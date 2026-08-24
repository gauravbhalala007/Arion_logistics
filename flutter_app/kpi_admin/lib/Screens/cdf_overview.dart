// lib/Screens/cdf_overview.dart
//
// Customer Delivery Feedback (CDF) overview — mirrors the Concessions
// architecture: weekly upload cards on top, hero stats, sort + delete,
// per-week detail with per-driver severity ranking, tap-driver → event
// sheet. Data lives at:
//
//   users/{adminUid}/reports/{reportId}.summary.cdf
//   users/{adminUid}/scores/{reportId}_{transporterId}.cdf
//
// The parser_service auto-detects CDF HTML and returns the right shape.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';
import '../services/parser_api.dart';
import '../services/report_section_remover.dart';
import '../services/report_writer.dart';
import '../widgets/admin_scope.dart';
import '../widgets/report_source_hint.dart';

class CdfOverviewPage extends StatefulWidget {
  const CdfOverviewPage({super.key});

  @override
  State<CdfOverviewPage> createState() => _CdfOverviewPageState();
}

enum _Sort { worstFirst, mostFeedback, dateDesc }

class _CdfOverviewPageState extends State<CdfOverviewPage> {
  bool _busyUpload = false;
  _Sort _sort = _Sort.worstFirst;

  // Dispatcher arbeiten im Namespace ihres Admins — currentUser.uid wäre
  // dort der falsche (leere) Namespace.
  String? get _uid =>
      AdminScope.adminUidOf(context) ?? FirebaseAuth.instance.currentUser?.uid;

