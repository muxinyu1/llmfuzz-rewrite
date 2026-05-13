#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_ROOT="${ROOT_DIR}/sources/phpMyFAQ"
APP_CODE_DIR="${SOURCE_ROOT}/phpmyfaq"
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

if [[ ! -d "${SOURCE_ROOT}" || ! -d "${APP_CODE_DIR}" ]]; then
  echo "phpMyFAQ source tree not found under ${SOURCE_ROOT}" >&2
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

cd "${SCRIPT_DIR}"

load_env_file() {
  local file="$1"
  local line key value first_char last_char

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%$'\r'}"

    # Skip empty lines and comments
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "${line}" =~ ^[[:space:]]*# ]] && continue

    key="${line%%=*}"
    value="${line#*=}"

    # Trim spaces around key
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    [[ -z "${key}" ]] && continue

    # Remove optional surrounding quotes from value
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
: "${PHPMYFAQ_IMAGE_TAG:=phpmyfaq-4.0.13}"
: "${MARIADB_IMAGE_TAG:=mariadb-10.11-revping}"
: "${MYSQL_ROOT_PASSWORD:=rootpasswd}"
: "${MYSQL_DATABASE:=phpmyfaq}"
: "${MYSQL_USER:=phpmyfaq}"
: "${MYSQL_PASSWORD:=phpmyfaq}"
: "${PHPMYFAQ_HTTP_PORT:=3300}"
APT_MIRROR="${APT_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian}"
DEBIAN_SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian-security}"

APP_IMAGE="${REGISTRY_IMAGE_PREFIX}:${PHPMYFAQ_IMAGE_TAG}"
DB_IMAGE="${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}"
DB_DOCKERFILE="${SOURCE_ROOT}/install/docker/mariadb-revping/Dockerfile"

echo "==> Ensure PHP dependencies (composer install)"
if [[ ! -f "${APP_CODE_DIR}/src/libs/autoload.php" ]]; then
  docker run --rm \
    -v "${SOURCE_ROOT}:/app" \
    -w /app \
    composer:2 \
    composer install --no-dev --ignore-platform-reqs
fi

echo "==> Pull images (fallback to local build if unavailable)"
if ! docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull; then
  echo "==> Remote image pull failed, building images locally"

  if [[ ! -f "${DB_DOCKERFILE}" ]]; then
    echo "DB Dockerfile not found: ${DB_DOCKERFILE}" >&2
    exit 1
  fi

  echo "==> Build phpMyFAQ image: ${APP_IMAGE}"
  docker build \
    --build-arg "APT_MIRROR=${APT_MIRROR}" \
    --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
    -t "${APP_IMAGE}" "${SOURCE_ROOT}"

  echo "==> Build MariaDB revping image: ${DB_IMAGE}"
  docker build \
    --build-arg "APT_MIRROR=${APT_MIRROR}" \
    --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
    -f "${DB_DOCKERFILE}" -t "${DB_IMAGE}" "${SOURCE_ROOT}"
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

echo "==> Check phpMyFAQ installation status"
INSTALLED_TABLE_COUNT="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T \
  database mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -Nse \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}' AND table_name='faqconfig';" \
  2>/dev/null || true)"

INSTALLED_TABLE_COUNT="${INSTALLED_TABLE_COUNT//$'\r'/}"
INSTALLED_TABLE_COUNT="${INSTALLED_TABLE_COUNT//$'\n'/}"
INSTALLED_TABLE_COUNT="$(echo "${INSTALLED_TABLE_COUNT}" | tr -d '[:space:]')"

if [[ "${INSTALLED_TABLE_COUNT}" != "1" ]]; then
  echo "==> First run detected, execute setup installer"

  app_ready=0
  for attempt in {1..40}; do
    if curl -fsS --max-time 20 "http://localhost:${PHPMYFAQ_HTTP_PORT}/setup/index.php" >/dev/null 2>&1; then
      app_ready=1
      break
    fi
    sleep 2
  done

  if [[ ${app_ready} -ne 1 ]]; then
    echo "phpMyFAQ setup page is not reachable" >&2
    exit 1
  fi

  INSTALL_RESPONSE="$(curl -fsS --max-time 120 -X POST "http://localhost:${PHPMYFAQ_HTTP_PORT}/setup/install" \
    --data-urlencode "sql_type=mysqli" \
    --data-urlencode "sql_server=database" \
    --data-urlencode "sql_port=3306" \
    --data-urlencode "sql_user=${MYSQL_USER}" \
    --data-urlencode "sql_password=${MYSQL_PASSWORD}" \
    --data-urlencode "sql_db=${MYSQL_DATABASE}" \
    --data-urlencode "sqltblpre=" \
    --data-urlencode "language=en" \
    --data-urlencode "permLevel=basic" \
    --data-urlencode "realname=Admin User" \
    --data-urlencode "email=admin@example.com" \
    --data-urlencode "loginname=${WEB_DEFAULT_USER}" \
    --data-urlencode "password=${WEB_DEFAULT_PASSWORD}" \
    --data-urlencode "password_retyped=${WEB_DEFAULT_PASSWORD}")"

  if ! grep -qi "installation worked like a charm" <<<"${INSTALL_RESPONSE}"; then
    echo "phpMyFAQ setup did not finish successfully" >&2
    echo "Response excerpt:" >&2
    echo "${INSTALL_RESPONSE}" | head -c 1200 >&2 || true
    exit 1
  fi
fi

echo "==> Verify admin login and config CSRF token"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "${COOKIE_JAR}"' EXIT

curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${PHPMYFAQ_HTTP_PORT}/admin/index.php" >/dev/null

curl -fsS -L -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" -X POST \
  --data-urlencode "faqusername=${WEB_DEFAULT_USER}" \
  --data-urlencode "faqpassword=${WEB_DEFAULT_PASSWORD}" \
  "http://localhost:${PHPMYFAQ_HTTP_PORT}/admin/index.php" >/dev/null

CONFIG_PAGE="$(curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${PHPMYFAQ_HTTP_PORT}/admin/index.php?action=config" || true)"

if ! grep -q 'id="pmf-csrf-token"' <<<"${CONFIG_PAGE}"; then
  echo "Failed to login with configured credentials or to fetch configuration CSRF token." >&2
  echo "If this is an existing deployment with different admin credentials, run shutdown.sh and start fresh." >&2
  exit 1
fi

echo "==> phpMyFAQ is ready"
echo "Open: http://localhost:${PHPMYFAQ_HTTP_PORT}"
echo "Compose project: phpmyfaq (default)"
echo "Default Web login: ${WEB_DEFAULT_USER} / ${WEB_DEFAULT_PASSWORD}"
