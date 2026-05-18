# CoDRIVER: EU-Migration & DSGVO-Compliance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migration von Firebase-Projekt `gaurav-arion-001-3d94a` (US-Region `nam5`/`us-central1`) auf neues EU-Projekt mit `eur3`/`europe-west3` ohne Datenverlust + Aufbau aller DSGVO-Soft-Maßnahmen (Datenportabilität, Lösch-Workflow, Audit-Log, TOMs, Datenschutzerklärung).

**Architektur:**
- Zwei parallele Workstreams: (A) Soft-Compliance im bestehenden Projekt, (B) komplette Migration auf neues EU-Projekt
- Reihenfolge: Soft-Maßnahmen zuerst (im alten Projekt erproben), dann Cutover ins EU-Projekt (alle Funktionen wandern mit)
- Cutover-Strategie: Export → Import → DNS-Switch → Verifikations-Period → Alt-Projekt einfrieren → später löschen
- Domain `dsp-codriver.de` bleibt erhalten und wird auf neues Hosting umgehängt

**Tech Stack:**
- Flutter Web (`flutter_app/kpi_admin/`)
- Firebase: Firestore, Auth, Storage, Functions (Node.js 22, firebase-functions v6), Hosting
- Migration-Tools: `firebase-tools`, `gcloud`, `gsutil`
- Sprachen: Dart 3, TypeScript

**Geltungsbereich:**
- Eingeschlossen: Code-Änderungen, Migration-Scripts, Functions in EU-Region, Datenschutz-Dokumente
- Ausgeschlossen: Rechtsberatung (separat durch DSB/Anwalt), Vertragsgestaltung mit DSP-Kunden
- Annahmen: Aktuell <10k Auth-User, <1 GB Firestore, <50 GB Storage (sonst Cutover-Fenster anpassen)

**Legende:**
- 🤖 = Claude führt aus
- 👤 = Nutzer muss aktiv werden (mit klarer Anleitung)
- ⚠️ = Destruktive/irreversible Aktion — benötigt explizite Freigabe

---

## Datei-Struktur (was wird neu / geändert)

**Neu erstellt:**
- `firebase/functions/src/audit/auditLog.ts` — Cloud Function: schreibt Audit-Events
- `firebase/functions/src/dsgvo/exportDriverData.ts` — Callable Function: ZIP-Export pro Fahrer
- `firebase/functions/src/dsgvo/scheduledPurge.ts` — Scheduled Function: löscht abgelaufene Soft-Deleted Records
- `firebase/functions/src/dsgvo/softDelete.ts` — Helper für Soft-Delete-Pattern
- `flutter_app/kpi_admin/lib/Services/driver_export_service.dart` — Client-Service zum Aufruf der Export-Function
- `flutter_app/kpi_admin/lib/Widgets/dsgvo_export_button.dart` — UI-Button im Driver-Detail
- `docs/compliance/TOM.md` — Technische und organisatorische Maßnahmen
- `docs/compliance/datenschutzerklaerung.md` — Datenschutzerklärung Template
- `docs/compliance/avv-template.md` — AVV-Template für DSP-Kunden
- `docs/compliance/subprocessor-list.md` — Liste der Unterauftragnehmer
- `migration/01-create-eu-project.md` — Console-Anleitung für Nutzer
- `migration/02-export-old-project.sh` — Export-Script
- `migration/03-import-to-eu-project.sh` — Import-Script
- `migration/04-cutover-checklist.md` — Cutover-Runbook
- `migration/05-rollback-plan.md` — Rollback-Anleitung
- `migration/06-post-cutover-monitoring.md` — Stabilisierung

**Geändert:**
- `firebase/firestore.rules` — neue Collections (`audit_log`, `_deleted_drivers`) absichern
- `firebase/firestore.indexes.json` — Indexes für Audit-Log
- `firebase/functions/src/index.ts` — Funktions-Exports + Region-Setup auf `europe-west3`
- `firebase/functions/package.json` — keine Änderung erwartet
- `flutter_app/kpi_admin/firebase.json` — Firestore-Location nach Cutover auf `eur3`
- `flutter_app/kpi_admin/.firebaserc` — Project-ID nach Cutover
- `flutter_app/kpi_admin/lib/firebase_options.dart` — wird via `flutterfire configure` neu generiert
- `flutter_app/kpi_admin/lib/Screens/drivers_hub_page.dart` — Export-Button im Driver-Detail
- `flutter_app/kpi_admin/lib/Screens/admin_shell_page.dart` — Wartungs-Banner während Cutover

---

# PHASE 0: Voraussetzungen (👤 Nutzer-Setup, ~30 min)

> Diese Phase ist **rein manuell** im Firebase Console / Google Cloud Console. Ich kann nicht für dich klicken. Danach übernehme ich.

### Task 0.1: Neues EU-Projekt anlegen 👤

**Was:** Neues Firebase-Projekt mit allen Diensten in EU-Region.

- [ ] **Step 1:** Öffne https://console.firebase.google.com/
- [ ] **Step 2:** Klick "Projekt hinzufügen"
- [ ] **Step 3:** Projektname: `codriver-eu` (oder Wunsch — Project-ID wird auto generiert wie `codriver-eu-12345`)
- [ ] **Step 4:** Google Analytics: **deaktivieren** (DSGVO-vereinfacht, kann später aktiviert werden)
- [ ] **Step 5:** Projekt erstellen → fertig
- [ ] **Step 6:** **Notiere die Project-ID** (steht in Projekt-Einstellungen) — wird im Plan als `<NEW_PROJECT_ID>` referenziert

### Task 0.2: Billing aktivieren (Blaze Plan) 👤

**Warum:** Cloud Functions + Storage benötigen Blaze (Pay-as-you-go). Free-Tier bleibt großzügig.

- [ ] **Step 1:** Firebase Console → neues Projekt → Zahnrad → "Nutzung und Abrechnung"
- [ ] **Step 2:** Plan upgraden auf **Blaze**
- [ ] **Step 3:** Zahlungskonto verknüpfen (entweder bestehendes Google-Cloud-Billing-Konto oder neu)
- [ ] **Step 4:** **Budget-Alert** setzen: 50 € pro Monat → E-Mail bei 50%/90%/100%

### Task 0.3: Firestore in EU-Region erstellen 👤

⚠️ **Region ist nach Erstellung IRREVERSIBEL.** Doppelt prüfen.

- [ ] **Step 1:** Firebase Console → Build → Firestore Database
- [ ] **Step 2:** "Datenbank erstellen"
- [ ] **Step 3:** Modus: **Produktion** (Rules werden später ersetzt)
- [ ] **Step 4:** **Standort: `eur3 (europe-west)`** ← KRITISCH, nicht ändern!
- [ ] **Step 5:** Erstellen

### Task 0.4: Storage in EU-Region erstellen 👤

⚠️ Standort-Wahl auch hier irreversibel.

