# Tokki Windows installer: installs the compiled Tokki package from PyPI.
# usage: irm https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.ps1 | iex
# or:    powershell -ExecutionPolicy Bypass -File install.ps1 [-Version X.Y.Z] [-Method auto|uv|pipx|user] [-Uninstall]
#
# When piped through `iex`, parameters cannot be passed; set environment
# variables before the `irm | iex` line instead:
#   $env:TOKKI_VERSION = "0.3.11"
#   $env:TOKKI_INSTALL_METHOD = "uv"
#   $env:TOKKI_ADD_TO_PATH = "1"
#   $env:TOKKI_UNINSTALL = "1"
param(
    [string]$Version = "",
    [string]$Method = "",
    [switch]$Uninstall,
    [switch]$AddToPath,
    [switch]$WithWrappers,
    [string[]]$Agent = @()
)

$ErrorActionPreference = "Stop"

function Test-Command($name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

function Test-Truthy($value) {
    if ($null -eq $value) { return $false }
    return @("1", "true", "yes", "on") -contains ($value.ToString().Trim().ToLowerInvariant())
}

function Test-RealPython($name) {
    # The Microsoft Store ships a `python` alias stub that opens the Store
    # instead of running Python; probe the interpreter before trusting it.
    if (-not (Test-Command $name)) { return $false }
    & $name -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 8) else 1)" 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Get-PythonCommand() {
    if (Test-RealPython "python") { return "python" }
    if (Test-RealPython "py") { return "py" }
    return $null
}

function Get-UserScriptsPath($python) {
    if (-not $python) { return "" }
    $userBase = (& $python -m site --user-base 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or -not $userBase) { return "" }
    return (Join-Path $userBase "Scripts")
}

function Add-UserPath($path) {
    if (-not $path) { return }
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $currentUserPath) { $currentUserPath = "" }
    $parts = $currentUserPath -split ";" | Where-Object { $_ -ne "" }
    if ($parts -notcontains $path) {
        $newPath = if ($currentUserPath) { "$path;$currentUserPath" } else { $path }
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "path: added to user PATH: $path"
    } else {
        Write-Host "path: already in user PATH: $path"
    }
    if (($env:Path -split ";") -notcontains $path) {
        $env:Path = "$path;$env:Path"
    }
}

function Find-TokkiCommand($pathHint) {
    $command = Get-Command tokki -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $candidates = @()
    if ($pathHint) {
        $candidates += Join-Path $pathHint "tokki.exe"
        $candidates += Join-Path $pathHint "tokki"
    }
    if ($env:USERPROFILE) {
        $defaultToolPath = Join-Path $env:USERPROFILE ".local\bin"
        $candidates += Join-Path $defaultToolPath "tokki.exe"
        $candidates += Join-Path $defaultToolPath "tokki"
    }
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return $candidate }
    }
    return ""
}

if ($Version -eq "" -and $env:TOKKI_VERSION) {
    $Version = $env:TOKKI_VERSION
}
if ($Method -eq "" -and $env:TOKKI_INSTALL_METHOD) {
    $Method = $env:TOKKI_INSTALL_METHOD
}
if ($Method -eq "") {
    $Method = "auto"
}
if (Test-Truthy $env:TOKKI_UNINSTALL) {
    $Uninstall = $true
}
if (Test-Truthy $env:TOKKI_ADD_TO_PATH) {
    $AddToPath = $true
}
if (Test-Truthy $env:TOKKI_WITH_WRAPPERS) {
    $WithWrappers = $true
}
if ($Agent.Count -eq 0 -and $env:TOKKI_AGENT) {
    $Agent = @($env:TOKKI_AGENT -split "[,; ]+" | Where-Object { $_ -ne "" })
}
if ($Agent.Count -gt 0) {
    $WithWrappers = $true
}

if (@("auto", "uv", "pipx", "user") -notcontains $Method) {
    Write-Error "tokki install: -Method must be auto, uv, pipx, or user"
    exit 2
}

$spec = "tokki"
if ($Version -ne "") {
    $spec = "tokki==$Version"
}

$defaultToolPath = if ($env:USERPROFILE) { Join-Path $env:USERPROFILE ".local\bin" } else { "" }
$python = Get-PythonCommand
$pythonScripts = Get-UserScriptsPath $python
$pathHint = if ($defaultToolPath) { $defaultToolPath } else { $pythonScripts }

