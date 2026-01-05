// lib/screens/driver_notifications_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/driver_notification.dart';
import '../widgets/driver_notification_card.dart';

class DriverNotificationsView extends StatelessWidget {
  final String dspUid;
  final String driverTransporterId;

  final ValueChanged<DriverNotification> onOpen;

  const DriverNotificationsView({
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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _col().orderBy('createdAt', descending: true).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No notifications yet.',
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        final items = docs.map((d) => DriverNotification.fromDoc(d)).toList();

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
