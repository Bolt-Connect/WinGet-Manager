#Requires -Version 5.1
<#
.SYNOPSIS
    Bouwt de Windows-installer (Setup.exe) via Inno Setup.

.DESCRIPTION
    Vereist: Inno Setup 6 (https://jrsoftware.org/isdl.php) of installeer met:
        winget install JRSoftware.InnoSetup

    Roept eerst Build-Exe.ps1 aan zodat er een verse exe is, daarna ISCC.

.PARAMETER Version
    Versie-string, default 0.1.0
#>

param(
    [string]$Version = '0.1.0'
)

$ErrorActionPreference = 'Stop'
$root      = $PSScriptRoot
$iss       = Join-Path $root 'installer\WinGetManager.iss'
$releaseDir= Join-Path $root 'release'

# --- 1. Verse EXE bouwen ----------------------------------------------------
Write-Host "[1/3] Hoofd-EXE bouwen..." -ForegroundColor Cyan
& (Join-Path $root 'Build-Exe.ps1')
if (-not (Test-Path (Join-Path $root 'build\WinGetManager.exe'))) {
    throw "Build-Exe.ps1 leverde geen exe op"
}

# --- 2. Inno Setup vinden ---------------------------------------------------
Write-Host "[2/3] Inno Setup detecteren..." -ForegroundColor Cyan

$candidates = @(
    'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
    'C:\Program Files\Inno Setup 6\ISCC.exe'
)
$iscc = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $iscc) {
    # Probeer via PATH
    $cmd = Get-Command ISCC -ErrorAction SilentlyContinue
    if ($cmd) { $iscc = $cmd.Source }
}

if (-not $iscc) {
    Write-Host ""
    Write-Host "Inno Setup niet gevonden. Installeer via:" -ForegroundColor Red
    Write-Host "  winget install JRSoftware.InnoSetup" -ForegroundColor Yellow
    Write-Host "Of download van: https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
    exit 1
}

Write-Host "  Gevonden: $iscc" -ForegroundColor Green

# --- 3. Setup compileren ----------------------------------------------------
Write-Host "[3/3] Setup-installer bouwen (versie $Version)..." -ForegroundColor Cyan

if (-not (Test-Path $releaseDir)) {
    New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null
}

& $iscc "/DMyAppVersion=$Version" $iss
if ($LASTEXITCODE -ne 0) {
    Write-Host "Inno Setup compilatie mislukt" -ForegroundColor Red
    exit 1
}

$setup = Join-Path $releaseDir "WinGetManager-Setup-$Version.exe"
if (Test-Path $setup) {
    $kb = [math]::Round((Get-Item $setup).Length / 1KB, 1)
    Write-Host ""
    Write-Host "KLAAR!" -ForegroundColor Green
    Write-Host "  Setup: $setup ($kb KB)"
    Write-Host ""
    Write-Host "Test:    dubbelklik op $setup"
    Write-Host "Stil:    $setup /VERYSILENT"
    Write-Host "Opties:  $setup /?"
} else {
    Write-Host "Output niet gevonden, check Inno Setup output" -ForegroundColor Red
    exit 1
}
