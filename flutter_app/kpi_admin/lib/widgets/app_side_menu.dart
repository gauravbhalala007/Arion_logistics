// lib/widgets/app_side_menu.dart
import 'dart:convert'; // for base64Decode
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

enum AppNav {
  home,
  dashboard,
  podQuality,
  drivers,
  tasks,
  shiftAbsence,
  incidentReports,
  academy,
  dispatcherPill,
  notifications,
  faqs,
  comingSoon,
  adminApprovals,
  profile,
}

class AppSideMenu extends StatelessWidget {
  final double width;
  final AppNav active;

  /// NEW: If provided, menu will switch tabs INSIDE AdminShellPage (IndexedStack).
  final ValueChanged<AppNav>? onSelect;

  /// NEW: Optional helper for narrow screens to close the Drawer after tap.
  final VoidCallback? closeDrawerIfOpen;

  const AppSideMenu({
    super.key,
    required this.width,
    required this.active,
    this.onSelect,
    this.closeDrawerIfOpen,
  });

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

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0B1220);

    final navItems = <Widget>[
      _MenuItem(
        icon: Icons.home_outlined,
        label: 'Home',
        active: active == AppNav.home,
        onTap: () => _handleNav(context, AppNav.home, '/home'),
      ),
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
      _MenuItem(
        icon: Icons.badge_outlined,
        label: 'Drivers Hub',
        active: active == AppNav.drivers,
        onTap: () => _handleNav(context, AppNav.drivers, '/drivers'),
      ),
      _MenuItem(
        icon: Icons.task_alt_outlined,
        label: 'Task Sheet',
        active: active == AppNav.tasks,
        onTap: () => _handleNav(context, AppNav.tasks, '/tasks'),
      ),
      _MenuItem(
        icon: Icons.schedule_rounded,
        label: 'Shift & Absence',
        active: active == AppNav.shiftAbsence,
        onTap: () => _handleNav(context, AppNav.shiftAbsence, '/shift-absence'),
      ),
      _MenuItem(
        icon: Icons.warning_amber_rounded,
        label: 'Incident Reports',
        active: active == AppNav.incidentReports,
        onTap: () =>
            _handleNav(context, AppNav.incidentReports, '/incident-reports'),
      ),
      _MenuItem(
        icon: Icons.school_outlined,
        label: 'DA Academy',
        active: active == AppNav.academy,
        onTap: () => _handleNav(context, AppNav.academy, '/academy'),
      ),
      _MenuItem(
        icon: Icons.support_agent_rounded,
        label: 'Dispatcher',
        active: active == AppNav.dispatcherPill,
        onTap: () =>
            _handleNav(context, AppNav.dispatcherPill, '/dispatcher-pill'),
      ),
      _MenuItem(
        icon: Icons.notifications_none,
        label: 'Notifications',
        active: active == AppNav.notifications,
        onTap: () =>
            _handleNav(context, AppNav.notifications, '/notifications'),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'FAQs',
        active: active == AppNav.faqs,
        onTap: () => _handleNav(context, AppNav.faqs, '/faqs'),
      ),

      // ---- Admin-only item (auto-detect from Firestore user role) ----
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userDocStream(),
        builder: (context, snap) {
          final role = (snap.data?.data()?['role'] ?? '').toString();
          final isAdmin = role == 'admin';
          if (!isAdmin) return const SizedBox.shrink();

          return _MenuItem(
            icon: Icons.verified_user_outlined,
            label: 'User Approvals',
            active: active == AppNav.adminApprovals,
            onTap: () =>
                _handleNav(context, AppNav.adminApprovals, '/admin-approvals'),
          );
        },
      ),
    ];

    return Container(
      width: width,
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
                                  (route) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white70,
                              ),
                              label: const Text(
                                'Sign out',
                                style: TextStyle(color: Colors.white70),
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

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white.withOpacity(0.10) : Colors.transparent;
    final fg = active ? Colors.white : Colors.white70;

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
            if (active)
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
