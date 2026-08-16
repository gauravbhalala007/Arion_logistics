import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Curated set of Material (Google) icons an update card can use. Stored by
/// key (never a raw codepoint) and referenced via named `Icons.*` constants
/// so icon tree-shaking keeps the glyphs. The first entry is the default.
const Map<String, IconData> kAppUpdateIcons = <String, IconData>{
  'campaign': Icons.campaign_rounded,
  'local_shipping': Icons.local_shipping_rounded,
  'auto_awesome': Icons.auto_awesome_rounded,
  'payments': Icons.payments_rounded,
  'insights': Icons.insights_rounded,
  'calendar_month': Icons.calendar_month_rounded,
  'translate': Icons.translate_rounded,
  'how_to_reg': Icons.how_to_reg_rounded,
  'health_and_safety': Icons.health_and_safety_rounded,
  'filter_alt': Icons.filter_alt_rounded,
  'tune': Icons.tune_rounded,
  'new_releases': Icons.new_releases_rounded,
  'bolt': Icons.bolt_rounded,
  'rocket_launch': Icons.rocket_launch_rounded,
};

/// Resolves a stored icon key to an [IconData], falling back to the default.
IconData appUpdateIconData(String key) =>
    kAppUpdateIcons[key] ?? kAppUpdateIcons['campaign']!;

/// Who an [AppUpdate] is shown to.
enum AppUpdateAudience { admin, driver, all }

AppUpdateAudience parseAppUpdateAudience(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'admin':
      return AppUpdateAudience.admin;
    case 'driver':
      return AppUpdateAudience.driver;
    case 'all':
    default:
      return AppUpdateAudience.all;
  }
}

String appUpdateAudienceValue(AppUpdateAudience a) {
  switch (a) {
    case AppUpdateAudience.admin:
      return 'admin';
    case AppUpdateAudience.driver:
      return 'driver';
    case AppUpdateAudience.all:
      return 'all';
  }
}

/// A product update / changelog entry authored by the superadmin. Stored in
/// the global root collection `appUpdates` so a single write reaches every
/// admin and driver. Shown as a post-login popup and listed in the
/// "Updates" menu section.
///
/// `title` and `body` are localized: each is a `{ langCode: text }` map in
/// Firestore (e.g. `{ de: "…", en: "…", tr: "…" }`). Legacy documents that
/// stored a plain string still parse — the string lands under a wildcard key
/// and is returned for every language. Read the text via [titleFor]/[bodyFor]
/// with the active locale's language code.
class AppUpdate {
  final String id;
  final Map<String, String> _title;
  final Map<String, String> _body;
  final String iconKey;
  final AppUpdateAudience audience;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String createdByEmail;

  const AppUpdate({
    required this.id,
    required Map<String, String> title,
    required Map<String, String> body,
    required this.iconKey,
    required this.audience,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByEmail,
  })  : _title = title,
        _body = body;

  /// The resolved icon for this update.
  IconData get icon => appUpdateIconData(iconKey);

  /// Title in [lang] (a language code like 'de' / 'en'), falling back to
  /// English, then German, then whatever translation exists.
  String titleFor(String lang) => _pick(_title, lang);

  /// Body in [lang], with the same fallback chain as [titleFor].
  String bodyFor(String lang) => _pick(_body, lang);

  /// Default-language title (German → English → any). For logs / non-UI use.
  String get title => _pick(_title, 'de');

  /// Default-language body (German → English → any).
  String get body => _pick(_body, 'de');

  static String _pick(Map<String, String> m, String lang) {
    if (m.isEmpty) return '';
    final exact = m[lang];
    if (exact != null && exact.isNotEmpty) return exact;
    return m['en'] ?? m['de'] ?? m.values.first;
  }

  /// True when this update targets the given app side ('admin' or 'driver').
  bool reaches(String side) {
    if (audience == AppUpdateAudience.all) return true;
    return appUpdateAudienceValue(audience) == side;
  }

  /// Parses a localized text field: a `{lang: text}` map, or a plain string
  /// (legacy) which is stored under the wildcard key '*' so it shows for all.
  static Map<String, String> _parseL10n(dynamic v) {
    if (v is Map) {
      final out = <String, String>{};
      v.forEach((key, value) {
        final s = (value ?? '').toString().trim();
        if (s.isNotEmpty) out[key.toString()] = s;
      });
      return out;
    }
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? <String, String>{} : <String, String>{'*': s};
  }

  factory AppUpdate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;
    return AppUpdate(
      id: doc.id,
      title: _parseL10n(data['title']),
      body: _parseL10n(data['body']),
      iconKey: (data['iconKey'] ?? '').toString().trim(),
      audience: parseAppUpdateAudience((data['audience'] ?? 'all').toString()),
      active: data['active'] != false,
      createdAt: toDate(data['createdAt']),
      updatedAt: toDate(data['updatedAt']),
      createdByEmail: (data['createdByEmail'] ?? '').toString().trim(),
    );
  }
}
