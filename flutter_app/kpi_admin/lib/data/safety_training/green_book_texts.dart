// lib/data/safety_training/green_book_texts.dart
//
// Bedien-/UI-Texte der Green-Book-Schulung (Fahrtenkontrollbuch /
// Tageskontrollblaetter nach § 1 Abs. 6 FPersV), je Sprache eine Map
// mit identischem Key-Satz (Vertrag). Platzhalter in geschweiften
// Klammern, z. B. {n}, {p}, {date}. Auflösung mit Fallback-Kette
// locale -> en -> de, analog zu driving_safety_texts.dart.
//
// Bewusst NICHT uebersetzt (bleiben in allen Sprachen gleich):
// die Eigennamen 'Green Book', 'DA Academy' und 'CoDriver' sowie die
// deutschen Rechtsbegriffe (FPersV, Fahrpersonalverordnung,
// § 1 Abs. 6, BAG, Tageskontrollblatt) — dort ist eine kurze
// Erlaeuterung in Klammern in der Zielsprache ergaenzt.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> greenBookTextsDe = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — Tageskontrollblatt',
  'intro_meta': '{c} Kapitel · {s} Seiten · Abschlusstest mit {q} '
      'Fragen',
  'intro_body': 'Das Green Book ist dein Fahrtenkontrollbuch: die '
      'Tageskontrollblätter nach § 1 Abs. 6 FPersV, mit denen du '
      'Lenkzeiten, Fahrtunterbrechungen und Ruhezeiten nachweist. In '
      'dieser Schulung lernst du, warum es Pflicht ist, wie du es '
      'korrekt ausfüllst, welche Zeiten gelten und was passiert, wenn '
      'du es nicht führst.',
  'status_passed': 'Test bestanden',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' am {date}',
  'status_open': 'Noch nicht abgeschlossen',
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
  'done_title': 'Test bestanden!',
  'done_body': 'Dein Ergebnis wurde gespeichert. Ab jetzt gilt: das '
      'Tageskontrollblatt jeden Tag vollständig führen — Lenkzeiten, '
      'Fahrtunterbrechungen und Ruhezeiten sofort eintragen, '
      'Unterschrift nicht vergessen und die Blätter fristgerecht '
      'abgeben.',
  'done_result': 'Ergebnis: {p} %',
  'done_passed_at': 'Bestanden am {date}',
  'btn_done': 'Fertig',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> greenBookTextsEn = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — daily control sheet',
  'intro_meta': '{c} chapters · {s} pages · final test with {q} '
      'questions',
  'intro_body': 'The Green Book is your driving record book: the daily '
      'control sheets (Tageskontrollblätter) required by § 1 Abs. 6 '
      'FPersV (the German driving personnel regulation). With them you '
      'prove your driving times, driving breaks and rest periods. In '
      'this training you learn why it is mandatory, how to fill it in '
      'correctly, which times apply and what happens if you do not '
      'keep it.',
  'status_passed': 'Test passed',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' on {date}',
  'status_open': 'Not completed yet',
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
  'done_title': 'Test passed!',
  'done_body': 'Your result has been saved. From now on: fill in the '
      'Tageskontrollblatt completely every day — enter driving times, '
      'driving breaks and rest periods right away, do not forget your '
      'signature and hand the sheets in on time.',
  'done_result': 'Result: {p} %',
  'done_passed_at': 'Passed on {date}',
  'btn_done': 'Done',
};

// ── Shqip / Albanian ────────────────────────────────────────────────
const Map<String, String> greenBookTextsSq = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — fleta ditore e kontrollit',
  'intro_meta': '{c} kapituj · {s} faqe · test përfundimtar me {q} '
      'pyetje',
  'intro_body': 'Green Book është libri yt i kontrollit të udhëtimeve: '
      'fletët ditore të kontrollit (Tageskontrollblätter) sipas § 1 '
      'Abs. 6 FPersV (rregullorja gjermane për personelin drejtues). '
      'Me to dëshmon kohët e drejtimit, ndërprerjet e udhëtimit dhe '
      'kohët e pushimit. Në këtë trajnim mëson pse është i '
      'detyrueshëm, si e plotëson saktë, cilat kohë vlejnë dhe çfarë '
      'ndodh nëse nuk e mban.',
  'status_passed': 'Testi u kalua',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' më {date}',
  'status_open': 'Ende e papërfunduar',
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
  'done_title': 'Testi u kalua!',
  'done_body': 'Rezultati yt u ruajt. Që tani: plotëso çdo ditë të '
      'plotë fletën ditore të kontrollit (Tageskontrollblatt) — shëno '
      'menjëherë kohët e drejtimit, ndërprerjet dhe pushimet, mos '
      'harro nënshkrimin dhe dorëzoji fletët në afat.',
  'done_result': 'Rezultati: {p} %',
  'done_passed_at': 'Kaluar më {date}',
  'btn_done': 'Gati',
};

