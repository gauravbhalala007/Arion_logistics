// lib/screens/admin_shell_page.dart
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'package:flutter_svg/flutter_svg.dart';

import '../localization/app_localizations.dart';
import '../services/admin_notifications_service.dart';
import '../widgets/admin_notifications_panel.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import '../widgets/app_shell.dart';
import '../widgets/new_version_gate.dart';
import '../widgets/app_side_menu.dart';
import 'login_page.dart';

// your existing pages
import 'admin_home_page.dart';
import 'scorecard_overview.dart';
import 'pod_quality_overview.dart';
import 'concessions_overview.dart';
import 'cdf_overview.dart';
import 'dwc_overview.dart';
import 'contact_compliance_overview.dart';
import 'drivers_hub_page.dart';
import 'admin_recruiting_page.dart';
import 'admin_waveplan_page.dart';
import 'admin_flexplan_page.dart';
import 'admin_calendar_page.dart';
import 'admin_contacts_page.dart';
import 'task_sheet_page.dart';
import 'admin_zeiten_abwesenheiten_page.dart';
import 'admin_da_requests_page.dart';
import 'admin_driver_reviews_page.dart';
import 'admin_safety_training_page.dart';
import 'admin_incident_reports_page.dart';
import 'notifications_page.dart';
import 'admin_app_updates_page.dart';
import '../widgets/app_update_popup.dart';
import 'admin_approvals_page.dart';
import 'admin_faq_page.dart';
import 'admin_academy_page.dart';
import 'admin_dispatchers_page.dart';
import 'admin_dispatcher_center_page.dart';
import 'dsp_profile_page.dart';
import 'feedback_page.dart';
import 'fleet_status_page.dart';
import 'admin_styleguide_page.dart';
import 'admin_cotimer_page.dart';
import 'admin_inventory_page.dart';
import 'admin_cart_page.dart';
import 'admin_shift_plan_page.dart';
import 'admin_payment_check_page.dart';
import 'admin_monthly_plan_page.dart';
import 'admin_vehicle_check_page.dart';
import '../widgets/admin_top_bar.dart';

class AdminShellPage extends StatefulWidget {
  final AppNav initialNav;

  const AdminShellPage({super.key, this.initialNav = AppNav.home});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  late AppNav _active = _initialActive();

  /// Ticket „nach Reload immer auf DA Requests": Der zuletzt aktive Tab
  /// wird im Browser gemerkt und beim Neuladen wiederhergestellt. Eine
  /// explizit angesteuerte Route (Deep-Link, Glocke) gewinnt weiterhin;
  /// danach wird die URL neutralisiert, damit der Reload nicht ewig auf
  /// derselben Route klebt.
  static const String _kLastNavKey = 'codriver.lastAdminNav';

  AppNav _initialActive() {
    if (widget.initialNav != AppNav.home) {
      _saveNav(widget.initialNav);
      _neutralizeUrl();
      return widget.initialNav;
    }
    try {
      final saved = html.window.localStorage[_kLastNavKey];
      if (saved != null && saved.isNotEmpty) {
        final nav = AppNav.values
            .where((n) => n.name == saved)
            .toList(growable: false);
        if (nav.isNotEmpty) return nav.first;
      }
    } catch (_) {}
    return widget.initialNav;
  }

  static void _saveNav(AppNav nav) {
    // Profil/Styleguide nicht merken — dort will nach Reload niemand landen.
    if (nav == AppNav.styleguide) return;
    try {
      html.window.localStorage[_kLastNavKey] = nav.name;
    } catch (_) {}
  }

  static void _neutralizeUrl() {
    try {
      html.window.history.replaceState(null, '', '/');
    } catch (_) {}
  }
  bool _redirectingToLogin = false;
  bool _redirectingToRoot = false;
  bool _updatePopupScheduled = false;
  bool _menuCollapsed = false;

  String? _profileUid;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _profileStream;

