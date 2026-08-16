// lib/data/privacy_notice/privacy_notice_texts.dart
//
// Bedien-/UI-Texte der verpflichtenden Datenschutzinformation nach
// Art. 13 DSGVO, je Sprache eine Map mit identischem Key-Satz
// (Vertrag). Platzhalter in geschweiften Klammern, z. B. {n}, {m}, {v},
// {date}, {error}. Auflösung mit Fallback-Kette locale -> en -> de,
// analog zu green_book_texts.dart.
//
// SPRACHREGEL (wichtig, nicht kosmetisch):
// Diese Seite ist eine INFORMATION mit Bestätigung der Kenntnisnahme.
// In allen Sprachen gilt deshalb: „Ich wurde informiert" / „Ich habe
// gelesen und verstanden". Keine Formulierung, die nach einer vom
// Fahrer erteilten Erlaubnis für die Verarbeitung klingt — im
// Beschäftigungsverhältnis wäre eine solche Erklärung wegen des
// Abhängigkeitsverhältnisses kaum freiwillig und jederzeit widerruflich.
//
// Bewusst NICHT übersetzt (bleiben in allen Sprachen gleich):
// die Rechtsbegriffe 'DSGVO', 'Art. 13', 'Art. 15', 'Art. 21',
// 'Art. 77' sowie der Eigenname 'CoDriver' — bei den Rechtsbegriffen
// ist eine kurze Erläuterung in Klammern in der Zielsprache ergänzt.
//
// GESTUFTES HINWEISMODELL (Art. 12 Abs. 1 DSGVO):
// Beim Login erscheint nur die Kurzinformation (`popup_*`). Der
// Volltext ist von dort einen Klick entfernt (`btn_read_full`) und
// bleibt auch danach jederzeit erreichbar (`later_entry_sub`). Die
// Kurzinformation ersetzt den Volltext nicht — sie führt zu ihm.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsDe = {
  'appbar_title': 'Datenschutzinformation',
  'intro_title': 'Datenschutzinformation für Fahrer',
  'intro_meta': '{n} Abschnitte · Fassung {v} · Stand {date}',
  'intro_body': 'Bevor du weiterarbeitest, informieren wir dich nach '
      'Art. 13 DSGVO: welche Daten über dich verarbeitet werden, wozu, '
      'auf welcher Rechtsgrundlage und wie lange sie gespeichert '
      'bleiben. Lies die Abschnitte durch und bestätige am Ende mit '
      'deiner Unterschrift, dass du sie gelesen und verstanden hast.',
  'intro_note': 'Das ist eine Information — keine Erlaubnis, die du '
      'erteilst. Deine Unterschrift bestätigt ausschließlich die '
      'Kenntnisnahme.',
  'responsible_label': 'Verantwortlich',
  'sections_title': 'Das erwartet dich',
  'btn_read': 'Information lesen',
  'btn_logout': 'Abmelden',
  'progress': 'Abschnitt {n} von {m}',
  'btn_back': 'Zurück',
  'btn_next': 'Weiter',
  'btn_to_ack': 'Weiter zur Bestätigung',
  'ack_title': 'Kenntnisnahme bestätigen',
  'ack_body': 'Du hast alle {m} Abschnitte gesehen. Bestätige jetzt, '
      'dass du die Datenschutzinformation in der Fassung {v} gelesen '
      'und verstanden hast.',
  'ack_checkbox': 'Ich wurde nach Art. 13 DSGVO informiert. Ich habe '
      'die Datenschutzinformation gelesen und verstanden.',
  'ack_note': 'Deine Bestätigung ändert nichts an deinen Rechten aus '
      'Art. 15 bis 21 DSGVO und an deinem Beschwerderecht nach '
      'Art. 77 DSGVO.',
  'sign_label': 'Deine Unterschrift',
  'btn_accept': 'Akzeptieren',
  'accept_note': 'Mit „Akzeptieren“ bestätigst du, dass du diese '
      'Datenschutzinformation zur Kenntnis genommen hast. Das ist '
      'keine Einwilligung — du erlaubst damit nichts.',
  'sign_hint': 'Unterschreibe mit dem Finger oder der Maus im Feld.',
  'btn_clear': 'Löschen',
  'btn_submit': 'Unterschreiben und bestätigen',
  'err_need_check': 'Bitte bestätige zuerst, dass du die Information '
      'gelesen und verstanden hast.',
  'err_need_signature': 'Bitte unterschreibe im Feld — ohne '
      'Unterschrift lässt sich die Bestätigung nicht abschließen.',
  'err_save': 'Speichern fehlgeschlagen: {error}',
  'done_title': 'Bestätigt — danke!',
  'done_body': 'Deine Kenntnisnahme ist gespeichert. Den Nachweis mit '
      'deiner Unterschrift findest du als PDF bei deinen '
      'Fahrerdokumenten. Ändert sich die Information, legen wir sie dir '
      'erneut vor.',
  'btn_done': 'Zur App',
  'gate_loading': 'Einen Moment …',
  'gate_error': 'Deine Datenschutzinformation konnte nicht geladen '
      'werden. Bitte prüfe deine Verbindung und versuch es erneut.',
  'btn_retry': 'Erneut versuchen',
  // ── Kurzinformation (Pop-up) ──────────────────────────────────────
  'popup_title': 'Kurzinformation zum Datenschutz',
  'popup_meta': 'Fassung {v} · Stand {date}',
  'popup_intro': 'In der App CoDriver werden Daten verarbeitet, die für '
      'deine Arbeit nötig sind. Hier die wichtigsten Punkte — Information '
      'nach Art. 13 DSGVO.',
  'popup_b_data': 'In der App: Anmeldung und Stammdaten, '
      'Arbeitszeiterfassung, DA Academy, Dokumente, Schicht- und '
      'Wellenplanung, Scorecard',
  'popup_b_purpose': 'Wozu: Durchführung des Arbeitsverhältnisses und '
      'gesetzliche Pflichten',
  'popup_b_rights': 'Deine Rechte: Auskunft, Berichtigung, Löschung — '
      'Details im Volltext',
  'popup_scope': 'Nur für die App: Für Lohnabrechnung, Personalakte oder '
      'Arbeitsvertrag gilt die eigene Datenschutzinformation deines '
      'Arbeitgebers.',
  'btn_read_full': 'Vollständige Information lesen',
  'btn_close': 'Schließen',
  'detail_readonly_note': 'Vollständige Information nach Art. 13 DSGVO '
      '— hier nur zum Nachlesen.',
  'later_entry_sub': 'Kurzinformation und Volltext jederzeit nachlesen',
  'ack_confirmed_on': 'Kenntnisnahme bestätigt am {date}',
  'ack_not_yet': 'Noch keine Kenntnisnahme gespeichert.',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsEn = {
  'appbar_title': 'Privacy information',
  'intro_title': 'Privacy information for drivers',
  'intro_meta': '{n} sections · version {v} · as of {date}',
  'intro_body': 'Before you continue working, we are informing you as '
      'required by Art. 13 DSGVO (EU General Data Protection '
      'Regulation, GDPR): which data about you is processed, for what '
      'purpose, on what legal basis and how long it is stored. Read '
      'through the sections and confirm at the end with your signature '
      'that you have read and understood them.',
  'intro_note': 'This is information — not a permission you grant. '
      'Your signature confirms only that you have taken note of it.',
  'responsible_label': 'Controller',
  'sections_title': 'What you will read',
  'btn_read': 'Read the information',
  'btn_logout': 'Sign out',
  'progress': 'Section {n} of {m}',
  'btn_back': 'Back',
  'btn_next': 'Next',
  'btn_to_ack': 'Continue to confirmation',
  'ack_title': 'Confirm that you have read it',
  'ack_body': 'You have seen all {m} sections. Now confirm that you '
      'have read and understood version {v} of this privacy '
      'information.',
  'ack_checkbox': 'I have been informed in accordance with Art. 13 '
      'DSGVO (GDPR). I have read and understood this privacy '
      'information.',
  'ack_note': 'Your confirmation does not affect your rights under '
      'Art. 15 to 21 DSGVO (GDPR) or your right to lodge a complaint '
      'under Art. 77 DSGVO (GDPR).',
  'sign_label': 'Your signature',
  'btn_accept': 'Accept',
  'accept_note': 'By tapping “Accept” you confirm that you have taken '
      'note of this privacy information. This is not consent — you '
      'are not granting any permission.',
  'sign_hint': 'Sign in the field with your finger or the mouse.',
  'btn_clear': 'Clear',
  'btn_submit': 'Sign and confirm',
  'err_need_check': 'Please confirm first that you have read and '
      'understood the information.',
  'err_need_signature': 'Please sign in the field — the confirmation '
      'cannot be completed without a signature.',
  'err_save': 'Saving failed: {error}',
  'done_title': 'Confirmed — thank you!',
  'done_body': 'Your confirmation has been saved. You will find the '
      'record with your signature as a PDF with your driver documents. '
      'If the information changes, we will present it to you again.',
  'btn_done': 'Go to the app',
  'gate_loading': 'One moment …',
  'gate_error': 'Your privacy information could not be loaded. Please '
      'check your connection and try again.',
  'btn_retry': 'Try again',
  // ── Short information (pop-up) ────────────────────────────────────
  'popup_title': 'Privacy at a glance',
  'popup_meta': 'Version {v} · as of {date}',
  'popup_intro': 'The CoDriver app processes data needed for your work. '
      'Here are the key points — information under Art. 13 DSGVO (GDPR).',
  'popup_b_data': 'In the app: sign-in and master data, time recording, '
      'DA Academy, documents, shift and wave planning, scorecard',
  'popup_b_purpose': 'Why: carrying out the employment relationship and '
      'legal obligations',
  'popup_b_rights': 'Your rights: access, rectification, erasure — '
      'details in the full text',
  'popup_scope': 'App only: payroll, personnel file or employment '
      'contract are covered by your employer’s own privacy information.',
  'btn_read_full': 'Read the full information',
  'btn_close': 'Close',
  'detail_readonly_note': 'Full information under Art. 13 DSGVO (GDPR) '
      '— for reading only.',
  'later_entry_sub': 'Read the short version and the full text any time',
  'ack_confirmed_on': 'Confirmed as read on {date}',
  'ack_not_yet': 'No confirmation stored yet.',
};

