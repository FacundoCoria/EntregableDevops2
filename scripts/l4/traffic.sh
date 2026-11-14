#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
[[ $# -eq 0 ]] || fail 'Uso: traffic.sh (L4_ITERATIONS=60 L4_INTERVAL=1)'
iterations=${L4_ITERATIONS:-60}; interval=${L4_INTERVAL:-1}
[[ "$iterations" =~ ^[1-9][0-9]*$ && "$iterations" -le 300 ]] || fail 'L4_ITERATIONS: 1..300'
[[ "$interval" =~ ^[1-5]$ ]] || fail 'L4_INTERVAL: 1..5 segundos'
for tool in kubectl curl "$PYTHON"; do need "$tool"; done
evidence traffic
forward api http; url=$FORWARD_URL
request "$url/actuator/health" > "$EVIDENCE/health.json"
py -c 'import json,sys; assert json.load(open(sys.argv[1]))["status"] == "UP"' "$EVIDENCE/health.json"
# Reuse one named product; label cardinality does not grow with each run.
request "$url/api/productos" > "$EVIDENCE/products-before.json"
product=$(py -c 'import json,sys; a=[p["id"] for p in json.load(open(sys.argv[1])) if p["nombre"]=="l4-10-trafico"]; print(a[0] if a else "")' "$EVIDENCE/products-before.json")
if [[ -z "$product" ]]; then
  request "$url/api/productos" -H 'Content-Type: application/json' -d '{"nombre":"l4-10-trafico","precio":42.5}' > "$EVIDENCE/product-created.json"
  product=$(py -c 'import json,sys; print(json.load(open(sys.argv[1]))["id"])' "$EVIDENCE/product-created.json")
fi
[[ "$product" =~ ^[0-9]+$ ]] || fail 'ID de producto inválido'
request "$url/actuator/prometheus" > "$EVIDENCE/metrics-before.txt"
for ((i=1; i<=iterations; i++)); do
  request "$url/api/productos" > /dev/null
  request "$url/api/pedidos" > /dev/null
  request "$url/api/pedidos" -H 'Content-Type: application/json' \
    -d "{\"cliente\":\"Prueba L4-10\",\"producto\":{\"id\":$product},\"estado\":\"Pendiente\",\"minutosEspera\":12}" > "$EVIDENCE/order-$i.json"
  py -c 'import json,sys; assert json.load(open(sys.argv[1]))["id"]' "$EVIDENCE/order-$i.json"
  sleep "$interval"
done
request "$url/actuator/prometheus" > "$EVIDENCE/metrics-after.txt"
py - "$EVIDENCE" "$iterations" <<'PY'
import json,re,sys
from pathlib import Path
p=Path(sys.argv[1]); expected=int(sys.argv[2])
def counter(name):
    return sum(float(line.rsplit(" ",1)[1]) for line in (p/name).read_text().splitlines()
               if line.startswith("pedidos_creados_total{") and 'producto="l4-10-trafico"' in line)
before=counter("metrics-before.txt"); after=counter("metrics-after.txt")
assert after-before == expected, (before,after,expected)
ids=[json.loads((p/f"order-{i}.json").read_text())["id"] for i in range(1,expected+1)]
assert len(set(ids)) == expected
(p/"summary.json").write_text(json.dumps(dict(result="PASS",orders=expected,reads=2*expected,before=before,after=after,ids=ids),indent=2))
PY
echo PASS | tee "$EVIDENCE/result.txt"
