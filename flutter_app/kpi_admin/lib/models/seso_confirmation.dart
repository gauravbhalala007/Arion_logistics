// lib/models/seso_confirmation.dart
//
// One SESO (Self-Sourced) vehicle confirmation. Each record bundles:
// vehicle type (SWB/LWB), daily rate, and an ordered list of weeks
// that have been confirmed by Amazon. Per week the admin tracks
// paid/unpaid and an optional payment screenshot.

import 'package:cloud_firestore/cloud_firestore.dart';

enum SesoVehicleType { swb, lwb }

extension SesoVehicleTypeX on SesoVehicleType {
  String get wire => name; // 'swb' | 'lwb'
  String get label => this == SesoVehicleType.swb ? 'SWB' : 'LWB';
  static SesoVehicleType fromWire(String? raw) {
    return (raw?.toLowerCase() == 'lwb')
        ? SesoVehicleType.lwb
        : SesoVehicleType.swb;
  }
}

class SesoWeekEntry {
  final int year;
  final int weekNumber; // 1..53
  final bool paid;
  final DateTime? paidAt;
  final String? paymentScreenshotPath;

  const SesoWeekEntry({
    required this.year,
    required this.weekNumber,
    this.paid = false,
    this.paidAt,
    this.paymentScreenshotPath,
  });

  Map<String, dynamic> toMap() => {
        'year': year,
        'weekNumber': weekNumber,
        'paid': paid,
        if (paidAt != null) 'paidAt': Timestamp.fromDate(paidAt!),
        if (paymentScreenshotPath != null && paymentScreenshotPath!.isNotEmpty)
          'paymentScreenshotPath': paymentScreenshotPath,
      };

  factory SesoWeekEntry.fromMap(Map<String, dynamic> map) {
    final ts = map['paidAt'];
    return SesoWeekEntry(
      year: (map['year'] as num?)?.toInt() ?? 0,
      weekNumber: (map['weekNumber'] as num?)?.toInt() ?? 0,
      paid: map['paid'] == true,
      paidAt: ts is Timestamp ? ts.toDate() : null,
      paymentScreenshotPath:
          (map['paymentScreenshotPath'] ?? '').toString().isEmpty
              ? null
              : map['paymentScreenshotPath'] as String,
    );
  }

  SesoWeekEntry copyWith({
    bool? paid,
    DateTime? paidAt,
    bool clearPaidAt = false,
    String? paymentScreenshotPath,
    bool clearPaymentScreenshot = false,
  }) =>
      SesoWeekEntry(
        year: year,
        weekNumber: weekNumber,
        paid: paid ?? this.paid,
        paidAt: clearPaidAt ? null : (paidAt ?? this.paidAt),
        paymentScreenshotPath: clearPaymentScreenshot
            ? null
            : (paymentScreenshotPath ?? this.paymentScreenshotPath),
      );

  /// Stable key for path generation: `2026_W35`.
  String get pathKey =>
      '${year}_W${weekNumber.toString().padLeft(2, '0')}';
}

class SesoConfirmation {
  final String id;
  final String transactionId; // SESO transaction-ID from the Amazon email
  final String orderId; // SESO order-ID (Auftrags-ID)
  final SesoVehicleType vehicleType;
  /// What Amazon pays the DSP per day (netto). Income side.
  final double dailyRate;
  /// What the DSP pays the rental partner per day. Cost side. The
  /// difference (`dailyRate - partnerDailyRate`) is the margin the
  /// DSP keeps before VAT.
  final double partnerDailyRate;
  final bool offPeak;
  final List<SesoWeekEntry> weeks;
  /// Confirmation email / screenshot of the SESO confirmation.
  final String? confirmationScreenshotPath;
  /// Paid invoice — uploaded for cross-checking that payment landed.
  final String? invoiceScreenshotPath;
  // Rental-company integration (Mietfirma).
  final String? rentalCompanyId;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  /// Total number of vehicles for the whole confirmation period.
  /// Replaces the older pickup/return-specific counts which kept the
  /// same number twice.
  final int? vehicleCount;
  // Legacy split fields — kept on read so older docs render until they
  // get re-saved. New writes only use [vehicleCount].
  final int? pickupVehicleCount;
  final int? returnVehicleCount;
  // Calendar event IDs (Firestore doc ids inside users/{uid}/calendar_events)
  // so we can update / delete the linked events when the SESO record
  // changes.
  final String? calendarPickupEventId;
  final String? calendarReturnEventId;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdByUid;

  const SesoConfirmation({
    required this.id,
    required this.transactionId,
    required this.orderId,
    required this.vehicleType,
    required this.dailyRate,
    required this.offPeak,
    required this.weeks,
    this.partnerDailyRate = 0,
    this.confirmationScreenshotPath,
    this.invoiceScreenshotPath,
    this.rentalCompanyId,
    this.pickupDate,
    this.returnDate,
    this.vehicleCount,
    this.pickupVehicleCount,
    this.returnVehicleCount,
    this.calendarPickupEventId,
    this.calendarReturnEventId,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.createdByUid,
  });

  // Derived totals — never persisted.
  double get weeklyCost => dailyRate * 7;
  double get totalCost => weeklyCost * weeks.length;
  int get paidWeekCount => weeks.where((w) => w.paid).length;
  double get paidCost => weeklyCost * paidWeekCount;
  double get openCost => totalCost - paidCost;

