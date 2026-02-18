// lib/screens/admin_shell_page.dart
import 'package:flutter/material.dart';

import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';

// your existing pages
import 'admin_home_page.dart';
import 'scorecard_overview.dart';
import 'pod_quality_overview.dart';
import 'drivers_hub_page.dart';
import 'task_sheet_page.dart';
import 'notifications_page.dart';
import 'admin_approvals_page.dart';
import 'admin_faq_page.dart';
import 'dsp_profile_page.dart';

class AdminShellPage extends StatefulWidget {
  final AppNav initialNav;

  const AdminShellPage({super.key, this.initialNav = AppNav.home});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  late AppNav _active = widget.initialNav;

  bool _isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 1100;

  @override
  Widget build(BuildContext context) {
    final narrow = _isNarrow(context);

    return AppShell(
      menuWidth: 300,
      sideMenu: AppSideMenu(
        width: 300,
        active: _active,
        onSelect: (nav) => setState(() => _active = nav),
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
          TaskSheetPage(),
          NotificationsPage(),
          AdminFaqPage(),
          AdminApprovalsPage(),
          DspProfilePage(),
        ],
      ),
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
      case AppNav.tasks:
        return 4;
      case AppNav.notifications:
        return 5;
      case AppNav.faqs:
        return 6;
      case AppNav.adminApprovals:
        return 7;
      case AppNav.profile:
        return 8;
      default:
        return 0;
    }
  }
}
