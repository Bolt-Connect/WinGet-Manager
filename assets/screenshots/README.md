# Screenshots

Screenshots van de WinGet Manager applicatie, geref. vanuit de hoofd-README en website.

## Aanwezig

| Bestand | Inhoud |
|---|---|
| `v0.2.5-installed-dark.png` | Geïnstalleerd-tab met 150 packages in dark mode (1200×750) |

## Hoe nieuwe screenshots maken

Automatisch via het helper-script (vereist dat de app draait):

```powershell
.\Take-Screenshot-Installed.ps1   # Start app in dark, switch naar Geïnstalleerd, capture
.\Take-Screenshot.ps1             # Capture huidige actieve tab + theme
```

Handmatig:

1. Start `build\WinGetManager.exe`
2. Win+Shift+S of Snipping Tool → selecteer alleen het app-venster
3. Sla op als PNG met sprekende naam (bv. `v0.2.6-updates-dark.png`)
4. Optioneel: comprimeer via [tinypng.com](https://tinypng.com) tot ~60-100 KB

## Naming-conventie

`vX.Y.Z-<tab>-<theme>.png`

Voorbeelden:
- `v0.2.5-installed-dark.png`
- `v0.3.0-updates-light.png`

## Resolutie

Native venstergrootte is 1200×750 px. Comprimeer naar PNG (geen JPG).
