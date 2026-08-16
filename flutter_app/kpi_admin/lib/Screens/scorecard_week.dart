// lib/Screens/scorecard_week.dart
//
// Score Card — Wochendetailseite. Apple-Style nach CoDriver-Styleguide:
//  • Inter durchgehend via AppTypography
//  • Hero-Karte (codriverGreen) für den Company-Score
//  • Weiße Sekundär-Tiles für Reliability + Rank
//  • Filter-Bar mit Search-Pille + Status-Pille + Upload-Button
//  • Driver-Cards mit Tier-Pill, klarer Score-Headline, KPI-Grid
//
// Datenfluss bleibt: report/{id}, users/{adminUid}/scores, driverNames.

import '../services/driver_csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import '../widgets/driver_performance_sections.dart';

final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

// ---- tiny helpers ----
String _s(dynamic v) => (v == null) ? '' : v.toString();
String _normTid(dynamic v) => DriverCsvService.normalizeTransporterId(_s(v));

String _pctStr(num? v) {
  if (v == null) return '—';
  try {
    return '${_pct.format(v)} %';
  } catch (_) {
    return '—';
  }
}

double _ceDisplayPenalty(num? ceCount) {
  final count = (ceCount ?? 0).toDouble();
  if (count <= 0) return 100.0;
  return -(50.0 * count);
}

String _ceDisplayStr(num? ceCount) => _pctStr(_ceDisplayPenalty(ceCount));

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _int.format(v);
  } catch (_) {
    return '—';
  }
}

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

class ScorecardWeekPage extends StatefulWidget {
  const ScorecardWeekPage({super.key, required this.reportRef});
  final DocumentReference<Map<String, dynamic>> reportRef;

  @override
  State<ScorecardWeekPage> createState() => _ScorecardWeekPageState();
}

class _ScorecardWeekPageState extends State<ScorecardWeekPage> {
  bool _busyUpload = false;
  bool _busyPdf = false;
  bool _companyExpanded = false;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _reportStream;

  String _query = '';
  String _bucket = 'ALL';

  bool get _de => Localizations.localeOf(context).languageCode == 'de';

  static const _bucketItems = <String>[
    'ALL',
    'FANTASTIC_PLUS',
    'FANTASTIC',
    'GREAT',
    'FAIR',
    'POOR',
  ];

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores() {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('reportId', isEqualTo: widget.reportRef.id)
        .snapshots()
        .map((s) => s.docs);
  }

