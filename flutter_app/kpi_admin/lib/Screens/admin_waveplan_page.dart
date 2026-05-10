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

import '../localization/app_localizations.dart';
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
  String generalNotes;

  _ProgramSnapshot({
    List<WaveplanRoute>? routes,
    List<String>? unassigned,
    Map<String, List<String>>? atlasByRoute,
    this.atlasConfirmed = false,
    this.isPublished = false,
    this.publishedAt,
    this.generalNotes = '',
  })  : routes = routes ?? [],
        unassigned = unassigned ?? [],
        atlasByRoute = atlasByRoute ?? {};
}

const List<Map<String, String>> _programs = [
  {'key': 'sameday_a', 'label': 'Sameday A'},
  {'key': 'nextday', 'label': 'Nextday'},
  {'key': 'sameday_c', 'label': 'Sameday C'},
];

class _AdminWaveplanPageState extends State<AdminWaveplanPage> {
  // Per-program saved state. Each program starts empty — the dispatcher
  // imports a fresh waveplan every day via the paste-box.
  final Map<String, _ProgramSnapshot> _saved = {
    'sameday_a': _ProgramSnapshot(),
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
  ///
  /// Dispatchers and shift brackets are intentionally NOT swapped —
  /// they are page-level state shared across all three programs.
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
    _generalNotes = snap.generalNotes;
    _waveAnchors.clear();
  }

