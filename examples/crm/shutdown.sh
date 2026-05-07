#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="${SCRIPT_DIR}"
COMPOSE_FILE="${DOCKER_DIR}/compose.yaml"
ENV_FILE="${DOCKER_DIR}/.env.prod-5.21.0"

# Keep the same project name used by start.sh
PROJECT_NAME="${COMPOSE_PROJECT_NAME:-churchcrm-prod-5210}"
# Runs without `-p` usually use the directory name as project name, e.g. "crm"
LEGACY_PROJECT_NAME="$(basename "${DOCKER_DIR}")"
# Very old runs from sources/CRM/docker used "docker"
OLDER_LEGACY_PROJECT_NAME="docker"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "compose file not found: ${COMPOSE_FILE}" >&2
  exit 1
fi

cd "${DOCKER_DIR}"

if [[ -f "${ENV_FILE}" ]]; then
  ENV_ARGS=(--env-file "${ENV_FILE}")
else
  ENV_ARGS=()
fi

for name in "${PROJECT_NAME}" "${LEGACY_PROJECT_NAME}" "${OLDER_LEGACY_PROJECT_NAME}"; do
  echo "==> Stop and remove ${name} containers/networks/volumes"
  docker compose -p "${name}" "${ENV_ARGS[@]}" -f "${COMPOSE_FILE}" down -v --remove-orphans || true
done

echo "==> Ensure DB volumes are removed"
docker volume rm "${PROJECT_NAME}_churchcrm-db-data" >/dev/null 2>&1 || true
docker volume rm "${LEGACY_PROJECT_NAME}_churchcrm-db-data" >/dev/null 2>&1 || true
docker volume rm "${OLDER_LEGACY_PROJECT_NAME}_churchcrm-db-data" >/dev/null 2>&1 || true

echo "==> Done"
echo "All stack containers are stopped and DB data has been cleared."
