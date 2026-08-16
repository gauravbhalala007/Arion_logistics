// lib/data/safety_training/ride_along_quiz_de.dart
//
// Fragen des Ride-Along-Abschlusstests. Fünfzehn Fragen, verteilt auf die
// fünf Kapitel aus ride_along_content_de.dart (ra1 … ra5), je drei
// Fragen pro Kapitel.
//
// Anspruch der Fragen: Szenarien aus den zwei Begleitfahrt-Tagen. Mehrere
// Optionen klingen bewusst plausibel — es kommt jeweils auf ein Detail
// an. Die `explanation` erklärt immer beides: warum die richtige Antwort
// richtig ist und warum der naheliegende Irrtum falsch ist.
//
// Mandantenfähig: Es wird nirgends nach betriebsspezifischen Zahlen
// (Stoppzahlen, Waiting-Area-Zeiten, Parkseite) gefragt — nur nach dem,
// was überall gilt. Ausnahmen mit Rechtsbezug: § 4 ArbZG (Pausen) und
// § 1 Abs. 6 FPersV (Green Book).

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> rideAlongQuestionsDe = [
  // ══════════════════════════ ra1 — Was der Ride Along ist
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Was ist der Ride Along?',
    options: [
      'Eine theoretische Einweisung im Büro vor dem ersten Arbeitstag',
      'Zwei Arbeitstage Begleitfahrt mit einem erfahrenen Fahrer als '
          'Trainer',
      'Eine amtliche Fahrprüfung, ohne die du nicht eingesetzt werden '
          'darfst',
    ],
    correctIndex: 1,
    explanation: 'Der Ride Along sind zwei echte Arbeitstage im Betrieb, an '
        'denen ein erfahrener Fahrer dich begleitet, alles erklärt und '
        'dich anschließend selbst machen lässt. Es ist weder eine '
        'Büroschulung noch eine behördliche Prüfung — es ist Einarbeitung '
        'im laufenden Betrieb, die aber bewertet und dokumentiert wird.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Wie viele Stopps musst du an den beiden Tagen fahren?',
    options: [
      'Das legt dein Betrieb bzw. deine Station fest — der Trainer nennt '
          'dir die Vorgabe',
      'Immer genau 20 am ersten und 70 am zweiten Tag, in jedem Betrieb '
          'gleich',
      'So viele, wie du dir selbst zutraust — eine Vorgabe gibt es nicht',
    ],
    correctIndex: 0,
    explanation: 'Verbreitet sind eine kleinere Zahl am ersten und deutlich '
        'mehr am zweiten Tag (oft rund 20 und rund 70), aber das sind '
        'Richtwerte einzelner Betriebe. Verbindlich ist allein die Vorgabe '
        'deiner Station. Der naheliegende Irrtum ist, eine gehörte Zahl '
        'für ein allgemeines Gesetz zu halten — frag deinen Trainer nach '
        'der Zahl, die für dich gilt.',
  ),
  DrivingQuestion(
    moduleId: 'ra1',
    question: 'Du bist am ersten Tag deutlich langsamer als geplant und '
        'machst mehrere Fehler beim Sortieren. Wie wirkt sich das auf die '
        'Bewertung aus?',
    options: [
      'Der Ride Along gilt damit als nicht bestanden und muss wiederholt '
          'werden',
      'Es spielt keine Rolle, denn am ersten Tag wird noch gar nichts '
          'bewertet',
      'Entscheidend ist, ob du nachfragst und den Fehler danach abstellst '
          '— nicht das Tempo',
    ],
    correctIndex: 2,
    explanation: 'Tempo am ersten Tag erwartet niemand; genau dafür ist die '
        'kleinere Stoppzahl da. Bewertet wird deine Lernbereitschaft: '
        'Fragst du nach, nimmst du Hinweise an, machst du denselben Fehler '
        'beim dritten Mal noch? Der Irrtum in beide Richtungen ist '
        'gefährlich — es ist weder eine Prüfung mit Fallbeil noch ein Tag '
        'ohne Bewertung.',
  ),

  // ══════════════════════════ ra2 — Der erste Tag
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Warum müssen die Stopps am Ride Along über deinen eigenen '
        'Account laufen?',
    options: [
      'Weil der Trainer seinen Account an diesen Tagen nicht benutzen darf',
      'Weil nur so sichtbar wird, wie deine eigene Zustellung aussieht — '
          'sie zählt unter deinem Namen',
      'Weil der Account des Trainers keine neuen Stopps mehr aufnehmen '
          'kann',
    ],
    correctIndex: 1,
    explanation: 'Alles, was du an diesen Tagen zustellst, läuft unter '
        'deinem Namen — genau wie später im Alltag. Nur so sehen Trainer '
        'und Betrieb deine tatsächliche Arbeitsweise, und nur so zählen '
        'die Stopps für deine Einarbeitung. Deshalb ist ein nicht '
        'funktionierender Zugang am Morgen kein Detail, sondern ein Grund, '
        'sofort Bescheid zu geben.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Was gilt für die Aufzeichnungsdauer von Mentor?',
    options: [
      'Mentor zeichnet rund 4 Stunden am Stück auf und muss danach neu '
          'gestartet werden',
      'Mentor läuft, einmal gestartet, bis zum Ende der Schicht durch',
      'Mentor startet sich automatisch, sobald sich das Fahrzeug bewegt',
    ],
    correctIndex: 0,
    explanation: 'Die Aufzeichnung läuft jeweils rund vier Stunden. Danach '
        'musst du sie neu starten, sonst bleibt der Rest der Tour '
        'unerfasst. Der häufigste Anfängerfehler ist genau der Irrtum, die '
        'App liefe von allein durch: morgens korrekt gestartet, nach der '
        'Pause nicht wieder aktiviert — und der halbe Tag fehlt in der '
        'Auswertung.',
  ),
  DrivingQuestion(
    moduleId: 'ra2',
    question: 'Du arbeitest an diesem Tag 9,5 Stunden. Wie lang muss deine '
        'Pause mindestens sein?',
    options: [
      '30 Minuten, denn 45 Minuten gelten erst ab 10 Stunden',
      'Es genügt, mehrere kurze Pausen von je 5 bis 10 Minuten zu machen',
      '45 Minuten, weil die Arbeitszeit über 9 Stunden liegt',
    ],
    correctIndex: 2,
    explanation: 'Nach § 4 ArbZG sind bei mehr als 6 Stunden mindestens 30 '
        'Minuten und bei mehr als 9 Stunden mindestens 45 Minuten Pause '
        'vorgeschrieben — 9,5 Stunden liegen über der Grenze. Die Pause '
        'darf aufgeteilt werden, aber jeder Teil muss mindestens 15 '
        'Minuten dauern; fünf Minuten zwischendurch zählen nicht mit.',
  ),

  // ══════════════════════════ ra3 — Der zweite Tag
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Ein Kunde mit einem Passwort-Paket hat den Code nicht zur '
        'Hand, will aber unterschreiben. Was tust du?',
    options: [
      'Du übergibst nicht — ohne korrekten Code gibt es keine Ausnahme',
      'Du übergibst gegen Unterschrift, denn die ist genauso ein Nachweis',
      'Du legst das Paket beim Nachbarn ab und informierst den Kunden',
    ],
    correctIndex: 0,
    explanation: 'Das Passwort ist der Nachweis, dass der Empfänger wirklich '
        'der Empfänger ist — dafür wurde es vergeben. Eine Unterschrift '
        'oder gutes Zureden ersetzen es nicht, und eine Nachbarabgabe '
        'schon gar nicht. Wird die Sendung später als nicht erhalten '
        'gemeldet, steht die Übergabe ohne Code als dein Fehler da. '
        'Richtig ist: Code suchen lassen, sonst Paket korrekt '
        'zurückführen und dokumentieren.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Beim Rangieren streifst du einen Poller. Es bleibt ein '
        'Kratzer am Transporter, niemand hat es gesehen. Was ist richtig?',
    options: [
      'Nichts unternehmen — bei einem Kratzer ohne Fremdschaden gibt es '
          'nichts zu melden',
      'Erst abwarten, ob es bei der nächsten Inspektion überhaupt auffällt',
      'Noch am selben Tag melden und in CoDriver dokumentieren',
    ],
    correctIndex: 2,
    explanation: 'Ein gemeldeter Schaden ist ein Vorfall, der bearbeitet '
        'wird; derselbe Schaden, den am nächsten Morgen jemand anders bei '
        'seiner Inspektion findet, ist ein ungeklärter Schaden — und der '
        'Verdacht richtet sich am Ende doch auf den letzten Nutzer. Der '
        'Irrtum „das fällt nicht auf" trägt nicht: Genau dafür gibt es die '
        'Inspektion vor und nach jeder Tour.',
  ),
  DrivingQuestion(
    moduleId: 'ra3',
    question: 'Was ist der Unterschied zwischen Leistung und Qualität in '
        'der Scorecard?',
    options: [
      'Beides meint dasselbe — die Scorecard misst nur die Zahl der '
          'Stopps',
      'Leistung ist die Menge in der Zeit, Qualität ist, wie sauber jeder '
          'einzelne Stopp abgeschlossen wurde',
      'Qualität betrifft nur das Fahrzeug, Leistung nur die Zustellung',
    ],
    correctIndex: 1,
    explanation: 'Leistung ist die Menge — wie viele Stopps in welcher Zeit. '
        'Qualität ist die Sorgfalt an jedem einzelnen Stopp: richtiger '
        'Ort, korrekte Dokumentation, keine Reklamation. Wer beides '
        'gleichsetzt, spart vorne eine Minute und erzeugt hinten eine '
        'Nachforschung, die den Betrieb ein Vielfaches kostet.',
  ),

  // ══════════════════════════ ra4 — Abschluss und Abgabe
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Wie oft unterschreibt der Trainer die Ride-Along-'
        'Checkliste?',
    options: [
      'Einmal am Ende des zweiten Tages für beide Tage zusammen',
      'Gar nicht — es unterschreibt nur der Dispatcher bei der Abgabe',
      'Je Tag einzeln, jeweils mit Datum',
    ],
    correctIndex: 2,
    explanation: 'Jeder Tag hat seine eigene Punkteliste und wird deshalb '
        'einzeln mit Datum und Unterschrift abgeschlossen. Das hat einen '
        'praktischen Grund: Fällt der zweite Tag aus oder wird er '
        'verschoben, ist trotzdem sauber dokumentiert, was am ersten Tag '
        'erledigt wurde. Eine Sammelunterschrift am Ende würde genau das '
        'unmöglich machen.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Was passiert mit der ausgefüllten Checkliste am Ende des '
        'zweiten Tages?',
    options: [
      'Sie wird als Foto beim zuständigen Dispatcher abgegeben',
      'Du nimmst sie mit nach Hause und bewahrst sie privat auf',
      'Sie bleibt im Fahrzeug, damit der nächste Trainer sie fortführt',
    ],
    correctIndex: 0,
    explanation: 'Das Blatt wird am Ende des zweiten Tages fotografiert und '
        'beim zuständigen Dispatcher abgegeben — damit ist der Ride Along '
        'formal abgeschlossen und deine Einarbeitung dokumentiert. Im '
        'Fahrzeug oder privat zu Hause ist der Nachweis für den Betrieb '
        'wertlos. Achte darauf, dass Häkchen, Datum, Namen und '
        'Unterschriften auf dem Foto lesbar sind.',
  ),
  DrivingQuestion(
    moduleId: 'ra4',
    question: 'Im Feedback heißt es, du seist beim Rangieren zu zögerlich. '
        'Wie reagierst du am sinnvollsten?',
    options: [
      'Erklären, dass du bewusst vorsichtig warst, und das Thema damit '
          'beenden',
      'Nach einem konkreten Beispiel aus dem Tag fragen',
      'Das Feedback zur Kenntnis nehmen und beim nächsten Mal schneller '
          'rangieren',
    ],
    correctIndex: 1,
    explanation: 'Vorsicht beim Rangieren ist richtig — „zögerlich" meint in '
        'aller Regel etwas anderes, etwa langes Überlegen statt kurz '
        'auszusteigen und zu schauen. Mit einem konkreten Beispiel hast '
        'du einen Punkt, an dem du arbeiten kannst. Sich zu rechtfertigen '
        'bringt nichts, und einfach schneller zu rangieren wäre die '
        'gefährlichste der drei Reaktionen.',
  ),

  // ══════════════════════════ ra5 — So bereitest du dich vor
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Wann solltest du prüfen, ob deine Zugänge zu Zeiterfassung, '
        'Mentor, Flex und CoDriver funktionieren?',
    options: [
      'Am Morgen des ersten Tages gemeinsam mit dem Trainer',
      'Erst dann, wenn beim Arbeiten tatsächlich ein Problem auftritt',
      'Vor dem ersten Tag, am besten am Vorabend',
    ],
    correctIndex: 2,
    explanation: 'Ein Passwort zurückzusetzen dauert am Vorabend Minuten und '
        'am Morgen in der Waiting Area eine halbe Stunde — wenn überhaupt '
        'jemand erreichbar ist. Der naheliegende Irrtum ist, das dem '
        'Trainer zu überlassen: Er kann dir bei einem gesperrten Zugang '
        'nicht helfen, und die Zeit fehlt dann bei den Stopps über deinen '
        'eigenen Account.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Was bedeutet „pünktlich" am Ride Along?',
    options: [
      'Einsatzbereit an der Station zum Schichtbeginn — Parken und Weg '
          'sind schon eingerechnet',
      'Zum Schichtbeginn am Tor der Station ankommen',
      'Spätestens dann da sein, wenn die Waiting Area aufgerufen wird',
    ],
    correctIndex: 0,
    explanation: 'Zum Schichtbeginn bist du einsatzbereit, nicht auf dem Weg. '
        'Wer erst am Tor ankommt, verliert Zeit beim Parken und beim Weg '
        'über den Hof und verpasst sein Waiting-Area-Fenster — und '
        'verschiebt damit auch die Welle des Trainers. Plane die Zeit zum '
        'Parken und Laufen deshalb bewusst ein.',
  ),
  DrivingQuestion(
    moduleId: 'ra5',
    question: 'Warum lohnt es sich, die Fragen an den Trainer schon vor '
        'Tag 1 aufzuschreiben?',
    options: [
      'Weil der Trainer die Fragen vorher schriftlich einreichen lassen '
          'muss',
      'Weil zehn nacheinander erklärte Abläufe niemand behält — '
          'aufgeschrieben fragst du gezielt nach',
      'Weil ungestellte Fragen sonst in der Bewertung negativ vermerkt '
          'werden',
    ],
    correctIndex: 1,
    explanation: 'Der Trainer erklärt an zwei Tagen sehr viel auf einmal; am '
        'Abend bleibt davon ohne Notizen wenig übrig. Wer seine Fragen '
        'vorbereitet und unterwegs zwei Stichworte je Thema mitschreibt, '
        'holt aus den zwei Tagen ein Vielfaches heraus. Eine formale '
        'Pflicht ist es nicht — und niemand vermerkt ungestellte Fragen '
        'negativ. Genau deshalb musst du selbst dafür sorgen.',
  ),
];
