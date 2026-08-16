// lib/widgets/driver_performance_sections.dart
//
// Fahrer-Performance-Sektionen: **Concessions**, **POD Quality Hits** und
// **Customer Feedback Hits**.
//
// Einzige Quelle für diese drei Sektionen — genutzt von
//  • `Screens/scorecard_week.dart` (Fahrer-Detail der Wochen-Scorecard) und
//  • `Screens/driver_hub_detail_page.dart` (Ansicht B „Score-Verlauf").
//
// Die Zahlenlogik ist 1:1 aus der ursprünglichen Scorecard-Detailseite
// übernommen (Rolling-4-Wochen-Fenster der Concessions, Wochen- vs.
// Gesamt-Hits über alle Score-Wochen). Gerendert wird im Karten-Stil der
// Driver-Hub-Detailseite („2a").

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Screens/concessions_week.dart' show kEurPerDnr;

// ── Design-Tokens (identisch zur 2a-Detailseite) ────────────────────────────

const Color _kCard = Color(0xFFFFFFFF);
const Color _kSurface = Color(0xFFF7F9FB);
const Color _kBorder = Color(0xFFE5E9EE);
const Color _kRowLine = Color(0xFFEEF1F4);
const Color _kText = Color(0xFF1A212B);
const Color _kText2 = Color(0xFF5B6572);
const Color _kText3 = Color(0xFF8A93A0);
const Color _kGreen = Color(0xFF0D8A60);
const Color _kRed = Color(0xFFB91C1C);
const Color _kOrange = Color(0xFFC2410C);

final NumberFormat _intFmt = NumberFormat.decimalPattern('de');

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _intFmt.format(v);
  } catch (_) {
    return '—';
  }
}

// ── Datenmodell ────────────────────────────────────────────────────────────

/// Eine Woche der Scorecard-Historie (Trend).
class DriverPerformanceTrendEntry {
  const DriverPerformanceTrendEntry(
    this.year,
    this.week,
    this.score,
    this.bucket,
  );

  final int year;
  final int week;
  final double score;
  final String bucket;
}

/// Alles, was die Fahrer-Performance-Ansicht braucht. Sprachneutral:
/// Übersetzt wird erst beim Rendern.
class DriverPerformanceData {
  const DriverPerformanceData({
    required this.trend,
    required this.currentYear,
    required this.currentWeekNo,
    required this.podHits,
    required this.podHitsWeek,
    required this.podWeeks,
    required this.cdfHits,
    required this.cdfHitsWeek,
    required this.cdfNegative,
    required this.cdfTotal,
    required this.cdfWeeks,
    required this.concessions,
    required this.concWeekDnr,
  });

  final List<DriverPerformanceTrendEntry> trend;
  final int currentYear;
  final int currentWeekNo;

  /// POD-Hits je Roh-Schlüssel (`blurryPhoto`, …) — gesamt bzw. aktuelle KW.
  final Map<String, int> podHits;
  final Map<String, int> podHitsWeek;
  final int podWeeks;

  /// Kundenfeedback-Hits je Roh-Code (`CDF_L1_…`).
  final Map<String, int> cdfHits;
  final Map<String, int> cdfHitsWeek;
  final int cdfNegative;
  final int cdfTotal;
  final int cdfWeeks;

  final Map<String, dynamic>? concessions;

  /// DNR-Zahl der aktuellen Kalenderwoche innerhalb des 4-Wochen-Fensters;
  /// `-1`, wenn die aktuelle Woche außerhalb des Fensters liegt.
  final double concWeekDnr;
}

