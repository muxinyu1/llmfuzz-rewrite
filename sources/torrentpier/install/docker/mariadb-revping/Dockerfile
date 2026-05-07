FROM mariadb:10.11 AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
        libcurl4-openssl-dev \
        libmariadb-dev-compat && \
    rm -rf /var/lib/apt/lists/*

COPY install/docker/mariadb-revping/revping_udf.c /tmp/revping_udf.c

RUN gcc -O2 -Wall -Wextra -fPIC -shared \
    /tmp/revping_udf.c \
    -o /tmp/librevping_udf.so \
    -I/usr/include/mariadb \
    -lcurl

FROM mariadb:10.11

RUN apt-get update && \
    apt-get install -y --no-install-recommends libcurl4 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/lib/mysql/plugin
COPY --from=builder /tmp/librevping_udf.so /usr/lib/mysql/plugin/librevping_udf.so
