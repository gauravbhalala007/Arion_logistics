// lib/data/driver_profile/driver_vehicle_issue_texts.dart
//
// Texte der Fahrerprofil-Karte „Fahrzeug-Mangel melden".
//
// Aufbau bewusst identisch zu `driver_profile_history_texts.dart`:
// eine `const Map<String, String>` je Sprache und ein Lookup mit der
// Fallback-Kette `locale -> en -> key`. Dadurch erscheint die Karte in
// allen elf Sprachen, die `AppLocalizations.supportedLocales` führt,
// ohne dass ein zweites Übersetzungssystem entsteht.

/// Text-Lookup mit Fallback `locale -> en -> key`.
///
/// `languageCode` darf ein Region-Subtag tragen (`de_DE`, `de-AT`) — er
/// wird abgeschnitten. `vars` ersetzt Platzhalter der Form `{key}`.
String driverVehicleIssueText(
  String languageCode,
  String key, {
  Map<String, String>? vars,
}) {
  final lang = languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;
  final table = _tables[lang] ?? _en;
  var out = table[key] ?? _en[key] ?? key;
  if (vars != null) {
    for (final entry in vars.entries) {
      out = out.replaceAll('{${entry.key}}', entry.value);
    }
  }
  return out;
}

const Map<String, Map<String, String>> _tables = <String, Map<String, String>>{
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

const Map<String, String> _en = <String, String>{
  'card_title': 'Report a vehicle issue',
  'card_subtitle': 'Pick a vehicle, describe the problem — your office sees it '
      'right away.',
  'dialog_title': 'Report a vehicle issue',
  'dialog_subtitle': 'For defects and wear. Use the accident form for '
      'accidents.',
  'field_vehicle': 'Vehicle',
  'search_hint': 'Search license plate',
  'no_match': 'No vehicle matches your search.',
  'fleet_empty_hint': 'License plate',
  'field_description': 'What is wrong?',
  'description_hint': 'e.g. rear left tyre loses air, sliding door jams …',
  'err_vehicle': 'Please select a vehicle.',
  'err_description': 'Please describe the issue.',
  'cancel': 'Cancel',
  'submit': 'Send report',
  'sending': 'Sending …',
  'snack_ok': 'Thanks — your report for {plate} has been sent.',
  'snack_err': 'Could not send the report: {error}',
};

const Map<String, String> _de = <String, String>{
  'card_title': 'Fahrzeug-Mangel melden',
  'card_subtitle': 'Fahrzeug wählen, Problem beschreiben — das Büro sieht es '
      'sofort.',
  'dialog_title': 'Fahrzeug-Mangel melden',
  'dialog_subtitle': 'Für Mängel und Verschleiß. Unfälle bitte über das '
      'Unfallformular melden.',
  'field_vehicle': 'Fahrzeug',
  'search_hint': 'Kennzeichen suchen',
  'no_match': 'Kein Fahrzeug passt zur Suche.',
  'fleet_empty_hint': 'Kennzeichen',
  'field_description': 'Was ist defekt?',
  'description_hint': 'z. B. Reifen hinten links verliert Luft, Schiebetür '
      'klemmt …',
  'err_vehicle': 'Bitte ein Fahrzeug auswählen.',
  'err_description': 'Bitte den Mangel beschreiben.',
  'cancel': 'Abbrechen',
  'submit': 'Meldung senden',
  'sending': 'Wird gesendet …',
  'snack_ok': 'Danke — deine Meldung zu {plate} wurde gesendet.',
  'snack_err': 'Meldung konnte nicht gesendet werden: {error}',
};

const Map<String, String> _sq = <String, String>{
  'card_title': 'Raporto një defekt të automjetit',
  'card_subtitle': 'Zgjidh automjetin, përshkruaj problemin — zyra e sheh '
      'menjëherë.',
  'dialog_title': 'Raporto një defekt të automjetit',
  'dialog_subtitle': 'Për defekte dhe konsumim. Për aksidente përdor '
      'formularin e aksidentit.',
  'field_vehicle': 'Automjeti',
  'search_hint': 'Kërko targën',
  'no_match': 'Asnjë automjet nuk përputhet me kërkimin.',
  'fleet_empty_hint': 'Targa',
  'field_description': 'Çfarë nuk shkon?',
  'description_hint': 'p.sh. goma e pasme majtas humb ajër, dera rrëshqitëse '
      'bllokohet …',
  'err_vehicle': 'Të lutem zgjidh një automjet.',
  'err_description': 'Të lutem përshkruaj defektin.',
  'cancel': 'Anulo',
  'submit': 'Dërgo raportin',
  'sending': 'Po dërgohet …',
  'snack_ok': 'Faleminderit — raporti yt për {plate} u dërgua.',
  'snack_err': 'Raporti nuk mund të dërgohej: {error}',
};

const Map<String, String> _hu = <String, String>{
  'card_title': 'Járműhiba bejelentése',
  'card_subtitle': 'Válaszd ki a járművet, írd le a hibát — az iroda azonnal '
      'látja.',
  'dialog_title': 'Járműhiba bejelentése',
  'dialog_subtitle': 'Hibákhoz és kopáshoz. Baleset esetén használd a baleseti '
      'űrlapot.',
  'field_vehicle': 'Jármű',
  'search_hint': 'Rendszám keresése',
  'no_match': 'Nincs a keresésnek megfelelő jármű.',
  'fleet_empty_hint': 'Rendszám',
  'field_description': 'Mi a hiba?',
  'description_hint': 'pl. bal hátsó gumi ereszt, a tolóajtó szorul …',
  'err_vehicle': 'Kérlek válassz járművet.',
  'err_description': 'Kérlek írd le a hibát.',
  'cancel': 'Mégse',
  'submit': 'Bejelentés küldése',
  'sending': 'Küldés …',
  'snack_ok': 'Köszönjük — a(z) {plate} bejelentésed elküldtük.',
  'snack_err': 'A bejelentést nem sikerült elküldeni: {error}',
};

const Map<String, String> _ro = <String, String>{
  'card_title': 'Raportează o defecțiune',
  'card_subtitle': 'Alege vehiculul, descrie problema — biroul o vede imediat.',
  'dialog_title': 'Raportează o defecțiune',
  'dialog_subtitle': 'Pentru defecțiuni și uzură. Pentru accidente folosește '
      'formularul de accident.',
  'field_vehicle': 'Vehicul',
  'search_hint': 'Caută numărul de înmatriculare',
  'no_match': 'Niciun vehicul nu corespunde căutării.',
  'fleet_empty_hint': 'Număr de înmatriculare',
  'field_description': 'Ce nu funcționează?',
  'description_hint': 'ex. anvelopa spate stânga pierde aer, ușa culisantă se '
      'blochează …',
  'err_vehicle': 'Te rugăm să alegi un vehicul.',
  'err_description': 'Te rugăm să descrii defecțiunea.',
  'cancel': 'Anulează',
  'submit': 'Trimite raportul',
  'sending': 'Se trimite …',
  'snack_ok': 'Mulțumim — raportul tău pentru {plate} a fost trimis.',
  'snack_err': 'Raportul nu a putut fi trimis: {error}',
};

const Map<String, String> _hr = <String, String>{
  'card_title': 'Prijavi kvar na vozilu',
  'card_subtitle': 'Odaberi vozilo, opiši problem — ured to odmah vidi.',
  'dialog_title': 'Prijavi kvar na vozilu',
  'dialog_subtitle': 'Za kvarove i istrošenost. Za nesreće koristi obrazac za '
      'nesreću.',
  'field_vehicle': 'Vozilo',
  'search_hint': 'Traži registarsku oznaku',
  'no_match': 'Nijedno vozilo ne odgovara pretrazi.',
  'fleet_empty_hint': 'Registarska oznaka',
  'field_description': 'Što ne radi?',
  'description_hint': 'npr. stražnja lijeva guma gubi zrak, klizna vrata '
      'zapinju …',
  'err_vehicle': 'Molimo odaberi vozilo.',
  'err_description': 'Molimo opiši kvar.',
  'cancel': 'Odustani',
  'submit': 'Pošalji prijavu',
  'sending': 'Šalje se …',
  'snack_ok': 'Hvala — tvoja prijava za {plate} je poslana.',
  'snack_err': 'Prijavu nije bilo moguće poslati: {error}',
};

const Map<String, String> _ar = <String, String>{
  'card_title': 'الإبلاغ عن عطل في المركبة',
  'card_subtitle': 'اختر المركبة وصف المشكلة — سيراها المكتب فوراً.',
  'dialog_title': 'الإبلاغ عن عطل في المركبة',
  'dialog_subtitle': 'للأعطال والتآكل. للحوادث استخدم نموذج الحادث.',
  'field_vehicle': 'المركبة',
  'search_hint': 'ابحث عن رقم اللوحة',
  'no_match': 'لا توجد مركبة تطابق البحث.',
  'fleet_empty_hint': 'رقم اللوحة',
  'field_description': 'ما هو العطل؟',
  'description_hint': 'مثال: الإطار الخلفي الأيسر يفقد الهواء، الباب المنزلق '
      'عالق …',
  'err_vehicle': 'يرجى اختيار مركبة.',
  'err_description': 'يرجى وصف العطل.',
  'cancel': 'إلغاء',
  'submit': 'إرسال البلاغ',
  'sending': 'جارٍ الإرسال …',
  'snack_ok': 'شكراً — تم إرسال بلاغك بخصوص {plate}.',
  'snack_err': 'تعذر إرسال البلاغ: {error}',
};

const Map<String, String> _tr = <String, String>{
  'card_title': 'Araç arızası bildir',
  'card_subtitle': 'Aracı seç, sorunu anlat — ofis anında görür.',
  'dialog_title': 'Araç arızası bildir',
  'dialog_subtitle': 'Arıza ve aşınma için. Kazalar için kaza formunu kullan.',
  'field_vehicle': 'Araç',
  'search_hint': 'Plaka ara',
  'no_match': 'Aramayla eşleşen araç yok.',
  'fleet_empty_hint': 'Plaka',
  'field_description': 'Sorun nedir?',
  'description_hint': 'ör. sol arka lastik hava kaçırıyor, sürgülü kapı '
      'sıkışıyor …',
  'err_vehicle': 'Lütfen bir araç seç.',
  'err_description': 'Lütfen arızayı anlat.',
  'cancel': 'Vazgeç',
  'submit': 'Bildirimi gönder',
  'sending': 'Gönderiliyor …',
  'snack_ok': 'Teşekkürler — {plate} için bildirimin gönderildi.',
  'snack_err': 'Bildirim gönderilemedi: {error}',
};

const Map<String, String> _ru = <String, String>{
  'card_title': 'Сообщить о неисправности',
  'card_subtitle': 'Выберите автомобиль и опишите проблему — офис увидит её '
      'сразу.',
  'dialog_title': 'Сообщить о неисправности',
  'dialog_subtitle': 'Для неисправностей и износа. Для ДТП используйте форму '
      'аварии.',
  'field_vehicle': 'Автомобиль',
  'search_hint': 'Поиск по номеру',
  'no_match': 'Ни один автомобиль не найден.',
  'fleet_empty_hint': 'Гос. номер',
  'field_description': 'Что не работает?',
  'description_hint': 'напр. заднее левое колесо спускает, сдвижная дверь '
      'заедает …',
  'err_vehicle': 'Пожалуйста, выберите автомобиль.',
  'err_description': 'Пожалуйста, опишите неисправность.',
  'cancel': 'Отмена',
  'submit': 'Отправить',
  'sending': 'Отправка …',
  'snack_ok': 'Спасибо — сообщение по {plate} отправлено.',
  'snack_err': 'Не удалось отправить сообщение: {error}',
};

const Map<String, String> _bg = <String, String>{
  'card_title': 'Сигнал за повреда на автомобил',
  'card_subtitle': 'Избери автомобил и опиши проблема — офисът го вижда '
      'веднага.',
  'dialog_title': 'Сигнал за повреда на автомобил',
  'dialog_subtitle': 'За повреди и износване. При катастрофа използвай '
      'формуляра за произшествие.',
  'field_vehicle': 'Автомобил',
  'search_hint': 'Търси регистрационен номер',
  'no_match': 'Няма автомобил, отговарящ на търсенето.',
  'fleet_empty_hint': 'Регистрационен номер',
  'field_description': 'Какво не работи?',
  'description_hint': 'напр. задната лява гума изпуска, плъзгащата врата '
      'заяжда …',
  'err_vehicle': 'Моля, избери автомобил.',
  'err_description': 'Моля, опиши повредата.',
  'cancel': 'Отказ',
  'submit': 'Изпрати сигнала',
  'sending': 'Изпраща се …',
  'snack_ok': 'Благодарим — сигналът ти за {plate} е изпратен.',
  'snack_err': 'Сигналът не можа да бъде изпратен: {error}',
};

const Map<String, String> _es = <String, String>{
  'card_title': 'Informar de una avería',
  'card_subtitle': 'Elige el vehículo y describe el problema — la oficina lo '
      've al instante.',
  'dialog_title': 'Informar de una avería',
  'dialog_subtitle': 'Para averías y desgaste. Para accidentes usa el '
      'formulario de accidente.',
  'field_vehicle': 'Vehículo',
  'search_hint': 'Buscar matrícula',
  'no_match': 'Ningún vehículo coincide con la búsqueda.',
  'fleet_empty_hint': 'Matrícula',
  'field_description': '¿Qué falla?',
  'description_hint': 'p. ej. la rueda trasera izquierda pierde aire, la '
      'puerta corredera se atasca …',
  'err_vehicle': 'Por favor, elige un vehículo.',
  'err_description': 'Por favor, describe la avería.',
  'cancel': 'Cancelar',
  'submit': 'Enviar informe',
  'sending': 'Enviando …',
  'snack_ok': 'Gracias — tu informe de {plate} se ha enviado.',
  'snack_err': 'No se ha podido enviar el informe: {error}',
};