/// Lädt Scores + Reports und aggregiert sie exakt wie die bisherige
/// Scorecard-Fahrerdetailseite.
///
/// [reportId] definiert „diese Woche". Ohne Report-Kontext (Driver Hub) wird
/// die **neueste** Kalenderwoche des Fahrers als aktuelle Woche benutzt.
Future<DriverPerformanceData> loadDriverPerformanceData({
  required String dspUid,
  required String transporterId,
  String? reportId,
}) async {
  final db = FirebaseFirestore.instance;
  final scoresSnap = await db
      .collection('users')
      .doc(dspUid)
      .collection('scores')
      .where('transporterId', isEqualTo: transporterId)
      .get();
  final reportsSnap =
      await db.collection('users').doc(dspUid).collection('reports').get();

  // reportId → (year, week)
  final weekByReport = <String, (int, int)>{};
  for (final r in reportsSnap.docs) {
    final m = r.data();
    final y = (m['year'] as num?)?.toInt() ?? 0;
    final w = (m['weekNumber'] as num?)?.toInt() ?? 0;
    if (y > 0 && w > 0) weekByReport[r.id] = (y, w);
  }
  (int, int) weekOf(Map<String, dynamic> d) =>
      weekByReport[(d['reportId'] ?? '').toString()] ?? (0, 0);

  // „Diese Woche" = Kalenderwoche des Reports, aus dem die Seite geöffnet
  // wurde. POD/CDF/Scorecard liegen in getrennten Reports, teilen sich aber
  // die Kalenderwoche — deshalb der Vergleich über (year, weekNumber).
  var currentWeek = (0, 0);
  if (reportId != null && reportId.isNotEmpty) {
    currentWeek = weekByReport[reportId] ?? (0, 0);
  } else {
    for (final doc in scoresSnap.docs) {
      final (y, w) = weekOf(doc.data());
      if (y <= 0) continue;
      if (y > currentWeek.$1 || (y == currentWeek.$1 && w > currentWeek.$2)) {
        currentWeek = (y, w);
      }
    }
  }
  bool isCurrentWeek(Map<String, dynamic> d) =>
      currentWeek.$1 > 0 && weekOf(d) == currentWeek;

  // ── Scorecard-Trend ──
  final trend = <DriverPerformanceTrendEntry>[];
  // ── POD-Hits: aktuelle Woche + Gesamtsumme je Grund ──
  final podHits = <String, double>{};
  final podHitsWeek = <String, double>{};
  var podWeeks = 0;
  // ── CDF-Hits: aktuelle Woche + Gesamtsumme je Grund ──
  var cdfNegative = 0;
  var cdfTotal = 0;
  var cdfWeeks = 0;
  final cdfHits = <String, int>{};
  final cdfHitsWeek = <String, int>{};
  // ── Concessions (neuester Report gewinnt) ──
  Map<String, dynamic>? conc;
  var concWeek = (0, 0);

  double podCount(Map<String, dynamic> pod, String key) {
    final v = pod[key] ?? pod['${key}Count'];
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  for (final doc in scoresSnap.docs) {
    final d = doc.data();

    final bucket = (d['statusBucket'] ?? '').toString().trim();
    final comp = _strMap(d['comp']);
    if (bucket.isNotEmpty && comp.isNotEmpty) {
      final (y, w) = weekOf(d);
      if (y > 0) {
        trend.add(DriverPerformanceTrendEntry(
          y,
          w,
          _numOr0(comp['FinalScore']),
          bucket,
        ));
      }
    }

    final pod = d['podQuality'];
    if (pod is Map) {
      podWeeks++;
      final podMap = Map<String, dynamic>.from(pod);
      final thisWeek = isCurrentWeek(d);
      for (final k in kDriverPodReasonKeys) {
        final n = podCount(podMap, k);
        if (n > 0) {
          podHits[k] = (podHits[k] ?? 0) + n;
          if (thisWeek) podHitsWeek[k] = (podHitsWeek[k] ?? 0) + n;
        }
      }
    }

    final cdf = d['cdf'];
    if (cdf is Map) {
      cdfWeeks++;
      final cdfMap = Map<String, dynamic>.from(cdf);
      int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
      cdfNegative += asInt(cdfMap['negativeFeedback']);
      cdfTotal += asInt(cdfMap['totalFeedback']);
      final events = cdfMap['events'];
      if (events is List) {
        final thisWeek = isCurrentWeek(d);
        for (final e in events) {
          if (e is! Map) continue;
          final l1 = (e['feedbackL1'] ?? '').toString().trim();
          if (l1.isEmpty) continue;
          cdfHits[l1] = (cdfHits[l1] ?? 0) + 1;
          if (thisWeek) cdfHitsWeek[l1] = (cdfHitsWeek[l1] ?? 0) + 1;
        }
      }
    }

    final c = d['concessions'];
    if (c is Map) {
      final (y, w) = weekOf(d);
      // Neuester Report gewinnt.
      if (conc == null ||
          y > concWeek.$1 ||
          (y == concWeek.$1 && w > concWeek.$2)) {
        conc = Map<String, dynamic>.from(c);
        concWeek = (y, w);
      }
    }
  }

  trend.sort((a, b) {
    final y = b.year.compareTo(a.year);
    if (y != 0) return y;
    return b.week.compareTo(a.week);
  });

  // Concessions-Wochenwert für die AKTUELLE Kalenderwoche. Die Fahrer-Map
  // speichert w1..w4, wobei w4 die eigene Woche des Reports ist; jeder Key
  // wird auf eine echte (Jahr, Woche) verschoben und verglichen.
  (int, int) shiftIsoWeek(int year, int week, int offset) {
    DateTime mondayOfW1(int y) {
      final jan4 = DateTime(y, 1, 4);
      return jan4.subtract(Duration(days: (jan4.weekday + 6) % 7));
    }

    final monday =
        mondayOfW1(year).add(Duration(days: (week - 1 + offset) * 7));
    final thursday = monday.add(const Duration(days: 3));
    final isoYear = thursday.year;
    final isoWeek = (monday.difference(mondayOfW1(isoYear)).inDays ~/ 7) + 1;
    return (isoYear, isoWeek);
  }

  double concWeekDnr = -1; // -1 → aktuelle Woche außerhalb des 4-Wochen-Fensters
  final concFinal = conc;
  if (concFinal != null && concWeek.$1 > 0 && currentWeek.$1 > 0) {
    final rawByWeek = concFinal['dnrCountByWeek'];
    final byWeek = rawByWeek is Map
        ? Map<String, dynamic>.from(rawByWeek)
        : const <String, dynamic>{};
    const wOffsets = <String, int>{'w4': 0, 'w3': -1, 'w2': -2, 'w1': -3};
    for (final e in wOffsets.entries) {
      if (shiftIsoWeek(concWeek.$1, concWeek.$2, e.value) == currentWeek) {
        final raw = byWeek[e.key];
        concWeekDnr = raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0;
        break;
      }
    }
  }

  return DriverPerformanceData(
    trend: trend,
    currentYear: currentWeek.$1,
    currentWeekNo: currentWeek.$2,
    podHits: {for (final e in podHits.entries) e.key: e.value.round()},
    podHitsWeek: {for (final e in podHitsWeek.entries) e.key: e.value.round()},
    podWeeks: podWeeks,
    cdfHits: cdfHits,
    cdfHitsWeek: cdfHitsWeek,
    cdfNegative: cdfNegative,
    cdfTotal: cdfTotal,
    cdfWeeks: cdfWeeks,
    concessions: conc,
    concWeekDnr: concWeekDnr,
  );
}

/// Reihenfolge/Umfang der ausgewerteten POD-Gründe.
const List<String> kDriverPodReasonKeys = <String>[
  'blurryPhoto',
  'photoTooDark',
  'noPackageDetected',
  'packageInCar',
  'packageTooClose',
];

double _numOr0(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim().replaceAll('%', '');
    return double.tryParse(s.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}

Map<String, dynamic> _strMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    try {
      return Map<String, dynamic>.from(v);
    } catch (_) {
      final out = <String, dynamic>{};
      v.forEach((k, val) => out['$k'] = val);
      return out;
    }
  }
  return <String, dynamic>{};
}

