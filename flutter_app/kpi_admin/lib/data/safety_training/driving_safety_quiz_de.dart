// lib/data/safety_training/driving_safety_quiz_de.dart
//
// Fragen des DSP-Fahrsicherheitstrainings — Modul-Quiz und Abschlusstest.
// Deutsche Master-Fassung; die Übersetzungen liegen in
// driving_safety_quiz_<lang>.dart, die Sprachauflösung und der Testaufbau
// in driving_safety_data.dart.
//
// Anspruch der Fragen: Szenarien aus dem Zustellalltag, Rechenaufgaben,
// Reihenfolge- und Rechtsfolgefragen. Mehrere Optionen klingen bewusst
// plausibel — es kommt jeweils auf ein Detail an. Die `explanation`
// erklärt immer beides: warum die richtige Antwort richtig ist und warum
// die naheliegende falsche Antwort falsch ist.

import 'package:flutter/foundation.dart';

@immutable
class DrivingQuestion {
  /// Modul, zu dem die Frage gehört ('m1' … 'm10').
  final String moduleId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  /// Pflichtfragen sind in JEDEM Abschlusstest enthalten — sie decken
  /// die Kernanliegen ab (Handyverbot, Ein-/Aussteigen).
  final bool mandatoryInExam;

  /// Nur Modul-Quiz, nicht Teil des Abschlusstest-Pools.
  final bool moduleOnly;

  const DrivingQuestion({
    required this.moduleId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.mandatoryInExam = false,
    this.moduleOnly = false,
  });
}

