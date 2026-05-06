#Requires -Version 5.1
<#
.SYNOPSIS
    Genereert een placeholder app-icoon als assets/icon.ico.

.DESCRIPTION
    Maakt een 256x256 PNG met een download-pijl op donkerblauwe achtergrond,
    en wrapt die in een ICO-container die door Windows wordt herkend.
    Vervang assets/icon.ico later door een eigen ontwerp.
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

# --- 1. PNG maken (256x256) -------------------------------------------------
Write-Host "Bitmap genereren (256x256)..." -ForegroundColor Cyan
$size   = 256
$bitmap = New-Object System.Drawing.Bitmap $size, $size
$g      = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode    = 'AntiAlias'
$g.InterpolationMode= 'HighQualityBicubic'
$g.TextRenderingHint= 'AntiAliasGridFit'

# Achtergrond: gradient blauw
$bgRect = New-Object System.Drawing.Rectangle 0,0,$size,$size
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $bgRect,
    ([System.Drawing.Color]::FromArgb(137, 180, 250)),
    ([System.Drawing.Color]::FromArgb(116, 199, 236)), 45
$g.FillRectangle($bgBrush, $bgRect)

# Afgeronde hoeken simuleren met een rechthoek met radius
# (volledige rechthoek werkt ook prima voor een ico)

# Witte download-pijl in het midden
$arrowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(30, 30, 46))

# Pijl: schacht (rechthoek) + driehoekige punt
$shaft = New-Object System.Drawing.Rectangle 100, 60, 56, 90
$g.FillRectangle($arrowBrush, $shaft)

$arrowPoints = @(
    (New-Object System.Drawing.PointF 64, 140),
    (New-Object System.Drawing.PointF 192, 140),
    (New-Object System.Drawing.PointF 128, 200)
)
$g.FillPolygon($arrowBrush, $arrowPoints)

# Doos-streep onderaan (dock/baseline)
$dock = New-Object System.Drawing.Rectangle 50, 215, 156, 14
$g.FillRectangle($arrowBrush, $dock)

# Kleine accentlijn boven pijl
$accent = New-Object System.Drawing.Rectangle 100, 38, 56, 14
$g.FillRectangle($arrowBrush, $accent)

# Cleanup
$bgBrush.Dispose()
$arrowBrush.Dispose()
$g.Dispose()

# Sla PNG op
$bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "  PNG opgeslagen: $pngPath" -ForegroundColor Green

# --- 2. ICO genereren (PNG-in-ICO formaat, Vista+) -------------------------
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
Write-Host "  ICO opgeslagen: $icoPath ($icoSize bytes)" -ForegroundColor Green
Write-Host ""
Write-Host "Klaar! Bouw nu opnieuw met Build.bat zodat de exe het icoon krijgt." -ForegroundColor Yellow
