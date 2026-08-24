// lib/services/admin_notifications_service.dart
//
// Kleines Benachrichtigungs-Zentrum fuer die Admin-Oberflaeche.
//
// Statt fuer jede Meldungsart eine eigene Glocke zu bauen, sammelt dieser
// Service eine Liste von QUELLEN ein. Jede Quelle liefert einen
// Live-Zaehler; die Glocke im Header zeigt die SUMME aller Quellen, das
// Panel hinter der Glocke listet die Quellen einzeln auf.
//
// ─────────────────────────────────────────────────────────────────────
// NEUE QUELLE ANDOCKEN (~10 Zeilen)
// ─────────────────────────────────────────────────────────────────────
// In [AdminNotificationsService.sourcesFor] einen weiteren Eintrag
// ergaenzen — mehr ist nicht noetig, Glocke, Summe, Panel und
// Navigation ziehen automatisch nach:
//
//   AdminNotificationSource(
//     id: 'incident_reports',
//     icon: Icons.warning_amber_rounded,
//     labelDe: 'Neue Incident Reports',
//     labelEn: 'New incident reports',
//     target: AppNav.incidentReports,
//     count: meinRepository.watchOpenCount(adminUid),
//   ),
//
// Regeln fuer den `count`-Stream:
//   • Er muss bei leerer/fehlender Berechtigung 0 liefern statt zu
//     werfen (siehe `_guardedSelfStream` unten als Vorlage) — sonst
//     laeuft die Glocke bei Dispatchern in permission-denied.
//   • Er sollte dieselbe Definition von "offen" benutzen wie die
//     Zielseite, damit Badge und Liste nie auseinanderlaufen.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/admin_scope.dart';
import '../widgets/app_side_menu.dart' show AppNav;
import 'admin_expiry_aggregator.dart';

/// Eine Meldungs-Quelle der Header-Glocke.
class AdminNotificationSource {
  /// Stabile technische Kennung (nur intern, z. B. fuer Keys).
  final String id;

  final IconData icon;
  final String labelDe;
  final String labelEn;

  /// Seite, auf die ein Klick in der Panel-Zeile navigiert.
  final AppNav target;

  /// Live-Zaehler. 0 blendet die Zeile im Panel aus.
  final Stream<int> count;

  const AdminNotificationSource({
    required this.id,
    required this.icon,
    required this.labelDe,
    required this.labelEn,
    required this.target,
    required this.count,
  });

  String label(bool de) => de ? labelDe : labelEn;
}

class AdminNotificationsService {
  const AdminNotificationsService._();

  /// Alle aktiven Quellen fuer den aktuellen Kontext, in Anzeige-
  /// Reihenfolge des Panels.
  static List<AdminNotificationSource> sourcesFor(BuildContext context) {
    final adminUid = AdminScope.adminUidOf(context);
    final selfUid = FirebaseAuth.instance.currentUser?.uid;

    return [
      AdminNotificationSource(
        id: 'da_requests',
        icon: Icons.request_page_outlined,
        labelDe: 'Offene DA Requests',
        labelEn: 'Open DA requests',
        target: AppNav.daRequests,
        count: watchOpenDaRequests(adminUid),
      ),
      AdminNotificationSource(
        id: 'doc_expiry',
        icon: Icons.event_busy_outlined,
        labelDe: 'Ablaufende Dokumente',
        labelEn: 'Expiring documents',
        target: AppNav.drivers,
        count: _watchExpiringDocuments(selfUid),
      ),
      AdminNotificationSource(
        id: 'feedback_done',
        icon: Icons.feedback_outlined,
        labelDe: 'Erledigtes Feedback',
        labelEn: 'Resolved feedback',
        target: AppNav.feedback,
        count: watchResolvedFeedback(),
      ),
    ];
  }

  /// Summe ueber alle Quellen — der Zaehler auf der Glocke.
  static Stream<int> watchTotal(BuildContext context) => watchCounts(
        context,
      ).map((counts) => counts.fold<int>(0, (a, b) => a + b));

  /// Live-Zaehler aller Quellen, index-gleich zu [sourcesFor].
  static Stream<List<int>> watchCounts(BuildContext context) =>
      combineCounts([for (final s in sourcesFor(context)) s.count]);

  // ── Quellen ────────────────────────────────────────────────────────