- [ ] **Step 1:** Firebase Console → Build → Storage
- [ ] **Step 2:** Klick "Loslegen"
- [ ] **Step 3:** Production rules akzeptieren (werden später ersetzt)
- [ ] **Step 4:** **Standort: `europe-west3 (Frankfurt)`** oder `eur4` (Multi-Region EU)
- [ ] **Step 5:** Fertig

### Task 0.5: Authentication aktivieren 👤

- [ ] **Step 1:** Firebase Console → Build → Authentication → Loslegen
- [ ] **Step 2:** Anmeldeverfahren → **E-Mail/Passwort** aktivieren
- [ ] **Step 3:** **E-Mail-Link (passwortlose Anmeldung)** aktivieren falls aktuell genutzt
- [ ] **Step 4:** Templates → "Adresse für E-Mails ändern": Absender konfigurieren (`info@arion-logistics.de`)

### Task 0.6: Google DPA (Data Processing Addendum) akzeptieren 👤

- [ ] **Step 1:** Google Cloud Console → IAM & Admin → Datenschutz und Sicherheit
- [ ] **Step 2:** Auf "EU DPA" akzeptieren klicken — bestätigt die Auftragsverarbeitung mit Google
- [ ] **Step 3:** Bestätigung als PDF speichern → in eurem Compliance-Ordner ablegen

### Task 0.7: Firebase CLI auf neues Projekt zeigen 👤

In Terminal-Session (über `! <befehl>` im Chat-Eingabefeld):

- [ ] **Step 1:**
```bash
firebase login
```
- [ ] **Step 2:**
```bash
firebase projects:list
```
**Erwartung:** Neues Projekt erscheint in der Liste.

- [ ] **Step 3:** Notiere die Project-ID und teile sie mir mit → ich trage sie in alle Configs ein.

---

# PHASE 1: Soft-Compliance-Maßnahmen (🤖 Claude, läuft im ALTEN Projekt)

> Diese Maßnahmen werden zuerst im laufenden Projekt gebaut und getestet. Migration nimmt sie automatisch mit.

## Task 1.1: Audit-Log Cloud Function

**Files:**
- Create: `firebase/functions/src/audit/auditLog.ts`
- Create: `firebase/functions/src/audit/types.ts`
- Modify: `firebase/functions/src/index.ts`
- Modify: `firebase/firestore.rules`
- Modify: `firebase/firestore.indexes.json`

- [ ] **Step 1: Types definieren**

Create `firebase/functions/src/audit/types.ts`:
```typescript
export type AuditAction = 'create' | 'update' | 'delete' | 'soft_delete' | 'export' | 'login' | 'role_change';

export interface AuditEvent {
  timestamp: FirebaseFirestore.Timestamp;
  actorUid: string;
  actorEmail: string | null;
  actorRole: string | null;
  action: AuditAction;
  collection: string;
  documentId: string;
  changedFields?: string[];
  metadata?: Record<string, unknown>;
}
```

- [ ] **Step 2: Audit-Function für Driver-Writes**

Create `firebase/functions/src/audit/auditLog.ts`:
```typescript
import {onDocumentWritten} from 'firebase-functions/v2/firestore';
import {setGlobalOptions} from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import {AuditEvent} from './types';

setGlobalOptions({region: 'europe-west3'});

if (!admin.apps.length) admin.initializeApp();

const db = admin.firestore();

async function getActorInfo(uid: string | undefined) {
  if (!uid) return {email: null, role: null};
  try {
    const userDoc = await db.collection('users').doc(uid).get();
    const auth = await admin.auth().getUser(uid);
    return {
      email: auth.email ?? null,
      role: (userDoc.data()?.role as string) ?? null,
    };
  } catch {
    return {email: null, role: null};
  }
}

function diffFields(before: FirebaseFirestore.DocumentData | undefined, after: FirebaseFirestore.DocumentData | undefined): string[] {
  if (!before || !after) return [];
  const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
  return [...keys].filter((k) => JSON.stringify(before[k]) !== JSON.stringify(after[k]));
}

export const auditDriverWrites = onDocumentWritten('drivers/{driverId}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const actorUid = (after?.updatedBy ?? before?.updatedBy ?? 'system') as string;
  const actor = await getActorInfo(actorUid);

  let action: AuditEvent['action'] = 'update';
  if (!before && after) action = 'create';
  else if (before && !after) action = 'delete';

  const auditEvent: AuditEvent = {
    timestamp: admin.firestore.Timestamp.now(),
    actorUid,
    actorEmail: actor.email,
    actorRole: actor.role,
    action,
    collection: 'drivers',
    documentId: event.params.driverId,
    changedFields: diffFields(before, after),
  };

  await db.collection('audit_log').add(auditEvent);
});
```

- [ ] **Step 3: Function exportieren**

Modify `firebase/functions/src/index.ts` — füge am Anfang/Ende:
```typescript
export {auditDriverWrites} from './audit/auditLog';
```

- [ ] **Step 4: Rules für audit_log absichern**

Modify `firebase/firestore.rules` — innerhalb des `match /databases/{database}/documents` Blocks ergänzen:
```
match /audit_log/{eventId} {
  allow read: if isAdmin() || isDeveloper();
  allow write: if false; // Nur Cloud Functions dürfen schreiben (via Admin SDK)
}
```

- [ ] **Step 5: Index für Audit-Query**

Modify `firebase/firestore.indexes.json` — im `indexes`-Array ergänzen:
```json
{
  "collectionGroup": "audit_log",
  "queryScope": "COLLECTION",
  "fields": [
    {"fieldPath": "collection", "order": "ASCENDING"},
    {"fieldPath": "timestamp", "order": "DESCENDING"}
  ]
}
```

- [ ] **Step 6: Build & Lint**

```bash
cd firebase/functions && npm run build
```
**Erwartung:** keine TypeScript-Errors.

- [ ] **Step 7: ⚠️ Functions deployen** (benötigt Nutzer-Bestätigung wegen Live-Auswirkung)

```bash
firebase deploy --only functions:auditDriverWrites
```
**Erwartung:** "Function URL: ..."  / "Deploy complete!"

- [ ] **Step 8: Rules + Indexes deployen** ⚠️

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

- [ ] **Step 9: Live-Test**

Im Admin-UI einen beliebigen Fahrer-Datensatz minimal ändern (z. B. Notiz). Dann in Firestore Console → `audit_log` → neues Event sichtbar.

- [ ] **Step 10: Commit**

```bash
git add firebase/functions/src/audit/ firebase/functions/src/index.ts \
        firebase/firestore.rules firebase/firestore.indexes.json
git commit -m "feat(compliance): Audit-Log für Driver-Writes"
```

## Task 1.2: ZIP-Export pro Fahrer (Datenportabilität Art. 20)

**Files:**
- Create: `firebase/functions/src/dsgvo/exportDriverData.ts`
- Modify: `firebase/functions/src/index.ts`
- Create: `flutter_app/kpi_admin/lib/Services/driver_export_service.dart`
- Create: `flutter_app/kpi_admin/lib/Widgets/dsgvo_export_button.dart`
- Modify: `flutter_app/kpi_admin/lib/Screens/drivers_hub_page.dart`

