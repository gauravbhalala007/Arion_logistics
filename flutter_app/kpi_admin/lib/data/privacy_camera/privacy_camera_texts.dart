// lib/data/privacy_camera/privacy_camera_texts.dart
//
// UI-Chrome (Buttons, Statuszeilen, Admin-Labels) für das Modul
// „Kameras im Fahrzeug – Datenschutz", in allen 11 App-Sprachen.
//
// ABGRENZUNG: Die KURSINHALTE (Module, Empfangsbestätigung) stehen NICHT
// hier, sondern in `assets/content/privacy_course_{lang}.json`. Hier
// stehen ausschließlich Bedienelemente rund um den Inhalt.
//
// Alle Sprach-Maps haben denselben Key-Satz (Vertrag). Platzhalter in
// geschweiften Klammern, z. B. {date}, {version}. Auflösung mit
// Fallback-Kette locale -> en -> de, analog zu privacy_texts.dart.
//
// Bewusst NICHT übersetzt: die Eigennamen „CoDriver" und „DA Academy"
// sowie der Sprachcode in `binding_label` — der verbindliche Wortlaut
// ist und bleibt deutsch.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> _de = {
  // Kacheln in der DA Academy
  'tile_title': 'Kameras im Fahrzeug – Datenschutz',
  'tile_subtitle': 'Was aufgenommen wird und welche Rechte Sie haben',
  'center_tile_title': 'Datenschutz',
  'center_tile_subtitle': 'Erklärungen lesen und Kontakt aufnehmen',

  // Statuszeile der Kachel
  'status_open': 'Noch offen',
  'status_ack': 'Bestätigt am {date}',
  'status_declined': 'Nicht bestätigt am {date}',
  'status_update': 'Neue Fassung – bitte erneut zur Kenntnis nehmen',

  // Kurs
  'course_progress': '{n} / {total}',
  'course_next': 'Weiter',
  'course_to_ack': 'Zur Bestätigung',
  'doc_gate_hint': 'Bitte öffnen und lesen Sie das Dokument, um fortzufahren.',

  // Volltext
  'doc_read_hint': 'Bitte lesen Sie das Dokument bis zum Ende.',
  'doc_read_done': 'Gelesen',
  'doc_version': 'Fassung {version}',
  'doc_checksum': 'Prüfsumme {hash}',

  // Zweisprachige Empfangsbestätigung
  'binding_label': 'Verbindlicher Wortlaut (Deutsch)',
  'translation_label': 'Übersetzung',

  // Empfangsbestätigung
  'ack_back': 'Zurück',
  'ack_decline_confirm': 'Nicht bestätigen',
  'ack_signature_clear': 'Löschen',
  'later_label': 'Später',
  'signature_required_hint': 'Bitte unterschreiben Sie, um zu bestätigen.',
  'signature_export_failed': 'Die Unterschrift konnte nicht übernommen werden. Bitte unterschreiben Sie noch einmal.',
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
  'center_contact_button': 'E-Mail schreiben',
  'center_mail_error': 'E-Mail-Programm konnte nicht geöffnet werden.',
  'center_signature_saved': 'Mit Unterschrift',
  'center_signature_none': 'Ohne Unterschrift',

  // Admin
  'admin_title': 'Kameras im Fahrzeug – Datenschutz',
  'admin_subtitle':
      'Empfangsbestätigungen zur Verkehrssicherheitstechnologie – '
      'Kenntnisnahme, keine Einwilligung.',
  'admin_count_ack': 'Bestätigt',
  'admin_count_declined': 'Nicht bestätigt',
  'admin_count_open': 'Offen',
  'admin_search': 'Fahrer suchen',
  'admin_refresh': 'Aktualisieren',
  'admin_empty_drivers': 'Keine aktiven Fahrer gefunden.',
  'admin_status_ack': 'Bestätigt',
  'admin_status_declined': 'Nicht bestätigt',
  'admin_status_open': 'Offen',
  'admin_status_outdated': 'Alte Fassung',
  'admin_decline_note': 'Vermerk',
  'admin_detail_version': 'Fassung {version} · Prüfsumme {hash}',
  'admin_detail_language': 'gelesen auf {lang}',
  'admin_detail_read': 'Volltext {seconds} s gelesen',
  'admin_detail_scrolled': 'bis zum Ende gescrollt',
  'admin_detail_signature': 'Unterschrift vorhanden',
  'admin_detail_no_signature': 'ohne Unterschrift',
  'admin_hint_no_gate':
      'Hinweis: Dieses Modul blockiert die Fahrer-App bewusst nicht. Eine '
      'Verweigerung ist kein Fehlerfall, sondern ein gültiger Nachweis der '
      'Aushändigung.',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> _en = {
  'tile_title': 'In-vehicle cameras – data protection',
  'tile_subtitle': 'What is captured and what rights you have',
  'center_tile_title': 'Data protection',
  'center_tile_subtitle': 'Read the notices and get in touch',

  'status_open': 'Still open',
  'status_ack': 'Confirmed on {date}',
  'status_declined': 'Not confirmed on {date}',
  'status_update': 'New version – please take note again',

  'course_progress': '{n} / {total}',
  'course_next': 'Continue',
  'course_to_ack': 'To confirmation',
  'doc_gate_hint': 'Please open and read the document to continue.',

  'doc_read_hint': 'Please read the document to the end.',
  'doc_read_done': 'Read',
  'doc_version': 'Version {version}',
  'doc_checksum': 'Checksum {hash}',

  'binding_label': 'Binding wording (German)',
  'translation_label': 'Translation',

  'ack_back': 'Back',
  'ack_decline_confirm': 'Do not confirm',
  'ack_signature_clear': 'Clear',
  'later_label': 'Later',
  'signature_required_hint': 'Please sign to confirm.',
  'signature_export_failed': 'The signature could not be captured. Please sign again.',
  'ack_save_error': 'Saving failed: {error}',
  'ok': 'OK',

  'center_course_open': 'Start course',
  'center_course_repeat': 'Review course',
  'center_status_none': 'No confirmation of receipt on file yet.',
  'center_status_ack': 'Receipt confirmed on {date}.',
  'center_status_declined':
      'Recorded on {date}: notice handed over, confirmation not signed.',
  'center_status_outdated':
      'A newer version of the privacy notice is available.',
  'center_contact_button': 'Send e-mail',
  'center_mail_error': 'The e-mail app could not be opened.',
  'center_signature_saved': 'With signature',
  'center_signature_none': 'Without signature',

  'admin_title': 'In-vehicle cameras – data protection',
  'admin_subtitle':
      'Confirmations of receipt for the road-safety technology – '
      'acknowledgement, not consent.',
  'admin_count_ack': 'Confirmed',
  'admin_count_declined': 'Not confirmed',
  'admin_count_open': 'Open',
  'admin_search': 'Search driver',
  'admin_refresh': 'Refresh',
  'admin_empty_drivers': 'No active drivers found.',
  'admin_status_ack': 'Confirmed',
  'admin_status_declined': 'Not confirmed',
  'admin_status_open': 'Open',
  'admin_status_outdated': 'Old version',
  'admin_decline_note': 'Note',
  'admin_detail_version': 'Version {version} · checksum {hash}',
  'admin_detail_language': 'read in {lang}',
  'admin_detail_read': 'Full text read for {seconds} s',
  'admin_detail_scrolled': 'scrolled to the end',
  'admin_detail_signature': 'signature on file',
  'admin_detail_no_signature': 'without signature',
  'admin_hint_no_gate':
      'Note: this module deliberately does not block the driver app. A refusal '
      'is not an error — it is a valid record that the notice was handed over.',
};