  /// True when the parser actually recognised the file as a CDF report —
  /// mirrors ReportWriter's `hasCdf` check. Without this guard a file the
  /// parser didn't understand was reported as "erfolgreich hochgeladen"
  /// but never appeared in the list (report doc without summary.cdf).
  static bool _parsedLooksLikeCdf(Map<String, dynamic> parsed) {
    final summary =
        (parsed['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
    if (summary['cdfSummary'] != null) return true;
    if (summary['cdfL1Distribution'] != null) return true;
    final drivers = (parsed['drivers'] as List?) ?? const [];
    return drivers.any(
      (d) => d is Map && d.containsKey('CDF_TotalFeedback'),
    );
  }

  Future<void> _uploadCdfHtml() async {
    if (_busyUpload) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    // Scope VOR den awaits auflösen (Dispatcher → Parent-Admin-Namespace).
    final uploadScopeUid = _uid;
    setState(() => _busyUpload = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['html', 'htm'],
        withData: true,
        allowMultiple: true,
      );
      if (picked == null || picked.files.isEmpty) return;

      var ok = 0;
      final failed = <String>[];
      for (final f in picked.files) {
        final Uint8List? bytes = f.bytes;
        if (bytes == null) {
          failed.add(de
              ? '${f.name}: Datei konnte nicht gelesen werden'
              : '${f.name}: file could not be read');
          continue;
        }
        final parsed = await ParserApi.parseHtml(bytes, filename: f.name);
        if (!_parsedLooksLikeCdf(parsed)) {
          failed.add(
            de
                ? '${f.name}: kein CDF-Inhalt erkannt — bitte die originale '
                    'Amazon-CDF-HTML-Datei unverändert hochladen'
                : '${f.name}: no CDF content detected — please upload the '
                    'original Amazon CDF HTML file unchanged',
          );
          continue;
        }
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await ReportWriter.writeReportAndScores(
          parserJson: parsed,
          storagePath: 'inline/$date/${f.name}',
          adminUid: uploadScopeUid,
        );
        ok++;
      }
      if (!mounted) return;
      final msg = StringBuffer(
        de
            ? (ok == 1
                ? '1 CDF-Bericht erfolgreich hochgeladen.'
                : '$ok CDF-Berichte erfolgreich hochgeladen.')
            : (ok == 1
                ? '1 CDF report uploaded successfully.'
                : '$ok CDF reports uploaded successfully.'),
      );
      if (failed.isNotEmpty) {
        msg.write('\n✗ ${failed.join('\n✗ ')}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.toString()),
          backgroundColor: failed.isNotEmpty ? const Color(0xFFB42318) : null,
          duration: failed.isNotEmpty
              ? const Duration(seconds: 8)
              : const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Upload fehlgeschlagen: $e' : 'Upload failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyUpload = false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text('Login required.')));
    }
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _reportsStream(),
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        de
                            ? 'Berichte konnten nicht geladen werden:\n'
                                '${snap.error}'
                            : 'Reports could not be loaded:\n${snap.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFB42318)),
                      ),
                    ),
                  );
                }
                final allDocs = snap.data?.docs ?? [];
                final weeks = <_CdfWeek>[];
                for (final d in allDocs) {
                  final data = d.data();
                  final summary = (data['summary'] as Map?)
                          ?.cast<String, dynamic>() ??
                      const {};
                  final cdf =
                      (summary['cdf'] as Map?)?.cast<String, dynamic>();
                  if (cdf == null) continue;
                  weeks.add(_CdfWeek.from(d, cdf));
                }
                _sortWeeks(weeks);
                return ListView(
                  children: [
                    _hero(weeks),
                    const SizedBox(height: 18),
                    const ReportSourceHint(
                      expectedFileName:
                          'z. B. DE-AION-DBY5-Week19-CDF-report.html',
                    ),
                    _toolbar(),
                    const SizedBox(height: 12),
                    if (snap.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (weeks.isEmpty)
                      _emptyState()
                    else
                      ...weeks.map((w) => _weekCard(w)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _sortWeeks(List<_CdfWeek> list) {
    switch (_sort) {
      case _Sort.worstFirst:
        list.sort((a, b) => b.negative.compareTo(a.negative));
        break;
      case _Sort.mostFeedback:
        list.sort((a, b) => b.total.compareTo(a.total));
        break;
      case _Sort.dateDesc:
        list.sort((a, b) {
          final yc = b.year.compareTo(a.year);
          if (yc != 0) return yc;
          return b.week.compareTo(a.week);
        });
        break;
    }
  }

  // ─── Header ─────────────────────────────────────────────
  Widget _hero(List<_CdfWeek> weeks) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final totalEvents =
        weeks.fold<int>(0, (s, w) => s + w.total);
    final totalNegative =
        weeks.fold<int>(0, (s, w) => s + w.negative);
    final affectedDrivers = weeks
        .fold<int>(0, (s, w) => s + w.affectedDrivers);
    final avgPerWeek =
        weeks.isEmpty ? 0 : (totalNegative / weeks.length).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C2D12), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Delivery Feedback',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            de
                ? 'Negative Kundenrückmeldungen pro Woche und Fahrer'
                : 'Negative customer feedback per week and driver',
            style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (ctx, c) {
            final narrow = c.maxWidth < 720;
            final tiles = [
              _heroTile(
                de ? 'Negative Feedbacks' : 'Negative feedback',
                '$totalNegative',
              ),
              _heroTile(de ? 'Ø pro Woche' : 'Avg per week', '$avgPerWeek'),
              _heroTile(
                de ? 'Gesamt Feedbacks' : 'Total feedback',
                '$totalEvents',
              ),
              _heroTile(
                de ? 'Betroffene Fahrer' : 'Drivers affected',
                '$affectedDrivers',
              ),
            ];
            return narrow
                ? Wrap(spacing: 12, runSpacing: 12, children: tiles)
                : Row(
                    children: tiles
                        .expand((t) =>
                            [Expanded(child: t), const SizedBox(width: 12)])
                        .toList()
                      ..removeLast(),
                  );
          }),
        ],
      ),
    );
  }

  Widget _heroTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFEF3C7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Toolbar ────────────────────────────────────────────
  Widget _toolbar() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Row(
      children: [
        FilledButton.icon(
          onPressed: _busyUpload ? null : _uploadCdfHtml,
          icon: _busyUpload
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(_busyUpload
              ? (de ? 'Lädt…' : 'Loading…')
              : (de ? 'CDF-Report hochladen' : 'Upload CDF report')),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFB45309),
          ),
        ),
        const Spacer(),
        DropdownButton<_Sort>(
          value: _sort,
          underline: const SizedBox.shrink(),
          items: [
            DropdownMenuItem(
              value: _Sort.worstFirst,
              child: Text(de ? 'Schlechteste zuerst' : 'Worst first'),
            ),
            DropdownMenuItem(
              value: _Sort.mostFeedback,
              child: Text(de ? 'Meiste Feedbacks' : 'Most feedback'),
            ),
            DropdownMenuItem(
              value: _Sort.dateDesc,
              child: Text(de ? 'Neueste zuerst' : 'Newest first'),
            ),
          ],
          onChanged: (v) => v == null ? null : setState(() => _sort = v),
        ),
      ],
    );
  }

  // ─── Empty state ───────────────────────────────────────
  Widget _emptyState() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.feedback_outlined,
              size: 56, color: Color(0xFFB45309)),
          const SizedBox(height: 12),
          Text(
            de
                ? 'Noch keine CDF-Berichte hochgeladen'
                : 'No CDF reports uploaded yet',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Klick oben auf "CDF-Report hochladen" und wähle die HTML-Datei '
                    'aus dem Amazon-Portal.'
                : 'Click "Upload CDF report" above and choose the HTML file '
                    'from the Amazon portal.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Week card ─────────────────────────────────────────
  Widget _weekCard(_CdfWeek w) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final severity = w.negative >= 10
        ? const Color(0xFFB42318)
        : w.negative >= 3
            ? const Color(0xFFB45309)
            : const Color(0xFF067647);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openWeek(w),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: severity,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        de
                            ? 'KW ${w.week} · ${w.year}'
                            : 'Week ${w.week} · ${w.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (w.station.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            w.station,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      de
                          ? '${w.negative} negative · ${w.total} gesamt · '
                              '${w.affectedDrivers} Fahrer betroffen'
                          : '${w.negative} negative · ${w.total} total · '
                              '${w.affectedDrivers} drivers affected',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFB42318)),
                onPressed: () => _confirmDelete(w),
                tooltip: de ? 'Diese Woche löschen' : 'Delete this week',
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(_CdfWeek w) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(de
            ? 'CDF-Daten dieser Woche löschen?'
            : 'Delete this week\'s CDF data?'),
        content: Text(
          de
              ? 'Die CDF-Daten der KW ${w.week}/${w.year} (${w.negative} negative '
                  'Feedbacks) werden entfernt. Scorecard, POD Quality und '
                  'Concessions derselben Woche bleiben erhalten. Vorgang ist nicht '
                  'rückgängig zu machen.'
              : 'The CDF data for week ${w.week}/${w.year} (${w.negative} negative '
                  'feedback items) will be removed. Scorecard, POD Quality and '
                  'Concessions of the same week are kept. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: const Color(0xFFB42318)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Löschen' : 'Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      // Nur die CDF-Sektion entfernen — Scorecard/POD/Concessions derselben
      // Woche teilen sich dasselbe Report- und Score-Dokument.
      await ReportSectionRemover.removeSection(
        uid: _uid!,
        reportRef: w.ref,
        sectionKey: 'cdf',
        scoreFields: const ['cdf'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(de
              ? 'CDF-Daten der KW ${w.week}/${w.year} gelöscht.'
              : 'CDF data for week ${w.week}/${w.year} deleted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Löschen fehlgeschlagen: $e' : 'Delete failed: $e',
          ),
        ),
      );
    }
  }

  // ─── Week detail ──────────────────────────────────────
  void _openWeek(_CdfWeek w) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CdfWeekDetailPage(week: w, uid: _uid!),
      ),
    );
  }
}

