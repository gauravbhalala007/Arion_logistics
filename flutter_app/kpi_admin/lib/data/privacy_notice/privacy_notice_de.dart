// lib/data/privacy_notice/privacy_notice_de.dart
//
// Datenschutzinformation für Fahrer nach Art. 13 DSGVO — deutsche
// Fassung (Master). Alle anderen Sprachen fallen derzeit hierauf
// zurück (siehe `privacy_notice_content.dart`).
//
// Quellen für die Abschnitte zur Zeiterfassung:
//   docs/datenschutz-zeiterfassung.md  (§ X, Buchstaben a bis j)
//   docs/dsfa-zeiterfassung.md         (Folgenabschätzung, Abschnitt 2.2)
// Die dortigen Kernaussagen sind hier in Du-Ansprache übernommen, nicht
// neu erfunden — insbesondere: keine Roh-GPS-Koordinaten, kein
// Hintergrund-Tracking, gespeichert wird nur das Ergebnis des
// Geofence-Checks.
//
// Speicherdauern sind nur dort mit Zahlen angegeben, wo sie belegt sind
// (Zeiterfassung: § 16 Abs. 2 ArbZG, § 147 AO). Überall sonst steht
// bewusst „für die Dauer des Beschäftigungsverhältnisses und die
// gesetzlichen Aufbewahrungsfristen".

import '../safety_training/safety_blocks.dart';
import 'privacy_notice_content.dart';

