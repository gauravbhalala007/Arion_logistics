// lib/Screens/admin_flexplan_page.dart
//
// Admin-Seite "Flexplan": Schichten je Tag anlegen (Name + Zeiten, keine
// Kapazität), Monat für Minijobber zur Auswahl freigeben, Stundenlohn und
// Maximalverdienst pflegen (daraus wird das Stundenlimit exakt berechnet),
// Tagesübersicht der Meldungen sowie Storno-Anfragen entscheiden.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/flexplan_repository.dart';
import '../widgets/admin_scope.dart';

const _kBorder = Color(0xFFE5E7EB);
const _kMuted = Color(0xFF6B7280);
const _kText = Color(0xFF111827);
const _kGreen = Color(0xFF1D7F5A);
const _kGreenBg = Color(0xFFECFDF3);
const _kOrange = Color(0xFFB45309);
const _kOrangeBg = Color(0xFFFFF7ED);

const List<String> _kMonthsDe = [
  'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August',
  'September', 'Oktober', 'November', 'Dezember',
];
const List<String> _kMonthsEn = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];
const List<String> _kWeekdaysDe = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const List<String> _kWeekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class AdminFlexplanPage extends StatefulWidget {
  const AdminFlexplanPage({super.key});

  @override
  State<AdminFlexplanPage> createState() => _AdminFlexplanPageState();
}

