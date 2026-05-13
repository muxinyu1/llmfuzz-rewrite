#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/sources/cloudlog"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
ENV_EXAMPLE_FILE="${SCRIPT_DIR}/.env.example"
ENV_FILE="${SCRIPT_DIR}/.env"
INSTALL_SQL_FILE="${SOURCE_DIR}/install/assets/install.sql"

VERIFIER_PORT="8000"
VERIFIER_HOST="host.docker.internal"
WEB_DEFAULT_USER="admin"
WEB_DEFAULT_PASSWORD="123456789"

usage() {
  echo "Usage: $0 [--verifier-port PORT] [--verifier-host HOST] [--web-user USER] [--web-password PASSWORD]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verifier-port)
      VERIFIER_PORT="$2"
      shift 2
      ;;
    --verifier-host)
      VERIFIER_HOST="$2"
      shift 2
      ;;
    --web-user)
      WEB_DEFAULT_USER="$2"
      shift 2
      ;;
    --web-password)
      WEB_DEFAULT_PASSWORD="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      ;;
  esac
done

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "cloudlog source tree not found under ${SOURCE_DIR}" >&2
  exit 1
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "compose file not found: ${COMPOSE_FILE}" >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  if [[ ! -f "${ENV_EXAMPLE_FILE}" ]]; then
    echo "env example file not found: ${ENV_EXAMPLE_FILE}" >&2
    exit 1
  fi
  cp "${ENV_EXAMPLE_FILE}" "${ENV_FILE}"
  echo "Created ${ENV_FILE} from .env.example"
fi

upsert_env() {
  local key="$1"
  local value="$2"
  if grep -q "^${key}=" "${ENV_FILE}"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "${ENV_FILE}"
  else
    echo "${key}=${value}" >> "${ENV_FILE}"
  fi
}

upsert_env "VERIFIER_HOST" "${VERIFIER_HOST}"
upsert_env "VERIFIER_PORT" "${VERIFIER_PORT}"
upsert_env "WEB_DEFAULT_USER" "${WEB_DEFAULT_USER}"
upsert_env "WEB_DEFAULT_PASSWORD" "${WEB_DEFAULT_PASSWORD}"

