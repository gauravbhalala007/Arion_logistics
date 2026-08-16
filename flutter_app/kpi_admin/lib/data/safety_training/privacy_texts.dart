// lib/data/safety_training/privacy_texts.dart
//
// Bedien-/UI-Texte der Datenschutz-Schulung (DSGVO-Grundschulung fuer
// Zustellfahrer), je Sprache eine Map mit identischem Key-Satz
// (Vertrag). Platzhalter in geschweiften Klammern, z. B. {n}, {p},
// {date}. Aufloesung mit Fallback-Kette locale -> en -> de, analog zu
// green_book_texts.dart.
//
// Bewusst NICHT uebersetzt (bleiben in allen Sprachen gleich):
// die Rechtsbegriffe 'DSGVO', 'Art. 5' und 'Art. 33' sowie die
// Eigennamen 'DA Academy' und 'CoDriver' — bei den Rechtsbegriffen ist
// eine kurze Erlaeuterung in Klammern in der Zielsprache ergaenzt.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> privacyTextsDe = {
  'appbar_title': 'Datenschutz',
  'training_title': 'Datenschutz — DSGVO im Zustellalltag',
  'intro_meta': '{c} Kapitel · {s} Seiten · Abschlusstest mit {q} '
      'Fragen',
  'intro_body': 'Du arbeitest jeden Tag mit personenbezogenen Daten: '
      'Empfängernamen, Adressen, Telefonnummern und Fotos als '
      'Ablieferungsnachweis. Nach den Regeln der DSGVO (EU-Datenschutz-'
      'Grundverordnung) zeigt dir diese Schulung, was du mit diesen '
      'Daten darfst und was nicht. Du lernst, was bei einer Datenpanne '
      'zu tun ist (Meldepflicht nach Art. 33 DSGVO) und welche Regeln '
      'für Verschwiegenheit gelten. Am Ende folgen der Abschlusstest '
      'und deine Unterschrift.',
  'status_passed': 'Test bestanden',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' am {date}',
  'status_open': 'Noch nicht abgeschlossen',
  'status_valid_until': 'Gültig bis {date}',
  'btn_view_content': 'Inhalte ansehen',
  'btn_start': 'Schulung starten',
  'chapters_title': 'Kapitel',
  'chapters_hint': 'Arbeite alle Kapitel durch. Danach öffnet sich der '
      'Abschlusstest mit {n} Fragen — bestanden ab {t} %.',
  'btn_exam_start': 'Abschlusstest starten',
  'btn_exam_locked': 'Erst alle Kapitel lesen',
  'chapter_badge': 'K{n}',
  'chapter_read': 'Gelesen · {n} Seiten',
  'chapter_pages': '{n} Seiten',
  'btn_back': 'Zurück',
  'btn_overview': 'Übersicht',
  'btn_chapter_done': 'Kapitel abschließen',
  'btn_next_chapter': 'Nächstes Kapitel',
  'btn_next': 'Weiter',
  'exam_title': 'Abschlusstest',
  'exam_intro': '{n} Fragen · ab {t} % bestanden',
  'exam_attempt': ' · Versuch {n}',
  'result_passed': 'Bestanden — {p} % richtig',
  'result_failed': 'Nicht bestanden — {p} %. Schau dir die Erklärungen '
      'an und versuch es erneut.',
  'btn_retry': 'Nochmal versuchen',
  'btn_check': 'Antworten prüfen',
  'btn_check_progress': 'Antworten prüfen ({a}/{b})',
  'err_save': 'Speichern fehlgeschlagen: {error}',
  'signature_title': 'Teilnahme bestätigen',
  'signature_hint': 'Mit deiner Unterschrift bestätigst du, dass du an '
      'der Datenschutz-Schulung teilgenommen und den Inhalt verstanden '
      'hast. Du hattest Gelegenheit, Fragen zu stellen.',
  'confirm_checkbox': 'Ich habe die Datenschutz-Schulung verstanden und '
      'bestätige meine Teilnahme.',
  'btn_clear': 'Löschen',
  'btn_sign_submit': 'Unterschreiben & abschließen',
  'done_title': 'Schulung abgeschlossen!',
  'done_body': 'Dein Ergebnis und deine Unterschrift wurden '
      'gespeichert. Ab jetzt gilt: Empfängerdaten nur dienstlich '
      'nutzen, Fotos ohne Personen und Kennzeichen, keine Screenshots '
      'von Adresslisten — und jede Datenpanne sofort melden.',
  'done_result': 'Ergebnis: {p} %',
  'done_passed_at': 'Bestanden am {date}',
  'btn_done': 'Fertig',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> privacyTextsEn = {
  'appbar_title': 'Data protection',
  'training_title': 'Data protection — DSGVO (GDPR) in daily delivery '
      'work',
  'intro_meta': '{c} chapters · {s} pages · final test with {q} '
      'questions',
  'intro_body': 'You work with personal data every day: recipient '
      'names, addresses, phone numbers and photos as proof of '
      'delivery. Following the rules of the DSGVO (the German name of '
      'the EU General Data Protection Regulation, GDPR), this training '
      'shows you what you may do with that data and what you may not. '
      'You learn what to do in case of a data breach (duty to report '
      'under Art. 33 DSGVO) and which rules of confidentiality apply. '
      'At the end there is the final test and your signature.',
  'status_passed': 'Test passed',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' on {date}',
  'status_open': 'Not completed yet',
  'status_valid_until': 'Valid until {date}',
  'btn_view_content': 'View content',
  'btn_start': 'Start training',
  'chapters_title': 'Chapters',
  'chapters_hint': 'Work through all chapters. After that the final '
      'test with {n} questions unlocks — pass mark {t} %.',
  'btn_exam_start': 'Start final test',
  'btn_exam_locked': 'Read all chapters first',
  'chapter_badge': 'C{n}',
  'chapter_read': 'Read · {n} pages',
  'chapter_pages': '{n} pages',
  'btn_back': 'Back',
  'btn_overview': 'Overview',
  'btn_chapter_done': 'Finish chapter',
  'btn_next_chapter': 'Next chapter',
  'btn_next': 'Next',
  'exam_title': 'Final test',
  'exam_intro': '{n} questions · pass mark {t} %',
  'exam_attempt': ' · attempt {n}',
  'result_passed': 'Passed — {p} % correct',
  'result_failed': 'Not passed — {p} %. Read the explanations and try '
      'again.',
  'btn_retry': 'Try again',
  'btn_check': 'Check answers',
  'btn_check_progress': 'Check answers ({a}/{b})',
  'err_save': 'Saving failed: {error}',
  'signature_title': 'Confirm participation',
  'signature_hint': 'With your signature you confirm that you took '
      'part in the data protection training and understood its '
      'content. You had the opportunity to ask questions.',
  'confirm_checkbox': 'I have understood the data protection training '
      'and confirm my participation.',
  'btn_clear': 'Clear',
  'btn_sign_submit': 'Sign & finish',
  'done_title': 'Training completed!',
  'done_body': 'Your result and your signature have been saved. From '
      'now on: use recipient data for work purposes only, take photos '
      'without people and licence plates, never screenshot address '
      'lists — and report every data breach immediately.',
  'done_result': 'Result: {p} %',
  'done_passed_at': 'Passed on {date}',
  'btn_done': 'Done',
};

