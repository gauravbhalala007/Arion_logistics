// lib/widgets/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Screens/login_page.dart';
import '../Screens/scorecard_overview.dart';
import '../Screens/driver_dashboard_page.dart';
import '../localization/app_localizations.dart'; // 🔹 for localeController

/// Decides whether we show:
///  - Login page (no user)
///  - DSP/admin dashboard (role != 'driver')
///  - Driver dashboard (role == 'driver' OR user only exists in users/*/drivers)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _CenterProgress();
        }

        final user = authSnap.data;
        if (user == null) {
          return const LoginPage();
        }

        // 🔹 First check the top-level users/{uid} doc (your function writes here)
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, docSnap) {
            if (docSnap.connectionState == ConnectionState.waiting) {
              return const _CenterProgress();
            }

            final doc = docSnap.data;
            final data = doc?.data();

            // ---------- CASE A: we have a users/{uid} doc ----------
            if (doc != null && doc.exists && data != null) {
              // 🔑 Load persisted language for this user and update global locale
              final langCode =
                  (data['languageCode'] ?? data['language'] ?? '').toString().trim();

              if (langCode.isNotEmpty) {
                // ⚠️ IMPORTANT: don't call setLocale directly during build.
                // Schedule it for *after* this frame instead.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (localeController.locale?.languageCode != langCode) {
                    localeController.setLocale(Locale(langCode));
                  }
                });
              }

              final role = (data['role'] ?? '').toString().trim();

              // ✅ DRIVER account stored in users/{uid}
              if (role == 'driver') {
                final dspUid = (data['dspUid'] ?? '').toString();
                final transporterId =
                    (data['transporterId'] ?? '').toString();

                if (dspUid.isNotEmpty && transporterId.isNotEmpty) {
                  return DriverDashboardPage(
                    dspUid: dspUid,
                    driverTransporterId: transporterId,
                  );
                }

                // If role=driver but we don't have mapping fields,
                // fall back to resolving via collectionGroup.
                return _DriverRouteResolver(authUser: user);
              }

              // 🔐 DSP / ADMIN ACCOUNT
              final approved = (data['approved'] == true);
              if (!approved) {
                return _AwaitApproval(email: user.email ?? '');
              }
              return const ScorecardOverviewPage();
            }

            // ---------- CASE B: no users/{uid} doc ----------
            // Then try to resolve as driver via collectionGroup.
            return _DriverRouteResolver(authUser: user);
          },
        );
      },
    );
  }
}

/// Resolves a driver Firestore document from the FirebaseAuth user
/// by looking into all users/*/drivers subcollections.
class _DriverRouteResolver extends StatelessWidget {
  final User authUser;
  const _DriverRouteResolver({required this.authUser});

  @override
  Widget build(BuildContext context) {
    final email = authUser.email;
    if (email == null || email.isEmpty) {
      return const _NoProfileFound();
    }

    final query = FirebaseFirestore.instance
        .collectionGroup('drivers')
        .where('email', isEqualTo: email)
        .limit(1);

    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: query.get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _CenterProgress();
        }
        if (snap.hasError) {
          return _NoProfileFound(
            message: 'Error loading driver profile: ${snap.error}',
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const _NoProfileFound();
        }

        final d = docs.first;
        final data = d.data();
        final transporterId = (data['transporterId'] ?? '').toString();
        final parent = d.reference.parent.parent; // users/{dspUid}
        if (parent == null) {
          return const _NoProfileFound();
        }
        final dspUid = parent.id;

        return DriverDashboardPage(
          dspUid: dspUid,
          driverTransporterId: transporterId,
        );
      },
    );
  }
}

/// Shown when we could not find a driver / DSP profile.
class _NoProfileFound extends StatelessWidget {
  final String? message;
  const _NoProfileFound({this.message});

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
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                message ??
                    'Your login is active, but no driver/DSP profile could be found.\n'
                    'Please contact your DSP or admin.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterProgress extends StatelessWidget {
  const _CenterProgress();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AwaitApproval extends StatelessWidget {
  final String email;
  const _AwaitApproval({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Your DSP account is awaiting approval.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Once an admin approves your account, you can access the dashboard.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(email, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              const Text(
                'You can close this tab; we’ll allow access after approval.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