  /// Offene DA Requests in `users/{adminUid}/da_requests`.
  ///
  /// Status-Schema (siehe admin_da_requests_page.dart):
  ///   'open' (Default, wenn das Feld fehlt) | 'paid' | 'done' | 'rejected'
  /// Als offen zaehlt exakt das, was der Filter "Offen" der Admin-Seite
  /// zeigt: `(status ?? 'open') == 'open'`. Deshalb wird die Collection
  /// komplett gelesen und lokal gefiltert — eine `where('status', ...)`-
  /// Query wuerde Dokumente ohne Status-Feld verschlucken.
  static Stream<int> watchOpenDaRequests(String? adminUid) {
    return _guardedSelfStream(adminUid, (uid) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('da_requests')
          .snapshots()
          .map(
            (snap) => snap.docs
                .where(
                  (d) => (d.data()['status'] ?? 'open').toString() == 'open',
                )
                .length,
          );
    });
  }

  /// Ungelesene Ablauf-Benachrichtigungen ueber alle Fahrer hinweg —
  /// dieselbe Zahl, die schon am Menuepunkt "Drivers Hub" haengt.
  /// [AdminExpiryAggregator] liefert bereits einen echten Stream, es
  /// braucht also keinen Einmal-Load mit Refresh.
  static Stream<int> _watchExpiringDocuments(String? selfUid) {
    if (selfUid == null || selfUid.isEmpty) return Stream.value(0);
    return AdminExpiryAggregator()
        .watchUnreadTotal(selfUid)
        .handleError((_) {});
  }

  /// Eigene Feedback-Tickets, die seit dem letzten Oeffnen der
  /// Feedback-Seite auf `done` gesprungen sind.
  ///
  /// Auf `createdByUid == self` eingeschraenkt, damit die Firestore-Regel
  /// (`signedIn() && resource.data.createdByUid == request.auth.uid`) den
  /// Read fuer jedes freigegebene Konto erlaubt, nicht nur fuer Staff.
  static Stream<int> watchResolvedFeedback() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncExpand((userSnap) async* {
          final lastSeen =
              (userSnap.data()?['feedbackLastSeenAt'] as Timestamp?)
                  ?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          yield* FirebaseFirestore.instance
              .collection('feedback')
              .where('createdByUid', isEqualTo: uid)
              .where('status', isEqualTo: 'done')
              .snapshots()
              .map(
                (snap) => snap.docs.where((d) {
                  final ts = d.data()['doneAt'];
                  if (ts is! Timestamp) return false;
                  return ts.toDate().isAfter(lastSeen);
                }).length,
              );
        })
        .handleError((_) {});
  }

  // ── Helfer ─────────────────────────────────────────────────────────

  /// Baut [build] nur, wenn [adminUid] dem eingeloggten Konto selbst
  /// gehoert — sonst konstant 0.
  ///
  /// Hintergrund: Die Regeln fuer die Admin-Subcollections erlauben Lesen
  /// nur `isSelf(userId)`. Ein Dispatcher arbeitet zwar im AdminScope
  /// seines Admins, darf dessen Antraege aber nicht lesen; ohne diese
  /// Schranke liefe die Glocke dort in permission-denied.
  static Stream<int> _guardedSelfStream(
    String? adminUid,
    Stream<int> Function(String uid) build,
  ) {
    final self = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null || adminUid.isEmpty || self == null) {
      return Stream.value(0);
    }
    if (adminUid != self) return Stream.value(0);
    return build(adminUid).handleError((_) {});
  }

  /// Fasst mehrere Zaehler-Streams zu einem Stream der jeweils zuletzt
  /// gesehenen Werte zusammen (index-gleich zur Eingabe). Emittiert
  /// sofort eine Null-Liste, damit die Glocke nie leer bleibt, und
  /// danach bei jeder Aenderung einer Quelle.
  static Stream<List<int>> combineCounts(List<Stream<int>> streams) {
    if (streams.isEmpty) return Stream.value(const <int>[]);

    final latest = List<int>.filled(streams.length, 0);
    final subs = <StreamSubscription<int>>[];
    late final StreamController<List<int>> controller;

    controller = StreamController<List<int>>(
      onListen: () {
        controller.add(List<int>.unmodifiable(latest));
        for (var i = 0; i < streams.length; i++) {
          final index = i;
          subs.add(
            streams[i].listen(
              (value) {
                if (latest[index] == value) return;
                latest[index] = value;
                if (!controller.isClosed) {
                  controller.add(List<int>.unmodifiable(latest));
                }
              },
              onError: (_) {},
            ),
          );
        }
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
        subs.clear();
      },
    );

    return controller.stream;
  }
}