// ── Shqip / Albanian ────────────────────────────────────────────────
const Map<String, String> privacyTextsSq = {
  'appbar_title': 'Mbrojtja e të dhënave',
  'training_title': 'Mbrojtja e të dhënave — DSGVO (GDPR) në '
      'përditshmërinë e dorëzimit',
  'intro_meta': '{c} kapituj · {s} faqe · test përfundimtar me {q} '
      'pyetje',
  'intro_body': 'Çdo ditë punon me të dhëna personale: emra '
      'marrësish, adresa, numra telefoni dhe foto si dëshmi dorëzimi. '
      'Sipas rregullave të DSGVO (rregullorja evropiane për mbrojtjen '
      'e të dhënave, GDPR), ky trajnim të tregon çfarë lejohesh të '
      'bësh me këto të dhëna dhe çfarë jo. Mëson çfarë duhet bërë në '
      'rast shkeljeje të të dhënave (detyrimi i njoftimit sipas '
      'Art. 33 DSGVO) dhe cilat rregulla vlejnë për konfidencialitetin. '
      'Në fund vjen testi përfundimtar dhe nënshkrimi yt.',
  'status_passed': 'Testi u kalua',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' më {date}',
  'status_open': 'Ende e papërfunduar',
  'status_valid_until': 'I vlefshëm deri më {date}',
  'btn_view_content': 'Shiko përmbajtjen',
  'btn_start': 'Fillo trajnimin',
  'chapters_title': 'Kapitujt',
  'chapters_hint': 'Puno të gjithë kapitujt. Pastaj hapet testi '
      'përfundimtar me {n} pyetje — kalohet nga {t} %.',
  'btn_exam_start': 'Fillo testin përfundimtar',
  'btn_exam_locked': 'Lexo së pari të gjithë kapitujt',
  'chapter_badge': 'K{n}',
  'chapter_read': 'E lexuar · {n} faqe',
  'chapter_pages': '{n} faqe',
  'btn_back': 'Prapa',
  'btn_overview': 'Pasqyra',
  'btn_chapter_done': 'Përfundo kapitullin',
  'btn_next_chapter': 'Kapitulli tjetër',
  'btn_next': 'Vazhdo',
  'exam_title': 'Testi përfundimtar',
  'exam_intro': '{n} pyetje · kalohet nga {t} %',
  'exam_attempt': ' · përpjekja {n}',
  'result_passed': 'Kaluar — {p} % saktë',
  'result_failed': 'Nuk u kalua — {p} %. Shiko shpjegimet dhe provo '
      'sërish.',
  'btn_retry': 'Provo sërish',
  'btn_check': 'Kontrollo përgjigjet',
  'btn_check_progress': 'Kontrollo përgjigjet ({a}/{b})',
  'err_save': 'Ruajtja dështoi: {error}',
  'signature_title': 'Konfirmo pjesëmarrjen',
  'signature_hint': 'Me nënshkrimin tënd konfirmon se ke marrë pjesë '
      'në trajnimin për mbrojtjen e të dhënave dhe e ke kuptuar '
      'përmbajtjen. Ke pasur mundësi të bësh pyetje.',
  'confirm_checkbox': 'E kam kuptuar trajnimin për mbrojtjen e të '
      'dhënave dhe konfirmoj pjesëmarrjen time.',
  'btn_clear': 'Fshij',
  'btn_sign_submit': 'Nënshkruaj & përfundo',
  'done_title': 'Trajnimi u përfundua!',
  'done_body': 'Rezultati dhe nënshkrimi yt u ruajtën. Që tani: '
      'përdor të dhënat e marrësve vetëm për punë, bëj foto pa persona '
      'dhe pa targa, mos bëj kurrë pamje ekrani të listave të adresave '
      '— dhe raporto menjëherë çdo shkelje të të dhënave.',
  'done_result': 'Rezultati: {p} %',
  'done_passed_at': 'Kaluar më {date}',
  'btn_done': 'Gati',
};

