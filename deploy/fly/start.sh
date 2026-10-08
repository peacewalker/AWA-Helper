#!/bin/sh
set -eu

cd /usr/src/app/output
mkdir -p /data/config /data/logs /data/data

if [ ! -s /data/config/config.yml ]; then
  if [ ! -s /tmp/bootstrap-config.yml ]; then
    echo "Missing initial config: set the Fly AWA_CONFIG secret before deploying." >&2
    exit 1
  fi
  cp /tmp/bootstrap-config.yml /data/config/config.yml
fi

for dir in config logs data; do
  if [ "$(readlink "/usr/src/app/output/$dir" 2>/dev/null || true)" != "/data/$dir" ]; then
    rm -rf "/usr/src/app/output/$dir"
    ln -s "/data/$dir" "/usr/src/app/output/$dir"
  fi
done

chown -R node:node /data
chmod 600 /data/config/config.yml

exec su-exec node:node "$@"
