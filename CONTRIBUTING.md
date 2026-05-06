# Bijdragen aan WinGet Manager

Bedankt dat je wilt bijdragen! Hier staat hoe je aan de slag kunt.

## Bug melden

Open een issue met:

- Versie van WinGet Manager (zie titelbalk)
- Versie van Windows (`winver`)
- Stappen om te reproduceren
- Verwacht vs. werkelijk gedrag
- Logs uit de app (tab **Logs** → kopieer relevante regels)

## Feature voorstel

Open een issue met label `enhancement` waarin je beschrijft:

- Wat je probeert te bereiken
- Waarom het huidige gedrag niet voldoet
- Hoe je voorstel zou werken (UI-mock-up, voorbeeldcode mag)

## Pull request

1. Fork de repo
2. Maak een feature-branch: `git checkout -b feat/mijn-feature`
3. Maak je wijzigingen in `src/`
4. Build lokaal: `.\Build.bat` en test `build\WinGetManager.exe`
5. Voeg een regel toe onder de juiste sectie in [CHANGELOG.md](CHANGELOG.md) → `## [Unreleased]`
6. Commit met duidelijke berichten (`feat: ...`, `fix: ...`, `docs: ...`)
7. Open een PR met beschrijving van wat er verandert en waarom

### Conventional commits (aanbevolen)

| Prefix | Wanneer |
|---|---|
| `feat:` | Nieuwe feature voor de gebruiker |
| `fix:` | Bug fix |
| `docs:` | Alleen documentatie |
| `style:` | Formattering, geen code-wijziging |
| `refactor:` | Code-herstructurering zonder gedragsverandering |
| `test:` | Tests toevoegen of aanpassen |
| `chore:` | Build, CI, dependencies |

## Codestijl

- PowerShell 5.1 compatibel (geen `??`, `?:`, etc.)
- Functies krijgen een verb-noun naam (`Get-X`, `Update-Y`)
- Comments en strings in Nederlands of Engels — wees consistent binnen één bestand
- Geen onnodig grote refactors zonder eerst issue te openen

## Project structuur

```
src/
├── Core/              Wrapper-modules (Logging, Config, WinGet-Core)
├── GUI/MainWindow.ps1 WPF-interface
└── Silent/            Headless CLI

Build-Exe.ps1          Bundelt naar single .exe via PS2EXE
.github/workflows/     CI/CD voor auto-build
```

## Lokaal bouwen

```powershell
.\Build.bat
.\build\WinGetManager.exe
```

## Vragen?

Open gerust een issue met label `question` — geen bezwaar.
