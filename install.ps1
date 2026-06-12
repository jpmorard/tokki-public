# Tokki Windows installer: installs the compiled Tokki package from PyPI.
# usage: irm https://raw.githubusercontent.com/jpmorard/tokki-public/main/install.ps1 | iex
# or:    powershell -ExecutionPolicy Bypass -File install.ps1 [-Version X.Y.Z]
param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$spec = "tokki"
if ($Version -ne "") {
    $spec = "tokki==$Version"
}

function Test-Command($name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host "tokki install"

$installed = $false
if (Test-Command "uv") {
    uv tool install --force $spec
    if ($LASTEXITCODE -eq 0) { $installed = $true }
}
if (-not $installed -and (Test-Command "pipx")) {
    pipx install --force $spec
    if ($LASTEXITCODE -eq 0) { $installed = $true }
}
if (-not $installed -and (Test-Command "python")) {
    python -m pip install --user --upgrade --force-reinstall $spec
    if ($LASTEXITCODE -eq 0) { $installed = $true }
}

if (-not $installed) {
    Write-Error "tokki install: failed; install uv (https://docs.astral.sh/uv/) or pipx and retry."
    exit 2
}

if (Test-Command "tokki") {
    tokki --version
} else {
    Write-Warning "tokki was installed but is not on PATH; restart the shell or add the Python scripts directory to PATH."
}
