// lib/screens/admin_shell_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';
import 'login_page.dart';

// your existing pages
import 'admin_home_page.dart';
import 'scorecard_overview.dart';
import 'pod_quality_overview.dart';
import 'drivers_hub_page.dart';
import 'admin_waveplan_page.dart';
import 'admin_calendar_page.dart';
import 'task_sheet_page.dart';
import 'admin_shift_absence_page.dart';
import 'admin_incident_reports_page.dart';
import 'notifications_page.dart';
import 'admin_approvals_page.dart';
import 'admin_faq_page.dart';
import 'admin_academy_page.dart';
import 'admin_dispatcher_pill_page.dart';
import 'dsp_profile_page.dart';
import 'feedback_page.dart';
import 'fleet_status_page.dart';

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

        // ✅ Prevent driver accounts from opening AdminShell routes directly.
        if (role == 'driver' || !approved) {
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

        return AppShell(
          menuWidth: 300,
          centerTitle: true,
          appBarBackgroundColor: const Color(0xFF0B1220),
          appBarForegroundColor: Colors.white,
          appBarToolbarHeight: 72,
          title: Image.asset(
            'assets/Codriver_logo_dark.png',
            height: 38,
            fit: BoxFit.contain,
          ),
          sideMenu: AppSideMenu(
            width: 300,
            active: _active,
            onSelect: (nav) {
              if (nav == _active) return;
              setState(() => _active = nav);
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
            children: const [
              AdminHomePage(),
              ScorecardOverviewPage(),
              PodQualityOverviewPage(),
              DriversHubPage(),
              AdminWaveplanPage(),
              AdminCalendarPage(),
              FleetStatusPage(),
              TaskSheetPage(),
              AdminShiftAbsencePage(),
              AdminIncidentReportsPage(),
              AdminAcademyPage(),
              AdminDispatcherPillPage(),
              NotificationsPage(),
              FeedbackPage(),
              AdminFaqPage(),
              AdminApprovalsPage(),
              DspProfilePage(),
            ],
          ),
        );
      },
    );
  }

  int _indexFor(AppNav nav) {
    switch (nav) {
      case AppNav.home:
        return 0;
      case AppNav.dashboard:
        return 1;
      case AppNav.podQuality:
        return 2;
      case AppNav.drivers:
        return 3;
      case AppNav.waveplan:
        return 4;
      case AppNav.calendar:
        return 5;
      case AppNav.fleetStatus:
        return 6;
      case AppNav.tasks:
        return 7;
      case AppNav.shiftAbsence:
        return 8;
      case AppNav.incidentReports:
        return 9;
      case AppNav.academy:
        return 10;
      case AppNav.dispatcherPill:
        return 11;
      case AppNav.notifications:
        return 12;
      case AppNav.feedback:
        return 13;
      case AppNav.faqs:
        return 14;
      case AppNav.adminApprovals:
        return 15;
      case AppNav.profile:
        return 16;
      default:
        return 0;
    }
  }
}
