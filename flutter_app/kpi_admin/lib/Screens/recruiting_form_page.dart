// lib/Screens/recruiting_form_page.dart
//
// Public, login-less recruiting form. Mirrors the ARION LOGISTICS
// Google Form 1:1 (questions in Albanian + German), plus the
// passport / ID + driver-license-front/back uploads at the end so
// the admin team has everything needed to file the work-visa
// (Arbeitsvisum) request.
//
// Routed by main.dart from `/apply?dsp=<adminUid>&type=local|visa`.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/recruiting_application.dart';
import '../models/recruiting_form_config.dart';
import '../services/recruiting_repository.dart';
import '../services/recruiting_upload_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';

class RecruitingFormPage extends StatefulWidget {
  const RecruitingFormPage({
    super.key,
    required this.adminUid,
    required this.channel,
    this.initialLang = '',
  });

  /// Target admin / DSP namespace. The form refuses to render if this
  /// is empty — the link is malformed.
  final String adminUid;
  final RecruitingChannel channel;

  /// Optional per URL (`?lang=bg` …) vorgewählte Sprache des
  /// Local-Formulars — überspringt die Sprachauswahl-Seite.
  final String initialLang;

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
  /// Only relevant when [_employmentInterest] == 'parttime'.
  /// Which specific weekdays the applicant is available to work.
  /// Canonical codes: mon, tue, wed, thu, fri, sat, sun.
  final Set<String> _parttimeWeekdays = <String>{};

  /// Weekday codes in calendar order with short German labels.
  static const List<List<String>> _kWeekdayOptions = <List<String>>[
    <String>['mon', 'Mo'],
    <String>['tue', 'Di'],
    <String>['wed', 'Mi'],
    <String>['thu', 'Do'],
    <String>['fri', 'Fr'],
    <String>['sat', 'Sa'],
    <String>['sun', 'So'],
  ];

  /// Selected weekday codes returned in calendar order (mon → sun).
  List<String> _orderedParttimeWeekdays() => _kWeekdayOptions
      .map((e) => e[0])
      .where(_parttimeWeekdays.contains)
      .toList();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  DateTime? _birthDate;
  final _birthPlace = TextEditingController();
  final _birthCountry = TextEditingController();
  String _nationality = '';
  // Holds the dropdown's currently selected item for the visa channel. May be
  // one of `_nationalities` or the `_kNationalityOther` sentinel; the actual
  // value lives in `_nationality` (free text when "Other" is chosen).
  String _nationalitySelect = '';
  final _nationalityFreeText = TextEditingController();
  static const _kNationalityOther = '__other__';
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

  /// Local/EU only — does the applicant also need accommodation?
  /// Stored under `customAnswers.needsAccommodation` (bool).
  bool? _needsAccommodation;

  /// Local/EU only — does the applicant have their own vehicle to get to
  /// work? Stored under `customAnswers.ownVehicleForCommute` (bool).
  bool? _ownVehicleForCommute;

  // ── Step 3: sizing + contact ──
  final _shirtSize = TextEditingController();
  final _shoeSize = TextEditingController();
  final _phone = TextEditingController();

  /// Selected phone country dial code. Applicants (esp. West-Balkan visa
  /// candidates) pick their prefix instead of typing it.
  String _dialCode = '+49';

  static const List<(String, String)> _kDialCodes = [
    ('🇩🇪', '+49'),
    ('🇽🇰', '+383'),
    ('🇦🇱', '+355'),
    ('🇲🇰', '+389'),
    ('🇷🇸', '+381'),
    ('🇲🇪', '+382'),
    ('🇧🇦', '+387'),
    ('🇭🇷', '+385'),
    ('🇸🇮', '+386'),
    ('🇦🇹', '+43'),
    ('🇨🇭', '+41'),
    ('🇷🇴', '+40'),
    ('🇧🇬', '+359'),
    ('🇭🇺', '+36'),
    ('🇵🇱', '+48'),
    ('🇹🇷', '+90'),
    ('🇺🇦', '+380'),
    ('🇮🇹', '+39'),
    ('🇫🇷', '+33'),
    ('🇬🇷', '+30'),
  ];

  /// Phone number with the selected dial code applied. Numbers that already
  /// carry a prefix (+... or 00...) are kept untouched.
  String _fullPhone() {
    var raw = _phone.text.trim();
    if (raw.isEmpty) return raw;
    if (raw.startsWith('+') || raw.startsWith('00')) return raw;
    // Local format "0170..." → drop the leading zero before prefixing.
    if (raw.startsWith('0')) raw = raw.substring(1);
    return '$_dialCode $raw';
  }
  final _email = TextEditingController();

  // ── Bank details (both channels) ──
  // IBAN wird in beiden Flows abgefragt; „Ich habe noch keine IBAN"
  // erlaubt das Nachreichen (gleiches Muster wie Steuer-ID).
  final _iban = TextEditingController();
  bool _noIbanYet = false;

  String _cleanedIban() =>
      _iban.text.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  static final _ibanPattern = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{10,30}$');

  // ── Step 4: truck license (Visa channel only) ──
  /// Two-step replacement: category first (none / C / CE), then —
  /// only if C or CE — the Code 95 follow-up.
  String _truckLicenseCategory = ''; // '', 'none', 'C', 'CE'
  bool? _hasCode95;
  // Prior experience as a parcel driver for an Amazon partner company.
  bool? _amazonPartnerExperience;

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

  /// Local/EU only — earliest possible start date (mandatory).
  /// Stored under `customAnswers.earliestStart` as `yyyy-MM-dd`.
  DateTime? _earliestStart;

  /// Local/EU only — optional referral ("Wer hat Sie geworben?").
  /// Stored under `customAnswers.referredBy` only when filled in.
  final _referredBy = TextEditingController();

  bool get _isLocal => widget.channel == RecruitingChannel.local;

  // Local/EU-Formular: gewählte Sprache (null = noch nicht gewählt →
  // Sprachauswahl zuerst, gleiches Muster wie im Visa-Kanal). Danach wird
  // das Formular einsprachig angezeigt.
  // 'de' | 'en' | 'bg' | 'hu' | 'ro' | 'pt' | 'sq'.
  String? _localLang;

  /// Local/EU-Texthelfer: gibt den Text in der gewählten Sprache zurück
  /// (Default Deutsch, solange nichts gewählt wurde).
  String _lt({
    required String de,
    required String en,
    required String bg,
    required String hu,
    required String ro,
    String? pt,
    String? sq,
  }) {
    switch (_localLang) {
      case 'en':
        return en;
      case 'bg':
        return bg;
      case 'hu':
        return hu;
      case 'ro':
        return ro;
      case 'pt':
        // Portugiesisch fällt auf Englisch zurück, falls (noch) nicht
        // übersetzt — so bleibt das Formular immer vollständig.
        return pt ?? en;
      case 'sq':
        // Albanisch fällt auf Englisch zurück, falls (noch) nicht
        // übersetzt — so bleibt das Formular immer vollständig.
        return sq ?? en;
      default:
        return de;
    }
  }

  /// Human-readable document name used in the upload-progress line and in
  /// upload-failure messages. Visa keeps the historical German labels.
  String _docSlotLabel(String slot) {
    if (!_isLocal) {
      return const <String, String>{
        'passport': 'Pass / Personalausweis Vorderseite',
        'id_back': 'Personalausweis Rückseite',
        'selfie': 'Selfie für Driver-Badge',
        'license_front': 'Führerschein Vorderseite',
        'license_back': 'Führerschein Rückseite',
      }[slot]!;
    }
    switch (slot) {
      case 'passport':
        return _lt(
          de: 'Pass / Personalausweis Vorderseite',
          en: 'Passport / ID card front',
          bg: 'Паспорт / лична карта, лицева страна',
          hu: 'Útlevél / személyi igazolvány előlap',
          ro: 'Pașaport / carte de identitate, față',
          pt: 'Passaporte / cartão de identidade, frente',
          sq: 'Pasaporta / letërnjoftimi, faqja e përparme',
        );
      case 'id_back':
        return _lt(
          de: 'Personalausweis Rückseite',
          en: 'ID card back',
          bg: 'Лична карта, гръб',
          hu: 'Személyi igazolvány hátlap',
          ro: 'Carte de identitate, verso',
          pt: 'Cartão de identidade, verso',
          sq: 'Letërnjoftimi, faqja e pasme',
        );
      case 'selfie':
        return _lt(
          de: 'Selfie für Driver-Badge',
          en: 'Selfie for the driver badge',
          bg: 'Селфи за баджа на шофьора',
          hu: 'Szelfi a sofőrkártyához',
          ro: 'Selfie pentru ecusonul de șofer',
          pt: 'Selfie para o crachá de motorista',
          sq: 'Selfie për distinktivin e shoferit',
        );
      case 'license_front':
        return _lt(
          de: 'Führerschein Vorderseite',
          en: "Driver's licence front",
          bg: 'Шофьорска книжка, лицева страна',
          hu: 'Jogosítvány előlap',
          ro: 'Permis de conducere, față',
          pt: 'Carta de condução, frente',
          sq: 'Patenta e shoferit, faqja e përparme',
        );
      default:
        return _lt(
          de: 'Führerschein Rückseite',
          en: "Driver's licence back",
          bg: 'Шофьорска книжка, гръб',
          hu: 'Jogosítvány hátlap',
          ro: 'Permis de conducere, verso',
          pt: 'Carta de condução, verso',
          sq: 'Patenta e shoferit, faqja e pasme',
        );
    }
  }

  /// Today at midnight — used as the lower bound of the "earliest start"
  /// picker so a picked today never falls before `firstDate`.
  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Placeholder for empty date pickers in the Local/EU flow.
  String _pickDateLabel() => _lt(
        de: 'Datum auswählen',
        en: 'Choose a date',
        bg: 'Изберете дата',
        hu: 'Válasszon dátumot',
        ro: 'Alegeți o dată',
        pt: 'Escolhe uma data',
        sq: 'Zgjidh një datë',
      );

  String _pickSizeLabel() => _lt(
        de: 'Größe wählen',
        en: 'Choose size',
        bg: 'Изберете размер',
        hu: 'Válasszon méretet',
        ro: 'Alegeți mărimea',
        pt: 'Escolhe o tamanho',
        sq: 'Zgjidh madhësinë',
      );

  String _submitLaterLabel() => _lt(
        de: 'Reiche ich später nach',
        en: "I'll submit later",
        bg: 'Ще предоставя по-късно',
        hu: 'Később pótolom',
        ro: 'Voi trimite mai târziu',
        pt: 'Envio mais tarde',
        sq: 'Do ta dorëzoj më vonë',
      );

  String _cancelLabel() => _lt(
        de: 'Abbrechen',
        en: 'Cancel',
        bg: 'Отказ',
        hu: 'Mégse',
        ro: 'Anulare',
        pt: 'Cancelar',
        sq: 'Anulo',
      );

  String _doneLabel() => _lt(
        de: 'Fertig',
        en: 'Done',
        bg: 'Готово',
        hu: 'Kész',
        ro: 'Gata',
        pt: 'Concluído',
        sq: 'Gati',
      );

  /// Short weekday label in the selected local language. The Visa channel
  /// keeps the static German labels from [_kWeekdayOptions].
  String _localWeekdayLabel(String code) {
    const labels = <String, List<String>>{
      // de, en, bg, hu, ro, pt, sq
      'mon': ['Mo', 'Mon', 'Пн', 'H', 'Lu', 'Seg', 'Hën'],
      'tue': ['Di', 'Tue', 'Вт', 'K', 'Ma', 'Ter', 'Mar'],
      'wed': ['Mi', 'Wed', 'Ср', 'Sze', 'Mi', 'Qua', 'Mër'],
      'thu': ['Do', 'Thu', 'Чт', 'Cs', 'Jo', 'Qui', 'Enj'],
      'fri': ['Fr', 'Fri', 'Пт', 'P', 'Vi', 'Sex', 'Pre'],
      'sat': ['Sa', 'Sat', 'Сб', 'Szo', 'Sâ', 'Sáb', 'Sht'],
      'sun': ['So', 'Sun', 'Нд', 'V', 'Du', 'Dom', 'Die'],
    };
    final row = labels[code];
    if (row == null) return code;
    switch (_localLang) {
      case 'en':
        return row[1];
      case 'bg':
        return row[2];
      case 'hu':
        return row[3];
      case 'ro':
        return row[4];
      case 'pt':
        return row[5];
      case 'sq':
        return row[6];
      default:
        return row[0];
    }
  }

  // Visa-Formular: gewählte Sprache (null = noch nicht gewählt → Auswahl
  // zuerst). 'sq' = Albanisch, 'de' = Deutsch. Danach wird nur diese
  // Sprache angezeigt (statt beide gleichzeitig).
  String? _visaLang;

  /// Visa-Kanal: Ersterteilung oder Arbeitgeberwechsel? Wird direkt
  /// nach der Sprachauswahl abgefragt (Ticket) und landet in den
  /// Bewerbungs-Ergebnissen. 'first_issue' | 'employer_change'.
  String? _visaPermitType;

  /// Visa-Texthelfer: gibt je nach gewählter Sprache den albanischen oder
  /// deutschen Text zurück (Default Albanisch).
  String _vt(String sq, String de) => _visaLang == 'de' ? de : sq;

