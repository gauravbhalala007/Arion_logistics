// lib/data/privacy_camera/privacy_camera_repository.dart
//
// Persistenz der Empfangsbestätigungen und Widersprüche zum Modul
// „Kameras im Fahrzeug – Datenschutz".
//
// ── WARUM DIESE PFADE ───────────────────────────────────────────────
// Naheliegend wäre `users/{dspUid}/privacy_camera_acks/{autoId}`. Das
// geht NICHT: die deployte `firestore.rules` gibt Fahrern dort kein
// Schreibrecht. Die Blanket-Regel
//     match /users/{userId}/{document=**} {
//       allow read, write: if isSelf(userId) || isDispatcherOf(userId);
//     }
// deckt ausschließlich Admin und Disponent ab — Fahrer sind nicht
// erfasst. Fahrer dürfen nur dort schreiben, wo eine explizite Regel mit
// `isDriverForUser(userId)` existiert; für die Academy ist das
//     users/{userId}/academy_test_results/{testId}/drivers/{driverId}
// mit den Bedingungen
//     driverTransporterId() == driverId
//  && request.resource.data.driverTransporterId == driverId
//  && request.resource.data.testId == testId
// (firestore.rules:959-979).
//
// Deshalb liegen Nachweis und Widerspruch als je EIN Dokument pro Fahrer
// in genau diesem Baum — dasselbe Muster, das `privacy_notice` und die
// Betriebsanweisungen bereits nutzen. Die Rules bleiben unangetastet.
//
//   Nachweise:    users/{dspUid}/academy_test_results/privacy_camera/
//                   drivers/{transporterId}
//   Widersprüche: users/{dspUid}/academy_test_results/
//                   privacy_camera_objection/drivers/{transporterId}
//
// Weil pro Fahrer nur ein Dokument beschreibbar ist (tiefere
// Unterkollektionen deckt keine Fahrer-Regel ab), bleibt die HISTORIE
// als Array `history` im selben Dokument erhalten — Spec §6 Nr. 4
// verlangt ausdrücklich, dass die Historie nicht verloren geht.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'privacy_camera_content.dart';

/// Ergebnis der Empfangsbestätigung. `declined` ist KEIN Fehlerfall,
/// sondern ein gleichwertiger, gültiger Nachweis der Aushändigung.
enum PrivacyAckOutcome { acknowledged, declined }

/// Nachweis der Kenntnisnahme (Spec §5).
@immutable
class PrivacyCameraAck {
  final String driverTransporterId;
  final String driverName;
  final String courseId;
  final String contentVersion;

  /// Welchen Wortlaut der Fahrer gesehen hat. Fassung und Prüfsumme
  /// beziehen sich IMMER auf den deutschen Volltext — er ist der
  /// verbindliche. Sonst würde ein Sprachwechsel des Fahrers als neue
  /// Fassung gelten und fälschlich eine Wiedervorlage auslösen.
  final String documentKey;
  final String documentVersion;
  final String documentContentSha256;

  /// Tatsächlich angezeigte Sprachfassung und deren Prüfsumme.
  final String documentDisplayLocale;
  final String documentDisplaySha256;

  /// Verbindlicher deutscher Wortlaut der Empfangsbestätigung (Spec §7).
  final String statementShown;

  /// Zusätzlich angezeigte Übersetzung. `null`, wenn der Fahrer die App
  /// auf Deutsch nutzt — dann ist [statementShown] bereits die
  /// angezeigte Fassung.
  final String? statementShownLocalized;

  /// Sprache, in der der Fahrer den Kurs gesehen hat.
  final String statementLocale;

  final PrivacyAckOutcome outcome;

  /// Gerätezeit. Die belastbare Zeit ist `receivedAt` (Serverzeit).
  final DateTime occurredAt;
  final DateTime? receivedAt;

  final bool checkboxConfirmed;

  /// Freiwillig. Base64-PNG; nie in Logs, nie in Listenansichten.
  final String? signaturePngBase64;

  // Kenntnisnahme-Beleg. Der Kurs hat kein Quiz mehr; belegt wird die
  // Kenntnisnahme über die durchlaufenen Module, das Scroll-Gate im
  // Volltext und die Lesedauer.
  final bool documentScrolledToEnd;
  final int documentReadSeconds;
  final List<String> completedModuleIds;

  final String appVersion;
  final String platform;
  final String locale;

