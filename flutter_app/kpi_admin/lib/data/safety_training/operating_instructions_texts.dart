// lib/data/safety_training/operating_instructions_texts.dart
//
// Anzeigetexte der Betriebsanweisungs-Seite
// (driver_operating_instructions_page.dart), je Sprache eine Map mit
// identischem Key-Satz (Vertrag). Platzhalter in geschweiften Klammern,
// z. B. {n}. Auflösung mit Fallback-Kette locale -> en -> de, analog zu
// academy_texts.dart und driving_safety_texts.dart.
//
// Bewusst NICHT übersetzt (bleiben in allen Sprachen gleich): deutsche
// Rechtsbegriffe und Gesetzesnamen (§, ArbSchG, DGUV Vorschrift 1,
// GefStoffV, StVO) sowie 'DA Academy' und 'CoDriver'.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> opsTextsDe = {
  'page_title': 'Betriebsanweisungen',
  'page_intro': 'Verbindliche Anweisungen deines Arbeitgebers für den '
      'Umgang mit Fahrzeugen, Ausrüstung und Gefahrstoffen. Du musst sie '
      'kennen und befolgen.',
  'detail_title': 'Betriebsanweisung',
  'link_badge': 'Betriebsanweisung',
  'section_scope': 'Geltungsbereich',
  'section_hazards': 'Gefahren für Mensch und Umwelt',
  'section_protection': 'Schutzmaßnahmen & Verhaltensregeln',
  'section_failure': 'Verhalten bei Störungen',
  'section_accident': 'Verhalten bei Unfällen & Erste Hilfe',
  'section_maintenance': 'Instandhaltung & Entsorgung',
  'legal_note': 'Diese Betriebsanweisung ist verbindlich (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). Bei Fragen wende dich an deinen Dispatcher '
      '— bevor du die Tätigkeit ausführst.',
  'empty_list': 'Für deine Sprache sind noch keine Betriebsanweisungen '
      'hinterlegt. Melde dich bei deinem Admin.',
  'cat_vehicle': 'Fahrzeug & Fahrbetrieb',
  'cat_ppe': 'Schutzausrüstung',
  'cat_handling': 'Sendungen & Ladung',
  'cat_hazardous': 'Gefahrstoffe',
  'cat_hygiene': 'Hygiene & Hautschutz',
  'cat_workplace': 'Arbeitsplatz',
  'ack_button': 'Als gelesen markieren',
  'ack_hint': 'Bestätige, dass du diese Betriebsanweisung gelesen und '
      'verstanden hast.',
  'ack_confirmed': 'Bestätigt',
  'ack_confirmed_on': 'Gelesen und bestätigt am {date}',
  'ack_pending': 'Noch nicht bestätigt',
  'ack_progress': '{done} von {total} bestätigt',
  'ack_open_count': 'noch {n} offen',
  'ack_all_done': 'Alle Betriebsanweisungen bestätigt.',
  'ack_saving': 'Wird gespeichert …',
  'ack_success': 'Betriebsanweisung als gelesen bestätigt.',
  'ack_error': 'Bestätigung konnte nicht gespeichert werden. Prüfe deine '
      'Internetverbindung und versuche es erneut.',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> opsTextsEn = {
  'page_title': 'Operating instructions',
  'page_intro': 'Binding instructions from your employer for handling '
      'vehicles, equipment and hazardous substances. You must know and '
      'follow them.',
  'detail_title': 'Operating instruction',
  'link_badge': 'Operating instruction',
  'section_scope': 'Scope',
  'section_hazards': 'Hazards to people and the environment',
  'section_protection': 'Protective measures & rules of conduct',
  'section_failure': 'What to do if something fails',
  'section_accident': 'Accidents & first aid',
  'section_maintenance': 'Maintenance & disposal',
  'legal_note': 'This operating instruction is binding (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). If anything is unclear, ask your '
      'dispatcher — before you start the task.',
  'empty_list': 'No operating instructions are available in your language '
      'yet. Please contact your admin.',
  'cat_vehicle': 'Vehicle & driving',
  'cat_ppe': 'Protective equipment',
  'cat_handling': 'Parcels & load',
  'cat_hazardous': 'Hazardous substances',
  'cat_hygiene': 'Hygiene & skin protection',
  'cat_workplace': 'Workplace',
  'ack_button': 'Mark as read',
  'ack_hint': 'Confirm that you have read and understood this operating '
      'instruction.',
  'ack_confirmed': 'Confirmed',
  'ack_confirmed_on': 'Read and confirmed on {date}',
  'ack_pending': 'Not confirmed yet',
  'ack_progress': '{done} of {total} confirmed',
  'ack_open_count': '{n} still open',
  'ack_all_done': 'All operating instructions confirmed.',
  'ack_saving': 'Saving …',
  'ack_success': 'Operating instruction confirmed as read.',
  'ack_error': 'Could not save your confirmation. Check your internet '
      'connection and try again.',
};

