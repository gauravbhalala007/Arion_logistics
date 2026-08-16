// lib/data/safety_training/green_book_quiz_de.dart
//
// Fragen des Green-Book-Abschlusstests (Fahrtenkontrollbuch nach
// § 1 Abs. 6 FPersV). Zwanzig Fragen, verteilt auf die sechs Kapitel aus
// green_book_content_de.dart.
//
// Anspruch der Fragen: Szenarien aus dem Zustellalltag, Zeitrechnungen und
// Rechtsfolgefragen. Mehrere Optionen klingen bewusst plausibel — es kommt
// jeweils auf ein Detail an. Die `explanation` erklärt immer beides: warum
// die richtige Antwort richtig ist und warum der naheliegende Irrtum
// falsch ist.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> greenBookQuestionsDe = [
  // ══════════════════════════ gb1 — Was das Green Book ist
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Was dokumentierst du im Green Book?',
    options: [
      'Den Zustand des Fahrzeugs vor Fahrtantritt',
      'Die Anzahl der zugestellten Pakete und Retouren',
      'Lenkzeiten, Fahrtunterbrechungen sowie Arbeits- und Ruhezeiten',
    ],
    correctIndex: 2,
    explanation: 'Das Green Book ist das Fahrtenkontrollbuch — die Sammlung '
        'der Tageskontrollblätter nach § 1 Abs. 6 FPersV. Es weist '
        'ausschließlich Zeiten nach. Der Fahrzeugzustand wird an anderer '
        'Stelle dokumentiert und gehört ausdrücklich nicht hierher.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Für welche Fahrzeuge gilt die Aufzeichnungspflicht nach '
        '§ 1 Abs. 6 FPersV?',
    options: [
      'Über 2,8 t bis 3,5 t zulässige Gesamtmasse im gewerblichen '
          'Güterverkehr',
      'Für jedes Fahrzeug, mit dem gewerblich Pakete transportiert werden',
      'Erst ab 3,5 t zulässiger Gesamtmasse',
    ],
    correctIndex: 0,
    explanation: 'Die Pflicht greift im Bereich über 2,8 t bis 3,5 t — genau '
        'der typische Zustell-Transporter. Unterhalb von 2,8 t besteht sie '
        'nicht, ab 3,5 t übernimmt der digitale Tachograf die Aufzeichnung.',
  ),
  DrivingQuestion(
    moduleId: 'gb1',
    question: 'Dein Transporter hat laut Fahrzeugschein 3,5 t zulässige '
        'Gesamtmasse, ist heute aber nur mit 900 kg beladen. Was gilt?',
    options: [
      'Keine Aufzeichnungspflicht — das tatsächliche Gewicht liegt unter '
          '2,8 t',
      'Die Aufzeichnungspflicht bleibt bestehen',
      'Die Pflicht gilt erst ab einer Tagesstrecke von 100 Kilometern',
    ],
    correctIndex: 1,
    explanation: 'Maßgeblich ist die zulässige Gesamtmasse aus dem '
        'Fahrzeugschein, nicht das heutige Ladegewicht. Der naheliegende '
        'Irrtum ist, jeden Tag neu nach der Beladung zu rechnen — die '
        'Einstufung des Fahrzeugs ändert sich dadurch nicht.',
  ),

  // ══════════════════════════ gb2 — Was genau eingetragen wird
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Welche Angabe gehört NICHT zu den Pflichtangaben des '
        'Tageskontrollblatts?',
    options: [
      'Kilometerstand bei Beginn und bei Ende der Fahrt',
      'Anzahl der zugestellten Sendungen',
      'Ort des Fahrtbeginns und des Fahrtendes',
    ],
    correctIndex: 1,
    explanation: 'Vorgeschrieben sind unter anderem Name, Vorname und '
        'Anschrift des Fahrers, das Kennzeichen, das Datum, die '
        'Kilometerstände, die Orte, die Zeiten und die Unterschrift. '
        'Stückzahlen sind eine betriebliche Kennzahl und stehen nicht auf '
        'dem Blatt.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Womit füllst du das Tageskontrollblatt aus?',
    options: [
      'Mit Kugelschreiber, dokumentenecht',
      'Mit Bleistift, damit sich Fehler sauber korrigieren lassen',
      'Das Schreibgerät ist egal, solange man es lesen kann',
    ],
    correctIndex: 0,
    explanation: 'Ein Eintrag, den man wegradieren kann, ist kein Nachweis. '
        'Genau deshalb ist Bleistift unzulässig — auch wenn die Korrektur '
        'gut gemeint ist. Ein Fehler wird einmal durchgestrichen und daneben '
        'neu geschrieben.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Alle Zeiten und Kilometerstände sind eingetragen, nur die '
        'Unterschrift fehlt. Was gilt für dieses Blatt?',
    options: [
      'Es ist gültig — die Unterschrift ist reine Formsache',
      'Es gilt als unvollständig und erfüllt die Aufzeichnungspflicht nicht',
      'Der Disponent kann es im Betrieb nachträglich gegenzeichnen',
    ],
    correctIndex: 1,
    explanation: 'Die Unterschrift ist eine der vorgeschriebenen Angaben — '
        'mit ihr bestätigst du den Inhalt. Ohne sie ist das Blatt '
        'unvollständig, mit denselben Folgen wie ein fehlendes Blatt. Eine '
        'fremde Unterschrift ersetzt deine nicht.',
  ),
  DrivingQuestion(
    moduleId: 'gb2',
    question: 'Du wartest 40 Minuten an der Rampe. Du tust nichts, musst '
        'aber jederzeit bereitstehen, weil es sofort weitergehen kann. Wie '
        'trägst du diese Zeit ein?',
    options: [
      'Als Fahrtunterbrechung — du hast schließlich nicht gearbeitet',
      'Als Beginn der täglichen Ruhezeit',
      'Als Arbeitszeit',
    ],
    correctIndex: 2,
    explanation: 'Eine Fahrtunterbrechung ist nur dann eine Pause, wenn du '
        'frei über die Zeit verfügen kannst und das vorher weißt. '
        'Bereitstehen ist Wartezeit und damit Arbeitszeit. Der naheliegende '
        'Irrtum lautet „ich habe nichts getan, also war es Pause" — '
        'entscheidend ist nicht die Tätigkeit, sondern die Verfügbarkeit.',
  ),

  // ══════════════════════════ gb3 — Lenkzeiten, Pausen, Ruhezeiten
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Wie lange darfst du an einem normalen Tag höchstens lenken?',
    options: [
      '9 Stunden',
      '10 Stunden',
      '8 Stunden, danach nur noch mit Zustimmung des Disponenten',
    ],
    correctIndex: 0,
    explanation: 'Die tägliche Lenkzeit beträgt höchstens 9 Stunden. Die 10 '
        'Stunden sind keine zweite Regelgrenze, sondern eine eng begrenzte '
        'Ausnahme — und eine betriebliche Zustimmung spielt für die Grenze '
        'überhaupt keine Rolle.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Wie oft darfst du die Lenkzeit auf 10 Stunden verlängern?',
    options: [
      'Einmal pro Woche',
      'Zweimal pro Woche',
      'An jedem Tag, an dem die Tour es erfordert',
    ],
    correctIndex: 1,
    explanation: 'Zweimal in der Woche darf die tägliche Lenkzeit auf 10 '
        'Stunden verlängert werden. Es ist ein Wochenkontingent, kein '
        'tägliches Recht — und der Umfang der Tour verlängert es nicht.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Du willst die Fahrtunterbrechung von 45 Minuten aufteilen. '
        'Welche Aufteilung ist zulässig?',
    options: [
      'Zuerst 30 Minuten, danach 15 Minuten',
      'Dreimal 15 Minuten über den Tag verteilt',
      'Zuerst 15 Minuten, danach 30 Minuten',
    ],
    correctIndex: 2,
    explanation: 'Die Teilung ist nur in zwei Abschnitten und nur in dieser '
        'Reihenfolge zulässig: erst mindestens 15, danach mindestens 30 '
        'Minuten. Die umgekehrte Reihenfolge zählt nicht, drei kurze '
        'Abschnitte ebenso wenig — auch wenn die Summe stimmt.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Du startest um 07:00 Uhr. Bis 09:30 Uhr sitzt du 2 Stunden am '
        'Steuer, bis 12:00 Uhr kommen 2 weitere Stunden Lenkzeit dazu, bis '
        '13:00 Uhr noch einmal 30 Minuten. Wann ist die Fahrtunterbrechung '
        'spätestens fällig?',
    options: [
      'Um 11:30 Uhr, also 4,5 Stunden nach Dienstbeginn',
      'Um 12:00 Uhr, weil die Mittagszeit dafür vorgesehen ist',
      'Um 13:00 Uhr',
    ],
    correctIndex: 2,
    explanation: '2 + 2 + 0,5 Stunden ergeben um 13:00 Uhr genau 4,5 Stunden '
        'reine Lenkzeit — jetzt darfst du keinen Meter mehr fahren, bevor '
        'die Pause erledigt ist. Der naheliegende Irrtum ist, ab '
        'Dienstbeginn zu rechnen: Die Uhr läuft nur, wenn das Fahrzeug '
        'fährt.',
  ),
  DrivingQuestion(
    moduleId: 'gb3',
    question: 'Du beendest die Lenkzeit um 17:15 Uhr. Wann darfst du '
        'frühestens wieder starten?',
    options: [
      'Um 02:15 Uhr — 9 Stunden Ruhezeit genügen',
      'Um 04:15 Uhr',
      'Sobald du dich ausgeruht fühlst, es gibt keine feste Grenze',
    ],
    correctIndex: 1,
    explanation: 'Die tägliche Ruhezeit beträgt mindestens 11 Stunden, also '
        'frühestens 04:15 Uhr. 9 Stunden sind die Grenze für die Lenkzeit, '
        'nicht für die Ruhezeit — die beiden Zahlen werden regelmäßig '
        'verwechselt.',
  ),

  // ══════════════════════════ gb4 — Typische Fehler
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Ein Kollege füllt die Blätter der ganzen Woche freitagabends '
        'aus. Die Zeiten stimmen inhaltlich. Wie ist das zu bewerten?',
    options: [
      'Es ist ein Verstoß und fällt bei einer Kontrolle auf',
      'Unproblematisch, solange die eingetragenen Zeiten der Wahrheit '
          'entsprechen',
      'Nur eine Frage der Ordnung, aber ohne rechtliche Bedeutung',
    ],
    correctIndex: 0,
    explanation: 'Aufzeichnen heißt zeitnah aufzeichnen. Nachgeschriebene '
        'Blätter erkennt man an gleichem Schriftbild, auffällig runden '
        'Zeiten und Kilometerständen, die nicht zur Strecke passen. Dass die '
        'Zeiten stimmen, heilt den Verstoß gegen die Aufzeichnungspflicht '
        'nicht.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Du merkst am Donnerstag, dass am Dienstag die Mittagspause '
        'nicht eingetragen ist. Du erinnerst dich sicher an die Uhrzeit. Was '
        'tust du?',
    options: [
      'Als Nachtrag mit Datum der Ergänzung eintragen und den Disponenten '
          'informieren',
      'Den Eintrag so einfügen, dass er wie am Dienstag geschrieben aussieht',
      'Die Lücke lassen — ein Nachtrag macht es nur schlimmer',
    ],
    correctIndex: 0,
    explanation: 'Eine ehrliche, erkennbar datierte Korrektur ist zulässig '
        'und besser als eine Lücke. Den Eintrag so zu gestalten, als wäre er '
        'am Dienstag entstanden, ist der Schritt von der Nachlässigkeit zur '
        'Täuschung — und wiegt deutlich schwerer.',
  ),
  DrivingQuestion(
    moduleId: 'gb4',
    question: 'Du hast heute 9,5 Stunden gelenkt, obwohl dein '
        'Wochenkontingent für 10 Stunden bereits aufgebraucht war. Was '
        'trägst du ein?',
    options: [
      'Genau 9,0 Stunden — damit das Blatt regelkonform aussieht',
      'Die tatsächlich gefahrenen 9,5 Stunden',
      'Für diesen Tag gar nichts, dann fällt es nicht auf',
    ],
    correctIndex: 1,
    explanation: 'Du trägst immer die tatsächlichen Zeiten ein. Ein '
        'geschönter Eintrag verwandelt eine Überschreitung in eine '
        'Falschangabe und macht die Sache schlimmer. Ein fehlendes Blatt ist '
        'ebenfalls ein eigener Verstoß — Weglassen hilft nicht.',
  ),

  // ══════════════════════════ gb5 — Mitführen, abgeben, aufbewahren
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Welche Aufzeichnungen musst du im Fahrzeug mitführen?',
    options: [
      'Nur das Blatt des laufenden Tages',
      'Die Blätter der laufenden Kalenderwoche',
      'Den laufenden Tag und die vorausgegangenen 28 Tage',
    ],
    correctIndex: 2,
    explanation: 'Mitzuführen sind die Aufzeichnungen der letzten 28 Tage '
        'einschließlich des laufenden Tages. Dass ältere Blätter ordentlich '
        'im Betrieb liegen, erfüllt die Aufbewahrungspflicht, aber nicht die '
        'Mitführpflicht — das sind zwei getrennte Pflichten.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Wie lange muss der Unternehmer die Tageskontrollblätter im '
        'Betrieb aufbewahren?',
    options: [
      'Ein Jahr',
      '28 Tage, danach dürfen sie vernichtet werden',
      'Drei Monate ab Ende des Quartals',
    ],
    correctIndex: 0,
    explanation: 'Der Unternehmer bewahrt die Aufzeichnungen ein Jahr lang '
        'auf und legt sie auf Verlangen vor. Die 28 Tage sind die Frist für '
        'das Mitführen durch den Fahrer — sie werden häufig mit der '
        'Aufbewahrungsfrist verwechselt.',
  ),
  DrivingQuestion(
    moduleId: 'gb5',
    question: 'Wer kontrolliert die Einhaltung der Aufzeichnungspflicht?',
    options: [
      'Ausschließlich die Polizei, und nur bei Straßenkontrollen',
      'BAG und Polizei — bei Straßenkontrollen und im Betrieb',
      'Der TÜV im Rahmen der Hauptuntersuchung des Fahrzeugs',
    ],
    correctIndex: 1,
    explanation: 'Kontrolliert wird durch das BAG (Bundesamt für Logistik '
        'und Mobilität) und die Polizei, sowohl am Straßenrand als auch im '
        'Betrieb. Die Hauptuntersuchung betrifft den technischen Zustand des '
        'Fahrzeugs und hat mit den Aufzeichnungen nichts zu tun.',
  ),

  // ══════════════════════════ gb6 — Konsequenzen
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Womit ist zu rechnen, wenn Blätter fehlen oder unvollständig '
        'sind?',
    options: [
      'Mit einem Bußgeld ab 100 Euro, je nach Schwere auch höher',
      'Mit gar keiner Folge — es ist eine rein betriebliche Vorschrift',
      'Mit einer kostenlosen Verwarnung ohne weitere Konsequenzen',
    ],
    correctIndex: 0,
    explanation: 'Fehlende oder unvollständige Aufzeichnungen sind eine '
        'Ordnungswidrigkeit; das Bußgeld beginnt bei rund 100 Euro und '
        'steigt mit der Schwere. Bei schweren oder wiederholten Verstößen '
        'kann zusätzlich ein Verfahren zur Zuverlässigkeit des Unternehmens '
        'eingeleitet werden.',
  ),
  DrivingQuestion(
    moduleId: 'gb6',
    question: 'Der Disponent sagt: „Fahr die zwei Stopps noch, die Pause '
        'schreibst du einfach rein." Wie reagierst du?',
    options: [
      'Der Anweisung folgen — der Disponent trägt dann die Verantwortung',
      'Die Pause weglassen, aber wenigstens ehrlich eintragen, dass sie '
          'fehlt',
      'Pause machen, korrekt eintragen und die offenen Stopps melden',
    ],
    correctIndex: 2,
    explanation: 'Eine mündliche Anweisung hebt deine Aufzeichnungspflicht '
        'nicht auf — du unterschreibst das Blatt und bestätigst damit den '
        'Inhalt. Die Pause bewusst ausfallen zu lassen wäre zusätzlich ein '
        'Verstoß gegen die Lenkzeitvorschriften. Der Betrieb muss die '
        'Einhaltung ermöglichen, nicht umgehen.',
  ),
];

/// Fragen eines Kapitels.
List<DrivingQuestion> greenBookQuestionsForModule(String id) =>
    greenBookQuestionsDe.where((q) => q.moduleId == id).toList();