  const PrivacyCameraAck({
    required this.driverTransporterId,
    required this.driverName,
    required this.courseId,
    required this.contentVersion,
    required this.documentKey,
    required this.documentVersion,
    required this.documentContentSha256,
    required this.documentDisplayLocale,
    required this.documentDisplaySha256,
    required this.statementShown,
    this.statementShownLocalized,
    required this.statementLocale,
    required this.outcome,
    required this.occurredAt,
    this.receivedAt,
    required this.checkboxConfirmed,
    this.signaturePngBase64,
    required this.documentScrolledToEnd,
    required this.documentReadSeconds,
    required this.completedModuleIds,
    required this.appVersion,
    required this.platform,
    required this.locale,
  });

  bool get isAcknowledged => outcome == PrivacyAckOutcome.acknowledged;

  /// Gilt der Nachweis noch für die aktuell ausgelieferte Fassung?
  ///
  /// Wiedervorlage NUR bei geänderter Fassung/Prüfsumme — bewusst KEINE
  /// Jahresfrist (Spec §2).
  bool matchesDocument(PrivacyDocument doc) =>
      documentVersion == doc.ref.version &&
      documentContentSha256 == doc.contentSha256;

  static DateTime? _date(Object? v) => v is Timestamp ? v.toDate() : null;

  factory PrivacyCameraAck.fromMap(Map<String, dynamic> m) {
    final doc = (m['document'] as Map?)?.cast<String, dynamic>() ?? const {};
    return PrivacyCameraAck(
      driverTransporterId: '${m['driverTransporterId'] ?? ''}',
      driverName: '${m['driverName'] ?? ''}',
      courseId: '${m['courseId'] ?? ''}',
      contentVersion: '${m['contentVersion'] ?? ''}',
      documentKey: '${doc['documentKey'] ?? ''}',
      documentVersion: '${doc['version'] ?? ''}',
      documentContentSha256: '${doc['contentSha256'] ?? ''}',
      documentDisplayLocale: '${doc['displayLocale'] ?? ''}',
      documentDisplaySha256: '${doc['displayContentSha256'] ?? ''}',
      statementShown: '${m['statementShown'] ?? ''}',
      statementShownLocalized: m['statementShownLocalized'] as String?,
      statementLocale: '${m['statementLocale'] ?? ''}',
      outcome: '${m['outcome']}' == PrivacyAckOutcome.declined.name
          ? PrivacyAckOutcome.declined
          : PrivacyAckOutcome.acknowledged,
      occurredAt: _date(m['occurredAt']) ?? DateTime(1970),
      receivedAt: _date(m['receivedAt']),
      checkboxConfirmed: m['checkboxConfirmed'] == true,
      signaturePngBase64: m['signaturePngBase64'] as String?,
      documentScrolledToEnd: m['documentScrolledToEnd'] == true,
      documentReadSeconds: (m['documentReadSeconds'] as num?)?.toInt() ?? 0,
      completedModuleIds:
          (m['completedModuleIds'] as List?)?.map((e) => '$e').toList() ??
          const [],
      appVersion: '${m['appVersion'] ?? ''}',
      platform: '${m['platform'] ?? ''}',
      locale: '${m['locale'] ?? ''}',
    );
  }

  /// Feldsatz für Firestore. `testId` und `driverTransporterId` sind
  /// Pflicht — ohne sie weist die Regel den Schreibvorgang ab.
  Map<String, dynamic> toMap() => {
    'testId': kPrivacyCameraTestId,
    'driverTransporterId': driverTransporterId,
    'driverName': driverName,
    'courseId': courseId,
    'contentVersion': contentVersion,
    'document': {
      'documentKey': documentKey,
      'version': documentVersion,
      // Verbindlich: Prüfsumme des DEUTSCHEN Volltextes.
      'contentSha256': documentContentSha256,
      // Zusätzlich: was der Fahrer tatsächlich gelesen hat.
      'displayLocale': documentDisplayLocale,
      'displayContentSha256': documentDisplaySha256,
    },
    // Verbindlicher deutscher Wortlaut …
    'statementShown': statementShown,
    // … und die zusätzlich angezeigte Übersetzung.
    'statementShownLocalized': statementShownLocalized,
    'statementLocale': statementLocale,
    'outcome': outcome.name,
    'occurredAt': Timestamp.fromDate(occurredAt),
    'checkboxConfirmed': checkboxConfirmed,
    'signaturePngBase64': signaturePngBase64,
    'documentScrolledToEnd': documentScrolledToEnd,
    'documentReadSeconds': documentReadSeconds,
    'completedModuleIds': completedModuleIds,
    'appVersion': appVersion,
    'platform': platform,
    'locale': locale,
  };

