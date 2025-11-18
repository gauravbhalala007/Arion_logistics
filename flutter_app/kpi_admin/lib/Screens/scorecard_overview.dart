// lib/screens/scorecard_overview.dart
import 'dart:typed_data';

import '../services/parser_api.dart';
import '../services/report_writer.dart';
import '../services/driver_csv.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⬇️ for uploading PDFs & CSVs
import 'package:file_picker/file_picker.dart';

import 'scorecard_week.dart';

import 'package:firebase_auth/firebase_auth.dart';

// NEW: shared shell + side menu
import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';

/// Simple German-style number formatting
final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

/// ---------- Week date helpers (ISO week: Monday start) ----------
DateTime _isoWeekStartUtc(int year, int week) {
  final jan4 = DateTime.utc(year, 1, 4);
  final week1Mon =
      jan4.subtract(Duration(days: jan4.weekday - DateTime.monday));
  return week1Mon.add(Duration(days: (week - 1) * 7));
}

String _dotted(DateTime d) => DateFormat('dd.MM.yyyy').format(d.toLocal());

/// ---------- Responsive helpers (match scorecard_week.dart) ----------
double _scaleForWidth(double w) {
  if (w >= 1440) return 1.0;
  if (w >= 1200) return 0.93 + (w - 1200) / 240 * (1.0 - 0.93);
  if (w >= 1000) return 0.86 + (w - 1000) / 200 * (0.93 - 0.86);
  if (w >= 800)  return 0.78 + (w - 800)  / 200 * (0.86 - 0.78);
  if (w >= 600)  return 0.70 + (w - 600)  / 200 * (0.78 - 0.70);
  if (w >= 420)  return 0.62 + (w - 420)  / 180 * (0.70 - 0.62);
  return 0.60;
}
double _sp(double base, double w) => base * _scaleForWidth(w);
double _pad(double base, double w) => base * _scaleForWidth(w);
bool _isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 1100;

/* ====================  Palette / styles  ==================== */
class _UI {
  static const bg = Color(0xFFF6F7F5);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const green = Color(0xFF5DBB98);
  static const greenDark = Color(0xFF16A34A);
  static const border = Color(0xFFE5E7EB);
  static const dark = Color(0xFF0B1220);
  static BoxShadow shadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 18,
    offset: Offset(0, 8),
  );
}

/* ====================  Model for view  ==================== */
class _ReportVM {
  final DocumentReference<Map<String, dynamic>> ref;
  final int year;
  final int week;
  final String label; // "Week 23 - 2025"
  final double? overall;
  final double? relNext;
  final double? relSame;
  final int? rankAtStation;
  final int? stationCount;
  final String? stationCode;

  _ReportVM({
    required this.ref,
    required this.year,
    required this.week,
    required this.label,
    required this.overall,
    required this.relNext,
    required this.relSame,
    required this.rankAtStation,
    required this.stationCount,
    required this.stationCode,
  });
}

class ScorecardOverviewPage extends StatefulWidget {
  const ScorecardOverviewPage({super.key});

  @override
  State<ScorecardOverviewPage> createState() => _ScorecardOverviewPageState();
}

class _ScorecardOverviewPageState extends State<ScorecardOverviewPage> {
  bool _busyUpload = false; // PDFs (bottom-left)
  bool _busyCsv = false;    // CSVs (top-right)