  // Margin breakdown (income − partner cost).
  double get dailyMargin => dailyRate - partnerDailyRate;
  double get weeklyPartnerCost => partnerDailyRate * 7;
  double get totalPartnerCost => weeklyPartnerCost * weeks.length;
  double get weeklyMargin => dailyMargin * 7;
  double get totalMargin => weeklyMargin * weeks.length;

  Map<String, dynamic> toMap() => {
        'transactionId': transactionId,
        'orderId': orderId,
        'vehicleType': vehicleType.wire,
        'dailyRate': dailyRate,
        'partnerDailyRate': partnerDailyRate,
        'offPeak': offPeak,
        'weeks': [for (final w in weeks) w.toMap()],
        if (confirmationScreenshotPath != null &&
            confirmationScreenshotPath!.isNotEmpty)
          'confirmationScreenshotPath': confirmationScreenshotPath,
        if (invoiceScreenshotPath != null &&
            invoiceScreenshotPath!.isNotEmpty)
          'invoiceScreenshotPath': invoiceScreenshotPath,
        if (note != null && note!.isNotEmpty) 'note': note,
        if (createdByUid != null) 'createdByUid': createdByUid,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory SesoConfirmation.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? const <String, dynamic>{};
    final rawWeeks = m['weeks'];
    final weeks = <SesoWeekEntry>[];
    if (rawWeeks is List) {
      for (final r in rawWeeks) {
        if (r is Map<String, dynamic>) weeks.add(SesoWeekEntry.fromMap(r));
        else if (r is Map) {
          weeks.add(
            SesoWeekEntry.fromMap(r.map((k, v) => MapEntry(k.toString(), v))),
          );
        }
      }
    }
    weeks.sort((a, b) {
      final byYear = a.year.compareTo(b.year);
      if (byYear != 0) return byYear;
      return a.weekNumber.compareTo(b.weekNumber);
    });

    final createdAt = m['createdAt'];
    final updatedAt = m['updatedAt'];

    final pickupTs = m['pickupDate'];
    final returnTs = m['returnDate'];

    return SesoConfirmation(
      id: doc.id,
      transactionId: (m['transactionId'] ?? '').toString(),
      orderId: (m['orderId'] ?? '').toString(),
      vehicleType: SesoVehicleTypeX.fromWire(m['vehicleType']?.toString()),
      dailyRate: (m['dailyRate'] as num?)?.toDouble() ?? 0.0,
      partnerDailyRate:
          (m['partnerDailyRate'] as num?)?.toDouble() ?? 0.0,
      offPeak: m['offPeak'] == true,
      weeks: weeks,
      confirmationScreenshotPath:
          (m['confirmationScreenshotPath'] ?? '').toString().isEmpty
              ? null
              : m['confirmationScreenshotPath'] as String,
      invoiceScreenshotPath:
          (m['invoiceScreenshotPath'] ?? '').toString().isEmpty
              ? null
              : m['invoiceScreenshotPath'] as String,
      rentalCompanyId: (m['rentalCompanyId'] ?? '').toString().isEmpty
          ? null
          : m['rentalCompanyId'] as String,
      pickupDate: pickupTs is Timestamp ? pickupTs.toDate() : null,
      returnDate: returnTs is Timestamp ? returnTs.toDate() : null,
      vehicleCount: (m['vehicleCount'] as num?)?.toInt() ??
          (m['pickupVehicleCount'] as num?)?.toInt() ??
          (m['returnVehicleCount'] as num?)?.toInt(),
      pickupVehicleCount: (m['pickupVehicleCount'] as num?)?.toInt(),
      returnVehicleCount: (m['returnVehicleCount'] as num?)?.toInt(),
      calendarPickupEventId:
          (m['calendarPickupEventId'] ?? '').toString().isEmpty
              ? null
              : m['calendarPickupEventId'] as String,
      calendarReturnEventId:
          (m['calendarReturnEventId'] ?? '').toString().isEmpty
              ? null
              : m['calendarReturnEventId'] as String,
      note: (m['note'] ?? '').toString().isEmpty
          ? null
          : m['note'] as String,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      createdByUid: (m['createdByUid'] ?? '').toString().isEmpty
          ? null
          : m['createdByUid'] as String,
    );
  }
}

/// One rental company (Mietfirma) stored under the admin's namespace.
/// Used by SESO confirmations to attach a vendor + their pickup address
/// so calendar entries for Abholung / Abgabe can be auto-populated.
class RentalCompany {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? note;
  final DateTime? createdAt;

  const RentalCompany({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.note,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (note != null && note!.isNotEmpty) 'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory RentalCompany.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? const <String, dynamic>{};
    final created = m['createdAt'];
    return RentalCompany(
      id: doc.id,
      name: (m['name'] ?? '').toString(),
      address: (m['address'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString().isEmpty
          ? null
          : m['phone'] as String,
      email: (m['email'] ?? '').toString().isEmpty
          ? null
          : m['email'] as String,
      note: (m['note'] ?? '').toString().isEmpty
          ? null
          : m['note'] as String,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }
}

/// Pure pricing helpers — keep separate from the model so they can be
/// unit-tested without instantiating Firestore objects.
double sesoWeeklyCost(double dailyRate) => dailyRate * 7;
double sesoTotalCost(double dailyRate, int weekCount) =>
    sesoWeeklyCost(dailyRate) * weekCount;