// ── Widget ─────────────────────────────────────────────────────────────────

/// Concessions + POD Quality Hits + Customer Feedback Hits als drei Karten.
///
/// Entweder selbst ladend ([DriverPerformanceSections.new]) oder mit bereits
/// geladenen Daten ([DriverPerformanceSections.fromData]) — Letzteres nutzt
/// die Scorecard-Detailseite, die dieselben Daten schon für Kopf und Trend
/// braucht (kein zweiter Fetch).
class DriverPerformanceSections extends StatefulWidget {
  const DriverPerformanceSections({
    super.key,
    required this.dspUid,
    required this.transporterId,
    this.reportId,
    this.spacing = 14,
    this.future,
  }) : data = null;

  const DriverPerformanceSections.fromData(
    DriverPerformanceData this.data, {
    super.key,
    this.spacing = 14,
  })  : dspUid = '',
        transporterId = '',
        reportId = null,
        future = null;

  final String dspUid;
  final String transporterId;

  /// Report, aus dem die Ansicht geöffnet wurde — definiert „diese Woche".
  /// `null` → neueste Woche des Fahrers.
  final String? reportId;

  /// Vertikaler Abstand zwischen den Karten.
  final double spacing;

  /// Bereits geladene Daten (Konstruktor `fromData`).
  final DriverPerformanceData? data;

  /// Optional vorgehaltener Ladevorgang — verhindert ein erneutes Laden,
  /// wenn das Widget (z. B. beim Umschalten der Ansicht) neu aufgebaut wird.
  final Future<DriverPerformanceData>? future;

  @override
  State<DriverPerformanceSections> createState() =>
      _DriverPerformanceSectionsState();
}

