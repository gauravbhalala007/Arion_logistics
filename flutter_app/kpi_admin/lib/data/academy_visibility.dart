// lib/data/academy_visibility.dart
//
// Sichtbarkeit der DA-Academy-Schulungen je DSP.
//
// Der Admin kann jede Schulung für seine Fahrer ein- und ausblenden.
// Ausgeblendete Schulungen verschwinden nicht, sondern erscheinen in der
// Fahrer-Academy als gesperrte „Kommt bald"-Kachel — konsistent zu den
// bereits vorhandenen, noch nicht freigeschalteten Trainings.
//
// ── ABLAGEORT UND WARUM ─────────────────────────────────────────────
//   users/{dspUid}/settings/academy_visibility
//     { trainings: { <testId>: bool } }
//
// Diese Stelle funktioniert mit den DEPLOYTEN Rules, ohne sie zu ändern:
//   match /users/{userId}/settings/{settingId} {
//     allow read, create, update, delete: if isSelf(userId) && isApproved(userId);   // Admin
//     allow read: if isDriverForUser(userId) && isApproved(userId);                  // Fahrer
//   }
// (firestore.rules:814-826 — Fahrer-Leserecht in Zeile 819.)
//
// Dass Fahrer `settings` wirklich lesen dürfen, ist im Bestand belegt:
// `driver_home_page` streamt `settings/dispatcher_pill` als Fahrer.
// Die von der Aufgabe erwogene Alternative `academy_tests/{testId}.enabled`
// wäre ebenfalls lesbar, ist aber die Registry der ADMIN-GEPFLEGTEN
// Kategorien (Firestore-Dokumente mit `order`/`enabled`) — die fest
// eingebauten Schulungen aus `kAcademyTrainings` haben dort gar keine
// Dokumente. Ein eigenes Settings-Dokument hält die beiden Konzepte
// sauber getrennt und kommt mit einem einzigen Read aus.
//
// DEFAULT: Ein fehlender Eintrag bedeutet SICHTBAR. Ohne Zutun des
// Admins ändert sich damit am heutigen Verhalten nichts.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

const String kAcademyVisibilitySettingId = 'academy_visibility';
const String kAcademyVisibilityField = 'trainings';

@immutable
class AcademyVisibility {
  /// testId -> sichtbar. Fehlender Schlüssel = sichtbar.
  final Map<String, bool> _flags;

  const AcademyVisibility(this._flags);

  /// Zustand, solange nichts geladen ist: alles sichtbar.
  static const AcademyVisibility allVisible = AcademyVisibility(
    <String, bool>{},
  );

  bool isVisible(String testId) => _flags[testId] ?? true;

  /// Nur die ausgeblendeten IDs — für Anzeige und Zähler.
  Set<String> get hiddenIds => {
    for (final e in _flags.entries)
      if (e.value == false) e.key,
  };

  bool get hasHidden => hiddenIds.isNotEmpty;

  /// Kopie mit geändertem Flag (für optimistische UI-Updates).
  AcademyVisibility withFlag(String testId, bool visible) =>
      AcademyVisibility({..._flags, testId: visible});

  factory AcademyVisibility.fromData(Map<String, dynamic>? data) {
    final raw = data?[kAcademyVisibilityField];
    if (raw is! Map) return allVisible;
    final flags = <String, bool>{};
    raw.forEach((key, value) {
      if (value is bool) flags['$key'] = value;
    });
    return AcademyVisibility(flags);
  }

  static DocumentReference<Map<String, dynamic>> ref(
    String dspUid, {
    FirebaseFirestore? firestore,
  }) => (firestore ?? FirebaseFirestore.instance)
      .collection('users')
      .doc(dspUid.trim())
      .collection('settings')
      .doc(kAcademyVisibilitySettingId);

  /// Einmaliges Laden. Bei fehlendem Dokument oder Fehler gilt „alles
  /// sichtbar" — eine Schulung darf nie wegen eines Ladefehlers
  /// verschwinden.
  static Future<AcademyVisibility> load(
    String dspUid, {
    FirebaseFirestore? firestore,
  }) async {
    if (dspUid.trim().isEmpty) return allVisible;
    try {
      final snap = await ref(dspUid, firestore: firestore).get();
      return AcademyVisibility.fromData(snap.data());
    } catch (_) {
      return allVisible;
    }
  }

  static Stream<AcademyVisibility> watch(
    String dspUid, {
    FirebaseFirestore? firestore,
  }) => ref(dspUid, firestore: firestore)
      .snapshots()
      .map((s) => AcademyVisibility.fromData(s.data()));

  /// Setzt genau ein Flag. `merge` lässt die übrigen Einträge stehen.
  static Future<void> setVisible(
    String dspUid,
    String testId,
    bool visible, {
    FirebaseFirestore? firestore,
  }) => ref(dspUid, firestore: firestore).set({
    kAcademyVisibilityField: {testId: visible},
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
