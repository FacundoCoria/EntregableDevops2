#!/usr/bin/env bash
# A disposable Kubernetes environment. Never operates the main profile or Jenkins.
export L4_CONTEXT=minikube-l4-b04
export L4_NAMESPACE=laboratorio4
export L4_RELEASE=l4
source "$(dirname -- "$0")/common.sh"
need minikube; need docker; need kubectl; need "$PYTHON"
action=${1:-plan}
[[ $# -le 1 ]] || fail 'Uso: sandbox.sh [plan|create|delete]'
[[ "$action" == plan || "$action" == create || "$action" == delete ]] || fail 'Acción inválida'
evidence "sandbox-$action"
marker="$ROOT/reports/l4-11b/b04-profile-owner.json"
echo 'Perfil exclusivo: minikube-l4-b04. Docker/CLI preinstalados; Jenkins principal excluido.' | tee "$EVIDENCE/plan.txt"
if [[ "$action" == plan ]]; then echo PLAN_ONLY | tee "$EVIDENCE/result.txt"; exit 0; fi
[[ ${L4_CONFIRM:-} == minikube-l4-b04/laboratorio4/l4 ]] || fail 'Requiere L4_CONFIRM=minikube-l4-b04/laboratorio4/l4'
minikube profile list -o json > "$EVIDENCE/profiles-before.json"
if [[ "$action" == create ]]; then
  [[ ! -e "$marker" ]] || fail 'Existe registro de propiedad; revisar antes de crear'
  py -c 'import json,sys; d=json.load(open(sys.argv[1])); assert not any(x.get("Name")=="minikube-l4-b04" for k in ("valid","invalid") for x in d.get(k,[])), "Perfil ya existente"' "$EVIDENCE/profiles-before.json"
  # Record intent first: failed creation can be retried/removed only after review.
  py -c 'import json,sys; json.dump({"profile":"minikube-l4-b04","state":"creating"},open(sys.argv[1],"x"))' "$marker"
  minikube start -p minikube-l4-b04 --driver=docker --container-runtime=containerd --kubernetes-version=v1.37.0 --memory=2800 --cpus=2 --keep-context | tee "$EVIDENCE/profile-start.txt"
  docker inspect --format '{{.Id}}' minikube-l4-b04 > "$EVIDENCE/container-id.txt"
  py -c 'import json,sys; cid=open(sys.argv[2]).read().strip(); assert len(cid)==64; json.dump({"profile":"minikube-l4-b04","state":"created","containerId":cid},open(sys.argv[1],"w"))' "$marker" "$EVIDENCE/container-id.txt"
  # Keep inner startup evidence with this profile's creation evidence.
  L4_EVIDENCE_DIR="$EVIDENCE/start" bash "$ROOT/scripts/l4/start.sh" --security
else
  [[ -f "$marker" ]] || fail 'Sin registro de propiedad: no se elimina el perfil'
  docker inspect --format '{{.Id}}' minikube-l4-b04 > "$EVIDENCE/container-id.txt"
  py -c 'import json,sys; d=json.load(open(sys.argv[1])); assert d["profile"]=="minikube-l4-b04" and d["state"]=="created" and d["containerId"]==open(sys.argv[2]).read().strip(), "Identidad del perfil distinta"' "$marker" "$EVIDENCE/container-id.txt"
  # Entire dedicated profile: includes retained PVC/PV, CRDs and namespaces.
  # Never delete files/directories or shared security installations.
  previous_context=$(kubectl config current-context 2>/dev/null || true)
  minikube delete -p minikube-l4-b04 | tee "$EVIDENCE/profile-delete.txt"
  # Minikube delete may clear current-context even when another profile was active.
  if [[ -n "$previous_context" && "$previous_context" != minikube-l4-b04 ]]; then
    kubectl config use-context "$previous_context" > "$EVIDENCE/context-restored.txt"
  fi
  minikube profile list -o json > "$EVIDENCE/profiles-after.json"
  py -c 'import json,sys; d=json.load(open(sys.argv[1])); assert not any(x.get("Name")=="minikube-l4-b04" for k in ("valid","invalid") for x in d.get(k,[]))' "$EVIDENCE/profiles-after.json"
  # Preserve ownership history alongside the deletion evidence.
  cp "$marker" "$EVIDENCE/owner-deleted.json"
  rm -- "$marker"
fi
echo PASS | tee "$EVIDENCE/result.txt"
