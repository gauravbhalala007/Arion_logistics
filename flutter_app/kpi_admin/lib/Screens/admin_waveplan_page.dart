// lib/Screens/admin_waveplan_page.dart
//
// Daily dispatch / Waveplan view. Routes are grouped by dispatch wave
// (start time). Each route shows its code, dispatch area + spur, and
// the assigned driver. Driver names are resolved live from
// `users/{uid}/drivers/{doc}` (same source as Scorecard / Drivers Hub).
// Drag-and-drop moves a driver between routes; the X button or the
// right-hand pool unassigns a driver. Phase 1 MVP — assignments live
// in memory; CSV/paste import is wired so dispatchers can load data.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/waveplan_route.dart';
import '../theme/app_button_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AdminWaveplanPage extends StatefulWidget {
  const AdminWaveplanPage({super.key});

  @override
  State<AdminWaveplanPage> createState() => _AdminWaveplanPageState();
}

/// One named shift bracket the dispatcher works.
class _ShiftRange {
  String start;
  String end;
  _ShiftRange({required this.start, required this.end});

  Map<String, String> toMap() => {'start': start, 'end': end};
}

/// All valid HH:MM values in 30-minute steps (04:00 → 23:30).
/// Generated once at first access and reused for every shift dropdown.
final List<String> _halfHourTimes = () {
  final out = <String>[];
  for (var h = 4; h <= 23; h++) {
    final hh = h.toString().padLeft(2, '0');
    out.add('$hh:00');
    out.add('$hh:30');
  }
  return List<String>.unmodifiable(out);
}();

/// Default shift bracket for the i-th dispatcher (zero-based).
_ShiftRange _defaultShiftFor(int index) {
  switch (index) {
    case 0:
      return _ShiftRange(start: '06:00', end: '14:30');
    case 1:
      return _ShiftRange(start: '14:30', end: '22:00');
    default:
      return _ShiftRange(start: '06:00', end: '14:30');
  }
}

/// Friendly display label for Amazon service types. Amazon returns
/// `Kinderzimmer-Route Stufe X` (German) and `Nursery Route Level X`
/// (English) interchangeably — both collapse to `Nursery Level X`.
String _normalizeServiceType(String raw) {
  var s = raw.trim();
  s = s.replaceAllMapped(
    RegExp(r'Kinderzimmer[\s-]*Route\s+Stufe\s+(\d+)', caseSensitive: false),
    (m) => 'Nursery Level ${m.group(1)}',
  );
  s = s.replaceAllMapped(
    RegExp(r'Nursery\s+Route\s+Level\s+(\d+)', caseSensitive: false),
    (m) => 'Nursery Level ${m.group(1)}',
  );
  return s;
}

/// Snapshot of every per-program piece of state. Three programs live
/// side-by-side (`Sameday A`, `Nextday`, `Sameday C`). Switching the
/// top tab saves the current state into the previous program and
/// loads the new one.
class _ProgramSnapshot {
  List<WaveplanRoute> routes;
  List<String> unassigned;
  Map<String, List<String>> atlasByRoute;
  bool atlasConfirmed;
  bool isPublished;
  DateTime? publishedAt;
  List<String> selectedDispatchers;
  Map<String, _ShiftRange> shiftByDispatcher;
  String generalNotes;

  _ProgramSnapshot({
    List<WaveplanRoute>? routes,
    List<String>? unassigned,
    Map<String, List<String>>? atlasByRoute,
    this.atlasConfirmed = false,
    this.isPublished = false,
    this.publishedAt,
    List<String>? selectedDispatchers,
    Map<String, _ShiftRange>? shiftByDispatcher,
    this.generalNotes = '',
  })  : routes = routes ?? [],
        unassigned = unassigned ?? [],
        atlasByRoute = atlasByRoute ?? {},
        selectedDispatchers = selectedDispatchers ?? [],
        shiftByDispatcher = shiftByDispatcher ?? {};
}

const List<Map<String, String>> _programs = [
  {'key': 'sameday_a', 'label': 'Sameday A'},
  {'key': 'nextday', 'label': 'Nextday'},
  {'key': 'sameday_c', 'label': 'Sameday C'},
];

class _AdminWaveplanPageState extends State<AdminWaveplanPage> {
  // Per-program saved state. Default to the sample data on Sameday A
  // so the dispatcher has something to play with after first load.
  final Map<String, _ProgramSnapshot> _saved = {
    'sameday_a': _ProgramSnapshot(routes: List.of(_sampleRoutes)),
    'nextday': _ProgramSnapshot(),
    'sameday_c': _ProgramSnapshot(),
  };
  String _activeProgram = 'sameday_a';

  late List<WaveplanRoute> _routes;
  final List<String> _unassigned = [];
  bool _isPublished = false;
  DateTime? _publishedAt;

  // Page-level dispatcher coordination — one bar at the top covers
  // every wave. Up to 3 dispatchers; each one has its own shift
  // bracket (independent picker). One free-form notes line is shown
  // to drivers after publish.
  final List<String> _selectedDispatchers = [];
  final Map<String, _ShiftRange> _shiftByDispatcher = {};
  static const int _maxDispatchers = 3;

  String _generalNotes = '';

  /// Atlas confirmation gate. Publish stays disabled until either a
  /// list was imported OR the dispatcher explicitly confirmed
  /// "Keine Atlas-Pakete heute".
  bool _atlasConfirmed = false;

  // Stream of dispatcher names configured on the Dispatcher Pill page.
  Stream<List<String>>? _dispatcherNamesStream;

  // Atlas tracking IDs per routeCode. These are sensitive/expensive
  // packages the driver has to fetch from the dispatcher in person.
  // Imported via a paste-box; persisted in the published doc so the
  // driver app can show an alert.
  final Map<String, List<String>> _atlasByRoute = {};

  // Scroll-to-wave anchors. One GlobalKey per wave timestamp,
  // attached to the section header in the list.
  final Map<String, GlobalKey> _waveAnchors = {};

  // transporterId (normalized) → driverName, streamed from Firestore.
  // Mirrors the resolution used in scorecard_overview.dart.
  Stream<Map<String, String>>? _namesStream;

  @override
  void initState() {
    super.initState();
    _namesStream = _driversNameMapGlobal();
    _dispatcherNamesStream = _streamDispatcherNames();
    _loadProgram(_activeProgram);
  }

  /// Replace all visible state with the snapshot of [programKey].
  /// Caller should `setState` so the UI rebuilds.
  void _loadProgram(String programKey) {
    final snap = _saved[programKey] ?? _ProgramSnapshot();
    _routes = snap.routes;
    _unassigned
      ..clear()
      ..addAll(snap.unassigned);
    _atlasByRoute
      ..clear()
      ..addAll(snap.atlasByRoute);
    _atlasConfirmed = snap.atlasConfirmed;
    _isPublished = snap.isPublished;
    _publishedAt = snap.publishedAt;
    _selectedDispatchers
      ..clear()
      ..addAll(snap.selectedDispatchers);
    _shiftByDispatcher
      ..clear()
      ..addAll(snap.shiftByDispatcher);
    _generalNotes = snap.generalNotes;
    _waveAnchors.clear();
  }

