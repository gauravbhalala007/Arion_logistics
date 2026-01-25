// lib/widgets/driver_notification_card.dart

import 'package:flutter/material.dart';
import '../models/driver_notification.dart';

class DriverNotificationCard extends StatelessWidget {
  final DriverNotification notification;
  final VoidCallback onTap;

  const DriverNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusText =
        notification.requiresConfirmation && !notification.confirmed
            ? 'confirmation required'
            : 'confirmed';

    final statusColor =
        (notification.requiresConfirmation && !notification.confirmed)
            ? const Color(0xFFE9741A)
            : const Color(0xFF1D7F5A);

    final typeLabel = _typeLabel(notification.type);
    final icon = _typeIcon(notification.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E4EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left icon (by type)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF3F6F7),
                border: Border.all(color: const Color(0xFFE1E4EA)),
              ),
              child: Icon(icon, color: const Color(0xFF4A4F59)),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NEW RULE | Title  + status pill on the right
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$typeLabel | ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              TextSpan(
                                text: notification.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF22252F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status pill (keep)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Color(0xFF4A4F59),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(DriverNotificationType t) {
  switch (t) {
    case DriverNotificationType.message:
      return 'NEW MESSAGE';
    case DriverNotificationType.academy:
      return 'DA ACADEMY';
    case DriverNotificationType.rideAlong:
      return 'RIDE ALONG';
    case DriverNotificationType.rule:
    default:
      return 'NEW RULE';
  }
}

IconData _typeIcon(DriverNotificationType t) {
  switch (t) {
    case DriverNotificationType.message:
      return Icons.chat_bubble_outline;
    case DriverNotificationType.academy:
      return Icons.school_outlined;
    case DriverNotificationType.rideAlong:
      return Icons.directions_car_filled_outlined;
    case DriverNotificationType.rule:
    default:
      return Icons.gavel_outlined;
  }
}

