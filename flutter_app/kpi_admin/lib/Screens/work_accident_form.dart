// lib/Screens/work_accident_form.dart
//
// "Mitarbeiter" tab of the Incident Report — a work-accident questionnaire
// (Arbeitsunfall / BG-Verkehr Unfallanzeige). Fillable by the driver (their
// own) and by the admin (for a chosen driver). Prefilled from the driver's
// profile (top-level + onboarding fields). Stored in the same
// `incident_reports` collection with type: 'work_accident', so the admin
// incident view lists it alongside vehicle reports — there, each value gets
// a copy button for transfer into the BG-Verkehr portal.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const _kAccent = Color(0xFF00B287);
const _kDeep = Color(0xFF0B6B53);
const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);

class WorkAccidentForm extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final bool isAdminMode;
  final VoidCallback? onSubmitted;

  const WorkAccidentForm({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    this.isAdminMode = false,
    this.onSubmitted,
  });

  @override
  State<WorkAccidentForm> createState() => _WorkAccidentFormState();
}

class _WorkAccidentFormState extends State<WorkAccidentForm> {
  bool _loading = true;
  bool _submitting = false;

  // ── Text controllers (everything is stored as text the admin can copy) ──
  final _arbeitsstelle = TextEditingController(text: 'Im o. g. Unternehmen');
  final _ansprechName = TextEditingController();
  final _ansprechPhone = TextEditingController();

  final _taetigkeit = TextEditingController();
  final _beschaeftigungsbeginn = TextEditingController();
  final _taetigkeitsumfeld = TextEditingController();

  final _fullName = TextEditingController();
  final _strasse = TextEditingController();
  final _land = TextEditingController(text: 'Deutschland');
  final _plz = TextEditingController();
  final _ort = TextEditingController();
  final _geburtsdatum = TextEditingController();
  final _staatsangehoerigkeit = TextEditingController();
  final _telefon = TextEditingController();
  final _arbeitsverhaeltnis = TextEditingController(text: 'Arbeitnehmer/-in');
  final _entgeltfortzahlung = TextEditingController();
  final _krankenkasse = TextEditingController();

  final _unfallzeitpunkt = TextEditingController();
  final _unfallort = TextEditingController();
  final _naehereOrt = TextEditingController();
  final _unfallhergang = TextEditingController();
  final _schilderung = TextEditingController(text: 'des Versicherten');
  final _zeuge = TextEditingController();

  final _unterbrechungZeit = TextEditingController();
  final _arbeitszeitBeginn = TextEditingController();
  final _arbeitszeitEnde = TextEditingController();
  final _verletzteKoerperteile = TextEditingController();
  final _artVerletzung = TextEditingController();
  final _erstbehandlung =
      TextEditingController(text: 'Ärztliche Behandlung bei:');
  final _behandelnderArzt = TextEditingController();

  final _betriebsrat = TextEditingController();
  final _unternehmer = TextEditingController();

