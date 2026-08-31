// lib/Screens/admin_work_contracts_page.dart
//
// Work Contracts (nur Arion Logistics — Owner-Accounts): In wenigen Klicks
// den richtigen Arbeitsvertrag als PDF erzeugen. Stammdaten kommen aus dem
// Fahrer- oder Bewerberprofil, Urlaub/Gehalt werden automatisch berechnet,
// die GF-Unterschrift ist eingedruckt. Zusätzlich: Zeitkontovereinbarung,
// Kamera-DSGVO und (bei Visum) die Erklärung zum Beschäftigungsverhältnis.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../services/work_contracts/work_contract_model.dart';
import '../services/work_contracts/work_contract_pdf.dart';
import '../widgets/admin_scope.dart';

const _kBorder = Color(0xFFE5E7EB);
const _kMuted = Color(0xFF6B7280);
const _kText = Color(0xFF111827);
const _kGreen = Color(0xFF1D7F5A);
const _kGreenBg = Color(0xFFECFDF3);
const _kOrange = Color(0xFFB45309);
const _kOrangeBg = Color(0xFFFFF7ED);

/// Nur diese Accounts sehen Work Contracts (Vorgabe: erstmal nur Arion).
const Set<String> kWorkContractOwners = {
  'admin@arion-logistics.de',
  'test@arion-logistics.de',
};

class AdminWorkContractsPage extends StatefulWidget {
  const AdminWorkContractsPage({super.key});

  @override
  State<AdminWorkContractsPage> createState() =>
      _AdminWorkContractsPageState();
}

class _AdminWorkContractsPageState extends State<AdminWorkContractsPage> {
  // Personen-Quelle
  bool _fromDrivers = true;
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _pickedLabel = '';

  // Stammdaten
  final _nameCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _zipCityCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  DateTime? _birthDate;
  DateTime? _residenceSince;
  // Standard-Geschlecht: männlich (Vorgabe Arion).
  String _gender = 'm';

