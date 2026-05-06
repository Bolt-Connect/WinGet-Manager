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

Issues en pull requests zijn welkom. Voor grotere wijzigingen graag eerst een issue openen om te bespreken.
