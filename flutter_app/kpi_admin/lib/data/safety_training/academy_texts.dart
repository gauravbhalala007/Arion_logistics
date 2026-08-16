// lib/data/safety_training/academy_texts.dart
//
// Anzeigetexte der DA-Academy-Übersichtsseite (driver_academy_page.dart),
// je Sprache eine Map mit identischem Key-Satz (Vertrag). Platzhalter in
// geschweiften Klammern, z. B. {n}. Auflösung mit Fallback-Kette
// locale -> en -> de, analog zu driving_safety_texts.dart und
// safety_texts_*.dart.
//
// Bewusst NICHT uebersetzt (bleiben in allen Sprachen gleich):
// 'DA Academy', 'Green Book', 'CoDriver' sowie deutsche Rechtsbegriffe.

// ── Deutsch (Master) ────────────────────────────────────────────────
const Map<String, String> academyTextsDe = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Fahrtenkontrollbuch: Lenk- und Ruhezeiten',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Zwei Tage Begleitfahrt: Vorbereitung mit '
      'Abschlusstest',
  'driving_title': 'Fahrsicherheitstraining',
  'driving_subtitle': '10 Module · Abschlusstest · Zertifikat',
  'privacy_title': 'Datenschutz',
  'privacy_subtitle': 'DSGVO im Zustellalltag: Test und Unterschrift',
  'ops_title': 'Betriebsanweisungen',
  'ops_subtitle': 'Verbindliche Anweisungen zum Nachschlagen',
  'faq_title': 'FAQ-Training',
  'faq_subtitle': 'Teste dein Wissen aus den FAQs',
  'status_open': 'Noch offen',
  'status_done': 'Erledigt am {done}',
  'status_done_due': 'Erledigt am {done} · wieder fällig am {due}',
  'status_due_soon': 'Erledigt am {done} · bald fällig am {due}',
  'status_expired': 'Abgelaufen am {due}, bitte erneut absolvieren',
  'status_ack_progress': '{n} von {total} bestätigt',
  'status_ack_all': 'Alle bestätigt',
  'badge_coming_soon': 'Kommt bald',
  'empty_categories': 'Es gibt noch keine Academy-Kategorien. Melde dich '
      'bei deinem Admin.',
};

// ── English ─────────────────────────────────────────────────────────
const Map<String, String> academyTextsEn = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Driving log: driving and rest times',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Two shadow days: preparation with final test',
  'driving_title': 'Driving safety training',
  'driving_subtitle': '10 modules · final test · certificate',
  'privacy_title': 'Data protection',
  'privacy_subtitle': 'GDPR in daily delivery: test and signature',
  'ops_title': 'Operating instructions',
  'ops_subtitle': 'Binding instructions for reference',
  'faq_title': 'FAQ training',
  'faq_subtitle': 'Test what you remember from the FAQ',
  'status_open': 'Not started yet',
  'status_done': 'Completed on {done}',
  'status_done_due': 'Completed on {done} · due again on {due}',
  'status_due_soon': 'Completed on {done} · due soon on {due}',
  'status_expired': 'Expired on {due}, please complete it again',
  'status_ack_progress': '{n} of {total} confirmed',
  'status_ack_all': 'All confirmed',
  'badge_coming_soon': 'Coming soon',
  'empty_categories': 'No academy categories are available yet. Please '
      'contact your admin.',
};

// ── Shqip (Albanisch) ───────────────────────────────────────────────
const Map<String, String> academyTextsSq = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Libri i kontrollit: kohët e drejtimit dhe pushimit',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Dy ditë shoqërimi: përgatitje me test përfundimtar',
  'driving_title': 'Trajnim i sigurisë në vozitje',
  'driving_subtitle': '10 module · test përfundimtar · certifikatë',
  'privacy_title': 'Mbrojtja e të dhënave',
  'privacy_subtitle': 'GDPR në përditshmërinë e dërgesave: test dhe '
      'nënshkrim',
  'ops_title': 'Udhëzime operative',
  'ops_subtitle': 'Udhëzime të detyrueshme për konsultim',
  'faq_title': 'Trajnim FAQ',
  'faq_subtitle': 'Provo atë që mban mend nga FAQ-të',
  'status_open': 'Ende e papërfunduar',
  'status_done': 'Përfunduar më {done}',
  'status_done_due': 'Përfunduar më {done} · sërish e detyrueshme më {due}',
  'status_due_soon': 'Përfunduar më {done} · skadon së shpejti më {due}',
  'status_expired': 'Skadoi më {due}, të lutem përsërite',
  'status_ack_progress': '{n} nga {total} të konfirmuara',
  'status_ack_all': 'Të gjitha të konfirmuara',
  'badge_coming_soon': 'Së shpejti',
  'empty_categories': 'Ende nuk ka kategori në DA Academy. Kontakto '
      'adminin tënd.',
};