if ($Uninstall) {
    Write-Host "tokki uninstall"
    $removed = $false
    if (Test-Command "uv") {
        uv tool uninstall tokki | Out-Null
        if ($LASTEXITCODE -eq 0) { $removed = $true }
    }
    if (Test-Command "pipx") {
        pipx uninstall tokki | Out-Null
        if ($LASTEXITCODE -eq 0) { $removed = $true }
    }
    if ($python) {
        & $python -m pip uninstall -y tokki | Out-Null
        if ($LASTEXITCODE -eq 0) { $removed = $true }
    }
    $uninstallCandidates = @()
    if ($defaultToolPath) {
        $uninstallCandidates += Join-Path $defaultToolPath "tokki.exe"
        $uninstallCandidates += Join-Path $defaultToolPath "tokki"
    }
    if ($pythonScripts) {
        $uninstallCandidates += Join-Path $pythonScripts "tokki.exe"
        $uninstallCandidates += Join-Path $pythonScripts "tokki"
    }
    foreach ($candidate in $uninstallCandidates) {
        if ($candidate -and (Test-Path $candidate)) {
            Remove-Item -Force $candidate -ErrorAction SilentlyContinue
        }
    }
    if ($removed) {
        Write-Host "package: removed"
    } else {
        Write-Host "package: not found by uv, pipx, or pip"
    }
    exit 0
}

Write-Host "tokki install"
Write-Host "package: $spec"
Write-Host "method: $Method"

$installed = $false
$usedMethod = ""

if (($Method -eq "auto" -or $Method -eq "uv") -and (Test-Command "uv")) {
    Write-Host "trying: uv tool install"
    uv tool install --force $spec
    if ($LASTEXITCODE -eq 0) {
        $installed = $true
        $usedMethod = "uv"
        $pathHint = $defaultToolPath
    } elseif ($Method -eq "uv") {
        Write-Error "tokki install: uv failed"
        exit 2
    }
}

if (-not $installed -and ($Method -eq "auto" -or $Method -eq "pipx")) {
    if (Test-Command "pipx") {
        Write-Host "trying: pipx install"
        pipx install --force $spec
        if ($LASTEXITCODE -eq 0) {
            $installed = $true
            $usedMethod = "pipx"
            $pathHint = $defaultToolPath
        } elseif ($Method -eq "pipx") {
            Write-Error "tokki install: pipx failed"
            exit 2
        }
    } elseif ($Method -eq "pipx") {
        Write-Error "tokki install: pipx is not available"
        exit 2
    }
}

if (-not $installed -and ($Method -eq "auto" -or $Method -eq "user")) {
    if ($python) {
        Write-Host "trying: pip --user"
        & $python -m pip install --user --upgrade --force-reinstall $spec
        if ($LASTEXITCODE -eq 0) {
            $installed = $true
            $usedMethod = "pip --user"
            $pythonScripts = Get-UserScriptsPath $python
            if ($pythonScripts) { $pathHint = $pythonScripts }
        } elseif ($Method -eq "user") {
            Write-Error "tokki install: pip --user failed"
            exit 2
        }
    } elseif ($Method -eq "user") {
        Write-Error "tokki install: Python 3.8+ was not found"
        exit 2
    }
}

if (-not $installed) {
    Write-Error "tokki install: failed; install uv (https://docs.astral.sh/uv/), pipx, or Python 3.8+ and retry."
    exit 2
}

if ($AddToPath -and $pathHint) {
    Add-UserPath $pathHint
}

$tokkiPath = Find-TokkiCommand $pathHint
if ($tokkiPath) {
    Write-Host "installed_by: $usedMethod"
    Write-Host "tokki: $tokkiPath"
    & $tokkiPath --version
} else {
    Write-Warning "tokki was installed but the command was not found yet."
    if ($pathHint) {
        Write-Warning "Add this directory to PATH, then reopen PowerShell: $pathHint"
        Write-Warning "  [Environment]::SetEnvironmentVariable('Path', `"$pathHint;`" + [Environment]::GetEnvironmentVariable('Path','User'), 'User')"
    }
    exit 3
}

if ($pathHint -and (($env:Path -split ";") -notcontains $pathHint)) {
    Write-Warning "$pathHint is not in this PowerShell session PATH."
    Write-Warning "Rerun with -AddToPath, set TOKKI_ADD_TO_PATH=1, or add it manually and reopen the shell."
}

if ($WithWrappers) {
    $requested = if ($Agent.Count -gt 0) { $Agent -join ", " } else { "detected agents" }
    Write-Warning "wrappers: not installed in native Windows PowerShell ($requested requested)."
    Write-Warning "Tokki agent wrappers are POSIX shims; use WSL or Git Bash and run install.sh --with-wrappers."
} else {
    Write-Host "wrappers: skipped on native Windows; use WSL/Git Bash for POSIX agent shims."
}

Write-Host "verify: tokki --version passed"
Write-Host "next: tokki doctor --strict"
