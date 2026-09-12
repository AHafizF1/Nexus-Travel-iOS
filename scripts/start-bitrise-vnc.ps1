<#
.SYNOPSIS
Opens a Bitrise Remote Development Environment through local noVNC.

.DESCRIPTION
Required environment variables:
  BITRISE_RDE_SSH_HOST
  BITRISE_RDE_SSH_PASSWORD
  BITRISE_RDE_VNC_HOST

Optional environment variables:
  BITRISE_RDE_SSH_PORT (default 22)
  BITRISE_RDE_SSH_USER (default vagrant)
  BITRISE_RDE_VNC_PORT (default 5900)

.EXAMPLE
$env:BITRISE_RDE_SSH_HOST = "ssh-host-from-bitrise"
$env:BITRISE_RDE_SSH_PASSWORD = "ssh-password-from-bitrise"
$env:BITRISE_RDE_VNC_HOST = "vnc-host-from-bitrise"
.\scripts\start-bitrise-vnc.ps1 -InstallDependencies
#>
[CmdletBinding()]
param(
    [string]$SshHost = $env:BITRISE_RDE_SSH_HOST,
    [int]$SshPort = $(if ($env:BITRISE_RDE_SSH_PORT) { [int]$env:BITRISE_RDE_SSH_PORT } else { 22 }),
    [string]$SshUser = $(if ($env:BITRISE_RDE_SSH_USER) { $env:BITRISE_RDE_SSH_USER } else { "vagrant" }),
    [string]$VncHost = $env:BITRISE_RDE_VNC_HOST,
    [int]$VncPort = $(if ($env:BITRISE_RDE_VNC_PORT) { [int]$env:BITRISE_RDE_VNC_PORT } else { 5900 }),
    [int]$LocalVncPort = 5901,
    [int]$WebPort = 6080,
    [switch]$InstallDependencies
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Value {
    param([string]$Name, [string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "Missing $Name. Set it as an environment variable or pass its matching parameter."
    }
}

function Test-LocalPort {
    param([int]$Port)

    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $Port)
    try {
        $listener.Start()
        return $true
    }
    catch {
        return $false
    }
    finally {
        $listener.Stop()
    }
}

function Wait-LocalPort {
    param([int]$Port, [int]$TimeoutSeconds = 15)

    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    do {
        try {
            $client = [Net.Sockets.TcpClient]::new()
            $client.Connect("127.0.0.1", $Port)
            $client.Dispose()
            return
        }
        catch {
            Start-Sleep -Milliseconds 250
        }
    } while ([DateTime]::UtcNow -lt $deadline)

    throw "Local port $Port did not become ready within $TimeoutSeconds seconds."
}

$sshPassword = $env:BITRISE_RDE_SSH_PASSWORD
Require-Value "BITRISE_RDE_SSH_HOST" $SshHost
Require-Value "BITRISE_RDE_SSH_PASSWORD" $sshPassword
Require-Value "BITRISE_RDE_VNC_HOST" $VncHost

$ssh = Get-Command ssh.exe -ErrorAction Stop
$git = Get-Command git.exe -ErrorAction Stop
$python = Get-Command python.exe -ErrorAction Stop

if (!(Test-LocalPort $LocalVncPort)) {
    throw "Local VNC port $LocalVncPort is already in use. Stop old tunnel or pass -LocalVncPort."
}
if (!(Test-LocalPort $WebPort)) {
    throw "Web port $WebPort is already in use. Stop old noVNC bridge or pass -WebPort."
}

$cacheRoot = Join-Path $env:LOCALAPPDATA "NexusTravel\remote-desktop"
$noVncRoot = Join-Path $cacheRoot "noVNC"
$askPassPath = Join-Path $cacheRoot "ssh-askpass.cmd"
$sshErrorPath = Join-Path $cacheRoot "ssh-error.log"
New-Item -ItemType Directory -Path $cacheRoot -Force | Out-Null

if (!(Test-Path -LiteralPath $noVncRoot)) {
    if (!$InstallDependencies) {
        throw "noVNC missing at $noVncRoot. Run once with -InstallDependencies."
    }
    & $git.Source clone --depth 1 https://github.com/novnc/noVNC.git $noVncRoot
    if ($LASTEXITCODE -ne 0) { throw "noVNC clone failed." }
}

& $python.Source -m websockify --help *> $null
if ($LASTEXITCODE -ne 0) {
    if (!$InstallDependencies) {
        throw "Python websockify missing. Run once with -InstallDependencies."
    }
    & $python.Source -m pip install --user websockify
    if ($LASTEXITCODE -ne 0) { throw "websockify install failed." }
}

# Askpass reads password from inherited environment. Secret never enters script file or process arguments.
Set-Content -LiteralPath $askPassPath -Encoding Ascii -Value '@powershell.exe -NoProfile -Command "[Console]::Out.Write($env:BITRISE_RDE_SSH_PASSWORD)"'
$env:SSH_ASKPASS = $askPassPath
$env:SSH_ASKPASS_REQUIRE = "force"
$env:DISPLAY = "codex-vnc"

$forward = "127.0.0.1:${LocalVncPort}:${VncHost}:${VncPort}"
$sshArgs = @(
    "-N", "-T",
    "-o", "ExitOnForwardFailure=yes",
    "-o", "StrictHostKeyChecking=accept-new",
    "-o", "ServerAliveInterval=30",
    "-o", "ServerAliveCountMax=3",
    "-L", $forward,
    "-p", $SshPort,
    "${SshUser}@${SshHost}"
)

$sshProcess = $null
$webProcess = $null
try {
    Remove-Item -LiteralPath $sshErrorPath -Force -ErrorAction SilentlyContinue
    $sshProcess = Start-Process -FilePath $ssh.Source -ArgumentList $sshArgs -PassThru -WindowStyle Hidden -RedirectStandardError $sshErrorPath
    try {
        Wait-LocalPort -Port $LocalVncPort
    }
    catch {
        if ($sshProcess.HasExited) {
            $details = Get-Content -Raw -LiteralPath $sshErrorPath -ErrorAction SilentlyContinue
            throw "SSH tunnel exited before opening local port $LocalVncPort. $details"
        }
        throw
    }

    $webArgs = @("-m", "websockify", "--web", $noVncRoot, $WebPort, "127.0.0.1:$LocalVncPort")
    $webProcess = Start-Process -FilePath $python.Source -ArgumentList $webArgs -PassThru -WindowStyle Hidden
    Wait-LocalPort -Port $WebPort

    $url = "http://127.0.0.1:$WebPort/vnc.html?autoconnect=true&resize=remote"
    Start-Process $url
    Write-Output "[OK] Remote desktop opened: $url"
    Write-Output "[INFO] noVNC login uses Bitrise VNC username/password from current RDE session."
    Write-Output "[INFO] Press Ctrl+C to stop tunnel and bridge."

    while (!$sshProcess.HasExited -and !$webProcess.HasExited) {
        Start-Sleep -Seconds 1
    }
    throw "SSH tunnel or noVNC bridge stopped unexpectedly."
}
finally {
    if ($webProcess -and !$webProcess.HasExited) { Stop-Process -Id $webProcess.Id }
    if ($sshProcess -and !$sshProcess.HasExited) { Stop-Process -Id $sshProcess.Id }
    Remove-Item -LiteralPath $askPassPath -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $sshErrorPath -Force -ErrorAction SilentlyContinue
}
