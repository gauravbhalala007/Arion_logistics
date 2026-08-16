# CoDriver – DSP Fahrsicherheitstraining

> **Zweck dieser Datei:** Vollständige Inhalts- und Umsetzungsspezifikation für ein interaktives
> Fahrsicherheits- und Arbeitsschutztraining in der Flutter-App **CoDriver**.
> Diese MD ist so aufgebaut, dass sie direkt an **Claude Code** übergeben werden kann, um die
> Schulung (Module, Quiz, Abschlusstest, Zertifikat) in Flutter umzusetzen.
>
> **Zielgruppe:** Amazon-DSP-Zusteller (Sprinter/Transporter bis 3,5 t, stop-basierte Zustellung).
> **Aufbau:** Modular & erweiterbar — neue Module können jederzeit nach demselben Schema ergänzt werden.
> **Technik-Kontext:** Flutter (CoDriver-App), Animationen/Interaktion via **Hyperframes**,
> Medien (Bilder/Video) via **Higgsfield**, Zertifikat wird im **Fahrerprofil** hinterlegt.
> **Sprache der Lerninhalte:** Deutsch (Du-Ansprache, praxisnah, kurz).

---

## 0. Wie diese Datei zu lesen ist (für Claude Code)

Jedes Modul folgt exakt demselben Schema, damit es sich generisch in Flutter rendern lässt:

1. **Modul-Metadaten** (`id`, `title`, `duration`, `goal`)
2. **Lerninhalt** (in kurzen Abschnitten / „Slides")
3. **Hyperframes-Interaktion** (welche Animation/Interaktion pro Slide)
4. **Higgsfield-Medienhinweise** (Platzhalter-Prompts für Bild/Video)
5. **Quiz** (Fragen + richtige Antwort + kurze Erklärung)

Am Ende folgen **Abschlusstest**, **Zertifikats-Spezifikation** und **Datenmodell**.

> **Wichtig:** Texte in den Modulen sind fertige Lerninhalte und können 1:1 übernommen werden.
> Platzhalter für Medien sind mit `MEDIA:` gekennzeichnet, Interaktionen mit `HYPERFRAME:`.

---

## 1. Übersicht & Lernziele

**Übergeordnetes Ziel:** Fahrer sensibilisieren, damit **Verkehrsunfälle** und **Arbeitsunfälle**
(Heben, Stolpern, Stürze, Hunde, Rangieren) aktiv vermieden werden. Sicherheit soll als Haltung
verankert werden, nicht als Regelwerk zum Auswendiglernen.

**Nach Abschluss kann der Fahrer:**

- die häufigsten Unfallursachen im Zustellalltag benennen und vermeiden,
- Fahrzeug und Ladung sicher prüfen und sichern,
- defensiv, vorausschauend und angepasst fahren,
- sicher rangieren und rückwärtsfahren,
- Arbeitsunfälle beim Aus-/Einsteigen, Heben und Zustellen vermeiden,
- sich im Notfall und nach einem Unfall richtig verhalten.

**Modulübersicht (Basis-Set, erweiterbar):**

| # | Modul | Fokus | Dauer ca. |
|---|-------|-------|-----------|
| M1 | Sicherheitskultur & Verantwortung | Haltung, Warum | 3 min |
| M2 | Fahrzeugcheck & Ladungssicherung | Vor der Tour | 4 min |
| M3 | Defensives & vorausschauendes Fahren | Während der Fahrt | 5 min |
| M4 | Rückwärtsfahren & Rangieren | Größte Schadensquelle | 4 min |
| M5 | Wetter, Sicht & schwierige Bedingungen | Anpassung | 4 min |
| M6 | Ablenkung (**Handyverbot**), Müdigkeit & Zeitdruck | Mensch | 5 min |
| M7 | **Arbeitsunfälle: Ein-/Aussteigen** (Schwerpunkt), Heben, Stürze | Körper | 7 min |
| M8 | An der Haustür: Hunde, Menschen, Umgebung | Zustellung | 4 min |
| M9 | Notfall & Verhalten nach einem Unfall | Ernstfall | 4 min |
| M10 | Zusammenfassung & Selbstverpflichtung | Transfer | 2 min |

> **Erweiterungspunkte (Extension Points):** z. B. `M11 E-Transporter & Reichweite`,
> `M12 Winterdienst`, `M13 Innenstadt & Radfahrer`, `M14 Gefahrgut-Basics`.
> Einfach nach demselben Modul-Schema anhängen und in die `modules`-Liste des Datenmodells aufnehmen.

---

## 2. Datenmodell (für Flutter / Persistenz)

Vorschlag für die Datenstruktur. Ziel: Inhalte als JSON pflegbar, Fortschritt & Zertifikat
lokal (z. B. Hive/Isar) und optional in der Cloud (z. B. Supabase) speicherbar.

```json
{
  "training": {
    "id": "dsp_fahrsicherheit_v1",
    "title": "DSP Fahrsicherheitstraining",
    "version": "1.0.0",
    "language": "de",
    "passThreshold": 0.8,
    "certificateValidityMonths": 12,
    "modules": ["m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10"]
  },
  "module": {
    "id": "m1",
    "title": "Sicherheitskultur & Verantwortung",
    "order": 1,
    "durationMinutes": 3,
    "goal": "Warum Sicherheit die eigene Entscheidung ist.",
    "slides": [
      {
        "id": "m1_s1",
        "type": "content",
        "heading": "…",
        "body": "…",
        "media": { "type": "image", "prompt": "…", "provider": "higgsfield" },
        "interaction": { "type": "fadeIn", "provider": "hyperframes", "params": {} }
      }
    ],
    "quiz": [
      {
        "id": "m1_q1",
        "question": "…",
        "options": ["A …", "B …", "C …"],
        "correctIndex": 1,
        "explanation": "…"
      }
    ]
  },
  "progress": {
    "driverId": "uuid",
    "trainingId": "dsp_fahrsicherheit_v1",
    "completedModules": ["m1", "m2"],
    "quizScores": { "m1": 1.0, "m2": 0.75 },
    "finalExam": { "score": 0.86, "passed": true, "attempts": 1 },
    "startedAt": "ISO-8601",
    "completedAt": "ISO-8601"
  },
  "certificate": {
    "id": "cert_uuid",
    "driverId": "uuid",
    "driverName": "…",
    "trainingId": "dsp_fahrsicherheit_v1",
    "trainingTitle": "DSP Fahrsicherheitstraining",
    "score": 0.86,
    "issuedAt": "ISO-8601",
    "validUntil": "ISO-8601",
    "certificateNumber": "CD-2026-000123",
    "issuer": "Arion Logistics",
    "verificationHash": "sha256(...)"
  }
}
```

**Slide-Typen (`type`):** `content` · `interactive` · `checklist` · `scenario` · `warning` · `summary`.
**Interaktions-Typen (Hyperframes, `interaction.type`):** siehe Abschnitt 3 (Hyperframes-Katalog).
**Regeln:** Modul gilt als bestanden, wenn dessen Quiz ≥ `passThreshold` erreicht.
Zertifikat wird erst nach bestandenem **Abschlusstest** erzeugt und im Fahrerprofil hinterlegt.

---

## 3. Hyperframes-Interaktionskatalog

Wiederverwendbare Interaktions-/Animationsbausteine. Claude Code kann diese als generische
Flutter-Widgets umsetzen und pro Slide über `interaction.type` referenzieren.

| `type` | Beschreibung | Sinnvoll für |
|--------|--------------|--------------|
| `fadeIn` | Inhalt sanft einblenden | Einstieg, Text-Slides |
| `staggeredList` | Punkte nacheinander erscheinen lassen | Checklisten, Merksätze |
| `tapToReveal` | Antwort/Detail erst nach Tippen zeigen | „Erst denken, dann sehen" |
| `hotspotImage` | Antippbare Punkte auf einem Bild (Gefahren finden) | Gefahrenerkennung, Fahrzeugcheck |
| `beforeAfterSlider` | Schieberegler zwischen zwei Zuständen | Richtig/Falsch, gesichert/ungesichert |
| `dragToSort` | Elemente in richtige Reihenfolge/Kategorie ziehen | Handlungsabläufe, Priorisierung |
| `scenarioBranch` | Entscheidungsszenario mit Verzweigung & Feedback | „Was tust du jetzt?" |
| `countUpStat` | Zahl hochzählen (Statistik-Effekt) | Sensibilisierung mit Fakten |
| `checklistToggle` | Interaktive Häkchen-Liste | Vor-der-Tour-Check |
| `swipeCards` | Karten wegwischen (richtig/falsch einschätzen) | Schnelle Wissensabfrage |
| `progressPulse` | Fortschritts-/Belohnungsanimation | Modulabschluss |
| `stopMotionSequence` | Bild-für-Bild-Ablauf (z. B. Rangier-Schritte) | Bewegungsabläufe |

> **Hinweis:** Jede Interaktion sollte **optional überspringbar** und **barrierearm** sein
> (Kontrast, Textalternative, keine reinen Zeitlimits). Animationen kurz halten (< 1,5 s),
> damit die Schulung sich schnell anfühlt.

---

## 4. Higgsfield-Medien-Leitfaden

Medien werden über **Higgsfield** erzeugt. In den Modulen stehen fertige Platzhalter-Prompts
(`MEDIA:`). Empfehlungen für einen einheitlichen Look:

- **Stil:** fotorealistisch, europäische Vorstadt-/Stadtumgebung, neutraler DSP-Lieferwagen
  (weißer Transporter, **kein** echtes Marken-/Amazon-Logo — generisch halten, um Markenrechte zu wahren).
- **Format:** Bilder 4:5 oder 1:1 (mobil), Kurzvideos 9:16, 3–6 s, ohne Ton nutzbar.
- **Konsistenz:** gleiche Fahrerfigur/gleicher Wagen über Module hinweg (Higgsfield Character-Sheet
  einmalig erstellen und wiederverwenden).
- **Sicherheit:** Personen mit Warnweste/festem Schuhwerk zeigen — die Medien sollen das
  richtige Verhalten vormachen.

> Konkrete Medien werden erst auf ausdrücklichen Wunsch generiert. Diese MD liefert nur die Prompts.

---

## 5. Lernmodule

### M1 – Sicherheitskultur & Verantwortung

- **id:** `m1` · **Dauer:** 3 min
- **Ziel:** Sicherheit als eigene Entscheidung verstehen — nicht als Vorschrift, sondern als Schutz für dich und andere.

**Slide 1 – Deine Tour, deine Verantwortung**
Jeden Tag legst du hunderte Kilometer zurück und hältst dutzende Male an. Jede Fahrt, jeder Stopp
ist eine Entscheidung. Die gute Nachricht: Fast jeder Unfall ist vermeidbar. Sicherheit beginnt
nicht am Steuer, sondern im Kopf — bevor du losfährst.
`HYPERFRAME: fadeIn`
`MEDIA: image — Fahrer mit Warnweste steigt morgens in weißen Lieferwagen, ruhige Vorstadtstraße, warmes Morgenlicht, fotorealistisch, 4:5`

**Slide 2 – Warum es zählt**
Zustellen gehört zu den Berufen mit den meisten Wege- und Arbeitsunfällen. Die häufigsten sind
nicht spektakulär: Auffahren im Stau, Schäden beim Rückwärtsfahren, Stürze beim Aussteigen,
verhobene Rücken. Alltäglich — und genau deshalb unterschätzt.
`HYPERFRAME: countUpStat` (z. B. „Über 70 % der Transporterschäden entstehen beim Rangieren/Rückwärtsfahren")

**Slide 3 – Die 3 Grundhaltungen**
1. **Vorausdenken** — Gefahren erkennen, bevor sie entstehen.
2. **Zeit gehört dir** — kein Paket ist einen Unfall wert. Zeitdruck ist keine Ausrede.
3. **Vorbild sein** — dein Verhalten schützt Kollegen, Fußgänger und Kinder.
`HYPERFRAME: staggeredList`

**Quiz M1**

1. Was ist die wichtigste Grundhaltung für sicheres Zustellen?
   - A) Möglichst schnell fahren, um Zeit zu sparen
   - **B) Vorausdenken und Gefahren früh erkennen** ✅
   - C) Sich auf das Können der anderen verlassen
   - *Erklärung:* Vorausschauendes Denken verhindert die meisten Unfälle, bevor sie entstehen.

