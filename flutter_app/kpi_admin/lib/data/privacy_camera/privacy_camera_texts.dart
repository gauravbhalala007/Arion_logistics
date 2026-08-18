// lib/data/privacy_camera/privacy_camera_texts.dart
//
// UI-Chrome (Buttons, Statuszeilen, Admin-Labels) für das Modul
// „Kameras im Fahrzeug – Datenschutz" — zweisprachig DE/EN nach
// Projektvorgabe.
//
// ABGRENZUNG: Die KURSINHALTE (Module, Quiz, Empfangsbestätigung,
// Widerspruchsformular) stehen NICHT hier, sondern in
// `assets/content/privacy_course_de.json`. Sie werden v1 nur auf Deutsch
// ausgeliefert; weitere Sprachen docken als weitere JSON-Datei an.
// Hier stehen ausschließlich Bedienelemente rund um den Inhalt.

/// Deutsche Fassung — Referenz für alle weiteren Sprachen.
const Map<String, String> _de = {
  // Kachel in der DA Academy
  'tile_title': 'Kameras im Fahrzeug – Datenschutz',
  'tile_subtitle': 'Was aufgenommen wird und welche Rechte Sie haben',
  'center_tile_title': 'Datenschutz',
  'center_tile_subtitle':
      'Erklärungen lesen, Widerspruch einlegen, Kontakt aufnehmen',

  // Statuszeile der Kachel
  'status_open': 'Noch offen',
  'status_ack': 'Bestätigt am {date}',
  'status_declined': 'Nicht bestätigt am {date}',
  'status_update': 'Neue Fassung – bitte erneut zur Kenntnis nehmen',

  // Kurs
  'course_progress': '{n} / {total}',
  'course_next': 'Weiter',
  'course_to_ack': 'Zur Bestätigung',
  'quiz_headline': 'Kurz nachgefragt',
  'quiz_answer_hint': 'Bitte beantworten Sie die Frage, um fortzufahren.',
  'doc_gate_hint': 'Bitte öffnen und lesen Sie das Dokument, um fortzufahren.',
  'exit_title': 'Kurs verlassen?',
  'exit_body':
      'Ihr Fortschritt geht verloren. Sie können den Kurs jederzeit neu '
      'starten – er blockiert die App nicht.',
  'exit_stay': 'Weiterlesen',
  'exit_leave': 'Verlassen',

  // Volltext
  'doc_read_hint': 'Bitte lesen Sie das Dokument bis zum Ende.',
  'doc_read_done': 'Gelesen',
  'doc_version': 'Fassung {version}',
  'doc_checksum': 'Prüfsumme {hash}',

  // Empfangsbestätigung
  'ack_back': 'Zurück',
  'ack_decline_confirm': 'Nicht bestätigen',
  'ack_signature_clear': 'Löschen',
  'ack_save_error': 'Speichern fehlgeschlagen: {error}',
  'ok': 'OK',

  // Datenschutz-Bereich
  'center_course_open': 'Kurs starten',
  'center_course_repeat': 'Kurs erneut ansehen',
  'center_status_none': 'Noch keine Empfangsbestätigung hinterlegt.',
  'center_status_ack': 'Empfang bestätigt am {date}.',
  'center_status_declined':
      'Am {date} vermerkt: Erklärung ausgehändigt, Bestätigung nicht '
      'unterzeichnet.',
  'center_status_outdated':
      'Es liegt eine neuere Fassung der Datenschutzerklärung vor.',
  'center_objection_open': 'Widerspruch einlegen',
  'center_objection_active': 'Widerspruch aktiv seit {date}',
  'center_objection_withdraw': 'Widerspruch zurücknehmen',
  'center_objection_processed': 'Bearbeitet am {date}',
  'center_objection_pending': 'In Bearbeitung',
  'center_contact_button': 'E-Mail schreiben',
  'center_mail_error': 'E-Mail-Programm konnte nicht geöffnet werden.',
  'center_signature_saved': 'Mit Unterschrift',
  'center_signature_none': 'Ohne Unterschrift',

  // Admin
  'admin_title': 'Kameras im Fahrzeug – Datenschutz',
  'admin_subtitle':
      'Empfangsbestätigungen (Kenntnisnahme, keine Einwilligung) und '
      'Widersprüche zur Verkehrssicherheitstechnologie.',
  'admin_tab_acks': 'Nachweise',
  'admin_tab_objections': 'Widersprüche',
  'admin_count_ack': 'Bestätigt',
  'admin_count_declined': 'Nicht bestätigt',
  'admin_count_open': 'Offen',
  'admin_count_objections': 'Offene Widersprüche',
  'admin_search': 'Fahrer suchen',
  'admin_refresh': 'Aktualisieren',
  'admin_empty_drivers': 'Keine aktiven Fahrer gefunden.',
  'admin_empty_objections': 'Es liegen keine Widersprüche vor.',
  'admin_status_ack': 'Bestätigt',
  'admin_status_declined': 'Nicht bestätigt',
  'admin_status_open': 'Offen',
  'admin_status_outdated': 'Alte Fassung',
  'admin_mark_processed': 'Als bearbeitet markieren',
  'admin_processed': 'Bearbeitet am {date}',
  'admin_unprocessed': 'Noch nicht bearbeitet',
  'admin_withdrawn': 'Zurückgenommen am {date}',
  'admin_objection_since': 'Eingegangen am {date}',
  'admin_reason': 'Grund',
  'admin_no_reason': 'Ohne Angabe von Gründen',
  'admin_decline_note': 'Vermerk',
  'admin_detail_version': 'Fassung {version} · Prüfsumme {hash}',
  'admin_detail_quiz': 'Quiz {correct}/{total}',
  'admin_detail_read': 'Volltext {seconds} s gelesen',
  'admin_detail_scrolled': 'bis zum Ende gescrollt',
  'admin_detail_signature': 'Unterschrift vorhanden',
  'admin_detail_no_signature': 'ohne Unterschrift',
  'admin_processed_error': 'Konnte nicht gespeichert werden: {error}',
  'admin_hint_no_gate':
      'Hinweis: Dieses Modul blockiert die Fahrer-App bewusst nicht. Eine '
      'Verweigerung ist kein Fehlerfall, sondern ein gültiger Nachweis der '
      'Aushändigung.',
};

