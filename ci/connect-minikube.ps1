# Ejecutar desde raiz del repositorio con Docker Desktop y contexto minikube.
# Token de 24h solo para laboratorio4; nunca guarda credenciales en el repo.
$ErrorActionPreference = 'Stop'
kubectl --context minikube apply -f "$PSScriptRoot/jenkins-rbac.yaml"
if ($LASTEXITCODE -ne 0) { throw 'RBAC no aplicado' }
$networks = docker inspect jenkins --format '{{json .NetworkSettings.Networks}}' | ConvertFrom-Json
if (-not $networks.PSObject.Properties['minikube']) {
    docker network connect minikube jenkins
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo conectar la red' }
}
$clusterInfo = kubectl --context minikube config view --minify --flatten --raw -o json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer CA del contexto minikube' }
$caData = $clusterInfo.clusters[0].cluster.'certificate-authority-data'
$serviceToken = kubectl --context minikube -n laboratorio4 create token jenkins-l4 --duration=24h
if ($LASTEXITCODE -ne 0) { throw 'No se pudo emitir token' }
$connection = @{
    apiVersion = 'v1'; kind = 'Config'; 'current-context' = 'l4'
    clusters = @(@{name='minikube';cluster=@{server='https://minikube:8443';'certificate-authority-data'=$caData}})
    contexts = @(@{name='l4';context=@{cluster='minikube';user='jenkins-l4';namespace='laboratorio4'}})
    users = @(@{name='jenkins-l4';user=@{token=$serviceToken}})
} | ConvertTo-Json -Depth 10 -Compress
$connection | docker exec -i jenkins sh -c 'umask 077; mkdir -p /var/jenkins_home/l4-kube; cat > /var/jenkins_home/l4-kube/config; chmod 600 /var/jenkins_home/l4-kube/config'
if ($LASTEXITCODE -ne 0) { throw 'No se pudo instalar conexion' }
$serviceToken = $null
$connection = $null
$clusterInfo = $null
docker exec jenkins sh -c 'export KUBECONFIG=/var/jenkins_home/l4-kube/config; /var/jenkins_home/l4-tools/bin/kubectl -n laboratorio4 get deployments'
if ($LASTEXITCODE -ne 0) { throw 'Conexion con token no verificada' }
Write-Output 'JENKINS_L4_CONNECTION_READY (token 24h)'