  /// Kompakter Historieneintrag — die Vorfassung bleibt nachweisbar,
  /// ohne die Unterschrift zu duplizieren.
  Map<String, dynamic> toHistoryEntry() => {
    'outcome': outcome.name,
    'occurredAt': Timestamp.fromDate(occurredAt),
    'documentVersion': documentVersion,
    'documentContentSha256': documentContentSha256,
    'contentVersion': contentVersion,
    'statementLocale': statementLocale,
    'hadSignature': (signaturePngBase64 ?? '').isNotEmpty,
  };
}

/// Stammdaten für Nachweis und Bescheinigung.
@immutable
class PrivacyDriverInfo {
  final String name;
  final String employeeNumber;
  final String companyName;

  const PrivacyDriverInfo({
    required this.name,
    required this.employeeNumber,
    required this.companyName,
  });
}

enum PrivacyObjectionStatus { active, withdrawn }

/// Widerspruch nach Art. 21 DSGVO — hier ohne Begründungspflicht.
@immutable
class PrivacyCameraObjection {
  final String driverTransporterId;
  final String driverName;
  final PrivacyObjectionStatus status;
  final String statement;
  final String? reason;
  final DateTime createdAt;
  final DateTime? withdrawnAt;

  /// Nachweis der tatsächlichen Bearbeitung (Spec §6 Nr. 3).
  final DateTime? processedAt;
  final String appVersion;
  final List<Map<String, dynamic>> history;

  const PrivacyCameraObjection({
    required this.driverTransporterId,
    required this.driverName,
    required this.status,
    required this.statement,
    this.reason,
    required this.createdAt,
    this.withdrawnAt,
    this.processedAt,
    required this.appVersion,
    this.history = const [],
  });

  bool get isActive => status == PrivacyObjectionStatus.active;

  static DateTime? _date(Object? v) => v is Timestamp ? v.toDate() : null;

  factory PrivacyCameraObjection.fromMap(Map<String, dynamic> m) =>
      PrivacyCameraObjection(
        driverTransporterId: '${m['driverTransporterId'] ?? ''}',
        driverName: '${m['driverName'] ?? ''}',
        status: '${m['status']}' == PrivacyObjectionStatus.withdrawn.name
            ? PrivacyObjectionStatus.withdrawn
            : PrivacyObjectionStatus.active,
        statement: '${m['statement'] ?? ''}',
        reason: (m['reason'] as String?)?.trim().isEmpty ?? true
            ? null
            : m['reason'] as String,
        createdAt: _date(m['createdAt']) ?? DateTime(1970),
        withdrawnAt: _date(m['withdrawnAt']),
        processedAt: _date(m['processedAt']),
        appVersion: '${m['appVersion'] ?? ''}',
        history: [
          for (final e in (m['history'] as List? ?? const []))
            (e as Map).cast<String, dynamic>(),
        ],
      );
}

/// Alles, was der Fahrer-Screen zum Rendern braucht.
@immutable
class PrivacyCameraState {
  final PrivacyCourseBundle bundle;
  final PrivacyCameraAck? ack;
  final PrivacyCameraObjection? objection;

  const PrivacyCameraState({
    required this.bundle,
    this.ack,
    this.objection,
  });

  /// Volltext in der Anzeigesprache des Fahrers.
  PrivacyDocument get document => bundle.primaryDocument;

  /// Deutscher Volltext — maßgeblich für Fassung und Prüfsumme.
  PrivacyDocument get bindingDocument => bundle.bindingDocument;

  /// Kenntnisnahme fällig — kein Nachweis oder Nachweis zu einer alten
  /// Fassung. Eine Verweigerung (`declined`) ist ein gültiger Nachweis
  /// und macht NICHT erneut fällig.
  ///
  /// Verglichen wird gegen die DEUTSCHE Fassung: ein Sprachwechsel des
  /// Fahrers darf keine Wiedervorlage auslösen.
  bool get acknowledgementDue {
    if (!bundle.course.requiresAcknowledgement) return false;
    final a = ack;
    if (a == null) return true;
    return !a.matchesDocument(bindingDocument);
  }
}

