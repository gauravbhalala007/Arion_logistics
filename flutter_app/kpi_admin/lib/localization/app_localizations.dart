// lib/localization/app_localizations.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Global locale controller used by the whole app.
/// main.dart listens to this and rebuilds MaterialApp when locale changes.
class LocaleController extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale? locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }
}

/// Single global instance
final localeController = LocaleController();

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const supportedLocales = <Locale>[
    Locale('en'), // English
    Locale('de'), // German
    Locale('sq'), // Albanian
    Locale('hu'), // Hungarian
    Locale('ro'), // Romanian
    Locale('hr'), // Croatian
    Locale('ar'), // Arabic
  ];

  // ---- Simple key/value translation table ----
  static const Map<String, Map<String, String>> _localizedValues = {
    // =========================
    // ENGLISH
    // =========================
    'en': {
      // common
      'back': 'Back',
      'continue': 'Continue',
      'button_save': 'Save',
      'required': 'required',
      'error_required': '{field} is required',
      'error_required_short': 'This field is required',
      'uploading': 'Uploading...',
      'upload': 'Upload',
      'replace': 'Replace',

      // generic / auth
      'error_must_be_logged_in_driver': 'You must be logged in as a driver.',
      'coming_soon': 'Coming soon',

      // header / home shell
      'header_good_morning': 'GOOD MORNING',
      'select_language': 'Select language',
      'notifications': 'Notifications',
      'no_notifications': 'No notifications',
      'change_profile_photo': 'Change profile photo',
      'logout': 'Logout',
      'profile_photo_updated': 'Profile photo updated.',
      'failed_upload_profile_photo': 'Failed to upload profile photo: {error}',
      'could_not_read_image_bytes':
          'Could not read image bytes from file picker.',

      // welcome
      'hi_name': 'Hi {name}, 👋',
      'welcome_to_company': 'welcome to {company}',
      'welcome_desc': 'We’re happy to have you on board. Let’s get started!',
      'codriver': 'CODRIVER',

      // step 1
      'your_address': 'YOUR ADDRESS',
      'your_origin': 'YOUR ORIGIN',
      'uniform': 'UNIFORM',
      'hint_street_house': 'Street, Housenumber',
      'hint_postal_code': 'Postal Code',
      'hint_city': 'City',
      'hint_country': 'Country',
      'hint_birthday': 'Your Birthday',
      'hint_birth_city': 'City of Birth',
      'hint_birth_state': 'State of Birth',
      'hint_nationality': 'Nationality (ID CARD) (Country name)',
      'label_cloth_size': 'choose your cloth size',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'choose your shoe size',
      'hint_shoe_size': 'e.g. 42',
      'label_notes': 'other wishes / notes',

      // step 2
      'work_permit': 'WORK PERMIT',
      'work_permit_question':
          'which kind of work permit do you have to work in Germany',
      'permit_german_id': 'German ID Card',
      'permit_eu_id': 'EU ID Card',
      'permit_work_visa': 'WORK VISA for Germany',

      // step 3
      'your_work_permit': 'YOUR WORK PERMIT',
      'please_upload_doc': 'please upload your document',
      'upload_quality_hint':
          'Make sure the photo is fully visible, high-quality, and taken from a top-down angle',
      'upload_your_file': 'upload your file',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF format up to 50 mb',
      'hint_select_expiry': 'select expiry date',

      // step 4
      'id_passport_title': 'ID Card, Passport',
      'id_card': 'ID CARD',
      'passport': 'PASSPORT',
      'or': 'OR',

      // step 5
      'your_passport': 'YOUR PASSPORT',
      'your_id_card': 'YOUR ID CARD',
      'frontside': 'FRONTSIDE',
      'backside': 'BACKSIDE',

      // step 6
      'your_drivers_license': 'YOUR DRIVERS LICENSE',
      'upload_file_front': 'upload your file (front)',
      'upload_file_back': 'upload your file (back)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (not PDF)',
      'tax_document': 'TAX DOCUMENT',
      'please_upload_tax_id': 'please upload your tax ID document',
      'upload_tax_id': 'upload tax ID',
      'file_formats_tax': 'PDF, JPG, PNG… up to 50 MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'License expiry date',
      'hint_license_expiry': 'Select expiry date',

      // preview
      'label_uploaded_docs': 'Uploaded documents',
      'no_docs': 'No documents uploaded yet.',

      // doc types
      'doc_resident_permit': 'Work permit / residence permit',
      'doc_tax_id': 'Tax ID document',
      'doc_insurance': 'Insurance',
      'doc_other_doc': 'Other document',

      'driver_license_front': 'Driver license (front)',
      'driver_license_back': 'Driver license (back)',
      'id_card_front': 'ID card (front)',
      'id_card_back': 'ID card (back)',
      'passport_front': 'Passport (front)',
      'passport_back': 'Passport (back)',

      // ---------------- DASHBOARD ----------------
      'dash_error_loading_reports': 'Error loading reports: {error}',
      'dash_no_reports_uploaded':
          'Your DSP has not uploaded any scorecard reports yet.',
      'dash_scorecard_week': 'SCORECARD WEEK {week}',
      'dash_week_range': 'Week {week}, {year}',
      'dash_no_scores_period': 'No scores for this period yet.',
      'dash_no_drivers_match': 'No drivers match this filter.',
      'dash_no_name': '(No Name)',

      'dash_company_score': 'Company Score',
      'dash_my_score': 'My Score',

      'dash_select_period': 'Select period',
      'dash_weekly_view': 'Weekly view',
      'dash_best_da_month': 'Best DA of the Month',
      'dash_best_da_year': 'Best DA of the Year',

      'dash_week': 'Week',
      'dash_total_score': 'Total Score',
      'dash_rank_in_station': 'Rank in station',
      'dash_status': 'Status',

      'dash_rank': 'Rank',
      'dash_score': 'Score',
      'dash_name': 'Name',

      'dash_delivered': 'Delivered',
      'dash_rank_in_aion': 'Rank in AION',
      'dash_rank_of_total': '{rank} of {total}',

      'dash_no_my_score_week': 'No score found for your driver ID in this week.',

      // KPI tiles
      'kpi_score': 'SCORE',
      'kpi_value': 'VALUE',
      'kpi_pro_tip': 'PRO TIP',

      'kpi_title_dcr': 'Delivery Completion Rate',
      'kpi_title_dnr': 'Delivery Not Received',
      'kpi_title_lor': 'Loss on Route',
      'kpi_title_pod': 'Proof of Delivery',
      'kpi_title_cc': 'Customer Contact',
      'kpi_title_ce': 'Customer Experience',
      'kpi_title_cdf': 'Customer Delivery Failures',

      'kpi_desc_dcr':
          'Delivery Completion Rate (DCR) measures how many planned stops were successfully completed.',
      'kpi_tip_dcr':
          'Maintain a consistent pace throughout the route and avoid unnecessary detours.',
      'kpi_desc_dnr':
          'Delivery Not Received (DNR) counts failed deliveries where the package could not be handed over.',
      'kpi_tip_dnr':
          'Double-check addresses and use customer contact options to reduce failed deliveries.',
      'kpi_desc_lor':
          'Loss on Route (LoR) tracks lost or damaged packages during the route.',
      'kpi_tip_lor':
          'Handle packages carefully and organise the van so that parcels do not get damaged.',
      'kpi_desc_pod':
          'Proof of Delivery (POD) measures correct scan and delivery confirmations.',
      'kpi_tip_pod':
          'Always scan the package at the door and ensure the correct drop location.',
      'kpi_desc_cc':
          'Customer Contact (CC) checks if the driver follows the interaction steps when needed.',
      'kpi_tip_cc':
          'Send messages or call customers when necessary to avoid missed deliveries.',
      'kpi_desc_ce':
          'Customer Experience (CE) represents how satisfied customers are with your deliveries.',
      'kpi_tip_ce':
          'Be friendly, punctual and careful with parcels to improve customer feedback.',
      'kpi_desc_cdf':
          'Customer Delivery Failures (CDF) tracks serious delivery issues.',
      'kpi_tip_cdf':
          'Analyse failed deliveries and learn from patterns to avoid repeating mistakes.',

      // Month names (long)
      'month_jan': 'January',
      'month_feb': 'February',
      'month_mar': 'March',
      'month_apr': 'April',
      'month_may': 'May',
      'month_jun': 'June',
      'month_jul': 'July',
      'month_aug': 'August',
      'month_sep': 'September',
      'month_oct': 'October',
      'month_nov': 'November',
      'month_dec': 'December',

      // Month names (short)
      'month_short_jan': 'Jan',
      'month_short_feb': 'Feb',
      'month_short_mar': 'Mar',
      'month_short_apr': 'Apr',
      'month_short_may': 'May',
      'month_short_jun': 'Jun',
      'month_short_jul': 'Jul',
      'month_short_aug': 'Aug',
      'month_short_sep': 'Sep',
      'month_short_oct': 'Oct',
      'month_short_nov': 'Nov',
      'month_short_dec': 'Dec',

      // NEW dashboard/status keys
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      'bucket_fantastic_plus': 'Fantastic Plus',
      'bucket_fantastic': 'Fantastic',
      'bucket_great': 'Great',
      'bucket_fair': 'Fair',
      'bucket_poor': 'Poor',

      'rank_at': 'at',
      'rank_of': 'of',

      'period_month': 'Month',
      'kw': 'KW',
    },

    // =========================
    // GERMAN
    // =========================
    'de': {
      'back': 'Zurück',
      'continue': 'Weiter',
      'button_save': 'Speichern',
      'required': 'pflicht',
      'error_required': '{field} ist erforderlich',
      'error_required_short': 'Dieses Feld ist erforderlich',
      'uploading': 'Wird hochgeladen...',
      'upload': 'Hochladen',
      'replace': 'Ersetzen',

      'error_must_be_logged_in_driver': 'Du musst als Fahrer eingeloggt sein.',
      'coming_soon': 'Kommt bald',

      'header_good_morning': 'GUTEN MORGEN',
      'select_language': 'Sprache auswählen',
      'notifications': 'Benachrichtigungen',
      'no_notifications': 'Keine Benachrichtigungen',
      'change_profile_photo': 'Profilfoto ändern',
      'logout': 'Abmelden',
      'profile_photo_updated': 'Profilfoto aktualisiert.',
      'failed_upload_profile_photo':
          'Profilfoto konnte nicht hochgeladen werden: {error}',
      'could_not_read_image_bytes':
          'Bilddaten konnten nicht aus der Datei gelesen werden.',

      'hi_name': 'Hallo {name}, 👋',
      'welcome_to_company': 'willkommen bei {company}',
      'welcome_desc': 'Schön, dass du dabei bist. Lass uns starten!',
      'codriver': 'CODRIVER',

      'your_address': 'DEINE ADRESSE',
      'your_origin': 'DEINE HERKUNFT',
      'uniform': 'UNIFORM',
      'hint_street_house': 'Straße, Hausnummer',
      'hint_postal_code': 'PLZ',
      'hint_city': 'Stadt',
      'hint_country': 'Land',
      'hint_birthday': 'Geburtsdatum',
      'hint_birth_city': 'Geburtsort',
      'hint_birth_state': 'Bundesland (Geburt)',
      'hint_nationality': 'Nationalität (ID-KARTE) (Land)',
      'label_cloth_size': 'Kleidergröße wählen',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'Schuhgröße wählen',
      'hint_shoe_size': 'z.B. 42',
      'label_notes': 'Sonstige Wünsche / Notizen',

      'work_permit': 'ARBEITSERLAUBNIS',
      'work_permit_question':
          'Welche Arbeitserlaubnis hast du, um in Deutschland zu arbeiten?',
      'permit_german_id': 'Deutscher Personalausweis',
      'permit_eu_id': 'EU-Ausweis',
      'permit_work_visa': 'ARBEITSVISUM für Deutschland',

      'your_work_permit': 'DEINE ARBEITSERLAUBNIS',
      'please_upload_doc': 'Bitte lade dein Dokument hoch',
      'upload_quality_hint':
          'Achte darauf, dass das Foto vollständig sichtbar, hochwertig und von oben aufgenommen ist',
      'upload_your_file': 'Datei hochladen',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF bis 50 MB',
      'hint_select_expiry': 'Ablaufdatum wählen',

      'id_passport_title': 'Ausweis, Reisepass',
      'id_card': 'AUSWEIS',
      'passport': 'REISEPASS',
      'or': 'ODER',

      'your_passport': 'DEIN REISEPASS',
      'your_id_card': 'DEIN AUSWEIS',
      'frontside': 'VORDERSEITE',
      'backside': 'RÜCKSEITE',

      'your_drivers_license': 'DEIN FÜHRERSCHEIN',
      'upload_file_front': 'Datei hochladen (Vorderseite)',
      'upload_file_back': 'Datei hochladen (Rückseite)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (kein PDF)',
      'tax_document': 'STEUERDOKUMENT',
      'please_upload_tax_id': 'Bitte lade dein Steuer-ID Dokument hoch',
      'upload_tax_id': 'Steuer-ID hochladen',
      'file_formats_tax': 'PDF, JPG, PNG… bis 50 MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'Führerschein Ablaufdatum',
      'hint_license_expiry': 'Ablaufdatum wählen',

      'label_uploaded_docs': 'Hochgeladene Dokumente',
      'no_docs': 'Noch keine Dokumente hochgeladen.',

      'doc_resident_permit': 'Arbeitserlaubnis / Aufenthaltstitel',
      'doc_tax_id': 'Steuer-ID Dokument',
      'doc_insurance': 'Versicherung',
      'doc_other_doc': 'Anderes Dokument',

      'driver_license_front': 'Führerschein (Vorderseite)',
      'driver_license_back': 'Führerschein (Rückseite)',
      'id_card_front': 'Ausweis (Vorderseite)',
      'id_card_back': 'Ausweis (Rückseite)',
      'passport_front': 'Reisepass (Vorderseite)',
      'passport_back': 'Reisepass (Rückseite)',

      'dash_error_loading_reports': 'Fehler beim Laden der Reports: {error}',
      'dash_no_reports_uploaded':
          'Dein DSP hat noch keine Scorecard-Reports hochgeladen.',
      'dash_scorecard_week': 'SCORECARD WOCHE {week}',
      'dash_week_range': 'Woche {week}, {year}',
      'dash_no_scores_period': 'Noch keine Scores für diesen Zeitraum.',
      'dash_no_drivers_match': 'Keine Fahrer passen zu diesem Filter.',
      'dash_no_name': '(Kein Name)',

      'dash_company_score': 'Unternehmens-Score',
      'dash_my_score': 'Mein Score',

      'dash_select_period': 'Zeitraum auswählen',
      'dash_weekly_view': 'Wochenansicht',
      'dash_best_da_month': 'Beste DA im Monat',
      'dash_best_da_year': 'Beste DA im Jahr',

      'dash_week': 'Woche',
      'dash_total_score': 'Gesamt-Score',
      'dash_rank_in_station': 'Rang in Station',
      'dash_status': 'Status',

      'dash_rank': 'Rang',
      'dash_score': 'Score',
      'dash_name': 'Name',

      'dash_delivered': 'Zugestellt',
      'dash_rank_in_aion': 'Rang in AION',
      'dash_rank_of_total': '{rank} von {total}',

      'dash_no_my_score_week':
          'Kein Score für deine Fahrer-ID in dieser Woche gefunden.',

      'kpi_score': 'SCORE',
      'kpi_value': 'WERT',
      'kpi_pro_tip': 'PRO TIPP',

      'kpi_title_dcr': 'Zustellabschlussrate',
      'kpi_title_dnr': 'Nicht erhalten',
      'kpi_title_lor': 'Verlust auf Route',
      'kpi_title_pod': 'Zustellnachweis',
      'kpi_title_cc': 'Kundenkontakt',
      'kpi_title_ce': 'Kundenerlebnis',
      'kpi_title_cdf': 'Zustellfehler',

      'kpi_desc_dcr':
          'DCR misst, wie viele geplante Stopps erfolgreich abgeschlossen wurden.',
      'kpi_tip_dcr':
          'Halte ein konstantes Tempo und vermeide unnötige Umwege.',
      'kpi_desc_dnr':
          'DNR zählt fehlgeschlagene Zustellungen, bei denen das Paket nicht übergeben werden konnte.',
      'kpi_tip_dnr':
          'Prüfe Adressen sorgfältig und nutze Kundenkontakt, um Fehlschläge zu reduzieren.',
      'kpi_desc_lor':
          'LoR verfolgt verlorene oder beschädigte Pakete während der Route.',
      'kpi_tip_lor':
          'Behandle Pakete vorsichtig und organisiere den Van, damit nichts beschädigt wird.',
      'kpi_desc_pod':
          'POD misst korrekte Scans und Zustellbestätigungen.',
      'kpi_tip_pod':
          'Scanne immer an der Tür und wähle den korrekten Ablageort.',
      'kpi_desc_cc':
          'CC prüft, ob der Fahrer die Kontakt-Schritte bei Bedarf einhält.',
      'kpi_tip_cc':
          'Rufe Kunden an oder sende Nachrichten, um verpasste Zustellungen zu vermeiden.',
      'kpi_desc_ce':
          'CE zeigt, wie zufrieden Kunden mit deinen Zustellungen sind.',
      'kpi_tip_ce':
          'Sei freundlich, pünktlich und sorgfältig mit Paketen.',
      'kpi_desc_cdf':
          'CDF verfolgt schwerwiegende Zustellprobleme.',
      'kpi_tip_cdf':
          'Analysiere Fehlschläge und vermeide wiederkehrende Muster.',

      'month_jan': 'Januar',
      'month_feb': 'Februar',
      'month_mar': 'März',
      'month_apr': 'April',
      'month_may': 'Mai',
      'month_jun': 'Juni',
      'month_jul': 'Juli',
      'month_aug': 'August',
      'month_sep': 'September',
      'month_oct': 'Oktober',
      'month_nov': 'November',
      'month_dec': 'Dezember',

      'month_short_jan': 'Jan',
      'month_short_feb': 'Feb',
      'month_short_mar': 'Mär',
      'month_short_apr': 'Apr',
      'month_short_may': 'Mai',
      'month_short_jun': 'Jun',
      'month_short_jul': 'Jul',
      'month_short_aug': 'Aug',
      'month_short_sep': 'Sep',
      'month_short_oct': 'Okt',
      'month_short_nov': 'Nov',
      'month_short_dec': 'Dez',

      // NEW dashboard/status keys
      'status_fantastic': 'Fantastisch',
      'status_great': 'Sehr gut',
      'status_fair': 'Okay',
      'status_poor': 'Schlecht',

      'bucket_fantastic_plus': 'Fantastisch Plus',
      'bucket_fantastic': 'Fantastisch',
      'bucket_great': 'Sehr gut',
      'bucket_fair': 'Okay',
      'bucket_poor': 'Schlecht',

      'rank_at': 'in',
      'rank_of': 'von',

      'period_month': 'Monat',
      'kw': 'KW',
    },

    // =========================
    // ALBANIAN (sq)
    // =========================
    'sq': {
      'back': 'Mbrapa',
      'continue': 'Vazhdo',
      'button_save': 'Ruaj',
      'required': 'detyrueshme',
      'error_required': '{field} është e detyrueshme',
      'error_required_short': 'Kjo fushë është e detyrueshme',
      'uploading': 'Duke u ngarkuar...',
      'upload': 'Ngarko',
      'replace': 'Zëvendëso',

      'error_must_be_logged_in_driver': 'Duhet të jesh i kyçur si shofer.',
      'coming_soon': 'Së shpejti',

      'header_good_morning': 'MIRËMËNGJES',
      'select_language': 'Zgjidh gjuhën',
      'notifications': 'Njoftime',
      'no_notifications': 'Nuk ka njoftime',
      'change_profile_photo': 'Ndrysho foton e profilit',
      'logout': 'Dil',
      'profile_photo_updated': 'Fotoja e profilit u përditësua.',
      'failed_upload_profile_photo': 'Dështoi ngarkimi i fotos së profilit: {error}',
      'could_not_read_image_bytes': 'Nuk u lexuan të dhënat e imazhit nga përzgjedhësi i skedarëve.',

      'hi_name': 'Përshëndetje {name}, 👋',
      'welcome_to_company': 'mirë se erdhe në {company}',
      'welcome_desc': 'Jemi të lumtur që je me ne. Le të fillojmë!',
      'codriver': 'CODRIVER',

      'your_address': 'ADRESA JOTE',
      'your_origin': 'ORIGJINA JOTE',
      'uniform': 'UNIFORMA',
      'hint_street_house': 'Rruga, Numri i shtëpisë',
      'hint_postal_code': 'Kodi postar',
      'hint_city': 'Qyteti',
      'hint_country': 'Shteti',
      'hint_birthday': 'Ditëlindja',
      'hint_birth_city': 'Qyteti i lindjes',
      'hint_birth_state': 'Rajoni/Shteti i lindjes',
      'hint_nationality': 'Shtetësia (KARTË ID) (Emri i vendit)',
      'label_cloth_size': 'zgjidh madhësinë e rrobave',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'zgjidh madhësinë e këpucëve',
      'hint_shoe_size': 'p.sh. 42',
      'label_notes': 'dëshira / shënime të tjera',

      'work_permit': 'LEJA E PUNËS',
      'work_permit_question':
          'çfarë lloj leje pune ke për të punuar në Gjermani',
      'permit_german_id': 'Kartë ID Gjermane',
      'permit_eu_id': 'Kartë ID e BE-së',
      'permit_work_visa': 'VIZË PUNE për Gjermani',

      'your_work_permit': 'LEJA JOTE E PUNËS',
      'please_upload_doc': 'ju lutem ngarkoni dokumentin tuaj',
      'upload_quality_hint':
          'Sigurohu që fotoja të jetë e dukshme plotësisht, me cilësi të lartë dhe e marrë nga lart',
      'upload_your_file': 'ngarko skedarin',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF deri në 50 MB',
      'hint_select_expiry': 'zgjidh datën e skadimit',

      'id_passport_title': 'Kartë ID, Pasaportë',
      'id_card': 'KARTË ID',
      'passport': 'PASAPORTË',
      'or': 'OSE',

      'your_passport': 'PASAPORTA JOTE',
      'your_id_card': 'KARTA JOTE ID',
      'frontside': 'PARA',
      'backside': 'PRAPA',

      'your_drivers_license': 'PATENTA JOTE',
      'upload_file_front': 'ngarko skedarin (para)',
      'upload_file_back': 'ngarko skedarin (prapa)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (jo PDF)',
      'tax_document': 'DOKUMENT TATIMOR',
      'please_upload_tax_id': 'ju lutem ngarkoni dokumentin e ID-së së taksave',
      'upload_tax_id': 'ngarko ID taksash',
      'file_formats_tax': 'PDF, JPG, PNG… deri në 50 MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'Skadimi i patentës',
      'hint_license_expiry': 'Zgjidh datën e skadimit',

      'label_uploaded_docs': 'Dokumente të ngarkuara',
      'no_docs': 'Nuk ka dokumente të ngarkuara ende.',

      'doc_resident_permit': 'Leje pune / leje qëndrimi',
      'doc_tax_id': 'Dokument i ID taksash',
      'doc_insurance': 'Sigurim',
      'doc_other_doc': 'Dokument tjetër',

      'driver_license_front': 'Patentë (para)',
      'driver_license_back': 'Patentë (prapa)',
      'id_card_front': 'Kartë ID (para)',
      'id_card_back': 'Kartë ID (prapa)',
      'passport_front': 'Pasaportë (para)',
      'passport_back': 'Pasaportë (prapa)',

      'dash_error_loading_reports': 'Gabim gjatë ngarkimit të raporteve: {error}',
      'dash_no_reports_uploaded': 'DSP-ja juaj nuk ka ngarkuar ende raporte scorecard.',
      'dash_scorecard_week': 'JAVA SCORECARD {week}',
      'dash_week_range': 'Java {week}, {year}',
      'dash_no_scores_period': 'Nuk ka rezultate për këtë periudhë ende.',
      'dash_no_drivers_match': 'Asnjë shofer nuk përputhet me këtë filtër.',
      'dash_no_name': '(Pa emër)',

      'dash_company_score': 'Rezultati i kompanisë',
      'dash_my_score': 'Rezultati im',

      'dash_select_period': 'Zgjidh periudhën',
      'dash_weekly_view': 'Pamje javore',
      'dash_best_da_month': 'DA më e mirë e muajit',
      'dash_best_da_year': 'DA më e mirë e vitit',

      'dash_week': 'Java',
      'dash_total_score': 'Rezultati total',
      'dash_rank_in_station': 'Renditja në stacion',
      'dash_status': 'Statusi',

      'dash_rank': 'Renditja',
      'dash_score': 'Rezultati',
      'dash_name': 'Emri',

      'dash_delivered': 'Dërguara',
      'dash_rank_in_aion': 'Renditja në AION',
      'dash_rank_of_total': '{rank} nga {total}',

      'dash_no_my_score_week': 'Nuk u gjet rezultat për ID-në tuaj të shoferit në këtë javë.',

      'kpi_score': 'REZULTATI',
      'kpi_value': 'VLERA',
      'kpi_pro_tip': 'KËSHILLË',

      'kpi_title_dcr': 'Norma e përfundimit të dorëzimeve',
      'kpi_title_dnr': 'Dorëzim i parealizuar (nuk u mor)',
      'kpi_title_lor': 'Humbje gjatë rrugës',
      'kpi_title_pod': 'Provë e dorëzimit',
      'kpi_title_cc': 'Kontakt me klientin',
      'kpi_title_ce': 'Përvoja e klientit',
      'kpi_title_cdf': 'Dështime të dorëzimit te klienti',

      'kpi_desc_dcr':
          'DCR mat sa ndalesa të planifikuara u përfunduan me sukses.',
      'kpi_tip_dcr':
          'Mbaj një ritëm të qëndrueshëm dhe shmang devijimet e panevojshme.',
      'kpi_desc_dnr':
          'DNR numëron dorëzimet e dështuara ku paketa nuk u dorëzua.',
      'kpi_tip_dnr':
          'Kontrollo adresat dhe përdor kontaktin me klientin për të ulur dështimet.',
      'kpi_desc_lor':
          'LoR ndjek paketat e humbura ose të dëmtuara gjatë rrugës.',
      'kpi_tip_lor':
          'Trajto paketat me kujdes dhe organizo furgonin që të mos dëmtohen.',
      'kpi_desc_pod':
          'POD mat skanimet e sakta dhe konfirmimet e dorëzimit.',
      'kpi_tip_pod':
          'Skanon gjithmonë te dera dhe zgjidh vendin e saktë të lënies.',
      'kpi_desc_cc':
          'CC kontrollon nëse shoferi ndjek hapat e ndërveprimit kur nevojitet.',
      'kpi_tip_cc':
          'Dërgo mesazhe ose telefono klientët kur është e nevojshme.',
      'kpi_desc_ce':
          'CE tregon sa të kënaqur janë klientët me dorëzimet.',
      'kpi_tip_ce':
          'Ji i sjellshëm, i përpiktë dhe i kujdesshëm me paketat.',
      'kpi_desc_cdf':
          'CDF ndjek probleme serioze të dorëzimit.',
      'kpi_tip_cdf':
          'Analizo dështimet dhe mëso nga modelet për të mos i përsëritur.',

      'month_jan': 'Janar',
      'month_feb': 'Shkurt',
      'month_mar': 'Mars',
      'month_apr': 'Prill',
      'month_may': 'Maj',
      'month_jun': 'Qershor',
      'month_jul': 'Korrik',
      'month_aug': 'Gusht',
      'month_sep': 'Shtator',
      'month_oct': 'Tetor',
      'month_nov': 'Nëntor',
      'month_dec': 'Dhjetor',

      'month_short_jan': 'Jan',
      'month_short_feb': 'Shk',
      'month_short_mar': 'Mar',
      'month_short_apr': 'Pri',
      'month_short_may': 'Maj',
      'month_short_jun': 'Qer',
      'month_short_jul': 'Kor',
      'month_short_aug': 'Gus',
      'month_short_sep': 'Sht',
      'month_short_oct': 'Tet',
      'month_short_nov': 'Nën',
      'month_short_dec': 'Dhj',

      'status_fantastic': 'Fantastik',
      'status_great': 'Shumë mirë',
      'status_fair': 'Mesatar',
      'status_poor': 'Dobët',

      'bucket_fantastic_plus': 'Fantastik Plus',
      'bucket_fantastic': 'Fantastik',
      'bucket_great': 'Shumë mirë',
      'bucket_fair': 'Mesatar',
      'bucket_poor': 'Dobët',

      'rank_at': 'në',
      'rank_of': 'nga',

      'period_month': 'Muaji',
      'kw': 'KW',
    },

    // =========================
    // HUNGARIAN (hu)
    // =========================
    'hu': {
      'back': 'Vissza',
      'continue': 'Tovább',
      'button_save': 'Mentés',
      'required': 'kötelező',
      'error_required': '{field} kötelező',
      'error_required_short': 'Ez a mező kötelező',
      'uploading': 'Feltöltés...',
      'upload': 'Feltöltés',
      'replace': 'Csere',

      'error_must_be_logged_in_driver': 'Be kell jelentkezned sofőrként.',
      'coming_soon': 'Hamarosan',

      'header_good_morning': 'JÓ REGGELT',
      'select_language': 'Nyelv kiválasztása',
      'notifications': 'Értesítések',
      'no_notifications': 'Nincs értesítés',
      'change_profile_photo': 'Profilkép módosítása',
      'logout': 'Kijelentkezés',
      'profile_photo_updated': 'Profilkép frissítve.',
      'failed_upload_profile_photo': 'Nem sikerült feltölteni a profilképet: {error}',
      'could_not_read_image_bytes': 'Nem sikerült beolvasni a képadatokat a fájlválasztóból.',

      'hi_name': 'Szia {name}, 👋',
      'welcome_to_company': 'üdvözlünk: {company}',
      'welcome_desc': 'Örülünk, hogy csatlakoztál. Kezdjük el!',
      'codriver': 'CODRIVER',

      'your_address': 'CÍMED',
      'your_origin': 'SZÁRMAZÁSOD',
      'uniform': 'EGYENRUHA',
      'hint_street_house': 'Utca, házszám',
      'hint_postal_code': 'Irányítószám',
      'hint_city': 'Város',
      'hint_country': 'Ország',
      'hint_birthday': 'Születési dátum',
      'hint_birth_city': 'Születési város',
      'hint_birth_state': 'Születési megye/állam',
      'hint_nationality': 'Állampolgárság (SZEMÉLYI) (Ország neve)',
      'label_cloth_size': 'ruhaméret kiválasztása',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'cipőméret kiválasztása',
      'hint_shoe_size': 'pl. 42',
      'label_notes': 'egyéb kívánságok / megjegyzések',

      'work_permit': 'MUNKAVÁLLALÁSI ENGEDÉLY',
      'work_permit_question':
          'milyen munkavállalási engedélyed van Németországban?',
      'permit_german_id': 'Német személyi igazolvány',
      'permit_eu_id': 'EU személyi igazolvány',
      'permit_work_visa': 'MUNKAVÍZUM Németországba',

      'your_work_permit': 'MUNKAVÁLLALÁSI ENGEDÉLYED',
      'please_upload_doc': 'kérjük töltsd fel a dokumentumot',
      'upload_quality_hint':
          'A fotó legyen teljesen látható, jó minőségű és felülről készüljön',
      'upload_your_file': 'fájl feltöltése',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF max. 50 MB',
      'hint_select_expiry': 'lejárati dátum kiválasztása',

      'id_passport_title': 'Személyi, Útlevél',
      'id_card': 'SZEMÉLYI',
      'passport': 'ÚTLEVÉL',
      'or': 'VAGY',

      'your_passport': 'ÚTLEVELED',
      'your_id_card': 'SZEMÉLYID',
      'frontside': 'ELŐLAP',
      'backside': 'HÁTLAP',

      'your_drivers_license': 'VEZETŐI ENGEDÉLYED',
      'upload_file_front': 'fájl feltöltése (elöl)',
      'upload_file_back': 'fájl feltöltése (hátul)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (nem PDF)',
      'tax_document': 'ADÓDOKUMENTUM',
      'please_upload_tax_id': 'kérjük töltsd fel az adóazonosító dokumentumot',
      'upload_tax_id': 'adóazonosító feltöltése',
      'file_formats_tax': 'PDF, JPG, PNG… max. 50 MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'Jogosítvány lejárata',
      'hint_license_expiry': 'Lejárati dátum kiválasztása',

      'label_uploaded_docs': 'Feltöltött dokumentumok',
      'no_docs': 'Még nincs feltöltött dokumentum.',

      'doc_resident_permit': 'Munkavállalási / tartózkodási engedély',
      'doc_tax_id': 'Adóazonosító dokumentum',
      'doc_insurance': 'Biztosítás',
      'doc_other_doc': 'Egyéb dokumentum',

      'driver_license_front': 'Jogosítvány (elöl)',
      'driver_license_back': 'Jogosítvány (hátul)',
      'id_card_front': 'Személyi (elöl)',
      'id_card_back': 'Személyi (hátul)',
      'passport_front': 'Útlevél (elöl)',
      'passport_back': 'Útlevél (hátul)',

      'dash_error_loading_reports': 'Hiba a jelentések betöltésekor: {error}',
      'dash_no_reports_uploaded': 'A DSP még nem töltött fel scorecard jelentéseket.',
      'dash_scorecard_week': 'SCORECARD HÉT {week}',
      'dash_week_range': '{week}. hét, {year}',
      'dash_no_scores_period': 'Erre az időszakra még nincs pontszám.',
      'dash_no_drivers_match': 'Nincs a szűrőnek megfelelő sofőr.',
      'dash_no_name': '(Nincs név)',

      'dash_company_score': 'Cég pontszám',
      'dash_my_score': 'Saját pontszám',

      'dash_select_period': 'Időszak kiválasztása',
      'dash_weekly_view': 'Heti nézet',
      'dash_best_da_month': 'A hónap legjobb DA-ja',
      'dash_best_da_year': 'Az év legjobb DA-ja',

      'dash_week': 'Hét',
      'dash_total_score': 'Összpontszám',
      'dash_rank_in_station': 'Helyezés az állomáson',
      'dash_status': 'Állapot',

      'dash_rank': 'Helyezés',
      'dash_score': 'Pontszám',
      'dash_name': 'Név',

      'dash_delivered': 'Kiszállítva',
      'dash_rank_in_aion': 'Helyezés az AION-ban',
      'dash_rank_of_total': '{rank} / {total}',

      'dash_no_my_score_week': 'Nem található pontszám a sofőr azonosítódhoz ezen a héten.',

      'kpi_score': 'PONTSZÁM',
      'kpi_value': 'ÉRTÉK',
      'kpi_pro_tip': 'TIPP',

      'kpi_title_dcr': 'Kézbesítési teljesítési arány',
      'kpi_title_dnr': 'Kézbesítés sikertelen (nem érkezett meg)',
      'kpi_title_lor': 'Útközbeni veszteség',
      'kpi_title_pod': 'Kézbesítési igazolás',
      'kpi_title_cc': 'Ügyfélkapcsolat',
      'kpi_title_ce': 'Ügyfélélmény',
      'kpi_title_cdf': 'Ügyfélkézbesítési hibák',

      'kpi_desc_dcr':
          'A DCR azt méri, hogy a tervezett megállók közül mennyit teljesítettél sikeresen.',
      'kpi_tip_dcr':
          'Tarts egyenletes tempót az útvonalon és kerüld a felesleges kitérőket.',
      'kpi_desc_dnr':
          'A DNR a sikertelen kézbesítéseket számolja, amikor a csomagot nem lehetett átadni.',
      'kpi_tip_dnr':
          'Ellenőrizd a címeket és használd az ügyfélkapcsolati lehetőségeket.',
      'kpi_desc_lor':
          'A LoR az útközben elveszett vagy megsérült csomagokat követi.',
      'kpi_tip_lor':
          'Bánj óvatosan a csomagokkal és rendezd a furgont, hogy ne sérüljenek.',
      'kpi_desc_pod':
          'A POD a helyes szkennelést és a kézbesítési visszaigazolást méri.',
      'kpi_tip_pod':
          'Mindig az ajtónál szkenneld és válaszd a megfelelő lerakási helyet.',
      'kpi_desc_cc':
          'A CC azt ellenőrzi, hogy szükség esetén követed-e a kapcsolattartási lépéseket.',
      'kpi_tip_cc':
          'Szükség esetén írj üzenetet vagy hívd fel az ügyfelet.',
      'kpi_desc_ce':
          'A CE azt mutatja, mennyire elégedettek az ügyfelek a kézbesítéssel.',
      'kpi_tip_ce':
          'Légy udvarias, pontos és óvatos a csomagokkal.',
      'kpi_desc_cdf':
          'A CDF a súlyos kézbesítési problémákat követi.',
      'kpi_tip_cdf':
          'Elemezd a hibákat és tanulj a mintákból, hogy ne ismétlődjenek.',

      'month_jan': 'Január',
      'month_feb': 'Február',
      'month_mar': 'Március',
      'month_apr': 'Április',
      'month_may': 'Május',
      'month_jun': 'Június',
      'month_jul': 'Július',
      'month_aug': 'Augusztus',
      'month_sep': 'Szeptember',
      'month_oct': 'Október',
      'month_nov': 'November',
      'month_dec': 'December',

      'month_short_jan': 'Jan',
      'month_short_feb': 'Feb',
      'month_short_mar': 'Már',
      'month_short_apr': 'Ápr',
      'month_short_may': 'Máj',
      'month_short_jun': 'Jún',
      'month_short_jul': 'Júl',
      'month_short_aug': 'Aug',
      'month_short_sep': 'Szep',
      'month_short_oct': 'Okt',
      'month_short_nov': 'Nov',
      'month_short_dec': 'Dec',

      'status_fantastic': 'Kiváló',
      'status_great': 'Nagyon jó',
      'status_fair': 'Megfelelő',
      'status_poor': 'Gyenge',

      'bucket_fantastic_plus': 'Kiváló Plusz',
      'bucket_fantastic': 'Kiváló',
      'bucket_great': 'Nagyon jó',
      'bucket_fair': 'Megfelelő',
      'bucket_poor': 'Gyenge',

      'rank_at': 'itt:',
      'rank_of': '/',

      'period_month': 'Hónap',
      'kw': 'KW',
    },

    // =========================
    // ROMANIAN (ro)
    // =========================
    'ro': {
      'back': 'Înapoi',
      'continue': 'Continuă',
      'button_save': 'Salvează',
      'required': 'obligatoriu',
      'error_required': '{field} este obligatoriu',
      'error_required_short': 'Acest câmp este obligatoriu',
      'uploading': 'Se încarcă...',
      'upload': 'Încarcă',
      'replace': 'Înlocuiește',

      'error_must_be_logged_in_driver': 'Trebuie să fii conectat ca șofer.',
      'coming_soon': 'În curând',

      'header_good_morning': 'BUNĂ DIMINEAȚA',
      'select_language': 'Selectează limba',
      'notifications': 'Notificări',
      'no_notifications': 'Nu există notificări',
      'change_profile_photo': 'Schimbă poza de profil',
      'logout': 'Deconectare',
      'profile_photo_updated': 'Poza de profil a fost actualizată.',
      'failed_upload_profile_photo': 'Încărcarea pozei de profil a eșuat: {error}',
      'could_not_read_image_bytes': 'Nu s-au putut citi datele imaginii din selectorul de fișiere.',

      'hi_name': 'Salut {name}, 👋',
      'welcome_to_company': 'bine ai venit la {company}',
      'welcome_desc': 'Ne bucurăm că ești alături de noi. Să începem!',
      'codriver': 'CODRIVER',

      'your_address': 'ADRESA TA',
      'your_origin': 'ORIGINEA TA',
      'uniform': 'UNIFORMĂ',
      'hint_street_house': 'Stradă, Număr',
      'hint_postal_code': 'Cod poștal',
      'hint_city': 'Oraș',
      'hint_country': 'Țară',
      'hint_birthday': 'Data nașterii',
      'hint_birth_city': 'Orașul nașterii',
      'hint_birth_state': 'Județ/Stat (naștere)',
      'hint_nationality': 'Naționalitate (CARTE ID) (Numele țării)',
      'label_cloth_size': 'alege mărimea hainelor',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'alege mărimea pantofilor',
      'hint_shoe_size': 'ex. 42',
      'label_notes': 'alte dorințe / notițe',

      'work_permit': 'PERMIS DE MUNCĂ',
      'work_permit_question':
          'ce tip de permis de muncă ai pentru a lucra în Germania',
      'permit_german_id': 'Carte de identitate germană',
      'permit_eu_id': 'Carte de identitate UE',
      'permit_work_visa': 'VIZĂ DE MUNCĂ pentru Germania',

      'your_work_permit': 'PERMISUL TĂU DE MUNCĂ',
      'please_upload_doc': 'te rugăm să încarci documentul',
      'upload_quality_hint':
          'Asigură-te că fotografia este complet vizibilă, clară și făcută de sus',
      'upload_your_file': 'încarcă fișierul',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF până la 50 MB',
      'hint_select_expiry': 'selectează data expirării',

      'id_passport_title': 'Carte ID, Pașaport',
      'id_card': 'CARTE ID',
      'passport': 'PAȘAPORT',
      'or': 'SAU',

      'your_passport': 'PAȘAPORTUL TĂU',
      'your_id_card': 'CARTEA TA ID',
      'frontside': 'FAȚĂ',
      'backside': 'SPATE',

      'your_drivers_license': 'PERMISUL TĂU AUTO',
      'upload_file_front': 'încarcă fișierul (față)',
      'upload_file_back': 'încarcă fișierul (spate)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (nu PDF)',
      'tax_document': 'DOCUMENT FISCAL',
      'please_upload_tax_id': 'te rugăm să încarci documentul cu ID fiscal',
      'upload_tax_id': 'încarcă ID fiscal',
      'file_formats_tax': 'PDF, JPG, PNG… până la 50 MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'Expirare permis',
      'hint_license_expiry': 'Selectează data expirării',

      'label_uploaded_docs': 'Documente încărcate',
      'no_docs': 'Încă nu există documente încărcate.',

      'doc_resident_permit': 'Permis de muncă / ședere',
      'doc_tax_id': 'Document ID fiscal',
      'doc_insurance': 'Asigurare',
      'doc_other_doc': 'Alt document',

      'driver_license_front': 'Permis auto (față)',
      'driver_license_back': 'Permis auto (spate)',
      'id_card_front': 'Carte ID (față)',
      'id_card_back': 'Carte ID (spate)',
      'passport_front': 'Pașaport (față)',
      'passport_back': 'Pașaport (spate)',

      'dash_error_loading_reports': 'Eroare la încărcarea rapoartelor: {error}',
      'dash_no_reports_uploaded': 'DSP-ul tău nu a încărcat încă rapoarte scorecard.',
      'dash_scorecard_week': 'SĂPTĂMÂNA SCORECARD {week}',
      'dash_week_range': 'Săptămâna {week}, {year}',
      'dash_no_scores_period': 'Nu există scoruri pentru această perioadă încă.',
      'dash_no_drivers_match': 'Niciun șofer nu se potrivește cu acest filtru.',
      'dash_no_name': '(Fără nume)',

      'dash_company_score': 'Scor companie',
      'dash_my_score': 'Scorul meu',

      'dash_select_period': 'Selectează perioada',
      'dash_weekly_view': 'Vizualizare săptămânală',
      'dash_best_da_month': 'Cel mai bun DA al lunii',
      'dash_best_da_year': 'Cel mai bun DA al anului',

      'dash_week': 'Săptămâna',
      'dash_total_score': 'Scor total',
      'dash_rank_in_station': 'Rang în stație',
      'dash_status': 'Status',

      'dash_rank': 'Rang',
      'dash_score': 'Scor',
      'dash_name': 'Nume',

      'dash_delivered': 'Livrate',
      'dash_rank_in_aion': 'Rang în AION',
      'dash_rank_of_total': '{rank} din {total}',

      'dash_no_my_score_week': 'Nu a fost găsit niciun scor pentru ID-ul tău de șofer în această săptămână.',

      'kpi_score': 'SCOR',
      'kpi_value': 'VALOARE',
      'kpi_pro_tip': 'SFAT',

      'kpi_title_dcr': 'Rata de finalizare a livrărilor',
      'kpi_title_dnr': 'Livrare nereușită (neprimit)',
      'kpi_title_lor': 'Pierdere pe rută',
      'kpi_title_pod': 'Dovadă de livrare',
      'kpi_title_cc': 'Contact cu clientul',
      'kpi_title_ce': 'Experiența clientului',
      'kpi_title_cdf': 'Eșecuri de livrare către client',

      'kpi_desc_dcr':
          'DCR măsoară câte opriri planificate au fost finalizate cu succes.',
      'kpi_tip_dcr':
          'Menține un ritm constant și evită ocolurile inutile.',
      'kpi_desc_dnr':
          'DNR numără livrările eșuate când pachetul nu a putut fi predat.',
      'kpi_tip_dnr':
          'Verifică adresele și folosește opțiunile de contact pentru a reduce eșecurile.',
      'kpi_desc_lor':
          'LoR urmărește pachetele pierdute sau deteriorate pe parcursul rutei.',
      'kpi_tip_lor':
          'Manipulează coletele cu grijă și organizează duba pentru a evita deteriorarea.',
      'kpi_desc_pod':
          'POD măsoară scanările corecte și confirmările de livrare.',
      'kpi_tip_pod':
          'Scanează întotdeauna la ușă și asigură locul corect de lăsare.',
      'kpi_desc_cc':
          'CC verifică dacă șoferul urmează pașii de interacțiune când este necesar.',
      'kpi_tip_cc':
          'Trimite mesaje sau sună clienții atunci când este necesar.',
      'kpi_desc_ce':
          'CE arată cât de mulțumiți sunt clienții de livrările tale.',
      'kpi_tip_ce':
          'Fii amabil, punctual și atent cu coletele.',
      'kpi_desc_cdf':
          'CDF urmărește probleme serioase de livrare.',
      'kpi_tip_cdf':
          'Analizează livrările eșuate și învață din tipare pentru a evita repetarea.',

      'month_jan': 'Ianuarie',
      'month_feb': 'Februarie',
      'month_mar': 'Martie',
      'month_apr': 'Aprilie',
      'month_may': 'Mai',
      'month_jun': 'Iunie',
      'month_jul': 'Iulie',
      'month_aug': 'August',
      'month_sep': 'Septembrie',
      'month_oct': 'Octombrie',
      'month_nov': 'Noiembrie',
      'month_dec': 'Decembrie',

      'month_short_jan': 'Ian',
      'month_short_feb': 'Feb',
      'month_short_mar': 'Mar',
      'month_short_apr': 'Apr',
      'month_short_may': 'Mai',
      'month_short_jun': 'Iun',
      'month_short_jul': 'Iul',
      'month_short_aug': 'Aug',
      'month_short_sep': 'Sep',
      'month_short_oct': 'Oct',
      'month_short_nov': 'Noi',
      'month_short_dec': 'Dec',

      'status_fantastic': 'Excelent',
      'status_great': 'Foarte bine',
      'status_fair': 'Acceptabil',
      'status_poor': 'Slab',

      'bucket_fantastic_plus': 'Excelent Plus',
      'bucket_fantastic': 'Excelent',
      'bucket_great': 'Foarte bine',
      'bucket_fair': 'Acceptabil',
      'bucket_poor': 'Slab',

      'rank_at': 'la',
      'rank_of': 'din',

      'period_month': 'Luna',
      'kw': 'KW',
    },

    // =========================
    // CROATIAN (hr)
    // =========================
    'hr': {
      'back': 'Natrag',
      'continue': 'Nastavi',
      'button_save': 'Spremi',
      'required': 'obavezno',
      'error_required': '{field} je obavezno',
      'error_required_short': 'Ovo polje je obavezno',
      'uploading': 'Učitavanje...',
      'upload': 'Učitaj',
      'replace': 'Zamijeni',

      'error_must_be_logged_in_driver': 'Moraš biti prijavljen kao vozač.',
      'coming_soon': 'Uskoro',

      'header_good_morning': 'DOBRO JUTRO',
      'select_language': 'Odaberi jezik',
      'notifications': 'Obavijesti',
      'no_notifications': 'Nema obavijesti',
      'change_profile_photo': 'Promijeni profilnu sliku',
      'logout': 'Odjava',
      'profile_photo_updated': 'Profilna slika je ažurirana.',
      'failed_upload_profile_photo': 'Neuspješno učitavanje profilne slike: {error}',
      'could_not_read_image_bytes': 'Nije moguće pročitati podatke slike iz birača datoteka.',

      'hi_name': 'Bok {name}, 👋',
      'welcome_to_company': 'dobrodošao/la u {company}',
      'welcome_desc': 'Drago nam je što si s nama. Krenimo!',
      'codriver': 'CODRIVER',

      'your_address': 'TVOJA ADRESA',
      'your_origin': 'TVOJE PORIJEKLO',
      'uniform': 'UNIFORMA',
      'hint_street_house': 'Ulica, Kućni broj',
      'hint_postal_code': 'Poštanski broj',
      'hint_city': 'Grad',
      'hint_country': 'Država',
      'hint_birthday': 'Datum rođenja',
      'hint_birth_city': 'Mjesto rođenja',
      'hint_birth_state': 'Regija/županija rođenja',
      'hint_nationality': 'Nacionalnost (OSOBNA) (Naziv države)',
      'label_cloth_size': 'odaberi veličinu odjeće',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'odaberi veličinu obuće',
      'hint_shoe_size': 'npr. 42',
      'label_notes': 'ostale želje / bilješke',

      'work_permit': 'RADNA DOZVOLA',
      'work_permit_question':
          'koju vrstu radne dozvole imaš za rad u Njemačkoj',
      'permit_german_id': 'Njemačka osobna iskaznica',
      'permit_eu_id': 'EU osobna iskaznica',
      'permit_work_visa': 'RADNA VIZA za Njemačku',

      'your_work_permit': 'TVOJA RADNA DOZVOLA',
      'please_upload_doc': 'molimo učitaj svoj dokument',
      'upload_quality_hint':
          'Provjeri da je fotografija potpuno vidljiva, kvalitetna i snimljena odozgo',
      'upload_your_file': 'učitaj datoteku',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF do 50 MB',
      'hint_select_expiry': 'odaberi datum isteka',

      'id_passport_title': 'Osobna, Putovnica',
      'id_card': 'OSOBNA',
      'passport': 'PUTOVNICA',
      'or': 'ILI',

      'your_passport': 'TVOJA PUTOVNICA',
      'your_id_card': 'TVOJA OSOBNA',
      'frontside': 'PREDNJA STRANA',
      'backside': 'STRAŽNJA STRANA',

      'your_drivers_license': 'TVOJA VOZAČKA DOZVOLA',
      'upload_file_front': 'učitaj datoteku (prednja)',
      'upload_file_back': 'učitaj datoteku (stražnja)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (ne PDF)',
      'tax_document': 'POREZNI DOKUMENT',
      'please_upload_tax_id': 'molimo učitaj dokument poreznog ID-a',
      'upload_tax_id': 'učitaj porezni ID',
      'file_formats_tax': 'PDF, JPG, PNG… do 50 MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'Istek vozačke dozvole',
      'hint_license_expiry': 'Odaberi datum isteka',

      'label_uploaded_docs': 'Učitani dokumenti',
      'no_docs': 'Još nema učitanih dokumenata.',

      'doc_resident_permit': 'Radna / boravišna dozvola',
      'doc_tax_id': 'Dokument poreznog ID-a',
      'doc_insurance': 'Osiguranje',
      'doc_other_doc': 'Drugi dokument',

      'driver_license_front': 'Vozačka (prednja)',
      'driver_license_back': 'Vozačka (stražnja)',
      'id_card_front': 'Osobna (prednja)',
      'id_card_back': 'Osobna (stražnja)',
      'passport_front': 'Putovnica (prednja)',
      'passport_back': 'Putovnica (stražnja)',

      'dash_error_loading_reports': 'Greška pri učitavanju izvještaja: {error}',
      'dash_no_reports_uploaded': 'Tvoj DSP još nije učitao scorecard izvještaje.',
      'dash_scorecard_week': 'SCORECARD TJEDAN {week}',
      'dash_week_range': 'Tjedan {week}, {year}',
      'dash_no_scores_period': 'Još nema rezultata za ovo razdoblje.',
      'dash_no_drivers_match': 'Nijedan vozač ne odgovara ovom filtru.',
      'dash_no_name': '(Bez imena)',

      'dash_company_score': 'Rezultat tvrtke',
      'dash_my_score': 'Moj rezultat',

      'dash_select_period': 'Odaberi razdoblje',
      'dash_weekly_view': 'Tjedni prikaz',
      'dash_best_da_month': 'Najbolji DA mjeseca',
      'dash_best_da_year': 'Najbolji DA godine',

      'dash_week': 'Tjedan',
      'dash_total_score': 'Ukupni rezultat',
      'dash_rank_in_station': 'Rang u stanici',
      'dash_status': 'Status',

      'dash_rank': 'Rang',
      'dash_score': 'Rezultat',
      'dash_name': 'Ime',

      'dash_delivered': 'Dostavljeno',
      'dash_rank_in_aion': 'Rang u AION-u',
      'dash_rank_of_total': '{rank} od {total}',

      'dash_no_my_score_week': 'Nije pronađen rezultat za tvoj ID vozača u ovom tjednu.',

      'kpi_score': 'REZULTAT',
      'kpi_value': 'VRIJEDNOST',
      'kpi_pro_tip': 'SAVJET',

      'kpi_title_dcr': 'Stopa dovršenih dostava',
      'kpi_title_dnr': 'Dostava nije primljena',
      'kpi_title_lor': 'Gubitak na ruti',
      'kpi_title_pod': 'Dokaz dostave',
      'kpi_title_cc': 'Kontakt s kupcem',
      'kpi_title_ce': 'Iskustvo kupca',
      'kpi_title_cdf': 'Neuspjele dostave kupcu',

      'kpi_desc_dcr':
          'DCR mjeri koliko je planiranih stajanja uspješno završeno.',
      'kpi_tip_dcr':
          'Održavaj stabilan tempo i izbjegavaj nepotrebna skretanja.',
      'kpi_desc_dnr':
          'DNR broji neuspjele dostave kada paket nije mogao biti predan.',
      'kpi_tip_dnr':
          'Provjeri adrese i koristi kontakt s kupcem kako bi smanjio neuspjele dostave.',
      'kpi_desc_lor':
          'LoR prati izgubljene ili oštećene pakete tijekom rute.',
      'kpi_tip_lor':
          'Pažljivo rukuj paketima i organiziraj kombi da se ne oštete.',
      'kpi_desc_pod':
          'POD mjeri ispravna skeniranja i potvrde dostave.',
      'kpi_tip_pod':
          'Uvijek skeniraj na vratima i odaberi ispravnu lokaciju ostavljanja.',
      'kpi_desc_cc':
          'CC provjerava prati li vozač korake komunikacije kada je potrebno.',
      'kpi_tip_cc':
          'Po potrebi pošalji poruku ili nazovi kupca.',
      'kpi_desc_ce':
          'CE pokazuje koliko su kupci zadovoljni tvojim dostavama.',
      'kpi_tip_ce':
          'Budi ljubazan, točan i pažljiv s paketima.',
      'kpi_desc_cdf':
          'CDF prati ozbiljne probleme s dostavom.',
      'kpi_tip_cdf':
          'Analiziraj neuspjele dostave i uči iz obrazaca kako bi izbjegao ponavljanje.',

      'month_jan': 'Siječanj',
      'month_feb': 'Veljača',
      'month_mar': 'Ožujak',
      'month_apr': 'Travanj',
      'month_may': 'Svibanj',
      'month_jun': 'Lipanj',
      'month_jul': 'Srpanj',
      'month_aug': 'Kolovoz',
      'month_sep': 'Rujan',
      'month_oct': 'Listopad',
      'month_nov': 'Studeni',
      'month_dec': 'Prosinac',

      'month_short_jan': 'Sij',
      'month_short_feb': 'Velj',
      'month_short_mar': 'Ožu',
      'month_short_apr': 'Tra',
      'month_short_may': 'Svi',
      'month_short_jun': 'Lip',
      'month_short_jul': 'Srp',
      'month_short_aug': 'Kol',
      'month_short_sep': 'Ruj',
      'month_short_oct': 'Lis',
      'month_short_nov': 'Stu',
      'month_short_dec': 'Pro',

      'status_fantastic': 'Izvrsno',
      'status_great': 'Vrlo dobro',
      'status_fair': 'Dobro',
      'status_poor': 'Loše',

      'bucket_fantastic_plus': 'Izvrsno Plus',
      'bucket_fantastic': 'Izvrsno',
      'bucket_great': 'Vrlo dobro',
      'bucket_fair': 'Dobro',
      'bucket_poor': 'Loše',

      'rank_at': 'u',
      'rank_of': 'od',

      'period_month': 'Mjesec',
      'kw': 'KW',
    },

    // =========================
    // ARABIC (ar)
    // =========================
    'ar': {
      'back': 'رجوع',
      'continue': 'متابعة',
      'button_save': 'حفظ',
      'required': 'إلزامي',
      'error_required': '{field} مطلوب',
      'error_required_short': 'هذا الحقل مطلوب',
      'uploading': 'جارٍ الرفع...',
      'upload': 'رفع',
      'replace': 'استبدال',

      'error_must_be_logged_in_driver': 'يجب تسجيل الدخول كسائق.',
      'coming_soon': 'قريباً',

      'header_good_morning': 'صباح الخير',
      'select_language': 'اختر اللغة',
      'notifications': 'الإشعارات',
      'no_notifications': 'لا توجد إشعارات',
      'change_profile_photo': 'تغيير صورة الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'profile_photo_updated': 'تم تحديث صورة الملف الشخصي.',
      'failed_upload_profile_photo': 'فشل رفع صورة الملف الشخصي: {error}',
      'could_not_read_image_bytes': 'تعذر قراءة بيانات الصورة من محدد الملفات.',

      'hi_name': 'مرحباً {name}، 👋',
      'welcome_to_company': 'مرحباً بك في {company}',
      'welcome_desc': 'سعداء بانضمامك إلينا. لنبدأ!',
      'codriver': 'CODRIVER',

      'your_address': 'عنوانك',
      'your_origin': 'معلوماتك الأساسية',
      'uniform': 'الزي',
      'hint_street_house': 'الشارع، رقم المنزل',
      'hint_postal_code': 'الرمز البريدي',
      'hint_city': 'المدينة',
      'hint_country': 'الدولة',
      'hint_birthday': 'تاريخ الميلاد',
      'hint_birth_city': 'مدينة الميلاد',
      'hint_birth_state': 'الولاية/المحافظة (الميلاد)',
      'hint_nationality': 'الجنسية (بطاقة الهوية) (اسم الدولة)',
      'label_cloth_size': 'اختر مقاس الملابس',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'اختر مقاس الحذاء',
      'hint_shoe_size': 'مثال: 42',
      'label_notes': 'ملاحظات / رغبات أخرى',

      'work_permit': 'تصريح العمل',
      'work_permit_question': 'ما نوع تصريح العمل الذي لديك للعمل في ألمانيا؟',
      'permit_german_id': 'بطاقة هوية ألمانية',
      'permit_eu_id': 'بطاقة هوية أوروبية',
      'permit_work_visa': 'تأشيرة عمل لألمانيا',

      'your_work_permit': 'تصريح عملك',
      'please_upload_doc': 'يرجى رفع المستند',
      'upload_quality_hint':
          'تأكد أن الصورة واضحة بالكامل وبجودة عالية ومأخوذة من الأعلى',
      'upload_your_file': 'ارفع ملفك',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF حتى 50MB',
      'hint_select_expiry': 'اختر تاريخ الانتهاء',

      'id_passport_title': 'هوية، جواز سفر',
      'id_card': 'الهوية',
      'passport': 'جواز السفر',
      'or': 'أو',

      'your_passport': 'جواز سفرك',
      'your_id_card': 'بطاقتك الشخصية',
      'frontside': 'الوجه الأمامي',
      'backside': 'الوجه الخلفي',

      'your_drivers_license': 'رخصة القيادة',
      'upload_file_front': 'ارفع الملف (أمام)',
      'upload_file_back': 'ارفع الملف (خلف)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (بدون PDF)',
      'tax_document': 'مستند ضريبي',
      'please_upload_tax_id': 'يرجى رفع مستند الرقم الضريبي',
      'upload_tax_id': 'ارفع الرقم الضريبي',
      'file_formats_tax': 'PDF, JPG, PNG… حتى 50MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'تاريخ انتهاء الرخصة',
      'hint_license_expiry': 'اختر تاريخ الانتهاء',

      'label_uploaded_docs': 'المستندات المرفوعة',
      'no_docs': 'لا توجد مستندات مرفوعة بعد.',

      'doc_resident_permit': 'تصريح عمل / إقامة',
      'doc_tax_id': 'مستند الرقم الضريبي',
      'doc_insurance': 'التأمين',
      'doc_other_doc': 'مستند آخر',

      'driver_license_front': 'رخصة القيادة (أمام)',
      'driver_license_back': 'رخصة القيادة (خلف)',
      'id_card_front': 'الهوية (أمام)',
      'id_card_back': 'الهوية (خلف)',
      'passport_front': 'جواز السفر (أمام)',
      'passport_back': 'جواز السفر (خلف)',

      'dash_error_loading_reports': 'خطأ أثناء تحميل التقارير: {error}',
      'dash_no_reports_uploaded': 'لم يقم DSP برفع تقارير الـ Scorecard بعد.',
      'dash_scorecard_week': 'أسبوع SCORECARD {week}',
      'dash_week_range': 'الأسبوع {week}، {year}',
      'dash_no_scores_period': 'لا توجد نتائج لهذه الفترة حتى الآن.',
      'dash_no_drivers_match': 'لا يوجد سائقون يطابقون هذا الفلتر.',
      'dash_no_name': '(بدون اسم)',

      'dash_company_score': 'نتيجة الشركة',
      'dash_my_score': 'نتيجتي',

      'dash_select_period': 'اختر الفترة',
      'dash_weekly_view': 'عرض أسبوعي',
      'dash_best_da_month': 'أفضل DA في الشهر',
      'dash_best_da_year': 'أفضل DA في السنة',

      'dash_week': 'الأسبوع',
      'dash_total_score': 'النتيجة الإجمالية',
      'dash_rank_in_station': 'الترتيب في المحطة',
      'dash_status': 'الحالة',

      'dash_rank': 'الترتيب',
      'dash_score': 'النتيجة',
      'dash_name': 'الاسم',

      'dash_delivered': 'تم التسليم',
      'dash_rank_in_aion': 'الترتيب في AION',
      'dash_rank_of_total': '{rank} من {total}',

      'dash_no_my_score_week': 'لم يتم العثور على نتيجة لمعرّف السائق الخاص بك في هذا الأسبوع.',

      'kpi_score': 'النتيجة',
      'kpi_value': 'القيمة',
      'kpi_pro_tip': 'نصيحة',

      'kpi_title_dcr': 'معدل إكمال التسليم',
      'kpi_title_dnr': 'لم يتم الاستلام',
      'kpi_title_lor': 'فقدان على الطريق',
      'kpi_title_pod': 'إثبات التسليم',
      'kpi_title_cc': 'التواصل مع العميل',
      'kpi_title_ce': 'تجربة العميل',
      'kpi_title_cdf': 'إخفاقات تسليم العميل',

      'kpi_desc_dcr':
          'يقيس DCR عدد نقاط التوقف المخطط لها التي تم إنجازها بنجاح.',
      'kpi_tip_dcr':
          'حافظ على وتيرة ثابتة وتجنب الالتفافات غير الضرورية.',
      'kpi_desc_dnr':
          'يحسب DNR حالات فشل التسليم عندما لا يمكن تسليم الطرد.',
      'kpi_tip_dnr':
          'تحقق من العناوين واستخدم خيارات التواصل مع العميل لتقليل الفشل.',
      'kpi_desc_lor':
          'يتتبع LoR الطرود المفقودة أو التالفة أثناء الطريق.',
      'kpi_tip_lor':
          'تعامل مع الطرود بحذر ونظّم السيارة لتجنب التلف.',
      'kpi_desc_pod':
          'يقيس POD عمليات المسح الصحيحة وتأكيدات التسليم.',
      'kpi_tip_pod':
          'امسح الطرد عند الباب وتأكد من اختيار موقع التسليم الصحيح.',
      'kpi_desc_cc':
          'يتحقق CC من اتباع خطوات التواصل عند الحاجة.',
      'kpi_tip_cc':
          'أرسل رسالة أو اتصل بالعملاء عند الضرورة لتجنب فشل التسليم.',
      'kpi_desc_ce':
          'يمثل CE مدى رضا العملاء عن عمليات التسليم.',
      'kpi_tip_ce':
          'كن ودوداً ودقيقاً وحذراً مع الطرود لتحسين تقييم العملاء.',
      'kpi_desc_cdf':
          'يتتبع CDF مشاكل التسليم الخطيرة.',
      'kpi_tip_cdf':
          'حلّل حالات الفشل وتعلّم من الأنماط لتجنب تكرار الأخطاء.',

      'month_jan': 'يناير',
      'month_feb': 'فبراير',
      'month_mar': 'مارس',
      'month_apr': 'أبريل',
      'month_may': 'مايو',
      'month_jun': 'يونيو',
      'month_jul': 'يوليو',
      'month_aug': 'أغسطس',
      'month_sep': 'سبتمبر',
      'month_oct': 'أكتوبر',
      'month_nov': 'نوفمبر',
      'month_dec': 'ديسمبر',

      'month_short_jan': 'ينا',
      'month_short_feb': 'فبر',
      'month_short_mar': 'مار',
      'month_short_apr': 'أبر',
      'month_short_may': 'ماي',
      'month_short_jun': 'يون',
      'month_short_jul': 'يول',
      'month_short_aug': 'أغس',
      'month_short_sep': 'سبت',
      'month_short_oct': 'أكت',
      'month_short_nov': 'نوف',
      'month_short_dec': 'ديس',

      'status_fantastic': 'ممتاز',
      'status_great': 'جيد جداً',
      'status_fair': 'متوسط',
      'status_poor': 'ضعيف',

      'bucket_fantastic_plus': 'ممتاز +',
      'bucket_fantastic': 'ممتاز',
      'bucket_great': 'جيد جداً',
      'bucket_fair': 'متوسط',
      'bucket_poor': 'ضعيف',

      'rank_at': 'في',
      'rank_of': 'من',

      'period_month': 'الشهر',
      'kw': 'KW',
    },
  };

  String _lang() => locale.languageCode.toLowerCase();

  String t(String key) {
    final lang = _lang();
    final langMap = _localizedValues[lang] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']![key] ?? key;
  }

  /// Translation with simple placeholder replacement: {name}, {week}, {error}, etc.
  String tf(String key, Map<String, String> params) {
    var text = t(key);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

/// Optional: helper to display language names with flags in the UI.
String languageLabel(String code) {
  switch (code) {
    case 'de':
      return '🇩🇪 Deutsch';
    case 'en':
      return '🇬🇧 English';
    case 'sq':
      return '🇦🇱 Shqip';
    case 'hu':
      return '🇭🇺 Magyar';
    case 'ro':
      return '🇷🇴 Română';
    case 'hr':
      return '🇭🇷 Hrvatski';
    case 'ar':
      return '🇸🇦 العربية';
    default:
      return code;
  }
}