  // Vertrag
  WcType _type = WcType.fulltime5;
  WcPay _pay = WcPay.monthly;
  bool _fixedTerm = true;
  // Vertragsbeginn ist standardmäßig HEUTE (Vorgabe Arion).
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final _wageCtrl = TextEditingController(text: '16,20');
  final _salaryCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '40');
  final _vacationCtrl = TextEditingController(text: '20');
  int _probation = 6;
  final _signCityCtrl = TextEditingController(text: WcEmployer.city);
  DateTime _signDate = DateTime.now();
  // EzB Frage 1: Standard ist die ERSTE Option (Aufenthaltstitel).
  String _ezbProcedure = 'aufenthaltstitel';
  String _ezbOccasion = 'ersterteilung';

  // Extra-Dokumente
  bool _withZeitkonto = true;
  bool _withCameraPrivacy = true;

  // Ergebnis
  bool _building = false;
  List<({String name, Uint8List bytes})> _results = [];
  Uint8List? _signaturePng;
  bool _signatureLoaded = false;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime(
        _startDate.year + 1, _startDate.month, _startDate.day);
    _recalcSalary();
    _loadSignature();
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim().toLowerCase();
      if (v != _search) setState(() => _search = v);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _streetCtrl.dispose();
    _zipCityCtrl.dispose();
    _nationalityCtrl.dispose();
    _wageCtrl.dispose();
    _salaryCtrl.dispose();
    _hoursCtrl.dispose();
    _vacationCtrl.dispose();
    _signCityCtrl.dispose();
    super.dispose();
  }

  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  bool get _allowed {
    final email =
        FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
    return kWorkContractOwners.contains(email);
  }

  /// GF-Unterschrift aus Firestore (nicht als öffentliches Web-Asset).
  Future<void> _loadSignature() async {
    final uid = _uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contract_assets')
          .doc('signature')
          .get();
      final b64 = (doc.data()?['png'] ?? '').toString();
      if (b64.isNotEmpty) _signaturePng = base64Decode(b64);
    } catch (_) {
      // Ohne Unterschrift wird eine leere Linie gedruckt.
    }
    if (mounted) setState(() => _signatureLoaded = true);
  }

  /// Setzt die Personenauswahl komplett zurück (nächster Vertrag).
  void _clearPerson() {
    setState(() {
      _pickedLabel = '';
      _nameCtrl.clear();
      _streetCtrl.clear();
      _zipCityCtrl.clear();
      _nationalityCtrl.clear();
      _birthDate = null;
      _residenceSince = null;
      _gender = '';
      _searchCtrl.clear();
      _results = [];
    });
  }

  double _parseNum(String s, double fallback) =>
      double.tryParse(s.replaceAll(',', '.').trim()) ?? fallback;

  double get _wage => _parseNum(_wageCtrl.text, 16.20);
  double get _hours => _parseNum(_hoursCtrl.text, 40);

  void _recalcSalary() {
    _salaryCtrl.text = wcEur(wcMonthlySalary(_wage, _hours));
  }

  void _applyTypeDefaults(WcType t) {
    setState(() {
      _type = t;
      _hoursCtrl.text = wcHours(t.defaultHoursPerWeek);
      _vacationCtrl.text = '${wcVacationDays(t, t.daysPerWeek)}';
      if (t == WcType.minijob || t == WcType.werkstudent) {
        _pay = WcPay.hourly;
      } else if (t == WcType.visa) {
        _pay = WcPay.monthly;
        // Beim Arbeitsvisum ist das einzige Extra-Dokument die EzB.
        _withZeitkonto = false;
        _withCameraPrivacy = false;
      }
      _recalcSalary();
    });
  }

  WorkContractData _collect() => WorkContractData(
        type: _type,
        pay: _pay,
        fixedTerm: _fixedTerm,
        employeeName: _nameCtrl.text.trim(),
        employeeStreet: _streetCtrl.text.trim(),
        employeeZipCity: _zipCityCtrl.text.trim(),
        birthDate: _birthDate,
        nationality: _nationalityCtrl.text.trim(),
        residenceSince: _residenceSince,
        gender: _gender,
        startDate: _startDate,
        endDate: _fixedTerm ? _endDate : null,
        hourlyWage: _wage,
        monthlySalary: _parseNum(_salaryCtrl.text, 0),
        hoursPerWeek: _hours,
        vacationDays: int.tryParse(_vacationCtrl.text.trim()) ?? 20,
        probationMonths: _probation,
        signCity: _signCityCtrl.text.trim().isEmpty
            ? WcEmployer.city
            : _signCityCtrl.text.trim(),
        signDate: _signDate,
        ezbProcedure: _ezbProcedure,
        ezbOccasion: _ezbOccasion,
      );

  Future<void> _generate() async {
    final de = _de;
    if (_nameCtrl.text.trim().isEmpty) {
      _snack(de ? 'Bitte zuerst eine Person wählen.' : 'Pick a person first.',
          error: true);
      return;
    }
    setState(() {
      _building = true;
      _results = [];
    });
    try {
      final d = _collect();
      final assets = await wcLoadAssets(signaturePng: _signaturePng);
      final slug = d.employeeName
          .replaceAll(RegExp(r'[^A-Za-z0-9ÄÖÜäöüß ]'), '')
          .replaceAll(' ', '_');
      final out = <({String name, Uint8List bytes})>[];
      out.add((
        name: 'Arbeitsvertrag_$slug.pdf',
        bytes: await wcBuildContractPdf(d, assets),
      ));
      if (_withZeitkonto) {
        out.add((
          name: 'Zeitkontovereinbarung_$slug.pdf',
          bytes: await wcBuildZeitkontoPdf(d, assets),
        ));
      }
      if (_withCameraPrivacy) {
        out.add((
          name: 'Datenschutz_Kamera_$slug.pdf',
          bytes: await wcBuildCameraPrivacyPdf(d, assets),
        ));
      }
      if (d.isVisa) {
        // Beim Arbeitsvisum ist das einzige Extra-Dokument die EzB —
        // das Original-BA-Formular (ba047549), automatisch ausgefüllt.
        out.add((
          name: 'Erklaerung_Beschaeftigungsverhaeltnis_$slug.pdf',
          bytes: await wcFillEzbOriginalPdf(d, _signaturePng),
        ));
      }
      setState(() => _results = out);
    } catch (e) {
      _snack(_de ? 'Fehler: $e' : 'Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? const Color(0xFFB91C1C) : null,
      content: Text(msg),
    ));
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
    DateTime? first,
    DateTime? last,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime(1940),
      lastDate: last ?? DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final de = _de;
    if (!_allowed) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Center(
          child: Text(
            de
                ? 'Work Contracts ist für diesen Account nicht freigeschaltet.'
                : 'Work Contracts is not enabled for this account.',
            style: const TextStyle(fontSize: 14, color: _kMuted),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _header(),
                const SizedBox(height: 12),
                _personCard(),
                const SizedBox(height: 12),
                _contractCard(),
                const SizedBox(height: 12),
                _extrasCard(),
                const SizedBox(height: 12),
                _generateCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: child,
      );

  Widget _header() {
    final de = _de;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.history_edu_rounded, color: _kGreen, size: 22),
            const SizedBox(width: 8),
            const Text('Work Contracts',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: _kText)),
            const Spacer(),
            if (_signatureLoaded && _signaturePng == null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kOrangeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  de ? 'Unterschrift fehlt' : 'Signature missing',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kOrange),
                ),
              ),
          ]),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Vertragsart wählen, Person aus Fahrer- oder Bewerberprofil '
                    'übernehmen, PDF drucken — Urlaub und Gehalt werden '
                    'automatisch berechnet, deine Unterschrift ist eingedruckt.'
                : 'Pick a contract type, pull the person from a driver or '
                    'applicant profile, print the PDF — vacation and salary '
                    'are calculated automatically with your signature '
                    'embedded.',
            style: const TextStyle(fontSize: 13, color: _kMuted),
          ),
        ],
      ),
    );
  }

  // ── Person ────────────────────────────────────────────────────────────

  Widget _personCard() {
    final de = _de;
    final uid = _uid;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(de ? '1 · Person' : '1 · Person',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _kText)),
          const SizedBox(height: 10),
          Row(children: [
            _choicePill(de ? 'Fahrer' : 'Drivers', _fromDrivers,
                () => setState(() => _fromDrivers = true)),
            const SizedBox(width: 8),
            _choicePill(de ? 'Bewerber' : 'Applicants', !_fromDrivers,
                () => setState(() => _fromDrivers = false)),
            const SizedBox(width: 12),
            if (_pickedLabel.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGreenBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text('✓ $_pickedLabel',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kGreen)),
                      ),
                      const SizedBox(width: 4),
                      // Auswahl aufheben — alle Personen-Felder leeren, um
                      // direkt den nächsten Vertrag zu machen.
                      InkWell(
                        onTap: _clearPerson,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(Icons.close_rounded,
                              size: 15, color: _kGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 10),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 18, color: _kMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: _kFieldValueStyle,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: de ? 'Name suchen …' : 'Search name …',
                      hintStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB6BCC6)),
                    ),
                  ),
                ),
                if (_search.isNotEmpty)
                  InkWell(
                    onTap: _searchCtrl.clear,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: _kMuted),
                    ),
                  ),
              ],
            ),
          ),
          if (_search.length >= 2 && uid != null)
            _fromDrivers ? _driverResults(uid) : _applicantResults(uid),
          const Divider(height: 28, color: _kBorder),
          // Manuell nachbearbeitbare Stammdaten — einheitliches Raster.
          _groupLabel(de ? 'Stammdaten' : 'Personal data'),
          _fieldGrid([
            _textField(_nameCtrl, de ? 'Vorname, Nachname' : 'Full name'),
            _textField(_streetCtrl, de ? 'Straße, Hausnr.' : 'Street, no.'),
            _textField(_zipCityCtrl, de ? 'PLZ, Ort' : 'ZIP, city'),
            _dateField(
              de ? 'Geburtsdatum' : 'Birth date',
              _birthDate,
              (v) => setState(() => _birthDate = v),
            ),
            if (_type == WcType.visa) ...[
              _textField(_nationalityCtrl,
                  de ? 'Staatsangehörigkeit' : 'Nationality'),
              _dateField(
                de ? 'Wohnsitz seit' : 'Residence since',
                _residenceSince,
                (v) => setState(() => _residenceSince = v),
              ),
              _dropdown<String>(
                label: de ? 'Geschlecht' : 'Gender',
                value: _gender.isEmpty ? null : _gender,
                items: {
                  'm': de ? 'männlich' : 'male',
                  'w': de ? 'weiblich' : 'female',
                  'd': 'divers',
                },
                onChanged: (v) => setState(() => _gender = v ?? ''),
              ),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _driverResults(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('drivers')
          .snapshots(),
      builder: (context, snap) {
        final docs = (snap.data?.docs ?? const [])
            .where((d) => (d.data()['driverName'] ?? '')
                .toString()
                .toLowerCase()
                .contains(_search))
            .take(6)
            .toList();
        return _resultList([
          for (final doc in docs)
            (
              label:
                  '${doc.data()['driverName'] ?? doc.id} · ${doc.id}',
              onTap: () {
                final data = doc.data();
                setState(() {
                  _pickedLabel = (data['driverName'] ?? doc.id).toString();
                  _nameCtrl.text = _pickedLabel;
                  _streetCtrl.text = (data['street'] ?? '').toString();
                  final zip = (data['postalCode'] ?? '').toString();
                  final city = (data['city'] ?? '').toString();
                  _zipCityCtrl.text = '$zip $city'.trim();
                  _birthDate = (data['birthDate'] is Timestamp)
                      ? (data['birthDate'] as Timestamp).toDate()
                      : _birthDate;
                  _nationalityCtrl.text =
                      (data['nationality'] ?? '').toString();
                  _residenceSince = (data['livingHereSince'] is Timestamp)
                      ? (data['livingHereSince'] as Timestamp).toDate()
                      : _residenceSince;
                  _searchCtrl.clear();
                });
              }
            ),
        ]);
      },
    );
  }

  Widget _applicantResults(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recruiting_applications')
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _de
                  ? 'Bewerber konnten nicht geladen werden: ${snap.error}'
                  : 'Could not load applicants: ${snap.error}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
            ),
          );
        }
        if (!snap.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_de ? 'Lade Bewerber …' : 'Loading applicants …',
                style: const TextStyle(fontSize: 12.5, color: _kMuted)),
          );
        }
        final docs = (snap.data?.docs ?? const []).where((d) {
          final m = d.data();
          final name =
              '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.toLowerCase();
          return name.contains(_search);
        }).take(6).toList();
        return _resultList([
          for (final doc in docs)
            (
              label:
                  '${doc.data()['firstName'] ?? ''} ${doc.data()['lastName'] ?? ''}'
                      .trim(),
              onTap: () {
                final data = doc.data();
                setState(() {
                  _pickedLabel =
                      '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                          .trim();
                  _nameCtrl.text = _pickedLabel;
                  _streetCtrl.text = (data['street'] ?? '').toString();
                  final zip = (data['postalCode'] ?? '').toString();
                  final city = (data['city'] ?? '').toString();
                  _zipCityCtrl.text = '$zip $city'.trim();
                  _birthDate = (data['birthDate'] is Timestamp)
                      ? (data['birthDate'] as Timestamp).toDate()
                      : _birthDate;
                  _nationalityCtrl.text =
                      (data['nationality'] ?? '').toString();
                  _residenceSince = (data['livingHereSince'] is Timestamp)
                      ? (data['livingHereSince'] as Timestamp).toDate()
                      : _residenceSince;
                  _searchCtrl.clear();
                });
              }
            ),
        ]);
      },
    );
  }

  Widget _resultList(List<({String label, VoidCallback onTap})> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(_de ? 'Keine Treffer.' : 'No matches.',
            style: const TextStyle(fontSize: 12.5, color: _kMuted)),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        for (var i = 0; i < items.length; i++)
          InkWell(
            onTap: items[i].onTap,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: i.isOdd ? const Color(0xFFF8FAFC) : Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(12) : Radius.zero,
                  bottom: i == items.length - 1
                      ? const Radius.circular(12)
                      : Radius.zero,
                ),
              ),
              child: Text(items[i].label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kText)),
            ),
          ),
      ]),
    );
  }

  // ── Vertrag ───────────────────────────────────────────────────────────

  Widget _contractCard() {
    final de = _de;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(de ? '2 · Vertrag' : '2 · Contract',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _kText)),
          const SizedBox(height: 14),
          _groupLabel(de ? 'Vertragstyp' : 'Contract type'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in WcType.values)
              _choicePill(de ? t.labelDe() : t.labelEn(), _type == t,
                  () => _applyTypeDefaults(t)),
          ]),
          const SizedBox(height: 16),
          _groupLabel(de ? 'Vergütung & Laufzeit' : 'Pay & term'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _choicePill(
                de ? 'Festvertrag (Monatsgehalt)' : 'Fixed (monthly salary)',
                _pay == WcPay.monthly, () {
              setState(() => _pay = WcPay.monthly);
            }),
            _choicePill(
                de ? 'Stundenvertrag (Stundenlohn)' : 'Hourly contract',
                _pay == WcPay.hourly, () {
              setState(() => _pay = WcPay.hourly);
            }),
            const SizedBox(width: 16, height: 36),
            _choicePill(de ? 'Befristet (1 Jahr)' : 'Fixed term (1 year)',
                _fixedTerm, () {
              setState(() => _fixedTerm = true);
            }),
            _choicePill(de ? 'Unbefristet' : 'Permanent', !_fixedTerm, () {
              setState(() => _fixedTerm = false);
            }),
          ]),
          const Divider(height: 32, color: _kBorder),
          _groupLabel(de ? 'Eckdaten' : 'Key data'),
          _fieldGrid([
            _dateField(
              de ? 'Vertragsbeginn' : 'Start date',
              _startDate,
              (v) => setState(() {
                _startDate = v;
                _endDate = DateTime(v.year + 1, v.month, v.day);
              }),
            ),
            if (_fixedTerm)
              _dateField(
                de ? 'Befristet bis' : 'Fixed term until',
                _endDate,
                (v) => setState(() => _endDate = v),
              ),
            _dateField(
              de ? 'Vertragsdatum (Unterschrift)' : 'Contract date',
              _signDate,
              (v) => setState(() => _signDate = v),
            ),
            _numField(_wageCtrl, de ? 'Stundenlohn (€)' : 'Hourly wage (€)',
                onChanged: (_) => setState(_recalcSalary)),
            _numField(_hoursCtrl, de ? 'Stunden / Woche' : 'Hours / week',
                onChanged: (_) => setState(_recalcSalary)),
            if (_pay == WcPay.monthly)
              _numField(_salaryCtrl,
                  de ? 'Gehalt / Monat (€, auto)' : 'Salary / month (€)'),
            _numField(_vacationCtrl,
                de ? 'Urlaubstage (auto)' : 'Vacation days (auto)'),
            _dropdown<int>(
              label: de ? 'Probezeit' : 'Probation',
              value: _probation,
              items: {
                3: de ? '3 Monate' : '3 months',
                6: de ? '6 Monate' : '6 months'
              },
              onChanged: (v) => setState(() => _probation = v ?? 6),
            ),
            _textField(
                _signCityCtrl, de ? 'Ort (Unterschrift)' : 'City (signature)'),
          ]),
          if (_type == WcType.visa) ...[
            const Divider(height: 32, color: _kBorder),
            _groupLabel(de
                ? 'Erklärung zum Beschäftigungsverhältnis (EzB)'
                : 'Employment declaration (EzB)'),
            _fieldGrid([
              _dropdown<String>(
                label: de ? 'Verfahren' : 'Procedure',
                value: _ezbProcedure,
                items: {
                  'aufenthaltstitel':
                      de ? 'Aufenthaltstitel' : 'Residence permit',
                  'vorabzustimmung':
                      de ? 'Vorabzustimmung BA' : 'BA pre-approval',
                  'arbeitserlaubnis':
                      de ? 'Arbeitserlaubnis BA' : 'BA work permit',
                },
                onChanged: (v) =>
                    setState(() => _ezbProcedure = v ?? 'aufenthaltstitel'),
              ),
              _dropdown<String>(
                label: de ? 'Anlass' : 'Occasion',
                value: _ezbOccasion,
                items: {
                  'ersterteilung': de ? 'Ersterteilung' : 'First issue',
                  'verlaengerung': de ? 'Verlängerung' : 'Extension',
                  'wechsel':
                      de ? 'Arbeitgeberwechsel' : 'Employer change',
                },
                onChanged: (v) =>
                    setState(() => _ezbOccasion = v ?? 'ersterteilung'),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  // ── Extras ────────────────────────────────────────────────────────────

  Widget _extrasCard() {
    final de = _de;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(de ? '3 · Extra-Dokumente' : '3 · Extra documents',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _kText)),
          const SizedBox(height: 6),
          _checkTile(
            de ? 'Zeitkontovereinbarung' : 'Working time account agreement',
            de
                ? 'Ergänzungsvereinbarung Arbeitszeitkonto (Ogletree-Vorlage) '
                    'als eigenes PDF.'
                : 'Supplementary working-time-account agreement as its own '
                    'PDF.',
            _withZeitkonto,
            (v) => setState(() => _withZeitkonto = v),
          ),
          _checkTile(
            de
                ? 'DSGVO Innenraumkamera (Verkehrssicherheit)'
                : 'GDPR in-cab camera (road safety)',
            de
                ? 'Datenschutzerklärung Verkehrssicherheitstechnologien mit '
                    'Empfangsbestätigung als eigenes PDF.'
                : 'Road-safety camera privacy notice with acknowledgement '
                    'block as its own PDF.',
            _withCameraPrivacy,
            (v) => setState(() => _withCameraPrivacy = v),
          ),
          if (_type == WcType.visa)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const Icon(Icons.attach_file_rounded,
                    size: 16, color: _kGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    de
                        ? 'Beim Arbeitsvisum wird die „Erklärung zum '
                            'Beschäftigungsverhältnis“ (inkl. '
                            'Führerschein-Bestätigung) automatisch erzeugt.'
                        : 'For work-visa contracts the employment '
                            'declaration (incl. licence letter) is generated '
                            'automatically.',
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  // ── Erzeugen ──────────────────────────────────────────────────────────

  Widget _generateCard() {
    final de = _de;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _building ? null : _generate,
                style: FilledButton.styleFrom(
                  backgroundColor: _kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _building
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: Text(
                  _building
                      ? (de ? 'Erzeuge PDFs …' : 'Building PDFs …')
                      : (de ? 'Verträge erzeugen' : 'Generate contracts'),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ]),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final r in _results)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.description_outlined,
                      size: 18, color: _kGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kText)),
                  ),
                  SizedBox(
                    height: 34,
                    width: 108,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Printing.layoutPdf(onLayout: (_) async => r.bytes),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kGreen,
                        side: const BorderSide(color: _kGreen),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.print_rounded, size: 15),
                      label: Text(de ? 'Drucken' : 'Print',
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 34,
                    width: 108,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Printing.sharePdf(bytes: r.bytes, filename: r.name),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kText,
                        side: const BorderSide(color: _kBorder),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 15),
                      label: const Text('PDF',
                          style: TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
          ],
        ],
      ),
    );
  }

  // ── Kleine Form-Helfer ────────────────────────────────────────────────

  /// Einheitliche Feldhöhe — alle Eingaben (Text, Zahl, Datum, Dropdown)
  /// sitzen in derselben Box, damit nichts springt oder überlappt.
  static const double _kFieldHeight = 58;

  /// Gleich breite Feld-Spalten: 3 auf breiten, 2 auf mittleren, 1 auf
  /// schmalen Screens — jede Zelle exakt gleich groß.
  Widget _fieldGrid(List<Widget> fields) => LayoutBuilder(
        builder: (context, c) {
          const gap = 12.0;
          final cols = c.maxWidth >= 700 ? 3 : (c.maxWidth >= 460 ? 2 : 1);
          final w = (c.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final f in fields) SizedBox(width: w, child: f),
            ],
          );
        },
      );

  /// Kleine Gruppen-Überschrift über Pill-Reihen und Feld-Rastern.
  Widget _groupLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: _kMuted,
            letterSpacing: 0.6,
          ),
        ),
      );

  /// Gemeinsame Hülle aller Felder: Rahmen, festes Maß, Label oben.
  Widget _fieldShell({
    required String label,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final box = Container(
      height: _kFieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: _kMuted)),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
    if (onTap == null) return box;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: box,
    );
  }

  static const _kFieldValueStyle = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: _kText,
  );

  Widget _choicePill(String label, bool active, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? _kGreen : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? _kGreen : _kBorder),
          ),
          // widthFactor: 1 → Pill bleibt so breit wie ihr Text (Container
          // mit alignment würde sich sonst auf volle Breite dehnen).
          child: Center(
            widthFactor: 1,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _kText)),
          ),
        ),
      );

  Widget _textField(TextEditingController ctrl, String label,
          {TextInputType? keyboardType, ValueChanged<String>? onChanged}) =>
      _fieldShell(
        label: label,
        child: SizedBox(
          height: 20,
          child: TextField(
            controller: ctrl,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: _kFieldValueStyle,
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: '—',
              hintStyle: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB6BCC6)),
            ),
          ),
        ),
      );

  Widget _numField(TextEditingController ctrl, String label,
          {ValueChanged<String>? onChanged}) =>
      _textField(
        ctrl,
        label,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
      );

  Widget _dateField(
          String label, DateTime? value, ValueChanged<DateTime> onPicked) =>
      _fieldShell(
        label: label,
        onTap: () =>
            _pickDate(initial: value ?? DateTime.now(), onPicked: onPicked),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null ? '—' : wcDate(value),
                style: _kFieldValueStyle,
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 14, color: _kMuted),
          ],
        ),
      );

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) =>
      _fieldShell(
        label: label,
        child: SizedBox(
          height: 20,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              style: _kFieldValueStyle,
              hint: const Text('—',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB6BCC6))),
              icon: const Icon(Icons.expand_more_rounded,
                  size: 16, color: _kMuted),
              items: [
                for (final e in items.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      );

  Widget _checkTile(
          String title, String sub, bool value, ValueChanged<bool> onChanged) =>
      InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(
              value
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 20,
              color: value ? _kGreen : _kMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _kText)),
                  Text(sub,
                      style:
                          const TextStyle(fontSize: 12, color: _kMuted)),
                ],
              ),
            ),
          ]),
        ),
      );
}
