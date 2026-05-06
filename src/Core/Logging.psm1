#Requires -Version 5.1

$Script:LogPath       = $null
$Script:MinLogLevel   = 'INFO'
$Script:LogObservable = $null   # System.Collections.ObjectModel.ObservableCollection[object] - set by GUI
$Script:WriteToHost   = $false  # In PS2EXE -NoConsole wordt Write-Host een MessageBox - standaard uit

$Script:LevelOrder = @{ DEBUG = 0; INFO = 1; WARN = 2; ERROR = 3 }
$Script:LevelColor = @{ DEBUG = 'Gray'; INFO = 'Cyan'; WARN = 'Yellow'; ERROR = 'Red' }

function Initialize-Logging {
    param(
        [Parameter(Mandatory)][string]$LogDirectory,
        [ValidateSet('DEBUG','INFO','WARN','ERROR')][string]$MinLevel = 'INFO',
        [int]$RetentionDays  = 30,
        [int]$MaxSizeMB      = 10,
        [switch]$WriteToHost
    )

    $Script:WriteToHost = [bool]$WriteToHost

    if (-not [System.IO.Path]::IsPathRooted($LogDirectory)) {
        $LogDirectory = Join-Path $PSScriptRoot "..\..\$LogDirectory"
    }
    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }

    $Script:MinLogLevel = $MinLevel
    $Script:LogPath     = Join-Path $LogDirectory "WinGetManager_$(Get-Date -Format 'yyyy-MM-dd').log"

    # Rotation: verwijder oude logs
    Get-ChildItem $LogDirectory -Filter 'WinGetManager_*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays) } |
        Remove-Item -Force

    # Rotate als huidig bestand te groot is
    if (Test-Path $Script:LogPath) {
        $sizeMB = (Get-Item $Script:LogPath).Length / 1MB
        if ($sizeMB -ge $MaxSizeMB) {
            $archive = $Script:LogPath -replace '\.log$', "_$(Get-Date -Format 'HHmmss').log"
            Rename-Item $Script:LogPath $archive
        }
    }
}

function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('DEBUG','INFO','WARN','ERROR')][string]$Level  = 'INFO',
        [string]$Source = 'System'
    )

    if ($Script:LevelOrder[$Level] -lt $Script:LevelOrder[$Script:MinLogLevel]) { return }

    $ts    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
    $entry = "[$ts] [$($Level.PadRight(5))] [$Source] $Message"

    if ($Script:LogPath) {
        try { Add-Content -Path $Script:LogPath -Value $entry -Encoding UTF8 }
        catch { <# schrijf-fout negeren zodat app blijft draaien #> }
    }

    if ($Script:WriteToHost) {
        try { Write-Host $entry -ForegroundColor $Script:LevelColor[$Level] } catch {}
    }

    if ($Script:LogObservable -ne $null) {
        $row = [PSCustomObject]@{
            Timestamp = $ts
            Level     = $Level
            Source    = $Source
            Message   = $Message
        }
        try {
            if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -eq 'STA') {
                $Script:LogObservable.Add($row)
            } else {
                $Script:LogObservable.Dispatcher.Invoke([action]{ $Script:LogObservable.Add($row) })
            }
        } catch { <# UI kan al gesloten zijn #> }
    }
}

function Set-LogObservable {
    param([object]$Collection)
    $Script:LogObservable = $Collection
}

function Get-LogPath { $Script:LogPath }

Export-ModuleMember -Function Initialize-Logging, Write-Log, Set-LogObservable, Get-LogPath

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH50xZSBKI3V0h/LKtQEFxrxe
# tYygggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQUjYGD31ITgx/eK88dGEu4ru0NI04wDQYJKoZIhvcNAQEB
# BQAEggEAPgjQYhpUfKcf0LRBK0gLsEfYSWLvMQyAxupUjA+azJOqMd5SJIBXNwMK
# PTzai0U7kBhSMVCYVL3yMVnOZtsuUh6VnrVof4DC4NcOKy+5KCAiiXq5Clx1eYwv
# 2Fa0nwc+FIzzjI9AZ6wY381V5aeJMuSF5smjaJZFmW4HZjwBCopSKfGFTgxIyNsY
# K4VpEeTt/HwHcr7YJt7zGlHoeHCSOFAuM/S0Jk5xqWmlJKSrSCU8+5/FoHSPpmnl
# xKGxSJN3hVvWdMupLL6TqAbzbhGre7p8B/MqxqBcVYuX/08JTYK7Bp1Ze6sof2YY
# 3YYsRMkyF7DK6iS02rqMOT+LB5wy/Q==
# SIG # End signature block