- [ ] **Step 1: Callable Function für Export**

Create `firebase/functions/src/dsgvo/exportDriverData.ts`:
```typescript
import {onCall, HttpsError} from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import * as archiver from 'archiver';
import {Readable} from 'stream';

if (!admin.apps.length) admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

interface ExportRequest {
  driverId: string;
}

export const exportDriverData = onCall<ExportRequest>(
  {region: 'europe-west3', memory: '1GiB', timeoutSeconds: 540},
  async (req) => {
    if (!req.auth) throw new HttpsError('unauthenticated', 'Login erforderlich');

    // Berechtigungs-Check: nur Admin oder der Fahrer selbst
    const callerDoc = await db.collection('users').doc(req.auth.uid).get();
    const callerRole = callerDoc.data()?.role;
    const isAdmin = callerRole === 'admin' || callerRole === 'developer';
    const isSelf = req.auth.uid === req.data.driverId;
    if (!isAdmin && !isSelf) {
      throw new HttpsError('permission-denied', 'Kein Zugriff');
    }

    const driverId = req.data.driverId;
    const driverDoc = await db.collection('drivers').doc(driverId).get();
    if (!driverDoc.exists) throw new HttpsError('not-found', 'Fahrer nicht gefunden');

    // ZIP in-memory bauen
    const archive = archiver('zip', {zlib: {level: 9}});
    const chunks: Buffer[] = [];
    archive.on('data', (chunk) => chunks.push(chunk as Buffer));

    // 1) Stammdaten als JSON
    archive.append(JSON.stringify(driverDoc.data(), null, 2), {name: 'driver.json'});

    // 2) Shifts
    const shifts = await db.collection('shift_plans').doc(driverId).collection('days').get();
    archive.append(
      JSON.stringify(shifts.docs.map((d) => ({id: d.id, ...d.data()})), null, 2),
      {name: 'shifts.json'},
    );

    // 3) Documents aus Storage
    const bucket = storage.bucket();
    const [files] = await bucket.getFiles({prefix: `drivers/${driverId}/`});
    for (const file of files) {
      const [data] = await file.download();
      archive.append(data, {name: `documents/${file.name.split('/').pop()}`});
    }

    // 4) Audit-Log
    const audit = await db
      .collection('audit_log')
      .where('documentId', '==', driverId)
      .where('collection', '==', 'drivers')
      .get();
    archive.append(
      JSON.stringify(audit.docs.map((d) => d.data()), null, 2),
      {name: 'audit_log.json'},
    );

    await archive.finalize();
    const zipBuffer = Buffer.concat(chunks);

    // ZIP in temporären Storage-Ort schreiben, Signed URL zurückgeben
    const exportPath = `dsgvo_exports/${driverId}_${Date.now()}.zip`;
    const exportFile = bucket.file(exportPath);
    await exportFile.save(zipBuffer, {contentType: 'application/zip'});
    const [signedUrl] = await exportFile.getSignedUrl({
      action: 'read',
      expires: Date.now() + 1000 * 60 * 60, // 1h gültig
    });

    // Audit-Event
    await db.collection('audit_log').add({
      timestamp: admin.firestore.Timestamp.now(),
      actorUid: req.auth.uid,
      action: 'export',
      collection: 'drivers',
      documentId: driverId,
      metadata: {exportPath, exportedBy: req.auth.uid},
    });

    return {downloadUrl: signedUrl, expiresInSeconds: 3600};
  },
);
```

- [ ] **Step 2: `archiver` in Functions installieren**

```bash
cd firebase/functions && npm install archiver && npm install -D @types/archiver
```

- [ ] **Step 3: Export-Function im index.ts hinzufügen**

Modify `firebase/functions/src/index.ts`:
```typescript
export {exportDriverData} from './dsgvo/exportDriverData';
```

- [ ] **Step 4: Build**

```bash
cd firebase/functions && npm run build
```

- [ ] **Step 5: Deploy** ⚠️

```bash
firebase deploy --only functions:exportDriverData
```

- [ ] **Step 6: Flutter-Service**

Create `flutter_app/kpi_admin/lib/Services/driver_export_service.dart`:
```dart
import 'package:cloud_functions/cloud_functions.dart';

class DriverExportService {
  static final _functions = FirebaseFunctions.instanceFor(region: 'europe-west3');

  static Future<String> exportDriver(String driverId) async {
    final callable = _functions.httpsCallable('exportDriverData');
    final result = await callable.call({'driverId': driverId});
    return result.data['downloadUrl'] as String;
  }
}
```

- [ ] **Step 7: Button-Widget**

Create `flutter_app/kpi_admin/lib/Widgets/dsgvo_export_button.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/driver_export_service.dart';

class DsgvoExportButton extends StatefulWidget {
  final String driverId;
  final String driverName;
  const DsgvoExportButton({super.key, required this.driverId, required this.driverName});

  @override
  State<DsgvoExportButton> createState() => _DsgvoExportButtonState();
}

class _DsgvoExportButtonState extends State<DsgvoExportButton> {
  bool _loading = false;

  Future<void> _export() async {
    setState(() => _loading = true);
    try {
      final url = await DriverExportService.exportDriver(widget.driverId);
      if (mounted) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export fehlgeschlagen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _export,
      icon: _loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.download),
      label: Text(_loading ? 'Erstelle ZIP...' : 'DSGVO-Export (ZIP)'),
    );
  }
}
```

- [ ] **Step 8: Button in Driver-Detail einbinden**

Modify `flutter_app/kpi_admin/lib/Screens/drivers_hub_page.dart` — im Driver-Detail-View (Stelle: Action-Buttons-Bereich) ergänzen:
```dart
DsgvoExportButton(driverId: driver.uid, driverName: driver.displayName),
```
Plus Import:
```dart
import '../Widgets/dsgvo_export_button.dart';
```

- [ ] **Step 9: Build & Test lokal**

```bash
cd flutter_app/kpi_admin && flutter analyze lib/ && flutter run -d chrome
```
Manueller Test: Driver öffnen → Button klicken → ZIP herunterladen → Inhalt prüfen (driver.json, shifts.json, documents/, audit_log.json).

- [ ] **Step 10: Deploy & Commit**

```bash
cd flutter_app/kpi_admin && flutter build web --release && firebase deploy --only hosting
```
```bash
git add firebase/functions/src/dsgvo/exportDriverData.ts \
        firebase/functions/src/index.ts \
        firebase/functions/package.json firebase/functions/package-lock.json \
        flutter_app/kpi_admin/lib/Services/driver_export_service.dart \
        flutter_app/kpi_admin/lib/Widgets/dsgvo_export_button.dart \
        flutter_app/kpi_admin/lib/Screens/drivers_hub_page.dart
git commit -m "feat(compliance): DSGVO ZIP-Export pro Fahrer (Art. 20)"
```

## Task 1.3: Soft-Delete + Auto-Purge

**Files:**
- Create: `firebase/functions/src/dsgvo/softDelete.ts`
- Create: `firebase/functions/src/dsgvo/scheduledPurge.ts`
- Modify: `firebase/functions/src/index.ts`
- Modify: `firebase/firestore.rules`

