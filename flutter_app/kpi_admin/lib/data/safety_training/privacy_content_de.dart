// lib/data/safety_training/privacy_content_de.dart
//
// Inhalte der Datenschutz-Schulung — deutsche Fassung.
//
// Rechtlicher Hintergrund: Die DSGVO kennt keine ausdrückliche
// „Schulungspflicht", verlangt sie aber mittelbar — Art. 32 DSGVO
// (organisatorische Maßnahmen zur Sicherheit der Verarbeitung),
// Art. 39 Abs. 1 lit. b DSGVO (Sensibilisierung und Schulung durch den
// Datenschutzbeauftragten) und Art. 5 Abs. 2 DSGVO (Rechenschaftspflicht).
// Aufsichtsbehörden werten fehlende Mitarbeiterschulungen regelmäßig als
// Indiz für unzureichende Maßnahmen, besonders nach einer Datenpanne.
// Bewährt ist eine jährliche Grundschulung plus Anlassschulungen und die
// Einweisung neuer Mitarbeiter. Die Dokumentation der Schulung — Test und
// Unterschrift — dient dem Nachweis nach Art. 5 Abs. 2 DSGVO.
//
// Aufbau wie beim Green Book: je Kapitel mehrere Folien aus typisierten
// Bausteinen — Rechtshinweise (CalloutTone.law), Fallbeispiele zum
// Nachdenken (Reveal), Do/Don't und eine Checkliste am Kapitelende.
// Für dieses Thema gibt es keine Illustrationen, deshalb `asset: ''`.

import 'safety_blocks.dart';

