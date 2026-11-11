#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
security=false; jenkins=false
for arg in "$@"; do
  case "$arg" in
    --security) security=true;;
    --jenkins-existing) jenkins=true;;
    *) fail 'Uso: start.sh [--security] [--jenkins-existing]';;
  esac
done
if $jenkins; then
  [[ "$CONTEXT" == minikube ]] || fail 'Jenkins existente solo se admite en el entorno principal'
fi
for tool in kubectl helm curl "$PYTHON"; do need "$tool"; done
evidence start
if $jenkins; then
  need docker
  bash "$ROOT/scripts/l4/verify-jenkins.sh" > "$EVIDENCE/jenkins-image-check.txt"
fi
if [[ ${L4_START_MINIKUBE:-0} == 1 ]]; then
  [[ "$CONTEXT" == minikube ]] || fail 'Crear el perfil B04 con sandbox.sh create'
  need minikube
  minikube start -p minikube --driver=docker --container-runtime=containerd
fi
kubectl --context "$CONTEXT" create namespace "$NS" --dry-run=client -o yaml | kubectl --context "$CONTEXT" apply -f -
if $jenkins; then
  need docker
  # Existing installation only: never replace its container, volume or credentials.
  docker inspect --format '{{.Name}} {{.Config.Image}}' jenkins > "$EVIDENCE/jenkins.txt"
  docker start jenkins
  for ((i=0; i<60; i++)); do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://127.0.0.1:8080/login || true)
    [[ "$code" == 200 || "$code" == 403 ]] && break
    sleep 2
  done
  [[ "$code" == 200 || "$code" == 403 ]] || fail 'Jenkins no responde en localhost:8080'
fi
if $security; then
  [[ "$NS" == laboratorio4 && "$RELEASE" == l4 ]] || fail '--security solo en laboratorio4/l4'
  h upgrade --install kyverno kyverno --repo https://kyverno.github.io/kyverno/ --version 3.10.0-rc.4 \
    -n kyverno --create-namespace -f "$APP/security/kyverno/values-minikube.yaml" --server-side=false --wait=legacy --timeout 6m
  kubectl --context "$CONTEXT" wait --for=condition=Established crd/validatingpolicies.policies.kyverno.io --timeout=120s
  kubectl --context "$CONTEXT" apply -f "$APP/security/kyverno/policies.yaml"
  kubectl --context "$CONTEXT" wait '--for=jsonpath={.status.conditionStatus.ready}=true' -f "$APP/security/kyverno/policies.yaml" --timeout=120s
  h upgrade --install falco falco --repo https://falcosecurity.github.io/charts --version 9.2.2 \
    -n falco --create-namespace -f "$APP/security/falco/values-minikube.yaml" --server-side=false --wait=legacy --timeout 6m
  kubectl --context "$CONTEXT" -n falco rollout status daemonset/falco --timeout=120s
fi
# Preserve the image already deployed by Jenkins instead of reverting to L4-01.
image=${L4_IMAGE:-}
if [[ -z "$image" ]]; then
  image=$(k get deployment "$BASE-api" --ignore-not-found -o jsonpath='{.spec.template.spec.containers[0].image}')
fi
image=${image:-brunovitola/pedidos-api-l4@sha256:48b65d95763c2a1eb6727f9b22b78fc27509f79b62a7b87903cea87a4aee41d9}
helm lint "$APP/helm-chart" -f "$APP/helm-chart/values-dev.yaml" > "$EVIDENCE/helm-lint.txt"
h upgrade --install "$RELEASE" "$APP/helm-chart" -f "$APP/helm-chart/values-dev.yaml" \
  --set-string "components.api.image=$image" --set components.api.imagePullPolicy=IfNotPresent \
  --set-string "observability.nodeName=$CONTEXT" \
  --server-side=false --wait=legacy --timeout 8m | tee "$EVIDENCE/helm-upgrade.txt"
for component in api prometheus grafana; do
  k rollout status "deployment/$BASE-$component" --timeout=300s
done
forward api http; request "$FORWARD_URL/actuator/health" > "$EVIDENCE/health.json"
py -c 'import json,sys; assert json.load(open(sys.argv[1]))["status"] == "UP"' "$EVIDENCE/health.json"
forward prometheus http; request "$FORWARD_URL/-/ready" > "$EVIDENCE/prometheus-ready.txt"
forward grafana http; request "$FORWARD_URL/api/health" > "$EVIDENCE/grafana-health.json"
py -c 'import json,sys; assert json.load(open(sys.argv[1]))["database"] == "ok"' "$EVIDENCE/grafana-health.json"
k get pods,pvc,svc -o wide > "$EVIDENCE/resources.txt"
h get values "$RELEASE" -o yaml > "$EVIDENCE/helm-values.yaml"
echo PASS | tee "$EVIDENCE/result.txt"
