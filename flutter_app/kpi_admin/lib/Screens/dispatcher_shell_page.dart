// lib/Screens/dispatcher_shell_page.dart
//
// Shell for users with role='dispatcher'. Mirrors AdminShellPage
// visually, but:
//   1. Filters the side menu to only the modules the parent admin
//      enabled in users/{adminUid}/sub_accounts/{dispatcherUid}.permissions
//   2. Wraps the entire body in [AdminScope] so module-level Firestore
//      reads/writes target the parent admin's data namespace once the
//      modules migrate from `currentUser.uid` to
//      `AdminScope.adminUidOf(context)`.
//
// Phase 1 ships the navigation + permission gate. Per-module
// retrofitting (currentUser.uid → AdminScope.adminUidOf) happens in
// follow-up commits.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/admin_scope.dart';
import 'login_page.dart';

// Module bodies — same as AdminShellPage.
import 'admin_home_page.dart';
import 'admin_waveplan_page.dart';
import 'admin_calendar_page.dart';
import 'admin_dispatcher_pill_page.dart';
import 'admin_faq_page.dart';
import 'admin_incident_reports_page.dart';
import 'admin_shift_absence_page.dart';
import 'admin_academy_page.dart';
import 'admin_approvals_page.dart';
import 'dsp_profile_page.dart';
import 'drivers_hub_page.dart';
import 'feedback_page.dart';
import 'fleet_status_page.dart';
import 'task_sheet_page.dart';

/// Permission key → (icon, label, page) used to render the nav and
/// resolve the active page.
class _ModuleEntry {
  final String key;
  final IconData icon;
  final String label;
  final Widget page;
  const _ModuleEntry({
    required this.key,
    required this.icon,
    required this.label,
    required this.page,
  });
}

const List<_ModuleEntry> _kAllModules = [
  _ModuleEntry(
    key: 'waveplan',
    icon: Icons.waves_rounded,
    label: 'Waveplan',
    page: AdminWaveplanPage(),
  ),
  _ModuleEntry(
    key: 'calendar',
    icon: Icons.calendar_month_rounded,
    label: 'Kalender',
    page: AdminCalendarPage(),
  ),
  _ModuleEntry(
    key: 'drivers_hub',
    icon: Icons.groups_rounded,
    label: 'Drivers Hub',
    page: DriversHubPage(),
  ),
  _ModuleEntry(
    key: 'tasks',
    icon: Icons.task_alt_rounded,
    label: 'Tasks',
    page: TaskSheetPage(),
  ),
  _ModuleEntry(
    key: 'shift_absence',
    icon: Icons.event_busy_rounded,
    label: 'Shift & Absence',
    page: AdminShiftAbsencePage(),
  ),
  _ModuleEntry(
    key: 'fleet_status',
    icon: Icons.local_shipping_rounded,
    label: 'Fleet Hub',
    page: FleetStatusPage(),
  ),
  _ModuleEntry(
    key: 'incident_reports',
    icon: Icons.report_gmailerrorred_rounded,
    label: 'Incident Reports',
    page: AdminIncidentReportsPage(),
  ),
  _ModuleEntry(
    key: 'academy',
    icon: Icons.school_rounded,
    label: 'Academy',
    page: AdminAcademyPage(),
  ),
  _ModuleEntry(
    key: 'dispatcher_pill',
    icon: Icons.support_agent_rounded,
    label: 'Dispatcher Pill',
    page: AdminDispatcherPillPage(),
  ),
  _ModuleEntry(
    key: 'feedback',
    icon: Icons.feedback_rounded,
    label: 'Feedback',
    page: FeedbackPage(),
  ),
  _ModuleEntry(
    key: 'faqs',
    icon: Icons.help_outline_rounded,
    label: 'FAQs',
    page: AdminFaqPage(),
  ),
  _ModuleEntry(
    key: 'approvals',
    icon: Icons.verified_user_outlined,
    label: 'Approvals',
    page: AdminApprovalsPage(),
  ),
];

