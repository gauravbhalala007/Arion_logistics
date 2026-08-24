// lib/services/vehicle_check_service.dart
//
// Geführte Foto-Fahrzeuginspektion ("Vehicle Check") — Datenmodell,
// Firestore-/Storage-Pfade und Hilfsfunktionen für Fahrer- und Admin-Seite.
//
// ─────────────────────────────────────────────────────────────────────────
//  PFAD-ENTSCHEIDUNGEN (Firestore-Rules dürfen NICHT geändert werden)
// ─────────────────────────────────────────────────────────────────────────
//
//  Firestore:  users/{dspUid}/drivers/{TID}/incident_reports/{checkId}
//
//    Ein eigener Pfad `.../vehicle_checks/{checkId}` wäre für den Fahrer
//    NICHT schreibbar: unter `users/{userId}` greift nur die Blanket-Rule
//    `match /{document=**} { allow read, write: if isSelf(userId) ||
//    isDispatcherOf(userId) }` — Fahrer sind dort nicht enthalten.
//    Fahrer-schreibbar sind ausschließlich die explizit gelisteten
//    Subcollections. Die einzige davon mit freier Doc-ID, ohne Pflicht-
//    Feldschema und OHNE bestehende Leser im Code ist
//    `users/{dspUid}/drivers/{driverId}/incident_reports/{reportId}`
//    (firestore.rules:1101-1114 — `create, update` für
//    `isDriverForUser(dspUid) && driverTransporterId() == driverId &&
//    request.resource.data.driverTransporterId == driverId`).
//
//    Deshalb liegen Checks dort und tragen `kind: 'vehicle_check'`
//    ([kVehicleCheckKind]) als Marker. Das Admin-Incident-Center liest
//    `users/{dspUid}/incident_reports` (Top-Level) — die Check-Dokumente
//    tauchen dort also NICHT auf und verfälschen keine Vorfall-Zähler.
//
//    TODO(rules): sobald ein Rules-Deploy möglich ist, eine eigene
//    `match /vehicle_checks/{checkId}`-Regel unter `drivers/{driverId}`
//    ergänzen und `kVehicleCheckCollection` umstellen.
//
//  Storage:    incident_reports/{dspUid}/{TID}/{checkId}/vehicle_check/{step}.jpg
//
//    `driver_docs/{tid}/vehicle_checks/{checkId}/{step}.jpg` scheitert an
//    storage.rules:128 — die Regel matcht nur EIN Pfadsegment nach der
//    Transporter-ID (`match /driver_docs/{tid}/{fileName}`). Der
//    Incident-Pfad (storage.rules:208) matcht dagegen exakt
//    `{dspUid}/{tid}/{reportId}/{folder}/{fileName}`, ist DSP-scoped und
//    für den Fahrer selbst schreibbar. `contentType` MUSS gesetzt sein,
//    sonst greift `isImage()` nicht.
//
//  Fleet-Hub-Spiegel: users/{dspUid}/fleet_events — für Fahrer nicht
//    schreibbar. Den Spiegel schreibt die Cloud Function
//    `onVehicleCheckCreated` (firebase/functions/src/vehicleChecks/).

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/material.dart';

import 'image_compression.dart';
import 'incident_reports.dart' show plateKeyOf, transporterIdOf;

export 'incident_reports.dart' show plateKeyOf, transporterIdOf;

/// Marker-Feld, an dem ein Vehicle-Check von einer echten Unfallmeldung
/// im selben Collection-Pfad unterschieden wird.
const String kVehicleCheckKind = 'vehicle_check';

/// Subcollection unter `users/{dspUid}/drivers/{TID}` (siehe Kopfkommentar).
const String kVehicleCheckCollection = 'incident_reports';

/// Wire-Wert des Fleet-Hub-Events, das die Cloud Function spiegelt.
const String kVehicleCheckEventType = 'vehicle_check';

/// Storage-Unterordner innerhalb des Check-Ordners.
const String kVehicleCheckStorageFolder = 'vehicle_check';

/// Kosten-Guard der KI-Analyse — mehr Bilder schickt die Function nicht.
const int kVehicleCheckMaxAiPhotos = 9;

// ═════════════════════════════════════════════════════════════════════════
//  Enums
// ═════════════════════════════════════════════════════════════════════════

/// Anlass des Checks.
enum VehicleCheckType { shiftStart, shiftEnd, handover }

extension VehicleCheckTypeX on VehicleCheckType {
  String get wire => switch (this) {
    VehicleCheckType.shiftStart => 'shift_start',
    VehicleCheckType.shiftEnd => 'shift_end',
    VehicleCheckType.handover => 'handover',
  };

  IconData get icon => switch (this) {
    VehicleCheckType.shiftStart => Icons.wb_sunny_outlined,
    VehicleCheckType.shiftEnd => Icons.nightlight_outlined,
    VehicleCheckType.handover => Icons.swap_horiz,
  };

  String label(bool de) => switch (this) {
    VehicleCheckType.shiftStart => de ? 'Schichtbeginn' : 'Shift start',
    VehicleCheckType.shiftEnd => de ? 'Schichtende' : 'Shift end',
    VehicleCheckType.handover => de ? 'Übergabe' : 'Handover',
  };

