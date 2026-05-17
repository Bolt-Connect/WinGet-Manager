# CLAUDE.md

Context for AI assistants (Claude Code, Cursor, GitHub Copilot, etc.) working on this repo.

## What this project is

WinGet Manager — a lightweight PowerShell + WPF GUI around Microsoft's `winget` CLI, bundled as a single `.exe` (~225 KB) via PS2EXE. Dark/light/auto theme, async UI, silent mode for automation, single-file portable + Inno Setup installer. Bilingual UI (English + Dutch) with auto-detect.

Target audience: personal Windows machines, end users who want to manage WinGet through a GUI.

## Architecture

```
WinGetManager.ps1          Entry point for PS1 mode (dev)
src/
├── Core/
│   ├── Logging.psm1       Writes to file + observable for GUI
│   ├── Config.psm1        Loads/saves settings.json
│   ├── I18n.psm1          Translations (NL + EN dictionaries, Get-Text, Apply-Translations)
│   └── WinGet-Core.psm1   Wrappers around winget.exe + self-update
├── GUI/MainWindow.ps1     WPF interface (XAML in here-string)
└── Silent/WinGet-Silent.ps1   Headless CLI mode

Build-Exe.ps1              Bundles everything into a single .ps1 + compiles via PS2EXE
└── build/WinGetManager.exe   Final product

installer/WinGetManager.iss  Inno Setup script
.github/workflows/build.yml  CI: builds EXE + Setup.exe per release tag
```

## Build process

```powershell
.\Build.bat                       # Generates build/WinGetManager.exe
.\Build-Installer.ps1 -Version x  # Requires Inno Setup, output in release/
```

Build-Exe.ps1 does:
1. Reads `src/Core/*.psm1` and strips Export-ModuleMember + signature blocks
2. Reads `src/GUI/MainWindow.ps1` and `src/Silent/WinGet-Silent.ps1`, strips Import-Module and duplicate init code
3. Concatenates everything into a single script file with param block + ScriptRoot detection
4. Compiles via `Invoke-PS2EXE` with icon, version, etc.

## Important conventions

### PowerShell 5.1 compatibility (required)
PS2EXE uses Windows PowerShell 5.1, **not** PowerShell 7. So:

- ❌ `$x ?? $y` (null-coalescing)
- ❌ `$x ?: $y` (ternary)
- ❌ `$x?.Property` (null-conditional)
- ✅ `if ($x) { $x } else { $y }`
- ✅ Verb-noun cmdlets, `[System.Type]` casts

### Async pattern for long operations
Use `Start-WinGetWork` (in MainWindow.ps1) for single async winget calls. For bulk operations: synchronized hashtable + DispatcherTimer + runspace. See `Start-BulkUpdate` as an example.

**Never** run synchronous winget calls on the UI thread — freezes the GUI.

### Closures in event handlers
Variables needed inside a Tick handler must be captured via `.GetNewClosure()`; otherwise you rely on script scope, which leads to null references during fast repeated events:

```powershell
$timer.Add_Tick({
    if ($handle.IsCompleted) {  # $handle from closure
        $timer.Stop()
        ...
    }
}.GetNewClosure())
```

### `$args` is a PowerShell automatic variable
Never use `$args` as your own variable name in scriptblocks with `param(...)`. PowerShell resets `$args` automatically. Use `$cmdArgs`, `$wingetArgs`, etc.

### Theme system
`MainWindow.ps1` has a `$Script:Themes` hashtable with Dark/Light palettes. At window-load the XAML is walked via `Apply-ThemeColors`, which substitutes hex codes. The default XAML uses Dark colors (`#1E1E2E` etc).

For new colors: add a hex to both palettes and add `'#hexvalue' = $colors.NewKey` to the mapping in `Apply-ThemeColors`.

Hex colors in XAML must exactly match the keys in the mapping.

### i18n system
`I18n.psm1` has a `$Script:Strings` hashtable with `nl-NL` and `en-US` sub-hashtables (~150 keys each). At window load:
1. `[xml]$Xaml = @'...'@` — XAML parsed into an XML object
2. `$xamlString = $Xaml.OuterXml` — serialize back
3. `$xamlString = Apply-Translations -Text $xamlString` — substitutes `{{Key}}` placeholders
4. `Apply-ThemeColors` substitutes hex codes
5. `[XamlReader]::Load(...)` builds the WPF tree

