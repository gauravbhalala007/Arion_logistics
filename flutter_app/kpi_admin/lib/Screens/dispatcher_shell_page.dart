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

// Module bodies — full parity with AdminShellPage.
import 'admin_home_page.dart';
import 'admin_waveplan_page.dart';
import 'admin_calendar_page.dart';
import 'admin_dispatcher_center_page.dart';
import 'admin_faq_page.dart';
import 'admin_incident_reports_page.dart';
import 'admin_shift_plan_page.dart';
import 'admin_zeiten_abwesenheiten_page.dart';
import 'admin_academy_page.dart';
import 'admin_approvals_page.dart';
import 'dsp_profile_page.dart';
import 'drivers_hub_page.dart';
import 'feedback_page.dart';
import 'fleet_status_page.dart';
import 'task_sheet_page.dart';
import '../widgets/new_version_gate.dart';
import 'admin_contacts_page.dart';
import 'admin_cotimer_page.dart';
import 'admin_inventory_page.dart';
import 'admin_monthly_plan_page.dart';
import 'admin_payment_check_page.dart';
import 'admin_recruiting_page.dart';
import 'admin_vehicle_check_page.dart';
import 'cdf_overview.dart';
import 'concessions_overview.dart';
import 'contact_compliance_overview.dart';
import 'dwc_overview.dart';
import 'scorecard_overview.dart';
import 'pod_quality_overview.dart';
import 'notifications_page.dart';

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
    key: 'dashboard',
    icon: Icons.dashboard_rounded,
    label: 'Score Card Dashboard',
    page: ScorecardOverviewPage(),
  ),
  _ModuleEntry(
    key: 'pod_quality',
    icon: Icons.photo_camera_outlined,
    label: 'POD Quality',
    page: PodQualityOverviewPage(),
  ),
  _ModuleEntry(
    key: 'drivers_hub',
    icon: Icons.groups_rounded,
    label: 'Drivers Hub',
    page: DriversHubPage(),
  ),
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
    key: 'fleet_status',
    icon: Icons.local_shipping_rounded,
    label: 'Fleet Hub',
    page: FleetStatusPage(),
  ),
  _ModuleEntry(
    key: 'tasks',
    icon: Icons.task_alt_rounded,
    label: 'Tasks',
    page: TaskSheetPage(),
  ),
  // Ticket „Sub accounts sollen alles sehen, was der Admin erlaubt":
  // fehlende Admin-Module fuer Sub-Accounts freigeschaltet. Sichtbar
  // ist, was die Dispatcher-Center-Schalter erlauben (fehlender
  // Schalter = erlaubt).
  _ModuleEntry(
    key: 'concessions',
    icon: Icons.report_gmailerrorred_outlined,
    label: 'Concessions',
    page: ConcessionsOverviewPage(),
  ),
  _ModuleEntry(
    key: 'cdf',
    icon: Icons.feedback_outlined,
    label: 'Customer Feedback',
    page: CdfOverviewPage(),
  ),
  _ModuleEntry(
    key: 'dwc',
    icon: Icons.verified_user_outlined,
    label: 'DWC / IADC',
    page: DwcOverviewPage(),
  ),
  _ModuleEntry(
    key: 'contact_compliance',
    icon: Icons.phone_in_talk_outlined,
    label: 'Contact Compliance',
    page: ContactComplianceOverviewPage(),
  ),
  _ModuleEntry(
    key: 'recruiting',
    icon: Icons.badge_outlined,
    label: 'Recruiting',
    page: AdminRecruitingPage(),
  ),
  _ModuleEntry(
    key: 'monthly_plan',
    icon: Icons.calendar_view_month_rounded,
    label: 'Monthly Plan',
    page: AdminMonthlyPlanPage(),
  ),
  _ModuleEntry(
    key: 'contacts',
    icon: Icons.contacts_outlined,
    label: 'Kontakte',
    page: AdminContactsPage(),
  ),
  _ModuleEntry(
    key: 'vehicle_check',
    icon: Icons.checklist_rounded,
    label: 'Vehicle Check',
    page: AdminVehicleCheckPage(),
  ),
  _ModuleEntry(
    key: 'inventory',
    icon: Icons.inventory_2_outlined,
    label: 'Inventar',
    page: AdminInventoryPage(),
  ),
  _ModuleEntry(
    key: 'cotimer',
    icon: Icons.timer_outlined,
    label: 'CoTimer',
    page: AdminCotimerPage(),
  ),
  _ModuleEntry(
    key: 'payment_check',
    icon: Icons.request_quote_outlined,
    label: 'Payment Check',
    page: AdminPaymentCheckPage(),
  ),
  _ModuleEntry(
    key: 'shift_plan',
    icon: Icons.event_note_rounded,
    label: 'Shift Plan',
    page: AdminShiftPlanPage(),
  ),
  _ModuleEntry(
    key: 'shift_absence',
    icon: Icons.event_busy_rounded,
    label: 'Zeiten & Abwesenheiten',
    page: AdminZeitenAbwesenheitenPage(),
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
    label: 'Dispatcher Center',
    page: AdminDispatcherCenterPage(),
  ),
  _ModuleEntry(
    key: 'notifications',
    icon: Icons.notifications_outlined,
    label: 'Notifications',
    page: NotificationsPage(),
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
          final displayName =
              (data['name'] ??
                      data['email'] ??
                      auth.displayName ??
                      auth.email ??
                      '')
                  .toString();

          if (!active) {
            return const _DispatcherDisabled();
          }

          // Sichtbar ist, was die Schalter im Dispatcher Center
          // erlauben (Anlegen-Dialog: Standard alles an). Fehlender
          // Schluessel = erlaubt (neue Module). Alt-Konten aus der
          // Vollparitaets-Aera tragen Maps mit AUSSCHLIESSLICH false —
          // die waren nie eine Admin-Entscheidung: ohne ein einziges
          // true bleibt die volle Sicht, bis der Admin einmal speichert.
          final perms = (data['permissions'] as Map?)
                  ?.map((k, v) => MapEntry(k.toString(), v == true)) ??
              const <String, bool>{};
          final managed = perms.values.any((v) => v);
          final allowed = !managed
              ? List<_ModuleEntry>.from(_kAllModules)
              : _kAllModules
                  .where((m) => !perms.containsKey(m.key) || perms[m.key]!)
                  .toList(growable: false);

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

          return NewVersionGate(
            child: Scaffold(
              backgroundColor: AppColors.surfaceLight,
              drawer: isNarrow
                  ? Drawer(
                      child: SafeArea(
                        child: _DispatcherSideMenu(
                          active: _active,
                          allowed: allowed,
                          displayName: displayName,
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
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Codriver_logo_dark.png',
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          if (displayName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Dispatcher: $displayName',
                              style: AppTypography.caption2.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ],
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
                        displayName: displayName,
                        onSelect: (k) => setState(() => _active = k),
                      ),
                    ),
                  Expanded(child: body),
                ],
              ),
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
  final String displayName;
  final ValueChanged<String> onSelect;
  const _DispatcherSideMenu({
    required this.active,
    required this.allowed,
    required this.displayName,
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
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.codriverGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.codriverGreen.withOpacity(0.32),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      size: 16,
                      color: AppColors.codriverGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'DISPATCHER',
                            style: AppTypography.caption2.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                              fontSize: 9.5,
                            ),
                          ),
                          if (displayName.isNotEmpty)
                            Text(
                              displayName,
                              style: AppTypography.footnote.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
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
    final de = Localizations.localeOf(context).languageCode == 'de';
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
                de
                    ? 'Dein Dispatcher-Zugang ist deaktiviert.'
                    : 'Your dispatcher access is disabled.',
                style: AppTypography.title3.copyWith(
                  color: AppColors.codriverGraphite,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                de
                    ? 'Bitte wende dich an deinen Admin.'
                    : 'Please contact your admin.',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: Text(de ? 'Abmelden' : 'Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
