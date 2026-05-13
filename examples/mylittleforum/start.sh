#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/sources/mylittleforum"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
ENV_EXAMPLE_FILE="${SCRIPT_DIR}/.env.example"
ENV_FILE="${SCRIPT_DIR}/.env"
INSTALL_SQL="${SOURCE_DIR}/install/install.sql"
DB_SETTINGS_FILE="${SOURCE_DIR}/config/db_settings.php"
DB_DOCKERFILE="${SOURCE_DIR}/install/docker/mariadb-revping/Dockerfile"

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
  echo "mylittleforum source tree not found under ${SOURCE_DIR}" >&2
  exit 1
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "compose file not found: ${COMPOSE_FILE}" >&2
  exit 1
fi

if [[ ! -f "${INSTALL_SQL}" ]]; then
  echo "install.sql not found: ${INSTALL_SQL}" >&2
  exit 1
fi

if [[ ! -f "${DB_SETTINGS_FILE}" ]]; then
  echo "db settings file not found: ${DB_SETTINGS_FILE}" >&2
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
: "${MYLITTLEFORUM_IMAGE_TAG:=mylittleforum-2.5.11}"
: "${MARIADB_IMAGE_TAG:=mariadb-10.11-revping}"
: "${MYSQL_ROOT_PASSWORD:=rootpasswd}"
: "${MYSQL_DATABASE:=mylittleforum}"
: "${MYSQL_USER:=mylittleforum}"
: "${MYSQL_PASSWORD:=mylittleforum}"
: "${MYLITTLEFORUM_HTTP_PORT:=3400}"
: "${MYLITTLEFORUM_DB_HOST:=database}"
: "${MYLITTLEFORUM_TABLE_PREFIX:=mlf2}"
: "${MYLITTLEFORUM_FORUM_ADDRESS:=http://localhost:${MYLITTLEFORUM_HTTP_PORT}/}"
APT_MIRROR="${APT_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian}"
DEBIAN_SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian-security}"

APP_IMAGE="${REGISTRY_IMAGE_PREFIX}:${MYLITTLEFORUM_IMAGE_TAG}"
DB_IMAGE="${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}"

echo "==> Ensure writable app paths"
mkdir -p "${SOURCE_DIR}/templates_c" "${SOURCE_DIR}/backup" "${SOURCE_DIR}/uploaded"
chmod 0777 "${SOURCE_DIR}/templates_c" || true
chmod 0666 "${DB_SETTINGS_FILE}" || true

echo "==> Sync db_settings.php"
python3 - "${DB_SETTINGS_FILE}" "${MYLITTLEFORUM_DB_HOST}" "${MYSQL_DATABASE}" "${MYSQL_USER}" "${MYSQL_PASSWORD}" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
host, database, user, password = sys.argv[2:6]
text = path.read_text(encoding="utf-8")

def replace_setting(src: str, key: str, value: str) -> str:
    value = value.replace("'", "\\'")
    pattern = rf"^\$db_settings\['{re.escape(key)}'\]\s*=\s*'.*?';"
    repl = f"$db_settings['{key}'] = '{value}';"
    return re.sub(pattern, repl, src, count=1, flags=re.MULTILINE)

updated = text
updated = replace_setting(updated, "host", host)
updated = replace_setting(updated, "database", database)
updated = replace_setting(updated, "user", user)
updated = replace_setting(updated, "password", password)

if updated != text:
    path.write_text(updated, encoding="utf-8")
PY

cd "${SCRIPT_DIR}"

echo "==> Pull images (fallback to local build if unavailable)"
if ! docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull; then
  echo "==> Remote image pull failed, building images locally"

  if [[ ! -f "${DB_DOCKERFILE}" ]]; then
    echo "DB Dockerfile not found: ${DB_DOCKERFILE}" >&2
    exit 1
  fi

  echo "==> Build mylittleforum image: ${APP_IMAGE}"
  docker build \
    --build-arg "APT_MIRROR=${APT_MIRROR}" \
    --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
    -t "${APP_IMAGE}" "${SOURCE_DIR}"

  echo "==> Build MariaDB revping image: ${DB_IMAGE}"
  docker build \
    --build-arg "APT_MIRROR=${APT_MIRROR}" \
    --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
    -f "${DB_DOCKERFILE}" -t "${DB_IMAGE}" "${SOURCE_DIR}"
fi

echo "==> Start containers"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d

echo "==> Wait for database readiness"
db_ready=0
for attempt in {1..40}; do
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

echo "==> Ensure rev_ping() function"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" \
  -e "DROP FUNCTION IF EXISTS rev_ping; CREATE FUNCTION rev_ping RETURNS STRING SONAME 'librevping_udf.so';"

echo "==> Ensure base schema"
TABLE_COUNT="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
  database mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -Nse \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}' AND table_name='${MYLITTLEFORUM_TABLE_PREFIX}_settings';" \
  2>/dev/null || true)"
TABLE_COUNT="${TABLE_COUNT//$'\r'/}"
TABLE_COUNT="${TABLE_COUNT//$'\n'/}"
TABLE_COUNT="$(echo "${TABLE_COUNT}" | tr -d '[:space:]')"

if [[ "${TABLE_COUNT}" != "1" ]]; then
  echo "==> Import install.sql"
  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
    mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < "${INSTALL_SQL}"
