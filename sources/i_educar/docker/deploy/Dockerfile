ARG PHP_VERSION=8.4
ARG COMPOSER_VERSION=2.8

FROM composer:${COMPOSER_VERSION} AS composer-bin

FROM php:${PHP_VERSION}-fpm-alpine

COPY --from=composer-bin /usr/bin/composer /usr/local/bin/composer

LABEL maintainer="Portabilis <contato@portabilis.com.br>"

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_PROCESS_TIMEOUT=900 \
    COMPOSER_DISABLE_XDEBUG_WARN=1

RUN apk add --no-cache \
    bash \
    fcgi \
    git \
    libc-dev \
    libpng-dev \
    libzip-dev \
    linux-headers \
    nginx \
    openjdk17-jre-headless \
    openssh-client \
    postgresql17-client \
    postgresql-dev \
    redis \
    supervisor \
    ttf-dejavu \
    unzip \
    && apk add --no-cache --virtual .phpize_deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && docker-php-ext-install \
    bcmath \
    gd \
    pcntl \
    pdo \
    pdo_pgsql \
    pgsql \
    zip \
    ftp \
    && apk del .phpize_deps \
    && rm -rf /var/cache/apk/* /etc/nginx/http.d/default.conf

WORKDIR /var/www/ieducar

COPY . .
COPY docker/deploy/nginx/default.conf /etc/nginx/http.d/default.conf
COPY docker/deploy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/deploy/entrypoint.sh /usr/local/bin/ieducar-entrypoint

RUN chmod +x /usr/local/bin/ieducar-entrypoint \
    && mkdir -p \
    /run/nginx \
    bootstrap/cache \
    storage/app/public \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    && composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
    && composer plug-and-play \
    && (php artisan storage:link --ansi || true) \
    && chown -R www-data:www-data bootstrap/cache storage \
    && chmod -R ug+rwx bootstrap/cache storage

EXPOSE 80

ENTRYPOINT ["ieducar-entrypoint"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