class _AdminFlexplanPageState extends State<AdminFlexplanPage> {
  /// Erster Tag des angezeigten Monats. Planung passiert typischerweise
  /// für den Folgemonat — deshalb startet die Seite dort.
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month + 1, 1);
  }

  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String get _monthKey => FlexplanRepository.monthKeyOf(_month);

  String _monthLabel(DateTime m) =>
      '${(_de ? _kMonthsDe : _kMonthsEn)[m.month - 1]} ${m.year}';

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
        content: Text(message),
      ),
    );
  }

  // ── Monat freigeben + Flex-Fahrer benachrichtigen ──────────────────────

  Future<void> _openMonth(FlexplanRepository repo, FlexMonth month) async {
    final de = _de;
    if (month.days.isEmpty) {
      _snack(
        de
            ? 'Bitte zuerst Schichten anlegen, dann freigeben.'
            : 'Please create shifts before opening the month.',
        error: true,
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de ? 'Monat freigeben?' : 'Open month?'),
        content: Text(
          de
              ? 'Alle Flex-Plan-Fahrer werden benachrichtigt und können ab '
                  'sofort Schichten für ${_monthLabel(_month)} wählen.'
              : 'All flex plan drivers will be notified and can pick shifts '
                  'for ${_monthLabel(_month)} right away.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(de ? 'Freigeben' : 'Open'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await repo.monthRef(_monthKey).set({
      'monthKey': _monthKey,
      'status': 'open',
      'openedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final notified = await _notifyFlexDrivers();
    if (!mounted) return;
    _snack(
      de
          ? 'Monat freigegeben — $notified Flex-Fahrer benachrichtigt.'
          : 'Month opened — $notified flex drivers notified.',
    );
  }

  /// Schreibt jedem Flex-Plan-Fahrer eine Benachrichtigung ins bestehende
  /// Fahrer-Notification-System (users/{dsp}/drivers/{TID}/notifications).
  Future<int> _notifyFlexDrivers() async {
    final uid = _uid;
    if (uid == null) return 0;
    final label = _monthLabel(_month);
    final drivers = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .where('planType', isEqualTo: 'flex')
        .get();

    final db = FirebaseFirestore.instance;
    var batch = db.batch();
    var inBatch = 0;
    var total = 0;
    for (final d in drivers.docs) {
      if (d.data()['active'] == false) continue;
      final ref = d.reference.collection('notifications').doc();
      final titleDe = 'Flexplan $label ist offen';
      final titleEn = 'Flex plan $label is open';
      final bodyDe =
          'Du kannst jetzt deine Schichten für $label auswählen. '
          'Öffne dazu die Flexplan-Seite in der App.';
      final bodyEn =
          'You can now pick your shifts for $label. '
          'Open the flex plan page in the app.';
      batch.set(ref, {
        'notificationId': ref.id,
        'type': 'message',
        'title': _de ? titleDe : titleEn,
        'body': _de ? bodyDe : bodyEn,
        'sourceLang': _de ? 'de' : 'en',
        'translations': <String, dynamic>{
          'de': {'title': titleDe, 'body': bodyDe},
          'en': {'title': titleEn, 'body': bodyEn},
        },
        'status': 'unread',
        'readAt': null,
        'confirmedAt': null,
        'requiresConfirmation': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      total++;
      inBatch++;
      if (inBatch >= 450) {
        await batch.commit();
        batch = db.batch();
        inBatch = 0;
      }
    }
    if (inBatch > 0) await batch.commit();
    return total;
  }

  Future<void> _closeMonth(FlexplanRepository repo) async {
    await repo.monthRef(_monthKey).set({
      'monthKey': _monthKey,
      'status': 'closed',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _snack(_de ? 'Monat geschlossen.' : 'Month closed.');
  }

  // ── Lohn / Limit bearbeiten ────────────────────────────────────────────

  Future<void> _editLimits(FlexplanRepository repo, FlexMonth month) async {
    final de = _de;
    final wageCtrl = TextEditingController(
      text: month.hourlyWage.toStringAsFixed(2),
    );
    final maxCtrl = TextEditingController(
      text: month.maxEarnings.toStringAsFixed(2),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de ? 'Lohn & Limit' : 'Wage & limit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wageCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: de ? 'Stundenlohn (€)' : 'Hourly wage (€)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: de
                    ? 'Maximalverdienst pro Monat (€)'
                    : 'Max monthly earnings (€)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(de ? 'Speichern' : 'Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    double parse(String raw, double fallback) =>
        double.tryParse(raw.replaceAll(',', '.').trim()) ?? fallback;
    final wage = parse(wageCtrl.text, month.hourlyWage);
    final maxEarn = parse(maxCtrl.text, month.maxEarnings);
    if (wage <= 0 || maxEarn <= 0) {
      _snack(de ? 'Ungültige Werte.' : 'Invalid values.', error: true);
      return;
    }
    await repo.monthRef(_monthKey).set({
      'monthKey': _monthKey,
      'hourlyWage': wage,
      'maxMonthlyEarnings': maxEarn,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Schichten anlegen / löschen ────────────────────────────────────────

  Future<void> _addShift(
    FlexplanRepository repo,
    FlexMonth month,
    DateTime day,
  ) async {
    final de = _de;
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '08:00');
    final endCtrl = TextEditingController(text: '12:00');
    // 0 = nur dieser Tag, 1 = alle gleichen Wochentage, 2 = alle Tage.
    var applyMode = 0;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(
            de
                ? 'Schicht am ${day.day}.${day.month}. anlegen'
                : 'Add shift on ${day.day}.${day.month}.',
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: de ? 'Name (z. B. Frühschicht)' : 'Name',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startCtrl,
                        decoration: InputDecoration(
                          labelText: de ? 'Start (HH:mm)' : 'Start (HH:mm)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: endCtrl,
                        decoration: InputDecoration(
                          labelText: de ? 'Ende (HH:mm)' : 'End (HH:mm)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final (i, label) in [
                  de ? 'Nur dieser Tag' : 'This day only',
                  de
                      ? 'Alle ${_kWeekdaysDe[day.weekday - 1]}. im Monat'
                      : 'Every ${_kWeekdaysEn[day.weekday - 1]} this month',
                  de ? 'Jeden Tag im Monat' : 'Every day this month',
                ].indexed)
                  RadioListTile<int>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: i,
                    groupValue: applyMode,
                    onChanged: (v) => setLocal(() => applyMode = v ?? 0),
                    title: Text(label, style: const TextStyle(fontSize: 14)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(de ? 'Abbrechen' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(de ? 'Anlegen' : 'Add'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) return;

    final name = nameCtrl.text.trim();
    final start = startCtrl.text.trim();
    final end = endCtrl.text.trim();
    if (name.isEmpty || shiftMinutes(start, end) <= 0) {
      _snack(
        _de
            ? 'Bitte Name und gültige Zeiten (HH:mm) angeben.'
            : 'Please enter a name and valid times (HH:mm).',
        error: true,
      );
      return;
    }

    final targets = <DateTime>[];
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      final matches = switch (applyMode) {
        1 => date.weekday == day.weekday,
        2 => true,
        _ => d == day.day,
      };
      if (matches) targets.add(date);
    }

    final updates = <String, dynamic>{
      'monthKey': _monthKey,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    for (final date in targets) {
      final key = FlexplanRepository.dateKeyOf(date);
      final existing = month.days[key] ?? const <FlexShift>[];
      final shift = FlexShift(
        id: '${DateTime.now().microsecondsSinceEpoch}_${date.day}',
        name: name,
        start: start,
        end: end,
      );
      updates['days.$key'] = [
        for (final s in existing) s.toMap(),
        shift.toMap(),
      ];
    }
    await repo.monthRef(_monthKey).set({
      'monthKey': _monthKey,
      'status': month.status,
      'hourlyWage': month.hourlyWage,
      'maxMonthlyEarnings': month.maxEarnings,
    }, SetOptions(merge: true));
    await repo.monthRef(_monthKey).update(updates);
  }

  Future<void> _removeShift(
    FlexplanRepository repo,
    FlexMonth month,
    String dateKey,
    FlexShift shift,
  ) async {
    final remaining = (month.days[dateKey] ?? const <FlexShift>[])
        .where((s) => s.id != shift.id)
        .toList();
    await repo.monthRef(_monthKey).update({
      'days.$dateKey': [for (final s in remaining) s.toMap()],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Storno-Anfragen ────────────────────────────────────────────────────

  Future<void> _decideCancellation(
    FlexplanRepository repo,
    DocumentSnapshot<Map<String, dynamic>> request,
    bool approve,
  ) async {
    final de = _de;
    final uid = _uid;
    if (uid == null) return;
    try {
      await repo.decideCancellation(
        request: request,
        approve: approve,
        decidedBy: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
      // Fahrer informieren — gleiche Mechanik wie beim Abwesenheitsantrag.
      final data = request.data() ?? const <String, dynamic>{};
      final tid = (data['driverTransporterId'] ?? '').toString();
      final shiftName = (data['shiftName'] ?? '').toString();
      final date = (data['date'] ?? '').toString();
      if (tid.isNotEmpty) {
        final ref = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('drivers')
            .doc(tid.toUpperCase())
            .collection('notifications')
            .doc();
        final titleDe = approve ? 'Storno genehmigt' : 'Storno abgelehnt';
        final titleEn = approve
            ? 'Cancellation approved'
            : 'Cancellation rejected';
        final bodyDe = approve
            ? 'Deine Schicht "$shiftName" am $date wurde storniert.'
            : 'Deine Storno-Anfrage für "$shiftName" am $date wurde '
                'abgelehnt — die Schicht bleibt bestehen.';
        final bodyEn = approve
            ? 'Your shift "$shiftName" on $date has been cancelled.'
            : 'Your cancellation request for "$shiftName" on $date was '
                'rejected — the shift remains booked.';
        await ref.set({
          'notificationId': ref.id,
          'type': 'message',
          'title': de ? titleDe : titleEn,
          'body': de ? bodyDe : bodyEn,
          'sourceLang': de ? 'de' : 'en',
          'translations': <String, dynamic>{
            'de': {'title': titleDe, 'body': bodyDe},
            'en': {'title': titleEn, 'body': bodyEn},
          },
          'status': 'unread',
          'readAt': null,
          'confirmedAt': null,
          'requiresConfirmation': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      if (!mounted) return;
      _snack(
        approve
            ? (de ? 'Storno genehmigt.' : 'Cancellation approved.')
            : (de ? 'Storno abgelehnt.' : 'Cancellation rejected.'),
      );
    } catch (e) {
      _snack(
        de ? 'Fehler: $e' : 'Error: $e',
        error: true,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) return const Scaffold(body: SizedBox.shrink());
    final repo = FlexplanRepository(uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: StreamBuilder<FlexMonth>(
          stream: repo.watchMonth(_monthKey),
          builder: (context, monthSnap) {
            final month =
                monthSnap.data ?? FlexMonth.fromDoc(_monthKey, null);
            return StreamBuilder<List<FlexBooking>>(
              stream: repo.watchBookings(_monthKey),
              builder: (context, bookingsSnap) {
                final bookings = bookingsSnap.data ?? const <FlexBooking>[];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _header(repo, month, bookings),
                        const SizedBox(height: 12),
                        _cancellationsPanel(repo),
                        _driverTotalsPanel(month, bookings),
                        const SizedBox(height: 12),
                        _daysPanel(repo, month, bookings),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            );
          },
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

  Widget _header(
    FlexplanRepository repo,
    FlexMonth month,
    List<FlexBooking> bookings,
  ) {
    final de = _de;
    final maxMinutes = month.maxMinutes;
    final statusChip = switch (month.status) {
      'open' => _chip(de ? 'Offen' : 'Open', _kGreen, _kGreenBg),
      'closed' => _chip(de ? 'Geschlossen' : 'Closed', _kMuted,
          const Color(0xFFF3F4F6)),
      _ => _chip(de ? 'Entwurf' : 'Draft', _kOrange, _kOrangeBg),
    };

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Flexplan',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              statusChip,
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _shiftMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: de ? 'Vormonat' : 'Previous month',
              ),
              Text(
                _monthLabel(_month),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              IconButton(
                onPressed: () => _shiftMonth(1),
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: de ? 'Folgemonat' : 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Minijobber wählen selbst, welche der angelegten Schichten '
                    'sie übernehmen. Einmal gewählte Schichten können nur per '
                    'Storno-Anfrage zurückgegeben werden.'
                : 'Minijobbers pick which of the created shifts they take. '
                    'Booked shifts can only be returned via a cancellation '
                    'request.',
            style: const TextStyle(fontSize: 13, color: _kMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                onTap: () => _editLimits(repo, month),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.euro_rounded, size: 15, color: _kMuted),
                      const SizedBox(width: 6),
                      Text(
                        de
                            ? '${month.hourlyWage.toStringAsFixed(2)} €/h · '
                                'max. ${month.maxEarnings.toStringAsFixed(2)} € '
                                '→ ${formatMinutes(maxMinutes)}'
                            : '${month.hourlyWage.toStringAsFixed(2)} €/h · '
                                'max ${month.maxEarnings.toStringAsFixed(2)} € '
                                '→ ${formatMinutes(maxMinutes)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_outlined, size: 14, color: _kMuted),
                    ],
                  ),
                ),
              ),
              if (!month.isOpen)
                FilledButton.icon(
                  onPressed: () => _openMonth(repo, month),
                  icon: const Icon(Icons.campaign_rounded, size: 18),
                  label: Text(
                    de ? 'Monat freigeben' : 'Open month',
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => _closeMonth(repo),
                  icon: const Icon(Icons.lock_outline_rounded, size: 18),
                  label: Text(de ? 'Monat schließen' : 'Close month'),
                ),
              _chip(
                de
                    ? '${bookings.where((b) => b.entries.isNotEmpty).length} '
                        'Fahrer gemeldet'
                    : '${bookings.where((b) => b.entries.isNotEmpty).length} '
                        'drivers signed up',
                _kGreen,
                _kGreenBg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      );

  // Offene Storno-Anfragen (alle Monate, damit nichts untergeht).
  Widget _cancellationsPanel(FlexplanRepository repo) {
    final de = _de;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: repo.cancellationsCol
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kOrangeBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDBA74)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.undo_rounded, size: 18, color: _kOrange),
                    const SizedBox(width: 8),
                    Text(
                      de
                          ? 'Storno-Anfragen (${docs.length})'
                          : 'Cancellation requests (${docs.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _kOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final doc in docs) _cancellationRow(repo, doc),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cancellationRow(
    FlexplanRepository repo,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final de = _de;
    final d = doc.data();
    final name = (d['driverName'] ?? '').toString();
    final tid = (d['driverTransporterId'] ?? '').toString();
    final label =
        '${(d['date'] ?? '').toString()} · ${(d['shiftName'] ?? '').toString()} '
        '${(d['start'] ?? '').toString()}–${(d['end'] ?? '').toString()}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? tid : '$name ($tid)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: _kMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _decideCancellation(repo, doc, false),
            child: Text(de ? 'Ablehnen' : 'Reject'),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: () => _decideCancellation(repo, doc, true),
            child: Text(de ? 'Genehmigen' : 'Approve'),
          ),
        ],
      ),
    );
  }

  // Gebuchte Stunden je Fahrer inkl. Verdienst.
  Widget _driverTotalsPanel(FlexMonth month, List<FlexBooking> bookings) {
    final de = _de;
    final active = bookings.where((b) => b.entries.isNotEmpty).toList()
      ..sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));
    if (active.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              de ? 'Gebuchte Stunden je Fahrer' : 'Booked hours per driver',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            for (final b in active)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        b.driverName.isEmpty
                            ? b.driverTransporterId
                            : '${b.driverName} (${b.driverTransporterId})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kText,
                        ),
                      ),
                    ),
                    Text(
                      '${formatMinutes(b.totalMinutes)} · '
                      '${earningsForMinutes(b.totalMinutes, month.hourlyWage).toStringAsFixed(2)} € '
                      '/ ${formatMinutes(month.maxMinutes)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: b.totalMinutes >= month.maxMinutes
                            ? _kOrange
                            : _kMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Tage des Monats: Schichten pflegen + Meldungen sehen.
  Widget _daysPanel(
    FlexplanRepository repo,
    FlexMonth month,
    List<FlexBooking> bookings,
  ) {
    final de = _de;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    // dateKey → Liste "Fahrer · Schicht"
    final signupsByDay = <String, List<String>>{};
    for (final b in bookings) {
      for (final e in b.entries) {
        final who = b.driverName.isEmpty
            ? b.driverTransporterId
            : b.driverName;
        signupsByDay
            .putIfAbsent(e.date, () => [])
            .add('$who · ${e.name} ${e.start}–${e.end}');
      }
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            de ? 'Schichten & Meldungen je Tag' : 'Shifts & signups per day',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            de
                ? 'Je Tag nur die verschiedenen Schichten mit Name und Zeiten '
                    '— keine Anzahl.'
                : 'Per day just the different shifts with name and times — '
                    'no capacity.',
            style: const TextStyle(fontSize: 12.5, color: _kMuted),
          ),
          const SizedBox(height: 10),
          for (var d = 1; d <= daysInMonth; d++)
            _dayRow(
              repo,
              month,
              DateTime(_month.year, _month.month, d),
              signupsByDay,
            ),
        ],
      ),
    );
  }

  Widget _dayRow(
    FlexplanRepository repo,
    FlexMonth month,
    DateTime day,
    Map<String, List<String>> signupsByDay,
  ) {
    final de = _de;
    final key = FlexplanRepository.dateKeyOf(day);
    final shifts = month.days[key] ?? const <FlexShift>[];
    final signups = signupsByDay[key] ?? const <String>[];
    final weekend = day.weekday >= 6;
    final weekday =
        (de ? _kWeekdaysDe : _kWeekdaysEn)[day.weekday - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: weekend ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 74,
                child: Text(
                  '$weekday ${day.day.toString().padLeft(2, '0')}.'
                  '${day.month.toString().padLeft(2, '0')}.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: weekend ? _kMuted : _kText,
                  ),
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in shifts)
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                        decoration: BoxDecoration(
                          color: _kGreenBg,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFABEFC6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${s.name} ${s.start}–${s.end}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kGreen,
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  _removeShift(repo, month, key, s),
                              child: const Padding(
                                padding: EdgeInsets.all(3),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: _kGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    InkWell(
                      onTap: () => _addShift(repo, month, day),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                size: 14, color: _kMuted),
                            const SizedBox(width: 2),
                            Text(
                              de ? 'Schicht' : 'Shift',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (signups.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 74),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final s in signups)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D4ED8),
                        ),
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
