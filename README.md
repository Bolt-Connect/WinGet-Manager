# WinGet Manager

Lichtgewicht GUI voor Windows Package Manager (`winget`) met dark/light theme en silent mode voor automatisering. Geschreven in PowerShell + WPF, gecompileerd naar één enkele `.exe`.

[![Latest Release](https://img.shields.io/github/v/release/Bolt-Connect/WinGetManager?label=release&color=blue)](https://github.com/Bolt-Connect/WinGetManager/releases/latest)
[![Build & Release](https://github.com/Bolt-Connect/WinGetManager/actions/workflows/build.yml/badge.svg)](https://github.com/Bolt-Connect/WinGetManager/actions/workflows/build.yml)
[![Downloads](https://img.shields.io/github/downloads/Bolt-Connect/WinGetManager/total?color=green)](https://github.com/Bolt-Connect/WinGetManager/releases)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
![Platform](https://img.shields.io/badge/windows-10%2B-0078D6)

## ⬇ Download

| Type | Link |
|---|---|
| **Portable** (single-file, geen install) | [WinGetManager.exe](https://github.com/Bolt-Connect/WinGetManager/releases/latest/download/WinGetManager.exe) |
| **Setup installer** (met Start-menu, uninstaller) | [WinGetManager-Setup.exe](https://github.com/Bolt-Connect/WinGetManager/releases/latest/download/WinGetManager-Setup.exe) |
| **Portable bundle** (incl. config + docs) | [WinGetManager-portable.zip](https://github.com/Bolt-Connect/WinGetManager/releases/latest/download/WinGetManager-portable.zip) |

[Alle releases →](https://github.com/Bolt-Connect/WinGetManager/releases)

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

Zie de **⬇ Download**-sectie hierboven voor directe links naar de drie distributievormen.

| Type | Wanneer kiezen |
|---|---|
| **Setup installer** | Reguliere installatie zoals Notepad++/7-Zip — Start-menu, uninstaller, Add/Remove Programs |
| **Portable** | USB-stick, draaien zonder install, geen sporen op systeem |
| **Portable bundle** | Hele zip met config + docs — handig voor offline-distributie |

### Vanuit source bouwen

```powershell
git clone https://github.com/Bolt-Connect/WinGetManager.git
cd WinGetManager
.\Build.bat                              # bouwt build\WinGetManager.exe
.\Build-Installer.ps1 -Version 0.2.0     # optioneel: maakt release\WinGetManager-Setup-0.2.0.exe
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