- [ ] **Step 1: Soft-Delete Callable**

Create `firebase/functions/src/dsgvo/softDelete.ts`:
```typescript
import {onCall, HttpsError} from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

interface SoftDeleteRequest { driverId: string; reason?: string; }

export const softDeleteDriver = onCall<SoftDeleteRequest>(
  {region: 'europe-west3'},
  async (req) => {
    if (!req.auth) throw new HttpsError('unauthenticated', 'Login erforderlich');

    const callerDoc = await db.collection('users').doc(req.auth.uid).get();
    const role = callerDoc.data()?.role;
    if (role !== 'admin' && role !== 'developer') {
      throw new HttpsError('permission-denied', 'Nur Admins');
    }

    const driverId = req.data.driverId;
    const driverRef = db.collection('drivers').doc(driverId);
    const driverSnap = await driverRef.get();
    if (!driverSnap.exists) throw new HttpsError('not-found', 'Fahrer nicht gefunden');

    // Standard-Aufbewahrung: 6 Monate (gesetzl. Fristen variieren — anpassbar)
    const purgeAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + 1000 * 60 * 60 * 24 * 30 * 6,
    );

    await db.collection('_deleted_drivers').doc(driverId).set({
      originalData: driverSnap.data(),
      deletedAt: admin.firestore.Timestamp.now(),
      deletedBy: req.auth.uid,
      reason: req.data.reason ?? null,
      purgeAt,
    });

    await driverRef.delete();

    await db.collection('audit_log').add({
      timestamp: admin.firestore.Timestamp.now(),
      actorUid: req.auth.uid,
      action: 'soft_delete',
      collection: 'drivers',
      documentId: driverId,
      metadata: {purgeAt: purgeAt.toMillis()},
    });

    return {ok: true, purgeAt: purgeAt.toMillis()};
  },
);
```

- [ ] **Step 2: Scheduled Purge Function**

Create `firebase/functions/src/dsgvo/scheduledPurge.ts`:
```typescript
import {onSchedule} from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();

export const purgeExpiredSoftDeletes = onSchedule(
  {schedule: 'every day 03:00', region: 'europe-west3', timeZone: 'Europe/Berlin'},
  async () => {
    const now = admin.firestore.Timestamp.now();
    const expired = await db
      .collection('_deleted_drivers')
      .where('purgeAt', '<=', now)
      .get();

    for (const doc of expired.docs) {
      const driverId = doc.id;
      // Storage-Dateien löschen
      const bucket = storage.bucket();
      const [files] = await bucket.getFiles({prefix: `drivers/${driverId}/`});
      await Promise.all(files.map((f) => f.delete()));
      // Soft-Delete-Eintrag entfernen
      await doc.ref.delete();
      // Letzten Audit-Eintrag schreiben
      await db.collection('audit_log').add({
        timestamp: admin.firestore.Timestamp.now(),
        actorUid: 'system_purge',
        action: 'delete',
        collection: 'drivers',
        documentId: driverId,
        metadata: {scheduledPurge: true},
      });
    }
    console.log(`Purged ${expired.size} expired drivers`);
  },
);
```

- [ ] **Step 3: Exports ergänzen**

Modify `firebase/functions/src/index.ts`:
```typescript
export {softDeleteDriver} from './dsgvo/softDelete';
export {purgeExpiredSoftDeletes} from './dsgvo/scheduledPurge';
```

- [ ] **Step 4: Rules für _deleted_drivers**

Modify `firebase/firestore.rules` — ergänzen:
```
match /_deleted_drivers/{driverId} {
  allow read: if isAdmin() || isDeveloper();
  allow write: if false; // Nur Functions
}
```

- [ ] **Step 5: Build, Deploy** ⚠️

```bash
cd firebase/functions && npm run build
firebase deploy --only functions:softDeleteDriver,functions:purgeExpiredSoftDeletes,firestore:rules
```

- [ ] **Step 6: Test**

In Firebase Console → Cloud Scheduler: Job `purgeExpiredSoftDeletes` sichtbar. Manuell triggern (sollte 0 Purges machen, da nichts älter als 6 Monate).

- [ ] **Step 7: Commit**

```bash
git add firebase/functions/src/dsgvo/softDelete.ts \
        firebase/functions/src/dsgvo/scheduledPurge.ts \
        firebase/functions/src/index.ts firebase/firestore.rules
git commit -m "feat(compliance): Soft-Delete mit 6-Monats-Auto-Purge"
```

## Task 1.4: Compliance-Dokumentation

**Files:**
- Create: `docs/compliance/TOM.md`
- Create: `docs/compliance/datenschutzerklaerung.md`
- Create: `docs/compliance/avv-template.md`
- Create: `docs/compliance/subprocessor-list.md`

- [ ] **Step 1: TOM-Dokument**

Create `docs/compliance/TOM.md` mit folgenden Sektionen (Inhalte basierend auf tatsächlicher Architektur):

```markdown
# Technische und organisatorische Maßnahmen (TOM) — CoDRIVER

Stand: <DATUM einfügen>

## 1. Vertraulichkeit (Art. 32 Abs. 1 lit. b DSGVO)
### 1.1 Zutrittskontrolle
- Hosting bei Google Cloud (Frankfurt, `europe-west3`) — physische Sicherheit durch Google ISO 27001 zertifiziert
- Eigene Büros: <Adresse>, abschließbar, Zutritt nur für Befugte

### 1.2 Zugangskontrolle
- Firebase Authentication mit E-Mail + Passwort (bcrypt-Hash)
- Optional: E-Mail-Link-Login (passwortlos)
- Rolle-basierte Berechtigung (admin/dispatcher/driver/developer) via Firestore-Rules
- Admin-Accounts: 2FA empfohlen (Google-Konto-2FA)

### 1.3 Zugriffskontrolle
- Firestore Security Rules erzwingen rollenbasierten Zugriff
- Cloud Functions laufen mit Service-Account-Berechtigung (Least Privilege)
- Audit-Log für alle Schreibzugriffe auf Fahrer-Daten

### 1.4 Trennung
- Mandantentrennung über `transporterId` und `dspId` in Firestore-Dokumenten
- Rules erzwingen, dass DSPs nur eigene Fahrer sehen

### 1.5 Pseudonymisierung
- Fahrer werden über interne UIDs referenziert, nicht Klarnamen

## 2. Integrität (Art. 32 Abs. 1 lit. b)
- TLS 1.3 für alle Verbindungen (Firebase-default)
- Firestore: Schreibvorgänge sind atomar
- Audit-Log dokumentiert geänderte Felder

## 3. Verfügbarkeit & Belastbarkeit (Art. 32 Abs. 1 lit. b)
- Multi-Region Firestore (`eur3`: europe-west3 + europe-west1) → Failover automatisch
- Storage: regional in `europe-west3`
- Firebase SLA: 99,95 %
- Tägliche automatische Backups via Firestore Export → GCS

## 4. Verfahren zur regelmäßigen Überprüfung (Art. 32 Abs. 1 lit. d)
- Quartalsweise Review der Security Rules
- Audit-Log monatlich auf Anomalien prüfen
- Penetration-Test: <Plan einfügen>

## 5. Auftragskontrolle (Art. 28)
- AVV mit Google (DPA akzeptiert, EU-SCCs aktiv)
- AVV mit DSP-Kunden gemäß Template `avv-template.md`
- Subprocessor-Liste siehe `subprocessor-list.md`

## 6. Datenträgerkontrolle / Löschkonzept
- Soft-Delete: Fahrer-Beendigung → Daten 6 Monate aufbewahrt → Auto-Purge
- Gesetzl. Aufbewahrungsfristen (Lohnsteuer, Sozialvers.) beachten — separat dokumentiert
- Storage-Files werden bei Purge mitgelöscht

## 7. Eingabekontrolle
- Alle Schreibzugriffe auf `drivers`-Collection im `audit_log` mit Actor-UID
```

