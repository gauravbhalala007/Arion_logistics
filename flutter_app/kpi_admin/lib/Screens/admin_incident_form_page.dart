import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../services/incident_reports.dart';
import '../utils/driver_activity.dart';
import '../widgets/co_button.dart';

/// ── Gemeinsame Feld-Optik ────────────────────────────────────────────────
/// Ruhige, gefüllte Felder: hellgraue Füllung, 12er-Radius, Hairline-Border,
/// Focus in Produktgrün. Keine Underlines, keine Theme-Akzentfarbe.
const Color kIncidentFieldFill = Color(0xFFF7F8F8);
const Color kIncidentBorder = Color(0xFFE5E7EB);
const Color kIncidentFocus = Color(0xFF067647);
const Color kIncidentText = Color(0xFF111827);
const Color kIncidentMuted = Color(0xFF6B7280);
const Color kIncidentDanger = Color(0xFFB42318);

/// Einheitliche `InputDecoration` für alle Incident-Formulare.
/// Label steht extern über dem Feld ([IncidentField]) — hier nur Hint.
InputDecoration incidentInputDecoration({
  String? hintText,
  String? errorText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool isDense = false,
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
    errorText: errorText,
    errorStyle: const TextStyle(
      color: kIncidentDanger,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: kIncidentFieldFill,
    isDense: isDense,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: border(kIncidentBorder, 1),
    enabledBorder: border(kIncidentBorder, 1),
    focusedBorder: border(kIncidentFocus, 1.5),
    errorBorder: border(kIncidentDanger, 1),
    focusedErrorBorder: border(kIncidentDanger, 1.5),
    disabledBorder: border(kIncidentBorder, 1),
  );
}

/// Feld mit externem Label darüber — 4er-Raster, optionale Pflichtmarkierung.
class IncidentField extends StatelessWidget {
  const IncidentField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.helper,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kIncidentText,
                ),
              ),
              if (required)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '*',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kIncidentDanger,
                    ),
                  ),
                ),
            ],
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              style: const TextStyle(fontSize: 12, color: kIncidentMuted),
            ),
          ],
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Erfassungs-/Bearbeitungsformular für einen Vorfall.
///
/// Der Vorfall wird **zuerst hier** erfasst; erst danach wird der Bericht
/// per Kopier-Button als Text in die WhatsApp-Gruppe gestellt.
///
/// Fahrzeug-Vorfall: Fahrer **und** Fahrzeug sind Pflicht.
/// Arbeitsunfall: Fahrer Pflicht, Fahrzeug optional.
class AdminIncidentFormPage extends StatefulWidget {
  const AdminIncidentFormPage({
    super.key,
    required this.dspUid,
    required this.category,
    this.docId,
    this.initialData,
  });

  final String dspUid;

  /// [kIncidentVehicle] oder [kIncidentWorkAccident].
  final String category;

  /// Gesetzt = Bearbeiten, sonst Neuanlage.
  final String? docId;
  final Map<String, dynamic>? initialData;

  bool get isEdit => docId != null;

  @override
  State<AdminIncidentFormPage> createState() => _AdminIncidentFormPageState();
}

class _AdminIncidentFormPageState extends State<AdminIncidentFormPage> {
  final _scrollCtrl = ScrollController();

  // Gemeinsame Felder
  final _addressCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Fahrzeug-Vorfall
  final _damageCtrl = TextEditingController();
  final _groundingReasonCtrl = TextEditingController();
  final _tpNameCtrl = TextEditingController();
  final _tpPlateCtrl = TextEditingController();
  final _tpPhoneCtrl = TextEditingController();
  final _tpEmailCtrl = TextEditingController();
  final _tpInsuranceCtrl = TextEditingController();

  // Arbeitsunfall
  final _injuryTypeCtrl = TextEditingController();
  final _bodyPartCtrl = TextEditingController();
  final _activityCtrl = TextEditingController();
  final _firstAidByCtrl = TextEditingController();
  final _witnessesCtrl = TextEditingController();
  final _daysOffCtrl = TextEditingController();

  String _incidentType = 'accident';
  String _responsibility = 'unknown';
  String _grounding = 'unknown';
  bool _firstAid = false;
  bool _doctorVisited = false;
  bool _bgReportRequired = false;

  DateTime _date = DateUtils.dateOnly(DateTime.now());
  TimeOfDay? _time;

  String _driverTid = '';
  String _driverName = '';
  String _plate = '';

  bool _saving = false;
  final Map<String, String> _errors = <String, String>{};