// ── Magyar (Ungarisch) ──────────────────────────────────────────────
const Map<String, String> academyTextsHu = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Menetlevél: vezetési és pihenőidő',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Két kísérőnap: felkészülés záróteszttel',
  'driving_title': 'Vezetésbiztonsági tréning',
  'driving_subtitle': '10 modul · záróteszt · tanúsítvány',
  'privacy_title': 'Adatvédelem',
  'privacy_subtitle': 'GDPR a kézbesítés mindennapjaiban: teszt és '
      'aláírás',
  'ops_title': 'Munkautasítások',
  'ops_subtitle': 'Kötelező utasítások utánanézéshez',
  'faq_title': 'GYIK tréning',
  'faq_subtitle': 'Próbáld ki, mit jegyeztél meg a GYIK-ből',
  'status_open': 'Még nincs teljesítve',
  'status_done': 'Teljesítve: {done}',
  'status_done_due': 'Teljesítve: {done} · újra esedékes: {due}',
  'status_due_soon': 'Teljesítve: {done} · hamarosan esedékes: {due}',
  'status_expired': 'Lejárt: {due}, kérjük, végezd el újra',
  'status_ack_progress': '{n} / {total} megerősítve',
  'status_ack_all': 'Mind megerősítve',
  'badge_coming_soon': 'Hamarosan',
  'empty_categories': 'Még nincs elérhető DA Academy kategória. Szólj az '
      'adminodnak.',
};

// ── Română (Rumänisch) ──────────────────────────────────────────────
const Map<String, String> academyTextsRo = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Registrul de control: timpi de conducere și odihnă',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Două zile de însoțire: pregătire cu test final',
  'driving_title': 'Training de siguranță rutieră',
  'driving_subtitle': '10 module · test final · certificat',
  'privacy_title': 'Protecția datelor',
  'privacy_subtitle': 'GDPR în activitatea zilnică: test și semnătură',
  'ops_title': 'Instrucțiuni de lucru',
  'ops_subtitle': 'Instrucțiuni obligatorii, pentru consultare',
  'faq_title': 'Antrenament FAQ',
  'faq_subtitle': 'Verifică ce ai reținut din FAQ',
  'status_open': 'Încă nefinalizat',
  'status_done': 'Finalizat pe {done}',
  'status_done_due': 'Finalizat pe {done} · scadent din nou pe {due}',
  'status_due_soon': 'Finalizat pe {done} · scadent în curând pe {due}',
  'status_expired': 'Expirat pe {due}, te rugăm să îl reiei',
  'status_ack_progress': '{n} din {total} confirmate',
  'status_ack_all': 'Toate confirmate',
  'badge_coming_soon': 'În curând',
  'empty_categories': 'Încă nu există categorii DA Academy. Contactează-ți '
      'adminul.',
};

// ── Hrvatski (Kroatisch) ────────────────────────────────────────────
const Map<String, String> academyTextsHr = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Knjiga kontrole: vrijeme vožnje i odmora',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Dva dana pratnje: priprema sa završnim testom',
  'driving_title': 'Trening sigurne vožnje',
  'driving_subtitle': '10 modula · završni test · certifikat',
  'privacy_title': 'Zaštita podataka',
  'privacy_subtitle': 'GDPR u svakodnevnoj dostavi: test i potpis',
  'ops_title': 'Radne upute',
  'ops_subtitle': 'Obvezne upute za brzu provjeru',
  'faq_title': 'FAQ trening',
  'faq_subtitle': 'Provjeri što si zapamtio iz FAQ-a',
  'status_open': 'Još nije odrađeno',
  'status_done': 'Odrađeno {done}',
  'status_done_due': 'Odrađeno {done} · ponovno obvezno {due}',
  'status_due_soon': 'Odrađeno {done} · uskoro istječe {due}',
  'status_expired': 'Isteklo {due}, molimo ponovi',
  'status_ack_progress': '{n} od {total} potvrđeno',
  'status_ack_all': 'Sve potvrđeno',
  'badge_coming_soon': 'Uskoro',
  'empty_categories': 'Još nema kategorija u DA Academy. Javi se svom '
      'adminu.',
};

