// lib/utils/vacation_pools.dart
//
// EINE gemeinsame Quelle für den Urlaubs-Saldo („Resturlaub").
//
// Vorher rechneten vier Stellen dieselbe Formel jeweils eigenhändig nach
// (Drivers Hub, Drivers-Hub-Detailseite, „DA Balance" in den
// Abwesenheiten und die Fahrer-App). Diese Datei bündelt die Logik, damit
// Admin und Fahrer garantiert dieselbe Zahl sehen.
//
// ───────────────────────────────────────────────────────────────────────
// ZWEI BETRIEBSARTEN
// ───────────────────────────────────────────────────────────────────────
//
// 1. LEGACY (Default, [VacationPoolsConfig.disabled])
//    Genau das bisherige Verhalten: EIN Topf, kein Verfallsdatum.
//      anteiliger Anspruch = Jahresurlaub / 12 × volle Monate seit
//      Beschäftigungsbeginn (ohne Beginn: voller Jahresanspruch)
//      Resturlaub = Anspruch − genehmigter, BEZAHLTER Urlaub
//    DSPs, die nichts konfigurieren, bleiben exakt hier.
//
// 2. TÖPFE (opt-in je DSP über `users/{dspUid}/settings/vacation_pools`
//    mit `enabled: true`)
//    Mehrere Urlaubs-Töpfe je Bezugsjahr mit EIGENEM Verfallsdatum, z. B.
//    der deutsche Standardfall:
//      • „Gesetzlich"  — 20 Tage, verfällt 31.03. des FOLGEjahres
//      • „Zusätzlich"  —  4 Tage, verfällt 31.12. des SELBEN Jahres
//
// ───────────────────────────────────────────────────────────────────────
// ABZUGSREGEL (Ticket „getrennte Verfallsdaten")
// ───────────────────────────────────────────────────────────────────────
//
// Genommene Urlaubstage werden ARBEITNEHMERFREUNDLICH verbucht: jeder
// einzelne Urlaubstag geht in den Topf, der am FRÜHESTEN verfällt und
// den Tag noch abdeckt. Damit werden erst die zum 31.12. verfallenden
// Zusatztage aufgebraucht und die gesetzlichen Tage (Restlaufzeit bis
// 31.03. des Folgejahres) bleiben so lange wie möglich erhalten.
//
// Ein Topf des Jahres `y` deckt Urlaubstage im Fenster
// `[01.01.y, Verfallsdatum]` ab. Ist das Verfallsdatum überschritten,
// zählt der Topf nicht mehr als verfügbar ([VacationBalance.pools]
// enthält ihn dann nicht mehr, [VacationBalance.expiredPools] schon).
//
// Urlaubstage, für die kein Topf mehr passt (z. B. nachgetragener Urlaub
// aus einem längst verfallenen Jahr), landen in
// [VacationBalance.unallocatedDays] und mindern den aktuellen Saldo
// bewusst NICHT.
//
// NICHT automatisiert (bewusst): Die gesetzliche Erinnerungspflicht —
// gesetzlicher Urlaub verfällt nur, wenn der Arbeitgeber rechtzeitig an
// den Resturlaub erinnert hat. Hier wird lediglich das Verfallsdatum
// ANGEZEIGT; es wird keine Erinnerung verschickt und kein Verfall
// „nachgewiesen".
//
// ───────────────────────────────────────────────────────────────────────
// MANUELLER ADMIN-OVERRIDE (`onboarding.remainingVacationDaysOverride`)
// ───────────────────────────────────────────────────────────────────────
//
// Bugfix: Der Override war bisher ein EINGEFRORENER Endwert — er gewann
// bedingungslos gegen die Berechnung (`override ?? computed`). Wer den
// Resturlaub einmal von Hand gesetzt hatte, bei dem wurde danach KEIN
// Urlaub mehr abgezogen; die Zahl blieb für immer stehen.
//
// Neu: Der Override ist eine MOMENTAUFNAHME zum Zeitpunkt
// `remainingVacationDaysOverrideAt`. Urlaub, der NACH diesem Zeitpunkt
// erfasst bzw. genehmigt wurde, wird davon abgezogen. Urlaub, der davor
// schon genehmigt war, gilt als im Override bereits berücksichtigt und
// wird NICHT doppelt abgezogen.
//
// Rückwärtskompatibel: Fehlt der Zeitstempel (ganz alte Overrides), gilt
// wie bisher der reine Override-Wert.