  /// Lazy-build cache for the IndexedStack. Each page is only
  /// constructed the first time the user navigates to it; it then
  /// stays in memory so subsequent visits feel instant and preserve
  /// scroll / filter state. This avoids opening 20+ Firestore
  /// listeners on first paint, which was the root cause of the
  /// slow-down after we kept adding heavy admin pages.
  final Set<AppNav> _materialized = <AppNav>{};

  @override
  void initState() {
    super.initState();
    _materialized.add(_active);
  }

  bool _isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 1100;

  /// Navy des Admin-Headers — auch die Farbe der mobilen Bottom-Bar.
  static const Color _kHeaderNavy = Color(0xFF0B1220);

  static String _tr(BuildContext c, String de, String en) =>
      Localizations.localeOf(c).languageCode == 'de' ? de : en;

  /// Wechselt den Shell-Tab (IndexedStack) auf [nav] — genutzt von den
  /// Header-Actions (z. B. Glocke → DA Requests).
  void _openNav(AppNav nav) {
    if (_active == nav) return;
    _saveNav(nav);
    setState(() {
      _active = nav;
      _materialized.add(nav);
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _profileDocStreamFor(
    String uid,
  ) {
    if (_profileUid == uid && _profileStream != null) {
      return _profileStream!;
    }
    _profileUid = uid;
    _profileStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();
    return _profileStream!;
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      if (!_redirectingToLogin) {
        _redirectingToLogin = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
        });
      }
      return const LoginPage();
    }

    final narrow = _isNarrow(context);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileDocStreamFor(authUser.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF6F7F5),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data?.data() ?? const <String, dynamic>{};
        final role = (data['role'] ?? '').toString().trim().toLowerCase();
        final approved = data['approved'] == true;
        // Wenn ein Dispatcher die Shell betritt, ist sein `users/{uid}`
        // Doc weder ein Admin (approved=false) noch ein Driver — wir
        // erkennen das daran, dass im Widget-Baum ein AdminScope gesetzt
        // ist, dessen UID nicht der eingeloggten ist.
        final adminScope = AdminScope.maybeOf(context);
        final isDispatcherShell = role == 'dispatcher' && adminScope != null;

        // ✅ Prevent driver accounts from opening AdminShell routes directly.
        // Dispatchers dürfen die Shell betreten, auch ohne `approved=true`.
        if (role == 'driver' || (!approved && !isDispatcherShell)) {
          if (!_redirectingToRoot) {
            _redirectingToRoot = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
            });
          }
          return const Scaffold(
            backgroundColor: Color(0xFFF6F7F5),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final dispatcherName = isDispatcherShell
            ? ((data['name'] ?? data['email'] ?? authUser.email ?? '')
                  .toString())
            : '';

        // Once per session: surface the newest unseen product update as a
        // post-login popup for admin-app users.
        if (!_updatePopupScheduled) {
          _updatePopupScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            AppUpdatePopup.maybeShow(context, uid: authUser.uid, side: 'admin');
          });
        }

        return NewVersionGate(
          child: AppShell(
            menuWidth: _menuCollapsed && !narrow ? 72 : 300,
            // Mobil: Logo linksbündig, kein Hamburger mehr (das Seitenmenü
            // hängt jetzt an der ersten Kachel der schwebenden Bottom-Bar).
            centerTitle: !narrow,
            hideDrawerButton: narrow,
            actions: narrow
                ? [
                    _HeaderLanguageAction(uid: authUser.uid),
                    const SizedBox(width: 12),
                    _HeaderIconAction(
                      icon: Icons.attach_file,
                      tooltip: _tr(context, 'Notizen', 'Notes'),
                      onTap: () =>
                          showAdminQuickNotes(context, uid: authUser.uid),
                    ),
                    const SizedBox(width: 12),
                    // Glocke mit rotem Zaehler: Summe aller offenen
                    // Meldungen. Klick oeffnet das Bottom-Sheet-Panel.
                    StreamBuilder<int>(
                      stream: AdminNotificationsService.watchTotal(context),
                      builder: (context, snap) {
                        final open = snap.data ?? 0;
                        return _HeaderIconAction(
                          icon: Icons.notifications_outlined,
                          badgeCount: open,
                          tooltip: open > 0
                              ? _tr(
                                  context,
                                  'Meldungen: $open',
                                  'Notifications: $open',
                                )
                              : _tr(context, 'Meldungen', 'Notifications'),
                          onTap: () => showAdminNotificationsSheet(
                            context: context,
                            onNavigate: _openNav,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _HeaderProfileAvatar(
                      profile: data,
                      onTap: () {
                        if (_active == AppNav.profile) return;
                        setState(() {
                          _active = AppNav.profile;
                          _materialized.add(AppNav.profile);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ]
                : null,
            appBarBackgroundColor: _kHeaderNavy,
            appBarForegroundColor: Colors.white,
            appBarToolbarHeight: 72,
            title: isDispatcherShell
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/Codriver_logo_dark.png',
                        height: 30,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        cacheHeight: 120,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dispatcher: $dispatcherName',
                        style: AppTypography.caption2.copyWith(
                          color: AppColors.codriverGreen,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                : Image.asset(
                    'assets/Codriver_logo_dark.png',
                    height: 38,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    cacheHeight: 152,
                  ),
            sideMenu: AppSideMenu(
              width: _menuCollapsed && !narrow ? 72 : 300,
              collapsed: _menuCollapsed && !narrow,
              onToggleCollapsed: narrow
                  ? null
                  : () => setState(() => _menuCollapsed = !_menuCollapsed),
              active: _active,
              onSelect: (nav) {
                if (nav == _active) return;
                _saveNav(nav);
                setState(() {
                  _active = nav;
                  _materialized.add(nav);
                });
              },
              closeDrawerIfOpen: () {
                if (!narrow) return;
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(); // closes Drawer
                }
              },
            ),
            body: _withMobileBottomNav(
              narrow: narrow,
              child: Column(
                children: [
                  // Desktop-only top menu bar: company + station on the left,
                  // quick notes / language / profile on the right.
                  if (!narrow && !isDispatcherShell)
                    AdminTopBar(
                      uid: authUser.uid,
                      profile: data,
                      onOpenProfile: () {
                        if (_active == AppNav.profile) return;
                        setState(() {
                          _active = AppNav.profile;
                          _materialized.add(AppNav.profile);
                        });
                      },
                      onOpenUpdates: () {
                        if (_active == AppNav.appUpdates) return;
                        setState(() {
                          _active = AppNav.appUpdates;
                          _materialized.add(AppNav.appUpdates);
                        });
                      },
                      onOpenNav: _openNav,
                    ),
                  _TrialCountdownBanner(profile: data),
                  Expanded(
                    child: IndexedStack(
                      index: _indexFor(_active),
                      children: [
                        _lazy(AppNav.home, () => const AdminHomePage()),
                        _lazy(
                          AppNav.dashboard,
                          () => const ScorecardOverviewPage(),
                        ),
                        _lazy(
                          AppNav.podQuality,
                          () => const PodQualityOverviewPage(),
                        ),
                        _lazy(
                          AppNav.concessions,
                          () => const ConcessionsOverviewPage(),
                        ),
                        _lazy(AppNav.cdf, () => const CdfOverviewPage()),
                        _lazy(AppNav.drivers, () => const DriversHubPage()),
                        _lazy(
                          AppNav.recruiting,
                          () => const AdminRecruitingPage(),
                        ),
                        _lazy(AppNav.waveplan, () => const AdminWaveplanPage()),
                        _lazy(AppNav.calendar, () => const AdminCalendarPage()),
                        _lazy(
                          AppNav.fleetStatus,
                          () => const FleetStatusPage(),
                        ),
                        _lazy(AppNav.tasks, () => const TaskSheetPage()),
                        _lazy(
                          AppNav.shiftAbsence,
                          () => const AdminZeitenAbwesenheitenPage(),
                        ),
                        _lazy(
                          AppNav.incidentReports,
                          () => const AdminIncidentReportsPage(),
                        ),
                        _lazy(AppNav.academy, () => const AdminAcademyPage()),
                        _lazy(
                          AppNav.dispatcherPill,
                          () => const AdminDispatcherCenterPage(),
                        ),
                        _lazy(
                          AppNav.notifications,
                          () => const NotificationsPage(),
                        ),
                        _lazy(
                          AppNav.appUpdates,
                          () => const AdminAppUpdatesPage(),
                        ),
                        _lazy(AppNav.feedback, () => const FeedbackPage()),
                        _lazy(AppNav.faqs, () => const AdminFaqPage()),
                        _lazy(
                          AppNav.adminApprovals,
                          () => const AdminApprovalsPage(),
                        ),
                        _lazy(
                          AppNav.dispatchers,
                          () => const AdminDispatchersPage(),
                        ),
                        _lazy(AppNav.profile, () => const DspProfilePage()),
                        _lazy(
                          AppNav.styleguide,
                          () => const AdminStyleguidePage(),
                        ),
                        _lazy(AppNav.cotimer, () => const AdminCotimerPage()),
                        _lazy(
                          AppNav.inventory,
                          () => const AdminInventoryPage(),
                        ),
                        _lazy(AppNav.cart, () => const AdminCartPage()),
                        _lazy(
                          AppNav.shiftPlan,
                          () => const AdminShiftPlanPage(),
                        ),
                        _lazy(
                          AppNav.paymentCheck,
                          () => const AdminPaymentCheckPage(),
                        ),
                        _lazy(
                          AppNav.monthlyPlan,
                          () => const AdminMonthlyPlanPage(),
                        ),
                        _lazy(AppNav.dwc, () => const DwcOverviewPage()),
                        _lazy(
                          AppNav.daRequests,
                          () => const AdminDaRequestsPage(),
                        ),
                        _lazy(
                          AppNav.safetyTraining,
                          () => const AdminSafetyTrainingPage(),
                        ),
                        _lazy(
                          AppNav.driverReviews,
                          () => const AdminDriverReviewsPage(),
                        ),
                        _lazy(
                          AppNav.contactCompliance,
                          () => const ContactComplianceOverviewPage(),
                        ),
                        _lazy(
                          AppNav.contacts,
                          () => const AdminContactsPage(),
                        ),
                        _lazy(
                          AppNav.vehicleCheck,
                          () => const AdminVehicleCheckPage(),
                        ),
                        _lazy(
                          AppNav.flexplan,
                          () => const AdminFlexplanPage(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Legt mobil die schwebende Bottom-Navigation über den Inhalt und
  /// reserviert darunter Platz, damit nichts verdeckt wird. Desktop gibt
  /// den Inhalt unverändert zurück.
  Widget _withMobileBottomNav({required bool narrow, required Widget child}) {
    if (!narrow) return child;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Reservierte Fläche = Bar-Höhe + Abstand nach unten + Luft darüber.
    // Weil der Seiteninhalt dadurch oberhalb der Bar endet, sitzen auch die
    // schwebenden Plus-/FAB-Buttons der Seiten (Fleet, …) automatisch über
    // der Bar — sie orientieren sich am unteren Rand ihres eigenen Bereichs.
    const reserved =
        _AdminMobileBottomNav.barHeight +
        _AdminMobileBottomNav.bottomMargin +
        16;
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(bottom: reserved + bottomInset),
            child: child,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          // Builder: der Kontext muss unterhalb des Scaffolds von AppShell
          // liegen, damit `Scaffold.of(...)` den Drawer öffnen kann.
          child: Builder(
            builder: (ctx) => SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  _AdminMobileBottomNav.bottomMargin,
                ),
                child: _AdminMobileBottomNav(
                  active: _active,
                  onSelect: (nav) {
                    if (nav == _active) return;
                    _saveNav(nav);
                    setState(() {
                      _active = nav;
                      _materialized.add(nav);
                    });
                  },
                  onOpenMenu: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Returns the real page widget only if [nav] has been visited at
  /// least once; otherwise an empty placeholder is rendered inside the
  /// IndexedStack. Once a page is built, it stays in memory so a
  /// later navigation reuses it (and its scroll / filter state is
  /// preserved).
  final Map<AppNav, Widget> _builtCache = <AppNav, Widget>{};

  Widget _lazy(AppNav nav, Widget Function() build) {
    if (!_materialized.contains(nav)) {
      return const SizedBox.shrink();
    }
    return _builtCache.putIfAbsent(nav, build);
  }

  int _indexFor(AppNav nav) {
    switch (nav) {
      case AppNav.home:
        return 0;
      case AppNav.dashboard:
        return 1;
      case AppNav.podQuality:
        return 2;
      case AppNav.concessions:
        return 3;
      case AppNav.cdf:
        return 4;
      case AppNav.drivers:
        return 5;
      case AppNav.recruiting:
        return 6;
      case AppNav.waveplan:
        return 7;
      case AppNav.calendar:
        return 8;
      case AppNav.fleetStatus:
        return 9;
      case AppNav.tasks:
        return 10;
      case AppNav.shiftAbsence:
        return 11;
      case AppNav.incidentReports:
        return 12;
      case AppNav.academy:
        return 13;
      case AppNav.dispatcherPill:
        return 14;
      case AppNav.notifications:
        return 15;
      case AppNav.appUpdates:
        return 16;
      case AppNav.feedback:
        return 17;
      case AppNav.faqs:
        return 18;
      case AppNav.adminApprovals:
        return 19;
      case AppNav.dispatchers:
        return 20;
      case AppNav.profile:
        return 21;
      case AppNav.styleguide:
        return 22;
      case AppNav.cotimer:
        return 23;
      case AppNav.inventory:
        return 24;
      case AppNav.cart:
        return 25;
      case AppNav.shiftPlan:
        return 26;
      case AppNav.paymentCheck:
        return 27;
      case AppNav.monthlyPlan:
        return 28;
      case AppNav.dwc:
        return 29;
      case AppNav.daRequests:
        return 30;
      case AppNav.safetyTraining:
        return 31;
      case AppNav.driverReviews:
        return 32;
      case AppNav.contactCompliance:
        return 33;
      case AppNav.contacts:
        return 34;
      case AppNav.vehicleCheck:
        return 35;
      case AppNav.flexplan:
        return 36;
      default:
        return 0;
    }
  }
}

/// Slim banner shown at the top of every admin page while the account
/// is on the 30-day trial. Counts down the remaining days and shifts
/// from green → amber → red as expiry approaches. Hidden entirely for
/// non-trial (paid / dispatcher) accounts.
class _TrialCountdownBanner extends StatelessWidget {
  final Map<String, dynamic> profile;
  const _TrialCountdownBanner({required this.profile});

  @override
  Widget build(BuildContext context) {
    final plan = (profile['plan'] ?? '').toString();
    final endsRaw = profile['trialEndsAt'];
    if (plan != 'trial' || endsRaw is! Timestamp) {
      return const SizedBox.shrink();
    }

    final endsAt = endsRaw.toDate();
    final now = DateTime.now();
    final remaining = endsAt.difference(now);

    // Already expired → auth_gate handles the hard block; render nothing.
    if (remaining.isNegative) return const SizedBox.shrink();

    // Round partial days up so the last 24 h still read as "1 Tag".
    final daysLeft = (remaining.inMinutes / (60 * 24)).ceil().clamp(1, 999);

    // Colour escalation by urgency.
    final Color accent;
    final Color bg;
    if (daysLeft <= 3) {
      accent = const Color(0xFFB42318); // red-700
      bg = const Color(0xFFFEF3F2); // red-50
    } else if (daysLeft <= 7) {
      accent = const Color(0xFFB54708); // amber-700
      bg = const Color(0xFFFFFAEB); // amber-50
    } else {
      accent = const Color(0xFF067A55); // green-700 (readable on light bg)
      bg = const Color(0xFFECFDF3); // green-50
    }

    final dayWord = daysLeft == 1 ? 'Tag' : 'Tage';

    return Material(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: accent.withValues(alpha: 0.18)),
            ),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: accent),
              const SizedBox(width: 4),
              Text(
                'Testversion',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                '· Noch $daysLeft $dayWord',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobiler Header rechts: Sprache · Notizen · Profil
// ---------------------------------------------------------------------------

/// Runder Header-Button (44×44 Trefferfläche) auf dem Navy des Headers.
class _HeaderIconAction extends StatelessWidget {
  const _HeaderIconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  /// Roter Zaehler oben rechts am Icon; 0 blendet ihn aus, ab 100 "99+".
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.10),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(icon, size: 21, color: Colors.white),
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                    // Ring in der Header-Navy, damit der Punkt sauber
                    // vom Icon abgesetzt ist.
                    border: Border.all(
                      color: const Color(0xFF0B1220),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sprach-Umschalter mit Landesflagge — gleiche Auswahl wie in der
/// Fahrer-App, gleiche Logik wie in der Desktop-Topbar
/// (`localeController` + `languageCode` auf `users/{uid}`).
class _HeaderLanguageAction extends StatelessWidget {
  const _HeaderLanguageAction({required this.uid});

  final String uid;

  static String flagAsset(String code) {
    switch (code) {
      case 'en':
        return 'assets/flags/gb.svg';
      case 'de':
        return 'assets/flags/de.svg';
      case 'sq':
        return 'assets/flags/al.svg';
      case 'hu':
        return 'assets/flags/hu.svg';
      case 'ro':
        return 'assets/flags/ro.svg';
      case 'hr':
        return 'assets/flags/hr.svg';
      case 'ar':
        return 'assets/flags/sy.svg';
      case 'tr':
        return 'assets/flags/tr.svg';
      case 'ru':
        return 'assets/flags/ru.svg';
      case 'bg':
        return 'assets/flags/bg.svg';
      case 'es':
        return 'assets/flags/es.svg';
      default:
        return 'assets/flags/gb.svg';
    }
  }

  Future<void> _select(BuildContext context) async {
    final current = (localeController.locale ?? Localizations.localeOf(context))
        .languageCode;
    final de = Localizations.localeOf(context).languageCode == 'de';

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E9EE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    de ? 'Sprache' : 'Language',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A212B),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final locale in AppLocalizations.supportedLocales)
                      ListTile(
                        minVerticalPadding: 12,
                        leading: SizedBox(
                          width: 30,
                          height: 30,
                          child: ClipOval(
                            child: SvgPicture.asset(
                              flagAsset(locale.languageCode),
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          languageLabel(locale.languageCode),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: locale.languageCode == current
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        trailing: locale.languageCode == current
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.codriverGreen,
                              )
                            : null,
                        onTap: () => Navigator.of(ctx).pop(locale.languageCode),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );

    if (picked == null || picked == current) return;
    localeController.setLocale(Locale(picked));
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'languageCode': picked,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    // Neutrales Sprach-Icon statt Landesflagge (Kundenwunsch) — die
    // Flaggen erscheinen weiterhin in der Auswahl-Liste des Sheets.
    return Tooltip(
      message: de ? 'Sprache' : 'Language',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _select(context),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.language, size: 26, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Profil-Avatar im Header: Firmen-/Profilfoto aus `users/{uid}`
/// (`profilePhotoBase64`, sonst `profilePhotoStorageUrl`), Fallback sind
/// die Initialen des Firmennamens auf grünem Verlauf.
class _HeaderProfileAvatar extends StatelessWidget {
  const _HeaderProfileAvatar({required this.profile, required this.onTap});

  final Map<String, dynamic> profile;
  final VoidCallback onTap;

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final name =
        (profile['companyName'] ?? profile['dspName'] ?? profile['name'] ?? '')
            .toString();

    ImageProvider? image;
    final b64 = (profile['profilePhotoBase64'] ?? '').toString().trim();
    if (b64.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(b64));
      } catch (_) {}
    }
    if (image == null) {
      final url = (profile['profilePhotoStorageUrl'] ?? '').toString().trim();
      if (url.isNotEmpty) image = NetworkImage(url);
    }

    return Tooltip(
      message: de ? 'Profil' : 'Profile',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: image == null
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0D8A60), Color(0xFF14A878)],
                        )
                      : null,
                  image: image == null
                      ? null
                      : DecorationImage(image: image, fit: BoxFit.cover),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                alignment: Alignment.center,
                child: image == null
                    ? Text(
                        _initials(name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Schwebende Bottom-Navigation (nur mobil)
// ---------------------------------------------------------------------------

/// Dunkle Variante der Fahrer-App-Bottom-Bar: schwebende Pill im Navy des
/// Headers. Erste Kachel öffnet das Seitenmenü, danach die fünf
/// Haupt-Bereiche. Aktiv = grün, inaktiv = gedämpftes Hellgrau.
class _AdminMobileBottomNav extends StatelessWidget {
  const _AdminMobileBottomNav({
    required this.active,
    required this.onSelect,
    required this.onOpenMenu,
  });

  final AppNav active;
  final ValueChanged<AppNav> onSelect;
  final VoidCallback onOpenMenu;

  static const Color _bar = Color(0xFF0B1220);
  static const Color _activeColor = Color(0xFF14A878);
  static const Color _idleColor = Color(0xFF9BA6B7);

  /// Gesamthöhe der Pille (Item-Höhe + vertikales Innenpadding) — die Shell
  /// reserviert damit exakt so viel Platz, wie die Bar wirklich braucht.
  static const double itemHeight = 54;
  static const double verticalPadding = 8;
  static const double barHeight = itemHeight + verticalPadding * 2;

  /// Abstand der Bar zum unteren Rand (zusätzlich zur SafeArea).
  static const double bottomMargin = 22;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    final items = <({AppNav nav, IconData icon, String label})>[
      (nav: AppNav.home, icon: Icons.home_outlined, label: 'Home'),
      (
        nav: AppNav.drivers,
        icon: Icons.badge_outlined,
        label: de ? 'Fahrer' : 'Drivers',
      ),
      (nav: AppNav.dashboard, icon: Icons.dashboard, label: 'Scorecard'),
      (
        nav: AppNav.fleetStatus,
        icon: Icons.local_shipping_outlined,
        label: 'Fleet',
      ),
      (
        nav: AppNav.recruiting,
        icon: Icons.work_outline_rounded,
        label: 'Recruiting',
      ),
    ];

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: _bar,
        // Echte Pille — vollständig abgerundet.
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: _NavItem(
                icon: item.icon,
                label: item.label,
                selected: active == item.nav,
                onTap: () => onSelect(item.nav),
                activeColor: _activeColor,
                idleColor: _idleColor,
              ),
            ),
          const SizedBox(width: 4),
          // Runde Menü-Kachel ganz rechts, vertikal mittig — etwas heller
          // als die Bar.
          Tooltip(
            message: de ? 'Menü' : 'Menu',
            waitDuration: const Duration(milliseconds: 500),
            child: Material(
              color: Colors.white.withValues(alpha: 0.14),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onOpenMenu,
                child: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(Icons.menu, size: 25, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.idleColor,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color idleColor;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : idleColor;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _AdminMobileBottomNav.itemHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kreisrunder Hintergrund hinter jedem Icon; aktiv = grüner
              // Tint, inaktiv = dezente helle Fläche auf dem Navy.
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? activeColor.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.08),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
