# Changelog

All notable changes to WinGet Manager are tracked in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.3.0] - 2026-05-17

### Added
- **i18n infrastructure** — new `src/Core/I18n.psm1` module with embedded English and Dutch dictionaries (~150 keys). Translations apply through `{{Key}}` placeholder substitution in XAML and `Get-Text` calls in code.
- **Language picker** in Settings tab: `Automatic (system)` / `Nederlands` / `English`. Save prompts for restart to apply.
- **Auto-detect language** via `CurrentUICulture` at startup: `nl-*` → Dutch, anything else → English (fallback). Default `Language` setting changed from `nl-NL` to `auto`.
- **All documentation translated to English** (README, CHANGELOG, CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, CLAUDE).

### Changed
- **Source column derivation** — `Parse-PackageJson` and `Parse-PackageText` now derive a logical source when winget leaves the column empty: `MSIX\…` → `msstore`, `ARP\…` → `local`, anything else → `winget`. Previously most installed packages showed an empty BRON column. New helper `Resolve-PackageSource` in `WinGet-Core.psm1`.
- **All log messages translated to English** (~60 strings across `WinGet-Silent.ps1`, `MainWindow.ps1`, `WinGet-Core.psm1`). Logs are now language-neutral regardless of UI language, making them easier to share in bug reports.
- **Status bar and runtime status messages** now i18n-aware (`Set-Status` calls go through `Get-Text`).
- **Dialog texts** for Show-Info / Show-Error / Ask-Confirm fully translated (~45 dialogs across install, uninstall, update, import/export, sources, settings, self-update flows).
- **Self-update reason strings** translated (up-to-date / no asset / download failed / corrupt / invalid exe / untrusted URL / not-exe runtime).
- **Sources tab description paragraph** fully translated, including the Run blocks explaining `winget` / `msstore` defaults.
- **Repo renamed** on GitHub from `WinGetManager` to `WinGet-Manager`. All internal references updated (README, CHANGELOG, CONTRIBUTING, CLAUDE, SECURITY, Config defaults, Inno Setup script).
- `SelfUpdateUrl` in new builds now points to the renamed repo. **One-time automatic migration**: when v0.2.5 users upgrade to v0.3.0, the legacy URL in their saved `settings.json` is rewritten to the new repo URL on first start.
- **Inno Setup installer** now uses `[CustomMessages]` with English + Dutch task descriptions instead of a hardcoded Dutch string.
- **Build pipeline and CI workflow** step names and console output translated to English.

### Fixed
- **Search returned 0 results in English mode** — `CmbSearchSource` filter compared the translated `Content` string ("Alle bronnen") which broke in EN. ComboBox items now use a language-neutral `Tag` attribute (`""` / `"winget"` / `"msstore"`) for the filter check. Same pattern applied to the Logs level filter (`CmbLogFilter`).
- **`EmptySearch.Text` reset still showed Dutch placeholder** when typing fewer than 2 characters, regardless of UI language. Now reads from `Get-Text 'Search.Empty'`.

---

## [0.2.5] - 2026-05-15

### Added
- **New app icon** based on the site logo (blue monitor with stand). Transparent background so it fits both dark and light Windows title bars and taskbar. `Generate-Icon.ps1` regenerates this design.
- **Monitor logo in app header** — replaced the `⊞` text symbol with a native XAML rendering of the actual logo. Theme-aware background (dark in dark, blends in light).
- **`BETA` badge** next to the version number in the header (amber yellow `#d29922`).
- **Status pill column** on the Installed tab: green "↑ Update" pill for updatable packages, grey "Up-to-date" for the rest. Replaces the green row text.
- **Tab badges as colored pills** in the tab header (blue for Installed/Sources, green for Updates).
- **Search icon (🔍)** in filter bars on Search and Installed tabs.