import 'dart:math' as math;

import 'vacation_days.dart';

/// Rundungstoleranz für die Tage-Arithmetik (halbe Tage sind möglich).
const double _epsilon = 0.000001;

// ---------------------------------------------------------------------------
// Konfiguration
// ---------------------------------------------------------------------------

/// Bekannte Topf-Schlüssel. Bewusst als Konstanten statt Enum, damit die
/// Firestore-Felder sprechend bleiben und später weitere Töpfe ohne
/// Migration dazukommen können.
class VacationPoolKeys {
  static const String statutory = 'statutory';
  static const String additional = 'additional';

  /// Pseudo-Topf im Legacy-Modus (ein Topf, kein Verfall).
  static const String legacy = 'legacy';
}

/// Definition EINES Urlaubs-Topfs: Tageszahl + Verfallsregel.
///
/// Die Verfallsregel ist relativ zum Bezugsjahr formuliert, damit sie
/// jahresunabhängig gespeichert werden kann:
/// `Verfall = DateTime(bezugsjahr + expiryYearOffset, expiryMonth, expiryDay)`.
class VacationPoolDef {
  const VacationPoolDef({
    required this.key,
    required this.days,
    required this.expiryMonth,
    required this.expiryDay,
    required this.expiryYearOffset,
  });

  final String key;
  final double days;
  final int expiryMonth;
  final int expiryDay;
  final int expiryYearOffset;

  /// Gesetzlicher Mindesturlaub — verfällt (nach Erinnerung) zum 31.03.
  /// des Folgejahres.
  static const VacationPoolDef statutoryDefault = VacationPoolDef(
    key: VacationPoolKeys.statutory,
    days: 20,
    expiryMonth: 3,
    expiryDay: 31,
    expiryYearOffset: 1,
  );

  /// Vertraglicher Zusatzurlaub — verfällt ohne Erinnerung zum 31.12.
  /// desselben Jahres.
  static const VacationPoolDef additionalDefault = VacationPoolDef(
    key: VacationPoolKeys.additional,
    days: 4,
    expiryMonth: 12,
    expiryDay: 31,
    expiryYearOffset: 0,
  );

  DateTime expiryFor(int year) => DateTime(
        year + expiryYearOffset,
        expiryMonth,
        expiryDay,
      );

  VacationPoolDef copyWith({double? days}) => VacationPoolDef(
        key: key,
        days: days ?? this.days,
        expiryMonth: expiryMonth,
        expiryDay: expiryDay,
        expiryYearOffset: expiryYearOffset,
      );
}

/// DSP-weite Topf-Konfiguration aus `users/{dspUid}/settings/vacation_pools`.
///
/// Fehlt das Dokument oder steht `enabled` nicht auf `true`, liefert
/// [VacationPoolsConfig.disabled] — und die Berechnung verhält sich
/// haargenau wie vor dem Feature (ein Topf, kein Verfall).
class VacationPoolsConfig {
  const VacationPoolsConfig({required this.enabled, required this.pools});

  final bool enabled;

  /// Töpfe in Anzeigereihenfolge (gesetzlich zuerst). Die Verbuchung
  /// sortiert intern selbst nach Verfallsdatum.
  final List<VacationPoolDef> pools;

  static const VacationPoolsConfig disabled =
      VacationPoolsConfig(enabled: false, pools: <VacationPoolDef>[]);

  /// Werkseinstellung, sobald ein DSP die Töpfe einschaltet.
  static const VacationPoolsConfig defaults = VacationPoolsConfig(
    enabled: true,
    pools: <VacationPoolDef>[
      VacationPoolDef.statutoryDefault,
      VacationPoolDef.additionalDefault,
    ],
  );

  /// Liest die DSP-Einstellungen. `null`/leer → [disabled].
  static VacationPoolsConfig fromSettings(Map<String, dynamic>? raw) {
    if (raw == null || raw['enabled'] != true) return disabled;

    VacationPoolDef read(VacationPoolDef fallback, String prefix) {
      return VacationPoolDef(
        key: fallback.key,
        days: _toDouble(raw['${prefix}Days']) ?? fallback.days,
        expiryMonth: _toInt(raw['${prefix}ExpiryMonth']) ?? fallback.expiryMonth,
        expiryDay: _toInt(raw['${prefix}ExpiryDay']) ?? fallback.expiryDay,
        expiryYearOffset: _toInt(raw['${prefix}ExpiryYearOffset']) ??
            fallback.expiryYearOffset,
      );
    }

    return VacationPoolsConfig(
      enabled: true,
      pools: <VacationPoolDef>[
        read(VacationPoolDef.statutoryDefault, VacationPoolKeys.statutory),
        read(VacationPoolDef.additionalDefault, VacationPoolKeys.additional),
      ],
    );
  }