// ── Shqip (Albanisch) ───────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsSq = {
  'appbar_title': 'Informacion për mbrojtjen e të dhënave',
  'intro_title': 'Informacion për mbrojtjen e të dhënave për shoferët',
  'intro_meta': '{n} seksione · versioni {v} · gjendja {date}',
  'intro_body': 'Përpara se të vazhdosh punën, të informojmë sipas '
      'Art. 13 DSGVO (Rregullorja e Përgjithshme e BE-së për Mbrojtjen '
      'e të Dhënave, GDPR): cilat të dhëna për ty përpunohen, për çfarë '
      'qëllimi, mbi cilën bazë ligjore dhe sa gjatë ruhen. Lexoji '
      'seksionet dhe në fund konfirmo me nënshkrimin tënd se i ke '
      'lexuar dhe kuptuar.',
  'intro_note': 'Ky është informacion — jo një leje që jep ti. '
      'Nënshkrimi yt konfirmon vetëm se e ke marrë dijeni.',
  'responsible_label': 'Përgjegjës',
  'sections_title': 'Çfarë do të lexosh',
  'btn_read': 'Lexo informacionin',
  'btn_logout': 'Dil',
  'progress': 'Seksioni {n} nga {m}',
  'btn_back': 'Kthehu',
  'btn_next': 'Vazhdo',
  'btn_to_ack': 'Vazhdo te konfirmimi',
  'ack_title': 'Konfirmo marrjen dijeni',
  'ack_body': 'I ke parë të gjitha {m} seksionet. Tani konfirmo se e ke '
      'lexuar dhe kuptuar versionin {v} të këtij informacioni për '
      'mbrojtjen e të dhënave.',
  'ack_checkbox': 'Jam informuar sipas Art. 13 DSGVO (GDPR). E kam '
      'lexuar dhe kuptuar këtë informacion për mbrojtjen e të dhënave.',
  'ack_note': 'Konfirmimi yt nuk ndryshon asgjë nga të drejtat e tua '
      'sipas Art. 15 deri 21 DSGVO (GDPR) dhe nga e drejta për ankesë '
      'sipas Art. 77 DSGVO (GDPR).',
  'sign_label': 'Nënshkrimi yt',
  'btn_accept': 'Pranoj',
  'accept_note': 'Duke shtypur „Pranoj“ konfirmon se e ke marrë në '
      'dijeni këtë informacion për mbrojtjen e të dhënave. Kjo nuk '
      'është pëlqim — nuk lejon asgjë me të.',
  'sign_hint': 'Nënshkruaj në fushë me gisht ose me miun.',
  'btn_clear': 'Fshij',
  'btn_submit': 'Nënshkruaj dhe konfirmo',
  'err_need_check': 'Të lutem konfirmo më parë se e ke lexuar dhe '
      'kuptuar informacionin.',
  'err_need_signature': 'Të lutem nënshkruaj në fushë — pa nënshkrim '
      'konfirmimi nuk mund të përfundohet.',
  'err_save': 'Ruajtja dështoi: {error}',
  'done_title': 'U konfirmua — faleminderit!',
  'done_body': 'Marrja jote dijeni u ruajt. Dëshminë me nënshkrimin '
      'tënd e gjen si PDF te dokumentet e tua të shoferit. Nëse '
      'informacioni ndryshon, do të ta paraqesim përsëri.',
  'btn_done': 'Te aplikacioni',
  'gate_loading': 'Një moment …',
  'gate_error': 'Informacioni për mbrojtjen e të dhënave nuk u ngarkua '
      'dot. Kontrollo lidhjen dhe provo përsëri.',
  'btn_retry': 'Provo përsëri',
  // ── Informacion i shkurtër (dritare) ──────────────────────────────
  'popup_title': 'Informacion i shkurtër për mbrojtjen e të dhënave',
  'popup_meta': 'Versioni {v} · gjendja {date}',
  'popup_intro': 'Në aplikacionin CoDriver përpunohen të dhënat e '
      'nevojshme për punën tënde. Këtu janë pikat kryesore — informacion '
      'sipas Art. 13 DSGVO (GDPR).',
  'popup_b_data': 'Në aplikacion: hyrja dhe të dhënat bazë, regjistrimi '
      'i orarit të punës, DA Academy, dokumente, planifikimi i turneve '
      'dhe i valëve, scorecard',
  'popup_b_purpose': 'Për çfarë: zbatimi i marrëdhënies së punës dhe '
      'detyrimet ligjore',
  'popup_b_rights': 'Të drejtat e tua: informim, korrigjim, fshirje — '
      'detajet në tekstin e plotë',
  'popup_scope': 'Vetëm për aplikacionin: për pagat, dosjen e personelit '
      'ose kontratën e punës vlen informacioni i veçantë për mbrojtjen e '
      'të dhënave i punëdhënësit tënd.',
  'btn_read_full': 'Lexo informacionin e plotë',
  'btn_close': 'Mbyll',
  'detail_readonly_note': 'Informacioni i plotë sipas Art. 13 DSGVO '
      '(GDPR) — këtu vetëm për lexim.',
  'later_entry_sub': 'Lexo kurdo informacionin e shkurtër dhe tekstin e '
      'plotë',
  'ack_confirmed_on': 'Marrja dijeni u konfirmua më {date}',
  'ack_not_yet': 'Ende nuk është ruajtur asnjë konfirmim.',
};

