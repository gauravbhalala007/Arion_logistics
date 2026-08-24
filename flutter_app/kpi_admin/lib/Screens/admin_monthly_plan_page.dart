// lib/Screens/admin_monthly_plan_page.dart
//
// Monthly Plan ("Spesen Fast Check") — one grid per month:
//   rows = working drivers, columns = days of the month.
// Each cell holds a day code (A, AC, AB, C, U, X, OSM, …). Days coded with
// one of [_kSpesenCodes] (A / AC / Ra / AB) count towards the monthly
// Spesen; the rate per day is configurable (default 14 €). The two
// right-hand columns show the qualifying-day count and the resulting €.
//
// Storage: users/{uid}/monthly_plans/{YYYY-MM}
//   { entries: { <transporterId>: { "1": "A", "2": "AC", ... } } }
// Settings: users/{uid}/settings/monthly_plan
//   { spesenContracts: [...], spesenBuckets: [...], autoFill: bool,
//     spesenRate: number, codeLabels: { "<code>": "<Beschriftung>" } }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/driver_contract_type.dart';
import '../models/employment_period.dart';
import '../models/shift_plan.dart';
import '../services/shift_plan_parser.dart';
import '../utils/driver_activity.dart';
import '../utils/vacation_days.dart';
import '../widgets/admin_scope.dart';
import '../widgets/clearable_search_field.dart';

/// Standard-Spesensatz in € pro qualifizierendem Tag. Über die
/// Einstellungen (`users/{uid}/settings/monthly_plan.spesenRate`) frei
/// konfigurierbar — dieser Wert dient nur als Vorbelegung/Fallback.
const double kSpesenPerDay = 14.0;

/// Day codes with display colours. Only [_kSpesenCodes] count towards €.
/// „AB" und „OSM" sind additiv ergänzt: bestehende Pläne mit den alten
/// Codes bleiben unverändert lesbar.
const List<String> kDayCodes = [
  'A', 'AC', 'AB', 'C', 'U', 'K', 'X', 'F', 'S', 'SA', 'Ra', 'OSM', 'P', 'N',
];

/// Codes, die einen Spesen-Tag auslösen. „AB" zählt (Ticket), „OSM" nicht.
const Set<String> _kSpesenCodes = {'A', 'AC', 'Ra', 'AB'};

/// Codes counted as a worked day in the compact mobile summary
/// (shift codes; U/K/F/X are days off and are counted separately).
const Set<String> _kWorkCodes = {'A', 'AC', 'C', 'Ra', 'AB', 'OSM'};

/// Compact contract-type tag shown in front of the employee name.
/// Minijob drivers never receive Spesen.
String _contractAbbr(DriverContractType? c) {
  switch (c) {
    case DriverContractType.fulltime:
      return 'FT';
    case DriverContractType.parttime4d:
      return 'PT4';
    case DriverContractType.parttime3d:
      return 'PT3';
    case DriverContractType.parttime2d:
      return 'PT2';
    case DriverContractType.minijob:
      return 'MJ';
    case DriverContractType.dispatcher:
      return 'DP';
    case DriverContractType.outSoon:
      return 'OUT';
    case null:
      return '';
  }
}

/// Vertragsgruppe für die Standard-Sortierung des Monatsplans (Ticket):
/// 1. Minijob · 2. Teilzeit · 3. Dispatch · 4. Vollzeit ·
/// 5. Austritt geplant · 6. Sonstige (kein Vertragstyp hinterlegt).
/// Alle Teilzeit-Varianten (2d/3d/4d) bilden **eine** Gruppe.
int _contractGroupRank(DriverContractType? c) => switch (c) {
      DriverContractType.minijob => 0,
      DriverContractType.parttime4d ||
      DriverContractType.parttime3d ||
      DriverContractType.parttime2d =>
        1,
      DriverContractType.dispatcher => 2,
      DriverContractType.fulltime => 3,
      DriverContractType.outSoon => 4,
      null => 5,
    };

Color _codeColor(String code) {
  switch (code) {
    case 'A':
      return const Color(0xFF86EFAC); // green
    case 'AC':
      return const Color(0xFF5EEAD4); // teal
    case 'AB':
      // Kräftigeres Smaragd — eigener Ton neben A (Grün) und AC (Türkis),
      // zählt wie diese als Spesen-Tag.
      return const Color(0xFF34D399); // emerald
    case 'C':
      return const Color(0xFFFDE047); // yellow
    case 'U':
      // Kräftigeres Violett — Ticket: war kaum von 'F' (Blau) zu
      // unterscheiden.
      return const Color(0xFFA78BFA); // purple (Urlaub — keine Spesen)
    case 'K':
      return const Color(0xFFFDA4AF); // rose (Krankmeldung — keine Spesen)
    case 'X':
      return const Color(0xFFFCA5A5); // red
    case 'F':
      // Gesättigteres Blau — Ticket: war kaum von 'U' (Violett) zu
      // unterscheiden.
      return const Color(0xFF60A5FA); // blue
    case 'S':
      return const Color(0xFFFDBA74); // orange
    case 'SA':
      return const Color(0xFF94A3B8); // slate
    case 'Ra':
      return const Color(0xFFBBF7D0); // light green
    case 'OSM':
      // Indigo — deutlich unterscheidbar von F (Blau) und N (Lavendel);
      // keine Spesen.
      return const Color(0xFF818CF8); // indigo
    case 'P':
      return const Color(0xFFF9A8D4); // pink
    case 'N':
      return const Color(0xFFD8B4FE); // lavender (Nationaler Feiertag)
    default:
      return Colors.transparent;
  }
}

class AdminMonthlyPlanPage extends StatefulWidget {
  const AdminMonthlyPlanPage({super.key});

  @override
  State<AdminMonthlyPlanPage> createState() => _AdminMonthlyPlanPageState();
}

class _AdminMonthlyPlanPageState extends State<AdminMonthlyPlanPage> {
  static const _kBg = Color(0xFFF3F6F7);
  static const _kBorder = Color(0xFFE5E7EB);
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _rowH = 34.0;
  static const _cellW = 34.0;

  /// Ticket „MONTHLY PLAN — unusable on mobile": unterhalb dieser Breite
  /// wird die Matrix (Namensspalte + 31 Tagesspalten ≈ 1290 px) durch eine
  /// zweistufige Touch-Ansicht ersetzt: Fahrerliste → Tagesliste je Fahrer.
  /// Oberhalb bleibt der bisherige Code-Pfad unverändert.
  static const _kNarrow = 700.0;

  /// Schmale Ansicht: Transporter-ID des Fahrers, dessen Tagesliste offen
  /// ist. `null` = Fahrerliste.
  String? _detailTid;

  late DateTime _month;

  // ── Ticket: search + sort controls for the driver rows ──
  String _search = '';

  /// Owned so the field's clear button can wipe the visible text as well.
  final TextEditingController _searchCtrl = TextEditingController();

  /// Ticket: inaktive Fahrer einblenden, um alte Monate nachzuerfassen.
  bool _showInactive = false;
  // 'contract' (default grouping), 'name', 'start', 'tid'
  String _sortMode = 'contract';

  // Ticket "CTRL+F": Browser-Suche greift in Flutter-Web nicht —
  // Cmd/Ctrl+F fokussiert stattdessen das Suchfeld der Seite.
  final FocusNode _searchFocus = FocusNode();

