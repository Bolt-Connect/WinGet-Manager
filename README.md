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

> Screenshots volgen in v0.2

## Installatie

### Optie 1 — Portable (aanbevolen voor nu)

1. Download `WinGetManager.exe` van de [Releases-pagina](../../releases)
2. Plaats in een map naar keuze
3. Dubbelklik

Geen installatie nodig.

### Optie 2 — Vanuit source bouwen

```powershell
git clone https://github.com/Bolt-Connect/WinGetManager.git
cd WinGetManager
.\Build.bat
# Output: build\WinGetManager.exe
```

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
