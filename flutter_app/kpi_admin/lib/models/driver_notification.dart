// lib/models/driver_notification.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../localization/app_localizations.dart';

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

  static String _activeLanguageCode() {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode.toLowerCase())
        .toSet();
    final raw = localeController.locale?.languageCode.toLowerCase() ?? 'en';
    return supported.contains(raw) ? raw : 'en';
  }

  static String _localizedText(
    Map<String, dynamic> data,
    String field,
    String fallback,
  ) {
    final lang = _activeLanguageCode();
    final translations =
        (data['translations'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    final current = translations[lang];
    if (current is Map) {
      final localized = (current[field] ?? '').toString().trim();
      if (localized.isNotEmpty) return localized;
    }

    return fallback;
  }

  factory DriverNotification.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final typeRaw = (data['type'] ?? '').toString().trim();
    final statusRaw = (data['status'] ?? 'unread').toString().trim();

    final baseTitle = (data['title'] ?? '').toString();
    final baseBody = (data['body'] ?? '').toString();
    final title = _localizedText(data, 'title', baseTitle);
    final body = _localizedText(data, 'body', baseBody);

    final createdAt = _parseDate(data['createdAt']);
    final requiresConfirmation = (data['requiresConfirmation'] as bool?) ?? true;


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
