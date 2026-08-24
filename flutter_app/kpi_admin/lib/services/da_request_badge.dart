// lib/services/da_request_badge.dart
//
// Gemeinsame Zaehl-Quelle fuer offene DA Requests (Fahrer-Antraege inkl.
// Gehaltsvorschuss). Wird vom Seitenmenue-Badge, der Desktop-Topbar-Glocke
// und der mobilen Header-Glocke genutzt — eine Logik statt drei Kopien.
//
// Datenquelle: users/{adminUid}/da_requests/{id}
//
// Status-Schema (siehe admin_da_requests_page.dart / driver_da_requests_view.dart):
//   'open'      — neu, noch nicht bearbeitet (Default, wenn das Feld fehlt)
//   'paid'      — Vorschuss ueberwiesen
//   'done'      — sonstiges Anliegen erledigt
//   'rejected'  — abgelehnt
// Als OFFEN zaehlt exakt das, was der Filter "Offen" der Admin-Seite zeigt:
// `(data['status'] ?? 'open') == 'open'`. Deshalb wird die Collection
// komplett gelesen und lokal gefiltert — eine `where('status', ...)`-Query
// wuerde Dokumente ohne Status-Feld verschlucken und das Badge koennte von
// der Liste abweichen.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../widgets/admin_scope.dart';

class DaRequestBadge {
  const DaRequestBadge._();

  /// Live-Anzahl der offenen Antraege im Namespace von [adminUid].
  ///
  /// Liefert konstant 0, wenn niemand eingeloggt ist oder wenn der
  /// Namespace einem *anderen* Konto gehoert: die Firestore-Regel fuer
  /// `users/{userId}/da_requests` erlaubt Lesen nur dem Konto selbst
  /// (`isSelf`) bzw. dem antragstellenden Fahrer. Ein Dispatcher, der im
  /// AdminScope seines Admins arbeitet, wuerde sonst bei jedem Rebuild in
  /// ein permission-denied laufen.
  static Stream<int> watch(String? adminUid) {
    final self = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null || adminUid.isEmpty || self == null) {
      return Stream.value(0);
    }
    if (adminUid != self) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(adminUid)
        .collection('da_requests')
        .snapshots()
        .map(
          (snap) => snap.docs
              .where((d) => (d.data()['status'] ?? 'open').toString() == 'open')
              .length,
        )
        .handleError((_) {});
  }

  /// Wie [watch], loest den Admin-Namespace aber ueber den [AdminScope]
  /// des Widget-Baums auf (Fallback: eingeloggter Nutzer).
  static Stream<int> watchForContext(BuildContext context) =>
      watch(AdminScope.adminUidOf(context));
}