// ── Magyar / Hungarian ──────────────────────────────────────────────
const Map<String, String> greenBookTextsHu = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — napi ellenőrző lap',
  'intro_meta': '{c} fejezet · {s} oldal · záróteszt {q} kérdéssel',
  'intro_body': 'A Green Book a menetellenőrző könyved: a napi '
      'ellenőrző lapok (Tageskontrollblätter) a § 1 Abs. 6 FPersV '
      '(német vezetői személyzeti rendelet) szerint. Ezekkel igazolod '
      'a vezetési időt, a vezetési szüneteket és a pihenőidőket. '
      'Ebben a képzésben megtanulod, miért kötelező, hogyan töltsd ki '
      'helyesen, milyen időhatárok érvényesek, és mi történik, ha nem '
      'vezeted.',
  'status_passed': 'Teszt teljesítve',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' ekkor: {date}',
  'status_open': 'Még nincs teljesítve',
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
  'done_title': 'Teszt teljesítve!',
  'done_body': 'Az eredményed mentve. Mostantól: a napi ellenőrző '
      'lapot (Tageskontrollblatt) minden nap hiánytalanul vezesd — a '
      'vezetési időt, a szüneteket és a pihenőidőket azonnal írd be, '
      'ne felejtsd el az aláírást, és a lapokat határidőre add le.',
  'done_result': 'Eredmény: {p} %',
  'done_passed_at': 'Teljesítve ekkor: {date}',
  'btn_done': 'Kész',
};

// ── Română / Romanian ───────────────────────────────────────────────
const Map<String, String> greenBookTextsRo = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — fișa zilnică de control',
  'intro_meta': '{c} capitole · {s} pagini · test final cu {q} '
      'întrebări',
  'intro_body': 'Green Book este registrul tău de control al curselor: '
      'fișele zilnice de control (Tageskontrollblätter) conform § 1 '
      'Abs. 6 FPersV (regulamentul german privind personalul de '
      'conducere). Cu ele dovedești timpii de conducere, pauzele de '
      'conducere și perioadele de odihnă. În acest curs afli de ce '
      'este obligatoriu, cum îl completezi corect, ce timpi se aplică '
      'și ce se întâmplă dacă nu îl ții.',
  'status_passed': 'Test promovat',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' pe {date}',
  'status_open': 'Încă nefinalizat',
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
  'done_title': 'Test promovat!',
  'done_body': 'Rezultatul tău a fost salvat. De acum: completează '
      'zilnic și integral fișa de control (Tageskontrollblatt) — '
      'notează imediat timpii de conducere, pauzele și perioadele de '
      'odihnă, nu uita semnătura și predă fișele la termen.',
  'done_result': 'Rezultat: {p} %',
  'done_passed_at': 'Promovat pe {date}',
  'btn_done': 'Gata',
};

// ── Hrvatski / Croatian ─────────────────────────────────────────────
const Map<String, String> greenBookTextsHr = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — dnevni kontrolni list',
  'intro_meta': '{c} poglavlja · {s} stranica · završni test s {q} '
      'pitanja',
  'intro_body': 'Green Book je tvoja knjiga kontrole vožnje: dnevni '
      'kontrolni listovi (Tageskontrollblätter) prema § 1 Abs. 6 '
      'FPersV (njemačka uredba o vozačkom osoblju). Njima dokazuješ '
      'vrijeme vožnje, prekide vožnje i odmore. U ovoj obuci učiš '
      'zašto je obvezan, kako ga ispravno ispuniti, koja vremena '
      'vrijede i što se događa ako ga ne vodiš.',
  'status_passed': 'Test položen',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' dana {date}',
  'status_open': 'Još nije završeno',
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
  'done_title': 'Test položen!',
  'done_body': 'Tvoj rezultat je spremljen. Od sada: dnevni kontrolni '
      'list (Tageskontrollblatt) vodi svaki dan u potpunosti — '
      'vrijeme vožnje, prekide i odmore upiši odmah, ne zaboravi '
      'potpis i listove predaj na vrijeme.',
  'done_result': 'Rezultat: {p} %',
  'done_passed_at': 'Položeno dana {date}',
  'btn_done': 'Gotovo',
};

