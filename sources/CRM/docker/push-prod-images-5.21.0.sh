#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REGISTRY_IMAGE_PREFIX="${REGISTRY_IMAGE_PREFIX:-crpi-8tnv6lve87c20oxm.cn-beijing.personal.cr.aliyuncs.com/llmfuzz/llmfuzz-dockerhub}"
REGISTRY_HOST="${REGISTRY_IMAGE_PREFIX%%/*}"

APP_LOCAL_IMAGE="churchcrm-local:5.21.0-php8-apache"
APP_REMOTE_IMAGE="${REGISTRY_IMAGE_PREFIX}:churchcrm-5.21.0-php8-apache"

DB_LOCAL_IMAGE="churchcrm-db-local:10.6-revping"
DB_REMOTE_IMAGE="${REGISTRY_IMAGE_PREFIX}:mariadb-10.6-revping"
APT_MIRROR="${APT_MIRROR:-mirrors.tuna.tsinghua.edu.cn}"

echo "==> Docker login to ${REGISTRY_HOST}"
docker login "${REGISTRY_HOST}"

echo "==> Build and push database image"
docker build \
  -f "${ROOT_DIR}/docker/mariadb-revping/Dockerfile" \
  -t "${DB_LOCAL_IMAGE}" \
  "${ROOT_DIR}"
docker tag "${DB_LOCAL_IMAGE}" "${DB_REMOTE_IMAGE}"
docker push "${DB_REMOTE_IMAGE}"

echo "==> Build and push ChurchCRM 5.21.0 app image"
docker build \
  --build-arg "APT_MIRROR=${APT_MIRROR}" \
  -f "${ROOT_DIR}/docker/Dockerfile.churchcrm-apache-php8-prod-5.21.0" \
  -t "${APP_LOCAL_IMAGE}" \
  "${ROOT_DIR}"
docker tag "${APP_LOCAL_IMAGE}" "${APP_REMOTE_IMAGE}"
docker push "${APP_REMOTE_IMAGE}"

echo "==> Done"
echo "Pushed images:"
echo "  - ${DB_REMOTE_IMAGE}"
echo "  - ${APP_REMOTE_IMAGE}"
