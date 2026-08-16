# CoDriver App — Projektregeln

## Skills

Beim Arbeiten an dieser App **immer** die folgenden Skills anwenden:

- `flutter-building-layouts` — für jede Art von UI-/Layout-Arbeit (Widgets, Responsive Design, Scaffold/Row/Column/Stack, etc.)
- `flutter-animating-apps` — für alle animierten Übergänge, Mikro-Interaktionen und State-getriebenen Animationen.
- `firebase-basics` — für alle allgemeinen Firebase-Arbeiten (Firestore, Storage, Functions, Rules, Konfiguration).
- `firebase-auth-basics` — speziell für Firebase Authentication (Sign-in, Sign-up, Passwort-Reset, Rollen, Tokens).
- `firebase-hosting-basics` — für Deployment und Konfiguration von Firebase Hosting (Build, `firebase deploy`, Headers, Rewrites).
- `frontend-design` — für visuelles Design, Komposition, Spacing, Typografie und Komponenten-Ästhetik.
- `web-design-guidelines` — für übergreifende Web-Design-Prinzipien (Hierarchie, Kontrast, Accessibility, Motion, moderne UI-Patterns).

### Installation (einmalig pro Umgebung)

```bash
npx skills add https://github.com/flutter/skills --skill flutter-building-layouts
npx skills add https://github.com/flutter/skills --skill flutter-animating-apps
npx skills add https://github.com/firebase/agent-skills --skill firebase-basics
npx skills add https://github.com/firebase/agent-skills --skill firebase-auth-basics
npx skills add https://github.com/firebase/agent-skills --skill firebase-hosting-basics
npx skills add https://github.com/anthropics/skills --skill frontend-design
npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines
```

### Anwendungsregel

- Bei jeder Änderung an Flutter-Widgets, Screens, Animationen, Firebase-Logik, Auth-Flows, Hosting-Deployments oder visuellem Design die oben genannten Skills heranziehen, **bevor** Code geschrieben wird.
- Wenn ein Skill Best-Practices oder Patterns vorgibt, diese übernehmen statt eigene Lösungen zu erfinden.
- Breakpoints, Responsive-Strategie, Animation-Kurven und Firebase-Patterns konsistent mit den Skill-Empfehlungen halten.

## Projektstruktur

- Flutter-App: `flutter_app/kpi_admin/`
- Firebase-Konfiguration: `flutter_app/kpi_admin/firebase.json`, generierte Options in `lib/firebase_options.dart`
- Parser-Service: `parser_service/`
- Firebase Functions/Rules: `firebase/`

## Entwicklungs-Workflow

```bash
cd "flutter_app/kpi_admin"
flutter run -d chrome
```

Im laufenden Prozess:
- `r` → Hot Reload (UI-Änderungen, ~1–2 s)
- `R` → Hot Restart (Struktur-Änderungen, ~3–5 s)
- `q` → Beenden

## Auto-Deploy

Nach jeder funktionalen Änderung an `flutter_app/kpi_admin/` automatisch deployen — **nicht** nochmal nachfragen:

```bash
cd "flutter_app/kpi_admin"
firebase use   # MUSS "codriver-eu" zurückgeben — sonst abbrechen!
flutter build web --release --pwa-strategy=none
firebase deploy --only hosting
```

Voraussetzung: `flutter analyze lib/` zeigt keine Errors (pre-existing Warnings/Infos sind OK). Bei Errors erst fixen, dann deployen.

Production-URL: https://dsp-codriver.de (Fallback: https://codriver-eu.web.app — beide bedient durch denselben Hosting-Site auf Projekt `codriver-eu`).

⚠️ Das alte Projekt `gaurav-arion-001-3d94a` ist als `legacy` Alias erhalten, dient nur dem Notfall-Rollback und darf **nicht** bedient werden. Vor jedem `firebase deploy` `firebase use` prüfen — Output muss `codriver-eu` sein.

Ausnahmen (vorher fragen):
- destruktive Git-Operationen (`reset --hard`, `push --force`, Branches löschen)
- Firestore-Rules-, Storage-Rules- oder Functions-Deploys (`firebase deploy --only firestore` / `--only storage` / `--only functions`)
- Schema-Migrationen, die existierende Daten ändern

## Sprache / Lokalisierung (Pflicht)

**Alle neuen UI-Texte immer zweisprachig DE/EN** — Englisch, wenn der Admin Englisch als
Sprache gewählt hat. Pattern wie im Bestand:

```dart
final de = Localizations.localeOf(context).languageCode == 'de';
Text(de ? 'Monat erfassen' : 'Add month')
```

Gilt für Labels, Dialoge, Tooltips, Snackbars, Tabellen-Header, PDF-Exporte usw.
Niemals neue Screens/Features nur auf Deutsch (oder nur auf Englisch) bauen.

## Arbeitsweise: einfach loslegen

Bei Umsetzungs-Arbeit (Features, Feedback-Tickets, UI-/Logik-Änderungen): **einfach
starten und durchziehen** — Design selbst sinnvoll festlegen, bauen, `flutter analyze`,
Hosting deployen, dann Ergebnis melden. **Nicht** nach Freigabe/Bestätigung fragen und
nicht das Brainstorming-/Design-Approval-Gate abwarten.

Weiterhin gilt: Die oben gelisteten **Ausnahmen** (destruktive Git-Ops, Rules-/Storage-/
Functions-Deploys, Daten-Migrationen) **vorher fragen** — diese Sicherheits-Asks bleiben.
