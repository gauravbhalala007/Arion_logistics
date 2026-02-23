import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';

const double _kTopCardHeight = 142;

class DriverHomePage extends StatelessWidget {
  final String dspUid;
  final int pendingTasksCount;
  final int unconfirmedRulesCount;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenShiftPlan;
  final VoidCallback onOpenAbsence;
  final VoidCallback onOpenIncidentReport;
  final VoidCallback onOpenComingSoon;

  const DriverHomePage({
    super.key,
    required this.dspUid,
    required this.pendingTasksCount,
    required this.unconfirmedRulesCount,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenShiftPlan,
    required this.onOpenAbsence,
    required this.onOpenIncidentReport,
    required this.onOpenComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return _DriverHomePageBody(
      dspUid: dspUid,
      pendingTasks: pendingTasksCount,
      unconfirmedRules: unconfirmedRulesCount,
      onOpenScorecard: onOpenScorecard,
      onOpenAcademy: onOpenAcademy,
      onOpenTasks: onOpenTasks,
      onOpenRules: onOpenRules,
      onOpenShiftPlan: onOpenShiftPlan,
      onOpenAbsence: onOpenAbsence,
      onOpenIncidentReport: onOpenIncidentReport,
      onOpenComingSoon: onOpenComingSoon,
    );
  }
}

class _DriverHomePageBody extends StatefulWidget {
  final String dspUid;
  final int pendingTasks;
  final int unconfirmedRules;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenShiftPlan;
  final VoidCallback onOpenAbsence;
  final VoidCallback onOpenIncidentReport;
  final VoidCallback onOpenComingSoon;

  const _DriverHomePageBody({
    required this.dspUid,
    required this.pendingTasks,
    required this.unconfirmedRules,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenShiftPlan,
    required this.onOpenAbsence,
    required this.onOpenIncidentReport,
    required this.onOpenComingSoon,
  });

