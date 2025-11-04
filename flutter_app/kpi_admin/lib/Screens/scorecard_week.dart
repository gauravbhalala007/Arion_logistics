import 'dart:typed_data';

import '../services/driver_csv.dart';
import 'package:file_picker/file_picker.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⬇️ for uploading CSV
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import '../main.dart' show storage;

final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

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

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores() {
    return FirebaseFirestore.instance
        .collection('scores')
        .where('reportRef', isEqualTo: widget.reportRef)
        .snapshots()
        .map((s) => s.docs);
  }

  /// NEW: Per-week names under reports/{reportId}/driverNames
  Stream<Map<String, String>> _driverNamesForWeek() {
    return widget.reportRef
        .collection('driverNames')
        .snapshots()
        .map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data() as Map<String, dynamic>;
        final id = (data['transporterId'] ?? d.id).toString();
        final name = (data['driverName'] ?? '').toString();
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  /// Global fallback (/drivers)
  Stream<Map<String, String>> _driversNameMapGlobal() {
    return FirebaseFirestore.instance.collection('drivers').snapshots().map(
      (snap) {
        final m = <String, String>{};
        for (final d in snap.docs) {
          final data = d.data();
          final id = (data['transporterId'] ?? '').toString();
          final name = (data['driverName'] ?? '').toString();
          if (id.isNotEmpty) m[id] = name;
        }
        return m;
      },
    );
  }

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim().replaceAll('%', '');
      return double.tryParse(s.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }

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

        final reportId = widget.reportRef.id;

        // Parse CSV client-side and write names + denorm into /scores
        await DriverCsvService.importForReport(
        reportId: reportId,
        csvBytes: bytes,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver names updated for this week.')),
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


  // Compute ISO week date range (Mon–Sun) for given year/week
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WEEK DETAILS',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _busyUpload ? null : _uploadDriverCsv,
                    icon: const Icon(Icons.upload),
                    label: Text(_busyUpload ? 'Uploading…' : 'Upload Driver CSV'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Summary row (from report.summary)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: widget.reportRef.snapshots(),
                builder: (context, snap) {
                  final Map<String, dynamic> report =
                      snap.data?.data() ?? <String, dynamic>{};

                  // Safe map conversion
                  final rawSummary = report['summary'];
                  final summary = rawSummary is Map
                      ? Map<String, dynamic>.from(rawSummary as Map)
                      : <String, dynamic>{};

                  final weekText = (summary['weekText'] ?? '').toString();

                  final weekNumber = (summary['weekNumber'] as num?)?.toInt() ??
                      (report['weekNumber'] as num?)?.toInt();
                  final year =
                      (summary['year'] as num?)?.toInt() ??
                          (report['year'] as num?)?.toInt();

                  final range = (weekNumber != null && year != null)
                      ? _isoWeekRange(year, weekNumber)
                      : '';

                  final overall =
                      (summary['overallScore'] as num?)?.toDouble();

                  // Both reliability metrics (plus generic fallback)
                  final relNext =
                      (summary['reliabilityNextDay'] as num?)?.toDouble();
                  final relSame =
                      (summary['reliabilitySameDay'] as num?)?.toDouble();
                  final relGeneric =
                      (summary['reliabilityScore'] as num?)?.toDouble();

                  final rankAtStation =
                      (summary['rankAtStation'] as num?)?.toInt();
                  final stationCount =
                      (summary['stationCount'] as num?)?.toInt();
                  final stationCode =
                      (summary['stationCode'] ?? report['stationCode'] ?? '')
                          .toString();

                  // Build a friendly rank even if stationCount is missing
                  final String rankValue = () {
                      if (rankAtStation == null) return '—';
                      var s = '#$rankAtStation';
                      if (stationCount != null && stationCount! > 0) {
                          s += ' of $stationCount';
                      }
                      if (stationCode.isNotEmpty) {
                          s += ' ($stationCode)';
                      }
                      return s;
                  }();


                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _KpiCard(
                        title: 'WEEK',
                        value: weekText.isEmpty
                            ? (weekNumber != null && year != null
                                ? 'Week $weekNumber - $year'
                                : '—')
                            : weekText,
                        subtitle: range,
                        accent: Colors.black87,
                        width: _cardWidthFor(MediaQuery.of(context).size.width),
                      ),
                      _KpiCard(
                        title: 'TOTAL COMPANY SCORE',
                        value: overall == null ? '—' : '${_pct.format(overall)} %',
                        subtitle: overall == null ? '' : _statusText(overall),
                        accent: const Color(0xFF16A34A),
                        width: _cardWidthFor(MediaQuery.of(context).size.width),
                      ),
                      _KpiCard(
                        title: 'RELIABILITY (NEXT-DAY)',
                        value: (relNext ?? relGeneric) == null
                            ? '—'
                            : '${_pct.format(relNext ?? relGeneric)} %',
                        subtitle: (relNext ?? relGeneric) == null
                            ? ''
                            : _statusText((relNext ?? relGeneric)!),
                        accent: const Color(0xFF0EA5E9),
                        width: _cardWidthFor(MediaQuery.of(context).size.width),
                      ),
                      _KpiCard(
                        title: 'RELIABILITY (SAME-DAY)',
                        value: relSame == null ? '—' : '${_pct.format(relSame)} %',
                        subtitle: relSame == null ? '' : _statusText(relSame),
                        accent: const Color(0xFF2563EB),
                        width: _cardWidthFor(MediaQuery.of(context).size.width),
                      ),
                      // Build a friendly rank even if stationCount is missing
                    //   String rankValue = '—';
                    //   if (rankAtStation != null) {
                    //     rankValue = '#$rankAtStation';
                    //     if (stationCount != null && stationCount > 0) {
                    //         rankValue += ' of $stationCount';
                    //     }
                    //     if (stationCode.isNotEmpty) {
                    //         rankValue += ' ($stationCode)';
                    //     }
                    //   }

                      _KpiCard(
                        title: 'RANK IN STATION',
                        value: rankValue,
                        subtitle: '',
                        accent: Colors.black87,
                        width: _cardWidthFor(MediaQuery.of(context).size.width),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Driver table with per-week names (fallback to global)
              Expanded(
                child: StreamBuilder<Map<String, String>>(
                  stream: _driverNamesForWeek(),
                  builder: (context, weekNamesSnap) {
                    final weekNames = weekNamesSnap.data ?? const <String, String>{};

                    return StreamBuilder<Map<String, String>>(
                      stream: _driversNameMapGlobal(),
                      builder: (context, globalNamesSnap) {
                        final globalNames =
                            globalNamesSnap.data ?? const <String, String>{};

                        // Merge: weekly names override global
                        final nameMap = <String, String>{}
                          ..addAll(globalNames)
                          ..addAll(weekNames);

                        return StreamBuilder<
                            List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                          stream: _scores(),
                          builder: (context, scoreSnap) {
                            if (scoreSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final scoreDocs = scoreSnap.data ?? [];
                            if (scoreDocs.isEmpty) {
                              return const Center(child: Text('No scores for this week.'));
                            }

                            // sort by rank if present, else final score desc
                            final docs = [...scoreDocs];
                            final hasAnyRank =
                                docs.any((d) => (d.data()['rank'] != null));
                            if (hasAnyRank) {
                              docs.sort((a, b) {
                                final ra =
                                    (a.data()['rank'] as num?)?.toInt() ?? 999999;
                                final rb =
                                    (b.data()['rank'] as num?)?.toInt() ?? 999999;
                                return ra.compareTo(rb);
                              });
                            } else {
                              docs.sort((a, b) {
                                final ca = (a.data()['comp'] ?? {}) as Map<String, dynamic>;
                                final cb = (b.data()['comp'] ?? {}) as Map<String, dynamic>;
                                final fa = _num(ca['FinalScore']);
                                final fb = _num(cb['FinalScore']);
                                return fb.compareTo(fa);
                              });
                            }

                            // Header row
                            final header = Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'DRIVER',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _Head('RANK'),
                                  _Head('TOTAL'),
                                  _Head('DELIVERED'),
                                  _Head('DCR'),
                                  _Head('DNR_Score'),
                                  _Head('LoR_Score'),
                                  _Head('POD'),
                                  _Head('CC'),
                                  _Head('CE'),
                                  _Head('CDF DPMO'),
                                  _Head(''),
                                ],
                              ),
                            );

                            return ListView.separated(
                              itemCount: docs.length + 1,
                              separatorBuilder: (_, i) =>
                                  i == 0 ? const Divider(height: 1) : const Divider(height: 1),
                              itemBuilder: (context, i) {
                                if (i == 0) return header;

                                final doc = docs[i - 1];
                                final data = doc.data();

                                // Safe map conversions
                                final compRaw = (data['comp'] ?? {});
                                final kpisRaw = (data['kpis'] ?? {});
                                final comp = compRaw is Map
                                    ? Map<String, dynamic>.from(compRaw as Map)
                                    : <String, dynamic>{};
                                final kpis = kpisRaw is Map
                                    ? Map<String, dynamic>.from(kpisRaw as Map)
                                    : <String, dynamic>{};

                                final transporterId =
                                    (data['transporterId'] ?? '').toString();
                                final name = (nameMap[transporterId] ?? '').isNotEmpty
                                    ? nameMap[transporterId]!
                                    : '(No Name)';

                                final score = _num(comp['FinalScore']);
                                final dcr = _num(comp['DCR_Score']);
                                final pod = _num(comp['POD_Score']);
                                final cc = _num(comp['CC_Score']);
                                final ce = _num(comp['CE_Score']);
                                final dnrScore = _num(comp['DNR_Score']);
                                final lorScore = _num(comp['LoR_Score']);

                                final delivered = _num(
                                  kpis['Delivered'] ??
                                      kpis['DELIVERED'] ??
                                      kpis['delivered'],
                                );
                                final cdf = _num(
                                  kpis['CDF DPMO'] ?? kpis['CDF'] ?? kpis['cdf'],
                                );

                                final rank = (data['rank'] as num?)?.toInt();
                                final rankDisplay =
                                    rank != null ? '#$rank' : '#$i';
                                final bucket =
                                    (data['statusBucket'] ?? '').toString();
                                final statusText =
                                    bucket.isNotEmpty ? bucket : _statusText(score);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 6),
                                  child: Row(
                                    children: [
                                      // Name + ID
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              transporterId,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      _cell(rankDisplay),
                                      _cell('${_pct.format(score)} %'),
                                      _cell(_int.format(delivered.round())),
                                      _cell('${_pct.format(dcr)} %'),
                                      _cell('${_pct.format(dnrScore)} %'),
                                      _cell('${_pct.format(lorScore)} %'),
                                      _cell('${_pct.format(pod)} %'),
                                      _cell('${_pct.format(cc)} %'),
                                      _cell('${_pct.format(ce)} %'),
                                      _cell(_int.format(cdf.round())),

                                      // status pill
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: _statusColor(score)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              statusText,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: _statusColor(score),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
            ],
          ),
        ),
      ),
    );
  }

  // FIXED: this now returns a cell with the provided text (not a constant)
  Widget _cell(String text) => Expanded(
        child: Center(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );

  double _cardWidthFor(double maxWidth) {
    if (maxWidth >= 1200) return (maxWidth - 18 * 2 - 12 * 2) / 3;
    if (maxWidth >= 900) return (maxWidth - 18 * 2 - 12) / 2;
    return maxWidth - 18 * 2;
  }
}

class _Head extends StatelessWidget {
  final String text;
  const _Head(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Center(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.width,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54, letterSpacing: 0.6)),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 6),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
