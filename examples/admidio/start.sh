#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/sources/admidio"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
ENV_EXAMPLE_FILE="${SCRIPT_DIR}/.env.example"
ENV_FILE="${SCRIPT_DIR}/.env"
DEMO_DB_SQL="${SOURCE_DIR}/demo_data/db.sql"
DEMO_DATA_SQL="${SOURCE_DIR}/demo_data/data.sql"

VERIFIER_PORT="8000"
VERIFIER_HOST="host.docker.internal"
WEB_DEFAULT_USER="Jack"
WEB_DEFAULT_PASSWORD="Jack.123456"
STATIC_ROLE_UUID="c3e251ba-9754-4b61-957b-c04118e2384d"

usage() {
  echo "Usage: $0 [--verifier-port PORT] [--verifier-host HOST] [--web-user USER] [--web-password PASSWORD] [--role-uuid UUID]"
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
    --role-uuid)
      STATIC_ROLE_UUID="$2"
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

if [[ ! -f "${DEMO_DB_SQL}" || ! -f "${DEMO_DATA_SQL}" ]]; then
  echo "Admidio demo SQL files are missing under ${SOURCE_DIR}/demo_data" >&2
  exit 1
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
upsert_env "STATIC_ROLE_UUID" "${STATIC_ROLE_UUID}"

cd "${SCRIPT_DIR}"

# shellcheck source=/dev/null
source "${ENV_FILE}"

echo "==> Pull images"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull

echo "==> Start containers"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d

: "${ADMIDIO_DB_ROOT_PASSWORD:=rootpasswd}"
: "${ADMIDIO_DB_NAME:=admidio}"
: "${ADMIDIO_DB_TABLE_PREFIX:=adm}"
: "${ADMIDIO_HTTP_PORT:=3100}"
: "${ADMIDIO_FILESYSTEM_VERSION:=4.3.16}"

echo "==> Wait for database readiness"
db_ready=0
for attempt in {1..40}; do
  if docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
    database mariadb -uroot -p"${ADMIDIO_DB_ROOT_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
    db_ready=1
    break
  fi
  sleep 2
done

if [[ ${db_ready} -ne 1 ]]; then
  echo "Database is not ready in time" >&2
  exit 1
fi

echo "==> Check whether demo schema is initialized"
BOOTSTRAPPED="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
  database mariadb -uroot -p"${ADMIDIO_DB_ROOT_PASSWORD}" -Nse \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${ADMIDIO_DB_NAME}' AND table_name='${ADMIDIO_DB_TABLE_PREFIX}_users';" \
  2>/dev/null || true)"
BOOTSTRAPPED="${BOOTSTRAPPED//$'\r'/}"
BOOTSTRAPPED="${BOOTSTRAPPED//$'\n'/}"

if [[ "${BOOTSTRAPPED}" != "1" ]]; then
  echo "==> Import Admidio demo schema/data into ${ADMIDIO_DB_NAME}"
  tmp_db_sql="$(mktemp)"
  tmp_data_sql="$(mktemp)"
  trap 'rm -f "${tmp_db_sql}" "${tmp_data_sql}"' EXIT

  sed "s/%PREFIX%/${ADMIDIO_DB_TABLE_PREFIX}/g" "${DEMO_DB_SQL}" > "${tmp_db_sql}"
  sed "s/%PREFIX%/${ADMIDIO_DB_TABLE_PREFIX}/g" "${DEMO_DATA_SQL}" > "${tmp_data_sql}"

  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
    database mariadb -uroot -p"${ADMIDIO_DB_ROOT_PASSWORD}" "${ADMIDIO_DB_NAME}" < "${tmp_db_sql}"

  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
    database mariadb -uroot -p"${ADMIDIO_DB_ROOT_PASSWORD}" "${ADMIDIO_DB_NAME}" < "${tmp_data_sql}"

  rm -f "${tmp_db_sql}" "${tmp_data_sql}"
  trap - EXIT
else
  echo "==> Demo schema already present, skip full import"
fi

echo "==> Ensure rev_ping() + login credentials + static role UUID"
ADMIN_PASSWORD_HASH="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
  -e WEB_DEFAULT_PASSWORD="${WEB_DEFAULT_PASSWORD}" \
  admidio php -r 'echo password_hash(getenv("WEB_DEFAULT_PASSWORD"), PASSWORD_DEFAULT), PHP_EOL;')"

if [[ -z "${ADMIN_PASSWORD_HASH}" ]]; then
  echo "Failed to generate password hash for ${WEB_DEFAULT_USER}" >&2
  exit 1
fi

WEB_DEFAULT_USER_SQL="${WEB_DEFAULT_USER//\'/\'\'}"
ADMIN_PASSWORD_HASH_SQL="${ADMIN_PASSWORD_HASH//\'/\'\'}"
STATIC_ROLE_UUID_SQL="${STATIC_ROLE_UUID//\'/\'\'}"
ADMIDIO_FILESYSTEM_VERSION_SQL="${ADMIDIO_FILESYSTEM_VERSION//\'/\'\'}"

docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${ADMIDIO_DB_ROOT_PASSWORD}" "${ADMIDIO_DB_NAME}" \
  -e "DROP FUNCTION IF EXISTS rev_ping;
      CREATE FUNCTION rev_ping RETURNS STRING SONAME 'librevping_udf.so';
      UPDATE ${ADMIDIO_DB_TABLE_PREFIX}_components
         SET com_version='${ADMIDIO_FILESYSTEM_VERSION_SQL}',
             com_beta=0,
             com_update_completed=1
       WHERE com_type='SYSTEM' AND com_name_intern='CORE';
      UPDATE ${ADMIDIO_DB_TABLE_PREFIX}_users
         SET usr_login_name='${WEB_DEFAULT_USER_SQL}',
             usr_password='${ADMIN_PASSWORD_HASH_SQL}',
             usr_valid=1
       WHERE usr_id=1;
      UPDATE ${ADMIDIO_DB_TABLE_PREFIX}_roles
         SET rol_uuid='${STATIC_ROLE_UUID_SQL}'
       WHERE rol_id=1;"

echo "==> Verify login page token availability"
if ! curl -fsSL --max-time 20 "http://localhost:${ADMIDIO_HTTP_PORT}/adm_program/overview.php" | grep -q "admidio-csrf-token"; then
  echo "Admidio did not expose login CSRF token as expected" >&2
  exit 1
fi

echo "==> Admidio is ready"
echo "Open: http://localhost:${ADMIDIO_HTTP_PORT}"
echo "Default Web login: ${WEB_DEFAULT_USER} / ${WEB_DEFAULT_PASSWORD}"
echo "Static role UUID (for replay): ${STATIC_ROLE_UUID}"
