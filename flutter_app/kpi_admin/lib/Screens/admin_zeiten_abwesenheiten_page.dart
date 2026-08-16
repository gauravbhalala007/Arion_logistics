// lib/Screens/admin_zeiten_abwesenheiten_page.dart
//
// Successor of `AdminShiftAbsencePage`. Three tabs:
//   1. Urlaub         — vacation requests (existing approval flow)
//   2. Krankmeldungen — sick-leave requests with a doctor-note upload
//   3. DA Balance     — per-driver sheet: sick days taken, PTO balance
//                       and overtime balance, plus the full absence +
//                       overtime history behind a tap
//
// Ticket RsRiTdR: the former separate „Zeitkonto" and „Fahrer" tabs are
// merged into the single „DA Balance" tab (same label in DE and EN).
// [ZeitkontoTab] is no longer mounted here — the file stays in the repo
// (payroll Excel import / manual month editing) but has no other caller
// at the moment.
//
// Phase A keeps tabs 1 + 2 backed by the existing
// [AdminShiftAbsencePage] until the planned per-type split happens.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/admin_scope.dart';
import '../widgets/pill_tab_bar.dart';
import 'admin_shift_absence_page.dart';

class AdminZeitenAbwesenheitenPage extends StatelessWidget {
  const AdminZeitenAbwesenheitenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final adminUid = AdminScope.adminUidOf(context) ??
        FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      return Center(
        child: Text(de ? 'Bitte einloggen.' : 'Please sign in.'),
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
                // „DA Balance" bleibt bewusst in beiden Sprachen gleich —
                // so nennt der Kunde die Ansicht.
                tabs: de
                    ? const [
                        'Urlaub',
                        'Krankmeldungen',
                        'DA Balance',
                      ]
                    : const [
                        'Vacation',
                        'Sick leave',
                        'DA Balance',
                      ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1 — Urlaub. Filters AdminShiftAbsencePage to
                // requests of type 'vacation' only.
                const AdminShiftAbsencePage(requestType: 'vacation'),
                // Tab 2 — Krankmeldungen. Same widget, filtered to
                // 'sick_leave'. Header, icon, and CTA labels swap
                // automatically based on this requestType.
                const AdminShiftAbsencePage(requestType: 'sick_leave'),
                // Tab 3 — DA Balance. Liste aller aktiven Fahrer mit
                // Krankheitstagen, PTO- und Overtime-Balance; Klick auf
                // einen Fahrer öffnet die komplette Historie (Urlaub,
                // Krankmeldungen, Überstunden).
                const AbsenceDriversOverviewPage(tabIndex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
