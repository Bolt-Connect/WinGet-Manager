#Requires -Version 5.1
<#
.SYNOPSIS
    WinGet Manager – grafische én stille beheertool voor WinGet packages.

.DESCRIPTION
    Start zonder parameters: opent de WPF-GUI.
    Start met -UpdateAll, -Install, -Search, etc.: werkt headless voor automatisering.

.EXAMPLE
    # GUI openen
    .\WinGetManager.ps1

    # Alle packages stil updaten (bijv. via Task Scheduler)
    .\WinGetManager.ps1 -UpdateAll -Silent

    # Specifiek pakket installeren
    .\WinGetManager.ps1 -Install "Mozilla.Firefox"

    # Backup van geïnstalleerde packages
    .\WinGetManager.ps1 -ExportPath "C:\backup\packages.json"

    # App zelf updaten
    .\WinGetManager.ps1 -SelfUpdate
#>

[CmdletBinding(DefaultParameterSetName = 'GUI')]
param(
    # ── Silent-modus parameters ─────────────────────────────────────────────
    [Parameter(ParameterSetName = 'Silent')][switch]$UpdateAll,
    [Parameter(ParameterSetName = 'Silent')][switch]$Update,
    [Parameter(ParameterSetName = 'Silent')][string]$PackageId,
    [Parameter(ParameterSetName = 'Silent')][string]$Install,
    [Parameter(ParameterSetName = 'Silent')][string]$Uninstall,
    [Parameter(ParameterSetName = 'Silent')][string]$Search,
    [Parameter(ParameterSetName = 'Silent')][string]$ExportPath,
    [Parameter(ParameterSetName = 'Silent')][string]$ImportPath,
    [Parameter(ParameterSetName = 'Silent')][switch]$ListInstalled,
    [Parameter(ParameterSetName = 'Silent')][switch]$ListUpdates,
    [Parameter(ParameterSetName = 'Silent')][switch]$SelfUpdate,
    [Parameter(ParameterSetName = 'Silent')][switch]$Silent,
    [Parameter(ParameterSetName = 'Silent')][switch]$Elevated,
    [Parameter(ParameterSetName = 'Silent')]
    [ValidateSet('user','machine')][string]$Scope = 'user',
    [Parameter(ParameterSetName = 'Silent')][switch]$IgnoreUnavailable,
    [Parameter(ParameterSetName = 'Silent')][switch]$NoConfirm,
    [Parameter(ParameterSetName = 'Silent')][string]$Source,

    # ── Gedeelde parameters ─────────────────────────────────────────────────
    [ValidateSet('DEBUG','INFO','WARN','ERROR')][string]$LogLevel,
    [string]$LogPath
)

$ErrorActionPreference = 'Stop'
$ScriptRoot = $PSScriptRoot

# Bepaal of we in silent-modus draaien (geen enkele GUI-parameter opgegeven)
$IsSilent = $PSCmdlet.ParameterSetName -eq 'Silent'

# Logging-niveau: CLI-parameter wint van config
if (-not $LogLevel) { $LogLevel = 'INFO' }

if ($IsSilent) {
    # ── Headless modus ───────────────────────────────────────────────────────
    $silentParams = @{}
    if ($UpdateAll)          { $silentParams.UpdateAll   = $true }
    if ($Update)             { $silentParams.Update      = $true }
    if ($PackageId)          { $silentParams.PackageId   = $PackageId }
    if ($Install)            { $silentParams.Install     = $Install }
    if ($Uninstall)          { $silentParams.Uninstall   = $Uninstall }
    if ($Search)             { $silentParams.Search      = $Search }
    if ($ExportPath)         { $silentParams.ExportPath  = $ExportPath }
    if ($ImportPath)         { $silentParams.ImportPath  = $ImportPath }
    if ($ListInstalled)      { $silentParams.ListInstalled = $true }
    if ($ListUpdates)        { $silentParams.ListUpdates = $true }
    if ($SelfUpdate)         { $silentParams.SelfUpdate  = $true }
    if ($Silent)             { $silentParams.Silent      = $true }
    if ($Elevated)           { $silentParams.Elevated    = $true }
    if ($Scope)              { $silentParams.Scope       = $Scope }
    if ($IgnoreUnavailable)  { $silentParams.IgnoreUnavailable = $true }
    if ($NoConfirm)          { $silentParams.NoConfirm   = $true }
    if ($Source)             { $silentParams.Source      = $Source }
    if ($LogLevel)           { $silentParams.LogLevel    = $LogLevel }
    if ($LogPath)            { $silentParams.LogPath     = $LogPath }

    & "$ScriptRoot\src\Silent\WinGet-Silent.ps1" @silentParams
} else {
    # ── GUI modus ─────────────────────────────────────────────────────────────
    # STA-thread vereist voor WPF
    if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName  = 'powershell.exe'
        $psi.Arguments = "-NoProfile -STA -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $psi.UseShellExecute = $false
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } else {
        & "$ScriptRoot\src\GUI\MainWindow.ps1"
    }
}

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8tik3V1v8YfjVYgp5EouJtq4
# 7E2gggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQULf6B7LNaJzBqMihl8/LY91StIUwwDQYJKoZIhvcNAQEB
# BQAEggEAbkYHJJM4nWuDcrXFhSViAL9+7VGAVWeyNXvyox622tq8RAyjMjiLLFtW
# 6raELRLnxc2Hms51Zpyi5+NpYvoyao7VkdRMbfk/XBFu0iIAwKF1tmLxa6Ww8zAe
# 22oraIy32khFq9DhVGI+coF1AJ9v3TtRqIMUU6r4FYyVneDAj2aMjVOhuAmicVow
# 98thmwphjs8LsJLDKMRNkuCMHFwmKQsttQRiR6OeKohBHI008+xYFpeShekv05P2
# Cr0u6/dDdIJgTqriLvjJhD9oJYHLqncnmxKMt+4N9lLhL4NyS2vkRocO84uVHNhf
# VXEe/nZnKGWGRdmuxgwuTXvOHIvkPw==
# SIG # End signature block
