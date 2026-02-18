import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class DriverAcademyPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onOpenGreenBook;
  final VoidCallback onOpenSafetyTraining;
  final VoidCallback onOpenAmazonDelivery;
  final VoidCallback onOpenCoDriverApp;

  const DriverAcademyPage({
    super.key,
    required this.onBack,
    required this.onOpenGreenBook,
    required this.onOpenSafetyTraining,
    required this.onOpenAmazonDelivery,
    required this.onOpenCoDriverApp,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

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
                  fontSize: 36 / 2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AcademyTile(
            title: t.t('driver_academy_green_book_title'),
            subtitle: t.t('driver_academy_green_book_subtitle'),
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF24B06E),
            iconBg: const Color(0xFFE6F6EE),
            badgeText: t.t('driver_home_new_badge'),
            onTap: onOpenGreenBook,
          ),
          const SizedBox(height: 10),
          _AcademyTile(
            title: t.t('driver_academy_safety_title'),
            subtitle: t.t('driver_academy_safety_subtitle'),
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFFFF7A18),
            iconBg: const Color(0xFFFFF0E4),
            onTap: onOpenSafetyTraining,
          ),
          const SizedBox(height: 10),
          _AcademyTile(
            title: t.t('driver_academy_delivery_title'),
            subtitle: t.t('driver_academy_delivery_subtitle'),
            icon: Icons.local_shipping_outlined,
            iconColor: const Color(0xFF38B888),
            iconBg: const Color(0xFFE8F7F2),
            onTap: onOpenAmazonDelivery,
          ),
          const SizedBox(height: 10),
          _AcademyTile(
            title: t.t('driver_academy_app_title'),
            subtitle: t.t('driver_academy_app_subtitle'),
            icon: Icons.menu_book_outlined,
            iconColor: const Color(0xFF3E82F7),
            iconBg: const Color(0xFFE9F1FE),
            onTap: onOpenCoDriverApp,
          ),
        ],
      ),
    );
  }
}

class _AcademyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? badgeText;
  final VoidCallback onTap;

  const _AcademyTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final badge = badgeText?.trim();
    final hasBadge = badge != null && badge.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 72,
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
                            fontSize: 30 / 2,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
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
            if (hasBadge)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24C06F),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
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
