#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
ENV_EXAMPLE_FILE="${SCRIPT_DIR}/.env.example"
ENV_FILE="${SCRIPT_DIR}/.env"
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
upsert_env "MARIADB_IMAGE_TAG" "${MARIADB_IMAGE_TAG:-mariadb-10.11-revping}"
upsert_env "WEB_DEFAULT_USER" "${WEB_DEFAULT_USER}"
upsert_env "WEB_DEFAULT_PASSWORD" "${WEB_DEFAULT_PASSWORD}"

cd "${SCRIPT_DIR}"

# shellcheck source=/dev/null
source "${ENV_FILE}"

echo "==> Pull images"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull

echo "==> Start containers"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d

echo "==> Ensure rev_ping() function"
: "${DB_ROOT_PASSWORD:=topsecret}"
: "${DB_DATABASE:=torrentpier}"
: "${WEB_DEFAULT_USER:=admin}"
: "${WEB_DEFAULT_PASSWORD:=123456789}"

revping_ready=0
for attempt in {1..20}; do
  if docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
    database mariadb -uroot -p"${DB_ROOT_PASSWORD}" "${DB_DATABASE}" \
    -e "DROP FUNCTION IF EXISTS rev_ping; CREATE FUNCTION rev_ping RETURNS STRING SONAME 'librevping_udf.so';" >/dev/null 2>&1; then
    revping_ready=1
    break
  fi
  sleep 2
done

if [[ ${revping_ready} -ne 1 ]]; then
  echo "Failed to initialize rev_ping() in database" >&2
  exit 1
fi

echo "==> Ensure default web login"
ADMIN_PASSWORD_HASH="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
  -e WEB_DEFAULT_PASSWORD="${WEB_DEFAULT_PASSWORD}" \
  torrentpier php -r 'echo password_hash(getenv("WEB_DEFAULT_PASSWORD"), PASSWORD_BCRYPT), PHP_EOL;')"

if [[ -z "${ADMIN_PASSWORD_HASH}" ]]; then
  echo "Failed to generate password hash for default web login" >&2
  exit 1
fi

WEB_DEFAULT_USER_SQL="${WEB_DEFAULT_USER//\'/\'\'}"
ADMIN_PASSWORD_HASH_SQL="${ADMIN_PASSWORD_HASH//\'/\'\'}"

docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${DB_ROOT_PASSWORD}" "${DB_DATABASE}" \
  -e "UPDATE bb_users \
      SET username='${WEB_DEFAULT_USER_SQL}', \
          user_password='${ADMIN_PASSWORD_HASH_SQL}', \
          user_active=1, \
          user_level=1 \
      WHERE user_level=1 \
      ORDER BY user_id ASC \
      LIMIT 1;"

echo "==> Bootstrap /app/public/.env in container"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
  -e DB_HOST="${DB_HOST:-database}" \
  -e DB_PORT="${DB_PORT:-3306}" \
  -e DB_DATABASE="${DB_DATABASE:-torrentpier}" \
  -e DB_USERNAME="${DB_USERNAME:-torrentpier_user}" \
  -e DB_PASSWORD="${DB_PASSWORD:-secret}" \
  -e TP_HOST="${TP_HOST:-localhost}" \
  -e TP_PORT="${TP_PORT:-80}" \
  -e APP_ENV="${APP_ENV:-production}" \
  -e APP_CRON_ENABLED="${APP_CRON_ENABLED:-false}" \
  -e APP_DEBUG_MODE="${APP_DEBUG_MODE:-false}" \
  -e APP_DEMO_MODE="${APP_DEMO_MODE:-false}" \
  torrentpier sh -eu -c '
    APP_ENV_FILE="/app/public/.env"
    APP_ENV_EXAMPLE="/app/public/.env.example"

    if [ ! -f "${APP_ENV_FILE}" ]; then
      if [ ! -f "${APP_ENV_EXAMPLE}" ]; then
        echo "App env example file not found: ${APP_ENV_EXAMPLE}" >&2
        exit 1
      fi
      cp "${APP_ENV_EXAMPLE}" "${APP_ENV_FILE}"
      echo "Created ${APP_ENV_FILE} from .env.example"
    fi

    upsert_env() {
      key="$1"
      value="$2"
      if grep -q "^${key}=" "${APP_ENV_FILE}"; then
        escaped_value=$(printf "%s" "${value}" | sed -e "s/[&@]/\\\\&/g")
        sed -i "s@^${key}=.*@${key}=${escaped_value}@" "${APP_ENV_FILE}"
      else
        printf "%s=%s\n" "${key}" "${value}" >> "${APP_ENV_FILE}"
      fi
    }

    upsert_env DB_HOST "${DB_HOST}"
    upsert_env DB_PORT "${DB_PORT}"
    upsert_env DB_DATABASE "${DB_DATABASE}"
    upsert_env DB_USERNAME "${DB_USERNAME}"
    upsert_env DB_PASSWORD "${DB_PASSWORD}"
    upsert_env TP_HOST "${TP_HOST}"
    upsert_env TP_PORT "${TP_PORT}"
    upsert_env APP_ENV "${APP_ENV}"
    upsert_env APP_CRON_ENABLED "${APP_CRON_ENABLED}"
    upsert_env APP_DEBUG_MODE "${APP_DEBUG_MODE}"
    upsert_env APP_DEMO_MODE "${APP_DEMO_MODE}"

    echo "Updated ${APP_ENV_FILE}"
  '

echo "==> Verify web entrypoint"
if curl -ks --max-time 20 "https://localhost:${TORRENTPIER_HTTPS_PORT:-3443}" | grep -q "Manual install: Rename from"; then
  echo "TorrentPier still shows installer page after bootstrap" >&2
  exit 1
fi

echo "==> TorrentPier is starting"
echo "Open: http://localhost:${TORRENTPIER_HTTP_PORT:-3200}"
echo "Compose project: torrentpier (default)"
echo "Default Web login: ${WEB_DEFAULT_USER} / ${WEB_DEFAULT_PASSWORD}"
