// lib/data/safety_training/safety_texts_de.dart
//
// Sicherheitsunterweisung — deutsche Master-Texte.
// Key-Satz ist der Vertrag für alle Sprachdateien: gleiche Keys,
// gleiche {platzhalter}. Bullets beginnen mit "• ", Zeilen durch \n.

const Map<String, String> safetyTextsDe = {
  'ask_anytime':
      'Fragen? Wende dich jederzeit an deinen Manager, deinen Dispatcher oder die Geschäftsführung — lieber einmal zu viel fragen als etwas falsch zu machen.',
  // ── Meta / UI ──
  'training_title': 'Sicherheitsunterweisung',
  'training_subtitle': 'Arbeitsschutz für Zusteller — jährliche Unterweisung',
  'training_intro':
      'Diese Unterweisung schützt dich: In ca. 15–20 Minuten lernst du die '
      'wichtigsten Regeln für sicheres Arbeiten und Fahren. Am Ende gibt es '
      'einen kurzen Test (20 Fragen, 80 % zum Bestehen) und du bestätigst '
      'die Teilnahme mit deiner Unterschrift.',
  'chapters_overview_title': 'Kapitelübersicht',
  'chapters_overview_hint': 'Arbeite die Kapitel der Reihe nach durch. Der Test wird freigeschaltet, sobald du alle gelesen hast.',
  'chapter_pages': '{n} Seiten',
  'btn_overview': 'Übersicht',
  'btn_chapter_done': 'Kapitel abschließen',
  'btn_test_locked': 'Erst alle Kapitel lesen',
  'chapter_label': 'Kapitel {n} von {m}',
  'btn_start': 'Unterweisung starten',
  'btn_next': 'Weiter',
  'btn_back': 'Zurück',
  'btn_start_test': 'Zum Test',
  'btn_submit_test': 'Antworten prüfen',
  'btn_retry': 'Nochmal versuchen',
  'btn_finish': 'Abschließen',
  'test_title': 'Abschluss-Test',
  'test_intro':
      '20 Fragen — mindestens 80 % (16 richtige) zum Bestehen. Du kannst den '
      'Test beliebig oft wiederholen.',
  'test_passed': 'Bestanden — {score} von {total} richtig!',
  'test_failed':
      'Leider nicht bestanden ({score} von {total}). Schau dir die Kapitel '
      'nochmal an und versuche es erneut.',
  'signature_title': 'Teilnahme bestätigen',
  'signature_hint':
      'Mit deiner Unterschrift bestätigst du, dass du an der Unterweisung '
      'teilgenommen und den Inhalt verstanden hast. Du hattest Gelegenheit, '
      'Fragen zu stellen.',
  'confirm_checkbox':
      'Ich habe die Unterweisung verstanden und bestätige meine Teilnahme.',
  'btn_clear': 'Löschen',
  'btn_sign_submit': 'Unterschreiben & abschließen',
  'cert_done_title': 'Unterweisung abgeschlossen!',
  'cert_done_body':
      'Dein Nachweis wurde erstellt und in deinen Dokumenten abgelegt. '
      'Die Unterweisung ist 12 Monate gültig.',
  'status_valid_until': 'Gültig bis {date}',
  'status_expired': 'Abgelaufen — bitte erneut absolvieren',
  'status_open': 'Noch nicht absolviert',

  // ── Kapitel ──
  'ch01_title': 'Grundlagen & deine Pflichten',
  'ch01_body': 'Arbeitsschutz ist gesetzlich geregelt (Arbeitsschutzgesetz + '
      'DGUV-Vorschriften) und schützt dein Leben und deine Gesundheit. '
      'Auch du hast Pflichten:\n'
      '• Betriebsanweisungen deines Arbeitgebers befolgen\n'
      '• Unfälle und Beinahe-Unfälle sofort melden\n'
      '• Erste Hilfe leisten bzw. unterstützen\n'
      '• Defekte und Mängel melden (z. B. kaputte Kabel, defekte Geräte)\n'
      '• Schutzausrüstung (Sicherheitsschuhe, Handschuhe, Warnweste) '
      'bestimmungsgemäß benutzen\n'
      '• Kein Alkohol, keine Drogen, keine beeinträchtigenden Medikamente — '
      'du darfst weder dich noch andere gefährden.',
  'ch02_title': 'Betriebsanweisungen',
  'ch02_body': 'Betriebsanweisungen sind verbindliche Anweisungen deines '
      'Arbeitgebers für den Umgang mit Fahrzeugen, Geräten und '
      'Gefahrstoffen.\n'
      '• Sie schützen dich vor Unfällen und Gesundheitsschäden\n'
      '• Wer gegen sie verstößt, riskiert bei einem Unfall die '
      'Mitverantwortung\n'
      '• Beispiele aus dem Fahralltag: Rückwärtsfahren bei Gefährdung nur '
      'mit Einweiser · Fahrzeug nach dem Verlassen immer abschließen · '
      'Abschleppen nur mit Abschleppstange · jeden Unfall unverzüglich '
      'melden\n'
      '• Frag nach, wenn dir eine Anweisung unklar ist — bevor du arbeitest.',
  'ch03_title': '10 Regeln für sicheres Arbeiten',
  'ch03_body': 'Diese zehn Regeln gelten jeden Tag:\n'
      '1. Sicher und umsichtig arbeiten\n'
      '2. Abfahrtkontrolle vor jeder Fahrt\n'
      '3. Ladung im Fahrzeug sichern\n'
      '4. Professionell fahren, StVO beachten\n'
      '5. Sicherheitsgurt immer anlegen\n'
      '6. Fahrzeug, Werkzeug und Ausrüstung in Ordnung halten\n'
      '7. Nur mit geeigneten Schuhen arbeiten\n'
      '8. Höflicher Umgang mit Kollegen und Kunden\n'
      '9. Pausenregelung einhalten\n'
      '10. Tolerant und respektvoll miteinander umgehen',
  'ch04_title': 'Sicherheitsschuhe & Schutzausrüstung',
  'ch04_body': 'Vom Arbeitgeber gestellte Sicherheitsschuhe müssen getragen '
      'werden — das ist Pflicht (§ 15 ArbSchG).\n'
      '• Sie schützen vor herabfallenden Paketen, Anstoßen, Hineintreten '
      'in spitze Gegenstände, Nässe und Rutschen\n'
      '• Schutzklassen: S1 (antistatisch, kraftstoffbeständige Sohle) · '
      'S2 (zusätzlich mind. 60 Min. wasserdicht) · S3 (zusätzlich '
      'durchtrittsichere, profilierte Sohle)\n'
      '• Prüfe deine Schuhe regelmäßig: abgelaufenes Profil oder Schäden → '
      'austauschen lassen\n'
      '• Besonders wichtig auf Rampen, unebenen Wegen, bei Rollbehältern '
      'und Handhubwagen\n'
      '• Warnweste griffbereit im Fahrzeug — bei Panne/Unfall Pflicht.',
  'ch05_title': 'Verhalten im Brandfall',
  'ch05_body': 'Feuerlöscher bedienen: 1. Sicherung ziehen · 2. Schlagknopf '
      'betätigen · 3. Löschpistole drücken.\n'
      '• In Windrichtung löschen, Flächenbrände von vorn, mehrere Löscher '
      'gleichzeitig statt nacheinander\n'
      '• Ein Löscher hält nur Sekunden (6-kg-Pulver: 15–23 s) — benutzte '
      'Löscher immer neu befüllen lassen\n'
      '• Fahrzeugbrand: NICHT im Tunnel oder auf Brücken anhalten — wenn '
      'möglich herausfahren, dann Warnblinker, anhalten, raus\n'
      '• Sofort Feuerwehr 112 rufen: Wo? Was brennt? Verletzte? Was ist '
      'geladen? Nicht auflegen — die Leitstelle beendet das Gespräch\n'
      '• Motorhaube nur mit Handschuhen und vorsichtig einen Spalt öffnen — '
      'Stichflammen-Gefahr durch Sauerstoff.',
  'ch06_title': 'Erste Hilfe',
  'ch06_body': 'Jeder ist gesetzlich verpflichtet, Erste Hilfe zu leisten '
      '(§ 323c StGB) — im Rahmen des Zumutbaren.\n'
      '• Wer hilft, macht grundsätzlich nichts falsch: Als Ersthelfer bist '
      'du unfallversichert und haftest nicht für Fehler — strafbar macht '
      'sich nur, wer NICHT hilft\n'
      '• Grundregeln: Ruhe bewahren · eigene Sicherheit zuerst · '
      'Unfallstelle absichern · dann helfen\n'
      '• Notruf 112 — die W-Fragen: Wo? Was? Wie viele Verletzte? Wer ruft '
      'an? Auf Rückfragen warten!\n'
      '• Jede Verletzung — auch kleine Schnitte — sofort versorgen und ins '
      'Verbandbuch eintragen\n'
      '• Bei Arbeitsunfähigkeit über 3 Tage muss der Arbeitgeber den '
      'Unfall der Berufsgenossenschaft melden — sag ihm daher immer '
      'Bescheid.',
  'ch07_title': 'Richtig sitzen & bewegen',
  'ch07_body': 'Langes, falsches Sitzen macht müde, verspannt und '
      'verlangsamt deine Reaktion.\n'
      '• Sitz vor der Fahrt richtig einstellen: Sitzhöhe, Abstand, '
      'Rückenlehne, Lendenwirbelstütze, Kopfstütze, Lenkrad, Gurtverlauf\n'
      '• Rücken ganz an die Lehne, aufrecht sitzen, Haltung immer wieder '
      'leicht verändern („dynamisches Sitzen")\n'
      '• Nutze Pausen für kurze Übungen: Arme nach oben strecken (ca. 8 s, '
      '3–5×) · Hände an den Hinterkopf, Ellenbogen nach hinten · im Sitzen '
      'das Lenkrad kräftig auseinanderziehen (3–6 s)\n'
      '• Ein trainierter Rücken ist deutlich weniger anfällig für '
      'Beschwerden.',
  'ch08_title': 'Psychische Belastung',
  'ch08_body': 'Termindruck, Stau, Parkplatzsuche, Konflikte — der '
      'Fahreralltag kann belasten. Das ist normal und kein persönliches '
      'Versagen.\n'
      '• Dauerstress führt zu Erschöpfung, Schlafproblemen, Fehlern und '
      'Krankheit — nimm Warnsignale ernst\n'
      '• Sprich Belastungen offen an: bei deinem Dispatcher, im '
      'Personalgespräch oder anonym\n'
      '• Realistische Touren, klare Zuständigkeiten und Feedback sind '
      'Aufgabe des Arbeitgebers — Hinweise helfen allen\n'
      '• Hilfe zu holen ist Stärke, nicht Schwäche. Bei akuten Krisen: '
      'Telefonseelsorge 0800 111 0 111 (kostenlos, rund um die Uhr).',
  'ch09_title': 'Sicheres Fahren & Abfahrtkontrolle',
  'ch09_body': 'Vor JEDER Fahrt: kurzer Abfahrtscheck — er dauert 2 '
      'Minuten und kann Leben retten.\n'
      '• Rundgang: Beleuchtung vorn/hinten · Reifen (Luftdruck, Profil) · '
      'Spiegel und Scheiben sauber · keine Leckagen · Türen/Planen zu · '
      'Kennzeichen sauber\n'
      '• Ladung gesichert? Zurrmittel unbeschädigt, zulässige Gesamtmasse '
      'eingehalten\n'
      '• Arbeitsplatz: Sitz und Spiegel eingestellt, Bremsprobe, '
      'Assistenzsysteme eingeschaltet\n'
      '• Im Winter: geeignete Bereifung, Frostschutz, Eiskratzer an Bord\n'
      '• Unterwegs: Gurt anlegen, StVO beachten, Abstand halten — '
      'niemals unter Alkohol/Drogen fahren.',
  'ch10_title': 'Pannen & Unfälle',
  'ch10_body': 'Grundregel: Eigenschutz vor Fremdschutz — Personen vor '
      'Sachen.\n'
      '• Panne: Warnblinker früh an, möglichst Parkplatz oder ganz rechts '
      'ran, Warnweste VOR dem Aussteigen anziehen, Warndreieck aufstellen '
      '(ca. 100 m, Autobahn 150–400 m)\n'
      '• Unfall: 1. Anhalten · 2. Absichern · 3. Erste Hilfe · 4. Notruf '
      '112 · 5. Personalien austauschen · 6. Bei Verletzten/hohem Schaden '
      'Polizei · 7. Fotos + Zeugen · 8. Arbeitgeber informieren\n'
      '• Parkendes Auto touchiert und niemand da? Mindestens 30 Minuten '
      'warten, dann Zettel reicht NICHT: unverzüglich zur Polizei — sonst '
      'Unfallflucht\n'
      '• Häufigste Verletzungen passieren übrigens nicht im Verkehr, '
      'sondern beim Aussteigen: über 50 % sind Stürze — nie abspringen, '
      'immer Aufstiege und Haltegriffe nutzen.',

  // ── Testfragen ──
  'q01': 'Was tust du als Erstes bei einem Unfall mit Verletzten?',
  'q01_a': 'Sofort den Arbeitgeber anrufen',
  'q01_b': 'Anhalten, Unfallstelle absichern (Warnweste, Warndreieck), '
      'dann Erste Hilfe und Notruf',
  'q01_c': 'Fotos machen und weiterfahren',
  'q02': 'Welche Notrufnummer wählst du bei einem Brand oder Verletzten?',
  'q02_a': '110',
  'q02_b': '112',
  'q02_c': '116117',
  'q03': 'Du touchierst ein parkendes Auto, der Halter ist nicht da. '
      'Was ist richtig?',
  'q03_a': 'Zettel mit Handynummer an die Scheibe und weiterfahren',
  'q03_b': 'Mindestens 30 Minuten warten, dann den Unfall unverzüglich '
      'der Polizei melden',
  'q03_c': 'Weiterfahren, wenn der Schaden klein aussieht',
  'q04': 'In welcher Entfernung stellst du das Warndreieck auf der '
      'Autobahn auf?',
  'q04_a': 'Direkt hinter dem Fahrzeug',
  'q04_b': 'ca. 50 m',
  'q04_c': '150 bis 400 m',
  'q05': 'Was ist die Grundregel an einer Pannen- oder Unfallstelle?',
  'q05_a': 'Sachschutz geht vor, um Kosten zu vermeiden',
  'q05_b': 'Eigenschutz vor Fremdschutz, Personenschutz vor Sachschutz',
  'q05_c': 'Erst die Ladung sichern, dann Personen helfen',
  'q06': 'Wann ziehst du bei einer Panne die Warnweste an?',
  'q06_a': 'Nur nachts',
  'q06_b': 'Nur auf der Autobahn',
  'q06_c': 'Immer — schon vor dem Aussteigen',
  'q07': 'Kannst du bestraft werden, wenn du bei der Ersten Hilfe einen '
      'Fehler machst?',
  'q07_a': 'Ja, Ersthelfer haften immer für Fehler',
  'q07_b': 'Nein — wer hilft, macht grundsätzlich nichts falsch. Strafbar '
      'macht sich nur, wer gar nicht hilft',
  'q07_c': 'Ja, deshalb sollten nur ausgebildete Ersthelfer eingreifen',
  'q08': 'Was passiert mit kleinen Verletzungen (z. B. Schnittwunde) bei '
      'der Arbeit?',
  'q08_a': 'Nichts, kleine Verletzungen sind Privatsache',
  'q08_b': 'Sofort behandeln und ins Verbandbuch eintragen',
  'q08_c': 'Nur dem Arzt melden, wenn sie sich entzündet',
  'q09': 'Wie greifst du ein Feuer mit dem Feuerlöscher an?',
  'q09_a': 'Gegen die Windrichtung, von hinten nach vorne',
  'q09_b': 'In Windrichtung, Flächenbrände von vorn, mehrere Löscher '
      'gleichzeitig',
  'q09_c': 'Von oben in die Flammenmitte, Löscher nacheinander einsetzen',
  'q10': 'Wo passieren die meisten meldepflichtigen Unfälle von Fahrern?',
  'q10_a': 'Im Straßenverkehr bei hoher Geschwindigkeit',
  'q10_b': 'Beim Aus-/Absteigen — Stürze, Stolpern, Umknicken (über 50 %)',
  'q10_c': 'Beim Betanken des Fahrzeugs',
  'q11': 'Was gehört zur Abfahrtkontrolle vor jeder Fahrt?',
  'q11_a': 'Nur ein Blick auf den Tank',
  'q11_b': 'Beleuchtung, Reifen, Bremsen, Spiegel, Ladungssicherung und '
      'Sitzeinstellung prüfen',
  'q11_c': 'Die Kontrolle ist nur nach Werkstattbesuchen nötig',
  'q12': 'Was gilt für Alkohol und Drogen im Arbeitsalltag als Fahrer?',
  'q12_a': 'Ein Bier zur Mittagspause ist erlaubt',
  'q12_b': 'Verboten — niemand darf sich oder andere durch berauschende '
      'Mittel gefährden',
  'q12_c': 'Nur während der Fahrt verboten, in der Pause erlaubt',
  'q13': 'Ein Kollege liegt nach einem Sturz auf dem Hof. Ein ausgebildeter Stationsersthelfer ist bereits bei ihm und versorgt ihn. Was gilt für dich?',
  'q13_a': 'Nichts weiter — ein Ersthelfer ist da, damit ist deine Pflicht erledigt',
  'q13_b': 'Du musst dich vergewissern, dass wirklich geholfen wird, und den Rettungsdienst alarmieren bzw. einweisen — die Alarmierungspflicht bleibt immer bestehen',
  'q13_c': 'Du musst ihn selbst versorgen, weil du ihn zuerst gesehen hast',
  'q14': 'Aus einem Behälter läuft brennende Flüssigkeit an der Außenwand herunter. Wie löschst du?',
  'q14_a': 'Von unten nach oben, damit die Pfütze zuerst aus ist',
  'q14_b': 'Von der Seite quer durch die Flammen',
  'q14_c': 'Von oben an der Austrittsstelle beginnen und nach unten arbeiten',
  'q15': 'Du steigst mit einem Paket in der linken Hand aus dem Fahrzeug. Was ist der Fehler?',
  'q15_a': 'Mit einem Paket in der Hand bleiben nur zwei Kontaktpunkte — erst absetzen, dann aussteigen',
  'q15_b': 'Kein Fehler, solange du dich mit der rechten Hand festhältst',
  'q15_c': 'Kein Fehler, solange du langsam aussteigst',
  'q16': 'Du hast einen 6-kg-Pulverlöscher benutzt, aber nur kurz gedrückt. Der Löscher fühlt sich noch voll an. Was tust du?',
  'q16_a': 'Zurück an die Wandhalterung hängen, er ist ja noch voll',
  'q16_b': 'Zur Wiederbefüllung geben und Ersatz melden — ein benutzter Löscher kommt nie zurück an die Wand',
  'q16_c': 'Im Fahrzeug mitnehmen als Reserve',
  'q17': 'Du bist seit drei Wochen auf einer Tour, die regelmäßig nicht zu schaffen ist. Was ist der richtige Weg?',
  'q17_a': 'Aushalten, das gehört zum Job',
  'q17_b': 'Einfach langsamer fahren und Stopps auslassen',
  'q17_c': 'Dem Dispatcher konkret melden, was wo nicht funktioniert — je genauer, desto eher ändert sich die Planung',
  'q18': 'Wann muss der Arbeitgeber einen Arbeitsunfall der Berufsgenossenschaft melden?',
  'q18_a': 'Bei jeder noch so kleinen Verletzung',
  'q18_b': 'Wenn die Arbeitsunfähigkeit mehr als 3 Kalendertage dauert — die Anzeige muss binnen 3 Tagen erfolgen',
  'q18_c': 'Nur bei tödlichen Unfällen',
  'q19': 'Was bedeutet Schutzklasse S3 bei Sicherheitsschuhen?',
  'q19_a': 'Wasserdicht für mindestens 60 Minuten plus durchtrittsichere und profilierte Sohle',
  'q19_b': 'Nur antistatisch mit kraftstoffbeständiger Sohle',
  'q19_c': 'Komplett aus Gummi gefertigt',
  'q20': 'Warum gilt beim Absteigen vom Fahrzeug die Regel „nur einen Punkt bewegen"?',
  'q20_a': 'Damit es schneller geht',
  'q20_b': 'Weil drei Punkte immer festen Halt behalten müssen — rutscht einer weg, hältst du dich mit den anderen',
  'q20_c': 'Weil es die Trittstufe schont',
};
