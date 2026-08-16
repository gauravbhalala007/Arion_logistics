// lib/data/safety_training/ride_along_texts.dart
//
// Bedien-/UI-Texte der Ride-Along-Schulung (zweitaegige Begleitfahrt
// eines neuen Fahrers mit einem erfahrenen Fahrer als Trainer), je
// Sprache eine Map mit identischem Key-Satz (Vertrag). Platzhalter in
// geschweiften Klammern, z. B. {n}, {p}, {date}. Auflösung mit
// Fallback-Kette locale -> en -> de, analog zu green_book_texts.dart.
//
// Bewusst NICHT uebersetzt (bleiben in allen Sprachen gleich):
// die Eigennamen 'Ride Along', 'DA Academy', 'Green Book' und
// 'CoDriver'.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> rideAlongTextsDe = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — deine zwei Begleittage',
  'intro_meta': '{c} Kapitel · {s} Seiten · Abschlusstest mit {q} '
      'Fragen',
  'intro_body': 'Der Ride Along sind deine zwei ersten Arbeitstage '
      'neben einem erfahrenen Fahrer, der dich als Trainer begleitet: '
      'Tag 1 mit weniger Stopps, Tag 2 mit deutlich mehr. Der Trainer '
      'arbeitet eine Checkliste ab und gibt am Ende ein Feedback. '
      'Diese Schulung bereitet dich darauf vor — du kennst die Themen '
      'der beiden Tage vorher, kannst gezielt nachfragen und die '
      'Begleitfahrt bewusst nutzen.',
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
  'done_body': 'Dein Ergebnis wurde gespeichert. Jetzt gilt: an beiden '
      'Tagen aufmerksam mitgehen, alles fragen, was unklar ist, jeden '
      'Punkt der Checkliste mit dem Trainer durchgehen und das '
      'Feedback am Ende ernst nehmen.',
  'done_result': 'Ergebnis: {p} %',
  'done_passed_at': 'Bestanden am {date}',
  'btn_done': 'Fertig',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> rideAlongTextsEn = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — your two shadow days',
  'intro_meta': '{c} chapters · {s} pages · final test with {q} '
      'questions',
  'intro_body': 'The Ride Along is your first two working days next to '
      'an experienced driver who accompanies you as your trainer: day 1 '
      'with fewer stops, day 2 with clearly more. The trainer works '
      'through a checklist and gives you feedback at the end. This '
      'training prepares you for it — you know the topics of both days '
      'in advance, can ask targeted questions and make the most of the '
      'shadow days.',
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
  'done_body': 'Your result has been saved. Now it counts: pay '
      'attention on both days, ask about anything that is unclear, go '
      'through every point of the checklist with your trainer and take '
      'the feedback at the end seriously.',
  'done_result': 'Result: {p} %',
  'done_passed_at': 'Passed on {date}',
  'btn_done': 'Done',
};

// ── Shqip / Albanian ────────────────────────────────────────────────
const Map<String, String> rideAlongTextsSq = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — dy ditët e tua shoqëruese',
  'intro_meta': '{c} kapituj · {s} faqe · test përfundimtar me {q} '
      'pyetje',
  'intro_body': 'Ride Along janë dy ditët e tua të para të punës pranë '
      'një shoferi me përvojë që të shoqëron si trajner: dita 1 me më '
      'pak ndalesa, dita 2 me dukshëm më shumë. Trajneri punon me një '
      'listë kontrolli dhe në fund të jep një vlerësim. Ky trajnim të '
      'përgatit për këtë — i njeh temat e të dyja ditëve që më parë, '
      'mund të pyesësh me qëllim dhe t’i shfrytëzosh ditët shoqëruese '
      'me vetëdije.',
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
  'done_body': 'Rezultati yt u ruajt. Tani vlen: qëndro i vëmendshëm '
      'në të dyja ditët, pyet për gjithçka që nuk e ke të qartë, kalo '
      'me trajnerin çdo pikë të listës së kontrollit dhe merre '
      'seriozisht vlerësimin në fund.',
  'done_result': 'Rezultati: {p} %',
  'done_passed_at': 'Kaluar më {date}',
  'btn_done': 'Gati',
};

// ── Magyar / Hungarian ──────────────────────────────────────────────
const Map<String, String> rideAlongTextsHu = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — a két kísérőnapod',
  'intro_meta': '{c} fejezet · {s} oldal · záróteszt {q} kérdéssel',
  'intro_body': 'A Ride Along az első két munkanapod egy tapasztalt '
      'sofőr mellett, aki oktatóként kísér téged: az 1. napon kevesebb '
      'megállóval, a 2. napon lényegesen többel. Az oktató végigmegy '
      'egy ellenőrzőlistán, és a végén visszajelzést ad. Ez a képzés '
      'felkészít erre — előre ismered mindkét nap témáit, célzottan '
      'tudsz kérdezni, és tudatosan használod ki a kísérőnapokat.',
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
  'done_body': 'Az eredményed mentve. Mostantól ez számít: legyél '
      'figyelmes mindkét napon, kérdezz rá mindenre, ami nem világos, '
      'menj végig az oktatóval az ellenőrzőlista minden pontján, és '
      'vedd komolyan a végi visszajelzést.',
  'done_result': 'Eredmény: {p} %',
  'done_passed_at': 'Teljesítve ekkor: {date}',
  'btn_done': 'Kész',
};