  /// Persist the visible state back into the snapshot for [programKey]
  /// before the user navigates to another program.
  void _saveProgram(String programKey) {
    _saved[programKey] = _ProgramSnapshot(
      routes: List.of(_routes),
      unassigned: List.of(_unassigned),
      atlasByRoute: Map.fromEntries(
        _atlasByRoute.entries.map((e) => MapEntry(e.key, List.of(e.value))),
      ),
      atlasConfirmed: _atlasConfirmed,
      isPublished: _isPublished,
      publishedAt: _publishedAt,
      selectedDispatchers: List.of(_selectedDispatchers),
      shiftByDispatcher: Map.of(_shiftByDispatcher),
      generalNotes: _generalNotes,
    );
  }

  void _switchProgram(String newKey) {
    if (newKey == _activeProgram) return;
    _saveProgram(_activeProgram);
    setState(() {
      _activeProgram = newKey;
      _loadProgram(newKey);
    });
  }

  /// Streams the dispatcher names configured on the
  /// "Dispatcher Pill" admin page (`users/{uid}/settings/dispatcher_pill`).
  Stream<List<String>> _streamDispatcherNames() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('dispatcher_pill')
        .snapshots()
        .map((doc) {
          final raw = (doc.data() ?? const {})['dispatchers'];
          if (raw is! List) return const <String>[];
          final out = <String>[];
          for (final row in raw) {
            if (row is! Map) continue;
            final n = (row['name'] ?? '').toString().trim();
            if (n.isNotEmpty) out.add(n);
          }
          return out;
        });
  }

  GlobalKey _anchorFor(String wave) =>
      _waveAnchors.putIfAbsent(wave, () => GlobalKey());

  void _jumpToWave(String wave) {
    final ctx = _waveAnchors[wave]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  /// Streams the same Firestore source the **Drivers Hub** writes to:
  /// `users/{uid}/drivers/{doc}` with fields `transporterId` (stored
  /// upper-cased on write) and `driverName`. We index every driver
  /// under three candidate keys (raw, uppercase, alphanumeric-only)
  /// so a lookup with any reasonable form of the ID hits.
  Stream<Map<String, String>> _driversNameMapGlobal() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
          final m = <String, String>{};
          for (final d in snap.docs) {
            final data = d.data();
            final raw = (data['transporterId'] ?? d.id).toString().trim();
            if (raw.isEmpty) continue;
            final name = (data['driverName'] ?? '').toString().trim();
            if (name.isEmpty) continue;

            for (final k in _idKeys(raw)) {
              m[k] = name;
            }
          }
          return m;
        });
  }

  /// Expands an id into the candidate forms a route might carry.
  static Iterable<String> _idKeys(String raw) sync* {
    final upper = raw.toUpperCase();
    yield raw;
    yield upper;
    yield upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  String _resolveName(Map<String, String> namesMap, String? tid) {
    if (tid == null || tid.isEmpty) return '';
    for (final k in _idKeys(tid.trim())) {
      final hit = namesMap[k];
      if (hit != null && hit.isNotEmpty) return hit;
    }
    return '';
  }

  // ─── Wave helpers ───────────────────────────────────────────────────────

  List<String> _wavesOf(List<WaveplanRoute> rs) {
    final set = <String>{for (final r in rs) r.dispatchTime};
    final list = set.toList()..sort();
    return list;
  }

  /// Routes ordered by wave (ascending) and then by dispatch slot.
  List<WaveplanRoute> _routesSorted() {
    final list = List<WaveplanRoute>.of(_routes);
    list.sort((a, b) {
      final t = a.dispatchTime.compareTo(b.dispatchTime);
      if (t != 0) return t;
      return a.dispatchSlot.compareTo(b.dispatchSlot);
    });
    return list;
  }

  // ─── Mutations ──────────────────────────────────────────────────────────

  void _assignTo(String routeId, String transporterId) {
    setState(() {
      final idx = _routes.indexWhere((r) => r.routeId == routeId);
      if (idx == -1) return;
      final target = _routes[idx];

      // Where is the driver currently? (in another route or in pool)
      final fromIdx = _routes.indexWhere(
        (r) => r.transporterId == transporterId,
      );
      final wasInPool = _unassigned.contains(transporterId);

      // If the target slot is occupied, the previous driver is bumped
      // to the source's old place (swap) or to the pool (came from pool).
      final displaced = target.transporterId;

      _routes[idx] = target.copyWith(
        transporterId: transporterId,
        assignedDsp: target.assignedDsp ?? 'AION',
      );

      if (fromIdx != -1 && fromIdx != idx) {
        // Source route loses the dragged driver; receives the displaced one
        // (could be null → that's fine, source becomes empty).
        _routes[fromIdx] = _routes[fromIdx].copyWith(
          transporterId: displaced,
          clearTransporterId: displaced == null,
        );
      } else if (wasInPool) {
        _unassigned.remove(transporterId);
        if (displaced != null) _unassigned.add(displaced);
      }
    });
  }

  void _unassign(String routeId) {
    setState(() {
      final idx = _routes.indexWhere((r) => r.routeId == routeId);
      if (idx == -1) return;
      final tid = _routes[idx].transporterId;
      if (tid == null) return;
      _routes[idx] = _routes[idx].copyWith(clearTransporterId: true);
      if (!_unassigned.contains(tid)) _unassigned.add(tid);
    });
  }

  void _dropToPool(String transporterId) {
    setState(() {
      final fromIdx = _routes.indexWhere(
        (r) => r.transporterId == transporterId,
      );
      if (fromIdx != -1) {
        _routes[fromIdx] = _routes[fromIdx].copyWith(clearTransporterId: true);
      }
      if (!_unassigned.contains(transporterId)) {
        _unassigned.add(transporterId);
      }
    });
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final waves = _wavesOf(_routes);
    final routes = _routesSorted();
    final isNarrow = MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: StreamBuilder<Map<String, String>>(
            stream: _namesStream,
            builder: (context, snap) {
              final namesMap = snap.data ?? const <String, String>{};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgramTabs(
                    active: _activeProgram,
                    onSelect: _switchProgram,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _Header(
                    onPaste: _showPasteDialog,
                    onAtlasPaste: _showAtlasPasteDialog,
                    onClear: _routes.isEmpty ? null : _clearWaveplan,
                    onPublishToggle:
                        (_routes.isEmpty || !_atlasConfirmed) && !_isPublished
                            ? null
                            : () => _togglePublish(namesMap),
                    isPublished: _isPublished,
                    publishedAt: _publishedAt,
                    routeCount: _routes.length,
                    assignedCount: _routes.where((r) => r.isAssigned).length,
                    atlasTotal: _atlasByRoute.values
                        .fold<int>(0, (s, l) => s + l.length),
                    atlasConfirmed: _atlasConfirmed,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  StreamBuilder<List<String>>(
                    stream: _dispatcherNamesStream,
                    builder: (context, dispSnap) {
                      final available = dispSnap.data ?? const <String>[];
                      return _DispatcherBar(
                        available: available,
                        selected: _selectedDispatchers,
                        shiftByDispatcher: _shiftByDispatcher,
                        maxSelectable: _maxDispatchers,
                        onAddDispatcher: (name) {
                          if (_selectedDispatchers.contains(name)) return;
                          if (_selectedDispatchers.length >=
                              _maxDispatchers) {
                            return;
                          }
                          setState(() {
                            _selectedDispatchers.add(name);
                            _shiftByDispatcher[name] = _defaultShiftFor(
                              _selectedDispatchers.length - 1,
                            );
                          });
                        },
                        onRemoveDispatcher: (name) {
                          setState(() {
                            _selectedDispatchers.remove(name);
                            _shiftByDispatcher.remove(name);
                          });
                        },
                        onShiftChanged: (name, range) {
                          setState(() {
                            _shiftByDispatcher[name] = range;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _NotesBar(
                    initial: _generalNotes,
                    onChanged: (v) => _generalNotes = v,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _WaveJumpBar(
                    waves: waves,
                    routesPerWave: {
                      for (final w in waves)
                        w: _routes.where((r) => r.dispatchTime == w).length,
                    },
                    onJump: _jumpToWave,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: isNarrow
                        ? _StackedLayout(
                            routes: routes,
                            unassigned: _unassigned,
                            namesMap: namesMap,
                            anchorFor: _anchorFor,
                            atlasFor: (code) =>
                                _atlasByRoute[code] ?? const [],
                            resolveName: (tid) => _resolveName(namesMap, tid),
                            onAssign: _assignTo,
                            onUnassign: _unassign,
                            onDropToPool: _dropToPool,
                          )
                        : _SideBySideLayout(
                            routes: routes,
                            unassigned: _unassigned,
                            namesMap: namesMap,
                            anchorFor: _anchorFor,
                            atlasFor: (code) =>
                                _atlasByRoute[code] ?? const [],
                            resolveName: (tid) => _resolveName(namesMap, tid),
                            onAssign: _assignTo,
                            onUnassign: _unassign,
                            onDropToPool: _dropToPool,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Import / paste ───────────────────────────────────────────────────

  Future<void> _showAtlasPasteDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.inventory_2_rounded,
              color: AppColors.warning,
              size: 20,
            ),
            SizedBox(width: 8),
            Text('Atlas-Pakete einfügen'),
          ],
        ),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aus der E-Mail kopieren und hier einfügen. Erwartet: '
                'eine Zeile pro Paket im Format '
                '"Tracking-ID - Route-Code - Transporter-ID". '
                'Der Fahrer sieht den Hinweis, das Paket beim Dispatcher '
                'abzuholen.',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                maxLines: 14,
                minLines: 10,
                style: AppTypography.footnote.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  hintText:
                      'DE5457917333 - CA_A143 - A5A6I65TGFZ5R\n'
                      'DE5457919556 - CA_A143 - A5A6I65TGFZ5R\n'
                      '…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_kAtlasNoneToday),
            child: const Text('Keine Atlas-Pakete für heute'),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.primary),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Importieren'),
          ),
        ],
      ),
    );
    if (result == null) return;

    // Sentinel: dispatcher confirmed there are no Atlas packages today.
    if (result == _kAtlasNoneToday) {
      setState(() {
        _atlasByRoute.clear();
        _atlasConfirmed = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Keine Atlas-Pakete für heute bestätigt — Publish ist freigegeben.',
          ),
        ),
      );
      return;
    }

    if (result.trim().isEmpty) return;

    final parsed = _parseAtlasPaste(result);
    if (parsed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konnte keine gültigen Atlas-Pakete erkennen.'),
        ),
      );
      return;
    }
    setState(() {
      _atlasByRoute
        ..clear()
        ..addAll(parsed);
      _atlasConfirmed = true;
    });
    final total = parsed.values.fold<int>(0, (s, l) => s + l.length);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$total Atlas-Pakete für ${parsed.length} Routen importiert.',
        ),
      ),
    );
  }

  /// Special return value from the Atlas-paste dialog meaning
  /// "the dispatcher confirmed there are no Atlas packages today".
  static const String _kAtlasNoneToday = '__ATLAS_NONE_TODAY__';

  /// Parse `DE… - CA_… - A…` lines (separator: ` - `). Groups
  /// tracking IDs by routeCode so a single route can carry multiple
  /// packages.
  Map<String, List<String>> _parseAtlasPaste(String input) {
    final out = <String, List<String>>{};
    for (final raw in input.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final parts = line.split(RegExp(r'\s+-\s+'));
      if (parts.length < 2) continue;
      final tracking = parts[0].trim();
      final routeCode = parts[1].trim();
      if (tracking.isEmpty || routeCode.isEmpty) continue;
      out.putIfAbsent(routeCode, () => []).add(tracking);
    }
    return out;
  }

  Future<void> _showPasteDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Waveplan einfügen'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tabelle aus Excel oder Webseite kopieren und hier einfügen. '
                'Erwartet: 9 Felder pro Route in dieser Reihenfolge — '
                'dispatchTime, shiftEnd, routeCode, routeId, dispatchArea, '
                'spur, "TID / DSP / TID", DSP, serviceType.',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                maxLines: 14,
                minLines: 10,
                style: AppTypography.footnote.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  hintText: '11:00:00\n20:00:00\nCA_A169\n7503578-169\n...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.primary),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Importieren'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    final parsed = _parsePastedWaveplan(result);
    if (parsed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konnte keine gültigen Routen erkennen.')),
      );
      return;
    }
    setState(() {
      _routes = parsed;
      _unassigned.clear();
      _waveAnchors.clear(); // anchors regenerated lazily on next build
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${parsed.length} Routen importiert.')),
    );
  }

  /// Parses the line-per-field paste format used by the Amazon dispatch
  /// list. Each route is 9 consecutive non-empty lines; "ASSIGN DA" is
  /// `<TID> / <DSP> / <TID>` and the first segment is taken as the
  /// transporterId.
  List<WaveplanRoute> _parsePastedWaveplan(String input) {
    final lines = input
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final out = <WaveplanRoute>[];
    for (var i = 0; i + 8 < lines.length; i += 9) {
      final dispatchTime = lines[i + 0];
      final shiftEnd = lines[i + 1];
      final routeCode = lines[i + 2];
      final routeId = lines[i + 3];
      final dispatchArea = lines[i + 4];
      final spurRaw = lines[i + 5].toLowerCase();
      final assignDa = lines[i + 6];
      final dsp = lines[i + 7];
      final serviceType = lines[i + 8];

      // Sanity check — first line should look like HH:MM:SS
      if (!RegExp(r'^\d{1,2}:\d{2}:\d{2}$').hasMatch(dispatchTime)) {
        continue;
      }

      String? tid;
      final parts = assignDa.split('/').map((p) => p.trim()).toList();
      if (parts.isNotEmpty) tid = parts.first;
      if (tid != null && tid.isEmpty) tid = null;

      out.add(
        WaveplanRoute(
          routeCode: routeCode,
          routeId: routeId,
          dispatchArea: dispatchArea,
          waitingAreaSpur: spurRaw,
          dispatchTime: dispatchTime,
          shiftEndTime: shiftEnd,
          serviceType: serviceType,
          transporterId: tid,
          assignedDsp: dsp,
        ),
      );
    }
    return out;
  }

  /// Today's published-waveplan doc reference for the active program.
  /// One doc per `(date, program)` pair so Sameday A / Nextday /
  /// Sameday C don't overwrite each other.
  ///
  /// Schema:
  /// ```
  /// users/{adminUid}/published_waveplans/{YYYY-MM-DD_program}
  ///   - publishedAt: Timestamp
  ///   - program: 'sameday_a' | 'nextday' | 'sameday_c'
  ///   - routes: [ { ... } ]
  ///   - dispatchers: [ { name, start, end } ]
  ///   - notes: String
  /// ```
  DocumentReference<Map<String, dynamic>>? _publishedDocRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('published_waveplans')
        .doc('${date}_$_activeProgram');
  }

  /// Toggle publish state. Writes routes (with resolved driver names) to
  /// `users/{adminUid}/published_waveplans/{date}`. The driver app
  /// streams that doc and shows the assignment + carpool tab live.
  Future<void> _togglePublish(Map<String, String> namesMap) async {
    final ref = _publishedDocRef();
    if (ref == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte erst einloggen.')),
      );
      return;
    }

    if (_isPublished) {
      // ─── Unpublish: delete the doc ───────────────────────────────────
      try {
        await ref.delete();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unpublish fehlgeschlagen: $e')),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _isPublished = false;
        _publishedAt = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veröffentlichung zurückgenommen — Fahrer sehen nichts mehr.',
          ),
        ),
      );
      return;
    }

    // ─── Publish: write all routes ─────────────────────────────────────
    final payloadRoutes = _routes.map((r) {
      return {
        'routeCode': r.routeCode,
        'routeId': r.routeId,
        'dispatchArea': r.dispatchArea,
        'spur': r.waitingAreaSpur,
        'dispatchTime': r.dispatchTime,
        'shiftEnd': r.shiftEndTime,
        'serviceType': _normalizeServiceType(r.serviceType),
        'transporterId': r.transporterId ?? '',
        'driverName': _resolveName(namesMap, r.transporterId),
        'assignedDsp': r.assignedDsp ?? '',
        'atlasTrackingIds': _atlasByRoute[r.routeCode] ?? const <String>[],
      };
    }).toList();

    try {
      final dispatchersPayload = _selectedDispatchers.map((name) {
        final s = _shiftByDispatcher[name];
        return {
          'name': name,
          'start': s?.start ?? '',
          'end': s?.end ?? '',
        };
      }).toList();

      await ref.set({
        'publishedAt': FieldValue.serverTimestamp(),
        'program': _activeProgram,
        'routes': payloadRoutes,
        'dispatchers': dispatchersPayload,
        'notes': _generalNotes.trim(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Publish fehlgeschlagen: $e')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _isPublished = true;
      _publishedAt = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Waveplan veröffentlicht — Fahrer sehen jetzt ihre Wave.',
        ),
      ),
    );
  }

  Future<void> _clearWaveplan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Waveplan leeren?'),
        content: const Text(
          'Alle Routen und Zuweisungen werden gelöscht. '
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.destructive),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leeren'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _routes = [];
      _unassigned.clear();
      _waveAnchors.clear();
      _atlasByRoute.clear();
      _atlasConfirmed = false;
      _selectedDispatchers.clear();
      _shiftByDispatcher.clear();
      _generalNotes = '';
      _isPublished = false;
      _publishedAt = null;
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Layout shells
// ════════════════════════════════════════════════════════════════════════════

