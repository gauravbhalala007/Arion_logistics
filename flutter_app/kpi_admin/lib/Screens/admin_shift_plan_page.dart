import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/shift_plan.dart';
import '../services/shift_plan_parser.dart';
import '../services/shift_plan_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import '../widgets/dispatcher_bar.dart';
import '../widgets/waveplan_date_strip.dart';

class AdminShiftPlanPage extends StatefulWidget {
  const AdminShiftPlanPage({super.key});

  @override
  State<AdminShiftPlanPage> createState() => _AdminShiftPlanPageState();
}

class _AdminShiftPlanPageState extends State<AdminShiftPlanPage> {
  static const Color _kPageBg = Color(0xFFF3F6F7);
  static const Color _kCardBg = Color(0xFFFFFFFF);
  static const Color _kBorder = Color(0xFFE5E7EB);
  static const Color _kText = Color(0xFF111827);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kSoft = Color(0xFFF9FAFB);

  final ShiftPlanRepository _repo = ShiftPlanRepository();

  late DateTime _selectedDate;
  ParsedShiftPlan? _parsed;
  List<ShiftPlanEntry> _entries = <ShiftPlanEntry>[];

  /// In-memory cache of edits per date-key. Whenever the admin
  /// changes `_entries`, the current day's snapshot is written here.
  /// Navigating away and back restores from this map first — Excel
  /// parse + Firestore stream are only consulted as fallbacks.
  final Map<String, List<ShiftPlanEntry>> _entriesByDate =
      <String, List<ShiftPlanEntry>>{};

  /// When true the "Publish" button writes the WHOLE imported week
  /// at once. Default false → only the selected day is published.
  bool _weekMode = false;

  bool _publishing = false;
  bool _uploading = false;
  /// User-facing phase label rendered inside [_UploadLoadingCard].
  /// Updated as the synchronous parser moves through its stages so
  /// the admin sees the work happening instead of a static spinner.
  String _uploadPhase = '';
  String? _parseError;

  /// Currently published doc for the selected day — used to show
  /// upload timestamp and to grey out the UI for past days.
  ShiftPlanDoc? _existingPublished;
  StreamSubscription<ShiftPlanDoc?>? _publishedSub;

  final List<String> _selectedDispatchers = <String>[];
  /// Per-dispatcher shift range, mirrors the Waveplan pattern.
  final Map<String, List<String>> _shiftByDispatcher =
      <String, List<String>>{};
  static const int _maxDispatchers = 3;
  final TextEditingController _meetCtrl = TextEditingController();

  /// Day notes shown to every driver. Admin can stack multiple
  /// title+body entries; each renders as a chip in the right rail
  /// with its own X-to-remove button.
  List<ShiftPlanNote> _planNotes = <ShiftPlanNote>[];

  /// Search filter for the middle column — matches driver name or TID.
  String _entrySearch = '';
  final TextEditingController _searchCtrl = TextEditingController();

