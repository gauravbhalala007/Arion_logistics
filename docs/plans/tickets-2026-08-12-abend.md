# Plan: Offene Feedback-Tickets 12.08.2026 (Abend-Batch)

## Kontext

CoDriver Flutter-Web-Admin (flutter_app/kpi_admin). 4 offene Kundentickets
aus der Firestore-`feedback`-Collection. Kunde schreibt Englisch, App ist
zweisprachig DE/EN.

## Global Constraints

- Alle neuen UI-Texte zweisprachig DE/EN nach Bestandsmuster:
  `final de = Localizations.localeOf(context).languageCode == 'de';`
- Bestehenden Code-Stil und Farbwelt des jeweiligen Screens übernehmen.
- KEINE firestore.rules-Änderungen; neue Felder nur in Pfaden, die Admins
  bereits schreiben dürfen (Admin-Subtree `users/{uid}/…`).
- KEINE Schema-Migrationen bestehender Daten (neue optionale Felder OK).
- KEINE Commits, KEINE Deploys durch Implementer (macht der Controller).
- `flutter analyze` auf allen geänderten Dateien: 0 Errors.
- Nicht anfassen: driver_safety_training_page.dart,
  driver_privacy_training_page.dart (paralleler Agent arbeitet daran).

## Task 1: Fleet Hub Feinschliff (3 Tickets)

Datei: lib/Screens/fleet_status_page.dart (ggf. lib/models/fleet_vehicle.dart).

1. **Bemerkungen** (Ticket IvnsvjoyXxIXMQc4vLkf): Freitext-Feld
   „Bemerkungen / Remarks" je Fahrzeug — im Fahrzeug-Editor-Dialog
   pflegbar, in der Detailansicht sichtbar. Speicherung wie das
   Werkstatt-Feld unter `users/{dspUid}/fleet_vehicle_extras/{plate}`
   (Feld `remarks`), NICHT im Vehicle-Dokument (Rules-Whitelist!).
2. **Status-Pill oben in der Detailansicht** (Ticket 6pYVENTHTSNRHqwXFQML):
   Beim Öffnen der Fahrzeug-Detailseite den Fahrzeugstatus prominent ganz
   oben als eigene farbige Pill anzeigen (gleiche Statusfarben wie in der
   Liste), damit der Zustand sofort erkennbar ist.
3. **Referenzen scrollbar** (Ticket E13vah6kyP69C7FFhXdg): Die
   Referenzen-Chips-Zeile über der Toolbar läuft bei vielen Einträgen aus
   dem sichtbaren Bereich. In einen horizontalen Scroller packen
   (`SingleChildScrollView`, `scrollDirection: Axis.horizontal`), damit
   alle Chips erreichbar sind; Layout sonst unverändert.

## Task 2: Time & Absence — bezahlter/unbezahlter Urlaub mit
Überstunden-Verrechnung (Ticket YaPruyvuOpV0VWa7WYxe)

Dateien (erkunden): lib/Screens/admin_shift_absence_page.dart (Urlaub
erfassen), lib/Screens/zeitkonto_tab.dart (Überstundenkonto),
lib/Screens/admin_monthly_plan_page.dart (Monatsplan-Anzeige).

1. Beim Erfassen von Urlaub (vacation) eine Auswahl **„Bezahlt / Paid"
   vs. „Unbezahlt / Unpaid"** ergänzen (Default: bezahlt). Speicherung als
   Feld am Abwesenheits-Dokument (z. B. `paid: true/false`) — bestehende
   Dokumente ohne Feld gelten als bezahlt.
2. **Monatsplan**: Urlaubstage zeigen statt des bisherigen einheitlichen
   Kürzels jetzt **„U"** für bezahlten und **„X"** für unbezahlten Urlaub
   (Legende/Tooltips DE/EN ergänzen, falls vorhanden).
3. **Überstundenkonto (Zeitkonto)**: Bezahlte Urlaubstage werden mit den
   Soll-Stunden des Tages GUTGESCHRIEBEN (zählen wie gearbeitet),
   unbezahlte Urlaubstage werden NICHT gutgeschrieben, sodass sie das
   Konto um die Soll-Stunden des Tages senken. Kundenbeispiel: 40 h
   Überstunden, 5 Tage unbezahlt (à 8 h Soll) → 0 h; 40 h Überstunden,
   5 Tage bezahlt → Konto bleibt bei 40 h Überstunden plus die
   gutgeschriebenen Sollstunden, d. h. der Fahrer verliert nichts.
   WICHTIG: Erst die bestehende Zeitkonto-Berechnung lesen und die
   Verrechnung exakt in deren Systematik einhängen (wo Soll/Ist berechnet
   werden), nicht parallel dazu erfinden. Wenn die bestehende Rechnung
   Urlaub bereits neutral behandelt (Soll = 0 an Urlaubstagen), dann gilt:
   bezahlt → weiterhin neutral; unbezahlt → Soll bleibt bestehen (Konto
   sinkt). Die gewählte Einbau-Stelle im Report dokumentieren.
