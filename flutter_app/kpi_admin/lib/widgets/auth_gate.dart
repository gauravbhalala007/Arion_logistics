import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Screens/scorecard_overview.dart';
import '../Screens/verify_email_page.dart';
import '../Screens/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, authSnap) {
        final user = authSnap.data;
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _CenterProgress();
        }
        if (user == null) {
          return const LoginPage();
        }
        if (!user.emailVerified) {
          return const VerifyEmailPage();
        }

        // Email verified → check approval
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (_, docSnap) {
            if (docSnap.connectionState == ConnectionState.waiting) {
              return const _CenterProgress();
            }
            final approved = (docSnap.data?.data()?['approved'] == true);
            if (!approved) {
              return _AwaitApproval(email: user.email ?? '');
            }
            return const ScorecardOverviewPage();
          },
        );
      },
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Your account is pending approval',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Thanks for signing up. Once an admin approves your account, you can access the dashboard.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(email, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              const Text('You can close this tab; we’ll allow access after approval.'),
            ],
          ),
        ),
      ),
    );
  }
}
