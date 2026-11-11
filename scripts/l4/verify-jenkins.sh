#!/usr/bin/env bash
# Read-only check. Never pull lts, recreate Jenkins or inspect credentials.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
PYTHON=${L4_PYTHON:-python3}
expected=$("$PYTHON" -c 'import json,sys; print(json.load(open(sys.argv[1]))["imageId"])' "$ROOT/ci/jenkins-image.lock.json")
actual=$(docker inspect --format '{{.Image}}' jenkins)
if [[ "$actual" != "$expected" ]]; then
  echo "ERROR: imagen Jenkins distinta del lock; revisar identidad antes de iniciar. Esperada=$expected actual=$actual" >&2
  exit 1
fi
printf 'PASS Jenkins imageId=%s\n' "$actual"
