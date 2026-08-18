# Deployment & Zusammenarbeit

Dieses Dokument beschreibt, wie zwischen **deinem Mac**, **GitHub** und
**Claude-Code-Sessions** gearbeitet wird, ohne dass Arbeit verloren geht, und
wie Änderungen automatisch live gehen.

---

## 1. Die Grundregel gegen Verluste

**GitHub ist die einzige Quelle der Wahrheit.** Weder dein Mac noch eine
Claude-Session halten einen Stand, den GitHub nicht kennt.

Daraus folgen drei Gewohnheiten:

| Situation | Was du tust |
|---|---|
| Du fängst am Mac an zu arbeiten | **Zuerst** `git pull origin main` |
| Du bist am Mac fertig | `git add -A && git commit -m "..." && git push` |
| Du startest eine Claude-Session | Nichts — die Session klont GitHub frisch |
| Claude ist fertig | Claude pusht auf einen `claude/*`-Branch, du prüfst und mergst |

Der eine Fehler, der wirklich Arbeit kostet: **am Mac weiterarbeiten, ohne zu
pullen, während parallel auf einem Branch etwas gemerged wurde.** Dann
entstehen zwei Stände derselben Datei. Deshalb: pullen, bevor du anfängst.

Es geht auch dann nichts verloren, wenn es doch passiert — Git behält beide
Versionen. Aber du musst dann von Hand zusammenführen, und das ist Arbeit.

### Warum Claude auf einem eigenen Branch arbeitet

Claude pusht nie direkt auf `main`. Jede Session arbeitet auf einem
`claude/...`-Branch. Das hat zwei Effekte:

- Dein `main` bleibt immer der Stand, der live ist.
- Du siehst jede Änderung als Diff, bevor sie live geht — und kannst sie auf
  der Preview-URL anschauen, bevor du mergst.

---

## 2. Einmalige Einrichtung (musst du einmal am Mac machen)

Damit GitHub für dich deployen darf, braucht es einen Firebase-Zugang als
GitHub-Secret. Der bequemste Weg erledigt beides in einem Schritt:

```bash
cd flutter_app/kpi_admin
npx -y firebase-tools@latest login
npx -y firebase-tools@latest init hosting:github
```

Der Assistent fragt nach dem Repository (`kreativwerk/Arion_logistics`), legt
in Google Cloud automatisch einen Service-Account an und hinterlegt ihn als
GitHub-Secret. **Wichtig:** Wenn er anbietet, Workflow-Dateien zu erzeugen oder
zu überschreiben, **lehne ab** — die liegen bereits fertig in
`.github/workflows/`.

Das Secret muss am Ende exakt `FIREBASE_SERVICE_ACCOUNT` heißen. Prüfen unter:
`GitHub → Settings → Secrets and variables → Actions`.

Heißt es anders (der Assistent hängt manchmal den Projektnamen an, z. B.
`FIREBASE_SERVICE_ACCOUNT_GAURAV_ARION_001_3D94A`), dann lege es zusätzlich
unter dem Namen `FIREBASE_SERVICE_ACCOUNT` an — Inhalt einfach kopieren.

### Alternative ohne Assistent

1. Google Cloud Console → IAM & Admin → Service Accounts → *Create*
2. Rollen: **Firebase Hosting Admin** + **Cloud Run Viewer** +
   **Service Account User**
   (zusätzlich **Firebase Rules Admin**, wenn auch Rules deployt werden sollen)
3. *Keys* → *Add Key* → JSON herunterladen
4. GitHub → Settings → Secrets and variables → Actions → *New repository secret*
   Name: `FIREBASE_SERVICE_ACCOUNT`, Wert: der **komplette** JSON-Inhalt

---

## 3. Was passiert bei welchem Push

Workflow: `.github/workflows/deploy-hosting.yml`

| Auslöser | Ergebnis |
|---|---|
| Push auf `main` | **Live-Deploy** auf `gaurav-arion-001-3d94a.web.app` |
| Push auf irgendeinen anderen Branch | **Preview-URL** unter `gaurav-arion-001-3d94a--<branchname>-<hash>.web.app`, läuft nach 7 Tagen ab |
| Pull Request geöffnet | Preview-Deploy, die URL wird **als Kommentar in den PR** geschrieben |
| Manuell in GitHub | `Actions → Deploy Web App → Run workflow` |

Der Ablauf pro Deploy:

1. Flutter-Version aus `.fvmrc` lesen (aktuell **3.41.6**) — CI und dein Mac
   bauen garantiert mit derselben Version
