@echo off
echo Opstarttest WinGet Manager...
echo.
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -Command ^
  "try { & '%~dp0WinGetManager.ps1' } catch { Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show($_.Exception.Message + \"`n`n\" + $_.ScriptStackTrace, 'Opstartfout', 'OK', 'Error') }"
echo.
echo Script beeindigd. Druk op een toets om te sluiten.
pause
