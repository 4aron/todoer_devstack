#!/usr/bin/env bash
# Reset the local stack: drop + recreate the database, apply all migrations,
# rebuild todoer_be from latest source, and run it.
set -euo pipefail
cd "$(dirname "$0")"

# Stop the backend so nothing holds connections to the db we're about to drop.
docker compose stop todoer_be

# Make sure the db is up and healthy, then drop + recreate the database.
docker compose up -d --wait db
docker compose exec db psql -U todoer -d postgres -v ON_ERROR_STOP=1 \
  -c 'DROP DATABASE IF EXISTS todoer WITH (FORCE);' \
  -c 'CREATE DATABASE todoer OWNER todoer;'

# Apply migrations from scratch.
docker compose run --rm migrate up

# Rebuild the backend image from latest source and start it.
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