class DispatcherShellPage extends StatefulWidget {
  final String parentAdminUid;
  const DispatcherShellPage({super.key, required this.parentAdminUid});

  @override
  State<DispatcherShellPage> createState() => _DispatcherShellPageState();
}

class _DispatcherShellPageState extends State<DispatcherShellPage> {
  /// `'home'` | `<permission_key>` | `'profile'`
  String _active = 'home';

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) return const LoginPage();

    final subRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.parentAdminUid)
        .collection('sub_accounts')
        .doc(auth.uid);

    return AdminScope(
      adminUid: widget.parentAdminUid,
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: subRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final data = snap.data?.data() ?? const <String, dynamic>{};
          final active = data['active'] != false;
          final permissions = (data['permissions'] as Map?)
                  ?.map((k, v) => MapEntry(k.toString(), v == true)) ??
              const <String, bool>{};

          if (!active) {
            return const _DispatcherDisabled();
          }

          final allowed = _kAllModules
              .where((m) => permissions[m.key] == true)
              .toList();

          // If the previously-active module got revoked, fall back to home.
          if (_active != 'home' &&
              _active != 'profile' &&
              !allowed.any((m) => m.key == _active)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _active = 'home');
            });
          }

          final body = _bodyFor(_active, allowed);
          final isNarrow = MediaQuery.of(context).size.width < 1100;

          return Scaffold(
            backgroundColor: AppColors.surfaceLight,
            drawer: isNarrow
                ? Drawer(
                    child: SafeArea(
                      child: _DispatcherSideMenu(
                        active: _active,
                        allowed: allowed,
                        onSelect: (k) {
                          setState(() => _active = k);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  )
                : null,
            appBar: isNarrow
                ? AppBar(
                    backgroundColor: const Color(0xFF0B1220),
                    foregroundColor: Colors.white,
                    title: Image.asset(
                      'assets/Codriver_logo_dark.png',
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                    centerTitle: true,
                  )
                : null,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isNarrow)
                  SizedBox(
                    width: 300,
                    child: _DispatcherSideMenu(
                      active: _active,
                      allowed: allowed,
                      onSelect: (k) => setState(() => _active = k),
                    ),
                  ),
                Expanded(child: body),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bodyFor(String key, List<_ModuleEntry> allowed) {
    if (key == 'home') return const AdminHomePage();
    if (key == 'profile') return const DspProfilePage();
    final match = allowed.where((m) => m.key == key);
    if (match.isNotEmpty) return match.first.page;
    return const AdminHomePage();
  }
}

class _DispatcherSideMenu extends StatelessWidget {
  final String active;
  final List<_ModuleEntry> allowed;
  final ValueChanged<String> onSelect;
  const _DispatcherSideMenu({
    required this.active,
    required this.allowed,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0B1220);
    return Container(
      color: dark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/Codriver_logo_dark.png',
                width: 300,
                height: 61,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Dispatcher',
                  style: AppTypography.caption1.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        active: active == 'home',
                        onTap: () => onSelect('home'),
                      ),
                      for (final m in allowed)
                        _NavItem(
                          icon: m.icon,
                          label: m.label,
                          active: active == m.key,
                          onTap: () => onSelect(m.key),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white24, height: 24),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                active: active == 'profile',
                onTap: () => onSelect('profile'),
              ),
              const SizedBox(height: 6),
              _NavItem(
                icon: Icons.logout_rounded,
                label: 'Abmelden',
                active: false,
                onTap: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: active
              ? AppColors.codriverGreen.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppColors.codriverGreen : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DispatcherDisabled extends StatelessWidget {
  const _DispatcherDisabled();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: AppColors.warning,
              ),
              const SizedBox(height: 12),
              Text(
                'Dein Dispatcher-Zugang ist deaktiviert.',
                style: AppTypography.title3.copyWith(
                  color: AppColors.codriverGraphite,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Bitte wende dich an deinen Admin.',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Abmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