// ── Magyar (Ungarisch) ──────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsHu = {
  'appbar_title': 'Adatvédelmi tájékoztató',
  'intro_title': 'Adatvédelmi tájékoztató sofőröknek',
  'intro_meta': '{n} fejezet · {v}. változat · állapot: {date}',
  'intro_body': 'Mielőtt tovább dolgozol, tájékoztatunk az Art. 13 '
      'DSGVO (az EU általános adatvédelmi rendelete, GDPR) szerint: '
      'milyen adatokat kezelünk rólad, milyen célból, milyen jogalapon '
      'és meddig tároljuk azokat. Olvasd végig a fejezeteket, és a '
      'végén az aláírásoddal erősítsd meg, hogy elolvastad és '
      'megértetted őket.',
  'intro_note': 'Ez tájékoztatás — nem olyan engedély, amelyet te adsz. '
      'Az aláírásod kizárólag a tudomásulvételt igazolja.',
  'responsible_label': 'Adatkezelő',
  'sections_title': 'Ez vár rád',
  'btn_read': 'Tájékoztató elolvasása',
  'btn_logout': 'Kijelentkezés',
  'progress': '{n}. fejezet a(z) {m}-ból',
  'btn_back': 'Vissza',
  'btn_next': 'Tovább',
  'btn_to_ack': 'Tovább a megerősítéshez',
  'ack_title': 'Tudomásulvétel megerősítése',
  'ack_body': 'Mind a(z) {m} fejezetet láttad. Most erősítsd meg, hogy '
      'az adatvédelmi tájékoztató {v}. változatát elolvastad és '
      'megértetted.',
  'ack_checkbox': 'Az Art. 13 DSGVO (GDPR) szerint tájékoztattak. Az '
      'adatvédelmi tájékoztatót elolvastam és megértettem.',
  'ack_note': 'A megerősítésed nem érinti az Art. 15–21 DSGVO (GDPR) '
      'szerinti jogaidat, sem az Art. 77 DSGVO (GDPR) szerinti '
      'panasztételi jogodat.',
  'sign_label': 'Az aláírásod',
  'btn_accept': 'Elfogadom',
  'accept_note': 'Az „Elfogadom” gombbal megerősíted, hogy tudomásul '
      'vetted ezt az adatvédelmi tájékoztatót. Ez nem hozzájárulás — '
      'semmit sem engedélyezel vele.',
  'sign_hint': 'Írd alá a mezőben ujjal vagy egérrel.',
  'btn_clear': 'Törlés',
  'btn_submit': 'Aláírás és megerősítés',
  'err_need_check': 'Kérjük, először erősítsd meg, hogy elolvastad és '
      'megértetted a tájékoztatót.',
  'err_need_signature': 'Kérjük, írd alá a mezőben — aláírás nélkül a '
      'megerősítés nem fejezhető be.',
  'err_save': 'A mentés nem sikerült: {error}',
  'done_title': 'Megerősítve — köszönjük!',
  'done_body': 'A tudomásulvételed mentve. Az aláírásoddal ellátott '
      'igazolást PDF-ként a sofőr-dokumentumaid között találod. Ha a '
      'tájékoztató változik, újra bemutatjuk neked.',
  'btn_done': 'Az alkalmazáshoz',
  'gate_loading': 'Egy pillanat …',
  'gate_error': 'Az adatvédelmi tájékoztatót nem sikerült betölteni. '
      'Ellenőrizd a kapcsolatot, és próbáld újra.',
  'btn_retry': 'Újra',
  // ── Rövid tájékoztató (felugró ablak) ─────────────────────────────
  'popup_title': 'Rövid adatvédelmi tájékoztató',
  'popup_meta': '{v}. változat · állapot: {date}',
  'popup_intro': 'A CoDriver alkalmazás a munkádhoz szükséges adatokat '
      'kezeli. Itt a legfontosabbak — tájékoztatás az Art. 13 DSGVO '
      '(GDPR) szerint.',
  'popup_b_data': 'Az alkalmazásban: bejelentkezés és törzsadatok, '
      'munkaidő-nyilvántartás, DA Academy, dokumentumok, műszak- és '
      'hullámtervezés, scorecard',
  'popup_b_purpose': 'Miért: a munkaviszony teljesítése és jogi '
      'kötelezettségek',
  'popup_b_rights': 'A jogaid: hozzáférés, helyesbítés, törlés — '
      'részletek a teljes szövegben',
  'popup_scope': 'Csak az alkalmazásra: a bérszámfejtésre, a személyi '
      'anyagra vagy a munkaszerződésre a munkáltatód saját adatvédelmi '
      'tájékoztatója vonatkozik.',
  'btn_read_full': 'Teljes tájékoztató elolvasása',
  'btn_close': 'Bezárás',
  'detail_readonly_note': 'Teljes tájékoztató az Art. 13 DSGVO (GDPR) '
      'szerint — itt csak elolvasásra.',
  'later_entry_sub': 'A rövid és a teljes tájékoztató bármikor '
      'elolvasható',
  'ack_confirmed_on': 'Tudomásulvétel megerősítve: {date}',
  'ack_not_yet': 'Még nincs mentett megerősítés.',
};