// =================================================================
//   Per-week detail (driver ranking + per-event sheet)
// =================================================================

class _CdfWeekDetailPage extends StatelessWidget {
  final _CdfWeek week;
  final String uid;
  const _CdfWeekDetailPage({required this.week, required this.uid});

  Stream<QuerySnapshot<Map<String, dynamic>>> _scoresStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('reportPath', isEqualTo: week.ref.path)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: Text(de
            ? 'CDF · KW ${week.week} · ${week.year}'
            : 'CDF · Week ${week.week} · ${week.year}'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _scoresStream(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snap.data!.docs
              .map((d) => _CdfDriverEntry.from(d))
              .where((e) => e.totalFeedback > 0)
              .toList()
            ..sort((a, b) => b.negative.compareTo(a.negative));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _summaryHeader(de),
              const SizedBox(height: 16),
              ...entries.map((e) => _driverRow(context, e)),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                        de
                            ? 'Keine CDF-Datensätze für diese Woche.'
                            : 'No CDF records for this week.',
                        style: const TextStyle(color: Color(0xFF6B7280))),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryHeader(bool de) {
    final dist = week.distribution;
    final tiles = <Widget>[];
    void add(String label, num? v) {
      final n = (v ?? 0).toInt();
      if (n <= 0) return;
      tiles.add(_DistTile(label: label, value: n));
    }

    add(de ? 'Nicht erhalten' : 'Never received',
        dist['CDF_L1_NeverReceived']);
    add(de ? 'Falsch behandelt' : 'Mishandled',
        dist['CDF_L1_DriverMishandled']);
    add(de ? 'Falsche Ablage' : 'Wrong location',
        dist['CDF_L1_NotDeliveredToPreferredLocation']);
    add(de ? 'Beschädigt' : 'Damaged', dist['CDF_L1_DamagedPackage']);
    add(de ? 'Zu spät' : 'Late', dist['CDF_L1_DeliveryWasLate']);
    add(de ? 'Schlechte Erfahrung' : 'Bad experience',
        dist['CDF_L1_BadDeliveryExperience']);
    add(de ? 'Unprofessionell' : 'Unprofessional',
        dist['CDF_L1_DriverWasUnprofessional']);
    add(de ? 'Sonstige' : 'Other', dist['CDF_L1_Other']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            de ? 'Kategorien dieser Woche' : 'Categories this week',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (tiles.isEmpty)
            Text(
                de
                    ? 'Keine Kategorien zugeordnet.'
                    : 'No categories assigned.',
                style: const TextStyle(color: Color(0xFF6B7280))),
          if (tiles.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: tiles),
        ],
      ),
    );
  }

  Widget _driverRow(BuildContext context, _CdfDriverEntry e) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final severity = e.negative >= 5
        ? const Color(0xFFB42318)
        : e.negative >= 2
            ? const Color(0xFFB45309)
            : const Color(0xFF067647);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openEvents(context, e),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: severity.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${e.negative}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: severity,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.driverName.isNotEmpty
                          ? e.driverName
                          : e.transporterId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      de
                          ? '${e.negative} negative von ${e.totalFeedback} gesamt'
                              ' · ${e.events.length} Events'
                          : '${e.negative} negative of ${e.totalFeedback} total'
                              ' · ${e.events.length} events',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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
      ),
    );
  }

  void _openEvents(BuildContext context, _CdfDriverEntry e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EventSheet(entry: e),
    );
  }
}