class _SideBySideLayout extends StatelessWidget {
  final List<WaveplanRoute> routes;
  final List<String> unassigned;
  final Map<String, String> namesMap;
  final GlobalKey Function(String wave) anchorFor;
  final List<String> Function(String routeCode) atlasFor;
  final String Function(String? transporterId) resolveName;
  final void Function(String routeId, String transporterId) onAssign;
  final void Function(String routeId) onUnassign;
  final void Function(String transporterId) onDropToPool;

  const _SideBySideLayout({
    required this.routes,
    required this.unassigned,
    required this.namesMap,
    required this.anchorFor,
    required this.atlasFor,
    required this.resolveName,
    required this.onAssign,
    required this.onUnassign,
    required this.onDropToPool,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 7,
          child: _RouteList(
            routes: routes,
            anchorFor: anchorFor,
            atlasFor: atlasFor,
            resolveName: resolveName,
            onAssign: onAssign,
            onUnassign: onUnassign,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 280,
          child: _UnassignedPool(
            transporterIds: unassigned,
            resolveName: resolveName,
            onDropToPool: onDropToPool,
          ),
        ),
      ],
    );
  }
}

class _StackedLayout extends StatelessWidget {
  final List<WaveplanRoute> routes;
  final List<String> unassigned;
  final Map<String, String> namesMap;
  final GlobalKey Function(String wave) anchorFor;
  final List<String> Function(String routeCode) atlasFor;
  final String Function(String? transporterId) resolveName;
  final void Function(String routeId, String transporterId) onAssign;
  final void Function(String routeId) onUnassign;
  final void Function(String transporterId) onDropToPool;