// ── Shqip (Albanisch) ───────────────────────────────────────────────
const Map<String, String> opsTextsSq = {
  'page_title': 'Udhëzime operative',
  'page_intro': 'Udhëzime të detyrueshme nga punëdhënësi yt për punën me '
      'automjete, pajisje dhe substanca të rrezikshme. Duhet t’i njohësh '
      'dhe t’i zbatosh.',
  'detail_title': 'Udhëzim operativ',
  'link_badge': 'Udhëzim operativ',
  'section_scope': 'Fusha e zbatimit',
  'section_hazards': 'Rreziqet për njeriun dhe mjedisin',
  'section_protection': 'Masat mbrojtëse dhe rregullat e sjelljes',
  'section_failure': 'Si të veprosh në rast defekti',
  'section_accident': 'Aksidentet dhe ndihma e parë',
  'section_maintenance': 'Mirëmbajtja dhe asgjësimi',
  'legal_note': 'Ky udhëzim operativ është i detyrueshëm (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). Nëse diçka nuk të është e qartë, pyet '
      'dispeçerin tënd — para se ta fillosh punën.',
  'empty_list': 'Ende nuk ka udhëzime operative në gjuhën tënde. Kontakto '
      'adminin tënd.',
  'cat_vehicle': 'Automjeti dhe drejtimi',
  'cat_ppe': 'Pajisjet mbrojtëse',
  'cat_handling': 'Dërgesat dhe ngarkesa',
  'cat_hazardous': 'Substancat e rrezikshme',
  'cat_hygiene': 'Higjiena dhe mbrojtja e lëkurës',
  'cat_workplace': 'Vendi i punës',
  'ack_button': 'Shëno si të lexuar',
  'ack_hint': 'Konfirmo që e ke lexuar dhe e ke kuptuar këtë udhëzim '
      'operativ.',
  'ack_confirmed': 'E konfirmuar',
  'ack_confirmed_on': 'Lexuar dhe konfirmuar më {date}',
  'ack_pending': 'Ende e pakonfirmuar',
  'ack_progress': '{done} nga {total} të konfirmuara',
  'ack_open_count': 'edhe {n} të hapura',
  'ack_all_done': 'Të gjitha udhëzimet operative janë konfirmuar.',
  'ack_saving': 'Po ruhet …',
  'ack_success': 'Udhëzimi operativ u konfirmua si i lexuar.',
  'ack_error': 'Konfirmimi nuk u ruajt dot. Kontrollo lidhjen me internetin '
      'dhe provo përsëri.',
};

// ── Magyar (Ungarisch) ──────────────────────────────────────────────
const Map<String, String> opsTextsHu = {
  'page_title': 'Munkautasítások',
  'page_intro': 'A munkáltatód kötelező érvényű utasításai a járművek, a '
      'felszerelés és a veszélyes anyagok kezeléséhez. Ismerned és '
      'követned kell őket.',
  'detail_title': 'Munkautasítás',
  'link_badge': 'Munkautasítás',
  'section_scope': 'Hatály',
  'section_hazards': 'Veszélyek az emberre és a környezetre',
  'section_protection': 'Védőintézkedések és magatartási szabályok',
  'section_failure': 'Teendők üzemzavar esetén',
  'section_accident': 'Baleset és elsősegély',
  'section_maintenance': 'Karbantartás és ártalmatlanítás',
  'legal_note': 'Ez a munkautasítás kötelező érvényű (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). Ha valami nem világos, kérdezd meg a '
      'diszpécsert — mielőtt elkezded a munkát.',
  'empty_list': 'A nyelveden még nincs munkautasítás. Szólj az '
      'adminodnak.',
  'cat_vehicle': 'Jármű és vezetés',
  'cat_ppe': 'Védőfelszerelés',
  'cat_handling': 'Küldemények és rakomány',
  'cat_hazardous': 'Veszélyes anyagok',
  'cat_hygiene': 'Higiénia és bőrvédelem',
  'cat_workplace': 'Munkahely',
  'ack_button': 'Megjelölés olvasottként',
  'ack_hint': 'Erősítsd meg, hogy elolvastad és megértetted ezt a '
      'munkautasítást.',
  'ack_confirmed': 'Megerősítve',
  'ack_confirmed_on': 'Elolvasva és megerősítve: {date}',
  'ack_pending': 'Még nincs megerősítve',
  'ack_progress': '{done} / {total} megerősítve',
  'ack_open_count': 'még {n} hátra',
  'ack_all_done': 'Minden munkautasítás megerősítve.',
  'ack_saving': 'Mentés …',
  'ack_success': 'A munkautasítást olvasottként megerősítetted.',
  'ack_error': 'A megerősítést nem sikerült menteni. Ellenőrizd az '
      'internetkapcsolatot, és próbáld újra.',
};

