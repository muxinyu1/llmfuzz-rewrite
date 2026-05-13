#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SRC_DIR="${ROOT_DIR}/sources/phpMyFAQ"

REGISTRY_IMAGE_PREFIX="${REGISTRY_IMAGE_PREFIX:-crpi-8tnv6lve87c20oxm.cn-beijing.personal.cr.aliyuncs.com/llmfuzz/llmfuzz-dockerhub}"
PHPMYFAQ_IMAGE_TAG="${PHPMYFAQ_IMAGE_TAG:-phpmyfaq-4.0.13}"
MARIADB_IMAGE_TAG="${MARIADB_IMAGE_TAG:-mariadb-10.11-revping}"
APT_MIRROR="${APT_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian}"
DEBIAN_SECURITY_MIRROR="${DEBIAN_SECURITY_MIRROR:-https://mirrors.tuna.tsinghua.edu.cn/debian-security}"
DB_DOCKERFILE="${SRC_DIR}/install/docker/mariadb-revping/Dockerfile"

APP_IMAGE="${REGISTRY_IMAGE_PREFIX}:${PHPMYFAQ_IMAGE_TAG}"
DB_IMAGE="${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}"

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "Source directory not found: ${SRC_DIR}" >&2
  exit 1
fi

if [[ ! -f "${DB_DOCKERFILE}" ]]; then
  echo "DB Dockerfile not found: ${DB_DOCKERFILE}" >&2
  exit 1
fi

echo "==> Build phpMyFAQ image from source Dockerfile"
docker build \
  --build-arg "APT_MIRROR=${APT_MIRROR}" \
  --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
  -t "${APP_IMAGE}" "${SRC_DIR}"

echo "==> Build MariaDB revping image"
docker build \
  --build-arg "APT_MIRROR=${APT_MIRROR}" \
  --build-arg "DEBIAN_SECURITY_MIRROR=${DEBIAN_SECURITY_MIRROR}" \
  -f "${DB_DOCKERFILE}" -t "${DB_IMAGE}" "${SRC_DIR}"

echo "==> Push phpMyFAQ image to ACR"
docker push "${APP_IMAGE}"

echo "==> Push MariaDB revping image to ACR"
docker push "${DB_IMAGE}"

echo "==> Done"
echo "phpMyFAQ image: ${APP_IMAGE}"
echo "MariaDB image:  ${DB_IMAGE}"
