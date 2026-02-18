import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../localization/app_localizations.dart';

const double _kTopCardHeight = 142;

class DriverHomePage extends StatelessWidget {
  final int pendingTasksCount;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenComingSoon;

  const DriverHomePage({
    super.key,
    required this.pendingTasksCount,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return _DriverHomePageBody(
      pendingTasks: pendingTasksCount,
      onOpenScorecard: onOpenScorecard,
      onOpenAcademy: onOpenAcademy,
      onOpenTasks: onOpenTasks,
      onOpenRules: onOpenRules,
      onOpenComingSoon: onOpenComingSoon,
    );
  }
}

class _DriverHomePageBody extends StatefulWidget {
  final int pendingTasks;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenComingSoon;

  const _DriverHomePageBody({
    required this.pendingTasks,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenComingSoon,
  });

  @override
  State<_DriverHomePageBody> createState() => _DriverHomePageBodyState();
}

class _DriverHomePageBodyState extends State<_DriverHomePageBody> {
  static const _dispatcherNames = ['ISRAFIL', 'HALIM', 'ANES'];
  int _selectedDispatcher = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final dateLabel =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${(now.year % 100).toString().padLeft(2, '0')}';

    final cards = <_HomeCardData>[
      _HomeCardData(
        title: t.t('nav_scorecard'),
        subtitle: t.t('driver_home_scorecard_subtitle'),
        iconAsset: 'assets/icons/cards_star.svg',
        iconColor: const Color(0xFF27B26A),
        iconBackground: const Color(0xFFE4F5EC),
        badgeText: t.t('driver_home_new_badge'),
        badgeColor: const Color(0xFF24C06F),
        onTap: widget.onOpenScorecard,
      ),
      _HomeCardData(
        title: t.t('driver_home_tasks_title'),
        subtitle: t.t('driver_home_tasks_subtitle'),
        icon: Icons.task_alt_outlined,
        iconColor: const Color(0xFF2CB773),
        iconBackground: const Color(0xFFE4F5EC),
        badgeText: widget.pendingTasks > 0 ? '${widget.pendingTasks}' : null,
        badgeColor: const Color(0xFFFF4B4B),
        onTap: widget.onOpenTasks,
      ),
      _HomeCardData(
        title: 'DA Academy',
        subtitle: t.t('driver_home_academy_subtitle'),
        icon: Icons.school_outlined,
        iconColor: const Color(0xFF3E82F7),
        iconBackground: const Color(0xFFE9F1FE),
        onTap: widget.onOpenAcademy,
      ),
      _HomeCardData(
        title: t.t('driver_home_rules_title'),
        subtitle: t.t('driver_home_rules_subtitle'),
        icon: Icons.gavel_outlined,
        iconColor: const Color(0xFF3E82F7),
        iconBackground: const Color(0xFFE9F1FE),
        badgeText: widget.pendingTasks > 0 ? '${widget.pendingTasks}' : null,
        badgeColor: const Color(0xFFFF4B4B),
        onTap: widget.onOpenRules,
      ),
      _HomeCardData(
        title: t.t('driver_home_vehicles_title'),
        subtitle: t.t('driver_home_vehicles_subtitle'),
        icon: Icons.directions_car_filled_outlined,
        iconColor: const Color(0xFF3E82F7),
        iconBackground: const Color(0xFFE9F1FE),
        onTap: widget.onOpenComingSoon,
      ),
      _HomeCardData(
        title: t.t('driver_home_codriver_title'),
        subtitle: t.t('driver_home_codriver_subtitle'),
        icon: Icons.smart_toy_outlined,
        iconColor: Colors.white,
        iconBackground: const Color(0xFF3E82F7),
        borderGradient: const LinearGradient(
          colors: [Color(0xFF2784FF), Color(0xFF27C79A)],
        ),
        onTap: widget.onOpenComingSoon,
      ),
      _HomeCardData(
        title: t.t('driver_home_absence_title'),
        subtitle: t.t('driver_home_absence_subtitle'),
        icon: Icons.event_busy_outlined,
        iconColor: const Color(0xFFFF7A18),
        iconBackground: const Color(0xFFFFF0E4),
        borderColor: const Color(0xFFFF8A1F),
        onTap: widget.onOpenComingSoon,
      ),
      _HomeCardData(
        title: t.t('driver_home_incident_title'),
        subtitle: t.t('driver_home_incident_subtitle'),
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFFF7A18),
        iconBackground: const Color(0xFFFFF0E4),
        borderColor: const Color(0xFFFF8A1F),
        onTap: widget.onOpenComingSoon,
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DispatcherCard(
                  dateLabel: dateLabel,
                  selectedIndex: _selectedDispatcher,
                  dispatcherNames: _dispatcherNames,
                  onSelect: (idx) {
                    setState(() => _selectedDispatcher = idx);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TopFeatureCard(
                  title: t.t('driver_home_shift_plan_title'),
                  subtitle: t.t('driver_home_shift_plan_subtitle'),
                  icon: Icons.calendar_today_rounded,
                  onTap: widget.onOpenComingSoon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: itemWidth,
                        child: _HomeFeatureCard(data: card),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

class _DispatcherCard extends StatelessWidget {
  final String dateLabel;
  final int selectedIndex;
  final List<String> dispatcherNames;
  final ValueChanged<int> onSelect;

  const _DispatcherCard({
    required this.dateLabel,
    required this.selectedIndex,
    required this.dispatcherNames,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final selectedName = dispatcherNames[selectedIndex];

    return Container(
      height: _kTopCardHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF23BD6C), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: List.generate(dispatcherNames.length, (i) {
                final active = i == selectedIndex;
                final isFirst = i == 0;
                final isLast = i == dispatcherNames.length - 1;
                final itemRadius = BorderRadius.only(
                  topLeft: isFirst ? const Radius.circular(14) : Radius.zero,
                  topRight: isLast ? const Radius.circular(14) : Radius.zero,
                );
                return Expanded(
                  child: InkWell(
                    borderRadius: itemRadius,
                    onTap: () => onSelect(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFE1F7EA)
                            : Colors.transparent,
                        borderRadius: active ? itemRadius : null,
                      ),
                      child: Text(
                        dispatcherNames[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? const Color(0xFF1A9E56)
                              : const Color(0xFF667085),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.t('driver_home_dispatcher'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '${selectedName[0]}${selectedName.substring(1).toLowerCase()}',
                              style: const TextStyle(
                                fontSize: 30 / 2,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          '6:00 - 13:00',
                          style: TextStyle(
                            fontSize: 28 / 2,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _RoundActionIcon(icon: Icons.call, bg: Color(0xFF38B888)),
                      SizedBox(height: 6),
                      _RoundActionIcon(
                        icon: Icons.chat_bubble_outline_rounded,
                        bg: Color(0xFF24C269),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _TopFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
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
          height: _kTopCardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDFE4E7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F5F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Color(0xFF38B888), size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 29 / 2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCardData {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? iconAsset;
  final Color iconColor;
  final Color iconBackground;
  final Color? borderColor;
  final Gradient? borderGradient;
  final String? badgeText;
  final Color badgeColor;
  final VoidCallback onTap;

  const _HomeCardData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconAsset,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
    this.borderColor,
    this.borderGradient,
    this.badgeText,
    this.badgeColor = const Color(0xFFFF4B4B),
  }) : assert(icon != null || iconAsset != null);
}

class _HomeFeatureCard extends StatelessWidget {
  final _HomeCardData data;

  const _HomeFeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final badge = data.badgeText?.trim();
    final hasBadge = badge != null && badge.isNotEmpty;
    final usesPillBadge = hasBadge && badge.length > 2;

    final inner = Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: data.borderGradient == null
            ? Border.all(
                color: data.borderColor ?? const Color(0xFFDDE3E7),
                width: 1.6,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.iconBackground,
              shape: BoxShape.circle,
            ),
            child: data.iconAsset != null
                ? Center(
                    child: SvgPicture.asset(
                      data.iconAsset!,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        data.iconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : Icon(data.icon, size: 23, color: data.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 29 / 2,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A8699),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final cardBody = data.borderGradient == null
        ? inner
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: data.borderGradient,
            ),
            padding: const EdgeInsets.all(2),
            child: inner,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: data.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            cardBody,
            if (hasBadge)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: usesPillBadge ? 36 : 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: usesPillBadge ? 8 : 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: data.badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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

class _RoundActionIcon extends StatelessWidget {
  final IconData icon;
  final Color bg;

  const _RoundActionIcon({required this.icon, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
