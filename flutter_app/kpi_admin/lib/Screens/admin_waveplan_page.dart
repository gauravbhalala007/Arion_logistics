// lib/Screens/admin_waveplan_page.dart
//
// Daily dispatch / Waveplan view. Routes are grouped by dispatch wave
// (start time). Each route shows its code, dispatch area + spur, and
// the assigned driver. Driver names are resolved live from
// `users/{uid}/drivers/{doc}` (same source as Scorecard / Drivers Hub).
// Drag-and-drop moves a driver between routes; the X button or the
// right-hand pool unassigns a driver. Phase 1 MVP — assignments live
// in memory; CSV/paste import is wired so dispatchers can load data.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/shift_plan.dart';
import '../models/waveplan_route.dart';
import '../services/public_plan_service.dart';
import '../services/shift_plan_repository.dart';
import '../widgets/share_link_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/driver_activity.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import '../widgets/waveplan_date_strip.dart';

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

  /// Day the dispatcher is currently viewing. Defaults to today.
  /// Persisted nowhere — refresh = back to today.
  late DateTime _selectedDate;

  // Page-level dispatcher coordination — one bar at the top covers
  // every wave. Up to 3 dispatchers; each one has its own shift
  // bracket (independent picker). One free-form notes line is shown
  // to drivers after publish.
  final List<String> _selectedDispatchers = [];
  final Map<String, _ShiftRange> _shiftByDispatcher = {};
  static const int _maxDispatchers = 3;

  String _generalNotes = '';

  /// Query of the driver search bar above the route list.
  String _driverSearch = '';

  // Ticket "CTRL+F": Cmd/Ctrl+F fokussiert die Fahrer-Suchleiste
  // (Browser-Suche greift in Flutter-Web nicht).
  final FocusNode _driverSearchFocus = FocusNode();

  bool _onGlobalKey(KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.keyF &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      if (_driverSearchFocus.canRequestFocus) {
        _driverSearchFocus.requestFocus();
        return true;
      }
    }
    return false;
  }

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

  // Manually added drivers that are NOT in the Amazon waveplan (e.g.
  // "infinities after sequence"). We give each a synthetic transporter-ID
  // (`MANUAL-<micros>`) and store the typed name here so the existing
  // name-resolution (list, PDF, share, driver app) works unchanged once
  // this map is merged into `namesMap`.
  final Map<String, String> _manualNames = {};

  // Latest merged names map (driver names + manual), captured during build
  // so bottom sheets / dialogs opened off the main tree can reuse it.
  Map<String, String> _lastNamesMap = const {};

  static bool _isManualTid(String? tid) =>
      tid != null && tid.startsWith('MANUAL-');

  // Scroll-to-wave anchors. One GlobalKey per wave timestamp,
  // attached to the section header in the list.
  final Map<String, GlobalKey> _waveAnchors = {};

  // transporterId (normalized) → driverName, streamed from Firestore.
  // Mirrors the resolution used in scorecard_overview.dart.
  Stream<Map<String, String>>? _namesStream;

  /// Live list of active drivers (with createdAt) — feeds the "Add from
  /// Drivers Hub" picker and the Newest/Oldest sort in the pool.
  Stream<List<_PickableDriver>>? _activeDriversStreamSrc;

  /// Published shift plan for the currently-selected date, populated by
  /// [_watchShiftPlan]. Lets us surface Park / Dispatch times that the
  /// admin already chose in the Shift Plan page.
  ShiftPlanDoc? _shiftPlanDoc;
  Map<String, ShiftPlanEntry> _shiftByTid =
      const <String, ShiftPlanEntry>{};
  StreamSubscription<ShiftPlanDoc?>? _shiftPlanSub;
  final ShiftPlanRepository _shiftPlanRepo = ShiftPlanRepository();

  String _dateKeyOf(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  void _watchShiftPlan() {
    _shiftPlanSub?.cancel();
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _shiftPlanSub = _shiftPlanRepo
        .watch(adminUid: uid, dateKey: _dateKeyOf(_selectedDate))
        .listen((doc) {
      if (!mounted) return;
      setState(() {
        _shiftPlanDoc = doc;
        final map = <String, ShiftPlanEntry>{};
        if (doc != null) {
          for (final e in doc.entries) {
            final tid = e.transporterId.trim().toUpperCase();
            if (tid.isNotEmpty) map[tid] = e;
          }
        }
        _shiftByTid = map;
      });
    });
  }

  /// Parking arrival time computed for [tid] from the shift plan.
  /// Mirrors the same logic used in admin_shift_plan_page.dart.
  String? _shiftParkingFor(String tid) {
    final doc = _shiftPlanDoc;
    final entry = _shiftByTid[tid.trim().toUpperCase()];
    if (doc == null || entry == null) return null;
    final override = entry.meetingTime.trim();
    if (override.isNotEmpty) return override;
    if (entry.blocks.isEmpty) return null;
    final raw = entry.blocks.first.startTime.trim();
    final m = RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)?',
            caseSensitive: false)
        .firstMatch(raw);
    if (m == null) return null;
    var h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final min = int.tryParse(m.group(2) ?? '0') ?? 0;
    final suf = (m.group(3) ?? '').toLowerCase();
    if (suf == 'pm' && h < 12) h += 12;
    if (suf == 'am' && h == 12) h = 0;
    final mins = h * 60 + min - doc.parkingOffsetMinutes;
    if (mins < 0) return null;
    final hh = (mins ~/ 60).toString().padLeft(2, '0');
    final mm = (mins % 60).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onGlobalKey);
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _namesStream = _driversNameMapGlobal();
    _activeDriversStreamSrc = _activeDriversStream();
    _dispatcherNamesStream = _streamDispatcherNames();
    _loadProgram(_activeProgram);
    _watchPublished();
    WidgetsBinding.instance.addPostFrameCallback((_) => _watchShiftPlan());
  }

  /// Opens a dialog listing every driver in the published shift plan
  /// with their parking and dispatch times. Read-only — admin edits go
  /// through the Shift Plan page itself.
  Future<void> _openShiftPlanTimesDialog(
    Map<String, String> namesMap,
  ) async {
    final doc = _shiftPlanDoc;
    if (doc == null) return;
    final entries = doc.entries
        .where((e) => e.transporterId.trim().isNotEmpty)
        .toList()
      ..sort((a, b) {
        final at = a.blocks.isNotEmpty ? a.blocks.first.startTime : '';
        final bt = b.blocks.isNotEmpty ? b.blocks.first.startTime : '';
        return at.compareTo(bt);
      });
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.green50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.event_note_rounded,
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
                            'Shift plan · ${entries.length} drivers',
                            style: AppTypography.title3.copyWith(
                              color: AppColors.codriverGraphite,
                            ),
                          ),
                          Text(
                            'Park = dispatch − ${doc.parkingOffsetMinutes} min',
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.labelSecondaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: entries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                          ),
                          child: Center(
                            child: Text(
                              'No drivers in the shift plan yet.',
                              style: AppTypography.body.copyWith(
                                color: AppColors.labelSecondaryLight,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (ctx, i) {
                            final e = entries[i];
                            final tid =
                                e.transporterId.trim().toUpperCase();
                            final name = e.driverName.isNotEmpty
                                ? e.driverName
                                : (namesMap[tid] ?? tid);
                            final dispatch = e.blocks.isNotEmpty
                                ? e.blocks.first.startTime
                                : '—';
                            final park = _shiftParkingFor(tid) ?? '—';
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.separatorLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTypography.subheadline
                                              .copyWith(
                                            color: AppColors
                                                .codriverGraphite,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          tid,
                                          style: AppTypography.caption2
                                              .copyWith(
                                            color: AppColors
                                                .labelSecondaryLight,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _ShiftPlanTimePill(
                                    label: 'Park',
                                    value: park,
                                    accent: AppColors.codriverDeep,
                                  ),
                                  const SizedBox(width: 6),
                                  _ShiftPlanTimePill(
                                    label: 'Dispatch',
                                    value: dispatch,
                                    accent: AppColors.codriverGreen,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Set / clear the mentee for the route identified by [routeId].
  void _assignMentee(String routeId, String? menteeTid) {
    setState(() {
      _routes = _routes.map((r) {
        if (r.routeId != routeId) return r;
        if (menteeTid == null || menteeTid.trim().isEmpty) {
          return r.copyWith(clearMenteeTransporterId: true);
        }
        return r.copyWith(menteeTransporterId: menteeTid.trim());
      }).toList();
    });
    _scheduleDraftSave();
  }

  /// Cycles the waiting-area lane for one route: none → left → right → none.
  /// Lets admins fill in the direction the public link shows as a pill.
  void _cycleRouteSpur(String routeId) {
    setState(() {
      _routes = _routes.map((r) {
        if (r.routeId != routeId) return r;
        final next = switch (r.waitingAreaSpur.toLowerCase()) {
          'links' => 'rechts',
          'rechts' => '',
          _ => 'links',
        };
        return r.copyWith(waitingAreaSpur: next);
      }).toList();
    });
    _scheduleDraftSave();
  }

  /// transporterIds already used in this wave (either as the primary
  /// driver or as a mentee). Used to filter the "Add Mentee" search.
  Set<String> get _inWaveTids {
    final out = <String>{};
    for (final r in _routes) {
      final t = (r.transporterId ?? '').trim().toUpperCase();
      if (t.isNotEmpty) out.add(t);
      final m = (r.menteeTransporterId ?? '').trim().toUpperCase();
      if (m.isNotEmpty) out.add(m);
    }
    return out;
  }

  /// Switch the displayed day. Resets in-memory state for ALL programs
  /// so we don't leak yesterday's snapshot into today's view, then
  /// re-watches the published doc for the new date.
  void _changeDate(DateTime d) {
    final next = DateTime(d.year, d.month, d.day);
    if (next == _selectedDate) return;
    setState(() {
      _selectedDate = next;
      // Reset all program snapshots — hydration will refill them from
      // the new date's published doc if it exists.
      for (final k in _saved.keys) {
        _saved[k] = _ProgramSnapshot();
      }
      _routes = <WaveplanRoute>[];
      _unassigned.clear();
      _atlasByRoute.clear();
      _atlasConfirmed = false;
      _isPublished = false;
      _publishedAt = null;
      _generalNotes = '';
      _waveAnchors.clear();
      _hydratedPrograms.clear();
    });
    _watchPublished();
    _watchShiftPlan();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _driverSearchFocus.dispose();
    _publishedSub?.cancel();
    _shiftPlanSub?.cancel();
    // Flush a pending debounced draft save so the last edit isn't lost.
    if (_draftSaveTimer?.isActive ?? false) {
      _draftSaveTimer?.cancel();
      // ignore: discarded_futures
      _saveDraft();
    }
    super.dispose();
  }

  /// Listens to the active program's `published_waveplans/{date}_{program}`
  /// doc so the publish/unpublish toggle reflects Firestore reality
  /// even after a page reload — without this the local `_isPublished`
  /// flag resets to false and the user can't unpublish what was
  /// already pushed live.
  ///
  /// On the very first emit per program-switch we also **hydrate** the
  /// local working state (routes, atlas, dispatchers, notes) from the
  /// doc so reloading the page mid-day brings back the wave. Since the
  /// doc id is `{YYYY-MM-DD}_{program}`, yesterday's wave never leaks
  /// into today — a new day automatically starts empty.
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _publishedSub;
  final Set<String> _hydratedPrograms = <String>{};

  /// Debounced internal draft save so an imported/edited wave survives a
  /// reload even BEFORE it is published.
  Timer? _draftSaveTimer;

  void _watchPublished() {
    _publishedSub?.cancel();
    final ref = _publishedDocRef();
    if (ref == null) return;
    final hydrationProgram = _activeProgram;
    _publishedSub = ref.snapshots().listen((snap) {
      if (!mounted) return;
      final exists = snap.exists;
      final data = snap.data() ?? const <String, dynamic>{};
      final ts = data['publishedAt'];
      final at = ts is Timestamp ? ts.toDate() : null;
      final shouldHydrate =
          exists && !_hydratedPrograms.contains(hydrationProgram);
      setState(() {
        _isPublished = exists;
        _publishedAt = at;
        if (shouldHydrate) {
          _hydrateFromPublishedDoc(data);
          _hydratedPrograms.add(hydrationProgram);
        }
      });
      // No published doc → restore the internal draft once, so
      // unpublished work comes back after a reload.
      if (!exists) {
        // ignore: discarded_futures
        _hydrateFromDraftIfAny(hydrationProgram);
      }
    });
  }

  DocumentReference<Map<String, dynamic>>? _draftDocRefFor(String program) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final d = _selectedDate;
    final date =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('waveplan_drafts')
        .doc('${date}_$program');
  }

  /// One-time draft hydration for [hydrationProgram] — only when nothing
  /// is loaded locally and no published doc exists.
  Future<void> _hydrateFromDraftIfAny(String hydrationProgram) async {
    if (_hydratedPrograms.contains(hydrationProgram)) return;
    final ref = _draftDocRefFor(hydrationProgram);
    if (ref == null) return;
    DocumentSnapshot<Map<String, dynamic>> snap;
    try {
      snap = await ref.get();
    } catch (_) {
      return;
    }
    if (!mounted) return;
    if (hydrationProgram != _activeProgram) return;
    if (_hydratedPrograms.contains(hydrationProgram)) return;
    if (_routes.isNotEmpty) return; // local edits win
    final data = snap.data();
    if (data == null) return;
    setState(() {
      _hydrateFromPublishedDoc(data);
      // Published docs force the atlas gate open — drafts keep the truth.
      _atlasConfirmed =
          data['atlasConfirmed'] == true || _atlasByRoute.isNotEmpty;
      _hydratedPrograms.add(hydrationProgram);
    });
  }

  void _scheduleDraftSave() {
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  /// Persists the current editor state to `waveplan_drafts` (best-effort,
  /// never publishes to drivers). An empty wave deletes the draft.
  Future<void> _saveDraft() async {
    final ref = _draftDocRefFor(_activeProgram);
    if (ref == null) return;
    // Diensthabende Dispatcher gelten tagesweit — in alle Programme des
    // Tages spiegeln, damit ein Link aus Nextday oder Sameday C sie
    // ebenfalls enthält (auch nach einem Neuladen der Seite).
    unawaited(_mirrorDispatchersToOtherPrograms());
    if (_routes.isEmpty) {
      try {
        await ref.delete();
      } catch (_) {}
      return;
    }
    final payloadRoutes = _routes.map((r) {
      return {
        'routeCode': r.routeCode,
        'routeId': r.routeId,
        'dispatchArea': r.dispatchArea,
        'spur': r.waitingAreaSpur,
        'dispatchTime': r.dispatchTime,
        'shiftEnd': r.shiftEndTime,
        'serviceType': r.serviceType,
        'transporterId': r.transporterId ?? '',
        'assignedDsp': r.assignedDsp ?? '',
        'menteeTransporterId': r.menteeTransporterId ?? '',
        'atlasTrackingIds': _atlasByRoute[r.routeCode] ?? const <String>[],
      };
    }).toList();
    try {
      await ref.set({
        'program': _activeProgram,
        'routes': payloadRoutes,
        'manualNames': _manualNames,
        'dispatchers': [
          for (final name in _selectedDispatchers)
            {
              'name': name,
              'start': _shiftByDispatcher[name]?.start ?? '',
              'end': _shiftByDispatcher[name]?.end ?? '',
            },
        ],
        'notes': _generalNotes.trim(),
        'atlasConfirmed': _atlasConfirmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Draft save is best-effort — publishing still works without it.
    }
  }

  /// Schreibt die Dispatcher-Auswahl in die Entwürfe der übrigen
  /// Programme desselben Tages. Ohne das steht sie nur im gerade
  /// bearbeiteten Programm, und ein Link aus einem anderen Programm
  /// geht ohne Dispatcher raus.
  Future<void> _mirrorDispatchersToOtherPrograms() async {
    final payload = [
      for (final name in _selectedDispatchers)
        {
          'name': name,
          'start': _shiftByDispatcher[name]?.start ?? '',
          'end': _shiftByDispatcher[name]?.end ?? '',
        },
    ];
    for (final p in const ['sameday_a', 'nextday', 'sameday_c']) {
      if (p == _activeProgram) continue;
      final other = _draftDocRefFor(p);
      if (other == null) continue;
      try {
        await other.set({
          'dispatchers': payload,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Best effort — der eigentliche Entwurf ist bereits gespeichert.
      }
    }
  }

  /// Restore a published wave back into the editor state. Called once
  /// per program, the first time we see the doc exists.
  void _hydrateFromPublishedDoc(Map<String, dynamic> data) {
    final rawRoutes = data['routes'];
    if (rawRoutes is List) {
      _routes = [
        for (final r in rawRoutes)
          if (r is Map<String, dynamic>)
            WaveplanRoute(
              routeCode: (r['routeCode'] ?? '').toString(),
              routeId: (r['routeId'] ?? '').toString(),
              dispatchArea: (r['dispatchArea'] ?? '').toString(),
              waitingAreaSpur: (r['spur'] ?? '').toString(),
              dispatchTime: (r['dispatchTime'] ?? '').toString(),
              shiftEndTime: (r['shiftEnd'] ?? '').toString(),
              serviceType: (r['serviceType'] ?? '').toString(),
              transporterId: ((r['transporterId'] ?? '').toString().isEmpty)
                  ? null
                  : (r['transporterId'] as String),
              assignedDsp: ((r['assignedDsp'] ?? '').toString().isEmpty)
                  ? null
                  : (r['assignedDsp'] as String),
              menteeTransporterId:
                  ((r['menteeTransporterId'] ?? '').toString().isEmpty)
                      ? null
                      : (r['menteeTransporterId'] as String),
            ),
      ];
      _atlasByRoute.clear();
      for (final r in rawRoutes) {
        if (r is Map<String, dynamic>) {
          final code = (r['routeCode'] ?? '').toString();
          final ids = r['atlasTrackingIds'];
          if (code.isEmpty || ids is! List) continue;
          final list = ids.map((e) => e.toString()).toList();
          if (list.isNotEmpty) _atlasByRoute[code] = list;
        }
      }
      // Restore manually-typed driver names. Prefer the explicit map
      // (drafts); fall back to the denormalized `driverName` on each
      // manual route (published docs don't carry the map).
      _manualNames.clear();
      final rawManual = data['manualNames'];
      if (rawManual is Map) {
        rawManual.forEach((k, v) {
          final key = k.toString();
          final name = (v ?? '').toString();
          if (key.isNotEmpty && name.isNotEmpty) _manualNames[key] = name;
        });
      }
      for (final r in rawRoutes) {
        if (r is Map<String, dynamic>) {
          final tid = (r['transporterId'] ?? '').toString();
          final name = (r['driverName'] ?? '').toString();
          if (_isManualTid(tid) &&
              name.isNotEmpty &&
              !_manualNames.containsKey(tid)) {
            _manualNames[tid] = name;
          }
        }
      }
      // If atlas data came back at all, also lift the publish gate.
      _atlasConfirmed = true;
      _waveAnchors.clear();
    }

    final notes = (data['notes'] ?? '').toString();
    _generalNotes = notes;

    // Ticket: Dispatcher fehlten im geteilten Link bei Nextday und
    // Sameday C. Die diensthabenden Dispatcher gelten für den ganzen
    // Tag, nicht je Programm — eine leere Liste aus einem Programm darf
    // eine bereits gesetzte Auswahl deshalb nicht löschen.
    final disp = data['dispatchers'];
    if (disp is List && disp.isNotEmpty) {
      _selectedDispatchers.clear();
      _shiftByDispatcher.clear();
      for (final d in disp) {
        if (d is Map<String, dynamic>) {
          final name = (d['name'] ?? '').toString().trim();
          if (name.isEmpty) continue;
          _selectedDispatchers.add(name);
          _shiftByDispatcher[name] = _ShiftRange(
            start: (d['start'] ?? '').toString(),
            end: (d['end'] ?? '').toString(),
          );
        }
      }
    }
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
    // Re-bind the published-state stream to the new program's doc.
    _watchPublished();
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

  /// All currently-working drivers of this DSP, enriched with the
  /// metadata needed for the in-app picker (name + createdAt). Used for
  /// the "Add from Drivers Hub" + sort flow on programs (SD_A/SD_C)
  /// where Amazon doesn't deliver an email waveplan we could paste.
  Stream<List<_PickableDriver>> _activeDriversStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
          final out = <_PickableDriver>[];
          for (final d in snap.docs) {
            final data = d.data();
            if (!isDriverWorking(data)) continue;
            final tid = (data['transporterId'] ?? d.id).toString().trim();
            if (tid.isEmpty) continue;
            final name = (data['driverName'] ?? data['fullName'] ?? '')
                .toString()
                .trim();
            final created = (data['createdAt'] as Timestamp?)?.toDate()
                ?? (data['addedAt'] as Timestamp?)?.toDate();
            out.add(_PickableDriver(
              tid: tid.toUpperCase(),
              name: name,
              createdAt: created,
            ));
          }
          return out;
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

  /// Search filter for the route list: matches the assigned driver
  /// (name or TID), the mentee and the route code. Empty query → all.
  List<WaveplanRoute> _filterRoutesBySearch(
    List<WaveplanRoute> routes,
    Map<String, String> namesMap,
  ) {
    final q = _driverSearch.trim().toLowerCase();
    if (q.isEmpty) return routes;
    return routes.where((r) {
      final tid = (r.transporterId ?? '').toLowerCase();
      final name = _resolveName(namesMap, r.transporterId).toLowerCase();
      final menteeTid = (r.menteeTransporterId ?? '').toLowerCase();
      final menteeName =
          _resolveName(namesMap, r.menteeTransporterId).toLowerCase();
      final code = r.routeCode.toLowerCase();
      return tid.contains(q) ||
          name.contains(q) ||
          menteeTid.contains(q) ||
          menteeName.contains(q) ||
          code.contains(q);
    }).toList();
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
    _scheduleDraftSave();
  }

  void _unassign(String routeId) {
    setState(() {
      final idx = _routes.indexWhere((r) => r.routeId == routeId);
      if (idx == -1) return;
      final tid = _routes[idx].transporterId;
      if (tid == null) return;

      // Bei manuell angelegten Einträgen IST die Transporter-ID die
      // Identität der Route. Würde man sie nur leeren, bliebe eine Route
      // zurück, die nicht mehr als manuell erkannt wird — sie tauchte
      // dann weder in "Einträge bearbeiten" auf noch ließ sie sich
      // löschen oder neu besetzen. Deshalb entfällt der ganze Eintrag.
      if (_isManualTid(tid)) {
        _routes.removeAt(idx);
        _manualNames.remove(tid);
        return;
      }

      _routes[idx] = _routes[idx].copyWith(clearTransporterId: true);
      if (!_unassigned.contains(tid)) _unassigned.add(tid);
    });
    _scheduleDraftSave();
  }

  void _dropToPool(String transporterId) {
    setState(() {
      final fromIdx = _routes.indexWhere(
        (r) => r.transporterId == transporterId,
      );
      // Manuelle Einträge gehören nicht in den Fahrer-Pool — sie
      // verschwinden mitsamt ihrer Route (siehe _unassign).
      if (_isManualTid(transporterId)) {
        if (fromIdx != -1) _routes.removeAt(fromIdx);
        _manualNames.remove(transporterId);
        return;
      }
      if (fromIdx != -1) {
        _routes[fromIdx] = _routes[fromIdx].copyWith(clearTransporterId: true);
      }
      if (!_unassigned.contains(transporterId)) {
        _unassigned.add(transporterId);
      }
    });
    _scheduleDraftSave();
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final routes = _routesSorted();
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 1100;
    final isMobile = width < 700;

    final dispatcherBarWidget = StreamBuilder<List<String>>(
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
            if (_selectedDispatchers.length >= _maxDispatchers) return;
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
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
          child: StreamBuilder<Map<String, String>>(
            stream: _namesStream,
            builder: (context, snap) {
              // Merge live driver names with manually-typed names so every
              // downstream consumer resolves manual drivers too.
              final namesMap = <String, String>{
                ...(snap.data ?? const <String, String>{}),
                ..._manualNames,
              };
              _lastNamesMap = namesMap;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Date strip ───────────────────────────────────
                  WaveplanDateStrip(
                    selected: _selectedDate,
                    onSelect: _changeDate,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // ─── Shift plan banner ────────────────────────────
                  if (_shiftPlanDoc != null &&
                      _shiftPlanDoc!.entries.isNotEmpty) ...[
                    _ShiftPlanBanner(
                      driverCount: _shiftPlanDoc!.entries
                          .where((e) =>
                              e.transporterId.trim().isNotEmpty)
                          .length,
                      offsetMinutes:
                          _shiftPlanDoc!.parkingOffsetMinutes,
                      onShowAll: () => _openShiftPlanTimesDialog(
                        namesMap,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  // ─── Top row ─────────────────────────────────────
                  // Mobile: tabs + round "+" + compact Publish.
                  // Desktop: tabs + dispatcher bar side-by-side.
                  if (isMobile)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ProgramPicker(
                          activeKey: _activeProgram,
                          onTap: _showProgramPicker,
                        ),
                        const Spacer(),
                        _RoundPlusButton(
                          onTap: _showMobileActionsSheet,
                        ),
                        if (_routes.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.xs),
                          _RoundDangerButton(
                            icon: Icons.delete_outline_rounded,
                            onTap: _clearWaveplan,
                          ),
                        ],
                        const SizedBox(width: AppSpacing.xs),
                        _PublishButton(
                          isPublished: _isPublished,
                          publishedAt: _publishedAt,
                          onToggle: (_routes.isEmpty || !_atlasConfirmed) &&
                                  !_isPublished
                              ? null
                              : () => _togglePublish(namesMap),
                          compact: true,
                        ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ProgramTabs(
                          active: _activeProgram,
                          onSelect: _switchProgram,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: dispatcherBarWidget),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  // Full header with all action buttons only on desktop;
                  // on mobile they live behind the round "+" sheet.
                  if (!isMobile)
                    _Header(
                      programLabel: _programs.firstWhere(
                        (p) => p['key'] == _activeProgram,
                        orElse: () => _programs[0],
                      )['label']!,
                      onPaste: _showPasteDialog,
                      onAddDriver: () => _showManualDriverDialog(namesMap),
                      onEditEntries: () => _showManualEntriesSheet(namesMap),
                      onAtlasPaste: _showAtlasPasteDialog,
                      onNotesEdit: _showNotesDialog,
                      onClear: _routes.isEmpty ? null : _clearWaveplan,
                      onPublishToggle:
                          (_routes.isEmpty || !_atlasConfirmed) && !_isPublished
                              ? null
                              : () => _togglePublish(namesMap),
                      onPdf: _routes.isEmpty
                          ? null
                          : () => _generateWaveplanPdf(namesMap),
                      onShare: _routes.isEmpty
                          ? null
                          : () => _shareWaveplan(namesMap),
                      isPublished: _isPublished,
                      publishedAt: _publishedAt,
                      routeCount: _routes.length,
                      assignedCount:
                          _routes.where((r) => r.isAssigned).length,
                      atlasTotal: _atlasByRoute.values
                          .fold<int>(0, (s, l) => s + l.length),
                      atlasConfirmed: _atlasConfirmed,
                      notesLength: _generalNotes.trim().length,
                    ),
                  if (!isMobile) const SizedBox(height: AppSpacing.md),
                  // Driver search — filters the route list by assigned
                  // driver (name/TID), mentee or route code.
                  if (_routes.isNotEmpty) ...[
                    SizedBox(
                      // 44px on phones so the field is an easy touch target.
                      height: isMobile ? 44 : 40,
                      child: TextField(
                        focusNode: _driverSearchFocus,
                        onChanged: (v) =>
                            setState(() => _driverSearch = v),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 19,
                          ),
                          suffixIcon: _driverSearch.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 16,
                                      color: Color(0xFF9CA3AF)),
                                  splashRadius: 14,
                                  onPressed: () => setState(
                                      () => _driverSearch = ''),
                                ),
                          hintText: Localizations.localeOf(context)
                                      .languageCode ==
                                  'de'
                              ? 'Fahrer suchen (Name, TID oder Route) …'
                              : 'Search driver (name, TID or route) …',
                          hintStyle: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9CA3AF),
                          ),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFE5E5EA), width: 0.6),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFE5E5EA), width: 0.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF00B287), width: 1.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Expanded(
                    child: StreamBuilder<List<_PickableDriver>>(
                      stream: _activeDriversStreamSrc,
                      builder: (context, activeSnap) {
                        final activeDrivers = activeSnap.data ??
                            const <_PickableDriver>[];
                        final visibleRoutes =
                            _filterRoutesBySearch(routes, namesMap);
                        return isNarrow
                            ? _StackedLayout(
                                routes: visibleRoutes,
                                unassigned: _unassigned,
                                namesMap: namesMap,
                                anchorFor: _anchorFor,
                                atlasFor: (code) =>
                                    _atlasByRoute[code] ?? const [],
                                resolveName: (tid) =>
                                    _resolveName(namesMap, tid),
                                onAssign: _assignTo,
                                onUnassign: _unassign,
                                onDropToPool: _dropToPool,
                                onMenteeChange: _assignMentee,
                                onSpurChange: _cycleRouteSpur,
                                inWaveTids: _inWaveTids,
                                activeDrivers: activeDrivers,
                              )
                            : _SideBySideLayout(
                                routes: visibleRoutes,
                                unassigned: _unassigned,
                                namesMap: namesMap,
                                anchorFor: _anchorFor,
                                atlasFor: (code) =>
                                    _atlasByRoute[code] ?? const [],
                                resolveName: (tid) =>
                                    _resolveName(namesMap, tid),
                                onAssign: _assignTo,
                                onUnassign: _unassign,
                                onDropToPool: _dropToPool,
                                onMenteeChange: _assignMentee,
                                onSpurChange: _cycleRouteSpur,
                                inWaveTids: _inWaveTids,
                                activeDrivers: activeDrivers,
                              );
                      },
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
                      '…  ·  oder / or:\n'
                      'CA_A197   DE5638642195\n'
                      'CA_A202   DE5636853987',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(),
            label: t.t('waveplan_btn_cancel'),
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(_kAtlasNoneToday),
            label: t.t('waveplan_atlas_dialog_btn_none_today'),
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            label: t.t('waveplan_btn_import'),
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
      _scheduleDraftSave();
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
    _scheduleDraftSave();
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

  /// Parses pasted Atlas package data into `{ routeCode: [trackingId, …] }`
  /// (a route can carry multiple packages). Two shapes are recognised:
  ///
  ///   1. `DE… - CA_… [- A…]` — the classic dash-separated export
  ///      (tracking first, routeCode second; further columns ignored).
  ///   2. Tabular `Route <tab/spaces> Shipment ID` — as pasted from a sheet,
  ///      in either column order and with an optional header row. Any line
  ///      where a tour/route number sits next to a package number works,
  ///      regardless of which station's sheet it came from.
  ///
  /// The classic path is untouched; the tabular path is additive.
  Map<String, List<String>> _parseAtlasPaste(String input) {
    final out = <String, List<String>>{};

    // Normalised lookup of already-loaded route codes, so we can tell which
    // column is the route no matter the order / separator / station sheet.
    final routeByKey = <String, String>{};
    for (final r in _routes) {
      final code = r.routeCode.trim();
      if (code.isEmpty) continue;
      for (final k in _idKeys(code)) {
        routeByKey.putIfAbsent(k, () => code);
      }
    }
    String? routeFor(String token) {
      for (final k in _idKeys(token.trim())) {
        final hit = routeByKey[k];
        if (hit != null) return hit;
      }
      return null;
    }

    for (final raw in input.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      // ── 1) Classic format (unchanged): "tracking - routeCode [- …]" ──
      // A line containing " - " is always treated as classic format and
      // never reinterpreted by the tabular path below.
      final dashParts = line.split(RegExp(r'\s+-\s+'));
      if (dashParts.length >= 2) {
        final tracking = dashParts[0].trim();
        final routeCode = dashParts[1].trim();
        if (tracking.isNotEmpty && routeCode.isNotEmpty) {
          out.putIfAbsent(routeCode, () => []).add(tracking);
        }
        continue;
      }

      // ── 2) Tabular format: route + shipment side by side (any order) ──
      // Split on tab / 2+ spaces / ; / , first; fall back to any whitespace
      // so a single-space separated pair still works.
      var tokens = line
          .split(RegExp(r'\t+|\s{2,}|[;,]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (tokens.length < 2) {
        tokens = line
            .split(RegExp(r'\s+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (tokens.length < 2) continue;

      // Route: prefer a token that matches an already-loaded route.
      String? routeCode;
      String routeToken = '';
      for (final tk in tokens) {
        final hit = routeFor(tk);
        if (hit != null) {
          routeCode = hit;
          routeToken = tk;
          break;
        }
      }

      // Shipment: the package-number-looking token that isn't the route.
      String? shipment;
      for (final tk in tokens) {
        if (tk == routeToken) continue;
        if (_looksLikeAtlasShipment(tk)) {
          shipment = tk;
          break;
        }
      }

      // Route known but shipment pattern didn't match (unusual id shape) →
      // the neighbour of a known route is the package (must be alphanumeric).
      if (routeCode != null && shipment == null) {
        for (final tk in tokens) {
          if (tk != routeToken &&
              tk.length >= 3 &&
              RegExp(r'[0-9A-Za-z]').hasMatch(tk)) {
            shipment = tk;
            break;
          }
        }
      }

      // No known route matched → infer it as the plausible neighbour of the
      // shipment (routes not yet loaded / unknown station codes).
      if (routeCode == null && shipment != null) {
        for (final tk in tokens) {
          if (tk == shipment) continue;
          if (_plausibleRouteToken(tk)) {
            routeCode = tk;
            break;
          }
        }
      }

      if (routeCode != null && shipment != null && shipment.isNotEmpty) {
        out.putIfAbsent(routeCode, () => []).add(shipment);
      }
    }
    return out;
  }

  /// A package / shipment id: optional short letter prefix followed by a long
  /// run of digits (dashes allowed inside), e.g. `DE5638642195`, `7503578-169`.
  static bool _looksLikeAtlasShipment(String s) =>
      RegExp(r'^[A-Za-z]{0,4}[0-9][0-9-]{5,}$').hasMatch(s.trim());

  /// A plausible tour/route token: carries at least one digit (so header
  /// words like "Route" are excluded) and isn't itself a shipment id.
  static bool _plausibleRouteToken(String s) {
    final t = s.trim();
    if (t.length < 2 || t.length > 20) return false;
    if (!RegExp(r'[0-9]').hasMatch(t)) return false;
    return !_looksLikeAtlasShipment(t);
  }

  /// Sticky note that stays visible for a period of time (independent of
  /// day/program). Lives as a special doc inside `published_waveplans`,
  /// so the existing security rules (admin write / driver read) apply.
  DocumentReference<Map<String, dynamic>>? _stickyNoteRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('published_waveplans')
        .doc('sticky_note');
  }

  /// Notes editor for the active program. Each program (Sameday A,
  /// Nextday, Sameday C) carries its own notes line — switching tabs
  /// swaps the persisted draft. Below it: the time-limited sticky note.
  Future<void> _showNotesDialog() async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final controller = TextEditingController(text: _generalNotes);

    // Load the current sticky note (if any) before opening the dialog.
    final stickyRef = _stickyNoteRef();
    var stickyText = '';
    DateTime? stickyUntil;
    if (stickyRef != null) {
      try {
        final snap = await stickyRef.get();
        final data = snap.data();
        if (data != null) {
          stickyText = (data['text'] ?? '').toString();
          final ts = data['validUntil'];
          if (ts is Timestamp) stickyUntil = ts.toDate();
        }
      } catch (_) {}
    }
    if (!mounted) return;
    final stickyController = TextEditingController(text: stickyText);
    // 0 = bis Ende der Woche, 7/14 = Tage ab heute.
    var stickyPreset = 7;

    DateTime presetUntil(int preset) {
      final now = DateTime.now();
      if (preset == 0) {
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return DateTime(monday.year, monday.month, monday.day + 6, 23, 59, 59);
      }
      return DateTime(now.year, now.month, now.day + preset, 23, 59, 59);
    }

    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.${d.year}';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
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
            child: SingleChildScrollView(
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
                    minLines: 3,
                    maxLines: 8,
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
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Icon(
                        Icons.push_pin_rounded,
                        color: AppColors.codriverDeep,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        de ? 'Sticky Note (mehrtägig)' : 'Sticky note (multi-day)',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.codriverGraphite,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    de
                        ? 'Bleibt für den gewählten Zeitraum jeden Tag im '
                            'Waveplan sichtbar — unabhängig vom Tages-Plan. '
                            'Leer speichern entfernt sie.'
                        : 'Stays visible in the waveplan every day for the '
                            'selected period — independent of the daily plan. '
                            'Save empty to remove it.',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
                  ),
                  if (stickyUntil != null && stickyText.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      de
                          ? 'Aktuell gültig bis ${fmtDate(stickyUntil)}'
                          : 'Currently valid until ${fmtDate(stickyUntil)}',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: stickyController,
                    minLines: 2,
                    maxLines: 6,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: de
                          ? 'z. B. Ab Montag neue Parkplatz-Regelung …'
                          : 'e.g. New parking rules from Monday …',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (label, preset) in [
                        (de ? 'Diese Woche' : 'This week', 0),
                        (de ? '7 Tage' : '7 days', 7),
                        (de ? '14 Tage' : '14 days', 14),
                      ])
                        ChoiceChip(
                          label: Text(
                            '$label · ${de ? 'bis' : 'until'} '
                            '${fmtDate(presetUntil(preset))}',
                            style: AppTypography.footnote.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          selected: stickyPreset == preset,
                          onSelected: (_) =>
                              setLocal(() => stickyPreset = preset),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CoButton(
              onPressed: () => Navigator.of(ctx).pop(),
              label: t.t('waveplan_btn_cancel'),
              variant: CoButtonVariant.quiet,
            ),
            CoButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              label: t.t('waveplan_btn_save'),
            ),
          ],
        ),
      ),
    );
    if (result != true) return;

    // Daily note (unchanged behaviour).
    setState(() {
      _generalNotes = controller.text;
    });
    _scheduleDraftSave();

    // Sticky note: write / update / delete.
    final newSticky = stickyController.text.trim();
    if (stickyRef != null) {
      try {
        if (newSticky.isEmpty) {
          if (stickyText.trim().isNotEmpty) await stickyRef.delete();
        } else {
          final now = DateTime.now();
          await stickyRef.set({
            'text': newSticky,
            'validFrom':
                Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
            'validUntil': Timestamp.fromDate(presetUntil(stickyPreset)),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                de
                    ? 'Sticky Note konnte nicht gespeichert werden: $e'
                    : 'Could not save sticky note: $e',
              ),
            ),
          );
        }
      }
    }
  }

  /// Manually add a driver/route that is NOT in the Amazon waveplan
  /// (e.g. "infinities after sequence" where names aren't sent). The
  /// driver gets a synthetic transporter-ID so the rest of the app
  /// (list, PDF, share, driver app) treats it like any other route.
  Future<void> _showManualDriverDialog(
    Map<String, String> namesMap, {
    WaveplanRoute? existing,
  }) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final isEdit = existing != null;

    TimeOfDay? parseHhmm(String raw) {
      final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw.trim());
      if (m == null) return null;
      return TimeOfDay(
        hour: int.parse(m.group(1)!),
        minute: int.parse(m.group(2)!),
      );
    }

    final nameCtrl = TextEditingController(
      text: isEdit ? (_manualNames[existing.transporterId] ?? '') : '',
    );
    final routeCtrl =
        TextEditingController(text: isEdit ? existing.routeCode : '');
    final stagingCtrl =
        TextEditingController(text: isEdit ? existing.dispatchArea : '');
    final atlasCtrl = TextEditingController(
      text: isEdit
          ? (_atlasByRoute[existing.routeCode] ?? const <String>[]).join('\n')
          : '',
    );
    TimeOfDay? startTime = isEdit ? parseHhmm(existing.dispatchTime) : null;
    TimeOfDay? endTime = isEdit ? parseHhmm(existing.shiftEndTime) : null;
    String parkSide = isEdit ? existing.waitingAreaSpur : ''; // '', 'links', 'rechts'

    // Distinct, sorted driver names for the autocomplete suggestions.
    final suggestions = namesMap.values
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    String fmt(TimeOfDay? t) => t == null
        ? ''
        : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            InputDecoration dec(String label, {String? hint}) =>
                InputDecoration(
                  labelText: label,
                  hintText: hint,
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF111827)),
                  ),
                );

            Future<void> pickTime(bool isStart) async {
              final picked = await showTimePicker(
                context: ctx,
                initialTime: (isStart ? startTime : endTime) ??
                    const TimeOfDay(hour: 11, minute: 0),
              );
              if (picked != null) {
                setLocal(() {
                  if (isStart) {
                    startTime = picked;
                  } else {
                    endTime = picked;
                  }
                });
              }
            }

            Widget timeField(String label, TimeOfDay? value, bool isStart) {
              return InkWell(
                onTap: () => pickTime(isStart),
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: dec(label),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 16, color: Color(0xFF4B5563)),
                      const SizedBox(width: 6),
                      Text(
                        value == null
                            ? (de ? 'wählen' : 'pick')
                            : fmt(value),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: value == null
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget sideChip(String value, String label) {
              final selected = parkSide == value;
              return Expanded(
                child: InkWell(
                  onTap: () => setLocal(() => parkSide = value),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.codriverGreen.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.codriverGreen
                            : const Color(0xFFE5E7EB),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.codriverDeep
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_add_alt_1_rounded,
                                size: 20, color: AppColors.codriverDeep),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEdit
                                    ? (de
                                        ? 'Eintrag bearbeiten'
                                        : 'Edit entry')
                                    : (de
                                        ? 'Fahrer manuell hinzufügen'
                                        : 'Add driver manually'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(dialogCtx).pop(false),
                              icon: const Icon(Icons.close_rounded, size: 20),
                              splashRadius: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          de
                              ? 'Für Fahrer, die nicht im Amazon-Waveplan '
                                  'stehen (z. B. Infinities nach Sequence).'
                              : 'For drivers not included in the Amazon '
                                  'waveplan (e.g. infinities after sequence).',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Driver name with autocomplete over known names.
                        Autocomplete<String>(
                          optionsBuilder: (value) {
                            final q = value.text.trim().toLowerCase();
                            if (q.isEmpty) return const Iterable<String>.empty();
                            return suggestions.where(
                              (s) => s.toLowerCase().contains(q),
                            );
                          },
                          onSelected: (s) => nameCtrl.text = s,
                          fieldViewBuilder:
                              (ctx2, ctrl, focus, onSubmit) {
                            // Mirror into our own controller for saving.
                            ctrl.text = nameCtrl.text;
                            ctrl.selection = TextSelection.collapsed(
                                offset: ctrl.text.length);
                            return TextField(
                              controller: ctrl,
                              focusNode: focus,
                              autofocus: true,
                              onChanged: (v) => nameCtrl.text = v,
                              decoration: dec(
                                de ? 'Fahrername *' : 'Driver name *',
                                hint: de
                                    ? 'Name eingeben oder wählen'
                                    : 'Type or pick a name',
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: routeCtrl,
                          textCapitalization:
                              TextCapitalization.characters,
                          decoration: dec(
                            de ? 'Routennummer *' : 'Route number *',
                            hint: 'z. B. CA_A169',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          de
                              ? 'Zeit-Vorlagen (Startzeit)'
                              : 'Time templates (start)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tpl in const [
                              '06:30', '10:30', '11:00', '11:20', '12:30',
                              '12:50', '13:00', '17:30', '22:00',
                            ])
                              InkWell(
                                onTap: () {
                                  final parts = tpl.split(':');
                                  setLocal(() => startTime = TimeOfDay(
                                        hour: int.parse(parts[0]),
                                        minute: int.parse(parts[1]),
                                      ));
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: startTime != null &&
                                            fmt(startTime) == tpl
                                        ? AppColors.codriverGreen
                                            .withValues(alpha: 0.14)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: startTime != null &&
                                              fmt(startTime) == tpl
                                          ? AppColors.codriverGreen
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    tpl,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                      color: startTime != null &&
                                              fmt(startTime) == tpl
                                          ? AppColors.codriverDeep
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: timeField(
                                de ? 'Startzeit' : 'Start time',
                                startTime,
                                true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: timeField(
                                de ? 'Endzeit' : 'End time',
                                endTime,
                                false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          de ? 'Park-Seite' : 'Park-side',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            sideChip('links', de ? 'Links' : 'Left'),
                            const SizedBox(width: 8),
                            sideChip('rechts', de ? 'Rechts' : 'Right'),
                            const SizedBox(width: 8),
                            sideChip('', de ? 'Keine' : 'None'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: stagingCtrl,
                          decoration: dec(
                            de
                                ? 'Staging-Area (optional)'
                                : 'Staging area (optional)',
                            hint: de
                                ? 'leer lassen, wenn keine Info'
                                : 'leave empty if no info',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: atlasCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: dec(
                            de
                                ? 'ATLAS Tracking-IDs (optional)'
                                : 'ATLAS tracking IDs (optional)',
                            hint: de
                                ? 'IDs mit Komma/Leerzeichen/Zeile trennen'
                                : 'separate IDs by comma / space / line',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CoButton(
                              onPressed: () =>
                                  Navigator.of(dialogCtx).pop(false),
                              label: de ? 'Abbrechen' : 'Cancel',
                              variant: CoButtonVariant.secondaryOutlined,
                            ),
                            const SizedBox(width: 10),
                            CoButton(
                              onPressed: () {
                                if (nameCtrl.text.trim().isEmpty ||
                                    routeCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        de
                                            ? 'Bitte Fahrername und '
                                                'Routennummer angeben.'
                                            : 'Please enter driver name and '
                                                'route number.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(dialogCtx).pop(true);
                              },
                              icon: Icons.add_rounded,
                              label: isEdit
                                  ? (de ? 'Speichern' : 'Save')
                                  : (de ? 'Hinzufügen' : 'Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (saved != true) {
      nameCtrl.dispose();
      routeCtrl.dispose();
      stagingCtrl.dispose();
      atlasCtrl.dispose();
      return;
    }

    final name = nameCtrl.text.trim();
    final routeCode = routeCtrl.text.trim();
    final staging = stagingCtrl.text.trim();
    final atlasIds = atlasCtrl.text
        .split(RegExp(r'[\s,;]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    // Editing keeps the same synthetic id; adding mints a new one.
    final tid = isEdit
        ? existing.routeId
        : 'MANUAL-${DateTime.now().microsecondsSinceEpoch}';
    final oldRouteCode = isEdit ? existing.routeCode : '';

    String norm(TimeOfDay? t) => t == null ? '' : '${fmt(t)}:00';

    setState(() {
      _manualNames[tid] = name;
      final updated = WaveplanRoute(
        routeCode: routeCode,
        routeId: tid,
        dispatchArea: staging,
        waitingAreaSpur: parkSide,
        dispatchTime: norm(startTime),
        shiftEndTime: norm(endTime),
        serviceType: '',
        transporterId: tid,
      );
      if (isEdit) {
        _routes = _routes
            .map((r) => r.routeId == tid ? updated : r)
            .toList();
        // Route code may have changed → move its Atlas IDs.
        if (oldRouteCode.isNotEmpty && oldRouteCode != routeCode) {
          _atlasByRoute.remove(oldRouteCode);
        }
      } else {
        _routes = [..._routes, updated];
      }
      if (atlasIds.isNotEmpty) {
        _atlasByRoute[routeCode] = atlasIds;
        // A manual Atlas entry counts as an explicit atlas decision.
        _atlasConfirmed = true;
      } else if (isEdit) {
        _atlasByRoute.remove(routeCode);
      }
    });
    _scheduleDraftSave();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEdit
              ? (de
                  ? '$name ($routeCode) aktualisiert.'
                  : 'Updated $name ($routeCode).')
              : (de
                  ? '$name ($routeCode) hinzugefügt.'
                  : 'Added $name ($routeCode).'),
        ),
      ),
    );

    nameCtrl.dispose();
    routeCtrl.dispose();
    stagingCtrl.dispose();
    atlasCtrl.dispose();
  }

  /// Lists the manually-added entries so they can be edited or removed
  /// (feedback: "edit already added options").
  Future<void> _showManualEntriesSheet(Map<String, String> namesMap) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevatedLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        final manual =
            _routes.where((r) => _isManualTid(r.transporterId)).toList();
        // Routen ohne Fahrer: entstanden u. a. durch den früheren Fehler,
        // bei dem manuelle Einträge beim Entfernen des Fahrers ihre
        // Kennung verloren. Hier lassen sie sich aufräumen.
        final empty = _routes
            .where((r) => (r.transporterId ?? '').trim().isEmpty)
            .toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    top: 4,
                    bottom: 8,
                  ),
                  child: Text(
                    de
                        ? 'Manuelle Einträge bearbeiten'
                        : 'Edit manual entries',
                    style: AppTypography.headline.copyWith(
                      color: AppColors.codriverGraphite,
                    ),
                  ),
                ),
                if (manual.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      de
                          ? 'Keine manuell hinzugefügten Einträge.'
                          : 'No manually added entries.',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: manual.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final r = manual[i];
                        final name = _manualNames[r.transporterId] ?? '';
                        final sub = [
                          if (r.dispatchTime.isNotEmpty) _hhmm(r.dispatchTime),
                          if (r.waitingAreaSpur == 'links')
                            (de ? 'links' : 'left')
                          else if (r.waitingAreaSpur == 'rechts')
                            (de ? 'rechts' : 'right'),
                        ].join(' · ');
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.separatorLight.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${r.routeCode} · ${name.isEmpty ? '—' : name}',
                                      style: AppTypography.subheadline
                                          .copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.codriverGraphite,
                                      ),
                                    ),
                                    if (sub.isNotEmpty)
                                      Text(
                                        sub,
                                        style: AppTypography.caption1
                                            .copyWith(
                                          color: AppColors
                                              .labelSecondaryLight,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: de ? 'Bearbeiten' : 'Edit',
                                icon: const Icon(Icons.edit_rounded,
                                    size: 18, color: Color(0xFF2563EB)),
                                onPressed: () {
                                  Navigator.of(sheetCtx).pop();
                                  _showManualDriverDialog(
                                    namesMap,
                                    existing: r,
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: de ? 'Löschen' : 'Delete',
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 18, color: Color(0xFFDC2626)),
                                onPressed: () {
                                  setState(() {
                                    _routes = _routes
                                        .where((x) =>
                                            x.routeId != r.routeId)
                                        .toList();
                                    _manualNames.remove(r.transporterId);
                                    _atlasByRoute.remove(r.routeCode);
                                  });
                                  _scheduleDraftSave();
                                  Navigator.of(sheetCtx).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (empty.isNotEmpty) ...[
                  const Divider(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      de
                          ? 'Leere Routen (${empty.length})'
                          : 'Empty routes (${empty.length})',
                      style: AppTypography.footnote.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: empty.length,
                      itemBuilder: (ctx, i) {
                        final r = empty[i];
                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          leading: const Icon(Icons.link_off_rounded,
                              size: 18, color: Color(0xFF94A3B8)),
                          title: Text(
                            [
                              r.routeCode,
                              r.dispatchTime,
                            ].where((e) => e.trim().isNotEmpty).join('  ·  '),
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.codriverGraphite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            de ? 'Kein Fahrer zugewiesen' : 'No driver assigned',
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: de ? 'Route löschen' : 'Delete route',
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: Color(0xFFDC2626)),
                            onPressed: () {
                              setState(() {
                                _routes = _routes
                                    .where((x) => x.routeId != r.routeId)
                                    .toList();
                                _atlasByRoute.remove(r.routeCode);
                              });
                              _scheduleDraftSave();
                              Navigator.of(sheetCtx).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPasteDialog() async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
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
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(),
            label: t.t('waveplan_btn_cancel'),
            variant: CoButtonVariant.quiet,
          ),
          // Upload the wave as an XLSX table (e.g. TMGM export) instead
          // of pasting its content.
          CoButton(
            onPressed: () => Navigator.of(ctx).pop('__upload_xlsx__'),
            label: de ? 'XLSX hochladen' : 'Upload XLSX',
            icon: Icons.upload_file_rounded,
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            label: t.t('waveplan_btn_import'),
          ),
        ],
      ),
    );
    if (result == '__upload_xlsx__') {
      await _uploadWaveplanXlsx();
      return;
    }
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
    // Persist immediately — an imported wave must survive a reload even
    // before it is published.
    // ignore: discarded_futures
    _saveDraft();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t.tf('waveplan_snack_routes_imported', {'count': '${parsed.length}'}),
        ),
      ),
    );
  }

  /// Uploads a tabular waveplan XLSX (e.g. the TMGM export) and imports it
  /// through the same parser the paste path uses. Parsing happens fully
  /// client-side via the `excel` package — no server round-trip.
  Future<void> _uploadWaveplanXlsx() async {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final bytes = picked.files.first.bytes;
    if (bytes == null) return;

    String cellText(xls.Data? c) {
      final v = c?.value;
      if (v == null) return '';
      String p(int n) => n.toString().padLeft(2, '0');
      if (v is xls.TextCellValue) return v.value.text?.trim() ?? '';
      if (v is xls.TimeCellValue) {
        return '${p(v.hour)}:${p(v.minute)}:${p(v.second)}';
      }
      if (v is xls.DateTimeCellValue) {
        return '${p(v.hour)}:${p(v.minute)}:${p(v.second)}';
      }
      return v.toString().trim();
    }

    List<WaveplanRoute> parsed;
    try {
      final book = xls.Excel.decodeBytes(bytes);
      if (book.tables.isEmpty) {
        throw Exception('Keine Tabelle in der Datei gefunden.');
      }
      final sheet = book.tables.values.first;
      final buf = StringBuffer();
      for (final row in sheet.rows) {
        buf.writeln(row.map(cellText).join('\t'));
      }
      // Same autodetection as the paste path, so an XLSX in the newer
      // 5-column "ASSIGN DA" layout imports too.
      parsed = _parsePastedWaveplan(buf.toString());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'XLSX-Import fehlgeschlagen: $e' : 'XLSX import failed: $e',
          ),
        ),
      );
      return;
    }

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
      _waveAnchors.clear();
    });
    // Persist immediately, same as the paste path.
    // ignore: discarded_futures
    _saveDraft();
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
  /// list. Each route is 9 consecutive non-empty lines, in order:
  ///   1. dispatchTime              (`11:00:00` or `11:00:00 AM`)
  ///   2. shift end / driving until (same shape)
  ///   3. routeCode                 (e.g. `CA_A151`)
  ///   4. routeId                   (e.g. `7510683-151`)
  ///   5. dispatchArea              (e.g. `STG-B_RED.3`)
  ///   6. waiting area spur         (`rechts` / `links` / …)
  ///   7. ASSIGN DA                 (`<TID> / <DSP> / <TID>` or just `<TID>`)
  ///   8. Assigned DSP              (e.g. `AION`)
  ///   9. Service Type              (free text)
  ///
  /// The parser is tolerant to:
  ///   • header rows at the top of the paste (skipped by content match),
  ///   • 12-hour times with `AM`/`PM` suffix (normalised to 24h),
  ///   • blank lines (already stripped),
  ///   • partially-mangled chunks — uses time-anchors at lines i and i+1
  ///     to re-sync rather than blindly chunk by 9.
  List<WaveplanRoute> _parsePastedWaveplan(String input) {
    // Some stations export a TABULAR waveplan (e.g. TMGM): one route per
    // row with tab-separated columns
    //   WAVE ⇥ routeCode ⇥ Stage ⇥ DA NAME ⇥ DSP ⇥ Waiting Area
    // Try that first — rows without tabs fall through untouched, so the
    // classic line-per-field format below keeps working.
    // NEW Amazon dispatch export — 5 fields per route:
    //   dispatchTime ⇥ routeCode ⇥ DispatchArea ⇥ Waiting Area Spur ⇥ ASSIGN DA
    // Tried BEFORE the tabular parser: its rows also start with a time,
    // but column 4 carries the lane (`links`/`rechts`) instead of the DA
    // name, so the tabular parser would mis-read the TID.
    final assignDa = _parseAssignDaWaveplan(input);
    if (assignDa.isNotEmpty) return assignDa;

    final tabular = _parseTabularWaveplan(input);
    if (tabular.isNotEmpty) return tabular;

    // SD_A / SD_C column format (no time column), e.g.:
    //   SC_A10  42  A6SWFJP8GEQ2J  STG-A BLUE .10  :arrow_right: Right
    final sdColumns = _parseSdColumnWaveplan(input);
    if (sdColumns.isNotEmpty) return sdColumns;

    final raw = input
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Filter out known header tokens. Amazon's dispatch-list export
    // sometimes includes a header row above the data; without this
    // filter every subsequent chunk would be off-by-one.
    const headerTokens = <String>{
      'dispatchtime',
      'driving time until',
      'routecode',
      'routeid',
      'dispatcharea',
      'waiting area spur',
      'assign da',
      'assigned dsp',
      'service type',
    };
    final lines = raw
        .where((l) => !headerTokens.contains(l.toLowerCase()))
        .toList();

    // A time cell is `H:MM`, `H:MM:SS` optionally followed by AM/PM.
    final timeRe = RegExp(
      r'^\d{1,2}:\d{2}(?::\d{2})?\s*(AM|PM)?$',
      caseSensitive: false,
    );

    final out = <WaveplanRoute>[];
    var i = 0;
    while (i + 8 < lines.length) {
      // Anchor on two consecutive time-looking lines. If the chunk is
      // misaligned we skip one line and try again instead of dropping
      // 9 in a row.
      if (!timeRe.hasMatch(lines[i]) || !timeRe.hasMatch(lines[i + 1])) {
        i += 1;
        continue;
      }

      final dispatchTime = _normaliseClock(lines[i + 0]);
      final shiftEnd = _normaliseClock(lines[i + 1]);
      final routeCode = lines[i + 2];
      final routeId = lines[i + 3];
      final dispatchArea = lines[i + 4];
      final spurRaw = lines[i + 5].toLowerCase();
      final assignDa = lines[i + 6];
      final dsp = lines[i + 7];
      final serviceType = lines[i + 8];

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
      i += 9;
    }
    return out;
  }

  // ─── New Amazon "ASSIGN DA" export (5 fields per route) ───────────────

  /// Header labels of the new Amazon dispatch export. Used both to skip
  /// the header block and to recognise the format up front.
  static const _assignDaHeaderTokens = <String>{
    'dispatchtime',
    'routecode',
    'dispatcharea',
    'waiting area spur',
    'waitingareaspur',
    'assign da',
    'assignda',
  };

  /// `links` / `rechts` (and their English spellings) → the canonical
  /// lane value the editor, the public plan and the driver app expect.
  /// Returns `null` when [raw] isn't a lane token at all.
  static String? _normaliseSpur(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;
    if (s == 'links' || s == 'left' || s.contains('arrow_left')) return 'links';
    if (s == 'rechts' || s == 'right' || s.contains('arrow_right')) {
      return 'rechts';
    }
    return null;
  }

  /// Extracts the transporter ID from an `ASSIGN DA` cell shaped
  /// `<TID> / <DSP> / <TID>`. Tolerates a single value without slashes,
  /// identical or differing outer TIDs and stray whitespace. Returns
  /// `(tid, dsp)`; both may be `null`.
  static ({String? tid, String? dsp}) _splitAssignDa(String raw) {
    final parts = raw
        .split('/')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return (tid: null, dsp: null);
    // Amazon TIDs are long alphanumeric all-caps tokens; the DSP code in
    // the middle is a short abbreviation (AION, BOYO, …).
    final tidRe = RegExp(r'^[A-Z0-9]{8,}$');
    String? tid;
    for (final p in parts) {
      final up = p.toUpperCase();
      if (tidRe.hasMatch(up)) {
        tid = up;
        break;
      }
    }
    tid ??= parts.first.toUpperCase();
    if (tid.isEmpty) tid = null;
    String? dsp;
    for (final p in parts) {
      final up = p.toUpperCase();
      if (up != tid && up.isNotEmpty) {
        dsp = p.trim();
        break;
      }
    }
    return (tid: tid, dsp: dsp);
  }

  /// Parses the newer Amazon dispatch export with **5 fields per route**:
  ///   1. dispatchTime         (`11:00:00`)
  ///   2. routeCode            (`CA_A49`)
  ///   3. DispatchArea         (`STG-B.6` — letter = area, number = slot)
  ///   4. Waiting Area Spur    (`links` / `rechts`)
  ///   5. ASSIGN DA            (`<TID> / <DSP> / <TID>` or just `<TID>`)
  ///
  /// Both shapes of the same export are accepted:
  ///   • **column-wise** — one route per line, tab-separated,
  ///   • **line-wise** — 5 consecutive lines per route (how the values
  ///     arrive when copied straight out of the web tool).
  ///
  /// Tolerates a leading header block, blank lines and 12-hour times.
  /// Returns an empty list when the paste isn't this format, so the
  /// caller can fall through to the other parsers.
  List<WaveplanRoute> _parseAssignDaWaveplan(String input) {
    final timeRe = RegExp(
      r'^\d{1,2}:\d{2}(?::\d{2})?\s*(AM|PM)?$',
      caseSensitive: false,
    );

    WaveplanRoute build({
      required String time,
      required String routeCode,
      required String area,
      required String spur,
      required String assignDa,
    }) {
      final da = _splitAssignDa(assignDa);
      return WaveplanRoute(
        routeCode: routeCode,
        // This export carries no separate route ID — the route code is
        // unique within the day, so it doubles as the ID (same as TMGM).
        routeId: routeCode,
        dispatchArea: area,
        waitingAreaSpur: spur,
        dispatchTime: _normaliseClock(time),
        shiftEndTime: '',
        serviceType: '',
        transporterId: da.tid,
        assignedDsp: da.dsp,
      );
    }

    // ── 1) Column-wise (tab-separated) ─────────────────────────────────
    final rows = <WaveplanRoute>[];
    for (final line in input.split('\n')) {
      final cells = line.split('\t').map((c) => c.trim()).toList();
      if (cells.length < 4) continue;
      if (!timeRe.hasMatch(cells[0])) continue; // header / junk row
      if (cells[1].isEmpty) continue; // no route code
      final spur = _normaliseSpur(cells[3]);
      // The lane in column 4 is what separates this export from the
      // TMGM tabular one (which carries the DA name there).
      if (spur == null) continue;
      rows.add(
        build(
          time: cells[0],
          routeCode: cells[1],
          area: cells[2],
          spur: spur,
          assignDa: cells.length > 4 ? cells[4] : '',
        ),
      );
    }
    if (rows.isNotEmpty) return rows;

    // ── 2) Line-wise (5 lines per route) ───────────────────────────────
    final raw = input
        .split(RegExp(r'[\n\t]'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    // Only the two labels unique to THIS export count as positive
    // identification — `routeCode` alone also appears in the TMGM header.
    const distinctiveHeaders = <String>{
      'waiting area spur',
      'waitingareaspur',
      'assign da',
      'assignda',
    };
    var sawHeader = false;
    final lines = <String>[];
    for (final l in raw) {
      final key = l.toLowerCase();
      if (_assignDaHeaderTokens.contains(key)) {
        if (distinctiveHeaders.contains(key)) sawHeader = true;
        continue;
      }
      lines.add(l);
    }

    final out = <WaveplanRoute>[];
    var i = 0;
    while (i + 3 < lines.length) {
      // Anchor: a time followed by a NON-time line. The classic 9-field
      // export has two times in a row, so it can never match here.
      if (!timeRe.hasMatch(lines[i]) || timeRe.hasMatch(lines[i + 1])) {
        i += 1;
        continue;
      }
      final spur = _normaliseSpur(lines[i + 3]);
      if (spur != null) {
        // An unassigned route has no ASSIGN DA cell at all, so the next
        // line is already the following record's dispatch time — never
        // swallow it as a transporter ID.
        final daLine = i + 4 < lines.length ? lines[i + 4] : '';
        final hasDa = daLine.isNotEmpty && !timeRe.hasMatch(daLine);
        out.add(
          build(
            time: lines[i],
            routeCode: lines[i + 1],
            area: lines[i + 2],
            spur: spur,
            assignDa: hasDa ? daLine : '',
          ),
        );
        i += hasDa ? 5 : 4;
        continue;
      }
      // Lane column missing entirely — only accepted when the header
      // block positively identified this export, so we never steal a
      // paste that belongs to one of the other parsers.
      if (sawHeader && lines[i + 3].contains('/')) {
        out.add(
          build(
            time: lines[i],
            routeCode: lines[i + 1],
            area: lines[i + 2],
            spur: '',
            assignDa: lines[i + 3],
          ),
        );
        i += 4;
        continue;
      }
      i += 1;
    }
    return out;
  }

  /// Parses the tabular (TMGM-style) waveplan paste: one route per row,
  /// tab-separated columns in the order
  ///   1. WAVE          (`10:40:00`)
  ///   2. routeCode     (`CA_A8`)
  ///   3. Stage         (`STG-A10.1`)
  ///   4. DA NAME       (`<TID> / <DSP> / <TID>` or just `<TID>`)
  ///   5. DSP           (`BOYO`)
  ///   6. Waiting Area  (time, e.g. `10:25:00` — informational, skipped)
  ///
  /// Header rows and anything whose first cell isn't a time are ignored.
  /// Returns an empty list when the paste isn't tabular at all, so the
  /// caller can fall back to the classic line-per-field parser.
  List<WaveplanRoute> _parseTabularWaveplan(String input) {
    final timeRe = RegExp(
      r'^\d{1,2}:\d{2}(?::\d{2})?\s*(AM|PM)?$',
      caseSensitive: false,
    );
    final out = <WaveplanRoute>[];
    for (final line in input.split('\n')) {
      final cells = line.split('\t').map((c) => c.trim()).toList();
      if (cells.length < 4) continue; // not tabular / header / junk
      if (!timeRe.hasMatch(cells[0])) continue; // header row etc.
      final routeCode = cells[1];
      if (routeCode.isEmpty) continue;

      final assignDa = cells.length > 3 ? cells[3] : '';
      String? tid = assignDa.split('/').first.trim();
      if (tid.isEmpty) tid = null;
      final dsp = cells.length > 4 ? cells[4].trim() : '';

      out.add(
        WaveplanRoute(
          routeCode: routeCode,
          // TMGM has no separate route ID — the route code is unique
          // within the day, so it doubles as the ID.
          routeId: routeCode,
          dispatchArea: cells.length > 2 ? cells[2] : '',
          waitingAreaSpur: '',
          dispatchTime: _normaliseClock(cells[0]),
          shiftEndTime: '',
          serviceType: '',
          transporterId: tid,
          assignedDsp: dsp.isEmpty ? null : dsp,
        ),
      );
    }
    return out;
  }

  /// Parses the SD_A / SD_C column format (no time column). Columns are
  /// separated by tabs or runs of 2+ spaces:
  ///   routeCode  packages  transporterId  stagingArea  direction
  /// e.g. `SC_A10  42  A6SWFJP8GEQ2J  STG-A BLUE .10  :arrow_right: Right`
  /// Direction (`:arrow_right: Right` / `:arrow_left: Left`) maps to the
  /// waiting-area lane. Returns empty when the paste isn't this format so
  /// the caller can keep trying other parsers.
  List<WaveplanRoute> _parseSdColumnWaveplan(String input) {
    final timeRe = RegExp(r'^\d{1,2}:\d{2}');
    final tidRe = RegExp(r'^[A-Z0-9]{8,}$');
    final routeRe = RegExp(r'^[A-Za-z]{1,4}[_-]?[A-Za-z]?\d');
    final out = <WaveplanRoute>[];

    for (final line in input.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final cells = trimmed
          .split(RegExp(r'\t+|\s{2,}'))
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (cells.length < 3) continue;
      final routeCode = cells[0];
      if (timeRe.hasMatch(routeCode)) continue; // handled elsewhere
      if (!routeRe.hasMatch(routeCode)) continue; // header / junk row

      // Transporter-ID = first Amazon-style all-caps/alnum token after the
      // route code (skips the package count).
      String? tid;
      var tidIdx = -1;
      for (var i = 1; i < cells.length; i++) {
        if (tidRe.hasMatch(cells[i].toUpperCase()) &&
            !RegExp(r'^\d+$').hasMatch(cells[i])) {
          tid = cells[i].toUpperCase();
          tidIdx = i;
          break;
        }
      }

      // Direction / lane from any cell mentioning left/right (word or
      // :arrow_left:/:arrow_right: emoji shortcode).
      var spur = '';
      for (final c in cells) {
        final l = c.toLowerCase();
        if (l.contains('arrow_right') || l.contains('right')) {
          spur = 'rechts';
          break;
        }
        if (l.contains('arrow_left') || l.contains('left')) {
          spur = 'links';
          break;
        }
      }

      // Staging area = the cell(s) between the TID and the direction,
      // typically a single cell like "STG-A BLUE .10".
      var staging = '';
      if (tidIdx >= 0 && tidIdx + 1 < cells.length) {
        final next = cells[tidIdx + 1];
        final l = next.toLowerCase();
        if (!l.contains('arrow_') && !(l == 'left' || l == 'right')) {
          staging = next;
        }
      }

      out.add(
        WaveplanRoute(
          routeCode: routeCode,
          routeId: routeCode,
          dispatchArea: staging,
          waitingAreaSpur: spur,
          dispatchTime: '',
          shiftEndTime: '',
          serviceType: '',
          transporterId: tid,
        ),
      );
    }
    return out;
  }

  /// Normalise a clock string to `HH:MM:SS` 24h. Accepts `11:00`,
  /// `11:00:00`, `11:00 AM`, `11:00:00 AM`, `08:00 PM`, …
  static String _normaliseClock(String raw) {
    final s = raw.trim();
    final m = RegExp(
      r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(s);
    if (m == null) return s;
    var hh = int.tryParse(m.group(1) ?? '') ?? 0;
    final mm = m.group(2) ?? '00';
    final ss = m.group(3) ?? '00';
    final ampm = m.group(4)?.toUpperCase();
    if (ampm == 'PM' && hh < 12) hh += 12;
    if (ampm == 'AM' && hh == 12) hh = 0;
    return '${hh.toString().padLeft(2, '0')}:$mm:$ss';
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
    final d = _selectedDate;
    final date =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
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
        'menteeTransporterId': r.menteeTransporterId ?? '',
        'menteeName': _resolveName(namesMap, r.menteeTransporterId),
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
        'manualNames': _manualNames,
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

  // ────────────────────────────────────────────────────────────────
  //   PDF EXPORT + PUBLIC SHARE LINK
  // ────────────────────────────────────────────────────────────────

  /// "11:00:00" → "11:00"; keeps unparseable values verbatim.
  String _hhmm(String s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s.trim());
    if (m == null) return s.trim();
    return '${m.group(1)!.padLeft(2, '0')}:${m.group(2)}';
  }

  /// Routes grouped into waves by dispatch time, waves sorted by time,
  /// routes inside a wave by their dispatch slot.
  List<MapEntry<String, List<WaveplanRoute>>> _wavesSorted() {
    final groups = <String, List<WaveplanRoute>>{};
    for (final r in _routes) {
      groups.putIfAbsent(r.dispatchTime, () => []).add(r);
    }
    int mins(String s) {
      final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s.trim());
      if (m == null) return 99999;
      return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
    }

    final keys = groups.keys.toList()
      ..sort((a, b) => mins(a).compareTo(mins(b)));
    return [
      for (final k in keys)
        MapEntry(
          k,
          groups[k]!..sort((a, b) => a.dispatchSlot.compareTo(b.dispatchSlot)),
        ),
    ];
  }

  String _pdfDateLabel(DateTime d) {
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    String p(int n) => n.toString().padLeft(2, '0');
    return '${wd[d.weekday - 1]}, ${p(d.day)}.${p(d.month)}.${d.year}';
  }

  /// Compact, branded waveplan PDF: one section per wave with route rows
  /// (driver, area, lane, shift end) and the Atlas tracking IDs listed
  /// beneath the affected routes.
  Future<void> _generateWaveplanPdf(Map<String, String> namesMap) async {
    if (_routes.isEmpty) return;
    final programLabel = _programs.firstWhere(
      (p) => p['key'] == _activeProgram,
      orElse: () => _programs[0],
    )['label']!;
    final brandDeep = PdfColor.fromInt(0xFF006047);
    final brandGreen = PdfColor.fromInt(0xFF00B287);
    final zebra = PdfColor.fromInt(0xFFF3F4F6);
    final atlasTotal =
        _atlasByRoute.values.fold<int>(0, (s, l) => s + l.length);

    pw.Widget cell(String txt, {bool bold = false, double size = 8.5}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
          child: pw.Text(
            txt,
            style: pw.TextStyle(
              fontSize: size,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) {
          final w = <pw.Widget>[
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 5,
                  height: 20,
                  margin: const pw.EdgeInsets.only(right: 8),
                  color: brandGreen,
                ),
                pw.Text('Waveplan',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: brandDeep)),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              [
                programLabel,
                _pdfDateLabel(_selectedDate),
                '${_routes.length} Routes',
                if (atlasTotal > 0) '$atlasTotal Atlas',
              ].join('  |  '),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ];
          if (_generalNotes.trim().isNotEmpty) {
            w.add(pw.SizedBox(height: 8));
            w.add(pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFFFF7ED),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(_generalNotes.trim(),
                  style: pw.TextStyle(
                      fontSize: 8.5, color: PdfColor.fromInt(0xFF92400E))),
            ));
          }
          for (final wave in _wavesSorted()) {
            final routes = wave.value;
            w.add(pw.SizedBox(height: 10));
            w.add(pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: pw.BoxDecoration(
                color: brandDeep,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Text(
                'Wave ${_hhmm(wave.key)}  |  ${routes.length} Routes',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white),
              ),
            ));
            w.add(pw.SizedBox(height: 3));
            w.add(pw.Table(
              border:
                  pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.3),
                1: const pw.FlexColumnWidth(2.2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(0.8),
                4: const pw.FlexColumnWidth(0.7),
                5: const pw.FlexColumnWidth(2.8),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: zebra),
                  children: [
                    cell('Route', bold: true, size: 8),
                    cell('Driver', bold: true, size: 8),
                    cell('Area', bold: true, size: 8),
                    cell('Lane', bold: true, size: 8),
                    cell('End', bold: true, size: 8),
                    cell('Atlas', bold: true, size: 8),
                  ],
                ),
                for (var i = 0; i < routes.length; i++)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isOdd ? zebra : PdfColors.white,
                    ),
                    children: [
                      cell(routes[i].routeCode, bold: true),
                      cell(() {
                        final name =
                            _resolveName(namesMap, routes[i].transporterId);
                        final mentee = _resolveName(
                            namesMap, routes[i].menteeTransporterId);
                        if (name.isEmpty) return '-';
                        return mentee.isEmpty ? name : '$name + $mentee';
                      }()),
                      cell(routes[i].dispatchArea),
                      cell(routes[i].waitingAreaSpur),
                      cell(_hhmm(routes[i].shiftEndTime)),
                      // Atlas: count + tracking numbers, highlighted yellow.
                      () {
                        final ids = _atlasByRoute[routes[i].routeCode] ??
                            const <String>[];
                        if (ids.isEmpty) return cell('');
                        return pw.Container(
                          color: PdfColor.fromInt(0xFFFDE047), // yellow
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 5, vertical: 3.5),
                          child: pw.Text(
                            '${ids.length}: ${ids.join(', ')}',
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        );
                      }(),
                    ],
                  ),
              ],
            ));
          }

          // ── Atlas driver list: ONLY drivers carrying Atlas packages ──
          final atlasDrivers = <List<String>>[
            for (final wave in _wavesSorted())
              for (final r in wave.value)
                if ((_atlasByRoute[r.routeCode] ?? const []).isNotEmpty)
                  [
                    () {
                      final name = _resolveName(namesMap, r.transporterId);
                      return name.isEmpty ? 'unassigned' : name;
                    }(),
                    r.routeCode,
                    'Wave ${_hhmm(wave.key)}',
                    (_atlasByRoute[r.routeCode] ?? const []).join(', '),
                  ],
          ];
          if (atlasDrivers.isNotEmpty) {
            w.add(pw.SizedBox(height: 14));
            w.add(pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFFDE047),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Text(
                'Atlas drivers (${atlasDrivers.length})',
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ));
            w.add(pw.SizedBox(height: 3));
            w.add(pw.Table(
              border:
                  pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.0),
                1: const pw.FlexColumnWidth(1.1),
                2: const pw.FlexColumnWidth(1.1),
                3: const pw.FlexColumnWidth(4.0),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: zebra),
                  children: [
                    cell('Driver', bold: true, size: 8),
                    cell('Route', bold: true, size: 8),
                    cell('Wave', bold: true, size: 8),
                    cell('Atlas packages', bold: true, size: 8),
                  ],
                ),
                for (var i = 0; i < atlasDrivers.length; i++)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isOdd
                          ? PdfColor.fromInt(0xFFFEF9C3) // light yellow
                          : PdfColors.white,
                    ),
                    children: [
                      cell(atlasDrivers[i][0], bold: true),
                      cell(atlasDrivers[i][1]),
                      cell(atlasDrivers[i][2]),
                      cell(atlasDrivers[i][3], size: 7),
                    ],
                  ),
              ],
            ));
          }
          return w;
        },
      ),
    );
    await Printing.layoutPdf(
      name: 'Waveplan_${_dateKeyOf(_selectedDate)}_$_activeProgram.pdf',
      onLayout: (format) async => doc.save(),
    );
  }

  /// Publishes a read-only snapshot under an unguessable public link
  /// (viewable without login) and shows the copy dialog.
  Future<void> _shareWaveplan(Map<String, String> namesMap) async {
    if (_routes.isEmpty) return;
    final programLabel = _programs.firstWhere(
      (p) => p['key'] == _activeProgram,
      orElse: () => _programs[0],
    )['label']!;
    final dateKey = _dateKeyOf(_selectedDate);

    final sections = <Map<String, dynamic>>[
      for (final wave in _wavesSorted())
        {
          'title': 'Wave ${_hhmm(wave.key)} · ${wave.value.length} routes',
          'rows': [
            for (final r in wave.value)
              {
                'primary': () {
                  final name = _resolveName(namesMap, r.transporterId);
                  final mentee =
                      _resolveName(namesMap, r.menteeTransporterId);
                  final who = name.isEmpty
                      ? '—'
                      : (mentee.isEmpty ? name : '$name + $mentee');
                  return '${r.routeCode} · $who';
                }(),
                'secondary': [
                  // Start–end time so the public viewer shows both, not just
                  // the wave header time.
                  if (r.dispatchTime.trim().isNotEmpty &&
                      r.shiftEndTime.trim().isNotEmpty)
                    '${_hhmm(r.dispatchTime)} – ${_hhmm(r.shiftEndTime)}'
                  else if (r.dispatchTime.trim().isNotEmpty)
                    'from ${_hhmm(r.dispatchTime)}'
                  else if (r.shiftEndTime.trim().isNotEmpty)
                    'until ${_hhmm(r.shiftEndTime)}',
                  if (r.dispatchArea.trim().isNotEmpty) r.dispatchArea,
                ].join(' · '),
                // Lane shown as its own green pill in the public viewer.
                if (r.waitingAreaSpur.trim().isNotEmpty)
                  'pills': <String>[
                    r.waitingAreaSpur.toLowerCase() == 'links'
                        ? 'Lane left'
                        : r.waitingAreaSpur.toLowerCase() == 'rechts'
                            ? 'Lane right'
                            : 'Lane ${r.waitingAreaSpur}',
                  ],
                if ((_atlasByRoute[r.routeCode] ?? const []).isNotEmpty) ...{
                  'badge':
                      '${(_atlasByRoute[r.routeCode] ?? const []).length} Atlas',
                  'badgeItems': _atlasByRoute[r.routeCode],
                },
              },
          ],
        },
    ];

    try {
      // Ticket: Sticky Note und diensthabende Dispatcher fehlten im
      // geteilten Link — beide gehören zum Tagesbild und werden daher
      // mitgeschickt.
      var stickyText = '';
      final stickyRef = _stickyNoteRef();
      if (stickyRef != null) {
        try {
          final snap = await stickyRef.get();
          final data = snap.data();
          if (data != null) {
            final text = (data['text'] ?? '').toString().trim();
            final vu = data['validUntil'];
            final vf = data['validFrom'];
            final now = DateTime.now();
            final started = vf is! Timestamp || !now.isBefore(vf.toDate());
            final running = vu is! Timestamp || !now.isAfter(vu.toDate());
            if (text.isNotEmpty && started && running) stickyText = text;
          }
        } catch (_) {}
      }

      final dispatcherPayload = [
        for (final name in _selectedDispatchers)
          {
            'name': name,
            'time': [
              _shiftByDispatcher[name]?.start ?? '',
              _shiftByDispatcher[name]?.end ?? '',
            ].where((e) => e.trim().isNotEmpty).join(' - '),
            'phone': '',
          },
      ];

      final url = await PublicPlanService().share(
        key: 'waveplan_${dateKey}_$_activeProgram',
        payload: {
          'type': 'waveplan',
          'title': 'Waveplan',
          'subtitle': programLabel,
          'date': _pdfDateLabel(_selectedDate),
          'company': '',
          'station': '',
          'notes': _generalNotes.trim(),
          'stickyNote': stickyText,
          'dispatchers': dispatcherPayload,
          'sections': sections,
        },
      );
      if (!mounted) return;
      await showShareLinkDialog(context, url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'de'
                ? 'Link erstellen fehlgeschlagen: $e'
                : 'Could not create link: $e',
          ),
        ),
      );
    }
  }

  /// Popover program picker anchored to the trigger button — opens
  /// just below the [_ProgramPicker] pill instead of sliding up from
  /// the bottom of the screen.
  Future<void> _showProgramPicker(BuildContext triggerCtx) async {
    final button = triggerCtx.findRenderObject() as RenderBox?;
    final overlayState = Navigator.of(triggerCtx).overlay;
    final overlay = overlayState?.context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.bottomLeft(Offset.zero) + const Offset(0, 6),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero) + const Offset(0, 6),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final picked = await showMenu<String>(
      context: triggerCtx,
      position: position,
      color: AppColors.surfaceElevatedLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      items: [
        for (final p in _programs)
          PopupMenuItem<String>(
            value: p['key'],
            height: 40,
            child: Row(
              children: [
                Icon(
                  p['key'] == _activeProgram
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 16,
                  color: p['key'] == _activeProgram
                      ? AppColors.codriverGreen
                      : AppColors.labelTertiaryLight,
                ),
                const SizedBox(width: 10),
                Text(
                  p['label']!,
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: p['key'] == _activeProgram
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    if (picked != null && picked != _activeProgram) {
      _switchProgram(picked);
    }
  }

  /// Mobile action menu — replaces the inline header buttons. Each
  /// row in the sheet maps to one of the existing dialogs/flows.
  Future<void> _showMobileActionsSheet() async {
    final t = AppLocalizations.of(context);
    final hasRoutes = _routes.isNotEmpty;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevatedLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        Widget tile({
          required IconData icon,
          required Color iconBg,
          required Color iconFg,
          required String label,
          required VoidCallback? onTap,
        }) {
          final disabled = onTap == null;
          return ListTile(
            enabled: !disabled,
            onTap: disabled
                ? null
                : () {
                    Navigator.of(sheetCtx).pop();
                    onTap();
                  },
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: disabled ? AppColors.surfaceLight : iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: disabled
                    ? AppColors.labelTertiaryLight
                    : iconFg,
              ),
            ),
            title: Text(
              label,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: disabled
                    ? AppColors.labelTertiaryLight
                    : AppColors.codriverGraphite,
              ),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.separatorLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                tile(
                  icon: Icons.content_paste_rounded,
                  iconBg: AppColors.green50,
                  iconFg: AppColors.codriverDeep,
                  label: t.t('waveplan_btn_paste_wave'),
                  onTap: _showPasteDialog,
                ),
                tile(
                  icon: Icons.person_add_alt_1_rounded,
                  iconBg: AppColors.green50,
                  iconFg: AppColors.codriverDeep,
                  label: Localizations.localeOf(context).languageCode == 'de'
                      ? 'Fahrer manuell hinzufügen'
                      : 'Add driver manually',
                  onTap: () => _showManualDriverDialog(_lastNamesMap),
                ),
                tile(
                  icon: Icons.edit_note_rounded,
                  iconBg: AppColors.green50,
                  iconFg: AppColors.codriverDeep,
                  label: Localizations.localeOf(context).languageCode == 'de'
                      ? 'Manuelle Einträge bearbeiten'
                      : 'Edit manual entries',
                  onTap: () => _showManualEntriesSheet(_lastNamesMap),
                ),
                tile(
                  icon: Icons.headset_mic_rounded,
                  iconBg: const Color(0xFFE8F1FF),
                  iconFg: const Color(0xFF0A84FF),
                  label: t.t('waveplan_dispatcher_label'),
                  onTap: () => _showDispatcherSheet(),
                ),
                tile(
                  icon: Icons.inventory_2_rounded,
                  iconBg: const Color(0xFFFFF4E5),
                  iconFg: AppColors.warning,
                  label: t.t('waveplan_btn_atlas'),
                  onTap: _showAtlasPasteDialog,
                ),
                tile(
                  icon: Icons.edit_note_rounded,
                  iconBg: AppColors.surfaceLight,
                  iconFg: AppColors.codriverDeep,
                  label: t.t('waveplan_btn_notes'),
                  onTap: _showNotesDialog,
                ),
                // PDF + share link — on desktop these live in the header
                // bar; on mobile they are only reachable via this sheet.
                tile(
                  icon: Icons.picture_as_pdf_outlined,
                  iconBg: AppColors.surfaceLight,
                  iconFg: AppColors.codriverDeep,
                  label: Localizations.localeOf(context).languageCode == 'de'
                      ? 'PDF exportieren'
                      : 'Export PDF',
                  onTap: hasRoutes
                      ? () => _generateWaveplanPdf(_lastNamesMap)
                      : null,
                ),
                tile(
                  icon: Icons.link_rounded,
                  iconBg: AppColors.surfaceLight,
                  iconFg: AppColors.codriverDeep,
                  label: Localizations.localeOf(context).languageCode == 'de'
                      ? 'Link teilen'
                      : 'Share link',
                  onTap: hasRoutes
                      ? () => _shareWaveplan(_lastNamesMap)
                      : null,
                ),
                if (hasRoutes)
                  tile(
                    icon: Icons.delete_outline_rounded,
                    iconBg: const Color(0xFFFDECEC),
                    iconFg: AppColors.error,
                    label: t.t('waveplan_btn_clear'),
                    onTap: _clearWaveplan,
                  ),
                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bottom-sheet wrapper around the dispatcher bar — used on mobile
  /// where the bar can't share the row with the program tabs.
  Future<void> _showDispatcherSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevatedLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              MediaQuery.of(sheetCtx).viewInsets.bottom + AppSpacing.lg,
            ),
            child: StatefulBuilder(
              builder: (ctx, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.separatorLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    StreamBuilder<List<String>>(
                      stream: _dispatcherNamesStream,
                      builder: (ctx2, snap) {
                        final available =
                            snap.data ?? const <String>[];
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
                              _shiftByDispatcher[name] =
                                  _defaultShiftFor(
                                _selectedDispatchers.length - 1,
                              );
                            });
                            setSheetState(() {});
                          },
                          onRemoveDispatcher: (name) {
                            setState(() {
                              _selectedDispatchers.remove(name);
                              _shiftByDispatcher.remove(name);
                            });
                            setSheetState(() {});
                          },
                          onShiftChanged: (name, range) {
                            setState(() {
                              _shiftByDispatcher[name] = range;
                            });
                            setSheetState(() {});
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
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
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: t.t('waveplan_btn_cancel'),
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: t.t('waveplan_btn_clear'),
            variant: CoButtonVariant.destructive,
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
      _manualNames.clear();
      _atlasConfirmed = false;
      _selectedDispatchers.clear();
      _shiftByDispatcher.clear();
      _generalNotes = '';
      _isPublished = false;
      _publishedAt = null;
    });
    // Clearing the wave also removes its internal draft.
    // ignore: discarded_futures
    _saveDraft();
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
  final void Function(String routeId, String? menteeTid) onMenteeChange;
  final void Function(String routeId) onSpurChange;
  final Set<String> inWaveTids;
  final List<_PickableDriver> activeDrivers;

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
    required this.onMenteeChange,
    required this.onSpurChange,
    required this.inWaveTids,
    this.activeDrivers = const <_PickableDriver>[],
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
            onMenteeChange: onMenteeChange,
            onSpurChange: onSpurChange,
            namesMap: namesMap,
            inWaveTids: inWaveTids,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 280,
          child: _UnassignedPool(
            transporterIds: unassigned,
            resolveName: resolveName,
            onDropToPool: onDropToPool,
            activeDrivers: activeDrivers,
            inWaveTids: inWaveTids,
            routes: routes,
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
  final void Function(String routeId, String? menteeTid) onMenteeChange;
  final void Function(String routeId) onSpurChange;
  final Set<String> inWaveTids;
  final List<_PickableDriver> activeDrivers;

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
    required this.onMenteeChange,
    required this.onSpurChange,
    required this.inWaveTids,
    this.activeDrivers = const <_PickableDriver>[],
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
            activeDrivers: activeDrivers,
            inWaveTids: inWaveTids,
            routes: routes,
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
            onMenteeChange: onMenteeChange,
            onSpurChange: onSpurChange,
            namesMap: namesMap,
            inWaveTids: inWaveTids,
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
  final VoidCallback onAddDriver;
  final VoidCallback onEditEntries;
  final VoidCallback onAtlasPaste;
  final VoidCallback onNotesEdit;
  final VoidCallback? onClear;
  final VoidCallback? onPublishToggle;
  final VoidCallback? onPdf;
  final VoidCallback? onShare;
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
    required this.onAddDriver,
    required this.onEditEntries,
    required this.onAtlasPaste,
    required this.onNotesEdit,
    required this.onClear,
    required this.onPublishToggle,
    this.onPdf,
    this.onShare,
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
          icon: Icons.person_add_alt_1_rounded,
          label: Localizations.localeOf(context).languageCode == 'de'
              ? 'Fahrer hinzufügen'
              : 'Add driver',
          onTap: onAddDriver,
          accent: AppColors.codriverDeep,
        ),
        _SmallActionButton(
          icon: Icons.edit_note_rounded,
          label: Localizations.localeOf(context).languageCode == 'de'
              ? 'Einträge bearbeiten'
              : 'Edit entries',
          onTap: onEditEntries,
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
        if (onPdf != null)
          _SmallActionButton(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF',
            onTap: onPdf,
          ),
        if (onShare != null)
          _SmallActionButton(
            icon: Icons.link_rounded,
            label: 'Link',
            onTap: onShare,
          ),
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
  /// Compact mode for mobile: drops the icon/pulse dot, shrinks padding,
  /// and uses a one-word label ("Publish" / "Live").
  final bool compact;
  const _PublishButton({
    required this.isPublished,
    required this.publishedAt,
    required this.onToggle,
    this.compact = false,
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

    final compact = widget.compact;
    final label = compact
        ? (published ? 'Live' : 'Publish')
        : (published
            ? loc.tf('waveplan_published_label', {'time': _timeLabel()})
            : loc.t('waveplan_publish_label'));

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
          // Compact (= mobile) keeps a >=44px touch target.
          height: compact ? 44 : 42,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.md : AppSpacing.lg,
          ),
          constraints: BoxConstraints(
            minWidth: compact ? 0 : (published ? 250 : 220),
          ),
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
              if (!compact) ...[
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
                              color:
                                  Colors.white.withOpacity(0.35 + 0.4 * t),
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
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  label,
                  key: ValueKey('$published-$compact'),
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
/// Round "+" pill used in the mobile header — taps open the bottom
/// sheet that holds the wave/dispatcher/atlas/notes/clear actions.
class _RoundPlusButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RoundPlusButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        child: Container(
          // 44px — comfortable touch target on phones (mobile-only widget).
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.codriverGreen,
            shape: BoxShape.circle,
            boxShadow: AppElevation.level1,
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Compact round red-tinted button — used inline next to the `+` on
/// the mobile waveplan header to clear the imported routes. Only
/// shown when there's actually something to delete.
class _RoundDangerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundDangerButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: onTap,
        child: Container(
          // 44px — comfortable touch target on phones (mobile-only widget).
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            shape: BoxShape.circle,
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: AppColors.error.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.error),
        ),
      ),
    );
  }
}

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
/// Mobile replacement for the desktop tab bar. Renders the active
/// program as a content-sized pill with a chevron — tapping it opens
/// the program picker popup right below the button (not a bottom
/// sheet, which would be far from the tap on a tall phone). Title
/// stays in sync with the selection.
class _ProgramPicker extends StatelessWidget {
  final String activeKey;
  final ValueChanged<BuildContext> onTap;
  const _ProgramPicker({required this.activeKey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = _programs.firstWhere(
      (p) => p['key'] == activeKey,
      orElse: () => _programs[0],
    )['label']!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(context),
        child: Container(
          // Mobile-only pill — 44px for a comfortable touch target.
          height: 44,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.codriverGraphite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.codriverDeep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  final void Function(String routeId, String? menteeTid) onMenteeChange;
  final void Function(String routeId) onSpurChange;
  final Map<String, String> namesMap;
  final Set<String> inWaveTids;

  const _RouteList({
    required this.routes,
    required this.anchorFor,
    required this.atlasFor,
    required this.resolveName,
    required this.onAssign,
    required this.onUnassign,
    required this.onMenteeChange,
    required this.onSpurChange,
    required this.namesMap,
    required this.inWaveTids,
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
          onMenteeChange: (mTid) =>
              onMenteeChange(routeItem.route.routeId, mTid),
          onSpurChange: () => onSpurChange(routeItem.route.routeId),
          namesMap: namesMap,
          inWaveTids: inWaveTids,
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
      child: CoPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
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
              // Ellipsis instead of overflowing narrow (mobile) rows.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w600,
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
    // Wrap instead of Row: on narrow (mobile bottom-sheet) widths the
    // time dropdowns flow onto the next line instead of overflowing.
    return Wrap(
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Selected pill — name + inline X. Clicking the X (or the
        // whole pill) removes the dispatcher from the selection.
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: CoPressable(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
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
                  // Cap the name so pill + time dropdowns never exceed a
                  // narrow (mobile bottom-sheet) row width.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.footnote.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
          'Wave ${_shortClock(wave)}',
          style: AppTypography.title3.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.codriverGraphite,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            t.tf('waveplan_wave_routes_count', {'count': '$count'}),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
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
  final ValueChanged<String?> onMenteeChange;
  final VoidCallback onSpurChange;
  final Map<String, String> namesMap;
  final Set<String> inWaveTids;
  final bool isAlternate;

  const _RouteCard({
    required this.route,
    required this.atlasTrackingIds,
    required this.resolveName,
    required this.onAssign,
    required this.onUnassign,
    required this.onMenteeChange,
    required this.onSpurChange,
    required this.namesMap,
    required this.inWaveTids,
    required this.isAlternate,
  });

  bool _isLeft() => route.waitingAreaSpur.toLowerCase() == 'links';
  bool _hasSpur() => route.waitingAreaSpur.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final left = _isLeft();
    final hasSpur = _hasSpur();
    final spurColor = !hasSpur
        ? const Color(0xFF9CA3AF) // neutral grey — lane not set yet
        : left
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              final driverName = resolveName(route.transporterId);
              return Row(
                children: [
                  // Driver chip first — most important info on the
                  // left. Fixed 260px on desktop; flexible on mobile
                  // so long names ellipsis instead of pushing the
                  // route metadata off-screen.
                  if (isCompact)
                    Expanded(
                      flex: 4,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: route.isAssigned
                            ? _DriverChip(
                                transporterId: route.transporterId!,
                                driverName: driverName,
                                dsp: route.assignedDsp,
                                menteeTransporterId:
                                    route.menteeTransporterId,
                                menteeName: route.hasMentee
                                    ? resolveName(route.menteeTransporterId)
                                    : '',
                                onRemove: onUnassign,
                                onMenteeChange: onMenteeChange,
                                onReplaceDriver: onAssign,
                                namesMap: namesMap,
                                inWaveTids: inWaveTids,
                                compact: true,
                              )
                            : _EmptyDropZone(active: hovered),
                      ),
                    )
                  else
                    SizedBox(
                      width: 260,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: route.isAssigned
                            ? _DriverChip(
                                transporterId: route.transporterId!,
                                driverName: driverName,
                                dsp: route.assignedDsp,
                                menteeTransporterId:
                                    route.menteeTransporterId,
                                menteeName: route.hasMentee
                                    ? resolveName(route.menteeTransporterId)
                                    : '',
                                onRemove: onUnassign,
                                onMenteeChange: onMenteeChange,
                                onReplaceDriver: onAssign,
                                namesMap: namesMap,
                                inWaveTids: inWaveTids,
                              )
                            : _EmptyDropZone(active: hovered),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  _SpurIndicator(
                    left: left,
                    color: spurColor,
                    hasSpur: hasSpur,
                    onTap: onSpurChange,
                    expandTouchTarget: isCompact,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Route metadata — compact, one column. Atlas chip
                  // is placed BEFORE the route code so the parcel
                  // indicator is the first thing the dispatcher
                  // scans for.
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (atlasTrackingIds.isNotEmpty) ...[
                              _AtlasBadge(
                                count: atlasTrackingIds.length,
                                trackingIds: atlasTrackingIds,
                                driverName: driverName,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                route.routeCode,
                                style:
                                    AppTypography.subheadline.copyWith(
                                  color: AppColors.codriverGraphite,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
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
                                  style:
                                      AppTypography.caption2.copyWith(
                                    color: spurColor,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          () {
                            // TMGM imports carry no service type / shift
                            // end — build the line only from what exists.
                            final parts = <String>[
                              if (route.serviceType.trim().isNotEmpty)
                                _normalizeServiceType(route.serviceType),
                              route.shiftEndTime.trim().isEmpty
                                  ? _shortClock(route.dispatchTime)
                                  : '${_shortClock(route.dispatchTime)}–'
                                      '${_shortClock(route.shiftEndTime)}',
                            ];
                            return parts.join('  ·  ');
                          }(),
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
              );
            },
          ),
        );
      },
    );
  }
}

/// Small attention-grabbing pill on a route card when one or more
/// Atlas packages are routed to that driver. Tap opens a popup with
/// the numbered tracking-IDs so the dispatcher can verify on the fly.
class _AtlasBadge extends StatelessWidget {
  final int count;
  final List<String> trackingIds;
  final String driverName;
  const _AtlasBadge({
    required this.count,
    this.trackingIds = const [],
    this.driverName = '',
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final chip = Container(
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

    if (trackingIds.isEmpty) return chip;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CoPressable(
        onTap: () => _showAtlasTrackingPopup(
          context,
          trackingIds,
          driverName: driverName,
        ),
        child: chip,
      ),
    );
  }
}

/// Popup listing all Atlas tracking-IDs for a single route, opened by
/// tapping the `_AtlasBadge` on a route card.
Future<void> _showAtlasTrackingPopup(
  BuildContext context,
  List<String> trackingIds, {
  required String driverName,
}) async {
  final t = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.tf('waveplan_btn_atlas_count', {
                    'count': '${trackingIds.length}',
                  }),
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverGraphite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (driverName.isNotEmpty)
                  Text(
                    driverName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 420),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < trackingIds.length; i++)
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTypography.caption2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trackingIds[i],
                        style: AppTypography.footnote.copyWith(
                          color: const Color(0xFF8A4A00),
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        CoButton(
          onPressed: () => Navigator.of(ctx).pop(),
          label: t.t('waveplan_btn_cancel'),
          variant: CoButtonVariant.quiet,
        ),
      ],
    ),
  );
}

/// Blue ← for left ("links"), green → for right ("rechts").
class _SpurIndicator extends StatelessWidget {
  final bool left;
  final Color color;
  final bool hasSpur;
  final VoidCallback? onTap;
  /// Adds invisible vertical hit-padding so the tap target reaches
  /// ~44px on touch devices (visuals stay identical). Only enabled in
  /// the compact/mobile route-card layout.
  final bool expandTouchTarget;
  const _SpurIndicator({
    required this.left,
    required this.color,
    this.hasSpur = true,
    this.onTap,
    this.expandTouchTarget = false,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final indicator = Container(
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
            !hasSpur
                ? Icons.swap_horiz_rounded
                : (left
                    ? Icons.arrow_back_rounded
                    : Icons.arrow_forward_rounded),
            size: 14,
            color: color,
          ),
          const SizedBox(height: 1),
          Text(
            !hasSpur ? (de ? 'Spur' : 'lane') : (left ? 'links' : 'rechts'),
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
    if (onTap == null) return indicator;
    return Tooltip(
      message: de
          ? 'Spur ändern (links / rechts / keine)'
          : 'Change lane (left / right / none)',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: expandTouchTarget
            // Invisible padding inside the InkWell grows the tap area
            // to ~44px without changing the drawn indicator.
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: indicator,
              )
            : indicator,
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
  final String? menteeTransporterId;
  final String menteeName;
  final ValueChanged<String?> onMenteeChange;
  final Map<String, String> namesMap;
  final Set<String> inWaveTids;
  /// Called when the admin uses "Fahrer ersetzen" in the chip menu.
  /// `null` disables the menu entry (used in the unassigned pool where
  /// replacement doesn't make sense).
  final ValueChanged<String>? onReplaceDriver;
  /// Compact (mobile) variant: drops the person avatar + close
  /// button so the chip fits next to the spur indicator on a phone.
  /// Long press still triggers the drag handle.
  final bool compact;

  const _DriverChip({
    required this.transporterId,
    required this.driverName,
    required this.onRemove,
    required this.onMenteeChange,
    required this.namesMap,
    required this.inWaveTids,
    this.menteeTransporterId,
    this.menteeName = '',
    this.dsp,
    this.onReplaceDriver,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _ChipBody(
      transporterId: transporterId,
      driverName: driverName,
      dsp: dsp,
      menteeTransporterId: menteeTransporterId,
      menteeName: menteeName,
      onRemove: onRemove,
      onMenteeChange: onMenteeChange,
      onReplaceDriver: onReplaceDriver,
      namesMap: namesMap,
      inWaveTids: inWaveTids,
      compact: compact,
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
            menteeTransporterId: menteeTransporterId,
            menteeName: menteeName,
            onRemove: onRemove,
            onMenteeChange: onMenteeChange,
            namesMap: namesMap,
            inWaveTids: inWaveTids,
            elevated: true,
            compact: compact,
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
  final String? menteeTransporterId;
  final String menteeName;
  final ValueChanged<String?> onMenteeChange;
  final ValueChanged<String>? onReplaceDriver;
  final Map<String, String> namesMap;
  final Set<String> inWaveTids;
  final bool elevated;
  final bool compact;

  const _ChipBody({
    required this.transporterId,
    required this.driverName,
    required this.onRemove,
    required this.onMenteeChange,
    required this.namesMap,
    required this.inWaveTids,
    this.menteeTransporterId,
    this.menteeName = '',
    this.dsp,
    this.onReplaceDriver,
    this.elevated = false,
    this.compact = false,
  });

  bool get _hasMentee =>
      menteeTransporterId != null && menteeTransporterId!.trim().isNotEmpty;

  static const Color _kMenteeBlue = Color(0xFF0A84FF);

  Future<void> _openMenu(BuildContext context) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromLTRB(
      origin.dx,
      origin.dy + box.size.height + 6,
      overlay.size.width - origin.dx - box.size.width,
      0,
    );

    final picked = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surfaceElevatedLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'open_profile',
          height: 44,
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: AppColors.codriverGreen,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  de ? 'Fahrerprofil öffnen' : 'Open driver profile',
                  style: AppTypography.subheadline.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.codriverGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'copy_tid',
          height: 44,
          child: Row(
            children: [
              const Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.codriverGraphite,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TID kopieren',
                      style: AppTypography.subheadline.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.codriverGraphite,
                      ),
                    ),
                    Text(
                      transporterId,
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.labelSecondaryLight,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (onReplaceDriver != null) const PopupMenuDivider(),
        if (onReplaceDriver != null)
          PopupMenuItem<String>(
            value: 'replace_driver',
            height: 44,
            child: Row(
              children: [
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 18,
                  color: Color(0xFFC2410C),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    de ? 'Fahrer ersetzen' : 'Replace driver',
                    style: AppTypography.subheadline.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC2410C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'mentee',
          height: 44,
          child: Row(
            children: [
              Icon(
                _hasMentee ? Icons.swap_horiz_rounded : Icons.person_add_alt_1,
                size: 18,
                color: _kMenteeBlue,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _hasMentee
                      ? 'Mentee ändern (${menteeName.isNotEmpty ? menteeName : menteeTransporterId})'
                      : 'Mentee hinzufügen',
                  style: AppTypography.subheadline.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _kMenteeBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (_hasMentee)
          PopupMenuItem<String>(
            value: 'mentee_remove',
            height: 40,
            child: Row(
              children: [
                const Icon(
                  Icons.person_remove_alt_1_outlined,
                  size: 18,
                  color: Color(0xFFB91C1C),
                ),
                const SizedBox(width: 10),
                Text(
                  de ? 'Mentee entfernen' : 'Remove mentee',
                  style: AppTypography.subheadline.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    if (!context.mounted) return;
    switch (picked) {
      case 'open_profile':
        // Copy TID to clipboard so the user can paste it into the
        // Drivers Hub search bar immediately, then route them there.
        await Clipboard.setData(ClipboardData(text: transporterId));
        if (!context.mounted) return;
        Navigator.of(context).pushNamed('/drivers');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              de
                  ? 'TID kopiert ($transporterId) — füge sie in die '
                      'Drivers-Hub-Suche ein, um $driverName zu öffnen.'
                  : 'TID copied ($transporterId) — paste it into the '
                      'Drivers Hub search to open $driverName.',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        break;
      case 'copy_tid':
        await Clipboard.setData(ClipboardData(text: transporterId));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TID kopiert · $transporterId'),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
      case 'mentee':
        final pickedTid = await showDialog<String>(
          context: context,
          builder: (ctx) => _AddMenteeDialog(
            namesMap: namesMap,
            disabledTids: {
              ...inWaveTids,
              transporterId.trim().toUpperCase(),
            },
            currentMenteeTid: menteeTransporterId,
          ),
        );
        if (pickedTid != null) {
          onMenteeChange(pickedTid);
        }
        break;
      case 'mentee_remove':
        onMenteeChange(null);
        break;
      case 'replace_driver':
        if (onReplaceDriver == null) break;
        final namedDrivers = <String, String>{};
        for (final entry in namesMap.entries) {
          final tid = entry.key.trim().toUpperCase();
          if (tid.isEmpty || tid.length < 4) continue;
          if (namedDrivers.containsKey(tid)) continue;
          namedDrivers[tid] = entry.value.trim();
        }
        final drivers = namedDrivers.entries
            .map((e) => _PickableDriver(tid: e.key, name: e.value))
            .toList();
        final newTid = await showDialog<String>(
          context: context,
          builder: (ctx) => _WaveplanDriverPickerDialog(
            drivers: drivers,
            title: de ? 'Fahrer ersetzen' : 'Replace driver',
            subtitle: de
                ? 'Aktuell: ${driverName.isEmpty ? transporterId : driverName}'
                : 'Current: ${driverName.isEmpty ? transporterId : driverName}',
            currentTid: transporterId,
            disabledTids: inWaveTids,
            icon: Icons.swap_horiz_rounded,
            accent: const Color(0xFFC2410C),
          ),
        );
        if (newTid != null && newTid.trim().isNotEmpty) {
          onReplaceDriver!(newTid.trim());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final hasName = driverName.trim().isNotEmpty;
    final borderColor =
        _hasMentee ? _kMenteeBlue : AppColors.codriverGreen;
    final avatarColor =
        _hasMentee ? _kMenteeBlue : AppColors.codriverGreen;

    return IntrinsicWidth(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openMenu(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 4 : 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: _hasMentee ? 2 : 1.5,
              ),
              boxShadow: elevated ? AppElevation.level3 : AppElevation.level1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!compact) ...[
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _hasMentee
                          ? Icons.school_outlined
                          : Icons.person_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasName
                            ? driverName
                            : (de ? '— kein Name —' : '— no name —'),
                        style: TextStyle(
                          fontSize: compact ? 12 : 13,
                          height: 1.15,
                          color: hasName
                              ? AppColors.codriverGraphite
                              : AppColors.labelTertiaryLight,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              hasName ? FontStyle.normal : FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: compact ? 1 : 2),
                      Text(
                        transporterId,
                        style: AppTypography.caption2.copyWith(
                          fontFamily: 'monospace',
                          color: AppColors.labelSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_hasMentee) ...[
                        SizedBox(height: compact ? 2 : 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 11,
                              color: _kMenteeBlue,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                menteeName.isNotEmpty
                                    ? menteeName
                                    : (menteeTransporterId ?? ''),
                                style: AppTypography.caption2.copyWith(
                                  color: _kMenteeBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: compact ? 6 : 10),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: CoPressable(
                    onTap: onRemove,
                    child: Container(
                      width: compact ? 18 : 20,
                      height: compact ? 18 : 20,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        size: compact ? 11 : 12,
                        color: AppColors.labelSecondaryLight,
                      ),
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

// ──────────────────────────────────────────────────────────────────────
//   ADD MENTEE DIALOG  — searchable list of available drivers
// ──────────────────────────────────────────────────────────────────────

class _AddMenteeDialog extends StatefulWidget {
  const _AddMenteeDialog({
    required this.namesMap,
    required this.disabledTids,
    required this.currentMenteeTid,
  });

  /// transporterId (UPPERCASE) → driver name
  final Map<String, String> namesMap;

  /// transporterIds that are already used (primary or mentee) in
  /// this wave. They appear greyed-out / disabled in the picker.
  final Set<String> disabledTids;

  final String? currentMenteeTid;

  @override
  State<_AddMenteeDialog> createState() => _AddMenteeDialogState();
}

class _AddMenteeDialogState extends State<_AddMenteeDialog> {
  final TextEditingController _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final allEntries = widget.namesMap.entries.toList()
      ..sort((a, b) =>
          a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    final cleanQ = _query.trim().toLowerCase();
    final filtered = allEntries.where((e) {
      final tid = e.key.trim().toUpperCase();
      final isCurrent = widget.currentMenteeTid != null &&
          widget.currentMenteeTid!.trim().toUpperCase() == tid;
      final taken = widget.disabledTids.contains(tid) && !isCurrent;
      if (taken) return false;
      if (cleanQ.isEmpty) return true;
      return e.value.toLowerCase().contains(cleanQ) ||
          tid.toLowerCase().contains(cleanQ);
    }).toList();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F1FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      color: Color(0xFF0A84FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          de ? 'Mentee hinzufügen' : 'Add mentee',
                          style: AppTypography.title3.copyWith(
                            color: AppColors.codriverGraphite,
                          ),
                        ),
                        Text(
                          de
                              ? 'Nur Fahrer, die noch nicht in der Wave sind.'
                              : 'Only drivers not yet in the wave.',
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.labelSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.labelSecondaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _q,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText:
                      de ? 'Name oder TID suchen…' : 'Search name or TID…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF0A84FF),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            de
                                ? 'Keine passenden Fahrer gefunden.'
                                : 'No matching drivers found.',
                            style: AppTypography.body.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: Color(0xFFE5E7EB),
                        ),
                        itemBuilder: (ctx, i) {
                          final tid = filtered[i].key;
                          final name = filtered[i].value;
                          final isCurrent = widget.currentMenteeTid != null &&
                              widget.currentMenteeTid!.trim().toUpperCase() ==
                                  tid.trim().toUpperCase();
                          return CoPressable(
                            onTap: () => Navigator.of(context).pop(tid),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE7F1FE),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 18,
                                      color: Color(0xFF0A84FF),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name.isNotEmpty
                                              ? name
                                              : (de
                                                  ? '— kein Name —'
                                                  : '— no name —'),
                                          style: AppTypography.subheadline
                                              .copyWith(
                                            color:
                                                AppColors.codriverGraphite,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          tid,
                                          style:
                                              AppTypography.caption2.copyWith(
                                            fontFamily: 'monospace',
                                            color: AppColors
                                                .labelSecondaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrent)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: Color(0xFF0A84FF),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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

class _UnassignedPool extends StatefulWidget {
  final List<String> transporterIds;
  final String Function(String? transporterId) resolveName;
  final void Function(String transporterId) onDropToPool;
  /// All currently-working drivers of the DSP — used for the "Add from
  /// Drivers Hub" picker (with sort by Name/Newest/Oldest) and to power
  /// Newest/Oldest sort on the pool itself.
  final List<_PickableDriver> activeDrivers;
  final Set<String> inWaveTids;
  /// All routes of the day — the pool search also surfaces drivers who
  /// are ALREADY assigned (ticket: "search option is not working" when
  /// the searched driver sits on a route and the pool is empty).
  final List<WaveplanRoute> routes;

  const _UnassignedPool({
    required this.transporterIds,
    required this.resolveName,
    required this.onDropToPool,
    this.activeDrivers = const <_PickableDriver>[],
    this.inWaveTids = const <String>{},
    this.routes = const <WaveplanRoute>[],
  });

  @override
  State<_UnassignedPool> createState() => _UnassignedPoolState();
}

class _UnassignedPoolState extends State<_UnassignedPool> {
  final TextEditingController _q = TextEditingController();
  String _query = '';
  _DriverPickerSort _sort = _DriverPickerSort.name;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _addFromHub() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final disabled = <String>{
      ...widget.inWaveTids.map((t) => t.toUpperCase()),
      ...widget.transporterIds.map((t) => t.toUpperCase()),
    };
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => _WaveplanDriverPickerDialog(
        drivers: widget.activeDrivers,
        title: de
            ? 'Fahrer aus Drivers Hub hinzufügen'
            : 'Add driver from Drivers Hub',
        subtitle: de
            ? 'Alle aktiven Fahrer · sortierbar nach Name / Neueste / Älteste'
            : 'All active drivers · sort by name / newest / oldest',
        disabledTids: disabled,
        icon: Icons.person_add_alt_1_rounded,
        accent: AppColors.codriverGreen,
        initialSort: _sort,
      ),
    );
    if (picked != null && picked.trim().isNotEmpty) {
      widget.onDropToPool(picked.trim());
    }
  }

  List<String> _displayedTids() {
    // Build TID → _PickableDriver lookup so we can sort by createdAt.
    final byTid = <String, _PickableDriver>{};
    for (final d in widget.activeDrivers) {
      byTid[d.tid.toUpperCase()] = d;
    }

    final cleanQ = _query.trim().toLowerCase();
    final filtered = widget.transporterIds.where((tid) {
      if (cleanQ.isEmpty) return true;
      if (tid.toLowerCase().contains(cleanQ)) return true;
      final name = widget.resolveName(tid).toLowerCase();
      return name.contains(cleanQ);
    }).toList();

    int byName(String a, String b) {
      final na = widget.resolveName(a).toLowerCase();
      final nb = widget.resolveName(b).toLowerCase();
      if (na.isEmpty && nb.isEmpty) return a.compareTo(b);
      if (na.isEmpty) return 1;
      if (nb.isEmpty) return -1;
      return na.compareTo(nb);
    }

    int byCreated(String a, String b, {required bool asc}) {
      final ta = byTid[a.toUpperCase()]?.createdAt;
      final tb = byTid[b.toUpperCase()]?.createdAt;
      if (ta == null && tb == null) return byName(a, b);
      if (ta == null) return 1;
      if (tb == null) return -1;
      return asc ? ta.compareTo(tb) : tb.compareTo(ta);
    }

    switch (_sort) {
      case _DriverPickerSort.name:
        filtered.sort(byName);
      case _DriverPickerSort.newest:
        filtered.sort((a, b) => byCreated(a, b, asc: false));
      case _DriverPickerSort.oldest:
        filtered.sort((a, b) => byCreated(a, b, asc: true));
    }
    return filtered;
  }

  /// Zugewiesene Fahrer, die zur Suche passen — als Info-Zeilen mit
  /// Route und Welle unter den Pool-Treffern.
  List<Widget> _assignedMatches() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final hits = widget.routes.where((r) {
      final tid = (r.transporterId ?? '').toLowerCase();
      if (tid.isEmpty) return false;
      final name = widget.resolveName(r.transporterId).toLowerCase();
      return tid.contains(q) || name.contains(q);
    }).toList();
    if (hits.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 4),
        child: Text(
          'Bereits zugewiesen',
          style: AppTypography.caption2.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: AppColors.labelSecondaryLight,
          ),
        ),
      ),
      for (final r in hits)
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 15, color: Color(0xFF00B287)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.resolveName(r.transporterId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.footnote.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.codriverGraphite,
                      ),
                    ),
                    Text(
                      '${r.routeCode} · Wave ${r.dispatchTime}',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final de = Localizations.localeOf(context).languageCode == 'de';
    final displayed = _displayedTids();
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => !widget.transporterIds.contains(d.data),
      onAcceptWithDetails: (d) => widget.onDropToPool(d.data),
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
              color: hovered ? AppColors.codriverGreen : Colors.transparent,
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
                    de ? 'Noch nicht zugewiesen' : 'Not assigned yet',
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
                      '${displayed.length}/${widget.transporterIds.length}',
                      style: AppTypography.caption1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.labelSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (widget.activeDrivers.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: CoButton(
                    onPressed: _addFromHub,
                    icon: Icons.person_add_alt_1_rounded,
                    label: de ? 'Fahrer aus Hub hinzufügen' : 'Add from Hub',
                    variant: CoButtonVariant.secondaryOutlined,
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _q,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: de ? 'Suchen…' : 'Search…',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          onPressed: () {
                            _q.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SortChip(
                      label: 'Name',
                      selected: _sort == _DriverPickerSort.name,
                      accent: AppColors.codriverGreen,
                      onTap: () => setState(
                        () => _sort = _DriverPickerSort.name,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: de ? 'Neueste' : 'Newest',
                      selected: _sort == _DriverPickerSort.newest,
                      accent: AppColors.codriverGreen,
                      onTap: () => setState(
                        () => _sort = _DriverPickerSort.newest,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _SortChip(
                      label: de ? 'Älteste' : 'Oldest',
                      selected: _sort == _DriverPickerSort.oldest,
                      accent: AppColors.codriverGreen,
                      onTap: () => setState(
                        () => _sort = _DriverPickerSort.oldest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  children: [
                    if (displayed.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          widget.transporterIds.isEmpty
                              ? (_query.trim().isEmpty
                                  ? t.t('waveplan_pool_empty')
                                  : '')
                              : (de
                                  ? 'Keine Treffer im Pool für „$_query".'
                                  : 'No matches in the pool for "$_query".'),
                          textAlign: TextAlign.center,
                          style: AppTypography.footnote.copyWith(
                            color: AppColors.labelTertiaryLight,
                          ),
                        ),
                      )
                    else
                      for (final tid in displayed)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _DriverChip(
                              transporterId: tid,
                              driverName: widget.resolveName(tid),
                              dsp: 'AION',
                              // Pool drivers stay where they are; tap is no-op.
                              onRemove: () {},
                              // Mentee picker not applicable in the pool.
                              onMenteeChange: (_) {},
                              namesMap: const <String, String>{},
                              inWaveTids: const <String>{},
                            ),
                          ),
                        ),
                    // Suche findet auch bereits zugewiesene Fahrer —
                    // mit Route + Welle, damit die Suche immer eine
                    // Antwort liefert.
                    ..._assignedMatches(),
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

// ──────────────────────────────────────────────────────────────────
//   SHIFT PLAN BANNER  (top of waveplan)
// ──────────────────────────────────────────────────────────────────

class _ShiftPlanBanner extends StatelessWidget {
  const _ShiftPlanBanner({
    required this.driverCount,
    required this.offsetMinutes,
    required this.onShowAll,
  });

  final int driverCount;
  final int offsetMinutes;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.codriverGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_note_rounded,
            size: 18,
            color: AppColors.codriverDeep,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shift plan loaded · $driverCount drivers',
                  style: AppTypography.subheadline.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Park = dispatch − $offsetMinutes min',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.codriverDeep.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onShowAll,
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('Show times'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.codriverDeep,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftPlanTimePill extends StatelessWidget {
  const _ShiftPlanTimePill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            value,
            style: AppTypography.subheadline.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Generic driver picker (Search + Sort) — used for Replace Driver,
//  "Add from Drivers Hub", and global driver search.
// ════════════════════════════════════════════════════════════════════════════

class _PickableDriver {
  final String tid;
  final String name;
  final DateTime? createdAt;
  const _PickableDriver({
    required this.tid,
    required this.name,
    this.createdAt,
  });
}

enum _DriverPickerSort { name, newest, oldest }

class _WaveplanDriverPickerDialog extends StatefulWidget {
  const _WaveplanDriverPickerDialog({
    required this.drivers,
    required this.title,
    this.subtitle,
    this.disabledTids = const <String>{},
    this.currentTid,
    this.icon = Icons.person_search_rounded,
    this.accent = const Color(0xFF0A84FF),
    this.initialSort = _DriverPickerSort.name,
  });

  final List<_PickableDriver> drivers;
  final String title;
  final String? subtitle;
  final Set<String> disabledTids;
  final String? currentTid;
  final IconData icon;
  final Color accent;
  final _DriverPickerSort initialSort;

  @override
  State<_WaveplanDriverPickerDialog> createState() =>
      _WaveplanDriverPickerDialogState();
}

class _WaveplanDriverPickerDialogState
    extends State<_WaveplanDriverPickerDialog> {
  final TextEditingController _q = TextEditingController();
  String _query = '';
  late _DriverPickerSort _sort = widget.initialSort;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<_PickableDriver> _filteredAndSorted() {
    final cleanQ = _query.trim().toLowerCase();
    final currentUpper = (widget.currentTid ?? '').trim().toUpperCase();
    final list = widget.drivers.where((d) {
      final isCurrent = d.tid.toUpperCase() == currentUpper;
      final taken =
          widget.disabledTids.contains(d.tid.toUpperCase()) && !isCurrent;
      if (taken) return false;
      if (cleanQ.isEmpty) return true;
      return d.name.toLowerCase().contains(cleanQ) ||
          d.tid.toLowerCase().contains(cleanQ);
    }).toList();

    int byName(_PickableDriver a, _PickableDriver b) {
      final na = a.name.toLowerCase();
      final nb = b.name.toLowerCase();
      if (na.isEmpty && nb.isEmpty) return a.tid.compareTo(b.tid);
      if (na.isEmpty) return 1;
      if (nb.isEmpty) return -1;
      return na.compareTo(nb);
    }

    int byCreated(_PickableDriver a, _PickableDriver b, {required bool asc}) {
      final ta = a.createdAt;
      final tb = b.createdAt;
      if (ta == null && tb == null) return byName(a, b);
      if (ta == null) return 1;
      if (tb == null) return -1;
      return asc ? ta.compareTo(tb) : tb.compareTo(ta);
    }

    switch (_sort) {
      case _DriverPickerSort.name:
        list.sort(byName);
      case _DriverPickerSort.newest:
        list.sort((a, b) => byCreated(a, b, asc: false));
      case _DriverPickerSort.oldest:
        list.sort((a, b) => byCreated(a, b, asc: true));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final filtered = _filteredAndSorted();
    final accent = widget.accent;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.title3.copyWith(
                            color: AppColors.codriverGraphite,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.labelSecondaryLight,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _q,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText:
                      de ? 'Name oder TID suchen…' : 'Search name or TID…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
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
                    borderSide: BorderSide(color: accent, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    de ? 'Sortieren:' : 'Sort:',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SortChip(
                            label: 'Name',
                            selected: _sort == _DriverPickerSort.name,
                            accent: accent,
                            onTap: () => setState(
                              () => _sort = _DriverPickerSort.name,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _SortChip(
                            label: de ? 'Neueste' : 'Newest',
                            selected: _sort == _DriverPickerSort.newest,
                            accent: accent,
                            onTap: () => setState(
                              () => _sort = _DriverPickerSort.newest,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _SortChip(
                            label: de ? 'Älteste' : 'Oldest',
                            selected: _sort == _DriverPickerSort.oldest,
                            accent: accent,
                            onTap: () => setState(
                              () => _sort = _DriverPickerSort.oldest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '${filtered.length}',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.labelTertiaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            de
                                ? 'Keine passenden Fahrer gefunden.'
                                : 'No matching drivers found.',
                            style: AppTypography.body.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: Color(0xFFE5E7EB),
                        ),
                        itemBuilder: (ctx, i) {
                          final d = filtered[i];
                          final isCurrent = (widget.currentTid ?? '')
                                  .trim()
                                  .toUpperCase() ==
                              d.tid.toUpperCase();
                          return CoPressable(
                            onTap: () => Navigator.of(context).pop(d.tid),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 18,
                                      color: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d.name.isNotEmpty
                                              ? d.name
                                              : (de
                                                  ? '— kein Name —'
                                                  : '— no name —'),
                                          style: AppTypography.subheadline
                                              .copyWith(
                                            color:
                                                AppColors.codriverGraphite,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          d.tid,
                                          style: AppTypography.caption2
                                              .copyWith(
                                            fontFamily: 'monospace',
                                            color:
                                                AppColors.labelSecondaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrent)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: accent,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CoPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE5E7EB),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption1.copyWith(
            color: selected ? accent : AppColors.codriverGraphite,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// First 5 chars of a clock string ("10:40:00" → "10:40") — safe for short
/// or empty values (TMGM imports have no shift end).
String _shortClock(String s) {
  final t = s.trim();
  return t.length >= 5 ? t.substring(0, 5) : t;
}