// ── Română (Rumänisch) ──────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsRo = {
  'appbar_title': 'Informare privind protecția datelor',
  'intro_title': 'Informare privind protecția datelor pentru șoferi',
  'intro_meta': '{n} secțiuni · versiunea {v} · la data de {date}',
  'intro_body': 'Înainte să continui lucrul, te informăm conform '
      'Art. 13 DSGVO (Regulamentul general al UE privind protecția '
      'datelor, GDPR): ce date despre tine sunt prelucrate, în ce scop, '
      'pe ce temei juridic și cât timp sunt stocate. Citește '
      'secțiunile și confirmă la final, prin semnătura ta, că le-ai '
      'citit și înțeles.',
  'intro_note': 'Aceasta este o informare — nu o permisiune pe care o '
      'acorzi tu. Semnătura ta confirmă exclusiv luarea la cunoștință.',
  'responsible_label': 'Operator',
  'sections_title': 'Ce vei citi',
  'btn_read': 'Citește informarea',
  'btn_logout': 'Deconectare',
  'progress': 'Secțiunea {n} din {m}',
  'btn_back': 'Înapoi',
  'btn_next': 'Continuă',
  'btn_to_ack': 'Continuă spre confirmare',
  'ack_title': 'Confirmă luarea la cunoștință',
  'ack_body': 'Ai văzut toate cele {m} secțiuni. Confirmă acum că ai '
      'citit și înțeles versiunea {v} a acestei informări privind '
      'protecția datelor.',
  'ack_checkbox': 'Am fost informat conform Art. 13 DSGVO (GDPR). Am '
      'citit și am înțeles această informare privind protecția datelor.',
  'ack_note': 'Confirmarea ta nu schimbă cu nimic drepturile tale '
      'conform Art. 15–21 DSGVO (GDPR) și nici dreptul de a depune '
      'plângere conform Art. 77 DSGVO (GDPR).',
  'sign_label': 'Semnătura ta',
  'btn_accept': 'Accept',
  'accept_note': 'Prin „Accept” confirmi că ai luat la cunoștință '
      'această informare privind protecția datelor. Nu este un '
      'consimțământ — nu permiți nimic prin aceasta.',
  'sign_hint': 'Semnează în câmp cu degetul sau cu mouse-ul.',
  'btn_clear': 'Șterge',
  'btn_submit': 'Semnează și confirmă',
  'err_need_check': 'Te rugăm să confirmi mai întâi că ai citit și '
      'înțeles informarea.',
  'err_need_signature': 'Te rugăm să semnezi în câmp — fără semnătură '
      'confirmarea nu poate fi finalizată.',
  'err_save': 'Salvarea a eșuat: {error}',
  'done_title': 'Confirmat — mulțumim!',
  'done_body': 'Luarea ta la cunoștință a fost salvată. Dovada cu '
      'semnătura ta o găsești ca PDF la documentele tale de șofer. Dacă '
      'informarea se modifică, ți-o vom prezenta din nou.',
  'btn_done': 'Către aplicație',
  'gate_loading': 'Un moment …',
  'gate_error': 'Informarea privind protecția datelor nu a putut fi '
      'încărcată. Verifică conexiunea și încearcă din nou.',
  'btn_retry': 'Încearcă din nou',
  // ── Informare scurtă (fereastră) ──────────────────────────────────
  'popup_title': 'Informare scurtă privind protecția datelor',
  'popup_meta': 'Versiunea {v} · la data de {date}',
  'popup_intro': 'Aplicația CoDriver prelucrează datele necesare pentru '
      'munca ta. Iată punctele esențiale — informare conform Art. 13 '
      'DSGVO (GDPR).',
  'popup_b_data': 'În aplicație: autentificare și date de bază, '
      'pontaj, DA Academy, documente, planificarea turelor și a '
      'valurilor, scorecard',
  'popup_b_purpose': 'În ce scop: executarea raportului de muncă și '
      'obligațiile legale',
  'popup_b_rights': 'Drepturile tale: acces, rectificare, ștergere — '
      'detalii în textul complet',
  'popup_scope': 'Doar pentru aplicație: pentru salarizare, dosarul de '
      'personal sau contractul de muncă se aplică informarea proprie a '
      'angajatorului tău.',
  'btn_read_full': 'Citește informarea completă',
  'btn_close': 'Închide',
  'detail_readonly_note': 'Informarea completă conform Art. 13 DSGVO '
      '(GDPR) — aici doar pentru citire.',
  'later_entry_sub': 'Citește oricând informarea scurtă și textul '
      'complet',
  'ack_confirmed_on': 'Luare la cunoștință confirmată la {date}',
  'ack_not_yet': 'Nu este salvată încă nicio confirmare.',
};