// ── Shqip (Albanisch) ───────────────────────────────────────────────
const Map<String, String> _sq = {
  'tile_title': 'Kamerat në automjet – mbrojtja e të dhënave',
  'tile_subtitle': 'Çfarë regjistrohet dhe cilat të drejta keni',
  'center_tile_title': 'Mbrojtja e të dhënave',
  'center_tile_subtitle': 'Lexoni njoftimet dhe na kontaktoni',

  'status_open': 'Ende e hapur',
  'status_ack': 'Konfirmuar më {date}',
  'status_declined': 'Nuk u konfirmua më {date}',
  'status_update': 'Version i ri – ju lutemi njihuni sërish me të',

  'course_progress': '{n} / {total}',
  'course_next': 'Vazhdo',
  'course_to_ack': 'Te konfirmimi',
  'doc_gate_hint': 'Ju lutemi hapni dhe lexoni dokumentin për të vazhduar.',

  'doc_read_hint': 'Ju lutemi lexoni dokumentin deri në fund.',
  'doc_read_done': 'Lexuar',
  'doc_version': 'Versioni {version}',
  'doc_checksum': 'Shuma e kontrollit {hash}',

  'binding_label': 'Formulimi detyrues (gjermanisht)',
  'translation_label': 'Përkthimi',

  'ack_back': 'Kthehu',
  'ack_decline_confirm': 'Mos konfirmo',
  'ack_signature_clear': 'Fshi',
  'later_label': 'Më vonë',
  'signature_required_hint': 'Ju lutemi nënshkruani për të konfirmuar.',
  'signature_export_failed': 'Nënshkrimi nuk mund të merrej. Ju lutemi nënshkruani përsëri.',
  'ack_save_error': 'Ruajtja dështoi: {error}',
  'ok': 'OK',

  'center_course_open': 'Fillo kursin',
  'center_course_repeat': 'Shiko kursin sërish',
  'center_status_none': 'Ende nuk është regjistruar asnjë konfirmim marrjeje.',
  'center_status_ack': 'Marrja u konfirmua më {date}.',
  'center_status_declined':
      'Shënuar më {date}: njoftimi u dorëzua, konfirmimi nuk u '
      'nënshkrua.',
  'center_status_outdated':
      'Ekziston një version më i ri i njoftimit për mbrojtjen e të dhënave.',
  'center_contact_button': 'Dërgo e-mail',
  'center_mail_error': 'Programi i e-mailit nuk mund të hapej.',
  'center_signature_saved': 'Me nënshkrim',
  'center_signature_none': 'Pa nënshkrim',

  'admin_title': 'Kamerat në automjet – mbrojtja e të dhënave',
  'admin_subtitle':
      'Konfirmime marrjeje për teknologjinë e sigurisë rrugore – '
      'njohje me përmbajtjen, jo pëlqim.',
  'admin_count_ack': 'Të konfirmuara',
  'admin_count_declined': 'Të pakonfirmuara',
  'admin_count_open': 'Të hapura',
  'admin_search': 'Kërko shofer',
  'admin_refresh': 'Rifresko',
  'admin_empty_drivers': 'Nuk u gjet asnjë shofer aktiv.',
  'admin_status_ack': 'Konfirmuar',
  'admin_status_declined': 'E pakonfirmuar',
  'admin_status_open': 'E hapur',
  'admin_status_outdated': 'Version i vjetër',
  'admin_decline_note': 'Shënim',
  'admin_detail_version': 'Versioni {version} · shuma e kontrollit {hash}',
  'admin_detail_language': 'lexuar në {lang}',
  'admin_detail_read': 'Teksti i plotë u lexua {seconds} s',
  'admin_detail_scrolled': 'u lëviz deri në fund',
  'admin_detail_signature': 'nënshkrimi ekziston',
  'admin_detail_no_signature': 'pa nënshkrim',
  'admin_hint_no_gate':
      'Shënim: ky modul nuk e bllokon qëllimisht aplikacionin e shoferit. '
      'Refuzimi nuk është gabim, por një dëshmi e vlefshme se njoftimi u '
      'dorëzua.',
};

