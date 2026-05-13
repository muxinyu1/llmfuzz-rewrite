#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_DIR="${ROOT_DIR}/sources/atomboard"
COMPOSE_FILE="${SCRIPT_DIR}/compose.yaml"
ENV_EXAMPLE_FILE="${SCRIPT_DIR}/.env.example"
ENV_FILE="${SCRIPT_DIR}/.env"
APP_DOCKERFILE="${SCRIPT_DIR}/Dockerfile"
DB_DOCKERFILE="${ROOT_DIR}/sources/phpMyFAQ/install/docker/mariadb-revping/Dockerfile"
DB_CONTEXT="${ROOT_DIR}/sources/phpMyFAQ"
SETTINGS_TEMPLATE_FILE="${SOURCE_DIR}/settings.default.php"
SETTINGS_FILE="${SOURCE_DIR}/settings.php"

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
  echo "atomboard source tree not found under ${SOURCE_DIR}" >&2
  exit 1
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "compose file not found: ${COMPOSE_FILE}" >&2
  exit 1
fi

if [[ ! -f "${APP_DOCKERFILE}" ]]; then
  echo "App Dockerfile not found: ${APP_DOCKERFILE}" >&2
  exit 1
fi

if [[ ! -f "${DB_DOCKERFILE}" ]]; then
  echo "DB Dockerfile not found: ${DB_DOCKERFILE}" >&2
  exit 1
fi

if [[ ! -f "${SETTINGS_TEMPLATE_FILE}" ]]; then
  echo "settings template not found: ${SETTINGS_TEMPLATE_FILE}" >&2
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
upsert_env "ATOM_ADMINPASS" "${WEB_DEFAULT_PASSWORD}"

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
: "${ATOMBOARD_IMAGE_TAG:=atomboard-2da51ed}"
: "${MARIADB_IMAGE_TAG:=mariadb-10.11-revping}"
: "${MYSQL_ROOT_PASSWORD:=rootpasswd}"
: "${MYSQL_DATABASE:=atomboard}"
: "${MYSQL_USER:=atomboard}"
: "${MYSQL_PASSWORD:=atomboard}"
: "${MYSQL_HOST:=database}"
: "${MYSQL_PORT:=3306}"
: "${ATOMBOARD_HTTP_PORT:=3600}"
: "${ATOM_BOARD:=}"
: "${ATOM_BOARD_DESCRIPTION:=AtomBoard Local Test}"
: "${ATOM_TRIPSEED:=atomboard-tripseed}"
: "${ATOM_ADMINPASS:=${WEB_DEFAULT_PASSWORD}}"
APT_MIRROR="${APT_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian}"
DEBIAN_SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian-security}"

APP_IMAGE="${REGISTRY_IMAGE_PREFIX}:${ATOMBOARD_IMAGE_TAG}"
DB_IMAGE="${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}"

echo "==> Ensure writable app paths"
mkdir -p "${SOURCE_DIR}/res" "${SOURCE_DIR}/src" "${SOURCE_DIR}/thumb"
chmod 0777 "${SOURCE_DIR}/res" "${SOURCE_DIR}/src" "${SOURCE_DIR}/thumb" || true

if [[ ! -f "${SETTINGS_FILE}" ]]; then
  cp "${SETTINGS_TEMPLATE_FILE}" "${SETTINGS_FILE}"
  echo "Created ${SETTINGS_FILE} from settings.default.php"
fi

echo "==> Sync settings.php"
python3 - "${SETTINGS_FILE}" "${ATOM_BOARD}" "${ATOM_BOARD_DESCRIPTION}" "${ATOM_ADMINPASS}" "${MYSQL_HOST}" "${MYSQL_PORT}" "${MYSQL_USER}" "${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" "${ATOM_TRIPSEED}" <<'PY'
import pathlib
import re
import sys

settings_file = pathlib.Path(sys.argv[1])
atom_board, atom_desc, admin_pass, db_host, db_port, db_user, db_pass, db_name, trip_seed = sys.argv[2:11]
text = settings_file.read_text(encoding="utf-8")