2. „Ein enger Zeitplan rechtfertigt ein höheres Risiko." — Richtig oder falsch?
   - A) Richtig
   - **B) Falsch** ✅
   - *Erklärung:* Kein Paket und kein Zeitplan ist einen Unfall oder eine Verletzung wert.

---

### M2 – Fahrzeugcheck & Ladungssicherung

- **id:** `m2` · **Dauer:** 4 min
- **Ziel:** Vor der Tour Fahrzeug prüfen und Ladung so sichern, dass nichts zur Gefahr wird.

**Slide 1 – Der 2-Minuten-Rundgang**
Bevor du losfährst: einmal um den Wagen. Reifen (Sitz, Profil, sichtbare Schäden), Beleuchtung,
Scheiben und Spiegel sauber, Kennzeichen frei, keine Flüssigkeitsspuren unterm Wagen. Zwei Minuten,
die einen Ausfall oder ein Bußgeld verhindern.
`HYPERFRAME: checklistToggle`
`MEDIA: image — Nahaufnahme Hände prüfen Reifenprofil an weißem Transporter, Warnweste, fotorealistisch`

**Slide 2 – Sicht ist Sicherheit**
Spiegel richtig einstellen, bevor der Motor läuft. Verschmutzte Spiegel und Scheiben kosten
Reaktionszeit. Im Winter: Eis komplett entfernen, nicht nur ein „Guckloch".
`HYPERFRAME: hotspotImage` (Gefahren am Wagen antippen: schmutziger Spiegel, kaputtes Rücklicht, plattes Rad)

**Slide 3 – Ladung sichern**
Lose Pakete werden bei einer Vollbremsung zu Geschossen. Schwere Pakete nach unten und nach vorne
(an die Trennwand), gleichmäßig verteilen, Zurrgurte/Trennnetze nutzen. Nichts darf in den Fußraum
oder auf den Beifahrersitz rutschen können.
`HYPERFRAME: beforeAfterSlider` (Laderaum ungesichert ↔ gesichert)
`MEDIA: image — Laderaum eines Transporters, Pakete ordentlich gestapelt und mit Netz gesichert`

**Slide 4 – Ordnung im Cockpit**
Getränk, Handy, Scanner sicher ablegen. Was rollt oder fliegt, lenkt ab. Ein aufgeräumter
Fahrerplatz ist ein sicherer Fahrerplatz.
`HYPERFRAME: fadeIn`

**Quiz M2**

1. Wie sicherst du schwere Pakete am besten?
   - **A) Unten und vorne an der Trennwand, gleichmäßig verteilt** ✅
   - B) Oben auf den leichten Paketen, damit sie schnell greifbar sind
   - C) Lose im Fußraum, damit sie nicht verrutschen
   - *Erklärung:* Schwer + tief + vorne = niedriger Schwerpunkt und kein Geschoss bei Bremsung.

