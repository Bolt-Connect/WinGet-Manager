#Requires -Version 5.1
<#
.SYNOPSIS
    WinGet Manager – silent/headless modus voor automatisering en scripting.

.DESCRIPTION
    Alle WinGet-functies zonder GUI. Geschikt voor Task Scheduler, CI/CD, of één-klik-update.

.EXAMPLE
    # Alle packages updaten (stil, geen bevestiging)
    .\WinGetManager.ps1 -UpdateAll -Silent

    # Specifiek pakket installeren
    .\WinGetManager.ps1 -Install "Mozilla.Firefox"

    # Zoeken
    .\WinGetManager.ps1 -Search "vscode"

    # Lijst geïnstalleerde packages
    .\WinGetManager.ps1 -ListInstalled

    # Export
    .\WinGetManager.ps1 -ExportPath "C:\backup\packages.json"

    # Import
    .\WinGetManager.ps1 -ImportPath "C:\backup\packages.json"
#>

param(
    [switch]$UpdateAll,
    [switch]$Update,
    [string]$PackageId,
    [string]$Install,
    [string]$Uninstall,
    [string]$Search,
    [string]$ExportPath,
    [string]$ImportPath,
    [switch]$ListInstalled,
    [switch]$ListUpdates,
    [switch]$SelfUpdate,
    [switch]$Silent,
    [switch]$Elevated,
    [ValidateSet('user','machine')][string]$Scope = 'user',
    [switch]$IgnoreUnavailable,
    [switch]$NoConfirm,
    [string]$Source
)

$ErrorActionPreference = 'Stop'
$ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent

Import-Module "$ScriptRoot\src\Core\Logging.psm1" -Force
Import-Module "$ScriptRoot\src\Core\Config.psm1"  -Force
Import-Module "$ScriptRoot\src\Core\WinGet-Core.psm1" -Force

$cfg = Get-AppConfig
Initialize-Logging -LogDirectory (Join-Path $ScriptRoot $cfg.LogDirectory) -MinLevel $cfg.LogLevel

try {
    Initialize-WinGetCore -WinGetPath $cfg.WinGetPath
} catch {
    Write-Log $_ -Level ERROR -Source Silent
    exit 1
}

# ---------------------------------------------------------------------------
# Zoeken
# ---------------------------------------------------------------------------