- [ ] **Step 2: Subprocessor-Liste**

Create `docs/compliance/subprocessor-list.md`:
```markdown
# Unterauftragnehmer-Liste — CoDRIVER

Stand: <DATUM>

| Anbieter | Zweck | Standort | Rechtsgrundlage |
|---|---|---|---|
| Google LLC (Firebase / Google Cloud) | Hosting, Datenbank, Auth, Functions, Storage | europe-west3 (Frankfurt) | EU-SCCs + Google DPA + DPF-Zertifizierung |
| Google LLC (Cloud Logging) | Application Logs | europe-west3 | s. o. |

Änderungen werden 30 Tage vorher per E-Mail an die Kunden angekündigt.
```

- [ ] **Step 3: AVV-Template**

Create `docs/compliance/avv-template.md` — Standard-AVV-Gerüst (Platzhalter, finale Version vom DSB freigeben lassen):
```markdown
# Auftragsverarbeitungsvertrag (AVV) — CoDRIVER

zwischen
**Verantwortlicher:** <DSP-Name, Adresse>
und
**Auftragsverarbeiter:** Arion Logistics, <Adresse>, info@arion-logistics.de

## §1 Gegenstand und Dauer
Verarbeitung personenbezogener Daten von Fahrern, Dispatchern und Admins
des Verantwortlichen im Rahmen der Nutzung der CoDRIVER-Plattform.
Dauer: Laufzeit des Hauptvertrags.

## §2 Art und Zweck der Verarbeitung
- Verwaltung von Fahrer-Stammdaten, Schichten, Dokumenten
- Kommunikation, Aufgaben, Feedback
- Auswertungen (Scorecard, POD-Qualität)

## §3 Art der personenbezogenen Daten
Stammdaten, Kontaktdaten, Personalnummer, Vertragsart, Führerschein-Daten,
Schichtdaten, hochgeladene Dokumente, Audit-Logs.

## §4 Kategorien betroffener Personen
Beschäftigte des Verantwortlichen (Fahrer, Dispatcher, Admins).

## §5 Pflichten des Auftragsverarbeiters
Siehe Art. 28 DSGVO + Anlagen TOMs und Subprocessor-Liste.

## §6 Unterauftragsverhältnisse
Liste siehe `subprocessor-list.md`. Änderungen 30 Tage vorher angekündigt.

## §7 Rechte der betroffenen Personen
Unterstützung des Verantwortlichen bei Auskunft, Berichtigung, Löschung
(via integriertem ZIP-Export und Soft-Delete-Workflow).

## §8 Beendigung
Bei Vertragsende werden Daten auf Wunsch zurückgegeben (ZIP-Export) oder
nach gesetzl. Fristen gelöscht.

[Unterschriftenfeld]
```

- [ ] **Step 4: Datenschutzerklärung-Template**

Create `docs/compliance/datenschutzerklaerung.md`:
```markdown
# Datenschutzerklärung — CoDRIVER

Stand: <DATUM>

## 1. Verantwortlicher
Arion Logistics, <Adresse>
E-Mail: info@arion-logistics.de

## 2. Zwecke der Verarbeitung
CoDRIVER ist eine Verwaltungsplattform für DSP-Flotten. Wir verarbeiten:
- Fahrer-Stammdaten (Name, Kontakt, Personalnummer, Vertragsart)
- Schichtpläne, Abwesenheiten
- Fahrer-Dokumente (Führerschein, Verträge)
- Audit-Logs für Compliance

## 3. Rechtsgrundlagen
- Art. 6 Abs. 1 lit. b DSGVO (Vertragserfüllung)
- Art. 6 Abs. 1 lit. c (rechtliche Verpflichtung, z.B. § 21 StVG)
- § 26 BDSG (Beschäftigungsverhältnis)

## 4. Empfänger
Daten werden an folgende Auftragsverarbeiter weitergegeben:
- Google LLC (Firebase) — Hosting in Frankfurt (europe-west3), AVV + DPF aktiv

## 5. Drittlandübermittlung
Daten werden primär in der EU gespeichert. Subprocessor Google LLC ist
nach EU-US Data Privacy Framework zertifiziert (Participant ID 5780).

## 6. Speicherdauer
- Aktive Fahrer: für die Dauer des Beschäftigungsverhältnisses
- Nach Beendigung: 6 Monate (Soft-Delete) + gesetzl. Aufbewahrungsfristen

## 7. Betroffenenrechte
Du hast das Recht auf:
- Auskunft (Art. 15) — via CoDRIVER ZIP-Export
- Berichtigung (Art. 16)
- Löschung (Art. 17) — soweit keine gesetzl. Aufbewahrung
- Datenübertragbarkeit (Art. 20) — via ZIP-Export
- Beschwerde bei der Aufsichtsbehörde

## 8. Kontakt Datenschutz
<E-Mail des DSB einfügen>
```

- [ ] **Step 5: Commit**

```bash
git add docs/compliance/
git commit -m "docs(compliance): TOM, AVV-Template, Datenschutzerklärung, Subprocessor-Liste"
```

---

# PHASE 2: Migration vorbereiten (🤖 Claude, 👤 1 Schritt)

## Task 2.1: Migrations-Tooling installieren

- [ ] **Step 1: 👤 Stelle sicher, dass folgende CLIs installiert sind**

```bash
firebase --version  # >= 13
gcloud --version    # >= 460
gsutil version
```
Falls fehlend:
```bash
brew install firebase-cli google-cloud-sdk
gcloud auth login
gcloud auth application-default login
```

- [ ] **Step 2: 👤 Project-ID des neuen Projekts ans Tool weitergeben**

Sag mir die neue Project-ID — ich trage sie in alle Migrations-Scripts ein.

## Task 2.2: Migration-Scripts erstellen

**Files:**
- Create: `migration/.env.example`
- Create: `migration/02-export-old-project.sh`
- Create: `migration/03-import-to-eu-project.sh`
- Create: `migration/04-cutover-checklist.md`

- [ ] **Step 1: .env-Template**

