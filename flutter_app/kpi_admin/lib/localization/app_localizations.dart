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
  // You can extend this over time with more keys.
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // --- App / profile ---
      'appTitle': 'DSP Copilot',
      'profileTitle': 'My Profile',
      'language': 'Language',
      'changePhoto': 'Change profile photo',
      'profilePhotoHint':
          'Profile photo is stored in Firestore (base64) for fast avatar display '
          'and in Firebase Storage for backup / full-size access.',

      // --- Driver dashboard / scorecard ---
      'driver_dashboard_header_scorecard': 'SCORE CARD DASHBOARD',
      'driver_dashboard_header_onboarding': 'ONBOARDING',
      'driver_dashboard_error_loading_reports': 'Error loading reports:',
      'driver_dashboard_no_reports':
          'Your DSP has not uploaded any scorecard reports yet.',
      'driver_dashboard_week_title_prefix': 'SCORECARD WEEK',
      'driver_dashboard_week_title_generic': 'SCORECARD WEEK',
      'driver_dashboard_search_hint':
          'Search name or Transporter ID…',
      'driver_dashboard_bucket_all_status': 'All Status',
      'driver_dashboard_bucket_fantastic_plus': 'Fantastic Plus',
      'driver_dashboard_bucket_fantastic': 'Fantastic',
      'driver_dashboard_bucket_great': 'Great',
      'driver_dashboard_bucket_fair': 'Fair',
      'driver_dashboard_bucket_poor': 'Poor',
      'driver_dashboard_summary_total_company_score':
          'TOTAL COMPANY SCORE',
      'driver_dashboard_summary_rank_in_station':
          'RANK IN STATION',
      'driver_dashboard_summary_reliability_score':
          'RELIABILITY SCORE',
      'driver_dashboard_no_scores_yet':
          'No scores for this week yet.',
      'driver_dashboard_no_drivers_match':
          'No drivers match this filter.',

      'status_fantastic_plus': 'Fantastic Plus',
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      // --- Driver onboarding ---
      'header_title': 'Onboarding | Personal data | ARION Logistics GmbH',
      'subtitle':
          'Please fill in your personal data for onboarding. Your DSP can view these details and uploaded documents in their portal.',
      'section_personal': 'Personal details',
      'section_address': 'Address',
      'section_license': 'Driving license',
      'section_emergency': 'Emergency contact',
      'section_payment': 'Payment & equipment',
      'section_notes': 'Other notes',
      'section_documents': 'Documents',
      'label_full_name': 'Full name',
      'label_name_at_birth': 'Name at birth',
      'label_dob': 'Date of birth',
      'hint_dob': 'e.g. 1995-03-14',
      'label_residence_permit_expiry': 'Residence permit expiry date',
      'hint_residence_permit_expiry': 'e.g. 2027-05-01',
      'label_phone': 'Phone number',
      'label_street': 'Street address',
      'label_city': 'City',
      'label_postal': 'Postal code',
      'label_country': 'Country',
      'label_license_number': 'Driving license number',
      'label_license_expiry': 'License expiry date',
      'hint_license_expiry': 'e.g. 2030-12-31',
      'label_emergency_name': 'Emergency contact name',
      'label_emergency_phone': 'Emergency contact phone',
      'label_iban': 'Bank IBAN (optional)',
      'label_insurance_company': 'Insurance company',
      'label_tax_id': 'Tax ID',
      'label_tshirt': 'T-shirt size (optional)',
      'hint_tshirt': 'e.g. S, M, L, XL',
      'label_notes': 'Notes',
      'label_upload_docs': 'Upload documents',
      'label_uploading': 'Uploading...',
      'label_uploaded_docs': 'Uploaded documents',
      'no_docs': 'No documents uploaded yet.',
      'button_save': 'Save',
      'language_label': 'Language',
      'error_required': 'Please enter {field}',
      'doc_resident_permit': 'Resident permit',
      'doc_driver_license': 'Driver’s licence',
      'doc_tax_id': 'Tax ID',
      'doc_insurance': 'Insurance',
      'doc_other_doc': 'Other document',
    },
    'de': {
      'appTitle': 'DSP Copilot',
      'profileTitle': 'Mein Profil',
      'language': 'Sprache',
      'changePhoto': 'Profilbild ändern',
      'profilePhotoHint':
          'Das Profilbild wird in Firestore (Base64) für schnelle Avatare '
          'und in Firebase Storage als Sicherung / Vollbild gespeichert.',

      // Driver dashboard (texts kept English for now – you can translate later)
      'driver_dashboard_header_scorecard': 'SCORE CARD DASHBOARD',
      'driver_dashboard_header_onboarding': 'ONBOARDING',
      'driver_dashboard_error_loading_reports': 'Error loading reports:',
      'driver_dashboard_no_reports':
          'Your DSP has not uploaded any scorecard reports yet.',
      'driver_dashboard_week_title_prefix': 'SCORECARD WEEK',
      'driver_dashboard_week_title_generic': 'SCORECARD WEEK',
      'driver_dashboard_search_hint':
          'Search name or Transporter ID…',
      'driver_dashboard_bucket_all_status': 'All Status',
      'driver_dashboard_bucket_fantastic_plus': 'Fantastic Plus',
      'driver_dashboard_bucket_fantastic': 'Fantastic',
      'driver_dashboard_bucket_great': 'Great',
      'driver_dashboard_bucket_fair': 'Fair',
      'driver_dashboard_bucket_poor': 'Poor',
      'driver_dashboard_summary_total_company_score':
          'TOTAL COMPANY SCORE',
      'driver_dashboard_summary_rank_in_station':
          'RANK IN STATION',
      'driver_dashboard_summary_reliability_score':
          'RELIABILITY SCORE',
      'driver_dashboard_no_scores_yet':
          'No scores for this week yet.',
      'driver_dashboard_no_drivers_match':
          'No drivers match this filter.',
      'status_fantastic_plus': 'Fantastic Plus',
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      'header_title': 'Onboarding | Personaldaten | ARION Logistics GmbH',
      'subtitle':
          'Bitte füllen Sie Ihre persönlichen Daten für das Onboarding aus. Ihr DSP kann diese Angaben und hochgeladene Dokumente im Portal einsehen.',
      'section_personal': 'Persönliche Daten',
      'section_address': 'Adresse',
      'section_license': 'Führerschein',
      'section_emergency': 'Notfallkontakt',
      'section_payment': 'Zahlung & Ausstattung',
      'section_notes': 'Weitere Hinweise',
      'section_documents': 'Dokumente',
      'label_full_name': 'Vollständiger Name',
      'label_name_at_birth': 'Geburtsname',
      'label_dob': 'Geburtsdatum',
      'hint_dob': 'z.B. 1995-03-14',
      'label_residence_permit_expiry': 'Ablaufdatum des Aufenthaltstitels',
      'hint_residence_permit_expiry': 'z.B. 2027-05-01',
      'label_phone': 'Telefonnummer',
      'label_street': 'Straße und Hausnummer',
      'label_city': 'Stadt',
      'label_postal': 'Postleitzahl',
      'label_country': 'Land',
      'label_license_number': 'Führerscheinnummer',
      'label_license_expiry': 'Ablaufdatum des Führerscheins',
      'hint_license_expiry': 'z.B. 2030-12-31',
      'label_emergency_name': 'Name des Notfallkontakts',
      'label_emergency_phone': 'Telefonnummer des Notfallkontakts',
      'label_iban': 'Bank-IBAN (optional)',
      'label_insurance_company': 'Versicherungsgesellschaft',
      'label_tax_id': 'Steuer-ID',
      'label_tshirt': 'T-Shirt-Größe (optional)',
      'hint_tshirt': 'z.B. S, M, L, XL',
      'label_notes': 'Notizen',
      'label_upload_docs': 'Dokumente hochladen',
      'label_uploading': 'Wird hochgeladen...',
      'label_uploaded_docs': 'Hochgeladene Dokumente',
      'no_docs': 'Noch keine Dokumente hochgeladen.',
      'button_save': 'Speichern',
      'language_label': 'Sprache',
      'error_required': 'Bitte {field} eingeben',
      'doc_resident_permit': 'Aufenthaltstitel',
      'doc_driver_license': 'Führerschein',
      'doc_tax_id': 'Steuer-ID',
      'doc_insurance': 'Versicherungsnachweis',
      'doc_other_doc': 'Anderes Dokument',
    },
    'sq': {
      'appTitle': 'DSP Copilot',
      'profileTitle': 'Profili im',
      'language': 'Gjuha',
      'changePhoto': 'Ndrysho foton e profilit',
      'profilePhotoHint':
          'Fotoja e profilit ruhen në Firestore (base64) për avatar të shpejtë '
          'dhe në Firebase Storage si kopje rezervë / madhësia e plotë.',

      // Driver dashboard – English text for now
      'driver_dashboard_header_scorecard': 'SCORE CARD DASHBOARD',
      'driver_dashboard_header_onboarding': 'ONBOARDING',
      'driver_dashboard_error_loading_reports': 'Error loading reports:',
      'driver_dashboard_no_reports':
          'Your DSP has not uploaded any scorecard reports yet.',
      'driver_dashboard_week_title_prefix': 'SCORECARD WEEK',
      'driver_dashboard_week_title_generic': 'SCORECARD WEEK',
      'driver_dashboard_search_hint':
          'Search name or Transporter ID…',
      'driver_dashboard_bucket_all_status': 'All Status',
      'driver_dashboard_bucket_fantastic_plus': 'Fantastic Plus',
      'driver_dashboard_bucket_fantastic': 'Fantastic',
      'driver_dashboard_bucket_great': 'Great',
      'driver_dashboard_bucket_fair': 'Fair',
      'driver_dashboard_bucket_poor': 'Poor',
      'driver_dashboard_summary_total_company_score':
          'TOTAL COMPANY SCORE',
      'driver_dashboard_summary_rank_in_station':
          'RANK IN STATION',
      'driver_dashboard_summary_reliability_score':
          'RELIABILITY SCORE',
      'driver_dashboard_no_scores_yet':
          'No scores for this week yet.',
      'driver_dashboard_no_drivers_match':
          'No drivers match this filter.',
      'status_fantastic_plus': 'Fantastic Plus',
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      'header_title':
          'Onboarding | Të dhënat personale | ARION Logistics GmbH',
      'subtitle':
          'Ju lutemi plotësoni të dhënat tuaja personale për procesin e pranimit. DSP-ja juaj mund t’i shohë këto të dhëna dhe dokumentet e ngarkuara në portal.',
      'section_personal': 'Të dhënat personale',
      'section_address': 'Adresa',
      'section_license': 'Patenta e makinës',
      'section_emergency': 'Kontakti i emergjencës',
      'section_payment': 'Pagesa & pajisjet',
      'section_notes': 'Shënime të tjera',
      'section_documents': 'Dokumentet',
      'label_full_name': 'Emri i plotë',
      'label_name_at_birth': 'Emri në lindje',
      'label_dob': 'Data e lindjes',
      'hint_dob': 'p.sh. 1995-03-14',
      'label_residence_permit_expiry':
          'Data e skadimit të lejes së qëndrimit',
      'hint_residence_permit_expiry': 'p.sh. 2027-05-01',
      'label_phone': 'Numri i telefonit',
      'label_street': 'Adresa e rrugës',
      'label_city': 'Qyteti',
      'label_postal': 'Kodi postar',
      'label_country': 'Shteti',
      'label_license_number': 'Numri i patentës',
      'label_license_expiry': 'Data e skadimit të patentës',
      'hint_license_expiry': 'p.sh. 2030-12-31',
      'label_emergency_name': 'Emri i kontaktit të emergjencës',
      'label_emergency_phone': 'Telefoni i kontaktit të emergjencës',
      'label_iban': 'IBAN i bankës (opsionale)',
      'label_insurance_company': 'Kompania e sigurimit',
      'label_tax_id': 'Numri i tatimit',
      'label_tshirt': 'Madhësia e bluzës (opsionale)',
      'hint_tshirt': 'p.sh. S, M, L, XL',
      'label_notes': 'Shënime',
      'label_upload_docs': 'Ngarko dokumente',
      'label_uploading': 'Duke ngarkuar...',
      'label_uploaded_docs': 'Dokumentet e ngarkuara',
      'no_docs': 'Nuk ka ende dokumente të ngarkuara.',
      'button_save': 'Ruaj',
      'language_label': 'Gjuha',
      'error_required': 'Ju lutem shkruani {field}',
      'doc_resident_permit': 'Leje qëndrimi',
      'doc_driver_license': 'Patenta e drejtimit',
      'doc_tax_id': 'Numri i tatimit',
      'doc_insurance': 'Dokumenti i sigurimit',
      'doc_other_doc': 'Dokument tjetër',
    },
    'hu': {
      'appTitle': 'DSP Copilot',
      'profileTitle': 'Profilom',
      'language': 'Nyelv',
      'changePhoto': 'Profilkép módosítása',
      'profilePhotoHint':
          'A profilkép Firestore-ban (base64) és Firebase Storage-ban kerül tárolásra.',

      // Driver dashboard – English text for now
      'driver_dashboard_header_scorecard': 'SCORE CARD DASHBOARD',
      'driver_dashboard_header_onboarding': 'ONBOARDING',
      'driver_dashboard_error_loading_reports': 'Error loading reports:',
      'driver_dashboard_no_reports':
          'Your DSP has not uploaded any scorecard reports yet.',
      'driver_dashboard_week_title_prefix': 'SCORECARD WEEK',
      'driver_dashboard_week_title_generic': 'SCORECARD WEEK',
      'driver_dashboard_search_hint':
          'Search name or Transporter ID…',
      'driver_dashboard_bucket_all_status': 'All Status',
      'driver_dashboard_bucket_fantastic_plus': 'Fantastic Plus',
      'driver_dashboard_bucket_fantastic': 'Fantastic',
      'driver_dashboard_bucket_great': 'Great',
      'driver_dashboard_bucket_fair': 'Fair',
      'driver_dashboard_bucket_poor': 'Poor',
      'driver_dashboard_summary_total_company_score':
          'TOTAL COMPANY SCORE',
      'driver_dashboard_summary_rank_in_station':
          'RANK IN STATION',
      'driver_dashboard_summary_reliability_score':
          'RELIABILITY SCORE',
      'driver_dashboard_no_scores_yet':
          'No scores for this week yet.',
      'driver_dashboard_no_drivers_match':
          'No drivers match this filter.',
      'status_fantastic_plus': 'Fantastic Plus',
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      'header_title': 'Onboarding | Személyes adatok | ARION Logistics GmbH',
      'subtitle':
          'Kérjük, töltse ki személyes adatait a beléptetéshez. Az Ön DSP-je ezeket az adatokat és a feltöltött dokumentumokat a portálon látja.',
      'section_personal': 'Személyes adatok',
      'section_address': 'Cím',
      'section_license': 'Vezetői engedély',
      'section_emergency': 'Sürgősségi kontakt',
      'section_payment': 'Fizetés és felszerelés',
      'section_notes': 'Egyéb megjegyzések',
      'section_documents': 'Dokumentumok',
      'label_full_name': 'Teljes név',
      'label_name_at_birth': 'Születési név',
      'label_dob': 'Születési dátum',
      'hint_dob': 'pl. 1995-03-14',
      'label_residence_permit_expiry':
          'Tartózkodási engedély lejárati dátuma',
      'hint_residence_permit_expiry': 'pl. 2027-05-01',
      'label_phone': 'Telefonszám',
      'label_street': 'Utca, házszám',
      'label_city': 'Város',
      'label_postal': 'Irányítószám',
      'label_country': 'Ország',
      'label_license_number': 'Jogosítvány száma',
      'label_license_expiry': 'Jogosítvány lejárati dátuma',
      'hint_license_expiry': 'pl. 2030-12-31',
      'label_emergency_name': 'Sürgősségi kontakt neve',
      'label_emergency_phone': 'Sürgősségi kontakt telefonszáma',
      'label_iban': 'Bankszámla IBAN (opcionális)',
      'label_insurance_company': 'Biztosító társaság',
      'label_tax_id': 'Adóazonosító',
      'label_tshirt': 'Pólóméret (opcionális)',
      'hint_tshirt': 'pl. S, M, L, XL',
      'label_notes': 'Megjegyzések',
      'label_upload_docs': 'Dokumentumok feltöltése',
      'label_uploading': 'Feltöltés folyamatban...',
      'label_uploaded_docs': 'Feltöltött dokumentumok',
      'no_docs': 'Még nincs feltöltött dokumentum.',
      'button_save': 'Mentés',
      'language_label': 'Nyelv',
      'error_required': 'Kérjük, adja meg: {field}',
      'doc_resident_permit': 'Tartózkodási engedély',
      'doc_driver_license': 'Vezetői engedély',
      'doc_tax_id': 'Adóazonosító',
      'doc_insurance': 'Biztosítási dokumentum',
      'doc_other_doc': 'Egyéb dokumentum',
    },
    'ro': {
      'appTitle': 'DSP Copilot',
      'profileTitle': 'Profilul meu',
      'language': 'Limbă',
      'changePhoto': 'Schimbă fotografia de profil',
      'profilePhotoHint':
          'Fotografia de profil este stocată în Firestore (base64) și în Firebase Storage.',

      // Driver dashboard – English text for now
      'driver_dashboard_header_scorecard': 'SCORE CARD DASHBOARD',
      'driver_dashboard_header_onboarding': 'ONBOARDING',
      'driver_dashboard_error_loading_reports': 'Error loading reports:',
      'driver_dashboard_no_reports':
          'Your DSP has not uploaded any scorecard reports yet.',
      'driver_dashboard_week_title_prefix': 'SCORECARD WEEK',
      'driver_dashboard_week_title_generic': 'SCORECARD WEEK',
      'driver_dashboard_search_hint':
          'Search name or Transporter ID…',
      'driver_dashboard_bucket_all_status': 'All Status',
      'driver_dashboard_bucket_fantastic_plus': 'Fantastic Plus',
      'driver_dashboard_bucket_fantastic': 'Fantastic',
      'driver_dashboard_bucket_great': 'Great',
      'driver_dashboard_bucket_fair': 'Fair',
      'driver_dashboard_bucket_poor': 'Poor',
      'driver_dashboard_summary_total_company_score':
          'TOTAL COMPANY SCORE',
      'driver_dashboard_summary_rank_in_station':
          'RANK IN STATION',
      'driver_dashboard_summary_reliability_score':
          'RELIABILITY SCORE',
      'driver_dashboard_no_scores_yet':
          'No scores for this week yet.',
      'driver_dashboard_no_drivers_match':
          'No drivers match this filter.',
      'status_fantastic_plus': 'Fantastic Plus',
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      'header_title': 'Onboarding | Date personale | ARION Logistics GmbH',
      'subtitle':
          'Vă rugăm să completați datele personale pentru procesul de onboarding. DSP-ul dvs. poate vedea aceste date și documentele încărcate în portal.',
      'section_personal': 'Date personale',
      'section_address': 'Adresă',
      'section_license': 'Permis de conducere',
      'section_emergency': 'Contact de urgență',
      'section_payment': 'Plată și echipament',
      'section_notes': 'Alte note',
      'section_documents': 'Documente',
      'label_full_name': 'Nume complet',
      'label_name_at_birth': 'Numele la naștere',
      'label_dob': 'Data nașterii',
      'hint_dob': 'ex. 1995-03-14',
      'label_residence_permit_expiry':
          'Data expirării permisului de ședere',
      'hint_residence_permit_expiry': 'ex. 2027-05-01',
      'label_phone': 'Număr de telefon',
      'label_street': 'Adresă stradă',
      'label_city': 'Oraș',
      'label_postal': 'Cod poștal',
      'label_country': 'Țară',
      'label_license_number': 'Număr permis de conducere',
      'label_license_expiry': 'Data expirării permisului',
      'hint_license_expiry': 'ex. 2030-12-31',
      'label_emergency_name': 'Nume contact de urgență',
      'label_emergency_phone': 'Telefon contact de urgență',
      'label_iban': 'IBAN bancar (opțional)',
      'label_insurance_company': 'Companie de asigurări',
      'label_tax_id': 'Cod de identificare fiscală',
      'label_tshirt': 'Mărime tricou (opțional)',
      'hint_tshirt': 'ex. S, M, L, XL',
      'label_notes': 'Note',
      'label_upload_docs': 'Încărcați documente',
      'label_uploading': 'Se încarcă...',
      'label_uploaded_docs': 'Documente încărcate',
      'no_docs': 'Nu există încă documente încărcate.',
      'button_save': 'Salvați',
      'language_label': 'Limbă',
      'error_required': 'Vă rugăm să introduceți {field}',
      'doc_resident_permit': 'Permis de ședere',
      'doc_driver_license': 'Permis de conducere',
      'doc_tax_id': 'Cod de identificare fiscală',
      'doc_insurance': 'Document de asigurare',
      'doc_other_doc': 'Alt document',
    },
    'hr': {
      'appTitle': 'DSP Copilot',
      'profileTitle': 'Moj profil',
      'language': 'Jezik',
      'changePhoto': 'Promijeni fotografiju profila',
      'profilePhotoHint':
          'Fotografija profila se sprema u Firestore (base64) i u Firebase Storage.',

      // Driver dashboard – English text for now
      'driver_dashboard_header_scorecard': 'SCORE CARD DASHBOARD',
      'driver_dashboard_header_onboarding': 'ONBOARDING',
      'driver_dashboard_error_loading_reports': 'Error loading reports:',
      'driver_dashboard_no_reports':
          'Your DSP has not uploaded any scorecard reports yet.',
      'driver_dashboard_week_title_prefix': 'SCORECARD WEEK',
      'driver_dashboard_week_title_generic': 'SCORECARD WEEK',
      'driver_dashboard_search_hint':
          'Search name or Transporter ID…',
      'driver_dashboard_bucket_all_status': 'All Status',
      'driver_dashboard_bucket_fantastic_plus': 'Fantastic Plus',
      'driver_dashboard_bucket_fantastic': 'Fantastic',
      'driver_dashboard_bucket_great': 'Great',
      'driver_dashboard_bucket_fair': 'Fair',
      'driver_dashboard_bucket_poor': 'Poor',
      'driver_dashboard_summary_total_company_score':
          'TOTAL COMPANY SCORE',
      'driver_dashboard_summary_rank_in_station':
          'RANK IN STATION',
      'driver_dashboard_summary_reliability_score':
          'RELIABILITY SCORE',
      'driver_dashboard_no_scores_yet':
          'No scores for this week yet.',
      'driver_dashboard_no_drivers_match':
          'No drivers match this filter.',
      'status_fantastic_plus': 'Fantastic Plus',
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      'header_title': 'Onboarding | Osobni podaci | ARION Logistics GmbH',
      'subtitle':
          'Molimo ispunite svoje osobne podatke za onboarding. Vaš DSP može vidjeti ove podatke i učitane dokumente u portalu.',
      'section_personal': 'Osobni podaci',
      'section_address': 'Adresa',
      'section_license': 'Vozačka dozvola',
      'section_emergency': 'Kontakt za hitne slučajeve',
      'section_payment': 'Plaćanje i oprema',
      'section_notes': 'Ostale napomene',
      'section_documents': 'Dokumenti',
      'label_full_name': 'Puno ime',
      'label_name_at_birth': 'Ime pri rođenju',
      'label_dob': 'Datum rođenja',
      'hint_dob': 'npr. 1995-03-14',
      'label_residence_permit_expiry':
          'Datum isteka dozvole boravka',
      'hint_residence_permit_expiry': 'npr. 2027-05-01',
      'label_phone': 'Broj telefona',
      'label_street': 'Ulica i kućni broj',
      'label_city': 'Grad',
      'label_postal': 'Poštanski broj',
      'label_country': 'Država',
      'label_license_number': 'Broj vozačke dozvole',
      'label_license_expiry': 'Datum isteka vozačke dozvole',
      'hint_license_expiry': 'npr. 2030-12-31',
      'label_emergency_name':
          'Ime kontakta za hitne slučajeve',
      'label_emergency_phone':
          'Telefon kontakta za hitne slučajeve',
      'label_iban': 'IBAN računa (opcionalno)',
      'label_insurance_company': 'Osiguravajuće društvo',
      'label_tax_id': 'Porezni broj',
      'label_tshirt': 'Veličina majice (opcionalno)',
      'hint_tshirt': 'npr. S, M, L, XL',
      'label_notes': 'Napomene',
      'label_upload_docs': 'Učitaj dokumente',
      'label_uploading': 'Učitavanje...',
      'label_uploaded_docs': 'Učitani dokumenti',
      'no_docs': 'Još nema učitanih dokumenata.',
      'button_save': 'Spremi',
      'language_label': 'Jezik',
      'error_required': 'Molimo unesite {field}',
      'doc_resident_permit': 'Dozvola boravka',
      'doc_driver_license': 'Vozačka dozvola',
      'doc_tax_id': 'Porezni broj',
      'doc_insurance': 'Dokaz o osiguranju',
      'doc_other_doc': 'Drugi dokument',
    },
    'ar': {
      'appTitle': 'DSP Copilot',
      'profileTitle': 'الملف الشخصي',
      'language': 'اللغة',
      'changePhoto': 'تغيير صورة الملف الشخصي',
      'profilePhotoHint':
          'يتم تخزين صورة الملف الشخصي في Firestore (base64) وفي Firebase Storage.',

      // Driver dashboard – English text for now
      'driver_dashboard_header_scorecard': 'SCORE CARD DASHBOARD',
      'driver_dashboard_header_onboarding': 'ONBOARDING',
      'driver_dashboard_error_loading_reports': 'Error loading reports:',
      'driver_dashboard_no_reports':
          'Your DSP has not uploaded any scorecard reports yet.',
      'driver_dashboard_week_title_prefix': 'SCORECARD WEEK',
      'driver_dashboard_week_title_generic': 'SCORECARD WEEK',
      'driver_dashboard_search_hint':
          'Search name or Transporter ID…',
      'driver_dashboard_bucket_all_status': 'All Status',
      'driver_dashboard_bucket_fantastic_plus': 'Fantastic Plus',
      'driver_dashboard_bucket_fantastic': 'Fantastic',
      'driver_dashboard_bucket_great': 'Great',
      'driver_dashboard_bucket_fair': 'Fair',
      'driver_dashboard_bucket_poor': 'Poor',
      'driver_dashboard_summary_total_company_score':
          'TOTAL COMPANY SCORE',
      'driver_dashboard_summary_rank_in_station':
          'RANK IN STATION',
      'driver_dashboard_summary_reliability_score':
          'RELIABILITY SCORE',
      'driver_dashboard_no_scores_yet':
          'No scores for this week yet.',
      'driver_dashboard_no_drivers_match':
          'No drivers match this filter.',
      'status_fantastic_plus': 'Fantastic Plus',
      'status_fantastic': 'Fantastic',
      'status_great': 'Great',
      'status_fair': 'Fair',
      'status_poor': 'Poor',

      'header_title': 'الانضمام | البيانات الشخصية | ARION Logistics GmbH',
      'subtitle':
          'يرجى تعبئة بياناتك الشخصية من أجل الانضمام. يمكن لمشغل التوصيل (DSP) الاطلاع على هذه البيانات والملفات المرفوعة في البوابة.',
      'section_personal': 'البيانات الشخصية',
      'section_address': 'العنوان',
      'section_license': 'رخصة القيادة',
      'section_emergency': 'جهة الاتصال في حالات الطوارئ',
      'section_payment': 'الدفع والمعدات',
      'section_notes': 'ملاحظات أخرى',
      'section_documents': 'الوثائق',
      'label_full_name': 'الاسم الكامل',
      'label_name_at_birth': 'الاسم عند الولادة',
      'label_dob': 'تاريخ الميلاد',
      'hint_dob': 'مثال: 1995-03-14',
      'label_residence_permit_expiry':
          'تاريخ انتهاء تصريح الإقامة',
      'hint_residence_permit_expiry': 'مثال: 2027-05-01',
      'label_phone': 'رقم الهاتف',
      'label_street': 'عنوان الشارع',
      'label_city': 'المدينة',
      'label_postal': 'الرمز البريدي',
      'label_country': 'البلد',
      'label_license_number': 'رقم رخصة القيادة',
      'label_license_expiry': 'تاريخ انتهاء الرخصة',
      'hint_license_expiry': 'مثال: 2030-12-31',
      'label_emergency_name': 'اسم جهة الاتصال للطوارئ',
      'label_emergency_phone': 'هاتف جهة الاتصال للطوارئ',
      'label_iban': 'رقم الآيبان البنكي (اختياري)',
      'label_insurance_company': 'شركة التأمين',
      'label_tax_id': 'رقم التعريف الضريبي',
      'label_tshirt': 'مقاس القميص (اختياري)',
      'hint_tshirt': 'مثال: S, M, L, XL',
      'label_notes': 'ملاحظات',
      'label_upload_docs': 'رفع الوثائق',
      'label_uploading': 'جاري الرفع...',
      'label_uploaded_docs': 'الوثائق المرفوعة',
      'no_docs': 'لم يتم رفع أي وثائق بعد.',
      'button_save': 'حفظ',
      'language_label': 'اللغة',
      'error_required': 'يرجى إدخال {field}',
      'doc_resident_permit': 'تصريح الإقامة',
      'doc_driver_license': 'رخصة القيادة',
      'doc_tax_id': 'رقم التعريف الضريبي',
      'doc_insurance': 'وثيقة التأمين',
      'doc_other_doc': 'مستند آخر',
    },
  };

  String _lang(BuildContext? context) {
    return locale.languageCode.toLowerCase();
  }

  String t(String key) {
    final lang = _lang(null);
    final langMap = _localizedValues[lang] ?? _localizedValues['en']!;
    return langMap[key] ?? _localizedValues['en']![key] ?? key;
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
    // No heavy async work needed, return synchronously.
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
      return '🇸🇾 العربية';
    default:
      return code;
  }
}