// ── Magyar / Hungarian ──────────────────────────────────────────────
const Map<String, String> privacyTextsHu = {
  'appbar_title': 'Adatvédelem',
  'training_title': 'Adatvédelem — DSGVO (GDPR) a kézbesítés '
      'mindennapjaiban',
  'intro_meta': '{c} fejezet · {s} oldal · záróteszt {q} kérdéssel',
  'intro_body': 'Minden nap személyes adatokkal dolgozol: címzettek '
      'nevével, címekkel, telefonszámokkal és a kézbesítést igazoló '
      'fotókkal. A DSGVO (az EU általános adatvédelmi rendelete, GDPR) '
      'szabályai alapján ez a képzés megmutatja, mit tehetsz ezekkel '
      'az adatokkal és mit nem. Megtanulod, mi a teendő adatvédelmi '
      'incidens esetén (bejelentési kötelezettség az Art. 33 DSGVO '
      'szerint), és milyen titoktartási szabályok érvényesek. A végén '
      'a záróteszt és az aláírásod következik.',
  'status_passed': 'Teszt teljesítve',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' ekkor: {date}',
  'status_open': 'Még nincs teljesítve',
  'status_valid_until': 'Érvényes eddig: {date}',
  'btn_view_content': 'Tartalom megtekintése',
  'btn_start': 'Képzés indítása',
  'chapters_title': 'Fejezetek',
  'chapters_hint': 'Dolgozd át az összes fejezetet. Utána megnyílik a '
      'záróteszt {n} kérdéssel — {t} %-tól teljesítve.',
  'btn_exam_start': 'Záróteszt indítása',
  'btn_exam_locked': 'Előbb olvasd el az összes fejezetet',
  'chapter_badge': 'F{n}',
  'chapter_read': 'Elolvasva · {n} oldal',
  'chapter_pages': '{n} oldal',
  'btn_back': 'Vissza',
  'btn_overview': 'Áttekintés',
  'btn_chapter_done': 'Fejezet befejezése',
  'btn_next_chapter': 'Következő fejezet',
  'btn_next': 'Tovább',
  'exam_title': 'Záróteszt',
  'exam_intro': '{n} kérdés · {t} %-tól teljesítve',
  'exam_attempt': ' · {n}. próbálkozás',
  'result_passed': 'Teljesítve — {p} % helyes',
  'result_failed': 'Nem sikerült — {p} %. Nézd át a magyarázatokat, és '
      'próbáld újra.',
  'btn_retry': 'Újrapróbálom',
  'btn_check': 'Válaszok ellenőrzése',
  'btn_check_progress': 'Válaszok ellenőrzése ({a}/{b})',
  'err_save': 'A mentés nem sikerült: {error}',
  'signature_title': 'Részvétel megerősítése',
  'signature_hint': 'Aláírásoddal igazolod, hogy részt vettél az '
      'adatvédelmi képzésen és megértetted a tartalmát. Lehetőséged '
      'volt kérdéseket feltenni.',
  'confirm_checkbox': 'Megértettem az adatvédelmi képzést, és '
      'megerősítem a részvételemet.',
  'btn_clear': 'Törlés',
  'btn_sign_submit': 'Aláírás és befejezés',
  'done_title': 'Képzés befejezve!',
  'done_body': 'Az eredményed és az aláírásod mentve. Mostantól: a '
      'címzettek adatait csak munkacélra használd, a fotókon ne legyen '
      'ember és rendszám, soha ne készíts képernyőképet a '
      'címlistákról — és minden adatvédelmi incidenst azonnal jelents.',
  'done_result': 'Eredmény: {p} %',
  'done_passed_at': 'Teljesítve ekkor: {date}',
  'btn_done': 'Kész',
};

