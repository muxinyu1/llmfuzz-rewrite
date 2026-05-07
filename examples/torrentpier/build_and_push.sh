#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SRC_DIR="${ROOT_DIR}/sources/torrentpier"

REGISTRY_IMAGE_PREFIX="${REGISTRY_IMAGE_PREFIX:-crpi-8tnv6lve87c20oxm.cn-beijing.personal.cr.aliyuncs.com/llmfuzz/llmfuzz-dockerhub}"
TORRENTPIER_IMAGE_TAG="${TORRENTPIER_IMAGE_TAG:-torrentpier-php84}"
MARIADB_IMAGE_TAG="${MARIADB_IMAGE_TAG:-mariadb-10.11-revping}"
DB_DOCKERFILE="${SRC_DIR}/install/docker/mariadb-revping/Dockerfile"

APP_IMAGE="${REGISTRY_IMAGE_PREFIX}:${TORRENTPIER_IMAGE_TAG}"
DB_IMAGE="${REGISTRY_IMAGE_PREFIX}:${MARIADB_IMAGE_TAG}"

if [[ ! -f "${DB_DOCKERFILE}" ]]; then
	echo "DB Dockerfile not found: ${DB_DOCKERFILE}" >&2
	exit 1
fi

echo "==> Build TorrentPier image from source Dockerfile"
docker build -t "${APP_IMAGE}" "${SRC_DIR}"

echo "==> Build MariaDB revping image"
docker build -f "${DB_DOCKERFILE}" -t "${DB_IMAGE}" "${SRC_DIR}"

echo "==> Push TorrentPier image to ACR"
docker push "${APP_IMAGE}"

echo "==> Push MariaDB revping image to ACR"
docker push "${DB_IMAGE}"

echo "==> Done"
echo "TorrentPier image: ${APP_IMAGE}"
echo "MariaDB image:    ${DB_IMAGE}"