  /// Firestore-Payload für `users/{dspUid}/settings/vacation_pools`.
  Map<String, dynamic> toSettings() {
    final map = <String, dynamic>{'enabled': enabled};
    for (final pool in pools) {
      map['${pool.key}Days'] = pool.days % 1 == 0 ? pool.days.toInt() : pool.days;
      map['${pool.key}ExpiryMonth'] = pool.expiryMonth;
      map['${pool.key}ExpiryDay'] = pool.expiryDay;
      map['${pool.key}ExpiryYearOffset'] = pool.expiryYearOffset;
    }
    return map;
  }

  /// Fahrer-individuelle Tageszahlen aus `onboarding` anwenden.
  ///
  /// Nur die TAGESZAHL ist je Fahrer übersteuerbar
  /// (`onboarding.vacationStatutoryDays` / `vacationAdditionalDays`) —
  /// die Verfallsdaten bleiben DSP-weit einheitlich.
  VacationPoolsConfig forDriver(Map<String, dynamic> onboarding) {
    if (!enabled) return this;
    return VacationPoolsConfig(
      enabled: true,
      pools: pools.map((pool) {
        final raw = onboarding[driverDaysFieldKey(pool.key)];
        final days = _toDouble(raw);
        return days == null || days < 0 ? pool : pool.copyWith(days: days);
      }).toList(growable: false),
    );
  }

  /// `onboarding`-Feldname für die fahrerindividuelle Tageszahl.
  static String driverDaysFieldKey(String poolKey) =>
      'vacation${poolKey[0].toUpperCase()}${poolKey.substring(1)}Days';

  VacationPoolDef? poolByKey(String key) {
    for (final pool in pools) {
      if (pool.key == key) return pool;
    }
    return null;
  }

  double get totalDays =>
      pools.fold<double>(0, (acc, pool) => acc + pool.days);
}

// ---------------------------------------------------------------------------
// Eingangsdaten
// ---------------------------------------------------------------------------

/// Ein Abwesenheits-Antrag, reduziert auf das für den Saldo Nötige.
class VacationAbsence {
  const VacationAbsence({
    required this.from,
    required this.to,
    required this.chargeable,
    required this.bookedAt,
  });

  final DateTime from;
  final DateTime to;

  /// Belastet das bezahlte Urlaubskontingent?
  ///
  /// Nur `type == 'vacation'`, `status == 'approved'` und `paid != false`.
  /// Sonderurlaub, Krankmeldungen, offene/abgelehnte/stornierte Anträge
  /// und unbezahlter Urlaub zählen — wie bisher — nicht mit.
  final bool chargeable;

  /// Zeitpunkt, ab dem der Urlaub „im System verbucht" war: bevorzugt
  /// `reviewedAt` (Genehmigung), sonst `submittedAt`/`createdAt`/
  /// `updatedAt`. Nur dieser Zeitstempel entscheidet, ob ein Antrag vor
  /// oder nach einem manuellen Resturlaubs-Override entstanden ist.
  final DateTime? bookedAt;

  /// Belastete Urlaubstage des Antrags.
  ///
  /// Ticket „TIME OFF & BALANCE": Samstage, Sonntage und die neun
  /// bundesweiten Feiertage zehren KEIN Urlaubskontingent auf — ein
  /// Antrag von Freitag bis Montag kostet also zwei Tage, nicht vier.
  /// Gezählt wird mit [vacationChargeableDays]; [inclusiveDays] bleibt
  /// als reine Kalendertage-Zählung für andere Abwesenheitsarten.
  int get days => vacationChargeableDays(from, to);