  static VehicleCheckType fromWire(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'shift_end' => VehicleCheckType.shiftEnd,
        'handover' => VehicleCheckType.handover,
        _ => VehicleCheckType.shiftStart,
      };
}

/// Die geführten Foto-Schritte — Reihenfolge = Reihenfolge im Wizard.
enum VehicleCheckStep {
  front,
  rear,
  left,
  right,
  cornerFrontLeft,
  cornerRearRight,
  odometer,
  interior,
}

extension VehicleCheckStepX on VehicleCheckStep {
  String get wire => switch (this) {
    VehicleCheckStep.front => 'front',
    VehicleCheckStep.rear => 'rear',
    VehicleCheckStep.left => 'left',
    VehicleCheckStep.right => 'right',
    VehicleCheckStep.cornerFrontLeft => 'corner_front_left',
    VehicleCheckStep.cornerRearRight => 'corner_rear_right',
    VehicleCheckStep.odometer => 'odometer',
    VehicleCheckStep.interior => 'interior',
  };

  IconData get icon => switch (this) {
    VehicleCheckStep.front => Icons.directions_car_filled_outlined,
    VehicleCheckStep.rear => Icons.rv_hookup_outlined,
    VehicleCheckStep.left => Icons.airport_shuttle_outlined,
    VehicleCheckStep.right => Icons.local_shipping_outlined,
    VehicleCheckStep.cornerFrontLeft => Icons.crop_free,
    VehicleCheckStep.cornerRearRight => Icons.crop_din,
    VehicleCheckStep.odometer => Icons.speed_outlined,
    VehicleCheckStep.interior => Icons.event_seat_outlined,
  };

  String label(bool de) => switch (this) {
    VehicleCheckStep.front => de ? 'Front' : 'Front',
    VehicleCheckStep.rear => de ? 'Heck' : 'Rear',
    VehicleCheckStep.left => de ? 'Fahrerseite' : 'Driver side',
    VehicleCheckStep.right => de ? 'Beifahrerseite' : 'Passenger side',
    VehicleCheckStep.cornerFrontLeft =>
      de ? 'Ecke vorne links' : 'Front-left corner',
    VehicleCheckStep.cornerRearRight =>
      de ? 'Ecke hinten rechts' : 'Rear-right corner',
    VehicleCheckStep.odometer => de ? 'Kilometerstand' : 'Odometer',
    VehicleCheckStep.interior => de ? 'Innenraum' : 'Interior',
  };

  /// Kurze Anleitung, die im Wizard über der Silhouette steht.
  String hint(bool de) => switch (this) {
    VehicleCheckStep.front => de
        ? 'Stell dich ca. 3 Schritte vor das Fahrzeug. Stoßstange, '
              'Scheinwerfer und Kennzeichen müssen komplett drauf sein.'
        : 'Stand about 3 steps in front of the van. Bumper, headlights '
              'and the number plate must be fully visible.',
    VehicleCheckStep.rear => de
        ? 'Ca. 3 Schritte hinter das Fahrzeug. Hecktüren, Rückleuchten '
              'und Kennzeichen im Bild.'
        : 'About 3 steps behind the van. Rear doors, tail lights and the '
              'number plate in frame.',
    VehicleCheckStep.left => de
        ? 'Ganze Fahrerseite von vorne bis hinten — Schiebetür, '
              'Schweller und beide Räder sichtbar.'
        : 'The whole driver side front to back — sliding door, sill and '
              'both wheels visible.',
    VehicleCheckStep.right => de
        ? 'Ganze Beifahrerseite von vorne bis hinten — Schiebetür, '
              'Schweller und beide Räder sichtbar.'
        : 'The whole passenger side front to back — sliding door, sill '
              'and both wheels visible.',
    VehicleCheckStep.cornerFrontLeft => de
        ? 'Schräg von vorne links: Front und Fahrerseite gleichzeitig — '
              'so sieht man Beulen an der Kante.'
        : 'Diagonally from the front left: front and driver side at once '
              '— that is where edge dents show up.',
    VehicleCheckStep.cornerRearRight => de
        ? 'Schräg von hinten rechts: Heck und Beifahrerseite '
              'gleichzeitig.'
        : 'Diagonally from the rear right: rear and passenger side at '
              'once.',
    VehicleCheckStep.odometer => de
        ? 'Zündung an, Foto vom Tacho. Der Kilometerstand muss klar '
              'lesbar sein.'
        : 'Ignition on, photo of the dashboard. The odometer reading '
              'must be clearly legible.',
    VehicleCheckStep.interior => de
        ? 'Laderaum bzw. Fahrerkabine — Sauberkeit und lose Teile '
              'sichtbar.'
        : 'Cargo area or cab — cleanliness and loose items visible.',
  };

  static VehicleCheckStep? fromWire(String raw) {
    final key = raw.trim().toLowerCase();
    for (final step in VehicleCheckStep.values) {
      if (step.wire == key) return step;
    }
    return null;
  }
}

/// Ergebnis eines Sichtprüfungs-Punkts.
///
/// Bewusst nur zwei Zustände: „nicht bewertet" wird nicht gespeichert,
/// sondern ist schlicht das Fehlen des Schlüssels in der Map.
enum VehicleCheckItemState { ok, issue }