  bool get _isWorkAccident => widget.category == kIncidentWorkAccident;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    for (final c in <TextEditingController>[
      _addressCtrl,
      _descriptionCtrl,
      _notesCtrl,
      _damageCtrl,
      _groundingReasonCtrl,
      _tpNameCtrl,
      _tpPlateCtrl,
      _tpPhoneCtrl,
      _tpEmailCtrl,
      _tpInsuranceCtrl,
      _injuryTypeCtrl,
      _bodyPartCtrl,
      _activityCtrl,
      _firstAidByCtrl,
      _witnessesCtrl,
      _daysOffCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate() {
    final data = widget.initialData;
    if (data == null) return;

    _addressCtrl.text = incidentAddress(data);
    _descriptionCtrl.text = incidentDescription(data);
    _notesCtrl.text = _str(data['notes']);
    _damageCtrl.text = _str(data['damage']);
    _groundingReasonCtrl.text = _str(data['groundingReason']);

    final tp = incidentMapOf(data['thirdParty']);
    _tpNameCtrl.text = _str(tp['name']);
    _tpPlateCtrl.text = _str(tp['plate']);
    _tpPhoneCtrl.text = _str(tp['phone']);
    _tpEmailCtrl.text = _str(tp['email']);
    _tpInsuranceCtrl.text = _str(tp['insurance']);

    // Bewusst über die Lese-Helfer: eine in der Fahrer-App erstellte
    // Unfallanzeige legt die Werte unter `workAccident.*` ab. Ohne Fallback
    // wären die Felder beim Bearbeiten leer und würden beim Speichern die
    // Originalangaben überschreiben.
    _injuryTypeCtrl.text = incidentInjuryType(data);
    _bodyPartCtrl.text = incidentBodyPart(data);
    _activityCtrl.text = incidentActivityAtTime(data);
    _firstAidByCtrl.text = incidentDoctorText(data);
    _witnessesCtrl.text = incidentWitnesses(data);
    final daysOff = data['expectedDaysOff'];
    if (daysOff is num && daysOff > 0) _daysOffCtrl.text = '${daysOff.toInt()}';

    _incidentType = incidentTypeOf(data);
    _responsibility = incidentResponsibilityOf(data);
    _grounding = incidentGroundingOf(data);
    _firstAid = data['firstAid'] == true;
    _doctorVisited = data['doctorVisited'] == true;
    _bgReportRequired = data['bgReportRequired'] == true;

    final occurredAt = incidentOccurredAt(data);
    if (occurredAt != null) _date = DateUtils.dateOnly(occurredAt);
    final timeText = _str(data['timeText']);
    final parsed = _parseTimeText(timeText);
    _time = parsed ??
        (occurredAt != null && !(occurredAt.hour == 0 && occurredAt.minute == 0)
            ? TimeOfDay.fromDateTime(occurredAt)
            : null);

    _driverTid = incidentDriverTid(data);
    _driverName = incidentDriverName(data);
    _plate = incidentPlate(data);
  }

  static String _str(dynamic v) => v?.toString().trim() ?? '';

  static TimeOfDay? _parseTimeText(String raw) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw.trim());
    if (match == null) return null;
    final h = int.tryParse(match.group(1)!) ?? 0;
    final m = int.tryParse(match.group(2)!) ?? 0;
    if (h > 23 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  // ── Pickers ────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 6),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = DateUtils.dateOnly(picked);
      _errors.remove('date');
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
  }

  Future<void> _pickDriver() async {
    final result = await showDialog<_PickedDriver>(
      context: context,
      builder: (_) => _DriverPickerDialog(dspUid: widget.dspUid),
    );
    if (result == null || !mounted) return;
    setState(() {
      _driverTid = result.transporterId;
      _driverName = result.name;
      _errors.remove('driver');
    });
  }

  Future<void> _pickVehicle() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _VehiclePickerDialog(dspUid: widget.dspUid),
    );
    if (result == null || !mounted) return;
    setState(() {
      _plate = result;
      _errors.remove('plate');
    });
  }

  // ── Speichern ──────────────────────────────────────────────────────────

  bool _validate() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final errors = <String, String>{};

    if (_driverTid.isEmpty) {
      errors['driver'] = de
          ? 'Wähle den betroffenen Fahrer aus.'
          : 'Select the driver involved.';
    }
    if (!_isWorkAccident && plateKeyOf(_plate).isEmpty) {
      errors['plate'] = de
          ? 'Wähle das betroffene Fahrzeug aus.'
          : 'Select the vehicle involved.';
    }
    if (_descriptionCtrl.text.trim().isEmpty) {
      errors['description'] = de
          ? 'Beschreibe kurz, was passiert ist.'
          : 'Describe briefly what happened.';
    }
    if (_isWorkAccident && _injuryTypeCtrl.text.trim().isEmpty) {
      errors['injuryType'] = de
          ? 'Trage die Art der Verletzung ein.'
          : 'Enter the type of injury.';
    }
    final daysOffRaw = _daysOffCtrl.text.trim();
    if (daysOffRaw.isNotEmpty && int.tryParse(daysOffRaw) == null) {
      errors['daysOff'] =
          de ? 'Nur ganze Tage eintragen.' : 'Enter whole days only.';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  Map<String, dynamic> _buildPayload() {
    final auth = FirebaseAuth.instance.currentUser;
    final reportedBy = (auth?.displayName ?? '').trim().isNotEmpty
        ? auth!.displayName!.trim()
        : (auth?.email ?? '').trim();

    final occurredAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time?.hour ?? 0,
      _time?.minute ?? 0,
    );
    final timeText = _time == null
        ? ''
        : '${_time!.hour.toString().padLeft(2, '0')}:'
            '${_time!.minute.toString().padLeft(2, '0')}';

    final plateRaw = _plate.trim();
    final payload = <String, dynamic>{
      'category': widget.category,
      // Invariante: `type` wird IMMER synchron zu `category` geschrieben.
      // Das Altfeld existiert nur noch für Bestandsleser (Fahrer-App), darf
      // aber nie widersprechen — sonst zählt ein nachbearbeiteter
      // Alt-Arbeitsunfall in `_countVehicleIncidents` falsch.
      'type': widget.category,
      'occurredAt': Timestamp.fromDate(occurredAt),
      'timeText': timeText,
      'driverTransporterId': transporterIdOf(_driverTid),
      'driverName': _driverName.trim(),
      'driverNameRaw': _driverName.trim(),
      'plate': plateRaw,
      'plateRaw': plateRaw,
      'plateKey': plateKeyOf(plateRaw),
      'address': _addressCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (_isWorkAccident) {
      final daysOff = int.tryParse(_daysOffCtrl.text.trim());
      payload.addAll(<String, dynamic>{
        'damage': '',
        'responsibility': 'unknown',
        'grounding': 'unknown',
        'groundingReason': '',
        'thirdParty': const <String, dynamic>{},
        'injuryType': _injuryTypeCtrl.text.trim(),
        'bodyPart': _bodyPartCtrl.text.trim(),
        'activityAtTime': _activityCtrl.text.trim(),
        'firstAid': _firstAid,
        'firstAidBy': _firstAid ? _firstAidByCtrl.text.trim() : '',
        'doctorVisited': _doctorVisited,
        'witnesses': _witnessesCtrl.text.trim(),
        'expectedDaysOff': daysOff,
        'bgReportRequired': _bgReportRequired,
      });
    } else {
      payload.addAll(<String, dynamic>{
        'incidentType': _incidentType,
        'damage': _damageCtrl.text.trim(),
        'responsibility': _responsibility,
        'grounding': _grounding,
        'groundingReason':
            _grounding == 'no' ? '' : _groundingReasonCtrl.text.trim(),
        'thirdParty': <String, dynamic>{
          'name': _tpNameCtrl.text.trim(),
          'plate': _tpPlateCtrl.text.trim(),
          'phone': _tpPhoneCtrl.text.trim(),
          'email': _tpEmailCtrl.text.trim(),
          'insurance': _tpInsuranceCtrl.text.trim(),
        },
      });
    }

    // Provenienz wird ausschließlich bei der Neuanlage gesetzt. Beim
    // Bearbeiten bleiben `source`, `confidence`, `reviewFlag`, `reportedAt`
    // und `reportedBy` unangetastet — sonst würde ein importierter Fall
    // (source 'structured' / 'chat_reconstructed' samt Konfidenz und
    // Review-Flag) durch eine einzige Korrektur unwiederbringlich als
    // „in CoDriver erfasst" umetikettiert.
    if (!widget.isEdit) {
      payload['source'] = kIncidentSourceCoDriver;
      payload['confidence'] = 1.0;
      payload['reviewFlag'] = false;
      payload['reportedAt'] = FieldValue.serverTimestamp();
      payload['reportedBy'] = reportedBy;
      payload['createdAt'] = FieldValue.serverTimestamp();
      payload['createdBy'] = auth?.uid ?? '';
    }
    return payload;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_validate()) {
      final de = Localizations.localeOf(context).languageCode == 'de';
      _snack(
        de
            ? 'Bitte die markierten Felder ausfüllen.'
            : 'Fill in the highlighted fields.',
        error: true,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final col = incidentReportsCol(widget.dspUid);
      final ref = widget.isEdit ? col.doc(widget.docId) : col.doc();
      await ref.set(_buildPayload(), SetOptions(merge: true));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final de = Localizations.localeOf(context).languageCode == 'de';
      _snack(
        de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
        error: true,
      );
    }
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? kIncidentDanger : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final title = widget.isEdit
        ? (de ? 'Vorfall bearbeiten' : 'Edit incident')
        : _isWorkAccident
            ? (de ? 'Arbeitsunfall erfassen' : 'Log work accident')
            : (de ? 'Unfall oder Schaden erfassen' : 'Log accident or damage');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(title, de),
            const Divider(height: 1, color: kIncidentBorder),
            Flexible(
              child: Scrollbar(
                controller: _scrollCtrl,
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _isWorkAccident
                        ? _workAccidentFields(de)
                        : _vehicleFields(de),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: kIncidentBorder),
            _footer(de),
          ],
        ),
      ),
    );
  }

  Widget _header(String title, bool de) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isWorkAccident
                  ? const Color(0xFFE7F0FF)
                  : const Color(0xFFFFF1E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isWorkAccident
                  ? Icons.personal_injury_outlined
                  : Icons.car_crash_outlined,
              size: 20,
              color: _isWorkAccident
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFC2410C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kIncidentText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  de
                      ? 'Erst hier erfassen, danach lässt sich der Bericht als Text kopieren.'
                      : 'Log it here first, then the report can be copied as text.',
                  style: const TextStyle(fontSize: 12, color: kIncidentMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: kIncidentMuted,
            tooltip: de ? 'Schließen' : 'Close',
          ),
        ],
      ),
    );
  }

  Widget _footer(bool de) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CoButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            label: de ? 'Abbrechen' : 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          const SizedBox(width: 8),
          CoButton(
            onPressed: _saving ? null : _save,
            icon: Icons.check_rounded,
            label: widget.isEdit
                ? (de ? 'Änderungen speichern' : 'Save changes')
                : (de ? 'Vorfall speichern' : 'Save incident'),
            busy: _saving,
          ),
        ],
      ),
    );
  }

  // ── Feldgruppen ────────────────────────────────────────────────────────

  List<Widget> _sharedTopFields(bool de) {
    return <Widget>[
      _sectionLabel(de ? 'Wann und wer' : 'When and who'),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: IncidentField(
              label: de ? 'Datum' : 'Date',
              required: true,
              child: _pickerButton(
                icon: Icons.calendar_today_outlined,
                text: DateFormat('dd.MM.yyyy').format(_date),
                onTap: _pickDate,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: IncidentField(
              label: de ? 'Uhrzeit' : 'Time',
              child: _pickerButton(
                icon: Icons.schedule_outlined,
                text: _time == null
                    ? (de ? 'Keine Angabe' : 'Not specified')
                    : '${_time!.hour.toString().padLeft(2, '0')}:'
                        '${_time!.minute.toString().padLeft(2, '0')}',
                placeholder: _time == null,
                onTap: _pickTime,
                onClear: _time == null ? null : () => setState(() => _time = null),
              ),
            ),
          ),
        ],
      ),
      IncidentField(
        label: de ? 'Fahrer' : 'Driver',
        required: true,
        child: _pickerButton(
          icon: Icons.person_outline_rounded,
          text: _driverTid.isEmpty
              ? (de ? 'Fahrer auswählen' : 'Select driver')
              : (_driverName.isEmpty || _driverName == _driverTid
                  ? _driverTid
                  : '$_driverName · $_driverTid'),
          placeholder: _driverTid.isEmpty,
          onTap: _pickDriver,
          error: _errors['driver'],
        ),
      ),
      IncidentField(
        label: de ? 'Fahrzeug' : 'Vehicle',
        required: !_isWorkAccident,
        helper: _isWorkAccident
            ? (de
                ? 'Optional — nur wenn beim Arbeitsunfall ein Fahrzeug beteiligt war.'
                : 'Optional — only if a vehicle was involved.')
            : null,
        child: _pickerButton(
          icon: Icons.local_shipping_outlined,
          text: _plate.isEmpty
              ? (de ? 'Fahrzeug auswählen' : 'Select vehicle')
              : _plate,
          placeholder: _plate.isEmpty,
          onTap: _pickVehicle,
          onClear: _plate.isEmpty || !_isWorkAccident
              ? null
              : () => setState(() => _plate = ''),
          error: _errors['plate'],
        ),
      ),
    ];
  }

  List<Widget> _vehicleFields(bool de) {
    return <Widget>[
      ..._sharedTopFields(de),
      const SizedBox(height: 8),
      _sectionLabel(de ? 'Was ist passiert' : 'What happened'),
      IncidentField(
        label: de ? 'Vorfallart' : 'Incident type',
        required: true,
        child: _dropdown<String>(
          value: _incidentType,
          items: [
            for (final type in kVehicleIncidentTypes)
              DropdownMenuItem<String>(
                value: type,
                child: Text(incidentTypeLabel(type, de: de)),
              ),
          ],
          onChanged: (v) => setState(() => _incidentType = v ?? 'accident'),
        ),
      ),
      IncidentField(
        label: de ? 'Ort' : 'Location',
        child: _text(
          _addressCtrl,
          hint: de ? 'Straße, PLZ, Ort' : 'Street, postcode, city',
        ),
      ),
      IncidentField(
        label: de ? 'Hergang' : 'Course of events',
        required: true,
        child: _text(
          _descriptionCtrl,
          hint: de
              ? 'Kurz und sachlich beschreiben, was passiert ist.'
              : 'Describe briefly and factually what happened.',
          minLines: 3,
          maxLines: 6,
          errorKey: 'description',
        ),
      ),
      IncidentField(
        label: de ? 'Schaden' : 'Damage',
        child: _text(
          _damageCtrl,
          hint: de
              ? 'z. B. Stoßstange hinten links eingedrückt'
              : 'e.g. rear left bumper dented',
          minLines: 2,
          maxLines: 4,
        ),
      ),
      const SizedBox(height: 8),
      _sectionLabel(de ? 'Bewertung' : 'Assessment'),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: IncidentField(
              label: de ? 'Schuldfrage' : 'Responsibility',
              child: _dropdown<String>(
                value: _responsibility,
                items: [
                  for (final value in kResponsibilityValues)
                    DropdownMenuItem<String>(
                      value: value,
                      child: Text(responsibilityLabel(value, de: de)),
                    ),
                ],
                onChanged: (v) =>
                    setState(() => _responsibility = v ?? 'unknown'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: IncidentField(
              label: 'Grounding',
              child: _dropdown<String>(
                value: _grounding,
                items: [
                  for (final value in kGroundingValues)
                    DropdownMenuItem<String>(
                      value: value,
                      child: Text(groundingLabel(value, de: de)),
                    ),
                ],
                onChanged: (v) => setState(() => _grounding = v ?? 'unknown'),
              ),
            ),
          ),
        ],
      ),
      if (_grounding != 'no')
        IncidentField(
          label: de ? 'Grund für das Grounding' : 'Reason for grounding',
          child: _text(
            _groundingReasonCtrl,
            hint: de ? 'z. B. Fahrerflucht' : 'e.g. hit and run',
          ),
        ),
      const SizedBox(height: 8),
      _sectionLabel(de ? 'Gegenpartei' : 'Third party'),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: IncidentField(
              label: de ? 'Name' : 'Name',
              child: _text(_tpNameCtrl),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: IncidentField(
              label: de ? 'Kennzeichen' : 'Plate',
              child: _text(
                _tpPlateCtrl,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: IncidentField(
              label: de ? 'Telefon' : 'Phone',
              child: _text(_tpPhoneCtrl, keyboardType: TextInputType.phone),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: IncidentField(
              label: de ? 'E-Mail' : 'Email',
              child: _text(
                _tpEmailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
        ],
      ),
      IncidentField(
        label: de ? 'Versicherung' : 'Insurance',
        child: _text(_tpInsuranceCtrl),
      ),
      _notesField(de),
    ];
  }

  List<Widget> _workAccidentFields(bool de) {
    return <Widget>[
      _hint(
        de
            ? 'Arbeitsunfall = Personenschaden am Arbeitsplatz (BG-relevant). '
                'Für einen Fahrzeugschaden den Bereich „Unfälle & Schäden" nutzen.'
            : 'Work accident = injury to a person at work (reportable to the '
                'employers\' liability insurance). Use "Accidents & damage" for '
                'vehicle damage.',
      ),
      ..._sharedTopFields(de),
      const SizedBox(height: 8),
      _sectionLabel(de ? 'Was ist passiert' : 'What happened'),
      IncidentField(
        label: de ? 'Ort' : 'Location',
        child: _text(
          _addressCtrl,
          hint: de ? 'Straße, PLZ, Ort' : 'Street, postcode, city',
        ),
      ),
      IncidentField(
        label: de ? 'Hergang' : 'Course of events',
        required: true,
        child: _text(
          _descriptionCtrl,
          hint: de
              ? 'Kurz und sachlich beschreiben, was passiert ist.'
              : 'Describe briefly and factually what happened.',
          minLines: 3,
          maxLines: 6,
          errorKey: 'description',
        ),
      ),
      IncidentField(
        label: de ? 'Tätigkeit zum Unfallzeitpunkt' : 'Activity at the time',
        child: _text(
          _activityCtrl,
          hint: de ? 'z. B. Paketzustellung' : 'e.g. parcel delivery',
        ),
      ),
      const SizedBox(height: 8),
      _sectionLabel(de ? 'Verletzung' : 'Injury'),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: IncidentField(
              label: de ? 'Art der Verletzung' : 'Type of injury',
              required: true,
              child: _text(
                _injuryTypeCtrl,
                hint: de ? 'z. B. Prellung' : 'e.g. contusion',
                errorKey: 'injuryType',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: IncidentField(
              label: de ? 'Körperteil' : 'Body part',
              child: _text(
                _bodyPartCtrl,
                hint: de ? 'z. B. Knie links' : 'e.g. left knee',
              ),
            ),
          ),
        ],
      ),
      _switchTile(
        label: de ? 'Erste Hilfe geleistet' : 'First aid given',
        value: _firstAid,
        onChanged: (v) => setState(() => _firstAid = v),
      ),
      if (_firstAid)
        IncidentField(
          label: de ? 'Erste Hilfe durch' : 'First aid by',
          child: _text(_firstAidByCtrl),
        ),
      _switchTile(
        label: de ? 'Durchgangsarzt aufgesucht' : 'Saw the designated doctor',
        value: _doctorVisited,
        onChanged: (v) => setState(() => _doctorVisited = v),
      ),
      const SizedBox(height: 8),
      _sectionLabel(de ? 'Folgen und Meldung' : 'Consequences and reporting'),
      IncidentField(
        label: de ? 'Zeugen' : 'Witnesses',
        child: _text(
          _witnessesCtrl,
          hint: de ? 'Namen, durch Komma getrennt' : 'Names, comma separated',
        ),
      ),
      IncidentField(
        label: de
            ? 'Voraussichtliche Ausfalltage'
            : 'Expected days off work',
        child: _text(
          _daysOffCtrl,
          hint: de ? 'z. B. 3' : 'e.g. 3',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorKey: 'daysOff',
        ),
      ),
      _switchTile(
        label: de ? 'BG-Meldung erforderlich' : 'Report to BG required',
        value: _bgReportRequired,
        onChanged: (v) => setState(() => _bgReportRequired = v),
      ),
      _notesField(de),
    ];
  }

  Widget _notesField(bool de) {
    return IncidentField(
      label: de ? 'Interne Notizen' : 'Internal notes',
      child: _text(
        _notesCtrl,
        hint: de
            ? 'Nur für das Team — landet mit im kopierten Bericht.'
            : 'For the team only — included in the copied report.',
        minLines: 2,
        maxLines: 4,
      ),
    );
  }

  // ── Bausteine ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: kIncidentMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _hint(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E4FB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _text(
    TextEditingController controller, {
    String? hint,
    int minLines = 1,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    String? errorKey,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines < minLines ? minLines : maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 14, color: kIncidentText, height: 1.4),
      decoration: incidentInputDecoration(
        hintText: hint,
        errorText: errorKey == null ? null : _errors[errorKey],
      ),
      onChanged: errorKey == null || _errors[errorKey] == null
          ? null
          : (_) => setState(() => _errors.remove(errorKey)),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.expand_more_rounded, size: 20),
      style: const TextStyle(fontSize: 14, color: kIncidentText),
      decoration: incidentInputDecoration(),
    );
  }

  /// Feld-artiger Button für Datum, Uhrzeit, Fahrer und Fahrzeug — sieht aus
  /// wie ein Eingabefeld, damit die Formularzeile optisch nicht bricht.
  Widget _pickerButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool placeholder = false,
    VoidCallback? onClear,
    String? error,
  }) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: kIncidentFieldFill,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? kIncidentDanger : kIncidentBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: kIncidentMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: placeholder
                            ? const Color(0xFF9CA3AF)
                            : kIncidentText,
                        fontWeight:
                            placeholder ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onClear != null)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      color: kIncidentMuted,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: MaterialLocalizations.of(context)
                          .deleteButtonTooltip,
                    )
                  else
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: kIncidentMuted,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kIncidentDanger,
              ),
            ),
          ),
      ],
    );
  }

  Widget _switchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: kIncidentFieldFill,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kIncidentBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kIncidentText,
                    ),
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: kIncidentFocus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Fahrer-Picker ────────────────────────────────────────────────────────