load_env_file() {
  local file="$1"
  local line key value first_char last_char

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%$'\r'}"

    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "${line}" =~ ^[[:space:]]*# ]] && continue

    key="${line%%=*}"
    value="${line#*=}"

    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    [[ -z "${key}" ]] && continue

    if [[ ${#value} -ge 2 ]]; then
      first_char="${value:0:1}"
      last_char="${value: -1}"
      if [[ "${first_char}" == '"' && "${last_char}" == '"' ]] || [[ "${first_char}" == "'" && "${last_char}" == "'" ]]; then
        value="${value:1:${#value}-2}"
      fi
    fi

    export "${key}=${value}"
  done < "${file}"
}

load_env_file "${ENV_FILE}"

: "${REGISTRY_IMAGE_PREFIX:=crpi-8tnv6lve87c20oxm.cn-beijing.personal.cr.aliyuncs.com/llmfuzz/llmfuzz-dockerhub}"
: "${CLOUDLOG_IMAGE_TAG:=cloudlog-2.7.5}"
: "${MARIADB_IMAGE_TAG:=mariadb-10.11-revping}"
: "${MYSQL_ROOT_PASSWORD:=rootpassword}"
: "${MYSQL_DATABASE:=cloudlog}"
: "${MYSQL_USER:=cloudlog}"
: "${MYSQL_PASSWORD:=cloudlogpassword}"
: "${MYSQL_HOST:=database}"
: "${MYSQL_PORT:=3306}"
: "${CLOUDLOG_HTTP_PORT:=3500}"
: "${BASE_LOCATOR:=IO91WM}"
: "${DIRECTORY:=/var/www/html}"
: "${WEBSITE_URL:=http://localhost:${CLOUDLOG_HTTP_PORT}}"
APT_MIRROR="${APT_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian}"
DEBIAN_SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian-security}"

upsert_env "REGISTRY_IMAGE_PREFIX" "${REGISTRY_IMAGE_PREFIX}"
upsert_env "CLOUDLOG_IMAGE_TAG" "${CLOUDLOG_IMAGE_TAG}"
upsert_env "MARIADB_IMAGE_TAG" "${MARIADB_IMAGE_TAG}"
upsert_env "MYSQL_ROOT_PASSWORD" "${MYSQL_ROOT_PASSWORD}"
upsert_env "MYSQL_DATABASE" "${MYSQL_DATABASE}"
upsert_env "MYSQL_USER" "${MYSQL_USER}"
upsert_env "MYSQL_PASSWORD" "${MYSQL_PASSWORD}"
upsert_env "MYSQL_HOST" "${MYSQL_HOST}"
upsert_env "MYSQL_PORT" "${MYSQL_PORT}"
upsert_env "CLOUDLOG_HTTP_PORT" "${CLOUDLOG_HTTP_PORT}"
upsert_env "BASE_LOCATOR" "${BASE_LOCATOR}"
upsert_env "DIRECTORY" "${DIRECTORY}"
upsert_env "WEBSITE_URL" "${WEBSITE_URL}"

APP_IMAGE="${REGISTRY_IMAGE_PREFIX}:${CLOUDLOG_IMAGE_TAG}"
DB_IMAGE="${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}"
DB_DOCKERFILE="${ROOT_DIR}/sources/phpMyFAQ/install/docker/mariadb-revping/Dockerfile"
DB_CONTEXT="${ROOT_DIR}/sources/phpMyFAQ"

cat > "${SOURCE_DIR}/.env" <<EOF
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
MYSQL_HOST=${MYSQL_HOST}
MYSQL_PORT=${MYSQL_PORT}
BASE_LOCATOR=${BASE_LOCATOR}
WEBSITE_URL=${WEBSITE_URL}
DIRECTORY=${DIRECTORY}
EOF

echo "==> Prepared ${SOURCE_DIR}/.env for Cloudlog startup script"

cd "${SCRIPT_DIR}"

echo "==> Pull images (fallback to local build if unavailable)"
if ! docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull; then
  echo "==> Remote image pull failed, building images locally"

  if [[ ! -f "${DB_DOCKERFILE}" ]]; then
    echo "DB Dockerfile not found: ${DB_DOCKERFILE}" >&2
    exit 1
  fi

  echo "==> Build Cloudlog image: ${APP_IMAGE}"
  docker build \
    --build-arg "APT_MIRROR=${APT_MIRROR}" \
    --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
    -t "${APP_IMAGE}" "${SOURCE_DIR}"

  echo "==> Build MariaDB revping image: ${DB_IMAGE}"
  docker build \
    --build-arg "APT_MIRROR=${APT_MIRROR}" \
    --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
    -f "${DB_DOCKERFILE}" -t "${DB_IMAGE}" "${DB_CONTEXT}"
fi

echo "==> Start containers"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d

echo "==> Wait for database readiness"
db_ready=0
for attempt in {1..50}; do
  if docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
    database mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
    db_ready=1
    break
  fi
  sleep 2
done

if [[ ${db_ready} -ne 1 ]]; then
  echo "Database is not ready in time" >&2
  exit 1
fi

echo "==> Ensure Cloudlog database schema"
users_table_exists="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -N -s -uroot -p"${MYSQL_ROOT_PASSWORD}" -e \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}' AND table_name='users';")"

if [[ "${users_table_exists}" == "0" ]]; then
  if [[ ! -f "${INSTALL_SQL_FILE}" ]]; then
    echo "Cloudlog install SQL not found: ${INSTALL_SQL_FILE}" >&2
    exit 1
  fi

  echo "==> users table missing, bootstrap schema from install.sql"
  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
    mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < "${INSTALL_SQL_FILE}"
fi

echo "==> Ensure Cloudlog migration/login page is reachable"
app_ready=0
for attempt in {1..60}; do
  if curl -fsS --max-time 20 "http://localhost:${CLOUDLOG_HTTP_PORT}/index.php/user/login" >/dev/null 2>&1; then
    app_ready=1
    break
  fi
  sleep 2
done

if [[ ${app_ready} -ne 1 ]]; then
  echo "Cloudlog login page is not reachable" >&2
  exit 1
fi

echo "==> Ensure rev_ping() function"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" \
  -e "DROP FUNCTION IF EXISTS rev_ping; CREATE FUNCTION rev_ping RETURNS STRING SONAME 'librevping_udf.so';"

