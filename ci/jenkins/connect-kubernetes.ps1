# Conexion opcional para C07. Solo usa el agente dedicado; nunca el Jenkins del curso.
param(
    [ValidatePattern('^l4-(c01(-[a-z0-9]+)*|c07)$')][string]$ProjectName = 'l4-c01',
    [string]$Context = 'minikube',
    [ValidatePattern('^[a-z0-9][a-z0-9-]*$')][string]$Namespace = 'laboratorio4',
    [ValidatePattern('^[a-z0-9][a-z0-9-]*$')][string]$Release = 'l4',
    [string]$DockerNetwork = 'minikube',
    [string]$ApiServer = 'https://minikube:8443'
)
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    $agentId = docker compose --env-file images.env -f compose.yaml -p $ProjectName ps -q agent
    if ($LASTEXITCODE -ne 0 -or -not $agentId) { throw 'Agente dedicado ausente' }
    $manifest = @{
        apiVersion='v1'; kind='List'; items=@(
            @{apiVersion='v1';kind='ServiceAccount';metadata=@{name='jenkins-c01';namespace=$Namespace};automountServiceAccountToken=$false},
            @{apiVersion='rbac.authorization.k8s.io/v1';kind='Role';metadata=@{name='jenkins-c01';namespace=$Namespace};rules=@(
                @{apiGroups=@('');resources=@('configmaps','secrets','services','persistentvolumeclaims','serviceaccounts');verbs=@('get','list','watch','create','update','patch')},
                @{apiGroups=@('');resources=@('pods','pods/log','events','endpoints');verbs=@('get','list','watch')},
                @{apiGroups=@('');resources=@('pods/portforward');verbs=@('create')},
                @{apiGroups=@('apps');resources=@('deployments');verbs=@('get','list','watch','create','update','patch')},
                @{apiGroups=@('apps');resources=@('replicasets');verbs=@('get','list','watch')}
            )},
            @{apiVersion='rbac.authorization.k8s.io/v1';kind='RoleBinding';metadata=@{name='jenkins-c01';namespace=$Namespace};subjects=@(@{kind='ServiceAccount';name='jenkins-c01';namespace=$Namespace});roleRef=@{apiGroup='rbac.authorization.k8s.io';kind='Role';name='jenkins-c01'}},
            @{apiVersion='rbac.authorization.k8s.io/v1';kind='ClusterRole';metadata=@{name="jenkins-c01-$Namespace-$Release"};rules=@(
                @{apiGroups=@('rbac.authorization.k8s.io');resources=@('clusterroles','clusterrolebindings');resourceNames=@("$Namespace-$Release-pedidos-node-metrics");verbs=@('get')}
            )},
            @{apiVersion='rbac.authorization.k8s.io/v1';kind='ClusterRoleBinding';metadata=@{name="jenkins-c01-$Namespace-$Release"};subjects=@(@{kind='ServiceAccount';name='jenkins-c01';namespace=$Namespace});roleRef=@{apiGroup='rbac.authorization.k8s.io';kind='ClusterRole';name="jenkins-c01-$Namespace-$Release"}}
        )
    } | ConvertTo-Json -Depth 20 -Compress
    $manifest | kubectl --context $Context apply -f -
    if ($LASTEXITCODE -ne 0) { throw 'RBAC dedicado no aplicado' }
    $networks = docker inspect $agentId --format '{{json .NetworkSettings.Networks}}' | ConvertFrom-Json
    if (-not $networks.PSObject.Properties[$DockerNetwork]) {
        docker network connect $DockerNetwork $agentId
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo conectar la red Kubernetes al agente' }
    }
    $clusterInfo = kubectl --context $Context config view --minify --flatten --raw -o json | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer CA del contexto elegido' }
    $token = kubectl --context $Context -n $Namespace create token jenkins-c01 --duration=24h
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo emitir token' }
    $config = @{
        apiVersion='v1';kind='Config';'current-context'='c01'
        clusters=@(@{name='l4';cluster=@{server=$ApiServer;'certificate-authority-data'=$clusterInfo.clusters[0].cluster.'certificate-authority-data'}})
        contexts=@(@{name='c01';context=@{cluster='l4';user='jenkins-c01';namespace=$Namespace}})
        users=@(@{name='jenkins-c01';user=@{token=$token}})
    } | ConvertTo-Json -Depth 10 -Compress
    $config | docker exec -i $agentId sh -c 'umask 077; mkdir -p /var/jenkins_home/l4-kube; cat > /var/jenkins_home/l4-kube/config'
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo guardar conexion en agente' }
    $token=$null; $config=$null; $clusterInfo=$null
    docker exec $agentId sh -c 'set -eu; export KUBECONFIG=/var/jenkins_home/l4-kube/config; kubectl get deployments; test "$(kubectl auth can-i create clusterroles)" = no; test "$(kubectl auth can-i get secrets -n kube-system)" = no'
    if ($LASTEXITCODE -ne 0) { throw 'Conexion o limites RBAC no verificados' }
    Write-Output 'C01_KUBERNETES_CONNECTED: token 24h; renovar antes de C07'
} finally { Pop-Location }
