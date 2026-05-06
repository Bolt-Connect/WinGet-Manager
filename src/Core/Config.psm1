#Requires -Version 5.1

$Script:ConfigPath   = $null
$Script:Config       = $null

$Script:Defaults = [ordered]@{
    LogDirectory          = 'logs'
    LogLevel              = 'INFO'
    LogRetentionDays      = 30
    MaxLogFileSizeMB      = 10
    WinGetPath            = 'winget'
    DefaultScope          = 'user'
    AutoUpdateCheckOnStart= $true
    ConfirmUninstall      = $true
    ConfirmUpdate         = $false
    SelfUpdateUrl         = 'https://api.github.com/repos/Bolt-Connect/WinGetManager/releases/latest'
    Theme                 = 'Auto'
    Language              = 'nl-NL'
}

function Initialize-Config {
    param([string]$ConfigPath)

    $Script:ConfigPath = $ConfigPath

    if (Test-Path $ConfigPath) {
        try {
            $json = Get-Content $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $merged = [ordered]@{}
            foreach ($key in $Script:Defaults.Keys) {
                $val = $json.$key
                $merged[$key] = if ($null -ne $val) { $val } else { $Script:Defaults[$key] }
            }
            $Script:Config = $merged
        } catch {
            Write-Warning "Config laden mislukt ($ConfigPath): $_  — standaardwaarden gebruikt."
            $Script:Config = $Script:Defaults.Clone()
        }
    } else {
        $Script:Config = $Script:Defaults.Clone()
        Save-Config
    }
}

function Get-AppConfig {
    if (-not $Script:Config) {
        $default = Join-Path $PSScriptRoot '..\..\config\settings.json'
        Initialize-Config -ConfigPath $default
    }
    return $Script:Config
}

function Set-ConfigValue {
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][object]$Value
    )
    $cfg = Get-AppConfig
    $cfg[$Key] = $Value
    Save-Config
}

function Save-Config {
    if (-not $Script:ConfigPath) { return }
    try {
        $dir = Split-Path $Script:ConfigPath
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $Script:Config | ConvertTo-Json -Depth 5 | Set-Content $Script:ConfigPath -Encoding UTF8
    } catch {
        Write-Warning "Config opslaan mislukt: $_"
    }
}

Export-ModuleMember -Function Initialize-Config, Get-AppConfig, Set-ConfigValue, Save-Config

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/dOwSTbghe97DnDnCjvw5kNt
# nLygggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQUcVipekkI1UV+4RYTECoiCVVoZi4wDQYJKoZIhvcNAQEB
# BQAEggEATIwFrbXKVGeI2I0uKxPT+qqLIsymNEmdUmKEUrKr19Y2nxHR5nUYVTf4
# 018AfjKi67MAc1AkCn0WBBtwspuWxML8cCHQieLygtcA4r9HaqaOn7p0jHp9cWKJ
# KrO46PG8Ov0Zj8kJ2LEz599RG8vs8Trr3Hv0OkRbDviS/zevRNjL3zxErZnjc2fL
# X7pA5kbZWl0RUQYw9XypxTYbw68lAKZ685mpF7l6Ai45zTmxO0VFcK4gQuAxrIHR
# l43YmHuFvkve8QZa2IZroqOqvlTk6W7W+iVxrv1YGuql9S3QCFSmOICEJKIsTzgv
# hw8EAGue+qUvfAIZkvlQd+MQTDazsg==
# SIG # End signature block