  /// Persist the visible state back into the snapshot for [programKey]
  /// before the user navigates to another program. Dispatcher state
  /// is shared and stored at page level, not in the snapshot.
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ProgramTabs(
                        active: _activeProgram,
                        onSelect: _switchProgram,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: StreamBuilder<List<String>>(
                          stream: _dispatcherNamesStream,
                          builder: (context, dispSnap) {
                            final available =
                                dispSnap.data ?? const <String>[];
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
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _Header(
                    programLabel: _programs.firstWhere(
                      (p) => p['key'] == _activeProgram,
                      orElse: () => _programs[0],
                    )['label']!,
                    onPaste: _showPasteDialog,
                    onAtlasPaste: _showAtlasPasteDialog,
                    onNotesEdit: _showNotesDialog,
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
                    notesLength: _generalNotes.trim().length,
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
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(t.t('waveplan_atlas_dialog_title')),
          ],
        ),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.t('waveplan_atlas_dialog_intro'),
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
            child: Text(t.t('waveplan_btn_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_kAtlasNoneToday),
            child: Text(t.t('waveplan_atlas_dialog_btn_none_today')),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.primary),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(t.t('waveplan_btn_import')),
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
        SnackBar(
          content: Text(t.t('waveplan_snack_atlas_none_confirmed')),
        ),
      );
      return;
    }

    if (result.trim().isEmpty) return;

    final parsed = _parseAtlasPaste(result);
    if (parsed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('waveplan_snack_atlas_invalid')),
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
          t.tf('waveplan_snack_atlas_imported', {
            'total': '$total',
            'routes': '${parsed.length}',
          }),
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

  /// Notes editor for the active program. Each program (Sameday A,
  /// Nextday, Sameday C) carries its own notes line — switching tabs
  /// swaps the persisted draft.
  Future<void> _showNotesDialog() async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController(text: _generalNotes);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.campaign_rounded,
              color: AppColors.codriverDeep,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(t.t('waveplan_notes_dialog_title')),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.t('waveplan_notes_dialog_intro'),
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 10,
                autofocus: true,
                style: AppTypography.footnote.copyWith(
                  color: AppColors.codriverGraphite,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: t.t('waveplan_notes_dialog_hint'),
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
            child: Text(t.t('waveplan_btn_cancel')),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.primary),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(t.t('waveplan_btn_save')),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() {
      _generalNotes = result;
    });
  }

  Future<void> _showPasteDialog() async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('waveplan_paste_dialog_title')),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.t('waveplan_paste_dialog_intro'),
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
            child: Text(t.t('waveplan_btn_cancel')),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.primary),
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(t.t('waveplan_btn_import')),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    final parsed = _parsePastedWaveplan(result);
    if (parsed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('waveplan_snack_routes_invalid'))),
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
      SnackBar(
        content: Text(
          t.tf('waveplan_snack_routes_imported', {'count': '${parsed.length}'}),
        ),
      ),
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
    final t = AppLocalizations.of(context);
    final ref = _publishedDocRef();
    if (ref == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.t('waveplan_snack_login_required'))),
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
          SnackBar(
            content: Text(
              t.tf('waveplan_snack_unpublish_failed', {'error': '$e'}),
            ),
          ),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _isPublished = false;
        _publishedAt = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('waveplan_snack_unpublished')),
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
        SnackBar(
          content: Text(
            t.tf('waveplan_snack_publish_failed', {'error': '$e'}),
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _isPublished = true;
      _publishedAt = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.t('waveplan_snack_published')),
      ),
    );
  }

  Future<void> _clearWaveplan() async {
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('waveplan_clear_dialog_title')),
        content: Text(t.t('waveplan_clear_dialog_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('waveplan_btn_cancel')),
          ),
          FilledButton(
            style: AppButtonStyle.of(AppButtonVariant.destructive),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('waveplan_btn_clear')),
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
  final String programLabel;
  final VoidCallback onPaste;
  final VoidCallback onAtlasPaste;
  final VoidCallback onNotesEdit;
  final VoidCallback? onClear;
  final VoidCallback? onPublishToggle;
  final bool isPublished;
  final DateTime? publishedAt;
  final int routeCount;
  final int assignedCount;
  final int atlasTotal;
  final bool atlasConfirmed;
  final int notesLength;

  const _Header({
    required this.programLabel,
    required this.onPaste,
    required this.onAtlasPaste,
    required this.onNotesEdit,
    required this.onClear,
    required this.onPublishToggle,
    required this.isPublished,
    required this.publishedAt,
    required this.routeCount,
    required this.assignedCount,
    required this.atlasTotal,
    required this.atlasConfirmed,
    required this.notesLength,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Order:
    //   1. Wave data (title + paste + stats)
    //   2. Atlas
    //   3. Note
    //   (Spacer)
    //   Clear · Publish
    //
    // Wrapped in a Row so the right-aligned items stay flush right on
    // wide screens; the left side uses a Wrap so it line-breaks on
    // narrow screens instead of clipping.
    final left = Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Waveplan · $programLabel',
          style: AppTypography.title2.copyWith(
            color: AppColors.codriverGraphite,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.codriverGreen,
              width: 1,
            ),
          ),
          child: Text(
            t.tf('waveplan_assigned_count', {
              'assigned': '$assignedCount',
              'total': '$routeCount',
            }),
            style: AppTypography.caption1.copyWith(
              color: AppColors.codriverDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _SmallActionButton(
          icon: Icons.content_paste_rounded,
          label: t.t('waveplan_btn_paste_wave'),
          onTap: onPaste,
        ),
        _SmallActionButton(
          icon: atlasConfirmed && atlasTotal == 0
              ? Icons.check_circle_outline_rounded
              : Icons.inventory_2_rounded,
          label: atlasTotal > 0
              ? t.tf('waveplan_btn_atlas_count', {'count': '$atlasTotal'})
              : (atlasConfirmed
                  ? t.t('waveplan_btn_atlas_none')
                  : t.t('waveplan_btn_atlas')),
          onTap: onAtlasPaste,
          accent: atlasConfirmed && atlasTotal == 0
              ? AppColors.success
              : AppColors.warning,
        ),
        _SmallActionButton(
          icon: notesLength > 0
              ? Icons.sticky_note_2_rounded
              : Icons.edit_note_rounded,
          label: notesLength > 0
              ? t.tf('waveplan_btn_notes_count', {'count': '$notesLength'})
              : t.t('waveplan_btn_notes'),
          onTap: onNotesEdit,
          accent: notesLength > 0 ? AppColors.codriverDeep : null,
        ),
      ],
    );

    final right = Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _SmallActionButton(
          icon: Icons.delete_outline_rounded,
          label: t.t('waveplan_btn_clear'),
          onTap: onClear,
          danger: true,
        ),
        _PublishButton(
          isPublished: isPublished,
          publishedAt: publishedAt,
          onToggle: onPublishToggle,
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: left),
        const SizedBox(width: AppSpacing.sm),
        right,
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
    final loc = AppLocalizations.of(context);
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
            ? loc.t('waveplan_publish_disabled_tooltip')
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
                      ? loc.tf('waveplan_published_label', {
                          'time': _timeLabel(),
                        })
                      : loc.t('waveplan_publish_label'),
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
    // routeIndex carries an alternate-row flag for the zebra striping —
    // we restart the count at each new wave so the first route under
    // a header always gets the same band.
    final items = <_ListItem>[];
    String? currentWave;
    int waveCount = 0;
    int routeIndex = 0;
    for (var i = 0; i < routes.length; i++) {
      final r = routes[i];
      if (r.dispatchTime != currentWave) {
        currentWave = r.dispatchTime;
        waveCount = routes.where((x) => x.dispatchTime == currentWave).length;
        items.add(_HeaderItem(currentWave!, waveCount));
        routeIndex = 0;
      }
      items.add(_RouteItem(r, routeIndex.isOdd));
      routeIndex++;
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
        final routeItem = it as _RouteItem;
        return _RouteCard(
          route: routeItem.route,
          atlasTrackingIds: atlasFor(routeItem.route.routeCode),
          resolveName: resolveName,
          onAssign: (tid) => onAssign(routeItem.route.routeId, tid),
          onUnassign: () => onUnassign(routeItem.route.routeId),
          isAlternate: routeItem.isAlternate,
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
    final t = AppLocalizations.of(context);
    final remaining = available.where((n) => !selected.contains(n)).toList();
    final canAddMore = selected.length < maxSelectable;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
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
        children: [
          const SizedBox(width: 4),
          const Icon(
            Icons.headset_mic_rounded,
            size: 16,
            color: AppColors.codriverDeep,
          ),
          const SizedBox(width: 6),
          Text(
            t.t('waveplan_dispatcher_label'),
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: available.isEmpty
                ? Text(
                    t.t('waveplan_dispatcher_empty'),
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final name in selected)
                        _DispatcherRow(
                          name: name,
                          range: shiftByDispatcher[name] ??
                              _defaultShiftFor(selected.indexOf(name)),
                          onShiftChanged: (r) => onShiftChanged(name, r),
                          onRemove: () => onRemoveDispatcher(name),
                        ),
                      if (canAddMore && remaining.isNotEmpty)
                        for (final name in remaining)
                          _AddDispatcherChip(
                            name: name,
                            onTap: () => onAddDispatcher(name),
                          ),
                      if (!canAddMore)
                        Text(
                          t.tf('waveplan_dispatcher_max', {
                            'n': '$maxSelectable',
                          }),
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelTertiaryLight,
                            fontStyle: FontStyle.italic,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selected pill — name + inline X. Clicking the X (or the
        // whole pill) removes the dispatcher from the selection.
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
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
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _TimeDropdown(
          value: range.start,
          onChanged: (v) => onShiftChanged(
            _ShiftRange(start: v, end: range.end),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('–'),
        ),
        _TimeDropdown(
          value: range.end,
          onChanged: (v) => onShiftChanged(
            _ShiftRange(start: range.start, end: v),
          ),
        ),
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
  final bool isAlternate;
  const _RouteItem(this.route, this.isAlternate);
}

class _WaveSectionHeader extends StatelessWidget {
  final String wave;
  final int count;
  const _WaveSectionHeader({required this.wave, required this.count});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
          t.tf('waveplan_wave_routes_count', {'count': '$count'}),
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
  final bool isAlternate;

  const _RouteCard({
    required this.route,
    required this.atlasTrackingIds,
    required this.resolveName,
    required this.onAssign,
    required this.onUnassign,
    required this.isAlternate,
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
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: hovered
                ? AppColors.green50
                : (isAlternate
                    ? AppColors.surfaceLight
                    : AppColors.surfaceElevatedLight),
            border: Border(
              left: BorderSide(
                color: hovered ? AppColors.codriverGreen : Colors.transparent,
                width: 3,
              ),
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
    final t = AppLocalizations.of(context);
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
            t.tf('waveplan_btn_atlas_count', {'count': '$count'}),
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
    final t = AppLocalizations.of(context);
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
        active ? t.t('waveplan_drop_here') : t.t('waveplan_drop_driver'),
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
    final t = AppLocalizations.of(context);
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
                            t.t('waveplan_pool_empty'),
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

