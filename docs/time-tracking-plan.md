# CoDriver Zeiterfassung — Master-Plan

Stand: 13. Mai 2026
Status: **Planung** (noch nicht implementiert)
Priorität: **#1 Feature**

---

## 0a. Aktivierung & Pricing (Add-On)

Das Zeiterfassungs-Modul ist ein **separates Add-On** zum CoDriver-Pro-Abo:

- **Preis (TBD)**: zusätzliches monatliches Pricing pro Station, separat
  abgebucht über Stripe-Subscription-Item
- **Default**: deaktiviert für alle Konten, auch nach dem 30-Tage-Trial
- **Sichtbarkeit**: Side-Menu-Punkt „Zeiterfassung" erscheint nur für
  Accounts mit `addons.timeTracking == true`
- **Anfangs-Phase**: nur für **admin@arion-logistics.de** (Super-Admin)
  freigeschaltet — kein anderer Account sieht das Modul. Wenn das
  Feature stabil ist, schalten wir gezielt einzelne Bestandskunden frei
  und bieten es schließlich als zubuchbares Add-On im Billing-Bereich an.

### Technisch
Im `users/{adminUid}` Doc:
```jsonc
{
  "addons": {
    "timeTracking": false,                  // Default false
    "timeTrackingActivatedAt": null,
    "timeTrackingStripeItemId": null         // Sub-Item für separate Abrechnung
  }
}
```

Side-Menu-Gating in `app_side_menu.dart` ähnlich wie aktuell der
„Styleguide"-Eintrag, der nur für `admin@arion-logistics.de` sichtbar
ist — Phase 1 verwendet dieselbe Email-Whitelist, später wird der
Gate auf das Firestore-Feld `addons.timeTracking` umgestellt.

### Rollout-Schritte für die Add-On-Logik
1. **Phase 0**: Owner-Email-Whitelist (`admin@arion-logistics.de`) →
   alles wird unter diesem Account entwickelt und getestet
2. **Phase 1 (intern)**: `addons.timeTracking` Boolean im Firestore,
   manuell durch Super-Admin gesetzt — Pilot-Kunden bekommen Zugriff
3. **Phase 2 (öffentlich)**: Im Billing-Tab ein neuer Bereich
   „Add-Ons" mit dem Zeiterfassungs-Modul als Toggle, der die
   Stripe-Subscription mit einem zusätzlichen Subscription-Item
   erweitert
4. **Phase 3 (Sales)**: Eigene Landing-Sektion mit Demo, Pricing,
   „Zur Aktivierung anfragen"-CTA

---

## 0. Anspruch & Rahmen

Die Zeiterfassung ist das **rechtlich anspruchsvollste** Feature im
Produkt. Sie muss:

1. **EU-konform**: ArbZG, BetrVG §87, EU-Arbeitszeitrichtlinie 2003/88/EG
2. **DSGVO-konform**: Art. 5, 6, 25, 32, 35 (Datenminimierung, Privacy
   by Design, DSFA bei Geo-Tracking)