  @override
  void initState() {
    super.initState();
    // Per Link vorgewählte Sprache (z. B. bulgarische Landingpage →
    // ?lang=bg): Sprachauswahl überspringen, Formular direkt einsprachig.
    const supported = {'de', 'en', 'bg', 'hu', 'ro', 'pt', 'sq'};
    if (supported.contains(widget.initialLang)) {
      _localLang = widget.initialLang;
    }
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
    _iban.dispose();
    _taxId.dispose();
    _socialSecurityNo.dispose();
    _childrenCount.dispose();
    _healthInsurance.dispose();
    _notes.dispose();
    _referredBy.dispose();
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
          return _isLocal
              ? _lt(
                  de: 'Bitte „${f.label}" beantworten.',
                  en: 'Please answer "${f.label}".',
                  bg: 'Моля, отговорете на „${f.label}".',
                  hu: 'Kérjük, válaszoljon a(z) „${f.label}" kérdésre.',
                  ro: 'Vă rugăm să răspundeți la „${f.label}".',
                  pt: 'Por favor, responde a "${f.label}".',
                  sq: 'Të lutem përgjigju "${f.label}".',
                )
              : 'Bitte „${f.label}" beantworten.';
        }
      }
      return null;
    }
    if (id == 'finance') {
      if (!_noIbanYet && _cleanedIban().isEmpty) {
        return _lt(
          de: 'IBAN fehlt.',
          en: 'IBAN missing.',
          bg: 'Липсва IBAN.',
          hu: 'Hiányzik az IBAN.',
          ro: 'Lipsește IBAN-ul.',
          pt: 'Falta o IBAN.',
          sq: 'IBAN-i mungon.',
        );
      }
      if (!_noIbanYet && !_ibanPattern.hasMatch(_cleanedIban())) {
        return _lt(
          de: 'IBAN scheint ungültig zu sein.',
          en: 'IBAN looks invalid.',
          bg: 'IBAN изглежда невалиден.',
          hu: 'Az IBAN érvénytelennek tűnik.',
          ro: 'IBAN-ul pare invalid.',
          pt: 'O IBAN parece inválido.',
          sq: 'IBAN-i duket i pavlefshëm.',
        );
      }
      if (!_taxIdLater && _taxId.text.trim().isEmpty) {
        return _lt(
          de: 'Steueridentifikationsnummer fehlt.',
          en: 'Tax identification number missing.',
          bg: 'Липсва данъчен идентификационен номер.',
          hu: 'Hiányzik az adóazonosító szám.',
          ro: 'Lipsește numărul de identificare fiscală.',
          pt: 'Falta o número de identificação fiscal.',
          sq: 'Numri i identifikimit tatimor mungon.',
        );
      }
      if (!_socialSecurityLater &&
          _socialSecurityNo.text.trim().isEmpty) {
        return _lt(
          de: 'Sozialversicherungsnummer fehlt.',
          en: 'Social security number missing.',
          bg: 'Липсва номер на социална осигуровка.',
          hu: 'Hiányzik a társadalombiztosítási szám.',
          ro: 'Lipsește numărul de asigurare socială.',
          pt: 'Falta o número de segurança social.',
          sq: 'Numri i sigurimeve shoqërore mungon.',
        );
      }
      if (_healthInsuranceChoice.isEmpty) {
        return _lt(
          de: 'Angabe zur Krankenkasse fehlt.',
          en: 'Health insurance information missing.',
          bg: 'Липсва информация за здравната каса.',
          hu: 'Hiányzik az egészségbiztosításra vonatkozó adat.',
          ro: 'Lipsesc informațiile despre asigurarea de sănătate.',
          pt: 'Falta a informação sobre o seguro de saúde.',
          sq: 'Informacioni për sigurimin shëndetësor mungon.',
        );
      }
      if (_healthInsuranceChoice == 'has' &&
          _healthInsurance.text.trim().isEmpty) {
        return _lt(
          de: 'Name der Krankenkasse fehlt.',
          en: 'Name of the health insurance fund missing.',
          bg: 'Липсва името на здравната каса.',
          hu: 'Hiányzik az egészségbiztosító neve.',
          ro: 'Lipsește numele casei de asigurări de sănătate.',
          pt: 'Falta o nome do seguro de saúde.',
          sq: 'Emri i sigurimit shëndetësor mungon.',
        );
      }
      if (_healthInsuranceChoice == 'none' && _aokBayernRegister.isEmpty) {
        return _lt(
          de: 'Bitte die Frage zur Krankenkassen-Anmeldung beantworten.',
          en: 'Please answer the health insurance registration question.',
          bg: 'Моля, отговорете на въпроса за регистрация в здравна каса.',
          hu: 'Kérjük, válaszoljon az egészségbiztosítási '
              'bejelentkezésre vonatkozó kérdésre.',
          ro: 'Vă rugăm să răspundeți la întrebarea despre înscrierea '
              'la casa de asigurări de sănătate.',
          pt: 'Por favor, responde à pergunta sobre a inscrição no seguro de '
              'saúde.',
          sq: 'Të lutem përgjigju pyetjes për regjistrimin në sigurimin '
              'shëndetësor.',
        );
      }
      if (_maritalStatus.isEmpty) {
        return _lt(
          de: 'Familienstand fehlt.',
          en: 'Marital status missing.',
          bg: 'Липсва семейно положение.',
          hu: 'Hiányzik a családi állapot.',
          ro: 'Lipsește starea civilă.',
          pt: 'Falta o estado civil.',
          sq: 'Gjendja civile mungon.',
        );
      }
      if (_childrenChoice.isEmpty) {
        return _lt(
          de: 'Angabe zu Kindern fehlt.',
          en: 'Information about children missing.',
          bg: 'Липсва информация за деца.',
          hu: 'Hiányzik a gyermekekre vonatkozó adat.',
          ro: 'Lipsesc informațiile despre copii.',
          pt: 'Falta a informação sobre filhos.',
          sq: 'Informacioni për fëmijët mungon.',
        );
      }
      if (_childrenChoice == 'count' &&
          _childrenCount.text.trim().isEmpty) {
        return _lt(
          de: 'Anzahl der Kinder fehlt.',
          en: 'Number of children missing.',
          bg: 'Липсва броят на децата.',
          hu: 'Hiányzik a gyermekek száma.',
          ro: 'Lipsește numărul de copii.',
          pt: 'Falta o número de filhos.',
          sq: 'Numri i fëmijëve mungon.',
        );
      }
      if (_earliestStart == null) {
        return _lt(
          de: 'Bitte ein mögliches Startdatum auswählen.',
          en: 'Please choose a possible start date.',
          bg: 'Моля, изберете възможна начална дата.',
          hu: 'Kérjük, válasszon egy lehetséges kezdési dátumot.',
          ro: 'Vă rugăm să alegeți o dată de început posibilă.',
          pt: 'Por favor, escolhe uma possível data de início.',
          sq: 'Të lutem zgjidh një datë të mundshme fillimi.',
        );
      }
      return null;
    }
    if (id == 'identity') {
      if (_employmentInterest.isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Bitte einen Beschäftigungs-Wunsch auswählen.',
                en: 'Please pick an employment type.',
                bg: 'Моля, изберете вид заетост.',
                hu: 'Kérjük, válasszon foglalkoztatási formát.',
                ro: 'Vă rugăm să alegeți tipul de angajare.',
                pt: 'Por favor, escolhe o tipo de emprego.',
                sq: 'Të lutem zgjidh llojin e punësimit.',
              )
            : _vt('Ju lutemi zgjidhni llojin e punës.',
                'Bitte Beschäftigungs-Wunsch auswählen.');
      }
      if (_employmentInterest == 'parttime' && _parttimeDays.isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Bitte 2, 3 oder 4 Tage pro Woche auswählen.',
                en: 'Please pick 2, 3 or 4 days per week.',
                bg: 'Моля, изберете 2, 3 или 4 дни седмично.',
                hu: 'Kérjük, válasszon heti 2, 3 vagy 4 napot.',
                ro: 'Vă rugăm să alegeți 2, 3 sau 4 zile pe săptămână.',
                pt: 'Por favor, escolhe 2, 3 ou 4 dias por semana.',
                sq: 'Të lutem zgjidh 2, 3 ose 4 ditë në javë.',
              )
            : _vt('Ju lutemi zgjidhni 2, 3 ose 4 ditë në javë.',
                'Bitte 2, 3 oder 4 Tage pro Woche auswählen.');
      }
      if (_employmentInterest == 'parttime' && _parttimeWeekdays.isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Bitte die verfügbaren Wochentage auswählen.',
                en: 'Please pick the weekdays you are available.',
                bg: 'Моля, изберете дните, в които сте на разположение.',
                hu: 'Kérjük, jelölje meg, mely napokon elérhető.',
                ro: 'Vă rugăm să alegeți zilele în care sunteți disponibil.',
                pt: 'Por favor, escolhe os dias em que estás disponível.',
                sq: 'Të lutem zgjidh ditët kur je i disponueshëm.',
              )
            : _vt('Ju lutemi zgjidhni ditët kur jeni i disponueshëm.',
                'Bitte die verfügbaren Wochentage auswählen.');
      }
      if (_firstName.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Vorname fehlt.',
                en: 'First name missing.',
                bg: 'Липсва име.',
                hu: 'Hiányzik a keresztnév.',
                ro: 'Lipsește prenumele.',
                pt: 'Falta o nome próprio.',
                sq: 'Emri mungon.',
              )
            : _vt('Emri mungon.', 'Vorname fehlt.');
      }
      if (_lastName.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Nachname fehlt.',
                en: 'Last name missing.',
                bg: 'Липсва фамилия.',
                hu: 'Hiányzik a vezetéknév.',
                ro: 'Lipsește numele de familie.',
                pt: 'Falta o apelido.',
                sq: 'Mbiemri mungon.',
              )
            : _vt('Mbiemri mungon.', 'Nachname fehlt.');
      }
      if (_birthDate == null) {
        return _isLocal
            ? _lt(
                de: 'Geburtsdatum fehlt.',
                en: 'Date of birth missing.',
                bg: 'Липсва дата на раждане.',
                hu: 'Hiányzik a születési dátum.',
                ro: 'Lipsește data nașterii.',
                pt: 'Falta a data de nascimento.',
                sq: 'Data e lindjes mungon.',
              )
            : _vt('Data e lindjes mungon.', 'Geburtsdatum fehlt.');
      }
      if (_birthPlace.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Geburtsort fehlt.',
                en: 'Place of birth missing.',
                bg: 'Липсва място на раждане.',
                hu: 'Hiányzik a születési hely.',
                ro: 'Lipsește locul nașterii.',
                pt: 'Falta o local de nascimento.',
                sq: 'Vendlindja mungon.',
              )
            : _vt('Vendlindja mungon.', 'Geburtsort fehlt.');
      }
      if (_birthCountry.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Geburtsland fehlt.',
                en: 'Country of birth missing.',
                bg: 'Липсва държава на раждане.',
                hu: 'Hiányzik a születési ország.',
                ro: 'Lipsește țara nașterii.',
                pt: 'Falta o país de nascimento.',
                sq: 'Shteti i lindjes mungon.',
              )
            : _vt('Shteti i lindjes mungon.', 'Geburtsland fehlt.');
      }
      if (_nationality.isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Nationalität fehlt.',
                en: 'Nationality missing.',
                bg: 'Липсва гражданство.',
                hu: 'Hiányzik az állampolgárság.',
                ro: 'Lipsește cetățenia.',
                pt: 'Falta a nacionalidade.',
                sq: 'Shtetësia mungon.',
              )
            : _vt('Shtetësia mungon.', 'Nationalität fehlt.');
      }
      return null;
    }
    if (id == 'address') {
      if (_street.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Adresse fehlt.',
                en: 'Address missing.',
                bg: 'Липсва адрес.',
                hu: 'Hiányzik a cím.',
                ro: 'Lipsește adresa.',
                pt: 'Falta a morada.',
                sq: 'Adresa mungon.',
              )
            : _vt('Rruga mungon.', 'Adresse fehlt.');
      }
      if (_postalCode.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Postleitzahl fehlt.',
                en: 'Postal code missing.',
                bg: 'Липсва пощенски код.',
                hu: 'Hiányzik az irányítószám.',
                ro: 'Lipsește codul poștal.',
                pt: 'Falta o código postal.',
                sq: 'Kodi postar mungon.',
              )
            : _vt('Kodi postar mungon.', 'PLZ fehlt.');
      }
      if (_city.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Stadt fehlt.',
                en: 'City missing.',
                bg: 'Липсва град.',
                hu: 'Hiányzik a város.',
                ro: 'Lipsește orașul.',
                pt: 'Falta a cidade.',
                sq: 'Qyteti mungon.',
              )
            : _vt('Qyteti mungon.', 'Stadt fehlt.');
      }
      // Unterkunft ist eine Pflicht-Angabe im Local/EU-Kanal.
      if (_isLocal && _needsAccommodation == null) {
        return _lt(
          de: 'Bitte die Frage zur Unterkunft beantworten.',
          en: 'Please answer the accommodation question.',
          bg: 'Моля, отговорете на въпроса за настаняването.',
          hu: 'Kérjük, válaszoljon a szállásra vonatkozó kérdésre.',
          ro: 'Vă rugăm să răspundeți la întrebarea despre cazare.',
          pt: 'Por favor, responde à pergunta sobre o alojamento.',
          sq: 'Të lutem përgjigju pyetjes për strehimin.',
        );
      }
      // Eigenes Fahrzeug für den Arbeitsweg — ebenfalls Pflicht (Local/EU).
      if (_isLocal && _ownVehicleForCommute == null) {
        return _lt(
          de: 'Bitte die Frage zum eigenen Fahrzeug beantworten.',
          en: 'Please answer the question about your own vehicle.',
          bg: 'Моля, отговорете на въпроса за собствено превозно средство.',
          hu: 'Kérjük, válaszoljon a saját járműre vonatkozó kérdésre.',
          ro: 'Vă rugăm să răspundeți la întrebarea despre vehiculul propriu.',
          pt: 'Por favor, responde à pergunta sobre o veículo próprio.',
          sq: 'Të lutem përgjigju pyetjes për automjetin vetjak.',
        );
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
            ? _lt(
                de: 'T-Shirt-Größe fehlt.',
                en: 'Shirt size missing.',
                bg: 'Липсва размер на тениската.',
                hu: 'Hiányzik a pólóméret.',
                ro: 'Lipsește mărimea tricoului.',
                pt: 'Falta o tamanho da t-shirt.',
                sq: 'Madhësia e bluzës mungon.',
              )
            : _vt('Madhësia mungon.', 'Größe fehlt.');
      }
      if (_shoeSize.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Schuhgröße fehlt.',
                en: 'Shoe size missing.',
                bg: 'Липсва номер на обувките.',
                hu: 'Hiányzik a cipőméret.',
                ro: 'Lipsește mărimea la încălțăminte.',
                pt: 'Falta o número do calçado.',
                sq: 'Numri i këpucëve mungon.',
              )
            : _vt('Numri i këpucëve mungon.', 'Schuhgröße fehlt.');
      }
      if (_phone.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'Telefonnummer fehlt.',
                en: 'Phone number missing.',
                bg: 'Липсва телефонен номер.',
                hu: 'Hiányzik a telefonszám.',
                ro: 'Lipsește numărul de telefon.',
                pt: 'Falta o número de telefone.',
                sq: 'Numri i telefonit mungon.',
              )
            : 'Telefon fehlt.';
      }
      if (_email.text.trim().isEmpty) {
        return _isLocal
            ? _lt(
                de: 'E-Mail-Adresse fehlt.',
                en: 'Email address missing.',
                bg: 'Липсва имейл адрес.',
                hu: 'Hiányzik az e-mail-cím.',
                ro: 'Lipsește adresa de e-mail.',
                pt: 'Falta o endereço de e-mail.',
                sq: 'Adresa e emailit mungon.',
              )
            : 'Email fehlt.';
      }
      if (!_email.text.contains('@')) {
        return _isLocal
            ? _lt(
                de: 'E-Mail-Adresse ist ungültig.',
                en: 'Email address is invalid.',
                bg: 'Имейл адресът е невалиден.',
                hu: 'Az e-mail-cím érvénytelen.',
                ro: 'Adresa de e-mail este invalidă.',
                pt: 'O endereço de e-mail é inválido.',
                sq: 'Adresa e emailit është e pavlefshme.',
              )
            : 'Email ist ungültig.';
      }
      // IBAN: Local/EU fragt sie im Finance-Schritt ab — hier nur Visa.
      if (!_isLocal) {
        if (!_noIbanYet && _cleanedIban().isEmpty) {
          return _vt('IBAN mungon.', 'IBAN fehlt.');
        }
        if (!_noIbanYet && !_ibanPattern.hasMatch(_cleanedIban())) {
          return _vt('IBAN duket i pavlefshëm.',
              'IBAN scheint ungültig.');
        }
      }
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
      if (_amazonPartnerExperience == null) {
        return _vt(
            'Ju lutemi zgjidhni Po ose Jo për përvojën me Amazon.',
            'Bitte Ja oder Nein zur Amazon-Erfahrung wählen.');
      }
      return null;
    }
    if (id == 'docs') {
        if (_passport == null) {
          return _isLocal
              ? _lt(
                  de: 'Pass / Personalausweis (Vorderseite) fehlt.',
                  en: 'Passport / ID card (front) missing.',
                  bg: 'Липсва паспорт / лична карта (лицева страна).',
                  hu: 'Hiányzik az útlevél / személyi igazolvány (előlap).',
                  ro: 'Lipsește pașaportul / cartea de identitate (față).',
                  pt: 'Falta o passaporte / cartão de identidade (frente).',
                  sq: 'Pasaporta / letërnjoftimi (faqja e përparme) mungon.',
                )
              : 'Pass / Personalausweis fehlt.';
        }
        if (_idBack == null) {
          return _isLocal
              ? _lt(
                  de: 'Personalausweis (Rückseite) fehlt.',
                  en: 'ID card (back) missing.',
                  bg: 'Липсва лична карта (гръб).',
                  hu: 'Hiányzik a személyi igazolvány (hátlap).',
                  ro: 'Lipsește cartea de identitate (verso).',
                  pt: 'Falta o cartão de identidade (verso).',
                  sq: 'Letërnjoftimi (faqja e pasme) mungon.',
                )
              : 'Personalausweis Rückseite fehlt / ID back side missing.';
        }
        if (_selfie == null) {
          return _isLocal
              ? _lt(
                  de: 'Selfie für den Driver-Badge fehlt.',
                  en: 'Selfie for the driver badge missing.',
                  bg: 'Липсва селфи за баджа на шофьора.',
                  hu: 'Hiányzik a sofőrkártyához szükséges szelfi.',
                  ro: 'Lipsește selfie-ul pentru ecusonul de șofer.',
                  pt: 'Falta a selfie para o crachá de motorista.',
                  sq: 'Selfie për distinktivin e shoferit mungon.',
                )
              : 'Selfie für Driver-Badge fehlt / Selfie missing.';
        }
        if (_licenseFront == null) {
          return _isLocal
              ? _lt(
                  de: 'Führerschein (Vorderseite) fehlt.',
                  en: "Driver's licence (front) missing.",
                  bg: 'Липсва шофьорска книжка (лицева страна).',
                  hu: 'Hiányzik a jogosítvány (előlap).',
                  ro: 'Lipsește permisul de conducere (față).',
                  pt: 'Falta a carta de condução (frente).',
                  sq: 'Patenta e shoferit (faqja e përparme) mungon.',
                )
              : 'Führerschein Vorderseite fehlt.';
        }
        if (_licenseBack == null) {
          return _isLocal
              ? _lt(
                  de: 'Führerschein (Rückseite) fehlt.',
                  en: "Driver's licence (back) missing.",
                  bg: 'Липсва шофьорска книжка (гръб).',
                  hu: 'Hiányzik a jogosítvány (hátlap).',
                  ro: 'Lipsește permisul de conducere (verso).',
                  pt: 'Falta a carta de condução (verso).',
                  sq: 'Patenta e shoferit (faqja e pasme) mungon.',
                )
              : 'Führerschein Rückseite fehlt.';
        }
        if (!_dsgvoAccepted) {
          return _isLocal
              ? _lt(
                  de: 'Bitte die Datenschutz-Einwilligung akzeptieren.',
                  en: 'Please accept the data protection consent.',
                  bg: 'Моля, приемете съгласието за защита на данните.',
                  hu: 'Kérjük, fogadja el az adatvédelmi hozzájárulást.',
                  ro: 'Vă rugăm să acceptați consimțământul privind '
                      'protecția datelor.',
                  pt: 'Por favor, aceita o consentimento de proteção de '
                      'dados.',
                  sq: 'Të lutem prano pëlqimin për mbrojtjen e të dhënave.',
                )
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
        setState(() => _error = _isLocal
            ? _lt(
                de: 'Das Bild ist zu groß und konnte nicht komprimiert '
                    'werden. Bitte wählen Sie eine kleinere Version.',
                en: 'Image too large and could not be compressed. Please '
                    'pick a smaller version.',
                bg: 'Изображението е твърде голямо и не можа да бъде '
                    'компресирано. Моля, изберете по-малка версия.',
                hu: 'A kép túl nagy, és nem sikerült tömöríteni. Kérjük, '
                    'válasszon kisebb változatot.',
                ro: 'Imaginea este prea mare și nu a putut fi comprimată. '
                    'Vă rugăm să alegeți o versiune mai mică.',
                pt: 'A imagem é demasiado grande e não foi possível '
                    'comprimi-la. Por favor, escolhe uma versão mais '
                    'pequena.',
                sq: 'Fotoja është shumë e madhe dhe nuk u kompresua dot. Të '
                    'lutem zgjidh një version më të vogël.',
              )
            : 'Image too large and could not be compressed. Please '
                'pick a smaller version.');
        return;
      }
      bytes = shrunk;
      mime = 'image/jpeg';
    } else if (bytes.lengthInBytes > hardCapBytes) {
      final mb = (bytes.lengthInBytes / 1024 / 1024).toStringAsFixed(1);
      setState(() => _error = _isLocal
          ? _lt(
              de: 'Datei zu groß ($mb MB). Maximal 10 MB pro Dokument.',
              en: 'File too large ($mb MB). Max 10 MB per document.',
              bg: 'Файлът е твърде голям ($mb MB). Максимум 10 MB на документ.',
              hu: 'A fájl túl nagy ($mb MB). Dokumentumonként legfeljebb 10 MB.',
              ro: 'Fișier prea mare ($mb MB). Maximum 10 MB per document.',
              pt: 'Ficheiro demasiado grande ($mb MB). Máximo 10 MB por '
                  'documento.',
              sq: 'Skedari është shumë i madh ($mb MB). Maksimumi 10 MB për '
                  'dokument.',
            )
          : 'File too large ($mb MB). Max 10 MB per document.');
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
  Future<Uint8List?> _compressImage(Uint8List raw) =>
      const RecruitingUploadService().compressImage(raw);

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
  }) =>
      const RecruitingUploadService().uploadDocument(
        adminUid: widget.adminUid,
        appId: appId,
        label: label,
        bytes: file.bytes,
        filename: file.filename,
        mimeType: file.mimeType,
      );

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
      _uploadProgress = _isLocal
          ? _lt(
              de: 'Wird vorbereitet…',
              en: 'Preparing…',
              bg: 'Подготовка…',
              hu: 'Előkészítés…',
              ro: 'Se pregătește…',
              pt: 'A preparar…',
              sq: 'Po përgatitet…',
            )
          : 'Preparing…';
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
        ('passport', _passport!, _docSlotLabel('passport')),
        ('id_back', _idBack!, _docSlotLabel('id_back')),
        ('selfie', _selfie!, _docSlotLabel('selfie')),
        ('license_front', _licenseFront!, _docSlotLabel('license_front')),
        ('license_back', _licenseBack!, _docSlotLabel('license_back')),
      ];
      final results = <RecruitingDocument>[];
      for (var i = 0; i < slots.length; i++) {
        final s = slots[i];
        final n = '${i + 1}/${slots.length}';
        setState(() => _uploadProgress = _isLocal
            ? _lt(
                de: 'Lädt $n: ${s.$3}…',
                en: 'Uploading $n: ${s.$3}…',
                bg: 'Качване $n: ${s.$3}…',
                hu: 'Feltöltés $n: ${s.$3}…',
                ro: 'Se încarcă $n: ${s.$3}…',
                pt: 'A carregar $n: ${s.$3}…',
                sq: 'Po ngarkohet $n: ${s.$3}…',
              )
            : 'Lädt $n: ${s.$3}…');
        try {
          final r = await _uploadDocument(
              appId: appId, label: s.$1, file: s.$2);
          results.add(r);
        } catch (e) {
          throw Exception(
            _isLocal
                ? _lt(
                    de: 'Upload „${s.$3}" fehlgeschlagen — $e',
                    en: 'Upload of "${s.$3}" failed — $e',
                    bg: 'Качването на „${s.$3}" беше неуспешно — $e',
                    hu: 'A(z) „${s.$3}" feltöltése sikertelen — $e',
                    ro: 'Încărcarea „${s.$3}" a eșuat — $e',
                    pt: 'O carregamento de "${s.$3}" falhou — $e',
                    sq: 'Ngarkimi i "${s.$3}" dështoi — $e',
                  )
                : 'Upload "${s.$3}" fehlgeschlagen — $e',
          );
        }
      }

      setState(() => _uploadProgress = _isLocal
          ? _lt(
              de: 'Wird gespeichert…',
              en: 'Saving…',
              bg: 'Запазване…',
              hu: 'Mentés…',
              ro: 'Se salvează…',
              pt: 'A guardar…',
              sq: 'Po ruhet…',
            )
          : 'Saving…');
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
        // Prior parcel-driver experience for an Amazon partner company.
        'amazonPartnerExperience': _amazonPartnerExperience,
        if (_employmentInterest == 'parttime')
          'parttimeDaysPerWeek': _parttimeDays,
        if (_employmentInterest == 'parttime')
          'parttimeWeekdays': _orderedParttimeWeekdays(),
        'birthCountry': _birthCountry.text.trim(),
        // DSGVO-Nachweis (Art. 7 DSGVO — Einwilligung dokumentieren)
        'dsgvoConsent': _dsgvoAccepted,
        'dsgvoConsentAt': DateTime.now().toIso8601String(),
        // Bankverbindung — in beiden Kanälen abgefragt.
        'iban': _noIbanYet ? 'later' : _cleanedIban(),
        'ibanSubmitLater': _noIbanYet,
        // Visa-Kanal: Ersterteilung oder Arbeitgeberwechsel (Ticket —
        // muss in den Ergebnissen notiert sein).
        if (!_isLocal && _visaPermitType != null)
          'visaPermitType': _visaPermitType,
        if (_isLocal) ...{
          // Sprache, in der das Formular ausgefüllt wurde — das Admin-Team
          // weiß dadurch, in welcher Sprache es antworten sollte.
          'formLanguage': _localLang ?? 'de',
          // Zusätzliche Unterkunft gewünscht? (Pflichtfrage im Adress-Schritt)
          'needsAccommodation': _needsAccommodation ?? false,
          // Eigenes Fahrzeug für den Arbeitsweg? (Pflichtfrage, Adress-Schritt)
          'ownVehicleForCommute': _ownVehicleForCommute ?? false,
          // Frühestmöglicher Starttermin als ISO-Datum (yyyy-MM-dd).
          if (_earliestStart != null)
            'earliestStart':
                _earliestStart!.toIso8601String().substring(0, 10),
          // Werbeprämie: wer hat die Bewerberin / den Bewerber geworben?
          if (_referredBy.text.trim().isNotEmpty)
            'referredBy': _referredBy.text.trim(),
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
        phoneWhatsApp: _fullPhone(),
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
      setState(() => _error = _isLocal
          ? _lt(
              de: 'Senden fehlgeschlagen: $e',
              en: 'Submit failed: $e',
              bg: 'Изпращането беше неуспешно: $e',
              hu: 'A küldés sikertelen: $e',
              ro: 'Trimiterea a eșuat: $e',
              pt: 'O envio falhou: $e',
              sq: 'Dërgimi dështoi: $e',
            )
          : 'Submit failed: $e');
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
    // Direkt nach der Sprachauswahl: Ersterteilung oder
    // Arbeitgeberwechsel? (Ticket — nur im Visa-Kanal.)
    if (widget.channel == RecruitingChannel.visa &&
        _visaPermitType == null) {
      return _ScaffoldShell(body: _buildVisaPermitTypePicker());
    }
    // Local/EU-Formular: gleiches Muster — zuerst Sprache wählen,
    // danach das Formular einsprachig anzeigen.
    if (_isLocal && _localLang == null) {
      return _ScaffoldShell(body: _buildLocalLanguagePicker());
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

  /// Visa-Kanal, direkt nach der Sprachauswahl (Ticket): Ersterteilung
  /// oder Arbeitgeberwechsel — in der gewählten Sprache.
  Widget _buildVisaPermitTypePicker() {
    Widget option({
      required IconData icon,
      required String label,
      required String sub,
      required String value,
    }) {
      return InkWell(
        onTap: () => setState(() => _visaPermitType = value),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child:
                    Icon(icon, color: AppColors.codriverDeep, size: 24),
              ),
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
                  child: const Icon(Icons.badge_outlined,
                      color: AppColors.codriverDeep, size: 28),
                ),
                const SizedBox(height: 18),
                Text(
                  _vt('Viza / leja e punës', 'Visum / Arbeitserlaubnis'),
                  style: AppTypography.title2.copyWith(
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _vt(
                      'A po aplikon për herë të parë për vizë pune, apo '
                          'po ndërron punëdhënësin?',
                      'Beantragst du zum ersten Mal ein Arbeitsvisum, '
                          'oder wechselst du den Arbeitgeber?'),
                  style: AppTypography.body.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                option(
                  icon: Icons.fiber_new_rounded,
                  label: _vt('Aplikim për herë të parë', 'Ersterteilung'),
                  sub: _vt('Viza ime e parë e punës në Gjermani',
                      'Mein erstes Arbeitsvisum für Deutschland'),
                  value: 'first_issue',
                ),
                const SizedBox(height: 12),
                option(
                  icon: Icons.swap_horiz_rounded,
                  label: _vt('Ndërrim punëdhënësi', 'Arbeitgeberwechsel'),
                  sub: _vt('Kam vizë dhe ndërroj punëdhënësin',
                      'Ich habe ein Visum und wechsle den Arbeitgeber'),
                  value: 'employer_change',
                ),
              ],
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

  /// Local/EU-Kanal: Sprachauswahl vor dem Formular (gleiches Muster wie
  /// im Visa-Kanal, nur mit fünf Sprachen). Nach der Auswahl wird das
  /// Formular ausschließlich in dieser Sprache angezeigt.
  Widget _buildLocalLanguagePicker() {
    Widget option({
      required String flag,
      required String label,
      required String sub,
      required String code,
    }) {
      return InkWell(
        onTap: () => setState(() => _localLang = code),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Text(flag, style: const TextStyle(fontSize: 28)),
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
        child: SingleChildScrollView(
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
                    'Sprache wählen · Choose language',
                    style: AppTypography.title2.copyWith(
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Wähle die Sprache für das Formular · '
                    'Choose the language for the form.',
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  option(
                    flag: '🇩🇪',
                    label: 'Deutsch',
                    sub: 'Weiter auf Deutsch',
                    code: 'de',
                  ),
                  const SizedBox(height: 12),
                  option(
                    flag: '🇬🇧',
                    label: 'English',
                    sub: 'Continue in English',
                    code: 'en',
                  ),
                  const SizedBox(height: 12),
                  option(
                    flag: '🇧🇬',
                    label: 'Български',
                    sub: 'Продължете на български',
                    code: 'bg',
                  ),
                  const SizedBox(height: 12),
                  option(
                    flag: '🇭🇺',
                    label: 'Magyar',
                    sub: 'Folytatás magyarul',
                    code: 'hu',
                  ),
                  const SizedBox(height: 12),
                  option(
                    flag: '🇷🇴',
                    label: 'Română',
                    sub: 'Continuă în română',
                    code: 'ro',
                  ),
                  const SizedBox(height: 12),
                  option(
                    flag: '🇵🇹',
                    label: 'Português',
                    sub: 'Continuar em português',
                    code: 'pt',
                  ),
                  const SizedBox(height: 12),
                  option(
                    flag: '🇦🇱',
                    label: 'Shqip',
                    sub: 'Vazhdo në shqip',
                    code: 'sq',
                  ),
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
                    ? _vt('Aplikim me Vizë Pune', 'Arbeitsvisum-Antrag')
                    : _lt(
                        de: 'Fahrer-Bewerbung',
                        en: 'Driver application',
                        bg: 'Кандидатура за шофьор',
                        hu: 'Sofőr jelentkezés',
                        ro: 'Candidatură șofer',
                        pt: 'Candidatura a motorista',
                        sq: 'Aplikim për shofer',
                      ),
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
              ? _lt(
                  de: 'Weitere Fragen',
                  en: 'Additional questions',
                  bg: 'Допълнителни въпроси',
                  hu: 'További kérdések',
                  ro: 'Întrebări suplimentare',
                  pt: 'Perguntas adicionais',
                  sq: 'Pyetje shtesë',
                )
              : _vt('Pyetjet shtesë', 'Weitere Fragen'),
        ),
        for (final f in _customFields)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _CustomFieldInput(
              field: f,
              value: _customAnswers[f.id],
              answerHint: _isLocal
                  ? _lt(
                      de: 'Antwort eingeben',
                      en: 'Type your answer',
                      bg: 'Въведете отговор',
                      hu: 'Írja be a válaszát',
                      ro: 'Introduceți răspunsul',
                      pt: 'Escreve a tua resposta',
                      sq: 'Shkruaj përgjigjen tënde',
                    )
                  : 'Type your answer',
              yesLabel: _isLocal
                  ? _lt(
                      de: 'Ja',
                      en: 'Yes',
                      bg: 'Да',
                      hu: 'Igen',
                      ro: 'Da',
                      pt: 'Sim',
                      sq: 'Po',
                    )
                  : 'Yes · Ja',
              noLabel: _isLocal
                  ? _lt(
                      de: 'Nein',
                      en: 'No',
                      bg: 'Не',
                      hu: 'Nem',
                      ro: 'Nu',
                      pt: 'Não',
                      sq: 'Jo',
                    )
                  : 'No · Nein',
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
              ? _lt(
                  de: 'Beschäftigungs-Wunsch',
                  en: 'Employment interest',
                  bg: 'Желана заетост',
                  hu: 'Kívánt foglalkoztatás',
                  ro: 'Tipul de angajare dorit',
                  pt: 'Tipo de emprego pretendido',
                  sq: 'Lloji i punësimit të dëshiruar',
                )
              : _vt('Lloji i punës', 'Beschäftigungs-Wunsch'),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Wofür bewerben Sie sich?',
                  en: 'What are you applying for?',
                  bg: 'За какво кандидатствате?',
                  hu: 'Mire jelentkezik?',
                  ro: 'Pentru ce aplicați?',
                  pt: 'A que te candidatas?',
                  sq: 'Për çfarë po aplikon?',
                )
              : _vt('Për çfarë po aplikoni?', 'Was bewirbst du dich?'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: _isLocal
                    ? _lt(
                        de: 'Vollzeit',
                        en: 'Full-time',
                        bg: 'Пълно работно време',
                        hu: 'Teljes munkaidő',
                        ro: 'Normă întreagă',
                        pt: 'Tempo inteiro',
                        sq: 'Kohë e plotë',
                      )
                    : _vt('Kohë e plotë', 'Vollzeit'),
                selected: _employmentInterest == 'fulltime',
                onTap: () =>
                    setState(() => _employmentInterest = 'fulltime'),
              ),
              _ChoiceTile(
                label: _isLocal
                    ? _lt(
                        de: 'Teilzeit',
                        en: 'Part-time',
                        bg: 'Непълно работно време',
                        hu: 'Részmunkaidő',
                        ro: 'Normă parțială',
                        pt: 'Tempo parcial',
                        sq: 'Kohë e pjesshme',
                      )
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
                        ? _lt(
                            de: 'Wie viele Tage pro Woche?',
                            en: 'How many days per week?',
                            bg: 'Колко дни седмично?',
                            hu: 'Hány napot hetente?',
                            ro: 'Câte zile pe săptămână?',
                            pt: 'Quantos dias por semana?',
                            sq: 'Sa ditë në javë?',
                          )
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
                          label: _isLocal
                              ? _lt(
                                  de: '$d Tage',
                                  en: '$d days',
                                  bg: '$d дни',
                                  hu: '$d nap',
                                  ro: '$d zile',
                                  pt: '$d dias',
                                  sq: '$d ditë',
                                )
                              : _vt('$d ditë', '$d Tage'),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 6),
                  child: Text(
                    _isLocal
                        ? _lt(
                            de: 'An welchen Tagen können Sie arbeiten?',
                            en: 'Which days are you available?',
                            bg: 'В кои дни сте на разположение?',
                            hu: 'Mely napokon tud dolgozni?',
                            ro: 'În ce zile sunteți disponibil?',
                            pt: 'Em que dias estás disponível?',
                            sq: 'Në cilat ditë mund të punosh?',
                          )
                        : _vt('Në cilat ditë je i disponueshëm?',
                            'An welchen Tagen kannst du?'),
                    style: AppTypography.caption1.copyWith(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final w in _kWeekdayOptions)
                      _WeekdayChip(
                        label:
                            _isLocal ? _localWeekdayLabel(w[0]) : w[1],
                        selected: _parttimeWeekdays.contains(w[0]),
                        onTap: () => setState(() {
                          if (!_parttimeWeekdays.remove(w[0])) {
                            _parttimeWeekdays.add(w[0]);
                          }
                        }),
                      ),
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
                    ? _lt(
                        de: 'Werkstudent',
                        en: 'Working student',
                        bg: 'Студент на работа (Werkstudent)',
                        hu: 'Diákmunka (Werkstudent)',
                        ro: 'Student angajat (Werkstudent)',
                        pt: 'Estudante trabalhador (Werkstudent)',
                        sq: 'Student punonjës (Werkstudent)',
                      )
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
              ? _lt(
                  de: 'Persönliche Daten',
                  en: 'Personal info',
                  bg: 'Лични данни',
                  hu: 'Személyes adatok',
                  ro: 'Date personale',
                  pt: 'Dados pessoais',
                  sq: 'Të dhënat personale',
                )
              : _vt('Të dhënat personale', 'Persönliche Daten'),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Vorname',
                  en: 'First name',
                  bg: 'Име',
                  hu: 'Keresztnév',
                  ro: 'Prenume',
                  pt: 'Nome próprio',
                  sq: 'Emri',
                )
              : _vt('Emri', 'Vorname'),
          child: TextField(
            controller: _firstName,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. Andreas',
                      en: 'e.g. Andreas',
                      bg: 'напр. Андрей',
                      hu: 'pl. András',
                      ro: 'ex. Andrei',
                      pt: 'p. ex. André',
                      sq: 'p.sh. Andreas',
                    )
                  : 'z.B. Andi',
            ),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Nachname',
                  en: 'Last name',
                  bg: 'Фамилия',
                  hu: 'Vezetéknév',
                  ro: 'Nume de familie',
                  pt: 'Apelido',
                  sq: 'Mbiemri',
                )
              : _vt('Mbiemri', 'Nachname'),
          child: TextField(
            controller: _lastName,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. Müller',
                      en: 'e.g. Müller',
                      bg: 'напр. Иванов',
                      hu: 'pl. Kovács',
                      ro: 'ex. Popescu',
                      pt: 'p. ex. Silva',
                      sq: 'p.sh. Krasniqi',
                    )
                  : 'z.B. Krasniqi',
            ),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Geburtsdatum',
                  en: 'Date of birth',
                  bg: 'Дата на раждане',
                  hu: 'Születési dátum',
                  ro: 'Data nașterii',
                  pt: 'Data de nascimento',
                  sq: 'Data e lindjes',
                )
              : _vt('Data e lindjes', 'Geburtsdatum'),
          child: _DatePickerField(
            value: _birthDate,
            firstDate: DateTime(1940),
            lastDate: DateTime.now(),
            placeholder: _isLocal ? _pickDateLabel() : 'Choose a date',
            onPick: (d) => setState(() => _birthDate = d),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Geburtsort (Stadt)',
                  en: 'Place of birth (city)',
                  bg: 'Място на раждане (град)',
                  hu: 'Születési hely (város)',
                  ro: 'Locul nașterii (oraș)',
                  pt: 'Local de nascimento (cidade)',
                  sq: 'Vendlindja (qyteti)',
                )
              : _vt('Vendlindja (Qyteti)', 'Geburtsort (Stadt)'),
          child: TextField(
            controller: _birthPlace,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. Köln',
                      en: 'e.g. Cologne',
                      bg: 'напр. София',
                      hu: 'pl. Budapest',
                      ro: 'ex. București',
                      pt: 'p. ex. Lisboa',
                      sq: 'p.sh. Tirana',
                    )
                  : 'z.B. Prishtina',
            ),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Geburtsland',
                  en: 'Country of birth',
                  bg: 'Държава на раждане',
                  hu: 'Születési ország',
                  ro: 'Țara nașterii',
                  pt: 'País de nascimento',
                  sq: 'Shteti i lindjes',
                )
              : _vt('Shteti i lindjes', 'Geburtsland'),
          child: TextField(
            controller: _birthCountry,
            textCapitalization: TextCapitalization.words,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. Deutschland',
                      en: 'e.g. Germany',
                      bg: 'напр. България',
                      hu: 'pl. Magyarország',
                      ro: 'ex. România',
                      pt: 'p. ex. Portugal',
                      sq: 'p.sh. Shqipëria',
                    )
                  : 'z.B. Kosovo / Deutschland',
            ),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Nationalität',
                  en: 'Nationality',
                  bg: 'Гражданство',
                  hu: 'Állampolgárság',
                  ro: 'Cetățenie',
                  pt: 'Nacionalidade',
                  sq: 'Shtetësia',
                )
              : _vt('Shtetësia', 'Nationalität'),
          child: _isLocal
              ? TextField(
                  controller: _nationalityFreeText,
                  decoration: _input(
                    _lt(
                      de: 'z. B. deutsch',
                      en: 'e.g. German',
                      bg: 'напр. българско',
                      hu: 'pl. magyar',
                      ro: 'ex. română',
                      pt: 'p. ex. portuguesa',
                      sq: 'p.sh. shqiptare',
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _nationality = v.trim()),
                )
              : Column(
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
                          child: Text(_vt('Tjetër…', 'Andere…')),
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
                          _vt('Shkruani shtetësinë', 'Nationalität eingeben'),
                        ),
                        onChanged: (v) =>
                            setState(() => _nationality = v.trim()),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return ListView(
      children: [
        _SectionLabel(
          text: _isLocal
              ? _lt(
                  de: 'Adresse',
                  en: 'Address',
                  bg: 'Адрес',
                  hu: 'Cím',
                  ro: 'Adresă',
                  pt: 'Morada',
                  sq: 'Adresa',
                )
              : _vt('Adresa', 'Adresse'),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Straße + Hausnummer',
                  en: 'Street + house number',
                  bg: 'Улица и номер',
                  hu: 'Utca és házszám',
                  ro: 'Strada și numărul',
                  pt: 'Rua e número',
                  sq: 'Rruga dhe numri i shtëpisë',
                )
              : _vt('Rruga + Numri i shtëpisë', 'Straße + Hausnummer'),
          child: TextField(
            controller: _street,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. Musterstraße 12',
                      en: 'e.g. Musterstraße 12',
                      bg: 'напр. Musterstraße 12',
                      hu: 'pl. Musterstraße 12',
                      ro: 'ex. Musterstraße 12',
                      pt: 'p. ex. Musterstraße 12',
                      sq: 'p.sh. Musterstraße 12',
                    )
                  : 'z.B. Musterstraße 12',
            ),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Postleitzahl',
                  en: 'Postal code',
                  bg: 'Пощенски код',
                  hu: 'Irányítószám',
                  ro: 'Cod poștal',
                  pt: 'Código postal',
                  sq: 'Kodi postar',
                )
              : _vt('Kodi postar', 'Postleitzahl'),
          child: TextField(
            controller: _postalCode,
            keyboardType: TextInputType.number,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. 51063',
                      en: 'e.g. 51063',
                      bg: 'напр. 51063',
                      hu: 'pl. 51063',
                      ro: 'ex. 51063',
                      pt: 'p. ex. 51063',
                      sq: 'p.sh. 51063',
                    )
                  : 'z.B. 51063',
            ),
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Stadt / Wohnort',
                  en: 'City',
                  bg: 'Град / населено място',
                  hu: 'Város / lakóhely',
                  ro: 'Oraș / localitate',
                  pt: 'Cidade / localidade',
                  sq: 'Qyteti / vendbanimi',
                )
              : _vt('Qyteti / Vendbanimi', 'Stadt / Wohnort'),
          child: TextField(
            controller: _city,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. Köln',
                      en: 'e.g. Cologne',
                      bg: 'напр. Köln',
                      hu: 'pl. Köln',
                      ro: 'ex. Köln',
                      pt: 'p. ex. Köln',
                      sq: 'p.sh. Köln',
                    )
                  : 'z.B. Köln',
            ),
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
        // ── Unterkunft (nur Local/EU, Pflichtangabe) ────────────────
        if (_isLocal) ...[
          const SizedBox(height: 8),
          _SectionLabel(
            text: _lt(
              de: 'Unterkunft',
              en: 'Accommodation',
              bg: 'Настаняване',
              hu: 'Szállás',
              ro: 'Cazare',
              pt: 'Alojamento',
              sq: 'Strehimi',
            ),
          ),
          _LabeledField(
            label: _lt(
              de: 'Brauchen Sie zusätzlich eine Unterkunft?',
              en: 'Do you also need accommodation?',
              bg: 'Имате ли нужда и от настаняване?',
              hu: 'Szüksége van szállásra is?',
              ro: 'Aveți nevoie și de cazare?',
              pt: 'Também precisas de alojamento?',
              sq: 'A ke nevojë edhe për strehim?',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChoiceTile(
                  label: _lt(
                    de: 'Ja, ich brauche eine Unterkunft',
                    en: 'Yes, I need accommodation',
                    bg: 'Да, имам нужда от настаняване',
                    hu: 'Igen, szükségem van szállásra',
                    ro: 'Da, am nevoie de cazare',
                    pt: 'Sim, preciso de alojamento',
                    sq: 'Po, kam nevojë për strehim',
                  ),
                  selected: _needsAccommodation == true,
                  onTap: () => setState(() => _needsAccommodation = true),
                ),
                _ChoiceTile(
                  label: _lt(
                    de: 'Nein, ich habe eine Unterkunft',
                    en: 'No, I already have accommodation',
                    bg: 'Не, вече имам жилище',
                    hu: 'Nem, van szállásom',
                    ro: 'Nu, am deja o locuință',
                    pt: 'Não, já tenho alojamento',
                    sq: 'Jo, e kam strehimin',
                  ),
                  selected: _needsAccommodation == false,
                  onTap: () => setState(() => _needsAccommodation = false),
                ),
              ],
            ),
          ),
          _LabeledField(
            label: _lt(
              de: 'Haben Sie ein eigenes Fahrzeug für den Weg zur Arbeit?',
              en: 'Do you have your own vehicle to get to work?',
              bg: 'Имате ли собствено превозно средство за път до работа?',
              hu: 'Van saját járműve a munkába járáshoz?',
              ro: 'Aveți un vehicul propriu pentru a ajunge la muncă?',
              pt: 'Tens veículo próprio para ir para o trabalho?',
              sq: 'A ke automjet vetjak për të shkuar në punë?',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChoiceTile(
                  label: _lt(
                    de: 'Ja, ich habe ein eigenes Fahrzeug',
                    en: 'Yes, I have my own vehicle',
                    bg: 'Да, имам собствено превозно средство',
                    hu: 'Igen, van saját járművem',
                    ro: 'Da, am un vehicul propriu',
                    pt: 'Sim, tenho veículo próprio',
                    sq: 'Po, kam automjet vetjak',
                  ),
                  selected: _ownVehicleForCommute == true,
                  onTap: () => setState(() => _ownVehicleForCommute = true),
                ),
                _ChoiceTile(
                  label: _lt(
                    de: 'Nein, ich habe kein eigenes Fahrzeug',
                    en: "No, I don't have my own vehicle",
                    bg: 'Не, нямам собствено превозно средство',
                    hu: 'Nem, nincs saját járművem',
                    ro: 'Nu, nu am un vehicul propriu',
                    pt: 'Não, não tenho veículo próprio',
                    sq: 'Jo, nuk kam automjet vetjak',
                  ),
                  selected: _ownVehicleForCommute == false,
                  onTap: () => setState(() => _ownVehicleForCommute = false),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContactStep() {
    return ListView(
      children: [
        _SectionLabel(
          text: _isLocal
              ? _lt(
                  de: 'Größen & Kontakt',
                  en: 'Sizes & contact',
                  bg: 'Размери и контакт',
                  hu: 'Méretek és elérhetőség',
                  ro: 'Mărimi și contact',
                  pt: 'Tamanhos e contacto',
                  sq: 'Madhësitë dhe kontakti',
                )
              : _vt('Madhësitë & Kontakti', 'Größen & Kontakt'),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'T-Shirt- & Jacken-Größe',
                  en: 'T-shirt & jacket size',
                  bg: 'Размер на тениска и яке',
                  hu: 'Póló- és kabátméret',
                  ro: 'Mărime tricou și jachetă',
                  pt: 'Tamanho de t-shirt e casaco',
                  sq: 'Madhësia e bluzës dhe e xhaketës',
                )
              : _vt('Madhësia e bluzës dhe xhaketës', 'T-Shirt- & Jacken-Größe'),
          child: _SizePickerField(
            value: _shirtSize.text,
            options: _kShirtSizes,
            onPick: (v) => setState(() => _shirtSize.text = v),
            placeholder: _isLocal ? _pickSizeLabel() : 'Choose size',
            cancelLabel: _isLocal ? _cancelLabel() : 'Cancel',
            doneLabel: _isLocal ? _doneLabel() : 'Done',
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Schuhgröße',
                  en: 'Shoe size',
                  bg: 'Номер на обувки',
                  hu: 'Cipőméret',
                  ro: 'Mărime încălțăminte',
                  pt: 'Número do calçado',
                  sq: 'Numri i këpucëve',
                )
              : _vt('Numri i këpucëve', 'Schuhgröße'),
          child: _SizePickerField(
            value: _shoeSize.text,
            options: _kShoeSizes,
            onPick: (v) => setState(() => _shoeSize.text = v),
            placeholder: _isLocal ? _pickSizeLabel() : 'Choose size',
            cancelLabel: _isLocal ? _cancelLabel() : 'Cancel',
            doneLabel: _isLocal ? _doneLabel() : 'Done',
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'Telefonnummer (WhatsApp)',
                  en: 'Phone number (WhatsApp)',
                  bg: 'Телефонен номер (WhatsApp)',
                  hu: 'Telefonszám (WhatsApp)',
                  ro: 'Număr de telefon (WhatsApp)',
                  pt: 'Número de telefone (WhatsApp)',
                  sq: 'Numri i telefonit (WhatsApp)',
                )
              : _vt('Numri i telefonit (WhatsApp)', 'Telefonnummer'),
          child: Row(
            children: [
              // Country dial-code picker (defaults to +49).
              SizedBox(
                width: 118,
                child: DropdownButtonFormField<String>(
                  value: _dialCode,
                  isDense: true,
                  decoration: _input(''),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    for (final (flag, code) in _kDialCodes)
                      DropdownMenuItem<String>(
                        value: code,
                        child: Text('$flag $code'),
                      ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _dialCode = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _input(
                    _isLocal
                        ? _lt(
                            de: 'z. B. 170 1234567',
                            en: 'e.g. 170 1234567',
                            bg: 'напр. 170 1234567',
                            hu: 'pl. 170 1234567',
                            ro: 'ex. 170 1234567',
                            pt: 'p. ex. 170 1234567',
                            sq: 'p.sh. 170 1234567',
                          )
                        : 'z.B. 170 1234567',
                  ),
                ),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: _isLocal
              ? _lt(
                  de: 'E-Mail',
                  en: 'Email',
                  bg: 'Имейл',
                  hu: 'E-mail',
                  ro: 'E-mail',
                  pt: 'E-mail',
                  sq: 'Email',
                )
              : 'Email',
          child: TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: _input(
              _isLocal
                  ? _lt(
                      de: 'z. B. name@example.com',
                      en: 'e.g. name@example.com',
                      bg: 'напр. name@example.com',
                      hu: 'pl. name@example.com',
                      ro: 'ex. name@example.com',
                      pt: 'p. ex. name@example.com',
                      sq: 'p.sh. name@example.com',
                    )
                  : 'z.B. andi@example.com',
            ),
          ),
        ),
        // IBAN — beim Local/EU-Flow im Finance-Schritt, hier nur Visa.
        if (!_isLocal)
          _LabeledField(
            label: _vt('IBAN (llogaria bankare)', 'IBAN (Bankverbindung)'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _iban,
                  enabled: !_noIbanYet,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _input('DE12 3456 7890 1234 5678 90'),
                ),
                _LaterToggle(
                  checked: _noIbanYet,
                  onChanged: (v) => setState(() => _noIbanYet = v),
                  label: _vt('Nuk kam ende IBAN',
                      'Ich habe noch keine IBAN'),
                ),
              ],
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
        _SectionLabel(
            text: _vt('Përvoja me Amazon', 'Erfahrung bei Amazon')),
        Text(
          _vt(
              'A ke punuar më parë si shofer pakosh për një kompani '
                  'partnere të Amazon?',
              'Hast du schon einmal für ein Amazon-Partnerunternehmen '
                  'als Paketfahrer gearbeitet?'),
          style: AppTypography.body.copyWith(
            color: const Color(0xFF374151),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RadioCard(
                selected: _amazonPartnerExperience == true,
                title: _vt('Po', 'Ja'),
                subtitle: '',
                onTap: () =>
                    setState(() => _amazonPartnerExperience = true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RadioCard(
                selected: _amazonPartnerExperience == false,
                title: _vt('Jo', 'Nein'),
                subtitle: '',
                onTap: () =>
                    setState(() => _amazonPartnerExperience = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
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
        _SectionLabel(
          text: _lt(
            de: 'Lohnsteuer-Daten',
            en: 'Payroll data',
            bg: 'Данни за заплата',
            hu: 'Bérszámfejtési adatok',
            ro: 'Date de salarizare',
            pt: 'Dados salariais',
            sq: 'Të dhënat e pagës',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
          child: Text(
            _lt(
              de: 'Beide Nummern finden Sie auf Ihrer letzten Lohnabrechnung.',
              en: 'You can find both numbers on your last pay slip.',
              bg: 'И двата номера можете да намерите в последния си фиш '
                  'за заплата.',
              hu: 'Mindkét szám megtalálható a legutóbbi bérpapírján.',
              ro: 'Ambele numere se regăsesc pe ultimul dumneavoastră '
                  'fluturaș de salariu.',
              pt: 'Encontras os dois números no teu último recibo de '
                  'vencimento.',
              sq: 'Të dy numrat i gjen në fletëpagesën tënde të fundit.',
            ),
            style: AppTypography.caption1.copyWith(
              color: const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'IBAN (Bankverbindung)',
            en: 'IBAN (bank account)',
            bg: 'IBAN (банкова сметка)',
            hu: 'IBAN (bankszámla)',
            ro: 'IBAN (cont bancar)',
            pt: 'IBAN (conta bancária)',
            sq: 'IBAN (llogaria bankare)',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _iban,
                enabled: !_noIbanYet,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                decoration: _input('DE12 3456 7890 1234 5678 90'),
              ),
              _LaterToggle(
                checked: _noIbanYet,
                onChanged: (v) => setState(() => _noIbanYet = v),
                label: _lt(
                  de: 'Ich habe noch keine IBAN',
                  en: "I don't have an IBAN yet",
                  bg: 'Все още нямам IBAN',
                  hu: 'Még nincs IBAN-om',
                  ro: 'Încă nu am IBAN',
                  pt: 'Ainda não tenho IBAN',
                  sq: 'Nuk kam ende IBAN',
                ),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'Steueridentifikationsnummer',
            en: 'Tax identification number',
            bg: 'Данъчен идентификационен номер',
            hu: 'Adóazonosító szám',
            ro: 'Număr de identificare fiscală',
            pt: 'Número de identificação fiscal',
            sq: 'Numri i identifikimit tatimor',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _taxId,
                enabled: !_taxIdLater,
                keyboardType: TextInputType.number,
                decoration: _input(
                  _lt(
                    de: '11-stellig',
                    en: '11 digits',
                    bg: '11 цифри',
                    hu: '11 számjegy',
                    ro: '11 cifre',
                    pt: '11 dígitos',
                    sq: '11 shifra',
                  ),
                ),
              ),
              _LaterToggle(
                checked: _taxIdLater,
                onChanged: (v) => setState(() => _taxIdLater = v),
                label: _submitLaterLabel(),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'Sozialversicherungsnummer',
            en: 'Social security number',
            bg: 'Номер на социална осигуровка',
            hu: 'Társadalombiztosítási szám',
            ro: 'Număr de asigurare socială',
            pt: 'Número de segurança social',
            sq: 'Numri i sigurimeve shoqërore',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _socialSecurityNo,
                enabled: !_socialSecurityLater,
                decoration: _input(
                  _lt(
                    de: '12-stellig',
                    en: '12 characters',
                    bg: '12 знака',
                    hu: '12 karakter',
                    ro: '12 caractere',
                    pt: '12 caracteres',
                    sq: '12 karaktere',
                  ),
                ),
              ),
              _LaterToggle(
                checked: _socialSecurityLater,
                onChanged: (v) =>
                    setState(() => _socialSecurityLater = v),
                label: _submitLaterLabel(),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'Krankenkasse',
            en: 'Health insurance',
            bg: 'Здравна каса',
            hu: 'Egészségbiztosítás',
            ro: 'Asigurare de sănătate',
            pt: 'Seguro de saúde',
            sq: 'Sigurimi shëndetësor',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: _lt(
                  de: 'Ich habe eine Krankenkasse',
                  en: 'I have health insurance',
                  bg: 'Имам здравна каса',
                  hu: 'Van egészségbiztosításom',
                  ro: 'Am asigurare de sănătate',
                  pt: 'Tenho seguro de saúde',
                  sq: 'Kam sigurim shëndetësor',
                ),
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
                      _lt(
                        de: 'Name der Krankenkasse · z. B. TK, AOK, Barmer',
                        en: 'Name of the health insurance · '
                            'e.g. TK, AOK, Barmer',
                        bg: 'Име на здравната каса · напр. TK, AOK, Barmer',
                        hu: 'Az egészségbiztosító neve · '
                            'pl. TK, AOK, Barmer',
                        ro: 'Numele casei de asigurări · '
                            'ex. TK, AOK, Barmer',
                        pt: 'Nome do seguro de saúde · p. ex. TK, AOK, '
                            'Barmer',
                        sq: 'Emri i sigurimit shëndetësor · p.sh. TK, AOK, '
                            'Barmer',
                      ),
                    ),
                  ),
                ),
              _ChoiceTile(
                label: _lt(
                  de: 'Ich bin aktuell nicht versichert / '
                      'ich habe keine Krankenkasse',
                  en: 'I am currently not insured / '
                      'I have no health insurance',
                  bg: 'В момента не съм осигурен / нямам здравна каса',
                  hu: 'Jelenleg nincs biztosításom / '
                      'nincs egészségbiztosítóm',
                  ro: 'În prezent nu sunt asigurat / '
                      'nu am casă de asigurări',
                  pt: 'De momento não estou segurado / não tenho seguro de '
                      'saúde',
                  sq: 'Aktualisht nuk jam i siguruar / nuk kam sigurim '
                      'shëndetësor',
                ),
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
                    _lt(
                      de: 'Möchten Sie, dass wir Sie bei einer '
                          'Krankenkasse anmelden?',
                      en: 'Would you like us to register you with a '
                          'health insurance fund?',
                      bg: 'Желаете ли да Ви регистрираме в здравна каса?',
                      hu: 'Szeretné, hogy bejelentsük egy '
                          'egészségbiztosítóhoz?',
                      ro: 'Doriți să vă înscriem la o casă de asigurări '
                          'de sănătate?',
                      pt: 'Queres que te inscrevamos num seguro de saúde?',
                      sq: 'A dëshiron që të të regjistrojmë në një sigurim '
                          'shëndetësor?',
                    ),
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _ChoiceTile(
                  label: _lt(
                    de: 'Ja, bitte bei einer Krankenkasse anmelden',
                    en: 'Yes, please register me with a health insurance',
                    bg: 'Да, моля, регистрирайте ме в здравна каса',
                    hu: 'Igen, kérem a bejelentést egy egészségbiztosítóhoz',
                    ro: 'Da, vă rog să mă înscrieți la o casă de asigurări',
                    pt: 'Sim, por favor inscrevam-me num seguro de saúde',
                    sq: 'Po, ju lutem më regjistroni në një sigurim '
                        'shëndetësor',
                  ),
                  selected: _aokBayernRegister == 'yes',
                  onTap: () => setState(() => _aokBayernRegister = 'yes'),
                ),
                _ChoiceTile(
                  label: _lt(
                    de: 'Nein, ich kümmere mich selbst darum',
                    en: 'No, I will take care of it myself',
                    bg: 'Не, ще се погрижа сам',
                    hu: 'Nem, magam intézem',
                    ro: 'Nu, mă ocup eu însumi',
                    pt: 'Não, trato disso sozinho',
                    sq: 'Jo, kujdesem vetë për këtë',
                  ),
                  selected: _aokBayernRegister == 'no',
                  onTap: () => setState(() => _aokBayernRegister = 'no'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionLabel(
          text: _lt(
            de: 'Familie',
            en: 'Family',
            bg: 'Семейство',
            hu: 'Család',
            ro: 'Familie',
            pt: 'Família',
            sq: 'Familja',
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'Familienstand',
            en: 'Marital status',
            bg: 'Семейно положение',
            hu: 'Családi állapot',
            ro: 'Stare civilă',
            pt: 'Estado civil',
            sq: 'Gjendja civile',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: _lt(
                  de: 'Geschieden',
                  en: 'Divorced',
                  bg: 'Разведен/а',
                  hu: 'Elvált',
                  ro: 'Divorțat(ă)',
                  pt: 'Divorciado(a)',
                  sq: 'I/e divorcuar',
                ),
                selected: _maritalStatus == 'divorced',
                onTap: () => setState(() => _maritalStatus = 'divorced'),
              ),
              _ChoiceTile(
                label: _lt(
                  de: 'Ledig',
                  en: 'Single',
                  bg: 'Неженен/неомъжена',
                  hu: 'Egyedülálló',
                  ro: 'Necăsătorit(ă)',
                  pt: 'Solteiro(a)',
                  sq: 'Beqar/e',
                ),
                selected: _maritalStatus == 'single',
                onTap: () => setState(() => _maritalStatus = 'single'),
              ),
              _ChoiceTile(
                label: _lt(
                  de: 'Verheiratet oder getrennt lebend',
                  en: 'Married or living separately',
                  bg: 'Женен/омъжена или живеещ разделно',
                  hu: 'Házas vagy különélő',
                  ro: 'Căsătorit(ă) sau separat(ă)',
                  pt: 'Casado(a) ou a viver separado(a)',
                  sq: 'I/e martuar ose i/e ndarë',
                ),
                selected: _maritalStatus == 'married_or_separated',
                onTap: () => setState(
                  () => _maritalStatus = 'married_or_separated',
                ),
              ),
              _ChoiceTile(
                label: _lt(
                  de: 'Verwitwet',
                  en: 'Widowed',
                  bg: 'Вдовец/вдовица',
                  hu: 'Özvegy',
                  ro: 'Văduv(ă)',
                  pt: 'Viúvo(a)',
                  sq: 'I ve / e ve',
                ),
                selected: _maritalStatus == 'widowed',
                onTap: () => setState(() => _maritalStatus = 'widowed'),
              ),
            ],
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'Kinder',
            en: 'Children',
            bg: 'Деца',
            hu: 'Gyermekek',
            ro: 'Copii',
            pt: 'Filhos',
            sq: 'Fëmijët',
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceTile(
                label: _lt(
                  de: 'Keine Kinder',
                  en: 'No children',
                  bg: 'Нямам деца',
                  hu: 'Nincs gyermekem',
                  ro: 'Fără copii',
                  pt: 'Sem filhos',
                  sq: 'Pa fëmijë',
                ),
                selected: _childrenChoice == 'none',
                onTap: () => setState(() => _childrenChoice = 'none'),
              ),
              _ChoiceTile(
                label: _lt(
                  de: 'Ja',
                  en: 'Yes',
                  bg: 'Да',
                  hu: 'Igen',
                  ro: 'Da',
                  pt: 'Sim',
                  sq: 'Po',
                ),
                selected: _childrenChoice == 'count',
                onTap: () => setState(() => _childrenChoice = 'count'),
              ),
              if (_childrenChoice == 'count')
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: TextField(
                    controller: _childrenCount,
                    keyboardType: TextInputType.number,
                    decoration: _input(
                      _lt(
                        de: 'Anzahl',
                        en: 'Number',
                        bg: 'Брой',
                        hu: 'Szám',
                        ro: 'Număr',
                        pt: 'Número',
                        sq: 'Numri',
                      ),
                    ),
                  ),
                ),
              _ChoiceTile(
                label: _submitLaterLabel(),
                selected: _childrenChoice == 'later',
                onTap: () => setState(() => _childrenChoice = 'later'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionLabel(
          text: _lt(
            de: 'Anmerkungen',
            en: 'Notes',
            bg: 'Забележки',
            hu: 'Megjegyzések',
            ro: 'Observații',
            pt: 'Observações',
            sq: 'Shënime',
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'Möchten Sie uns noch etwas mitteilen?',
            en: 'Anything else we should know?',
            bg: 'Има ли още нещо, което искате да ни съобщите?',
            hu: 'Van még valami, amit tudnunk kellene?',
            ro: 'Mai doriți să ne comunicați ceva?',
            pt: 'Queres dizer-nos mais alguma coisa?',
            sq: 'A dëshiron të na thuash diçka tjetër?',
          ),
          child: TextField(
            controller: _notes,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _input(
              _lt(
                de: 'Optional — z. B. gewünschte Schichten, Fragen',
                en: 'Optional — e.g. preferred shifts, questions',
                bg: 'По желание — напр. предпочитани смени, въпроси',
                hu: 'Opcionális — pl. kívánt műszakok, kérdések',
                ro: 'Opțional — ex. ture preferate, întrebări',
                pt: 'Opcional — p. ex. turnos preferidos, dúvidas',
                sq: 'Opsionale — p.sh. turnet e preferuara, pyetje',
              ),
            ),
          ),
        ),
        // ── Startdatum (Pflicht, nur Local/EU) ──────────────────────
        const SizedBox(height: 12),
        _SectionLabel(
          text: _lt(
            de: 'Startdatum',
            en: 'Start date',
            bg: 'Начална дата',
            hu: 'Kezdés időpontja',
            ro: 'Data de început',
            pt: 'Data de início',
            sq: 'Data e fillimit',
          ),
        ),
        _LabeledField(
          label: _lt(
            de: 'Ab wann könnten Sie starten?',
            en: 'When could you start?',
            bg: 'От кога бихте могли да започнете?',
            hu: 'Mikortól tudna kezdeni?',
            ro: 'De când ați putea începe?',
            pt: 'A partir de quando poderias começar?',
            sq: 'Nga cila datë mund të fillosh?',
          ),
          child: _DatePickerField(
            value: _earliestStart,
            // Date-only bounds: a picked "today" must not fall before
            // firstDate when the picker is reopened.
            firstDate: _today,
            lastDate: _today.add(const Duration(days: 730)),
            initialDate: _today,
            placeholder: _pickDateLabel(),
            onPick: (d) => setState(() {
              _earliestStart = DateTime(d.year, d.month, d.day);
              _error = null;
            }),
          ),
        ),
        // ── Werbeprämie (nur Local/EU) ──────────────────────────────
        const SizedBox(height: 4),
        _ReferralBonusCard(
          title: _lt(
            de: 'Werbeprämie: 100 €',
            en: 'Referral bonus: €100',
            bg: 'Бонус за препоръка: 100 €',
            hu: 'Ajánlói bónusz: 100 €',
            ro: 'Bonus de recomandare: 100 €',
            pt: 'Prémio por recomendação: 100 €',
            sq: 'Bonus rekomandimi: 100 €',
          ),
          body: _lt(
            de: 'Aktion bis Ende September: Wenn Sie eine neue Mitarbeiterin '
                'oder einen neuen Mitarbeiter werben und diese Person '
                'mindestens einen Monat bei uns bleibt, erhalten Sie 100 € '
                'Prämie.',
            en: 'Promotion until the end of September: if you refer a new '
                'employee and that person stays with us for at least one '
                'month, you receive a €100 bonus.',
            bg: 'Промоция до края на септември: ако препоръчате нов '
                'служител и той остане при нас поне един месец, получавате '
                'бонус от 100 €.',
            hu: 'Akció szeptember végéig: ha új munkatársat ajánl, és az '
                'illető legalább egy hónapig nálunk marad, Ön 100 € '
                'jutalmat kap.',
            ro: 'Promoție până la sfârșitul lunii septembrie: dacă '
                'recomandați un nou angajat și acesta rămâne la noi cel '
                'puțin o lună, primiți un bonus de 100 €.',
            pt: 'Promoção até ao final de setembro: se recomendares um novo '
                'colaborador e essa pessoa ficar connosco pelo menos um '
                'mês, recebes um prémio de 100 €.',
            sq: 'Oferta zgjat deri në fund të shtatorit: nëse rekomandon një '
                'punonjës të ri dhe ky person qëndron me ne të paktën një '
                'muaj, merr 100 € bonus.',
          ),
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: _lt(
            de: 'Wurden Sie von jemandem geworben? Name der Person (optional)',
            en: 'Were you referred by someone? Name of the person (optional)',
            bg: 'Препоръчал ли Ви е някой? Име на лицето (по желание)',
            hu: 'Ajánlotta Önt valaki? Az illető neve (opcionális)',
            ro: 'V-a recomandat cineva? Numele persoanei (opțional)',
            pt: 'Foste recomendado por alguém? Nome da pessoa (opcional)',
            sq: 'A të rekomandoi dikush? Emri i personit (opsionale)',
          ),
          child: TextField(
            controller: _referredBy,
            textCapitalization: TextCapitalization.words,
            decoration: _input(
              _lt(
                de: 'Optional — Vor- und Nachname',
                en: 'Optional — first and last name',
                bg: 'По желание — име и фамилия',
                hu: 'Opcionális — vezeték- és keresztnév',
                ro: 'Opțional — prenume și nume',
                pt: 'Opcional — nome próprio e apelido',
                sq: 'Opsionale — emri dhe mbiemri',
              ),
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
              ? _lt(
                  de: 'Dokumente',
                  en: 'Documents',
                  bg: 'Документи',
                  hu: 'Dokumentumok',
                  ro: 'Documente',
                  pt: 'Documentos',
                  sq: 'Dokumentet',
                )
              : _vt('Dokumentet', 'Dokumente'),
        ),
        Text(
          _isLocal
              ? _lt(
                  de: 'Bitte gut sichtbar, vollständig und nicht '
                      'abgeschnitten fotografieren.',
                  en: 'Clear, complete, no shadows — nothing cut off.',
                  bg: 'Снимката да е ясна, пълна и без отрязани краища.',
                  hu: 'Jól látható, teljes kép, semmi ne legyen levágva.',
                  ro: 'Fotografie clară, completă, fără părți tăiate.',
                  pt: 'Fotografia nítida, completa, sem partes cortadas.',
                  sq: 'Foto e qartë, e plotë dhe pa pjesë të prera.',
                )
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
              ? _lt(
                  de: 'Pass / Personalausweis (Vorderseite)',
                  en: 'Passport / ID card (front)',
                  bg: 'Паспорт / лична карта (лицева страна)',
                  hu: 'Útlevél / személyi igazolvány (előlap)',
                  ro: 'Pașaport / carte de identitate (față)',
                  pt: 'Passaporte / cartão de identidade (frente)',
                  sq: 'Pasaporta / letërnjoftimi (faqja e përparme)',
                )
              : 'Pass / Personalausweis (Vorderseite)',
          subtitle: _isLocal
              ? _lt(
                  de: 'Vorderseite von Pass oder Personalausweis',
                  en: 'Front side of passport or ID card',
                  bg: 'Лицева страна на паспорта или личната карта',
                  hu: 'Az útlevél vagy igazolvány elülső oldala',
                  ro: 'Fața pașaportului sau a cărții de identitate',
                  pt: 'Frente do passaporte ou do cartão de identidade',
                  sq: 'Faqja e përparme e pasaportës ose e letërnjoftimit',
                )
              : _vt('Faqja e parë', 'Vorderseite'),
          icon: Icons.badge_outlined,
          file: _passport,
          onPick: () => _pickDocument('passport'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: _isLocal
              ? _lt(
                  de: 'Personalausweis (Rückseite)',
                  en: 'ID card (back)',
                  bg: 'Лична карта (гръб)',
                  hu: 'Személyi igazolvány (hátlap)',
                  ro: 'Carte de identitate (verso)',
                  pt: 'Cartão de identidade (verso)',
                  sq: 'Letërnjoftimi (faqja e pasme)',
                )
              : _vt('Karta e identitetit (Pjesa e prapme)',
                  'Personalausweis (Rückseite)'),
          subtitle: _isLocal
              ? _lt(
                  de: 'Rückseite des Personalausweises',
                  en: 'Back side of your ID card',
                  bg: 'Гърбът на личната карта',
                  hu: 'A személyi igazolvány hátoldala',
                  ro: 'Versoul cărții de identitate',
                  pt: 'Verso do cartão de identidade',
                  sq: 'Faqja e pasme e letërnjoftimit',
                )
              : _vt('Faqja e prapme e kartës', 'Rückseite'),
          icon: Icons.badge_outlined,
          file: _idBack,
          onPick: () => _pickDocument('id_back'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: _isLocal
              ? _lt(
                  de: 'Selfie für den Driver-Badge',
                  en: 'Selfie for the driver badge',
                  bg: 'Селфи за баджа на шофьора',
                  hu: 'Szelfi a sofőrkártyához',
                  ro: 'Selfie pentru ecusonul de șofer',
                  pt: 'Selfie para o crachá de motorista',
                  sq: 'Selfie për distinktivin e shoferit',
                )
              : _vt('Selfie për Driver-Badge', 'Selfie für Driver-Badge'),
          subtitle: _isLocal
              ? _lt(
                  de: 'Weißer Hintergrund, Kopf gerade, keine Sonnenbrille',
                  en: 'Plain white background, head straight, no sunglasses',
                  bg: 'Бял фон, изправена глава, без слънчеви очила',
                  hu: 'Fehér háttér, egyenes fejtartás, napszemüveg nélkül',
                  ro: 'Fundal alb, capul drept, fără ochelari de soare',
                  pt: 'Fundo branco, cabeça direita, sem óculos de sol',
                  sq: 'Sfond i bardhë, koka drejt, pa syze dielli',
                )
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
                      ? _lt(
                          de: 'Bitte den Führerschein gerade von oben in '
                              'guter Qualität fotografieren. Der gesamte '
                              'Führerschein muss zu sehen sein.',
                          en: "Photograph the driver's licence straight from "
                              'above, in high quality. The whole card must '
                              'be visible.',
                          bg: 'Моля, снимайте шофьорската книжка право '
                              'отгоре и с добро качество. Цялата книжка '
                              'трябва да се вижда.',
                          hu: 'Kérjük, a jogosítványt egyenesen felülről, jó '
                              'minőségben fényképezze le. A teljes '
                              'kártyának látszania kell.',
                          ro: 'Vă rugăm să fotografiați permisul de '
                              'conducere drept de sus, la o calitate bună. '
                              'Întregul permis trebuie să fie vizibil.',
                          pt: 'Fotografa a carta de condução de cima e a '
                              'direito, com boa qualidade. A carta tem de '
                              'estar toda visível.',
                          sq: 'Fotografo patentën drejt nga lart, me cilësi '
                              'të mirë. E gjithë patenta duhet të duket.',
                        )
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
              ? _lt(
                  de: 'Führerschein (Vorderseite)',
                  en: "Driver's licence (front)",
                  bg: 'Шофьорска книжка (лицева страна)',
                  hu: 'Jogosítvány (előlap)',
                  ro: 'Permis de conducere (față)',
                  pt: 'Carta de condução (frente)',
                  sq: 'Patenta e shoferit (faqja e përparme)',
                )
              : _vt('Patenta', 'Führerschein (Vorderseite)'),
          subtitle: _isLocal
              ? _lt(
                  de: 'Vorderseite',
                  en: 'Front side',
                  bg: 'Лицева страна',
                  hu: 'Elülső oldal',
                  ro: 'Fața',
                  pt: 'Frente',
                  sq: 'Faqja e përparme',
                )
              : _vt('Pjesa e parë', 'Vorderseite'),
          icon: Icons.credit_card_rounded,
          file: _licenseFront,
          onPick: () => _pickDocument('license_front'),
        ),
        const SizedBox(height: 10),
        _UploadCard(
          title: _isLocal
              ? _lt(
                  de: 'Führerschein (Rückseite)',
                  en: "Driver's licence (back)",
                  bg: 'Шофьорска книжка (гръб)',
                  hu: 'Jogosítvány (hátlap)',
                  ro: 'Permis de conducere (verso)',
                  pt: 'Carta de condução (verso)',
                  sq: 'Patenta e shoferit (faqja e pasme)',
                )
              : _vt('Patenta', 'Führerschein (Rückseite)'),
          subtitle: _isLocal
              ? _lt(
                  de: 'Rückseite',
                  en: 'Back side',
                  bg: 'Гръб',
                  hu: 'Hátoldal',
                  ro: 'Verso',
                  pt: 'Verso',
                  sq: 'Faqja e pasme',
                )
              : _vt('Pjesa e prapme', 'Rückseite'),
          icon: Icons.credit_card_outlined,
          file: _licenseBack,
          onPick: () => _pickDocument('license_back'),
        ),
        const SizedBox(height: 18),
        _DsgvoConsent(
          isLocal: _isLocal,
          lang: _localLang ?? 'de',
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
            label: _isLocal
                ? _lt(
                    de: 'Zurück',
                    en: 'Back',
                    bg: 'Назад',
                    hu: 'Vissza',
                    ro: 'Înapoi',
                    pt: 'Voltar',
                    sq: 'Prapa',
                  )
                : 'Back',
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
              ? (_isLocal
                  ? _lt(
                      de: 'Senden',
                      en: 'Submit',
                      bg: 'Изпрати',
                      hu: 'Elküldés',
                      ro: 'Trimite',
                      pt: 'Enviar',
                      sq: 'Dërgo',
                    )
                  : _vt('Dërgo', 'Senden'))
              : (_isLocal
                  ? _lt(
                      de: 'Weiter',
                      en: 'Next',
                      bg: 'Напред',
                      hu: 'Tovább',
                      ro: 'Continuă',
                      pt: 'Seguinte',
                      sq: 'Vazhdo',
                    )
                  : _vt('Vazhdo', 'Weiter')),
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
              _isLocal
                  ? _lt(
                      de: 'Danke für deine Bewerbung!',
                      en: 'Thank you for your application!',
                      bg: 'Благодарим за кандидатурата ти!',
                      hu: 'Köszönjük a jelentkezésed!',
                      ro: 'Îți mulțumim pentru candidatură!',
                      pt: 'Obrigado pela tua candidatura!',
                      sq: 'Faleminderit për aplikimin tënd!',
                    )
                  : _vt('Faleminderit për aplikimin!',
                      'Danke für deine Bewerbung!'),
              style: AppTypography.title2.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _isLocal
                  ? _lt(
                      de: 'Deine Bewerbung wurde übermittelt. Wir melden '
                          'uns in wenigen Tagen bei dir für die nächsten '
                          'Schritte.',
                      en: 'Your application has been submitted. We will '
                          'get back to you within a few days with the '
                          'next steps.',
                      bg: 'Кандидатурата ти беше изпратена. Ще се свържем '
                          'с теб до няколко дни за следващите стъпки.',
                      hu: 'Jelentkezésedet elküldtük. Néhány napon belül '
                          'jelentkezünk nálad a következő lépésekkel.',
                      ro: 'Candidatura ta a fost trimisă. Te vom contacta '
                          'în câteva zile cu următorii pași.',
                      pt: 'A tua candidatura foi enviada. Entraremos em '
                          'contacto contigo dentro de poucos dias com os '
                          'próximos passos.',
                      sq: 'Aplikimi yt u dërgua. Do të të kontaktojmë brenda '
                          'pak ditësh për hapat e ardhshëm.',
                    )
                  : _vt(
                      'Aplikimi yt u dërgua. Do të të kontaktojmë brenda '
                          'pak ditësh për hapat e ardhshëm.',
                      'Deine Bewerbung wurde übermittelt. Wir melden uns '
                          'in wenigen Tagen bei dir für die nächsten '
                          'Schritte.'),
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
    this.answerHint = 'Type your answer',
    this.yesLabel = 'Yes · Ja',
    this.noLabel = 'No · Nein',
  });

  final RecruitingCustomField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  /// Frame UI around the DSP's own question text — localised in the
  /// Local/EU channel, unchanged (combined DE/EN) in the Visa channel.
  final String answerHint;
  final String yesLabel;
  final String noLabel;

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
          decoration: _customInput(answerHint),
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
          decoration: _customInput(answerHint),
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
                title: yesLabel,
                subtitle: '',
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RadioCard(
                selected: value == false,
                title: noLabel,
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
    this.placeholder = 'Choose a date',
    this.initialDate,
  });

  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPick;
  final String placeholder;

  /// Where the calendar opens when nothing is picked yet. Defaults to
  /// 01.01.2000 (birth-date friendly).
  final DateTime? initialDate;

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
          initialDate: value ?? initialDate ?? DateTime(2000, 1, 1),
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
    this.cancelLabel = 'Cancel',
    this.doneLabel = 'Done',
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onPick;
  final String placeholder;
  final String cancelLabel;
  final String doneLabel;

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
                        label: cancelLabel,
                        variant: CoButtonVariant.quiet,
                      ),
                      const Spacer(),
                      CoButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(picked),
                        label: doneLabel,
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
    this.lang = 'de',
  });

  final bool isLocal;

  /// Selected language of the Local/EU form ('de' | 'en' | 'bg' | 'hu' |
  /// 'ro' | 'pt' | 'sq'). Ignored in the Visa channel, which keeps its
  /// Albanian text.
  final String lang;
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

    final infoBg =
        '$companyOther е администратор на обработката на Вашите данни. '
        'Данните и качените документи се обработват единствено за '
        'разглеждане на кандидатурата Ви и за създаване и изпълнение на '
        'евентуално трудово правоотношение (чл. 6, § 1, б. „б" ОРЗД; '
        'снимката/селфито за баджа на шофьора — на основание Вашето '
        'съгласие, чл. 6, § 1, б. „а" ОРЗД). Всички данни се съхраняват '
        'сигурно на сървъри в ЕС и не се предоставят на неоправомощени '
        'трети лица; техническата обработка се извършва от нашия обработващ '
        'CoDriver (Kreativwerk Albert Dobra). Данни се предоставят на органи '
        'само когато това се изисква по закон и се изтриват, когато вече не '
        'са необходими. Имате право на достъп, коригиране, изтриване, '
        'ограничаване и преносимост на данните, да оттеглите съгласието си '
        'по всяко време и да подадете жалба до надзорен орган.';

    final infoHu =
        'Az adatkezelő a(z) $companyOther. Adatait és a feltöltött '
        'dokumentumokat kizárólag a jelentkezés elbírálása, valamint egy '
        'esetleges munkaviszony létesítése és teljesítése céljából kezeljük '
        '(GDPR 6. cikk (1) b) pont; a sofőrkártyához készült fénykép/szelfi '
        'az Ön hozzájárulása alapján, GDPR 6. cikk (1) a) pont). Minden adat '
        'biztonságosan, EU-s szervereken kerül tárolásra, és nem adjuk át '
        'jogosulatlan harmadik feleknek; a technikai adatfeldolgozást '
        'adatfeldolgozónk, a CoDriver (Kreativwerk Albert Dobra) végzi. '
        'Hatóságok részére csak jogszabályi kötelezettség esetén adunk át '
        'adatot, és az adatokat töröljük, amint már nincs rájuk szükség. '
        'Önt megilleti a hozzáférés, helyesbítés, törlés, korlátozás és '
        'adathordozhatóság joga, hozzájárulását bármikor visszavonhatja, és '
        'panasszal élhet a felügyeleti hatóságnál.';

    final infoRo =
        '$companyOther este operatorul care prelucrează datele '
        'dumneavoastră. Datele și documentele încărcate sunt prelucrate '
        'exclusiv pentru soluționarea candidaturii și pentru stabilirea și '
        'derularea unui posibil raport de muncă (art. 6 alin. (1) lit. b '
        'GDPR; fotografia/selfie-ul pentru ecusonul de șofer în baza '
        'consimțământului dumneavoastră, art. 6 alin. (1) lit. a GDPR). '
        'Toate datele sunt stocate în siguranță pe servere din UE și nu sunt '
        'transmise unor terți neautorizați; prelucrarea tehnică este '
        'realizată de persoana noastră împuternicită CoDriver (Kreativwerk '
        'Albert Dobra). Datele sunt transmise autorităților doar când legea '
        'o impune și sunt șterse când nu mai sunt necesare. Aveți dreptul de '
        'acces, rectificare, ștergere, restricționare și portabilitate a '
        'datelor, de a vă retrage oricând consimțământul și de a depune o '
        'plângere la o autoritate de supraveghere.';

    final infoPt =
        '$companyOther é o responsável pelo tratamento dos seus dados. Os '
        'seus dados e os documentos carregados são tratados exclusivamente '
        'para a análise da sua candidatura e para o estabelecimento e a '
        'execução de uma eventual relação de trabalho (art. 6.º, n.º 1, '
        'al. b) do RGPD; a fotografia/selfie para o cartão de motorista com '
        'base no seu consentimento, art. 6.º, n.º 1, al. a) do RGPD). Todos '
        'os dados são armazenados em segurança em servidores na UE e não são '
        'partilhados com terceiros não autorizados; o tratamento técnico é '
        'realizado pelo nosso subcontratante CoDriver (Kreativwerk Albert '
        'Dobra). Os dados só são transmitidos a autoridades quando a lei o '
        'exige e são eliminados quando deixam de ser necessários. Tem o '
        'direito de acesso, retificação, apagamento, limitação e '
        'portabilidade dos dados, de retirar o consentimento a qualquer '
        'momento e de apresentar reclamação junto de uma autoridade de '
        'controlo.';

    const consentDe =
        'Ich habe die Datenschutzhinweise gelesen und willige in die '
        'Verarbeitung und sichere Speicherung meiner Daten und Dokumente zu den '
        'genannten Zwecken ein.';
    const consentEn =
        'I have read the privacy notice and consent to the processing and '
        'secure storage of my data and documents for the stated purposes.';
    const consentBg =
        'Прочетох информацията за защита на личните данни и давам съгласие '
        'за обработването и сигурното съхранение на моите данни и документи '
        'за посочените цели.';
    const consentHu =
        'Elolvastam az adatvédelmi tájékoztatót, és hozzájárulok adataim és '
        'dokumentumaim megjelölt célokból történő kezeléséhez és biztonságos '
        'tárolásához.';
    const consentRo =
        'Am citit informarea privind protecția datelor și îmi exprim '
        'consimțământul pentru prelucrarea și stocarea în siguranță a '
        'datelor și documentelor mele în scopurile menționate.';
    const consentPt =
        'Li a informação sobre proteção de dados e consinto no tratamento e '
        'no armazenamento seguro dos meus dados e documentos para os fins '
        'indicados.';
    const consentSq =
        'I kam lexuar udhëzimet e privatësisë dhe jap pëlqimin për '
        'përpunimin dhe ruajtjen e sigurt të të dhënave dhe dokumenteve të '
        'mia për qëllimet e përmendura.';

    // Local/EU: German legal text stays visible (the employer is German),
    // the second block repeats it in the language the applicant picked.
    // Visa: unchanged — German + Albanian.
    final String? infoSecondary = isLocal
        ? switch (lang) {
            'en' => infoEn,
            'bg' => infoBg,
            'hu' => infoHu,
            'ro' => infoRo,
            'pt' => infoPt,
            'sq' => infoSq,
            _ => null,
          }
        : infoSq;
    final String? consentSecondary = isLocal
        ? switch (lang) {
            'en' => consentEn,
            'bg' => consentBg,
            'hu' => consentHu,
            'ro' => consentRo,
            'pt' => consentPt,
            'sq' => consentSq,
            _ => null,
          }
        : 'I kam lexuar udhëzimet e privatësisë dhe jap pëlqimin për përpunimin '
            'dhe ruajtjen e sigurt të të dhënave dhe dokumenteve të mia për '
            'qëllimet e përmendura.';

    final title = isLocal
        ? switch (lang) {
            'en' => 'Data protection',
            'bg' => 'Защита на личните данни',
            'hu' => 'Adatvédelem',
            'ro' => 'Protecția datelor',
            'pt' => 'Proteção de dados',
            'sq' => 'Mbrojtja e të dhënave',
            _ => 'Datenschutz',
          }
        : 'Mbrojtja e të dhënave · Datenschutz';

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
                title,
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
          if (infoSecondary != null) ...[
            const SizedBox(height: 8),
            Text(
              infoSecondary,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
                        if (consentSecondary != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            consentSecondary,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
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

/// Friendly promo box at the end of the Local/EU form: 100 € referral
/// bonus if the referred person stays at least one month.
class _ReferralBonusCard extends StatelessWidget {
  const _ReferralBonusCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.codriverGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.codriverGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 22,
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
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.codriverDeep.withValues(alpha: 0.85),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
  final String label;
  const _LaterToggle({
    required this.checked,
    required this.onChanged,
    this.label = "I'll submit later · Reiche ich später nach",
  });

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
                label,
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

/// Compact toggle chip for selecting a single weekday. Multiple may be
/// active at once (multi-select availability).
class _WeekdayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _WeekdayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: 46,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
        child: Text(
          label,
          style: AppTypography.caption1.copyWith(
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.codriverGreen
                : const Color(0xFF111827),
          ),
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