### Changed
- **Dark theme palette matches GitHub style** (same palette as the website CSS):
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
- **Minimal tab styling**: tabs now without background/borders — only text with a blue underline for the active tab. Much cleaner.
- **Cleaner DataGrid**: no frame border, transparent background, only subtle horizontal row separators, column headers now UPPERCASE + muted (`NAME`, `ID`, `VERSION`, etc).
- **Airier row spacing**: MinHeight 38px + DataGridCell padding 10x8px for more breathing room.
- **Bigger filter bar**: padding 14×9 + MinHeight 38 for a prominent, GitHub-style input.
- **Header and status bar background** now match `BgPrimary` instead of a separate darker card color — more uniform.
- **Window icon** is now extracted at runtime from the EXE (PS2EXE-embedded resource) — works without an extra `assets/icon.ico` file next to the exe.
- README badge "current stable" → **"public beta"** with an orange beta status badge at the top.

---

## [0.2.4] - 2026-05-14

### Fixed
- **Updates tab counter was wrong**: WinGet's footer line "X upgrades available." was being parsed as a package. Parser now also filters these footer lines (NL + EN) plus rows without an Id-column value.
- **Logs tab stayed empty in GUI**: `DataGridTextColumn` default binding mode (TwoWay) did not work with `PSCustomObject` NoteProperty. Bindings are now explicit `Mode=OneWay`. Also: ObservableCollection has no `Dispatcher` property — replaced by a separate `$Script:LogDispatcher` with the Window's Dispatcher for thread-safe Add from background runspaces.
- **`ConfirmUpdate` setting didn't work**: the checkbox in Settings saved the value but no update button checked it. Now wired in `BtnUpdateSelectedInstalled`, `BtnUpdateAll`, and `BtnUpdateSelected` with "Don't ask again" option via `Ask-ConfirmEx`.

### Changed
- `Set-LogObservable` now also accepts a `-Dispatcher` parameter (optional) for thread-safe collection updates.
- Keyboard shortcut diagnostic logs lowered back to `DEBUG` level (no longer polluting the logs).
- **Installed tab sorting**: items with an available update now appear at the top, then alphabetical. This way users immediately see what's updatable without scrolling.

---

## [0.2.3] - 2026-05-07

### Added
- **Tab badges with count**: tabs now show the number of items per category, e.g. `📦 Installed (147)`, `⬆ Updates (3)`, `🔗 Sources (2)`. Updates and Sources only show a counter at ≥1 item.
- **Empty-state messages** in all DataGrids:
  - Search (no text): "🔍 Type at least 2 characters to search"
  - Search (no match): "🔍 No results for 'xyz'"
  - Installed (empty): "📦 No packages found"
  - Updates (empty): "✓ All packages are up-to-date 🎉" (green)
  - Sources (empty): "🔗 No sources configured"
- **Info card on Sources tab** explaining what `winget` and `msstore` are and what you can do here.

---

## [0.2.2] - 2026-05-06

### Added
- Global keyboard shortcuts:
  - `F5` refreshes the current tab (Installed / Updates / Sources / Search)
  - `Ctrl+F` jumps to the Search tab and focuses the search bar
  - `Ctrl+R` opens the Updates tab and refreshes immediately
  - `Ctrl+L` opens the Logs tab
  - `Ctrl+W` closes the app
  - `Esc` clears the search field on the Search tab
- F5 simulates a click on the corresponding Refresh button with a **gold flash animation** (250ms) for visible feedback.
- "Keyboard shortcuts" section in the Settings tab with an overview of all shortcuts.
- "Don't ask again" checkbox on uninstall confirmations; ticking it saves `ConfirmUninstall=false` in the config.
- `Ask-ConfirmEx` helper: themed custom dialog with optional opt-out checkbox per action.

### Fixed
- ComboBoxItems were unreadable in dark mode (dark system text on dark background). Added: explicit ComboBoxItem style with theme-aware Foreground.
- DataGrid.ItemsSource crashed on pipelines with 1 result (PowerShell unwraps single-item arrays to scalar). All assignments now wrapped with `@(...)`.
- Keyboard shortcut handler did not always fire if a TextBox/DataGrid had focus. Replaced with `AddHandler` and `handledEventsToo=$true`.