if ($Search) {
    Write-Log "Zoeken: $Search" -Source Silent
    $packages = Search-WinGetPackage -Query $Search -Source $Source
    if ($packages.Count -eq 0) {
        Write-Log "Geen resultaten gevonden voor: $Search" -Source Silent
    } else {
        $packages | Format-Table -AutoSize | Out-String | Write-Host
        Write-Log "$($packages.Count) resultaten gevonden" -Source Silent
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Geïnstalleerde packages
# ---------------------------------------------------------------------------

if ($ListInstalled) {
    Write-Log "Geïnstalleerde packages ophalen" -Source Silent
    $packages = Get-WinGetInstalled -Source $Source
    $packages | Format-Table -AutoSize | Out-String | Write-Host
    Write-Log "Totaal: $($packages.Count) packages" -Source Silent
    exit 0
}

# ---------------------------------------------------------------------------
# Beschikbare updates
# ---------------------------------------------------------------------------

if ($ListUpdates) {
    Write-Log "Beschikbare updates controleren" -Source Silent
    $updates = Get-WinGetUpdates
    if ($updates.Count -eq 0) {
        Write-Log "Alle packages zijn up-to-date." -Source Silent
    } else {
        $updates | Format-Table -AutoSize | Out-String | Write-Host
        Write-Log "$($updates.Count) update(s) beschikbaar" -Source Silent
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Alles updaten
# ---------------------------------------------------------------------------

if ($UpdateAll) {
    Write-Log "Alle packages updaten gestart" -Source Silent

    $onProgress = {
        param($name)
        Write-Log "Updaten: $name" -Source Silent
    }

    $result = Update-AllWinGetPackages -Silent:$Silent -Elevated:$Elevated -OnProgress $onProgress

    Write-Log "Klaar: $($result.Success) geslaagd, $($result.Failed) mislukt" -Source Silent

    $result.Packages | Where-Object { -not $_.Success } | ForEach-Object {
        Write-Log "Mislukt: $($_.Id)" -Level WARN -Source Silent
    }

    exit $(if ($result.Failed -gt 0) { 1 } else { 0 })
}

# ---------------------------------------------------------------------------
# Specifiek package updaten
# ---------------------------------------------------------------------------

if ($Update -and $PackageId) {
    $ok = Update-WinGetPackage -Id $PackageId -Silent:$Silent -Elevated:$Elevated
    exit $(if ($ok) { 0 } else { 1 })
}

# ---------------------------------------------------------------------------
# Installeren
# ---------------------------------------------------------------------------

if ($Install) {
    Write-Log "Installeren: $Install" -Source Silent
    $ok = Install-WinGetPackage -Id $Install -Scope $Scope -Silent:$Silent -Elevated:$Elevated
    exit $(if ($ok) { 0 } else { 1 })
}

# ---------------------------------------------------------------------------
# Verwijderen
# ---------------------------------------------------------------------------

if ($Uninstall) {
    if (-not $NoConfirm -and -not $Silent) {
        $confirm = Read-Host "Weet u zeker dat u '$Uninstall' wilt verwijderen? (j/n)"
        if ($confirm -notmatch '^[jJyY]') {
            Write-Log "Verwijderen geannuleerd" -Source Silent
            exit 0
        }
    }
    $ok = Uninstall-WinGetPackage -Id $Uninstall -Scope $Scope -Silent:$Silent -Elevated:$Elevated
    exit $(if ($ok) { 0 } else { 1 })
}

# ---------------------------------------------------------------------------
# Exporteren
# ---------------------------------------------------------------------------

if ($ExportPath) {
    Write-Log "Exporteren naar: $ExportPath" -Source Silent
    $ok = Export-WinGetPackages -OutputPath $ExportPath
    exit $(if ($ok) { 0 } else { 1 })
}

# ---------------------------------------------------------------------------
# Importeren
# ---------------------------------------------------------------------------

if ($ImportPath) {
    if (-not (Test-Path $ImportPath)) {
        Write-Log "Importbestand niet gevonden: $ImportPath" -Level ERROR -Source Silent
        exit 1
    }
    Write-Log "Importeren van: $ImportPath" -Source Silent
    $ok = Import-WinGetPackages -InputPath $ImportPath -IgnoreUnavailable:$IgnoreUnavailable -Elevated:$Elevated
    exit $(if ($ok) { 0 } else { 1 })
}

# ---------------------------------------------------------------------------
# Zelf-update
# ---------------------------------------------------------------------------

if ($SelfUpdate) {
    Write-Log "Zelf-update controleren" -Source Silent
    $cfg2    = Get-AppConfig
    $updated = Update-App -Url $cfg2.SelfUpdateUrl
    if ($updated) {
        Write-Log "Update toegepast, herstart de app" -Source Silent
    } else {
        Write-Log "Geen update beschikbaar" -Source Silent
    }
    exit 0
}

Write-Host "Gebruik: .\WinGetManager.ps1 -Help voor beschikbare opties"
exit 0

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNgp3L6lbsNCRqRMHBLwVE2iF
# 2LmgggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
# AQsFADAhMR8wHQYDVQQDDBZXaW5HZXRNYW5hZ2VyIExvY2FsRGV2MB4XDTI2MDUw
# NTE2NDgxOVoXDTM2MDUwNTE2NTgxOVowITEfMB0GA1UEAwwWV2luR2V0TWFuYWdl
# ciBMb2NhbERldjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ807LAn
# KDnHe2OML2epBu8NQPQJcoungebjGrM9Sls7qYoaHxPzIwAn5O6NcjyPeBT27nFl
# eQD5HRtffpch5eH8G6weLo/GMmx6z9xWXYEuCqWbzaqcoyYcBTcbwvuz5rOHVxe1
# h4V577zRq5fMxI4oHkneX1/nc36IQznorEvflz86FAw3TwodaT4E7Gw/xH7EQ1MO
# UCwCpsZDdKvZdSrEzgpnFmHqbhjCsOBQLVVoYud0syXosGBQt9JwwaZvp3mQvoJu
# rch0yTuMCIlc46dkecMF4k6xxnXWSifCG+/qqJwYesgRdshr7BqRfXfhJBifREJe
# P6a2k+5RSuScq6kCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMB0GA1UdDgQWBBTB/nzy91KscDO0MblJ8J7M61u28DANBgkqhkiG
# 9w0BAQsFAAOCAQEAUfMEGcqt3OmRMubGOQ7UP9GnMDHV6V74QDFa5Za2hcLCH14s
# J08tg9/3ahctk+0iXuLp/+UOT1pfMPDblQQ7QhLegc9PF0BJH+3DEMr0x7IXnquF
# BSzMgkvAFHUXwGmLOeatJjC1ryMk379hqIIt1eBx6852ye/ID0A3H42Od7v+Y2si
# AFPxSLu8NoLuuhzlsKqdY4lhRZ5vbflD3WGPxC92A747x9uRGCO5QipXSVJVviFL
# D1ZlACyUIRdpH4Ex3x+hfjr7rkJm63KiG9u3S0GYwZ5uU3x3RjA/h6e5F0lscWJa
# blzdQy335fx0Y5i2hoCBRue8IfYWbXy69JWQFDGCAdYwggHSAgEBMDUwITEfMB0G
# A1UEAwwWV2luR2V0TWFuYWdlciBMb2NhbERldgIQERy/5noS0YNDQ+ns6effbDAJ
# BgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAj
# BgkqhkiG9w0BCQQxFgQUXuVk8U6TRos+sb4H4YVWzGpPWiwwDQYJKoZIhvcNAQEB
# BQAEggEAnxbXrbYR/d++zGqkE6cwbLIkXzBmHQucSfH9o441r1dD30XJz8t5kcr2
# m+TPxDzsyvoFYIfA9QnSpDcq/PGPnNZFyIBm4+MOc5Mt8q5wyyo4DX4F4QiGYuv+
# DMy8YwzuyI0+0RbJcEgetlKLQz3nm4B3UShtWdYKKBmb6d0+gt/6H8b9KkP2jTTd
# 8Riwjp155jLylso4Mb0DzTnXNMX0aKjdRM76oFQ3XHd/MK+1CTsP0pl2kCUHayN0
# X8vWgqqr2oO00EYVWrSK6xU6qhiCgUeIedgLw8x4lsKi1+EjZog3pdsaESoL+vgi
# wsKs6n7RDt1TEQ5rqNjWN+3KssHPFw==
# SIG # End signature block