  const _StackedLayout({
    required this.routes,
    required this.unassigned,
    required this.namesMap,
    required this.anchorFor,
    required this.atlasFor,
    required this.resolveName,
    required this.onAssign,
    required this.onUnassign,
    required this.onDropToPool,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: _UnassignedPool(
            transporterIds: unassigned,
            resolveName: resolveName,
            onDropToPool: onDropToPool,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _RouteList(
            routes: routes,
            anchorFor: anchorFor,
            atlasFor: atlasFor,
            resolveName: resolveName,
            onAssign: onAssign,
            onUnassign: onUnassign,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Header + Wave tabs
// ════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final VoidCallback onPaste;
  final VoidCallback onAtlasPaste;
  final VoidCallback? onClear;
  final VoidCallback? onPublishToggle;
  final bool isPublished;
  final DateTime? publishedAt;
  final int routeCount;
  final int assignedCount;
  final int atlasTotal;
  final bool atlasConfirmed;

  const _Header({
    required this.onPaste,
    required this.onAtlasPaste,
    required this.onClear,
    required this.onPublishToggle,
    required this.isPublished,
    required this.publishedAt,
    required this.routeCount,
    required this.assignedCount,
    required this.atlasTotal,
    required this.atlasConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Waveplan',
          style: AppTypography.title2.copyWith(
            color: AppColors.codriverGraphite,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$assignedCount / $routeCount zugewiesen',
            style: AppTypography.caption1.copyWith(
              color: AppColors.codriverDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        _SmallActionButton(
          icon: Icons.content_paste_rounded,
          label: 'Wave einfügen',
          onTap: onPaste,
        ),
        const SizedBox(width: AppSpacing.xs),
        _SmallActionButton(
          icon: atlasConfirmed && atlasTotal == 0
              ? Icons.check_circle_outline_rounded
              : Icons.inventory_2_rounded,
          label: atlasTotal > 0
              ? 'Atlas · $atlasTotal'
              : (atlasConfirmed ? 'Atlas · keine' : 'Atlas'),
          onTap: onAtlasPaste,
          accent: atlasConfirmed && atlasTotal == 0
              ? AppColors.success
              : AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.xs),
        _SmallActionButton(
          icon: Icons.delete_outline_rounded,
          label: 'Leeren',
          onTap: onClear,
          danger: true,
        ),
        const SizedBox(width: AppSpacing.sm),
        _PublishButton(
          isPublished: isPublished,
          publishedAt: publishedAt,
          onToggle: onPublishToggle,
        ),
      ],
    );
  }
}

/// Animated publish/unpublish toggle. Wider than the other action
/// buttons so it reads as the primary CTA. Cross-fades between two
/// states; a status dot pulses while published. Clicking it again
/// "unpublishes" — drivers stop seeing the wave.
class _PublishButton extends StatefulWidget {
  final bool isPublished;
  final DateTime? publishedAt;
  final VoidCallback? onToggle;
  const _PublishButton({
    required this.isPublished,
    required this.publishedAt,
    required this.onToggle,
  });

  @override
  State<_PublishButton> createState() => _PublishButtonState();
}

class _PublishButtonState extends State<_PublishButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _timeLabel() {
    final d = widget.publishedAt;
    if (d == null) return '';
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final published = widget.isPublished;
    final disabled = widget.onToggle == null;
    final bg = disabled
        ? AppColors.labelTertiaryLight
        : published
            ? AppColors.codriverDeep
            : (_hovered ? const Color(0xFF00A07A) : AppColors.codriverGreen);

    return MouseRegion(
      cursor: disabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: disabled
            ? 'Erst Wave-Daten und Atlas-Status setzen.'
            : '',
        child: GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          constraints: BoxConstraints(minWidth: published ? 250 : 220),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: AppElevation.level2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (published)
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) {
                    final t = _pulse.value;
                    return Container(
                      width: 10 + 2 * t,
                      height: 10 + 2 * t,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.35 + 0.4 * t),
                            blurRadius: 8 + 6 * t,
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.send_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  published
                      ? 'Veröffentlicht  ·  ${_timeLabel()}  ·  Unpublish'
                      : 'Waveplan veröffentlichen',
                  key: ValueKey(published),
                  style: AppTypography.subheadline.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

/// Compact secondary-action button for the page header. Pill-shaped,
/// content-fitting, level-1 shadow + subtle hairline border, hover
/// darkens the fill slightly. Optional [danger] tints the icon red,
/// or pass an explicit [accent] colour for a custom tone.
class _SmallActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  final Color? accent;
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.accent,
  });

  @override
  State<_SmallActionButton> createState() => _SmallActionButtonState();
}

class _SmallActionButtonState extends State<_SmallActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final fg = disabled
        ? AppColors.labelTertiaryLight
        : (widget.accent ??
              (widget.danger ? AppColors.error : AppColors.codriverDeep));
    return MouseRegion(
      cursor: disabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: _hovered && !disabled
                ? AppColors.surfaceLight
                : AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: AppColors.separatorLight.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTypography.footnote.copyWith(
                  color: disabled ? fg : AppColors.codriverGraphite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Program switcher at the very top of the page — three independent
/// workspaces: Sameday A, Nextday, Sameday C. Switching a tab swaps
/// the visible state with the saved snapshot for that program.
class _ProgramTabs extends StatelessWidget {
  final String active;
  final ValueChanged<String> onSelect;
  const _ProgramTabs({required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: AppColors.separatorLight.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in _programs)
            _ProgramTab(
              label: p['label']!,
              selected: p['key'] == active,
              onTap: () => onSelect(p['key']!),
            ),
        ],
      ),
    );
  }
}

class _ProgramTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ProgramTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.codriverGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTypography.subheadline.copyWith(
              color: selected ? Colors.white : AppColors.codriverGraphite,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of jump-to-wave buttons. Tapping a button scrolls the list
/// to the corresponding wave heading. Replaces the earlier tab pattern
/// — every wave is visible at once, the buttons are just shortcuts.
class _WaveJumpBar extends StatelessWidget {
  final List<String> waves;
  final Map<String, int> routesPerWave;
  final ValueChanged<String> onJump;

  const _WaveJumpBar({
    required this.waves,
    required this.routesPerWave,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final w in waves)
          _WaveJumpChip(
            label: 'Wave ${w.substring(0, 5)}',
            count: routesPerWave[w] ?? 0,
            onTap: () => onJump(w),
          ),
      ],
    );
  }
}

class _WaveJumpChip extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onTap;

  const _WaveJumpChip({
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppElevation.level1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_downward_rounded,
                size: 14,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.subheadline.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.codriverGraphite,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.caption2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.codriverDeep,
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

// ════════════════════════════════════════════════════════════════════════════
//  Route list + Route card
// ════════════════════════════════════════════════════════════════════════════

/// Renders all routes in a single scroll list with section headers
/// per dispatch wave. Each header carries a [GlobalKey] so the
/// jump-bar above can scroll directly to it.
class _RouteList extends StatelessWidget {
  final List<WaveplanRoute> routes;
  final GlobalKey Function(String wave) anchorFor;
  final List<String> Function(String routeCode) atlasFor;
  final String Function(String? transporterId) resolveName;
  final void Function(String routeId, String transporterId) onAssign;
  final void Function(String routeId) onUnassign;

  const _RouteList({
    required this.routes,
    required this.anchorFor,
    required this.atlasFor,
    required this.resolveName,
    required this.onAssign,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    // Build a flat list of (header / route) entries grouped by wave.
    final items = <_ListItem>[];
    String? currentWave;
    int waveCount = 0;
    for (var i = 0; i < routes.length; i++) {
      final r = routes[i];
      if (r.dispatchTime != currentWave) {
        currentWave = r.dispatchTime;
        // Count routes for this wave to display in the header.
        waveCount = routes.where((x) => x.dispatchTime == currentWave).length;
        items.add(_HeaderItem(currentWave!, waveCount));
      }
      items.add(_RouteItem(r));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        if (it is _HeaderItem) {
          return Padding(
            key: anchorFor(it.wave),
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: _WaveSectionHeader(wave: it.wave, count: it.count),
          );
        }
        final route = (it as _RouteItem).route;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: _RouteCard(
            route: route,
            atlasTrackingIds: atlasFor(route.routeCode),
            resolveName: resolveName,
            onAssign: (tid) => onAssign(route.routeId, tid),
            onUnassign: () => onUnassign(route.routeId),
          ),
        );
      },
    );
  }
}

/// Page-level dispatcher selector. One bar covers all waves of the
/// day. Up to 3 named dispatchers can be picked from the existing
/// Dispatcher Pill list; **each one** carries its own shift bracket
/// (start + end times in 30-minute steps, picked independently).
class _DispatcherBar extends StatelessWidget {
  final List<String> available;
  final List<String> selected;
  final Map<String, _ShiftRange> shiftByDispatcher;
  final int maxSelectable;
  final ValueChanged<String> onAddDispatcher;
  final ValueChanged<String> onRemoveDispatcher;
  final void Function(String name, _ShiftRange newRange) onShiftChanged;

  const _DispatcherBar({
    required this.available,
    required this.selected,
    required this.shiftByDispatcher,
    required this.maxSelectable,
    required this.onAddDispatcher,
    required this.onRemoveDispatcher,
    required this.onShiftChanged,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = available.where((n) => !selected.contains(n)).toList();
    final canAddMore = selected.length < maxSelectable;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: AppColors.separatorLight.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.headset_mic_rounded,
                size: 16,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: 6),
              Text(
                'Dispatcher',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· ${selected.length} / $maxSelectable',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelTertiaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                'Keine Dispatcher konfiguriert — auf der '
                '"Dispatcher Pill"-Seite anlegen.',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final name in selected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _DispatcherRow(
                      name: name,
                      range: shiftByDispatcher[name] ??
                          _defaultShiftFor(selected.indexOf(name)),
                      onShiftChanged: (r) => onShiftChanged(name, r),
                      onRemove: () => onRemoveDispatcher(name),
                    ),
                  ),
                if (canAddMore && remaining.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final name in remaining)
                        _AddDispatcherChip(
                          name: name,
                          onTap: () => onAddDispatcher(name),
                        ),
                    ],
                  )
                else if (!canAddMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Maximal $maxSelectable Dispatcher erreicht.',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.labelTertiaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AddDispatcherChip extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _AddDispatcherChip({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.separatorLight.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 13,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: 4),
              Text(
                name,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.codriverGraphite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One selected-dispatcher row: name pill + start dropdown + end
/// dropdown + remove button.
class _DispatcherRow extends StatelessWidget {
  final String name;
  final _ShiftRange range;
  final ValueChanged<_ShiftRange> onShiftChanged;
  final VoidCallback onRemove;

  const _DispatcherRow({
    required this.name,
    required this.range,
    required this.onShiftChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Selected pill — name + inline X. Clicking the X (or the
        // whole pill) removes the dispatcher from the selection.
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
              decoration: BoxDecoration(
                color: AppColors.codriverGreen,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppElevation.level1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    name,
                    style: AppTypography.footnote.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Icon(
          Icons.schedule_rounded,
          size: 14,
          color: AppColors.codriverDeep,
        ),
        const SizedBox(width: 4),
        _TimeDropdown(
          value: range.start,
          onChanged: (v) => onShiftChanged(
            _ShiftRange(start: v, end: range.end),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('–'),
        ),
        _TimeDropdown(
          value: range.end,
          onChanged: (v) => onShiftChanged(
            _ShiftRange(start: range.start, end: v),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

/// HH:MM dropdown stepping in 30-minute increments.
class _TimeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TimeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final inList = _halfHourTimes.contains(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: inList ? value : null,
          isDense: true,
          hint: Text(
            value,
            style: AppTypography.footnote.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            size: 18,
            color: AppColors.labelSecondaryLight,
          ),
          items: [
            for (final t in _halfHourTimes)
              DropdownMenuItem(
                value: t,
                child: Text(
                  t,
                  style: AppTypography.footnote.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Free-form info shown to all drivers — e.g. "Stau auf A3" or
/// "Maximale Zustellzeit verkürzt".
class _NotesBar extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  const _NotesBar({required this.initial, required this.onChanged});

  @override
  State<_NotesBar> createState() => _NotesBarState();
}

class _NotesBarState extends State<_NotesBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppElevation.level1,
        border: Border.all(
          color: AppColors.separatorLight.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.campaign_rounded,
                size: 16,
                color: AppColors.codriverDeep,
              ),
              const SizedBox(width: 6),
              Text(
                'Hinweis',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· wird auf jedem Fahrer-Handy angezeigt',
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelTertiaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            minLines: 3,
            maxLines: 6,
            style: AppTypography.footnote.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              hintText:
                  'Hinweis für alle Fahrer — z.B. "Stau auf A3", '
                  '"Maximale Zustellzeit 18:00", "Briefing 10:45 in der Halle".',
              hintStyle: AppTypography.footnote.copyWith(
                color: AppColors.labelTertiaryLight,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.codriverGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class _ListItem {
  const _ListItem();
}

class _HeaderItem extends _ListItem {
  final String wave;
  final int count;
  const _HeaderItem(this.wave, this.count);
}

class _RouteItem extends _ListItem {
  final WaveplanRoute route;
  const _RouteItem(this.route);
}

class _WaveSectionHeader extends StatelessWidget {
  final String wave;
  final int count;
  const _WaveSectionHeader({required this.wave, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.codriverGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Wave ${wave.substring(0, 5)}',
          style: AppTypography.title3.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.codriverGraphite,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '· $count Routen',
          style: AppTypography.subheadline.copyWith(
            color: AppColors.labelSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// One compact route row — small enough that ~18 fit on a 1080p screen
/// without scrolling. Spur uses **blue** for left and **green** for
/// right. Driver-chip width hugs its content rather than stretching.
class _RouteCard extends StatelessWidget {
  final WaveplanRoute route;
  final List<String> atlasTrackingIds;
  final String Function(String? transporterId) resolveName;
  final ValueChanged<String> onAssign;
  final VoidCallback onUnassign;

  const _RouteCard({
    required this.route,
    required this.atlasTrackingIds,
    required this.resolveName,
    required this.onAssign,
    required this.onUnassign,
  });

  bool _isLeft() => route.waitingAreaSpur.toLowerCase() == 'links';

  @override
  Widget build(BuildContext context) {
    final left = _isLeft();
    final spurColor = left
        ? const Color(0xFF0A84FF) // iOS blue — links
        : AppColors.codriverGreen; // brand green — rechts

    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data != route.transporterId,
      onAcceptWithDetails: (d) => onAssign(d.data),
      builder: (context, candidate, _) {
        final hovered = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: hovered ? AppColors.codriverGreen : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Driver chip first — most important info on the left.
              SizedBox(
                width: 260,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: route.isAssigned
                      ? _DriverChip(
                          transporterId: route.transporterId!,
                          driverName: resolveName(route.transporterId),
                          dsp: route.assignedDsp,
                          onRemove: onUnassign,
                        )
                      : _EmptyDropZone(active: hovered),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SpurIndicator(left: left, color: spurColor),
              const SizedBox(width: AppSpacing.sm),
              // Route metadata — compact, one column
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          route.routeCode,
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.codriverGraphite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: spurColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            route.dispatchArea,
                            style: AppTypography.caption2.copyWith(
                              color: spurColor,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        if (atlasTrackingIds.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _AtlasBadge(count: atlasTrackingIds.length),
                        ],
                      ],
                    ),
                    Text(
                      '${_normalizeServiceType(route.serviceType)}  ·  '
                      '${route.dispatchTime.substring(0, 5)}–'
                      '${route.shiftEndTime.substring(0, 5)}',
                      style: AppTypography.caption1.copyWith(
                        color: AppColors.labelSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Small attention-grabbing pill on a route card when one or more
/// Atlas packages are routed to that driver. Tooltip shows the
/// tracking IDs so the dispatcher can verify on the fly.
class _AtlasBadge extends StatelessWidget {
  final int count;
  const _AtlasBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_rounded,
            size: 11,
            color: AppColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            'Atlas · $count',
            style: AppTypography.caption2.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue ← for left ("links"), green → for right ("rechts").
class _SpurIndicator extends StatelessWidget {
  final bool left;
  final Color color;
  const _SpurIndicator({required this.left, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            left ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(height: 1),
          Text(
            left ? 'links' : 'rechts',
            style: TextStyle(
              fontSize: 9.5,
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDropZone extends StatelessWidget {
  final bool active;
  const _EmptyDropZone({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: double.infinity,
      decoration: BoxDecoration(
        color: active
            ? AppColors.green50
            : AppColors.surfaceLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? AppColors.codriverGreen
              : AppColors.separatorLight.withOpacity(0.6),
          width: active ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        active ? 'Hier ablegen' : 'Driver ablegen',
        style: AppTypography.caption1.copyWith(
          color: active
              ? AppColors.codriverDeep
              : AppColors.labelTertiaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Driver chip (Draggable)
// ════════════════════════════════════════════════════════════════════════════

/// Compact, content-hugging driver pill. Driver name on top, transporter
/// ID below in monospace. Whole pill is `Draggable` (using pointer
/// anchor so the pill follows the cursor exactly). Pill width = content,
/// not parent.
class _DriverChip extends StatelessWidget {
  final String transporterId;
  final String driverName;
  final String? dsp;
  final VoidCallback onRemove;

  const _DriverChip({
    required this.transporterId,
    required this.driverName,
    required this.onRemove,
    this.dsp,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _ChipBody(
      transporterId: transporterId,
      driverName: driverName,
      dsp: dsp,
      onRemove: onRemove,
    );

    return Draggable<String>(
      data: transporterId,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.95,
          child: _ChipBody(
            transporterId: transporterId,
            driverName: driverName,
            dsp: dsp,
            onRemove: onRemove,
            elevated: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }
}

class _ChipBody extends StatelessWidget {
  final String transporterId;
  final String driverName;
  final String? dsp;
  final VoidCallback onRemove;
  final bool elevated;

  const _ChipBody({
    required this.transporterId,
    required this.driverName,
    required this.onRemove,
    this.dsp,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = driverName.trim().isNotEmpty;
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.codriverGreen,
            width: 1.5,
          ),
          boxShadow: elevated ? AppElevation.level3 : AppElevation.level1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.codriverGreen,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasName ? driverName : '— kein Name —',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.15,
                      color: hasName
                          ? AppColors.codriverGraphite
                          : AppColors.labelTertiaryLight,
                      fontWeight: FontWeight.w500,
                      fontStyle: hasName ? FontStyle.normal : FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Tap-to-copy on the transporterId. Hovers light up
                  // the row + a tiny copy icon to make the affordance
                  // discoverable.
                  _CopyableId(transporterId: transporterId),
                ],
              ),
            ),
            const SizedBox(width: 10),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: AppColors.labelSecondaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// transporterId line that copies itself on tap. Shows a small copy
/// icon next to the ID and gives haptic-style feedback by briefly
/// swapping the icon for a check mark plus a Snackbar.
class _CopyableId extends StatefulWidget {
  final String transporterId;
  const _CopyableId({required this.transporterId});

  @override
  State<_CopyableId> createState() => _CopyableIdState();
}

class _CopyableIdState extends State<_CopyableId> {
  bool _hovered = false;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.transporterId));
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Transporter-ID kopiert: ${widget.transporterId}'),
          duration: const Duration(seconds: 2),
        ),
      );
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _copy,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.surfaceLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.transporterId,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.0,
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4),
              Icon(
                _copied
                    ? Icons.check_rounded
                    : Icons.content_copy_rounded,
                size: 11,
                color: _copied
                    ? AppColors.success
                    : (_hovered
                        ? AppColors.codriverDeep
                        : AppColors.labelTertiaryLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Unassigned pool (right column)
// ════════════════════════════════════════════════════════════════════════════

class _UnassignedPool extends StatelessWidget {
  final List<String> transporterIds;
  final String Function(String? transporterId) resolveName;
  final void Function(String transporterId) onDropToPool;

  const _UnassignedPool({
    required this.transporterIds,
    required this.resolveName,
    required this.onDropToPool,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => !transporterIds.contains(d.data),
      onAcceptWithDetails: (d) => onDropToPool(d.data),
      builder: (context, candidate, _) {
        final hovered = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: hovered
                  ? AppColors.codriverGreen
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 20,
                    color: AppColors.codriverDeep,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Noch nicht zugewiesen',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.codriverGraphite,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${transporterIds.length}',
                      style: AppTypography.caption1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: transporterIds.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'Driver hier hinziehen,\num zu unzuweisen.',
                            textAlign: TextAlign.center,
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.labelTertiaryLight,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: transporterIds.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (_, i) => Align(
                          alignment: Alignment.centerLeft,
                          child: _DriverChip(
                            transporterId: transporterIds[i],
                            driverName: resolveName(transporterIds[i]),
                            dsp: 'AION',
                            // Pool drivers stay where they are; tap is no-op.
                            onRemove: () {},
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Sample data — Phase 1 only. Replaced by CSV/paste import in Phase 2.
// ════════════════════════════════════════════════════════════════════════════

const List<WaveplanRoute> _sampleRoutes = [
  // Wave 1 — 11:00:00, STG-B_RED
  WaveplanRoute(
    routeCode: 'CA_A169',
    routeId: '7503578-169',
    dispatchArea: 'STG-B_RED.7',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket',
    transporterId: 'A3L9NTUOLVYR8O',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A174',
    routeId: '7503578-174',
    dispatchArea: 'STG-B_RED.8',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket Mittlerer Lieferwagen',
    transporterId: 'A3ALROM073LW44',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A175',
    routeId: '7503578-175',
    dispatchArea: 'STG-B_RED.9',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket',
    transporterId: 'A3H11XF1SVS84O',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A168',
    routeId: '7503578-168',
    dispatchArea: 'STG-B_RED.10',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket Mittlerer Lieferwagen',
    transporterId: 'A1PPLQX8HTZC2D',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A136',
    routeId: '7503578-136',
    dispatchArea: 'STG-B_RED.11',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket Mittlerer Lieferwagen',
    transporterId: 'A19DAZ4K79PT84',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A152',
    routeId: '7503578-152',
    dispatchArea: 'STG-B_RED.12',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket Mittlerer Lieferwagen',
    transporterId: 'A2IEHJ434ZM6TX',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A145',
    routeId: '7503578-145',
    dispatchArea: 'STG-B_RED.13',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket',
    transporterId: 'A1OGWC6I2AH4CB',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A162',
    routeId: '7503578-162',
    dispatchArea: 'STG-B_RED.14',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket Mittlerer Lieferwagen',
    transporterId: 'A280XZLU3W0S5Q',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A161',
    routeId: '7503578-161',
    dispatchArea: 'STG-B_RED.15',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket Mittlerer Lieferwagen',
    transporterId: 'A3H3RK2YQB79UX',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A163',
    routeId: '7503578-163',
    dispatchArea: 'STG-B_RED.16',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Standardpaket',
    transporterId: 'A25BTUGWTZWSXO',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A170',
    routeId: '7503578-170',
    dispatchArea: 'STG-B_RED.17',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Nursery Route Level 4',
    transporterId: 'AADFQ28NJOVTZ',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A159',
    routeId: '7503578-159',
    dispatchArea: 'STG-B_RED.18',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Kinderzimmer-Route Stufe 3',
    transporterId: 'AS997F0VRMPCU',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A166',
    routeId: '7503578-166',
    dispatchArea: 'STG-B_RED.19',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Kinderzimmer-Route Stufe 1',
    transporterId: 'A3TPIEIBUSUYT',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A148',
    routeId: '7503578-148',
    dispatchArea: 'STG-B_RED.20',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Kinderzimmer-Route Stufe 1',
    transporterId: 'A32HYJY6YR0GO9',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A154',
    routeId: '7503578-154',
    dispatchArea: 'STG-B_RED.21',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Kinderzimmer-Route Stufe 1',
    transporterId: 'A3LN0IILNR3WUN',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A165',
    routeId: '7503578-165',
    dispatchArea: 'STG-B_RED.22',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Kinderzimmer-Route Stufe 1',
    transporterId: 'ABECJ3GWAFJZ',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A164',
    routeId: '7503578-164',
    dispatchArea: 'STG-B_RED.23',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Kinderzimmer-Route Stufe 1',
    transporterId: 'A30JN9TQJHIV1R',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A160',
    routeId: '7503578-160',
    dispatchArea: 'STG-B_RED.24',
    waitingAreaSpur: 'links',
    dispatchTime: '11:00:00',
    shiftEndTime: '20:00:00',
    serviceType: 'Kinderzimmer-Route Stufe 1',
    transporterId: 'A2KC3U90DIZFMR',
    assignedDsp: 'AION',
  ),

  // Wave 2 — 11:20:00, STG-C_YELLOW
  WaveplanRoute(
    routeCode: 'CA_A143',
    routeId: '7503578-143',
    dispatchArea: 'STG-C_YELLOW.1',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A5A6I65TGFZ5R',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A142',
    routeId: '7503578-142',
    dispatchArea: 'STG-C_YELLOW.2',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A1NMK9VZFYROPQ',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A173',
    routeId: '7503578-173',
    dispatchArea: 'STG-C_YELLOW.3',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A1ISAABLH0O0ES',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A167',
    routeId: '7503578-167',
    dispatchArea: 'STG-C_YELLOW.4',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A1FUK8W5UWQSF9',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A138',
    routeId: '7503578-138',
    dispatchArea: 'STG-C_YELLOW.5',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A2I58T8EHFRIEO',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A144',
    routeId: '7503578-144',
    dispatchArea: 'STG-C_YELLOW.6',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A1P7WR7XVP66BE',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A146',
    routeId: '7503578-146',
    dispatchArea: 'STG-C_YELLOW.7',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A2MZ9R6Z5RTM0K',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A153',
    routeId: '7503578-153',
    dispatchArea: 'STG-C_YELLOW.8',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A3VBUAN22RR3XX',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A156',
    routeId: '7503578-156',
    dispatchArea: 'STG-C_YELLOW.9',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'APRZ8PWWNT126',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A150',
    routeId: '7503578-150',
    dispatchArea: 'STG-C_YELLOW.10',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A3VX1BN9SXV2X4',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A149',
    routeId: '7503578-149',
    dispatchArea: 'STG-C_YELLOW.11',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A3FTNUP0KX138H',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A151',
    routeId: '7503578-151',
    dispatchArea: 'STG-C_YELLOW.12',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'ASMX0VHXOGCDW',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A155',
    routeId: '7503578-155',
    dispatchArea: 'STG-C_YELLOW.13',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A11QQXKOJRNZUJ',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A157',
    routeId: '7503578-157',
    dispatchArea: 'STG-C_YELLOW.14',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A20YHLI0TJ9VIM',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A158',
    routeId: '7503578-158',
    dispatchArea: 'STG-C_YELLOW.15',
    waitingAreaSpur: 'rechts',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Standard Parcel - Low Emission Vehicle',
    transporterId: 'A33UCX3JZMWN76',
    assignedDsp: 'AION',
  ),
  WaveplanRoute(
    routeCode: 'CA_A147',
    routeId: '7503578-147',
    dispatchArea: 'STG-C_YELLOW.16',
    waitingAreaSpur: 'links',
    dispatchTime: '11:20:00',
    shiftEndTime: '20:20:00',
    serviceType: 'Kinderzimmer Route Stufe 1 - LEV',
    transporterId: 'A1SPHJKW2GCFAJ',
    assignedDsp: 'AION',
  ),
];
