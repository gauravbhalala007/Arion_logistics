// lib/widgets/app_side_menu.dart
import 'dart:convert'; // for base64Decode
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Screens/owner_insights_page.dart';
import '../services/admin_expiry_aggregator.dart';
import '../services/admin_notifications_service.dart';
import '../services/auth_service.dart';
import 'admin_scope.dart';
import '../localization/app_localizations.dart';
import '../utils/inventory_l10n.dart';

/// Schalter fuer die monatliche Fahrerbewertung.
///
/// Auf `false` verschwindet der Menuepunkt und die Karte im Drivers Hub;
/// Seiten, Datenmodell und bereits erfasste Bewertungen bleiben
/// unveraendert bestehen. Zum Wiedereinschalten hier auf `true` setzen.
const bool kDriverReviewsEnabled = false;

enum AppNav {
  home,
  dashboard,
  podQuality,
  concessions,
  cdf,
  dwc,
  drivers,
  recruiting,
  waveplan,
  calendar,
  fleetStatus,
  tasks,
  shiftAbsence,
  daRequests,
  safetyTraining,
  driverReviews,
  incidentReports,
  academy,
  dispatcherPill,
  notifications,
  appUpdates,
  feedback,
  faqs,
  comingSoon,
  adminApprovals,
  dispatchers,
  profile,
  styleguide,
  cotimer,
  inventory,
  cart,
  shiftPlan,
  paymentCheck,
  monthlyPlan,
  contactCompliance,
}

class AppSideMenu extends StatelessWidget {
  final double width;
  final AppNav active;

  /// NEW: If provided, menu will switch tabs INSIDE AdminShellPage (IndexedStack).
  final ValueChanged<AppNav>? onSelect;

  /// NEW: Optional helper for narrow screens to close the Drawer after tap.
  final VoidCallback? closeDrawerIfOpen;

  /// Collapsed rail mode — icons only, labels appear as a hover
  /// flyout in the accent colour. Toggled via [onToggleCollapsed].
  final bool collapsed;
  final VoidCallback? onToggleCollapsed;

  const AppSideMenu({
    super.key,
    required this.width,
    required this.active,
    this.onSelect,
    this.closeDrawerIfOpen,
    this.collapsed = false,
    this.onToggleCollapsed,
  });

  /// Counts the current user's OWN feedback entries that flipped to
  /// `done` after they last opened the feedback page.
  ///
  /// Die Logik liegt in [AdminNotificationsService], damit Menue-Badge
  /// und Glocken-Panel garantiert dieselbe Zahl zeigen.
  Stream<int> _feedbackDoneBadgeStream() =>
      AdminNotificationsService.watchResolvedFeedback();

  void _handleNav(BuildContext context, AppNav nav, String routeName) {
    // If AdminShellPage is controlling selection -> no navigation push.
    if (onSelect != null) {
      onSelect!(nav);
      closeDrawerIfOpen?.call();
      return;
    }

    // Fallback: old behavior (route navigation)
    final current = ModalRoute.of(context)?.settings.name;
    if (current != routeName) {
      Navigator.of(context).pushNamedAndRemoveUntil(routeName, (r) => false);
    }
  }

