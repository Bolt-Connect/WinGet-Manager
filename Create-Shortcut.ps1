#Requires -Version 5.1
<#
    Maakt een snelkoppeling op het bureaublad die de GUI start zonder terminal.
    Eenmalig uitvoeren via rechtsklik > Uitvoeren met PowerShell
#>

$appPath  = Join-Path $PSScriptRoot 'WinGetManager.ps1'
$desktop  = [Environment]::GetFolderPath('Desktop')
$lnkPath  = Join-Path $desktop 'WinGet Manager.lnk'

$shell    = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnkPath)

$shortcut.TargetPath       = 'powershell.exe'
$shortcut.Arguments        = "-NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$appPath`""
$shortcut.WorkingDirectory = $PSScriptRoot
$shortcut.WindowStyle      = 1    # 1 = normaal venster voor WPF; console blijft verborgen
$shortcut.Description      = 'WinGet Manager – package beheer'

# Optioneel: gebruik het PowerShell-icoon
$shortcut.IconLocation = 'powershell.exe,0'

$shortcut.Save()

Write-Host ""
Write-Host "Snelkoppeling aangemaakt op het bureaublad:" -ForegroundColor Green
Write-Host "  $lnkPath"
Write-Host ""
Write-Host "Dubbelklik op 'WinGet Manager' om de app te starten."
Write-Host ""

# Kleine pauze zodat de gebruiker het bericht kan lezen
Start-Sleep -Seconds 3

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXDQ37639v5uNvq3g+SShlcjS
# 8b2gggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQUkm1OuVJPaAgoHjv/+OuZ1DYWlskwDQYJKoZIhvcNAQEB
# BQAEggEARwpTQkglfe2UHqUWyL01Ei1ycWyoCtn6Bq0dE6U+bHS6pNd3jSlWqMuV
# h/8d40rspEXtxoBmmHD/SZM5ndVjw1fwFTe7Gz0APojY22Ma6FepSBzlmrW3qjCV
# Lg6X84IlWHhar860jfj19unO6OLQYgiSYN+d8dssKwDoHqjUq8iDP5WPFLP1aHF+
# XAYoRMQYOoyxs9eWv3Yj0auzbFqC4JKIcyWjAko5qqHX+twpvnmYnecaJ6NUD3Wu
# e6eP1AO03rvuaN5mPXZNuzcpUZg3meZrez9x0sCI1IOFwFTWq86B94mrC89r6iew
# QWhuITq/TZLr31cKKrFQY2X+9TNzKQ==
# SIG # End signature block
