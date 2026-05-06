Set oShell = CreateObject("WScript.Shell")
Set oFSO   = CreateObject("Scripting.FileSystemObject")
strDir = oFSO.GetParentFolderName(WScript.ScriptFullName)
strCmd = "powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & strDir & "\WinGetManager.ps1"""
oShell.Run strCmd, 0, False
