FROM ubuntu:24.04
ARG YDB_VERSION=26.2.1.14

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash curl ca-certificates && rm -rf /var/lib/apt/lists/*

# ydbd + YDB CLI из одного официального архива
# (библиотек не требуется, LD_LIBRARY_PATH не нужен)
RUN mkdir -p /opt/ydb \
    && curl -fsSL \
      "https://binaries.ydb.tech/release/${YDB_VERSION}/ydbd-${YDB_VERSION}-linux-amd64.tar.gz" \
      | tar -xz --strip-components=1 -C /opt/ydb \
    && test -x /opt/ydb/bin/ydbd \
    && test -x /opt/ydb/bin/ydb \
    && ln -sf /opt/ydb/bin/ydbd /usr/local/bin/ydbd \
    && ln -sf /opt/ydb/bin/ydb /usr/local/bin/ydb \
    && /opt/ydb/bin/ydb version --semantic \
    && { /opt/ydb/bin/ydbd --help >/dev/null 2>&1 || test $? -eq 1; }

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
