import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';
import '../widgets/metric_info_chip.dart';

final _intFmt = NumberFormat.decimalPattern('de');
final _eurFmt = NumberFormat.currency(
  locale: 'de_DE',
  symbol: '€',
  decimalDigits: 2,
);

/// Geschätzte Kosten pro DNR-Fall (Amazon-Erstattung + operativer
/// Mehraufwand). Heuristik — kann später pro DSP per Firestore-Setting
/// konfigurierbar werden.
const double kEurPerDnr = 5.50;

String _eurStr(num? dnrCount) {
  if (dnrCount == null) return '—';
  final eur = dnrCount * kEurPerDnr;
  try {
    return _eurFmt.format(eur);
  } catch (_) {
    return '€ ${eur.toStringAsFixed(2)}';
  }
}

/// Sorted list of Concessions focus areas as `MetricInfoChip`s, sorted
/// by count descending so the most-frequent mistakes appear first.
/// `focus` is the raw map from Firestore (`summary.concessions.focusBuckets`).
List<Widget> buildConcessionsFocusChips(
  BuildContext context,
  Map<String, dynamic> focus,
) {
  final t = AppLocalizations.of(context);

  num? n(String k) {
    final v = focus[k];
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v.trim().replaceAll(',', '.'));
    return null;
  }

  String fmt(num? v) {
    if (v == null) return '—';
    try {
      return _intFmt.format(v);
    } catch (_) {
      return '—';
    }
  }

  // Order: dataKey, labelKey (rest derived: ${labelKey}_desc + _tip).
  // Listed in default order — gets re-sorted by count below.
  final entries = <_FocusEntry>[
    _FocusEntry('attendedDnr', 'concessions_focus_attended_dnr'),
    _FocusEntry('photoOnDelivery', 'concessions_focus_photo_on_delivery'),
    _FocusEntry(
      'successfulContact',
      'concessions_focus_successful_contact',
    ),
    _FocusEntry('delivered25m', 'concessions_focus_delivered_25m'),
    _FocusEntry('falseScan', 'concessions_focus_false_scan'),
    _FocusEntry('mailbox', 'concessions_focus_mailbox'),
    _FocusEntry('deliveredOtp', 'concessions_focus_delivered_otp'),
  ];

  // Sort: warnings (count > 0) first, then by count desc, then alpha.
  entries.sort((a, b) {
    final ca = n(a.dataKey) ?? 0;
    final cb = n(b.dataKey) ?? 0;
    final aWarn = ca > 0;
    final bWarn = cb > 0;
    if (aWarn != bWarn) return bWarn ? 1 : -1;
    if (ca != cb) return cb.compareTo(ca);
    return a.labelKey.compareTo(b.labelKey);
  });

  return entries.map((e) {
    final c = n(e.dataKey);
    return MetricInfoChip(
      label: t.t(e.labelKey),
      value: fmt(c),
      count: c,
      description: t.t('${e.labelKey}_desc'),
      tip: t.t('${e.labelKey}_tip'),
    );
  }).toList();
}

class _FocusEntry {
  final String dataKey;
  final String labelKey;
  const _FocusEntry(this.dataKey, this.labelKey);
}

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _intFmt.format(v);
  } catch (_) {
    return '—';
  }
}

double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim().replaceAll('%', '');
    return double.tryParse(s.replaceAll(',', '.'));
  }
  return null;
}

class ConcessionsWeekPage extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> reportRef;

  const ConcessionsWeekPage({super.key, required this.reportRef});

  @override
  State<ConcessionsWeekPage> createState() => _ConcessionsWeekPageState();
}

