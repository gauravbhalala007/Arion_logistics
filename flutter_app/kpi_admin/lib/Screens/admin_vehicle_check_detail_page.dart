// lib/Screens/admin_vehicle_check_detail_page.dart
//
// Admin-Detailansicht eines geführten Fahrzeug-Checks.
//
// Erreichbar über die Events-Spalte der Fahrzeug-Detailseite: die Cloud
// Function `onVehicleCheckCreated` spiegelt jeden Check als Event nach
// `users/{dspUid}/fleet_events` und legt dort `checkPath` ab.
//
// Zeigt:
//   • Kopfzeile (Kennzeichen, Anlass, Fahrer, Zeit, Kilometerstand)
//   • Fotogalerie aller Schritte, mit Vorher/Nachher-Vergleich gegen einen
//     frei wählbaren zweiten Check desselben Fahrzeugs
//   • Ergebnis der 12-Punkte-Sichtprüfung des Fahrers (auffällige Punkte
//     hervorgehoben) — fehlt bei Checks aus der Zeit davor
//   • Schadenliste mit „NEU"-Badge gegenüber dem Vorgänger-Check
//   • KI-Befunde (Stufe 2) — immer als Vorschlag, nie automatisch
//     übernommen
//   • „Als Vorfall melden" → öffnet das bestehende Incident-Formular mit
//     Fahrzeug + Fahrer vorbefüllt

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/incident_reports.dart' show kIncidentVehicle;
import '../services/vehicle_check_service.dart';
import '../widgets/admin_scope.dart';
import 'admin_incident_form_page.dart';

const Color _kGreen = Color(0xFF067647);
const Color _kGreenSoft = Color(0xFFE6F8F2);
const Color _kPageBg = Color(0xFFF6F7F7);
const Color _kText = Color(0xFF111827);
const Color _kMuted = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kAmber = Color(0xFFB45309);
const Color _kAmberSoft = Color(0xFFFEF3C7);
const Color _kRed = Color(0xFFB42318);
const Color _kBlue = Color(0xFF1D4ED8);
const Color _kBlueSoft = Color(0xFFEAF0FE);

/// Öffnet die Check-Detailansicht als eigene Route.
Future<void> openAdminVehicleCheckDetail(
  BuildContext context, {
  required String dspUid,
  required String checkPath,
  bool canManage = true,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => AdminScope(
        adminUid: dspUid,
        child: AdminVehicleCheckDetailPage(
          dspUid: dspUid,
          checkPath: checkPath,
          canManage: canManage,
        ),
      ),
    ),
  );
}

class AdminVehicleCheckDetailPage extends StatefulWidget {
  const AdminVehicleCheckDetailPage({
    super.key,
    required this.dspUid,
    required this.checkPath,
    this.canManage = true,
  });

  final String dspUid;
  final String checkPath;
  final bool canManage;

  @override
  State<AdminVehicleCheckDetailPage> createState() =>
      _AdminVehicleCheckDetailPageState();
}

/// Ein Eintrag des Vergleichs-Pickers — aus `fleet_events` gelesen, damit
/// wir nicht über alle Fahrer-Subcollections iterieren müssen.
class _CheckRef {
  const _CheckRef({required this.path, required this.date, required this.km});

  final String path;
  final DateTime? date;
  final int? km;
}

