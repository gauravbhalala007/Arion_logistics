// lib/Screens/admin_zeiten_abwesenheiten_page.dart
//
// Successor of `AdminShiftAbsencePage`. Three tabs:
//   1. Urlaub        — vacation requests (existing approval flow)
//   2. Zeitkonto     — Soll/Ist-Stunden + manual paid-overtime entries
//   3. Krankmeldungen — sick-leave requests with a doctor-note upload
//
// Phase A keeps tabs 1 + 3 backed by the existing
// [AdminShiftAbsencePage] until the planned per-type split happens.
// The Zeitkonto tab is brand-new and fully wired up.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/admin_scope.dart';
import 'admin_shift_absence_page.dart';
import 'zeitkonto_tab.dart';

class AdminZeitenAbwesenheitenPage extends StatelessWidget {
  const AdminZeitenAbwesenheitenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminUid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      return const Center(
        child: Text('Bitte einloggen.'),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: const Color(0xFFF3F6F7),
            child: TabBar(
              indicatorColor: AppColors.codriverGreen,
              labelColor: AppColors.codriverGraphite,
              unselectedLabelColor: AppColors.labelSecondaryLight,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Urlaub'),
                Tab(text: 'Zeitkonto'),
                Tab(text: 'Krankmeldungen'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1 — Urlaub. For now the existing combined page;
                // a per-type filter is the next refactor step.
                const AdminShiftAbsencePage(),
                // Tab 2 — Zeitkonto.
                ZeitkontoTab(dspUid: adminUid),
                // Tab 3 — Krankmeldungen. Same page for now, will be
                // split when the existing AdminShiftAbsencePage learns
                // to filter by request type.
                const AdminShiftAbsencePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
