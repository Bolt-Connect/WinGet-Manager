# CLAUDE.md

Context voor AI-assistenten (Claude Code, Cursor, GitHub Copilot, etc.) die aan deze repo werken.

## Wat dit project is

WinGet Manager — een lichtgewicht PowerShell + WPF GUI rond Microsoft's `winget` CLI, gebundeld als één enkele `.exe` (~150 KB) via PS2EXE. Dark/light/auto thema, async UI, silent mode voor automatisering, single-file portable + Inno Setup installer.

Doelgroep: persoonlijke Windows-machines, eindgebruikers die WinGet willen beheren via GUI.

## Architectuur

```
WinGetManager.ps1          Entry point voor PS1-mode (dev)
src/
├── Core/
│   ├── Logging.psm1       Schrijft naar bestand + observable voor GUI
│   ├── Config.psm1        Laadt/saved settings.json
│   └── WinGet-Core.psm1   Wrappers rond winget.exe + zelf-update
├── GUI/MainWindow.ps1     WPF interface (XAML in here-string)
└── Silent/WinGet-Silent.ps1   Headless CLI mode

Build-Exe.ps1              Bundelt alles tot één .ps1 + compileert via PS2EXE
└── build/WinGetManager.exe   Eindproduct

installer/WinGetManager.iss  Inno Setup script
.github/workflows/build.yml  CI: bouwt EXE + Setup.exe per release-tag
```

## Build proces

```powershell
.\Build.bat                       # Genereert build/WinGetManager.exe
.\Build-Installer.ps1 -Version x  # Vereist Inno Setup, output in release/
```

Build-Exe.ps1 doet:
1. Read `src/Core/*.psm1` en strip Export-ModuleMember + signature blocks
2. Read `src/GUI/MainWindow.ps1` en `src/Silent/WinGet-Silent.ps1`, strip Import-Module en duplicaat init-code
3. Concateneer alles tot één scriptfile met param-block + ScriptRoot detectie
4. Compileer via `Invoke-PS2EXE` met icoon, versie, etc.

## Belangrijke conventies

### PowerShell 5.1 compatibiliteit (verplicht)
PS2EXE gebruikt Windows PowerShell 5.1, **niet** PowerShell 7. Dus:

- ❌ `$x ?? $y` (null-coalescing)
- ❌ `$x ?: $y` (ternary)
- ❌ `$x?.Property` (null-conditional)
- ✅ `if ($x) { $x } else { $y }`
- ✅ Verb-noun cmdlets, `[System.Type]` casts

### Async pattern voor lange operaties
Gebruik `Start-WinGetWork` (in MainWindow.ps1) voor enkele async winget-calls. Voor bulk-operaties: synchronized hashtable + DispatcherTimer + runspace. Zie `Start-BulkUpdate` als voorbeeld.

**Nooit** synchrone winget-calls op de UI-thread doen — vriest GUI.

### Closures bij event handlers
Variabelen die in een Tick-handler nodig zijn moeten via `.GetNewClosure()` worden vastgelegd, anders ben je afhankelijk van script-scope wat tot null-references leidt bij snelle herhaalde events:

```powershell
$timer.Add_Tick({
    if ($handle.IsCompleted) {  # $handle uit closure
        $timer.Stop()
        ...
    }
}.GetNewClosure())
```

### `$args` is een PowerShell automatic variable
Gebruik nooit `$args` als naam voor je eigen variabele in scriptblocks met `param(...)`. PowerShell reset `$args` automatisch. Gebruik `$cmdArgs`, `$wingetArgs`, etc.

### Theme-systeem
`MainWindow.ps1` heeft een `$Script:Themes` hashtable met Dark/Light palettes. Bij window-load wordt de XAML doorlopen via `Apply-ThemeColors` die hex-codes substitueert. Standaard XAML gebruikt Dark-kleuren (`#1E1E2E` etc).

Voor nieuwe kleuren: voeg een hex toe aan beide palettes, en voeg `'#hexvalue' = $colors.NewKey` toe aan de mapping in `Apply-ThemeColors`.

