#!/bin/sh
set -e

cd /var/www/ieducar

if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

mkdir -p \
  /run/nginx \
  bootstrap/cache \
  storage/app/public \
  storage/framework/cache \
  storage/framework/sessions \
  storage/framework/views \
  storage/logs

chown -R www-data:www-data bootstrap/cache storage
chmod -R ug+rwx bootstrap/cache storage

exec "$@"
