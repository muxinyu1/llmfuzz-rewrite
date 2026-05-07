#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_DIR="${ROOT_DIR}/docker"
ENV_FILE="${DOCKER_DIR}/.env.prod-5.21.0"
COMPOSE_FILE="${DOCKER_DIR}/docker-compose.prod-5.21.0.yaml"
PROJECT_NAME="${COMPOSE_PROJECT_NAME:-churchcrm-prod-5210}"

if [[ ! -f "${ENV_FILE}" ]]; then
  cat > "${ENV_FILE}" <<'EOF'
REGISTRY_IMAGE_PREFIX=crpi-8tnv6lve87c20oxm.cn-beijing.personal.cr.aliyuncs.com/llmfuzz/llmfuzz-dockerhub
MYSQL_ROOT_PASSWORD=changeme
MYSQL_DATABASE=churchcrm
MYSQL_USER=churchcrm
MYSQL_PASSWORD=changeme
WEB_DEFAULT_USER=admin
WEB_DEFAULT_PASSWORD=Admin@123456
VERIFIER_HOST=127.0.0.1
VERIFIER_PORT=80
CRM_HTTP_PORT=8080
EOF
  echo "Created ${ENV_FILE}."
fi

cd "${DOCKER_DIR}"

echo "==> Pull images"
docker compose -p "${PROJECT_NAME}" --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull

echo "==> Start containers"
docker compose -p "${PROJECT_NAME}" --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d

echo "==> Ensure default web login and rev_ping() function"
source "${ENV_FILE}"
: "${MYSQL_ROOT_PASSWORD:=changeme}"
: "${MYSQL_DATABASE:=churchcrm}"
: "${WEB_DEFAULT_USER:=admin}"
: "${WEB_DEFAULT_PASSWORD:=Admin@123456}"
docker compose -p "${PROJECT_NAME}" --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" exec -T database \
  mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" <<SQL
DROP FUNCTION IF EXISTS rev_ping;
CREATE FUNCTION rev_ping RETURNS STRING SONAME 'librevping_udf.so';

UPDATE user_usr
SET usr_UserName = '${WEB_DEFAULT_USER}',
    usr_Password = SHA2(CONCAT('${WEB_DEFAULT_PASSWORD}', usr_per_ID), 256),
    usr_NeedPasswordChange = 0,
    usr_FailedLogins = 0
WHERE usr_per_ID = (
    SELECT admin_usr_per_ID FROM (
        SELECT usr_per_ID AS admin_usr_per_ID
        FROM user_usr
        WHERE usr_Admin = 1
        ORDER BY usr_per_ID ASC
        LIMIT 1
    ) AS t
);
SQL

echo "==> ChurchCRM is starting"
echo "Open: http://localhost:${CRM_HTTP_PORT:-8080}"
echo "Compose project: ${PROJECT_NAME}"
echo "Default Web login: ${WEB_DEFAULT_USER} / ${WEB_DEFAULT_PASSWORD}"
