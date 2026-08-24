// lib/Screens/driver_vehicle_check_page.dart
//
// Geführte Foto-Fahrzeuginspektion (Stufe 1) — Fahrer-Flow.
//
// Mobile-first Wizard: Fahrzeug → Anlass → 8 geführte Fotos →
// 12-Punkte-Sichtprüfung → optionale Schadensmeldung → Zusammenfassung →
// speichern.
//
// Sichtbarkeit steuert `driver_home_page.dart`
// (`_kVehicleCheckVisibleForDrivers`). Alle anderen Fahrer bekommen
// weiterhin den alten Ja/Nein-Sheet aus `driver_vehicle_inspection_page.dart`.
//
// Pfade + Rules-Begründung: siehe `services/vehicle_check_service.dart`.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/vehicle_check_service.dart';

/// Öffnet den geführten Check als eigene Seite (Vollbild, mobile-first).
Future<void> openDriverVehicleCheck(
  BuildContext context, {
  required String dspUid,
  required String driverTransporterId,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => DriverVehicleCheckPage(
        dspUid: dspUid,
        driverTransporterId: driverTransporterId,
      ),
    ),
  );
}

// ── Palette (identisch zu den übrigen Fahrer-Seiten) ─────────────────────
const Color _kGreen = Color(0xFF067647);
const Color _kGreenSoft = Color(0xFFE6F8F2);
const Color _kPageBg = Color(0xFFF1F3F2);
const Color _kText = Color(0xFF111827);
const Color _kMuted = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kAmber = Color(0xFFB45309);
const Color _kRed = Color(0xFFB42318);

class DriverVehicleCheckPage extends StatefulWidget {
  const DriverVehicleCheckPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  final String dspUid;
  final String driverTransporterId;

  @override
  State<DriverVehicleCheckPage> createState() => _DriverVehicleCheckPageState();
}

/// Die Wizard-Phasen. Die Foto-Schritte sind eine eigene Phase mit
/// eigenem Index, damit die Fortschrittsanzeige linear bleibt.
enum _Phase { vehicle, photos, inspection, damages, review }

class _DriverVehicleCheckPageState extends State<DriverVehicleCheckPage> {
  final _plateCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();

  _Phase _phase = _Phase.vehicle;
  int _photoIndex = 0;

  VehicleCheckType _type = VehicleCheckType.shiftStart;
  final Map<VehicleCheckStep, Uint8List> _shots =
      <VehicleCheckStep, Uint8List>{};
  final List<VehicleCheckDamage> _damages = <VehicleCheckDamage>[];

  /// Ergebnis der Sichtprüfung. Fehlender Schlüssel = noch nicht bewertet.
  final Map<VehicleCheckInspectionItem, VehicleCheckItemState> _inspection =
      <VehicleCheckInspectionItem, VehicleCheckItemState>{};

  /// Abschlussbestätigung in der Review-Phase (Kundenvorgabe).
  bool _confirmed = false;

  bool _busyPicking = false;
  bool _submitting = false;
  int _uploaded = 0;
  String _driverName = '';
  String _lastPlate = '';
  bool _done = false;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String _tr(String de, String en) => _de ? de : en;

  static const List<VehicleCheckStep> _steps = VehicleCheckStep.values;
  static const List<VehicleCheckInspectionItem> _items =
      VehicleCheckInspectionItem.values;

