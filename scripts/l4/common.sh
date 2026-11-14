#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
APP="$ROOT/pedidos-api/pedidos-api"
CONTEXT=${L4_CONTEXT:-minikube}
NS=${L4_NAMESPACE:-laboratorio4}
RELEASE=${L4_RELEASE:-l4}
BASE="$RELEASE-pedidos"
PYTHON=${L4_PYTHON:-python3}
py() { "$PYTHON" "$@"; }
fail() { echo "ERROR: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null || fail "Falta $1 en PATH"; }
scope() {
  [[ "$CONTEXT" == minikube || "$CONTEXT" == minikube-l4-b04 ]] || fail 'Solo se admite minikube o minikube-l4-b04'
  [[ "$NS" == laboratorio4 || "$NS" =~ ^laboratorio4-l4test[a-z0-9-]*$ ]] || fail 'Namespace fuera del laboratorio'
  [[ "$RELEASE" =~ ^l4(-[a-z0-9]+)*$ && ${#RELEASE} -le 25 ]] || fail 'Release inválido (l4 o l4-..., máximo 25 caracteres)'
}
k() { kubectl --context "$CONTEXT" -n "$NS" "$@"; }
h() { helm --kube-context "$CONTEXT" -n "$NS" "$@"; }
evidence() {
  local destination=${L4_EVIDENCE_DIR:-"$ROOT/reports/l4-10/$(date -u +%Y%m%dT%H%M%SZ)-$1-$$"}
  [[ ! -e "$destination" ]] || fail "No sobrescribir evidencia: $destination"
  mkdir -p -- "$destination"
  EVIDENCE=$(cd -- "$destination" && pwd)
  printf 'context=%s\nnamespace=%s\nrelease=%s\nutc=%s\n' "$CONTEXT" "$NS" "$RELEASE" "$(date -u +%FT%TZ)" > "$EVIDENCE/scope.txt"
  echo "Evidencia: $EVIDENCE"
}
forward_pids=()
close_forwards() {
  local pid
  for pid in "${forward_pids[@]}"; do kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true; done
}
finish() {
  local code=$?
  close_forwards
  if [[ "$code" -ne 0 && -n ${EVIDENCE:-} ]]; then
    printf 'FAIL exit=%s\n' "$code" > "$EVIDENCE/result.txt"
  fi
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
forward() {
  local component=$1 remote=$2 log="$EVIDENCE/forward-$1.log"
  # Spawn kubectl directly: backgrounding the k() function would track a
  # subshell, leaving its native kubectl child alive under Git Bash on Windows.
  kubectl --context "$CONTEXT" -n "$NS" port-forward --address 127.0.0.1 "svc/$BASE-$component" ":$remote" > "$log" 2>&1 &
  local pid=$!
  forward_pids+=("$pid")
  local attempt port
  for ((attempt=0; attempt<60; attempt++)); do
    kill -0 "$pid" 2>/dev/null || { cat "$log" >&2; fail "Port-forward $component terminó"; }
    port=$(sed -nE 's/.*127\.0\.0\.1:([0-9]+) ->.*/\1/p' "$log" | head -n 1)
    if [[ -n "$port" ]]; then FORWARD_URL="http://127.0.0.1:$port"; return; fi
    sleep 1
  done
  fail "Timeout port-forward $component"
}
request() { curl --fail --silent --show-error --connect-timeout 3 --max-time 15 "$@"; }
scope
