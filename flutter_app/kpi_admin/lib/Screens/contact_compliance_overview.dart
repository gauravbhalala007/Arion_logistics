// lib/Screens/contact_compliance_overview.dart
//
// Contact Compliance overview — mirrors the DWC/IADC architecture:
// upload option on top, hero stats, sort, weekly cards, per-week detail
// with per-driver Contact-Compliance ranking. Data lives at:
//
//   users/{adminUid}/reports/{reportId}
//     .summary.deliveryQualitySwc.standardWorkCompliance.contactCompliance
//   users/{adminUid}/scores/{reportId}_{transporterId}
//     .kpis.CC  (raw percentage)  ·  .comp.CC_Score (computed score)
//
// Contact Compliance (CC) is the Amazon scorecard metric describing how
// often a driver correctly contacted the customer (call / SMS) when a
// delivery problem occurred. The parser_service already extracts the
// per-driver "CC" column from the weekly DSP scorecard PDF, so the
// upload path here is the scorecard PDF — same parser + ReportWriter
// pipeline as the sibling sections, no new Firestore paths or rules.
//
// Note: unlike CDF/DWC there is no per-week delete button here — the CC
// values live inside the shared DSP scorecard score docs (kpis/comp),
// which are managed from the Score Card Dashboard.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/parser_api.dart';
import '../services/report_writer.dart';
import '../widgets/admin_scope.dart';

// Theme accents (teal — distinct from CDF's amber and DWC's blue).
const _kAccent = Color(0xFF0D9488);
const _kAccentDeep = Color(0xFF115E59);

/// "xx.x%" or "—" for a nullable percentage.
String _fmtPct(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)}%';

/// Colour for a Contact-Compliance value (higher is better, target ~98%+).
Color _ccColor(double? v) {
  if (v == null) return const Color(0xFF9CA3AF);
  if (v >= 98) return const Color(0xFF067647);
  if (v >= 95) return const Color(0xFFB45309);
  return const Color(0xFFB42318);
}

/// Parses "98,5 %", "98.5%", 98.5 … into a double, else null.
double? _pctOf(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim().replaceAll('%', '').replaceAll(',', '.');
  if (s.isEmpty) return null;
  return double.tryParse(s);
}

class ContactComplianceOverviewPage extends StatefulWidget {
  const ContactComplianceOverviewPage({super.key});

  @override
  State<ContactComplianceOverviewPage> createState() =>
      _ContactComplianceOverviewPageState();
}

enum _Sort { dateDesc, worstCc }