  /// Baut den Eintrag aus einem `absence_requests`-Dokument.
  /// Liefert `null`, wenn kein verwertbarer Zeitraum drinsteht.
  static VacationAbsence? fromMap(Map<String, dynamic> data) {
    final from = parseVacationDate(data['fromDate']);
    final to = parseVacationDate(data['toDate']);
    if (from == null || to == null) return null;

    final type = (data['type'] ?? '').toString().trim().toLowerCase();
    final status = (data['status'] ?? '').toString().trim().toLowerCase();
    // Konvention wie serverseitig (`computeMonthlyAccount`): fehlendes
    // `paid`-Feld (Bestandsdaten) gilt als bezahlt.
    final paid = data['paid'] is bool ? data['paid'] as bool : true;

    return VacationAbsence(
      from: _dateOnly(from),
      to: _dateOnly(to),
      chargeable: type == 'vacation' && status == 'approved' && paid,
      bookedAt: vacationBookedAtOf(data),
    );
  }
}

/// Kanonische [VacationAbsence.bookedAt]-Kette.
///
/// Bewusst als eigener Helfer, damit Aufrufer, die bereits ein eigenes
/// Item-Modell haben (z. B. `_AbsenceAdminItem` in „DA Balance"), NICHT
/// ihre eigene Reihenfolge erfinden — sonst berechnen zwei Anzeigeorte
/// unterschiedliche Override-Anker für denselben Antrag.
///
/// `reviewedAt` zuerst, weil erst die Genehmigung Tage verbraucht;
/// danach der Einreich-, Anlage- und zuletzt der Änderungszeitpunkt.
DateTime? vacationBookedAtOf(Map<String, dynamic> data) =>
    parseVacationDate(data['reviewedAt']) ??
    parseVacationDate(data['submittedAt']) ??
    parseVacationDate(data['createdAt']) ??
    parseVacationDate(data['updatedAt']);

// ---------------------------------------------------------------------------
// Ergebnis
// ---------------------------------------------------------------------------

/// Ein Topf im Bezugsjahr `year` mit seinem konkreten Verbrauch.
class VacationPoolSlice {
  const VacationPoolSlice({
    required this.key,
    required this.year,
    required this.entitlement,
    required this.used,
    required this.expiresOn,
  });

  final String key;
  final int year;

  /// Anspruch in diesem Jahr (im Eintrittsjahr anteilig gekürzt, bei
  /// gesetztem Override der daraus abgeleitete Startwert).
  final double entitlement;
  final double used;

  /// `null` = kein Verfall (Legacy-Modus).
  final DateTime? expiresOn;

  double get remaining {
    final left = entitlement - used;
    return left < 0 ? 0 : left;
  }

  bool isExpiredAt(DateTime now) {
    final expiry = expiresOn;
    if (expiry == null) return false;
    return _dateOnly(now).isAfter(_dateOnly(expiry));
  }
}

/// Gesamtergebnis: Töpfe + Kennzahlen für die Anzeige.
class VacationBalance {
  const VacationBalance({
    required this.pooled,
    required this.pools,
    required this.expiredPools,
    required this.unallocatedDays,
    required this.overrideValue,
    required this.overrideAt,
    required this.usedSinceOverride,
    required this.totalUsedAllTime,
  });

  /// `true` = Topf-Modus, `false` = Legacy (ein Topf ohne Verfall).
  final bool pooled;

  /// Noch gültige Töpfe, nach Verfallsdatum aufsteigend (der zuerst
  /// verfallende Topf steht vorn — das ist auch die Abzugsreihenfolge).
  final List<VacationPoolSlice> pools;

  /// Bereits verfallene Töpfe des laufenden und des Vorjahres — nur für
  /// die Anzeige („verfallen am …"), zählen nicht mehr mit.
  final List<VacationPoolSlice> expiredPools;

  /// Genehmigte Urlaubstage, für die kein gültiger Topf existiert.
  final double unallocatedDays;

  final double? overrideValue;
  final DateTime? overrideAt;

  /// Urlaubstage, die NACH dem Override erfasst/genehmigt wurden.
  final double usedSinceOverride;

  /// Alle genehmigten, bezahlten Urlaubstage (unabhängig von Töpfen) —
  /// für die „Genommen"-Kennzahl in der Fahrer-App.
  final double totalUsedAllTime;

  bool get overrideApplied => overrideValue != null;

  /// Verfügbarer Resturlaub über alle noch gültigen Töpfe.
  double get totalRemaining =>
      pools.fold<double>(0, (acc, pool) => acc + pool.remaining);