// ── Română / Romanian ───────────────────────────────────────────────
const Map<String, String> rideAlongTextsRo = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — cele două zile de însoțire',
  'intro_meta': '{c} capitole · {s} pagini · test final cu {q} '
      'întrebări',
  'intro_body': 'Ride Along înseamnă primele tale două zile de lucru '
      'alături de un șofer cu experiență, care te însoțește ca '
      'formator: ziua 1 cu mai puține opriri, ziua 2 cu semnificativ '
      'mai multe. Formatorul parcurge o listă de verificare și îți dă '
      'un feedback la final. Acest curs te pregătește — cunoști '
      'dinainte temele celor două zile, poți întreba țintit și '
      'folosești conștient zilele de însoțire.',
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
  'done_body': 'Rezultatul tău a fost salvat. De acum contează: fii '
      'atent în ambele zile, întreabă orice nu îți este clar, parcurge '
      'cu formatorul fiecare punct din lista de verificare și ia în '
      'serios feedbackul de la final.',
  'done_result': 'Rezultat: {p} %',
  'done_passed_at': 'Promovat pe {date}',
  'btn_done': 'Gata',
};

// ── Hrvatski / Croatian ─────────────────────────────────────────────
const Map<String, String> rideAlongTextsHr = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — tvoja dva dana pratnje',
  'intro_meta': '{c} poglavlja · {s} stranica · završni test s {q} '
      'pitanja',
  'intro_body': 'Ride Along su tvoja prva dva radna dana uz iskusnog '
      'vozača koji te prati kao trener: 1. dan s manje stajališta, 2. '
      'dan sa znatno više. Trener prolazi kontrolnu listu i na kraju ti '
      'daje povratnu informaciju. Ova obuka te priprema za to — teme '
      'oba dana znaš unaprijed, možeš ciljano pitati i svjesno '
      'iskoristiti dane pratnje.',
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
  'done_body': 'Tvoj rezultat je spremljen. Od sada vrijedi: budi '
      'pažljiv oba dana, pitaj sve što ti nije jasno, prođi s trenerom '
      'svaku točku kontrolne liste i ozbiljno shvati povratnu '
      'informaciju na kraju.',
  'done_result': 'Rezultat: {p} %',
  'done_passed_at': 'Položeno dana {date}',
  'btn_done': 'Gotovo',
};

// ── Türkçe / Turkish ────────────────────────────────────────────────
const Map<String, String> rideAlongTextsTr = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — iki refakat günün',
  'intro_meta': '{c} bölüm · {s} sayfa · {q} soruluk bitirme testi',
  'intro_body': 'Ride Along, sana eğitmen olarak eşlik eden deneyimli '
      'bir sürücünün yanındaki ilk iki iş günündür: 1. gün daha az '
      'durakla, 2. gün belirgin şekilde daha fazlasıyla. Eğitmen bir '
      'kontrol listesini işler ve sonunda sana geri bildirim verir. Bu '
      'eğitim seni buna hazırlar — iki günün konularını önceden '
      'bilirsin, hedefli soru sorabilirsin ve refakat günlerini '
      'bilinçli değerlendirirsin.',
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
  'done_body': 'Sonucun kaydedildi. Bundan sonrası: iki gün boyunca '
      'dikkatli ol, anlamadığın her şeyi sor, kontrol listesinin her '
      'maddesini eğitmenle birlikte gözden geçir ve sonundaki geri '
      'bildirimi ciddiye al.',
  'done_result': 'Sonuç: {p} %',
  'done_passed_at': 'Geçilme tarihi: {date}',
  'btn_done': 'Bitti',
};

// ── Русский / Russian ───────────────────────────────────────────────
const Map<String, String> rideAlongTextsRu = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — твои два дня сопровождения',
  'intro_meta': '{c} глав · {s} страниц · итоговый тест из {q} '
      'вопросов',
  'intro_body': 'Ride Along — это твои первые два рабочих дня рядом с '
      'опытным водителем, который сопровождает тебя как наставник: в '
      '1-й день меньше остановок, во 2-й заметно больше. Наставник '
      'проходит контрольный лист и в конце даёт обратную связь. Это '
      'обучение готовит тебя к ним — ты заранее знаешь темы обоих '
      'дней, можешь задавать точные вопросы и осознанно использовать '
      'дни сопровождения.',
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
  'done_body': 'Твой результат сохранён. Теперь главное: будь '
      'внимателен оба дня, спрашивай обо всём, что непонятно, пройди с '
      'наставником каждый пункт контрольного листа и серьёзно отнесись '
      'к обратной связи в конце.',
  'done_result': 'Результат: {p} %',
  'done_passed_at': 'Сдано {date}',
  'btn_done': 'Готово',
};