  Stream<Map<String, String>> _driverNamesForWeek() {
    return widget.reportRef.collection('driverNames').snapshots().map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = _strMap(d.data());
        final id = _normTid(data['transporterId'] ?? d.id);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  Stream<Map<String, String>> _driversNameMapGlobal() {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(const <String, String>{});
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
          final m = <String, String>{};
          for (final d in snap.docs) {
            final data = d.data();
            final id = _normTid(data['transporterId'] ?? d.id);
            final name = _s(data['driverName']);
            if (id.isNotEmpty) m[id] = name;
          }
          return m;
        });
  }

  @override
  void initState() {
    super.initState();
    _reportStream = widget.reportRef.snapshots();
  }

  String _prettyBucket(String raw) {
    switch (_s(raw).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return 'Fantastic+';
      case 'FANTASTIC':
        return 'Fantastic';
      case 'GREAT':
        return 'Great';
      case 'FAIR':
        return 'Fair';
      case 'POOR':
        return 'Poor';
      default:
        return _s(raw);
    }
  }

  Color _tierColor(String apiBucket) {
    switch (_s(apiBucket).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return AppColors.tierFantasticPlus;
      case 'FANTASTIC':
        return AppColors.tierFantastic;
      case 'GREAT':
        return AppColors.tierGreat;
      case 'FAIR':
        return AppColors.tierFair;
      case 'POOR':
        return AppColors.tierPoor;
      default:
        return AppColors.labelTertiaryLight;
    }
  }

  Future<void> _uploadDriverCsv() async {
    final t = AppLocalizations.of(context);
    if (_busyUpload) return;
    setState(() => _busyUpload = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        setState(() => _busyUpload = false);
        return;
      }
      final f = picked.files.single;
      final bytes = f.bytes;
      if (bytes == null) {
        throw Exception(t.t('scorecard_overview_no_file_bytes'));
      }

      final uid = AdminScope.adminUidOf(context) ??
          FirebaseAuth.instance.currentUser?.uid ??
          '';
      final result = await DriverCsvService.importForUser(
        uid: uid,
        csvBytes: bytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t.t('scorecard_overview_csv_updated')} '
            'Parsed ${result.parsedRows}, '
            'matched ${result.mappedDrivers}, '
            'new ${result.newDrivers}, '
            'score rows updated ${result.updatedScores}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('scorecard_overview_csv_failed', {'error': '$e'})),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyUpload = false);
    }
  }

  // Compact PDF of the weekly scorecard: one row per driver, showing only the
  // result (FinalScore + status tier) — no raw KPI values.
  Future<void> _downloadScorecardPdf() async {
    if (_busyPdf) return;
    // Locale captured before the first await so the PDF labels and the
    // error SnackBar stay correct even after async gaps.
    final de = _de;
    setState(() => _busyPdf = true);
    try {
      final docs = await _scores().first;
      final weekNames = await _driverNamesForWeek().first;
      final globalNames = await _driversNameMapGlobal().first;
      final nameMap = <String, String>{...globalNames, ...weekNames};
      final rep = await widget.reportRef.get();
      final summary = _strMap(rep.data()?['summary']);
      final week = (summary['weekNumber'] as num?)?.toInt();
      final year = (summary['year'] as num?)?.toInt();
      final station = _s(summary['stationCode']);

      final rows = docs
          .where((d) {
            // Skip drivers with 0 delivered packages.
            final kpis = _strMap(d.data()['kpis']);
            final delivered = _numOr0(kpis['Delivered'] ??
                kpis['DELIVERED'] ??
                kpis['delivered']);
            return delivered > 0;
          })
          .map((d) {
        final data = d.data();
        final comp = _strMap(data['comp']);
        final kpis = _strMap(data['kpis']);
        final tid = _normTid(data['transporterId']);
        final name = _s(nameMap[tid]);
        final ceCount =
            _numOr0(kpis['CE'] ?? kpis['CE %'] ?? kpis['CE_PCT']);
        return (
          rank: (data['rank'] as num?)?.toInt(),
          name: name.isEmpty ? _s(data['transporterId']) : name,
          score: _numOr0(comp['FinalScore']),
          bucketRaw: _s(data['statusBucket']),
          tier: _prettyBucket(_s(data['statusBucket'])),
          delivered: _intStr(_numOr0(kpis['Delivered'] ??
                  kpis['DELIVERED'] ??
                  kpis['delivered'])
              .round()),
          dcr: _pctStr(_numOr0(comp['DCR_Score'])),
          dsc: _intStr(_numOr0(kpis['DNR'] ?? kpis['DNR DPMO']).round()),
          lor: _intStr(_numOr0(kpis['LoR'] ?? kpis['LoR DPMO']).round()),
          pod: _pctStr(_numOr0(comp['POD_Score'])),
          cc: _pctStr(_numOr0(comp['CC_Score'])),
          ce: _ceDisplayStr(ceCount),
          cdf: _intStr(_numOr0(kpis['CDF'] ?? kpis['CDF DPMO']).round()),
        );
      }).toList();
      final hasRank = rows.any((r) => r.rank != null);
      // Best → worst: by rank when present, else by descending final score.
      rows.sort((a, b) => hasRank
          ? (a.rank ?? 999999).compareTo(b.rank ?? 999999)
          : b.score.compareTo(a.score));

      String scoreStr(double s) =>
          s == s.roundToDouble() ? s.toInt().toString() : s.toStringAsFixed(1);

      // Status colour — applied ONLY to the Status cell.
      PdfColor tierColor(String bucketRaw) {
        switch (bucketRaw.trim().toUpperCase()) {
          case 'FANTASTIC_PLUS':
            return PdfColor.fromInt(0xFF0E7C5A);
          case 'FANTASTIC':
            return PdfColor.fromInt(0xFF16A34A);
          case 'GREAT':
            return PdfColor.fromInt(0xFF65A30D);
          case 'FAIR':
            return PdfColor.fromInt(0xFFD97706);
          case 'POOR':
            return PdfColor.fromInt(0xFFDC2626);
          default:
            return PdfColor.fromInt(0xFF6B7280);
        }
      }

      final brandDeep = PdfColor.fromInt(0xFF006047);
      final zebra = PdfColor.fromInt(0xFFF3F4F6);

      pw.Widget dataCell(String txt,
          {bool left = false, bool bold = false, PdfColor? bg, PdfColor? fg}) {
        return pw.Container(
          color: bg,
          alignment: left ? pw.Alignment.centerLeft : pw.Alignment.center,
          padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: pw.Text(
            txt,
            textAlign: left ? pw.TextAlign.left : pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: fg ?? PdfColors.grey900,
            ),
          ),
        );
      }

      pw.Widget headCell(String txt, {bool left = false}) => pw.Container(
            alignment: left ? pw.Alignment.centerLeft : pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            child: pw.Text(
              txt,
              textAlign: left ? pw.TextAlign.left : pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          );

      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (ctx) => [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 5,
                  height: 20,
                  margin: const pw.EdgeInsets.only(right: 8),
                  color: PdfColor.fromInt(0xFF00B287),
                ),
                pw.Text('Scorecard',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: brandDeep)),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              [
                if (week != null) de ? 'KW $week' : 'Week $week',
                if (year != null) '$year',
                if (station.isNotEmpty) station,
                de ? 'beste bis schlechteste' : 'best to worst',
              ].join('  ·  '),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(20),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1.6),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(1),
                6: const pw.FlexColumnWidth(1.2),
                7: const pw.FlexColumnWidth(1.2),
                8: const pw.FlexColumnWidth(1),
                9: const pw.FlexColumnWidth(1),
                10: const pw.FlexColumnWidth(1),
                11: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: brandDeep),
                  children: [
                    headCell('#'),
                    headCell(de ? 'Fahrer' : 'Driver', left: true),
                    headCell('Status'),
                    headCell('Score'),
                    headCell('Delivered'),
                    headCell('DCR'),
                    headCell('DSC\nDPMO'),
                    headCell('LoR\nDPMO'),
                    headCell('POD'),
                    headCell('CC'),
                    headCell('CE'),
                    headCell('CDF\nDPMO'),
                  ],
                ),
                for (var i = 0; i < rows.length; i++)
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isEven ? PdfColors.white : zebra,
                    ),
                    children: [
                      dataCell(rows[i].rank?.toString() ?? '${i + 1}'),
                      dataCell(rows[i].name.isEmpty ? '—' : rows[i].name,
                          left: true),
                      dataCell(
                        rows[i].tier.isEmpty ? '—' : rows[i].tier,
                        bold: true,
                        bg: tierColor(rows[i].bucketRaw),
                        fg: PdfColors.white,
                      ),
                      dataCell(scoreStr(rows[i].score), bold: true),
                      dataCell(rows[i].delivered),
                      dataCell(rows[i].dcr),
                      dataCell(rows[i].dsc),
                      dataCell(rows[i].lor),
                      dataCell(rows[i].pod),
                      dataCell(rows[i].cc),
                      dataCell(rows[i].ce),
                      dataCell(rows[i].cdf),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
      await Printing.layoutPdf(
        name: 'Scorecard_KW${week ?? ''}.pdf',
        onLayout: (format) async => doc.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              de ? 'PDF fehlgeschlagen: $e' : 'PDF failed: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busyPdf = false);
    }
  }

  Future<void> _openReassignDialog({required String unmatchedTid}) async {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || unmatchedTid.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ReassignDriverDialog(
        dspUid: uid,
        unmatchedTid: unmatchedTid,
        reportRef: widget.reportRef,
      ),
    );
  }

  String _isoWeekRange(int year, int week) {
    final jan4 = DateTime(year, 1, 4);
    final jan4IsoWeekday = (jan4.weekday + 6) % 7;
    final mondayW1 = jan4.subtract(Duration(days: jan4IsoWeekday));
    final monday = mondayW1.add(Duration(days: (week - 1) * 7));
    final sunday = monday.add(const Duration(days: 6));
    final df = DateFormat('dd.MM.yyyy');
    return '${df.format(monday)} – ${df.format(sunday)}';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 800;
    final padH = isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _reportStream,
          builder: (context, snap) {
            final summary = _strMap(snap.data?.data()?['summary']);
            final week = (summary['weekNumber'] as num?)?.toInt();
            final year = (summary['year'] as num?)?.toInt();
            final de =
                Localizations.localeOf(context).languageCode == 'de';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scorecard',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (week != null)
                  Text(
                    '${de ? 'KW' : 'Week'} $week'
                    '${year != null ? ' · $year' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: EdgeInsets.fromLTRB(padH, isMobile ? 8 : 16, padH, 80),
              children: [
                // One stream for hero + company details so the score can't
                // flicker in and out from two competing subscriptions.
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _reportStream,
                  builder: (context, snap) {
                    final data =
                        snap.data?.data() ?? const <String, dynamic>{};
                    final summary = _strMap(data['summary']);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _heroStrip(summary, data, isMobile),
                        const SizedBox(height: 16),
                        _companyDetails(summary, isMobile),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
                _buildFilterBar(isMobile),
                const SizedBox(height: 18),
                _buildDriversList(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Company scorecard details — ALL company KPI values for the week,
  //  grouped exactly like the driver dashboard (Compliance & Safety /
  //  Delivery Quality & SWC), value + coloured status per metric.
  // ════════════════════════════════════════════════════════════════════════

  Widget _companyDetails(Map<String, dynamic> summary, bool isMobile) {
    final cas = _strMap(summary['complianceAndSafety']);
    final dqs = _strMap(summary['deliveryQualitySwc']);
    if (cas.isEmpty && dqs.isEmpty) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);

    // Flatten to individual section groups (Safety, Quality, …) so they can
    // masonry across the full width instead of leaving the left card short.
    final groups = <_CoGroupData>[];
    void collect(Map<String, dynamic> cat, Set<String> hidden) {
      final keys = _coOrderedSections(cat.keys
          .where((k) => k != 'overallStatus' && !hidden.contains(k)));
      for (final k in keys) {
        final metrics = _strMap(cat[k]);
        if (_coOrderedMetrics(k, metrics.keys).isEmpty) continue;
        groups.add(_CoGroupData(
          k,
          metrics,
          _coOrderedMetrics(k, metrics.keys).length,
        ));
      }
    }

    collect(cas, const {'compliance'});
    collect(dqs, const {});
    if (groups.isEmpty) return const SizedBox.shrink();

    Widget groupCard(_CoGroupData g) =>
        _CoSummaryGroup(sectionKey: g.sectionKey, metrics: g.metrics);

    Widget layout;
    if (isMobile) {
      layout = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < groups.length; i++) ...[
            groupCard(groups[i]),
            if (i != groups.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    } else {
      // Balanced two-column masonry: each group joins the shorter column.
      final colA = <Widget>[];
      final colB = <Widget>[];
      var wA = 0;
      var wB = 0;
      for (final g in groups) {
        if (wA <= wB) {
          colA.add(groupCard(g));
          wA += g.weight;
        } else {
          colB.add(groupCard(g));
          wB += g.weight;
        }
      }
      Widget column(List<Widget> items) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
      layout = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: column(colA)),
          const SizedBox(width: 12),
          Expanded(child: column(colB)),
        ],
      );
    }

    // Everything lives in ONE collapsible box.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () =>
                setState(() => _companyExpanded = !_companyExpanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title on its own line, pills side by side below.
                        Text(
                          t.t('dash_company_data_section').toUpperCase(),
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.labelSecondaryLight,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            if (cas.isNotEmpty)
                              Flexible(
                                child: _CoCategoryChip(
                                  label: t.t('dash_compliance_safety'),
                                  status: _s(cas['overallStatus']),
                                ),
                              ),
                            if (cas.isNotEmpty && dqs.isNotEmpty)
                              const SizedBox(width: 6),
                            if (dqs.isNotEmpty)
                              Flexible(
                                child: _CoCategoryChip(
                                  label: t.t('dash_delivery_quality_swc'),
                                  status: _s(dqs['overallStatus']),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _companyExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.labelSecondaryLight,
                  ),
                ],
              ),
            ),
          ),
          if (_companyExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E5EA)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: layout,
            ),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Hero KPI strip (Company Score · Reliability · Rank)
  // ════════════════════════════════════════════════════════════════════════

  Widget _heroStrip(
      Map<String, dynamic> summary, Map<String, dynamic> data, bool isMobile) {
    final t = AppLocalizations.of(context);
    final overall = (summary['overallScore'] as num?)?.toDouble();
    final rawStatus = _s(summary['overallStatus']);
    final overallStatus = rawStatus.isNotEmpty ? rawStatus : _bucketFromScore(overall);
    final relNext = (summary['reliabilityNextDay'] as num?)?.toDouble();
    final relGeneric = (summary['reliabilityScore'] as num?)?.toDouble();
    final reliability = relNext ?? relGeneric;
    final rank = (summary['rankAtStation'] as num?)?.toInt();
    final stationCount = (summary['stationCount'] as num?)?.toInt();
    final station =
        _s(summary['stationCode'] ?? data['stationCode']).toUpperCase();
    final rankText = rank == null
        ? '—'
        : (stationCount != null && stationCount > 0
            ? '#$rank / $stationCount'
            : '#$rank');

    final heroCard = _HeroCompanyCard(
      score: overall,
      statusLabel: overallStatus.isEmpty ? '' : _coPretty(overallStatus),
      statusColor: _coBucketColor(overallStatus),
    );
    final relTile = _StatTile(
      label: t.t('scorecard_overview_reliability_score'),
      value: reliability == null ? '—' : '${_pct.format(reliability)} %',
      sub: '',
    );
    final rankTile = _StatTile(
      label: t.t('dash_rank_in_station'),
      value: rankText,
      sub: station,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 84, child: heroCard),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: relTile),
                const SizedBox(width: 10),
                Expanded(child: rankTile),
              ],
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: heroCard),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: relTile),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: rankTile),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Filter Bar
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildFilterBar(bool isMobile) {
    final t = AppLocalizations.of(context);

    final search = SizedBox(
      height: 44,
      child: TextField(
        style: AppTypography.subheadline.copyWith(
          color: AppColors.codriverGraphite,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceElevatedLight,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.labelSecondaryLight,
            size: 20,
          ),
          hintText: t.t('dash_search_name_or_id'),
          hintStyle: AppTypography.subheadline.copyWith(
            color: AppColors.labelTertiaryLight,
            fontWeight: FontWeight.w500,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.codriverGreen, width: 1.4),
          ),
        ),
        onChanged: (s) => setState(() => _query = s.trim()),
      ),
    );

    final bucketDropdown = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.surfaceElevatedLight,
          borderRadius: BorderRadius.circular(12),
          value: _bucketItems.contains(_bucket) ? _bucket : 'ALL',
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.codriverDeep),
          style: AppTypography.subheadline.copyWith(
            color: AppColors.codriverDeep,
            fontWeight: FontWeight.w700,
          ),
          items: [
            DropdownMenuItem(
                value: 'ALL', child: Text(t.t('dash_all_status'))),
            for (final v in _bucketItems.skip(1))
              DropdownMenuItem(value: v, child: Text(_prettyBucket(v))),
          ],
          onChanged: (v) => setState(() => _bucket = v ?? 'ALL'),
        ),
      ),
    );

    final uploadBtn = CoButton(
      onPressed: _busyUpload ? null : _uploadDriverCsv,
      icon: Icons.upload_rounded,
      label: _busyUpload
          ? t.t('uploading')
          : t.t('dash_upload_driver_csv'),
      busy: _busyUpload,
    );

    final pdfBtn = CoButton(
      onPressed: _busyPdf ? null : _downloadScorecardPdf,
      icon: Icons.picture_as_pdf_outlined,
      label: 'PDF',
      variant: CoButtonVariant.quiet,
      busy: _busyPdf,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: bucketDropdown),
              const SizedBox(width: 8),
              pdfBtn,
              const SizedBox(width: 8),
              uploadBtn,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: search),
        const SizedBox(width: 10),
        bucketDropdown,
        const SizedBox(width: 10),
        pdfBtn,
        const SizedBox(width: 10),
        uploadBtn,
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Drivers list
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildDriversList(bool isMobile) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<Map<String, String>>(
      stream: _driverNamesForWeek(),
      builder: (context, weekNamesSnap) {
        final weekNames = weekNamesSnap.data ?? const <String, String>{};
        return StreamBuilder<Map<String, String>>(
          stream: _driversNameMapGlobal(),
          builder: (context, globalNamesSnap) {
            final globalNames =
                globalNamesSnap.data ?? const <String, String>{};
            final nameMap = <String, String>{}
              ..addAll(globalNames)
              ..addAll(weekNames);

            return StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _scores(),
              builder: (context, scoreSnap) {
                if (scoreSnap.connectionState == ConnectionState.waiting) {
                  return const CoStateSwitcher(
                    child: Padding(
                      key: ValueKey('drivers-loading'),
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.codriverGreen,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                var docs = scoreSnap.data ?? [];
                if (docs.isEmpty) {
                  return CoStateSwitcher(
                    child: _EmptyState(
                      key: const ValueKey('drivers-empty-period'),
                      label: t.t('dash_no_scores_period'),
                    ),
                  );
                }

                // Fahrer ohne Auslieferungen aus der Wertung entfernen.
                // Diese hatten in der Woche keine Pakete und duerfen
                // nicht in Statistiken / Ranking erscheinen.
                docs = docs.where((d) {
                  final data = d.data();
                  final kpis = (data['kpis'] as Map?) ?? const {};
                  final delivered = _numOr0(
                    kpis['Delivered'] ??
                        kpis['DELIVERED'] ??
                        kpis['delivered'] ??
                        data['Delivered'] ??
                        data['delivered'],
                  );
                  return delivered > 0;
                }).toList();

                if (_bucket != 'ALL') {
                  docs = docs.where((d) {
                    final b = _s(d.data()['statusBucket']).toUpperCase();
                    return b == _bucket;
                  }).toList();
                }

                final q = _query.toLowerCase();
                if (q.isNotEmpty) {
                  docs = docs.where((d) {
                    final normalizedId =
                        _normTid(d.data()['transporterId']);
                    final id = normalizedId.toLowerCase();
                    final name =
                        _s(nameMap[normalizedId]).toLowerCase();
                    return id.contains(q) || name.contains(q);
                  }).toList();
                }

                final hasAnyRank =
                    docs.any((d) => (d.data()['rank'] != null));
                docs.sort((a, b) {
                  if (hasAnyRank) {
                    final ra =
                        (a.data()['rank'] as num?)?.toInt() ?? 999999;
                    final rb =
                        (b.data()['rank'] as num?)?.toInt() ?? 999999;
                    return ra.compareTo(rb);
                  }
                  final ca = _strMap(a.data()['comp']);
                  final cb = _strMap(b.data()['comp']);
                  final fa = _numOr0(ca['FinalScore']);
                  final fb = _numOr0(cb['FinalScore']);
                  return fb.compareTo(fa);
                });

                if (docs.isEmpty) {
                  return CoStateSwitcher(
                    child: _EmptyState(
                      key: const ValueKey('drivers-empty-filter'),
                      label: t.t('dash_no_drivers_match'),
                    ),
                  );
                }

                return CoStateSwitcher(
                  child: Column(
                  key: const ValueKey('drivers-loaded'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            t.t('drivers_hub_title').toUpperCase(),
                            style: AppTypography.caption2.copyWith(
                              color: AppColors.labelSecondaryLight,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.codriverGreen
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${docs.length}',
                              style: AppTypography.caption2.copyWith(
                                color: AppColors.codriverDeep,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var i = 0; i < docs.length; i++) ...[
                      _DriverCard(
                        data: docs[i].data(),
                        nameMap: nameMap,
                        isMobile: isMobile,
                        prettyBucket: _prettyBucket,
                        tierColor: _tierColor,
                        onAssignTid: () => _openReassignDialog(
                          unmatchedTid: _s(
                            docs[i].data()['transporterId'],
                          ).trim(),
                        ),
                        onTap: () {
                          final uid = AdminScope.adminUidOf(context) ??
                              FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;
                          final d = docs[i].data();
                          final tid = _s(d['transporterId']).trim();
                          final name =
                              _s(nameMap[_normTid(tid)]).trim().isEmpty
                                  ? tid
                                  : _s(nameMap[_normTid(tid)]).trim();
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => _DriverScoreDetailPage(
                                uid: uid,
                                transporterId: tid,
                                driverName: name,
                                currentScore:
                                    _numOr0(_strMap(d['comp'])['FinalScore']),
                                currentBucket: _s(d['statusBucket']),
                                reportId: widget.reportRef.id,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  Hero Company Score Card (grüner Marken-Hero)
// ════════════════════════════════════════════════════════════════════════

class _HeroCompanyCard extends StatelessWidget {
  final double? score;
  final String statusLabel;
  final Color statusColor;
  const _HeroCompanyCard({
    required this.score,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.codriverGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppElevation.level1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('admin_home_company_score').toUpperCase(),
                  style: AppTypography.caption2.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                if (statusLabel.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: AppTypography.caption2.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: score != null ? _pct.format(score) : '—',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 30,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                TextSpan(
                  text: ' %',
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.75),
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

// ════════════════════════════════════════════════════════════════════════
//  Stat Tile (white)
// ════════════════════════════════════════════════════════════════════════

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _StatTile({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.title3.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              sub,
              style: AppTypography.caption2.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  Driver Card
// ════════════════════════════════════════════════════════════════════════

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, String> nameMap;
  final bool isMobile;
  final String Function(String raw) prettyBucket;
  final Color Function(String raw) tierColor;
  final VoidCallback? onAssignTid;

  /// Opens the driver detail view (trend, concessions, POD, CDF).
  final VoidCallback? onTap;

  const _DriverCard({
    required this.data,
    required this.nameMap,
    required this.isMobile,
    required this.prettyBucket,
    required this.tierColor,
    this.onAssignTid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final compRaw = data['comp'];
    final kpisRaw = data['kpis'];
    final comp = compRaw is Map
        ? Map<String, dynamic>.from(compRaw as Map)
        : <String, dynamic>{};
    final kpis = kpisRaw is Map
        ? Map<String, dynamic>.from(kpisRaw as Map)
        : <String, dynamic>{};

    final de = Localizations.localeOf(context).languageCode == 'de';

    final transporterId = _s(data['transporterId']).trim();
    final normalizedTid = _normTid(transporterId);
    final mappedName = _s(nameMap[normalizedTid]);
    final isUnmatched = mappedName.isEmpty;
    final name = isUnmatched ? t.t('dash_no_name') : mappedName;

    final score = _numOr0(comp['FinalScore']);
    final dcr = _numOr0(comp['DCR_Score']);
    final pod = _numOr0(comp['POD_Score']);
    final cc = _numOr0(comp['CC_Score']);
    final ceCount =
        _numOr0(kpis['CE'] ?? kpis['CE %'] ?? kpis['CE_PCT']);
    final delivered = _numOr0(
        kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered']);
    final dnr = _numOr0(kpis['DNR'] ?? kpis['DNR DPMO']);
    final lor = _numOr0(kpis['LoR'] ?? kpis['LoR DPMO']);
    final cdf = _numOr0(kpis['CDF'] ?? kpis['CDF DPMO']);

    final rank = (data['rank'] as num?)?.toInt();
    final apiBucketRaw = _s(data['statusBucket']);
    final tier = tierColor(apiBucketRaw);
    final tierText = prettyBucket(apiBucketRaw);

    final kpis8 = <_Kpi>[
      _Kpi('Delivered', _intStr(delivered.round())),
      _Kpi('DCR', _pctStr(dcr)),
      _Kpi('DSC DPMO', _intStr(dnr.round())),
      _Kpi('LoR DPMO', _intStr(lor.round())),
      _Kpi('POD', _pctStr(pod)),
      _Kpi('CC', _pctStr(cc)),
      _Kpi('CE', _ceDisplayStr(ceCount)),
      _Kpi('CDF DPMO', _intStr(cdf.round())),
    ];

    return CoPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 18,
        vertical: isMobile ? 14 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top row: rank badge + name + tier pill + score ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RankBadge(rank: rank, tierColor: tier),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            transporterId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.labelSecondaryLight,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tier.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tierText.toUpperCase(),
                            style: AppTypography.caption2.copyWith(
                              color: tier,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (isUnmatched && onAssignTid != null) ...[
                          const SizedBox(width: 6),
                          CoPressable(
                            onTap: onAssignTid,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.codriverGreen,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    de ? 'Zuordnen' : 'Assign',
                                    style:
                                        AppTypography.caption2.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SCORE',
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _pctStr(score),
                    style: AppTypography.title3.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          const SizedBox(height: 12),
          // ── KPI grid ──
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 720
                  ? 8
                  : c.maxWidth >= 520
                      ? 4
                      : c.maxWidth >= 360
                          ? 4
                          : 2;
              const gap = 12.0;
              final cellW = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: 12,
                children: [
                  for (final k in kpis8)
                    SizedBox(
                      width: cellW,
                      child: _KpiCell(label: k.label, value: k.value),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  _Kpi(this.label, this.value);
}

class _KpiCell extends StatelessWidget {
  final String label;
  final String value;
  const _KpiCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption2.copyWith(
            color: AppColors.labelSecondaryLight,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverDeep,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int? rank;
  final Color tierColor;
  const _RankBadge({required this.rank, required this.tierColor});

  @override
  Widget build(BuildContext context) {
    if (rank == null) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E5EA)),
        ),
        alignment: Alignment.center,
        child: Text(
          '—',
          style: AppTypography.subheadline.copyWith(
            color: AppColors.labelTertiaryLight,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: AppTypography.subheadline.copyWith(
          color: tierColor,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.green50,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.codriverDeep,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Reassign Dialog ─────────────────────────────────────────────────
//
// Opens from a scorecard row whose Transporter-ID does not match any of
// the admin's drivers. Lists drivers with `tidPending: true` (their TID
// is still a generated PENDING-XXXXXX placeholder). Picking one writes
// the real TID onto that driver and refreshes the report's driverNames
// map so the row immediately shows the correct name.
class _ReassignDriverDialog extends StatelessWidget {
  final String dspUid;
  final String unmatchedTid;
  final DocumentReference<Map<String, dynamic>> reportRef;

  const _ReassignDriverDialog({
    required this.dspUid,
    required this.unmatchedTid,
    required this.reportRef,
  });

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final mediaW = MediaQuery.of(context).size.width;
    final dialogW = mediaW < 480 ? mediaW - 32 : 460.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogW, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                de ? 'TID zuordnen' : 'Assign TID',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                de
                    ? 'Wähle den Fahrer, zu dem die TID '
                        '$unmatchedTid '
                        'gehört. Die TID wird beim Fahrer gespeichert und '
                        'die Scorecard wird neu gematcht.'
                    : 'Pick the driver this TID '
                        '$unmatchedTid '
                        'belongs to. The TID is saved on the driver and the '
                        'scorecard is re-matched.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(dspUid)
                      .collection('drivers')
                      .where('tidPending', isEqualTo: true)
                      .snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.codriverGreen,
                            ),
                          ),
                        ),
                      );
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          de
                              ? 'Keine Fahrer mit ausstehender TID gefunden. '
                                  'Lege den Fahrer im Drivers Hub neu an, '
                                  'ohne TID einzutragen.'
                              : 'No drivers with a pending TID found. '
                                  'Re-create the driver in the Drivers Hub '
                                  'without entering a TID.',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      );
                    }
                    docs.sort((a, b) {
                      final an =
                          (a.data()['driverName'] ?? '').toString();
                      final bn =
                          (b.data()['driverName'] ?? '').toString();
                      return an.toLowerCase().compareTo(bn.toLowerCase());
                    });
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (ctx, i) {
                        final d = docs[i];
                        final data = d.data();
                        final name =
                            (data['driverName'] ?? '').toString();
                        final placeholderTid = d.id;
                        return _PendingDriverTile(
                          name: name.isEmpty
                              ? (de ? 'Ohne Name' : 'No name')
                              : name,
                          placeholderTid: placeholderTid,
                          onTap: () => _assign(
                            context,
                            driverDoc: d.reference,
                            driverName: name,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: CoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: de ? 'Abbrechen' : 'Cancel',
                  variant: CoButtonVariant.quiet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assign(
    BuildContext context, {
    required DocumentReference<Map<String, dynamic>> driverDoc,
    required String driverName,
  }) async {
    final realTid = unmatchedTid.trim().toUpperCase();
    if (realTid.isEmpty) return;

    // Resolved before the awaits below so the SnackBars stay localized.
    final de = Localizations.localeOf(context).languageCode == 'de';
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // Update the driver doc: real TID + flip tidPending off.
      await driverDoc.set({
        'transporterId': realTid,
        'tidPending': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Write the name into the report's driverNames subcollection so
      // this week's scorecard rows render the driver name immediately.
      await reportRef
          .collection('driverNames')
          .doc(realTid)
          .set({
        'transporterId': realTid,
        'driverName': driverName,
        'assignedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            de
                ? 'TID $realTid → $driverName zugeordnet.'
                : 'TID $realTid → assigned to $driverName.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Fehler beim Zuordnen: $e' : 'Assignment failed: $e',
          ),
        ),
      );
    }
  }
}

class _PendingDriverTile extends StatelessWidget {
  final String name;
  final String placeholderTid;
  final VoidCallback onTap;

  const _PendingDriverTile({
    required this.name,
    required this.placeholderTid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CoPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E5EA)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person_rounded,
                  size: 18, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    placeholderTid,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════════════
//  Company scorecard summary widgets (admin) — mirrors the driver dashboard
//  so the admin sees every company KPI value per week.
// ════════════════════════════════════════════════════════════════════════

String _coSectionLabel(BuildContext context, String key) {
  final loc = AppLocalizations.of(context);
  switch (key) {
    case 'safety':
      return loc.t('dash_company_section_safety');
    case 'compliance':
      return loc.t('dash_company_section_compliance');
    case 'customerDeliveryExperience':
      return loc.t('dash_company_section_customer_delivery_experience');
    case 'quality':
      return loc.t('dash_company_section_quality');
    case 'standardWorkCompliance':
      return loc.t('dash_company_section_standard_work_compliance');
    default:
      return key;
  }
}

String _coMetricLabel(BuildContext context, String key) {
  final loc = AppLocalizations.of(context);
  switch (key) {
    case 'fico':
      return loc.t('dash_metric_fico');
    case 'speedingEventRatePer100Trips':
      return loc.t('dash_metric_speeding_event_rate');
    case 'mentorAdoptionRate':
      return loc.t('dash_metric_mentor_adoption_rate');
    case 'vehicleAuditCompliance':
      return loc.t('dash_metric_vehicle_audit_compliance');
    case 'breachOfContract':
      return loc.t('dash_metric_breach_of_contract');
    case 'workingHoursCompliance':
      return loc.t('dash_metric_working_hours_compliance');
    case 'comprehensiveAuditScore':
      return loc.t('dash_metric_comprehensive_audit_score');
    case 'customerEscalationDpmo':
      return loc.t('dash_metric_customer_escalation_dpmo');
    case 'customerDeliveryFeedback':
      return loc.t('dash_metric_customer_delivery_feedback');
    case 'deliveryCompletionRate':
      return loc.t('dash_metric_delivery_completion_rate');
    case 'dnrDpmo':
      return loc.t('dash_metric_dnr_dpmo');
    case 'lorDpmo':
      return loc.t('dash_metric_lor_dpmo');
    case 'dscDpmo':
      return loc.t('dash_metric_dsc_dpmo');
    case 'photoOnDelivery':
      return loc.t('dash_metric_photo_on_delivery');
    case 'contactCompliance':
      return loc.t('dash_metric_contact_compliance');
    default:
      return key;
  }
}

List<String> _coOrderedSections(Iterable<String> keys) {
  const order = <String>[
    'safety',
    'compliance',
    'customerDeliveryExperience',
    'quality',
    'standardWorkCompliance',
  ];
  final existing = keys.toSet();
  return [
    ...order.where(existing.contains),
    ...keys.where((k) => !order.contains(k)),
  ];
}

List<String> _coOrderedMetrics(String sectionKey, Iterable<String> keys) {
  const metricOrder = <String, List<String>>{
    'safety': ['fico', 'speedingEventRatePer100Trips', 'mentorAdoptionRate'],
    'compliance': [
      'vehicleAuditCompliance',
      'workingHoursCompliance',
      'comprehensiveAuditScore',
      'breachOfContract',
    ],
    'customerDeliveryExperience': [
      'customerEscalationDpmo',
      'customerDeliveryFeedback',
    ],
    'quality': ['deliveryCompletionRate', 'dnrDpmo', 'lorDpmo'],
    'standardWorkCompliance': [
      'dscDpmo',
      'photoOnDelivery',
      'contactCompliance',
    ],
  };
  final desired = metricOrder[sectionKey] ?? const <String>[];
  final existing = keys.toSet();
  return [
    ...desired.where(existing.contains),
    ...keys.where((k) => !desired.contains(k)),
  ];
}

bool _coUsesPercent(String key) {
  switch (key) {
    case 'mentorAdoptionRate':
    case 'vehicleAuditCompliance':
    case 'workingHoursCompliance':
    case 'deliveryCompletionRate':
    case 'photoOnDelivery':
    case 'contactCompliance':
      return true;
    default:
      return false;
  }
}

String _coFormatValue(String key, dynamic rawValue) {
  if (rawValue == null) return '—';
  if (rawValue is num) {
    final num value = rawValue;
    final hasFraction = value % 1 != 0;
    final formatted = hasFraction
        ? value.toStringAsFixed(2).replaceAll('.', ',')
        : value.toString();
    return _coUsesPercent(key) ? '$formatted%' : formatted;
  }
  final text = _s(rawValue).trim();
  return text.isEmpty ? '—' : text;
}

// Status colours identical to the company scorecard the driver sees:
//  Fantastic+ green · Fantastic blue · Great yellow · Fair orange · Poor red.
Color _coBucketColor(String raw) {
  switch (_s(raw).trim().toUpperCase()) {
    case 'FANTASTIC_PLUS':
      return const Color(0xFF00B287);
    case 'FANTASTIC':
      return const Color(0xFF0082AF);
    case 'GREAT':
      return const Color(0xFFF7AA00);
    case 'FAIR':
      return const Color(0xFFF47400);
    case 'POOR':
      return const Color(0xFFCE4121);
    default:
      return const Color(0xFF64748B);
  }
}

/// Company overall status derived from the % score when the report has no
/// explicit `overallStatus` (thresholds mirror the driver dashboard).
String _bucketFromScore(double? s) {
  if (s == null) return '';
  if (s >= 88) return 'FANTASTIC_PLUS';
  if (s >= 80) return 'FANTASTIC';
  if (s >= 70) return 'GREAT';
  if (s >= 60) return 'FAIR';
  return 'POOR';
}

String _coPretty(String raw) {
  switch (_s(raw).trim().toUpperCase()) {
    case 'FANTASTIC_PLUS':
      return 'Fantastic+';
    case 'FANTASTIC':
      return 'Fantastic';
    case 'GREAT':
      return 'Great';
    case 'FAIR':
      return 'Fair';
    case 'POOR':
      return 'Poor';
    default:
      return _s(raw);
  }
}

/// One flattened company section group + its metric count (for masonry
/// column balancing).
class _CoGroupData {
  final String sectionKey;
  final Map<String, dynamic> metrics;
  final int weight;
  const _CoGroupData(this.sectionKey, this.metrics, this.weight);
}

/// Compact chip showing a company category and its overall status colour,
/// e.g. "Compliance & Safety · FANTASTIC".
class _CoCategoryChip extends StatelessWidget {
  final String label;
  final String status;
  const _CoCategoryChip({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.isEmpty
        ? const Color(0xFF64748B)
        : _coBucketColor(status);
    final statusText = status.isEmpty ? '' : _coPretty(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption2.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
          if (statusText.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(
              statusText.toUpperCase(),
              style: AppTypography.caption2.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoSummaryGroup extends StatelessWidget {
  final String sectionKey;
  final Map<String, dynamic> metrics;
  const _CoSummaryGroup({required this.sectionKey, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final metricKeys = _coOrderedMetrics(sectionKey, metrics.keys);
    if (metricKeys.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 2),
          child: Text(
            _coSectionLabel(context, sectionKey).toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        for (int i = 0; i < metricKeys.length; i++) ...[
          _CoSummaryMetricRow(
            metricKey: metricKeys[i],
            metric: _strMap(metrics[metricKeys[i]]),
          ),
          if (i != metricKeys.length - 1)
            const Divider(height: 1, color: Color(0xFFEEF0F2)),
        ],
      ],
    );
  }
}

class _CoSummaryMetricRow extends StatelessWidget {
  final String metricKey;
  final Map<String, dynamic> metric;
  const _CoSummaryMetricRow({required this.metricKey, required this.metric});

  @override
  Widget build(BuildContext context) {
    final valueText = _coFormatValue(metricKey, metric['value']);
    final statusRaw = _s(metric['status']);
    final statusText = statusRaw.isEmpty ? '' : _coPretty(statusRaw);
    final statusColor = _coBucketColor(statusRaw);
    // Single line: label ......... value  status.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _coMetricLabel(context, metricKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.footnote.copyWith(
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            valueText,
            style: AppTypography.subheadline.copyWith(
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (statusText.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 58),
              alignment: Alignment.centerRight,
              child: Text(
                statusText,
                textAlign: TextAlign.right,
                style: AppTypography.caption2.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  Driver detail — Scorecard trend (all weeks) + compact Concessions +
//  POD-Quality hits + Customer-Feedback hits. Opened by tapping a driver
//  card on the weekly scorecard.
// ════════════════════════════════════════════════════════════════════════

class _DriverScoreDetailPage extends StatefulWidget {
  final String uid;
  final String transporterId;
  final String driverName;
  final double currentScore;
  final String currentBucket;

  /// Report the detail was opened from — defines "this week".
  final String reportId;

  const _DriverScoreDetailPage({
    required this.uid,
    required this.transporterId,
    required this.driverName,
    required this.currentScore,
    required this.currentBucket,
    required this.reportId,
  });

  @override
  State<_DriverScoreDetailPage> createState() =>
      _DriverScoreDetailPageState();
}

class _DriverScoreDetailPageState extends State<_DriverScoreDetailPage> {
  // Datenladung + Concessions/POD/CDF-Sektionen leben in
  // `widgets/driver_performance_sections.dart` — dieselbe Quelle, die auch
  // die Driver-Hub-Detailseite („2a") verwendet.
  late final Future<DriverPerformanceData> _future = loadDriverPerformanceData(
    dspUid: widget.uid,
    transporterId: widget.transporterId,
    reportId: widget.reportId,
  );

  /// German when the app language is German, English otherwise.
  bool get _de => Localizations.localeOf(context).languageCode == 'de';
  String _tr(String de, String en) => _de ? de : en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        title: Text(widget.driverName),
      ),
      body: FutureBuilder<DriverPerformanceData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.codriverGreen),
              ),
            );
          }
          final data = snap.data;
          if (snap.hasError || data == null) {
            return Center(
              child: Text(_tr('Konnte Daten nicht laden', 'Could not load data') + ': ${snap.error}',
                  style: const TextStyle(color: Color(0xFF6B7280))),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  _headerCard(data),
                  const SizedBox(height: 14),
                  _trendCard(data.trend),
                  const SizedBox(height: 14),
                  // Concessions · POD Quality Hits · Customer Feedback Hits —
                  // gemeinsames Widget mit der Driver-Hub-Detailseite.
                  DriverPerformanceSections.fromData(data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section cards ──

  BoxDecoration get _card => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
        boxShadow: AppElevation.level1,
      );

  Widget _sectionTitle(IconData icon, String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.codriverDeep),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.headline.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle,
              style: AppTypography.caption1
                  .copyWith(color: const Color(0xFF6B7280))),
        ],
      ],
    );
  }

  Widget _headerCard(DriverPerformanceData data) {
    final color = _coBucketColor(widget.currentBucket);
    final weekLabel = data.currentWeekNo > 0
        ? _tr('KW ${data.currentWeekNo} · ${data.currentYear}',
            'WEEK ${data.currentWeekNo} · ${data.currentYear}')
        : _tr('AKTUELLE WOCHE', 'CURRENT WEEK');
    return Container(
      decoration: _card,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.driverName,
                    style: AppTypography.title3.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 2),
                Text(widget.transporterId,
                    style: AppTypography.caption1
                        .copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(weekLabel.toUpperCase(),
                  style: AppTypography.caption2.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  )),
              const SizedBox(height: 2),
              Text(_pctStr(widget.currentScore),
                  style: AppTypography.title3.copyWith(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _coPretty(widget.currentBucket).toUpperCase(),
                  style: AppTypography.caption2.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trendCard(List<DriverPerformanceTrendEntry> trend) {
    return Container(
      decoration: _card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.timeline_rounded, 'Scorecard Trend',
              subtitle: _tr('Alle bisherigen Wochen — einzeln aufgelistet',
                  'All previous weeks — listed individually')),
          const SizedBox(height: 10),
          if (trend.isNotEmpty) ...[
            // Overall average across ALL weeks, shown above the list.
            Builder(builder: (context) {
              final avg =
                  trend.fold<double>(0, (s, e) => s + e.score) /
                      trend.length;
              final avgBucket = _bucketFromScore(avg);
              final bucketColor = _coBucketColor(avgBucket);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tr('GESAMTSCORE (Ø)', 'OVERALL SCORE (avg)'),
                        style: AppTypography.caption2.copyWith(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    if (avgBucket.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bucketColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _coPretty(avgBucket),
                          style: AppTypography.caption2.copyWith(
                            color: bucketColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      _pctStr(avg),
                      style: AppTypography.headline.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _tr('${trend.length} Wochen',
                            '${trend.length} weeks'),
                        style: AppTypography.caption2.copyWith(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          if (trend.isEmpty)
            Text(_tr('Noch keine Scorecard-Historie.',
                    'No scorecard history yet.'),
                style: AppTypography.footnote
                    .copyWith(color: const Color(0xFF9CA3AF)))
          else
            for (int i = 0; i < trend.length; i++)
              Container(
                color: i.isOdd ? const Color(0xFFF6F7F9) : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        _tr('KW ${trend[i].week} · ${trend[i].year}',
                            'Week ${trend[i].week} · ${trend[i].year}'),
                        style: AppTypography.subheadline.copyWith(
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _coBucketColor(trend[i].bucket)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _coPretty(trend[i].bucket),
                        style: AppTypography.caption2.copyWith(
                          color: _coBucketColor(trend[i].bucket),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _pctStr(trend[i].score),
                      style: AppTypography.subheadline.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
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

