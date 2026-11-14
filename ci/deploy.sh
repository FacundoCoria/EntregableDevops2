#!/bin/sh
set -eu
: "${EVIDENCE:?}" "${APP:?}" "${IMAGE_TAG:?}"
namespace=laboratorio4
release=l4
chart="$APP/helm-chart"
helm lint "$chart" -f "$chart/values-dev.yaml" \
  --set-string "components.api.image=$IMAGE_TAG" --set components.api.imagePullPolicy=IfNotPresent
helm template "$release" "$chart" -n "$namespace" -f "$chart/values-dev.yaml" \
  --set-string "components.api.image=$IMAGE_TAG" --set components.api.imagePullPolicy=IfNotPresent \
  > "$EVIDENCE/helm-rendered.yaml"
helm upgrade --install "$release" "$chart" -n "$namespace" -f "$chart/values-dev.yaml" \
  --set-string "components.api.image=$IMAGE_TAG" --set components.api.imagePullPolicy=IfNotPresent \
  --server-side=false --wait=legacy --timeout 8m
kubectl -n "$namespace" rollout status deployment/l4-pedidos-api --timeout=300s
kubectl -n "$namespace" get pods,pvc,services -l app.kubernetes.io/instance=l4 -o wide > "$EVIDENCE/kubernetes.txt"
helm status "$release" -n "$namespace" > "$EVIDENCE/helm-status.txt"
helm get values "$release" -n "$namespace" -o yaml > "$EVIDENCE/helm-values.yaml"
# Requests originate inside the Jenkins container, on the Minikube network.
kubectl -n "$namespace" port-forward service/l4-pedidos-api 18089:8080 > "$EVIDENCE/port-forward.log" 2>&1 &
forward_pid=$!
trap 'kill "$forward_pid" 2>/dev/null || true' EXIT
attempt=0
until curl -fsS http://127.0.0.1:18089/actuator/health > "$EVIDENCE/api-health.json"; do
  attempt=$((attempt + 1))
  [ "$attempt" -lt 30 ] || exit 1
  sleep 1
done
python3 -c 'import json,os; from pathlib import Path; assert json.loads((Path(os.environ["EVIDENCE"])/"api-health.json").read_text())["status"] == "UP"'
curl -fsS http://127.0.0.1:18089/actuator/prometheus > "$EVIDENCE/api-metrics.txt"
echo L4_DEPLOY_PASS
