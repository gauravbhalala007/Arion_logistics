// lib/Screens/recruiting_form_page.dart
//
// Public, login-less recruiting form. Mirrors the ARION LOGISTICS
// Google Form 1:1 (questions in Albanian + German), plus the
// passport / ID + driver-license-front/back uploads at the end so
// the admin team has everything needed to file the work-visa
// (Arbeitsvisum) request.
//
// Routed by main.dart from `/apply?dsp=<adminUid>&type=local|visa`.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../models/recruiting_application.dart';
import '../models/recruiting_form_config.dart';
import '../services/recruiting_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';

class RecruitingFormPage extends StatefulWidget {
  const RecruitingFormPage({
    super.key,
    required this.adminUid,
    required this.channel,
  });

  /// Target admin / DSP namespace. The form refuses to render if this
  /// is empty — the link is malformed.
  final String adminUid;
  final RecruitingChannel channel;

  @override
  State<RecruitingFormPage> createState() => _RecruitingFormPageState();
}

class _RecruitingFormPageState extends State<RecruitingFormPage> {
  final _repo = RecruitingRepository();
  String _companyName = '';
  int _step = 0;
  bool _submitting = false;
  bool _submitted = false;
  String _uploadProgress = '';
  String? _error;

  /// DSP-defined custom questions (form-builder MVP). Loaded once on
  /// init; empty list = no custom step is shown.
  List<RecruitingCustomField> _customFields =
      const <RecruitingCustomField>[];
  final Map<String, dynamic> _customAnswers = <String, dynamic>{};

  // ── Step 1: identity ──
  /// What kind of contract the applicant is interested in. Asked at the
  /// very top of the identity step so the admin team can sort by goal
  /// from the start. Stored on the application doc under
  /// `customAnswers.employmentInterest`.
  /// Possible values: `fulltime`, `parttime`, `minijob`.
  String _employmentInterest = '';
  /// Only relevant when [_employmentInterest] == 'parttime'.
  /// Values: '2', '3', '4' (days per week).
  String _parttimeDays = '';
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  DateTime? _birthDate;
  final _birthPlace = TextEditingController();
  final _birthCountry = TextEditingController();
  String _nationality = '';
  final _nationalityFreeText = TextEditingController();
  static const _nationalities = <String>[
    'Kosovë / Kosovo',
    'Shqipëri / Albanien',
    'Maqedonia e Veriut / Nordmazedonien',
    'Serbi / Serbien',
  ];

  // ── Step 2: address ──
  final _street = TextEditingController();
  final _postalCode = TextEditingController();
  final _city = TextEditingController();
  DateTime? _livingSince;

  // ── Step 3: sizing + contact ──
  final _shirtSize = TextEditingController();
  final _shoeSize = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  // ── Step 4: truck license (Visa channel only) ──
  /// Two-step replacement: category first (none / C / CE), then —
  /// only if C or CE — the Code 95 follow-up.
  String _truckLicenseCategory = ''; // '', 'none', 'C', 'CE'
  bool? _hasCode95;

  // ── Step 5: documents ──
  _PickedFile? _passport; // Personalausweis Vorderseite / Reisepass
  _PickedFile? _idBack; // Personalausweis Rückseite
  _PickedFile? _selfie; // Selfie für Driver-Badge
  _PickedFile? _licenseFront;
  _PickedFile? _licenseBack;

  // ── DSGVO / Datenschutz-Einwilligung (aktive Zustimmung, Pflicht) ──
  bool _dsgvoAccepted = false;

  // ── Step 6 (Local/EU only): payroll & family ──
  final _taxId = TextEditingController();
  final _socialSecurityNo = TextEditingController();
  bool _taxIdLater = false;
  bool _socialSecurityLater = false;
  // '', 'single', 'divorced', 'married_or_separated', 'widowed'
  String _maritalStatus = '';
  String _childrenChoice = ''; // '', 'none', 'count', 'later'
  final _childrenCount = TextEditingController();
  final _healthInsurance = TextEditingController();
  String _healthInsuranceChoice = ''; // '', 'has', 'none'
  String _aokBayernRegister = ''; // '', 'yes', 'no'
  final _notes = TextEditingController();

  bool get _isLocal => widget.channel == RecruitingChannel.local;

  // Visa-Formular: gewählte Sprache (null = noch nicht gewählt → Auswahl
  // zuerst). 'sq' = Albanisch, 'de' = Deutsch. Danach wird nur diese
  // Sprache angezeigt (statt beide gleichzeitig).
  String? _visaLang;

