// lib/Screens/admin_recruiting_page.dart
//
// Top-level "Recruiting" admin page. Was previously a tab inside the
// Drivers Hub — moved out into its own route + side-menu entry so it's
// easier to find and gives the Local/EU and Visa channels room to
// evolve independently.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/admin_scope.dart';
import 'admin_recruiting_panel.dart';

class AdminRecruitingPage extends StatelessWidget {
  const AdminRecruitingPage({super.key});

  String? _resolveAdminUid(BuildContext context) {
    final scoped = AdminScope.maybeOf(context)?.adminUid;
    if (scoped != null && scoped.isNotEmpty) return scoped;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final adminUid = _resolveAdminUid(context);
    if (adminUid == null) {
      return const Scaffold(
        body: Center(child: Text('—')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AdminRecruitingPanel(adminUid: adminUid),
          ),
        ),
      ),
    );
  }
}
