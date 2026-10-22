#!/bin/bash
set -e
ROLE="$1"

# если передали произвольную команду — просто выполняем её (для сервиса инициализации)
if [ -n "$ROLE" ] && [ "$ROLE" != "static" ] && [ "$ROLE" != "dynamic" ]; then
  exec "$@"
fi

# у каждого узла свой каталог конфигурации (ydbd пишет туда маркеры идентификации)
mkdir -p /opt/ydb/cfg
[ -f /opt/ydb/cfg/config.yaml ] || cp /tmp/config.yaml /opt/ydb/cfg/config.yaml

if [ "$ROLE" = "static" ]; then
  mkdir -p /ydb_data
  for disk in pdisk1.dat pdisk2.dat pdisk3.dat; do
    [ -f "/ydb_data/$disk" ] || truncate -s 8G "/ydb_data/$disk"
  done

  exec /opt/ydb/bin/ydbd server --log-level 3 \
    --yaml-config /opt/ydb/cfg/config.yaml \
    --grpc-port 2135 --ic-port 19001 --mon-port 8765 \
    --node static
fi

if [ "$ROLE" = "dynamic" ]; then
  exec /opt/ydb/bin/ydbd server --log-level 3 \
    --yaml-config /opt/ydb/cfg/config.yaml \
    --grpc-port 2136 --ic-port 19002 --mon-port 8766 \
    --tenant /Root/testdb \
    --node-broker grpc://ydb-s1:2135 \
    --node-broker grpc://ydb-s2:2135 \
    --node-broker grpc://ydb-s3:2135
fi
