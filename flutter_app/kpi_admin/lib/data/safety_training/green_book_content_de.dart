// lib/data/safety_training/green_book_content_de.dart
//
// Inhalte der Green-Book-Schulung — deutsche Fassung.
//
// Das „Green Book" ist das Fahrtenkontrollbuch: die Sammlung der
// Tageskontrollblätter nach § 1 Abs. 6 Fahrpersonalverordnung (FPersV).
// Damit werden Lenkzeiten, Fahrtunterbrechungen, Arbeits- und Ruhezeiten
// nachgewiesen — es ist KEINE Fahrzeug-Sichtprüfung.
//
// Aufbau wie beim Fahrsicherheitstraining: je Kapitel mehrere Folien aus
// typisierten Bausteinen — Zahlen-Kacheln, Fallbeispiele zum Nachdenken
// (Reveal), Do/Don't, Rechtshinweise und eine Checkliste am Kapitelende.
// Für dieses Thema gibt es keine Illustrationen, deshalb `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> greenBookContentDe = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'gb1',
    title: 'Was das Green Book ist',
    summary: 'Fahrtenkontrollbuch nach § 1 Abs. 6 FPersV — und warum es '
        'für dich Pflicht ist',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Fahrtenkontrollbuch, nicht Fahrzeugcheck',
        blocks: [
          ParagraphBlock(
            'Das „Green Book" ist dein Fahrtenkontrollbuch. Darin sammelst '
            'du die Tageskontrollblätter: für jeden Arbeitstag ein Blatt, '
            'auf dem steht, wann du gefahren bist, wann du Pause gemacht '
            'hast und wann deine Ruhezeit begonnen hat.',
          ),
          ParagraphBlock(
            'Es ist ausdrücklich kein Fahrzeug-Check. Reifen, Licht und '
            'Karosserie werden woanders dokumentiert. Im Green Book geht es '
            'ausschließlich um Zeiten — deine Zeiten.',
          ),
          BulletsBlock([
            'Ein Blatt pro Tag, an dem du ein aufzeichnungspflichtiges '
                'Fahrzeug bewegst',
            'Handschriftlich geführt, dokumentenecht und unterschrieben',
            'Es weist nach, dass du Lenkzeiten, Pausen und Ruhezeiten '
                'eingehalten hast',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kurz gesagt',
            text: 'Das Green Book beantwortet eine einzige Frage: Wann warst '
                'du am Steuer, und wann nicht? Alles andere gehört nicht '
                'hinein.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wer aufzeichnen muss',
        blocks: [
          ParagraphBlock(
            'Die Pflicht kommt aus § 1 Abs. 6 der Fahrpersonalverordnung '
            '(FPersV). Sie hängt nicht an dir persönlich, sondern am '
            'Fahrzeug und am Zweck der Fahrt: gewerblicher Güterverkehr mit '
            'einem Fahrzeug über 2,8 t bis 3,5 t zulässiger Gesamtmasse. Das '
            'ist genau der typische Zustell-Transporter.',
          ),
          FactsBlock([
            FactItem('unter 2,8 t', 'keine Aufzeichnungspflicht nach § 1 '
                'Abs. 6 FPersV'),
            FactItem('2,8–3,5 t', 'Tageskontrollblatt — dein Green Book'),
            FactItem('ab 3,5 t', 'digitaler Tachograf statt Papierblatt'),
          ]),
          ParagraphBlock(
            'Maßgeblich ist die zulässige Gesamtmasse, die im '
            'Fahrzeugschein steht — nicht, wie schwer der Transporter heute '
            'tatsächlich beladen ist. Ein halb leerer 3,5-Tonner bleibt '
            'aufzeichnungspflichtig.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: '§ 1 Abs. 6 FPersV verpflichtet dich, Lenkzeiten, '
                'Fahrtunterbrechungen sowie Arbeits- und Ruhezeiten '
                'aufzuzeichnen. Fährst du ohne dieses Blatt, verstößt du '
                'gegen die Verordnung — unabhängig davon, ob du dich an die '
                'Zeiten gehalten hast.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wozu die Aufzeichnung gut ist',
        blocks: [
          ParagraphBlock(
            'Die Vorschrift ist kein Selbstzweck. Sie existiert, weil '
            'übermüdete Fahrer im Straßenverkehr gefährlich sind — für sich '
            'und für alle anderen. Das Blatt macht sichtbar, ob deine '
            'Arbeitstage überhaupt einhaltbar geplant sind.',
          ),
          BulletsBlock([
            'Schutz vor Übermüdung: Wer die Pause dokumentieren muss, macht '
                'sie eher auch wirklich',
            'Nachweis für dich: Das Blatt belegt, dass du korrekt gefahren '
                'bist — auch Monate später',
            'Nachweis gegen Behauptungen: Ohne Aufzeichnung steht deine '
                'Erinnerung gegen die Annahme der Kontrolle',
            'Grundlage für die Tourenplanung: Wiederkehrend zu enge Touren '
                'fallen im Blatt auf',
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Du bist heute an die Zeiten gehalten — '
                'Pause pünktlich, Feierabend rechtzeitig. Nur das Blatt hast '
                'du nicht ausgefüllt, weil ohnehin alles in Ordnung war. '
                'Kontrolle am Nachmittag. Ist das ein Problem?',
            answer: 'Ja. Aufzeichnungspflicht heißt: Der Nachweis selbst ist '
                'die Pflicht. Ob du dich tatsächlich an die Zeiten gehalten '
                'hast, kann bei einer Straßenkontrolle niemand feststellen — '
                'es gibt ja nichts vorzulegen. Aus Sicht der Kontrolle ist '
                'ein fehlendes Blatt genau so zu behandeln wie ein '
                'überschrittener Zeitrahmen: Es liegt ein Verstoß vor, und er '
                'wird geahndet. Deine Einhaltung nützt dir nur, wenn du sie '
                'belegen kannst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: das Grundverständnis',
        blocks: [
          ChecklistBlock(
            title: 'Das nehme ich aus Kapitel 1 mit',
            items: [
              'Ich weiß, dass das Green Book Zeiten dokumentiert und nicht '
                  'den Fahrzeugzustand',
              'Ich kenne die Rechtsgrundlage: § 1 Abs. 6 FPersV',
              'Ich weiß, dass Fahrzeuge über 2,8 t bis 3,5 t betroffen sind',
              'Ich weiß, dass die zulässige Gesamtmasse zählt, nicht das '
                  'aktuelle Ladegewicht',
              'Ich weiß, dass ab 3,5 t der digitale Tachograf greift',
              'Mir ist klar, dass ein fehlendes Blatt schon für sich ein '
                  'Verstoß ist',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ein Satz für die Tour',
            text: '„Was ich nicht aufgeschrieben habe, kann ich nicht '
                'beweisen."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'gb2',
    title: 'Was genau eingetragen wird',
    summary: 'Alle Pflichtfelder — und wie du sie sauber ausfüllst',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Die Pflichtangaben auf dem Blatt',
        blocks: [
          ParagraphBlock(
            'Ein Tageskontrollblatt ist nur dann ein Nachweis, wenn alle '
            'vorgeschriebenen Angaben darauf stehen. Fehlt eine davon, gilt '
            'das Blatt als unvollständig — mit denselben Folgen wie ein '
            'fehlendes Blatt.',
          ),
          BulletsBlock([
            'Name, Vorname und Anschrift des Fahrers',
            'Amtliches Kennzeichen des Fahrzeugs',
            'Datum des Tages',
            'Kilometerstand bei Beginn und bei Ende der Fahrt',
            'Ort des Fahrtbeginns und Ort des Fahrtendes',
            'Lenkzeiten und Ruhezeiten mit Stundenangabe',
            'Fahrtunterbrechungen (die Pausen)',
            'Deine Unterschrift',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Vollständig heißt vollständig',
            text: '§ 1 Abs. 6 FPersV zählt die Angaben abschließend auf. Ein '
                'Blatt ohne Kennzeichen, ohne Anschrift oder ohne '
                'Unterschrift erfüllt die Aufzeichnungspflicht nicht — auch '
                'wenn die Zeiten korrekt eingetragen sind.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Schritt für Schritt ausfüllen',
        blocks: [
          ParagraphBlock(
            'Die Reihenfolge unten ist bewusst so gewählt, dass du nichts '
            'vergisst: erst die festen Angaben, dann die Zeiten im '
            'Tagesverlauf, zum Schluss der Abschluss.',
          ),
          StepsBlock([
            'Vor dem Losfahren: Datum, Name, Vorname, Anschrift und '
                'Kennzeichen eintragen',
            'Kilometerstand vom Tacho ablesen und als Anfangsstand '
                'eintragen — nicht schätzen',
            'Ort des Fahrtbeginns eintragen (Depot, Standort, Ortsname)',
            'Beginn der Lenkzeit mit Uhrzeit eintragen, sobald du losfährst',
            'Jede Fahrtunterbrechung sofort mit Beginn und Ende eintragen — '
                'nicht erst am Abend',
            'Am Tourende: Ort des Fahrtendes und den End-Kilometerstand '
                'eintragen',
            'Ende der Lenkzeit und Beginn der Ruhezeit eintragen',
            'Blatt durchlesen, auf Lücken prüfen und unterschreiben',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Dokumentenecht schreiben',
            text: 'Kugelschreiber, nicht Bleistift. Ein Eintrag, den man '
                'wegradieren kann, ist kein Nachweis. Ein Schreibfehler wird '
                'einmal durchgestrichen, daneben neu geschrieben — nicht '
                'übermalt und nicht überklebt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Zeiten sauber eintragen',
        blocks: [
          ParagraphBlock(
            'Am meisten schiefgeht bei den Zeiten. Jeder Zeitblock des Tages '
            'gehört in eine eigene Zeile, mit Uhrzeit von–bis. So sieht ein '
            'normaler Zustelltag aus:',
          ),
          TableBlock(
            headers: ['Von–bis', 'Art', 'Hinweis'],
            rows: [
              ['06:30–07:00', 'Arbeitszeit', 'Laden im Depot, noch keine '
                  'Lenkzeit'],
              ['07:00–11:30', 'Lenkzeit', '4,5 Stunden — jetzt ist die Pause '
                  'fällig'],
              ['11:30–12:15', 'Fahrtunterbrechung', '45 Minuten am Stück'],
              ['12:15–16:45', 'Lenkzeit', 'zweiter Block, zusammen 9 Stunden'],
              ['16:45–17:15', 'Arbeitszeit', 'Rückgabe, Retouren, Abschluss'],
              ['ab 17:15', 'Ruhezeit', 'mindestens 11 Stunden bis zum '
                  'nächsten Start'],
            ],
          ),
          BulletsBlock([
            'Lenkzeit ist nur die Zeit am Steuer bei laufender Fahrt',
            'Be- und Entladen, Scannen, Warten am Stopp ist Arbeitszeit, '
                'aber keine Lenkzeit',
            'Eine Fahrtunterbrechung ist nur dann eine Pause, wenn du in '
                'dieser Zeit wirklich nicht arbeitest',
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Du stehst 40 Minuten an der Rampe und '
                'wartest, dass abgeladen wird. Du sitzt im Fahrerhaus und '
                'machst nichts. Darfst du das als Fahrtunterbrechung '
                'eintragen?',
            answer: 'Nur wenn du in dieser Zeit tatsächlich frei über sie '
                'verfügen kannst und keine Arbeitsleistung erbringst — und '
                'wenn du das vorher weißt. Musst du jederzeit bereitstehen, '
                'weil es gleich weitergehen kann, ist das Wartezeit und keine '
                'Pause. Der naheliegende Irrtum: „Ich habe nichts getan, also '
                'war es Pause." Entscheidend ist nicht, ob du dich bewegt '
                'hast, sondern ob du über die Zeit verfügen konntest. Im '
                'Zweifel trägst du es als Arbeitszeit ein — das ist immer die '
                'sichere Seite.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: Blatt vollständig?',
        blocks: [
          ChecklistBlock(
            title: 'Bevor ich unterschreibe',
            items: [
              'Name, Vorname und Anschrift stehen drauf',
              'Kennzeichen des Fahrzeugs stimmt mit dem gefahrenen Fahrzeug '
                  'überein',
              'Datum ist eingetragen',
              'Anfangs- und End-Kilometerstand sind vom Tacho abgelesen',
              'Ort des Fahrtbeginns und des Fahrtendes stehen drauf',
              'Alle Lenkzeiten sind mit Uhrzeit von–bis eingetragen',
              'Alle Fahrtunterbrechungen sind eingetragen',
              'Beginn der Ruhezeit ist eingetragen',
              'Alles mit Kugelschreiber, keine Radierung, keine Lücke',
              'Unterschrift gesetzt',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'gb3',
    title: 'Lenkzeiten, Pausen, Ruhezeiten',
    summary: 'Die Zahlen, die dein Arbeitstag einhalten muss',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Die Zahlen, die zählen',
        blocks: [
          ParagraphBlock(
            'Das Green Book dokumentiert Zeiten — aber nur, damit man '
            'nachvollziehen kann, ob du Grenzen eingehalten hast. Diese '
            'Grenzen musst du im Kopf haben, nicht nur auf dem Papier.',
          ),
          FactsBlock([
            FactItem('9 h', 'Lenkzeit pro Tag im Regelfall'),
            FactItem('10 h', 'zweimal pro Woche als Ausnahme erlaubt'),
            FactItem('4,5 h', 'Lenkzeit am Stück, dann ist Pause fällig'),
          ]),
          FactsBlock([
            FactItem('45 min', 'Fahrtunterbrechung nach 4,5 Stunden'),
            FactItem('15 + 30', 'zulässige Teilung — in dieser Reihenfolge'),
            FactItem('11 h', 'tägliche Ruhezeit, mindestens'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Was die Vorschrift verlangt',
            text: 'Die Lenkzeit beträgt höchstens 9 Stunden täglich, '
                'zweimal in der Woche darf sie auf 10 Stunden verlängert '
                'werden. Nach spätestens 4,5 Stunden Lenkzeit ist eine '
                'Fahrtunterbrechung von mindestens 45 Minuten einzulegen. Die '
                'tägliche Ruhezeit beträgt mindestens 11 Stunden.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Pause richtig legen',
        blocks: [
          ParagraphBlock(
            'Die 45 Minuten sind der Normalfall. Du darfst sie aufteilen — '
            'aber nur in genau zwei Abschnitte und nur in einer bestimmten '
            'Reihenfolge: erst mindestens 15 Minuten, danach mindestens 30 '
            'Minuten. Umgekehrt zählt es nicht.',
          ),
          DoDontBlock(
            doTitle: 'So ist die Pause gültig',
            dos: [
              '45 Minuten am Stück nach spätestens 4,5 Stunden Lenkzeit',
              'Oder 15 Minuten zuerst, danach 30 Minuten',
              'Beide Teile innerhalb desselben 4,5-Stunden-Blocks',
              'Beide Teile mit Uhrzeit von–bis ins Blatt eintragen',
            ],
            dontTitle: 'So zählt sie nicht',
            donts: [
              '30 Minuten zuerst und 15 Minuten danach — falsche Reihenfolge',
              'Drei kurze Pausen von je 15 Minuten',
              'Zwei mal 20 Minuten — der zweite Teil ist zu kurz',
              'Pause erst nach 5 Stunden Lenkzeit, weil der Stopp besser '
                  'gepasst hat',
            ],
          ),
          BulletsBlock([
            'Die 4,5 Stunden sind reine Lenkzeit — Stopps mit Ausliefern '
                'zählen nicht mit',
            'Die Pause muss vor dem Überschreiten liegen, nicht danach',
            'Nach der vollständigen Unterbrechung beginnt ein neuer '
                '4,5-Stunden-Block',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der häufigste Denkfehler',
            text: 'Die Pause ist nicht dann fällig, wenn du 4,5 Stunden im '
                'Dienst bist, sondern wenn du 4,5 Stunden gelenkt hast. Wer '
                'nach Dienstzeit rechnet, macht die Pause meistens zu früh '
                '— und dann noch einmal zu spät.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Rechnen im Zustellalltag',
        blocks: [
          ParagraphBlock(
            'Im Alltag rechnest du nicht mit einem Block, sondern mit vielen '
            'kurzen Fahrten zwischen den Stopps. Addiere sie zusammen — sie '
            'ergeben deine Lenkzeit.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du startest um 07:00 Uhr. Bis 09:30 Uhr '
                'sitzt du 2 Stunden am Steuer, den Rest an den Stopps. Bis '
                '12:00 Uhr kommen weitere 2 Stunden Lenkzeit dazu, bis 13:00 '
                'Uhr noch einmal 30 Minuten. Wann ist deine Pause spätestens '
                'fällig?',
            answer: 'Um 13:00 Uhr. Zu diesem Zeitpunkt hast du 2 + 2 + 0,5 = '
                '4,5 Stunden reine Lenkzeit erreicht — jetzt darfst du keinen '
                'Meter mehr fahren, bevor die Fahrtunterbrechung erledigt '
                'ist. Der naheliegende Irrtum wäre, ab 07:00 Uhr sechs '
                'Stunden Dienstzeit zu rechnen und die Pause auf 11:30 Uhr zu '
                'legen. Die Uhr, die zählt, läuft nur, wenn das Fahrzeug '
                'fährt.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du hast diese Woche schon zweimal 10 '
                'Stunden gelenkt. Heute ist Freitag, du bist bei 8,5 Stunden '
                'Lenkzeit und hast noch zwei Stopps, zusammen etwa 40 '
                'Minuten Fahrt. Geht das noch?',
            answer: 'Nein. Die Verlängerung auf 10 Stunden darfst du nur '
                'zweimal pro Woche nutzen, und die sind aufgebraucht. Heute '
                'gilt wieder die Regelgrenze von 9 Stunden — dir bleiben also '
                '30 Minuten Lenkzeit, nicht 40. Du fährst den erreichbaren '
                'Stopp, meldest den Rest dem Disponenten und beendest die '
                'Lenkzeit. Der naheliegende Irrtum: „Die 10 Stunden stehen '
                'mir jeden Tag zu." Sie sind eine Ausnahme mit '
                'Wochenkontingent.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: Zeiten im Griff',
        blocks: [
          ChecklistBlock(
            title: 'Das nehme ich aus Kapitel 3 mit',
            items: [
              'Ich weiß, dass 9 Stunden Lenkzeit die Regel sind',
              'Ich weiß, dass 10 Stunden nur zweimal pro Woche erlaubt sind',
              'Ich zähle die 4,5 Stunden als reine Lenkzeit, nicht als '
                  'Dienstzeit',
              'Ich mache mindestens 45 Minuten Fahrtunterbrechung',
              'Ich teile die Pause höchstens in 15 + 30 Minuten, in dieser '
                  'Reihenfolge',
              'Ich halte mindestens 11 Stunden tägliche Ruhezeit ein',
              'Ich trage jede Pause sofort ein, nicht am Abend',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Merksatz',
            text: '4,5 – 45 – 9 – 11. Vier Zahlen, die deinen Tag '
                'strukturieren. Wer sie kennt, muss nicht rechnen, sondern '
                'nur mitschreiben.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'gb4',
    title: 'Typische Fehler beim Ausfüllen',
    summary: 'Die sechs Fehler, die bei jeder Kontrolle auffallen',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Die sechs häufigsten Fehler',
        blocks: [
          ParagraphBlock(
            'Fast alle beanstandeten Blätter scheitern nicht an den Zeiten, '
            'sondern an der Art, wie sie geführt wurden. Diese sechs Fehler '
            'machen ein sonst korrektes Blatt wertlos.',
          ),
          DoDontBlock(
            doTitle: 'So führst du das Blatt richtig',
            dos: [
              'Jeden Eintrag sofort machen, wenn der Zeitblock endet',
              'Kugelschreiber benutzen, dokumentenecht',
              'Pausen mit der tatsächlichen Uhrzeit von–bis eintragen',
              'Kilometerstand vom Tacho ablesen',
              'Am Tagesende unterschreiben',
              'Das Blatt bleibt im Fahrzeug, bei dir',
            ],
            dontTitle: 'So wird das Blatt beanstandet',
            donts: [
              'Die ganze Woche am Freitagabend nachtragen',
              'Mit Bleistift schreiben, um „später korrigieren" zu können',
              'Pausen schätzen („so ungefähr eine Dreiviertelstunde")',
              'Den Kilometerstand aus dem Kopf hinschreiben',
              'Die Unterschrift vergessen',
              'Die Blätter zu Hause oder im Depot liegen lassen',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der teuerste Fehler ist der bequemste',
            text: 'Nachträglich ausfüllen fühlt sich harmlos an — es ist der '
                'Fehler, der am schnellsten auffliegt und am schwersten wiegt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Warum Nachträge auffallen',
        blocks: [
          ParagraphBlock(
            'Ein am Stück nachgeschriebenes Blatt sieht anders aus als eines, '
            'das über den Tag verteilt entstanden ist. Kontrolleure sehen '
            'täglich beides und erkennen den Unterschied sofort.',
          ),
          BulletsBlock([
            'Gleiches Schriftbild, gleicher Stift, gleicher Druck über alle '
                'Zeilen',
            'Auffällig runde Zeiten: alles endet auf halbe und volle Stunden',
            'Kilometerstände, die nicht zur eingetragenen Strecke passen',
            'Angaben, die den Lieferscheinen, Scans oder Tankbelegen '
                'widersprechen',
            'Pausen, die immer exakt 45 Minuten dauern — auch an Tagen, an '
                'denen das nicht möglich war',
          ]),
          ParagraphBlock(
            'Dazu kommt: Bei einer Kontrolle im Betrieb liegen die Blätter '
            'neben den übrigen Unterlagen. Widersprüche fallen nicht dir auf, '
            'sondern der Behörde.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Falsch ist schlimmer als leer',
            text: 'Ein unvollständiges Blatt ist ein Verstoß gegen die '
                'Aufzeichnungspflicht. Ein bewusst falsch ausgefülltes Blatt '
                'ist mehr als das — dort geht es nicht mehr nur um eine '
                'Ordnungswidrigkeit, sondern um die Frage der Täuschung. Trag '
                'lieber ein, dass du zu lange gefahren bist, als eine Zeit zu '
                'erfinden.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du merkst am Donnerstag, dass am Dienstag '
                'die Mittagspause nicht eingetragen ist. Du erinnerst dich '
                'genau: 12:10 bis 12:55 Uhr. Was tust du?',
            answer: 'Du trägst sie nach — aber sichtbar als Nachtrag, mit dem '
                'Datum der Ergänzung und einer kurzen Bemerkung, und du '
                'informierst deinen Disponenten. Eine ehrliche, erkennbare '
                'Korrektur ist zulässig und deutlich besser als eine Lücke. '
                'Der naheliegende Irrtum wäre, den Eintrag so einzufügen, als '
                'wäre er am Dienstag entstanden — genau das ist der Schritt '
                'von der Nachlässigkeit zur Fälschung.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: sauber geführt',
        blocks: [
          ChecklistBlock(
            title: 'Mein Blatt hält einer Kontrolle stand',
            items: [
              'Ich trage jeden Zeitblock sofort ein, nicht am Abend',
              'Ich schreibe mit Kugelschreiber',
              'Ich lese Uhrzeiten und Kilometerstände ab, statt sie zu '
                  'schätzen',
              'Ich unterschreibe jedes Blatt',
              'Meine Blätter sind immer bei mir im Fahrzeug',
              'Korrekturen mache ich sichtbar und datiert, nie unsichtbar',
              'Ich trage lieber einen Verstoß ein, als eine Zeit zu erfinden',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'gb5',
    title: 'Mitführen, abgeben, aufbewahren',
    summary: '28 Tage beim Fahrer, ein Jahr im Betrieb',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Die beiden Fristen',
        blocks: [
          ParagraphBlock(
            'Das ausgefüllte Blatt ist erst dann etwas wert, wenn es im '
            'richtigen Moment am richtigen Ort ist. Dafür gibt es zwei '
            'Fristen, die du auseinanderhalten musst.',
          ),
          FactsBlock([
            FactItem('28 Tage', 'Aufzeichnungen führt der Fahrer mit sich'),
            FactItem('1 Jahr', 'bewahrt der Unternehmer sie im Betrieb auf'),
          ]),
          BulletsBlock([
            'Die 28 Tage betreffen dich: Du musst die Aufzeichnungen des '
                'laufenden Tages und der vorausgegangenen 28 Tage dabeihaben',
            'Die Jahresfrist betrifft den Betrieb: Er muss die Blätter ein '
                'Jahr lang aufbewahren und auf Verlangen vorlegen',
            'Beides gilt gleichzeitig — die Blätter wandern erst nach Ablauf '
                'der Mitführpflicht ins Archiv',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Mitführpflicht',
            text: 'Die Aufzeichnungen der letzten 28 Tage gehören ins '
                'Fahrzeug — nicht in den Spind, nicht nach Hause und nicht '
                'ins Büro. Fehlen sie bei einer Kontrolle, hilft es nicht, '
                'dass sie ordentlich geführt wurden.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Straßenkontrolle',
        blocks: [
          ParagraphBlock(
            'Kontrolliert wird durch das BAG — das Bundesamt für Logistik und '
            'Mobilität — und durch die Polizei. Beide dürfen am Straßenrand '
            'kontrollieren, das BAG zusätzlich im Betrieb.',
          ),
          StepsBlock([
            'Anhalten, Motor aus, Fenster runter, Hände sichtbar lassen',
            'Ruhig bleiben — eine Kontrolle ist Routine, kein Verdacht',
            'Führerschein, Fahrzeugpapiere und die Aufzeichnungen der '
                'letzten 28 Tage vorlegen',
            'Fragen sachlich beantworten, nichts erfinden und nichts '
                'ausschmücken',
            'Bei einer Beanstandung: Vorgang aufnehmen lassen, nicht '
                'diskutieren',
            'Danach den Disponenten informieren und den Vorgang im Betrieb '
                'dokumentieren',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Vorbereitung schlägt Erklärung',
            text: 'Eine Kontrolle dauert wenige Minuten, wenn die Blätter '
                'vollständig im Fahrzeug liegen. Alles andere kostet dich und '
                'den Betrieb den ganzen Nachmittag.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Am Straßenrand fragt der Kontrolleur nach '
                'den letzten 28 Tagen. Du hast nur die aktuelle Woche dabei — '
                'die älteren Blätter hast du korrekt im Depot abgegeben. '
                'Reicht das?',
            answer: 'Nein. Die Mitführpflicht umfasst den laufenden Tag und '
                'die vorausgegangenen 28 Tage. Dass die älteren Blätter '
                'ordentlich im Betrieb liegen, erfüllt die Aufbewahrungs-, '
                'aber nicht die Mitführpflicht — es sind zwei getrennte '
                'Pflichten. Richtig ist: Kopien oder Originale der letzten 28 '
                'Tage bleiben bei dir, erst danach gehen sie ins Archiv. '
                'Kläre mit deinem Disponenten, wie ihr das im Betrieb '
                'organisiert.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Abgeben im Betrieb',
        blocks: [
          ParagraphBlock(
            'Der Unternehmer kann seine Aufbewahrungspflicht nur erfüllen, '
            'wenn er die Blätter auch bekommt. Deshalb ist die Abgabe kein '
            'Verwaltungskram, sondern Teil deiner Aufzeichnungspflicht.',
          ),
          BulletsBlock([
            'Blätter nach Ablauf der Mitführfrist vollständig abgeben, nicht '
                'stapelweise am Monatsende',
            'Nichts wegwerfen, auch keine Blätter mit Fehlern oder '
                'Korrekturen',
            'Fehlt dir ein Blatt, sag es sofort — eine gemeldete Lücke ist '
                'besser als eine entdeckte',
            'Urlaubs-, Krank- und Bürotage nicht einfach auslassen, sondern '
                'nach betrieblicher Vorgabe kennzeichnen',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Lücken bleiben Lücken',
            text: 'Ein Tag ohne Blatt lässt sich später nicht rekonstruieren. '
                'Wer die Abgabe schleifen lässt, produziert genau die Lücken, '
                'die bei einer Betriebskontrolle auffallen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: Unterlagen im Griff',
        blocks: [
          ChecklistBlock(
            title: 'Vor jeder Schicht und nach jeder Woche',
            items: [
              'Die Aufzeichnungen der letzten 28 Tage sind im Fahrzeug',
              'Das heutige Blatt ist begonnen und liegt griffbereit',
              'Führerschein und Fahrzeugpapiere sind dabei',
              'Abgelaufene Blätter habe ich im Betrieb abgegeben',
              'Ich habe kein Blatt weggeworfen, auch keines mit Korrekturen',
              'Ich weiß, wen ich bei einer Kontrolle informieren muss',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'gb6',
    title: 'Konsequenzen bei Verstößen',
    summary: 'Bußgeld, Verantwortung des Betriebs, interne Eskalation',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Was rechtlich droht',
        blocks: [
          ParagraphBlock(
            'Ein fehlendes oder unvollständiges Tageskontrollblatt ist eine '
            'Ordnungswidrigkeit. Wie hoch das Bußgeld ausfällt, hängt davon '
            'ab, wie schwer und wie oft verstoßen wurde.',
          ),
          FactsBlock([
            FactItem('ab 100 €', 'Bußgeld bei fehlenden oder '
                'unvollständigen Blättern'),
            FactItem('je nach Schwere', 'höhere Beträge bei mehreren oder '
                'wiederholten Verstößen'),
          ]),
          BulletsBlock([
            'Betroffen ist nicht nur der Fahrer — auch das Unternehmen trägt '
                'Verantwortung für die Aufzeichnungen',
            'Bei schweren oder wiederholten Verstößen droht ein Verfahren zur '
                'Zuverlässigkeit des Unternehmens',
            'Kontrolliert wird durch BAG und Polizei, am Straßenrand und im '
                'Betrieb',
            'Beanstandungen aus einer Betriebskontrolle betreffen alle '
                'Fahrer, nicht nur den kontrollierten',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Zwei Adressaten, eine Pflicht',
            text: 'Die FPersV nimmt Fahrer und Unternehmer gemeinsam in die '
                'Pflicht: Du musst aufzeichnen und mitführen, der Betrieb '
                'muss aufbewahren und überwachen. Fällt eines von beidem aus, '
                'haftet die jeweils verantwortliche Seite.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Eskalation im Betrieb',
        blocks: [
          ParagraphBlock(
            'Unabhängig davon, ob eine Behörde etwas feststellt, gilt im '
            'Betrieb eine feste Abfolge. Sie ist für alle gleich und wird '
            'dokumentiert.',
          ),
          StepsBlock([
            'Erste Stufe: mündliche Ermahnung durch den Disponenten',
            'Zweite Stufe: schriftliche Abmahnung in der Personalakte',
            'Dritte Stufe: arbeitsrechtliche Konsequenzen bis zur Kündigung',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der Verstoß ist das fehlende Blatt',
            text: 'Die Stufen laufen unabhängig davon, ob etwas passiert ist '
                'oder ob eine Kontrolle stattgefunden hat. Schon das nicht '
                'geführte Blatt ist der Verstoß.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Der Disponent drängt: „Fahr die zwei '
                'Stopps noch, schreib die Pause einfach ein, wir sind sonst '
                'nicht durch." Was gilt?',
            answer: 'Die Anweisung ändert nichts an deiner Pflicht. Du bist '
                'derjenige, der aufzeichnet und unterschreibt — mit deiner '
                'Unterschrift bestätigst du den Inhalt. Eine mündliche '
                'Anweisung schützt dich weder bei der Kontrolle noch später '
                'im Betrieb. Richtig ist: Pause machen, korrekt eintragen, '
                'die verbleibenden Stopps melden und die Anweisung '
                'dokumentieren. Der Betrieb ist verpflichtet, die Einhaltung '
                'zu ermöglichen — nicht, sie zu umgehen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: Abschluss',
        blocks: [
          ChecklistBlock(
            title: 'Das nehme ich aus der Schulung mit',
            items: [
              'Das Green Book ist das Fahrtenkontrollbuch nach § 1 Abs. 6 '
                  'FPersV',
              'Ich kenne alle Pflichtangaben und fülle sie vollständig aus',
              'Ich halte 9 h Lenkzeit, 4,5 h bis zur Pause, 45 min '
                  'Unterbrechung und 11 h Ruhezeit ein',
              'Ich trage sofort ein, mit Kugelschreiber, und unterschreibe',
              'Ich führe die Aufzeichnungen der letzten 28 Tage mit',
              'Ich gebe abgelaufene Blätter im Betrieb ab',
              'Ich weiß, dass ein fehlendes Blatt ein Bußgeld ab 100 Euro '
                  'auslösen kann',
              'Ich weiß, dass eine Anweisung meine Aufzeichnungspflicht '
                  'nicht aufhebt',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ein Satz für die Tour',
            text: '„Das Blatt schreibt mit, während ich fahre — nicht, wenn '
                'ich fertig bin."',
          ),
        ],
      ),
    ],
  ),
];
