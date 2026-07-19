// lib/models/time_account.dart
//
// "Zeitkonto" feature data model. Captures what comes out of the
// external payroll-export Excel: per-employee, per-month Soll- and
// Ist-Stunden plus an overtime balance. Stores per-employee monthly
// rows AND a top-level summary that includes manually-recorded
// "bezahlte Stunden" (paid hours) which reduce the open overtime.

import 'package:cloud_firestore/cloud_firestore.dart';

/// One row from a payroll Excel — one employee for one billing
/// period (typically a month).
class TimeImportEntry {
  final String id;
  final String employeeName;
  final String employeeId;
  final double sollHours;     // contractual expected hours
  final double istHours;      // time tracked
  final double overtimeBalance; // from Excel, may differ from ist-soll
  final String? deliveryStation;
  final String? contractType;
  final double? hourlyRate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, dynamic>? raw; // audit copy of the parsed row

  const TimeImportEntry({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.sollHours,
    required this.istHours,
    required this.overtimeBalance,
    required this.periodStart,
    required this.periodEnd,
    this.deliveryStation,
    this.contractType,
    this.hourlyRate,
    this.raw,
  });

  /// Year-month bucket for grouping into [TimeAccountMonth].
  String get periodKey =>
      '${periodStart.year}-${periodStart.month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'employeeName': employeeName,
        'employeeId': employeeId,
        'sollHours': sollHours,
        'istHours': istHours,
        'overtimeBalance': overtimeBalance,
        'periodStart': Timestamp.fromDate(periodStart),
        'periodEnd': Timestamp.fromDate(periodEnd),
        if (deliveryStation != null) 'deliveryStation': deliveryStation,
        if (contractType != null) 'contractType': contractType,
        if (hourlyRate != null) 'hourlyRate': hourlyRate,
        if (raw != null) 'raw': raw,
      };

  factory TimeImportEntry.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? const <String, dynamic>{};
    final ps = m['periodStart'];
    final pe = m['periodEnd'];
    return TimeImportEntry(
      id: doc.id,
      employeeName: (m['employeeName'] ?? '').toString(),
      employeeId: (m['employeeId'] ?? '').toString(),
      sollHours: (m['sollHours'] as num?)?.toDouble() ?? 0.0,
      istHours: (m['istHours'] as num?)?.toDouble() ?? 0.0,
      overtimeBalance:
          (m['overtimeBalance'] as num?)?.toDouble() ?? 0.0,
      deliveryStation: (m['deliveryStation'] ?? '').toString().isEmpty
          ? null
          : m['deliveryStation'] as String,
      contractType: (m['contractType'] ?? '').toString().isEmpty
          ? null
          : m['contractType'] as String,
      hourlyRate: (m['hourlyRate'] as num?)?.toDouble(),
      periodStart:
          ps is Timestamp ? ps.toDate() : DateTime.now(),
      periodEnd: pe is Timestamp ? pe.toDate() : DateTime.now(),
      raw: m['raw'] is Map<String, dynamic>
          ? m['raw'] as Map<String, dynamic>
          : null,
    );
  }
}

class TimeImport {
  final String id;
  final String filename;
  final DateTime? uploadedAt;
  final String? uploadedByUid;
  final int rowCount;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final String? storagePath;

  const TimeImport({
    required this.id,
    required this.filename,
    required this.rowCount,
    this.uploadedAt,
    this.uploadedByUid,
    this.periodStart,
    this.periodEnd,
    this.storagePath,
  });

  factory TimeImport.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? const <String, dynamic>{};
    final ua = m['uploadedAt'];
    final ps = m['periodStart'];
    final pe = m['periodEnd'];
    return TimeImport(
      id: doc.id,
      filename: (m['filename'] ?? '').toString(),
      rowCount: (m['rowCount'] as num?)?.toInt() ?? 0,
      uploadedAt: ua is Timestamp ? ua.toDate() : null,
      uploadedByUid: (m['uploadedByUid'] ?? '').toString().isEmpty
          ? null
          : m['uploadedByUid'] as String,
      periodStart: ps is Timestamp ? ps.toDate() : null,
      periodEnd: pe is Timestamp ? pe.toDate() : null,
      storagePath: (m['storagePath'] ?? '').toString().isEmpty
          ? null
          : m['storagePath'] as String,
    );
  }
}

/// Manual ledger entry — admin records that some overtime has been
/// paid out, reducing the open balance for that employee.
class PaidHoursEntry {
  final String id;
  final String employeeId;
  final String employeeName;
  final double hours;
  final DateTime paidAt;
  final String? note;
  final String? createdByUid;

  const PaidHoursEntry({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.hours,
    required this.paidAt,
    this.note,
    this.createdByUid,
  });

  Map<String, dynamic> toMap() => {
        'employeeId': employeeId,
        'employeeName': employeeName,
        'hours': hours,
        'paidAt': Timestamp.fromDate(paidAt),
        if (note != null && note!.isNotEmpty) 'note': note,
        if (createdByUid != null) 'createdByUid': createdByUid,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory PaidHoursEntry.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final m = doc.data() ?? const <String, dynamic>{};
    final pa = m['paidAt'];
    return PaidHoursEntry(
      id: doc.id,
      employeeId: (m['employeeId'] ?? '').toString(),
      employeeName: (m['employeeName'] ?? '').toString(),
      hours: (m['hours'] as num?)?.toDouble() ?? 0.0,
      paidAt: pa is Timestamp ? pa.toDate() : DateTime.now(),
      note: (m['note'] ?? '').toString().isEmpty
          ? null
          : m['note'] as String,
      createdByUid: (m['createdByUid'] ?? '').toString().isEmpty
          ? null
          : m['createdByUid'] as String,
    );
  }
}

/// Aggregated per-employee snapshot, computed in-app from the union
/// of all imported [TimeImportEntry]s and [PaidHoursEntry]s.
class TimeAccountAggregate {
  final String employeeId;
  final String employeeName;
  /// Lifetime overtime accumulated across all imported months
  /// (= Σ overtimeBalance OR Σ (ist − soll) — whichever is non-zero).
  final double lifetimeOvertime;
  /// Lifetime paid-out hours (manual entries).
  final double paidHours;
  /// Open balance the company still owes.
  double get openOvertime => lifetimeOvertime - paidHours;
  /// Per-month detail — sorted ascending by period.
  final List<TimeImportEntry> months;

  TimeAccountAggregate({
    required this.employeeId,
    required this.employeeName,
    required this.lifetimeOvertime,
    required this.paidHours,
    required this.months,
  });

  /// Returns the month entry for the given (year, month), or null.
  TimeImportEntry? entryFor(int year, int month) {
    for (final m in months) {
      if (m.periodStart.year == year && m.periodStart.month == month) {
        return m;
      }
    }
    return null;
  }
}