  /// Doc-level default offset between parking arrival and dispatch
  /// start. 15 min is the standard. Editable in the right column.
  int _parkingOffsetMinutes = 15;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    _meetCtrl.text = _parkingOffsetMinutes.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bindPublishedStream();
    });
  }

  @override
  void dispose() {
    _publishedSub?.cancel();
    _meetCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _bindPublishedStream() {
    _publishedSub?.cancel();
    final adminUid = _adminUid;
    if (adminUid == null) return;
    _publishedSub = _repo
        .watch(adminUid: adminUid, dateKey: _currentDateKey)
        .listen((doc) {
      if (!mounted) return;
      // We hydrate `_entries` (and the other doc-level controls) from
      // Firestore whenever:
      //   • The day is past/today (Excel re-upload is forbidden, so
      //     the admin always wants to see what actually ran), OR
      //   • There's a published doc AND no local edits cache for
      //     this day (page just (re)mounted — Firestore is the only
      //     source of truth after a browser refresh).
      // Future days where the admin already has local edits keep
      // their in-memory `_entries` (the cache check below).
      final hasLocalEdits =
          _entriesByDate.containsKey(_currentDateKey) ||
              _entries.isNotEmpty;
      final shouldHydrate =
          doc != null && (_isPastOrToday || !hasLocalEdits);
      setState(() {
        _existingPublished = doc;
        if (shouldHydrate) {
          _entries = List<ShiftPlanEntry>.from(doc.entries);
          _parkingOffsetMinutes = doc.parkingOffsetMinutes;
          _meetCtrl.text = doc.parkingOffsetMinutes.toString();
          _shiftByDispatcher
            ..clear()
            ..addAll(doc.dispatcherShifts);
          _selectedDispatchers
            ..clear()
            ..addAll(doc.dispatchers);
          _planNotes = List<ShiftPlanNote>.from(doc.notes);
          // Seed the in-memory edits cache so subsequent navigation
          // away + back preserves what we just hydrated.
          if (!_isPastOrToday) {
            _entriesByDate[_currentDateKey] =
                List<ShiftPlanEntry>.from(doc.entries);
          }
        }
      });
    });
  }

  String? get _adminUid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String get _currentDateKey => _dateKey(_selectedDate);

  String _formatDate(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _onDateChanged(DateTime d) {
    // Snapshot the day we're about to leave so edits survive the
    // navigation. Past / today days come from Firestore so we don't
    // cache them in the edit map.
    final leavingKey = _currentDateKey;
    if (!_isPastOrToday) {
      _entriesByDate[leavingKey] =
          List<ShiftPlanEntry>.from(_entries);
    }

    setState(() {
      _selectedDate = DateTime(d.year, d.month, d.day);
      _existingPublished = null;
      if (_isPastOrToday) {
        // Past / today: hydrate from Firestore in the stream listener,
        // never from a cached Excel parse. This prevents accidentally
        // overwriting historic plans with stale Excel data.
        _entries = <ShiftPlanEntry>[];
      } else {
        // Priority: in-memory edits cache > Excel parse > empty.
        final cached = _entriesByDate[_currentDateKey];
        if (cached != null) {
          _entries = List<ShiftPlanEntry>.from(cached);
        } else {
          _entries = List<ShiftPlanEntry>.from(
            _parsed?.assignmentsByDate[_currentDateKey] ??
                const <ShiftPlanEntry>[],
          );
        }
      }
    });
    _bindPublishedStream();
  }

  /// Visible, copy-friendly error dialog for upload failures. Used in
  /// place of a SnackBar so long messages and stack traces stay
  /// readable. Anything the user sees here is also dumped to the
  /// browser console via print().
  Future<void> _showUploadErrorDialog({
    required String title,
    required String message,
    String? details,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
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
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.title3.copyWith(
                          color: const Color(0xFFB91C1C),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: SelectableText(
                    message,
                    style: AppTypography.body.copyWith(
                      color: _kText,
                      height: 1.45,
                    ),
                  ),
                ),
                if (details != null && details.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          details,
                          style: AppTypography.caption2.copyWith(
                            fontFamily: 'monospace',
                            color: const Color(0xFF7F1D1D),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Spacer(),
                    CoButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      label: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndParseFile() async {
    if (_uploading) return;
    // ignore: avoid_print
    print('[shift-plan] _pickAndParseFile: opening file picker');
    setState(() => _parseError = null);

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('[shift-plan] FilePicker.pickFiles threw: $e\n$st');
      if (!mounted) return;
      await _showUploadErrorDialog(
        title: 'File picker failed',
        message: 'Could not open the file dialog.\n\nDetails: $e',
      );
      return;
    }

    if (result == null || result.files.isEmpty) {
      // ignore: avoid_print
      print('[shift-plan] picker cancelled (null/empty)');
      return;
    }
    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes;
    // ignore: avoid_print
    print(
      '[shift-plan] file picked: name=${pickedFile.name} '
      'size=${pickedFile.size} bytes-loaded=${bytes?.lengthInBytes}',
    );
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      await _showUploadErrorDialog(
        title: 'File came back empty',
        message:
            'The browser returned no bytes for "${pickedFile.name}". '
            'This usually happens with iCloud / OneDrive shortcuts, '
            'very large files, or unsupported browsers.\n\n'
            'Tip: copy the .xlsx to your local Downloads folder and '
            'pick it again.',
      );
      return;
    }
    if (!mounted) return;

    // Use an inline overlay state instead of a modal dialog. Modal
    // dialogs combined with a synchronous CPU-heavy parser can leave
    // the dialog visible if Navigator.pop races with build cycles.
    setState(() {
      _uploading = true;
      _uploadPhase = 'Reading file…';
    });

    // Wait two frames so the overlay AND its pulse animation have time
    // to paint before the parser runs. The async parser yields back to
    // the event loop between phases so the animation keeps moving.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 120));

    ParsedShiftPlan? parsed;
    Object? parserError;
    StackTrace? parserStack;
    try {
      parsed = await parseShiftPlanExcelAsync(
        bytes,
        onPhase: (phase) {
          if (!mounted) return;
          setState(() => _uploadPhase = phase);
        },
      );
      // ignore: avoid_print
      print(
        '[shift-plan] parsed OK · days=${parsed.availableDateKeys.length} '
        '· roster=${parsed.roster.length}',
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('[shift-plan] parser failed: $e\n$st');
      parserError = e;
      parserStack = st;
    }

    if (!mounted) return;
    setState(() {
      _uploading = false;
      _uploadPhase = '';
    });

    if (parserError != null) {
      final msg = parserError.toString();
      setState(() => _parseError =
          msg.isEmpty ? 'Unknown parser error' : msg);
      await _showUploadErrorDialog(
        title: 'Parser error',
        message: msg.isEmpty
            ? '(no message)'
            : msg,
        details: parserStack?.toString(),
      );
      return;
    }

    setState(() {
      _parsed = parsed;
      _parseError = null;
    });

    // Show every parsed day. The user may want to inspect (not
    // necessarily publish) past days. The publish path itself blocks
    // past-day overwrites via _onDateChanged + the week-mode skip.
    final available = parsed!.availableDateKeys;
    // ignore: avoid_print
    print('[shift-plan] available days: $available');
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            'File processed — no day columns detected.',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Ask which day to load. Preference order:
    //   1. Currently-selected date, if it's in the parsed range AND
    //      it's not a past day (we never default to a past day).
    //   2. First future day (today or later).
    //   3. First day overall (fallback when only past days exist).
    final now = DateTime.now();
    final todayKey = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final firstFuture = available.firstWhere(
      (k) => k.compareTo(todayKey) >= 0,
      orElse: () => '',
    );
    final defaultKey = (available.contains(_currentDateKey) &&
            _currentDateKey.compareTo(todayKey) >= 0)
        ? _currentDateKey
        : (firstFuture.isNotEmpty ? firstFuture : available.first);
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => _DayPickerDialog(
        availableKeys: available,
        initialKey: defaultKey,
      ),
    );
    if (picked == null || !mounted) return;

    final pickedDate = DateTime.parse(picked);
    // Past-day guard: the Excel data still loads so the admin can
    // inspect it, but we never write past days. _onDateChanged + the
    // publish path enforce this — the day-picker just defaults the
    // selected date. We reuse `todayKey` defined above for the picker
    // default to avoid re-computing.
    final today = DateTime.parse(todayKey);
    final isPast = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day)
        .isBefore(today);
    final freshEntries = isPast
        ? <ShiftPlanEntry>[]
        : List<ShiftPlanEntry>.from(
            parsed.assignmentsByDate[picked] ??
                const <ShiftPlanEntry>[],
          );
    setState(() {
      _selectedDate =
          DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      _entries = freshEntries;
      // Seed the cache so navigating away and back restores this
      // freshly-loaded day. Past days don't get cached — they hydrate
      // from Firestore on demand.
      if (!isPast) {
        _entriesByDate[picked] =
            List<ShiftPlanEntry>.from(freshEntries);
      }
    });
    _bindPublishedStream();

    if (!mounted) return;
    final d = pickedDate;
    final label = '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.${d.year}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.codriverDeep,
        content: Text(
          'Shift plan for $label loaded · ${_entries.length} drivers.',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool get _isTomorrowSelected {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    return _selectedDate.year == tomorrow.year &&
        _selectedDate.month == tomorrow.month &&
        _selectedDate.day == tomorrow.day;
  }

  /// True if the selected day is yesterday or earlier — read-only,
  /// or today (today's plan already runs, also locked).
  bool get _isPastOrToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !_selectedDate.isAfter(today);
  }

  /// The 19:00–23:59 publish window required for tomorrow's plan.
  bool get _inEveningWindow {
    final now = DateTime.now();
    return now.hour >= 19;
  }

  /// Hard rules that disable the Publish button. The 19:00 window is
  /// no longer a hard gate — it's surfaced as a soft warning the
  /// admin can override in the confirm dialog.
  String? _publishBlockedReason() {
    if (!_weekMode && _entries.isEmpty) {
      return 'No shifts loaded. Upload a file.';
    }
    if (!_weekMode && !_allSlotsFilled) {
      return '$_emptySlotCount empty slot${_emptySlotCount == 1 ? '' : 's'} — fill first.';
    }
    if (_weekMode &&
        (_parsed == null || _parsed!.assignmentsByDate.isEmpty)) {
      return 'No data in the file.';
    }
    return null;
  }

  /// Soft warning shown alongside the publish button. Doesn't disable
  /// the button — the admin can confirm-through in the publish flow.
  String? _publishSoftWarning() {
    if (_isTomorrowSelected && !_inEveningWindow) {
      return 'Outside the 19:00–23:59 window for tomorrow — confirm in the dialog.';
    }
    return null;
  }

  bool get _canPublish => _publishBlockedReason() == null;

  Future<void> _publish() async {
    final adminUid = _adminUid;
    if (adminUid == null) return;
    final blocked = _publishBlockedReason();
    if (blocked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(blocked)),
      );
      return;
    }

    // Extra-Warnung wenn ein anderer Tag als morgen ausgewählt ist —
    // im Normalfall soll der Admin für den Folgetag publishen.
    if (!_weekMode && !_isTomorrowSelected) {
      final proceedOffTomorrow = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Day other than tomorrow'),
          content: Text(
            'You selected **${_formatDate(_selectedDate)}** — '
            'that is not tomorrow.\n\n'
            'Publish the shift plan for this day anyway?',
          ),
          actions: [
            CoButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              label: 'Cancel',
              variant: CoButtonVariant.quiet,
            ),
            CoButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              label: 'Yes, this day',
            ),
          ],
        ),
      );
      if (proceedOffTomorrow != true || !mounted) return;
    }

    // Soft 19:00 gate — tomorrow's plan was previously hard-locked
    // outside the evening window. Now it asks instead of blocking.
    if (!_weekMode &&
        _isTomorrowSelected &&
        !_inEveningWindow) {
      final proceedOffWindow = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Outside the 19:00 window'),
          content: const Text(
            'Tomorrow\'s plan is normally published between 19:00 '
            'and 23:59 because Amazon\'s tour count can still shift '
            'until then.\n\n'
            'Publish anyway?',
          ),
          actions: [
            CoButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              label: 'Wait',
              variant: CoButtonVariant.quiet,
            ),
            CoButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              label: 'Publish now',
            ),
          ],
        ),
      );
      if (proceedOffWindow != true || !mounted) return;
    }

    final scope = _weekMode
        ? 'the whole week (${_parsed!.assignmentsByDate.length} days)'
        : _formatDate(_selectedDate);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publish shift plan'),
        content: Text(
          _weekMode
              ? 'You are publishing $scope.\n\n'
                  'After confirmation a 3-minute timer starts. '
                  'You can still cancel the publish until then. '
                  'Drivers are notified only after the timer.'
              : 'You are publishing only the plan for $scope. '
                  'Other days from the file remain untouched.\n\n'
                  'After confirmation a 3-minute timer starts. '
                  'You can still cancel the publish until then. '
                  'Drivers are notified only after the timer.',
        ),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: 'Start timer',
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final go = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const _PublishCountdownDialog(durationSeconds: 180),
    );
    if (!mounted) return;
    if (go != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publish cancelled.')),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      if (_weekMode) {
        // Publish every day from the Excel as its own Firestore doc.
        // Skip past days defensively — week-mode never overwrites
        // historic data, regardless of what the Excel contains.
        final today = DateTime(DateTime.now().year,
            DateTime.now().month, DateTime.now().day);
        for (final entry in _parsed!.assignmentsByDate.entries) {
          final entryDate = DateTime.parse(entry.key);
          if (entryDate.isBefore(today)) continue;
          await _repo.publish(
            adminUid: adminUid,
            plan: ShiftPlanDoc(
              dateKey: entry.key,
              entries: entry.value,
              station: _parsed?.station ?? '',
              company: _parsed?.company ?? '',
              dispatchers: List<String>.from(_selectedDispatchers),
              notes: List<ShiftPlanNote>.from(_planNotes),
              meetingTime: '',
              parkingOffsetMinutes: _parkingOffsetMinutes,
              dispatcherShifts: Map<String, List<String>>.from(
                _shiftByDispatcher,
              ),
              publishedAt: null,
            ),
          );
        }
      } else {
        await _repo.publish(
          adminUid: adminUid,
          plan: ShiftPlanDoc(
            dateKey: _currentDateKey,
            entries: _entries,
            station: _parsed?.station ?? '',
            company: _parsed?.company ?? '',
            dispatchers: List<String>.from(_selectedDispatchers),
            notes: List<ShiftPlanNote>.from(_planNotes),
            meetingTime: '',
            parkingOffsetMinutes: _parkingOffsetMinutes,
            dispatcherShifts: Map<String, List<String>>.from(
              _shiftByDispatcher,
            ),
            publishedAt: null,
          ),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            _weekMode
                ? 'Week plan published. Drivers will be notified.'
                : 'Shift plan for ${_formatDate(_selectedDate)} published.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: $e')),
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Stream<List<String>> _dispatcherNamesStream() {
    final uid = _adminUid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('dispatcher_pill')
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? const <String, dynamic>{};
      final list = data['dispatchers'];
      if (list is! List) return <String>[];
      return list
          .map((e) => (e is Map ? (e['name'] ?? '') : e).toString().trim())
          .where((s) => s.isNotEmpty)
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });
  }

  List<ShiftRoster> _availableDrivers() {
    final taken = _inUseTids;
    final source = _parsed?.roster ?? const <ShiftRoster>[];
    return source
        .where(
          (r) => !taken.contains(r.transporterId.trim().toUpperCase()),
        )
        .toList();
  }

  /// TIDs already used somewhere in the plan — primary driver OR
  /// mentee. Used to filter the mentee picker.
  Set<String> get _inUseTids {
    final out = <String>{};
    for (final e in _entries) {
      final t = e.transporterId.trim().toUpperCase();
      if (t.isNotEmpty) out.add(t);
      final m = e.menteeTransporterId.trim().toUpperCase();
      if (m.isNotEmpty) out.add(m);
    }
    return out;
  }


  /// The audit signature for the currently signed-in admin. Falls
  /// back to email or "Admin" if no displayName is set.
  String get _adminDisplayName {
    final u = FirebaseAuth.instance.currentUser;
    final dn = (u?.displayName ?? '').trim();
    if (dn.isNotEmpty) return dn;
    final em = (u?.email ?? '').trim();
    if (em.isNotEmpty) return em;
    return 'Admin';
  }

  /// Shows a confirm dialog with the entry's name in the question and
  /// runs [onConfirm] if the admin confirms. Returns true if applied.
  Future<bool> _confirm({
    required String title,
    required String message,
    String confirmLabel = 'Yes, change',
    bool destructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message, style: const TextStyle(height: 1.5)),
        actions: [
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            label: 'Cancel',
            variant: CoButtonVariant.quiet,
          ),
          CoButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            label: confirmLabel,
            variant: destructive
                ? CoButtonVariant.destructive
                : CoButtonVariant.primary,
          ),
        ],
      ),
    );
    return ok == true;
  }

  /// Clear the driver from a slot (X button) — the slot itself stays
  /// in the plan so the admin can drop a different driver in. Publish
  /// is disabled until every slot has a driver again. Past edits get
  /// an audit-trail entry attached.
  Future<void> _clearEntry(int index) async {
    final e = _entries[index];
    final name =
        e.driverName.isNotEmpty ? e.driverName : e.transporterId;
    final ok = await _confirm(
      title: 'Remove driver',
      message:
          'Are you sure "$name" should be removed from the plan?\n\n'
          'The slot stays empty and an audit entry is created.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _entries[index] = _entries[index].copyWith(
        transporterId: '',
        driverName: '',
        appendAudit: AuditEvent(
          userName: _adminDisplayName,
          timestamp: DateTime.now(),
          action: 'removed "$name"',
        ),
      );
    });
  }

  /// Remove a slot entirely (for accidentally added rescue / extra
  /// slots). Reachable only via the editor dialog. Confirms first.
  Future<void> _deleteEntry(int index) async {
    final e = _entries[index];
    final name =
        e.driverName.isNotEmpty ? e.driverName : 'empty slot';
    final ok = await _confirm(
      title: 'Delete slot',
      message:
          'Are you sure the slot "$name" should be deleted completely?\n\n'
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _entries.removeAt(index));
  }

  /// Has the admin filled every slot? Required before publish.
  bool get _allSlotsFilled =>
      _entries.every((e) => e.transporterId.trim().isNotEmpty);

  int get _emptySlotCount =>
      _entries.where((e) => e.transporterId.trim().isEmpty).length;

  void _assignDriverToSlot(int index, ShiftRoster driver) {
    setState(() {
      _entries[index] = _entries[index].copyWith(
        transporterId: driver.transporterId,
        driverName: driver.driverName,
      );
    });
  }

  Future<void> _addManualSlot(ShiftKind kind) async {
    final time = await showDialog<String>(
      context: context,
      builder: (ctx) => _TimePickerDialog(
        kind: kind,
        knownTimes: _knownDispatchTimes(),
      ),
    );
    if (time == null || time.trim().isEmpty || !mounted) return;
    setState(() {
      _entries.add(
        ShiftPlanEntry(
          transporterId: '',
          driverName: '',
          blocks: <ShiftBlock>[
            ShiftBlock(
              serviceType: kind == ShiftKind.rescue ? 'Rescue' : 'Extra',
              startTime: time,
              duration: '9 Std.',
            ),
          ],
          kind: kind,
        ),
      );
    });
  }

  Future<void> _editEntry(int index) async {
    final original = _entries[index];
    final result = await showDialog<_EntryEditorResult>(
      context: context,
      builder: (ctx) => _EntryEditorDialog(
        entry: original,
        roster: _parsed?.roster ?? const <ShiftRoster>[],
        inUseTids: _inUseTids,
        ownTransporterId: original.transporterId,
      ),
    );
    if (result == null) return;
    if (result.deleteSlot) {
      await _deleteEntry(index);
      return;
    }
    if (result.updated == null) return;

    // Diff the original vs updated to produce one audit entry per
    // meaningful change. The dialog itself doesn't write audit
    // events — this keeps the dialog dumb and the page authoritative.
    final updated = result.updated!;
    final actions = _diffEntryActions(original, updated);
    if (actions.isEmpty) {
      setState(() => _entries[index] = updated);
      return;
    }
    final ok = await _confirm(
      title: actions.length == 1
          ? 'Confirm change'
          : 'Confirm ${actions.length} changes',
      message:
          'The following changes will be saved with an audit entry:\n\n'
          '• ${actions.join('\n• ')}\n\n'
          'Stamped with your name and the current time.',
      confirmLabel: 'Save',
    );
    if (!ok || !mounted) return;
    final now = DateTime.now();
    final newTrail = <AuditEvent>[
      ...updated.auditTrail,
      for (final a in actions)
        AuditEvent(
          userName: _adminDisplayName,
          timestamp: now,
          action: a,
        ),
    ];
    setState(() {
      _entries[index] = updated.copyWith(auditTrail: newTrail);
    });
  }

  /// Computes a list of user-facing action labels describing what
  /// changed between [a] and [b]. Empty list = no audit-worthy change.
  List<String> _diffEntryActions(ShiftPlanEntry a, ShiftPlanEntry b) {
    final out = <String>[];
    if (a.kind != b.kind) {
      out.add('changed kind from ${_kindLabel(a.kind)} → ${_kindLabel(b.kind)}');
    }
    if (a.meetingTime.trim() != b.meetingTime.trim()) {
      final to = b.meetingTime.trim().isEmpty
          ? 'global'
          : b.meetingTime.trim();
      out.add('changed meeting time to "$to"');
    }
    if (a.menteeTransporterId.trim() != b.menteeTransporterId.trim()) {
      if (b.menteeTransporterId.trim().isEmpty) {
        final who = a.menteeName.isNotEmpty
            ? a.menteeName
            : a.menteeTransporterId;
        out.add('removed ride along "$who"');
      } else if (a.menteeTransporterId.trim().isEmpty) {
        final who = b.menteeName.isNotEmpty
            ? b.menteeName
            : b.menteeTransporterId;
        out.add('added ride along "$who"');
      } else {
        out.add(
            'changed ride along to "${b.menteeName.isNotEmpty ? b.menteeName : b.menteeTransporterId}"');
      }
    }
    if (a.personalNotes.trim() != b.personalNotes.trim()) {
      out.add(b.personalNotes.trim().isEmpty
          ? 'removed personal note'
          : 'updated personal note');
    }
    if (a.lateCancel != b.lateCancel) {
      out.add(b.lateCancel
          ? 'marked as Cut · Late Cancel'
          : 'cleared Cut · Late Cancel mark');
    } else if (b.lateCancel &&
        a.lateCancelReason.trim() != b.lateCancelReason.trim()) {
      out.add('updated Late Cancel reason');
    }
    return out;
  }

  /// Opens the notes editor dialog. Lets the admin set a title + body,
  /// load a saved template, save the current text as a new template,
  /// or delete a template. Persists templates per admin in Firestore.
  /// When [editingIndex] is set, the dialog edits the note at that
  /// index of [_planNotes]. Otherwise it appends a new note.
  Future<void> _openNotesEditor({int? editingIndex}) async {
    final adminUid = _adminUid;
    if (adminUid == null) return;
    final existing = editingIndex != null
        ? _planNotes[editingIndex]
        : const ShiftPlanNote(title: '', body: '');
    final result = await showDialog<_NotesEditorResult>(
      context: context,
      builder: (ctx) => _NotesEditorDialog(
        initialTitle: existing.title,
        initialBody: existing.body,
        templatesStream: _repo.watchNoteTemplates(adminUid),
        onSaveTemplate: (title, body) async {
          await _repo.saveNoteTemplate(
            adminUid: adminUid,
            title: title,
            body: body,
          );
        },
        onDeleteTemplate: (id) async {
          await _repo.deleteNoteTemplate(
            adminUid: adminUid,
            templateId: id,
          );
        },
      ),
    );
    if (result == null || !mounted) return;
    final note = ShiftPlanNote(
      title: result.title.trim(),
      body: result.body.trim(),
    );
    if (note.title.isEmpty && note.body.isEmpty) return;
    setState(() {
      if (editingIndex != null) {
        _planNotes[editingIndex] = note;
      } else {
        _planNotes.add(note);
      }
    });
  }

  void _removeNoteAt(int index) {
    setState(() => _planNotes.removeAt(index));
  }

  /// Unpublish the current day's plan — deletes the Firestore doc so
  /// drivers no longer see it. Strong confirm with the date in the
  /// message to avoid accidental wipes.
  Future<void> _unpublishCurrent() async {
    final adminUid = _adminUid;
    final existing = _existingPublished;
    if (adminUid == null || existing == null) return;
    final ok = await _confirm(
      title: 'Unpublish shift plan',
      message:
          'Remove the published plan for ${_formatDate(_selectedDate)}?\n\n'
          'Drivers will no longer see it. Your local edits stay in '
          'place — you can re-publish later.',
      confirmLabel: 'Unpublish',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await _repo.unpublish(
        adminUid: adminUid,
        dateKey: _currentDateKey,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            'Unpublished ${_formatDate(_selectedDate)}.',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unpublish failed: $e')),
      );
    }
  }

  /// Clear all entries on the current day — used by the Clear button
  /// next to Publish. Confirms first.
  Future<void> _clearAllEntries() async {
    if (_entries.isEmpty) return;
    final ok = await _confirm(
      title: 'Clear all entries',
      message:
          'This removes all ${_entries.length} drivers from the plan '
          'for ${_formatDate(_selectedDate)}. The Excel parse stays '
          'cached — you can re-load the day from the file.',
      confirmLabel: 'Clear',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _entries = <ShiftPlanEntry>[];
      _entrySearch = '';
      _searchCtrl.clear();
      // Also wipe the in-memory cache for this day. Otherwise the
      // hydration logic (`hasLocalEdits = cache has key`) would
      // suppress a Firestore re-hydration after the next publish.
      _entriesByDate.remove(_currentDateKey);
    });
  }

  String _kindLabel(ShiftKind k) {
    switch (k) {
      case ShiftKind.regular:
        return 'Regular';
      case ShiftKind.rescue:
        return 'Rescue';
      case ShiftKind.extra:
        return 'Extra';
    }
  }

  /// Group entries by their first block's start time. Empty start
  /// time goes to "Other". Returns ordered groups. Applies the search
  /// filter — entries hidden by the filter never enter the groups.
  List<MapEntry<String, List<int>>> _groupedByStart() {
    final visible = _filteredIndices().toSet();
    final groups = <String, List<int>>{};
    for (var i = 0; i < _entries.length; i++) {
      if (!visible.contains(i)) continue;
      final e = _entries[i];
      final start =
          e.blocks.isNotEmpty ? e.blocks.first.startTime.trim() : '';
      final key = start.isEmpty ? 'Other' : start;
      groups.putIfAbsent(key, () => <int>[]).add(i);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == 'Other') return 1;
        if (b == 'Other') return -1;
        return _minutesOfDay(a).compareTo(_minutesOfDay(b));
      });
    return [
      for (final k in keys) MapEntry(k, groups[k]!),
    ];
  }

  int _minutesOfDay(String s) {
    final m = RegExp(
            r'^(\d{1,2}):(\d{2})\s*(am|pm)?', caseSensitive: false)
        .firstMatch(s.trim());
    if (m == null) return 99999;
    var h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final min = int.tryParse(m.group(2) ?? '0') ?? 0;
    final suf = (m.group(3) ?? '').toLowerCase();
    if (suf == 'pm' && h < 12) h += 12;
    if (suf == 'am' && h == 12) h = 0;
    return h * 60 + min;
  }

  /// Distinct dispatch start times already present in `_entries`,
  /// sorted by time. Used by the Rescue/Extra time-picker as quick chips.
  List<String> _knownDispatchTimes() {
    final set = <String>{};
    for (final e in _entries) {
      for (final b in e.blocks) {
        final t = b.startTime.trim();
        if (t.isNotEmpty) set.add(t);
      }
    }
    final list = set.toList();
    list.sort((a, b) => _minutesOfDay(a).compareTo(_minutesOfDay(b)));
    return list;
  }

  /// Apply the search filter to entries. Search matches driver name OR
  /// transporter ID, case-insensitive. Empty query → identity.
  List<int> _filteredIndices() {
    final q = _entrySearch.trim().toLowerCase();
    if (q.isEmpty) {
      return List<int>.generate(_entries.length, (i) => i);
    }
    final out = <int>[];
    for (var i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      if (e.driverName.toLowerCase().contains(q) ||
          e.transporterId.toLowerCase().contains(q)) {
        out.add(i);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final adminUid = _adminUid;
    if (adminUid == null) {
      return const Scaffold(
        backgroundColor: _kPageBg,
        body: Center(child: Text('—')),
      );
    }
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 1100;
    final isMedium = width >= 760 && width < 1100;

    return Scaffold(
      backgroundColor: _kPageBg,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  _Header(
                    publishedAt: _existingPublished?.publishedAt,
                    isPastOrToday: _isPastOrToday,
                    lateCancelCount:
                        _entries.where((e) => e.lateCancel).length,
                    canPublish: _canPublish,
                    publishing: _publishing,
                    publishLabel:
                        _weekMode ? 'Publish week' : 'Publish day',
                    onPublish: _publish,
                    canClear: _entries.isNotEmpty && !_publishing,
                    onClear: _clearAllEntries,
                    canUnpublish: _existingPublished != null &&
                        !_publishing,
                    onUnpublish: _unpublishCurrent,
                    selectedDate: _selectedDate,
                    onDateChanged: _onDateChanged,
                    blockedReason: _publishBlockedReason(),
                    softWarning: _publishSoftWarning(),
                  ),
                  const SizedBox(height: 10),
                  if (_parseError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _parseError!,
                        style: AppTypography.footnote.copyWith(
                          color: const Color(0xFFB91C1C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Layout stays mounted at all times — even without
                  // an uploaded Excel. The middle column handles its
                  // own empty state ("No shifts for this day"), and
                  // the right column has the file-upload action.
                  Expanded(
                    child: isWide
                        ? _wideLayout()
                        : isMedium
                            ? _mediumLayout()
                            : _narrowLayout(),
                  ),
                ],
              ),
            ),
            // Upload overlay — rendered directly (no fade-in switcher)
            // so the first paint lands on the very next frame, before
            // the synchronous Excel parser blocks the main thread.
            if (_uploading)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Center(
                      child: _UploadLoadingCard(phase: _uploadPhase),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 280, child: _leftColumn()),
        const SizedBox(width: 12),
        Expanded(child: _middleColumn()),
        const SizedBox(width: 12),
        SizedBox(width: 320, child: _rightColumn()),
      ],
    );
  }

  Widget _mediumLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _middleColumn()),
              const SizedBox(width: 12),
              SizedBox(width: 320, child: _rightColumn()),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 200, child: _leftColumn()),
      ],
    );
  }

  Widget _narrowLayout() {
    return Column(
      children: [
        SizedBox(height: 180, child: _leftColumn()),
        const SizedBox(height: 10),
        Expanded(child: _middleColumn()),
        const SizedBox(height: 10),
        SizedBox(height: 320, child: _rightColumn()),
      ],
    );
  }

  Widget _leftColumn() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KW toggle — switches publish from single-day to whole-week.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: _KwToggle(
              active: _weekMode,
              parsed: _parsed,
              onToggle: () =>
                  setState(() => _weekMode = !_weekMode),
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          // Available drivers pool
          Expanded(child: _AvailablePool(drivers: _availableDrivers())),
        ],
      ),
    );
  }

  Widget _middleColumn() {
    final groups = _groupedByStart();
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDate(_selectedDate),
                        style: AppTypography.headline.copyWith(
                          color: _kText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${_entries.length} drivers · '
                        '${_entries.where((e) => e.kind == ShiftKind.rescue).length} rescue · '
                        '${_entries.where((e) => e.kind == ShiftKind.extra).length} extra',
                        style: AppTypography.caption1.copyWith(
                          color: _kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                CoButton(
                  onPressed: () => _addManualSlot(ShiftKind.rescue),
                  label: '+ Rescue',
                  variant: CoButtonVariant.secondaryOutlined,
                ),
                const SizedBox(width: 6),
                CoButton(
                  onPressed: () => _addManualSlot(ShiftKind.extra),
                  label: '+ Extra',
                  variant: CoButtonVariant.secondaryOutlined,
                ),
              ],
            ),
          ),
          // Search bar — filters the list by driver name or TID.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                if (_entrySearch == v) return;
                setState(() => _entrySearch = v);
              },
              style: AppTypography.subheadline.copyWith(
                color: _kText,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Search driver name or TID…',
                hintStyle: AppTypography.subheadline.copyWith(
                  color: _kMuted,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: _kMuted,
                ),
                suffixIcon: _entrySearch.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: _kMuted,
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _entrySearch = '');
                        },
                        tooltip: 'Clear search',
                      ),
                isDense: true,
                filled: true,
                fillColor: _kSoft,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.codriverGreen,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          Expanded(
            child: _entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No shifts for this day in the file.',
                        textAlign: TextAlign.center,
                        style:
                            AppTypography.body.copyWith(color: _kMuted),
                      ),
                    ),
                  )
                : groups.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No drivers match "$_entrySearch".',
                        textAlign: TextAlign.center,
                        style:
                            AppTypography.body.copyWith(color: _kMuted),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    itemCount: groups.fold<int>(
                        0, (acc, g) => acc + 1 + g.value.length),
                    itemBuilder: (ctx, idx) {
                      // Walk groups to find which header/row this idx is.
                      var cursor = 0;
                      for (final g in groups) {
                        if (idx == cursor) {
                          return _TimeGroupHeader(label: g.key);
                        }
                        cursor++;
                        if (idx < cursor + g.value.length) {
                          final entryIdx = g.value[idx - cursor];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 4,
                            ),
                            child: _AssignmentRow(
                              entry: _entries[entryIdx],
                              parkingOffsetMinutes: _parkingOffsetMinutes,
                              onTap: () => _editEntry(entryIdx),
                              onClearDriver: () => _clearEntry(entryIdx),
                              onDropDriver: (drv) =>
                                  _assignDriverToSlot(entryIdx, drv),
                            ),
                          );
                        }
                        cursor += g.value.length;
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rightColumn() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RightLabel(icon: Icons.event_note_rounded, text: 'Date'),
            const SizedBox(height: 6),
            WaveplanDateStrip(
              selected: _selectedDate,
              onSelect: _onDateChanged,
            ),
            const SizedBox(height: 16),
            _RightLabel(
              icon: Icons.local_parking_rounded,
              text: 'Parking offset (min before dispatch)',
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _meetCtrl,
                    keyboardType: TextInputType.number,
                    style: AppTypography.subheadline.copyWith(
                      color: _kText,
                      fontWeight: FontWeight.w700,
                    ),
                    onChanged: (v) {
                      final parsed = int.tryParse(v.trim());
                      if (parsed != null && parsed >= 0 && parsed <= 120) {
                        setState(() => _parkingOffsetMinutes = parsed);
                      }
                    },
                    decoration: _rightInputDecoration(hint: '15'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _kSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Text(
                    '$_parkingOffsetMinutes min',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Default 15 min. Each row shows Park = Dispatch − offset.',
              style: AppTypography.caption2.copyWith(
                color: _kMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            _RightLabel(
              icon: Icons.headset_mic_rounded,
              text: 'Dispatcher',
            ),
            const SizedBox(height: 6),
            StreamBuilder<List<String>>(
              stream: _dispatcherNamesStream(),
              builder: (context, snap) {
                final available = snap.data ?? const <String>[];
                return DispatcherBar(
                  available: available,
                  selected: _selectedDispatchers,
                  shiftByDispatcher: _shiftByDispatcher.map(
                    (k, v) => MapEntry(
                      k,
                      DispatcherShiftRange.fromList(v),
                    ),
                  ),
                  maxSelectable: _maxDispatchers,
                  emptyLabel: 'Configure in Dispatcher Center.',
                  stacked: true,
                  onAddDispatcher: (name) {
                    if (_selectedDispatchers.contains(name)) return;
                    if (_selectedDispatchers.length >= _maxDispatchers) {
                      return;
                    }
                    setState(() {
                      _selectedDispatchers.add(name);
                      _shiftByDispatcher[name] = defaultShiftFor(
                        _selectedDispatchers.length - 1,
                      ).toList();
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
                      _shiftByDispatcher[name] = range.toList();
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _RightLabel(
              icon: Icons.sticky_note_2_outlined,
              text: 'Notes',
            ),
            const SizedBox(height: 6),
            _NotesSection(
              notes: _planNotes,
              onAdd: () => _openNotesEditor(),
              onEdit: (i) => _openNotesEditor(editingIndex: i),
              onRemove: _removeNoteAt,
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, color: _kBorder),
            const SizedBox(height: 14),
            CoButton(
              onPressed: _pickAndParseFile,
              label: _parsed == null
                  ? 'Upload file'
                  : 'Choose new file',
              icon: Icons.upload_file_outlined,
              variant: CoButtonVariant.secondaryOutlined,
              fullWidth: true,
            ),
            if (_publishBlockedReason() != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _publishBlockedReason()!,
                        style: AppTypography.caption1.copyWith(
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _rightInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body.copyWith(
        color: AppColors.labelHintLight,
      ),
      filled: true,
      fillColor: _kSoft,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.codriverGreen,
          width: 1.4,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   HEADER
// ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    this.publishedAt,
    this.isPastOrToday = false,
    this.lateCancelCount = 0,
    this.canPublish = false,
    this.publishing = false,
    this.publishLabel = 'Publish',
    this.onPublish,
    this.canClear = false,
    this.onClear,
    this.canUnpublish = false,
    this.onUnpublish,
    required this.selectedDate,
    required this.onDateChanged,
    this.blockedReason,
    this.softWarning,
  });

  final DateTime? publishedAt;
  final bool isPastOrToday;
  final int lateCancelCount;
  final bool canPublish;
  final bool publishing;
  final String publishLabel;
  final VoidCallback? onPublish;
  final bool canClear;
  final VoidCallback? onClear;
  final bool canUnpublish;
  final VoidCallback? onUnpublish;

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  /// Reason the publish button is hard-disabled. Renders as a yellow
  /// inline pill above the Publish action so the admin never wonders
  /// why the button is greyed out.
  final String? blockedReason;

  /// Soft, override-able warning (e.g. 19:00 window). Doesn't disable
  /// the button — surfaced as an amber pill.
  final String? softWarning;

  /// ISO week number for the selected date (KW). Standard German
  /// calendar week — Thursday rule.
  int _isoWeek(DateTime d) {
    final thursday = d.add(Duration(days: 4 - d.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    return ((thursday.difference(firstThursday).inDays) ~/ 7) + 1;
  }

  String _formatDate(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _fmt(DateTime d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.day)}.${pad(d.month)}.${d.year} ${pad(d.hour)}:${pad(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: _AdminShiftPlanPageState._kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AdminShiftPlanPageState._kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Shift Plan',
                  style: AppTypography.title2.copyWith(
                    color: _AdminShiftPlanPageState._kText,
                  ),
                ),
                Text(
                  'KW ${_isoWeek(selectedDate)} · '
                  '${selectedDate.year} · '
                  '${_formatDate(selectedDate)}',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.codriverDeep,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
          if (publishedAt != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.codriverGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_done_rounded,
                    size: 16,
                    color: AppColors.codriverDeep,
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Uploaded',
                        style: AppTypography.caption2.copyWith(
                          color: _AdminShiftPlanPageState._kMuted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        _fmt(publishedAt!),
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.codriverDeep,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (isPastOrToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFFCD34D),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history_edu_rounded,
                    size: 14,
                    color: Color(0xFF92400E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'With audit',
                    style: AppTypography.caption2.copyWith(
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (lateCancelCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFFCA5A5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cancel_outlined,
                    size: 14,
                    color: Color(0xFFB91C1C),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$lateCancelCount Cuts',
                    style: AppTypography.caption2.copyWith(
                      color: const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── Publish / Unpublish / Clear actions (top-right) ─────
          if (blockedReason != null) ...[
            const SizedBox(width: 10),
            _ReasonPill(
              text: blockedReason!,
              tone: _ReasonTone.blocking,
            ),
          ] else if (softWarning != null) ...[
            const SizedBox(width: 10),
            _ReasonPill(
              text: softWarning!,
              tone: _ReasonTone.warning,
            ),
          ],
          if (onClear != null) ...[
            const SizedBox(width: 10),
            CoButton(
              onPressed: canClear ? onClear : null,
              label: 'Clear',
              icon: Icons.delete_sweep_outlined,
              variant: CoButtonVariant.destructiveQuiet,
            ),
          ],
          // Single Publish↔Unpublish toggle. While a doc is published
          // the button switches to the destructive Unpublish action;
          // otherwise it's the standard green Publish.
          if (onUnpublish != null && canUnpublish) ...[
            const SizedBox(width: 6),
            CoButton(
              onPressed: publishing ? null : onUnpublish,
              label: 'Unpublish',
              icon: Icons.cloud_off_outlined,
              variant: CoButtonVariant.destructive,
              busy: publishing,
            ),
          ] else if (onPublish != null) ...[
            const SizedBox(width: 6),
            CoButton(
              onPressed: !canPublish || publishing ? null : onPublish,
              label: publishLabel,
              icon: Icons.send_outlined,
              busy: publishing,
            ),
          ],
        ],
      ),
        ],
      ),
    );
  }
}

enum _ReasonTone { blocking, warning }

class _ReasonPill extends StatelessWidget {
  const _ReasonPill({required this.text, required this.tone});
  final String text;
  final _ReasonTone tone;

  @override
  Widget build(BuildContext context) {
    final isBlock = tone == _ReasonTone.blocking;
    final bg = isBlock
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFEF3C7);
    final fg = isBlock
        ? const Color(0xFFB91C1C)
        : const Color(0xFFB45309);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBlock
                  ? Icons.block_rounded
                  : Icons.warning_amber_rounded,
              size: 14,
              color: fg,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption2.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   KW (WEEK MODE) TOGGLE
// ──────────────────────────────────────────────────────────────────

class _KwToggle extends StatelessWidget {
  const _KwToggle({
    required this.active,
    required this.parsed,
    required this.onToggle,
  });

  final bool active;
  final ParsedShiftPlan? parsed;
  final VoidCallback onToggle;

  int _isoWeek(DateTime d) {
    final thursday = d.add(Duration(days: 4 - d.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final week = ((thursday.difference(firstThursday).inDays) ~/ 7) + 1;
    return week;
  }

  @override
  Widget build(BuildContext context) {
    final dates = parsed?.availableDateKeys ?? const <String>[];
    final kwLabel = dates.isEmpty
        ? 'KW'
        : 'KW ${_isoWeek(DateTime.parse(dates.first))}';
    return CoPressable(
      onTap: parsed == null ? null : onToggle,
      borderRadius: BorderRadius.circular(999),
      child: Material(
      color: active
          ? AppColors.codriverGreen
          : _AdminShiftPlanPageState._kSoft,
      shape: StadiumBorder(
        side: BorderSide(
          color: active
              ? AppColors.codriverGreen
              : _AdminShiftPlanPageState._kBorder,
        ),
      ),
      child: InkWell(
        onTap: parsed == null ? null : onToggle,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.view_week_rounded,
                size: 18,
                color: active
                    ? Colors.white
                    : _AdminShiftPlanPageState._kText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      kwLabel,
                      style: AppTypography.subheadline.copyWith(
                        color: active
                            ? Colors.white
                            : _AdminShiftPlanPageState._kText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      active
                          ? 'Publish whole week'
                          : 'Just this day',
                      style: AppTypography.caption2.copyWith(
                        color: active
                            ? Colors.white.withValues(alpha: 0.85)
                            : _AdminShiftPlanPageState._kMuted,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 18,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.3)
                      : _AdminShiftPlanPageState._kBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  alignment: active
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
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

// ──────────────────────────────────────────────────────────────────
//   RIGHT COLUMN LABEL
// ──────────────────────────────────────────────────────────────────

class _RightLabel extends StatelessWidget {
  const _RightLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.codriverDeep),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTypography.caption2.copyWith(
            color: _AdminShiftPlanPageState._kMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   TIME GROUP HEADER (minimal divider with label)
// ──────────────────────────────────────────────────────────────────

class _TimeGroupHeader extends StatelessWidget {
  const _TimeGroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: _AdminShiftPlanPageState._kMuted,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Divider(
              height: 1,
              color: _AdminShiftPlanPageState._kBorder,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   AVAILABLE POOL (left column)
// ──────────────────────────────────────────────────────────────────

class _AvailablePool extends StatelessWidget {
  const _AvailablePool({required this.drivers});
  final List<ShiftRoster> drivers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 18,
                color: _AdminShiftPlanPageState._kText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Available',
                  style: AppTypography.subheadline.copyWith(
                    color: _AdminShiftPlanPageState._kText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _AdminShiftPlanPageState._kSoft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _AdminShiftPlanPageState._kBorder,
                  ),
                ),
                child: Text(
                  '${drivers.length}',
                  style: AppTypography.caption2.copyWith(
                    color: _AdminShiftPlanPageState._kMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CoStateSwitcher(
            child: drivers.isEmpty
                ? const Center(
                    key: ValueKey('pool-empty'),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'All drivers assigned.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _AdminShiftPlanPageState._kMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    key: const ValueKey('pool-list'),
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
                    itemCount: drivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (ctx, i) {
                      final d = drivers[i];
                      return Draggable<ShiftRoster>(
                        data: d,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _PoolPill(driver: d, elevated: true),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.35,
                          child: _PoolPill(driver: d),
                        ),
                        child: _PoolPill(driver: d),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _PoolPill extends StatelessWidget {
  const _PoolPill({required this.driver, this.elevated = false});
  final ShiftRoster driver;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _AdminShiftPlanPageState._kBorder),
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x22111827),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.codriverGreen,
            child: Icon(
              Icons.person_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              driver.driverName.isEmpty ? '—' : driver.driverName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption1.copyWith(
                color: _AdminShiftPlanPageState._kText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   ASSIGNMENT ROW (single line)
// ──────────────────────────────────────────────────────────────────

class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow({
    required this.entry,
    required this.parkingOffsetMinutes,
    required this.onTap,
    required this.onClearDriver,
    required this.onDropDriver,
  });

  final ShiftPlanEntry entry;

  /// Doc-level offset between meeting (parking) and dispatch start in
  /// minutes. Each block's pill renders `Meeting HH:mm · Dispatch HH:mm`
  /// where Meeting = block.startTime − parkingOffsetMinutes.
  final int parkingOffsetMinutes;
  final VoidCallback onTap;
  final VoidCallback onClearDriver;
  final ValueChanged<ShiftRoster> onDropDriver;

  /// Subtract [parkingOffsetMinutes] from a HH:mm or h:mm[am|pm] time
  /// string. Returns empty when input can't be parsed.
  String _meetingFor(String dispatch) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)?',
            caseSensitive: false)
        .firstMatch(dispatch.trim());
    if (m == null) return '';
    var h = int.tryParse(m.group(1) ?? '0') ?? 0;
    final mins = int.tryParse(m.group(2) ?? '0') ?? 0;
    final suf = (m.group(3) ?? '').toLowerCase();
    if (suf == 'pm' && h < 12) h += 12;
    if (suf == 'am' && h == 12) h = 0;
    final total = h * 60 + mins - parkingOffsetMinutes;
    if (total < 0) return '';
    final hh = (total ~/ 60).toString().padLeft(2, '0');
    final mm = (total % 60).toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Color get _kindColor {
    switch (entry.kind) {
      case ShiftKind.rescue:
        return const Color(0xFFD97706);
      case ShiftKind.extra:
        return const Color(0xFF1D4ED8);
      case ShiftKind.regular:
        return AppColors.codriverGreen;
    }
  }

  String get _kindLabel {
    switch (entry.kind) {
      case ShiftKind.rescue:
        return 'Rescue';
      case ShiftKind.extra:
        return 'Extra';
      case ShiftKind.regular:
        return 'Regular';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDriver = entry.transporterId.trim().isNotEmpty;
    final hasMentee = entry.hasMentee;
    final hasBlocks = entry.blocks.isNotEmpty;
    // Combined service-type label across all blocks (e.g.
    // "Sameday Parcel + Multiuse"). Dedup to avoid noise when two
    // blocks share the same service.
    final services = <String>[];
    final seen = <String>{};
    for (final b in entry.blocks) {
      final s = b.serviceType.trim();
      if (s.isEmpty) continue;
      if (seen.add(s.toLowerCase())) services.add(s);
    }
    final serviceLabel = services.join(' + ');
    return DragTarget<ShiftRoster>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => onDropDriver(d.data),
      builder: (context, candidate, _) {
        final hovered = candidate.isNotEmpty;
        final borderColor = hovered
            ? AppColors.codriverGreen
            : hasMentee
                ? const Color(0xFF0A84FF)
                : _AdminShiftPlanPageState._kBorder;
        return Material(
          color: hovered
              ? AppColors.green50
              : _AdminShiftPlanPageState._kSoft,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor,
              width: (hovered || hasMentee) ? 1.4 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
              child: Row(
                children: [
                  // Left colour bar
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _kindColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name (flex-grows) — with optional mentee pill below.
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasDriver
                              ? entry.driverName
                              : 'Empty slot · drop a driver here',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subheadline.copyWith(
                            color: hasDriver
                                ? _AdminShiftPlanPageState._kText
                                : _AdminShiftPlanPageState._kMuted,
                            fontWeight: FontWeight.w800,
                            fontStyle: hasDriver
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                        if (hasMentee)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.school_rounded,
                                  size: 11,
                                  color: Color(0xFF0A84FF),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    entry.menteeName.isNotEmpty
                                        ? entry.menteeName
                                        : entry.menteeTransporterId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption2.copyWith(
                                      color: const Color(0xFF0A84FF),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasBlocks) ...[
                    // One paired pill per shift block:
                    //   Meeting HH:mm · Dispatch HH:mm
                    // Stays single-line via Wrap; multi-shift drivers
                    // get two pairs side by side.
                    Flexible(
                      flex: 6,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final b in entry.blocks)
                            _MeetingDispatchPair(
                              meeting: _meetingFor(b.startTime),
                              dispatch: b.startTime,
                            ),
                          if (serviceLabel.isNotEmpty)
                            ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 200),
                              child: Text(
                                serviceLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption1.copyWith(
                                  color:
                                      _AdminShiftPlanPageState._kMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else
                    const Spacer(flex: 4),
                  // Personal notes indicator
                  if (entry.personalNotes.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Tooltip(
                        message: entry.personalNotes,
                        child: const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 18,
                          color: AppColors.codriverDeep,
                        ),
                      ),
                    ),
                  // Audit-trail indicator
                  if (entry.auditTrail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Tooltip(
                        message: entry.auditTrail
                            .reversed
                            .take(3)
                            .map((e) => e.describe())
                            .join('\n'),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  if (entry.lateCancel) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Cut · Late Cancel',
                        style: AppTypography.caption2.copyWith(
                          color: const Color(0xFFB91C1C),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _kindColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _kindLabel,
                      style: AppTypography.caption2.copyWith(
                        color: _kindColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  if (hasDriver)
                    IconButton(
                      onPressed: onClearDriver,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: _AdminShiftPlanPageState._kMuted,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      tooltip: 'Remove driver — slot stays empty',
                    )
                  else
                    const SizedBox(width: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pairs the Meeting (parking arrival) time with the Dispatch start
/// time for one shift block. Two micro-pills side by side, separated
/// by an arrow — keeps every row single-line even when a driver has
/// two shifts in the day.
class _MeetingDispatchPair extends StatelessWidget {
  const _MeetingDispatchPair({
    required this.meeting,
    required this.dispatch,
  });

  final String meeting;
  final String dispatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _AdminShiftPlanPageState._kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (meeting.isNotEmpty) ...[
            const Icon(
              Icons.local_parking_rounded,
              size: 11,
              color: AppColors.codriverDeep,
            ),
            const SizedBox(width: 3),
            Text(
              meeting,
              style: AppTypography.caption2.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 10,
              color: _AdminShiftPlanPageState._kMuted,
            ),
            const SizedBox(width: 6),
          ],
          const Icon(
            Icons.directions_car_rounded,
            size: 11,
            color: AppColors.codriverGreen,
          ),
          const SizedBox(width: 3),
          Text(
            dispatch,
            style: AppTypography.caption2.copyWith(
              color: _AdminShiftPlanPageState._kText,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   ENTRY EDITOR DIALOG  (click row → personal notes + kind switch)
// ──────────────────────────────────────────────────────────────────

class _EntryEditorResult {
  const _EntryEditorResult({this.updated, this.deleteSlot = false});
  final ShiftPlanEntry? updated;
  final bool deleteSlot;
}

class _EntryEditorDialog extends StatefulWidget {
  const _EntryEditorDialog({
    required this.entry,
    required this.roster,
    required this.inUseTids,
    required this.ownTransporterId,
  });

  final ShiftPlanEntry entry;
  final List<ShiftRoster> roster;
  final Set<String> inUseTids;
  final String ownTransporterId;

  @override
  State<_EntryEditorDialog> createState() => _EntryEditorDialogState();
}

class _EntryEditorDialogState extends State<_EntryEditorDialog> {
  late final TextEditingController _notes;
  late final TextEditingController _meet;
  late final TextEditingController _lcReason;
  late ShiftKind _kind;
  String _menteeTid = '';
  String _menteeName = '';
  late bool _lateCancel;

  @override
  void initState() {
    super.initState();
    _notes = TextEditingController(text: widget.entry.personalNotes);
    _meet = TextEditingController(text: widget.entry.meetingTime);
    _lcReason =
        TextEditingController(text: widget.entry.lateCancelReason);
    _kind = widget.entry.kind;
    _menteeTid = widget.entry.menteeTransporterId;
    _menteeName = widget.entry.menteeName;
    _lateCancel = widget.entry.lateCancel;
  }

  @override
  void dispose() {
    _notes.dispose();
    _meet.dispose();
    _lcReason.dispose();
    super.dispose();
  }

  Future<void> _pickMentee() async {
    final result = await showDialog<ShiftRoster?>(
      context: context,
      builder: (ctx) => _MenteePickerDialog(
        roster: widget.roster,
        disabledTids: {
          ...widget.inUseTids,
          widget.ownTransporterId.trim().toUpperCase(),
        },
        currentMenteeTid: _menteeTid,
      ),
    );
    if (result == null) return;
    setState(() {
      _menteeTid = result.transporterId;
      _menteeName = result.driverName;
    });
  }

  void _removeMentee() {
    setState(() {
      _menteeTid = '';
      _menteeName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasDriver = widget.entry.transporterId.trim().isNotEmpty;
    final hasMentee = _menteeTid.trim().isNotEmpty;
    final canDeleteSlot = widget.entry.kind != ShiftKind.regular ||
        widget.entry.blocks.isEmpty;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
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
                    child: const Icon(
                      Icons.person_rounded,
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
                          hasDriver
                              ? widget.entry.driverName
                              : 'Manual slot',
                          style: AppTypography.title3.copyWith(
                            color: _AdminShiftPlanPageState._kText,
                          ),
                        ),
                        if (hasDriver)
                          Text(
                            widget.entry.transporterId,
                            style: AppTypography.caption2.copyWith(
                              color: _AdminShiftPlanPageState._kMuted,
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EditorLabel('Shift kind (internal only)'),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final k in ShiftKind.values)
                            ChoiceChip(
                              label: Text(
                                k == ShiftKind.regular
                                    ? 'Regular'
                                    : k == ShiftKind.rescue
                                        ? 'Rescue'
                                        : 'Extra',
                              ),
                              selected: _kind == k,
                              onSelected: (_) => setState(() {
                                _kind = k;
                                // Late Cancel ist Amazon-Bezahllogik
                                // nur für reguläre Schichten. Wenn der
                                // Admin den Typ ändert, wird die
                                // Markierung automatisch entfernt.
                                if (k != ShiftKind.regular) {
                                  _lateCancel = false;
                                }
                              }),
                              selectedColor: AppColors.codriverGreen,
                              backgroundColor:
                                  _AdminShiftPlanPageState._kSoft,
                              side: BorderSide(
                                color: _kind == k
                                    ? AppColors.codriverGreen
                                    : _AdminShiftPlanPageState._kBorder,
                              ),
                              labelStyle: AppTypography.caption1.copyWith(
                                color: _kind == k
                                    ? Colors.white
                                    : _AdminShiftPlanPageState._kText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _EditorLabel(
                        'Meeting time '
                        '(overrides the global time, optional)',
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _meet,
                        decoration: const InputDecoration(
                          hintText: 'z.B. 10:10',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _EditorLabel('Ride Along'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: hasMentee
                              ? const Color(0xFFE7F1FE)
                              : _AdminShiftPlanPageState._kSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasMentee
                                ? const Color(0xFF0A84FF)
                                : _AdminShiftPlanPageState._kBorder,
                            width: hasMentee ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0A84FF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.school_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: hasMentee
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _menteeName.isEmpty
                                              ? _menteeTid
                                              : _menteeName,
                                          style: AppTypography.subheadline
                                              .copyWith(
                                            color: _AdminShiftPlanPageState
                                                ._kText,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _menteeTid,
                                          style: AppTypography.caption2
                                              .copyWith(
                                            color: _AdminShiftPlanPageState
                                                ._kMuted,
                                            fontFamily: 'monospace',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'No ride along assigned',
                                      style: AppTypography.caption1
                                          .copyWith(
                                        color: _AdminShiftPlanPageState
                                            ._kMuted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                            ),
                            if (hasMentee)
                              CoButton(
                                onPressed: _removeMentee,
                                label: 'Remove',
                                variant:
                                    CoButtonVariant.destructiveQuiet,
                              ),
                            const SizedBox(width: 4),
                            CoButton(
                              onPressed: _pickMentee,
                              label: hasMentee ? 'Change' : 'Choose',
                              variant: CoButtonVariant.secondaryOutlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _EditorLabel(
                        'Personal note '
                        '(only this driver sees it)',
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _notes,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'e.g. Pick up badge at security 10:10\n'
                              'Don\'t forget the keys',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (_kind == ShiftKind.regular) ...[
                        const SizedBox(height: 14),
                        _LateCancelSection(
                          active: _lateCancel,
                          reasonCtrl: _lcReason,
                          onToggle: () => setState(
                            () => _lateCancel = !_lateCancel,
                          ),
                        ),
                      ],
                      if (widget.entry.auditTrail.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _EditorLabel('Edit history'),
                        const SizedBox(height: 6),
                        _AuditTrailList(
                          events: widget.entry.auditTrail,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (canDeleteSlot)
                    CoButton(
                      onPressed: () => Navigator.of(context).pop(
                        const _EntryEditorResult(deleteSlot: true),
                      ),
                      label: 'Delete slot',
                      icon: Icons.delete_outline,
                      variant: CoButtonVariant.destructiveQuiet,
                    ),
                  const Spacer(),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'Cancel',
                    variant: CoButtonVariant.quiet,
                  ),
                  const SizedBox(width: 6),
                  CoButton(
                    onPressed: () {
                      final isRegular = _kind == ShiftKind.regular;
                      Navigator.of(context).pop(
                        _EntryEditorResult(
                          updated: widget.entry.copyWith(
                            personalNotes: _notes.text.trim(),
                            meetingTime: _meet.text.trim(),
                            kind: _kind,
                            menteeTransporterId: _menteeTid,
                            menteeName: _menteeName,
                            // Late Cancel ist nur für reguläre
                            // Schichten Amazon-bezahlbar — Rescue /
                            // Extra-Slots können das Flag nicht setzen.
                            lateCancel: isRegular && _lateCancel,
                            lateCancelReason:
                                (isRegular && _lateCancel)
                                    ? _lcReason.text.trim()
                                    : '',
                          ),
                        ),
                      );
                    },
                    label: 'Save',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorLabel extends StatelessWidget {
  const _EditorLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption2.copyWith(
        color: _AdminShiftPlanPageState._kMuted,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   LATE CANCEL SECTION  (editor dialog)
// ──────────────────────────────────────────────────────────────────

class _LateCancelSection extends StatelessWidget {
  const _LateCancelSection({
    required this.active,
    required this.reasonCtrl,
    required this.onToggle,
  });

  final bool active;
  final TextEditingController reasonCtrl;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFEE2E2)
            : _AdminShiftPlanPageState._kSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? const Color(0xFFFCA5A5)
              : _AdminShiftPlanPageState._kBorder,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 18,
                color: active
                    ? const Color(0xFFB91C1C)
                    : _AdminShiftPlanPageState._kMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mark as Cut · Late Cancel',
                      style: AppTypography.subheadline.copyWith(
                        color: active
                            ? const Color(0xFFB91C1C)
                            : _AdminShiftPlanPageState._kText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Tour was confirmed in last night\'s plan but cancelled today.',
                      style: AppTypography.caption2.copyWith(
                        color: _AdminShiftPlanPageState._kMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: active,
                activeThumbColor: const Color(0xFFB91C1C),
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: active
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextField(
                      controller: reasonCtrl,
                      decoration: InputDecoration(
                        hintText:
                            'Reason · e.g. Sickness 06:30',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: const Color(0xFFFCA5A5)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: const Color(0xFFFCA5A5)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFB91C1C),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   AUDIT TRAIL LIST  (editor dialog)
// ──────────────────────────────────────────────────────────────────

class _AuditTrailList extends StatelessWidget {
  const _AuditTrailList({required this.events});
  final List<AuditEvent> events;

  @override
  Widget build(BuildContext context) {
    final reversed = events.reversed.toList();
    return Container(
      decoration: BoxDecoration(
        color: _AdminShiftPlanPageState._kSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AdminShiftPlanPageState._kBorder),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < reversed.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.history_rounded,
                      size: 14,
                      color: _AdminShiftPlanPageState._kMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reversed[i].describe(),
                      style: AppTypography.caption1.copyWith(
                        color: _AdminShiftPlanPageState._kText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < reversed.length - 1)
              const Divider(
                height: 1,
                color: _AdminShiftPlanPageState._kBorder,
              ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   MENTEE PICKER DIALOG
// ──────────────────────────────────────────────────────────────────

class _MenteePickerDialog extends StatefulWidget {
  const _MenteePickerDialog({
    required this.roster,
    required this.disabledTids,
    required this.currentMenteeTid,
  });

  final List<ShiftRoster> roster;
  final Set<String> disabledTids;
  final String currentMenteeTid;

  @override
  State<_MenteePickerDialog> createState() => _MenteePickerDialogState();
}

class _MenteePickerDialogState extends State<_MenteePickerDialog> {
  final TextEditingController _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cleanQ = _query.trim().toLowerCase();
    final filtered = widget.roster.where((r) {
      final tid = r.transporterId.trim().toUpperCase();
      final isCurrent = widget.currentMenteeTid
              .trim()
              .toUpperCase() ==
          tid;
      if (widget.disabledTids.contains(tid) && !isCurrent) return false;
      if (cleanQ.isEmpty) return true;
      return r.driverName.toLowerCase().contains(cleanQ) ||
          tid.toLowerCase().contains(cleanQ);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          'Choose ride along',
                          style: AppTypography.title3.copyWith(
                            color: _AdminShiftPlanPageState._kText,
                          ),
                        ),
                        Text(
                          'Only drivers not already in the plan.',
                          style: AppTypography.footnote.copyWith(
                            color: _AdminShiftPlanPageState._kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: _AdminShiftPlanPageState._kMuted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _q,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search name or TID…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: _AdminShiftPlanPageState._kSoft,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: _AdminShiftPlanPageState._kBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: _AdminShiftPlanPageState._kBorder,
                    ),
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No matching drivers.',
                            style: AppTypography.body.copyWith(
                              color: _AdminShiftPlanPageState._kMuted,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: _AdminShiftPlanPageState._kBorder,
                        ),
                        itemBuilder: (ctx, i) {
                          final r = filtered[i];
                          final isCurrent = widget.currentMenteeTid
                                  .trim()
                                  .toUpperCase() ==
                              r.transporterId.trim().toUpperCase();
                          return CoPressable(
                            onTap: () => Navigator.of(context).pop(r),
                            child: InkWell(
                            onTap: () => Navigator.of(context).pop(r),
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
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE7F1FE),
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
                                          r.driverName.isNotEmpty
                                              ? r.driverName
                                              : '— no name —',
                                          style: AppTypography.subheadline
                                              .copyWith(
                                            color:
                                                _AdminShiftPlanPageState
                                                    ._kText,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          r.transporterId,
                                          style: AppTypography.caption2
                                              .copyWith(
                                            fontFamily: 'monospace',
                                            color:
                                                _AdminShiftPlanPageState
                                                    ._kMuted,
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

// ──────────────────────────────────────────────────────────────────
//   UPLOAD LOADING DIALOG
// ──────────────────────────────────────────────────────────────────

class _UploadLoadingCard extends StatelessWidget {
  const _UploadLoadingCard({this.phase = ''});

  /// One of: 'Reading file…', 'Parsing rows…', 'Grouping by day…'.
  /// Empty falls back to the generic message.
  final String phase;

  @override
  Widget build(BuildContext context) {
    final detail = phase.isNotEmpty
        ? phase
        : 'Parsing the file and grouping by day.';
    return Container(
      width: 340,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing brand-coloured ring around the spinner — gives a
          // stronger "in progress" cue than a bare indicator.
          Stack(
            alignment: Alignment.center,
            children: [
              const _PulseRing(),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.codriverGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Loading shift plan',
            style: AppTypography.headline.copyWith(
              color: _AdminShiftPlanPageState._kText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Text(
              detail,
              key: ValueKey(detail),
              textAlign: TextAlign.center,
              style: AppTypography.caption1.copyWith(
                color: _AdminShiftPlanPageState._kMuted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tiny three-dot indeterminate dots beneath the message.
          const _LoadingDots(),
        ],
      ),
    );
  }
}

/// Two concentric pulsing rings around the spinner. Used inside the
/// upload loading card to make the indeterminate progress feel alive.
class _PulseRing extends StatefulWidget {
  const _PulseRing();

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 2; i++)
                _ring(
                  progress: ((_ctrl.value + (i * 0.5)) % 1.0),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _ring({required double progress}) {
    final size = 56 + progress * 36;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.codriverGreen
              .withValues(alpha: opacity * 0.45),
          width: 2,
        ),
      ),
    );
  }
}

/// Three little dots that fade in and out in a wave — extra signal
/// that the work is still running even when the message text is
/// momentarily stable.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++) ...[
              _dot(((_ctrl.value + i * 0.18) % 1.0)),
              if (i < 2) const SizedBox(width: 6),
            ],
          ],
        );
      },
    );
  }

  Widget _dot(double phase) {
    final amp = (1.0 - (phase * 2 - 1).abs()).clamp(0.0, 1.0);
    final opacity = 0.25 + amp * 0.75;
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.codriverGreen.withValues(alpha: opacity),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   PUBLISH COUNTDOWN DIALOG
// ──────────────────────────────────────────────────────────────────

class _PublishCountdownDialog extends StatefulWidget {
  const _PublishCountdownDialog({required this.durationSeconds});
  final int durationSeconds;

  @override
  State<_PublishCountdownDialog> createState() =>
      _PublishCountdownDialogState();
}

class _PublishCountdownDialogState
    extends State<_PublishCountdownDialog> {
  late int _remaining;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) {
        _ticker?.cancel();
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _mmss {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.durationSeconds - _remaining) /
        widget.durationSeconds.clamp(1, 1 << 30);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('Publishing shortly'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'The shift plan will publish in $_mmss. '
            'You can still cancel before then.',
            style: AppTypography.body.copyWith(
              color: _AdminShiftPlanPageState._kText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.codriverGreen,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _mmss,
                    style: AppTypography.title1.copyWith(
                      color: _AdminShiftPlanPageState._kText,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'remaining',
                    style: AppTypography.caption2.copyWith(
                      color: _AdminShiftPlanPageState._kMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        CoButton(
          onPressed: () => Navigator.of(context).pop(false),
          label: 'Cancel',
          variant: CoButtonVariant.destructiveQuiet,
        ),
        CoButton(
          onPressed: () => Navigator.of(context).pop(true),
          label: 'Publish now',
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   TIME PICKER DIALOG  (for + Rescue / + Extra)
// ──────────────────────────────────────────────────────────────────

class _TimePickerDialog extends StatefulWidget {
  const _TimePickerDialog({
    required this.kind,
    required this.knownTimes,
  });

  final ShiftKind kind;
  final List<String> knownTimes;

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  String? _selectedKnown;
  TimeOfDay? _customTime;

  String _formatTimeOfDay(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickCustom() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _customTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _customTime = picked;
      _selectedKnown = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kindLabel = widget.kind == ShiftKind.rescue ? 'Rescue' : 'Extra';
    final accent = widget.kind == ShiftKind.rescue
        ? const Color(0xFFD97706)
        : const Color(0xFF1D4ED8);
    final accentBg = widget.kind == ShiftKind.rescue
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFE0E7FF);

    String? value() {
      if (_customTime != null) return _formatTimeOfDay(_customTime!);
      return _selectedKnown;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
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
                      color: accentBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.access_time_rounded,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$kindLabel · dispatch time',
                          style: AppTypography.title3.copyWith(
                            color: _AdminShiftPlanPageState._kText,
                          ),
                        ),
                        Text(
                          'Pick from existing times or set a custom time.',
                          style: AppTypography.caption1.copyWith(
                            color: _AdminShiftPlanPageState._kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (widget.knownTimes.isNotEmpty) ...[
                Text(
                  'EXISTING TIMES IN THIS PLAN',
                  style: AppTypography.caption2.copyWith(
                    color: _AdminShiftPlanPageState._kMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in widget.knownTimes)
                      ChoiceChip(
                        label: Text(t),
                        selected: _selectedKnown == t,
                        onSelected: (_) {
                          setState(() {
                            _selectedKnown = t;
                            _customTime = null;
                          });
                        },
                        selectedColor: accent,
                        backgroundColor:
                            _AdminShiftPlanPageState._kSoft,
                        side: BorderSide(
                          color: _selectedKnown == t
                              ? accent
                              : _AdminShiftPlanPageState._kBorder,
                        ),
                        labelStyle: AppTypography.caption1.copyWith(
                          color: _selectedKnown == t
                              ? Colors.white
                              : _AdminShiftPlanPageState._kText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'CUSTOM TIME',
                style: AppTypography.caption2.copyWith(
                  color: _AdminShiftPlanPageState._kMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              CoButton(
                onPressed: _pickCustom,
                label: _customTime != null
                    ? _formatTimeOfDay(_customTime!)
                    : 'Pick a custom time',
                icon: Icons.schedule_rounded,
                variant: CoButtonVariant.secondaryOutlined,
                fullWidth: true,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Spacer(),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'Cancel',
                    variant: CoButtonVariant.quiet,
                  ),
                  const SizedBox(width: 6),
                  CoButton(
                    onPressed: value() == null
                        ? null
                        : () => Navigator.of(context).pop(value()),
                    label: 'Add slot',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   DAY PICKER DIALOG  (after Excel upload)
// ──────────────────────────────────────────────────────────────────

class _DayPickerDialog extends StatefulWidget {
  const _DayPickerDialog({
    required this.availableKeys,
    required this.initialKey,
  });

  final List<String> availableKeys;
  final String initialKey;

  @override
  State<_DayPickerDialog> createState() => _DayPickerDialogState();
}

class _DayPickerDialogState extends State<_DayPickerDialog> {
  late String _selected = widget.initialKey;

  static const _weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  String _format(String key) {
    final d = DateTime.parse(key);
    final wd = _weekdays[d.weekday - 1];
    return '$wd ${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
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
                          'Pick a day to load',
                          style: AppTypography.title3.copyWith(
                            color: _AdminShiftPlanPageState._kText,
                          ),
                        ),
                        Text(
                          'The file spans the whole week — only the '
                          'chosen day is loaded into the planner.',
                          style: AppTypography.caption1.copyWith(
                            color: _AdminShiftPlanPageState._kMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final k in widget.availableKeys)
                    ChoiceChip(
                      label: Text(_format(k)),
                      selected: _selected == k,
                      onSelected: (_) => setState(() => _selected = k),
                      selectedColor: AppColors.codriverGreen,
                      backgroundColor: _AdminShiftPlanPageState._kSoft,
                      side: BorderSide(
                        color: _selected == k
                            ? AppColors.codriverGreen
                            : _AdminShiftPlanPageState._kBorder,
                      ),
                      labelStyle: AppTypography.caption1.copyWith(
                        color: _selected == k
                            ? Colors.white
                            : _AdminShiftPlanPageState._kText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Spacer(),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'Cancel',
                    variant: CoButtonVariant.quiet,
                  ),
                  const SizedBox(width: 6),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    label: 'Load day',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   NOTES BUTTON  (right-rail compact preview)
// ──────────────────────────────────────────────────────────────────

class _NotesSection extends StatelessWidget {
  const _NotesSection({
    required this.notes,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  final List<ShiftPlanNote> notes;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < notes.length; i++) ...[
          _NoteChip(
            note: notes[i],
            onTap: () => onEdit(i),
            onRemove: () => onRemove(i),
          ),
          const SizedBox(height: 6),
        ],
        // Add-button — switches between "Add a note" (empty list) and
        // a smaller "Add another note" once one is set.
        Material(
          color: notes.isEmpty
              ? _AdminShiftPlanPageState._kSoft
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _AdminShiftPlanPageState._kBorder,
            ),
          ),
          child: InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_comment_outlined,
                    size: 18,
                    color: _AdminShiftPlanPageState._kMuted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      notes.isEmpty
                          ? 'Add a note'
                          : 'Add another note',
                      style: AppTypography.subheadline.copyWith(
                        color: _AdminShiftPlanPageState._kText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: _AdminShiftPlanPageState._kMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One note chip in the right rail: shows the title (or body preview
/// if no title is set), with an X button to delete the note. Tap the
/// chip body to re-open the editor for that note.
class _NoteChip extends StatelessWidget {
  const _NoteChip({
    required this.note,
    required this.onTap,
    required this.onRemove,
  });

  final ShiftPlanNote note;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final title = note.title.trim().isNotEmpty
        ? note.title.trim()
        : 'Untitled note';
    final preview = note.body.trim().isNotEmpty
        ? note.body.trim().replaceAll('\n', ' · ')
        : '';
    return Material(
      color: AppColors.green50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.codriverGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (preview.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.codriverDeep
                                .withValues(alpha: 0.7),
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(6, 10, 10, 10),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.codriverDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
//   NOTES EDITOR DIALOG  (title + body + templates)
// ──────────────────────────────────────────────────────────────────

class _NotesEditorResult {
  const _NotesEditorResult({required this.title, required this.body});
  final String title;
  final String body;
}

class _NotesEditorDialog extends StatefulWidget {
  const _NotesEditorDialog({
    required this.initialTitle,
    required this.initialBody,
    required this.templatesStream,
    required this.onSaveTemplate,
    required this.onDeleteTemplate,
  });

  final String initialTitle;
  final String initialBody;
  final Stream<List<NoteTemplate>> templatesStream;
  final Future<void> Function(String title, String body) onSaveTemplate;
  final Future<void> Function(String templateId) onDeleteTemplate;

  @override
  State<_NotesEditorDialog> createState() => _NotesEditorDialogState();
}

class _NotesEditorDialogState extends State<_NotesEditorDialog> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  String? _appliedTemplateId;
  bool _savingTemplate = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle);
    _body = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _saveAsTemplate() async {
    final t = _title.text.trim();
    final b = _body.text.trim();
    if (t.isEmpty || b.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Title and body are required to save as template.',
          ),
        ),
      );
      return;
    }
    setState(() => _savingTemplate = true);
    try {
      await widget.onSaveTemplate(t, b);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.codriverDeep,
          content: Text(
            'Template "$t" saved.',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingTemplate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
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
                      Icons.sticky_note_2_rounded,
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
                          'Day notes',
                          style: AppTypography.title3.copyWith(
                            color: _AdminShiftPlanPageState._kText,
                          ),
                        ),
                        Text(
                          'Shown to every driver on this day.',
                          style: AppTypography.caption1.copyWith(
                            color: _AdminShiftPlanPageState._kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: _AdminShiftPlanPageState._kMuted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: 'Title (shown as preview)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: AppTypography.subheadline.copyWith(
                  color: _AdminShiftPlanPageState._kText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _body,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: AppTypography.body.copyWith(
                  color: _AdminShiftPlanPageState._kText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  CoButton(
                    onPressed: _savingTemplate ? null : _saveAsTemplate,
                    label: 'Save as template',
                    icon: Icons.bookmark_add_outlined,
                    variant: CoButtonVariant.secondaryOutlined,
                    busy: _savingTemplate,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'TEMPLATES',
                style: AppTypography.caption2.copyWith(
                  color: _AdminShiftPlanPageState._kMuted,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: StreamBuilder<List<NoteTemplate>>(
                  stream: widget.templatesStream,
                  builder: (context, snap) {
                    if (snap.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                AppColors.codriverGreen,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    final templates =
                        snap.data ?? const <NoteTemplate>[];
                    if (templates.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _AdminShiftPlanPageState._kSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _AdminShiftPlanPageState._kBorder,
                          ),
                        ),
                        child: Text(
                          'No templates yet. Save the current note '
                          'above to reuse it on other days.',
                          style: AppTypography.caption1.copyWith(
                            color: _AdminShiftPlanPageState._kMuted,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: templates.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 6),
                      itemBuilder: (ctx, i) {
                        final tpl = templates[i];
                        final isApplied =
                            tpl.id == _appliedTemplateId;
                        return _TemplateTile(
                          template: tpl,
                          applied: isApplied,
                          onApply: () {
                            setState(() {
                              _title.text = tpl.title;
                              _body.text = tpl.body;
                              _appliedTemplateId = tpl.id;
                            });
                          },
                          onDelete: () =>
                              widget.onDeleteTemplate(tpl.id),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CoButton(
                    onPressed: () {
                      setState(() {
                        _title.clear();
                        _body.clear();
                        _appliedTemplateId = null;
                      });
                    },
                    label: 'Clear',
                    variant: CoButtonVariant.destructiveQuiet,
                  ),
                  const Spacer(),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: 'Cancel',
                    variant: CoButtonVariant.quiet,
                  ),
                  const SizedBox(width: 6),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(
                      _NotesEditorResult(
                        title: _title.text,
                        body: _body.text,
                      ),
                    ),
                    label: 'Save',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.applied,
    required this.onApply,
    required this.onDelete,
  });

  final NoteTemplate template;
  final bool applied;
  final VoidCallback onApply;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: applied
          ? AppColors.green50
          : _AdminShiftPlanPageState._kSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: applied
              ? AppColors.codriverGreen.withValues(alpha: 0.4)
              : _AdminShiftPlanPageState._kBorder,
          width: applied ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onApply,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          child: Row(
            children: [
              Icon(
                applied
                    ? Icons.check_circle_rounded
                    : Icons.bookmark_rounded,
                size: 18,
                color: applied
                    ? AppColors.codriverGreen
                    : _AdminShiftPlanPageState._kMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      template.title.isNotEmpty
                          ? template.title
                          : '— no title —',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.subheadline.copyWith(
                        color: _AdminShiftPlanPageState._kText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (template.body.isNotEmpty)
                      Text(
                        template.body.replaceAll('\n', ' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption2.copyWith(
                          color: _AdminShiftPlanPageState._kMuted,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFB91C1C),
                tooltip: 'Delete template',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
