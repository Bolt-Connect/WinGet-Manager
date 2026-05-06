#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Registreert een geplande taak die dagelijks alle WinGet-packages automatisch updatet.

.PARAMETER Time
    Tijdstip voor de dagelijkse update. Standaard: 03:00

.PARAMETER Uninstall
    Verwijdert de geplande taak in plaats van te installeren.

.EXAMPLE
    .\Install-ScheduledUpdate.ps1
    .\Install-ScheduledUpdate.ps1 -Time "02:30"
    .\Install-ScheduledUpdate.ps1 -Uninstall
#>

param(
    [string]$Time      = '03:00',
    [switch]$Uninstall
)

$TaskName        = 'WinGetManager-AutoUpdate'
$TaskDescription = 'WinGet Manager: dagelijkse automatische package-updates'
$ScriptPath      = Join-Path $PSScriptRoot 'WinGetManager.ps1'

if ($Uninstall) {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "✓ Geplande taak '$TaskName' verwijderd." -ForegroundColor Green
    } else {
        Write-Host "Taak '$TaskName' bestaat niet." -ForegroundColor Yellow
    }
    exit 0
}

$action  = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$ScriptPath`" -UpdateAll -Silent"

$trigger = New-ScheduledTaskTrigger -Daily -At $Time

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2) `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -MultipleInstances IgnoreNew

$principal = New-ScheduledTaskPrincipal `
    -UserId 'SYSTEM' `
    -LogonType ServiceAccount `
    -RunLevel Highest

$task = New-ScheduledTask `
    -Action   $action `
    -Trigger  $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description $TaskDescription

Register-ScheduledTask -TaskName $TaskName -InputObject $task -Force | Out-Null

Write-Host ""
Write-Host "✓ Geplande taak geregistreerd:" -ForegroundColor Green
Write-Host "  Naam:      $TaskName"
Write-Host "  Tijdstip:  Dagelijks om $Time"
Write-Host "  Script:    $ScriptPath"
Write-Host "  Logboek:   Zie de logs\ map in de app-directory"
Write-Host ""
Write-Host "Handmatig starten:"
Write-Host "  Start-ScheduledTask -TaskName '$TaskName'"
Write-Host ""
Write-Host "Verwijderen:"
Write-Host "  .\Install-ScheduledUpdate.ps1 -Uninstall"

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqRhXII9UvBIO3Zn5S8i75uKg
# A6WgggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQU0P6Kt3ZIQJO0TC+fSfs+YG6qq3UwDQYJKoZIhvcNAQEB
# BQAEggEAMgUKRV1EoJ2WHwWGArzXkVGp9EqCZmBZkj7roZWTDBtY9Q7V+XBZFmu7
# biUmXYxsdzTUcqMSWAP8YTYFNob6nxr3bcegNTCLpd33ZJdSsg/b3Ff1SL7kOxIK
# INsvOOhmbzGeE9TEMBugf1pWYe6awsA9632wH3BRW2T+iNaJQ5EwBviYZcMi3Ebc
# V35r2ndybNtfaPaNyJkRMZMPz1WhvnuK7NBfJrBv3cGZ1ggR0RZoBHO28QptSHYX
# 68E1tLxKCa2LGixKCthRgL7MfNe9UgZSccNlIU0ENrXhy0pWBnmYWV0ukVFdlInC
# qdIAY3XIfeG/yaFQ+OFdYj0WONxDEw==
# SIG # End signature block