extension VehicleCheckItemStateX on VehicleCheckItemState {
  String get wire => switch (this) {
    VehicleCheckItemState.ok => 'ok',
    VehicleCheckItemState.issue => 'issue',
  };

  bool get isIssue => this == VehicleCheckItemState.issue;

  String label(bool de) => switch (this) {
    VehicleCheckItemState.ok => de ? 'In Ordnung' : 'OK',
    VehicleCheckItemState.issue => de ? 'Auffällig' : 'Issue',
  };

  static VehicleCheckItemState? fromWire(String raw) =>
      switch (raw.trim().toLowerCase()) {
        'ok' => VehicleCheckItemState.ok,
        'issue' => VehicleCheckItemState.issue,
        _ => null,
      };
}

/// Die 12 Punkte der geführten Sichtprüfung (Kundenvorgabe).
///
/// Reihenfolge = Reihenfolge in der Fahrer-UI. Zu jedem Punkt liegt unter
/// `assets/vehicle_check/` ein Beispielbild, das typisch zeigt, wie der
/// Mangel aussieht — es ist ausdrücklich eine SICHTprüfung, nichts wird
/// gemessen.
enum VehicleCheckInspectionItem {
  mirrors,
  seatBelt,
  wires,
  tread,
  pressure,
  sharpEdges,
  headlights,
  holes,
  sensors,
  tireCracks,
  lamps,
  cameras,
}

extension VehicleCheckInspectionItemX on VehicleCheckInspectionItem {
  String get wire => switch (this) {
    VehicleCheckInspectionItem.mirrors => 'mirrors',
    VehicleCheckInspectionItem.seatBelt => 'seat_belt',
    VehicleCheckInspectionItem.wires => 'wires',
    VehicleCheckInspectionItem.tread => 'tread',
    VehicleCheckInspectionItem.pressure => 'pressure',
    VehicleCheckInspectionItem.sharpEdges => 'sharp_edges',
    VehicleCheckInspectionItem.headlights => 'headlights',
    VehicleCheckInspectionItem.holes => 'holes',
    VehicleCheckInspectionItem.sensors => 'sensors',
    VehicleCheckInspectionItem.tireCracks => 'tire_cracks',
    VehicleCheckInspectionItem.lamps => 'lamps',
    VehicleCheckInspectionItem.cameras => 'cameras',
  };

  /// Beispielbild. Dateinamen sind fix — sie liegen bereits im Repo und
  /// sind über `- assets/vehicle_check/` in der `pubspec.yaml` registriert.
  String get asset => switch (this) {
    VehicleCheckInspectionItem.mirrors => 'assets/vehicle_check/mirrors.jpg',
    VehicleCheckInspectionItem.seatBelt => 'assets/vehicle_check/seatbelt.jpg',
    VehicleCheckInspectionItem.wires => 'assets/vehicle_check/wires.jpg',
    VehicleCheckInspectionItem.tread => 'assets/vehicle_check/tread.jpg',
    VehicleCheckInspectionItem.pressure => 'assets/vehicle_check/pressure.jpg',
    VehicleCheckInspectionItem.sharpEdges =>
      'assets/vehicle_check/sharp_edges.jpg',
    VehicleCheckInspectionItem.headlights =>
      'assets/vehicle_check/headlights.jpg',
    VehicleCheckInspectionItem.holes => 'assets/vehicle_check/holes.jpg',
    VehicleCheckInspectionItem.sensors => 'assets/vehicle_check/sensors.jpg',
    VehicleCheckInspectionItem.tireCracks =>
      'assets/vehicle_check/tire_cracks.jpg',
    VehicleCheckInspectionItem.lamps => 'assets/vehicle_check/lamps.jpg',
    VehicleCheckInspectionItem.cameras => 'assets/vehicle_check/cameras.jpg',
  };

  // Nur `Icons.*` — Material Symbols laden im Web-Build nicht zuverlässig.
  IconData get icon => switch (this) {
    VehicleCheckInspectionItem.mirrors => Icons.flip,
    VehicleCheckInspectionItem.seatBelt =>
      Icons.airline_seat_recline_normal_outlined,
    VehicleCheckInspectionItem.wires => Icons.cable,
    VehicleCheckInspectionItem.tread => Icons.tire_repair,
    VehicleCheckInspectionItem.pressure => Icons.compress,
    VehicleCheckInspectionItem.sharpEdges => Icons.dangerous_outlined,
    VehicleCheckInspectionItem.headlights => Icons.lightbulb_outline,
    VehicleCheckInspectionItem.holes => Icons.donut_large,
    VehicleCheckInspectionItem.sensors => Icons.sensors,
    VehicleCheckInspectionItem.tireCracks => Icons.timeline,
    VehicleCheckInspectionItem.lamps => Icons.wb_incandescent_outlined,
    VehicleCheckInspectionItem.cameras => Icons.videocam_outlined,
  };