Hex-kleuren in XAML moeten exact overeenkomen met de keys in de mapping.

### PS2EXE-specifieke gotchas
- `$PSScriptRoot` is leeg in een PS2EXE EXE — gebruik `[System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName` als fallback
- `Write-Host` met `-NoConsole` toont een MessageBox — gebruik `Write-Log` met `-WriteToHost:$false`
- WPF werkt alleen in STA — PS2EXE-compile met `-STA` flag
- Encoding: ASCII-veilige bron, geen box-drawing chars in PS-files (UTF-8 BOM-issues)

### Silent mode integratie
Bundle merget de silent-script-body in de hoofdscript via `Read-Cleaned -StripParam`. Dat strip alles vóór de eerste `if ($Search)` regel — dus de silent-script begint nu altijd met dat als marker. Niet weghalen.

## Self-update

Werkt alleen in EXE-distributie. Stappen:

1. `Get-LatestAppVersion` haalt GitHub Releases API op
2. Vergelijk `[version]$latest -gt [version]$Script:AppVersion`
3. Download `.exe` asset naar `WinGetManager.exe.new`
4. Verifieer PE-header (`Test-PEFile`) en HTTPS+github.com host (`Test-TrustedUpdateUrl`)
5. Schrijf `WinGetManager-Update-*.bat` naar TEMP, spawn die
6. Bat wacht op exit, verplaatst .new → original, herstart

`$Script:AppVersion` in `WinGet-Core.psm1` moet matchen met de release-tag.

## Wat te doen bij een nieuwe feature

1. Maak wijziging in juiste `src/` bestand
2. Run `.\Build.bat` lokaal — output in `build/`
3. Test `build\WinGetManager.exe`
4. Voeg regel toe aan `## [Unreleased]` in `CHANGELOG.md`
5. Commit met conventional commit prefix (`feat:`, `fix:`, `docs:`, `refactor:`)
6. Push — GitHub Actions bouwt artifact

## Wat te doen bij een release

1. Update `$Script:AppVersion` in `src/Core/WinGet-Core.psm1`
2. Update `Version` in `Build-Exe.ps1` (PS2EXE param)
3. Promote `## [Unreleased]` naar `## [x.y.z] - YYYY-MM-DD` in CHANGELOG
4. Voeg nieuwe lege `[Unreleased]` toe
5. Commit + push
6. `git tag -a vx.y.z -m "..."` en `git push origin vx.y.z`
7. GitHub Actions publiceert release met portable + installer + zip

## Wat de gebruiker WIL zien

- Stabiel werkende GUI zonder freezes
- Duidelijke foutmeldingen (geen rauwe exit codes)
- Zo min mogelijk muisklikken voor veelvoorkomende taken
- Theme volgt Windows-voorkeur tenzij anders ingesteld
- Self-update is "magisch" — klik knop, herstart, klaar

## Bekende gotchas / footguns

- DataGrid `IsReadOnly="True"` op de DataGrid maakt ALLE kolommen non-editable, ook checkboxes. Gebruik `IsReadOnly="True"` per `DataGridTextColumn` ipv. op de DataGrid zelf als je checkboxes wilt laten werken.
- WPF StackPanel heeft GEEN `Spacing` property (dat is WinUI). Gebruik `Margin` op de kinderen.
- `Foreground="#CDD6F4"` direct als attribute werkt niet voor theme-substitutie als de hex niet in de mapping staat. Gebruik altijd kleuren uit de palette.

## Roadmap (zie ook README)

- v0.3.0: System tray-icoon, toast-notificaties, package details panel
- v0.4.0: Engelse vertaling (i18n infrastructuur), keyboard shortcuts
- v1.0.0: Microsoft Store distributie ($19), winget-pkgs submit

## Links

- Repo: https://github.com/Bolt-Connect/WinGet-Manager
- WinGet docs: https://learn.microsoft.com/en-us/windows/package-manager/winget/
- PS2EXE: https://github.com/MScholtes/PS2EXE
- Inno Setup: https://jrsoftware.org/isinfo.php
