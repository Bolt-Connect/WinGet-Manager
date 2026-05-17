#Requires -Version 5.1
<#
    Capture screenshot van WinGet Manager met de Geinstalleerd-tab actief.
    Vereist dat de app al draait.
#>

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
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
if (-not $proc -or $proc.MainWindowHandle -eq [IntPtr]::Zero) {
    Write-Host "Geen WinGetManager-window" -ForegroundColor Red
    exit 1
}

[WinApi]::ShowWindow($proc.MainWindowHandle, 9) | Out-Null
Start-Sleep -Milliseconds 500
[WinApi]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
Start-Sleep -Milliseconds 800

# UI Automation: vind de Geinstalleerd TabItem en selecteer hem
$root  = [System.Windows.Automation.AutomationElement]::FromHandle($proc.MainWindowHandle)
$tabItemControl = [System.Windows.Automation.ControlType]::TabItem

$descendants = $root.FindAll(
    [System.Windows.Automation.TreeScope]::Descendants,
    (New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        $tabItemControl)))

$target = $null
foreach ($t in $descendants) {
    $name = $t.Current.Name
    if ($name -match 'Geïnstalleerd|Geinstalleerd|Installed') {
        $target = $t
        break
    }
}

if ($target) {
    Write-Host "Tab gevonden: $($target.Current.Name)"
    $pattern = $target.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
    $pattern.Select()
    Start-Sleep -Seconds 2
    Write-Host "Geinstalleerd-tab geselecteerd"
} else {
    Write-Host "Tab niet gevonden via UIA, beschikbare tabs:"
    foreach ($t in $descendants) { Write-Host " - $($t.Current.Name)" }
}

# Screenshot
$r = New-Object WinApi+RECT
[WinApi]::GetWindowRect($proc.MainWindowHandle, [ref]$r) | Out-Null
$w  = $r.Right - $r.Left
$ht = $r.Bottom - $r.Top
Write-Host ("Window: ({0},{1}) {2}x{3}" -f $r.Left, $r.Top, $w, $ht)

$bmp = New-Object System.Drawing.Bitmap $w, $ht
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($r.Left, $r.Top, 0, 0, (New-Object System.Drawing.Size $w, $ht))
$g.Dispose()

$outDir = Join-Path $PSScriptRoot 'assets\screenshots'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$out = Join-Path $outDir 'v0.3-installed-dark.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Saved: $out ($([math]::Round((Get-Item $out).Length / 1KB, 1)) KB)" -ForegroundColor Green
