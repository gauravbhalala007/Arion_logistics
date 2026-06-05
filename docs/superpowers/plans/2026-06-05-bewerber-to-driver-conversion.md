# Bewerber → Driver Umwandlung — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Einen Recruiting-Bewerber im finalen Schritt zu einem Driver umwandeln, wobei alle Stammdaten, Custom-Antworten und die 5 hochgeladenen Dokumente ins Driver-Profil übernommen werden; der Bewerber bleibt im Recruiting und wird als „übernommen" markiert.

**Architecture:** Der bestehende `Driver hinzufügen`-Dialog (`add_driver_dialog.dart`) wird erweitert: Er nimmt optional die Quell-`RecruitingApplication` an, schreibt deren Daten flach ins Driver-Dokument, kopiert die 5 Storage-Dateien client-seitig nach `driver_docs/{tid}` bzw. `driver_profile_photos/{tid}` und legt passende Einträge in der Driver-`documents`-Subcollection an. Nach Erfolg markiert er den Bewerber mit `convertedToDriver`. Das Recruiting-Detail (`admin_recruiting_panel.dart`) übergibt die Bewerbung an den Dialog, zeigt danach ein „Als Driver übernommen"-Badge und deaktiviert den Button.

**Tech Stack:** Flutter (Web), Dart, `cloud_firestore`, `firebase_storage`, `cloud_functions` (bestehende `createDriverLogin` Function — unverändert).

