param([string]$AppPath = $PSScriptRoot)
<#
    Intern setup-script — wordt aangeroepen door Start-GUI.bat.
    Maakt een zelfondertekend cert, vertrouwt het, en ondertekent alle scripts.
#>

$AppPath = $AppPath.TrimEnd('\').TrimEnd('/')
$logFile = Join-Path $AppPath 'setup.log'
$marker  = Join-Path $AppPath '.setup-state.json'

# Start volledige transcript zodat we elke stap kunnen terugzien
try { Stop-Transcript | Out-Null } catch {}
Start-Transcript -Path $logFile -Force | Out-Null

$exitCode = 1
try {
    Write-Host ""
    Write-Host "=========================================="
    Write-Host " WinGet Manager - eenmalige installatie"
    Write-Host "=========================================="
    Write-Host "Tijd:    $(Get-Date)"
    Write-Host "App pad: $AppPath"
    Write-Host "Gebruiker: $env:USERNAME"
    Write-Host "Admin:   $((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"
    Write-Host ""

    if (-not (Test-Path $AppPath)) {
        throw "App-map bestaat niet: $AppPath"
    }

    # ── Stap 1: Bestanden deblokkeren ──────────────────────────────────────────
    Write-Host "[1/4] Bestanden deblokkeren (Zone.Identifier verwijderen)..."
    Get-ChildItem -Path $AppPath -Recurse -Include "*.ps1","*.psm1","*.bat","*.vbs" -ErrorAction SilentlyContinue |
        Unblock-File -ErrorAction SilentlyContinue
    Write-Host "      OK"

    # ── Stap 2: Code-signing certificaat ───────────────────────────────────────
    Write-Host "[2/4] Code-signing certificaat..."
    $certName = "WinGetManager LocalDev"

    $existing = Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue |
        Where-Object { $_.Subject -eq "CN=$certName" -and $_.NotAfter -gt (Get-Date) } |
        Select-Object -First 1

    if ($existing) {
        $cert = $existing
        Write-Host "      Hergebruik bestaand certificaat: $($cert.Thumbprint)"
    } else {
        # Verwijder eventueel verlopen oude certs
        Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue |
            Where-Object { $_.Subject -eq "CN=$certName" } |
            Remove-Item -Force -ErrorAction SilentlyContinue

        $cert = New-SelfSignedCertificate `
            -Subject           "CN=$certName" `
            -CertStoreLocation "Cert:\CurrentUser\My" `
            -KeyUsage          DigitalSignature `
            -Type              CodeSigningCert `
            -NotAfter          (Get-Date).AddYears(10)
        Write-Host "      Nieuw certificaat aangemaakt: $($cert.Thumbprint)"
    }

    # ── Stap 3: Cert vertrouwen op machine-niveau ─────────────────────────────
    Write-Host "[3/4] Certificaat vertrouwen (TrustedPublisher + Root, LocalMachine)..."
    foreach ($storeName in @("TrustedPublisher", "Root")) {
        $store = [System.Security.Cryptography.X509Certificates.X509Store]::new($storeName, "LocalMachine")
        $store.Open("ReadWrite")
        $present = $store.Certificates | Where-Object { $_.Thumbprint -eq $cert.Thumbprint }
        if (-not $present) {
            $store.Add($cert)
            Write-Host "      Toegevoegd aan $storeName"
        } else {
            Write-Host "      Al aanwezig in $storeName"
        }
        $store.Close()
    }

    # ── Stap 4: Alle scripts ondertekenen ──────────────────────────────────────
    Write-Host "[4/4] Scripts ondertekenen..."
    $scripts = Get-ChildItem -Path $AppPath -Recurse -Include "*.ps1","*.psm1"
    $ok = 0; $fail = 0
    foreach ($file in $scripts) {
        try {
            $sig = Set-AuthenticodeSignature -FilePath $file.FullName -Certificate $cert -ErrorAction Stop
            if ($sig.Status -eq 'Valid') {
                Write-Host "      OK   $($file.FullName.Substring($AppPath.Length))"
                $ok++
            } else {
                Write-Host "      WARN $($file.Name) - status: $($sig.Status) - $($sig.StatusMessage)"
                $fail++
            }
        } catch {
            Write-Host "      FAIL $($file.Name) - $_"
            $fail++
        }
    }

    # ── ExecutionPolicy ────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "ExecutionPolicy CurrentUser -> AllSigned"
    Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope CurrentUser -Force

    # ── Verificatie ────────────────────────────────────────────────────────────
    $main   = Join-Path $AppPath 'WinGetManager.ps1'
    $verify = Get-AuthenticodeSignature $main
    Write-Host ""
    Write-Host "Eindcontrole WinGetManager.ps1: $($verify.Status)"
    if ($verify.StatusMessage) { Write-Host "  Bericht: $($verify.StatusMessage)" }

    # Marker-bestand met resultaat
    @{
        Thumbprint = $cert.Thumbprint
        Date       = (Get-Date).ToString('o')
        ScriptsOK  = $ok
        ScriptsFail= $fail
        Verify     = $verify.Status.ToString()
    } | ConvertTo-Json | Set-Content -Path $marker -Encoding UTF8

    Write-Host ""
    Write-Host "Resultaat: $ok geslaagd, $fail mislukt, eindstatus: $($verify.Status)"

    if ($verify.Status -eq 'Valid') {
        Write-Host "KLAAR - app is nu vertrouwd." -ForegroundColor Green
        $exitCode = 0
    } else {
        Write-Host "WAARSCHUWING - signature-controle gaf '$($verify.Status)'" -ForegroundColor Yellow
        $exitCode = 2
    }
} catch {
    Write-Host ""
    Write-Host "FOUT TIJDENS SETUP:"
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
    $exitCode = 1
}

try { Stop-Transcript | Out-Null } catch {}
Start-Sleep -Seconds 2
exit $exitCode

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+PWLoyLMOZEpk2uhfLO/OI3W
# 2NigggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQUaPq+MTL8N0HeNcHvtl5mM/nK1kMwDQYJKoZIhvcNAQEB
# BQAEggEAZpEhaJms4NBFpxNsCwo8O9QexgR+j+zrWWaS3/lb7xb9h7Px98ysXT6+
# HRv6pYtWHEz4SFCpesdB7OMMs953PPRAqi3hRSy2alnxBJOIzWJFFtnP9FIiaINn
# ho38cL354MwvH94WstB3XN+QrDsYZcCBWg9K+lSJi9AjSpsHHCKcnEEm84OgmDmy
# eMqI9LATiDk/spKifz6zn3uqmudbqwWz/C2JmVwKrunn4JY4AGme63S/ce6RyuPX
# OFdbxINZIFTOpBcm6XNYS2lR/+OfTE6G82Bo0LOY0nmhQHv0iLYFh2LRvqdZy8CC
# DyyRAzU0az/bjLyHA9pjdZlxS3rM5Q==
# SIG # End signature block
