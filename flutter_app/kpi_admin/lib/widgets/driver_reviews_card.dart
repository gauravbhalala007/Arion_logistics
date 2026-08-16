// lib/widgets/driver_reviews_card.dart
//
// Zeigt im Drivers Hub die monatlichen Dispatcher-Bewertungen eines
// Fahrers — neueste zuerst, aufklappbar.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/driver_review_model.dart';

class DriverReviewsCard extends StatelessWidget {
  final String adminUid;
  final String driverTransporterId;

  const DriverReviewsCard({
    super.key,
    required this.adminUid,
    required this.driverTransporterId,
  });

  static const _kText = Color(0xFF1A2233);
  static const _kMuted = Color(0xFF7A8699);
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kMint = Color(0xFFEBF7F1);
  static const _kLine = Color(0xFFE3E8EF);

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (driverTransporterId.trim().isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .collection('driver_reviews')
          .where('driverTransporterId', isEqualTo: driverTransporterId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final docs = (snap.data?.docs ?? []).toList()
          ..sort((a, b) => (b.data()['period'] ?? '')
              .toString()
              .compareTo((a.data()['period'] ?? '').toString()));
        if (docs.isEmpty) return const SizedBox.shrink();

        final latest = docs.first.data();
        final score = (latest['score'] as num?)?.toDouble() ?? 0;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kLine),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _kMint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.star_rounded,
                    size: 19, color: _kGreen),
              ),
              title: Text(
                de ? 'Bewertungen' : 'Reviews',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              subtitle: Text(
                de
                    ? '${docs.length} Monate · zuletzt '
                        '${reviewPeriodLabel((latest['period'] ?? '').toString())} '
                        '· ${(score * 100).round()} %'
                    : '${docs.length} months · latest '
                        '${(score * 100).round()} %',
                style: const TextStyle(fontSize: 12.5, color: _kMuted),
              ),
              children: [
                for (final d in docs) _reviewBlock(d.data(), de),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reviewBlock(Map<String, dynamic> r, bool de) {
    final score = (r['score'] as num?)?.toDouble() ?? 0;
    final attitude = (r['attitude'] as num?)?.toInt();
    final ratings =
        (r['ratings'] as Map?)?.cast<String, dynamic>() ?? const {};
    final created = r['createdAt'];
    final dateText = created is Timestamp
        ? DateFormat('dd.MM.yyyy').format(created.toDate())
        : '';


    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reviewPeriodLabel((r['period'] ?? '').toString()),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: _kText,
                  ),
                ),
              ),
              Text(
                '${(score * 100).round()} %',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: score >= 0.7
                      ? _kGreen
                      : score >= 0.5
                          ? const Color(0xFFB45309)
                          : const Color(0xFFC0392B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            [
              if ((r['dispatcherName'] ?? '').toString().isNotEmpty)
                '${de ? 'von' : 'by'} ${r['dispatcherName']}',
              if (dateText.isNotEmpty) dateText,
              if (attitude != null)
                (de ? kAttitudeOptionsDe : kAttitudeOptionsEn)[attitude],
            ].join('  ·  '),
            style: const TextStyle(fontSize: 11.5, color: _kMuted),
          ),
          if (ratings.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final q in kDriverReviewQuestions)
                  if (ratings[q.id] is num)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _kLine),
                      ),
                      child: Text(
                        '${q.label}: '
                        '${q.optionsDe[(ratings[q.id] as num).toInt().clamp(0, q.optionsDe.length - 1)]}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F4A5A),
                        ),
                      ),
                    ),
              ],
            ),
          ],
          if ((r['comment'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              (r['comment'] ?? '').toString(),
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF3F4A5A),
              ),
            ),
          ],
          if ((r['note'] ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${de ? 'Notiz' : 'Note'}: ${r['note']}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _kMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
