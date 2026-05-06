@echo off
setlocal
set "APPDIR=%~dp0"
if "%APPDIR:~-1%"=="\" set "APPDIR=%APPDIR:~0,-1%"

echo === WinGet Manager - debug start ===
echo App pad: %APPDIR%
echo.

echo [1] Signature-status van WinGetManager.ps1:
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "(Get-AuthenticodeSignature '%APPDIR%\WinGetManager.ps1') | Format-List Status, StatusMessage, SignerCertificate"

echo [2] Signatures van alle modules:
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem '%APPDIR%' -Recurse -Include '*.ps1','*.psm1' | ForEach-Object { $s = Get-AuthenticodeSignature $_.FullName; '{0,-10} {1}' -f $s.Status, $_.FullName.Substring($PWD.Path.Length) }" 2>&1

echo.
echo [3] App starten (zichtbare console)...
echo ============================================
powershell.exe -NoProfile -STA -ExecutionPolicy AllSigned -File "%APPDIR%\WinGetManager.ps1"
echo ============================================
echo.
echo Script eindigde met exitcode: %ERRORLEVEL%
echo.
pause
