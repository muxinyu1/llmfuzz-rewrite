#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_DIR="${ROOT_DIR}/docker"
COMPOSE_FILE="${DOCKER_DIR}/docker-compose.prod-5.21.0.yaml"
ENV_FILE="${DOCKER_DIR}/.env.prod-5.21.0"

# Keep the same project name used by start-prod-5.21.0.sh
PROJECT_NAME="${COMPOSE_PROJECT_NAME:-churchcrm-prod-5210}"
# Older runs used the default project name derived from directory name "docker"
LEGACY_PROJECT_NAME="docker"

cd "${DOCKER_DIR}"

if [[ -f "${ENV_FILE}" ]]; then
  ENV_ARGS=(--env-file "${ENV_FILE}")
else
  ENV_ARGS=()
fi

echo "==> Stop and remove ${PROJECT_NAME} containers/networks/volumes"
docker compose -p "${PROJECT_NAME}" "${ENV_ARGS[@]}" -f "${COMPOSE_FILE}" down -v --remove-orphans || true

echo "==> Stop and remove ${LEGACY_PROJECT_NAME} containers/networks/volumes"
docker compose -p "${LEGACY_PROJECT_NAME}" "${ENV_ARGS[@]}" -f "${COMPOSE_FILE}" down -v --remove-orphans || true

echo "==> Ensure DB volumes are removed"
docker volume rm "${PROJECT_NAME}_churchcrm-db-data" >/dev/null 2>&1 || true
docker volume rm "${LEGACY_PROJECT_NAME}_churchcrm-db-data" >/dev/null 2>&1 || true

echo "==> Done"
echo "All stack containers are stopped and DB data has been cleared."
