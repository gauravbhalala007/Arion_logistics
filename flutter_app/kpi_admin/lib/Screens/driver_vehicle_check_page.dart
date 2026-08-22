// lib/Screens/driver_vehicle_check_page.dart
//
// Geführte Foto-Fahrzeuginspektion (Stufe 1) — Fahrer-Flow.
//
// Mobile-first Wizard: Fahrzeug → Anlass → 8 geführte Fotos →
// optionale Schadensmeldung → Zusammenfassung → speichern.
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
enum _Phase { vehicle, photos, damages, review }

class _DriverVehicleCheckPageState extends State<DriverVehicleCheckPage> {
  final _plateCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();

  _Phase _phase = _Phase.vehicle;
  int _photoIndex = 0;

  VehicleCheckType _type = VehicleCheckType.shiftStart;
  final Map<VehicleCheckStep, Uint8List> _shots =
      <VehicleCheckStep, Uint8List>{};
  final List<VehicleCheckDamage> _damages = <VehicleCheckDamage>[];

  bool _busyPicking = false;
  bool _submitting = false;
  int _uploaded = 0;
  String _driverName = '';
  String _lastPlate = '';
  bool _done = false;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String _tr(String de, String en) => _de ? de : en;

  static const List<VehicleCheckStep> _steps = VehicleCheckStep.values;

  @override
  void initState() {
    super.initState();
    _loadDriver();
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

  /// Gesamtzahl der Wizard-Seiten für die Fortschrittsleiste.
  int get _totalPages => 1 + _steps.length + 2;

  int get _pageIndex => switch (_phase) {
    _Phase.vehicle => 0,
    _Phase.photos => 1 + _photoIndex,
    _Phase.damages => 1 + _steps.length,
    _Phase.review => 1 + _steps.length + 1,
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
          setState(() => _phase = _Phase.damages);
        }
      case _Phase.damages:
        setState(() => _phase = _Phase.review);
      case _Phase.review:
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
      case _Phase.damages:
        setState(() {
          _phase = _Phase.photos;
          _photoIndex = _steps.length - 1;
        });
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
          _tr(
            'Kennzeichen genau wie am Fahrzeug eintippen — Leerzeichen und '
            'Bindestriche sind egal.',
            'Type the plate exactly as on the van — spaces and dashes do '
            'not matter.',
          ),
        ),
        const SizedBox(height: 14),
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

  // ── Phase 3: Schäden ───────────────────────────────────────────────────

  Widget _buildDamageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

  // ── Phase 4: Zusammenfassung ───────────────────────────────────────────

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
              _tr('Gemeldete Schäden', 'Reported damage'),
              '${_damages.length}',
            ),
          ],
        ),
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
      ],
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
    final label = isReview
        ? _tr('Check absenden', 'Submit check')
        : isDamages
        ? _tr('Weiter zur Übersicht', 'Continue to summary')
        : _tr('Weiter', 'Continue');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(
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
              onPressed: _submitting ? null : _next,
              style: FilledButton.styleFrom(
                backgroundColor: _kGreen,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