// ── Hrvatski (Kroatisch) ────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsHr = {
  'appbar_title': 'Informacija o zaštiti podataka',
  'intro_title': 'Informacija o zaštiti podataka za vozače',
  'intro_meta': '{n} odjeljaka · verzija {v} · stanje {date}',
  'intro_body': 'Prije nego što nastaviš raditi, informiramo te u '
      'skladu s Art. 13 DSGVO (Opća uredba EU o zaštiti podataka, '
      'GDPR): koji se podaci o tebi obrađuju, u koju svrhu, na kojoj '
      'pravnoj osnovi i koliko dugo se pohranjuju. Pročitaj odjeljke i '
      'na kraju svojim potpisom potvrdi da si ih pročitao i razumio.',
  'intro_note': 'Ovo je informacija — nije dopuštenje koje ti daješ. '
      'Tvoj potpis potvrđuje isključivo da si upoznat sa sadržajem.',
  'responsible_label': 'Voditelj obrade',
  'sections_title': 'Što te očekuje',
  'btn_read': 'Pročitaj informaciju',
  'btn_logout': 'Odjava',
  'progress': 'Odjeljak {n} od {m}',
  'btn_back': 'Natrag',
  'btn_next': 'Dalje',
  'btn_to_ack': 'Dalje na potvrdu',
  'ack_title': 'Potvrdi da si upoznat',
  'ack_body': 'Vidio si svih {m} odjeljaka. Sada potvrdi da si '
      'pročitao i razumio verziju {v} ove informacije o zaštiti '
      'podataka.',
  'ack_checkbox': 'Informiran sam u skladu s Art. 13 DSGVO (GDPR). '
      'Pročitao sam i razumio ovu informaciju o zaštiti podataka.',
  'ack_note': 'Tvoja potvrda ne mijenja tvoja prava iz Art. 15 do 21 '
      'DSGVO (GDPR) ni pravo na pritužbu iz Art. 77 DSGVO (GDPR).',
  'sign_label': 'Tvoj potpis',
  'btn_accept': 'Prihvaćam',
  'accept_note': 'Klikom na „Prihvaćam“ potvrđuješ da si primio/la na '
      'znanje ovu informaciju o zaštiti podataka. To nije privola — '
      'time ništa ne dopuštaš.',
  'sign_hint': 'Potpiši se u polju prstom ili mišem.',
  'btn_clear': 'Obriši',
  'btn_submit': 'Potpiši i potvrdi',
  'err_need_check': 'Molimo najprije potvrdi da si pročitao i razumio '
      'informaciju.',
  'err_need_signature': 'Molimo potpiši se u polju — bez potpisa '
      'potvrda se ne može dovršiti.',
  'err_save': 'Spremanje nije uspjelo: {error}',
  'done_title': 'Potvrđeno — hvala!',
  'done_body': 'Tvoja potvrda je spremljena. Dokaz s tvojim potpisom '
      'nalazi se kao PDF među tvojim vozačkim dokumentima. Ako se '
      'informacija promijeni, ponovno ćemo ti je prikazati.',
  'btn_done': 'U aplikaciju',
  'gate_loading': 'Trenutak …',
  'gate_error': 'Informacija o zaštiti podataka nije se mogla učitati. '
      'Provjeri vezu i pokušaj ponovno.',
  'btn_retry': 'Pokušaj ponovno',
  // ── Kratka informacija (skočni prozor) ────────────────────────────
  'popup_title': 'Kratka informacija o zaštiti podataka',
  'popup_meta': 'Verzija {v} · stanje {date}',
  'popup_intro': 'Aplikacija CoDriver obrađuje podatke potrebne za tvoj '
      'rad. Ovo su najvažnije točke — informacija prema Art. 13 DSGVO '
      '(GDPR).',
  'popup_b_data': 'U aplikaciji: prijava i osnovni podaci, evidencija '
      'radnog vremena, DA Academy, dokumenti, planiranje smjena i '
      'valova, scorecard',
  'popup_b_purpose': 'U koju svrhu: izvršavanje radnog odnosa i '
      'zakonske obveze',
  'popup_b_rights': 'Tvoja prava: pristup, ispravak, brisanje — '
      'pojedinosti u cijelom tekstu',
  'popup_scope': 'Samo za aplikaciju: za obračun plaće, personalni '
      'dosje ili ugovor o radu vrijedi zasebna informacija tvog '
      'poslodavca.',
  'btn_read_full': 'Pročitaj cijelu informaciju',
  'btn_close': 'Zatvori',
  'detail_readonly_note': 'Cijela informacija prema Art. 13 DSGVO '
      '(GDPR) — ovdje samo za čitanje.',
  'later_entry_sub': 'Kratku informaciju i cijeli tekst pročitaj kad '
      'god želiš',
  'ack_confirmed_on': 'Upoznatost potvrđena {date}',
  'ack_not_yet': 'Još nije spremljena nijedna potvrda.',
};

// ── Türkçe (Türkisch) ───────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsTr = {
  'appbar_title': 'Veri koruma bilgilendirmesi',
  'intro_title': 'Sürücüler için veri koruma bilgilendirmesi',
  'intro_meta': '{n} bölüm · sürüm {v} · durum {date}',
  'intro_body': 'Çalışmaya devam etmeden önce seni Art. 13 DSGVO (AB '
      'Genel Veri Koruma Tüzüğü, GDPR) uyarınca bilgilendiriyoruz: '
      'hakkında hangi veriler işleniyor, hangi amaçla, hangi hukuki '
      'dayanakla ve ne kadar süre saklanıyor. Bölümleri oku ve sonunda '
      'imzanla okuduğunu ve anladığını onayla.',
  'intro_note': 'Bu bir bilgilendirmedir — senin verdiğin bir izin '
      'değildir. İmzan yalnızca bilgi edindiğini onaylar.',
  'responsible_label': 'Veri sorumlusu',
  'sections_title': 'Seni bekleyen konular',
  'btn_read': 'Bilgilendirmeyi oku',
  'btn_logout': 'Çıkış yap',
  'progress': 'Bölüm {n} / {m}',
  'btn_back': 'Geri',
  'btn_next': 'Devam',
  'btn_to_ack': 'Onaya devam et',
  'ack_title': 'Bilgi edindiğini onayla',
  'ack_body': 'Tüm {m} bölümü gördün. Şimdi bu veri koruma '
      'bilgilendirmesinin {v}. sürümünü okuduğunu ve anladığını onayla.',
  'ack_checkbox': 'Art. 13 DSGVO (GDPR) uyarınca bilgilendirildim. Bu '
      'veri koruma bilgilendirmesini okudum ve anladım.',
  'ack_note': 'Onayın, Art. 15–21 DSGVO (GDPR) kapsamındaki haklarını '
      've Art. 77 DSGVO (GDPR) kapsamındaki şikâyet hakkını hiçbir '
      'şekilde etkilemez.',
  'sign_label': 'İmzan',
  'btn_accept': 'Kabul ediyorum',
  'accept_note': '„Kabul ediyorum“ ile bu veri koruma bilgilendirmesini '
      'okuduğunu ve bilgi aldığını onaylıyorsun. Bu bir rıza değildir — '
      'bununla hiçbir şeye izin vermiş olmazsın.',
  'sign_hint': 'Alana parmağınla veya fareyle imza at.',
  'btn_clear': 'Sil',
  'btn_submit': 'İmzala ve onayla',
  'err_need_check': 'Lütfen önce bilgilendirmeyi okuduğunu ve '
      'anladığını onayla.',
  'err_need_signature': 'Lütfen alana imza at — imza olmadan onay '
      'tamamlanamaz.',
  'err_save': 'Kaydetme başarısız: {error}',
  'done_title': 'Onaylandı — teşekkürler!',
  'done_body': 'Bilgi edindiğin kaydedildi. İmzanı taşıyan belgeyi PDF '
      'olarak sürücü belgelerinin arasında bulabilirsin. '
      'Bilgilendirme değişirse sana yeniden sunacağız.',
  'btn_done': 'Uygulamaya git',
  'gate_loading': 'Bir saniye …',
  'gate_error': 'Veri koruma bilgilendirmen yüklenemedi. Lütfen '
      'bağlantını kontrol edip tekrar dene.',
  'btn_retry': 'Tekrar dene',
  // ── Kısa bilgilendirme (açılır pencere) ───────────────────────────
  'popup_title': 'Kısa veri koruma bilgilendirmesi',
  'popup_meta': 'Sürüm {v} · durum {date}',
  'popup_intro': 'CoDriver uygulaması, işin için gerekli verileri '
      'işler. En önemli noktalar burada — Art. 13 DSGVO (GDPR) uyarınca '
      'bilgilendirme.',
  'popup_b_data': 'Uygulamada: giriş ve temel veriler, mesai kaydı, '
      'DA Academy, belgeler, vardiya ve dalga planlaması, scorecard',
  'popup_b_purpose': 'Ne için: iş ilişkisinin yürütülmesi ve yasal '
      'yükümlülükler',
  'popup_b_rights': 'Haklarınız: bilgi alma, düzeltme, silme — '
      'ayrıntılar tam metinde',
  'popup_scope': 'Yalnızca uygulama için: bordro, personel dosyası veya '
      'iş sözleşmesi için işvereninin kendi veri koruma '
      'bilgilendirmesi geçerlidir.',
  'btn_read_full': 'Bilgilendirmenin tamamını oku',
  'btn_close': 'Kapat',
  'detail_readonly_note': 'Art. 13 DSGVO (GDPR) uyarınca tam '
      'bilgilendirme — burada yalnızca okumak için.',
  'later_entry_sub': 'Kısa bilgiyi ve tam metni istediğin zaman oku',
  'ack_confirmed_on': 'Bilgi edinme {date} tarihinde onaylandı',
  'ack_not_yet': 'Henüz kayıtlı bir onay yok.',
};

