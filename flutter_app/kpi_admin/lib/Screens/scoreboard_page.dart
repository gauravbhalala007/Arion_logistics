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

  // ---------------- Data streams ----------------

  /// Stream all drivers into a cache: transporterId -> driverName
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

  /// Find most recent (year, weekNumber) with any scores.
  Future<(int year, int week)> _latestYearWeek() async {
    final snap = await FirebaseFirestore.instance
        .collection('scores')
        .orderBy('reportDate', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      final now = DateTime.now();
      final week = _isoWeekOf(now);
      return (now.year, week);
    }
    final d = snap.docs.first.data() as Map<String, dynamic>;
    return ((d['year'] ?? DateTime.now().year) as int,
        (d['weekNumber'] ?? _isoWeekOf(DateTime.now())) as int);
  }

  /// Scores stream for a specific year+week.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scoresFor(
      int year, int week) {
    return FirebaseFirestore.instance
        .collection('scores')
        .where('year', isEqualTo: year)
        .where('weekNumber', isEqualTo: week)
        .orderBy('comp.FinalScore', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }

  // ---------------- Utils ----------------

  // Accepts numbers or strings ("92,68", "92.68") and returns a double.
  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim().replaceAll('%', '');
      // Convert "92,68" → "92.68"
      return double.tryParse(s.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }

  int _isoWeekOf(DateTime d) {
    final thursday = d.add(Duration(days: (3 - ((d.weekday + 6) % 7))));
    final firstThursday =
        DateTime(thursday.year, 1, 4).add(Duration(days: (3 - ((DateTime(thursday.year, 1, 4).weekday + 6) % 7))));
    return 1 + ((thursday.difference(firstThursday).inDays) ~/ 7);
  }

  String _weekRangeText(int year, int week) {
    // Approximate Monday of ISO week:
    final jan4 = DateTime(year, 1, 4);
    final jan4Weekday = (jan4.weekday + 6) % 7; // 0..6 with Monday=0
    final mondayOfWeek1 = jan4.subtract(Duration(days: jan4Weekday));
    final monday = mondayOfWeek1.add(Duration(days: (week - 1) * 7));
    final sunday = monday.add(const Duration(days: 6));
    final df = DateFormat('dd.MM.yyyy');
    return '${df.format(monday)} – ${df.format(sunday)}';
  }

  String _statusLabel(double v) {
    if (v >= 85) return 'FANTASTIC';
    if (v >= 70) return 'GREAT';
    if (v >= 55) return 'FAIR';
    return 'POOR';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= HEADER BAR =======
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SCORECARD',
                  style: TextStyle(
                    fontSize: width < 700 ? 22 : 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'WEEK',
                  style: TextStyle(
                      fontSize: width < 700 ? 22 : 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54),
                ),
                const SizedBox(width: 6),
                const Text(
                  '…',
                  style:
                      TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  children: [
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
              ],
            ),

            const SizedBox(height: 8),

            FutureBuilder<(int, int)>(
              future: _latestYearWeek(),
              builder: (context, latestSnap) {
                final loading = latestSnap.connectionState ==
                    ConnectionState.waiting;
                final (year, week) =
                    latestSnap.data ?? (DateTime.now().year, _isoWeekOf(DateTime.now()));

                final rangeText = _weekRangeText(year, week);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rangeText,
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),

                    // ======= KPI CARDS =======
                    StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      stream: _scoresFor(year, week),
                      builder: (context, scoreSnap) {
                        final scoreDocs = scoreSnap.data ?? [];

                        // Aggregate company KPIs
                        double avgFinal = 0;
                        double avgCC = 0;
                        if (scoreDocs.isNotEmpty) {
                          for (final doc in scoreDocs) {
                            final comp = (doc['comp'] ?? {}) as Map<String, dynamic>;
                            avgFinal += _num(comp['FinalScore']);
                            avgCC += _num(comp['CC_Score']);
                          }
                          avgFinal /= scoreDocs.length;
                          avgCC /= scoreDocs.length;
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _KpiCard(
                                    title: 'TOTAL COMPANY SCORE',
                                    value: '${_pct.format(avgFinal)} %',
                                    subtitle: _statusLabel(avgFinal),
                                    accent: const Color(0xFF16A34A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: _KpiCard(
                                    title: 'RANK IN STATION',
                                    value: '4 of 7',
                                    subtitle: '-3 from WoW',
                                    accent: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _KpiCard(
                                    title: 'RELIABILITY SCORE',
                                    value: '${_pct.format(avgCC)} %',
                                    subtitle: _statusLabel(avgCC),
                                    accent: const Color(0xFF16A34A),
                                  ),
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
                            StreamBuilder<Map<String, String>>(
                              stream: _driversNameMap(),
                              builder: (context, namesSnap) {
                                final nameMap = namesSnap.data ?? {};
                                if (loading ||
                                    scoreSnap.connectionState ==
                                        ConnectionState.waiting ||
                                    namesSnap.connectionState ==
                                        ConnectionState.waiting) {
                                  return const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(),
                                  ));
                                }

                                if (scoreDocs.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Text('No scores for this week yet.'),
                                    ),
                                  );
                                }

                                return _DriverTable(
                                  scoreDocs: scoreDocs,
                                  nameMap: nameMap,
                                  numConv: _num,
                                );
                              },
                            ),
                          ],
                        );
                      },
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

/// ----- KPI Card widget -----
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black54, letterSpacing: 0.6)),
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
    );
  }
}

/// ----- DRIVER TABLE -----
class _DriverTable extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> scoreDocs;
  final Map<String, String> nameMap;
  final double Function(dynamic) numConv;

  const _DriverTable({
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

  @override
  Widget build(BuildContext context) {
    // Header row
    final headers = [
      'RANK',
      'TOTAL',
      'DELIVERED',
      'DCR',
      'DNR DPMO',
      'LoR DPMO',
      'POD',
      'CC',
      'CE',
      'CDF DPMO',
    ];

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 260, child: Text('DRIVER')),
                  for (final h in headers)
                    Expanded(
                      child: Text(
                        h,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // rows
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

                // Delivered might not exist in your data; attempt a few keys
                final deliveredRaw = kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered'];
                final delivered = numConv(deliveredRaw);

                final dnr = numConv(kpis['DNR DPMO'] ?? kpis['DNR'] ?? kpis['dnr']);
                final lor = numConv(kpis['LoR DPMO'] ?? kpis['LoR'] ?? kpis['lor']);
                final cdf = numConv(kpis['CDF DPMO'] ?? kpis['CDF'] ?? kpis['cdf']);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Driver name + ID
                      SizedBox(
                        width: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              transporterId,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // Metric cells
                      _metricCell('#${i + 1}'),
                      _metricCell(_pct.format(score)),
                      _metricCell(_int.format(delivered.round())),
                      _metricCell(_pct.format(dcr)),
                      _metricCell(_int.format(dnr.round())),
                      _metricCell(_int.format(lor.round())),
                      _metricCell(_pct.format(pod)),
                      _metricCell(_pct.format(cc)),
                      _metricCell(_pct.format(ce)),
                      _metricCell(_int.format(cdf.round())),

                      // Status pill
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(score).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusText(score),
                          style: TextStyle(
                            color: _statusColor(score),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
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

  static Widget _metricCell(String text) => Expanded(
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

  static String _statusText(double v) {
    if (v >= 85) return 'Fantastic';
    if (v >= 70) return 'Great';
    if (v >= 55) return 'Fair';
    return 'Poor';
  }
}