// ── Română (Rumänisch) ──────────────────────────────────────────────
const Map<String, String> opsTextsRo = {
  'page_title': 'Instrucțiuni de lucru',
  'page_intro': 'Instrucțiuni obligatorii de la angajatorul tău pentru '
      'lucrul cu vehicule, echipamente și substanțe periculoase. Trebuie '
      'să le cunoști și să le respecți.',
  'detail_title': 'Instrucțiune de lucru',
  'link_badge': 'Instrucțiune de lucru',
  'section_scope': 'Domeniu de aplicare',
  'section_hazards': 'Pericole pentru om și mediu',
  'section_protection': 'Măsuri de protecție și reguli de comportament',
  'section_failure': 'Ce faci în caz de defecțiune',
  'section_accident': 'Accidente și prim ajutor',
  'section_maintenance': 'Întreținere și eliminare',
  'legal_note': 'Această instrucțiune de lucru este obligatorie '
      '(§ 12 ArbSchG, § 4 DGUV Vorschrift 1). Dacă ceva nu e clar, '
      'întreabă-ți dispecerul — înainte să începi activitatea.',
  'empty_list': 'Încă nu există instrucțiuni de lucru în limba ta. '
      'Contactează-ți adminul.',
  'cat_vehicle': 'Vehicul și condus',
  'cat_ppe': 'Echipament de protecție',
  'cat_handling': 'Colete și încărcătură',
  'cat_hazardous': 'Substanțe periculoase',
  'cat_hygiene': 'Igienă și protecția pielii',
  'cat_workplace': 'Locul de muncă',
  'ack_button': 'Marchează ca citit',
  'ack_hint': 'Confirmă că ai citit și ai înțeles această instrucțiune de '
      'lucru.',
  'ack_confirmed': 'Confirmat',
  'ack_confirmed_on': 'Citit și confirmat pe {date}',
  'ack_pending': 'Încă neconfirmat',
  'ack_progress': '{done} din {total} confirmate',
  'ack_open_count': 'încă {n} de confirmat',
  'ack_all_done': 'Toate instrucțiunile de lucru sunt confirmate.',
  'ack_saving': 'Se salvează …',
  'ack_success': 'Instrucțiunea de lucru a fost confirmată ca citită.',
  'ack_error': 'Confirmarea nu a putut fi salvată. Verifică conexiunea la '
      'internet și încearcă din nou.',
};

// ── Hrvatski (Kroatisch) ────────────────────────────────────────────
const Map<String, String> opsTextsHr = {
  'page_title': 'Radne upute',
  'page_intro': 'Obvezne upute tvog poslodavca za rad s vozilima, opremom '
      'i opasnim tvarima. Moraš ih poznavati i pridržavati ih se.',
  'detail_title': 'Radna uputa',
  'link_badge': 'Radna uputa',
  'section_scope': 'Područje primjene',
  'section_hazards': 'Opasnosti za čovjeka i okoliš',
  'section_protection': 'Zaštitne mjere i pravila ponašanja',
  'section_failure': 'Postupanje u slučaju kvara',
  'section_accident': 'Nezgode i prva pomoć',
  'section_maintenance': 'Održavanje i zbrinjavanje',
  'legal_note': 'Ova radna uputa je obvezujuća (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). Ako ti nešto nije jasno, pitaj svog '
      'dispečera — prije nego što započneš posao.',
  'empty_list': 'Na tvom jeziku još nema radnih uputa. Javi se svom '
      'adminu.',
  'cat_vehicle': 'Vozilo i vožnja',
  'cat_ppe': 'Zaštitna oprema',
  'cat_handling': 'Pošiljke i teret',
  'cat_hazardous': 'Opasne tvari',
  'cat_hygiene': 'Higijena i zaštita kože',
  'cat_workplace': 'Radno mjesto',
  'ack_button': 'Označi kao pročitano',
  'ack_hint': 'Potvrdi da si pročitao i razumio ovu radnu uputu.',
  'ack_confirmed': 'Potvrđeno',
  'ack_confirmed_on': 'Pročitano i potvrđeno {date}',
  'ack_pending': 'Još nije potvrđeno',
  'ack_progress': '{done} od {total} potvrđeno',
  'ack_open_count': 'još {n} otvoreno',
  'ack_all_done': 'Sve radne upute su potvrđene.',
  'ack_saving': 'Spremanje …',
  'ack_success': 'Radna uputa potvrđena kao pročitana.',
  'ack_error': 'Potvrdu nije bilo moguće spremiti. Provjeri internetsku vezu '
      'i pokušaj ponovno.',
};