// ── Türkçe (Türkisch) ───────────────────────────────────────────────
const Map<String, String> academyTextsTr = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Sefer kontrol defteri: sürüş ve dinlenme süreleri',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'İki refakat günü: hazırlık ve bitirme testi',
  'driving_title': 'Sürüş güvenliği eğitimi',
  'driving_subtitle': '10 modül · final testi · sertifika',
  'privacy_title': 'Veri koruma',
  'privacy_subtitle': 'Günlük dağıtımda GDPR: test ve imza',
  'ops_title': 'İş talimatları',
  'ops_subtitle': 'Bağlayıcı talimatlar — başvuru için',
  'faq_title': 'SSS eğitimi',
  'faq_subtitle': 'SSS’lerden hatırladığını test et',
  'status_open': 'Henüz tamamlanmadı',
  'status_done': '{done} tarihinde tamamlandı',
  'status_done_due': '{done} tarihinde tamamlandı · {due} tarihinde yeniden '
      'gerekli',
  'status_due_soon': '{done} tarihinde tamamlandı · {due} tarihinde doluyor',
  'status_expired': '{due} tarihinde doldu, lütfen tekrar tamamla',
  'status_ack_progress': '{total} içinden {n} onaylandı',
  'status_ack_all': 'Tümü onaylandı',
  'badge_coming_soon': 'Yakında',
  'empty_categories': 'Henüz DA Academy kategorisi yok. Yöneticinle '
      'iletişime geç.',
};

// ── Русский (Russisch) ──────────────────────────────────────────────
const Map<String, String> academyTextsRu = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Книга учёта: время управления и отдыха',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Два дня сопровождения: подготовка и итоговый тест',
  'driving_title': 'Тренинг безопасного вождения',
  'driving_subtitle': '10 модулей · итоговый тест · сертификат',
  'privacy_title': 'Защита данных',
  'privacy_subtitle': 'GDPR в повседневной доставке: тест и подпись',
  'ops_title': 'Рабочие инструкции',
  'ops_subtitle': 'Обязательные инструкции для справки',
  'faq_title': 'Тренинг по FAQ',
  'faq_subtitle': 'Проверь, что ты запомнил из FAQ',
  'status_open': 'Ещё не пройдено',
  'status_done': 'Пройдено {done}',
  'status_done_due': 'Пройдено {done} · снова требуется {due}',
  'status_due_soon': 'Пройдено {done} · скоро истекает {due}',
  'status_expired': 'Истекло {due}, пожалуйста, пройди заново',
  'status_ack_progress': '{n} из {total} подтверждено',
  'status_ack_all': 'Всё подтверждено',
  'badge_coming_soon': 'Скоро',
  'empty_categories': 'Категорий DA Academy пока нет. Обратись к своему '
      'админу.',
};

// ── Български (Bulgarisch) ──────────────────────────────────────────
const Map<String, String> academyTextsBg = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Книга за контрол: време на управление и почивка',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Два дни съпровождане: подготовка с финален тест',
  'driving_title': 'Обучение за безопасно шофиране',
  'driving_subtitle': '10 модула · финален тест · сертификат',
  'privacy_title': 'Защита на данните',
  'privacy_subtitle': 'GDPR в ежедневната доставка: тест и подпис',
  'ops_title': 'Работни инструкции',
  'ops_subtitle': 'Задължителни инструкции за справка',
  'faq_title': 'Обучение по ЧЗВ',
  'faq_subtitle': 'Провери какво си запомнил от ЧЗВ',
  'status_open': 'Още не е направено',
  'status_done': 'Направено на {done}',
  'status_done_due': 'Направено на {done} · отново дължимо на {due}',
  'status_due_soon': 'Направено на {done} · изтича скоро на {due}',
  'status_expired': 'Изтече на {due}, моля, направи го отново',
  'status_ack_progress': '{n} от {total} потвърдени',
  'status_ack_all': 'Всичко е потвърдено',
  'badge_coming_soon': 'Очаквайте скоро',
  'empty_categories': 'Още няма категории в DA Academy. Свържи се с '
      'админа си.',
};

