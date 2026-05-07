#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="$(cd "$(dirname "$0")" && pwd)/compose.yaml"

# ---------- 参数解析 ----------
VERIFIER_PORT="${VERIFIER_PORT:-8000}"
VERIFIER_HOST="${VERIFIER_HOST:-host.docker.internal}"

usage() {
  echo "用法: $0 [--verifier-port PORT] [--verifier-host HOST] [--reset]"
  echo ""
  echo "  --verifier-port PORT   verifier 回调端口（默认 8000）"
  echo "  --verifier-host HOST   verifier 回调地址（默认 host.docker.internal）"
  echo "  --reset                先销毁已有容器和 volume，全新初始化"
  exit 1
}

RESET=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --verifier-port) VERIFIER_PORT="$2"; shift 2 ;;
    --verifier-host) VERIFIER_HOST="$2"; shift 2 ;;
    --reset)         RESET=1; shift ;;
    -h|--help)       usage ;;
    *) echo "未知参数: $1"; usage ;;
  esac
done

export VERIFIER_PORT VERIFIER_HOST

DC="docker compose -f $COMPOSE_FILE"

# ---------- 可选重置 ----------
if [[ $RESET -eq 1 ]]; then
  echo "[reset] 停止并删除容器和 volume ..."
  $DC down -v --remove-orphans 2>/dev/null || true
fi

# ---------- 判断是否首次启动（检查 migrations 表是否存在，比 volume 更可靠）----------
FIRST_RUN=0
if ! $DC exec -T postgres psql -U ieducar -d ieducar -tAc \
    "SELECT 1 FROM information_schema.tables WHERE table_name='migrations'" 2>/dev/null | grep -q 1; then
  FIRST_RUN=1
fi

# ---------- 启动核心服务 ----------
echo "[start] 拉取镜像并启动服务 ..."
$DC up -d --pull missing

# ---------- 等待 postgres 健康 ----------
echo "[wait] 等待 postgres 就绪 ..."
TIMEOUT=120
ELAPSED=0
until $DC exec -T postgres pg_isready -U ieducar -d ieducar &>/dev/null; do
  if [[ $ELAPSED -ge $TIMEOUT ]]; then
    echo "[error] postgres 启动超时（${TIMEOUT}s），请检查日志：docker compose -f $COMPOSE_FILE logs postgres"
    exit 1
  fi
  sleep 3
  ELAPSED=$((ELAPSED + 3))
done
echo "[wait] postgres 已就绪"

# ---------- 首次初始化 ----------
if [[ $FIRST_RUN -eq 1 ]]; then
  echo "[init] 首次启动，执行数据库迁移与数据填充 ..."
  $DC --profile setup run --rm init
  echo "[init] 初始化完成"
else
  echo "[init] 检测到已有数据，跳过初始化（使用 --reset 可强制重新初始化）"
fi

# ---------- 完成 ----------
APP_PORT=8080
echo ""
echo "========================================="
echo " i-educar 已启动"
echo " 应用地址:  http://localhost:${APP_PORT}"
echo " VERIFIER:  ${VERIFIER_HOST}:${VERIFIER_PORT}"
echo "========================================="