  String label(bool de) => switch (this) {
    VehicleCheckInspectionItem.mirrors =>
      de ? 'Spiegel & Spiegelgehäuse' : 'Mirrors & mirror frames',
    VehicleCheckInspectionItem.seatBelt =>
      de ? 'Sicherheitsgurte & Gurtschlösser' : 'Seat belts & buckles',
    VehicleCheckInspectionItem.wires =>
      de ? 'Lose Kabel & Kunststoffteile' : 'Hanging wires & plastic parts',
    VehicleCheckInspectionItem.tread =>
      de ? 'Reifenprofil (mind. 1,6 mm)' : 'Tire tread (at least 1.6 mm)',
    VehicleCheckInspectionItem.pressure =>
      de ? 'Reifendruck zu niedrig' : 'Low tire pressure',
    VehicleCheckInspectionItem.sharpEdges =>
      de ? 'Scharfe Kanten' : 'Sharp edges',
    VehicleCheckInspectionItem.headlights =>
      de ? 'Scheinwerfer & Leuchtmittel' : 'Headlights & bulbs',
    VehicleCheckInspectionItem.holes =>
      de ? 'Löcher in der Karosserie' : 'Holes in the bodywork',
    VehicleCheckInspectionItem.sensors =>
      de ? 'Sensoren & Sensoröffnungen' : 'Sensors & sensor holes',
    VehicleCheckInspectionItem.tireCracks =>
      de ? 'Risse im Reifen' : 'Cracked tires',
    VehicleCheckInspectionItem.lamps =>
      de ? 'Fehlende Leuchten' : 'Missing lamps',
    VehicleCheckInspectionItem.cameras => de ? 'Kameras' : 'Cameras',
  };

  /// Worauf der Fahrer schaut — bewusst als Sichtprüfung formuliert,
  /// nirgends wird gemessen.
  String hint(bool de) => switch (this) {
    VehicleCheckInspectionItem.mirrors => de
        ? 'Beide Außenspiegel ansehen: Ist das Glas gesprungen oder das '
              'Gehäuse gebrochen bzw. lose?'
        : 'Look at both wing mirrors: is the glass cracked or the frame '
              'broken or loose?',
    VehicleCheckInspectionItem.seatBelt => de
        ? 'Gurt ganz herausziehen — eingerissen oder ausgefranst? Rastet '
              'das Gurtschloss sauber ein und löst es wieder?'
        : 'Pull the belt all the way out — ripped or frayed? Does the '
              'buckle click in cleanly and release again?',
    VehicleCheckInspectionItem.wires => de
        ? 'Hängen irgendwo Kabel oder Verkleidungsteile lose herunter — '
              'innen im Laderaum wie außen unter dem Fahrzeug?'
        : 'Are any wires or trim parts hanging loose — inside the cargo '
              'area as well as underneath the van?',
    VehicleCheckInspectionItem.tread => de
        ? 'Nur hinsehen, nicht messen: Steht das Profil fast auf Höhe der '
              'Verschleißmarker in den Rillen, ist es zu wenig.'
        : 'Just look, do not measure: if the tread is almost level with '
              'the wear markers in the grooves, it is too low.',
    VehicleCheckInspectionItem.pressure => de
        ? 'Sichtprüfung ohne Messgerät: Sieht ein Reifen platt aus oder '
              'wird er unten sichtbar breit eingedrückt?'
        : 'Visual check, no gauge: does a tire look flat or visibly '
              'squashed and bulging where it meets the road?',
    VehicleCheckInspectionItem.sharpEdges => de
        ? 'Gebrochenes Plastik oder aufgerissenes Blech, an dem man sich '
              'schneiden kann — besonders an Stoßfängern und Radläufen.'
        : 'Broken plastic or torn metal you could cut yourself on — '
              'especially on bumpers and wheel arches.',
    VehicleCheckInspectionItem.headlights => de
        ? 'Streuscheiben gebrochen oder blind? Licht kurz einschalten und '
              'prüfen, ob wirklich alle Lampen brennen.'
        : 'Lenses cracked or clouded? Switch the lights on briefly and '
              'check that every lamp really works.',
    VehicleCheckInspectionItem.holes => de
        ? 'Durchgehende Löcher oder Risse in Blech und Stoßfänger, die '
              'von einem Schaden stammen.'
        : 'Holes or tears going right through panels or bumpers, caused '
              'by damage.',
    VehicleCheckInspectionItem.sensors => de
        ? 'Sitzen alle Park- und Abstandssensoren fest in ihren '
              'Öffnungen? Leere, lose oder gebrochene Löcher zählen als '
              'Mangel.'
        : 'Are all parking and distance sensors sitting firmly in their '
              'holes? Empty, loose or broken holes count as a defect.',
    VehicleCheckInspectionItem.tireCracks => de
        ? 'Reifenflanke ansehen: tiefe Risse oder Furchen (deutlich '
              'sichtbar, ab etwa 2,5 cm) sind ein Mangel.'
        : 'Look at the sidewall: deep cracks or grooves (clearly '
              'visible, from about 2.5 cm) are a defect.',
    VehicleCheckInspectionItem.lamps => de
        ? 'Fehlt eine Leuchte ganz — z. B. eine Seitenleuchte, ein '
              'Nebelscheinwerfer oder eine Abdeckung?'
        : 'Is a lamp missing entirely — e.g. a side lamp, a fog lamp or '
              'a lamp cover?',
    VehicleCheckInspectionItem.cameras => de
        ? 'Sind alle Kameras da, sauber und unbeschädigt — Rückfahr- und '
              'Seitenkameras?'
        : 'Are all cameras present, clean and undamaged — reversing and '
              'side cameras?',
  };

