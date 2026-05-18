// lib/Screens/recruiting_form_page.dart
//
// Public, login-less recruiting form. Mirrors the ARION LOGISTICS
// Google Form 1:1 (questions in Albanian + German), plus the
// passport / ID + driver-license-front/back uploads at the end so
// the admin team has everything needed to file the work-visa
// (Arbeitsvisum) request.
//
// Routed by main.dart from `/recruiting?dsp=<adminUid>&type=local|visa`.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  DateTime? _birthDate;
  final _birthPlace = TextEditingController();
  String _nationality = '';
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

  // ── Step 4: truck license ──
  /// Two-step replacement: category first (none / C / CE), then —
  /// only if C or CE — the Code 95 follow-up.
  String _truckLicenseCategory = ''; // '', 'none', 'C', 'CE'
  bool? _hasCode95;

  // ── Step 5: documents ──
  _PickedFile? _passport;
  _PickedFile? _licenseFront;
  _PickedFile? _licenseBack;

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
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _birthPlace.dispose();
    _street.dispose();
    _postalCode.dispose();
    _city.dispose();
    _shirtSize.dispose();
    _shoeSize.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  /// Dynamic step list — when the DSP has custom questions configured
  /// we insert a 'custom' step right before the documents step.
  List<String> get _stepIds {
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
    final idx = id == 'identity'
        ? 0
        : id == 'address'
            ? 1
            : id == 'contact'
                ? 2
                : id == 'license'
                    ? 3
                    : 4;
    switch (idx) {
      case 0:
        if (_firstName.text.trim().isEmpty) return 'Emri / Vorname fehlt.';
        if (_lastName.text.trim().isEmpty) return 'Mbiemri / Nachname fehlt.';
        if (_birthDate == null) {
          return 'Data e lindjes / Geburtsdatum fehlt.';
        }
        if (_birthPlace.text.trim().isEmpty) {
          return 'Vendlindja / Geburtsort fehlt.';
        }
        if (_nationality.isEmpty) {
          return 'Shtetësia / Nationalität fehlt.';
        }
        return null;
      case 1:
        if (_street.text.trim().isEmpty) return 'Rruga / Adresse fehlt.';
        if (_postalCode.text.trim().isEmpty) return 'Kodi postar / PLZ fehlt.';
        if (_city.text.trim().isEmpty) return 'Qyteti / Stadt fehlt.';
        if (_livingSince == null) {
          return 'Që nga kur? / Seit wann? fehlt.';
        }
        return null;
      case 2:
        if (_shirtSize.text.trim().isEmpty) return 'Madhësia / Größe fehlt.';
        if (_shoeSize.text.trim().isEmpty) {
          return 'Numri i këpucëve / Schuhgröße fehlt.';
        }
        if (_phone.text.trim().isEmpty) return 'Telefon fehlt.';
        if (_email.text.trim().isEmpty) return 'Email fehlt.';
        if (!_email.text.contains('@')) return 'Email ist ungültig.';
        return null;
      case 3:
        if (_truckLicenseCategory.isEmpty) {
          return 'Patenta e kamionit / Lkw-Führerschein-Antwort fehlt.';
        }
        if (_truckLicenseCategory != 'none' && _hasCode95 == null) {
          return 'Code 95 — bitte Ja oder Nein wählen.';
        }
        return null;
      case 4:
        if (_passport == null) {
          return 'Pass / Personalausweis fehlt.';
        }
        if (_licenseFront == null) {
          return 'Führerschein Vorderseite fehlt.';
        }
        if (_licenseBack == null) {
          return 'Führerschein Rückseite fehlt.';
        }
        return null;
      default:
        return null;
    }
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

    // Auto-compress oversized images (5 MB hard cap). PDFs go through
    // untouched — admin can ask for a smaller one if needed.
    const maxBytes = 5 * 1024 * 1024;
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
    } else if (bytes.lengthInBytes > maxBytes) {
      setState(() => _error =
          'File too large (${(bytes.lengthInBytes / 1024 / 1024).toStringAsFixed(1)} MB). '
          'Max 5 MB per document.');
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
        case 'license_front':
          _licenseFront = picked;
          break;
        case 'license_back':
          _licenseBack = picked;
          break;
      }
    });
  }

  /// Down-scales an image so its longest edge is ≤ 2000 px and
  /// re-encodes at JPEG q80 — typical 8-12 MP phone shots end up
  /// around 600–900 KB without visible loss for ID documents.
  Future<Uint8List?> _compressImage(Uint8List raw) async {
    try {
      final decoded = img.decodeImage(raw);
      if (decoded == null) return null;
      const maxEdge = 2000;
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
      final encoded = img.encodeJpg(resized, quality: 80);
      return Uint8List.fromList(encoded);
    } catch (_) {
      return null;
    }
  }

  /// Upload a single picked file to Firebase Storage under
  ///   `recruiting/{adminUid}/{appId}/{label}.{ext}`
  /// and return the resulting downloadUrl + storagePath.
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
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putData(
      file.bytes,
      SettableMetadata(contentType: file.mimeType),
    );
    final url = await ref.getDownloadURL();
    return RecruitingDocument(
      label: label,
      filename: file.filename,
      mimeType: file.mimeType,
      downloadUrl: url,
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

      setState(() => _uploadProgress = 'Uploading documents…');
      final results = await Future.wait(<Future<RecruitingDocument>>[
        _uploadDocument(
            appId: appId, label: 'passport', file: _passport!),
        _uploadDocument(
            appId: appId,
            label: 'license_front',
            file: _licenseFront!),
        _uploadDocument(
            appId: appId, label: 'license_back', file: _licenseBack!),
      ]);

      setState(() => _uploadProgress = 'Saving…');
      final composedLicense = _composedTruckLicenseAnswer();
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
        customAnswers: Map<String, dynamic>.from(_customAnswers),
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
                    ? 'Aplikim me Vizë Pune · Working Visa Application'
                    : 'Aplikim Local / EU · Local / EU Application',
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
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomStep() {
    return ListView(
      children: [
        _SectionLabel(text: 'Pyetjet shtesë · Weitere Fragen'),
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
        _SectionLabel(text: 'Të dhënat personale · Personal info'),
        _LabeledField(
          label: 'Emri · Vorname',
          child: TextField(
            controller: _firstName,
            decoration: _input('z.B. Andi'),
          ),
        ),
        _LabeledField(
          label: 'Mbiemri · Nachname',
          child: TextField(
            controller: _lastName,
            decoration: _input('z.B. Krasniqi'),
          ),
        ),
        _LabeledField(
          label: 'Data e lindjes · Geburtsdatum',
          child: _DatePickerField(
            value: _birthDate,
            firstDate: DateTime(1940),
            lastDate: DateTime.now(),
            onPick: (d) => setState(() => _birthDate = d),
          ),
        ),
        _LabeledField(
          label: 'Vendlindja (Qyteti) · Geburtsort (Stadt)',
          child: TextField(
            controller: _birthPlace,
            decoration: _input('z.B. Prishtina'),
          ),
        ),
        _LabeledField(
          label: 'Shtetësia · Nationalität',
          child: DropdownButtonFormField<String>(
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
        _SectionLabel(text: 'Adresa · Adresse'),
        _LabeledField(
          label: 'Rruga + Numri i shtëpisë · Straße + Hausnummer',
          child: TextField(
            controller: _street,
            decoration: _input('z.B. Musterstraße 12'),
          ),
        ),
        _LabeledField(
          label: 'Kodi postar · Postleitzahl',
          child: TextField(
            controller: _postalCode,
            keyboardType: TextInputType.number,
            decoration: _input('z.B. 51063'),
          ),
        ),
        _LabeledField(
          label: 'Qyteti / Vendbanimi · Stadt / Wohnort',
          child: TextField(
            controller: _city,
            decoration: _input('z.B. Köln'),
          ),
        ),
        _LabeledField(
          label: 'Që nga kur jeton në këtë adresë? · Wohnhaft seit?',
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
        _SectionLabel(text: 'Madhësitë & Kontakti · Größen & Kontakt'),
        _LabeledField(
          label: 'Madhësia e bluzës dhe xhaketës · T-Shirt- & Jacken-Größe',
          child: _SizePickerField(
            value: _shirtSize.text,
            options: _kShirtSizes,
            onPick: (v) => setState(() => _shirtSize.text = v),
            placeholder: 'Choose size',
          ),
        ),
        _LabeledField(
          label: 'Numri i këpucëve · Schuhgröße',
          child: _SizePickerField(
            value: _shoeSize.text,
            options: _kShoeSizes,
            onPick: (v) => setState(() => _shoeSize.text = v),
            placeholder: 'Choose size',
          ),
        ),
        _LabeledField(
          label: 'Numri i telefonit (WhatsApp) · Telefonnummer',
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
        _SectionLabel(text: 'Patenta e kamionit · Lkw-Führerschein'),
        Text(
          'A ke edhe patentën e kamionit?\nHast du auch einen Lkw-Führerschein?',
          style: AppTypography.body.copyWith(
            color: const Color(0xFF374151),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        _RadioCard(
          selected: _truckLicenseCategory == 'none',
          title: 'Jo, nuk kam',
          subtitle: 'Nein, habe ich nicht',
          onTap: () => setState(() {
            _truckLicenseCategory = 'none';
            _hasCode95 = null;
          }),
        ),
        const SizedBox(height: 8),
        _RadioCard(
          selected: _truckLicenseCategory == 'C',
          title: 'Po, kategoria C',
          subtitle: 'Ja, Klasse C',
          onTap: () => setState(() => _truckLicenseCategory = 'C'),
        ),
        const SizedBox(height: 8),
        _RadioCard(
          selected: _truckLicenseCategory == 'CE',
          title: 'Po, kategoria CE',
          subtitle: 'Ja, Klasse CE',
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
                      _SectionLabel(text: 'Kodi 95 · Code 95'),
                      Text(
                        'A e ke kodin 95?\nHast du Code 95?',
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
                              title: 'Po · Ja',
                              subtitle: 'Code 95 vorhanden',
                              onTap: () =>
                                  setState(() => _hasCode95 = true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _RadioCard(
                              selected: _hasCode95 == false,
                              title: 'Jo · Nein',
                              subtitle: 'Code 95 nicht vorhanden',
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

  Widget _buildDocsStep() {
    return ListView(
      children: [
        _SectionLabel(
          text: 'Dokumentet · Dokumente',
        ),
        Text(
          'Foto e qartë, e plotë dhe pa hije.\n'
          'Bitte gut sichtbar, vollständig, nicht abgeschnitten.',
          style: AppTypography.caption1.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        _UploadCard(
          title: 'Pass / Personalausweis',
          subtitle:
              'Passi ose karta e identitetit · Reisepass oder ID-Karte',
          icon: Icons.badge_outlined,
          file: _passport,
          onPick: () => _pickDocument('passport'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: 'Patenta · Führerschein (Vorderseite)',
          subtitle: 'Pjesa e parë · Front side',
          icon: Icons.credit_card_rounded,
          file: _licenseFront,
          onPick: () => _pickDocument('license_front'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: 'Patenta · Führerschein (Rückseite)',
          subtitle: 'Pjesa e prapme · Back side',
          icon: Icons.credit_card_outlined,
          file: _licenseBack,
          onPick: () => _pickDocument('license_back'),
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
          label: isLast ? 'Submit · Dërgo' : 'Next · Vazhdo',
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
              'Faleminderit! · Danke!',
              style: AppTypography.title2.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Aplikimi yt u dërgua. Do të kontaktojmë së shpejti.\n'
              'Ihre Bewerbung wurde übermittelt. Wir melden uns in '
              'Kürze.',
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
