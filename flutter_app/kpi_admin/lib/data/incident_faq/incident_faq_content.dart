// lib/data/incident_faq/incident_faq_content.dart
//
// Telefon-Leitfaden für die Disposition: „Was frage ich den Fahrer bei
// einem Unfall?"
//
// Zweck: Der Dispatcher hat den Fahrer am Ohr, der Fahrer steht neben
// einem beschädigten Transporter. Die Punkte sind deshalb kurz,
// sprechbar und in der Reihenfolge sortiert, in der man sie am Telefon
// abarbeitet — Sicherheit zuerst, dann Polizei-Pflicht, dann die
// Datenabfrage.
//
// Der Fragenkatalog ist bewusst **deckungsgleich mit dem
// Erfassungsformular** (`lib/Screens/admin_incident_form_page.dart`):
// jeder Punkt in `incidentFaqAskSection*` trägt in `field` das Feld, in
// das die Antwort später wandert. Wird das Formular um ein Pflichtfeld
// erweitert, gehört hier eine Frage dazu — sonst fehlt die Angabe
// später im Bericht.
//
// Reiner Inhalt, keine UI: gerendert wird das generisch von
// `lib/widgets/incident_faq_sheet.dart`. Texte können hier gepflegt
// werden, ohne die Oberfläche anzufassen.

import 'package:flutter/material.dart';

/// Farbliche Einordnung eines Abschnitts. Die Oberfläche übersetzt das
/// in konkrete Farben — hier steht nur die Bedeutung.
enum IncidentFaqTone {
  /// Sachlicher Abschnitt (Datenabfrage, Fotos, Nacharbeit).
  neutral,

  /// Gefahr für Leib und Leben / harte Verbote.
  danger,

  /// Pflicht mit rechtlicher Folge (Polizei rufen).
  warning,

  /// Abschluss, „danach passiert das".
  success,
}

/// Ein einzelner Punkt eines Abschnitts.
@immutable
class IncidentFaqPoint {
  const IncidentFaqPoint(this.text, {this.detail, this.field});

  /// Die eigentliche Frage bzw. Anweisung — ein Satz, sprechbar.
  final String text;

  /// Optionale Präzisierung in kleinerer Schrift (Beispiele, Grenzwerte).
  final String? detail;

  /// Optional: Feld im Erfassungsformular, in das die Antwort gehört.
  /// Wird als kleiner Chip hinter dem Punkt gezeigt.
  final String? field;
}

/// Ein Abschnitt des Leitfadens.
@immutable
class IncidentFaqSection {
  const IncidentFaqSection({
    required this.id,
    required this.icon,
    required this.title,
    required this.points,
    this.tone = IncidentFaqTone.neutral,
    this.intro,
    this.footnote,
    this.numbered = false,
  });

  /// Stabile, sprachunabhängige ID (Reihenfolge-Abgleich DE/EN).
  final String id;

  final IconData icon;
  final String title;

  /// Ein Satz unter der Überschrift, der den Abschnitt einordnet.
  final String? intro;

  final List<IncidentFaqPoint> points;

  /// Schlusshinweis am Ende des Abschnitts.
  final String? footnote;

  final IncidentFaqTone tone;

  /// Punkte durchnummerieren statt Bullets — nur für den Fragenkatalog,
  /// wo die Reihenfolge Teil der Anweisung ist.
  final bool numbered;
}

/// Überschrift des Leitfadens.
const String incidentFaqTitleDe = 'Unfall am Telefon: Was frage ich?';
const String incidentFaqTitleEn = 'Accident on the phone: what to ask';

const String incidentFaqSubtitleDe =
    'Leitfaden für die Disposition — von oben nach unten abarbeiten.';
const String incidentFaqSubtitleEn =
    'Guide for dispatch — work through it top to bottom.';

/// Schlusshinweis unter allen Abschnitten.
const String incidentFaqFooterDe =
    'Im Zweifel Rücksprache mit der Leitung. Lieber einmal zu viel '
    'gefragt als eine Angabe, die später im Bericht fehlt.';
