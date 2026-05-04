// lib/screens/driver_rules_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/driver_notification.dart';
import '../widgets/driver_notification_card.dart';

class DriverRulesView extends StatelessWidget {
  final String dspUid;
  final String driverTransporterId;

  final ValueChanged<DriverNotification> onOpen;

  const DriverRulesView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onOpen,
  });

  CollectionReference<Map<String, dynamic>> _col() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('drivers')
        .doc(driverTransporterId.toUpperCase())
        .collection('notifications');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _col()
          .where('type', isEqualTo: 'rule')
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              t.tf('driver_rules_error_template', {'error': '${snap.error}'}),
            ),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              t.t('driver_rules_empty'),
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        final sortedDocs = [...docs]..sort((a, b) {
          final aData = a.data();
          final bData = b.data();

          final aSort = (aData['sortOrder'] as num?)?.toInt();
          final bSort = (bData['sortOrder'] as num?)?.toInt();
          if (aSort != null && bSort != null && aSort != bSort) {
            return aSort.compareTo(bSort);
          }
          if (aSort != null && bSort == null) return -1;
          if (aSort == null && bSort != null) return 1;

          final aCreated = aData['createdAt'];
          final bCreated = bData['createdAt'];
          final aMillis = aCreated is Timestamp
              ? aCreated.millisecondsSinceEpoch
              : 0;
          final bMillis = bCreated is Timestamp
              ? bCreated.millisecondsSinceEpoch
              : 0;
          return bMillis.compareTo(aMillis);
        });

        final items = sortedDocs
            .map((d) => DriverNotification.fromDoc(d))
            .toList(growable: false);

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final n = items[i];
            return DriverNotificationCard(
              notification: n,
              onTap: () => onOpen(n),
            );
          },
        );
      },
    );
  }
}