fi

echo "==> Ensure default admin login and seed bookmarks"
ADMIN_PASSWORD_HASH="$(python3 - "${WEB_DEFAULT_PASSWORD}" <<'PY'
import hashlib
import secrets
import sys

pw = sys.argv[1]
salt = secrets.token_hex(5)
print(hashlib.sha1((pw + salt).encode()).hexdigest() + salt)
PY
)"

WEB_DEFAULT_USER_SQL="${WEB_DEFAULT_USER//\'/\'\'}"
ADMIN_PASSWORD_HASH_SQL="${ADMIN_PASSWORD_HASH//\'/\'\'}"
FORUM_ADDRESS_SQL="${MYLITTLEFORUM_FORUM_ADDRESS//\'/\'\'}"

docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" <<SQL
INSERT INTO ${MYLITTLEFORUM_TABLE_PREFIX}_userdata (user_type, user_name, user_pw, user_email, email_contact, profile, logins, last_login, last_logout, registered, pwf_code, theme)
SELECT 2, 'admin', '${ADMIN_PASSWORD_HASH_SQL}', 'admin@example.com', 1, '', 0, NOW(), NOW(), NOW(), '', ''
WHERE NOT EXISTS (SELECT 1 FROM ${MYLITTLEFORUM_TABLE_PREFIX}_userdata WHERE user_type = 2);

UPDATE ${MYLITTLEFORUM_TABLE_PREFIX}_userdata
SET user_name = '${WEB_DEFAULT_USER_SQL}',
    user_pw = '${ADMIN_PASSWORD_HASH_SQL}',
    activate_code = '',
    user_lock = 0,
    email_contact = 1,
    last_login = last_login,
    registered = registered
WHERE user_type = 2
ORDER BY user_id ASC
LIMIT 1;

INSERT INTO ${MYLITTLEFORUM_TABLE_PREFIX}_settings (name, value)
VALUES ('forum_address', '${FORUM_ADDRESS_SQL}')
ON DUPLICATE KEY UPDATE value = VALUES(value);

INSERT INTO ${MYLITTLEFORUM_TABLE_PREFIX}_categories (order_id, category, description, accession)
SELECT 1, 'General', 'General category', 0
WHERE NOT EXISTS (
  SELECT 1
  FROM ${MYLITTLEFORUM_TABLE_PREFIX}_categories
  WHERE category = 'General'
);

SET @admin_id := (
  SELECT user_id
  FROM ${MYLITTLEFORUM_TABLE_PREFIX}_userdata
  WHERE user_type = 2
  ORDER BY user_id ASC
  LIMIT 1
);

INSERT INTO ${MYLITTLEFORUM_TABLE_PREFIX}_entries (pid, tid, uniqid, user_id, name, subject, category, text, last_reply)
SELECT 0, 0, UUID(), @admin_id, '${WEB_DEFAULT_USER_SQL}', 'Seed topic A', 1, 'Seed content A', NOW()
WHERE NOT EXISTS (
  SELECT 1
  FROM ${MYLITTLEFORUM_TABLE_PREFIX}_entries
  WHERE subject = 'Seed topic A'
);

INSERT INTO ${MYLITTLEFORUM_TABLE_PREFIX}_entries (pid, tid, uniqid, user_id, name, subject, category, text, last_reply)
SELECT 0, 0, UUID(), @admin_id, '${WEB_DEFAULT_USER_SQL}', 'Seed topic B', 1, 'Seed content B', NOW()
WHERE NOT EXISTS (
  SELECT 1
  FROM ${MYLITTLEFORUM_TABLE_PREFIX}_entries
  WHERE subject = 'Seed topic B'
);

SET @oid := 0;
INSERT IGNORE INTO ${MYLITTLEFORUM_TABLE_PREFIX}_bookmarks (user_id, posting_id, subject, order_id)
SELECT @admin_id, e.id, e.subject, (@oid := @oid + 1)
FROM ${MYLITTLEFORUM_TABLE_PREFIX}_entries e
ORDER BY e.id ASC
LIMIT 2;
SQL

echo "==> Verify login and bookmarks page"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "${COOKIE_JAR}"' EXIT

curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${MYLITTLEFORUM_HTTP_PORT}/index.php?mode=login" >/dev/null

curl -fsS -L -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" -X POST \
  --data-urlencode "username=${WEB_DEFAULT_USER}" \
  --data-urlencode "userpw=${WEB_DEFAULT_PASSWORD}" \
  "http://localhost:${MYLITTLEFORUM_HTTP_PORT}/index.php?mode=login" >/dev/null

BOOKMARK_PAGE="$(curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${MYLITTLEFORUM_HTTP_PORT}/index.php?mode=bookmarks" || true)"

if ! grep -Eqi 'mode=bookmarks|subnav_bookmarks|bookmark' <<<"${BOOKMARK_PAGE}"; then
  echo "Failed to verify bookmark page access with configured credentials." >&2
  exit 1
fi

echo "==> my little forum is ready"
echo "Open: http://localhost:${MYLITTLEFORUM_HTTP_PORT}"
echo "Compose project: mylittleforum (default)"
echo "Default Web login: ${WEB_DEFAULT_USER} / ${WEB_DEFAULT_PASSWORD}"