  static VehicleCheckInspectionItem? fromWire(String raw) {
    final key = raw.trim().toLowerCase();
    for (final item in VehicleCheckInspectionItem.values) {
      if (item.wire == key) return item;
    }
    return null;
  }
}

/// Firestore-Form der Sichtprüfung: `{ '<wire>': 'ok' | 'issue' }`.
Map<String, String> encodeVehicleCheckInspection(
  Map<VehicleCheckInspectionItem, VehicleCheckItemState> value,
) => <String, String>{
  for (final entry in value.entries) entry.key.wire: entry.value.wire,
};

/// Liest die Sichtprüfung robust zurück — alte Checks ohne `inspection`
/// (und unbekannte Schlüssel/Werte) ergeben schlicht eine leere Map.
Map<VehicleCheckInspectionItem, VehicleCheckItemState>
decodeVehicleCheckInspection(Object? raw) {
  if (raw is! Map) {
    return const <VehicleCheckInspectionItem, VehicleCheckItemState>{};
  }
  final out = <VehicleCheckInspectionItem, VehicleCheckItemState>{};
  raw.forEach((key, value) {
    final item = VehicleCheckInspectionItemX.fromWire('$key');
    final state = VehicleCheckItemStateX.fromWire('$value');
    if (item != null && state != null) out[item] = state;
  });
  return out;
}

/// Schadenskategorie.
enum VehicleDamageCategory { scratch, dent, glass, tire, interior, other }

extension VehicleDamageCategoryX on VehicleDamageCategory {
  String get wire => switch (this) {
    VehicleDamageCategory.scratch => 'scratch',
    VehicleDamageCategory.dent => 'dent',
    VehicleDamageCategory.glass => 'glass',
    VehicleDamageCategory.tire => 'tire',
    VehicleDamageCategory.interior => 'interior',
    VehicleDamageCategory.other => 'other',
  };

  IconData get icon => switch (this) {
    VehicleDamageCategory.scratch => Icons.show_chart,
    VehicleDamageCategory.dent => Icons.blur_circular_outlined,
    VehicleDamageCategory.glass => Icons.broken_image_outlined,
    VehicleDamageCategory.tire => Icons.tire_repair,
    VehicleDamageCategory.interior => Icons.event_seat_outlined,
    VehicleDamageCategory.other => Icons.help_outline,
  };

  String label(bool de) => switch (this) {
    VehicleDamageCategory.scratch => de ? 'Kratzer' : 'Scratch',
    VehicleDamageCategory.dent => de ? 'Delle' : 'Dent',
    VehicleDamageCategory.glass => de ? 'Glas' : 'Glass',
    VehicleDamageCategory.tire => de ? 'Reifen' : 'Tire',
    VehicleDamageCategory.interior => de ? 'Innenraum' : 'Interior',
    VehicleDamageCategory.other => de ? 'Sonstiges' : 'Other',
  };

  static VehicleDamageCategory fromWire(String raw) {
    final key = raw.trim().toLowerCase();
    for (final c in VehicleDamageCategory.values) {
      if (c.wire == key) return c;
    }
    return VehicleDamageCategory.other;
  }
}

/// Betroffene Stelle am Fahrzeug.
enum VehicleDamageLocation { front, rear, left, right, roof, interior }

extension VehicleDamageLocationX on VehicleDamageLocation {
  String get wire => switch (this) {
    VehicleDamageLocation.front => 'front',
    VehicleDamageLocation.rear => 'rear',
    VehicleDamageLocation.left => 'left',
    VehicleDamageLocation.right => 'right',
    VehicleDamageLocation.roof => 'roof',
    VehicleDamageLocation.interior => 'interior',
  };

  String label(bool de) => switch (this) {
    VehicleDamageLocation.front => de ? 'Front' : 'Front',
    VehicleDamageLocation.rear => de ? 'Heck' : 'Rear',
    VehicleDamageLocation.left => de ? 'Links' : 'Left',
    VehicleDamageLocation.right => de ? 'Rechts' : 'Right',
    VehicleDamageLocation.roof => de ? 'Dach' : 'Roof',
    VehicleDamageLocation.interior => de ? 'Innen' : 'Interior',
  };

  static VehicleDamageLocation fromWire(String raw) {
    final key = raw.trim().toLowerCase();
    for (final l in VehicleDamageLocation.values) {
      if (l.wire == key) return l;
    }
    return VehicleDamageLocation.front;
  }
}

/// Dekodiert eine Firestore-Liste über [parse] und wirft `null`-Ergebnisse
/// weg — spart in jedem Modell dieselbe `whereType`-Kette.
List<T> _decodeList<T>(Object? raw, T? Function(Object?) parse) {
  if (raw is! List) return <T>[];
  final out = <T>[];
  for (final entry in raw) {
    final parsed = parse(entry);
    if (parsed != null) out.add(parsed);
  }
  return out;
}

// ═════════════════════════════════════════════════════════════════════════
//  Modelle
// ═════════════════════════════════════════════════════════════════════════