// ── Magyar (Ungarisch) ──────────────────────────────────────────────
const Map<String, String> _hu = {
  'tile_title': 'Kamerák a járműben – adatvédelem',
  'tile_subtitle': 'Mit rögzítenek, és milyen jogai vannak',
  'center_tile_title': 'Adatvédelem',
  'center_tile_subtitle':
      'Olvassa el a tájékoztatókat, és lépjen kapcsolatba velünk',

  'status_open': 'Még nyitott',
  'status_ack': 'Visszaigazolva: {date}',
  'status_declined': 'Nincs visszaigazolva: {date}',
  'status_update': 'Új változat – kérjük, ismét vegye tudomásul',

  'course_progress': '{n} / {total}',
  'course_next': 'Tovább',
  'course_to_ack': 'A visszaigazoláshoz',
  'doc_gate_hint':
      'A folytatáshoz kérjük, nyissa meg és olvassa el a dokumentumot.',

  'doc_read_hint': 'Kérjük, olvassa el a dokumentumot a végéig.',
  'doc_read_done': 'Elolvasva',
  'doc_version': '{version} változat',
  'doc_checksum': 'Ellenőrző összeg: {hash}',

  'binding_label': 'Kötelező érvényű szöveg (német)',
  'translation_label': 'Fordítás',

  'ack_back': 'Vissza',
  'ack_decline_confirm': 'Nem igazolom vissza',
  'ack_signature_clear': 'Törlés',
  'later_label': 'Később',
  'signature_required_hint': 'Kérjük, írja alá a visszaigazoláshoz.',
  'signature_export_failed': 'Az aláírást nem sikerült rögzíteni. Kérjük, írja alá újra.',
  'ack_save_error': 'A mentés nem sikerült: {error}',
  'ok': 'OK',

  'center_course_open': 'Tanfolyam indítása',
  'center_course_repeat': 'Tanfolyam újranézése',
  'center_status_none': 'Még nincs rögzítve átvételi visszaigazolás.',
  'center_status_ack': 'Az átvétel visszaigazolva: {date}.',
  'center_status_declined':
      '{date} napján rögzítve: a tájékoztatót átadták, a visszaigazolást '
      'nem írták alá.',
  'center_status_outdated':
      'Az adatvédelmi tájékoztatónak újabb változata érhető el.',
  'center_contact_button': 'E-mail írása',
  'center_mail_error': 'Az e-mail programot nem sikerült megnyitni.',
  'center_signature_saved': 'Aláírással',
  'center_signature_none': 'Aláírás nélkül',

  'admin_title': 'Kamerák a járműben – adatvédelem',
  'admin_subtitle':
      'Átvételi visszaigazolások a közlekedésbiztonsági technológiához – '
      'tudomásulvétel, nem hozzájárulás.',
  'admin_count_ack': 'Visszaigazolva',
  'admin_count_declined': 'Nincs visszaigazolva',
  'admin_count_open': 'Nyitott',
  'admin_search': 'Sofőr keresése',
  'admin_refresh': 'Frissítés',
  'admin_empty_drivers': 'Nem található aktív sofőr.',
  'admin_status_ack': 'Visszaigazolva',
  'admin_status_declined': 'Nincs visszaigazolva',
  'admin_status_open': 'Nyitott',
  'admin_status_outdated': 'Régi változat',
  'admin_decline_note': 'Megjegyzés',
  'admin_detail_version': '{version} változat · ellenőrző összeg: {hash}',
  'admin_detail_language': '{lang} nyelven olvasva',
  'admin_detail_read': 'A teljes szöveg olvasása: {seconds} s',
  'admin_detail_scrolled': 'végiggörgetve',
  'admin_detail_signature': 'aláírás rendelkezésre áll',
  'admin_detail_no_signature': 'aláírás nélkül',
  'admin_hint_no_gate':
      'Megjegyzés: ez a modul szándékosan nem tiltja le a sofőr '
      'alkalmazását. A visszautasítás nem hiba, hanem érvényes igazolás '
      'arról, hogy a tájékoztatót átadták.',
};

