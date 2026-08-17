// lib/Screens/recruiting_agency_form_page.dart
//
// Staffing-agency form for the Non-EU / Working-Visa channel.
//
// Context: recruitment agencies send Arion the candidate data needed to
// start a working-visa procedure. Arion has NO direct contact with the
// candidate — the agency is the counterpart the team calls once the
// Vorabzustimmung arrives. This form therefore captures the AGENCY
// contact next to the candidate's identity documents.
//
// Two entry points, same widget:
//   • internal  — opened from the Recruiting panel (admin is signed in)
//   • public    — /jobs/<slug>/agency  ·  /apply?dsp=<uid>&type=agency
//
// Submissions are written with channel `visa` (NOT a new channel value:
// firestore.rules pins the public create to `channel in ['local','visa']`)
// and are marked with `customAnswers.viaAgency = true`, so they show up
// in the Visa tab alongside the direct applications but stay clearly
// labelled.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/recruiting_agency.dart';
import '../models/recruiting_application.dart';
import '../services/recruiting_agency_repository.dart';
import '../services/recruiting_upload_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';

class RecruitingAgencyFormPage extends StatefulWidget {
  const RecruitingAgencyFormPage({
    super.key,
    required this.adminUid,
    this.isInternal = false,
  });

  /// Target admin / DSP namespace.
  final String adminUid;

  /// True when opened from the admin panel. The admin is authenticated,
  /// so a newly entered agency can be persisted to the directory right
  /// away. Public submissions are adopted later by the panel.
  final bool isInternal;

  @override
  State<RecruitingAgencyFormPage> createState() =>
      _RecruitingAgencyFormPageState();
}

class _RecruitingAgencyFormPageState extends State<RecruitingAgencyFormPage> {
  static const _uploads = RecruitingUploadService();
  final _agencyRepo = RecruitingAgencyRepository();

  // 'de' | 'en' — agencies are DE/EN capable, so a compact toggle in the
  // header is enough (no five-language picker like the driver form).
  String _lang = 'de';
  String _t(String de, String en) => _lang == 'en' ? en : de;

  String _companyName = '';
  int _step = 0;
  bool _submitting = false;
  bool _submitted = false;
  String _uploadProgress = '';
  String? _error;

  // ── Agency block ──
  List<RecruitingAgency> _savedAgencies = const <RecruitingAgency>[];
  bool _loadingAgencies = true;

  /// id of the picked saved agency, or [_kNewAgency] when entering a
  /// new one. Empty = nothing chosen yet.
  String _agencySelection = '';
  static const _kNewAgency = '__new__';

  final _agencyName = TextEditingController();
  final _agencyPhone = TextEditingController();
  final _agencyEmail = TextEditingController();

  // ── Candidate block ──
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  DateTime? _birthDate;
  String _gender = ''; // 'm' | 'f' | 'd'

  /// Country of origin. Mirrors the Visa form 1:1 (same option list,
  /// same "Andere…" free-text escape hatch) and is stored in the very
  /// same `nationality` field on the application document, so the admin
  /// panel renders it without any extra mapping.
  String _nationality = '';
  String _nationalitySelect = '';
  final _nationalityFreeText = TextEditingController();
  static const _kNationalityOther = '__other__';
  static const _nationalities = <String>[
    'Kosovë / Kosovo',
    'Shqipëri / Albanien',
    'Maqedonia e Veriut / Nordmazedonien',
    'Serbi / Serbien',
  ];

  // ── Documents ──
  PickedRecruitingFile? _passportFront;
  PickedRecruitingFile? _passportBack;
  PickedRecruitingFile? _licenseFront;
  PickedRecruitingFile? _licenseBack;
  PickedRecruitingFile? _ezb;

