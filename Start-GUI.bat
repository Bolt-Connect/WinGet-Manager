@echo off
setlocal enabledelayedexpansion

set "APPDIR=%~dp0"
if "%APPDIR:~-1%"=="\" set "APPDIR=%APPDIR:~0,-1%"

REM ── Check signature van WinGetManager.ps1 (de echte test) ───────────────────
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "exit ([int]((Get-AuthenticodeSignature '%APPDIR%\WinGetManager.ps1').Status -ne 'Valid'))"
if %ERRORLEVEL% EQU 0 goto :launch

REM ── Setup nodig: elevated signing-script aanroepen ─────────────────────────
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "try { $p = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File','%APPDIR%\Sign-Scripts.ps1','-AppPath','%APPDIR%'); exit $p.ExitCode } catch { exit 99 }"
set "SETUP_EXIT=%ERRORLEVEL%"

REM ── Hercheck signature ──────────────────────────────────────────────────────
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "exit ([int]((Get-AuthenticodeSignature '%APPDIR%\WinGetManager.ps1').Status -ne 'Valid'))"
if %ERRORLEVEL% EQU 0 goto :launch

REM ── Setup mislukt: toon foutdialoog met log-inhoud ─────────────────────────
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Add-Type -AssemblyName System.Windows.Forms;" ^
  "$logPath = '%APPDIR%\setup.log';" ^
  "$status = (Get-AuthenticodeSignature '%APPDIR%\WinGetManager.ps1').Status;" ^
  "$tail = if (Test-Path $logPath) { (Get-Content $logPath -Tail 30) -join [Environment]::NewLine } else { '(geen setup.log gevonden - elevated proces is mogelijk niet gestart)' };" ^
  "$msg = 'Setup is niet voltooid.' + [Environment]::NewLine + 'Setup-exitcode: %SETUP_EXIT%' + [Environment]::NewLine + 'Signature-status: ' + $status + [Environment]::NewLine + [Environment]::NewLine + 'Laatste 30 regels uit setup.log:' + [Environment]::NewLine + $tail;" ^
  "[System.Windows.Forms.MessageBox]::Show($msg, 'WinGet Manager - setup mislukt', 'OK', 'Error')"
exit /b 1

:launch
start "" /b powershell.exe -NoProfile -STA -ExecutionPolicy AllSigned -WindowStyle Hidden -File "%APPDIR%\WinGetManager.ps1"
exit /b 0