// ── Română (Rumänisch) ──────────────────────────────────────────────
const Map<String, String> _ro = {
  'tile_title': 'Camere în vehicul – protecția datelor',
  'tile_subtitle': 'Ce se înregistrează și ce drepturi aveți',
  'center_tile_title': 'Protecția datelor',
  'center_tile_subtitle': 'Citiți informările și luați legătura cu noi',

  'status_open': 'Încă deschis',
  'status_ack': 'Confirmat la {date}',
  'status_declined': 'Neconfirmat la {date}',
  'status_update': 'Versiune nouă – vă rugăm să luați din nou la cunoștință',

  'course_progress': '{n} / {total}',
  'course_next': 'Continuă',
  'course_to_ack': 'Către confirmare',
  'doc_gate_hint':
      'Vă rugăm să deschideți și să citiți documentul pentru a continua.',

  'doc_read_hint': 'Vă rugăm să citiți documentul până la sfârșit.',
  'doc_read_done': 'Citit',
  'doc_version': 'Versiunea {version}',
  'doc_checksum': 'Sumă de control {hash}',

  'binding_label': 'Text obligatoriu (germană)',
  'translation_label': 'Traducere',

  'ack_back': 'Înapoi',
  'ack_decline_confirm': 'Nu confirm',
  'ack_signature_clear': 'Șterge',
  'later_label': 'Mai târziu',
  'signature_required_hint': 'Vă rugăm să semnați pentru a confirma.',
  'signature_export_failed': 'Semnătura nu a putut fi preluată. Vă rugăm să semnați din nou.',
  'ack_save_error': 'Salvarea a eșuat: {error}',
  'ok': 'OK',

  'center_course_open': 'Începe cursul',
  'center_course_repeat': 'Revezi cursul',
  'center_status_none':
      'Nu există încă nicio confirmare de primire înregistrată.',
  'center_status_ack': 'Primire confirmată la {date}.',
  'center_status_declined':
      'Consemnat la {date}: informarea a fost înmânată, confirmarea nu a '
      'fost semnată.',
  'center_status_outdated':
      'Există o versiune mai nouă a notei de informare privind protecția '
      'datelor.',
  'center_contact_button': 'Trimite e-mail',
  'center_mail_error': 'Programul de e-mail nu a putut fi deschis.',
  'center_signature_saved': 'Cu semnătură',
  'center_signature_none': 'Fără semnătură',

  'admin_title': 'Camere în vehicul – protecția datelor',
  'admin_subtitle':
      'Confirmări de primire pentru tehnologia de siguranță rutieră – '
      'luare la cunoștință, nu consimțământ.',
  'admin_count_ack': 'Confirmate',
  'admin_count_declined': 'Neconfirmate',
  'admin_count_open': 'Deschise',
  'admin_search': 'Caută șofer',
  'admin_refresh': 'Actualizează',
  'admin_empty_drivers': 'Nu au fost găsiți șoferi activi.',
  'admin_status_ack': 'Confirmat',
  'admin_status_declined': 'Neconfirmat',
  'admin_status_open': 'Deschis',
  'admin_status_outdated': 'Versiune veche',
  'admin_decline_note': 'Mențiune',
  'admin_detail_version': 'Versiunea {version} · sumă de control {hash}',
  'admin_detail_language': 'citit în {lang}',
  'admin_detail_read': 'Text integral citit {seconds} s',
  'admin_detail_scrolled': 'derulat până la final',
  'admin_detail_signature': 'semnătură existentă',
  'admin_detail_no_signature': 'fără semnătură',
  'admin_hint_no_gate':
      'Notă: acest modul nu blochează în mod intenționat aplicația '
      'șoferului. Refuzul nu este o eroare, ci o dovadă valabilă că '
      'informarea a fost înmânată.',
};

// ── Hrvatski (Kroatisch) ────────────────────────────────────────────
const Map<String, String> _hr = {
  'tile_title': 'Kamere u vozilu – zaštita podataka',
  'tile_subtitle': 'Što se snima i koja prava imate',
  'center_tile_title': 'Zaštita podataka',
  'center_tile_subtitle': 'Pročitajte obavijesti i javite nam se',

  'status_open': 'Još otvoreno',
  'status_ack': 'Potvrđeno {date}',
  'status_declined': 'Nije potvrđeno {date}',
  'status_update': 'Nova verzija – molimo ponovno se upoznajte s njom',

  'course_progress': '{n} / {total}',
  'course_next': 'Dalje',
  'course_to_ack': 'Na potvrdu',
  'doc_gate_hint': 'Molimo otvorite i pročitajte dokument kako biste nastavili.',

  'doc_read_hint': 'Molimo pročitajte dokument do kraja.',
  'doc_read_done': 'Pročitano',
  'doc_version': 'Verzija {version}',
  'doc_checksum': 'Kontrolni zbroj {hash}',

  'binding_label': 'Obvezujući tekst (njemački)',
  'translation_label': 'Prijevod',

  'ack_back': 'Natrag',
  'ack_decline_confirm': 'Ne potvrđujem',
  'ack_signature_clear': 'Obriši',
  'later_label': 'Kasnije',
  'signature_required_hint': 'Molimo potpišite kako biste potvrdili.',
  'signature_export_failed': 'Potpis nije bilo moguće preuzeti. Molimo potpišite ponovno.',
  'ack_save_error': 'Spremanje nije uspjelo: {error}',
  'ok': 'OK',

  'center_course_open': 'Pokreni tečaj',
  'center_course_repeat': 'Ponovno pogledaj tečaj',
  'center_status_none': 'Još nije zabilježena nijedna potvrda o primitku.',
  'center_status_ack': 'Primitak potvrđen {date}.',
  'center_status_declined':
      'Zabilježeno {date}: obavijest uručena, potvrda nije potpisana.',
  'center_status_outdated':
      'Dostupna je novija verzija obavijesti o zaštiti podataka.',
  'center_contact_button': 'Pošalji e-poštu',
  'center_mail_error': 'Program za e-poštu nije se mogao otvoriti.',
  'center_signature_saved': 'S potpisom',
  'center_signature_none': 'Bez potpisa',

  'admin_title': 'Kamere u vozilu – zaštita podataka',
  'admin_subtitle':
      'Potvrde o primitku za tehnologiju sigurnosti u prometu – '
      'primanje na znanje, ne privola.',
  'admin_count_ack': 'Potvrđeno',
  'admin_count_declined': 'Nije potvrđeno',
  'admin_count_open': 'Otvoreno',
  'admin_search': 'Traži vozača',
  'admin_refresh': 'Osvježi',
  'admin_empty_drivers': 'Nije pronađen nijedan aktivan vozač.',
  'admin_status_ack': 'Potvrđeno',
  'admin_status_declined': 'Nije potvrđeno',
  'admin_status_open': 'Otvoreno',
  'admin_status_outdated': 'Stara verzija',
  'admin_decline_note': 'Napomena',
  'admin_detail_version': 'Verzija {version} · kontrolni zbroj {hash}',
  'admin_detail_language': 'pročitano na jeziku {lang}',
  'admin_detail_read': 'Cijeli tekst čitan {seconds} s',
  'admin_detail_scrolled': 'pomaknuto do kraja',
  'admin_detail_signature': 'potpis postoji',
  'admin_detail_no_signature': 'bez potpisa',
  'admin_hint_no_gate':
      'Napomena: ovaj modul namjerno ne blokira aplikaciju za vozače. '
      'Odbijanje nije pogreška, nego valjan dokaz da je obavijest uručena.',
};

