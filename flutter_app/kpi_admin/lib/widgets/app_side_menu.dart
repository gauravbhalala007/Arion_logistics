import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

enum AppNav { dashboard, drivers, comingSoon, adminApprovals }

class AppSideMenu extends StatelessWidget {
  final double width;
  final AppNav active;

  const AppSideMenu({
    super.key,
    required this.width,
    required this.active,
  });

  void _goIfNeeded(BuildContext context, String routeName) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current != routeName) {
      Navigator.of(context).pushNamedAndRemoveUntil(routeName, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0B1220);

    return Container(
      width: width,
      color: dark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DSP COPILOT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 18),
              const _ThinDivider(),

              _MenuItem(
                icon: Icons.dashboard,
                label: 'Score Card Dashboard',
                active: active == AppNav.dashboard,
                onTap: () => _goIfNeeded(context, '/dashboard'),
              ),
              _MenuItem(
                icon: Icons.badge_outlined,
                label: 'Drivers Hub',
                active: active == AppNav.drivers,
                onTap: () => _goIfNeeded(context, '/drivers'),
              ),
              _MenuItem(
                icon: Icons.timer_outlined,
                label: 'Coming Soon',
                active: active == AppNav.comingSoon,
                onTap: () => _goIfNeeded(context, '/coming-soon'),
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
                    onTap: () => _goIfNeeded(context, '/admin-approvals'),
                  );
                },
              ),

              const Spacer(),
              const _ThinDivider(),
              const SizedBox(height: 12),

              // ---- Profile card (uses live Firebase user + Firestore name) ----
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

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ProfileText(
                                name: name,
                                email: email.toString(),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white70),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () async => AuthService.signOut(),
                            icon: const Icon(Icons.logout, color: Colors.white70),
                            label: const Text(
                              'Sign out',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ],
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
      // emit a single empty doc-like snapshot
      final ctrl = Stream<DocumentSnapshot<Map<String, dynamic>>>.multi((c) {
        c.close();
      });
      return ctrl;
    }
    return FirebaseFirestore.instance.collection('users').doc(u.uid).snapshots();
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