  static const List<String> _stepIds = <String>['agency', 'candidate', 'docs'];
  int get _totalSteps => _stepIds.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.adminUid.trim().isEmpty) {
      setState(() => _loadingAgencies = false);
      return;
    }
    final agencies = await _agencyRepo.fetch(widget.adminUid);
    if (mounted) {
      setState(() {
        _savedAgencies = agencies;
        _loadingAgencies = false;
        // No saved agencies yet → go straight to the "new agency" form.
        if (agencies.isEmpty) _agencySelection = _kNewAgency;
      });
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
      if (mounted && name.isNotEmpty) setState(() => _companyName = name);
    } catch (_) {
      // Header falls back to the static default.
    }
  }

  @override
  void dispose() {
    _agencyName.dispose();
    _agencyPhone.dispose();
    _agencyEmail.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _nationalityFreeText.dispose();
    super.dispose();
  }

  bool get _isNewAgency => _agencySelection == _kNewAgency;

  RecruitingAgency? get _pickedAgency {
    if (_agencySelection.isEmpty || _isNewAgency) return null;
    for (final a in _savedAgencies) {
      if (a.id == _agencySelection) return a;
    }
    return null;
  }

  String get _effectiveAgencyName =>
      _isNewAgency ? _agencyName.text.trim() : (_pickedAgency?.name ?? '');
  String get _effectiveAgencyPhone =>
      _isNewAgency ? _agencyPhone.text.trim() : (_pickedAgency?.phone ?? '');
  String get _effectiveAgencyEmail =>
      _isNewAgency ? _agencyEmail.text.trim() : (_pickedAgency?.email ?? '');

  // ── Validation ───────────────────────────────────────────────────
  String? _validateStep(int step) {
    switch (_stepIds[step]) {
      case 'agency':
        if (_agencySelection.isEmpty) {
          return _t('Bitte eine Agentur wählen oder neu anlegen.',
              'Please pick an agency or create a new one.');
        }
        if (_isNewAgency) {
          if (_agencyName.text.trim().isEmpty) {
            return _t('Agenturname fehlt.', 'Agency name missing.');
          }
          if (_agencyPhone.text.trim().isEmpty) {
            return _t('Telefonnummer der Agentur fehlt.',
                'Agency phone number missing.');
          }
          if (_agencyEmail.text.trim().isEmpty) {
            return _t('E-Mail der Agentur fehlt.', 'Agency email missing.');
          }
          if (!_agencyEmail.text.contains('@')) {
            return _t('E-Mail der Agentur ist ungültig.',
                'Agency email is invalid.');
          }
        }
        return null;
      case 'candidate':
        if (_firstName.text.trim().isEmpty) {
          return _t('Vorname des Kandidaten fehlt.',
              "Candidate's first name missing.");
        }
        if (_lastName.text.trim().isEmpty) {
          return _t('Nachname des Kandidaten fehlt.',
              "Candidate's last name missing.");
        }
        if (_birthDate == null) {
          return _t('Geburtsdatum fehlt.', 'Date of birth missing.');
        }
        if (_gender.isEmpty) {
          return _t('Bitte das Geschlecht auswählen.',
              'Please select the gender.');
        }
        if (_nationality.trim().isEmpty) {
          return _t('Herkunftsland fehlt.', 'Country of origin missing.');
        }
        return null;
      case 'docs':
        if (_passportFront == null) {
          return _t('Reisepass (Vorderseite) fehlt.',
              'Passport (front) missing.');
        }
        if (_passportBack == null) {
          return _t('Reisepass (Rückseite) fehlt.', 'Passport (back) missing.');
        }
        if (_licenseFront == null) {
          return _t('Führerschein (Vorderseite) fehlt.',
              "Driver's licence (front) missing.");
        }
        if (_licenseBack == null) {
          return _t('Führerschein (Rückseite) fehlt.',
              "Driver's licence (back) missing.");
        }
        if (_ezb == null) {
          return _t('EZB (PDF) fehlt.', 'EZB (PDF) missing.');
        }
        return null;
    }
    return null;
  }

  // ── Document picking ─────────────────────────────────────────────
  Future<void> _pick(String slot) async {
    final res = await _uploads.pickDocument(
      // EZB is an official declaration — PDF only.
      extensions: slot == 'ezb'
          ? const <String>['pdf']
          : RecruitingUploadService.allowedExtensions,
    );
    if (!mounted) return;
    if (res.error == PickDocumentError.compressionFailed) {
      setState(() => _error = _t(
          'Das Bild ist zu groß und konnte nicht komprimiert werden. '
              'Bitte eine kleinere Version wählen.',
          'Image too large and could not be compressed. Please pick a '
              'smaller version.'));
      return;
    }
    if (res.error == PickDocumentError.tooLarge) {
      final mb = res.megabytes ?? '';
      setState(() => _error = _t(
          'Datei zu groß ($mb MB). Maximal 10 MB pro Dokument.',
          'File too large ($mb MB). Max 10 MB per document.'));
      return;
    }
    final f = res.file;
    if (f == null) return;
    setState(() {
      _error = null;
      switch (slot) {
        case 'passport_front':
          _passportFront = f;
          break;
        case 'passport_back':
          _passportBack = f;
          break;
        case 'license_front':
          _licenseFront = f;
          break;
        case 'license_back':
          _licenseBack = f;
          break;
        case 'ezb':
          _ezb = f;
          break;
      }
    });
  }

  String _slotLabel(String slot) {
    switch (slot) {
      case 'passport_front':
        return _t('Reisepass Vorderseite', 'Passport front');
      case 'passport_back':
        return _t('Reisepass Rückseite', 'Passport back');
      case 'license_front':
        return _t('Führerschein Vorderseite', "Driver's licence front");
      case 'license_back':
        return _t('Führerschein Rückseite', "Driver's licence back");
      default:
        return _t('EZB (PDF)', 'EZB (PDF)');
    }
  }

  // ── Submit ───────────────────────────────────────────────────────
  Future<void> _submit() async {
    for (var i = 0; i < _totalSteps; i++) {
      final err = _validateStep(i);
      if (err != null) {
        setState(() {
          _error = err;
          _step = i;
        });
        return;
      }
    }
    setState(() {
      _submitting = true;
      _uploadProgress = _t('Wird vorbereitet…', 'Preparing…');
      _error = null;
    });
    try {
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.adminUid)
          .collection('recruiting_applications');
      final docRef = col.doc();
      final appId = docRef.id;

      // Sequential uploads — same reasoning as the driver form: iOS
      // Safari on cellular chokes on parallel Storage uploads.
      final slots = <(String, PickedRecruitingFile)>[
        ('passport_front', _passportFront!),
        ('passport_back', _passportBack!),
        ('license_front', _licenseFront!),
        ('license_back', _licenseBack!),
        ('ezb', _ezb!),
      ];
      final results = <RecruitingDocument>[];
      for (var i = 0; i < slots.length; i++) {
        final (slot, file) = slots[i];
        final n = '${i + 1}/${slots.length}';
        setState(() => _uploadProgress = _t(
            'Lädt $n: ${_slotLabel(slot)}…',
            'Uploading $n: ${_slotLabel(slot)}…'));
        try {
          results.add(
            await _uploads.uploadDocument(
              adminUid: widget.adminUid,
              appId: appId,
              label: slot,
              bytes: file.bytes,
              filename: file.filename,
              mimeType: file.mimeType,
            ),
          );
        } catch (e) {
          throw Exception(_t(
              'Upload „${_slotLabel(slot)}" fehlgeschlagen — $e',
              'Upload of "${_slotLabel(slot)}" failed — $e'));
        }
      }

      setState(() => _uploadProgress = _t('Wird gespeichert…', 'Saving…'));

      final agencyName = _effectiveAgencyName;
      final agencyPhone = _effectiveAgencyPhone;
      final agencyEmail = _effectiveAgencyEmail;

      final app = RecruitingApplication(
        id: appId,
        adminUid: widget.adminUid,
        // Visa channel on purpose — the rules only allow local|visa.
        channel: RecruitingChannel.visa,
        status: RecruitingStatus.newApp,
        submittedAt: DateTime.now(),
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        birthDate: _birthDate,
        // Same field the Visa form uses → the panel shows it as-is.
        nationality: _nationality.trim(),
        // Not collected by the agency form — the agency supplies only
        // identity + documents. Kept empty so the schema stays intact.
        birthPlace: '',
        street: '',
        postalCode: '',
        city: '',
        livingHereSince: null,
        shirtSize: '',
        shoeSize: '',
        truckLicense: '',
        // The agency is the only reachable contact — the rules require a
        // non-empty email, and this is the address the team must use.
        email: agencyEmail,
        phoneWhatsApp: agencyPhone,
        documents: results,
        customAnswers: <String, dynamic>{
          'viaAgency': true,
          'agencyName': agencyName,
          'agencyPhone': agencyPhone,
          'agencyEmail': agencyEmail,
          'candidateGender': _gender,
          'agencySubmittedInternally': widget.isInternal,
        },
      );
      await docRef.set(app.toCreatePayload());

      // Persist a newly entered agency for next time. Only possible when
      // an admin is signed in — `settings` is admin-write-only. Public
      // submissions get adopted by the panel (syncFromApplications).
      if (widget.isInternal && _isNewAgency && agencyEmail.isNotEmpty) {
        try {
          await _agencyRepo.upsert(
            adminUid: widget.adminUid,
            agency: RecruitingAgency(
              id: '',
              name: agencyName,
              phone: agencyPhone,
              email: agencyEmail,
              createdAt: DateTime.now(),
            ),
          );
        } catch (_) {
          // Directory is a convenience — never fail the submission.
        }
      }

      if (!mounted) return;
      setState(() => _submitted = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error =
          _t('Senden fehlgeschlagen: $e', 'Submit failed: $e'));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _uploadProgress = '';
        });
      }
    }
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);
    if (widget.isInternal) return body;
    return Title(
      title: _companyName.isEmpty
          ? 'Agentur-Formular'
          : 'Agentur-Formular · $_companyName',
      color: const Color(0xFF006047),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F7),
        body: body,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.adminUid.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _t(
              'Ungültiger Link.\n\nBitte fragen Sie Ihren Ansprechpartner '
                  'nach der korrekten Adresse.',
              'Invalid link.\n\nPlease ask your contact for the correct URL.',
            ),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ),
      );
    }
    if (_submitted) return _buildSuccess();
    if (_loadingAgencies) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
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
                _StepBar(current: _step, total: _totalSteps),
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
                _buildNav(),
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
            Icons.apartment_rounded,
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
                _companyName.isEmpty
                    ? 'ARION LOGISTICS'
                    : _companyName.toUpperCase(),
                style: AppTypography.caption2.copyWith(
                  color: AppColors.codriverDeep,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                _t('Agentur-Formular · Arbeitsvisum',
                    'Agency form · Working visa'),
                style: AppTypography.title3.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _LangToggle(
          lang: _lang,
          onChanged: (v) => setState(() => _lang = v),
        ),
      ],
    );
  }

  Widget _buildStep() {
    switch (_stepIds[_step]) {
      case 'agency':
        return _buildAgencyStep();
      case 'candidate':
        return _buildCandidateStep();
      default:
        return _buildDocsStep();
    }
  }

  Widget _buildAgencyStep() {
    return ListView(
      children: [
        _Section(_t('Personalagentur', 'Staffing agency')),
        Text(
          _t(
            'Bitte wählen Sie Ihre Agentur aus oder legen Sie sie neu an. '
                'Wir kontaktieren ausschließlich die Agentur.',
            'Please pick your agency or create a new one. We will contact '
                'the agency only.',
          ),
          style: AppTypography.caption1.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        if (_savedAgencies.isNotEmpty) ...[
          _Labeled(
            label: _t('Agentur wählen', 'Choose agency'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final a in _savedAgencies)
                  _Choice(
                    label: a.pickerLabel,
                    selected: _agencySelection == a.id,
                    onTap: () => setState(() => _agencySelection = a.id),
                  ),
                _Choice(
                  label: _t('＋ Neue Agentur anlegen', '＋ Add new agency'),
                  selected: _isNewAgency,
                  onTap: () => setState(() => _agencySelection = _kNewAgency),
                ),
              ],
            ),
          ),
        ],
        if (_isNewAgency) ...[
          const SizedBox(height: 4),
          _Section(_t('Neue Agentur', 'New agency')),
          _Labeled(
            label: _t('Agenturname', 'Agency name'),
            child: TextField(
              controller: _agencyName,
              textCapitalization: TextCapitalization.words,
              decoration: _input(_t('z. B. Balkan Staffing GmbH',
                  'e.g. Balkan Staffing GmbH')),
            ),
          ),
          _Labeled(
            label: _t('Telefonnummer', 'Phone number'),
            child: TextField(
              controller: _agencyPhone,
              keyboardType: TextInputType.phone,
              decoration: _input('z. B. +383 44 123456'),
            ),
          ),
          _Labeled(
            label: _t('E-Mail', 'Email'),
            child: TextField(
              controller: _agencyEmail,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: _input('z. B. kontakt@agentur.com'),
            ),
          ),
        ] else if (_pickedAgency != null) ...[
          const SizedBox(height: 4),
          _AgencySummary(
            agency: _pickedAgency!,
            phoneLabel: _t('Telefon', 'Phone'),
            emailLabel: _t('E-Mail', 'Email'),
          ),
        ],
      ],
    );
  }

  Widget _buildCandidateStep() {
    return ListView(
      children: [
        _Section(_t('Kandidat/in', 'Candidate')),
        _Labeled(
          label: _t('Vorname', 'First name'),
          child: TextField(
            controller: _firstName,
            textCapitalization: TextCapitalization.words,
            decoration: _input(_t('z. B. Andi', 'e.g. Andi')),
          ),
        ),
        _Labeled(
          label: _t('Nachname', 'Last name'),
          child: TextField(
            controller: _lastName,
            textCapitalization: TextCapitalization.words,
            decoration: _input(_t('z. B. Krasniqi', 'e.g. Krasniqi')),
          ),
        ),
        _Labeled(
          label: _t('Geburtsdatum', 'Date of birth'),
          child: _DateField(
            value: _birthDate,
            placeholder: _t('Datum auswählen', 'Choose a date'),
            onPick: (d) => setState(() => _birthDate = d),
          ),
        ),
        _Labeled(
          label: _t('Geschlecht', 'Gender'),
          child: Row(
            children: [
              Expanded(
                child: _Choice(
                  label: _t('Männlich', 'Male'),
                  selected: _gender == 'm',
                  compact: true,
                  onTap: () => setState(() => _gender = 'm'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Choice(
                  label: _t('Weiblich', 'Female'),
                  selected: _gender == 'f',
                  compact: true,
                  onTap: () => setState(() => _gender = 'f'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Choice(
                  label: _t('Divers', 'Diverse'),
                  selected: _gender == 'd',
                  compact: true,
                  onTap: () => setState(() => _gender = 'd'),
                ),
              ),
            ],
          ),
        ),
        _Labeled(
          label: _t('Herkunftsland', 'Country of origin'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue:
                    _nationalitySelect.isEmpty ? null : _nationalitySelect,
                decoration: _input(''),
                items: [
                  for (final n in _nationalities)
                    DropdownMenuItem(value: n, child: Text(n)),
                  DropdownMenuItem(
                    value: _kNationalityOther,
                    child: Text(_t('Andere…', 'Other…')),
                  ),
                ],
                onChanged: (v) => setState(() {
                  _nationalitySelect = v ?? '';
                  _nationality = v == _kNationalityOther
                      ? _nationalityFreeText.text.trim()
                      : (v ?? '');
                }),
              ),
              if (_nationalitySelect == _kNationalityOther) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _nationalityFreeText,
                  textCapitalization: TextCapitalization.words,
                  decoration: _input(
                    _t('Herkunftsland eingeben', 'Enter country of origin'),
                  ),
                  onChanged: (v) => setState(() => _nationality = v.trim()),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocsStep() {
    return ListView(
      children: [
        _Section(_t('Dokumente', 'Documents')),
        Text(
          _t(
            'Bitte gut sichtbar, vollständig und nicht abgeschnitten. '
                'Max. 10 MB pro Dokument.',
            'Clear, complete, nothing cut off. Max 10 MB per document.',
          ),
          style: AppTypography.caption1.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        _Upload(
          title: _t('Reisepass (Vorderseite)', 'Passport (front)'),
          subtitle: _t('Seite mit Lichtbild', 'Page with the photo'),
          icon: Icons.badge_outlined,
          file: _passportFront,
          onPick: () => _pick('passport_front'),
        ),
        const SizedBox(height: 10),
        _Upload(
          title: _t('Reisepass (Rückseite)', 'Passport (back)'),
          subtitle: _t('Rückseite / zweite Seite', 'Back / second page'),
          icon: Icons.badge_outlined,
          file: _passportBack,
          onPick: () => _pick('passport_back'),
        ),
        const SizedBox(height: 10),
        _Upload(
          title: _t('Führerschein (Vorderseite)', "Driver's licence (front)"),
          subtitle: _t('Vorderseite', 'Front side'),
          icon: Icons.credit_card_rounded,
          file: _licenseFront,
          onPick: () => _pick('license_front'),
        ),
        const SizedBox(height: 10),
        _Upload(
          title: _t('Führerschein (Rückseite)', "Driver's licence (back)"),
          subtitle: _t('Rückseite', 'Back side'),
          icon: Icons.credit_card_outlined,
          file: _licenseBack,
          onPick: () => _pick('license_back'),
        ),
        const SizedBox(height: 10),
        _Upload(
          title: _t('EZB (PDF)', 'EZB (PDF)'),
          subtitle: _t(
            'Erklärung zum Beschäftigungsverhältnis — nur PDF',
            'Declaration of employment (EZB) — PDF only',
          ),
          icon: Icons.picture_as_pdf_outlined,
          file: _ezb,
          onPick: () => _pick('ezb'),
        ),
      ],
    );
  }

  Widget _buildNav() {
    final isLast = _step == _totalSteps - 1;
    return Row(
      children: [
        if (_step > 0)
          CoButton(
            onPressed: _submitting ? null : () => setState(() => _step -= 1),
            label: _t('Zurück', 'Back'),
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
          label: isLast ? _t('Senden', 'Submit') : _t('Weiter', 'Next'),
          icon: isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
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
              decoration: const BoxDecoration(
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
              _t('Danke!', 'Thank you!'),
              style: AppTypography.title2.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                'Die Kandidaten-Daten wurden übermittelt. Wir melden uns '
                    'bei der angegebenen Agentur.',
                'The candidate data has been submitted. We will get back to '
                    'the agency you provided.',
              ),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            if (widget.isInternal) ...[
              const SizedBox(height: 18),
              CoButton(
                onPressed: () => Navigator.of(context).maybePop(),
                label: _t('Schließen', 'Close'),
                variant: CoButtonVariant.secondaryOutlined,
              ),
            ],
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
//   Helper widgets (mirrors the driver form's visual language)
// ──────────────────────────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.lang, required this.onChanged});
  final String lang;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget pill(String code, String label) {
      final active = lang == code;
      return CoPressable(
        onTap: () => onChanged(code),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.codriverGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: active ? Colors.white : const Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [pill('de', 'DE'), pill('en', 'EN')],
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current, required this.total});
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

class _Section extends StatelessWidget {
  const _Section(this.text);
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

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});
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

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 14,
            vertical: 12,
          ),
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
            mainAxisAlignment: compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.codriverGreen
                    : const Color(0xFF9CA3AF),
                size: compact ? 18 : 22,
              ),
              SizedBox(width: compact ? 6 : 10),
              Flexible(
                child: Text(
                  label,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: (compact
                          ? AppTypography.caption1
                          : AppTypography.body)
                      .copyWith(
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

/// Read-only recap of the agency the user picked from the directory.
class _AgencySummary extends StatelessWidget {
  const _AgencySummary({
    required this.agency,
    required this.phoneLabel,
    required this.emailLabel,
  });

  final RecruitingAgency agency;
  final String phoneLabel;
  final String emailLabel;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.codriverDeep),
              const SizedBox(width: 8),
              Text(
                '$label: ',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.codriverDeep.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.codriverGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agency.name,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
          row(Icons.phone_rounded, phoneLabel, agency.phone),
          row(Icons.mail_outline_rounded, emailLabel, agency.email),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.onPick,
    required this.placeholder,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onPick;
  final String placeholder;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(1940),
          lastDate: DateTime.now(),
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
              value == null ? placeholder : _fmt(value!),
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

class _Upload extends StatelessWidget {
  const _Upload({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.onPick,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final PickedRecruitingFile? file;
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
                color:
                    has ? AppColors.codriverGreen : const Color(0xFFF3F4F6),
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
                          ? AppColors.codriverDeep.withValues(alpha: 0.75)
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
              color:
                  has ? AppColors.codriverDeep : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
