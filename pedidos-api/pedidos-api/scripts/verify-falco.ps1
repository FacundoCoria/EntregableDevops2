param([string]$Context = 'minikube')
$ErrorActionPreference = 'Stop'
$appRoot = Split-Path $PSScriptRoot -Parent
$repoRoot = (Resolve-Path (Join-Path $appRoot '../..')).Path
$manifest = Join-Path $appRoot 'security/falco/test-sensitive-read.yaml'
$reportRoot = Join-Path $repoRoot 'reports/l4-08'
$log = Join-Path $repoRoot 'reports/falco-event.log'
New-Item -ItemType Directory -Force $reportRoot | Out-Null
if (Test-Path $log) { throw 'El log ya existe. Preservarlo antes de elegir otra ruta para repetir.' }
$utf8 = [System.Text.UTF8Encoding]::new($false)
function Record([string]$Message) {
    [System.IO.File]::AppendAllText($log, $Message + "`n", $utf8)
}
function Kube {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments)
    Record ("`nUTC: " + [DateTime]::UtcNow.ToString('o') + "`nCOMMAND: kubectl --context $Context " + ($Arguments -join ' '))
    $lines = @(& kubectl --context $Context @Arguments 2>&1)
    $code = $LASTEXITCODE
    $value = ($lines | Out-String).TrimEnd()
    Record ("EXIT: $code`n$value")
    if ($code -ne 0) { throw "kubectl fallo, exit=$code; consultar $log" }
    return $value
}
function Events([string]$Raw) {
    foreach ($line in ($Raw -split "`n")) {
        try {
            $event = $line | ConvertFrom-Json -ErrorAction Stop
            if ($event.rule) { $event }
        } catch { } # Los mensajes de arranque pueden no ser JSON.
    }
}
$created = $false
Record "L4-08 Falco; UTC=$([DateTime]::UtcNow.ToString('o')); context=$Context; namespace=laboratorio4"
Record 'Accion: cat /etc/shadow mediante exec directo sin shell/TTY. Archivo ficticio de ConfigMap, sin credenciales reales. Control: cat /etc/hostname.'
try {
    Kube @('get','nodes','-o','wide') | Set-Content (Join-Path $reportRoot 'nodes.txt')
    $falcoPod = ((Kube @('-n','falco','get','pods','-l','app.kubernetes.io/name=falco','-o','json')) | ConvertFrom-Json).items
    if ($falcoPod.Count -ne 1) { throw 'Esta prueba espera un solo nodo/agente Falco.' }
    $falcoName = $falcoPod[0].metadata.name
    Kube @('-n','falco','wait',"pod/$falcoName",'--for=condition=Ready','--timeout=60s') | Out-Null
    Kube @('-n','falco','logs',$falcoName,'-c','falco') | Set-Content (Join-Path $reportRoot 'falco-startup.log')
    # create evita adoptar y posteriormente borrar recursos preexistentes.
    Kube @('create','--dry-run=server','-f',$manifest) | Out-Null
    Kube @('create','-f',$manifest) | Out-Null
    $created = $true
    Kube @('-n','laboratorio4','wait','pod/l4-08-falco-read','--for=condition=Ready','--timeout=120s') | Out-Null
    $podRaw = Kube @('-n','laboratorio4','get','pod','l4-08-falco-read','-o','json')
    $podRaw | Set-Content (Join-Path $reportRoot 'test-pod.json')
    $pod = $podRaw | ConvertFrom-Json
    $cid = $pod.status.containerStatuses[0].containerID -replace '^containerd://',''
    if (-not $cid) { throw 'No se obtuvo containerID.' }
    $since = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ')
    $identity = Kube @('-n','laboratorio4','exec','l4-08-falco-read','-c','reader','--','id')
    if ($identity -notmatch 'uid=10001') { throw 'UID inesperado.' }
    Kube @('-n','laboratorio4','exec','l4-08-falco-read','-c','reader','--','cat','/etc/hostname') | Out-Null
    Start-Sleep -Seconds 8
    $controlRaw = Kube @('-n','falco','logs',$falcoName,'-c','falco',"--since-time=$since")
    $controlRaw | Set-Content (Join-Path $reportRoot 'control-events.log')
    $control = @(Events $controlRaw | Where-Object { $_.rule -eq 'Read sensitive file untrusted' -and $cid.StartsWith([string]$_.output_fields.'container.id') -and $_.output_fields.'container.id' })
    if ($control.Count) { throw 'El control produjo una alerta sensible inesperada en el contenedor de prueba.' }
    $start = [DateTime]::UtcNow
    $fixture = Kube @('-n','laboratorio4','exec','l4-08-falco-read','-c','reader','--','cat','/etc/shadow')
    $end = [DateTime]::UtcNow
    if ($fixture.Trim() -ne 'l4_falco_fixture:!:20000:0:99999:7:::') { throw 'Contenido ficticio inesperado.' }
    $matches = @()
    for ($attempt = 0; $attempt -lt 10; $attempt++) {
        Start-Sleep -Seconds 3
        $raw = Kube @('-n','falco','logs',$falcoName,'-c','falco',"--since-time=$since")
        $raw | Set-Content (Join-Path $reportRoot 'test-window-events.log')
        $matches = @(Events $raw | Where-Object {
            $f = $_.output_fields
            $_.rule -eq 'Read sensitive file untrusted' -and
            $f.'container.id' -and $cid.StartsWith([string]$f.'container.id') -and
            $f.'fd.name' -eq '/etc/shadow' -and $f.'proc.name' -eq 'cat' -and $f.'user.uid' -eq 10001
        })
        if ($matches.Count) { break }
    }
    if (-not $matches.Count) { throw 'No se localizo la alerta requerida; no se acredita deteccion.' }
    $match = $matches[0]
    $eventTime = [DateTimeOffset]::Parse($match.time).UtcDateTime
    if ($eventTime -lt $start.AddSeconds(-2) -or $eventTime -gt $end.AddSeconds(2)) { throw 'Evento fuera de la ventana de accion.' }
    $matches | ConvertTo-Json -Depth 30 | Set-Content (Join-Path $reportRoot 'matched-event.json')
    $result = [ordered]@{
        pass = $true; context = $Context; namespace = 'laboratorio4'; pod = $pod.metadata.name
        podUid = $pod.metadata.uid; containerId = $cid; image = $pod.spec.containers[0].image
        imageId = $pod.status.containerStatuses[0].imageID; falcoPod = $falcoName
        command = 'kubectl --context minikube -n laboratorio4 exec l4-08-falco-read -c reader -- cat /etc/shadow'
        actionStartUtc = $start.ToString('o'); actionEndUtc = $end.ToString('o'); eventTimeUtc = $match.time
        rule = $match.rule; priority = $match.priority; matchedEvents = $matches.Count
        controlMatchedSensitiveEvents = $control.Count; shellOpened = $false; syntheticFixture = $true
    }
    $result | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $reportRoot 'correlation.json')
    Record ("`nRESULT: PASS`n" + ($result | ConvertTo-Json -Depth 10))
    $result | ConvertTo-Json -Depth 10
} catch {
    Record ("`nRESULT: FAIL`n" + $_.Exception.Message)
    throw
} finally {
    if ($created) {
        Kube @('delete','-f',$manifest,'--wait=true','--timeout=60s') | Out-Null
        Record 'CLEANUP: Pod y ConfigMap exclusivos de la prueba eliminados.'
    }
}
