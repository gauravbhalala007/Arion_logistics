// lib/Screens/driver_hub_detail_page.dart
//
// Driver-Hub-Detailseite im Kunden-Design „2a" (Design-Handoff
// `design_handoff_driver_hub`): Header-Leiste, links eine fixe 300px-
// Profilkarte, rechts ein eigener Scrollbereich mit thematisch gruppierten
// Karten. Ein Klick auf die „Gesamtscore"-Kachel baut die rechte Spalte
// animiert (350 ms) zum Wochen-Score-Verlauf um.
//
// Diese Datei enthält **ausschließlich Darstellung**. Jede Bearbeitung läuft
// über [DriverHubDetailActions] zurück in `drivers_hub_page.dart`, wo die
// bestehenden Editor-Dialoge unverändert weiterleben (keine Duplikate).

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';
import '../models/employment_period.dart';
import '../services/incident_reports.dart';
import '../services/vacation_pools_repository.dart';
import '../utils/vacation_pools.dart';
import '../widgets/vacation_pool_lines.dart';
import '../widgets/driver_performance_sections.dart';

// ---------------------------------------------------------------------------
// Design-Tokens (1:1 aus dem Handoff)
// ---------------------------------------------------------------------------

class _C {
  static const pageBg = Color(0xFFF2F4F7);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F9FB);
  static const border = Color(0xFFE5E9EE);
  static const rowLine = Color(0xFFEEF1F4);
  static const text = Color(0xFF1A212B);
  static const text2 = Color(0xFF5B6572);
  static const text3 = Color(0xFF8A93A0);
  static const muted = Color(0xFFB6BEC8);

  static const green = Color(0xFF0D8A60);
  static const green2 = Color(0xFF14A878);
  static const greenTint = Color(0xFFE7F6EF);
  static const docBg = Color(0xFFF4FBF8);
  static const docBorder = Color(0xFFDFF0E8);

  static const amberText = Color(0xFF9A6B1F);
  static const amberValue = Color(0xFFB0731C);
  static const amberBadge = Color(0xFFF8E9CD);
  static const amberDot = Color(0xFFE09B2D);

  static const redText = Color(0xFFA13C3C);
  static const redValue = Color(0xFFB32F2F);
  static const redBg = Color(0xFFFDF0F0);
  static const redBorder = Color(0xFFF0D4D4);

  static const barTrack = Color(0xFFE9EDF1);
}

const double _kNarrowBreakpoint = 700;

/// Farbsatz einer Score-Stufe (Handoff: ≥75 grün, ≥55 amber, sonst rot).
class _ScorePalette {
  const _ScorePalette({
    required this.bg,
    required this.border,
    required this.label,
    required this.value,
    required this.badgeBg,
    required this.bar,
  });

  final Color bg;
  final Color border;
  final Color label;
  final Color value;
  final Color badgeBg;
  final Color bar;

  // Amazon-Scorecard-Buckets — identisch zur Fahrerliste im Drivers Hub
  // (_driverScoreBucket*: ≥93 Fantastic Plus teal, ≥86 Fantastic blau,
  // ≥70 Great amber, ≥50 Fair orange, sonst Poor rot).
  static const fantasticPlus = _ScorePalette(
    bg: Color(0xFFE4F7F3),
    border: Color(0xFFB8E8DF),
    label: Color(0xFF0F766E),
    value: Color(0xFF0F766E),
    badgeBg: Color(0xFFC9F0E8),
    bar: Color(0xFF14B8A6),
  );
  static const fantastic = _ScorePalette(
    bg: Color(0xFFE7F5FC),
    border: Color(0xFFBEE3F5),
    label: Color(0xFF0369A1),
    value: Color(0xFF0369A1),
    badgeBg: Color(0xFFCDE9F8),
    bar: Color(0xFF0EA5E9),
  );
  static const great = _ScorePalette(
    bg: Color(0xFFFEF5E5),
    border: Color(0xFFF8E2B5),
    label: Color(0xFFB45309),
    value: Color(0xFFB45309),
    badgeBg: Color(0xFFFBEACB),
    bar: Color(0xFFF59E0B),
  );
  static const fair = _ScorePalette(
    bg: Color(0xFFFFF1E6),
    border: Color(0xFFFAD7B8),
    label: Color(0xFFC2410C),
    value: Color(0xFFC2410C),
    badgeBg: Color(0xFFFDE0C8),
    bar: Color(0xFFFB923C),
  );
  static const poor = _ScorePalette(
    bg: _C.redBg,
    border: _C.redBorder,
    label: _C.redText,
    value: _C.redValue,
    badgeBg: Color(0xFFF6DADA),
    bar: _C.redValue,
  );

  static _ScorePalette of(double score) {
    if (score >= 93) return fantasticPlus;
    if (score >= 86) return fantastic;
    if (score >= 70) return great;
    if (score >= 50) return fair;
    return poor;
  }

  static String labelOf(double score) {
    if (score >= 93) return 'Fantastic Plus';
    if (score >= 86) return 'Fantastic';
    if (score >= 70) return 'Great';
    if (score >= 50) return 'Fair';
    return 'Poor';
  }
}

// ---------------------------------------------------------------------------
// Brücke zu den bestehenden Editoren in drivers_hub_page.dart
// ---------------------------------------------------------------------------

/// Alle Schreib-/Editor-Aktionen der Detailseite. Die Implementierungen leben
/// weiterhin in `_DriversHubPageState` — hier werden nur Closures übergeben,
/// damit die Seite selbst keine Firestore-Writes und keine Dialoge kennt.
class DriverHubDetailActions {
  const DriverHubDetailActions({
    required this.editOnboardingField,
    required this.pickOnboardingDate,
    required this.editExpiryOrNone,
    required this.editDriverName,
    required this.editWorkPermitType,
    required this.editDriverLanguage,
    required this.editRemainingVacation,
    required this.editEmployeeNumber,
    required this.editLicenseType,
    required this.editTransporterId,
    required this.settingsMenuBuilder,
    required this.profileImage,
    required this.workPermitTypeLabel,
    required this.languageLabelOf,
  });

  /// `_adminEditField` — generischer Editor für `onboarding.<fieldKey>`.
  final void Function({
    required String label,
    required String fieldKey,
    required String initialValue,
    bool isDate,
    bool isNumeric,
  }) editOnboardingField;

  /// `_pickHeroDate` — Datepicker, schreibt `onboarding.<fieldKey>`.
  final void Function({
    required String fieldKey,
    String? current,
    Map<String, String> Function(DateTime picked)? extraFields,
  }) pickOnboardingDate;

  /// `_editExpiryOrNone` — Datum ODER „kein Ablaufdatum".
  final void Function({
    required String dateKey,
    required String noExpiryKey,
    String? currentDate,
    String? dialogTitle,
    String? pickDateLabel,
    String? noneLabel,
  }) editExpiryOrNone;

  /// `_adminEditDriverName` — Anzeigename (inkl. Sync in andere Sammlungen).
  final void Function(String initialValue) editDriverName;

  /// `_adminEditWorkPermitType`.
  final void Function(dynamic initialValue, dynamic fallbackExpiry)
      editWorkPermitType;

  /// `_adminEditDriverLanguage`.
  final void Function(dynamic initialValue) editDriverLanguage;

  /// `_editRemainingVacationOverride` — manueller Resturlaubs-Override.
  final void Function({
    required String label,
    required double? currentOverride,
    required double? computed,
  }) editRemainingVacation;

  /// `_editEmployeeNumber`.
  final void Function(String current) editEmployeeNumber;

  /// `_adminEditLicenseType` — EU vs. Nicht-EU-Führerschein.
  final void Function(String current) editLicenseType;

  /// `_editTransporterId`.
  final void Function(
    DocumentSnapshot<Map<String, dynamic>> driverDoc,
    String currentTid,
  ) editTransporterId;

  /// `_driverSettingsMenu` — das bestehende Zahnrad-Menü der Detailseite.
  final Widget Function(DocumentSnapshot<Map<String, dynamic>> driverDoc)
      settingsMenuBuilder;

  /// `_profileImageFromOnboarding`.
  final ImageProvider? Function(dynamic onboardingRaw) profileImage;

  /// `_workPermitTypeLabel`.
  final String Function(dynamic raw, dynamic fallbackExpiry)
      workPermitTypeLabel;

  /// `languageLabel` aus der Lokalisierung.
  final String Function(String code) languageLabelOf;
}

// ---------------------------------------------------------------------------
// Seite
// ---------------------------------------------------------------------------

class DriverHubDetailPage extends StatefulWidget {
  const DriverHubDetailPage({
    super.key,
    required this.driverRef,
    required this.dspUid,
    required this.actions,
    this.onBack,
    this.autoEditField,
  });

  /// Feld, dessen Editor beim Öffnen sofort aufgehen soll.
  ///
  /// Wird gesetzt, wenn der Admin in den Benachrichtigungen auf eine
  /// ablaufende Unterlage tippt: Dann will er das Datum ändern und nicht
  /// erst die passende Zeile suchen. Erlaubte Werte sind die
  /// `onboarding`-Feldnamen (`idDocExpiry`, `workVisaExpiry`,
  /// `zusatzblattExpiry`, `licenseExpiry`).
  final String? autoEditField;

  /// Eingebetteter Modus: statt Navigator.pop räumt der Zurück-Pfeil
  /// den Detail-State der umgebenden Seite (Shell-Menü bleibt sichtbar).
  final VoidCallback? onBack;

  final DocumentReference<Map<String, dynamic>> driverRef;

  /// Wirksamer Admin-Namespace (`users/{scope}`) — Dispatcher liefern hier
  /// die UID ihres Parent-Admins.
  final String? dspUid;

  final DriverHubDetailActions actions;

  @override
  State<DriverHubDetailPage> createState() => _DriverHubDetailPageState();
}

enum _DetailView { overview, scores }

class _DriverHubDetailPageState extends State<DriverHubDetailPage> {
  _DetailView _view = _DetailView.overview;

  String? _copiedKey;
  Timer? _copyTimer;
  bool _missingHandled = false;

  final ScrollController _rightScroll = ScrollController();
  final ScrollController _leftScroll = ScrollController();