  /// Saldo MIT Vorzeichen (Ticket „Show negative PTO balance"): wird
  /// negativ, wenn mehr Urlaub genommen als erworben wurde. Nur im
  /// Legacy-Modus relevant — im Topf-Modus steckt Übernutzung bewusst in
  /// [unallocatedDays] und der Topf-Saldo bleibt bei 0 stehen.
  double get totalRemainingSigned =>
      pooled ? totalRemaining : totalEntitlement - totalUsed;

  double get totalEntitlement =>
      pools.fold<double>(0, (acc, pool) => acc + pool.entitlement);

  double get totalUsed => pools.fold<double>(0, (acc, pool) => acc + pool.used);

  VacationPoolSlice? poolByKey(String key) {
    for (final pool in pools) {
      if (pool.key == key) return pool;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Berechnung
// ---------------------------------------------------------------------------

/// Berechnet den Urlaubs-Saldo.
///
/// [annualVacationDays] und [workStartDate] stammen wie bisher aus
/// `onboarding`; [manualOverride]/[manualOverrideAt] aus
/// `onboarding.remainingVacationDaysOverride(At)`.
VacationBalance computeVacationBalance({
  required List<VacationAbsence> absences,
  required VacationPoolsConfig config,
  required double annualVacationDays,
  DateTime? workStartDate,
  double? manualOverride,
  DateTime? manualOverrideAt,
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());

  final chargeable =
      absences.where((a) => a.chargeable).toList(growable: false);
  final totalUsedAllTime =
      chargeable.fold<double>(0, (acc, a) => acc + a.days);

  // Urlaub, der nach dem Override erfasst/genehmigt wurde. Ohne
  // Zeitstempel bleibt es beim alten Verhalten: Override gewinnt komplett.
  final anchor = manualOverride == null ? null : manualOverrideAt;
  final sinceOverride = anchor == null
      ? const <VacationAbsence>[]
      : chargeable
          .where((a) => a.bookedAt != null && a.bookedAt!.isAfter(anchor))
          .toList(growable: false);
  final usedSinceOverride =
      sinceOverride.fold<double>(0, (acc, a) => acc + a.days);

  // Welche Anträge belasten die Töpfe? Mit Override nur die danach
  // hinzugekommenen (alles Ältere steckt bereits im Override-Wert).
  final consuming = manualOverride == null
      ? chargeable
      : (anchor == null ? const <VacationAbsence>[] : sinceOverride);

  if (!config.enabled) {
    return _legacyBalance(
      today: today,
      annualVacationDays: annualVacationDays,
      workStartDate: workStartDate,
      manualOverride: manualOverride,
      manualOverrideAt: manualOverrideAt,
      usedSinceOverride: usedSinceOverride,
      totalUsedAllTime: totalUsedAllTime,
      consumedDays: consuming.fold<double>(0, (acc, a) => acc + a.days),
    );
  }

  // ── Topf-Modus ────────────────────────────────────────────────────
  // Bezugsjahre: das laufende Jahr und das Vorjahr. Mehr braucht es
  // nicht — der am längsten laufende Topf (31.03. Folgejahr) ist Ende
  // März des Folgejahres erledigt.
  final years = <int>[today.year - 1, today.year];

  final ledger = <_LedgerEntry>[];
  for (final year in years) {
    for (final def in config.pools) {
      ledger.add(
        _LedgerEntry(
          key: def.key,
          year: year,
          entitlement: _entitlementForYear(def.days, year, workStartDate),
          windowStart: DateTime(year, 1, 1),
          expiry: def.expiryFor(year),
        ),
      );
    }
  }

  // Abzugsreihenfolge: was zuerst verfällt, wird zuerst verbraucht.
  ledger.sort((a, b) {
    final byExpiry = a.expiry.compareTo(b.expiry);
    return byExpiry != 0 ? byExpiry : a.year.compareTo(b.year);
  });

  // Override als Startwert: Der Admin hat den GESAMT-Resturlaub gesetzt.
  // Er wird spiegelbildlich zur Abzugsregel verteilt — die am spätesten
  // verfallenden Töpfe zuerst gefüllt, weil die früher verfallenden
  // Tage nach derselben Regel bereits verbraucht worden wären. Ein Rest
  // über alle Topf-Kapazitäten hinaus geht nicht verloren, sondern
  // landet im am längsten laufenden Topf.
  if (manualOverride != null) {
    final open = ledger
        .where((e) => !_dateOnly(e.expiry).isBefore(today))
        .toList(growable: false);
    var left = manualOverride < 0 ? 0.0 : manualOverride;
    for (final entry in ledger) {
      entry.entitlement = 0;
    }
    for (var i = open.length - 1; i >= 0 && left > 0; i--) {
      final take = math.min(open[i].capacity, left);
      open[i].entitlement = take;
      left -= take;
    }
    // Mehr Tage als alle Töpfe fassen → Überhang in den am längsten
    // laufenden Topf, damit nichts unter den Tisch fällt.
    if (left > 0 && open.isNotEmpty) {
      open.last.entitlement += left;
    }
  }

  // Jeden einzelnen Urlaubstag chronologisch verbuchen. Wochenenden und
  // bundesweite Feiertage bleiben außen vor — sie kosten keinen Urlaub
  // (siehe [VacationAbsence.days]).
  final days = <DateTime>[];
  for (final absence in consuming) {
    for (var day = absence.from;
        !day.isAfter(absence.to);
        day = day.add(const Duration(days: 1))) {
      if (!isVacationChargeableDay(day)) continue;
      days.add(_dateOnly(day));
    }
  }
  days.sort();

  var unallocated = 0.0;
  for (final day in days) {
    var todo = 1.0;
    // `ledger` ist nach Verfallsdatum sortiert → der zuerst verfallende
    // passende Topf wird zuerst belastet.
    for (final entry in ledger) {
      if (todo <= _epsilon) break;
      if (day.isBefore(entry.windowStart)) continue;
      if (day.isAfter(entry.expiry)) continue;
      final free = entry.entitlement - entry.used;
      if (free <= _epsilon) continue;
      final take = math.min(free, todo);
      entry.used += take;
      todo -= take;
    }
    if (todo > _epsilon) unallocated += todo;
  }

  final open = <VacationPoolSlice>[];
  final expired = <VacationPoolSlice>[];
  for (final entry in ledger) {
    final slice = VacationPoolSlice(
      key: entry.key,
      year: entry.year,
      entitlement: entry.entitlement,
      used: entry.used,
      expiresOn: entry.expiry,
    );
    if (slice.isExpiredAt(today)) {
      // Verfallene Töpfe sind nur interessant, wenn dort tatsächlich
      // Urlaub verbucht wurde — sonst wäre die Liste voller leerer
      // Vorjahres-Töpfe.
      if (slice.used > _epsilon) expired.add(slice);
    } else {
      open.add(slice);
    }
  }

  return VacationBalance(
    pooled: true,
    pools: open,
    expiredPools: expired,
    unallocatedDays: unallocated,
    overrideValue: manualOverride,
    overrideAt: manualOverrideAt,
    usedSinceOverride: usedSinceOverride,
    totalUsedAllTime: totalUsedAllTime,
  );
}

VacationBalance _legacyBalance({
  required DateTime today,
  required double annualVacationDays,
  required DateTime? workStartDate,
  required double? manualOverride,
  required DateTime? manualOverrideAt,
  required double usedSinceOverride,
  required double totalUsedAllTime,
  required double consumedDays,
}) {
  // Unveränderte Bestandsformel.
  final accrued = workStartDate == null
      ? annualVacationDays
      : (annualVacationDays / 12.0) *
          completedMonthsSince(workStartDate, today);

  final entitlement = manualOverride ?? accrued;
  final used = manualOverride == null ? consumedDays : usedSinceOverride;

  final slice = VacationPoolSlice(
    key: VacationPoolKeys.legacy,
    year: today.year,
    entitlement: entitlement < 0 ? 0 : entitlement,
    used: used,
    expiresOn: null,
  );

  return VacationBalance(
    pooled: false,
    pools: <VacationPoolSlice>[slice],
    expiredPools: const <VacationPoolSlice>[],
    unallocatedDays: 0,
    overrideValue: manualOverride,
    overrideAt: manualOverrideAt,
    usedSinceOverride: usedSinceOverride,
    totalUsedAllTime: totalUsedAllTime,
  );
}

/// Anspruch eines Topfes im Jahr [year].
///
/// Beginnt das Arbeitsverhältnis im Bezugsjahr, gilt der übliche
/// Zwölftel-Anspruch (1/12 je vollem Beschäftigungsmonat), aufgerundet
/// auf halbe Tage. Vor dem Eintritt: 0 Tage.
double _entitlementForYear(double days, int year, DateTime? workStartDate) {
  if (workStartDate == null) return days;
  final start = _dateOnly(workStartDate);
  if (start.year > year) return 0;
  if (start.year < year) return days;

  // Volle Monate im Eintrittsjahr: ab dem Eintrittsmonat, wenn am
  // Monatsersten begonnen wurde, sonst ab dem Folgemonat.
  final firstFullMonth = start.day == 1 ? start.month : start.month + 1;
  final months = 12 - firstFullMonth + 1;
  if (months <= 0) return 0;
  if (months >= 12) return days;
  final prorated = days * months / 12.0;
  return (prorated * 2).ceil() / 2.0;
}

class _LedgerEntry {
  _LedgerEntry({
    required this.key,
    required this.year,
    required this.entitlement,
    required this.windowStart,
    required this.expiry,
  }) : capacity = entitlement;

  final String key;
  final int year;

  /// Ursprünglicher Anspruch — Obergrenze beim Verteilen eines Overrides.
  final double capacity;

  double entitlement;
  double used = 0;
  final DateTime windowStart;
  final DateTime expiry;
}

// ---------------------------------------------------------------------------
// Gemeinsame kleine Helfer (bisher in vier Screens dupliziert)
// ---------------------------------------------------------------------------

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Kalendertage inklusive Start- und Endtag (Bestandskonvention:
/// Wochenenden und Feiertage zählen mit).
int inclusiveDays(DateTime? from, DateTime? to) {
  if (from == null || to == null) return 0;
  final start = _dateOnly(from);
  final end = _dateOnly(to);
  if (end.isBefore(start)) return 0;
  return end.difference(start).inDays + 1;
}

int completedMonthsSince(DateTime start, DateTime now) {
  final safeStart = _dateOnly(start);
  final safeNow = _dateOnly(now);
  var months = (safeNow.year - safeStart.year) * 12 +
      (safeNow.month - safeStart.month);
  if (safeNow.day < safeStart.day) months -= 1;
  return months < 0 ? 0 : months;
}

/// Versteht alle im Bestand vorkommenden Datumsformate: `Timestamp`,
/// `DateTime`, ISO-8601 und `TT/MM/JJJJ`.
DateTime? parseVacationDate(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  // `Timestamp` ohne Firestore-Import (diese Datei bleibt SDK-frei).
  try {
    final dynamic dyn = raw;
    if (dyn is! String && dyn is! num) {
      final converted = dyn.toDate();
      if (converted is DateTime) return converted;
    }
  } catch (_) {
    // kein Timestamp — weiter mit den String-Formaten
  }
  if (raw is num) {
    return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
  }
  final value = raw.toString().trim();
  if (value.isEmpty) return null;
  final slash = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(value);
  if (slash != null) {
    final day = int.tryParse(slash.group(1)!);
    final month = int.tryParse(slash.group(2)!);
    final year = int.tryParse(slash.group(3)!);
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }
  final dotted = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$').firstMatch(value);
  if (dotted != null) {
    final day = int.tryParse(dotted.group(1)!);
    final month = int.tryParse(dotted.group(2)!);
    final year = int.tryParse(dotted.group(3)!);
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }
  }
  return DateTime.tryParse(value);
}

double? _toDouble(Object? raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String && raw.trim().isNotEmpty) {
    return double.tryParse(raw.trim().replaceAll(',', '.'));
  }
  return null;
}

int? _toInt(Object? raw) {
  final value = _toDouble(raw);
  return value?.round();
}

/// Fahrer-Jahresurlaub aus `onboarding` (Default 20) — Bestandslogik.
double annualVacationDaysOf(Map<String, dynamic> onboarding,
    {double fallback = 20}) {
  final value = _toDouble(onboarding['annualVacationDays']);
  if (value != null && value > 0) return value;
  return fallback;
}

/// Manueller Resturlaubs-Override aus `onboarding` (oder `null`).
double? vacationOverrideOf(Map<String, dynamic> onboarding) =>
    _toDouble(onboarding['remainingVacationDaysOverride']);

DateTime? vacationOverrideAtOf(Map<String, dynamic> onboarding) =>
    parseVacationDate(onboarding['remainingVacationDaysOverrideAt']);

/// Tageszahl formatieren: ganze Zahlen ohne Nachkommastellen.
String formatVacationDays(double value) {
  if (value % 1 == 0) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String formatVacationDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.${value.year}';