// ── العربية (Arabisch) ──────────────────────────────────────────────
const Map<String, String> _ar = {
  'tile_title': 'الكاميرات داخل المركبة – حماية البيانات',
  'tile_subtitle': 'ما الذي يُسجَّل وما هي حقوقك',
  'center_tile_title': 'حماية البيانات',
  'center_tile_subtitle': 'قراءة الإشعارات والتواصل معنا',

  'status_open': 'لا يزال مفتوحًا',
  'status_ack': 'تم التأكيد في {date}',
  'status_declined': 'لم يتم التأكيد في {date}',
  'status_update': 'نسخة جديدة – يُرجى الاطلاع عليها مرة أخرى',

  'course_progress': '{n} / {total}',
  'course_next': 'متابعة',
  'course_to_ack': 'إلى التأكيد',
  'doc_gate_hint': 'يُرجى فتح المستند وقراءته للمتابعة.',

  'doc_read_hint': 'يُرجى قراءة المستند حتى نهايته.',
  'doc_read_done': 'تمت القراءة',
  'doc_version': 'الإصدار {version}',
  'doc_checksum': 'المجموع الاختباري {hash}',

  'binding_label': 'الصيغة الملزمة (بالألمانية)',
  'translation_label': 'الترجمة',

  'ack_back': 'رجوع',
  'ack_decline_confirm': 'عدم التأكيد',
  'ack_signature_clear': 'مسح',
  'later_label': 'لاحقًا',
  'signature_required_hint': 'يُرجى التوقيع للتأكيد.',
  'signature_export_failed': 'تعذّر التقاط التوقيع. يُرجى التوقيع مرة أخرى.',
  'ack_save_error': 'فشل الحفظ: {error}',
  'ok': 'OK',

  'center_course_open': 'بدء الدورة',
  'center_course_repeat': 'إعادة مشاهدة الدورة',
  'center_status_none': 'لا يوجد حتى الآن أي إقرار باستلام مسجَّل.',
  'center_status_ack': 'تم تأكيد الاستلام في {date}.',
  'center_status_declined':
      'مُدوَّن في {date}: تم تسليم الإشعار ولم يتم توقيع الإقرار.',
  'center_status_outdated': 'تتوفر نسخة أحدث من إشعار حماية البيانات.',
  'center_contact_button': 'إرسال بريد إلكتروني',
  'center_mail_error': 'تعذَّر فتح برنامج البريد الإلكتروني.',
  'center_signature_saved': 'مع توقيع',
  'center_signature_none': 'بدون توقيع',

  'admin_title': 'الكاميرات داخل المركبة – حماية البيانات',
  'admin_subtitle':
      'إقرارات باستلام إشعار تقنية السلامة المرورية – '
      'علم واطلاع، وليست موافقة.',
  'admin_count_ack': 'مؤكَّد',
  'admin_count_declined': 'غير مؤكَّد',
  'admin_count_open': 'مفتوح',
  'admin_search': 'البحث عن سائق',
  'admin_refresh': 'تحديث',
  'admin_empty_drivers': 'لم يتم العثور على سائقين نشطين.',
  'admin_status_ack': 'مؤكَّد',
  'admin_status_declined': 'غير مؤكَّد',
  'admin_status_open': 'مفتوح',
  'admin_status_outdated': 'نسخة قديمة',
  'admin_decline_note': 'ملاحظة',
  'admin_detail_version': 'الإصدار {version} · المجموع الاختباري {hash}',
  'admin_detail_language': 'تمت القراءة بلغة {lang}',
  'admin_detail_read': 'تمت قراءة النص الكامل لمدة {seconds} ث',
  'admin_detail_scrolled': 'تم التمرير حتى النهاية',
  'admin_detail_signature': 'التوقيع موجود',
  'admin_detail_no_signature': 'بدون توقيع',
  'admin_hint_no_gate':
      'ملاحظة: لا يحجب هذا النموذج تطبيق السائق عن قصد. الرفض ليس خطأً، '
      'بل هو إثبات صالح على تسليم الإشعار.',
};