  /// Visa-Texthelfer: gibt je nach gewählter Sprache den albanischen oder
  /// deutschen Text zurück (Default Albanisch).
  String _vt(String sq, String de) => _visaLang == 'de' ? de : sq;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    if (widget.adminUid.trim().isEmpty) return;
    try {
      final cfg = await _repo.fetchFormConfig(
        adminUid: widget.adminUid,
        channel: widget.channel,
      );
      if (!mounted) return;
      setState(() => _customFields = cfg.fields);
    } catch (_) {
      // Public form continues without custom questions on error —
      // standard fields still get the applicant through.
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminUid)
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      final name = ((data['companyName'] ?? data['dspName'] ?? '') as Object?)
          .toString()
          .trim();
      if (!mounted) return;
      if (name.isNotEmpty) setState(() => _companyName = name);
    } catch (_) {
      // Title falls back to the static default below.
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _birthPlace.dispose();
    _birthCountry.dispose();
    _street.dispose();
    _postalCode.dispose();
    _city.dispose();
    _shirtSize.dispose();
    _shoeSize.dispose();
    _phone.dispose();
    _email.dispose();
    _taxId.dispose();
    _socialSecurityNo.dispose();
    _childrenCount.dispose();
    _healthInsurance.dispose();
    _notes.dispose();
    _nationalityFreeText.dispose();
    super.dispose();
  }

  /// Dynamic step list — Visa channel uses the historical Albanian flow
  /// with truck-license + Code 95 questions; Local/EU is the simpler
  /// German+English flow with a finance/family step after the docs.
  List<String> get _stepIds {
    if (_isLocal) {
      return <String>[
        'identity',
        'address',
        'contact',
        if (_customFields.isNotEmpty) 'custom',
        'docs',
        'finance',
      ];
    }
    return <String>[
      'identity',
      'address',
      'contact',
      'license',
      if (_customFields.isNotEmpty) 'custom',
      'docs',
    ];
  }

  int get _totalSteps => _stepIds.length;
  int get _docsStepIndex => _stepIds.indexOf('docs');

  // ── Validation per step ─────────────────────────────────────────
  String? _validateStep(int step) {
    final id = _stepIds[step];
    if (id == 'custom') {
      for (final f in _customFields) {
        if (!f.required) continue;
        final v = _customAnswers[f.id];
        final empty = v == null ||
            (v is String && v.trim().isEmpty) ||
            (v is List && v.isEmpty);
        if (empty) {
          return 'Bitte „${f.label}" beantworten.';
        }
      }
      return null;
    }
    if (id == 'finance') {
      if (!_taxIdLater && _taxId.text.trim().isEmpty) {
        return 'Steueridentifikationsnummer fehlt / Tax ID missing.';
      }
      if (!_socialSecurityLater &&
          _socialSecurityNo.text.trim().isEmpty) {
        return 'Sozialversicherungsnummer fehlt / Social security number missing.';
      }
      if (_healthInsuranceChoice.isEmpty) {
        return 'Angabe zur Krankenkasse fehlt / Health insurance missing.';
      }
      if (_healthInsuranceChoice == 'has' &&
          _healthInsurance.text.trim().isEmpty) {
        return 'Name der Krankenkasse fehlt / Health insurance name missing.';
      }
      if (_healthInsuranceChoice == 'none' && _aokBayernRegister.isEmpty) {
        return 'Bitte AOK-Bayern-Anmeldung beantworten / '
            'Please answer the AOK Bayern question.';
      }
      if (_maritalStatus.isEmpty) {
        return 'Familienstand fehlt / Marital status missing.';
      }
      if (_childrenChoice.isEmpty) {
        return 'Angabe zu Kindern fehlt / Children info missing.';
      }
      if (_childrenChoice == 'count' &&
          _childrenCount.text.trim().isEmpty) {
        return 'Anzahl Kinder fehlt / Children count missing.';
      }
      return null;
    }
    if (id == 'identity') {
      if (_employmentInterest.isEmpty) {
        return _isLocal
            ? 'Please pick an employment type · '
                'Bitte Beschäftigungs-Wunsch auswählen.'
            : _vt('Ju lutemi zgjidhni llojin e punës.',
                'Bitte Beschäftigungs-Wunsch auswählen.');
      }
      if (_employmentInterest == 'parttime' && _parttimeDays.isEmpty) {
        return _isLocal
            ? 'Please pick 2, 3 or 4 days per week · '
                'Bitte 2, 3 oder 4 Tage pro Woche auswählen.'
            : _vt('Ju lutemi zgjidhni 2, 3 ose 4 ditë në javë.',
                'Bitte 2, 3 oder 4 Tage pro Woche auswählen.');
      }
      if (_firstName.text.trim().isEmpty) {
        return _isLocal
            ? 'First name / Vorname fehlt.'
            : _vt('Emri mungon.', 'Vorname fehlt.');
      }
      if (_lastName.text.trim().isEmpty) {
        return _isLocal
            ? 'Last name / Nachname fehlt.'
            : _vt('Mbiemri mungon.', 'Nachname fehlt.');
      }
      if (_birthDate == null) {
        return _isLocal
            ? 'Date of birth / Geburtsdatum fehlt.'
            : _vt('Data e lindjes mungon.', 'Geburtsdatum fehlt.');
      }
      if (_birthPlace.text.trim().isEmpty) {
        return _isLocal
            ? 'Place of birth / Geburtsort fehlt.'
            : _vt('Vendlindja mungon.', 'Geburtsort fehlt.');
      }
      if (_birthCountry.text.trim().isEmpty) {
        return _isLocal
            ? 'Country of birth / Geburtsland fehlt.'
            : _vt('Shteti i lindjes mungon.', 'Geburtsland fehlt.');
      }
      if (_nationality.isEmpty) {
        return _isLocal
            ? 'Nationality / Nationalität fehlt.'
            : _vt('Shtetësia mungon.', 'Nationalität fehlt.');
      }
      return null;
    }
    if (id == 'address') {
      if (_street.text.trim().isEmpty) {
        return _isLocal
            ? 'Address / Adresse fehlt.'
            : _vt('Rruga mungon.', 'Adresse fehlt.');
      }
      if (_postalCode.text.trim().isEmpty) {
        return _isLocal
            ? 'Postal code / PLZ fehlt.'
            : _vt('Kodi postar mungon.', 'PLZ fehlt.');
      }
      if (_city.text.trim().isEmpty) {
        return _isLocal
            ? 'City / Stadt fehlt.'
            : _vt('Qyteti mungon.', 'Stadt fehlt.');
      }
      // livingSince is Visa-only — Local/EU dropped the field.
      if (!_isLocal && _livingSince == null) {
        return _vt('Që nga kur? mungon.', 'Seit wann? fehlt.');
      }
      return null;
    }
    if (id == 'contact') {
      if (_shirtSize.text.trim().isEmpty) {
        return _isLocal
            ? 'Shirt size / Größe fehlt.'
            : _vt('Madhësia mungon.', 'Größe fehlt.');
      }
      if (_shoeSize.text.trim().isEmpty) {
        return _isLocal
            ? 'Shoe size / Schuhgröße fehlt.'
            : _vt('Numri i këpucëve mungon.', 'Schuhgröße fehlt.');
      }
      if (_phone.text.trim().isEmpty) return 'Telefon fehlt.';
      if (_email.text.trim().isEmpty) return 'Email fehlt.';
      if (!_email.text.contains('@')) return 'Email ist ungültig.';
      return null;
    }
    if (id == 'license') {
      if (_truckLicenseCategory.isEmpty) {
        return _vt('Përgjigja për patentën e kamionit mungon.',
            'Lkw-Führerschein-Antwort fehlt.');
      }
      if (_truckLicenseCategory != 'none' && _hasCode95 == null) {
        return _vt('Code 95 — ju lutemi zgjidhni Po ose Jo.',
            'Code 95 — bitte Ja oder Nein wählen.');
      }
      return null;
    }
    if (id == 'docs') {
        if (_passport == null) {
          return _isLocal
              ? 'Passport / ID document missing — Pass / Personalausweis fehlt.'
              : 'Pass / Personalausweis fehlt.';
        }
        if (_idBack == null) {
          return 'Personalausweis Rückseite fehlt / ID back side missing.';
        }
        if (_selfie == null) {
          return 'Selfie für Driver-Badge fehlt / Selfie missing.';
        }
        if (_licenseFront == null) {
          return 'Führerschein Vorderseite fehlt.';
        }
        if (_licenseBack == null) {
          return 'Führerschein Rückseite fehlt.';
        }
        if (!_dsgvoAccepted) {
          return _isLocal
              ? 'Please accept the data protection consent · '
                  'Bitte Datenschutz-Einwilligung akzeptieren.'
              : _vt('Ju lutemi pranoni pëlqimin e privatësisë.',
                  'Bitte Datenschutz-Einwilligung akzeptieren.');
        }
        return null;
      }
    return null;
  }

  // ── Document pickers ────────────────────────────────────────────
  /// Picks a file, downsizes images that exceed [maxBytes] (5 MB), and
  /// stores the result in memory. Upload to Storage happens in [_submit]
  /// so a slow connection during picking doesn't block the user.
  Future<void> _pickDocument(String slot) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'heic'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    if (f.bytes == null) return;
    final ext = (f.extension ?? '').toLowerCase();
    var bytes = f.bytes!;
    var mime = ext == 'pdf'
        ? 'application/pdf'
        : ext == 'png'
            ? 'image/png'
            : ext == 'heic'
                ? 'image/heic'
                : 'image/jpeg';

    // Auto-compress every image > 1.2 MB. iOS Safari on cellular can
    // choke on resumable Storage uploads above ~2 MB — keeping each
    // file small dramatically improves submit success. PDFs are sent
    // as-is (admin can ask for a smaller scan if needed).
    const maxBytes = 1200 * 1024;
    const hardCapBytes = 10 * 1024 * 1024;
    if (mime.startsWith('image/') && bytes.lengthInBytes > maxBytes) {
      final shrunk = await _compressImage(bytes);
      if (shrunk == null) {
        setState(() => _error =
            'Image too large and could not be compressed. Please '
            'pick a smaller version.');
        return;
      }
      bytes = shrunk;
      mime = 'image/jpeg';
    } else if (bytes.lengthInBytes > hardCapBytes) {
      setState(() => _error =
          'File too large (${(bytes.lengthInBytes / 1024 / 1024).toStringAsFixed(1)} MB). '
          'Max 10 MB per document.');
      return;
    }

    setState(() {
      _error = null;
      final picked = _PickedFile(
        bytes: bytes,
        filename: f.name,
        mimeType: mime,
      );
      switch (slot) {
        case 'passport':
          _passport = picked;
          break;
        case 'id_back':
          _idBack = picked;
          break;
        case 'selfie':
          _selfie = picked;
          break;
        case 'license_front':
          _licenseFront = picked;
          break;
        case 'license_back':
          _licenseBack = picked;
          break;
      }
    });
  }

  /// Down-scales an image so its longest edge is ≤ 1600 px and
  /// re-encodes at JPEG q75. Typical 8-12 MP phone shots end up around
  /// 350–600 KB — still perfectly readable for ID documents, but
  /// upload-friendly on cellular and well below iOS Safari's resumable-
  /// upload sweet spot.
  Future<Uint8List?> _compressImage(Uint8List raw) async {
    try {
      final decoded = img.decodeImage(raw);
      if (decoded == null) return null;
      const maxEdge = 1600;
      final longest = decoded.width > decoded.height
          ? decoded.width
          : decoded.height;
      final resized = longest > maxEdge
          ? img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? maxEdge : null,
              height: decoded.width >= decoded.height ? null : maxEdge,
              interpolation: img.Interpolation.linear,
            )
          : decoded;
      final encoded = img.encodeJpg(resized, quality: 75);
      return Uint8List.fromList(encoded);
    } catch (_) {
      return null;
    }
  }

  /// Upload a single picked file to Firebase Storage under
  ///   `recruiting/{adminUid}/{appId}/{label}.{ext}`
  /// and return the resulting downloadUrl + storagePath.
  ///
  /// We deliberately BYPASS the Firebase Storage SDK and POST directly
  /// to the Firebase Storage REST endpoint. The SDK on iOS Safari uses
  /// a resumable-upload protocol that occasionally throws a misleading
  /// `firebase_storage/unauthorized` error on cellular networks even
  /// when the underlying rule allows the write. A plain
  /// `uploadType=media` POST is one round-trip, no preflight session,
  /// works identically on every browser (we verified with curl).
  Future<RecruitingDocument> _uploadDocument({
    required String appId,
    required String label,
    required _PickedFile file,
  }) async {
    final ext = file.mimeType == 'application/pdf'
        ? 'pdf'
        : file.mimeType == 'image/png'
            ? 'png'
            : file.mimeType == 'image/heic'
                ? 'heic'
                : 'jpg';
    final path = 'recruiting/${widget.adminUid}/$appId/$label.$ext';
    final encodedPath = Uri.encodeComponent(path);
    // Hard-code the bucket the app uses — `firebase_options.dart` and
    // the deployed Storage CORS config agree on this value, so it stays
    // consistent across all environments.
    const bucket = 'codriver-eu.firebasestorage.app';
    final uri = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/$bucket/o'
      '?uploadType=media&name=$encodedPath',
    );

    final resp = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': file.mimeType,
      },
      body: file.bytes,
    );

    if (resp.statusCode != 200) {
      throw Exception(
        'Storage POST returned ${resp.statusCode}: ${resp.body}',
      );
    }

    final meta = jsonDecode(resp.body) as Map<String, dynamic>;
    final downloadTokens = (meta['downloadTokens'] ?? '').toString();
    final downloadUrl =
        'https://firebasestorage.googleapis.com/v0/b/$bucket/o/'
        '$encodedPath?alt=media&token=$downloadTokens';

    return RecruitingDocument(
      label: label,
      filename: file.filename,
      mimeType: file.mimeType,
      downloadUrl: downloadUrl,
      storagePath: path,
      sizeBytes: file.bytes.lengthInBytes,
    );
  }

  // ── Submit ──────────────────────────────────────────────────────
  /// Two-phase submit:
  ///   1. Pre-allocate a Firestore doc reference so we know the appId
  ///      → that ID is the folder name in Storage.
  ///   2. Upload all three files in parallel to Storage.
  ///   3. Write the Firestore doc with the resulting downloadUrls.
  Future<void> _submit() async {
    final err = _validateStep(_docsStepIndex);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _submitting = true;
      _uploadProgress = 'Preparing…';
      _error = null;
    });
    try {
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminUid)
          .collection('recruiting_applications');
      final docRef = col.doc();
      final appId = docRef.id;

      // Uploads run SEQUENTIALLY (not Future.wait) — iOS Safari on
      // cellular can choke on parallel resumable uploads, throwing the
      // misleading `firebase_storage/unauthorized` error. One at a time
      // is slower (~2-3s extra) but reliable.
      final slots = <(String, _PickedFile, String)>[
        ('passport', _passport!, 'Pass / Personalausweis Vorderseite'),
        ('id_back', _idBack!, 'Personalausweis Rückseite'),
        ('selfie', _selfie!, 'Selfie für Driver-Badge'),
        ('license_front', _licenseFront!, 'Führerschein Vorderseite'),
        ('license_back', _licenseBack!, 'Führerschein Rückseite'),
      ];
      final results = <RecruitingDocument>[];
      for (var i = 0; i < slots.length; i++) {
        final s = slots[i];
        setState(() =>
            _uploadProgress = 'Lädt ${i + 1}/${slots.length}: ${s.$3}…');
        try {
          final r = await _uploadDocument(
              appId: appId, label: s.$1, file: s.$2);
          results.add(r);
        } catch (e) {
          throw Exception('Upload "${s.$3}" fehlgeschlagen — $e');
        }
      }

      setState(() => _uploadProgress = 'Saving…');
      final composedLicense =
          _isLocal ? '' : _composedTruckLicenseAnswer();
      // Local/EU answers — pack them into customAnswers so we don't
      // need to evolve the RecruitingApplication schema yet. Visa
      // applications skip this block entirely.
      final mergedAnswers = <String, dynamic>{
        ..._customAnswers,
        // Asked on the very first screen for both Local and Visa
        // applicants so the admin team can sort by goal immediately.
        'employmentInterest': _employmentInterest,
        if (_employmentInterest == 'parttime')
          'parttimeDaysPerWeek': _parttimeDays,
        'birthCountry': _birthCountry.text.trim(),
        // DSGVO-Nachweis (Art. 7 DSGVO — Einwilligung dokumentieren)
        'dsgvoConsent': _dsgvoAccepted,
        'dsgvoConsentAt': DateTime.now().toIso8601String(),
        if (_isLocal) ...{
          'taxId': _taxIdLater ? 'later' : _taxId.text.trim(),
          'taxIdSubmitLater': _taxIdLater,
          'socialSecurityNumber': _socialSecurityLater
              ? 'later'
              : _socialSecurityNo.text.trim(),
          'socialSecuritySubmitLater': _socialSecurityLater,
          'healthInsuranceStatus': _healthInsuranceChoice,
          if (_healthInsuranceChoice == 'has')
            'healthInsurance': _healthInsurance.text.trim(),
          if (_healthInsuranceChoice == 'none')
            'aokBayernRegisterRequested': _aokBayernRegister == 'yes',
          'maritalStatus': _maritalStatus,
          'childrenChoice': _childrenChoice,
          if (_childrenChoice == 'count')
            'childrenCount': _childrenCount.text.trim(),
          if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
        },
      };
      final app = RecruitingApplication(
        id: appId,
        adminUid: widget.adminUid,
        channel: widget.channel,
        status: RecruitingStatus.newApp,
        submittedAt: DateTime.now(),
        firstName: _firstName.text,
        lastName: _lastName.text,
        birthDate: _birthDate,
        birthPlace: _birthPlace.text,
        nationality: _nationality,
        street: _street.text,
        postalCode: _postalCode.text,
        city: _city.text,
        livingHereSince: _livingSince,
        shirtSize: _shirtSize.text,
        shoeSize: _shoeSize.text,
        phoneWhatsApp: _phone.text,
        email: _email.text,
        truckLicense: composedLicense,
        documents: results,
        customAnswers: mergedAnswers,
      );
      await docRef.set(app.toCreatePayload());
      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Submit failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadProgress = '';
        });
      }
    }
  }

  String _composedTruckLicenseAnswer() {
    if (_truckLicenseCategory == 'none') {
      return 'No truck license · Kein Lkw-Führerschein';
    }
    final cat = _truckLicenseCategory == 'C' ? 'C' : 'CE';
    final code = _hasCode95 == true
        ? 'Code 95 vorhanden'
        : _hasCode95 == false
            ? 'ohne Code 95'
            : '';
    return code.isEmpty ? 'Class $cat' : 'Class $cat · $code';
  }

  // ── UI ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Title(
      title: _companyName.isEmpty
          ? 'Personalfragebogen'
          : 'Personalfragebogen für $_companyName',
      color: const Color(0xFF006047),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.adminUid.trim().isEmpty) {
      return _ScaffoldShell(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Invalid recruiting link.\n\n'
              'Please ask your contact at ARION LOGISTICS for the '
              'correct application URL.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ),
      );
    }
    if (_submitted) return _ScaffoldShell(body: _buildSuccess());

    // Visa-Formular: zuerst Sprache wählen (Albanisch oder Deutsch),
    // danach nur diese Sprache anzeigen.
    if (widget.channel == RecruitingChannel.visa && _visaLang == null) {
      return _ScaffoldShell(body: _buildVisaLanguagePicker());
    }

    return _ScaffoldShell(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _StepIndicator(current: _step, total: _totalSteps),
                  const SizedBox(height: 14),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStep(),
                      ),
                    ),
                  ),
                  if (_submitting && _uploadProgress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.codriverGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _uploadProgress,
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.codriverDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: AppTypography.caption1.copyWith(
                          color: const Color(0xFFB91C1C),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _buildNavButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisaLanguagePicker() {
    Widget option({
      required String flag,
      required String label,
      required String sub,
      required String code,
    }) {
      return InkWell(
        onTap: () => setState(() => _visaLang = code),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.title3.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      sub,
                      style: AppTypography.caption1.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.codriverDeep),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.translate_rounded,
                      color: AppColors.codriverDeep, size: 28),
                ),
                const SizedBox(height: 18),
                Text(
                  'Zgjidh gjuhën · Sprache wählen',
                  style: AppTypography.title2.copyWith(
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Zgjidh gjuhën për formularin · '
                  'Wähle die Sprache für das Formular.',
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                option(
                  flag: '🇦🇱',
                  label: 'Shqip',
                  sub: 'Vazhdo në shqip',
                  code: 'sq',
                ),
                const SizedBox(height: 12),
                option(
                  flag: '🇩🇪',
                  label: 'Deutsch',
                  sub: 'Weiter auf Deutsch',
                  code: 'de',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.work_history_rounded,
            color: AppColors.codriverDeep,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ARION LOGISTICS',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.codriverDeep,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                widget.channel == RecruitingChannel.visa
                    ? _vt('Aplikim me Vizë Pune', 'Arbeitsvisum-Antrag')
                    : 'Driver Application · Fahrer-Bewerbung',
                style: AppTypography.title3.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep() {
    final id = _stepIds[_step];
    switch (id) {
      case 'identity':
        return _buildIdentityStep();
      case 'address':
        return _buildAddressStep();
      case 'contact':
        return _buildContactStep();
      case 'license':
        return _buildLicenseStep();
      case 'custom':
        return _buildCustomStep();
      case 'docs':
        return _buildDocsStep();
      case 'finance':
        return _buildFinanceStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomStep() {
    return ListView(
      children: [
        _SectionLabel(
          text: _isLocal
              ? 'Additional questions · Weitere Fragen'
              : _vt('Pyetjet shtesë', 'Weitere Fragen'),
        ),
        for (final f in _customFields)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CustomFieldInput(
              field: f,
              value: _customAnswers[f.id],
              onChanged: (v) => setState(() {
                if (v == null) {
                  _customAnswers.remove(f.id);
                } else {
                  _customAnswers[f.id] = v;
                }
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildIdentityStep() {
    return ListView(
      children: [
        _SectionLabel(
          text: _isLocal
              ? 'Employment interest · Beschäftigungs-Wunsch'
              : _vt('Lloji i punës', 'Beschäftigungs-Wunsch'),
        ),
        _LabeledField(
          label: _isLocal
              ? 'What are you applying for?'
              : _vt('Për çfarë po aplikoni?', 'Was bewirbst du dich?'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: _isLocal
                    ? 'Fulltime · Vollzeit'
                    : _vt('Kohë e plotë', 'Vollzeit'),
                selected: _employmentInterest == 'fulltime',
                onTap: () =>
                    setState(() => _employmentInterest = 'fulltime'),
              ),
              _ChoiceTile(
                label: _isLocal
                    ? 'Part-time · Teilzeit'
                    : _vt('Gjysmë-orari', 'Teilzeit'),
                selected: _employmentInterest == 'parttime',
                onTap: () =>
                    setState(() => _employmentInterest = 'parttime'),
              ),
              if (_employmentInterest == 'parttime') ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 0, 6),
                  child: Text(
                    _isLocal
                        ? 'How many days per week? · Wie viele Tage pro Woche?'
                        : _vt('Sa ditë në javë?', 'Wie viele Tage pro Woche?'),
                    style: AppTypography.caption1.copyWith(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final d in const ['2', '3', '4']) ...[
                      Expanded(
                        child: _DaysChoiceTile(
                          label: _isLocal ? '$d days · $d Tage' : _vt('$d ditë', '$d Tage'),
                          selected: _parttimeDays == d,
                          onTap: () =>
                              setState(() => _parttimeDays = d),
                        ),
                      ),
                      if (d != '4') const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],
              _ChoiceTile(
                label: 'Minijob',
                selected: _employmentInterest == 'minijob',
                onTap: () =>
                    setState(() => _employmentInterest = 'minijob'),
              ),
              _ChoiceTile(
                label: _isLocal
                    ? 'Working student · Werkstudent'
                    : _vt('Student punëtor', 'Werkstudent'),
                selected: _employmentInterest == 'werkstudent',
                onTap: () =>
                    setState(() => _employmentInterest = 'werkstudent'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionLabel(
          text: _isLocal
              ? 'Personal info · Persönliche Daten'
              : _vt('Të dhënat personale', 'Persönliche Daten'),
        ),
        _LabeledField(
          label: _isLocal ? 'First name · Vorname' : _vt('Emri', 'Vorname'),
          child: TextField(
            controller: _firstName,
            decoration: _input(_isLocal ? 'e.g. Andreas' : 'z.B. Andi'),
          ),
        ),
        _LabeledField(
          label: _isLocal ? 'Last name · Nachname' : _vt('Mbiemri', 'Nachname'),
          child: TextField(
            controller: _lastName,
            decoration: _input(_isLocal ? 'e.g. Müller' : 'z.B. Krasniqi'),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'Date of birth · Geburtsdatum'
              : _vt('Data e lindjes', 'Geburtsdatum'),
          child: _DatePickerField(
            value: _birthDate,
            firstDate: DateTime(1940),
            lastDate: DateTime.now(),
            onPick: (d) => setState(() => _birthDate = d),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'Place of birth · Geburtsort'
              : _vt('Vendlindja (Qyteti)', 'Geburtsort (Stadt)'),
          child: TextField(
            controller: _birthPlace,
            decoration: _input('z.B. Prishtina'),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'Country of birth · Geburtsland'
              : _vt('Shteti i lindjes', 'Geburtsland'),
          child: TextField(
            controller: _birthCountry,
            textCapitalization: TextCapitalization.words,
            decoration: _input('z.B. Kosovo / Deutschland'),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'Nationality · Nationalität'
              : _vt('Shtetësia', 'Nationalität'),
          child: _isLocal
              ? TextField(
                  controller: _nationalityFreeText,
                  decoration: _input('e.g. Deutsch / German'),
                  onChanged: (v) =>
                      setState(() => _nationality = v.trim()),
                )
              : DropdownButtonFormField<String>(
                  initialValue: _nationality.isEmpty ? null : _nationality,
                  decoration: _input(''),
                  items: [
                    for (final n in _nationalities)
                      DropdownMenuItem(value: n, child: Text(n)),
                  ],
                  onChanged: (v) => setState(() => _nationality = v ?? ''),
                ),
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return ListView(
      children: [
        _SectionLabel(
            text: _isLocal ? 'Address · Adresse' : _vt('Adresa', 'Adresse')),
        _LabeledField(
          label: _isLocal
              ? 'Street + number · Straße + Hausnummer'
              : _vt('Rruga + Numri i shtëpisë', 'Straße + Hausnummer'),
          child: TextField(
            controller: _street,
            decoration: _input('z.B. Musterstraße 12'),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'Postal code · Postleitzahl'
              : _vt('Kodi postar', 'Postleitzahl'),
          child: TextField(
            controller: _postalCode,
            keyboardType: TextInputType.number,
            decoration: _input('z.B. 51063'),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'City · Stadt'
              : _vt('Qyteti / Vendbanimi', 'Stadt / Wohnort'),
          child: TextField(
            controller: _city,
            decoration: _input('z.B. Köln'),
          ),
        ),
        if (!_isLocal)
          _LabeledField(
            label: _vt('Që nga kur jeton në këtë adresë?', 'Wohnhaft seit?'),
            child: _DatePickerField(
              value: _livingSince,
              firstDate: DateTime(1980),
              lastDate: DateTime.now(),
              onPick: (d) => setState(() => _livingSince = d),
            ),
          ),
      ],
    );
  }

  Widget _buildContactStep() {
    return ListView(
      children: [
        _SectionLabel(
          text: _isLocal
              ? 'Sizes & contact · Größen & Kontakt'
              : _vt('Madhësitë & Kontakti', 'Größen & Kontakt'),
        ),
        _LabeledField(
          label: _isLocal
              ? 'T-shirt & jacket size · T-Shirt- & Jacken-Größe'
              : _vt('Madhësia e bluzës dhe xhaketës', 'T-Shirt- & Jacken-Größe'),
          child: _SizePickerField(
            value: _shirtSize.text,
            options: _kShirtSizes,
            onPick: (v) => setState(() => _shirtSize.text = v),
            placeholder: 'Choose size',
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'Shoe size · Schuhgröße'
              : _vt('Numri i këpucëve', 'Schuhgröße'),
          child: _SizePickerField(
            value: _shoeSize.text,
            options: _kShoeSizes,
            onPick: (v) => setState(() => _shoeSize.text = v),
            placeholder: 'Choose size',
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? 'Phone (WhatsApp) · Telefonnummer'
              : _vt('Numri i telefonit (WhatsApp)', 'Telefonnummer'),
          child: TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: _input('z.B. +49 170 1234567'),
          ),
        ),
        _LabeledField(
          label: 'Email',
          child: TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: _input('z.B. andi@example.com'),
          ),
        ),
      ],
    );
  }

  // EU clothing + shoe size scales. Kept on the form so the picker
  // is offline-friendly and the wheel feels native (no network round-
  // trip on open).
  static const List<String> _kShirtSizes = <String>[
    'XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL',
  ];
  static const List<String> _kShoeSizes = <String>[
    '36', '37', '38', '39', '40', '41', '42', '43', '44', '45',
    '46', '47', '48', '49', '50',
  ];

  Widget _buildLicenseStep() {
    return ListView(
      children: [
        _SectionLabel(text: _vt('Patenta e kamionit', 'Lkw-Führerschein')),
        Text(
          _vt('A ke edhe patentën e kamionit?',
              'Hast du auch einen Lkw-Führerschein?'),
          style: AppTypography.body.copyWith(
            color: const Color(0xFF374151),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        _RadioCard(
          selected: _truckLicenseCategory == 'none',
          title: _vt('Jo, nuk kam', 'Nein, habe ich nicht'),
          subtitle: '',
          onTap: () => setState(() {
            _truckLicenseCategory = 'none';
            _hasCode95 = null;
          }),
        ),
        const SizedBox(height: 8),
        _RadioCard(
          selected: _truckLicenseCategory == 'C',
          title: _vt('Po, kategoria C', 'Ja, Klasse C'),
          subtitle: '',
          onTap: () => setState(() => _truckLicenseCategory = 'C'),
        ),
        const SizedBox(height: 8),
        _RadioCard(
          selected: _truckLicenseCategory == 'CE',
          title: _vt('Po, kategoria CE', 'Ja, Klasse CE'),
          subtitle: '',
          onTap: () => setState(() => _truckLicenseCategory = 'CE'),
        ),
        // ── Conditional follow-up: Code 95 ─────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _truckLicenseCategory == 'C' ||
                  _truckLicenseCategory == 'CE'
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionLabel(text: _vt('Kodi 95', 'Code 95')),
                      Text(
                        _vt('A e ke kodin 95?', 'Hast du Code 95?'),
                        style: AppTypography.body.copyWith(
                          color: const Color(0xFF374151),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _RadioCard(
                              selected: _hasCode95 == true,
                              title: _vt('Po', 'Ja'),
                              subtitle: _vt('Kodi 95 ekziston', 'Code 95 vorhanden'),
                              onTap: () =>
                                  setState(() => _hasCode95 = true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _RadioCard(
                              selected: _hasCode95 == false,
                              title: _vt('Jo', 'Nein'),
                              subtitle:
                                  _vt('Kodi 95 nuk ekziston', 'Code 95 nicht vorhanden'),
                              onTap: () =>
                                  setState(() => _hasCode95 = false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Local/EU only — payroll + family questions shown after the doc
  // uploads. Tax-ID and Social Security both support a "I'll submit
  // later" toggle; marital status + children count include the same
  // "later" option (per the spec).
  Widget _buildFinanceStep() {
    return ListView(
      children: [
        _SectionLabel(text: 'Payroll data · Lohnsteuer-Daten'),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
          child: Text(
            'You can find both numbers on your last pay slip. · '
            'Beide Nummern findest du in deiner letzten Lohnabrechnung.',
            style: AppTypography.caption1.copyWith(
              color: const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        _LabeledField(
          label: 'Tax ID · Steueridentifikationsnummer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _taxId,
                enabled: !_taxIdLater,
                keyboardType: TextInputType.number,
                decoration: _input('11 digits · 11-stellig'),
              ),
              _LaterToggle(
                checked: _taxIdLater,
                onChanged: (v) => setState(() => _taxIdLater = v),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: 'Social security no. · Sozialversicherungsnummer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _socialSecurityNo,
                enabled: !_socialSecurityLater,
                decoration: _input('12 chars · 12-stellig'),
              ),
              _LaterToggle(
                checked: _socialSecurityLater,
                onChanged: (v) =>
                    setState(() => _socialSecurityLater = v),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: 'Health insurance · Krankenkasse',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: 'Ich habe eine Krankenkasse',
                selected: _healthInsuranceChoice == 'has',
                onTap: () => setState(() => _healthInsuranceChoice = 'has'),
              ),
              if (_healthInsuranceChoice == 'has')
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                  child: TextField(
                    controller: _healthInsurance,
                    textCapitalization: TextCapitalization.words,
                    decoration: _input(
                      'Name der Krankenkasse · z. B. TK, AOK, Barmer',
                    ),
                  ),
                ),
              _ChoiceTile(
                label: 'Ich bin aktuell nicht versichert / '
                    'ich habe keine Krankenkasse',
                selected: _healthInsuranceChoice == 'none',
                onTap: () => setState(() {
                  _healthInsuranceChoice = 'none';
                  _healthInsurance.clear();
                }),
              ),
              if (_healthInsuranceChoice == 'none') ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                  child: Text(
                    'Möchtest du, dass wir dich bei der AOK Bayern anmelden?',
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _ChoiceTile(
                  label: 'Ja, bitte bei AOK Bayern anmelden',
                  selected: _aokBayernRegister == 'yes',
                  onTap: () => setState(() => _aokBayernRegister = 'yes'),
                ),
                _ChoiceTile(
                  label: 'Nein, ich kümmere mich selbst darum',
                  selected: _aokBayernRegister == 'no',
                  onTap: () => setState(() => _aokBayernRegister = 'no'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionLabel(text: 'Family · Familie'),
        _LabeledField(
          label: 'Marital status · Familienstand',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: 'Geschieden',
                selected: _maritalStatus == 'divorced',
                onTap: () => setState(() => _maritalStatus = 'divorced'),
              ),
              _ChoiceTile(
                label: 'Ledig',
                selected: _maritalStatus == 'single',
                onTap: () => setState(() => _maritalStatus = 'single'),
              ),
              _ChoiceTile(
                label: 'Verheiratet oder getrennt lebend',
                selected: _maritalStatus == 'married_or_separated',
                onTap: () => setState(
                  () => _maritalStatus = 'married_or_separated',
                ),
              ),
              _ChoiceTile(
                label: 'Verwitwet',
                selected: _maritalStatus == 'widowed',
                onTap: () => setState(() => _maritalStatus = 'widowed'),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: 'Children · Kinder',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: 'No children · Keine Kinder',
                selected: _childrenChoice == 'none',
                onTap: () => setState(() => _childrenChoice = 'none'),
              ),
              _ChoiceTile(
                label: 'Yes · Ja',
                selected: _childrenChoice == 'count',
                onTap: () => setState(() => _childrenChoice = 'count'),
              ),
              if (_childrenChoice == 'count')
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: TextField(
                    controller: _childrenCount,
                    keyboardType: TextInputType.number,
                    decoration: _input('Number · Anzahl'),
                  ),
                ),
              _ChoiceTile(
                label: "I'll submit later · Reiche ich später nach",
                selected: _childrenChoice == 'later',
                onTap: () => setState(() => _childrenChoice = 'later'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionLabel(text: 'Notes · Anmerkungen'),
        _LabeledField(
          label: 'Anything else we should know? · '
              'Möchtest du uns noch etwas mitteilen?',
          child: TextField(
            controller: _notes,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _input(
              'Optional — e.g. start date, preferred shifts, questions · '
              'Optional — z. B. Startdatum, gewünschte Schichten, Fragen',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocsStep() {
    return ListView(
      children: [
        _SectionLabel(
          text: _isLocal
              ? 'Documents · Dokumente'
              : _vt('Dokumentet', 'Dokumente'),
        ),
        Text(
          _isLocal
              ? 'Clear, complete, no shadows.\n'
                  'Bitte gut sichtbar, vollständig, nicht abgeschnitten.'
              : _vt('Foto e qartë, e plotë dhe pa hije.',
                  'Bitte gut sichtbar, vollständig, nicht abgeschnitten.'),
          style: AppTypography.caption1.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        _UploadCard(
          title: _isLocal
              ? 'Passport / ID — front · Pass / Personalausweis (Vorderseite)'
              : 'Pass / Personalausweis (Vorderseite)',
          subtitle: _isLocal
              ? 'Front side of passport or ID card · Vorderseite'
              : _vt('Faqja e parë', 'Vorderseite'),
          icon: Icons.badge_outlined,
          file: _passport,
          onPick: () => _pickDocument('passport'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: _isLocal
              ? 'ID card — back · Personalausweis (Rückseite)'
              : _vt('Karta e identitetit (Pjesa e prapme)',
                  'Personalausweis (Rückseite)'),
          subtitle: _isLocal
              ? 'Back side of your ID card · Rückseite des Personalausweises'
              : _vt('Faqja e prapme e kartës', 'Rückseite'),
          icon: Icons.badge_outlined,
          file: _idBack,
          onPick: () => _pickDocument('id_back'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: _isLocal
              ? 'Selfie for Driver Badge · Selfie für Driver-Badge'
              : _vt('Selfie për Driver-Badge', 'Selfie für Driver-Badge'),
          subtitle: _isLocal
              ? 'Plain white background, head straight, no sunglasses · '
                  'Weißer Hintergrund, Kopf gerade, keine Sonnenbrille'
              : _vt('Sfond i bardhë, koka drejt, pa syze dielli',
                  'Weißer Hintergrund, Kopf gerade, keine Sonnenbrille'),
          icon: Icons.face_retouching_natural_rounded,
          file: _selfie,
          onPick: () => _pickDocument('selfie'),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  size: 18, color: Color(0xFF92400E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isLocal
                      ? 'Photograph the driver\'s licence straight from above, '
                          'in high quality. The whole card must be visible.\n'
                          'Bitte den Führerschein gerade von oben in guter '
                          'Qualität fotografieren. Der gesamte Führerschein '
                          'muss zu sehen sein.'
                      : _vt(
                          'Të dhënat e patentës: foto nga lart, e qartë dhe '
                              'patenta në tërësi e dukshme.',
                          'Bitte den Führerschein gerade von oben in guter '
                              'Qualität fotografieren. Der gesamte Führerschein '
                              'muss zu sehen sein.'),
                  style: AppTypography.caption1.copyWith(
                    color: const Color(0xFF7A3E08),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: _isLocal
              ? "Driver's licence (front) · Führerschein (Vorderseite)"
              : _vt('Patenta', 'Führerschein (Vorderseite)'),
          subtitle: _isLocal
              ? 'Front side · Vorderseite'
              : _vt('Pjesa e parë', 'Vorderseite'),
          icon: Icons.credit_card_rounded,
          file: _licenseFront,
          onPick: () => _pickDocument('license_front'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: _isLocal
              ? "Driver's licence (back) · Führerschein (Rückseite)"
              : _vt('Patenta', 'Führerschein (Rückseite)'),
          subtitle: _isLocal
              ? 'Back side · Rückseite'
              : _vt('Pjesa e prapme', 'Rückseite'),
          icon: Icons.credit_card_outlined,
          file: _licenseBack,
          onPick: () => _pickDocument('license_back'),
        ),
        const SizedBox(height: 18),
        _DsgvoConsent(
          isLocal: _isLocal,
          companyName: _companyName,
          accepted: _dsgvoAccepted,
          onChanged: (v) => setState(() {
            _dsgvoAccepted = v;
            if (v) _error = null;
          }),
        ),
      ],
    );
  }

  Widget _buildNavButtons() {
    final isLast = _step == _totalSteps - 1;
    return Row(
      children: [
        if (_step > 0)
          CoButton(
            onPressed: _submitting
                ? null
                : () => setState(() => _step -= 1),
            label: 'Back',
            variant: CoButtonVariant.quiet,
          ),
        const Spacer(),
        CoButton(
          onPressed: _submitting
              ? null
              : () {
                  final err = _validateStep(_step);
                  if (err != null) {
                    setState(() => _error = err);
                    return;
                  }
                  setState(() => _error = null);
                  if (isLast) {
                    _submit();
                  } else {
                    setState(() => _step += 1);
                  }
                },
          label: isLast
              ? (_isLocal ? 'Submit · Senden' : _vt('Dërgo', 'Senden'))
              : (_isLocal ? 'Next · Weiter' : _vt('Vazhdo', 'Weiter')),
          icon:
              isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
          busy: _submitting,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.green50,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.codriverGreen,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isLocal ? 'Thank you! · Danke!' : _vt('Faleminderit!', 'Danke!'),
              style: AppTypography.title2.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _isLocal
                  ? 'Your application has been submitted. '
                      'We will get back to you shortly.\n'
                      'Ihre Bewerbung wurde übermittelt. Wir melden uns in '
                      'Kürze.'
                  : _vt(
                      'Aplikimi yt u dërgua. Do të kontaktojmë së shpejti.',
                      'Ihre Bewerbung wurde übermittelt. Wir melden uns in '
                          'Kürze.'),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(
          color: const Color(0xFFD1D5DB),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.codriverGreen,
            width: 1.5,
          ),
        ),
      );
}

// ──────────────────────────────────────────────────────────────────
//   Helper widgets
// ──────────────────────────────────────────────────────────────────

class _ScaffoldShell extends StatelessWidget {
  const _ScaffoldShell({required this.body});
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      body: body,
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: i <= current
                    ? AppColors.codriverGreen
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.caption2.copyWith(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption1.copyWith(
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// Renders one DSP-defined custom question. The widget dispatches on
/// [RecruitingFieldType] — short text → TextField; long text → multi-
/// line TextField; dropdown → choice-chip group; yes/no → two radio
/// cards; date → date picker.
class _CustomFieldInput extends StatelessWidget {
  const _CustomFieldInput({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final RecruitingCustomField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = field.required ? '${field.label} *' : field.label;
    Widget body;
    switch (field.type) {
      case RecruitingFieldType.shortText:
        body = TextField(
          controller: TextEditingController(text: value?.toString() ?? '')
            ..selection = TextSelection.collapsed(
              offset: (value?.toString() ?? '').length,
            ),
          onChanged: onChanged,
          decoration: _customInput('Type your answer'),
        );
        break;
      case RecruitingFieldType.longText:
        body = TextField(
          controller: TextEditingController(text: value?.toString() ?? '')
            ..selection = TextSelection.collapsed(
              offset: (value?.toString() ?? '').length,
            ),
          minLines: 3,
          maxLines: 6,
          onChanged: onChanged,
          decoration: _customInput('Type your answer'),
        );
        break;
      case RecruitingFieldType.dropdown:
        body = Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final opt in field.options)
              ChoiceChip(
                label: Text(opt),
                selected: value == opt,
                onSelected: (_) => onChanged(opt),
                selectedColor: AppColors.codriverGreen,
                backgroundColor: const Color(0xFFF9FAFB),
                side: BorderSide(
                  color: value == opt
                      ? AppColors.codriverGreen
                      : const Color(0xFFE5E7EB),
                ),
                labelStyle: AppTypography.caption1.copyWith(
                  color: value == opt
                      ? Colors.white
                      : const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        );
        break;
      case RecruitingFieldType.yesNo:
        body = Row(
          children: [
            Expanded(
              child: _RadioCard(
                selected: value == true,
                title: 'Yes · Ja',
                subtitle: '',
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RadioCard(
                selected: value == false,
                title: 'No · Nein',
                subtitle: '',
                onTap: () => onChanged(false),
              ),
            ),
          ],
        );
        break;
      case RecruitingFieldType.date:
        DateTime? d;
        if (value is String && value.toString().isNotEmpty) {
          d = DateTime.tryParse(value.toString());
        }
        body = _DatePickerField(
          value: d,
          firstDate: DateTime(1940),
          lastDate: DateTime(2100),
          onPick: (picked) =>
              onChanged(picked.toIso8601String().substring(0, 10)),
        );
        break;
    }
    return _LabeledField(label: label, child: body);
  }

  InputDecoration _customInput(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body.copyWith(
          color: const Color(0xFFD1D5DB),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.codriverGreen,
            width: 1.5,
          ),
        ),
      );
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onPick,
  });

  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPick;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate,
          lastDate: lastDate,
          initialDate: value ?? DateTime(2000, 1, 1),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 10),
            Text(
              value == null ? 'Choose a date' : _fmt(value!),
              style: AppTypography.body.copyWith(
                color: value == null
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact radio-card used by the LKW question and Code-95 follow-up.
/// Picks up Emil-Kowalski feel via [CoPressable]: 0.97 press-scale
/// with spring overshoot. Subtle by design — productivity, not party.
class _RadioCard extends StatelessWidget {
  const _RadioCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CoPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.green50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.codriverGreen
                : const Color(0xFFE5E7EB),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.codriverGreen
                    : Colors.white,
                border: Border.all(
                  color: selected
                      ? AppColors.codriverGreen
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.subheadline.copyWith(
                      color: selected
                          ? AppColors.codriverDeep
                          : const Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        subtitle,
                        style: AppTypography.caption2.copyWith(
                          color: selected
                              ? AppColors.codriverDeep
                                  .withValues(alpha: 0.7)
                              : const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS-style size selector. Opens a Cupertino wheel picker in a
/// modal bottom sheet so the user can spin through EU shirt / shoe
/// sizes — fits Emil-Kowalski's "use spring physics, not arbitrary
/// curves" rule (the wheel has native momentum & snap).
class _SizePickerField extends StatelessWidget {
  const _SizePickerField({
    required this.value,
    required this.options,
    required this.onPick,
    this.placeholder = 'Choose',
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onPick;
  final String placeholder;

  Future<void> _open(BuildContext context) async {
    final initial =
        options.indexOf(value.trim()).clamp(0, options.length - 1);
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var picked = options[initial];
        return SafeArea(
          top: false,
          child: SizedBox(
            height: 280,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    children: [
                      CoButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        label: 'Cancel',
                        variant: CoButtonVariant.quiet,
                      ),
                      const Spacer(),
                      CoButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(picked),
                        label: 'Done',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 38,
                    scrollController: FixedExtentScrollController(
                      initialItem: initial,
                    ),
                    onSelectedItemChanged: (i) => picked = options[i],
                    children: [
                      for (final o in options)
                        Center(
                          child: Text(
                            o,
                            style: AppTypography.title3.copyWith(
                              color: AppColors.codriverGraphite,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) onPick(result);
  }

  @override
  Widget build(BuildContext context) {
    final empty = value.trim().isEmpty;
    return CoPressable(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.straighten_rounded,
              size: 18,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                empty ? placeholder : value,
                style: AppTypography.body.copyWith(
                  color: empty
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

/// DSGVO-Einwilligung am Ende des Formulars: Art.-13-Informationen +
/// aktive (nicht vorausgewählte) Checkbox. Ohne Häkchen ist kein Absenden
/// möglich (siehe _validateStep). Texte vor Live-Gang vom Datenschutz-
/// Anwalt prüfen lassen.
class _DsgvoConsent extends StatelessWidget {
  const _DsgvoConsent({
    required this.isLocal,
    required this.companyName,
    required this.accepted,
    required this.onChanged,
  });

  final bool isLocal;
  final String companyName;
  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1D7F5A);
    final company =
        companyName.trim().isEmpty ? 'das Unternehmen' : companyName.trim();
    final companyOther = companyName.trim().isEmpty
        ? (isLocal ? 'the company' : 'kompania')
        : companyName.trim();

    final infoDe =
        'Verantwortlich für die Datenverarbeitung ist $company. Deine Angaben '
        'und hochgeladenen Dokumente werden ausschließlich zur Bearbeitung '
        'deiner Bewerbung sowie zur Anbahnung und Durchführung eines möglichen '
        'Beschäftigungsverhältnisses verarbeitet (Art. 6 Abs. 1 lit. b DSGVO, '
        '§ 26 BDSG; Foto/Selfie für den Driver-Badge auf Grundlage deiner '
        'Einwilligung, Art. 6 Abs. 1 lit. a DSGVO).\n\n'
        'Alle Daten werden sicher auf Servern in der EU gespeichert und nicht '
        'an unbefugte Dritte weitergegeben. Die technische Verarbeitung erfolgt '
        'durch unseren Auftragsverarbeiter CoDriver (Kreativwerk Albert Dobra). '
        'Eine Übermittlung an Behörden erfolgt nur, soweit gesetzlich '
        'erforderlich (z. B. im Visum-/ZAV-Verfahren).\n\n'
        'Deine Daten werden gelöscht, sobald sie für diese Zwecke nicht mehr '
        'erforderlich sind. Dir stehen die Rechte auf Auskunft, Berichtigung, '
        'Löschung, Einschränkung und Datenübertragbarkeit zu; eine erteilte '
        'Einwilligung kannst du jederzeit mit Wirkung für die Zukunft '
        'widerrufen. Außerdem hast du ein Beschwerderecht bei einer '
        'Datenschutz-Aufsichtsbehörde.';

    final infoEn =
        '$companyOther is the controller for processing your data. Your details '
        'and uploaded documents are processed solely to handle your application '
        'and to establish and carry out a possible employment relationship '
        '(Art. 6(1)(b) GDPR; photo/selfie for the driver badge based on your '
        'consent, Art. 6(1)(a) GDPR). All data is stored securely on servers in '
        'the EU and is not shared with unauthorised third parties; technical '
        'processing is carried out by our processor CoDriver (Kreativwerk Albert '
        'Dobra). Data is shared with authorities only where legally required and '
        'is deleted once no longer needed. You have the right to access, '
        'rectification, erasure, restriction and data portability, to withdraw '
        'consent at any time, and to lodge a complaint with a supervisory '
        'authority.';

    final infoSq =
        '$companyOther është përgjegjës për përpunimin e të dhënave tuaja. Të '
        'dhënat dhe dokumentet e ngarkuara përpunohen vetëm për shqyrtimin e '
        'aplikimit dhe për krijimin e zhvillimin e një marrëdhënieje të mundshme '
        'pune (neni 6(1)(b) GDPR; foto/selfie për distinktivin e shoferit në '
        'bazë të pëlqimit tuaj, neni 6(1)(a) GDPR). Të gjitha të dhënat ruhen në '
        'mënyrë të sigurt në servera në BE dhe nuk u jepen palëve të treta të '
        'paautorizuara; përpunimi teknik kryhet nga përpunuesi ynë CoDriver '
        '(Kreativwerk Albert Dobra). Të dhënat u jepen autoriteteve vetëm kur '
        'kërkohet me ligj dhe fshihen kur nuk nevojiten më. Keni të drejtën e '
        'qasjes, korrigjimit, fshirjes, kufizimit dhe transferueshmërisë, të '
        'tërhiqni pëlqimin në çdo kohë dhe të ankoheni te një autoritet '
        'mbikëqyrës.';

    const consentDe =
        'Ich habe die Datenschutzhinweise gelesen und willige in die '
        'Verarbeitung und sichere Speicherung meiner Daten und Dokumente zu den '
        'genannten Zwecken ein.';
    final consentOther = isLocal
        ? 'I have read the privacy notice and consent to the processing and '
            'secure storage of my data and documents for the stated purposes.'
        : 'I kam lexuar udhëzimet e privatësisë dhe jap pëlqimin për përpunimin '
            'dhe ruajtjen e sigurt të të dhënave dhe dokumenteve të mia për '
            'qëllimet e përmendura.';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E7DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.privacy_tip_outlined, size: 18, color: green),
              const SizedBox(width: 8),
              Text(
                isLocal
                    ? 'Data protection · Datenschutz'
                    : 'Mbrojtja e të dhënave · Datenschutz',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            infoDe,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLocal ? infoEn : infoSq,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
          InkWell(
            onTap: () => onChanged(!accepted),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: accepted,
                      onChanged: (v) => onChanged(v ?? false),
                      activeColor: green,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          consentDe,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          consentOther,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.35,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.onPick,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _PickedFile? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final has = file != null;
    return CoPressable(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: has ? AppColors.green50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: has
                ? AppColors.codriverGreen.withValues(alpha: 0.4)
                : const Color(0xFFE5E7EB),
            width: has ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: has
                    ? AppColors.codriverGreen
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                has ? Icons.check_rounded : icon,
                color: has ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.subheadline.copyWith(
                      color: has
                          ? AppColors.codriverDeep
                          : const Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    has ? file!.filename : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption2.copyWith(
                      color: has
                          ? AppColors.codriverDeep
                              .withValues(alpha: 0.75)
                          : const Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.upload_file_outlined,
              size: 20,
              color: has
                  ? AppColors.codriverDeep
                  : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact "I'll submit later" checkbox used for the optional payroll
/// fields on the Local/EU recruiting form.
class _LaterToggle extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  const _LaterToggle({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => onChanged(!checked),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: checked,
                onChanged: (v) => onChanged(v ?? false),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "I'll submit later · Reiche ich später nach",
                style: AppTypography.body.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-choice option tile used in the Local/EU "marital status"
/// + "children" questions. Selected = filled accent, unselected =
/// neutral border.
/// Compact 3-up "2 / 3 / 4 days" toggle shown when the applicant
/// picks Part-time. Smaller footprint than the standard _ChoiceTile
/// so all three fit side-by-side without overflowing the form column.
class _DaysChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DaysChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.codriverGreen
                : const Color(0xFFE5E7EB),
            width: selected ? 1.6 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 16,
              color: selected
                  ? AppColors.codriverGreen
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.codriverGreen
                  : const Color(0xFFE5E7EB),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.codriverGreen
                    : const Color(0xFF9CA3AF),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickedFile {
  const _PickedFile({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String mimeType;
}
