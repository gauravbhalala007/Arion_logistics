# CoDriver App — Projektregeln

## Skills

Beim Arbeiten an dieser App **immer** die folgenden Skills anwenden:

- `flutter-build-responsive-layout` — für Layout-/Responsive-Arbeit (Widgets, Breakpoints, Scaffold/Row/Column/Stack).
- `flutter-fix-layout-issues` — für Overflow-, Constraint- und Render-Probleme.
- `dart-run-static-analysis` — vor jedem Push, um Analyse-Fehler früh zu finden.
- `firebase-basics` — für alle allgemeinen Firebase-Arbeiten (Firestore, Storage, Functions, Rules, Konfiguration).
- `firebase-auth-basics` — speziell für Firebase Authentication (Sign-in, Sign-up, Passwort-Reset, Rollen, Tokens).
- `firebase-hosting-basics` — für Deployment und Konfiguration von Firebase Hosting (Build, Deploy, Headers, Rewrites, Preview-Channels).
- `frontend-design` — für visuelles Design, Komposition, Spacing, Typografie und Komponenten-Ästhetik.
- `web-design-guidelines` — für übergreifende Web-Design-Prinzipien (Hierarchie, Kontrast, Accessibility, Motion, moderne UI-Patterns).

### Installation

Nicht mehr nötig. Die Skills liegen eingecheckt unter `.agents/skills/` und
sind über `.claude/skills/` verlinkt — jede Session und jeder frische Clone hat
sie sofort.

Aktualisieren bei Bedarf:

```bash
npx skills update
```

Hinweis: Die früher hier genannten Skills `flutter-building-layouts` und
`flutter-animating-apps` existieren im Repo `flutter/skills` nicht mehr. Ersatz
sind `flutter-build-responsive-layout` und `flutter-fix-layout-issues`; einen
eigenen Animations-Skill bietet das Repo derzeit nicht an.

### Anwendungsregel

- Bei jeder Änderung an Flutter-Widgets, Screens, Animationen, Firebase-Logik, Auth-Flows, Hosting-Deployments oder visuellem Design die oben genannten Skills heranziehen, **bevor** Code geschrieben wird.
- Wenn ein Skill Best-Practices oder Patterns vorgibt, diese übernehmen statt eigene Lösungen zu erfinden.
- Breakpoints, Responsive-Strategie, Animation-Kurven und Firebase-Patterns konsistent mit den Skill-Empfehlungen halten.

## Projektstruktur

- Flutter-App (Frontend + Hosting): `flutter_app/kpi_admin/`
  - `firebase.json` → **nur** Hosting + FlutterFire-Config
  - `lib/firebase_options.dart` → eingecheckt, kein Geheimnis (siehe DEPLOYMENT.md)
- Firebase-Backend: `firebase/`
  - `firebase.json` → Firestore, Storage, Functions, Emulatoren
  - `firestore.rules`, `storage.rules`, `firestore.indexes.json` → **maßgeblich**
  - `functions/` → Cloud Functions (TypeScript, Node 22)
- Parser-Service: `parser_service/` (Cloud Run, `europe-west3`)

Wichtig: Rules und Indexes **nur** in `firebase/` pflegen. Die Kopien unter
`flutter_app/kpi_admin/` sind veraltet und als solche markiert.

## Entwicklungs-Workflow

```bash
cd "flutter_app/kpi_admin"
flutter run -d chrome
```

Im laufenden Prozess:
- `r` → Hot Reload (UI-Änderungen, ~1–2 s)
- `R` → Hot Restart (Struktur-Änderungen, ~3–5 s)
- `q` → Beenden

## Deployment

Vollständige Beschreibung in **[DEPLOYMENT.md](DEPLOYMENT.md)**.

Kurzfassung:

- Push auf `main` → automatischer **Live-Deploy** via GitHub Actions
- Push auf jeden anderen Branch → automatische **Preview-URL** (7 Tage gültig)
- Schlägt `flutter build web --release` fehl, wird **nicht** deployed
- Rules, Functions und der Parser-Service werden **nicht** automatisch deployt

Claude arbeitet immer auf einem `claude/*`-Branch und nie direkt auf `main`.
