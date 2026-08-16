// lib/Screens/concessions_dashboard.dart
//
// Concessions Drivers Dashboard
// =============================
//
// Aggregat-Ansicht ueber ALLE Wochen — pro Fahrer eine kompakte Zeile mit
// den wichtigsten Verlust-Metriken auf einen Blick.
//
//   ┌──────────────────────────────────────────────────────────┐
//   │ 🔍 Suche...                       Sortieren: Verlust ▼   │
//   ├──────────────────────────────────────────────────────────┤
//   │ TOTAL: 1.234,50 €    DNRs: 224    Fahrer: 23             │
//   ├──────────────────────────────────────────────────────────┤
//   │ ●  Max Mustermann · A1B2C3        12 DNR · 1.852 · 66 €  │
//   │ ●  Anna Schulz   · D4E5F6          8 DNR · 1.234 · 44 €  │
//   │ ○  Tim Lehmann   · G7H8I9          3 DNR ·   412 · 16 €  │
//   │ ✓  Lukas Peters  · J0K1L2          0 DNR ·     0 ·  0 €  │
//   └──────────────────────────────────────────────────────────┘
//
// Default-Sortierung: Verlust desc (schlechteste oben).
// Filter ueber Such-Feld nach Name oder Transporter-ID.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';
import 'concessions_week.dart' show kEurPerDnr;

final _intFmt = NumberFormat.decimalPattern('de');
final _eurFmt = NumberFormat.currency(
  locale: 'de_DE',
  symbol: '€',
  decimalDigits: 2,
);

String _intStr(num? v) {
  if (v == null) return '—';
  try {
    return _intFmt.format(v);
  } catch (_) {
    return '—';
  }
}

String _eurStr(num? eur) {
  if (eur == null) return '—';
  try {
    return _eurFmt.format(eur);
  } catch (_) {
    return '€ ${eur.toStringAsFixed(2)}';
  }
}