/// Ein hochgeladenes Foto eines Schritts.
class VehicleCheckPhoto {
  const VehicleCheckPhoto({
    required this.step,
    required this.url,
    required this.path,
  });

  final VehicleCheckStep step;
  final String url;
  final String path;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'step': step.wire,
    'url': url,
    'path': path,
  };

  static VehicleCheckPhoto? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final step = VehicleCheckStepX.fromWire('${raw['step'] ?? ''}');
    if (step == null) return null;
    return VehicleCheckPhoto(
      step: step,
      url: '${raw['url'] ?? ''}',
      path: '${raw['path'] ?? ''}',
    );
  }
}

/// Ein vom Fahrer gemeldeter Schaden.
class VehicleCheckDamage {
  const VehicleCheckDamage({
    required this.category,
    required this.location,
    this.photoStep,
    this.comment = '',
    this.source = 'driver',
  });

  final VehicleDamageCategory category;
  final VehicleDamageLocation location;

  /// Optional: das Foto, auf dem der Schaden zu sehen ist.
  final VehicleCheckStep? photoStep;
  final String comment;

  /// `driver` = manuell gemeldet, `ai` = aus einem KI-Vorschlag übernommen.
  final String source;

  /// Vergleichsschlüssel für „NEU vs. bestehend" — bewusst OHNE Kommentar,
  /// damit derselbe Schaden bei abweichender Formulierung nicht erneut als
  /// neu gilt.
  String get signature => '${category.wire}|${location.wire}';

  Map<String, dynamic> toMap() => <String, dynamic>{
    'category': category.wire,
    'location': location.wire,
    'photoStep': photoStep?.wire ?? '',
    'comment': comment,
    'source': source,
  };

  static VehicleCheckDamage? fromMap(Object? raw) {
    if (raw is! Map) return null;
    return VehicleCheckDamage(
      category: VehicleDamageCategoryX.fromWire('${raw['category'] ?? ''}'),
      location: VehicleDamageLocationX.fromWire('${raw['location'] ?? ''}'),
      photoStep: VehicleCheckStepX.fromWire('${raw['photoStep'] ?? ''}'),
      comment: '${raw['comment'] ?? ''}'.trim(),
      source: '${raw['source'] ?? 'driver'}',
    );
  }
}

/// Ein KI-Schadenskandidat (Stufe 2) — nie automatisch übernommen.
class VehicleCheckAiCandidate {
  const VehicleCheckAiCandidate({
    required this.step,
    required this.category,
    required this.description,
    required this.confidence,
  });

  final VehicleCheckStep? step;
  final VehicleDamageCategory category;
  final String description;
  final double confidence;

  static VehicleCheckAiCandidate? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final conf = raw['confidence'];
    return VehicleCheckAiCandidate(
      step: VehicleCheckStepX.fromWire('${raw['step'] ?? ''}'),
      category: VehicleDamageCategoryX.fromWire('${raw['category'] ?? ''}'),
      description: '${raw['description'] ?? ''}'.trim(),
      confidence: conf is num ? conf.toDouble() : 0,
    );
  }
}

/// Qualitätsurteil der KI je Foto.
class VehicleCheckAiPhotoQuality {
  const VehicleCheckAiPhotoQuality({
    required this.step,
    required this.usable,
    required this.matchesStep,
    required this.note,
  });

  final VehicleCheckStep? step;
  final bool usable;
  final bool matchesStep;
  final String note;

  static VehicleCheckAiPhotoQuality? fromMap(Object? raw) {
    if (raw is! Map) return null;
    return VehicleCheckAiPhotoQuality(
      step: VehicleCheckStepX.fromWire('${raw['step'] ?? ''}'),
      usable: raw['usable'] == true,
      matchesStep: raw['matchesStep'] == true,
      note: '${raw['note'] ?? ''}'.trim(),
    );
  }
}

/// Ein kompletter Check.
class VehicleCheck {
  const VehicleCheck({
    required this.checkId,
    required this.path,
    required this.dspUid,
    required this.plate,
    required this.plateKey,
    required this.type,
    required this.odometerKm,
    required this.photos,
    required this.damages,
    required this.inspection,
    required this.driverTransporterId,
    required this.driverName,
    required this.checkedAt,
    required this.aiStatus,
    required this.aiError,
    required this.aiOdometerKm,
    required this.aiPlateMatch,
    required this.aiPlateText,
    required this.aiCandidates,
    required this.aiQuality,
    required this.aiSummary,
  });

  final String checkId;
  final String path;
  final String dspUid;
  final String plate;
  final String plateKey;
  final VehicleCheckType type;
  final int odometerKm;
  final List<VehicleCheckPhoto> photos;
  final List<VehicleCheckDamage> damages;

  /// Ergebnis der 12-Punkte-Sichtprüfung. Leer bei Checks, die vor der
  /// Einführung der Sichtprüfung entstanden sind.
  final Map<VehicleCheckInspectionItem, VehicleCheckItemState> inspection;

  final String driverTransporterId;
  final String driverName;
  final DateTime? checkedAt;