echo "==> Ensure default admin credentials and minimal data"
ADMIN_PASSWORD_HASH="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
  -e WEB_DEFAULT_PASSWORD="${WEB_DEFAULT_PASSWORD}" \
  cloudlog php -r 'echo password_hash(getenv("WEB_DEFAULT_PASSWORD"), PASSWORD_DEFAULT), PHP_EOL;')"

if [[ -z "${ADMIN_PASSWORD_HASH}" ]]; then
  echo "Failed to generate password hash for default web login" >&2
  exit 1
fi

WEB_DEFAULT_USER_SQL="${WEB_DEFAULT_USER//\'/\'\'}"
ADMIN_PASSWORD_HASH_SQL="${ADMIN_PASSWORD_HASH//\'/\'\'}"

docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" <<SQL
UPDATE users
SET user_name='${WEB_DEFAULT_USER_SQL}',
    user_password='${ADMIN_PASSWORD_HASH_SQL}',
    user_email='admin@example.com',
    user_type='99',
    user_callsign='M0ABC',
    user_locator='IO91JS',
    user_firstname='Admin',
    user_lastname='User'
ORDER BY user_id ASC
LIMIT 1;

SET @uid := (SELECT user_id FROM users ORDER BY user_id ASC LIMIT 1);

INSERT INTO station_logbooks (user_id, logbook_name)
SELECT @uid, 'Default Logbook'
WHERE NOT EXISTS (
  SELECT 1 FROM station_logbooks WHERE user_id = @uid
);

SET @logbook_id := (SELECT logbook_id FROM station_logbooks WHERE user_id = @uid ORDER BY logbook_id ASC LIMIT 1);

UPDATE users
SET active_station_logbook = @logbook_id
WHERE user_id = @uid;

INSERT INTO station_logbooks_relationship (station_logbook_id, station_location_id)
SELECT @logbook_id, 1
WHERE NOT EXISTS (
  SELECT 1
  FROM station_logbooks_relationship
  WHERE station_logbook_id = @logbook_id
    AND station_location_id = 1
);

INSERT INTO TABLE_HRD_CONTACTS_V01 (
  station_id,
  COL_CALL,
  COL_TIME_ON,
  COL_TIME_OFF,
  COL_BAND,
  COL_MODE,
  COL_GRIDSQUARE,
  COL_VUCC_GRIDS,
  COL_PROP_MODE,
  COL_COUNTRY,
  COL_DXCC
)
SELECT
  1,
  'N0CALL',
  NOW(),
  NOW(),
  '2m',
  'SSB',
  'IO91',
  '',
  '',
  'England',
  '223'
WHERE NOT EXISTS (
  SELECT 1 FROM TABLE_HRD_CONTACTS_V01 WHERE station_id = 1
);
SQL

echo "==> Verify login and awards endpoint"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "${COOKIE_JAR}"' EXIT

curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${CLOUDLOG_HTTP_PORT}/index.php/user/login" >/dev/null

curl -fsS -L -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" -X POST \
  --data-urlencode "user_name=${WEB_DEFAULT_USER}" \
  --data-urlencode "user_password=${WEB_DEFAULT_PASSWORD}" \
  "http://localhost:${CLOUDLOG_HTTP_PORT}/index.php/user/login" >/dev/null

AWARDS_PAGE="$(curl -fsS -L -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${CLOUDLOG_HTTP_PORT}/index.php/awards" || true)"

if ! grep -Eqi 'Awards|VUCC' <<<"${AWARDS_PAGE}"; then
  echo "Failed to verify awards page access with configured credentials." >&2
  exit 1
fi

curl -fsS -L -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" -X POST \
  --data-urlencode "Gridsquare=IO91" \
  --data-urlencode "Band=All" \
  "http://localhost:${CLOUDLOG_HTTP_PORT}/index.php/awards/vucc_details_ajax" >/dev/null

echo "==> Cloudlog is ready"
echo "Open: http://localhost:${CLOUDLOG_HTTP_PORT}"
echo "Compose project: cloudlog (default)"
echo "Default Web login: ${WEB_DEFAULT_USER} / ${WEB_DEFAULT_PASSWORD}"