2. Warum ist der Rundgang vor der Tour wichtig?
   - A) Nur wegen der Optik
   - **B) Um Schäden, Ausfälle und Sichtprobleme früh zu erkennen** ✅
   - C) Ist er nicht — reine Zeitverschwendung
   - *Erklärung:* Zwei Minuten Kontrolle verhindern Pannen, Unfälle und Bußgelder.

---

### M3 – Defensives & vorausschauendes Fahren

- **id:** `m3` · **Dauer:** 5 min
- **Ziel:** Während der Fahrt Abstand, Tempo und Aufmerksamkeit so steuern, dass du immer eine Reserve hast.

**Slide 1 – Abstand ist Zeit**
Abstand ist keine Höflichkeit, sondern deine Reaktionszeit. Faustregel: mindestens 2 Sekunden
zum Vordermann, bei Nässe 3+. Wähle einen festen Punkt am Straßenrand — passiert ihn der
Vordermann, zähl „einundzwanzig, zweiundzwanzig". Bist du vorher dran, bist du zu dicht auf.
`HYPERFRAME: scenarioBranch`
`MEDIA: video — Sicht aus dem Transporter, Vordermann bremst plötzlich, 9:16, 4s`

**Slide 2 – Blick weit voraus**
Schau nicht auf die Stoßstange vor dir, sondern 12–15 Sekunden voraus. So siehst du Bremslichter,
Ampeln und Fußgänger früh und musst nicht hektisch reagieren. Der Blick lenkt das Fahrzeug.
`HYPERFRAME: hotspotImage` (Gefahren im Verkehrsbild früh erkennen: Kind am Bordstein, Radfahrer, öffnende Autotür)

**Slide 3 – Tempo anpassen**
Die erlaubte Geschwindigkeit ist ein Maximum, kein Ziel. In Wohngebieten, an Schulen, bei
parkenden Autos: langsamer als erlaubt ist oft richtig. Ein voll beladener Transporter bremst
deutlich länger als ein Pkw.
`HYPERFRAME: countUpStat` (Anhalteweg bei 30 vs. 50 km/h)

**Slide 4 – Kreuzungen & Abbiegen**
Die meisten schweren Kollisionen passieren an Kreuzungen. Vor dem Abbiegen: Schulterblick,
toter Winkel, besonders auf Radfahrer und Fußgänger achten. Lieber eine Sekunde länger schauen.
`HYPERFRAME: tapToReveal`

**Slide 5 – Der tote Winkel**
Dein Transporter hat große tote Winkel, vor allem rechts. Spiegel richtig eingestellt + aktiver
Schulterblick. Gehe nie davon aus, dass dich jemand gesehen hat.
`HYPERFRAME: beforeAfterSlider` (Sichtfeld mit/ohne Schulterblick)

**Quiz M3**

1. Wie groß sollte der Mindestabstand bei trockener Straße sein?
   - A) 0,5 Sekunden
   - **B) Mindestens 2 Sekunden (bei Nässe mehr)** ✅
   - C) Abstand ist egal, Hauptsache man bremst rechtzeitig
   - *Erklärung:* 2 Sekunden geben Reaktions- und Bremsreserve; bei Nässe 3+.

2. Wohin sollte dein Blick beim Fahren hauptsächlich gehen?
   - A) Direkt auf die Stoßstange des Vordermanns
   - **B) Weit voraus (12–15 Sekunden), um früh zu reagieren** ✅
   - C) Vor allem auf den Scanner/das Handy
   - *Erklärung:* Der weite Blick verschafft Zeit; das Fahrzeug folgt dem Blick.

3. Wo passieren besonders viele schwere Kollisionen?
   - **A) An Kreuzungen und beim Abbiegen** ✅
   - B) Auf gerader, freier Landstraße
   - C) Beim Parken
   - *Erklärung:* Kreuzungen sind Konfliktpunkte — Schulterblick und toter Winkel entscheiden.

---

### M4 – Rückwärtsfahren & Rangieren

- **id:** `m4` · **Dauer:** 4 min
- **Ziel:** Die häufigste Schadensquelle beherrschen — sicher rückwärts und in engen Situationen rangieren.

**Slide 1 – Die Nummer-1-Schadensquelle**
Die meisten Transporterschäden entstehen langsam — beim Rückwärtsfahren und Rangieren: Poller,
Mauern, andere Autos, Personen im toten Winkel. Langsam heißt nicht harmlos.
`HYPERFRAME: countUpStat`
`MEDIA: image — Transporter setzt in enger Wohnstraße zurück, Fahrer schaut über Schulter, fotorealistisch`

**Slide 2 – Erst schauen, dann setzen**
Wenn möglich: **vorwärts einparken, rückwärts nur wenn nötig.** Vor dem Zurücksetzen einmal
aussteigen und die Rückseite prüfen (Kinder, Poller, Gefälle). „Get Out And Look" — kurz GOAL.
`HYPERFRAME: stopMotionSequence` (Schritte: anhalten → aussteigen → Umfeld prüfen → langsam zurück)

**Slide 3 – Langsam, mit Blick nach hinten**
Schritttempo. Über die Schulter und in beide Spiegel schauen, nicht nur auf die Kamera verlassen.
Im Zweifel: anhalten und neu schauen. Fenster runter, um zu hören.
`HYPERFRAME: dragToSort` (richtige Reihenfolge der Rangier-Schritte sortieren)

**Slide 4 – Helfer & enge Stellen**
Ist jemand dabei, kann er einweisen — aber nur, wenn du ihn durchgehend siehst. Verlierst du den
Einweiser aus dem Blick: sofort stoppen. Enge Hofeinfahrten lieber einmal mehr rangieren als
erzwingen.
`HYPERFRAME: scenarioBranch`

**Quiz M4**

1. Was ist beim Rückwärtsfahren die sicherste Grundregel?
   - **A) Vor dem Zurücksetzen aussteigen und das Umfeld prüfen (GOAL)** ✅
   - B) Sich voll auf die Rückfahrkamera verlassen
   - C) Zügig zurücksetzen, um den Verkehr nicht aufzuhalten
   - *Erklärung:* Kurz aussteigen und schauen deckt tote Winkel, Kinder und Poller auf.

2. Was tust du, wenn du den Einweiser nicht mehr siehst?
   - A) Weiterfahren, er wird schon aufpassen
   - **B) Sofort anhalten** ✅
   - C) Schneller fahren, um die Stelle hinter dich zu bringen
   - *Erklärung:* Kein Sichtkontakt = kein sicheres Zeichen. Immer stoppen.

---

### M5 – Wetter, Sicht & schwierige Bedingungen

- **id:** `m5` · **Dauer:** 4 min
- **Ziel:** Fahrweise an Regen, Nässe, Nebel, Schnee, Dunkelheit und Hitze anpassen.

**Slide 1 – Nässe & Aquaplaning**
Bei Regen sinkt die Haftung deutlich. Tempo runter, Abstand rauf (3+ Sekunden), sanft lenken und
bremsen. Bei stehendem Wasser: nicht bremsen oder ruckartig lenken — Gas weg und Wagen laufen lassen.
`HYPERFRAME: beforeAfterSlider` (trockene ↔ nasse Fahrbahn: Bremsweg)
`MEDIA: video — Transporter fährt bei Regen, Spritzwasser, reduzierte Sicht, 9:16, 4s`

**Slide 2 – Schnee & Glätte**
Bei Glätte alles sanft: anfahren, bremsen, lenken. Größerer Abstand, früher vom Gas. Brücken und
Schattenstellen frieren zuerst. Bei Schneematsch besonders auf Radfahrer und Fußgänger achten,
die selbst rutschen können.
`HYPERFRAME: scenarioBranch`