// ── Български / Bulgarian ───────────────────────────────────────────
const Map<String, String> rideAlongTextsBg = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — двата ти дни на съпровождане',
  'intro_meta': '{c} глави · {s} страници · финален тест с {q} '
      'въпроса',
  'intro_body': 'Ride Along са първите ти два работни дни до опитен '
      'шофьор, който те съпровожда като обучител: ден 1 с по-малко '
      'спирки, ден 2 с чувствително повече. Обучителят преминава по '
      'контролен лист и накрая ти дава обратна връзка. Това обучение '
      'те подготвя за тях — знаеш темите на двата дни предварително, '
      'можеш да питаш целенасочено и да използваш съзнателно дните на '
      'съпровождане.',
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
  'done_body': 'Резултатът ти е запазен. Отсега важи: бъди внимателен '
      'и в двата дни, питай за всичко, което не ти е ясно, премини с '
      'обучителя през всяка точка от контролния лист и приеми сериозно '
      'обратната връзка накрая.',
  'done_result': 'Резултат: {p} %',
  'done_passed_at': 'Издържан на {date}',
  'btn_done': 'Готово',
};

// ── العربية / Arabic (westliche Ziffern 0–9) ────────────────────────
const Map<String, String> rideAlongTextsAr = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — يوما المرافقة',
  'intro_meta': '{c} فصول · {s} صفحات · اختبار نهائي من {q} سؤالاً',
  'intro_body': 'Ride Along هما أول يومي عمل لك بجانب سائق ذي خبرة '
      'يرافقك كمدرّب: اليوم الأول بعدد أقل من التوقفات، واليوم الثاني '
      'بعدد أكبر بكثير. يعمل المدرّب وفق قائمة تحقّق ويعطيك في النهاية '
      'تقييماً. هذا التدريب يهيّئك لذلك — تعرف موضوعات اليومين مسبقاً، '
      'ويمكنك أن تسأل بشكل محدّد وأن تستفيد من يومي المرافقة بوعي.',
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
  'done_body': 'تم حفظ نتيجتك. الآن المهم: كن منتبهاً في اليومين، '
      'واسأل عن كل ما هو غير واضح، وراجع مع المدرّب كل بند من بنود '
      'قائمة التحقّق، وخذ التقييم في النهاية على محمل الجد.',
  'done_result': 'النتيجة: {p} %',
  'done_passed_at': 'تم الاجتياز بتاريخ {date}',
  'btn_done': 'تم',
};

// ── Español / Spanish ───────────────────────────────────────────────
const Map<String, String> rideAlongTextsEs = {
  'appbar_title': 'Ride Along',
  'training_title': 'Ride Along — tus dos días de acompañamiento',
  'intro_meta': '{c} capítulos · {s} páginas · examen final con {q} '
      'preguntas',
  'intro_body': 'El Ride Along son tus dos primeros días de trabajo '
      'junto a un conductor con experiencia que te acompaña como '
      'formador: el día 1 con menos paradas y el día 2 con bastantes '
      'más. El formador va repasando una lista de verificación y al '
      'final te da su feedback. Esta formación te prepara para ello: '
      'conoces de antemano los temas de los dos días, puedes preguntar '
      'de forma concreta y aprovechar al máximo el acompañamiento.',
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
  'done_body': 'Tu resultado se ha guardado. Ahora lo que cuenta es '
      'esto: presta atención los dos días, pregunta todo lo que no '
      'tengas claro, repasa con el formador cada punto de la lista de '
      'verificación y toma en serio el feedback final.',
  'done_result': 'Resultado: {p} %',
  'done_passed_at': 'Aprobado el {date}',
  'btn_done': 'Listo',
};

const Map<String, Map<String, String>> rideAlongTextsByLang = {
  'de': rideAlongTextsDe,
  'en': rideAlongTextsEn,
  'sq': rideAlongTextsSq,
  'hu': rideAlongTextsHu,
  'ro': rideAlongTextsRo,
  'hr': rideAlongTextsHr,
  'tr': rideAlongTextsTr,
  'ru': rideAlongTextsRu,
  'bg': rideAlongTextsBg,
  'ar': rideAlongTextsAr,
  'es': rideAlongTextsEs,
};

/// Text-Lookup mit Fallback locale -> en -> de.
///
/// [vars] ersetzt Platzhalter der Form `{key}`.
String rideAlongText(
  String lang,
  String key, {
  Map<String, String>? vars,
}) {
  final map = rideAlongTextsByLang[lang.trim().toLowerCase()];
  var out =
      map?[key] ?? rideAlongTextsEn[key] ?? rideAlongTextsDe[key] ?? key;
  if (vars != null) {
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
  }
  return out;
}