  /// Kennzeichen der aktiven Fahrzeuge des DSP — Auswahlliste statt
  /// Abtippen. Leer, solange nicht geladen oder wenn die Rules den
  /// Lesezugriff (noch) nicht erlauben; dann bleibt das Textfeld der Weg.
  List<String> _fleetPlates = const <String>[];
  bool _fleetLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDriver();
    _loadFleet();
  }

  /// Fahrzeugliste des DSP laden.
  ///
  /// Bewusst fehlertolerant: Scheitert die Abfrage (fehlende Freigabe,
  /// kein Netz), bleibt die Liste leer und der Fahrer tippt das
  /// Kennzeichen wie bisher ein — der Check ist dadurch nie blockiert.
  Future<void> _loadFleet() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('vehicles')
          .get();
      final plates =
          <String>{
            for (final doc in snap.docs)
              if (doc.data()['isDeleted'] != true)
                ('${doc.data()['plateNumber'] ?? doc.id}').trim().toUpperCase(),
          }.where((p) => p.isNotEmpty).toList()..sort();
      if (!mounted) return;
      setState(() {
        _fleetPlates = plates;
        _fleetLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _fleetLoading = false);
    }
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _odometerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDriver() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .doc(transporterIdOf(widget.driverTransporterId))
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      final name = <Object?>[
        data['name'],
        data['fullName'],
        data['driverName'],
      ].map((v) => '${v ?? ''}'.trim()).firstWhere(
        (v) => v.isNotEmpty,
        orElse: () => '',
      );
      final last = data['lastVehicleCheck'];
      final lastPlate = last is Map ? '${last['plate'] ?? ''}'.trim() : '';
      if (!mounted) return;
      setState(() {
        _driverName = name;
        _lastPlate = lastPlate;
      });
    } catch (_) {
      // Fahrername ist nur Komfort — ein Lesefehler darf den Check nicht
      // blockieren.
    }
  }

  // ── Helfer ─────────────────────────────────────────────────────────────

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? _kRed : _kGreen,
        content: Text(message),
      ),
    );
  }

  VehicleCheckStep get _currentStep => _steps[_photoIndex];

  int get _odometerKm => int.tryParse(_odometerCtrl.text.trim()) ?? 0;

  bool get _plateValid => plateKeyOf(_plateCtrl.text).length >= 4;

  bool get _allPhotosTaken =>
      _steps.every((s) => _shots[s] != null && _shots[s]!.isNotEmpty);

  /// Noch nicht bewertete Sichtprüfungs-Punkte.
  int get _openInspectionCount => _items.length - _inspection.length;

  bool get _inspectionComplete => _openInspectionCount == 0;

  /// Als auffällig markierte Punkte — steuert die Hinweise in Schaden- und
  /// Review-Phase.
  int get _issueCount =>
      _inspection.values.where((s) => s == VehicleCheckItemState.issue).length;

  /// Gesamtzahl der Wizard-Seiten für die Fortschrittsleiste.
  int get _totalPages => 1 + _steps.length + 3;

  int get _pageIndex => switch (_phase) {
    _Phase.vehicle => 0,
    _Phase.photos => 1 + _photoIndex,
    _Phase.inspection => 1 + _steps.length,
    _Phase.damages => 1 + _steps.length + 1,
    _Phase.review => 1 + _steps.length + 2,
  };

  // ── Foto aufnehmen ─────────────────────────────────────────────────────

  Future<void> _capture(VehicleCheckStep step) async {
    if (_busyPicking) return;
    setState(() => _busyPicking = true);
    try {
      // FilePicker rendert auf Mobile-Web ein <input accept="image/*"> —
      // iOS/Android bieten dort direkt „Kamera" an. Ein eigener
      // Kamera-Stream wäre für V1 unverhältnismäßig.
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.image,
      );
      final bytes = result?.files.firstOrNull?.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (result != null) {
          _snack(
            _tr(
              'Bild konnte nicht gelesen werden.',
              'Could not read the image.',
            ),
            error: true,
          );
        }
        return;
      }
      final compressed = await compressVehicleCheckPhoto(bytes);
      if (!mounted) return;
      setState(() => _shots[step] = compressed);
    } catch (e) {
      _snack(
        _tr('Aufnahme fehlgeschlagen: $e', 'Capture failed: $e'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busyPicking = false);
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────

  void _next() {
    FocusScope.of(context).unfocus();
    switch (_phase) {
      case _Phase.vehicle:
        if (!_plateValid) {
          _snack(
            _tr(
              'Bitte ein gültiges Kennzeichen eingeben.',
              'Please enter a valid number plate.',
            ),
            error: true,
          );
          return;
        }
        setState(() => _phase = _Phase.photos);
      case _Phase.photos:
        if (_shots[_currentStep] == null) {
          _snack(
            _tr('Bitte zuerst ein Foto machen.', 'Please take a photo first.'),
            error: true,
          );
          return;
        }
        if (_currentStep == VehicleCheckStep.odometer && _odometerKm <= 0) {
          _snack(
            _tr(
              'Bitte den Kilometerstand als Zahl eintragen.',
              'Please type the odometer reading as a number.',
            ),
            error: true,
          );
          return;
        }
        if (_photoIndex + 1 < _steps.length) {
          setState(() => _photoIndex++);
        } else {
          setState(() => _phase = _Phase.inspection);
        }
      case _Phase.inspection:
        if (!_inspectionComplete) {
          _snack(
            _tr(
              'Noch $_openInspectionCount von ${_items.length} offen.',
              '$_openInspectionCount of ${_items.length} still open.',
            ),
            error: true,
          );
          return;
        }
        setState(() => _phase = _Phase.damages);
      case _Phase.damages:
        setState(() => _phase = _Phase.review);
      case _Phase.review:
        if (!_confirmed) {
          _snack(
            _tr(
              'Bitte bestätige zuerst, dass du alles geprüft hast.',
              'Please confirm that you have checked everything.',
            ),
            error: true,
          );
          return;
        }
        _submit();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    switch (_phase) {
      case _Phase.vehicle:
        Navigator.of(context).maybePop();
      case _Phase.photos:
        if (_photoIndex == 0) {
          setState(() => _phase = _Phase.vehicle);
        } else {
          setState(() => _photoIndex--);
        }
      case _Phase.inspection:
        setState(() {
          _phase = _Phase.photos;
          _photoIndex = _steps.length - 1;
        });
      case _Phase.damages:
        setState(() => _phase = _Phase.inspection);
      case _Phase.review:
        setState(() => _phase = _Phase.damages);
    }
  }

  // ── Speichern ──────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_allPhotosTaken) {
      _snack(
        _tr('Es fehlen noch Fotos.', 'Some photos are still missing.'),
        error: true,
      );
      return;
    }
    if (_odometerKm <= 0) {
      _snack(
        _tr('Kilometerstand fehlt.', 'Odometer reading is missing.'),
        error: true,
      );
      return;
    }
    if (!_inspectionComplete) {
      _snack(
        _tr(
          'Die Sichtprüfung ist noch nicht vollständig.',
          'The visual inspection is not complete yet.',
        ),
        error: true,
      );
      return;
    }

    setState(() {
      _submitting = true;
      _uploaded = 0;
    });
    try {
      final tid = transporterIdOf(widget.driverTransporterId);
      final checkRef = vehicleCheckCollection(
        dspUid: widget.dspUid,
        transporterId: tid,
      ).doc();
      final checkId = checkRef.id;

      final photos = <VehicleCheckPhoto>[];
      for (final step in _steps) {
        final bytes = _shots[step];
        if (bytes == null) continue;
        photos.add(
          await uploadVehicleCheckPhoto(
            dspUid: widget.dspUid,
            transporterId: tid,
            checkId: checkId,
            step: step,
            jpegBytes: bytes,
          ),
        );
        if (mounted) setState(() => _uploaded = photos.length);
      }

      await saveVehicleCheck(
        dspUid: widget.dspUid,
        transporterId: tid,
        checkId: checkId,
        driverName: _driverName,
        plate: _plateCtrl.text.trim(),
        type: _type,
        odometerKm: _odometerKm,
        photos: photos,
        damages: _damages,
        inspection: _inspection,
      );

      if (!mounted) return;
      setState(() => _done = true);
    } catch (e) {
      _snack(
        _tr('Speichern fehlgeschlagen: $e', 'Could not save: $e'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Schadens-Dialog ────────────────────────────────────────────────────

  Future<void> _addDamage() async {
    final result = await showModalBottomSheet<VehicleCheckDamage>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DamageSheet(
        de: _de,
        availableSteps: _steps.where((s) => _shots[s] != null).toList(),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _damages.add(result));
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildDone();

    return Scaffold(
      backgroundColor: _kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitting ? null : _back,
          tooltip: _tr('Zurück', 'Back'),
        ),
        title: Text(
          _tr('Fahrzeug-Check', 'Vehicle check'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_pageIndex + 1) / _totalPages,
            minHeight: 4,
            backgroundColor: _kBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: switch (_phase) {
                      _Phase.vehicle => _buildVehicleStep(),
                      _Phase.photos => _buildPhotoStep(),
                      _Phase.inspection => _buildInspectionStep(),
                      _Phase.damages => _buildDamageStep(),
                      _Phase.review => _buildReviewStep(),
                    },
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Phase 1: Fahrzeug + Anlass ─────────────────────────────────────────

  Widget _buildVehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          _tr('Welches Fahrzeug fährst du?', 'Which van are you driving?'),
          _fleetPlates.isEmpty
              ? _tr(
                  'Kennzeichen genau wie am Fahrzeug eintippen — Leerzeichen '
                  'und Bindestriche sind egal.',
                  'Type the plate exactly as on the van — spaces and dashes '
                  'do not matter.',
                )
              : _tr(
                  'Aus der Liste auswählen oder Kennzeichen eintippen.',
                  'Pick it from the list or type the plate.',
                ),
        ),
        const SizedBox(height: 14),
        if (_fleetLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (_fleetPlates.isNotEmpty) ...[
          _VehiclePicker(
            plates: _fleetPlates,
            selected: plateKeyOf(_plateCtrl.text),
            lastPlate: _lastPlate,
            de: _de,
            onPick: (plate) => setState(() {
              _plateCtrl.text = plate;
              _plateCtrl.selection = TextSelection.collapsed(
                offset: plate.length,
              );
            }),
          ),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _plateCtrl,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
          decoration: InputDecoration(
            labelText: _tr('Kennzeichen', 'Number plate'),
            hintText: 'B-CD 1234',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.pin_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
          ),
        ),
        if (_lastPlate.isNotEmpty) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(Icons.history, size: 16),
              label: Text(
                _tr('Zuletzt: $_lastPlate', 'Last time: $_lastPlate'),
              ),
              onPressed: () => setState(() {
                _plateCtrl.text = _lastPlate;
                _plateCtrl.selection = TextSelection.collapsed(
                  offset: _lastPlate.length,
                );
              }),
            ),
          ),
        ],
        if (_plateCtrl.text.trim().isNotEmpty && !_plateValid) ...[
          const SizedBox(height: 8),
          Text(
            _tr(
              'Das sieht noch nicht nach einem Kennzeichen aus.',
              'That does not look like a plate yet.',
            ),
            style: const TextStyle(fontSize: 12, color: _kRed),
          ),
        ],
        const SizedBox(height: 26),
        _sectionTitle(
          _tr('Anlass', 'Reason'),
          _tr(
            'Wann machst du den Check?',
            'When are you running this check?',
          ),
        ),
        const SizedBox(height: 12),
        for (final type in VehicleCheckType.values) ...[
          _RadioTile(
            icon: type.icon,
            label: type.label(_de),
            selected: _type == type,
            onTap: () => setState(() => _type = type),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 14),
        _InfoBox(
          icon: Icons.photo_camera_outlined,
          tone: _kGreen,
          text: _tr(
            'Gleich machst du ${_steps.length} Fotos rund um das Fahrzeug. '
            'Plane etwa 3 Minuten ein und stell dich so hin, dass das '
            'ganze Fahrzeug ins Bild passt.',
            'Next you will take ${_steps.length} photos around the van. '
            'Plan about 3 minutes and stand back far enough to fit the '
            'whole van into the frame.',
          ),
        ),
      ],
    );
  }

  // ── Phase 2: geführte Fotos ────────────────────────────────────────────

  Widget _buildPhotoStep() {
    final step = _currentStep;
    final shot = _shots[step];
    final isOdometer = step == VehicleCheckStep.odometer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kGreenSoft,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${_photoIndex + 1} / ${_steps.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _kGreen,
                ),
              ),
            ),
            const Spacer(),
            Text(
              _plateCtrl.text.trim().toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _kMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          step.label(_de),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _kText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.hint(_de),
          style: const TextStyle(fontSize: 13.5, color: _kMuted, height: 1.45),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            decoration: BoxDecoration(
              color: shot == null ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: shot == null ? _kBorder : _kGreen,
                width: shot == null ? 1 : 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: shot == null
                ? _Silhouette(step: step, de: _de)
                : Image.memory(shot, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _busyPicking ? null : () => _capture(step),
                style: FilledButton.styleFrom(
                  backgroundColor: shot == null ? _kGreen : Colors.white,
                  foregroundColor: shot == null ? Colors.white : _kGreen,
                  side: shot == null
                      ? null
                      : const BorderSide(color: _kGreen, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _busyPicking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        shot == null
                            ? Icons.photo_camera_outlined
                            : Icons.refresh,
                        size: 20,
                      ),
                label: Text(
                  shot == null
                      ? _tr('Foto aufnehmen', 'Take photo')
                      : _tr('Neu aufnehmen', 'Retake'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        if (isOdometer) ...[
          const SizedBox(height: 18),
          TextField(
            controller: _odometerCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              labelText: _tr('Kilometerstand (Zahl)', 'Odometer (number)'),
              hintText: '84200',
              suffixText: 'km',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.speed_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kBorder),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tr(
              'Pflichtfeld — genau die Zahl vom Tacho, ohne Nachkommastellen.',
              'Required — exactly the number on the dashboard, no decimals.',
            ),
            style: const TextStyle(fontSize: 12, color: _kMuted),
          ),
        ],
      ],
    );
  }

  // ── Phase 3: Sichtprüfung (12 Punkte) ──────────────────────────────────

  Widget _buildInspectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          _tr('Sichtprüfung', 'Visual inspection'),
          _tr(
            'Geh die ${_items.length} Punkte am Fahrzeug durch und sag zu '
            'jedem, ob er in Ordnung ist. Alles nur mit den Augen — du '
            'musst nichts messen.',
            'Walk through the ${_items.length} points on the van and say '
            'for each one whether it is fine. Eyes only — you do not have '
            'to measure anything.',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _inspectionComplete ? _kGreenSoft : Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: _inspectionComplete ? _kGreen : _kBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _inspectionComplete
                    ? Icons.check_circle_outline
                    : Icons.checklist_rtl,
                size: 18,
                color: _inspectionComplete ? _kGreen : _kMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _inspectionComplete
                      ? _tr(
                          'Alle ${_items.length} Punkte bewertet.',
                          'All ${_items.length} points rated.',
                        )
                      : _tr(
                          'Noch $_openInspectionCount von ${_items.length} '
                          'offen',
                          '$_openInspectionCount of ${_items.length} still '
                          'open',
                        ),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _inspectionComplete ? _kGreen : _kMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _items.length; i++) ...[
          _InspectionCard(
            index: i + 1,
            total: _items.length,
            item: _items[i],
            de: _de,
            state: _inspection[_items[i]],
            onSelect: (state) =>
                setState(() => _inspection[_items[i]] = state),
            onOpenImage: () => _openExampleImage(_items[i]),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        _InfoBox(
          icon: Icons.image_outlined,
          tone: _kMuted,
          text: _tr(
            'Beispielbilder — so sieht ein Mangel typischerweise aus.',
            'Example photos — this is what a defect typically looks like.',
          ),
        ),
      ],
    );
  }

  /// Beispielbild groß: abgedunkelter Hintergrund, Bild vollflächig, Titel
  /// darunter (Muster wie `_showQrPopup` in `fleet_status_page.dart`).
  void _openExampleImage(VehicleCheckInspectionItem item) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  maxScale: 5,
                  child: Image.asset(item.asset, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.label(_de),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _tr(
                'Beispielbild — so sieht ein Mangel typischerweise aus.',
                'Example photo — this is what a defect typically looks like.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              child: Text(_tr('Schließen', 'Close')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phase 4: Schäden ───────────────────────────────────────────────────

  Widget _buildDamageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_issueCount > 0) ...[
          _InfoBox(
            icon: Icons.warning_amber_rounded,
            tone: _kAmber,
            text: _tr(
              'Du hast $_issueCount ${_issueCount == 1 ? 'Punkt' : 'Punkte'} '
              'als auffällig markiert — bitte melde sie unten als Schaden '
              'mit Foto.',
              'You marked $_issueCount '
              '${_issueCount == 1 ? 'point' : 'points'} as an issue — '
              'please report them below as damage with a photo.',
            ),
          ),
          const SizedBox(height: 14),
        ],
        _sectionTitle(
          _tr('Schäden melden', 'Report damage'),
          _tr(
            'Optional. Melde alles, was dir auffällt — auch alte Schäden. '
            'Der Admin sieht sofort, was seit dem letzten Check neu ist.',
            'Optional. Report anything you notice — old damage too. The '
            'admin instantly sees what is new since the last check.',
          ),
        ),
        const SizedBox(height: 14),
        if (_damages.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: [
                const Icon(Icons.verified_outlined, size: 30, color: _kGreen),
                const SizedBox(height: 8),
                Text(
                  _tr('Keine Schäden gemeldet.', 'No damage reported.'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < _damages.length; i++) ...[
            _DamageRow(
              damage: _damages[i],
              de: _de,
              onRemove: () => setState(() => _damages.removeAt(i)),
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _addDamage,
          style: OutlinedButton.styleFrom(
            foregroundColor: _kGreen,
            side: const BorderSide(color: _kGreen, width: 1.3),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          icon: const Icon(Icons.add, size: 19),
          label: Text(
            _tr('Schaden hinzufügen', 'Add damage'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  // ── Phase 5: Zusammenfassung ───────────────────────────────────────────

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          _tr('Alles korrekt?', 'All correct?'),
          _tr(
            'Nach dem Absenden landet der Check direkt beim Fleet-Team.',
            'Once submitted the check goes straight to the fleet team.',
          ),
        ),
        const SizedBox(height: 14),
        _SummaryCard(
          rows: <(String, String)>[
            (
              _tr('Kennzeichen', 'Number plate'),
              _plateCtrl.text.trim().toUpperCase(),
            ),
            (_tr('Anlass', 'Reason'), _type.label(_de)),
            (
              _tr('Kilometerstand', 'Odometer'),
              '${formatVehicleCheckKm(_odometerKm)} km',
            ),
            (
              _tr('Fotos', 'Photos'),
              '${_shots.length} / ${_steps.length}',
            ),
            (
              _tr('Sichtprüfung', 'Visual inspection'),
              _issueCount == 0
                  ? _tr(
                      'alle ${_items.length} in Ordnung',
                      'all ${_items.length} OK',
                    )
                  : _tr(
                      '$_issueCount von ${_items.length} auffällig',
                      '$_issueCount of ${_items.length} flagged',
                    ),
            ),
            (
              _tr('Gemeldete Schäden', 'Reported damage'),
              '${_damages.length}',
            ),
          ],
        ),
        if (_issueCount > 0) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final item in _items)
                if (_inspection[item] == VehicleCheckItemState.issue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _kAmber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: _kAmber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 14, color: _kAmber),
                        const SizedBox(width: 6),
                        Text(
                          item.label(_de),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _kAmber,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
          children: <Widget>[
            for (final step in _steps)
              GestureDetector(
                onTap: () => setState(() {
                  _phase = _Phase.photos;
                  _photoIndex = _steps.indexOf(step);
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _shots[step] == null
                      ? Icon(step.icon, color: _kMuted, size: 20)
                      : Image.memory(_shots[step]!, fit: BoxFit.cover),
                ),
              ),
          ],
        ),
        if (_submitting) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _steps.isEmpty ? null : _uploaded / _steps.length,
            minHeight: 6,
            backgroundColor: _kBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
          ),
          const SizedBox(height: 6),
          Text(
            _tr(
              'Lade Fotos hoch … $_uploaded / ${_steps.length}',
              'Uploading photos … $_uploaded / ${_steps.length}',
            ),
            style: const TextStyle(fontSize: 12, color: _kMuted),
          ),
        ],
        const SizedBox(height: 18),
        _buildConfirmBox(),
      ],
    );
  }

  /// Abschlussbestätigung direkt über dem Absende-Button. Ohne Haken bleibt
  /// der Button im Footer inaktiv.
  Widget _buildConfirmBox() {
    final flagged = _issueCount > 0;
    final tone = flagged ? _kAmber : _kGreen;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.45), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                flagged
                    ? Icons.warning_amber_rounded
                    : Icons.help_outline_rounded,
                size: 20,
                color: tone,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _tr(
                    'Bist du sicher, dass alles in Ordnung ist?',
                    'Are you sure everything is in order?',
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: tone,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _tr(
              'Im Zweifel immer den Dispatcher fragen.',
              'If in doubt, always ask your dispatcher.',
            ),
            style: TextStyle(fontSize: 13, color: tone, height: 1.4),
          ),
          if (flagged) ...[
            const SizedBox(height: 6),
            Text(
              _tr(
                'Du hast $_issueCount '
                '${_issueCount == 1 ? 'Punkt' : 'Punkte'} als auffällig '
                'markiert — informiere zusätzlich deinen Dispatcher.',
                'You marked $_issueCount '
                '${_issueCount == 1 ? 'point' : 'points'} as an issue — '
                'please also inform your dispatcher.',
              ),
              style: TextStyle(fontSize: 12.5, color: tone, height: 1.4),
            ),
          ],
          const SizedBox(height: 2),
          InkWell(
            onTap: _submitting
                ? null
                : () => setState(() => _confirmed = !_confirmed),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Checkbox(
                      value: _confirmed,
                      activeColor: tone,
                      onChanged: _submitting
                          ? null
                          : (v) => setState(() => _confirmed = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _tr(
                        'Ja, ich habe alles geprüft.',
                        'Yes, I have checked everything.',
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: tone,
                      ),
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

  // ── Abschluss ──────────────────────────────────────────────────────────

  Widget _buildDone() {
    return Scaffold(
      backgroundColor: _kPageBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: _kGreenSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _kGreen,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _tr('Check gespeichert', 'Check saved'),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tr(
                    'Danke! Dein Fleet-Team sieht den Check jetzt in der '
                    'Fahrzeugakte.',
                    'Thanks! Your fleet team can now see the check in the '
                    'vehicle file.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _kMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                  ),
                  child: Text(_tr('Fertig', 'Done')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final isReview = _phase == _Phase.review;
    final isDamages = _phase == _Phase.damages;
    final isInspection = _phase == _Phase.inspection;
    final label = isReview
        ? _tr('Check absenden', 'Submit check')
        : isDamages
        ? _tr('Weiter zur Übersicht', 'Continue to summary')
        : _tr('Weiter', 'Continue');

    // Zwei harte Gates: die Sichtprüfung muss vollständig sein, und der
    // Fahrer muss die Abschlussfrage bestätigt haben.
    final blocked =
        (isInspection && !_inspectionComplete) || (isReview && !_confirmed);
    final blockedHint = isInspection
        ? _tr(
            'Noch $_openInspectionCount von ${_items.length} offen',
            '$_openInspectionCount of ${_items.length} still open',
          )
        : _tr(
            'Bitte oben bestätigen, dass du alles geprüft hast.',
            'Please confirm above that you have checked everything.',
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (blocked) ...[
            Row(
              children: [
                const Icon(Icons.info_outline, size: 15, color: _kAmber),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    blockedHint,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (_phase != _Phase.vehicle) ...[
                OutlinedButton(
                  onPressed: _submitting ? null : _back,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kMuted,
                    side: const BorderSide(color: _kBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                  ),
                  child: Text(_tr('Zurück', 'Back')),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: (_submitting || blocked) ? null : _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: _kGreen,
                    disabledBackgroundColor: _kBorder,
                    disabledForegroundColor: _kMuted,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          isReview ? Icons.send_rounded : Icons.arrow_forward,
                          size: 19,
                        ),
                  label: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: _kText,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 13.5, color: _kMuted, height: 1.45),
      ),
    ],
  );
}

// ═════════════════════════════════════════════════════════════════════════
//  Kleinteile
// ═════════════════════════════════════════════════════════════════════════

/// Beispiel-Umriss je Schritt: ein großes Icon plus Positionsmarke. Bewusst
/// nur `Icons.*` — Material Symbols laden im Web-Build nicht zuverlässig.
class _Silhouette extends StatelessWidget {
  const _Silhouette({required this.step, required this.de});

  final VehicleCheckStep step;
  final bool de;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _FramePainter()),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(step.icon, size: 62, color: _kBorder),
            const SizedBox(height: 10),
            Text(
              de ? 'So ausrichten' : 'Line it up like this',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Gestrichelter Sucherrahmen — visualisiert, wie weit weg der Fahrer
/// stehen soll.
class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const inset = 18.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    const corner = 26.0;
    // Nur die vier Ecken zeichnen — das liest sich als Sucher, nicht als Box.
    for (final (dx, dy, sx, sy) in <(double, double, double, double)>[
      (rect.left, rect.top, 1, 1),
      (rect.right, rect.top, -1, 1),
      (rect.left, rect.bottom, 1, -1),
      (rect.right, rect.bottom, -1, -1),
    ]) {
      canvas.drawLine(Offset(dx, dy), Offset(dx + corner * sx, dy), paint);
      canvas.drawLine(Offset(dx, dy), Offset(dx, dy + corner * sy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _kGreenSoft : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kGreen : _kBorder,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? _kGreen : _kMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? _kGreen : _kText,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? _kGreen : _kBorder,
            ),
          ],
        ),
      ),
    );
  }
}

/// Eine Karte der 12-Punkte-Sichtprüfung: Titel, Hilfstext, Beispielbild
/// und die beiden Bewertungs-Schaltflächen.
///
/// Mobile-first: alles untereinander, Tap-Flächen ≥ 48 px, Bild nur so groß
/// wie nötig (4:3, `BoxFit.cover`).
class _InspectionCard extends StatelessWidget {
  const _InspectionCard({
    required this.index,
    required this.total,
    required this.item,
    required this.de,
    required this.state,
    required this.onSelect,
    required this.onOpenImage,
  });

  final int index;
  final int total;
  final VehicleCheckInspectionItem item;
  final bool de;
  final VehicleCheckItemState? state;
  final ValueChanged<VehicleCheckItemState> onSelect;
  final VoidCallback onOpenImage;

  @override
  Widget build(BuildContext context) {
    final isOk = state == VehicleCheckItemState.ok;
    final isIssue = state == VehicleCheckItemState.issue;
    final border = isOk
        ? _kGreen
        : isIssue
        ? _kAmber
        : _kBorder;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: state == null ? 1 : 1.8),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isIssue
                      ? _kAmber.withValues(alpha: 0.12)
                      : _kGreenSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isIssue ? _kAmber : _kGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label(de),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.hint(de),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _kMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(item.icon, size: 20, color: _kMuted),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onOpenImage,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item.asset,
                        fit: BoxFit.cover,
                        // Alle 12 Karten hängen in derselben Scroll-Column,
                        // werden also gleichzeitig dekodiert. Ohne
                        // `cacheWidth` wären das 12 × ~3 MB Raster auf einem
                        // Fahrer-Handy; die Vollauflösung liefert der
                        // Lightbox-Dialog.
                        cacheWidth: 720,
                        errorBuilder: (_, _, _) => Container(
                          color: _kPageBg,
                          alignment: Alignment.center,
                          child: Icon(item.icon, size: 34, color: _kBorder),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.zoom_out_map,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                de ? 'Beispiel' : 'Example',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StateButton(
                  icon: Icons.check_circle_outline,
                  label: de ? 'In Ordnung' : 'OK',
                  tone: _kGreen,
                  selected: isOk,
                  onTap: () => onSelect(VehicleCheckItemState.ok),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StateButton(
                  icon: Icons.error_outline,
                  label: de ? 'Auffällig' : 'Issue',
                  tone: _kAmber,
                  selected: isIssue,
                  onTap: () => onSelect(VehicleCheckItemState.issue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// „In Ordnung" / „Auffällig" — bewusst zwei getrennte, große Flächen
/// statt eines Toggles, damit auf dem Handy nichts versehentlich kippt.
class _StateButton extends StatelessWidget {
  const _StateButton({
    required this.icon,
    required this.label,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? tone.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? tone : _kBorder,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: selected ? tone : _kMuted),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selected ? tone : _kText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text, required this.tone});

  final IconData icon;
  final String text;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: tone, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].$1,
                      style: const TextStyle(fontSize: 13, color: _kMuted),
                    ),
                  ),
                  Text(
                    rows[i].$2,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DamageRow extends StatelessWidget {
  const _DamageRow({
    required this.damage,
    required this.de,
    required this.onRemove,
  });

  final VehicleCheckDamage damage;
  final bool de;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final sub = <String>[
      damage.location.label(de),
      if (damage.photoStep != null) damage.photoStep!.label(de),
      if (damage.comment.isNotEmpty) damage.comment,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Icon(damage.category.icon, size: 20, color: _kAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  damage.category.label(de),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 11.5, color: _kMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: _kMuted,
            onPressed: onRemove,
            tooltip: de ? 'Entfernen' : 'Remove',
          ),
        ],
      ),
    );
  }
}

/// Bottom-Sheet zum Erfassen eines Schadens.
class _DamageSheet extends StatefulWidget {
  const _DamageSheet({required this.de, required this.availableSteps});

  final bool de;
  final List<VehicleCheckStep> availableSteps;

  @override
  State<_DamageSheet> createState() => _DamageSheetState();
}

class _DamageSheetState extends State<_DamageSheet> {
  VehicleDamageCategory _category = VehicleDamageCategory.scratch;
  VehicleDamageLocation _location = VehicleDamageLocation.front;
  VehicleCheckStep? _step;
  final _commentCtrl = TextEditingController();

  bool get _de => widget.de;
  String _tr(String de, String en) => _de ? de : en;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _tr('Schaden erfassen', 'Record damage'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 16),
              _label(_tr('Kategorie', 'Category')),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final c in VehicleDamageCategory.values)
                    ChoiceChip(
                      avatar: Icon(c.icon, size: 15),
                      label: Text(c.label(_de)),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _label(_tr('Stelle am Fahrzeug', 'Location on the van')),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final l in VehicleDamageLocation.values)
                    ChoiceChip(
                      label: Text(l.label(_de)),
                      selected: _location == l,
                      onSelected: (_) => setState(() => _location = l),
                    ),
                ],
              ),
              if (widget.availableSteps.isNotEmpty) ...[
                const SizedBox(height: 16),
                _label(_tr('Auf welchem Foto?', 'On which photo?')),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ChoiceChip(
                      label: Text(_tr('Keins', 'None')),
                      selected: _step == null,
                      onSelected: (_) => setState(() => _step = null),
                    ),
                    for (final s in widget.availableSteps)
                      ChoiceChip(
                        label: Text(s.label(_de)),
                        selected: _step == s,
                        onSelected: (_) => setState(() => _step = s),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _label(_tr('Kommentar', 'Comment')),
              TextField(
                controller: _commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: _tr(
                    'z. B. „Kratzer ca. 20 cm über dem Radlauf"',
                    'e.g. "≈20 cm scratch above the wheel arch"',
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  VehicleCheckDamage(
                    category: _category,
                    location: _location,
                    photoStep: _step,
                    comment: _commentCtrl.text.trim(),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _tr('Schaden übernehmen', 'Add damage'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: _kMuted,
        letterSpacing: 0.5,
      ),
    ),
  );
}

/// Auswahl des eigenen Fahrzeugs aus der Flotte des DSP.
///
/// Bewusst als Suchfeld plus Kachelraster statt Dropdown: Auf dem Handy
/// mit 60+ Fahrzeugen ist Tippen schneller als Scrollen, und das zuletzt
/// gefahrene Fahrzeug steht immer ganz oben.
class _VehiclePicker extends StatefulWidget {
  const _VehiclePicker({
    required this.plates,
    required this.selected,
    required this.lastPlate,
    required this.de,
    required this.onPick,
  });

  final List<String> plates;

  /// Bereits gewähltes Kennzeichen als Vergleichsschlüssel.
  final String selected;
  final String lastPlate;
  final bool de;
  final ValueChanged<String> onPick;

  @override
  State<_VehiclePicker> createState() => _VehiclePickerState();
}

class _VehiclePickerState extends State<_VehiclePicker> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _visible {
    final needle = plateKeyOf(_search.text);
    final all = <String>[
      // Zuletzt gefahren zuerst — der häufigste Fall.
      if (widget.lastPlate.isNotEmpty &&
          widget.plates.any(
            (p) => plateKeyOf(p) == plateKeyOf(widget.lastPlate),
          ))
        widget.plates.firstWhere(
          (p) => plateKeyOf(p) == plateKeyOf(widget.lastPlate),
        ),
      ...widget.plates.where(
        (p) => plateKeyOf(p) != plateKeyOf(widget.lastPlate),
      ),
    ];
    if (needle.isEmpty) return all;
    return all.where((p) => plateKeyOf(p).contains(needle)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final de = widget.de;
    final visible = _visible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.plates.length > 8)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: _search,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                isDense: true,
                hintText: de ? 'Kennzeichen suchen…' : 'Search plate…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(_search.clear),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
              ),
            ),
          ),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              de
                  ? 'Kein Fahrzeug gefunden — tipp das Kennzeichen unten ein.'
                  : 'No vehicle found — type the plate below.',
              style: const TextStyle(fontSize: 12.5, color: _kMuted),
            ),
          )
        else
          ConstrainedBox(
            // Höhe deckelt die Liste, damit das Textfeld darunter bei
            // großen Flotten sichtbar bleibt.
            constraints: const BoxConstraints(maxHeight: 232),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final plate in visible)
                    _PlateChip(
                      plate: plate,
                      active: plateKeyOf(plate) == widget.selected,
                      isLast: widget.lastPlate.isNotEmpty &&
                          plateKeyOf(plate) == plateKeyOf(widget.lastPlate),
                      de: de,
                      onTap: () => widget.onPick(plate),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PlateChip extends StatelessWidget {
  const _PlateChip({
    required this.plate,
    required this.active,
    required this.isLast,
    required this.de,
    required this.onTap,
  });

  final String plate;
  final bool active;
  final bool isLast;
  final bool de;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1D7F5A);
    return Material(
      color: active ? green : Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? green : _kBorder,
              width: active ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLast) ...[
                Icon(
                  Icons.history,
                  size: 15,
                  color: active ? Colors.white70 : _kMuted,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                plate,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: active ? Colors.white : const Color(0xFF111827),
                ),
              ),
              if (active) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
