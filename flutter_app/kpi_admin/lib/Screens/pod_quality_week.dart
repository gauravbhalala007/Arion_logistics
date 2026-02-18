import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';

final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

String _pctStr(num? v) {
  if (v == null) return '—';
  try {
    return '${_pct.format(v)} %';
  } catch (_) {
    return '—';
  }
}

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _int.format(v);
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

class PodQualityWeekPage extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> reportRef;

  const PodQualityWeekPage({super.key, required this.reportRef});

  @override
  State<PodQualityWeekPage> createState() => _PodQualityWeekPageState();
}

class _PodQualityWeekPageState extends State<PodQualityWeekPage> {
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
          final podQuality =
              (summary['podQuality'] as Map?)?.cast<String, dynamic>() ?? {};
          final podSummary =
              (podQuality['summary'] as Map?)?.cast<String, dynamic>() ?? {};
          final podRejects =
              (podQuality['rejects'] as Map?)?.cast<String, dynamic>() ?? {};

          final label = (summary['weekText'] ?? t.t('pod_quality_title'))
              .toString();
          final station =
              (summary['stationCode'] ?? report['stationCode'] ?? '')
                  .toString();

          final opportunities = _num(podSummary['opportunitiesCount']);
          final successPct = _num(podSummary['successPct']);
          final rejectsPct = _num(podSummary['rejectsPct']);

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
                            label: t.t('pod_quality_title'),
                            icon: Icons.photo_camera_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final useRow = constraints.maxWidth >= 540;
                          final tiles = [
                            _StatTile(
                              label: t.t('pod_quality_opp'),
                              value: _intStr(opportunities),
                              tone: _TileTone.neutral,
                            ),
                            _StatTile(
                              label: t.t('pod_quality_success'),
                              value: _pctStr(successPct),
                              tone: _TileTone.good,
                            ),
                            _StatTile(
                              label: t.t('pod_quality_rejects'),
                              value: _pctStr(rejectsPct),
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
                      if (podRejects.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          t.t('pod_quality_rejects_breakdown'),
                          style: TextStyle(
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
                              label: t.t('pod_quality_blurry'),
                              value: _intStr(
                                _num(podRejects['blurryPhotoCount']),
                              ),
                            ),
                            _MiniStat(
                              label: t.t('pod_quality_too_dark'),
                              value: _intStr(
                                _num(podRejects['photoTooDarkCount']),
                              ),
                            ),
                            _MiniStat(
                              label: t.t('pod_quality_no_package'),
                              value: _intStr(
                                _num(podRejects['noPackageDetectedCount']),
                              ),
                            ),
                            _MiniStat(
                              label: t.t('pod_quality_in_car'),
                              value: _intStr(
                                _num(podRejects['packageInCarCount']),
                              ),
                            ),
                            _MiniStat(
                              label: t.t('pod_quality_too_close'),
                              value: _intStr(
                                _num(podRejects['packageTooCloseCount']),
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
                              (d) => (d.data()['podQuality'] as Map?) != null,
                            )
                            .toList();

                        if (rows.isEmpty) {
                          return Center(
                            child: Text(t.t('pod_quality_no_data_week')),
                          );
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                              child: Row(
                                children: [
                                  Text(
                                    t.t('pod_quality_drivers'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _SectionTag(
                                    label: t.tf('pod_quality_entries_count', {
                                      'count': '${rows.length}',
                                    }),
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
                                  final pod =
                                      (data['podQuality'] as Map?)
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

                                  final opportunities =
                                      _num(pod['opportunities']) ?? 0;
                                  final success = _num(pod['success']) ?? 0;
                                  final bypass = _num(pod['bypass']) ?? 0;
                                  final rejects = _num(pod['rejects']) ?? 0;

                                  final successPct = opportunities > 0
                                      ? (success / opportunities) * 100.0
                                      : null;
                                  final rejectsPct = opportunities > 0
                                      ? (rejects / opportunities) * 100.0
                                      : null;

                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
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
                                              noNameText: t.t('dash_no_name'),
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
                                                      color: Color(0xFF111827),
                                                    ),
                                                  ),
                                                  if (transporterId.isNotEmpty)
                                                    Text(
                                                      transporterId,
                                                      style: const TextStyle(
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
                                                    'pod_quality_success',
                                                  ),
                                                  value: _pctStr(successPct),
                                                  tone: _TileTone.good,
                                                ),
                                                const SizedBox(height: 6),
                                                _StatPill(
                                                  label: t.t(
                                                    'pod_quality_rejects',
                                                  ),
                                                  value: _pctStr(rejectsPct),
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
                                              label: t.t('pod_quality_opp'),
                                              value: _intStr(opportunities),
                                            ),
                                            _MiniStat(
                                              label: t.t('pod_quality_success'),
                                              value: _intStr(success),
                                            ),
                                            _MiniStat(
                                              label: t.t('pod_quality_bypass'),
                                              value: _intStr(bypass),
                                            ),
                                            _MiniStat(
                                              label: t.t('pod_quality_rejects'),
                                              value: _intStr(rejects),
                                            ),
                                            _MiniStat(
                                              label: t.t('pod_quality_blurry'),
                                              value: _intStr(
                                                _num(pod['blurryPhoto']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'pod_quality_too_dark',
                                              ),
                                              value: _intStr(
                                                _num(pod['photoTooDark']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'pod_quality_no_package',
                                              ),
                                              value: _intStr(
                                                _num(pod['noPackageDetected']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t('pod_quality_in_car'),
                                              value: _intStr(
                                                _num(pod['packageInCar']),
                                              ),
                                            ),
                                            _MiniStat(
                                              label: t.t(
                                                'pod_quality_too_close',
                                              ),
                                              value: _intStr(
                                                _num(pod['packageTooClose']),
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
    final parts = trimmed.split(RegExp(r'\\s+')).where((p) => p.isNotEmpty);
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
