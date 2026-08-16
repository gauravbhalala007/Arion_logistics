# Spanisch (es) als 11. Sprache — Rollout-Plan & Inventar

Ziel: Spanisch überall dort ergänzen, wo die App heute 10 Sprachen führt
(de, en, sq, hu, ro, hr, tr, ru, bg, ar). Vorgehen: erst ALLE Inhalte
übersetzen (Hintergrund-Agenten), zuletzt zentral „scharfschalten"
(Locale + Resolver + Sprachwähler), damit nie eine halbfertige Sprache
live ist. Fallback-Kette bleibt locale → en → de.

## A. Inhalte / Übersetzungsdateien (neu anzulegen)

Schulungen (lib/data/safety_training/), je Sprache eigene Datei,
Master = *_de.dart, Konvention wie bestehende Übersetzungen
(Symbole …Es, Struktur 1:1, IDs/correctIndex identisch):

- [x] driving_safety_content_es.dart (~3000 Z., Master 3011)  — Welle 1
- [x] driving_safety_quiz_es.dart (1018 Z.)                    — Welle 1
- [x] green_book_content_es.dart (779 Z.)                      — Welle 1
- [x] green_book_quiz_es.dart (339 Z.)                         — Welle 1
- [x] ride_along_content_es.dart (1247 Z.)                     — Welle 1
- [x] ride_along_quiz_es.dart (297 Z.)                         — Welle 1
- [x] safety_content_es.dart (1081 Z.)                         — Welle 1
- [x] safety_texts_es.dart (279 Z.)                            — Welle 1
- [x] operating_instructions_es.dart (371 Z.)                  — Welle 2
- [x] privacy_content_es.dart (~1010 Z.)                       — Welle 2
- [x] privacy_quiz_es.dart (~370 Z.)                           — Welle 2

Datenschutzinformation (lib/data/privacy_notice/):

- [x] privacy_notice_es.dart (652 Z., Art.-13-Volltext)        — Welle 2

## B. Bedientext-Maps (bestehende Dateien, je ein Es-Block ergänzen)

- [x] lib/data/safety_training/driving_safety_texts.dart       — Welle 2
- [x] lib/data/safety_training/green_book_texts.dart           — Welle 2
- [x] lib/data/safety_training/ride_along_texts.dart           — Welle 2
- [x] lib/data/safety_training/privacy_texts.dart              — Welle 2
- [x] lib/data/safety_training/operating_instructions_texts.dart — Welle 2
- [x] lib/data/safety_training/academy_texts.dart              — Welle 2
- [x] lib/data/privacy_notice/privacy_notice_texts.dart (inkl. popup_*-Keys) — Welle 2

## C. App-Lokalisierung (Fahrer-UI)

- [x] lib/localization/es_strings.dart NEU — nach dem Muster von
      bg_strings.dart (flache Override-Map, 1666 Keys, Quelle = en-Block
      in app_localizations.dart)                               — Welle 1
- [x] app_localizations.dart: Import + Merge-Zweig für 'es'
      (identisch zum bg-Mechanismus, Z. ~14915) + Locale('es') in
      supportedLocales                                          — Finale
- [x] Green-Book-Fragen: kGreenBookQuestionsEs                  — Welle 2

## D. Verstreute Sprach-Maps (je ein 'es'-Eintrag)

- [x] lib/Screens/add_driver_dialog.dart (_Lang-Liste: 'es', 'Español', 🇪🇸) — Finale
- [x] lib/Screens/driver_home_shell.dart (2 switch-Blöcke ~Z. 754/781) — Finale
- [x] lib/Screens/driver_green_book_page.dart (switch ~Z. 243)  — Finale
- [x] lib/Screens/driver_incident_report_page.dart (Map ~Z. 2071) — Finale
- [x] lib/widgets/app_update_popup.dart (2 Maps ~Z. 64/77)      — Finale
- [x] lib/Screens/driver_operating_instructions_page.dart
      (_allInstructionsFor-switch: 'es' → operatingInstructionsEs) — Finale

## E. Resolver „scharfschalten" (erst wenn A–D fertig)

- [x] driving_safety_data.dart: 'es'-Zweige (chapters + questions)
- [x] green_book_data.dart: 'es'-Zweige
- [x] ride_along_data.dart: 'es'-Zweige
- [x] safety_training_data.dart: 'es'-Zweige
- [x] privacy_data.dart: 'es'-Zweige
- [x] lib/data/privacy_notice/privacy_notice_content.dart:
      Sections-Resolver um 'es' ergänzen

## F. Abschluss

- [x] Struktur-Verifikation (tool/check_privacy_translations.py-Muster
      auf es ausweiten; Slide-/Fragen-Zahlen aller Trainings = de)
- [x] flutter analyze lib/ → 0 Errors
- [x] Build + Hosting-Deploy
- [x] Ticket-/Statusmeldung an den Nutzer

## Regeln für die Übersetzungs-Agenten

- Spanisch (europäisches Spanisch, Du-Form „tú" wie die anderen
  Übersetzungen), Fachbegriffe: 'DSGVO (RGPD)', Art.-Verweise
  unverändert, Eigennamen (CoDriver, Amazon, Green Book, TÜV, StVO
  mit kurzer Erläuterung) wie in den Geschwister-Übersetzungen.
- Struktur 1:1 zum deutschen Master (Blöcke, IDs, Reihenfolge,
  correctIndex); Dart single quotes; \n erhalten; Datei muss
  kompilieren (flutter analyze auf die neuen Dateien).
- KEINE Resolver/Locale-Änderungen durch Übersetzungs-Agenten —
  Scharfschalten macht der Controller zentral (Abschnitt E/F).