For runtime strings in code, use `Get-Text 'Key.Name'` (with optional `-FormatArgs @(...)` for `{0}` placeholders).

**Conventions**:
- All user-facing strings → through i18n (XAML `{{Key}}` or `Get-Text`)
- All log messages (`Write-Log "..."`) → **literal English** (logs are language-neutral)
- Source-column values (`winget`/`msstore`/`local`) → fixed English identifiers, not translated
- New string? Add the key to **both** dictionaries in `src/Core/I18n.psm1`

### PS2EXE-specific gotchas
- `$PSScriptRoot` is empty in a PS2EXE EXE — use `[System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName` as a fallback
- `Write-Host` with `-NoConsole` shows a MessageBox — use `Write-Log` with `-WriteToHost:$false`
- WPF only works in STA — PS2EXE compile with `-STA` flag
- Encoding: source files with non-ASCII chars (emojis, accented chars) **must have a UTF-8 BOM**, otherwise PowerShell 5.1 reads them as cp1252 and corrupts the bytes. The `I18n.psm1` module relies on this.

### Silent mode integration
The bundler merges the silent script body into the main script via `Read-Cleaned -StripParam`. That strips everything before the first `if ($Search)` line — so the silent script now always starts with that as a marker. Don't remove it.

## Self-update

Only works in the EXE distribution. Steps:

1. `Get-LatestAppVersion` fetches the GitHub Releases API
2. Compare `[version]$latest -gt [version]$Script:AppVersion`
3. Download `.exe` asset as `WinGetManager.exe.new`
4. Verify PE header (`Test-PEFile`) and HTTPS+github.com host (`Test-TrustedUpdateUrl`)
5. Write `WinGetManager-Update-*.bat` to TEMP, spawn it
6. The bat waits for exit, moves `.new` → original, restarts

`$Script:AppVersion` in `WinGet-Core.psm1` must match the release tag.

## What to do for a new feature

1. Make the change in the right `src/` file
2. Run `.\Build.bat` locally — output in `build/`
3. Test `build\WinGetManager.exe`
4. Add a line to `## [Unreleased]` in `CHANGELOG.md`
5. Commit with a conventional commit prefix (`feat:`, `fix:`, `docs:`, `refactor:`)
6. Push — GitHub Actions builds the artifact

## What to do for a release

1. Update `$Script:AppVersion` in `src/Core/WinGet-Core.psm1`
2. Update `Version` in `Build-Exe.ps1` (PS2EXE param)
3. Promote `## [Unreleased]` to `## [x.y.z] - YYYY-MM-DD` in CHANGELOG
4. Add a new empty `[Unreleased]` section
5. Commit + push
6. `git tag -a vx.y.z -m "..."` and `git push origin vx.y.z`
7. GitHub Actions publishes the release with portable + installer + zip

## What the user wants to see

- A stable GUI without freezes
- Clear error messages (no raw exit codes)
- As few clicks as possible for common tasks
- Theme follows the Windows preference unless set otherwise
- Language follows the OS UI culture unless set otherwise
- Self-update is "magic" — click the button, restart, done

## Known gotchas / footguns

- `IsReadOnly="True"` on the DataGrid makes ALL columns non-editable, including checkboxes. Use `IsReadOnly="True"` per `DataGridTextColumn` instead of on the DataGrid itself if you want checkboxes to work.
- WPF StackPanel has NO `Spacing` property (that's WinUI). Use `Margin` on the children.
- `Foreground="#CDD6F4"` directly as an attribute does not work for theme substitution if the hex is missing from the mapping. Always use colors from the palette.
- Files containing emojis or non-ASCII need a UTF-8 BOM, otherwise PS5.1 reads them as cp1252 and the module fails to parse.

## Roadmap (see also README)

- v0.4.0: System tray icon, toast notifications, cancel button, package details panel
- v0.5.0: Test phase + SignPath signing
- v1.0.0: First stable release / Microsoft Store distribution

## Links

- Repo: https://github.com/Bolt-Connect/WinGet-Manager
- WinGet docs: https://learn.microsoft.com/en-us/windows/package-manager/winget/
- PS2EXE: https://github.com/MScholtes/PS2EXE
- Inno Setup: https://jrsoftware.org/isinfo.php
