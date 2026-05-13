FROM mariadb:10.11

ARG APT_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian"
ARG DEBIAN_SECURITY_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian-security"

RUN set -eux; \
        if [ -f /etc/apt/sources.list ]; then \
            sed -ri "s@https?://deb.debian.org/debian@${APT_MIRROR}@g; s@https?://security.debian.org/debian-security@${DEBIAN_SECURITY_MIRROR}@g" /etc/apt/sources.list; \
        fi; \
        if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
            sed -ri "s@https?://deb.debian.org/debian@${APT_MIRROR}@g; s@https?://security.debian.org/debian-security@${DEBIAN_SECURITY_MIRROR}@g" /etc/apt/sources.list.d/debian.sources; \
        fi

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libc6-dev libmariadb-dev-compat libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

COPY install/docker/mariadb-revping/revping_udf.c /tmp/revping_udf.c

RUN mkdir -p /usr/lib/mysql/plugin \
    && gcc -Wall -Werror -fPIC -shared /tmp/revping_udf.c -I/usr/include/mariadb -lcurl -o /usr/lib/mysql/plugin/librevping_udf.so \
    && chown mysql:mysql /usr/lib/mysql/plugin/librevping_udf.so \
    && chmod 0644 /usr/lib/mysql/plugin/librevping_udf.so \
    && rm -f /tmp/revping_udf.c

USER mysql