// ── Türkçe / Turkish ────────────────────────────────────────────────
const Map<String, String> greenBookTextsTr = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — günlük kontrol formu',
  'intro_meta': '{c} bölüm · {s} sayfa · {q} soruluk bitirme testi',
  'intro_body': 'Green Book senin sefer kontrol defterin: § 1 Abs. 6 '
      'FPersV (Alman sürücü personeli yönetmeliği) uyarınca tutulan '
      'günlük kontrol formları (Tageskontrollblätter). Bunlarla sürüş '
      'sürelerini, sürüş molalarını ve dinlenme sürelerini '
      'belgelersin. Bu eğitimde neden zorunlu olduğunu, doğru nasıl '
      'doldurulduğunu, hangi sürelerin geçerli olduğunu ve tutmazsan '
      'ne olacağını öğrenirsin.',
  'status_passed': 'Test geçildi',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' ({date})',
  'status_open': 'Henüz tamamlanmadı',
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
  'done_title': 'Testi geçtin!',
  'done_body': 'Sonucun kaydedildi. Bundan sonra: günlük kontrol '
      'formunu (Tageskontrollblatt) her gün eksiksiz tut — sürüş '
      'sürelerini, molaları ve dinlenme sürelerini hemen yaz, imzayı '
      'unutma ve formları zamanında teslim et.',
  'done_result': 'Sonuç: {p} %',
  'done_passed_at': 'Geçilme tarihi: {date}',
  'btn_done': 'Bitti',
};

// ── Русский / Russian ───────────────────────────────────────────────
const Map<String, String> greenBookTextsRu = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — дневной контрольный лист',
  'intro_meta': '{c} глав · {s} страниц · итоговый тест из {q} '
      'вопросов',
  'intro_body': 'Green Book — это твоя книга контроля поездок: '
      'дневные контрольные листы (Tageskontrollblätter) согласно § 1 '
      'Abs. 6 FPersV (немецкое постановление о водительском '
      'персонале). Ими ты подтверждаешь время управления, перерывы в '
      'вождении и время отдыха. В этом обучении ты узнаешь, почему '
      'это обязательно, как правильно заполнять листы, какие сроки '
      'действуют и что будет, если ты их не ведёшь.',
  'status_passed': 'Тест сдан',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' от {date}',
  'status_open': 'Ещё не пройдено',
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
  'done_title': 'Тест сдан!',
  'done_body': 'Твой результат сохранён. С этого момента: заполняй '
      'дневной контрольный лист (Tageskontrollblatt) полностью каждый '
      'день — сразу вноси время управления, перерывы и время отдыха, '
      'не забывай подпись и сдавай листы в срок.',
  'done_result': 'Результат: {p} %',
  'done_passed_at': 'Сдано {date}',
  'btn_done': 'Готово',
};

// ── Български / Bulgarian ───────────────────────────────────────────
const Map<String, String> greenBookTextsBg = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — дневен контролен лист',
  'intro_meta': '{c} глави · {s} страници · финален тест с {q} '
      'въпроса',
  'intro_body': 'Green Book е твоята книга за контрол на пътуванията: '
      'дневните контролни листове (Tageskontrollblätter) съгласно § 1 '
      'Abs. 6 FPersV (германската наредба за водачния персонал). С тях '
      'доказваш времето на управление, прекъсванията на пътуването и '
      'почивките. В това обучение научаваш защо е задължителен, как се '
      'попълва правилно, какви времена важат и какво става, ако не го '
      'водиш.',
  'status_passed': 'Тестът е издържан',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' на {date}',
  'status_open': 'Още не е завършено',
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
  'done_title': 'Тестът е издържан!',
  'done_body': 'Резултатът ти е запазен. Отсега нататък: води дневния '
      'контролен лист (Tageskontrollblatt) изцяло всеки ден — вписвай '
      'веднага времето на управление, прекъсванията и почивките, не '
      'забравяй подписа и предавай листовете навреме.',
  'done_result': 'Резултат: {p} %',
  'done_passed_at': 'Издържан на {date}',
  'btn_done': 'Готово',
};

