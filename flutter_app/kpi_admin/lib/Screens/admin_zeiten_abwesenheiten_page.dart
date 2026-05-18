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

import '../widgets/admin_scope.dart';
import '../widgets/pill_tab_bar.dart';
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Builder(
              builder: (ctx) => PillTabBar(
                controller: DefaultTabController.of(ctx),
                tabs: const ['Urlaub', 'Zeitkonto', 'Krankmeldungen'],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1 — Urlaub. Filters AdminShiftAbsencePage to
                // requests of type 'vacation' only.
                const AdminShiftAbsencePage(requestType: 'vacation'),
                // Tab 2 — Zeitkonto.
                ZeitkontoTab(dspUid: adminUid),
                // Tab 3 — Krankmeldungen. Same widget, filtered to
                // 'sick_leave'. Header, icon, and CTA labels swap
                // automatically based on this requestType.
                const AdminShiftAbsencePage(requestType: 'sick_leave'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
