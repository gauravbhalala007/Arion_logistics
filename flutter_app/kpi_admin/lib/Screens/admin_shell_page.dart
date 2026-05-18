// lib/screens/admin_shell_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';
import 'login_page.dart';

// your existing pages
import 'admin_home_page.dart';
import 'scorecard_overview.dart';
import 'pod_quality_overview.dart';
import 'concessions_overview.dart';
import 'drivers_hub_page.dart';
import 'admin_waveplan_page.dart';
import 'admin_calendar_page.dart';
import 'task_sheet_page.dart';
import 'admin_zeiten_abwesenheiten_page.dart';
import 'admin_incident_reports_page.dart';
import 'notifications_page.dart';
import 'admin_approvals_page.dart';
import 'admin_faq_page.dart';
import 'admin_academy_page.dart';
import 'admin_dispatcher_pill_page.dart';
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

class AdminShellPage extends StatefulWidget {
  final AppNav initialNav;

  const AdminShellPage({super.key, this.initialNav = AppNav.home});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  late AppNav _active = widget.initialNav;
  bool _redirectingToLogin = false;
  bool _redirectingToRoot = false;

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
        final isDispatcherShell =
            role == 'dispatcher' && adminScope != null;

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

        return AppShell(
          menuWidth: 300,
          centerTitle: true,
          appBarBackgroundColor: const Color(0xFF0B1220),
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
                ),
          sideMenu: AppSideMenu(
            width: 300,
            active: _active,
            onSelect: (nav) {
              if (nav == _active) return;
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
          body: IndexedStack(
            index: _indexFor(_active),
            children: [
              _lazy(AppNav.home, () => const AdminHomePage()),
              _lazy(AppNav.dashboard, () => const ScorecardOverviewPage()),
              _lazy(AppNav.podQuality, () => const PodQualityOverviewPage()),
              _lazy(AppNav.concessions, () => const ConcessionsOverviewPage()),
              _lazy(AppNav.drivers, () => const DriversHubPage()),
              _lazy(AppNav.waveplan, () => const AdminWaveplanPage()),
              _lazy(AppNav.calendar, () => const AdminCalendarPage()),
              _lazy(AppNav.fleetStatus, () => const FleetStatusPage()),
              _lazy(AppNav.tasks, () => const TaskSheetPage()),
              _lazy(AppNav.shiftAbsence,
                  () => const AdminZeitenAbwesenheitenPage()),
              _lazy(AppNav.incidentReports,
                  () => const AdminIncidentReportsPage()),
              _lazy(AppNav.academy, () => const AdminAcademyPage()),
              _lazy(AppNav.dispatcherPill,
                  () => const AdminDispatcherCenterPage()),
              _lazy(AppNav.notifications, () => const NotificationsPage()),
              _lazy(AppNav.feedback, () => const FeedbackPage()),
              _lazy(AppNav.faqs, () => const AdminFaqPage()),
              _lazy(AppNav.adminApprovals, () => const AdminApprovalsPage()),
              _lazy(AppNav.dispatchers, () => const AdminDispatchersPage()),
              _lazy(AppNav.profile, () => const DspProfilePage()),
              _lazy(AppNav.styleguide, () => const AdminStyleguidePage()),
              _lazy(AppNav.cotimer, () => const AdminCotimerPage()),
              _lazy(AppNav.inventory, () => const AdminInventoryPage()),
              _lazy(AppNav.cart, () => const AdminCartPage()),
              _lazy(AppNav.shiftPlan, () => const AdminShiftPlanPage()),
            ],
          ),
        );
      },
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
      case AppNav.drivers:
        return 4;
      case AppNav.waveplan:
        return 5;
      case AppNav.calendar:
        return 6;
      case AppNav.fleetStatus:
        return 7;
      case AppNav.tasks:
        return 8;
      case AppNav.shiftAbsence:
        return 9;
      case AppNav.incidentReports:
        return 10;
      case AppNav.academy:
        return 11;
      case AppNav.dispatcherPill:
        return 12;
      case AppNav.notifications:
        return 13;
      case AppNav.feedback:
        return 14;
      case AppNav.faqs:
        return 15;
      case AppNav.adminApprovals:
        return 16;
      case AppNav.dispatchers:
        return 17;
      case AppNav.profile:
        return 18;
      case AppNav.styleguide:
        return 19;
      case AppNav.cotimer:
        return 20;
      case AppNav.inventory:
        return 21;
      case AppNav.cart:
        return 22;
      case AppNav.shiftPlan:
        return 23;
      default:
        return 0;
    }
  }
}
