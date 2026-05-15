# Changelog

Alle noemenswaardige wijzigingen aan WinGet Manager worden in dit bestand bijgehouden.

Het formaat is gebaseerd op [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), en dit project gebruikt [Semantic Versioning](https://semver.org/lang/nl/).

## [Unreleased]

### Toegevoegd
- (nog niets)

---

## [0.2.5] - 2026-05-15

### Toegevoegd
- **Nieuw app-icoon** gebaseerd op het site-logo (blauw monitor met statief). Transparante achtergrond zodat het zowel op dark als light Windows-titelbalken en taakbalk past. `Generate-Icon.ps1` regenereert dit ontwerp.
- **Monitor-logo in app header** — `⊞` tekst-symbool vervangen door native XAML rendering van het echte logo. Theme-bewuste achtergrond (donker in dark, blendt in light).
- **`BETA` badge** naast versie-nummer in de header (amber-geel `#d29922`).
- **Status-pill kolom** in Geïnstalleerd-tab: groene "↑ Update" pill voor updatebare packages, grijze "Up-to-date" voor de rest. Vervangt de groene rij-tekst.
- **Tab-badges als gekleurde pills** in de tab-header (blauw bolletje voor Geïnstalleerd/Bronnen, groen voor Updates).
- **Zoek-icoon (🔍)** in filter-balken op Zoeken- en Geïnstalleerd-tabs.

### Gewijzigd
- **Dark theme kleurpalet matcht GitHub-stijl** (zelfde palette als de website CSS):
  - `BgPrimary` `#1A1B26` → `#0d1117`
  - `BgSecondary` `#24283B` → `#161b22`
  - `BgCard` `#2F3349` → `#21262d`
  - `BorderColor` `#3B4261` → `#30363d`
  - `TextMuted` `#7A88B0` → `#8b949e`
  - `TextPrimary` `#E5E9F0` → `#e6edf3`
  - `AccentBlue` `#4FA3FF` → `#2f81f7`
  - `AccentGreen` `#4ADE80` → `#3fb950`
  - `AccentRed` `#FF6B7A` → `#f85149`
  - `AccentYellow` `#FFD23F` → `#d29922`
- **Tab-styling minimal**: tabs nu zonder achtergrond/borders — alleen tekst met blauwe onderlijn bij de actieve tab. Veel cleaner.
- **DataGrid cleaner**: geen frame-border, transparante achtergrond, alleen subtiele horizontale row-separators, kolom-headers nu UPPERCASE + muted (`NAAM`, `ID`, `VERSIE`, etc).
- **Row spacing luchtiger**: MinHeight 38px + DataGridCell padding 10x8px voor meer ademruimte.
- **Filter-balk groter**: padding 14×9 + MinHeight 38 voor een prominente, GitHub-stijl input.
- **Header- en statusbar-achtergrond** matchen nu de BgPrimary kleur ipv. een aparte donkerdere card-kleur — uniformer.
- **Window-icoon** wordt nu runtime uit de EXE geëxtraheerd (PS2EXE-embedded resource) — werkt zonder extra `assets/icon.ico` bestand naast de exe.
- README badge "huidige stable" → **"public beta"** met oranje beta-status badge bovenaan.

---

## [0.2.4] - 2026-05-14

### Opgelost
- **Updates-tab teller klopte niet**: WinGet's footer-regel "X upgrades available." werd als pakket geparsed. Parser filtert nu ook deze footer-regels (NL + EN) plus regels zonder Id-kolom-waarde.
- **Logs-tab bleef leeg in GUI**: `DataGridTextColumn` default binding-mode (TwoWay) werkte niet met `PSCustomObject` NoteProperty. Bindings nu expliciet `Mode=OneWay`. Plus: ObservableCollection heeft geen `Dispatcher` property — vervangen door aparte `$Script:LogDispatcher` met het Window's Dispatcher voor thread-safe Add vanuit achtergrond-runspaces.
- **`ConfirmUpdate` setting werkte niet**: de checkbox in Settings sloeg de waarde wel op, maar geen enkele update-knop checkte hem. Nu wired bij `BtnUpdateSelectedInstalled`, `BtnUpdateAll`, en `BtnUpdateSelected` met "Niet meer vragen"-optie via `Ask-ConfirmEx`.

### Gewijzigd
- `Set-LogObservable` accepteert nu ook een `-Dispatcher` parameter (optioneel) voor thread-safe collection updates.
- Keyboard shortcut diagnostic logs teruggezet naar `DEBUG` niveau (vervuilden de logs niet meer).
- **Geïnstalleerd-tab sortering**: items met beschikbare update staan nu bovenaan, daarna alfabetisch. Op die manier zien gebruikers direct wat updatebaar is zonder te scrollen.

---

## [0.2.3] - 2026-05-07

### Toegevoegd
- **Tab-badges met telling**: tabs tonen nu het aantal items per categorie, bijv. `📦 Geïnstalleerd (147)`, `⬆ Updates (3)`, `🔗 Bronnen (2)`. Updates en Bronnen tonen alleen een teller bij ≥1 item.
- **Empty-state berichten** in alle DataGrids:
  - Zoeken (geen tekst): "🔍 Typ minimaal 2 tekens om te zoeken"
  - Zoeken (geen match): "🔍 Geen resultaten voor 'xyz'"
  - Geïnstalleerd (leeg): "📦 Geen packages gevonden"
  - Updates (leeg): "✓ Alle packages zijn up-to-date 🎉" (groen)
  - Bronnen (leeg): "🔗 Geen bronnen geconfigureerd"
- **Info-card op Bronnen-tab** met uitleg wat `winget` en `msstore` zijn en wat je hier kunt doen.

---

## [0.2.2] - 2026-05-06

### Toegevoegd
- Globale keyboard shortcuts:
  - `F5` ververst de huidige tab (Geïnstalleerd / Updates / Bronnen / Zoeken)
  - `Ctrl+F` springt naar Zoeken-tab en focust de zoekbalk
  - `Ctrl+R` opent Updates-tab en ververst meteen
  - `Ctrl+L` opent Logs-tab
  - `Ctrl+W` sluit de app
  - `Esc` wist het zoekveld op de Zoeken-tab
- F5 simuleert een klik op de bijbehorende Vernieuwen-knop met **goud-flash animatie** (250ms) voor zichtbare feedback.
- "Sneltoetsen" sectie in Instellingen-tab met overzicht van alle keyboard shortcuts.
- "Niet meer vragen"-checkbox bij verwijder-confirmaties; aanvinken slaat ConfirmUninstall=false op in config.
- `Ask-ConfirmEx` helper: themed custom dialog met optionele opt-out checkbox per actie.

### Opgelost
- ComboBoxItems waren onleesbaar in dark mode (donkere systeem-tekst op donkere achtergrond). Toegevoegd: expliciete ComboBoxItem-style met theme-bewuste Foreground.
- DataGrid.ItemsSource crashte bij pipelines met 1 resultaat (PowerShell unwrapt single-item arrays naar scalar). Alle assignments nu gewrapped met `@(...)`.
- Keyboard shortcut handler werd niet altijd gevuurd als TextBox/DataGrid focus had. Vervangen door `AddHandler` met `handledEventsToo=$true`.

---

## [0.2.1] - 2026-05-06

### Toegevoegd
- README-badges: build status, latest release, downloads count, license.
- Directe download-links in README via stabiele `/releases/latest/download/` URL-patroon — werkt automatisch voor elke nieuwe release zonder de README te updaten.
- `CLAUDE.md` met project-context voor AI-assistenten (Claude Code, Cursor, Copilot).

### Gewijzigd
- GitHub Actions uploadt nu zowel versioned (`WinGetManager-Setup-0.2.1.exe`) als stabiele (`WinGetManager-Setup.exe`) filenames per release.
- Hetzelfde voor portable zip: `WinGetManager-v0.2.1-portable.zip` + `WinGetManager-portable.zip`.
- README-installatie-sectie vereenvoudigd: nu duidelijke vergelijking van Setup vs Portable vs Bundle.

### Opgelost
- v0.2.0 release miste de stabiele `WinGetManager-Setup.exe` filename — direct-download links in README pointten naar 404 voor de installer. Vanaf 0.2.1 werken alle `/releases/latest/download/...` URLs.

---

## [0.2.0] - 2026-05-06

### Toegevoegd
- Werkende self-update via GitHub Releases API: detecteert nieuwere versie, downloadt de nieuwe `.exe`, vervangt zichzelf en herstart automatisch.
- Achtergrond update-check bij opstarten — knop "App updaten" wordt oranje wanneer er een nieuwere versie beschikbaar is.
- Search-as-you-type op de Zoeken-tab met 400ms debouncing en async runspaces (UI freeze-free).
- Live progress-tekst bij Update Alles / Selectie updaten: "Updaten (3/12): Firefox..."
- Mislukt-overzicht na bulk update toont welke packages niet konden worden bijgewerkt.
- Screenshots-mappen-structuur en README-sectie voor visuele documentatie.

### Gewijzigd
- Versie verhoogd van `1.0.0` (intern) naar `0.2.0` om aan te sluiten bij de release-tag.
- Update-knop verwijst nu naar GitHub Releases API ipv. een placeholder-URL.

### Opgelost
- Race condition in de search-debouncing waarbij oude timers null-reference fouten veroorzaakten.
- "Cannot bind argument" fout bij update door collision met PowerShell `$args` automatic variable.

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

[Unreleased]: https://github.com/Bolt-Connect/WinGetManager/compare/v0.2.5...HEAD
[0.2.5]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.2.5
[0.2.4]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.2.4
[0.2.3]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.2.3
[0.2.2]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.2.2
[0.2.1]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.2.1
[0.2.0]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.2.0
[0.1.0]: https://github.com/Bolt-Connect/WinGetManager/releases/tag/v0.1.0