// ── Română / Romanian ───────────────────────────────────────────────
const Map<String, String> privacyTextsRo = {
  'appbar_title': 'Protecția datelor',
  'training_title': 'Protecția datelor — DSGVO (GDPR) în activitatea '
      'zilnică de livrare',
  'intro_meta': '{c} capitole · {s} pagini · test final cu {q} '
      'întrebări',
  'intro_body': 'Lucrezi zilnic cu date cu caracter personal: nume de '
      'destinatari, adrese, numere de telefon și fotografii ca dovadă '
      'de livrare. Conform regulilor DSGVO (regulamentul european '
      'privind protecția datelor, GDPR), acest curs îți arată ce ai '
      'voie să faci cu aceste date și ce nu. Afli ce trebuie făcut în '
      'caz de incident de securitate a datelor (obligația de '
      'notificare conform Art. 33 DSGVO) și ce reguli de '
      'confidențialitate se aplică. La final urmează testul final și '
      'semnătura ta.',
  'status_passed': 'Test promovat',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' pe {date}',
  'status_open': 'Încă nefinalizat',
  'status_valid_until': 'Valabil până la {date}',
  'btn_view_content': 'Vezi conținutul',
  'btn_start': 'Începe cursul',
  'chapters_title': 'Capitole',
  'chapters_hint': 'Parcurge toate capitolele. După aceea se deschide '
      'testul final cu {n} întrebări — promovat de la {t} %.',
  'btn_exam_start': 'Începe testul final',
  'btn_exam_locked': 'Citește întâi toate capitolele',
  'chapter_badge': 'C{n}',
  'chapter_read': 'Citit · {n} pagini',
  'chapter_pages': '{n} pagini',
  'btn_back': 'Înapoi',
  'btn_overview': 'Prezentare',
  'btn_chapter_done': 'Finalizează capitolul',
  'btn_next_chapter': 'Capitolul următor',
  'btn_next': 'Continuă',
  'exam_title': 'Test final',
  'exam_intro': '{n} întrebări · promovat de la {t} %',
  'exam_attempt': ' · încercarea {n}',
  'result_passed': 'Promovat — {p} % corect',
  'result_failed': 'Nepromovat — {p} %. Citește explicațiile și '
      'încearcă din nou.',
  'btn_retry': 'Încearcă din nou',
  'btn_check': 'Verifică răspunsurile',
  'btn_check_progress': 'Verifică răspunsurile ({a}/{b})',
  'err_save': 'Salvarea a eșuat: {error}',
  'signature_title': 'Confirmă participarea',
  'signature_hint': 'Prin semnătura ta confirmi că ai participat la '
      'cursul de protecția datelor și ai înțeles conținutul. Ai avut '
      'ocazia să pui întrebări.',
  'confirm_checkbox': 'Am înțeles cursul de protecția datelor și '
      'confirm participarea mea.',
  'btn_clear': 'Șterge',
  'btn_sign_submit': 'Semnează și finalizează',
  'done_title': 'Curs finalizat!',
  'done_body': 'Rezultatul și semnătura ta au fost salvate. De acum: '
      'folosește datele destinatarilor doar în scop de serviciu, '
      'fotografiază fără persoane și fără numere de înmatriculare, nu '
      'face niciodată capturi de ecran ale listelor de adrese — și '
      'raportează imediat orice incident de date.',
  'done_result': 'Rezultat: {p} %',
  'done_passed_at': 'Promovat pe {date}',
  'btn_done': 'Gata',
};