2. `flutter pub get`
3. `flutter analyze` — nur Bericht, blockiert nicht
4. `flutter build web --release` — **schlägt der Build fehl, wird nichts
   deployed.** Das ist das Sicherheitsnetz: ein kaputter Stand kann die Live-Seite
   nicht erreichen
5. Deploy auf Live- oder Preview-Channel

Deploys desselben Branches laufen nie parallel (`concurrency`), es kann also
kein älterer Build einen neueren überschreiben.

Der Workflow startet nur, wenn sich etwas unter `flutter_app/kpi_admin/`
geändert hat — eine Änderung an einer PDF im Projektwurzelverzeichnis löst
keinen Deploy aus.

---

## 4. Was **nicht** automatisch deployt wird

Bewusste Entscheidung — diese drei Teile haben eigene Risiken:

| Teil | Warum manuell | Befehl |
|---|---|---|
| **Firestore-/Storage-Rules** | Ein falscher Rules-Deploy sperrt Nutzer aus oder öffnet Daten. Siehe Abschnitt 5. | `Actions → Deploy Firestore/Storage Rules` (erst `dry-run`, dann `deploy`) |
| **Cloud Functions** | Braucht Billing-Kontext und kann laufende Aufrufe abbrechen | `cd firebase && npx firebase-tools deploy --only functions` |
| **Parser-Service** | Eigener Cloud-Run-Dienst in `europe-west3`, eigenes Container-Image | Deploy aus `parser_service/` via Cloud Run |

Der Parser-Service läuft unter
`https://parser-service-641293967282.europe-west3.run.app/parse`
(konfiguriert in `lib/config/app_config.dart`).

---

## 5. Offener Punkt: Firestore-Rules

Im Repo lagen **zwei unterschiedliche** Rules-Stände:

| Datei | Umfang | Status |
|---|---|---|
| `firebase/firestore.rules` | 847 Zeilen, 28 `match`-Blöcke, kennt die Rolle `developer` | als maßgeblich behandelt |
| `flutter_app/kpi_admin/firestore.rules` | 374 Zeilen, 20 `match`-Blöcke, **ohne** `developer`-Rolle | als veraltet markiert |

Beide wurden im selben Commit (`e4c42c4`) zuletzt angefasst, daher lässt sich
aus der Historie nicht ableiten, welcher Stand tatsächlich in Firebase aktiv
ist. Da die App laut Commit-Historie eine `developer`-Rolle nutzt, ist
`firebase/firestore.rules` mit hoher Wahrscheinlichkeit der richtige — bewiesen
ist es nicht.

**Was bereits getan wurde**, damit nichts schiefgeht:

- `flutter_app/kpi_admin/firebase.json` deployt keine Rules mehr (nur noch Hosting)
- `firebase/firebase.json` deployt kein Hosting mehr (der Pfad dort war
  ohnehin falsch und hätte ein leeres Verzeichnis veröffentlicht)
- Die veralteten Kopien tragen einen Warnhinweis im Kopf
- `firestore.indexes.json` in der App wurde zu `.legacy` umbenannt

**Was noch zu klären ist:** In der Firebase Console unter
*Firestore Database → Rules* nachsehen, welcher Stand live ist, und die
verbleibende Datei entsprechend anpassen. Danach können die veralteten Kopien
gelöscht werden.

---

## 6. Lokal arbeiten

```bash
cd flutter_app/kpi_admin
flutter pub get
flutter run -d chrome
```

Im laufenden Prozess: `r` = Hot Reload, `R` = Hot Restart, `q` = Beenden.

Vor dem Pushen kurz prüfen, ob der CI-Build durchgehen wird:

```bash
flutter analyze
flutter build web --release
```

### Hinweis zu `lib/firebase_options.dart`

Diese Datei ist **bewusst eingecheckt**. Sie war zwischenzeitlich als
„Geheimnis" aus dem Repo entfernt worden, was dazu führte, dass ein frischer
Clone die App nicht bauen konnte.

Die Web-Firebase-Config ist kein Geheimnis: `apiKey`, `projectId` und
`appId` werden beim Web-Build in `main.dart.js` eingebettet und damit an jeden
Browser ausgeliefert, der die Seite öffnet. Der Schutz der Daten kommt
ausschließlich aus den Firestore- und Storage-Rules.

Echte Geheimnisse (`google-services.json`, `GoogleService-Info.plist`,
Service-Account-Keys, `.env`) bleiben weiterhin in `.gitignore`.
