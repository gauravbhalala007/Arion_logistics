// RESPONSIVE + DESKTOP-STYLE DRIVER ROW — scorecard_week.dart
import 'dart:typed_data';

import '../services/driver_csv.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// for uploading CSV
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import '../main.dart' show storage;

// 🔸 Added: need current user id to read scores under users/{uid}/scores
import 'package:firebase_auth/firebase_auth.dart';

// NEW: shared shell + side menu
import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';

final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

// ---- tiny helpers ----
String _s(dynamic v) => (v == null) ? '' : v.toString();

String _pctStr(num? v) {
  if (v == null) return '';
  try { return '${_pct.format(v)} %'; } catch (_) { return ''; }
}

String _intStr(num? v) {
  if (v == null) return '';
  try { return _int.format(v); } catch (_) { return ''; }
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

// --------- responsive scale helpers ---------
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

bool _isCompactRow(double w) => w < 960;
int _summaryCols(double w) => w < 720 ? 1 : (w < 1200 ? 2 : 3);
int _kpiCols(double w) => w < 520 ? 2 : (w < 820 ? 3 : 4);

// ============================================

class ScorecardWeekPage extends StatefulWidget {
  const ScorecardWeekPage({
    super.key,
    required this.reportRef,
  });

  final DocumentReference<Map<String, dynamic>> reportRef;

  @override
  State<ScorecardWeekPage> createState() => _ScorecardWeekPageState();
}

class _ScorecardWeekPageState extends State<ScorecardWeekPage> {
  bool _busyUpload = false;

  // UI controls (search + bucket filter)
  String _query = '';
  String _bucket = 'ALL'; // ALL | FANTASTIC_PLUS | FANTASTIC | GREAT | FAIR | POOR
  static const _bucketItems = <String>['ALL','FANTASTIC_PLUS','FANTASTIC','GREAT','FAIR','POOR'];

  // 🔧 Updated: read from users/{uid}/scores instead of global 'scores'
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('scores')
        .where('reportRef', isEqualTo: widget.reportRef)
        .snapshots()
        .map((s) => s.docs);
  }

  /// Per-week names under reports/{reportId}/driverNames
  Stream<Map<String, String>> _driverNamesForWeek() {
    return widget.reportRef.collection('driverNames').snapshots().map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data() as Map<String, dynamic>;
        final id = _s(data['transporterId'] ?? d.id);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  /// Global fallback (/drivers)
  Stream<Map<String, String>> _driversNameMapGlobal() {
    return FirebaseFirestore.instance.collection('drivers').snapshots().map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final id = _s(data['transporterId']);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  // ===== summary helpers =====
  String _statusText(double v) {
    if (v >= 85) return 'Fantastic';
    if (v >= 70) return 'Great';
    if (v >= 55) return 'Fair';
    return 'Poor';
  }

  Color _statusColor(double v) {
    if (v >= 85) return const Color(0xFF16A34A);
    if (v >= 70) return const Color(0xFF22C55E);
    if (v >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  // ===== API bucket mapping (driver rows) =====
  String _prettyBucket(String raw) {
    switch (_s(raw).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS': return 'Fantastic Plus';
      case 'FANTASTIC':      return 'Fantastic';
      case 'GREAT':          return 'Great';
      case 'FAIR':           return 'Fair';
      case 'POOR':           return 'Poor';
      default:               return _s(raw);
    }
  }

  Color _colorFromApiBucket(String apiBucket) {
    switch (_s(apiBucket).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
      case 'FANTASTIC': return const Color(0xFF16A34A);
      case 'GREAT':     return const Color(0xFF22C55E);
      case 'FAIR':      return const Color(0xFFF59E0B);
      case 'POOR':
      default:          return const Color(0xFFEF4444);
    }
  }

  Future<void> _uploadDriverCsv() async {
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
      if (mounted) setState(() => _busyUpload = false);
    }
  }


  // Compute ISO week date range (Mon–Sun)
  String _isoWeekRange(int year, int week) {
    final jan4 = DateTime(year, 1, 4);
    final jan4IsoWeekday = (jan4.weekday + 6) % 7; // Mon=0..Sun=6
    final mondayW1 = jan4.subtract(Duration(days: jan4IsoWeekday));
    final monday = mondayW1.add(Duration(days: (week - 1) * 7));
    final sunday = monday.add(const Duration(days: 6));
    final df = DateFormat('dd.MM.yyyy');
    return '${df.format(monday)} – ${df.format(sunday)}';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Title updates via stream (week number)
    final shellTitle = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.reportRef.snapshots(),
      builder: (context, snap) {
        final Map<String, dynamic> report = snap.data?.data() ?? <String, dynamic>{};
        final rawSummary = report['summary'];
        final summary = rawSummary is Map
            ? Map<String, dynamic>.from(rawSummary as Map)
            : <String, dynamic>{};
        final weekNumber = (summary['weekNumber'] as num?)?.toInt()
            ?? (report['weekNumber'] as num?)?.toInt();
        return Text(weekNumber != null ? 'SCORECARD WEEK $weekNumber' : 'SCORECARD WEEK');
      },
    );

    final csvAction = Padding(
      padding: EdgeInsets.only(right: _pad(8, w)),
      child: FilledButton.icon(
        onPressed: _busyUpload ? null : _uploadDriverCsv,
        icon: const Icon(Icons.upload),
        label: Text(
          _busyUpload ? 'Uploading…' : 'Upload Driver CSV',
          style: TextStyle(fontSize: _sp(14, w)),
        ),
      ),
    );

    // Your original page body (unchanged)
    final pageBody = Padding(
      padding: EdgeInsets.all(_pad(18, w)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Top bar: Title + date + controls =====
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: widget.reportRef.snapshots(),
              builder: (context, snap) {
                final Map<String, dynamic> report = snap.data?.data() ?? <String, dynamic>{};
                final rawSummary = report['summary'];
                final summary = rawSummary is Map
                    ? Map<String, dynamic>.from(rawSummary as Map)
                    : <String, dynamic>{};

                final weekNumber = (summary['weekNumber'] as num?)?.toInt()
                    ?? (report['weekNumber'] as num?)?.toInt();
                final year = (summary['year'] as num?)?.toInt()
                    ?? (report['year'] as num?)?.toInt();
                final range = (weekNumber != null && year != null)
                    ? _isoWeekRange(year, weekNumber)
                    : '';

                final title = Text(
                  weekNumber != null ? 'SCORECARD WEEK $weekNumber' : 'SCORECARD WEEK',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: _sp(26, w),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5),
                );

                final dateLbl = Text(
                  _s(range),
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: _sp(13, w)),
                );

                final controls = Wrap(
                  alignment: WrapAlignment.end,
                  spacing: _pad(12, w),
                  runSpacing: _pad(8, w),
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: w < 600 ? w : 380 * _scaleForWidth(w)),
                      child: SizedBox(
                        width: w < 600 ? double.infinity : 360 * _scaleForWidth(w),
                        child: TextField(
                          style: TextStyle(fontSize: _sp(14, w)),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search name or Transporter ID…',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: _pad(12, w),
                              vertical: _pad(12, w),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (s) => setState(() => _query = s.trim()),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: _pad(12, w)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _bucketItems.contains(_bucket) ? _bucket : 'ALL',
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                            DropdownMenuItem(value: 'FANTASTIC_PLUS', child: Text('Fantastic Plus')),
                            DropdownMenuItem(value: 'FANTASTIC', child: Text('Fantastic')),
                            DropdownMenuItem(value: 'GREAT', child: Text('Great')),
                            DropdownMenuItem(value: 'FAIR', child: Text('Fair')),
                            DropdownMenuItem(value: 'POOR', child: Text('Poor')),
                          ],
                          onChanged: (v) => setState(() => _bucket = v ?? 'ALL'),
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _busyUpload ? null : _uploadDriverCsv,
                      icon: const Icon(Icons.upload),
                      label: Text(
                        _busyUpload ? 'Uploading…' : 'Upload Driver CSV',
                        style: TextStyle(fontSize: _sp(14, w)),
                      ),
                    ),
                  ],
                );

                if (w < 880) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title, SizedBox(height: _pad(6, w)), dateLbl,
                      SizedBox(height: _pad(12, w)), controls,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, SizedBox(height: _pad(6, w)), dateLbl],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: controls),
                  ],
                );
              },
            ),

            SizedBox(height: _pad(16, w)),

            // ===== Summary cards (unchanged) =====
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: widget.reportRef.snapshots(),
              builder: (context, snap) {
                final Map<String, dynamic> report = snap.data?.data() ?? <String, dynamic>{};
                final rawSummary = report['summary'];
                final summary = rawSummary is Map
                    ? Map<String, dynamic>.from(rawSummary as Map)
                    : <String, dynamic>{};

                final overall = (summary['overallScore'] as num?)?.toDouble();
                final relNext = (summary['reliabilityNextDay'] as num?)?.toDouble();
                final relGeneric = (summary['reliabilityScore'] as num?)?.toDouble();
                final reliability = relNext ?? relGeneric;

                final rankAtStation = (summary['rankAtStation'] as num?)?.toInt();
                final stationCount  = (summary['stationCount']  as num?)?.toInt();
                final rankText = () {
                  if (rankAtStation == null) return '—';
                  var s = '$rankAtStation';
                  if (stationCount != null && stationCount > 0) s += ' of $stationCount';
                  return s;
                }();

                final stationName = _s(summary['stationCode'] ?? report['stationCode']);

                final w  = MediaQuery.of(context).size.width;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(_pad(16, w)),
                      child: LayoutBuilder(
                        builder: (context, cns) {
                          final double maxW = cns.maxWidth;
                          final int cols = maxW >= 1024 ? 3 : (maxW >= 680 ? 2 : 1);
                          final gap = _pad(16, w);
                          final childW = (maxW - gap * (cols - 1)) / cols;

                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            children: [
                              SizedBox(
                                width: childW,
                                child: _InnerSummaryPanel(
                                  w: w,
                                  title: 'TOTAL COMPANY SCORE',
                                  big: overall == null ? '—' : '${_pct.format(overall)} %',
                                  small: overall == null ? '' : _statusText(overall),
                                  accent: const Color(0xFF16A34A),
                                ),
                              ),
                              SizedBox(
                                width: childW,
                                child: _InnerSummaryPanel(
                                  w: w,
                                  title: 'RANK IN STATION',
                                  big: rankText,
                                  small: stationName,
                                  accent: Colors.black87,
                                ),
                              ),
                              SizedBox(
                                width: childW,
                                child: _InnerSummaryPanel(
                                  w: w,
                                  title: 'RELIABILITY SCORE',
                                  big: reliability == null ? '—' : '${_pct.format(reliability)} %',
                                  small: reliability == null ? '' : _statusText(reliability),
                                  accent: const Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: _pad(16, w)),

            // ===== Drivers list =====
            StreamBuilder<Map<String, String>>(
              stream: _driverNamesForWeek(),
              builder: (context, weekNamesSnap) {
                final weekNames = weekNamesSnap.data ?? const <String, String>{};

                return StreamBuilder<Map<String, String>>(
                  stream: _driversNameMapGlobal(),
                  builder: (context, globalNamesSnap) {
                    final globalNames = globalNamesSnap.data ?? const <String, String>{};

                    final nameMap = <String, String>{}
                      ..addAll(globalNames)
                      ..addAll(weekNames);

                    return StreamBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      stream: _scores(),
                      builder: (context, scoreSnap) {
                        if (scoreSnap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        var docs = scoreSnap.data ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No scores for this week.'));
                        }

                        // Filter by bucket
                        if (_bucket != 'ALL') {
                          docs = docs.where((d) {
                            final b = _s(d.data()['statusBucket']).toUpperCase();
                            return b == _bucket;
                          }).toList();
                        }

                        // Filter by search
                        final q = _query.toLowerCase();
                        if (q.isNotEmpty) {
                          docs = docs.where((d) {
                            final id = _s(d.data()['transporterId']).toLowerCase();
                            final name = _s(nameMap[_s(d.data()['transporterId'])]).toLowerCase();
                            return id.contains(q) || name.contains(q);
                          }).toList();
                        }

                        // Sort: rank if present else FinalScore desc
                        final hasAnyRank = docs.any((d) => (d.data()['rank'] != null));
                        docs.sort((a, b) {
                          if (hasAnyRank) {
                            final ra = (a.data()['rank'] as num?)?.toInt() ?? 999999;
                            final rb = (b.data()['rank'] as num?)?.toInt() ?? 999999;
                            return ra.compareTo(rb);
                          }
                          final ca = (a.data()['comp'] ?? {}) as Map<String, dynamic>;
                          final cb = (b.data()['comp'] ?? {}) as Map<String, dynamic>;
                          final fa = _numOr0(ca['FinalScore']);
                          final fb = _numOr0(cb['FinalScore']);
                          return fb.compareTo(fa);
                        });

                        if (docs.isEmpty) {
                          return const Center(child: Text('No drivers match this filter.'));
                        }

                        final maxRowWidth =
                            w >= 1400 ? 1200.0 : (w >= 1100 ? 1100.0 : w - _pad(18, w) * 2);
                        final useCompact = _isCompactRow(w);

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => SizedBox(height: _pad(12, w)),
                          itemBuilder: (context, i) {
                            try {
                              final data = docs[i].data();

                              final compRaw = (data['comp'] ?? {});
                              final kpisRaw = (data['kpis'] ?? {});
                              final comp = compRaw is Map
                                  ? Map<String, dynamic>.from(compRaw as Map)
                                  : <String, dynamic>{};
                              final kpis = kpisRaw is Map
                                  ? Map<String, dynamic>.from(kpisRaw as Map)
                                  : <String, dynamic>{};

                              final transporterId = _s(data['transporterId']).trim();
                              final name = _s(nameMap[transporterId]).isNotEmpty
                                  ? _s(nameMap[transporterId])
                                  : '(No Name)';

                              final score = _numOr0(comp['FinalScore']);
                              final dcr = _numOr0(comp['DCR_Score']);
                              final pod = _numOr0(comp['POD_Score']);
                              final cc  = _numOr0(comp['CC_Score']);
                              final ce  = _numOr0(comp['CE']);

                              final delivered = _numOr0(kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered']);
                              final dnr = _numOr0(kpis['DNR'] ?? kpis['DNR DPMO']);
                              final lor = _numOr0(kpis['LoR'] ?? kpis['LoR DPMO']);
                              final cdf = _numOr0(kpis['CDF'] ?? kpis['CDF DPMO']);

                              final rank = (data['rank'] as num?)?.toInt();
                              final apiBucketRaw = _s(data['statusBucket']);
                              final statusText = apiBucketRaw.isNotEmpty ? _prettyBucket(apiBucketRaw) : _statusText(score);
                              final statusColor = apiBucketRaw.isNotEmpty ? _colorFromApiBucket(apiBucketRaw) : _statusColor(score);

                              return Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: maxRowWidth),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28 * _scaleForWidth(w)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _pad(18, w),
                                      vertical: _pad(16, w),
                                    ),
                                    child: useCompact
                                        // ====== COMPACT ======
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          _s(name),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w800,
                                                            fontSize: _sp(16, w),
                                                          ),
                                                        ),
                                                        SizedBox(height: _pad(2, w)),
                                                        Text(
                                                          _s(transporterId),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: _sp(12, w),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        SizedBox(height: _pad(6, w)),
                                                        Container(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: _pad(10, w), vertical: _pad(6, w)),
                                                          decoration: BoxDecoration(
                                                            color: statusColor.withOpacity(0.12),
                                                            borderRadius: BorderRadius.circular(999),
                                                          ),
                                                          child: Text(
                                                            _s(statusText),
                                                            style: TextStyle(
                                                              fontSize: _sp(11, w),
                                                              fontWeight: FontWeight.w800,
                                                              color: statusColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Wrap(
                                                    spacing: _pad(10, w),
                                                    runSpacing: _pad(6, w),
                                                    children: [
                                                      _ChipStat(title: 'RANK',  value: rank != null ? '#$rank' : '—', w: w),
                                                      _ChipStat(title: 'TOTAL', value: _pctStr(score), w: w),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: _pad(14, w)),
                                              const Divider(height: 1),
                                              SizedBox(height: _pad(10, w)),
                                              LayoutBuilder(
                                                builder: (context, cns) {
                                                  final cols = _kpiCols(cns.maxWidth);
                                                  final gap = _pad(12, w);
                                                  final cellW = (cns.maxWidth - (cols - 1) * gap) / cols;
                                                  final cells = [
                                                    _KpiCell(label: 'DELIVERED', value: _intStr(delivered.round()), w: w),
                                                    _KpiCell(label: 'DCR',       value: _pctStr(dcr), w: w),
                                                    _KpiCell(label: 'DNR DPMO',  value: _intStr(dnr.round()), w: w),
                                                    _KpiCell(label: 'LoR DPMO',  value: _intStr(lor.round()), w: w),
                                                    _KpiCell(label: 'POD',       value: _pctStr(pod), w: w),
                                                    _KpiCell(label: 'CC',        value: _pctStr(cc), w: w),
                                                    _KpiCell(label: 'CE',        value: _pctStr(ce), w: w),
                                                    _KpiCell(label: 'CDF DPMO',  value: _intStr(cdf.round()), w: w),
                                                  ];
                                                  return Wrap(
                                                    spacing: gap,
                                                    runSpacing: _pad(10, w),
                                                    children: cells.map((c) => SizedBox(width: cellW, child: c)).toList(),
                                                  );
                                                },
                                              ),
                                            ],
                                          )
                                        // ====== DESKTOP ======
                                        : IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 28,
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            _s(name),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              fontSize: _sp(18, w),
                                                            ),
                                                          ),
                                                          SizedBox(height: _pad(2, w)),
                                                          Text(
                                                            _s(transporterId),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: _sp(13, w),
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          SizedBox(height: _pad(6, w)),
                                                          Text(
                                                            _s(statusText),
                                                            style: TextStyle(
                                                              fontSize: _sp(13, w),
                                                              fontWeight: FontWeight.w800,
                                                              color: statusColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'RANK', value: rank != null ? '#$rank' : '—', w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'TOTAL', value: _intStr(score), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'DELIVERED', value: _intStr(delivered.round()), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'DCR', value: _intStr(dcr), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'DNR DPMO', value: _intStr(dnr.round()), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'LoR DPMO', value: _intStr(lor.round()), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'POD', value: _intStr(pod), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'CC', value: _intStr(cc), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'CE', value: _intStr(ce), w: w),
                                                VerticalDivider(width: _pad(22, w), thickness: 1, color: Colors.black12),

                                                _MetricCol(title: 'CDF DPMO', value: _intStr(cdf.round()), w: w),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            } catch (e, st) {
                              debugPrint('Driver row render error: $e\n$st');
                              return const SizedBox.shrink();
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );

    return AppShell(
      menuWidth: 280,
      sideMenu: const AppSideMenu(
        width: 280,
        active: AppNav.drivers,
      ),
      title: shellTitle,
      actions: [csvAction],
      body: Container(
        color: const Color(0xFFF5F7F9),
        child: pageBody,
      ),
    );
  }
}

// ===== Widgets (unchanged from your version) =====

class _SummaryCard extends StatelessWidget {
  final String title;
  final String big;
  final String small;
  final Color accent;
  final double w;
  final bool centered;
  const _SummaryCard({
    required this.title,
    required this.big,
    required this.small,
    required this.accent,
    required this.w,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _pad(22, w), vertical: _pad(22, w)),
        child: Column(
          crossAxisAlignment: align,
          children: [
            Text(
              _s(title),
              textAlign: textAlign,
              style: TextStyle(
                fontSize: _sp(13, w),
                color: Colors.black54,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: _pad(10, w)),
            Text(
              _s(big),
              textAlign: textAlign,
              style: TextStyle(fontSize: _sp(30, w), fontWeight: FontWeight.w800, color: accent),
            ),
            SizedBox(height: _pad(6, w)),
            if (_s(small).isNotEmpty)
              Text(
                _s(small),
                textAlign: textAlign,
                style: TextStyle(
                  fontSize: _sp(13, w),
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String title;
  final String value;
  final double w;
  const _ChipStat({required this.title, required this.value, required this.w});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _pad(14, w), vertical: _pad(10, w)),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_s(title),
              style: TextStyle(
                fontSize: _sp(11, w),
                letterSpacing: 0.6,
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              )),
          SizedBox(height: _pad(4, w)),
          Text(
            _s(value),
            style: TextStyle(fontSize: _sp(15, w), fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _KpiCell extends StatelessWidget {
  final String label;
  final String value;
  final double w;
  const _KpiCell({required this.label, required this.value, required this.w});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_s(label),
            style: TextStyle(
                fontSize: _sp(12, w),
                color: Colors.black54,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4)),
        SizedBox(height: _pad(4, w)),
        Text(
          _s(value),
          style: TextStyle(fontSize: _sp(15, w), fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _MetricCol extends StatelessWidget {
  final String title;
  final String value;
  final double w;
  const _MetricCol({required this.title, required this.value, required this.w});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _s(title).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(12, w),
              color: Colors.black54,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: _pad(6, w)),
          Text(
            _s(value),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(20, w),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerSummaryPanel extends StatelessWidget {
  final double w;
  final String title;
  final String big;
  final String small;
  final Color accent;

  const _InnerSummaryPanel({
    required this.w,
    required this.title,
    required this.big,
    required this.small,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12.withOpacity(0.15)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _pad(22, w),
        vertical: _pad(26, w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(14, w),
              color: Colors.black45,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: _pad(14, w)),
          Text(
            big,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _sp(36, w),
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          SizedBox(height: _pad(12, w)),
          if (small.isNotEmpty)
            Text(
              small,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _sp(16, w),
                color: Colors.black54,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
        ],
      ),
    );
  }
}
