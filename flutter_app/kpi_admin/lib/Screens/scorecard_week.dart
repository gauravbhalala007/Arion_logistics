// lib/Screens/scorecard_week.dart
//
// Score Card — Wochendetailseite. Apple-Style nach CoDriver-Styleguide:
//  • Inter durchgehend via AppTypography
//  • Hero-Karte (codriverGreen) für den Company-Score
//  • Weiße Sekundär-Tiles für Reliability + Rank
//  • Filter-Bar mit Search-Pille + Status-Pille + Upload-Button
//  • Driver-Cards mit Tier-Pill, klarer Score-Headline, KPI-Grid
//
// Datenfluss bleibt: report/{id}, users/{adminUid}/scores, driverNames.

import '../services/driver_csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';

final _pct = NumberFormat.decimalPattern('de');
final _int = NumberFormat.decimalPattern('de');

// ---- tiny helpers ----
String _s(dynamic v) => (v == null) ? '' : v.toString();
String _normTid(dynamic v) => DriverCsvService.normalizeTransporterId(_s(v));

String _pctStr(num? v) {
  if (v == null) return '—';
  try {
    return '${_pct.format(v)} %';
  } catch (_) {
    return '—';
  }
}

double _ceDisplayPenalty(num? ceCount) {
  final count = (ceCount ?? 0).toDouble();
  if (count <= 0) return 100.0;
  return -(50.0 * count);
}

String _ceDisplayStr(num? ceCount) => _pctStr(_ceDisplayPenalty(ceCount));

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _int.format(v);
  } catch (_) {
    return '—';
  }
}

double _numOr0(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim().replaceAll('%', '');
    return double.tryParse(s.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}

Map<String, dynamic> _strMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    try {
      return Map<String, dynamic>.from(v);
    } catch (_) {
      final out = <String, dynamic>{};
      v.forEach((k, val) => out['$k'] = val);
      return out;
    }
  }
  return <String, dynamic>{};
}

class ScorecardWeekPage extends StatefulWidget {
  const ScorecardWeekPage({super.key, required this.reportRef});
  final DocumentReference<Map<String, dynamic>> reportRef;

  @override
  State<ScorecardWeekPage> createState() => _ScorecardWeekPageState();
}

class _ScorecardWeekPageState extends State<ScorecardWeekPage> {
  bool _busyUpload = false;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _reportStream;

  String _query = '';
  String _bucket = 'ALL';
  static const _bucketItems = <String>[
    'ALL',
    'FANTASTIC_PLUS',
    'FANTASTIC',
    'GREAT',
    'FAIR',
    'POOR',
  ];

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores() {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .where('reportId', isEqualTo: widget.reportRef.id)
        .snapshots()
        .map((s) => s.docs);
  }