  @override
  State<_DriverHomePageBody> createState() => _DriverHomePageBodyState();
}

class _DriverHomePageBodyState extends State<_DriverHomePageBody> {
  static const _settingsCollection = 'settings';
  static const _dispatcherPillDoc = 'dispatcher_pill';
  int _selectedDispatcher = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final dateLabel =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${(now.year % 100).toString().padLeft(2, '0')}';
    final dispatcherDocStream = widget.dspUid.trim().isEmpty
        ? null
        : FirebaseFirestore.instance
              .collection('users')
              .doc(widget.dspUid)
              .collection(_settingsCollection)
              .doc(_dispatcherPillDoc)
              .snapshots();

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
        title: t.t('driver_academy_title'),
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
        badgeText: widget.unconfirmedRules > 0
            ? '${widget.unconfirmedRules}'
            : null,
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
        onTap: widget.onOpenAbsence,
      ),
      _HomeCardData(
        title: t.t('driver_home_incident_title'),
        subtitle: t.t('driver_home_incident_subtitle'),
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFFF7A18),
        iconBackground: const Color(0xFFFFF0E4),
        borderColor: const Color(0xFFFF8A1F),
        onTap: widget.onOpenIncidentReport,
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
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: dispatcherDocStream,
                  builder: (context, snap) {
                    final dispatchers = _parseDispatchers(snap.data?.data());
                    if (dispatchers.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    if (_selectedDispatcher >= dispatchers.length &&
                        dispatchers.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() => _selectedDispatcher = 0);
                      });
                    }

                    final safeIndex = _selectedDispatcher.clamp(
                      0,
                      dispatchers.length - 1,
                    );
                    return _DispatcherCard(
                      dateLabel: dateLabel,
                      selectedIndex: safeIndex,
                      dispatchers: dispatchers,
                      onSelect: (idx) {
                        setState(() => _selectedDispatcher = idx);
                      },
                      onCallTap: () =>
                          _callNumber(dispatchers[safeIndex].phone),
                      onWhatsAppTap: () =>
                          _openWhatsApp(dispatchers[safeIndex]),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TopFeatureCard(
                  title: t.t('driver_home_shift_plan_title'),
                  subtitle: t.t('driver_home_shift_plan_subtitle'),
                  icon: Icons.calendar_today_rounded,
                  onTap: widget.onOpenShiftPlan,
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

  List<_DispatcherContact> _parseDispatchers(Map<String, dynamic>? data) {
    final fallback = <_DispatcherContact>[
      const _DispatcherContact(
        name: 'ISRAFIL',
        startTime: '06:00',
        endTime: '13:00',
      ),
      const _DispatcherContact(
        name: 'HALIM',
        startTime: '13:00',
        endTime: '20:00',
      ),
      const _DispatcherContact(
        name: 'ANES',
        startTime: '20:00',
        endTime: '03:00',
      ),
    ];

    final raw = data?['dispatchers'];
    if (raw is! List) return fallback;

    final out = <_DispatcherContact>[];
    for (final row in raw) {
      if (row is! Map) continue;
      final map = row.cast<String, dynamic>();
      if (map['isActive'] == false) continue;
      final name = _firstNonEmpty([
        _stringOf(map['name']),
        _stringOf(map['label']),
        _stringOf(map['title']),
      ]);
      if (name.isEmpty) continue;

      out.add(
        _DispatcherContact(
          name: name,
          startTime: _firstNonEmpty([
            _stringOf(map['startTime']),
            _stringOf(map['shiftStart']),
          ]),
          endTime: _firstNonEmpty([
            _stringOf(map['endTime']),
            _stringOf(map['shiftEnd']),
          ]),
          phone: _stringOf(map['phone']),
          whatsapp: _firstNonEmpty([
            _stringOf(map['whatsapp']),
            _stringOf(map['whatsApp']),
            _stringOf(map['wa']),
          ]),
          whatsappLink: _firstNonEmpty([
            _stringOf(map['whatsappLink']),
            _stringOf(map['whatsappUrl']),
            _stringOf(map['waLink']),
          ]),
        ),
      );
    }

    return out.isEmpty ? fallback : out;
  }

  Future<void> _callNumber(String rawNumber) async {
    final number = rawNumber.trim();
    if (number.isEmpty) {
      _showSnack('No phone number configured for this dispatcher.');
      return;
    }
    final uri = Uri(scheme: 'tel', path: number);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      _showSnack('Could not open dialer.');
    }
  }

  Future<void> _openWhatsApp(_DispatcherContact contact) async {
    final linkRaw = contact.whatsappLink.trim();
    Uri? uri;

    if (linkRaw.isNotEmpty) {
      final parsed = Uri.tryParse(linkRaw);
      if (parsed != null) {
        if (parsed.hasScheme) {
          uri = parsed;
        } else {
          uri = Uri.tryParse('https://$linkRaw');
        }
      }
    }

    if (uri == null) {
      final rawNumber = contact.whatsappOrPhone;
      final looksLikeLink =
          rawNumber.contains('://') ||
          rawNumber.startsWith('wa.me/') ||
          rawNumber.startsWith('www.');
      if (looksLikeLink) {
        final parsed = Uri.tryParse(rawNumber);
        if (parsed != null) {
          uri = parsed.hasScheme ? parsed : Uri.tryParse('https://$rawNumber');
        }
      }
    }

    if (uri == null) {
      final rawNumber = contact.whatsappOrPhone;
      final number = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (number.isEmpty) {
        _showSnack(
          'No WhatsApp link or number configured for this dispatcher.',
        );
        return;
      }
      uri = Uri.parse('https://wa.me/$number');
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      _showSnack('Could not open WhatsApp.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final v = raw.trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }
}

class _DispatcherCard extends StatelessWidget {
  final String dateLabel;
  final int selectedIndex;
  final List<_DispatcherContact> dispatchers;
  final ValueChanged<int> onSelect;
  final VoidCallback onCallTap;
  final VoidCallback onWhatsAppTap;

  const _DispatcherCard({
    required this.dateLabel,
    required this.selectedIndex,
    required this.dispatchers,
    required this.onSelect,
    required this.onCallTap,
    required this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (dispatchers.isEmpty) {
      return const SizedBox.shrink();
    }
    final safeIndex = selectedIndex.clamp(0, dispatchers.length - 1);
    final selected = dispatchers[safeIndex];
    final selectedName = selected.name;

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
              children: List.generate(dispatchers.length, (i) {
                final active = i == safeIndex;
                final isFirst = i == 0;
                final isLast = i == dispatchers.length - 1;
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
                        dispatchers[i].name.toUpperCase(),
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
                              selectedName,
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
                        Text(
                          selected.timeRange,
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
                    children: [
                      _RoundActionIcon(
                        icon: Icons.call,
                        bg: const Color(0xFF38B888),
                        onTap: onCallTap,
                      ),
                      SizedBox(height: 6),
                      _RoundActionIcon(
                        iconAsset: 'assets/icons/whatsapp.svg',
                        bg: const Color(0xFF24C269),
                        onTap: onWhatsAppTap,
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
  final IconData? icon;
  final String? iconAsset;
  final Color bg;
  final VoidCallback? onTap;

  const _RoundActionIcon({
    this.icon,
    this.iconAsset,
    required this.bg,
    this.onTap,
  }) : assert(icon != null || iconAsset != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: iconAsset != null
              ? Center(
                  child: SvgPicture.asset(
                    iconAsset!,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _DispatcherContact {
  final String name;
  final String startTime;
  final String endTime;
  final String phone;
  final String whatsapp;
  final String whatsappLink;

  const _DispatcherContact({
    required this.name,
    required this.startTime,
    required this.endTime,
    this.phone = '',
    this.whatsapp = '',
    this.whatsappLink = '',
  });

  String get timeRange {
    final s = startTime.trim();
    final e = endTime.trim();
    if (s.isEmpty && e.isEmpty) return '--';
    if (s.isEmpty) return e;
    if (e.isEmpty) return s;
    return '$s - $e';
  }

  String get whatsappOrPhone {
    final wa = whatsapp.trim();
    if (wa.isNotEmpty) return wa;
    return phone;
  }
}