// ── Русский (Russisch) ──────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsRu = {
  'appbar_title': 'Информация о защите данных',
  'intro_title': 'Информация о защите данных для водителей',
  'intro_meta': 'Разделов: {n} · версия {v} · по состоянию на {date}',
  'intro_body': 'Прежде чем продолжить работу, мы информируем тебя в '
      'соответствии с Art. 13 DSGVO (Общий регламент ЕС по защите '
      'данных, GDPR): какие данные о тебе обрабатываются, для чего, на '
      'каком правовом основании и как долго они хранятся. Прочитай '
      'разделы и в конце подтверди своей подписью, что прочитал и '
      'понял их.',
  'intro_note': 'Это информация, а не разрешение, которое даёшь ты. '
      'Твоя подпись подтверждает только ознакомление.',
  'responsible_label': 'Ответственный',
  'sections_title': 'Что тебя ждёт',
  'btn_read': 'Прочитать информацию',
  'btn_logout': 'Выйти',
  'progress': 'Раздел {n} из {m}',
  'btn_back': 'Назад',
  'btn_next': 'Далее',
  'btn_to_ack': 'Перейти к подтверждению',
  'ack_title': 'Подтверждение ознакомления',
  'ack_body': 'Ты просмотрел все {m} разделов. Теперь подтверди, что '
      'прочитал и понял версию {v} этой информации о защите данных.',
  'ack_checkbox': 'Я был проинформирован в соответствии с Art. 13 '
      'DSGVO (GDPR). Я прочитал и понял эту информацию о защите данных.',
  'ack_note': 'Твоё подтверждение не влияет на твои права по '
      'Art. 15–21 DSGVO (GDPR) и на право подать жалобу по Art. 77 '
      'DSGVO (GDPR).',
  'sign_label': 'Твоя подпись',
  'btn_accept': 'Принять',
  'accept_note': 'Нажимая «Принять», ты подтверждаешь, что '
      'ознакомился(-лась) с этой информацией о защите данных. '
      'Это не согласие — ты ничего этим не разрешаешь.',
  'sign_hint': 'Распишись в поле пальцем или мышью.',
  'btn_clear': 'Очистить',
  'btn_submit': 'Подписать и подтвердить',
  'err_need_check': 'Пожалуйста, сначала подтверди, что прочитал и '
      'понял информацию.',
  'err_need_signature': 'Пожалуйста, распишись в поле — без подписи '
      'подтверждение невозможно завершить.',
  'err_save': 'Не удалось сохранить: {error}',
  'done_title': 'Подтверждено — спасибо!',
  'done_body': 'Твоё ознакомление сохранено. Документ с твоей подписью '
      'ты найдёшь в формате PDF среди своих водительских документов. '
      'Если информация изменится, мы покажем её тебе снова.',
  'btn_done': 'В приложение',
  'gate_loading': 'Одну минуту …',
  'gate_error': 'Не удалось загрузить информацию о защите данных. '
      'Проверь соединение и попробуй ещё раз.',
  'btn_retry': 'Попробовать снова',
  // ── Краткая информация (всплывающее окно) ─────────────────────────
  'popup_title': 'Краткая информация о защите данных',
  'popup_meta': 'Версия {v} · по состоянию на {date}',
  'popup_intro': 'Приложение CoDriver обрабатывает данные, необходимые '
      'для твоей работы. Вот главное — информация по Art. 13 DSGVO '
      '(GDPR).',
  'popup_b_data': 'В приложении: вход и основные данные, учёт рабочего '
      'времени, DA Academy, документы, планирование смен и волн, '
      'scorecard',
  'popup_b_purpose': 'Для чего: исполнение трудовых отношений и '
      'юридические обязанности',
  'popup_b_rights': 'Твои права: доступ, исправление, удаление — '
      'подробности в полном тексте',
  'popup_scope': 'Только для приложения: для расчёта зарплаты, личного '
      'дела или трудового договора действует отдельная информация '
      'твоего работодателя.',
  'btn_read_full': 'Прочитать полную информацию',
  'btn_close': 'Закрыть',
  'detail_readonly_note': 'Полная информация по Art. 13 DSGVO (GDPR) — '
      'здесь только для чтения.',
  'later_entry_sub': 'Краткую информацию и полный текст можно прочитать '
      'в любое время',
  'ack_confirmed_on': 'Ознакомление подтверждено {date}',
  'ack_not_yet': 'Подтверждение пока не сохранено.',
};