class _PickedDriver {
  const _PickedDriver({required this.transporterId, required this.name});
  final String transporterId;
  final String name;
}

class _DriverPickerDialog extends StatefulWidget {
  const _DriverPickerDialog({required this.dspUid});
  final String dspUid;

  @override
  State<_DriverPickerDialog> createState() => _DriverPickerDialogState();
}

class _DriverPickerDialogState extends State<_DriverPickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  /// Ausgeschiedene Fahrer bleiben ausgeblendet, bis der Admin sie
  /// zuschaltet — nötig für die Nacherfassung historischer Fälle.
  bool _includeInactive = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static String _nameOf(Map<String, dynamic> data) {
    for (final key in const ['driverName', 'name', 'fullName']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers');

    return _PickerScaffold(
      title: de ? 'Fahrer auswählen' : 'Select driver',
      subtitle: _includeInactive
          ? (de
              ? 'Aktive und ausgeschiedene Fahrer.'
              : 'Active and former drivers.')
          : (de
              ? 'Nur aktive Fahrer werden angezeigt.'
              : 'Only active drivers are listed.'),
      searchController: _searchCtrl,
      searchHint: de ? 'Name oder TID suchen' : 'Search name or TID',
      onQueryChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
      filterToggle: _PickerToggle(
        label: de
            ? 'Auch ausgeschiedene Fahrer anzeigen'
            : 'Also show former drivers',
        value: _includeInactive,
        onChanged: (v) => setState(() => _includeInactive = v),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _PickerLoading();
          }
          if (snap.hasError) {
            return _PickerMessage(
              icon: Icons.wifi_off_rounded,
              text: de
                  ? 'Fahrerliste konnte nicht geladen werden. Verbindung prüfen.'
                  : 'Could not load the driver list. Check the connection.',
            );
          }
          final docs = (snap.data?.docs ?? const [])
              .where((d) => _includeInactive || isDriverWorking(d.data()))
              .where((d) {
                if (_query.isEmpty) return true;
                return d.id.toLowerCase().contains(_query) ||
                    _nameOf(d.data()).toLowerCase().contains(_query);
              })
              .toList()
            ..sort((a, b) {
              final na = _nameOf(a.data()).toLowerCase();
              final nb = _nameOf(b.data()).toLowerCase();
              if (na.isEmpty && nb.isEmpty) return a.id.compareTo(b.id);
              if (na.isEmpty) return 1;
              if (nb.isEmpty) return -1;
              return na.compareTo(nb);
            });

          if (docs.isEmpty) {
            return _PickerMessage(
              icon: Icons.person_search_outlined,
              text: _query.isEmpty
                  ? (de
                      ? 'Keine aktiven Fahrer vorhanden. Schalte ausgeschiedene Fahrer dazu, um ältere Fälle zu erfassen.'
                      : 'No active drivers available. Include former drivers to log older cases.')
                  : (de
                      ? 'Kein Fahrer passt zu deiner Suche.'
                      : 'No driver matches your search.'),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: kIncidentBorder),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final name = _nameOf(doc.data());
              return ListTile(
                minVerticalPadding: 12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  name.isEmpty ? doc.id : name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: kIncidentText,
                  ),
                ),
                subtitle: Text(
                  'TID ${doc.id}',
                  style: const TextStyle(fontSize: 12, color: kIncidentMuted),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: kIncidentMuted,
                ),
                onTap: () => Navigator.of(context).pop(
                  _PickedDriver(
                    transporterId: transporterIdOf(doc.id),
                    name: name.isEmpty ? doc.id : name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Fahrzeug-Picker ──────────────────────────────────────────────────────

class _VehiclePickerDialog extends StatefulWidget {
  const _VehiclePickerDialog({required this.dspUid});
  final String dspUid;

  @override
  State<_VehiclePickerDialog> createState() => _VehiclePickerDialogState();
}

class _VehiclePickerDialogState extends State<_VehiclePickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  /// Abgemeldete Fahrzeuge (Status INACTIVE) sind ausgeblendet, bis der
  /// Admin sie zuschaltet — nötig für die Nacherfassung historischer Fälle.
  bool _includeRetired = false;

  static bool _isRetired(Map<String, dynamic> data) =>
      (data['status'] ?? '').toString().trim().toUpperCase() == 'INACTIVE';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('vehicles');

    return _PickerScaffold(
      title: de ? 'Fahrzeug auswählen' : 'Select vehicle',
      subtitle: _includeRetired
          ? (de
              ? 'Alle Kennzeichen aus dem Fleet Hub.'
              : 'All plates from the fleet hub.')
          : (de
              ? 'Angemeldete Kennzeichen aus dem Fleet Hub.'
              : 'Registered plates from the fleet hub.'),
      searchController: _searchCtrl,
      searchHint: de ? 'Kennzeichen suchen' : 'Search plate',
      onQueryChanged: (v) => setState(() => _query = plateKeyOf(v)),
      filterToggle: _PickerToggle(
        label: de
            ? 'Auch abgemeldete Fahrzeuge anzeigen'
            : 'Also show deregistered vehicles',
        value: _includeRetired,
        onChanged: (v) => setState(() => _includeRetired = v),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _PickerLoading();
          }
          if (snap.hasError) {
            return _PickerMessage(
              icon: Icons.wifi_off_rounded,
              text: de
                  ? 'Fahrzeugliste konnte nicht geladen werden. Verbindung prüfen.'
                  : 'Could not load the vehicle list. Check the connection.',
            );
          }
          final docs = (snap.data?.docs ?? const [])
              .where((d) => d.data()['isDeleted'] != true)
              .where((d) => _includeRetired || !_isRetired(d.data()))
              .where((d) => _query.isEmpty || plateKeyOf(d.id).contains(_query))
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));

          if (docs.isEmpty) {
            return _PickerMessage(
              icon: Icons.local_shipping_outlined,
              text: _query.isEmpty
                  ? (de
                      ? 'Keine angemeldeten Fahrzeuge. Schalte abgemeldete Fahrzeuge dazu, um ältere Fälle zu erfassen.'
                      : 'No registered vehicles. Include deregistered vehicles to log older cases.')
                  : (de
                      ? 'Kein Fahrzeug passt zu deiner Suche.'
                      : 'No vehicle matches your search.'),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: kIncidentBorder),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final brand = (data['brand'] ?? '').toString().trim();
              final model = (data['model'] ?? '').toString().trim();
              final subtitle = [brand, model].where((e) => e.isNotEmpty).join(' ');
              return ListTile(
                minVerticalPadding: 12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  doc.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: kIncidentText,
                  ),
                ),
                subtitle: subtitle.isEmpty
                    ? null
                    : Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kIncidentMuted,
                        ),
                      ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: kIncidentMuted,
                ),
                onTap: () => Navigator.of(context).pop(doc.id),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Picker-Gerüst ────────────────────────────────────────────────────────

class _PickerScaffold extends StatelessWidget {
  const _PickerScaffold({
    required this.title,
    required this.subtitle,
    required this.searchController,
    required this.searchHint,
    required this.onQueryChanged,
    required this.child,
    this.filterToggle,
  });

  final String title;
  final String subtitle;
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onQueryChanged;
  final Widget child;

  /// Optionaler Umschalter unter dem Suchfeld (z. B. „Auch inaktive
  /// anzeigen") — nötig, um historische Fälle nachzuerfassen.
  final Widget? filterToggle;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: kIncidentText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: kIncidentMuted),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: kIncidentText),
                decoration: incidentInputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: kIncidentMuted,
                  ),
                ),
                onChanged: onQueryChanged,
              ),
              if (filterToggle != null) filterToggle!,
              const SizedBox(height: 12),
              Expanded(child: child),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: CoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: de ? 'Abbrechen' : 'Cancel',
                  variant: CoButtonVariant.quiet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerLoading extends StatelessWidget {
  const _PickerLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(kIncidentFocus),
        ),
      ),
    );
  }
}

/// Kompakter Umschalter unter dem Suchfeld eines Pickers.
/// Tap-Ziel 44 pt hoch, obwohl der Schalter kleiner wirkt.
class _PickerToggle extends StatelessWidget {
  const _PickerToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                visualDensity: VisualDensity.compact,
                activeColor: kIncidentFocus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: kIncidentMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerMessage extends StatelessWidget {
  const _PickerMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: kIncidentMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
