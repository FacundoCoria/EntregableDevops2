param(
    [string]$EvidenceDir = './observability-evidence',
    [string]$Context = 'minikube',
    [string]$Namespace = 'laboratorio4',
    [string]$Release = 'l4',
    [int]$TrafficSeconds = 90,
    [switch]$KeepForwarding
)
$ErrorActionPreference = 'Stop'
if ($TrafficSeconds -lt 30 -or $TrafficSeconds -gt 300) { throw 'TrafficSeconds must be between 30 and 300' }
New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
$EvidenceDir = (Resolve-Path -LiteralPath $EvidenceDir).Path
$base = "$Release-pedidos"
$forwarders = @()
$passed = $false
function Kube {
    param([string[]]$Arguments)
    $result = & kubectl --context $Context -n $Namespace @Arguments
    if ($LASTEXITCODE -ne 0) { throw "kubectl failed: $($Arguments -join ' ')" }
    return $result
}
function Forward {
    param([string]$Component, [int]$LocalPort, [int]$RemotePort)
    $p = Start-Process -FilePath (Get-Command kubectl).Source -WindowStyle Hidden -PassThru -ArgumentList @(
        '--context', $Context, '-n', $Namespace, 'port-forward', "svc/$base-$Component",
        "${LocalPort}:${RemotePort}", '--address', '127.0.0.1'
    ) -RedirectStandardOutput "$EvidenceDir/forward-$Component.txt" -RedirectStandardError "$EvidenceDir/forward-$Component-error.txt"
    $script:forwarders += $p
}
function Wait-Http {
    param([string]$Url)
    for ($i=0; $i -lt 45; $i++) {
        try { return Invoke-RestMethod $Url -TimeoutSec 3 } catch { Start-Sleep -Seconds 1 }
    }
    throw "Unavailable: $Url"
}
function Save-Json {
    param($Value, [string]$Name)
    $Value | ConvertTo-Json -Depth 60 | Set-Content -Encoding utf8 "$EvidenceDir/$Name.json"
}
function Query {
    param([string]$Expression)
    $q = [uri]::EscapeDataString($Expression)
    $r = Invoke-RestMethod "http://127.0.0.1:19090/api/v1/query?query=$q"
    if ($r.status -ne 'success') { throw 'Prometheus query failed' }
    return $r
}
try {
    Kube -Arguments @('get','pods,pvc,svc,deploy','-o','wide') | Set-Content "$EvidenceDir/resources.txt"
    $pods = Kube -Arguments @('get','pods','-l',"app.kubernetes.io/instance=$Release",'-o','json') | ConvertFrom-Json
    Save-Json $pods 'pods'
    Forward api 18080 8080
    Forward prometheus 19090 9090
    Forward grafana 13000 3000
    $health = Wait-Http 'http://127.0.0.1:18080/actuator/health'
    if ($health.status -ne 'UP') { throw 'API is not UP' }
    $null = Wait-Http 'http://127.0.0.1:19090/-/ready'
    $gh = Wait-Http 'http://127.0.0.1:13000/api/health'
    if ($gh.database -ne 'ok') { throw 'Grafana health failed' }
    # Local laboratory defaults, or environment credentials if changed by the owner.
    # Never write the login response, session cookie or password to evidence.
    $user = if ($env:L4_GRAFANA_USER) { $env:L4_GRAFANA_USER } else { 'admin' }
    $pass = if ($env:L4_GRAFANA_PASSWORD) { $env:L4_GRAFANA_PASSWORD } else { 'admin' }
    $login = @{user=$user; password=$pass} | ConvertTo-Json
    $null = Invoke-RestMethod 'http://127.0.0.1:13000/login' -Method Post -ContentType application/json -Body $login -SessionVariable gs
    $ds = Invoke-RestMethod 'http://127.0.0.1:13000/api/datasources/uid/l4-prometheus' -WebSession $gs
    Save-Json $ds 'datasource'
    $dh = Invoke-RestMethod 'http://127.0.0.1:13000/api/datasources/uid/l4-prometheus/health' -WebSession $gs
    Save-Json $dh 'datasource-health'
    if ($dh.status -ne 'OK') { throw 'Datasource health failed' }
    $dashboard = Invoke-RestMethod 'http://127.0.0.1:13000/api/dashboards/uid/l4-observabilidad' -WebSession $gs
    Save-Json $dashboard 'dashboard-export'
    if (-not $dashboard.meta.provisioned -or $dashboard.dashboard.panels.Count -ne 6) { throw 'Dashboard provisioning failed' }
    # Create a single bounded-cardinality product per run; orders remain as evidence.
    $productName = 'l4-04-' + [guid]::NewGuid().ToString('N').Substring(0,8)
    $product = Invoke-RestMethod 'http://127.0.0.1:18080/api/productos' -Method Post -ContentType application/json -Body (@{nombre=$productName; precio=42.5} | ConvertTo-Json)
    if (-not $product.id) { throw 'Product was not created' }
    $orders = @()
    $started = [DateTimeOffset]::UtcNow
    $reads = 0
    $iteration = 0
    while (([DateTimeOffset]::UtcNow - $started).TotalSeconds -lt $TrafficSeconds) {
        $null = Invoke-RestMethod 'http://127.0.0.1:18080/api/productos'
        $null = Invoke-RestMethod 'http://127.0.0.1:18080/api/pedidos'
        $reads += 2
        if ($iteration % 10 -eq 0) {
            $order = Invoke-RestMethod 'http://127.0.0.1:18080/api/pedidos' -Method Post -ContentType application/json -Body (@{cliente='Prueba L4-04'; producto=@{id=$product.id}; estado='Pendiente'; minutosEspera=12} | ConvertTo-Json)
            if (-not $order.id) { throw 'Order was not created' }
            $orders += $order
        }
        $iteration++
        Start-Sleep -Milliseconds 500
    }
    Save-Json @{started=$started.ToString('o'); ended=[DateTimeOffset]::UtcNow.ToString('o'); product=$product; orders=$orders; reads=$reads} 'traffic'
    $metrics = Invoke-WebRequest 'http://127.0.0.1:18080/actuator/prometheus'
    $metrics.Content | Set-Content "$EvidenceDir/actuator-prometheus.txt"
    $targets = Invoke-RestMethod 'http://127.0.0.1:19090/api/v1/targets'
    Save-Json $targets 'targets'
    foreach ($job in @('pedidos-api','kubelet-resource')) {
        $target = @($targets.data.activeTargets | Where-Object {$_.labels.job -eq $job})
        if ($target.Count -ne 1 -or $target[0].health -ne 'up') { throw "Target not UP: $job" }
    }
    $results = @()
    $to = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $from = $started.ToUnixTimeMilliseconds()
    foreach ($panel in $dashboard.dashboard.panels) {
        $expr = $panel.targets[0].expr.Replace('${release}',$Release).Replace('$release',$Release).Replace('$namespace',$Namespace).Replace('$__rate_interval','1m')
        $r = Query $expr
        Save-Json $r "panel-$($panel.id)-prometheus"
        if ($r.data.result.Count -eq 0) { throw "No data: $($panel.title)" }
        foreach ($series in $r.data.result) {
            $value = [double]::Parse($series.value[1], [Globalization.CultureInfo]::InvariantCulture)
            if ([double]::IsNaN($value) -or [double]::IsInfinity($value) -or $value -lt 0) { throw "Invalid value: $($panel.title)" }
        }
        if ($panel.id -in @(1,2) -and [double]$r.data.result[0].value[1] -le 0) { throw "Expected positive traffic/latency: $($panel.title)" }
        if ($panel.id -in @(3,4) -and $r.data.result.Count -ne $pods.items.Count) { throw 'Expected CPU/memory series for every release pod' }
        $grBody = @{from="$from"; to="$to"; queries=@(@{refId='A'; datasource=@{uid='l4-prometheus'; type='prometheus'}; expr=$expr; range=$true; intervalMs=5000; maxDataPoints=300})} | ConvertTo-Json -Depth 8
        $gr = Invoke-RestMethod 'http://127.0.0.1:13000/api/ds/query' -Method Post -ContentType application/json -Body $grBody -WebSession $gs
        Save-Json $gr "panel-$($panel.id)-grafana"
        if ($gr.results.A.error -or $gr.results.A.status -ge 400 -or $gr.results.A.frames.Count -eq 0) { throw "Grafana query failed: $($panel.title)" }
        if (-not @($gr.results.A.frames | Where-Object {$_.data.values[0].Count -gt 0}).Count) { throw "Empty Grafana frames: $($panel.title)" }
        $results += @{id=$panel.id; title=$panel.title; expression=$expr; prometheus=$r.data.result; grafanaFrames=$gr.results.A.frames.Count}
    }
    $business = Query ('pedidos_creados_total{job="pedidos-api",namespace="'+$Namespace+'",release="'+$Release+'",producto="'+$productName+'"}')
    if ($business.data.result.Count -ne 1 -or [int]$business.data.result[0].value[1] -ne $orders.Count) { throw 'Business metric differs from orders actually created' }
    Save-Json $business 'business-correlation'
    Kube -Arguments @('logs',"deployment/$base-prometheus",'--tail=100') | Set-Content "$EvidenceDir/prometheus-log.txt"
    Kube -Arguments @('logs',"deployment/$base-grafana",'--tail=100') | Set-Content "$EvidenceDir/grafana-log.txt"
    Save-Json @{date=[DateTimeOffset]::UtcNow.ToString('o');context=$Context;namespace=$Namespace;release=$Release;status='PASS';targets='both UP';panels=$results;ordersCreated=$orders.Count;businessCounter=[int]$business.data.result[0].value[1];grafanaVersion=$gh.version} 'verification'
    $passed=$true
    Write-Output 'PASS: both scrapes UP, six panels queried through Prometheus and Grafana, business counter matches created orders'
} finally {
    if ($KeepForwarding -and $passed) {
        Save-Json @($forwarders | ForEach-Object {@{id=$_.Id;path=$_.Path;startTime=$_.StartTime.ToString('o')}}) 'forward-processes'
        Write-Output 'Local URLs remain available on ports 18080, 19090 and 13000 for Bruno to review.'
    } else {
        foreach ($p in $forwarders) { if (-not $p.HasExited) { Stop-Process -Id $p.Id } }
    }
}
