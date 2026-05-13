FROM mariadb:10.11

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
