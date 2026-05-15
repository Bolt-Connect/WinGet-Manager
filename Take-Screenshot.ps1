#Requires -Version 5.1
<#
    Capture screenshot van de WinGet Manager applicatie en sla op in assets/screenshots/.
    Veronderstelt dat de app al draait (start anders 'build\WinGetManager.exe' eerst).
#>
param(
    [string]$OutputName = 'Screenshot-v0.2.5.png'
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinApi {
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int n);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
"@

$proc = Get-Process -Name 'WinGetManager' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proc) {
    Write-Host "Geen WinGetManager-process gevonden. Start build\WinGetManager.exe eerst." -ForegroundColor Red
    exit 1
}

$h = $proc.MainWindowHandle
if ($h -eq [IntPtr]::Zero) {
    Write-Host "Process gevonden maar geen window handle (nog niet zichtbaar?)" -ForegroundColor Red
    exit 1
}

[WinApi]::ShowWindow($h, 9) | Out-Null
Start-Sleep -Milliseconds 600
[WinApi]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 1000

$r = New-Object WinApi+RECT
[WinApi]::GetWindowRect($h, [ref]$r) | Out-Null
$w  = $r.Right - $r.Left
$ht = $r.Bottom - $r.Top
Write-Host ("Window bounds: ({0},{1}) {2}x{3}" -f $r.Left, $r.Top, $w, $ht)

$bmp = New-Object System.Drawing.Bitmap $w, $ht
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($r.Left, $r.Top, 0, 0, (New-Object System.Drawing.Size $w, $ht))
$g.Dispose()

$outDir = Join-Path $PSScriptRoot 'assets\screenshots'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$out = Join-Path $outDir $OutputName
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

$size = [math]::Round((Get-Item $out).Length / 1KB, 1)
Write-Host "Saved: $out ($size KB)" -ForegroundColor Green
