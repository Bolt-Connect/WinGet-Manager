@echo off
setlocal
set "APPDIR=%~dp0"
if "%APPDIR:~-1%"=="\" set "APPDIR=%APPDIR:~0,-1%"

echo ============================================
echo  WinGet Manager - EXE bouwen
echo ============================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%APPDIR%\Build-Exe.ps1"

echo.
pause
