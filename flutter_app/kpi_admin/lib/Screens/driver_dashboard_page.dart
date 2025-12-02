// lib/Screens/driver_dashboard_page.dart
//
// Driver home page:
// - Shows latest scorecard week for the DSP the driver belongs to
// - UI closely follows scorecard_week.dart (summary + full ranking list)
// - Drivers see ALL drivers of that DSP for the latest report.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_shell.dart';
import '../widgets/driver_side_menu.dart';
import 'driver_onboarding_page.dart';   // 🔹 use your existing onboarding form

// ---------- small helpers (same logic as in scorecard_week.dart) ----------

String _s(dynamic v) => (v == null) ? '' : v.toString();

num _numOr0(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is String) {
    final s = v.trim().replaceAll('%', '');
    return num.tryParse(s.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}

// ==========================================================================
// 1) DriverDashboardPage: entry from AuthGate
// ==========================================================================

class DriverDashboardPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId; // not used for filtering, only for context

  const DriverDashboardPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  // 🔹 which tab is active in the driver portal (Scorecard / Onboarding)
  DriverNav _activeTab = DriverNav.dashboard;

  @override
  Widget build(BuildContext context) {
    // 🔹 this is where the driver's onboarding data lives
    final driverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(widget.driverTransporterId.toUpperCase());

    return AppShell(
      menuWidth: 280,
      sideMenu: DriverSideMenu(
        width: 280,
        active: _activeTab,
        // 🔹 when user clicks Scorecard / Onboarding
        onNav: (nav) {
          setState(() {
            _activeTab = nav;
          });
        },
      ),
      title: Text(
        _activeTab == DriverNav.dashboard
            ? 'SCORE CARD DASHBOARD'
            : 'ONBOARDING',
      ),
      body: Container(
        color: const Color(0xFFF5F7F9),
        padding: const EdgeInsets.all(18),
        // 🔹 switch body based on active tab
        child: _activeTab == DriverNav.dashboard
            ? _buildLatestWeek()
            : DriverOnboardingPage(driverRef: driverRef),
      ),
    );
  }

  /// Loads the latest report for this DSP and shows the full week scorecard.
  Widget _buildLatestWeek() {
    final reportsQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('reports')
        .orderBy('year', descending: true)
        .orderBy('weekNumber', descending: true)
        .limit(1);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reportsQuery.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error loading reports: ${snap.error}'),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Your DSP has not uploaded any scorecard reports yet.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final reportDoc = docs.first;
        return _DriverWeekScorecard(
          dspUid: widget.dspUid,
          reportRef: reportDoc.reference,
        );
      },
    );
  }
}

// ==========================================================================
// 2) _DriverWeekScorecard: same UI concept as scorecard_week.dart,
//    but read-only and scoped to dspUid + latest report.
// ==========================================================================

class _DriverWeekScorecard extends StatefulWidget {
  final String dspUid;
  final DocumentReference<Map<String, dynamic>> reportRef;

  const _DriverWeekScorecard({
    required this.dspUid,
    required this.reportRef,
  });

  @override
  State<_DriverWeekScorecard> createState() => _DriverWeekScorecardState();
}

class _DriverWeekScorecardState extends State<_DriverWeekScorecard> {
  String _query = '';
  String _bucket = 'ALL'; // ALL | FANTASTIC_PLUS | FANTASTIC | GREAT | FAIR | POOR

  static const _bucketItems = <String>[
    'ALL',
    'FANTASTIC_PLUS',
    'FANTASTIC',
    'GREAT',
    'FAIR',
    'POOR',
  ];

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _scores() {
    // IMPORTANT: use dspUid, not currentUser.uid
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('scores')
        .where('reportRef', isEqualTo: widget.reportRef)
        .snapshots()
        .map((s) => s.docs);
  }

