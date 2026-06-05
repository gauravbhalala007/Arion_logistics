// lib/Screens/add_driver_dialog.dart
//
// Modern driver-creation dialog that replaces the legacy bare-bones
// AlertDialog inside `drivers_hub_page.dart`. Highlights:
//   • Name + Email required, Transporter-ID optional (assigned later)
//   • Password visible with show/hide toggle + a one-tap "Standard
//     password" chip that pulls the admin's pre-configured default
//   • Driver's preferred language picker — drives the welcome message
//   • After save: a success screen with the welcome message preview
//     in the chosen language + a copy-to-clipboard button

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import '../models/driver_contract_type.dart';
import '../models/recruiting_application.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

const String _kAppUrl = 'https://dsp-codriver.de/';

/// Returns true if a driver was successfully created.
/// Optional `prefilled*` params pre-populate the form — used by the
/// Recruiting flow to hand off a hired applicant into onboarding
/// without retyping the basics.
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

  @override
  State<_AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<_AddDriverDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _tidCtrl = TextEditingController();
  final _employeeNumberCtrl = TextEditingController();
  late final TextEditingController _passwordCtrl;
  bool _passwordVisible = true;
  String _language = 'de';
  DriverContractType? _contractType;
  bool _saving = false;
  String? _error;

  // After save we flip into "success" mode showing the welcome
  // message preview.
  bool _success = false;
  String? _savedName;
  String? _savedEmail;
  String? _savedPassword;
  String? _savedLanguage;
  String? _savedLoginNotice;
  String? _savedDocNotice;

  static const _supportedLanguages = <_Lang>[
    _Lang('de', 'Deutsch', '🇩🇪'),
    _Lang('en', 'English', '🇬🇧'),
    _Lang('sq', 'Shqip', '🇦🇱'),
    _Lang('hu', 'Magyar', '🇭🇺'),
    _Lang('ro', 'Romana', '🇷🇴'),
    _Lang('hr', 'Hrvatski', '🇭🇷'),
    _Lang('ar', 'العربية', '🇸🇦'),
    _Lang('tr', 'Turkce', '🇹🇷'),
    _Lang('ru', 'Русский', '🇷🇺'),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.prefilledName ?? '');
    _emailCtrl =
        TextEditingController(text: widget.prefilledEmail ?? '');
    _phoneCtrl =
        TextEditingController(text: widget.prefilledPhone ?? '');
    _passwordCtrl = TextEditingController(text: widget.defaultPassword);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _tidCtrl.dispose();
    _employeeNumberCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (name.isEmpty) {
      setState(() => _error = 'Name ist Pflichtfeld.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Gültige E-Mail-Adresse erforderlich.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Passwort muss mind. 6 Zeichen haben.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final db = FirebaseFirestore.instance;
      final tidRaw = _tidCtrl.text.trim();
      final hasRealTid = tidRaw.isNotEmpty;
      // When the admin has a Transporter-ID at creation time we use it
      // as the doc id (matches the existing schema). Otherwise we generate
      // a placeholder TID like `PENDING-A7B3K9` that:
      //  - is unique (collision-checked against existing drivers),
      //  - is used as both doc id and `transporterId`, so the Cloud
      //    Function `createDriverLogin` can create the auth user without
      //    a real TID being known yet,
      //  - is flagged via `tidPending: true` so the UI shows "TID
      //    ausstehend" and the Scorecard-Reassign-Dialog can pick it up.
      final String effectiveTid = hasRealTid
          ? tidRaw.toUpperCase()
          : await _generateUniquePendingTid(db: db, dspUid: widget.dspUid);

      final ref = db
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .doc(effectiveTid);

      await ref.set({
        'driverName': name,
        'email': email,
        'transporterId': effectiveTid,
        if (_phoneCtrl.text.trim().isNotEmpty)
          'phone': _phoneCtrl.text.trim(),
        if (_employeeNumberCtrl.text.trim().isNotEmpty)
          'employeeNumber': _employeeNumberCtrl.text.trim(),
        'preferredLanguage': _language,
        if (_contractType != null) 'contractType': _contractType!.value,
        'pendingLogin': {
          'email': email,
          'password': password,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'hasLogin': false,
        'tidPending': !hasRealTid,
        'active': true,
      }, SetOptions(merge: true));

      // Create the Firebase Auth user immediately. We always have a TID
      // (either real or a generated PENDING-XXXXXX placeholder), so the
      // Cloud Function always succeeds.
      String? loginNotice;
      try {
        await FirebaseFunctions.instance
            .httpsCallable('createDriverLogin')
            .call(<String, dynamic>{
          'dspUid': widget.dspUid,
          'transporterId': effectiveTid,
          'driverDocId': ref.id,
          'password': password,
        });
        await ref.set({
          'hasLogin': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        loginNotice = 'Driver wurde gespeichert. Login-Erstellung schlug '
            'fehl: $e';
      }

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
        if (failed.isNotEmpty) {
          docNotice =
              'Einige Dokumente konnten nicht übernommen werden (${failed.join(', ')}). '
              'Bitte im Drivers-Hub manuell nachladen.';
        }
        // Markierung darf den bereits erstellten Driver nicht scheitern
        // lassen — Fehler nur als Hinweis sammeln.
        try {
          await _markApplicationConverted(app: srcApp, tid: effectiveTid);
        } catch (e) {
          debugPrint('Bewerber-Markierung fehlgeschlagen: $e');
          docNotice = '${docNotice ?? ''} Bewerber konnte nicht als '
                  '„übernommen" markiert werden — bitte Status manuell prüfen.'
              .trim();
        }
      }

      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

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
        // Die Storage-Rules verlangen einen non-null contentType, der
        // image/* (Profilbild) bzw. image/* oder application/pdf
        // (driver_docs) matcht. Recruiting-Docs liefern mimeType nicht
        // immer mit → aus Endung ableiten, niemals null senden.
        final mime = d.mimeType.trim();
        final contentType = mime.isNotEmpty
            ? mime
            : (d.filename.toLowerCase().endsWith('.pdf')
                ? 'application/pdf'
                : 'image/jpeg');
        final stamp = DateTime.now().millisecondsSinceEpoch;

        if (d.label == 'selfie') {
          // Profilbild: nach driver_profile_photos + onboarding-Map.
          // Pfad ist .jpg, Rule verlangt image/* → notfalls image/jpeg.
          final photoContentType =
              mime.startsWith('image/') ? mime : 'image/jpeg';
          final photoRef = storage
              .ref()
              .child('driver_profile_photos')
              .child(tid)
              .child('recruiting_$stamp.jpg');
          await photoRef.putData(
            bytes,
            fb_storage.SettableMetadata(contentType: photoContentType),
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
            d.filename.trim().isNotEmpty ? d.filename.trim() : docType;
        final destRef = storage
            .ref()
            .child('driver_docs')
            .child(tid)
            .child('${stamp}_$fileName');
        await destRef.putData(
          bytes,
          fb_storage.SettableMetadata(contentType: contentType),
        );
        final url = await destRef.getDownloadURL();
        await docsCol.doc(docType).set(<String, dynamic>{
          'fileName': fileName,
          'downloadUrl': url,
          'storagePath': destRef.fullPath,
          'contentType': contentType,
          'uploadedAt': FieldValue.serverTimestamp(),
          'uploadedAtClient': Timestamp.now(),
          'size': bytes.length,
          'docType': docType,
          'uploadedBy': 'recruiting',
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Recruiting-Doc-Kopie fehlgeschlagen (${d.label}): $e');
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _success ? _buildSuccess(context) : _buildForm(context),
        ),
      ),
    );
  }

  // Builds a unique PENDING-XXXXXX placeholder TID for drivers who don't
  // have a real Transporter-ID yet. 6 chars from a 32-symbol Base32-style
  // alphabet (no confusing chars like 0/O, 1/I/L) → ~1B combinations.
  // Checks Firestore for collisions and retries up to 5 times.
  static const _kPendingPrefix = 'PENDING-';
  static const _kPendingAlphabet =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  Future<String> _generateUniquePendingTid({
    required FirebaseFirestore db,
    required String dspUid,
  }) async {
    final rng = Random.secure();
    for (var attempt = 0; attempt < 5; attempt++) {
      final suffix = List.generate(
        6,
        (_) => _kPendingAlphabet[rng.nextInt(_kPendingAlphabet.length)],
      ).join();
      final tid = '$_kPendingPrefix$suffix';
      final existing = await db
          .collection('users')
          .doc(dspUid)
          .collection('drivers')
          .doc(tid)
          .get();
      if (!existing.exists) return tid;
    }
    // Fallback with timestamp suffix — astronomically unique.
    final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(32)
        .toUpperCase();
    return '$_kPendingPrefix$ts';
  }

  // ─── Form mode ───────────────────────────────────────────────────────

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppColors.codriverDeep,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fahrer anlegen',
                      style: AppTypography.title3.copyWith(
                        color: AppColors.codriverGraphite,
                      ),
                    ),
                    Text(
                      'Name & E-Mail genügen. Die Transporter-ID kann später ergänzt werden.',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Schließen',
                onPressed: _saving
                    ? null
                    : () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Label('Name *'),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Vor- und Nachname',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          _Label('E-Mail *'),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'driver@example.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          _Label('Telefon (optional)'),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+49 …',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Label('Transporter-ID (optional, wird ggf. später gesetzt)'),
          TextField(
            controller: _tidCtrl,
            decoration: const InputDecoration(
              hintText: 'z.B. A1B2C3D4E5F6G7',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: AppSpacing.md),
          _Label('Personalnummer (optional)'),
          TextField(
            controller: _employeeNumberCtrl,
            decoration: const InputDecoration(
              hintText: 'z.B. 1024',
              prefixIcon: Icon(Icons.tag_rounded),
              helperText:
                  'Muss identisch zu SD Worx / ADP sein — Codriver '
                  'nutzt dies fürs Payroll-Matching.',
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Label('Bevorzugte Sprache'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final l in _supportedLanguages)
                ChoiceChip(
                  label: Text('${l.flag}  ${l.label}'),
                  selected: _language == l.code,
                  onSelected: (_) => setState(() => _language = l.code),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Label('Vertragsart'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in DriverContractType.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _contractType == c,
                  onSelected: (sel) => setState(
                    () => _contractType = sel ? c : null,
                  ),
                  selectedColor: c.pillColor,
                  labelStyle: TextStyle(
                    color: _contractType == c
                        ? Colors.white
                        : const Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: _contractType == c
                        ? c.pillColor
                        : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Label('Passwort'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _passwordVisible
                          ? 'Verbergen'
                          : 'Anzeigen',
                      onPressed: () => setState(
                        () => _passwordVisible = !_passwordVisible,
                      ),
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ActionChip(
                avatar: const Icon(Icons.password_rounded, size: 16),
                label: const Text('Standard'),
                onPressed: widget.defaultPassword.isEmpty
                    ? null
                    : () => setState(() {
                          _passwordCtrl.text = widget.defaultPassword;
                        }),
              ),
            ],
          ),
          if (widget.defaultPassword.isEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Standard-Passwort ist noch nicht hinterlegt. '
              'Du kannst es im Drivers-Hub-Header festlegen.',
              style: AppTypography.caption2.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Spacer(),
              TextButton(
                onPressed:
                    _saving ? null : () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text('Anlegen'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Success mode ───────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context) {
    final lang = _savedLanguage ?? 'de';
    final title = AppLocalizations.driverWelcomeTitle(lang);
    final body = AppLocalizations.driverWelcomeBody(
      lang,
      name: _savedName ?? '',
      email: _savedEmail ?? '',
      password: _savedPassword ?? '',
      appUrl: _kAppUrl,
    );
    final copyText = '$title\n\n$body';

    return SingleChildScrollView(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.codriverGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fahrer angelegt!',
                      style: AppTypography.title3.copyWith(
                        color: AppColors.codriverGraphite,
                      ),
                    ),
                    Text(
                      'Schicke dem neuen Fahrer die Begrüßungsnachricht.',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_savedLoginNotice != null) ...[
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
                      _savedLoginNotice!,
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
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Willkommen im Team',
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vorschau in ${_languageLabel(lang)}:',
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: AppElevation.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  body,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.codriverGraphite,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: copyText));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nachricht in Zwischenablage kopiert.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.content_copy_rounded),
                  label: const Text('Nachricht kopieren'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Fertig'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Switch back to a fresh empty form for the next driver.
                _nameCtrl.clear();
                _emailCtrl.clear();
                _phoneCtrl.clear();
                _tidCtrl.clear();
                _passwordCtrl.text = widget.defaultPassword;
                setState(() {
                  _success = false;
                  _savedName = null;
                  _savedEmail = null;
                  _savedPassword = null;
                });
              },
              icon: const Icon(Icons.person_add_alt_rounded, size: 18),
              label: const Text('Noch einen Fahrer anlegen'),
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabel(String code) =>
      _supportedLanguages.firstWhere(
        (l) => l.code == code,
        orElse: () => _supportedLanguages.first,
      ).label;
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: AppTypography.caption1.copyWith(
            color: AppColors.labelSecondaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _Lang {
  final String code;
  final String label;
  final String flag;
  const _Lang(this.code, this.label, this.flag);
}

/// Returns the admin's stored "Standard-Passwort" for new drivers, or
/// an empty string if not set. Reads from
/// `users/{adminUid}.defaultDriverPassword` which is where the
/// existing bulk-password field already writes to.
Future<String> readDefaultDriverPassword(String adminUid) async {
  try {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(adminUid)
        .get();
    final v = snap.data()?['defaultDriverPassword'];
    if (v is String) return v;
  } catch (_) {}
  return '';
}

/// Convenience wrapper around [showAddDriverDialog] that resolves the
/// current admin's UID and stored default password automatically.
Future<bool> showAddDriverDialogForCurrentAdmin(BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return false;
  final pwd = await readDefaultDriverPassword(uid);
  if (!context.mounted) return false;
  return showAddDriverDialog(
    context: context,
    dspUid: uid,
    defaultPassword: pwd,
  );
}