// ── Hrvatski / Croatian ─────────────────────────────────────────────
const Map<String, String> privacyTextsHr = {
  'appbar_title': 'Zaštita podataka',
  'training_title': 'Zaštita podataka — DSGVO (GDPR) u svakodnevnoj '
      'dostavi',
  'intro_meta': '{c} poglavlja · {s} stranica · završni test s {q} '
      'pitanja',
  'intro_body': 'Svaki dan radiš s osobnim podacima: imenima '
      'primatelja, adresama, brojevima telefona i fotografijama kao '
      'dokazom dostave. Prema pravilima DSGVO (europska uredba o '
      'zaštiti podataka, GDPR) ova obuka pokazuje što s tim podacima '
      'smiješ, a što ne. Učiš što treba učiniti kod povrede podataka '
      '(obveza prijave prema Art. 33 DSGVO) i koja pravila vrijede za '
      'povjerljivost. Na kraju slijede završni test i tvoj potpis.',
  'status_passed': 'Test položen',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' dana {date}',
  'status_open': 'Još nije završeno',
  'status_valid_until': 'Vrijedi do {date}',
  'btn_view_content': 'Pogledaj sadržaj',
  'btn_start': 'Pokreni obuku',
  'chapters_title': 'Poglavlja',
  'chapters_hint': 'Prođi sva poglavlja. Nakon toga otvara se završni '
      'test s {n} pitanja — položeno od {t} %.',
  'btn_exam_start': 'Pokreni završni test',
  'btn_exam_locked': 'Najprije pročitaj sva poglavlja',
  'chapter_badge': 'P{n}',
  'chapter_read': 'Pročitano · {n} stranica',
  'chapter_pages': '{n} stranica',
  'btn_back': 'Natrag',
  'btn_overview': 'Pregled',
  'btn_chapter_done': 'Završi poglavlje',
  'btn_next_chapter': 'Sljedeće poglavlje',
  'btn_next': 'Dalje',
  'exam_title': 'Završni test',
  'exam_intro': '{n} pitanja · položeno od {t} %',
  'exam_attempt': ' · pokušaj {n}',
  'result_passed': 'Položeno — {p} % točno',
  'result_failed': 'Nije položeno — {p} %. Pogledaj objašnjenja i '
      'pokušaj ponovno.',
  'btn_retry': 'Pokušaj ponovno',
  'btn_check': 'Provjeri odgovore',
  'btn_check_progress': 'Provjeri odgovore ({a}/{b})',
  'err_save': 'Spremanje nije uspjelo: {error}',
  'signature_title': 'Potvrdi sudjelovanje',
  'signature_hint': 'Svojim potpisom potvrđuješ da si sudjelovao u '
      'obuci o zaštiti podataka i razumio sadržaj. Imao si priliku '
      'postaviti pitanja.',
  'confirm_checkbox': 'Razumio sam obuku o zaštiti podataka i '
      'potvrđujem svoje sudjelovanje.',
  'btn_clear': 'Obriši',
  'btn_sign_submit': 'Potpiši i završi',
  'done_title': 'Obuka je završena!',
  'done_body': 'Tvoj rezultat i tvoj potpis su spremljeni. Od sada: '
      'podatke primatelja koristi samo službeno, fotografiraj bez '
      'osoba i registarskih oznaka, nikada ne radi snimke zaslona '
      'popisa adresa — i svaku povredu podataka odmah prijavi.',
  'done_result': 'Rezultat: {p} %',
  'done_passed_at': 'Položeno dana {date}',
  'btn_done': 'Gotovo',
};

// ── Türkçe / Turkish ────────────────────────────────────────────────
const Map<String, String> privacyTextsTr = {
  'appbar_title': 'Veri koruma',
  'training_title': 'Veri koruma — günlük dağıtımda DSGVO (GDPR)',
  'intro_meta': '{c} bölüm · {s} sayfa · {q} soruluk bitirme testi',
  'intro_body': 'Her gün kişisel verilerle çalışıyorsun: alıcı adları, '
      'adresler, telefon numaraları ve teslimat kanıtı olarak '
      'fotoğraflar. Bu eğitim, DSGVO (Avrupa veri koruma tüzüğü, GDPR) '
      'kurallarına göre bu verilerle neyi yapabileceğini ve neyi '
      'yapamayacağını gösterir. Bir veri ihlalinde ne yapman '
      'gerektiğini (Art. 33 DSGVO uyarınca bildirim yükümlülüğü) ve '
      'hangi gizlilik kurallarının geçerli olduğunu öğrenirsin. Sonunda '
      'bitirme testi ve imzan gelir.',
  'status_passed': 'Test geçildi',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' ({date})',
  'status_open': 'Henüz tamamlanmadı',
  'status_valid_until': '{date} tarihine kadar geçerli',
  'btn_view_content': 'İçeriği görüntüle',
  'btn_start': 'Eğitimi başlat',
  'chapters_title': 'Bölümler',
  'chapters_hint': 'Tüm bölümleri çalış. Sonrasında {n} soruluk '
      'bitirme testi açılır — {t} % ve üzeri başarılı sayılır.',
  'btn_exam_start': 'Bitirme testini başlat',
  'btn_exam_locked': 'Önce tüm bölümleri oku',
  'chapter_badge': 'B{n}',
  'chapter_read': 'Okundu · {n} sayfa',
  'chapter_pages': '{n} sayfa',
  'btn_back': 'Geri',
  'btn_overview': 'Genel bakış',
  'btn_chapter_done': 'Bölümü tamamla',
  'btn_next_chapter': 'Sonraki bölüm',
  'btn_next': 'Devam',
  'exam_title': 'Bitirme testi',
  'exam_intro': '{n} soru · {t} % ile geçilir',
  'exam_attempt': ' · {n}. deneme',
  'result_passed': 'Geçtin — {p} % doğru',
  'result_failed': 'Geçemedin — {p} %. Açıklamalara bak ve tekrar '
      'dene.',
  'btn_retry': 'Tekrar dene',
  'btn_check': 'Cevapları kontrol et',
  'btn_check_progress': 'Cevapları kontrol et ({a}/{b})',
  'err_save': 'Kaydetme başarısız: {error}',
  'signature_title': 'Katılımı onayla',
  'signature_hint': 'İmzanla veri koruma eğitimine katıldığını ve '
      'içeriği anladığını onaylıyorsun. Soru sorma imkânın oldu.',
  'confirm_checkbox': 'Veri koruma eğitimini anladım ve katılımımı '
      'onaylıyorum.',
  'btn_clear': 'Temizle',
  'btn_sign_submit': 'İmzala ve bitir',
  'done_title': 'Eğitim tamamlandı!',
  'done_body': 'Sonucun ve imzan kaydedildi. Bundan sonra: alıcı '
      'verilerini yalnızca iş amaçlı kullan, fotoğrafları kişiler ve '
      'plakalar olmadan çek, adres listelerinin ekran görüntüsünü asla '
      'alma — ve her veri ihlalini hemen bildir.',
  'done_result': 'Sonuç: {p} %',
  'done_passed_at': 'Geçilme tarihi: {date}',
  'btn_done': 'Bitti',
};