  // Memoisierte Futures (Aggregationen, kein Live-Stream nötig).
  Future<int>? _incidentFuture;
  String _incidentKey = '';
  Future<_SickDays>? _sickFuture;
  String _sickKey = '';
  Future<DriverPerformanceData>? _perfFuture;
  String _perfKey = '';

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  String _tr(String de, String en) => _de ? de : en;

  // ── Urlaubs-Töpfe (DSP-weit, siehe utils/vacation_pools.dart) ───────
  VacationPoolsConfig _poolsConfig = VacationPoolsConfig.disabled;
  bool _poolsRequested = false;

  Future<void> _loadPoolsOnce() async {
    if (_poolsRequested) return;
    final uid = widget.dspUid;
    if (uid == null || uid.trim().isEmpty) return;
    _poolsRequested = true;
    final config = await VacationPoolsRepository.load(uid);
    if (!mounted) return;
    setState(() => _poolsConfig = config);
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadPoolsOnce());
    // Aus einer Benachrichtigung heraus geöffnet: den passenden
    // Datums-Editor sofort aufziehen. Nach dem ersten Frame, damit der
    // Dialog einen fertigen Context vorfindet.
    final field = (widget.autoEditField ?? '').trim();
    if (field.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openEditorFor(field);
      });
    }
  }

  /// Öffnet den Editor eines Ablaufdatums anhand des `onboarding`-Feldes.
  ///
  /// Felder mit der Option „kein Ablaufdatum" (Zusatzblatt, Führerschein)
  /// bekommen den kombinierten Editor, alle anderen den reinen
  /// Datumswähler — genau wie beim Klick auf die Zeile selbst.
  Future<void> _openEditorFor(String field) async {
    final snap = await widget.driverRef.get();
    if (!mounted) return;
    final onboarding = _mapOf((snap.data() ?? const {})['onboarding']);
    switch (field) {
      case 'zusatzblattExpiry':
        widget.actions.editExpiryOrNone(
          dateKey: 'zusatzblattExpiry',
          noExpiryKey: 'zusatzblattNoExpiry',
          currentDate: _str(onboarding['zusatzblattExpiry']),
        );
      case 'licenseExpiry':
        widget.actions.editExpiryOrNone(
          dateKey: 'licenseExpiry',
          noExpiryKey: 'licenseNoExpiry',
          currentDate: _str(onboarding['licenseExpiry']),
        );
      case 'workVisaExpiry':
        widget.actions.pickOnboardingDate(
          fieldKey: 'workVisaExpiry',
          current: _str(
            onboarding['workVisaExpiry'] ??
                onboarding['residencePermitExpiry'],
          ),
        );
      case 'idDocExpiry':
        // Gleicher Dialog wie beim Klick auf die Zeile: Fuer Nicht-Visa
        // mit der Option „kein Ablaufdatum".
        if (_normalizePermit(onboarding) == 'working_visa') {
          widget.actions.pickOnboardingDate(
            fieldKey: 'idDocExpiry',
            current: _str(onboarding['idDocExpiry']),
          );
        } else {
          widget.actions.editExpiryOrNone(
            dateKey: 'idDocExpiry',
            noExpiryKey: 'idDocNoExpiry',
            currentDate: _str(onboarding['idDocExpiry']),
          );
        }
    }
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    _rightScroll.dispose();
    _leftScroll.dispose();
    super.dispose();
  }

  Future<void> _copy(String key, String value) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    setState(() => _copiedKey = key);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _copiedKey = null);
    });
  }

  Future<int> _incidents(String uid, String tid) {
    final key = '$uid|$tid';
    if (key != _incidentKey || _incidentFuture == null) {
      _incidentKey = key;
      _incidentFuture =
          countVehicleIncidentsForDriver(dspUid: uid, transporterId: tid);
    }
    return _incidentFuture!;
  }

  /// Concessions/POD/CDF — einmal pro Fahrer laden, nicht bei jedem
  /// Ansichtswechsel.
  Future<DriverPerformanceData>? _performance(String uid, String tid) {
    if (uid.isEmpty || tid.isEmpty) return null;
    final key = '$uid|$tid';
    if (key != _perfKey || _perfFuture == null) {
      _perfKey = key;
      _perfFuture = loadDriverPerformanceData(
        dspUid: uid,
        transporterId: tid,
      );
    }
    return _perfFuture;
  }

  Future<_SickDays> _sickDays(String uid, String tid) {
    final key = '$uid|$tid';
    if (key != _sickKey || _sickFuture == null) {
      _sickKey = key;
      _sickFuture = _loadSickDays(uid, tid);
    }
    return _sickFuture!;
  }

  /// Genehmigte Krankmeldungen aus `users/{scope}/absence_requests` —
  /// dieselbe Zähllogik wie `_loadSickRanking` (nur `approved`, Tage
  /// inklusive beider Enden).
  static Future<_SickDays> _loadSickDays(String uid, String tid) async {
    final year = DateTime.now().year;
    if (uid.isEmpty || tid.isEmpty) return _SickDays(0, 0, year);
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('absence_requests');

    // Bestandsdaten tragen teils nur `driverId` statt `driverTransporterId`
    // — `_loadSickRanking` liest beide Felder, also fragen wir beide ab und
    // führen sie über die Doc-ID zusammen (keine Doppelzählung).
    final results = await Future.wait([
      col.where('driverTransporterId', isEqualTo: tid).get(),
      col.where('driverId', isEqualTo: tid).get(),
    ]);
    final byId = <String, Map<String, dynamic>>{};
    for (final snap in results) {
      for (final doc in snap.docs) {
        byId[doc.id] = doc.data();
      }
    }

    var total = 0;
    var inYear = 0;
    final yearStart = DateTime.utc(year, 1, 1);
    final yearEnd = DateTime.utc(year, 12, 31);

    for (final data in byId.values) {
      if ((data['type'] ?? '').toString().trim().toLowerCase() !=
          'sick_leave') {
        continue;
      }
      if ((data['status'] ?? '').toString().trim().toLowerCase() !=
          'approved') {
        continue;
      }
      final from = parseFlexibleDate(data['fromDate']);
      final to = parseFlexibleDate(data['toDate']);
      if (from == null || to == null) continue;
      final f = DateTime.utc(from.year, from.month, from.day);
      final t = DateTime.utc(to.year, to.month, to.day);
      final days = t.difference(f).inDays + 1;
      if (days <= 0) continue;
      total += days;

      final clipStart = f.isAfter(yearStart) ? f : yearStart;
      final clipEnd = t.isBefore(yearEnd) ? t : yearEnd;
      final inYearDays = clipEnd.difference(clipStart).inDays + 1;
      if (inYearDays > 0) inYear += inYearDays;
    }
    return _SickDays(total, inYear, year);
  }

  // ── Formatierung ────────────────────────────────────────────────────────

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year.toString().padLeft(4, '0')}';
  }

  static String _fmtPercent(double v) =>
      '${v.toStringAsFixed(1).replaceAll('.', ',')} %';

  static final NumberFormat _intFmt = NumberFormat.decimalPattern('de');

  static String _fmtInt(num v) => _intFmt.format(v);

  static String _fmtDays(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static String _str(dynamic raw) => (raw ?? '').toString().trim();

  // ── Build ───────────────────────────────────────────────────────────────

  /// Nach einem TID-Wechsel wird das Fahrer-Dokument verschoben und das alte
  /// gelöscht — ohne Guard bliebe eine leere Karte stehen.
  void _handleMissingDriver() {
    if (_missingHandled || !mounted) return;
    _missingHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      final onBack = widget.onBack;
      if (onBack != null) {
        onBack();
      } else {
        Navigator.of(context).maybePop();
      }
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            _tr(
              'Fahrer-Datensatz wurde verschoben — bitte neu öffnen.',
              'Driver record was moved — please reopen.',
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Dünne, helle Scrollbar wie im Handoff (8px, Thumb #D5DBE2,
      // Track transparent) — bewusst nur lokal für diese Seite.
      data: Theme.of(context).copyWith(
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll<double>(8),
          thumbColor: WidgetStatePropertyAll<Color>(Color(0xFFD5DBE2)),
          trackColor: WidgetStatePropertyAll<Color>(Colors.transparent),
          trackBorderColor: WidgetStatePropertyAll<Color>(Colors.transparent),
          radius: Radius.circular(99),
          crossAxisMargin: 2,
        ),
      ),
      child: Scaffold(
        backgroundColor: _C.pageBg,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: widget.driverRef.snapshots(),
            builder: (context, snap) {
              final doc = snap.data;
              if (doc != null && !doc.exists) {
                _handleMissingDriver();
              }
              if (doc == null || !doc.exists) {
                return Column(
                  children: [
                    _header(null),
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }
              final data = doc.data() ?? const <String, dynamic>{};
              return Column(
                children: [
                  _header(doc),
                  Expanded(child: _body(doc, data)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Header-Leiste ───────────────────────────────────────────────────────

  Widget _header(DocumentSnapshot<Map<String, dynamic>>? doc) {
    return Container(
      decoration: const BoxDecoration(
        color: _C.card,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _IconAction(
                icon: Icons.arrow_back,
                size: 23,
                color: _C.text2,
                tooltip: _tr('Zurück', 'Back'),
                onTap: () {
                  final onBack = widget.onBack;
                  if (onBack != null) {
                    onBack();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
          ),
          const Text(
            'Driver Hub',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
              color: _C.text,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: doc == null
                  ? const SizedBox(width: 40, height: 40)
                  : widget.actions.settingsMenuBuilder(doc),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rumpf ───────────────────────────────────────────────────────────────

  Widget _body(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    final onboarding = _mapOf(data['onboarding']);
    final tid = _str(data['transporterId']).toUpperCase();
    final uid = (widget.dspUid ?? '').trim();

    final scoresStream = (uid.isEmpty || tid.isEmpty)
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('scores')
            .where('transporterId', isEqualTo: tid)
            .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: scoresStream,
      builder: (context, scoreSnap) {
        final weeks = _weeksFrom(scoreSnap.data?.docs);
        return LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < _kNarrowBreakpoint;
            final profile = _profileCard(
              doc,
              data,
              onboarding,
              tid,
              weeks,
              narrow: narrow,
            );

            if (narrow) {
              // Mobil klappt der Score-Verlauf direkt unter der Kachel auf
              // (siehe `_profileCard`) — die Sektionen darunter zeigen
              // deshalb immer die Übersicht.
              return SingleChildScrollView(
                controller: _rightScroll,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    profile,
                    const SizedBox(height: 14),
                    _overviewPanel(doc, data, onboarding),
                  ],
                ),
              );
            }

            final panel = _rightPanel(doc, data, onboarding, weeks);

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    // 15 % breiter als das 300px-Handoff — Kundenwunsch.
                    width: 345,
                    child: SingleChildScrollView(
                      controller: _leftScroll,
                      child: profile,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _rightScroll,
                      padding: const EdgeInsets.only(right: 4),
                      child: panel,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Linke Profilkarte
  // ═════════════════════════════════════════════════════════════════════════

  Widget _profileCard(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
    Map<String, dynamic> onboarding,
    String tid,
    List<_WeekScore> weeks, {
    required bool narrow,
  }) {
    final name = _str(data['driverName']).isEmpty
        ? _str(onboarding['fullName'])
        : _str(data['driverName']);
    final employeeNumber = _str(data['employeeNumber']);
    final photo = widget.actions.profileImage(data['onboarding']);

    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1 — Avatar / Name / Badges
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _avatar(name, photo),
                const SizedBox(height: 10),
                _HoverUnderline(
                  tooltip: _tr('Anzeigename bearbeiten', 'Edit display name'),
                  onTap: () => widget.actions
                      .editDriverName(_str(data['driverName'])),
                  child: Text(
                    name.isEmpty ? _tr('Ohne Namen', 'No name') : name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _C.text,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                _identityLine(doc, employeeNumber, tid),
                const SizedBox(height: 10),
                _badges(data),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2 — Kennzahl-Kacheln
          _scoreTile(weeks),
          if (narrow) _mobileScoreAccordion(data, weeks),
          const SizedBox(height: 8),
          _incidentTile(tid),
          const SizedBox(height: 8),
          _sickTile(tid),
          const SizedBox(height: 8),
          _contractTile(onboarding),
          const SizedBox(height: 8),
          _probationTile(onboarding),

          // 3 — Ablaufdaten
          const SizedBox(height: 16),
          _sectionDivider(),
          const SizedBox(height: 12),
          _expiryBlock(onboarding),

          // 4 — Kontakt
          ..._contactBlock(data, onboarding),
        ],
      ),
    );
  }

  Widget _avatar(String name, ImageProvider? photo) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.green, _C.green2],
        ),
        image: photo == null
            ? null
            : DecorationImage(image: photo, fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: photo != null
          ? null
          : Text(
              _initials(name),
              style: const TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
    );
  }

  /// „Personalnr. 27 · A5A6I65TGFZ5R" — beide Teile öffnen (ohne zusätzliches
  /// Stift-Icon, damit das Design unverändert bleibt) den jeweiligen
  /// Bestands-Editor.
  Widget _identityLine(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String employeeNumber,
    String tid,
  ) {
    const style = TextStyle(fontSize: 12, color: _C.text3, height: 1.35);
    final numberText = employeeNumber.isEmpty
        ? _tr('Personalnr. —', 'Employee no. —')
        : _tr('Personalnr. $employeeNumber', 'Employee no. $employeeNumber');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: _HoverUnderline(
            tooltip: _tr('Personalnummer bearbeiten', 'Edit employee number'),
            onTap: () => widget.actions.editEmployeeNumber(employeeNumber),
            child: Text(
              numberText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ),
        const Text(' · ', style: style),
        Flexible(
          child: _HoverUnderline(
            tooltip: _tr('Transporter-ID bearbeiten', 'Edit transporter ID'),
            onTap: () => widget.actions.editTransporterId(doc, tid),
            child: Text(
              tid.isEmpty ? '—' : tid,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ),
      ],
    );
  }

  Widget _badges(Map<String, dynamic> data) {
    final onboardingRaw = data['onboarding'];
    final hasOnboarding = onboardingRaw is Map && onboardingRaw.isNotEmpty;
    final active = (data['active'] as bool?) ?? true;
    final hasLogin = (data['hasLogin'] as bool?) ?? false;
    final isDispatcher = data['isDispatcher'] == true ||
        _str(data['role']).toLowerCase() == 'dispatcher';

    final badges = <Widget>[
      if (isDispatcher)
        _badge(_tr('Dispatcher', 'Dispatcher'), _C.greenTint, _C.green),
      if (!hasOnboarding)
        _badge(_tr('Ausstehend', 'Pending'), _C.amberBadge, _C.amberText)
      else if (active)
        _badge(
          _tr('Approved', 'Approved'),
          _C.greenTint,
          _C.green,
          icon: Icons.check,
        )
      else
        _badge(_tr('Inaktiv', 'Inactive'), _C.redBg, _C.redValue),
      _badge(
        hasLogin
            ? _tr('Login erstellt', 'Login created')
            : _tr('Kein Login', 'No login'),
        const Color(0xFFEEF1F4),
        _C.text2,
      ),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: badges,
    );
  }

  Widget _badge(String text, Color bg, Color fg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Kennzahl-Kacheln ────────────────────────────────────────────────────

  Widget _scoreTile(List<_WeekScore> weeks) {
    final hasScores = weeks.isNotEmpty;
    final average = hasScores
        ? weeks.map((w) => w.score).reduce((a, b) => a + b) / weeks.length
        : 0.0;
    final palette = hasScores ? _ScorePalette.of(average) : _ScorePalette.fair;
    final open = _view == _DetailView.scores;

    return _HoverTile(
      onTap: hasScores
          ? () => setState(
                () => _view = open ? _DetailView.overview : _DetailView.scores,
              )
          : null,
      decoration: BoxDecoration(
        color: palette.bg,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        // Pfeil rechts vertikal mittig zur ganzen Kachel.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _tr('Gesamtscore', 'Overall score'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.label,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      hasScores ? _fmtPercent(average) : '—',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: palette.value,
                        height: 1.2,
                      ),
                    ),
                    if (hasScores) ...[
                      const SizedBox(width: 7),
                      _scoreBadge(average, palette),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  !hasScores
                      ? _tr('Noch keine Wochen-Scores',
                          'No weekly scores yet')
                      : open
                          ? _tr('Verlauf wird angezeigt', 'History shown')
                          : _tr('Klicken für Wochen-Verlauf',
                              'Click for weekly history'),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: palette.label,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (hasScores)
            Icon(
              open ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 26,
              color: palette.label,
            ),
        ],
      ),
    );
  }

  /// Mobiler Ausklapp: derselbe Score-Verlauf wie in Ansicht B, nur direkt
  /// unter der Gesamtscore-Kachel — auf schmalen Screens läge die rechte
  /// Spalte sonst weit unterhalb des Sichtfelds.
  Widget _mobileScoreAccordion(
    Map<String, dynamic> data,
    List<_WeekScore> weeks,
  ) {
    final open = _view == _DetailView.scores && weeks.isNotEmpty;
    final uid = (widget.dspUid ?? '').trim();
    final tid = _str(data['transporterId']).toUpperCase();

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.ease,
      alignment: Alignment.topCenter,
      child: !open
          ? const SizedBox(width: double.infinity, height: 0)
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _scoresPanel(weeks),
                  const SizedBox(height: 14),
                  DriverPerformanceSections(
                    dspUid: uid,
                    transporterId: tid,
                    future: _performance(uid, tid),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _scoreBadge(double score, _ScorePalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: palette.badgeBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _ScorePalette.labelOf(score).toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.42,
          color: palette.value,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _metricTile({
    required String label,
    required Widget value,
    Color bg = _C.surface,
    Color labelColor = _C.text2,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: labelColor,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 10),
          value,
        ],
      ),
    );
  }

  Widget _incidentTile(String tid) {
    final uid = (widget.dspUid ?? '').trim();
    return _metricTile(
      label: _tr('Unfälle', 'Accidents'),
      bg: _C.redBg,
      labelColor: _C.redText,
      value: (uid.isEmpty || tid.isEmpty)
          ? _metricValue('—', color: _C.redValue)
          : FutureBuilder<int>(
              future: _incidents(uid, tid),
              builder: (context, snap) => _metricValue(
                snap.hasData ? '${snap.data}' : '…',
                color: _C.redValue,
              ),
            ),
    );
  }

  Widget _sickTile(String tid) {
    final uid = (widget.dspUid ?? '').trim();
    return _metricTile(
      label: _tr('Krankheitstage gesamt', 'Sick days total'),
      value: (uid.isEmpty || tid.isEmpty)
          ? _metricValue('—')
          : FutureBuilder<_SickDays>(
              future: _sickDays(uid, tid),
              builder: (context, snap) {
                final s = snap.data;
                if (s == null) return _metricValue('…');
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    _metricValue('${s.total}'),
                    const SizedBox(width: 4),
                    Text(
                      '(${s.inYear} ${_tr('in', 'in')} ${s.year})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _C.text3,
                        height: 1.2,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _metricValue(String text, {Color color = _C.text}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      ),
    );
  }

  Widget _contractTile(Map<String, dynamic> onboarding) {
    final unlimited = onboarding['contractUnlimited'] == true;
    final end = parseFlexibleDate(onboarding['contractExpiry']);
    final expired = end != null && end.isBefore(_today());
    // Ohne jede Vertragsangabe bleibt die Kachel neutral — „befristet" in
    // Grün wäre eine Aussage, die die Daten nicht hergeben.
    final unknown = !unlimited && end == null;

    final text = unknown
        ? '—'
        : unlimited
            ? _tr('unbefristet', 'unlimited')
            : _tr('befristet bis ${_fmtDate(end)}',
                'fixed until ${_fmtDate(end)}');

    return _metricTile(
      label: _tr('Arbeitsvertrag', 'Employment contract'),
      value: _smallValue(
        text,
        unknown
            ? _C.muted
            : expired
                ? _C.redValue
                : _C.green,
      ),
    );
  }

  Widget _probationTile(Map<String, dynamic> onboarding) {
    final start = parseFlexibleDate(onboarding['workStartDate']);
    final end = start == null
        ? null
        : _addMonths(start, 6).subtract(const Duration(days: 1));
    final done = end != null && end.isBefore(_today());

    final text = end == null
        ? _tr('unbekannt', 'unknown')
        : done
            ? _tr('beendet', 'completed')
            : _tr('läuft bis ${_fmtDate(end)}', 'until ${_fmtDate(end)}');

    return _metricTile(
      label: _tr('Probezeit', 'Probation'),
      value: _smallValue(
        text,
        end == null
            ? _C.muted
            : done
                ? _C.green
                : _C.amberValue,
      ),
    );
  }

  Widget _smallValue(String text, Color color) {
    return Flexible(
      child: Text(
        text,
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _sectionDivider() =>
      const Divider(height: 1, thickness: 1, color: _C.rowLine);

  Widget _blockTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.55,
            color: _C.text3,
            height: 1.3,
          ),
        ),
      );

  // ── Ablaufdaten ─────────────────────────────────────────────────────────

  Widget _expiryBlock(Map<String, dynamic> onboarding) {
    final permit = _normalizePermit(onboarding);
    final isVisa = permit == 'working_visa';
    final licenseType = _normalizeLicense(onboarding);
    final isNonEu = licenseType == 'non_eu';
    final firstDay = parseFlexibleDate(onboarding['firstDayInGermany']);

    final rows = <Widget>[];

    // Ausweis-/Passablauf gilt fuer JEDEN Fahrer, nicht nur fuer
    // Visa-Inhaber. Vorher stand die Zeile im Visa-Block — EU-Fahrer
    // bekamen zwar die Warnung "ID expiring", fanden aber kein Feld,
    // um das Datum zu pflegen.
    // Ein Reisepass laeuft immer ab; ein EU-Personalausweis nicht
    // zwingend — es gibt aber sehr wohl Ausweise mit Ablaufdatum.
    // Deshalb hier der kombinierte Editor: Datum eintragen ODER
    // ausdruecklich „kein Ablaufdatum" setzen.
    rows.add(_expiryRow(
      label: isVisa ? _tr('Reisepass', 'Passport') : _tr('Ausweis', 'ID document'),
      date: parseFlexibleDate(onboarding['idDocExpiry']),
      noExpiry: onboarding['idDocNoExpiry'] == true,
      onEdit: isVisa
          ? () => widget.actions.pickOnboardingDate(
                fieldKey: 'idDocExpiry',
                current: _str(onboarding['idDocExpiry']),
              )
          : () => widget.actions.editExpiryOrNone(
                dateKey: 'idDocExpiry',
                noExpiryKey: 'idDocNoExpiry',
                currentDate: _str(onboarding['idDocExpiry']),
              ),
    ));

    if (isVisa) {
      final visaRaw =
          onboarding['workVisaExpiry'] ?? onboarding['residencePermitExpiry'];
      rows.add(_expiryRow(
        label: 'Visa',
        date: parseFlexibleDate(visaRaw),
        onEdit: () => widget.actions.pickOnboardingDate(
          fieldKey: 'workVisaExpiry',
          current: _str(visaRaw),
        ),
      ));
      rows.add(_expiryRow(
        label: 'Zusatzblatt',
        date: parseFlexibleDate(onboarding['zusatzblattExpiry']),
        noExpiry: onboarding['zusatzblattNoExpiry'] == true,
        onEdit: () => widget.actions.editExpiryOrNone(
          dateKey: 'zusatzblattExpiry',
          noExpiryKey: 'zusatzblattNoExpiry',
          currentDate: _str(onboarding['zusatzblattExpiry']),
        ),
      ));
    }

    // Führerschein-Zeilen als eigener Block mit eigener Überschrift.
    final licenseRows = <Widget>[];

    // Führerschein-Art (`onboarding.licenseType`) als eigene Zeile — der
    // Wert ist der Einstieg in den Bestands-Editor `_adminEditLicenseType`.
    licenseRows.add(_valueRow(
      label: _tr('Führerschein-Art', 'Licence type'),
      value: isNonEu ? _tr('Nicht-EU', 'Non-EU') : 'EU',
      onEdit: () => widget.actions.editLicenseType(licenseType),
      tooltip: _tr('Führerschein-Typ ändern', 'Change licence type'),
    ));

    if (isNonEu) {
      // Ausländische Führerscheine gelten in Deutschland nur 6 Monate ab
      // Einreise — das Datum wird deshalb aus `firstDayInGermany` gerechnet
      // (und beim Speichern zusätzlich in `licenseExpiry` gespiegelt, damit
      // die Ablauf-Benachrichtigungen es sehen).
      licenseRows.add(_expiryRow(
        label: _tr('Führerschein gültig bis', 'Licence valid until'),
        date: firstDay == null ? null : _addMonths(firstDay, 6),
        warnMonths: 2,
        onEdit: () => widget.actions.pickOnboardingDate(
          fieldKey: 'firstDayInGermany',
          current: _str(onboarding['firstDayInGermany']),
          extraFields: (picked) => {
            'licenseExpiry': _fmtDate(_addMonths(picked, 6)),
          },
        ),
        editTooltip: _tr(
          'Einreisedatum ändern (6 Monate Gültigkeit)',
          'Edit entry date (6 months validity)',
        ),
      ));
      licenseRows.add(_valueRow(
        label: _tr('In Deutschland seit', 'In Germany since'),
        value: firstDay == null ? '—' : _fmtDate(firstDay),
        muted: firstDay == null,
        onEdit: () => widget.actions.pickOnboardingDate(
          fieldKey: 'firstDayInGermany',
          current: _str(onboarding['firstDayInGermany']),
          extraFields: (picked) => {
            'licenseExpiry': _fmtDate(_addMonths(picked, 6)),
          },
        ),
      ));
    } else {
      licenseRows.add(_expiryRow(
        label: _tr('Führerschein gültig bis', 'Licence valid until'),
        date: parseFlexibleDate(onboarding['licenseExpiry']),
        noExpiry: onboarding['licenseNoExpiry'] == true,
        onEdit: () => widget.actions.editExpiryOrNone(
          dateKey: 'licenseExpiry',
          noExpiryKey: 'licenseNoExpiry',
          currentDate: _str(onboarding['licenseExpiry']),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rows.isNotEmpty) ...[
          _blockTitle(
            isVisa
                ? _tr(
                    'Ablaufdaten · Working Visa',
                    'Expiry dates · working visa',
                  )
                : _tr('Ablaufdaten', 'Expiry dates'),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            rows[i],
          ],
          const SizedBox(height: 14),
        ],
        // Eigene Überschrift für den Führerschein-Block.
        _blockTitle(_tr('Führerschein', 'Driving licence')),
        for (var i = 0; i < licenseRows.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          licenseRows[i],
        ],
      ],
    );
  }

  /// Zeile ohne Datum (z. B. Führerschein-Art) — gleiche Geometrie wie
  /// [_expiryRow], damit Labels und Werte im Block bündig stehen.
  Widget _valueRow({
    required String label,
    required String value,
    required VoidCallback onEdit,
    String? tooltip,
    bool muted = false,
  }) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: _C.text2, height: 1.3),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: muted ? _C.muted : _C.text,
                height: 1.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        _IconAction(
          icon: Icons.edit_outlined,
          size: 15,
          color: _C.muted,
          tooltip: tooltip ?? '${_tr('Bearbeiten', 'Edit')}: $label',
          onTap: onEdit,
        ),
      ],
    );
  }

  Widget _expiryRow({
    required String label,
    required DateTime? date,
    bool noExpiry = false,
    required VoidCallback onEdit,
    String? editTooltip,
    int warnMonths = 12,
  }) {
    final today = _today();
    Color dot = _C.green;
    Color valueColor = _C.text;
    if (!noExpiry && date != null) {
      if (date.isBefore(today)) {
        dot = _C.redValue;
        valueColor = _C.redValue;
      } else if (date.isBefore(_addMonths(today, warnMonths))) {
        dot = _C.amberDot;
        valueColor = _C.amberText;
      }
    } else if (date == null && !noExpiry) {
      dot = _C.muted;
      valueColor = _C.muted;
    }

    final valueText = noExpiry
        ? _tr('kein Ablauf', 'no expiry')
        : date == null
            ? '—'
            : _fmtDate(date);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: noExpiry ? _C.green : dot,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: _C.text2, height: 1.3),
          ),
        ),
        const SizedBox(width: 8),
        // Datum selbst ist ebenfalls Tap-Ziel — nur der 15-px-Stift
        // allein war zu leicht zu verfehlen („nicht bearbeitbar“-
        // Feedback des Kunden).
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Text(
              valueText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: noExpiry ? _C.green : valueColor,
                height: 1.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        _IconAction(
          icon: Icons.edit_outlined,
          size: 15,
          color: _C.muted,
          tooltip: editTooltip ?? '${_tr('Bearbeiten', 'Edit')}: $label',
          onTap: onEdit,
        ),
      ],
    );
  }

  // ── Kontakt ─────────────────────────────────────────────────────────────

  List<Widget> _contactBlock(
    Map<String, dynamic> data,
    Map<String, dynamic> onboarding,
  ) {
    final address = [
      _str(onboarding['address']),
      [
        _str(onboarding['postalCode']),
        _str(onboarding['city']),
      ].where((p) => p.isNotEmpty).join(' '),
    ].where((p) => p.isNotEmpty).join(', ');

    final rows = <Widget>[
      if (_str(data['email']).isNotEmpty)
        _copyRow(
          key: 'workMail',
          icon: Icons.work_outline,
          value: _str(data['email']),
          tooltip: _tr('Firmen-E-Mail', 'Company email'),
        ),
      if (_str(onboarding['privateEmail']).isNotEmpty)
        _copyRow(
          key: 'privateMail',
          icon: Icons.mail_outline,
          value: _str(onboarding['privateEmail']),
          tooltip: _tr('Private E-Mail', 'Private email'),
        ),
      if (_str(onboarding['phone']).isNotEmpty)
        _copyRow(
          key: 'phone',
          icon: Icons.call_outlined,
          value: _str(onboarding['phone']),
          tooltip: _tr('Telefon', 'Phone'),
        ),
      if (address.isNotEmpty)
        _copyRow(
          key: 'address',
          icon: Icons.home_outlined,
          value: address,
          tooltip: _tr('Adresse', 'Address'),
        ),
    ];

    if (rows.isEmpty) return const [];

    return [
      const SizedBox(height: 16),
      _sectionDivider(),
      const SizedBox(height: 12),
      _blockTitle(_tr('Kontakt', 'Contact')),
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) const SizedBox(height: 6),
        rows[i],
      ],
    ];
  }

  Widget _copyRow({
    required String key,
    required IconData icon,
    required String value,
    required String tooltip,
  }) {
    final copied = _copiedKey == key;
    return _HoverTile(
      onTap: () => _copy(key, value),
      tooltip: '$tooltip — ${_tr('kopieren', 'copy')}',
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: const Color(0xFFEEF1F4),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: _C.text3),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _C.text,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            copied ? Icons.check : Icons.content_copy,
            size: 16,
            color: copied ? _C.green : _C.muted,
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Rechte Spalte
  // ═════════════════════════════════════════════════════════════════════════

  Widget _rightPanel(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
    Map<String, dynamic> onboarding,
    List<_WeekScore> weeks,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.ease,
      switchOutCurve: Curves.ease,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      child: _view == _DetailView.scores
          ? SizedBox(
              key: const ValueKey('scores'),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _scoresPanel(weeks),
                  const SizedBox(height: 14),
                  // Concessions · POD Quality Hits · Customer Feedback Hits —
                  // dasselbe Widget wie in der Scorecard-Fahrerdetailseite.
                  DriverPerformanceSections(
                    dspUid: (widget.dspUid ?? '').trim(),
                    transporterId: _str(data['transporterId']).toUpperCase(),
                    // Ladevorgang liegt in der Seite → das Umschalten
                    // Übersicht ⇄ Verlauf lädt nicht jedes Mal neu.
                    future: _performance(
                      (widget.dspUid ?? '').trim(),
                      _str(data['transporterId']).toUpperCase(),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              key: const ValueKey('overview'),
              width: double.infinity,
              child: _overviewPanel(doc, data, onboarding),
            ),
    );
  }

  // ── Ansicht A — Übersicht ───────────────────────────────────────────────

  Widget _overviewPanel(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
    Map<String, dynamic> onboarding,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _contractCard(data, onboarding),
        const SizedBox(height: 14),
        _personalCard(data, onboarding),
        const SizedBox(height: 14),
        _paymentCard(onboarding),
        const SizedBox(height: 14),
        _documentsCard(),
        const SizedBox(height: 14),
        _emergencyCard(onboarding),
      ],
    );
  }

  Widget _card({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: _C.surface,
              border: Border(bottom: BorderSide(color: _C.rowLine)),
            ),
            padding: EdgeInsets.fromLTRB(20, trailing == null ? 12 : 10, 20,
                trailing == null ? 12 : 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: _C.green,
                      height: 1.3,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing,
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _contractCard(
    Map<String, dynamic> data,
    Map<String, dynamic> onboarding,
  ) {
    final unlimited = onboarding['contractUnlimited'] == true;
    final start = parseFlexibleDate(onboarding['workStartDate']);
    final end = parseFlexibleDate(onboarding['contractExpiry']);
    final annual = _annualVacationDays(onboarding);
    final permitLabel = widget.actions.workPermitTypeLabel(
      onboarding['workPermitType'],
      onboarding['residencePermitExpiry'],
    );

    final current = currentEmploymentPeriod(employmentPeriodsOf(data));
    final active = (data['active'] as bool?) ?? true;
    final since = current?.startDate ?? start;
    final employment = !active
        ? _tr('inaktiv', 'inactive')
        : since == null
            ? _tr('aktiv', 'active')
            : _tr('aktiv seit ${_fmtDate(since)}',
                'active since ${_fmtDate(since)}');

    return _card(
      title: _tr('Vertrag & Urlaub', 'Contract & leave'),
      child: _TwoColGrid(
        rowBuilder: _fieldRow,
        fields: [
          _FieldSpec(
            label: _tr('Vertragsbeginn', 'Contract start'),
            value: _fmtDate(start),
            onEdit: () => widget.actions.pickOnboardingDate(
              fieldKey: 'workStartDate',
              current: _str(onboarding['workStartDate']),
            ),
          ),
          _FieldSpec(
            label: _tr('Vertragsende', 'Contract end'),
            value: unlimited
                ? _tr('Unbefristet', 'Unlimited')
                : _fmtDate(end),
            valueColor: unlimited ? _C.green : null,
            onEdit: () => widget.actions.editExpiryOrNone(
              dateKey: 'contractExpiry',
              noExpiryKey: 'contractUnlimited',
              currentDate: _str(onboarding['contractExpiry']),
              dialogTitle: _tr('Vertragsende', 'Contract end'),
              pickDateLabel:
                  _tr('Vertragsende wählen', 'Pick contract end date'),
              noneLabel: _tr('Unbefristet', 'Unlimited'),
            ),
          ),
          // Ein-Topf-Modus: unverändert „Urlaub pro Jahr".
          if (!_poolsConfig.enabled)
            _FieldSpec(
              label: _tr('Urlaub pro Jahr', 'Annual leave'),
              value: '${_fmtDays(annual)} ${_tr('Tage', 'days')}',
              onEdit: () => widget.actions.editOnboardingField(
                label: _tr('Urlaub pro Jahr', 'Annual leave'),
                fieldKey: 'annualVacationDays',
                initialValue: _str(onboarding['annualVacationDays']),
                isNumeric: true,
              ),
            ),
          // Topf-Modus: je Topf eine eigene Zeile mit Resttagen und
          // Verfallsdatum; die Tageszahl ist fahrerindividuell
          // übersteuerbar (leer = DSP-Default).
          if (_poolsConfig.enabled)
            for (final pool in _poolsConfig.forDriver(onboarding).pools)
              _vacationPoolField(onboarding, pool),
          _remainingVacationField(onboarding),
          _FieldSpec(
            label: _tr('Arbeitserlaubnis', 'Work permit'),
            value: permitLabel,
            onEdit: () => widget.actions.editWorkPermitType(
              onboarding['workPermitType'],
              onboarding['residencePermitExpiry'],
            ),
          ),
          _FieldSpec(
            label: _tr('Beschäftigung', 'Employment'),
            value: employment,
            valueColor: active ? _C.green : _C.redValue,
          ),
        ],
      ),
    );
  }

  /// Live-Saldo aus `utils/vacation_pools.dart` — dieselbe Quelle wie
  /// Drivers Hub, „DA Balance" und Fahrer-App.
  Widget _vacationBalanceBuilder(
    Map<String, dynamic> onboarding, {
    required Widget Function(VacationBalance? balance, VacationBalance? plain)
        builder,
  }) {
    final config = _poolsConfig.forDriver(onboarding);
    final annual = annualVacationDaysOf(onboarding);
    final start = parseVacationDate(onboarding['workStartDate']);
    final override = vacationOverrideOf(onboarding);
    final overrideAt = vacationOverrideAtOf(onboarding);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.driverRef.collection('absence_requests').snapshots(),
      builder: (context, snap) {
        if (snap.hasError || snap.connectionState == ConnectionState.waiting) {
          return builder(null, null);
        }
        final absences = <VacationAbsence>[
          for (final doc in snap.data?.docs ??
              const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
            if (VacationAbsence.fromMap(doc.data()) case final a?) a,
        ];
        return builder(
          computeVacationBalance(
            absences: absences,
            config: config,
            annualVacationDays: annual,
            workStartDate: start,
            manualOverride: override,
            manualOverrideAt: overrideAt,
          ),
          computeVacationBalance(
            absences: absences,
            config: config,
            annualVacationDays: annual,
            workStartDate: start,
          ),
        );
      },
    );
  }

  /// Eine Topf-Zeile: „14 von 20 · verfällt 31.03.2027".
  /// Der Stift bearbeitet die fahrerindividuelle Tageszahl
  /// (`onboarding.vacationStatutoryDays` / `vacationAdditionalDays`);
  /// leer lassen = DSP-Default.
  _FieldSpec _vacationPoolField(
    Map<String, dynamic> onboarding,
    VacationPoolDef pool,
  ) {
    final fieldKey = VacationPoolsConfig.driverDaysFieldKey(pool.key);
    return _FieldSpec(
      label: vacationPoolLabel(context, pool.key),
      value: '',
      valueBuilder: (spec) => _vacationBalanceBuilder(
        onboarding,
        builder: (balance, _) {
          final slice = balance?.poolByKey(pool.key);
          final text = slice == null
              ? '…'
              : '${_fmtDays(slice.remaining)} ${_tr('von', 'of')} '
                  '${_fmtDays(slice.entitlement)}'
                  '${slice.expiresOn == null ? '' : ' · ${AppLocalizations.of(context).tf('vacation_pool_expires_on', {
                      'date': formatVacationDate(slice.expiresOn!),
                    })}'}';
          return _FieldValue(
            text: text,
            onEdit: () => widget.actions.editOnboardingField(
              label: vacationPoolLabel(context, pool.key),
              fieldKey: fieldKey,
              initialValue: _str(onboarding[fieldKey]),
              isNumeric: true,
            ),
          );
        },
      ),
    );
  }

  /// Resturlaub gesamt.
  ///
  /// Der manuelle Override ist seit dem Bugfix kein eingefrorener Wert
  /// mehr, sondern eine Momentaufnahme: später erfasster Urlaub wird
  /// davon abgezogen (Details in `utils/vacation_pools.dart`).
  _FieldSpec _remainingVacationField(Map<String, dynamic> onboarding) {
    final label = _tr('Resturlaub', 'Remaining leave');
    final override = vacationOverrideOf(onboarding);
    final overrideAt = vacationOverrideAtOf(onboarding);

    return _FieldSpec(
      label: label,
      value: '',
      valueBuilder: (spec) => _vacationBalanceBuilder(
        onboarding,
        builder: (balance, plain) {
          final text = balance == null
              ? '…'
              : '${_fmtDays(balance.totalRemaining)} ${_tr('Tage', 'days')}';
          final usedSince = balance?.usedSinceOverride ?? 0;

          return _FieldValue(
            text: text,
            edited: override != null,
            editedTooltip: override == null
                ? null
                : <String>[
                    _tr('Manuell gesetzt', 'Manually set'),
                    _tr('Startwert: ${_fmtDays(override)} Tage',
                        'Baseline: ${_fmtDays(override)} days'),
                    if (overrideAt != null) formatVacationDate(overrideAt),
                    if (usedSince > 0)
                      _tr(
                        'seither ${_fmtDays(usedSince)} Tage abgezogen',
                        '${_fmtDays(usedSince)} days deducted since',
                      ),
                    if (plain != null)
                      _tr('Ohne Anpassung: ${_fmtDays(plain.totalRemaining)}',
                          'Without override: ${_fmtDays(plain.totalRemaining)}'),
                  ].join(' · '),
            onEdit: () => widget.actions.editRemainingVacation(
              label: label,
              currentOverride: override,
              computed: plain?.totalRemaining,
            ),
          );
        },
      ),
    );
  }

  Widget _personalCard(
    Map<String, dynamic> data,
    Map<String, dynamic> onboarding,
  ) {
    final birthPlace = [
      _str(onboarding['birthCity']),
      _str(onboarding['birthState']),
    ].where((p) => p.isNotEmpty).join(', ');
    final language = _str(onboarding['language']);

    return _card(
      title: _tr('Persönliche Daten & Herkunft', 'Personal details & origin'),
      child: _TwoColGrid(
        rowBuilder: _fieldRow,
        fields: [
          _FieldSpec(
            label: _tr('Vollständiger Name', 'Full name'),
            value: _str(onboarding['fullName']).isEmpty
                ? _str(data['driverName'])
                : _str(onboarding['fullName']),
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Vollständiger Name', 'Full name'),
              fieldKey: 'fullName',
              initialValue: _str(onboarding['fullName']),
            ),
          ),
          _FieldSpec(
            label: _tr('Geburtsname', 'Name at birth'),
            value: _str(onboarding['nameAtBirth']),
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Geburtsname', 'Name at birth'),
              fieldKey: 'nameAtBirth',
              initialValue: _str(onboarding['nameAtBirth']),
            ),
          ),
          _FieldSpec(
            label: _tr('Geburtsdatum', 'Date of birth'),
            value: _fmtDate(parseFlexibleDate(onboarding['dateOfBirth'])),
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Geburtsdatum', 'Date of birth'),
              fieldKey: 'dateOfBirth',
              initialValue: _str(onboarding['dateOfBirth']),
              isDate: true,
            ),
          ),
          _FieldSpec(
            label: _tr('Geburtsort', 'Place of birth'),
            value: birthPlace,
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Geburtsort', 'City of birth'),
              fieldKey: 'birthCity',
              initialValue: _str(onboarding['birthCity']),
            ),
          ),
          _FieldSpec(
            label: _tr('Nationalität (Ausweis)', 'Nationality (ID card)'),
            value: _str(onboarding['nationalityIdCard']),
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Nationalität (Ausweis)', 'Nationality (ID card)'),
              fieldKey: 'nationalityIdCard',
              initialValue: _str(onboarding['nationalityIdCard']),
            ),
          ),
          _FieldSpec(
            label: _tr('Fahrersprache', 'Driver language'),
            value: language.isEmpty
                ? ''
                : widget.actions.languageLabelOf(language),
            onEdit: () =>
                widget.actions.editDriverLanguage(onboarding['language']),
          ),
          _inGermanySinceField(onboarding),
        ],
      ),
    );
  }

  /// „In Deutschland seit" — erstes Einreisedatum
  /// (`onboarding.firstDayInGermany`, Bestandsfeld).
  ///
  /// Bei einem **Nicht-EU-Führerschein** gilt die Fahrerlaubnis in
  /// Deutschland nur 6 Monate ab Einreise. Beim Speichern wird deshalb —
  /// exakt wie in der alten Detailansicht — zusätzlich
  /// `onboarding.licenseExpiry` auf Einreise + 6 Monate gesetzt, damit die
  /// Ablauf-Benachrichtigungen den abgeleiteten Wert sehen. Bei einem
  /// EU-Führerschein bleibt `licenseExpiry` unangetastet.
  _FieldSpec _inGermanySinceField(Map<String, dynamic> onboarding) {
    final label = _tr('In Deutschland seit', 'In Germany since');
    final firstDay = parseFlexibleDate(onboarding['firstDayInGermany']);
    final isNonEu = _normalizeLicense(onboarding) == 'non_eu';

    return _FieldSpec(
      label: label,
      value: _fmtDate(firstDay),
      onEdit: () => widget.actions.pickOnboardingDate(
        fieldKey: 'firstDayInGermany',
        current: _str(onboarding['firstDayInGermany']),
        extraFields: isNonEu
            ? (picked) => {'licenseExpiry': _fmtDate(_addMonths(picked, 6))}
            : null,
      ),
    );
  }

  Widget _paymentCard(Map<String, dynamic> onboarding) {
    final rows = <_FieldSpec>[
      _FieldSpec(
        label: 'IBAN',
        value: _str(onboarding['bankIban']),
        mono: true,
        copyKey: 'iban',
        onEdit: () => widget.actions.editOnboardingField(
          label: 'IBAN',
          fieldKey: 'bankIban',
          initialValue: _str(onboarding['bankIban']),
        ),
      ),
      _FieldSpec(
        label: _tr('Krankenversicherung', 'Health insurance'),
        value: _str(onboarding['insuranceCompany']),
        mono: true,
        copyKey: 'insurance',
        onEdit: () => widget.actions.editOnboardingField(
          label: _tr('Krankenversicherung', 'Health insurance'),
          fieldKey: 'insuranceCompany',
          initialValue: _str(onboarding['insuranceCompany']),
        ),
      ),
      _FieldSpec(
        label: _tr('Steuer-ID', 'Tax ID'),
        value: _str(onboarding['taxId']),
        mono: true,
        copyKey: 'taxId',
        onEdit: () => widget.actions.editOnboardingField(
          label: _tr('Steuer-ID', 'Tax ID'),
          fieldKey: 'taxId',
          initialValue: _str(onboarding['taxId']),
        ),
      ),
    ];

    return _card(
      title: _tr('Zahlung & Steuer', 'Payment & tax'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++)
            _fieldRow(rows[i], divider: i != rows.length - 1),
        ],
      ),
    );
  }

  Widget _emergencyCard(Map<String, dynamic> onboarding) {
    return _card(
      title: _tr('Notfall, Uniform & Notizen', 'Emergency, uniform & notes'),
      child: _TwoColGrid(
        rowBuilder: _fieldRow,
        fields: [
          _FieldSpec(
            label: _tr('Notfallkontakt', 'Emergency contact'),
            value: _str(onboarding['emergencyContactName']),
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Notfallkontakt', 'Emergency contact'),
              fieldKey: 'emergencyContactName',
              initialValue: _str(onboarding['emergencyContactName']),
            ),
          ),
          _FieldSpec(
            label: _tr('Notfall-Telefon', 'Emergency phone'),
            value: _str(onboarding['emergencyContactPhone']),
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Notfall-Telefon', 'Emergency phone'),
              fieldKey: 'emergencyContactPhone',
              initialValue: _str(onboarding['emergencyContactPhone']),
            ),
          ),
          _FieldSpec(
            label: _tr('T-Shirt-Größe', 'T-shirt size'),
            value: _str(onboarding['tShirtSize']),
            placeholder: '—',
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('T-Shirt-Größe', 'T-shirt size'),
              fieldKey: 'tShirtSize',
              initialValue: _str(onboarding['tShirtSize']),
            ),
          ),
          _FieldSpec(
            label: _tr('Schuhgröße', 'Shoe size'),
            value: _str(onboarding['shoeSize']),
            placeholder: '—',
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Schuhgröße', 'Shoe size'),
              fieldKey: 'shoeSize',
              initialValue: _str(onboarding['shoeSize']),
            ),
          ),
        ],
        fullWidth: [
          _FieldSpec(
            label: _tr('Notizen', 'Notes'),
            value: _str(onboarding['notes']),
            placeholder: _tr('— keine', '— none'),
            onEdit: () => widget.actions.editOnboardingField(
              label: _tr('Notizen', 'Notes'),
              fieldKey: 'notes',
              initialValue: _str(onboarding['notes']),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dokumente · Company Drive (Status-only) ─────────────────────────────

  Widget _documentsCard() {
    final specs = <({String type, String label})>[
      (type: 'contract', label: _tr('Arbeitsvertrag', 'Employment contract')),
      (type: 'resident_permit', label: _tr('Arbeitserlaubnis', 'Work permit')),
      (
        type: 'resident_permit_back',
        label: _tr('Aufenthaltstitel (Rückseite)', 'Residence permit (back)')
      ),
      (type: 'passport_front', label: _tr('Reisepass', 'Passport')),
      (
        type: 'driver_license_front',
        label: _tr('Führerschein', 'Driving licence')
      ),
      (type: 'tax_id', label: _tr('Steuer-ID-Dokument', 'Tax ID document')),
    ];

    return _card(
      title: _tr('Dokumente · Company Drive', 'Documents · company drive'),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.driverRef.collection('documents').snapshots(),
        builder: (context, snap) {
          final byType = <String, Map<String, dynamic>>{
            for (final d in snap.data?.docs ??
                const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
              (d.data()['docType'] ?? d.id).toString(): d.data(),
          };

          // Nachweise aus Schulungen (Zertifikate, Kenntnisnahmen).
          // Sie haben keinen festen Upload-Slot oben, sondern entstehen
          // in der DA Academy und liegen als Dokument mit `downloadUrl`
          // beim Fahrer. Ohne diesen Abschnitt wären sie hier unsichtbar.
          final certTypes =
              byType.keys
                  .where((k) => !specs.any((s) => s.type == k))
                  .where((k) => _str(byType[k]?['downloadUrl']).isNotEmpty)
                  .toList()
                ..sort();

          return LayoutBuilder(
            builder: (context, constraints) {
              final oneCol = constraints.maxWidth < 520;
              final chips = [
                for (final s in specs)
                  _docChip(
                    label: s.label,
                    docType: s.type,
                    data: byType[s.type],
                  ),
              ];
              final grid = oneCol
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < chips.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          chips[i],
                        ],
                      ],
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < chips.length; i += 2) ...[
                          if (i > 0) const SizedBox(height: 8),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: chips[i]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: i + 1 < chips.length
                                      ? chips[i + 1]
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );

              if (certTypes.isEmpty) return grid;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  grid,
                  const SizedBox(height: 14),
                  Text(
                    _tr('Nachweise & Zertifikate', 'Certificates & records'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < certTypes.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _certTile(certTypes[i], byType[certTypes[i]]),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Bezeichnung eines Schulungsnachweises. Gleiche Beschriftungen wie im
  /// klassischen Drivers Hub, damit dasselbe Dokument nicht an zwei Orten
  /// anders heißt.
  String _certLabel(String docType) {
    switch (docType) {
      case 'safety_training_certificate':
        return _tr('Sicherheitsunterweisung (Zertifikat)',
            'Safety instruction (certificate)');
      case 'privacy_training_certificate':
        return _tr('Datenschutz-Schulung (Zertifikat)',
            'Privacy training (certificate)');
      case 'privacy_notice_ack':
        return _tr('Datenschutzinformation (Kenntnisnahme)',
            'Privacy notice (acknowledgement)');
      case 'camera_privacy_ack_certificate':
        return _tr('Kamera-Datenschutz (Kenntnisnahme)',
            'Camera privacy (acknowledgement)');
      default:
        return docType;
    }
  }

  /// Zeile für einen Schulungsnachweis: Klick öffnet das PDF.
  ///
  /// Bewusst kein Drive-Toggle wie bei den Upload-Slots — diese Dokumente
  /// erzeugt die DA Academy selbst, sie werden hier nur eingesehen.
  Widget _certTile(String docType, Map<String, dynamic>? data) {
    final url = _str(data?['downloadUrl']);
    final completedAt = data?['completedAt'];
    final date = completedAt is Timestamp
        ? DateFormat('dd.MM.yyyy').format(completedAt.toDate())
        : '';

    return _HoverTile(
      onTap: url.isEmpty ? null : () => _openUrl(url),
      tooltip: _tr('Nachweis öffnen', 'Open record'),
      decoration: BoxDecoration(
        color: _C.docBg,
        border: Border.all(color: _C.docBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, size: 18, color: _C.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _certLabel(docType),
              maxLines: 2,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.text,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            date.isEmpty ? _tr('öffnen', 'open') : date,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: _C.text3,
              height: 1.25,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.open_in_new_rounded, size: 15, color: _C.text3),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tr('Dokument konnte nicht geöffnet werden.',
                'The document could not be opened.'),
          ),
        ),
      );
    }
  }

  /// Status-Chip „im Company Drive".
  ///
  /// **Semantik:** Angezeigt wird „gespeichert", sobald entweder das
  /// Drive-Flag `availableInOwnDrive` gesetzt ist **oder** tatsächlich eine
  /// Datei hochgeladen wurde (`downloadUrl`). Der Upload hat in der Anzeige
  /// Vorrang: Ein Dokument mit Datei bleibt „gespeichert", auch wenn das
  /// Flag aus ist. Der Tap schaltet ausschließlich das **Flag** um — die
  /// Datei selbst wird hier nie angefasst (Upload/Löschen bleibt in der
  /// klassischen Ansicht).
  Widget _docChip({
    required String label,
    required String docType,
    required Map<String, dynamic>? data,
  }) {
    final hasFile = _str(data?['downloadUrl']).isNotEmpty;
    final inOwnDrive = data?['availableInOwnDrive'] == true;
    final stored = inOwnDrive || hasFile;

    return _HoverTile(
      onTap: () => _toggleOwnDrive(docType, inOwnDrive),
      tooltip: inOwnDrive
          ? _tr('Markierung entfernen', 'Remove mark')
          : _tr('Als gespeichert markieren', 'Mark as stored'),
      decoration: BoxDecoration(
        color: stored ? _C.docBg : _C.surface,
        border: Border.all(color: stored ? _C.docBorder : _C.border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: stored ? _C.green : const Color(0xFFE9EDF1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: stored
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : const Text(
                    '–',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1,
                      color: _C.text3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: stored ? _C.text : _C.text3,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            stored
                ? _tr('im Company Drive', 'in company drive')
                : _tr('noch nicht gespeichert', 'not stored yet'),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              color: stored ? _C.green : _C.text3,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  /// Schreibt das Drive-Flag — identisch zu `_setOwnDriveFlag` im Drivers Hub.
  Future<void> _toggleOwnDrive(String docType, bool current) async {
    try {
      await widget.driverRef.collection('documents').doc(docType).set({
        'docType': docType,
        'availableInOwnDrive': !current,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_de ? 'Fehler: $e' : 'Error: $e')),
      );
    }
  }

  // ── Ansicht B — Score-Verlauf ───────────────────────────────────────────

  Widget _scoresPanel(List<_WeekScore> weeks) {
    final average = weeks.isEmpty
        ? 0.0
        : weeks.map((w) => w.score).reduce((a, b) => a + b) / weeks.length;
    final palette = _ScorePalette.of(average);
    final totalPackages =
        weeks.fold<int>(0, (total, w) => total + w.packages);
    _WeekScore? bestSoFar;
    for (final w in weeks) {
      if (bestSoFar == null || w.score > bestSoFar.score) bestSoFar = w;
    }
    final best = bestSoFar;

    // Wochen sind neueste-zuerst sortiert → erste = neueste, letzte = älteste.
    // Über mehrere Jahre hinweg wäre ein reines min/max der Wochennummern
    // irreführend, deshalb dann mit Jahr („10/2025 – 33/2026").
    final multiYear = weeks.map((w) => w.year).whereType<int>().toSet().length > 1;
    final rangeLabel = weeks.isEmpty
        ? ''
        : ' · ${_tr('Woche', 'Week')} '
            '${_weekToken(weeks.last, multiYear)}'
            '${multiYear ? ' – ' : '–'}'
            '${_weekToken(weeks.first, multiYear)}';

    return _card(
      title: '${_tr('Score-Verlauf', 'Score history')}$rangeLabel',
      trailing: _BackPill(
        label: _tr('Zurück zur Übersicht', 'Back to overview'),
        onTap: () => setState(() => _view = _DetailView.overview),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 460;
              final tiles = <Widget>[
                _statTile(
                  label: _tr('Ø Gesamtscore', 'Ø overall score'),
                  bg: palette.bg,
                  border: palette.border,
                  labelColor: palette.label,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          weeks.isEmpty ? '—' : _fmtPercent(average),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: palette.value,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (weeks.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _scoreBadge(average, palette),
                      ],
                    ],
                  ),
                ),
                _statTile(
                  label: _tr('Pakete gesamt', 'Total packages'),
                  child: Text(
                    _fmtInt(totalPackages),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: _C.text,
                      height: 1.2,
                    ),
                  ),
                ),
                _statTile(
                  label: _tr('Beste Woche', 'Best week'),
                  child: Text(
                    best == null
                        ? '—'
                        : '${_tr('Woche', 'Week')} '
                            '${_weekToken(best, multiYear)} · '
                            '${_fmtPercent(best.score)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: _C.green,
                      height: 1.2,
                    ),
                  ),
                ),
              ];

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      tiles[i],
                    ],
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < tiles.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: tiles[i]),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          if (weeks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: _C.surface,
                border: Border.all(color: _C.rowLine),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _tr('Noch keine Wochen-Scores vorhanden.',
                    'No weekly scores yet.'),
                style: const TextStyle(fontSize: 13, color: _C.text2),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(right: 4),
                itemCount: weeks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) => _weekRow(weeks[i], i == 0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statTile({
    required String label,
    required Widget child,
    Color bg = _C.surface,
    Color border = _C.border,
    Color labelColor = _C.text2,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: labelColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }

  /// „33" bzw. „33/2026", wenn die Daten mehrere Jahre umfassen.
  static String _weekToken(_WeekScore w, bool withYear) {
    final week = w.week?.toString() ?? '—';
    if (!withYear || w.year == null) return week;
    return '$week/${w.year}';
  }

  String _weekLabel(_WeekScore w, {required bool current}) {
    final week = w.week == null ? '—' : '${w.week}';
    if (current) {
      return '${_tr('Woche', 'Week')} $week · ${_tr('aktuell', 'current')}';
    }
    return '${_tr('Woche', 'Week')} $week${w.year == null ? '' : ' · ${w.year}'}';
  }

  Widget _weekRow(_WeekScore w, bool isCurrent) {
    final palette = _ScorePalette.of(w.score);
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border.all(color: _C.rowLine),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              _weekLabel(w, current: isCurrent),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _C.text2,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (w.score / 100).clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: _C.barTrack,
                valueColor: AlwaysStoppedAnimation<Color>(palette.bar),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            child: Text(
              _fmtPercent(w.score),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: palette.bar,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Status-Badge neben der Prozentzahl — gleiche Buckets/Farben
          // wie Score-Kachel und Fahrerliste.
          SizedBox(
            width: 92,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.badgeBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  _ScorePalette.labelOf(w.score).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: palette.value,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              '${_fmtInt(w.packages)} ${_tr('Pakete', 'packages')}',
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: _C.text3,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feldzeile ───────────────────────────────────────────────────────────

  Widget _fieldRow(_FieldSpec spec, {required bool divider}) {
    final copied = spec.copyKey != null && _copiedKey == spec.copyKey;
    final hasValue = spec.value.trim().isNotEmpty;

    return Container(
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: _C.rowLine)),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              spec.label,
              style: const TextStyle(
                fontSize: 12.5,
                color: _C.text2,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: spec.valueBuilder != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: spec.valueBuilder!(spec),
                  )
                : _FieldValue(
                    text: hasValue
                        ? spec.value
                        : (spec.placeholder ??
                            _tr('— nicht hinterlegt', '— not set')),
                    color: hasValue ? (spec.valueColor ?? _C.text) : _C.muted,
                    mono: spec.mono,
                    onEdit: spec.onEdit,
                    onCopy: spec.copyKey == null || !hasValue
                        ? null
                        : () => _copy(spec.copyKey!, spec.value),
                    copied: copied,
                  ),
          ),
        ],
      ),
    );
  }

  // ── Datenaufbereitung ───────────────────────────────────────────────────

  List<_WeekScore> _weeksFrom(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs,
  ) {
    final out = <_WeekScore>[];
    for (final doc in docs ?? const []) {
      final data = doc.data();
      final score = ((data['comp'] as Map?)?['FinalScore'] as num?)?.toDouble();
      if (score == null) continue;
      final kpis = (data['kpis'] as Map?) ?? const {};
      final rawDelivered = kpis['Delivered'] ??
          kpis['DELIVERED'] ??
          kpis['delivered'] ??
          data['Delivered'] ??
          data['delivered'];
      // 0-Delivery-Wochen herausfiltern — identisch zur Fahrerliste im
      // Drivers Hub und zum bisherigen Wochen-Summary, sonst weichen
      // Ø-Score und Wochenliste sichtbar von der Liste ab.
      double? delivered;
      if (rawDelivered is num) {
        delivered = rawDelivered.toDouble();
      } else if (rawDelivered is String) {
        delivered = double.tryParse(rawDelivered.trim().replaceAll(',', '.'));
      }
      if (delivered == null || delivered <= 0) continue;
      final packages = delivered.round();

      out.add(_WeekScore(
        year: (data['year'] as num?)?.toInt(),
        week: (data['weekNumber'] as num?)?.toInt(),
        score: score,
        packages: packages,
      ));
    }
    out.sort((a, b) {
      final ay = a.year ?? -1;
      final by = b.year ?? -1;
      if (ay != by) return by.compareTo(ay);
      final aw = a.week ?? -1;
      final bw = b.week ?? -1;
      return bw.compareTo(aw);
    });
    return out;
  }

  double _annualVacationDays(Map<String, dynamic> onboarding) {
    final raw = onboarding['annualVacationDays'];
    if (raw is num && raw > 0) return raw.toDouble();
    if (raw is String) {
      final parsed = num.tryParse(raw.trim().replaceAll(',', '.'));
      if (parsed != null && parsed > 0) return parsed.toDouble();
    }
    return 20;
  }

  // `_approvedVacationDays`/`_completedMonthsSince` leben jetzt in
  // `utils/vacation_pools.dart` (eine Formel fuer Admin + Fahrer-App).

  String _normalizePermit(Map<String, dynamic> onboarding) {
    final value = _str(onboarding['workPermitType']).toLowerCase();
    if (value.isEmpty) {
      return _str(onboarding['residencePermitExpiry']).isNotEmpty
          ? 'working_visa'
          : 'eu';
    }
    if (value == 'eu' || value == 'permit_eu_id' || value == 'eu_id') {
      return 'eu';
    }
    if (value == 'working_visa' ||
        value == 'work_visa' ||
        value == 'permit_work_visa' ||
        value == 'visa') {
      return 'working_visa';
    }
    return value;
  }

  String _normalizeLicense(Map<String, dynamic> onboarding) {
    final v = _str(onboarding['licenseType']).toLowerCase();
    if (v == 'eu') return 'eu';
    if (v == 'non_eu' || v == 'noneu' || v == 'non-eu') return 'non_eu';
    return _str(onboarding['firstDayInGermany']).isNotEmpty ? 'non_eu' : 'eu';
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _addMonths(DateTime date, int months) {
    final totalMonths = (date.month - 1) + months;
    final year = date.year + (totalMonths ~/ 12);
    final month = (totalMonths % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day <= lastDay ? date.day : lastDay;
    return DateTime(year, month, day);
  }

  static Map<String, dynamic> _mapOf(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return const <String, dynamic>{};
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Datenklassen
// ---------------------------------------------------------------------------

class _SickDays {
  const _SickDays(this.total, this.inYear, this.year);
  final int total;
  final int inYear;
  final int year;
}

class _WeekScore {
  const _WeekScore({
    required this.year,
    required this.week,
    required this.score,
    required this.packages,
  });

  final int? year;
  final int? week;
  final double score;
  final int packages;
}

class _FieldSpec {
  const _FieldSpec({
    required this.label,
    required this.value,
    this.placeholder,
    this.valueColor,
    this.onEdit,
    this.copyKey,
    this.mono = false,
    this.valueBuilder,
  });

  final String label;
  final String value;
  final String? placeholder;
  final Color? valueColor;
  final VoidCallback? onEdit;

  /// Wenn gesetzt, bekommt die Zeile ein Copy-Icon (Key für den 1,5-s-Swap).
  final String? copyKey;
  final bool mono;

  /// Für Zeilen, deren Wert selbst live geladen wird (Resturlaub).
  final Widget Function(_FieldSpec spec)? valueBuilder;
}

// ---------------------------------------------------------------------------
// Kleine Bausteine
// ---------------------------------------------------------------------------

/// Wert + optionales Copy-/Edit-Icon, rechtsbündig.
class _FieldValue extends StatelessWidget {
  const _FieldValue({
    required this.text,
    this.color = _C.text,
    this.mono = false,
    this.onEdit,
    this.onCopy,
    this.copied = false,
    this.edited = false,
    this.editedTooltip,
  });

  final String text;
  final Color color;
  final bool mono;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final bool copied;
  final bool edited;
  final String? editedTooltip;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.3,
              fontFamily: mono ? 'monospace' : null,
              fontFamilyFallback: mono ? const ['Menlo', 'Courier'] : null,
            ),
          ),
        ),
        if (edited) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: editedTooltip ?? (de ? 'bearbeitet' : 'edited'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _C.amberBadge,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                de ? 'bearbeitet' : 'edited',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.amberText,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
        if (onCopy != null) ...[
          const SizedBox(width: 4),
          _IconAction(
            icon: copied ? Icons.check : Icons.content_copy,
            size: 15,
            color: copied ? _C.green : _C.muted,
            tooltip: de ? 'Kopieren' : 'Copy',
            onTap: onCopy!,
          ),
        ],
        if (onEdit != null) ...[
          const SizedBox(width: 2),
          _IconAction(
            icon: Icons.edit_outlined,
            size: 15,
            color: _C.muted,
            tooltip: de ? 'Bearbeiten' : 'Edit',
            onTap: onEdit!,
          ),
        ],
      ],
    );
  }
}

/// Zweispaltiges Feld-Raster mit mittiger Trennlinie (40px Spalten-Gap).
class _TwoColGrid extends StatelessWidget {
  const _TwoColGrid({
    required this.fields,
    required this.rowBuilder,
    this.fullWidth = const [],
  });

  final List<_FieldSpec> fields;
  final List<_FieldSpec> fullWidth;

  /// Baut eine Feldzeile — kommt aus `_DriverHubDetailPageState._fieldRow`.
  final Widget Function(_FieldSpec spec, {required bool divider}) rowBuilder;

  @override
  Widget build(BuildContext context) {
    Widget column(List<_FieldSpec> items, {required bool forceDivider}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            rowBuilder(
              items[i],
              divider: forceDivider || i != items.length - 1,
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final single = constraints.maxWidth < 520;
        final hasFullWidth = fullWidth.isNotEmpty;

        Widget grid;
        if (single) {
          grid = column(fields, forceDivider: hasFullWidth);
        } else {
          // Zeilenweise bauen (nicht zwei unabhängige Spalten): so liegen
          // die Zeilentrenner links und rechts immer auf derselben Höhe,
          // auch wenn ein Wert umbricht.
          final pairs = <List<_FieldSpec?>>[];
          for (var i = 0; i < fields.length; i += 2) {
            pairs.add([
              fields[i],
              i + 1 < fields.length ? fields[i + 1] : null,
            ]);
          }
          grid = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < pairs.length; r++)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: rowBuilder(
                          pairs[r][0]!,
                          divider: hasFullWidth || r != pairs.length - 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 19.5,
                          right: 19.5,
                          top: r == 0 ? 8 : 0,
                          bottom: r == pairs.length - 1 ? 8 : 0,
                        ),
                        child: Container(width: 1, color: _C.border),
                      ),
                      Expanded(
                        child: pairs[r][1] == null
                            ? const SizedBox.shrink()
                            : rowBuilder(
                                pairs[r][1]!,
                                divider:
                                    hasFullWidth || r != pairs.length - 1,
                              ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }

        if (!hasFullWidth) return grid;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            grid,
            for (var i = 0; i < fullWidth.length; i++)
              rowBuilder(
                fullWidth[i],
                divider: i != fullWidth.length - 1,
              ),
          ],
        );
      },
    );
  }
}

/// Icon-Button mit 24px-Trefferfläche und exakt gesetzter Icon-Größe.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.size,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hit = size < 24 ? 24.0 : size + 17;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: hit,
            height: hit,
            child: Icon(icon, size: size, color: color),
          ),
        ),
      ),
    );
  }
}

