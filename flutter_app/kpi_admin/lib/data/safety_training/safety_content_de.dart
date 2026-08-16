// lib/data/safety_training/safety_content_de.dart
//
// Inhalte der Sicherheitsunterweisung — deutsche Fassung (Master).
// Aufbau folgt der SVG-Vorlage: je Thema mehrere Seiten statt einer
// Textwand. Generisch formuliert, ohne Firmen-/Ortsbezug.

import 'safety_blocks.dart';

const String _a = 'assets/academy/safety/';

const List<SafetyChapterContent> safetyContentDe = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ch01',
    title: 'Rechtsgrundlagen & deine Pflichten',
    summary: 'Warum es Arbeitsschutz gibt — und was du beitragen musst',
    asset: '${_a}ch01_grundlagen.svg',
    slides: [
      SafetySlide(
        title: 'Worauf der Arbeitsschutz aufbaut',
        asset: '${_a}ch01_grundlagen.svg',
        blocks: [
          ParagraphBlock(
            'Arbeitsschutz ist kein freiwilliges Angebot deines '
            'Arbeitgebers, sondern gesetzlich vorgeschrieben. Er stützt '
            'sich auf zwei Säulen: das staatliche Recht und das Recht der '
            'Unfallversicherungsträger.',
          ),
          BulletsBlock([
            'Arbeitsschutzgesetz (ArbSchG) — regelt die Pflichten des '
                'Arbeitgebers und die Rechte und Pflichten der '
                'Beschäftigten',
            'Verordnungen — konkretisieren das Gesetz, z. B. '
                'Arbeitsstätten-, Betriebssicherheits- und '
                'Gefahrstoffverordnung',
            'DGUV Vorschriften — verbindliche Regeln der Berufsgenossen'
                'schaft, für dich als Versicherten bindend',
            'DGUV Regeln und Informationen — Umsetzungshilfen und '
                'Empfehlungen, nicht bindend, aber praxisbewährt',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Unterschied, der zählt',
            text: 'DGUV Vorschriften sind verbindlich. DGUV Regeln zeigen, '
                'wie man sie umsetzt. DGUV Informationen sind Empfehlungen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Deine sechs Pflichten als Beschäftigter',
        blocks: [
          ParagraphBlock(
            'Der Arbeitgeber muss dich schützen — du musst mitmachen. '
            'Diese Pflichten gelten für jeden Beschäftigten, unabhängig '
            'von Position und Vertrag.',
          ),
          StepsBlock([
            'Für deine eigene Sicherheit und die deiner Kollegen sorgen',
            'Betriebsanweisungen und Unterweisungen befolgen',
            'Erste Hilfe leisten bzw. wirksame Erste Hilfe unterstützen',
            'Unfälle und Beinahe-Unfälle melden — auch kleine',
            'Defekte und Mängel sofort melden (defekte Kabel, kaputte '
                'Geräte, fehlerhafte Abläufe)',
            'Schutzausrüstung bestimmungsgemäß benutzen — '
                'Sicherheitsschuhe, Handschuhe, Warnweste, Gehörschutz',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Alkohol, Drogen, Medikamente',
            text: 'Du darfst dich und andere nicht durch berauschende '
                'Mittel gefährden. Das gilt für die gesamte Arbeitszeit — '
                'auch in der Pause, weil du danach wieder fährst. Auch '
                'Medikamente, die müde machen, gehören dazu: frag im '
                'Zweifel deinen Arzt.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ch02',
    title: 'Betriebsanweisungen',
    summary: 'Verbindliche Anweisungen — und warum sie dich schützen',
    asset: '${_a}ch02_betriebsanweisungen.svg',
    slides: [
      SafetySlide(
        title: 'Was eine Betriebsanweisung ist',
        asset: '${_a}ch02_betriebsanweisungen.svg',
        blocks: [
          ParagraphBlock(
            'Eine Betriebsanweisung ist eine verbindliche Anweisung deines '
            'Arbeitgebers für den Umgang mit Fahrzeugen, Arbeitsmitteln '
            'und Gefahrstoffen. Sie ist keine Empfehlung.',
          ),
          BulletsBlock([
            'Sie liegt im Betrieb aus — du musst sie kennen',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Das solltest du wissen',
            text: 'Wer gegen eine Betriebsanweisung verstößt, dem kann das '
                'bei der Unfalluntersuchung zugerechnet werden. Im '
                'schlimmsten Fall bedeutet das Mitverantwortung an einem '
                'Unfall — auch für dich persönlich.',
          ),
          ParagraphBlock(
            'Abgrenzung: Die Betriebsanweisung regelt den Umgang mit '
            'einem Arbeitsmittel oder Gefahrstoff. Die Arbeitsanweisung '
            'regelt den Ablauf eines Arbeitsprozesses.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Aufbau — sechs Abschnitte',
        blocks: [
          ParagraphBlock(
            'Jede Betriebsanweisung ist gleich aufgebaut. Wenn du den '
            'Aufbau kennst, findest du im Ernstfall sofort die richtige '
            'Stelle.',
          ),
          StepsBlock([
            'Geltungsbereich — wofür und für wen sie gilt',
            'Gefahren für Mensch und Umwelt',
            'Schutzmaßnahmen und Verhaltensregeln',
            'Verhalten bei Störungen',
            'Verhalten bei Unfällen und Erste Hilfe',
            'Entsorgung und Instandhaltung',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Beispiel: Fahren mit dem Transporter',
        blocks: [
          ParagraphBlock(
            'So sehen konkrete Regeln aus einer Betriebsanweisung für '
            'Fahrzeuge bis 3,5 t aus:',
          ),
          BulletsBlock([
            'Gültige Fahrerlaubnis mitführen',
            'Kein Alkohol und keine Drogen vor und während der Fahrt',
            'Rückwärtsfahren bei Gefährdung nur mit Einweiser',
            'Fahrzeug nach dem Verlassen generell abschließen',
            'Abschleppen nur mit Abschleppstange',
            'Unfallstelle absichern, jeden Unfall unverzüglich melden',
            'Auch kleinere Verletzungen sofort behandeln und ins '
                'Verbandbuch eintragen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Im Zweifel fragen',
            text: 'Wenn dir eine Anweisung unklar ist, frag deinen '
                'Dispatcher — bevor du losfährst, nicht danach.',
          ),
          SubheadBlock('Die wichtigsten Anweisungen'),
          ParagraphBlock(
            'Alle Betriebsanweisungen findest du jederzeit in der DA '
            'Academy unter „Betriebsanweisungen".',
          ),
          InstructionRefBlock([
            'baw_transporter',
            'baw_heben_tragen',
            'baw_winter',
          ]),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ch03',
    title: 'Die 10 Regeln für sicheres Arbeiten',
    summary: 'Der Kern deines Arbeitstags — jeden Tag gültig',
    asset: '${_a}ch03_sicheres_arbeiten.svg',
    slides: [
      SafetySlide(
        title: 'Zehn Regeln, jeden Tag',
        asset: '${_a}ch03_sicheres_arbeiten.svg',
        blocks: [
          StepsBlock([
            'Sicheres und umsichtiges Arbeiten',
            'Abfahrtkontrolle vor Antritt der Fahrt',
            'Sichern der Ladung im Fahrzeug',
            'Professionelles Fahren und Beachten der StVO',
            'Anlegen des Sicherheitsgurtes',
            'Fahrzeuge, Werkzeuge und Ausrüstungen in Ordnung halten',
            'Arbeiten nur mit geeigneten Schuhen',
            'Höflicher Umgang mit Kollegen und Kunden',
            'Einhaltung der Pausenregelung',
            'Toleranter und respektvoller Umgang',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die drei mit dem größten Effekt',
            text: 'Abfahrtkontrolle, Ladungssicherung, Sicherheitsgurt. '
                'Diese drei verhindern die meisten schweren Folgen — und '
                'kosten zusammen keine drei Minuten.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ch04',
    title: 'Persönliche Schutzausrüstung (PSA)',
    summary: 'Sicherheitsschuhe und Warnweste — deine tägliche Pflicht',
    asset: '${_a}ch04_psa.svg',
    slides: [
      SafetySlide(
        title: 'Deine PSA als Zusteller',
        asset: '${_a}ch04_psa.svg',
        blocks: [
          ParagraphBlock(
            'Persönliche Schutzausrüstung ist alles, was du am Körper '
            'trägst, um dich vor Gefahren zu schützen. In der Zustellung '
            'sind zwei Teile täglich Pflicht:',
          ),
          FactsBlock([
            FactItem('1', 'Sicherheitsschuhe'),
            FactItem('2', 'Warnweste'),
          ]),
          BulletsBlock([
            'Sicherheitsschuhe — den ganzen Arbeitstag, in der Station '
                'wie auf der Route',
            'Warnweste — griffbereit im Fahrzeug und angezogen, bevor du '
                'bei Panne, Unfall oder Halt an der Straße aussteigst',
          ]),
          SubheadBlock('Weitere PSA — je nach Tätigkeit'),
          ParagraphBlock(
            'Diese Ausrüstung ist nicht täglich vorgeschrieben, kann aber '
            'für bestimmte Arbeiten nötig sein. Was für dich gilt, steht '
            'in der Gefährdungsbeurteilung und der Betriebsanweisung.',
          ),
          BulletsBlock([
            'Schutzhandschuhe — bei scharfkantigen Sendungen, '
                'Reinigungs- und Wartungsarbeiten, im Winter',
            'Gehörschutz — bei Lärm, z. B. in bestimmten Hallenbereichen',
            'Schutzbrille — bei Arbeiten mit Spritzgefahr',
            'Kopfschutz — auf Baustellen und bei Gefahr herabfallender '
                'Gegenstände',
            'Wetterschutzkleidung — bei dauerhafter Arbeit im Freien',
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Benutzungspflicht',
            text: 'Vom Arbeitgeber bereitgestellte PSA musst du '
                'bestimmungsgemäß benutzen (§ 15 Arbeitsschutzgesetz). '
                'Der Arbeitgeber stellt sie kostenlos und muss die '
                'Einhaltung überwachen.',
          ),
          InstructionRefBlock(['baw_sicherheitsschuhe', 'baw_warnweste']),
        ],
      ),
      SafetySlide(
        title: 'Sicherheitsschuhe: Schutzwirkung',
        blocks: [
          ParagraphBlock(
            'Der Fußschutz ist die PSA, die du am häufigsten brauchst — '
            'und die am häufigsten unterschätzt wird.',
          ),
          SubheadBlock('Wovor sie schützen'),
          BulletsBlock([
            'Mechanisch — Anstoßen, Quetschen, herabfallende Pakete, '
                'Hineintreten in spitze Gegenstände',
            'Umknicken — knöchelhohe Schuhe stützen das Sprunggelenk und '
                'verhindern Bänderrisse und Knöchelverletzungen',
            'Elektrisch — antistatische Ableitung',
            'Chemisch — Säuren, Öle, Kraftstoffe',
            'Thermisch — Hitze und Kälte',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Warum knöchelhoch',
            text: 'Die häufigste Verletzung in der Zustellung ist das '
                'Umknicken beim Aussteigen, auf Bordsteinen und unebenen '
                'Wegen. Ein knöchelhoher Schuh stützt das Gelenk genau '
                'dort, wo es wegknickt — ein Halbschuh kann das nicht.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Auch wenn sie unbequem sind — und auch im Sommer',
            text: 'Die Tragepflicht gilt an jedem Arbeitstag, unabhängig '
                'von Wetter und Tragekomfort. Gerade im Sommer wird '
                'gewechselt — und genau dann passieren die Verletzungen. '
                'Drücken oder scheuern die Schuhe, ist das ein Grund für '
                'ein anderes Modell, kein Grund für Turnschuhe.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Prüf deine Schuhe regelmäßig',
            text: 'Abgelaufenes Profil, Risse oder starke Verschmutzung: '
                'austauschen lassen. Nimm keine eigenen Veränderungen vor '
                'und arbeite nie in Turnschuhen — auch nicht „nur kurz".',
          ),
        ],
      ),
      SafetySlide(
        title: 'Schutzklassen im Überblick',
        blocks: [
          TableBlock(
            headers: ['Klasse', 'Eigenschaften'],
            rows: [
              [
                'S1',
                'Geschlossener Fersenbereich, antistatisch, '
                    'kraftstoffbeständige Sohle',
              ],
              ['S2', 'wie S1 + mindestens 60 Minuten wasserundurchlässig'],
              ['S3', 'wie S2 + durchtrittsichere und profilierte Sohle'],
              ['S4', 'wie S2, komplett aus Gummi (vulkanisiert)'],
              ['S5', 'wie S4 + durchtrittsichere Sohle'],
            ],
          ),
          SubheadBlock('Wann sie besonders wichtig sind'),
          BulletsBlock([
            'Auf Leitern, Tritten und Treppen',
            'Bei Rollbehältern und Handhubwagen',
            'Auf unebenen Wegen und Rampen',
          ]),
          ParagraphBlock(
            'Merkmale eines guten Schuhs: fester Sitz, geschlossen, '
            'Fersenhalt mit Dämpfung, biegsame Sohle, niedriger Absatz, '
            'rutschhemmendes Profil.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ch05',
    title: 'Verhalten im Brandfall',
    summary: 'Feuerlöscher richtig einsetzen und Fahrzeugbrände beherrschen',
    asset: '${_a}ch05_brandfall.svg',
    slides: [
      SafetySlide(
        title: 'Feuerlöscher bedienen',
        asset: '${_a}ch05_brandfall.svg',
        blocks: [
          ParagraphBlock(
            'Es gibt Pulver-, Wasser-/Schaum- und CO₂-Löscher. Die '
            'Bedienung ist bei allen gleich:',
          ),
          StepsBlock([
            'Sicherung entfernen',
            'Schlagknopf betätigen',
            'Löschpistole betätigen',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Du hast nur Sekunden',
            text: 'Ein Löscher ist schneller leer, als die meisten denken. '
                'Deshalb: lieber mehrere Löscher gleichzeitig einsetzen '
                'als nacheinander.',
          ),
          FactsBlock([
            FactItem('6–12 s', 'Pulver 1–2 kg'),
            FactItem('15–23 s', 'Pulver 6 kg'),
            FactItem('18–33 s', 'Pulver 12 kg'),
            FactItem('20–30 s', 'Schaum 6 l'),
            FactItem('5–10 s', 'CO₂ 2 kg'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Richtig löschen — Schritt für Schritt',
        blocks: [
          ParagraphBlock(
            'Die Reihenfolge entscheidet, ob das Feuer ausgeht oder wieder '
            'aufflammt. Sieben Schritte, die du dir merken solltest:',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}fire01_pin.svg',
              title: 'Löscher bereitmachen',
              caption: 'Sicherung ziehen, Schlagknopf betätigen, Löscher '
                  'aufrecht halten. Erst dann zum Brand gehen.',
            ),
            IllustratedStep(
              asset: '${_a}fire02_wind.svg',
              title: 'In Windrichtung angreifen',
              caption: 'Der Wind muss in deinem Rücken sein und das '
                  'Löschmittel ins Feuer tragen — nie dagegen anlöschen. '
                  'So bleiben Hitze und Rauch von dir weg.',
            ),
            IllustratedStep(
              asset: '${_a}fire03_surface.svg',
              title: 'Flächenbrand: von vorn beginnen',
              caption: 'Auf die vordere Kante der Flammen zielen, in die '
                  'Glut hinein — nicht in die Flammenspitzen. Dann Stück '
                  'für Stück nach hinten arbeiten.',
            ),
            IllustratedStep(
              asset: '${_a}fire04_drip.svg',
              title: 'Tropfbrand: von oben nach unten',
              caption: 'Läuft brennende Flüssigkeit herab, oben an der '
                  'Austrittsstelle anfangen und nach unten arbeiten — '
                  'sonst brennt es von oben immer wieder nach.',
            ),
            IllustratedStep(
              asset: '${_a}fire05_together.svg',
              title: 'Mehrere Löscher gleichzeitig',
              caption: 'Sind mehrere Löscher und Helfer da: gemeinsam und '
                  'zur selben Zeit einsetzen. Nacheinander gibt dem Feuer '
                  'zwischen den Löschern Zeit, sich zu erholen.',
            ),
            IllustratedStep(
              asset: '${_a}fire06_watch.svg',
              title: 'Brandstelle beobachten',
              caption: 'Nach dem Löschen an der Stelle bleiben und '
                  'beobachten. Glutnester entzünden sich oft nach Minuten '
                  'erneut — mit Abstand und einsatzbereitem Löscher.',
            ),
            IllustratedStep(
              asset: '${_a}fire07_refill.svg',
              title: 'Benutzten Löscher neu befüllen lassen',
              caption: 'Ein benutzter Löscher gehört nie zurück an die '
                  'Wand — auch nicht nach einem kurzen Stoß. Sofort zur '
                  'Wiederbefüllung geben und Ersatz melden.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Wann du nicht löschst',
            text: 'Bring dich nie in Gefahr. Wenn der Brand größer als ein '
                'Papierkorb ist, sich stark Rauch entwickelt oder du den '
                'Fluchtweg riskierst: raus, Tür zu, 112 rufen und andere '
                'warnen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fahrzeugbrand',
        blocks: [
          SubheadBlock('Häufigste Ursachen'),
          BulletsBlock([
            'Undichtigkeiten bei Kraftstoff oder Öl',
            'Isoliermaterial an heißen Bauteilen',
            'Mechanische Schäden',
            'Elektrische Defekte',
            'Brennende Abfallbehälter',
          ]),
          SubheadBlock('Was du tust'),
          StepsBlock([
            'Nicht in Tunneln oder auf Brücken anhalten — wenn möglich '
                'herausfahren',
            'Warnblinker an, geeignete Stelle ansteuern, anhalten',
            'Fahrzeug verlassen, Abstand halten',
            'Feuerwehr 112 alarmieren — Standort mit Fahrtrichtung nennen',
            'Erst dann eigene Löschversuche, wenn es sicher ist',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Motorhaube: Vorsicht',
            text: 'Nur mit Handschuhen und nur einen Spalt öffnen. Durch '
                'die plötzliche Sauerstoffzufuhr können Stichflammen '
                'entstehen.',
          ),
          SubheadBlock('Was die Leitstelle wissen muss'),
          BulletsBlock([
            'Wo brennt es?',
            'Was brennt und in welchem Umfang?',
            'Wie viele Verletzte, welche Verletzungen?',
            'Was ist geladen?',
            'Wer meldet?',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Nicht auflegen',
            text: 'Beende das Telefonat nie selbst. Warte auf Rückfragen — '
                'die Leitstelle beendet das Gespräch.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ch06',
    title: 'Erste Hilfe',
    summary: 'Deine Pflicht, deine Absicherung und die Dokumentation',
    asset: '${_a}ch06_erste_hilfe.svg',
    slides: [
      SafetySlide(
        title: 'Helfen ist Pflicht — und abgesichert',
        asset: '${_a}ch06_erste_hilfe.svg',
        blocks: [
          ParagraphBlock(
            'Jeder ist verpflichtet, Erste Hilfe zu leisten — im Rahmen '
            'des Zumutbaren und ohne sich selbst erheblich zu gefährden. '
            'Auch als Laie.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 323c StGB — unterlassene Hilfeleistung',
            text: 'Wer nicht hilft, obwohl es zumutbar wäre, macht sich '
                'strafbar: bis zu einem Jahr Freiheitsstrafe oder '
                'Geldstrafe. Das gilt auch für „Gaffer", die Helfer '
                'behindern.',
          ),
          SubheadBlock('Wer hilft, macht nichts falsch'),
          BulletsBlock([
            'Als Ersthelfer haftest du nicht für Fehler — außer bei '
                'Vorsatz oder grober Fahrlässigkeit',
            'Du bist während der Hilfeleistung gesetzlich unfallversichert',
            'Kosten trägst du nicht; Sachschäden werden in der Regel '
                'ersetzt',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Der einzige echte Fehler',
            text: 'Nichts zu tun. Alles andere ist besser als Wegsehen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ersthelfer in der Station — und du',
        blocks: [
          ParagraphBlock(
            'In der Station gibt es ausgebildete betriebliche Ersthelfer. '
            'Dafür sorgt der Unternehmer: Die Organisation der Ersten '
            'Hilfe ist seine Aufgabe (§ 24 DGUV Vorschrift 1), und er '
            'muss eine Mindestzahl ausgebildeter Ersthelfer stellen '
            '(§ 26 DGUV Vorschrift 1).',
          ),
          FactsBlock([
            FactItem('1', 'Ersthelfer bei 2–20 Anwesenden'),
            FactItem('10 %', 'der Anwesenden in sonstigen Betrieben'),
            FactItem('2 Jahre', 'Fortbildung der Ersthelfer'),
          ]),
          ParagraphBlock(
            'Arbeiten mehrere Arbeitgeber auf demselben Gelände, müssen '
            'sie sich abstimmen und gegenseitig informieren '
            '(§ 8 Arbeitsschutzgesetz). Dabei kann vereinbart werden, '
            'dass die Erste-Hilfe-Organisation der Station mitgenutzt '
            'wird. Das regelt die Zusammenarbeit der Betriebe — nicht '
            'deine persönliche Pflicht.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Das entbindet dich nicht',
            text: 'Die Hilfeleistungspflicht nach § 323c StGB trifft jeden '
                'persönlich. Ausgebildete Ersthelfer in der Station ändern '
                'daran nichts.',
          ),
          SubheadBlock('So ist es rechtlich zu handhaben'),
          BulletsBlock([
            'Ist bereits jemand da und hilft tatsächlich ausreichend, '
                'musst du nicht selbst Hand anlegen',
            'Die Pflicht, Rettungsdienst zu alarmieren und Hilfe zu holen, '
                'bleibt in jedem Fall bestehen',
            'Du musst dich vergewissern, dass wirklich geholfen wird — '
                'Wegsehen mit dem Gedanken „da kümmert sich schon jemand" '
                'reicht nicht',
            'Auf Anweisung des Ersthelfers unterstützen: absichern, '
                'Rettungsdienst einweisen, Material holen, andere '
                'fernhalten',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Auf Tour bist du allein',
            text: 'Den größten Teil deiner Arbeitszeit bist du nicht in '
                'der Station, sondern unterwegs. Dort gibt es keinen '
                'Stationsersthelfer — bei einem Notfall auf der Route '
                'bist du der Ersthelfer.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Notruf absetzen',
        blocks: [
          FactsBlock([
            FactItem('112', 'Notruf, europaweit'),
          ]),
          SubheadBlock('Die fünf W-Fragen'),
          StepsBlock([
            'Wo ist es passiert?',
            'Wie viele Personen sind verletzt?',
            'Was ist passiert?',
            'Wer ruft an?',
            'Warten auf Rückfragen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Grundregeln beim Helfen',
            text: 'Ruhe bewahren · schnell handeln · eigene Sicherheit '
                'beachten · Unfallstelle absichern · nach bestem Wissen '
                'helfen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Dokumentation & Meldung',
        blocks: [
          ParagraphBlock(
            'Jede Verletzung wird dokumentiert — auch die kleine '
            'Schnittwunde. Das schützt dich, falls später Folgen '
            'auftreten.',
          ),
          SubheadBlock('Ins Verbandbuch gehören'),
          BulletsBlock([
            'Zeit und Ort',
            'Hergang',
            'Art und Umfang der Verletzung',
            'Name der verletzten Person',
            'Zeugen und Ersthelfer',
          ]),
          FactsBlock([
            FactItem('> 3 Tage', 'AU → Unfallanzeige nötig'),
            FactItem('3 Tage', 'Frist für die Anzeige'),
            FactItem('5 Jahre', 'Aufbewahrung, vertraulich'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Sofort melden',
            text: 'Tödliche Unfälle, Massenunfälle und schwere '
                'Gesundheitsschäden meldet der Unternehmer unverzüglich — '
                'informiere deinen Arbeitgeber deshalb immer sofort.',
          ),
          ParagraphBlock(
            'Verbandkästen müssen vollständig sein. Prüfe das Verfalldatum '
            'und melde fehlendes Material.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 7
  SafetyChapterContent(
    id: 'ch07',
    title: 'Sitzen & Bewegen',
    summary: 'Rücken schonen, Konzentration halten',
    asset: '${_a}ch07_sitzen_bewegen.svg',
    slides: [
      SafetySlide(
        title: 'Warum Sitzen zum Risiko wird',
        asset: '${_a}ch07_sitzen_bewegen.svg',
        blocks: [
          ParagraphBlock(
            'Langes, schlecht eingestelltes Sitzen ist mehr als '
            'unbequem — es kostet dich Aufmerksamkeit und Reaktionszeit.',
          ),
          BulletsBlock([
            'Ermüdung und nachlassende Konzentration',
            'Verspannungen und Rückenschmerzen',
            'Beschwerden an Hals- und Lendenwirbelsäule',
            'Unfälle durch verzögerte Reaktion',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Sitz richtig einstellen',
        blocks: [
          ParagraphBlock(
            'Nimm dir vor der ersten Fahrt zwei Minuten. Sieben '
            'Einstellungen entscheiden:',
          ),
          StepsBlock([
            'Sitzhöhe und Längsverstellung',
            'Sitzflächentiefe',
            'Neigung der Sitzfläche',
            'Neigung der Rückenlehne',
            'Lendenwirbelstütze',
            'Kopfstütze',
            'Lenkrad und Gurtverlauf',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Dynamisches Sitzen',
            text: 'Rücken ganz an die Lehne, aufrecht sitzen — und die '
                'Haltung immer wieder leicht verändern. Die beste '
                'Sitzposition ist die nächste.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Übungen für zwischendurch',
        blocks: [
          SubheadBlock('Im Sitzen'),
          BulletsBlock([
            'Lenkrad kräftig auseinanderziehen — 3–6 Sekunden halten, '
                '3 Wiederholungen',
            'Knie gegen den Druck der Hände pressen — 3–6 Sekunden, '
                '5 Wiederholungen',
            'Auf der Sitzfläche abstützen und Gewicht anheben — '
                '3 Wiederholungen',
          ]),
          SubheadBlock('Im Stehen'),
          BulletsBlock([
            'Arme nach oben strecken — ca. 8 Sekunden, 3–5 Wiederholungen',
            'Hände an den Hinterkopf, Ellenbogen nach hinten — ca. '
                '8 Sekunden, 3–5 Wiederholungen',
            'Ferse auf eine ca. 30 cm hohe Erhöhung, Bein dehnen — ca. '
                '8 Sekunden, 2–3 Mal je Bein',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ein trainierter Rücken hält mehr aus',
            text: 'Nutze die Pausenzeit — nicht zusätzliche Zeit.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 8
  SafetyChapterContent(
    id: 'ch08',
    title: 'Belastung & Konzentration',
    summary: 'Leistungsfähig und aufmerksam durch den Tag',
    asset: '${_a}ch08_psychische_belastung.svg',
    slides: [
      SafetySlide(
        title: 'Warum das zum Arbeitsschutz gehört',
        asset: '${_a}ch08_psychische_belastung.svg',
        blocks: [
          ParagraphBlock(
            'Wer unter Druck steht, reagiert langsamer, übersieht mehr und '
            'macht Fehler. Genau deshalb ist Belastung ein '
            'Sicherheitsthema — nicht erst dann, wenn jemand krank wird.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Gesetzlich vorgeschrieben',
            text: 'Seit 2013 muss die Gefährdungsbeurteilung ausdrücklich '
                'auch psychische Belastungen bei der Arbeit berücksichtigen '
                '(§ 5 Abs. 3 Nr. 6 Arbeitsschutzgesetz). Beurteilt werden '
                'die Arbeitsbedingungen — nicht einzelne Personen.',
          ),
          SubheadBlock('Was im Fahralltag Druck erzeugt'),
          BulletsBlock([
            'Enge Zeitfenster, Stau, Baustellen, Parkplatzsuche',
            'Unklare Zuständigkeiten beim Be- und Entladen',
            'Fehlende oder späte Informationen zur Tour',
            'Technische Probleme am Fahrzeug oder Gerät',
            'Schwierige Kundensituationen',
          ]),
          ParagraphBlock(
            'Das sind Bedingungen, an denen der Betrieb etwas ändern kann. '
            'Deshalb ist die wichtigste Regel: melden, solange es noch zu '
            'lösen ist.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Konzentriert bleiben — so geht es praktisch',
        blocks: [
          SubheadBlock('Während der Tour'),
          BulletsBlock([
            'Pausen als Werkzeug nutzen: kurz aussteigen, Blick in die '
                'Ferne, ein paar Schritte gehen — das stellt die '
                'Aufmerksamkeit messbar wieder her',
            'Ausreichend trinken und regelmäßig essen',
            'Nicht unter Zeitdruck rangieren — die zwei Minuten sind '
                'billiger als ein Blechschaden',
            'Handy erst im Stand bedienen, Adresseingabe vor der Abfahrt',
            'Nach schwierigen Kundenkontakten kurz durchatmen, bevor du '
                'weiterfährst',
          ]),
          SubheadBlock('Früh ansprechen statt aushalten'),
          ParagraphBlock(
            'Wenn etwas dauerhaft nicht passt, sag es deinem Dispatcher — '
            'früh und konkret. Eine Tour, die regelmäßig nicht zu schaffen '
            'ist, ein Fahrzeug, das Probleme macht, eine Route mit '
            'ständiger Parkplatznot: das lässt sich planen, wenn es '
            'jemand weiß.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Konkret melden hilft mehr als aushalten',
            text: 'Sag, was genau hakt und wo — nicht nur, dass es '
                'stressig war. Je konkreter die Rückmeldung, desto eher '
                'ändert sich etwas an der Planung.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Nach besonderen Ereignissen',
        blocks: [
          ParagraphBlock(
            'Manche Situationen wirken nach: ein schwerer Unfall, ein '
            'Überfall, ein Erste-Hilfe-Einsatz mit schwer verletzten '
            'Personen. Das ist eine normale Reaktion auf ein unnormales '
            'Ereignis — und kein Zeichen von Schwäche.',
          ),
          BulletsBlock([
            'Melde das Ereignis deinem Vorgesetzten, auch wenn dir selbst '
                'nichts passiert ist',
            'Nach Arbeitsunfällen gibt es Unterstützungsangebote über die '
                'Berufsgenossenschaft',
            'Viele Betriebe haben psychologische Ersthelfer oder '
                'Traumalotsen — frag im Büro nach',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Im akuten Notfall',
            text: 'Bei einer akuten seelischen Krise in Deutschland: '
                'Telefonseelsorge 0800 111 0 111 — kostenlos, anonym, rund '
                'um die Uhr erreichbar.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 9
  SafetyChapterContent(
    id: 'ch09',
    title: 'Sicheres Fahren & Abfahrtkontrolle',
    summary: 'Zwei Minuten Kontrolle vor jeder Tour',
    asset: '${_a}ch09_sicheres_fahren.svg',
    slides: [
      SafetySlide(
        title: 'Der Rundgang ums Fahrzeug',
        asset: '${_a}ch09_sicheres_fahren.svg',
        blocks: [
          ParagraphBlock(
            'Vor jedem Fahrtantritt ist ein Abfahrtscheck Pflicht. Er '
            'dauert zwei Minuten und findet genau die Mängel, die '
            'unterwegs teuer oder gefährlich werden.',
          ),
          BulletsBlock([
            'Beleuchtung vorne und hinten',
            'Sicht — Spiegel und Scheiben sauber und unbeschädigt',
            'Räder — Luftdruck, Profil, Befestigung',
            'Bremsen — Bremsprobe, Bremsdruck',
            'Motor und Antrieb — Öl, Kühl- und Bremsflüssigkeit, '
                'Scheibenwaschwasser, keine Leckagen',
            'Planen und Türen geschlossen',
            'Kennzeichen und Warntafeln sauber',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Ladung & Fahrerarbeitsplatz',
        blocks: [
          SubheadBlock('Ladungssicherung'),
          BulletsBlock([
            'Ist das Fahrzeug für diese Ladung geeignet?',
            'Zurrmittel unbeschädigt?',
            'Ladung gesichert und gegen Verrutschen geschützt?',
            'Achslasten und zulässige Gesamtmasse eingehalten?',
          ]),
          SubheadBlock('Dein Arbeitsplatz'),
          BulletsBlock([
            'Sitz und Lenkrad richtig eingestellt',
            'Kontrolleinrichtungen ohne Störungsmeldung',
            'Bremsprobe unauffällig',
            'Fahrerassistenzsysteme eingeschaltet und einsatzbereit',
            'Lüftung funktionsfähig',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Im Winter zusätzlich',
            text: 'Geeignete Bereifung, gegebenenfalls Schneeketten oder '
                'Anfahrhilfen, ausreichend Frostschutz in Kühlflüssigkeit '
                'und Scheibenwaschwasser, Eiskratzer an Bord.',
          ),
          InstructionRefBlock(['baw_transporter', 'baw_winter']),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 10
  SafetyChapterContent(
    id: 'ch10',
    title: 'Pannen & Unfälle',
    summary: 'Absichern, helfen, richtig dokumentieren',
    asset: '${_a}ch10_pannen_unfaelle.svg',
    slides: [
      SafetySlide(
        title: 'Grundregel und Panne',
        asset: '${_a}ch10_pannen_unfaelle.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die Grundregel',
            text: 'Eigenschutz geht vor Fremdschutz. Personenschutz geht '
                'vor Sachschutz.',
          ),
          SubheadBlock('Wenn sich eine Panne ankündigt'),
          StepsBlock([
            'Frühzeitig einen geeigneten Halteplatz suchen — z. B. bei '
                'steigender Kühlwassertemperatur',
            'Warnblinkanlage schon beim Ausrollen einschalten',
            'Wenn möglich zum nächsten Parkplatz, sonst äußerster rechter '
                'Fahrbahnrand',
            'Feststellbremse anziehen, bei Dunkelheit Standlicht an',
            'Warnweste anziehen — vor dem Aussteigen',
            'Warndreieck aufstellen',
          ]),
          FactsBlock([
            FactItem('100 m', 'Warndreieck, Landstraße'),
            FactItem('150–400 m', 'Warndreieck, Autobahn'),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Notfallplan bei einem Unfall',
        blocks: [
          StepsBlock([
            'Anhalten — immer, auch wenn niemand da ist',
            'Unfallstelle absichern — Warnblinker, Feststellbremse, bei '
                'Dunkelheit Standlicht, Warnweste vor dem Aussteigen, '
                'Warndreieck',
            'Erste Hilfe leisten — unverzüglich',
            'Notruf 112 absetzen — bei Dringlichkeit auch vor der Ersten '
                'Hilfe',
            'Personalien austauschen — Name, Anschrift, Kennzeichen, '
                'Versicherung',
            'Polizei rufen — bei Personenschäden, hohem Sachschaden oder '
                'Verdacht auf Alkohol/Drogen',
            'Beweise sichern — Fotos von Unfallstelle und Schäden, '
                'Kontaktdaten von Zeugen',
            'Arbeitgeber informieren und Vorgehen absprechen, '
                'Fahrtüchtigkeit prüfen, Warndreieck wieder einpacken',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Parkschaden & die häufigste Verletzung',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Ein Zettel reicht nicht',
            text: 'Wenn du ein parkendes Auto touchierst und niemand da '
                'ist: mindestens 30 Minuten warten. Danach Name und '
                'Anschrift hinterlassen UND den Unfall unverzüglich bei '
                'der nächsten Polizeidienststelle melden. Sonst ist es '
                'Unfallflucht.',
          ),
          SubheadBlock('Wo Fahrer sich wirklich verletzen'),
          FactsBlock([
            FactItem('51,6 %', 'Stürze und Abstürze'),
            FactItem('7,2 %', 'Verkehrsunfälle'),
          ]),
          ParagraphBlock(
            'Die meisten meldepflichtigen Unfälle passieren nicht im '
            'Straßenverkehr, sondern beim Auf- und Absteigen vom '
            'Führerhaus oder der Ladefläche.',
          ),
          DoDontBlock(
            doTitle: 'Richtig',
            dos: [
              'Vorgesehene Aufstiege und Haltegriffe benutzen',
              'Drei-Punkt-Kontakt beim Ein- und Aussteigen',
              'Aufstiege sauber und frei halten',
              'Geeignetes Schuhwerk tragen',
            ],
            dontTitle: 'Gefährlich',
            donts: [
              'Aus dem Führerhaus oder von der Ladefläche abspringen',
              'Verschmutzte, vereiste oder zugestellte Aufstiege begehen',
              'Auf nicht dafür vorgesehene Fahrzeugteile oder die Ladung '
                  'steigen',
              'Schadhafte Leitern benutzen',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 11
  SafetyChapterContent(
    id: 'ch11',
    title: 'Die 3-Punkte-Regel',
    summary: 'Ein- und Aussteigen — die wichtigste Einzelregel',
    asset: '${_a}step3p_cover.svg',
    slides: [
      SafetySlide(
        title: 'Immer 3 von 4 Kontaktpunkten',
        asset: '${_a}step3p_cover.svg',
        blocks: [
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die Grundregel',
            text: '2 Hände + 1 Fuß  ODER  2 Füße + 1 Hand. Drei Punkte '
                'haben immer festen Kontakt zum Fahrzeug.',
          ),
          ParagraphBlock(
            'Du steigst täglich dutzende Male ein und aus — in Eile, bei '
            'Regen, mit vollen Händen. Genau dabei passieren die meisten '
            'Unfälle. Drei feste Punkte geben dir Halt und verhindern '
            'Stürze und Verletzungen an Knöchel, Knie und Rücken.',
          ),
          FactsBlock([
            FactItem('51,6 %', 'aller Unfälle sind Stürze'),
            FactItem('7,2 %', 'sind Verkehrsunfälle'),
          ]),
          ParagraphBlock(
            'Kein anderer Handgriff im Arbeitsalltag verhindert so viele '
            'Verletzungen wie dieser. Deshalb steht er am Ende dieser '
            'Unterweisung — als das, was hängenbleiben soll.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die vier Regeln im Einzelnen',
        blocks: [
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_01_face.svg',
              title: 'Gesicht zum Fahrzeug',
              caption: 'Steig immer zum Fahrzeug gewandt aus — nie '
                  'rückwärts oder seitlich herausspringen. Springen ist '
                  'die häufigste Unfallursache. Nutze immer Trittstufe '
                  'und Haltegriffe.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_02_hands.svg',
              title: 'Erst absetzen, dann greifen',
              caption: 'Keine Pakete in der Hand beim Ein- und '
                  'Aussteigen. Setz die Sendung erst ab oder verstau '
                  'Kleinteile in Tasche oder Gürtel — die Hände bleiben '
                  'frei zum Festhalten.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_03_onepoint.svg',
              title: 'Nur einen Punkt bewegen',
              caption: 'Bewege immer nur eine Hand oder einen Fuß, '
                  'während die anderen drei festen Halt haben. Nicht '
                  'hetzen — auch nicht, wenn die Tour drängt.',
            ),
            IllustratedStep(
              asset: '${_a}step3p_04_steps.svg',
              title: 'Auf Stufen und Halt achten',
              caption: 'Nässe, Schnee, Öl und Schmutz im Blick behalten. '
                  'Ruhig und kontrolliert auftreten, Stufen bei Bedarf '
                  'vorher säubern.',
            ),
          ]),
        ],
      ),
      SafetySlide(
        title: 'Zwei Dinge, die dazugehören',
        blocks: [
          SubheadBlock('Halbhohe Sicherheitsschuhe'),
          ParagraphBlock(
            'Halbhohe Schuhe schließen den Knöchel ein und stabilisieren '
            'das Sprunggelenk deutlich besser — genau dort passiert das '
            'Umknicken beim Absteigen.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Schon mal umgeknickt?',
            text: 'Wer bereits Knöchelprobleme hatte, sollte sich '
                'halbhohe Schuhe geben lassen — vor der nächsten Tour, '
                'nicht danach.',
          ),
          IllustratedStepsBlock([
            IllustratedStep(
              asset: '${_a}step3p_05_phone.svg',
              title: 'Kein privates Handy in der Hand',
              caption: 'Telefonieren, tippen und scrollen macht '
                  'unkonzentriert — genau daraus entstehen Stürze und '
                  'Unfälle. Private Anrufe und Nachrichten warten bis zur '
                  'Pause. Beim Ein- und Aussteigen gehört das Handy '
                  'weggesteckt.',
            ),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Kurz gemerkt',
            text: 'Gesicht zum Fahrzeug · drei Punkte halten · Hände frei '
                '· halbhohe Sicherheitsschuhe · kein privates Handy · '
                'Stufen nutzen statt springen.',
          ),
        ],
      ),
    ],
  ),
];
