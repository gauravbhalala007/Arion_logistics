import 'package:flutter/material.dart';

/// Fixed list of employment contracts a DSP can hire a driver under.
/// Stored as the [value] string on the driver doc
/// (`users/{adminUid}/drivers/{tid}.contractType`).
enum DriverContractType {
  fulltime('fulltime'),
  parttime4d('parttime_4d'),
  parttime3d('parttime_3d'),
  parttime2d('parttime_2d'),
  minijob('minijob');

  const DriverContractType(this.value);
  final String value;

  /// Strict parser — anything we don't recognise comes back as null.
  /// The UI uses null to mean "no contract type set" (legacy drivers).
  static DriverContractType? fromValue(dynamic v) {
    final s = (v ?? '').toString().trim().toLowerCase();
    if (s.isEmpty) return null;
    for (final c in DriverContractType.values) {
      if (c.value == s) return c;
    }
    return null;
  }

  String get label {
    switch (this) {
      case DriverContractType.fulltime:
        return 'Fulltime';
      case DriverContractType.parttime4d:
        return 'Parttime 4 Days';
      case DriverContractType.parttime3d:
        return 'Parttime 3 Days';
      case DriverContractType.parttime2d:
        return 'Parttime 2 Days';
      case DriverContractType.minijob:
        return 'Minijob';
    }
  }

  /// Compact label used inside the driver-row pill — saves horizontal
  /// space while staying readable.
  String get shortLabel {
    switch (this) {
      case DriverContractType.fulltime:
        return 'Fulltime';
      case DriverContractType.parttime4d:
        return 'PT · 4d';
      case DriverContractType.parttime3d:
        return 'PT · 3d';
      case DriverContractType.parttime2d:
        return 'PT · 2d';
      case DriverContractType.minijob:
        return 'Minijob';
    }
  }

  Color get pillColor {
    switch (this) {
      case DriverContractType.fulltime:
        return const Color(0xFF1D7F5A);
      case DriverContractType.parttime4d:
        return const Color(0xFF0369A1);
      case DriverContractType.parttime3d:
        return const Color(0xFF7C3AED);
      case DriverContractType.parttime2d:
        return const Color(0xFFB45309);
      case DriverContractType.minijob:
        return const Color(0xFF6B7280);
    }
  }
}