  /// Ticket: Beschäftigungszeitraum unter dem Fahrernamen.
  ///
  /// Zeigt „17.06.26 – 30.07.26"; läuft der Vertrag noch, steht statt des
  /// Enddatums ein Aktiv-Kennzeichen. Gibt es mehrere Zeiträume (z. B.
  /// nach Wiedereinstellung), wird der für den angezeigten Monat
  /// relevante genommen. Ohne Daten bleibt die Zeile ganz weg, damit
  /// keine leere Lücke entsteht.
  Widget _employmentLine(Map<String, dynamic> driverData) {
    final periods = employmentPeriodsOf(driverData);
    final period = employmentPeriodForMonth(periods, _month);
    final start = period?.startDate;
    if (period == null || start == null) return const SizedBox.shrink();

    final de = Localizations.localeOf(context).languageCode == 'de';
    final startText = formatShortDate(start);

    if (period.isOngoing) {
      return Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '$startText – ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: _kMuted),
              ),
            ),
            const Icon(
              Icons.check_circle_rounded,
              size: 10,
              color: Color(0xFF1D7F5A),
            ),
            const SizedBox(width: 2),
            Text(
              de ? 'aktiv' : 'active',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D7F5A),
              ),
            ),
          ],
        ),
      );
    }

    final end = period.endDate;
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Text(
        end == null ? startText : '$startText – ${formatShortDate(end)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10, color: _kMuted),
      ),
    );
  }

  bool _onGlobalKey(KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.keyF &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      if (_searchFocus.canRequestFocus) {
        _searchFocus.requestFocus();
        return true;
      }
    }
    return false;
  }

  /// Per ISO week: transporterId → normalized scorecard bucket
  /// (FANTASTICPLUS/FANTASTIC/GREAT/FAIR/POOR). Weeks whose bucket is
  /// not in [_spesenBuckets] are cancelled automatically (a manual
  /// toggle in the cell menu can override this).
  Map<int, Map<String, String>> _bucketByWeek = {};
  String _poorFairLoadedFor = '';

  // ── Settings: who receives Spesen ──
  // Contract types entitled to Spesen. Default: fulltime + parttime.
  Set<String> _spesenContracts = {
    'fulltime', 'parttime_4d', 'parttime_3d', 'parttime_2d',
  };
  // Scorecard buckets entitled to Spesen. Default: all except Fair/Poor.
  Set<String> _spesenBuckets = {'FANTASTICPLUS', 'FANTASTIC', 'GREAT'};
  // € pro Spesen-Tag — im Einstellungs-Dialog frei wählbar.
  double _spesenRate = kSpesenPerDay;
  // Eigene Beschriftung je Zellen-Code (Code → Klartext). Leere/fehlende
  // Einträge fallen auf [_defaultCodeLabel] zurück.
  Map<String, String> _codeLabels = {};
  bool _settingsLoaded = false;

  // ── Ticket „Auto-Vorbelegung" ──────────────────────────────────────
  // Genehmigter Urlaub aus „Zeiten & Abwesenheiten" erscheint als „U"
  // (bezahlt) bzw. „X" (unbezahlt),
  // Samstage/Sonntage als „F" (unbezahlt). Die Vorbelegung ist eine
  // reine ANZEIGE-Schicht: sie wird NIE nach Firestore geschrieben und
  // greift ausschließlich in Zellen, die noch komplett leer sind. Damit
  // kann eine manuelle Eintragung technisch nicht überschrieben werden.
  bool _autoFill = true;

  /// transporterId (UPPERCASE) → Tag des angezeigten Monats → Kürzel des
  /// GENEHMIGTEN Abwesenheitsantrags, der den Tag abdeckt: `'U'` für
  /// bezahlten Urlaub, `'X'` für unbezahlten Urlaub, `'K'` für eine
  /// genehmigte Krankmeldung.
  Map<String, Map<int, String>> _absenceDaysByTid = {};
  String _absenceLoadedFor = '';

  static String _normBucket(dynamic v) =>
      v.toString().toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');

  DocumentReference<Map<String, dynamic>>? get _settingsRef {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('monthly_plan');
  }

  Future<void> _loadSettings() async {
    if (_settingsLoaded) return;
    _settingsLoaded = true;
    final ref = _settingsRef;
    if (ref == null) return;
    try {
      final snap = await ref.get();
      final data = snap.data();
      if (data == null || !mounted) return;
      setState(() {
        final c = data['spesenContracts'];
        if (c is List) {
          _spesenContracts = c.map((e) => e.toString()).toSet();
        }
        final b = data['spesenBuckets'];
        if (b is List) {
          _spesenBuckets = b.map(_normBucket).toSet();
        }
        final auto = data['autoFill'];
        if (auto is bool) _autoFill = auto;
        final rate = data['spesenRate'];
        if (rate is num && rate >= 0) _spesenRate = rate.toDouble();
        final labels = data['codeLabels'];
        if (labels is Map) {
          _codeLabels = {
            for (final e in labels.entries)
              if (e.value != null && e.value.toString().trim().isNotEmpty)
                e.key.toString(): e.value.toString().trim(),
          };
        }
      });
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    final ref = _settingsRef;
    if (ref == null) return;
    await ref.set({
      'spesenContracts': _spesenContracts.toList(),
      'spesenBuckets': _spesenBuckets.toList(),
      'autoFill': _autoFill,
      'spesenRate': _spesenRate,
      // Immer alle Codes schreiben (leerer String = Standardbeschriftung).
      // `merge: true` führt Map-Felder zusammen — eine gelöschte
      // Beschriftung verschwände sonst nicht.
      'codeLabels': {
        for (final c in kDayCodes) c: _codeLabels[c] ?? '',
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Schalter „Monat automatisch vorbelegen" — Urlaub (U bezahlt /
  /// X unbezahlt) aus den genehmigten Anträgen und Wochenenden (F).
  /// Reine Anzeige, keine Schreibvorgänge; die Wahl wird pro Admin
  /// gespeichert.
  Future<void> _toggleAutoFill() async {
    setState(() => _autoFill = !_autoFill);
    _snack(_autoFill
        ? _tr(
            'Automatische Vorbelegung an: genehmigter Urlaub = U '
                '(bezahlt) bzw. X (unbezahlt), genehmigte Krankmeldung '
                '= K, Sa/So = F. Nur leere Felder, nichts wird '
                'gespeichert.',
            'Auto pre-fill on: approved vacation = U (paid) or X '
                '(unpaid), approved sick leave = K, Sat/Sun = F. Empty '
                'cells only, nothing is stored.')
        : _tr('Automatische Vorbelegung aus.', 'Auto pre-fill off.'));
    await _saveSettings();
  }

  /// Whether this contract type receives Spesen at all. Drivers
  /// without a stored contract type stay eligible.
  bool _contractEligible(DriverContractType? c) =>
      c == null || _spesenContracts.contains(c.value);

  /// Eingabeformat des Spesensatzes: „14" bzw. „14,50" (DE) / „14.50".
  String _rateInput(double v) {
    final s =
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return _de ? s.replaceAll('.', ',') : s;
  }

  Future<void> _openSettings() async {
    final contracts = {..._spesenContracts};
    final buckets = {..._spesenBuckets};
    const bucketOptions = [
      ('FANTASTICPLUS', 'Fantastic+'),
      ('FANTASTIC', 'Fantastic'),
      ('GREAT', 'Great'),
      ('FAIR', 'Fair'),
      ('POOR', 'Poor'),
    ];
    final rateCtrl = TextEditingController(text: _rateInput(_spesenRate));
    final labelCtrls = {
      for (final c in kDayCodes)
        c: TextEditingController(text: _codeLabels[c] ?? ''),
    };
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            _tr('Monatsplan-Einstellungen', 'Monthly plan settings'),
            style:
                const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Spesensatz ──
                  Text(
                    _tr('Spesensatz pro Spesen-Tag',
                        'Spesen rate per qualifying day'),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _kMuted),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: rateCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]')),
                    ],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      isDense: true,
                      suffixText: _tr('€ / Tag', '€ / day'),
                      hintText: _rateInput(kSpesenPerDay),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tr(
                        'Gilt für alle Codes mit Spesen '
                            '(${kDayCodes.where(_kSpesenCodes.contains).join(' / ')}).',
                        'Applies to all codes with Spesen '
                            '(${kDayCodes.where(_kSpesenCodes.contains).join(' / ')}).'),
                    style: const TextStyle(fontSize: 11, color: _kMuted),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _kBorder),
                  const SizedBox(height: 12),
                  Text(
                    _tr('Wer erhält Spesen? (Vertragsart)',
                        'Who receives Spesen? (contract type)'),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _kMuted),
                  ),
                  for (final c in DriverContractType.values)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(c.label,
                          style: const TextStyle(fontSize: 13)),
                      value: contracts.contains(c.value),
                      onChanged: (v) => setLocal(() {
                        v == true
                            ? contracts.add(c.value)
                            : contracts.remove(c.value);
                      }),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    _tr('Wer erhält Spesen? (Performance-Status)',
                        'Who receives Spesen? (performance status)'),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _kMuted),
                  ),
                  for (final (key, label) in bucketOptions)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title:
                          Text(label, style: const TextStyle(fontSize: 13)),
                      value: buckets.contains(key),
                      onChanged: (v) => setLocal(() {
                        v == true ? buckets.add(key) : buckets.remove(key);
                      }),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    _tr('Wochen mit abgewähltem Status werden automatisch gestrichen (orange). Manuelle Änderungen pro Woche haben Vorrang.',
                        'Weeks with a deselected status are cancelled automatically (orange). Manual per-week changes take precedence.'),
                    style: const TextStyle(fontSize: 11, color: _kMuted),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _kBorder),
                  const SizedBox(height: 12),
                  // ── Beschriftung der Codes ──
                  Text(
                    _tr('Beschriftung der Codes',
                        'Labels for the day codes'),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _kMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tr(
                        'Eigene Bedeutung je Kürzel — erscheint in Legende, '
                            'Tooltips und im Code-Menü. Leer = Standard.',
                        'Custom meaning per code — shown in the legend, '
                            'tooltips and the code menu. Empty = default.'),
                    style: const TextStyle(fontSize: 11, color: _kMuted),
                  ),
                  const SizedBox(height: 8),
                  for (final code in kDayCodes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 34,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _codeColor(code),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          if (_kSpesenCodes.contains(code)) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.euro_rounded,
                                size: 13, color: Color(0xFF1D7F5A)),
                          ],
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: labelCtrls[code],
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 9),
                                hintText: _defaultCodeLabel(code) ??
                                    _tr('Bedeutung eingeben',
                                        'Enter meaning'),
                                hintStyle: const TextStyle(
                                    fontSize: 12, color: Color(0xFF9CA3AF)),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
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
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_tr('Abbrechen', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_tr('Speichern', 'Save')),
            ),
          ],
        ),
      ),
    );
    final rateText = rateCtrl.text.trim().replaceAll(',', '.');
    final labels = {
      for (final e in labelCtrls.entries)
        if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
    };
    rateCtrl.dispose();
    for (final c in labelCtrls.values) {
      c.dispose();
    }
    if (saved != true || !mounted) return;
    final parsedRate = double.tryParse(rateText);
    if (parsedRate == null || parsedRate < 0) {
      _snack(_tr(
          'Ungültiger Spesensatz — bisheriger Wert '
              '(${_money(_spesenRate)}) bleibt bestehen.',
          'Invalid Spesen rate — the previous value '
              '(${_money(_spesenRate)}) is kept.'));
    }
    setState(() {
      _spesenContracts = contracts;
      _spesenBuckets = buckets;
      if (parsedRate != null && parsedRate >= 0) _spesenRate = parsedRate;
      _codeLabels = labels;
    });
    await _saveSettings();
  }

  /// Horizontal scroll of the pinned header row, the body and the always
  /// visible scrollbar strip below the matrix are kept in sync so the day
  /// columns always line up.
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  final ScrollController _hFoot = ScrollController();

  /// Vertikaler Scroll des Matrix-Körpers (eigene Scrollbar) und der
  /// Seite selbst, wenn die Shell zu wenig Höhe übrig lässt.
  final ScrollController _vBody = ScrollController();
  final ScrollController _vPage = ScrollController();
  bool _hSyncing = false;
  bool _rosterImporting = false;

  /// Ticket „not scrollable": Maus-Drag als Scroll-Geste zulassen und die
  /// automatischen Scrollbars abschalten — die Matrix bekommt stattdessen
  /// eigene, dauerhaft sichtbare Scrollbars.
  ScrollBehavior _dragScrollBehavior(BuildContext context) =>
      ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        dragDevices: const {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      );

  void _syncScroll(ScrollController from) {
    if (_hSyncing || !from.hasClients) return;
    _hSyncing = true;
    for (final to in [_hHeader, _hBody, _hFoot]) {
      if (identical(to, from) || !to.hasClients) continue;
      final target = from.offset.clamp(0.0, to.position.maxScrollExtent);
      if ((to.offset - target).abs() > 0.5) to.jumpTo(target);
    }
    _hSyncing = false;
  }

  String? get _uid {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _hHeader.addListener(() => _syncScroll(_hHeader));
    _hBody.addListener(() => _syncScroll(_hBody));
    _hFoot.addListener(() => _syncScroll(_hFoot));
    HardwareKeyboard.instance.addHandler(_onGlobalKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onGlobalKey);
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _hHeader.dispose();
    _hBody.dispose();
    _hFoot.dispose();
    _vBody.dispose();
    _vPage.dispose();
    super.dispose();
  }

  String get _monthKey =>
      '${_month.year.toString().padLeft(4, '0')}-'
      '${_month.month.toString().padLeft(2, '0')}';

  DocumentReference<Map<String, dynamic>>? get _planRef {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('monthly_plans')
        .doc(_monthKey);
  }

  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String _tr(String de, String en) => _de ? de : en;

  /// Beschriftung einer Vertragsgruppe (DE/EN) für die Gruppen-Kopfzeilen.
  String _groupLabel(int rank) => switch (rank) {
        0 => 'Minijob',
        1 => _tr('Teilzeit', 'Part-time'),
        2 => _tr('Dispatch', 'Dispatch'),
        3 => _tr('Vollzeit', 'Full-time'),
        4 => _tr('Austritt geplant', 'Leaving soon'),
        _ => _tr('Sonstige', 'Other'),
      };

  /// Höhe einer Gruppen-Kopfzeile in der Matrix.
  static const _groupRowH = 24.0;

  /// Zeilenfolge von Liste und Matrix: In der Standard-Sortierung
  /// („Vertragsgruppe") steht vor jeder Gruppe eine Kopfzeile, sonst
  /// stehen nur die Fahrer in der Liste. `index < 0` = Kopfzeile.
  List<({int index, int rank, int count})> _planRows(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
  ) {
    int rankOf(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
        _contractGroupRank(
            DriverContractType.fromValue(d.data()['contractType']));

    final rows = <({int index, int rank, int count})>[];
    final grouped = _sortMode == 'contract';
    var prev = -1;
    for (var i = 0; i < drivers.length; i++) {
      final rank = rankOf(drivers[i]);
      if (grouped && rank != prev) {
        var count = 0;
        for (var j = i; j < drivers.length && rankOf(drivers[j]) == rank; j++) {
          count++;
        }
        rows.add((index: -1, rank: rank, count: count));
        prev = rank;
      }
      rows.add((index: i, rank: rank, count: 0));
    }
    return rows;
  }

  /// Dezente Gruppen-Kopfzeile („Minijob · 3") für Matrix und Handy-Liste.
  Widget _groupHeader(int rank, int count, {double? width}) {
    return Container(
      width: width,
      height: _groupRowH,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 12, right: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2F6),
        border: Border(
          top: BorderSide(color: Color(0xFFDDE3EA), width: 0.8),
          bottom: BorderSide(color: Color(0xFFDDE3EA), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _groupLabel(rank).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// Zusatz für die Legende, solange die Vorbelegung aktiv ist.
  String _autoLegendSuffix() => _tr(
      ' · blass = automatisch vorbelegt (Urlaub U/X, Krank K, Sa/So F)',
      ' · pale = pre-filled automatically (vacation U/X, sick K, '
          'Sat/Sun F)');

  String _monthLabel() {
    const de = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    const en = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final names = _de ? de : en;
    return '${names[_month.month - 1]} ${_month.year}';
  }

  Future<void> _setCode(String tid, int day, String? code) async {
    final ref = _planRef;
    if (ref == null) return;
    await ref.set({
      'entries': {
        tid: {'$day': code ?? FieldValue.delete()},
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Ticket: Monat per Klick auswählen — kleiner Picker mit
  /// Jahres-Pfeilen und 12-Monats-Raster (wie im Feedback-Screenshot).
  Future<void> _pickMonthDialog() async {
    var year = _month.year;
    final de = Localizations.localeOf(context).languageCode == 'de';
    const namesDe = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    const namesEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final names = de ? namesDe : namesEn;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () => setLocal(() => year--),
                      ),
                      Expanded(
                        child: Text(
                          '$year',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _kText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () => setLocal(() => year++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 2.6,
                    children: [
                      for (var m = 1; m <= 12; m++)
                        Builder(builder: (context) {
                          final isCurrent = year == _month.year &&
                              m == _month.month;
                          return InkWell(
                            onTap: () => Navigator.pop(
                                ctx, DateTime(year, m)),
                            borderRadius: BorderRadius.circular(9),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: isCurrent
                                      ? const Color(0xFF00B287)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                names[m - 1],
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? const Color(0xFF065F46)
                                      : _kText,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _month = DateTime(picked.year, picked.month));
  }

  /// Ticket: einen Code auf mehrere Tage der Kalenderwoche anwenden
  /// (z. B. „U" für Mo–Fr oder die ganze Woche Mo–Sa). Ein einziges
  /// Firestore-Update für alle betroffenen Tage; Sonntage bleiben frei.
  Future<void> _applyCodeToWeek(
    String tid,
    int day,
    String code, {
    required int lastWeekday, // 5 = Mo–Fr, 6 = Mo–Sa
  }) async {
    final ref = _planRef;
    if (ref == null) return;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final date = DateTime(_month.year, _month.month, day);
    final monday = day - (date.weekday - 1);
    final updates = <String, dynamic>{};
    for (var offset = 0; offset < lastWeekday; offset++) {
      final d = monday + offset;
      if (d < 1 || d > daysInMonth) continue;
      updates['$d'] = code;
    }
    if (updates.isEmpty) return;
    await ref.set({
      'entries': {tid: updates},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Clears every entry (Mo–Sa) of the calendar week that [day] falls in,
  /// for one employee. Sundays are already free. One Firestore update.
  Future<void> _clearWeek(String tid, int day) async {
    final ref = _planRef;
    if (ref == null) return;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final date = DateTime(_month.year, _month.month, day);
    final monday = day - (date.weekday - 1);
    final updates = <String, dynamic>{};
    for (var offset = 0; offset < 6; offset++) {
      final d = monday + offset;
      if (d < 1 || d > daysInMonth) continue;
      updates['$d'] = FieldValue.delete();
    }
    if (updates.isEmpty) return;
    await ref.set({
      'entries': {tid: updates},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Ticket: alle nationalen Feiertage des angezeigten Monats für alle
  /// aktiven Mitarbeiter als 'N' markieren — wie im Arbeitsplan-Sheet.
  /// Ein einziger merge-Write für alle Fahrer × Feiertage.
  Future<void> _applyNationalHolidays() async {
    final ref = _planRef;
    final uid = _uid;
    if (ref == null || uid == null) return;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final holidayDays = <int>[
      for (var d = 1; d <= daysInMonth; d++)
        if (isGermanyPublicHoliday(DateTime(_month.year, _month.month, d))) d,
    ];
    final mm = _month.month.toString().padLeft(2, '0');
    if (holidayDays.isEmpty) {
      _snack(_tr('Keine nationalen Feiertage im $mm/${_month.year}.',
          'No national holidays in $mm/${_month.year}.'));
      return;
    }
    final dates = holidayDays
        .map((d) => '${d.toString().padLeft(2, '0')}.$mm.')
        .join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _tr('Feiertage (N) setzen', 'Set holidays (N)'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        content: Text(
          _tr(
              'Folgende nationale Feiertage werden für ALLE aktiven '
                  'Mitarbeiter als "N" eingetragen (bestehende Einträge an '
                  'diesen Tagen werden überschrieben):\n\n$dates',
              'The following national holidays will be set to "N" for ALL '
                  'active employees (existing entries on these days will be '
                  'overwritten):\n\n$dates'),
          style: const TextStyle(fontSize: 13.5, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_tr('Abbrechen', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_tr('Eintragen', 'Apply')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _showBusyOverlay(
        _tr('Feiertage werden eingetragen …', 'Applying holidays …'));
    try {
      final drivers = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('drivers')
          .get();
      final codes = <String, dynamic>{};
      for (final dr in drivers.docs) {
        final data = dr.data();
        if (!isDriverWorking(data)) continue;
        final tid = (data['transporterId'] ?? dr.id).toString().trim();
        if (tid.isEmpty) continue;
        codes[tid] = {for (final d in holidayDays) '$d': 'N'};
      }
      if (codes.isNotEmpty) {
        await ref.set({
          'entries': codes,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      _hideBusyOverlay();
      _snack(_tr(
          '${holidayDays.length} Feiertag(e) für ${codes.length} '
              'Mitarbeiter eingetragen.',
          '${holidayDays.length} holiday(s) applied for ${codes.length} '
              'employees.'));
    } catch (e) {
      _hideBusyOverlay();
      _snack(_tr('Feiertage konnten nicht eingetragen werden: $e',
          'Could not apply holidays: $e'));
    }
  }

  /// ISO-8601 week number for a date.
  /// UTC-basiert, damit der Sommerzeit-Übergang keinen Tag "verschluckt"
  /// (lokale Differenzen über die DST-Grenze sind 1h kürzer und .inDays
  /// rundet dann eine ganze Woche falsch).
  static int _isoWeek(DateTime d) {
    final day = DateTime.utc(d.year, d.month, d.day);
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final jan4 = DateTime.utc(thursday.year, 1, 4);
    final week1Monday = jan4.subtract(Duration(days: jan4.weekday - 1));
    return thursday.difference(week1Monday).inDays ~/ 7 + 1;
  }

  int _weekOfDay(int day) =>
      _isoWeek(DateTime(_month.year, _month.month, day));

  /// Toggle "Spesen gestrichen" for one employee in one calendar week.
  /// Stored explicitly (true/false) so a manual choice overrides the
  /// automatic poor/fair scorecard rule in both directions.
  Future<void> _toggleWeekBlock(String tid, int week, bool block) async {
    final ref = _planRef;
    if (ref == null) return;
    await ref.set({
      'blockedWeeks': {
        tid: {'$week': block},
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Toggle "No Spesen" for one employee for the whole month.
  Future<void> _toggleMonthBlock(String tid, bool block) async {
    final ref = _planRef;
    if (ref == null) return;
    await ref.set({
      'blockedMonths': {tid: block},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Loads scorecard buckets for every calendar week of the displayed
  /// month and collects the POOR/FAIR drivers per week.
  Future<void> _loadPoorFairFlags() async {
    final uid = _uid;
    if (uid == null) return;
    final key = _monthKey;
    if (_poorFairLoadedFor == key) return;
    _poorFairLoadedFor = key;

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final weeks = <int>{};
    for (var d = 1; d <= daysInMonth; d++) {
      weeks.add(_weekOfDay(d));
    }

    final result = <int, Map<String, String>>{};
    try {
      final db = FirebaseFirestore.instance;
      final reports = await db
          .collection('users')
          .doc(uid)
          .collection('reports')
          .where('year', isEqualTo: _month.year)
          .get();
      for (final report in reports.docs) {
        final week = (report.data()['weekNumber'] as num?)?.toInt();
        if (week == null || !weeks.contains(week)) continue;
        final scores = await db
            .collection('users')
            .doc(uid)
            .collection('scores')
            .where('reportId', isEqualTo: report.id)
            .get();
        for (final s in scores.docs) {
          final data = s.data();
          final comp = data['comp'];
          final bucket = _normBucket(
              (comp is Map ? comp['statusBucket'] : null) ??
                  data['statusBucket'] ??
                  '');
          if (bucket.isEmpty) continue;
          final tid = (data['transporterId'] ?? '').toString().trim();
          if (tid.isEmpty) continue;
          (result[week] ??= <String, String>{})[tid] = bucket;
        }
      }
    } catch (_) {
      // Scorecard data unavailable — keep manual toggles only.
    }
    if (!mounted || _monthKey != key) return;
    setState(() => _bucketByWeek = result);
  }

  /// Lädt die GENEHMIGTEN Abwesenheitsanträge aus „Zeiten &
  /// Abwesenheiten" (`users/{uid}/absence_requests`, dieselbe Sammlung,
  /// die der Urlaubs- und der Krankmeldungs-Tab dort schreiben) und
  /// mappt sie auf die Tage des angezeigten Monats.
  ///
  /// Es zählt ausschließlich `status == 'approved'` — offene
  /// (`pending`) und abgelehnte (`rejected`) Anträge werden nie
  /// übernommen. Ein einzelner Gleichheits-Filter braucht keinen
  /// Composite-Index; Typ- und Monatsabgrenzung passieren clientseitig.
  ///
  /// Codes:
  ///  * `type == 'vacation'`   → „U" (bezahlt) bzw. „X" (unbezahlt).
  ///    Anträge ohne `paid`-Feld (alle Bestandsdaten) gelten als
  ///    bezahlt → „U" wie bisher.
  ///  * `type == 'sick_leave'` → „K" (Krank). Ticket „Sick Leave input
  ///    dates are not being reflected in the monthly plan": vorher
  ///    filterte die Query hart auf `type == 'vacation'`, genehmigte
  ///    Krankmeldungen tauchten im Monatsplan deshalb nie auf.
  ///
  /// Überschneiden sich Urlaub und Krankmeldung an einem Tag, gewinnt
  /// die Krankmeldung (Krankheit unterbricht den Urlaub) — deshalb
  /// werden die Urlaubstage zuerst, die Kranktage danach geschrieben.
  Future<void> _loadApprovedAbsences() async {
    final uid = _uid;
    if (uid == null) return;
    final key = _monthKey;
    if (_absenceLoadedFor == key) return;
    _absenceLoadedFor = key;

    final first = DateTime(_month.year, _month.month, 1);
    final last = DateTime(_month.year, _month.month + 1, 0);
    final result = <String, Map<int, String>>{};
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('absence_requests')
          .where('status', isEqualTo: 'approved')
          .get();
      // Urlaub zuerst, Krankmeldungen danach → 'K' überschreibt 'U'/'X'.
      for (final sickPass in [false, true]) {
        for (final doc in snap.docs) {
          final data = doc.data();
          // Bewusst streng: nur explizit gesetzte Typen. Dokumente ohne
          // `type` blieben auch vorher außen vor (die alte Query
          // filterte hart auf `type == 'vacation'`).
          final type = (data['type'] ?? '').toString().trim();
          final isSick = type == 'sick_leave';
          if (isSick != sickPass) continue;
          if (!isSick && type != 'vacation') continue;
          final tid = (data['driverTransporterId'] ?? '')
              .toString()
              .trim()
              .toUpperCase();
          if (tid.isEmpty) continue;
          final from = parseFlexibleDate(data['fromDate']);
          if (from == null) continue;
          final to = parseFlexibleDate(data['toDate']) ?? from;
          if (from.isAfter(last) || to.isBefore(first)) continue;
          final String code;
          if (isSick) {
            code = 'K';
          } else {
            // Fehlendes `paid`-Feld = bezahlt (Abwärtskompatibilität).
            final paid = data['paid'] is bool ? data['paid'] as bool : true;
            code = paid ? 'U' : 'X';
          }
          final start = from.isBefore(first) ? first : from;
          final end = to.isAfter(last) ? last : to;
          for (var d = start;
              !d.isAfter(end);
              d = d.add(const Duration(days: 1))) {
            (result[tid] ??= <int, String>{})[d.day] = code;
          }
        }
      }
    } catch (_) {
      // Keine Abwesenheitsdaten erreichbar — dann bleibt die
      // Vorbelegung ohne 'U'/'X'/'K' und füllt nur die Wochenenden.
    }
    if (!mounted || _monthKey != key) return;
    setState(() => _absenceDaysByTid = result);
  }

  /// Automatisch vorgeschlagener Code für einen Tag — oder `''`, wenn die
  /// Automatik für diesen Tag nichts vorschlägt.
  ///
  /// Reihenfolge (bewusst so):
  ///  1. Nationale Feiertage bleiben unangetastet. Für sie gibt es die
  ///     eigene Aktion „Feiertage (N) eintragen"; die Wochenend-Regel
  ///     darf ihr weder vorgreifen noch widersprechen.
  ///  2. Samstag/Sonntag → 'F' (unbezahlt). Der Wochenendcode gewinnt
  ///     auch gegen einen Urlaubsantrag, der über das Wochenende läuft —
  ///     sonst würden Urlaubstage am Wochenende verbraucht.
  ///  3. Werktag innerhalb eines genehmigten Antrags → 'U' (Urlaub
  ///     bezahlt), 'X' (Urlaub unbezahlt) oder 'K' (Krankmeldung).
  String _autoCodeFor(DateTime date, Map<int, String> absenceDays) {
    if (isGermanyPublicHoliday(date)) return '';
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      return 'F';
    }
    return absenceDays[date.day] ?? '';
  }

  /// Vorbelegung je Fahrer für den angezeigten Monat:
  /// transporterId → Tag → Code. Nur Tage innerhalb des
  /// Beschäftigungszeitraums; Fahrer, deren Zeitraum den Monat nicht
  /// abdeckt, tauchen gar nicht auf.
  Map<String, Map<int, String>> _buildAutoCodes(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
    int daysInMonth,
  ) {
    final out = <String, Map<int, String>>{};
    if (!_autoFill) return out;
    for (final doc in drivers) {
      final data = doc.data();
      final tid = (data['transporterId'] ?? doc.id).toString().trim();
      if (tid.isEmpty) continue;
      final periods = employmentPeriodsOf(data);
      // Kein hinterlegter Zeitraum → keine Einschränkung möglich, der
      // Fahrer wird wie im Rest der Seite als ganzmonatig behandelt.
      final period = periods.isEmpty
          ? null
          : employmentPeriodForMonth(periods, _month);
      if (periods.isNotEmpty && period == null) continue;
      final absences =
          _absenceDaysByTid[tid.toUpperCase()] ?? const <int, String>{};
      final map = <int, String>{};
      for (var d = 1; d <= daysInMonth; d++) {
        final date = DateTime(_month.year, _month.month, d);
        if (period != null && !period.coversDay(date)) continue;
        final code = _autoCodeFor(date, absences);
        if (code.isNotEmpty) map[d] = code;
      }
      if (map.isNotEmpty) out[tid] = map;
    }
    return out;
  }

  Future<void> _pickCode(
    BuildContext cellContext,
    String tid,
    int day,
    String current,
    bool weekBlocked,
    bool monthBlocked, {
    /// True, wenn [current] nur automatisch vorbelegt ist (nichts
    /// gespeichert). Dann gibt es nichts zu „leeren", und der Admin
    /// bekommt stattdessen den Hinweis, dass jede Auswahl die
    /// Vorbelegung dauerhaft ersetzt.
    bool isAuto = false,
  }) async {
    final box = cellContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(cellContext).context.findRenderObject()
        as RenderBox?;
    if (box == null || overlay == null) return;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final picked = await showMenu<String>(
      context: cellContext,
      position: pos,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        if (isAuto) ...[
          PopupMenuItem<String>(
            enabled: false,
            height: 34,
            child: Row(
              children: [
                const Icon(Icons.auto_fix_high_rounded,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _tr('„$current" ist automatisch vorbelegt',
                        '"$current" is pre-filled automatically'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 6),
        ],
        for (final code in kDayCodes)
          PopupMenuItem<String>(
            value: code,
            height: 34,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _codeColor(code),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(code,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                if (_kSpesenCodes.contains(code))
                  Flexible(
                    child: Text(
                      _codeLabels[code] != null
                          ? '${_codeLabel(code)} · +${_money(_spesenRate)}'
                          : '+${_money(_spesenRate)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF1D7F5A)),
                    ),
                  )
                else if (_codeLabel(code) != null)
                  Flexible(
                    child: Text(
                      _codeLabel(code)!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ),
              ],
            ),
          ),
        // Nur wenn wirklich etwas gespeichert ist — eine rein
        // automatische Vorbelegung gibt es in Firestore nicht.
        if (current.isNotEmpty && !isAuto)
          PopupMenuItem<String>(
            value: '__clear__',
            height: 34,
            child: Row(
              children: [
                const Icon(Icons.backspace_outlined,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 8),
                Text(_tr('Leeren', 'Clear'),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        // Ticket: Code auf mehrere Tage gleichzeitig anwenden.
        if (current.isNotEmpty) ...[
          const PopupMenuDivider(height: 6),
          PopupMenuItem<String>(
            value: '__apply_mo_fr__',
            height: 36,
            child: Row(
              children: [
                const Icon(Icons.date_range_rounded,
                    size: 15, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  _tr('„$current" auf Mo–Fr anwenden',
                      'Apply "$current" to Mon–Fri'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: '__apply_week__',
            height: 36,
            child: Row(
              children: [
                const Icon(Icons.view_week_rounded,
                    size: 15, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  _tr('„$current" auf ganze Woche (Mo–Sa)',
                      'Apply "$current" to whole week (Mon–Sat)'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
        ],
        const PopupMenuDivider(height: 6),
        PopupMenuItem<String>(
          value: '__clear_week__',
          height: 36,
          child: Row(
            children: [
              const Icon(Icons.backspace_rounded,
                  size: 15, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Text(
                _tr('Ganze Woche leeren (Mo–Sa)',
                    'Clear whole week (Mon–Sat)'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 6),
        PopupMenuItem<String>(
          value: '__toggle_week__',
          height: 36,
          child: Row(
            children: [
              Icon(
                weekBlocked
                    ? Icons.restart_alt_rounded
                    : Icons.money_off_rounded,
                size: 15,
                color: const Color(0xFFF97316),
              ),
              const SizedBox(width: 8),
              Text(
                weekBlocked
                    ? _tr('Spesen wieder zahlen (KW ${_weekOfDay(day)})',
                        'Pay Spesen again (Wk ${_weekOfDay(day)})')
                    : _tr('No Spesen Week (KW ${_weekOfDay(day)})',
                        'No Spesen Week (Wk ${_weekOfDay(day)})'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC2410C),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: '__toggle_month__',
          height: 36,
          child: Row(
            children: [
              Icon(
                monthBlocked
                    ? Icons.restart_alt_rounded
                    : Icons.event_busy_rounded,
                size: 15,
                color: const Color(0xFFDC2626),
              ),
              const SizedBox(width: 8),
              Text(
                monthBlocked
                    ? _tr('Spesen wieder zahlen (Monat)',
                        'Pay Spesen again (month)')
                    : _tr('No Spesen Month (${_monthLabel()})',
                        'No Spesen Month (${_monthLabel()})'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (picked == null) return;
    if (picked == '__toggle_week__') {
      await _toggleWeekBlock(tid, _weekOfDay(day), !weekBlocked);
      return;
    }
    if (picked == '__toggle_month__') {
      await _toggleMonthBlock(tid, !monthBlocked);
      return;
    }
    if (picked == '__apply_mo_fr__') {
      await _applyCodeToWeek(tid, day, current, lastWeekday: 5);
      return;
    }
    if (picked == '__apply_week__') {
      await _applyCodeToWeek(tid, day, current, lastWeekday: 6);
      return;
    }
    if (picked == '__clear_week__') {
      await _clearWeek(tid, day);
      return;
    }
    await _setCode(tid, day, picked == '__clear__' ? null : picked);
  }

  // ─────────────────────── Roster import ───────────────────────

  String _dateKeyOf(int day) =>
      '$_monthKey-${day.toString().padLeft(2, '0')}';

  /// Hours of one shift block, parsed from labels like "9 Std." or
  /// "8 Std. 45 m".
  static double _blockHours(ShiftBlock b) {
    final s = b.duration;
    final h = RegExp(r'(\d+(?:[.,]\d+)?)\s*Std', caseSensitive: false)
        .firstMatch(s);
    final m = RegExp(r'(\d+)\s*m', caseSensitive: false).firstMatch(
        s.replaceFirst(RegExp(r'\d+(?:[.,]\d+)?\s*Std\.?',
            caseSensitive: false), ''));
    final hours =
        double.tryParse(h?.group(1)?.replaceAll(',', '.') ?? '') ?? 0;
    final minutes = double.tryParse(m?.group(1) ?? '') ?? 0;
    return hours + minutes / 60;
  }

  /// Roster rule: two shifts (e.g. 6h + 4h) → AC, one full shift
  /// (≥ 8h) → A, one short shift (4h/6h) → C.
  static String? _codeForBlocks(List<ShiftBlock> blocks) {
    if (blocks.isEmpty) return null;
    if (blocks.length >= 2) return 'AC';
    return _blockHours(blocks.first) >= 8 ? 'A' : 'C';
  }

  /// Schreibt die Roster-Einträge eines Tages. Gibt die Anzahl der
  /// befüllten Mitarbeiter zurück; [notify] steuert die Snackbar
  /// (beim Mehrtages-Import kommt EINE Sammelmeldung am Ende).
  Future<int> _applyRosterEntries(
    int day,
    List<ShiftPlanEntry> entries, {
    bool notify = true,
  }) async {
    final ref = _planRef;
    if (ref == null) return 0;
    final codes = <String, dynamic>{};
    for (final e in entries) {
      final tid = e.transporterId.trim();
      if (tid.isEmpty || e.lateCancel) continue;
      final code = _codeForBlocks(e.blocks);
      if (code == null) continue;
      codes[tid] = {'$day': code};
    }
    if (codes.isEmpty) {
      if (notify) {
        _snack(_tr('Keine Schichten für diesen Tag gefunden.',
            'No shifts found for this day.'));
      }
      return 0;
    }
    await ref.set({
      'entries': codes,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (notify) {
      _snack(_tr(
          '${codes.length} Mitarbeiter für den ${day.toString().padLeft(2, '0')}.${_month.month.toString().padLeft(2, '0')}. ausgefüllt.',
          '${codes.length} employees filled for ${_monthKey}-${day.toString().padLeft(2, '0')}.'));
    }
    return codes.length;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Modales Lade-Overlay: Spinner + „Bitte nicht aktualisieren"-Hinweis.
  /// Nicht wegklickbar; wird über [_hideBusyOverlay] geschlossen.
  void _showBusyOverlay(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF00B287),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _tr('Bitte den Browser nicht aktualisieren.',
                      "Please don't refresh the browser."),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _kMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideBusyOverlay() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _importRosterXlsx(int day) async {
    if (_rosterImporting) return;
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    final bytes = res?.files.single.bytes;
    if (bytes == null) return;
    setState(() => _rosterImporting = true);
    _showBusyOverlay(
        _tr('Roster wird gelesen …', 'Reading roster …'));
    ParsedShiftPlan parsed;
    try {
      parsed =
          await parseShiftPlanExcelAsync(bytes, assumeYear: _month.year);
    } catch (e) {
      _hideBusyOverlay();
      if (mounted) setState(() => _rosterImporting = false);
      _snack(_tr('Roster konnte nicht gelesen werden: $e',
          'Could not read roster: $e'));
      return;
    }
    _hideBusyOverlay();
    if (!mounted) {
      _rosterImporting = false;
      return;
    }

    // Ticket: Tage auswählbar — einzelne Tage oder die ganze Woche
    // (Mo–Sa) des angeklickten Tages. Nur Tage mit Roster-Daten sind
    // wählbar.
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final clickedDate = DateTime(_month.year, _month.month, day);
    final monday = day - (clickedDate.weekday - 1);
    final weekDays = <int>[
      for (var offset = 0; offset < 6; offset++) // Mo–Sa
        if (monday + offset >= 1 && monday + offset <= daysInMonth)
          monday + offset,
    ];
    final availability = <int, bool>{
      for (final d in weekDays)
        d: (parsed.assignmentsByDate[_dateKeyOf(d)]?.isNotEmpty ??
            false),
    };
    if (availability.values.every((v) => !v)) {
      if (mounted) setState(() => _rosterImporting = false);
      final days = parsed.availableDateKeys.join(', ');
      _snack(_tr(
          'Roster enthält keine Daten für diese Woche. Enthalten: $days',
          'Roster has no data for this week. Contains: $days'));
      return;
    }

    const wdDe = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const wdEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selected = <int>{
      if (availability[day] ?? false) day,
    };
    if (selected.isEmpty) {
      // Angeklickter Tag ohne Daten → alle verfügbaren vorschlagen.
      selected.addAll(weekDays.where((d) => availability[d] ?? false));
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final allAvailable =
              weekDays.where((d) => availability[d] ?? false).toList();
          final allSelected = allAvailable.isNotEmpty &&
              allAvailable.every(selected.contains);
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              _tr('Roster anwenden auf …', 'Apply roster to …'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800),
            ),
            content: SizedBox(
              width: 330,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ganze Woche (Mo–Sa) auf einen Klick.
                  InkWell(
                    onTap: () => setLocal(() {
                      if (allSelected) {
                        selected.clear();
                      } else {
                        selected
                          ..clear()
                          ..addAll(allAvailable);
                      }
                    }),
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      children: [
                        Checkbox(
                          value: allSelected,
                          activeColor: const Color(0xFF00B287),
                          onChanged: (_) => setLocal(() {
                            if (allSelected) {
                              selected.clear();
                            } else {
                              selected
                                ..clear()
                                ..addAll(allAvailable);
                            }
                          }),
                        ),
                        Expanded(
                          child: Text(
                            _tr('Ganze Woche (Mo–Sa)',
                                'Whole week (Mon–Sat)'),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _kText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 14),
                  for (final d in weekDays)
                    InkWell(
                      onTap: (availability[d] ?? false)
                          ? () => setLocal(() {
                                if (!selected.remove(d)) selected.add(d);
                              })
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: selected.contains(d),
                            activeColor: const Color(0xFF00B287),
                            onChanged: (availability[d] ?? false)
                                ? (_) => setLocal(() {
                                      if (!selected.remove(d)) {
                                        selected.add(d);
                                      }
                                    })
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              '${_tr(wdDe[DateTime(_month.year, _month.month, d).weekday - 1], wdEn[DateTime(_month.year, _month.month, d).weekday - 1])} '
                              '${d.toString().padLeft(2, '0')}.${_month.month.toString().padLeft(2, '0')}.'
                              '${(availability[d] ?? false) ? '' : _tr('  — keine Daten', '  — no data')}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: (availability[d] ?? false)
                                    ? _kText
                                    : _kMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(_tr('Abbrechen', 'Cancel')),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00B287)),
                onPressed: selected.isEmpty
                    ? null
                    : () => Navigator.pop(ctx, true),
                child: Text(_tr('Anwenden (${selected.length})',
                    'Apply (${selected.length})')),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true) {
      if (mounted) setState(() => _rosterImporting = false);
      return;
    }

    _showBusyOverlay(_tr('Roster wird übernommen …',
        'Applying roster …'));
    try {
      var totalEmployees = 0;
      final appliedDays = selected.toList()..sort();
      for (final d in appliedDays) {
        final entries = parsed.assignmentsByDate[_dateKeyOf(d)];
        if (entries == null || entries.isEmpty) continue;
        totalEmployees +=
            await _applyRosterEntries(d, entries, notify: false);
      }
      _hideBusyOverlay();
      _snack(_tr(
          '${appliedDays.length} Tag(e) ausgefüllt — $totalEmployees Einträge übernommen.',
          '${appliedDays.length} day(s) filled — $totalEmployees entries applied.'));
    } catch (e) {
      _hideBusyOverlay();
      _snack(_tr('Roster konnte nicht übernommen werden: $e',
          'Could not apply roster: $e'));
    } finally {
      if (mounted) setState(() => _rosterImporting = false);
    }
  }

  Future<void> _importFromSavedShiftPlan(int day) async {
    final uid = _uid;
    if (uid == null) return;
    final key = _dateKeyOf(day);
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('shift_plans')
        .doc(key)
        .get();
    final data = snap.data();
    final rawEntries = data?['entries'];
    if (!snap.exists || rawEntries is! List || rawEntries.isEmpty) {
      _snack(_tr('Kein gespeicherter Shift Plan für $key gefunden.',
          'No saved shift plan found for $key.'));
      return;
    }
    final entries = rawEntries
        .whereType<Map>()
        .map((e) => ShiftPlanEntry.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    await _applyRosterEntries(day, entries);
  }

  Future<void> _onDayHeaderTap(int day) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _tr('Tag ${day.toString().padLeft(2, '0')}.${_month.month.toString().padLeft(2, '0')}. automatisch ausfüllen',
              'Auto-fill day ${_dateKeyOf(day)}'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'xlsx'),
            child: Row(
              children: [
                const Icon(Icons.upload_file_rounded,
                    size: 18, color: Color(0xFF0F766E)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_tr('Roster (.xlsx) hochladen',
                      'Upload roster (.xlsx)')),
                ),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'plan'),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded,
                    size: 18, color: Color(0xFF1D4ED8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_tr('Aus gespeichertem Shift Plan übernehmen',
                      'Take from saved shift plan')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 4),
            child: Text(
              _tr('≥ 8 Std = A · kurze Schicht (4/6 Std) = C · zwei Schichten = AC',
                  '≥ 8h = A · short shift (4/6h) = C · two shifts = AC'),
              style: const TextStyle(fontSize: 11, color: _kMuted),
            ),
          ),
        ],
      ),
    );
    if (choice == 'xlsx') {
      await _importRosterXlsx(day);
    } else if (choice == 'plan') {
      await _importFromSavedShiftPlan(day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: Text('—')),
      );
    }
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    _loadPoorFairFlags();
    _loadSettings();
    if (_autoFill) _loadApprovedAbsences();

    // Ticket: Handy-Ansicht. Oberhalb von [_kNarrow] läuft exakt der
    // bisherige Code-Pfad (Matrix + Kopfzeile in einer Reihe). Die Breite
    // kommt aus den echten Constraints der Shell (nicht aus der Fenster-
    // breite), damit die Umschaltung auch neben der Sidebar stimmt.
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < _kNarrow;
            final pad = narrow ? 10.0 : 16.0;
            final legend = _legendText();

            final head = <Widget>[
              if (narrow) ..._narrowTopBar() else ...[
              // ── Header: title + month switcher ──
              Row(
                children: [
                  Text(
                    'Monthly Plan',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Ticket „not scrollable": Die Legende darf die Kopfzeile
                  // nicht mehr sprengen — sie schrumpft mit und kürzt bei
                  // Bedarf (voller Text im Tooltip). Vorher wurden Monats-
                  // navigation und Aktionen aus dem Fenster geschoben.
                  Flexible(
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Tooltip(
                        message: legend,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            legend,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => setState(() {
                      _month = DateTime(_month.year, _month.month - 1);
                    }),
                  ),
                  // Ticket: Monat per Klick auswählbar (Monats-Picker
                  // mit Jahres-Navigation, wie im Feedback-Screenshot).
                  InkWell(
                    onTap: _pickMonthDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _monthLabel(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _kText,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.arrow_drop_down_rounded,
                              size: 20, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => setState(() {
                      _month = DateTime(_month.year, _month.month + 1);
                    }),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: _showInactive
                        ? _tr('Nur aktive Fahrer zeigen',
                            'Show only active drivers')
                        : _tr('Inaktive Fahrer einblenden',
                            'Show inactive drivers'),
                    icon: Icon(
                      _showInactive
                          ? Icons.person_off_rounded
                          : Icons.person_off_outlined,
                      color: _showInactive
                          ? const Color(0xFF00B287)
                          : const Color(0xFF475569),
                    ),
                    onPressed: () =>
                        setState(() => _showInactive = !_showInactive),
                  ),
                  IconButton(
                    tooltip: _autoFill
                        ? _tr(
                            'Automatische Vorbelegung aus '
                                '(Urlaub U bezahlt / X unbezahlt · '
                                'Krank K · Wochenende F)',
                            'Turn off auto pre-fill '
                                '(vacation U paid / X unpaid · sick K · '
                                'weekend F)')
                        : _tr(
                            'Monat automatisch vorbelegen '
                                '(genehmigter Urlaub = U bezahlt / '
                                'X unbezahlt · genehmigte Krankmeldung = K '
                                '· Sa/So = F)',
                            'Pre-fill month automatically '
                                '(approved vacation = U paid / X unpaid · '
                                'approved sick leave = K · Sat/Sun = F)'),
                    icon: Icon(
                      _autoFill
                          ? Icons.auto_fix_high_rounded
                          : Icons.auto_fix_off_rounded,
                      color: _autoFill
                          ? const Color(0xFF00B287)
                          : const Color(0xFF475569),
                    ),
                    onPressed: _toggleAutoFill,
                  ),
                  IconButton(
                    tooltip: _tr('Nationale Feiertage (N) eintragen',
                        'Apply national holidays (N)'),
                    icon: const Icon(Icons.celebration_outlined,
                        color: Color(0xFF7C3AED)),
                    onPressed: _applyNationalHolidays,
                  ),
                  IconButton(
                    tooltip: _tr(
                        'Monatsplan-Einstellungen '
                            '(Spesensatz, Beschriftungen)',
                        'Monthly plan settings (rate, labels)'),
                    icon: const Icon(Icons.settings_outlined,
                        color: Color(0xFF475569)),
                    onPressed: _openSettings,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Controls: search + sort (ticket) ──
              Row(
                children: [
                  SizedBox(
                    width: 280,
                    height: 38,
                    child: _searchField(),
                  ),
                  const SizedBox(width: 8),
                  _sortButton(),
                ],
              ),
              ],
              const SizedBox(height: 12),
            ];

            // ── Grid ──
            final plan =
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('drivers')
                      .snapshots(),
                  builder: (context, driverSnap) {
                    final drivers = (driverSnap.data?.docs ?? const [])
                        .where((d) =>
                            _showInactive || isDriverWorking(d.data()))
                        .where((d) {
                          if (_search.isEmpty) return true;
                          final data = d.data();
                          final name = (data['driverName'] ?? '')
                              .toString()
                              .toLowerCase();
                          final tid = (data['transporterId'] ?? d.id)
                              .toString()
                              .toLowerCase();
                          // Ticket: auch nach Personalnummer (Employee ID)
                          // filtern — führende Nullen tolerant behandeln.
                          final empNo = (data['employeeNumber'] ?? '')
                              .toString()
                              .toLowerCase();
                          String deZero(String s) =>
                              s.replaceFirst(RegExp(r'^0+'), '');
                          final empMatch = empNo.isNotEmpty &&
                              (empNo.contains(_search) ||
                                  (deZero(empNo).isNotEmpty &&
                                      deZero(empNo)
                                          .contains(deZero(_search))));
                          return name.contains(_search) ||
                              tid.contains(_search) ||
                              empMatch;
                        })
                        .toList()
                      ..sort((a, b) {
                        // Ticket: group by contract type (Minijob → Teilzeit
                        // → Dispatch → Vollzeit), then by work start date —
                        // not alphabetically.
                        int rank(dynamic doc) => _contractGroupRank(
                            DriverContractType.fromValue(
                                doc.data()['contractType']));

                        // Startdatum = derselbe Vertragsbeginn, der unter dem
                        // Namen steht bzw. im Drivers Hub als „aktiv seit"
                        // erscheint (employmentPeriods, sonst der Legacy-Wert
                        // onboarding.workStartDate im Format dd/MM/yyyy).
                        // Ohne Startdatum ans Ende der Gruppe.
                        DateTime startOf(dynamic doc) {
                          final data =
                              Map<String, dynamic>.from(doc.data() as Map);
                          final periods = employmentPeriodsOf(data);
                          final start =
                              employmentPeriodForMonth(periods, _month)
                                      ?.startDate ??
                                  (periods.isEmpty
                                      ? null
                                      : periods.first.startDate);
                          return start ?? DateTime(2100);
                        }

                        String nameOf(dynamic doc) =>
                            (doc.data()['driverName'] ?? '')
                                .toString()
                                .toLowerCase();

                        String tidOf(dynamic doc) =>
                            (doc.data()['transporterId'] ?? doc.id)
                                .toString()
                                .toLowerCase();

                        switch (_sortMode) {
                          case 'name':
                            return nameOf(a).compareTo(nameOf(b));
                          case 'start':
                            final s = startOf(a).compareTo(startOf(b));
                            if (s != 0) return s;
                            return nameOf(a).compareTo(nameOf(b));
                          case 'tid':
                            return tidOf(a).compareTo(tidOf(b));
                          default:
                            final r = rank(a).compareTo(rank(b));
                            if (r != 0) return r;
                            final s = startOf(a).compareTo(startOf(b));
                            if (s != 0) return s;
                            return nameOf(a).compareTo(nameOf(b));
                        }
                      });

                    return StreamBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      stream: _planRef!.snapshots(),
                      builder: (context, planSnap) {
                        final planData = planSnap.data?.data();
                        final raw = planData?['entries'];
                        final entries = raw is Map
                            ? Map<String, dynamic>.from(raw)
                            : const <String, dynamic>{};
                        final blockedRaw = planData?['blockedWeeks'];
                        final blockedWeeks = blockedRaw is Map
                            ? Map<String, dynamic>.from(blockedRaw)
                            : const <String, dynamic>{};
                        final blockedMonthsRaw = planData?['blockedMonths'];
                        final blockedMonths = blockedMonthsRaw is Map
                            ? Map<String, dynamic>.from(blockedMonthsRaw)
                            : const <String, dynamic>{};

                        bool monthBlocked(String tid) =>
                            blockedMonths[tid] == true;

                        // Nur das, was tatsächlich in Firestore steht.
                        String storedCodeOf(String tid, int day) {
                          final m = entries[tid];
                          if (m is! Map) return '';
                          return (m['$day'] ?? '').toString();
                        }

                        // Anzeige-Vorbelegung (U/F). Wird nie gespeichert.
                        final autoCodes =
                            _buildAutoCodes(drivers, daysInMonth);

                        // Die Vorbelegung greift ausschließlich dort, wo
                        // noch gar nichts eingetragen ist — ein manueller
                        // Wert gewinnt immer.
                        bool isAuto(String tid, int day) =>
                            storedCodeOf(tid, day).isEmpty &&
                            (autoCodes[tid]?[day] ?? '').isNotEmpty;

                        String codeOf(String tid, int day) {
                          final stored = storedCodeOf(tid, day);
                          if (stored.isNotEmpty) return stored;
                          return autoCodes[tid]?[day] ?? '';
                        }

                        bool weekBlocked(String tid, int week) {
                          final m = blockedWeeks[tid];
                          if (m is Map && m.containsKey('$week')) {
                            return m['$week'] == true; // manual override
                          }
                          if (monthBlocked(tid)) return true;
                          // Automatic rule: scorecard bucket not
                          // entitled to Spesen (settings).
                          final bucket = _bucketByWeek[week]?[tid];
                          if (bucket == null) return false;
                          return !_spesenBuckets.contains(bucket);
                        }

                        int spesenDays(String tid) {
                          var n = 0;
                          for (var d = 1; d <= daysInMonth; d++) {
                            if (weekBlocked(tid, _weekOfDay(d))) continue;
                            if (_kSpesenCodes.contains(codeOf(tid, d))) n++;
                          }
                          return n;
                        }

                        // Monats-Gesamtsumme: Spesen-Tage aller
                        // berechtigten Mitarbeiter und der daraus
                        // resultierende Betrag.
                        final totalDays = drivers.fold<int>(
                          0,
                          (total, d) {
                            // Contract types deselected in the
                            // settings never receive Spesen.
                            if (!_contractEligible(
                                DriverContractType.fromValue(
                                    d.data()['contractType']))) {
                              return total;
                            }
                            return total +
                                spesenDays((d.data()['transporterId'] ?? d.id)
                                    .toString()
                                    .trim());
                          },
                        );
                        final totalEur = totalDays * _spesenRate;

                        // Ticket: in der schmalen Ansicht ist ggf. die
                        // Tagesliste eines Fahrers geöffnet.
                        QueryDocumentSnapshot<Map<String, dynamic>>? detail;
                        if (narrow && _detailTid != null) {
                          for (final d in drivers) {
                            final tid = (d.data()['transporterId'] ?? d.id)
                                .toString()
                                .trim();
                            if (tid == _detailTid) {
                              detail = d;
                              break;
                            }
                          }
                          // Fällt der Fahrer durch Suche/Filter/Monats-
                          // wechsel weg, zurück zur Liste.
                          if (detail == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && _detailTid != null) {
                                setState(() => _detailTid = null);
                              }
                            });
                          }
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _kBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                child: detail != null
                                    ? _narrowDetailBar(detail, spesenDays)
                                    : Row(
                                  children: [
                                    Text(
                                      _tr(
                                          '${drivers.length} Mitarbeiter',
                                          '${drivers.length} employees'),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _kMuted,
                                      ),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                      child: Text(
                                        '${_tr('Spesen gesamt: ', 'Total Spesen: ')}'
                                        '$totalDays ${_tr('Tage', 'days')} · '
                                        '${_money(totalEur)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF065F46),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: _kBorder),
                              Expanded(
                                child: drivers.isEmpty
                                    ? Center(
                                        child: Text(
                                          _tr('Keine aktiven Mitarbeiter.',
                                              'No active employees.'),
                                          style: const TextStyle(
                                              color: _kMuted),
                                        ),
                                      )
                                    : narrow
                                        ? (detail != null
                                            ? _narrowDayList(
                                                detail, daysInMonth,
                                                codeOf, isAuto,
                                                weekBlocked,
                                                monthBlocked)
                                            : _narrowDriverList(
                                                drivers, daysInMonth,
                                                codeOf, spesenDays))
                                        : _grid(
                                            drivers, daysInMonth, codeOf,
                                            isAuto, spesenDays,
                                            weekBlocked, monthBlocked),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );

            // Ticket „It's not scrollable": Reicht die von der Shell
            // gelieferte Höhe nicht für Kopfbereich + Plan, wird die
            // ganze Seite vertikal scrollbar (statt zu überlaufen) und der
            // Planbereich behält seine Mindesthöhe.
            const minPlanH = 320.0;
            final roomForPlan =
                constraints.maxHeight - 2 * pad - (narrow ? 300.0 : 120.0);
            if (roomForPlan >= minPlanH) {
              return Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...head, Expanded(child: plan)],
                ),
              );
            }
            return ScrollConfiguration(
              behavior: _dragScrollBehavior(context),
              child: Scrollbar(
              controller: _vPage,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _vPage,
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...head,
                      SizedBox(height: minPlanH, child: plan),
                    ],
                  ),
                ),
              ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ───────────────────── Shared controls ─────────────────────

  /// Suchfeld (Name / TID / Personalnummer). Desktop rendert es in einer
  /// 280×38-Box, die schmale Ansicht über die volle Breite.
  Widget _searchField() {
    return TextField(
      controller: _searchCtrl,
      focusNode: _searchFocus,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFF9CA3AF),
          size: 18,
        ),
        suffixIcon: buildSearchClearButton(
          context: context,
          value: _search,
          focusNode: _searchFocus,
          iconSize: 16,
          onClear: () {
            _searchCtrl.clear();
            setState(() => _search = '');
          },
        ),
        // The desktop box is only 38px tall — keep the X height-neutral.
        suffixIconConstraints: kSearchClearConstraintsCompact,
        hintText: _tr('Name, TID oder Personalnr. suchen…',
            'Search name, TID or employee ID…'),
        hintStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9CA3AF),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF00B287), width: 1.4),
        ),
      ),
      onChanged: (value) =>
          setState(() => _search = value.trim().toLowerCase()),
    );
  }

  /// Sortier-Auswahl. Defaults = bisherige Desktop-Darstellung.
  Widget _sortButton({double height = 38, bool expand = false}) {
    final label = Text(
      switch (_sortMode) {
        'name' => _tr('Name A–Z', 'Name A–Z'),
        'start' => _tr('Vertragsbeginn', 'Contract start'),
        'tid' => 'Transporter-ID',
        _ => _tr('Vertragsgruppe', 'Contract group'),
      },
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    );
    return PopupMenuButton<String>(
      tooltip: _tr('Sortieren', 'Sort'),
      position: PopupMenuPosition.under,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) => setState(() => _sortMode = v),
      itemBuilder: (ctx) => [
        for (final opt in [
          ('contract',
              _tr('Vertragsgruppe (Standard)', 'Contract group (default)')),
          ('name', _tr('Name A–Z', 'Name A–Z')),
          ('start', _tr('Vertragsbeginn', 'Contract start')),
          ('tid', 'Transporter-ID'),
        ])
          PopupMenuItem<String>(
            value: opt.$1,
            height: 38,
            child: Row(
              children: [
                Icon(
                  _sortMode == opt.$1
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 16,
                  color: _sortMode == opt.$1
                      ? const Color(0xFF00B287)
                      : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 8),
                Text(opt.$2, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
      ],
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder, width: 0.8),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded,
                size: 17, color: Color(0xFF475569)),
            const SizedBox(width: 6),
            // Nur in der schmalen Ansicht ist die Breite gebunden — ohne
            // `expand` würde ein Flexible in unbounded Constraints werfen.
            if (expand) Flexible(child: label) else label,
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Schmale Ansicht (< 700 px) ─────────────────────

  /// Kopfbereich der Handy-Ansicht: Titel + Aktionsmenü, Monatsnavigation,
  /// Legende und — solange die Fahrerliste sichtbar ist — Suche, Sortierung
  /// und der Schalter für inaktive Fahrer. Alles untereinander, damit
  /// nichts überläuft.
  List<Widget> _narrowTopBar() {
    final detailOpen = _detailTid != null;
    return [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Monthly Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
          ),
          _narrowMoreMenu(),
        ],
      ),
      const SizedBox(height: 8),
      // ── Monatsnavigation ──
      Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder, width: 0.8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              height: 46,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: _tr('Vorheriger Monat', 'Previous month'),
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                }),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: _pickMonthDialog,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 46,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _monthLabel(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _kText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_drop_down_rounded,
                          size: 20, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 46,
              height: 46,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: _tr('Nächster Monat', 'Next month'),
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                }),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // ── Legende ──
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _legendText(),
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: Color(0xFF065F46),
          ),
        ),
      ),
      if (!detailOpen) ...[
        const SizedBox(height: 8),
        SizedBox(height: 44, child: _searchField()),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _sortButton(height: 44, expand: true)),
            const SizedBox(width: 8),
            Tooltip(
              message: _showInactive
                  ? _tr('Nur aktive Fahrer zeigen', 'Show only active drivers')
                  : _tr('Inaktive Fahrer einblenden', 'Show inactive drivers'),
              child: InkWell(
                onTap: () => setState(() => _showInactive = !_showInactive),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 46,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _showInactive
                        ? const Color(0xFFDCFCE7)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _showInactive
                          ? const Color(0xFF00B287)
                          : _kBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    _showInactive
                        ? Icons.person_off_rounded
                        : Icons.person_off_outlined,
                    size: 20,
                    color: _showInactive
                        ? const Color(0xFF00B287)
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ];
  }

  /// Sammelaktionen der Kopfzeile, die auf dem Handy nicht nebeneinander
  /// passen: Feiertage eintragen, Spesen-Einstellungen, Tag aus Roster
  /// füllen (in der Matrix hängt das am Klick auf den Tages-Spaltenkopf).
  Widget _narrowMoreMenu() {
    return PopupMenuButton<String>(
      tooltip: _tr('Aktionen', 'Actions'),
      position: PopupMenuPosition.under,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF475569)),
      onSelected: (v) async {
        switch (v) {
          case 'roster':
            await _pickDayForRoster();
          case 'autofill':
            await _toggleAutoFill();
          case 'holidays':
            await _applyNationalHolidays();
          case 'settings':
            await _openSettings();
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem<String>(
          value: 'autofill',
          height: 46,
          child: Row(
            children: [
              Icon(
                _autoFill
                    ? Icons.auto_fix_high_rounded
                    : Icons.auto_fix_off_rounded,
                size: 18,
                color: _autoFill
                    ? const Color(0xFF00B287)
                    : const Color(0xFF475569),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _autoFill
                      ? _tr('Automatische Vorbelegung aus',
                          'Turn off auto pre-fill')
                      : _tr('Monat automatisch vorbelegen (U / F)',
                          'Pre-fill month automatically (U / F)'),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'roster',
          height: 46,
          child: Row(
            children: [
              const Icon(Icons.upload_file_rounded,
                  size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Text(_tr('Tag aus Roster ausfüllen', 'Fill day from roster'),
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'holidays',
          height: 46,
          child: Row(
            children: [
              const Icon(Icons.celebration_outlined,
                  size: 18, color: Color(0xFF7C3AED)),
              const SizedBox(width: 10),
              Text(
                  _tr('Nationale Feiertage (N) eintragen',
                      'Apply national holidays (N)'),
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          height: 46,
          child: Row(
            children: [
              const Icon(Icons.settings_outlined,
                  size: 18, color: Color(0xFF475569)),
              const SizedBox(width: 10),
              Text(
                  _tr('Monatsplan-Einstellungen',
                      'Monthly plan settings'),
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  /// Tag auswählen, für den der Roster-Import laufen soll — Ersatz für den
  /// Klick auf den Tages-Spaltenkopf der Matrix.
  Future<void> _pickDayForRoster() async {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    const wdDe = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const wdEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _tr('Welcher Tag?', 'Which day?'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var d = 1; d <= daysInMonth; d++)
                  Builder(builder: (_) {
                    final date = DateTime(_month.year, _month.month, d);
                    final sunday = date.weekday == 7;
                    return InkWell(
                      onTap: () => Navigator.pop(ctx, d),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sunday
                              ? const Color(0xFFEFF3F6)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kBorder, width: 0.8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (_de ? wdDe : wdEn)[date.weekday - 1],
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: _kMuted,
                              ),
                            ),
                            Text(
                              '$d',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _kText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_tr('Abbrechen', 'Cancel')),
          ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    await _onDayHeaderTap(picked);
  }

  /// Eine Kennzahl der Monatszusammenfassung (Arbeit / Urlaub / Krank …).
  Widget _statChip(String label, String value, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
          const SizedBox(width: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }

  /// Stufe 1 der Handy-Ansicht: eine Karte je Fahrer mit Name,
  /// Personalnummer / Transporter-ID, Beschäftigungszeile und der
  /// Monatszusammenfassung (Arbeitstage, Urlaub, Krank, offene Tage,
  /// Spesen). Tippen öffnet die Tagesliste.
  Widget _narrowDriverList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
    int daysInMonth,
    String Function(String tid, int day) codeOf,
    int Function(String tid) spesenDays,
  ) {
    // Gleiche Gruppierung wie in der Matrix: Minijob → Teilzeit →
    // Dispatch → Vollzeit, innerhalb der Gruppe nach Vertragsbeginn.
    final planRows = _planRows(drivers);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      itemCount: planRows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = planRows[index];
        if (row.index < 0) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 6, bottom: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _groupHeader(row.rank, row.count),
            ),
          );
        }
        final i = row.index;
        final doc = drivers[i];
        final data = doc.data();
        final tid = (data['transporterId'] ?? doc.id).toString().trim();
        final contract = DriverContractType.fromValue(data['contractType']);
        final abbr = _contractAbbr(contract);
        final isMinijob = contract == DriverContractType.minijob;
        final eligible = _contractEligible(contract);

        var work = 0;
        var vacation = 0;
        // Unbezahlter Urlaub (X) wird separat ausgewiesen — er wird dem
        // Zeitkonto NICHT gutgeschrieben.
        var unpaidVacation = 0;
        var sick = 0;
        var open = 0;
        for (var d = 1; d <= daysInMonth; d++) {
          final code = codeOf(tid, d);
          if (code.isEmpty) {
            // Sonntage sind frei — wie in der „fehlt"-Zeile der Matrix.
            if (DateTime(_month.year, _month.month, d).weekday != 7) open++;
            continue;
          }
          if (_kWorkCodes.contains(code)) {
            work++;
          } else if (code == 'U') {
            vacation++;
          } else if (code == 'X') {
            unpaidVacation++;
          } else if (code == 'K') {
            sick++;
          }
        }
        final days = eligible ? spesenDays(tid) : 0;
        final eur = days * _spesenRate;

        final empNo = (data['employeeNumber'] ?? '').toString().trim();
        final sub = [
          if (empNo.isNotEmpty) '${_tr('Nr.', 'No.')} $empNo',
          if (tid.isNotEmpty) tid,
        ].join(' · ');

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _detailTid = tid),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (abbr.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isMinijob
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  abbr,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isMinijob
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                (data['driverName'] ?? '—').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _kText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (sub.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: _kMuted),
                            ),
                          ),
                        _employmentLine(data),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _statChip(
                              _tr('Arbeit', 'Work'),
                              '$work',
                              const Color(0xFF065F46),
                              const Color(0xFFD1FAE5),
                            ),
                            _statChip(
                              _tr('Urlaub', 'Vacation'),
                              '$vacation',
                              const Color(0xFF6D28D9),
                              const Color(0xFFEDE9FE),
                            ),
                            if (unpaidVacation > 0)
                              _statChip(
                                _tr('Urlaub unbez.', 'Vacation unpaid'),
                                '$unpaidVacation',
                                const Color(0xFF9A3412),
                                const Color(0xFFFFEDD5),
                              ),
                            _statChip(
                              _tr('Krank', 'Sick'),
                              '$sick',
                              const Color(0xFFBE123C),
                              const Color(0xFFFFE4E6),
                            ),
                            if (open > 0)
                              _statChip(
                                _tr('offen', 'open'),
                                '$open',
                                const Color(0xFFC2410C),
                                const Color(0xFFFFF7ED),
                              ),
                            _statChip(
                              'Spesen',
                              eligible
                                  ? '$days ${_tr('Tage', 'days')} · '
                                      '${_money(eur)}'
                                  : '—',
                              eligible
                                  ? const Color(0xFF065F46)
                                  : _kMuted,
                              eligible
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFF3F4F6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 22, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Kopfzeile der Tagesliste: zurück zur Fahrerliste + Spesen des Fahrers.
  Widget _narrowDetailBar(
    QueryDocumentSnapshot<Map<String, dynamic>> driver,
    int Function(String tid) spesenDays,
  ) {
    final data = driver.data();
    final tid = (data['transporterId'] ?? driver.id).toString().trim();
    final eligible = _contractEligible(
        DriverContractType.fromValue(data['contractType']));
    final days = eligible ? spesenDays(tid) : 0;
    final eur = days * _spesenRate;
    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: _tr('Zurück zur Fahrerliste', 'Back to driver list'),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () => setState(() => _detailTid = null),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (data['driverName'] ?? '—').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              Text(
                '$tid · ${_monthLabel()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: _kMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          eligible
              ? '$days ${_tr('T', 'd')} · ${_money(eur)}'
              : '—',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: eligible ? const Color(0xFF065F46) : _kMuted,
          ),
        ),
      ],
    );
  }

  /// Standard-Klartext für die dokumentierten Codes; alle übrigen Codes
  /// stehen für sich (die Matrix zeigt dort ebenfalls nur das Kürzel),
  /// bis der Admin in den Einstellungen eine Beschriftung hinterlegt.
  String? _defaultCodeLabel(String code) => switch (code) {
        'U' => _tr('Urlaub (bezahlt)', 'Vacation (paid)'),
        'X' => _tr('Urlaub (unbezahlt)', 'Vacation (unpaid)'),
        'K' => _tr('Krank', 'Sick'),
        'N' => _tr('Feiertag', 'Public holiday'),
        'AB' => _tr('AB-Schicht (mit Spesen)', 'AB shift (with Spesen)'),
        'OSM' => _tr('OSM (ohne Spesen)', 'OSM (no Spesen)'),
        _ => null,
      };

  /// Beschriftung eines Codes: eigene Bezeichnung aus den Einstellungen,
  /// sonst der Standardtext. `null`, wenn beides fehlt.
  String? _codeLabel(String code) {
    final custom = _codeLabels[code]?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return _defaultCodeLabel(code);
  }

  /// Geldbetrag in der Sprache des Admins („14 €" / „14,50 €").
  String _money(double v) {
    final s = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
    return '${_de ? s.replaceAll('.', ',') : s} €';
  }

  /// Legende des Kopfbereichs — nutzt den konfigurierten Spesensatz und
  /// die (ggf. eigenen) Beschriftungen aller Codes.
  String _legendText() {
    final spesenCodes =
        kDayCodes.where(_kSpesenCodes.contains).join(' / ');
    final parts = <String>[
      '$spesenCodes = ${_money(_spesenRate)} '
          '${_tr('pro Tag', 'per day')}',
      for (final c in kDayCodes)
        if (!_kSpesenCodes.contains(c) && _codeLabel(c) != null)
          '$c = ${_codeLabel(c)}',
      for (final c in kDayCodes)
        if (_kSpesenCodes.contains(c) && _codeLabels[c] != null)
          '$c = ${_codeLabel(c)}',
      _tr('U / X / K = keine Spesen', 'U / X / K = no Spesen'),
      _tr('Poor/Fair-Woche = automatisch gestrichen',
          'poor/fair week = auto-cancelled'),
    ];
    return parts.join(' · ') + (_autoFill ? _autoLegendSuffix() : '');
  }

  /// Stufe 2 der Handy-Ansicht: die Tage des Monats untereinander. Tippen
  /// öffnet dasselbe [_pickCode]-Menü wie eine Matrix-Zelle — gleiche
  /// Codes, gleiche Schreiblogik, inkl. Wochen-/Monats-Sperre und
  /// „auf ganze Woche anwenden".
  Widget _narrowDayList(
    QueryDocumentSnapshot<Map<String, dynamic>> driver,
    int daysInMonth,
    String Function(String tid, int day) codeOf,
    bool Function(String tid, int day) isAuto,
    bool Function(String tid, int week) weekBlocked,
    bool Function(String tid) monthBlocked,
  ) {
    final data = driver.data();
    final tid = (data['transporterId'] ?? driver.id).toString().trim();
    const wdDe = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const wdEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final mm = _month.month.toString().padLeft(2, '0');

    final rows = <Widget>[];
    var shownWeek = -1;
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      final week = _weekOfDay(d);
      final blocked = weekBlocked(tid, week);

      if (week != shownWeek) {
        shownWeek = week;
        rows.add(
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              color: Color(0xFFEDF2F7),
              border: Border(
                bottom: BorderSide(color: Color(0xFFCBD5E1), width: 0.8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _tr('KW $week', 'Wk $week'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                ),
                if (blocked) ...[
                  const Spacer(),
                  const Icon(Icons.money_off_rounded,
                      size: 13, color: Color(0xFFF97316)),
                  const SizedBox(width: 4),
                  Text(
                    _tr('keine Spesen', 'no Spesen'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC2410C),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      final code = codeOf(tid, d);
      final auto = isAuto(tid, d);
      final sunday = date.weekday == 7;
      final saturday = date.weekday == 6;
      final note = <String>[
        if (_codeLabel(code) != null) _codeLabel(code)!,
        if (auto) _tr('automatisch', 'automatic'),
        if (_kSpesenCodes.contains(code))
          blocked
              ? _tr('${_money(_spesenRate)} gestrichen',
                  '${_money(_spesenRate)} cancelled')
              : '+${_money(_spesenRate)}',
        if (code.isEmpty) _tr('kein Eintrag', 'no entry'),
      ].join(' · ');

      rows.add(
        Builder(
          builder: (rowContext) => InkWell(
            onTap: () => _pickCode(
                rowContext, tid, d, code, blocked, monthBlocked(tid),
                isAuto: auto),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: sunday
                    ? const Color(0xFFEFF3F6)
                    : (saturday ? const Color(0xFFF6F7F9) : Colors.white),
                border: blocked
                    ? Border.all(color: const Color(0xFFF97316), width: 1.5)
                    : const Border(
                        bottom: BorderSide(
                            color: Color(0xFFEDF0F3), width: 0.8),
                      ),
              ),
              child: Row(
                children: [
                  // Farbakzent des Codes — dieselbe Palette wie die Zellen.
                  Container(width: 5, color: _codeColor(code)),
                  const SizedBox(width: 9),
                  SizedBox(
                    width: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_de ? wdDe : wdEn)[date.weekday - 1],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: (sunday || saturday)
                                ? const Color(0xFF94A3B8)
                                : _kMuted,
                          ),
                        ),
                        Text(
                          '${d.toString().padLeft(2, '0')}.$mm.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _kText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: code.isEmpty
                          ? const Color(0xFFF9FAFB)
                          : (auto
                              // Vorbelegung blasser als eine echte
                              // Eintragung.
                              ? Color.alphaBlend(
                                  _codeColor(code).withValues(alpha: 0.38),
                                  Colors.white)
                              : _codeColor(code)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: code.isEmpty || auto
                              ? _kBorder
                              : Colors.transparent,
                          width: 0.8),
                    ),
                    child: Text(
                      code.isEmpty ? '–' : code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            auto ? FontWeight.w600 : FontWeight.w800,
                        fontStyle:
                            auto ? FontStyle.italic : FontStyle.normal,
                        color: code.isEmpty
                            ? const Color(0xFF9CA3AF)
                            : (auto
                                ? const Color(0xFF64748B)
                                : const Color(0xFF1F2937)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _kMuted,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_outlined,
                      size: 16, color: Color(0xFFB6BDC7)),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: rows,
    );
  }

  Widget _grid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers,
    int daysInMonth,
    String Function(String tid, int day) codeOf,
    bool Function(String tid, int day) isAuto,
    int Function(String tid) spesenDays,
    bool Function(String tid, int week) weekBlocked,
    bool Function(String tid) monthBlocked,
  ) {
    const wd = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const wdEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const kwRowH = 20.0;
    bool isSunday(int day) =>
        DateTime(_month.year, _month.month, day).weekday == 7;
    bool isMonday(int day) =>
        DateTime(_month.year, _month.month, day).weekday == 1;

    // Contiguous calendar-week segments within this month: (week, start, end).
    final weekSegments = <(int, int, int)>[];
    var segStart = 1;
    var segWeek = _weekOfDay(1);
    for (var d = 2; d <= daysInMonth; d++) {
      final w = _weekOfDay(d);
      if (w != segWeek) {
        weekSegments.add((segWeek, segStart, d - 1));
        segStart = d;
        segWeek = w;
      }
    }
    weekSegments.add((segWeek, segStart, daysInMonth));

    // Ticket: laufende Nummer pro Vertragsgruppe — startet bei jedem
    // Gruppenwechsel neu bei 1. Gruppen wie in der Standard-Sortierung:
    // alle Teilzeit-Typen zählen als EINE Gruppe.
    int numberGroup(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
        _contractGroupRank(
            DriverContractType.fromValue(doc.data()['contractType']));

    final groupNumbers = List<int>.filled(drivers.length, 0);
    var prevGroup = -1;
    var groupCounter = 0;
    for (var i = 0; i < drivers.length; i++) {
      final g = numberGroup(drivers[i]);
      if (g != prevGroup) {
        groupCounter = 1;
        prevGroup = g;
      } else {
        groupCounter++;
      }
      groupNumbers[i] = groupCounter;
    }

    // Zeilenfolge inkl. Gruppen-Kopfzeilen (Ticket: Minijob → Teilzeit →
    // Dispatch → Vollzeit). Namen-, Tages- und Summenspalte laufen über
    // dieselbe Liste, damit die Zeilen zeilengenau übereinanderliegen.
    final planRows = _planRows(drivers);
    final matrixW = daysInMonth * _cellW;

    const missRowH = 17.0;
    const freeRowH = 17.0;
    final headerH = _rowH + 6 + kwRowH + missRowH + freeRowH;

    String tidOf(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
        (d.data()['transporterId'] ?? d.id).toString().trim();

    // Ticket: pro KW zählen, wie viele Mitarbeiter mindestens einen
    // U/F/K/X-Tag haben — Wochenübersicht "wie viele sind frei".
    const freeCodes = ['U', 'F', 'K', 'X'];
    Map<String, int> freeCountsFor(int start, int end) {
      final counts = <String, int>{for (final c in freeCodes) c: 0};
      var total = 0;
      for (final dr in drivers) {
        final tid = tidOf(dr);
        final seen = <String>{};
        for (var d = start; d <= end; d++) {
          final c = codeOf(tid, d);
          // Das automatische Wochenend-'F' bleibt hier außen vor —
          // sonst hätte jede Woche zwangsläufig „alle frei" und die
          // Zeile verlöre ihren Informationswert. Automatischer
          // Urlaub (U) zählt dagegen mit.
          if (c == 'F' && isAuto(tid, d)) continue;
          if (freeCodes.contains(c)) seen.add(c);
        }
        if (seen.isNotEmpty) total++;
        for (final c in seen) {
          counts[c] = counts[c]! + 1;
        }
      }
      counts['total'] = total;
      return counts;
    }

    final freeRow = Row(
      children: [
        for (final (week, start, end) in weekSegments)
          Builder(builder: (context) {
            final counts = freeCountsFor(start, end);
            final total = counts['total']!;
            final breakdown = freeCodes
                .map((c) => '$c ${counts[c]}')
                .join(' · ');
            return Tooltip(
              message: _tr(
                  'KW $week: $total Mitarbeiter mit freien Tagen '
                      '($breakdown)',
                  'Wk $week: $total employees with days off '
                      '($breakdown)'),
              waitDuration: const Duration(milliseconds: 400),
              child: Container(
                width: (end - start + 1) * _cellW,
                height: freeRowH,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F3FF),
                  border: Border(
                    left: BorderSide(color: Color(0xFFCBD5E1), width: 1),
                    bottom:
                        BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
                  ),
                ),
                child: Text(
                  total == 0
                      ? '–'
                      : _tr('$total frei', '$total off'),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: total == 0
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF7C3AED),
                  ),
                ),
              ),
            );
          }),
      ],
    );

    // Per day: how many employees still have no code entered.
    int missingOn(int day) =>
        drivers.where((dr) => codeOf(tidOf(dr), day).isEmpty).length;

    final missingRow = Row(
      children: [
        for (var d = 1; d <= daysInMonth; d++)
          Builder(builder: (context) {
            // Sundays are off days — no missing-entry tracking.
            if (isSunday(d)) {
              return Container(
                width: _cellW,
                height: missRowH,
                color: const Color(0xFFEFF3F6),
              );
            }
            final missing = missingOn(d);
            return Tooltip(
              message: _tr('$missing fehlende Eintragungen',
                  '$missing missing entries'),
              waitDuration: const Duration(milliseconds: 600),
              child: Container(
                width: _cellW,
                height: missRowH,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: isMonday(d)
                      ? const Border(
                          left: BorderSide(
                              color: Color(0xFFCBD5E1), width: 1))
                      : null,
                ),
                child: missing == 0
                    ? const Icon(Icons.check_rounded,
                        size: 11, color: Color(0xFF059669))
                    : Text(
                        '$missing',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEA580C),
                        ),
                      ),
              ),
            );
          }),
      ],
    );

    // ── Pinned header rows (KW segments + clickable days) ──
    final kwHeaderRow = Row(
      children: [
        for (final (week, start, end) in weekSegments)
          Container(
            width: (end - start + 1) * _cellW,
            height: kwRowH,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEDF2F7),
              border: Border(
                left: BorderSide(color: Color(0xFFCBD5E1), width: 1),
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
              ),
            ),
            child: Text(
              _tr('KW $week', 'Wk $week'),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
              ),
            ),
          ),
      ],
    );

    final dayHeaderRow = Row(
      children: [
        for (var d = 1; d <= daysInMonth; d++)
          Tooltip(
            message: _tr('Klicken: Tag aus Roster ausfüllen',
                'Click: fill day from roster'),
            waitDuration: const Duration(milliseconds: 600),
            child: InkWell(
              onTap: () => _onDayHeaderTap(d),
              child: Container(
                width: _cellW,
                height: _rowH + 6,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSunday(d)
                      ? const Color(0xFFEFF3F6)
                      : const Color(0xFFF9FAFB),
                  border: isMonday(d)
                      ? const Border(
                          left: BorderSide(
                              color: Color(0xFFCBD5E1), width: 1))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (_de ? wd : wdEn)[
                          DateTime(_month.year, _month.month, d).weekday -
                              1],
                      style: const TextStyle(
                        fontSize: 8.5,
                        color: _kMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$d',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    // Ticket „not scrollable": Ziehen mit der Maus scrollt die Matrix, die
    // Scrollbars bleiben dauerhaft sichtbar — vorher war die Tages-Matrix
    // mit einer Maus nur durch Vergrößern des Fensters erreichbar.
    return ScrollConfiguration(
      behavior: _dragScrollBehavior(context),
      child: Column(
      children: [
        // ── Pinned header (always visible) ──
        Row(
          children: [
            Container(
              width: 228,
              height: headerH,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(left: 14, bottom: 9),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                border: Border(
                    right:
                        BorderSide(color: Color(0xFF94A3B8), width: 2)),
              ),
              child: Text(
                _tr('Mitarbeiter', 'Employee'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _kMuted,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _hHeader,
                scrollDirection: Axis.horizontal,
                child: Column(
                    children: [
                      kwHeaderRow,
                      freeRow,
                      missingRow,
                      dayHeaderRow,
                    ]),
              ),
            ),
            Container(
              width: 116,
              height: headerH,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 9),
              color: const Color(0xFFF9FAFB),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      _tr('Tage', 'Days'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _kMuted,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 60,
                    child: Text(
                      '€',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _kMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // ── Scrollable body ──
        Expanded(
          child: Scrollbar(
            controller: _vBody,
            thumbVisibility: true,
            child: SingleChildScrollView(
            controller: _vBody,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fixed left: employee names ──
                Container(
                  width: 228,
                  decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color(0xFF94A3B8), width: 2)),
                  ),
                  child: Column(
                    children: [
                      for (final row in planRows)
                        if (row.index < 0)
                          _groupHeader(row.rank, row.count, width: 228)
                        else
                        Builder(builder: (context) {
                          final i = row.index;
                          final contract = DriverContractType.fromValue(
                              drivers[i].data()['contractType']);
                    final abbr = _contractAbbr(contract);
                    final isMinijob =
                        contract == DriverContractType.minijob;
                    return Container(
                      height: _rowH,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 10, right: 6),
                      color: i.isOdd
                          ? const Color(0xFFF6F7F9)
                          : Colors.white,
                      child: Row(
                        children: [
                          // Laufende Nummer innerhalb der Vertragsgruppe
                          // (MJ: 1-2-3, TZ: 1-2-3, VZ: 1-2-3 …).
                          SizedBox(
                            width: 18,
                            child: Text(
                              '${groupNumbers[i]}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 30,
                            height: 17,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: abbr.isEmpty
                                  ? Colors.transparent
                                  : (isMinijob
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              abbr,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: isMinijob
                                    ? const Color(0xFF92400E)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (drivers[i].data()['driverName'] ?? '—')
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                    color: _kText,
                                  ),
                                ),
                                // Ticket: Beschäftigungszeitraum aus dem
                                // Drivers Hub direkt unter dem Namen.
                                _employmentLine(drivers[i].data()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
                // ── Scrollable middle: day cells ──
                Expanded(
                  child: SingleChildScrollView(
                    controller: _hBody,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        for (final row in planRows)
                          if (row.index < 0)
                            // Gruppen-Kopfzeile über die volle Matrixbreite.
                            Container(
                              width: matrixW,
                              height: _groupRowH,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2F6),
                                border: Border(
                                  top: BorderSide(
                                      color: Color(0xFFDDE3EA), width: 0.8),
                                  bottom: BorderSide(
                                      color: Color(0xFFDDE3EA), width: 0.8),
                                ),
                              ),
                            )
                          else
                          Row(
                            children: [
                              for (var d = 1; d <= daysInMonth; d++)
                                _dayCell(
                                  drivers[row.index],
                                  d,
                                  codeOf,
                                  isAuto,
                                  weekBlocked,
                                  monthBlocked,
                                  zebra: row.index.isOdd,
                                  sunday: isSunday(d),
                                  monday: isMonday(d),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                // ── Fixed right: Spesen totals ──
                SizedBox(
                  width: 116,
                  child: Column(
                    children: [
                      for (final row in planRows)
                        if (row.index < 0)
                          Container(
                            height: _groupRowH,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2F6),
                              border: Border(
                                top: BorderSide(
                                    color: Color(0xFFDDE3EA), width: 0.8),
                                bottom: BorderSide(
                                    color: Color(0xFFDDE3EA), width: 0.8),
                              ),
                            ),
                          )
                        else
                        Builder(builder: (context) {
                          final i = row.index;
                          final tid = (drivers[i]
                                      .data()['transporterId'] ??
                            drivers[i].id)
                        .toString()
                        .trim();
                    final isMinijob = !_contractEligible(
                        DriverContractType.fromValue(
                            drivers[i].data()['contractType']));
                    final days = isMinijob ? 0 : spesenDays(tid);
                    final eur = days * _spesenRate;
                    return Container(
                      height: _rowH,
                      color: i.isOdd
                          ? const Color(0xFFF6F7F9)
                          : Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 44,
                            child: Text(
                              isMinijob ? '—' : '$days',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _kText,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              isMinijob ? '—' : _money(eur),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isMinijob
                                    ? _kMuted
                                    : const Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
        // ── Dauerhaft sichtbare Horizontal-Scrollbar der Tages-Matrix ──
        // Sie hängt an einem eigenen (leeren) Scrollbereich derselben
        // Breite und ist mit Kopf- und Körper-Scroll gekoppelt.
        Container(
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 228),
              Expanded(
                child: Scrollbar(
                  controller: _hFoot,
                  thumbVisibility: true,
                  thickness: 8,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SingleChildScrollView(
                    controller: _hFoot,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: matrixW, height: 14),
                  ),
                ),
              ),
              const SizedBox(width: 116),
            ],
          ),
        ),
      ],
      ),
    );
  }

  Widget _dayCell(
    QueryDocumentSnapshot<Map<String, dynamic>> driver,
    int day,
    String Function(String tid, int day) codeOf,
    bool Function(String tid, int day) isAuto,
    bool Function(String tid, int week) weekBlocked,
    bool Function(String tid) monthBlocked, {
    required bool zebra,
    required bool sunday,
    required bool monday,
  }) {
    final tid =
        (driver.data()['transporterId'] ?? driver.id).toString().trim();
    final code = codeOf(tid, day);
    final auto = isAuto(tid, day);
    final blocked = weekBlocked(tid, _weekOfDay(day));
    final emptyBg = sunday
        ? const Color(0xFFEFF3F6)
        : (zebra ? const Color(0xFFF6F7F9) : Colors.white);
    // Automatisch vorbelegte Zellen werden blasser gezeichnet, damit auf
    // einen Blick erkennbar bleibt, was der Admin selbst eingetragen hat.
    final bg = code.isEmpty
        ? emptyBg
        : (auto
            ? Color.alphaBlend(
                _codeColor(code).withValues(alpha: 0.38), emptyBg)
            : _codeColor(code));
    // Blocked calendar week: code label stays, day gets an orange frame
    // and its A/AC days no longer count towards the Spesen total.
    final border = blocked
        ? Border.all(color: const Color(0xFFF97316), width: 1.5)
        : Border(
            left: BorderSide(
              color: monday
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFFEDF0F3),
              width: monday ? 1 : 0.5,
            ),
            top: const BorderSide(color: Color(0xFFEDF0F3), width: 0.5),
            right: const BorderSide(color: Color(0xFFEDF0F3), width: 0.5),
            bottom: const BorderSide(color: Color(0xFFEDF0F3), width: 0.5),
          );
    // Tooltip: Bedeutung des Codes (eigene Beschriftung aus den
    // Einstellungen, sonst Standard) samt Spesen-Hinweis.
    final tip = code.isEmpty
        ? ''
        : [
            [code, if (_codeLabel(code) != null) _codeLabel(code)!]
                .join(' — '),
            if (_kSpesenCodes.contains(code))
              blocked
                  ? _tr('${_money(_spesenRate)} gestrichen',
                      '${_money(_spesenRate)} cancelled')
                  : '+${_money(_spesenRate)}',
            if (auto) _tr('automatisch vorbelegt', 'pre-filled automatically'),
          ].join(' · ');
    return Builder(
      builder: (cellContext) {
        final cell = InkWell(
          onTap: () => _pickCode(
              cellContext, tid, day, code, blocked, monthBlocked(tid),
              isAuto: auto),
          child: Container(
            width: _cellW,
            height: _rowH,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              border: border,
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: auto ? FontWeight.w600 : FontWeight.w800,
                fontStyle: auto ? FontStyle.italic : FontStyle.normal,
                color: auto
                    ? const Color(0xFF64748B)
                    : const Color(0xFF1F2937),
              ),
            ),
          ),
        );
        if (tip.isEmpty) return cell;
        return Tooltip(
          message: tip,
          waitDuration: const Duration(milliseconds: 400),
          child: cell,
        );
      },
    );
  }
}
