// lib/widgets/driver_side_menu.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Driver navigation tabs
enum DriverNav { dashboard, onboarding }

class DriverSideMenu extends StatelessWidget {
  final double width;
  final DriverNav active;
  final ValueChanged<DriverNav>? onNav;

  const DriverSideMenu({
    super.key,
    required this.width,
    required this.active,
    this.onNav,
  });

  void _handleTap(DriverNav nav) {
    if (onNav != null) onNav!(nav);
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
                'DRIVER PORTAL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 18),

              _menuItem(
                icon: Icons.dashboard_outlined,
                label: 'Scorecard',
                active: active == DriverNav.dashboard,
                onTap: () => _handleTap(DriverNav.dashboard),
              ),
              _menuItem(
                icon: Icons.assignment_outlined,
                label: 'Onboarding',
                active: active == DriverNav.onboarding,
                onTap: () => _handleTap(DriverNav.onboarding),
              ),

              const Spacer(),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white.withOpacity(0.12),
              ),
              const SizedBox(height: 8),

              // 🔹 Profile card for driver (avatar + name + email)
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _userDocStream(),
                builder: (context, snap) {
                  final u = FirebaseAuth.instance.currentUser;
                  final profile = snap.data?.data();

                  // Name: try firstName / lastName, else displayName, else "Driver"
                  final name = (() {
                    final f = (profile?['firstName'] ?? '').toString().trim();
                    final l = (profile?['lastName'] ?? '').toString().trim();
                    final n = [f, l].where((s) => s.isNotEmpty).join(' ');
                    if (n.isNotEmpty) return n;
                    return u?.displayName ?? 'Driver';
                  })();

                  final email = u?.email ?? (profile?['email'] ?? '—').toString();

                  // Load avatar from users/{uid}.profilePhotoBase64
                  final img = _profileImageFromUserData(
                    directBase64: profile?['profilePhotoBase64'],
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // 👉 Open shared profile page
                            Navigator.of(context).pushNamed('/profile');
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white24,
                                backgroundImage: img,
                                child: img == null
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ProfileText(
                                  name: name,
                                  email: email,
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white70),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!context.mounted) return;
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            },
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

  Widget _menuItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final bg = active ? Colors.white.withOpacity(0.12) : Colors.transparent;
    final fg = Colors.white;

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

// ---------- Helpers ----------

Stream<DocumentSnapshot<Map<String, dynamic>>> _userDocStream() {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) {
    final ctrl = Stream<DocumentSnapshot<Map<String, dynamic>>>.multi((c) {
      c.close();
    });
    return ctrl;
  }
  return FirebaseFirestore.instance.collection('users').doc(u.uid).snapshots();
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

/// Decode profile photo from base64 stored directly on users/{uid}.profilePhotoBase64
ImageProvider? _profileImageFromUserData({
  dynamic directBase64,
}) {
  String? base64String;

  if (directBase64 != null && directBase64.toString().isNotEmpty) {
    base64String = directBase64.toString();
  }

  if (base64String == null || base64String.isEmpty) return null;

  try {
    final bytes = base64Decode(base64String);
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}
