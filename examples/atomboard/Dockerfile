FROM php:7.4-apache

ARG APT_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian"
ARG DEBIAN_SECURITY_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian-security"

WORKDIR /var/www/html

RUN set -eux; \
    if [ -f /etc/apt/sources.list ]; then \
      sed -ri "s@https?://deb.debian.org/debian@${APT_MIRROR}@g; s@https?://security.debian.org/debian-security@${DEBIAN_SECURITY_MIRROR}@g" /etc/apt/sources.list; \
    fi; \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
      sed -ri "s@https?://deb.debian.org/debian@${APT_MIRROR}@g; s@https?://security.debian.org/debian-security@${DEBIAN_SECURITY_MIRROR}@g" /etc/apt/sources.list.d/debian.sources; \
    fi

RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    zlib1g-dev \
    libonig-dev \
    default-mysql-client \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli gd mbstring zip \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "upload_max_filesize = 30M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 35M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 128M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini

EXPOSE 80

CMD ["apache2-foreground"]