  Stream<Map<String, String>> _driverNamesForWeek() {
    return widget.reportRef.collection('driverNames').snapshots().map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = _strMap(d.data());
        final id = _normTid(data['transporterId'] ?? d.id);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  Stream<Map<String, String>> _driversNameMapGlobal() {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(const <String, String>{});
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
          final m = <String, String>{};
          for (final d in snap.docs) {
            final data = d.data();
            final id = _normTid(data['transporterId'] ?? d.id);
            final name = _s(data['driverName']);
            if (id.isNotEmpty) m[id] = name;
          }
          return m;
        });
  }

  @override
  void initState() {
    super.initState();
    _reportStream = widget.reportRef.snapshots();
  }

  String _prettyBucket(String raw) {
    switch (_s(raw).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return 'Fantastic+';
      case 'FANTASTIC':
        return 'Fantastic';
      case 'GREAT':
        return 'Great';
      case 'FAIR':
        return 'Fair';
      case 'POOR':
        return 'Poor';
      default:
        return _s(raw);
    }
  }

  Color _tierColor(String apiBucket) {
    switch (_s(apiBucket).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return AppColors.tierFantasticPlus;
      case 'FANTASTIC':
        return AppColors.tierFantastic;
      case 'GREAT':
        return AppColors.tierGreat;
      case 'FAIR':
        return AppColors.tierFair;
      case 'POOR':
        return AppColors.tierPoor;
      default:
        return AppColors.labelTertiaryLight;
    }
  }

  Future<void> _uploadDriverCsv() async {
    final t = AppLocalizations.of(context);
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
      if (bytes == null) {
        throw Exception(t.t('scorecard_overview_no_file_bytes'));
      }

      final uid = AdminScope.adminUidOf(context) ??
          FirebaseAuth.instance.currentUser?.uid ??
          '';
      final result = await DriverCsvService.importForUser(
        uid: uid,
        csvBytes: bytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t.t('scorecard_overview_csv_updated')} '
            'Parsed ${result.parsedRows}, '
            'matched ${result.mappedDrivers}, '
            'new ${result.newDrivers}, '
            'score rows updated ${result.updatedScores}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.tf('scorecard_overview_csv_failed', {'error': '$e'})),
        ),
      );
    } finally {
      if (mounted) setState(() => _busyUpload = false);
    }
  }

  Future<void> _openReassignDialog({required String unmatchedTid}) async {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || unmatchedTid.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ReassignDriverDialog(
        dspUid: uid,
        unmatchedTid: unmatchedTid,
        reportRef: widget.reportRef,
      ),
    );
  }

  String _isoWeekRange(int year, int week) {
    final jan4 = DateTime(year, 1, 4);
    final jan4IsoWeekday = (jan4.weekday + 6) % 7;
    final mondayW1 = jan4.subtract(Duration(days: jan4IsoWeekday));
    final monday = mondayW1.add(Duration(days: (week - 1) * 7));
    final sunday = monday.add(const Duration(days: 6));
    final df = DateFormat('dd.MM.yyyy');
    return '${df.format(monday)} – ${df.format(sunday)}';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 800;
    final padH = isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: EdgeInsets.fromLTRB(padH, isMobile ? 8 : 16, padH, 80),
              children: [
                _buildHeroStrip(isMobile),
                const SizedBox(height: 18),
                _buildFilterBar(isMobile),
                const SizedBox(height: 18),
                _buildDriversList(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Hero KPI strip (Company Score · Reliability · Rank)
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildHeroStrip(bool isMobile) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _reportStream,
      builder: (context, snap) {
        final data = snap.data?.data() ?? const <String, dynamic>{};
        final summary = _strMap(data['summary']);

        final overall = (summary['overallScore'] as num?)?.toDouble();
        final overallStatus = _s(summary['overallStatus']);
        final relNext = (summary['reliabilityNextDay'] as num?)?.toDouble();
        final relGeneric =
            (summary['reliabilityScore'] as num?)?.toDouble();
        final reliability = relNext ?? relGeneric;
        final rank = (summary['rankAtStation'] as num?)?.toInt();
        final stationCount = (summary['stationCount'] as num?)?.toInt();
        final station =
            _s(summary['stationCode'] ?? data['stationCode']).toUpperCase();

        final rankText = rank == null
            ? '—'
            : (stationCount != null && stationCount > 0
                ? '#$rank / $stationCount'
                : '#$rank');

        final tierColor = _tierColor(overallStatus);

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 168,
                child: _HeroCompanyCard(
                  score: overall,
                  tierColor: tierColor,
                  tierLabel: _prettyBucket(overallStatus),
                ),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _StatTile(
                        label:
                            t.t('scorecard_overview_reliability_score'),
                        value: reliability == null
                            ? '—'
                            : '${_pct.format(reliability)} %',
                        sub: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        label: t.t('dash_rank_in_station'),
                        value: rankText,
                        sub: station,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return SizedBox(
          height: 168,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: _HeroCompanyCard(
                  score: overall,
                  tierColor: tierColor,
                  tierLabel: _prettyBucket(overallStatus),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _StatTile(
                  label: t.t('scorecard_overview_reliability_score'),
                  value: reliability == null
                      ? '—'
                      : '${_pct.format(reliability)} %',
                  sub: '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _StatTile(
                  label: t.t('dash_rank_in_station'),
                  value: rankText,
                  sub: station,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Filter Bar
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildFilterBar(bool isMobile) {
    final t = AppLocalizations.of(context);

    final search = SizedBox(
      height: 44,
      child: TextField(
        style: AppTypography.subheadline.copyWith(
          color: AppColors.codriverGraphite,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceElevatedLight,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.labelSecondaryLight,
            size: 20,
          ),
          hintText: t.t('dash_search_name_or_id'),
          hintStyle: AppTypography.subheadline.copyWith(
            color: AppColors.labelTertiaryLight,
            fontWeight: FontWeight.w500,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 0.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 0.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.codriverGreen, width: 1.4),
          ),
        ),
        onChanged: (s) => setState(() => _query = s.trim()),
      ),
    );

    final bucketDropdown = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.surfaceElevatedLight,
          borderRadius: BorderRadius.circular(12),
          value: _bucketItems.contains(_bucket) ? _bucket : 'ALL',
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.codriverDeep),
          style: AppTypography.subheadline.copyWith(
            color: AppColors.codriverDeep,
            fontWeight: FontWeight.w700,
          ),
          items: [
            DropdownMenuItem(
                value: 'ALL', child: Text(t.t('dash_all_status'))),
            for (final v in _bucketItems.skip(1))
              DropdownMenuItem(value: v, child: Text(_prettyBucket(v))),
          ],
          onChanged: (v) => setState(() => _bucket = v ?? 'ALL'),
        ),
      ),
    );

    final uploadBtn = CoButton(
      onPressed: _busyUpload ? null : _uploadDriverCsv,
      icon: Icons.upload_rounded,
      label: _busyUpload
          ? t.t('uploading')
          : t.t('dash_upload_driver_csv'),
      busy: _busyUpload,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: bucketDropdown),
              const SizedBox(width: 8),
              uploadBtn,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: search),
        const SizedBox(width: 10),
        bucketDropdown,
        const SizedBox(width: 10),
        uploadBtn,
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Drivers list
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildDriversList(bool isMobile) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<Map<String, String>>(
      stream: _driverNamesForWeek(),
      builder: (context, weekNamesSnap) {
        final weekNames = weekNamesSnap.data ?? const <String, String>{};
        return StreamBuilder<Map<String, String>>(
          stream: _driversNameMapGlobal(),
          builder: (context, globalNamesSnap) {
            final globalNames =
                globalNamesSnap.data ?? const <String, String>{};
            final nameMap = <String, String>{}
              ..addAll(globalNames)
              ..addAll(weekNames);

            return StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _scores(),
              builder: (context, scoreSnap) {
                if (scoreSnap.connectionState == ConnectionState.waiting) {
                  return const CoStateSwitcher(
                    child: Padding(
                      key: ValueKey('drivers-loading'),
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.codriverGreen,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                var docs = scoreSnap.data ?? [];
                if (docs.isEmpty) {
                  return CoStateSwitcher(
                    child: _EmptyState(
                      key: const ValueKey('drivers-empty-period'),
                      label: t.t('dash_no_scores_period'),
                    ),
                  );
                }

                if (_bucket != 'ALL') {
                  docs = docs.where((d) {
                    final b = _s(d.data()['statusBucket']).toUpperCase();
                    return b == _bucket;
                  }).toList();
                }

                final q = _query.toLowerCase();
                if (q.isNotEmpty) {
                  docs = docs.where((d) {
                    final normalizedId =
                        _normTid(d.data()['transporterId']);
                    final id = normalizedId.toLowerCase();
                    final name =
                        _s(nameMap[normalizedId]).toLowerCase();
                    return id.contains(q) || name.contains(q);
                  }).toList();
                }

                final hasAnyRank =
                    docs.any((d) => (d.data()['rank'] != null));
                docs.sort((a, b) {
                  if (hasAnyRank) {
                    final ra =
                        (a.data()['rank'] as num?)?.toInt() ?? 999999;
                    final rb =
                        (b.data()['rank'] as num?)?.toInt() ?? 999999;
                    return ra.compareTo(rb);
                  }
                  final ca = _strMap(a.data()['comp']);
                  final cb = _strMap(b.data()['comp']);
                  final fa = _numOr0(ca['FinalScore']);
                  final fb = _numOr0(cb['FinalScore']);
                  return fb.compareTo(fa);
                });

                if (docs.isEmpty) {
                  return CoStateSwitcher(
                    child: _EmptyState(
                      key: const ValueKey('drivers-empty-filter'),
                      label: t.t('dash_no_drivers_match'),
                    ),
                  );
                }

                return CoStateSwitcher(
                  child: Column(
                  key: const ValueKey('drivers-loaded'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            t.t('drivers_hub_title').toUpperCase(),
                            style: AppTypography.caption2.copyWith(
                              color: AppColors.labelSecondaryLight,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.codriverGreen
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${docs.length}',
                              style: AppTypography.caption2.copyWith(
                                color: AppColors.codriverDeep,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (var i = 0; i < docs.length; i++) ...[
                      _DriverCard(
                        data: docs[i].data(),
                        nameMap: nameMap,
                        isMobile: isMobile,
                        prettyBucket: _prettyBucket,
                        tierColor: _tierColor,
                        onAssignTid: () => _openReassignDialog(
                          unmatchedTid: _s(
                            docs[i].data()['transporterId'],
                          ).trim(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  Hero Company Score Card (grüner Marken-Hero)
// ════════════════════════════════════════════════════════════════════════

class _HeroCompanyCard extends StatelessWidget {
  final double? score;
  final Color tierColor;
  final String tierLabel;
  const _HeroCompanyCard({
    required this.score,
    required this.tierColor,
    required this.tierLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.codriverGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppElevation.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.t('admin_home_company_score').toUpperCase(),
                  style: AppTypography.caption2.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (tierLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tierLabel.toUpperCase(),
                    style: AppTypography.caption2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: score != null ? _pct.format(score) : '—',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 60,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.4,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      TextSpan(
                        text: '  %',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  Stat Tile (white)
// ════════════════════════════════════════════════════════════════════════

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _StatTile({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.title1.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -0.6,
              ),
            ),
          ),
          if (sub.isNotEmpty)
            Text(
              sub,
              style: AppTypography.caption1.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  Driver Card
// ════════════════════════════════════════════════════════════════════════

class _DriverCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, String> nameMap;
  final bool isMobile;
  final String Function(String raw) prettyBucket;
  final Color Function(String raw) tierColor;
  final VoidCallback? onAssignTid;

  const _DriverCard({
    required this.data,
    required this.nameMap,
    required this.isMobile,
    required this.prettyBucket,
    required this.tierColor,
    this.onAssignTid,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final compRaw = data['comp'];
    final kpisRaw = data['kpis'];
    final comp = compRaw is Map
        ? Map<String, dynamic>.from(compRaw as Map)
        : <String, dynamic>{};
    final kpis = kpisRaw is Map
        ? Map<String, dynamic>.from(kpisRaw as Map)
        : <String, dynamic>{};

    final transporterId = _s(data['transporterId']).trim();
    final normalizedTid = _normTid(transporterId);
    final mappedName = _s(nameMap[normalizedTid]);
    final isUnmatched = mappedName.isEmpty;
    final name = isUnmatched ? t.t('dash_no_name') : mappedName;

    final score = _numOr0(comp['FinalScore']);
    final dcr = _numOr0(comp['DCR_Score']);
    final pod = _numOr0(comp['POD_Score']);
    final cc = _numOr0(comp['CC_Score']);
    final ceCount =
        _numOr0(kpis['CE'] ?? kpis['CE %'] ?? kpis['CE_PCT']);
    final delivered = _numOr0(
        kpis['Delivered'] ?? kpis['DELIVERED'] ?? kpis['delivered']);
    final dnr = _numOr0(kpis['DNR'] ?? kpis['DNR DPMO']);
    final lor = _numOr0(kpis['LoR'] ?? kpis['LoR DPMO']);
    final cdf = _numOr0(kpis['CDF'] ?? kpis['CDF DPMO']);

    final rank = (data['rank'] as num?)?.toInt();
    final apiBucketRaw = _s(data['statusBucket']);
    final tier = tierColor(apiBucketRaw);
    final tierText = prettyBucket(apiBucketRaw);

    final kpis8 = <_Kpi>[
      _Kpi('Delivered', _intStr(delivered.round())),
      _Kpi('DCR', _pctStr(dcr)),
      _Kpi('DSC DPMO', _intStr(dnr.round())),
      _Kpi('LoR DPMO', _intStr(lor.round())),
      _Kpi('POD', _pctStr(pod)),
      _Kpi('CC', _pctStr(cc)),
      _Kpi('CE', _ceDisplayStr(ceCount)),
      _Kpi('CDF DPMO', _intStr(cdf.round())),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppElevation.level1,
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 18,
        vertical: isMobile ? 14 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top row: rank badge + name + tier pill + score ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RankBadge(rank: rank, tierColor: tier),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.codriverDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            transporterId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.labelSecondaryLight,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tier.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tierText.toUpperCase(),
                            style: AppTypography.caption2.copyWith(
                              color: tier,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (isUnmatched && onAssignTid != null) ...[
                          const SizedBox(width: 6),
                          CoPressable(
                            onTap: onAssignTid,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.codriverGreen,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Zuordnen',
                                    style:
                                        AppTypography.caption2.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SCORE',
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.labelSecondaryLight,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _pctStr(score),
                    style: AppTypography.title3.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5E5EA)),
          const SizedBox(height: 12),
          // ── KPI grid ──
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 720
                  ? 8
                  : c.maxWidth >= 520
                      ? 4
                      : c.maxWidth >= 360
                          ? 4
                          : 2;
              const gap = 12.0;
              final cellW = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: 12,
                children: [
                  for (final k in kpis8)
                    SizedBox(
                      width: cellW,
                      child: _KpiCell(label: k.label, value: k.value),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  _Kpi(this.label, this.value);
}

class _KpiCell extends StatelessWidget {
  final String label;
  final String value;
  const _KpiCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption2.copyWith(
            color: AppColors.labelSecondaryLight,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.codriverDeep,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int? rank;
  final Color tierColor;
  const _RankBadge({required this.rank, required this.tierColor});

  @override
  Widget build(BuildContext context) {
    if (rank == null) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E5EA)),
        ),
        alignment: Alignment.center,
        child: Text(
          '—',
          style: AppTypography.subheadline.copyWith(
            color: AppColors.labelTertiaryLight,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: AppTypography.subheadline.copyWith(
          color: tierColor,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.green50,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.codriverDeep,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.labelSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Reassign Dialog ─────────────────────────────────────────────────
//
// Opens from a scorecard row whose Transporter-ID does not match any of
// the admin's drivers. Lists drivers with `tidPending: true` (their TID
// is still a generated PENDING-XXXXXX placeholder). Picking one writes
// the real TID onto that driver and refreshes the report's driverNames
// map so the row immediately shows the correct name.
class _ReassignDriverDialog extends StatelessWidget {
  final String dspUid;
  final String unmatchedTid;
  final DocumentReference<Map<String, dynamic>> reportRef;

  const _ReassignDriverDialog({
    required this.dspUid,
    required this.unmatchedTid,
    required this.reportRef,
  });

  @override
  Widget build(BuildContext context) {
    final mediaW = MediaQuery.of(context).size.width;
    final dialogW = mediaW < 480 ? mediaW - 32 : 460.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogW, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TID zuordnen',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Wähle den Fahrer, zu dem die TID '
                '$unmatchedTid '
                'gehört. Die TID wird beim Fahrer gespeichert und '
                'die Scorecard wird neu gematcht.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(dspUid)
                      .collection('drivers')
                      .where('tidPending', isEqualTo: true)
                      .snapshots(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.codriverGreen,
                            ),
                          ),
                        ),
                      );
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Keine Fahrer mit ausstehender TID gefunden. '
                          'Lege den Fahrer im Drivers Hub neu an, '
                          'ohne TID einzutragen.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      );
                    }
                    docs.sort((a, b) {
                      final an =
                          (a.data()['driverName'] ?? '').toString();
                      final bn =
                          (b.data()['driverName'] ?? '').toString();
                      return an.toLowerCase().compareTo(bn.toLowerCase());
                    });
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (ctx, i) {
                        final d = docs[i];
                        final data = d.data();
                        final name =
                            (data['driverName'] ?? '').toString();
                        final placeholderTid = d.id;
                        return _PendingDriverTile(
                          name: name.isEmpty ? 'Ohne Name' : name,
                          placeholderTid: placeholderTid,
                          onTap: () => _assign(
                            context,
                            driverDoc: d.reference,
                            driverName: name,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: CoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Abbrechen',
                  variant: CoButtonVariant.quiet,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _assign(
    BuildContext context, {
    required DocumentReference<Map<String, dynamic>> driverDoc,
    required String driverName,
  }) async {
    final realTid = unmatchedTid.trim().toUpperCase();
    if (realTid.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // Update the driver doc: real TID + flip tidPending off.
      await driverDoc.set({
        'transporterId': realTid,
        'tidPending': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Write the name into the report's driverNames subcollection so
      // this week's scorecard rows render the driver name immediately.
      await reportRef
          .collection('driverNames')
          .doc(realTid)
          .set({
        'transporterId': realTid,
        'driverName': driverName,
        'assignedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('TID $realTid → $driverName zugeordnet.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Fehler beim Zuordnen: $e')),
      );
    }
  }
}

class _PendingDriverTile extends StatelessWidget {
  final String name;
  final String placeholderTid;
  final VoidCallback onTap;

  const _PendingDriverTile({
    required this.name,
    required this.placeholderTid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CoPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E5EA)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person_rounded,
                  size: 18, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    placeholderTid,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.3,
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
    );
  }
}