def php_str(v: str) -> str:
    return "'" + v.replace("\\", "\\\\").replace("'", "\\'") + "'"


def replace_define(src: str, key: str, value: str) -> str:
    pattern = rf"define\('{re.escape(key)}',\s*.*?\);"
    repl = f"define('{key}', {value});"
    return re.sub(pattern, repl, src, count=1)

updated = text
updates = {
    "ATOM_BOARD": php_str(atom_board),
    "ATOM_BOARD_DESCRIPTION": php_str(atom_desc),
    "ATOM_ADMINPASS": php_str(admin_pass),
    "ATOM_DBMODE": php_str("mysqli"),
    "ATOM_DBHOST": php_str(db_host),
    "ATOM_DBPORT": str(int(db_port) if str(db_port).isdigit() else 3306),
    "ATOM_DBUSERNAME": php_str(db_user),
    "ATOM_DBPASSWORD": php_str(db_pass),
    "ATOM_DBNAME": php_str(db_name),
    "ATOM_TRIPSEED": php_str(trip_seed),
    "ATOM_POSTING_DELAY": "0",
    "ATOM_NOFILEOK": "true",
    "ATOM_CAPTCHA": php_str(""),
}

for key, value in updates.items():
    updated = replace_define(updated, key, value)

if updated != text:
    settings_file.write_text(updated, encoding="utf-8")
PY

chmod 0666 "${SETTINGS_FILE}" || true

cd "${SCRIPT_DIR}"

echo "==> Pull images (fallback to local build if unavailable)"
if ! docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull; then
  echo "==> Remote image pull failed, building images locally"

  echo "==> Build atomboard image: ${APP_IMAGE}"
  docker build \
    --build-arg "APT_MIRROR=${APT_MIRROR}" \
    --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
    -f "${APP_DOCKERFILE}" \
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

echo "==> Warm up application and initialize schema"
app_ready=0
for attempt in {1..40}; do
  if curl -fsS -L "http://localhost:${ATOMBOARD_HTTP_PORT}/imgboard.php" >/dev/null 2>&1; then
    app_ready=1
    break
  fi
  sleep 2
done

if [[ ${app_ready} -ne 1 ]]; then
  echo "AtomBoard HTTP endpoint is not reachable in time" >&2
  exit 1
fi

echo "==> Ensure seed ban record (used by admin lift SQLi path)"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" <<'SQL'
INSERT INTO bans (ip_from, ip_to, timestamp, expire, reason)
SELECT INET_ATON('127.0.0.1'), INET_ATON('127.0.0.1'), UNIX_TIMESTAMP(), 0, 'seed-ban-for-sqli'
WHERE NOT EXISTS (
  SELECT 1 FROM bans WHERE reason = 'seed-ban-for-sqli'
);
SQL

echo "==> Verify admin manage login"
COOKIE_JAR="$(mktemp)"
trap 'rm -f "${COOKIE_JAR}"' EXIT

curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${ATOMBOARD_HTTP_PORT}/imgboard.php?manage" >/dev/null

curl -fsS -L -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" -X POST \
  --data-urlencode "managepassword=${WEB_DEFAULT_PASSWORD}" \
  "http://localhost:${ATOMBOARD_HTTP_PORT}/imgboard.php?manage" >/dev/null

MANAGE_PAGE="$(curl -fsS -c "${COOKIE_JAR}" -b "${COOKIE_JAR}" \
  "http://localhost:${ATOMBOARD_HTTP_PORT}/imgboard.php?manage" || true)"

if ! grep -Eqi 'Raw post|Bans|Moderator panel|Status' <<<"${MANAGE_PAGE}"; then
  echo "Failed to verify AtomBoard admin manage access with configured password." >&2
  exit 1
fi

echo "==> AtomBoard is ready"
echo "Open: http://localhost:${ATOMBOARD_HTTP_PORT}"
echo "Compose project: atomboard (default)"
echo "Default manage login password: ${WEB_DEFAULT_PASSWORD}"