/// Erkennt XLSX-Summary-Zeilen (z. B. "TOTALDNRCOUNT") die der Parser
/// als Fahrer interpretiert. Diese sind Aggregate ueber alle Fahrer und
/// duerfen NICHT in Listen/Totals einbezogen werden.
const _kSummaryRowKeys = <String>{
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

bool _isSummaryRow(Map<String, dynamic> data) {
  final tid = (data['transporterId'] ?? '').toString().trim().toUpperCase();
  final name = (data['driverName'] ?? '').toString().trim().toUpperCase();
  final tidNorm = tid.replaceAll(RegExp(r'[^A-Z]'), '');
  final nameNorm = name.replaceAll(RegExp(r'[^A-Z]'), '');
  return _kSummaryRowKeys.contains(tid) ||
      _kSummaryRowKeys.contains(name) ||
      _kSummaryRowKeys.contains(tidNorm) ||
      _kSummaryRowKeys.contains(nameNorm);
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

enum _SortBy { lossDesc, dnrsDesc, dpmoDesc, nameAsc }

class ConcessionsDashboardPage extends StatefulWidget {
  const ConcessionsDashboardPage({super.key});

  @override
  State<ConcessionsDashboardPage> createState() =>
      _ConcessionsDashboardPageState();
}

class _ConcessionsDashboardPageState extends State<ConcessionsDashboardPage> {
  final _searchCtrl = TextEditingController();
  String _q = '';
  _SortBy _sort = _SortBy.lossDesc;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Stream<List<_DriverAgg>> _aggregatedStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scores')
        .snapshots()
        .map((snap) {
          // WICHTIG: totalDnr / totalDelivered / dnrDpmo4w sind im
          // Concessions-Datenmodell bereits 4-Wochen-Rolling-Werte.
          // Wenn wir mehrere Wochen-Uploads haben, sind die Fenster
          // ueberlappend — Summieren wuerde DOPPELZAEHLUNG erzeugen.
          //
          // Daher: pro Fahrer nur den NEUESTEN Score verwenden (= aktuelles
          // 4-Wochen-Fenster).
          final byTid = <String, _DriverAgg>{};
          for (final d in snap.docs) {
            final data = d.data();
            final c =
                (data['concessions'] as Map?)?.cast<String, dynamic>();
            if (c == null) continue;
            if (_isSummaryRow(data)) continue;

            final tid = (data['transporterId'] ?? '').toString().trim();
            if (tid.isEmpty) continue;

            final name = (data['driverName'] ?? '').toString().trim();
            final delivered = _num(c['totalDelivered']) ?? 0;
            final dnr = _num(c['totalDnr']) ?? 0;
            final dpmo = _num(c['dnrDpmo4w']) ?? 0;
            final yearN = (data['year'] as num?)?.toInt() ?? 0;
            final weekN = (data['weekNumber'] as num?)?.toInt() ?? 0;
            // Combine year+week to a sortable number, e.g. 202618 for W18-2026
            final periodKey = yearN * 100 + weekN;

            final existing = byTid[tid];
            if (existing == null || periodKey > existing.periodKey) {
              byTid[tid] = _DriverAgg(
                transporterId: tid,
                name: name.isNotEmpty
                    ? name
                    : (existing?.name ?? ''),
                totalDelivered: delivered,
                totalDnr: dnr,
                latestDpmo4w: dpmo,
                periodKey: periodKey,
              );
            }
          }
          return byTid.values.toList();
        });
  }

  void _applySort(List<_DriverAgg> rows) {
    switch (_sort) {
      case _SortBy.lossDesc:
        rows.sort((a, b) => b.totalLoss.compareTo(a.totalLoss));
        break;
      case _SortBy.dnrsDesc:
        rows.sort((a, b) => b.totalDnr.compareTo(a.totalDnr));
        break;
      case _SortBy.dpmoDesc:
        rows.sort((a, b) => b.latestDpmo4w.compareTo(a.latestDpmo4w));
        break;
      case _SortBy.nameAsc:
        rows.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }
  }

  List<_DriverAgg> _filter(List<_DriverAgg> rows) {
    if (_q.trim().isEmpty) return rows;
    final q = _q.trim().toLowerCase();
    return rows
        .where(
          (r) =>
              r.name.toLowerCase().contains(q) ||
              r.transporterId.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: Text(t.t('concessions_dashboard_overview_title')),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder<List<_DriverAgg>>(
              stream: _aggregatedStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final raw = snap.data ?? const <_DriverAgg>[];
                final rows = _filter([...raw]);
                _applySort(rows);

                final totalDnr = raw.fold<double>(
                  0,
                  (s, r) => s + r.totalDnr,
                );
                final totalLoss = raw.fold<double>(
                  0,
                  (s, r) => s + r.totalLoss,
                );
                final activeDrivers =
                    raw.where((r) => r.totalDnr > 0).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero stats
                    _TotalsHero(
                      totalLoss: totalLoss,
                      totalDnr: totalDnr,
                      driversWithIssues: activeDrivers,
                      totalDrivers: raw.length,
                    ),
                    const SizedBox(height: 16),

                    // Search + Sort
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _q = v),
                            decoration: InputDecoration(
                              hintText: t.t('concessions_search_hint'),
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SortMenu(
                          value: _sort,
                          onChanged: (v) => setState(() => _sort = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Driver list
                    Expanded(
                      child: rows.isEmpty
                          ? _EmptyState(query: _q)
                          : ListView.separated(
                              itemCount: rows.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) =>
                                  _DriverRow(agg: rows[i]),
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
}

// ============================================================
//  Aggregat-Datenklasse
// ============================================================

class _DriverAgg {
  final String transporterId;
  final String name;
  final double totalDelivered;
  final double totalDnr;
  final double latestDpmo4w;
  /// Sortable identifier of the latest period that produced this row.
  /// Computed as year*100 + weekNumber (e.g. 202618 for KW 18 / 2026).
  final int periodKey;
  const _DriverAgg({
    required this.transporterId,
    required this.name,
    required this.totalDelivered,
    required this.totalDnr,
    required this.latestDpmo4w,
    required this.periodKey,
  });

  double get totalLoss => totalDnr * kEurPerDnr;
}

// ============================================================
//  Hero-Totals-Karte
// ============================================================

class _TotalsHero extends StatelessWidget {
  final double totalLoss;
  final double totalDnr;
  final int driversWithIssues;
  final int totalDrivers;
  const _TotalsHero({
    required this.totalLoss,
    required this.totalDnr,
    required this.driversWithIssues,
    required this.totalDrivers,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3F2), Color(0xFFFFF7E6)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeroMetric(
              label: t.t('concessions_total_loss'),
              value: _eurStr(totalLoss),
              accent: const Color(0xFFB42318),
              icon: Icons.payments_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: const Color(0xFFFECDCA),
          ),
          Expanded(
            child: _HeroMetric(
              label: t.t('concessions_affected_drivers'),
              value: '$driversWithIssues / $totalDrivers',
              accent: const Color(0xFF1F2937),
              icon: Icons.people_alt_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  Sortier-Menu
// ============================================================

class _SortMenu extends StatelessWidget {
  final _SortBy value;
  final ValueChanged<_SortBy> onChanged;
  const _SortMenu({required this.value, required this.onChanged});

  String _label(BuildContext context, _SortBy v) {
    final t = AppLocalizations.of(context);
    switch (v) {
      case _SortBy.lossDesc:
        return t.t('concessions_sort_loss');
      case _SortBy.dnrsDesc:
        return t.t('concessions_sort_dnrs');
      case _SortBy.dpmoDesc:
        return t.t('concessions_sort_dpmo');
      case _SortBy.nameAsc:
        return t.t('concessions_sort_name');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SortBy>(
      tooltip: AppLocalizations.of(context).t('concessions_sort_tooltip'),
      onSelected: onChanged,
      itemBuilder: (ctx) => _SortBy.values
          .map((v) => PopupMenuItem<_SortBy>(
                value: v,
                child: Row(
                  children: [
                    if (v == value)
                      const Icon(Icons.check, size: 18, color: Color(0xFF1D7F5A))
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(_label(ctx, v)),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_vert_rounded,
              size: 18,
              color: Color(0xFF374151),
            ),
            const SizedBox(width: 6),
            Text(
              _label(context, value),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  Driver-Zeile (compact)
// ============================================================

class _DriverRow extends StatelessWidget {
  final _DriverAgg agg;
  const _DriverRow({required this.agg});

  Color _severityColor() {
    if (agg.totalDnr <= 0) return const Color(0xFF15803D); // green: clean
    if (agg.totalDnr <= 2) return const Color(0xFFB54708); // amber: minor
    return const Color(0xFFB42318); // red: serious
  }

  IconData _severityIcon() {
    if (agg.totalDnr <= 0) return Icons.check_circle_rounded;
    if (agg.totalDnr <= 2) return Icons.circle;
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor();
    final name = agg.name.isEmpty ? '—' : agg.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08111827),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_severityIcon(), color: color, size: 22),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                if (agg.transporterId.isNotEmpty)
                  Text(
                    agg.transporterId,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
          ),
          _InlineStat(
            label: 'DNR',
            value: _intStr(agg.totalDnr),
            accent: color,
          ),
          const SizedBox(width: 18),
          _InlineStat(
            label: 'DPMO',
            value: _intStr(agg.latestDpmo4w),
            accent: const Color(0xFF374151),
          ),
          const SizedBox(width: 18),
          _InlineStat(
            label: AppLocalizations.of(context).t('concessions_loss'),
            value: _eurStr(agg.totalLoss),
            accent: const Color(0xFFB42318),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool emphasize;
  const _InlineStat({
    required this.label,
    required this.value,
    required this.accent,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 15 : 14,
            fontWeight: FontWeight.w800,
            color: accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ============================================================
//  Empty State
// ============================================================

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isSearching = query.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.inbox_outlined,
            size: 48,
            color: const Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? t.tf('concessions_search_empty', {'query': query})
                : t.t('concessions_dashboard_empty'),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
