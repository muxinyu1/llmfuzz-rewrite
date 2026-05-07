# 基于 Debian 版 postgres:17，plpython3u 包兼容性最好
FROM crpi-8tnv6lve87c20oxm.cn-beijing.personal.cr.aliyuncs.com/llmfuzz/llmfuzz-dockerhub:postgres-17

RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-plpython3-17 \
    && rm -rf /var/lib/apt/lists/*

COPY init-rev-ping.sql /docker-entrypoint-initdb.d/01-rev-ping.sql