// ── Türkçe (Türkisch) ───────────────────────────────────────────────
const Map<String, String> _tr = {
  'tile_title': 'Araç içi kameralar – veri koruma',
  'tile_subtitle': 'Neyin kaydedildiği ve hangi haklara sahip olduğunuz',
  'center_tile_title': 'Veri koruma',
  'center_tile_subtitle': 'Bilgilendirmeleri okuyun ve bizimle iletişime geçin',

  'status_open': 'Henüz açık',
  'status_ack': '{date} tarihinde teyit edildi',
  'status_declined': '{date} tarihinde teyit edilmedi',
  'status_update': 'Yeni sürüm – lütfen tekrar bilgi edinin',

  'course_progress': '{n} / {total}',
  'course_next': 'Devam',
  'course_to_ack': 'Teyide git',
  'doc_gate_hint': 'Devam etmek için lütfen belgeyi açıp okuyun.',

  'doc_read_hint': 'Lütfen belgeyi sonuna kadar okuyun.',
  'doc_read_done': 'Okundu',
  'doc_version': 'Sürüm {version}',
  'doc_checksum': 'Sağlama toplamı {hash}',

  'binding_label': 'Bağlayıcı metin (Almanca)',
  'translation_label': 'Çeviri',

  'ack_back': 'Geri',
  'ack_decline_confirm': 'Teyit etme',
  'ack_signature_clear': 'Sil',
  'later_label': 'Daha sonra',
  'signature_required_hint': 'Teyit etmek için lütfen imzalayın.',
  'signature_export_failed': 'İmza alınamadı. Lütfen tekrar imzalayın.',
  'ack_save_error': 'Kaydetme başarısız oldu: {error}',
  'ok': 'OK',

  'center_course_open': 'Kursu başlat',
  'center_course_repeat': 'Kursu tekrar izle',
  'center_status_none': 'Henüz kayıtlı bir teslim alma teyidi yok.',
  'center_status_ack': 'Teslim alma {date} tarihinde teyit edildi.',
  'center_status_declined':
      '{date} tarihinde kaydedildi: bilgilendirme teslim edildi, teyit '
      'imzalanmadı.',
  'center_status_outdated':
      'Veri koruma bilgilendirmesinin daha yeni bir sürümü mevcut.',
  'center_contact_button': 'E-posta gönder',
  'center_mail_error': 'E-posta programı açılamadı.',
  'center_signature_saved': 'İmzalı',
  'center_signature_none': 'İmzasız',

  'admin_title': 'Araç içi kameralar – veri koruma',
  'admin_subtitle':
      'Trafik güvenliği teknolojisine ilişkin teslim alma teyitleri – '
      'bilgi edinme, rıza değil.',
  'admin_count_ack': 'Teyit edildi',
  'admin_count_declined': 'Teyit edilmedi',
  'admin_count_open': 'Açık',
  'admin_search': 'Sürücü ara',
  'admin_refresh': 'Yenile',
  'admin_empty_drivers': 'Etkin sürücü bulunamadı.',
  'admin_status_ack': 'Teyit edildi',
  'admin_status_declined': 'Teyit edilmedi',
  'admin_status_open': 'Açık',
  'admin_status_outdated': 'Eski sürüm',
  'admin_decline_note': 'Not',
  'admin_detail_version': 'Sürüm {version} · sağlama toplamı {hash}',
  'admin_detail_language': '{lang} dilinde okundu',
  'admin_detail_read': 'Tam metin {seconds} sn okundu',
  'admin_detail_scrolled': 'sonuna kadar kaydırıldı',
  'admin_detail_signature': 'imza mevcut',
  'admin_detail_no_signature': 'imzasız',
  'admin_hint_no_gate':
      'Not: bu modül sürücü uygulamasını bilerek engellemez. Reddetme bir '
      'hata değil, bilgilendirmenin teslim edildiğine dair geçerli bir '
      'kanıttır.',
};

