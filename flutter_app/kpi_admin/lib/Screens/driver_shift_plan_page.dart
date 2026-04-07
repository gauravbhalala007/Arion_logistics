import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';

class DriverShiftPlanPage extends StatelessWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverShiftPlanPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final driverId = driverTransporterId.toUpperCase().trim();
    if (dspUid.trim().isEmpty || driverId.isEmpty) {
      return Center(child: Text(t.t('driver_shift_plan_missing_scope')));
    }

    final shiftsCol = FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('drivers')
        .doc(driverId)
        .collection('shifts');

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF1D7F5A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t.t('driver_shift_plan_title'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: shiftsCol
                    .orderBy('shiftStart', descending: false)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        t.tf('driver_shift_plan_load_failed_template', {
                          'error': '${snap.error}',
                        }),
                      ),
                    );
                  }

                  final docs = snap.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return Center(child: Text(t.t('driver_shift_plan_empty')));
                  }

                  final now = DateTime.now();
                  final upcoming =
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
                  final past = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                  for (final d in docs) {
                    final data = d.data();
                    final start = _toDateTime(data['shiftStart']);
                    if (start == null || start.isAfter(now)) {
                      upcoming.add(d);
                    } else {
                      past.add(d);
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 14),
                    children: [
                      _sectionLabel(t.t('driver_shift_plan_upcoming')),
                      if (upcoming.isEmpty)
                        _emptyCard(t.t('driver_shift_plan_upcoming_empty'))
                      else
                        ...upcoming.map((doc) => _shiftCard(context, doc)),
                      const SizedBox(height: 10),
                      _sectionLabel(t.t('driver_shift_plan_past')),
                      if (past.isEmpty)
                        _emptyCard(t.t('driver_shift_plan_past_empty'))
                      else
                        ...past.reversed.map((doc) => _shiftCard(context, doc)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3E7)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _shiftCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final start = _toDateTime(data['shiftStart']);
    final end = _toDateTime(data['shiftEnd']);
    final notes = _stringOf(data['notes']);
    final templateLabel = _stringOf(data['templateLabel']);
    final templateBg =
        _toColor(data['templateBgColor']) ?? const Color(0xFFE4F5EC);
    final templateFg =
        _toColor(data['templateFgColor']) ?? const Color(0xFF1D7F5A);
    final status = _stringOf(data['status']).isEmpty
        ? 'scheduled'
        : _stringOf(data['status']);

    final dayLabel = start == null
        ? '-'
        : DateFormat('EEEE, dd.MM.yyyy').format(start);
    final timeLabel = '${_time(start)} - ${_time(end)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: Color(0xFF1D7F5A),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dayLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFFE4F5EC),
                ),
                child: Text(
                  (status.trim().toLowerCase() == 'scheduled'
                          ? AppLocalizations.of(
                              context,
                            ).t('driver_shift_plan_status_scheduled')
                          : status)
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1D7F5A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            timeLabel,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (templateLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: templateBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                templateLabel,
                style: TextStyle(
                  color: templateFg,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              notes,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static DateTime? _toDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }

  static String _time(DateTime? value) {
    if (value == null) return '--:--';
    return DateFormat('HH:mm').format(value);
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static Color? _toColor(dynamic raw) {
    if (raw is int) return Color(raw);
    if (raw is num) return Color(raw.toInt());
    return null;
  }
}