**Keine Rules-Änderung nötig:** Admin darf laut `firebase/storage.rules` Recruiting-Dateien lesen (`recruiting/{adminUid}/…`, Z.227-232) und nach `driver_docs/{tid}` (Z.128-137) + `driver_profile_photos/{tid}` (Z.111-120) schreiben. Driver-Doc create/update ist für den Admin in `firestore.rules` ohne Feldbeschränkung erlaubt. Es werden also **keine** Rules deployt (vermeidet die CLAUDE.md-Ausnahme „Rules-Deploy vorher fragen").

> **Testing-Hinweis (Abweichung von TDD):** Dieses Repo hat keine etablierte Widget-/Unit-Test-Suite für diese Screens; der CLAUDE.md-Workflow verifiziert über `flutter analyze lib/` (keine neuen Errors) plus manuellen Lauf via `flutter run -d chrome`. Laut Skill-Priorität haben User-Instruktionen (CLAUDE.md) Vorrang. Jede Task wird daher mit `flutter analyze lib/` + einem manuellen Verifikationsschritt abgeschlossen, nicht mit automatisierten Tests.

---

### Task 1: `convertedToDriver`-Feld im Recruiting-Modell

**Files:**
- Modify: `flutter_app/kpi_admin/lib/models/recruiting_application.dart`

- [ ] **Step 1: Feld + Konstruktor-Parameter ergänzen**

In der Klasse `RecruitingApplication`, im Konstruktor (nach `this.customAnswers = const <String, dynamic>{},`, ca. Z.212) ergänzen:

```dart
    this.customAnswers = const <String, dynamic>{},
    this.convertedToDriver,
  });
```

Und als Feld (nach der `customAnswers`-Felddeklaration, ca. Z.257) ergänzen:

```dart
  final Map<String, dynamic> customAnswers;

  /// Gesetzt, sobald der Bewerber in einen Driver umgewandelt wurde.
  /// Form: `{ 'tid': <transporterId>, 'at': <Timestamp> }`. `null`,
  /// solange noch keine Umwandlung erfolgt ist.
  final Map<String, dynamic>? convertedToDriver;

  bool get isConvertedToDriver => convertedToDriver != null;

  /// Transporter-ID des erzeugten Drivers, oder `null`.
  String? get convertedDriverTid {
    final tid = convertedToDriver?['tid'];
    final s = (tid ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }
```

- [ ] **Step 2: Deserialisierung in `fromDoc` ergänzen**

In `factory RecruitingApplication.fromDoc(...)`, direkt vor dem schließenden `);` des `return RecruitingApplication(` (nach der `customAnswers:`-Zuweisung, ca. Z.321) ergänzen:

```dart
      customAnswers: (d['customAnswers'] is Map)
          ? Map<String, dynamic>.from(d['customAnswers'] as Map)
          : const <String, dynamic>{},
      convertedToDriver: (d['convertedToDriver'] is Map)
          ? Map<String, dynamic>.from(d['convertedToDriver'] as Map)
          : null,
    );
```

- [ ] **Step 3: Analyze**

Run: `cd flutter_app/kpi_admin && flutter analyze lib/models/recruiting_application.dart`
Expected: Keine neuen Errors (Info/Warnings die vorher schon da waren sind OK).

- [ ] **Step 4: Commit**

```bash
git add flutter_app/kpi_admin/lib/models/recruiting_application.dart
git commit -m "feat(recruiting): convertedToDriver-Feld im Bewerber-Modell"
```

---

### Task 2: `add_driver_dialog` nimmt Quell-Bewerbung an & schreibt alle Stammdaten

**Files:**
- Modify: `flutter_app/kpi_admin/lib/Screens/add_driver_dialog.dart`

- [ ] **Step 1: Import des Recruiting-Modells ergänzen**

Bei den Imports (nach `import '../models/driver_contract_type.dart';`, Z.21) ergänzen:

```dart
import '../models/driver_contract_type.dart';
import '../models/recruiting_application.dart';
```

- [ ] **Step 2: Neuen Parameter durch beide Einstiegspunkte reichen**

In `showAddDriverDialog(...)` (Z.33-53) den Parameter ergänzen und durchreichen:

```dart
Future<bool> showAddDriverDialog({
  required BuildContext context,
  required String dspUid,
  required String defaultPassword,
  String? prefilledName,
  String? prefilledEmail,
  String? prefilledPhone,
  RecruitingApplication? sourceApplication,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AddDriverDialog(
      dspUid: dspUid,
      defaultPassword: defaultPassword,
      prefilledName: prefilledName,
      prefilledEmail: prefilledEmail,
      prefilledPhone: prefilledPhone,
      sourceApplication: sourceApplication,
    ),
  );
  return result == true;
}
```

- [ ] **Step 3: Feld + Konstruktor in `_AddDriverDialog`**

Im `_AddDriverDialog`-StatefulWidget (Z.55-67) ergänzen:

```dart
class _AddDriverDialog extends StatefulWidget {
  final String dspUid;
  final String defaultPassword;
  final String? prefilledName;
  final String? prefilledEmail;
  final String? prefilledPhone;
  final RecruitingApplication? sourceApplication;
  const _AddDriverDialog({
    required this.dspUid,
    required this.defaultPassword,
    this.prefilledName,
    this.prefilledEmail,
    this.prefilledPhone,
    this.sourceApplication,
  });
```

- [ ] **Step 4: Stammdaten-Schreibmethode hinzufügen**

Direkt nach der `_save()`-Methode (nach Z.233, vor `@override Widget build`) diese Methode einfügen. Sie schreibt alle Bewerberfelder flach auf das Driver-Doc:

```dart
  /// Übernimmt alle Bewerber-Stammdaten flach ins Driver-Dokument.
  /// Wird nur im Recruiting-Onboarding-Flow aufgerufen.
  Future<void> _writeRecruitingFields({
    required DocumentReference<Map<String, dynamic>> ref,
    required RecruitingApplication app,
  }) async {
    await ref.set(<String, dynamic>{
      'emailPrivate': app.email.trim(),
      'emailBusiness': '',
      'birthDate':
          app.birthDate != null ? Timestamp.fromDate(app.birthDate!) : null,
      'birthPlace': app.birthPlace.trim(),
      'nationality': app.nationality.trim(),
      'street': app.street.trim(),
      'postalCode': app.postalCode.trim(),
      'city': app.city.trim(),
      'livingHereSince': app.livingHereSince != null
          ? Timestamp.fromDate(app.livingHereSince!)
          : null,
      'shirtSize': app.shirtSize.trim(),
      'shoeSize': app.shoeSize.trim(),
      'truckLicense': app.truckLicense.trim(),
      'channel': app.channel.value,
      'customAnswers': app.customAnswers,
      'adminNote': app.adminNote.trim(),
      'convertedFromApplication': <String, dynamic>{
        'appId': app.id,
        'adminUid': app.adminUid,
        'at': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }
```

- [ ] **Step 5: Aufruf in `_save()` einhängen**

In `_save()` direkt **nach** dem Block, der die Auth-Login-Erstellung umschließt — also nach dem `} catch (e) { loginNotice = ... }`-Block (nach Z.214) und **vor** `if (!mounted) return;` (Z.216) — einfügen:

```dart
      } catch (e) {
        loginNotice = 'Driver wurde gespeichert. Login-Erstellung schlug '
            'fehl: $e';
      }

      // Recruiting-Onboarding: alle Bewerber-Stammdaten übernehmen.
      final srcApp = widget.sourceApplication;
      if (srcApp != null) {
        await _writeRecruitingFields(ref: ref, app: srcApp);
      }

      if (!mounted) return;
```

- [ ] **Step 6: Analyze**

Run: `cd flutter_app/kpi_admin && flutter analyze lib/Screens/add_driver_dialog.dart`
Expected: Keine neuen Errors.

- [ ] **Step 7: Commit**

```bash
git add flutter_app/kpi_admin/lib/Screens/add_driver_dialog.dart
git commit -m "feat(drivers): Add-Driver-Dialog übernimmt Bewerber-Stammdaten"
```

---

### Task 3: Dokument-Kopie (5 Docs + Selfie als Profilbild) + Bewerber markieren

**Files:**
- Modify: `flutter_app/kpi_admin/lib/Screens/add_driver_dialog.dart`

- [ ] **Step 1: Imports für Storage + base64**

Bei den Imports oben ergänzen (`firebase_storage` und `dart:convert`):

```dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
```

(`dart:math` und die übrigen Zeilen existieren bereits — nur `dart:convert` und die `firebase_storage`-Zeile sind neu. Reihenfolge an die bestehende Datei anpassen.)

- [ ] **Step 2: State-Feld für Doc-Hinweis ergänzen**

Bei den Success-State-Feldern (nach `String? _savedLoginNotice;`, Z.93) ergänzen:

```dart
  String? _savedLoginNotice;
  String? _savedDocNotice;
```

- [ ] **Step 3: Kopier-Methode hinzufügen**

Nach `_writeRecruitingFields(...)` (aus Task 2) diese Methode einfügen. Sie lädt jede Bewerber-Datei via Storage-Referenz, lädt sie in den Driver-Pfad hoch und legt den `documents`-Subcollection-Eintrag an; die Selfie wird zum Profilbild. Gibt die Labels fehlgeschlagener Kopien zurück:

```dart
  /// Mappt ein Recruiting-Dokument-Label auf den Driver-`docType`.
  /// `selfie` ist Sonderfall (Profilbild) und wird hier nicht gemappt.
  static const Map<String, String> _kRecruitingDocTypeMap = <String, String>{
    'passport': 'id_card_front',
    'id_back': 'id_card_back',
    'license_front': 'driver_license_front',
    'license_back': 'driver_license_back',
  };

  /// Kopiert die Bewerber-Dokumente in die Driver-Storage-Pfade und legt
  /// `documents`-Einträge an. Selfie → Profilbild. Liefert die Labels,
  /// deren Kopie fehlgeschlagen ist (für einen Hinweis im Erfolgs-Screen).
  Future<List<String>> _copyRecruitingDocuments({
    required DocumentReference<Map<String, dynamic>> ref,
    required String tid,
    required RecruitingApplication app,
  }) async {
    final storage = fb_storage.FirebaseStorage.instance;
    final docsCol = ref.collection('documents');
    final failures = <String>[];

    for (final d in app.documents) {
      try {
        final hasPath = d.storagePath.trim().isNotEmpty;
        final hasUrl = d.downloadUrl.trim().isNotEmpty;
        if (!hasPath && !hasUrl) {
          continue; // legacy/base64-only oder leer → nichts zu kopieren
        }
        final srcRef = hasPath
            ? storage.ref(d.storagePath)
            : storage.refFromURL(d.downloadUrl);
        // 25 MB Limit deckt die max. 15 MB Recruiting-Uploads ab.
        final bytes = await srcRef.getData(25 * 1024 * 1024);
        if (bytes == null) {
          failures.add(d.label);
          continue;
        }
        final contentType =
            d.mimeType.trim().isEmpty ? null : d.mimeType.trim();
        final stamp = DateTime.now().millisecondsSinceEpoch;

        if (d.label == 'selfie') {
          // Profilbild: nach driver_profile_photos + onboarding-Map.
          final photoRef = storage
              .ref()
              .child('driver_profile_photos')
              .child(tid)
              .child('recruiting_$stamp.jpg');
          await photoRef.putData(
            bytes,
            contentType == null
                ? null
                : fb_storage.SettableMetadata(contentType: contentType),
          );
          final url = await photoRef.getDownloadURL();
          await ref.set(<String, dynamic>{
            'onboarding': <String, dynamic>{
              'profilePhotoBase64': base64Encode(bytes),
              'profilePhotoUrl': url,
            },
          }, SetOptions(merge: true));
          continue;
        }

        final docType = _kRecruitingDocTypeMap[d.label] ?? d.label;
        final fileName =
            d.filename.trim().isNotEmpty ? d.filename.trim() : '$docType';
        final destRef = storage
            .ref()
            .child('driver_docs')
            .child(tid)
            .child('${stamp}_$fileName');
        await destRef.putData(
          bytes,
          contentType == null
              ? null
              : fb_storage.SettableMetadata(contentType: contentType),
        );
        final url = await destRef.getDownloadURL();
        await docsCol.doc(docType).set(<String, dynamic>{
          'fileName': fileName,
          'downloadUrl': url,
          'storagePath': destRef.fullPath,
          if (contentType != null) 'contentType': contentType,
          'uploadedAt': FieldValue.serverTimestamp(),
          'uploadedAtClient': Timestamp.now(),
          'size': bytes.length,
          'docType': docType,
          'uploadedBy': 'recruiting',
        }, SetOptions(merge: true));
      } catch (_) {
        failures.add(d.label);
      }
    }
    return failures;
  }

  /// Markiert die Quell-Bewerbung als umgewandelt (bleibt im Recruiting).
  Future<void> _markApplicationConverted({
    required RecruitingApplication app,
    required String tid,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(app.adminUid)
        .collection('recruiting_applications')
        .doc(app.id)
        .set(<String, dynamic>{
      'convertedToDriver': <String, dynamic>{
        'tid': tid,
        'at': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }
```

- [ ] **Step 4: Kopie + Markierung in `_save()` aufrufen**

In `_save()` den in Task 2 eingefügten `if (srcApp != null) { ... }`-Block erweitern, sodass nach den Stammdaten auch Dokumente kopiert und der Bewerber markiert werden:

```dart
      // Recruiting-Onboarding: Stammdaten, Dokumente, Markierung.
      final srcApp = widget.sourceApplication;
      String? docNotice;
      if (srcApp != null) {
        await _writeRecruitingFields(ref: ref, app: srcApp);
        final failed = await _copyRecruitingDocuments(
          ref: ref,
          tid: effectiveTid,
          app: srcApp,
        );
        await _markApplicationConverted(app: srcApp, tid: effectiveTid);
        if (failed.isNotEmpty) {
          docNotice =
              'Einige Dokumente konnten nicht übernommen werden (${failed.join(', ')}). '
              'Bitte im Drivers-Hub manuell nachladen.';
        }
      }

      if (!mounted) return;
```

- [ ] **Step 5: Doc-Hinweis im Erfolgs-State speichern**

Im selben `_save()` im `setState`-Block (Z.217-225) die neue Zeile ergänzen:

```dart
      setState(() {
        _saving = false;
        _success = true;
        _savedName = name;
        _savedEmail = email;
        _savedPassword = password;
        _savedLanguage = _language;
        _savedLoginNotice = loginNotice;
        _savedDocNotice = docNotice;
      });
```

- [ ] **Step 6: Doc-Hinweis im Erfolgs-Screen anzeigen**

In `_buildSuccess(...)` direkt **nach** dem `if (_savedLoginNotice != null) ...[ ... ]`-Block (nach Z.626, vor `const SizedBox(height: AppSpacing.lg),` Z.627) einen analogen Hinweisblock einfügen:

```dart
          if (_savedDocNotice != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: Color(0xFF92400E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _savedDocNotice!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
```

- [ ] **Step 7: Analyze**

Run: `cd flutter_app/kpi_admin && flutter analyze lib/Screens/add_driver_dialog.dart`
Expected: Keine neuen Errors. (Falls `fb_storage`-Präfix-Konflikte gemeldet werden, sicherstellen dass nur EIN `firebase_storage`-Import mit Alias `fb_storage` existiert.)

- [ ] **Step 8: Commit**

```bash
git add flutter_app/kpi_admin/lib/Screens/add_driver_dialog.dart
git commit -m "feat(drivers): Bewerber-Dokumente bei Umwandlung ins Driver-Profil kopieren"
```

---

### Task 4: Recruiting-Detail — volle Daten übergeben, Badge + Disable

**Files:**
- Modify: `flutter_app/kpi_admin/lib/Screens/admin_recruiting_panel.dart`

- [ ] **Step 1: Sicherstellen, dass `cloud_firestore` importiert ist**

Run: `grep -n "package:cloud_firestore/cloud_firestore.dart" flutter_app/kpi_admin/lib/Screens/admin_recruiting_panel.dart`
Falls KEIN Treffer: bei den Imports oben `import 'package:cloud_firestore/cloud_firestore.dart';` ergänzen. Falls Treffer vorhanden: nichts tun.

- [ ] **Step 2: Lokalen Conversion-State einführen**

In `_RecruitingApplicationDetailPageState` (nach `bool _onboardingBusy = false;`, Z.669) ergänzen:

```dart
  bool _onboardingBusy = false;
  late Map<String, dynamic>? _convertedToDriver = widget.app.convertedToDriver;
```

- [ ] **Step 3: `sourceApplication` übergeben + nach Erfolg neu laden**

Die Methode `_onboardAsDriver()` (Z.671-697) ersetzen durch:

```dart
  Future<void> _onboardAsDriver() async {
    final app = widget.app;
    final fullName = app.displayName;
    setState(() => _onboardingBusy = true);
    final ok = await showAddDriverDialog(
      context: context,
      dspUid: widget.adminUid,
      defaultPassword: '',
      prefilledName: fullName,
      prefilledEmail: app.email,
      prefilledPhone: app.phoneWhatsApp,
      sourceApplication: app,
    );
    if (!mounted) return;
    setState(() => _onboardingBusy = false);
    if (ok) {
      // Markierung wurde vom Dialog geschrieben — frisch nachladen,
      // damit Badge + Disable sofort greifen.
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.adminUid)
            .collection('recruiting_applications')
            .doc(app.id)
            .get();
        final conv = snap.data()?['convertedToDriver'];
        if (mounted && conv is Map) {
          setState(() =>
              _convertedToDriver = Map<String, dynamic>.from(conv));
        }
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            'Driver created for "$fullName".',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
```

- [ ] **Step 4: Onboard-Box durch Converted-Badge ersetzen wenn umgewandelt**

Den Block `if (_status == RecruitingStatus.hired) ...[ ... ]` (Z.787-846) ersetzen durch eine Verzweigung: erst Badge prüfen, sonst die bestehende Onboard-Box (mit jetzt deaktiviertem Button-Pfad ist nicht nötig, da die Box im Converted-Fall gar nicht erst gerendert wird):

```dart
                // Bereits übernommen → Badge statt Onboard-Box.
                if (_convertedToDriver != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.codriverGreen
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.codriverDeep,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Als Driver übernommen',
                                style: AppTypography.subheadline.copyWith(
                                  color: AppColors.codriverDeep,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                _convertedDriverSubtitle(),
                                style: AppTypography.caption2.copyWith(
                                  color: AppColors.codriverDeep
                                      .withValues(alpha: 0.75),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
                // Onboard hand-off — visible once status reaches
                // Eingestellt. Pre-fills the standard add-driver flow.
                else if (_status == RecruitingStatus.hired) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.codriverGreen
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_add_alt_rounded,
                          color: AppColors.codriverDeep,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hired — ready to onboard',
                                style: AppTypography.subheadline.copyWith(
                                  color: AppColors.codriverDeep,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Create the driver record with this '
                                'applicant\'s data pre-filled.',
                                style: AppTypography.caption2.copyWith(
                                  color: AppColors.codriverDeep
                                      .withValues(alpha: 0.75),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CoButton(
                          onPressed: _onboardingBusy
                              ? null
                              : _onboardAsDriver,
                          label: 'Onboard as driver',
                          icon: Icons.person_add_alt_rounded,
                          busy: _onboardingBusy,
                        ),
                      ],
                    ),
                  ),
                ],
```

- [ ] **Step 5: Subtitle-Helper für das Badge ergänzen**

In `_RecruitingApplicationDetailPageState`, direkt nach der neuen `_onboardAsDriver()`-Methode, einfügen:

```dart
  String _convertedDriverSubtitle() {
    final tid = (_convertedToDriver?['tid'] ?? '').toString().trim();
    if (tid.isEmpty) {
      return 'Dieser Bewerber wurde bereits in einen Driver übernommen.';
    }
    return 'Driver-ID: $tid · Daten & Dokumente wurden übernommen.';
  }
```

- [ ] **Step 6: Analyze**

Run: `cd flutter_app/kpi_admin && flutter analyze lib/Screens/admin_recruiting_panel.dart`
Expected: Keine neuen Errors.

- [ ] **Step 7: Commit**

```bash
git add flutter_app/kpi_admin/lib/Screens/admin_recruiting_panel.dart
git commit -m "feat(recruiting): Detail übergibt volle Bewerberdaten & zeigt Übernommen-Badge"
```

---

### Task 5: Gesamt-Analyze, manuelle Verifikation & Deploy

**Files:** (keine — nur Verifikation/Deploy)

- [ ] **Step 1: Voll-Analyze**

Run: `cd flutter_app/kpi_admin && flutter analyze lib/`
Expected: Keine Errors (vorbestehende Warnings/Infos sind OK).

- [ ] **Step 2: Manuelle Verifikation im Browser**

Run: `cd flutter_app/kpi_admin && flutter run -d chrome`
Dann manuell prüfen:
1. Recruiting → einen Bewerber mit hochgeladenen Dokumenten öffnen, Status auf „Eingestellt"/`hired` setzen → „Onboard as driver" erscheint.
2. Button klicken → Dialog ist mit Name/E-Mail/Telefon vorbefüllt. Transporter-ID + Passwort vergeben, „Anlegen".
3. Erfolgs-Screen erscheint; bei Doc-Problemen erscheint der gelbe Hinweis.
4. Drivers-Hub öffnen → neuer Driver existiert mit den Stammdaten; Profilbild (Selfie) sichtbar; in den Driver-Dokumenten liegen `id_card_front`/`id_card_back`/`driver_license_front`/`driver_license_back`.
5. Zurück ins Recruiting-Detail desselben Bewerbers → grünes Badge „Als Driver übernommen" mit Driver-ID, Onboard-Button verschwunden. Bewerber ist weiterhin in der Liste.

- [ ] **Step 3: Deploy (gemäß CLAUDE.md Auto-Deploy)**

```bash
cd flutter_app/kpi_admin
firebase use   # MUSS "codriver-eu" zurückgeben — sonst abbrechen!
flutter build web --release
firebase deploy --only hosting
```

Production-URL danach prüfen: https://dsp-codriver.de

- [ ] **Step 4: Abschluss-Commit (falls noch ungetrackte Änderungen)**

```bash
git add -A
git commit -m "chore(recruiting): Bewerber→Driver Umwandlung verifiziert & deployed" || echo "nichts zu committen"
```

---

## Self-Review

**Spec-Abdeckung:**
- „Alle Daten übernehmen" → Task 2 (Stammdaten + customAnswers) + Task 3 (5 Dokumente + Selfie als Profilbild). ✓
- „E-Mail: zusätzlich `emailPrivate`, später `emailBusiness`" → Task 2 `_writeRecruitingFields` schreibt `emailPrivate` (= Bewerber-Mail) und leeres `emailBusiness`; Login-`email` bleibt die vorbefüllte Bewerber-Mail. ✓
- „Dialog mit vorausgefüllten Daten, Admin vergibt TID + Passwort" → Task 4 reicht `sourceApplication` durch; Dialog (Task 2/3) nutzt bestehende TID/Passwort-Felder. ✓
- „Bewerber bleibt im Recruiting, als ‚übernommen' markieren, Doppelanlage verhindern" → Task 3 `_markApplicationConverted` + Task 4 Badge/Disable (Onboard-Box wird im Converted-Fall nicht gerendert → kein erneutes Anlegen über diesen Weg). ✓
- „Dokumente client-seitig kopieren, kein neuer Function-Deploy / keine Rules-Änderung" → Task 3 nutzt `firebase_storage` getData/putData; Rules-Check im Architecture-Abschnitt bestätigt Berechtigungen. ✓

**Placeholder-Scan:** Keine TBD/TODO; alle Schritte enthalten konkreten Code. ✓

**Typ-Konsistenz:** `convertedToDriver` als `Map<String, dynamic>?` in Modell (Task 1), Dialog (Task 3 schreibt `{tid, at}`) und Detail-State (Task 4) konsistent. `_kRecruitingDocTypeMap` Labels stimmen mit den Driver-`docType`-Werten aus `drivers_hub_page.dart` (`id_card_front`, `id_card_back`, `driver_license_front`, `driver_license_back`) überein. `fb_storage`-Alias durchgängig. ✓