class _DistTile extends StatelessWidget {
  final String label;
  final int value;
  const _DistTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFB45309),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventSheet extends StatelessWidget {
  final _CdfDriverEntry entry;
  const _EventSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scroll) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                entry.driverName.isNotEmpty
                    ? entry.driverName
                    : entry.transporterId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.events.length} Customer Feedback Events',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: entry.events.length,
                  itemBuilder: (_, i) => _EventCard(event: entry.events[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});

  String _humanizeLocation(String raw, bool de) {
    switch (raw.toUpperCase()) {
      case 'DELIVERED_TO_DOORSTEP':
        return de ? 'an die Haustür' : 'to the doorstep';
      case 'DELIVERED_TO_MAIL_SLOT':
        return de ? 'in den Briefkasten' : 'to the mail slot';
      case 'DELIVERED_TO_HOUSEHOLD_MEMBER':
        return de ? 'an Haushaltsmitglied' : 'to household member';
      case 'DELIVERED_TO_NEIGHBOUR':
        return de ? 'an Nachbarn' : 'to neighbour';
      case 'DELIVERED_TO_RECEPTIONIST':
        return de ? 'an Empfang' : 'to receptionist';
      case 'DELIVERED_TO_SAFE_PLACE':
        return de ? 'an sicheren Ort' : 'to safe place';
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final l1 = (event['feedbackL1'] ?? '').toString();
    final l2 = (event['feedbackL2'] ?? '').toString();
    final date = (event['feedbackDate'] ?? '').toString();
    final time = (event['deliveryTime'] ?? '').toString();
    final postal = (event['postalCode'] ?? '').toString();
    final tracking = (event['trackingId'] ?? '').toString();
    final loc = (event['phrDeliveryLocation'] ?? '').toString();
    final farScan = event['packageScannedFar'] == true;
    final dnr = event['dnrConcession'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                l1.isEmpty
                    ? (de ? '(ohne Kategorie)' : '(no category)')
                    : l1,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF7C2D12),
                ),
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ]),
          if (l2.isNotEmpty && l2.toLowerCase() != 'other')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l2,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            if (postal.isNotEmpty) _chip(postal, const Color(0xFFE5E7EB)),
            if (time.isNotEmpty)
              _chip(
                de ? 'Geliefert $time' : 'Delivered $time',
                const Color(0xFFE5E7EB),
              ),
            if (loc.isNotEmpty)
              _chip(_humanizeLocation(loc, de), const Color(0xFFDBEAFE)),
            if (farScan)
              _chip(
                de ? '> 25m Scan-Abstand' : '> 25m scan distance',
                const Color(0xFFFED7AA),
              ),
            if (dnr)
              _chip(
                de ? 'Mit DNR Concession' : 'With DNR concession',
                const Color(0xFFFECACA),
              ),
            if (tracking.isNotEmpty)
              _chip('Tracking $tracking', const Color(0xFFE5E7EB)),
          ]),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF374151),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =================================================================