// ── Русский / Russian ───────────────────────────────────────────────
const Map<String, String> privacyTextsRu = {
  'appbar_title': 'Защита данных',
  'training_title': 'Защита данных — DSGVO (GDPR) в повседневной '
      'доставке',
  'intro_meta': '{c} глав · {s} страниц · итоговый тест из {q} '
      'вопросов',
  'intro_body': 'Каждый день ты работаешь с персональными данными: '
      'именами получателей, адресами, номерами телефонов и '
      'фотографиями как подтверждением доставки. По правилам DSGVO '
      '(европейский регламент о защите данных, GDPR) это обучение '
      'показывает, что тебе можно делать с этими данными, а что '
      'нельзя. Ты узнаешь, что делать при утечке данных (обязанность '
      'уведомления по Art. 33 DSGVO) и какие правила действуют для '
      'неразглашения. В конце — итоговый тест и твоя подпись.',
  'status_passed': 'Тест сдан',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' от {date}',
  'status_open': 'Ещё не пройдено',
  'status_valid_until': 'Действителен до {date}',
  'btn_view_content': 'Посмотреть материалы',
  'btn_start': 'Начать обучение',
  'chapters_title': 'Главы',
  'chapters_hint': 'Пройди все главы. После этого откроется итоговый '
      'тест из {n} вопросов — сдано от {t} %.',
  'btn_exam_start': 'Начать итоговый тест',
  'btn_exam_locked': 'Сначала прочитай все главы',
  'chapter_badge': 'Г{n}',
  'chapter_read': 'Прочитано · {n} страниц',
  'chapter_pages': '{n} страниц',
  'btn_back': 'Назад',
  'btn_overview': 'Обзор',
  'btn_chapter_done': 'Завершить главу',
  'btn_next_chapter': 'Следующая глава',
  'btn_next': 'Далее',
  'exam_title': 'Итоговый тест',
  'exam_intro': '{n} вопросов · сдано от {t} %',
  'exam_attempt': ' · попытка {n}',
  'result_passed': 'Сдано — {p} % правильно',
  'result_failed': 'Не сдано — {p} %. Прочитай пояснения и попробуй '
      'ещё раз.',
  'btn_retry': 'Попробовать ещё раз',
  'btn_check': 'Проверить ответы',
  'btn_check_progress': 'Проверить ответы ({a}/{b})',
  'err_save': 'Не удалось сохранить: {error}',
  'signature_title': 'Подтвердить участие',
  'signature_hint': 'Своей подписью ты подтверждаешь, что прошёл '
      'обучение по защите данных и понял его содержание. У тебя была '
      'возможность задать вопросы.',
  'confirm_checkbox': 'Я понял обучение по защите данных и '
      'подтверждаю своё участие.',
  'btn_clear': 'Очистить',
  'btn_sign_submit': 'Подписать и завершить',
  'done_title': 'Обучение завершено!',
  'done_body': 'Твой результат и твоя подпись сохранены. С этого '
      'момента: данные получателей использовать только по работе, '
      'фотографировать без людей и номерных знаков, никогда не делать '
      'скриншоты списков адресов — и о каждой утечке данных сообщать '
      'немедленно.',
  'done_result': 'Результат: {p} %',
  'done_passed_at': 'Сдано {date}',
  'btn_done': 'Готово',
};