class PrivacyCameraRepository {
  PrivacyCameraRepository({
    required this.dspUid,
    required this.driverTransporterId,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String dspUid;
  final String driverTransporterId;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _ackRef => _db
      .collection('users')
      .doc(dspUid.trim())
      .collection('academy_test_results')
      .doc(kPrivacyCameraTestId)
      .collection('drivers')
      .doc(driverTransporterId.trim());

  DocumentReference<Map<String, dynamic>> get _objectionRef => _db
      .collection('users')
      .doc(dspUid.trim())
      .collection('academy_test_results')
      .doc(kPrivacyCameraObjectionTestId)
      .collection('drivers')
      .doc(driverTransporterId.trim());

  DocumentReference<Map<String, dynamic>> get _driverRef => _db
      .collection('users')
      .doc(dspUid.trim())
      .collection('drivers')
      .doc(driverTransporterId.trim());

  /// Stammdaten für Nachweis und Bescheinigung. Fehlt der Name, tritt
  /// die Transporter-ID an seine Stelle — leer darf das Feld nicht sein.
  Future<PrivacyDriverInfo> loadDriverInfo() async {
    var name = '';
    var employeeNumber = '';
    var companyName = '';
    try {
      final snap = await _driverRef.get();
      final data = snap.data() ?? const <String, dynamic>{};
      name = '${data['driverName'] ?? data['name'] ?? ''}'.trim();
      employeeNumber = '${data['employeeNumber'] ?? ''}'.trim();
      companyName = '${data['company'] ?? ''}'.trim();
    } catch (_) {
      // Stammdaten sind optional — der Nachweis entsteht trotzdem.
    }
    try {
      final profile = await _db.collection('users').doc(dspUid.trim()).get();
      final data = profile.data() ?? const <String, dynamic>{};
      final fromProfile =
          '${data['companyName'] ?? data['dspName'] ?? data['company'] ?? ''}'
              .trim();
      if (fromProfile.isNotEmpty) companyName = fromProfile;
    } catch (_) {
      // Fallback bleibt der Firmenname aus dem Fahrer-Dokument.
    }
    return PrivacyDriverInfo(
      name: name.isEmpty ? driverTransporterId.trim() : name,
      employeeNumber: employeeNumber,
      companyName: companyName,
    );
  }

  Future<PrivacyCameraState> load(String languageCode) async {
    final bundle = await PrivacyCourseBundle.load(languageCode);
    PrivacyCameraAck? ack;
    PrivacyCameraObjection? objection;
    try {
      final snaps = await Future.wait([_ackRef.get(), _objectionRef.get()]);
      final ackData = snaps[0].data();
      if (ackData != null && ackData['outcome'] != null) {
        ack = PrivacyCameraAck.fromMap(ackData);
      }
      final objData = snaps[1].data();
      if (objData != null && objData['status'] != null) {
        objection = PrivacyCameraObjection.fromMap(objData);
      }
    } catch (_) {
      // Ohne Daten lieber keinen Status behaupten als einen falschen.
    }
    return PrivacyCameraState(
      bundle: bundle,
      ack: ack,
      objection: objection,
    );
  }

  /// Schreibt den Nachweis. Ein bestehender Nachweis wandert vorher in
  /// `history`, damit frühere Fassungen belegbar bleiben.
  Future<void> submitAcknowledgement(
    PrivacyCameraAck ack, {
    PrivacyCameraAck? previous,
  }) async {
    await _ackRef.set({
      ...ack.toMap(),
      'receivedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (previous != null)
        'history': FieldValue.arrayUnion([previous.toHistoryEntry()]),
    }, SetOptions(merge: true));
  }

  Future<void> submitObjection({
    required String driverName,
    required String statement,
    String? reason,
  }) async {
    final now = DateTime.now();
    await _objectionRef.set({
      'testId': kPrivacyCameraObjectionTestId,
      'driverTransporterId': driverTransporterId.trim(),
      'driverName': driverName,
      'status': PrivacyObjectionStatus.active.name,
      'statement': statement,
      'reason': (reason ?? '').trim().isEmpty ? null : reason!.trim(),
      'createdAt': Timestamp.fromDate(now),
      'receivedAt': FieldValue.serverTimestamp(),
      'withdrawnAt': null,
      // Eine neue Erhebung startet die Bearbeitung neu.
      'processedAt': null,
      'processedBy': null,
      'appVersion': kPrivacyCameraAppVersion,
      'history': FieldValue.arrayUnion([
        {'action': 'submitted', 'at': Timestamp.fromDate(now)},
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Legt die Bescheinigung ab: PDF nach Storage `driver_docs/{tid}/…`,
  /// Verweis als Fahrer-Dokument (erscheint im Drivers Hub unter
  /// „Nachweise & Zertifikate") und `certificateUrl` am Nachweis.
  ///
  /// Wird ausschließlich bei `acknowledged` aufgerufen.
  Future<String> storeCertificate({
    required Uint8List pdfBytes,
    required DateTime occurredAt,
    required String documentVersion,
    required String contentSha256,
  }) async {
    final tid = driverTransporterId.trim();
    final filename =
        'Kameras_Datenschutz_Empfangsbestaetigung_'
        '${DateFormat('yyyy-MM-dd').format(occurredAt)}.pdf';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('driver_docs')
        .child(tid)
        .child('${occurredAt.millisecondsSinceEpoch}_$filename');
    await storageRef.putData(
      pdfBytes,
      SettableMetadata(contentType: 'application/pdf'),
    );
    final url = await storageRef.getDownloadURL();

    await _driverRef
        .collection('documents')
        .doc(kPrivacyCameraCertificateDocType)
        .set({
          'fileName': filename,
          'downloadUrl': url,
          'storagePath': storageRef.fullPath,
          'contentType': 'application/pdf',
          'uploadedAt': FieldValue.serverTimestamp(),
          'uploadedAtClient': Timestamp.now(),
          'size': pdfBytes.length,
          'docType': kPrivacyCameraCertificateDocType,
          'uploadedBy': 'driver',
          'completedAt': Timestamp.fromDate(occurredAt),
          'documentVersion': documentVersion,
          'contentSha256': contentSha256,
        }, SetOptions(merge: true));

    // Pflichtfelder erneut mitschreiben — die Fahrer-Regel prüft sie
    // auch beim Update am fertigen Dokument.
    await _ackRef.set({
      'testId': kPrivacyCameraTestId,
      'driverTransporterId': tid,
      'certificateUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return url;
  }

  /// Rücknahme — genauso einfach wie die Abgabe (Spec §6 Nr. 4).
  Future<void> withdrawObjection() async {
    final now = DateTime.now();
    await _objectionRef.set({
      'testId': kPrivacyCameraObjectionTestId,
      'driverTransporterId': driverTransporterId.trim(),
      'status': PrivacyObjectionStatus.withdrawn.name,
      'withdrawnAt': Timestamp.fromDate(now),
      'history': FieldValue.arrayUnion([
        {'action': 'withdrawn', 'at': Timestamp.fromDate(now)},
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

/// Admin-Sicht: liest die Nachweise und Widersprüche aller Fahrer.
/// Der Admin ist `isSelf(userId)` und darf den gesamten Baum lesen und
/// `processedAt` setzen.
class PrivacyCameraAdminRepository {
  PrivacyCameraAdminRepository({required this.dspUid, FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final String dspUid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _drivers(String testId) => _db
      .collection('users')
      .doc(dspUid.trim())
      .collection('academy_test_results')
      .doc(testId)
      .collection('drivers');

  Future<Map<String, PrivacyCameraAck>> loadAcks() async {
    final snap = await _drivers(kPrivacyCameraTestId).get();
    final out = <String, PrivacyCameraAck>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['outcome'] == null) continue;
      out[doc.id.toUpperCase()] = PrivacyCameraAck.fromMap(data);
    }
    return out;
  }

  /// Keyed by the RAW document id (= Transporter-ID, wie geschrieben).
  /// Bewusst nicht normalisiert: mit diesem Schlüssel wird später
  /// `processedAt` in genau dieses Dokument zurückgeschrieben.
  Future<Map<String, PrivacyCameraObjection>> loadObjections() async {
    final snap = await _drivers(kPrivacyCameraObjectionTestId).get();
    final out = <String, PrivacyCameraObjection>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['status'] == null) continue;
      out[doc.id] = PrivacyCameraObjection.fromMap(data);
    }
    return out;
  }

  /// Setzt `processedAt` — der Nachweis, dass der Widerspruch nicht nur
  /// in der Datenbank gelandet, sondern tatsächlich umgesetzt ist.
  Future<void> markObjectionProcessed({
    required String transporterId,
    required String processedBy,
  }) async {
    final now = DateTime.now();
    await _drivers(kPrivacyCameraObjectionTestId).doc(transporterId).set({
      'testId': kPrivacyCameraObjectionTestId,
      'driverTransporterId': transporterId,
      'processedAt': Timestamp.fromDate(now),
      'processedBy': processedBy,
      'history': FieldValue.arrayUnion([
        {
          'action': 'processed',
          'at': Timestamp.fromDate(now),
          'by': processedBy,
        },
      ]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
