// lib/data/safety_training/privacy_quiz_de.dart
//
// Fragen des Abschlusstests der Datenschutz-Schulung. Achtzehn Fragen,
// gleichmäßig verteilt auf die sechs Kapitel aus privacy_content_de.dart
// (je drei Fragen pro Kapitel ds1 … ds6).
//
// Anspruch der Fragen: Szenarien aus dem Zustellalltag und
// Rechtsfolgefragen. Mehrere Optionen klingen bewusst plausibel — es
// kommt jeweils auf ein Detail an. Die `explanation` erklärt immer
// beides: warum die richtige Antwort richtig ist und warum der
// naheliegende Irrtum falsch ist.

import 'driving_safety_quiz_de.dart';

const List<DrivingQuestion> privacyQuestionsDe = [
  // ══════════════════════════ ds1 — Warum Datenschutz dich betrifft
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Welche der folgenden Angaben ist KEINE personenbezogene '
        'Angabe im Sinne der DSGVO?',
    options: [
      'Die Gesamtzahl der heute auf der Tour zugestellten Pakete',
      'Der Hinweis „Paket bitte hinter die Mülltonne stellen" mit '
          'zugehöriger Adresse',
      'Das Ablieferungsfoto vor der Haustür eines Empfängers',
    ],
    correctIndex: 0,
    explanation: 'Eine reine Stückzahl ohne Bezug zu einer Person ist '
        'nicht personenbezogen. Der Ablagehinweis dagegen sagt etwas über '
        'die Wohnsituation eines bestimmten Menschen aus, und das '
        'Ablieferungsfoto ist einer Adresse zugeordnet. Der naheliegende '
        'Irrtum ist, nur Namen für personenbezogen zu halten — '
        'personenbezogen ist jede Angabe, mit der sich eine Person '
        'bestimmen lässt.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Du erzählst abends im Freundeskreis, in welcher Straße ein '
        'bekannter Sportler wohnt, dessen Paket du zugestellt hast. Wie '
        'ist das zu bewerten?',
    options: [
      'Unproblematisch, solange du den Namen nicht ins Internet stellst',
      'Ein Verstoß gegen Zweckbindung und Vertraulichkeit nach Art. 5 '
          'DSGVO',
      'Unproblematisch, weil eine Adresse ohnehin öffentlich bekannt ist',
    ],
    correctIndex: 1,
    explanation: 'Du kennst die Adresse ausschließlich aus deiner Arbeit. '
        'Sie an Dritte weiterzugeben, ist eine zweckwidrige Offenlegung '
        'und verstößt gegen Art. 5 Abs. 1 lit. b und lit. f DSGVO. Der '
        'naheliegende Irrtum ist, dass ein kleiner privater Kreis nicht '
        'zählt — die DSGVO fragt nicht nach der Größe des Publikums.',
  ),
  DrivingQuestion(
    moduleId: 'ds1',
    question: 'Aus welchen Vorschriften folgt, dass das Unternehmen dich '
        'im Datenschutz schulen muss?',
    options: [
      'Aus § 12 Abs. 1 Arbeitsschutzgesetz — Datenschutz ist Teil der '
          'jährlichen Sicherheitsunterweisung',
      'Aus einer ausdrücklichen Schulungspflicht in Art. 30 DSGVO',
      'Mittelbar aus Art. 32, Art. 39 Abs. 1 lit. b und Art. 5 Abs. 2 '
          'DSGVO',
    ],
    correctIndex: 2,
    explanation: 'Die DSGVO kennt keine ausdrückliche Schulungspflicht. '
        'Sie ergibt sich mittelbar: Art. 32 verlangt organisatorische '
        'Maßnahmen, Art. 39 Abs. 1 lit. b nennt Sensibilisierung und '
        'Schulung als Aufgabe des Datenschutzbeauftragten, und Art. 5 '
        'Abs. 2 verlangt den Nachweis der Einhaltung. Art. 30 betrifft '
        'dagegen das Verzeichnis von Verarbeitungstätigkeiten, und das '
        'ArbSchG regelt den Arbeitsschutz, nicht den Datenschutz.',
  ),

  // ══════════════════════════ ds2 — Fotos und Ablieferungsnachweise
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Was darf auf einem Ablieferungsfoto zu sehen sein?',
    options: [
      'Der Empfänger, wenn er der Aufnahme mündlich zugestimmt hat',
      'Das Paket am Ablageort, dazu Tür oder Hausnummer als Ortsbezug',
      'Das Paket und das Kennzeichen des davor parkenden Fahrzeugs zur '
          'besseren Zuordnung',
    ],
    correctIndex: 1,
    explanation: 'Das Foto beantwortet genau eine Frage: Wo liegt das '
        'Paket? Alles darüber hinaus verstößt gegen die Datenminimierung '
        'nach Art. 5 Abs. 1 lit. c DSGVO. Personen gehören auch mit '
        'mündlichem Einverständnis nicht auf den Nachweis, und ein '
        'Kennzeichen ist eine personenbezogene Angabe, die für den Zweck '
        'nicht erforderlich ist.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Der Scanner streikt. Du fotografierst die Ablage mit deiner '
        'normalen Handy-Kamera und lädst das Bild danach in die '
        'dienstliche App. Was ist daran falsch?',
    options: [
      'Nichts — entscheidend ist nur, dass das Bild am Ende in der App '
          'liegt',
      'Nur die Bildqualität, rechtlich ist es unbedenklich',
      'Das Bild liegt danach dauerhaft in der privaten Galerie, oft '
          'zusätzlich in einer privaten Cloud',
    ],
    correctIndex: 2,
    explanation: 'Der Upload beseitigt die Kopie nicht: Das Original '
        'bleibt in der privaten Galerie und wird häufig automatisch in '
        'eine Cloud gesichert. Damit liegen personenbezogene Daten '
        'außerhalb der Kontrolle des Betriebs. Der naheliegende Irrtum '
        'ist, dass nur der Endzustand zählt — entscheidend ist jede '
        'Kopie, die unterwegs entsteht.',
  ),
  DrivingQuestion(
    moduleId: 'ds2',
    question: 'Dir fällt nach dem Abschließen des Stopps auf, dass auf '
        'dem hochgeladenen Foto eine Nachbarin erkennbar ist. Was tust '
        'du?',
    options: [
      'Dispatcher oder Betriebsleitung informieren, damit das Bild im '
          'System gelöscht wird',
      'Nichts — der Stopp ist abgeschlossen, das Bild lässt sich ohnehin '
          'nicht mehr ändern',
      'Am nächsten Tag bei der Nachbarin klingeln und um Erlaubnis bitten',
    ],
    correctIndex: 0,
    explanation: 'Nur wenn der Betrieb davon weiß, kann er das Bild '
        'löschen und den Vorgang dokumentieren. Der naheliegende Irrtum '
        'ist, dass sich eine Meldung nach Abschluss des Stopps nicht mehr '
        'lohnt. Eine nachträgliche Einwilligung heilt den Verstoß nicht '
        'und ist zudem keine tragfähige Rechtsgrundlage im '
        'Beschäftigungskontext.',
  ),

  // ══════════════════════════ ds3 — Umgang mit Empfängerdaten
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Du machst einen Screenshot der Adressliste, um dir die '
        'Reihenfolge besser merken zu können. Niemand sonst bekommt ihn '
        'zu sehen. Ist das zulässig?',
    options: [
      'Ja, solange du den Screenshot am Ende der Tour wieder löschst',
      'Ja, weil du die Daten ohnehin dienstlich verarbeiten darfst',
      'Nein — ein Screenshot ist eine Kopie außerhalb des Systems und '
          'damit unzulässig',
    ],
    correctIndex: 2,
    explanation: 'Mit dem Screenshot entsteht eine Kopie personenbezogener '
        'Daten, die der Betrieb nicht mehr kontrollieren kann. Dass du '
        'die Daten dienstlich sehen darfst, erlaubt dir nicht, sie '
        'außerhalb des Systems zu speichern. Auch das Vorhaben, später zu '
        'löschen, ändert nichts an der unzulässigen Verarbeitung.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Ein Nachbar nimmt ein Paket an und fragt, was darin ist und '
        'ob der Empfänger überhaupt noch dort wohnt. Was sagst du?',
    options: [
      'Nur Empfängername und Hausnummer — zum Inhalt und zu weiteren '
          'Angaben keine Auskunft',
      'Alles, was auf dem Etikett steht, denn er nimmt das Paket ja '
          'entgegen',
      'Nichts, auch nicht den Namen des Empfängers',
    ],
    correctIndex: 0,
    explanation: 'Für die Nachbarschaftsabgabe sind Name und Hausnummer '
        'erforderlich — ohne sie kann der Nachbar das Paket nicht '
        'weitergeben. Alles darüber hinaus, insbesondere der Inhalt oder '
        'die Bestätigung von Wohnverhältnissen, ist eine Offenlegung ohne '
        'Rechtsgrundlage nach Art. 6 DSGVO. Gar nichts zu sagen wäre '
        'dagegen praxisfern und für die Abgabe nicht durchführbar.',
  ),
  DrivingQuestion(
    moduleId: 'ds3',
    question: 'Die Tour ist beendet, die Papier-Tourenliste wird nicht '
        'mehr gebraucht. Wie entsorgst du sie richtig?',
    options: [
      'In der Papiertonne am eigenen Wohnhaus, sobald du zu Hause bist',
      'Über den im Betrieb vorgesehenen Weg — Datenschutzbehälter oder '
          'Aktenvernichter',
      'Zerrissen im Restmüll an der Tankstelle, damit sie niemand mehr '
          'lesen kann',
    ],
    correctIndex: 1,
    explanation: 'Auf der Liste stehen Namen und Anschriften; sie muss so '
        'entsorgt werden, dass sie nicht wiederherstellbar ist — im '
        'Betrieb über Datenschutzbehälter oder Aktenvernichter. Der '
        'naheliegende Irrtum ist, dass eine erledigte Liste wertlos sei. '
        'Öffentlich zugängliche Tonnen scheiden aus, und mit nach Hause '
        'hättest du die Liste ohnehin nicht nehmen dürfen.',
  ),

  // ══════════════════════════ ds4 — Eigene Daten und Kollegendaten
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Ein Kollege bittet dich um einen Screenshot einer '
        'internen Auswertung, auf der alle Fahrer mit Namen und Werten '
        'stehen. Er will nur seine eigene Zeile sehen. Wie reagierst du?',
    options: [
      'Ablehnen und ihn an die Betriebsleitung verweisen — er hat nur '
          'Anspruch auf seine eigenen Daten',
      'Schicken, weil er auf der Liste selbst steht und deshalb '
          'zugriffsberechtigt ist',
      'Schicken, aber vorher die Namen der anderen unkenntlich machen '
          'und danach den Screenshot löschen',
    ],
    correctIndex: 0,
    explanation: 'Mit dem Screenshot bekäme er die Leistungsdaten aller '
        'Kollegen — eine Weitergabe von Beschäftigtendaten ohne '
        'Rechtsgrundlage. Sein Auskunftsrecht nach Art. 15 DSGVO bezieht '
        'sich ausschließlich auf seine eigenen Daten. Auch eine '
        'selbstgebastelte Schwärzung ändert nichts daran, dass du eine '
        'unzulässige Kopie erstellt hast.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Warum sind Krankmeldungen von Kollegen besonders '
        'geschützt?',
    options: [
      'Weil sie im Arbeitsvertrag ausdrücklich als vertraulich bezeichnet '
          'werden',
      'Weil sie Betriebsgeheimnisse nach dem GeschGehG sind',
      'Weil Gesundheitsdaten besondere Kategorien personenbezogener Daten '
          'nach Art. 9 DSGVO sind',
    ],
    correctIndex: 2,
    explanation: 'Gesundheitsdaten fallen unter Art. 9 DSGVO und '
        'unterliegen einem strengeren Schutz als gewöhnliche Daten. Schon '
        'die Tatsache der Erkrankung ist eine solche Angabe, der Grund '
        'erst recht. Betriebsgeheimnisse betreffen dagegen '
        'Unternehmenswissen, nicht Gesundheitsdaten von Beschäftigten.',
  ),
  DrivingQuestion(
    moduleId: 'ds4',
    question: 'Du möchtest wissen, welche Daten dein Arbeitgeber über dich '
        'gespeichert hat. Welches Recht nutzt du dafür?',
    options: [
      'Das Recht auf Datenübertragbarkeit nach Art. 20 DSGVO',
      'Das Auskunftsrecht nach Art. 15 DSGVO',
      'Das Widerspruchsrecht nach Art. 21 DSGVO',
    ],
    correctIndex: 1,
    explanation: 'Art. 15 DSGVO gibt dir Anspruch auf eine Übersicht der '
        'zu deiner Person gespeicherten Daten und der Zwecke. Art. 20 '
        'betrifft die Herausgabe in einem übertragbaren Format, Art. 21 '
        'den Widerspruch gegen eine Verarbeitung — beides beantwortet '
        'nicht die Frage, was überhaupt gespeichert ist. Die Anfrage muss '
        'grundsätzlich binnen eines Monats beantwortet werden.',
  ),

  // ══════════════════════════ ds5 — Datenpanne
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Welcher dieser Vorfälle ist KEINE Datenpanne?',
    options: [
      'Du hast ein Paket beim falschen Empfänger abgegeben, der es '
          'geöffnet hat',
      'Du hast dich bei der Zahl der Retouren im Tagesbericht verzählt',
      'Du hast die Tourenliste im unverschlossenen Fahrzeug offen liegen '
          'gelassen',
    ],
    correctIndex: 1,
    explanation: 'Ein Zählfehler bei Retouren betrifft keine '
        'personenbezogenen Daten und macht sie niemandem zugänglich. In '
        'den beiden anderen Fällen konnten Unbefugte Namen, Anschriften '
        'oder Sendungsinhalte zur Kenntnis nehmen — das ist eine '
        'Verletzung des Schutzes personenbezogener Daten.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Was besagt die 72-Stunden-Frist aus Art. 33 DSGVO?',
    options: [
      'Das Unternehmen muss eine Datenpanne möglichst binnen 72 Stunden '
          'nach Bekanntwerden der Aufsichtsbehörde melden',
      'Der Fahrer hat 72 Stunden Zeit, den Vorfall im Betrieb zu melden',
      'Betroffene müssen sich binnen 72 Stunden beim Unternehmen '
          'beschweren, sonst verfällt ihr Anspruch',
    ],
    correctIndex: 0,
    explanation: 'Die Frist bindet das Unternehmen gegenüber der '
        'Aufsichtsbehörde und läuft ab dem Bekanntwerden. Genau deshalb '
        'musst du sofort melden — jede Stunde, die du zuwartest, fehlt '
        'dem Betrieb. Der naheliegende Irrtum ist, die 72 Stunden als '
        'eigenes Zeitfenster für den Fahrer zu lesen.',
  ),
  DrivingQuestion(
    moduleId: 'ds5',
    question: 'Du hast am Abend gemerkt, dass ein Paket beim falschen '
        'Empfänger gelandet ist und dort geöffnet wurde. Was ist richtig?',
    options: [
      'Morgen früh unauffällig abholen und richtig zustellen — dann ist '
          'der Fehler behoben',
      'Erst beim nächsten Dienstgespräch erwähnen, weil ohnehin nichts '
          'mehr zu ändern ist',
      'Noch am selben Tag Dispatcher oder Betriebsleitung informieren und '
          'nichts auf eigene Faust unternehmen',
    ],
    correctIndex: 2,
    explanation: 'Es liegt bereits eine Datenpanne vor: Eine fremde Person '
        'hat Name, Anschrift und Sendungsinhalt erfahren. Der Betrieb '
        'muss bewerten, dokumentieren und gegebenenfalls nach Art. 33 '
        'DSGVO melden — dafür braucht er die Information sofort. Die '
        'stille Korrektur wirkt harmlos, verhindert aber genau diese '
        'Schritte. Wer sofort meldet, handelt richtig.',
  ),

  // ══════════════════════════ ds6 — Verschwiegenheit und Loyalität
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Welche Äußerung ist von der Meinungsfreiheit NICHT gedeckt?',
    options: [
      'Die Aussage, eine Tour sei regelmäßig nicht in der geplanten Zeit '
          'zu schaffen',
      'Der Hinweis, ein Fahrzeug sei trotz mehrfacher Meldung nicht '
          'repariert worden',
      'Die bewusst unwahre Behauptung, die Firma betrüge ihre Fahrer '
          'systematisch bei den Stunden',
    ],
    correctIndex: 2,
    explanation: 'Meinungsäußerungen und wahrheitsgemäße Kritik sind durch '
        'Art. 5 Abs. 1 GG geschützt, auch wenn sie unbequem sind. '
        'Bewusst unwahre Tatsachenbehauptungen sind es nicht: Sie können '
        'eine fristlose Kündigung nach § 626 BGB rechtfertigen und bei '
        'übler Nachrede zusätzlich nach § 186 StGB strafbar sein.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'Du meldest nach bestem Wissen einen Missstand im Betrieb. '
        'Am Ende stellt sich heraus, dass dein Verdacht nicht zutraf. Was '
        'gilt?',
    options: [
      'Der Schutz entfällt rückwirkend, weil die Meldung falsch war',
      'Du bleibst durch das Hinweisgeberschutzgesetz vor Repressalien '
          'geschützt',
      'Der Schutz gilt nur, wenn du die Meldung zusätzlich extern '
          'eingereicht hast',
    ],
    correctIndex: 1,
    explanation: 'Das HinSchG (seit 2. Juli 2023) schützt Beschäftigte, '
        'die Verstöße melden, vor Repressalien wie Kündigung, Abmahnung '
        'oder Benachteiligung. Der Schutz entfällt nur bei wissentlich '
        'oder grob fahrlässig unrichtigen Meldungen — nicht bei einem '
        'ernsthaften Verdacht, der sich am Ende nicht bestätigt. Eine '
        'externe Meldung ist dafür nicht erforderlich.',
  ),
  DrivingQuestion(
    moduleId: 'ds6',
    question: 'In der Fahrer-Chatgruppe wird über angebliche '
        'Lohnkürzungen diskutiert. Du bist selbst unzufrieden. Was ist '
        'der richtige Weg?',
    options: [
      'Den eigenen, konkreten Fall benennen und ihn an Dispatcher, '
          'Betriebsleitung oder die interne Meldestelle geben',
      'Die Behauptung in der Gruppe bestätigen, damit die Kollegen '
          'gewarnt sind',
      'Den Vorwurf öffentlich in einem Bewertungsportal posten, damit '
          'sich etwas bewegt',
    ],
    correctIndex: 0,
    explanation: 'Der eigene, überprüfbare Fall ist wahr, sachlich und '
        'über das HinSchG geschützt — und intern am schnellsten lösbar. '
        'Eine Behauptung zu bestätigen, die du selbst nicht erlebt hast, '
        'ist eine unwahre Tatsachenbehauptung; eine geschlossene '
        'Chatgruppe ist dabei kein geschützter Raum, sobald ein '
        'Screenshot herumgeht. Der Gang nach außen kommt erst in '
        'Betracht, wenn intern nichts passiert.',
  ),
];
