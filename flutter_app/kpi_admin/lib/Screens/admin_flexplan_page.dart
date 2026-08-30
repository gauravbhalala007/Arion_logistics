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
import '../utils/german_holidays.dart';
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
    if (month.shifts.isEmpty) {
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

  // ── Schichten anlegen / löschen (einmal je Monat, gelten Mo–Sa) ────────

  Future<void> _addShift(FlexplanRepository repo, FlexMonth month) async {
    final de = _de;
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '08:00');
    final endCtrl = TextEditingController(text: '12:00');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de ? 'Schicht anlegen' : 'Add shift'),
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
                      decoration: const InputDecoration(
                        labelText: 'Start (HH:mm)',
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
              const SizedBox(height: 10),
              Text(
                de
                    ? 'Gilt automatisch für jeden Tag des Monats außer '
                        'Sonntage und Feiertage '
                        '(${germanRegionName(month.region)}).'
                    : 'Automatically applies to every day of the month '
                        'except Sundays and public holidays '
                        '(${germanRegionName(month.region)}).',
                style: const TextStyle(fontSize: 12.5, color: _kMuted),
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

    final shift = FlexShift(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      start: start,
      end: end,
    );
    await repo.monthRef(_monthKey).set({
      'monthKey': _monthKey,
      'status': month.status,
      'hourlyWage': month.hourlyWage,
      'maxMonthlyEarnings': month.maxEarnings,
      'region': month.region,
      'shifts': [
        for (final s in month.shifts) s.toMap(),
        shift.toMap(),
      ],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _removeShift(
    FlexplanRepository repo,
    FlexMonth month,
    FlexShift shift,
  ) async {
    await repo.monthRef(_monthKey).set({
      'shifts': [
        for (final s in month.shifts)
          if (s.id != shift.id) s.toMap(),
      ],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _setRegion(FlexplanRepository repo, String region) async {
    await repo.monthRef(_monthKey).set({
      'monthKey': _monthKey,
      'region': region,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
                // Alle Fahrer mit planType == 'flex' — eigene Box rechts.
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('drivers')
                      .where('planType', isEqualTo: 'flex')
                      .snapshots(),
                  builder: (context, driversSnap) {
                    final flexDrivers = (driversSnap.data?.docs ?? const [])
                        .map((d) => (
                              tid: d.id,
                              name: (d.data()['driverName'] ?? '').toString(),
                              active: d.data()['active'] != false,
                            ))
                        .toList()
                      ..sort((a, b) => a.name.compareTo(b.name));

                    final mainList = ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _header(repo, month, bookings),
                        const SizedBox(height: 12),
                        _cancellationsPanel(repo),
                        _shiftsPanel(repo, month),
                        const SizedBox(height: 12),
                        _driverTotalsPanel(month, bookings),
                        _daysPanel(repo, month, bookings),
                        const SizedBox(height: 24),
                      ],
                    );

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 1000;
                        if (!wide) {
                          // Schmal: Box als Karte oberhalb der Tagesliste.
                          return Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 1040),
                              child: ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  _header(repo, month, bookings),
                                  const SizedBox(height: 12),
                                  _cancellationsPanel(repo),
                                  _flexDriversPanel(flexDrivers, bookings),
                                  const SizedBox(height: 12),
                                  _shiftsPanel(repo, month),
                                  const SizedBox(height: 12),
                                  _driverTotalsPanel(month, bookings),
                                  _daysPanel(repo, month, bookings),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1360),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: mainList),
                                SizedBox(
                                  width: 300,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 16, 16, 16),
                                    child: SingleChildScrollView(
                                      child: _flexDriversPanel(
                                          flexDrivers, bookings),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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
              // Bundesland — bestimmt, welche Feiertage schichtfrei sind.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: kGermanRegions
                            .any((r) => r.code == month.region)
                        ? month.region
                        : 'NW',
                    isDense: true,
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                    icon: const Icon(Icons.expand_more_rounded, size: 18),
                    items: [
                      for (final r in kGermanRegions)
                        DropdownMenuItem(
                          value: r.code,
                          child: Text(r.name),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) _setRegion(repo, v);
                    },
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
                    if (b.doubleLimitUnlocked)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _chip('2×', _kOrange, _kOrangeBg),
                      ),
                    Text(
                      '${formatMinutes(b.totalMinutes)} · '
                      '${earningsForMinutes(b.totalMinutes, month.hourlyWage).toStringAsFixed(2)} € '
                      '/ ${formatMinutes(b.maxMinutesFor(month))}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: b.totalMinutes >= b.maxMinutesFor(month)
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

  /// Eigene Box mit allen Flex-Fahrern (planType == 'flex') — inklusive
  /// gebuchter Stunden im angezeigten Monat, damit man sofort sieht,
  /// wer sich schon gemeldet hat.
  Widget _flexDriversPanel(
    List<({String tid, String name, bool active})> drivers,
    List<FlexBooking> bookings,
  ) {
    final de = _de;
    final minutesByTid = <String, int>{
      for (final b in bookings) b.driverTransporterId: b.totalMinutes,
    };
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, size: 18, color: _kGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  de
                      ? 'Flex-Fahrer (${drivers.length})'
                      : 'Flex drivers (${drivers.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            de
                ? 'Wird im Drivers Hub über das Fix/Flex-Pill gepflegt.'
                : 'Managed via the fix/flex pill in the Drivers Hub.',
            style: const TextStyle(fontSize: 11.5, color: _kMuted),
          ),
          const SizedBox(height: 10),
          if (drivers.isEmpty)
            Text(
              de ? 'Noch keine Flex-Fahrer.' : 'No flex drivers yet.',
              style: const TextStyle(fontSize: 12.5, color: _kMuted),
            ),
          for (final d in drivers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: d.active
                          ? const Color(0xFF34C759)
                          : const Color(0xFF9CA3AF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name.isEmpty ? d.tid : d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                        Text(
                          d.tid,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: _kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((minutesByTid[d.tid] ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kGreenBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        formatMinutes(minutesByTid[d.tid]!),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _kGreen,
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

  // Die einmal angelegten Schichten des Monats.
  Widget _shiftsPanel(FlexplanRepository repo, FlexMonth month) {
    final de = _de;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            de ? 'Schichten' : 'Shifts',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            de
                ? 'Einmal anlegen — gilt für jeden Tag des Monats außer '
                    'Sonntage und Feiertage in '
                    '${germanRegionName(month.region)}.'
                : 'Create once — applies to every day of the month except '
                    'Sundays and public holidays in '
                    '${germanRegionName(month.region)}.',
            style: const TextStyle(fontSize: 12.5, color: _kMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in month.shifts)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: _kGreenBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFABEFC6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${s.name} ${s.start}–${s.end} '
                        '(${formatMinutes(s.minutes)})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kGreen,
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeShift(repo, month, s),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 15,
                            color: _kGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => _addShift(repo, month),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(de ? 'Schicht anlegen' : 'Add shift'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tagesübersicht: wer hat sich für welchen Tag gemeldet; Sonntage und
  // Feiertage sind sichtbar gesperrt.
  Widget _daysPanel(
    FlexplanRepository repo,
    FlexMonth month,
    List<FlexBooking> bookings,
  ) {
    final de = _de;

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
            de ? 'Meldungen je Tag' : 'Signups per day',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
          const SizedBox(height: 10),
          for (var d = 1; d <= month.daysInMonth; d++)
            _dayRow(
              month,
              DateTime(_month.year, _month.month, d),
              signupsByDay,
            ),
        ],
      ),
    );
  }

  Widget _dayRow(
    FlexMonth month,
    DateTime day,
    Map<String, List<String>> signupsByDay,
  ) {
    final de = _de;
    final key = FlexplanRepository.dateKeyOf(day);
    final signups = signupsByDay[key] ?? const <String>[];
    final blocked = month.blockedReason(day);
    final weekday =
        (de ? _kWeekdaysDe : _kWeekdaysEn)[day.weekday - 1];

    final String? blockedLabel = blocked == null
        ? null
        : blocked == 'sunday'
            ? (de ? 'Sonntag — keine Schichten' : 'Sunday — no shifts')
            : (de ? 'Feiertag: $blocked' : 'Public holiday: $blocked');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: blocked != null ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              '$weekday ${day.day.toString().padLeft(2, '0')}.'
              '${day.month.toString().padLeft(2, '0')}.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: blocked != null ? _kMuted : _kText,
              ),
            ),
          ),
          Expanded(
            child: blocked != null
                ? Row(
                    children: [
                      Icon(
                        blocked == 'sunday'
                            ? Icons.weekend_outlined
                            : Icons.celebration_outlined,
                        size: 14,
                        color: _kMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          blockedLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: _kMuted,
                          ),
                        ),
                      ),
                    ],
                  )
                : signups.isEmpty
                    ? Text(
                        de ? 'Noch keine Meldungen' : 'No signups yet',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kMuted,
                        ),
                      )
                    : Wrap(
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
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
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
      ),
    );
  }
}
