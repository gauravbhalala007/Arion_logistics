// lib/data/safety_training/operating_instructions_de.dart
//
// Betriebsanweisungen — deutsche Fassung (Master).
// Generisch für Zustellbetriebe formuliert; betriebsspezifische Angaben
// (Ansprechpartner, Standort der Verbandkästen, Sammelplatz) ergänzt
// der jeweilige Betrieb.

import 'operating_instructions.dart';

const List<OperatingInstruction> operatingInstructionsDe = [
  // ─────────────────────────────────────────── Fahrzeug
  OperatingInstruction(
    id: 'baw_transporter',
    title: 'Fahren mit dem Transporter bis 3,5 t',
    subtitle: 'Zustellfahrzeug führen, rangieren, abstellen',
    category: InstructionCategory.vehicle,
    scope: 'Gilt für alle Beschäftigten, die Zustellfahrzeuge bis 3,5 t '
        'zulässiger Gesamtmasse führen.',
    hazards: [
      'Verkehrsunfälle durch Ablenkung, Zeitdruck und Übermüdung',
      'Anfahren von Personen beim Rückwärtsfahren — toter Winkel',
      'Verrutschende Ladung beim Bremsen und in Kurven',
      'Stürze beim Ein- und Aussteigen',
      'Überschreiten der zulässigen Gesamtmasse',
    ],
    protection: [
      'Gültige Fahrerlaubnis mitführen',
      'Abfahrtkontrolle vor Fahrtantritt: Beleuchtung, Reifen, Bremsen, '
          'Sicht, Ladungssicherung',
      'Sitz, Spiegel und Kopfstütze vor der ersten Fahrt einstellen',
      'Sicherheitsgurt anlegen — auch auf kurzen Strecken zwischen zwei '
          'Stopps',
      'Kein Alkohol, keine Drogen, keine beeinträchtigenden Medikamente '
          'vor und während der Fahrt',
      'Mobiltelefon nur mit Freisprecheinrichtung, Adresseingabe nur im '
          'Stand',
      'Rückwärtsfahren bei Gefährdung nur mit Einweiser; im Zweifel '
          'aussteigen und Umfeld prüfen',
      'Ladung gegen Verrutschen sichern, schwere Sendungen nach unten '
          'und an die Stirnwand',
      'Fahrzeug nach dem Verlassen generell abschließen, Schlüssel nie '
          'stecken lassen',
      'Pausen- und Lenkzeitregelungen einhalten',
    ],
    onFailure: [
      'Bei Warnleuchten oder auffälligen Geräuschen: sichere Stelle '
          'anfahren und anhalten',
      'Warnblinkanlage einschalten, Warnweste anziehen, Warndreieck '
          'aufstellen (ca. 100 m, Autobahn 150–400 m)',
      'Dispatcher informieren, Pannendienst über den vorgegebenen Weg '
          'anfordern',
      'Nicht selbst reparieren — Abschleppen nur mit Abschleppstange',
      'Fahrzeug mit erkennbarem Mangel nicht weiterbewegen',
    ],
    onAccident: [
      'Anhalten, Unfallstelle absichern, Warnweste vor dem Aussteigen',
      'Erste Hilfe leisten, Notruf 112',
      'Polizei bei Personenschaden, hohem Sachschaden oder Verdacht auf '
          'Alkohol/Drogen',
      'Personalien und Versicherungsdaten austauschen, Fotos und Zeugen '
          'sichern',
      'Arbeitgeber unverzüglich informieren; auch kleine Verletzungen '
          'ins Verbandbuch eintragen',
    ],
    maintenance: [
      'Mängel sofort melden und dokumentieren',
      'Fahrzeug sauber halten, Sicht- und Trittflächen frei von Schnee, '
          'Eis und Verschmutzung',
      'Verbandkasten, Warndreieck und Warnweste auf Vollständigkeit und '
          'Verfalldatum prüfen',
      'Wartungs- und Inspektionstermine einhalten',
    ],
  ),

  // ─────────────────────────────────────────── PSA
  OperatingInstruction(
    id: 'baw_sicherheitsschuhe',
    title: 'Sicherheitsschuhe',
    subtitle: 'Fußschutz im Zustellbetrieb',
    category: InstructionCategory.ppe,
    scope: 'Gilt für alle Beschäftigten in Zustellung, Lager und '
        'Fahrzeughof.',
    hazards: [
      'Herabfallende Sendungen und Ladungsteile',
      'Hineintreten in spitze oder scharfkantige Gegenstände',
      'Umknicken und Bänderverletzungen am Sprunggelenk beim Aussteigen, '
          'auf Bordsteinen und unebenen Wegen',
      'Ausrutschen auf nassen und vereisten Flächen',
      'Quetschungen durch Rollbehälter und Handhubwagen',
    ],
    protection: [
      'Sicherheitsschuhe während der gesamten Arbeitszeit tragen — in '
          'der Station wie auf der Route, ganzjährig und unabhängig vom '
          'Tragekomfort',
      'Knöchelhohe Ausführung bevorzugen — sie stützt das Sprunggelenk '
          'gegen Umknicken',
      'Mindestens Schutzklasse S1; bei Nässe S2, bei Durchtrittgefahr S3',
      'Schuhe vollständig schnüren, geschlossen tragen',
      'Vor Arbeitsbeginn auf Mängel prüfen: Profil, Risse, Sohlenhaftung',
      'Keine eigenen Veränderungen an den Schuhen vornehmen',
      'Niemals in Turnschuhen oder offenen Schuhen arbeiten',
    ],
    onFailure: [
      'Abgelaufenes Profil, Risse oder defekte Sohle: Schuhe nicht '
          'weiter benutzen',
      'Drückende oder scheuernde Schuhe melden — es gibt andere Modelle '
          'und Größen; Ausweichen auf private Turnschuhe ist keine '
          'Lösung',
      'Ersatz beim Vorgesetzten anfordern — der Arbeitgeber stellt die '
          'PSA kostenlos',
    ],
    onAccident: [
      'Fußverletzungen sofort versorgen lassen, auch scheinbar leichte',
      'Eintrag ins Verbandbuch',
      'Bei Durchstichverletzungen ärztliche Behandlung — Tetanusschutz '
          'prüfen lassen',
    ],
    maintenance: [
      'Schuhe regelmäßig reinigen und trocknen lassen',
      'Stark verschmutzte oder durchnässte Schuhe austauschen',
      'Austauschintervall nach Herstellerangabe und Verschleiß',
    ],
  ),

  OperatingInstruction(
    id: 'baw_warnweste',
    title: 'Warnweste',
    subtitle: 'Gesehen werden im Straßenraum',
    category: InstructionCategory.ppe,
    scope: 'Gilt für alle Beschäftigten, die sich im Straßenraum, auf '
        'dem Hof oder an Verladeflächen aufhalten.',
    hazards: [
      'Übersehen werden durch andere Verkehrsteilnehmer',
      'Schlechte Sicht bei Dämmerung, Dunkelheit, Regen und Nebel',
      'Rangierverkehr auf dem Stationsgelände',
    ],
    protection: [
      'Warnweste griffbereit im Fahrerhaus mitführen — nicht im '
          'Laderaum',
      'Vor dem Aussteigen anziehen bei Panne, Unfall und jedem Halt im '
          'Straßenraum',
      'Auf dem Stationsgelände und an Verladeflächen tragen, wenn dort '
          'Fahrverkehr herrscht',
      'Warnweste der Klasse 2 oder 3 verwenden, vollständig schließen',
      'Bei Dunkelheit zusätzlich auf Beleuchtung und Standlicht achten',
    ],
    onFailure: [
      'Verschmutzte, verblichene oder beschädigte Weste ersetzen — die '
          'Reflexstreifen müssen wirksam sein',
      'Fehlende Weste vor Fahrtantritt melden und ersetzen lassen',
    ],
    onAccident: [
      'Nach einem Unfall im Straßenraum Weste anbehalten, bis die '
          'Unfallstelle geräumt ist',
      'Verletzungen melden und dokumentieren',
    ],
    maintenance: [
      'Weste sauber halten, nach Herstellerangabe waschen',
      'Auf Vollständigkeit im Fahrzeug prüfen — Teil der '
          'Abfahrtkontrolle',
    ],
  ),

  // ─────────────────────────────────────────── Handhabung
  OperatingInstruction(
    id: 'baw_heben_tragen',
    title: 'Heben und Tragen',
    subtitle: 'Sendungen bewegen, ohne den Rücken zu schädigen',
    category: InstructionCategory.handling,
    scope: 'Gilt für das manuelle Heben, Tragen und Absetzen von '
        'Sendungen und Ladungsträgern.',
    hazards: [
      'Wirbelsäulen- und Bandscheibenschäden durch falsche Hebetechnik',
      'Muskel- und Sehnenverletzungen durch ruckartige Bewegungen',
      'Quetschungen an Händen und Füßen beim Absetzen',
      'Stolpern durch eingeschränkte Sicht bei großen Sendungen',
    ],
    protection: [
      'Vor dem Heben Gewicht abschätzen und Weg freimachen',
      'Nah an die Last herantreten, Füße schulterbreit',
      'Aus den Beinen heben: in die Knie gehen, Rücken gerade halten',
      'Last körpernah tragen, nicht auf Armeslänge',
      'Nicht heben und gleichzeitig drehen — mit den Füßen umsetzen',
      'Schwere oder sperrige Sendungen zu zweit oder mit Hilfsmitteln '
          'bewegen (Rollbehälter, Sackkarre, Handhubwagen)',
      'Sicht beim Tragen freihalten; im Zweifel zweimal gehen',
      'Handschuhe bei scharfkantigen Sendungen tragen',
    ],
    onFailure: [
      'Last, die zu schwer oder unhandlich ist, nicht allein bewegen — '
          'Hilfe anfordern',
      'Defekte Hilfsmittel (klemmende Rollen, beschädigte Sackkarre) '
          'nicht benutzen und melden',
    ],
    onAccident: [
      'Bei plötzlichem Schmerz im Rücken Tätigkeit sofort abbrechen',
      'Vorgesetzten informieren, Eintrag ins Verbandbuch',
      'Bei anhaltenden Beschwerden Durchgangsarzt aufsuchen',
    ],
    maintenance: [
      'Transporthilfsmittel regelmäßig auf Funktion prüfen',
      'Verkehrswege und Ladeflächen frei und rutschsicher halten',
    ],
  ),

  OperatingInstruction(
    id: 'baw_winter',
    title: 'Winterliche Straßenverhältnisse',
    subtitle: 'Fahren und Zustellen bei Schnee, Eis und Nässe',
    category: InstructionCategory.vehicle,
    scope: 'Gilt für Zustellung und Fahrbetrieb bei winterlichen '
        'Verhältnissen.',
    hazards: [
      'Verlängerter Bremsweg, Schleudern, Aquaplaning',
      'Stürze auf vereisten Gehwegen, Rampen und Trittstufen',
      'Unterkühlung bei längerem Aufenthalt im Freien',
      'Eingeschränkte Sicht durch vereiste Scheiben und Spiegel',
    ],
    protection: [
      'Fahrzeug vor Fahrtantritt vollständig von Schnee und Eis '
          'befreien — auch Dach, Scheinwerfer und Kennzeichen',
      'Wintertaugliche Bereifung; Schneeketten und Anfahrhilfen bei '
          'Bedarf mitführen',
      'Frostschutz in Kühl- und Scheibenwaschwasser prüfen, Eiskratzer '
          'an Bord',
      'Geschwindigkeit deutlich reduzieren, Abstand mindestens '
          'verdoppeln',
      'Sanft bremsen, lenken und beschleunigen',
      'Trittflächen und Aufstiege vor Benutzung von Schnee befreien',
      'Warme, wetterfeste Kleidung und rutschhemmendes Schuhwerk tragen',
      'Zeitdruck vermeiden — lieber später ankommen als gar nicht',
    ],
    onFailure: [
      'Bei unpassierbaren Straßen Tour abbrechen und Dispatcher '
          'informieren',
      'Fahrzeug bei Festfahren nicht mit Gewalt freifahren — Hilfe '
          'anfordern',
    ],
    onAccident: [
      'Unfallstelle besonders sorgfältig absichern — Warndreieck weiter '
          'entfernt aufstellen',
      'Sturzverletzungen auch bei leichten Symptomen melden und '
          'dokumentieren',
    ],
    maintenance: [
      'Wischerblätter und Beleuchtung regelmäßig kontrollieren',
      'Türdichtungen pflegen, Schlösser enteisen',
    ],
  ),

  // ─────────────────────────────────────────── Gefahrstoffe
  OperatingInstruction(
    id: 'baw_adblue',
    title: 'AdBlue (Harnstofflösung)',
    subtitle: 'Nachfüllen von AdBlue am Zustellfahrzeug',
    category: InstructionCategory.hazardous,
    scope: 'Gilt für das Nachfüllen und Handhaben von AdBlue an '
        'Fahrzeugen mit SCR-Abgasreinigung.',
    hazards: [
      'Reizung von Augen, Haut und Atemwegen bei Kontakt',
      'Rutschgefahr durch verschüttete Flüssigkeit',
      'Kristallisation und Korrosion an Fahrzeugteilen',
      'Umweltbelastung bei Eintrag in Boden oder Kanalisation',
    ],
    protection: [
      'Nur den vorgesehenen blauen Einfüllstutzen verwenden — niemals '
          'in den Dieseltank füllen',
      'Schutzhandschuhe tragen, Hautkontakt vermeiden',
      'Nur im Freien oder gut belüftet nachfüllen, Motor abstellen',
      'Behälter sauber verschließen, nicht in der Sonne lagern',
      'Nach dem Umgang Hände gründlich waschen',
    ],
    onFailure: [
      'Verschüttete Flüssigkeit sofort mit Wasser verdünnen und '
          'aufnehmen',
      'Bindemittel verwenden, nicht in die Kanalisation spülen',
      'Bei Fehlbetankung Fahrzeug nicht starten und sofort melden',
    ],
    onAccident: [
      'Augenkontakt: mindestens 15 Minuten mit Wasser spülen, Arzt '
          'aufsuchen',
      'Hautkontakt: mit viel Wasser abspülen, benetzte Kleidung '
          'wechseln',
      'Verschlucken: Mund ausspülen, Wasser trinken, Arzt aufsuchen',
      'Vorfall melden und ins Verbandbuch eintragen',
    ],
    maintenance: [
      'Behälter und Einfüllbereich sauber halten',
      'Leere Gebinde nach Vorgabe entsorgen',
    ],
  ),

  // ─────────────────────────────────────────── Hygiene
  OperatingInstruction(
    id: 'baw_hautschutz',
    title: 'Hautschutz & Handhygiene',
    subtitle: 'Hände schützen bei Kundenkontakt und Ladearbeit',
    category: InstructionCategory.hygiene,
    scope: 'Gilt für alle Beschäftigten mit häufigem Handkontakt zu '
        'Sendungen, Fahrzeugen und Kunden.',
    hazards: [
      'Austrocknung und Risse durch häufiges Waschen und Desinfizieren',
      'Hautreizungen durch Schmutz, Kälte und Reinigungsmittel',
      'Infektionsübertragung bei Kundenkontakt',
      'Schnitt- und Schürfwunden an Kartonkanten',
    ],
    protection: [
      'Hautschutzmittel vor Arbeitsbeginn auftragen',
      'Hände nach Toilettengang, vor Pausen und nach Ladearbeit waschen',
      'Desinfektionsmittel vollständig einreiben und trocknen lassen — '
          'nicht abwischen',
      'Nach dem Waschen Hautpflegemittel verwenden',
      'Schutzhandschuhe bei scharfkantigen oder verschmutzten Sendungen',
      'Ringe und Armbanduhren bei Ladearbeit ablegen',
    ],
    onFailure: [
      'Bei anhaltender Rötung, Juckreiz oder Rissen Tätigkeit melden',
      'Unverträgliches Mittel nicht weiter verwenden — Alternative '
          'anfordern',
    ],
    onAccident: [
      'Schnitt- und Schürfwunden sofort reinigen und verbinden',
      'Eintrag ins Verbandbuch, auch bei kleinen Verletzungen',
      'Bei Entzündungszeichen ärztliche Behandlung',
    ],
    maintenance: [
      'Spender für Seife, Desinfektions- und Pflegemittel auf '
          'Füllstand prüfen',
      'Leere oder defekte Spender melden',
    ],
  ),

  // ─────────────────────────────────────────── Arbeitsplatz
  OperatingInstruction(
    id: 'baw_bildschirm',
    title: 'Bildschirmarbeitsplatz',
    subtitle: 'Disposition und Büroarbeit',
    category: InstructionCategory.workplace,
    scope: 'Gilt für Beschäftigte, die überwiegend am Bildschirm '
        'arbeiten — insbesondere Dispatcher und Verwaltung.',
    hazards: [
      'Augenbeschwerden durch Blendung und langes Fokussieren',
      'Verspannungen in Nacken, Schultern und Rücken',
      'Sehnenscheidenreizung durch ungünstige Hand- und Armhaltung',
      'Stolpern über Kabel',
    ],
    protection: [
      'Bildschirmoberkante etwa in Augenhöhe, Sehabstand 50–70 cm',
      'Bildschirm seitlich zum Fenster stellen — nicht davor oder '
          'dagegen',
      'Sitzhöhe so wählen, dass Unter- und Oberarme etwa einen rechten '
          'Winkel bilden',
      'Füße flach auf dem Boden oder auf einer Fußstütze',
      'Regelmäßig Haltung wechseln, kurze Blickpausen in die Ferne',
      'Kabel führen und sichern',
    ],
    onFailure: [
      'Flackernde oder defekte Bildschirme und Leuchten melden',
      'Defekte Stühle nicht weiter benutzen',
    ],
    onAccident: [
      'Bei anhaltenden Beschwerden Vorgesetzten informieren',
      'Anspruch auf arbeitsmedizinische Vorsorge und '
          'Bildschirmarbeitsplatzbrille prüfen lassen',
    ],
    maintenance: [
      'Bildschirm und Eingabegeräte sauber halten',
      'Arbeitsplatzbeleuchtung regelmäßig prüfen',
    ],
  ),
];
