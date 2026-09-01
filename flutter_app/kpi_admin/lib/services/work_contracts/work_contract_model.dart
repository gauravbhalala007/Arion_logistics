// lib/services/work_contracts/work_contract_model.dart
//
// Work Contracts (nur Arion Logistics): Datenmodell für die Vertrags-
// erstellung. Vertragstexte basieren auf den Ogletree-Mustern (Befristeter/
// Unbefristeter Arbeitsvertrag Vollzeit oder Teilzeit, Jan/Feb 2025) —
// OHNE Spesen-/Auslagen-Klauseln (Vorgabe Arion).

/// Vertragstyp — bestimmt Wochentage, Standard-Wochenstunden und den
/// automatisch berechneten gesetzlichen Mindesturlaub.
enum WcType {
  fulltime5('fulltime5'),
  parttime4('parttime4'),
  parttime3('parttime3'),
  parttime2('parttime2'),
  werkstudent('werkstudent'),
  minijob('minijob'),
  visa('visa');

  const WcType(this.value);
  final String value;

  /// Arbeitstage pro Woche (Basis der Urlaubsberechnung).
  int get daysPerWeek {
    switch (this) {
      case WcType.fulltime5:
      case WcType.visa:
        return 5;
      case WcType.parttime4:
        return 4;
      case WcType.parttime3:
        return 3;
      case WcType.parttime2:
      case WcType.werkstudent:
      case WcType.minijob:
        return 2;
    }
  }

  /// Standard-Wochenstunden.
  double get defaultHoursPerWeek {
    switch (this) {
      case WcType.fulltime5:
      case WcType.visa:
        return 40;
      case WcType.parttime4:
        return 32;
      case WcType.parttime3:
        return 24;
      case WcType.parttime2:
        return 16;
      case WcType.werkstudent:
        return 16;
      case WcType.minijob:
        return 8;
    }
  }

  String labelDe() {
    switch (this) {
      case WcType.fulltime5:
        return 'Vollzeit (5 Tage)';
      case WcType.parttime4:
        return 'Teilzeit (4 Tage)';
      case WcType.parttime3:
        return 'Teilzeit (3 Tage)';
      case WcType.parttime2:
        return 'Teilzeit (2 Tage)';
      case WcType.werkstudent:
        return 'Werkstudent';
      case WcType.minijob:
        return 'Minijob';
      case WcType.visa:
        return 'Arbeitsvisum (Vollzeit)';
    }
  }

  String labelEn() {
    switch (this) {
      case WcType.fulltime5:
        return 'Full-time (5 days)';
      case WcType.parttime4:
        return 'Part-time (4 days)';
      case WcType.parttime3:
        return 'Part-time (3 days)';
      case WcType.parttime2:
        return 'Part-time (2 days)';
      case WcType.werkstudent:
        return 'Working student';
      case WcType.minijob:
        return 'Mini job';
      case WcType.visa:
        return 'Work visa (full-time)';
    }
  }
}

/// Festvertrag (Monatsgehalt) oder Stundenvertrag (Stundenlohn).
enum WcPay { monthly, hourly }

/// Gesetzlicher Mindesturlaub: 20 Tage bei 5-Tage-Woche, anteilig weniger
/// (20/5 = 4 Tage Urlaub je Wochenarbeitstag). Minijob (2 Tage/Woche im
/// Standard) hat laut Arion-Vorgabe 4 Tage Jahresurlaub — das entspricht
/// bewusst NICHT der anteiligen Formel und wird separat gesetzt.
int wcVacationDays(WcType type, int daysPerWeek) {
  if (type == WcType.minijob) return 4;
  final d = daysPerWeek.clamp(1, 6);
  return (20 * d / 5).round();
}

/// Monatsgehalt aus Stundenlohn: Wochenstunden × 4,325 Wochen/Monat —
/// so ergibt der Arion-Standard (16,20 € × 40 h) exakt 2.802,60 €.
double wcMonthlySalary(double hourlyWage, double hoursPerWeek) {
  final v = hourlyWage * hoursPerWeek * 4.325;
  return (v * 100).roundToDouble() / 100;
}

/// Arbeitgeber-Konstanten (Arion Logistics GmbH).
class WcEmployer {
  static const name = 'ARION Logistics GmbH';
  static const street = 'Industriestr. 12a';
  static const zipCity = '91325 Adelsdorf';
  static const city = 'Adelsdorf';
  static const web = 'www.arion-logistics.de';
  static const email = 'info@arion-logistics.de';
  static const phone = '+49 911 13 06 53 52';
  static const managingDirector = 'Albert Dobra';
  static const betriebsnummer = '75048550';
  static const contactPhone = '01708139442';
}

/// Alle Eingaben für einen Vertragsentwurf.
class WorkContractData {
  WorkContractData({
    required this.type,
    required this.pay,
    required this.fixedTerm,
    required this.employeeName,
    required this.employeeStreet,
    required this.employeeZipCity,
    this.birthDate,
    this.nationality = '',
    this.residenceSince,
    this.gender = '',
    required this.startDate,
    this.endDate,
    required this.hourlyWage,
    required this.monthlySalary,
    required this.hoursPerWeek,
    required this.vacationDays,
    this.probationMonths = 6,
    required this.signCity,
    required this.signDate,
    this.ezbProcedure = 'vorabzustimmung',
    this.ezbOccasion = 'ersterteilung',
  });