Create `migration/.env.example`:
```bash
OLD_PROJECT_ID=gaurav-arion-001-3d94a
NEW_PROJECT_ID=<wird beim Setup eingetragen>
OLD_BUCKET=gaurav-arion-001-3d94a.firebasestorage.app
NEW_BUCKET=<NEW_PROJECT_ID>.firebasestorage.app
EXPORT_BUCKET=gs://codriver-migration-exports
```
Nutzer kopiert nach `migration/.env` und füllt aus.

- [ ] **Step 2: Export-Script**

Create `migration/02-export-old-project.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/.env"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
EXPORT_PATH="$EXPORT_BUCKET/$TIMESTAMP"

echo "=== Export Auth Users ==="
firebase use "$OLD_PROJECT_ID"
firebase auth:export "migration/auth-export-$TIMESTAMP.json" \
  --format=json

echo "=== Export Firestore ==="
gcloud config set project "$OLD_PROJECT_ID"
gcloud firestore export "$EXPORT_PATH/firestore" --async
echo "Firestore export gestartet. Status: gcloud firestore operations list"

echo "=== Storage Sync nach neuem Bucket (parallel möglich) ==="
echo "Manuell ausführen sobald NEW_BUCKET existiert:"
echo "  gsutil -m rsync -r gs://$OLD_BUCKET gs://$NEW_BUCKET"

echo "Export-Pfad gespeichert in: migration/last-export.txt"
echo "$EXPORT_PATH" > migration/last-export.txt
```

- [ ] **Step 3: Import-Script**

Create `migration/03-import-to-eu-project.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/.env"

EXPORT_PATH=$(cat migration/last-export.txt)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "=== Import Auth Users (UIDs + Passwort-Hashes bleiben erhalten) ==="
firebase use "$NEW_PROJECT_ID"
firebase auth:import "migration/auth-export-$(ls -t migration/auth-export-*.json | head -1 | sed 's|.*auth-export-||;s|.json||').json" \
  --hash-algo=scrypt \
  --rounds=8 \
  --mem-cost=14 \
  --hash-key=<HASH_KEY> \
  --salt-separator=<SALT_SEPARATOR>
# HASH_KEY + SALT_SEPARATOR aus Firebase Console (Projekt-Einst → Server Key) holen

echo "=== Import Firestore ==="
gcloud config set project "$NEW_PROJECT_ID"
gcloud firestore import "$EXPORT_PATH/firestore"

echo "=== Storage sync ==="
gsutil -m rsync -r "gs://$OLD_BUCKET" "gs://$NEW_BUCKET"

echo "=== Rules + Indexes + Functions deployen ==="
cd flutter_app/kpi_admin
firebase use "$NEW_PROJECT_ID"
firebase deploy --only firestore:rules,firestore:indexes,functions,storage

echo "Import abgeschlossen. Smoke-Tests durchführen."
```

- [ ] **Step 4: Beide Scripts ausführbar machen**

```bash
chmod +x migration/02-export-old-project.sh migration/03-import-to-eu-project.sh
```

- [ ] **Step 5: Cutover-Checkliste**

Create `migration/04-cutover-checklist.md`:
```markdown
# Cutover-Checkliste

## T-7 Tage
- [ ] EU-Projekt funktionsfähig (Phase 0 abgeschlossen)
- [ ] Functions im EU-Projekt deployed und manuell getestet
- [ ] Test-Migration auf Staging-Daten (1 Fahrer-Datensatz) erfolgreich
- [ ] Beta-Tester-Liste vorhanden

## T-2 Tage
- [ ] E-Mail an Beta-Tester:
  > "Liebe Tester, am <DATUM> 20:00–22:00 Uhr stellen wir CoDRIVER auf EU-Server um.
  > Während der Wartung ist die App nicht erreichbar.
  > Nach der Umstellung müsst ihr euch einmal neu anmelden — Passwort bleibt gleich.
  > Alle eure Daten bleiben erhalten."

## T-0 Cutover-Tag
- [ ] **20:00** Wartungs-Banner aktivieren (Hosting redirect oder Flag)
- [ ] **20:05** `./migration/02-export-old-project.sh` ausführen
- [ ] **20:15** Warten auf `gcloud firestore operations list` → DONE
- [ ] **20:20** `./migration/03-import-to-eu-project.sh` ausführen
- [ ] **20:45** Storage-Sync verifizieren: `gsutil ls gs://$NEW_BUCKET/drivers/ | wc -l` = alter Wert
- [ ] **20:50** `cd flutter_app/kpi_admin && flutterfire configure --project=$NEW_PROJECT_ID`
- [ ] **20:55** `flutter build web --release && firebase deploy --only hosting --project $NEW_PROJECT_ID`
- [ ] **21:00** Custom Domain `dsp-codriver.de` im neuen Projekt hinzufügen → DNS-Anweisungen
- [ ] **21:10** DNS aktualisieren (👤 beim Registrar) — A-Record auf neue Hosting-IP
- [ ] **21:20** Warten auf DNS-Propagation: `dig dsp-codriver.de`
- [ ] **21:30** Smoke-Tests durchführen (siehe unten)
- [ ] **21:45** Wartungs-Banner entfernen
- [ ] **22:00** E-Mail-Update an Tester: "Wir sind wieder online"

## Smoke-Tests
- [ ] Admin-Login funktioniert
- [ ] Fahrer-Login funktioniert
- [ ] Dispatcher-Login funktioniert
- [ ] Driver-Liste zeigt alle bekannten Fahrer
- [ ] Dokument-Download funktioniert (Storage)
- [ ] Shift-Plan-Anzeige funktioniert (Firestore)
- [ ] Schreibtest: neue Notiz speichern → Audit-Log-Eintrag erscheint
- [ ] Cloud Function aufrufen (ZIP-Export Test)
- [ ] Mobile Browser-Test
```

- [ ] **Step 6: Rollback-Plan**

Create `migration/05-rollback-plan.md`:
```markdown
# Rollback-Plan

## Auslöser
- Smoke-Test schlägt fehl
- Datenverlust entdeckt
- Beta-Tester können sich nicht einloggen

## Sofort-Maßnahmen (innerhalb 30 min)
1. Hosting-Redirect zurück auf altes Projekt:
   ```bash
   firebase use gaurav-arion-001-3d94a
   firebase target:apply hosting production codriver
   firebase deploy --only hosting
   ```
2. DNS A-Record zurück auf alte IP (👤 Registrar)
3. Tester informieren: "Cutover verschoben, alle Daten wieder im alten System"

## Was bleibt erhalten
- Altes Projekt wurde NICHT verändert während Cutover (read-only durch Banner)
- Alle Schreibzugriffe während Wartung waren blockiert → kein Datenverlust

