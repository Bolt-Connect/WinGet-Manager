#Requires -Version 5.1
<#
.SYNOPSIS
    Genereert het WinGet Manager app-icoon op basis van het site-logo
    (monitor met statief, blauw op donkere achtergrond).

.DESCRIPTION
    Rendert het SVG-design van 'assets site/logo-icon.svg' programmatisch
    op 256x256, wrapt in een PNG-in-ICO container.
    Vervang assets/icon.ico door een eigen design als je een ander logo wilt.
#>

$ErrorActionPreference = 'Stop'
$root      = $PSScriptRoot
$assetsDir = Join-Path $root 'assets'
$pngPath   = Join-Path $assetsDir 'icon-256.png'
$icoPath   = Join-Path $assetsDir 'icon.ico'

if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

Add-Type -AssemblyName System.Drawing

# --- 1. PNG renderen (256x256) -------------------------------------------------
Write-Host "Bitmap genereren (256x256)..." -ForegroundColor Cyan

# Schaalfactor t.o.v. SVG viewBox 56x56
$size  = 256
$scale = $size / 56.0

$bitmap = New-Object System.Drawing.Bitmap $size, $size
$g      = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode    = 'AntiAlias'
$g.InterpolationMode= 'HighQualityBicubic'

# Transparante achtergrond: alleen monitor-icoon, geen donker vlak.
# Voordeel: matcht zowel dark als light Windows titelbalken en taakbalk.
$g.Clear([System.Drawing.Color]::Transparent)

# Helper: afgeronde rechthoek tekenen via GraphicsPath
function New-RoundedRect {
    param([float]$x, [float]$y, [float]$w, [float]$h, [float]$r)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x,        $y,        $d, $d, 180, 90)
    $path.AddArc($x+$w-$d,  $y,        $d, $d, 270, 90)
    $path.AddArc($x+$w-$d,  $y+$h-$d,  $d, $d,   0, 90)
    $path.AddArc($x,        $y+$h-$d,  $d, $d,  90, 90)
    $path.CloseFigure()
    return $path
}

# --- Monitor-rechthoek: blauwe outline (#2f81f7) ---
$accentColor = [System.Drawing.Color]::FromArgb(0x2f, 0x81, 0xf7)
$strokeWidth = [int](3 * $scale)
$pen = New-Object System.Drawing.Pen $accentColor, $strokeWidth
$pen.LineJoin    = 'Round'
$pen.StartCap    = 'Round'
$pen.EndCap      = 'Round'

# Monitor body: x=5 y=8 w=46 h=30 rx=4 (in SVG-coordinaten)
$mx = [int](5  * $scale)
$my = [int](8  * $scale)
$mw = [int](46 * $scale)
$mh = [int](30 * $scale)
$mr = [int](4  * $scale)
$monitorPath = New-RoundedRect $mx $my $mw $mh $mr
$g.DrawPath($pen, $monitorPath)

# --- Statief (verticale lijn) ---
# SVG: x1=28 y1=38 x2=28 y2=48
$g.DrawLine($pen, [int](28*$scale), [int](38*$scale), [int](28*$scale), [int](48*$scale))

# --- Voet (horizontale lijn) ---
# SVG: x1=18 y1=48 x2=38 y2=48
$g.DrawLine($pen, [int](18*$scale), [int](48*$scale), [int](38*$scale), [int](48*$scale))

# Cleanup
$pen.Dispose()
$monitorPath.Dispose()
$g.Dispose()

# Save PNG
$bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "  PNG: $pngPath" -ForegroundColor Green

# --- 2. ICO genereren (PNG-in-ICO, Vista+) ----------------------------------
Write-Host "ICO container bouwen..." -ForegroundColor Cyan
$pngBytes = [System.IO.File]::ReadAllBytes($pngPath)

$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms

# ICONDIR header
$bw.Write([uint16]0)                    # Reserved
$bw.Write([uint16]1)                    # Type: 1 = ICO
$bw.Write([uint16]1)                    # 1 image

# ICONDIRENTRY
$bw.Write([byte]0)                      # Width (0 = 256)
$bw.Write([byte]0)                      # Height (0 = 256)
$bw.Write([byte]0)                      # Palette colors
$bw.Write([byte]0)                      # Reserved
$bw.Write([uint16]1)                    # Color planes
$bw.Write([uint16]32)                   # Bits per pixel
$bw.Write([uint32]$pngBytes.Length)     # Bytes
$bw.Write([uint32]22)                   # Offset (header is 22 bytes)

# PNG payload
$bw.Write($pngBytes)
$bw.Flush()

[System.IO.File]::WriteAllBytes($icoPath, $ms.ToArray())
$bw.Dispose()
$ms.Dispose()
$bitmap.Dispose()

$icoSize = (Get-Item $icoPath).Length
Write-Host "  ICO: $icoPath ($icoSize bytes)" -ForegroundColor Green
Write-Host ""
Write-Host "Klaar! Run Build.bat zodat de exe het nieuwe icoon krijgt." -ForegroundColor Yellow