const Map<String, String> _en = {
  'tile_title': 'In-vehicle cameras – data protection',
  'tile_subtitle': 'What is captured and what rights you have',
  'center_tile_title': 'Data protection',
  'center_tile_subtitle': 'Read the notices, object, get in touch',

  'status_open': 'Still open',
  'status_ack': 'Confirmed on {date}',
  'status_declined': 'Not confirmed on {date}',
  'status_update': 'New version – please take note again',

  'course_progress': '{n} / {total}',
  'course_next': 'Continue',
  'course_to_ack': 'To confirmation',
  'quiz_headline': 'Quick check',
  'quiz_answer_hint': 'Please answer the question to continue.',
  'doc_gate_hint': 'Please open and read the document to continue.',
  'exit_title': 'Leave the course?',
  'exit_body':
      'Your progress will be lost. You can restart the course at any time – '
      'it never blocks the app.',
  'exit_stay': 'Keep reading',
  'exit_leave': 'Leave',

  'doc_read_hint': 'Please read the document to the end.',
  'doc_read_done': 'Read',
  'doc_version': 'Version {version}',
  'doc_checksum': 'Checksum {hash}',

  'ack_back': 'Back',
  'ack_decline_confirm': 'Do not confirm',
  'ack_signature_clear': 'Clear',
  'ack_save_error': 'Saving failed: {error}',
  'ok': 'OK',

  'center_course_open': 'Start course',
  'center_course_repeat': 'Review course',
  'center_status_none': 'No confirmation of receipt on file yet.',
  'center_status_ack': 'Receipt confirmed on {date}.',
  'center_status_declined':
      'Recorded on {date}: notice handed over, confirmation not signed.',
  'center_status_outdated': 'A newer version of the privacy notice is available.',
  'center_objection_open': 'Submit objection',
  'center_objection_active': 'Objection active since {date}',
  'center_objection_withdraw': 'Withdraw objection',
  'center_objection_processed': 'Processed on {date}',
  'center_objection_pending': 'Being processed',
  'center_contact_button': 'Send e-mail',
  'center_mail_error': 'The e-mail app could not be opened.',
  'center_signature_saved': 'With signature',
  'center_signature_none': 'Without signature',

  'admin_title': 'In-vehicle cameras – data protection',
  'admin_subtitle':
      'Confirmations of receipt (acknowledgement, not consent) and objections '
      'to the road-safety technology.',
  'admin_tab_acks': 'Records',
  'admin_tab_objections': 'Objections',
  'admin_count_ack': 'Confirmed',
  'admin_count_declined': 'Not confirmed',
  'admin_count_open': 'Open',
  'admin_count_objections': 'Open objections',
  'admin_search': 'Search driver',
  'admin_refresh': 'Refresh',
  'admin_empty_drivers': 'No active drivers found.',
  'admin_empty_objections': 'There are no objections.',
  'admin_status_ack': 'Confirmed',
  'admin_status_declined': 'Not confirmed',
  'admin_status_open': 'Open',
  'admin_status_outdated': 'Old version',
  'admin_mark_processed': 'Mark as processed',
  'admin_processed': 'Processed on {date}',
  'admin_unprocessed': 'Not processed yet',
  'admin_withdrawn': 'Withdrawn on {date}',
  'admin_objection_since': 'Received on {date}',
  'admin_reason': 'Reason',
  'admin_no_reason': 'No reason given',
  'admin_decline_note': 'Note',
  'admin_detail_version': 'Version {version} · checksum {hash}',
  'admin_detail_quiz': 'Quiz {correct}/{total}',
  'admin_detail_read': 'Full text read for {seconds} s',
  'admin_detail_scrolled': 'scrolled to the end',
  'admin_detail_signature': 'signature on file',
  'admin_detail_no_signature': 'without signature',
  'admin_processed_error': 'Could not be saved: {error}',
  'admin_hint_no_gate':
      'Note: this module deliberately does not block the driver app. A refusal '
      'is not an error — it is a valid record that the notice was handed over.',
};

/// Auflösung wie bei den übrigen Schulungen: gesuchte Sprache, sonst
/// Englisch, sonst Deutsch. `{var}`-Platzhalter werden ersetzt.
String privacyCameraText(
  String languageCode,
  String key, {
  Map<String, String>? vars,
}) {
  final lang = languageCode.trim().toLowerCase();
  final table = lang == 'de' ? _de : _en;
  var out = table[key] ?? _en[key] ?? _de[key] ?? key;
  if (vars != null) {
    for (final entry in vars.entries) {
      out = out.replaceAll('{${entry.key}}', entry.value);
    }
  }
  return out;
}
