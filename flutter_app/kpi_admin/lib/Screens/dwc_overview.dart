// lib/Screens/dwc_overview.dart
//
// DWC / IADC overview — mirrors the CDF / Concessions architecture:
// weekly upload cards on top, hero stats, sort + delete, per-week detail
// with per-driver DWC% / IADC% ranking. Data lives at:
//
//   users/{adminUid}/reports/{reportId}.summary.dwc
//   users/{adminUid}/scores/{reportId}_{transporterId}.dwc
//
// The parser_service auto-detects the "DWC/IADC" HTML report and returns
// per-driver { DWC_DwcPct, DWC_IadcPct } keyed by Transporter ID.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/parser_api.dart';
import '../services/report_section_remover.dart';
import '../services/report_writer.dart';
import '../widgets/report_source_hint.dart';

// Theme accents (blue — distinct from CDF's amber).
const _kAccent = Color(0xFF2563EB);
const _kAccentDeep = Color(0xFF1E3A8A);

/// "xx.x%" or "—" for a nullable percentage.
String _fmtPct(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)}%';

/// Colour for an IADC value (the workflow-compliance metric, usually low).
Color _iadcColor(double? v) {
  if (v == null) return const Color(0xFF9CA3AF);
  if (v >= 85) return const Color(0xFF067647);
  if (v >= 70) return const Color(0xFFB45309);
  return const Color(0xFFB42318);
}

/// Colour for a DWC value (delivery-without-complaints, usually high).
Color _dwcColor(double? v) {
  if (v == null) return const Color(0xFF9CA3AF);
  if (v >= 98) return const Color(0xFF067647);
  if (v >= 95) return const Color(0xFFB45309);
  return const Color(0xFFB42318);
}

class DwcOverviewPage extends StatefulWidget {
  const DwcOverviewPage({super.key});

  @override
  State<DwcOverviewPage> createState() => _DwcOverviewPageState();
}

enum _Sort { worstIadc, worstDwc, dateDesc }