**Slide 3 – Sicht: Nebel, Dämmerung, Dunkelheit**
Licht rechtzeitig einschalten, Nebelscheinwerfer nur bei echter Nebelsicht. Bei Nebel Tempo an die
Sichtweite anpassen: Faustregel Sichtweite in Metern ≈ Tempo in km/h. Verschmutzte Scheiben und
müde Augen verschlechtern die Nachtsicht zusätzlich.
`HYPERFRAME: hotspotImage` (bei Dunkelheit schwer sichtbare Fußgänger/Radfahrer erkennen)

**Slide 4 – Hitze & lange Touren**
Im Sommer: genug trinken, Pausen im Schatten. Ein überhitzter, dehydrierter Fahrer reagiert
langsamer. Nie ein Tier oder eine Person im aufgeheizten Wagen zurücklassen.
`HYPERFRAME: fadeIn`

**Quiz M5**

1. Wie reagierst du richtig bei stehendem Wasser (Aquaplaning-Gefahr)?
   - A) Kräftig bremsen und gegenlenken
   - **B) Gas wegnehmen, Lenkung ruhig halten, Wagen laufen lassen** ✅
   - C) Beschleunigen, um durchzukommen
   - *Erklärung:* Ruckartiges Bremsen/Lenken bei Aquaplaning führt zum Kontrollverlust.

2. Wie passt du bei Nebel dein Tempo an?
   - **A) An die Sichtweite (Sichtweite in Metern ≈ Tempo in km/h)** ✅
   - B) Immer die erlaubte Höchstgeschwindigkeit
   - C) Schneller, um schnell aus dem Nebel zu kommen
   - *Erklärung:* Du darfst nur so schnell fahren, wie du sicher anhalten kannst.

---

### M6 – Ablenkung, Müdigkeit & Zeitdruck

- **id:** `m6` · **Dauer:** 5 min
- **Ziel:** Die menschlichen Hauptursachen für Unfälle erkennen und aktiv gegensteuern — mit klarer, kompromissloser Handy-Regel.

**Slide 1 – Handy am Steuer: VERBOTEN**
Ganz klar und ohne Ausnahme: **Das Handy in der Hand ist während der Fahrt verboten.** Nicht zum
Telefonieren, nicht zum Tippen, nicht zum Nachschauen – und **auch nicht zum Musik-, Podcast- oder
Nachrichten-Auswählen.** Das ist nicht nur unsere Firmenregel, sondern Gesetz: Nach **§ 23 StVO**
darf das Gerät während der Fahrt **nicht in die Hand genommen oder gehalten** werden.¹
`HYPERFRAME: fadeIn` (Verbots-Symbol groß, klare rote Kernbotschaft)
`MEDIA: image — durchgestrichenes Handy-Symbol am Lenkrad, klare Verbotsdarstellung, fotorealistisch`

**Slide 2 – Warum? 2 Sekunden reichen für einen Unfall**
Ein Blick aufs Handy bei Tempo 50 heißt: **mehrere Sekunden „blind" fahren** – in 2 Sekunden legst
du rund **28 Meter ohne Kontrolle** zurück. Ein Kind, ein Radfahrer, ein Bremslicht – in dieser
Zeit passiert der Unfall. Kein Song, keine Nachricht, kein Stopp-Update ist das wert.
`HYPERFRAME: countUpStat` (bei 50 km/h in 2 s Blindfahrt ~28 m)

**Slide 3 – Auch Musik: nur vor der Fahrt einstellen**
Musik und Podcasts sind okay – aber **nicht mit dem Handy in der Hand.** Alles **vor Fahrtantritt**
im Stand auswählen und starten (Playlist, Lautstärke, Navi-Ziel). Läuft es einmal, wird während der
Fahrt **nichts mehr am Gerät angefasst.** **Keine Kopfhörer/Ohrhörer** – du musst Verkehr, Hupen und
Einsatzfahrzeuge hören.
`HYPERFRAME: swipeCards` (erlaubt/verboten: „Playlist vorher im Stand" ✔ / „Song wechseln während der Fahrt" ✗ verboten)

**Slide 4 – Die einzige Ausnahme: im Stand, Motor aus**
Handy, Scanner und Navi bedienst du **nur im sicheren Stand** – und rechtlich zählt „Stand" erst,
wenn der **Motor komplett aus** ist (die Start-Stopp-Automatik reicht nicht).¹ An der roten Ampel im
Rollen ist **nicht** erlaubt. Ins Fahrzeug einsteigen → Ziel & Musik einstellen → losfahren.
`HYPERFRAME: tapToReveal`
`MEDIA: image — Hand legt Handy in Halterung, bevor der Wagen anfährt, fotorealistisch`

**Slide 5 – Was es kostet (und für die Probezeit bedeutet)**
Handy in der Hand: **100 € und 1 Punkt** in Flensburg; mit Gefährdung **150 € + 2 Punkte + 1 Monat
Fahrverbot**.¹ In der **Führerschein-Probezeit** kommt ein Aufbauseminar und die Verlängerung auf
4 Jahre dazu. Für dich als Berufsfahrer heißt ein Fahrverbot: kein Job. Das Handy wegzulegen ist
die einfachste Versicherung deines Arbeitsplatzes.
`HYPERFRAME: countUpStat`

**Slide 6 – Ablenkung hat viele Formen**
Nicht nur das Handy: Essen, Trinken, Suchen nach Paketen, Gedanken beim nächsten Stopp. Wenn du
etwas erledigen musst, das die Hände oder Augen braucht — **halt kurz an.**
`HYPERFRAME: swipeCards` (Aktivität während der Fahrt: ok / nicht ok einordnen)

**Slide 7 – Müdigkeit erkennen**
Gähnen, schwere Lider, verpasste Abzweigungen, „Sekundenschlaf" — das sind Warnzeichen, keine
Kleinigkeiten. Gegen Müdigkeit hilft nur Pause und Bewegung, nicht Fenster auf oder lauter Musik.
Kurze Pausen einplanen, besonders nach dem Mittag und in den ersten/letzten Stunden.
`HYPERFRAME: tapToReveal` (Warnzeichen aufdecken)

**Slide 8 – Zeitdruck clever managen**
Zeitdruck ist real — aber Rasen und Hetze sparen kaum Zeit und kosten viel Risiko. Realistisch
takten, Rangieren und Kreuzungen nie überstürzen. Wenn der Plan nicht aufgeht: das ist kein
Sicherheitsproblem, das ist ein Planungsthema — melde es, statt es am Steuer auszugleichen.
`HYPERFRAME: scenarioBranch`

**Quelle (Modul M6):**
1. § 23 Abs. 1a StVO; Bußgeldkatalog / ADAC – Handy am Steuer: Halten/Nutzen 100 € + 1 Punkt, mit Gefährdung 150 € + 2 Punkte + 1 Monat Fahrverbot; Ausnahme nur bei ausgeschaltetem Motor; Probezeit-Folgen.

**Quiz M6** *(Schwerpunkt Handynutzung)*

1. Darfst du während der Fahrt das Handy in die Hand nehmen, um die Musik zu wechseln?
   - A) Ja, kurz ist okay
   - **B) Nein – das Handy bleibt tabu, Musik nur vorher im Stand einstellen** ✅
   - C) Nur an der roten Ampel
   - *Erklärung:* Auch fürs Musik-/Podcast-Auswählen gilt: Hände weg vom Handy während der Fahrt.

2. Wann darfst du Handy/Scanner/Navi überhaupt bedienen?
   - A) Kurz während der Fahrt, wenn frei ist
   - **B) Nur im sicheren Stand mit ausgeschaltetem Motor** ✅
   - C) An roten Ampeln im Rollen
   - *Erklärung:* Rechtlich zählt „Stand" erst bei ausgeschaltetem Motor; schon 2 s Blick weg = ~28 m Blindfahrt.

