# Run from the clean checkout of the published candidate. Does not start a job.
param([string]$Helm = 'helm')
$ErrorActionPreference = 'Stop'
function Check { if ($LASTEXITCODE -ne 0) { throw 'C07 command failed; preserve logs and inspect before retrying' } }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$app = Join-Path $repo 'pedidos-api/pedidos-api'
$local = Join-Path $PSScriptRoot '.local'
$out = Join-Path $repo 'reports/l4-c07/setup'
if (Test-Path $out) { throw 'Setup evidence exists; do not overwrite' }
New-Item -ItemType Directory -Path $out -Force | Out-Null
docker ps -a --no-trunc --format '{{.ID}}|{{.Names}}|{{.Image}}|{{.State}}' | Set-Content "$out/docker-before.txt"; Check
$profiles = minikube profile list -o json | ConvertFrom-Json; Check
if (@($profiles.valid + $profiles.invalid | Where-Object Name -eq 'minikube-l4-c07').Count) { throw 'C07 profile already exists' }
$existing = docker ps -aq --filter label=com.docker.compose.project=l4-c07; Check
if ($existing) { throw 'C07 Compose project already exists' }
New-Item -ItemType Directory -Path $local -Force | Out-Null
if (Test-Path "$local/c07-owner.json") { throw 'C07 ownership record exists' }
@{profile='minikube-l4-c07';project='l4-c07';state='creating'} | ConvertTo-Json | Set-Content "$local/c07-owner.json"
minikube start -p minikube-l4-c07 --driver=docker --container-runtime=containerd --kubernetes-version=v1.37.0 --memory=4096 --cpus=2 --keep-context *> "$out/minikube-start.log"; Check
$cid = docker inspect minikube-l4-c07 --format '{{.Id}}'; Check
@{profile='minikube-l4-c07';project='l4-c07';containerId=$cid;state='created'} | ConvertTo-Json | Set-Content "$local/c07-owner.json"
kubectl --context minikube-l4-c07 create namespace laboratorio4; Check
& $Helm --kube-context minikube-l4-c07 upgrade --install kyverno kyverno --repo https://kyverno.github.io/kyverno/ --version 3.10.0-rc.4 -n kyverno --create-namespace -f "$app/security/kyverno/values-minikube.yaml" --server-side=false --wait=legacy --timeout 6m *> "$out/kyverno-install.log"; Check
kubectl --context minikube-l4-c07 wait --for=condition=Established crd/validatingpolicies.policies.kyverno.io --timeout=120s; Check
kubectl --context minikube-l4-c07 apply -f "$app/security/kyverno/policies.yaml" *> "$out/policies-apply.log"; Check
kubectl --context minikube-l4-c07 wait '--for=jsonpath={.status.conditionStatus.ready}=true' -f "$app/security/kyverno/policies.yaml" --timeout=120s; Check
& $Helm --kube-context minikube-l4-c07 upgrade --install falco falco --repo https://falcosecurity.github.io/charts --version 9.2.2 -n falco --create-namespace -f "$app/security/falco/values-minikube.yaml" --server-side=false --wait=legacy --timeout 6m *> "$out/falco-install.log"; Check
# Jenkins can read these named cluster-scoped objects but cannot create them.
& $Helm template l4 "$app/helm-chart" -n laboratorio4 --set-string observability.nodeName=minikube-l4-c07 --show-only templates/monitoring-rbac.yaml | Set-Content "$out/monitoring-rbac.yaml"; Check
kubectl --context minikube-l4-c07 -n laboratorio4 apply -f "$out/monitoring-rbac.yaml"; Check
kubectl --context minikube-l4-c07 -n laboratorio4 annotate -f "$out/monitoring-rbac.yaml" meta.helm.sh/release-name=l4 meta.helm.sh/release-namespace=laboratorio4 --overwrite; Check
kubectl --context minikube-l4-c07 -n laboratorio4 label -f "$out/monitoring-rbac.yaml" app.kubernetes.io/managed-by=Helm --overwrite; Check
if (-not (Test-Path "$local/admin-password.txt")) {
    [IO.File]::WriteAllText("$local/admin-password.txt", [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)))
}
$env:JENKINS_HTTP_PORT='18083'
Push-Location $PSScriptRoot
try {
    docker compose --env-file images.env -f compose.yaml -f compose.c07.yaml -p l4-c07 up -d --build --wait --wait-timeout 300 *> "$out/jenkins-start.log"; Check
} finally { Pop-Location }
& "$PSScriptRoot/connect-kubernetes.ps1" -ProjectName l4-c07 -Context minikube-l4-c07 -DockerNetwork minikube-l4-c07 -ApiServer https://minikube-l4-c07:8443
kubectl --context minikube-l4-c07 get pods -A -o wide | Set-Content "$out/pods.txt"; Check
'C07_SETUP_READY; Jenkins http://localhost:18083; job still disabled' | Set-Content "$out/result.txt"
Write-Output 'C07_SETUP_READY; account bruno; password is local, never print it'
