FROM php:8.2-apache

ARG APT_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian"
ARG DEBIAN_SECURITY_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian-security"

RUN set -eux; \
    if [ -f /etc/apt/sources.list ]; then \
      sed -ri "s@https?://deb.debian.org/debian@${APT_MIRROR}@g; s@https?://security.debian.org/debian-security@${DEBIAN_SECURITY_MIRROR}@g" /etc/apt/sources.list; \
    fi; \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
      sed -ri "s@https?://deb.debian.org/debian@${APT_MIRROR}@g; s@https?://security.debian.org/debian-security@${DEBIAN_SECURITY_MIRROR}@g" /etc/apt/sources.list.d/debian.sources; \
    fi

RUN apt-get update \
    && apt-get install -y --no-install-recommends libonig-dev \
    && docker-php-ext-install mysqli mbstring \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY . /var/www/html

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 0777 /var/www/html/templates_c