// ── Türkçe (Türkisch) ───────────────────────────────────────────────
const Map<String, String> opsTextsTr = {
  'page_title': 'İş talimatları',
  'page_intro': 'İşverenin tarafından araçlar, ekipman ve tehlikeli '
      'maddelerle çalışma için verilen bağlayıcı talimatlar. Bunları '
      'bilmek ve uygulamak zorundasın.',
  'detail_title': 'İş talimatı',
  'link_badge': 'İş talimatı',
  'section_scope': 'Kapsam',
  'section_hazards': 'İnsan ve çevre için tehlikeler',
  'section_protection': 'Koruyucu önlemler ve davranış kuralları',
  'section_failure': 'Arıza durumunda ne yapmalı',
  'section_accident': 'Kaza ve ilk yardım',
  'section_maintenance': 'Bakım ve bertaraf',
  'legal_note': 'Bu iş talimatı bağlayıcıdır (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). Bir şey net değilse, işe başlamadan önce '
      'dispeçerine sor.',
  'empty_list': 'Kendi dilinde henüz iş talimatı yok. Yöneticinle '
      'iletişime geç.',
  'cat_vehicle': 'Araç ve sürüş',
  'cat_ppe': 'Koruyucu donanım',
  'cat_handling': 'Gönderiler ve yük',
  'cat_hazardous': 'Tehlikeli maddeler',
  'cat_hygiene': 'Hijyen ve cilt koruması',
  'cat_workplace': 'Çalışma yeri',
  'ack_button': 'Okundu olarak işaretle',
  'ack_hint': 'Bu iş talimatını okuduğunu ve anladığını onayla.',
  'ack_confirmed': 'Onaylandı',
  'ack_confirmed_on': '{date} tarihinde okundu ve onaylandı',
  'ack_pending': 'Henüz onaylanmadı',
  'ack_progress': '{total} talimattan {done} tanesi onaylandı',
  'ack_open_count': '{n} tanesi açık',
  'ack_all_done': 'Tüm iş talimatları onaylandı.',
  'ack_saving': 'Kaydediliyor …',
  'ack_success': 'İş talimatı okundu olarak onaylandı.',
  'ack_error': 'Onay kaydedilemedi. İnternet bağlantını kontrol et ve tekrar '
      'dene.',
};

// ── Русский (Russisch) ──────────────────────────────────────────────
const Map<String, String> opsTextsRu = {
  'page_title': 'Рабочие инструкции',
  'page_intro': 'Обязательные инструкции твоего работодателя по работе с '
      'транспортом, оборудованием и опасными веществами. Ты должен их '
      'знать и соблюдать.',
  'detail_title': 'Рабочая инструкция',
  'link_badge': 'Рабочая инструкция',
  'section_scope': 'Область применения',
  'section_hazards': 'Опасности для человека и окружающей среды',
  'section_protection': 'Меры защиты и правила поведения',
  'section_failure': 'Действия при неисправности',
  'section_accident': 'Несчастные случаи и первая помощь',
  'section_maintenance': 'Обслуживание и утилизация',
  'legal_note': 'Эта рабочая инструкция обязательна к исполнению '
      '(§ 12 ArbSchG, § 4 DGUV Vorschrift 1). Если что-то непонятно, '
      'спроси своего диспетчера — прежде чем приступать к работе.',
  'empty_list': 'На твоём языке рабочих инструкций пока нет. Обратись к '
      'своему админу.',
  'cat_vehicle': 'Автомобиль и вождение',
  'cat_ppe': 'Средства защиты',
  'cat_handling': 'Отправления и груз',
  'cat_hazardous': 'Опасные вещества',
  'cat_hygiene': 'Гигиена и защита кожи',
  'cat_workplace': 'Рабочее место',
  'ack_button': 'Отметить как прочитанное',
  'ack_hint': 'Подтверди, что ты прочитал и понял эту рабочую инструкцию.',
  'ack_confirmed': 'Подтверждено',
  'ack_confirmed_on': 'Прочитано и подтверждено {date}',
  'ack_pending': 'Ещё не подтверждено',
  'ack_progress': 'Подтверждено {done} из {total}',
  'ack_open_count': 'осталось {n}',
  'ack_all_done': 'Все рабочие инструкции подтверждены.',
  'ack_saving': 'Сохранение …',
  'ack_success': 'Рабочая инструкция подтверждена как прочитанная.',
  'ack_error': 'Не удалось сохранить подтверждение. Проверь интернет-'
      'соединение и попробуй ещё раз.',
};

