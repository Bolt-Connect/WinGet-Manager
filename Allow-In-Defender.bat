@echo off
setlocal

REM ── Self-elevate ────────────────────────────────────────────────────────────
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "APPDIR=%~dp0"
if "%APPDIR:~-1%"=="\" set "APPDIR=%APPDIR:~0,-1%"

echo ============================================
echo  WinGet Manager - Defender-uitsluiting
echo ============================================
echo.
echo Map: %APPDIR%
echo.

powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%APPDIR%' -ErrorAction Stop; Write-Host 'OK - map is uitgesloten van Defender-scan.' -ForegroundColor Green"

if %errorLevel% neq 0 (
    echo.
    echo MISLUKT. Voer handmatig uit in Admin PowerShell:
    echo.
    echo   Add-MpPreference -ExclusionPath "%APPDIR%"
    echo.
)

echo.
echo Druk op een toets om te sluiten en daarna Start-GUI.bat te starten.
pause