const List<PrivacyNoticeSection> privacyNoticeSectionsDe = [
  // ══════════════════════════════════════════════════════════════ 1
  PrivacyNoticeSection(
    id: 'verantwortlich',
    title: 'Wer deine Daten verarbeitet',
    summary: 'Verantwortlicher, Auftragsverarbeiter und wo die Daten '
        'liegen',
    blocks: [
      ParagraphBlock(
        'Damit du in CoDriver arbeiten kannst, werden Daten über dich '
        'verarbeitet. Nach Art. 13 DSGVO hast du das Recht, von Anfang '
        'an zu wissen, welche das sind, wozu sie verarbeitet werden, '
        'worauf sich das stützt und wie lange sie gespeichert bleiben. '
        'Genau das steht auf den folgenden Seiten.',
      ),
      SubheadBlock('Verantwortlich'),
      ParagraphBlock(
        'Verantwortlich für deine Daten ist dein Arbeitgeber — der '
        'Delivery Service Partner (DSP), bei dem du angestellt bist. '
        'Sein Name steht oben auf dieser Seite. An ihn richtest du alle '
        'Anliegen rund um deine Daten; hat er eine oder einen '
        'Datenschutzbeauftragten benannt, kannst du dich direkt dorthin '
        'wenden.',
      ),
      SubheadBlock('Wer die Software betreibt'),
      ParagraphBlock(
        'CoDriver wird von der ARION Logistics GmbH bereitgestellt. Sie '
        'verarbeitet deine Daten ausschließlich im Auftrag und nach '
        'Weisung deines Arbeitgebers — als Auftragsverarbeiterin nach '
        'Art. 28 DSGVO, auf Grundlage eines Vertrags zur '
        'Auftragsverarbeitung. Eigene Zwecke verfolgt sie mit deinen '
        'Daten nicht.',
      ),
      SubheadBlock('Wo die Daten gespeichert sind'),
      ParagraphBlock(
        'Die Daten liegen bei Google Firebase in der Europäischen Union '
        '(Firestore-Region eur3, Rechenzentren Frankfurt und Belgien; '
        'Cloud Functions in europe-west3, Frankfurt). Sie sind auf dem '
        'Transportweg und im Speicher verschlüsselt. Eine Übermittlung '
        'in ein Drittland außerhalb der EU findet nicht statt.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Das ist eine Information — keine Erlaubnis, die du erteilst',
        text: 'Du wirst hier informiert. Deine Unterschrift am Ende '
            'bestätigt ausschließlich, dass du diese Information '
            'gelesen und verstanden hast. Ob deine Daten verarbeitet '
            'werden dürfen, hängt nicht von deiner Unterschrift ab, '
            'sondern von den Rechtsgrundlagen, die bei jedem Abschnitt '
            'genannt sind. Warum das so ist, steht im letzten '
            'Abschnitt.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 2
  PrivacyNoticeSection(
    id: 'stammdaten',
    title: 'Deine Stammdaten',
    summary: 'Name, Personalnummer, Transporter-ID und Kontaktdaten',
    blocks: [
      ParagraphBlock(
        'Ohne ein Fahrerprofil kann dich niemand einplanen, dir eine '
        'Schicht zuweisen oder dich erreichen. Dein Profil ist die '
        'Grundlage für alles Weitere in der App.',
      ),
      SubheadBlock('Welche Daten'),
      BulletsBlock([
        'Vor- und Nachname',
        'Transporter-ID — deine Kennung im Amazon-System und '
            'gleichzeitig dein Schlüssel in CoDriver',
        'Personalnummer, sofern dein Arbeitgeber eine vergeben hat',
        'Geschäftliche E-Mail-Adresse — sie ist zugleich dein Login',
        'Telefonnummer für die Erreichbarkeit im Einsatz',
        'Geburtsdatum und Staatsangehörigkeit, soweit sie im Onboarding '
            'oder aus deiner Bewerbung übernommen wurden',
        'Profilfoto, wenn du eines hinterlegst',
        'Gewählte App-Sprache',
        'Status deines Beschäftigungsverhältnisses (aktiv, inaktiv, '
            'ausgeschieden)',
      ]),
      SubheadBlock('Wozu'),
      ParagraphBlock(
        'Zur eindeutigen Zuordnung deiner Person zu Schichten, Fahrzeugen, '
        'Zeiten und Nachweisen, zur Kommunikation zwischen dir und der '
        'Disposition und zur Verwaltung deines Zugangs zur App.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Rechtsgrundlage',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (Durchführung deines '
            'Arbeitsvertrags) in Verbindung mit § 26 Abs. 1 BDSG '
            '(Datenverarbeitung für Zwecke des '
            'Beschäftigungsverhältnisses).',
      ),
      SubheadBlock('Wie lange'),
      ParagraphBlock(
        'Für die Dauer des Beschäftigungsverhältnisses und die '
        'gesetzlichen Aufbewahrungsfristen. Danach wird dein Profil '
        'gelöscht oder gesperrt.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 3
  PrivacyNoticeSection(
    id: 'zeiterfassung',
    title: 'Zeiterfassung und Standortprüfung',
    summary: 'Stempeln mit Geofence-Check — und was dabei ausdrücklich '
        'nicht gespeichert wird',
    blocks: [
      ParagraphBlock(
        'Dein Arbeitgeber ist gesetzlich verpflichtet, deine Arbeitszeit '
        'objektiv, verlässlich und zugänglich aufzuzeichnen — so steht '
        'es in § 16 ArbZG und im Urteil des Europäischen Gerichtshofs '
        'C-55/18. Wenn du in CoDriver stempelst („Schicht beginnen", '
        '„Pause", „Schicht beenden"), prüft die App, ob sich dein Gerät '
        'am vereinbarten Einsatzort befindet.',
      ),
      SubheadBlock('Welche Daten bei jedem Stempeln'),
      BulletsBlock([
        'Zeitpunkt als Server-Zeitstempel',
        'Deine Transporter-ID',
        'Ob du die Standort-Erlaubnis auf deinem Gerät erteilt hast',
        'Ergebnis des Geofence-Checks: innerhalb oder außerhalb des '
            'Hub-Bereichs',
        'Kennung des Hub-Bereichs, z. B. „DBY5_main"',
        'Genauigkeit der Standortbestimmung in Metern',
        'Hub-ID und Versionsnummer des gescannten QR-Codes',
        'Geräteplattform und App-Version',
        'Deine IP-Adresse, gespeichert nur als SHA-256-Hashwert, nie im '
            'Klartext',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Was ausdrücklich NICHT gespeichert wird',
        text: 'Deine genauen GPS-Koordinaten werden nicht gespeichert. '
            'Sie werden im Moment des Stempelns einmalig an den Server '
            'übertragen, dort für den Geofence-Check ausgewertet und '
            'dann verworfen. Übrig bleibt nur die Antwort „war im '
            'Hub-Bereich / war nicht im Hub-Bereich". Es gibt kein '
            'Standort-Tracking im Hintergrund und kein Bewegungsprofil '
            'zwischen zwei Stempelvorgängen.',
      ),
      SubheadBlock('Wozu'),
      BulletsBlock([
        'Rechtssichere Dokumentation deiner Arbeitszeit nach § 16 ArbZG',
        'Korrekte Abrechnung von Lohn und Sozialversicherung',
        'Schutz vor Manipulation beim Stempeln',
      ]),
      SubheadBlock('Standort-Erlaubnis ist freiwillig'),
      ParagraphBlock(
        'Ob du deinem Gerät die Standort-Erlaubnis gibst, entscheidest '
        'du selbst und kannst es jederzeit in den Geräte-Einstellungen '
        'ändern. Ohne Standort-Erlaubnis kannst du trotzdem stempeln — '
        'der Vorgang wird dann als „Standort nicht bestätigt" markiert '
        'und von der Disposition manuell geprüft. Arbeitsrechtliche '
        'Nachteile entstehen dir daraus nicht.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Rechtsgrundlage',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (Durchführung des '
            'Arbeitsvertrags), Art. 6 Abs. 1 lit. c DSGVO (rechtliche '
            'Verpflichtung aus § 16 ArbZG), Art. 6 Abs. 1 lit. f DSGVO '
            '(berechtigtes Interesse an der Verhinderung von '
            'Manipulation) und § 26 BDSG.',
      ),
      SubheadBlock('Wie lange'),
      TableBlock(
        headers: ['Daten', 'Aufbewahrung', 'Grundlage'],
        rows: [
          ['Einzelne Zeitbuchungen', '2 Jahre', '§ 16 Abs. 2 ArbZG'],
          ['Monatswerte (Soll/Ist/Saldo)', '6 Jahre', '§ 147 AO'],
          ['Änderungsprotokoll', '2 Jahre', 'Nachvollziehbarkeit'],
          ['Korrekturanträge', '2 Jahre', 'Nachvollziehbarkeit'],
        ],
      ),
      SubheadBlock('Keine automatische Entscheidung über dich'),
      ParagraphBlock(
        'Eine automatisierte Entscheidung mit rechtlicher Wirkung nach '
        'Art. 22 DSGVO findet nicht statt. Hinweise der App, etwa zu '
        'einer überschrittenen Pause, sind rein informativ; über Folgen '
        'entscheidet immer ein Mensch. Vor Einführung der Zeiterfassung '
        'wurde eine Datenschutz-Folgenabschätzung nach Art. 35 DSGVO '
        'durchgeführt; das verbleibende Risiko wurde als niedrig '
        'bewertet, weil weder Roh-Koordinaten noch Bewegungsprofile '
        'gespeichert werden.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 4
  PrivacyNoticeSection(
    id: 'academy',
    title: 'DA Academy — Schulungen und Nachweise',
    summary: 'Testergebnisse, Zertifikate und deine Unterschrift darauf',
    blocks: [
      ParagraphBlock(
        'In der DA Academy absolvierst du Unterweisungen und Schulungen '
        '— zum Beispiel die Sicherheitsunterweisung, das Green Book, '
        'die Datenschutz-Schulung oder Betriebsanweisungen. Dein '
        'Arbeitgeber muss nachweisen können, dass du unterwiesen wurdest.',
      ),
      SubheadBlock('Welche Daten'),
      BulletsBlock([
        'Welche Schulung du wann begonnen und abgeschlossen hast',
        'Ergebnis des Abschlusstests: erreichte Punktzahl, Prozentwert, '
            'bestanden oder nicht bestanden, Anzahl der Versuche',
        'Datum des Bestehens und Ablauf der Gültigkeit',
        'Sprache, in der du die Schulung bearbeitet hast',
        'Deine handschriftliche Unterschrift als Bilddatei',
        'Das daraus erzeugte Nachweis-PDF mit Name, Personalnummer, '
            'Transporter-ID, Datum und Unterschrift',
        'Bestätigungen einzelner Betriebsanweisungen und Regeln',
      ]),
      SubheadBlock('Wozu'),
      ParagraphBlock(
        'Zum Nachweis der Unterweisung gegenüber Behörden, '
        'Berufsgenossenschaft und Auftraggeber, zur Steuerung fälliger '
        'Wiederholungsschulungen und zur Erfüllung der '
        'Rechenschaftspflicht deines Arbeitgebers.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Rechtsgrundlage',
        text: 'Art. 6 Abs. 1 lit. c DSGVO (rechtliche Verpflichtung aus '
            'Arbeitsschutz- und Datenschutzrecht, u. a. § 12 ArbSchG, '
            '§ 4 DGUV Vorschrift 1, Art. 5 Abs. 2 und Art. 32 DSGVO), '
            'Art. 6 Abs. 1 lit. b DSGVO (Durchführung des '
            'Arbeitsvertrags) und § 26 BDSG.',
      ),
      SubheadBlock('Wie lange'),
      ParagraphBlock(
        'Für die Dauer des Beschäftigungsverhältnisses und die '
        'gesetzlichen Aufbewahrungsfristen. Nachweise über '
        'Unterweisungen werden mindestens so lange aufbewahrt, wie sie '
        'zum Nachweis gegenüber Behörden benötigt werden.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 5
  PrivacyNoticeSection(
    id: 'dokumente',
    title: 'Deine Dokumente',
    summary: 'Führerschein, Ausweis, Aufenthaltstitel und weitere '
        'Nachweise',
    blocks: [
      ParagraphBlock(
        'Für den Einsatz als Fahrer müssen bestimmte Nachweise vorliegen '
        'und gültig sein. Du oder die Disposition legt sie in deinem '
        'Fahrerprofil ab.',
      ),
      SubheadBlock('Welche Daten'),
      BulletsBlock([
        'Führerschein — Vorder- und Rückseite',
        'Personalausweis oder Reisepass',
        'Aufenthaltstitel und Arbeitserlaubnis, sofern erforderlich',
        'Steuer-Identifikationsnummer',
        'Nachweis der Sozialversicherung',
        'Arbeitsvertrag',
        'Ablauf- und Gültigkeitsdaten dieser Dokumente',
      ]),
      SubheadBlock('Wozu'),
      ParagraphBlock(
        'Zur Prüfung, ob du überhaupt eingesetzt werden darfst — vor '
        'allem der Führerscheinkontrolle als Halterpflicht des '
        'Arbeitgebers —, zur Erfüllung melderechtlicher, steuerlicher '
        'und sozialversicherungsrechtlicher Pflichten und zur '
        'rechtzeitigen Erinnerung, bevor ein Dokument abläuft.',
      ),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Besondere Sorgfalt',
        text: 'Ausweisdokumente enthalten sensible Angaben. Sie sind nur '
            'für dich selbst und für die Disposition deines Betriebs '
            'sichtbar, liegen verschlüsselt in der EU und werden nicht '
            'an Dritte weitergegeben, außer eine Behörde verlangt es '
            'auf gesetzlicher Grundlage.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Rechtsgrundlage',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (Durchführung des '
            'Arbeitsvertrags), Art. 6 Abs. 1 lit. c DSGVO (rechtliche '
            'Verpflichtungen, u. a. § 21 StVG Halterhaftung, '
            'Aufenthalts-, Steuer- und Sozialversicherungsrecht), '
            'Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an der '
            'Einsatzfähigkeit) und § 26 BDSG.',
      ),
      SubheadBlock('Wie lange'),
      ParagraphBlock(
        'Für die Dauer des Beschäftigungsverhältnisses und die '
        'gesetzlichen Aufbewahrungsfristen.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 6
  PrivacyNoticeSection(
    id: 'abwesenheiten',
    title: 'Abwesenheiten, Urlaub und Krankmeldungen',
    summary: 'Anträge, Genehmigungen und Arbeitsunfähigkeits-'
        'bescheinigungen',
    blocks: [
      ParagraphBlock(
        'Urlaub, Krankmeldung und andere Abwesenheiten meldest du in der '
        'App; die Disposition entscheidet darüber und plant entsprechend.',
      ),
      SubheadBlock('Welche Daten'),
      BulletsBlock([
        'Art der Abwesenheit — Urlaub, Krankheit, unbezahlte Freistellung '
            'und weitere Gründe',
        'Zeitraum von … bis und Anzahl der Tage',
        'Status: beantragt, genehmigt, abgelehnt',
        'Dein Kommentar zum Antrag und die Antwort der Disposition',
        'Dein Urlaubsanspruch und der bereits verbrauchte Anteil',
        'Hochgeladene Arbeitsunfähigkeitsbescheinigung, wenn du eine '
            'einreichst',
      ]),
      CalloutBlock(
        tone: CalloutTone.warning,
        title: 'Krankmeldungen sind besonders geschützt',
        text: 'Erfasst wird nur, DASS du arbeitsunfähig bist und für '
            'welchen Zeitraum. Eine Diagnose musst du weder angeben '
            'noch enthält die Bescheinigung für den Arbeitgeber eine. '
            'Gesundheitsdaten sind besondere Daten nach Art. 9 DSGVO '
            'und werden nur von den Personen eingesehen, die sie für '
            'Entgeltfortzahlung und Planung tatsächlich brauchen.',
      ),
      SubheadBlock('Wozu'),
      ParagraphBlock(
        'Zur Planung des Einsatzes, zur Berechnung von Urlaubsanspruch '
        'und Entgeltfortzahlung und zum Nachweis gegenüber '
        'Sozialversicherungsträgern.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Rechtsgrundlage',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (Durchführung des '
            'Arbeitsvertrags), Art. 6 Abs. 1 lit. c DSGVO (u. a. BUrlG '
            'und EntgFG) sowie für die Angaben zur Arbeitsunfähigkeit '
            'Art. 9 Abs. 2 lit. b DSGVO in Verbindung mit § 26 Abs. 3 '
            'BDSG (Ausübung von Rechten und Pflichten aus dem '
            'Arbeitsrecht und dem Recht der sozialen Sicherheit).',
      ),
      SubheadBlock('Wie lange'),
      ParagraphBlock(
        'Für die Dauer des Beschäftigungsverhältnisses und die '
        'gesetzlichen Aufbewahrungsfristen. '
        'Arbeitsunfähigkeitsbescheinigungen werden gelöscht, sobald sie '
        'für Entgeltfortzahlung und Nachweis nicht mehr benötigt werden.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 7
  PrivacyNoticeSection(
    id: 'planung',
    title: 'Schicht- und Wellenplanung',
    summary: 'Wer wann auf welcher Welle, Route und in welchem Fahrzeug '
        'fährt',
    blocks: [
      ParagraphBlock(
        'Die Disposition plant jeden Tag, wer arbeitet, in welcher Welle '
        'du startest und mit welchem Fahrzeug du unterwegs bist. Dieser '
        'Plan ist für dich und die Disposition sichtbar.',
      ),
      SubheadBlock('Welche Daten'),
      BulletsBlock([
        'Deine Einteilung je Tag — eingeplant, frei, Abwesenheit',
        'Wellenzeit und Startzeit',
        'Zugewiesene Route beziehungsweise Tour',
        'Zugewiesenes Fahrzeug mit Kennzeichen',
        'Bestätigung der Kenntnisnahme deines Plans',
        'Änderungen am Plan und wer sie vorgenommen hat',
        'Aufgaben und Mitteilungen, die dir zugewiesen sind, samt '
            'Lesebestätigung',
      ]),
      SubheadBlock('Wozu'),
      ParagraphBlock(
        'Zur Organisation des Tagesgeschäfts, zur Zuordnung von Fahrzeug '
        'und Route und zur Nachvollziehbarkeit, wer wann welche Tour '
        'gefahren ist.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Rechtsgrundlage',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (Durchführung des '
            'Arbeitsvertrags) und Art. 6 Abs. 1 lit. f DSGVO '
            '(berechtigtes Interesse an einem funktionierenden '
            'Betriebsablauf), jeweils in Verbindung mit § 26 BDSG.',
      ),
      SubheadBlock('Wie lange'),
      ParagraphBlock(
        'Für die Dauer des Beschäftigungsverhältnisses und die '
        'gesetzlichen Aufbewahrungsfristen.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 8
  PrivacyNoticeSection(
    id: 'scorecard',
    title: 'Leistungsdaten aus der Scorecard',
    summary: 'Kennzahlen zu Sicherheit, Qualität und Zustellung',
    blocks: [
      ParagraphBlock(
        'Der Auftraggeber stellt wöchentlich Kennzahlen zu deiner '
        'Zustelltätigkeit bereit. CoDriver liest diese Scorecard ein und '
        'zeigt sie dir und der Disposition an.',
      ),
      SubheadBlock('Welche Daten'),
      BulletsBlock([
        'Sicherheitskennzahlen wie FICO-Fahrscore, Geschwindigkeits-'
            'ereignisse je 100 Touren und Mentor-Nutzung',
        'Compliance-Kennzahlen wie Fahrzeugkontrolle und Einhaltung der '
            'Arbeitszeiten',
        'Qualitätskennzahlen wie Zustellquote, nicht zugestellte '
            'Sendungen und Verlustquote',
        'Kennzahlen zur Zustellqualität wie Foto als '
            'Ablieferungsnachweis und Kontakt-Compliance',
        'Kundenfeedback und Eskalationen',
        'Gesamtbewertung je Woche und deren Entwicklung',
      ]),
      SubheadBlock('Wozu'),
      ParagraphBlock(
        'Zur Erfüllung des Vertrags zwischen deinem Arbeitgeber und dem '
        'Auftraggeber, zur Erkennung von Sicherheitsrisiken, zur '
        'gezielten Schulung und zur Rückmeldung an dich.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Kein Automatismus über deinen Kopf hinweg',
        text: 'Aus einer Kennzahl folgt keine automatische Maßnahme. '
            'Bewertungen und Gespräche führt immer ein Mensch, und du '
            'kannst deine Sicht dazu darlegen. Eine automatisierte '
            'Entscheidung nach Art. 22 DSGVO findet nicht statt.',
      ),
      CalloutBlock(
        tone: CalloutTone.law,
        title: 'Rechtsgrundlage',
        text: 'Art. 6 Abs. 1 lit. b DSGVO (Durchführung des '
            'Arbeitsvertrags) und Art. 6 Abs. 1 lit. f DSGVO '
            '(berechtigtes Interesse an Verkehrssicherheit, '
            'Qualitätssicherung und Erfüllung der vertraglichen '
            'Pflichten gegenüber dem Auftraggeber), in Verbindung mit '
            '§ 26 BDSG.',
      ),
      SubheadBlock('Wie lange'),
      ParagraphBlock(
        'Für die Dauer des Beschäftigungsverhältnisses und die '
        'gesetzlichen Aufbewahrungsfristen.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 9
  PrivacyNoticeSection(
    id: 'empfaenger',
    title: 'Wer deine Daten sieht',
    summary: 'Empfänger innerhalb und außerhalb des Betriebs',
    blocks: [
      SubheadBlock('Im Betrieb'),
      BulletsBlock([
        'Die Geschäftsführung deines Arbeitgebers',
        'Die Disposition und von ihr berechtigte Dispatcher — jeweils '
            'nur für den eigenen Betrieb',
        'Du selbst: eigene Daten siehst du in der App jederzeit',
      ]),
      SubheadBlock('Außerhalb des Betriebs'),
      BulletsBlock([
        'Google Ireland/Google LLC als Hosting-Dienstleister '
            '(Auftragsverarbeitung, Server in der EU)',
        'ARION Logistics GmbH als Betreiberin von CoDriver '
            '(Auftragsverarbeitung)',
        'Steuerberatung und Lohnabrechnung, soweit dein Arbeitgeber sie '
            'einsetzt — jeweils auf Grundlage eines Vertrags zur '
            'Auftragsverarbeitung',
        'Der Auftraggeber, soweit die Scorecard-Kennzahlen ohnehin von '
            'dort stammen',
        'Behörden, Sozialversicherungsträger und Berufsgenossenschaft — '
            'nur wenn eine gesetzliche Grundlage sie dazu berechtigt',
      ]),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Nicht verkauft, nicht für Werbung genutzt',
        text: 'Deine Daten werden nicht verkauft, nicht für Werbung '
            'verwendet und nicht an Dritte weitergegeben, die sie für '
            'eigene Zwecke nutzen möchten.',
      ),
      SubheadBlock('Woher die Daten kommen'),
      ParagraphBlock(
        'Die meisten Daten stammen von dir selbst — aus deiner '
        'Bewerbung, dem Onboarding und deiner täglichen Nutzung der App. '
        'Die Scorecard-Kennzahlen stammen vom Auftraggeber, die Plan- '
        'und Schichtdaten von der Disposition.',
      ),
      SubheadBlock('Musst du die Daten angeben?'),
      ParagraphBlock(
        'Einige Angaben sind erforderlich, damit das '
        'Beschäftigungsverhältnis überhaupt durchgeführt werden kann — '
        'zum Beispiel Name, Führerschein und Arbeitszeiten. Ohne sie '
        'kannst du nicht eingesetzt werden. Andere Angaben, etwa das '
        'Profilfoto, sind freiwillig; daraus entsteht dir kein Nachteil.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 10
  PrivacyNoticeSection(
    id: 'rechte',
    title: 'Deine Rechte',
    summary: 'Auskunft, Berichtigung, Löschung, Widerspruch und '
        'Beschwerde',
    blocks: [
      ParagraphBlock(
        'Dir stehen gegenüber deinem Arbeitgeber als Verantwortlichem '
        'die folgenden Rechte zu. Sie auszuüben ist kostenlos, und es '
        'entsteht dir daraus kein Nachteil.',
      ),
      BulletsBlock([
        'Auskunft (Art. 15 DSGVO): Du kannst erfahren, ob und welche '
            'Daten über dich verarbeitet werden, und eine Kopie davon '
            'verlangen.',
        'Berichtigung (Art. 16 DSGVO): Falsche Daten musst du '
            'berichtigen lassen können, unvollständige ergänzen — für '
            'Zeitbuchungen gibt es dafür den Korrekturantrag in der App.',
        'Löschung (Art. 17 DSGVO): Daten, die nicht mehr benötigt werden '
            'und keiner Aufbewahrungspflicht unterliegen, werden auf '
            'Verlangen gelöscht.',
        'Einschränkung der Verarbeitung (Art. 18 DSGVO): Ist strittig, '
            'ob Daten richtig sind oder verarbeitet werden dürfen, '
            'kannst du verlangen, dass sie bis zur Klärung nur noch '
            'gespeichert werden.',
        'Datenübertragbarkeit (Art. 20 DSGVO): Daten, die du '
            'bereitgestellt hast, erhältst du in einem gängigen, '
            'maschinenlesbaren Format.',
        'Widerspruch (Art. 21 DSGVO): Gegen Verarbeitungen, die auf ein '
            'berechtigtes Interesse gestützt sind — etwa den '
            'automatischen Geofence-Check —, kannst du aus Gründen '
            'deiner besonderen Situation Widerspruch einlegen.',
        'Beschwerde (Art. 77 DSGVO): Du kannst dich jederzeit bei einer '
            'Datenschutz-Aufsichtsbehörde beschweren.',
      ]),
      SubheadBlock('An wen du dich wendest'),
      ParagraphBlock(
        'Zuerst an deinen Arbeitgeber — den DSP, dessen Name oben auf '
        'dieser Seite steht. Hat er eine oder einen '
        'Datenschutzbeauftragten benannt, kannst du dich unmittelbar '
        'dorthin wenden; die Kontaktdaten nennt dir die '
        'Geschäftsführung. Für eine Beschwerde ist die '
        'Datenschutz-Aufsichtsbehörde des Bundeslandes zuständig, in dem '
        'dein Betrieb seinen Sitz hat; du kannst dich auch an die '
        'Behörde an deinem Wohnort oder am Ort des mutmaßlichen '
        'Verstoßes wenden.',
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'So schnell bekommst du Antwort',
        text: 'Auf einen Antrag muss dir der Verantwortliche '
            'grundsätzlich innerhalb eines Monats antworten. Nur in '
            'komplizierten Fällen darf er die Frist verlängern und muss '
            'dich darüber informieren.',
      ),
    ],
  ),

  // ══════════════════════════════════════════════════════════════ 11
  PrivacyNoticeSection(
    id: 'bedeutung',
    title: 'Was deine Bestätigung bedeutet',
    summary: 'Warum du hier informiert wirst und nicht etwas erlaubst',
    blocks: [
      ParagraphBlock(
        'Gleich unterschreibst du. Damit klar ist, was du unterschreibst: '
        'Du bestätigst ausschließlich, dass du diese Information gelesen '
        'und verstanden hast. Du erlaubst damit keine Verarbeitung und '
        'gibst nichts frei.',
      ),
      SubheadBlock('Warum das wichtig ist'),
      ParagraphBlock(
        'In einem Arbeitsverhältnis stehst du in einem '
        'Abhängigkeitsverhältnis zu deinem Arbeitgeber. Eine Erklärung, '
        'mit der du eine Verarbeitung erlaubst, wäre deshalb kaum je '
        'wirklich freiwillig — und du könntest sie jederzeit '
        'zurückziehen, was die Zeiterfassung oder die Lohnabrechnung '
        'unmöglich machen würde. Deshalb wird deine Arbeit in CoDriver '
        'nicht auf eine solche Erklärung gestützt, sondern auf das, was '
        'ohnehin gilt: die Durchführung deines Arbeitsvertrags '
        '(Art. 6 Abs. 1 lit. b DSGVO), gesetzliche Pflichten deines '
        'Arbeitgebers (Art. 6 Abs. 1 lit. c DSGVO) und berechtigte '
        'Interessen des Betriebs (Art. 6 Abs. 1 lit. f DSGVO), jeweils '
        'in Verbindung mit § 26 BDSG.',
      ),
      DoDontBlock(
        doTitle: 'Das bestätigst du',
        dos: [
          'Ich wurde nach Art. 13 DSGVO über die Verarbeitung meiner '
              'Daten informiert.',
          'Ich habe diese Datenschutzinformation gelesen und verstanden.',
          'Ich weiß, an wen ich mich mit Fragen und Anträgen wende.',
        ],
        dontTitle: 'Das bestätigst du nicht',
        donts: [
          'Keine Erlaubnis für eine Verarbeitung — die Rechtsgrundlagen '
              'stehen bei jedem Abschnitt.',
          'Keinen Verzicht auf deine Rechte aus Art. 15 bis 21 DSGVO.',
          'Keinen Verzicht auf dein Beschwerderecht nach Art. 77 DSGVO.',
        ],
      ),
      CalloutBlock(
        tone: CalloutTone.key,
        title: 'Und wenn sich etwas ändert?',
        text: 'Ändert sich diese Information inhaltlich, erhöht sich '
            'ihre Fassungsnummer und sie wird dir beim nächsten Login '
            'erneut vorgelegt. So weißt du immer, worüber du informiert '
            'wurdest — und wann.',
      ),
      ParagraphBlock(
        'Die Bestätigung selbst wird ebenfalls dokumentiert: gespeichert '
        'werden deine Transporter-ID, die Fassungsnummer, Datum und '
        'Uhrzeit, die Sprache dieser Ansicht sowie das Nachweis-PDF mit '
        'deiner Unterschrift. Grundlage dafür ist die Rechenschafts'
        'pflicht nach Art. 5 Abs. 2 DSGVO.',
      ),
    ],
  ),
];
