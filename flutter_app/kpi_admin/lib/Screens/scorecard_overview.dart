import 'dart:typed_data';

import '../services/parser_api.dart';
import '../services/report_writer.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⬇️ for uploading PDFs
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import '../main.dart' show storage;
import 'dart:convert';
import 'package:http/http.dart' as http;


import 'scorecard_week.dart';

/// Simple German-style number formatting
final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

class ScorecardOverviewPage extends StatefulWidget {
  const ScorecardOverviewPage({super.key});

  @override
  State<ScorecardOverviewPage> createState() => _ScorecardOverviewPageState();
}

class _ScorecardOverviewPageState extends State<ScorecardOverviewPage> {
  bool _busyUpload = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream() {
    return FirebaseFirestore.instance
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .limit(26)
        .snapshots();
  }

  Future<void> _uploadWeeklyPdf() async {
    if (_busyUpload) return;
    setState(() => _busyUpload = true);
    try {
        final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        );
        if (picked == null || picked.files.isEmpty) {
        setState(() => _busyUpload = false);
        return;
        }
        final f = picked.files.single;
        final bytes = f.bytes;
        if (bytes == null) throw Exception('No file bytes');

        // 1) Upload to Storage (optional but good for audit)
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final path = 'uploads/reports/$date/${f.name}';
        final meta = fb.SettableMetadata(contentType: 'application/pdf');
        await storage.ref(path).putData(bytes, meta);

        // 2) Parse on Render
        final parsed = await ParserApi.parsePdf(bytes, filename: f.name);

        // 3) Write to Firestore (reports + scores with deterministic IDs)
        await ReportWriter.writeReportAndScores(
        parserJson: parsed,
        storagePath: path,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parsed & saved. Dashboard updated.')),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold( // <-- ensure Scaffold exists for SnackBars
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Upload PDF button
              Row(
                children: [
                  Text('SCORE CARD DASHBOARD',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          )),
                  const SizedBox(width: 10),
                  const Text('— Overview',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      )),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _busyUpload ? null : _uploadWeeklyPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(_busyUpload ? 'Uploading…' : 'Upload Weekly PDF'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Multi-week chart + list
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _reportsStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No reports yet.'));
                    }

                    // Build points (chronological left->right)
                    final points = docs
                        .map((d) {
                          final m = d.data();
                          final rawSummary = m['summary'];
                          final s = rawSummary is Map
                              ? Map<String, dynamic>.from(rawSummary as Map)
                              : <String, dynamic>{};
                          final score =
                              (s['overallScore'] as num?)?.toDouble() ?? 0;
                          final w = (m['weekNumber'] as num?)?.toInt();
                          final y = (m['year'] as num?)?.toInt();
                          final label = (s['weekText'] ??
                                  (w != null && y != null ? 'W$w/$y' : '—'))
                              .toString();
                          return _ChartPoint(
                            xLabel: label,
                            y: score,
                            ref: d.reference,
                            summary: s,
                          );
                        })
                        .toList()
                        .reversed
                        .toList();

                    return LayoutBuilder(
                      builder: (context, c) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mini chart (left)
                            Expanded(
                              flex: 3,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Score Card Overview',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          )),
                                      const SizedBox(height: 12),
                                      _MiniBarChart(points: points),
                                      const SizedBox(height: 8),
                                      const Text('Tap a bar or pick from the list →',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Weekly list (right)
                            Expanded(
                              flex: 2,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: points.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) {
                                    final p = points.reversed.toList()[i]; // newest first
                                    final overall = p.y;
                                    final rel = (p.summary['reliabilityScore'] ??
                                            p.summary['reliabilityNextDay'])
                                        as num?;
                                    return ListTile(
                                      title: Text(p.xLabel,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      subtitle: Text(
                                        'Overall: ${_pct.format(overall)} %'
                                        '${rel != null ? ' • Reliability: ${_pct.format(rel)} %' : ''}',
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ScorecardWeekPage(
                                            reportRef: p.ref,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
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
}

class _ChartPoint {
  final String xLabel;
  final double y;
  final DocumentReference<Map<String, dynamic>> ref; // typed
  final Map<String, dynamic> summary;
  _ChartPoint({
    required this.xLabel,
    required this.y,
    required this.ref,
    required this.summary,
  });
}

/// Very small dependency-free bar chart.
/// Tap a bar to open that week.
class _MiniBarChart extends StatelessWidget {
  final List<_ChartPoint> points;
  const _MiniBarChart({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxY = (points.map((e) => e.y).fold<double>(0, (a, b) => a > b ? a : b))
        .clamp(1, 100);
    return SizedBox(
      height: 220,
      child: LayoutBuilder(
        builder: (context, c) {
          final barW = (c.maxWidth / (points.length * 1.4)).clamp(6, 24);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final p in points)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ScorecardWeekPage(reportRef: p.ref),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (p.y / maxY) * 160,
                          width: barW.toDouble(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.green.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.xLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
