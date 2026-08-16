// lib/data/safety_training/ride_along_content_de.dart
//
// Inhalte der Ride-Along-Schulung — deutsche Fassung.
//
// Der „Ride Along" ist die zweitägige Begleitfahrt für neue Fahrer: Tag 1
// mit einer kleineren Zahl Stopps, Tag 2 mit deutlich mehr. Der Trainer
// arbeitet dabei eine Checkliste ab, quittiert jeden Punkt und gibt am
// Ende ein Feedback; das Blatt wird als Foto beim zuständigen Dispatcher
// abgegeben.
//
// Zweck dieser Schulung: VORBEREITUNG. Wer sie vorher durchgeht, hört die
// Themen der zwei Tage nicht zum ersten Mal, sondern kann gezielt
// nachfragen und die Begleitfahrt bewusst nutzen.
//
// Aufbau wie beim Green Book: je Kapitel mehrere Folien aus typisierten
// Bausteinen — Zahlen-Kacheln, Fallbeispiele zum Nachdenken (Reveal),
// Do/Don't, Merksätze und eine Checkliste am Kapitelende. Für dieses
// Thema gibt es keine Illustrationen, deshalb `asset: ''`.
//
// Mandantenfähig: KEINE Personennamen, keine Stationsnamen, keine
// betriebsspezifischen Zahlen als Regel. Stoppzahlen, Waiting-Area-
// Zeiten, Arbeitsbeginn und Parkseite sind ausdrücklich Vorgaben der
// jeweiligen Station — sie nennt der Trainer. Firmenwerkzeuge wie die
// Zeiterfassung stehen nur als Beispiel („z. B. Kenjo"). Konkret
// bleiben dürfen: die Amazon-Werkzeuge (Flex, Mentor, ATLAS,
// Scorecard), die App CoDriver, die Pausenregeln nach § 4 ArbZG und
// das Green Book nach § 1 Abs. 6 FPersV — alles drei gilt
// betriebsübergreifend.

import 'safety_blocks.dart';