class _DriverPerformanceSectionsState extends State<DriverPerformanceSections> {
  Future<DriverPerformanceData>? _future;
  String _key = '';

  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String _tr(String de, String en) => _de ? de : en;

  Future<DriverPerformanceData> _ensureFuture() {
    final provided = widget.future;
    if (provided != null) return provided;
    final key = '${widget.dspUid}|${widget.transporterId}|${widget.reportId}';
    if (key != _key || _future == null) {
      _key = key;
      _future = loadDriverPerformanceData(
        dspUid: widget.dspUid,
        transporterId: widget.transporterId,
        reportId: widget.reportId,
      );
    }
    return _future!;
  }

  @override
  Widget build(BuildContext context) {
    final preloaded = widget.data;
    if (preloaded != null) return _sections(preloaded);

    if (widget.dspUid.trim().isEmpty || widget.transporterId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<DriverPerformanceData>(
      future: _ensureFuture(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _shell(
            title: _tr('Performance wird geladen…', 'Loading performance…'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          );
        }
        final data = snap.data;
        if (snap.hasError || data == null) {
          return _shell(
            title: 'Performance',
            child: Text(
              _tr('Konnte Daten nicht laden.', 'Could not load data.'),
              style: const TextStyle(fontSize: 13, color: _kText3),
            ),
          );
        }
        return _sections(data);
      },
    );
  }

  Widget _sections(DriverPerformanceData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _concessionsCard(data),
        SizedBox(height: widget.spacing),
        _hitsCard(
          title: 'POD Quality Hits',
          rows: {
            for (final e in data.podHits.entries) _podLabel(e.key): e.value,
          },
          weekRows: {
            for (final e in data.podHitsWeek.entries) _podLabel(e.key): e.value,
          },
          emptyText: _tr(
            'Keine POD-Hits — sauber unterwegs.',
            'No POD hits — clean record.',
          ),
          subtitle: data.podWeeks > 0
              ? _tr('Summe über ${data.podWeeks} Wochen',
                  'Total across ${data.podWeeks} weeks')
              : null,
        ),
        SizedBox(height: widget.spacing),
        _hitsCard(
          title: 'Customer Feedback Hits',
          rows: {
            for (final e in data.cdfHits.entries) _cdfLabel(e.key): e.value,
          },
          weekRows: {
            for (final e in data.cdfHitsWeek.entries) _cdfLabel(e.key): e.value,
          },
          emptyText: _tr(
            'Kein negatives Kundenfeedback.',
            'No negative customer feedback.',
          ),
          subtitle: data.cdfWeeks > 0
              ? _tr(
                  'Summe über ${data.cdfWeeks} Wochen · '
                      '${data.cdfNegative} negative von ${data.cdfTotal} Rückmeldungen',
                  'Total across ${data.cdfWeeks} weeks · '
                      '${data.cdfNegative} negative of ${data.cdfTotal} feedbacks')
              : null,
        ),
      ],
    );
  }

  String _podLabel(String key) {
    switch (key) {
      case 'blurryPhoto':
        return _tr('Foto unscharf', 'Blurry photo');
      case 'photoTooDark':
        return _tr('Foto zu dunkel', 'Photo too dark');
      case 'noPackageDetected':
        return _tr('Kein Paket erkannt', 'No package detected');
      case 'packageInCar':
        return _tr('Paket im Auto', 'Package in car');
      case 'packageTooClose':
        return _tr('Paket zu nah', 'Package too close');
      default:
        return key;
    }
  }

  String _cdfLabel(String raw) {
    switch (raw) {
      case 'CDF_L1_NeverReceived':
        return _tr('Nicht erhalten', 'Never received');
      case 'CDF_L1_DriverMishandled':
        return _tr('Falsch behandelt', 'Mishandled');
      case 'CDF_L1_NotDeliveredToPreferredLocation':
        return _tr('Falsche Ablage', 'Wrong location');
      case 'CDF_L1_DamagedPackage':
        return _tr('Beschädigt', 'Damaged');
      case 'CDF_L1_DeliveryWasLate':
        return _tr('Zu spät', 'Late delivery');
      case 'CDF_L1_BadDeliveryExperience':
        return _tr('Schlechte Erfahrung', 'Bad experience');
      case 'CDF_L1_DriverWasUnprofessional':
        return _tr('Unprofessionell', 'Unprofessional');
      case 'CDF_L1_Other':
        return _tr('Sonstige', 'Other');
      default:
        return raw.replaceAll('CDF_L1_', '');
    }
  }

  // ── Kartenrahmen im 2a-Stil ──────────────────────────────────────────────

  Widget _shell({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: _kSurface,
              border: Border(bottom: BorderSide(color: _kRowLine)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: _kGreen,
                    height: 1.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: _kText3,
                      height: 1.3,
                    ),
                  ),
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

  Widget _scopeLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: _kText3,
            height: 1.3,
          ),
        ),
      );

  Widget _stat(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: _kText2,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      );

  // ── Concessions ──────────────────────────────────────────────────────────

  Widget _concessionsCard(DriverPerformanceData data) {
    final conc = data.concessions;
    double n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    final totalDnr = conc == null ? 0.0 : n(conc['totalDnr']);
    final delivered = conc == null ? 0.0 : n(conc['totalDelivered']);
    final eur = totalDnr * kEurPerDnr;
    final weekDnr = data.concWeekDnr;
    final weekEur = weekDnr < 0 ? 0.0 : weekDnr * kEurPerDnr;
    String eurStr(double v) => _de
        ? '≈ ${v.toStringAsFixed(2).replaceAll('.', ',')} €'
        : '≈ ${v.toStringAsFixed(2)} €';

    return _shell(
      title: 'Concessions',
      subtitle: conc == null
          ? null
          : _tr('Rollierender 4-Wochen-Zeitraum (neuester Report)',
              'Rolling 4-week window (latest report)'),
      child: conc == null
          ? Text(
              _tr('Keine Concessions-Daten vorhanden.',
                  'No concessions data available.'),
              style: const TextStyle(fontSize: 13, color: _kText3),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Aktuelle Kalenderwoche ──
                _scopeLabel(_tr('Woche', 'Week')),
                if (weekDnr < 0)
                  Text(
                    _tr('Diese KW liegt außerhalb des Report-Fensters.',
                        'This week is outside the report window.'),
                    style: const TextStyle(fontSize: 12.5, color: _kText3),
                  )
                else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _stat(
                          _tr('Pakete verloren', 'Packages lost'),
                          _intStr(weekDnr.round()),
                          weekDnr > 0 ? _kRed : const Color(0xFF1D7F5A),
                        ),
                        const SizedBox(width: 10),
                        _stat(
                          _tr('Verlorener Wert', 'Lost value'),
                          eurStr(weekEur),
                          weekDnr > 0 ? _kOrange : const Color(0xFF1D7F5A),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                // ── Gesamt (rollierende 4 Wochen) ──
                _scopeLabel(_tr('Gesamt (4 Wochen)', 'Total (4 weeks)')),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _stat(_tr('Pakete verloren', 'Packages lost'),
                          _intStr(totalDnr.round()), _kRed),
                      const SizedBox(width: 10),
                      _stat(_tr('Verlorener Wert', 'Lost value'), eurStr(eur),
                          _kOrange),
                      const SizedBox(width: 10),
                      _stat(_tr('Zugestellt', 'Delivered'),
                          _intStr(delivered.round()), const Color(0xFF1D7F5A)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── POD / CDF Hits ───────────────────────────────────────────────────────

  Widget _hitsCard({
    required String title,
    required Map<String, int> rows,
    required Map<String, int> weekRows,
    required String emptyText,
    String? subtitle,
  }) {
    final entries = rows.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Widget countChip(int value, {required bool highlight}) => Container(
          constraints: const BoxConstraints(minWidth: 34),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          decoration: BoxDecoration(
            color: value == 0
                ? const Color(0xFFF3F4F6)
                : (highlight
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFFFF7ED)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: value == 0
                  ? const Color(0xFF9CA3AF)
                  : (highlight ? _kRed : _kOrange),
            ),
          ),
        );

    return _shell(
      title: title,
      subtitle: subtitle,
      child: entries.isEmpty
          ? Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 18, color: Color(0xFF16A34A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    emptyText,
                    style: const TextStyle(fontSize: 13, color: _kText2),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spaltenköpfe: diese Woche | alle Wochen.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 64,
                        child: Text(
                          _tr('Woche', 'Week').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: _kText3,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(
                          _tr('Gesamt', 'Total').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: _kText3,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                for (var i = 0; i < entries.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      color: i.isOdd ? _kSurface : _kCard,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entries[i].key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kText,
                              height: 1.3,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Center(
                            child: countChip(
                              weekRows[entries[i].key] ?? 0,
                              highlight: false,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 64,
                          child: Center(
                            child: countChip(entries[i].value,
                                highlight: true),
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