class _AdminVehicleCheckDetailPageState
    extends State<AdminVehicleCheckDetailPage> {
  VehicleCheck? _check;
  VehicleCheck? _previous;
  VehicleCheck? _compare;
  List<_CheckRef> _siblings = const <_CheckRef>[];
  String _error = '';
  bool _loading = true;
  bool _busy = false;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String _tr(String de, String en) => _de ? de : en;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final snap = await FirebaseFirestore.instance
          .doc(widget.checkPath)
          .get();
      if (!snap.exists) {
        setState(() {
          _loading = false;
          _error = _tr('Check nicht gefunden.', 'Check not found.');
        });
        return;
      }
      final check = VehicleCheck.fromSnapshot(snap);
      final siblings = await _loadSiblings(check);
      final previousRef = _previousOf(siblings, check);
      final previous = previousRef == null
          ? null
          : await _loadByPath(previousRef.path);
      if (!mounted) return;
      setState(() {
        _check = check;
        _siblings = siblings;
        _previous = previous;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  /// Alle Checks desselben Fahrzeugs — Quelle ist der Fleet-Event-Spiegel.
  Future<List<_CheckRef>> _loadSiblings(VehicleCheck check) async {
    if (check.plateKey.isEmpty) return const <_CheckRef>[];
    try {
      final snap = await fleetEventsCollection(widget.dspUid)
          .where('plateKey', isEqualTo: check.plateKey)
          .where('type', isEqualTo: kVehicleCheckEventType)
          .get();
      final out = <_CheckRef>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final path = '${data['checkPath'] ?? ''}'.trim();
        if (path.isEmpty) continue;
        final km = data['km'];
        out.add(
          _CheckRef(
            path: path,
            date: (data['date'] as Timestamp?)?.toDate(),
            km: km is num ? km.toInt() : null,
          ),
        );
      }
      out.sort((a, b) {
        final ad = a.date;
        final bd = b.date;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return out;
    } catch (_) {
      // Ohne deployte Spiegel-Function gibt es (noch) keine Events — dann
      // entfällt der Vergleich, der Rest der Seite funktioniert weiter.
      return const <_CheckRef>[];
    }
  }

  _CheckRef? _previousOf(List<_CheckRef> siblings, VehicleCheck check) {
    final at = check.checkedAt;
    if (at == null) return null;
    for (final ref in siblings) {
      if (ref.path == check.path) continue;
      final d = ref.date;
      if (d != null && d.isBefore(at)) return ref;
    }
    return null;
  }

  Future<VehicleCheck?> _loadByPath(String path) async {
    try {
      final snap = await FirebaseFirestore.instance.doc(path).get();
      if (!snap.exists) return null;
      return VehicleCheck.fromSnapshot(snap);
    } catch (_) {
      return null;
    }
  }

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error ? _kRed : _kGreen,
        content: Text(message),
      ),
    );
  }

  // ── Aktionen ───────────────────────────────────────────────────────────

  /// Übernimmt einen KI-Kandidaten in die verbindliche Schadenliste.
  Future<void> _acceptCandidate(VehicleCheckAiCandidate candidate) async {
    final check = _check;
    if (check == null || _busy) return;
    setState(() => _busy = true);
    try {
      final damage = VehicleCheckDamage(
        category: candidate.category,
        location: _locationForStep(candidate.step),
        photoStep: candidate.step,
        comment: candidate.description,
        source: 'ai',
      );
      await FirebaseFirestore.instance.doc(check.path).update(<String, dynamic>{
        'damages': FieldValue.arrayUnion(<Map<String, dynamic>>[
          damage.toMap(),
        ]),
        'damageCount': check.damages.length + 1,
        'aiAcceptedAt': FieldValue.serverTimestamp(),
      });
      _snack(_tr('Als Schaden übernommen.', 'Added as damage.'));
      await _load();
    } catch (e) {
      _snack(
        _tr('Übernehmen fehlgeschlagen: $e', 'Could not accept: $e'),
        error: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static VehicleDamageLocation _locationForStep(VehicleCheckStep? step) =>
      switch (step) {
        VehicleCheckStep.front ||
        VehicleCheckStep.cornerFrontLeft => VehicleDamageLocation.front,
        VehicleCheckStep.rear ||
        VehicleCheckStep.cornerRearRight => VehicleDamageLocation.rear,
        VehicleCheckStep.left => VehicleDamageLocation.left,
        VehicleCheckStep.right => VehicleDamageLocation.right,
        VehicleCheckStep.interior => VehicleDamageLocation.interior,
        _ => VehicleDamageLocation.front,
      };

  Future<void> _reportAsIncident() async {
    final check = _check;
    if (check == null) return;
    final damageText = check.damages
        .map(
          (d) => <String>[
            d.category.label(_de),
            d.location.label(_de),
            if (d.comment.isNotEmpty) d.comment,
          ].join(' · '),
        )
        .join('\n');
    final description = <String>[
      _tr(
        'Aus Fahrzeug-Check vom '
            '${_fmtDateTime(check.checkedAt)} (${check.type.label(_de)}).',
        'From vehicle check on '
            '${_fmtDateTime(check.checkedAt)} (${check.type.label(_de)}).',
      ),
      '${_tr('Kilometerstand', 'Odometer')}: '
          '${formatVehicleCheckKm(check.odometerKm)} km',
      if (damageText.isNotEmpty) damageText,
    ].join('\n');

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AdminScope(
          adminUid: widget.dspUid,
          child: AdminIncidentFormPage(
            dspUid: widget.dspUid,
            category: kIncidentVehicle,
            initialData: <String, dynamic>{
              'plate': check.plate,
              'plateKey': check.plateKey,
              'driverTransporterId': check.driverTransporterId,
              'driverName': check.driverName,
              'description': description,
              'damage': damageText,
              if (check.checkedAt != null)
                'occurredAt': Timestamp.fromDate(check.checkedAt!),
              if (check.checkedAt != null)
                'timeText': DateFormat('HH:mm').format(check.checkedAt!),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickCompare() async {
    final check = _check;
    if (check == null) return;
    final options = _siblings.where((s) => s.path != check.path).toList();
    if (options.isEmpty) {
      _snack(
        _tr(
          'Für dieses Fahrzeug gibt es noch keinen zweiten Check.',
          'There is no second check for this van yet.',
        ),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title: Text(
                _tr('Vergleichs-Check wählen', 'Pick a check to compare'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: _compare == null
                  ? null
                  : TextButton(
                      onPressed: () => Navigator.of(ctx).pop('__none__'),
                      child: Text(_tr('Aufheben', 'Clear')),
                    ),
            ),
            const Divider(height: 1),
            for (final option in options)
              ListTile(
                leading: const Icon(Icons.fact_check_outlined),
                title: Text(_fmtDateTime(option.date)),
                subtitle: option.km == null
                    ? null
                    : Text('${formatVehicleCheckKm(option.km!)} km'),
                onTap: () => Navigator.of(ctx).pop(option.path),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    if (picked == '__none__') {
      setState(() => _compare = null);
      return;
    }
    final loaded = await _loadByPath(picked);
    if (!mounted) return;
    if (loaded == null) {
      _snack(
        _tr('Vergleichs-Check nicht lesbar.', 'Could not read that check.'),
        error: true,
      );
      return;
    }
    setState(() => _compare = loaded);
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final check = _check;
    return Scaffold(
      backgroundColor: _kPageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          _tr('Fahrzeug-Check', 'Vehicle check'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          if (check != null)
            IconButton(
              tooltip: _tr('Vorher/Nachher', 'Before/after'),
              icon: Icon(
                _compare == null ? Icons.compare_outlined : Icons.compare,
                color: _compare == null ? _kMuted : _kGreen,
              ),
              onPressed: _pickCompare,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _kRed),
                ),
              ),
            )
          : check == null
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 940),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: <Widget>[
                    _header(check),
                    const SizedBox(height: 14),
                    _damagesCard(check),
                    // Alte Checks tragen kein `inspection`-Feld — dann
                    // entfällt die Karte ersatzlos.
                    if (check.inspection.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 14),
                      _inspectionCard(check),
                    ],
                    const SizedBox(height: 14),
                    _aiCard(check),
                    const SizedBox(height: 14),
                    _photosCard(check),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _card({required String title, Widget? trailing, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _header(VehicleCheck check) {
    return _card(
      title: check.plate.isEmpty
          ? _tr('Ohne Kennzeichen', 'No plate')
          : check.plate.toUpperCase(),
      trailing: widget.canManage
          ? TextButton.icon(
              onPressed: _reportAsIncident,
              icon: const Icon(Icons.report_gmailerrorred_outlined, size: 18),
              label: Text(_tr('Als Vorfall melden', 'Report as incident')),
              style: TextButton.styleFrom(foregroundColor: _kRed),
            )
          : null,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          _fact(
            Icons.event_note_outlined,
            _tr('Anlass', 'Reason'),
            check.type.label(_de),
          ),
          _fact(
            Icons.speed_outlined,
            _tr('Kilometerstand', 'Odometer'),
            '${formatVehicleCheckKm(check.odometerKm)} km',
          ),
          _fact(
            Icons.person_outline,
            _tr('Fahrer', 'Driver'),
            check.driverName.isEmpty
                ? check.driverTransporterId
                : '${check.driverName} · ${check.driverTransporterId}',
          ),
          _fact(
            Icons.schedule,
            _tr('Zeitpunkt', 'Time'),
            _fmtDateTime(check.checkedAt),
          ),
          _fact(
            Icons.photo_library_outlined,
            _tr('Fotos', 'Photos'),
            '${check.photos.length}',
          ),
        ],
      ),
    );
  }

  Widget _fact(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _kPageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: _kMuted),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(fontSize: 10.5, color: _kMuted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Schäden ────────────────────────────────────────────────────────────

  Widget _damagesCard(VehicleCheck check) {
    final newSignatures = newDamageSignatures(
      current: check,
      previous: _previous,
    );
    return _card(
      title: _tr(
        'Gemeldete Schäden (${check.damages.length})',
        'Reported damage (${check.damages.length})',
      ),
      trailing: _previous == null
          ? _pill(
              _tr('Kein Vorgänger-Check', 'No previous check'),
              _kMuted,
              _kPageBg,
            )
          : _pill(
              _tr(
                'Vergleich: ${_fmtDateTime(_previous!.checkedAt)}',
                'Compared to ${_fmtDateTime(_previous!.checkedAt)}',
              ),
              _kBlue,
              _kBlueSoft,
            ),
      child: check.damages.isEmpty
          ? Row(
              children: <Widget>[
                const Icon(Icons.verified_outlined, size: 20, color: _kGreen),
                const SizedBox(width: 10),
                Text(
                  _tr(
                    'Der Fahrer hat keine Schäden gemeldet.',
                    'The driver reported no damage.',
                  ),
                  style: const TextStyle(fontSize: 13, color: _kMuted),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (var i = 0; i < check.damages.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _damageTile(
                    check.damages[i],
                    isNew: newSignatures.contains(check.damages[i].signature),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _damageTile(VehicleCheckDamage damage, {required bool isNew}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isNew ? _kAmberSoft : _kPageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isNew ? _kAmber : _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(damage.category.icon, size: 19, color: _kAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        '${damage.category.label(_de)} · '
                        '${damage.location.label(_de)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      _pill(_tr('NEU', 'NEW'), Colors.white, _kAmber),
                    ],
                    if (damage.source == 'ai') ...[
                      const SizedBox(width: 6),
                      _pill(_tr('aus KI', 'from AI'), _kBlue, _kBlueSoft),
                    ],
                  ],
                ),
                if (damage.comment.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    damage.comment,
                    style: const TextStyle(fontSize: 12, color: _kMuted),
                  ),
                ],
                if (damage.photoStep != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${_tr('Foto', 'Photo')}: '
                    '${damage.photoStep!.label(_de)}',
                    style: const TextStyle(fontSize: 11, color: _kMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sichtprüfung ───────────────────────────────────────────────────────

  /// 12-Punkte-Sichtprüfung des Fahrers: auffällige Punkte groß und amber,
  /// die als in Ordnung gemeldeten dezent als Chip-Reihe darunter.
  Widget _inspectionCard(VehicleCheck check) {
    final issues = check.inspectionIssues;
    final rated = check.inspection.length;
    final total = VehicleCheckInspectionItem.values.length;
    final okItems = <VehicleCheckInspectionItem>[
      for (final item in VehicleCheckInspectionItem.values)
        if (check.inspection[item] == VehicleCheckItemState.ok) item,
    ];
    final missing = total - rated;

    return _card(
      title: _tr(
        'Sichtprüfung ($rated/$total bewertet)',
        'Visual inspection ($rated/$total rated)',
      ),
      trailing: issues.isEmpty
          ? _pill(
              _tr('Alles in Ordnung', 'All clear'),
              _kGreen,
              _kGreenSoft,
            )
          : _pill(
              _tr(
                '${issues.length} auffällig',
                '${issues.length} flagged',
              ),
              Colors.white,
              _kAmber,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (issues.isEmpty)
            Row(
              children: <Widget>[
                const Icon(Icons.verified_outlined, size: 20, color: _kGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tr(
                      'Der Fahrer hat alle geprüften Punkte als in Ordnung '
                      'gemeldet.',
                      'The driver reported every rated point as fine.',
                    ),
                    style: const TextStyle(fontSize: 13, color: _kMuted),
                  ),
                ),
              ],
            )
          else
            for (var i = 0; i < issues.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: 8),
              _inspectionIssueTile(issues[i]),
            ],
          if (okItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _tr(
                'Als in Ordnung gemeldet (${okItems.length})',
                'Reported as fine (${okItems.length})',
              ),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _kMuted,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final item in okItems)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _kPageBg,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(item.icon, size: 13, color: _kMuted),
                        const SizedBox(width: 6),
                        Text(
                          item.label(_de),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (missing > 0) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              _tr(
                '$missing Punkte wurden nicht bewertet.',
                '$missing points were not rated.',
              ),
              style: const TextStyle(fontSize: 11.5, color: _kMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _inspectionIssueTile(VehicleCheckInspectionItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _kAmberSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kAmber),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.icon, size: 19, color: _kAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        item.label(_de),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _pill(
                      _tr('AUFFÄLLIG', 'ISSUE'),
                      Colors.white,
                      _kAmber,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.hint(_de),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── KI ─────────────────────────────────────────────────────────────────

  Widget _aiCard(VehicleCheck check) {
    final status = check.aiStatus;
    final (String statusLabel, Color fg, Color bg) = switch (status) {
      'done' => (_tr('Analyse fertig', 'Analysis done'), _kBlue, _kBlueSoft),
      'running' => (_tr('Analysiert …', 'Analysing …'), _kMuted, _kPageBg),
      'error' => (_tr('Fehlgeschlagen', 'Failed'), _kRed, const Color(0xFFFEE4E2)),
      'skipped' => (_tr('Übersprungen', 'Skipped'), _kMuted, _kPageBg),
      _ => (_tr('Wartet …', 'Queued …'), _kMuted, _kPageBg),
    };

    final children = <Widget>[
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kBlueSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.auto_awesome_outlined, size: 18, color: _kBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _tr(
                  'KI-Vorschlag — bitte prüfen. Nichts davon ist bestätigt; '
                  'übernommene Punkte landen in der Schadenliste oben.',
                  'AI suggestion — please review. Nothing here is confirmed; '
                  'accepted items move into the damage list above.',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: _kBlue,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    if (status == 'error') {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            check.aiError.isEmpty
                ? _tr('Unbekannter Fehler.', 'Unknown error.')
                : check.aiError,
            style: const TextStyle(fontSize: 12, color: _kMuted),
          ),
        );
    }

    if (check.aiSummary.isNotEmpty) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            check.aiSummary,
            style: const TextStyle(fontSize: 13, color: _kText, height: 1.45),
          ),
        );
    }

    final crossChecks = <Widget>[
      if (check.aiOdometerKm != null)
        _crossCheck(
          Icons.speed_outlined,
          _tr('KM laut Foto', 'Odometer from photo'),
          '${formatVehicleCheckKm(check.aiOdometerKm!)} km',
          ok: check.aiOdometerKm == check.odometerKm,
          hint: check.aiOdometerKm == check.odometerKm
              ? _tr('stimmt mit der Eingabe überein', 'matches the entry')
              : _tr(
                  'Fahrer hat ${formatVehicleCheckKm(check.odometerKm)} km '
                  'eingetragen',
                  'driver entered ${formatVehicleCheckKm(check.odometerKm)} km',
                ),
        ),
      if (check.aiPlateMatch != null)
        _crossCheck(
          Icons.pin_outlined,
          _tr('Kennzeichen erkannt', 'Plate recognised'),
          check.aiPlateText.isEmpty ? '—' : check.aiPlateText,
          ok: check.aiPlateMatch == true,
          hint: check.aiPlateMatch == true
              ? _tr('passt zum Fahrzeug', 'matches the vehicle')
              : _tr(
                  'weicht von ${check.plate} ab',
                  'differs from ${check.plate}',
                ),
        ),
    ];
    if (crossChecks.isNotEmpty) {
      children
        ..add(const SizedBox(height: 12))
        ..add(Wrap(spacing: 10, runSpacing: 10, children: crossChecks));
    }

    final poor = check.aiQuality
        .where((q) => !q.usable || !q.matchesStep)
        .toList();
    if (poor.isNotEmpty) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final q in poor)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.image_not_supported_outlined,
                        size: 16,
                        color: _kAmber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${q.step?.label(_de) ?? _tr('Foto', 'Photo')}: '
                          '${q.note.isEmpty ? _tr('schwer verwertbar', 'hard to use') : q.note}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kMuted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
    }

    if (check.aiCandidates.isNotEmpty) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final c in check.aiCandidates) ...[
                _candidateTile(c),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
    } else if (status == 'done') {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            _tr(
              'Die KI hat keine zusätzlichen Schadens-Kandidaten gefunden.',
              'The AI found no additional damage candidates.',
            ),
            style: const TextStyle(fontSize: 12.5, color: _kMuted),
          ),
        );
    }

    return _card(
      title: _tr('KI-Assistenz', 'AI assistance'),
      trailing: _pill(statusLabel, fg, bg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _crossCheck(
    IconData icon,
    String label,
    String value, {
    required bool ok,
    required String hint,
  }) {
    final tone = ok ? _kGreen : _kAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: ok ? _kGreenSoft : _kAmberSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: tone),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label, style: TextStyle(fontSize: 10.5, color: tone)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: tone,
                ),
              ),
              Text(hint, style: const TextStyle(fontSize: 10.5, color: _kMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _candidateTile(VehicleCheckAiCandidate candidate) {
    final percent = (candidate.confidence * 100).clamp(0, 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _kPageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(candidate.category.icon, size: 19, color: _kBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        candidate.category.label(_de),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _pill('$percent %', _kBlue, _kBlueSoft),
                    if (candidate.step != null) ...[
                      const SizedBox(width: 6),
                      _pill(candidate.step!.label(_de), _kMuted, Colors.white),
                    ],
                  ],
                ),
                if (candidate.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    candidate.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _kMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.canManage)
            TextButton(
              onPressed: _busy ? null : () => _acceptCandidate(candidate),
              style: TextButton.styleFrom(foregroundColor: _kGreen),
              child: Text(_tr('Übernehmen', 'Accept')),
            ),
        ],
      ),
    );
  }

  // ── Fotos ──────────────────────────────────────────────────────────────

  Widget _photosCard(VehicleCheck check) {
    final compare = _compare;
    return _card(
      title: compare == null
          ? _tr('Fotos', 'Photos')
          : _tr(
              'Vorher/Nachher — ${_fmtDateTime(compare.checkedAt)} → '
              '${_fmtDateTime(check.checkedAt)}',
              'Before/after — ${_fmtDateTime(compare.checkedAt)} → '
              '${_fmtDateTime(check.checkedAt)}',
            ),
      trailing: TextButton.icon(
        onPressed: _pickCompare,
        icon: const Icon(Icons.compare_outlined, size: 17),
        label: Text(
          compare == null
              ? _tr('Vergleichen', 'Compare')
              : _tr('Anderer Check', 'Other check'),
        ),
        style: TextButton.styleFrom(foregroundColor: _kGreen),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = compare != null
              ? 1
              : constraints.maxWidth < 520
              ? 2
              : 4;
          return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: compare != null ? 2.4 : 0.9,
            children: <Widget>[
              for (final step in VehicleCheckStep.values)
                compare == null
                    ? _photoTile(step, check.photoFor(step))
                    : _comparePair(step, compare.photoFor(step), check.photoFor(step)),
            ],
          );
        },
      ),
    );
  }

  Widget _photoTile(VehicleCheckStep step, VehicleCheckPhoto? photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: _photoBox(photo, step)),
        const SizedBox(height: 5),
        Text(
          step.label(_de),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: _kMuted,
          ),
        ),
      ],
    );
  }

  Widget _comparePair(
    VehicleCheckStep step,
    VehicleCheckPhoto? before,
    VehicleCheckPhoto? after,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          step.label(_de),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: _kMuted,
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: _photoBox(before, step, corner: _tr('vorher', 'before'))),
              const SizedBox(width: 8),
              Expanded(child: _photoBox(after, step, corner: _tr('nachher', 'after'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoBox(
    VehicleCheckPhoto? photo,
    VehicleCheckStep step, {
    String corner = '',
  }) {
    final box = Container(
      decoration: BoxDecoration(
        color: _kPageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: photo == null || photo.url.isEmpty
          ? Center(child: Icon(step.icon, size: 22, color: _kBorder))
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(
                  photo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 20,
                      color: _kBorder,
                    ),
                  ),
                ),
                if (corner.isNotEmpty)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: _pill(corner, Colors.white, Colors.black54),
                  ),
              ],
            ),
    );
    if (photo == null || photo.url.isEmpty) return box;
    return GestureDetector(
      onTap: () => _openLightbox(photo, step),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: box),
    );
  }

  void _openLightbox(VehicleCheckPhoto photo, VehicleCheckStep step) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              step.label(_de),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: InteractiveViewer(
                maxScale: 5,
                child: Image.network(photo.url, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text(_tr('Schließen', 'Close')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Kleinteile ─────────────────────────────────────────────────────────

  Widget _pill(String text, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: fg,
      ),
    ),
  );

  String _fmtDateTime(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd.MM.yyyy · HH:mm').format(value);
  }
}
