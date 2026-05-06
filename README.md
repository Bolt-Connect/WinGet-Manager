# WinGet Manager

Lichtgewicht GUI voor Windows Package Manager (`winget`) met dark/light theme en silent mode voor automatisering. Geschreven in PowerShell + WPF, gecompileerd naar één enkele `.exe` van ~150 KB.

[![Latest Release](https://img.shields.io/github/v/release/Bolt-Connect/WinGetManager?label=release&color=blue)](https://github.com/Bolt-Connect/WinGetManager/releases/latest)
[![Build & Release](https://github.com/Bolt-Connect/WinGetManager/actions/workflows/build.yml/badge.svg)](https://github.com/Bolt-Connect/WinGetManager/actions/workflows/build.yml)
[![Downloads](https://img.shields.io/github/downloads/Bolt-Connect/WinGetManager/total?color=green)](https://github.com/Bolt-Connect/WinGetManager/releases)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
![Platform](https://img.shields.io/badge/windows-10%2B-0078D6)

## ⬇ Download

| Type | Link | Wanneer kiezen |
|---|---|---|
| **Portable** | [WinGetManager.exe](https://github.com/Bolt-Connect/WinGetManager/releases/latest/download/WinGetManager.exe) | Single-file, draaien zonder install. USB, dev-machine. |
| **Setup installer** | [WinGetManager-Setup.exe](https://github.com/Bolt-Connect/WinGetManager/releases/latest/download/WinGetManager-Setup.exe) | Nette install met Start-menu, uninstaller, optionele auto-update task. |
| **Portable bundle** | [WinGetManager-portable.zip](https://github.com/Bolt-Connect/WinGetManager/releases/latest/download/WinGetManager-portable.zip) | EXE + config + docs in één zip. Voor offline distributie. |

[Alle releases →](https://github.com/Bolt-Connect/WinGetManager/releases)

---

## Features

- **🔍 Search-as-you-type** — live resultaten tijdens typen, async, geen UI freeze
- **📦 Geïnstalleerd beheren** — versies + update-status, multi-select voor bulk-acties
- **⬆ Updaten** — alle of geselecteerde packages met live progress (`3/12: Firefox...`)
- **🔄 Auto-detect blokkerende apps** — sluit draaiende apps die updates verhinderen
- **📂 Import / Export** — JSON-backup compatibel met `winget export/import`
- **🔗 Bronnen beheren** — winget sources toevoegen, verwijderen, resetten
- **🌗 Theme** — Dark / Light / Auto (volgt Windows-systeemvoorkeur)
- **🤖 Silent mode** — alle functies headless via CLI voor Task Scheduler
- **📋 Logging** — dagelijkse logs met rotatie + live panel in GUI
- **⬆ Self-update** — controleert GitHub op nieuwe versie, downloadt + herstart
- **🔒 Security** — alleen HTTPS naar `*.github.com`, PE-header check op downloads

## Vereisten

- **Windows 10** (1809+) of **Windows 11**
- **WinGet** (App Installer) — komt standaard mee met Windows 11. Op Windows 10 [installeer via Microsoft Store](ms-windows-store://pdp/?productid=9NBLGGH4NNS1)

## Silent mode (automatisering)

Alle GUI-functies zijn ook beschikbaar via command-line — geschikt voor scripts en Task Scheduler:

```powershell
# Alle packages stil updaten
WinGetManager.exe -UpdateAll -Silent

# Specifiek pakket installeren
WinGetManager.exe -Install Mozilla.Firefox

# Geïnstalleerde packages exporteren
WinGetManager.exe -ExportPath "C:\backup\packages.json"

# Lijst alle beschikbare updates
WinGetManager.exe -ListUpdates

# Importeren op andere machine
WinGetManager.exe -ImportPath "C:\backup\packages.json"
```

Voor een **dagelijkse auto-update** taak in Task Scheduler:

```powershell
.\Install-ScheduledUpdate.ps1 -Time "03:00"
```

## Vanuit source bouwen

```powershell
git clone https://github.com/Bolt-Connect/WinGetManager.git
cd WinGetManager
.\Build.bat                              # bouwt build\WinGetManager.exe
.\Build-Installer.ps1 -Version 0.2.1     # optioneel: maakt release\WinGetManager-Setup-0.2.1.exe
```

Voor de Setup-installer is [Inno Setup 6](https://jrsoftware.org/isdl.php) nodig:

```powershell
winget install JRSoftware.InnoSetup
```

## Bijdragen

Issues en pull requests zijn welkom. Zie:

- [CONTRIBUTING.md](CONTRIBUTING.md) — hoe te beginnen
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — community-standaarden
- [SECURITY.md](SECURITY.md) — beveiligingsproblemen melden
- [CHANGELOG.md](CHANGELOG.md) — wat veranderde per versie
- [CLAUDE.md](CLAUDE.md) — context voor AI-assistenten

## Project structuur

```
src/
├── Core/              Wrapper-modules: Logging, Config, WinGet-Core
├── GUI/MainWindow.ps1 WPF dark/light theme interface (1500+ regels)
└── Silent/            Headless CLI mode

Build-Exe.ps1          Bundelt alles naar single .exe via PS2EXE
Build-Installer.ps1    Bouwt setup-installer via Inno Setup
Generate-Icon.ps1      Genereert assets/icon.ico
installer/             Inno Setup script
.github/workflows/     GitHub Actions: auto-build + release per tag
```

## Roadmap

### ✅ Klaar (v0.2.x)
- Dark / Light / Auto theme
- Async UI (geen freezes)
- Auto-close apps die updates blokkeren
- Multi-select bulk uninstall / update
- Search-as-you-type
- Self-update via GitHub Releases
- GitHub Actions auto-build + release pipeline
- Portable + Inno Setup installer distributie

### 🚧 Komende versies
- [ ] System tray-icoon met snelle update-actie
- [ ] Toast-notificaties bij voltooide updates
- [ ] Package details paneel (klik → side-panel met info)
- [ ] Engelse vertaling (i18n)
- [ ] Keyboard shortcuts (Ctrl+F, F5, Esc)

### 🎯 Strategisch
- [ ] Microsoft Store distributie ($19 — lost SmartScreen + Smart App Control op)
- [ ] Submit naar `winget-pkgs` (`winget install WinGetManager`)
- [ ] SignPath code-signing (gratis voor OSS)

## Licentie

MIT — zie [LICENSE](LICENSE).
