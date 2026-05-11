// lib/widgets/admin_notification_bell.dart
//
// Bell icon for the admin app bar with a red badge showing the total
// number of unread document-expiry notifications across the admin's
// drivers. Tap navigates to the Drivers Hub (where the expiring
// drivers are sorted to the top).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/admin_expiry_aggregator.dart';
import '../theme/app_colors.dart';
import 'admin_scope.dart';

class AdminNotificationBell extends StatelessWidget {
  /// Called when the bell is tapped. Wire to a navigation that opens
  /// the Drivers Hub or a notifications list.
  final VoidCallback? onTap;
  final Color iconColor;
  const AdminNotificationBell({
    super.key,
    this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final uid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return IconButton(
        onPressed: onTap,
        icon: Icon(Icons.notifications_none_rounded, color: iconColor),
      );
    }

    return StreamBuilder<int>(
      stream: AdminExpiryAggregator().watchUnreadTotal(uid),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: onTap,
              icon: Icon(
                count > 0
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: iconColor,
              ),
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