3. Sind Kopfhörer/Ohrhörer beim Fahren okay?
   - A) Ja, solange die Musik leise ist
   - **B) Nein – du musst Verkehr, Hupen und Einsatzfahrzeuge hören** ✅
   - C) Nur ein Ohr
   - *Erklärung:* Was dein Gehör für den Verkehr blockiert, ist tabu.

4. Was hilft wirklich gegen Müdigkeit?
   - A) Fenster öffnen und laute Musik
   - **B) Eine echte Pause mit Bewegung** ✅
   - C) Einfach durchhalten und schneller fahren
   - *Erklärung:* Nur Ruhe und Bewegung stellen die Aufmerksamkeit wieder her.

5. Was tust du, wenn der Zeitplan nicht realistisch ist?
   - A) Riskanter fahren, um aufzuholen
   - **B) Sicher weiterarbeiten und das Planungsproblem melden** ✅
   - C) Pausen und Kontrollen weglassen
   - *Erklärung:* Sicherheit wird nicht gegen Zeit getauscht — Planung wird angepasst.

---

### M7 – Arbeitsunfälle: Ein-/Aussteigen, Heben & Stürze

- **id:** `m7` · **Dauer:** 7 min
- **Ziel:** Verletzungen abseits des Fahrens vermeiden — mit klarem Schwerpunkt auf dem **sicheren Ein- und Aussteigen**, der häufigsten und teuersten Unfallart im Zustellalltag.

> **Schwerpunkt-Modul.** Ein- und Aussteigen wird hier bewusst ausführlich behandelt: Genau
> diese Unfälle (umknicken, abrutschen, stürzen) führen zu langen Ausfällen und sind ein
> zentraler Grund, warum Fahrer die Probezeit nicht bestehen. Wer das hier verinnerlicht,
> schützt sich – und seinen Job.

**Slide 1 – Warum das der wichtigste Handgriff des Tages ist**
Du steigst pro Tour dutzende Male ein und aus – das ist die Bewegung, die du am häufigsten machst.
Genau deshalb passieren hier die meisten Verletzungen: Umknicken, Abrutschen an der Trittkante,
Sturz aus dem Wagen, Fehltritt in den Verkehr. Rutsch-, Stolper- und Sturzunfälle verursachen bei
Berufsfahrern jedes Jahr rund **100.000 Arbeitsunfälle** mit im Schnitt **~24 Ausfalltagen** pro
Fall.¹ Die BG Verkehr warnt ausdrücklich, dass Abstürze beim Ein- und Aussteigen zu **schweren,
mitunter tödlichen Verletzungen** führen.²
`HYPERFRAME: countUpStat` (z. B. „~24 Ausfalltage pro Sturz")
`MEDIA: image — Fahrer steigt mit Drei-Punkt-Kontakt kontrolliert aus weißem Transporter, festes Schuhwerk, fotorealistisch`

**Slide 2 – Die 3-Punkt-Regel (2+1)**
Die zentrale Regel der BG Verkehr lautet: **Zwei Hände und ein Fuß sind immer in Kontakt mit dem
Fahrzeug** – „2+1".² Du hast also jederzeit drei feste Kontaktpunkte, bevor du den nächsten löst.
So kann ein einzelner Ausrutscher nie zum Sturz werden, weil dich immer noch zwei Punkte halten.
`HYPERFRAME: tapToReveal` (die drei Kontaktpunkte nacheinander aufdecken)
`MEDIA: image — Nahaufnahme: zwei Hände an Haltegriffen, ein Fuß auf der Trittstufe, Markierung der 3 Kontaktpunkte`

**Slide 3 – Richtig rein, richtig raus**
- **Einsteigen:** mit dem Gesicht **vorwärts** zum Fahrzeug.
- **Aussteigen:** **rückwärts**, mit dem Gesicht zum Fahrzeug – wie auf einer Leiter, nie mit dem
  Rücken zur Tür herausdrehen.²
- **Alle Trittstufen nutzen – keine auslassen.²**
- **Haltegriffe benutzen**, nicht die Türkante oder das Lenkrad als Notgriff.
- **Niemals springen** – der häufigste Fehler und die häufigste Ursache für umgeknickte Knöchel,
  Knie- und Rückenverletzungen.²
`HYPERFRAME: stopMotionSequence` (Aussteigen Schritt für Schritt: anhalten → Verkehr prüfen → umdrehen → 3-Punkt → absteigen)

**Slide 4 – Die typischen Fehler (und was sie kosten)**
Was zu Stürzen führt: **Springen** statt absteigen; **Hände voll** (Handy, Scanner, Kaffee,
Pakete) – dann fehlt der Griff; sich auf **Reifen oder Radnabe** als Tritt verlassen (kein sicherer
Kontaktpunkt); der **Blick aufs Handy** beim Absteigen; **nasse, vereiste oder verschmutzte**
Trittkanten und Griffe.¹ ² Merksatz: **Erst absteigen, dann greifen** – Gegenstände zuerst im
Fahrzeug ablegen oder abstellen, dann mit freien Händen aussteigen.
`HYPERFRAME: swipeCards` (Situation richtig/falsch einordnen: „springt raus mit Paket in der Hand" usw.)

**Slide 5 – Die Verkehrsseite: der unterschätzte Moment**
Bei niedrigen Sprintern/Transportern ist oft nicht die Höhe das Problem, sondern der **Schritt in
den fließenden Verkehr**. Vor dem Öffnen der Tür immer über die Schulter und in den Spiegel schauen
– besonders auf **Radfahrer und Roller**, die eng am Wagen vorbeiziehen. Wenn möglich zur
**Gehweg-/sicheren Seite** aussteigen. Tür nicht weit aufreißen, bevor du geschaut hast.
`HYPERFRAME: scenarioBranch` („Du hältst am Fahrbahnrand, ein Radfahrer nähert sich – wie steigst du aus?")
`MEDIA: video — Blick über die Schulter vor dem Türöffnen, Radfahrer zieht vorbei, 9:16, 4s`

**Slide 6 – Schuhwerk & Untergrund**
Die BG Verkehr empfiehlt **Schuhwerk, das den Fuß umschließt und rutschfest ist**.² Keine offenen
oder abgelaufenen Schuhe. Vor dem Aussteigen kurz auf den **Untergrund** achten: Bordstein,
Gefälle, Laub, Nässe, Eis. Griffe und Stufen bei Schnee/Eis **frei halten**.¹ Wenn möglich **eben
und beleuchtet** halten.
`HYPERFRAME: checklistToggle` (Vor-dem-Aussteigen-Check: Schuhe, Untergrund, Hände frei, Verkehr geprüft)

**Slide 7 – Richtig heben & tragen**
Aus den Beinen heben, nicht aus dem Rücken: nah an den Körper, Rücken gerade, in die Knie gehen.
Nicht mit Last verdrehen – mit den Füßen umtreten. Schwere/sperrige Pakete: Hilfsmittel nutzen oder
zu zweit. Sichtbehinderung durch zu hohe Stapel vermeiden.
`HYPERFRAME: beforeAfterSlider` (falsche ↔ richtige Hebetechnik)
`MEDIA: image — Person hebt Paket aus den Knien, gerader Rücken, Nahaufnahme`

**Slide 8 – Stolpern, Rutschen, Stürzen auf dem Weg**
Auf dem Weg zur Tür lauern die Gefahren: Bordsteine, Treppen, Laub, Eis, schlecht beleuchtete Wege,
Gartenschläuche. Festes Schuhwerk. Bei Glätte kleine Schritte. Blick auch mal auf den Weg, nicht
nur aufs Paket oder Handy. Nachts Taschenlampe/Handylicht für den Weg.
`HYPERFRAME: hotspotImage` (Stolperfallen auf einem Gehweg finden)

**Slide 9 – Kleine Wehwehchen ernst nehmen**
Ein verhobener Rücken oder ein umgeknickter Fuß wird schlimmer, wenn man weitermacht. Melde
Beschwerden früh – das ist Stärke, nicht Schwäche, und verhindert lange Ausfälle.
`HYPERFRAME: tapToReveal`

**Quellen (Modul M7):**
1. Flotten-/Arbeitsschutzquellen zu Slips, Trips & Falls bei Berufsfahrern (ca. 100.000 Unfälle/Jahr, ~24 Ausfalltage): Penske Truck Leasing – „Three Points of Contact"; Accident Fund; ICW Group.
2. BG Verkehr – „Ein- und Aussteigen" (Drei-Punkt-Kontakt „2+1", vorwärts ein-/rückwärts aussteigen, alle Trittstufen, Haltegriffe, nicht springen, umschließendes rutschfestes Schuhwerk).

**Quiz M7** *(Wissensnachweis – Schwerpunkt Ein-/Aussteigen)*

1. Wie lautet die 3-Punkt-Regel der BG Verkehr beim Ein-/Aussteigen?
   - A) Ein Hand und ein Fuß reichen
   - **B) Zwei Hände und ein Fuß immer am Fahrzeug („2+1")** ✅
   - C) Beide Füße zuerst auf den Boden, dann loslassen
   - *Erklärung:* Drei feste Kontaktpunkte halten dich, selbst wenn ein Punkt abrutscht.

