// lib/Screens/admin_vehicle_check_page.dart
//
// Admin-Archiv der geführten Foto-Fahrzeuginspektion ("Vehicle Check").
//
// Beantwortet genau eine Frage pro Tag: WER hat den Fahrzeug-Check gemacht
// und wer nicht? Links „Erledigt", rechts „Offen", oben zwei Zählerkacheln
// und ein Suchfeld über beide Listen.
//
// ─────────────────────────────────────────────────────────────────────────
//  DATENQUELLEN (bewusst OHNE neue Firestore-Regel / CollectionGroup)
// ─────────────────────────────────────────────────────────────────────────
//
//  1. `users/{dspUid}/fleet_events` — der Server-Spiegel, den die Cloud
//     Function `onVehicleCheckCreated` pro Check schreibt (Feld `type` ==
//     [kVehicleCheckEventType]). Flach unter dem DSP und für Admins wie
//     Dispatcher lesbar. Abgefragt wird NUR über den Tages-Zeitraum auf
//     `date` (reiner Range-Filter → automatischer Einzelfeld-Index, kein
//     Composite-Index nötig); die Trennung von echten Unfall-Events
//     passiert clientseitig über `type`.
//
//  2. `users/{dspUid}/drivers/{TID}.lastVehicleCheck` — die Kurzfassung,
//     die der Fahrer beim Speichern selbst mitschreibt. Sie deckt die Zeit
//     VOR dem Deploy der Spiegel-Function ab (siehe [_kMirrorLiveSince])
//     und liefert zusätzlich `inspectionIssueCount`, das im Fleet-Event
//     nicht mitgespiegelt wird. Zusammengeführt wird über `checkId`.
//
//  Die Liste der aktiven Fahrer kommt wie überall aus
//  `users/{dspUid}/drivers` + `isDriverWorking(...)`.
//
//  Grenze: `lastVehicleCheck` kennt naturgemäß nur den JEWEILS LETZTEN
//  Check eines Fahrers. Für zurückliegende Tage ohne Fleet-Event kann
//  deshalb nur der letzte Check erkannt werden — darauf weist die Seite
//  im Hinweisstreifen offen hin.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/vehicle_check_service.dart'
    show kVehicleCheckEventType, fleetEventsCollection;
import '../utils/driver_activity.dart';
import '../widgets/admin_scope.dart';
import '../widgets/clearable_search_field.dart';
import 'admin_vehicle_check_detail_page.dart';

const Color _kPageBg = Color(0xFFF6F7F7);
const Color _kText = Color(0xFF111827);
const Color _kMuted = Color(0xFF6B7280);
const Color _kBorder = Color(0xFFE5E7EB);
const Color _kGreen = Color(0xFF067647);
const Color _kGreenSoft = Color(0xFFE6F8F2);
const Color _kAmber = Color(0xFFB45309);
const Color _kAmberSoft = Color(0xFFFEF3C7);
const Color _kRed = Color(0xFFB42318);

/// Ab diesem Tag spiegelt `onVehicleCheckCreated` jeden Check nach
/// `fleet_events`. Für frühere Tage ist das Archiv naturgemäß lückenhaft —
/// die Seite sagt das dem Admin, statt „0 erledigt" zu behaupten.
final DateTime _kMirrorLiveSince = DateTime(2026, 8, 25);

/// Ein Fahrer, der am gewählten Tag einen Check abgegeben hat.
class _DoneEntry {
  _DoneEntry({
    required this.transporterId,
    required this.driverName,
    required this.at,
    required this.plate,
    required this.checkPath,
    required this.checkId,
    required this.damageCount,
    required this.inspectionIssueCount,
    required this.fromMirror,
  });

  final String transporterId;
  String driverName;
  final DateTime at;
  String plate;
  String checkPath;
  final String checkId;
  int damageCount;

  /// Kommt nur aus `lastVehicleCheck` — das Fleet-Event spiegelt die
  /// Sichtprüfung nicht mit. `null` = unbekannt (nicht „0").
  int? inspectionIssueCount;