3. **EuGH-Urteil 2019** („Stechuhr-Urteil", C-55/18) erfüllen:
   objektives, verlässliches und zugängliches System
4. **Amazon-DSP-konform**: Lenk-/Arbeitszeiten der EU-Fahrpersonalverordnung
   (VO 561/2006), pre-/post-trip Zeiten, Schichtlängen-Grenzen
5. **Direkt anbinden** an SD Worx + ADP — kein manueller CSV-Schritt
6. **Intuitive UX**: Driver brauchen 2-3 Taps für Schichtanfang/-ende

---

## 1. Architektur-Überblick

```
┌─────────────────────────┐         ┌──────────────────────────┐
│  Driver-App (Flutter)   │         │  Admin/Dispatcher (Web)  │
│  • Clock-in/out         │         │  • Live-Board            │
│  • Pause start/end      │         │  • Zeitkonto-View        │
│  • GPS Permission       │         │  • Korrektur-Genehmigung │
│  • Korrektur beantragen │         │  • Compliance-Reports    │
└────────────┬────────────┘         │  • Payroll-Export        │
             │                      └──────────────┬───────────┘
             │                                     │
             │      Firestore + Cloud Functions    │
             └─────────────┬───────────────────────┘
                           │
                           ▼
       ┌──────────────────────────────────────────────┐
       │ Cloud Functions (TypeScript)                 │
       │ • clockIn / clockOut (server time stamp)     │
       │ • validateGeofence                           │
       │ • computeDailyAggregate (Trigger)            │
       │ • applyHolidays (Daily Schedule)             │
       │ • complianceChecker (Trigger)                │
       │ • exportToPayroll (callable)                 │
       │ • syncSdWorx / syncAdp (Webhooks + Polling)  │
       └──────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────────┐
        ▼                  ▼                      ▼
  ┌──────────┐      ┌─────────────┐       ┌──────────────┐
  │ SD Worx  │      │ ADP         │       │ Holiday API  │
  │ Connect  │      │ Workforce   │       │ feiertage-api│
  │ REST     │      │ Now (OAuth2)│       │ .de          │
  └──────────┘      └─────────────┘       └──────────────┘
```

---

## 2. Datenmodell (Firestore)

### `users/{adminUid}/drivers/{driverId}` — Erweiterung
```jsonc
{
  // … bestehende Felder …

  "employment": {
    "weeklyContractHours": 40,        // Soll-Stunden / Woche
    "dailyContractHours": 8,          // Default-Soll / Tag (frei werktags)
    "workingDays": ["MO","TU","WE","TH","FR"],
    "vacationDaysPerYear": 28,
    "vacationCarryFromPrevYear": 4,
    "contractStart": <Timestamp>,
    "contractEnd": null,
    "bundesland": "BE",                // ISO-Code, für Feiertage
    "address": { "postal_code": "10115", "city": "Berlin" },
    // Lohn-Dienstleister-Mapping
    "payroll": {
      "provider": "sd_worx | adp | none",
      "externalEmployeeId": "EMP-12345",
      "costCenter": "DBY5",
      "lastSyncedAt": <Timestamp>
    }
  }
}
```

### Neue Subcollections

#### `users/{adminUid}/drivers/{driverId}/time_entries/{entryId}`
Eine Zeile pro Schicht-Ereignis. Server-time-stamp, niemals Client.

```jsonc
{
  "type": "shift_start | pause_start | pause_end | shift_end",
  "ts": <Timestamp>,                  // Server-Timestamp, set by Cloud Function
  "clientReportedAt": <Timestamp>,    // Reference, falls Server-Time abweicht
  "stationCode": "DBY5",
  "location": {
    "geofenceId": "DBY5_main",
    "geofenceMatched": true,
    "accuracy": 12.4,                  // Meter
    "lat": null, "lng": null           // Nicht gespeichert! Nur Geofence-Match
  },
  "deviceInfo": {
    "platform": "ios | android | web",
    "appVersion": "1.2.3",
    "ipHash": "sha256-xxx"             // Hash, nicht IP-Klartext
  },
  "shiftId": "<uuid>",                 // Verkettet zur Schicht
  "correction": null,                  // Falls aus Korrektur-Antrag entstanden
  "createdAt": <Timestamp>
}
```

#### `users/{adminUid}/drivers/{driverId}/shifts/{shiftId}`
Aggregierte Schicht (entsteht durch Cloud Function aus den Entries).

```jsonc
{
  "shiftDate": "2026-05-13",          // ISO-Datum (Schichtdatum, nicht Wochentag!)
  "startTs": <Timestamp>,
  "endTs": <Timestamp>,
  "totalDuration": 28800,             // Sekunden
  "pauseDuration": 1800,
  "workDuration": 27000,
  "pauses": [
    { "start": <Timestamp>, "end": <Timestamp>, "durationSec": 1800 }
  ],
  "complianceFlags": {
    "minBreakMet": true,              // ≥30 min bei >6h, ≥45 min bei >9h
    "maxShiftLengthOk": true,         // ≤10h Schicht
    "restPeriodToPreviousShiftOk": true, // ≥11h Ruhezeit
    "warnings": []
  },
  "isOpen": false,                    // true = Schicht läuft noch
  "stationCode": "DBY5",
  "routeId": "CA_A151",               // Verknüpft mit Waveplan
  "approvedBy": null,                 // Admin-UID falls manuell genehmigt
  "approvedAt": null,
  "createdAt": <Timestamp>
}
```

#### `users/{adminUid}/drivers/{driverId}/time_account/{yearMonth}`
Monatliche Aggregation, eine Doc pro `2026-05`.

```jsonc
{
  "month": "2026-05",
  "soll": 168.00,                     // Sollstunden
  "ist": 172.50,                      // Iststunden
  "saldo": 4.50,                      // Überstunden (rolling)
  "paid": 0,                          // Ausgezahlt
  "open": 4.50,                       // Noch offene Überstunden
  "vacationTakenDays": 2,
  "sickDays": 0,
  "holidayDays": 1,
  "workingDays": 21,
  "lastRecomputedAt": <Timestamp>
}
```

#### `users/{adminUid}/drivers/{driverId}/correction_requests/{reqId}`
```jsonc
{
  "type": "missing_entry | wrong_time | forgot_pause | other",
  "shiftDate": "2026-05-13",
  "requestedChanges": {
    "newStart": <Timestamp>,
    "newEnd": <Timestamp>,
    "pauses": [...]
  },
  "reason": "Habe vergessen einzustempeln",
  "status": "pending | approved | rejected",
  "submittedAt": <Timestamp>,
  "decidedAt": null,
  "decidedBy": null,
  "comment": null
}
```

#### `users/{adminUid}/stations/{stationCode}` — Erweiterung
```jsonc
{
  "code": "DBY5",
  "label": "Berlin DBY5",
  "geofences": [
    {
      "id": "DBY5_main",
      "centerLat": 52.5,
      "centerLng": 13.4,
      "radiusMeters": 200
    }
  ],
  "bundesland": "BE",                 // Default für Driver dieser Station
  "timezone": "Europe/Berlin"
}
```

#### `users/{adminUid}/holidays/{date}` (cached)
```jsonc
{
  "date": "2026-12-25",
  "name": "1. Weihnachtstag",
  "type": "national | state",
  "applicableStates": ["DE_ALL"]      // oder ["BY","BW",...]
}
```

---

## 3. Driver-UX

### 3.1 Stempel-Hauptbildschirm (Mobile)

```
┌─────────────────────────────────────┐
│ ☀ Donnerstag, 13. Mai               │
│                                     │
│   ┌─ STATUS ────────────────────┐   │
│   │ Du bist nicht eingestempelt │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─ STANDORT ──────────────────┐   │
│   │ ✓ DBY5 Berlin               │   │
│   │   ±12 m, GPS aktiv          │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─ SCHICHTPLAN ───────────────┐   │
│   │ 11:00 – 20:00 (geplant)     │   │
│   │ Wave A · Route CA_A151      │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌──────────────────────────┐      │
│   │  ▶  SCHICHT STARTEN      │      │
│   └──────────────────────────┘      │
│                                     │
│ ─────────────────────────────────── │
│ Heute      Diese Woche      Saldo   │
│ 0:00 / 8h  18:30 / 40h      +2:30   │
└─────────────────────────────────────┘
```

**Während aktiver Schicht**:
- Live-Timer mittig
- Großer `▶ PAUSE STARTEN`-Button
- `■ SCHICHT BEENDEN`-Button kleiner darunter
- Standort-Status oben (grün/gelb/rot)

**Während Pause**:
- Pausen-Timer
- `↩ PAUSE BEENDEN`
- Hinweis: „Mindestens X min für gesetzliche Pause"

### 3.2 Korrektur-Flow

Driver tippt auf einen Tag im Verlauf →

```
┌─ 13.05.2026 ────────────────────────┐
│ Schicht                             │
│ 11:02 – 19:58 · 8h 11min (netto)    │
│ Pause: 13:30 – 14:00                │
│                                     │
│ [Korrektur beantragen]              │
└─────────────────────────────────────┘
```

Tap auf „Korrektur beantragen" → Modal mit:
- Datumsfeld (fixiert)
- Schichtstart-Picker (Zeit)
- Schichtende-Picker
- Pausen-Zeilen mit + Button
- Begründungs-Textfeld
- „Anfrage absenden"

### 3.3 Zeitkonto-Tab

| Monat | Soll | Ist | Saldo | Ø/Tag |
|---|---|---|---|---|
| Mai 2026 | 168:00 | 172:30 | **+4:30** | 8:14 |
| Apr 2026 | 168:00 | 168:00 | 0:00 | 8:00 |
| Mär 2026 | 184:00 | 191:15 | **+7:15** | 8:18 |

Plus großes Karten-Display: aktueller Gesamt-Saldo, Vacation-Days, Sick-Days.

### 3.4 Standortzustimmung (Onboarding)

Beim ersten Login:
```
┌──────────────────────────────────────┐
│ 📍 Standort-Erlaubnis                │
│                                      │
│ CoDriver prüft bei jedem Stempel-    │
│ vorgang, ob du an deinem Hub bist.   │
│                                      │
│ • Wir speichern KEINE exakten        │
│   Koordinaten — nur „bist du am Hub  │
│   oder nicht" (Geofence-Match)       │
│ • Tracking läuft nur beim Stempeln,  │
│   nicht im Hintergrund               │
│ • Du kannst Standort-Erlaubnis       │
│   jederzeit widerrufen               │
│                                      │
│ [Genaue Datenschutzerklärung]        │
│                                      │
│ [Nein, manuell stempeln]             │
│ [Ja, Standort erlauben]              │
└──────────────────────────────────────┘
```

Wenn „Nein": Stempel funktioniert weiter, aber Admin sieht
„Standort nicht bestätigt"-Flag und muss bei jedem Eintrag manuell
genehmigen.

---

## 4. Admin-UX

### 4.1 Live-Board (Tab in Drivers-Hub)
Realtime-View wer gerade eingestempelt ist:

```
┌─ AKTUELL EINGESTEMPELT · 12 Fahrer ─────────┐
│                                              │
│ ● Max Müller       seit 07:02 · 4h 33min    │
│   Wave A · CA_A151 · DBY5                   │
│                                              │
│ ● Anna Schmidt     seit 11:15 · 0h 20min    │
│   ⏸ Pause seit 11:30                        │
│                                              │
│ ⚠ Lukas Weber      seit 06:45 · 9h 50min    │
│   Schichtlänge fast erreicht (10h)          │
│                                              │
└──────────────────────────────────────────────┘
```

### 4.2 Zeitkonto-Übersicht (Tab in „Time & Absence")
Tabelle pro Fahrer mit Soll/Ist/Saldo/Vacation, sortierbar, mit
Export-Button rechts oben.

### 4.3 Korrektur-Inbox
Pending-Requests vom Driver, Pro-Zeile-View:
- Driver-Name + Datum + Was geändert wurde (Diff-View)
- Begründung
- Buttons: ✓ Genehmigen / ✗ Ablehnen / Bearbeiten

### 4.4 Compliance-Report (neuer Tab)
Pro Woche:
- Pausen-Verstöße (rot markiert)
- Schichtlängen-Verstöße
- Ruhezeit-Verstöße
- Wochenarbeitszeit > 48h Durchschnitt

→ PDF-Export für Audits

---

## 5. Geo-Tracking — Datenschutz by Design

### 5.1 Was wir **nicht** machen
- ❌ Keine Tracks der Routen während der Schicht
- ❌ Keine Klartext-Koordinaten in der Datenbank
- ❌ Keine Background-Location

### 5.2 Was wir machen
- ✅ Geofence-Check **nur zum Zeitpunkt** des Stempelvorgangs
- ✅ Server speichert nur `geofenceMatched: true/false` + `geofenceId`
- ✅ Genauigkeit (accuracy) speichern für Audit, aber keine lat/lng
- ✅ Driver bekommt mit jedem Stempelvorgang Notification: „Standort
  geprüft am Hub DBY5"
- ✅ Datenexport-Funktion: Driver kann alle eigenen Zeit-Daten als
  ZIP downloaden (DSGVO Art. 20)

### 5.3 DSFA (Datenschutz-Folgenabschätzung)
Notwendig wegen Art. 35 DSGVO bei systematischem Standort-Tracking.
Wird als PDF im `docs/`-Ordner abgelegt mit:
- Beschreibung der Verarbeitung
- Risiko-Einschätzung (Tracking → Bewegungsprofil-Risiko)
- Maßnahmen zur Risikominimierung (Geofence-Only, keine Speicherung
  von lat/lng, Verschlüsselung)
- Restrisiko-Bewertung

### 5.4 Server-Side-Validierung
Geofence-Check passiert **immer serverseitig** in der Cloud Function
`clockIn`/`clockOut` — Client-seitige Manipulation ist wirkungslos:

```ts
export const clockIn = onCall(async (req) => {
  const { stationCode, lat, lng } = req.data;
  const station = await getStation(req.auth!.uid, stationCode);
  const inGeofence = station.geofences.some(g =>
    haversineMeters(lat, lng, g.centerLat, g.centerLng) <= g.radiusMeters
  );
  // lat/lng werden NIE gespeichert, nur das Boolean
  await writeTimeEntry({
    geofenceMatched: inGeofence,
    geofenceId: inGeofence ? station.geofences[0].id : null,
    // …
  });
});
```

---

## 6. Feiertage automatisch

### 6.1 Quelle
Library [`holiday_de`](https://pub.dev/packages/holidays) oder
besser: **Server-Side** über die [feiertage-api.de](https://feiertage-api.de/)
(kostenlos, offen, alle 16 Bundesländer + bundesweite Tage).

### 6.2 Scheduled Cloud Function
```ts
export const populateHolidays = onSchedule('0 4 1 1 *', async () => {
  // Jeden 1. Januar um 04:00 für das laufende Jahr alle Feiertage holen
  const year = new Date().getFullYear();
  for (const state of GERMAN_STATES) {
    const url = `https://feiertage-api.de/api/?jahr=${year}&nur_land=${state}`;
    const resp = await fetch(url);
    const holidays = await resp.json();
    for (const [name, info] of Object.entries(holidays)) {
      await db.collection('global_holidays')
        .doc(`${year}_${state}_${info.datum}`)
        .set({ name, date: info.datum, state, year });
    }
  }
});
```

### 6.3 Per-Driver-Anwendung
Driver hat `bundesland: "BE"`. Bei der Soll-Stunden-Berechnung für
einen Monat:

```ts
function computeSollHours(driver, month) {
  const workingDays = getWorkingDaysInMonth(month, driver.workingDays);
  const holidays = getHolidaysForState(driver.bundesland, month);
  const effectiveDays = workingDays.filter(
    d => !holidays.some(h => isSameDate(h, d))
  );
  return effectiveDays.length * driver.dailyContractHours;
}
```

Feiertage **werden automatisch** als „Bezahlter Feiertag" (volle Soll)
ins Zeitkonto verbucht — keine manuelle Eintragung.

### 6.4 Bundesland-Setup
- Beim Driver-Onboarding wird das Bundesland abgefragt
- Default = das Bundesland der Station (wenn Station-Code im Plan
  zur Adresse passt)
- Admin kann pro Driver übersteuern (z. B. bei Wochenend-Pendlern)

---

## 7. ArbZG-Compliance-Checks (Cloud Function)

Bei jedem `shift_end`-Event triggert `complianceChecker`:

| Check | Schwelle | Quelle |
|---|---|---|
| `minBreakMet` | ≥30 min Pause bei >6h Schicht, ≥45 min bei >9h | ArbZG §4 |
| `maxShiftLengthOk` | ≤10h Schichtdauer (8h Standard, 10h ausnahmsweise) | ArbZG §3 |
| `restPeriodToPreviousShiftOk` | ≥11h Ruhezeit seit letzter Schicht | ArbZG §5 |
| `maxWeeklyAverageOk` | ≤48h Wochenarbeitszeit Ø über 24 Wochen | ArbZG §3 |
| `nightShiftDocumented` | Bei Schichten 23:00–06:00 | ArbZG §6 |

Verstöße werden:
- Im `shifts/{shiftId}.complianceFlags.warnings[]` gespeichert
- Im Admin-Compliance-Tab rot markiert
- Auf Wunsch per Email an Admin gemeldet (täglicher Digest)

**Wichtig**: Die Funktion **verhindert** den Verstoß nicht (Driver kann
trotzdem länger arbeiten) — sie protokolliert nur. Verhindern wäre
übergriffig.

---

## 8. Payroll-Integration

### 8.1 Architektur
Nicht „Export-Button" sondern **API-Push** in regelmäßigen Intervallen
(z. B. Monatsabschluss am 1. des Folgemonats um 06:00).

### 8.2 SD Worx Connect (REST)

**Auth**: OAuth 2.0 Client Credentials Flow (separater Client je
Mandant).

**Endpunkte** (vereinfacht):
- `POST /api/v1/payroll/time-attendance/employees/{emp_id}/entries`
- `POST /api/v1/payroll/leave/employees/{emp_id}/requests`
- `GET  /api/v1/employees` (für Sync der Mitarbeiter-IDs)

**Datenmodell-Mapping**:
| CoDriver | SD Worx |
|---|---|
| `shift.workDuration` (Sekunden) | `regularHours` (Stunden) |
| `shift.overtimeHours` (über Soll) | `overtimeHours` |
| `holiday_entry` | `paidHolidayHours` |
| `sick_day` | `sicknessHours` |
| `vacation` | `vacationDays` |

**Cloud Function `syncSdWorx`**:
```ts
export const syncSdWorx = onSchedule('0 6 1 * *', async () => {
  // Am 1. jedes Monats 06:00 für den vorherigen Monat
  const month = previousMonth();
  const admins = await db.collection('users')
    .where('payroll.provider', '==', 'sd_worx').get();
  for (const admin of admins.docs) {
    const drivers = await admin.ref.collection('drivers').get();
    for (const driver of drivers.docs) {
      const data = driver.data();
      if (!data.payroll?.externalEmployeeId) continue;
      const monthly = await computeMonthlyPayload(driver, month);
      await sdWorxApi.postTimeAttendance(
        data.payroll.externalEmployeeId,
        monthly
      );
    }
  }
});
```

### 8.3 ADP Workforce Now

**Auth**: OAuth 2.0 mit ADP Authorization Server + SSL-Client-Cert
(ADP-Standard).

**Endpunkte**:
- `POST /events/hr/v1/time-card.process` (Stempelzeiten)
- `POST /events/hr/v1/time-off-request.process` (Urlaub/Krankheit)

**Quirks**:
- ADP Workforce Now ist US-zentrisch — DE-Mandanten brauchen
  „ADP Celergo" als Backend, das per Roo Connect angebunden wird
- Pro Mandant einmaliger Onboarding-Prozess mit ADP-Account-Manager
- Test in Sandbox-Environment empfohlen

### 8.4 Mapping-UI
Im Driver-Detail neuer Tab „Lohnabrechnung":
- Provider-Auswahl (SD Worx / ADP / Keine)
- Externe Mitarbeiter-ID
- Cost Center
- Last-Sync-Status: „Mai 2026 erfolgreich übertragen am 01.06.2026"
- Sync-Errors-Log

### 8.5 Fallback: CSV-Export
Falls Sync fehlschlägt oder Provider nicht angeschlossen:
- DATEV-LODAS-CSV-Format als Universal-Fallback
- SD-Worx-Custom-CSV als Pre-Setup für Onboarding
- ADP-CSV als Backup

---

## 9. DSGVO + Datenschutz

### 9.1 Mindest-Compliance-Maßnahmen
1. **Datenschutzerklärung** ergänzen um Abschnitt „Zeiterfassung mit
   Geofence" (Klartext, was wir speichern, was nicht, wie lange)
2. **AV-Vertrag** mit Firebase + Lohnanbietern abschließen (TOMs
   prüfen)
3. **Betriebsvereinbarung** mit dem Betriebsrat — bei mitbestimmungs-
   pflichtigen Betrieben (§87 (1) Nr. 6 BetrVG: Einführung techn.
   Einrichtungen zur Überwachung)
4. **Aufbewahrungsfristen**:
   - Zeit-Entries: 2 Jahre (ArbZG §16 (2))
   - Schicht-Aggregate: 6 Jahre (Lohnabrechnung, AO §147)
   - Korrektur-Anfragen: 2 Jahre
   - Geofence-Match-Boolean: 2 Jahre (nicht das Geofence-Objekt selbst)
5. **Löschroutinen**: Scheduled Function, die nach Fristablauf
   automatisch entfernt

### 9.2 Betroffenenrechte
- **Auskunft** (Art. 15): „Meine Daten herunterladen"-Button im
  Driver-Profil → vollständiger ZIP-Export
- **Berichtigung** (Art. 16): Über das Korrektur-Antrag-System
- **Löschung** (Art. 17): Nach Vertragsende automatisch, bei Antrag
  manuell durch Admin (mit Audit-Eintrag)
- **Datenportabilität** (Art. 20): CSV-Export im Standard-Format

### 9.3 DSFA-Pflicht
Geo-Tracking + Mitarbeiter = **hohes Risiko** laut Art. 35.
DSFA muss vor Inbetriebnahme erstellt werden (Vorlage liegt unter
`docs/dsfa-zeiterfassung.md` — noch zu schreiben).

---

## 10. Anti-Manipulation

| Risiko | Maßnahme |
|---|---|
| Driver stempelt zu Hause ein | Geofence-Check serverseitig + Boolean-Speicherung |
| Driver gibt sein Phone an Kollegen | Device-Binding (Auth-Token + DeviceId in `time_entries`) |
| Driver dreht Systemuhr | Server-Timestamps, niemals Client-Time speichern (nur als Referenz) |
| Admin manipuliert nachträglich | Audit-Log jeder Änderung in `audit_log/{entryId}` |
| Doppel-Stempeln | Atomare Cloud Function mit Firestore-Transaction |
| GPS-Spoofing | accuracy-Check (>50m → manuelle Genehmigung), zusätzlich Mobile-IP-Plausibilität |

---

## 11. Phasen-Plan

| Phase | Inhalt | Geschätzt |
|---|---|---|
| **0** | DSFA + Datenschutzerklärung + Betriebsvereinbarung-Template | 1 Woche (extern) |
| **1** | Datenmodell + Cloud Functions `clockIn` / `clockOut` + `validateGeofence` + Audit-Log | 3 Tage |
| **2** | Driver-UI: Stempel-Screen, Pause-Flow, Zeitkonto-Tab | 4 Tage |
| **3** | Admin-UI: Live-Board, Zeitkonto-Übersicht, Korrektur-Inbox | 3 Tage |
| **4** | Feiertags-Sync + ArbZG-Compliance-Checks + Compliance-Report-Tab | 2 Tage |
| **5** | SD Worx Integration (Sandbox + Live) | 1 Woche (inkl. Provider-Onboarding) |
| **6** | ADP Integration (Sandbox + Live) | 1 Woche (inkl. Provider-Onboarding) |
| **7** | CSV-Fallback (DATEV) + Export-UI | 1 Tag |
| **8** | DSGVO-Routinen: Auto-Löschung, Datenexport, Audit-Verbesserung | 2 Tage |
| **9** | Beta mit 1-2 Pilot-DSPs + Iteration | 2-4 Wochen |

**Realistische Gesamtdauer**: ~10-12 Wochen bis Production-Ready,
ohne Phase 0 (die parallel läuft).

---

## 12. Getroffene Entscheidungen

| Punkt | Entscheidung |
|---|---|
| **Add-On-Pricing** | Separates kostenpflichtiges Modul über zweites Stripe-Subscription-Item, Default aus. Anfänglich nur für `admin@arion-logistics.de` per Owner-Email-Whitelist |
| **Stempel-Methode** | **GPS-Geofence + QR-Code** als Doppel-Faktor. QR-Sticker (HMAC-signiert, pro Hub eindeutig) am Hub-Eingang. Beide Faktoren werden server-seitig validiert |
| **Pflicht-Pause** | **Reminder** via Push-Notification nach 5 h Schicht („Bitte 30 min Pause"). Keine erzwungene Auto-Pause |
| **Korrektur-Flow** | **Driver beantragt → Admin genehmigt**. Vollständiges Audit-Log jeder Änderung |
| **Datenresidenz** | **Komplett-Migration `nam5 → eur3`** (Frankfurt). Da Firestore eine Region nicht migrieren kann, heißt das praktisch: neue Database in `eur3` anlegen, Daten per Migrations-Skript kopieren, App auf neue DB umstellen, alte Database löschen. Mehrstündiger Wartungsfenster nötig — wird vor Zeiterfassungs-Rollout durchgeführt |
| **Lohn-Provider** | SD Worx + ADP + DATEV-CSV-Export **alle drei vorgesehen**, aber **erst nach MVP**, weil noch keine Provider-Verträge stehen. Phase 5-7 startet sobald der erste Vertrag da ist |
| **Betriebsrat** | Keiner vorhanden → keine Betriebsvereinbarung nötig. Driver gibt individuell die Standort-Erlaubnis beim Onboarding. Datenschutzerklärung muss trotzdem erweitert werden |
| **Schicht-Modell** | **Driver punched selbst** ein/aus. Schicht beginnt mit dem Clock-in-Stempel, endet mit Clock-out. Kein separater Pre-/Post-Trip-Sub-Schritt im MVP — alles fließt in eine Schicht ein |

---

## 13. Nächste Schritte (Sequenz)

**Phase 0a — Vorbereitung (vor Code)**
- Firestore-Migration `nam5 → eur3` planen, Test-Migration, dann
  Production-Migration mit Wartungsfenster
- Datenschutzerklärung um „Standort beim Stempeln + Geofence-Match"
  ergänzen
- HMAC-Schlüssel pro Hub generieren, QR-Code-Sticker-Druck vorbereiten

**Phase 1 — Datenmodell + Server-Stempel**
- Firestore-Collections (time_entries, shifts, time_account,
  correction_requests, stations.geofences) anlegen
- Cloud Functions:
  - `clockIn` / `clockOut` mit GPS + QR-Validierung
  - `computeDailyShift` (Trigger)
  - `computeMonthlyAccount` (Scheduled, täglich)
- Owner-Email-Whitelist im Side-Menu

**Phase 2 — Driver-UX**
- Stempel-Hauptscreen
- Pause-Flow + Schicht-Ende
- Zeitkonto-Tab
- Korrektur-Antrag-Modal
- Standort-Zustimmungs-Dialog

**Phase 3 — Admin-UX**
- Live-Board
- Zeitkonto-Übersicht
- Korrektur-Inbox
- Compliance-Report-Tab

**Phase 4 — Feiertage + Compliance**
- Scheduled-Function für Bundesland-Feiertage
- ArbZG-Checks
- Compliance-Reports

**Phase 5-7 — Payroll** (sobald Verträge stehen)
- DATEV-CSV-Export (kein API-Vertrag nötig)
- SD Worx API
- ADP API

**Phase 8 — Add-On-Pricing**
- Stripe-Subscription-Item für Zeiterfassung
- Toggle im Billing-Tab
- Per-Account-Aktivierung über `addons.timeTracking`

Sobald die `nam5 → eur3` Migration durch ist, kann Phase 1 starten.

---

## 13. Was im MVP nicht drin ist (für später)

- Schichtplan-Soll-Eintrag durch Admin (Pflicht-Schichten mit
  Soll-Zeitfenster)
- Auto-Suggested Pauses (Smart-Reminder basierend auf historischer
  Pause-Zeit)
- Driver-zu-Driver-Schichttausch
- Integration mit Time-Off-Anfragen aus dem bestehenden „Time &
  Absence"-Modul (kommt in Phase 4 dazu, sobald Datenmodell stabil)
- Live-Dashboard für Dispatcher („wer fehlt heute?")
- Multi-Hub-Driver (ein Driver an zwei Stationen am Tag)
- Mobile-App nativ (aktuell läuft die Driver-App auch im Browser, eine
  PWA-Optimierung reicht für Phase 1)
- Stundenzettel-PDF zum Ausdrucken für Driver
