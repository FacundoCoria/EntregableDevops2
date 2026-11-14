$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    docker info --format '{{.ServerVersion}}'
    if ($LASTEXITCODE -ne 0) { throw 'Abrir Docker Desktop y esperar al motor Linux.' }
    New-Item -ItemType Directory -Force -Path '.local' | Out-Null
    if (-not (Test-Path -LiteralPath '.local/admin-password.txt')) {
        $password = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
        [IO.File]::WriteAllText((Join-Path $PSScriptRoot '.local/admin-password.txt'), $password)
        $password = $null
    }
    docker compose --env-file images.env -f compose.yaml config --quiet
    if ($LASTEXITCODE -ne 0) { throw 'Configuracion Compose invalida' }
    docker compose --env-file images.env -f compose.yaml up -d --build --wait --wait-timeout 240
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo iniciar Jenkins dedicado' }
    Write-Output 'Jenkins dedicado: http://localhost:18080 ; usuario bruno'
    Write-Output "Clave local: $PSScriptRoot/.local/admin-password.txt (no compartir ni publicar)"
} finally { Pop-Location }