  /// `true`, wenn der Eintrag aus `fleet_events` stammt.
  final bool fromMirror;
}

/// Ein aktiver Fahrer ohne Check am gewählten Tag.
class _MissingEntry {
  const _MissingEntry({
    required this.transporterId,
    required this.driverName,
    required this.lastCheckAt,
  });

  final String transporterId;
  final String driverName;

  /// Zeitpunkt des zuletzt bekannten Checks (aus `lastVehicleCheck`).
  final DateTime? lastCheckAt;
}

class AdminVehicleCheckPage extends StatefulWidget {
  const AdminVehicleCheckPage({super.key});

  @override
  State<AdminVehicleCheckPage> createState() => _AdminVehicleCheckPageState();
}

class _AdminVehicleCheckPageState extends State<AdminVehicleCheckPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  late DateTime _day = _dateOnly(DateTime.now());

  // Memoisierte Streams: `snapshots()` liefert bei jedem Aufruf ein NEUES
  // Stream-Objekt — ohne Cache würde jeder setState die Listener neu
  // aufbauen (Flackern + unnötige Reads).
  String? _streamUid;
  DateTime? _streamDay;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _driversStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _eventsStream;

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String? get _uid => AdminScope.adminUidOf(context);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _isToday => _day == _dateOnly(DateTime.now());

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _ensureStreams(String uid) {
    if (_streamUid == uid && _streamDay == _day) return;
    _streamUid = uid;
    _streamDay = _day;
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    _driversStream = userRef.collection('drivers').snapshots();
    // Reiner Range-Filter auf EINEM Feld → automatischer Index. Die
    // Typ-Trennung (Check vs. Unfall) passiert unten im Code.
    _eventsStream = fleetEventsCollection(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_day))
        .where(
          'date',
          isLessThan: Timestamp.fromDate(_day.add(const Duration(days: 1))),
        )
        .snapshots();
  }

  void _shiftDay(int days) {
    final next = _dateOnly(_day.add(Duration(days: days)));
    if (next.isAfter(_dateOnly(DateTime.now()))) return;
    setState(() => _day = next);
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2024),
      lastDate: _dateOnly(DateTime.now()),
      helpText: _de ? 'Tag wählen' : 'Pick a day',
    );
    if (picked == null || !mounted) return;
    setState(() => _day = _dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final de = _de;
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      return Scaffold(
        backgroundColor: _kPageBg,
        body: Center(
          child: Text(de ? 'Bitte einloggen.' : 'Please sign in.'),
        ),
      );
    }
    _ensureStreams(uid);

    return Scaffold(
      backgroundColor: _kPageBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.sizeOf(context).width < 700 ? 14 : 20,
              18,
              MediaQuery.sizeOf(context).width < 700 ? 14 : 20,
              12,
            ),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _driversStream,
              builder: (context, driverSnap) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _eventsStream,
                  builder: (context, eventSnap) {
                    final loading =
                        driverSnap.connectionState == ConnectionState.waiting ||
                        eventSnap.connectionState == ConnectionState.waiting;
                    final (done, missing) = _buildRows(
                      driverDocs: driverSnap.data?.docs ??
                          const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
                      eventDocs: eventSnap.data?.docs ??
                          const <QueryDocumentSnapshot<Map<String, dynamic>>>[],
                    );
                    return _body(
                      de: de,
                      uid: uid,
                      loading: loading,
                      done: done,
                      missing: missing,
                      error: driverSnap.hasError || eventSnap.hasError,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Zusammenführung Fleet-Events + lastVehicleCheck
  // ═══════════════════════════════════════════════════════════════════════

  (List<_DoneEntry>, List<_MissingEntry>) _buildRows({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> driverDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> eventDocs,
  }) {
    final active = driverDocs
        .where((d) => isDriverWorking(d.data()))
        .toList(growable: false);

    String tidOf(Map<String, dynamic> data, String fallback) =>
        (data['transporterId'] ?? fallback).toString().trim().toUpperCase();

    final nameByTid = <String, String>{};
    for (final doc in active) {
      final data = doc.data();
      final tid = tidOf(data, doc.id);
      final name =
          (data['driverName'] ?? data['fullName'] ?? tid).toString().trim();
      nameByTid[tid] = name.isEmpty ? tid : name;
    }

    // ── 1. Spiegel-Events des Tages ──────────────────────────────────────
    final done = <String, _DoneEntry>{}; // key: TID
    for (final doc in eventDocs) {
      final data = doc.data();
      if ('${data['type'] ?? ''}'.trim() != kVehicleCheckEventType) continue;
      final at = (data['date'] as Timestamp?)?.toDate();
      if (at == null) continue;
      final tid = '${data['driverTransporterId'] ?? ''}'.trim().toUpperCase();
      if (tid.isEmpty) continue;
      final damage = data['damageCount'];
      final entry = _DoneEntry(
        transporterId: tid,
        driverName: '${data['driverName'] ?? ''}'.trim().isEmpty
            ? (nameByTid[tid] ?? tid)
            : '${data['driverName']}'.trim(),
        at: at,
        plate: '${data['plate'] ?? ''}'.trim(),
        checkPath: '${data['checkPath'] ?? ''}'.trim(),
        checkId: '${data['checkId'] ?? doc.id}'.trim(),
        damageCount: damage is num ? damage.toInt() : 0,
        inspectionIssueCount: null,
        fromMirror: true,
      );
      // Mehrere Checks am selben Tag (Schichtbeginn/-ende): der spätere
      // gewinnt die Kachel, gezählt wird der Fahrer trotzdem nur einmal.
      final existing = done[tid];
      if (existing == null || at.isAfter(existing.at)) done[tid] = entry;
    }

    // ── 2. Kurzfassung auf dem Fahrer-Dokument ───────────────────────────
    for (final doc in active) {
      final data = doc.data();
      final tid = tidOf(data, doc.id);
      final last = data['lastVehicleCheck'];
      if (last is! Map) continue;
      final at = (last['at'] as Timestamp?)?.toDate();
      if (at == null || _dateOnly(at) != _day) continue;

      final damage = last['damageCount'];
      final issues = last['inspectionIssueCount'];
      final existing = done[tid];
      if (existing != null) {
        // Ergänzt das Event um die Sichtprüfung, die dort fehlt.
        if (existing.checkId == '${last['checkId'] ?? ''}'.trim() ||
            existing.checkPath == '${last['path'] ?? ''}'.trim()) {
          existing.inspectionIssueCount = issues is num ? issues.toInt() : null;
          if (existing.plate.isEmpty) {
            existing.plate = '${last['plate'] ?? ''}'.trim();
          }
        }
        continue;
      }
      // Kein Spiegel-Event (Check vor dem Function-Deploy) → Fallback.
      done[tid] = _DoneEntry(
        transporterId: tid,
        driverName: nameByTid[tid] ?? tid,
        at: at,
        plate: '${last['plate'] ?? ''}'.trim(),
        checkPath: '${last['path'] ?? ''}'.trim(),
        checkId: '${last['checkId'] ?? ''}'.trim(),
        damageCount: damage is num ? damage.toInt() : 0,
        inspectionIssueCount: issues is num ? issues.toInt() : null,
        fromMirror: false,
      );
    }

    // ── 3. Offene Fahrer ─────────────────────────────────────────────────
    final missing = <_MissingEntry>[];
    for (final doc in active) {
      final data = doc.data();
      final tid = tidOf(data, doc.id);
      if (done.containsKey(tid)) continue;
      final last = data['lastVehicleCheck'];
      final lastAt =
          last is Map ? (last['at'] as Timestamp?)?.toDate() : null;
      missing.add(
        _MissingEntry(
          transporterId: tid,
          driverName: nameByTid[tid] ?? tid,
          lastCheckAt: lastAt,
        ),
      );
    }

    // Nur aktive Fahrer stehen in „Erledigt" — ein Event eines inzwischen
    // ausgeschiedenen Fahrers würde die Tageszahlen sonst verfälschen.
    final doneList = done.values
        .where((e) => nameByTid.containsKey(e.transporterId))
        .toList()
      ..sort((a, b) => b.at.compareTo(a.at));
    missing.sort(
      (a, b) => a.driverName.toLowerCase().compareTo(b.driverName.toLowerCase()),
    );
    return (doneList, missing);
  }

  bool _matches(String name, String tid, String plate) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        tid.toLowerCase().contains(q) ||
        plate.toLowerCase().contains(q);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  UI
  // ═══════════════════════════════════════════════════════════════════════

  Widget _body({
    required bool de,
    required String uid,
    required bool loading,
    required List<_DoneEntry> done,
    required List<_MissingEntry> missing,
    required bool error,
  }) {
    final doneShown = done
        .where((e) => _matches(e.driverName, e.transporterId, e.plate))
        .toList(growable: false);
    final missingShown = missing
        .where((e) => _matches(e.driverName, e.transporterId, ''))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(de),
        const SizedBox(height: 14),
        _dayBar(de),
        const SizedBox(height: 12),
        _counters(de, done.length, missing.length),
        const SizedBox(height: 12),
        _searchField(de),
        if (_day.isBefore(_kMirrorLiveSince)) ...[
          const SizedBox(height: 10),
          _mirrorHint(de),
        ],
        if (error) ...[
          const SizedBox(height: 10),
          _banner(
            de
                ? 'Die Tagesdaten konnten nicht vollständig geladen werden.'
                : 'The day could not be loaded completely.',
            _kRed,
            const Color(0xFFFEE2E2),
            Icons.error_outline,
          ),
        ],
        const SizedBox(height: 14),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 860;
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _column(
                              title: de ? 'Erledigt' : 'Done',
                              icon: Icons.check_circle_outline,
                              color: _kGreen,
                              count: doneShown.length,
                              child: _doneList(de, uid, doneShown, done.isEmpty),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _column(
                              title: de ? 'Offen' : 'Missing',
                              icon: Icons.pending_outlined,
                              color: _kAmber,
                              count: missingShown.length,
                              child: _missingList(de, missingShown),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _sectionTitle(
                          de ? 'Erledigt' : 'Done',
                          Icons.check_circle_outline,
                          _kGreen,
                          doneShown.length,
                        ),
                        const SizedBox(height: 8),
                        if (doneShown.isEmpty)
                          _emptyBox(_doneEmptyText(de, done.isEmpty))
                        else
                          for (final e in doneShown) ...[
                            _doneTile(de, uid, e),
                            const SizedBox(height: 8),
                          ],
                        const SizedBox(height: 18),
                        _sectionTitle(
                          de ? 'Offen' : 'Missing',
                          Icons.pending_outlined,
                          _kAmber,
                          missingShown.length,
                        ),
                        const SizedBox(height: 8),
                        if (missingShown.isEmpty)
                          _emptyBox(
                            de
                                ? 'Niemand offen — alle aktiven Fahrer haben '
                                    'geprüft.'
                                : 'Nobody missing — every active driver '
                                    'checked in.',
                          )
                        else
                          for (final e in missingShown) ...[
                            _missingTile(de, e),
                            const SizedBox(height: 8),
                          ],
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _header(bool de) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        de ? 'Fahrzeug-Check' : 'Vehicle Check',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: _kText,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        de
            ? 'Archiv je Tag: welche aktiven Fahrer den geführten '
                'Fahrzeug-Check abgegeben haben — und welche nicht.'
            : 'Day-by-day archive: which active drivers submitted the '
                'guided vehicle check — and which did not.',
        style: const TextStyle(fontSize: 13.5, color: _kMuted),
      ),
    ],
  );

  Widget _dayBar(bool de) {
    final forwardEnabled = !_isToday;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: de ? 'Tag zurück' : 'Previous day',
            onPressed: () => _shiftDay(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: _kText,
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDay,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: _kMuted,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _dayLabel(_day, de),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ),
                    if (_isToday) ...[
                      const SizedBox(width: 8),
                      _pill(de ? 'HEUTE' : 'TODAY', _kGreen, _kGreenSoft),
                    ],
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: de ? 'Tag vor' : 'Next day',
            onPressed: forwardEnabled ? () => _shiftDay(1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: _kText,
          ),
        ],
      ),
    );
  }

  Widget _counters(bool de, int doneCount, int missingCount) => Row(
    children: [
      Expanded(
        child: _counterTile(
          value: doneCount,
          label: de ? 'erledigt' : 'done',
          icon: Icons.check_circle_outline,
          fg: _kGreen,
          bg: _kGreenSoft,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _counterTile(
          value: missingCount,
          label: de ? 'offen' : 'missing',
          icon: Icons.pending_outlined,
          fg: _kAmber,
          bg: _kAmberSoft,
        ),
      ),
    ],
  );

  Widget _counterTile({
    required int value,
    required String label,
    required IconData icon,
    required Color fg,
    required Color bg,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: fg.withValues(alpha: 0.22)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: fg),
        const SizedBox(width: 10),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: fg,
            height: 1.1,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _searchField(bool de) => TextField(
    controller: _searchCtrl,
    focusNode: _searchFocus,
    onChanged: (v) => setState(() => _query = v),
    textInputAction: TextInputAction.search,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintText: de
          ? 'Fahrer, Transporter-ID oder Kennzeichen suchen…'
          : 'Search driver, transporter ID or plate…',
      hintStyle: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: _kMuted,
      ),
      prefixIcon: const Icon(Icons.search, size: 20, color: _kMuted),
      suffixIcon: buildSearchClearButton(
        context: context,
        value: _query,
        onClear: () {
          _searchCtrl.clear();
          setState(() => _query = '');
        },
        focusNode: _searchFocus,
      ),
      suffixIconConstraints: kSearchClearConstraints,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kGreen, width: 1.4),
      ),
    ),
  );

  Widget _mirrorHint(bool de) => _banner(
    de
        ? 'Hinweis: Die automatische Spiegelung der Fahrzeug-Checks läuft '
            'erst seit dem 25.08.2026. Für frühere Tage zeigt diese Seite '
            'nur den jeweils zuletzt gespeicherten Check eines Fahrers — '
            'das Archiv kann hier also unvollständig sein.'
        : 'Note: vehicle checks have only been mirrored automatically since '
            '25 Aug 2026. For earlier days this page can only show each '
            'driver’s most recent stored check, so the archive may be '
            'incomplete.',
    const Color(0xFF1D4ED8),
    const Color(0xFFEAF0FE),
    Icons.info_outline,
  );

  Widget _banner(String text, Color fg, Color bg, IconData icon) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: fg.withValues(alpha: 0.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _column({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required Widget child,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle(title, icon, color, count),
      const SizedBox(height: 8),
      Expanded(child: child),
    ],
  );

  Widget _sectionTitle(String title, IconData icon, Color color, int count) =>
      Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _kText,
            ),
          ),
          const SizedBox(width: 8),
          _pill('$count', color, color.withValues(alpha: 0.10)),
        ],
      );

  String _doneEmptyText(bool de, bool nothingAtAll) {
    if (_query.trim().isNotEmpty && !nothingAtAll) {
      return de ? 'Kein Treffer für die Suche.' : 'No match for your search.';
    }
    if (_day.isBefore(_kMirrorLiveSince)) {
      return de
          ? 'Für diesen Tag liegt kein Fahrzeug-Check vor. Die automatische '
              'Spiegelung läuft erst seit dem 25.08.2026 — ältere Checks '
              'tauchen hier deshalb nur auf, wenn sie der letzte Check des '
              'Fahrers sind.'
          : 'No vehicle check on record for this day. Automatic mirroring '
              'only started on 25 Aug 2026, so older checks appear here only '
              'if they are the driver’s most recent one.';
    }
    return de
        ? 'An diesem Tag hat noch niemand einen Fahrzeug-Check abgegeben.'
        : 'Nobody has submitted a vehicle check on this day yet.';
  }

  Widget _doneList(
    bool de,
    String uid,
    List<_DoneEntry> rows,
    bool nothingAtAll,
  ) {
    if (rows.isEmpty) {
      return SingleChildScrollView(
        child: _emptyBox(_doneEmptyText(de, nothingAtAll)),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _doneTile(de, uid, rows[i]),
    );
  }

  Widget _missingList(bool de, List<_MissingEntry> rows) {
    if (rows.isEmpty) {
      return SingleChildScrollView(
        child: _emptyBox(
          _query.trim().isNotEmpty
              ? (de
                    ? 'Kein Treffer für die Suche.'
                    : 'No match for your search.')
              : (de
                    ? 'Niemand offen — alle aktiven Fahrer haben geprüft.'
                    : 'Nobody missing — every active driver checked in.'),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _missingTile(de, rows[i]),
    );
  }

  Widget _emptyBox(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kBorder),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        height: 1.4,
        color: _kMuted,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _doneTile(bool de, String uid, _DoneEntry e) {
    final issues = e.inspectionIssueCount ?? 0;
    final flagged = e.damageCount > 0 || issues > 0;
    final canOpen = e.checkPath.isNotEmpty;

    final facts = <String>[
      _timeLabel(e.at),
      if (e.plate.isNotEmpty) e.plate,
      e.damageCount == 1
          ? (de ? '1 Schaden' : '1 damage')
          : (de ? '${e.damageCount} Schäden' : '${e.damageCount} damages'),
      if (e.inspectionIssueCount != null)
        issues == 1
            ? (de ? '1 Auffälligkeit' : '1 issue')
            : (de ? '$issues Auffälligkeiten' : '$issues issues'),
    ];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: canOpen
            ? () => openAdminVehicleCheckDetail(
                context,
                dspUid: uid,
                checkPath: e.checkPath,
              )
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: flagged ? _kAmber.withValues(alpha: 0.35) : _kBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: _kGreenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_filled_outlined,
                  size: 18,
                  color: _kGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            e.driverName.isEmpty
                                ? e.transporterId
                                : e.driverName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _kText,
                            ),
                          ),
                        ),
                        if (flagged) ...[
                          const SizedBox(width: 6),
                          _pill(
                            de ? 'AUFFÄLLIG' : 'FLAGGED',
                            _kAmber,
                            _kAmberSoft,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      facts.join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.2,
                        color: _kMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!e.fromMirror) ...[
                      const SizedBox(height: 2),
                      Text(
                        de
                            ? 'aus der Fahrer-Kurzfassung'
                            : 'from the driver summary',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: _kMuted.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                canOpen ? Icons.chevron_right : Icons.lock_outline,
                size: 18,
                color: _kMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _missingTile(bool de, _MissingEntry e) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: _kAmberSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline,
            size: 18,
            color: _kAmber,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.driverName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                e.lastCheckAt == null
                    ? (de ? 'Noch nie geprüft' : 'Never checked')
                    : (de
                          ? 'Zuletzt ${_dayLabel(_dateOnly(e.lastCheckAt!), de)}'
                          : 'Last ${_dayLabel(_dateOnly(e.lastCheckAt!), de)}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.2,
                  color: _kMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          e.transporterId,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: _kMuted,
          ),
        ),
      ],
    ),
  );

  Widget _pill(String text, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.3,
        color: fg,
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════
//  Datum/Zeit — bewusst von Hand, weil `initializeDateFormatting` in
//  dieser App nicht läuft und `DateFormat` mit Locale 'de' dann wirft.
// ═════════════════════════════════════════════════════════════════════════

String _two(int v) => v < 10 ? '0$v' : '$v';

const List<String> _kWeekdaysDe = <String>[
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];

const List<String> _kWeekdaysEn = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String _dayLabel(DateTime d, bool de) {
  final weekday = (de ? _kWeekdaysDe : _kWeekdaysEn)[d.weekday - 1];
  return '$weekday, ${_two(d.day)}.${_two(d.month)}.${d.year}';
}

String _timeLabel(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
