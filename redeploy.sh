#!/usr/bin/env bash
# Rebuild todoer_be from latest source and (re)start it. The db and its data
# are untouched. Use this after any backend code/config change — a plain
# restart would run the stale baked-in image.
set -euo pipefail
cd "$(dirname "$0")"

docker compose up -d --build todoer_be

# Wait for it to answer.
for _ in $(seq 1 30); do
  if curl -sf http://localhost:8080/healthz > /dev/null; then
    echo "todoer_be is up: http://localhost:8080"
    exit 0
  fi
  sleep 1
done
echo "todoer_be did not become healthy — check: docker compose logs todoer_be" >&2
exit 1