  /// Per-week driver names under reports/{reportId}/driverNames
  Stream<Map<String, String>> _driverNamesForWeek() {
    return widget.reportRef.collection('driverNames').snapshots().map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final id = _s(data['transporterId'] ?? d.id);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  /// DSP-scoped driver master data: users/{dspUid}/drivers
  Stream<Map<String, String>> _driversNameMapGlobal() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .snapshots()
        .map((snap) {
      final m = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final id = _s(data['transporterId']);
        final name = _s(data['driverName']);
        if (id.isNotEmpty) m[id] = name;
      }
      return m;
    });
  }

  String _statusText(double v) {
    if (v >= 85) return 'Fantastic';
    if (v >= 70) return 'Great';
    if (v >= 55) return 'Fair';
    return 'Poor';
  }

  Color _statusColor(double v) {
    if (v >= 85) return const Color(0xFF16A34A);
    if (v >= 70) return const Color(0xFF22C55E);
    if (v >= 55) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _prettyBucket(String raw) {
    switch (_s(raw).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
        return 'Fantastic Plus';
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

  Color _colorFromApiBucket(String apiBucket) {
    switch (_s(apiBucket).trim().toUpperCase()) {
      case 'FANTASTIC_PLUS':
      case 'FANTASTIC':
        return const Color(0xFF16A34A);
      case 'GREAT':
        return const Color(0xFF22C55E);
      case 'FAIR':
        return const Color(0xFFF59E0B);
      case 'POOR':
      default:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 1000;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Title + date + search / bucket ----------
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: widget.reportRef.snapshots(),
              builder: (context, snap) {
                final report = snap.data?.data() ?? <String, dynamic>{};
                final summaryRaw = report['summary'];
                final summary = summaryRaw is Map
                    ? Map<String, dynamic>.from(summaryRaw as Map)
                    : <String, dynamic>{};

                final weekNumber =
                    (summary['weekNumber'] as num?)?.toInt() ??
                        (report['weekNumber'] as num?)?.toInt();
                final year = (summary['year'] as num?)?.toInt() ??
                    (report['year'] as num?)?.toInt();

                String range = '';
                if (weekNumber != null && year != null) {
                  // keep range simple here
                  range = 'Week $weekNumber, $year';
                }

                final title = Text(
                  weekNumber != null
                      ? 'SCORECARD WEEK $weekNumber'
                      : 'SCORECARD WEEK',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                );

                final dateLbl = Text(
                  range,
                  style: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w600),
                );

                final controls = Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    SizedBox(
                      width: isCompact ? width - 36 : 340,
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search name or Transporter ID…',
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        onChanged: (s) => setState(() {
                          _query = s.trim().toLowerCase();
                        }),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _bucketItems.contains(_bucket)
                              ? _bucket
                              : 'ALL',
                          items: const [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text('All Status'),
                            ),
                            DropdownMenuItem(
                              value: 'FANTASTIC_PLUS',
                              child: Text('Fantastic Plus'),
                            ),
                            DropdownMenuItem(
                              value: 'FANTASTIC',
                              child: Text('Fantastic'),
                            ),
                            DropdownMenuItem(
                              value: 'GREAT',
                              child: Text('Great'),
                            ),
                            DropdownMenuItem(
                              value: 'FAIR',
                              child: Text('Fair'),
                            ),
                            DropdownMenuItem(
                              value: 'POOR',
                              child: Text('Poor'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _bucket = v ?? 'ALL'),
                        ),
                      ),
                    ),
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 4),
                      dateLbl,
                      const SizedBox(height: 12),
                      controls,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: 4),
                          dateLbl,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: controls),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            // ---------- Summary cards ----------
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: widget.reportRef.snapshots(),
              builder: (context, snap) {
                final report = snap.data?.data() ?? <String, dynamic>{};
                final summaryRaw = report['summary'];
                final summary = summaryRaw is Map
                    ? Map<String, dynamic>.from(summaryRaw as Map)
                    : <String, dynamic>{};

                final overall =
                    (summary['overallScore'] as num?)?.toDouble() ?? 0;
                final relNext =
                    (summary['reliabilityNextDay'] as num?)?.toDouble();
                final relGeneric =
                    (summary['reliabilityScore'] as num?)?.toDouble();
                final reliability = relNext ?? relGeneric;

                final rankAtStation =
                    (summary['rankAtStation'] as num?)?.toInt();
                final stationCount =
                    (summary['stationCount'] as num?)?.toInt();
                final stationName =
                    _s(summary['stationCode'] ?? report['stationCode']);

                String rankText = '—';
                if (rankAtStation != null) {
                  rankText = '$rankAtStation';
                  if (stationCount != null && stationCount > 0) {
                    rankText += ' of $stationCount';
                  }
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, cns) {
                        final maxW = cns.maxWidth;
                        final cols =
                            maxW >= 900 ? 3 : (maxW >= 600 ? 2 : 1);
                        final gap = 16.0;
                        final childW =
                            (maxW - gap * (cols - 1)) / cols;

                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            SizedBox(
                              width: childW,
                              child: _SummaryPanel(
                                title: 'TOTAL COMPANY SCORE',
                                big: overall == 0
                                    ? '—'
                                    : '${overall.toStringAsFixed(2)} %',
                                small: overall == 0
                                    ? ''
                                    : _statusText(overall),
                                accent: const Color(0xFF16A34A),
                              ),
                            ),
                            SizedBox(
                              width: childW,
                              child: _SummaryPanel(
                                title: 'RANK IN STATION',
                                big: rankText,
                                small: stationName,
                                accent: Colors.black87,
                              ),
                            ),
                            SizedBox(
                              width: childW,
                              child: _SummaryPanel(
                                title: 'RELIABILITY SCORE',
                                big: reliability == null
                                    ? '—'
                                    : '${reliability.toStringAsFixed(2)} %',
                                small: reliability == null
                                    ? ''
                                    : _statusText(reliability),
                                accent: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // ---------- Drivers list (FULL RANKING) ----------
            StreamBuilder<Map<String, String>>(
              stream: _driverNamesForWeek(),
              builder: (context, weekSnap) {
                final weekNames =
                    weekSnap.data ?? const <String, String>{};

                return StreamBuilder<Map<String, String>>(
                  stream: _driversNameMapGlobal(),
                  builder: (context, globalSnap) {
                    final globalNames =
                        globalSnap.data ?? const <String, String>{};

                    final nameMap = <String, String>{}
                      ..addAll(globalNames)
                      ..addAll(weekNames);

                    return StreamBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      stream: _scores(),
                      builder: (context, scoreSnap) {
                        if (scoreSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var docs = scoreSnap.data ?? [];
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                                'No scores for this week yet.'),
                          );
                        }

                        // filter by status bucket
                        if (_bucket != 'ALL') {
                          docs = docs.where((d) {
                            final b = _s(d.data()['statusBucket'])
                                .toUpperCase();
                            return b == _bucket;
                          }).toList();
                        }

                        // search filter
                        if (_query.isNotEmpty) {
                          docs = docs.where((d) {
                            final data = d.data();
                            final tid = _s(data['transporterId'])
                                .toLowerCase();
                            final name = _s(
                              nameMap[_s(data['transporterId'])],
                            ).toLowerCase();
                            return tid.contains(_query) ||
                                name.contains(_query);
                          }).toList();
                        }

                        // sort by rank if present, otherwise FinalScore desc
                        final hasAnyRank = docs.any(
                            (d) => d.data()['rank'] != null);
                        docs.sort((a, b) {
                          if (hasAnyRank) {
                            final ra =
                                (a.data()['rank'] as num?)?.toInt() ??
                                    999999;
                            final rb =
                                (b.data()['rank'] as num?)?.toInt() ??
                                    999999;
                            return ra.compareTo(rb);
                          }
                          final ca = (a.data()['comp'] ?? {})
                              as Map<String, dynamic>;
                          final cb = (b.data()['comp'] ?? {})
                              as Map<String, dynamic>;
                          final fa = _numOr0(ca['FinalScore']);
                          final fb = _numOr0(cb['FinalScore']);
                          return fb.compareTo(fa);
                        });

                        if (docs.isEmpty) {
                          return const Center(
                              child: Text(
                                  'No drivers match this filter.'));
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final data = docs[i].data();
                            final compRaw = (data['comp'] ?? {});
                            final kpisRaw = (data['kpis'] ?? {});
                            final comp =
                                compRaw is Map<String, dynamic>
                                    ? compRaw
                                    : <String, dynamic>{};
                            final kpis =
                                kpisRaw is Map<String, dynamic>
                                    ? kpisRaw
                                    : <String, dynamic>{};

                            final tid =
                                _s(data['transporterId']).trim();
                            final name = _s(nameMap[tid]).isNotEmpty
                                ? _s(nameMap[tid])
                                : '(No Name)';

                            final score =
                                _numOr0(comp['FinalScore']).toDouble();
                            final delivered =
                                _numOr0(kpis['Delivered'] ??
                                        kpis['DELIVERED'] ??
                                        kpis['delivered'])
                                    .toInt();
                            final dcr =
                                _numOr0(comp['DCR_Score']).toDouble();
                            final pod =
                                _numOr0(comp['POD_Score']).toDouble();
                            final cc =
                                _numOr0(comp['CC_Score']).toDouble();
                            final ce =
                                _numOr0(comp['CE']).toDouble();
                            final dnr = _numOr0(
                                    kpis['DNR'] ?? kpis['DNR DPMO'])
                                .toInt();
                            final lor = _numOr0(
                                    kpis['LoR'] ?? kpis['LoR DPMO'])
                                .toInt();
                            final cdf = _numOr0(
                                    kpis['CDF'] ?? kpis['CDF DPMO'])
                                .toInt();

                            final rank =
                                (data['rank'] as num?)?.toInt();
                            final apiBucketRaw =
                                _s(data['statusBucket']);
                            final statusText =
                                apiBucketRaw.isNotEmpty
                                    ? _prettyBucket(apiBucketRaw)
                                    : _statusText(score);
                            final statusColor =
                                apiBucketRaw.isNotEmpty
                                    ? _colorFromApiBucket(
                                        apiBucketRaw)
                                    : _statusColor(score);

                            return _DriverRowCard(
                              isCompact: isCompact,
                              name: name,
                              transporterId: tid,
                              statusText: statusText,
                              statusColor: statusColor,
                              rank: rank,
                              score: score,
                              delivered: delivered,
                              dcr: dcr,
                              dnr: dnr,
                              lor: lor,
                              pod: pod,
                              cc: cc,
                              ce: ce,
                              cdf: cdf,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 3) Small UI pieces used above
// ==========================================================================

class _SummaryPanel extends StatelessWidget {
  final String title;
  final String big;
  final String small;
  final Color accent;

  const _SummaryPanel({
    required this.title,
    required this.big,
    required this.small,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black45,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            big,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          if (small.isNotEmpty)
            Text(
              small,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _DriverRowCard extends StatelessWidget {
  final bool isCompact;
  final String name;
  final String transporterId;
  final String statusText;
  final Color statusColor;
  final int? rank;
  final double score;
  final int delivered;
  final double dcr;
  final int dnr;
  final int lor;
  final double pod;
  final double cc;
  final double ce;
  final int cdf;

  const _DriverRowCard({
    required this.isCompact,
    required this.name,
    required this.transporterId,
    required this.statusText,
    required this.statusColor,
    required this.rank,
    required this.score,
    required this.delivered,
    required this.dcr,
    required this.dnr,
    required this.lor,
    required this.pod,
    required this.cc,
    required this.ce,
    required this.cdf,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      // mobile / small layout
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transporterId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        rank != null ? '#$rank' : '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${score.toStringAsFixed(2)} %',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _smallStat('DELIVERED', '$delivered'),
                  _smallStat('DCR', '${dcr.toStringAsFixed(2)} %'),
                  _smallStat('DNR DPMO', '$dnr'),
                  _smallStat('LoR DPMO', '$lor'),
                  _smallStat('POD', '${pod.toStringAsFixed(2)} %'),
                  _smallStat('CC', '${cc.toStringAsFixed(2)} %'),
                  _smallStat('CE', '${ce.toStringAsFixed(2)} %'),
                  _smallStat('CDF DPMO', '$cdf'),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // desktop row layout
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transporterId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('RANK', rank != null ? '#$rank' : '—'),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('TOTAL', '${score.toStringAsFixed(2)}'),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('DELIVERED', '$delivered'),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('DCR', dcr.toStringAsFixed(2)),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('DNR DPMO', '$dnr'),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('LoR DPMO', '$lor'),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('POD', pod.toStringAsFixed(2)),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('CC', cc.toStringAsFixed(2)),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('CE', ce.toStringAsFixed(2)),
            const VerticalDivider(width: 22, thickness: 1, color: Colors.black12),
            _metric('CDF DPMO', '$cdf'),
          ],
        ),
      ),
    );
  }

  static Widget _metric(String title, String value) {
    return Expanded(
      flex: 9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _smallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