  /// `pending` | `running` | `done` | `error` | `skipped`
  final String aiStatus;
  final String aiError;
  final int? aiOdometerKm;
  final bool? aiPlateMatch;
  final String aiPlateText;
  final List<VehicleCheckAiCandidate> aiCandidates;
  final List<VehicleCheckAiPhotoQuality> aiQuality;
  final String aiSummary;

  /// Als auffällig markierte Sichtprüfungs-Punkte, in Enum-Reihenfolge.
  List<VehicleCheckInspectionItem> get inspectionIssues =>
      <VehicleCheckInspectionItem>[
        for (final item in VehicleCheckInspectionItem.values)
          if (inspection[item] == VehicleCheckItemState.issue) item,
      ];

  VehicleCheckPhoto? photoFor(VehicleCheckStep step) {
    for (final p in photos) {
      if (p.step == step) return p;
    }
    return null;
  }

  static VehicleCheck fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final ai = data['aiFindings'];
    final aiMap = ai is Map ? ai : const <dynamic, dynamic>{};
    final odo = data['odometerKm'];
    final aiOdo = aiMap['odometerKm'];
    final plateMatch = aiMap['plateMatch'];
    return VehicleCheck(
      checkId: '${data['checkId'] ?? doc.id}',
      path: doc.reference.path,
      dspUid: '${data['dspUid'] ?? ''}',
      plate: '${data['plate'] ?? ''}',
      plateKey: '${data['plateKey'] ?? ''}',
      type: VehicleCheckTypeX.fromWire('${data['checkType'] ?? ''}'),
      odometerKm: odo is num ? odo.toInt() : 0,
      photos: _decodeList(data['photos'], VehicleCheckPhoto.fromMap),
      damages: _decodeList(data['damages'], VehicleCheckDamage.fromMap),
      inspection: decodeVehicleCheckInspection(data['inspection']),
      driverTransporterId: '${data['driverTransporterId'] ?? ''}',
      driverName: '${data['driverName'] ?? ''}',
      checkedAt: (data['checkedAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate(),
      aiStatus: '${data['aiStatus'] ?? 'pending'}',
      aiError: '${data['aiError'] ?? ''}',
      aiOdometerKm: aiOdo is num ? aiOdo.toInt() : null,
      aiPlateMatch: plateMatch is bool ? plateMatch : null,
      aiPlateText: '${aiMap['plateText'] ?? ''}',
      aiSummary: '${aiMap['summary'] ?? ''}',
      aiCandidates: _decodeList(
        aiMap['damageCandidates'],
        VehicleCheckAiCandidate.fromMap,
      ),
      aiQuality: _decodeList(
        aiMap['photoQuality'],
        VehicleCheckAiPhotoQuality.fromMap,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
//  Firestore-Referenzen
// ═════════════════════════════════════════════════════════════════════════

/// `users/{dspUid}/drivers/{TID}/incident_reports` (siehe Kopfkommentar).
CollectionReference<Map<String, dynamic>> vehicleCheckCollection({
  required String dspUid,
  required String transporterId,
}) => FirebaseFirestore.instance
    .collection('users')
    .doc(dspUid)
    .collection('drivers')
    .doc(transporterIdOf(transporterId))
    .collection(kVehicleCheckCollection);

/// `users/{dspUid}/fleet_events` — der Admin-Spiegel (Cloud Function).
CollectionReference<Map<String, dynamic>> fleetEventsCollection(String dspUid) =>
    FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('fleet_events');

// ═════════════════════════════════════════════════════════════════════════
//  Foto-Aufbereitung + Upload
// ═════════════════════════════════════════════════════════════════════════

/// Skaliert auf max. 1600 px längste Kante und kodiert als JPEG q75 —
/// dasselbe Rezept wie Recruiting- und Incident-Fotos (siehe
/// `image_compression.dart`), damit ein 12-MP-Handyfoto nicht 6 MB durch
/// das Mobilfunknetz schiebt. Ist das Format nicht dekodierbar, geht das
/// Original raus — ein Check ohne Foto wäre schlimmer als ein großes Foto.
Future<Uint8List> compressVehicleCheckPhoto(Uint8List raw) async =>
    await compressImageToJpeg(raw) ?? raw;

/// Storage-Pfad eines Schritt-Fotos.
String vehicleCheckPhotoPath({
  required String dspUid,
  required String transporterId,
  required String checkId,
  required VehicleCheckStep step,
}) =>
    'incident_reports/$dspUid/${transporterIdOf(transporterId)}/$checkId/'
    '$kVehicleCheckStorageFolder/${step.wire}.jpg';

/// Lädt ein bereits komprimiertes JPEG hoch und liefert die Download-URL.
Future<VehicleCheckPhoto> uploadVehicleCheckPhoto({
  required String dspUid,
  required String transporterId,
  required String checkId,
  required VehicleCheckStep step,
  required Uint8List jpegBytes,
}) async {
  final path = vehicleCheckPhotoPath(
    dspUid: dspUid,
    transporterId: transporterId,
    checkId: checkId,
    step: step,
  );
  final ref = fb.FirebaseStorage.instance.ref().child(path);
  // contentType MUSS gesetzt sein — die Storage-Rule `isImage()` lehnt
  // Uploads ohne Bild-MIME-Type ab (Flutter Web schickt sonst
  // application/octet-stream).
  await ref.putData(
    jpegBytes,
    fb.SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'public,max-age=31536000',
    ),
  );
  final url = await ref.getDownloadURL();
  return VehicleCheckPhoto(step: step, url: url, path: path);
}

// ═════════════════════════════════════════════════════════════════════════
//  Speichern
// ═════════════════════════════════════════════════════════════════════════

/// Schreibt das Check-Dokument und aktualisiert die Kurzfassung auf dem
/// Fahrer-Dokument (`lastVehicleCheck`).
///
/// Der Fahrer darf sein eigenes Driver-Doc updaten (firestore.rules:1121) —
/// darüber findet die Fahrzeug-Detailseite den letzten Check auch dann,
/// wenn die Spiegel-Function noch nicht deployt ist.
Future<void> saveVehicleCheck({
  required String dspUid,
  required String transporterId,
  required String checkId,
  required String driverName,
  required String plate,
  required VehicleCheckType type,
  required int odometerKm,
  required List<VehicleCheckPhoto> photos,
  required List<VehicleCheckDamage> damages,
  Map<VehicleCheckInspectionItem, VehicleCheckItemState> inspection =
      const <VehicleCheckInspectionItem, VehicleCheckItemState>{},
}) async {
  final tid = transporterIdOf(transporterId);
  final db = FirebaseFirestore.instance;
  final driverRef = db
      .collection('users')
      .doc(dspUid)
      .collection('drivers')
      .doc(tid);
  final checkRef = driverRef.collection(kVehicleCheckCollection).doc(checkId);
  final now = DateTime.now();
  final key = plateKeyOf(plate);
  final inspectionIssues = inspection.values.where((s) => s.isIssue).length;

  final payload = <String, dynamic>{
    // Rules-Pflichtfeld: `request.resource.data.driverTransporterId == driverId`
    'driverTransporterId': tid,
    'kind': kVehicleCheckKind,
    'checkId': checkId,
    'dspUid': dspUid,
    'plate': plate.trim(),
    'plateRaw': plate.trim(),
    'plateKey': key,
    'checkType': type.wire,
    'odometerKm': odometerKm,
    'photos': <Map<String, dynamic>>[for (final p in photos) p.toMap()],
    'damages': <Map<String, dynamic>>[for (final d in damages) d.toMap()],
    // Sichtprüfung: flache Map `{ '<wire>': 'ok' | 'issue' }` — ein
    // zusätzliches Feld auf demselben Dokument, das die bestehenden
    // Rules bereits abdecken (kein Pflicht-Feldschema).
    'inspection': encodeVehicleCheckInspection(inspection),
    'inspectionIssueCount': inspectionIssues,
    'photoCount': photos.length,
    'damageCount': damages.length,
    'driverName': driverName.trim(),
    'driverUid': FirebaseAuth.instance.currentUser?.uid ?? '',
    'checkedAt': Timestamp.fromDate(now),
    'createdAt': FieldValue.serverTimestamp(),
    'aiStatus': 'pending',
  };

  final batch = db.batch();
  batch.set(checkRef, payload);
  batch.set(driverRef, <String, dynamic>{
    'lastVehicleCheck': <String, dynamic>{
      'checkId': checkId,
      'path': checkRef.path,
      'plate': plate.trim(),
      'plateKey': key,
      'checkType': type.wire,
      'odometerKm': odometerKm,
      'photoCount': photos.length,
      'damageCount': damages.length,
      'inspectionIssueCount': inspectionIssues,
      'at': Timestamp.fromDate(now),
      'driverName': driverName.trim(),
      'driverTransporterId': tid,
    },
  }, SetOptions(merge: true));
  await batch.commit();
}

// ═════════════════════════════════════════════════════════════════════════
//  Auswertung
// ═════════════════════════════════════════════════════════════════════════

/// Schäden, die im Vorgänger-Check noch nicht standen → „NEU"-Badge.
///
/// Vergleicht bewusst nur Kategorie + Stelle ([VehicleCheckDamage.signature]),
/// nicht den Freitext: sonst wäre jeder Schaden bei jeder Neuformulierung
/// wieder „neu".
Set<String> newDamageSignatures({
  required VehicleCheck current,
  required VehicleCheck? previous,
}) {
  if (previous == null) return const <String>{};
  final known = <String>{for (final d in previous.damages) d.signature};
  return <String>{
    for (final d in current.damages)
      if (!known.contains(d.signature)) d.signature,
  };
}

/// Untertitel-Zeile für Fleet-Event und Admin-Kacheln.
String vehicleCheckSubtitle(VehicleCheck check, bool de) {
  final km = _formatKm(check.odometerKm);
  final parts = <String>[
    de
        ? '${check.photos.length} Fotos'
        : '${check.photos.length} photos',
    de
        ? '${check.damages.length} Schäden'
        : '${check.damages.length} damages',
    'KM $km',
    if (check.driverName.isNotEmpty) check.driverName,
  ];
  return parts.join(' · ');
}

String _formatKm(int km) {
  final digits = km.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${km < 0 ? '-' : ''}$buffer';
}

/// Öffentlich, damit Fahrer- und Admin-UI dieselbe Tausenderpunkt-Form
/// verwenden.
String formatVehicleCheckKm(int km) => _formatKm(km);
