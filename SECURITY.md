# Security Policy

## Ondersteunde versies

Alleen de meest recente release ontvangt actief beveiligingspatches.

| Versie  | Ondersteund        |
| ------- | ------------------ |
| 0.x     | :white_check_mark: |

## Een kwetsbaarheid melden

Vond je een beveiligingsprobleem? Help ons door het **niet publiek** te melden in een issue, maar privé via een van de volgende kanalen:

- Open een **private security advisory** op GitHub:
  [github.com/Bolt-Connect/WinGet-Manager/security/advisories/new](https://github.com/Bolt-Connect/WinGet-Manager/security/advisories/new)
- Of stuur een mail naar de beheerder via het profiel van [@Bolt-Connect](https://github.com/Bolt-Connect)

Wat te vermelden in je melding:

- Een duidelijke beschrijving van het probleem
- Stappen om het te reproduceren
- De impact die je voorziet (lezen van data, code uitvoeren, etc.)
- Optioneel: een voorstel voor de fix

## Wat je kunt verwachten

| Tijd  | Reactie |
| ---- | ------- |
| 48 uur | Eerste bevestiging dat we de melding hebben ontvangen |
| 7 dagen | Inhoudelijke reactie met onze eerste analyse |
| 30 dagen | Streefdatum voor een patch (afhankelijk van complexiteit) |

Als je je verantwoordelijk meldt en ons de tijd geeft om het op te lossen, vermelden we je bij de release-notes (tenzij je anoniem wilt blijven).

## Aandachtspunten

WinGet Manager is een wrapper rond `winget.exe`. Beveiligingsproblemen die specifiek zijn voor WinGet zelf horen niet hier — meld die bij [microsoft/winget-cli](https://github.com/microsoft/winget-cli/security).

Houd ons project gefocust op:

- Lokale code-execution risico's (bijv. command injection in onze wrappers)
- Onveilige defaults of configuratie
- Bestandspad-traversal in import/export
- Onveilige installatie-flows
- Privacy-issues (logging van gevoelige data)

## Disclosure

Na een patch wordt het probleem publiek gemaakt via een GitHub Security Advisory met CVE indien van toepassing.
