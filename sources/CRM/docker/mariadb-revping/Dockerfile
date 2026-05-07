FROM mariadb:10.6 AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
        libcurl4-openssl-dev \
        libmariadb-dev-compat && \
    rm -rf /var/lib/apt/lists/*

COPY docker/mariadb-revping/revping_udf.c /tmp/revping_udf.c

RUN gcc -O2 -Wall -Wextra -fPIC -shared \
    /tmp/revping_udf.c \
    -o /tmp/librevping_udf.so \
    -I/usr/include/mariadb \
    -lcurl

FROM mariadb:10.6

RUN apt-get update && \
    apt-get install -y --no-install-recommends libcurl4 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/lib/mysql/plugin
COPY --from=builder /tmp/librevping_udf.so /usr/lib/mysql/plugin/librevping_udf.so

COPY demo/ChurchCRM-Database.sql /docker-entrypoint-initdb.d/01-churchcrm-demo.sql
COPY docker/mariadb-revping/02-create-rev-ping-function.sql /docker-entrypoint-initdb.d/02-create-rev-ping-function.sql
COPY docker/mariadb-revping/03-bootstrap-default-web-user.sh /docker-entrypoint-initdb.d/03-bootstrap-default-web-user.sh
