#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
docker info --format '{{.ServerVersion}}'
mkdir -p .local
if [ ! -s .local/admin-password.txt ]; then
    (umask 077; python3 -c 'import secrets; print(secrets.token_urlsafe(32))' > .local/admin-password.txt)
fi
docker compose --env-file images.env -f compose.yaml config --quiet
docker compose --env-file images.env -f compose.yaml up -d --build --wait --wait-timeout 240
echo 'Jenkins dedicado: http://localhost:18080 ; usuario bruno'
echo 'Clave local en ci/jenkins/.local/admin-password.txt; no compartir ni publicar.'