2. Wie steigst du richtig aus dem Transporter?
   - A) Vorwärts, mit dem Rücken zur Tür, und abspringen
   - **B) Rückwärts, mit dem Gesicht zum Fahrzeug, wie auf einer Leiter** ✅
   - C) Egal, Hauptsache schnell
   - *Erklärung:* Rückwärts mit Blick zum Fahrzeug ermöglicht sicheren 3-Punkt-Kontakt; springen verursacht die meisten Verletzungen.

3. Was ist der häufigste Fehler beim Aussteigen?
   - **A) Aus dem Wagen springen** ✅
   - B) Zu langsam absteigen
   - C) Beide Hände am Haltegriff
   - *Erklärung:* Springen belastet Knöchel, Knie und Rücken – die typische Ausfallursache.

4. Du hast Handy und ein Paket in den Händen und willst aussteigen. Was tust du?
   - A) So aussteigen, geht schon
   - **B) Erst im Fahrzeug ablegen, dann mit freien Händen und 3-Punkt-Kontakt aussteigen** ✅
   - C) Das Paket zwischen die Zähne nehmen
   - *Erklärung:* Volle Hände verhindern den Halt an den Griffen – erst ablegen, dann aussteigen.

5. Worauf achtest du zusätzlich, bevor du die Fahrertür öffnest?
   - **A) Über die Schulter/in den Spiegel auf Radfahrer und Verkehr schauen** ✅
   - B) Nur nach vorne schauen
   - C) Tür weit aufreißen, damit man gesehen wird
   - *Erklärung:* Der Schritt in den fließenden Verkehr ist bei Transportern die unterschätzte Gefahr.

6. Welches Schuhwerk empfiehlt die BG Verkehr fürs Ein-/Aussteigen?
   - A) Leichte, offene Schuhe für schnelles Anziehen
   - **B) Den Fuß umschließendes, rutschfestes Schuhwerk** ✅
   - C) Egal, solange sie bequem sind
   - *Erklärung:* Fester, rutschfester Halt verhindert Umknicken und Abrutschen an der Trittkante.

7. Wie hebst du ein schweres Paket richtig?
   - **A) Aus den Beinen, Rücken gerade, Last nah am Körper** ✅
   - B) Mit rundem Rücken und gestreckten Armen
   - C) Schnell und mit Schwung aus der Drehung
   - *Erklärung:* Heben aus den Beinen schützt die Wirbelsäule; nie mit Last verdrehen.

---

### M8 – An der Haustür: Hunde, Menschen & Umgebung

- **id:** `m8` · **Dauer:** 4 min
- **Ziel:** Am Zustellpunkt sicher agieren — mit Tieren, Menschen und der Umgebung.

**Slide 1 – Hunde richtig einschätzen**
Hunde sind eine der häufigsten Verletzungsursachen bei Zustellern. Grundregeln: nicht direkt in
die Augen starren, nicht wegrennen, ruhig bleiben, dem Hund die Seite zuwenden. Das Paket kann als
Barriere dienen. Bei aggressivem Hund: nicht das Grundstück betreten, Zustellung dokumentieren und
sicher zurückziehen.
`HYPERFRAME: scenarioBranch` („Bellender Hund am Gartentor — was tust du?")
`MEDIA: image — Zusteller bleibt ruhig an einem Gartentor stehen, Hund im Hintergrund, fotorealistisch`

**Slide 2 – Sichere Wege am Grundstück**
Ausgewiesene Wege nutzen, nicht über nasse Rasen, lose Platten oder steile Böschungen abkürzen.
Auf Stufen, Treppen und Handläufe achten. Schlecht einsehbare Ecken langsam angehen.
`HYPERFRAME: hotspotImage`

**Slide 3 – Umgang mit Menschen**
Freundlich, ruhig, professionell — auch bei Stress oder Konflikten. Deeskalieren statt streiten.
Wahre Distanz, wenn sich jemand aggressiv verhält, und brich die Zustellung im Zweifel ab. Deine
Sicherheit geht vor jeder Zustellung.
`HYPERFRAME: tapToReveal`

**Slide 4 – Der Wagen als sicherer Ort**
Wagen beim Verlassen absichern: Motor aus, Schlüssel mit, abschließen (besonders in belebten
Gegenden). Nie mit laufendem Motor und offener Tür weit weggehen — Diebstahl- und Rollgefahr.
An Gefällstrecken Handbremse fest und Räder einschlagen.
`HYPERFRAME: checklistToggle`

**Quiz M8**

1. Wie verhältst du dich bei einem aggressiven Hund?
   - A) Wegrennen und laut werden
   - **B) Ruhig bleiben, nicht anstarren, Grundstück nicht betreten, sicher zurückziehen** ✅
   - C) Den Hund verscheuchen und trotzdem zustellen
   - *Erklärung:* Ruhe und Distanz verhindern Bisse; keine Zustellung ist ein Risiko wert.

2. Was gilt, wenn du den Wagen kurz verlässt?
   - A) Motor läuft, Tür offen — geht schneller
   - **B) Motor aus, Schlüssel mit, abschließen** ✅
   - C) Egal, dauert ja nur kurz
   - *Erklärung:* Offener, laufender Wagen ist Diebstahl- und Rollgefahr.

---

### M9 – Notfall & Verhalten nach einem Unfall

- **id:** `m9` · **Dauer:** 4 min
- **Ziel:** Im Ernstfall ruhig, richtig und rechtssicher handeln.

**Slide 1 – Erst absichern**
Nach einem Unfall oder bei einer Panne: **Absichern – Melden – Helfen.** Warnblinker an, Warnweste
anlegen, Warndreieck in ausreichendem Abstand aufstellen (innerorts ~50 m, außerorts ~100 m,
Autobahn ~150–200 m). Erst die Unfallstelle sicher machen, dann alles Weitere.
`HYPERFRAME: dragToSort` (richtige Reihenfolge: Warnblinker → Weste → Dreieck → Notruf → Erste Hilfe)
`MEDIA: image — Fahrer stellt Warndreieck auf, Warnweste, Warnblinker am Transporter`

**Slide 2 – Notruf & Erste Hilfe**
Bei Verletzten: **112** rufen. Klar melden: Wo? Was? Wie viele Verletzte? Welche Verletzungen?
Warten auf Rückfragen. Erste Hilfe leisten, soweit du kannst — auch einfache Maßnahmen (ansprechen,
Blutung stillen, wärmen) helfen. Unterlassene Hilfeleistung ist strafbar.
`HYPERFRAME: tapToReveal` (Notruf-Fragen aufdecken)

