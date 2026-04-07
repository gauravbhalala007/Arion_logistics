import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'driver_green_book_page.dart';
import 'driver_academy_module_page.dart';

class DriverAcademyPage extends StatelessWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverAcademyPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(dspUid.trim())
          .collection('academy_tests')
          .orderBy('order')
          .snapshots(),
      builder: (context, snap) {
        final locale = Localizations.localeOf(
          context,
        ).languageCode.toLowerCase();
        final docs = snap.data?.docs ?? const [];
        final categories =
            docs
                .map((doc) => _AcademyCategory.fromDoc(doc))
                .where((c) => c.enabled)
                .toList()
              ..sort((a, b) {
                if (a.order != b.order) return a.order.compareTo(b.order);
                return a
                    .titleFor(locale)
                    .toLowerCase()
                    .compareTo(b.titleFor(locale).toLowerCase());
              });
        final visibleCategories = categories
            .where((c) => c.id.trim().toLowerCase() != 'green_book')
            .toList(growable: false);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    t.t('driver_academy_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (snap.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: t.t('driver_academy_green_book_title'),
                      subtitle: t.t('driver_academy_green_book_subtitle'),
                      icon: Icons.menu_book_rounded,
                      iconColor: const Color(0xFF22AF66),
                      iconBg: const Color(0xFFE9F7EF),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DriverGreenBookPage(
                              dspUid: dspUid,
                              driverTransporterId: driverTransporterId,
                              onBack: () => Navigator.of(context).pop(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ...visibleCategories.map((category) {
                  final title = category.titleFor(locale);
                  final subtitle = category.subtitleFor(locale);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AcademyTile(
                      title: title,
                      subtitle: subtitle,
                      icon: _iconForCategory(category.id),
                      iconColor: const Color(0xFF3E82F7),
                      iconBg: const Color(0xFFE9F1FE),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DriverAcademyModulePage(
                              dspUid: dspUid,
                              driverTransporterId: driverTransporterId,
                              categoryId: category.id,
                              fallbackTitle: title,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                  }),
                  if (visibleCategories.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFDDE3E7),
                          width: 1.2,
                        ),
                      ),
                      child: const Text(
                        'No academy categories are available yet. Please contact your admin.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
            ],
          ),
        );
      },
    );
  }

  IconData _iconForCategory(String categoryId) {
    final id = categoryId.trim().toLowerCase();
    if (id.contains('green')) return Icons.menu_book_rounded;
    if (id.contains('safety')) return Icons.shield_outlined;
    if (id.contains('delivery') || id.contains('amazon')) {
      return Icons.local_shipping_outlined;
    }
    if (id.contains('app')) return Icons.phone_android_rounded;
    return Icons.school_outlined;
  }
}

class _AcademyCategory {
  final String id;
  final int order;
  final bool enabled;
  final Map<String, String> titleByLocale;
  final Map<String, String> subtitleByLocale;

  const _AcademyCategory({
    required this.id,
    required this.order,
    required this.enabled,
    required this.titleByLocale,
    required this.subtitleByLocale,
  });

  factory _AcademyCategory.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _AcademyCategory(
      id: doc.id,
      order: (data['order'] as num?)?.toInt() ?? 0,
      enabled: data['enabled'] != false,
      titleByLocale: _collectLocalized(data, 'title'),
      subtitleByLocale: _collectLocalized(data, 'subtitle'),
    );
  }

  String titleFor(String locale) {
    final code = locale.trim().toLowerCase();
    final direct = (titleByLocale[code] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final en = (titleByLocale['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    return id;
  }

  String subtitleFor(String locale) {
    final code = locale.trim().toLowerCase();
    final direct = (subtitleByLocale[code] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final en = (subtitleByLocale['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    return '';
  }

  static Map<String, String> _collectLocalized(
    Map<String, dynamic> data,
    String prefix,
  ) {
    final out = <String, String>{};
    for (final entry in data.entries) {
      if (!entry.key.startsWith('${prefix}_')) continue;
      final code = entry.key.substring(prefix.length + 1).trim().toLowerCase();
      if (code.isEmpty) continue;
      final value = (entry.value ?? '').toString().trim();
      if (value.isNotEmpty) out[code] = value;
    }
    final plain = (data[prefix] ?? '').toString().trim();
    if (plain.isNotEmpty && !out.containsKey('en')) {
      out['en'] = plain;
    }
    return out;
  }
}

class _AcademyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _AcademyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8699),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF7A8699),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