/// Kachel mit Hover-Abdunklung (Handoff: `filter: brightness(.96)`).
class _HoverTile extends StatelessWidget {
  const _HoverTile({
    required this.child,
    required this.decoration,
    required this.padding,
    this.onTap,
    this.tooltip,
    this.hoverColor,
  });

  final Widget child;
  final BoxDecoration decoration;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    final radius = decoration.borderRadius as BorderRadius?;
    Widget content = Material(
      color: decoration.color,
      shape: RoundedRectangleBorder(
        borderRadius: radius ?? BorderRadius.zero,
        side: decoration.border?.top ?? BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: hoverColor ?? const Color(0x0A000000),
        child: Padding(padding: padding, child: child),
      ),
    );
    if (tooltip == null) return content;
    return Tooltip(
      message: tooltip!,
      waitDuration: const Duration(milliseconds: 500),
      child: content,
    );
  }
}

/// Text, der beim Hovern unterstrichen wird — dezenter Editier-Einstieg
/// ohne zusätzliches Icon (Personalnummer / Transporter-ID).
class _HoverUnderline extends StatefulWidget {
  const _HoverUnderline({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  State<_HoverUnderline> createState() => _HoverUnderlineState();
}

class _HoverUnderlineState extends State<_HoverUnderline> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              decoration: _hover ? TextDecoration.underline : null,
              decorationColor: _C.text3,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Pill-Button „← Zurück zur Übersicht" im Karten-Header.
class _BackPill extends StatelessWidget {
  const _BackPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _C.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
        side: const BorderSide(color: _C.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFEEF1F4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 16, color: _C.text2),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.text2,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