**Slide 3 – Nach einem Blechschaden**
Auch bei kleinen Schäden (Rangierdelle, Spiegel): anhalten, Stelle absichern, Daten austauschen
bzw. dokumentieren (Fotos, Ort, Zeit, Beteiligte). Nie einfach weiterfahren — das kann Fahrerflucht
sein. Schaden immer melden, auch wenn er klein wirkt.
`HYPERFRAME: checklistToggle`

**Slide 4 – Ruhe bewahren & melden**
Durchatmen, Situation ordnen, Disponent/Betrieb informieren. Ehrliche, schnelle Meldung ist immer
besser als Vertuschen. Aus jedem Vorfall lernen wir für die nächste Tour.
`HYPERFRAME: fadeIn`

**Quiz M9**

1. In welcher Reihenfolge handelst du an einer Unfallstelle?
   - **A) Absichern (Warnblinker, Weste, Dreieck) → Notruf → Erste Hilfe** ✅
   - B) Erst Fotos für die Versicherung machen
   - C) Sofort weiterfahren, um den Verkehr nicht zu stören
   - *Erklärung:* Erst die Stelle sichern, damit keine weiteren Unfälle passieren.

2. Was gilt bei einem kleinen Rangierschaden an einem fremden Auto?
   - A) Weiterfahren, war ja nur eine Delle
   - **B) Anhalten, dokumentieren, Daten austauschen/melden** ✅
   - C) Nur melden, wenn jemand zugeschaut hat
   - *Erklärung:* Wegfahren kann Fahrerflucht sein; jeder Schaden wird gemeldet.

3. Welche Nummer rufst du bei Verletzten?
   - **A) 112** ✅
   - B) 110 nur bei Blechschaden
   - C) Zuerst den Disponenten, dann irgendwann den Notruf
   - *Erklärung:* Bei Verletzten hat der Notruf 112 absolute Priorität.

---

### M10 – Zusammenfassung & Selbstverpflichtung

- **id:** `m10` · **Dauer:** 2 min
- **Ziel:** Das Gelernte verankern und in eine persönliche Haltung überführen.

**Slide 1 – Deine 7 Kernregeln**
1. Vorausdenken schlägt schnell reagieren.
2. Abstand & angepasstes Tempo geben dir immer eine Reserve.
3. Beim Rückwärtsfahren: aussteigen, schauen, langsam.
4. Handy & Ablenkung nur im Stand.
5. Müdigkeit und Zeitdruck ernst nehmen — Sicherheit vor Plan.
6. Richtig aussteigen, heben, gehen — dein Körper ist dein Werkzeug.
7. Im Notfall: absichern, melden, helfen.
`HYPERFRAME: staggeredList`

**Slide 2 – Deine Selbstverpflichtung**
„Ich fahre so, dass alle sicher nach Hause kommen — auch ich." Sicherheit ist kein Regelbuch,
sondern deine tägliche Entscheidung.
`HYPERFRAME: progressPulse` (Abschluss-Belohnung, überleitet zum Abschlusstest)
`MEDIA: image — Fahrer am Ende des Tages, steigt zufrieden aus dem Wagen, Abendlicht, fotorealistisch`

**Quiz M10** *(leichte Wiederholung, optional)*

1. Was fasst die Haltung dieser Schulung am besten zusammen?
   - **A) Sicherheit ist meine tägliche Entscheidung, damit alle sicher nach Hause kommen** ✅
   - B) Regeln gelten nur, wenn kontrolliert wird
   - C) Hauptsache schnell fertig
   - *Erklärung:* Sicherheit ist eine Haltung, keine Pflichtübung.

---

## 6. Abschlusstest & Bestehensgrenze

**Regeln:**

- Der Abschlusstest wird erst freigeschaltet, wenn **alle Pflichtmodule** durchlaufen sind.
- **Bestehensgrenze:** `passThreshold = 0,8` (mindestens **80 %** richtig).
- **Fragenzahl:** 12 (Auswahl aus dem Pool; Reihenfolge & Antwortoptionen mischen). **Die beiden
  Ein-/Aussteigen-Fragen (Nr. 10 & 11) sind Pflicht in jedem Testdurchlauf** – sie sind das
  Kernanliegen und dürfen nicht „herausgemischt" werden. Ebenso ist die **Handy-Frage (Nr. 8)**
  in jedem Durchlauf Pflicht.
- **Wiederholung:** Bei Nichtbestehen beliebig oft wiederholbar; empfohlen: nach Fehlversuch die
  betroffenen Module noch einmal anzeigen. `attempts` mitzählen.
- **Zertifikat:** wird **nur bei Bestehen** erzeugt (siehe Abschnitt 7).

**Fragenpool Abschlusstest (14, davon 12 pro Durchlauf; Nr. 8, 10 & 11 immer dabei):**

