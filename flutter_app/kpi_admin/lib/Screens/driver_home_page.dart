import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';
import '../widgets/motion_helpers.dart';
import 'driver_vehicle_inspection_page.dart';

/// Driver-Whitelist als Fallback, falls der Admin das Add-On Flag noch
/// nicht explizit aktiviert hat. Alle anderen Driver sehen co:timer nur,
/// wenn ihr DSP-Admin `users/{adminUid}.addons.timeTracking == true`
/// gesetzt hat (über den co:timer Setup-Tab).
const Set<String> _kCotimerVisibleForDrivers = {
  'albert.dobra@arion-logistics.de',
  'test@arion-logistics.de',
};

const double _kTopCardHeight = 142;

class DriverHomePage extends StatelessWidget {
  final String dspUid;
  final String driverTransporterId;
  final int pendingTasksCount;
  final int unconfirmedRulesCount;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenShiftPlan;
  final VoidCallback onOpenAbsence;
  final VoidCallback onOpenIncidentReport;
  final VoidCallback onOpenWaveplan;
  final VoidCallback onOpenComingSoon;
  final VoidCallback onOpenCotimer;

  const DriverHomePage({
    super.key,
    required this.dspUid,
    this.driverTransporterId = '',
    required this.pendingTasksCount,
    required this.unconfirmedRulesCount,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenShiftPlan,
    required this.onOpenAbsence,
    required this.onOpenIncidentReport,
    required this.onOpenWaveplan,
    required this.onOpenComingSoon,
    required this.onOpenCotimer,
  });

  @override
  Widget build(BuildContext context) {
    return _DriverHomePageBody(
      dspUid: dspUid,
      driverTransporterId: driverTransporterId,
      pendingTasks: pendingTasksCount,
      unconfirmedRules: unconfirmedRulesCount,
      onOpenScorecard: onOpenScorecard,
      onOpenAcademy: onOpenAcademy,
      onOpenTasks: onOpenTasks,
      onOpenRules: onOpenRules,
      onOpenShiftPlan: onOpenShiftPlan,
      onOpenAbsence: onOpenAbsence,
      onOpenIncidentReport: onOpenIncidentReport,
      onOpenWaveplan: onOpenWaveplan,
      onOpenComingSoon: onOpenComingSoon,
      onOpenCotimer: onOpenCotimer,
    );
  }
}

class _DriverHomePageBody extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final int pendingTasks;
  final int unconfirmedRules;
  final VoidCallback onOpenScorecard;
  final VoidCallback onOpenAcademy;
  final VoidCallback onOpenTasks;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenShiftPlan;
  final VoidCallback onOpenAbsence;
  final VoidCallback onOpenIncidentReport;
  final VoidCallback onOpenWaveplan;
  final VoidCallback onOpenComingSoon;
  final VoidCallback onOpenCotimer;

  const _DriverHomePageBody({
    required this.dspUid,
    required this.driverTransporterId,
    required this.pendingTasks,
    required this.unconfirmedRules,
    required this.onOpenScorecard,
    required this.onOpenAcademy,
    required this.onOpenTasks,
    required this.onOpenRules,
    required this.onOpenShiftPlan,
    required this.onOpenAbsence,
    required this.onOpenIncidentReport,
    required this.onOpenWaveplan,
    required this.onOpenComingSoon,
    required this.onOpenCotimer,
  });

  @override
  State<_DriverHomePageBody> createState() => _DriverHomePageBodyState();
}

class _DriverHomePageBodyState extends State<_DriverHomePageBody> {
  static const _settingsCollection = 'settings';
  static const _dispatcherPillDoc = 'dispatcher_pill';
  int _selectedDispatcher = 0;
  // Reaktives Flag: ist co:timer Add-On vom Admin freigeschaltet?
  // Wird per Stream auf users/{dspUid}.addons.timeTracking live gehalten.
  bool _cotimerAddonEnabled = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _addonSub;

  @override
  void initState() {
    super.initState();
    final dsp = widget.dspUid.trim();
    if (dsp.isNotEmpty) {
      _addonSub = FirebaseFirestore.instance
          .collection('users')
          .doc(dsp)
          .snapshots()
          .listen((snap) {
        final addons = (snap.data()?['addons'] as Map?) ?? const {};
        final enabled = addons['timeTracking'] == true;
        if (mounted && enabled != _cotimerAddonEnabled) {
          setState(() => _cotimerAddonEnabled = enabled);
        }
      });
    }
  }

  @override
  void dispose() {
    _addonSub?.cancel();
    super.dispose();
  }