class _ConcessionsWeekPageState extends State<ConcessionsWeekPage> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _reportStream;

  Future<void> _confirmDeleteDetail(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('concessions_delete_week_title')),
        content: Text(
          t.tf('concessions_delete_week_body', {
            'week': t.t('concessions_shell_week_title'),
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.t('admin_home_cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.t('concessions_delete_week_confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final db = FirebaseFirestore.instance;
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final scoresSnap = await db
          .collection('users')
          .doc(uid)
          .collection('scores')
          .where('reportPath', isEqualTo: widget.reportRef.path)
          .get();
      const chunkSize = 400;
      for (var i = 0; i < scoresSnap.docs.length; i += chunkSize) {
        final batch = db.batch();
        final end = (i + chunkSize < scoresSnap.docs.length)
            ? i + chunkSize
            : scoresSnap.docs.length;
        for (final d in scoresSnap.docs.sublist(i, end)) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
      await widget.reportRef.delete();
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('concessions_delete_week_failed', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Query by reportPath (string) — survives migration cleanly. The
    // alternative .where('reportRef', isEqualTo: widget.reportRef) used
    // to fail silently in some imports because the imported
    // DocumentReference instances did not equality-match.
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('reportPath', isEqualTo: widget.reportRef.path)
        .snapshots()
        .map((s) => s.docs);
  }

  @override
  void initState() {
    super.initState();
    _reportStream = widget.reportRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Material(
      color: const Color(0xFFF5F7F9),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _reportStream,
        builder: (context, reportSnap) {
          if (reportSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final report = reportSnap.data?.data() ?? {};
          final summary =
              (report['summary'] as Map?)?.cast<String, dynamic>() ?? {};
          final conc =
              (summary['concessions'] as Map?)?.cast<String, dynamic>() ?? {};
          final concSummary =
              (conc['summary'] as Map?)?.cast<String, dynamic>() ?? {};
          final concFocus =
              (conc['focusBuckets'] as Map?)?.cast<String, dynamic>() ?? {};

          final label = (summary['weekText'] ?? t.t('concessions_title'))
              .toString();
          final station =
              (summary['stationCode'] ?? report['stationCode'] ?? '')
                  .toString();

          final delVolume = _num(concSummary['delVolume']);
          final dnrCount = _num(concSummary['dnrCount']);
          final dnrDpmo = _num(concSummary['dnrDpmo']);

          final reportYear = (report['year'] as num?)?.toInt() ?? 0;
          final reportWeek = (report['weekNumber'] as num?)?.toInt() ?? 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F111827),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                if (station.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      station,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF374151),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: t.t(
                              'concessions_delete_week_tooltip',
                            ),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFB42318),
                              size: 22,
                            ),
                            onPressed: () => _confirmDeleteDetail(context),
                          ),
                          const SizedBox(width: 4),
                          _SectionTag(
                            label: t.t('concessions_title'),
                            icon: Icons.report_gmailerrorred_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final useRow = constraints.maxWidth >= 720;
                          final tiles = [
                            _StatTile(
                              label: t.t('concessions_delivered'),
                              value: _intStr(delVolume),
                              tone: _TileTone.neutral,
                            ),
                            _StatTile(
                              label: t.t('concessions_dnr_count'),
                              value: _intStr(dnrCount),
                              tone: _TileTone.warn,
                            ),
                            _StatTile(
                              label: t.t('concessions_dnr_dpmo'),
                              value: _intStr(dnrDpmo),
                              tone: _TileTone.warn,
                            ),
                            _StatTile(
                              label: t.t('concessions_loss'),
                              value: _eurStr(dnrCount),
                              tone: _TileTone.danger,
                            ),
                          ];

                          if (useRow) {
                            return Row(
                              children: [
                                Expanded(child: tiles[0]),
                                const SizedBox(width: 12),
                                Expanded(child: tiles[1]),
                                const SizedBox(width: 12),
                                Expanded(child: tiles[2]),
                                const SizedBox(width: 12),
                                Expanded(child: tiles[3]),
                              ],
                            );
                          }

                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: tiles,
                          );
                        },
                      ),
                      if (concFocus.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          t.t('concessions_focus_breakdown'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: buildConcessionsFocusChips(
                            context,
                            concFocus,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Expanded(
                child:
                    StreamBuilder<
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    >(
                      stream: _scores(),
                      builder: (context, scoreSnap) {
                        if (scoreSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final docs = scoreSnap.data ?? const [];
                        // XLSX-Summary-Zeilen ausfiltern (TOTALDNRCOUNT
                        // u. ä.) — die addieren bereits alle Fahrer und
                        // wuerden hier doppelt erscheinen.
                        const summaryKeys = {
                          'TOTAL',
                          'TOTALDNR',
                          'TOTALDNRCOUNT',
                          'TOTAL_DNR',
                          'TOTAL_DNR_COUNT',
                          'SUMMARY',
                          'GESAMT',
                          'GESAMTSUMME',
                          'SUM',
                          'TOTALS',
                        };
                        bool isSummary(Map<String, dynamic> data) {
                          final tid =
                              (data['transporterId'] ?? '').toString();
                          final name =
                              (data['driverName'] ?? '').toString();
                          final tidU = tid.trim().toUpperCase();
                          final nameU = name.trim().toUpperCase();
                          final tidN =
                              tidU.replaceAll(RegExp(r'[^A-Z]'), '');
                          final nameN =
                              nameU.replaceAll(RegExp(r'[^A-Z]'), '');
                          return summaryKeys.contains(tidU) ||
                              summaryKeys.contains(nameU) ||
                              summaryKeys.contains(tidN) ||
                              summaryKeys.contains(nameN);
                        }
                        final rows = docs
                            .where(
                              (d) =>
                                  (d.data()['concessions'] as Map?) !=
                                      null &&
                                  !isSummary(d.data()),
                            )
                            .toList();

                        if (rows.isEmpty) {
                          return Center(
                            child: Text(t.t('concessions_no_data_week')),
                          );
                        }

                        // Sort by DPMO 4W descending (worst first)
                        rows.sort((a, b) {
                          final pa =
                              _num(
                                (a.data()['concessions']
                                        as Map?)?['dnrDpmo4w'],
                              ) ??
                              0;
                          final pb =
                              _num(
                                (b.data()['concessions']
                                        as Map?)?['dnrDpmo4w'],
                              ) ??
                              0;
                          return pb.compareTo(pa);
                        });

                        // Ticket „alle Betraege auflisten": Summe je
                        // Woche ueber alle Fahrer — die Kacheln oben
                        // zeigen nur die 4-Wochen-Summe, hier steht die
                        // Aufschluesselung samt Betrag je Woche.
                        final weekTotals = <String, int>{};
                        for (final d in rows) {
                          final cw =
                              ((d.data()['concessions'] as Map?)?['dnrCountByWeek']
                                      as Map?)
                                  ?.cast<String, dynamic>() ??
                              const <String, dynamic>{};
                          cw.forEach((k, v) {
                            final n = v is num
                                ? v.toInt()
                                : int.tryParse('$v') ?? 0;
                            if (n > 0) {
                              weekTotals[k] = (weekTotals[k] ?? 0) + n;
                            }
                          });
                        }

                        return Column(
                          children: [
                            if (weekTotals.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    24, 4, 24, 4),
                                child: _WeekAmountsPanel(
                                  weekTotals: weekTotals,
                                  reportYear: reportYear,
                                  reportWeek: reportWeek,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                4,
                                24,
                                8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    t.t('concessions_drivers'),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _SectionTag(
                                    label: t.tf(
                                      'concessions_entries_count',
                                      {'count': '${rows.length}'},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  24,
                                ),
                                itemCount: rows.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final data = rows[i].data();
                                  final c =
                                      (data['concessions'] as Map?)
                                          ?.cast<String, dynamic>() ??
                                      const <String, dynamic>{};

                                  final transporterId =
                                      (data['transporterId'] ?? '').toString();
                                  final driverName = (data['driverName'] ?? '')
                                      .toString()
                                      .trim();
                                  final name = driverName.isNotEmpty
                                      ? driverName
                                      : t.t('dash_no_name');

                                  final totalDelivered =
                                      _num(c['totalDelivered']);
                                  final totalDnr = _num(c['totalDnr']);
                                  final dpmo4w = _num(c['dnrDpmo4w']);

                                  final byWeek =
                                      (c['dnrCountByWeek'] as Map?)
                                          ?.cast<String, dynamic>() ??
                                      const {};
                                  final focus =
                                      (c['focusBuckets'] as Map?)
                                          ?.cast<String, dynamic>() ??
                                      const {};

                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x0B111827),
                                          blurRadius: 18,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            _AvatarBadge(
                                              text: name,
                                              noNameText:
                                                  t.t('dash_no_name'),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Color(
                                                        0xFF111827,
                                                      ),
                                                    ),
                                                  ),
                                                  if (transporterId
                                                      .isNotEmpty)
                                                    Text(
                                                      transporterId,
                                                      style:
                                                          const TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF6B7280,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            // Kompakte Metrik-Leiste: DNRs · DPMO · Loss
                                            _DriverMetricStrip(
                                              dnrCount: totalDnr,
                                              dpmo4w: dpmo4w,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_delivered',
                                              ),
                                              value: _intStr(totalDelivered),
                                            ),
                                            ..._dnrWeekChips(
                                              context,
                                              byWeek: byWeek,
                                              reportYear: reportYear,
                                              reportWeek: reportWeek,
                                            ),
                                            ...buildConcessionsFocusChips(
                                              context,
                                              focus,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

enum _TileTone { neutral, good, warn, danger }

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final _TileTone tone;

  const _StatTile({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (tone) {
      case _TileTone.good:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case _TileTone.warn:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      case _TileTone.danger:
        bg = const Color(0xFFFEE4E2);
        fg = const Color(0xFFB42318);
        break;
      case _TileTone.neutral:
      default:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final _TileTone tone;

  const _StatPill({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (tone) {
      case _TileTone.good:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case _TileTone.warn:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      case _TileTone.danger:
        bg = const Color(0xFFFEE4E2);
        fg = const Color(0xFFB42318);
        break;
      case _TileTone.neutral:
      default:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTag extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _SectionTag({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF6B7280)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String text;
  final String noNameText;

  const _AvatarBadge({required this.text, required this.noNameText});

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == noNameText) return '?';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.map((p) => p[0]).toList();
    if (letters.isEmpty) return '?';
    if (letters.length == 1) return letters.first.toUpperCase();
    return (letters[0] + letters[1]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(text);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

/// Kompakte horizontale Metrik-Leiste fuer Concessions Driver-Row.
/// Drei Werte nebeneinander: DNRs, DPMO 4W, geschaetzter EUR-Verlust.
/// Jede Zelle ist tap-bar → oeffnet Erklaer-Sheet (MetricInfoChip).
class _DriverMetricStrip extends StatelessWidget {
  final double? dnrCount;
  final double? dpmo4w;
  const _DriverMetricStrip({this.dnrCount, this.dpmo4w});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        MetricInfoChip(
          label: t.t('concessions_dnr_count'),
          value: _intStr(dnrCount),
          count: dnrCount,
          description: t.t('concessions_dnr_count_desc'),
          tip: t.t('concessions_dnr_count_tip'),
        ),
        const SizedBox(width: 6),
        MetricInfoChip(
          label: t.t('concessions_dnr_dpmo_4w'),
          value: _intStr(dpmo4w),
          count: dpmo4w,
          description: t.t('concessions_dnr_dpmo_4w_desc'),
          tip: t.t('concessions_dnr_dpmo_4w_tip'),
        ),
        const SizedBox(width: 6),
        MetricInfoChip(
          label: t.t('concessions_loss'),
          value: _eurStr(dnrCount),
          count: dnrCount,
          description: t.t('concessions_loss_desc'),
          tip: t.t('concessions_loss_tip'),
        ),
      ],
    );
  }
}

/// Berechnet die ISO-Kalenderwoche fuer (year, week, offset).
/// offset == 0 → genau die Report-Woche
/// offset == -1 → eine Woche frueher, etc.
/// Behandelt Jahreswechsel: KW 1 → KW 52/53 des Vorjahres.
({int year, int week}) _shiftIsoWeek(int year, int week, int offset) {
  int y = year;
  int w = week + offset;
  while (w < 1) {
    y -= 1;
    final prevMax = _isoWeeksInYear(y);
    w += prevMax;
  }
  while (w > _isoWeeksInYear(y)) {
    w -= _isoWeeksInYear(y);
    y += 1;
  }
  return (year: y, week: w);
}

/// Liefert das Datum (Montag, 00:00 UTC) der gegebenen ISO-Kalenderwoche.
/// Der 4. Januar liegt per Definition in KW 1 — wir suchen den Montag
/// dieser Woche und addieren (week - 1) * 7 Tage.
DateTime _isoWeekMonday(int year, int week) {
  final jan4 = DateTime.utc(year, 1, 4);
  final jan4Dow = jan4.weekday; // 1=Mo .. 7=So
  final week1Monday = jan4.subtract(Duration(days: jan4Dow - 1));
  return week1Monday.add(Duration(days: (week - 1) * 7));
}

int _isoWeeksInYear(int year) {
  // Eine ISO-Woche hat das Jahr 53 wenn der 1.1. ein Donnerstag ist
  // oder es ein Schaltjahr ist und der 1.1. ein Mittwoch ist.
  final jan1Dow = DateTime(year, 1, 1).weekday;
  final isLeap =
      (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  if (jan1Dow == DateTime.thursday) return 53;
  if (isLeap && jan1Dow == DateTime.wednesday) return 53;
  return 52;
}

/// Erzeugt Chips fuer DNR-Vorkommen pro echter Kalenderwoche.
/// Nur Wochen mit count > 0 werden gezeigt, sortiert: neueste zuerst.
List<Widget> _dnrWeekChips(
  BuildContext context, {
  required Map<String, dynamic> byWeek,
  required int reportYear,
  required int reportWeek,
}) {
  if (reportWeek <= 0) return const [];
  final t = AppLocalizations.of(context);

  // w4 = neueste Woche (= reportWeek), w1 = aelteste (= reportWeek - 3)
  // Mappe w-Schluessel auf Offset relativ zur Report-Woche.
  const wToOffset = <String, int>{
    'w4': 0,
    'w3': -1,
    'w2': -2,
    'w1': -3,
  };

  final entries = <({int year, int week, int count})>[];
  for (final wKey in wToOffset.keys) {
    final raw = byWeek[wKey];
    final n = (raw is num)
        ? raw.toInt()
        : (raw is String ? int.tryParse(raw.trim()) ?? 0 : 0);
    if (n <= 0) continue;
    final shifted = _shiftIsoWeek(reportYear, reportWeek, wToOffset[wKey]!);
    entries.add((year: shifted.year, week: shifted.week, count: n));
  }

  // Sort: newest first (highest year then week desc)
  entries.sort((a, b) {
    final yc = b.year.compareTo(a.year);
    if (yc != 0) return yc;
    return b.week.compareTo(a.week);
  });

  if (entries.isEmpty) return const [];

  return entries.map((e) {
    final mondayDate = _isoWeekMonday(e.year, e.week);
    final sundayDate = mondayDate.add(const Duration(days: 6));
    final df = DateFormat('dd.MM.', 'de_DE');
    final dfFull = DateFormat('dd.MM.yyyy', 'de_DE');
    final dateRange = mondayDate.year == sundayDate.year
        ? '${df.format(mondayDate)} – ${dfFull.format(sundayDate)}'
        : '${dfFull.format(mondayDate)} – ${dfFull.format(sundayDate)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE4E2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 14,
            color: Color(0xFFB42318),
          ),
          const SizedBox(width: 6),
          Text(
            dateRange,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A271A),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            // Ticket „alle Betraege auflisten": je Woche Anzahl UND
            // geschaetzter Betrag, nicht nur die 4-Wochen-Summe oben.
            '· ${e.count} · ${_eurStr(e.count)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB42318),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }).toList();
}

/// „Beträge je Woche" — Aufschlüsselung der DNRs und der geschätzten
/// Beträge über alle Fahrer, je Kalenderwoche des Reports (W1–W4).
///
/// Ticket: die Kacheln oben zeigen nur die 4-Wochen-Summe; hier steht
/// jede Woche einzeln mit Datumsspanne, Anzahl und Betrag.
class _WeekAmountsPanel extends StatelessWidget {
  const _WeekAmountsPanel({
    required this.weekTotals,
    required this.reportYear,
    required this.reportWeek,
  });

  /// wKey ('w1'..'w4') → DNR-Summe über alle Fahrer.
  final Map<String, int> weekTotals;
  final int reportYear;
  final int reportWeek;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (reportWeek <= 0) return const SizedBox.shrink();

    const wToOffset = <String, int>{'w4': 0, 'w3': -1, 'w2': -2, 'w1': -3};
    final entries = <({int year, int week, int count})>[];
    weekTotals.forEach((k, n) {
      final off = wToOffset[k];
      if (off == null || n <= 0) return;
      final shifted = _shiftIsoWeek(reportYear, reportWeek, off);
      entries.add((year: shifted.year, week: shifted.week, count: n));
    });
    if (entries.isEmpty) return const SizedBox.shrink();
    entries.sort((a, b) {
      final yc = b.year.compareTo(a.year);
      return yc != 0 ? yc : b.week.compareTo(a.week);
    });
    final total = entries.fold<int>(0, (acc, e) => acc + e.count);

    final df = DateFormat('dd.MM.', 'de_DE');
    final dfFull = DateFormat('dd.MM.yyyy', 'de_DE');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            de ? 'BETRÄGE JE WOCHE' : 'AMOUNTS PER WEEK',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'KW ${e.week} · '
                      '${df.format(_isoWeekMonday(e.year, e.week))} \u2013 '
                      '${dfFull.format(_isoWeekMonday(e.year, e.week).add(const Duration(days: 6)))}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF374151),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Text(
                    '${e.count} DNR · ${_eurStr(e.count)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB42318),
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 12, color: Color(0xFFE5E7EB)),
          Row(
            children: [
              Expanded(
                child: Text(
                  de ? 'Gesamt (4 Wochen)' : 'Total (4 weeks)',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                '$total DNR · ${_eurStr(total)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            de
                ? 'Betrag geschätzt: ${_eurFmt.format(kEurPerDnr)} je DNR.'
                : 'Amount estimated: ${_eurFmt.format(kEurPerDnr)} per DNR.',
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