const List<SafetyChapterContent> rideAlongContentDe = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ra1',
    title: 'Was der Ride Along ist',
    summary: 'Zwei Tage Begleitfahrt: Ziel, Ablauf, wer dabei ist und '
        'wie bewertet wird',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Zwei Tage neben einem erfahrenen Fahrer',
        blocks: [
          ParagraphBlock(
            'Der Ride Along ist deine Begleitfahrt zum Einstieg: zwei '
            'Arbeitstage, an denen ein erfahrener Fahrer als Trainer mit '
            'dir unterwegs ist. Du lernst die Tour nicht aus einer '
            'Präsentation kennen, sondern genau dort, wo sie stattfindet — '
            'in der Station, in der Loading Area und auf der Straße.',
          ),
          FactsBlock([
            FactItem('2 Tage', 'Begleitfahrt mit einem Trainer'),
            FactItem('Tag 1', 'kleinere Zahl Stopps — in vielen Betrieben '
                'rund 20'),
            FactItem('Tag 2', 'deutlich mehr Stopps — in vielen Betrieben '
                'rund 70'),
          ]),
          ParagraphBlock(
            'Die beiden Tage bauen aufeinander auf. Am ersten Tag liegt der '
            'Schwerpunkt auf den Abläufen: Wie kommt man in die Station, '
            'welche Apps startet man wann, wie wird beladen, wann ist '
            'Pause. Am zweiten Tag steigt die Menge deutlich, und du '
            'fährst und stellst selbst zu — der Trainer begleitet, '
            'übernimmt aber nicht.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Die Stoppzahlen sind Richtwerte',
            text: 'Wie viele Stopps an Tag 1 und Tag 2 tatsächlich '
                'vorgesehen sind, legt dein Betrieb bzw. deine Station '
                'fest. Verbreitet sind rund 20 am ersten und rund 70 am '
                'zweiten Tag — verbindlich ist aber allein die Vorgabe, '
                'die dir dein Trainer oder dein zuständiger Dispatcher '
                'nennt.',
          ),
          BulletsBlock([
            'Beide Tage laufen über deinen eigenen Account, nicht über den '
                'des Trainers',
            'Die Stopps zählen als echte Arbeit, nicht als Trockenübung',
            'Der Trainer erklärt, zeigt vor und lässt dich anschließend '
                'selbst machen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kurz gesagt',
            text: 'Der Ride Along ist deine Einarbeitung im Echtbetrieb. '
                'Am Ende sollst du eine Tour allein fahren können — das '
                'ist der Maßstab, an dem sich alles orientiert.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wer dabei ist und wer was macht',
        blocks: [
          ParagraphBlock(
            'Am Ride Along sind drei Rollen beteiligt. Wenn du weißt, wer '
            'wofür zuständig ist, fragst du nicht die falsche Person und '
            'verlierst keine Zeit.',
          ),
          TableBlock(
            headers: ['Rolle', 'Aufgabe'],
            rows: [
              [
                'Du',
                'Fährst, stellst zu, fragst nach, machst mit — beide Tage '
                    'über deinen eigenen Account',
              ],
              [
                'Trainer',
                'Erfahrener Fahrer: erklärt jeden Punkt, zeigt es vor, '
                    'beobachtet dich, hakt die Checkliste ab und '
                    'unterschreibt',
              ],
              [
                'Dispatcher',
                'Plant die zwei Tage ein, ist Ansprechpartner bei '
                    'Problemen und nimmt am Ende das Foto der Checkliste '
                    'entgegen',
              ],
            ],
          ),
          ParagraphBlock(
            'Der Trainer ist nicht dein Vorgesetzter und nicht dein '
            'Prüfer im Sinne einer Behörde. Er ist der Kollege, der die '
            'Station am besten kennt. Genau deshalb ist er die richtige '
            'Adresse für jede Frage, die dir während der zwei Tage '
            'einfällt — auch für die, die dir banal vorkommt.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Fragen kosten nichts',
            text: 'Eine Frage am Ride Along ist billig. Dieselbe Frage in '
                'Woche drei, allein auf der Tour, mit einer vollen Route '
                'vor dir, ist teuer.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die Checkliste und das Feedback',
        blocks: [
          ParagraphBlock(
            'Der Trainer arbeitet ein festes Blatt ab — die Ride-Along-'
            'Checkliste. Darauf steht für jeden der beiden Tage, was '
            'erklärt und gezeigt worden sein muss: von der '
            'Fahrzeuginspektion über die Pausenregeln bis zu den '
            'Passwort-Paketen. Jeder Punkt wird quittiert, jeder Tag wird '
            'mit Datum und Unterschrift abgeschlossen.',
          ),
          BulletsBlock([
            'Die Checkliste ist der Nachweis, dass du eingearbeitet wurdest',
            'Sie schützt auch dich: Was abgehakt ist, wurde dir erklärt',
            'Nach dem zweiten Tag gibt der Trainer ein Feedback zu Leistung '
                'und Fahrfähigkeiten',
          ]),
          ParagraphBlock(
            'Es ist keine Prüfung mit Fallbeil. Niemand erwartet, dass du '
            'am ersten Tag die Tour wie ein Fahrer mit drei Jahren '
            'Erfahrung fährst. Aber es wird bewertet: Der Trainer schreibt '
            'auf, wie du arbeitest, und das Blatt geht an den Betrieb. '
            'Wer sichtbar mitdenkt, pünktlich ist und Hinweise annimmt, '
            'bekommt ein gutes Feedback — auch wenn er langsam ist.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der Unterschied, auf den es ankommt',
            text: 'Bewertet wird nicht, ob du alles kannst, sondern ob du '
                'lernbereit bist und die Regeln ernst nimmst. Fehler sind '
                'normal. Fehler zweimal erklärt zu bekommen und trotzdem '
                'zu ignorieren, ist es nicht.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Am ersten Tag verwechselst du zweimal '
                'die Reihenfolge der Pakete am Rollwagen und brauchst für '
                'deine Stopps deutlich länger als geplant. Du bist sicher, '
                'dass der Ride Along damit gelaufen ist. Stimmt das?',
            answer: 'Nein. Genau dafür ist der erste Tag da. Der Trainer '
                'erwartet Tempo erst am zweiten Tag ansatzweise und in den '
                'Wochen danach richtig. Was er am ersten Tag bewertet, ist '
                'etwas anderes: Fragst du nach, wenn du unsicher bist? '
                'Machst du denselben Fehler beim dritten Mal noch? '
                'Sortierst du danach von dir aus sauberer? Wer den Fehler '
                'anspricht und beim nächsten Rollwagen bewusst anders '
                'vorgeht, hinterlässt einen besseren Eindruck als jemand, '
                'der schnell ist und nichts hinterfragt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste: Kapitel 1',
        blocks: [
          ChecklistBlock(
            title: 'Das nehme ich aus Kapitel 1 mit',
            items: [
              'Der Ride Along sind zwei Arbeitstage mit einem Trainer',
              'Tag 1 weniger Stopps, Tag 2 deutlich mehr — die genaue Zahl '
                  'gibt mein Betrieb vor (verbreitet rund 20 und rund 70)',
              'Beide Tage laufen über meinen eigenen Account',
              'Der Trainer erklärt, zeigt vor und lässt mich selbst machen',
              'Er hakt eine Checkliste ab und unterschreibt je Tag',
              'Nach Tag 2 gibt es ein Feedback zu Leistung und '
                  'Fahrfähigkeiten',
              'Es ist Einarbeitung, aber sie wird bewertet — Lernbereitschaft '
                  'zählt mehr als Tempo',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Ein Satz für die zwei Tage',
            text: '„Ich frage lieber einmal zu viel als einmal zu wenig — '
                'dafür sind diese zwei Tage da."',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ra2',
    title: 'Der erste Tag',
    summary: 'Erste Stopps, App-Start, Inspektion, Loading Area, Pausen '
        'und Fahrzeugschlüssel',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Die ersten Stopps mit deinem eigenen Account',
        blocks: [
          ParagraphBlock(
            'Der erste Tag hat eine Mindestmenge an Stopps, die du '
            'gefahren und zugestellt haben sollst — über deinen eigenen '
            'Account. Sie ist bewusst klein gehalten (in vielen Betrieben '
            'rund 20); die verbindliche Zahl nennt dir dein Trainer für '
            'deine Station. Es geht an Tag 1 nicht um Menge, sondern '
            'darum, dass jeder Handgriff einmal richtig sitzt.',
          ),
          ParagraphBlock(
            'Wichtig ist der eigene Account. Nicht der des Trainers, nicht '
            'ein Sammelzugang. Alles, was du an diesem Tag zustellst, läuft '
            'unter deinem Namen — genau so, wie es später auch zählt. Nur '
            'so sehen der Trainer und der Betrieb, wie deine Zustellung '
            'wirklich aussieht.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Ohne Zugang kein Ride Along',
            text: 'Wenn dein Account am Morgen nicht funktioniert, sag es '
                'sofort — vor dem Losfahren, nicht am ersten Stopp. Ein '
                'ungeklärter Zugang kostet den ganzen Tag.',
          ),
          SubheadBlock('Die CoDriver-App'),
          ParagraphBlock(
            'CoDriver ist die App des Betriebs — die App, in der du gerade '
            'liest. Sie ist getrennt von den Amazon-Werkzeugen: Amazon '
            'steuert die Tour, CoDriver alles rund um deine Arbeit im '
            'Unternehmen. Der Trainer geht sie am ersten Tag mit dir durch.',
          ),
          BulletsBlock([
            'Schichtplan und Wave-Plan: wann du arbeitest und in welcher '
                'Welle du startest',
            'Abwesenheiten und Krankmeldungen melden',
            'DA Academy: Schulungen wie diese hier, dazu die '
                'Betriebsanweisungen',
            'Nachrichten und Benachrichtigungen des Betriebs',
            'Unfall- und Schadensmeldungen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Merke',
            text: 'Amazon-Apps steuern die Tour. CoDriver steuert dein '
                'Arbeitsverhältnis. Beides brauchst du täglich, und beides '
                'gehört an Tag 1 einmal komplett angesehen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Ankommen: Arbeitszeiten, Parkseite, Waiting Area',
        blocks: [
          ParagraphBlock(
            'Der Tag beginnt nicht mit dem ersten Stopp, sondern mit dem '
            'Ankommen an der Station. Drei Dinge legt der Trainer dir am '
            'ersten Tag fest ans Herz, weil sie sich jeden einzelnen '
            'Arbeitstag wiederholen.',
          ),
          SubheadBlock('1 — Arbeitszeiten'),
          ParagraphBlock(
            'Deine Schicht hat einen festen Beginn. Er steht im Schichtplan '
            'in CoDriver, und „Beginn" heißt: zu dieser Zeit bist du '
            'einsatzbereit an der Station — nicht auf dem Weg dorthin. Die '
            'konkreten Uhrzeiten deiner Station nennt dir der Trainer, sie '
            'unterscheiden sich je nach Standort und Welle.',
          ),
          SubheadBlock('2 — Parkseite'),
          ParagraphBlock(
            'Jede Station hat eine Regelung, wo Privatfahrzeuge stehen '
            'dürfen und auf welcher Seite die Transporter aufgestellt '
            'werden. Das ist keine Schikane: Auf dem Hof rangieren viele '
            'Fahrzeuge gleichzeitig, oft rückwärts und mit schlechter '
            'Sicht. Wer falsch parkt, blockiert eine Fahrgasse oder steht '
            'im toten Winkel eines Rangierenden. Der Trainer zeigt dir die '
            'Seite, die für dich gilt.',
          ),
          SubheadBlock('3 — Waiting-Area-Zeiten'),
          ParagraphBlock(
            'Die Waiting Area ist der Bereich, in dem du wartest, bis dein '
            'Rollwagen oder deine Ladeposition aufgerufen wird. Dafür gibt '
            'es feste Zeitfenster je Welle. Wer zu früh dort steht, '
            'verstopft den Bereich; wer zu spät kommt, verpasst seinen '
            'Aufruf und schiebt die ganze Welle nach hinten. Die genauen '
            'Zeiten für deine Station nennt dir der Trainer am ersten Tag — '
            'schreib sie dir auf.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Die drei Zahlen, die du dir notieren solltest',
            text: 'Schichtbeginn, Parkseite und dein Waiting-Area-Fenster. '
                'Diese drei Angaben brauchst du ab dem Tag danach jeden '
                'Morgen — und dann fragt dich niemand mehr.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du bist pünktlich zum Schichtbeginn am '
                'Tor, brauchst dann aber zehn Minuten für einen Parkplatz, '
                'weil du auf der falschen Seite gesucht hast. In der '
                'Waiting Area bist du damit zu spät. Wie schlimm ist das?',
            answer: 'Schlimmer, als es aussieht. Der Aufruf in der Waiting '
                'Area ist getaktet: Wenn du dein Fenster verpasst, rutschst '
                'du hinter die anderen Fahrer deiner Welle. Dein Rollwagen '
                'wartet, dein Fahrzeug blockiert dabei möglicherweise eine '
                'Position, und dein Start verschiebt sich um mehr als die '
                'zehn Minuten, die du verloren hast. Deshalb gehören '
                'Parkseite und Waiting-Area-Zeit zusammen: „pünktlich am '
                'Tor" ist nicht dasselbe wie „pünktlich in der Waiting '
                'Area". Plane die Zeit zum Parken und Laufen mit ein.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Der Start: Zeiterfassung, Mentor und Flex',
        blocks: [
          ParagraphBlock(
            'Drei Systeme müssen am Anfang der Schicht laufen — und zwar '
            'rechtzeitig und in dieser Reihenfolge. Jedes hat einen anderen '
            'Zweck, und jedes verursacht Ärger, wenn es zu spät gestartet '
            'wird.',
          ),
          StepsBlock([
            'Die Zeiterfassung deines Betriebs (z. B. Kenjo) — Einstempeln '
                'zum Schichtbeginn. Was du hier nicht startest, ist keine '
                'bezahlte Arbeitszeit und fehlt später in deiner '
                'Abrechnung. Welches System dein Betrieb nutzt, zeigt dir '
                'der Trainer.',
            'Mentor — die Fahrverhaltens-App von Amazon: muss laufen, bevor '
                'du losfährst. Sie zeichnet dein Fahrverhalten auf und '
                'liefert die Daten für deinen Score.',
            'Flex — die Zustell-App von Amazon: hier bekommst du deine '
                'Route, scannst die Pakete und dokumentierst jede '
                'Zustellung.',
          ]),
          SubheadBlock('Die 4 Stunden von Mentor'),
          ParagraphBlock(
            'Mentor läuft nicht unbegrenzt: Die App zeichnet jeweils rund '
            'vier Stunden am Stück auf. Danach musst du sie neu starten, '
            'sonst läuft der Rest deiner Tour unerfasst. Genau das ist der '
            'häufigste Anfängerfehler — die App wurde morgens korrekt '
            'gestartet, aber nach der Mittagspause nicht wieder aktiviert. '
            'Der Trainer zeigt dir am ersten Tag, woran du erkennst, dass '
            'Mentor noch mitläuft.',
          ),
          FactsBlock([
            FactItem('4 h', 'Aufzeichnungsdauer von Mentor am Stück'),
            FactItem('vor Abfahrt', 'Mentor starten — nicht erst unterwegs'),
            FactItem('nach der Pause', 'Mentor prüfen und neu starten'),
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Häufigster Fehler am ersten Tag',
            text: 'Flex läuft, Mentor nicht. Dann fährst du zwar deine '
                'Route, aber dein Fahrverhalten wird nicht erfasst — und '
                'fehlende Mentor-Zeit fällt im Betrieb genauso auf wie ein '
                'schlechter Wert.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du merkst um 14 Uhr, dass Mentor seit '
                'der Pause nicht mehr läuft. Was tust du — bis Feierabend '
                'weiterfahren und es morgen besser machen, oder sofort '
                'reagieren?',
            answer: 'Sofort reagieren: an der nächsten sicheren Stelle '
                'anhalten, Mentor neu starten, weiterfahren. Der '
                'naheliegende Irrtum ist zu denken, ein halber Tag ohne '
                'Aufzeichnung sei egal, weil man ja ordentlich gefahren '
                'ist. Ist er nicht: Für den Betrieb sieht eine Lücke aus '
                'wie eine Lücke — nicht wie gutes Fahren. Und weiterfahren '
                'heißt, die Lücke mit jeder Stunde größer zu machen. Melde '
                'es zusätzlich deinem Trainer oder deinem zuständigen '
                'Dispatcher, damit die Lücke erklärbar ist.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fahrzeuginspektion und Loading Area',
        blocks: [
          SubheadBlock('Die Fahrzeuginspektion'),
          ParagraphBlock(
            'Bevor du losfährst, wird das Fahrzeug geprüft — und nach der '
            'Tour noch einmal. Die Inspektion ist eine Sichtprüfung mit '
            'Dokumentation: Du gehst einmal um den Transporter herum, '
            'schaust dir jede Seite an, prüfst die Funktionen und hältst '
            'fest, was du siehst.',
          ),
          BulletsBlock([
            'Rundgang außen: Karosserie, Stoßfänger, Spiegel, Scheiben — '
                'jede Delle und jeder Kratzer',
            'Reifen: Profil, sichtbare Schäden, Luftdruck-Eindruck',
            'Licht: Abblendlicht, Bremslicht, Blinker, Rückfahrscheinwerfer',
            'Innenraum und Laderaum: Sauberkeit, lose Teile, Trennwand',
            'Ausstattung: Warndreieck, Warnweste, Verbandkasten',
            'Kilometerstand und Tank- bzw. Ladezustand',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Warum die Inspektion VOR der Fahrt zählt',
            text: 'Ein Schaden, den du vorher dokumentierst, ist ein '
                'Vorschaden. Derselbe Schaden, den du nicht dokumentierst, '
                'ist am Abend dein Schaden. Die zwei Minuten Rundgang sind '
                'die günstigste Versicherung deines Arbeitstages.',
          ),
          SubheadBlock('Beladen des Rollwagens in der Loading Area'),
          ParagraphBlock(
            'In der Loading Area steht dein Rollwagen mit den Paketen '
            'deiner Route. Wie du ihn in den Transporter räumst, '
            'entscheidet über deinen ganzen Tag: Wer unsortiert einlädt, '
            'sucht an jedem Stopp — und das summiert sich über eine volle '
            'Tour zu Stunden.',
          ),
          BulletsBlock([
            'In der Reihenfolge der Route einladen: was zuerst raus muss, '
                'kommt zuletzt rein und liegt vorn',
            'Schwere Pakete nach unten, leichte nach oben — nicht umgekehrt',
            'Ladung sichern: nichts darf beim Bremsen nach vorn rutschen',
            'Nichts in den Durchgang oder vor die Schiebetür stapeln',
            'Sonderpakete (Passwort, ATLAS, Sperrgut) getrennt und '
                'griffbereit legen',
            'Den leeren Rollwagen zurückstellen, wo er hingehört — nicht '
                'irgendwo abstellen',
          ]),
          DoDontBlock(
            doTitle: 'So machst du es richtig',
            dos: [
              'Beim Einladen schon mitdenken, welcher Stopp der erste ist',
              'Beim Heben in die Knie gehen, Last nah am Körper',
              'Fragen, wenn du nicht weißt, wohin ein Paket gehört',
            ],
            dontTitle: 'Das kostet dich später Zeit',
            donts: [
              'Alles hineinwerfen und „unterwegs sortieren"',
              'Pakete auf die Trennwand oder in den Fahrerbereich legen',
              'Den Rollwagen mitten in der Fahrgasse stehen lassen',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Pausen, Schlüssel und automatische Verriegelung',
        blocks: [
          SubheadBlock('Pausen: 30 und 45 Minuten'),
          ParagraphBlock(
            'Es gibt zwei Pausenlängen, und welche für dich gilt, hängt '
            'allein an deiner Arbeitszeit an diesem Tag. Anders als '
            'Waiting-Area-Zeiten oder Stoppzahlen ist das keine Vorgabe '
            'deiner Station, sondern Gesetz: § 4 Arbeitszeitgesetz '
            '(ArbZG). Die Regel gilt damit in jedem Betrieb gleich und ist '
            'nicht verhandelbar.',
          ),
          FactsBlock([
            FactItem('30 min', 'bei mehr als 6 bis zu 9 Stunden Arbeitszeit'),
            FactItem('45 min', 'bei mehr als 9 Stunden Arbeitszeit'),
            FactItem('15 min', 'kleinste anrechenbare Teilpause'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: '§ 4 ArbZG — die Rechtsgrundlage',
            text: 'Das Arbeitszeitgesetz schreibt bei mehr als 6 Stunden '
                'Arbeitszeit mindestens 30 Minuten Ruhepause vor, bei mehr '
                'als 9 Stunden mindestens 45 Minuten. Länger als 6 Stunden '
                'ohne Pause zu arbeiten, ist ausdrücklich untersagt.',
          ),
          ParagraphBlock(
            'Die Pause darf aufgeteilt werden, aber jeder Teil muss '
            'mindestens 15 Minuten dauern — zweimal 15 Minuten ergeben '
            'also die 30er-Pause, dreimal 15 Minuten die 45er. Fünf Minuten '
            'zwischendurch zählen nicht. Wichtig ist außerdem: Die Pause '
            'muss vor Ablauf von sechs Stunden Arbeit begonnen haben, nicht '
            'erst am Ende der Schicht.',
          ),
          ParagraphBlock(
            'Warum sie erfasst werden muss: Deine Pause ist keine bezahlte '
            'Arbeitszeit, und der Betrieb muss nachweisen können, dass du '
            'sie tatsächlich gemacht hast. Deshalb wird sie in der '
            'Zeiterfassung eingetragen — nicht aus Misstrauen, sondern '
            'weil eine nicht dokumentierte Pause bei einer Prüfung als '
            'nicht genommene Pause gilt. Das ist ein Verstoß, für den der '
            'Betrieb haftet. Der Trainer zeigt dir, wo genau du sie '
            'einträgst.',
          ),
          SubheadBlock('Automatische Verriegelung und der Schlüssel'),
          ParagraphBlock(
            'Viele Sprinter verriegeln automatisch: Fällt die Tür ins '
            'Schloss oder rollt das Fahrzeug an, schließt die '
            'Zentralverriegelung von selbst. Das ist ein Diebstahlschutz '
            'für deine Ladung — und es ist genau der Grund, warum der '
            'Schlüssel immer am Mann bleibt.',
          ),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Der Schlüssel gehört an deinen Körper',
            text: 'Nicht auf den Sitz, nicht in die Ablage, nicht in die '
                'Jackentasche, die im Fahrzeug liegt. Schlüssel in die '
                'Hosentasche oder an das Band an deinem Gürtel — jedes '
                'Mal, wenn du aussteigst.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Du hältst kurz, lässt den Schlüssel im '
                'Zündschloss stecken, nimmst zwei Pakete und schließt die '
                'Schiebetür mit dem Fuß. Die Zentralverriegelung schließt. '
                'Was passiert jetzt?',
            answer: 'Du stehst mit zwei Paketen vor einem verschlossenen '
                'Transporter, in dem dein Schlüssel, dein Handy, die '
                'restliche Ladung und meist auch deine Papiere liegen. Der '
                'Tag ist damit gelaufen: Du brauchst Hilfe von der Station '
                'oder einen Schlüsseldienst, deine gesamte Route steht, '
                'und die Pakete im Fahrzeug erreichen ihre Kunden heute '
                'nicht mehr. Der naheliegende Irrtum ist „ich bin doch nur '
                'zehn Sekunden weg" — die automatische Verriegelung '
                'unterscheidet nicht zwischen zehn Sekunden und zehn '
                'Minuten. Deshalb gilt ausnahmslos: Schlüssel raus, '
                'Schlüssel an den Körper, dann erst aussteigen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tourende: Flex schließen und Inspektion',
        blocks: [
          ParagraphBlock(
            'Der Tag endet nicht am letzten Stopp, sondern an der Station. '
            'Zwei Dinge stehen dort auf der Checkliste des Trainers — und '
            'beide werden gerne vergessen, weil man müde ist und nach '
            'Hause will.',
          ),
          StepsBlock([
            'Flex-App ordentlich schließen: Route abschließen, Retouren '
                'abgeben und die App beenden — nicht einfach das Handy '
                'wegstecken.',
            'Fahrzeuginspektion nach der Fahrt: derselbe Rundgang wie '
                'morgens, jetzt mit dem Blick auf neue Schäden, '
                'Kilometerstand und Tank- bzw. Ladezustand.',
            'Fahrzeug sauber und leer übergeben, Laderaum kontrollieren — '
                'kein Paket bleibt drin.',
            'In der Zeiterfassung deines Betriebs (z. B. Kenjo) '
                'ausstempeln und den Schlüssel dort abgeben, wo er '
                'hingehört.',
          ]),
          ParagraphBlock(
            'Die Abschlussinspektion ist das Gegenstück zur Inspektion am '
            'Morgen. Erst durch beide zusammen ist klar, was an diesem Tag '
            'am Fahrzeug passiert ist — und was nicht. Fehlt die abends, '
            'lässt sich ein Schaden am nächsten Morgen niemandem mehr '
            'zuordnen, und der nächste Fahrer übernimmt dein Problem oder '
            'du seines.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Merksatz für den Feierabend',
            text: 'Flex zu, Runde ums Fahrzeug, Laderaum leer, ausgestempelt, '
                'Schlüssel abgegeben. Erst dann ist Feierabend.',
          ),
          ChecklistBlock(
            title: 'Das nehme ich aus Tag 1 mit',
            items: [
              'Die von meinem Betrieb vorgegebene Zahl Stopps über meinen '
                  'eigenen Account',
              'Ich kenne die CoDriver-App und weiß, was ich darin finde',
              'Ich kenne meinen Schichtbeginn, die Parkregelung meiner '
                  'Station und mein Waiting-Area-Fenster',
              'Ich starte die Zeiterfassung (z. B. Kenjo), Mentor und Flex '
                  'rechtzeitig und in dieser Reihenfolge',
              'Ich weiß, dass Mentor rund 4 Stunden aufzeichnet und danach '
                  'neu gestartet werden muss',
              'Ich mache die Fahrzeuginspektion vor und nach der Tour',
              'Ich belade den Rollwagen in Routenreihenfolge, schwer nach '
                  'unten, Ladung gesichert',
              'Ich kenne die Pausenregel nach § 4 ArbZG: 30 Minuten ab mehr '
                  'als 6 Stunden, 45 Minuten ab mehr als 9 Stunden — und '
                  'ich trage sie ein',
              'Der Schlüssel bleibt immer am Körper, weil der Sprinter '
                  'automatisch verriegelt',
              'Am Ende schließe ich Flex, mache die Inspektion und stemple '
                  'aus',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ra3',
    title: 'Der zweite Tag',
    summary: 'Deutlich mehr Stopps selbstständig, Scorecard, '
        'Fahrzeugschutz, Green Book, Sonderpakete, Tanken und Laden',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Deutlich mehr Stopps — du fährst, du stellst zu',
        blocks: [
          ParagraphBlock(
            'Am zweiten Tag dreht sich das Verhältnis um. Die Stoppzahl '
            'steigt deutlich — in vielen Betrieben auf rund 70, verbindlich '
            'ist die Vorgabe deiner Station — und du führst die Stopps '
            'selbstständig durch: Du fährst, du navigierst, du scannst, du '
            'stellst zu, du dokumentierst. Der Trainer sitzt daneben und '
            'greift nur ein, wenn es nötig ist.',
          ),
          FactsBlock([
            FactItem('mehr', 'Stopps als an Tag 1 — Zahl nach Vorgabe des '
                'Betriebs'),
            FactItem('selbst', 'Fahren und Zustellen — der Trainer '
                'begleitet nur'),
            FactItem('1 Tag', 'bis zur ersten eigenen Tour'),
          ]),
          ParagraphBlock(
            'Das ist der eigentliche Sinn des zweiten Tages: Du sollst '
            'einmal erlebt haben, wie sich eine volle Tour anfühlt — mit '
            'dem Tempo, dem Sortieren zwischendurch, den Kunden, die nicht '
            'öffnen, und dem Gefühl, dass die Uhr läuft. Wenn du das '
            'einmal mit jemandem neben dir gemacht hast, ist der erste '
            'Alleingang nur noch halb so groß.',
          ),
          BulletsBlock([
            'Lass dir nichts abnehmen, was du selbst machen kannst — auch '
                'wenn es langsamer geht',
            'Frag nach jedem Stopp, der dir komisch vorkam, sofort nach',
            'Merke dir, was du dir aufschreiben musst: Codes, Abläufe, '
                'Ansprechpartner',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Der Maßstab von Tag 2',
            text: 'Nicht „schafft er die Tour in Rekordzeit", sondern '
                '„könnte man ihn morgen allein losschicken". Genau das '
                'schätzt der Trainer ein.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Scorecard, Qualität und Leistung',
        blocks: [
          ParagraphBlock(
            'Deine Arbeit wird gemessen. Die Scorecard von Amazon fasst '
            'Woche für Woche zusammen, wie du und dein Betrieb gefahren '
            'sind. Am zweiten Tag erklärt dir der Trainer, welche Werte '
            'darin stehen und wie du sie beeinflusst — denn fast jeder '
            'Wert entsteht aus etwas, das du selbst in der Hand hast.',
          ),
          BulletsBlock([
            'Zustellqualität: Wurde das Paket an der richtigen Stelle '
                'übergeben oder abgelegt und sauber dokumentiert?',
            'Fahrverhalten aus Mentor: Bremsen, Beschleunigen, Kurven, '
                'Handynutzung, Anschnallen',
            'Zuverlässigkeit: pünktlicher Start, vollständig gefahrene '
                'Route, korrekte Rückgabe',
            'Kundenrückmeldungen: Beschwerden und Lob landen ebenfalls in '
                'der Auswertung',
          ]),
          ParagraphBlock(
            'Qualität und Leistung sind dabei zwei verschiedene Dinge, die '
            'oft verwechselt werden. Leistung ist die Menge: wie viele '
            'Stopps in welcher Zeit. Qualität ist, wie sauber jeder '
            'einzelne Stopp abgeschlossen wurde. Ein Fahrer mit hoher '
            'Leistung und schlechter Qualität verursacht mehr Arbeit, als '
            'er einspart — jede Reklamation kostet den Betrieb ein '
            'Vielfaches der Minute, die vorne gespart wurde.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der teuerste Fehler ist der schnelle Fehler',
            text: 'Ein Paket an den falschen Ort gelegt und schnell '
                'weiterfahren spart dir eine Minute und kostet den Betrieb '
                'eine Reklamation, eine Nachforschung und im Zweifel den '
                'Warenwert.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Der Kunde öffnet nicht, du hast noch 30 '
                'Stopps vor dir. Du legst das Paket hinter die Mülltonne '
                'und machst schnell ein Foto von der Haustür. Warum ist '
                'das ein Problem?',
            answer: 'Gleich doppelt. Erstens stimmt der Ablageort nicht mit '
                'dem überein, was du dokumentiert hast — findet der Kunde '
                'das Paket nicht, steht deine Zustellung als unbelegt da. '
                'Zweitens ist die Ablage hinter einer Mülltonne kein '
                'geeigneter Ort: Sie ist von der Straße einsehbar und wird '
                'geleert. Richtig ist, den vorgesehenen Weg zu gehen — '
                'Nachbar, sicherer Ablageort mit Kundenfreigabe oder '
                'Rückführung — und exakt das zu dokumentieren, was du '
                'wirklich getan hast. Die eine gesparte Minute steht gegen '
                'eine Reklamation, die dich, den Kunden und den Betrieb '
                'jeweils deutlich mehr kostet.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Fahrzeugschutz, Unfälle, Reinigung und Pflege',
        blocks: [
          ParagraphBlock(
            'Der Transporter ist dein Arbeitsplatz und das teuerste '
            'Werkzeug, das dir der Betrieb anvertraut. Wie du damit '
            'umgehst, ist am zweiten Tag ein eigener Punkt auf der '
            'Checkliste — in drei Teilen.',
          ),
          SubheadBlock('1 — Schäden vermeiden'),
          BulletsBlock([
            'Rückwärtsfahren nur, wenn es nicht anders geht — und dann '
                'langsam, mit Blick über beide Spiegel',
            'Bei unklarer Situation aussteigen und schauen, statt zu raten',
            'Enge Einfahrten, tiefe Äste, Tiefgaragen und Poller sind die '
                'häufigsten Schadensquellen',
            'Abstand halten und vorausschauend bremsen — das schont '
                'Fahrzeug und Scorecard gleichzeitig',
          ]),
          SubheadBlock('2 — Wenn doch etwas passiert'),
          StepsBlock([
            'Anhalten, absichern: Warnblinker, Warnweste, Warndreieck.',
            'Verletzte versorgen, bei Personenschaden immer 112 rufen.',
            'Nichts verändern, Fotos machen: Gesamtsituation, Schäden, '
                'Kennzeichen, Umfeld.',
            'Bei fremdem Fahrzeug oder unklarer Schuld die Polizei '
                'hinzuziehen — auch bei kleinen Schäden.',
            'Sofort deinen zuständigen Dispatcher informieren und den '
                'Vorfall in CoDriver melden.',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Niemals weiterfahren',
            text: 'Auch ein kleiner Kratzer an einem fremden Fahrzeug ist '
                'ohne Meldung Unfallflucht — eine Straftat. Ein Zettel '
                'hinter dem Scheibenwischer reicht rechtlich nicht aus.',
          ),
          SubheadBlock('3 — Reinigung und Pflege'),
          BulletsBlock([
            'Fahrerhaus täglich leer räumen: kein Müll, keine Flaschen, '
                'keine Papiere',
            'Laderaum ausfegen und auf vergessene Pakete prüfen',
            'Scheiben und Spiegel sauber halten — schlechte Sicht ist ein '
                'Sicherheitsproblem, kein Schönheitsfehler',
            'Betriebsstoffe und auffällige Geräusche melden, nicht '
                'ignorieren',
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Beim Rangieren streifst du einen Poller. '
                'Am Fahrzeug ist ein Kratzer, sonst nichts, niemand hat es '
                'gesehen. Meldest du das?',
            answer: 'Ja, immer und noch am selben Tag. Es geht nicht um '
                'Schuld, sondern um Zuordnung: Ein gemeldeter Kratzer ist '
                'ein Vorfall, der bearbeitet wird. Derselbe Kratzer, den '
                'am nächsten Morgen ein anderer Fahrer bei seiner '
                'Inspektion findet, ist ein ungeklärter Schaden — und das '
                'wird für alle Beteiligten unangenehm, auch für dich, weil '
                'sich der Verdacht am Ende doch auf den letzten Nutzer '
                'richtet. Der naheliegende Irrtum ist „das fällt nicht '
                'auf". Es fällt bei der nächsten Inspektion auf, dafür ist '
                'sie da.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Green Book / Kontrollbuch',
        blocks: [
          ParagraphBlock(
            'Das Green Book ist dein Fahrtenkontrollbuch: die '
            'Tageskontrollblätter nach § 1 Abs. 6 Fahrpersonalverordnung '
            '(FPersV), mit denen du deine Lenkzeiten, '
            'Fahrtunterbrechungen und Ruhezeiten nachweist. Auch das ist '
            'keine Regel deiner Station, sondern geltendes '
            'Fahrpersonalrecht — es gilt in jedem Betrieb gleich. Es ist '
            'ausdrücklich keine Fahrzeugprüfung: Im Green Book geht es '
            'ausschließlich um Zeiten, deine Zeiten.',
          ),
          BulletsBlock([
            'Ein Blatt pro Arbeitstag, handschriftlich geführt und '
                'unterschrieben',
            'Eingetragen werden Beginn und Ende der Fahrt, Kilometerstände, '
                'Lenkzeiten, Unterbrechungen und Ruhezeiten',
            'Sofort ausfüllen, nicht abends aus dem Gedächtnis '
                'rekonstruieren',
            'Die Aufzeichnungen der letzten Tage werden mitgeführt und '
                'sind bei einer Kontrolle vorzulegen',
          ]),
          ParagraphBlock(
            'Der Trainer zeigt dir am zweiten Tag, wo das Blatt liegt, wie '
            'es ausgefüllt wird und wo die fertigen Blätter abgegeben '
            'werden. Alles Weitere steht nicht hier: In der DA Academy '
            'gibt es dafür die eigene Schulung „Green Book" — mit den '
            'Pflichtangaben, den Lenk- und Ruhezeiten, der Mitführpflicht '
            'und den Folgen bei Verstößen. Arbeite sie durch, statt dir '
            'die Details am zweiten Tag im Fahrzeug merken zu wollen.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Aufzeichnung selbst ist die Pflicht',
            text: 'Ob du dich an die Zeiten gehalten hast, kann bei einer '
                'Kontrolle niemand feststellen, wenn nichts vorliegt. Ein '
                'fehlendes Blatt ist deshalb genauso ein Verstoß wie eine '
                'überschrittene Lenkzeit.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sonderfälle: Passwort-Pakete und ATLAS-Pakete',
        blocks: [
          SubheadBlock('Passwort-Pakete'),
          ParagraphBlock(
            'Manche Sendungen dürfen nur gegen ein Passwort oder einen '
            'Code übergeben werden, den der Kunde vorher erhalten hat. '
            'Typisch sind hochwertige Waren und alles, was besonders '
            'diebstahlgefährdet ist. Flex weist dich am Stopp darauf hin.',
          ),
          BulletsBlock([
            'Der Kunde nennt oder zeigt dir den Code — du liest ihn nicht '
                'vor und nennst ihn nicht zuerst',
            'Ohne korrekten Code keine Übergabe: keine Ausnahme, auch nicht '
                'beim Nachbarn',
            'Keine Ablage an der Tür und kein Abstellen im Hausflur',
            'Stimmt der Code nicht, wird die Sendung nach dem vorgesehenen '
                'Weg zurückgeführt und dokumentiert',
          ]),
          SubheadBlock('ATLAS-Pakete'),
          ParagraphBlock(
            'ATLAS-Sendungen sind ebenfalls besonders behandelte Pakete: '
            'Sie folgen einem eigenen Prozess mit zusätzlichen Schritten '
            'im Scan- und Übergabeablauf. Wichtig ist für dich, dass du '
            'sie erkennst, sie getrennt und griffbereit lagerst und den '
            'vorgegebenen Ablauf nicht abkürzt. Wie der Prozess in deiner '
            'Station konkret aussieht und welche Schritte Flex dir dabei '
            'vorgibt, zeigt dir der Trainer am zweiten Tag am realen '
            'Paket.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Sonderpakete zuerst einsortieren',
            text: 'Beide Paketarten willst du nicht am Stopp unter 90 '
                'anderen Sendungen suchen. Leg sie beim Beladen bewusst '
                'getrennt und merke dir ihre Position.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Der Kunde ist da, hat aber sein Passwort '
                'nicht zur Hand — „das ist doch nur Formsache, ich '
                'unterschreibe Ihnen alles". Was tust du?',
            answer: 'Du übergibst nicht. Das Passwort ist der Nachweis, '
                'dass der Empfänger wirklich der Empfänger ist — genau '
                'deshalb wurde es vergeben. Eine Unterschrift, ein '
                'Ausweis, den du nicht prüfen darfst, oder gutes Zureden '
                'ersetzen es nicht. Der naheliegende Irrtum ist, '
                'Freundlichkeit über den Prozess zu stellen: Wird die '
                'Sendung später als nicht erhalten gemeldet, steht die '
                'Übergabe ohne Code als Fehler in deinem Namen. Bitte den '
                'Kunden, den Code in seiner Bestellbestätigung '
                'nachzusehen. Findet er ihn nicht, nimmst du das Paket '
                'wieder mit und dokumentierst es korrekt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Tanken, Laden und Tourende',
        blocks: [
          SubheadBlock('Tanken'),
          ParagraphBlock(
            'Der Transporter wird nach den Regeln des Betriebs betankt: an '
            'den vorgesehenen Stationen, mit der Tankkarte des Fahrzeugs '
            'und mit dem richtigen Kraftstoff. Der Beleg gehört zum '
            'Fahrzeug oder wird dort abgegeben, wo der Trainer es dir '
            'zeigt. Wann du tankst, hängt an einer einfachen Regel: nicht '
            'erst, wenn die Reserveleuchte kommt, sondern so, dass der '
            'nächste Fahrer nicht mit fast leerem Tank starten muss.',
          ),
          BulletsBlock([
            'Richtige Kraftstoffsorte — eine Fehlbetankung legt das '
                'Fahrzeug tagelang still',
            'Tankkarte gehört zum Fahrzeug, nicht in deine private Tasche',
            'Beleg aufbewahren und wie vorgegeben abgeben',
            'Motor aus, nicht rauchen, Handy weg an der Zapfsäule',
          ]),
          SubheadBlock('Elektrisches Laden'),
          ParagraphBlock(
            'Bei einem Elektrofahrzeug tritt das Laden an die Stelle des '
            'Tankens — mit einem wichtigen Unterschied: Laden dauert '
            'länger und muss deshalb geplant werden. Der Trainer zeigt '
            'dir, wo geladen wird, welches Kabel zum Fahrzeug gehört und '
            'welchen Ladestand das Fahrzeug am Ende der Schicht haben '
            'soll.',
          ),
          BulletsBlock([
            'Ladestand im Blick behalten und rechtzeitig planen, nicht '
                'erst bei Restreichweite reagieren',
            'Nach dem Anstecken prüfen, ob der Ladevorgang wirklich '
                'gestartet ist',
            'Kabel sauber aufwickeln und keine Stolperstellen '
                'hinterlassen',
            'Am Ende der Schicht das Fahrzeug so übergeben, wie es der '
                'Betrieb vorgibt — der nächste Fahrer startet damit',
          ]),
          SubheadBlock('Tourende — wie an Tag 1'),
          StepsBlock([
            'Flex-App ordentlich schließen, Route abschließen, Retouren '
                'abgeben.',
            'Fahrzeuginspektion nach der Fahrt: Rundgang, neue Schäden, '
                'Kilometerstand, Tank- bzw. Ladestand.',
            'Laderaum leer und sauber, Fahrerhaus aufgeräumt.',
            'Ausstempeln, Schlüssel abgeben, Green Book vervollständigen.',
          ]),
          ChecklistBlock(
            title: 'Das nehme ich aus Tag 2 mit',
            items: [
              'Die von meinem Betrieb vorgegebene, deutlich höhere Zahl '
                  'Stopps — die ich selbst fahre und zustelle',
              'Ich weiß, was in der Scorecard steht und wie ich sie '
                  'beeinflusse',
              'Qualität ist nicht dasselbe wie Leistung — beides zählt',
              'Ich vermeide Schäden aktiv und melde jeden Vorfall sofort',
              'Ich halte das Fahrzeug innen und außen sauber',
              'Ich kenne das Green Book nach § 1 Abs. 6 FPersV und mache '
                  'dazu die eigene Schulung in der DA Academy',
              'Passwort-Pakete gebe ich nur gegen den korrekten Code heraus',
              'ATLAS-Pakete erkenne ich und folge dem vorgegebenen Prozess',
              'Ich kenne die Regeln für Tanken und für elektrisches Laden',
              'Am Ende: Flex schließen, Inspektion, ausstempeln',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ra4',
    title: 'Abschluss und Abgabe',
    summary: 'Feedback des Trainers, Unterschriften je Tag und die Abgabe '
        'des Blattes als Foto',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Das Feedback des Trainers',
        blocks: [
          ParagraphBlock(
            'Nach dem zweiten Tag setzt sich der Trainer mit dir zusammen '
            'und gibt ein Feedback zu deiner Leistung und deinen '
            'Fahrfähigkeiten. Das ist kein Urteil in zwei Worten, sondern '
            'eine Einschätzung: Was läuft schon rund, woran musst du '
            'arbeiten, worauf sollst du in den nächsten Wochen besonders '
            'achten.',
          ),
          BulletsBlock([
            'Fahrverhalten: Ruhe, Vorausschau, Rückwärtsfahren, Umgang mit '
                'engen Stellen',
            'Zustellung: Sorgfalt, Dokumentation, Umgang mit Kunden',
            'Organisation: Sortieren, Zeitgefühl, Umgang mit den Apps',
            'Arbeitshaltung: Pünktlichkeit, Nachfragen, Umgang mit '
                'Hinweisen',
          ]),
          ParagraphBlock(
            'Nimm das Feedback ernst, aber nicht persönlich. Es ist die '
            'einzige Gelegenheit, in der dir jemand zwei volle Tage lang '
            'zugesehen hat. Frag nach, wenn dir ein Punkt unklar ist, und '
            'frag konkret: „Was genau soll ich beim Rückwärtsfahren anders '
            'machen?" bringt dir mehr als ein Nicken.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Die eine Frage zum Schluss',
            text: 'Frag deinen Trainer am Ende: „Was ist die eine Sache, '
                'auf die ich in meiner ersten Woche allein besonders '
                'achten soll?" Die Antwort ist das Wertvollste aus zwei '
                'Tagen.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Im Feedback heißt es, du seist zu '
                'zögerlich beim Rangieren und verlierst dadurch Zeit. Du '
                'findest, du warst einfach vorsichtig. Wie gehst du damit '
                'um?',
            answer: 'Nachfragen statt rechtfertigen. Vorsicht beim '
                'Rangieren ist richtig — der Trainer meint mit „zögerlich" '
                'in aller Regel etwas anderes: dass du lange überlegst, '
                'statt auszusteigen und kurz zu schauen, oder dass du '
                'mehrfach ansetzt, wo einmal Zurücksetzen mit Blick über '
                'beide Spiegel gereicht hätte. Bitte um ein konkretes '
                'Beispiel aus dem Tag. Dann hast du einen Punkt, an dem du '
                'wirklich arbeiten kannst, statt einer Bewertung, die du '
                'nur abnickst oder abwehrst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Das Blatt: Datum, Namen, Unterschriften',
        blocks: [
          ParagraphBlock(
            'Die Ride-Along-Checkliste ist erst vollständig, wenn die '
            'Kopfdaten stimmen. Ohne sie ist das Blatt ein Zettel mit '
            'Häkchen und keinem Nachweis zuzuordnen.',
          ),
          TableBlock(
            headers: ['Angabe', 'Was gemeint ist'],
            rows: [
              ['Datum', 'Für jeden der beiden Tage getrennt eingetragen'],
              ['Name des Schülers', 'Dein Name — der neue Fahrer'],
              ['Name des Lehrers', 'Der Name deines Trainers'],
              [
                'Unterschrift',
                'Vom Trainer, je Tag einzeln — nicht einmal für beide Tage',
              ],
            ],
          ),
          ParagraphBlock(
            'Dass je Tag unterschrieben wird, hat einen Grund: Jeder Tag '
            'hat seine eigene Liste von Punkten. Fällt der zweite Tag aus '
            'oder wird er verschoben, ist trotzdem sauber dokumentiert, '
            'was am ersten Tag erledigt wurde. Prüfe deshalb am Ende jedes '
            'Tages selbst, ob Datum und Unterschrift eingetragen sind.',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Selbst hinschauen',
            text: 'Das Blatt ist der Nachweis deiner Einarbeitung. Fehlt '
                'eine Unterschrift, fehlt der Nachweis — und nachträglich '
                'ist so etwas immer mühsam. Ein Blick vor dem Feierabend '
                'reicht.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Abgabe: Foto beim Dispatcher',
        blocks: [
          ParagraphBlock(
            'Am Ende des zweiten Tages wird das ausgefüllte Blatt als Foto '
            'bei deinem zuständigen Dispatcher abgegeben. Damit ist der '
            'Ride Along formal abgeschlossen und deine Einarbeitung '
            'dokumentiert.',
          ),
          StepsBlock([
            'Blatt auf eine ebene Fläche legen, gutes Licht suchen.',
            'Von oben fotografieren, das ganze Blatt im Bild, ohne '
                'Schatten und ohne abgeschnittene Ränder.',
            'Prüfen, ob Häkchen, Datum, Namen und Unterschriften lesbar '
                'sind.',
            'Foto beim zuständigen Dispatcher abgeben — auf dem Weg, den '
                'euch der Trainer nennt.',
            'Das Papierblatt so behandeln, wie es dein Betrieb vorgibt: '
                'Es kann verlangt werden.',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Unlesbar ist wie nicht abgegeben',
            text: 'Ein verwackeltes oder halb abgeschnittenes Foto muss '
                'neu gemacht werden — und dann seid ihr beide vielleicht '
                'schon zu Hause. Schau es dir einmal an, bevor du es '
                'wegschickst.',
          ),
          ChecklistBlock(
            title: 'Das nehme ich aus dem Abschluss mit',
            items: [
              'Nach Tag 2 gibt der Trainer ein Feedback zu Leistung und '
                  'Fahrfähigkeiten',
              'Ich frage bei unklaren Punkten konkret nach',
              'Auf dem Blatt stehen Datum, Name des Schülers und Name des '
                  'Lehrers',
              'Der Trainer unterschreibt je Tag einzeln',
              'Ich prüfe am Ende jedes Tages selbst, ob alles eingetragen '
                  'ist',
              'Das Blatt wird am Ende von Tag 2 als lesbares Foto beim '
                  'zuständigen Dispatcher abgegeben',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ra5',
    title: 'So bereitest du dich vor',
    summary: 'Was du VOR Tag 1 klären solltest — Zugänge, Ausrüstung, '
        'Zeitplanung und deine Fragen',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Vorher klären: Zugänge und Technik',
        blocks: [
          ParagraphBlock(
            'Der häufigste Grund, warum ein erster Tag schlecht anläuft, '
            'ist kein fehlendes Wissen, sondern ein nicht funktionierender '
            'Zugang. Kläre das vorher — dann beginnt dein Ride Along mit '
            'dem, worum es geht.',
          ),
          BulletsBlock([
            'Dein eigener Account für die Zustellung: Zugangsdaten '
                'vorhanden und einmal erfolgreich angemeldet',
            'Zeiterfassung deines Betriebs (z. B. Kenjo): Zugang '
                'eingerichtet, du weißt, wie du ein- und ausstempelst',
            'Mentor und Flex: Apps installiert, Anmeldung getestet, '
                'Berechtigungen für Standort und Bewegung erteilt',
            'CoDriver: angemeldet, Benachrichtigungen erlaubt',
            'Handy: geladen, ausreichend Speicher, Ladekabel oder Powerbank '
                'für den Transporter dabei',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Am Vorabend prüfen, nicht am Morgen',
            text: 'Ein Passwort zurückzusetzen dauert um 20 Uhr fünf '
                'Minuten und um 6 Uhr in der Waiting Area eine halbe '
                'Stunde — wenn überhaupt jemand erreichbar ist.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Am Morgen des ersten Tages lässt sich '
                'deine Zustell-App nicht anmelden. Der Trainer wartet, die '
                'Welle läuft an. Was ist die beste Reaktion?',
            answer: 'Sofort sagen, dass der Zugang nicht funktioniert — '
                'und zwar dem Trainer, damit er deinen zuständigen '
                'Dispatcher einschalten kann. Der naheliegende Irrtum ist, '
                'still weiterzuprobieren, um nicht unfähig zu wirken. Das '
                'kostet die Minuten, in denen das Problem noch lösbar '
                'wäre, und am Ende fährst du den ganzen Tag über den '
                'Account des Trainers mit — womit die Mindestzahl an '
                'Stopps über deinen eigenen Account nicht erfüllt ist und '
                'der Tag im schlimmsten Fall wiederholt werden muss. '
                'Deshalb: früh melden, klar sagen, was du schon probiert '
                'hast.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kleidung, Ausrüstung und Pünktlichkeit',
        blocks: [
          SubheadBlock('Was du anziehst'),
          BulletsBlock([
            'Sicherheitsschuhe: fester, geschlossener Arbeitsschuh — keine '
                'Sneaker, keine Sandalen',
            'Wetterfeste Kleidung: Du bist den ganzen Tag draußen, auch '
                'wenn es morgens noch trocken aussieht',
            'Bewegungsfreiheit: Du steigst hunderte Male ein und aus',
            'Warnweste griffbereit — sie liegt im Fahrzeug, gehört aber in '
                'deinen Kopf',
          ]),
          SubheadBlock('Was du dabei hast'),
          BulletsBlock([
            'Führerschein — ohne ihn fährst du nicht, auch nicht am ersten '
                'Tag',
            'Ausweis oder Aufenthaltsdokument, falls der Betrieb es '
                'verlangt',
            'Getränk und etwas zu essen für die Pause',
            'Stift und ein kleines Notizbuch oder Notizen-App',
          ]),
          SubheadBlock('Pünktlichkeit'),
          ParagraphBlock(
            'Pünktlich heißt: einsatzbereit an der Station zum '
            'Schichtbeginn, nicht ankommend am Tor. Rechne die Zeit für '
            'Parken, Weg über den Hof und Waiting Area dazu. Wer am ersten '
            'Tag zu spät kommt, verschiebt die Welle des Trainers mit — '
            'und das bleibt hängen.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Faustregel für die ersten Tage',
            text: 'Plane den Weg so, dass du eher zu früh da bist. Die '
                'gewonnene Viertelstunde nutzt du, um dich umzusehen — '
                'Toiletten, Waiting Area, Aufstellplätze.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Deine Fragen — und die Checkliste vorher',
        blocks: [
          ParagraphBlock(
            'Du hast zwei Tage lang jemanden neben dir, der alles weiß, '
            'was du wissen musst. Das ist eine Situation, die so nicht '
            'wiederkommt. Der Fehler, den fast alle machen: Sie merken '
            'sich ihre Fragen nicht und fallen ihnen erst in Woche zwei '
            'wieder ein, allein im Transporter.',
          ),
          BulletsBlock([
            'Schreib schon vor Tag 1 auf, was du wissen willst — auch '
                'Kleinigkeiten',
            'Notiere während der Tour die Antworten, verlass dich nicht '
                'aufs Gedächtnis',
            'Fotografiere nichts von Kundendaten, aber notiere Abläufe und '
                'Ansprechpartner',
            'Frag am Ende jedes Tages: „Was habe ich heute noch nicht '
                'gesehen?"',
          ]),
          ParagraphBlock(
            'Gute Fragen für den Ride Along sind zum Beispiel: Wann genau '
            'ist mein Waiting-Area-Fenster? Wo parke ich privat? Wie '
            'erkenne ich, ob Mentor noch läuft? Wo trage ich meine Pause '
            'ein? Wem melde ich einen Schaden zuerst? Wo gebe ich das '
            'Green Book ab? Was mache ich, wenn ein Kunde bei einem '
            'Passwort-Paket den Code nicht hat?',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Warum du diese Schulung gemacht hast',
            text: 'Nicht damit du am Ride Along alles schon kannst, '
                'sondern damit du die Begriffe kennst. Wer weiß, was '
                'gemeint ist, kann zuhören — wer alles zum ersten Mal '
                'hört, kann nur nicken.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Der Trainer erklärt am Vormittag zehn '
                'Dinge hintereinander. Am Abend erinnerst du dich an drei '
                'davon. Woran lag es — an dir?',
            answer: 'An der Methode, nicht an dir. Zehn neue Abläufe '
                'nacheinander erklärt bekommen und behalten funktioniert '
                'bei niemandem. Was funktioniert: die Begriffe vorher '
                'einmal gelesen haben — genau dafür ist diese Schulung da '
                '— und unterwegs mitschreiben. Zwei Stichworte pro Thema '
                'reichen, um am Abend den ganzen Ablauf wieder aufzurufen. '
                'Und was am zweiten Tag noch fehlt, fragst du gezielt '
                'nach, statt zu hoffen, dass es von selbst wiederkommt.',
          ),
          ChecklistBlock(
            title: 'Vor Tag 1 — zum Selbst-Abhaken',
            items: [
              'Zugangsdaten für meinen eigenen Zustell-Account getestet',
              'Zeiterfassung (z. B. Kenjo), Mentor, Flex und CoDriver '
                  'installiert und angemeldet',
              'Handy geladen, Ladekabel oder Powerbank eingepackt',
              'Sicherheitsschuhe und wetterfeste Kleidung bereitgelegt',
              'Führerschein und benötigte Dokumente eingesteckt',
              'Getränk und Essen für die Pause vorbereitet',
              'Stift und Notizmöglichkeit dabei',
              'Anfahrt geplant — inklusive Parken und Weg zur Waiting Area',
              'Meine Fragen an den Trainer aufgeschrieben',
              'Diese Schulung durchgearbeitet, damit ich die Begriffe kenne',
            ],
          ),
        ],
      ),
    ],
  ),
];