1. Wichtigste Grundhaltung für sicheres Zustellen? → *Vorausdenken / Gefahren früh erkennen.*
2. „Zeitdruck rechtfertigt höheres Risiko." → *Falsch.*
3. Schwere Pakete richtig sichern? → *Unten & vorne an der Trennwand, gleichmäßig verteilt.*
4. Mindestabstand bei trockener Straße? → *Mind. 2 Sekunden (bei Nässe mehr).*
5. Wohin geht der Blick beim Fahren? → *Weit voraus (12–15 Sekunden).*
6. Sicherste Grundregel beim Rückwärtsfahren? → *Aussteigen und Umfeld prüfen (GOAL).*
7. Reaktion bei Aquaplaning? → *Gas weg, Lenkung ruhig, Wagen laufen lassen.*
8. **[Pflicht]** Handy während der Fahrt – auch zum Musikwechseln? → *Verboten; Bedienung nur im Stand bei ausgeschaltetem Motor, Musik vorher einstellen, keine Kopfhörer.*
9. Was hilft gegen Müdigkeit? → *Echte Pause mit Bewegung.*
10. **[Pflicht]** 3-Punkt-Regel beim Ein-/Aussteigen? → *Zwei Hände und ein Fuß immer am Fahrzeug („2+1").*
11. **[Pflicht]** Wie steigt man richtig aus? → *Rückwärts, Gesicht zum Fahrzeug, nicht springen, alle Trittstufen.*
12. Richtige Hebetechnik? → *Aus den Beinen, Rücken gerade, Last nah am Körper.*
13. Verhalten bei aggressivem Hund? → *Ruhig bleiben, Distanz, Grundstück nicht betreten.*
14. Reihenfolge an der Unfallstelle? → *Absichern → Notruf → Erste Hilfe.*

> **Umsetzungshinweis:** Fragen als gemeinsamer Pool mit `moduleRef` ausliefern, damit der Test
> bei Wiederholungen variieren kann. Punkte: 1 Punkt/Frage, `score = richtig / gesamt`.

---

## 7. Zertifikats-Spezifikation

Nach bestandenem Abschlusstest erzeugt die App ein Zertifikat und legt es im **Fahrerprofil** ab.

**Pflichtfelder:**

| Feld | Beschreibung | Beispiel |
|------|--------------|----------|
| `certificateNumber` | Eindeutige, lesbare Nummer | `CD-2026-000123` |
| `driverName` | Voller Name des Fahrers | `Max Mustermann` |
| `driverId` | Interne Fahrer-ID (UUID) | `a1b2c3…` |
| `trainingTitle` | Titel der Schulung | `DSP Fahrsicherheitstraining` |
| `trainingVersion` | Version der Inhalte | `1.0.0` |
| `score` | Erreichtes Ergebnis | `0.92` (= 92 %) |
| `issuedAt` | Ausstellungsdatum (ISO-8601) | `2026-08-05T10:12:00Z` |
| `validUntil` | Gültig bis (Standard: +12 Monate) | `2027-08-05` |
| `issuer` | Ausstellende Firma | `Arion Logistics` |
| `verificationHash` | SHA-256 über die Felder (Fälschungsschutz) | `9f8e…` |

**Verhalten:**

- **Gültigkeit:** `certificateValidityMonths = 12`. Nach Ablauf gilt die Schulung als „fällig zur
  Auffrischung"; App kann eine Erinnerung anzeigen.
- **Anzeige im Profil:** Status-Badge (`Gültig` / `Läuft bald ab` / `Abgelaufen`), Ausstelldatum,
  Ablaufdatum, Ergebnis, Zertifikatsnummer.
- **Export:** Als PDF generierbar (Name, Nummer, Datum, Gültigkeit, Ergebnis, optional QR-Code mit
  `verificationHash` zur Verifikation).
- **Persistenz:** lokal im Fahrerprofil + optional serverseitig (z. B. Supabase) für Nachweis/Audit.
- **Eindeutigkeit:** `certificateNumber` fortlaufend, Schema `CD-{Jahr}-{6-stellig laufend}`.

**Vorschlag Zertifikats-Layout (PDF/Screen):**

```
────────────────────────────────────────
        ZERTIFIKAT — FAHRSICHERHEIT
        DSP Fahrsicherheitstraining
────────────────────────────────────────
  Hiermit wird bestätigt, dass

        {driverName}

  das DSP Fahrsicherheitstraining
  erfolgreich abgeschlossen hat.

  Ergebnis:        {score in %}
  Ausgestellt am:  {issuedAt}
  Gültig bis:      {validUntil}
  Zertifikat-Nr.:  {certificateNumber}

  Ausgestellt von: {issuer}
  [QR-Code: verificationHash]
────────────────────────────────────────
```

---

## 8. App-Flow & Integrationshinweise (für Claude Code)

**Empfohlener Ablauf in CoDriver:**

1. **Start/Onboarding-Screen** → Ziel & Dauer, Fortschritt sichtbar.
2. **Modulliste** → Module nacheinander (oder frei) mit Fortschritts-/Abschluss-Status.
3. **Modul-Screen** → Slides (Content/Interaktion) → Modul-Quiz → Ergebnis → nächstes Modul.
4. **Abschlusstest** → freigeschaltet nach allen Modulen → Ergebnis vs. `passThreshold`.
5. **Bestanden** → Zertifikat generieren → im Fahrerprofil hinterlegen → optional PDF-Export.
6. **Nicht bestanden** → betroffene Module empfehlen → Test wiederholbar.

**Technische Hinweise:**

- Inhalte als **JSON** (aus dieser MD ableitbar) laden, damit Texte/Module ohne App-Update pflegbar sind.
- **Hyperframes** für Slide-Animationen/Interaktionen (Katalog in Abschnitt 3) als
  wiederverwendbare Widgets kapseln; jede Interaktion überspringbar & barrierearm.
- **Higgsfield**-Medien vorab generieren und als Assets/CDN einbinden; `MEDIA:`-Prompts sind die Vorlage.
- **Fortschritt & Zertifikat** lokal (Hive/Isar) speichern, optional Sync (Supabase) für Nachweis.
- **Barrierefreiheit:** ausreichender Kontrast, Textalternativen zu Medien, keine reinen Zeitlimits,
  Schrift skalierbar.
- **Mehrsprachigkeit:** Struktur ist i18n-fähig — `language`-Feld + separate Textressourcen erlauben
  spätere Übersetzungen.

---

## 9. Quellen (belegte Fakten)

Die in den Modulen mit Fußnoten gekennzeichneten Aussagen (v. a. M7, Ein-/Aussteigen) stützen sich auf:

- **BG Verkehr – „Ein- und Aussteigen"** (Berufsgenossenschaft Verkehrswirtschaft Post-Logistik Telekommunikation): Drei-Punkt-Kontakt „2+1" (zwei Hände + ein Fuß), vorwärts einsteigen / rückwärts aussteigen, alle Trittstufen nutzen, Haltegriffe verwenden, nicht springen, umschließendes rutschfestes Schuhwerk. https://www.bg-verkehr.de/arbeitssicherheit-gesundheit/branchen/gueterkraftverkehr/rund-ums-fahren/ein-und-aussteigen
- **BG Verkehr – „Tipps gegen Abstürze beim Ein- und Aussteigen"** (Pressemitteilung, Warnung vor schweren/tödlichen Verletzungen). https://www.bg-verkehr.de/presse/pressemitteilungen/archiv/bg-verkehr-gibt-tipps-gegen-abstuerze-beim-ein-und-aussteigen
- **Penske Truck Leasing – „Watch Your Step! Know the Three Points of Contact"** (Technik, typische Fehler, ~100.000 Unfälle/Jahr, ~24 Ausfalltage). https://www.pensketruckleasing.com/resources/resource-library/safety/three-points-of-contact/
- **Accident Fund / ICW Group** – Driver Safety: 3 Points of Contact (Bestätigung der Technik & Prävention). https://www.accidentfund.com/resources/be-safe-when-entering-and-exiting-trucks-with-three-points-of-contact/ · https://www.icwgroup.com/articles-insights/work-comp/driver-safety-3-points-of-contact/
- **§ 23 Abs. 1a StVO** & **ADAC – „Handy am Steuer: Bußgelder und Strafen"** (Halten/Nutzen des Geräts während der Fahrt verboten; 100 € + 1 Punkt, mit Gefährdung 150 € + 2 Punkte + 1 Monat Fahrverbot; Ausnahme nur bei ausgeschaltetem Motor; Probezeit-Folgen). https://www.adac.de/verkehr/recht/verkehrsvorschriften-deutschland/handyverstoss/

> **Hinweis:** Konkrete Zahlen (z. B. ~100.000 Unfälle/Jahr, ~24 Ausfalltage) stammen aus
> US-/internationalen Flotten- und Versicherungsquellen und dienen der Sensibilisierung. Für eine
> rechtssichere Unterweisung nach deutschem Arbeitsschutz sind die **BG-Verkehr-Vorgaben** maßgeblich.

---

## 10. Änderungs-/Versionshinweise

- **v1.2.0** — M6 mit **striktem Handyverbot** verschärft (8 Slides): Handy in der Hand komplett
  verboten – auch fürs Musik-/Podcast-Auswählen; Musik nur vor der Fahrt im Stand einstellen; keine
  Kopfhörer; Rechtsgrundlage § 23 StVO inkl. Bußgeldern & Probezeit-Folgen belegt. Quiz auf 5 Fragen
  erweitert (3 zum Handy). Abschlusstest-Handyfrage jetzt Pflicht in jedem Durchlauf.
- **v1.1.0** — M7 „Ein-/Aussteigen" zum **Schwerpunktmodul** ausgebaut (9 Slides, 3-Punkt-Standard
  nach BG Verkehr, belegte Quellen). Abschlusstest-Pool auf 14 Fragen erweitert; die beiden
  Ein-/Aussteigen-Fragen sind Pflicht in jedem Durchlauf. Quellenverzeichnis ergänzt.
- **v1.0.0** — Basis-Set M1–M10, Abschlusstest (80 % Grenze), Zertifikats-Spec, Hyperframes-Katalog,
  Higgsfield-Medienhinweise. Modular erweiterbar über Extension Points.

*Diese Datei ist die inhaltliche Grundlage. Medien werden separat via Higgsfield erzeugt,
die App-Umsetzung erfolgt in Flutter (CoDriver) mit Hyperframes.*
