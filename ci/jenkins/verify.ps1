param(
    [string]$OutputDirectory,
    [ValidatePattern('^l4-c01(-[a-z0-9-]+)?$')][string]$ProjectName = 'l4-c01'
)
$ErrorActionPreference = 'Stop'
if (-not $OutputDirectory) {
    $stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
    $OutputDirectory = Join-Path $PSScriptRoot "../../reports/l4-c01/verify-$stamp"
}
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
function Invoke-DockerChecked([string[]]$DockerArguments) {
    $result = & docker @DockerArguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Docker fallo: $($DockerArguments -join ' ')`n$result" }
    return ($result -join "`n")
}
Push-Location $PSScriptRoot
try {
    $compose = @('compose','--env-file','images.env','-f','compose.yaml','-p',$ProjectName)
    $controller = Invoke-DockerChecked ($compose + @('ps','-q','controller'))
    $agent = Invoke-DockerChecked ($compose + @('ps','-q','agent'))
    $engine = Invoke-DockerChecked ($compose + @('ps','-q','docker'))
    if (-not $controller -or -not $agent -or -not $engine) { throw 'Faltan servicios dedicados' }
    $state = Invoke-DockerChecked @('exec',$controller,'cat','/var/jenkins_home/c01-configured.json')
    $config = $state | ConvertFrom-Json
    if ($config.core -ne '2.580.2' -or $config.controllerExecutors -ne 0 -or $config.agentExecutors -ne 1 -or -not $config.integralDisabled) { throw 'Configuracion Jenkins inesperada' }
    $lock = Get-Content -Raw plugins.lock.json | ConvertFrom-Json
    foreach ($plugin in $lock.plugins.PSObject.Properties) {
        if ($config.plugins.($plugin.Name) -ne $plugin.Value.version) { throw "Plugin distinto: $($plugin.Name)" }
    }
    $state | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'jenkins-state.json')
    $details = @()
    foreach ($entry in @(@{service='controller';id=$controller},@{service='agent';id=$agent},@{service='docker';id=$engine})) {
        $container = (Invoke-DockerChecked @('inspect',$entry.id) | ConvertFrom-Json)[0]
        if ($container.Mounts | Where-Object { $_.Source -eq '/var/run/docker.sock' -or $_.Destination -eq '/var/run/docker.sock' }) { throw 'Socket host montado' }
        if ($entry.service -ne 'docker') {
            $uid = Invoke-DockerChecked @('exec',$entry.id,'id','-u')
            if ($uid.Trim() -ne '1000' -or $container.HostConfig.Privileged) { throw 'Identidad/privilegios Jenkins incorrectos' }
        }
        $details += @{
            service=$entry.service;id=$container.Id;image=$container.Image;user=$container.Config.User
            privileged=$container.HostConfig.Privileged;mounts=$container.Mounts;networks=@($container.NetworkSettings.Networks.PSObject.Properties.Name)
            restartCount=$container.RestartCount;ports=$container.NetworkSettings.Ports
        }
    }
    $details | ConvertTo-Json -Depth 10 | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'containers.json')
    Invoke-DockerChecked @('exec',$controller,'sh','-c','set -eu; test ! -S /var/run/docker.sock; test ! -e /certs/client; test ! -e /var/jenkins_home/l4-kube/config; ! getent hosts docker') | Out-Null
    $hostId = Invoke-DockerChecked @('info','--format','{{.ID}}')
    $remoteId = Invoke-DockerChecked @('exec',$agent,'docker','info','--format','{{.ID}}')
    if ($hostId -eq $remoteId) { throw 'Agente conectado al Docker del equipo' }
    $dockerVersion = Invoke-DockerChecked @('exec',$agent,'docker','version')
    $dockerVersion | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'docker-version.txt')
    Invoke-DockerChecked @('exec',$agent,'docker','buildx','version') | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'buildx-version.txt')
    Invoke-DockerChecked @('exec',$agent,'sh','-c','set -eu; test "$DOCKER_TLS_VERIFY" = 1; test "$DOCKER_HOST" = tcp://docker:2376; test -r /certs/client/key.pem; test ! -S /var/run/docker.sock') | Out-Null
    $tools = Invoke-DockerChecked @('exec',$agent,'sh','/opt/l4/bootstrap-tools.sh')
    $tools | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'tools.txt')
    Invoke-DockerChecked @('exec',$agent,'sh','/opt/l4/test-versions.sh') | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'version-negative.txt')
    Invoke-DockerChecked @('exec',$agent,'dpkg-query','-W') | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'apt-packages.txt')
    Invoke-DockerChecked @('exec',$agent,'cat','/opt/l4-tools/python-packages.txt') | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'python-packages.txt')
    Invoke-DockerChecked @('exec',$agent,'sh','-c','java -version 2>&1; python3 --version; git --version; curl --version') | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'base-tools.txt')
    @{result='PASS';hostDockerId=$hostId;dedicatedDockerId=$remoteId;pluginsChecked=@($lock.plugins.PSObject.Properties).Count;timestamp=(Get-Date).ToUniversalTime().ToString('o')} | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'result.json')
    Write-Output "C01_VERIFY_PASS: $OutputDirectory"
} finally { Pop-Location }