class _DwcOverviewPageState extends State<DwcOverviewPage> {
  bool _busyUpload = false;
  _Sort _sort = _Sort.dateDesc;
  // When set, the week-detail view is shown inline (inside the admin shell,
  // so the sidebar stays) instead of pushing a full-screen route.
  _DwcWeek? _selectedWeek;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _uploadDwcHtml() async {
    if (_busyUpload) return;
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
      for (final f in picked.files) {
        final Uint8List? bytes = f.bytes;
        if (bytes == null) continue;
        final parsed = await ParserApi.parseHtml(bytes, filename: f.name);
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await ReportWriter.writeReportAndScores(
          parserJson: parsed,
          storagePath: 'inline/$date/${f.name}',
        );
        ok++;
      }
      if (!mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de
                ? (ok == 1
                    ? '1 DWC/IADC-Bericht erfolgreich hochgeladen.'
                    : '$ok DWC/IADC-Berichte erfolgreich hochgeladen.')
                : (ok == 1
                    ? '1 DWC/IADC report uploaded successfully.'
                    : '$ok DWC/IADC reports uploaded successfully.'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                de ? 'Upload fehlgeschlagen: $e' : 'Upload failed: $e')),
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
    // Inline week detail — keeps the admin sidebar visible.
    if (_selectedWeek != null) {
      return _DwcWeekDetailPage(
        week: _selectedWeek!,
        uid: _uid!,
        onBack: () => setState(() => _selectedWeek = null),
      );
    }
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
                final allDocs = snap.data?.docs ?? [];
                final weeks = <_DwcWeek>[];
                for (final d in allDocs) {
                  final data = d.data();
                  final summary = (data['summary'] as Map?)
                          ?.cast<String, dynamic>() ??
                      const {};
                  final dwc =
                      (summary['dwc'] as Map?)?.cast<String, dynamic>();
                  if (dwc == null) continue;
                  weeks.add(_DwcWeek.from(d, dwc));
                }
                _sortWeeks(weeks);
                return ListView(
                  children: [
                    _hero(weeks),
                    const SizedBox(height: 18),
                    const ReportSourceHint(
                      expectedFileName:
                          'z. B. DE-AION-DBY5-DWC-IADC-Report_2026-26.html',
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

  void _sortWeeks(List<_DwcWeek> list) {
    int byDate(_DwcWeek a, _DwcWeek b) {
      final yc = b.year.compareTo(a.year);
      if (yc != 0) return yc;
      return b.week.compareTo(a.week);
    }

    switch (_sort) {
      case _Sort.worstIadc:
        list.sort((a, b) => (a.iadcPct ?? 999).compareTo(b.iadcPct ?? 999));
        break;
      case _Sort.worstDwc:
        list.sort((a, b) => (a.dwcPct ?? 999).compareTo(b.dwcPct ?? 999));
        break;
      case _Sort.dateDesc:
        list.sort(byDate);
        break;
    }
  }

  // ─── Header ─────────────────────────────────────────────
  Widget _hero(List<_DwcWeek> weeks) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    double? avg(Iterable<double?> xs) {
      final vals = xs.whereType<double>().toList();
      if (vals.isEmpty) return null;
      return vals.reduce((a, b) => a + b) / vals.length;
    }

    final latest = ([...weeks]..sort((a, b) {
          final yc = b.year.compareTo(a.year);
          return yc != 0 ? yc : b.week.compareTo(a.week);
        }))
        .cast<_DwcWeek?>()
        .firstWhere((_) => true, orElse: () => null);
    final avgDwc = avg(weeks.map((w) => w.dwcPct));
    final avgIadc = avg(weeks.map((w) => w.iadcPct));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_kAccentDeep, _kAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DWC / IADC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Delivery Without Complaints & In-App Delivery Confirmation',
            style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
          ),
          const SizedBox(height: 14),
          _kpiExplainer(
            'DWC %',
            de
                ? 'Zustellungen ohne Kundenbeschwerde (kein „nicht erhalten", '
                    'kein Schaden). Hoch = gut, Ziel ~98 %+.'
                : 'Deliveries without customer complaints (no "not received", '
                    'no damage). Higher is better, target ~98%+.',
          ),
          const SizedBox(height: 8),
          _kpiExplainer(
            'IADC %',
            de
                ? 'Korrekte Zustellbestätigung in der App (Foto, richtige '
                    'Ablage, Scan am Zustellort). Hoch = gut.'
                : 'Correct delivery confirmation in the app (photo, correct '
                    'drop-off location, scan at the delivery point). Higher '
                    'is better.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (ctx, c) {
            final narrow = c.maxWidth < 720;
            final tiles = [
              _heroTile('Ø DWC %', _fmtPct(avgDwc)),
              _heroTile('Ø IADC %', _fmtPct(avgIadc)),
              _heroTile(de ? 'Wochen' : 'Weeks', '${weeks.length}'),
              _heroTile(de ? 'Fahrer (aktuell)' : 'Drivers (current)',
                  '${latest?.totalDrivers ?? 0}'),
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
              color: Color(0xFFDBEAFE),
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

  /// One-line "KPI — what it means" explainer, styled for the hero gradient.
  Widget _kpiExplainer(String kpi, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            kpi,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE0ECFF),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Toolbar ────────────────────────────────────────────
  Widget _toolbar() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Row(
      children: [
        FilledButton.icon(
          onPressed: _busyUpload ? null : _uploadDwcHtml,
          icon: _busyUpload
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(_busyUpload
              ? (de ? 'Lädt…' : 'Loading…')
              : (de ? 'DWC/IADC-Report hochladen' : 'Upload DWC/IADC report')),
          style: FilledButton.styleFrom(backgroundColor: _kAccent),
        ),
        const Spacer(),
        DropdownButton<_Sort>(
          value: _sort,
          underline: const SizedBox.shrink(),
          items: [
            DropdownMenuItem(
              value: _Sort.dateDesc,
              child: Text(de ? 'Neueste zuerst' : 'Newest first'),
            ),
            DropdownMenuItem(
              value: _Sort.worstIadc,
              child: Text(de ? 'Schlechteste IADC' : 'Worst IADC'),
            ),
            DropdownMenuItem(
              value: _Sort.worstDwc,
              child: Text(de ? 'Schlechteste DWC' : 'Worst DWC'),
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
          const Icon(Icons.verified_user_outlined,
              size: 56, color: _kAccent),
          const SizedBox(height: 12),
          Text(
            de
                ? 'Noch keine DWC/IADC-Berichte hochgeladen'
                : 'No DWC/IADC reports uploaded yet',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Klick oben auf "DWC/IADC-Report hochladen" und wähle die '
                    'HTML-Datei aus dem Amazon-Portal.'
                : 'Click "Upload DWC/IADC report" above and pick the HTML '
                    'file from the Amazon portal.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Week card ─────────────────────────────────────────
  Widget _weekCard(_DwcWeek w) {
    final de = Localizations.localeOf(context).languageCode == 'de';
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
                  color: _iadcColor(w.iadcPct),
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
                        '${de ? 'KW' : 'CW'} ${w.week} · ${w.year}',
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
                    const SizedBox(height: 6),
                    Row(children: [
                      _pctPill('DWC', w.dwcPct, _dwcColor(w.dwcPct)),
                      const SizedBox(width: 8),
                      _pctPill('IADC', w.iadcPct, _iadcColor(w.iadcPct)),
                      const SizedBox(width: 8),
                      Text(
                        de
                            ? '${w.totalDrivers} Fahrer'
                            : '${w.totalDrivers} drivers',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ]),
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

  static Widget _pctPill(String label, double? v, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label ${_fmtPct(v)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(_DwcWeek w) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final de = Localizations.localeOf(ctx).languageCode == 'de';
        return AlertDialog(
          title: Text(de
              ? 'DWC-Daten dieser Woche löschen?'
              : 'Delete DWC data for this week?'),
          content: Text(
            de
                ? 'Die DWC/IADC-Daten der KW ${w.week}/${w.year} werden '
                    'entfernt. Scorecard, POD Quality und Concessions '
                    'derselben Woche bleiben erhalten. Vorgang ist nicht '
                    'rückgängig zu machen.'
                : 'The DWC/IADC data for CW ${w.week}/${w.year} will be '
                    'removed. Scorecard, POD Quality and Concessions of the '
                    'same week are kept. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(de ? 'Abbrechen' : 'Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB42318)),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(de ? 'Löschen' : 'Delete'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;

    try {
      // Nur die DWC-Sektion entfernen — alle Features teilen sich pro
      // Woche dasselbe Report- und Score-Dokument.
      await ReportSectionRemover.removeSection(
        uid: _uid!,
        reportRef: w.ref,
        sectionKey: 'dwc',
        scoreFields: const ['dwc'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DWC-Daten der KW ${w.week}/${w.year} gelöscht.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Löschen fehlgeschlagen: $e')),
      );
    }
  }

  // ─── Week detail ──────────────────────────────────────
  void _openWeek(_DwcWeek w) {
    setState(() => _selectedWeek = w);
  }
}

// =================================================================
//   Per-week detail (per-driver DWC% / IADC% ranking)
// =================================================================

class _DwcWeekDetailPage extends StatelessWidget {
  final _DwcWeek week;
  final String uid;
  final VoidCallback onBack;
  const _DwcWeekDetailPage({
    required this.week,
    required this.uid,
    required this.onBack,
  });

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _scoresStream(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snap.data!.docs
                    .map((d) => _DwcDriverEntry.from(d))
                    .where((e) => e.hasData)
                    .toList()
                  ..sort((a, b) =>
                      (a.iadcPct ?? 999).compareTo(b.iadcPct ?? 999));

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _detailHeader(),
                    const SizedBox(height: 12),
                    _summaryHeader(),
                    const SizedBox(height: 16),
                    ...entries.map((e) => _driverRow(context, e)),
                    if (entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                              'Keine DWC/IADC-Datensätze für diese Woche.',
                              style: TextStyle(color: Color(0xFF6B7280))),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Inline header with a back button (keeps the admin sidebar visible
  /// instead of pushing a full-screen route).
  Widget _detailHeader() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: Color(0xFF374151)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'DWC/IADC · KW ${week.week} · ${week.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _summaryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _bigStat('DWC %', week.dwcPct, _dwcColor(week.dwcPct)),
              ),
              Container(width: 1, height: 44, color: const Color(0xFFE5E7EB)),
              Expanded(
                child:
                    _bigStat('IADC %', week.iadcPct, _iadcColor(week.iadcPct)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF0F3)),
          const SizedBox(height: 12),
          _kpiDesc(
            'DWC %',
            'Zustellungen ohne Kundenbeschwerde (kein „nicht erhalten", '
                'kein Schaden). Hoch = gut, Ziel ~98 %+.',
          ),
          const SizedBox(height: 6),
          _kpiDesc(
            'IADC %',
            'Korrekte Zustellbestätigung in der App (Foto, richtige Ablage, '
                'Scan am Zustellort). Hoch = gut.',
          ),
        ],
      ),
    );
  }

  /// "KPI — meaning" line for the white summary card (dark text).
  Widget _kpiDesc(String kpi, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            kpi,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bigStat(String label, double? v, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _fmtPct(v),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _driverRow(BuildContext context, _DwcDriverEntry e) {
    final topMiss = e.misses.isNotEmpty ? e.misses.first : null;
    final subtitle = topMiss != null
        ? '${e.totalMisses} Hits · Top: ${topMiss.value}× '
            '${_MissInfo.forCategory(topMiss.key).title}'
        : 'Keine Miss-Kategorien';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: e.misses.isEmpty ? null : () => _openMisses(context, e),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.driverName.isNotEmpty ? e.driverName : e.transporterId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // KPIs split per driver: DWC and IADC as two separate cells.
              _statCell('DWC', e.dwcPct, _dwcColor(e.dwcPct)),
              const SizedBox(width: 8),
              _statCell('IADC', e.iadcPct, _iadcColor(e.iadcPct)),
              if (e.misses.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF9CA3AF)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact labelled KPI cell (one metric) used per driver.
  Widget _statCell(String label, double? v, Color color) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            _fmtPct(v),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _openMisses(BuildContext context, _DwcDriverEntry e) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MissSheet(entry: e),
    );
  }
}

/// Bottom sheet listing a driver's miss categories with a plain-language
/// explanation of what went wrong and how to improve.
class _MissSheet extends StatelessWidget {
  final _DwcDriverEntry entry;
  const _MissSheet({required this.entry});

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
              const SizedBox(height: 8),
              Row(children: [
                _DwcOverviewPageState._pctPill(
                    'DWC', entry.dwcPct, _dwcColor(entry.dwcPct)),
                const SizedBox(width: 8),
                _DwcOverviewPageState._pctPill(
                    'IADC', entry.iadcPct, _iadcColor(entry.iadcPct)),
                const SizedBox(width: 8),
                Text('${entry.totalMisses} Hits gesamt',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ]),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: entry.misses.length,
                  itemBuilder: (_, i) {
                    final m = entry.misses[i];
                    final info = _MissInfo.forCategory(m.key);
                    return _MissCard(count: m.value, info: info);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MissCard extends StatelessWidget {
  final int count;
  final _MissInfo info;
  const _MissCard({required this.count, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count×',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _kAccentDeep)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(info.title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827))),
            ),
          ]),
          const SizedBox(height: 8),
          _line(Icons.error_outline_rounded, const Color(0xFFB42318),
              'Problem', info.wrong),
          const SizedBox(height: 6),
          _line(Icons.lightbulb_outline_rounded, const Color(0xFF067647),
              'Besser', info.improve),
        ],
      ),
    );
  }

  Widget _line(IconData icon, Color color, String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 12.5, height: 1.4, color: Color(0xFF374151)),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: color)),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =================================================================
//   View-models
// =================================================================

class _DwcWeek {
  final DocumentReference<Map<String, dynamic>> ref;
  final int year;
  final int week;
  final String station;
  final double? dwcPct;
  final double? iadcPct;
  final int totalDrivers;

  _DwcWeek({
    required this.ref,
    required this.year,
    required this.week,
    required this.station,
    required this.dwcPct,
    required this.iadcPct,
    required this.totalDrivers,
  });

  factory _DwcWeek.from(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> dwc,
  ) {
    final data = doc.data();
    final summary = (dwc['summary'] as Map?)?.cast<String, dynamic>() ?? {};
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    double? asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v');
    return _DwcWeek(
      ref: doc.reference,
      year: asInt(data['year']),
      week: asInt(data['weekNumber']),
      station: (data['stationCode'] ?? '').toString(),
      dwcPct: asDouble(summary['dwcPct']),
      iadcPct: asDouble(summary['iadcPct']),
      totalDrivers: asInt(summary['totalDrivers']),
    );
  }
}

class _DwcDriverEntry {
  final String transporterId;
  final String driverName;
  final double? dwcPct;
  final double? iadcPct;
  /// Category → count, sorted highest-first.
  final List<MapEntry<String, int>> misses;

  _DwcDriverEntry({
    required this.transporterId,
    required this.driverName,
    required this.dwcPct,
    required this.iadcPct,
    required this.misses,
  });

  bool get hasData => dwcPct != null || iadcPct != null || misses.isNotEmpty;
  int get totalMisses => misses.fold(0, (s, e) => s + e.value);

  factory _DwcDriverEntry.from(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final dwc = (d['dwc'] as Map?)?.cast<String, dynamic>() ?? {};
    double? asDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v');
    final rawMisses = (dwc['misses'] as Map?)?.cast<String, dynamic>() ?? {};
    final misses = <MapEntry<String, int>>[
      for (final e in rawMisses.entries)
        MapEntry(
            e.key, e.value is num ? (e.value as num).toInt() : 0),
    ]..sort((a, b) => b.value.compareTo(a.value));
    return _DwcDriverEntry(
      transporterId: (d['transporterId'] ?? '').toString(),
      driverName: (d['driverName'] ?? '').toString(),
      dwcPct: asDouble(dwc['dwcPct']),
      iadcPct: asDouble(dwc['iadcPct']),
      misses: misses,
    );
  }
}

/// A short German explanation for a DWC/IADC miss category — what the driver
/// did wrong and how to improve. Matched by keyword so it survives small
/// wording differences between station reports.
class _MissInfo {
  final String title;
  final String wrong;
  final String improve;
  const _MissInfo(this.title, this.wrong, this.improve);

  static _MissInfo forCategory(String raw) {
    final c = raw.toLowerCase();
    bool has(String s) => c.contains(s);
    if (has('photo defect')) {
      return const _MissInfo(
        'Foto-Mangel',
        'Das Zustellfoto war unscharf, zu dunkel oder das Paket nicht erkennbar.',
        'Sauberes, gut ausgeleuchtetes Foto machen — Paket klar im Bild, Ablageort erkennbar. Nicht in Bewegung fotografieren.',
      );
    }
    if (has('no photo')) {
      return const _MissInfo(
        'Kein Foto',
        'Es wurde gar kein Zustellfoto (Photo on Delivery) gemacht.',
        'Bei jeder unbeaufsichtigten Zustellung ein Foto aufnehmen — das ist Pflicht für den Nachweis.',
      );
    }
    if (has('otp')) {
      return const _MissInfo(
        'OTP verpasst',
        'Der Einmalcode (OTP) wurde beim Kunden nicht abgefragt, wo er nötig war.',
        'Bei OTP-Sendungen den Code vom Kunden geben lassen und in der App eingeben — nicht ohne abliefern.',
      );
    }
    if (has('contact miss')) {
      return const _MissInfo(
        'Kontakt verpasst',
        'Der Kunde wurde nicht kontaktiert, obwohl es der Workflow verlangt hätte.',
        'Vor Ablage die App-Kontaktoption nutzen (Anruf/Nachricht), wenn angeboten.',
      );
    }
    if (has('unattended without safe place')) {
      return const _MissInfo(
        'Unbeaufsichtigt ohne sicheren Ort',
        'Paket unbeaufsichtigt abgelegt, ohne sicheren Ort und ohne Kontakt — hohes Beschwerderisiko (DNR).',
        'Nur an einem wirklich sicheren, vor Sicht/Wetter geschützten Ort ablegen — sonst Kontakt suchen oder Fehlversuch.',
      );
    }
    if (has('phr')) {
      return const _MissInfo(
        'Nicht am Kunden-Ablageort',
        'Nicht an dem vom Kunden hinterlegten bevorzugten Ablageort (PHR) zugestellt.',
        'Die vom Kunden hinterlegte Ablagepräferenz in der App befolgen.',
      );
    }
    if (has('mailbox')) {
      return const _MissInfo(
        'Briefkasten-Empfehlung ignoriert',
        'Die App hat Briefkasten/Mailbox empfohlen, es wurde aber anders zugestellt.',
        'Der empfohlenen Zustellmethode folgen — bei Mailbox-Empfehlung in den Briefkasten legen.',
      );
    }
    if (has('unattended')) {
      return const _MissInfo(
        'Ablage-Methode nicht befolgt (Unattended)',
        'Die von der App empfohlene bzw. sichere unbeaufsichtigte Ablage-Methode wurde nicht eingehalten.',
        'Immer die in der App vorgeschlagene Methode wählen (empfohlener/­sicherer Ort) statt eigenmächtig abzulegen.',
      );
    }
    if (has('attended')) {
      return const _MissInfo(
        'Übergabe-Methode nicht befolgt (Attended)',
        'Bei einer Übergabe wurde nicht die empfohlene/­sichere Methode eingehalten.',
        'Persönliche Übergabe korrekt in der App bestätigen und die empfohlene Methode wählen.',
      );
    }
    if (has('business hours')) {
      return const _MissInfo(
        'Außerhalb der Öffnungszeiten',
        'Ein Geschäftskunde wurde außerhalb seiner Öffnungszeiten angefahren.',
        'Geschäftsadressen nur innerhalb der Öffnungszeiten zustellen — sonst umplanen.',
      );
    }
    if (has('false scan')) {
      return const _MissInfo(
        'Falsch-Scan',
        'Ein Scan wurde vom Kunden als falsch bestätigt (z. B. zu weit vom Zustellort gescannt).',
        'Erst am tatsächlichen Zustellort scannen — nicht aus dem Fahrzeug oder aus Distanz.',
      );
    }
    if (has('household member')) {
      return const _MissInfo(
        'Haushaltsmitglied (DNR)',
        'Übergabe an ein Haushaltsmitglied führte zu „nicht erhalten" (DNR).',
        'Bei Übergabe die richtige Person/Option wählen und korrekt in der App bestätigen.',
      );
    }
    if (has('1-ca') || has('mailbox miss')) {
      return const _MissInfo(
        'Nicht in Briefkasten zugestellt',
        'Eine Briefkasten-Zustellung wurde nicht wie vorgesehen ausgeführt.',
        'Wenn Briefkasten möglich/empfohlen: dort zustellen und korrekt bestätigen.',
      );
    }
    return _MissInfo(
      raw,
      'Zustellung wich vom vorgesehenen Workflow ab.',
      'Den in der App vorgegebenen Zustell- und Bestätigungsablauf genau befolgen.',
    );
  }
}