/// Alle Fragen. Das Modul-Quiz filtert nach [moduleId], der Abschlusstest
/// zieht aus allen Fragen mit `moduleOnly == false`.
const List<DrivingQuestion> drivingQuestionsDe = [
  // ══════════════════════════════════ M1 — Sicherheitskultur
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Du liegst 20 Stopps hinter dem Plan. Welche Reaktion '
        'entspricht der Sicherheitskultur im Betrieb?',
    options: [
      'Zwischen den Stopps zügiger fahren, an den Stopps selbst aber '
          'sorgfältig bleiben',
      'Den Rückstand melden und die Tour im gewohnten sicheren Tempo '
          'weiterfahren',
      'Die Kontrollzeiten beim Rangieren kürzen, das Fahrverhalten aber '
          'unverändert lassen',
    ],
    correctIndex: 1,
    explanation: 'Zeitdruck ist ein Planungsproblem und wird gemeldet, '
        'nicht am Steuer ausgeglichen. Die beiden anderen Antworten '
        'klingen nach Kompromiss, verlegen das Risiko aber nur: Höheres '
        'Tempo zwischen den Stopps verlängert genau den Anhalteweg, und '
        'gekürzte Rangierkontrollen treffen die Tätigkeit, bei der 70 % '
        'aller Schäden entstehen.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Dein Disponent weist dich an, mit einem defekten '
        'Bremslicht loszufahren. Wer trägt die Verantwortung, wenn es '
        'deswegen zu einem Auffahrunfall kommt?',
    options: [
      'Der Disponent, weil er die Anweisung gegeben hat',
      'Der Betrieb, weil er das Fahrzeug bereitstellt',
      'Niemand — ein einzelnes Bremslicht ist kein sicherheitsrelevanter '
          'Mangel',
      'Du als Fahrzeugführer',
    ],
    correctIndex: 3,
    explanation: 'Als Fahrzeugführer verantwortest du den '
        'verkehrssicheren Zustand des Fahrzeugs, das du bewegst — eine '
        'mündliche Anweisung hebt das nicht auf. Dass der Betrieb das '
        'Fahrzeug stellt, klingt naheliegend, entlastet dich aber nicht: '
        'Bußgeld und Punkte treffen dich persönlich. Richtig ist, den '
        'Mangel zu melden und ein anderes Fahrzeug zu verlangen.',
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Beim Rangieren fehlten nur wenige Zentimeter zu einem '
        'Poller — passiert ist nichts. Was ist richtig?',
    options: [
      'Als Beinahe-Unfall melden',
      'Nichts tun, es ist ja kein Schaden entstanden und niemand wurde '
          'gefährdet',
      'Nur melden, wenn ein Kollege oder eine Kamera es mitbekommen hat',
    ],
    correctIndex: 0,
    explanation: 'Ein Beinahe-Unfall zeigt eine Gefahrenstelle, bevor sie '
        'jemanden trifft — gemeldet, ist sie beim nächsten Kollegen '
        'entschärft. Der Gedanke „kein Schaden, kein Thema" ist der '
        'häufigste Grund, warum dieselbe Stelle Wochen später doch zum '
        'Schaden führt.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm1',
    question: 'Bei welcher Tätigkeit entstehen rund 70 % aller '
        'Transporterschäden?',
    options: [
      'Auf Autobahn und Landstraße bei hoher Geschwindigkeit',
      'Beim Abbiegen an Kreuzungen im Stadtverkehr',
      'Beim Rangieren und Rückwärtsfahren',
    ],
    correctIndex: 2,
    explanation: 'Die große Mehrheit der Schäden entsteht im Schritttempo '
        'beim Rangieren. Hohe Geschwindigkeit verursacht die schwersten '
        'Unfälle, aber nicht die meisten Schäden — genau diese '
        'Verwechslung führt dazu, dass beim Rangieren zu wenig aufgepasst '
        'wird.',
  ),

  // ══════════════════════════════════ M2 — Fahrzeugcheck & Ladung
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Ladung muss nach den anerkannten Regeln der Technik gegen '
        '0,8 g nach vorn gesichert werden. Welche Rückhaltekraft '
        'entspricht das bei einem 20-kg-Paket ungefähr?',
    options: [
      'rund 2 kg',
      'rund 8 kg',
      'rund 16 kg',
      'rund 200 kg',
    ],
    correctIndex: 2,
    explanation: '0,8 × 20 kg ergibt rund 16 kg Rückhaltekraft. „Rund 2 '
        'kg" unterschätzt die Kraft dramatisch und ist der Grund, warum '
        'Pakete für harmlos gehalten werden; „200 kg" verwechselt die '
        'Sicherungsvorgabe mit der Anprallwucht bei einem echten '
        'Aufprall, die tatsächlich noch weit darüber liegt.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Wie belädst du den Laderaum richtig?',
    options: [
      'Schwer nach unten und nach vorn an die Trennwand, Gewicht '
          'gleichmäßig verteilt',
      'Schwer nach oben, damit die schweren Pakete beim Greifen nicht '
          'unter den leichten liegen',
      'Schwer nach hinten an die Tür, damit die schweren Sendungen '
          'zuerst herauskommen',
    ],
    correctIndex: 0,
    explanation: 'Schwer + tief + vorn hält den Schwerpunkt niedrig und '
        'die Masse dort, wo die Trennwand sie auffangen kann. Die beiden '
        'anderen Varianten sind nach Arbeitsablauf gedacht, nicht nach '
        'Physik: Gewicht oben erhöht die Kippneigung, Gewicht hinten '
        'entlastet die Vorderachse und verschlechtert die Lenkung.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Nach zwei Dritteln der Tour ist der Laderaum halb leer. '
        'Was gilt jetzt für die Ladungssicherung?',
    options: [
      'Sie ist weniger wichtig, weil deutlich weniger Gewicht an Bord ist',
      'Sie muss neu hergestellt werden — die Restpakete haben jetzt mehr '
          'Weg, um Tempo aufzunehmen',
      'Sie gilt unverändert weiter, zu tun ist nichts',
    ],
    correctIndex: 1,
    explanation: 'Je leerer der Laderaum, desto größer die Strecke, auf '
        'der ein Paket beschleunigen kann, bevor es aufschlägt. „Weniger '
        'Gewicht, weniger Gefahr" klingt logisch, ist aber falsch: '
        'Entscheidend ist nicht die Gesamtmasse, sondern das einzelne '
        'ungesicherte Paket.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Was verlangt die DGUV Vorschrift 70 (Fahrzeuge) von dir '
        'vor Beginn der Arbeitsschicht?',
    options: [
      'Eine technische Prüfung mit Hebebühne und Bremsenprüfstand',
      'Eine Prüfung des Fahrzeugs auf offensichtliche Mängel',
      'Eine Prüfung nur bei Fahrzeugen, die du zum ersten Mal fährst',
    ],
    correctIndex: 1,
    explanation: 'Verlangt wird der augenfällige Mängelcheck vor der '
        'Schicht — genau das, was der Rundgang leistet. Die technische '
        'Prüfung ist Sache der Werkstatt und ersetzt deinen Rundgang '
        'nicht; und die Pflicht gilt für jedes Fahrzeug an jedem Tag, '
        'nicht nur für unbekannte.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Welche Profiltiefe schreibt das Gesetz mindestens vor — '
        'und was ist bei nasser Fahrbahn sinnvoll?',
    options: [
      '3 mm gesetzlich; bei Nässe genügen dann 1,6 mm',
      '1,6 mm gesetzlich; das reicht bei Nässe unverändert aus',
      '4 mm gesetzlich, ganzjährig für alle Reifen',
      '1,6 mm gesetzlich; bei Nässe sind mindestens 3 mm sinnvoll',
    ],
    correctIndex: 3,
    explanation: 'Gesetzliches Minimum sind 1,6 mm, praktisch sinnvoll '
        'bei Nässe mindestens 3 mm. Die Antwort „1,6 mm reichen auch bei '
        'Nässe" ist der klassische Irrtum: Das Minimum ist die Grenze zur '
        'Ordnungswidrigkeit, nicht die Grenze zur Sicherheit — bei 1,6 mm '
        'verdrängt der Reifen kaum noch Wasser.',
  ),
  DrivingQuestion(
    moduleId: 'm2',
    question: 'Der nächste Stopp liegt auf dem Beifahrersitz, damit du '
        'ihn schnell greifen kannst. Was ist daran das Hauptproblem?',
    options: [
      'Das Paket wird bei einer Bremsung zum Geschoss und kann unter das '
          'Bremspedal geraten',
      'Es sieht bei einer Verkehrskontrolle unordentlich aus',
      'Es ist zulässig, solange das Paket weniger als 10 kg wiegt',
    ],
    correctIndex: 0,
    explanation: 'Alles im Fahrerhaus bewegt sich bei einer Bremsung mit '
        'deiner Ausgangsgeschwindigkeit weiter — im schlimmsten Fall in '
        'den Fußraum unter das Pedal. Eine Gewichtsgrenze gibt es dafür '
        'nicht: Auch ein leichtes Paket blockiert ein Pedal.',
  ),

  // ══════════════════════════════════ M3 — Defensiv fahren
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Du fährst außerorts 80 km/h auf trockener Straße. Welcher '
        'Abstand zum Vordermann ist mindestens richtig?',
    options: [
      'Etwa 20 Meter — das entspricht drei Fahrzeuglängen',
      'Etwa 45 Meter — rund zwei Sekunden bzw. halber Tachowert',
      'Etwa 10 Meter, solange du aufmerksam bist und die Straße frei ist',
    ],
    correctIndex: 1,
    explanation: 'Zwei Sekunden entsprechen bei 80 km/h rund 45 Metern, '
        'der halbe Tachowert 40 Metern — beides passt zusammen. 20 Meter '
        'wirken auf der Straße nach viel, liegen aber unter dem reinen '
        'Reaktionsweg von 24 Metern: Du wärst aufgefahren, bevor die '
        'Bremse überhaupt greift.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Wie lang ist der Anhalteweg bei 50 km/h nach den '
        'Faustformeln (normale Bremsung)?',
    options: [
      '15 Meter',
      '25 Meter',
      '40 Meter',
      '65 Meter',
    ],
    correctIndex: 2,
    explanation: 'Reaktionsweg (50 ÷ 10) × 3 = 15 m plus Bremsweg '
        '(50 ÷ 10)² = 25 m ergibt 40 m. Wer 25 Meter nennt, hat nur den '
        'Bremsweg gerechnet und den Reaktionsweg vergessen — das ist der '
        'häufigste Rechenfehler und genau der Teil der Strecke, den du '
        'mit voller Geschwindigkeit zurücklegst.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Wie berechnest du den Reaktionsweg nach der Faustformel?',
    options: [
      '(Tempo ÷ 10) × 3',
      '(Tempo ÷ 10) × (Tempo ÷ 10)',
      'Tempo ÷ 2',
    ],
    correctIndex: 0,
    explanation: 'Der Reaktionsweg ist (km/h ÷ 10) × 3. Die zweite Formel '
        'ist der Bremsweg, die dritte der Faustwert für den '
        'Sicherheitsabstand — beide sehen ähnlich aus, beschreiben aber '
        'etwas völlig anderes.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Du verdoppelst dein Tempo von 30 auf 60 km/h. Wie '
        'verändert sich der reine Bremsweg?',
    options: [
      'Er verdoppelt sich',
      'Er vervierfacht sich',
      'Er verdreifacht sich',
      'Er bleibt nahezu gleich, weil die Bremse bei höherem Tempo '
          'stärker greift',
    ],
    correctIndex: 1,
    explanation: 'Der Bremsweg wächst im Quadrat der Geschwindigkeit: aus '
        '9 Metern werden 36 Meter. Die naheliegende Antwort „verdoppelt" '
        'unterschätzt genau das — sie erklärt, warum 20 km/h mehr in der '
        'Wohnstraße als harmlos empfunden werden.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Warum musst du mit voll beladenem Transporter deutlich '
        'langsamer in Kurven fahren als mit einem Pkw?',
    options: [
      'Weil der hohe Schwerpunkt die Kippneigung stark erhöht',
      'Weil die Lenkung bei Beladung ungenauer wird',
      'Weil die Reifen unter Last weicher werden und mehr Grip haben',
    ],
    correctIndex: 0,
    explanation: 'Ein hoch beladener Kastenwagen kippt dort, wo ein Pkw '
        'noch rutscht — und kündigt es kaum an. Die Lenkpräzision '
        'verändert sich zwar auch, ist aber nicht das eigentliche '
        'Risiko: Kippen passiert plötzlich und endet außerhalb der '
        'Fahrbahn.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Du willst an einer Ampel rechts abbiegen, ein Radfahrer '
        'steht rechts neben dir. Die Ampel wird grün. Was tust du '
        'zuerst?',
    options: [
      'Zügig anfahren und abbiegen, bevor der Radfahrer in Fahrt kommt',
      'In den rechten Außenspiegel schauen und dann einlenken',
      'Schulterblick nach rechts und den Radfahrer durchfahren lassen',
    ],
    correctIndex: 2,
    explanation: 'Sobald du anfährst und einlenkst, wandert der Radfahrer '
        'in den toten Winkel — und dein Heck schwenkt zusätzlich in seine '
        'Spur. Der Blick in den Spiegel klingt richtig, reicht aber genau '
        'dann nicht mehr, wenn es darauf ankommt: Der Spiegel zeigt den '
        'Bereich rechts neben dem Fahrerhaus nicht vollständig.',
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Welchen seitlichen Mindestabstand musst du innerorts beim '
        'Überholen eines Radfahrers einhalten?',
    options: [
      '1,0 Meter',
      '1,5 Meter',
      '2,0 Meter',
    ],
    correctIndex: 1,
    explanation: 'Innerorts sind es 1,5 Meter, außerorts 2,0 Meter. Wer '
        '2,0 Meter für den Innerorts-Wert hält, verwechselt beide — und '
        'wer mit 1,0 Meter überholt, unterschreitet den Mindestabstand '
        'und haftet bei einem Sturz des Radfahrers.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm3',
    question: 'Wie weit voraus sollte dein Blick beim Fahren gerichtet '
        'sein?',
    options: [
      'Auf die Stoßstange des Vordermanns, damit du sein Bremsen sofort '
          'siehst',
      'Auf die eigene Motorhaube, weil du damit die Spur am genauesten '
          'hältst',
      '12–15 Sekunden voraus',
    ],
    correctIndex: 2,
    explanation: 'Der weite Blick verschafft dir Zeit: Du siehst Ampeln, '
        'Bremslichter und Fußgänger, bevor du reagieren musst. Der Blick '
        'auf die Stoßstange fühlt sich aufmerksam an, macht dich aber '
        'zum reinen Reagierer — du erfährst erst von der Gefahr, wenn '
        'der Vordermann schon bremst.',
  ),

  // ══════════════════════════════════ M4 — Rückwärts & Rangieren
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Wofür steht GOAL beim Rückwärtsfahren?',
    options: [
      '„Get Out And Look" — anhalten, aussteigen, hinter dem Fahrzeug '
          'nachsehen',
      '„Go Only At Low speed" — ausschließlich im Schritttempo '
          'zurücksetzen',
      '„Guide On A Line" — sich an einer Bodenmarkierung orientieren',
    ],
    correctIndex: 0,
    explanation: 'GOAL heißt aussteigen und nachschauen — es deckt tiefe '
        'Poller, Gefälle und Kinder auf, die du vom Sitz aus nie siehst. '
        'Schritttempo ist zwar ebenfalls Pflicht, ersetzt das Nachschauen '
        'aber nicht: Auch im Schritttempo fährst du in einen Bereich, den '
        'du nicht einsehen kannst.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Dein Fahrzeug hat eine Rückfahrkamera. Was ändert das an '
        'GOAL?',
    options: [
      'GOAL entfällt, weil die Kamera den Bereich hinter dem Fahrzeug '
          'zeigt',
      'Nichts',
      'GOAL ist damit nur noch bei Dunkelheit und schlechter Sicht nötig',
    ],
    correctIndex: 1,
    explanation: 'Die Kamera zeigt nur einen Ausschnitt, verzerrt '
        'Abstände und wird von Regen, Schnee und Schmutz blind — vor '
        'allem sieht sie nicht, was seitlich in deine Bahn läuft. Sie '
        'ergänzt GOAL, sie ersetzt es nie.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Wo steht ein Einweiser richtig?',
    options: [
      'Direkt hinter dem Fahrzeug, weil er von dort den Abstand am '
          'besten beurteilen kann',
      'Vor dem Fahrzeug, um gleichzeitig den Verkehr anzuhalten',
      'Seitlich, sodass du ihn durchgehend im Spiegel siehst',
    ],
    correctIndex: 2,
    explanation: 'Nur wer seitlich und dauerhaft sichtbar steht, kann '
        'sicher einweisen. Die Position direkt hinter dem Fahrzeug wirkt '
        'zwar am nächsten am Geschehen, ist aber genau der Bereich, in '
        'dem der Einweiser selbst überrollt wird, sobald du ihn aus dem '
        'Blick verlierst.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Du siehst deinen Einweiser im Spiegel plötzlich nicht '
        'mehr. Was tust du?',
    options: [
      'Langsamer weiterfahren, bis er wieder auftaucht',
      'Sofort anhalten',
      'Kurz hupen und weiterfahren, damit er sich wieder zeigt',
    ],
    correctIndex: 1,
    explanation: 'Kein Sichtkontakt heißt kein gültiges Zeichen — also '
        'anhalten, nicht nur langsamer werden. „Langsamer weiterfahren" '
        'klingt vorsichtig, bedeutet aber, dass du weiterhin in einen '
        'Bereich fährst, den niemand mehr für dich überwacht.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Was verlangt § 9 Abs. 5 StVO beim Rückwärtsfahren?',
    options: [
      'Warnblinklicht einzuschalten',
      'Höchstens Schrittgeschwindigkeit zu fahren',
      'Eine Gefährdung anderer auszuschließen — erforderlichenfalls mit '
          'Einweiser',
    ],
    correctIndex: 2,
    explanation: 'Die Vorschrift fordert den Ausschluss jeder Gefährdung, '
        'nötigenfalls durch einen Einweiser — der Maßstab ist also das '
        'Ergebnis, nicht eine bestimmte Geschwindigkeit. Schritttempo und '
        'Warnblinker sind gute Praxis, erfüllen die Pflicht allein aber '
        'nicht.',
  ),
  DrivingQuestion(
    moduleId: 'm4',
    question: 'Der letzte Stopp liegt in einem engen Innenhof: vorwärts '
        'kommst du hinein, heraus nur rückwärts an einer Mauer vorbei. '
        'Was ist die sicherste Entscheidung?',
    options: [
      'Auf der Straße halten und die letzten Meter zu Fuß bzw. mit der '
          'Sackkarre gehen',
      'Vorwärts hineinfahren, weil man die Einfahrt dann für den Rückweg '
          'schon kennt',
      'Zügig rückwärts hineinsetzen, solange die Straße noch frei ist',
    ],
    correctIndex: 0,
    explanation: 'Die sicherste Rückwärtsfahrt ist die, die gar nicht '
        'stattfindet. Dass man die Einfahrt „nach dem Hineinfahren '
        'kennt", ist ein Trugschluss: Beim Herausfahren sind die '
        'kritischen Punkte hinter dir, und der wartende Verkehr erzeugt '
        'zusätzlich Druck.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M5 — Wetter & Sicht
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Die Lenkung wird plötzlich leicht, die Reifen schwimmen '
        'auf einem Wasserfilm auf. Was tust du?',
    options: [
      'Kräftig bremsen und gegenlenken',
      'Gas wegnehmen, Lenkung ruhig geradeaus halten, ausrollen lassen',
      'Beschleunigen, um die Wasserstelle schnell zu verlassen',
    ],
    correctIndex: 1,
    explanation: 'Solange der Wasserfilm trägt, wirken Bremse und Lenkung '
        'nicht — sie wirken erst schlagartig, wenn der Reifen wieder '
        'greift, und genau daraus entsteht das Schleudern. Bremsen und '
        'Gegenlenken ist die intuitive, aber falsche Reaktion.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Wovon hängt die Aquaplaning-Gefahr am stärksten ab?',
    options: [
      'Vom Gewicht der Ladung',
      'Vom Alter des Fahrzeugs und der Bremsanlage',
      'Von Profiltiefe, Wasserhöhe und vor allem der Geschwindigkeit',
    ],
    correctIndex: 2,
    explanation: 'Die Gefahr steigt überproportional mit der '
        'Geschwindigkeit und sinkt mit der Profiltiefe — das Profil muss '
        'das Wasser vor dem Reifen wegleiten. Die Ladung spielt eine '
        'Nebenrolle: Mehr Gewicht drückt den Reifen zwar stärker auf die '
        'Straße, ändert aber nichts daran, dass ein flaches Profil bei '
        'Tempo kein Wasser mehr verdrängt.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Bei Nebel siehst du noch etwa 40 Meter weit. Wie schnell '
        'darfst du höchstens fahren?',
    options: [
      'Höchstens 40 km/h',
      'Bis zur zulässigen Höchstgeschwindigkeit, solange das Licht an ist',
      'Höchstens 80 km/h, wenn die Nebelschlussleuchte eingeschaltet ist',
    ],
    correctIndex: 0,
    explanation: 'Faustregel: Sichtweite in Metern ist deine Obergrenze '
        'in km/h — bei 40 Metern Sicht also 40 km/h. Licht und '
        'Nebelschlussleuchte machen dich sichtbarer, verlängern aber '
        'nicht deine Sichtweite und damit auch nicht das erlaubte '
        'Tempo.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Wann schreibt § 2 Abs. 3a StVO wintertaugliche Reifen '
        'vor?',
    options: [
      'Immer im Zeitraum Oktober bis Ostern, unabhängig vom Wetter',
      'Bei Glatteis, Schneeglätte, Schneematsch, Eis- oder Reifglätte',
      'Nur, wenn geschlossene Schneedecke auf der Fahrbahn liegt',
    ],
    correctIndex: 1,
    explanation: 'In Deutschland gilt eine situative Pflicht: Sie hängt '
        'am Straßenzustand, nicht am Kalender. „Oktober bis Ostern" ist '
        'nur eine praktische Merkregel für den Reifenwechsel und keine '
        'Rechtsgrundlage — und Schneematsch reicht bereits, es muss '
        'keine geschlossene Decke liegen.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Es ist eiskalt und du hast Zeitdruck. Du kratzt nur die '
        'Fahrerseite der Frontscheibe frei. Was gilt?',
    options: [
      'Erlaubt, solange du deutlich langsamer fährst',
      'Erlaubt, wenn die Heizung den Rest während der Fahrt freimacht',
      'Nicht erlaubt — alle Scheiben, Spiegel, Leuchten und das '
          'Kennzeichen müssen frei sein',
    ],
    correctIndex: 2,
    explanation: 'Das freigekratzte „Guckloch" ist eine '
        'Ordnungswidrigkeit und bei einem Unfall ein schwerer '
        'Verschuldensvorwurf. Dass die Heizung nachzieht, ist keine '
        'Ausnahme: Maßgeblich ist der Zustand beim Losfahren, nicht drei '
        'Minuten später.',
  ),
  DrivingQuestion(
    moduleId: 'm5',
    question: 'Warum ist ein LEERER Kastenwagen bei Sturm besonders '
        'gefährdet?',
    options: [
      'Weil ihm das Gewicht der Ladung fehlt, das ihn auf der Straße '
          'hält',
      'Weil der Luftwiderstand ohne Ladung größer ist',
      'Weil der Reifendruck im leeren Zustand höher ist',
    ],
    correctIndex: 0,
    explanation: 'Die Angriffsfläche ist leer wie beladen gleich groß, '
        'die Masse aber deutlich kleiner — dieselbe Böe versetzt das '
        'Fahrzeug also stärker. Der Luftwiderstand ändert sich durch die '
        'Ladung im Inneren gar nicht, das ist der Denkfehler.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M6 — Ablenkung & Müdigkeit
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Darfst du während der Fahrt das Handy in die Hand nehmen, '
        'um die Musik zu wechseln?',
    options: [
      'Ja, wenn es nur eine Sekunde dauert und die Straße frei ist',
      'Nur an der roten Ampel',
      'Nein',
    ],
    correctIndex: 2,
    explanation: 'Schon das Aufnehmen oder Halten des Geräts ist der '
        'Verstoß — unabhängig davon, wofür. Die rote Ampel ist keine '
        'Ausnahme, solange der Motor läuft. Musik, Ziel und Lautstärke '
        'werden vor der Fahrt im Stand eingestellt.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Wann darfst du Handy oder Scanner rechtlich in die Hand '
        'nehmen?',
    options: [
      'Nur wenn das Fahrzeug steht UND der Motor ausgeschaltet ist',
      'Sobald das Fahrzeug steht — die Start-Stopp-Automatik reicht dafür '
          'aus',
      'Kurz während der Fahrt, wenn die Strecke gerade und frei ist',
    ],
    correctIndex: 0,
    explanation: 'Die Ausnahme greift nur bei stehendem Fahrzeug mit '
        'ausgeschaltetem Motor. Die Start-Stopp-Automatik zählt '
        'ausdrücklich nicht — genau darauf verlassen sich viele an der '
        'roten Ampel und kassieren dort ihr Bußgeld.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Du fährst 50 km/h und schaust 2 Sekunden auf das Display. '
        'Wie weit fährst du dabei ohne Sicht auf die Straße?',
    options: [
      'rund 8 Meter',
      'rund 28 Meter',
      'rund 14 Meter',
      'rund 50 Meter',
    ],
    correctIndex: 1,
    explanation: '50 km/h sind rund 14 Meter pro Sekunde, in 2 Sekunden '
        'also etwa 28 Meter. Wer „14 Meter" wählt, hat nur eine Sekunde '
        'gerechnet — ein typischer Fehler, der die Blindstrecke '
        'halbiert erscheinen lässt.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Du nickst bei Tempo 80 für 4 Sekunden weg. Welche Strecke '
        'legst du unkontrolliert zurück?',
    options: [
      'rund 30 Meter',
      'rund 50 Meter',
      'rund 90 Meter',
      'rund 160 Meter',
    ],
    correctIndex: 2,
    explanation: '80 km/h sind rund 22 Meter pro Sekunde, mal 4 ergibt '
        'etwa 89 Meter. Anders als beim Handyblick lenkst du in dieser '
        'Zeit gar nicht — das Fahrzeug driftet aus der Spur. Deshalb ist '
        'die Vorstellung eines „kurzen" Wegnickens so gefährlich.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Was hilft gegen akute Müdigkeit am Steuer wirklich?',
    options: [
      'Fenster öffnen und laute Musik',
      'Kaffee trinken und schneller fahren, um früher fertig zu sein',
      'Anhalten, 15–20 Minuten Kurzschlaf, danach Bewegung',
    ],
    correctIndex: 2,
    explanation: 'Nur Schlaf und Bewegung stellen die Aufmerksamkeit '
        'wieder her. Frische Luft und laute Musik wirken höchstens '
        'wenige Minuten und täuschen dabei Wachheit vor — genau in dieser '
        'Phase überschätzt man sich am stärksten.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Ein Ohrhörer für die Freisprechfunktion, das andere Ohr '
        'frei — ist das während der Fahrt in Ordnung?',
    options: [
      'Ja, ein freies Ohr genügt für den Verkehr',
      'Ja, solange die Lautstärke niedrig eingestellt ist',
      'Nein',
    ],
    correctIndex: 2,
    explanation: 'Du musst Hupen, Rufe und Einsatzfahrzeuge sicher '
        'orten können — und dafür brauchst du beide Ohren; beim '
        'Rangieren ist das Gehör oft die einzige Warnung. Eine niedrige '
        'Lautstärke ändert nichts daran, dass ein Ohr belegt ist.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Was droht, wenn du mit dem Handy in der Hand einen anderen '
        'Verkehrsteilnehmer gefährdest?',
    options: [
      '100 € und 1 Punkt',
      '150 €, 2 Punkte und 1 Monat Fahrverbot',
      'Eine mündliche Verwarnung ohne Eintrag',
    ],
    correctIndex: 1,
    explanation: '100 € und 1 Punkt sind der Grundtatbestand ohne '
        'Gefährdung; kommt eine Gefährdung hinzu, steigt es auf 150 €, '
        '2 Punkte und einen Monat Fahrverbot. Für dich als Berufsfahrer '
        'ist nicht das Geld das Problem, sondern das Fahrverbot.',
  ),
  DrivingQuestion(
    moduleId: 'm6',
    question: 'Der Tourenplan ist heute nicht sicher zu schaffen. Was ist '
        'die richtige Reaktion?',
    options: [
      'Sicher weiterarbeiten und das Planungsproblem früh melden',
      'Pausen streichen und die Kontrollen beim Rangieren kürzen',
      'Zwischen den Stopps schneller fahren und die Zeit dort holen',
    ],
    correctIndex: 0,
    explanation: 'Der Plan wird angepasst, nicht die Sicherheit. '
        'Entscheidend ist außerdem der Zeitpunkt: Eine Meldung am frühen '
        'Nachmittag kann noch etwas bewirken, eine am Abend nicht mehr. '
        'Pausen zu streichen verschärft das Problem, weil deine '
        'Aufmerksamkeit genau dann abfällt.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M7 — Ein-/Aussteigen & Heben
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Wie lautet die 3-Punkt-Regel („2+1") der BG Verkehr beim '
        'Ein- und Aussteigen?',
    options: [
      'Eine Hand und zwei Füße sind immer am Fahrzeug',
      'Zwei Hände und ein Fuß sind immer in Kontakt mit dem Fahrzeug',
      'Beide Füße stehen auf dem Boden, bevor du die Griffe loslässt',
    ],
    correctIndex: 1,
    explanation: 'Zwei Hände plus ein Fuß ergeben drei feste Punkte, '
        'sodass ein einzelner Ausrutscher nie zum Sturz führt. „Beide '
        'Füße zuerst auf den Boden" beschreibt genau den Moment, in dem '
        'du gar keinen Halt mehr hast — das ist die Sprungvariante.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Wie steigst du richtig aus dem Fahrerhaus aus?',
    options: [
      'Vorwärts, mit dem Rücken zur Tür, den letzten Schritt springend',
      'Seitlich aus dem Sitz herausdrehen und auf beiden Füßen landen',
      'Rückwärts, mit dem Gesicht zum Fahrzeug, wie auf einer Leiter',
    ],
    correctIndex: 2,
    explanation: 'Nur mit dem Gesicht zum Fahrzeug kannst du Haltegriffe '
        'und Trittstufe nutzen und drei Kontaktpunkte halten. Das '
        'Herausdrehen aus dem Sitz wirkt schneller, belastet aber Knie '
        'und Sprunggelenk mit dem vollen Körpergewicht auf einmal — es '
        'ist der häufigste Ausstiegsfehler.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Welcher dieser Griffe zählt NICHT als sicherer '
        'Kontaktpunkt?',
    options: [
      'Der Haltegriff an der A-Säule',
      'Die Türkante',
      'Der Haltegriff am Türrahmen',
    ],
    correctIndex: 1,
    explanation: 'Die Türkante gehört zu einem beweglichen Bauteil: Die '
        'Tür kann nachgeben oder zuschwingen, gerade wenn du dein '
        'Gewicht darauf verlagerst. Dasselbe gilt für Lenkrad, Sitz, '
        'Reifen und Radnabe — sichere Punkte sind nur die dafür '
        'vorgesehenen Haltegriffe.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Du hast Scanner und ein Paket in den Händen und willst aus '
        'dem Laderaum steigen. Was ist richtig?',
    options: [
      'Beides zuerst abstellen, dann mit freien Händen absteigen',
      'Das Paket unter den Arm klemmen und dich mit der freien Hand '
          'festhalten',
      'Zügig aussteigen, es sind ja nur zwei Stufen',
    ],
    correctIndex: 0,
    explanation: 'Mit vollen Händen hast du keine drei Kontaktpunkte und '
        'kannst einen Sturz nicht abfangen. Die Ein-Hand-Variante klingt '
        'nach Kompromiss, ist aber genau die Situation, in der ein '
        'Abrutschen direkt zum Sturz führt: Ein Punkt hält dich nicht.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Du hältst am Fahrbahnrand und willst die Fahrertür '
        'öffnen. Was schützt einen von hinten kommenden Radfahrer am '
        'besten?',
    options: [
      'Die Tür nur einen Spalt öffnen und kurz warten',
      'Die Tür zügig und weit öffnen, damit sie gut sichtbar ist',
      'Vor dem Öffnen kurz in den Außenspiegel schauen',
      'Schulterblick und Spiegel — und die Tür mit der weiter entfernten '
          'Hand öffnen',
    ],
    correctIndex: 3,
    explanation: 'Der Griff mit der weiter entfernten Hand dreht deinen '
        'Oberkörper automatisch nach hinten und erzwingt den Blick. Der '
        'kurze Spiegelblick allein reicht nicht, weil ein Radfahrer im '
        'toten Winkel genau dann nicht sichtbar ist; und ein '
        'spaltbreites Öffnen warnt niemanden, der bereits neben dir ist.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Was ist beim Heben die gefährlichste Kombination für die '
        'Wirbelsäule?',
    options: [
      'Anheben und dabei den Oberkörper verdrehen',
      'Anheben mit stark angewinkelten Knien aus der Hocke',
      'Anheben mit der Last dicht am Körper',
    ],
    correctIndex: 0,
    explanation: 'Last plus Drehung belastet die Bandscheiben einseitig '
        'und ist die klassische Ursache für akute Rückenschäden — '
        'stattdessen mit den Füßen umtreten. Hocke und körpernahe Last '
        'sind dagegen genau die richtige Technik.',
  ),
  DrivingQuestion(
    moduleId: 'm7',
    question: 'Du knickst beim Aussteigen leicht um, kannst aber '
        'weiterarbeiten. Was ist richtig?',
    options: [
      'Abwarten und nur melden, wenn es am nächsten Tag noch schmerzt',
      'Nichts tun — es war nur ein Umknicken ohne Ausfall',
      'Sofort melden und ins Verbandbuch eintragen',
    ],
    correctIndex: 2,
    explanation: 'Nur dokumentierte Vorfälle gelten später als '
        'Arbeitsunfall, und ein unbehandeltes Bänderproblem heilt '
        'schlechter. Das Abwarten bis zum nächsten Tag ist verbreitet '
        'und genau der Grund, warum der Zusammenhang mit der Arbeit '
        'später oft nicht mehr anerkannt wird.',
    moduleOnly: true,
  ),

  // ══════════════════════════════════ M8 — Haustür & Umgebung
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Ein großer Hund bellt am Gartentor. Der Kunde hat im '
        'Lieferhinweis notiert: „Hund ist lieb." Was tust du?',
    options: [
      'Ruhig hineingehen — der Kunde kennt seinen Hund am besten',
      'Das Grundstück nicht betreten, Kontakt versuchen und den Hinweis '
          'für Kollegen hinterlegen',
      'Das Paket über den Zaun legen und weiterfahren',
    ],
    correctIndex: 1,
    explanation: 'Ein Lieferhinweis ist keine Sicherheitsfreigabe: Der '
        'Kunde kennt seinen Hund im Umgang mit der Familie, nicht mit '
        'einem fremden Menschen, der ein großes Objekt trägt. Das Paket '
        'über den Zaun zu legen ist außerdem keine ordnungsgemäße '
        'Zustellung.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Ein freilaufender Hund kommt bellend auf dich zu. Was ist '
        'richtig?',
    options: [
      'Ruhig stehen bleiben, Blick abwenden, ihm die Seite zuwenden und '
          'langsam zurückgehen',
      'Zügig zum Fahrzeug zurücklaufen und die Tür schließen',
      'Laut werden und das Paket zur Abwehr erheben',
    ],
    correctIndex: 0,
    explanation: 'Ruhe, abgewandter Blick und langsames Zurückweichen '
        'nehmen dem Hund den Anlass. Zum Fahrzeug zu laufen klingt '
        'vernünftig, ist aber falsch: Wegrennen löst den Jagdreflex aus, '
        'und der Hund ist schneller als du.',
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Der kürzeste Weg zur Haustür führt über einen nassen '
        'Rasen. Was tust du?',
    options: [
      'Abkürzen — bei 120 Stopps summiert sich der Umweg erheblich',
      'Abkürzen, aber nur bei Tageslicht und trockener Witterung',
      'Den befestigten Weg nehmen',
    ],
    correctIndex: 2,
    explanation: 'Stolpern, Rutschen und Stürzen ist die häufigste '
        'Verletzungsursache in der Zustellung, und fast immer passiert es '
        'auf den letzten Metern. Die Zeitrechnung geht nicht auf: Der '
        'Umweg kostet Sekunden, ein Sturz im Schnitt 24 Ausfalltage.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm8',
    question: 'Was gilt, wenn du das Fahrzeug für eine Zustellung '
        'verlässt?',
    options: [
      'Motor aus, Schlüssel mitnehmen, abschließen, am Gefälle Räder '
          'einschlagen',
      'Der Motor darf laufen, solange du in Sichtweite bleibst',
      'Es genügt, die Handbremse fest anzuziehen',
    ],
    correctIndex: 0,
    explanation: 'Wer sein Fahrzeug verlässt, muss es gegen unbefugte '
        'Benutzung sichern und Unfälle vermeiden. „In Sichtweite" ist '
        'keine Ausnahme — ein laufendes, offenes Fahrzeug ist in '
        'Sekunden weg, und am Gefälle hält die Handbremse allein einen '
        'beladenen Transporter nicht zuverlässig.',
  ),

  // ══════════════════════════════════ M9 — Notfall & Unfall
  DrivingQuestion(
    moduleId: 'm9',
    question: 'In welcher Reihenfolge handelst du an einer Unfallstelle '
        'mit Verletzten?',
    options: [
      'Erste Hilfe leisten, dann absichern, dann den Notruf absetzen',
      'Absichern, dann Notruf, dann Erste Hilfe',
      'Notruf, dann Fotos für die Versicherung, dann Erste Hilfe',
    ],
    correctIndex: 1,
    explanation: 'Erst die Stelle sichern, sonst wird aus einem Unfall '
        'ein zweiter — mit dir als Opfer. Sofort zum Verletzten zu '
        'laufen wirkt menschlich richtig, ist auf Landstraße und '
        'Autobahn aber lebensgefährlich; Fotos haben in dieser Phase gar '
        'keinen Platz.',
    mandatoryInExam: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'In welchem Abstand stellst du das Warndreieck auf der '
        'Autobahn auf?',
    options: [
      'ca. 50 Meter',
      'ca. 100 Meter',
      'ca. 150–200 Meter',
    ],
    correctIndex: 2,
    explanation: 'Innerorts rund 50 m, außerorts rund 100 m, auf der '
        'Autobahn 150–200 m — je höher das Tempo, desto früher muss die '
        'Warnung stehen. Wer den Außerorts-Wert nimmt, gibt dem '
        'nachfolgenden Verkehr bei 120 km/h kaum drei Sekunden. Vor '
        'Kuppen und Kurven gehört das Dreieck davor, nicht dahinter.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Auf einer dreispurigen Autobahn stockt der Verkehr. Wo '
        'bildest du die Rettungsgasse?',
    options: [
      'Zwischen der linken und der mittleren Spur',
      'Zwischen der mittleren und der rechten Spur',
      'Auf dem Standstreifen',
      'In der Mitte der Fahrbahn, unabhängig von der Spurzahl',
    ],
    correctIndex: 0,
    explanation: 'Die Gasse liegt immer zwischen dem äußerst linken und '
        'dem unmittelbar rechts daneben liegenden Fahrstreifen — '
        'unabhängig davon, wie viele Spuren es gibt. Der Standstreifen '
        'ist keine Alternative: Dort fahren Einsatzkräfte, wenn die '
        'Gasse blockiert ist.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Wann muss die Rettungsgasse gebildet werden?',
    options: [
      'Erst wenn Blaulicht zu sehen oder zu hören ist',
      'Sobald der Verkehr stockt',
      'Erst wenn es über die Anzeigetafel angeordnet wird',
    ],
    correctIndex: 1,
    explanation: 'Die Gasse entsteht mit dem Stocken, nicht mit dem '
        'Blaulicht. Wartet man auf das Einsatzfahrzeug, stehen die '
        'Fahrzeuge längst zu dicht — dann hat niemand mehr Platz zum '
        'Ausweichen.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Du beschädigst beim Rangieren ein geparktes Auto, niemand '
        'ist in der Nähe. Reicht ein Zettel hinter dem Scheibenwischer?',
    options: [
      'Ja, wenn Name und Telefonnummer darauf stehen',
      'Ja, ein Zettel ist der gesetzlich vorgesehene Weg',
      'Nein — es reicht nur, wenn du zusätzlich Fotos machst',
      'Nein — du musst eine angemessene Zeit warten und sonst die '
          'Polizei informieren',
    ],
    correctIndex: 3,
    explanation: 'Ein Zettel gilt rechtlich nicht als ausreichende '
        'Feststellung — er kann wegfliegen oder entfernt werden; wer '
        'sich darauf verlässt, riskiert den Vorwurf des unerlaubten '
        'Entfernens vom Unfallort. Fotos dokumentieren zwar den Schaden, '
        'ersetzen aber weder das Warten noch die Meldung.',
  ),
  DrivingQuestion(
    moduleId: 'm9',
    question: 'Eine Person atmet nach dem Unfall nicht normal. Was tust '
        'du?',
    options: [
      'Sofort mit der Herzdruckmassage beginnen, etwa 100–120 Mal pro '
          'Minute',
      'Die Person in die stabile Seitenlage bringen und zudecken',
      'Auf den Rettungsdienst warten — als Laie darfst du nichts machen',
    ],
    correctIndex: 0,
    explanation: 'Ohne normale Atmung zählt jede Minute, und Drücken ist '
        'die einzige Maßnahme, die hilft. Die stabile Seitenlage ist '
        'richtig — aber nur bei vorhandener normaler Atmung. Und '
        'Nichtstun ist die einzige falsche Entscheidung: Unterlassene '
        'Hilfeleistung ist strafbar.',
  ),

  // ══════════════════════════════════ M10 — Zusammenfassung
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Was fasst die Haltung dieser Schulung am besten zusammen?',
    options: [
      'Regeln gelten vor allem dann, wenn kontrolliert wird',
      'Sicherheit ist meine tägliche Entscheidung, damit alle sicher nach '
          'Hause kommen',
      'Hauptsache, die Tour ist pünktlich abgearbeitet',
    ],
    correctIndex: 1,
    explanation: 'Sicherheit ist eine Haltung, keine Pflichtübung — und '
        'sie zeigt sich gerade dann, wenn niemand zusieht. Wer Regeln an '
        'Kontrollen koppelt, hat sie nicht verstanden, sondern nur '
        'ausgehalten.',
    moduleOnly: true,
  ),
  DrivingQuestion(
    moduleId: 'm10',
    question: 'Wie viele Kontaktpunkte hältst du beim Ein- und '
        'Aussteigen — und wie viele Sekunden Abstand mindestens auf '
        'trockener Straße?',
    options: [
      '2 Kontaktpunkte und 1 Sekunde',
      '3 Kontaktpunkte und 1 Sekunde',
      '3 Kontaktpunkte (2 Hände + 1 Fuß) und 2 Sekunden',
    ],
    correctIndex: 2,
    explanation: 'Drei Kontaktpunkte („2+1") und zwei Sekunden Abstand — '
        'bei Nässe drei. Eine Sekunde Abstand entspricht bei Tempo 50 '
        'genau dem reinen Reaktionsweg: Du würdest ohne jede '
        'Bremsreserve auffahren.',
  ),
];

// Sprachauflösung, `drivingQuestionsForModule()` und `buildDrivingExam()`
// leben in driving_safety_data.dart.