---

## [0.2.1] - 2026-05-06

### Added
- README badges: build status, latest release, downloads count, license.
- Direct download links in README via stable `/releases/latest/download/` URL pattern — works automatically for every new release without updating the README.
- `CLAUDE.md` with project context for AI assistants (Claude Code, Cursor, Copilot).

### Changed
- GitHub Actions now uploads both versioned (`WinGetManager-Setup-0.2.1.exe`) and stable (`WinGetManager-Setup.exe`) filenames per release.
- Same for portable zip: `WinGetManager-v0.2.1-portable.zip` + `WinGetManager-portable.zip`.
- README install section simplified: now a clear comparison of Setup vs Portable vs Bundle.

### Fixed
- v0.2.0 release was missing the stable `WinGetManager-Setup.exe` filename — direct download links in README pointed to 404 for the installer. From 0.2.1 onward all `/releases/latest/download/...` URLs work.

---

## [0.2.0] - 2026-05-06

### Added
- Working self-update via GitHub Releases API: detects newer version, downloads the new `.exe`, replaces itself and restarts automatically.
- Background update check at startup — "Update app" button turns orange when a newer version is available.
- Search-as-you-type on the Search tab with 400ms debouncing and async runspaces (UI freeze-free).
- Live progress text during Update All / Update selection: "Updating (3/12): Firefox..."
- Failure overview after bulk update shows which packages could not be updated.
- Screenshots folder structure and README section for visual documentation.

### Changed
- Version bumped from `1.0.0` (internal) to `0.2.0` to align with the release tag.
- Update button now points to the GitHub Releases API instead of a placeholder URL.

### Fixed
- Race condition in search debouncing where old timers caused null-reference errors.
- "Cannot bind argument" error during update due to collision with PowerShell's `$args` automatic variable.

---

## [0.1.0] - 2026-05-06

First public release.

### Added
- WPF GUI with 7 tabs: Search, Installed, Updates, Import/Export, Sources, Logs, Settings.
- Dark / Light / Auto theme (Auto follows Windows system preference).
- Async background runspace so the UI doesn't freeze during long winget operations.
- Auto-detect running apps that block an update, with a confirmation dialog to close them and resume the update.
- Mapping of WinGet exit codes to readable messages (instead of raw codes).
- Updates tab: checkable checkbox column to selectively update packages.
- Installed tab: shows current version + available version, colors rows green when an update is available.
- Silent CLI mode for automation (Task Scheduler, scripts):
  - `-UpdateAll`, `-Install`, `-Uninstall`, `-Search`, `-ExportPath`, `-ImportPath`, `-ListInstalled`, `-ListUpdates`.
- Smart config location: portable (next to the exe) or `%APPDATA%\WinGetManager\` if the app folder isn't writable.
- Logging with daily rotation, retention setting and a live log panel in the GUI.
- Single-file `.exe` distribution (146 KB) via PS2EXE bundling.
- Inno Setup installer with optional desktop shortcut and Task Scheduler task.
- GitHub Actions workflow that automatically publishes portable + installer + zip as a release on every tag.
- Documentation: README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, LICENSE (MIT).

### Known
- Self-update functionality is provided in the architecture but not yet implemented; updates must be done manually via a new download.
- Smart App Control (Windows 11) blocks running the exe — disabling is a one-way action. Will be resolved once the app is distributed via Microsoft Store.
- SmartScreen shows an "Unknown publisher" warning on first launch (click *More info* → *Run anyway*). Will be resolved later via SignPath or Microsoft Store distribution.

[Unreleased]: https://github.com/Bolt-Connect/WinGet-Manager/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.3.0
[0.2.5]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.2.5
[0.2.4]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.2.4
[0.2.3]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.2.3
[0.2.2]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.2.2
[0.2.1]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.2.1
[0.2.0]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.2.0
[0.1.0]: https://github.com/Bolt-Connect/WinGet-Manager/releases/tag/v0.1.0