class _ContactComplianceOverviewPageState
    extends State<ContactComplianceOverviewPage> {
  bool _busyUpload = false;
  _Sort _sort = _Sort.dateDesc;
  // When set, the week-detail view is shown inline (inside the admin shell,
  // so the sidebar stays) instead of pushing a full-screen route.
  _CcWeek? _selectedWeek;

  // Dispatcher arbeiten im Namespace ihres Admins — currentUser.uid wäre
  // dort der falsche (leere) Namespace.
  String? get _uid => AdminScope.adminUidOf(context);

  /// True when the parsed file actually carries per-driver Contact
  /// Compliance data (the "CC" column of the DSP scorecard PDF). Without
  /// this guard an unrelated file would be reported as uploaded but never
  /// show up in this section.
  static bool _parsedHasContactCompliance(Map<String, dynamic> parsed) {
    final drivers = (parsed['drivers'] as List?) ?? const [];
    if (drivers.any(
        (d) => d is Map && (d['CC'] != null || d['CC_Score'] != null))) {
      return true;
    }
    final summary =
        (parsed['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
    final dqs =
        (summary['deliveryQualitySwc'] as Map?)?.cast<String, dynamic>() ??
            const {};
    final swc = (dqs['standardWorkCompliance'] as Map?)
            ?.cast<String, dynamic>() ??
        const {};
    return swc['contactCompliance'] != null;
  }

  Future<void> _uploadScorecardPdf() async {
    if (_busyUpload) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    setState(() => _busyUpload = true);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
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
        final parsed = await ParserApi.parsePdf(bytes, filename: f.name);
        if (!_parsedHasContactCompliance(parsed)) {
          failed.add(
            de
                ? '${f.name}: keine Contact-Compliance-Daten erkannt — bitte '
                    'die wöchentliche Amazon-Scorecard-PDF unverändert '
                    'hochladen'
                : '${f.name}: no Contact Compliance data detected — please '
                    'upload the original weekly Amazon scorecard PDF '
                    'unchanged',
          );
          continue;
        }
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await ReportWriter.writeReportAndScores(
          parserJson: parsed,
          storagePath: 'inline/$date/${f.name}',
          adminUid: _uid,
        );
        ok++;
      }
      if (!mounted) return;
      final msg = StringBuffer(
        de
            ? (ok == 1
                ? '1 Scorecard erfolgreich hochgeladen.'
                : '$ok Scorecards erfolgreich hochgeladen.')
            : (ok == 1
                ? '1 scorecard uploaded successfully.'
                : '$ok scorecards uploaded successfully.'),
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
    // Inline week detail — keeps the admin sidebar visible.
    if (_selectedWeek != null) {
      return _CcWeekDetailPage(
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
                final de =
                    Localizations.localeOf(ctx).languageCode == 'de';
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
                final weeks = <_CcWeek>[];
                for (final d in allDocs) {
                  final w = _CcWeek.from(d);
                  if (w == null) continue;
                  weeks.add(w);
                }
                _sortWeeks(weeks);
                return ListView(
                  children: [
                    _hero(weeks),
                    const SizedBox(height: 18),
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

  void _sortWeeks(List<_CcWeek> list) {
    int byDate(_CcWeek a, _CcWeek b) {
      final yc = b.year.compareTo(a.year);
      if (yc != 0) return yc;
      return b.week.compareTo(a.week);
    }

    switch (_sort) {
      case _Sort.worstCc:
        list.sort((a, b) => (a.ccPct ?? 999).compareTo(b.ccPct ?? 999));
        break;
      case _Sort.dateDesc:
        list.sort(byDate);
        break;
    }
  }

  // ─── Header ─────────────────────────────────────────────
  Widget _hero(List<_CcWeek> weeks) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    double? avg(Iterable<double?> xs) {
      final vals = xs.whereType<double>().toList();
      if (vals.isEmpty) return null;
      return vals.reduce((a, b) => a + b) / vals.length;
    }

    final byDate = [...weeks]..sort((a, b) {
        final yc = b.year.compareTo(a.year);
        return yc != 0 ? yc : b.week.compareTo(a.week);
      });
    final latest = byDate.isEmpty ? null : byDate.first;
    final avgCc = avg(weeks.map((w) => w.ccPct));
    final ccVals = weeks.map((w) => w.ccPct).whereType<double>().toList();
    final bestCc = ccVals.isEmpty
        ? null
        : ccVals.reduce((a, b) => a > b ? a : b);

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
            'Contact Compliance',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            de
                ? 'Korrekte Kundenkontaktaufnahme bei Zustellproblemen — pro '
                    'Woche und Fahrer'
                : 'Correct customer contact on delivery problems — per week '
                    'and driver',
            style: const TextStyle(color: Color(0xFF99F6E4), fontSize: 12),
          ),
          const SizedBox(height: 14),
          _kpiExplainer(
            'CC %',
            de
                ? 'Wie oft der Fahrer bei Zustellproblemen den Kunden korrekt '
                    'kontaktiert hat (Anruf/SMS über die App). Hoch = gut, '
                    'Ziel ~98 %+.'
                : 'How often the driver correctly contacted the customer '
                    '(call/SMS via the app) when a delivery problem occurred. '
                    'Higher is better, target ~98%+.',
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (ctx, c) {
            final narrow = c.maxWidth < 720;
            final tiles = [
              _heroTile('Ø CC %', _fmtPct(avgCc)),
              _heroTile(
                de ? 'Aktuelle Woche' : 'Latest week',
                _fmtPct(latest?.ccPct),
              ),
              _heroTile(
                de ? 'Beste Woche' : 'Best week',
                _fmtPct(bestCc),
              ),
              _heroTile(de ? 'Wochen' : 'Weeks', '${weeks.length}'),
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
              color: Color(0xFFCCFBF1),
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
              color: Color(0xFFD9FDF6),
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
          onPressed: _busyUpload ? null : _uploadScorecardPdf,
          icon: _busyUpload
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(_busyUpload
              ? (de ? 'Lädt…' : 'Loading…')
              : (de
                  ? 'Scorecard hochladen (PDF)'
                  : 'Upload scorecard (PDF)')),
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
              value: _Sort.worstCc,
              child: Text(de ? 'Schlechteste CC' : 'Worst CC'),
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
          const Icon(Icons.phone_in_talk_outlined, size: 56, color: _kAccent),
          const SizedBox(height: 12),
          Text(
            de
                ? 'Noch keine Contact-Compliance-Daten vorhanden'
                : 'No Contact Compliance data yet',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Klick oben auf "Scorecard hochladen (PDF)" und wähle die '
                    'wöchentliche Amazon-Scorecard-PDF. Die Contact-Compliance-'
                    'Werte pro Fahrer werden automatisch daraus gelesen.'
                : 'Click "Upload scorecard (PDF)" above and pick the weekly '
                    'Amazon scorecard PDF. Per-driver Contact Compliance '
                    'values are read from it automatically.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Week card ─────────────────────────────────────────
  Widget _weekCard(_CcWeek w) {
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
                  color: _ccColor(w.ccPct),
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
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            w.station,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      _pctPill('CC', w.ccPct, _ccColor(w.ccPct)),
                      const SizedBox(width: 8),
                      Text(
                        de
                            ? 'Fahrer-Details öffnen'
                            : 'Open driver details',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ]),
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

  // ─── Week detail ──────────────────────────────────────
  void _openWeek(_CcWeek w) {
    setState(() => _selectedWeek = w);
  }
}

// =================================================================
//   Per-week detail (per-driver Contact-Compliance ranking)
// =================================================================

class _CcWeekDetailPage extends StatelessWidget {
  final _CcWeek week;
  final String uid;
  final VoidCallback onBack;
  const _CcWeekDetailPage({
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
    final de = Localizations.localeOf(context).languageCode == 'de';
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
                    .map((d) => _CcDriverEntry.from(d))
                    .where((e) => e.hasData)
                    .toList()
                  ..sort(
                      (a, b) => (a.ccPct ?? 999).compareTo(b.ccPct ?? 999));

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _detailHeader(de),
                    const SizedBox(height: 12),
                    _summaryHeader(de),
                    const SizedBox(height: 16),
                    ...entries.map((e) => _driverRow(context, e)),
                    if (entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            de
                                ? 'Keine Contact-Compliance-Datensätze für '
                                    'diese Woche.'
                                : 'No Contact Compliance records for this '
                                    'week.',
                            style:
                                const TextStyle(color: Color(0xFF6B7280)),
                          ),
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
  Widget _detailHeader(bool de) {
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
          'Contact Compliance · ${de ? 'KW' : 'CW'} ${week.week} · '
          '${week.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _summaryHeader(bool de) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _bigStat(
            de ? 'CC % (Station gesamt)' : 'CC % (station overall)',
            week.ccPct,
            _ccColor(week.ccPct),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF0F3)),
          const SizedBox(height: 12),
          _kpiDesc(
            'CC %',
            de
                ? 'Wie oft der Fahrer bei Zustellproblemen den Kunden korrekt '
                    'kontaktiert hat (Anruf/SMS über die App). Hoch = gut, '
                    'Ziel ~98 %+.'
                : 'How often the driver correctly contacted the customer '
                    '(call/SMS via the app) when a delivery problem occurred. '
                    'Higher is better, target ~98%+.',
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
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            kpi,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F766E),
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

  Widget _driverRow(BuildContext context, _CcDriverEntry e) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
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
                    e.ccPct == null
                        ? (de
                            ? 'Kein CC-Wert diese Woche'
                            : 'No CC value this week')
                        : (e.ccPct! >= 98
                            ? (de ? 'Im Zielbereich' : 'On target')
                            : (de
                                ? 'Unter Ziel — Kontaktaufnahme schulen'
                                : 'Below target — coach contact workflow')),
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
            _statCell('CC', e.ccPct, _ccColor(e.ccPct)),
            if (e.ccScore != null) ...[
              const SizedBox(width: 8),
              _scoreCell(de ? 'Score' : 'Score', e.ccScore!),
            ],
          ],
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

  /// Neutral cell for the computed CC score (0–100, no % sign).
  Widget _scoreCell(String label, double v) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            v.toStringAsFixed(v % 1 == 0 ? 0 : 1),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
//   View-models
// =================================================================

class _CcWeek {
  final DocumentReference<Map<String, dynamic>> ref;
  final int year;
  final int week;
  final String station;

  /// Station-level Contact Compliance from the scorecard summary
  /// (`deliveryQualitySwc.standardWorkCompliance.contactCompliance.value`);
  /// null when the parser found no company value for that week.
  final double? ccPct;

  _CcWeek({
    required this.ref,
    required this.year,
    required this.week,
    required this.station,
    required this.ccPct,
  });

  /// Returns null when the report doc carries no DSP-scorecard data at all
  /// (e.g. weeks where only CDF/DWC/Concessions were uploaded).
  static _CcWeek? from(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final summary =
        (data['summary'] as Map?)?.cast<String, dynamic>() ?? const {};
    final dqs =
        (summary['deliveryQualitySwc'] as Map?)?.cast<String, dynamic>() ??
            const {};
    final swc = (dqs['standardWorkCompliance'] as Map?)
            ?.cast<String, dynamic>() ??
        const {};
    final ccMetric =
        (swc['contactCompliance'] as Map?)?.cast<String, dynamic>();

    // Only weeks with DSP-scorecard content have per-driver CC values.
    final isScorecardWeek = ccMetric != null ||
        summary['overallScore'] != null ||
        summary['overallStatus'] != null;
    if (!isScorecardWeek) return null;

    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return _CcWeek(
      ref: doc.reference,
      year: asInt(data['year']),
      week: asInt(data['weekNumber']),
      station: (data['stationCode'] ?? '').toString(),
      ccPct: _pctOf(ccMetric?['value']),
    );
  }
}

class _CcDriverEntry {
  final String transporterId;
  final String driverName;

  /// Raw Contact-Compliance percentage from the scorecard ("CC" column).
  final double? ccPct;

  /// Computed CC score (0–100) from the KPI formulas, when present.
  final double? ccScore;

  _CcDriverEntry({
    required this.transporterId,
    required this.driverName,
    required this.ccPct,
    required this.ccScore,
  });

  bool get hasData => ccPct != null || ccScore != null;

  factory _CcDriverEntry.from(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final kpis = (d['kpis'] as Map?)?.cast<String, dynamic>() ?? const {};
    final comp = (d['comp'] as Map?)?.cast<String, dynamic>() ?? const {};
    return _CcDriverEntry(
      transporterId: (d['transporterId'] ?? '').toString(),
      driverName: (d['driverName'] ?? '').toString(),
      ccPct: _pctOf(kpis['CC']),
      ccScore: _pctOf(comp['CC_Score']),
    );
  }
}