  /// A role-gated menu group: shows its header + [items] only for approved
  /// admin/user/developer accounts, otherwise nothing (so the header never
  /// appears without content).
  Widget _roleSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userDocStream(),
      builder: (context, snap) {
        final data = snap.data?.data() ?? const <String, dynamic>{};
        final role = (data['role'] ?? '').toString().trim().toLowerCase();
        final approved = data['approved'] == true;
        final canSee = approved &&
            (role == 'admin' || role == 'user' || role == 'developer');
        if (!canSee) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_SectionHeader(title), ...items],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0B1220);
    final t = AppLocalizations.of(context);

    final navItems = <Widget>[
      // ── Shortlinks (Favoriten) ──
      // Nur am Desktop und nur in der ausgeklappten Leiste: die
      // Icons-only-Schiene ist selbst schon eine Kurzwahl, und mobil
      // führt die schwebende Bottom-Nav durch die Hauptseiten.
      if (!collapsed && MediaQuery.sizeOf(context).width >= 1100)
        _ShortcutsBar(
          onOpen: (nav, route) => _handleNav(context, nav, route),
        ),

      // ── Overview ──
      _SectionHeader(_groupTitle(context, 'overview')),
      _MenuItem(
        icon: Icons.home_outlined,
        label: 'Home',
        active: active == AppNav.home,
        onTap: () => _handleNav(context, AppNav.home, '/home'),
      ),
      _MenuItem(
        icon: Icons.gavel_rounded,
        label: 'Company Rules',
        active: active == AppNav.notifications,
        onTap: () =>
            _handleNav(context, AppNav.notifications, '/notifications'),
      ),
      _MenuItem(
        icon: Icons.campaign_outlined,
        label: 'Updates',
        active: active == AppNav.appUpdates,
        onTap: () => _handleNav(context, AppNav.appUpdates, '/app-updates'),
      ),

      // ── Performance ──
      _SectionHeader(_groupTitle(context, 'performance')),
      _MenuItem(
        icon: Icons.dashboard,
        label: 'Score Card Dashboard',
        active: active == AppNav.dashboard,
        onTap: () => _handleNav(context, AppNav.dashboard, '/dashboard'),
      ),
      _SubMenuItem(
        icon: Icons.photo_camera_outlined,
        label: 'POD Quality',
        active: active == AppNav.podQuality,
        onTap: () => _handleNav(context, AppNav.podQuality, '/pod-quality'),
      ),
      _SubMenuItem(
        icon: Icons.report_gmailerrorred_outlined,
        label: 'Concessions',
        active: active == AppNav.concessions,
        onTap: () => _handleNav(context, AppNav.concessions, '/concessions'),
      ),
      _SubMenuItem(
        icon: Icons.feedback_outlined,
        label: 'Customer Feedback',
        active: active == AppNav.cdf,
        onTap: () => _handleNav(context, AppNav.cdf, '/cdf'),
      ),
      _SubMenuItem(
        icon: Icons.verified_user_outlined,
        label: 'DWC / IADC',
        active: active == AppNav.dwc,
        onTap: () => _handleNav(context, AppNav.dwc, '/dwc'),
      ),
      _SubMenuItem(
        icon: Icons.phone_in_talk_outlined,
        label: 'Contact Compliance',
        active: active == AppNav.contactCompliance,
        onTap: () => _handleNav(
            context, AppNav.contactCompliance, '/contact-compliance'),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'FAQs',
        active: active == AppNav.faqs,
        onTap: () => _handleNav(context, AppNav.faqs, '/faqs'),
      ),
      _MenuItem(
        icon: Icons.school_outlined,
        label: 'DA Academy',
        active: active == AppNav.academy,
        onTap: () => _handleNav(context, AppNav.academy, '/academy'),
      ),

      // ── Planning & Operations ──
      _SectionHeader(_groupTitle(context, 'planning')),
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userDocStream(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? const <String, dynamic>{};
          final role = (data['role'] ?? '').toString().trim().toLowerCase();
          final approved = data['approved'] == true;
          final canSee = approved &&
              (role == 'admin' || role == 'user' || role == 'developer');
          if (!canSee) return const SizedBox.shrink();
          return _MenuItem(
            icon: Icons.event_note_rounded,
            label: 'Shift Plan',
            active: active == AppNav.shiftPlan,
            onTap: () => _handleNav(context, AppNav.shiftPlan, '/shift-plan'),
            betaBadge: true,
          );
        },
      ),
      _MenuItem(
        icon: Icons.waves_rounded,
        label: 'Waveplan',
        active: active == AppNav.waveplan,
        onTap: () => _handleNav(context, AppNav.waveplan, '/waveplan'),
      ),
      // Ticket: Monthly Plan direkt neben dem Waveplan (vorher am Ende
      // in der Finance-Sektion). Role-Gating wie dort beibehalten.
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userDocStream(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? const <String, dynamic>{};
          final role =
              (data['role'] ?? '').toString().trim().toLowerCase();
          final approved = data['approved'] == true;
          final canSee = approved &&
              (role == 'admin' || role == 'user' || role == 'developer');
          if (!canSee) return const SizedBox.shrink();
          return _MenuItem(
            icon: Icons.calendar_view_month_rounded,
            label: 'Monthly Plan',
            active: active == AppNav.monthlyPlan,
            onTap: () =>
                _handleNav(context, AppNav.monthlyPlan, '/monthly-plan'),
            betaBadge: true,
          );
        },
      ),
      _MenuItem(
        icon: Icons.calendar_month_rounded,
        label: Localizations.localeOf(context).languageCode == 'de'
            ? 'Kalender'
            : 'Calendar',
        active: active == AppNav.calendar,
        onTap: () => _handleNav(context, AppNav.calendar, '/calendar'),
      ),
      _MenuItem(
        icon: Icons.task_alt_outlined,
        label: 'Task Sheet',
        active: active == AppNav.tasks,
        onTap: () => _handleNav(context, AppNav.tasks, '/tasks'),
      ),
      _MenuItem(
        icon: Icons.support_agent_rounded,
        label: 'Dispatcher Center',
        active: active == AppNav.dispatcherPill,
        onTap: () =>
            _handleNav(context, AppNav.dispatcherPill, '/dispatcher-pill'),
      ),
      _ownerOnly(
        _MenuItem(
          icon: Icons.timer_outlined,
          label: 'co:timer',
          active: active == AppNav.cotimer,
          onTap: () => _handleNav(context, AppNav.cotimer, '/cotimer'),
        ),
      ),

      // ── Team ──
      _SectionHeader(_groupTitle(context, 'team')),
      StreamBuilder<int>(
        stream: () {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid == null) return Stream.value(0);
          return AdminExpiryAggregator().watchUnreadTotal(uid);
        }(),
        builder: (context, snap) => _MenuItem(
          icon: Icons.badge_outlined,
          label: 'Drivers Hub',
          active: active == AppNav.drivers,
          onTap: () => _handleNav(context, AppNav.drivers, '/drivers'),
          badgeCount: snap.data ?? 0,
        ),
      ),
      _MenuItem(
        icon: Icons.work_outline_rounded,
        label: 'Recruiting',
        active: active == AppNav.recruiting,
        onTap: () => _handleNav(context, AppNav.recruiting, '/recruiting'),
      ),
      _MenuItem(
        icon: Icons.schedule_rounded,
        label: Localizations.localeOf(context).languageCode == 'de'
            ? 'Zeiten & Abwesenheiten'
            : 'Time & Absence',
        active: active == AppNav.shiftAbsence,
        onTap: () => _handleNav(context, AppNav.shiftAbsence, '/shift-absence'),
      ),
      StreamBuilder<int>(
        stream: AdminNotificationsService.watchOpenDaRequests(
          AdminScope.adminUidOf(context),
        ),
        builder: (context, snap) => _MenuItem(
          icon: Icons.request_page_outlined,
          label: 'DA Requests',
          active: active == AppNav.daRequests,
          onTap: () => _handleNav(context, AppNav.daRequests, '/da-requests'),
          badgeCount: snap.data ?? 0,
        ),
      ),
      // Fahrerbewertung ist vorerst ausgeblendet — das Feature bleibt
      // vollstaendig erhalten (Seite, Modell, Auswertung) und wird
      // spaeter wieder eingehaengt, sobald Zweckbindung, Aufbewahrung
      // und ggf. Mitbestimmung geklaert sind.
      if (kDriverReviewsEnabled)
        _MenuItem(
          icon: Icons.star_outline_rounded,
          label: Localizations.localeOf(context).languageCode == 'de'
              ? 'Fahrerbewertung'
              : 'Driver Reviews',
          active: active == AppNav.driverReviews,
          onTap: () =>
              _handleNav(context, AppNav.driverReviews, '/driver-reviews'),
        ),
      _MenuItem(
        icon: Icons.health_and_safety_outlined,
        label: Localizations.localeOf(context).languageCode == 'de'
            ? 'Sicherheitsunterweisung'
            : 'Safety Instruction',
        active: active == AppNav.safetyTraining,
        onTap: () =>
            _handleNav(context, AppNav.safetyTraining, '/safety-training'),
      ),
      _MenuItem(
        icon: Icons.warning_amber_rounded,
        label: 'Incident Reports',
        active: active == AppNav.incidentReports,
        onTap: () =>
            _handleNav(context, AppNav.incidentReports, '/incident-reports'),
      ),

      // ── Fleet & Supplies (role-gated) ──
      _roleSection(context, _groupTitle(context, 'fleet'), [
        _MenuItem(
          icon: Icons.local_shipping_outlined,
          label: t.t('fleet_status_nav'),
          active: active == AppNav.fleetStatus,
          onTap: () =>
              _handleNav(context, AppNav.fleetStatus, '/fleet-status'),
        ),
        _MenuItem(
          icon: Icons.inventory_2_outlined,
          label: InvL10n.of(context).inventory,
          active: active == AppNav.inventory,
          onTap: () => _handleNav(context, AppNav.inventory, '/inventory'),
        ),
      ]),

      // ── Finance (role-gated) ──
      _roleSection(context, _groupTitle(context, 'finance'), [
        _MenuItem(
          icon: Icons.fact_check_outlined,
          label: 'Payment Check',
          active: active == AppNav.paymentCheck,
          onTap: () =>
              _handleNav(context, AppNav.paymentCheck, '/payment-check'),
          betaBadge: true,
        ),
      ]),

      // ── System & Help ──
      _SectionHeader(_groupTitle(context, 'system')),
      StreamBuilder<int>(
        stream: _feedbackDoneBadgeStream(),
        builder: (context, snap) => _MenuItem(
          icon: Icons.feedback,
          label: 'Feedback',
          active: active == AppNav.feedback,
          onTap: () => _handleNav(context, AppNav.feedback, '/feedback'),
          badgeCount: snap.data ?? 0,
        ),
      ),
      _ownerOnly(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MenuItem(
              icon: Icons.verified_user_outlined,
              label: 'User Approvals',
              active: active == AppNav.adminApprovals,
              onTap: () => _handleNav(
                context,
                AppNav.adminApprovals,
                '/admin-approvals',
              ),
            ),
            _MenuItem(
              icon: Icons.palette_outlined,
              label: 'Styleguide',
              active: active == AppNav.styleguide,
              onTap: () =>
                  _handleNav(context, AppNav.styleguide, '/styleguide'),
            ),
          ],
        ),
      ),
      // Owner-Dashboard (Nutzerzahlen aller CoDriver-Firmen): NUR für das
      // Arion-Hauptkonto sichtbar; die Seite selbst verlangt zusätzlich das
      // Passwort, das serverseitig in `getOwnerUsageStats` geprüft wird.
      Builder(
        builder: (context) {
          final email =
              FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
          if (email != 'admin@arion-logistics.de') {
            return const SizedBox.shrink();
          }
          return _MenuItem(
            icon: Icons.query_stats,
            label: 'Insights',
            active: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const OwnerInsightsPage(),
              ),
            ),
          );
        },
      ),
    ];

    return _MenuScope(
      collapsed: collapsed,
      child: Container(
      width: width,
      color: dark,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 8 : 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (collapsed)
                Center(
                  child: Tooltip(
                    message:
                        Localizations.localeOf(context).languageCode == 'de'
                            ? 'Menü ausklappen'
                            : 'Expand menu',
                    child: InkWell(
                      onTap: onToggleCollapsed,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/codriver_mark.png',
                          height: 34,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          cacheHeight: 136,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/Codriver_logo_dark.png',
                        height: 61,
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                        filterQuality: FilterQuality.high,
                        // 61 logical px × 3 (max retina) = 183 phys px.
                        // Pre-decoding at 244 gives extra headroom without
                        // blowing the cache vs the 814 source pixels.
                        cacheHeight: 244,
                      ),
                    ),
                    if (onToggleCollapsed != null)
                      IconButton(
                        tooltip:
                            Localizations.localeOf(context).languageCode == 'de'
                                ? 'Menü einklappen'
                                : 'Collapse menu',
                        onPressed: onToggleCollapsed,
                        icon: const Icon(Icons.chevron_left_rounded,
                            color: Colors.white54, size: 24),
                      ),
                  ],
                ),
              SizedBox(height: collapsed ? 6 : 18),
              const _ThinDivider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: navItems,
                  ),
                ),
              ),
              const _ThinDivider(),
              const SizedBox(height: 12),

              // ---- Profile card ----
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _userDocStream(),
                builder: (context, snap) {
                  final u = FirebaseAuth.instance.currentUser;
                  final profile = snap.data?.data();

                  final name = (() {
                    final f = (profile?['firstName'] ?? '').toString().trim();
                    final l = (profile?['lastName'] ?? '').toString().trim();
                    final n = [f, l].where((s) => s.isNotEmpty).join(' ');
                    if (n.isNotEmpty) return n;
                    return u?.displayName ?? 'User';
                  })();

                  final email = u?.email ?? (profile?['email'] ?? '—');

                  final onboardingRaw = profile?['onboarding'];
                  final base64Direct = profile?['profilePhotoBase64'];
                  final img = _profileImageFromUserData(
                    onboardingRaw: onboardingRaw,
                    directBase64: base64Direct,
                  );

                  if (collapsed) {
                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        _CollapsedTip(
                          label: name,
                          child: InkWell(
                            onTap: () => _handleNav(
                                context, AppNav.profile, '/profile'),
                            borderRadius: BorderRadius.circular(999),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white24,
                              backgroundImage: img,
                              child: img == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white, size: 20)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _CollapsedTip(
                          label: t.t('button_sign_out'),
                          child: IconButton(
                            onPressed: () async {
                              await AuthService.signOut();
                              if (!context.mounted) return;
                              Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                      '/login', (r) => false);
                            },
                            icon: const Icon(Icons.logout,
                                color: Colors.white70, size: 20),
                          ),
                        ),
                        ],
                      ),
                    );
                  }

                  return InkWell(
                    onTap: () {
                      _handleNav(context, AppNav.profile, '/profile');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white24,
                                backgroundImage: img,
                                child: img == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ProfileText(
                                  name: name,
                                  email: email.toString(),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () async {
                                await AuthService.signOut();
                                if (!context.mounted) return;
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (r) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white70,
                              ),
                              label: Text(
                                t.t('button_sign_out'),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocStream() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      final ctrl = Stream<DocumentSnapshot<Map<String, dynamic>>>.multi((c) {
        c.close();
      });
      return ctrl;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid)
        .snapshots();
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  /// Optional red count badge on the right (e.g., for the Drivers
  /// Hub item to show how many expiry notifications are open).
  final int? badgeCount;

  /// Optional green "BETA" tag rendered to the right of the label —
  /// used to mark menu entries whose feature is still in beta.
  final bool betaBadge;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badgeCount,
    this.betaBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white.withOpacity(0.10) : Colors.transparent;
    final fg = active ? Colors.white : Colors.white70;

    if (_MenuScope.of(context)) {
      return _CollapsedTip(
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: fg, size: 20),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    top: 5,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 0.5),
                      constraints: const BoxConstraints(minWidth: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB91C1C),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeCount! > 99 ? '99+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (betaBadge)
              Container(
                margin: const EdgeInsets.only(left: 6, right: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B287).withOpacity(0.18),
                  border: Border.all(
                    color: const Color(0xFF00B287).withOpacity(0.55),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'BETA',
                  style: TextStyle(
                    color: Color(0xFF7DDDBE),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
                constraints: const BoxConstraints(minWidth: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeCount! > 99 ? '99+' : '$badgeCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (active && (badgeCount == null || badgeCount == 0))
              const Icon(Icons.chevron_right, size: 18, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _SubMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _SubMenuItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white.withOpacity(0.08) : Colors.transparent;
    final fg = active ? Colors.white : Colors.white60;

    if (_MenuScope.of(context)) {
      return _CollapsedTip(
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            height: 32,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: fg, size: 16),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(top: 0, bottom: 2),
        padding: const EdgeInsets.fromLTRB(26, 6, 12, 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.subdirectory_arrow_right, color: fg, size: 14),
            const SizedBox(width: 6),
            Icon(icon, color: fg, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (active)
              const Icon(Icons.chevron_right, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _ProfileText extends StatelessWidget {
  final String name;
  final String email;
  const _ProfileText({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white.withOpacity(0.12),
    );
  }
}

ImageProvider? _profileImageFromUserData({
  dynamic onboardingRaw,
  dynamic directBase64,
}) {
  String? base64String;

  if (directBase64 != null && directBase64.toString().isNotEmpty) {
    base64String = directBase64.toString();
  } else if (onboardingRaw != null) {
    Map<String, dynamic> onboarding;
    if (onboardingRaw is Map<String, dynamic>) {
      onboarding = onboardingRaw;
    } else if (onboardingRaw is Map) {
      onboarding = onboardingRaw.map((k, v) => MapEntry(k.toString(), v));
    } else {
      onboarding = const {};
    }

    final val = onboarding['profilePhotoBase64'];
    if (val != null && val.toString().isNotEmpty) {
      base64String = val.toString();
    }
  }

  if (base64String == null || base64String.isEmpty) return null;

  try {
    final bytes = base64Decode(base64String);
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

/// Localised group header title (English base, German when the app locale is
/// German). Falls back to English for any other selected language.
String _groupTitle(BuildContext context, String key) {
  final code = Localizations.localeOf(context).languageCode;
  const de = <String, String>{
    'overview': 'Übersicht',
    'performance': 'Performance',
    'planning': 'Planung & Betrieb',
    'team': 'Team',
    'fleet': 'Flotte & Material',
    'finance': 'Finanzen',
    'system': 'System & Hilfe',
  };
  const en = <String, String>{
    'overview': 'Overview',
    'performance': 'Performance',
    'planning': 'Planning & Operations',
    'team': 'Team',
    'fleet': 'Fleet & Supplies',
    'finance': 'Finance',
    'system': 'System & Help',
  };
  final map = code == 'de' ? de : en;
  return map[key] ?? key;
}

/// Wraps [child] so it only renders for the CoDriver owner accounts.
Widget _ownerOnly(Widget child) {
  return Builder(
    builder: (context) {
      final email =
          FirebaseAuth.instance.currentUser?.email?.toLowerCase() ?? '';
      const owners = <String>{
        'admin@arion-logistics.de',
        'test@arion-logistics.de',
      };
      return owners.contains(email) ? child : const SizedBox.shrink();
    },
  );
}

/// Small uppercase group header shown above a set of menu items.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    if (_MenuScope.of(context)) {
      // Collapsed rail: replace the caption with a subtle divider.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.10),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: Colors.white.withValues(alpha: 0.40),
        ),
      ),
    );
  }
}

/// Inherited flag so every menu item knows whether the sidebar is in
/// the collapsed (icons-only) rail mode without threading a parameter
/// through every call site.
class _MenuScope extends InheritedWidget {
  final bool collapsed;
  const _MenuScope({required this.collapsed, required super.child});

  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_MenuScope>()
          ?.collapsed ??
      false;

  @override
  bool updateShouldNotify(_MenuScope old) => old.collapsed != collapsed;
}

/// Hover flyout for the collapsed rail: shows the item title to the
/// right of the icon in the CoDriver accent colour.
class _CollapsedTip extends StatefulWidget {
  final String label;
  final Widget child;
  const _CollapsedTip({required this.label, required this.child});

  @override
  State<_CollapsedTip> createState() => _CollapsedTipState();
}

class _CollapsedTipState extends State<_CollapsedTip> {
  OverlayEntry? _entry;

  void _show() {
    if (_entry != null || widget.label.trim().isEmpty) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final pos = box.localToGlobal(Offset(box.size.width + 10, 0));
    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx,
        top: pos.dy + box.size.height / 2 - 15,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF00B287),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _show(),
      onExit: (_) => _hide(),
      child: widget.child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Shortlinks (Favoriten) — Icon-Reihe über der OVERVIEW-Sektion
// ═══════════════════════════════════════════════════════════════════════

/// Eine anwählbare Lieblingsseite: Ziel, Icon und zweisprachiger Name.
class _ShortcutDef {
  const _ShortcutDef(
    this.nav,
    this.icon,
    this.route,
    this.de,
    this.en, {
    this.sDe,
    this.sEn,
  });

  final AppNav nav;
  final IconData icon;
  final String route;
  final String de;
  final String en;

  /// Kurzform für die Bildunterschrift der Kachel — nur nötig, wenn der
  /// volle Name unter dem Icon nicht in eine Zeile passt. Der volle Name
  /// steht weiterhin im Tooltip.
  final String? sDe;
  final String? sEn;

  String label(bool isDe) => isDe ? de : en;

  String caption(bool isDe) => isDe ? (sDe ?? de) : (sEn ?? en);

  /// Firestore-Schlüssel — der Enum-Name ist stabil.
  String get key => nav.name;
}

/// Auswahl für das Anpassen-Menü. Bewusst nur Seiten, die die Shell
/// wirklich kennt (siehe `_lazy(...)`-Liste in `AdminShellPage`).
const List<_ShortcutDef> _kShortcutCatalog = <_ShortcutDef>[
  _ShortcutDef(AppNav.home, Icons.home_outlined, '/home', 'Home', 'Home'),
  _ShortcutDef(AppNav.dashboard, Icons.dashboard, '/dashboard', 'Scorecard',
      'Scorecard'),
  _ShortcutDef(AppNav.podQuality, Icons.photo_camera_outlined, '/pod-quality',
      'POD Quality', 'POD Quality'),
  _ShortcutDef(AppNav.concessions, Icons.report_gmailerrorred_outlined,
      '/concessions', 'Concessions', 'Concessions'),
  _ShortcutDef(AppNav.cdf, Icons.feedback_outlined, '/cdf', 'Customer Feedback',
      'Customer Feedback',
      sDe: 'Customer', sEn: 'Customer'),
  _ShortcutDef(AppNav.dwc, Icons.verified_user_outlined, '/dwc', 'DWC / IADC',
      'DWC / IADC'),
  _ShortcutDef(AppNav.contactCompliance, Icons.phone_in_talk_outlined,
      '/contact-compliance', 'Contact Compliance', 'Contact Compliance',
      sDe: 'Contact', sEn: 'Contact'),
  _ShortcutDef(AppNav.drivers, Icons.badge_outlined, '/drivers', 'Drivers Hub',
      'Drivers Hub',
      sDe: 'Drivers', sEn: 'Drivers'),
  _ShortcutDef(AppNav.recruiting, Icons.work_outline_rounded, '/recruiting',
      'Recruiting', 'Recruiting'),
  _ShortcutDef(AppNav.fleetStatus, Icons.local_shipping_outlined,
      '/fleet-status', 'Fleet Hub', 'Fleet Hub'),
  _ShortcutDef(AppNav.waveplan, Icons.waves_rounded, '/waveplan', 'Waveplan',
      'Waveplan'),
  _ShortcutDef(AppNav.shiftPlan, Icons.event_note_rounded, '/shift-plan',
      'Shift Plan', 'Shift Plan'),
  _ShortcutDef(AppNav.monthlyPlan, Icons.calendar_view_month_rounded,
      '/monthly-plan', 'Monthly Plan', 'Monthly Plan',
      sDe: 'Monthly', sEn: 'Monthly'),
  _ShortcutDef(AppNav.calendar, Icons.calendar_month_rounded, '/calendar',
      'Kalender', 'Calendar'),
  _ShortcutDef(AppNav.tasks, Icons.task_alt_outlined, '/tasks', 'Task Sheet',
      'Task Sheet',
      sDe: 'Tasks', sEn: 'Tasks'),
  _ShortcutDef(AppNav.dispatcherPill, Icons.support_agent_rounded,
      '/dispatcher-pill', 'Dispatcher Center', 'Dispatcher Center',
      sDe: 'Dispatcher', sEn: 'Dispatcher'),
  _ShortcutDef(AppNav.cotimer, Icons.timer_outlined, '/cotimer', 'co:timer',
      'co:timer'),
  _ShortcutDef(AppNav.shiftAbsence, Icons.schedule_rounded, '/shift-absence',
      'Zeiten & Abwesenheiten', 'Time & absence',
      sDe: 'Zeiten', sEn: 'Absence'),
  _ShortcutDef(AppNav.daRequests, Icons.request_page_outlined, '/da-requests',
      'DA Requests', 'DA Requests',
      sDe: 'Requests', sEn: 'Requests'),
  _ShortcutDef(AppNav.academy, Icons.school_outlined, '/academy', 'DA Academy',
      'DA Academy',
      sDe: 'Academy', sEn: 'Academy'),
  _ShortcutDef(AppNav.safetyTraining, Icons.health_and_safety_outlined,
      '/safety-training', 'Sicherheitsunterweisung', 'Safety training',
      sDe: 'Sicherheit', sEn: 'Safety'),
  _ShortcutDef(AppNav.incidentReports, Icons.warning_amber_rounded,
      '/incident-reports', 'Incident Reports', 'Incident Reports',
      sDe: 'Incidents', sEn: 'Incidents'),
  _ShortcutDef(AppNav.inventory, Icons.inventory_2_outlined, '/inventory',
      'Inventar', 'Inventory'),
  _ShortcutDef(AppNav.paymentCheck, Icons.fact_check_outlined, '/payment-check',
      'Payment Check', 'Payment Check',
      sDe: 'Payment', sEn: 'Payment'),
  _ShortcutDef(AppNav.feedback, Icons.feedback, '/feedback', 'Feedback',
      'Feedback'),
  _ShortcutDef(AppNav.faqs, Icons.help_outline, '/faqs', 'FAQs', 'FAQs'),
];

/// Werkseinstellung, solange nichts angepasst wurde.
const List<AppNav> _kDefaultShortcuts = <AppNav>[
  AppNav.fleetStatus,
  AppNav.drivers,
  AppNav.dashboard,
  AppNav.recruiting,
];

/// Höchstzahl gleichzeitiger Shortlinks — zwei Reihen à vier Icons.
const int _kMaxShortcuts = 8;

_ShortcutDef? _shortcutByKey(String key) {
  for (final def in _kShortcutCatalog) {
    if (def.key == key) return def;
  }
  return null;
}

/// Icon-Reihe der Lieblingsseiten samt Drei-Punkte-Menü zum Anpassen.
///
/// Gespeichert wird pro DSP unter `users/{scope}/settings/menu_shortcuts`
/// (Feld `items`: Liste von [AppNav]-Namen) — dieselbe Ablage wie die
/// übrigen DSP-Einstellungen, daher ohne neue Firestore-Regel.
class _ShortcutsBar extends StatelessWidget {
  const _ShortcutsBar({required this.onOpen});

  final void Function(AppNav nav, String route) onOpen;

  static const Color _accent = Color(0xFF00B287);

  static String? _scopeUidOf(BuildContext context) {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.trim().isNotEmpty) return scoped.trim();
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static DocumentReference<Map<String, dynamic>> _docFor(String scope) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(scope)
          .collection('settings')
          .doc('menu_shortcuts');

  List<_ShortcutDef> _read(Map<String, dynamic>? data) {
    final raw = data?['items'];
    if (raw is List) {
      final picked = <_ShortcutDef>[];
      for (final entry in raw) {
        final def = _shortcutByKey('$entry'.trim());
        if (def != null && !picked.contains(def)) picked.add(def);
        if (picked.length >= _kMaxShortcuts) break;
      }
      // Leere gespeicherte Liste ist eine bewusste Entscheidung („keine
      // Shortlinks") — nur ein fehlendes Feld fällt auf die Vorgabe zurück.
      return picked;
    }
    return <_ShortcutDef>[
      for (final nav in _kDefaultShortcuts)
        ...(_kShortcutCatalog.where((d) => d.nav == nav)),
    ];
  }

  Future<void> _edit(
    BuildContext context,
    String scope,
    List<_ShortcutDef> current,
  ) async {
    // Vor dem await greifen — danach ist der Context ggf. nicht mehr gültig.
    final de = Localizations.localeOf(context).languageCode == 'de';
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await showDialog<List<_ShortcutDef>>(
      context: context,
      builder: (_) => _ShortcutsEditorDialog(initial: current),
    );
    if (result == null) return;
    try {
      await _docFor(scope).set(<String, dynamic>{
        'items': result.map((d) => d.key).toList(growable: false),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Speichern fehlgeschlagen: $e' : 'Could not save: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = _scopeUidOf(context);
    if (scope == null || scope.isEmpty) return const SizedBox.shrink();
    final de = Localizations.localeOf(context).languageCode == 'de';

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _docFor(scope).snapshots(),
      builder: (context, snap) {
        final items = _read(snap.data?.data());
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 2, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        de ? 'SHORTLINKS' : 'SHORTCUTS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Colors.white.withValues(alpha: 0.40),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        splashRadius: 16,
                        tooltip: de
                            ? 'Shortlinks anpassen'
                            : 'Customise shortcuts',
                        onPressed: () => _edit(context, scope, items),
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Text(
                    de
                        ? 'Keine — über ⋯ auswählen'
                        : 'None — pick via ⋯',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      // Immer vier Kacheln je Reihe — so bleibt das Raster
                      // ruhig, egal wie viele Shortlinks gewählt sind.
                      const perRow = 4;
                      const gap = 8.0;
                      final tile =
                          (c.maxWidth - gap * (perRow - 1)) / perRow;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final def in items)
                            _ShortcutTile(
                              def: def,
                              width: tile,
                              label: def.label(de),
                              caption: def.caption(de),
                              accent: _accent,
                              onTap: () => onOpen(def.nav, def.route),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.def,
    required this.width,
    required this.label,
    required this.caption,
    required this.accent,
    required this.onTap,
  });

  final _ShortcutDef def;
  final double width;

  /// Voller Name — nur im Tooltip.
  final String label;

  /// Kurzer Titel unter dem Icon.
  final String caption;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 350),
      child: SizedBox(
        width: width,
        height: 58,
        child: Material(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            hoverColor: accent.withValues(alpha: 0.22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  def.icon,
                  size: 19,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    caption,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.8,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Auswahl-Dialog: welche Seiten liegen als Shortlink oben im Menü?
class _ShortcutsEditorDialog extends StatefulWidget {
  const _ShortcutsEditorDialog({required this.initial});

  final List<_ShortcutDef> initial;

  @override
  State<_ShortcutsEditorDialog> createState() => _ShortcutsEditorDialogState();
}

class _ShortcutsEditorDialogState extends State<_ShortcutsEditorDialog> {
  late final List<_ShortcutDef> _selected =
      List<_ShortcutDef>.from(widget.initial);

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final full = _selected.length >= _kMaxShortcuts;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        de ? 'Shortlinks anpassen' : 'Customise shortcuts',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 420,
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              de
                  ? 'Bis zu $_kMaxShortcuts Seiten — sie erscheinen oben '
                      'im Menü in der Reihenfolge der Auswahl.'
                  : 'Up to $_kMaxShortcuts pages — they appear at the top '
                      'of the menu in the order you pick them.',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _kShortcutCatalog.length,
                itemBuilder: (context, i) {
                  final def = _kShortcutCatalog[i];
                  final index = _selected.indexOf(def);
                  final picked = index >= 0;
                  return CheckboxListTile(
                    value: picked,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    // Volle Auswahl: Nicht-Gewählte lassen sich erst
                    // wieder anhaken, wenn etwas abgewählt wurde.
                    onChanged: (!picked && full)
                        ? null
                        : (v) => setState(() {
                              if (v == true) {
                                _selected.add(def);
                              } else {
                                _selected.remove(def);
                              }
                            }),
                    secondary: Icon(def.icon, size: 20),
                    title: Text(
                      def.label(de),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: picked
                        ? Text(
                            de ? 'Position ${index + 1}' : 'Position ${index + 1}',
                            style: const TextStyle(fontSize: 11.5),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(de ? 'Abbrechen' : 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: Text(de ? 'Speichern' : 'Save'),
        ),
      ],
    );
  }
}