// ── Български (Bulgarisch) ──────────────────────────────────────────
const Map<String, String> opsTextsBg = {
  'page_title': 'Работни инструкции',
  'page_intro': 'Задължителни инструкции от твоя работодател за работа с '
      'превозни средства, оборудване и опасни вещества. Трябва да ги '
      'знаеш и да ги спазваш.',
  'detail_title': 'Работна инструкция',
  'link_badge': 'Работна инструкция',
  'section_scope': 'Обхват',
  'section_hazards': 'Опасности за човека и околната среда',
  'section_protection': 'Защитни мерки и правила за поведение',
  'section_failure': 'Действия при повреда',
  'section_accident': 'Злополуки и първа помощ',
  'section_maintenance': 'Поддръжка и изхвърляне',
  'legal_note': 'Тази работна инструкция е задължителна (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). Ако нещо не ти е ясно, попитай диспечера '
      'си — преди да започнеш работа.',
  'empty_list': 'На твоя език още няма работни инструкции. Свържи се с '
      'админа си.',
  'cat_vehicle': 'Превозно средство и шофиране',
  'cat_ppe': 'Защитно оборудване',
  'cat_handling': 'Пратки и товар',
  'cat_hazardous': 'Опасни вещества',
  'cat_hygiene': 'Хигиена и защита на кожата',
  'cat_workplace': 'Работно място',
  'ack_button': 'Отбележи като прочетено',
  'ack_hint': 'Потвърди, че си прочел и разбрал тази работна инструкция.',
  'ack_confirmed': 'Потвърдено',
  'ack_confirmed_on': 'Прочетено и потвърдено на {date}',
  'ack_pending': 'Още не е потвърдено',
  'ack_progress': 'Потвърдени {done} от {total}',
  'ack_open_count': 'остават {n}',
  'ack_all_done': 'Всички работни инструкции са потвърдени.',
  'ack_saving': 'Запазване …',
  'ack_success': 'Работната инструкция е потвърдена като прочетена.',
  'ack_error': 'Потвърждението не можа да бъде запазено. Провери интернет '
      'връзката и опитай отново.',
};

// ── العربية (Arabisch) ──────────────────────────────────────────────
const Map<String, String> opsTextsAr = {
  'page_title': 'تعليمات التشغيل',
  'page_intro': 'تعليمات ملزمة من صاحب العمل للتعامل مع المركبات '
      'والمعدات والمواد الخطرة. يجب أن تعرفها وتلتزم بها.',
  'detail_title': 'تعليمات التشغيل',
  'link_badge': 'تعليمات التشغيل',
  'section_scope': 'نطاق التطبيق',
  'section_hazards': 'المخاطر على الإنسان والبيئة',
  'section_protection': 'إجراءات الحماية وقواعد السلوك',
  'section_failure': 'التصرف عند حدوث عطل',
  'section_accident': 'الحوادث والإسعافات الأولية',
  'section_maintenance': 'الصيانة والتخلص من النفايات',
  'legal_note': 'هذه التعليمات ملزمة (§ 12 ArbSchG, '
      '§ 4 DGUV Vorschrift 1). إذا كان هناك شيء غير واضح، اسأل المشرف '
      'على التوزيع قبل أن تبدأ العمل.',
  'empty_list': 'لا توجد تعليمات تشغيل بلغتك بعد. تواصل مع المشرف.',
  'cat_vehicle': 'المركبة والقيادة',
  'cat_ppe': 'معدات الحماية',
  'cat_handling': 'الشحنات والحمولة',
  'cat_hazardous': 'المواد الخطرة',
  'cat_hygiene': 'النظافة وحماية الجلد',
  'cat_workplace': 'مكان العمل',
  'ack_button': 'وضع علامة كمقروء',
  'ack_hint': 'أكّد أنك قرأت هذه التعليمات وفهمتها.',
  'ack_confirmed': 'تم التأكيد',
  'ack_confirmed_on': 'تمت القراءة والتأكيد في {date}',
  'ack_pending': 'لم يتم التأكيد بعد',
  'ack_progress': 'تم تأكيد {done} من {total}',
  'ack_open_count': 'ما زال {n} متبقياً',
  'ack_all_done': 'تم تأكيد جميع تعليمات التشغيل.',
  'ack_saving': 'جارٍ الحفظ …',
  'ack_success': 'تم تأكيد قراءة تعليمات التشغيل.',
  'ack_error': 'تعذّر حفظ التأكيد. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
};