const String incidentFaqFooterEn =
    'When in doubt, check with your manager. Better to ask one question '
    'too many than to miss a detail in the report.';

// ═══════════════════════════════════════════════════════════════════════
// Deutsch
// ═══════════════════════════════════════════════════════════════════════

const List<IncidentFaqSection> incidentFaqSectionsDe = [
  // ──────────────────────────────────────────────────────────────── 1
  IncidentFaqSection(
    id: 'safety',
    icon: Icons.health_and_safety_outlined,
    tone: IncidentFaqTone.danger,
    title: 'Zuerst: Sicherheit',
    intro:
        'Bevor du irgendetwas aufnimmst — ist der Fahrer in Sicherheit? '
        'Erst danach Daten abfragen.',
    points: [
      IncidentFaqPoint(
        'Ist jemand verletzt — Fahrer, Gegner, Beifahrer, Passanten?',
        detail:
            'Bei Verletzten zuerst 112 rufen (lassen), dann erst weiter '
            'melden. Fahrer bleibt am Telefon, bis Hilfe unterwegs ist.',
      ),
      IncidentFaqPoint(
        'Sind alle in Sicherheit und weg von der Fahrbahn?',
      ),
      IncidentFaqPoint(
        'Warnblinker an, Warnweste anziehen, Warndreieck aufstellen.',
        detail:
            'Innerorts ca. 50 m, Landstraße ca. 100 m, Autobahn ca. 200 m '
            'hinter der Unfallstelle. Warnweste vor dem Aussteigen.',
      ),
      IncidentFaqPoint(
        'Fahrzeug nur bewegen, wenn es den Verkehr gefährdet.',
        detail:
            'Sonst Endstellung stehen lassen, bis die Fotos gemacht sind — '
            'die Position ist der wichtigste Beweis.',
      ),
      IncidentFaqPoint(
        'Steht der Fahrer unter Schock? Ruhig sprechen, kurze Fragen, '
        'keine Vorwürfe.',
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────── 2
  IncidentFaqSection(
    id: 'police',
    icon: Icons.local_police_outlined,
    tone: IncidentFaqTone.warning,
    title: 'Wann die Polizei kommen MUSS',
    intro:
        'In diesen Fällen wird die Polizei gerufen — auch wenn der '
        'Unfallgegner das nicht will.',
    points: [
      IncidentFaqPoint(
        'Personenschaden — jemand ist verletzt, egal wie leicht.',
      ),
      IncidentFaqPoint(
        'Unfallflucht oder unbekannter Gegner.',
        detail:
            'Verursacher weggefahren, Schaden am geparkten Transporter, '
            'kein Zettel, kein Zeuge.',
      ),
      IncidentFaqPoint(
        'Streit über die Schuldfrage oder der Gegner rückt seine Daten '
        'nicht heraus.',
      ),
      IncidentFaqPoint(
        'Schaden an fremdem Eigentum, dessen Eigentümer nicht da ist.',
        detail:
            'Geparktes Auto, Zaun, Poller, Garagentor, Briefkasten. Der '
            'Fahrer muss warten — ein Zettel hinter dem Scheibenwischer '
            'ist keine Entschuldigung und gilt als Unfallflucht.',
      ),
      IncidentFaqPoint(
        'Verdacht auf Alkohol oder Drogen bei einem Beteiligten.',
      ),
      IncidentFaqPoint(
        'Wildunfall.',
        detail:
            'Polizei oder Jagdpächter verständigen. Ohne '
            'Wildunfallbescheinigung zahlt die Kaskoversicherung in der '
            'Regel nicht. Totes Tier nicht mitnehmen.',
      ),
      IncidentFaqPoint(
        'Der Fahrer fühlt sich bedroht oder die Lage eskaliert.',
      ),
    ],
    footnote:
        'Polizei war vor Ort? Immer Tagebuchnummer und Dienststelle '
        'abfragen — die Versicherung fragt danach.',
  ),

  // ──────────────────────────────────────────────────────────────── 3
  IncidentFaqSection(
    id: 'ask',
    icon: Icons.checklist_rounded,
    title: 'Was du den Fahrer abfragst',
    intro:
        'In dieser Reihenfolge durchgehen — dann passt später alles '
        'lückenlos ins Formular.',
    numbered: true,
    points: [
      IncidentFaqPoint(
        'Wo genau ist es passiert?',
        detail:
            'Straße, Hausnummer, PLZ, Ortsteil. Auf Landstraße oder '
            'Autobahn zusätzlich Fahrtrichtung und Kilometerangabe.',
        field: 'Ort',
      ),
      IncidentFaqPoint(
        'Wann ist es passiert?',
        detail: 'Datum und Uhrzeit des Unfalls — nicht die Uhrzeit des Anrufs.',
        field: 'Datum · Uhrzeit',
      ),
      IncidentFaqPoint(
        'Wer fährt? Name und Transporter-ID.',
        field: 'Fahrer',
      ),
      IncidentFaqPoint(
        'Welches Fahrzeug? Kennzeichen des eigenen Transporters.',
        field: 'Fahrzeug',
      ),
      IncidentFaqPoint(
        'Auf welcher Route bzw. in welcher Wave ist er unterwegs?',
        detail: 'Wichtig für die Umplanung — läuft die Tour weiter?',
        field: 'Interne Notizen',
      ),
      IncidentFaqPoint(
        'Was genau ist passiert? Hergang in einem Satz.',
        detail:
            'Mit den Worten des Fahrers aufschreiben, nichts hineindeuten. '
            'Beispiel: „Beim Rückwärtsfahren gegen einen Poller gestoßen."',
        field: 'Hergang',
      ),
      IncidentFaqPoint(
        'Wer ist beteiligt? Je Unfallgegner die vollständigen Daten.',
        detail:
            'Kennzeichen, Name, Anschrift, Telefonnummer, Versicherung und '
            'Versicherungsschein-Nummer. Bei mehreren Beteiligten alle '
            'einzeln erfassen.',
        field: 'Gegenpartei',
      ),
      IncidentFaqPoint(
        'Gibt es Zeugen?',
        detail:
            'Name und Telefonnummer. Unabhängige Zeugen entscheiden später '
            'die Schuldfrage — jetzt fragen, danach sind sie weg.',
        field: 'Interne Notizen',
      ),
      IncidentFaqPoint(
        'Ist die Polizei vor Ort?',
        detail: 'Wenn ja: Tagebuchnummer und zuständige Dienststelle notieren.',
        field: 'Interne Notizen',
      ),
      IncidentFaqPoint(
        'Welcher Schaden ist entstanden?',
        detail:
            'Eigenes Fahrzeug und fremdes Fahrzeug getrennt beschreiben — '
            'Bauteil und Art des Schadens, z. B. „Stoßstange hinten links '
            'eingedrückt".',
        field: 'Schaden',
      ),
      IncidentFaqPoint(
        'Ist das Fahrzeug noch fahrbereit?',
        detail:
            'Ja/Nein und warum nicht: Reifen, Beleuchtung, Flüssigkeit '
            'unter dem Fahrzeug, Tür schließt nicht, Sicht eingeschränkt.',
        field: 'Grounding',
      ),
      IncidentFaqPoint(
        'Ist die Ladung betroffen?',
        detail: 'Pakete beschädigt, verloren oder muss umgeladen werden?',
        field: 'Interne Notizen',
      ),
      IncidentFaqPoint(
        'Kilometerstand ablesen lassen.',
        field: 'Interne Notizen',
      ),
      IncidentFaqPoint(
        'Wie geht es weiter? Abschleppdienst nötig, Rückholung, '
        'Ersatzfahrzeug?',
        field: 'Interne Notizen',
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────── 4
  IncidentFaqSection(
    id: 'photos',
    icon: Icons.photo_camera_outlined,
    title: 'Fotos, die der Fahrer machen muss',
    intro:
        'Noch am Telefon ansagen — eine halbe Stunde später ist die '
        'Unfallstelle geräumt.',
    points: [
      IncidentFaqPoint(
        'Gesamtaufnahme der Unfallstelle aus mehreren Richtungen.',
        detail:
            'Mit Abstand, sodass beide Fahrzeuge und der Straßenverlauf '
            'zusammen zu sehen sind. Mindestens drei Blickwinkel.',
      ),
      IncidentFaqPoint(
        'Beide Fahrzeuge komplett — in Endstellung, bevor etwas bewegt wird.',
      ),
      IncidentFaqPoint(
        'Nahaufnahmen aller Schäden, einzeln.',
        detail: 'Am eigenen Transporter und am fremden Fahrzeug.',
      ),
      IncidentFaqPoint(
        'Kennzeichen beider Fahrzeuge, gut lesbar.',
      ),
      IncidentFaqPoint(
        'Straßenverlauf, Verkehrsschilder, Ampeln, Fahrbahnmarkierungen.',
        detail: 'Vorfahrt, Halteverbot und Spuren klären später die Schuld.',
      ),
      IncidentFaqPoint(
        'Bremsspuren, Splitter, Fahrbahnzustand — falls vorhanden.',
        detail: 'Nässe, Laub, Schnee, Baustelle, schlechte Sicht.',
      ),
      IncidentFaqPoint(
        'Papiere des Gegners, wenn er einverstanden ist.',
        detail: 'Führerschein, Fahrzeugschein, Versicherungskarte.',
      ),
    ],
    footnote:
        'Fotos direkt danach in CoDriver an den Vorfall hängen — nicht in '
        'der Galerie liegen lassen.',
  ),

  // ──────────────────────────────────────────────────────────────── 5
  IncidentFaqSection(
    id: 'never',
    icon: Icons.block_rounded,
    tone: IncidentFaqTone.danger,
    title: 'Was der Fahrer NICHT tun darf',
    intro: 'Das gehört in jedes Telefonat — auch bei kleinen Schäden.',
    points: [
      IncidentFaqPoint(
        'Kein Schuldanerkenntnis — weder mündlich noch schriftlich.',
        detail:
            'Kein „Tut mir leid, ich war schuld." Die Schuldfrage klärt die '
            'Versicherung, nicht der Fahrer am Straßenrand.',
      ),
      IncidentFaqPoint(
        'Keine Zusage zur Kostenübernahme, kein Bargeld, keine Reparatur '
        '„unter der Hand".',
      ),
      IncidentFaqPoint(
        'Nichts unterschreiben außer dem Europäischen Unfallbericht.',
        detail:
            'Und dort nur reine Tatsachen ankreuzen: Ort, Zeit, Fahrzeuge, '
            'Schäden, Skizze. Kein Feld zur Schuldfrage ausfüllen.',
      ),
      IncidentFaqPoint(
        'Unfallstelle nicht ohne Freigabe verlassen.',
        detail:
            'Auch nicht bei einem Kratzer am geparkten Auto. Warten oder '
            'Polizei rufen — sonst ist es Unfallflucht.',
      ),
      IncidentFaqPoint(
        'Keine Diskussion mit dem Gegner, keine Bewertung des Hergangs.',
      ),
      IncidentFaqPoint(
        'Keine Auskunft an Anwälte, Werkstätten oder Abschleppdienste des '
        'Gegners.',
        detail: 'Alles läuft über die Disposition.',
      ),
      IncidentFaqPoint(
        'Nichts in sozialen Netzwerken posten, keine Fotos weitergeben.',
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────── 6
  IncidentFaqSection(
    id: 'after',
    icon: Icons.task_alt_rounded,
    tone: IncidentFaqTone.success,
    title: 'Danach — was du erledigst',
    intro: 'Direkt nach dem Anruf, solange die Angaben frisch sind.',
    points: [
      IncidentFaqPoint(
        'Vorfall in CoDriver anlegen: Vorfälle › Unfälle & Schäden › '
        'Vorfall erfassen.',
      ),
      IncidentFaqPoint(
        'Alle Fotos an den Vorfall hängen.',
      ),
      IncidentFaqPoint(
        'Nicht fahrbereit? Fahrzeug im Fleet Hub auf „Grounded" setzen und '
        'den Grund eintragen.',
      ),
      IncidentFaqPoint(
        'Ersatzfahrzeug klären: Pool-Fahrzeug, Mietwagen oder Route '
        'umplanen.',
      ),
      IncidentFaqPoint(
        'Bericht an die Versicherung senden und den Bearbeitungs-Status im '
        'Vorfall mitführen.',
      ),
      IncidentFaqPoint(
        'Ist der eigene Fahrer verletzt? Zusätzlich einen Arbeitsunfall '
        'anlegen und die BG-Meldung prüfen.',
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════════
// English
// ═══════════════════════════════════════════════════════════════════════

const List<IncidentFaqSection> incidentFaqSectionsEn = [
  // ──────────────────────────────────────────────────────────────── 1
  IncidentFaqSection(
    id: 'safety',
    icon: Icons.health_and_safety_outlined,
    tone: IncidentFaqTone.danger,
    title: 'First: safety',
    intro:
        'Before you record anything — is the driver safe? Only then start '
        'collecting details.',
    points: [
      IncidentFaqPoint(
        'Is anyone injured — driver, third party, passengers, bystanders?',
        detail:
            'If anyone is hurt, call 112 first, report afterwards. Keep the '
            'driver on the line until help is on the way.',
      ),
      IncidentFaqPoint(
        'Is everyone safe and away from the traffic lane?',
      ),
      IncidentFaqPoint(
        'Hazard lights on, high-visibility vest on, warning triangle out.',
        detail:
            'Roughly 50 m in town, 100 m on rural roads, 200 m on the '
            'motorway behind the scene. Vest on before leaving the vehicle.',
      ),
      IncidentFaqPoint(
        'Only move the vehicle if it is a danger to traffic.',
        detail:
            'Otherwise leave it where it stopped until the photos are '
            'taken — the final position is the strongest evidence.',
      ),
      IncidentFaqPoint(
        'Is the driver in shock? Speak calmly, ask short questions, no '
        'blame.',
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────── 2
  IncidentFaqSection(
    id: 'police',
    icon: Icons.local_police_outlined,
    tone: IncidentFaqTone.warning,
    title: 'When the police MUST be called',
    intro:
        'In these cases the police are called — even if the other party '
        'objects.',
    points: [
      IncidentFaqPoint(
        'Personal injury — someone is hurt, however minor.',
      ),
      IncidentFaqPoint(
        'Hit and run, or the other party is unknown.',
        detail:
            'The other driver left, damage to the parked van, no note, no '
            'witness.',
      ),
      IncidentFaqPoint(
        'Dispute over who is at fault, or the other party refuses to give '
        'their details.',
      ),
      IncidentFaqPoint(
        'Damage to third-party property whose owner is not present.',
        detail:
            'Parked car, fence, bollard, garage door, mailbox. The driver '
            'must wait — a note under the wiper is not enough and counts '
            'as hit and run.',
      ),
      IncidentFaqPoint(
        'Suspicion of alcohol or drugs on any party involved.',
      ),
      IncidentFaqPoint(
        'Collision with wildlife.',
        detail:
            'Call the police or the local game keeper. Without the official '
            'wildlife-accident certificate the insurer usually refuses to '
            'pay. Do not take the animal along.',
      ),
      IncidentFaqPoint(
        'The driver feels threatened or the situation escalates.',
      ),
    ],
    footnote:
        'Police attended? Always ask for the case/reference number and the '
        'station — the insurer will ask for it.',
  ),

  // ──────────────────────────────────────────────────────────────── 3
  IncidentFaqSection(
    id: 'ask',
    icon: Icons.checklist_rounded,
    title: 'What to ask the driver',
    intro:
        'Work through it in this order — then everything fits the form '
        'later without gaps.',
    numbered: true,
    points: [
      IncidentFaqPoint(
        'Where exactly did it happen?',
        detail:
            'Street, house number, postcode, district. On rural roads or '
            'the motorway also the direction and the kilometre marker.',
        field: 'Location',
      ),
      IncidentFaqPoint(
        'When did it happen?',
        detail: 'Date and time of the accident — not the time of the call.',
        field: 'Date · Time',
      ),
      IncidentFaqPoint(
        'Who is driving? Name and transporter ID.',
        field: 'Driver',
      ),
      IncidentFaqPoint(
        'Which vehicle? Plate of our own van.',
        field: 'Vehicle',
      ),
      IncidentFaqPoint(
        'Which route or wave is he on?',
        detail: 'Needed for re-planning — does the route continue?',
        field: 'Internal notes',
      ),
      IncidentFaqPoint(
        'What exactly happened? Course of events in one sentence.',
        detail:
            'Write it down in the driver\'s own words, add no '
            'interpretation. Example: "Hit a bollard while reversing."',
        field: 'Course of events',
      ),
      IncidentFaqPoint(
        'Who else is involved? Full details for every third party.',
        detail:
            'Plate, name, address, phone number, insurer and policy number. '
            'With several parties, record each one separately.',
        field: 'Third party',
      ),
      IncidentFaqPoint(
        'Are there witnesses?',
        detail:
            'Name and phone number. Independent witnesses decide the '
            'liability question later — ask now, in ten minutes they are '
            'gone.',
        field: 'Internal notes',
      ),
      IncidentFaqPoint(
        'Are the police on site?',
        detail: 'If yes: note the case/reference number and the station.',
        field: 'Internal notes',
      ),
      IncidentFaqPoint(
        'What damage was caused?',
        detail:
            'Describe our vehicle and the third-party vehicle separately — '
            'part and type of damage, e.g. "rear left bumper dented".',
        field: 'Damage',
      ),
      IncidentFaqPoint(
        'Is the vehicle still roadworthy?',
        detail:
            'Yes/no and why not: tyres, lights, fluid under the vehicle, '
            'door will not close, restricted view.',
        field: 'Grounding',
      ),
      IncidentFaqPoint(
        'Is the load affected?',
        detail: 'Parcels damaged, lost, or do they need to be transferred?',
        field: 'Internal notes',
      ),
      IncidentFaqPoint(
        'Have him read out the odometer reading.',
        field: 'Internal notes',
      ),
      IncidentFaqPoint(
        'What happens next? Tow truck needed, recovery, replacement '
        'vehicle?',
        field: 'Internal notes',
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────── 4
  IncidentFaqSection(
    id: 'photos',
    icon: Icons.photo_camera_outlined,
    title: 'Photos the driver has to take',
    intro:
        'Tell him while still on the phone — half an hour later the scene '
        'is cleared.',
    points: [
      IncidentFaqPoint(
        'Wide shot of the scene from several directions.',
        detail:
            'From a distance, so both vehicles and the road layout are '
            'visible together. At least three angles.',
      ),
      IncidentFaqPoint(
        'Both vehicles in full — where they stopped, before anything is '
        'moved.',
      ),
      IncidentFaqPoint(
        'Close-ups of every single piece of damage.',
        detail: 'On our own van and on the third-party vehicle.',
      ),
      IncidentFaqPoint(
        'Plates of both vehicles, clearly readable.',
      ),
      IncidentFaqPoint(
        'Road layout, traffic signs, traffic lights, lane markings.',
        detail:
            'Right of way, no-stopping zones and lanes settle the liability '
            'question later.',
      ),
      IncidentFaqPoint(
        'Skid marks, debris, road condition — if present.',
        detail: 'Wet road, leaves, snow, roadworks, poor visibility.',
      ),
      IncidentFaqPoint(
        'The other party\'s documents, if he agrees.',
        detail: 'Driving licence, registration, insurance card.',
      ),
    ],
    footnote:
        'Attach the photos to the incident in CoDriver right away — do not '
        'leave them in the phone gallery.',
  ),

  // ──────────────────────────────────────────────────────────────── 5
  IncidentFaqSection(
    id: 'never',
    icon: Icons.block_rounded,
    tone: IncidentFaqTone.danger,
    title: 'What the driver must NOT do',
    intro: 'Say this in every call — even for small damage.',
    points: [
      IncidentFaqPoint(
        'Never admit fault — neither verbally nor in writing.',
        detail:
            'No "sorry, that was my fault". Liability is settled by the '
            'insurer, not by the driver at the roadside.',
      ),
      IncidentFaqPoint(
        'No promise to cover costs, no cash, no repair deal on the side.',
      ),
      IncidentFaqPoint(
        'Sign nothing except the European Accident Statement.',
        detail:
            'And there only tick plain facts: place, time, vehicles, '
            'damage, sketch. Leave any liability field blank.',
      ),
      IncidentFaqPoint(
        'Do not leave the scene without clearance.',
        detail:
            'Not even for a scratch on a parked car. Wait or call the '
            'police — otherwise it is a hit and run.',
      ),
      IncidentFaqPoint(
        'No argument with the other party, no assessment of what happened.',
      ),
      IncidentFaqPoint(
        'No information to the other party\'s lawyers, garages or towing '
        'services.',
        detail: 'Everything goes through dispatch.',
      ),
      IncidentFaqPoint(
        'Nothing on social media, no photos passed on to anyone.',
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────────── 6
  IncidentFaqSection(
    id: 'after',
    icon: Icons.task_alt_rounded,
    tone: IncidentFaqTone.success,
    title: 'Afterwards — what you do',
    intro: 'Right after the call, while the details are still fresh.',
    points: [
      IncidentFaqPoint(
        'Create the incident in CoDriver: Incidents › Accidents & damage › '
        'Log incident.',
      ),
      IncidentFaqPoint(
        'Attach all photos to the incident.',
      ),
      IncidentFaqPoint(
        'Not roadworthy? Set the vehicle to "Grounded" in the Fleet Hub and '
        'enter the reason.',
      ),
      IncidentFaqPoint(
        'Sort out a replacement: pool vehicle, rental, or re-plan the route.',
      ),
      IncidentFaqPoint(
        'Send the report to the insurer and keep the handling status on the '
        'incident up to date.',
      ),
      IncidentFaqPoint(
        'Is our own driver injured? Also log a work accident and check '
        'whether the BG report is required.',
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════════
// Zugriff
// ═══════════════════════════════════════════════════════════════════════

/// Abschnitte in der Sprache des Admins.
List<IncidentFaqSection> incidentFaqSections({required bool de}) =>
    de ? incidentFaqSectionsDe : incidentFaqSectionsEn;

String incidentFaqTitle({required bool de}) =>
    de ? incidentFaqTitleDe : incidentFaqTitleEn;

String incidentFaqSubtitle({required bool de}) =>
    de ? incidentFaqSubtitleDe : incidentFaqSubtitleEn;

String incidentFaqFooter({required bool de}) =>
    de ? incidentFaqFooterDe : incidentFaqFooterEn;

/// Der komplette Leitfaden als reiner Text — für „Als Checkliste
/// kopieren". Ziel sind Slack, Notizen oder ein Ausdruck neben dem
/// Telefon, deshalb bewusst ohne Markdown-Auszeichnung: nur
/// Überschriften, Kästchen und Einrückung.
String incidentFaqChecklistText({required bool de}) {
  final buffer = StringBuffer()
    ..writeln(incidentFaqTitle(de: de).toUpperCase())
    ..writeln(incidentFaqSubtitle(de: de))
    ..writeln();

  for (final section in incidentFaqSections(de: de)) {
    buffer.writeln('— ${section.title.toUpperCase()} —');
    final intro = section.intro;
    if (intro != null) buffer.writeln(intro);

    for (var i = 0; i < section.points.length; i++) {
      final point = section.points[i];
      final marker = section.numbered ? '${i + 1}.' : '[ ]';
      buffer.writeln('$marker ${point.text}');
      final detail = point.detail;
      if (detail != null) buffer.writeln('    $detail');
      final field = point.field;
      if (field != null) {
        buffer.writeln('    ${de ? 'Feld' : 'Field'}: $field');
      }
    }

    final footnote = section.footnote;
    if (footnote != null) buffer.writeln('! $footnote');
    buffer.writeln();
  }

  buffer.writeln(incidentFaqFooter(de: de));
  return buffer.toString();
}
