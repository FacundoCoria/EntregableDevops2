param([string]$Context = 'minikube')
$ErrorActionPreference = 'Stop'
$appRoot = Split-Path $PSScriptRoot -Parent
$repoRoot = (Resolve-Path (Join-Path $appRoot '../..')).Path
$policyRoot = Join-Path $appRoot 'security/kyverno'
$reportRoot = Join-Path $repoRoot 'reports/l4-07'
$log = Join-Path $repoRoot 'reports/kyverno-validation.log'
New-Item -ItemType Directory -Force $reportRoot | Out-Null
if (Test-Path $log) { throw 'El log ya existe; conservarlo y elegir una nueva ruta antes de repetir.' }
"L4-07 Kyverno admission validation; $(Get-Date -Format o); context=$Context; namespace=laboratorio4; server dry-run" | Set-Content $log
$cases = Get-Content (Join-Path $policyRoot 'tests/cases.json') -Raw | ConvertFrom-Json
$results = @()
foreach ($case in $cases) {
    $file = Join-Path $policyRoot ('tests/' + $case.file)
    $output = & kubectl --context $Context create --dry-run=server -f $file 2>&1
    $exit = $LASTEXITCODE
    $outputText = $output | Out-String
    $expected = if ($case.policy) { 'DENY ' + $case.policy } else { 'ACCEPT' }
    $pass = if ($case.policy) { $exit -ne 0 -and $outputText.Contains($case.policy) -and $outputText.Contains('denied') } else { $exit -eq 0 }
    "`nCOMMAND: kubectl --context $Context create --dry-run=server -f $file`nEXPECTED: $expected`nEXIT: $exit`n$outputText`nPASS: $pass" | Add-Content $log
    $results += [pscustomobject]@{case=$case.file;expected=$expected;exitCode=$exit;pass=$pass}
}
$results | ConvertTo-Json | Set-Content (Join-Path $reportRoot 'validation-results.json')
$results | Format-Table
if ($results.Where({ -not $_.pass }).Count) { throw 'Fallaron casos; revisar el log preservado.' }
"`nRESULT: $($results.Count)/$($results.Count) PASS. Los dry-run prueban admision; no ejecucion de contenedores." | Add-Content $log