// ── Български (Bulgarisch) ──────────────────────────────────────────
const Map<String, String> privacyNoticeTextsBg = {
  'appbar_title': 'Информация за защита на данните',
  'intro_title': 'Информация за защита на данните за шофьори',
  'intro_meta': '{n} раздела · версия {v} · към {date}',
  'intro_body': 'Преди да продължиш работа, те информираме съгласно '
      'Art. 13 DSGVO (Общ регламент на ЕС относно защитата на данните, '
      'GDPR): какви данни за теб се обработват, за каква цел, на какво '
      'правно основание и колко дълго се съхраняват. Прочети разделите '
      'и накрая потвърди с подписа си, че си ги прочел и разбрал.',
  'intro_note': 'Това е информация — не разрешение, което ти даваш. '
      'Подписът ти потвърждава единствено, че си запознат.',
  'responsible_label': 'Администратор на данните',
  'sections_title': 'Какво те очаква',
  'btn_read': 'Прочети информацията',
  'btn_logout': 'Изход',
  'progress': 'Раздел {n} от {m}',
  'btn_back': 'Назад',
  'btn_next': 'Напред',
  'btn_to_ack': 'Към потвърждението',
  'ack_title': 'Потвърди запознаването',
  'ack_body': 'Видя всички {m} раздела. Сега потвърди, че си прочел и '
      'разбрал версия {v} на тази информация за защита на данните.',
  'ack_checkbox': 'Бях информиран съгласно Art. 13 DSGVO (GDPR). '
      'Прочетох и разбрах тази информация за защита на данните.',
  'ack_note': 'Потвърждението ти не променя правата ти по Art. 15–21 '
      'DSGVO (GDPR), нито правото ти на жалба по Art. 77 DSGVO (GDPR).',
  'sign_label': 'Твоят подпис',
  'btn_accept': 'Приемам',
  'accept_note': 'С „Приемам“ потвърждаваш, че си се запознал(а) с '
      'тази информация за защита на данните. Това не е съгласие — '
      'с това не разрешаваш нищо.',
  'sign_hint': 'Подпиши се в полето с пръст или с мишката.',
  'btn_clear': 'Изчисти',
  'btn_submit': 'Подпиши и потвърди',
  'err_need_check': 'Моля, първо потвърди, че си прочел и разбрал '
      'информацията.',
  'err_need_signature': 'Моля, подпиши се в полето — без подпис '
      'потвърждението не може да бъде завършено.',
  'err_save': 'Запазването е неуспешно: {error}',
  'done_title': 'Потвърдено — благодарим!',
  'done_body': 'Запознаването ти е записано. Документа с твоя подпис '
      'ще намериш като PDF при своите шофьорски документи. Ако '
      'информацията се промени, ще ти я покажем отново.',
  'btn_done': 'Към приложението',
  'gate_loading': 'Един момент …',
  'gate_error': 'Информацията за защита на данните не можа да се '
      'зареди. Провери връзката и опитай отново.',
  'btn_retry': 'Опитай отново',
  // ── Кратка информация (изскачащ прозорец) ─────────────────────────
  'popup_title': 'Кратка информация за защита на данните',
  'popup_meta': 'Версия {v} · към {date}',
  'popup_intro': 'Приложението CoDriver обработва данните, необходими '
      'за работата ти. Ето най-важното — информация съгласно Art. 13 '
      'DSGVO (GDPR).',
  'popup_b_data': 'В приложението: вход и основни данни, отчитане на '
      'работното време, DA Academy, документи, планиране на смени и '
      'вълни, scorecard',
  'popup_b_purpose': 'За какво: изпълнение на трудовото правоотношение '
      'и законови задължения',
  'popup_b_rights': 'Твоите права: достъп, коригиране, изтриване — '
      'подробности в пълния текст',
  'popup_scope': 'Само за приложението: за заплати, лично трудово досие '
      'или трудов договор важи отделната информация на твоя работодател.',
  'btn_read_full': 'Прочети пълната информация',
  'btn_close': 'Затвори',
  'detail_readonly_note': 'Пълна информация съгласно Art. 13 DSGVO '
      '(GDPR) — тук само за прочит.',
  'later_entry_sub': 'Прочети кратката информация и пълния текст по '
      'всяко време',
  'ack_confirmed_on': 'Запознаването е потвърдено на {date}',
  'ack_not_yet': 'Все още няма запазено потвърждение.',
};

// ── العربية (Arabisch) ──────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsAr = {
  'appbar_title': 'معلومات حماية البيانات',
  'intro_title': 'معلومات حماية البيانات للسائقين',
  'intro_meta': '{n} أقسام · الإصدار {v} · بتاريخ {date}',
  'intro_body': 'قبل أن تواصل العمل، نُعلمك وفق Art. 13 DSGVO '
      '(اللائحة الأوروبية العامة لحماية البيانات، GDPR): ما هي '
      'البيانات التي تُعالَج عنك، ولأي غرض، وعلى أي أساس قانوني، وكم '
      'مدة تخزينها. اقرأ الأقسام وأكِّد في النهاية بتوقيعك أنك قرأتها '
      'وفهمتها.',
  'intro_note': 'هذه معلومات — وليست إذناً تمنحه أنت. توقيعك يؤكد فقط '
      'أنك اطلعت عليها.',
  'responsible_label': 'المسؤول عن المعالجة',
  'sections_title': 'ما ينتظرك',
  'btn_read': 'اقرأ المعلومات',
  'btn_logout': 'تسجيل الخروج',
  'progress': 'القسم {n} من {m}',
  'btn_back': 'رجوع',
  'btn_next': 'التالي',
  'btn_to_ack': 'المتابعة إلى التأكيد',
  'ack_title': 'تأكيد الاطلاع',
  'ack_body': 'لقد اطلعت على جميع الأقسام البالغ عددها {m}. أكِّد الآن '
      'أنك قرأت وفهمت الإصدار {v} من معلومات حماية البيانات هذه.',
  'ack_checkbox': 'تم إعلامي وفق Art. 13 DSGVO (GDPR). قرأت معلومات '
      'حماية البيانات هذه وفهمتها.',
  'ack_note': 'تأكيدك لا يغيّر شيئاً من حقوقك بموجب Art. 15 إلى 21 '
      'DSGVO (GDPR) ولا من حقك في تقديم شكوى بموجب Art. 77 DSGVO '
      '(GDPR).',
  'sign_label': 'توقيعك',
  'btn_accept': 'موافق',
  'accept_note': 'بالنقر على ”موافق“ تؤكد أنك اطّلعت على معلومات '
      'حماية البيانات هذه. هذا ليس موافقة على المعالجة — فأنت لا '
      'تمنح بذلك أي إذن.',
  'sign_hint': 'وقّع داخل الحقل بإصبعك أو بالفأرة.',
  'btn_clear': 'مسح',
  'btn_submit': 'وقّع وأكِّد',
  'err_need_check': 'يرجى أولاً تأكيد أنك قرأت المعلومات وفهمتها.',
  'err_need_signature': 'يرجى التوقيع داخل الحقل — لا يمكن إتمام '
      'التأكيد بدون توقيع.',
  'err_save': 'فشل الحفظ: {error}',
  'done_title': 'تم التأكيد — شكراً لك!',
  'done_body': 'تم حفظ اطلاعك. ستجد الإثبات الذي يحمل توقيعك بصيغة PDF '
      'ضمن مستندات السائق الخاصة بك. وإذا تغيّرت المعلومات فسنعرضها '
      'عليك من جديد.',
  'btn_done': 'إلى التطبيق',
  'gate_loading': 'لحظة من فضلك …',
  'gate_error': 'تعذّر تحميل معلومات حماية البيانات. تحقق من اتصالك '
      'وحاول مرة أخرى.',
  'btn_retry': 'حاول مرة أخرى',
  // ── معلومات موجزة (نافذة منبثقة) ──────────────────────────────────
  'popup_title': 'معلومات موجزة عن حماية البيانات',
  'popup_meta': 'الإصدار {v} · بتاريخ {date}',
  'popup_intro': 'يعالج تطبيق CoDriver البيانات اللازمة لعملك. وفيما '
      'يلي أهم النقاط — معلومات وفق Art. 13 DSGVO (GDPR).',
  'popup_b_data': 'في التطبيق: تسجيل الدخول والبيانات الأساسية، تسجيل '
      'وقت العمل، DA Academy، المستندات، تخطيط الورديات والموجات، '
      'البطاقة التقييمية (Scorecard)',
  'popup_b_purpose': 'لماذا: تنفيذ علاقة العمل والالتزامات القانونية',
  'popup_b_rights': 'حقوقك: الوصول والتصحيح والحذف — التفاصيل في النص '
      'الكامل',
  'popup_scope': 'للتطبيق فقط: أما كشوف الرواتب وملف الموظف وعقد العمل '
      'فتسري عليها معلومات حماية البيانات الخاصة بصاحب العمل.',
  'btn_read_full': 'اقرأ المعلومات الكاملة',
  'btn_close': 'إغلاق',
  'detail_readonly_note': 'المعلومات الكاملة وفق Art. 13 DSGVO (GDPR) — '
      'هنا للقراءة فقط.',
  'later_entry_sub': 'اقرأ المعلومات الموجزة والنص الكامل في أي وقت',
  'ack_confirmed_on': 'تم تأكيد الاطلاع في {date}',
  'ack_not_yet': 'لم يُحفظ أي تأكيد بعد.',
};