//   View-models
// =================================================================

class _CdfWeek {
  final DocumentReference<Map<String, dynamic>> ref;
  final int year;
  final int week;
  final String station;
  final int total;
  final int negative;
  final int affectedDrivers;
  final Map<String, dynamic> distribution;

  _CdfWeek({
    required this.ref,
    required this.year,
    required this.week,
    required this.station,
    required this.total,
    required this.negative,
    required this.affectedDrivers,
    required this.distribution,
  });

  factory _CdfWeek.from(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> cdf,
  ) {
    final data = doc.data();
    final summary = (cdf['summary'] as Map?)?.cast<String, dynamic>() ?? {};
    final dist = (cdf['l1Distribution'] as Map?)?.cast<String, dynamic>() ?? {};
    int asInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return _CdfWeek(
      ref: doc.reference,
      year: asInt(data['year']),
      week: asInt(data['weekNumber']),
      station: (data['stationCode'] ?? '').toString(),
      total: asInt(summary['totalEvents']),
      negative: asInt(summary['totalNegative']),
      affectedDrivers: asInt(summary['totalDrivers']),
      distribution: dist,
    );
  }
}

class _CdfDriverEntry {
  final String transporterId;
  final String driverName;
  final int totalFeedback;
  final int negative;
  final List<Map<String, dynamic>> events;

  _CdfDriverEntry({
    required this.transporterId,
    required this.driverName,
    required this.totalFeedback,
    required this.negative,
    required this.events,
  });

  factory _CdfDriverEntry.from(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final cdf = (d['cdf'] as Map?)?.cast<String, dynamic>() ?? {};
    int asInt(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final rawEvents = (cdf['events'] as List?) ?? const [];
    final events = <Map<String, dynamic>>[];
    for (final e in rawEvents) {
      if (e is Map) events.add(e.cast<String, dynamic>());
    }
    return _CdfDriverEntry(
      transporterId: (d['transporterId'] ?? '').toString(),
      driverName: (d['driverName'] ?? '').toString(),
      totalFeedback: asInt(cdf['totalFeedback']),
      negative: asInt(cdf['negativeFeedback']),
      events: events,
    );
  }
}
