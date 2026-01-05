// lib/models/driver_notification.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum DriverNotificationType {
  rule,
  message,
  academy,
  rideAlong,
}

class DriverNotification {
  final String id;
  final DriverNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;

  final bool requiresConfirmation;

  // Backend-driven status
  final String status; // unread | read | confirmed
  final DateTime? readAt;
  final DateTime? confirmedAt;

  DriverNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.requiresConfirmation,
    required this.status,
    required this.readAt,
    required this.confirmedAt,
  });

  bool get confirmed => status == 'confirmed';

  bool get isUnread => status == 'unread';

  static DriverNotificationType _parseType(String raw) {
    switch (raw) {
      case 'rule':
        return DriverNotificationType.rule;
      case 'message':
        return DriverNotificationType.message;
      case 'academy':
        return DriverNotificationType.academy;
      case 'rideAlong':
        return DriverNotificationType.rideAlong;
      default:
        return DriverNotificationType.message;
    }
  }

  static DateTime _parseDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }

  static DateTime? _parseDateOrNull(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  factory DriverNotification.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final typeRaw = (data['type'] ?? '').toString().trim();
    final statusRaw = (data['status'] ?? 'unread').toString().trim();

    final title = (data['title'] ?? '').toString();
    final body = (data['body'] ?? '').toString();

    final createdAt = _parseDate(data['createdAt']);
    final requiresConfirmation = (data['requiresConfirmation'] as bool?) ??
        (typeRaw == 'rule');

    return DriverNotification(
      id: doc.id,
      type: _parseType(typeRaw),
      title: title,
      body: body,
      createdAt: createdAt,
      requiresConfirmation: requiresConfirmation,
      status: statusRaw.isEmpty ? 'unread' : statusRaw,
      readAt: _parseDateOrNull(data['readAt']),
      confirmedAt: _parseDateOrNull(data['confirmedAt']),
    );
  }
}