  /// Test-phase access gate for the Shift Plan feature. Drivers can
  /// peek at the new view only after entering the shared password
  /// 4002. Remove this dialog (and the inline onTap wrapper) once the
  /// feature is opened to everyone.
  Future<void> _promptShiftPlanPassword(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => const _ShiftPlanPasswordDialog(),
    );
    if (ok == true && mounted) {
      widget.onOpenShiftPlan();
    }
  }

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
      // Page: DriverAcademyPage
      // Wiring: driver_home_shell.dart -> DriverView.academy
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
      // Planned page: Vehicles overview
      // Current placeholder card only; no driver page is wired yet.
      _HomeCardData(
        title: t.t('driver_home_vehicles_title'),
        subtitle: t.t('driver_home_vehicles_subtitle'),
        icon: Icons.directions_car_filled_outlined,
        iconColor: const Color(0xFF3E82F7),
        iconBackground: const Color(0xFFE9F1FE),
        badgeText: t.t('coming_soon'),
        onTap: null,
      ),
      // Planned page: CoDriver AI assistant
      // Current placeholder card only; no driver page is wired yet.
      _HomeCardData(
        title: t.t('driver_home_codriver_title'),
        subtitle: t.t('driver_home_codriver_subtitle'),
        icon: Icons.smart_toy_outlined,
        iconColor: Colors.white,
        iconBackground: const Color(0xFF3E82F7),
        borderGradient: const LinearGradient(
          colors: [Color(0xFF2784FF), Color(0xFF27C79A)],
        ),
        badgeText: t.t('coming_soon'),
        onTap: null,
      ),
      // Page: DriverAbsencePage
      // Wiring: driver_home_shell.dart -> DriverView.absence
      _HomeCardData(
        title: t.t('driver_home_absence_title'),
        subtitle: t.t('driver_home_absence_subtitle'),
        icon: Icons.event_busy_outlined,
        iconColor: const Color(0xFFFF7A18),
        iconBackground: const Color(0xFFFFF0E4),
        borderColor: const Color(0xFFFF8A1F),
        onTap: widget.onOpenAbsence,
      ),
      // Page: DriverIncidentReportPage
      // Wiring: driver_home_shell.dart -> DriverView.incidentReport
      _HomeCardData(
        title: t.t('driver_home_incident_title'),
        subtitle: t.t('driver_home_incident_subtitle'),
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFFF7A18),
        iconBackground: const Color(0xFFFFF0E4),
        borderColor: const Color(0xFFFF8A1F),
        badgeText: t.t('coming_soon'),
        onTap: null,
      ),
      // Pre-shift vehicle check — opens a bottom sheet with two quick
      // yes/no questions. When "No" we instruct the driver to send a
      // walk-around video to the dispatcher via WhatsApp.
      _HomeCardData(
        title: 'Fahrzeug-Check',
        subtitle: 'Kurz vor Schichtstart bestätigen',
        icon: Icons.directions_car_rounded,
        iconColor: const Color(0xFF1D7F5A),
        iconBackground: const Color(0xFFE6F8F2),
        onTap: () => openDriverVehicleInspectionSheet(
          context,
          dspUid: widget.dspUid,
          driverDocId: widget.driverTransporterId.toUpperCase(),
        ),
      ),
      // Page: DriverWaveplanView
      // Wiring: driver_home_shell.dart -> DriverView.waveplan
      _HomeCardData(
        title: 'Waveplan',
        subtitle: 'Deine Route, Spur & Schicht',
        icon: Icons.waves_rounded,
        iconColor: const Color(0xFF00B287),
        iconBackground: const Color(0xFFE6F8F2),
        onTap: widget.onOpenWaveplan,
      ),
      // Page: DriverCotimerClockPage  (Add-On-Modul)
      // Wiring: driver_home_shell.dart -> DriverView.cotimer
      // Sichtbar wenn:
      //   • Admin hat `addons.timeTracking == true` gesetzt (UI im
      //     co:timer Setup-Tab), ODER
      //   • Driver-Email auf Test-Whitelist (legacy fallback).
      if (_cotimerAddonEnabled ||
          _kCotimerVisibleForDrivers.contains(
            (FirebaseAuth.instance.currentUser?.email ?? '')
                .toLowerCase()
                .trim(),
          ))
        _HomeCardData(
          title: 'co:timer',
          subtitle: 'Stempel-Uhr · Beta',
          icon: Icons.timer_outlined,
          iconColor: const Color(0xFF006047),
          iconBackground: const Color(0xFFE6F8F2),
          badgeText: 'BETA',
          badgeColor: const Color(0xFFB7791F),
          onTap: widget.onOpenCotimer,
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
                // Page: DriverShiftPlanView
                // Test phase: tap shows a 4-digit password gate. On
                // success the shift plan opens via onOpenShiftPlan.
                // Remove the gate once the feature ships to all DSPs.
                child: _TopFeatureCard(
                  title: t.t('driver_home_shift_plan_title'),
                  subtitle: t.t('driver_home_shift_plan_subtitle'),
                  icon: Icons.event_note_rounded,
                  badgeText: t.t('coming_soon'),
                  onTap: () => _promptShiftPlanPassword(context),
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
                children: [
                  for (var i = 0; i < cards.length; i++)
                    SizedBox(
                      width: itemWidth,
                      // Stagger Fade-In beim Mount (Emil-Pattern):
                      // 30 ms je Item, kumulativ max ~300 ms.
                      child: StaggeredFadeIn(
                        delay: Duration(milliseconds: 30 * i),
                        slideOffsetY: 0.06,
                        child: _HomeFeatureCard(data: cards[i]),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  List<_DispatcherContact> _parseDispatchers(Map<String, dynamic>? data) {
    final raw = data?['dispatchers'];
    if (raw is! List) return const <_DispatcherContact>[];

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

    return out;
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
  final VoidCallback? onTap;
  final String? badgeText;

  const _TopFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final badge = badgeText?.trim();
    final hasBadge = badge != null && badge.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: _kTopCardHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : const Color(0xFFF8FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDFE4E7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isEnabled ? 0.06 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? const Color(0xFFE9F5F1)
                            : const Color(0xFFEEF2F4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isEnabled
                            ? const Color(0xFF38B888)
                            : const Color(0xFF9AA4B2),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 29 / 2,
                        fontWeight: FontWeight.w800,
                        color: isEnabled
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isEnabled
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasBadge)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFD7DEE6)),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ),
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
  final VoidCallback? onTap;

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
    final usesPillBadge = hasBadge;
    final isEnabled = data.onTap != null;

    final inner = Container(
      height: 96, // 8 px Rhythmus, +4 px vs alt für luftigeren Look
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: data.borderGradient == null
            ? Border.all(
                color: const Color(0xFFE5E5EA), // hairline neutral
                width: 0.6,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isEnabled ? 0.04 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEnabled
                  ? data.iconBackground
                  : const Color(0xFFEEF2F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: data.iconAsset != null
                ? Center(
                    child: SvgPicture.asset(
                      data.iconAsset!,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        isEnabled
                            ? data.iconColor
                            : const Color(0xFF9CA3AF),
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                : Icon(
                    data.icon,
                    size: 20,
                    color: isEnabled
                        ? data.iconColor
                        : const Color(0xFF9CA3AF),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isEnabled
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isEnabled
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                    height: 1.3,
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
              borderRadius: BorderRadius.circular(16),
              gradient: data.borderGradient,
            ),
            padding: const EdgeInsets.all(1.4),
            child: inner,
          );

    return PressFeedback(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(16),
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
                    color: isEnabled
                        ? data.badgeColor
                        : const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(999),
                    border: isEnabled
                        ? null
                        : Border.all(color: const Color(0xFFD7DEE6)),
                  ),
                  child: Text(
                    badge,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isEnabled
                          ? Colors.white
                          : const Color(0xFF667085),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
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

/// Test-phase password gate for the Shift Plan tile. Returns `true`
/// on correct passcode, `false` (or null) on cancel/wrong code. The
/// shared passcode is "4002"; remove this widget when the feature
/// rolls out to all drivers.
class _ShiftPlanPasswordDialog extends StatefulWidget {
  const _ShiftPlanPasswordDialog();

  @override
  State<_ShiftPlanPasswordDialog> createState() =>
      _ShiftPlanPasswordDialogState();
}

class _ShiftPlanPasswordDialogState
    extends State<_ShiftPlanPasswordDialog> {
  static const _passcode = '4002';
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim() == _passcode) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F5EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF1D7F5A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Shift plan · Beta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Enter the 4-digit test passcode.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: Color(0xFF111827),
                ),
                onChanged: (_) {
                  if (_wrong) setState(() => _wrong = false);
                },
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _wrong
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _wrong
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _wrong
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF1D7F5A),
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              if (_wrong) ...[
                const SizedBox(height: 6),
                const Text(
                  'Wrong passcode. Ask your dispatcher.',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D7F5A),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Unlock',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
