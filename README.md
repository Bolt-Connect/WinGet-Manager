# WinGet Manager

Lichtgewicht GUI voor Windows Package Manager (`winget`) met dark-theme interface en silent mode voor automatisering. Geschreven in PowerShell + WPF, gecompileerd naar één enkele `.exe`.

![Status](https://img.shields.io/badge/status-alpha-orange)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/windows-10%2B-0078D6)

---

## Features

- **Zoeken** — alle packages in winget-bronnen doorzoeken
- **Geïnstalleerd beheren** — versies + update-status in één overzicht
- **Updaten** — alle of geselecteerde packages, met progress feedback
- **Importeren / Exporteren** — JSON-backup van geïnstalleerde packages
- **Bronnen beheren** — winget sources toevoegen / verwijderen / resetten
- **Silent mode** — alle functies headless beschikbaar voor Task Scheduler
- **Logging** — uitgebreide logs per dag met live GUI-panel
- **Async UI** — installer / updater bevriest de GUI niet meer

## Screenshots

| Zoeken | Geïnstalleerd | Updates |
|--------|---------------|---------|
| ![Search](assets/screenshots/01-search.png) | ![Installed](assets/screenshots/02-installed.png) | ![Updates](assets/screenshots/03-updates.png) |

| Import/Export | Instellingen | Light thema |
|---------------|--------------|-------------|
| ![Import/Export](assets/screenshots/04-import-export.png) | ![Settings](assets/screenshots/05-settings.png) | ![Light](assets/screenshots/06-light-theme.png) |

## Installatie

### Optie 1 — Setup installer (aanbevolen)

Download `WinGetManager-Setup-x.y.z.exe` van de [Releases-pagina](../../releases) en doorloop de wizard. De installer:

- Plaatst de app in `Program Files\WinGetManager\` of in een andere gekozen locatie
- Maakt een Start-menu en (optioneel) bureaublad-snelkoppeling
- Optioneel een dagelijkse Task Scheduler voor auto-update
- Verschijnt netjes in **Configuratiescherm → Programma's** met uninstaller

### Optie 2 — Portable

1. Download `WinGetManager.exe` (alleenstaand bestand) van de [Releases-pagina](../../releases)
2. Plaats in een map naar keuze
3. Dubbelklik — config en logs worden automatisch naast de exe aangemaakt

Voor offline-distributie kan ook de portable zip (`WinGetManager-vX.Y.Z-portable.zip`) gebruikt worden.

### Optie 3 — Vanuit source bouwen

```powershell
git clone https://github.com/Bolt-Connect/WinGetManager.git
cd WinGetManager
.\Build.bat                              # bouwt build\WinGetManager.exe
.\Build-Installer.ps1 -Version 0.1.0     # optioneel: maakt release\WinGetManager-Setup-0.1.0.exe
```

Voor de installer is [Inno Setup 6](https://jrsoftware.org/isdl.php) nodig (`winget install JRSoftware.InnoSetup`).

## Silent mode (automatisering)

```powershell
# Alle packages updaten (Task Scheduler vriendelijk)
WinGetManager.exe -UpdateAll -Silent

# Specifiek pakket installeren
WinGetManager.exe -Install Mozilla.Firefox

# Backup van geïnstalleerde packages
WinGetManager.exe -ExportPath "C:\backup\packages.json"
```

## Vereisten

- Windows 10 of 11
- WinGet (App Installer) — komt standaard mee met Windows 11

## Licentie

MIT — zie [LICENSE](LICENSE).

## Bijdragen

Issues en pull requests zijn welkom. Zie:

- [CONTRIBUTING.md](CONTRIBUTING.md) — hoe te beginnen
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — community-standaarden
- [SECURITY.md](SECURITY.md) — beveiligingsproblemen melden
- [CHANGELOG.md](CHANGELOG.md) — wat veranderde per versie

## Project structuur

```
src/
├── Core/              Wrapper-modules: Logging, Config, WinGet-Core
├── GUI/MainWindow.ps1 WPF dark/light theme interface
└── Silent/            Headless CLI

Build-Exe.ps1          Bundelt alles naar single .exe via PS2EXE
Build.bat              Wrapper voor het build-script
Generate-Icon.ps1      Genereert assets/icon.ico
.github/workflows/     GitHub Actions: auto-build + release
```

## Roadmap

- [x] Dark / light / auto theme
- [x] Async background runspace voor lange operaties
- [x] Auto-close apps die de update blokkeren
- [x] GitHub Actions auto-build
- [ ] Self-update via GitHub Releases API
- [ ] Microsoft Store distributie
- [ ] System tray-icoon met snelle update-actie
- [ ] Submit naar `winget-pkgs` (zelf installeerbaar via winget)
