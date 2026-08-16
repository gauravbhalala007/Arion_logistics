// lib/Screens/driver_cotimer_account_page.dart
//
// Driver-side time-account view: monthly Soll/Ist/Saldo + shift history.
// Liest aus der Default-DB (eur3): time_account/{YYYY-MM} und shifts/.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import '../services/time_tracking_firestore.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/cotimer_account_widgets.dart';

class DriverTimeAccountPage extends StatefulWidget {
  final String adminUid;
  final String driverId;
  const DriverTimeAccountPage({
    super.key,
    required this.adminUid,
    required this.driverId,
  });

  @override
  State<DriverTimeAccountPage> createState() => _DriverTimeAccountPageState();
}

class _DriverTimeAccountPageState extends State<DriverTimeAccountPage> {
  late DateTime _selectedMonth;
  // 0 = aktueller Monat (Details), 1 = Übersicht alle Monate
  int _view = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  String get _monthKey {
    final y = _selectedMonth.year;
    final m = _selectedMonth.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  String _monthLabel(DateTime d) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  void _shiftMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountStream = TimeTrackingFirestore.timeAccount(
      adminUid: widget.adminUid,
      driverId: widget.driverId,
    ).doc(_monthKey).snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F7),
      appBar: AppBar(
        title: const Text(
          'Mein Zeitkonto',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xFFF3F6F7),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF3F6F7),
        foregroundColor: const Color(0xFF1C1C1E),
      ),
      body: Column(
        children: [
          // Segmented Control — Monat / Übersicht
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: SegmentedToggle(
              value: _view,
              labels: const ['Monat', 'Übersicht'],
              onChanged: (v) => setState(() => _view = v),
            ),
          ),
          // State-Morph via Emil-Kowalski-Pattern: 220 ms Crossfade +
          // 0.96 → 1.0 Scale, easeOutCubic. Liest sich als „content
          // morphed in place" statt two screens swap.
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.97, end: 1.0)
                        .animate(anim),
                    child: child,
                  ),
                );
              },
              child: _view == 0
                  ? _buildMonthView(accountStream, key: const ValueKey('m'))
                  : _buildOverviewView(key: const ValueKey('o')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(
    Stream<DocumentSnapshot<Map<String, dynamic>>> accountStream, {
    Key? key,
  }) {
    return ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
      children: [
        _buildMonthPicker(),
        const SizedBox(height: 16),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: accountStream,
          builder: (ctx, snap) {
            final data = snap.data?.data();
            return Column(
              children: [
                _buildSummaryCard(data),
                const SizedBox(height: 12),
                _buildSpesenCard(data),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'SCHICHTEN',
            style: AppTypography.caption2.copyWith(
              color: AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildShiftsList(),
      ],
    );
  }

  Widget _buildMonthPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _shiftMonth(-1),
          ),
          Expanded(
            child: Text(
              _monthLabel(_selectedMonth),
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
              color: const Color(0xFF1C1C1E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              final now = DateTime.now();
              final next =
                  DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              if (next.isAfter(DateTime(now.year, now.month))) return;
              _shiftMonth(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic>? data) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final sollH = (data?['soll'] as num?)?.toDouble() ?? 0;
    final istH = (data?['ist'] as num?)?.toDouble() ?? 0;
    final stampedH = (data?['istStamped'] as num?)?.toDouble() ?? istH;
    final creditedH = (data?['istCredited'] as num?)?.toDouble() ?? 0;
    final saldoH = (data?['saldo'] as num?)?.toDouble() ?? (istH - sollH);
    final vacationDays = (data?['vacationDays'] as num?)?.toInt() ?? 0;
    // Unbezahlter Urlaub wird dem Zeitkonto NICHT gutgeschrieben —
    // ältere Monatsdokumente kennen das Feld nicht (dann 0).
    final unpaidVacationDays =
        (data?['vacationDaysUnpaid'] as num?)?.toInt() ?? 0;
    final sickDays = (data?['sickDays'] as num?)?.toInt() ?? 0;
    final holidays = (data?['holidayDays'] as num?)?.toInt() ?? 0;

    String fmt(double h) {
      final sign = h < 0 ? '-' : '';
      final abs = h.abs();
      return '$sign${abs.toStringAsFixed(1)} h';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SALDO',
            style: AppTypography.caption2.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fmt(saldoH),
            style: AppTypography.largeTitle.copyWith(
              color: const Color(0xFF1C1C1E),
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: const Color(0xFFE5E5EA),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _summaryStat('Soll', fmt(sollH))),
              _vDivider(),
              Expanded(child: _summaryStat('Ist', fmt(istH))),
              _vDivider(),
              Expanded(child: _summaryStat('Gestempelt', fmt(stampedH))),
            ],
          ),
          if (creditedH > 0 || vacationDays > 0 || sickDays > 0 ||
              holidays > 0) ...[
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: const Color(0xFFE5E5EA),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _summaryStat('Urlaub', '$vacationDays T'),
                ),
                _vDivider(),
                Expanded(
                  child: _summaryStat('Krank', '$sickDays T'),
                ),
                _vDivider(),
                Expanded(
                  child: _summaryStat('Feiertage', '$holidays T'),
                ),
              ],
            ),
            if (creditedH > 0) ...[
              const SizedBox(height: 10),
              Text(
                de
                    ? 'Davon ${fmt(creditedH)} aus Urlaub/Krank angerechnet'
                    : 'Includes ${fmt(creditedH)} credited from leave/sickness',
                style: AppTypography.caption1.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (unpaidVacationDays > 0) ...[
              const SizedBox(height: 6),
              Text(
                de
                    ? 'Davon $unpaidVacationDays T unbezahlter Urlaub — '
                        'keine Gutschrift'
                    : '$unpaidVacationDays d of unpaid leave — not credited',
                style: AppTypography.caption1.copyWith(
                  color: const Color(0xFF9A3412),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 0.6,
        height: 28,
        color: const Color(0xFFE5E5EA),
      );

  Widget _buildSpesenCard(Map<String, dynamic>? data) {
    final spesenDays = (data?['spesenDays'] as num?)?.toInt() ?? 0;
    final spesenAmount =
        (data?['spesenAmount'] as num?)?.toDouble() ?? 0.0;
    final spesenRate =
        (data?['spesenRatePerDay'] as num?)?.toDouble() ?? 14.0;
    final spesenThreshold =
        (data?['spesenThresholdHours'] as num?)?.toInt() ?? 8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.codriverGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.restaurant_outlined,
              color: AppColors.codriverGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Spesen (steuerfrei)',
                  style: AppTypography.subheadline.copyWith(
              color: const Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  spesenDays == 0
                      ? 'Noch keine Schicht ≥ ${spesenThreshold} h'
                      : '$spesenDays Tag${spesenDays == 1 ? '' : 'e'} à '
                          '${spesenRate.toStringAsFixed(0)} €',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${spesenAmount.toStringAsFixed(2)} €',
            style: AppTypography.title3.copyWith(
              color: spesenAmount > 0
                  ? AppColors.codriverGreen
                  : AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.caption2.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.subheadline.copyWith(
            color: const Color(0xFF1C1C1E),
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildShiftsList() {
    final monthStart = _selectedMonth;
    final monthEnd =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    final stream = TimeTrackingFirestore.shifts(
      adminUid: widget.adminUid,
      driverId: widget.driverId,
    )
        .where('startTs',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('startTs', isLessThan: Timestamp.fromDate(monthEnd))
        .orderBy('startTs', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Text(
              'Keine Schichten in diesem Monat.',
              textAlign: TextAlign.center,
              style: AppTypography.subheadline.copyWith(
                color: AppColors.labelSecondaryLight,
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final d in docs) ...[
              _ShiftListTile(data: d.data()),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  // ── Übersicht: alle Monate mit Saldo ─────────────────────────────────
  Widget _buildOverviewView({Key? key}) {
    final stream = TimeTrackingFirestore.timeAccount(
      adminUid: widget.adminUid,
      driverId: widget.driverId,
    ).orderBy(FieldPath.documentId, descending: true).snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: key,
      stream: stream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Noch keine Monatsabschlüsse',
                style: AppTypography.subheadline.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
        double totalSaldo = 0;
        double totalIst = 0;
        double totalSoll = 0;
        for (final d in docs) {
          final data = d.data();
          totalSaldo += (data['saldo'] as num?)?.toDouble() ?? 0;
          totalIst += (data['ist'] as num?)?.toDouble() ?? 0;
          totalSoll += (data['soll'] as num?)?.toDouble() ?? 0;
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
          children: [
            _buildOverallSaldo(totalSaldo, totalIst, totalSoll),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'PRO MONAT',
                style: AppTypography.caption2.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (var i = 0; i < docs.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OverviewMonthRow(
                  delayMs: 30 * i, // stagger fade-in (Emil-Pattern)
                  monthKey: docs[i].id,
                  data: docs[i].data(),
                  onTap: () {
                    final parts = docs[i].id.split('-');
                    if (parts.length == 2) {
                      setState(() {
                        _selectedMonth = DateTime(
                          int.parse(parts[0]),
                          int.parse(parts[1]),
                        );
                        _view = 0;
                      });
                    }
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOverallSaldo(double saldoH, double istH, double sollH) {
    final positive = saldoH >= 0;
    final sign = saldoH >= 0 ? '+' : '−';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÜBERSTUNDEN GESAMT',
            style: AppTypography.caption2.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$sign${saldoH.abs().toStringAsFixed(1)} h',
            style: AppTypography.largeTitle.copyWith(
              color: positive
                  ? AppColors.codriverGreen
                  : const Color(0xFFF97316),
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(height: 0.6, color: const Color(0xFFE5E5EA)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _bigStat(
                  'Soll',
                  '${sollH.toStringAsFixed(0)} h',
                ),
              ),
              Container(
                width: 0.6,
                height: 28,
                color: const Color(0xFFE5E5EA),
              ),
              Expanded(
                child: _bigStat(
                  'Ist',
                  '${istH.toStringAsFixed(0)} h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption2.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.title3.copyWith(
            color: const Color(0xFF1C1C1E),
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ShiftListTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ShiftListTile({required this.data});

  String _fmtHm(double seconds) {
    final h = (seconds / 3600).floor();
    final m = ((seconds - h * 3600) / 60).round();
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  String _fmtHmShort(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  String _fmtDay(DateTime d) {
    const wk = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return '${wk[d.weekday - 1]} ${d.day}.${d.month}.';
  }

  @override
  Widget build(BuildContext context) {
    final startTs = data['startTs'] as Timestamp?;
    final endTs = data['endTs'] as Timestamp?;
    final stationCode = (data['stationCode'] ?? '').toString();
    final total = (data['totalDuration'] as num?)?.toDouble() ?? 0;
    final pause = (data['pauseDuration'] as num?)?.toDouble() ?? 0;
    final work = (data['workDuration'] as num?)?.toDouble() ?? 0;
    final isOpen = (data['isOpen'] as bool?) ?? false;
    final compFlags = data['complianceFlags'];
    final warnings = (compFlags is Map ? compFlags['warnings'] as List? : null)
        ?? const [];

    final timeText = startTs == null
        ? '—'
        : isOpen
            ? '${_fmtHmShort(startTs.toDate())} → läuft'
            : '${_fmtHmShort(startTs.toDate())} – '
                '${endTs == null ? "?" : _fmtHmShort(endTs.toDate())}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                startTs == null ? '—' : _fmtDay(startTs.toDate()),
                style: AppTypography.subheadline.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.codriverDeep,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stationCode.isEmpty ? '—' : stationCode,
                style: AppTypography.caption2.copyWith(
                  color: AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeText,
                  style: AppTypography.footnote.copyWith(
              color: const Color(0xFF1C1C1E),
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtHm(work)} · Pause ${_fmtHm(pause)} · ges. '
                  '${_fmtHm(total)}',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.labelSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (warnings.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 12, color: Color(0xFF92400E)),
                  const SizedBox(width: 4),
                  Text(
                    '${warnings.length}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