// ── Български / Bulgarian ───────────────────────────────────────────
const Map<String, String> privacyTextsBg = {
  'appbar_title': 'Защита на данните',
  'training_title': 'Защита на данните — DSGVO (GDPR) в ежедневната '
      'доставка',
  'intro_meta': '{c} глави · {s} страници · финален тест с {q} '
      'въпроса',
  'intro_body': 'Всеки ден работиш с лични данни: имена на получатели, '
      'адреси, телефонни номера и снимки като доказателство за '
      'доставка. Според правилата на DSGVO (европейският регламент за '
      'защита на данните, GDPR) това обучение ти показва какво можеш '
      'да правиш с тези данни и какво не. Научаваш какво да правиш при '
      'пробив в данните (задължение за уведомяване по Art. 33 DSGVO) и '
      'какви правила важат за поверителността. Накрая следват '
      'финалният тест и твоят подпис.',
  'status_passed': 'Тестът е издържан',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' на {date}',
  'status_open': 'Още не е завършено',
  'status_valid_until': 'Валиден до {date}',
  'btn_view_content': 'Виж съдържанието',
  'btn_start': 'Започни обучението',
  'chapters_title': 'Глави',
  'chapters_hint': 'Премини през всички глави. След това се отключва '
      'финалният тест с {n} въпроса — издържан от {t} %.',
  'btn_exam_start': 'Започни финалния тест',
  'btn_exam_locked': 'Първо прочети всички глави',
  'chapter_badge': 'Г{n}',
  'chapter_read': 'Прочетено · {n} страници',
  'chapter_pages': '{n} страници',
  'btn_back': 'Назад',
  'btn_overview': 'Преглед',
  'btn_chapter_done': 'Завърши главата',
  'btn_next_chapter': 'Следваща глава',
  'btn_next': 'Напред',
  'exam_title': 'Финален тест',
  'exam_intro': '{n} въпроса · издържан от {t} %',
  'exam_attempt': ' · опит {n}',
  'result_passed': 'Издържан — {p} % верни',
  'result_failed': 'Неиздържан — {p} %. Прегледай обясненията и опитай '
      'отново.',
  'btn_retry': 'Опитай отново',
  'btn_check': 'Провери отговорите',
  'btn_check_progress': 'Провери отговорите ({a}/{b})',
  'err_save': 'Записването е неуспешно: {error}',
  'signature_title': 'Потвърди участието',
  'signature_hint': 'С подписа си потвърждаваш, че си участвал в '
      'обучението по защита на данните и си разбрал съдържанието. '
      'Имал си възможност да зададеш въпроси.',
  'confirm_checkbox': 'Разбрах обучението по защита на данните и '
      'потвърждавам участието си.',
  'btn_clear': 'Изтрий',
  'btn_sign_submit': 'Подпиши и завърши',
  'done_title': 'Обучението е завършено!',
  'done_body': 'Резултатът и подписът ти са запазени. Отсега нататък: '
      'използвай данните на получателите само служебно, снимай без '
      'хора и регистрационни номера, никога не прави екранни снимки на '
      'списъци с адреси — и съобщавай веднага за всеки пробив в '
      'данните.',
  'done_result': 'Резултат: {p} %',
  'done_passed_at': 'Издържан на {date}',
  'btn_done': 'Готово',
};

// ── العربية / Arabic (westliche Ziffern 0–9) ────────────────────────
const Map<String, String> privacyTextsAr = {
  'appbar_title': 'حماية البيانات',
  'training_title': 'حماية البيانات — DSGVO (GDPR) في العمل اليومي '
      'للتوصيل',
  'intro_meta': '{c} فصول · {s} صفحات · اختبار نهائي من {q} سؤالاً',
  'intro_body': 'أنت تعمل كل يوم ببيانات شخصية: أسماء المستلمين '
      'والعناوين وأرقام الهواتف والصور كإثبات للتسليم. وفق قواعد DSGVO '
      '(اللائحة الأوروبية العامة لحماية البيانات، GDPR) يوضح لك هذا '
      'التدريب ما يُسمح لك فعله بهذه البيانات وما لا يُسمح. وتتعلم ما '
      'يجب فعله عند حدوث خرق للبيانات (واجب الإبلاغ وفق Art. 33 DSGVO) '
      'وما القواعد التي تسري على السرية. وفي النهاية يأتي الاختبار '
      'النهائي وتوقيعك.',
  'status_passed': 'تم اجتياز الاختبار',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' بتاريخ {date}',
  'status_open': 'لم يتم الإنهاء بعد',
  'status_valid_until': 'صالح حتى {date}',
  'btn_view_content': 'عرض المحتوى',
  'btn_start': 'ابدأ التدريب',
  'chapters_title': 'الفصول',
  'chapters_hint': 'اعمل على كل الفصول. بعد ذلك يُفتح الاختبار النهائي '
      'المكوّن من {n} أسئلة — النجاح من {t} %.',
  'btn_exam_start': 'ابدأ الاختبار النهائي',
  'btn_exam_locked': 'اقرأ كل الفصول أولاً',
  'chapter_badge': 'ف{n}',
  'chapter_read': 'تمت القراءة · {n} صفحات',
  'chapter_pages': '{n} صفحات',
  'btn_back': 'رجوع',
  'btn_overview': 'نظرة عامة',
  'btn_chapter_done': 'إنهاء الفصل',
  'btn_next_chapter': 'الفصل التالي',
  'btn_next': 'التالي',
  'exam_title': 'الاختبار النهائي',
  'exam_intro': '{n} أسئلة · النجاح من {t} %',
  'exam_attempt': ' · المحاولة {n}',
  'result_passed': 'ناجح — {p} % صحيحة',
  'result_failed': 'غير ناجح — {p} %. راجع التوضيحات وحاول مرة أخرى.',
  'btn_retry': 'حاول مرة أخرى',
  'btn_check': 'تحقق من الإجابات',
  'btn_check_progress': 'تحقق من الإجابات ({a}/{b})',
  'err_save': 'فشل الحفظ: {error}',
  'signature_title': 'تأكيد المشاركة',
  'signature_hint': 'بتوقيعك تؤكد أنك شاركت في تدريب حماية البيانات '
      'وفهمت محتواه. وقد أتيحت لك الفرصة لطرح الأسئلة.',
  'confirm_checkbox': 'لقد فهمت تدريب حماية البيانات وأؤكد مشاركتي.',
  'btn_clear': 'مسح',
  'btn_sign_submit': 'وقّع وأنهِ',
  'done_title': 'تم إنهاء التدريب!',
  'done_body': 'تم حفظ نتيجتك وتوقيعك. من الآن فصاعداً: استخدم بيانات '
      'المستلمين لأغراض العمل فقط، والتقط الصور بدون أشخاص ولا لوحات '
      'أرقام، ولا تأخذ لقطات شاشة لقوائم العناوين — وأبلغ فوراً عن أي '
      'خرق للبيانات.',
  'done_result': 'النتيجة: {p} %',
  'done_passed_at': 'تم الاجتياز بتاريخ {date}',
  'btn_done': 'تم',
};