// ── Русский (Russisch) ──────────────────────────────────────────────
const Map<String, String> _ru = {
  'tile_title': 'Камеры в автомобиле – защита данных',
  'tile_subtitle': 'Что записывается и какие права у вас есть',
  'center_tile_title': 'Защита данных',
  'center_tile_subtitle': 'Ознакомьтесь с уведомлениями и свяжитесь с нами',

  'status_open': 'Ещё не подтверждено',
  'status_ack': 'Подтверждено {date}',
  'status_declined': 'Не подтверждено {date}',
  'status_update': 'Новая редакция – просим ознакомиться повторно',

  'course_progress': '{n} / {total}',
  'course_next': 'Далее',
  'course_to_ack': 'К подтверждению',
  'doc_gate_hint':
      'Пожалуйста, откройте и прочитайте документ, чтобы продолжить.',

  'doc_read_hint': 'Пожалуйста, прочитайте документ до конца.',
  'doc_read_done': 'Прочитано',
  'doc_version': 'Редакция {version}',
  'doc_checksum': 'Контрольная сумма {hash}',

  'binding_label': 'Обязательная редакция текста (немецкий)',
  'translation_label': 'Перевод',

  'ack_back': 'Назад',
  'ack_decline_confirm': 'Не подтверждать',
  'ack_signature_clear': 'Очистить',
  'later_label': 'Позже',
  'signature_required_hint': 'Пожалуйста, подпишите, чтобы подтвердить.',
  'signature_export_failed': 'Не удалось получить подпись. Пожалуйста, подпишите ещё раз.',
  'ack_save_error': 'Не удалось сохранить: {error}',
  'ok': 'OK',

  'center_course_open': 'Начать курс',
  'center_course_repeat': 'Просмотреть курс ещё раз',
  'center_status_none': 'Подтверждение получения пока не зафиксировано.',
  'center_status_ack': 'Получение подтверждено {date}.',
  'center_status_declined':
      'Зафиксировано {date}: уведомление вручено, подтверждение не '
      'подписано.',
  'center_status_outdated':
      'Доступна более новая редакция уведомления о защите данных.',
  'center_contact_button': 'Написать письмо',
  'center_mail_error': 'Не удалось открыть почтовую программу.',
  'center_signature_saved': 'С подписью',
  'center_signature_none': 'Без подписи',

  'admin_title': 'Камеры в автомобиле – защита данных',
  'admin_subtitle':
      'Подтверждения получения уведомления о технологии безопасности '
      'дорожного движения – ознакомление, а не согласие.',
  'admin_count_ack': 'Подтверждено',
  'admin_count_declined': 'Не подтверждено',
  'admin_count_open': 'Открыто',
  'admin_search': 'Поиск водителя',
  'admin_refresh': 'Обновить',
  'admin_empty_drivers': 'Активные водители не найдены.',
  'admin_status_ack': 'Подтверждено',
  'admin_status_declined': 'Не подтверждено',
  'admin_status_open': 'Открыто',
  'admin_status_outdated': 'Старая редакция',
  'admin_decline_note': 'Отметка',
  'admin_detail_version': 'Редакция {version} · контрольная сумма {hash}',
  'admin_detail_language': 'прочитано на языке {lang}',
  'admin_detail_read': 'Полный текст читался {seconds} с',
  'admin_detail_scrolled': 'прокручено до конца',
  'admin_detail_signature': 'подпись имеется',
  'admin_detail_no_signature': 'без подписи',
  'admin_hint_no_gate':
      'Примечание: этот модуль намеренно не блокирует приложение водителя. '
      'Отказ – не ошибка, а действительное подтверждение того, что '
      'уведомление было вручено.',
};

// ── Български (Bulgarisch) ──────────────────────────────────────────
const Map<String, String> _bg = {
  'tile_title': 'Камери в превозното средство – защита на данните',
  'tile_subtitle': 'Какво се записва и какви права имате',
  'center_tile_title': 'Защита на данните',
  'center_tile_subtitle': 'Прочетете съобщенията и се свържете с нас',

  'status_open': 'Все още предстои',
  'status_ack': 'Потвърдено на {date}',
  'status_declined': 'Непотвърдено на {date}',
  'status_update': 'Нова редакция – моля, запознайте се отново',

  'course_progress': '{n} / {total}',
  'course_next': 'Напред',
  'course_to_ack': 'Към потвърждението',
  'doc_gate_hint': 'Моля, отворете и прочетете документа, за да продължите.',

  'doc_read_hint': 'Моля, прочетете документа докрай.',
  'doc_read_done': 'Прочетено',
  'doc_version': 'Редакция {version}',
  'doc_checksum': 'Контролна сума {hash}',

  'binding_label': 'Обвързващ текст (немски)',
  'translation_label': 'Превод',

  'ack_back': 'Назад',
  'ack_decline_confirm': 'Не потвърждавам',
  'ack_signature_clear': 'Изчисти',
  'later_label': 'По-късно',
  'signature_required_hint': 'Моля, подпишете, за да потвърдите.',
  'signature_export_failed': 'Подписът не можа да бъде получен. Моля, подпишете отново.',
  'ack_save_error': 'Запазването е неуспешно: {error}',
  'ok': 'OK',

  'center_course_open': 'Стартиране на курса',
  'center_course_repeat': 'Преглед на курса отново',
  'center_status_none': 'Все още няма записано потвърждение за получаване.',
  'center_status_ack': 'Получаването е потвърдено на {date}.',
  'center_status_declined':
      'Отбелязано на {date}: съобщението е връчено, потвърждението не е '
      'подписано.',
  'center_status_outdated':
      'Налична е по-нова редакция на съобщението за защита на данните.',
  'center_contact_button': 'Изпращане на имейл',
  'center_mail_error': 'Имейл програмата не можа да бъде отворена.',
  'center_signature_saved': 'С подпис',
  'center_signature_none': 'Без подпис',

  'admin_title': 'Камери в превозното средство – защита на данните',
  'admin_subtitle':
      'Потвърждения за получаване на съобщението за технологията за пътна '
      'безопасност – запознаване, а не съгласие.',
  'admin_count_ack': 'Потвърдени',
  'admin_count_declined': 'Непотвърдени',
  'admin_count_open': 'Предстоящи',
  'admin_search': 'Търсене на шофьор',
  'admin_refresh': 'Обновяване',
  'admin_empty_drivers': 'Не са намерени активни шофьори.',
  'admin_status_ack': 'Потвърдено',
  'admin_status_declined': 'Непотвърдено',
  'admin_status_open': 'Предстои',
  'admin_status_outdated': 'Стара редакция',
  'admin_decline_note': 'Забележка',
  'admin_detail_version': 'Редакция {version} · контролна сума {hash}',
  'admin_detail_language': 'прочетено на {lang}',
  'admin_detail_read': 'Пълният текст е четен {seconds} с',
  'admin_detail_scrolled': 'превъртяно до края',
  'admin_detail_signature': 'има подпис',
  'admin_detail_no_signature': 'без подпис',
  'admin_hint_no_gate':
      'Забележка: този модул умишлено не блокира приложението на шофьора. '
      'Отказът не е грешка, а валидно доказателство, че съобщението е '
      'връчено.',
};