  Stream<List<_ReportVM>> _reportsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .limit(52)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = d.data();
              final s = (m['summary'] as Map?)?.cast<String, dynamic>() ?? {};
              final y = (m['year'] as num?)?.toInt() ?? 0;
              final w = (m['weekNumber'] as num?)?.toInt() ?? 0;
              return _ReportVM(
                ref: d.reference,
                year: y,
                week: w,
                label: (s['weekText'] ?? 'Week $w - $y').toString(),
                overall: (s['overallScore'] as num?)?.toDouble(),
                relNext: (s['reliabilityNextDay'] as num?)?.toDouble(),
                relSame: (s['reliabilitySameDay'] as num?)?.toDouble(),
                rankAtStation: (s['rankAtStation'] as num?)?.toInt(),
                stationCount: (s['stationCount'] as num?)?.toInt(),
                stationCode: s['stationCode'] as String?,
              );
            }).toList());
  }

  Future<void> _uploadWeeklyPdf() async {
    if (_busyUpload) return;
    setState(() => _busyUpload = true);

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        allowMultiple: true, // 👈 allow selecting multiple PDFs
      );

      if (picked == null || picked.files.isEmpty) {
        return; // user cancelled
      }

      int successCount = 0;

      for (final f in picked.files) {
        final Uint8List? bytes = f.bytes;
        if (bytes == null) continue; // skip weird cases

        // ✅ Parse directly (no Firebase Storage)
        final parsed = await ParserApi.parsePdf(bytes, filename: f.name);

        // ✅ Write to Firestore — keep a pseudo storagePath for traceability
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final pseudoPath = 'inline/$date/${f.name}'; // informational only

        await ReportWriter.writeReportAndScores(
          parserJson: parsed,
          storagePath: pseudoPath,
        );

        successCount++;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successCount == 1
                ? '1 scorecard parsed & saved. Dashboard updated.'
                : '$successCount scorecards parsed & saved. Dashboard updated.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload/parse failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyUpload = false);
    }
  }


  Future<void> _uploadDriverCsv() async {
    if (_busyCsv) return;
    setState(() => _busyCsv = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        setState(() => _busyCsv = false);
        return;
      }
      final f = picked.files.single;
      final Uint8List? bytes = f.bytes;
      if (bytes == null) throw Exception('No file bytes');

      // ✅ NEW: user-scoped update so ALL of this user’s reports/scores get names
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await DriverCsvService.importForUser(uid: uid, csvBytes: bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver names updated across all your reports.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyCsv = false);
    }
  }


  // ---- delete a single report doc (scores are NOT deleted) ----
  Future<void> _confirmAndDeleteReport(
    BuildContext context, {
    required DocumentReference<Map<String, dynamic>> reportRef,
    required String titleLabel,
  }) async {
    final w = MediaQuery.of(context).size.width;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: Text(
          'This will delete the report "$titleLabel" from Firestore.\n'
          'Scores and other data will NOT be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(fontSize: _sp(13, w), color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await reportRef.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  /* ---------------- Stats helpers ---------------- */
  double? _avg(Iterable<double?> xs) {
    final v = xs.whereType<double>().toList();
    if (v.isEmpty) return null;
    return v.reduce((a, b) => a + b) / v.length;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sc = _scaleForWidth(w);
    final narrow = _isNarrow(context);

    // AppShell title & optional actions (kept minimal; page still shows its own CSV buttons)
    final shellTitle = const Text('SCORE CARD DASHBOARD — Overview');

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content area (no local drawer/side menu here; handled by AppShell)
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.all(_pad(18, w)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row (hidden on narrow because AppBar from shell already shows a title)
                    if (!narrow)
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: _pad(8, w),
                              children: [
                                Text(
                                  'SCORE CARD DASHBOARD',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontSize: _sp(24, w),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: .2,
                                        color: _UI.textPrimary,
                                      ),
                                ),
                                Text('— Overview',
                                    style: TextStyle(
                                      fontSize: _sp(13, w),
                                      color: _UI.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _busyCsv ? null : _uploadDriverCsv,
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  _UI.textPrimary.withOpacity(.9),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(24 * sc)),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                  horizontal: _pad(16, w),
                                  vertical: _pad(12, w)),
                            ),
                            icon: Icon(Icons.upload_file, size: _sp(18, w)),
                            label: Text(
                                _busyCsv ? 'Uploading…' : 'Upload Driver CSV',
                                style: TextStyle(fontSize: _sp(14, w))),
                          ),
                        ],
                      ),
                    if (!narrow) SizedBox(height: _pad(16, w)),

                    Expanded(
                      child: StreamBuilder<List<_ReportVM>>(
                        stream: _reportsStream(),
                        builder: (context, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(
                                child: Text('Error: ${snap.error}'));
                          }
                          final list = snap.data ?? const <_ReportVM>[];

                          // ======== EMPTY STATE (upload panel + summary) ========
                          if (list.isEmpty) {
                            final uploadPanel = _Panel(
                              title: 'UPLOAD SCORECARD PDF',
                              trailing: Icon(Icons.more_horiz,
                                  color: _UI.textSecondary,
                                  size: _sp(20, w)),
                              child: LayoutBuilder(builder: (context, c) {
                                final iconSize =
                                    w < 380 ? _sp(28, w) : _sp(34, w);
                                final gap =
                                    w < 380 ? _pad(6, w) : _pad(8, w);
                                return Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 120),
                                  padding: EdgeInsets.symmetric(
                                      vertical: _pad(12, w)),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(16 * sc),
                                    border: Border.all(color: _UI.border),
                                    color: _UI.bg,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_rounded,
                                          size: iconSize),
                                      SizedBox(height: gap),
                                      Text(
                                        _busyUpload
                                            ? 'Uploading…'
                                            : 'Upload your Scorecard PDF',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: _sp(13, w),
                                          color: _UI.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: gap),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            minWidth: 140),
                                        child: FilledButton(
                                          onPressed: _busyUpload
                                              ? null
                                              : _uploadWeeklyPdf,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: _UI.greenDark,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20 * sc),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: _pad(16, w),
                                              vertical: _pad(10, w),
                                            ),
                                          ),
                                          child: Text('Choose file',
                                              style: TextStyle(
                                                  fontSize: _sp(14, w))),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );

                            final summaryRight = _Panel(
                              title: 'Score Card Summary',
                              trailing: Icon(Icons.more_horiz,
                                  color: _UI.textSecondary,
                                  size: _sp(20, w)),
                              child: Padding(
                                padding: EdgeInsets.all(_pad(12, w)),
                                child: Text(
                                  'No reports yet. Upload your first Scorecard PDF to get started.',
                                  style: TextStyle(
                                      color: _UI.textSecondary,
                                      fontSize: _sp(13, w)),
                                ),
                              ),
                            );

                            if (narrow) {
                              return ListView(
                                children: [
                                  uploadPanel,
                                  SizedBox(height: _pad(16, w)),
                                  summaryRight,
                                ],
                              );
                            } else {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child:
                                          ListView(children: [uploadPanel])),
                                  SizedBox(width: _pad(16, w)),
                                  Expanded(flex: 2, child: summaryRight),
                                ],
                              );
                            }
                          }

                          // ======== NON-EMPTY ========
                          final latest = list.first;
                          final currentYear = latest.year;

                          final byYear = <int, List<_ReportVM>>{};
                          for (final r in list) {
                            byYear.putIfAbsent(r.year, () => []).add(r);
                          }
                          final ytd = byYear[currentYear] ?? [];

                          final ytdOverall = _avg(ytd.map((e) => e.overall));
                          final ytdRel = _avg(ytd.map((e) => e.relNext ?? e.relSame));

                          double? lastWeekOverallDelta, lastWeekRelDelta;
                          if (list.length >= 2) {
                            final prev = list[1];
                            if (latest.overall != null && prev.overall != null) {
                              lastWeekOverallDelta = latest.overall! - prev.overall!;
                            }
                            final lRel = latest.relNext ?? latest.relSame;
                            final pRel = prev.relNext ?? prev.relSame;
                            if (lRel != null && pRel != null) {
                              lastWeekRelDelta = lRel - pRel;
                            }
                          }

                          double? yoyOverallDelta, yoyRelDelta;
                          final prevYear = currentYear - 1;
                          if (byYear.containsKey(prevYear)) {
                            final py = byYear[prevYear]!;
                            final pyOverall = _avg(py.map((e) => e.overall));
                            final cyOverall = ytdOverall;
                            if (pyOverall != null && cyOverall != null) {
                              yoyOverallDelta = cyOverall - pyOverall;
                            }
                            final pyRel = _avg(py.map((e) => e.relNext ?? e.relSame));
                            if (ytdRel != null && pyRel != null) {
                              yoyRelDelta = ytdRel - pyRel;
                            }
                          }

                          final chart = list.take(12).toList().reversed.toList();

                          // ----- LEFT column content
                          final leftColumnContent = <Widget>[
                            _ResponsiveStatStrip(
                              latestOverall: latest.overall,
                              ytdOverall: ytdOverall,
                              lastWeekOverallDelta: lastWeekOverallDelta,
                              yoyOverallDelta: yoyOverallDelta,
                              latestRel: latest.relNext ?? latest.relSame,
                              ytdRel: ytdRel,
                              lastWeekRelDelta: lastWeekRelDelta,
                              yoyRelDelta: yoyRelDelta,
                              yearLabel: latest.year.toString(),
                            ),
                            SizedBox(height: _pad(16, w)),
                            _Panel(
                              title: 'Score Card Overview',
                              child: _MiniBarChart(
                                points: chart
                                    .map((p) => _BarPoint(
                                          label:
                                              'W${p.week.toString().padLeft(2, '0')}',
                                          value: p.overall ?? 0,
                                          ref: p.ref,
                                        ))
                                    .toList(),
                              ),
                            ),
                            SizedBox(height: _pad(16, w)),
                            _Panel(
                              title: 'UPLOAD SCORECARD PDF',
                              trailing: Icon(Icons.more_horiz,
                                  color: _UI.textSecondary,
                                  size: _sp(20, w)),
                              child: LayoutBuilder(builder: (context, c) {
                                final iconSize =
                                    w < 380 ? _sp(28, w) : _sp(34, w);
                                final gap =
                                    w < 380 ? _pad(6, w) : _pad(8, w);
                                return Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 120),
                                  padding: EdgeInsets.symmetric(
                                      vertical: _pad(12, w)),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(16 * sc),
                                    border: Border.all(color: _UI.border),
                                    color: _UI.bg,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_rounded,
                                          size: iconSize),
                                      SizedBox(height: gap),
                                      Text(
                                        _busyUpload
                                            ? 'Uploading…'
                                            : 'Upload your Scorecard PDF',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: _sp(13, w),
                                          color: _UI.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: gap),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            minWidth: 140),
                                        child: FilledButton(
                                          onPressed: _busyUpload
                                              ? null
                                              : _uploadWeeklyPdf,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: _UI.greenDark,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20 * sc),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: _pad(16, w),
                                              vertical: _pad(10, w),
                                            ),
                                          ),
                                          child: Text('Choose file',
                                              style: TextStyle(
                                                  fontSize: _sp(14, w))),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ];

                          // ----- RIGHT panel (summary list) with 3-dots delete menu
                          final rightPanel = _Panel(
                            title: 'Score Card Summary',
                            trailing: Icon(Icons.more_horiz,
                                color: _UI.textSecondary, size: _sp(20, w)),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: _UI.border),
                              itemBuilder: (_, i) {
                                final p = list[i];
                                final badge =
                                    (p.overall != null) ? _pct.format(p.overall) : '—';

                                final start = _isoWeekStartUtc(p.year, p.week);
                                final end = start.add(const Duration(days: 6));
                                final dateRange = '${_dotted(start)} – ${_dotted(end)}';

                                final rankLine =
                                    (p.rankAtStation != null && p.stationCount != null)
                                        ? 'Rank in Station: ${p.rankAtStation} of ${p.stationCount}'
                                        : (p.stationCode ?? 'FANTASTIC');

                                final rowTitle =
                                    'Score Card ${p.label.split(" ").last} KW ${p.week}';

                                return ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: _pad(8, w)),
                                  leading: CircleAvatar(
                                    backgroundColor: _UI.green.withOpacity(.2),
                                    radius: _pad(26, w),
                                    child: Text(
                                      badge,
                                      style: TextStyle(
                                        color: _UI.greenDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: _sp(12, w),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    rowTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: _sp(14, w),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: _pad(2, w)),
                                      Text(
                                        dateRange,
                                        style: TextStyle(
                                          color: _UI.textSecondary,
                                          fontSize: _sp(12, w),
                                        ),
                                      ),
                                      Text(
                                        '• $rankLine • ',
                                        style: TextStyle(
                                          color: _UI.textSecondary,
                                          fontSize: _sp(12, w),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuButton<String>(
                                        tooltip: 'More',
                                        onSelected: (v) {
                                          if (v == 'delete') {
                                            _confirmAndDeleteReport(
                                              context,
                                              reportRef: p.ref,
                                              titleLabel: rowTitle,
                                            );
                                          }
                                        },
                                        itemBuilder: (ctx) => [
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text(
                                              'Delete report',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w700,
                                                fontSize: _sp(13, w),
                                              ),
                                            ),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert),
                                      ),
                                      SizedBox(width: _pad(4, w)),
                                      Icon(Icons.chevron_right_rounded,
                                          size: _sp(22, w)),
                                    ],
                                  ),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ScorecardWeekPage(reportRef: p.ref),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );

                          if (narrow) {
                            return ListView(
                              children: [
                                ...leftColumnContent,
                                SizedBox(height: _pad(16, w)),
                                rightPanel,
                              ],
                            );
                          } else {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ListView(children: leftColumnContent),
                                ),
                                SizedBox(width: _pad(16, w)),
                                Expanded(
                                  flex: 2,
                                  child: ListView(
                                    children: [
                                      rightPanel,
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Use shared AppShell + shared side menu
    return AppShell(
      menuWidth: 280,
      sideMenu: AppSideMenu(
        width: 280,
        active: AppNav.dashboard,
      ),
      title: shellTitle,
      body: Stack(
        children: [
          Container(color: _UI.bg, child: body),

          if (_busyUpload) ...[
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.08),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Uploading & processing scorecards…',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* ====================  UI helpers  ==================== */

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Panel({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: _UI.card,
        borderRadius: BorderRadius.circular(16 * _scaleForWidth(w)),
        boxShadow: [_UI.shadow],
        border: Border.all(color: _UI.border),
      ),
      padding: EdgeInsets.all(_pad(16, w)),
      child: Column(
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: _sp(18, w), fontWeight: FontWeight.w800)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: _pad(12, w)),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? value; // percent
  final double? delta; // change vs prev period
  final String deltaCaption;
  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    this.delta,
    this.deltaCaption = 'from last week',
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sc = _scaleForWidth(w);
    final isUp = (delta ?? 0) >= 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _UI.card,
        borderRadius: BorderRadius.circular(16 * sc),
        boxShadow: [_UI.shadow],
        border: Border.all(color: _UI.border),
      ),
      padding: EdgeInsets.all(_pad(16, w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(12, w),
              color: _UI.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
          SizedBox(height: _pad(4, w)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(12, w),
              color: _UI.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: _pad(8, w)),
          Text(
            value != null ? '${_pct.format(value)} %' : '—',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(28, w),
              fontWeight: FontWeight.w800,
              color: _UI.textPrimary,
            ),
          ),
          SizedBox(height: _pad(8, w)),
          if (delta != null)
            Padding(
              padding: EdgeInsets.only(top: _pad(4, w)),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: _pad(6, w),
                runSpacing: _pad(2, w),
                children: [
                  Icon(
                    isUp ? Icons.trending_up : Icons.trending_down,
                    size: _sp(16, w),
                    color: isUp ? _UI.greenDark : Colors.red,
                  ),
                  Text(
                    '${isUp ? '+' : ''}${_pct.format(delta!.abs())} %',
                    style: TextStyle(
                      fontSize: _sp(13, w),
                      color: isUp ? _UI.greenDark : Colors.red,
                      fontWeight: FontWeight.w700),
                  ),
                  Text(
                    deltaCaption,
                    style: TextStyle(
                      color: _UI.textSecondary,
                      fontSize: _sp(12, w),
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

/* ====================  Chart (unchanged)  ==================== */

class _BarPoint {
  final String label;
  final double value;
  final DocumentReference<Map<String, dynamic>> ref;
  _BarPoint({required this.label, required this.value, required this.ref});
}

class _MiniBarChart extends StatelessWidget {
  final List<_BarPoint> points;
  const _MiniBarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sc = _scaleForWidth(w);

    const axisMax = 100.0;
    final isNarrow = _isNarrow(context);

    final xLabelAreaH = (_pad(34, w)).clamp(28.0, 56.0);
    final chartH = (isNarrow ? _pad(240, w) : _pad(300, w));

    return SizedBox(
      height: chartH,
      child: LayoutBuilder(builder: (context, c) {
        final targetSlots = (points.length * 2.2).clamp(10, 36).toDouble();
        final barW = (c.maxWidth / targetSlots).clamp(8, 18).toDouble() * sc;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _UI.border),
            borderRadius: BorderRadius.circular(16 * sc),
          ),
          padding: EdgeInsets.all(_pad(16, w)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Y-axis labels
              SizedBox(
                width: _pad(36, w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [100, 80, 60, 40, 20, 0]
                      .map((v) => Text('$v',
                          style: TextStyle(color: _UI.textSecondary)))
                      .toList(),
                ),
              ),
              SizedBox(width: _pad(8, w)),

              // Chart area
              Expanded(
                child: LayoutBuilder(builder: (context, area) {
                  final usableH = area.maxHeight - xLabelAreaH;

                  return Stack(
                    children: [
                      // Grid
                      Positioned.fill(
                        top: 0,
                        bottom: xLabelAreaH,
                        child: Column(
                          children: List.generate(
                            5,
                            (_) => Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: _UI.border.withOpacity(0.8),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom baseline
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: xLabelAreaH - 1,
                        child: Container(height: 1, color: _UI.border.withOpacity(0.8)),
                      ),

                      // Bars
                      Positioned.fill(
                        top: 0,
                        bottom: xLabelAreaH,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: points.map((p) {
                              final v = p.value.clamp(0, axisMax);
                              final h = (v / axisMax) * (usableH - _pad(8, w));
                              return GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ScorecardWeekPage(reportRef: p.ref),
                                  ),
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  height: h,
                                  width: barW,
                                  decoration: BoxDecoration(
                                    color: _UI.green,
                                    borderRadius: BorderRadius.circular(8 * sc),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // X labels strip
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: xLabelAreaH,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: points.map((p) {
                            return SizedBox(
                              width: barW * 2.2,
                              child: Text(
                                p.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _sp(11, w),
                                  color: _UI.textSecondary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/* ====================  Stat strip  ==================== */

class _ResponsiveStatStrip extends StatelessWidget {
  final double? latestOverall;
  final double? ytdOverall;
  final double? lastWeekOverallDelta;
  final double? yoyOverallDelta;

  final double? latestRel;
  final double? ytdRel;
  final double? lastWeekRelDelta;
  final double? yoyRelDelta;

  final String yearLabel;

  const _ResponsiveStatStrip({
    super.key,
    required this.latestOverall,
    required this.ytdOverall,
    required this.lastWeekOverallDelta,
    required this.yoyOverallDelta,
    required this.latestRel,
    required this.ytdRel,
    required this.lastWeekRelDelta,
    required this.yoyRelDelta,
    required this.yearLabel,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    if (w >= 1280) {
      // Desktop: one row of 4
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'SCORECARD',
              subtitle: 'LAST WEEK',
              value: latestOverall,
              delta: lastWeekOverallDelta,
            ),
          ),
          SizedBox(width: _pad(12, w)),
          Expanded(
            child: _StatCard(
              title: 'SCORECARD',
              subtitle: 'YEAR $yearLabel',
              value: ytdOverall,
              deltaCaption: 'from last year',
              delta: yoyOverallDelta,
            ),
          ),
          SizedBox(width: _pad(12, w)),
          Expanded(
            child: _StatCard(
              title: 'RELIABILITY SCORE',
              subtitle: 'LAST WEEK',
              value: latestRel,
              delta: lastWeekRelDelta,
            ),
          ),
          SizedBox(width: _pad(12, w)),
          Expanded(
            child: _StatCard(
              title: 'RELIABILITY SCORE',
              subtitle: 'YEAR $yearLabel',
              value: ytdRel,
              deltaCaption: 'from last year',
              delta: yoyRelDelta,
            ),
          ),
        ],
      );
    } else if (w >= 800) {
      // Tablet: 2×2
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'SCORECARD',
                  subtitle: 'LAST WEEK',
                  value: latestOverall,
                  delta: lastWeekOverallDelta,
                ),
              ),
              SizedBox(width: _pad(12, w)),
              Expanded(
                child: _StatCard(
                  title: 'SCORECARD',
                  subtitle: 'YEAR $yearLabel',
                  value: ytdOverall,
                  deltaCaption: 'from last year',
                  delta: yoyOverallDelta,
                ),
              ),
            ],
          ),
          SizedBox(height: _pad(12, w)),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'RELIABILITY SCORE',
                  subtitle: 'LAST WEEK',
                  value: latestRel,
                  delta: lastWeekRelDelta,
                ),
              ),
              SizedBox(width: _pad(12, w)),
              Expanded(
                child: _StatCard(
                  title: 'RELIABILITY SCORE',
                  subtitle: 'YEAR $yearLabel',
                  value: ytdRel,
                  deltaCaption: 'from last year',
                  delta: yoyRelDelta,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Mobile: stacked
      return Column(
        children: [
          _StatCard(
            title: 'SCORECARD',
            subtitle: 'LAST WEEK',
            value: latestOverall,
            delta: lastWeekOverallDelta,
          ),
          SizedBox(height: _pad(12, w)),
          _StatCard(
            title: 'SCORECARD',
            subtitle: 'YEAR $yearLabel',
            value: ytdOverall,
            deltaCaption: 'from last year',
            delta: yoyOverallDelta,
          ),
          SizedBox(height: _pad(12, w)),
          _StatCard(
            title: 'RELIABILITY SCORE',
            subtitle: 'LAST WEEK',
            value: latestRel,
            delta: lastWeekRelDelta,
          ),
          SizedBox(height: _pad(12, w)),
          _StatCard(
            title: 'RELIABILITY SCORE',
            subtitle: 'YEAR $yearLabel',
            value: ytdRel,
            deltaCaption: 'from last year',
            delta: yoyRelDelta,
          ),
        ],
      );
    }
  }
}
