param(
    [string]$EvidenceDir = './helm-evidence',
    [string]$Context = 'minikube',
    [string]$Namespace = 'laboratorio4',
    [string]$Release = 'l4'
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
$EvidenceDir = (Resolve-Path -LiteralPath $EvidenceDir).Path
$base = "$Release-pedidos"
$forwarders = @()
function Kube {
    param([string[]]$Arguments)
    $result = & kubectl --context $Context -n $Namespace @Arguments
    if ($LASTEXITCODE -ne 0) { throw "kubectl failed: $($Arguments -join ' ')" }
    return $result
}
function Forward {
    param([string]$Component, [int]$LocalPort, [string]$RemotePort)
    # Only this script's process is terminated. Bind exclusively to loopback.
    $p = Start-Process -FilePath (Get-Command kubectl).Source -WindowStyle Hidden -PassThru -ArgumentList @(
        '--context', $Context, '-n', $Namespace, 'port-forward', "svc/$base-$Component",
        "${LocalPort}:${RemotePort}", '--address', '127.0.0.1'
    ) -RedirectStandardOutput "$EvidenceDir/forward-$Component.txt" -RedirectStandardError "$EvidenceDir/forward-$Component-error.txt"
    $script:forwarders += $p
}
function Wait-Health {
    param([string]$Url)
    for ($i=0; $i -lt 60; $i++) {
        try { return Invoke-RestMethod $Url -TimeoutSec 3 } catch { Start-Sleep -Seconds 1 }
    }
    throw "Health unavailable: $Url"
}
try {
    Kube -Arguments @('get','pods,pvc,svc,deploy','-o','wide') | Set-Content -Encoding utf8 "$EvidenceDir/resources-before.txt"
    $before = (Kube -Arguments @('get','pods','-l',"app.kubernetes.io/instance=$Release,app.kubernetes.io/component=api",'-o','json') | ConvertFrom-Json).items[0]
    $pvcBefore = Kube -Arguments @('get','pvc',"$base-api",'-o','json') | ConvertFrom-Json
    Forward -Component api -LocalPort 18080 -RemotePort http
    Forward -Component grafana -LocalPort 13000 -RemotePort http
    Forward -Component prometheus -LocalPort 19090 -RemotePort http
    $health = Wait-Health 'http://127.0.0.1:18080/actuator/health'
    if ($health.status -ne 'UP') { throw 'API health is not UP' }
    $grafana = Wait-Health 'http://127.0.0.1:13000/api/health'
    if ($grafana.database -ne 'ok') { throw 'Grafana database is not healthy' }
    $prometheus = Wait-Health 'http://127.0.0.1:19090/-/ready'
    $liveness = Invoke-RestMethod 'http://127.0.0.1:18080/actuator/health/liveness'
    if ($liveness.status -ne 'UP') { throw 'Liveness is not UP' }
    $name = 'l4-03-' + [guid]::NewGuid().ToString('N').Substring(0,12)
    $payload = @{nombre=$name; precio=123.45} | ConvertTo-Json
    $created = Invoke-RestMethod 'http://127.0.0.1:18080/api/productos' -Method Post -ContentType application/json -Body $payload
    if (-not $created.id) { throw 'Missing product ID' }
    $metrics = Invoke-WebRequest 'http://127.0.0.1:18080/actuator/prometheus' -UseBasicParsing
    if ($metrics.Content -notmatch 'jvm_memory_used_bytes') { throw 'Missing metrics' }
    $user = Kube -Arguments @('exec', $before.metadata.name, '--','id')
    if ($user -notmatch 'uid=10001' -or $user -notmatch 'gid=10001') { throw 'Unexpected API user' }
    $user | Set-Content -Encoding utf8 "$EvidenceDir/api-user.txt"
    # Recreate strategy stops the only H2 writer before a replacement starts.
    Kube -Arguments @('rollout','restart',"deployment/$base-api") | Set-Content -Encoding utf8 "$EvidenceDir/restart.txt"
    Kube -Arguments @('rollout','status',"deployment/$base-api",'--timeout=240s') | Add-Content -Encoding utf8 "$EvidenceDir/restart.txt"
    $after = (Kube -Arguments @('get','pods','-l',"app.kubernetes.io/instance=$Release,app.kubernetes.io/component=api",'-o','json') | ConvertFrom-Json).items[0]
    if ($before.metadata.uid -eq $after.metadata.uid) { throw 'Pod was not recreated' }
    # The original forwarding terminates when the old pod goes away.
    $oldApiForward = $forwarders[0]
    if (-not $oldApiForward.HasExited) { Stop-Process -Id $oldApiForward.Id; $oldApiForward.WaitForExit() }
    Forward -Component api -LocalPort 18080 -RemotePort http
    $null = Wait-Health 'http://127.0.0.1:18080/actuator/health'
    $recovered = Invoke-RestMethod "http://127.0.0.1:18080/api/productos/$($created.id)"
    if ($recovered.nombre -ne $name -or $recovered.precio -ne 123.45) { throw 'H2 data mismatch after pod recreation' }
    $pvcAfter = Kube -Arguments @('get','pvc',"$base-api",'-o','json') | ConvertFrom-Json
    if ($pvcBefore.metadata.uid -ne $pvcAfter.metadata.uid -or $pvcAfter.status.phase -ne 'Bound') { throw 'PVC changed or unbound' }
    $envVars = Kube -Arguments @('exec',$after.metadata.name,'--','printenv','API_TITLE','SPRING_PROFILES_ACTIVE','SPRING_DATASOURCE_URL','SPRING_H2_CONSOLE_ENABLED')
    $envVars | Set-Content -Encoding utf8 "$EvidenceDir/api-config.txt"
    if ($envVars[2] -ne 'jdbc:h2:file:/data/pedidos' -or $envVars[3] -ne 'false') { throw 'Unexpected H2 configuration' }
    Kube -Arguments @('exec',$after.metadata.name,'--','ls','-ln','/data') | Set-Content -Encoding utf8 "$EvidenceDir/h2-files.txt"
    Kube -Arguments @('get','pods,pvc,svc,deploy','-o','wide') | Set-Content -Encoding utf8 "$EvidenceDir/resources-after.txt"
    Kube -Arguments @('get','pods','-o','json') | Set-Content -Encoding utf8 "$EvidenceDir/pods.json"
    Kube -Arguments @('logs',"deployment/$base-api") | Set-Content -Encoding utf8 "$EvidenceDir/api-log.txt"
    @{
        date=(Get-Date).ToString('o'); context=$Context; namespace=$Namespace; release=$Release
        apiHealth=$health; liveness=$liveness; grafanaHealth=$grafana; prometheusReady=$prometheus
        created=$created; recoveredAfterPodRecreation=$recovered
        oldPodUid=$before.metadata.uid; newPodUid=$after.metadata.uid; pvcUid=$pvcAfter.metadata.uid
        image=$after.spec.containers[0].image; imageID=$after.status.containerStatuses[0].imageID
        configuration=$envVars; persistence='PASS'; metrics='jvm_memory_used_bytes present'
    } | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 "$EvidenceDir/verification.json"
    Write-Output 'PASS: Helm services, health, environment, metrics and H2 after pod recreation'
} finally {
    foreach ($p in $forwarders) { if (-not $p.HasExited) { Stop-Process -Id $p.Id } }
}