// ── Español (Spanisch) ──────────────────────────────────────────────
const Map<String, String> privacyNoticeTextsEs = {
  'appbar_title': 'Información sobre protección de datos',
  'intro_title': 'Información sobre protección de datos para '
      'conductores',
  'intro_meta': '{n} apartados · versión {v} · a fecha de {date}',
  'intro_body': 'Antes de que sigas trabajando te informamos conforme '
      'al Art. 13 DSGVO (Reglamento General de Protección de Datos de '
      'la UE, RGPD): qué datos tuyos se tratan, con qué finalidad, sobre '
      'qué base jurídica y durante cuánto tiempo se conservan. Lee los '
      'apartados y confirma al final con tu firma que los has leído y '
      'entendido.',
  'intro_note': 'Esto es una información, no un permiso que tú '
      'concedes. Tu firma confirma únicamente que has tomado '
      'conocimiento de ella.',
  'responsible_label': 'Responsable del tratamiento',
  'sections_title': 'Esto es lo que vas a leer',
  'btn_read': 'Leer la información',
  'btn_logout': 'Cerrar sesión',
  'progress': 'Apartado {n} de {m}',
  'btn_back': 'Atrás',
  'btn_next': 'Siguiente',
  'btn_to_ack': 'Continuar a la confirmación',
  'ack_title': 'Confirmar que la has leído',
  'ack_body': 'Has visto los {m} apartados. Confirma ahora que has '
      'leído y entendido la versión {v} de esta información sobre '
      'protección de datos.',
  'ack_checkbox': 'He sido informado conforme al Art. 13 DSGVO (RGPD). '
      'He leído y entendido esta información sobre protección de datos.',
  'ack_note': 'Tu confirmación no afecta a tus derechos según los '
      'Art. 15 a 21 DSGVO (RGPD) ni a tu derecho a reclamar según el '
      'Art. 77 DSGVO (RGPD).',
  'sign_label': 'Tu firma',
  'btn_accept': 'Aceptar',
  'accept_note': 'Al pulsar «Aceptar» confirmas que has tomado '
      'conocimiento de esta información sobre protección de datos. No '
      'es un consentimiento: con ello no autorizas nada.',
  'sign_hint': 'Firma en el campo con el dedo o con el ratón.',
  'btn_clear': 'Borrar',
  'btn_submit': 'Firmar y confirmar',
  'err_need_check': 'Confirma primero que has leído y entendido la '
      'información.',
  'err_need_signature': 'Firma en el campo: sin firma no se puede '
      'completar la confirmación.',
  'err_save': 'Error al guardar: {error}',
  'done_title': 'Confirmado. ¡Gracias!',
  'done_body': 'Tu confirmación se ha guardado. El justificante con tu '
      'firma lo encuentras en PDF junto a tus documentos de conductor. '
      'Si la información cambia, te la volveremos a presentar.',
  'btn_done': 'Ir a la app',
  'gate_loading': 'Un momento …',
  'gate_error': 'No se ha podido cargar tu información sobre protección '
      'de datos. Comprueba tu conexión e inténtalo de nuevo.',
  'btn_retry': 'Intentar de nuevo',
  // ── Información resumida (ventana emergente) ──────────────────────
  'popup_title': 'Protección de datos de un vistazo',
  'popup_meta': 'Versión {v} · a fecha de {date}',
  'popup_intro': 'La app CoDriver trata los datos necesarios para tu '
      'trabajo. Estos son los puntos clave — información conforme al '
      'Art. 13 DSGVO (RGPD).',
  'popup_b_data': 'En la app: inicio de sesión y datos maestros, '
      'registro de jornada, DA Academy, documentos, planificación de '
      'turnos y oleadas, Scorecard',
  'popup_b_purpose': 'Para qué: ejecución de la relación laboral y '
      'obligaciones legales',
  'popup_b_rights': 'Tus derechos: acceso, rectificación, supresión — '
      'los detalles, en el texto completo',
  'popup_scope': 'Solo para la app: para la nómina, el expediente '
      'personal o el contrato de trabajo se aplica la información sobre '
      'protección de datos propia de tu empresa.',
  'btn_read_full': 'Leer la información completa',
  'btn_close': 'Cerrar',
  'detail_readonly_note': 'Información completa conforme al Art. 13 '
      'DSGVO (RGPD) — aquí solo para consulta.',
  'later_entry_sub': 'Consulta cuando quieras el resumen y el texto '
      'completo',
  'ack_confirmed_on': 'Toma de conocimiento confirmada el {date}',
  'ack_not_yet': 'Todavía no hay ninguna confirmación guardada.',
};

const Map<String, Map<String, String>> privacyNoticeTextsByLang = {
  'de': privacyNoticeTextsDe,
  'en': privacyNoticeTextsEn,
  'sq': privacyNoticeTextsSq,
  'hu': privacyNoticeTextsHu,
  'ro': privacyNoticeTextsRo,
  'hr': privacyNoticeTextsHr,
  'tr': privacyNoticeTextsTr,
  'ru': privacyNoticeTextsRu,
  'bg': privacyNoticeTextsBg,
  'ar': privacyNoticeTextsAr,
  'es': privacyNoticeTextsEs,
};

/// Text-Lookup mit Fallback locale -> en -> de.
///
/// [vars] ersetzt Platzhalter der Form `{key}`.
String privacyNoticeText(
  String lang,
  String key, {
  Map<String, String>? vars,
}) {
  final map = privacyNoticeTextsByLang[lang];
  var out = map?[key] ??
      privacyNoticeTextsEn[key] ??
      privacyNoticeTextsDe[key] ??
      key;
  if (vars != null) {
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
  }
  return out;
}
