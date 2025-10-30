// lib/screens/scoreboard_page.dart
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

import '../main.dart' show storage;

/// Formatting helpers (German-like decimals to match mockups)
final _pct = NumberFormat.decimalPattern('de'); // 84,56
final _int = NumberFormat.decimalPattern('de'); // 1.245 etc.

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  String? _uploadMsg;
  bool _busyUpload = false;

  // ---------------- Upload helpers (CSV / PDF on the same page) ----------------
  Future<void> _uploadFile({required bool isCsv}) async {
    setState(() {
      _busyUpload = true;
      _uploadMsg = null;
    });

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: isCsv ? ['csv'] : ['pdf'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) {
        setState(() {
          _uploadMsg = 'Upload cancelled.';
          _busyUpload = false;
        });
        return;
      }

      final file = res.files.single;
      final Uint8List? bytes = file.bytes;
      if (bytes == null) throw Exception('No bytes in picked file');

      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final path = isCsv
          ? 'uploads/drivers/$date/${file.name}'
          : 'uploads/reports/$date/${file.name}';
      final meta = fb.SettableMetadata(
        contentType: isCsv ? 'text/csv' : 'application/pdf',
      );

      final task = await storage.ref(path).putData(bytes, meta);
      final m = await task.ref.getMetadata();
      final kb = ((m.size ?? 0) / 1024).toStringAsFixed(1);

      setState(() {
        _uploadMsg =
            '${isCsv ? "CSV" : "PDF"} uploaded: ${m.fullPath} ($kb KB). Functions will process shortly.';
        _busyUpload = false;
      });
    } catch (e) {
      setState(() {
        _uploadMsg = 'Upload failed: $e';
        _busyUpload = false;
      });
    }
  }

  // ---------------- Data helpers ----------------

  /// Latest report (with summary) stream
  Stream<QueryDocumentSnapshot<Map<String, dynamic>>?> _latestReport() {
    return FirebaseFirestore.instance
        .collection('reports')
        .orderBy('reportDate', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first);
  }

  /// Scores for given report doc ref (sorting done client-side)
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresForReport(
      DocumentReference reportRef) {
    return FirebaseFirestore.instance
        .collection('scores')
        .where('reportRef', isEqualTo: reportRef)
        .snapshots()
        .map((s) => s.docs);
  }

  /// Map transporterId -> driverName
  Stream<Map<String, String>> _driversNameMap() {
    return FirebaseFirestore.instance.collection('drivers').snapshots().map(
      (snap) {
        final m = <String, String>{};
        for (final d in snap.docs) {
          final data = d.data() as Map<String, dynamic>;
          final id = (data['transporterId'] ?? '').toString();
          final name = (data['driverName'] ?? '').toString();
          if (id.isNotEmpty) m[id] = name;
        }
        return m;
      },
    );
  }

  // ---------------- Utils ----------------

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim().replaceAll('%', '');
      return double.tryParse(s.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }

  String _statusLabel(double v) {
    if (v >= 85) return 'FANTASTIC';
    if (v >= 70) return 'GREAT';
    if (v >= 55) return 'FAIR';
    return 'POOR';
  }

  String _weekRangeFromReport(Map<String, dynamic> report) {
    final summary = (report['summary'] ?? {}) as Map<String, dynamic>;
    final weekText = (summary['weekText'] ?? '').toString();
    if (weekText.isNotEmpty) return weekText;

    final ts = report['reportDate'];
    DateTime? d;
    if (ts is Timestamp) d = ts.toDate();
    d ??= DateTime.now();
    final df = DateFormat('dd.MM.yyyy');
    return df.format(d);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 980;
          final headerTitleSize = isNarrow ? 22.0 : 34.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======= HEADER BAR =======
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    Text(
                      'SCORECARD',
                      style: TextStyle(
                        fontSize: headerTitleSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'WEEK',
                      style: TextStyle(
                        fontSize: headerTitleSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                      ),
                    ),
                    const Text('…',
                        style: TextStyle(
                            fontSize: 34, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 14),
                    FilledButton.icon(
                      onPressed:
                          _busyUpload ? null : () => _uploadFile(isCsv: true),
                      icon: const Icon(Icons.upload),
                      label: const Text('UPLOAD DRIVER CSV'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed:
                          _busyUpload ? null : () => _uploadFile(isCsv: false),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('UPLOAD WEEKLY PDF'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ======= LATEST REPORT =======
                StreamBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
                  stream: _latestReport(),
                  builder: (context, repSnap) {
                    final reportDoc = repSnap.data;
                    if (repSnap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (reportDoc == null) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No report uploaded yet.'),
                      );
                    }

                    final report = reportDoc.data();
                    final summary =
                        (report['summary'] ?? {}) as Map<String, dynamic>;

                    final overall = (summary['overallScore'] as num?)?.toDouble();
                    final reliability =
                        (summary['reliabilityScore'] as num?)?.toDouble();
                    final rankAtStation =
                        (summary['rankAtStation'] as num?)?.toInt();
                    final stationCount =
                        (summary['stationCount'] as num?)?.toInt();
                    final rankDeltaWoW =
                        (summary['rankDeltaWoW'] as num?)?.toInt();
                    final weekText = _weekRangeFromReport(report);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekText,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 14),

                        // ======= KPI CARDS (responsive Wrap) =======
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _KpiCard(
                              title: 'TOTAL COMPANY SCORE',
                              value: overall == null
                                  ? '—'
                                  : '${_pct.format(overall)} %',
                              subtitle: overall == null
                                  ? ''
                                  : _statusLabel(overall),
                              accent: const Color(0xFF16A34A),
                              width: _cardWidthFor(constraints.maxWidth),
                            ),
                            _KpiCard(
                              title: 'RANK IN STATION',
                              value: (rankAtStation == null ||
                                      stationCount == null)
                                  ? '—'
                                  : '${rankAtStation} of $stationCount',
                              subtitle: (rankDeltaWoW == null ||
                                      rankDeltaWoW == 0)
                                  ? 'WoW unchanged'
                                  : (rankDeltaWoW! > 0
                                      ? '+$rankDeltaWoW from WoW'
                                      : '$rankDeltaWoW from WoW'),
                              accent: Colors.black87,
                              width: _cardWidthFor(constraints.maxWidth),
                            ),
                            _KpiCard(
                              title: 'RELIABILITY SCORE',
                              value: reliability == null
                                  ? '—'
                                  : '${_pct.format(reliability)} %',
                              subtitle: reliability == null
                                  ? ''
                                  : _statusLabel(reliability),
                              accent: const Color(0xFF16A34A),
                              width: _cardWidthFor(constraints.maxWidth),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        if (_uploadMsg != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _uploadMsg!,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          ),

                        // ======= DRIVER TABLE =======
                        StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                          stream: _scoresForReport(reportDoc.reference),
                          builder: (context, scoreSnap) {
                            if (scoreSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final scoreDocs = scoreSnap.data ?? [];

                            if (scoreDocs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text('No scores for this report yet.'),
                                ),
                              );
                            }

                            return StreamBuilder<Map<String, String>>(
                              stream: _driversNameMap(),
                              builder: (context, namesSnap) {
                                final nameMap = namesSnap.data ?? {};
                                if (namesSnap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                // Sort: rank asc if present, else FinalScore desc
                                final docs = [...scoreDocs];
                                final hasAnyRank =
                                    docs.any((d) => (d.data()['rank'] != null));
                                if (hasAnyRank) {
                                  docs.sort((a, b) {
                                    final ra =
                                        (a.data()['rank'] as num?)?.toInt() ??
                                            999999;
                                    final rb =
                                        (b.data()['rank'] as num?)?.toInt() ??
                                            999999;
                                    return ra.compareTo(rb);
                                  });
                                } else {
                                  docs.sort((a, b) {
                                    final ca = (a.data()['comp'] ?? {})
                                        as Map<String, dynamic>;
                                    final cb = (b.data()['comp'] ?? {})
                                        as Map<String, dynamic>;
                                    final fa = _num(ca['FinalScore']);
                                    final fb = _num(cb['FinalScore']);
                                    return fb.compareTo(fa);
                                  });
                                }

                                // === Horizontal scroll + explicit table width (NO Expanded) ===
                                // 
                                return _DriverTableResponsive(
                                    scoreDocs: docs,
                                    nameMap: nameMap,
                                    numConv: _num,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _cardWidthFor(double maxWidth) {
    if (maxWidth >= 1200) return (maxWidth - 18 * 2 - 12 * 2) / 3;
    if (maxWidth >= 900) return (maxWidth - 18 * 2 - 12) / 2;
    return maxWidth - 18 * 2;
  }
}

/// ----- KPI Card widget -----
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final double width;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.width,
  });

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

// /// ----- DRIVER TABLE (fixed widths, no Expanded) -----
// class _DriverTableFixed extends StatelessWidget {
//   final List<QueryDocumentSnapshot<Map<String, dynamic>>> scoreDocs;
//   final Map<String, String> nameMap;
//   final double Function(dynamic) numConv;
//   final double nameColW;
//   final double colW;
//   final double statusW;

//   const _DriverTableFixed({
//     required this.scoreDocs,
//     required this.nameMap,
//     required this.numConv,
//     required this.nameColW,
//     required this.colW,
//     required this.statusW,
//   });

//   Color _statusColor(double v) {
//     if (v >= 85) return const Color(0xFF16A34A);
//     if (v >= 70) return const Color(0xFF22C55E);
//     if (v >= 55) return const Color(0xFFF59E0B);
//     return const Color(0xFFEF4444);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Header row
//     final headers = [
//       'RANK',
//       'TOTAL',
//       'DELIVERED',
//       'DCR',
//       'DNR_Score',
//       'LoR_Score',
//       'POD',
//       'CC',
//       'CE',
//       'CDF DPMO',
//     ];

//     return Card(
//       clipBehavior: Clip.hardEdge,
//       elevation: 0.5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Column(
//           children: [
//             // header
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: nameColW,
//                     child: const Text(
//                       'DRIVER',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.black54,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                   for (final h in headers)
//                     SizedBox(
//                       width: colW,
//                       child: Text(
//                         h,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black54,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   SizedBox(width: statusW), // status pill col (no header)
//                 ],
//               ),
//             ),
//             const Divider(height: 1),

//             // rows
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: scoreDocs.length,
//               separatorBuilder: (_, __) => const Divider(height: 1),
//               itemBuilder: (context, i) {
//                 final doc = scoreDocs[i];
//                 final data = doc.data();
//                 final comp =
//                     (data['comp'] ?? <String, dynamic>{}) as Map<String, dynamic>;
//                 final kpis =
//                     (data['kpis'] ?? <String, dynamic>{}) as Map<String, dynamic>;

//                 final transporterId = (data['transporterId'] ?? '').toString();
//                 final name = (nameMap[transporterId] ?? '').isNotEmpty
//                     ? nameMap[transporterId]!
//                     : '(No Name)';

//                 final score = numConv(comp['FinalScore']);
//                 final dcr = numConv(comp['DCR_Score']);
//                 final pod = numConv(comp['POD_Score']);
//                 final cc = numConv(comp['CC_Score']);
//                 final ce = numConv(comp['CE_Score']);

//                 final deliveredRaw =
//                     kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered'];
//                 final delivered = numConv(deliveredRaw);

//                 final dnr =
//                     numConv(comp['DNR_Score']);
//                 final lorScore = numConv(comp['LoR_Score']);
//                 final cdf =
//                     numConv(kpis['CDF DPMO'] ?? kpis['CDF'] ?? kpis['cdf']);

//                 final rank = (data['rank'] as num?)?.toInt();
//                 final rankDisplay = rank != null ? '#$rank' : '#${i + 1}';

//                 final statusBucket = (data['statusBucket'] ?? '').toString();
//                 final statusText = statusBucket.isNotEmpty
//                     ? statusBucket
//                     : _statusText(score);

//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // Driver name + ID (fixed width)
//                       SizedBox(
//                         width: nameColW,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(name,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.w700, fontSize: 15)),
//                             const SizedBox(height: 2),
//                             Text(
//                               transporterId,
//                               style: const TextStyle(
//                                   color: Colors.black54, fontSize: 12),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Metric cells (fixed width)
//                       _metricCell(rankDisplay, colW),
//                       _metricCell(_pct.format(score), colW),
//                       _metricCell(_int.format(delivered.round()), colW),
//                       _metricCell(_pct.format(dcr), colW),
//                       _metricCell(_int.format(dnr.round()), colW),
//                       _metricCell(_pct.format(lorScore), colW),
//                       _metricCell(_pct.format(pod), colW),
//                       _metricCell(_pct.format(cc), colW),
//                       _metricCell(_pct.format(ce), colW),
//                       _metricCell(_int.format(cdf.round()), colW),

//                       // Status pill (fixed width cell)
//                       SizedBox(
//                         width: statusW,
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: _statusColor(score).withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(999),
//                             ),
//                             child: Text(
//                               statusText,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 color: _statusColor(score),
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _metricCell(String text, double width) => SizedBox(
//         width: width,
//         child: Center(
//           child: Text(
//             text,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       );

//   static String _statusText(double v) {
//     if (v >= 85) return 'Fantastic';
//     if (v >= 70) return 'Great';
//     if (v >= 55) return 'Fair';
//     return 'Poor';
//   }
// }
/// ----- DRIVER TABLE (responsive, no horizontal scroll) -----
class _DriverTableResponsive extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> scoreDocs;
  final Map<String, String> nameMap;
  final double Function(dynamic) numConv;

  const _DriverTableResponsive({
    required this.scoreDocs,
    required this.nameMap,
    required this.numConv,
  });

  Color _statusColor(double v) {
    if (v >= 85) return const Color(0xFF16A34A);
    if (v >= 70) return const Color(0xFF22C55E);
    if (v >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  static String _statusText(double v) {
    if (v >= 85) return 'Fantastic';
    if (v >= 70) return 'Great';
    if (v >= 55) return 'Fair';
    return 'Poor';
  }

  Widget _headCell(String text, {int flex = 1}) => Expanded(
        flex: flex,
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _cell(String text, {int flex = 1}) => Expanded(
        flex: flex,
        child: Center(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Column order kept same as your current UI (but no horizontal scroll).
    // We give the DRIVER column a larger flex so the row fits.
    // All other metric columns share equal flex to fit the width.
    const nameFlex = 3; // wider for name+ID
    const colFlex = 2;  // metrics
    const statusFlex = 2;

    final headers = const [
      'RANK',
      'TOTAL',
      'DELIVERED',
      'DCR',
      'DNR_Score',
      'LoR_Score',
      'POD',
      'CC',
      'CE',
      'CDF DPMO',
    ];

    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  // DRIVER header
                  Expanded(
                    flex: nameFlex,
                    child: const Text(
                      'DRIVER',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (final h in headers) _headCell(h, flex: colFlex),
                  _headCell('', flex: statusFlex), // status col, no title
                ],
              ),
            ),
            const Divider(height: 1),

            // Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scoreDocs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final doc = scoreDocs[i];
                final data = doc.data();
                final comp =
                    (data['comp'] ?? <String, dynamic>{}) as Map<String, dynamic>;
                final kpis =
                    (data['kpis'] ?? <String, dynamic>{}) as Map<String, dynamic>;

                final transporterId = (data['transporterId'] ?? '').toString();
                final name = (nameMap[transporterId] ?? '').isNotEmpty
                    ? nameMap[transporterId]!
                    : '(No Name)';

                final score = numConv(comp['FinalScore']);
                final dcr = numConv(comp['DCR_Score']);
                final pod = numConv(comp['POD_Score']);
                final cc = numConv(comp['CC_Score']);
                final ce = numConv(comp['CE_Score']);

                final deliveredRaw =
                    kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered'];
                final delivered = numConv(deliveredRaw);

                final dnr = numConv(comp['DNR_Score']);
                final lorScore = numConv(comp['LoR_Score']);
                final cdf = numConv(kpis['CDF DPMO'] ?? kpis['CDF'] ?? kpis['cdf']);

                final rank = (data['rank'] as num?)?.toInt();
                final rankDisplay = rank != null ? '#$rank' : '#${i + 1}';

                final statusBucket = (data['statusBucket'] ?? '').toString();
                final statusText =
                    statusBucket.isNotEmpty ? statusBucket : _statusText(score);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // DRIVER (name + ID)
                      Expanded(
                        flex: nameFlex,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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

                      // Metrics
                      _cell(rankDisplay, flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(score), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(delivered.round()), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(dcr), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(dnr), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(lorScore), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(pod), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(cc), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(ce), flex: colFlex),
                      _cell(NumberFormat.decimalPattern('de').format(cdf.round()), flex: colFlex),

                      // Status
                      Expanded(
                        flex: statusFlex,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(score).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
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
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
