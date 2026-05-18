import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';

final _intFmt = NumberFormat.decimalPattern('de');

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

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('reportRef', isEqualTo: widget.reportRef)
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
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    station,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _SectionTag(
                            label: t.t('concessions_title'),
                            icon: Icons.report_gmailerrorred_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final useRow = constraints.maxWidth >= 540;
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
                          ];

                          if (useRow) {
                            return Row(
                              children: [
                                Expanded(child: tiles[0]),
                                const SizedBox(width: 12),
                                Expanded(child: tiles[1]),
                                const SizedBox(width: 12),
                                Expanded(child: tiles[2]),
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
                          children: [
                            _MiniStat(
                              label: t.t('concessions_focus_attended_dnr'),
                              value: _intStr(
                                _num(concFocus['attendedDnr']),
                              ),
                            ),
                            _MiniStat(
                              label: t.t(
                                'concessions_focus_photo_on_delivery',
                              ),
                              value: _intStr(
                                _num(concFocus['photoOnDelivery']),
                              ),
                            ),
                            _MiniStat(
                              label: t.t(
                                'concessions_focus_successful_contact',
                              ),
                              value: _intStr(
                                _num(concFocus['successfulContact']),
                              ),
                            ),
                            _MiniStat(
                              label:
                                  t.t('concessions_focus_delivered_25m'),
                              value: _intStr(
                                _num(concFocus['delivered25m']),
                              ),
                            ),
                            _MiniStat(
                              label: t.t('concessions_focus_false_scan'),
                              value: _intStr(_num(concFocus['falseScan'])),
                            ),
                            _MiniStat(
                              label: t.t('concessions_focus_mailbox'),
                              value: _intStr(_num(concFocus['mailbox'])),
                            ),
                            _MiniStat(
                              label:
                                  t.t('concessions_focus_delivered_otp'),
                              value: _intStr(
                                _num(concFocus['deliveredOtp']),
                              ),
                            ),
                          ],
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
                        final rows = docs
                            .where(
                              (d) =>
                                  (d.data()['concessions'] as Map?) != null,
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

                        return Column(
                          children: [
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
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                _StatPill(
                                                  label: t.t(
                                                    'concessions_dnr_count',
                                                  ),
                                                  value: _intStr(totalDnr),
                                                  tone: _TileTone.warn,
                                                ),
                                                const SizedBox(height: 6),
                                                _StatPill(
                                                  label: t.t(
                                                    'concessions_dnr_dpmo_4w',
                                                  ),
                                                  value: _intStr(dpmo4w),
                                                  tone: _TileTone.warn,
                                                ),
                                              ],
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
                                            _MiniStat(
                                              label: t.tf(
                                                'concessions_week_w',
                                                {'week': '1'},
                                              ),
                                              value: _intStr(
                                                _num(byWeek['w1']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.tf(
                                                'concessions_week_w',
                                                {'week': '2'},
                                              ),
                                              value: _intStr(
                                                _num(byWeek['w2']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.tf(
                                                'concessions_week_w',
                                                {'week': '3'},
                                              ),
                                              value: _intStr(
                                                _num(byWeek['w3']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.tf(
                                                'concessions_week_w',
                                                {'week': '4'},
                                              ),
                                              value: _intStr(
                                                _num(byWeek['w4']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_focus_attended_dnr',
                                              ),
                                              value: _intStr(
                                                _num(focus['attendedDnr']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_focus_photo_on_delivery',
                                              ),
                                              value: _intStr(
                                                _num(
                                                  focus['photoOnDelivery'],
                                                ),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_focus_successful_contact',
                                              ),
                                              value: _intStr(
                                                _num(
                                                  focus[
                                                      'successfulContact'],
                                                ),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_focus_delivered_25m',
                                              ),
                                              value: _intStr(
                                                _num(focus['delivered25m']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_focus_false_scan',
                                              ),
                                              value: _intStr(
                                                _num(focus['falseScan']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_focus_mailbox',
                                              ),
                                              value: _intStr(
                                                _num(focus['mailbox']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'concessions_focus_delivered_otp',
                                              ),
                                              value: _intStr(
                                                _num(focus['deliveredOtp']),
                                              ),
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

enum _TileTone { neutral, good, warn }

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