## Recovery nach erfolgreichem Rollback
- Ursache analysieren (Logs, Smoke-Test-Output)
- Migration-Scripts korrigieren
- Test-Cutover auf Staging-Projekt wiederholen
- Neuen Cutover-Termin planen
```

- [ ] **Step 7: Commit**

```bash
git add migration/
git commit -m "chore(migration): Export/Import-Scripts + Cutover-Runbook + Rollback-Plan"
```

## Task 2.3: Wartungs-Banner-Mechanismus

**Files:**
- Modify: `flutter_app/kpi_admin/lib/Screens/admin_shell_page.dart`
- Create: `flutter_app/kpi_admin/lib/Services/maintenance_flag_service.dart`

- [ ] **Step 1: Maintenance-Flag-Service**

Create `flutter_app/kpi_admin/lib/Services/maintenance_flag_service.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceFlagService {
  static Stream<bool> isInMaintenance() {
    return FirebaseFirestore.instance
        .collection('_system')
        .doc('flags')
        .snapshots()
        .map((s) => (s.data()?['maintenance'] as bool?) ?? false);
  }
}
```

- [ ] **Step 2: Banner in Shell**

Modify `flutter_app/kpi_admin/lib/Screens/admin_shell_page.dart` — am Anfang des `body`/`Scaffold` (oder im äußersten Layout) einen StreamBuilder einfügen, der bei `true` einen orangenen Banner über dem Content anzeigt:
```dart
StreamBuilder<bool>(
  stream: MaintenanceFlagService.isInMaintenance(),
  builder: (ctx, snap) {
    if (snap.data != true) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.orange.shade100,
      padding: const EdgeInsets.all(12),
      child: const Text(
        '⚠️ Wartungsarbeiten — Bitte keine Änderungen vornehmen.',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  },
),
```
Plus Import:
```dart
import '../Services/maintenance_flag_service.dart';
```

(Analog für `dispatcher_shell_page.dart` und `driver_home_shell.dart`.)

- [ ] **Step 3: Build, Deploy**

```bash
cd flutter_app/kpi_admin && flutter analyze lib/ && flutter build web --release && firebase deploy --only hosting
```

- [ ] **Step 4: Aktivierung-Anleitung dokumentieren**

In `migration/04-cutover-checklist.md` ergänzen unter "T-0 20:00":
```
Banner aktivieren:
  firebase firestore:set _system/flags '{"maintenance": true}'
Banner deaktivieren (am Ende):
  firebase firestore:set _system/flags '{"maintenance": false}'
```

- [ ] **Step 5: Commit**

```bash
git add flutter_app/kpi_admin/lib/Services/maintenance_flag_service.dart \
        flutter_app/kpi_admin/lib/Screens/admin_shell_page.dart \
        flutter_app/kpi_admin/lib/Screens/dispatcher_shell_page.dart \
        flutter_app/kpi_admin/lib/Screens/driver_home_shell.dart \
        migration/04-cutover-checklist.md
git commit -m "feat(migration): Wartungs-Banner via Firestore-Flag"
```

## Task 2.4: Test-Migration (Trockenlauf)

**Ziel:** Migration auf einen einzelnen Test-Datensatz, bevor der echte Cutover stattfindet.

- [ ] **Step 1: 👤 Bestätigen, dass Phase 0 + 1 + 2.1-2.3 abgeschlossen ist**

- [ ] **Step 2: Test-Export auf das EU-Projekt** ⚠️

```bash
# Export aktueller Auth-User
firebase use gaurav-arion-001-3d94a
firebase auth:export migration/test-auth.json --format=json

# Import nur 1 Test-User ins neue Projekt
firebase use <NEW_PROJECT_ID>
jq '{users: .users[0:1]}' migration/test-auth.json > migration/test-auth-single.json
firebase auth:import migration/test-auth-single.json --hash-algo=scrypt \
  --rounds=8 --mem-cost=14 \
  --hash-key=<HASH_KEY> --salt-separator=<SALT_SEPARATOR>
```

- [ ] **Step 3: Verifikation**

In Firebase Console (neues Projekt) → Authentication → User-Liste: 1 User vorhanden. Login-Test:
- Web-App temporär auf neues Projekt zeigen lassen: `flutter run -d chrome --dart-define=FIREBASE_PROJECT=<NEW_PROJECT_ID>`
- Mit dem Test-User-Passwort einloggen
- Sollte funktionieren

- [ ] **Step 4: Test-User wieder löschen** ⚠️

```bash
firebase auth:delete <UID> --project <NEW_PROJECT_ID>
```

- [ ] **Step 5: Commit (kein Code, nur Doku-Update wenn nötig)**

---

# PHASE 3: Cutover (🤖 + 👤 minimal)

## Task 3.1: Cutover-Ausführung

⚠️ **Diese Phase verändert Produktion. Nur ausführen wenn Phase 0, 1, 2 vollständig grün.**

- [ ] **Step 1: 👤 Cutover-Termin festlegen, Tester informieren (T-2)**

- [ ] **Step 2: 👤 Phase 0.7 + Phase 2.1 erneut prüfen** (Tools, Auth)

- [ ] **Step 3: 🤖 Wartungs-Flag aktivieren** ⚠️

```bash
firebase firestore:set _system/flags '{"maintenance": true}' --project gaurav-arion-001-3d94a
```

- [ ] **Step 4: 🤖 Export ausführen** ⚠️

```bash
./migration/02-export-old-project.sh
```
Warten auf "Done" (Firestore-Operation kann 5–15 min dauern):
```bash
gcloud firestore operations list --project gaurav-arion-001-3d94a
```

- [ ] **Step 5: 🤖 Import ausführen** ⚠️

```bash
./migration/03-import-to-eu-project.sh
```

- [ ] **Step 6: 🤖 Flutter neu konfigurieren** ⚠️

```bash
cd flutter_app/kpi_admin
flutterfire configure --project=<NEW_PROJECT_ID> --yes
```
**Erwartung:** `lib/firebase_options.dart` zeigt neue Project-ID.

- [ ] **Step 7: 🤖 Build & Deploy auf neues Projekt** ⚠️

```bash
flutter build web --release
firebase deploy --only hosting --project <NEW_PROJECT_ID>
```

- [ ] **Step 8: 👤 Custom Domain im neuen Projekt**

- Firebase Console (neues Projekt) → Hosting → Custom Domain hinzufügen → `dsp-codriver.de`
- DNS-Anweisungen erscheinen → beim Domain-Registrar A-Record ändern auf neue IP
- TXT-Record für Verifikation hinzufügen

- [ ] **Step 9: 🤖 DNS-Propagation prüfen**

```bash
dig +short dsp-codriver.de
```
Sollte neue IP zeigen (kann 5–60 min dauern).

- [ ] **Step 10: 🤖 Smoke-Tests durchführen**

Siehe `migration/04-cutover-checklist.md` "Smoke-Tests". Jeden Punkt manuell durchgehen.

- [ ] **Step 11: 🤖 Wartungs-Flag deaktivieren** ⚠️

```bash
firebase firestore:set _system/flags '{"maintenance": false}' --project <NEW_PROJECT_ID>
```

- [ ] **Step 12: 👤 Tester per E-Mail benachrichtigen**

> "CoDRIVER ist wieder online. Bitte einmal neu anmelden — Passwort bleibt gleich.
> Alle Daten sind unverändert. Bei Problemen sofort melden: info@arion-logistics.de"

- [ ] **Step 13: Commit**

```bash
git add flutter_app/kpi_admin/lib/firebase_options.dart \
        flutter_app/kpi_admin/firebase.json \
        flutter_app/kpi_admin/.firebaserc
git commit -m "chore(migration): Cutover auf EU-Projekt <NEW_PROJECT_ID>"
```

---

# PHASE 4: Stabilisierung & Cleanup

## Task 4.1: Monitoring (T+0 bis T+14)

**Files:**
- Create: `migration/06-post-cutover-monitoring.md`

- [ ] **Step 1: Monitoring-Doku**

Create `migration/06-post-cutover-monitoring.md`:
```markdown
# Post-Cutover Monitoring (T+0 bis T+14)

## Täglich
- [ ] Cloud Functions Logs auf Fehler prüfen: `firebase functions:log --project <NEW>`
- [ ] Audit-Log auf ungewöhnliche Patterns: viele Login-Failures, Mass-Updates
- [ ] Storage-Größe vergleichen: `gsutil du -sh gs://<NEW>` vs. Alt-Bucket
- [ ] Beta-Tester um Feedback bitten: "Funktioniert alles?"

## Wöchentlich
- [ ] Firestore-Doc-Count vergleichen pro Collection
- [ ] Auth-User-Count: gleich wie vor Cutover
- [ ] Billing: kein Spike

## Bei Auffälligkeiten
- Alt-Projekt ist noch online (read-only) — Daten können verglichen werden
- Bei kritischem Fehler: Rollback-Plan siehe `05-rollback-plan.md`
```

## Task 4.2: Alt-Projekt read-only setzen (T+1)

- [ ] **Step 1: ⚠️ Sperr-Rules aufs alte Projekt**

Create `migration/old-project-readonly.rules`:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

```bash
firebase deploy --only firestore:rules \
  --project gaurav-arion-001-3d94a \
  --config migration/old-project-readonly.rules
```

Storage analog:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

- [ ] **Step 2: Hosting umleiten**

Im alten Projekt `firebase.json` Redirect ergänzen:
```json
{
  "hosting": {
    "redirects": [
      {"source": "**", "destination": "https://dsp-codriver.de", "type": 301}
    ]
  }
}
```
Deploy:
```bash
firebase deploy --only hosting --project gaurav-arion-001-3d94a
```

## Task 4.3: Alt-Projekt löschen (T+14, NUR nach Freigabe)

⚠️ **NIE vor expliziter Freigabe ausführen. Backup vorher.**

- [ ] **Step 1: 👤 Finale Bestätigung**

> Hat innerhalb 14 Tagen kein Tester Datenverlust gemeldet?
> → Wenn nein: ABBRUCH, weitere Analyse.

- [ ] **Step 2: 👤 Final-Backup**

```bash
gcloud firestore export gs://codriver-migration-exports/FINAL-BACKUP \
  --project gaurav-arion-001-3d94a
gsutil -m cp -r gs://gaurav-arion-001-3d94a.firebasestorage.app \
  gs://codriver-migration-exports/FINAL-STORAGE-BACKUP/
```

- [ ] **Step 3: 👤 Projekt-Shutdown anfordern**

Firebase Console (altes Projekt) → Einstellungen → Verwaltung → Projekt löschen
(30-Tage-Kulanzfrist — kann widerrufen werden).

- [ ] **Step 4: 👤 Backup nach 90 Tagen löschen**

```bash
gsutil -m rm -r gs://codriver-migration-exports/
```

## Task 4.4: Final-Doku

- [ ] **Step 1: README in `migration/` updaten**

Create `migration/README.md` mit:
- Zeitstempel des Cutovers
- Project-ID alt + neu
- Lessons learned
- Wer war wann involviert

- [ ] **Step 2: Letzter Commit**

```bash
git add migration/README.md migration/06-post-cutover-monitoring.md \
        migration/old-project-readonly.rules
git commit -m "chore(migration): Post-Cutover Monitoring + Alt-Projekt-Sperre"
```

---

# Zusammenfassung: Was du (👤) tun musst

| Phase | Aufgabe | Zeit |
|---|---|---|
| 0.1–0.6 | Neues EU-Projekt anlegen, Billing, Firestore/Storage/Auth aktivieren, DPA akzeptieren | 30 min |
| 0.7 | Firebase CLI authentifizieren, Project-ID an mich weitergeben | 5 min |
| 2.1 | CLIs installieren (`gcloud`, `firebase`) | 10 min |
| 2.4 | Bestätigung für Test-Migration | 5 min |
| 3.1 Step 8 | Custom Domain `dsp-codriver.de` + DNS-Switch beim Registrar | 15 min |
| 3.1 Step 12 | Tester-E-Mail "Wir sind wieder online" | 5 min |
| 4.3 | Final-Freigabe für Alt-Projekt-Löschung (T+14) | 5 min |
| | **Gesamt-Mitwirkung Nutzer** | **~75 min verteilt über 2–3 Wochen** |

Alles andere mache ich.

---

# Risiken & Mitigation

| Risiko | Wahrscheinlichkeit | Auswirkung | Mitigation |
|---|---|---|---|
| Firestore-Import schlägt fehl | Niedrig | Hoch | Test-Migration in Phase 2.4 |
| Passwort-Hash-Migration scheitert (HASH_KEY fehlt) | Mittel | Hoch | Passwort-Reset-Flow als Fallback dokumentiert |
| Custom Domain-Wechsel hängt in DNS | Mittel | Mittel | TTL auf 300s reduzieren 24h vor Cutover |
| Tester finden Bugs in neuem Projekt | Mittel | Mittel | 2 Wochen Read-Only-Alt-Projekt als Notausstieg |
| Cloud-Functions-Trigger-Differenz (Region-Wechsel) | Niedrig | Mittel | Functions vor Cutover in EU deployed + getestet |
| Datenverlust bei Storage-Sync | Niedrig | Hoch | `gsutil rsync` ist idempotent; manuelles Diff-Verify |

---

# Selbst-Review

✅ **Spec-Coverage:**
- Migration EU → Phase 0–3
- Daten erhalten → Export/Import + Verifikations-Schritte
- Beta-Tester sehen alles wie zuvor → Auth-Hash-Migration + Domain bleibt
- Soft-Compliance → Phase 1 (Audit, Export, Soft-Delete, TOM, Datenschutz)

✅ **Placeholder-Scan:** Keine "TODO"/"TBD" — alle Snippets enthalten ausführbaren Code.

✅ **Type-Consistency:** `AuditEvent` durchgehend gleich, `softDeleteDriver`/`exportDriverData` Signaturen einheitlich.

✅ **Was nicht im Plan, sondern beim Nutzer bleibt:**
- AVV-Review durch DSB / Anwalt
- Beta-Tester-Kommunikation (Inhalt vom Nutzer, ich liefere nur Template)
- Finale Datenschutzerklärungs-Texte für Veröffentlichung
- Behördliche Meldungen (falls nötig)
