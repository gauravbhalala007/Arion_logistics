// lib/services/seso_confirmation_repository.dart
//
// Firestore + Storage helpers for SESO confirmations AND the related
// rental-company directory. Writes calendar_events docs for the
// pickup/return dates so they show up on the admin calendar.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/seso_confirmation.dart';

class SesoConfirmationRepository {
  SesoConfirmationRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _col(String dspUid) =>
      _firestore.collection('users').doc(dspUid).collection('seso_confirmations');

  CollectionReference<Map<String, dynamic>> _rentalCol(String dspUid) =>
      _firestore.collection('users').doc(dspUid).collection('rental_companies');

  CollectionReference<Map<String, dynamic>> _calendarCol(String dspUid) =>
      _firestore.collection('users').doc(dspUid).collection('calendar_events');

  Stream<List<SesoConfirmation>> watch(String dspUid) {
    return _col(dspUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SesoConfirmation.fromDoc).toList());
  }

  Stream<List<RentalCompany>> watchRentalCompanies(String dspUid) {
    return _rentalCol(dspUid)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(RentalCompany.fromDoc).toList());
  }

  Future<String> createRentalCompany({
    required String dspUid,
    required String name,
    required String address,
    String? phone,
    String? email,
    String? note,
  }) async {
    final ref = await _rentalCol(dspUid).add({
      'name': name,
      'address': address,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (note != null && note.isNotEmpty) 'note': note,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateRentalCompany({
    required String dspUid,
    required String id,
    required String name,
    required String address,
    String? phone,
    String? email,
    String? note,
  }) async {
    await _rentalCol(dspUid).doc(id).update({
      'name': name,
      'address': address,
      'phone': phone ?? '',
      'email': email ?? '',
      'note': note ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRentalCompany({
    required String dspUid,
    required String id,
  }) async {
    await _rentalCol(dspUid).doc(id).delete();
  }

  Future<RentalCompany?> getRentalCompany({
    required String dspUid,
    required String id,
  }) async {
    final snap = await _rentalCol(dspUid).doc(id).get();
    if (!snap.exists) return null;
    return RentalCompany.fromDoc(snap);
  }

  // ─── SESO confirmation CRUD ──────────────────────────────────────────

  Future<String> create({
    required String dspUid,
    required String transactionId,
    required String orderId,
    required SesoVehicleType vehicleType,
    required double dailyRate,
    double partnerDailyRate = 0,
    required bool offPeak,
    required List<SesoWeekEntry> weeks,
    String? note,
    String? rentalCompanyId,
    DateTime? pickupDate,
    DateTime? returnDate,
    int? vehicleCount,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final ref = await _col(dspUid).add({
      'transactionId': transactionId,
      'orderId': orderId,
      'vehicleType': vehicleType.wire,
      'dailyRate': dailyRate,
      'partnerDailyRate': partnerDailyRate,
      'offPeak': offPeak,
      'weeks': [for (final w in weeks) w.toMap()],
      if (note != null && note.isNotEmpty) 'note': note,
      if (rentalCompanyId != null && rentalCompanyId.isNotEmpty)
        'rentalCompanyId': rentalCompanyId,
      if (pickupDate != null) 'pickupDate': Timestamp.fromDate(pickupDate),
      if (returnDate != null) 'returnDate': Timestamp.fromDate(returnDate),
      if (vehicleCount != null) 'vehicleCount': vehicleCount,
      if (uid != null) 'createdByUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _syncCalendarEventsForConfirmation(
      dspUid: dspUid,
      confirmationId: ref.id,
    );
    return ref.id;
  }

  Future<void> update({
    required String dspUid,
    required String confirmationId,
    String? transactionId,
    String? orderId,
    SesoVehicleType? vehicleType,
    double? dailyRate,
    double? partnerDailyRate,
    bool? offPeak,
    List<SesoWeekEntry>? weeks,
    String? note,
    String? confirmationScreenshotPath,
    bool clearConfirmationScreenshot = false,
    String? invoiceScreenshotPath,
    bool clearInvoiceScreenshot = false,
    String? rentalCompanyId,
    bool clearRentalCompany = false,
    DateTime? pickupDate,
    bool clearPickupDate = false,
    DateTime? returnDate,
    bool clearReturnDate = false,
    int? vehicleCount,
  }) async {
    final patch = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (transactionId != null) patch['transactionId'] = transactionId;
    if (orderId != null) patch['orderId'] = orderId;
    if (vehicleType != null) patch['vehicleType'] = vehicleType.wire;
    if (dailyRate != null) patch['dailyRate'] = dailyRate;
    if (partnerDailyRate != null) {
      patch['partnerDailyRate'] = partnerDailyRate;
    }
    if (offPeak != null) patch['offPeak'] = offPeak;
    if (weeks != null) {
      patch['weeks'] = [for (final w in weeks) w.toMap()];
    }
    if (note != null) {
      patch['note'] = note.isEmpty ? FieldValue.delete() : note;
    }
    if (clearConfirmationScreenshot) {
      patch['confirmationScreenshotPath'] = FieldValue.delete();
    } else if (confirmationScreenshotPath != null) {
      patch['confirmationScreenshotPath'] = confirmationScreenshotPath;
    }
    if (clearInvoiceScreenshot) {
      patch['invoiceScreenshotPath'] = FieldValue.delete();
    } else if (invoiceScreenshotPath != null) {
      patch['invoiceScreenshotPath'] = invoiceScreenshotPath;
    }
    if (clearRentalCompany) {
      patch['rentalCompanyId'] = FieldValue.delete();
    } else if (rentalCompanyId != null) {
      patch['rentalCompanyId'] = rentalCompanyId;
    }
    if (clearPickupDate) {
      patch['pickupDate'] = FieldValue.delete();
    } else if (pickupDate != null) {
      patch['pickupDate'] = Timestamp.fromDate(pickupDate);
    }
    if (clearReturnDate) {
      patch['returnDate'] = FieldValue.delete();
    } else if (returnDate != null) {
      patch['returnDate'] = Timestamp.fromDate(returnDate);
    }
    if (vehicleCount != null) {
      patch['vehicleCount'] = vehicleCount;
    }
    await _col(dspUid).doc(confirmationId).update(patch);

    await _syncCalendarEventsForConfirmation(
      dspUid: dspUid,
      confirmationId: confirmationId,
    );
  }

  Future<void> delete({
    required String dspUid,
    required String confirmationId,
  }) async {
    // Read existing to find linked calendar event ids.
    final docSnap = await _col(dspUid).doc(confirmationId).get();
    final data = docSnap.data() ?? const <String, dynamic>{};
    final pickupEventId =
        (data['calendarPickupEventId'] ?? '').toString();
    final returnEventId =
        (data['calendarReturnEventId'] ?? '').toString();

    // Best-effort cleanup of linked calendar events.
    if (pickupEventId.isNotEmpty) {
      try {
        await _calendarCol(dspUid).doc(pickupEventId).delete();
      } catch (_) {}
    }
    if (returnEventId.isNotEmpty) {
      try {
        await _calendarCol(dspUid).doc(returnEventId).delete();
      } catch (_) {}
    }

    // Best-effort cleanup of Storage files.
    try {
      final folder = _storage.ref('users/$dspUid/seso/$confirmationId');
      final list = await folder.listAll();
      for (final item in list.items) {
        await item.delete();
      }
    } catch (_) {}

    await _col(dspUid).doc(confirmationId).delete();
  }

  /// Read latest doc + ensure calendar events for pickup/return match
  /// the current state (create / update / delete linked events).
  Future<void> _syncCalendarEventsForConfirmation({
    required String dspUid,
    required String confirmationId,
  }) async {
    final snap = await _col(dspUid).doc(confirmationId).get();
    if (!snap.exists) return;
    final c = SesoConfirmation.fromDoc(snap);

    // Resolve company name + address for the event title/location.
    String companyName = '';
    String companyAddress = '';
    if (c.rentalCompanyId != null && c.rentalCompanyId!.isNotEmpty) {
      final rc = await getRentalCompany(
        dspUid: dspUid,
        id: c.rentalCompanyId!,
      );
      if (rc != null) {
        companyName = rc.name;
        companyAddress = rc.address;
      }
    }

    final patch = <String, dynamic>{};

    final count = c.vehicleCount ??
        c.pickupVehicleCount ??
        c.returnVehicleCount;

    // Pickup event.
    await _upsertCalendarEvent(
      dspUid: dspUid,
      existingEventId: c.calendarPickupEventId,
      date: c.pickupDate,
      count: count,
      titlePrefix: 'Abholung',
      companyName: companyName,
      vehicleTypeLabel: c.vehicleType.label,
      address: companyAddress,
      patchKey: 'calendarPickupEventId',
      patch: patch,
    );

    // Return event.
    await _upsertCalendarEvent(
      dspUid: dspUid,
      existingEventId: c.calendarReturnEventId,
      date: c.returnDate,
      count: count,
      titlePrefix: 'Abgabe',
      companyName: companyName,
      vehicleTypeLabel: c.vehicleType.label,
      address: companyAddress,
      patchKey: 'calendarReturnEventId',
      patch: patch,
    );

    if (patch.isNotEmpty) {
      await _col(dspUid).doc(confirmationId).update(patch);
    }
  }

  /// Internal: keeps `calendar_events` in sync with the confirmation's
  /// pickup/return fields. If [date] is null, the event (if any) is
  /// deleted and its id is cleared in [patch].
  Future<void> _upsertCalendarEvent({
    required String dspUid,
    required String? existingEventId,
    required DateTime? date,
    required int? count,
    required String titlePrefix,
    required String companyName,
    required String vehicleTypeLabel,
    required String address,
    required String patchKey,
    required Map<String, dynamic> patch,
  }) async {
    final col = _calendarCol(dspUid);

    if (date == null) {
      // Remove any existing calendar event.
      if (existingEventId != null && existingEventId.isNotEmpty) {
        try {
          await col.doc(existingEventId).delete();
        } catch (_) {}
        patch[patchKey] = FieldValue.delete();
      }
      return;
    }

    final niceCount = (count != null && count > 0) ? '$count× ' : '';
    final niceCompany = companyName.isNotEmpty ? ' · $companyName' : '';
    final title = '$titlePrefix · $niceCount$vehicleTypeLabel$niceCompany';

    // Use the same field shape `admin_calendar_page.dart` reads from.
    final data = {
      'start': Timestamp.fromDate(DateTime(date.year, date.month, date.day, 9)),
      'end': Timestamp.fromDate(DateTime(date.year, date.month, date.day, 18)),
      'title': title,
      'category': 'Mietfahrzeug',
      'location': address,
      'dispatcher': '',
      'sourceTag': 'seso',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (existingEventId != null && existingEventId.isNotEmpty) {
      try {
        await col.doc(existingEventId).update(data);
        return;
      } catch (_) {
        // Doc may have been manually deleted — fall through to create.
      }
    }

    final ref = await col.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    patch[patchKey] = ref.id;
  }

  // ─── Storage uploads ─────────────────────────────────────────────────

  Future<String> uploadConfirmationScreenshot({
    required String dspUid,
    required String confirmationId,
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final ext = _extOf(filename);
    final ref = _storage.ref(
      'users/$dspUid/seso/$confirmationId/confirmation$ext',
    );
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType ?? _mimeOf(ext)),
    );
    return ref.fullPath;
  }

  Future<String> uploadInvoiceScreenshot({
    required String dspUid,
    required String confirmationId,
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final ext = _extOf(filename);
    final ref = _storage.ref(
      'users/$dspUid/seso/$confirmationId/invoice$ext',
    );
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType ?? _mimeOf(ext)),
    );
    return ref.fullPath;
  }

  Future<String> uploadPaymentScreenshot({
    required String dspUid,
    required String confirmationId,
    required SesoWeekEntry week,
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) async {
    final ext = _extOf(filename);
    final ref = _storage.ref(
      'users/$dspUid/seso/$confirmationId/payment_${week.pathKey}$ext',
    );
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType ?? _mimeOf(ext)),
    );
    return ref.fullPath;
  }

  Future<String> downloadUrl(String path) =>
      _storage.ref(path).getDownloadURL();

  static String _extOf(String filename) {
    final i = filename.lastIndexOf('.');
    if (i <= 0 || i == filename.length - 1) return '';
    return filename.substring(i).toLowerCase();
  }

  static String _mimeOf(String ext) {
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