  final WcType type;
  final WcPay pay;
  final bool fixedTerm;

  final String employeeName;
  final String employeeStreet;
  final String employeeZipCity;
  final DateTime? birthDate;
  final String nationality;
  final DateTime? residenceSince;

  /// 'm' | 'w' | 'd' | '' — nur für das EzB-Formular (Visum).
  final String gender;

  /// Beginn des Arbeitsverhältnisses (Vertrags- und Befristungsbasis).
  final DateTime startDate;
  final DateTime? endDate;

  final double hourlyWage;
  final double monthlySalary;
  final double hoursPerWeek;
  final int vacationDays;
  final int probationMonths;

  final String signCity;
  final DateTime signDate;

  /// EzB (Visum): 'aufenthaltstitel' | 'vorabzustimmung' | 'arbeitserlaubnis'
  final String ezbProcedure;

  /// EzB (Visum): 'ersterteilung' | 'verlaengerung' | 'wechsel'
  final String ezbOccasion;

  bool get isVisa => type == WcType.visa;
  bool get isMinijob => type == WcType.minijob;
  bool get isWerkstudent => type == WcType.werkstudent;

  String get payAmountLabel => pay == WcPay.monthly
      ? '${_eur(monthlySalary)} €'
      : '${_eur(hourlyWage)} €/Std.';
}

String _eur(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

String wcEur(double v) => _eur(v);

String wcDate(DateTime? d) => d == null
    ? ''
    : '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

String wcHours(double h) =>
    h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1).replaceAll('.', ',');

// ── Kündigungen / Aufhebungsvertrag ──────────────────────────────────

/// Art der Beendigung — bestimmt Text und Standard-Beendigungsdatum.
enum WcTerminationType {
  ordentlich('ordentlich'),
  probezeit('probezeit'),
  fristlos('fristlos'),
  aufhebung('aufhebung');

  const WcTerminationType(this.value);
  final String value;

  String labelDe() {
    switch (this) {
      case WcTerminationType.ordentlich:
        return 'Ordentliche Kündigung';
      case WcTerminationType.probezeit:
        return 'Kündigung in der Probezeit';
      case WcTerminationType.fristlos:
        return 'Fristlose Kündigung';
      case WcTerminationType.aufhebung:
        return 'Aufhebungsvertrag';
    }
  }

  String labelEn() {
    switch (this) {
      case WcTerminationType.ordentlich:
        return 'Regular termination';
      case WcTerminationType.probezeit:
        return 'Termination during probation';
      case WcTerminationType.fristlos:
        return 'Immediate termination';
      case WcTerminationType.aufhebung:
        return 'Mutual termination agreement';
    }
  }
}

/// Standard-Beendigungsdatum je Art (immer überschreibbar):
/// • fristlos / Aufhebungsvertrag → heute
/// • Probezeit → heute + 2 Wochen (taggenau, § 622 Abs. 3 BGB)
/// • ordentlich → gesetzliche Grundfrist § 622 Abs. 1 BGB:
///   4 Wochen (28 Tage) zum 15. ODER zum Ende eines Kalendermonats —
///   also der früheste 15. bzw. Monatsletzte, der mindestens 28 Tage
///   nach heute liegt.
DateTime wcTerminationDefaultEndDate(WcTerminationType type, DateTime today) {
  final t0 = DateTime(today.year, today.month, today.day);
  switch (type) {
    case WcTerminationType.fristlos:
    case WcTerminationType.aufhebung:
      return t0;
    case WcTerminationType.probezeit:
      return t0.add(const Duration(days: 14));
    case WcTerminationType.ordentlich:
      final earliest = t0.add(const Duration(days: 28));
      // Kandidaten: 15. und Monatsletzter der nächsten Monate.
      for (var m = 0; m < 4; m++) {
        final month = DateTime(t0.year, t0.month + m, 1);
        final mid = DateTime(month.year, month.month, 15);
        final end = DateTime(month.year, month.month + 1, 0);
        if (!mid.isBefore(earliest)) return mid;
        if (!end.isBefore(earliest)) return end;
      }
      return earliest;
  }
}

/// Eingaben für ein Kündigungs-/Aufhebungsdokument (eine PDF-Seite).
class WcTerminationData {
  WcTerminationData({
    required this.type,
    required this.employeeName,
    required this.employeeStreet,
    required this.employeeZipCity,
    required this.endDate,
    required this.signCity,
    required this.signDate,
    this.reason = '',
    this.withSignature = true,
  });

  final WcTerminationType type;
  final String employeeName;
  final String employeeStreet;
  final String employeeZipCity;

  /// Beendigungs- bzw. Wirksamkeitsdatum.
  final DateTime endDate;
  final String signCity;
  final DateTime signDate;

  /// Optionaler Grund — nur bei fristloser Kündigung mit ausgegeben.
  final String reason;

  /// GF-Unterschrift eindrucken? Abwählbar, falls handschriftlich
  /// unterschrieben werden soll.
  final bool withSignature;
}