// ── Español (Spanisch) ──────────────────────────────────────────────
const Map<String, String> opsTextsEs = {
  'page_title': 'Instrucciones de trabajo',
  'page_intro': 'Instrucciones vinculantes de tu empresa para el manejo '
      'de vehículos, equipos y sustancias peligrosas. Debes conocerlas y '
      'cumplirlas.',
  'detail_title': 'Instrucción de trabajo',
  'link_badge': 'Instrucción de trabajo',
  'section_scope': 'Ámbito de aplicación',
  'section_hazards': 'Peligros para las personas y el medio ambiente',
  'section_protection': 'Medidas de protección y normas de conducta',
  'section_failure': 'Qué hacer en caso de avería',
  'section_accident': 'Accidentes y primeros auxilios',
  'section_maintenance': 'Mantenimiento y eliminación',
  'legal_note': 'Esta instrucción de trabajo es vinculante (§ 12 '
      'ArbSchG, § 4 DGUV Vorschrift 1). Si algo no te queda claro, '
      'pregunta a tu dispatcher antes de empezar la tarea.',
  'empty_list': 'Todavía no hay instrucciones de trabajo en tu idioma. '
      'Ponte en contacto con tu admin.',
  'cat_vehicle': 'Vehículo y conducción',
  'cat_ppe': 'Equipo de protección',
  'cat_handling': 'Envíos y carga',
  'cat_hazardous': 'Sustancias peligrosas',
  'cat_hygiene': 'Higiene y protección de la piel',
  'cat_workplace': 'Puesto de trabajo',
  'ack_button': 'Marcar como leído',
  'ack_hint': 'Confirma que has leído y entendido esta instrucción de '
      'trabajo.',
  'ack_confirmed': 'Confirmado',
  'ack_confirmed_on': 'Leído y confirmado el {date}',
  'ack_pending': 'Aún sin confirmar',
  'ack_progress': '{done} de {total} confirmadas',
  'ack_open_count': 'quedan {n}',
  'ack_all_done': 'Todas las instrucciones de trabajo están '
      'confirmadas.',
  'ack_saving': 'Guardando …',
  'ack_success': 'Instrucción de trabajo confirmada como leída.',
  'ack_error': 'No se ha podido guardar la confirmación. Comprueba tu '
      'conexión a internet e inténtalo de nuevo.',
};

const Map<String, Map<String, String>> opsTextsByLang = {
  'de': opsTextsDe,
  'en': opsTextsEn,
  'sq': opsTextsSq,
  'hu': opsTextsHu,
  'ro': opsTextsRo,
  'hr': opsTextsHr,
  'tr': opsTextsTr,
  'ru': opsTextsRu,
  'bg': opsTextsBg,
  'ar': opsTextsAr,
  'es': opsTextsEs,
};

/// Text-Lookup mit Fallback locale -> en -> de.
///
/// [vars] ersetzt Platzhalter der Form `{key}`.
String opsText(
  String languageCode,
  String key, {
  Map<String, String>? vars,
}) {
  final code = languageCode.trim().toLowerCase();
  final lang = opsTextsByLang[code];
  var out = lang?[key] ?? opsTextsEn[key] ?? opsTextsDe[key] ?? key;
  if (vars != null) {
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
  }
  return out;
}

/// Versalien-Schreibweise für Rubriken-Labels.
///
/// Dart kennt kein locale-sensitives `toUpperCase()`; im Türkischen
/// würde 'i' sonst zu 'I' statt 'İ'. Schriften ohne Groß-/Kleinschreibung
/// (Arabisch) bleiben unverändert.
String opsUpper(String languageCode, String text) {
  if (languageCode.trim().toLowerCase() == 'tr') {
    return text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }
  return text.toUpperCase();
}