const List<SafetyChapterContent> privacyContentDe = [
  // ══════════════════════════════════════════════════ 1
  SafetyChapterContent(
    id: 'ds1',
    title: 'Warum Datenschutz dich betrifft',
    summary: 'Personenbezogene Daten im Zustellalltag und die Grundsätze '
        'aus Art. 5 DSGVO',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Du arbeitest den ganzen Tag mit fremden Daten',
        blocks: [
          ParagraphBlock(
            'Datenschutz klingt nach Büro, Aktenschrank und Jurist. In '
            'Wirklichkeit ist kaum jemand so nah an personenbezogenen Daten '
            'wie du. Vom ersten Scan am Morgen bis zum letzten Stopp am '
            'Abend hast du fremde Namen, Adressen und Telefonnummern in der '
            'Hand — und dazu Fotos von fremden Haustüren.',
          ),
          ParagraphBlock(
            'Personenbezogen ist jede Angabe, mit der sich eine Person '
            'bestimmen lässt. Nicht nur der Name: auch die Kombination aus '
            'Adresse, Uhrzeit und Paketinhalt sagt etwas über einen '
            'Menschen aus. Genau deshalb gelten dafür Regeln.',
          ),
          BulletsBlock([
            'Empfängernamen und Anschriften auf Etikett, Scanner und Liste',
            'Telefonnummern für die Kontaktaufnahme vor der Zustellung',
            'Unterschriften auf dem Scanner als Empfangsbestätigung',
            'Fotos als Ablieferungsnachweis vor der Tür',
            'Standortdaten des Scanners und des Fahrzeugs',
            'Angaben zu Nachbarn, bei denen du ein Paket abgegeben hast',
            'Hinweise wie „Paket bitte hinter die Mülltonne" — auch das '
                'ist eine Information über die Wohnsituation eines Menschen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Kurz gesagt',
            text: 'Alles, was du über einen Empfänger erfährst, hast du nur '
                'erfahren, weil du das Paket bringst. Für alles andere hast '
                'du diese Information nicht bekommen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Drei Grundsätze, die im Alltag zählen',
        blocks: [
          ParagraphBlock(
            'Art. 5 DSGVO stellt sechs Grundsätze auf. Drei davon '
            'entscheiden praktisch jeden Tag darüber, ob du richtig oder '
            'falsch handelst. In einfacher Sprache:',
          ),
          TableBlock(
            headers: ['Grundsatz', 'Was das für dich heißt'],
            rows: [
              [
                'Zweckbindung',
                'Daten nur für den Zweck nutzen, für den du sie bekommen '
                    'hast: die Zustellung. Nicht für Privates.',
              ],
              [
                'Datenminimierung',
                'Nur so viel erheben und zeigen wie nötig. Kein Foto mehr '
                    'als nötig, keine Liste länger als nötig.',
              ],
              [
                'Vertraulichkeit',
                'Was du siehst, bleibt bei dir und im Betrieb. Nicht in der '
                    'Chatgruppe, nicht am Küchentisch, nicht im Netz.',
              ],
            ],
          ),
          ParagraphBlock(
            'Dazu kommen Richtigkeit (falsche Angaben korrigieren statt '
            'weiterschleppen), Speicherbegrenzung (nichts länger behalten '
            'als nötig) und Rechenschaftspflicht — der letzte Punkt '
            'betrifft das Unternehmen und ist der Grund für diese Schulung.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: 'Art. 5 Abs. 1 DSGVO verlangt unter anderem Zweckbindung '
                '(lit. b), Datenminimierung (lit. c) sowie Integrität und '
                'Vertraulichkeit (lit. f). Diese Grundsätze gelten für '
                'jeden, der im Auftrag des Unternehmens mit '
                'personenbezogenen Daten umgeht — also auch für dich auf '
                'der Tour.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Warum es diese Schulung gibt',
        blocks: [
          ParagraphBlock(
            'Die DSGVO schreibt nirgends wörtlich „Mitarbeiter müssen '
            'geschult werden". Sie verlangt es trotzdem — nur über drei '
            'andere Wege. Deshalb sitzt du hier, und deshalb wird der '
            'Abschluss dokumentiert.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Woraus die Schulungspflicht folgt',
            text: 'Art. 32 DSGVO verpflichtet das Unternehmen zu '
                'technischen und organisatorischen Maßnahmen für die '
                'Sicherheit der Verarbeitung — geschulte Mitarbeiter sind '
                'eine solche Maßnahme. Art. 39 Abs. 1 lit. b DSGVO nennt '
                'Sensibilisierung und Schulung ausdrücklich als Aufgabe des '
                'Datenschutzbeauftragten. Und Art. 5 Abs. 2 DSGVO verlangt, '
                'dass das Unternehmen die Einhaltung nachweisen kann — '
                'Rechenschaftspflicht.',
          ),
          ParagraphBlock(
            'Aufsichtsbehörden schauen bei einer Prüfung genau darauf. '
            'Fehlende Mitarbeiterschulungen werten sie regelmäßig als Indiz '
            'dafür, dass die Maßnahmen unzureichend waren — besonders dann, '
            'wenn bereits etwas passiert ist. Nach einer Datenpanne ist die '
            'erste Frage fast immer: Waren die Leute geschult, und könnt '
            'ihr das belegen?',
          ),
          BulletsBlock([
            'Jährliche Grundschulung für alle — dein Abschluss gilt zwölf '
                'Monate',
            'Anlassschulung, wenn sich etwas ändert oder etwas passiert ist',
            'Einweisung neuer Mitarbeiter vor dem ersten eigenen Tag',
            'Dokumentation von Test und Unterschrift als Nachweis nach '
                'Art. 5 Abs. 2 DSGVO',
          ]),
        ],
      ),
      SafetySlide(
        title: 'Wo die Linie im Alltag verläuft',
        blocks: [
          RevealBlock(
            prompt: 'Fallbeispiel: Auf deiner Tour liegt ein Paket für '
                'einen bekannten Fußballer aus der Region. Am Abend '
                'erzählst du im Freundeskreis, in welcher Straße er wohnt — '
                'nichts weiter, kein Name auf Social Media, nur unter '
                'Freunden. Ist das ein Datenschutzverstoß?',
            answer: 'Ja. Die Adresse ist eine personenbezogene Angabe, und '
                'du kennst sie ausschließlich aus deiner Arbeit. Sie an '
                'Dritte weiterzugeben, verstößt gegen die Zweckbindung '
                '(Art. 5 Abs. 1 lit. b DSGVO) und gegen die '
                'Vertraulichkeit (lit. f). Der naheliegende Irrtum ist, dass '
                'ein privater Kreis „nicht zählt" — die DSGVO fragt nicht, '
                'wie groß dein Publikum war, sondern ob du die Daten '
                'zweckwidrig offengelegt hast. Erzählt einer deiner Freunde '
                'es weiter, hast du zusätzlich keinerlei Kontrolle mehr.',
          ),
          DoDontBlock(
            doTitle: 'Richtig',
            dos: [
              'Empfängerdaten nur für die Zustellung nutzen und danach im '
                  'System lassen',
              'Bei Rückfragen zu einer Sendung an Dispatcher oder '
                  'Betriebsleitung verweisen',
              'Scanner und Papierliste so halten, dass Dritte nicht '
                  'mitlesen können',
              'Unklare Situationen ansprechen statt selbst zu entscheiden',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Adressen oder Namen im privaten Umfeld erzählen — auch nicht '
                  '„nur unter Freunden"',
              'Prominente oder auffällige Sendungen zum Gesprächsthema '
                  'machen',
              'Empfängerdaten aus Neugier nachschlagen, ohne dass ein '
                  'Auftrag dazu besteht',
              'Sich darauf verlassen, dass „das doch niemand erfährt"',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste Kapitel 1',
        blocks: [
          ParagraphBlock(
            'Geh die Punkte kurz durch. Wenn du bei einem Punkt zögerst, '
            'blättere noch einmal zurück — im Test kommen genau diese '
            'Situationen wieder.',
          ),
          ChecklistBlock(
            title: 'Das nehme ich aus Kapitel 1 mit',
            items: [
              'Ich weiß, welche Daten auf meiner Tour personenbezogen sind',
              'Ich kenne Zweckbindung, Datenminimierung und Vertraulichkeit',
              'Ich weiß, dass Empfängerdaten nicht ins Private gehören',
              'Ich weiß, warum diese Schulung dokumentiert wird '
                  '(Art. 5 Abs. 2 DSGVO)',
              'Mir ist klar, dass die Schulung jährlich wiederholt wird',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 2
  SafetyChapterContent(
    id: 'ds2',
    title: 'Fotos und Ablieferungsnachweise',
    summary: 'Was aufs Bild darf, was nicht — und wohin das Foto gehört',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Das Foto hat genau einen Zweck',
        blocks: [
          ParagraphBlock(
            'Das Ablieferungsfoto soll eine einzige Frage beantworten: Wo '
            'liegt das Paket? Nichts anderes. Alles, was darüber '
            'hinausgeht, ist mehr Information als nötig — und damit ein '
            'Verstoß gegen die Datenminimierung.',
          ),
          ParagraphBlock(
            'Praktisch heißt das: Kamera runter auf das Paket, nah genug, '
            'dass man den Ablageort erkennt, und weit genug weg von allem, '
            'was Menschen zeigt oder identifizierbar macht.',
          ),
          DoDontBlock(
            doTitle: 'Darf aufs Bild',
            dos: [
              'Das Paket selbst am Ablageort',
              'Ein Stück Hauswand, Tür oder Treppe als Ortsbezug',
              'Die Hausnummer, wenn sie zur Zuordnung nötig ist',
              'Bei Abstellgenehmigung: der vereinbarte Ablageplatz',
            ],
            dontTitle: 'Darf nicht aufs Bild',
            donts: [
              'Personen — auch nicht der Empfänger, auch nicht von hinten',
              'Kfz-Kennzeichen von parkenden Fahrzeugen',
              'Fenster, Balkone und Blicke in Innenräume',
              'Kinder, Haustiere, Besucher, Nachbarn im Hintergrund',
              'Namensschilder Dritter, wenn sie nicht zur Sendung gehören',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: 'Art. 5 Abs. 1 lit. c DSGVO verlangt Datenminimierung: '
                'Daten müssen dem Zweck angemessen und auf das notwendige '
                'Maß beschränkt sein. Ein Foto, das Personen, Kennzeichen '
                'oder Wohnungsinnenräume zeigt, geht über den Zweck '
                '„Ablieferungsnachweis" hinaus. Zusätzlich greift bei '
                'abgebildeten Personen das Recht am eigenen Bild.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wohin das Foto gehört — und wohin nicht',
        blocks: [
          ParagraphBlock(
            'Genauso wichtig wie der Bildinhalt ist der Speicherort. Das '
            'Foto entsteht in der dienstlichen App und bleibt dort. Es hat '
            'in deiner privaten Galerie nichts verloren und erst recht '
            'nicht in einem Messenger.',
          ),
          BulletsBlock([
            'Foto ausschließlich in der dienstlichen App aufnehmen — nicht '
                'erst mit der Kamera-App und dann hochladen',
            'Keine Kopie in der privaten Galerie, keine Cloud-Sicherung des '
                'privaten Handys',
            'Kein Versand über WhatsApp, Telegram, Signal oder eine '
                'Fahrer-Chatgruppe',
            'Kein Foto „zur Sicherheit" für dich selbst aufheben — der '
                'Nachweis liegt im System',
          ]),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Der häufigste Fehler',
            text: 'Erst mit der normalen Kamera fotografieren und das Bild '
                'dann in die App hochladen. Damit liegt das Foto dauerhaft '
                'in deiner privaten Galerie — oft zusätzlich in einer Cloud '
                'im Ausland. Das ist eine unzulässige Verarbeitung, auch '
                'wenn du es nie jemandem zeigst.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Wenn doch jemand drauf ist',
        blocks: [
          ParagraphBlock(
            'Es passiert: Die Nachbarin tritt genau im Moment des Auslösens '
            'aus der Tür, oder ein Kind läuft durchs Bild. Das ist kein '
            'Drama — solange du sofort handelst.',
          ),
          StepsBlock([
            'Foto sofort löschen, bevor du den Stopp abschließt',
            'Neu fotografieren, diesmal ohne Person im Bild',
            'Wenn das Bild schon hochgeladen ist: Dispatcher oder '
                'Betriebsleitung informieren, damit es im System gelöscht '
                'werden kann',
            'Wenn du unsicher bist, ob jemand erkennbar ist: lieber melden '
                'als hoffen',
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Du stellst ein Paket im Hinterhof ab. '
                'Auf dem Foto sieht man das Paket — und im Hintergrund '
                'durch ein bodentiefes Fenster ein Wohnzimmer mit zwei '
                'Personen auf dem Sofa. Du hast bereits abgeschlossen und '
                'stehst schon im nächsten Hof. Was tust du?',
            answer: 'Du meldest es. Das Bild zeigt einen Innenraum und '
                'identifizierbare Personen — es geht damit weit über den '
                'Zweck „Ablieferungsnachweis" hinaus und muss aus dem '
                'System entfernt werden. Der naheliegende Irrtum ist, dass '
                'sich der Fehler nicht mehr lohnt zu melden, weil der Stopp '
                'schon abgeschlossen ist. Genau umgekehrt: Nur wenn das '
                'Unternehmen davon weiß, kann es das Bild löschen und den '
                'Vorgang dokumentieren. Wer es meldet, macht alles richtig — '
                'wer schweigt, lässt einen Verstoß bestehen.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste Kapitel 2',
        blocks: [
          ChecklistBlock(
            title: 'Vor jedem Ablieferungsfoto',
            items: [
              'Ich fotografiere nur in der dienstlichen App',
              'Auf dem Bild ist keine Person zu sehen',
              'Kein Kennzeichen, kein Fenster, kein Innenraum im Bild',
              'Das Paket und der Ablageort sind eindeutig erkennbar',
              'Kein Bild landet in meiner privaten Galerie oder in einem '
                  'Chat',
              'Wenn versehentlich jemand drauf ist: löschen, neu machen, '
                  'melden',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 3
  SafetyChapterContent(
    id: 'ds3',
    title: 'Umgang mit Empfängerdaten',
    summary: 'Scanner, Telefon und Papierlisten — Dienstmittel, keine '
        'Privatsache',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Scanner und Diensthandy sind keine Privatgeräte',
        blocks: [
          ParagraphBlock(
            'Auf dem Scanner und dem dienstlichen Telefon liegen die Daten '
            'von hunderten Menschen pro Tag. Beide Geräte gehören dem '
            'Betrieb und sind ausschließlich für die Arbeit da — auch in '
            'der Pause und auch, wenn du sie mit nach Hause nimmst.',
          ),
          BulletsBlock([
            'Keine privaten Apps, keine private Anmeldung, keine private '
                'Cloud auf dem Dienstgerät',
            'Das Gerät nicht weitergeben — auch nicht kurz an Kollegen, '
                'Angehörige oder Bekannte',
            'Bildschirmsperre aktiv lassen und das Gerät nie unbeaufsichtigt '
                'liegen lassen',
            'Beim Verlassen des Fahrzeugs: Scanner mitnehmen oder sicher '
                'verstauen, nicht sichtbar auf dem Sitz',
          ]),
          CalloutBlock(
            tone: CalloutTone.danger,
            title: 'Absolutes Verbot',
            text: 'Keine Screenshots von Adresslisten, Tourenübersichten '
                'oder Empfängerdaten. Auch nicht, um sie dir selbst zu '
                'schicken, auch nicht „als Gedächtnisstütze". Ein '
                'Screenshot ist eine Kopie außerhalb des Systems — genau '
                'das, was der Betrieb nicht mehr kontrollieren kann.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Auskunft an Nachbarn und Fremde',
        blocks: [
          ParagraphBlock(
            'An der Tür wirst du gefragt. Das ist normal und meistens '
            'harmlos gemeint. Trotzdem gilt: Du gibst nur so viel preis, '
            'wie für die Zustellung nötig ist — nicht mehr.',
          ),
          TableBlock(
            headers: ['Situation', 'So weit darfst du gehen'],
            rows: [
              [
                'Nachbar nimmt ein Paket an',
                'Name des Empfängers und Hausnummer nennen — mehr braucht '
                    'er nicht.',
              ],
              [
                'Nachbar fragt, was drin ist',
                'Keine Auskunft. Der Inhalt geht nur den Empfänger etwas an.',
              ],
              [
                'Jemand fragt, ob Person X hier wohnt',
                'Keine Auskunft. Du bestätigst keine Wohnadressen.',
              ],
              [
                'Jemand fragt, wann du wieder kommst',
                'Allgemein antworten, keine Angaben zu anderen Sendungen '
                    'oder Empfängern.',
              ],
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: 'Eine Weitergabe von Empfängerdaten an Dritte ist eine '
                'Offenlegung im Sinne von Art. 4 Nr. 2 DSGVO und braucht '
                'eine Rechtsgrundlage nach Art. 6 DSGVO. Für die '
                'Nachbarschaftsabgabe ist die Nennung von Name und Adresse '
                'zur Vertragserfüllung erforderlich — für Paketinhalte, '
                'Telefonnummern oder Auskünfte über andere Empfänger gibt '
                'es keine.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Papier ist die unterschätzte Gefahr',
        blocks: [
          ParagraphBlock(
            'Digitale Daten sind wenigstens durch eine Bildschirmsperre '
            'geschützt. Ein Zettel im Fahrzeug ist es nicht. Eine '
            'Tourenliste hinter der Windschutzscheibe ist von außen '
            'lesbar — mit Namen und Adressen von zweihundert Haushalten.',
          ),
          BulletsBlock([
            'Papierlisten nie offen im Fahrzeug liegen lassen, schon gar '
                'nicht sichtbar durch die Scheibe',
            'Beim Verlassen des Fahrzeugs Listen mitnehmen oder verschlossen '
                'verstauen',
            'Am Ende der Tour: Listen im Betrieb abgeben, nicht mit nach '
                'Hause nehmen',
            'Entsorgung nur über den vorgesehenen Weg im Betrieb — nicht in '
                'den Hausmüll, nicht in den Papierkorb an der Tankstelle',
            'Etiketten von Retouren und Fehlpaketen ebenso behandeln wie '
                'Listen',
          ]),
          RevealBlock(
            prompt: 'Fallbeispiel: Du bist mit der Tour fertig, die '
                'Tourenliste ist nur noch Altpapier. Auf dem Heimweg wirfst '
                'du sie in die Papiertonne an deinem Wohnhaus. Ist das in '
                'Ordnung?',
            answer: 'Nein. Auf der Liste stehen Namen und Anschriften — '
                'personenbezogene Daten. Sie müssen so entsorgt werden, '
                'dass niemand sie wiederherstellen kann, in der Regel über '
                'einen Datenschutz-Behälter oder den Aktenvernichter im '
                'Betrieb. Der naheliegende Irrtum ist, dass eine erledigte '
                'Liste „nichts mehr wert" sei. Für den Datenschutz ändert '
                'die Erledigung nichts: Die Daten sind dieselben, und eine '
                'offene Papiertonne ist ein öffentlich zugänglicher Ort. '
                'Zusätzlich hättest du die Liste gar nicht erst mit nach '
                'Hause nehmen dürfen.',
          ),
          DoDontBlock(
            doTitle: 'Richtig',
            dos: [
              'Listen im Betrieb abgeben und dort ordnungsgemäß entsorgen',
              'Scanner sperren, bevor du das Fahrzeug verlässt',
              'Bei Rückfragen zu fremden Sendungen an die Betriebsleitung '
                  'verweisen',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Screenshots von Adresslisten anfertigen oder verschicken',
              'Tourenlisten mit nach Hause nehmen oder privat entsorgen',
              'Empfängerdaten an Nachbarn, Bekannte oder Dritte weitergeben',
              'Das Dienstgerät an jemand anderen weiterreichen',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste Kapitel 3',
        blocks: [
          ChecklistBlock(
            title: 'Am Ende jeder Tour',
            items: [
              'Kein Screenshot von Adressdaten auf meinem Gerät',
              'Scanner und Diensthandy sind gesperrt und sicher verstaut',
              'Keine Papierliste liegt offen im Fahrzeug',
              'Alle Listen und Etiketten sind im Betrieb abgegeben',
              'Ich habe keine Empfängerdaten an Dritte weitergegeben',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 4
  SafetyChapterContent(
    id: 'ds4',
    title: 'Deine eigenen Daten und die der Kollegen',
    summary: 'Krankmeldung, Zeiterfassung, Personalakte — und deine '
        'Betroffenenrechte',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Datenschutz schützt auch dich',
        blocks: [
          ParagraphBlock(
            'Nicht nur Empfänger haben Daten im System — du auch. Und die '
            'sind zum Teil deutlich sensibler als eine Lieferadresse.',
          ),
          BulletsBlock([
            'Leistungskennzahlen aus deiner Zustelltätigkeit',
            'Krankmeldungen und Abwesenheiten',
            'Zeiterfassung, Schichtpläne, Pausenzeiten',
            'Führerschein- und Ausweisdaten aus der Personalakte',
            'Fotos, auf denen du oder Kollegen zu sehen sind',
          ]),
          ParagraphBlock(
            'Diese Daten darf der Betrieb verarbeiten, soweit es für das '
            'Arbeitsverhältnis erforderlich ist. Er darf sie aber nicht '
            'beliebig weitergeben — und du darfst es genauso wenig, wenn es '
            'um Kollegen geht.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: 'Beschäftigtendaten werden auf Grundlage von Art. 6 '
                'Abs. 1 lit. b und f DSGVO in Verbindung mit § 26 BDSG '
                'verarbeitet — zulässig nur, soweit es für das '
                'Beschäftigungsverhältnis erforderlich ist. '
                'Gesundheitsdaten wie Krankmeldungen sind besondere '
                'Kategorien nach Art. 9 DSGVO und besonders streng '
                'geschützt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Kollegendaten gehören nicht dir',
        blocks: [
          ParagraphBlock(
            'Im Depot bekommt man vieles mit: wer krank ist, wer Ärger '
            'mit einer Tour hatte, wer eine Abmahnung bekommen hat. '
            'Mitbekommen ist das eine — weitererzählen das andere.',
          ),
          DoDontBlock(
            doTitle: 'Richtig',
            dos: [
              'Über deine eigenen Werte sprechen, so viel du möchtest',
              'Probleme mit einem Kollegen direkt mit ihm oder mit der '
                  'Betriebsleitung klären',
              'Ein Foto mit Kollegen nur machen und teilen, wenn alle '
                  'Abgebildeten einverstanden sind',
              'Beobachtete Verstöße intern melden statt im Depot '
                  'herumzuerzählen',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Leistungsdaten oder Auswertungen von Kollegen weitergeben',
              'Über den Krankheitsgrund eines Kollegen sprechen — auch '
                  'wenn du ihn kennst',
              'Fotos oder Videos von Kollegen ohne deren Einverständnis in '
                  'Chatgruppen posten',
              'Screenshots aus internen Listen oder Auswertungen teilen',
            ],
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Besonders heikel',
            text: 'Krankmeldungen. Dass jemand krank ist, ist eine '
                'Gesundheitsangabe nach Art. 9 DSGVO. Der Grund erst '
                'recht. Weitergabe an andere Fahrer ist auch dann nicht '
                'erlaubt, wenn der Betroffene selbst schon davon erzählt '
                'hat.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Deine Rechte als Betroffener',
        blocks: [
          ParagraphBlock(
            'Die DSGVO gibt dir Rechte gegenüber deinem Arbeitgeber. Du '
            'musst sie nicht begründen, und ihre Ausübung darf dir nicht '
            'zum Nachteil werden.',
          ),
          TableBlock(
            headers: ['Recht', 'Was du verlangen kannst'],
            rows: [
              [
                'Auskunft (Art. 15)',
                'Eine Übersicht, welche Daten über dich gespeichert sind '
                    'und wofür.',
              ],
              [
                'Berichtigung (Art. 16)',
                'Korrektur falscher Angaben, etwa einer falschen '
                    'Personalnummer oder Adresse.',
              ],
              [
                'Löschung (Art. 17)',
                'Löschung von Daten, die nicht mehr benötigt werden und '
                    'keiner Aufbewahrungsfrist unterliegen.',
              ],
            ],
          ),
          ParagraphBlock(
            'Ansprechpartner ist die Betriebsleitung oder der '
            'Datenschutzbeauftragte des Unternehmens. Eine Anfrage muss '
            'grundsätzlich innerhalb eines Monats beantwortet werden.',
          ),
          RevealBlock(
            prompt: 'Fallbeispiel: Ein Kollege bittet dich, ihm einen '
                'Screenshot einer internen Auswertung zu schicken — auf der '
                'alle Fahrer mit Namen und Werten stehen. Er will nur sehen, '
                'wo er selbst steht. Machst du das?',
            answer: 'Nein. Auf dem Screenshot stehen die Leistungsdaten '
                'aller Kollegen; das ist eine Weitergabe von '
                'Beschäftigtendaten ohne Rechtsgrundlage. Dass der Kollege '
                'nur seine eigene Zeile sehen will, ändert nichts — er '
                'bekommt trotzdem alle anderen mit. Richtig ist: Er fragt '
                'seine eigenen Werte bei der Betriebsleitung ab. Sein '
                'Auskunftsrecht nach Art. 15 DSGVO bezieht sich '
                'ausschließlich auf seine eigenen Daten.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Checkliste Kapitel 4',
        blocks: [
          ChecklistBlock(
            title: 'Im Umgang mit Kollegendaten',
            items: [
              'Ich gebe keine Leistungsdaten von Kollegen weiter',
              'Ich spreche nicht über Krankmeldungen anderer',
              'Ich poste keine Fotos von Kollegen ohne deren Zustimmung',
              'Ich mache keine Screenshots aus internen Auswertungen',
              'Ich weiß, an wen ich mich wende, wenn ich Auskunft über '
                  'meine eigenen Daten möchte',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 5
  SafetyChapterContent(
    id: 'ds5',
    title: 'Wenn etwas schiefgeht — Datenpanne',
    summary: '72 Stunden Meldefrist: warum du sofort melden musst',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Was eine Datenpanne ist',
        blocks: [
          ParagraphBlock(
            'Eine Datenpanne ist nicht nur der große Hackerangriff. In der '
            'Zustellung sind es fast immer kleine, alltägliche Missgeschicke '
            '— und genau die zählen auch.',
          ),
          BulletsBlock([
            'Dienstliches Telefon oder Scanner verloren oder gestohlen',
            'Paket beim falschen Empfänger abgegeben, der es geöffnet hat',
            'Paket mit lesbarem Adressetikett offen im Hausflur oder auf '
                'der Straße liegen gelassen',
            'Foto oder Adressliste versehentlich an die falsche Person '
                'geschickt',
            'Tourenliste verloren oder im Fahrzeug offen liegen gelassen',
            'Scanner unbeaufsichtigt und entsperrt zugänglich gewesen',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Faustregel',
            text: 'Sobald personenbezogene Daten jemandem zugänglich '
                'geworden sind, dem sie nicht zugänglich sein sollten, ist '
                'es eine Datenpanne. Ob am Ende tatsächlich ein Schaden '
                'entstanden ist, entscheidet nicht du — das prüft der '
                'Betrieb.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Die 72-Stunden-Frist',
        blocks: [
          ParagraphBlock(
            'Der entscheidende Punkt für dich ist die Uhr. Sobald das '
            'Unternehmen von einer Datenpanne erfährt, läuft eine sehr '
            'kurze Frist — und sie läuft unabhängig davon, ob es Feierabend, '
            'Wochenende oder Feiertag ist.',
          ),
          FactsBlock([
            FactItem('72 Std.', 'Meldefrist des Unternehmens an die '
                'Aufsichtsbehörde nach Art. 33 DSGVO'),
            FactItem('sofort', 'deine Meldung an Dispatcher oder '
                'Betriebsleitung — noch am selben Tag'),
            FactItem('0', 'Nachteile für dich, wenn du einen eigenen Fehler '
                'sofort meldest'),
          ]),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: 'Art. 33 Abs. 1 DSGVO verpflichtet das Unternehmen, eine '
                'Verletzung des Schutzes personenbezogener Daten '
                'unverzüglich und möglichst binnen 72 Stunden nach '
                'Bekanntwerden der Aufsichtsbehörde zu melden. Bei hohem '
                'Risiko müssen nach Art. 34 DSGVO zusätzlich die '
                'Betroffenen benachrichtigt werden. Das Unternehmen kann '
                'diese Frist nur einhalten, wenn du sofort meldest.',
          ),
        ],
      ),
      SafetySlide(
        title: 'So meldest du richtig',
        blocks: [
          StepsBlock([
            'Sofort Dispatcher oder Betriebsleitung anrufen — nicht bis zum '
                'Feierabend warten',
            'Sagen, was passiert ist, wann es passiert ist und welche Daten '
                'betroffen sind',
            'Sagen, wer die Daten möglicherweise gesehen hat',
            'Nichts auf eigene Faust reparieren: kein Löschen von '
                'Protokollen, kein Zurückholen ohne Absprache',
            'Wenn möglich, den Zustand sichern — etwa das falsch '
                'zugestellte Paket nicht weiterbewegen, bevor abgestimmt '
                'ist, wie vorzugehen ist',
          ]),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Das Wichtigste in diesem Kapitel',
            text: 'Wer einen Fehler sofort meldet, handelt richtig. Das '
                'Melden ist ausdrücklich erwünscht und ist kein Eingeständnis '
                'von Unfähigkeit. Verschweigen dagegen macht aus einem '
                'kleinen Missgeschick ein echtes Problem — für die '
                'Betroffenen, für den Betrieb und am Ende auch für dich.',
          ),
          DoDontBlock(
            doTitle: 'Richtig',
            dos: [
              'Sofort melden, auch wenn es peinlich ist',
              'Vollständig schildern, auch die eigenen Fehler',
              'Nachfragen, ob du noch etwas tun sollst',
            ],
            dontTitle: 'Falsch',
            donts: [
              'Abwarten, ob es überhaupt jemand merkt',
              'Erst am nächsten Arbeitstag Bescheid sagen',
              'Den Vorfall kleinreden oder Teile weglassen',
              'Auf eigene Faust versuchen, das Paket oder das Foto '
                  'zurückzuholen',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Fallbeispiel und Checkliste',
        blocks: [
          RevealBlock(
            prompt: 'Fallbeispiel: Du merkst am Abend, dass du ein Paket in '
                'Haus Nummer 14 statt 41 abgegeben hast. Der Empfänger dort '
                'hat es bereits geöffnet. Du willst es morgen früh einfach '
                'abholen und richtig zustellen — dann fällt es niemandem '
                'auf. Was ist daran falsch?',
            answer: 'Zwei Dinge. Erstens ist bereits eine Datenpanne '
                'eingetreten: Eine fremde Person hat Name, Anschrift und '
                'Inhalt der Sendung erfahren. Das ist meldepflichtig zu '
                'prüfen, und die 72-Stunden-Frist aus Art. 33 DSGVO läuft '
                'ab dem Moment, in dem das Unternehmen davon erfährt. '
                'Zweitens verhinderst du mit dem Abwarten genau das, was '
                'der Betrieb tun müsste — bewerten, dokumentieren und '
                'gegebenenfalls den betroffenen Empfänger informieren. Der '
                'naheliegende Irrtum ist, dass eine stille Korrektur '
                'niemandem schadet. Tatsächlich schadet sie: Wird der '
                'Vorfall später bekannt, steht das Unternehmen ohne '
                'fristgerechte Meldung da — und du hast den Fehler '
                'verschwiegen statt ihn gemeldet zu haben.',
          ),
          ChecklistBlock(
            title: 'Bei jedem Verdacht auf eine Datenpanne',
            items: [
              'Ich melde noch am selben Tag, nicht erst morgen',
              'Ich sage, was passiert ist, wann und welche Daten betroffen '
                  'sind',
              'Ich beschönige nichts und lasse nichts weg',
              'Ich unternehme nichts auf eigene Faust',
              'Mir ist klar: Melden ist richtig, Verschweigen macht es '
                  'schlimmer',
            ],
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════════════════════ 6
  SafetyChapterContent(
    id: 'ds6',
    title: 'Verschwiegenheit und Loyalität',
    summary: 'Was nach außen darf, was nicht — und warum sachliche Kritik '
        'ausdrücklich erlaubt ist',
    asset: '',
    slides: [
      SafetySlide(
        title: 'Betriebsgeheimnisse bleiben im Betrieb',
        blocks: [
          ParagraphBlock(
            'Neben personenbezogenen Daten gibt es eine zweite Gruppe von '
            'Informationen, die nicht nach außen gehören: interne Zahlen '
            'und Betriebs- und Geschäftsgeheimnisse. Dazu zählt vieles, was '
            'im Depot ganz selbstverständlich besprochen wird.',
          ),
          BulletsBlock([
            'Preise, Konditionen und Verträge mit Auftraggebern',
            'Interne Kennzahlen und Auswertungen',
            'Tourenpläne, Routenlogik und Kapazitätszahlen',
            'Interne Anweisungen, Schulungsunterlagen und Prozessvorgaben',
            'Fotos aus dem Depot, auf denen Listen, Bildschirme oder '
                'Sendungen zu erkennen sind',
          ]),
          ParagraphBlock(
            'Das gilt in jedem Kanal gleichermaßen: im persönlichen '
            'Gespräch, in sozialen Netzwerken und in Fahrer-Chatgruppen. '
            'Eine WhatsApp-Gruppe mit sechzig Fahrern ist keine private '
            'Unterhaltung.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: 'Geschäftsgeheimnisse sind durch das '
                'Geschäftsgeheimnisgesetz (GeschGehG) geschützt. '
                'Unabhängig davon folgt aus dem Arbeitsvertrag eine '
                'Verschwiegenheitspflicht als arbeitsvertragliche '
                'Nebenpflicht nach § 241 Abs. 2 BGB. Für '
                'personenbezogene Daten gilt zusätzlich die '
                'Vertraulichkeit nach Art. 5 Abs. 1 lit. f DSGVO.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Unwahre Behauptungen über die Firma',
        blocks: [
          ParagraphBlock(
            'Hier wird oft durcheinandergebracht, was erlaubt ist und was '
            'nicht. Die Grenze verläuft nicht zwischen „positiv" und '
            '„negativ", sondern zwischen wahr und bewusst unwahr, zwischen '
            'Kritik und Schmähung.',
          ),
          ParagraphBlock(
            'Bewusst unwahre Tatsachenbehauptungen über das Unternehmen, '
            'Vorgesetzte oder Kollegen sind von der Meinungsfreiheit nicht '
            'gedeckt. Dasselbe gilt für Beleidigungen und Schmähkritik — '
            'also Äußerungen, bei denen es nicht mehr um die Sache geht, '
            'sondern nur noch darum, jemanden herabzusetzen.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Die Rechtsgrundlage',
            text: 'Art. 5 Abs. 1 GG schützt Meinungsäußerungen, aber keine '
                'bewusst unwahren Tatsachenbehauptungen und keine '
                'Schmähkritik. Solche Äußerungen können eine fristlose '
                'Kündigung nach § 626 BGB rechtfertigen. Bei übler '
                'Nachrede kommt eine Strafbarkeit nach § 186 StGB hinzu; '
                'bei bewusst falschen Behauptungen greift § 187 StGB '
                '(Verleumdung).',
          ),
          CalloutBlock(
            tone: CalloutTone.warning,
            title: 'Typische Missverständnisse',
            text: 'Ein privates Profil ist nicht privat, sobald andere '
                'mitlesen können. Eine geschlossene Chatgruppe ist nicht '
                'geschützt, sobald ein Screenshot davon weitergeht. Und '
                '„das war doch nur meine Meinung" hilft nicht, wenn die '
                'Aussage eine Tatsachenbehauptung war, die nachweislich '
                'nicht stimmt.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Sachliche Kritik ist ausdrücklich erlaubt',
        blocks: [
          ParagraphBlock(
            'Genauso wichtig wie die Grenze ist, was diesseits davon liegt '
            '— und das ist viel. Du darfst Kritik äußern, auch deutlich, '
            'auch unbequem. Du darfst sagen, dass eine Tour zu eng geplant '
            'ist, dass ein Fahrzeug in schlechtem Zustand ist oder dass '
            'eine Ansage im Depot falsch war.',
          ),
          ParagraphBlock(
            'Und wer echte Missstände meldet, steht nicht schutzlos da: '
            'Seit dem 2. Juli 2023 gilt das Hinweisgeberschutzgesetz '
            '(HinSchG). Es verbietet Repressalien gegen Beschäftigte, die '
            'Verstöße melden — also Kündigung, Abmahnung, Versetzung oder '
            'Benachteiligung wegen der Meldung.',
          ),
          CalloutBlock(
            tone: CalloutTone.law,
            title: 'Hinweisgeberschutz',
            text: 'Das HinSchG schützt Personen, die im beruflichen '
                'Kontext Verstöße melden, vor Repressalien. Der Schutz '
                'entfällt nur bei wissentlich oder grob fahrlässig '
                'unrichtigen Meldungen. Wer also ernsthaft und nach bestem '
                'Wissen einen Missstand meldet, ist geschützt — auch dann, '
                'wenn sich der Verdacht am Ende nicht bestätigt.',
          ),
          CalloutBlock(
            tone: CalloutTone.key,
            title: 'Der Unterschied in einem Satz',
            text: 'Sag, was du erlebt hast — nicht, was du dir zusammenreimst. '
                'Wahrheitsgemäße Kritik ist geschützt, erfundene Vorwürfe '
                'sind es nicht.',
          ),
        ],
      ),
      SafetySlide(
        title: 'Der konstruktive Weg',
        blocks: [
          ParagraphBlock(
            'Fast alles, was Fahrer nach außen tragen, ließe sich intern '
            'schneller lösen. Der Weg nach innen ist deshalb nicht nur der '
            'sicherere, sondern meistens auch der wirksamere.',
          ),
          StepsBlock([
            'Zuerst den Dispatcher ansprechen — die meisten Probleme sind '
                'Planungsprobleme und dort lösbar',
            'Kommt nichts zurück: Betriebsleitung ansprechen, gern '
                'schriftlich, mit Datum und konkretem Vorfall',
            'Bei ernsteren Verstößen: die interne Meldestelle nach dem '
                'HinSchG nutzen',
            'Erst wenn intern nichts passiert, kommen externe Stellen in '
                'Betracht — dann aber sachlich und mit belegbaren '
                'Tatsachen',
          ]),
          DoDontBlock(
            doTitle: 'Erlaubt und erwünscht',
            dos: [
              'Sagen, dass eine Tour regelmäßig nicht zu schaffen ist',
              'Auf einen technischen Mangel am Fahrzeug hinweisen — auch '
                  'wiederholt',
              'Einen konkreten Vorfall schildern, den du selbst erlebt hast',
              'Einen Verstoß über die interne Meldestelle melden',
              'Nachhaken, wenn auf eine Meldung nichts passiert',
            ],
            dontTitle: 'Nicht gedeckt',
            donts: [
              'Behauptungen aufstellen, von denen du weißt, dass sie nicht '
                  'stimmen',
              'Vorgesetzte oder Kollegen beleidigen oder herabwürdigen',
              'Interne Zahlen, Verträge oder Auswertungen öffentlich machen',
              'Gerüchte in Chatgruppen weiterverbreiten, ohne sie zu kennen',
              'Konflikte über Bewertungsportale oder soziale Netzwerke '
                  'austragen, bevor intern überhaupt jemand gefragt wurde',
            ],
          ),
        ],
      ),
      SafetySlide(
        title: 'Fallbeispiel und Checkliste',
        blocks: [
          RevealBlock(
            prompt: 'Fallbeispiel: In der Fahrer-Chatgruppe schreibt '
                'jemand, die Firma zahle Stunden absichtlich nicht aus. Du '
                'hast das selbst nie erlebt, ärgerst dich aber gerade über '
                'deinen Dienstplan und schreibst: „Stimmt, die betrügen '
                'uns alle systematisch." Am nächsten Tag geht ein '
                'Screenshot der Gruppe herum. Wie ist das zu bewerten?',
            answer: 'Kritisch — nicht wegen der Kritik, sondern wegen der '
                'Form. Du hast eine Tatsachenbehauptung aufgestellt '
                '(„betrügen uns systematisch"), die du selbst nicht belegen '
                'kannst und nicht erlebt hast. Bewusst unwahre '
                'Tatsachenbehauptungen sind von der Meinungsfreiheit nicht '
                'gedeckt und können arbeitsrechtliche Folgen bis zur '
                'fristlosen Kündigung nach § 626 BGB haben; bei übler '
                'Nachrede kommt § 186 StGB hinzu. Der Screenshot zeigt '
                'außerdem, dass eine geschlossene Gruppe kein geschützter '
                'Raum ist. Richtig gewesen wäre: deinen eigenen Fall '
                'benennen — „Bei mir fehlen im Juli zwei Stunden, ich habe '
                'das gemeldet und bisher keine Antwort" — und ihn an '
                'Dispatcher, Betriebsleitung oder die interne Meldestelle '
                'geben. Diese Aussage ist wahr, überprüfbar und durch das '
                'HinSchG geschützt. Ergebnis: Dieselbe Unzufriedenheit, '
                'aber richtig geäußert, kann dir nicht schaden.',
          ),
          ChecklistBlock(
            title: 'Bevor ich etwas nach außen trage',
            items: [
              'Ich weiß aus eigener Anschauung, dass es stimmt',
              'Ich schildere den Vorfall sachlich, ohne Beleidigung',
              'Ich gebe keine internen Zahlen, Verträge oder Auswertungen '
                  'preis',
              'Ich habe es zuerst intern angesprochen — Dispatcher, '
                  'Betriebsleitung oder Meldestelle',
              'Mir ist klar: echte Missstände zu melden ist geschützt, '
                  'Erfundenes zu behaupten nicht',
            ],
          ),
        ],
      ),
    ],
  ),
];
