// lib/data/safety_training/driving_safety_content_de.dart
//
// Inhalte des DSP-Fahrsicherheitstrainings — deutsche Fassung (Master).
// Module M1–M10 nach der Inhaltsspezifikation „CoDriver – DSP
// Fahrsicherheitstraining". Aufbau wie bei der Sicherheitsunterweisung:
// je Modul mehrere Folien aus typisierten Bausteinen — Zahlen-Kacheln,
// Fallbeispiele zum Nachdenken (Reveal), Do/Don't, Rechtshinweise und
// eine Checkliste am Modulende.
//
// Bildpfade liegen unter assets/academy/driving/. Das Auftaktbild eines
// Moduls steht am Kapitel (`asset`), zusätzliche Einzelbilder an der
// jeweiligen Folie (`SafetySlide.asset`), Schrittfolgen als
// IllustratedStepsBlock.

import 'safety_blocks.dart';

const List<SafetyChapterContent> drivingSafetyContentDe = [
  // ══════════════════════════════════════════════════ M1
  SafetyChapterContent(
    id: 'm1',
    title: 'Sicherheitskultur & Verantwortung',
    summary: 'Sicherheit als eigene Entscheidung verstehen — nicht als '
        'Vorschrift',
    asset: 'assets/academy/driving/m01_sicherheitskultur.svg',
    slides: [
      SafetySlide(
        title: 'Deine Tour, deine Verantwortung',
        blocks: [
          ParagraphBlock(
            'Jeden Tag legst du hunderte Kilometer zurück und hältst '
            'dutzende Male an. Jede Fahrt, jeder Stopp, jedes Aussteigen '
            'ist eine Entscheidung. Die gute Nachricht: Fast jeder Unfall '
            'ist vermeidbar. Sicherheit beginnt nicht am Steuer, sondern '
            'im Kopf — bevor du losfährst.',
          ),
          FactsBlock([
            FactItem('120+', 'Stopps an einem normalen Zustelltag'),
            FactItem('250+', 'Mal ein- und aussteigen pro Tour'),
            FactItem('1', 'Sekunde Unaufmerksamkeit reicht für einen '
                'Unfall'),
          ]),
          ParagraphBlock(
            'Bei dieser Menge an Wiederholungen entscheidet nicht dein '
            'Können über den Tag, sondern deine Routine. Eine gute '
            'Routine schützt dich auch dann, wenn du müde bist oder '
            'unter Druck stehst — eine schlechte Routine wird '
            'irgendwann teuer.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Der Kerngedanke',
            text: 'Sicherheit ist nichts, was du zusätzlich machst. Sie '
                'ist die Art, wie du deine Arbeit machst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Was in der Zustellung wirklich passiert',
        blocks: [
          ParagraphBlock(
            'Zustellen gehört zu den Berufen mit den meisten Wege- und '
            'Arbeitsunfällen. Die häufigsten Vorfälle sind nicht '
            'spektakulär: Auffahren im Stau, Schäden beim '
            'Rückwärtsfahren, Stürze beim Aussteigen, verhobene Rücken, '
            'umgeknickte Knöchel. Alltäglich — und genau deshalb '
            'unterschätzt.',
          ),
          FactsBlock([
            FactItem('70 %', 'der Transporterschäden entstehen beim '
                'Rangieren und Rückwärtsfahren'),
            FactItem('Nr. 1', 'Stolpern, Rutschen, Stürzen ist die '
                'häufigste Verletzungsursache in der Zustellung'),
            FactItem('24', 'Ausfalltage im Schnitt nach einem Sturz'),
          ]),
          ParagraphBlock(
            'Auffällig ist: Fast alle diese Vorfälle passieren bei '
            'niedriger Geschwindigkeit oder im Stand. Es sind keine '
            'dramatischen Fahrmanöver, sondern normale Handgriffe, die '
            'einmal schlecht ausgeführt wurden.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Langsam ist nicht harmlos',
            text: 'Ein Schaden beim Rangieren mit Schrittgeschwindigkeit '
                'kostet den Betrieb schnell einen vierstelligen Betrag — '
                'und dich einen halben Tag Ärger.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die drei Grundhaltungen',
        blocks: [
          ParagraphBlock(
            'Aus allem, was in diesem Training kommt, lassen sich drei '
            'Haltungen ableiten. Wenn du nur diese drei mitnimmst, hast '
            'du den größten Teil erledigt.',
          ),
          BulletsBlock([
            'Vorausdenken — Gefahren erkennen, bevor sie entstehen. Wer '
                'nur reagiert, ist immer zu spät',
            'Zeit gehört dir — kein Paket ist einen Unfall wert. '
                'Zeitdruck ist ein Planungsproblem, keine Ausrede',
            'Vorbild sein — dein Verhalten schützt Kollegen, Fußgänger '
                'und Kinder. Du bist im Straßenbild ein Profi, kein '
                'Privatfahrer',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Merksatz',
            text: 'Der beste Fahrer ist nicht der schnellste, sondern '
                'der, dem nie etwas passiert — weil er es kommen sieht.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Jede Fahrt ist eine Kette von Entscheidungen',
        asset: 'assets/academy/driving/m01b_entscheidung.svg',
        blocks: [
          ParagraphBlock(
            'Ein Unfall ist selten ein einzelner Fehler. Meistens sind '
            'es fünf, sechs kleine Entscheidungen, die alle für sich '
            'harmlos wirken — und sich am Ende addieren. Genau deshalb '
            'kannst du die Kette an jeder Stelle unterbrechen.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Es ist 17:40 Uhr, du hast noch 22 '
                'Stopps offen. Der Ladeboden ist unaufgeräumt, dein '
                'Handy vibriert im Halter, und vor dir wird es eng. Wo '
                'liegt hier eigentlich das Risiko?',
            answer: 'Nicht in der Enge vor dir — sondern in der '
                'Vorgeschichte. Der unaufgeräumte Ladeboden kostet dich '
                'bei jedem Stopp Zeit, die Zeit erzeugt Druck, der Druck '
                'senkt deine Aufmerksamkeit, und das Handy zieht den '
                'Rest ab. Die richtige Entscheidung war zwei Stunden '
                'früher fällig: Laderaum sortieren, Handy stumm, '
                'realistisch takten. Jetzt hilft nur noch: anhalten, '
                'durchatmen, Stopp für Stopp weitermachen und die '
                'Planung danach melden.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die Kette brechen',
            text: 'Frag dich bei jedem unguten Gefühl: Was ist gerade '
                'das eine Glied, das ich mit 30 Sekunden Aufwand '
                'herausnehmen kann?',
          ),
        ],
      ),
      SafetySlide(
        title: 'Vorbild im Team',
        asset: 'assets/academy/driving/m01c_vorbild.svg',
        blocks: [
          ParagraphBlock(
            'Sicherheitskultur entsteht nicht durch Aushänge, sondern '
            'durch das, was Kollegen voneinander abschauen. Wer neu '
            'anfängt, macht das nach, was die Erfahrenen vorleben — '
            'auch das Falsche.',
          ),
          DoDontBlock(
            doTitle: 'Kultur, die trägt',
            dos: [
              'Beinahe-Unfälle offen ansprechen, ohne dass jemand '
                  'blöd angeguckt wird',
              'Neue Kollegen aktiv auf Trittstufen, Griffe und den '
                  'toten Winkel hinweisen',
              'Defekte sofort melden, auch wenn die Tour dadurch '
                  'später startet',
              'Auch bei Zeitdruck sichtbar sauber rangieren',
            ],
            dontTitle: 'Kultur, die schadet',
            donts: [
              '„Das machen wir hier immer so" als Begründung',
              'Über den Kollegen lachen, der aussteigt und nachschaut',
              'Kleine Schäden untereinander regeln statt melden',
              'Abkürzungen vorleben, die man Neuen nie beibringen '
                  'würde',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Beinahe-Unfälle sind Gold wert',
            text: 'Jeder gemeldete Beinahe-Unfall ist ein Unfall, der '
                'beim nächsten Kollegen nicht mehr passiert. Melden ist '
                'Stärke, nicht Petzen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wer haftet eigentlich?',
        blocks: [
          ParagraphBlock(
            'Am Steuer bist du Fahrzeugführer — und damit persönlich '
            'verantwortlich. Der Betrieb stellt dir ein sicheres '
            'Fahrzeug, unterweist dich und plant die Tour. Ob du dann '
            'mit Abstand fährst, den Gurt anlegst und vor dem '
            'Zurücksetzen aussteigst, entscheidest allein du.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Was das Gesetz von dir erwartet',
            text: '§ 1 StVO verlangt ständige Vorsicht und gegenseitige '
                'Rücksicht. § 3 Abs. 1 StVO verlangt, dass du nur so '
                'schnell fährst, wie du innerhalb der übersehbaren '
                'Strecke anhalten kannst. Beides gilt unabhängig davon, '
                'was auf dem Schild steht.',
          ),
          BulletsBlock([
            'Bußgelder und Punkte treffen dich persönlich, nicht den '
                'Betrieb',
            'Bei grober Fahrlässigkeit kann dich die Versicherung '
                'anteilig in Regress nehmen',
            'Bei Gefährdung anderer kann aus einem Verkehrsverstoß eine '
                'Straftat werden (§ 315c StGB)',
            'Ein Fahrverbot bedeutet für dich als Berufsfahrer: kein '
                'Einsatz',
          ]),
          RevealBlock(
            prompt: 'Du merkst morgens, dass ein Bremslicht ausgefallen '
                'ist. Der Disponent sagt: „Fahr trotzdem, wir haben '
                'niemanden sonst." Wer trägt das Risiko?',
            answer: 'Du. Als Fahrzeugführer haftest du für den '
                'verkehrssicheren Zustand des Fahrzeugs, das du bewegst '
                '— eine mündliche Anweisung hebt das nicht auf. Richtig '
                'ist: Mangel melden, Ersatzfahrzeug oder Reparatur '
                'verlangen, Meldung dokumentieren. Ein defektes '
                'Bremslicht am Transporter ist außerdem genau der '
                'Mangel, der zum Auffahrunfall führt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: deine Haltung',
        blocks: [
          ChecklistBlock(
            title: 'Das nehme ich aus Modul 1 mit',
            items: [
              'Ich weiß, dass die meisten Schäden langsam und alltäglich '
                  'passieren',
              'Ich denke voraus, statt nur zu reagieren',
              'Ich behandle Zeitdruck als Planungsproblem, nicht als '
                  'Fahrproblem',
              'Ich melde Mängel und Beinahe-Unfälle, auch kleine',
              'Ich weiß, dass ich als Fahrzeugführer persönlich hafte',
              'Ich bin mir bewusst, dass neue Kollegen mich kopieren',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ein Satz für die Tour',
            text: '„Ich fahre so, dass alle sicher nach Hause kommen — '
                'auch ich."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M2
  SafetyChapterContent(
    id: 'm2',
    title: 'Fahrzeugcheck & Ladungssicherung',
    summary: 'Vor der Tour Fahrzeug prüfen und Ladung so sichern, dass '
        'nichts zur Gefahr wird',
    asset: 'assets/academy/driving/m02_fahrzeugcheck.svg',
    slides: [
      SafetySlide(
        title: 'Warum der Check keine Formalie ist',
        blocks: [
          ParagraphBlock(
            'Der Rundgang vor der Tour dauert zwei Minuten. Er '
            'verhindert Pannen mitten auf der Route, Bußgelder bei einer '
            'Kontrolle und im schlimmsten Fall einen Unfall, den du '
            'hättest sehen können, bevor du losgefahren bist.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Prüfpflicht vor der Schicht',
            text: 'Nach der DGUV Vorschrift 70 (Fahrzeuge) musst du dein '
                'Fahrzeug vor Beginn jeder Arbeitsschicht auf '
                'offensichtliche Mängel prüfen. Stellst du Mängel fest, '
                'die die Betriebssicherheit gefährden, darfst du nicht '
                'losfahren — du meldest sie.',
          ),
          FactsBlock([
            FactItem('2 min', 'dauert der komplette Rundgang'),
            FactItem('4', 'Stationen: Reifen, Licht, Flüssigkeiten, '
                'Ladung'),
          ]),
          ParagraphBlock(
            'Wichtig: Der Check ersetzt keine Werkstattprüfung. Du '
            'suchst nach dem, was ins Auge fällt — nicht nach '
            'verborgenen Defekten.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Der Rundgang — vier Stationen',
        asset: 'assets/academy/driving/m02b_rundgang.svg',
        blocks: [
          ParagraphBlock(
            'Geh immer in derselben Reihenfolge um den Wagen. Eine feste '
            'Reihenfolge ist der einzige Weg, nichts zu vergessen, wenn '
            'es morgens hektisch wird.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/load01_reifen.svg',
              title: '1 · Reifen und Räder',
              caption: 'Geh einmal komplett herum und schau dir alle '
                  'vier Reifen an: sichtbar platt, Risse, Fremdkörper, '
                  'Profil noch ausreichend? Ein Reifen, der morgens '
                  'schon weich aussieht, hält keine Tour durch.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load02_licht.svg',
              title: '2 · Beleuchtung und Kennzeichen',
              caption: 'Standlicht, Abblendlicht, Blinker, Bremslicht '
                  'und Rückfahrscheinwerfer prüfen — Bremslicht zur Not '
                  'über die Reflexion an einer Wand oder mit einem '
                  'Kollegen. Kennzeichen muss frei und lesbar sein.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load03_fluessigkeiten.svg',
              title: '3 · Flüssigkeiten und Boden',
              caption: 'Ein Blick unter den Wagen: Öl-, Kühl- oder '
                  'Bremsflüssigkeitsspuren auf dem Boden sind immer ein '
                  'Grund zum Melden. Dazu Wischwasser auffüllen — im '
                  'Winter mit Frostschutz.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/load04_ladung.svg',
              title: '4 · Laderaum und Ladung',
              caption: 'Türen auf und hineinschauen: Sitzt alles fest, '
                  'sind Trennnetz und Zurrgurte gespannt, liegt nichts '
                  'lose obenauf? Was hier locker steht, fliegt bei der '
                  'ersten Vollbremsung nach vorn.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Reifen: dein einziger Kontakt zur Straße',
        blocks: [
          ParagraphBlock(
            'Vier Kontaktflächen, jede etwa so groß wie eine '
            'Postkarte — mehr verbindet deinen beladenen Transporter '
            'nicht mit der Fahrbahn. Alles, was du über Bremsen, Lenken '
            'und Haftung lernst, hängt an diesen vier Flächen.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'gesetzliche Mindestprofiltiefe'),
            FactItem('3 mm', 'empfohlenes Mindestprofil im Sommer'),
            FactItem('4 mm', 'empfohlenes Mindestprofil im Winter'),
            FactItem('60 € + 1 P.', 'bei zu geringer Profiltiefe'),
          ]),
          BulletsBlock([
            'Profiltiefe mit einer 1-Euro-Münze prüfen: Der goldene Rand '
                'ist 3 mm breit — verschwindet er im Profil, hast du '
                'noch genug',
            'Luftdruck bei kalten Reifen prüfen und an die Beladung '
                'anpassen — beladen brauchst du mehr Druck als leer',
            'Auf ungleichmäßigen Abrieb achten: einseitig abgefahren '
                'heißt Spur- oder Druckproblem',
            'Beulen, Risse und eingefahrene Schrauben sofort melden',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Zu wenig Druck ist gefährlicher als zu viel',
            text: 'Ein zu schwach aufgepumpter Reifen walkt, wird heiß '
                'und kann bei voller Beladung platzen. Außerdem wächst '
                'der Bremsweg und die Aquaplaning-Gefahr steigt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Licht, Scheiben, Spiegel',
        blocks: [
          ParagraphBlock(
            'Gesehen werden ist genauso wichtig wie sehen. Ein '
            'ausgefallenes Bremslicht am Transporter ist die klassische '
            'Ursache für einen Auffahrunfall, bei dem du zwar nicht der '
            'Verursacher bist — aber trotzdem den Schaden hast.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Freie Sicht ist Pflicht',
            text: 'Nach § 23 Abs. 1 StVO musst du dafür sorgen, dass '
                'Sicht und Gehör nicht beeinträchtigt sind — durch '
                'Ladung, Besetzung, vereiste oder verschmutzte Scheiben. '
                'Ein freigekratztes „Guckloch" reicht ausdrücklich '
                'nicht.',
          ),
          BulletsBlock([
            'Spiegel im Stand einstellen, bevor der Motor läuft — nie '
                'während der Fahrt',
            'Außenspiegel so, dass ein schmaler Streifen des eigenen '
                'Fahrzeugs sichtbar bleibt: das ist dein Bezugspunkt',
            'Scheiben und Spiegel innen wie außen sauber halten — Fett '
                'auf der Innenseite blendet nachts extrem',
            'Wischerblätter, die schmieren, sofort tauschen lassen',
          ]),
          RevealBlock(
            prompt: 'Beim Rundgang fällt dir auf: Der rechte '
                'Außenspiegel wackelt und hat einen Riss. Du hast noch '
                '190 Stopps vor dir. Fahren oder nicht?',
            answer: 'Nicht fahren, bevor es gemeldet ist. Der rechte '
                'Außenspiegel ist genau der, mit dem du den toten Winkel '
                'zu Radfahrern und Gehweg absicherst — ausgerechnet dort '
                'passieren die schweren Abbiegeunfälle. Ein gerissener, '
                'wackelnder Spiegel ist ein Mangel, der die '
                'Verkehrssicherheit betrifft. Melden, tauschen oder '
                'Fahrzeug wechseln.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ladungssicherung: die Kräfte verstehen',
        blocks: [
          ParagraphBlock(
            'Ladung muss so gesichert sein, dass sie auch bei einer '
            'Vollbremsung oder einem plötzlichen Ausweichmanöver nicht '
            'verrutscht. Was das konkret heißt, steht in den anerkannten '
            'Regeln der Technik — und die rechnen mit klaren Werten.',
          ),
          FactsBlock([
            FactItem('0,8 g', 'Kraft nach vorn, gegen die gesichert '
                'werden muss'),
            FactItem('0,5 g', 'Kraft nach hinten und zur Seite'),
            FactItem('16 kg', 'Rückhaltekraft, die allein ein 20-kg-'
                'Paket beim Bremsen braucht'),
          ]),
          ParagraphBlock(
            'Übersetzt: Ein 20-kg-Paket drückt bei einer Vollbremsung '
            'mit rund 16 kg nach vorn — als hättest du einen vollen '
            'Wasserkasten in Richtung Trennwand geschoben. Bei zwanzig '
            'solchen Paketen sind das über 300 kg, die sich gleichzeitig '
            'nach vorn bewegen wollen.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 22 StVO — Ladung',
            text: 'Die Ladung ist so zu verstauen und zu sichern, dass '
                'sie selbst bei Vollbremsung oder plötzlicher '
                'Ausweichbewegung nicht verrutschen, umfallen, hin- und '
                'herrollen oder herabfallen kann. Ungesicherte Ladung '
                'wird mit Bußgeld und bei Gefährdung mit Punkt geahndet '
                '— und trifft den Fahrer.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Was 20 kg im Ernstfall anrichten',
        blocks: [
          ParagraphBlock(
            'Die 0,8 g gelten für Bremsen und Ausweichen. Bei einem '
            'echten Aufprall wirken deutlich höhere Verzögerungen über '
            'einen sehr kurzen Zeitraum — die Anprallwucht eines '
            'ungesicherten Pakets liegt dann um ein Vielfaches über '
            'seinem Gewicht.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Auf dem Beifahrersitz liegt eine '
                '12-kg-Sendung, weil sie der nächste Stopp ist. Du '
                'musst innerorts vor einem Kind vollbremsen. Was '
                'passiert mit dem Paket?',
            answer: 'Es bewegt sich mit deiner Ausgangsgeschwindigkeit '
                'weiter, bis etwas es aufhält — Armaturenbrett, '
                'Windschutzscheibe oder dein Kopf beim seitlichen '
                'Aufprall. Schon bei einer normalen Gefahrenbremsung '
                'fliegt es vom Sitz in den Fußraum und kann dort unter '
                'das Bremspedal geraten. Genau deshalb gehört keine '
                'Sendung nach vorn: Der nächste Stopp wird im Laderaum '
                'vorsortiert, nicht auf dem Beifahrersitz zwischen'
                'gelagert.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Nichts im Fahrerhaus',
            text: 'Kein Paket, keine Rollbox, kein loses Werkzeug im '
                'Fahrerraum. Ein Gegenstand unter dem Bremspedal nimmt '
                'dir genau in dem Moment die Bremse, in dem du sie '
                'brauchst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'So belädst du richtig',
        asset: 'assets/academy/driving/m02c_ladung.svg',
        blocks: [
          ParagraphBlock(
            'Die Grundregel: schwer nach unten, schwer nach vorn, '
            'Gewicht gleichmäßig über die Achsen. Ein hoch beladener '
            'Transporter hat einen hohen Schwerpunkt — und der '
            'entscheidet, ob du in einer Kurve noch rutschst oder schon '
            'kippst.',
          ),
          DoDontBlock(
            doTitle: 'Gesichert',
            dos: [
              'Schwere Pakete unten und vorne an der Trennwand',
              'Gewicht gleichmäßig links/rechts verteilt',
              'Formschlüssig laden — Lücken schließen, damit nichts '
                  'anlaufen kann',
              'Zurrgurte und Trennnetz gespannt, auch wenn der '
                  'Laderaum leerer wird',
              'Nach jedem Nachladen kurz kontrollieren',
            ],
            dontTitle: 'Ungesichert',
            donts: [
              'Schwere Pakete lose obenauf gestapelt',
              'Sendungen im Fußraum oder auf dem Beifahrersitz',
              'Alles nur „irgendwie" hineingeschoben, Lücken offen',
              'Trennnetz gelöst, weil es beim Greifen stört',
              'Ladung nur mit dem eigenen Körpergewicht „festgehalten"',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der leere Laderaum ist der gefährlichste',
            text: 'Je weniger drin ist, desto mehr Weg hat das '
                'Restpaket, um Tempo aufzunehmen. Halb leer heißt '
                'nicht halb gefährlich — es heißt neu sichern.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ordnung im Cockpit & Gurt',
        blocks: [
          ParagraphBlock(
            'Getränk, Handy, Scanner, Lieferscheine — alles bekommt '
            'einen festen Platz. Was rollt, klappert oder fliegt, zieht '
            'deinen Blick von der Straße. Ein aufgeräumter Fahrerplatz '
            'ist ein sicherer Fahrerplatz.',
          ),
          FactsBlock([
            FactItem('30 €', 'Verwarnungsgeld ohne Sicherheitsgurt'),
            FactItem('Jeder', 'Stopp: Gurt wieder anlegen, auch für '
                '200 Meter'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 21a StVO — Gurtpflicht',
            text: 'Der Sicherheitsgurt ist während der Fahrt anzulegen — '
                'ohne Ausnahme für kurze Strecken zwischen zwei Stopps. '
                'Bei einem Unfall ohne Gurt kann dir außerdem ein '
                'Mitverschulden angerechnet werden.',
          ),
          ParagraphBlock(
            'Gerade in der Zustellung ist der Gurt die am häufigsten '
            'weggelassene Sicherung — weil zwischen zwei Stopps nur '
            'wenige hundert Meter liegen. Genau dort passieren aber die '
            'meisten innerörtlichen Kollisionen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste vor der Abfahrt',
        blocks: [
          ChecklistBlock(
            title: 'Bevor ich losfahre',
            items: [
              'Rundgang in fester Reihenfolge gemacht',
              'Reifen: Profil, Druck, Beschädigungen geprüft',
              'Beleuchtung rundum geprüft, Kennzeichen lesbar',
              'Keine Flüssigkeitsspuren unter dem Fahrzeug',
              'Scheiben und Spiegel sauber, Spiegel eingestellt',
              'Schwere Pakete unten und vorn, Gewicht verteilt',
              'Zurrgurte und Trennnetz gespannt',
              'Nichts Loses im Fahrerhaus, Handy in der Halterung',
              'Warnweste griffbereit, Warndreieck an Bord',
              'Gurt angelegt',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M3
  SafetyChapterContent(
    id: 'm3',
    title: 'Defensives & vorausschauendes Fahren',
    summary: 'Abstand, Tempo und Aufmerksamkeit so steuern, dass du immer '
        'eine Reserve hast',
    asset: 'assets/academy/driving/m03_defensiv.svg',
    slides: [
      SafetySlide(
        title: 'Anhalteweg = Reaktionsweg + Bremsweg',
        blocks: [
          ParagraphBlock(
            'Der Anhalteweg ist die Strecke vom Moment des Erkennens bis '
            'zum Stillstand. Er besteht aus zwei Teilen: dem '
            'Reaktionsweg, den du noch mit voller Geschwindigkeit '
            'zurücklegst, und dem eigentlichen Bremsweg.',
          ),
          FactsBlock([
            FactItem('ca. 1 s', 'Reaktionszeit eines wachen, nüchternen '
                'Fahrers'),
            FactItem('× 3', 'Reaktionsweg = Tempo ÷ 10, mal 3'),
            FactItem('²', 'Bremsweg = (Tempo ÷ 10) im Quadrat'),
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die Faustformeln',
            text: 'Reaktionsweg = (km/h ÷ 10) × 3. Bremsweg = '
                '(km/h ÷ 10) × (km/h ÷ 10). Beides addiert ergibt den '
                'Anhalteweg. Bei einer Gefahrenbremsung halbiert sich '
                'der Bremsweg.',
          ),
          ParagraphBlock(
            'Der entscheidende Punkt: Der Bremsweg wächst nicht '
            'proportional zum Tempo, sondern im Quadrat. Doppeltes Tempo '
            'bedeutet vierfachen Bremsweg — das ist der Grund, warum 20 '
            'km/h mehr in der Wohnstraße alles ändern.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rechnen statt schätzen',
        blocks: [
          TableBlock(
            headers: ['Tempo', 'Reaktion', 'Bremsweg', 'Anhalteweg'],
            rows: [
              ['30 km/h', '9 m', '9 m', '18 m'],
              ['50 km/h', '15 m', '25 m', '40 m'],
              ['70 km/h', '21 m', '49 m', '70 m'],
              ['100 km/h', '30 m', '100 m', '130 m'],
            ],
          ),
          ParagraphBlock(
            'Zum Vergleich: Ein Sprinter ist etwa 6 Meter lang. Bei '
            'Tempo 50 brauchst du also rund sieben Fahrzeuglängen bis '
            'zum Stillstand — und die ersten zweieinhalb davon vergehen, '
            'bevor du überhaupt das Pedal berührst.',
          ),
          RevealBlock(
            prompt: 'Rechenaufgabe: Du fährst 50 km/h durch eine '
                'Wohnstraße. In 20 Metern läuft ein Kind zwischen zwei '
                'geparkten Autos auf die Fahrbahn. Kommst du zum '
                'Stehen?',
            answer: 'Nein. Allein dein Reaktionsweg beträgt 15 Meter, '
                'danach folgen 25 Meter Bremsweg — zusammen 40 Meter. '
                'Selbst mit Gefahrenbremsung (15 m + 12,5 m = 27,5 m) '
                'reichen 20 Meter nicht. Bei Tempo 30 dagegen: 9 m '
                'Reaktion + 9 m Bremsweg = 18 Meter — du stehst zwei '
                'Meter vorher. Genau das ist der Unterschied zwischen '
                'einem Schreck und einem schweren Unfall.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Zwei-Sekunden-Regel',
        asset: 'assets/academy/driving/m03b_abstand.svg',
        blocks: [
          ParagraphBlock(
            'Abstand ist keine Höflichkeit, sondern deine Reaktionszeit '
            'in Metern. Und weil er in Sekunden gedacht funktioniert, '
            'passt er sich automatisch an dein Tempo an.',
          ),
          StepsBlock([
            'Such dir einen festen Punkt am Straßenrand — Schild, '
                'Laterne, Fahrbahnmarkierung',
            'Passiert der Vordermann diesen Punkt, beginne zu zählen: '
                '„einundzwanzig, zweiundzwanzig"',
            'Bist du vor „zweiundzwanzig" am Punkt, fährst du zu dicht '
                'auf',
            'Bei Nässe, Nebel oder Dunkelheit auf drei Sekunden '
                'erhöhen',
          ]),
          FactsBlock([
            FactItem('2 s', 'Mindestabstand bei trockener Fahrbahn'),
            FactItem('3 s+', 'bei Nässe, Nebel, Dunkelheit'),
            FactItem('28 m', 'entsprechen 2 Sekunden bei Tempo 50'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 Abs. 1 StVO — Abstand',
            text: 'Der Abstand zum Vordermann muss in der Regel so groß '
                'sein, dass auch dann hinter ihm gehalten werden kann, '
                'wenn er plötzlich gebremst wird. Als Faustformel gilt '
                'außerorts der halbe Tachowert in Metern.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wenn der Abstand fehlt',
        blocks: [
          RevealBlock(
            prompt: 'Fallbeispiel: Auf der Bundesstraße hältst du bei '
                'Tempo 80 sauber 40 Meter Abstand. Ein Pkw zieht in die '
                'Lücke und bremst dann ab. Was ist jetzt richtig?',
            answer: 'Nicht ärgern, nicht hupen, nicht drängeln — '
                'sondern Gas wegnehmen und den Abstand neu aufbauen. '
                'Das kostet dich ein paar Sekunden und ist die einzige '
                'Reaktion, die dein Risiko senkt. Wer stattdessen '
                'aufschließt, um die Lücke zu „verteidigen", hat bei '
                'Tempo 80 keine 40 Meter mehr, sondern vielleicht 15 — '
                'weniger als der reine Reaktionsweg von 24 Metern.',
          ),
          DoDontBlock(
            doTitle: 'Souverän',
            dos: [
              'Abstand nach dem Einscheren ruhig neu aufbauen',
              'Bei Drängler hinter dir: rechts halten, vorbeilassen',
              'Vor Ampeln und Baustellen früh vom Gas gehen',
              'Im Stau Lücke zum Vordermann lassen, damit du '
                  'ausscheren kannst',
            ],
            dontTitle: 'Riskant',
            donts: [
              'Auffahren, um das Einscheren zu verhindern',
              'Lichthupe und Hupe als Erziehungsmittel',
              'Im Stop-and-go direkt auf die Stoßstange rollen',
              'Abstand nur nach Gefühl statt nach Sekunden schätzen',
            ],
          ),
          FactsBlock([
            FactItem('bis 400 €', 'Bußgeld bei Abstandsverstößen, dazu '
                'Punkte und Fahrverbot'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Blick weit voraus',
        asset: 'assets/academy/driving/m03c_blickfuehrung.svg',
        blocks: [
          ParagraphBlock(
            'Schau nicht auf die Stoßstange vor dir, sondern 12–15 '
            'Sekunden voraus — innerorts also etwa zwei Straßenblöcke. '
            'So siehst du Bremslichter, Ampeln, Fußgänger und '
            'Engstellen früh und musst nicht hektisch reagieren.',
          ),
          BulletsBlock([
            'Kind am Bordstein, das noch nicht geschaut hat',
            'Radfahrer, der gleich um ein parkendes Auto ausschert',
            'Autotür, hinter der jemand sitzt — Rücklichter an, Kopf '
                'im Innenspiegel',
            'Bremslichter drei Fahrzeuge weiter vorn',
            'Mülltonnen am Straßenrand: Anzeichen für Rangierverkehr',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Der Blick lenkt das Fahrzeug',
            text: 'Wohin du schaust, dorthin fährst du. Deshalb beim '
                'Ausweichen immer auf die freie Lücke schauen — nie auf '
                'das Hindernis.',
          ),
          ParagraphBlock(
            'Alle paar Sekunden ein kurzer Blick in die Spiegel gehört '
            'dazu. So weißt du jederzeit, was hinter dir passiert, ohne '
            'dass du im Notfall erst nachschauen musst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tempo ist Physik',
        blocks: [
          ParagraphBlock(
            'Die erlaubte Geschwindigkeit ist ein Maximum, kein Ziel. In '
            'Wohngebieten, an Schulen, bei parkenden Autos und in engen '
            'Straßen ist langsamer als erlaubt oft die einzig richtige '
            'Wahl.',
          ),
          FactsBlock([
            FactItem('×4', 'Bremsweg bei doppeltem Tempo'),
            FactItem('18 m', 'Anhalteweg bei 30 km/h'),
            FactItem('40 m', 'Anhalteweg bei 50 km/h'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 3 Abs. 1 StVO — Sichtfahrgebot',
            text: 'Du darfst nur so schnell fahren, dass du innerhalb '
                'der übersehbaren Strecke anhalten kannst. Bei Nebel, '
                'Dunkelheit oder unübersichtlicher Kurve ist das '
                'deutlich weniger als das Schild erlaubt.',
          ),
          ParagraphBlock(
            'Rechne einmal nach, was Rasen wirklich bringt: Auf zehn '
            'Kilometern Stadtstrecke sparst du zwischen Tempo 50 und '
            'Tempo 60 bestenfalls zwei Minuten — die dir die nächste '
            'rote Ampel wieder nimmt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Warum dein beladener Transporter anders fährt',
        blocks: [
          ParagraphBlock(
            'Ein voll beladener Transporter ist ein anderes Fahrzeug als '
            'derselbe Wagen morgens leer. Mehr Masse heißt mehr '
            'Bewegungsenergie, die die Bremse abbauen muss — und ein '
            'höherer Schwerpunkt heißt weniger Reserve in der Kurve.',
          ),
          FactsBlock([
            FactItem('3,5 t', 'zulässiges Gesamtgewicht deines '
                'Transporters'),
            FactItem('bis 1,4 t', 'Zuladung — mehr als die Hälfte des '
                'Leergewichts'),
            FactItem('hoch', 'Schwerpunkt: Kastenwagen kippen, wo Pkw '
                'noch rutschen'),
          ]),
          BulletsBlock([
            'Beladen früher und sanfter bremsen — die Bremse braucht '
                'länger für dieselbe Verzögerung',
            'In Kurven deutlich langsamer: Die Ladung verlagert sich '
                'nach außen und verstärkt die Kippneigung',
            'Bei Ausweichmanövern nicht ruckartig gegenlenken — genau '
                'das bringt hohe Fahrzeuge zum Kippen',
            'Kreisverkehre und Autobahnausfahrten mit deutlich weniger '
                'Tempo anfahren als gewohnt',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Der Kipp-Moment kommt ohne Vorwarnung',
            text: 'Anders als ein Pkw kündigt ein hoher Kastenwagen das '
                'Kippen kaum an. Wenn sich die Ladung hörbar verschiebt, '
                'bist du bereits zu schnell — Tempo raus, bevor du in '
                'die Kurve gehst, nicht darin.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Der tote Winkel',
        asset: 'assets/academy/driving/m03d_toterwinkel.svg',
        blocks: [
          ParagraphBlock(
            'Dein Transporter hat große tote Winkel — vor allem rechts '
            'neben und schräg hinter dem Fahrerhaus. Ein kompletter '
            'Radfahrer samt Rad passt dort hinein, ohne dass du ihn im '
            'Spiegel siehst.',
          ),
          FactsBlock([
            FactItem('rechts', 'der größte tote Winkel bei '
                'Kastenwagen'),
            FactItem('1,5 m', 'Mindestabstand beim Überholen von '
                'Radfahrern innerorts'),
            FactItem('2 m', 'Mindestabstand außerorts'),
          ]),
          ParagraphBlock(
            'Spiegel richtig einstellen reduziert den toten Winkel, '
            'beseitigt ihn aber nicht. Deshalb gehört zu jedem '
            'Spurwechsel und jedem Abbiegen der aktive Schulterblick — '
            'ein kurzer, echter Blick über die Schulter, nicht nur ein '
            'Kopfnicken Richtung Spiegel.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Gehe nie davon aus, gesehen zu werden',
            text: 'Blickkontakt ist der einzige verlässliche Beweis, '
                'dass dich jemand wahrgenommen hat. Ein Blinker ist eine '
                'Absicht, keine Garantie.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Abbiegen: der gefährlichste Moment',
        blocks: [
          ParagraphBlock(
            'Die meisten schweren Kollisionen mit Radfahrern und '
            'Fußgängern passieren beim Rechtsabbiegen. Der Grund ist '
            'immer derselbe: Der Radfahrer fährt geradeaus weiter und '
            'befindet sich genau in dem Bereich, den der Fahrer beim '
            'Einlenken nicht mehr einsehen kann.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du willst an einer Ampel rechts '
                'abbiegen. Ein Radfahrer hat dich links überholt und '
                'steht neben dir. Die Ampel wird grün. Was tust du '
                'zuerst?',
            answer: 'Stehen bleiben und ihn vorlassen. Sobald du '
                'anfährst und einlenkst, wandert er in den toten Winkel '
                'rechts — und dein Fahrzeugheck schwenkt beim Einlenken '
                'zusätzlich in seine Spur. Richtig ist: vor dem Anfahren '
                'Schulterblick nach rechts, Radfahrer und Fußgänger '
                'durchlassen, dann langsam einlenken und während des '
                'Abbiegens erneut in den rechten Spiegel schauen. Wer '
                'sich nur auf den Spiegel verlässt, sieht ihn genau '
                'dann nicht mehr, wenn es darauf ankommt.',
          ),
          DoDontBlock(
            doTitle: 'Sicher abbiegen',
            dos: [
              'Früh blinken und Tempo deutlich reduzieren',
              'Schulterblick vor dem Einlenken — nicht nur Spiegel',
              'Während des Abbiegens noch einmal rechts kontrollieren',
              'Im Zweifel anhalten und durchlassen',
            ],
            dontTitle: 'Riskant',
            donts: [
              'Im Schwung abbiegen, um die Lücke zu nutzen',
              'Nur der Blick in den Spiegel',
              'Annehmen, dass Radfahrer hinter dir bleiben',
              'Blinker erst setzen, wenn du schon einlenkst',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Beim Abbiegen und Wenden',
            text: '§ 9 Abs. 5 StVO: Beim Abbiegen in ein Grundstück, '
                'beim Wenden und beim Rückwärtsfahren musst du eine '
                'Gefährdung anderer Verkehrsteilnehmer ausschließen — '
                'erforderlichenfalls musst du dich einweisen lassen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: defensiv unterwegs',
        blocks: [
          ChecklistBlock(
            title: 'Das setze ich ab heute um',
            items: [
              'Ich kenne die Faustformeln für Reaktions- und Bremsweg',
              'Ich prüfe meinen Abstand am Fixpunkt mit zwei Sekunden',
              'Ich erhöhe bei Nässe und Dunkelheit auf drei Sekunden',
              'Ich schaue 12–15 Sekunden voraus statt auf die '
                  'Stoßstange',
              'Ich fahre beladen langsamer in Kurven und bremse früher',
              'Ich mache vor jedem Abbiegen und Spurwechsel einen '
                  'echten Schulterblick',
              'Ich halte 1,5 m Abstand beim Überholen von Radfahrern '
                  'innerorts',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M4
  SafetyChapterContent(
    id: 'm4',
    title: 'Rückwärtsfahren & Rangieren',
    summary: 'Die häufigste Schadensquelle beherrschen — sicher rückwärts '
        'und in engen Situationen rangieren',
    asset: 'assets/academy/driving/m04_rueckwaerts.svg',
    slides: [
      SafetySlide(
        title: 'Die Nummer-1-Schadensquelle',
        blocks: [
          ParagraphBlock(
            'Die meisten Transporterschäden entstehen langsam — beim '
            'Rückwärtsfahren und Rangieren: Poller, Mauern, Laternen, '
            'andere Autos, offene Türen. Und in den schlimmsten Fällen '
            'Personen, die im toten Winkel hinter dem Fahrzeug stehen.',
          ),
          FactsBlock([
            FactItem('70 %', 'aller Transporterschäden passieren beim '
                'Rangieren'),
            FactItem('< 10 km/h', 'Tempo, bei dem die meisten '
                'Rangierschäden entstehen'),
            FactItem('blind', 'ein Bereich von mehreren Metern direkt '
                'hinter dem Fahrzeug'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Warum ausgerechnet hier',
            text: 'Beim Rückwärtsfahren fehlt dir das, was dich sonst '
                'schützt: freie Sicht. Gleichzeitig fühlt es sich '
                'langsam und deshalb ungefährlich an — die gefährlichste '
                'Kombination im Zustellalltag.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rückwärtsfahren vermeiden statt beherrschen',
        blocks: [
          ParagraphBlock(
            'Die sicherste Rückwärtsfahrt ist die, die du nicht machst. '
            'Denk schon beim Anfahren des Stopps daran, wie du wieder '
            'wegkommst — dann brauchst du am Ende gar nicht zu '
            'rangieren.',
          ),
          BulletsBlock([
            'Wenn möglich vorwärts einparken und vorwärts wieder '
                'wegfahren',
            'Lieber 40 Meter weiter halten als in eine enge Einfahrt '
                'zurücksetzen',
            'Bei Sackgassen und Höfen: vor dem Hineinfahren überlegen, '
                'wie du wieder herauskommst',
            'Wendemöglichkeiten auf der Route merken — sie sind jeden '
                'Tag dieselben',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Was Recht und DGUV verlangen',
            text: '§ 9 Abs. 5 StVO: Beim Rückwärtsfahren musst du eine '
                'Gefährdung anderer ausschließen, erforderlichenfalls '
                'einweisen lassen. Die DGUV Vorschrift 70 (Fahrzeuge) '
                'verlangt dasselbe: Rückwärtsfahren nur, wenn eine '
                'Gefährdung von Personen ausgeschlossen ist.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL — Get Out And Look',
        asset: 'assets/academy/driving/m04b_goal.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'GOAL',
            text: '„Get Out And Look" — anhalten, aussteigen, hinter dem '
                'Fahrzeug nachsehen, dann erst zurücksetzen. Das deckt '
                'genau die Dinge auf, die du vom Sitz aus nie siehst.',
          ),
          ParagraphBlock(
            'Der Rundgang dauert zehn bis fünfzehn Sekunden. In dieser '
            'Zeit siehst du niedrige Poller, Bordsteinkanten, Gefälle, '
            'lose Gullydeckel, spielende Kinder und die Höhe der '
            'Toreinfahrt. Nichts davon zeigt dir eine Rückfahrkamera '
            'zuverlässig.',
          ),
          FactsBlock([
            FactItem('15 s', 'dauert ein GOAL-Rundgang'),
            FactItem('90 cm', 'Höhe, unter der ein Kind hinter dem '
                'Fahrzeug unsichtbar bleibt'),
          ]),
          ParagraphBlock(
            'Und noch etwas: Was du beim Aussteigen gesehen hast, '
            'behältst du im Kopf. Du fährst danach nicht ins Ungewisse, '
            'sondern auf ein Bild zu, das du kennst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'GOAL Schritt für Schritt',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/goal01_stopp.svg',
              title: '1 · Anhalten',
              caption: 'Bevor du den Rückwärtsgang einlegst, hältst du '
                  'vollständig an und sicherst das Fahrzeug. Wer schon '
                  'rollt, entscheidet nicht mehr — er reagiert nur '
                  'noch.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal02_aussteigen.svg',
              title: '2 · Aussteigen',
              caption: 'Steig aus, statt dich im Sitz zu verrenken. '
                  'Nutze dabei die Trittstufe und die Haltegriffe — '
                  'die Drei-Punkt-Regel gilt auch hier.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal03_umschauen.svg',
              title: '3 · Umschauen',
              caption: 'Geh einmal komplett um das Fahrzeug: Was steht '
                  'tief hinter dem Heck, wie hoch ist die Einfahrt, wo '
                  'ist Gefälle, sind Kinder oder Tiere in der Nähe? '
                  'Präge dir Abstände und Fixpunkte ein.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/goal04_zurueck.svg',
              title: '4 · Langsam zurück',
              caption: 'Erst jetzt zurücksetzen — im Schritttempo, mit '
                  'Blick über die Schulter und in beide Spiegel. Im '
                  'Zweifel noch einmal anhalten und neu schauen.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Langsam heißt nicht harmlos',
        blocks: [
          StepsBlock([
            'Schritttempo wählen — nie schneller, auch nicht auf dem '
                'leeren Hof',
            'Fenster herunterlassen, um zu hören: Rufe, Hupen, Kinder',
            'Über die Schulter und in beide Spiegel schauen, im '
                'Wechsel',
            'Kamera nur als Ergänzung nutzen, nie als einzige Quelle',
            'Bei jedem Zweifel anhalten, aussteigen, neu schauen',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Der Kamera-Trugschluss',
            text: 'Die Rückfahrkamera zeigt einen Ausschnitt, verzerrt '
                'Abstände und wird von Regen, Schnee und Schmutz '
                'blind. Sie sieht nichts, was seitlich neben dem Heck '
                'in deine Bahn läuft. Sie ersetzt GOAL nicht.',
          ),
          FactsBlock([
            FactItem('Schritt', 'maximales Tempo beim Rangieren'),
            FactItem('2 s', 'braucht ein Kind, um in den Bereich hinter '
                'dem Fahrzeug zu laufen'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Einweiser richtig nutzen',
        blocks: [
          ParagraphBlock(
            'Ein Einweiser hilft nur, wenn die Regeln vorher klar sind. '
            'Ein Kollege, der irgendwo hinter dem Fahrzeug steht und '
            'winkt, ist keine Sicherheit — er ist ein zusätzliches '
            'Risiko.',
          ),
          BulletsBlock([
            'Zeichen vorher absprechen: Stopp, langsam, weiter, wie '
                'viel Platz',
            'Der Einweiser steht seitlich, nie direkt hinter dem '
                'Fahrzeug',
            'Du musst ihn durchgehend im Spiegel sehen — sonst gilt '
                'Stopp',
            'Nur eine Person weist ein, nicht mehrere gleichzeitig',
            'Der Einweiser trägt Warnweste, besonders bei Dämmerung',
          ]),
          RevealBlock(
            prompt: 'Du setzt in eine enge Hofeinfahrt zurück, dein '
                'Kollege weist ein. Plötzlich siehst du ihn im Spiegel '
                'nicht mehr. Was tust du?',
            answer: 'Sofort stoppen — nicht langsamer werden, sondern '
                'anhalten. Kein Sichtkontakt bedeutet kein gültiges '
                'Zeichen. Vielleicht ist er hinter dem Fahrzeug '
                'entlanggegangen, ausgerutscht oder wurde von einem '
                'Passanten angesprochen. Erst weiterfahren, wenn du ihn '
                'wieder siehst und er dir ein neues Zeichen gibt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fallbeispiel: die enge Hofeinfahrt',
        blocks: [
          RevealBlock(
            prompt: 'Fallbeispiel: Der letzte Stopp liegt in einem '
                'Innenhof. Die Einfahrt ist eng, hinter dir wartet ein '
                'Auto, es regnet und du bist 40 Minuten hinter dem '
                'Plan. Vorwärts kommst du rein — raus nur rückwärts, an '
                'einer Mauer und drei geparkten Autos vorbei. Was ist '
                'die richtige Entscheidung?',
            answer: 'Gar nicht erst hineinfahren. Halte auf der Straße, '
                'trage die letzten Meter zu Fuß oder nutze die '
                'Sackkarre. Wenn du schon drin bist: Warnblinker an, '
                'aussteigen, Lage ansehen, gegebenenfalls den wartenden '
                'Fahrer bitten zurückzusetzen, und dann in mehreren '
                'kurzen Zügen mit Zwischenkontrollen herausrangieren. '
                'Der wartende Fahrer hinter dir ist kein Grund zur '
                'Eile — der Schaden zählt am Ende dir, nicht ihm. Die '
                '40 Minuten Verspätung holt kein Rangiermanöver auf, '
                'aber ein Blechschaden kostet dich den Rest des Tages.',
          ),
          DoDontBlock(
            doTitle: 'Richtig rangieren',
            dos: [
              'In mehreren kurzen Zügen statt in einem langen',
              'Zwischendurch anhalten und die Lage neu prüfen',
              'Warnblinker beim Rangieren im Verkehrsraum',
              'Lieber weiter weg halten und die letzten Meter laufen',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Unter Druck von Wartenden schneller rangieren',
              'Mit einem Zug „durchziehen", weil es sonst peinlich '
                  'wirkt',
              'Nur auf Kamera oder Sensoren vertrauen',
              'Rangieren, während Fußgänger den Bereich queren',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: rückwärts & rangieren',
        blocks: [
          ChecklistBlock(
            title: 'Vor jedem Rückwärtsmanöver',
            items: [
              'Ich prüfe zuerst, ob ich das Rückwärtsfahren vermeiden '
                  'kann',
              'Ich halte vollständig an, bevor ich den Rückwärtsgang '
                  'einlege',
              'Ich steige aus und schaue hinter das Fahrzeug (GOAL)',
              'Ich fahre nur im Schritttempo zurück',
              'Ich schaue über die Schulter und in beide Spiegel, nicht '
                  'nur auf die Kamera',
              'Ich lasse das Fenster herunter, um zu hören',
              'Ich halte sofort an, wenn ich den Einweiser nicht mehr '
                  'sehe',
              'Ich melde jeden Rangierschaden, auch die kleine Delle',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M5
  SafetyChapterContent(
    id: 'm5',
    title: 'Wetter, Sicht & schwierige Bedingungen',
    summary: 'Fahrweise an Regen, Nässe, Nebel, Schnee, Dunkelheit und '
        'Hitze anpassen',
    asset: 'assets/academy/driving/m05_wetter.svg',
    slides: [
      SafetySlide(
        title: 'Nässe verändert alles',
        blocks: [
          ParagraphBlock(
            'Auf nasser Fahrbahn sinkt die Haftung deutlich — der '
            'Bremsweg verlängert sich erheblich, in vielen Situationen '
            'auf annähernd das Doppelte. Besonders kritisch ist der '
            'erste Regen nach einer langen Trockenphase: Öl und Gummi '
            'auf der Fahrbahn bilden mit dem Wasser einen rutschigen '
            'Film.',
          ),
          FactsBlock([
            FactItem('bis ×2', 'so lang wird der Bremsweg bei Nässe'),
            FactItem('3 s+', 'Mindestabstand statt 2 Sekunden'),
            FactItem('−20 %', 'Tempo als grobe Orientierung'),
          ]),
          BulletsBlock([
            'Früher und sanfter bremsen, nicht in der Kurve',
            'Lenkbewegungen weich ausführen, nicht ruckartig',
            'Auf Fahrbahnmarkierungen, Gullydeckel und Straßenbahn'
                'schienen achten — dort ist es am rutschigsten',
            'Spurrillen meiden, dort steht das Wasser',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Geschwindigkeit ist Pflicht, nicht Wahl',
            text: '§ 3 Abs. 1 StVO verlangt, dass du deine '
                'Geschwindigkeit den Straßen-, Verkehrs-, Sicht- und '
                'Wetterverhältnissen anpasst. Bei einem Unfall auf '
                'nasser Straße hilft dir das erlaubte Tempo nicht '
                'weiter.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: was da wirklich passiert',
        asset: 'assets/academy/driving/m05b_aquaplaning.svg',
        blocks: [
          ParagraphBlock(
            'Aquaplaning heißt: Zwischen Reifen und Fahrbahn schiebt '
            'sich ein Wasserfilm. Der Reifen schwimmt auf. Von diesem '
            'Moment an haben Lenkung und Bremse keine Wirkung mehr — '
            'nicht weniger, sondern keine.',
          ),
          ParagraphBlock(
            'Die Profilrillen haben genau eine Aufgabe: das Wasser vor '
            'dem Reifen wegzuleiten. Bei höherem Tempo muss ein Reifen '
            'in jeder Sekunde etliche Liter Wasser verdrängen. Je '
            'flacher das Profil und je höher das Tempo, desto früher '
            'schafft er das nicht mehr.',
          ),
          FactsBlock([
            FactItem('1,6 mm', 'gesetzliches Minimum — für Aquaplaning '
                'schon zu wenig'),
            FactItem('3 mm', 'praktische Untergrenze bei nassem '
                'Wetter'),
            FactItem('Tempo²', 'so stark steigt die Aquaplaning-'
                'Gefahr mit der Geschwindigkeit'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Woran du es früh merkst',
            text: 'Die Lenkung wird plötzlich leicht, die Fahrgeräusche '
                'ändern sich, die Drehzahl steigt ohne Grund. Das sind '
                'die Sekunden, in denen du noch vom Gas gehen kannst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aquaplaning: die richtige Reaktion',
        blocks: [
          DoDontBlock(
            doTitle: 'Bei stehendem Wasser richtig',
            dos: [
              'Gas wegnehmen — nur das, kein Vollgas-Aus',
              'Lenkung ruhig und geradeaus halten',
              'Kupplung treten bzw. auskuppeln lassen',
              'Wagen ausrollen lassen, bis die Reifen wieder greifen',
              'Erst danach vorsichtig lenken oder bremsen',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Kräftig bremsen — die Räder blockieren wirkungslos',
              'Ruckartig lenken oder gegenlenken',
              'Beschleunigen, um „durchzukommen"',
              'Die Spur wechseln, während die Reifen aufschwimmen',
            ],
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Auf der Bundesstraße steht nach '
                'einem Gewitter Wasser in der rechten Spurrille. Du '
                'fährst 80 km/h, hinter dir drängelt ein Pkw. Was '
                'machst du?',
            answer: 'Deutlich vom Gas gehen, bevor du in das Wasser '
                'einfährst — nicht darin. Halte die Lenkung gerade und '
                'lass den Drängler drängeln; ein Auffahrunfall ist '
                'reparabel, ein Abflug in den Gegenverkehr nicht. Wer '
                'stattdessen mitten im Wasser bremst oder ausweicht, '
                'provoziert genau den Kontrollverlust, den er '
                'vermeiden will. Wenn möglich: nach dem Wasser rechts '
                'halten und den Drängler vorbeilassen.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ein aufschwimmender Reifen lenkt nicht',
            text: 'Solange der Wasserfilm trägt, ist jede Lenkbewegung '
                'wirkungslos — sie wirkt erst schlagartig, wenn der '
                'Reifen wieder greift. Genau daraus entsteht der '
                'Schleudervorgang.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Profiltiefe & Winterreifen',
        blocks: [
          TableBlock(
            headers: ['Situation', 'Profil / Reifen'],
            rows: [
              ['Gesetzliches Minimum', '1,6 mm — ganzjährig'],
              ['Sommer, nasse Straße', 'ab 3 mm empfohlen'],
              ['Winter, Schnee & Matsch', 'ab 4 mm empfohlen'],
              ['Glätte, Schnee, Eis', 'Winterreifen mit Alpine-Symbol'],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Situative Winterreifenpflicht',
            text: 'Nach § 2 Abs. 3a StVO darfst du bei Glatteis, '
                'Schneeglätte, Schneematsch, Eis- oder Reifglätte nur '
                'mit wintertauglichen Reifen fahren. Verstöße kosten '
                'Bußgeld und einen Punkt — bei Behinderung anderer '
                'mehr.',
          ),
          BulletsBlock([
            'Winterreifen erkennst du am Alpine-Symbol (Berg mit '
                'Schneeflocke)',
            'Auch wintertaugliche Reifen wirken bei zu wenig Profil '
                'kaum noch',
            'Reifenalter beachten: Gummi härtet aus und verliert '
                'Grip, auch wenn das Profil noch da ist',
            'Melde dünnes Profil, bevor der erste Frost kommt — nicht '
                'am Morgen danach',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Schnee, Eis & Freikratzen',
        asset: 'assets/academy/driving/m05c_winter.svg',
        blocks: [
          ParagraphBlock(
            'Bei Glätte gilt für alles: sanft. Sanft anfahren, sanft '
            'bremsen, sanft lenken. Jede ruckartige Bewegung überfordert '
            'den ohnehin geringen Grip. Brücken, Waldstücke und '
            'Schattenstellen frieren zuerst — und tauen zuletzt auf.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Kein „Guckloch"',
            text: 'Alle Scheiben, Spiegel, Leuchten und das Kennzeichen '
                'müssen frei sein (§ 23 Abs. 1 StVO). Ein freigekratztes '
                'Guckloch ist eine Ordnungswidrigkeit — und bei einem '
                'Unfall ein schwerer Verschuldensvorwurf. Auch Schnee '
                'auf dem Dach muss herunter, bevor du losfährst.',
          ),
          DoDontBlock(
            doTitle: 'Winterroutine',
            dos: [
              'Alle Scheiben und Spiegel komplett freikratzen',
              'Dach, Lichter und Kennzeichen von Schnee befreien',
              'Trittstufen und Haltegriffe von Eis und Matsch '
                  'säubern',
              'Wischwasser mit Frostschutz auffüllen',
              'Deutlich früher losfahren statt unterwegs aufzuholen',
            ],
            dontTitle: 'Winterfehler',
            donts: [
              'Losfahren, während die Scheibe noch abtaut',
              'Heißes Wasser auf die Scheibe gießen',
              'Auf Schneematsch bremsen und gleichzeitig lenken',
              'Vereiste Trittstufen ignorieren — hier stürzt du',
            ],
          ),
          FactsBlock([
            FactItem('0 °C', 'ab hier zuerst Brücken und '
                'Schattenstellen'),
            FactItem('×2 bis ×10', 'so viel länger wird der Bremsweg '
                'auf Schnee und Eis'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Nebel, Dämmerung, Dunkelheit',
        blocks: [
          ParagraphBlock(
            'Bei schlechter Sicht ist nicht nur das Sehen schwerer, '
            'sondern auch das Gesehenwerden. Licht rechtzeitig '
            'einschalten — im Zweifel eine halbe Stunde früher als '
            'nötig.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Faustregel bei Nebel',
            text: 'Sichtweite in Metern entspricht dem maximalen Tempo '
                'in km/h. Siehst du nur 50 Meter weit, fährst du '
                'höchstens 50 km/h — und bei Sichtweite unter 50 Metern '
                'gilt ohnehin Tempo 50 als Obergrenze.',
          ),
          BulletsBlock([
            'Nebelscheinwerfer nur bei echter Sichtbehinderung, nicht '
                'als Dauerbeleuchtung',
            'Nebelschlussleuchte erst unter 50 Metern Sichtweite — sie '
                'blendet den Hintermann stark',
            'Leitpfosten am Fahrbahnrand als Orientierung nutzen',
            'Bei Dämmerung besonders auf Fußgänger in dunkler Kleidung '
                'achten',
            'Innenraumbeleuchtung aus, Scheiben innen sauber — beides '
                'kostet sonst Nachtsicht',
          ]),
          FactsBlock([
            FactItem('50 m', 'Abstand zwischen zwei Leitpfosten '
                'außerorts'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Sturm & Seitenwind',
        blocks: [
          ParagraphBlock(
            'Dein Kastenwagen ist eine große, hohe Fläche — im '
            'Seitenwind verhält er sich völlig anders als ein Pkw. '
            'Besonders gefährlich sind Stellen, an denen der Wind '
            'plötzlich einsetzt: Brücken, Waldausgänge, Lücken zwischen '
            'Gebäuden und beim Überholtwerden von Lkw.',
          ),
          BulletsBlock([
            'Tempo deutlich reduzieren, beide Hände ans Lenkrad',
            'An bekannten Windstellen den Griff vorher festigen und '
                'mit einer Böe rechnen',
            'Nach dem Überholen eines Lkw mit einem Windstoß rechnen',
            'Bei Sturm nicht unter Bäumen und nicht neben Baugerüsten '
                'parken',
            'Türen im Wind festhalten — sie werden aufgerissen und '
                'beschädigt',
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Sturmwarnung, du fährst leer über '
                'eine Autobahnbrücke. Warum ist ausgerechnet leer '
                'kritisch?',
            answer: 'Weil dem Fahrzeug das Gewicht fehlt, das es auf '
                'der Straße hält. Ein leerer Kastenwagen bietet '
                'dieselbe Angriffsfläche wie ein beladener, wiegt aber '
                'gut ein Drittel weniger — eine Böe versetzt ihn '
                'deutlich stärker. Richtig ist: vor der Brücke Tempo '
                'raus, beide Hände ans Lenkrad, mit dem Windstoß am '
                'Brückenende rechnen und nicht neben einem Lkw '
                'fahren.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Hitze & lange Touren',
        blocks: [
          ParagraphBlock(
            'Im Sommer arbeitest du in einem Fahrzeug, das sich in der '
            'Sonne stark aufheizt, und läufst dabei viele Kilometer. '
            'Ein überhitzter, dehydrierter Fahrer reagiert messbar '
            'langsamer — der Effekt ist mit dem von Müdigkeit '
            'vergleichbar.',
          ),
          FactsBlock([
            FactItem('2–3 l', 'Flüssigkeit pro Schicht bei Hitze'),
            FactItem('> 60 °C', 'Innenraumtemperatur in einem in der '
                'Sonne stehenden Fahrzeug'),
          ]),
          BulletsBlock([
            'Regelmäßig trinken, bevor du Durst spürst',
            'Pausen im Schatten, nicht im aufgeheizten Fahrerhaus',
            'Kopfbedeckung und Sonnenschutz bei langen Laufwegen',
            'Bei Kreislaufproblemen sofort melden und Pause machen',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Niemals zurücklassen',
            text: 'Nie ein Tier oder eine Person im aufgeheizten Wagen '
                'zurücklassen — auch nicht „nur fünf Minuten" und auch '
                'nicht mit gekipptem Fenster. Der Innenraum wird in '
                'Minuten lebensgefährlich heiß.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: schwierige Bedingungen',
        blocks: [
          ChecklistBlock(
            title: 'Bei Wetter und schlechter Sicht',
            items: [
              'Ich passe Tempo und Abstand an, nicht nur an das Schild',
              'Ich erhöhe bei Nässe auf mindestens 3 Sekunden Abstand',
              'Bei Aquaplaning: Gas weg, geradeaus, nicht bremsen',
              'Ich kenne meine Profiltiefe und melde dünne Reifen '
                  'früh',
              'Ich kratze alle Scheiben frei, kein Guckloch',
              'Ich räume Schnee vom Dach, den Lichtern und vom '
                  'Kennzeichen',
              'Ich rechne an Brücken und Waldausgängen mit Seitenwind',
              'Ich trinke ausreichend und mache Pausen im Schatten',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M6
  SafetyChapterContent(
    id: 'm6',
    title: 'Ablenkung, Müdigkeit & Zeitdruck',
    summary: 'Die menschlichen Hauptursachen für Unfälle erkennen und '
        'aktiv gegensteuern',
    asset: 'assets/academy/driving/m06_ablenkung.svg',
    slides: [
      SafetySlide(
        title: 'Handy am Steuer: VERBOTEN',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Das Handy in der Hand ist während der Fahrt verboten',
            text: 'Nicht zum Telefonieren, nicht zum Tippen, nicht zum '
                'Nachschauen — und auch nicht zum Musik-, Podcast- oder '
                'Nachrichten-Auswählen.',
          ),
          ParagraphBlock(
            'Ganz klar und ohne Ausnahme. Das ist nicht nur unsere '
            'Firmenregel, sondern Gesetz. Und es gilt für jedes '
            'elektronische Gerät, das der Kommunikation, Information '
            'oder Organisation dient — also auch für den Scanner.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 23 Abs. 1a StVO',
            text: 'Wer ein Fahrzeug führt, darf ein elektronisches Gerät '
                'nur benutzen, wenn es dafür weder aufgenommen noch '
                'gehalten wird. Schon das Aufnehmen oder Halten in der '
                'Hand ist der Verstoß — unabhängig davon, was du damit '
                'machst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Strecke im Blindflug',
        asset: 'assets/academy/driving/m06b_handy.svg',
        blocks: [
          ParagraphBlock(
            'Ein Blick aufs Display ist keine Sekunde — er dauert im '
            'Schnitt zwei bis drei Sekunden, eine gelesene Nachricht '
            'eher fünf. In dieser Zeit fährst du mit geschlossenen '
            'Augen. Rechne es einmal in Metern durch.',
          ),
          FactsBlock([
            FactItem('14 m/s', 'legst du bei Tempo 50 pro Sekunde '
                'zurück'),
            FactItem('28 m', 'blind bei 2 Sekunden Blick aufs Handy'),
            FactItem('ca. 70 m', 'blind, wenn du eine Nachricht liest'),
          ]),
          RevealBlock(
            prompt: 'Rechenaufgabe: Du fährst 30 km/h durch eine '
                'Spielstraße und schaust 3 Sekunden auf den Scanner. '
                'Wie weit fährst du blind — und reicht das für einen '
                'Unfall?',
            answer: 'Bei 30 km/h legst du gut 8 Meter pro Sekunde '
                'zurück, in 3 Sekunden also rund 25 Meter. Das ist '
                'mehr als der komplette Anhalteweg bei diesem Tempo '
                '(18 Meter). Anders gesagt: Du durchfährst blind eine '
                'Strecke, auf der du bei Sicht längst hättest anhalten '
                'können. Wer denkt, bei niedrigem Tempo sei ein Blick '
                'unkritisch, verwechselt langsam mit sicher — gerade '
                'in Spielstraßen laufen Kinder ohne Vorwarnung auf die '
                'Fahrbahn.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Musik, Navi, Scanner — alles vorher',
        blocks: [
          ParagraphBlock(
            'Musik und Podcasts sind okay — aber nicht mit dem Handy in '
            'der Hand. Alles vor Fahrtantritt im Stand auswählen und '
            'starten: Playlist, Lautstärke, Navi-Ziel, nächster Stopp. '
            'Läuft es einmal, wird während der Fahrt nichts mehr am '
            'Gerät angefasst.',
          ),
          DoDontBlock(
            doTitle: 'Erlaubt',
            dos: [
              'Playlist und Lautstärke vorher im Stand einstellen',
              'Navi-Ziel vor dem Losfahren eingeben',
              'Handy in der Halterung liegen lassen und nur '
                  'anschauen',
              'Freihändig über die Freisprechanlage sprechen',
              'Für alles andere kurz anhalten',
            ],
            dontTitle: 'Verboten',
            donts: [
              'Song oder Podcast während der Fahrt wechseln',
              'Nachricht während der Fahrt lesen oder tippen',
              'Handy an der roten Ampel in die Hand nehmen',
              'Scanner oder Stopp-Liste im Rollen bedienen',
              'Das Gerät vom Halter nehmen, um es besser zu sehen',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Keine Kopfhörer',
            text: 'Keine Kopfhörer oder Ohrhörer während der Fahrt — '
                'auch nicht auf einem Ohr. Du musst Verkehr, Hupen, '
                'Rufe und Einsatzfahrzeuge hören. Beim Rangieren ist '
                'dein Gehör oft die einzige Warnung.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die einzige Ausnahme: im Stand, Motor aus',
        blocks: [
          ParagraphBlock(
            'Handy, Scanner und Navi bedienst du nur im sicheren Stand. '
            'Der praktische Ablauf am Stopp: anhalten, Motor aus, '
            'Gerät bedienen, dann aussteigen. Und vor dem Losfahren: '
            'einsteigen, Ziel und Musik einstellen, dann starten.',
          ),
          RevealBlock(
            prompt: 'Ab wann zählt „Stand" rechtlich — und was ist mit '
                'der Start-Stopp-Automatik an der roten Ampel?',
            answer: 'Rechtlich zählt der Stand erst, wenn der Motor '
                'ausgeschaltet ist. Die Ausnahme greift ausdrücklich '
                'nicht, wenn der Motor nur durch eine automatische '
                'Start-Stopp-Funktion ruht. An der roten Ampel darfst '
                'du das Gerät also nicht in die Hand nehmen — auch '
                'nicht, wenn der Motor gerade still ist.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Ausnahme nur bei ausgeschaltetem Motor',
            text: 'Die Bedienung ist nur zulässig, wenn das Fahrzeug '
                'steht und der Motor ausgeschaltet ist. Eine '
                'automatische Start-Stopp-Abschaltung genügt dafür '
                'nicht.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Was es kostet',
        blocks: [
          FactsBlock([
            FactItem('100 € + 1 Punkt', 'Handy in der Hand während der '
                'Fahrt'),
            FactItem('150 € + 2 Punkte', 'mit Gefährdung, dazu 1 Monat '
                'Fahrverbot'),
            FactItem('200 € + 2 Punkte', 'mit Sachbeschädigung, dazu '
                '1 Monat Fahrverbot'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Probezeit',
            text: 'In der Führerschein-Probezeit kommen ein '
                'Aufbauseminar und die Verlängerung der Probezeit auf '
                '4 Jahre dazu.',
          ),
          ParagraphBlock(
            'Für dich als Berufsfahrer heißt ein Fahrverbot: kein Job '
            'für einen Monat. Und wenn aus der Ablenkung ein Unfall '
            'mit Verletzten wird, bleibt es nicht beim Bußgeld — dann '
            'steht der Vorwurf der Gefährdung des Straßenverkehrs im '
            'Raum (§ 315c StGB), und der ist eine Straftat.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die einfachste Versicherung',
            text: 'Das Handy wegzulegen kostet nichts und schützt '
                'deinen Führerschein, deinen Arbeitsplatz und im '
                'Ernstfall ein Leben.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ablenkung hat viele Formen',
        blocks: [
          ParagraphBlock(
            'Nicht nur das Handy: Essen, Trinken, Suchen nach Paketen, '
            'Gespräche, Ärger über den letzten Kunden, Gedanken beim '
            'nächsten Stopp. Ablenkung ist alles, was Augen, Hände oder '
            'Kopf von der Straße wegnimmt.',
          ),
          DoDontBlock(
            doTitle: 'Okay während der Fahrt',
            dos: [
              'Auf die Straße schauen',
              'Freihändig über die Freisprechanlage sprechen',
              'Kurze Blicke in die Spiegel',
              'Für alles andere kurz anhalten',
            ],
            dontTitle: 'Nicht okay',
            donts: [
              'Essen oder Getränk auspacken',
              'Im Laderaum nach dem nächsten Paket suchen',
              'Scanner oder Stopp-Liste im Fahren bedienen',
              'Während des Fahrens die Route im Kopf neu sortieren, '
                  'statt kurz zu halten',
            ],
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du merkst beim Losfahren, dass du '
                'die falsche Sendung gegriffen hast. Der richtige '
                'Stopp ist 300 Meter weiter. Was tust du?',
            answer: 'Zum nächsten sicheren Halt fahren, anhalten, Motor '
                'aus, dann im Laderaum tauschen. Der Griff nach hinten '
                'während der Fahrt ist die klassische Situation, in der '
                'Fahrer die Spur verlassen — dabei drehst du '
                'gleichzeitig Kopf und Oberkörper weg. 300 Meter '
                'Umweg dauern 30 Sekunden, ein Streifschaden den Rest '
                'des Tages.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Müdigkeit: dein Körper verhandelt nicht',
        asset: 'assets/academy/driving/m06c_muedigkeit.svg',
        blocks: [
          ParagraphBlock(
            'Müdigkeit ist kein Willensproblem. Ab einem bestimmten '
            'Punkt schaltet dein Gehirn kurz ab — ob du willst oder '
            'nicht. Das Tückische: Genau in dieser Phase '
            'überschätzt du deine eigene Wachheit am stärksten.',
          ),
          SubheadBlock('Die Warnzeichen, die du ernst nehmen musst'),
          BulletsBlock([
            'Häufiges Gähnen, brennende oder schwere Augen',
            'Du erinnerst dich an die letzten Kilometer nicht',
            'Du verpasst Abzweigungen oder Stopps',
            'Der Sitzabstand fühlt sich plötzlich falsch an, du '
                'rutschst herum',
            'Du fährst unruhig in der Spur oder korrigierst ständig',
            'Frieren und Nackenverspannung ohne äußeren Grund',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Risikozeiten',
            text: 'Am gefährlichsten sind die frühen Morgenstunden, das '
                'Tief nach dem Mittagessen und die letzte Stunde der '
                'Tour. Plane genau dort deine Pausen ein.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sekundenschlaf in Metern',
        blocks: [
          ParagraphBlock(
            'Ein Sekundenschlaf dauert typischerweise zwei bis fünf '
            'Sekunden. Das klingt kurz — bis man es in Metern '
            'ausrechnet.',
          ),
          FactsBlock([
            FactItem('56 m', 'bei Tempo 50 in 4 Sekunden '
                'Sekundenschlaf'),
            FactItem('89 m', 'bei Tempo 80 in 4 Sekunden'),
            FactItem('111 m', 'bei Tempo 100 in 4 Sekunden'),
          ]),
          RevealBlock(
            prompt: 'Rechenaufgabe: Du fährst 80 km/h auf der '
                'Landstraße und nickst 4 Sekunden weg. Wie weit fährst '
                'du unkontrolliert — und was liegt auf dieser Strecke?',
            answer: '80 km/h sind rund 22 Meter pro Sekunde, in 4 '
                'Sekunden also etwa 89 Meter. Auf dieser Strecke liegen '
                'auf einer Landstraße typischerweise eine Kurve, eine '
                'Baumreihe und der Gegenverkehr. Und anders als beim '
                'Handyblick lenkst du in dieser Zeit nicht — das '
                'Fahrzeug driftet aus der Spur. Deshalb hilft gegen '
                'Sekundenschlaf nur eines: vorher anhalten.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Es gibt keine kleine Version davon',
            text: 'Wer einmal weggenickt ist, nickt wieder weg — meist '
                'innerhalb weniger Minuten. Die Fahrt endet hier, nicht '
                'am nächsten Stopp.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Was hilft — und was nicht',
        blocks: [
          DoDontBlock(
            doTitle: 'Wirkt wirklich',
            dos: [
              'Anhalten und 15–20 Minuten die Augen schließen',
              'Aussteigen, gehen, frische Luft und Bewegung',
              'Etwas essen und trinken',
              'Die Tour melden und Unterstützung anfordern, wenn es '
                  'nicht reicht',
            ],
            dontTitle: 'Wirkt nicht (oder nur Minuten)',
            donts: [
              'Fenster auf und laute Musik',
              'Kaffee als Ersatz für Schlaf',
              'Sich mit Gesprächen wachhalten',
              'Schneller fahren, um früher fertig zu sein',
            ],
          ),
          ParagraphBlock(
            'Ein Kurzschlaf von 15 bis 20 Minuten mit anschließender '
            'Bewegung ist die einzige Maßnahme, die kurzfristig '
            'wirklich etwas bringt. Alles andere verschiebt das Problem '
            'nur um ein paar Kilometer.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Fahruntüchtigkeit',
            text: 'Wer trotz erkennbarer Übermüdung weiterfährt, führt '
                'das Fahrzeug fahruntüchtig. Kommt es dabei zu einer '
                'Gefährdung, ist das kein Bußgeld mehr, sondern eine '
                'Straftat (§ 315c StGB).',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zeitdruck clever managen & Checkliste',
        blocks: [
          ParagraphBlock(
            'Zeitdruck ist real — aber Rasen und Hetze sparen kaum Zeit '
            'und kosten viel Risiko. Der Zeitgewinn durch schnelleres '
            'Fahren liegt im Stadtverkehr im Bereich von Minuten; ein '
            'einziger Rangierschaden kostet dich eine Stunde.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Wenn der Plan nicht aufgeht',
            text: 'Das ist kein Sicherheitsproblem, das ist ein '
                'Planungsthema — melde es früh, statt es am Steuer '
                'auszugleichen. Eine Meldung um 13 Uhr hilft, eine um '
                '18 Uhr nicht mehr.',
          ),
          ChecklistBlock(
            title: 'Das nehme ich aus Modul 6 mit',
            items: [
              'Mein Handy bleibt während der Fahrt unberührt',
              'Musik, Navi und Scanner stelle ich vor dem Losfahren '
                  'ein',
              'Ich weiß, dass „Stand" erst bei ausgeschaltetem Motor '
                  'zählt',
              'Ich trage keine Kopfhörer',
              'Ich kenne meine persönlichen Müdigkeitszeichen',
              'Bei Müdigkeit halte ich an, statt durchzuhalten',
              'Ich melde einen unrealistischen Plan früh und ehrlich',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M7
  SafetyChapterContent(
    id: 'm7',
    title: 'Arbeitsunfälle: Ein-/Aussteigen, Heben & Stürze',
    summary: 'Verletzungen abseits des Fahrens vermeiden — Schwerpunkt '
        'sicheres Ein- und Aussteigen',
    asset: 'assets/academy/driving/m07_ein_aussteigen.svg',
    slides: [
      SafetySlide(
        title: 'Warum das der wichtigste Handgriff des Tages ist',
        blocks: [
          ParagraphBlock(
            'Du steigst pro Tour dutzende Male ein und aus — das ist die '
            'Bewegung, die du am häufigsten machst. Genau deshalb '
            'passieren hier die meisten Verletzungen: Umknicken, '
            'Abrutschen an der Trittkante, Sturz aus dem Wagen, '
            'Fehltritt in den Verkehr.',
          ),
          FactsBlock([
            FactItem('100.000', 'Rutsch-, Stolper- und Sturzunfälle bei '
                'Berufsfahrern pro Jahr'),
            FactItem('24', 'Ausfalltage im Schnitt pro Sturz'),
            FactItem('Nr. 1', 'häufigste Verletzungsart in der '
                'Zustellung'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'BG Verkehr warnt',
            text: 'Die BG Verkehr warnt ausdrücklich, dass Abstürze beim '
                'Ein- und Aussteigen zu schweren, mitunter tödlichen '
                'Verletzungen führen.',
          ),
          ParagraphBlock(
            'Der Unterschied zwischen einem sicheren und einem '
            'gefährlichen Ausstieg sind zwei Sekunden. Auf 250 '
            'Ausstiege pro Tag gerechnet sind das gut acht Minuten — '
            'die günstigste Versicherung deines Körpers.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die 3-Punkt-Regel (2+1)',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Zwei Hände und ein Fuß — immer',
            text: 'Die zentrale Regel der BG Verkehr: Zwei Hände und ein '
                'Fuß sind immer in Kontakt mit dem Fahrzeug — „2+1".',
          ),
          ParagraphBlock(
            'Du hast also jederzeit drei feste Kontaktpunkte, bevor du '
            'den nächsten löst. So kann ein einzelner Ausrutscher nie '
            'zum Sturz werden, weil dich immer noch zwei Punkte halten. '
            'Bewege immer nur einen Punkt, nie zwei gleichzeitig.',
          ),
          RevealBlock(
            prompt: 'Welche drei Kontaktpunkte sind gemeint — und was '
                'zählt ausdrücklich nicht dazu?',
            answer: 'Linke Hand am Haltegriff, rechte Hand am '
                'Haltegriff, ein Fuß auf der Trittstufe. Nicht dazu '
                'zählen: das Lenkrad, die Türkante, der Sitz, der '
                'Reifen und die Radnabe. Türkante und Lenkrad geben '
                'nach oder drehen sich weg — genau dann, wenn du sie '
                'brauchst.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Merksatz',
            text: 'Erst absteigen, dann greifen. Gegenstände zuerst im '
                'Fahrzeug ablegen, dann mit freien Händen aussteigen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Richtig rein, richtig raus',
        blocks: [
          BulletsBlock([
            'Einsteigen: mit dem Gesicht vorwärts zum Fahrzeug',
            'Aussteigen: rückwärts, mit dem Gesicht zum Fahrzeug — wie '
                'auf einer Leiter, nie mit dem Rücken zur Tür '
                'herausdrehen',
            'Alle Trittstufen nutzen — keine auslassen',
            'Haltegriffe benutzen, nicht die Türkante oder das Lenkrad '
                'als Notgriff',
            'Beim Ausstieg aus dem Laderaum dieselbe Regel: Gesicht '
                'zum Fahrzeug, Stufe für Stufe',
          ]),
          StepsBlock([
            'Anhalten und Fahrzeug sichern',
            'Gegenstände im Fahrzeug ablegen',
            'Verkehr über Schulter und Spiegel prüfen',
            'Tür kontrolliert öffnen',
            'Umdrehen, Gesicht zum Fahrzeug',
            'Drei Kontaktpunkte herstellen',
            'Stufe für Stufe absteigen',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Niemals springen',
        asset: 'assets/academy/driving/m07b_springen.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Springen ist der häufigste Fehler',
            text: 'Der Absprung aus Fahrerhaus oder Laderaum ist die '
                'häufigste Ursache für umgeknickte Knöchel sowie Knie- '
                'und Rückenverletzungen in der Zustellung.',
          ),
          ParagraphBlock(
            'Der Ladeboden eines Transporters liegt je nach Modell '
            'etwa 55 bis 75 Zentimeter über der Straße. Beim Absprung '
            'wirkt beim Aufkommen ein Vielfaches deines Körpergewichts '
            'auf Sprunggelenk, Knie und Wirbelsäule — und zwar bei '
            'jedem einzelnen Sprung.',
          ),
          FactsBlock([
            FactItem('55–75 cm', 'Höhe des Ladebodens über der Straße'),
            FactItem('250+', 'Ausstiege pro Tour — jeder einzelne zählt '
                'auf die Gelenke'),
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Es regnet, du springst aus dem '
                'Laderaum auf einen abschüssigen Gehweg mit nassem '
                'Laub. Was genau geht dabei schief?',
            answer: 'Beim Absprung kannst du die Landung nicht mehr '
                'korrigieren — du bist in der Luft, und was unter dir '
                'passiert, entscheidet der Untergrund. Nasses Laub auf '
                'Gefälle bietet fast keine Reibung: Der Fuß rutscht '
                'beim Aufkommen weg, das Gelenk knickt seitlich um. '
                'Wer stattdessen Stufe für Stufe mit drei '
                'Kontaktpunkten absteigt, spürt den rutschigen '
                'Untergrund, bevor er sein volles Gewicht darauf '
                'setzt — und kann noch abbrechen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die typischen Fehler',
        blocks: [
          DoDontBlock(
            doTitle: 'Richtig',
            dos: [
              'Gegenstände zuerst im Fahrzeug ablegen',
              'Mit freien Händen und drei Kontaktpunkten absteigen',
              'Trittkanten und Griffe sauber und frei halten',
              'Bei Nässe und Eis Stufen vorher säubern',
              'Sich Zeit nehmen — auch beim 180. Stopp',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Springen statt absteigen',
              'Hände voll — Handy, Scanner, Kaffee, Pakete',
              'Reifen oder Radnabe als Tritt benutzen',
              'Blick aufs Handy beim Absteigen',
              'Nasse, vereiste oder verschmutzte Trittkanten '
                  'ignorieren',
              'Aus dem Sitz heraus seitlich herausdrehen',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der Stopp danach ist der gefährlichste',
            text: 'Nach einem langen Halt sind die Beine steif und die '
                'Konzentration weg. Genau dann passiert der Fehltritt — '
                'kurz sammeln, dann aussteigen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Verkehrsseite: der unterschätzte Moment',
        blocks: [
          ParagraphBlock(
            'Bei niedrigen Sprintern und Transportern ist oft nicht die '
            'Höhe das Problem, sondern der Schritt in den fließenden '
            'Verkehr. Wenn möglich zur Gehweg- oder sicheren Seite '
            'aussteigen. Tür nicht weit aufreißen, bevor du geschaut '
            'hast.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 1 StVO — Ein- und Aussteigen',
            text: 'Wer ein- oder aussteigt, muss sich so verhalten, dass '
                'eine Gefährdung anderer Verkehrsteilnehmer '
                'ausgeschlossen ist. Bei einem Türunfall trifft die '
                'Verantwortung praktisch immer den Aussteigenden.',
          ),
          RevealBlock(
            prompt: 'Du hältst am Fahrbahnrand, ein Radfahrer nähert '
                'sich von hinten — wie steigst du aus?',
            answer: 'Vor dem Öffnen der Tür über die Schulter und in '
                'den Spiegel schauen, den Radfahrer vorbeilassen, die '
                'Tür nur kontrolliert und mit der weiter entfernten '
                'Hand öffnen. Der sogenannte „holländische Griff" — '
                'die Tür mit der rechten Hand öffnen — dreht deinen '
                'Oberkörper automatisch nach hinten und zwingt dich '
                'zum Blick. Radfahrer und Roller ziehen eng am Wagen '
                'vorbei und rechnen nicht mit einer sich öffnenden '
                'Tür.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Schuhwerk & Untergrund',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Empfehlung der BG Verkehr',
            text: 'Schuhwerk, das den Fuß umschließt und rutschfest '
                'ist. Keine offenen oder abgelaufenen Schuhe. '
                'Knöchelhohe Sicherheitsschuhe stützen genau das '
                'Gelenk, das beim Absteigen umknickt.',
          ),
          ParagraphBlock(
            'Vor dem Aussteigen kurz auf den Untergrund achten: '
            'Bordstein, Gefälle, Laub, Nässe, Eis, Rollsplitt. Griffe '
            'und Stufen bei Schnee und Eis frei halten. Wenn möglich '
            'eben und beleuchtet halten.',
          ),
          ChecklistBlock(
            title: 'Vor dem Aussteigen',
            items: [
              'Festes, rutschfestes Schuhwerk an',
              'Untergrund geprüft — Bordstein, Gefälle, Nässe, Eis',
              'Hände frei, Gegenstände abgelegt',
              'Verkehr über Schulter und Spiegel geprüft',
              'Trittstufen sauber und frei',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Richtig heben und tragen',
        blocks: [
          ParagraphBlock(
            'Der Rücken ist das zweithäufigste Ausfallrisiko nach den '
            'Stürzen. Und anders als ein Sturz passiert der '
            'Bandscheibenschaden nicht an einem Tag — er entsteht durch '
            'tausende falsche Hebevorgänge.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/lift01_nah.svg',
              title: '1 · Last nah an den Körper',
              caption: 'Geh dicht an das Paket heran, bevor du es '
                  'anhebst. Jeder Zentimeter Abstand zum Körper '
                  'vervielfacht die Belastung auf die Bandscheiben.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift02_hocke.svg',
              title: '2 · In die Hocke gehen',
              caption: 'Beuge die Knie und geh in die Hocke, statt dich '
                  'aus der Hüfte nach vorn zu klappen. Die Kraft kommt '
                  'aus den Beinen — sie sind der stärkste Muskel, den '
                  'du hast.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift03_ruecken.svg',
              title: '3 · Rücken gerade halten',
              caption: 'Halte den Rücken gerade und den Blick nach '
                  'vorn, während du dich mit den Beinen aufrichtest. '
                  'Ein runder Rücken unter Last ist die klassische '
                  'Bandscheibenposition.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/lift04_drehen.svg',
              title: '4 · Nicht drehen — umtreten',
              caption: 'Dreh dich niemals mit der Last im Oberkörper. '
                  'Setz stattdessen die Füße um und dreh den ganzen '
                  'Körper. Heben plus Drehen ist die gefährlichste '
                  'Kombination für die Wirbelsäule.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Wie schwer ist zu schwer?',
        blocks: [
          ParagraphBlock(
            'Feste Kilogramm-Grenzen gibt es im Gesetz nicht — '
            'entscheidend sind Gewicht, Haltung, Häufigkeit und '
            'Umgebung zusammen. In der Praxis haben sich aber '
            'Orientierungswerte bewährt.',
          ),
          FactsBlock([
            FactItem('ca. 25 kg', 'Orientierung für gelegentliches '
                'Heben (Männer)'),
            FactItem('ca. 15 kg', 'Orientierung für gelegentliches '
                'Heben (Frauen)'),
            FactItem('darüber', 'Hilfsmittel nutzen oder zu zweit '
                'tragen'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Lastenhandhabungsverordnung',
            text: 'Der Arbeitgeber muss manuelles Heben und Tragen so '
                'weit wie möglich vermeiden und geeignete Hilfsmittel '
                'bereitstellen. Du musst diese Hilfsmittel dann auch '
                'benutzen — sie stehen nicht zur Zierde da.',
          ),
          DoDontBlock(
            doTitle: 'Richtig tragen',
            dos: [
              'Sackkarre oder Rollbox nutzen, statt zweimal zu laufen',
              'Sperrige Sendungen zu zweit tragen',
              'Sichtfeld frei halten — nicht über den Stapel '
                  'hinwegschauen',
              'Vor dem Anheben Weg und Absetzpunkt festlegen',
            ],
            dontTitle: 'Falsch tragen',
            donts: [
              'Runder Rücken, gestreckte Arme',
              'Mit Last im Oberkörper verdrehen',
              'Schwung holen und ruckartig anheben',
              'Türme tragen, die die Sicht auf den Weg nehmen',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Stolpern, Rutschen, Stürzen auf dem Weg',
        blocks: [
          ParagraphBlock(
            'Stolpern, Rutschen und Stürzen ist die häufigste '
            'Verletzungsursache in der Zustellung — häufiger als jeder '
            'Verkehrsunfall. Und fast immer passiert es auf den letzten '
            'Metern zwischen Fahrzeug und Haustür.',
          ),
          FactsBlock([
            FactItem('Nr. 1', 'häufigste Unfallart in der Zustellung'),
            FactItem('letzte 30 m', 'zwischen Fahrzeug und Tür — der '
                'gefährlichste Abschnitt'),
          ]),
          BulletsBlock([
            'Festes, rutschfestes Schuhwerk tragen — jeden Tag, auch '
                'im Sommer',
            'Bei Glätte kleine Schritte machen und den ganzen Fuß '
                'aufsetzen',
            'Blick auch mal auf den Weg, nicht nur aufs Paket oder '
                'Handy',
            'Nachts Taschenlampe oder Handylicht für den Weg nutzen',
            'Bekannte Stolperstellen auf der Route im Kopf behalten',
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Du trägst zwei Pakete übereinander '
                'zu einer Haustür mit drei Stufen. Was ist hier das '
                'eigentliche Problem?',
            answer: 'Du siehst deine eigenen Füße und die Stufenkanten '
                'nicht. Ein Treppenaufgang ohne Sicht auf die Stufe ist '
                'die klassische Sturzsituation — und mit vollen Händen '
                'kannst du dich weder am Geländer festhalten noch den '
                'Sturz abfangen. Richtig: einzeln tragen, den Stapel so '
                'niedrig halten, dass du die Stufen siehst, oder die '
                'Sackkarre nutzen. Zweimal laufen dauert 40 Sekunden.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kleine Verletzungen ernst nehmen',
        blocks: [
          ParagraphBlock(
            'Ein verhobener Rücken oder ein umgeknickter Fuß wird '
            'schlimmer, wenn man weitermacht. Aus einer Bagatelle wird '
            'über Wochen ein echter Ausfall — und rückwirkend lässt '
            'sich der Zusammenhang mit der Arbeit oft nicht mehr '
            'nachweisen.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Dokumentieren schützt dich',
            text: 'Jede Verletzung gehört ins Verbandbuch — auch die '
                'kleine. Bei ärztlicher Behandlung nach einem '
                'Arbeitsunfall gehst du zum Durchgangsarzt. Ohne '
                'Dokumentation ist eine spätere Anerkennung als '
                'Arbeitsunfall schwierig.',
          ),
          RevealBlock(
            prompt: 'Warum solltest du kleine Beschwerden sofort melden '
                '— auch wenn du weiterarbeiten kannst?',
            answer: 'Erstens medizinisch: Ein unbehandeltes '
                'Bänderproblem heilt schlechter und kommt wieder. '
                'Zweitens rechtlich: Nur was dokumentiert ist, gilt '
                'später als Arbeitsunfall. Drittens für alle: Erst '
                'gemeldete Vorfälle zeigen, wo im Betrieb eine Stufe, '
                'ein Griff oder ein Ablauf verbessert werden muss. '
                'Melden ist Stärke, nicht Schwäche.',
          ),
          ChecklistBlock(
            title: 'Das nehme ich aus Modul 7 mit',
            items: [
              'Ich steige rückwärts aus, mit dem Gesicht zum Fahrzeug',
              'Ich halte immer drei Kontaktpunkte (2 Hände + 1 Fuß)',
              'Ich springe nie aus Fahrerhaus oder Laderaum',
              'Ich lege Gegenstände ab, bevor ich aussteige',
              'Ich schaue vor dem Türöffnen über die Schulter',
              'Ich hebe aus den Beinen und drehe mich nicht mit Last',
              'Ich nutze Hilfsmittel statt Heldentaten',
              'Ich melde jede Verletzung, auch die kleine',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M8
  SafetyChapterContent(
    id: 'm8',
    title: 'An der Haustür: Hunde, Menschen & Umgebung',
    summary: 'Am Zustellpunkt sicher agieren — mit Tieren, Menschen und '
        'der Umgebung',
    asset: 'assets/academy/driving/m08_haustuer.svg',
    slides: [
      SafetySlide(
        title: 'Der Zustellpunkt: fremdes Terrain',
        blocks: [
          ParagraphBlock(
            'Sobald du das Fahrzeug verlässt, betrittst du fremdes '
            'Gelände, das du nicht kennst und das niemand für dich '
            'gesichert hat: unbekannte Wege, lose Platten, dunkle '
            'Treppenhäuser, Tiere und Menschen in jeder Stimmung.',
          ),
          FactsBlock([
            FactItem('120+', 'fremde Grundstücke pro Tour'),
            FactItem('30 m', 'Fußweg im Schnitt je Stopp'),
            FactItem('0', 'davon sind für dich vorbereitet'),
          ]),
          ParagraphBlock(
            'Deshalb gilt am Zustellpunkt dieselbe Grundhaltung wie am '
            'Steuer: erst schauen, dann handeln. Und im Zweifel: nicht '
            'zustellen. Eine Sendung, die nicht ankommt, ist ein '
            'Vorgang — eine Verletzung ist ein Ausfall.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Hunde richtig einschätzen',
        asset: 'assets/academy/driving/m08b_hund.svg',
        blocks: [
          ParagraphBlock(
            'Hunde gehören zu den häufigsten Verletzungsursachen bei '
            'Zustellern. Aus Sicht des Hundes bist du ein Eindringling, '
            'der sich schnell bewegt, fremd riecht und ein großes '
            'Objekt trägt — die Reaktion ist Verteidigung, nicht '
            'Bosheit.',
          ),
          BulletsBlock([
            'Nicht direkt in die Augen starren — das ist für den Hund '
                'eine Drohung',
            'Nicht wegrennen und nicht laut werden, sondern ruhig '
                'stehen bleiben',
            'Dem Hund die Seite zuwenden, nicht die Front',
            'Arme ruhig am Körper, keine hektischen Bewegungen',
            'Das Paket kann als Barriere zwischen dich und den Hund',
            'Langsam rückwärts gehen, den Hund dabei im Blick '
                'behalten',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ruhe ist deine beste Ausrüstung',
            text: 'Ein Hund reagiert auf Bewegung und Tonlage, nicht '
                'auf Argumente. Langsam, leise und seitlich — das ist '
                'die ganze Technik.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wenn es ernst wird',
        blocks: [
          RevealBlock(
            prompt: 'Fallbeispiel: Am Gartentor steht ein großer Hund '
                'und bellt. Das Tor ist nur angelehnt, der Kunde hat '
                '„Hund ist lieb" in die Lieferhinweise geschrieben. Was '
                'tust du?',
            answer: 'Du betrittst das Grundstück nicht. Ein '
                'Lieferhinweis ist keine Sicherheitsfreigabe — der '
                'Kunde kennt seinen Hund im Umgang mit der Familie, '
                'nicht im Umgang mit einem fremden Mann mit Paket. '
                'Richtig: vom Tor zurücktreten, versuchen zu '
                'klingeln oder anzurufen, die Sendung dokumentiert '
                'nicht zustellen und den Hinweis im System '
                'hinterlegen, damit der nächste Kollege vorgewarnt '
                'ist. Ein Biss kostet dich Wochen — die Sendung '
                'kostet den Kunden einen Tag.',
          ),
          DoDontBlock(
            doTitle: 'Richtig',
            dos: [
              'Vor dem Öffnen des Tors auf Hundegeräusche und Näpfe '
                  'achten',
              'Bei freilaufendem Hund gar nicht erst eintreten',
              'Hinweise für Kollegen im System hinterlegen',
              'Bei Biss oder Kratzer: sofort melden und ärztlich '
                  'behandeln lassen',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Den Hund streicheln oder füttern',
              'Über das Tier hinweg zur Tür durchgehen',
              'Wegrennen oder mit dem Paket nach dem Hund schlagen',
              'Sich auf „Der tut nichts" verlassen',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Jeder Hundebiss gehört zum Arzt',
            text: 'Auch ein kleiner Biss oder Kratzer kann sich '
                'infizieren. Sofort reinigen, ärztlich behandeln '
                'lassen, ins Verbandbuch eintragen und melden — '
                'unabhängig davon, wie harmlos es aussieht.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sichere Wege am Grundstück',
        asset: 'assets/academy/driving/m08c_stolperfallen.svg',
        blocks: [
          ParagraphBlock(
            'Der Weg zur Haustür ist kein Arbeitsplatz, den jemand für '
            'dich geprüft hat. Nutze die ausgewiesenen Wege und kürze '
            'nicht über nasse Rasenflächen, lose Platten oder steile '
            'Böschungen ab.',
          ),
          BulletsBlock([
            'Gartenschläuche, Kabel und Rankgitter am Boden',
            'Lose oder abgesackte Gehwegplatten',
            'Nasses Laub, Moos und Algen auf schattigen Wegen',
            'Kies und Rollsplitt auf glatten Platten',
            'Unbeleuchtete Treppen ohne Handlauf',
            'Kellerschächte, offene Gullys und Lichtschächte',
            'Spielzeug, Fahrräder und Mülltonnen im Weg',
          ]),
          FactsBlock([
            FactItem('letzte 30 m', 'hier passieren die meisten '
                'Stürze'),
            FactItem('1 Hand', 'sollte für den Handlauf frei bleiben'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Abkürzen kostet mehr, als es spart',
            text: 'Der Weg über den Rasen spart zehn Sekunden. Ein '
                'Sturz darauf kostet im Schnitt 24 Ausfalltage.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Treppen, Keller & Dunkelheit',
        blocks: [
          ParagraphBlock(
            'In Treppenhäusern und Hinterhöfen kommen zwei Dinge '
            'zusammen: schlechtes Licht und unbekannte Stufenhöhen. '
            'Beides zusammen ist die häufigste Sturzsituation abseits '
            'des Fahrzeugs.',
          ),
          BulletsBlock([
            'Immer eine Hand für den Handlauf frei halten',
            'Licht einschalten, statt „es geht auch so"',
            'Taschenlampe oder Handylicht nutzen — aber im Gehen '
                'nicht auf das Display schauen',
            'Bei Treppen den Stapel so niedrig halten, dass du die '
                'Stufen siehst',
            'Auf unterschiedliche Stufenhöhen in Altbauten achten',
          ]),
          RevealBlock(
            prompt: 'Du sollst in einen dunklen Kellergang zustellen. '
                'Der Lichtschalter funktioniert nicht. Was ist die '
                'richtige Entscheidung?',
            answer: 'Nicht hineingehen. Ein unbeleuchteter Gang mit '
                'unbekannten Stufen, Kellerschächten und Abstellgut ist '
                'kein Ort, den du mit einem Paket in der Hand betrittst '
                '— und im Zweifel weiß niemand, dass du dort bist. '
                'Richtig: beim Kunden klingeln, an einem sicheren Ort '
                'übergeben oder die Sendung dokumentiert nicht '
                'zustellen. Ein Handylicht ersetzt keine Beleuchtung, '
                'weil du dafür eine Hand brauchst, die du am Handlauf '
                'benötigst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Menschen: deeskalieren statt gewinnen',
        blocks: [
          ParagraphBlock(
            'Du bist für den Kunden das Gesicht eines ganzen Konzerns — '
            'und bekommst deshalb manchmal Ärger ab, der dir nicht '
            'gilt. Freundlich, ruhig und professionell zu bleiben ist '
            'nicht nur höflich, es ist deine wirksamste '
            'Sicherheitsmaßnahme.',
          ),
          StepsBlock([
            'Ruhige Stimme, langsames Sprechtempo, offene Körper'
                'haltung',
            'Zuhören und das Anliegen benennen, statt sofort zu '
                'widersprechen',
            'Bei dem bleiben, was du tun kannst — keine Versprechen '
                'für andere',
            'Abstand halten: mindestens eine Armlänge, Fluchtweg frei',
            'Wenn es eskaliert: Gespräch beenden und zum Fahrzeug '
                'zurückgehen',
          ]),
          RevealBlock(
            prompt: 'Jemand wird laut, kommt dir sehr nahe und '
                'blockiert den Weg zu deinem Fahrzeug. Was gilt?',
            answer: 'Deine Sicherheit geht vor jeder Zustellung. Nicht '
                'diskutieren, nicht recht behalten wollen, keinen '
                'Körperkontakt provozieren. Zurückweichen, Abstand '
                'herstellen, laut und deutlich Distanz einfordern, im '
                'Notfall in die Öffentlichkeit gehen und die Polizei '
                'rufen. Danach: Vorfall melden, damit der Stopp für '
                'Kollegen markiert wird. Kein Paket rechtfertigt eine '
                'körperliche Auseinandersetzung.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Der Wagen als sicherer Ort',
        blocks: [
          ParagraphBlock(
            'Dein Fahrzeug ist Werkzeug, Lager und Rückzugsort. Wenn du '
            'es verlässt, muss es sicher stehen — und wenn du dich '
            'bedroht fühlst, ist es der Ort, zu dem du zurückgehst.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 14 Abs. 2 StVO',
            text: 'Wer sein Fahrzeug verlässt, muss die nötigen '
                'Maßnahmen treffen, um Unfälle und Verkehrsstörungen zu '
                'vermeiden, und es gegen unbefugte Benutzung sichern.',
          ),
          DoDontBlock(
            doTitle: 'Richtig abgestellt',
            dos: [
              'Motor aus, Schlüssel mitnehmen, abschließen',
              'Am Gefälle Handbremse fest anziehen und Räder '
                  'einschlagen',
              'Warnblinker bei Halt im Verkehrsraum',
              'Laderaumtür schließen, wenn du außer Sichtweite bist',
            ],
            dontTitle: 'Riskant',
            donts: [
              'Motor läuft, Tür offen — „geht ja schneller"',
              'Schlüssel steckt, während du an der Tür bist',
              'Am Hang ohne eingeschlagene Räder abstellen',
              'Laderaum offen stehen lassen in belebten Gegenden',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste am Zustellpunkt',
        blocks: [
          ChecklistBlock(
            title: 'An jedem Stopp',
            items: [
              'Motor aus, Schlüssel mit, Fahrzeug abgeschlossen',
              'Am Gefälle gesichert, Räder eingeschlagen',
              'Vor dem Betreten auf Hunde und Hinweise geachtet',
              'Ausgewiesene Wege genutzt, nicht abgekürzt',
              'Eine Hand für den Handlauf frei',
              'Stapel so niedrig, dass ich die Stufen sehe',
              'Bei Dunkelheit für Licht gesorgt',
              'Bei Aggression: Distanz, Rückzug, Meldung',
              'Bei Biss, Sturz oder Beinahe-Unfall: gemeldet',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M9
  SafetyChapterContent(
    id: 'm9',
    title: 'Notfall & Verhalten nach einem Unfall',
    summary: 'Im Ernstfall ruhig, richtig und rechtssicher handeln',
    asset: 'assets/academy/driving/m09_notfall.svg',
    slides: [
      SafetySlide(
        title: 'Absichern — Melden — Helfen',
        blocks: [
          ParagraphBlock(
            'Nach einem Unfall oder bei einer Panne gilt immer dieselbe '
            'Reihenfolge: erst die Stelle sicher machen, dann den '
            'Notruf, dann Erste Hilfe. Diese Reihenfolge ist kein '
            'Formalismus — sie verhindert den zweiten Unfall, bei dem '
            'die Helfer selbst zu Opfern werden.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die Reihenfolge merken',
            text: 'Absichern → Melden → Helfen. Wer sofort zum '
                'Verletzten läuft, ohne abzusichern, wird auf einer '
                'Landstraße oder Autobahn selbst überfahren.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 34 StVO — nach einem Verkehrsunfall',
            text: 'Du musst unverzüglich anhalten, den Verkehr sichern, '
                'bei geringfügigem Schaden aus dem Gefahrenbereich '
                'fahren, Verletzten helfen und die Feststellung deiner '
                'Person und deines Fahrzeugs ermöglichen.',
          ),
          ParagraphBlock(
            'Und ganz wichtig: Ruhe. Die ersten zehn Sekunden nach '
            'einem Knall entscheiden über die nächsten zehn Minuten. '
            'Einmal durchatmen, dann der Reihe nach.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die ersten fünf Schritte',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: 'assets/academy/driving/acc01_absichern.svg',
              title: '1 · Warnblinker an',
              caption: 'Sofort nach dem Anhalten den Warnblinker '
                  'einschalten — er ist das erste Signal für alle, die '
                  'von hinten kommen. Bei Dunkelheit zusätzlich das '
                  'Standlicht anlassen.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc02_warnweste.svg',
              title: '2 · Warnweste anlegen',
              caption: 'Die Weste ziehst du an, bevor du aussteigst — '
                  'nicht danach. Sie liegt deshalb griffbereit im '
                  'Fahrerhaus und nicht hinten im Laderaum.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc03_dreieck.svg',
              title: '3 · Warndreieck aufstellen',
              caption: 'Geh hinter der Leitplanke oder am Fahrbahnrand '
                  'entgegen der Fahrtrichtung und stelle das Dreieck in '
                  'ausreichendem Abstand auf — innerorts rund 50 m, '
                  'außerorts 100 m, auf der Autobahn 150–200 m.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc04_notruf.svg',
              title: '4 · Notruf 112 absetzen',
              caption: 'Sag, wo du bist, was passiert ist, wie viele '
                  'Verletzte es gibt und welche Verletzungen du siehst '
                  '— und lege erst auf, wenn die Leitstelle keine '
                  'Fragen mehr hat.',
            ),
            IllustratedStep(
              asset: 'assets/academy/driving/acc05_erstehilfe.svg',
              title: '5 · Erste Hilfe leisten',
              caption: 'Ansprechen, Atmung prüfen, Blutungen stillen, '
                  'wärmen und beim Verletzten bleiben. Auch einfache '
                  'Maßnahmen helfen — nichts zu tun ist die einzige '
                  'falsche Entscheidung.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Warnblinker, Weste, Dreieck',
        blocks: [
          TableBlock(
            headers: ['Bereich', 'Abstand Warndreieck'],
            rows: [
              ['Innerorts', 'ca. 50 m'],
              ['Außerorts', 'ca. 100 m'],
              ['Autobahn', 'ca. 150–200 m'],
              ['Vor Kuppe oder Kurve', 'davor, nicht dahinter'],
            ],
          ),
          ParagraphBlock(
            'Entscheidend ist nicht der exakte Meterwert, sondern dass '
            'der nachfolgende Verkehr dich rechtzeitig sieht. Vor einer '
            'Kuppe oder Kurve gehört das Dreieck davor — sonst wird es '
            'erst sichtbar, wenn es zu spät ist.',
          ),
          FactsBlock([
            FactItem('1', 'Warnweste ist Pflicht im Fahrzeug '
                '(§ 53a StVZO)'),
            FactItem('vorher', 'Weste anlegen, bevor du aussteigst'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Hinter der Leitplanke gehen',
            text: 'Auf Autobahn und Landstraße gehst du niemals auf der '
                'Fahrbahn zum Aufstellen des Dreiecks, sondern hinter '
                'der Leitplanke oder auf dem Bankett — entgegen der '
                'Fahrtrichtung, damit du den Verkehr siehst.',
          ),
          DoDontBlock(
            doTitle: 'An der Unfallstelle richtig',
            dos: [
              'Warnblinker sofort, Weste vor dem Aussteigen',
              'Hinter der Leitplanke entgegen der Fahrtrichtung gehen',
              'Dreieck vor Kuppe oder Kurve aufstellen',
              'Nach dem Absichern selbst in Sicherheit gehen',
            ],
            dontTitle: 'Typische Fehler',
            donts: [
              'Ohne Weste aussteigen und „nur kurz" nachschauen',
              'Auf der Fahrbahn zum Dreieck laufen',
              'Zwischen den Fahrzeugen stehen bleiben',
              'Zuerst Fotos machen, statt abzusichern',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Rettungsgasse',
        blocks: [
          ParagraphBlock(
            'Die Rettungsgasse wird gebildet, sobald der Verkehr stockt '
            '— nicht erst, wenn Blaulicht zu sehen ist. Dann ist es '
            'meist zu spät, weil niemand mehr Platz hat.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 11 Abs. 2 StVO',
            text: 'Auf Autobahnen und Außerortsstraßen mit mindestens '
                'zwei Fahrstreifen je Richtung ist die Gasse immer '
                'zwischen dem äußerst linken und dem unmittelbar rechts '
                'daneben liegenden Fahrstreifen zu bilden — unabhängig '
                'davon, wie viele Spuren es gibt.',
          ),
          FactsBlock([
            FactItem('links + 1', 'so wird die Gasse gebildet'),
            FactItem('ab 200 €', 'Bußgeld, wenn keine Gasse gebildet '
                'wird'),
            FactItem('2 Punkte', 'plus in der Regel 1 Monat '
                'Fahrverbot'),
          ]),
          RevealBlock(
            prompt: 'Auf einer dreispurigen Autobahn steht der Verkehr. '
                'Wo genau ist die Rettungsgasse — und darfst du in ihr '
                'fahren, wenn du gerade zur Ausfahrt willst?',
            answer: 'Immer zwischen der linken Spur und der mittleren '
                'Spur — nie zwischen Mitte und rechts und nie auf dem '
                'Standstreifen. Und nein: Die Rettungsgasse ist '
                'ausschließlich für Einsatzfahrzeuge. Wer sie nutzt, '
                'um schneller zur Ausfahrt zu kommen, zahlt ein '
                'ähnlich hohes Bußgeld wie derjenige, der gar keine '
                'bildet, und riskiert das Fahrverbot. Der Standstreifen '
                'ist keine Alternative — dort fahren Rettungskräfte, '
                'wenn die Gasse blockiert ist.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Notruf 112 richtig absetzen',
        blocks: [
          FactsBlock([
            FactItem('112', 'Notruf europaweit, auch ohne Guthaben'),
            FactItem('110', 'Polizei — bei reinem Blechschaden'),
          ]),
          StepsBlock([
            'Wo ist es passiert? — Ort, Straße, Kilometerangabe, '
                'Fahrtrichtung, markante Punkte',
            'Was ist passiert? — Art des Unfalls, beteiligte '
                'Fahrzeuge, Gefahren wie auslaufender Kraftstoff',
            'Wie viele Verletzte?',
            'Welche Verletzungen? — bewusstlos, blutend, '
                'eingeklemmt',
            'Warten auf Rückfragen — die Leitstelle beendet das '
                'Gespräch',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hilfe leisten ist Pflicht',
            text: 'Unterlassene Hilfeleistung ist eine Straftat '
                '(§ 323c StGB). Erwartet wird das, was dir zumutbar ist '
                '— Notruf absetzen, absichern, ansprechen, betreuen. '
                'Niemand verlangt, dass du dich selbst in Gefahr '
                'bringst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Erste Hilfe: die Dinge, die zählen',
        blocks: [
          ParagraphBlock(
            'Du musst kein Sanitäter sein. Die entscheidenden Maßnahmen '
            'kann jeder — und sie sind es, die über Leben und Tod '
            'entscheiden, bevor der Rettungsdienst da ist.',
          ),
          StepsBlock([
            'Ansprechen und vorsichtig an der Schulter rütteln — '
                'reagiert die Person?',
            'Keine Reaktion: Atemwege freimachen, Kopf überstrecken, '
                'Atmung 10 Sekunden prüfen',
            'Atmung normal: stabile Seitenlage, zudecken, dabei '
                'bleiben',
            'Keine normale Atmung: sofort Herzdruckmassage beginnen '
                'und nicht aufhören',
            'Starke Blutung: direkt mit Druck versorgen, Druckverband '
                'anlegen',
          ]),
          FactsBlock([
            FactItem('100–120', 'Druckmassagen pro Minute'),
            FactItem('5–6 cm', 'Drucktiefe beim Erwachsenen'),
            FactItem('10 s', 'reichen für die Atemkontrolle'),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Helm und Eingeklemmte',
            text: 'Einen Motorradhelm nimmst du nur ab, wenn die Person '
                'nicht normal atmet — dann führt kein Weg daran vorbei. '
                'Eingeklemmte Personen bewegst du nicht, außer es droht '
                'unmittelbare Gefahr durch Feuer.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Nach einem Blechschaden',
        blocks: [
          ParagraphBlock(
            'Auch bei kleinen Schäden — Rangierdelle, abgefahrener '
            'Spiegel, Kratzer am geparkten Auto — gilt das volle '
            'Programm. Der Schaden wird immer gemeldet, auch wenn er '
            'klein wirkt und niemand zugesehen hat.',
          ),
          ChecklistBlock(
            title: 'Nach einem Blechschaden',
            items: [
              'Anhalten und Fahrzeug sichern',
              'Warnblinker, bei Bedarf Weste und Dreieck',
              'Daten austauschen bzw. auf den Halter warten',
              'Fotos aus mehreren Winkeln, Ort, Zeit, Kennzeichen',
              'Zeugen und deren Kontaktdaten notieren',
              'Kein Schuldanerkenntnis unterschreiben',
              'Schaden im Betrieb melden — noch am selben Tag',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Nie einfach weiterfahren',
            text: 'Wer sich vom Unfallort entfernt, ohne die '
                'Feststellung seiner Person zu ermöglichen, begeht '
                'unerlaubtes Entfernen vom Unfallort (§ 142 StGB) — '
                'eine Straftat mit Geld- oder Freiheitsstrafe, auch bei '
                'einer kleinen Delle.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Beim Rangieren streifst du den '
                'Außenspiegel eines geparkten Autos. Niemand ist da. '
                'Reicht ein Zettel hinter dem Scheibenwischer?',
            answer: 'Nein. Ein Zettel gilt rechtlich nicht als '
                'ausreichende Feststellung — er kann wegfliegen, nass '
                'werden oder entfernt werden. Richtig ist: eine '
                'angemessene Zeit am Unfallort warten (je nach '
                'Situation werden etwa 30 Minuten als Richtwert '
                'herangezogen), und wenn niemand kommt, die Polizei '
                'informieren und den Schaden dort melden. Ein Zettel '
                'zusätzlich ist gute Praxis, ersetzt aber weder das '
                'Warten noch die Meldung.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ruhe bewahren, melden, lernen',
        blocks: [
          ParagraphBlock(
            'Durchatmen, Situation ordnen, Disponent und Betrieb '
            'informieren. Eine ehrliche, schnelle Meldung ist immer '
            'besser als Vertuschen — sie schützt dich, sie schützt den '
            'Betrieb, und aus jedem Vorfall lernen wir für die nächste '
            'Tour.',
          ),
          ChecklistBlock(
            title: 'Das nehme ich aus Modul 9 mit',
            items: [
              'Ich kenne die Reihenfolge: absichern, melden, helfen',
              'Ich lege die Warnweste an, bevor ich aussteige',
              'Ich stelle das Warndreieck in ausreichendem Abstand auf',
              'Ich bilde die Rettungsgasse zwischen links und der '
                  'Spur daneben, sobald es stockt',
              'Ich kenne die fünf Angaben beim Notruf 112',
              'Ich weiß, dass Nichtstun die einzige falsche '
                  'Entscheidung ist',
              'Ich melde jeden Schaden am selben Tag — auch die kleine '
                  'Delle',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ M10
  SafetyChapterContent(
    id: 'm10',
    title: 'Zusammenfassung & Selbstverpflichtung',
    summary: 'Das Gelernte verankern und in eine persönliche Haltung '
        'überführen',
    asset: 'assets/academy/driving/m10_selbstverpflichtung.svg',
    slides: [
      SafetySlide(
        title: 'Deine 7 Kernregeln',
        blocks: [
          BulletsBlock([
            'Vorausdenken schlägt schnell reagieren',
            'Abstand und angepasstes Tempo geben dir immer eine '
                'Reserve',
            'Beim Rückwärtsfahren: aussteigen, schauen, langsam (GOAL)',
            'Handy und Ablenkung nur im Stand bei ausgeschaltetem '
                'Motor',
            'Müdigkeit und Zeitdruck ernst nehmen — Sicherheit vor '
                'Plan',
            'Richtig aussteigen, heben, gehen — dein Körper ist dein '
                'Werkzeug',
            'Im Notfall: absichern, melden, helfen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Wenn du nur eine Regel mitnimmst',
            text: 'Nimm die Zeit, die du brauchst. Fast jeder Unfall in '
                'der Zustellung entsteht in dem Moment, in dem jemand '
                'zwei Sekunden sparen wollte.',
          ),
          DoDontBlock(
            doTitle: 'So sieht ein sicherer Tag aus',
            dos: [
              'Rundgang, Ladung gesichert, Gurt an',
              'Zwei Sekunden Abstand, Blick weit voraus',
              'Vor jedem Rückwärtsmanöver aussteigen und schauen',
              'Handy in der Halterung, Pause bei Müdigkeit',
              'Rückwärts aussteigen mit drei Kontaktpunkten',
            ],
            dontTitle: 'Die fünf teuersten Abkürzungen',
            donts: [
              'Rundgang „heute mal" ausfallen lassen',
              'Ladung nach dem Nachladen nicht neu sichern',
              'Kurz aufs Display schauen, weil die Straße frei ist',
              'Aus dem Laderaum springen, weil es schneller geht',
              'Einen Rangierschaden nicht melden',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Zahlen, die hängenbleiben sollten',
        blocks: [
          FactsBlock([
            FactItem('2 s', 'Mindestabstand'),
            FactItem('2 + 1', 'Kontaktpunkte beim Aussteigen'),
            FactItem('112', 'Notruf bei Verletzten'),
          ]),
          TableBlock(
            headers: ['Zahl', 'Bedeutung'],
            rows: [
              ['2 Sekunden', 'Mindestabstand, bei Nässe 3+'],
              ['18 / 40 m', 'Anhalteweg bei 30 / 50 km/h'],
              ['28 m', 'Blindfahrt bei 2 s Handyblick und Tempo 50'],
              ['89 m', 'Sekundenschlaf von 4 s bei Tempo 80'],
              ['0,8 g', 'Sicherungskraft nach vorn für die Ladung'],
              ['2 + 1', 'Kontaktpunkte beim Ein- und Aussteigen'],
              ['70 %', 'der Schäden entstehen beim Rangieren'],
              ['112', 'Notruf bei Verletzten'],
            ],
          ),
          ParagraphBlock(
            'Diese acht Zahlen sind der harte Kern des Trainings. Wer '
            'sie im Kopf hat, trifft auch dann die richtige '
            'Entscheidung, wenn keine Zeit zum Nachdenken ist.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dein persönlicher Selbstcheck',
        asset: 'assets/academy/driving/m10b_selbstcheck.svg',
        blocks: [
          ParagraphBlock(
            'Geh diese Liste einmal ehrlich durch — nicht für den '
            'Betrieb, sondern für dich. Jeder nicht gesetzte Haken ist '
            'eine konkrete Sache, die du morgen ändern kannst.',
          ),
          ChecklistBlock(
            title: 'Mein Sicherheits-Selbstcheck',
            items: [
              'Ich mache den Rundgang jeden Morgen, auch wenn es '
                  'eilt',
              'Ich sichere die Ladung neu, wenn der Laderaum leerer '
                  'wird',
              'Ich halte zwei Sekunden Abstand und prüfe das am '
                  'Fixpunkt',
              'Ich steige vor jedem Rückwärtsmanöver aus und schaue '
                  'nach',
              'Ich fasse mein Handy während der Fahrt nicht an',
              'Ich halte an, wenn ich müde werde',
              'Ich steige immer rückwärts mit drei Kontaktpunkten aus',
              'Ich hebe aus den Beinen und nutze Hilfsmittel',
              'Ich melde Schäden, Beinahe-Unfälle und Verletzungen',
              'Ich sage Bescheid, wenn ein Plan nicht sicher machbar '
                  'ist',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Fallbeispiel: der Tag, an dem alles zusammenkommt',
        blocks: [
          RevealBlock(
            prompt: 'Fallbeispiel: Freitag, Regen, 190 Stopps. Du '
                'startest 25 Minuten zu spät, der Laderaum ist von der '
                'Nachtschicht unsortiert, dein Handy klingelt ständig, '
                'und um 16 Uhr merkst du, dass du seit dem Frühstück '
                'nichts gegessen hast. Was ist jetzt die richtige '
                'Reihenfolge?',
            answer: 'Halte an und sortiere zuerst den Laderaum — das '
                'holst du in einer Viertelstunde wieder rein und '
                'sparst dir 190 Suchvorgänge. Dann: Handy stumm, in '
                'die Halterung, Anrufe in der nächsten Pause. Dann '
                'zehn Minuten essen und trinken, denn ab jetzt fällt '
                'deine Aufmerksamkeit sonst stündlich. Und dann eine '
                'ehrliche Meldung an die Disposition, dass der Plan '
                'heute nicht vollständig aufgeht. Was du nicht machst: '
                'die Zeit auf der Straße holen wollen, Pausen '
                'streichen, Rangiermanöver abkürzen. Der Tag ist nicht '
                'mehr zu retten — dein Rücken, dein Führerschein und '
                'dein Fahrzeug schon.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die eigentliche Prüfung',
            text: 'Sicher fahren kann jeder an einem guten Tag. Der '
                'Unterschied zeigt sich an dem Tag, an dem alles '
                'gleichzeitig schiefgeht.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Deine Selbstverpflichtung',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dein Versprechen',
            text: '„Ich fahre so, dass alle sicher nach Hause kommen — '
                'auch ich."',
          ),
          ParagraphBlock(
            'Sicherheit ist kein Regelbuch, sondern deine tägliche '
            'Entscheidung. Niemand steht neben dir, wenn du morgens um '
            'sechs entscheidest, ob du den Rundgang machst, oder wenn '
            'du abends um sieben entscheidest, ob du vor dem '
            'Zurücksetzen noch einmal aussteigst. Genau das macht diese '
            'Entscheidungen so wichtig.',
          ),
          ChecklistBlock(
            title: 'Ich verpflichte mich',
            items: [
              'Ich halte die Regeln auch dann ein, wenn niemand '
                  'zusieht',
              'Ich nehme mir die Sekunden, die Sicherheit kostet',
              'Ich melde ehrlich, statt zu vertuschen',
              'Ich helfe neuen Kollegen, es von Anfang an richtig zu '
                  'machen',
              'Ich komme jeden Abend gesund nach Hause',
            ],
          ),
        ],
      ),
    ],
  ),
];