// ── Español (Spanisch) ──────────────────────────────────────────────
const Map<String, String> _es = {
  'tile_title': 'Cámaras en el vehículo – protección de datos',
  'tile_subtitle': 'Qué se graba y qué derechos tiene usted',
  'center_tile_title': 'Protección de datos',
  'center_tile_subtitle': 'Lea las informaciones y póngase en contacto',

  'status_open': 'Aún pendiente',
  'status_ack': 'Confirmado el {date}',
  'status_declined': 'No confirmado el {date}',
  'status_update': 'Nueva versión – tome nota de nuevo, por favor',

  'course_progress': '{n} / {total}',
  'course_next': 'Continuar',
  'course_to_ack': 'Ir a la confirmación',
  'doc_gate_hint': 'Abra y lea el documento para continuar.',

  'doc_read_hint': 'Lea el documento hasta el final.',
  'doc_read_done': 'Leído',
  'doc_version': 'Versión {version}',
  'doc_checksum': 'Suma de comprobación {hash}',

  'binding_label': 'Texto vinculante (alemán)',
  'translation_label': 'Traducción',

  'ack_back': 'Atrás',
  'ack_decline_confirm': 'No confirmar',
  'ack_signature_clear': 'Borrar',
  'later_label': 'Más tarde',
  'signature_required_hint': 'Por favor, firme para confirmar.',
  'signature_export_failed': 'No se ha podido capturar la firma. Por favor, firme de nuevo.',
  'ack_save_error': 'Error al guardar: {error}',
  'ok': 'OK',

  'center_course_open': 'Iniciar el curso',
  'center_course_repeat': 'Volver a ver el curso',
  'center_status_none': 'Todavía no consta ninguna confirmación de recepción.',
  'center_status_ack': 'Recepción confirmada el {date}.',
  'center_status_declined':
      'Registrado el {date}: información entregada, confirmación no '
      'firmada.',
  'center_status_outdated':
      'Existe una versión más reciente de la información sobre protección '
      'de datos.',
  'center_contact_button': 'Escribir un correo',
  'center_mail_error': 'No se pudo abrir el programa de correo.',
  'center_signature_saved': 'Con firma',
  'center_signature_none': 'Sin firma',

  'admin_title': 'Cámaras en el vehículo – protección de datos',
  'admin_subtitle':
      'Confirmaciones de recepción sobre la tecnología de seguridad vial – '
      'toma de conocimiento, no consentimiento.',
  'admin_count_ack': 'Confirmado',
  'admin_count_declined': 'No confirmado',
  'admin_count_open': 'Pendiente',
  'admin_search': 'Buscar conductor',
  'admin_refresh': 'Actualizar',
  'admin_empty_drivers': 'No se han encontrado conductores activos.',
  'admin_status_ack': 'Confirmado',
  'admin_status_declined': 'No confirmado',
  'admin_status_open': 'Pendiente',
  'admin_status_outdated': 'Versión antigua',
  'admin_decline_note': 'Anotación',
  'admin_detail_version': 'Versión {version} · suma de comprobación {hash}',
  'admin_detail_language': 'leído en {lang}',
  'admin_detail_read': 'Texto completo leído durante {seconds} s',
  'admin_detail_scrolled': 'desplazado hasta el final',
  'admin_detail_signature': 'firma disponible',
  'admin_detail_no_signature': 'sin firma',
  'admin_hint_no_gate':
      'Nota: este módulo no bloquea deliberadamente la aplicación del '
      'conductor. La negativa no es un error, sino una prueba válida de que '
      'la información fue entregada.',
};

/// Auflösung wie bei den übrigen Schulungen: gesuchte Sprache, sonst
/// Englisch, sonst Deutsch. `{var}`-Platzhalter werden ersetzt.
String privacyCameraText(
  String languageCode,
  String key, {
  Map<String, String>? vars,
}) {
  final lang = languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;
  final table = _privacyCameraTables[lang] ?? _en;
  var out = table[key] ?? _en[key] ?? _de[key] ?? key;
  if (vars != null) {
    for (final entry in vars.entries) {
      out = out.replaceAll('{${entry.key}}', entry.value);
    }
  }
  return out;
}

const Map<String, Map<String, String>> _privacyCameraTables = {
  'de': _de,
  'en': _en,
  'sq': _sq,
  'hu': _hu,
  'ro': _ro,
  'hr': _hr,
  'ar': _ar,
  'tr': _tr,
  'ru': _ru,
  'bg': _bg,
  'es': _es,
};