  // ── Yes/No + choice state ──
  String _geschlecht = '';
  bool? _auszubildende = false;
  bool? _geringfuegig = false;
  bool? _leiharbeit = false;
  bool? _maschinenunfall = false;
  bool? _gewaltereignis = false;
  bool? _augenzeuge = false;
  bool? _toedlich = false;
  bool? _arbeitsunterbrechung;
  bool? _wiederaufnahme;
  bool? _weiterleitungGewerbeaufsicht = false;
  bool _bestaetigt = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    for (final c in [
      _arbeitsstelle, _ansprechName, _ansprechPhone, _taetigkeit,
      _beschaeftigungsbeginn, _taetigkeitsumfeld, _fullName, _strasse, _land,
      _plz, _ort, _geburtsdatum, _staatsangehoerigkeit, _telefon,
      _arbeitsverhaeltnis, _entgeltfortzahlung, _krankenkasse, _unfallzeitpunkt,
      _unfallort, _naehereOrt, _unfallhergang, _schilderung, _zeuge,
      _unterbrechungZeit, _arbeitszeitBeginn, _arbeitszeitEnde,
      _verletzteKoerperteile, _artVerletzung, _erstbehandlung,
      _behandelnderArzt, _betriebsrat, _unternehmer,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _s(dynamic v) => (v ?? '').toString().trim();

  String _firstNonEmpty(List<String> xs) =>
      xs.firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');

  Future<void> _prefill() async {
    try {
      final db = FirebaseFirestore.instance;
      final dspRef = db.collection('users').doc(widget.dspUid);
      final driverSnap = await dspRef
          .collection('drivers')
          .doc(widget.driverTransporterId.toUpperCase())
          .get();
      final d = driverSnap.data() ?? const <String, dynamic>{};
      final ob = (d['onboarding'] is Map)
          ? Map<String, dynamic>.from(d['onboarding'] as Map)
          : const <String, dynamic>{};

      // Company / contact prefill from the DSP doc.
      final dspSnap = await dspRef.get();
      final dsp = dspSnap.data() ?? const <String, dynamic>{};

      if (!mounted) return;
      setState(() {
        _fullName.text = _firstNonEmpty([
          _s(d['driverName']), _s(d['fullName']), _s(d['name']),
          _s(ob['fullName']),
        ]);
        _strasse.text = _firstNonEmpty([_s(d['street']), _s(ob['address'])]);
        _plz.text = _firstNonEmpty([_s(d['postalCode']), _s(ob['postalCode'])]);
        _ort.text = _firstNonEmpty([_s(d['city']), _s(ob['city'])]);
        final country = _firstNonEmpty([_s(ob['country'])]);
        if (country.isNotEmpty) _land.text = country;
        _geburtsdatum.text =
            _firstNonEmpty([_s(d['birthDate']), _s(ob['dateOfBirth'])]);
        _staatsangehoerigkeit.text = _firstNonEmpty(
            [_s(d['nationality']), _s(ob['nationalityIdCard'])]);
        _telefon.text =
            _firstNonEmpty([_s(d['phone']), _s(ob['phone'])]);
        _krankenkasse.text = _s(ob['insuranceCompany']);
        _beschaeftigungsbeginn.text = _s(ob['workStartDate']);
        _ansprechName.text = _firstNonEmpty(
            [_s(dsp['ownerName']), _s(dsp['contactName']), _s(dsp['companyName'])]);
        _ansprechPhone.text =
            _firstNonEmpty([_s(dsp['phone']), _s(dsp['contactPhone'])]);
        _unternehmer.text = _firstNonEmpty([_s(dsp['ownerName'])]);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: error ? const Color(0xFFB91C1C) : _kDeep,
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
  }

  Future<void> _submit() async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      _snack(
          Localizations.localeOf(context).languageCode == 'de'
              ? 'Bitte erneut anmelden.'
              : 'Please sign in again.',
          error: true);
      return;
    }
    if (widget.dspUid.trim().isEmpty ||
        widget.driverTransporterId.trim().isEmpty) {
      _snack('Fahrer-Zuordnung fehlt.', error: true);
      return;
    }
    if (_unfallort.text.trim().isEmpty) {
      _snack('Bitte den Unfallort angeben.', error: true);
      return;
    }
    if (_unfallhergang.text.trim().isEmpty) {
      _snack('Bitte den Unfallhergang beschreiben.', error: true);
      return;
    }
    if (!_bestaetigt) {
      _snack('Bitte bestätige, dass alle Angaben geprüft sind.', error: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final dspRef = db.collection('users').doc(widget.dspUid);
      final rootRef = dspRef.collection('incident_reports').doc();
      final reportId = rootRef.id;

      final driverId = widget.driverTransporterId.toUpperCase();
      final driverRef = dspRef.collection('drivers').doc(driverId);
      final driverSnap = await driverRef.get();
      final dd = driverSnap.data() ?? const <String, dynamic>{};
      final driverName = _firstNonEmpty([
        _s(dd['name']), _s(dd['fullName']), _s(dd['driverName']),
        _fullName.text,
      ]);
      final driverAuthUid =
          widget.isAdminMode ? _s(dd['uid']) : auth.uid;

      String yn(bool? b) => b == null ? '' : (b ? 'ja' : 'nein');

      final wa = <String, dynamic>{
        'arbeitsstelle': _arbeitsstelle.text.trim(),
        'ansprechName': _ansprechName.text.trim(),
        'ansprechPhone': _ansprechPhone.text.trim(),
        'taetigkeit': _taetigkeit.text.trim(),
        'auszubildende': yn(_auszubildende),
        'beschaeftigungsbeginn': _beschaeftigungsbeginn.text.trim(),
        'taetigkeitsumfeld': _taetigkeitsumfeld.text.trim(),
        'geringfuegig': yn(_geringfuegig),
        'leiharbeit': yn(_leiharbeit),
        'fullName': _fullName.text.trim(),
        'strasse': _strasse.text.trim(),
        'land': _land.text.trim(),
        'plz': _plz.text.trim(),
        'ort': _ort.text.trim(),
        'geburtsdatum': _geburtsdatum.text.trim(),
        'geschlecht': _geschlecht,
        'staatsangehoerigkeit': _staatsangehoerigkeit.text.trim(),
        'telefon': _telefon.text.trim(),
        'arbeitsverhaeltnis': _arbeitsverhaeltnis.text.trim(),
        'entgeltfortzahlung': _entgeltfortzahlung.text.trim(),
        'krankenkasse': _krankenkasse.text.trim(),
        'unfallzeitpunkt': _unfallzeitpunkt.text.trim(),
        'unfallort': _unfallort.text.trim(),
        'naehereOrt': _naehereOrt.text.trim(),
        'maschinenunfall': yn(_maschinenunfall),
        'unfallhergang': _unfallhergang.text.trim(),
        'schilderung': _schilderung.text.trim(),
        'gewaltereignis': yn(_gewaltereignis),
        'zeuge': _zeuge.text.trim(),
        'augenzeuge': yn(_augenzeuge),
        'toedlich': yn(_toedlich),
        'arbeitsunterbrechung': yn(_arbeitsunterbrechung),
        'unterbrechungZeit': _unterbrechungZeit.text.trim(),
        'wiederaufnahme': yn(_wiederaufnahme),
        'arbeitszeitBeginn': _arbeitszeitBeginn.text.trim(),
        'arbeitszeitEnde': _arbeitszeitEnde.text.trim(),
        'verletzteKoerperteile': _verletzteKoerperteile.text.trim(),
        'artVerletzung': _artVerletzung.text.trim(),
        'erstbehandlung': _erstbehandlung.text.trim(),
        'behandelnderArzt': _behandelnderArzt.text.trim(),
        'betriebsrat': _betriebsrat.text.trim(),
        'unternehmer': _unternehmer.text.trim(),
        'weiterleitungGewerbeaufsicht': yn(_weiterleitungGewerbeaufsicht),
      };

      final payload = <String, dynamic>{
        'reportId': reportId,
        'type': 'work_accident',
        'dspUid': widget.dspUid,
        'driverUid': driverAuthUid,
        'driverTransporterId': driverId,
        'driverName': driverName,
        // mirror unfallort into `location` so the admin list row is meaningful
        'location': _unfallort.text.trim(),
        'description': _unfallhergang.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'submitted',
        'createdByAdmin': widget.isAdminMode,
        if (widget.isAdminMode) 'createdByAdminUid': auth.uid,
        'workAccident': wa,
      };

      final driverDocRef =
          driverRef.collection('incident_reports').doc(reportId);
      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverDocRef, payload, SetOptions(merge: true));
      batch.set(driverRef, {
        'lastIncidentReportAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return;
      _snack('Arbeitsunfall gespeichert.');
      widget.onSubmitted?.call();
    } catch (e) {
      _snack('Speichern fehlgeschlagen: $e', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Date/time picker helpers ──
  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) {
      ctrl.text = '${_two(d.day)}.${_two(d.month)}.${d.year}';
    }
  }

  Future<void> _pickDateTime(TextEditingController ctrl) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    final time = t == null ? '' : ' ${_two(t.hour)}:${_two(t.minute)}';
    ctrl.text = '${_two(d.day)}.${_two(d.month)}.${d.year}$time';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: _kAccent)),
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _intro(),
          const SizedBox(height: 14),
          _section('Basis-Informationen', [
            _field('Arbeitsstelle der versicherten Person', _arbeitsstelle),
            _field('Name der Ansprechperson', _ansprechName),
            _field('Telefon der Ansprechperson', _ansprechPhone),
          ]),
          _section('Angaben zur versicherten Person', [
            _field('Tätigkeit zum Unfallzeitpunkt', _taetigkeit),
            _yesNo('Auszubildende/-r?', _auszubildende,
                (v) => setState(() => _auszubildende = v)),
            _field('Beginn der Beschäftigung', _beschaeftigungsbeginn,
                hint: 'MM.JJJJ'),
            _field('Tätigkeitsumfeld im Unternehmen', _taetigkeitsumfeld,
                hint: 'z. B. Fahrzeug'),
            _yesNo('Geringfügige Beschäftigung?', _geringfuegig,
                (v) => setState(() => _geringfuegig = v)),
            _yesNo('Leiharbeitnehmer/-in?', _leiharbeit,
                (v) => setState(() => _leiharbeit = v)),
          ]),
          _section('Weitere Angaben zur versicherten Person', [
            _field('Vor- und Nachname', _fullName),
            _field('Straße und Hausnummer', _strasse),
            _field('Land', _land),
            _field('Postleitzahl', _plz),
            _field('Ort', _ort),
            _dateField('Geburtsdatum', _geburtsdatum),
            _genderField(),
            _field('Staatsangehörigkeit', _staatsangehoerigkeit),
            _field('Telefonnummer', _telefon),
            _field('Angaben zum Arbeitsverhältnis', _arbeitsverhaeltnis),
            _field('Entgeltfortzahlung (Wochen)', _entgeltfortzahlung,
                keyboard: TextInputType.number),
            _field('Krankenkasse', _krankenkasse),
          ]),
          _section('Informationen zum Unfall — Teil I', [
            _dateTimeField('Unfallzeitpunkt (Datum / Zeit)', _unfallzeitpunkt),
            _field('Unfallort', _unfallort, hint: 'z. B. Auf dem Geschäftsweg'),
            _field('Nähere Angaben zum Unfallort', _naehereOrt, lines: 2),
            _yesNo('Maschinenunfall?', _maschinenunfall,
                (v) => setState(() => _maschinenunfall = v)),
            _field('Unfallhergang', _unfallhergang, lines: 3),
            _field('Schilderung der Angaben zum Unfall', _schilderung),
            _yesNo('Hat ein Gewaltereignis stattgefunden?', _gewaltereignis,
                (v) => setState(() => _gewaltereignis = v)),
            _field('Erste Zeugin / erster Zeuge des Unfalls', _zeuge, lines: 2),
            _yesNo('War diese Person Augenzeuge/-in?', _augenzeuge,
                (v) => setState(() => _augenzeuge = v)),
          ]),
          _section('Informationen zum Unfall — Teil II', [
            _yesNo('Tödlicher Unfall?', _toedlich,
                (v) => setState(() => _toedlich = v)),
            _yesNo('Unterbrechung der Arbeit?', _arbeitsunterbrechung,
                (v) => setState(() => _arbeitsunterbrechung = v)),
            _dateTimeField('Datum und Uhrzeit der Unterbrechung',
                _unterbrechungZeit),
            _yesNo('Wiederaufnahme der Arbeit?', _wiederaufnahme,
                (v) => setState(() => _wiederaufnahme = v)),
            _field('Arbeitszeit — Beginn', _arbeitszeitBeginn, hint: 'z. B. 11:00'),
            _field('Arbeitszeit — Ende', _arbeitszeitEnde, hint: 'z. B. 19:30'),
            _field('Verletzte Körperteile', _verletzteKoerperteile),
            _field('Art der Verletzung', _artVerletzung, lines: 2),
            _field('Erstbehandlung der versicherten Person', _erstbehandlung),
            _field('Erstbehandelnde/r Arzt/Ärztin oder Krankenhaus',
                _behandelnderArzt),
          ]),
          _section('Betrieb', [
            _field('Personal- bzw. Betriebsrat', _betriebsrat),
            _field('Unternehmer/-in (Bevollmächtigte/-r)', _unternehmer),
            _yesNo('Weiterleitung an das Gewerbeaufsichtsamt?',
                _weiterleitungGewerbeaufsicht,
                (v) => setState(() => _weiterleitungGewerbeaufsicht = v)),
          ]),
          const SizedBox(height: 8),
          _confirmRow(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _kAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined),
              label: Text(
                  Localizations.localeOf(context).languageCode == 'de'
                      ? 'Arbeitsunfall speichern'
                      : 'Save Arbeitsunfall report',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  // ── UI helpers ──
  Widget _intro() => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFEFFaf6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kAccent.withValues(alpha: 0.35)),
        ),
        child: Text(
          Localizations.localeOf(context).languageCode == 'de'
              ? 'Arbeitsunfall-Meldung (Unfallanzeige). Persönliche Daten sind aus '
                  'dem Fahrerprofil vorbefüllt — bitte prüfen und den Unfall ergänzen.'
              : 'Arbeitsunfall report (Unfallanzeige — the statutory German '
                  'accident report). Personal data is pre-filled from the driver '
                  'profile — please check it and add the accident details. Field '
                  'labels follow the official German form.',
          style: const TextStyle(fontSize: 12.5, color: _kDeep, height: 1.4),
        ),
      );

  Widget _section(String title, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _kInk)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, int lines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _kMuted)),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            minLines: lines,
            maxLines: lines == 1 ? 1 : lines + 2,
            keyboardType: keyboard ??
                (lines > 1 ? TextInputType.multiline : TextInputType.text),
            decoration: _dec(hint),
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, TextEditingController ctrl) =>
      _pickerField(label, ctrl, Icons.calendar_today_outlined,
          () => _pickDate(ctrl));

  Widget _dateTimeField(String label, TextEditingController ctrl) =>
      _pickerField(label, ctrl, Icons.schedule_outlined,
          () => _pickDateTime(ctrl));

  Widget _pickerField(String label, TextEditingController ctrl, IconData icon,
      VoidCallback onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _kMuted)),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            decoration: _dec('TT.MM.JJJJ').copyWith(
              suffixIcon: IconButton(
                icon: Icon(icon, size: 19, color: _kAccent),
                onPressed: onPick,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Geschlecht',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _kMuted)),
          const SizedBox(height: 5),
          Row(
            children: [
              for (final g in const ['männlich', 'weiblich', 'divers'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(g),
                    selected: _geschlecht == g,
                    selectedColor: _kAccent.withValues(alpha: 0.18),
                    onSelected: (_) => setState(() => _geschlecht = g),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _yesNo(String label, bool? value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _kInk)),
          ),
          const SizedBox(width: 8),
          _ynChip('Ja', value == true, () => onChanged(true)),
          const SizedBox(width: 6),
          _ynChip('Nein', value == false, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _ynChip(String label, bool selected, VoidCallback onTap) {
    return Material(
      color: selected ? _kAccent : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : _kInk)),
        ),
      ),
    );
  }

  Widget _confirmRow() {
    return InkWell(
      onTap: () => setState(() => _bestaetigt = !_bestaetigt),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: _bestaetigt,
              activeColor: _kAccent,
              onChanged: (v) => setState(() => _bestaetigt = v ?? false),
            ),
            Expanded(
              child: Text(
                  Localizations.localeOf(context).languageCode == 'de'
                      ? 'Ich habe alle Angaben überprüft.'
                      : 'I have checked all entries.',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kInk)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String? hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _kAccent, width: 1.5),
        ),
      );
}