// ── العربية / Arabic (westliche Ziffern 0–9) ────────────────────────
const Map<String, String> greenBookTextsAr = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — ورقة المراقبة اليومية',
  'intro_meta': '{c} فصول · {s} صفحات · اختبار نهائي من {q} سؤالاً',
  'intro_body': 'Green Book هو دفتر مراقبة رحلاتك: أوراق المراقبة '
      'اليومية (Tageskontrollblätter) وفق § 1 Abs. 6 FPersV (اللائحة '
      'الألمانية لطاقم القيادة). بها تُثبت أوقات القيادة وفترات '
      'الاستراحة أثناء القيادة وأوقات الراحة. في هذا التدريب تتعلم '
      'لماذا هو إلزامي، وكيف تملؤه بشكل صحيح، وما الأوقات التي تنطبق، '
      'وماذا يحدث إذا لم تمسكه.',
  'status_passed': 'تم اجتياز الاختبار',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' بتاريخ {date}',
  'status_open': 'لم يتم الإنهاء بعد',
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
  'done_title': 'تم اجتياز الاختبار!',
  'done_body': 'تم حفظ نتيجتك. من الآن فصاعداً: املأ ورقة المراقبة '
      'اليومية (Tageskontrollblatt) كاملة كل يوم — سجّل أوقات القيادة '
      'وفترات الاستراحة وأوقات الراحة فوراً، ولا تنسَ التوقيع، وسلّم '
      'الأوراق في الموعد.',
  'done_result': 'النتيجة: {p} %',
  'done_passed_at': 'تم الاجتياز بتاريخ {date}',
  'btn_done': 'تم',
};

// ── Español / Spanish ───────────────────────────────────────────────
const Map<String, String> greenBookTextsEs = {
  'appbar_title': 'Green Book',
  'training_title': 'Green Book — hoja de control diaria',
  'intro_meta': '{c} capítulos · {s} páginas · examen final con {q} '
      'preguntas',
  'intro_body': 'El Green Book es tu libro de control de conducción: las '
      'hojas de control diarias (Tageskontrollblätter) exigidas por el '
      '§ 1 Abs. 6 FPersV (el reglamento alemán sobre personal de '
      'conducción). Con ellas acreditas los tiempos de conducción, las '
      'pausas y los periodos de descanso. En esta formación aprenderás '
      'por qué es obligatorio, cómo se rellena correctamente, qué '
      'tiempos se aplican y qué pasa si no lo llevas.',
  'status_passed': 'Test aprobado',
  'status_passed_score': ' · {p} %',
  'status_passed_date': ' el {date}',
  'status_open': 'Aún sin completar',
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
  'done_title': '¡Test aprobado!',
  'done_body': 'Tu resultado se ha guardado. A partir de ahora: rellena '
      'cada día por completo la hoja de control '
      '(Tageskontrollblatt) — anota de inmediato los tiempos de '
      'conducción, las pausas y los descansos, no olvides la firma y '
      'entrega las hojas dentro del plazo.',
  'done_result': 'Resultado: {p} %',
  'done_passed_at': 'Aprobado el {date}',
  'btn_done': 'Listo',
};

const Map<String, Map<String, String>> greenBookTextsByLang = {
  'de': greenBookTextsDe,
  'en': greenBookTextsEn,
  'sq': greenBookTextsSq,
  'hu': greenBookTextsHu,
  'ro': greenBookTextsRo,
  'hr': greenBookTextsHr,
  'tr': greenBookTextsTr,
  'ru': greenBookTextsRu,
  'bg': greenBookTextsBg,
  'ar': greenBookTextsAr,
  'es': greenBookTextsEs,
};

/// Text-Lookup mit Fallback locale -> en -> de.
///
/// [vars] ersetzt Platzhalter der Form `{key}`.
String greenBookText(
  String lang,
  String key, {
  Map<String, String>? vars,
}) {
  final map = greenBookTextsByLang[lang];
  var out =
      map?[key] ?? greenBookTextsEn[key] ?? greenBookTextsDe[key] ?? key;
  if (vars != null) {
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
  }
  return out;
}