// ── العربية (Arabisch) ──────────────────────────────────────────────
const Map<String, String> academyTextsAr = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'دفتر مراقبة الرحلات: أوقات القيادة والراحة',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'يوما مرافقة: تحضير مع اختبار نهائي',
  'driving_title': 'تدريب السلامة أثناء القيادة',
  'driving_subtitle': '10 وحدات · اختبار نهائي · شهادة',
  'privacy_title': 'حماية البيانات',
  'privacy_subtitle': 'اللائحة العامة لحماية البيانات في العمل اليومي: '
      'اختبار وتوقيع',
  'ops_title': 'تعليمات التشغيل',
  'ops_subtitle': 'تعليمات ملزمة للرجوع إليها',
  'faq_title': 'تدريب الأسئلة الشائعة',
  'faq_subtitle': 'اختبر ما تتذكره من الأسئلة الشائعة',
  'status_open': 'لم يتم بعد',
  'status_done': 'تم الإنجاز في {done}',
  'status_done_due': 'تم الإنجاز في {done} · مستحق مجددًا في {due}',
  'status_due_soon': 'تم الإنجاز في {done} · يستحق قريبًا في {due}',
  'status_expired': 'انتهت الصلاحية في {due}، يرجى إعادته',
  'status_ack_progress': '{n} من {total} مؤكدة',
  'status_ack_all': 'تم تأكيد الكل',
  'badge_coming_soon': 'قريباً',
  'empty_categories': 'لا توجد فئات في DA Academy بعد. تواصل مع المشرف.',
};

// ── Español (Spanisch) ──────────────────────────────────────────────
const Map<String, String> academyTextsEs = {
  'page_title': 'DA Academy',
  'green_book_title': 'Green Book',
  'green_book_subtitle': 'Libro de control: tiempos de conducción y '
      'descanso',
  'ride_along_title': 'Ride Along',
  'ride_along_subtitle': 'Dos días de acompañamiento: preparación con '
      'examen final',
  'driving_title': 'Formación en seguridad vial',
  'driving_subtitle': '10 módulos · examen final · certificado',
  'privacy_title': 'Protección de datos',
  'privacy_subtitle': 'DSGVO (RGPD) en el reparto diario: test y firma',
  'ops_title': 'Instrucciones de trabajo',
  'ops_subtitle': 'Instrucciones vinculantes para consultar',
  'faq_title': 'Entrenamiento con FAQ',
  'faq_subtitle': 'Pon a prueba lo que recuerdas de las FAQ',
  'status_open': 'Aún pendiente',
  'status_done': 'Completado el {done}',
  'status_done_due': 'Completado el {done} · vuelve a tocar el {due}',
  'status_due_soon': 'Completado el {done} · toca pronto, el {due}',
  'status_expired': 'Caducó el {due}; vuelve a realizarlo, por favor',
  'status_ack_progress': '{n} de {total} confirmadas',
  'status_ack_all': 'Todas confirmadas',
  'badge_coming_soon': 'Muy pronto',
  'empty_categories': 'Todavía no hay categorías de la DA Academy. '
      'Ponte en contacto con tu admin.',
};

const Map<String, Map<String, String>> academyTextsByLang = {
  'de': academyTextsDe,
  'en': academyTextsEn,
  'sq': academyTextsSq,
  'hu': academyTextsHu,
  'ro': academyTextsRo,
  'hr': academyTextsHr,
  'tr': academyTextsTr,
  'ru': academyTextsRu,
  'bg': academyTextsBg,
  'ar': academyTextsAr,
  'es': academyTextsEs,
};

/// Text-Lookup mit Fallback locale -> en -> de.
///
/// [vars] ersetzt Platzhalter der Form `{key}`.
String academyText(
  String languageCode,
  String key, {
  Map<String, String>? vars,
}) {
  final code = languageCode.trim().toLowerCase();
  final lang = academyTextsByLang[code];
  var out = lang?[key] ?? academyTextsEn[key] ?? academyTextsDe[key] ?? key;
  if (vars != null) {
    vars.forEach((k, v) => out = out.replaceAll('{$k}', v));
  }
  return out;
}
