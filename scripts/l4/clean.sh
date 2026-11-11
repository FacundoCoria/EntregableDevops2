#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
apply=false; purge=false; security=false
for arg in "$@"; do
  case "$arg" in
    --apply) apply=true;;
    --purge-data) purge=true;;
    --security) security=true;;
    *) fail 'Uso: clean.sh [--apply] [--purge-data] [--security]';;
  esac
done
need kubectl; need helm
evidence clean
if $security; then [[ "$NS" == laboratorio4 && "$RELEASE" == l4 ]] || fail '--security solo en laboratorio4/l4'; fi
{
  echo "Contexto=$CONTEXT namespace=$NS release=$RELEASE"
  echo "Desinstalar release $RELEASE: API, Prometheus, Grafana, configuración y RBAC de métricas."
  echo "Eliminar PVC=$purge (solo $BASE-api, $BASE-prometheus, $BASE-grafana)."
  echo "Retirar políticas L4 y releases kyverno/falco=$security."
  echo 'Conservar namespaces, CRD compartidas, Jenkins/credenciales/volumen, Minikube, default y reportes.'
} | tee "$EVIDENCE/plan.txt"
if ! $apply; then echo 'PLAN_ONLY' | tee "$EVIDENCE/result.txt"; exit 0; fi
[[ ${L4_CONFIRM:-} == "$CONTEXT/$NS/$RELEASE" ]] || fail "Para ejecutar: L4_CONFIRM=$CONTEXT/$NS/$RELEASE y --apply"
# Validate all data ownership before uninstalling or deleting anything.
if $purge; then
  for component in api prometheus grafana; do
    pvc="$BASE-$component"
    object=$(k get pvc "$pvc" --ignore-not-found -o json)
    if [[ -n "$object" ]]; then
      printf '%s' "$object" | py -c 'import json,sys; d=json.load(sys.stdin); a=d["metadata"].get("annotations",{}); assert a.get("meta.helm.sh/release-name")==sys.argv[1] and a.get("meta.helm.sh/release-namespace")==sys.argv[2], "PVC ajeno o sin propietario Helm"' "$RELEASE" "$NS"
    fi
  done
fi
# Fail closed on API/Helm errors; an empty successful list alone means absent.
releases=$(h list -q --filter "^$RELEASE$")
if [[ "$releases" == "$RELEASE" ]]; then
  h uninstall "$RELEASE" --wait=legacy --timeout 5m | tee "$EVIDENCE/uninstall.txt"
fi
if $purge; then
  # Exact names and Helm ownership checks, never delete a whole namespace.
  for component in api prometheus grafana; do
    pvc="$BASE-$component"
    owner=$(k get pvc "$pvc" --ignore-not-found -o 'jsonpath={.metadata.annotations.meta\.helm\.sh/release-name}')
    if [[ -n "$owner" ]]; then
      [[ "$owner" == "$RELEASE" ]] || fail "PVC ajeno: $pvc"
      k delete pvc "$pvc" --wait=true --timeout=120s
    elif [[ -n $(k get pvc "$pvc" --ignore-not-found -o name) ]]; then
      fail "PVC sin propietario Helm: $pvc"
    fi
  done
fi
if $security; then
  kubectl --context "$CONTEXT" delete -f "$APP/security/kyverno/policies.yaml" --ignore-not-found
  for item in falco kyverno; do
    installed=$(helm --kube-context "$CONTEXT" -n "$item" list -q --filter "^$item$")
    if [[ "$installed" == "$item" ]]; then
      helm --kube-context "$CONTEXT" -n "$item" uninstall "$item" --wait=legacy --timeout 5m
    fi
  done
fi
remaining=$(k get deploy,svc,cm,sa -l "app.kubernetes.io/instance=$RELEASE" -o name)
[[ -z "$remaining" ]] || fail "Recursos restantes: $remaining"
k get pvc -o wide > "$EVIDENCE/pvc-after.txt"
echo PASS | tee "$EVIDENCE/result.txt"