// ── Español / Spanish ───────────────────────────────────────────────
const Map<String, String> privacyTextsEs = {
  'appbar_title': 'Protección de datos',
  'training_title': 'Protección de datos — DSGVO (RGPD) en el reparto '
      'diario',
  'intro_meta': '{c} capítulos · {s} páginas · examen final con {q} '
      'preguntas',
  'intro_body': 'Cada día trabajas con datos personales: nombres de '
      'destinatarios, direcciones, números de teléfono y fotos como '
      'prueba de entrega. Siguiendo las reglas del DSGVO (nombre alemán '
      'del Reglamento General de Protección de Datos de la UE, RGPD), '
      'esta formación te muestra qué puedes hacer con esos datos y qué '
      'no. Aprenderás qué hacer en caso de una brecha de datos '
      '(obligación de notificación según el Art. 33 DSGVO) y qué reglas '
      'de confidencialidad se aplican. Al final vienen el examen y tu '
      'firma.',
  'status_passed': 'Test aprobado',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' el {date}',
  'status_open': 'Aún sin completar',
  'status_valid_until': 'Válido hasta el {date}',
  'btn_view_content': 'Ver contenidos',
  'btn_start': 'Empezar la formación',
  'chapters_title': 'Capítulos',
  'chapters_hint': 'Estudia todos los capítulos. Después se desbloquea '
      'el examen final con {n} preguntas — se aprueba a partir del '
      '{t} %.',
  'btn_exam_start': 'Empezar el examen final',
  'btn_exam_locked': 'Lee primero todos los capítulos',
  'chapter_badge': 'C{n}',
  'chapter_read': 'Leído · {n} páginas',
  'chapter_pages': '{n} páginas',
  'btn_back': 'Atrás',
  'btn_overview': 'Resumen',
  'btn_chapter_done': 'Finalizar capítulo',
  'btn_next_chapter': 'Capítulo siguiente',
  'btn_next': 'Siguiente',
  'exam_title': 'Examen final',
  'exam_intro': '{n} preguntas · se aprueba a partir del {t} %',
  'exam_attempt': ' · intento {n}',
  'result_passed': 'Aprobado — {p} % correcto',
  'result_failed': 'No aprobado — {p} %. Lee las explicaciones e '
      'inténtalo de nuevo.',
  'btn_retry': 'Intentar de nuevo',
  'btn_check': 'Comprobar respuestas',
  'btn_check_progress': 'Comprobar respuestas ({a}/{b})',
  'err_save': 'Error al guardar: {error}',
  'signature_title': 'Confirmar la participación',
  'signature_hint': 'Con tu firma confirmas que has participado en la '
      'formación sobre protección de datos y que has entendido su '
      'contenido. Has tenido la oportunidad de hacer preguntas.',
  'confirm_checkbox': 'He entendido la formación sobre protección de '
      'datos y confirmo mi participación.',
  'btn_clear': 'Borrar',
  'btn_sign_submit': 'Firmar y finalizar',
  'done_title': '¡Formación completada!',
  'done_body': 'Tu resultado y tu firma se han guardado. A partir de '
      'ahora: usa los datos de los destinatarios solo con fines '
      'laborales, haz las fotos sin personas ni matrículas, nunca hagas '
      'capturas de listas de direcciones y notifica de inmediato '
      'cualquier brecha de datos.',
  'done_result': 'Resultado: {p} %',
  'done_passed_at': 'Aprobado el {date}',
  'btn_done': 'Listo',
};

const Map<String, Map<String, String>> privacyTextsByLang = {
  'de': privacyTextsDe,
  'en': privacyTextsEn,
  'sq': privacyTextsSq,
  'hu': privacyTextsHu,
  'ro': privacyTextsRo,
  'hr': privacyTextsHr,
  'tr': privacyTextsTr,
  'ru': privacyTextsRu,
  'bg': privacyTextsBg,
  'ar': privacyTextsAr,
  'es': privacyTextsEs,
};

/// Text-Lookup mit Fallback locale -> en -> de.
///
/// [vars] ersetzt Platzhalter der Form `{key}`.
String privacyText(
  String lang,
  String key, {
  Map<String, String>? vars,
}) {
  final map = privacyTextsByLang[lang];
  var out = map?[key] ?? privacyTextsEn[key] ?? privacyTextsDe[key] ?? key;
  if (vars != null) {
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
  }
  return out;
}
