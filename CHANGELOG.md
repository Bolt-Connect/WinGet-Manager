# Changelog

Alle noemenswaardige wijzigingen aan WinGet Manager worden in dit bestand bijgehouden.

Het formaat is gebaseerd op [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), en dit project gebruikt [Semantic Versioning](https://semver.org/lang/nl/).

## [Unreleased]

### Toegevoegd
- (nog niets)

### Gewijzigd
- (nog niets)

### Opgelost
- (nog niets)

### Verwijderd
- (nog niets)

---

## [0.1.0] - 2026-05-06

Eerste publieke release.

### Toegevoegd
- WPF GUI met 7 tabbladen: Zoeken, Geïnstalleerd, Updates, Import/Export, Bronnen, Logs, Instellingen.
- Dark / Light / Auto thema (Auto volgt Windows-systeemvoorkeur).
- Async background runspace zodat de UI niet bevriest tijdens lange winget-operaties.
- Auto-detectie van draaiende apps die een update blokkeren, met confirmatie-dialoog om ze te sluiten en de update te hervatten.
- Mapping van WinGet exit codes naar leesbare meldingen (in plaats van rauwe codes).
- Updates-tab: aanvinkbare checkbox-kolom om selectief packages te updaten.
- Geïnstalleerd-tab: toont actuele versie + beschikbare versie, kleurt rijen groen wanneer er een update beschikbaar is.
- Silent CLI-modus voor automatisering (Task Scheduler, scripts):
  - `-UpdateAll`, `-Install`, `-Uninstall`, `-Search`, `-ExportPath`, `-ImportPath`, `-ListInstalled`, `-ListUpdates`.
- Slimme config-locatie: portable (naast de exe) of `%APPDATA%\WinGetManager\` als app-map niet schrijfbaar is.
- Logging met dagelijkse rotatie, retentie-instelling en live log-paneel in de GUI.
- Single-file `.exe` distributie (146 KB) via PS2EXE bundling.
- Inno Setup installer met optionele bureaublad-snelkoppeling en Task Scheduler taak.
- GitHub Actions workflow die bij elke tag automatisch portable + installer + zip publiceert als release.
- Documentatie: README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, LICENSE (MIT).

### Bekend
- Self-update functionaliteit is voorzien in de architectuur maar nog niet geïmplementeerd; updates moeten handmatig via een nieuwe download.
- Smart App Control (Windows 11) blokkeert het uitvoeren van de exe — uitschakelen is een one-way actie. Wordt opgelost zodra app via Microsoft Store gedistribueerd wordt.
- SmartScreen toont een "Unknown publisher" waarschuwing bij eerste start (klik *Meer info* → *Toch uitvoeren*). Wordt later opgelost via SignPath of Microsoft Store distributie.

[Unreleased]: https://github.com/Bolt-Connect/WinGetManager/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.1.0
