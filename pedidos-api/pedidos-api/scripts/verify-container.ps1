param(
    [string]$Image = 'pedidos-api:l4-01',
    [string]$EvidenceDir = './container-evidence'
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
$EvidenceDir = (Resolve-Path -LiteralPath $EvidenceDir).Path
$testId = 'l4-01-' + [guid]::NewGuid().ToString('N').Substring(0, 12)
$volumeName = "$testId-data"
$containerName = "$testId-api"
function Invoke-Docker {
    param([string[]]$Arguments)
    $result = & docker @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Docker failed: $($Arguments[0])" }
    return $result
}
function Start-TestApi {
    Invoke-Docker -Arguments @('run', '-d', '--name', $containerName,
        '--memory', '768m', '--cpus', '1', '--cap-drop', 'ALL',
        '--security-opt', 'no-new-privileges',
        '-e', 'SPRING_H2_CONSOLE_ENABLED=false',
        '-e', 'MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED=true',
        '-p', '127.0.0.1::8080', '--mount', "type=volume,source=$volumeName,target=/data", $Image) | Out-Null
    $portInfo = Invoke-Docker -Arguments @('port', $containerName, '8080/tcp')
    $script:baseUrl = 'http://' + ($portInfo | Select-Object -First 1)
    for ($attempt = 0; $attempt -lt 90; $attempt++) {
        try {
            $health = Invoke-RestMethod "$baseUrl/actuator/health" -TimeoutSec 2
            if ($health.status -eq 'UP') { return }
        } catch {}
        Start-Sleep -Seconds 2
    }
    throw 'API did not become healthy within the startup budget'
}
$passed = $false
try {
    Invoke-Docker -Arguments @('volume', 'create', $volumeName) | Out-Null
    Start-TestApi
    $user = Invoke-Docker -Arguments @('exec', $containerName, 'id')
    if ($user -notmatch 'uid=10001' -or $user -notmatch 'gid=10001') { throw "Unexpected user: $user" }
    $payload = @{nombre=$testId; precio=123.45} | ConvertTo-Json
    $created = Invoke-RestMethod "$baseUrl/api/productos" -Method Post -ContentType 'application/json' -Body $payload
    if (-not $created.id) { throw 'Product was not created' }
    $metrics = Invoke-WebRequest "$baseUrl/actuator/prometheus" -UseBasicParsing
    if ($metrics.Content -notmatch 'jvm_memory_used_bytes') { throw 'Prometheus metrics missing' }
    $liveness = Invoke-RestMethod "$baseUrl/actuator/health/liveness"
    if ($liveness.status -ne 'UP') { throw 'Liveness check failed' }
    Invoke-Docker -Arguments @('stop', '--time', '30', $containerName) | Out-Null
    & docker logs $containerName 2>&1 | Set-Content -Encoding utf8 "$EvidenceDir/api-first-start.txt"
    Invoke-Docker -Arguments @('rm', $containerName) | Out-Null
    Start-TestApi
    $recovered = Invoke-RestMethod "$baseUrl/api/productos/$($created.id)"
    if ($recovered.nombre -ne $testId -or $recovered.precio -ne 123.45) { throw 'H2 persistence check failed' }
    $files = Invoke-Docker -Arguments @('exec', $containerName, 'ls', '-ln', '/data')
    $imageId = Invoke-Docker -Arguments @('image', 'inspect', '--format', '{{.Id}}', $Image)
    @{
        date = (Get-Date).ToString('o'); image = $Image; imageId = $imageId
        user = $user; health = 'UP'; liveness = 'UP'; metrics = 'jvm_memory_used_bytes present'
        created = $created; recoveredAfterRecreation = $recovered; dataFiles = $files
        memoryLimit = '768m'; cpuLimit = '1'; persistence = 'PASS'; volume = $volumeName
    } | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 "$EvidenceDir/container-verification.json"
    $passed = $true
    Write-Output 'PASS: non-root, API, health, metrics and H2 persistence after container recreation'
} finally {
    & docker logs $containerName 2>&1 | Set-Content -Encoding utf8 "$EvidenceDir/api-last-start.txt"
    & docker stop --time 30 $containerName | Out-Null
    & docker rm $containerName | Out-Null
    # Only the unique volume created by this execution is eligible for cleanup.
    if ($passed) { & docker volume rm $volumeName | Out-Null }
    else { Write-Warning "Retained test volume for diagnosis: $volumeName" }
}
