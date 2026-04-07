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
    Locale('tr'), // Turkish
    Locale('ru'), // Russian
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
      'header_good_afternoon': 'GOOD AFTERNOON',
      'header_good_evening': 'GOOD EVENING',
      'select_language': 'Select language',
      'notifications': 'Notifications',
      'no_notifications': 'No notifications',
      'nav_home': 'Home',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Help',
      'nav_rules': 'Rules',
      'nav_profile': 'Profile',
      'nav_tasks': 'Tasks',
      'driver_home_dispatcher': 'Dispatcher',
      'driver_home_shift_plan_title': 'Shift Plan',
      'driver_home_shift_plan_subtitle': 'Your shifts',
      'driver_home_scorecard_subtitle': 'Your performance overview',
      'driver_home_tasks_title': 'Tasks',
      'driver_home_tasks_subtitle': 'Manage open to-dos',
      'driver_home_academy_subtitle': 'Training & knowledge',
      'driver_home_rules_title': 'Company Rules',
      'driver_home_rules_subtitle': 'Guidelines & policies',
      'driver_notification_published_on': 'Published {date}',
      'driver_home_vehicles_title': 'Vehicles',
      'driver_home_vehicles_subtitle': 'Vehicle overview',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'Your AI assistant',
      'driver_home_absence_title': 'Absence',
      'driver_home_absence_subtitle': 'Vacation & sick leave',
      'driver_home_incident_title': 'Incident Report',
      'driver_home_incident_subtitle': 'Report an accident',
      'driver_home_new_badge': 'NEW',
      'driver_academy_title': 'DA Academy',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle': 'Daily inspection sheet guidelines',
      'driver_academy_safety_title': 'Safety Training',
      'driver_academy_safety_subtitle': 'Safety trainings',
      'driver_academy_delivery_title': 'Amazon Delivery',
      'driver_academy_delivery_subtitle': 'Delivery processes & workflows',
      'driver_academy_app_title': 'CoDriver App',
      'driver_academy_app_subtitle': 'App features & guides',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - Training Video',
      'driver_green_book_video_subtitle': 'Tap to play',
      'driver_green_book_start_test': 'Start Green Book Test',
      'driver_green_book_test_required': 'Test required',
      'driver_green_book_section1_title': 'Green Book Daily Inspection Sheet',
      'driver_green_book_section1_text':
          'The daily inspection sheet (Green Book) is a mandatory document that must be completed before each shift. It helps verify vehicle condition and documents safety-relevant points.',
      'driver_green_book_section1_b1': 'Complete it fully before every shift.',
      'driver_green_book_section1_b2': 'Report vehicle defects immediately.',
      'driver_green_book_section1_b3': 'Do not forget your signature.',
      'driver_green_book_section2_title': 'Consequences of Non-Compliance',
      'driver_green_book_section2_text':
          'Violations are handled in escalating steps:',
      'driver_green_book_section2_b1':
          'First warning: Verbal warning from dispatcher.',
      'driver_green_book_section2_b2': 'Second warning: Written warning.',
      'driver_green_book_section2_b3':
          'Repeated violations: Employment-law consequences up to termination.',
      'driver_green_book_section3_title': 'Legal Penalties',
      'driver_green_book_section3_text':
          'Driving without a properly completed inspection sheet can lead to serious legal consequences:',
      'driver_green_book_section3_b1':
          'Fine: up to €5,000 for driver, up to €15,000 for company.',
      'driver_green_book_section3_b2':
          'Driving ban: possible license withdrawal for repeated violations.',
      'driver_green_book_section3_b3': 'Points in Flensburg may be recorded.',
      'driver_green_book_section3_b4':
          'Insurance coverage can be reduced/void in case of accident.',
      'driver_green_book_test_title': 'Green Book Test',
      'driver_green_book_test_progress': 'Question {current} of {total}',
      'driver_green_book_test_true': 'True',
      'driver_green_book_test_false': 'False',
      'driver_green_book_test_next': 'Next',
      'driver_green_book_test_submit': 'Submit test',
      'driver_green_book_test_statement1':
          'The Green Book must be completed before every shift.',
      'driver_green_book_test_statement2':
          'Vehicle defects can be reported at the end of the week.',
      'driver_green_book_test_statement3':
          'The first non-compliance consequence is a verbal warning.',
      'driver_green_book_test_statement4':
          'Legal penalties can include a fine up to €5,000 for the driver.',
      'driver_green_book_test_statement5':
          'Insurance coverage is always unaffected if the Green Book is missing.',
      'driver_green_book_test_result_pass_title': 'Test passed',
      'driver_green_book_test_result_fail_title': 'Test not passed',
      'driver_green_book_test_result_pass_body':
          'Good job. You scored {score}/{total}.',
      'driver_green_book_test_result_fail_body':
          'You scored {score}/{total}. Review the Green Book section and try again.',
      'driver_green_book_test_retry': 'Retry',
      'driver_green_book_test_close': 'Close',
      'driver_green_book_test_back_to_green_book': 'Back to Green Book',
      'driver_green_book_test_no_questions':
          'No test questions are configured yet. Please contact your dispatcher.',
      'driver_green_book_test_offline_fallback':
          'Live test sync failed. You can continue with fallback questions and retry loading.',
      'admin_home_notification': 'Notification',
      'admin_home_driver_fallback': 'Driver',
      'admin_home_not_confirmed_by': 'NOT CONFIRMED BY:',
      'admin_home_missing_loading': 'missing: ...',
      'admin_home_missing_unknown': 'missing: --',
      'admin_home_missing_count': 'missing: {count}',
      'admin_home_error_generic': 'Error: {error}',
      'admin_home_all_drivers_confirmed': 'All drivers have confirmed.',
      'admin_home_close': 'Close',
      'admin_home_last_week': 'Last Week',
      'admin_home_not_logged_in': 'Not logged in.',
      'admin_home_loading_reports': 'Loading reports...',
      'admin_home_no_reports_uploaded': 'No reports uploaded yet.',
      'admin_home_week_short': 'WK',
      'admin_home_month_prefix': 'MONTH',
      'admin_home_year_prefix': 'YEAR',
      'admin_home_loading_scores': 'Loading scores...',
      'admin_home_name_fallback': 'First Name Last Name',
      'admin_home_scorecard': 'Scorecard',
      'admin_home_company_score': 'COMPANY SCORE',
      'admin_home_of': 'of',
      'admin_home_best_driver': 'Best Driver',
      'admin_home_worst_defender': 'Worst Defender',
      'admin_home_notification_history': 'Notification History',
      'admin_home_no_notifications_yet': 'No notifications yet.',
      'admin_home_notification_type_message': 'NEW MESSAGE',
      'admin_home_notification_type_academy': 'DA ACADEMY',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'NEW RULE',
      'admin_home_edit_rule': 'Edit rule',
      'admin_home_title': 'Title',
      'admin_home_body': 'Body',
      'admin_home_cancel': 'Cancel',
      'admin_home_save': 'Save',
      'admin_home_title_or_body_required': 'Title or body is required.',
      'admin_home_notification_not_found': 'Notification not found.',
      'admin_home_rule_updated_for_drivers':
          'Rule updated for {count} drivers.',
      'admin_home_edit_failed': 'Edit failed: {error}',
      'admin_home_delete_notification_question': 'Delete notification?',
      'admin_home_delete_notification_body':
          'This will delete this notification for you and for all drivers.',
      'admin_home_delete': 'Delete',
      'admin_home_notification_deleted': 'Notification deleted.',
      'admin_home_delete_failed': 'Delete failed: {error}',
      'admin_home_options': 'Options',
      'admin_home_title_upper': 'TITLE',
      'admin_home_confirmed_by': 'confirmed by',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Service',
      'admin_home_accidents': 'Accidents',
      'admin_home_total': 'total',
      'admin_home_active': 'active',
      'admin_home_inactive': 'inactive',
      'admin_home_doc_id_card': 'ID Card',
      'admin_home_doc_driving_license': 'Driving License',
      'admin_home_doc_residence_permit': 'Residence Permit',
      'admin_home_loading_drivers': 'Loading drivers...',
      'admin_home_no_drivers_yet': 'No drivers yet.',
      'admin_home_contract': 'Contract',
      'admin_home_last_day': 'last day',
      'admin_home_probation': 'Probation',
      'admin_home_ended': 'ended',
      'admin_home_ends': 'ends',
      'admin_home_expired_by': 'expired by',
      'admin_home_loading_documents': 'Loading documents...',
      'admin_home_driver_documents': 'Driver Documents',
      'admin_home_expired_documents': 'Expired Documents',
      'admin_home_expired_soon': 'expired soon',
      'admin_home_missing_documents_data': 'Missing Documents / Data',
      'admin_home_total_missing': 'total missing',
      'admin_home_driver_contracts': 'Driver Contracts',
      'admin_home_last_day_soon': 'last day soon',
      'admin_home_no_items': 'No items',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'Change profile photo',
      'profile_change_photo': 'Change Profile Photo',
      'logout': 'Logout',
      'profile_logout': 'Logout',
      'pin_change_with_old':
          'You can change your PIN after verifying the old one.',
      'pin_forgot_contact_admin': 'Forgot your PIN? Contact your admin.',
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
      'dash_compliance_safety': 'Compliance & Safety',
      'dash_delivery_quality_swc': 'Delivery Quality & SWC',
      'dash_company_threshold_hint': '{score}% out of {target}% minimum',
      'dash_company_threshold_met': '{score}% meets the {target}% threshold',
      'dash_company_data_section': 'Data As-Company',
      'dash_company_data_show': 'Show results as company',
      'dash_company_data_hide': 'Hide company categories',
      'dash_company_section_safety': 'Safety',
      'dash_company_section_compliance': 'Compliance',
      'dash_company_section_customer_delivery_experience':
          'Customer Delivery Experience',
      'dash_company_section_quality': 'Quality',
      'dash_company_section_standard_work_compliance':
          'Standard Work Compliance',
      'dash_metric_fico': 'Safe Driving Metric (FICO)',
      'dash_metric_speeding_event_rate':
          'Speeding Event Rate (Per 100 Trips)',
      'dash_metric_mentor_adoption_rate': 'Mentor Adoption Rate',
      'dash_metric_vehicle_audit_compliance':
          'Vehicle Audit (VSA) Compliance',
      'dash_metric_breach_of_contract': 'Breach of Contract (BOC)',
      'dash_metric_working_hours_compliance':
          'Working Hours Compliance (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Comprehensive Audit Score (CAS)',
      'dash_metric_customer_escalation_dpmo': 'Customer Escalation DPMO',
      'dash_metric_customer_delivery_feedback': 'Customer Delivery Feedback',
      'dash_metric_delivery_completion_rate':
          'Delivery Completion Rate (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Photo-On-Delivery',
      'dash_metric_contact_compliance': 'Contact Compliance',

      'dash_rank': 'Rank',
      'dash_score': 'Score',
      'dash_name': 'Name',

      'dash_delivered': 'Delivered',
      'dash_rank_in_aion': 'Rank in AION',
      'dash_rank_of_total': '{rank} of {total}',

      'dash_no_my_score_week':
          'No score found for your driver ID in this week.',
      'dash_all_status': 'All Status',
      'dash_search_name_or_id': 'Search name or Transporter ID...',
      'dash_upload_driver_csv': 'Upload Driver CSV',

      // Scorecard overview (admin)
      'scorecard_overview_title': 'SCORE CARD DASHBOARD',
      'scorecard_overview_overview_suffix': '— Overview',
      'scorecard_overview_upload_pdf': 'UPLOAD SCORECARD PDF',
      'scorecard_overview_upload_prompt': 'Upload your Scorecard PDF',
      'scorecard_overview_choose_file': 'Choose file',
      'scorecard_overview_summary_title': 'Score Card Summary',
      'scorecard_overview_no_reports_yet':
          'No reports yet. Upload your first Scorecard PDF to get started.',
      'scorecard_overview_chart_title': 'Score Card Overview',
      'scorecard_overview_best_drivers': 'Best Drivers',
      'scorecard_overview_no_reports_available': 'No reports available.',
      'scorecard_overview_no_drivers_period':
          'No drivers found for this period.',
      'scorecard_overview_select_station': 'Select station',
      'scorecard_overview_all_stations': 'All Stations',
      'scorecard_overview_select_period': 'Select period',
      'scorecard_overview_best_drivers_year': 'Best drivers of year',
      'scorecard_overview_best_drivers_month': 'Best drivers of month',
      'scorecard_overview_station': 'Station',
      'scorecard_overview_station_code': 'Station {code}',
      'scorecard_overview_upload_success_one':
          '1 scorecard parsed and saved. Dashboard updated.',
      'scorecard_overview_upload_success_many':
          '{count} scorecards parsed and saved. Dashboard updated.',
      'scorecard_overview_upload_parse_failed': 'Upload/parse failed: {error}',
      'scorecard_overview_no_file_bytes': 'No file bytes',
      'scorecard_overview_csv_updated':
          'Driver names updated across all your reports.',
      'scorecard_overview_csv_failed': 'CSV import failed: {error}',
      'scorecard_overview_delete_report_q': 'Delete report?',
      'scorecard_overview_delete_report_body':
          'This will delete the report "{title}" and all score entries for this week.',
      'scorecard_overview_deleted': 'Report and week scores deleted.',
      'scorecard_overview_delete_failed': 'Delete failed: {error}',
      'scorecard_overview_more': 'More',
      'scorecard_overview_delete_report_menu': 'Delete report',
      'scorecard_overview_upload_processing':
          'Uploading and processing scorecards...',
      'scorecard_overview_row_title': 'Score Card {year} WK {week}',
      'scorecard_overview_reliability_score': 'Reliability Score',
      'scorecard_overview_from_last_week': 'from last week',
      'scorecard_overview_from_last_year': 'from last year',

      // KPI tiles
      'kpi_score': 'SCORE',
      'kpi_value': 'VALUE',
      'kpi_pro_tip': 'PRO TIP',

      'kpi_title_dcr': 'Delivery Completion Rate',
      'kpi_title_dnr': 'Delivery Success Conditions',
      'kpi_title_lor': 'Lost on Road',
      'kpi_title_pod': 'Picture on Delivery',
      'kpi_title_cc': 'Customer Contact',
      'kpi_title_ce': 'Customer Escalation',
      'kpi_title_cdf': 'Customer Delivery Feedback',

      'kpi_desc_dcr':
          'The higher the value, the better. To achieve a 100% success rate, it is recommended to attempt a redelivery* after a failed delivery.',
      'kpi_tip_dcr':
          'Example: If you cannot deliver a package on a given day for any reason and attempt delivery again later the same day, your DCR value will be higher and closer to 100%, even if the second delivery attempt is also unsuccessful.',

      'kpi_desc_dnr':
          'DSC DPMO (Delivery Success Conditions)\n(previously DNR – Delivery Not Received)\n\nThe lower the value, the better.\n\nThis metric measures how correctly and traceably deliveries are carried out.\n\nBasic delivery rules:\n- Delivery to the correct person or the correct location\n- Deliveries to customers, household members, neighbors, or receptionists are low risk when performed correctly\n- Always use the correct scan/reason code so customers receive correct notifications\n\nMailroom / mailbox deliveries:\n- Follow the standard workflow\n- Packages must be fully inside the mailbox or mail slot and must not protrude\n- Use the most accurate scan available\n\nCorrect address & geofence:\n- Delivery within 25 meters of the correct geofence\n- Always match name and address in the app with the package label and the building\n- If the geocode appears incorrect, report it via SDS\n\nPhoto at delivery (POD):\n- Always take a clear photo when prompted\n- Package and surroundings must be clearly visible\n- Especially important for unattended deliveries and customer trust\n\nFollow delivery preferences:\n- Follow customer instructions in the app if they are safe\n- If instructions are unsafe, contact the customer\n- Only use approved safe locations from the app\n\nSimultaneous / group stops:\n- Use “Select all” only when multiple packages are delivered to the same person or location (e.g. reception)\n- Correctly capture recipient name and signature',

      'kpi_tip_dnr':
          'Important notice:\n\nRepeated high values in DSC DPMO indicate incorrect or risky deliveries.\n\n- Frequent deviations may be interpreted by Amazon as potential theft\n- This may trigger a loss prevention process\n- In the worst case, this may lead to termination of cooperation\n\nCareful scans, correct photos, and following all delivery rules protect you and your team.',

      'kpi_desc_lor':
          'LoR (Lost on Road)\n\nThe lower the value, the better.\n\nThis metric shows whether all undelivered packages are correctly recorded at the end of the route.\n\nAt the end of the route:\n- Check in the scanner how many packages must be returned\n- Ensure this number exactly matches the packages in the vehicle',

      'kpi_tip_lor':
          'Important notice:\n\nThis is the category with the highest suspicion of theft.\n\nDiscrepancies between scanner and vehicle inventory may be considered serious errors and can lead to internal investigations or further consequences.',

      'kpi_desc_pod':
          'PoD (Picture on Delivery)\n\nThe higher the value, the better.\n\nThis column shows packages for which a photo was taken but which were marked as Invalid or Unsafe.\n\nCommon reasons for POD rejection:\n1. Package label with customer data visible (package must be turned over)\n2. Blurry photo\n3. Person visible in the photo\n4. No package visible in the photo\n5. Package inside the vehicle\n6. Package in hand\n7. Package too close to the camera\n8. Photo too dark',

      'kpi_tip_pod':
          'This should be the easiest category\nTarget value: 100%\nSignificantly improves the overall score',

      'pod_quality_title': 'POD Quality',
      'pod_quality_success': 'Success',
      'pod_quality_rejects': 'Rejects',
      'pod_quality_opp': 'Opportunities',
      'pod_quality_bypass': 'Bypass',
      'pod_quality_blurry': 'Blurry',
      'pod_quality_too_dark': 'Too Dark',
      'pod_quality_no_package': 'No Package',
      'pod_quality_in_car': 'In Car',
      'pod_quality_too_close': 'Too Close',
      'pod_quality_shell_week_title': 'POD QUALITY - WEEK',
      'pod_quality_week_label': 'Week {week}',
      'pod_quality_dashboard_title': 'POD QUALITY DASHBOARD',
      'pod_quality_upload_pdf': 'Upload PDF',
      'pod_quality_no_reports_uploaded':
          'No POD Quality reports yet. Upload a POD Quality PDF to get started.',
      'pod_quality_upload_success_one':
          '1 POD Quality report parsed and saved.',
      'pod_quality_upload_success_many':
          '{count} POD Quality reports parsed and saved.',
      'pod_quality_upload_parse_failed': 'Upload/parse failed: {error}',
      'pod_quality_rejects_breakdown': 'Rejects breakdown',
      'pod_quality_no_data_week': 'No POD data for this week.',
      'pod_quality_drivers': 'Drivers',
      'pod_quality_entries_count': '{count} entries',

      'kpi_desc_cc':
          'CC (Customer Contact)\n\nThe higher the value, the better.\n\nExtremely important:\nYou must ALWAYS send a “No safe location” or “Address not found” message every time you cannot deliver a package because:\n\n- the customer is not at home or\n- the address cannot be found',

      'kpi_tip_cc':
          'There is an automatic standard message in the app for every scenario.',

      'kpi_desc_ce':
          'CE (Customer Escalation)\n\nThe lower the value, the better.\nThe worst category of all.\n\nCustomers escalate when delivery instructions are not followed.\n\nThe driver is always responsible\nAppeals are nearly impossible without very strong evidence\nHas the strongest impact on your Scorecard\n\nHow to avoid CE\n\nIt is against delivery guidelines to leave packages at unsafe or unattended locations without approval\n\nDelivery Associates must:\n- Ring the doorbell / use intercom or knock\n- Give the customer sufficient time to respond\n\nIf the customer cannot be reached and no safe location is stored:\n- Call the customer twice\n- Send a text message\n- Contact Driver Support if no contact is possible\n\nIf necessary:\n- Scan the package as “Delivery failed – customer unavailable”\n- Retry delivery according to guidelines',

      'kpi_tip_ce':
          'Do not leave packages at unsafe or unapproved locations\nAlways follow the correct shipping and delivery processes',

      'kpi_desc_cdf':
          'CDF DPMO (Customer Delivery Feedback)\n\nThe lower the value, the better.\n\nLevel 1 (L1)\n- Customer rates the delivery as “Great” (👍) or “Not so good” (👎)\n\nLevel 2 (L2)\n- Additional feedback on why the experience was good or bad',

      'kpi_tip_cdf': 'CDF is calculated exclusively at L1 level',

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

      // FAQs
      'faq_title': 'Frequently Asked Questions',
      'faq_search_hint': 'Search questions',
      'faq_empty': 'No matching FAQs found.',
      'driver_tasks_error': 'Error: {error}',
      'driver_tasks_no_tasks': 'No tasks assigned yet.',
      'driver_tasks_update_status': 'Update status',
      'driver_tasks_confirm_completed': 'Confirm completed',
      'driver_tasks_set_completed_first': 'Set status to Completed first.',
      'driver_tasks_completion_confirmed': 'Completion confirmed.',
      'driver_tasks_failed_update_status': 'Failed to update status: {error}',
      'driver_tasks_failed_confirm_task': 'Failed to confirm task: {error}',
      'driver_tasks_status_confirmed_by_you': 'Status confirmed by you.',
      'driver_tasks_confirm_when_fully_done':
          'Please confirm when this task is fully done.',
      'driver_tasks_status_pending': 'Pending',
      'driver_tasks_status_in_progress': 'In progress',
      'driver_tasks_status_completed': 'Completed',
      'faq_green_book_video_title': 'Green Book Tutorial Video',
      'faq_green_book_video_subtitle':
          'Watch how to fill the Green Book step by step',
      'faq_green_book_video_action': 'Play video',
      'faq_green_book_video_missing':
          'Green Book video link is not configured yet.',
      'faq_green_book_video_open_failed':
          'Could not open Green Book video link.',

      'faq_q1': 'What is most important about your daily task?',
      'faq_a1': 'Delivering packages in quality and in good behavior.',

      'faq_q2': 'What should you not do in case of problems with the costumer?',
      'faq_a2':
          'DO NOT try to handle the situation yourself and inform a dispatcher onduty instead. We will try to talk to the costumer for you and avoid any bad consequences from Amazon due to costumer complaints. We are here for you!',

      'faq_q3':
          'What if the situation has already escalated and the costumer is not happy for whatever happened?',
      'faq_a3':
          'It is never too late to fix any mistakes. Still call us and we will try to fix the mistake with the costumer. Better late than ever.',

      'faq_q4':
          'What is more important, Quantity (speed of delivering as many stops as possible) or Quality?',
      'faq_a4':
          'Quality! Always quality! Follow costumers instructions and DO NOT leave the package in unsafe locations, just because you are behind with your stops.',

      'faq_q5':
          'What if I focus on quality but then I get behind with my stops?',
      'faq_a5':
          'You will finish your stops, in one way or another. We will try to send help but only if we see it reasonable.',

      'faq_q6': 'What is scorecard and a DNR?',
      'faq_a6': 'Glad you asked.',

      'faq_q7': 'Weekly Scorecard',
      'faq_a7':
          'The weekly scorecard gives us a quick, clear overview of how the team is doing on our key goals. It helps us spot what’s going well, where we’re falling behind, and what we need to focus on for the week ahead The overall scores are as follows:\n'
          '• Fantastic Plus: >93% (exceptional performance)\n'
          '• Fantastic: 85% – 92.9%\n'
          '• Great: 70% – 84.9%\n'
          '• Fair: 50% – 69.9%\n'
          '• Poor: <50%',

      'faq_q7_1': 'DNR Tab\nDelivered Not Received',
      'faq_a7_1':
          'Is when you have delivered a package, and clicked "Swipe to finish" button confirming you have delivered the package but the costumer has not received the package due to number of reasons: Package theft, box being empty of the package items and also wrong delivery to the wrong address.\n'
          'Every Tuesday you will receive pictures of every DNR you have received during the week.',

      'faq_q7_1_1':
          'How should I avoid this and how important it is to the weekly scorecard?',
      'faq_a7_1_1':
          'It is very important and to avoid this you simply should inform the costumer beforehand that you are soon going to their house/business and ONLY ring the bell with their nameplate on it.',

      'faq_q7_1_2': 'How do I avoid package losses?',
      'faq_a7_1_2':
          'Always try to give the packages on hand to the costumer and if this is not possible, send a message informing them as to where the package was left, for example, in the garage, under the stairs, in the shed, behind the flower vase, etc..\n'
          'If you do not think it is safe to leave the package unattended, please, it is always best to just take the package and try again later. This is VERY important.',

      'faq_q7_1_3': 'How do I know what place is safe or not?',
      'faq_a7_1_3':
          'Instinct and also common sense. If a building consist of 20 - 30 floors and you leave it by the mailboxes, chances for it to be stolen are higher and higher compared to those in a private house.\n'
          'Also, to help you on your daily deliveries and to avoid getting hit by a DNR, everyday morning we will post a picture with addresses that consist with a high chance of packages to be stolen and costumers complaining, based on previous results deliveries and statistics.',

      'faq_q7_1_4':
          'What if a package is lost or stolen, how will that affect my score?',
      'faq_a7_1_4':
          'Badly. This will affect you by at least 30% and that is only with one package which loses you at least 600 points. The more points you see in the scorecard under your name, the worse it is. The more packages you deliver per work-week, the less points you lose. The points you lose also varies by the price of the item lost, the more expensive, more points lost. We should keep this score section as low as possible.\n'
          'Not to be ignored is the fact that if you regurlarly have a high number of lost packages, we will have to release you due to the fact that sooner or later, Amazon may suspect of package theft, and therefore this is very dangerous.',

      'faq_q7_2':
          'CC Tab\n'
          'Contact Compliance',
      'faq_a7_2':
          'Meaning how many times you have reached out to the costumer about their delivery, be it via message or a phone call. The less you interact with the costumer, the less scores you will get in the scorecard and we should keep this section as high as possible because it is actually one of the the easiest categories and it helps a lot in your overall score.',

      'faq_q7_2_1': 'Why should I do this?',
      'faq_a7_2_1':
          'Delivering packages is not just Drop&Go, you should also inform the costumer beforehand and ask them as to where would they like to have the package delivered.',

      'faq_q7_2_2': 'How do I improve my CC Scores?',
      'faq_a7_2_2':
          'Thank you for asking. Simple, by calling and especially by texting costumers in every stop.',

      'faq_q7_3': 'CE Tab\nCostumer Escalation',
      'faq_a7_3':
          'Remember how bad DNR affected your scores? Well, this is at least 2 times worse, and you also risk losing your job because it depends on how bad the situation was.',

      'faq_q7_3_1': 'How do I avoid this?',
      'faq_a7_3_1':
          'By always following costumers delivery instructions and in case of a mistake, first please apologize and if the costumer is angry, please ask them for a minute of their time to talk to us, as you are already calling us. By reading Section 2, you should know by now that it is best to just leave it to us to handle such issues.',

      'faq_q7_4': 'POD Tab\nPicture on Delivery',
      'faq_a7_4':
          'This column shows the list of package eligible for PODs, for which photos have been taken but which have been either Invalid or Not Sure. Reason for rejecting a POD, which may include:\n'
          '1- Package label on photo with costumers details. Package should be turned backwards before the picture is taken.\n'
          '2- Blurred photo\n'
          '3- Person apparent in photo\n'
          '4- No parcel detected in photo\n'
          '5- Parcel in car\n'
          '6- Parcel in hand\n'
          '7- Parcel in letterbox\n'
          '8- Parcel too close\n'
          '9- Photo too dark.\n'
          'This one should always be the easiest where you should get a score of 100% and it improves your overall score',

      'faq_q7_5': 'LoR Tab\nLost on Road',
      'faq_a7_5':
          'Penalizes you when you have a scanned a package from your loading and have not returned it at the end of the shift in case of a unsuccesful delivery. So the package has been lost and you will lose as much points as you would in a DNR, so please count well the packages you bring back and make sure they match with the packages shown in scanner. You can find them on: Todays Itinerary - Summary - Problems. If they dont match, please inform the dispatcher on-duty before ending work in the Amazon app.',

      'faq_q7_6': 'DCR Tab\nDelivery Completion Rate',
      'faq_a7_6':
          'YShows your capabilities on delivering packages. It tracks the percentage of deliveries completed as planned, helping us measure the efficiency and reliability of our deliveries. It highlights issues like delays, failed attempts, or routing problems. This should always be as high as possible. To make that possible you should every day do reattempts and avoid as much you can returning packages.',

      'faq_q7_7': 'CDF Tab (Previously, DEX)\nCostumer Delivery Feedback',
      'faq_a7_7':
          'Captures the recipient’s experience with the delivery process, including punctuality, condition of goods, and driver professionalism. It helps us identify service strengths and areas for improvement. At the end of the delivery, costumer gets an email from Amazon about the delivery experience, with questions such as:\n'
          '1) Was your package delivered on time?\n'
          'Yes / No\n'
          '2) Was the package left in a secure location?\n'
          'Yes / No\n'
          '3) Was the package in good condition when it arrived?\n'
          'Yes / No\n'
          '4) How satisfied are you with the delivery overall?\n'
          'Very satisfied / Satisfied / Neutral / Dissatisfied / Very Dissatisfied\n'
          '5) How would you rate the communication and tracking updates for thisdelivery?\n'
          'Excellent / Good / Fair / Poor\n'
          '6) Was the delivery person courteous and professional?\n'
          'Yes / No / Not Applicable (Contactless Delivery)\n'
          '7) Do you have any comments about your delivery experience?\n'
          '(Costumer additional comments)',

      'faq_q7_8': 'What should I keep in mind about the scorecard?',
      'faq_a7_8':
          'Quality and efficency go a long way. Good scores are good for you, for the company and good for the whole team. Costumer satisfaction is very important and good scores are accompanied with a bonus from the company.\n'
          'Give your best, get the best.',

      'faq_q8': 'What other areas should I be careful about?',
      'faq_a8':
          'Taking care of yourself in driving safely, avoiding injuries and avoiding dogs and dog bites. Being careful with work equipment such as the daily vehicle, the work scanner/phone and coming to work wearing your safety shoes & safety vest, Amazon-branded jacket or t-shirt (depending on the weather).',

      'faq_q9':
          'What happens if I do a car accident or damage the work vehicle?',
      'faq_a9':
          'First, make sure you are okay and you are not badly injured. As about the car damage, if we determine that accidents occur due to negligence – for example, distractions such as mobile phone use while driving – you will be personally liable for the full damage. Additionally, you will receive a report from the police, which could even result in license suspension. Of course, this is also a reason for immediate dismissal. Otherwise you are only expelled from taking Weekly Scorecard Bonuses for 2 months. In case of an incident, you ARE obliged to inform us immediately and provide us with the time of the incident, location, if there is damages to private or public properties (such as wall, fences, lamp posts, people and/or pets), location and pictures of the car damages.',

      'faq_q10': 'What do I do when I have packages damaged and/or missing.',
      'faq_a10':
          'When a package is damaged, feel free to book it as damaged and return it to station. If that damaged package was a liquid package and has damaged other packages with it, please make a picture of all damaged packages and send it to the dispatcher on duty and we will report it to Amazon for you.\n'
          'When a package is missing, feel free to mark/book it as missing unless it has an OTP for which YOU HAVE to report it to us first before marking it as missing. This is VERY IMPORTANT.',

      'faq_q11': 'What is an OTP (One-Time Password) Package?',
      'faq_a11':
          'It is an expensive item that Amazon requires costumer to provide the driver with a One Time Password before delivering the package, to ensure the package is delivered to the right person/costumer. You have to take extensive care for such packages and not to leave them unattended and only hand the packages to the costumer that has provided you with the password.',

      'faq_q12':
          'Why do we keep bothering you to slow down and not go any faster?',
      'faq_a12':
          'We do not like that either but that is how the system is. We need to follow systems algorithm and do as many stops per-hour as predetermined so we can get more routes in the future and you get to work more and not be free.\n'
          'Also by going faster, you risk getting a DNR and risk losing points for both, yourself and the company in the weekly scorecard.',

      'faq_q13':
          'Then why do the dispatchers sometimes ask me as to why you are behind and if there is something wrong?',
      'faq_a13':
          'We know this is not pleasant but we need some feedback as to what might have happened on the road that caused you to be behind with your stops. Amazon asks us for this feedback because there is also a timelimit of which you should have delivered X stop, therefore Amazon needs to know why the remaining stops are behind the delivery schedule and with this information, improve future delivery efficiency.',

      'faq_q14': 'Why do we sometimes ask you to go help a fellow colleague?',
      'faq_a14':
          'Because many factors play a role in the colleagues delay such as bad internet connection in the area, traffic, blocked streets due to construction in the area which has made it difficult for the other driver to deliver on time, therefore your help is needed.',

      'faq_q15':
          'Do I immediately in my first day, start to deliver standart-route packages as other, more experienced delivery drivers?',
      'faq_a15':
          'No, obviously not that is not the case for you. At the beginning you will have a period of 14 work-days to put in practice what you have learned in the ride-along days with your trainer and adjust with the area, with the car, with the scanner and to learn the workflow proccess.\n'
          'With that said, for that time period of 14 days, Amazon will give you up to 50% less than normal packages and stops in your schedule.',

      'faq_q16':
          'What to do when an address is wrong and/or the location pin is not correct on the map?',
      'faq_a16':
          'First confirm that the pin is not correct by searching the address in google maps (is more accurate and is already installed on your scanner) and if it does not match, inform a dispatcher on duty with the errors.',

      'faq_q17': 'What are my daily tasks before I begin and after I end work?',
      'faq_a17':
          '1- When you come into the parking, first you make sure you are wearing the safety shoes and safety vest and Amazon uniform.\n'
          '2- Check if your scanner is fully charged and inform a dispatcher present in the moment if it is not charged.\n'
          '3- Check if there is anything wrong with the car.\n'
          '4- Start trip on Mentor app on your scanner.\n'
          '5- Post the picture of the car doashboard showing the current car mileage and daily trip (in the car) reset to 0.\n'
          '6- Get ready to start going down in the Waiting Area only 10 minutes before the planned hour of loading time, not any sooner.\n'
          '7- When in the Waiting area, turn off your car, start the Flex App and Timesheet. Please, not a minute earlier, especially the flex app. Do not forget the 10 minute timestamp.\n'
          '8- The lastly go to Loading Area with the Yard Marshall instructions. When you are in the Loading area, turn off your car and only leave the car AFTER you have heard the whistle from the Yard Marshall.\n'
          '9- After you have finished loading your car, start your car and start driving but only when the Yard Marshall instructs you to.\n'
          '10- After you have finished all of your stops, check the car fuel tank and if it is less than half remaining, please refill it.\n'
          '11- When you are at the station, please drop all of your remaining packages in the areas designated by Amazon, drop the bags in a timely manner\n'
          '12- When in parking, shut down the car and complete the Green Book (Tageskontrollblat), post the picture of the daily mileage you did during the day delivering, along with a picture of the Green Book.\n'
          '13- Shut down your car and please return your work bag to the designated area/van',

      'faq_q18':
          'Do I have to do anything when I change the van and take another van rather than the one I usually take?',
      'faq_a18':
          'You should make a video of it, capturing in detail every small damage the previous driver/s might have done, so it is not your fault in the next inspection of the car.',

      'faq_q19':
          'What should I do if the Flex app is constantly loading and slowing down my work flow?',
      'faq_a19':
          'First check if you have an active internet connection. To do so you can try to send a message to the current stop costumer and if it goes through then that means the internet connection is active. You can also check by opening another app in the scanner such as the browser and searching something on it.\n'
          'Steps you should follow if there isn ot an active internet connection:\n'
          '1- Restart your scanner. This should always be the first thing you try.\n'
          '2- Turn on/off airplane mode. This works most of the time without having to wait for the scanner to restart.\n'
          '3- As a very last resort, please try to share some hotspot from your personal phone for just 10 minutes max just for the system to refresh itself.\n'
          'You can also work offline but at some point you have to connect to the internet and be active. To work offline you must first download offline maps in the Flex app. To do so, you go to Settings - Offline Maps (last option) - Download DBY5 - Allow downloads with mobile connection.\n',

      'faq_q20':
          'What if the internet connection is active and the Flex app is still not working as it should?',
      'faq_a20':
          '1- Restart the scanner.\n'
          '2- Turn on/off airplane mode\n'
          '3- Exit from the app\n'
          '4- Turn off/on Location Services (GPS)\n'
          '5- Log out from Flex app and log-in again with the Credentials you use for the Mentor App.\n'
          '6- Check if the app needs to be updated.\n'
          'You should try these stepse one by one. If one does not work, please try the next down after it.',
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
      'header_good_afternoon': 'GUTEN TAG',
      'header_good_evening': 'GUTEN ABEND',
      'select_language': 'Sprache auswählen',
      'notifications': 'Benachrichtigungen',
      'no_notifications': 'Keine Benachrichtigungen',
      'nav_home': 'Home',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Hilfe',
      'nav_rules': 'Regeln',
      'nav_profile': 'Profil',
      'nav_tasks': 'Aufgaben',
      'driver_home_dispatcher': 'Dispatcher',
      'driver_home_shift_plan_title': 'Arbeitsplan',
      'driver_home_shift_plan_subtitle': 'Deine Schichten',
      'driver_home_scorecard_subtitle': 'Deine Leistungsübersicht',
      'driver_home_tasks_title': 'Aufgaben',
      'driver_home_tasks_subtitle': 'Offene To-Dos verwalten',
      'driver_home_academy_subtitle': 'Schulungen & Wissen',
      'driver_home_rules_title': 'Firmenregeln',
      'driver_home_rules_subtitle': 'Richtlinien & Vorschriften',
      'driver_notification_published_on': 'Veroeffentlicht {date}',
      'driver_home_vehicles_title': 'Fahrzeuge',
      'driver_home_vehicles_subtitle': 'Fahrzeugübersicht',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'Dein KI-Assistent',
      'driver_home_absence_title': 'Abwesenheit',
      'driver_home_absence_subtitle': 'Urlaub & Krankmeldung',
      'driver_home_incident_title': 'Unfallbericht',
      'driver_home_incident_subtitle': 'Unfall melden',
      'driver_home_new_badge': 'NEW',
      'driver_academy_title': 'DA Academy',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle':
          'Richtlinien zum Tageskontrollblatt',
      'driver_academy_safety_title': 'Safety Training',
      'driver_academy_safety_subtitle': 'Sicherheitsschulungen',
      'driver_academy_delivery_title': 'Amazon Delivery',
      'driver_academy_delivery_subtitle': 'Zustellprozesse & Abläufe',
      'driver_academy_app_title': 'CoDriver App',
      'driver_academy_app_subtitle': 'App-Funktionen & Anleitungen',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - Schulungsvideo',
      'driver_green_book_video_subtitle': 'Tippen zum Abspielen',
      'driver_green_book_start_test': 'Green Book Test starten',
      'driver_green_book_test_required': 'Test erforderlich',
      'driver_green_book_section1_title': 'Tageskontrollblatt - Green Book',
      'driver_green_book_section1_text':
          'Das Tageskontrollblatt (Green Book) ist ein verpflichtendes Dokument, das täglich vor Fahrtantritt ausgefüllt werden muss. Es dient der Überprüfung des Fahrzeugzustands und der Dokumentation sicherheitsrelevanter Punkte.',
      'driver_green_book_section1_b1':
          'Vor jeder Schicht vollständig ausfüllen.',
      'driver_green_book_section1_b2': 'Fahrzeugmängel sofort melden.',
      'driver_green_book_section1_b3': 'Unterschrift nicht vergessen.',
      'driver_green_book_section2_title': 'Konsequenzen bei Nichteinhaltung',
      'driver_green_book_section2_text':
          'Bei Verstößen gelten folgende Eskalationsstufen:',
      'driver_green_book_section2_b1':
          'Erste Verwarnung: Mündliche Ermahnung durch den Disponenten.',
      'driver_green_book_section2_b2':
          'Zweite Verwarnung: Schriftliche Abmahnung.',
      'driver_green_book_section2_b3':
          'Wiederholte Verstöße: Arbeitsrechtliche Konsequenzen bis zur Kündigung.',
      'driver_green_book_section3_title': 'Rechtliche Strafen',
      'driver_green_book_section3_text':
          'Das Führen eines Fahrzeugs ohne ordnungsgemäß ausgefülltes Tageskontrollblatt kann zu erheblichen rechtlichen Konsequenzen führen:',
      'driver_green_book_section3_b1':
          'Bußgeld: Bis zu 5.000 EUR für den Fahrer, bis zu 15.000 EUR für das Unternehmen.',
      'driver_green_book_section3_b2':
          'Fahrverbot: Möglicher Entzug der Fahrerlaubnis bei wiederholten Verstößen.',
      'driver_green_book_section3_b3':
          'Punkte in Flensburg: Eintragung im Fahreignungsregister möglich.',
      'driver_green_book_section3_b4':
          'Versicherungsschutz: Bei Unfall kann der Schutz entfallen.',
      'driver_green_book_test_title': 'Green Book Test',
      'driver_green_book_test_progress': 'Frage {current} von {total}',
      'driver_green_book_test_true': 'Richtig',
      'driver_green_book_test_false': 'Falsch',
      'driver_green_book_test_next': 'Weiter',
      'driver_green_book_test_submit': 'Test absenden',
      'driver_green_book_test_statement1':
          'Das Green Book muss vor jeder Schicht ausgefullt werden.',
      'driver_green_book_test_statement2':
          'Fahrzeugmangel konnen erst am Ende der Woche gemeldet werden.',
      'driver_green_book_test_statement3':
          'Die erste Konsequenz bei Nichteinhaltung ist eine mundliche Verwarnung.',
      'driver_green_book_test_statement4':
          'Zu den rechtlichen Strafen kann ein Bußgeld von bis zu 5.000 EUR fur den Fahrer gehoren.',
      'driver_green_book_test_statement5':
          'Der Versicherungsschutz bleibt immer unbeeinflusst, wenn das Green Book fehlt.',
      'driver_green_book_test_result_pass_title': 'Test bestanden',
      'driver_green_book_test_result_fail_title': 'Test nicht bestanden',
      'driver_green_book_test_result_pass_body':
          'Gut gemacht. Du hast {score}/{total} erreicht.',
      'driver_green_book_test_result_fail_body':
          'Du hast {score}/{total} erreicht. Bitte Abschnitt Green Book wiederholen und erneut versuchen.',
      'driver_green_book_test_retry': 'Erneut versuchen',
      'driver_green_book_test_close': 'Schliessen',
      'driver_green_book_test_back_to_green_book': 'Zuruck zum Green Book',
      'driver_green_book_test_no_questions':
          'Es sind noch keine Testfragen konfiguriert. Bitte kontaktiere deinen Dispatcher.',
      'driver_green_book_test_offline_fallback':
          'Live-Test-Synchronisierung fehlgeschlagen. Du kannst mit Fallback-Fragen fortfahren und das Laden erneut versuchen.',
      'admin_home_notification': 'Benachrichtigung',
      'admin_home_driver_fallback': 'Fahrer',
      'admin_home_not_confirmed_by': 'NICHT BESTAETIGT VON:',
      'admin_home_missing_loading': 'fehlt: ...',
      'admin_home_missing_unknown': 'fehlt: --',
      'admin_home_missing_count': 'fehlt: {count}',
      'admin_home_error_generic': 'Fehler: {error}',
      'admin_home_all_drivers_confirmed': 'Alle Fahrer haben bestaetigt.',
      'admin_home_close': 'Schliessen',
      'admin_home_last_week': 'Letzte Woche',
      'admin_home_not_logged_in': 'Nicht eingeloggt.',
      'admin_home_loading_reports': 'Berichte werden geladen...',
      'admin_home_no_reports_uploaded': 'Noch keine Berichte hochgeladen.',
      'admin_home_week_short': 'KW',
      'admin_home_month_prefix': 'MONAT',
      'admin_home_year_prefix': 'JAHR',
      'admin_home_loading_scores': 'Scores werden geladen...',
      'admin_home_name_fallback': 'Vorname Nachname',
      'admin_home_scorecard': 'Scorecard',
      'admin_home_company_score': 'UNTERNEHMENS-SCORE',
      'admin_home_of': 'von',
      'admin_home_best_driver': 'Bester Fahrer',
      'admin_home_worst_defender': 'Schlechtester Defender',
      'admin_home_notification_history': 'Benachrichtigungsverlauf',
      'admin_home_no_notifications_yet': 'Noch keine Benachrichtigungen.',
      'admin_home_notification_type_message': 'NEUE NACHRICHT',
      'admin_home_notification_type_academy': 'DA AKADEMIE',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'NEUE REGEL',
      'admin_home_edit_rule': 'Regel bearbeiten',
      'admin_home_title': 'Titel',
      'admin_home_body': 'Inhalt',
      'admin_home_cancel': 'Abbrechen',
      'admin_home_save': 'Speichern',
      'admin_home_title_or_body_required':
          'Titel oder Inhalt ist erforderlich.',
      'admin_home_notification_not_found': 'Benachrichtigung nicht gefunden.',
      'admin_home_rule_updated_for_drivers':
          'Regel fuer {count} Fahrer aktualisiert.',
      'admin_home_edit_failed': 'Bearbeiten fehlgeschlagen: {error}',
      'admin_home_delete_notification_question': 'Benachrichtigung loeschen?',
      'admin_home_delete_notification_body':
          'Diese Benachrichtigung wird fuer dich und alle Fahrer geloescht.',
      'admin_home_delete': 'Loeschen',
      'admin_home_notification_deleted': 'Benachrichtigung geloescht.',
      'admin_home_delete_failed': 'Loeschen fehlgeschlagen: {error}',
      'admin_home_options': 'Optionen',
      'admin_home_title_upper': 'TITEL',
      'admin_home_confirmed_by': 'bestaetigt von',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Service',
      'admin_home_accidents': 'Unfaelle',
      'admin_home_total': 'gesamt',
      'admin_home_active': 'aktiv',
      'admin_home_inactive': 'inaktiv',
      'admin_home_doc_id_card': 'Ausweis',
      'admin_home_doc_driving_license': 'Fuehrerschein',
      'admin_home_doc_residence_permit': 'Aufenthaltstitel',
      'admin_home_loading_drivers': 'Fahrer werden geladen...',
      'admin_home_no_drivers_yet': 'Noch keine Fahrer.',
      'admin_home_contract': 'Vertrag',
      'admin_home_last_day': 'letzter Tag',
      'admin_home_probation': 'Probezeit',
      'admin_home_ended': 'beendet',
      'admin_home_ends': 'endet',
      'admin_home_expired_by': 'abgelaufen am',
      'admin_home_loading_documents': 'Dokumente werden geladen...',
      'admin_home_driver_documents': 'Fahrerdokumente',
      'admin_home_expired_documents': 'Abgelaufene Dokumente',
      'admin_home_expired_soon': 'bald ablaufend',
      'admin_home_missing_documents_data': 'Fehlende Dokumente / Daten',
      'admin_home_total_missing': 'gesamt fehlend',
      'admin_home_driver_contracts': 'Fahrervertraege',
      'admin_home_last_day_soon': 'letzter Tag bald',
      'admin_home_no_items': 'Keine Eintraege',
      'admin_home_time_suffix': 'Uhr',
      'change_profile_photo': 'Profilfoto ändern',
      'profile_change_photo': 'Profilfoto ändern',
      'logout': 'Abmelden',
      'profile_logout': 'Abmelden',
      'pin_change_with_old':
          'Du kannst deine PIN nach Eingabe der alten PIN ändern.',
      'pin_forgot_contact_admin':
          'PIN vergessen? Bitte den Admin kontaktieren.',
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
      'dash_company_data_section': 'Daten als Unternehmen',
      'dash_company_data_show': 'Ergebnisse als Unternehmen anzeigen',
      'dash_company_data_hide': 'Unternehmenskategorien ausblenden',

      'dash_rank': 'Rang',
      'dash_score': 'Score',
      'dash_name': 'Name',

      'dash_delivered': 'Zugestellt',
      'dash_rank_in_aion': 'Rang in AION',
      'dash_rank_of_total': '{rank} von {total}',

      'dash_no_my_score_week':
          'Kein Score für deine Fahrer-ID in dieser Woche gefunden.',
      'dash_all_status': 'Alle Status',
      'dash_search_name_or_id': 'Name oder Transporter-ID suchen...',
      'dash_upload_driver_csv': 'Fahrer-CSV hochladen',

      'scorecard_overview_title': 'SCORE CARD DASHBOARD',
      'scorecard_overview_overview_suffix': '— Übersicht',
      'scorecard_overview_upload_pdf': 'SCORECARD-PDF HOCHLADEN',
      'scorecard_overview_upload_prompt': 'Lade deine Scorecard-PDF hoch',
      'scorecard_overview_choose_file': 'Datei auswählen',
      'scorecard_overview_summary_title': 'Scorecard-Zusammenfassung',
      'scorecard_overview_no_reports_yet':
          'Noch keine Berichte. Lade deine erste Scorecard-PDF hoch, um zu starten.',
      'scorecard_overview_chart_title': 'Scorecard-Übersicht',
      'scorecard_overview_best_drivers': 'Beste Fahrer',
      'scorecard_overview_no_reports_available': 'Keine Berichte verfügbar.',
      'scorecard_overview_no_drivers_period':
          'Keine Fahrer für diesen Zeitraum gefunden.',
      'scorecard_overview_select_station': 'Station auswählen',
      'scorecard_overview_all_stations': 'Alle Stationen',
      'scorecard_overview_select_period': 'Zeitraum auswählen',
      'scorecard_overview_best_drivers_year': 'Beste Fahrer des Jahres',
      'scorecard_overview_best_drivers_month': 'Beste Fahrer des Monats',
      'scorecard_overview_station': 'Station',
      'scorecard_overview_station_code': 'Station {code}',
      'scorecard_overview_upload_success_one':
          '1 Scorecard analysiert und gespeichert. Dashboard aktualisiert.',
      'scorecard_overview_upload_success_many':
          '{count} Scorecards analysiert und gespeichert. Dashboard aktualisiert.',
      'scorecard_overview_upload_parse_failed':
          'Upload/Analyse fehlgeschlagen: {error}',
      'scorecard_overview_no_file_bytes': 'Keine Dateidaten',
      'scorecard_overview_csv_updated':
          'Fahrernamen in all deinen Berichten aktualisiert.',
      'scorecard_overview_csv_failed': 'CSV-Import fehlgeschlagen: {error}',
      'scorecard_overview_delete_report_q': 'Bericht löschen?',
      'scorecard_overview_delete_report_body':
          'Dadurch wird der Bericht "{title}" und alle Score-Einträge dieser Woche gelöscht.',
      'scorecard_overview_deleted': 'Bericht und Wochen-Scores gelöscht.',
      'scorecard_overview_delete_failed': 'Löschen fehlgeschlagen: {error}',
      'scorecard_overview_more': 'Mehr',
      'scorecard_overview_delete_report_menu': 'Bericht löschen',
      'scorecard_overview_upload_processing':
          'Scorecards werden hochgeladen und verarbeitet...',
      'scorecard_overview_row_title': 'Score Card {year} KW {week}',
      'scorecard_overview_reliability_score': 'Zuverlässigkeits-Score',
      'scorecard_overview_from_last_week': 'gegenüber letzter Woche',
      'scorecard_overview_from_last_year': 'gegenüber letztem Jahr',

      'kpi_score': 'SCORE',
      'kpi_value': 'WERT',
      'kpi_pro_tip': 'PRO TIPP',

      'kpi_title_dcr': 'Delivery Completion Rate',
      'kpi_title_dnr': 'Delivery Success Conditions',
      'kpi_title_lor': 'Lost on Road',
      'kpi_title_pod': 'Picture on Delivery',
      'kpi_title_cc': 'Customer Contact',
      'kpi_title_ce': 'Customer Escalation',
      'kpi_title_cdf': 'Customer Delivery Feedback',

      'kpi_desc_dcr':
          'Je höher der Wert, desto besser. Um eine 100 % Erfolgsquote zu erreichen, wird empfohlen, eine erneute Zustellung* bei fehlgeschlagener Lieferung durchzuführen. ',
      'kpi_tip_dcr':
          'Beispiel: Wenn du an einem Tag ein Paket aus irgendeinem Grund nicht zustellen kannst und die Zustellung später am selben Tag erneut versuchst, wird dein DCR-Wert höher und näher an 100 % liegen, selbst wenn auch der zweite Zustellversuch nicht erfolgreich ist.',
      'kpi_desc_dnr':
          'DSC DPMO (Delivery Success Conditions)\n(früher DNR – Delivery Not Received)\n\nJe niedriger der Wert, desto besser.\n\nDiese Kennzahl misst, wie korrekt und nachvollziehbar Zustellungen durchgeführt werden.\n\nGrundregeln der Zustellung:\n- Zustellung an die richtige Person oder den richtigen Ort\n- Zustellungen an Kunden, Haushaltsmitglieder, Nachbarn oder Rezeptionisten sind bei korrekter Durchführung risikoarm\n- Immer den korrekten Scan-/Grund-Code verwenden, damit Kunden korrekte Benachrichtigungen erhalten\n\nPostraum- / Briefkastenzustellungen:\n- Standard-Workflow einhalten\n- Pakete müssen vollständig im Briefkasten oder Postschlitz sein und dürfen nicht herausragen\n- Den genauesten verfügbaren Scan verwenden\n\nKorrekte Adresse & Geofence:\n- Zustellung innerhalb von 25 Metern des korrekten Geofence\n- Name und Adresse in der App immer mit dem Paketlabel und dem Gebäude abgleichen\n- Wenn der Geocode falsch erscheint, diesen über SDS melden\n\nFoto bei Zustellung (POD):\n- Immer ein klares Foto aufnehmen, wenn dazu aufgefordert\n- Paket und Umgebung müssen gut sichtbar sein\n- Besonders wichtig bei unbeaufsichtigten Zustellungen und für das Kundenvertrauen\n\nZustellpräferenzen einhalten:\n- Kundenanweisungen in der App befolgen, sofern sie sicher sind\n- Wenn Anweisungen unsicher sind, den Kunden kontaktieren\n- Nur genehmigte sichere Ablageorte aus der App verwenden\n\nGleichzeitige / Gruppen-Stopps:\n- \"Alle auswählen\" nur verwenden, wenn mehrere Pakete an dieselbe Person oder denselben Ort geliefert werden (z. B. Rezeption)\n- Empfängername und Unterschrift korrekt erfassen',

      'kpi_tip_dnr':
          'Wichtiger Hinweis:\n\nWiederholt hohe Werte bei DSC DPMO deuten auf fehlerhafte oder riskante Zustellungen hin.\n\n- Häufige Abweichungen können von Amazon als möglicher Diebstahl interpretiert werden\n- Dies kann ein Loss-Prevention-Verfahren auslösen\n- Im schlimmsten Fall kann dies zur Beendigung der Zusammenarbeit führen\n\nSorgfältige Scans, korrekte Fotos und das Einhalten aller Zustellregeln schützen dich und dein Team.',

      'kpi_desc_lor':
          'LoR (Lost on Road)\n\nJe niedriger der Wert, desto besser.\n\nDiese Kennzahl zeigt, ob am Ende der Route alle nicht zugestellten Pakete korrekt erfasst wurden.\n\nAm Ende der Route:\n- Im Scanner prüfen, wie viele Pakete zurückzugeben sind\n- Sicherstellen, dass diese Zahl exakt mit den Paketen im Fahrzeug übereinstimmt',

      'kpi_tip_lor':
          'Wichtiger Hinweis:\n\nDies ist die Kategorie mit dem höchsten Diebstahlverdacht.\n\nAbweichungen zwischen Scanner und Fahrzeugbestand können als schwerwiegender Fehler gewertet werden und zu internen Prüfungen oder weiteren Konsequenzen führen.',

      'kpi_desc_pod':
          'PoD (Picture on Delivery)\n\nJe höher der Wert, desto besser.\n\nDiese Spalte zeigt Pakete, für die ein Foto aufgenommen wurde, die jedoch als Ungültig oder Unsicher markiert wurden.\n\nHäufige Gründe für POD-Ablehnung:\n1. Paketlabel mit Kundendaten sichtbar (Paket muss umgedreht werden)\n2. Unscharfes Foto\n3. Person auf dem Foto sichtbar\n4. Kein Paket auf dem Foto erkennbar\n5. Paket im Fahrzeug\n6. Paket in der Hand\n7. Paket zu nah an der Kamera\n8. Foto zu dunkel',

      'kpi_tip_pod':
          'Dies sollte die einfachste Kategorie sein\nZielwert: 100 %\nVerbessert den Gesamt-Score erheblich',

      'pod_quality_title': 'POD-Qualität',
      'pod_quality_success': 'Erfolg',
      'pod_quality_rejects': 'Ablehnungen',
      'pod_quality_opp': 'Chancen',
      'pod_quality_bypass': 'Übersprungen',
      'pod_quality_blurry': 'Unscharf',
      'pod_quality_too_dark': 'Zu dunkel',
      'pod_quality_no_package': 'Kein Paket',
      'pod_quality_in_car': 'Im Auto',
      'pod_quality_too_close': 'Zu nah',
      'pod_quality_shell_week_title': 'POD-QUALITAET - WOCHE',
      'pod_quality_week_label': 'Woche {week}',
      'pod_quality_dashboard_title': 'POD-QUALITAET DASHBOARD',
      'pod_quality_upload_pdf': 'PDF hochladen',
      'pod_quality_no_reports_uploaded':
          'Noch keine POD-Qualitaetsberichte. Lade eine POD-Qualitaet-PDF hoch, um zu starten.',
      'pod_quality_upload_success_one':
          '1 POD-Qualitaetsbericht analysiert und gespeichert.',
      'pod_quality_upload_success_many':
          '{count} POD-Qualitaetsberichte analysiert und gespeichert.',
      'pod_quality_upload_parse_failed':
          'Upload/Analyse fehlgeschlagen: {error}',
      'pod_quality_rejects_breakdown': 'Aufschluesselung der Ablehnungen',
      'pod_quality_no_data_week': 'Keine POD-Daten fuer diese Woche.',
      'pod_quality_drivers': 'Fahrer',
      'pod_quality_entries_count': '{count} Eintraege',

      'kpi_desc_cc':
          'CC (Customer Contact)\n\nJe höher der Wert, desto besser.\n\nExtrem wichtig:\nDu musst IMMER eine „Kein sicherer Ablageort“- oder „Adresse nicht gefunden“-Nachricht senden, jedes Mal, wenn du ein Paket nicht zustellen kannst, weil:\n\n- der Kunde nicht zu Hause ist oder\n- die Adresse nicht gefunden werden kann',

      'kpi_tip_cc':
          'Für jedes Szenario gibt es eine automatische Standardnachricht in der App.',

      'kpi_desc_ce':
          'CE (Customer Escalation)\n\nJe niedriger der Wert, desto besser.\nDie schlechteste Kategorie von allen.\n\nKunden eskalieren, wenn Zustellanweisungen nicht eingehalten werden.\n\nDer Fahrer ist immer verantwortlich\nEinsprüche sind ohne sehr starke Beweise nahezu unmöglich\nHat den stärksten Einfluss auf deine Scorecard\n\nSo vermeidest du CE\n\nEs ist gegen die Zustellrichtlinien, Pakete ohne Genehmigung an unsicheren oder unbeaufsichtigten Orten abzulegen\n\nDelivery Associates müssen:\n- Klingeln / Gegensprechanlage benutzen oder klopfen\n- Dem Kunden ausreichend Zeit zum Antworten geben\n\nWenn der Kunde nicht erreichbar ist und kein sicherer Ablageort hinterlegt wurde:\n- Kunden zweimal anrufen\n- Eine Textnachricht senden\n- Driver Support kontaktieren, wenn kein Kontakt möglich ist\n\nFalls notwendig:\n- Paket scannen als „Zustellung fehlgeschlagen – Kunde nicht verfügbar“\n- Zustellung gemäß Richtlinie erneut versuchen',

      'kpi_tip_ce':
          'Keine Pakete an unsicheren oder nicht genehmigten Orten ablegen\nImmer die korrekten Versand- und Zustellprozesse einhalten',

      'kpi_desc_cdf':
          'CDF DPMO (Customer Delivery Feedback)\n\nJe niedriger der Wert, desto besser.\n\nLevel 1 (L1)\n- Kunde bewertet die Zustellung als „Großartig“ (👍) oder „Nicht so gut“ (👎)\n\nLevel 2 (L2)\n- Zusätzliche Rückmeldung, warum die Erfahrung gut oder schlecht war',

      'kpi_tip_cdf': 'CDF wird ausschließlich auf L1-Ebene berechnet',

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

      // =========================
      // GERMAN (de) – FAQ keys
      // =========================

      // FAQs
      'faq_title': 'Häufig gestellte Fragen',
      'faq_search_hint': 'Fragen suchen',
      'faq_empty': 'Keine passenden FAQs gefunden.',
      'driver_tasks_error': 'Fehler: {error}',
      'driver_tasks_no_tasks': 'Noch keine Aufgaben zugewiesen.',
      'driver_tasks_update_status': 'Status aktualisieren',
      'driver_tasks_confirm_completed': 'Als erledigt bestaetigen',
      'driver_tasks_set_completed_first':
          'Setze den Status zuerst auf "Abgeschlossen".',
      'driver_tasks_completion_confirmed': 'Erledigung bestaetigt.',
      'driver_tasks_failed_update_status':
          'Status konnte nicht aktualisiert werden: {error}',
      'driver_tasks_failed_confirm_task':
          'Aufgabe konnte nicht bestaetigt werden: {error}',
      'driver_tasks_status_confirmed_by_you': 'Status von dir bestaetigt.',
      'driver_tasks_confirm_when_fully_done':
          'Bitte bestaetige, wenn diese Aufgabe vollstaendig erledigt ist.',
      'driver_tasks_status_pending': 'Ausstehend',
      'driver_tasks_status_in_progress': 'In Bearbeitung',
      'driver_tasks_status_completed': 'Abgeschlossen',
      'faq_green_book_video_title': 'Green-Book Videoanleitung',
      'faq_green_book_video_subtitle':
          'Sieh dir Schritt für Schritt an, wie das Green Book ausgefüllt wird',
      'faq_green_book_video_action': 'Video abspielen',
      'faq_green_book_video_missing':
          'Der Green-Book-Videolink ist noch nicht konfiguriert.',
      'faq_green_book_video_open_failed':
          'Der Green-Book-Videolink konnte nicht geöffnet werden.',

      'faq_q1': 'Was ist bei deiner täglichen Arbeit am wichtigsten?',
      'faq_a1': 'Pakete mit Qualität und gutem Verhalten zuzustellen.',

      'faq_q2': 'Was solltest du bei Problemen mit dem Kunden NICHT tun?',
      'faq_a2':
          'Versuche NICHT, die Situation selbst zu lösen, sondern informiere stattdessen den Dispatcher im Dienst. Wir sprechen mit dem Kunden für dich und versuchen, negative Folgen von Amazon durch Kundenbeschwerden zu vermeiden. Wir sind für dich da!',

      'faq_q3':
          'Was, wenn die Situation bereits eskaliert ist und der Kunde aus irgendeinem Grund unzufrieden ist?',
      'faq_a3':
          'Es ist nie zu spät, Fehler zu korrigieren. Ruf uns trotzdem an und wir versuchen, den Fehler mit dem Kunden zu klären. Besser spät als nie.',

      'faq_q4':
          'Was ist wichtiger: Quantität (so schnell wie möglich viele Stopps) oder Qualität?',
      'faq_a4':
          'Qualität! Immer Qualität! Folge den Kundenanweisungen und lege das Paket NICHT an unsicheren Orten ab, nur weil du mit den Stopps im Rückstand bist.',

      'faq_q5':
          'Was ist, wenn ich mich auf Qualität konzentriere und dadurch mit meinen Stopps in Rückstand gerate?',
      'faq_a5':
          'Du wirst deine Stopps beenden – so oder so. Wir versuchen, Hilfe zu schicken, aber nur, wenn wir es für sinnvoll halten.',

      'faq_q6': 'Was ist eine Scorecard und was ist ein DNR?',
      'faq_a6': 'Gut, dass du fragst.',

      // 7 – Weekly scorecard
      'faq_q7': 'Wöchentliche Scorecard',
      'faq_a7':
          'Die wöchentliche Scorecard gibt uns einen schnellen, klaren Überblick, wie das Team bei unseren wichtigsten Zielen abschneidet. '
          'Sie hilft uns zu erkennen, was gut läuft, wo wir zurückliegen und worauf wir uns in der kommenden Woche konzentrieren müssen.\n\n'
          'Die Gesamtbewertungen sind wie folgt:\n'
          '• Fantastic Plus: >93% (außergewöhnliche Leistung)\n'
          '• Fantastic: 85% – 92,9%\n'
          '• Great: 70% – 84,9%\n'
          '• Fair: 50% – 69,9%\n'
          '• Poor: <50%',

      'faq_q7_1': 'DNR-Tab\nDelivered Not Received',
      'faq_a7_1':
          'Das passiert, wenn du ein Paket zugestellt und mit „Swipe to finish“ bestätigt hast, der Kunde das Paket aber nicht erhalten hat – aus verschiedenen Gründen: '
          'Paketdiebstahl, leere Verpackung oder Zustellung an die falsche Adresse.\n'
          'Jeden Dienstag erhältst du Fotos zu jedem DNR, den du in der Woche hattest.',

      'faq_q7_1_1':
          'Wie kann ich das vermeiden und wie wichtig ist das für die wöchentliche Scorecard?',
      'faq_a7_1_1':
          'Das ist sehr wichtig. Um es zu vermeiden, informiere den Kunden vorher, dass du bald ankommst, und klingele NUR bei dem Klingelschild mit seinem Namen.',

      'faq_q7_1_2': 'Wie vermeide ich Paketverluste?',
      'faq_a7_1_2':
          'Versuche immer, die Pakete dem Kunden persönlich zu übergeben. Wenn das nicht möglich ist, sende eine Nachricht und informiere ihn, wo das Paket abgelegt wurde, z. B. in der Garage, unter der Treppe, im Schuppen, hinter der Blumenvase usw.\n'
          'Wenn du nicht glaubst, dass es sicher ist, das Paket unbeaufsichtigt zu lassen, nimm es bitte lieber wieder mit und versuche es später erneut. Das ist SEHR wichtig.',

      'faq_q7_1_3': 'Woran erkenne ich, ob ein Ort sicher ist oder nicht?',
      'faq_a7_1_3':
          'Instinkt und gesunder Menschenverstand. Wenn ein Gebäude 20–30 Stockwerke hat und du das Paket bei den Briefkästen ablegst, ist die Wahrscheinlichkeit für Diebstahl deutlich höher als bei einem Einfamilienhaus.\n'
          'Außerdem posten wir jeden Morgen ein Bild mit Adressen, bei denen eine hohe Wahrscheinlichkeit für Diebstahl und Kundenbeschwerden besteht – basierend auf bisherigen Zustellungen und Statistiken.',

      'faq_q7_1_4':
          'Was passiert, wenn ein Paket verloren geht oder gestohlen wird – wie wirkt sich das auf meinen Score aus?',
      'faq_a7_1_4':
          'Sehr negativ. Das kann dich mit mindestens 30% treffen – und schon ein einziges Paket kann dir mindestens 600 Punkte kosten. Je mehr Punkte du in der Scorecard unter deinem Namen siehst, desto schlechter ist es. Je mehr Pakete du pro Arbeitswoche zustellst, desto weniger Punkte verlierst du pro Vorfall. Die verlorenen Punkte variieren auch je nach Preis des Artikels: Je teurer, desto mehr Punkteverlust.\n'
          'Wichtig ist außerdem: Wenn du regelmäßig eine hohe Anzahl verlorener Pakete hast, müssen wir dich ggf. freistellen, weil Amazon früher oder später Paketdiebstahl vermuten könnte. Das ist sehr gefährlich.',

      // CC
      'faq_q7_2': 'CC-Tab\nContact Compliance',
      'faq_a7_2':
          'Das bedeutet, wie oft du den Kunden wegen seiner Lieferung kontaktierst – per Nachricht oder Anruf. Je weniger du den Kunden kontaktierst, desto weniger Score bekommst du in der Scorecard. Wir sollten diesen Bereich so hoch wie möglich halten, weil er zu den einfachsten Kategorien gehört und dir beim Gesamtscore sehr hilft.',

      'faq_q7_2_1': 'Warum sollte ich das machen?',
      'faq_a7_2_1':
          'Pakete zuzustellen ist nicht nur „Drop & Go“. Du solltest den Kunden vorher informieren und fragen, wo er das Paket gerne zugestellt haben möchte.',

      'faq_q7_2_2': 'Wie verbessere ich meinen CC-Score?',
      'faq_a7_2_2':
          'Danke für die Frage. Ganz einfach: durch Anrufe und vor allem durch Nachrichten an den Kunden bei jedem Stopp.',

      // CE
      'faq_q7_3': 'CE-Tab\nKundeneskalation',
      'faq_a7_3':
          'Du erinnerst dich, wie stark DNR deine Scores beeinflusst? Das hier ist mindestens doppelt so schlimm, und du riskierst auch deinen Job – je nachdem, wie schlimm die Situation war.',

      'faq_q7_3_1': 'Wie kann ich das vermeiden?',
      'faq_a7_3_1':
          'Indem du immer die Kundenanweisungen befolgst. Wenn ein Fehler passiert, entschuldige dich bitte zuerst. Wenn der Kunde wütend ist, bitte ihn um eine Minute Zeit, damit er mit uns sprechen kann, während du uns anrufst. '
          'Nach Abschnitt 2 solltest du inzwischen wissen, dass es am besten ist, solche Fälle von uns klären zu lassen.',

      // POD
      'faq_q7_4': 'POD-Tab\nFoto bei Zustellung',
      'faq_a7_4':
          'Diese Spalte zeigt eine Liste von Paketen, die für POD-Fotos geeignet sind, bei denen Fotos gemacht wurden, die jedoch entweder „Ungültig“ oder „Nicht sicher“ waren. Gründe für die Ablehnung können sein:\n'
          '1- Paketlabel mit Kundendaten ist auf dem Foto sichtbar. Das Paket muss vor dem Foto umgedreht werden.\n'
          '2- Unscharfes Foto\n'
          '3- Person auf dem Foto sichtbar\n'
          '4- Kein Paket auf dem Foto erkennbar\n'
          '5- Paket im Auto\n'
          '6- Paket in der Hand\n'
          '7- Paket im Briefkasten\n'
          '8- Foto zu nah\n'
          '9- Foto zu dunkel.\n'
          'Das sollte immer der einfachste Bereich sein, in dem du 100% erreichen solltest – und es verbessert deinen Gesamtscore.',

      // LoR
      'faq_q7_5': 'LoR-Tab\nLost on Road',
      'faq_a7_5':
          'Du wirst bestraft, wenn du ein Paket beim Laden gescannt hast und es am Ende der Schicht bei einer nicht erfolgreichen Zustellung nicht zurückgegeben wird. Dann gilt das Paket als verloren und du verlierst ähnlich viele Punkte wie bei einem DNR. '
          'Zähle daher die zurückgebrachten Pakete sorgfältig und stelle sicher, dass sie mit den Paketen im Scanner übereinstimmen. Du findest das unter: Today’s Itinerary – Summary – Problems. '
          'Wenn es nicht übereinstimmt, informiere bitte den Dispatcher im Dienst, bevor du die Arbeit in der Amazon-App beendest.',

      // DCR
      'faq_q7_6': 'DCR-Tab\nDelivery Completion Rate',
      'faq_a7_6':
          'Zeigt deine Fähigkeit, Pakete zuzustellen. Es verfolgt den Prozentsatz der Zustellungen, die wie geplant abgeschlossen wurden, und hilft uns, die Effizienz und Zuverlässigkeit unserer Zustellungen zu messen. '
          'Es macht Probleme sichtbar wie Verspätungen, fehlgeschlagene Zustellversuche oder Routing-Probleme. Dieser Wert sollte immer so hoch wie möglich sein. '
          'Dazu solltest du jeden Tag Reattempts machen und Rückgaben so weit wie möglich vermeiden.',

      // CDF
      'faq_q7_7': 'CDF-Tab (früher: DEX)\nKunden-Lieferfeedback',
      'faq_a7_7':
          'Erfasst die Erfahrung des Empfängers mit dem Zustellprozess, einschließlich Pünktlichkeit, Zustand der Ware und Professionalität des Fahrers. '
          'Es hilft uns, Stärken und Verbesserungsmöglichkeiten zu erkennen. Am Ende der Zustellung erhält der Kunde eine E-Mail von Amazon zur Liefererfahrung mit Fragen wie:\n'
          '1) Wurde dein Paket pünktlich zugestellt?\n'
          'Ja / Nein\n'
          '2) Wurde das Paket an einem sicheren Ort abgelegt?\n'
          'Ja / Nein\n'
          '3) War das Paket bei Ankunft in gutem Zustand?\n'
          'Ja / Nein\n'
          '4) Wie zufrieden bist du insgesamt mit der Lieferung?\n'
          'Sehr zufrieden / Zufrieden / Neutral / Unzufrieden / Sehr unzufrieden\n'
          '5) Wie bewertest du Kommunikation und Tracking-Updates für diese Lieferung?\n'
          'Ausgezeichnet / Gut / Mittel / Schlecht\n'
          '6) War die Zustellperson höflich und professionell?\n'
          'Ja / Nein / Nicht zutreffend (kontaktlose Zustellung)\n'
          '7) Hast du Kommentare zu deiner Liefererfahrung?\n'
          '(Zusätzliche Kundenkommentare)',

      'faq_q7_8':
          'Was sollte ich bezüglich der Scorecard im Hinterkopf behalten?',
      'faq_a7_8':
          'Qualität und Effizienz bringen dich weit. Gute Scores sind gut für dich, für die Firma und für das gesamte Team. Kundenzufriedenheit ist sehr wichtig, und gute Scores werden mit einem Bonus der Firma belohnt.\n'
          'Gib dein Bestes, bekomme das Beste.',

      // 8+
      'faq_q8': 'In welchen anderen Bereichen sollte ich vorsichtig sein?',
      'faq_a8':
          'Achte auf dich selbst: Fahre sicher, vermeide Verletzungen und vermeide Hunde bzw. Hundebisse. Sei vorsichtig mit Arbeitsausrüstung wie dem täglichen Fahrzeug, dem Arbeitsscanner/Telefon und komme zur Arbeit mit Sicherheitsschuhen und Sicherheitsweste sowie Amazon-Jacke oder T-Shirt (je nach Wetter).',

      'faq_q9':
          'Was passiert, wenn ich einen Unfall habe oder das Arbeitsfahrzeug beschädige?',
      'faq_a9':
          'Zuerst stelle sicher, dass du in Ordnung bist und nicht schwer verletzt wurdest. '
          'Wenn wir feststellen, dass Unfälle durch Fahrlässigkeit passieren – z. B. Ablenkungen wie Handynutzung während der Fahrt – haftest du persönlich für den gesamten Schaden. Außerdem erhältst du einen Polizeibericht, was sogar zu einem Führerscheinentzug führen kann. Das kann auch ein Grund für eine sofortige Kündigung sein. '
          'Andernfalls wirst du „nur“ für 2 Monate von den wöchentlichen Scorecard-Boni ausgeschlossen. '
          'Im Falle eines Vorfalls bist du verpflichtet, uns sofort zu informieren und uns Uhrzeit, Ort, ob private oder öffentliche Sachen beschädigt wurden (z. B. Wände, Zäune, Laternen, Menschen und/oder Tiere), sowie Fotos der Fahrzeugschäden zu senden.',

      'faq_q10': 'Was mache ich, wenn Pakete beschädigt und/oder fehlend sind?',
      'faq_a10':
          'Wenn ein Paket beschädigt ist, kannst du es als beschädigt buchen und zur Station zurückbringen. Wenn es sich um ein Flüssigkeitspaket handelt, das andere Pakete beschädigt hat, mache bitte ein Foto von allen beschädigten Paketen und sende es dem Dispatcher im Dienst. Wir melden es dann für dich an Amazon.\n'
          'Wenn ein Paket fehlt, kannst du es als fehlend markieren/buchen – außer es hat ein OTP. Dann musst du es ZUERST bei uns melden, bevor du es als fehlend markierst. Das ist SEHR wichtig.',

      'faq_q11': 'Was ist ein OTP (One-Time Password) Paket?',
      'faq_a11':
          'Das ist ein teurer Artikel, bei dem Amazon verlangt, dass der Kunde dem Fahrer ein Einmalpasswort (OTP) gibt, bevor das Paket zugestellt wird – um sicherzustellen, dass es an die richtige Person zugestellt wird. '
          'Du musst bei solchen Paketen besonders sorgfältig sein, sie nicht unbeaufsichtigt lassen und sie nur dem Kunden übergeben, der dir das Passwort gegeben hat.',

      'faq_q12':
          'Warum sagen wir dir immer wieder, du sollst langsamer machen und nicht schneller fahren?',
      'faq_a12':
          'Uns gefällt das auch nicht, aber so funktioniert das System. Wir müssen dem Algorithmus folgen und eine vorgegebene Anzahl Stopps pro Stunde einhalten, damit wir in Zukunft mehr Routen bekommen und du mehr arbeiten kannst statt frei zu haben.\n'
          'Außerdem riskierst du durch zu schnelles Arbeiten einen DNR und verlierst Punkte – sowohl für dich als auch für die Firma – in der wöchentlichen Scorecard.',

      'faq_q13':
          'Warum fragen dich die Dispatcher manchmal, warum du zurückliegst und ob etwas nicht stimmt?',
      'faq_a13':
          'Wir wissen, dass das unangenehm ist, aber wir brauchen Feedback, was auf der Straße passiert ist, sodass du mit deinen Stopps in Rückstand geraten bist. Amazon fragt uns nach diesem Feedback, weil es auch ein Zeitlimit gibt, bis zu dem du X Stopps erledigt haben solltest. Mit diesen Informationen kann Amazon zukünftige Zustelleffizienz verbessern.',

      'faq_q14': 'Warum bitten wir dich manchmal, einem Kollegen zu helfen?',
      'faq_a14':
          'Weil viele Faktoren eine Rolle spielen können, warum ein Kollege zurückliegt – z. B. schlechte Internetverbindung, Verkehr, gesperrte Straßen durch Baustellen. Dann wird deine Hilfe benötigt.',

      'faq_q15':
          'Beginne ich am ersten Tag sofort mit Standard-Routen wie erfahrene Fahrer?',
      'faq_a15':
          'Nein, natürlich nicht. Am Anfang hast du eine Phase von 14 Arbeitstagen, um das Gelernte aus den Ride-Along-Tagen mit deinem Trainer umzusetzen und dich an Gebiet, Fahrzeug, Scanner und Workflow zu gewöhnen.\n'
          'In dieser Zeit gibt Amazon dir bis zu 50% weniger Pakete und Stopps als normal.',

      'faq_q16':
          'Was tun, wenn eine Adresse falsch ist und/oder der Standort-Pin auf der Karte nicht stimmt?',
      'faq_a16':
          'Bestätige zuerst, dass der Pin nicht stimmt, indem du die Adresse in Google Maps suchst (ist genauer und auf deinem Scanner installiert). Wenn es nicht passt, informiere den Dispatcher im Dienst über die Fehler.',

      'faq_q17':
          'Was sind meine täglichen Aufgaben, bevor ich starte und nachdem ich die Arbeit beende?',
      'faq_a17':
          '1- Wenn du auf den Parkplatz kommst, stelle zuerst sicher, dass du Sicherheitsschuhe, Sicherheitsweste und Amazon-Uniform trägst.\n'
          '2- Prüfe, ob dein Scanner vollständig geladen ist, und informiere einen Dispatcher vor Ort, wenn er nicht geladen ist.\n'
          '3- Prüfe, ob am Fahrzeug etwas nicht stimmt.\n'
          '4- Starte die Fahrt in der Mentor-App auf deinem Scanner.\n'
          '5- Poste ein Foto vom Armaturenbrett mit aktuellem Kilometerstand und dem Tages-Trip (im Auto) auf 0 zurückgesetzt.\n'
          '6- Gehe erst 10 Minuten vor der geplanten Ladezeit in den Waiting Area – nicht früher.\n'
          '7- Im Waiting Area: Motor aus, Flex App und Timesheet starten. Bitte keine Minute früher, besonders die Flex App. Den 10-Minuten-Zeitstempel nicht vergessen.\n'
          '8- Dann in den Loading Area nach Anweisung des Yard Marshalls. Im Loading Area Motor aus und das Auto erst verlassen, NACHDEM du den Pfiff des Yard Marshalls gehört hast.\n'
          '9- Nach dem Laden: Motor starten und erst losfahren, wenn der Yard Marshall es anweist.\n'
          '10- Nach allen Stopps: Tank prüfen. Wenn weniger als halb voll, bitte nachtanken.\n'
          '11- An der Station: verbleibende Pakete in die von Amazon vorgesehenen Bereiche ablegen, Taschen rechtzeitig abgeben.\n'
          '12- Auf dem Parkplatz: Motor aus, Green Book (Tageskontrollblatt) ausfüllen, Foto vom Tageskilometerstand posten sowie ein Foto vom Green Book.\n'
          '13- Motor aus und die Arbeits-Tasche bitte in den dafür vorgesehenen Bereich zurücklegen.',

      'faq_q18':
          'Muss ich etwas beachten, wenn ich das Fahrzeug wechsle und ein anderes nehme als sonst?',
      'faq_a18':
          'Du solltest ein Video machen, das jeden kleinen Schaden im Detail zeigt, den der/die Fahrer vor dir verursacht haben könnten, damit es bei der nächsten Kontrolle nicht als dein Fehler gilt.',

      'faq_q19':
          'Was tun, wenn die Flex-App ständig lädt und meinen Workflow verlangsamt?',
      'faq_a19':
          'Prüfe zuerst, ob du eine aktive Internetverbindung hast. Das kannst du testen, indem du dem Kunden am aktuellen Stopp eine Nachricht schickst. Wenn sie durchgeht, ist das Internet aktiv. Du kannst auch eine andere App öffnen (z. B. Browser) und etwas suchen.\n'
          'Schritte, wenn keine aktive Internetverbindung besteht:\n'
          '1- Scanner neu starten. Das sollte immer das Erste sein.\n'
          '2- Flugmodus ein/aus. Das funktioniert oft, ohne auf einen Neustart zu warten.\n'
          '3- Als allerletzte Option: Teile maximal 10 Minuten Hotspot von deinem privaten Handy, damit sich das System aktualisieren kann.\n'
          'Du kannst auch offline arbeiten, aber irgendwann musst du wieder online sein. Um offline zu arbeiten, musst du zuerst Offline-Karten in der Flex App herunterladen: Settings – Offline Maps (letzte Option) – Download DBY5 – Allow downloads with mobile connection.\n',

      'faq_q20':
          'Was, wenn die Internetverbindung aktiv ist, die Flex-App aber trotzdem nicht richtig funktioniert?',
      'faq_a20':
          '1- Scanner neu starten.\n'
          '2- Flugmodus ein/aus\n'
          '3- App schließen\n'
          '4- Standortdienste (GPS) aus/an\n'
          '5- Aus der Flex App ausloggen und wieder einloggen (mit denselben Zugangsdaten wie in der Mentor App).\n'
          '6- Prüfen, ob ein Update verfügbar ist.\n'
          'Probiere diese Schritte nacheinander. Wenn einer nicht funktioniert, gehe zum nächsten über.',
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
      'header_good_afternoon': 'MIRËDITA',
      'header_good_evening': 'MIRËMBRËMA',
      'select_language': 'Zgjidh gjuhën',
      'notifications': 'Njoftime',
      'no_notifications': 'Nuk ka njoftime',
      'nav_home': 'Home',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Ndihmë',
      'nav_rules': 'Rregulla',
      'nav_profile': 'Profil',
      'nav_tasks': 'Detyrat',
      'driver_home_dispatcher': 'Dispecer',
      'driver_home_shift_plan_title': 'Plani i turnit',
      'driver_home_shift_plan_subtitle': 'Turnet e tua',
      'driver_home_scorecard_subtitle': 'Permbledhja e performances tende',
      'driver_home_tasks_title': 'Detyrat',
      'driver_home_tasks_subtitle': 'Menaxho detyrat e hapura',
      'driver_home_academy_subtitle': 'Trajnim & njohuri',
      'driver_home_rules_title': 'Rregullat e kompanise',
      'driver_home_rules_subtitle': 'Udhezime & politika',
      'driver_notification_published_on': 'Publikuar {date}',
      'driver_home_vehicles_title': 'Automjetet',
      'driver_home_vehicles_subtitle': 'Permbledhja e automjeteve',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'Asistenti yt AI',
      'driver_home_absence_title': 'Mungesa',
      'driver_home_absence_subtitle': 'Pushime & leje mjekesore',
      'driver_home_incident_title': 'Raport incidenti',
      'driver_home_incident_subtitle': 'Raporto nje aksident',
      'driver_home_new_badge': 'RE',
      'driver_academy_title': 'DA Academy',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle':
          'Udhezime per fletën e kontrollit ditor',
      'driver_academy_safety_title': 'Trajnim sigurie',
      'driver_academy_safety_subtitle': 'Trajnime sigurie',
      'driver_academy_delivery_title': 'Dorezim Amazon',
      'driver_academy_delivery_subtitle': 'Procese & rrjedha pune te dorezimit',
      'driver_academy_app_title': 'Aplikacioni CoDriver',
      'driver_academy_app_subtitle': 'Veçori & udhezues te aplikacionit',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - Video trajnimi',
      'driver_green_book_video_subtitle': 'Prek per ta luajtur',
      'driver_green_book_start_test': 'Fillo testin Green Book',
      'driver_green_book_test_required': 'Test i detyrueshem',
      'driver_green_book_section1_title':
          'Fleta ditore e kontrollit Green Book',
      'driver_green_book_section1_text':
          'Fleta ditore e kontrollit (Green Book) eshte dokument i detyrueshem qe plotesohet para çdo turni. Ajo verifikon gjendjen e automjetit dhe dokumenton pikat e sigurise.',
      'driver_green_book_section1_b1': 'Plotesoje plotesisht para çdo turni.',
      'driver_green_book_section1_b2':
          'Raporto menjehere defektet e automjetit.',
      'driver_green_book_section1_b3': 'Mos harro nenshkrimin.',
      'driver_green_book_section2_title': 'Pasojat e mosrespektimit',
      'driver_green_book_section2_text':
          'Shkeljet trajtohen me hapa ne rritje:',
      'driver_green_book_section2_b1':
          'Paralajmerimi i pare: verbal nga dispeceri.',
      'driver_green_book_section2_b2': 'Paralajmerimi i dyte: me shkrim.',
      'driver_green_book_section2_b3':
          'Shkelje te perseritura: veprime disiplinore.',
      'driver_green_book_section3_title': 'Ndeshkime ligjore',
      'driver_green_book_section3_text':
          'Nese Green Book mungon ose eshte i paplotesuar ne kontroll:',
      'driver_green_book_section3_b1': 'Deri ne 5000 EUR gjobe per shoferin.',
      'driver_green_book_section3_b2': 'Deri ne 30000 EUR gjobe per kompanine.',
      'driver_green_book_section3_b3':
          'Mund te regjistrohen pike ne Flensburg.',
      'driver_green_book_section3_b4':
          'Mund te kete ndikim negativ ne siguracion.',
      'driver_green_book_test_title': 'Testi Green Book',
      'driver_green_book_test_progress': 'Pyetja {current} nga {total}',
      'driver_green_book_test_next': 'Tjetra',
      'driver_green_book_test_submit': 'Dergo testin',
      'driver_green_book_test_result_pass_title': 'Testi u kalua',
      'driver_green_book_test_result_fail_title': 'Testi nuk u kalua',
      'driver_green_book_test_result_pass_body':
          'Urime! Ke kaluar testin me {score}/{total}.',
      'driver_green_book_test_result_fail_body':
          'Ke marre {score}/{total}. Provo perseri.',
      'driver_green_book_test_retry': 'Provo perseri',
      'driver_green_book_test_close': 'Mbyll',
      'driver_green_book_test_back_to_green_book': 'Kthehu te Green Book',
      'driver_green_book_test_no_questions':
          'Nuk ka ende pyetje testi te konfiguruara. Kontakto dispecerin.',
      'driver_green_book_test_offline_fallback':
          'Sinkronizimi live i testit deshtoi. Mund te vazhdosh me pyetjet fallback dhe te provosh perseri.',
      'admin_home_notification': 'Njoftim',
      'admin_home_driver_fallback': 'Shofer',
      'admin_home_not_confirmed_by': 'NUK E KANE KONFIRMUAR:',
      'admin_home_missing_loading': 'mungon: ...',
      'admin_home_missing_unknown': 'mungon: --',
      'admin_home_missing_count': 'mungon: {count}',
      'admin_home_error_generic': 'Gabim: {error}',
      'admin_home_all_drivers_confirmed': 'Te gjithe shoferet kane konfirmuar.',
      'admin_home_close': 'Mbyll',
      'admin_home_last_week': 'Java e fundit',
      'admin_home_not_logged_in': 'Nuk jeni i kycur.',
      'admin_home_loading_reports': 'Duke ngarkuar raportet...',
      'admin_home_no_reports_uploaded': 'Ende nuk ka raporte te ngarkuara.',
      'admin_home_week_short': 'JW',
      'admin_home_month_prefix': 'MUAJI',
      'admin_home_year_prefix': 'VITI',
      'admin_home_loading_scores': 'Duke ngarkuar piket...',
      'admin_home_name_fallback': 'Emri Mbiemri',
      'admin_home_scorecard': 'Scorecard',
      'admin_home_company_score': 'PIKET E KOMPANISE',
      'admin_home_of': 'nga',
      'admin_home_best_driver': 'Shoferi me i mire',
      'admin_home_worst_defender': 'Mbrojtesi me i dobet',
      'admin_home_notification_history': 'Historiku i njoftimeve',
      'admin_home_no_notifications_yet': 'Ende nuk ka njoftime.',
      'admin_home_notification_type_message': 'MESAZH I RI',
      'admin_home_notification_type_academy': 'DA ACADEMY',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'RREGULL I RI',
      'admin_home_edit_rule': 'Ndrysho rregullin',
      'admin_home_title': 'Titulli',
      'admin_home_body': 'Permbajtja',
      'admin_home_cancel': 'Anulo',
      'admin_home_save': 'Ruaj',
      'admin_home_title_or_body_required': 'Titulli ose permbajtja kerkohet.',
      'admin_home_notification_not_found': 'Njoftimi nuk u gjet.',
      'admin_home_rule_updated_for_drivers':
          'Rregulli u perditesua per {count} shoferë.',
      'admin_home_edit_failed': 'Ndryshimi deshtoi: {error}',
      'admin_home_delete_notification_question': 'Te fshihet njoftimi?',
      'admin_home_delete_notification_body':
          'Ky njoftim do te fshihet per ju dhe per te gjithe shoferet.',
      'admin_home_delete': 'Fshij',
      'admin_home_notification_deleted': 'Njoftimi u fshi.',
      'admin_home_delete_failed': 'Fshirja deshtoi: {error}',
      'admin_home_options': 'Opsione',
      'admin_home_title_upper': 'TITULLI',
      'admin_home_confirmed_by': 'konfirmuar nga',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Servis',
      'admin_home_accidents': 'Aksidente',
      'admin_home_total': 'totali',
      'admin_home_active': 'aktiv',
      'admin_home_inactive': 'joaktiv',
      'admin_home_doc_id_card': 'Karte ID',
      'admin_home_doc_driving_license': 'Patente shoferi',
      'admin_home_doc_residence_permit': 'Leje qendrimi',
      'admin_home_loading_drivers': 'Duke ngarkuar shoferet...',
      'admin_home_no_drivers_yet': 'Ende nuk ka shoferë.',
      'admin_home_contract': 'Kontrate',
      'admin_home_last_day': 'dita e fundit',
      'admin_home_probation': 'Prove',
      'admin_home_ended': 'mbaroi',
      'admin_home_ends': 'mbaron',
      'admin_home_expired_by': 'skaduar me',
      'admin_home_loading_documents': 'Duke ngarkuar dokumentet...',
      'admin_home_driver_documents': 'Dokumentet e shoferit',
      'admin_home_expired_documents': 'Dokumente te skaduara',
      'admin_home_expired_soon': 'skadon se shpejti',
      'admin_home_missing_documents_data': 'Dokumente / te dhena qe mungojne',
      'admin_home_total_missing': 'mungojne gjithsej',
      'admin_home_driver_contracts': 'Kontratat e shoferëve',
      'admin_home_last_day_soon': 'dita e fundit se shpejti',
      'admin_home_no_items': 'Nuk ka artikuj',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'Ndrysho foton e profilit',
      'profile_change_photo': 'Ndrysho foton e profilit',
      'logout': 'Dil',
      'profile_logout': 'Dil',
      'pin_change_with_old':
          'Mund ta ndryshosh PIN-in pasi të verifikosh PIN-in e vjetër.',
      'pin_forgot_contact_admin':
          'Ke harruar PIN-in? Kontakto administratorin.',
      'profile_photo_updated': 'Fotoja e profilit u përditësua.',
      'failed_upload_profile_photo':
          'Dështoi ngarkimi i fotos së profilit: {error}',
      'could_not_read_image_bytes':
          'Nuk u lexuan të dhënat e imazhit nga përzgjedhësi i skedarëve.',

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

      'dash_error_loading_reports':
          'Gabim gjatë ngarkimit të raporteve: {error}',
      'dash_no_reports_uploaded':
          'DSP-ja juaj nuk ka ngarkuar ende raporte scorecard.',
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
      'dash_company_data_section': 'Të dhëna si kompani',
      'dash_company_data_show': 'Shfaq rezultatet si kompani',
      'dash_company_data_hide': 'Fshih kategoritë e kompanisë',

      'dash_rank': 'Renditja',
      'dash_score': 'Rezultati',
      'dash_name': 'Emri',

      'dash_delivered': 'Dërguara',
      'dash_rank_in_aion': 'Renditja në AION',
      'dash_rank_of_total': '{rank} nga {total}',

      'dash_no_my_score_week':
          'Nuk u gjet rezultat për ID-në tuaj të shoferit në këtë javë.',
      'dash_all_status': 'Te gjitha statuset',
      'dash_search_name_or_id': 'Kerko emrin ose ID-ne e Transportuesit...',
      'dash_upload_driver_csv': 'Ngarko CSV te shoferve',

      'scorecard_overview_title': 'PANELI SCORE CARD',
      'scorecard_overview_overview_suffix': '— Permbledhje',
      'scorecard_overview_upload_pdf': 'NGARKO PDF SCORECARD',
      'scorecard_overview_upload_prompt': 'Ngarko PDF-ne e Scorecard',
      'scorecard_overview_choose_file': 'Zgjidh skedarin',
      'scorecard_overview_summary_title': 'Permbledhja e Score Card',
      'scorecard_overview_no_reports_yet':
          'Ende nuk ka raporte. Ngarko PDF-ne e pare te Scorecard per te filluar.',
      'scorecard_overview_chart_title': 'Pasqyra e Score Card',
      'scorecard_overview_best_drivers': 'Shoferet me te mire',
      'scorecard_overview_no_reports_available': 'Nuk ka raporte.',
      'scorecard_overview_no_drivers_period':
          'Nuk u gjeten shofer per kete periudhe.',
      'scorecard_overview_select_station': 'Zgjidh stacionin',
      'scorecard_overview_all_stations': 'Te gjitha stacionet',
      'scorecard_overview_select_period': 'Zgjidh periudhen',
      'scorecard_overview_best_drivers_year': 'Shoferet me te mire te vitit',
      'scorecard_overview_best_drivers_month': 'Shoferet me te mire te muajit',
      'scorecard_overview_station': 'Stacioni',
      'scorecard_overview_station_code': 'Stacioni {code}',
      'scorecard_overview_upload_success_one':
          '1 scorecard u analizua dhe u ruajt. Paneli u perditesua.',
      'scorecard_overview_upload_success_many':
          '{count} scorecard u analizuan dhe u ruajten. Paneli u perditesua.',
      'scorecard_overview_upload_parse_failed':
          'Ngarkimi/analiza deshtoi: {error}',
      'scorecard_overview_no_file_bytes': 'Nuk ka te dhena skedari',
      'scorecard_overview_csv_updated':
          'Emrat e shoferve u perditesuan ne te gjitha raportet.',
      'scorecard_overview_csv_failed': 'Importi CSV deshtoi: {error}',
      'scorecard_overview_delete_report_q': 'Ta fshij raportin?',
      'scorecard_overview_delete_report_body':
          'Kjo do te fshije raportin "{title}" dhe te gjitha hyrjet e scores per kete jave.',
      'scorecard_overview_deleted': 'Raporti dhe score-t e javes u fshine.',
      'scorecard_overview_delete_failed': 'Fshirja deshtoi: {error}',
      'scorecard_overview_more': 'Me shume',
      'scorecard_overview_delete_report_menu': 'Fshi raportin',
      'scorecard_overview_upload_processing':
          'Duke ngarkuar dhe perpunuar scorecard-et...',
      'scorecard_overview_row_title': 'Score Card {year} JW {week}',
      'scorecard_overview_reliability_score': 'Rezultati i besueshmerise',
      'scorecard_overview_from_last_week': 'nga java e kaluar',
      'scorecard_overview_from_last_year': 'nga viti i kaluar',

      'kpi_score': 'REZULTATI',
      'kpi_value': 'VLERA',
      'kpi_pro_tip': 'KËSHILLË',

      'kpi_title_dcr': 'Shkalla e Suksesit të Dorëzimit',
      'kpi_title_dnr': 'Kushtet e Suksesit të Dorëzimit',
      'kpi_title_lor': 'Humbur Gjatë Rrugës',
      'kpi_title_pod': 'Foto gjatë Dorëzimit',
      'kpi_title_cc': 'Kontakt me Klientin',
      'kpi_title_ce': 'Përshkallëzim nga Klienti',
      'kpi_title_cdf': 'Vlerësimi i Dorëzimit nga Klienti',

      'kpi_desc_dcr':
          'Sa më e lartë vlera, aq më mirë. Për të arritur një shkallë suksesi 100%, rekomandohet të bëhet një përpjekje për ridorëzim* pas një dorëzimi të pasuksesshëm.',
      'kpi_tip_dcr':
          'Shembull: Nëse nuk mund të dorëzosh një paketë gjatë një dite për çfarëdo arsye dhe provon ta dorëzosh sërish më vonë po atë ditë, vlera jote DCR do të jetë më e lartë dhe më afër 100%, edhe nëse përpjekja e dytë e dorëzimit është gjithashtu e pasuksesshme.',

      'kpi_desc_dnr':
          'DSC DPMO (Kushtet e Suksesit të Dorëzimit)\n(më parë DNR – Dorëzim i Pa Marrë)\n\nSa më e ulët vlera, aq më mirë.\n\nKjo metrikë mat se sa saktë dhe në mënyrë të gjurmueshme kryhen dorëzimet.\n\nRregullat bazë të dorëzimit:\n- Dorëzim te personi i saktë ose në vendin e saktë\n- Dorëzimet te klientët, anëtarët e familjes, fqinjët ose recepsionistët janë me rrezik të ulët kur kryhen saktë\n- Përdor gjithmonë kodin e saktë të skanimit/arsyes në mënyrë që klientët të marrin njoftime të sakta\n\nDorëzime në dhomë poste / kuti postare:\n- Ndiq rrjedhën standarde të punës\n- Paketat duhet të jenë plotësisht brenda kutisë postare ose hapjes postare dhe nuk duhet të dalin jashtë\n- Përdor skanimin më të saktë të disponueshëm\n\nAdresë e saktë & Geofence:\n- Dorëzim brenda 25 metrave nga geofence i saktë\n- Gjithmonë përputh emrin dhe adresën në aplikacion me etiketën e paketës dhe ndërtesën\n- Nëse geokodi duket i pasaktë, raportoje përmes SDS\n\nFoto gjatë dorëzimit (POD):\n- Gjithmonë bëj një foto të qartë kur kërkohet\n- Paketa dhe ambienti përreth duhet të jenë qartë të dukshme\n- Veçanërisht e rëndësishme për dorëzime pa mbikëqyrje dhe për besimin e klientit\n\nRespekto preferencat e dorëzimit:\n- Ndiq udhëzimet e klientit në aplikacion nëse janë të sigurta\n- Nëse udhëzimet janë të pasigurta, kontakto klientin\n- Përdor vetëm vendet e sigurta të miratuara nga aplikacioni\n\nNdalesa të njëkohshme / në grup:\n- Përdor “Zgjidh të gjitha” vetëm kur disa paketa dorëzohen te i njëjti person ose në të njëjtin vend (p.sh. recepsion)\n- Regjistro saktë emrin e marrësit dhe nënshkrimin',

      'kpi_tip_dnr':
          'Njoftim i rëndësishëm:\n\nVlera të larta të përsëritura në DSC DPMO tregojnë dorëzime të pasakta ose të rrezikshme.\n\n- Devijimet e shpeshta mund të interpretohen nga Amazon si vjedhje e mundshme\n- Kjo mund të aktivizojë një proces parandalimi humbjesh\n- Në rastin më të keq, kjo mund të çojë në përfundimin e bashkëpunimit\n\nSkanime të kujdesshme, foto të sakta dhe respektimi i të gjitha rregullave të dorëzimit të mbrojnë ty dhe ekipin tënd.',

      'kpi_desc_lor':
          'LoR (Humbur Gjatë Rrugës)\n\nSa më e ulët vlera, aq më mirë.\n\nKjo metrikë tregon nëse të gjitha paketat e pa dorëzuara janë regjistruar saktë në fund të itinerarit.\n\nNë fund të itinerarit:\n- Kontrollo në skaner sa paketa duhet të kthehen\n- Sigurohu që ky numër përputhet saktësisht me paketat në automjet',

      'kpi_tip_lor':
          'Njoftim i rëndësishëm:\n\nKjo është kategoria me dyshimin më të lartë për vjedhje.\n\nMospërputhjet midis skanerit dhe inventarit të automjetit mund të konsiderohen gabime serioze dhe mund të çojnë në hetime të brendshme ose pasoja të tjera.',

      'kpi_desc_pod':
          'PoD (Foto gjatë Dorëzimit)\n\nSa më e lartë vlera, aq më mirë.\n\nKjo kolonë tregon paketat për të cilat është bërë një foto, por që janë shënuar si të Pavlefshme ose të Pasigurta.\n\nArsyet e zakonshme për refuzimin e POD:\n1. Etiketa e paketës me të dhëna të klientit e dukshme (paketa duhet të kthehet)\n2. Foto e paqartë\n3. Person i dukshëm në foto\n4. Asnjë paketë e dukshme në foto\n5. Paketa brenda automjetit\n6. Paketa në dorë\n7. Paketa shumë afër kamerës\n8. Foto shumë e errët',

      'kpi_tip_pod':
          'Kjo duhet të jetë kategoria më e thjeshtë\nVlera e synuar: 100%\nPërmirëson ndjeshëm rezultatin e përgjithshëm',

      'pod_quality_title': 'Cilësia POD',
      'pod_quality_success': 'Sukses',
      'pod_quality_rejects': 'Refuzime',
      'pod_quality_opp': 'Mundësi',
      'pod_quality_bypass': 'Anashkalime',
      'pod_quality_blurry': 'E paqartë',
      'pod_quality_too_dark': 'Shumë e errët',
      'pod_quality_no_package': 'Pa paketë',
      'pod_quality_in_car': 'Në makinë',
      'pod_quality_too_close': 'Shumë afër',
      'pod_quality_shell_week_title': 'CILESIA POD - JAVA',
      'pod_quality_week_label': 'Java {week}',
      'pod_quality_dashboard_title': 'PANELI I CILESISE POD',
      'pod_quality_upload_pdf': 'Ngarko PDF',
      'pod_quality_no_reports_uploaded':
          'Ende nuk ka raporte te cilesise POD. Ngarko nje PDF POD per te filluar.',
      'pod_quality_upload_success_one':
          '1 raport i cilesise POD u analizua dhe u ruajt.',
      'pod_quality_upload_success_many':
          '{count} raporte te cilesise POD u analizuan dhe u ruajten.',
      'pod_quality_upload_parse_failed': 'Ngarkimi/analiza deshtoi: {error}',
      'pod_quality_rejects_breakdown': 'Ndarja e refuzimeve',
      'pod_quality_no_data_week': 'Nuk ka te dhena POD per kete jave.',
      'pod_quality_drivers': 'Shoferet',
      'pod_quality_entries_count': '{count} hyrje',

      'kpi_desc_cc':
          'CC (Kontakt me Klientin)\n\nSa më e lartë vlera, aq më mirë.\n\nJashtëzakonisht e rëndësishme:\nDuhet GJITHMONË të dërgosh një mesazh “Nuk ka vend të sigurt” ose “Adresa nuk u gjet”, çdo herë që nuk mund të dorëzosh një paketë sepse:\n\n- klienti nuk është në shtëpi ose\n- adresa nuk mund të gjendet',

      'kpi_tip_cc':
          'Ekziston një mesazh standard automatik në aplikacion për çdo skenar.',

      'kpi_desc_ce':
          'CE (Përshkallëzim nga Klienti)\n\nSa më e ulët vlera, aq më mirë.\nKategoria më e keqe nga të gjitha.\n\nKlientët përshkallëzojnë kur udhëzimet e dorëzimit nuk respektohen.\n\nShoferi është gjithmonë përgjegjës\nAnkesat janë pothuajse të pamundura pa prova shumë të forta\nKa ndikimin më të fortë në Scorecard-in tënd\n\nSi të shmangësh CE\n\nËshtë kundër udhëzimeve të dorëzimit të lësh paketat në vende të pasigurta ose të pambikëqyrura pa miratim\n\nDelivery Associates duhet:\n- Të bien zilen / të përdorin interfonin ose të trokasin\n- T’i japin klientit kohë të mjaftueshme për t’u përgjigjur\n\nNëse klienti nuk mund të kontaktohet dhe nuk është regjistruar asnjë vend i sigurt:\n- Të telefonojnë klientin dy herë\n- Të dërgojnë një mesazh me tekst\n- Të kontaktojnë Driver Support nëse nuk është i mundur kontakti\n\nNëse është e nevojshme:\n- Të skanojnë paketën si “Dorëzim i dështuar – klienti i padisponueshëm”\n- Të provojnë sërish dorëzimin sipas udhëzimeve',

      'kpi_tip_ce':
          'Mos i lër paketat në vende të pasigurta ose të pamiratuara\nRespekto gjithmonë proceset e sakta të dërgimit dhe dorëzimit',

      'kpi_desc_cdf':
          'CDF DPMO (Vlerësimi i Dorëzimit nga Klienti)\n\nSa më e ulët vlera, aq më mirë.\n\nNiveli 1 (L1)\n- Klienti e vlerëson dorëzimin si “Shkëlqyeshëm” (👍) ose “Jo aq mirë” (👎)\n\nNiveli 2 (L2)\n- Reagim shtesë pse përvoja ishte e mirë ose e keqe',

      'kpi_tip_cdf': 'CDF llogaritet ekskluzivisht në nivelin L1',

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

      // =========================
      // ALBANIAN (sq) – FAQ keys
      // =========================

      // FAQs
      'faq_title': 'Pyetje të Shpeshta',
      'faq_search_hint': 'Kërko pyetje',
      'faq_empty': 'Nuk u gjetën FAQ që përputhen.',
      'driver_tasks_error': 'Gabim: {error}',
      'driver_tasks_no_tasks': 'Ende nuk ka detyra te caktuara.',
      'driver_tasks_update_status': 'Perditeso statusin',
      'driver_tasks_confirm_completed': 'Konfirmo te perfunduar',
      'driver_tasks_set_completed_first':
          'Vendose statusin fillimisht te "E perfunduar".',
      'driver_tasks_completion_confirmed': 'Perfundimi u konfirmua.',
      'driver_tasks_failed_update_status':
          'Perditesimi i statusit deshtoi: {error}',
      'driver_tasks_failed_confirm_task':
          'Konfirmimi i detyres deshtoi: {error}',
      'driver_tasks_status_confirmed_by_you': 'Statusi u konfirmua nga ju.',
      'driver_tasks_confirm_when_fully_done':
          'Ju lutem konfirmoni kur kjo detyre te perfundoje plotesisht.',
      'driver_tasks_status_pending': 'Ne pritje',
      'driver_tasks_status_in_progress': 'Ne proces',
      'driver_tasks_status_completed': 'E perfunduar',
      'faq_green_book_video_title': 'Video udhëzues për Green Book',
      'faq_green_book_video_subtitle':
          'Shiko hap pas hapi si të plotësosh Green Book',
      'faq_green_book_video_action': 'Shiko videon',
      'faq_green_book_video_missing':
          'Linku i videos së Green Book nuk është konfiguruar ende.',
      'faq_green_book_video_open_failed':
          'Nuk u hap linku i videos së Green Book.',

      'faq_q1':
          'Cila është gjëja më e rëndësishme në detyrën tënde të përditshme?',
      'faq_a1': 'Dërgimi i paketave me cilësi dhe me sjellje të mirë.',

      'faq_q2': 'Çfarë nuk duhet të bësh në rast problemesh me klientin?',
      'faq_a2':
          'MOS u përpiq ta zgjidhësh situatën vetë; informo dispatcher-in në detyrë. Ne do të flasim me klientin për ty dhe do të përpiqemi të shmangim pasojat negative nga Amazon për shkak të ankesave. Jemi këtu për ty!',

      'faq_q3':
          'Po nëse situata tashmë ka eskaluar dhe klienti nuk është i kënaqur për çfarëdo që ka ndodhur?',
      'faq_a3':
          'Nuk është kurrë vonë për të rregulluar gabimet. Na telefono gjithsesi dhe do të përpiqemi ta rregullojmë me klientin. Më mirë vonë se kurrë.',

      'faq_q4':
          'Çfarë është më e rëndësishme: Sasia (shpejtësia për të dorëzuar sa më shumë ndalesa) apo Cilësia?',
      'faq_a4':
          'Cilësia! Gjithmonë cilësia! Ndiq udhëzimet e klientit dhe MOS e lër paketën në vende të pasigurta vetëm sepse je mbrapa me ndalesat.',

      'faq_q5':
          'Po nëse fokusohem te cilësia, por pastaj mbetem mbrapa me ndalesat?',
      'faq_a5':
          'Do t’i përfundosh ndalesat, në një mënyrë ose në një tjetër. Do të përpiqemi të dërgojmë ndihmë, por vetëm nëse e shohim të arsyeshme.',

      'faq_q6': 'Çfarë është scorecard dhe çfarë është një DNR?',
      'faq_a6': 'Mirë që pyete.',

      // 7 – Weekly scorecard
      'faq_q7': 'Scorecard Javore',
      'faq_a7':
          'Scorecard-i javor na jep një pasqyrë të shpejtë dhe të qartë se si po ecën ekipi në objektivat kryesore. '
          'Na ndihmon të shohim çfarë po shkon mirë, ku po mbetemi pas dhe ku duhet të fokusohemi për javën në vijim.\n\n'
          'Rezultatet e përgjithshme janë si më poshtë:\n'
          '• Fantastic Plus: >93% (performancë e jashtëzakonshme)\n'
          '• Fantastic: 85% – 92.9%\n'
          '• Great: 70% – 84.9%\n'
          '• Fair: 50% – 69.9%\n'
          '• Poor: <50%',

      'faq_q7_1': 'Skeda DNR\nDelivered Not Received',
      'faq_a7_1':
          'Është kur ti e ke dorëzuar paketën dhe ke shtypur butonin “Swipe to finish” duke konfirmuar dorëzimin, '
          'por klienti nuk e ka marrë paketën për arsye të ndryshme: vjedhje, kuti bosh ose dorëzim në adresë të gabuar.\n'
          'Çdo të martë do të marrësh fotografi për çdo DNR që ke pasur gjatë javës.',

      'faq_q7_1_1':
          'Si ta shmang këtë dhe sa e rëndësishme është për scorecard-in javor?',
      'faq_a7_1_1':
          'Është shumë e rëndësishme. Për ta shmangur, thjesht njofto klientin paraprakisht që po afrohesh dhe bjeri ziles VETËM te emri i tij në zile.',

      'faq_q7_1_2': 'Si t’i shmang humbjet e paketave?',
      'faq_a7_1_2':
          'Gjithmonë përpiqu t’ia dorëzosh paketat në dorë klientit. Nëse kjo nuk është e mundur, dërgo një mesazh duke e informuar se ku u la paketa, p.sh. në garazh, nën shkallë, në kasolle, pas vazos së luleve, etj.\n'
          'Nëse mendon se nuk është e sigurt ta lësh paketën pa mbikëqyrje, më mirë merre dhe provo përsëri më vonë. Kjo është SHUMË e rëndësishme.',

      'faq_q7_1_3': 'Si ta di nëse një vend është i sigurt apo jo?',
      'faq_a7_1_3':
          'Instinkti dhe logjika. Nëse një ndërtesë ka 20–30 kate dhe ti e lë paketën te kutitë postare, shanset për vjedhje janë shumë më të larta krahasuar me një shtëpi private.\n'
          'Gjithashtu, për të të ndihmuar në dorëzimet e përditshme dhe për të shmangur DNR, çdo mëngjes do të postojmë një foto me adresa ku ka rrezik të lartë për vjedhje dhe ankesa, bazuar në rezultatet dhe statistikat e mëparshme.',

      'faq_q7_1_4':
          'Po nëse një paketë humbet ose vidhet, si ndikon kjo në rezultatin tim?',
      'faq_a7_1_4':
          'Shumë keq. Kjo të ndikon të paktën me 30% dhe edhe vetëm një paketë mund të të kushtojë të paktën 600 pikë. '
          'Sa më shumë pikë të shohësh në scorecard nën emrin tënd, aq më keq është. Sa më shumë paketa dorëzon në javë, aq më pak pikë humbet për rast. '
          'Pikët e humbura ndryshojnë edhe sipas çmimit të artikullit: sa më i shtrenjtë, aq më shumë pikë humben.\n'
          'Gjithashtu, nëse rregullisht ke numër të lartë paketash të humbura, do të duhet të të largojmë, sepse herët a vonë Amazon mund të dyshojë për vjedhje paketash. Kjo është shumë e rrezikshme.',

      // CC
      'faq_q7_2': 'Skeda CC\nContact Compliance',
      'faq_a7_2':
          'Do të thotë sa herë ke kontaktuar klientin për dorëzimin e tij, qoftë me mesazh apo telefonatë. '
          'Sa më pak të komunikosh me klientin, aq më i ulët do të jetë rezultati në scorecard. '
          'Këtë seksion duhet ta mbajmë sa më të lartë që të jetë e mundur, sepse është një nga kategoritë më të lehta dhe ndihmon shumë në rezultatin e përgjithshëm.',

      'faq_q7_2_1': 'Pse duhet ta bëj këtë?',
      'faq_a7_2_1':
          'Dorëzimi i paketave nuk është vetëm “Drop&Go”. Duhet ta njoftosh klientin paraprakisht dhe ta pyesësh se ku do të donte të dorëzohej paketa.',

      'faq_q7_2_2': 'Si ta përmirësoj rezultatin tim CC?',
      'faq_a7_2_2':
          'Faleminderit që pyete. Shumë thjesht: duke telefonuar dhe sidomos duke dërguar mesazhe klientëve në çdo ndalesë.',

      // CE
      'faq_q7_3': 'Skeda CE\nCustomer Escalation',
      'faq_a7_3':
          'Të kujtohet sa keq ndikoi DNR në rezultatet? Kjo është të paktën 2 herë më e keqe dhe rrezikon edhe vendin e punës, sepse varet sa e rëndë ishte situata.',

      'faq_q7_3_1': 'Si ta shmang këtë?',
      'faq_a7_3_1':
          'Duke ndjekur gjithmonë udhëzimet e dorëzimit të klientit. Në rast gabimi, kërko falje menjëherë. '
          'Nëse klienti është i zemëruar, kërkoji një minutë kohë që të flasë me ne, ndërsa ti po na telefonon. '
          'Duke lexuar Seksionin 2, tani duhet ta dish që është më mirë ta lëmë ne t’i trajtojmë këto situata.',

      // POD
      'faq_q7_4': 'Skeda POD\nPicture on Delivery',
      'faq_a7_4':
          'Kjo kolonë tregon listën e paketave të përshtatshme për POD, për të cilat janë bërë foto, por që janë shënuar si “Invalid” ose “Not Sure”. Arsyet e refuzimit mund të përfshijnë:\n'
          '1- Etiketa e paketës me të dhënat e klientit duket në foto. Paketa duhet të kthehet mbrapsht para se të bëhet foto.\n'
          '2- Foto e paqartë\n'
          '3- Person i dukshëm në foto\n'
          '4- Nuk dallohet paketë në foto\n'
          '5- Paketë në makinë\n'
          '6- Paketë në dorë\n'
          '7- Paketë në kuti poste\n'
          '8- Paketë shumë afër\n'
          '9- Foto shumë e errët.\n'
          'Kjo duhet të jetë gjithmonë pjesa më e lehtë ku duhet të marrësh 100% dhe përmirëson rezultatin tënd të përgjithshëm.',

      // LoR
      'faq_q7_5': 'Skeda LoR\nLost on Road',
      'faq_a7_5':
          'Të penalizon kur ke skanuar një paketë gjatë ngarkimit dhe nuk e kthen në fund të turnit në rast dorëzimi të pasuksesshëm. '
          'Pra paketa konsiderohet e humbur dhe humb po aq pikë sa në një DNR. '
          'Prandaj numëro mirë paketat që kthen dhe sigurohu që përputhen me paketat e shfaqura në scanner. '
          'Mund t’i gjesh te: Today’s Itinerary – Summary – Problems. Nëse nuk përputhen, informo dispatcher-in në detyrë para se ta mbyllësh punën në aplikacionin Amazon.',

      // DCR
      'faq_q7_6': 'Skeda DCR\nDelivery Completion Rate',
      'faq_a7_6':
          'Tregon aftësinë tënde për të dorëzuar paketa. Ndjek përqindjen e dorëzimeve të përfunduara sipas planit dhe na ndihmon të masim efikasitetin dhe besueshmërinë. '
          'Thekson probleme si vonesa, tentativa të dështuara ose probleme me rrugëtimin. Ky duhet të jetë sa më i lartë që të jetë e mundur. '
          'Për ta arritur këtë, bëj çdo ditë reattempts dhe shmang sa të mundesh kthimin e paketave.',

      // CDF
      'faq_q7_7': 'Skeda CDF (më parë: DEX)\nCustomer Delivery Feedback',
      'faq_a7_7':
          'Kap përvojën e marrësit me procesin e dorëzimit, duke përfshirë përpikmërinë, gjendjen e mallrave dhe profesionalizmin e shoferit. '
          'Na ndihmon të identifikojmë pikat e forta dhe fushat për përmirësim. Në fund të dorëzimit, klienti merr një email nga Amazon për përvojën e dorëzimit me pyetje si:\n'
          '1) A u dorëzua paketa në kohë?\n'
          'Po / Jo\n'
          '2) A u la paketa në një vend të sigurt?\n'
          'Po / Jo\n'
          '3) A ishte paketa në gjendje të mirë kur mbërriti?\n'
          'Po / Jo\n'
          '4) Sa i kënaqur je me dorëzimin në përgjithësi?\n'
          'Shumë i kënaqur / I kënaqur / Neutral / I pakënaqur / Shumë i pakënaqur\n'
          '5) Si e vlerëson komunikimin dhe përditësimet e ndjekjes për këtë dorëzim?\n'
          'Shkëlqyeshëm / Mirë / Mesatar / Dobët\n'
          '6) A ishte personi i dorëzimit i sjellshëm dhe profesional?\n'
          'Po / Jo / Jo e aplikueshme (dorëzim pa kontakt)\n'
          '7) A ke ndonjë koment për përvojën tënde të dorëzimit?\n'
          '(Komente shtesë të klientit)',

      'faq_q7_8': 'Çfarë duhet të kem parasysh për scorecard-in?',
      'faq_a7_8':
          'Cilësia dhe efikasiteti të çojnë larg. Rezultatet e mira janë të mira për ty, për kompaninë dhe për të gjithë ekipin. Kënaqësia e klientit është shumë e rëndësishme dhe rezultatet e mira shoqërohen me bonus nga kompania.\n'
          'Jep maksimumin, merr maksimumin.',

      'faq_q8': 'Në cilat fusha të tjera duhet të jem i kujdesshëm?',
      'faq_a8':
          'Kujdesu për veten: vozit në mënyrë të sigurt, shmang dëmtimet dhe shmang qentë dhe kafshimet. '
          'Kujdes me pajisjet e punës si furgoni i ditës, scanner/telefoni i punës dhe eja në punë me këpucë sigurie dhe jelek sigurie, si edhe xhaketë ose bluzë me markën Amazon (në varësi të motit).',

      'faq_q9': 'Çfarë ndodh nëse bëj aksident ose dëmtoj furgonin e punës?',
      'faq_a9':
          'Së pari, sigurohu që je mirë dhe nuk je i lënduar rëndë. Sa i përket dëmit të makinës, nëse përcaktojmë se aksidenti ka ndodhur për shkak të neglizhencës – p.sh. shpërqendrime si përdorimi i telefonit gjatë vozitjes – do të jesh personalisht përgjegjës për të gjithë dëmin. '
          'Përveç kësaj, do të marrësh raport nga policia, që mund të çojë edhe në pezullim patente. Kjo mund të jetë edhe arsye për largim të menjëhershëm. '
          'Përndryshe, thjesht përjashtohesh nga bonuset javore të Scorecard për 2 muaj. '
          'Në rast incidenti, je i detyruar të na njoftosh menjëherë dhe të na japësh kohën e incidentit, vendndodhjen, nëse ka dëme në prona private ose publike (si mure, gardhe, shtylla ndriçimi, njerëz dhe/ose kafshë), si dhe foto të dëmeve të makinës.',

      'faq_q10': 'Çfarë të bëj kur kam paketa të dëmtuara dhe/ose që mungojnë?',
      'faq_a10':
          'Kur një paketë është e dëmtuar, mund ta shënosh si të dëmtuar dhe ta kthesh në stacion. Nëse ajo paketë ishte me lëng dhe ka dëmtuar edhe paketa të tjera, bëj një foto të të gjitha paketave të dëmtuara dhe dërgoje dispatcher-it në detyrë; ne do ta raportojmë në Amazon për ty.\n'
          'Kur një paketë mungon, mund ta shënosh si missing – përveç nëse ka OTP, ku DUHET ta raportosh fillimisht tek ne para se ta shënosh si missing. Kjo është SHUMË e rëndësishme.',

      'faq_q11': 'Çfarë është një paketë OTP (One-Time Password)?',
      'faq_a11':
          'Është një artikull i shtrenjtë që Amazon kërkon që klienti t’i japë shoferit një fjalëkalim njëpërdorimësh (OTP) para dorëzimit, për të siguruar që paketa i dorëzohet personit/klientit të duhur. '
          'Duhet të kesh kujdes të shtuar për këto paketa, të mos i lësh pa mbikëqyrje dhe t’ia dorëzosh paketën vetëm klientit që të ka dhënë fjalëkalimin.',

      'faq_q12':
          'Pse vazhdojmë të të themi të ngadalësosh dhe të mos shkosh më shpejt?',
      'faq_a12':
          'As neve nuk na pëlqen, por kështu funksionon sistemi. Duhet të ndjekim algoritmin dhe të bëjmë një numër ndalesash për orë siç është paracaktuar, që të marrim më shumë rrugë në të ardhmen dhe ti të kesh më shumë punë e jo të jesh i lirë.\n'
          'Gjithashtu, duke shkuar më shpejt rrezikon të marrësh DNR dhe të humbësh pikë si për veten, ashtu edhe për kompaninë në scorecard-in javor.',

      'faq_q13':
          'Atëherë pse dispatcher-at ndonjëherë më pyesin pse je mbrapa dhe nëse ka diçka që nuk shkon?',
      'faq_a13':
          'E dimë që nuk është e këndshme, por na duhet feedback se çfarë mund të ketë ndodhur rrugës që të ka bërë të mbetesh mbrapa me ndalesat. Amazon na e kërkon këtë feedback sepse ka edhe një afat kohor ku duhet të kesh dorëzuar X ndalesa; prandaj Amazon duhet të dijë pse ndalesat e mbetura janë mbrapa planit, për të përmirësuar efikasitetin e ardhshëm.',

      'faq_q14': 'Pse ndonjëherë të kërkojmë të shkosh të ndihmosh një koleg?',
      'faq_a14':
          'Sepse shumë faktorë ndikojnë në vonesën e kolegut, si lidhje e dobët interneti në zonë, trafik, rrugë të bllokuara nga punime, që e bëjnë të vështirë dorëzimin në kohë. Prandaj nevojitet ndihma jote.',

      'faq_q15':
          'A filloj që në ditën e parë të dorëzoj paketa në ruter standard si shoferët më me përvojë?',
      'faq_a15':
          'Jo, sigurisht që jo. Në fillim ke një periudhë prej 14 ditësh pune për të vënë në praktikë atë që ke mësuar në ditët “ride-along” me trajnerin dhe për t’u përshtatur me zonën, furgonin, scanner-in dhe procesin e punës.\n'
          'Gjatë kësaj periudhe 14-ditore, Amazon do të të japë deri në 50% më pak paketa dhe ndalesa se normalisht.',

      'faq_q16':
          'Çfarë të bëj kur një adresë është e gabuar dhe/ose pini i vendndodhjes nuk është i saktë në hartë?',
      'faq_a16':
          'Së pari konfirmo që pini nuk është i saktë duke kërkuar adresën në Google Maps (është më i saktë dhe është i instaluar në scanner). Nëse nuk përputhet, njofto dispatcher-in në detyrë për gabimet.',

      'faq_q17':
          'Cilat janë detyrat e mia të përditshme para se të filloj dhe pasi të mbaroj punën?',
      'faq_a17':
          '1- Kur vjen në parking, sigurohu që mban këpucë sigurie, jelek sigurie dhe uniformën e Amazon.\n'
          '2- Kontrollo nëse scanner-i është i karikuar plotësisht dhe njofto dispatcher-in nëse nuk është.\n'
          '3- Kontrollo nëse ka ndonjë problem me furgonin.\n'
          '4- Nis udhëtimin në aplikacionin Mentor në scanner.\n'
          '5- Posto një foto të panelit të furgonit që tregon kilometrat aktualë dhe trip-in ditor (në furgon) të resetuar në 0.\n'
          '6- Shko në Waiting Area vetëm 10 minuta para orës së planifikuar të ngarkimit, jo më herët.\n'
          '7- Në Waiting Area, fik motorin, hap Flex App dhe Timesheet. Jo asnjë minutë më herët, sidomos Flex App. Mos harro “timestamp”-in 10-minutësh.\n'
          '8- Pastaj shko në Loading Area sipas udhëzimeve të Yard Marshall. Në Loading Area fik motorin dhe dil nga furgoni vetëm PASI të dëgjosh bilbilin e Yard Marshall.\n'
          '9- Pasi të kesh ngarkuar, ndiz furgonin dhe nis lëvizjen vetëm kur Yard Marshall të të udhëzojë.\n'
          '10- Pasi të përfundosh ndalesat, kontrollo karburantin; nëse është më pak se gjysma, mbushe.\n'
          '11- Në stacion, lëri paketat e mbetura në zonat e caktuara nga Amazon dhe kthe çantat në kohë.\n'
          '12- Në parking, fik furgonin dhe plotëso Green Book (Tageskontrollblatt), posto foto të kilometrave ditorë dhe foto të Green Book.\n'
          '13- Fik furgonin dhe kthe çantën e punës në zonën e caktuar.',

      'faq_q18':
          'A duhet të bëj diçka kur ndërroj furgonin dhe marr një tjetër në vend të atij që përdor zakonisht?',
      'faq_a18':
          'Duhet të bësh një video që tregon me detaje çdo dëmtim të vogël që mund të kenë bërë shoferët para teje, që të mos jetë faji yt në inspektimin e ardhshëm.',

      'faq_q19':
          'Çfarë të bëj nëse Flex App është gjithmonë duke u ngarkuar dhe po ma ngadalëson punën?',
      'faq_a19':
          'Së pari kontrollo nëse ke lidhje aktive interneti. Mund ta provosh duke dërguar një mesazh te klienti i ndalesës aktuale; nëse shkon, atëherë interneti është aktiv. Mund ta kontrollosh edhe duke hapur një aplikacion tjetër, p.sh. browser-in.\n'
          'Hapat nëse NUK ka lidhje aktive interneti:\n'
          '1- Rinise scanner-in. Kjo duhet të jetë gjithmonë gjëja e parë.\n'
          '2- Aktivizo/çaktivizo airplane mode. Shpesh funksionon pa pritur rinisjen.\n'
          '3- Si zgjidhje e fundit, përdor hotspot nga telefoni personal për maksimum 10 minuta, vetëm sa të rifreskohet sistemi.\n'
          'Mund të punosh edhe offline, por në një moment duhet të lidhet interneti. Për offline duhet të shkarkosh offline maps në Flex App: Settings – Offline Maps (opsioni i fundit) – Download DBY5 – Allow downloads with mobile connection.\n',

      'faq_q20':
          'Po nëse interneti është aktiv, por Flex App prapë nuk punon siç duhet?',
      'faq_a20':
          '1- Rinise scanner-in.\n'
          '2- Aktivizo/çaktivizo airplane mode\n'
          '3- Dil nga aplikacioni\n'
          '4- Çaktivizo/aktivizo Location Services (GPS)\n'
          '5- Dil (log out) nga Flex App dhe hyr përsëri (log in) me kredencialet që përdor për Mentor App.\n'
          '6- Kontrollo nëse aplikacioni ka nevojë për përditësim.\n'
          'Provoji këto hapa një nga një. Nëse njëri nuk funksionon, provo tjetrin.',
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
      'header_good_afternoon': 'JÓ NAPOT',
      'header_good_evening': 'JÓ ESTÉT',
      'select_language': 'Nyelv kiválasztása',
      'notifications': 'Értesítések',
      'no_notifications': 'Nincs értesítés',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Súgó',
      'nav_rules': 'Szabályok',
      'nav_profile': 'Profil',
      'nav_tasks': 'Feladatok',
      'driver_home_dispatcher': 'Diszpecser',
      'driver_home_shift_plan_title': 'Muszakterv',
      'driver_home_shift_plan_subtitle': 'Muszakjaid',
      'driver_home_scorecard_subtitle': 'Teljesitmenyed attekintese',
      'driver_home_tasks_title': 'Feladatok',
      'driver_home_tasks_subtitle': 'Nyitott teendok kezelese',
      'driver_home_academy_subtitle': 'Kepzes & tudas',
      'driver_home_rules_title': 'Ceges szabalyok',
      'driver_home_rules_subtitle': 'Iranyelvek es szabalyzatok',
      'driver_notification_published_on': 'Kozzeteve {date}',
      'driver_home_vehicles_title': 'Jarmuvek',
      'driver_home_vehicles_subtitle': 'Jarmu attekintes',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'AI asszisztensed',
      'driver_home_absence_title': 'Tavollet',
      'driver_home_absence_subtitle': 'Szabadsag & betegszabadsag',
      'driver_home_incident_title': 'Incidensjelentes',
      'driver_home_incident_subtitle': 'Baleset bejelentese',
      'driver_home_new_badge': 'UJ',
      'driver_academy_title': 'DA Akademia',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle': 'Napi ellenorzolap iranyelvek',
      'driver_academy_safety_title': 'Biztonsagi kepzes',
      'driver_academy_safety_subtitle': 'Biztonsagi treningek',
      'driver_academy_delivery_title': 'Amazon kiszallitas',
      'driver_academy_delivery_subtitle': 'Kiszallitasi folyamatok',
      'driver_academy_app_title': 'CoDriver alkalmazas',
      'driver_academy_app_subtitle': 'App funkciok es utmutatok',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - Kepzesi video',
      'driver_green_book_video_subtitle': 'Erintsd meg a lejatszashoz',
      'driver_green_book_start_test': 'Green Book teszt inditasa',
      'driver_green_book_test_required': 'A teszt kotelezo',
      'driver_green_book_section1_title': 'Green Book napi ellenorzolap',
      'driver_green_book_section1_text':
          'A napi ellenorzolap (Green Book) kotelezo dokumentum, amelyet minden muszak elott ki kell tolteni. Segit ellenorizni a jarmu allapotat es dokumentalja a biztonsagi pontokat.',
      'driver_green_book_section1_b1':
          'Minden muszak elott teljesen toltsd ki.',
      'driver_green_book_section1_b2': 'A jarmuhibakat azonnal jelentsd.',
      'driver_green_book_section1_b3': 'Ne felejtsd el az alairast.',
      'driver_green_book_section2_title': 'A szabalysertes kovetkezmenyei',
      'driver_green_book_section2_text':
          'A jogsertesek fokozatos lepesek szerint kezeltek:',
      'driver_green_book_section2_b1':
          'Elso figyelmeztetes: szobeli figyelmeztetes a diszpecsertol.',
      'driver_green_book_section2_b2':
          'Masodik figyelmeztetes: irasbeli figyelmeztetes.',
      'driver_green_book_section2_b3':
          'Ismetelt jogsertes: fegyelmi intezkedesek.',
      'driver_green_book_section3_title': 'Jogi buntetesek',
      'driver_green_book_section3_text':
          'Ha a Green Book hianyzik vagy ellenorzeskor hianyosan van kitoltve:',
      'driver_green_book_section3_b1':
          'A soforre akar 5000 EUR birsag is kiszabhato.',
      'driver_green_book_section3_b2':
          'A cegre akar 30000 EUR birsag is kiszabhato.',
      'driver_green_book_section3_b3': 'Flensburg pontok rogzithetok.',
      'driver_green_book_section3_b4': 'A biztositasra negativ hatassal lehet.',
      'driver_green_book_test_title': 'Green Book teszt',
      'driver_green_book_test_progress': '{current}. kerdes / {total}',
      'driver_green_book_test_next': 'Kovetkezo',
      'driver_green_book_test_submit': 'Teszt kuldese',
      'driver_green_book_test_result_pass_title': 'Sikeres teszt',
      'driver_green_book_test_result_fail_title': 'Sikertelen teszt',
      'driver_green_book_test_result_pass_body':
          'Gratulalunk! A teszt sikeres: {score}/{total}.',
      'driver_green_book_test_result_fail_body':
          'Az eredmenyed {score}/{total}. Probald ujra.',
      'driver_green_book_test_retry': 'Ujraprobalas',
      'driver_green_book_test_close': 'Bezaras',
      'driver_green_book_test_back_to_green_book': 'Vissza a Green Bookhoz',
      'driver_green_book_test_no_questions':
          'Meg nincsenek beallitva tesztkerdesek. Lepj kapcsolatba a diszpecserrel.',
      'driver_green_book_test_offline_fallback':
          'Az elo teszt szinkronizalas sikertelen. Fallback kerdesekkel folytathatod, majd probald ujra.',
      'admin_home_notification': 'Ertesites',
      'admin_home_driver_fallback': 'Sofor',
      'admin_home_not_confirmed_by': 'NEM EROSITETTE MEG:',
      'admin_home_missing_loading': 'hianyzik: ...',
      'admin_home_missing_unknown': 'hianyzik: --',
      'admin_home_missing_count': 'hianyzik: {count}',
      'admin_home_error_generic': 'Hiba: {error}',
      'admin_home_all_drivers_confirmed': 'Minden sofor megerositette.',
      'admin_home_close': 'Bezar',
      'admin_home_last_week': 'Mult het',
      'admin_home_not_logged_in': 'Nincs bejelentkezve.',
      'admin_home_loading_reports': 'Jelentesek betoltese...',
      'admin_home_no_reports_uploaded': 'Meg nincs feltoltott jelentes.',
      'admin_home_week_short': 'HET',
      'admin_home_month_prefix': 'HONAP',
      'admin_home_year_prefix': 'EV',
      'admin_home_loading_scores': 'Pontszamok betoltese...',
      'admin_home_name_fallback': 'Keresztnev Vezeteknev',
      'admin_home_scorecard': 'Scorecard',
      'admin_home_company_score': 'CEGES PONTSZAM',
      'admin_home_of': 'bol',
      'admin_home_best_driver': 'Legjobb sofor',
      'admin_home_worst_defender': 'Leggyengebb defender',
      'admin_home_notification_history': 'Ertesitesi elozmenyek',
      'admin_home_no_notifications_yet': 'Meg nincs ertesites.',
      'admin_home_notification_type_message': 'UJ UZENET',
      'admin_home_notification_type_academy': 'DA AKADEMIA',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'UJ SZABALY',
      'admin_home_edit_rule': 'Szabaly szerkesztese',
      'admin_home_title': 'Cim',
      'admin_home_body': 'Tartalom',
      'admin_home_cancel': 'Megse',
      'admin_home_save': 'Mentes',
      'admin_home_title_or_body_required': 'A cim vagy tartalom kotelezo.',
      'admin_home_notification_not_found': 'Ertesites nem talalhato.',
      'admin_home_rule_updated_for_drivers':
          'Szabaly frissitve {count} sofornek.',
      'admin_home_edit_failed': 'Szerkesztes sikertelen: {error}',
      'admin_home_delete_notification_question': 'Ertesites torlese?',
      'admin_home_delete_notification_body':
          'Ez az ertesites torlodik nalad es az osszes sofornel.',
      'admin_home_delete': 'Torles',
      'admin_home_notification_deleted': 'Ertesites torolve.',
      'admin_home_delete_failed': 'Torles sikertelen: {error}',
      'admin_home_options': 'Opciók',
      'admin_home_title_upper': 'CIM',
      'admin_home_confirmed_by': 'megerositette',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Szerviz',
      'admin_home_accidents': 'Balesetek',
      'admin_home_total': 'osszesen',
      'admin_home_active': 'aktiv',
      'admin_home_inactive': 'inaktiv',
      'admin_home_doc_id_card': 'Szemelyi igazolvany',
      'admin_home_doc_driving_license': 'Jogositvany',
      'admin_home_doc_residence_permit': 'Tartozkodasi engedely',
      'admin_home_loading_drivers': 'Soforok betoltese...',
      'admin_home_no_drivers_yet': 'Meg nincsenek soforok.',
      'admin_home_contract': 'Szerzodes',
      'admin_home_last_day': 'utolso nap',
      'admin_home_probation': 'Probaido',
      'admin_home_ended': 'veget ert',
      'admin_home_ends': 'vege',
      'admin_home_expired_by': 'lejart ekkor',
      'admin_home_loading_documents': 'Dokumentumok betoltese...',
      'admin_home_driver_documents': 'Sofor dokumentumok',
      'admin_home_expired_documents': 'Lejart dokumentumok',
      'admin_home_expired_soon': 'hamarosan lejar',
      'admin_home_missing_documents_data': 'Hianyzo dokumentumok / adatok',
      'admin_home_total_missing': 'osszes hiany',
      'admin_home_driver_contracts': 'Sofor szerzodesek',
      'admin_home_last_day_soon': 'utolso nap hamarosan',
      'admin_home_no_items': 'Nincs elem',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'Profilkép módosítása',
      'profile_change_photo': 'Profilkép módosítása',
      'logout': 'Kijelentkezés',
      'profile_logout': 'Kijelentkezés',
      'pin_change_with_old': 'A PIN módosításához add meg a régi PIN-t.',
      'pin_forgot_contact_admin':
          'Elfelejtetted a PIN-t? Vedd fel a kapcsolatot az adminnal.',
      'profile_photo_updated': 'Profilkép frissítve.',
      'failed_upload_profile_photo':
          'Nem sikerült feltölteni a profilképet: {error}',
      'could_not_read_image_bytes':
          'Nem sikerült beolvasni a képadatokat a fájlválasztóból.',

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
      'dash_no_reports_uploaded':
          'A DSP még nem töltött fel scorecard jelentéseket.',
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
      'dash_company_data_section': 'Adatok vállalati szinten',
      'dash_company_data_show': 'Eredmények megjelenítése vállalatként',
      'dash_company_data_hide': 'Vállalati kategóriák elrejtése',

      'dash_rank': 'Helyezés',
      'dash_score': 'Pontszám',
      'dash_name': 'Név',

      'dash_delivered': 'Kiszállítva',
      'dash_rank_in_aion': 'Helyezés az AION-ban',
      'dash_rank_of_total': '{rank} / {total}',

      'dash_no_my_score_week':
          'Nem található pontszám a sofőr azonosítódhoz ezen a héten.',
      'dash_all_status': 'Minden statusz',
      'dash_search_name_or_id': 'Nev vagy Transporter ID keresese...',
      'dash_upload_driver_csv': 'Sofor CSV feltoltese',

      'scorecard_overview_title': 'SCORE CARD VEZERLOPULT',
      'scorecard_overview_overview_suffix': '— Attekintes',
      'scorecard_overview_upload_pdf': 'SCORECARD PDF FELTOLTESE',
      'scorecard_overview_upload_prompt': 'Toltsd fel a Scorecard PDF-et',
      'scorecard_overview_choose_file': 'Fajl kivalasztasa',
      'scorecard_overview_summary_title': 'Score Card osszegzes',
      'scorecard_overview_no_reports_yet':
          'Meg nincs jelentes. Toltsd fel az elso Scorecard PDF-et a kezdeshez.',
      'scorecard_overview_chart_title': 'Score Card attekintes',
      'scorecard_overview_best_drivers': 'Legjobb soforok',
      'scorecard_overview_no_reports_available': 'Nincs elerheto jelentes.',
      'scorecard_overview_no_drivers_period':
          'Erre az idoszakra nincs talalhato sofor.',
      'scorecard_overview_select_station': 'Allomas kivalasztasa',
      'scorecard_overview_all_stations': 'Minden allomas',
      'scorecard_overview_select_period': 'Idoszak kivalasztasa',
      'scorecard_overview_best_drivers_year': 'Ev legjobb soforjai',
      'scorecard_overview_best_drivers_month': 'Honap legjobb soforjai',
      'scorecard_overview_station': 'Allomas',
      'scorecard_overview_station_code': 'Allomas {code}',
      'scorecard_overview_upload_success_one':
          '1 scorecard feldolgozva es elmentve. A vezerlopult frissitve.',
      'scorecard_overview_upload_success_many':
          '{count} scorecard feldolgozva es elmentve. A vezerlopult frissitve.',
      'scorecard_overview_upload_parse_failed':
          'Feltoltes/feldolgozas sikertelen: {error}',
      'scorecard_overview_no_file_bytes': 'Nincs fajladat',
      'scorecard_overview_csv_updated':
          'A sofornevek frissultek az osszes jelentesben.',
      'scorecard_overview_csv_failed': 'CSV import sikertelen: {error}',
      'scorecard_overview_delete_report_q': 'Torlod a jelentest?',
      'scorecard_overview_delete_report_body':
          'Ez torli a(z) "{title}" jelentest es az adott het osszes pontbejegyzeset.',
      'scorecard_overview_deleted': 'A jelentes es a heti pontok torolve.',
      'scorecard_overview_delete_failed': 'Torles sikertelen: {error}',
      'scorecard_overview_more': 'Tovabb',
      'scorecard_overview_delete_report_menu': 'Jelentes torlese',
      'scorecard_overview_upload_processing':
          'Scorecardok feltoltese es feldolgozasa...',
      'scorecard_overview_row_title': 'Score Card {year} HET {week}',
      'scorecard_overview_reliability_score': 'Megbizhatosagi pontszam',
      'scorecard_overview_from_last_week': 'elozo hethez kepest',
      'scorecard_overview_from_last_year': 'elozo evhez kepest',

      'kpi_score': 'PONTSZÁM',
      'kpi_value': 'ÉRTÉK',
      'kpi_pro_tip': 'TIPP',

      'kpi_title_dcr': 'Kézbesítési Sikerességi Arány',
      'kpi_title_dnr': 'Kézbesítési Sikerfeltételek',
      'kpi_title_lor': 'Útközben Elveszett',
      'kpi_title_pod': 'Kézbesítéskori Fénykép',
      'kpi_title_cc': 'Ügyfélkapcsolat',
      'kpi_title_ce': 'Ügyfél Eszkaláció',
      'kpi_title_cdf': 'Ügyfél Kézbesítési Visszajelzés',

      'kpi_desc_dcr':
          'Minél magasabb az érték, annál jobb. A 100%-os sikerességi arány eléréséhez ajánlott sikertelen kézbesítés után újrakézbesítést* megkísérelni.',
      'kpi_tip_dcr':
          'Példa: Ha egy adott napon bármilyen okból nem tudsz kézbesíteni egy csomagot, és még ugyanazon a napon újra megpróbálod a kézbesítést, a DCR értéked magasabb lesz és közelebb kerül a 100%-hoz, még akkor is, ha a második kézbesítési kísérlet sem sikeres.',

      'kpi_desc_dnr':
          'DSC DPMO (Kézbesítési Sikerfeltételek)\n(korábban DNR – Kézbesítés nem történt meg)\n\nMinél alacsonyabb az érték, annál jobb.\n\nEz a mutató azt méri, hogy a kézbesítések mennyire helyesen és nyomon követhetően történnek.\n\nAlapvető kézbesítési szabályok:\n- Kézbesítés a megfelelő személynek vagy a megfelelő helyre\n- Ügyfeleknek, háztartás tagjainak, szomszédoknak vagy recepciósoknak történő kézbesítés megfelelő végrehajtás esetén alacsony kockázatú\n- Mindig a megfelelő szkennelési/indok kódot használd, hogy az ügyfelek helyes értesítéseket kapjanak\n\nPostaszoba / postaláda kézbesítések:\n- Kövesd a szabványos munkafolyamatot\n- A csomagoknak teljes egészében a postaládában vagy a postanyílásban kell lenniük, és nem lóghatnak ki\n- A lehető legpontosabb szkennelést használd\n\nHelyes cím és geofence:\n- Kézbesítés a megfelelő geofence 25 méteres körzetén belül\n- Az alkalmazásban szereplő nevet és címet mindig egyeztesd a csomagcímkével és az épülettel\n- Ha a geokód helytelennek tűnik, jelentsd SDS-en keresztül\n\nFénykép kézbesítéskor (POD):\n- Mindig készíts tiszta fényképet, amikor erre felszólítanak\n- A csomagnak és a környezetnek jól láthatónak kell lennie\n- Különösen fontos felügyelet nélküli kézbesítések és az ügyfélbizalom szempontjából\n\nKézbesítési preferenciák betartása:\n- Kövesd az alkalmazásban megadott ügyfélutasításokat, amennyiben azok biztonságosak\n- Ha az utasítások nem biztonságosak, vedd fel a kapcsolatot az ügyféllel\n- Csak az alkalmazásban jóváhagyott biztonságos helyeket használd\n\nEgyidejű / csoportos megállók:\n- A „Mind kijelölése” funkciót csak akkor használd, ha több csomagot ugyanannak a személynek vagy ugyanarra a helyre kézbesítesz (pl. recepció)\n- A címzett nevét és aláírását pontosan rögzítsd',

      'kpi_tip_dnr':
          'Fontos figyelmeztetés:\n\nAz ismételten magas DSC DPMO értékek helytelen vagy kockázatos kézbesítésekre utalnak.\n\n- A gyakori eltéréseket az Amazon potenciális lopásként értelmezheti\n- Ez veszteségmegelőzési eljárást indíthat el\n- A legrosszabb esetben az együttműködés megszüntetéséhez vezethet\n\nA gondos szkennelések, a megfelelő fényképek és az összes kézbesítési szabály betartása megvéd téged és a csapatodat.',

      'kpi_desc_lor':
          'LoR (Útközben Elveszett)\n\nMinél alacsonyabb az érték, annál jobb.\n\nEz a mutató azt mutatja, hogy az út végén minden nem kézbesített csomag helyesen lett-e rögzítve.\n\nAz út végén:\n- Ellenőrizd a szkennerben, hány csomagot kell visszavinni\n- Győződj meg róla, hogy ez a szám pontosan megegyezik a járműben lévő csomagok számával',

      'kpi_tip_lor':
          'Fontos figyelmeztetés:\n\nEz a kategória a legnagyobb lopásgyanúval jár.\n\nA szkenner és a jármű készlete közötti eltérések súlyos hibának minősülhetnek, és belső vizsgálatokhoz vagy további következményekhez vezethetnek.',

      'kpi_desc_pod':
          'PoD (Kézbesítéskori Fénykép)\n\nMinél magasabb az érték, annál jobb.\n\nEz az oszlop azokat a csomagokat mutatja, amelyekről készült fénykép, de Érvénytelen vagy Nem biztonságos jelölést kaptak.\n\nA POD elutasításának gyakori okai:\n1. A csomagcímkén láthatók az ügyfél adatai (a csomagot meg kell fordítani)\n2. Elmosódott fénykép\n3. Személy látható a fényképen\n4. Nem látható csomag a fényképen\n5. Csomag a járműben\n6. Csomag kézben\n7. A csomag túl közel van a kamerához\n8. A fénykép túl sötét',

      'kpi_tip_pod':
          'Ez kell legyen a legegyszerűbb kategória\nCélérték: 100%\nJelentősen javítja az összpontszámot',

      'pod_quality_title': 'POD minőség',
      'pod_quality_success': 'Siker',
      'pod_quality_rejects': 'Elutasítások',
      'pod_quality_opp': 'Lehetőségek',
      'pod_quality_bypass': 'Átugrás',
      'pod_quality_blurry': 'Elmosódott',
      'pod_quality_too_dark': 'Túl sötét',
      'pod_quality_no_package': 'Nincs csomag',
      'pod_quality_in_car': 'Az autóban',
      'pod_quality_too_close': 'Túl közel',
      'pod_quality_shell_week_title': 'POD MINOSEG - HET',
      'pod_quality_week_label': '{week}. het',
      'pod_quality_dashboard_title': 'POD MINOSEG VEZERLOPULT',
      'pod_quality_upload_pdf': 'PDF feltoltese',
      'pod_quality_no_reports_uploaded':
          'Meg nincs POD minosegi jelentes. Tolts fel egy POD PDF-et a kezdeshez.',
      'pod_quality_upload_success_one':
          '1 POD minosegi jelentes feldolgozva es elmentve.',
      'pod_quality_upload_success_many':
          '{count} POD minosegi jelentes feldolgozva es elmentve.',
      'pod_quality_upload_parse_failed':
          'Feltoltes/feldolgozas sikertelen: {error}',
      'pod_quality_rejects_breakdown': 'Elutasitasok bontasa',
      'pod_quality_no_data_week': 'Nincs POD adat erre a hetre.',
      'pod_quality_drivers': 'Soforok',
      'pod_quality_entries_count': '{count} bejegyzes',

      'kpi_desc_cc':
          'CC (Ügyfélkapcsolat)\n\nMinél magasabb az érték, annál jobb.\n\nRendkívül fontos:\nMINDIG küldened kell egy „Nincs biztonságos hely” vagy „Cím nem található” üzenetet minden alkalommal, amikor nem tudsz kézbesíteni egy csomagot, mert:\n\n- az ügyfél nincs otthon vagy\n- a cím nem található',

      'kpi_tip_cc':
          'Minden forgatókönyvre létezik automatikus alapértelmezett üzenet az alkalmazásban.',

      'kpi_desc_ce':
          'CE (Ügyfél Eszkaláció)\n\nMinél alacsonyabb az érték, annál jobb.\nA legrosszabb kategória mind közül.\n\nAz ügyfelek akkor eszkalálnak, ha a kézbesítési utasításokat nem tartják be.\n\nA sofőr mindig felelős\nFellebbezések nagyon erős bizonyítékok nélkül szinte lehetetlenek\nA legerősebb hatással van a Scorecardodra\n\nHogyan kerüld el a CE-t\n\nA kézbesítési irányelvek ellen van, ha engedély nélkül nem biztonságos vagy felügyelet nélküli helyeken hagyod a csomagokat\n\nA Delivery Associates kötelesek:\n- Csengetni / kaputelefont használni vagy kopogni\n- Elegendő időt adni az ügyfélnek a válaszadásra\n\nHa az ügyfél nem érhető el, és nincs rögzítve biztonságos hely:\n- Az ügyfelet kétszer felhívni\n- Szöveges üzenetet küldeni\n- Driver Supporttal kapcsolatba lépni, ha nincs lehetőség kapcsolatra\n\nSzükség esetén:\n- A csomagot „Sikertelen kézbesítés – ügyfél nem elérhető” státusszal szkennelni\n- Az irányelveknek megfelelően újrapróbálni a kézbesítést',

      'kpi_tip_ce':
          'Ne hagyj csomagokat nem biztonságos vagy nem jóváhagyott helyeken\nMindig tartsd be a helyes szállítási és kézbesítési folyamatokat',

      'kpi_desc_cdf':
          'CDF DPMO (Ügyfél Kézbesítési Visszajelzés)\n\nMinél alacsonyabb az érték, annál jobb.\n\n1. szint (L1)\n- Az ügyfél a kézbesítést „Nagyszerű” (👍) vagy „Nem olyan jó” (👎) értékeléssel látja el\n\n2. szint (L2)\n- További visszajelzés arról, miért volt a tapasztalat jó vagy rossz',

      'kpi_tip_cdf': 'A CDF kizárólag L1 szinten kerül kiszámításra',

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

      // =========================
      // HUNGARIAN (hu) – FAQ keys
      // =========================

      // FAQs
      'faq_title': 'Gyakran ismételt kérdések',
      'faq_search_hint': 'Kérdések keresése',
      'faq_empty': 'Nem található megfelelő GYIK.',
      'driver_tasks_error': 'Hiba: {error}',
      'driver_tasks_no_tasks': 'Meg nincs hozzad rendelt feladat.',
      'driver_tasks_update_status': 'Allapot frissitese',
      'driver_tasks_confirm_completed': 'Befejezettkent megerosites',
      'driver_tasks_set_completed_first':
          'Eloszor allitsd az allapotot "Befejezett"-re.',
      'driver_tasks_completion_confirmed': 'Teljesites megerositve.',
      'driver_tasks_failed_update_status':
          'Az allapot frissitese sikertelen: {error}',
      'driver_tasks_failed_confirm_task':
          'A feladat megerositese sikertelen: {error}',
      'driver_tasks_status_confirmed_by_you': 'Allapot altalad megerositve.',
      'driver_tasks_confirm_when_fully_done':
          'Kerjuk, erositsd meg, amikor ez a feladat teljesen kesz.',
      'driver_tasks_status_pending': 'Fuggoben',
      'driver_tasks_status_in_progress': 'Folyamatban',
      'driver_tasks_status_completed': 'Befejezett',
      'faq_green_book_video_title': 'Green Book oktatóvideó',
      'faq_green_book_video_subtitle':
          'Nézd meg lépésről lépésre, hogyan kell kitölteni a Green Bookot',
      'faq_green_book_video_action': 'Videó lejátszása',
      'faq_green_book_video_missing':
          'A Green Book videólink még nincs beállítva.',
      'faq_green_book_video_open_failed':
          'A Green Book videólink nem nyitható meg.',

      'faq_q1': 'Mi a legfontosabb a napi feladatod során?',
      'faq_a1': 'A csomagok minőségi kézbesítése és a megfelelő viselkedés.',

      'faq_q2': 'Mit NE tegyél, ha problémád van az ügyféllel?',
      'faq_a2':
          'NE próbáld meg egyedül kezelni a helyzetet, hanem értesítsd a szolgálatos diszpécsert. Mi megpróbálunk az ügyféllel beszélni helyetted, és elkerülni az Amazon felől érkező negatív következményeket az ügyfélpanaszok miatt. Itt vagyunk neked!',

      'faq_q3':
          'Mi van akkor, ha a helyzet már elmérgesedett, és az ügyfél valami miatt nem elégedett?',
      'faq_a3':
          'Soha nincs túl késő kijavítani a hibákat. Hívj minket akkor is, és megpróbáljuk rendezni a helyzetet az ügyféllel. Jobb későn, mint soha.',

      'faq_q4':
          'Mi a fontosabb: Mennyiség (minél gyorsabban minél több megálló) vagy Minőség?',
      'faq_a4':
          'Minőség! Mindig minőség! Kövesd az ügyfél utasításait, és NE hagyd a csomagot nem biztonságos helyen csak azért, mert le vagy maradva a megállókkal.',

      'faq_q5':
          'Mi van, ha a minőségre figyelek, de emiatt lemaradok a megállókkal?',
      'faq_a5':
          'Be fogod fejezni a megállókat, valahogy. Megpróbálunk segítséget küldeni, de csak akkor, ha ezt ésszerűnek látjuk.',

      'faq_q6': 'Mi az a scorecard és mi az a DNR?',
      'faq_a6': 'Örülünk, hogy megkérdezted.',

      // 7 – Weekly scorecard
      'faq_q7': 'Heti scorecard',
      'faq_a7':
          'A heti scorecard gyors, átlátható képet ad arról, hogyan teljesít a csapat a fő céljaink mentén. '
          'Segít látni, mi megy jól, hol maradunk el, és mire kell fókuszálnunk a következő héten.\n\n'
          'Az összesített értékelések:\n'
          '• Fantastic Plus: >93% (kiemelkedő teljesítmény)\n'
          '• Fantastic: 85% – 92,9%\n'
          '• Great: 70% – 84,9%\n'
          '• Fair: 50% – 69,9%\n'
          '• Poor: <50%',

      'faq_q7_1': 'DNR fül\nDelivered Not Received',
      'faq_a7_1':
          'Akkor fordul elő, amikor kézbesítettél egy csomagot, és a „Swipe to finish” gombbal megerősítetted a kézbesítést, '
          'de az ügyfél mégsem kapta meg a csomagot különböző okok miatt: csomaglopás, üres doboz, vagy rossz címre történő kézbesítés.\n'
          'Minden kedden képeket kapsz az összes DNR-esetedről az adott héten.',

      'faq_q7_1_1':
          'Hogyan kerülhetem el ezt, és mennyire fontos ez a heti scorecardban?',
      'faq_a7_1_1':
          'Nagyon fontos. Ennek elkerüléséhez előre értesítsd az ügyfelet, hogy hamarosan érkezel, és CSAK annál a csengőnél csengess, amelyen az ő neve szerepel.',

      'faq_q7_1_2': 'Hogyan kerülhetem el a csomagok eltűnését?',
      'faq_a7_1_2':
          'Mindig próbáld a csomagokat kézből átadni az ügyfélnek. Ha ez nem lehetséges, küldj üzenetet, és írd meg, hol hagytad a csomagot, '
          'például a garázsban, a lépcső alatt, a fészerben, a virágcserép mögött stb.\n'
          'Ha nem érzed biztonságosnak a felügyelet nélküli lerakást, inkább vidd magaddal a csomagot, és próbáld meg később újra. Ez NAGYON fontos.',

      'faq_q7_1_3': 'Honnan tudom, hogy egy hely biztonságos-e vagy sem?',
      'faq_a7_1_3':
          'Ösztön és józan ész. Ha egy épület 20–30 emeletes, és a postaládáknál hagyod a csomagot, sokkal nagyobb az esélye a lopásnak, '
          'mintha egy családi házban kézbesítenéd.\n'
          'Emellett, hogy segítsünk a napi kézbesítésekben és elkerüld a DNR-t, minden reggel közzéteszünk egy képet olyan címekről, '
          'amelyeknél nagy a csomaglopás és panasz esélye a korábbi eredmények és statisztikák alapján.',

      'faq_q7_1_4':
          'Mi van, ha egy csomag elveszik vagy ellopják? Hogyan hat ez a pontszámomra?',
      'faq_a7_1_4':
          'Nagyon rosszul. Ez legalább 30%-kal ronthatja a pontszámodat, és már egyetlen csomag is legalább 600 pont veszteséget jelenthet. '
          'Minél több pont szerepel a scorecardban a neved mellett, annál rosszabb. Minél több csomagot kézbesítesz egy munkahéten, annál kevesebb pontot veszítesz egy esetnél. '
          'A pontveszteség az eltűnt áru értékétől is függ: minél drágább, annál több pont.\n'
          'Fontos továbbá: ha rendszeresen sok az elveszett csomagod, el kell küldenünk, mert az Amazon előbb-utóbb csomaglopásra gyanakodhat. Ez nagyon veszélyes.',

      // CC
      'faq_q7_2': 'CC fül\nContact Compliance',
      'faq_a7_2':
          'Azt mutatja, hányszor léptél kapcsolatba az ügyféllel a kézbesítés kapcsán – üzenetben vagy telefonon. '
          'Minél kevesebbet kommunikálsz az ügyféllel, annál alacsonyabb lesz a pontszámod ebben a kategóriában. '
          'Ezt a részt a lehető legmagasabban kell tartani, mert ez az egyik legegyszerűbb kategória, és sokat javít az összpontszámon.',

      'faq_q7_2_1': 'Miért kell ezt csinálnom?',
      'faq_a7_2_1':
          'A csomagkézbesítés nem csak „lerak és kész”. Előre tájékoztasd az ügyfelet, és kérdezd meg, hova szeretné, hogy a csomag kerüljön.',

      'faq_q7_2_2': 'Hogyan javíthatom a CC pontszámomat?',
      'faq_a7_2_2':
          'Köszönjük a kérdést. Egyszerű: hívással, és különösen üzenetküldéssel szinte minden megállónál.',

      // CE
      'faq_q7_3': 'CE fül\nÜgyfél-eszkaláció',
      'faq_a7_3':
          'Emlékszel, milyen rosszul hatott a DNR a pontszámodra? Ez legalább kétszer olyan rossz, és akár az állásodat is kockáztatod – attól függően, mennyire súlyos volt a helyzet.',

      'faq_q7_3_1': 'Hogyan kerülhetem el ezt?',
      'faq_a7_3_1':
          'Mindig kövesd az ügyfél kézbesítési utasításait. Hiba esetén először kérj elnézést. '
          'Ha az ügyfél mérges, kérd meg, hogy adjon egy percet, hogy beszélhessen velünk – miközben te már hívsz minket. '
          'A 2. szakasz alapján mostanra tudnod kell, hogy a legjobb, ha az ilyen helyzeteket ránk bízod.',

      // POD
      'faq_q7_4': 'POD fül\nKép a kézbesítésről',
      'faq_a7_4':
          'Ez az oszlop azokat a csomagokat mutatja, amelyeknél POD-fotó szükséges, és készült is fotó, de az „Invalid” vagy „Not Sure” minősítést kapott. '
          'A POD elutasításának okai lehetnek:\n'
          '1- A fotón látszik a címke az ügyfél adataival. A csomagot a fotó előtt fordítsd meg.\n'
          '2- Homályos fotó\n'
          '3- Személy látható a fotón\n'
          '4- Nem látható csomag a fotón\n'
          '5- Csomag az autóban\n'
          '6- Csomag kézben\n'
          '7- Csomag a postaládában\n'
          '8- Túl közeli fotó\n'
          '9- Túl sötét fotó.\n'
          'Ennek mindig a legegyszerűbbnek kell lennie: 100%-os eredményre kell törekedni, és javítja az összpontszámot.',

      // LoR
      'faq_q7_5': 'LoR fül\nLost on Road',
      'faq_a7_5':
          'Akkor kapsz büntetést, ha a rakodásnál beszkenneltél egy csomagot, de a műszak végén nem hoztad vissza sikertelen kézbesítés esetén. '
          'Ilyenkor a csomag elveszettnek számít, és annyi pontot veszíthetsz, mint egy DNR-nél. '
          'Számold meg pontosan a visszahozott csomagokat, és ellenőrizd, hogy egyeznek-e a scannerben látható listával. '
          'Ezt itt találod: Today’s Itinerary – Summary – Problems. Ha nem egyezik, még a műszak lezárása előtt jelezd a szolgálatos diszpécsernek az Amazon appban.',

      // DCR
      'faq_q7_6': 'DCR fül\nDelivery Completion Rate',
      'faq_a7_6':
          'A csomagkézbesítési képességedet mutatja. Azt követi, hogy a tervezett kézbesítések hány százalékát teljesítetted, '
          'és segít mérni a hatékonyságot és megbízhatóságot. Kiemeli a problémákat, mint késések, sikertelen kísérletek vagy útvonal-problémák. '
          'Ennek mindig a lehető legmagasabbnak kell lennie. Ehhez naponta végezz újrapróbálkozásokat (reattempt), és amennyire csak lehet, kerüld a visszahozást.',

      // CDF
      'faq_q7_7': 'CDF fül (korábban: DEX)\nÜgyfél kézbesítési visszajelzés',
      'faq_a7_7':
          'Az ügyfél kézbesítési élményét rögzíti, beleértve a pontosságot, az áru állapotát és a sofőr professzionalizmusát. '
          'Segít az erősségek és fejlesztendő területek azonosításában. A kézbesítés után az ügyfél e-mailt kap az Amazontól a kézbesítési élményről, például ilyen kérdésekkel:\n'
          '1) Időben érkezett meg a csomag?\n'
          'Igen / Nem\n'
          '2) Biztonságos helyen lett lerakva a csomag?\n'
          'Igen / Nem\n'
          '3) Jó állapotban érkezett meg a csomag?\n'
          'Igen / Nem\n'
          '4) Mennyire vagy összességében elégedett a kézbesítéssel?\n'
          'Nagyon elégedett / Elégedett / Semleges / Elégedetlen / Nagyon elégedetlen\n'
          '5) Hogyan értékeled a kommunikációt és a követési (tracking) frissítéseket ehhez a kézbesítéshez?\n'
          'Kiváló / Jó / Közepes / Rossz\n'
          '6) Udvarias és professzionális volt a kézbesítő?\n'
          'Igen / Nem / Nem alkalmazható (kontaktmentes kézbesítés)\n'
          '7) Van-e megjegyzésed a kézbesítési élménnyel kapcsolatban?\n'
          '(Ügyfél megjegyzései)',

      'faq_q7_8': 'Mit tartsak észben a scorecarddal kapcsolatban?',
      'faq_a7_8':
          'A minőség és a hatékonyság sokat számít. A jó pontszám jó neked, jó a cégnek és jó az egész csapatnak. Az ügyfél-elégedettség nagyon fontos, '
          'és a jó pontszámokat a cég bónusszal jutalmazza.\n'
          'Add a legjobbat, kapd a legjobbat.',

      // 8+
      'faq_q8': 'Milyen más területekre kell még figyelnem?',
      'faq_a8':
          'Vigyázz magadra: vezess biztonságosan, kerüld a sérüléseket, és figyelj a kutyákra/kutyaharapásra. '
          'Óvd a munkaeszközöket is, például a napi járművet és a munka scannert/telefont. '
          'Munkába mindig biztonsági cipőben és láthatósági mellényben érkezz, valamint Amazon kabátban vagy pólóban (az időjárástól függően).',

      'faq_q9':
          'Mi történik, ha balesetet okozok vagy megsértem a munkajárművet?',
      'faq_a9':
          'Először is győződj meg róla, hogy jól vagy, és nem sérültél meg súlyosan. '
          'A járműkár kapcsán: ha úgy ítéljük meg, hogy a baleset gondatlanságból történt – például figyelemelterelés, mint a telefonhasználat vezetés közben –, '
          'akkor személyesen felelsz a teljes kárért. Emellett rendőrségi jegyzőkönyvet kapsz, ami akár jogosítványfelfüggesztéshez is vezethet. '
          'Ez akár azonnali elbocsátás oka is lehet. Egyéb esetben „csak” 2 hónapra kizárunk a heti Scorecard bónuszokból. '
          'Esemény esetén köteles vagy azonnal értesíteni minket, és elküldeni az időpontot, helyszínt, hogy történt-e kár magán- vagy közterületen (falak, kerítések, lámpaoszlopok, emberek és/vagy állatok), valamint a kár helyét és fotókat a sérülésekről.',

      'faq_q10': 'Mit tegyek, ha a csomag sérült és/vagy hiányzik?',
      'faq_a10':
          'Ha egy csomag sérült, nyugodtan könyveld sérültnek, és vidd vissza a állomásra. '
          'Ha folyadékos csomag volt, és más csomagokat is megrongált, készíts fotót az összes sérült csomagról, és küldd el a szolgálatos diszpécsernek – mi jelentjük az Amazon felé.\n'
          'Ha egy csomag hiányzik, jelölheted hiányzónak – kivéve, ha OTP-s. OTP esetén ELŐSZÖR jelentsd nekünk, mielőtt hiányzónak jelölöd. Ez NAGYON fontos.',

      'faq_q11': 'Mi az az OTP (One-Time Password) csomag?',
      'faq_a11':
          'Ez egy drága termék, amelynél az Amazon megköveteli, hogy az ügyfél egy egyszer használatos jelszót (OTP) adjon a sofőrnek kézbesítés előtt, '
          'hogy biztosan a megfelelő személy kapja meg. Kiemelten figyelj az ilyen csomagokra: ne hagyd felügyelet nélkül, és csak annak add át, aki megadta a jelszót.',

      'faq_q12': 'Miért mondjuk folyton, hogy lassíts, és ne menj gyorsabban?',
      'faq_a12':
          'Mi sem szeretjük, de így működik a rendszer. Követnünk kell az algoritmust, és a meghatározott óránkénti megálló-számot, '
          'hogy a jövőben több útvonalat kapjunk, te pedig többet dolgozhass, és ne legyél „sz_strip” (szabad).\n'
          'Ráadásul, ha túl gyorsan mész, megnő a DNR kockázata, és pontokat veszítesz – te is, és a cég is – a heti scorecardban.',

      'faq_q13':
          'A diszpécserek miért kérdezik néha, hogy miért vagy lemaradva, és hogy van-e valami probléma?',
      'faq_a13':
          'Tudjuk, hogy ez nem kellemes, de szükségünk van visszajelzésre, mi történt az úton, ami miatt lemaradtál a megállókkal. '
          'Amazon ezt a visszajelzést kéri tőlünk, mert időlimit is van, ameddig X megállót teljesítened kellett volna. Ezek az információk segítenek az Amazonnak a jövőbeli kézbesítési hatékonyság javításában.',

      'faq_q14': 'Miért kérjük néha, hogy menj és segíts egy kollégának?',
      'faq_a14':
          'Mert sok tényező okozhat késést: rossz internet a környéken, forgalom, útlezárások/építkezések, amelyek megnehezítik az időben történő kézbesítést. Ilyenkor szükség van a segítségedre.',

      'faq_q15':
          'Az első napomon rögtön ugyanazokat a standard útvonalakat kapom, mint a tapasztalt sofőrök?',
      'faq_a15':
          'Nem, természetesen nem. Kezdetben 14 munkanapos időszakod van, hogy a trénerrel töltött ride-along napokon tanultakat gyakorold, '
          'és hozzászokj a területhez, az autóhoz, a scannerhez és a munkafolyamathoz.\n'
          'Ebben a 14 napban az Amazon akár 50%-kal kevesebb csomagot és megállót ad a szokásosnál.',

      'faq_q16':
          'Mit tegyek, ha rossz a cím és/vagy a térképen nem jó a helyszín-pin?',
      'faq_a16':
          'Először ellenőrizd, hogy a pin tényleg rossz-e: keresd meg a címet Google Maps-ben (pontosabb, és a scannereden is telepítve van). '
          'Ha nem egyezik, jelezd a szolgálatos diszpécsernek a hibát.',

      'faq_q17':
          'Mik a napi feladataim a munka kezdése előtt és a munka végén?',
      'faq_a17':
          '1- Amikor a parkolóba érkezel, először ellenőrizd, hogy rajtad van-e a biztonsági cipő, a láthatósági mellény és az Amazon egyenruha.\n'
          '2- Ellenőrizd, hogy a scanner teljesen fel van-e töltve, és jelezd a jelenlévő diszpécsernek, ha nincs.\n'
          '3- Nézd meg, van-e valami probléma az autóval.\n'
          '4- Indítsd el a Mentor appban a tripet a scannereden.\n'
          '5- Küldj képet a műszerfalról: aktuális kilométeróra-állás és a napi trip (az autóban) 0-ra resetelve.\n'
          '6- Csak 10 perccel a tervezett rakodási idő előtt menj le a Waiting Area-ba – ne korábban.\n'
          '7- A Waiting Area-ban: motor leállít, Flex App és Timesheet indítás. Kérlek, ne egy perccel sem előbb, különösen a Flex Appot. Ne felejtsd el a 10 perces időbélyeget.\n'
          '8- Végül menj a Loading Area-ba a Yard Marshall utasításai szerint. Ott motor leállít, és csak AZUTÁN szállj ki, hogy hallottad a Yard Marshall sípját.\n'
          '9- Rakodás után indítsd be az autót, és csak akkor indulj el, ha a Yard Marshall utasít rá.\n'
          '10- Miután végeztél az összes megállóval, ellenőrizd az üzemanyagszintet, és ha fél tank alatt van, tankolj.\n'
          '11- Az állomáson tedd le a megmaradt csomagokat az Amazon által kijelölt helyekre, a táskákat időben add le.\n'
          '12- A parkolóban állítsd le az autót, töltsd ki a Green Bookot (Tageskontrollblatt), és küldj képet a napi megtett kilométerről, valamint a Green Bookról.\n'
          '13- Állítsd le az autót, és vidd vissza a munkatáskát a kijelölt helyre.',

      'faq_q18':
          'Kell-e bármit csinálnom, ha furgont cserélek, és nem a megszokottat viszem?',
      'faq_a18':
          'Készíts róla videót, amely részletesen mutatja az összes apró sérülést, amit az előző sofőr(ök) okozhattak, hogy a következő ellenőrzésnél ne téged hibáztassanak.',

      'faq_q19':
          'Mit tegyek, ha a Flex app folyamatosan tölt, és lelassítja a munkafolyamatot?',
      'faq_a19':
          'Először ellenőrizd, hogy van-e aktív internetkapcsolat. Ezt úgy tudod tesztelni, hogy üzenetet küldesz az aktuális megállónál lévő ügyfélnek. '
          'Ha átmegy, akkor van internet. Ezt úgy is ellenőrizheted, hogy megnyitsz egy másik appot (pl. böngésző), és keresel valamit.\n'
          'Lépések, ha nincs aktív internet:\n'
          '1- Indítsd újra a scannert. Ez legyen mindig az első.\n'
          '2- Kapcsold be/ki a repülő módot. Ez gyakran működik újraindítás nélkül is.\n'
          '3- Utolsó lehetőségként ossz meg hotspotot a saját telefonodról legfeljebb 10 percre, hogy a rendszer frissíteni tudjon.\n'
          'Offline is dolgozhatsz, de egy ponton újra csatlakoznod kell. Offline munkához előbb le kell töltened az offline térképeket a Flex appban: Settings – Offline Maps (utolsó opció) – Download DBY5 – Allow downloads with mobile connection.\n',

      'faq_q20':
          'Mi van, ha van internet, de a Flex app mégsem működik rendesen?',
      'faq_a20':
          '1- Scanner újraindítása.\n'
          '2- Repülő mód be/ki\n'
          '3- Kilépés az appból\n'
          '4- Helymeghatározás (GPS) ki/be\n'
          '5- Kijelentkezés a Flex appból, majd bejelentkezés újra (a Mentor apphoz használt adatokkal).\n'
          '6- Ellenőrizd, hogy van-e frissítés az apphoz.\n'
          'Ezeket a lépéseket egymás után próbáld ki. Ha az egyik nem működik, menj a következőre.',
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
      'header_good_afternoon': 'BUNĂ ZIUA',
      'header_good_evening': 'BUNĂ SEARA',
      'select_language': 'Selectează limba',
      'notifications': 'Notificări',
      'no_notifications': 'Nu există notificări',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Ajutor',
      'nav_rules': 'Reguli',
      'nav_profile': 'Profil',
      'nav_tasks': 'Sarcini',
      'driver_home_dispatcher': 'Dispecer',
      'driver_home_shift_plan_title': 'Plan tura',
      'driver_home_shift_plan_subtitle': 'Turele tale',
      'driver_home_scorecard_subtitle': 'Prezentarea performantei tale',
      'driver_home_tasks_title': 'Sarcini',
      'driver_home_tasks_subtitle': 'Gestioneaza sarcinile deschise',
      'driver_home_academy_subtitle': 'Instruire & cunostinte',
      'driver_home_rules_title': 'Regulile companiei',
      'driver_home_rules_subtitle': 'Ghiduri & politici',
      'driver_notification_published_on': 'Publicat {date}',
      'driver_home_vehicles_title': 'Vehicule',
      'driver_home_vehicles_subtitle': 'Prezentare vehicule',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'Asistentul tau AI',
      'driver_home_absence_title': 'Absenta',
      'driver_home_absence_subtitle': 'Concediu & medical',
      'driver_home_incident_title': 'Raport incident',
      'driver_home_incident_subtitle': 'Raporteaza un accident',
      'driver_home_new_badge': 'NOU',
      'driver_academy_title': 'DA Academy',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle':
          'Ghid pentru fisa zilnica de inspectie',
      'driver_academy_safety_title': 'Training de siguranta',
      'driver_academy_safety_subtitle': 'Cursuri de siguranta',
      'driver_academy_delivery_title': 'Livrare Amazon',
      'driver_academy_delivery_subtitle': 'Procese si fluxuri de livrare',
      'driver_academy_app_title': 'Aplicatia CoDriver',
      'driver_academy_app_subtitle': 'Functii si ghiduri ale aplicatiei',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - Video de instruire',
      'driver_green_book_video_subtitle': 'Apasa pentru redare',
      'driver_green_book_start_test': 'Porneste testul Green Book',
      'driver_green_book_test_required': 'Test obligatoriu',
      'driver_green_book_section1_title':
          'Fisa zilnica de inspectie Green Book',
      'driver_green_book_section1_text':
          'Fisa zilnica de inspectie (Green Book) este un document obligatoriu care trebuie completat inainte de fiecare tura. Ajuta la verificarea starii vehiculului si documenteaza punctele de siguranta.',
      'driver_green_book_section1_b1':
          'Completeaz-o integral inainte de fiecare tura.',
      'driver_green_book_section1_b2':
          'Raporteaza imediat defectele vehiculului.',
      'driver_green_book_section1_b3': 'Nu uita semnatura.',
      'driver_green_book_section2_title': 'Consecinte ale nerespectarii',
      'driver_green_book_section2_text':
          'Abaterile sunt tratate in pasi progresivi:',
      'driver_green_book_section2_b1':
          'Primul avertisment: avertisment verbal de la dispecer.',
      'driver_green_book_section2_b2':
          'Al doilea avertisment: avertisment scris.',
      'driver_green_book_section2_b3': 'Abateri repetate: masuri disciplinare.',
      'driver_green_book_section3_title': 'Sanctiuni legale',
      'driver_green_book_section3_text':
          'Daca Green Book lipseste sau este incomplet la control:',
      'driver_green_book_section3_b1':
          'Amenda de pana la 5000 EUR pentru sofer.',
      'driver_green_book_section3_b2':
          'Amenda de pana la 30000 EUR pentru companie.',
      'driver_green_book_section3_b3': 'Se pot inregistra puncte in Flensburg.',
      'driver_green_book_section3_b4': 'Poate afecta negativ asigurarea.',
      'driver_green_book_test_title': 'Test Green Book',
      'driver_green_book_test_progress': 'Intrebarea {current} din {total}',
      'driver_green_book_test_next': 'Urmatorul',
      'driver_green_book_test_submit': 'Trimite testul',
      'driver_green_book_test_result_pass_title': 'Test promovat',
      'driver_green_book_test_result_fail_title': 'Test nepromovat',
      'driver_green_book_test_result_pass_body':
          'Felicitari! Ai promovat testul cu {score}/{total}.',
      'driver_green_book_test_result_fail_body':
          'Ai obtinut {score}/{total}. Incearca din nou.',
      'driver_green_book_test_retry': 'Incearca din nou',
      'driver_green_book_test_close': 'Inchide',
      'driver_green_book_test_back_to_green_book': 'Inapoi la Green Book',
      'driver_green_book_test_no_questions':
          'Nu exista inca intrebari configurate pentru test. Contacteaza dispecerul.',
      'driver_green_book_test_offline_fallback':
          'Sincronizarea live a testului a esuat. Poti continua cu intrebari fallback si sa incerci din nou.',
      'admin_home_notification': 'Notificare',
      'admin_home_driver_fallback': 'Sofer',
      'admin_home_not_confirmed_by': 'NU A CONFIRMAT:',
      'admin_home_missing_loading': 'lipsesc: ...',
      'admin_home_missing_unknown': 'lipsesc: --',
      'admin_home_missing_count': 'lipsesc: {count}',
      'admin_home_error_generic': 'Eroare: {error}',
      'admin_home_all_drivers_confirmed': 'Toti soferii au confirmat.',
      'admin_home_close': 'Inchide',
      'admin_home_last_week': 'Saptamana trecuta',
      'admin_home_not_logged_in': 'Nu esti autentificat.',
      'admin_home_loading_reports': 'Se incarca rapoartele...',
      'admin_home_no_reports_uploaded': 'Nu exista inca rapoarte incarcate.',
      'admin_home_week_short': 'SAPT',
      'admin_home_month_prefix': 'LUNA',
      'admin_home_year_prefix': 'AN',
      'admin_home_loading_scores': 'Se incarca scorurile...',
      'admin_home_name_fallback': 'Prenume Nume',
      'admin_home_scorecard': 'Scorecard',
      'admin_home_company_score': 'SCORUL COMPANIEI',
      'admin_home_of': 'din',
      'admin_home_best_driver': 'Cel mai bun sofer',
      'admin_home_worst_defender': 'Cel mai slab defender',
      'admin_home_notification_history': 'Istoric notificari',
      'admin_home_no_notifications_yet': 'Nu exista notificari inca.',
      'admin_home_notification_type_message': 'MESAJ NOU',
      'admin_home_notification_type_academy': 'DA ACADEMY',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'REGULA NOUA',
      'admin_home_edit_rule': 'Editeaza regula',
      'admin_home_title': 'Titlu',
      'admin_home_body': 'Continut',
      'admin_home_cancel': 'Anuleaza',
      'admin_home_save': 'Salveaza',
      'admin_home_title_or_body_required':
          'Titlul sau continutul este obligatoriu.',
      'admin_home_notification_not_found': 'Notificarea nu a fost gasita.',
      'admin_home_rule_updated_for_drivers':
          'Regula a fost actualizata pentru {count} soferi.',
      'admin_home_edit_failed': 'Editarea a esuat: {error}',
      'admin_home_delete_notification_question': 'Stergi notificarea?',
      'admin_home_delete_notification_body':
          'Aceasta notificare va fi stearsa pentru tine si pentru toti soferii.',
      'admin_home_delete': 'Sterge',
      'admin_home_notification_deleted': 'Notificarea a fost stearsa.',
      'admin_home_delete_failed': 'Stergerea a esuat: {error}',
      'admin_home_options': 'Optiuni',
      'admin_home_title_upper': 'TITLU',
      'admin_home_confirmed_by': 'confirmat de',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Service',
      'admin_home_accidents': 'Accidente',
      'admin_home_total': 'total',
      'admin_home_active': 'active',
      'admin_home_inactive': 'inactive',
      'admin_home_doc_id_card': 'Carte de identitate',
      'admin_home_doc_driving_license': 'Permis de conducere',
      'admin_home_doc_residence_permit': 'Permis de sedere',
      'admin_home_loading_drivers': 'Se incarca soferii...',
      'admin_home_no_drivers_yet': 'Nu exista soferi inca.',
      'admin_home_contract': 'Contract',
      'admin_home_last_day': 'ultima zi',
      'admin_home_probation': 'Perioada de proba',
      'admin_home_ended': 'incheiat',
      'admin_home_ends': 'se termina',
      'admin_home_expired_by': 'expirat la',
      'admin_home_loading_documents': 'Se incarca documentele...',
      'admin_home_driver_documents': 'Documente soferi',
      'admin_home_expired_documents': 'Documente expirate',
      'admin_home_expired_soon': 'expira curand',
      'admin_home_missing_documents_data': 'Documente / date lipsa',
      'admin_home_total_missing': 'total lipsa',
      'admin_home_driver_contracts': 'Contracte soferi',
      'admin_home_last_day_soon': 'ultima zi curand',
      'admin_home_no_items': 'Nu exista elemente',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'Schimbă poza de profil',
      'profile_change_photo': 'Schimbă poza de profil',
      'logout': 'Deconectare',
      'profile_logout': 'Deconectare',
      'pin_change_with_old':
          'Poți schimba PIN-ul după verificarea celui vechi.',
      'pin_forgot_contact_admin':
          'Ai uitat PIN-ul? Contactează administratorul.',
      'profile_photo_updated': 'Poza de profil a fost actualizată.',
      'failed_upload_profile_photo':
          'Încărcarea pozei de profil a eșuat: {error}',
      'could_not_read_image_bytes':
          'Nu s-au putut citi datele imaginii din selectorul de fișiere.',

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
      'dash_no_reports_uploaded':
          'DSP-ul tău nu a încărcat încă rapoarte scorecard.',
      'dash_scorecard_week': 'SĂPTĂMÂNA SCORECARD {week}',
      'dash_week_range': 'Săptămâna {week}, {year}',
      'dash_no_scores_period':
          'Nu există scoruri pentru această perioadă încă.',
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
      'dash_company_data_section': 'Date la nivel de companie',
      'dash_company_data_show': 'Arată rezultatele ca companie',
      'dash_company_data_hide': 'Ascunde categoriile companiei',

      'dash_rank': 'Rang',
      'dash_score': 'Scor',
      'dash_name': 'Nume',

      'dash_delivered': 'Livrate',
      'dash_rank_in_aion': 'Rang în AION',
      'dash_rank_of_total': '{rank} din {total}',

      'dash_no_my_score_week':
          'Nu a fost găsit niciun scor pentru ID-ul tău de șofer în această săptămână.',
      'dash_all_status': 'Toate statusurile',
      'dash_search_name_or_id': 'Cauta nume sau ID Transporter...',
      'dash_upload_driver_csv': 'Incarca CSV soferi',

      'scorecard_overview_title': 'TABLOU SCORE CARD',
      'scorecard_overview_overview_suffix': '— Prezentare',
      'scorecard_overview_upload_pdf': 'INCARCA PDF SCORECARD',
      'scorecard_overview_upload_prompt': 'Incarca PDF-ul Scorecard',
      'scorecard_overview_choose_file': 'Alege fisierul',
      'scorecard_overview_summary_title': 'Rezumat Score Card',
      'scorecard_overview_no_reports_yet':
          'Nu exista rapoarte inca. Incarca primul PDF Scorecard pentru a incepe.',
      'scorecard_overview_chart_title': 'Prezentare Score Card',
      'scorecard_overview_best_drivers': 'Cei mai buni soferi',
      'scorecard_overview_no_reports_available':
          'Nu exista rapoarte disponibile.',
      'scorecard_overview_no_drivers_period':
          'Nu au fost gasiti soferi pentru aceasta perioada.',
      'scorecard_overview_select_station': 'Selecteaza statia',
      'scorecard_overview_all_stations': 'Toate statiile',
      'scorecard_overview_select_period': 'Selecteaza perioada',
      'scorecard_overview_best_drivers_year': 'Cei mai buni soferi ai anului',
      'scorecard_overview_best_drivers_month': 'Cei mai buni soferi ai lunii',
      'scorecard_overview_station': 'Statie',
      'scorecard_overview_station_code': 'Statia {code}',
      'scorecard_overview_upload_success_one':
          '1 scorecard analizat si salvat. Tabloul a fost actualizat.',
      'scorecard_overview_upload_success_many':
          '{count} scorecard-uri analizate si salvate. Tabloul a fost actualizat.',
      'scorecard_overview_upload_parse_failed':
          'Incarcarea/analiza a esuat: {error}',
      'scorecard_overview_no_file_bytes': 'Nu exista date ale fisierului',
      'scorecard_overview_csv_updated':
          'Numele soferilor au fost actualizate in toate rapoartele.',
      'scorecard_overview_csv_failed': 'Importul CSV a esuat: {error}',
      'scorecard_overview_delete_report_q': 'Stergi raportul?',
      'scorecard_overview_delete_report_body':
          'Acest lucru va sterge raportul "{title}" si toate inregistrarile de scor pentru aceasta saptamana.',
      'scorecard_overview_deleted':
          'Raportul si scorurile saptamanii au fost sterse.',
      'scorecard_overview_delete_failed': 'Stergerea a esuat: {error}',
      'scorecard_overview_more': 'Mai mult',
      'scorecard_overview_delete_report_menu': 'Sterge raportul',
      'scorecard_overview_upload_processing':
          'Se incarca si se proceseaza scorecard-urile...',
      'scorecard_overview_row_title': 'Score Card {year} SAPT {week}',
      'scorecard_overview_reliability_score': 'Scor de fiabilitate',
      'scorecard_overview_from_last_week': 'fata de saptamana trecuta',
      'scorecard_overview_from_last_year': 'fata de anul trecut',

      'kpi_score': 'SCOR',
      'kpi_value': 'VALOARE',
      'kpi_pro_tip': 'SFAT',

      'kpi_title_dcr': 'Rata de Succes a Livrării',
      'kpi_title_dnr': 'Condițiile de Succes ale Livrării',
      'kpi_title_lor': 'Pierdut pe Traseu',
      'kpi_title_pod': 'Fotografie la Livrare',
      'kpi_title_cc': 'Contact cu Clientul',
      'kpi_title_ce': 'Escaladare de la Client',
      'kpi_title_cdf': 'Feedback-ul Clientului privind Livrarea',

      'kpi_desc_dcr':
          'Cu cât valoarea este mai mare, cu atât mai bine. Pentru a atinge o rată de succes de 100%, se recomandă efectuarea unei încercări de relivrare* după o livrare eșuată.',
      'kpi_tip_dcr':
          'Exemplu: Dacă într-o zi nu poți livra un colet din orice motiv și încerci din nou livrarea mai târziu în aceeași zi, valoarea DCR va fi mai mare și mai aproape de 100%, chiar dacă și a doua încercare de livrare este nereușită.',

      'kpi_desc_dnr':
          'DSC DPMO (Condițiile de Succes ale Livrării)\n(anterior DNR – Livrare Neprimita)\n\nCu cât valoarea este mai mică, cu atât mai bine.\n\nAcest indicator măsoară cât de corect și trasabil sunt efectuate livrările.\n\nReguli de bază ale livrării:\n- Livrare către persoana corectă sau locația corectă\n- Livrările către clienți, membri ai gospodăriei, vecini sau recepționeri sunt cu risc scăzut atunci când sunt efectuate corect\n- Folosește întotdeauna codul corect de scanare/motiv pentru ca clienții să primească notificări corecte\n\nLivrări în camera poștală / cutia poștală:\n- Respectă fluxul de lucru standard\n- Coletele trebuie să fie complet în interiorul cutiei poștale sau fantei poștale și nu trebuie să iasă în afară\n- Folosește cea mai precisă scanare disponibilă\n\nAdresă corectă & Geofence:\n- Livrare în interiorul a 25 de metri de geofence-ul corect\n- Compară întotdeauna numele și adresa din aplicație cu eticheta coletului și clădirea\n- Dacă geocodul pare incorect, raportează prin SDS\n\nFotografie la livrare (POD):\n- Fă întotdeauna o fotografie clară atunci când ți se solicită\n- Coletul și mediul înconjurător trebuie să fie clar vizibile\n- Deosebit de important pentru livrările nesupravegheate și pentru încrederea clientului\n\nRespectarea preferințelor de livrare:\n- Respectă instrucțiunile clientului din aplicație, dacă sunt sigure\n- Dacă instrucțiunile nu sunt sigure, contactează clientul\n- Folosește doar locațiile sigure aprobate din aplicație\n\nOpriri simultane / de grup:\n- Folosește „Selectează toate” doar atunci când mai multe colete sunt livrate aceleiași persoane sau în același loc (de ex. recepție)\n- Înregistrează corect numele destinatarului și semnătura',

      'kpi_tip_dnr':
          'Notificare importantă:\n\nValorile ridicate repetate la DSC DPMO indică livrări incorecte sau riscante.\n\n- Abaterile frecvente pot fi interpretate de Amazon ca posibil furt\n- Acest lucru poate declanșa un proces de prevenire a pierderilor\n- În cel mai rău caz, poate duce la încetarea colaborării\n\nScanările atente, fotografiile corecte și respectarea tuturor regulilor de livrare te protejează pe tine și echipa ta.',

      'kpi_desc_lor':
          'LoR (Pierdut pe Traseu)\n\nCu cât valoarea este mai mică, cu atât mai bine.\n\nAcest indicator arată dacă toate coletele nelivrate sunt înregistrate corect la finalul rutei.\n\nLa finalul rutei:\n- Verifică în scanner câte colete trebuie returnate\n- Asigură-te că acest număr corespunde exact cu coletele din vehicul',

      'kpi_tip_lor':
          'Notificare importantă:\n\nAceasta este categoria cu cel mai ridicat suspiciune de furt.\n\nNeconcordanțele dintre scanner și inventarul vehiculului pot fi considerate erori grave și pot duce la investigații interne sau la alte consecințe.',

      'kpi_desc_pod':
          'PoD (Fotografie la Livrare)\n\nCu cât valoarea este mai mare, cu atât mai bine.\n\nAceastă coloană arată coletele pentru care a fost făcută o fotografie, dar care au fost marcate ca Nevalide sau Nesigure.\n\nMotive frecvente pentru respingerea POD:\n1. Eticheta coletului cu datele clientului vizibilă (coletul trebuie întors)\n2. Fotografie neclară\n3. Persoană vizibilă în fotografie\n4. Niciun colet vizibil în fotografie\n5. Colet în vehicul\n6. Colet în mână\n7. Colet prea aproape de cameră\n8. Fotografie prea întunecată',

      'kpi_tip_pod':
          'Aceasta ar trebui să fie cea mai simplă categorie\nValoare țintă: 100%\nÎmbunătățește semnificativ scorul general',

      'pod_quality_title': 'Calitate POD',
      'pod_quality_success': 'Succes',
      'pod_quality_rejects': 'Respingeri',
      'pod_quality_opp': 'Oportunități',
      'pod_quality_bypass': 'Ocoliri',
      'pod_quality_blurry': 'Neclar',
      'pod_quality_too_dark': 'Prea întunecat',
      'pod_quality_no_package': 'Fără colet',
      'pod_quality_in_car': 'În mașină',
      'pod_quality_too_close': 'Prea aproape',
      'pod_quality_shell_week_title': 'CALITATE POD - SAPTAMANA',
      'pod_quality_week_label': 'Saptamana {week}',
      'pod_quality_dashboard_title': 'TABLOU CALITATE POD',
      'pod_quality_upload_pdf': 'Incarca PDF',
      'pod_quality_no_reports_uploaded':
          'Nu exista inca rapoarte de calitate POD. Incarca un PDF POD pentru a incepe.',
      'pod_quality_upload_success_one':
          '1 raport de calitate POD a fost analizat si salvat.',
      'pod_quality_upload_success_many':
          '{count} rapoarte de calitate POD au fost analizate si salvate.',
      'pod_quality_upload_parse_failed': 'Incarcarea/analiza a esuat: {error}',
      'pod_quality_rejects_breakdown': 'Detaliere respingeri',
      'pod_quality_no_data_week':
          'Nu exista date POD pentru aceasta saptamana.',
      'pod_quality_drivers': 'Soferi',
      'pod_quality_entries_count': '{count} inregistrari',

      'kpi_desc_cc':
          'CC (Contact cu Clientul)\n\nCu cât valoarea este mai mare, cu atât mai bine.\n\nExtrem de important:\nTrebuie SĂ TRIMIȚI ÎNTOTDEAUNA un mesaj „Nicio locație sigură” sau „Adresa nu a fost găsită” de fiecare dată când nu poți livra un colet deoarece:\n\n- clientul nu este acasă sau\n- adresa nu poate fi găsită',

      'kpi_tip_cc':
          'Există un mesaj standard automat în aplicație pentru fiecare scenariu.',

      'kpi_desc_ce':
          'CE (Escaladare de la Client)\n\nCu cât valoarea este mai mică, cu atât mai bine.\nCea mai proastă categorie dintre toate.\n\nClienții escaladează atunci când instrucțiunile de livrare nu sunt respectate.\n\nȘoferul este întotdeauna responsabil\nContestațiile sunt aproape imposibile fără dovezi foarte puternice\nAre cel mai puternic impact asupra Scorecard-ului tău\n\nCum să eviți CE\n\nEste împotriva regulilor de livrare să lași colete în locații nesigure sau nesupravegheate fără aprobare\n\nDelivery Associates trebuie:\n- Să sune la sonerie / să folosească interfonul sau să bată la ușă\n- Să ofere clientului suficient timp pentru a răspunde\n\nDacă clientul nu poate fi contactat și nu este setată nicio locație sigură:\n- Să sune clientul de două ori\n- Să trimită un mesaj text\n- Să contacteze Driver Support dacă nu este posibil contactul\n\nDacă este necesar:\n- Să scaneze coletul ca „Livrare eșuată – client indisponibil”\n- Să reîncerce livrarea conform regulilor',

      'kpi_tip_ce':
          'Nu lăsa colete în locații nesigure sau neaprobate\nRespectă întotdeauna procesele corecte de expediere și livrare',

      'kpi_desc_cdf':
          'CDF DPMO (Feedback-ul Clientului privind Livrarea)\n\nCu cât valoarea este mai mică, cu atât mai bine.\n\nNivelul 1 (L1)\n- Clientul evaluează livrarea ca „Groaznic” (👍) sau „Nu atât de bine” (👎)\n\nNivelul 2 (L2)\n- Feedback suplimentar despre motivul pentru care experiența a fost bună sau rea',

      'kpi_tip_cdf': 'CDF este calculat exclusiv la nivelul L1',

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

      // =========================
      // ROMANIAN (ro) – FAQ keys
      // =========================

      // FAQs
      'faq_title': 'Întrebări frecvente',
      'faq_search_hint': 'Căutați întrebări',
      'faq_empty': 'Nu au fost găsite Întrebări frecvente care să corespundă.',
      'driver_tasks_error': 'Eroare: {error}',
      'driver_tasks_no_tasks': 'Nu exista inca sarcini atribuite.',
      'driver_tasks_update_status': 'Actualizeaza statusul',
      'driver_tasks_confirm_completed': 'Confirma finalizarea',
      'driver_tasks_set_completed_first':
          'Seteaza mai intai statusul la "Finalizat".',
      'driver_tasks_completion_confirmed': 'Finalizarea a fost confirmata.',
      'driver_tasks_failed_update_status':
          'Actualizarea statusului a esuat: {error}',
      'driver_tasks_failed_confirm_task':
          'Confirmarea sarcinii a esuat: {error}',
      'driver_tasks_status_confirmed_by_you': 'Status confirmat de tine.',
      'driver_tasks_confirm_when_fully_done':
          'Te rugam sa confirmi cand aceasta sarcina este complet finalizata.',
      'driver_tasks_status_pending': 'In asteptare',
      'driver_tasks_status_in_progress': 'In desfasurare',
      'driver_tasks_status_completed': 'Finalizat',
      'faq_green_book_video_title': 'Video tutorial Green Book',
      'faq_green_book_video_subtitle':
          'Urmărește pas cu pas cum se completează Green Book',
      'faq_green_book_video_action': 'Redă video',
      'faq_green_book_video_missing':
          'Linkul video Green Book nu este încă configurat.',
      'faq_green_book_video_open_failed':
          'Linkul video Green Book nu a putut fi deschis.',

      'faq_q1': 'Ce este cel mai important în sarcina ta zilnică?',
      'faq_a1': 'Livrarea coletelor cu calitate și cu un comportament bun.',

      'faq_q2': 'Ce NU ar trebui să faci în cazul unor probleme cu clientul?',
      'faq_a2':
          'NU încerca să gestionezi situația singur și informează în schimb dispecerul de serviciu. Vom încerca să vorbim cu clientul pentru tine și să evităm orice consecințe negative din partea Amazon din cauza reclamațiilor clienților. Suntem aici pentru tine!',

      'faq_q3':
          'Ce se întâmplă dacă situația a escaladat deja și clientul nu este mulțumit de ceea ce s-a întâmplat?',
      'faq_a3':
          'Nu este niciodată prea târziu să corectezi orice greșeli. Sună-ne în continuare și vom încerca să reparăm greșeala cu clientul. Mai bine mai târziu decât niciodată.',

      'faq_q4':
          'Ce este mai important, Cantitatea (viteza de a livra cât mai multe opriri posibil) sau Calitatea?',
      'faq_a4':
          'Calitatea! Întotdeauna calitatea! Urmează instrucțiunile clientului și NU lăsa coletul în locuri nesigure doar pentru că ești în urmă cu opririle.',

      'faq_q5':
          'Ce se întâmplă dacă mă concentrez pe calitate, dar apoi rămân în urmă cu opririle?',
      'faq_a5':
          'Îți vei termina opririle, într-un fel sau altul. Vom încerca să trimitem ajutor, dar numai dacă vedem că este rezonabil.',

      'faq_q6': 'Ce este scorecard-ul și ce este un DNR?',
      'faq_a6': 'Ne bucurăm că ai întrebat.',

      // 7 – Weekly scorecard
      'faq_q7': 'Scorecard săptămânal',
      'faq_a7':
          'Scorecard-ul săptămânal ne oferă o imagine rapidă și clară despre cum se descurcă echipa în ceea ce privește obiectivele noastre cheie. Ne ajută să vedem ce merge bine, unde rămânem în urmă și pe ce trebuie să ne concentrăm pentru săptămâna următoare. Scorurile generale sunt următoarele:\n'
          '• Fantastic Plus: >93% (performanță excepțională)\n'
          '• Fantastic: 85% – 92.9%\n'
          '• Great: 70% – 84.9%\n'
          '• Fair: 50% – 69.9%\n'
          '• Poor: <50%',

      'faq_q7_1': 'Fila DNR\nDelivered Not Received',
      'faq_a7_1':
          'Este atunci când ai livrat un colet și ai apăsat butonul „Swipe to finish”, confirmând că ai livrat coletul, dar clientul nu a primit coletul din mai multe motive: furtul coletului, cutia fiind goală de conținut și, de asemenea, livrarea greșită la o adresă greșită.\n'
          'În fiecare marți vei primi poze cu fiecare DNR pe care l-ai avut în timpul săptămânii.',

      'faq_q7_1_1':
          'Cum ar trebui să evit acest lucru și cât de important este pentru scorecard-ul săptămânal?',
      'faq_a7_1_1':
          'Este foarte important și, pentru a evita acest lucru, pur și simplu ar trebui să informezi clientul din timp că vei ajunge în curând la casa/afacerea lui și să suni DOAR la soneria pe care este trecut numele lui.',

      'faq_q7_1_2': 'Cum evit pierderile de colete?',
      'faq_a7_1_2':
          'Încearcă întotdeauna să predai coletele direct clientului și, dacă acest lucru nu este posibil, trimite un mesaj informându-l unde a fost lăsat coletul, de exemplu, în garaj, sub scări, în șopron, în spatele vazei cu flori etc..\n'
          'Dacă nu consideri că este sigur să lași coletul nesupravegheat, te rugăm, cel mai bine este întotdeauna să iei coletul și să încerci din nou mai târziu. Acest lucru este FOARTE important.',

      'faq_q7_1_3': 'Cum știu ce loc este sigur sau nu?',
      'faq_a7_1_3':
          'Instinct și bun simț. Dacă o clădire are 20 - 30 de etaje și îl lași lângă cutiile poștale, șansele să fie furat sunt din ce în ce mai mari comparativ cu o casă privată.\n'
          'De asemenea, pentru a te ajuta la livrările zilnice și pentru a evita să primești un DNR, în fiecare dimineață vom posta o poză cu adrese care au o probabilitate mare ca pachetele să fie furate și clienții să se plângă, pe baza rezultatelor și statisticilor livrărilor anterioare.',

      'faq_q7_1_4':
          'Ce se întâmplă dacă un colet este pierdut sau furat, cum îmi va afecta scorul?',
      'faq_a7_1_4':
          'Rău. Acest lucru te va afecta cu cel puțin 30% și asta doar cu un singur colet, care îți scade cel puțin 600 de puncte. Cu cât vezi mai multe puncte în scorecard sub numele tău, cu atât este mai rău. Cu cât livrezi mai multe colete pe săptămâna de lucru, cu atât pierzi mai puține puncte. Punctele pe care le pierzi variază și în funcție de prețul articolului pierdut: cu cât este mai scump, cu atât se pierd mai multe puncte. Ar trebui să păstrăm această secțiune de scor cât mai mică posibil.\n'
          'De asemenea, nu trebuie ignorat faptul că, dacă în mod regulat ai un număr mare de colete pierdute, va trebui să te eliberăm din funcție, deoarece mai devreme sau mai târziu Amazon poate suspecta furt de colete și, prin urmare, acest lucru este foarte periculos.',

      'faq_q7_2':
          'Fila CC\n'
          'Contact Compliance',
      'faq_a7_2':
          'Înseamnă de câte ori ai contactat clientul în legătură cu livrarea lui, fie prin mesaj, fie printr-un apel telefonic. Cu cât interacționezi mai puțin cu clientul, cu atât vei obține scoruri mai mici în scorecard și ar trebui să păstrăm această secțiune cât mai sus posibil, deoarece este de fapt una dintre cele mai ușoare categorii și ajută mult la scorul tău general.',

      'faq_q7_2_1': 'De ce ar trebui să fac asta?',
      'faq_a7_2_1':
          'Livrarea coletelor nu înseamnă doar Drop&Go, ar trebui să informezi clientul în prealabil și să îl întrebi unde ar dori să fie livrat coletul.',

      'faq_q7_2_2': 'Cum îmi îmbunătățesc scorurile CC?',
      'faq_a7_2_2':
          'Îți mulțumim că ai întrebat. Simplu, sunând și mai ales trimițând mesaje clienților la fiecare oprire.',

      'faq_q7_3': 'Fila CE\nCostumer Escalation',
      'faq_a7_3':
          'Îți amintești cât de rău ți-a afectat DNR scorurile? Ei bine, asta este cel puțin de 2 ori mai rău și riști, de asemenea, să îți pierzi locul de muncă, deoarece depinde de cât de gravă a fost situația.',

      'faq_q7_3_1': 'Cum evit acest lucru?',
      'faq_a7_3_1':
          'Urmând întotdeauna instrucțiunile de livrare ale clientului și, în cazul unei greșeli, mai întâi te rugăm să îți ceri scuze, iar dacă clientul este supărat, te rugăm să îi ceri un minut din timpul lui pentru a vorbi cu noi, deoarece deja ne suni. Citind Secțiunea 2, ar trebui să știi până acum că este cel mai bine să ne lași pe noi să gestionăm astfel de situații.',

      'faq_q7_4': 'Fila POD\nPicture on Delivery',
      'faq_a7_4':
          'Această coloană arată lista coletelor eligibile pentru POD-uri, pentru care au fost făcute fotografii, dar care au fost fie Invalid, fie Not Sure. Motivele pentru respingerea unui POD pot include:\n'
          '1- Eticheta coletului este în poză cu detaliile clientului. Coletul trebuie întors invers înainte de a face poza.\n'
          '2- Poză neclară\n'
          '3- Persoană vizibilă în poză\n'
          '4- Niciun colet detectat în poză\n'
          '5- Colet în mașină\n'
          '6- Colet în mână\n'
          '7- Colet în cutia poștală\n'
          '8- Colet prea aproape\n'
          '9- Poză prea întunecată.\n'
          'Aceasta ar trebui să fie întotdeauna cea mai ușoară, unde ar trebui să ai un scor de 100% și îți îmbunătățește scorul general',

      'faq_q7_5': 'Fila LoR\nLost on Road',
      'faq_a7_5':
          'Te penalizează atunci când ai scanat un colet la încărcare și nu l-ai returnat la sfârșitul turei în cazul unei livrări nereușite. Astfel coletul s-a pierdut și vei pierde la fel de multe puncte ca la un DNR, așa că te rugăm să numeri bine coletele pe care le aduci înapoi și să te asiguri că se potrivesc cu coletele afișate în scanner. Le poți găsi la: Todays Itinerary - Summary - Problems. Dacă nu se potrivesc, te rugăm să informezi dispecerul de serviciu înainte de a încheia munca în aplicația Amazon.',

      'faq_q7_6': 'Fila DCR\nDelivery Completion Rate',
      'faq_a7_6':
          'Îți arată capacitățile de a livra colete. Urmărește procentul livrărilor finalizate conform planului, ajutându-ne să măsurăm eficiența și fiabilitatea livrărilor noastre. Evidențiază probleme precum întârzieri, încercări eșuate sau probleme de rutare. Acesta ar trebui să fie întotdeauna cât mai mare posibil. Pentru a face acest lucru posibil ar trebui în fiecare zi să faci reattempts și să eviți cât de mult poți returnarea coletelor.',

      'faq_q7_7': 'Fila CDF (Anterior, DEX)\nCostumer Delivery Feedback',
      'faq_a7_7':
          'Captează experiența destinatarului cu procesul de livrare, inclusiv punctualitatea, starea bunurilor și profesionalismul șoferului. Ne ajută să identificăm punctele forte ale serviciului și zonele de îmbunătățire. La finalul livrării, clientul primește un e-mail de la Amazon despre experiența livrării, cu întrebări precum:\n'
          '1) A fost coletul livrat la timp?\n'
          'Da / Nu\n'
          '2) A fost coletul lăsat într-un loc sigur?\n'
          'Da / Nu\n'
          '3) A fost coletul în stare bună când a ajuns?\n'
          'Da / Nu\n'
          '4) Cât de mulțumit ești de livrare în general?\n'
          'Foarte mulțumit / Mulțumit / Neutru / Nemulțumit / Foarte nemulțumit\n'
          '5) Cum ai evalua comunicarea și actualizările de urmărire pentru această livrare?\n'
          'Excelent / Bun / Acceptabil / Slab\n'
          '6) A fost persoana de livrare amabilă și profesionistă?\n'
          'Da / Nu / Nu se aplică (Livrare fără contact)\n'
          '7) Ai comentarii despre experiența ta de livrare?\n'
          '(Comentarii suplimentare ale clientului)',

      'faq_q7_8': 'Ce ar trebui să am în vedere despre scorecard?',
      'faq_a7_8':
          'Calitatea și eficiența contează mult. Scorurile bune sunt bune pentru tine, pentru companie și bune pentru întreaga echipă. Satisfacția clientului este foarte importantă și scorurile bune sunt însoțite de un bonus din partea companiei.\n'
          'Dă tot ce poți, primește ce e mai bun.',

      'faq_q8': 'La ce alte domenii ar trebui să fiu atent?',
      'faq_a8':
          'Ai grijă de tine conducând în siguranță, evitând accidentările și evitând câinii și mușcăturile de câine. Ai grijă de echipamentele de lucru, cum ar fi vehiculul zilnic, scannerul/telefonul de lucru și vino la muncă purtând pantofii de siguranță și vesta de siguranță, jachetă sau tricou marca Amazon (în funcție de vreme).',

      'faq_q9':
          'Ce se întâmplă dacă fac un accident de mașină sau deteriorez vehiculul de lucru?',
      'faq_a9':
          'Mai întâi, asigură-te că ești bine și că nu ești rănit grav. În ceea ce privește daunele la mașină, dacă stabilim că accidentele apar din neglijență – de exemplu, distrageri precum utilizarea telefonului mobil în timpul conducerii – vei fi personal răspunzător pentru întreaga daună. În plus, vei primi un raport de la poliție, care ar putea duce chiar la suspendarea permisului. Desigur, acesta este și un motiv pentru concediere imediată. În caz contrar, ești doar exclus de la bonusurile Weekly Scorecard pentru 2 luni. În cazul unui incident, ești OBLIGAT să ne informezi imediat și să ne furnizezi ora incidentului, locația, dacă există daune la proprietăți private sau publice (cum ar fi pereți, garduri, stâlpi de iluminat, persoane și/sau animale de companie), locația și poze cu daunele mașinii.',

      'faq_q10': 'Ce fac când am colete deteriorate și/sau lipsă.',
      'faq_a10':
          'Când un colet este deteriorat, te rugăm să îl înregistrezi ca deteriorat și să îl returnezi la stație. Dacă acel colet deteriorat a fost un colet cu lichide și a deteriorat și alte colete, te rugăm să faci o poză cu toate coletele deteriorate și să o trimiți dispecerului de serviciu și vom raporta noi către Amazon.\n'
          'Când un colet lipsește, te rugăm să îl marchezi/înregistrezi ca lipsă, cu excepția cazului în care are un OTP, pentru care TREBUIE să ne raportezi mai întâi înainte de a-l marca drept lipsă. Acest lucru este FOARTE important.',

      'faq_q11': 'Ce este un colet OTP (One-Time Password)?',
      'faq_a11':
          'Este un articol scump pentru care Amazon cere clientului să îi ofere șoferului o parolă unică (One Time Password) înainte de a livra coletul, pentru a se asigura că coletul este livrat persoanei/clientului potrivit. Trebuie să ai grijă deosebită de astfel de colete, să nu le lași nesupravegheate și să înmânezi coletele doar clientului care ți-a furnizat parola.',

      'faq_q12':
          'De ce te tot deranjăm să încetinești și să nu mergi mai repede?',
      'faq_a12':
          'Nici nouă nu ne place, dar așa este sistemul. Trebuie să urmăm algoritmul sistemului și să facem cât mai multe opriri pe oră, așa cum este stabilit, ca să putem obține mai multe rute în viitor și tu să ajungi să lucrezi mai mult și să nu fii liber.\n'
          'De asemenea, mergând mai repede, riști să primești un DNR și riști să pierzi puncte pentru ambele, pentru tine și pentru companie, în scorecard-ul săptămânal.',

      'faq_q13':
          'Atunci de ce dispecerii uneori mă întreabă de ce sunt în urmă și dacă este ceva în neregulă?',
      'faq_a13':
          'Știm că acest lucru nu este plăcut, dar avem nevoie de un feedback despre ce s-ar fi putut întâmpla pe drum care te-a făcut să rămâi în urmă cu opririle. Amazon ne cere acest feedback deoarece există și un termen-limită până la care ar fi trebuit să livrezi X opriri, prin urmare Amazon trebuie să știe de ce opririle rămase sunt în urmă față de programul de livrare și, cu aceste informații, să îmbunătățească eficiența livrărilor viitoare.',

      'faq_q14': 'De ce uneori îți cerem să mergi să ajuți un coleg?',
      'faq_a14':
          'Pentru că mulți factori joacă un rol în întârzierea colegului, cum ar fi conexiunea slabă la internet în zonă, traficul, străzi blocate din cauza lucrărilor în zonă, ceea ce a făcut dificil pentru celălalt șofer să livreze la timp, prin urmare ajutorul tău este necesar.',

      'faq_q15':
          'În prima mea zi, încep imediat să livrez colete pe rute standard ca alți șoferi de livrare mai experimentați?',
      'faq_a15':
          'Nu, evident că nu este cazul pentru tine. La început vei avea o perioadă de 14 zile de lucru pentru a pune în practică ceea ce ai învățat în zilele de ride-along cu trainerul tău și pentru a te adapta la zonă, la mașină, la scanner și pentru a învăța procesul de lucru.\n'
          'Cu asta spus, pentru acea perioadă de 14 zile, Amazon îți va da cu până la 50% mai puține colete și opriri decât în mod normal în programul tău.',

      'faq_q16':
          'Ce să faci când o adresă este greșită și/sau pinul locației nu este corect pe hartă?',
      'faq_a16':
          'Mai întâi confirmă că pinul nu este corect căutând adresa în Google Maps (este mai precis și este deja instalat pe scannerul tău) și, dacă nu se potrivește, informează un dispecer de serviciu cu erorile.',

      'faq_q17':
          'Care sunt sarcinile mele zilnice înainte de a începe și după ce termin munca?',
      'faq_a17':
          '1- Când ajungi în parcare, mai întâi te asiguri că porți pantofii de siguranță și vesta de siguranță și uniforma Amazon.\n'
          '2- Verifică dacă scannerul tău este complet încărcat și informează un dispecer prezent în acel moment dacă nu este încărcat.\n'
          '3- Verifică dacă este ceva în neregulă cu mașina.\n'
          '4- Începe trip-ul în aplicația Mentor pe scannerul tău.\n'
          '5- Postează poza tabloului de bord al mașinii care arată kilometrajul curent al mașinii și trip-ul zilnic (în mașină) resetat la 0.\n'
          '6- Pregătește-te să cobori în Waiting Area doar cu 10 minute înainte de ora planificată de încărcare, nu mai devreme.\n'
          '7- Când ești în Waiting area, oprește mașina, pornește Flex App și Timesheet. Te rog, nici măcar un minut mai devreme, mai ales flex app-ul. Nu uita timestamp-ul de 10 minute.\n'
          '8- Apoi mergi la Loading Area conform instrucțiunilor Yard Marshall. Când ești în Loading area, oprește mașina și părăsește mașina DOAR DUPĂ ce ai auzit fluierul Yard Marshall.\n'
          '9- După ce ai terminat încărcarea mașinii, pornește mașina și începe să conduci, dar numai când Yard Marshall îți spune.\n'
          '10- După ce ai terminat toate opririle, verifică rezervorul și, dacă este sub jumătate, te rog să alimentezi.\n'
          '11- Când ești la stație, te rog să lași toate coletele rămase în zonele desemnate de Amazon, lasă sacii la timp\n'
          '12- Când ești în parcare, oprește mașina și completează Green Book (Tageskontrollblat), postează poza cu kilometrajul zilnic pe care l-ai făcut în timpul zilei livrând, împreună cu o poză cu Green Book.\n'
          '13- Oprește mașina și te rog să returnezi geanta de lucru în zona desemnată/van',

      'faq_q18':
          'Trebuie să fac ceva când schimb van-ul și iau un alt van decât cel pe care îl iau de obicei?',
      'faq_a18':
          'Ar trebui să faci un video cu el, surprinzând în detaliu fiecare mică daună pe care șoferul(șoferii) anterior(i) ar fi putut să o facă, astfel încât să nu fie vina ta la următoarea inspecție a mașinii.',

      'faq_q19':
          'Ce ar trebui să fac dacă aplicația Flex se încarcă constant și îmi încetinește fluxul de lucru?',
      'faq_a19':
          'Mai întâi verifică dacă ai o conexiune activă la internet. Pentru a face asta poți încerca să trimiți un mesaj clientului de la oprirea curentă și, dacă se trimite, atunci înseamnă că internetul este activ. Poți verifica și deschizând o altă aplicație pe scanner, cum ar fi browserul, și căutând ceva pe el.\n'
          'Pașii pe care ar trebui să îi urmezi dacă nu există o conexiune activă la internet:\n'
          '1- Repornește scannerul. Acesta ar trebui să fie întotdeauna primul lucru pe care îl încerci.\n'
          '2- Pornește/oprește modul avion. Acesta funcționează de cele mai multe ori fără să aștepți repornirea scannerului.\n'
          '3- Ca ultimă soluție, te rog să încerci să partajezi un hotspot de pe telefonul tău personal pentru doar 10 minute max, doar pentru ca sistemul să se reîmprospăteze.\n'
          'Poți lucra și offline, dar la un moment dat trebuie să te conectezi la internet și să fii activ. Pentru a lucra offline trebuie mai întâi să descarci hărțile offline în aplicația Flex. Pentru a face asta, mergi la Settings - Offline Maps (ultima opțiune) - Download DBY5 - Allow downloads with mobile connection.\n',

      'faq_q20':
          'Ce se întâmplă dacă conexiunea la internet este activă și aplicația Flex încă nu funcționează așa cum ar trebui?',
      'faq_a20':
          '1- Repornește scannerul.\n'
          '2- Pornește/oprește modul avion\n'
          '3- Ieși din aplicație\n'
          '4- Oprește/pornește Location Services (GPS)\n'
          '5- Deloghează-te din aplicația Flex și loghează-te din nou cu credențialele pe care le folosești pentru aplicația Mentor.\n'
          '6- Verifică dacă aplicația trebuie actualizată.\n'
          'Ar trebui să încerci acești pași unul câte unul. Dacă unul nu funcționează, te rog încearcă următorul de mai jos.',
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
      'header_good_afternoon': 'DOBAR DAN',
      'header_good_evening': 'DOBRA VEČER',
      'select_language': 'Odaberi jezik',
      'notifications': 'Obavijesti',
      'no_notifications': 'Nema obavijesti',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Pomoć',
      'nav_rules': 'Pravila',
      'nav_profile': 'Profil',
      'nav_tasks': 'Zadaci',
      'driver_home_dispatcher': 'Dispecer',
      'driver_home_shift_plan_title': 'Plan smjene',
      'driver_home_shift_plan_subtitle': 'Tvoje smjene',
      'driver_home_scorecard_subtitle': 'Pregled tvoje izvedbe',
      'driver_home_tasks_title': 'Zadaci',
      'driver_home_tasks_subtitle': 'Upravljaj otvorenim zadacima',
      'driver_home_academy_subtitle': 'Obuka i znanje',
      'driver_home_rules_title': 'Pravila kompanije',
      'driver_home_rules_subtitle': 'Smjernice i politike',
      'driver_notification_published_on': 'Objavljeno {date}',
      'driver_home_vehicles_title': 'Vozila',
      'driver_home_vehicles_subtitle': 'Pregled vozila',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'Tvoj AI asistent',
      'driver_home_absence_title': 'Odsustvo',
      'driver_home_absence_subtitle': 'Godisnji i bolovanje',
      'driver_home_incident_title': 'Prijava incidenta',
      'driver_home_incident_subtitle': 'Prijavi nesrecu',
      'driver_home_new_badge': 'NOVO',
      'driver_academy_title': 'DA Academy',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle':
          'Smjernice za dnevni kontrolni list',
      'driver_academy_safety_title': 'Sigurnosna obuka',
      'driver_academy_safety_subtitle': 'Treninzi sigurnosti',
      'driver_academy_delivery_title': 'Amazon dostava',
      'driver_academy_delivery_subtitle': 'Procesi i tokovi dostave',
      'driver_academy_app_title': 'CoDriver aplikacija',
      'driver_academy_app_subtitle': 'Funkcije i vodici aplikacije',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - Video obuka',
      'driver_green_book_video_subtitle': 'Dodirni za reprodukciju',
      'driver_green_book_start_test': 'Pokreni Green Book test',
      'driver_green_book_test_required': 'Test je obavezan',
      'driver_green_book_section1_title': 'Green Book dnevni kontrolni list',
      'driver_green_book_section1_text':
          'Dnevni kontrolni list (Green Book) je obavezan dokument koji se mora ispuniti prije svake smjene. Pomaze provjeri stanja vozila i biljezi sigurnosno vazne stavke.',
      'driver_green_book_section1_b1':
          'Popuni ga u potpunosti prije svake smjene.',
      'driver_green_book_section1_b2': 'Odmah prijavi nedostatke na vozilu.',
      'driver_green_book_section1_b3': 'Ne zaboravi potpis.',
      'driver_green_book_section2_title': 'Posljedice nepostivanja',
      'driver_green_book_section2_text':
          'Krsenja se tretiraju kroz postupne korake:',
      'driver_green_book_section2_b1':
          'Prvo upozorenje: usmeno upozorenje dispecera.',
      'driver_green_book_section2_b2': 'Drugo upozorenje: pismeno upozorenje.',
      'driver_green_book_section2_b3':
          'Ponovljena krsenja: disciplinske mjere.',
      'driver_green_book_section3_title': 'Zakonske kazne',
      'driver_green_book_section3_text':
          'Ako Green Book nedostaje ili je nepotpuno popunjen tokom kontrole:',
      'driver_green_book_section3_b1': 'Kazna do 5000 EUR za vozaca.',
      'driver_green_book_section3_b2': 'Kazna do 30000 EUR za kompaniju.',
      'driver_green_book_section3_b3':
          'Moguce evidentiranje bodova u Flensburgu.',
      'driver_green_book_section3_b4': 'Moguci negativan uticaj na osiguranje.',
      'driver_green_book_test_title': 'Green Book test',
      'driver_green_book_test_progress': 'Pitanje {current} od {total}',
      'driver_green_book_test_next': 'Dalje',
      'driver_green_book_test_submit': 'Posalji test',
      'driver_green_book_test_result_pass_title': 'Test je polozen',
      'driver_green_book_test_result_fail_title': 'Test nije polozen',
      'driver_green_book_test_result_pass_body':
          'Cestitamo! Test je polozen sa {score}/{total}.',
      'driver_green_book_test_result_fail_body':
          'Rezultat je {score}/{total}. Pokusaj ponovo.',
      'driver_green_book_test_retry': 'Pokusaj ponovo',
      'driver_green_book_test_close': 'Zatvori',
      'driver_green_book_test_back_to_green_book': 'Nazad na Green Book',
      'driver_green_book_test_no_questions':
          'Nema konfigurisanih test pitanja. Kontaktiraj dispecera.',
      'driver_green_book_test_offline_fallback':
          'Neuspjela live sinhronizacija testa. Mozes nastaviti s fallback pitanjima i pokusati ponovo.',
      'admin_home_notification': 'Obavijest',
      'admin_home_driver_fallback': 'Vozac',
      'admin_home_not_confirmed_by': 'NIJE POTVRDIO:',
      'admin_home_missing_loading': 'nedostaje: ...',
      'admin_home_missing_unknown': 'nedostaje: --',
      'admin_home_missing_count': 'nedostaje: {count}',
      'admin_home_error_generic': 'Greska: {error}',
      'admin_home_all_drivers_confirmed': 'Svi vozaci su potvrdili.',
      'admin_home_close': 'Zatvori',
      'admin_home_last_week': 'Prosli tjedan',
      'admin_home_not_logged_in': 'Niste prijavljeni.',
      'admin_home_loading_reports': 'Ucitavanje izvjestaja...',
      'admin_home_no_reports_uploaded': 'Jos nema ucitanih izvjestaja.',
      'admin_home_week_short': 'TJ',
      'admin_home_month_prefix': 'MJESEC',
      'admin_home_year_prefix': 'GODINA',
      'admin_home_loading_scores': 'Ucitavanje rezultata...',
      'admin_home_name_fallback': 'Ime Prezime',
      'admin_home_scorecard': 'Scorecard',
      'admin_home_company_score': 'REZULTAT TVRTKE',
      'admin_home_of': 'od',
      'admin_home_best_driver': 'Najbolji vozac',
      'admin_home_worst_defender': 'Najslabiji defender',
      'admin_home_notification_history': 'Povijest obavijesti',
      'admin_home_no_notifications_yet': 'Jos nema obavijesti.',
      'admin_home_notification_type_message': 'NOVA PORUKA',
      'admin_home_notification_type_academy': 'DA ACADEMY',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'NOVO PRAVILO',
      'admin_home_edit_rule': 'Uredi pravilo',
      'admin_home_title': 'Naslov',
      'admin_home_body': 'Sadrzaj',
      'admin_home_cancel': 'Odustani',
      'admin_home_save': 'Spremi',
      'admin_home_title_or_body_required': 'Naslov ili sadrzaj je obavezan.',
      'admin_home_notification_not_found': 'Obavijest nije pronadena.',
      'admin_home_rule_updated_for_drivers':
          'Pravilo azurirano za {count} vozaca.',
      'admin_home_edit_failed': 'Uredivanje nije uspjelo: {error}',
      'admin_home_delete_notification_question': 'Obrisati obavijest?',
      'admin_home_delete_notification_body':
          'Ova obavijest ce biti obrisana za vas i za sve vozace.',
      'admin_home_delete': 'Obrisi',
      'admin_home_notification_deleted': 'Obavijest je obrisana.',
      'admin_home_delete_failed': 'Brisanje nije uspjelo: {error}',
      'admin_home_options': 'Opcije',
      'admin_home_title_upper': 'NASLOV',
      'admin_home_confirmed_by': 'potvrdio',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Servis',
      'admin_home_accidents': 'Nesrece',
      'admin_home_total': 'ukupno',
      'admin_home_active': 'aktivni',
      'admin_home_inactive': 'neaktivni',
      'admin_home_doc_id_card': 'Osobna iskaznica',
      'admin_home_doc_driving_license': 'Vozacka dozvola',
      'admin_home_doc_residence_permit': 'Dozvola boravka',
      'admin_home_loading_drivers': 'Ucitavanje vozaca...',
      'admin_home_no_drivers_yet': 'Jos nema vozaca.',
      'admin_home_contract': 'Ugovor',
      'admin_home_last_day': 'zadnji dan',
      'admin_home_probation': 'Probni rok',
      'admin_home_ended': 'zavrseno',
      'admin_home_ends': 'zavrsava',
      'admin_home_expired_by': 'isteklo',
      'admin_home_loading_documents': 'Ucitavanje dokumenata...',
      'admin_home_driver_documents': 'Dokumenti vozaca',
      'admin_home_expired_documents': 'Istekli dokumenti',
      'admin_home_expired_soon': 'uskoro istice',
      'admin_home_missing_documents_data': 'Nedostajuci dokumenti / podaci',
      'admin_home_total_missing': 'ukupno nedostaje',
      'admin_home_driver_contracts': 'Ugovori vozaca',
      'admin_home_last_day_soon': 'zadnji dan uskoro',
      'admin_home_no_items': 'Nema stavki',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'Promijeni profilnu sliku',
      'profile_change_photo': 'Promijeni profilnu sliku',
      'logout': 'Odjava',
      'profile_logout': 'Odjava',
      'pin_change_with_old':
          'PIN možeš promijeniti nakon provjere starog PIN-a.',
      'pin_forgot_contact_admin':
          'Zaboravili ste PIN? Kontaktirajte administratora.',
      'profile_photo_updated': 'Profilna slika je ažurirana.',
      'failed_upload_profile_photo':
          'Neuspješno učitavanje profilne slike: {error}',
      'could_not_read_image_bytes':
          'Nije moguće pročitati podatke slike iz birača datoteka.',

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
      'dash_no_reports_uploaded':
          'Tvoj DSP još nije učitao scorecard izvještaje.',
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
      'dash_company_data_section': 'Podaci kao tvrtka',
      'dash_company_data_show': 'Prikaži rezultate kao tvrtka',
      'dash_company_data_hide': 'Sakrij kategorije tvrtke',

      'dash_rank': 'Rang',
      'dash_score': 'Rezultat',
      'dash_name': 'Ime',

      'dash_delivered': 'Dostavljeno',
      'dash_rank_in_aion': 'Rang u AION-u',
      'dash_rank_of_total': '{rank} od {total}',

      'dash_no_my_score_week':
          'Nije pronađen rezultat za tvoj ID vozača u ovom tjednu.',
      'dash_all_status': 'Svi statusi',
      'dash_search_name_or_id': 'Pretrazi ime ili ID transportera...',
      'dash_upload_driver_csv': 'Ucitaj CSV vozaca',

      'scorecard_overview_title': 'SCORE CARD NADZORNA PLOCA',
      'scorecard_overview_overview_suffix': '— Pregled',
      'scorecard_overview_upload_pdf': 'UCITAJ SCORECARD PDF',
      'scorecard_overview_upload_prompt': 'Ucitaj svoj Scorecard PDF',
      'scorecard_overview_choose_file': 'Odaberi datoteku',
      'scorecard_overview_summary_title': 'Sazetak Score Carda',
      'scorecard_overview_no_reports_yet':
          'Jos nema izvjestaja. Ucitaj svoj prvi Scorecard PDF za pocetak.',
      'scorecard_overview_chart_title': 'Pregled Score Carda',
      'scorecard_overview_best_drivers': 'Najbolji vozaci',
      'scorecard_overview_no_reports_available': 'Nema dostupnih izvjestaja.',
      'scorecard_overview_no_drivers_period':
          'Nema pronadenih vozaca za ovo razdoblje.',
      'scorecard_overview_select_station': 'Odaberi stanicu',
      'scorecard_overview_all_stations': 'Sve stanice',
      'scorecard_overview_select_period': 'Odaberi razdoblje',
      'scorecard_overview_best_drivers_year': 'Najbolji vozaci godine',
      'scorecard_overview_best_drivers_month': 'Najbolji vozaci mjeseca',
      'scorecard_overview_station': 'Stanica',
      'scorecard_overview_station_code': 'Stanica {code}',
      'scorecard_overview_upload_success_one':
          '1 scorecard je obraden i spremljen. Nadzorna ploca je azurirana.',
      'scorecard_overview_upload_success_many':
          '{count} scorecarda su obradena i spremljena. Nadzorna ploca je azurirana.',
      'scorecard_overview_upload_parse_failed':
          'Ucitavanje/obrada nije uspjela: {error}',
      'scorecard_overview_no_file_bytes': 'Nema podataka datoteke',
      'scorecard_overview_csv_updated':
          'Imena vozaca su azurirana u svim izvjestajima.',
      'scorecard_overview_csv_failed': 'CSV uvoz nije uspio: {error}',
      'scorecard_overview_delete_report_q': 'Obrisati izvjestaj?',
      'scorecard_overview_delete_report_body':
          'Ovo ce obrisati izvjestaj "{title}" i sve unose rezultata za ovaj tjedan.',
      'scorecard_overview_deleted': 'Izvjestaj i tjedni rezultati su obrisani.',
      'scorecard_overview_delete_failed': 'Brisanje nije uspjelo: {error}',
      'scorecard_overview_more': 'Vise',
      'scorecard_overview_delete_report_menu': 'Obrisi izvjestaj',
      'scorecard_overview_upload_processing':
          'Ucitavanje i obrada scorecarda...',
      'scorecard_overview_row_title': 'Score Card {year} TJ {week}',
      'scorecard_overview_reliability_score': 'Skor pouzdanosti',
      'scorecard_overview_from_last_week': 'u odnosu na prosli tjedan',
      'scorecard_overview_from_last_year': 'u odnosu na proslu godinu',

      'kpi_score': 'REZULTAT',
      'kpi_value': 'VRIJEDNOST',
      'kpi_pro_tip': 'SAVJET',

      'kpi_title_dcr': 'Stopa Uspješnosti Dostave',
      'kpi_title_dnr': 'Uvjeti Uspješne Dostave',
      'kpi_title_lor': 'Izgubljeno na Ruti',
      'kpi_title_pod': 'Fotografija pri Dostavi',
      'kpi_title_cc': 'Kontakt s Kupcem',
      'kpi_title_ce': 'Eskalacija Kupca',
      'kpi_title_cdf': 'Povratne Informacije Kupca o Dostavi',

      'kpi_desc_dcr':
          'Što je vrijednost viša, to je bolje. Kako bi se postigla stopa uspješnosti od 100 %, preporučuje se ponovni pokušaj dostave* nakon neuspjele dostave.',
      'kpi_tip_dcr':
          'Primjer: Ako tijekom dana iz bilo kojeg razloga ne možeš dostaviti paket i pokušaš dostavu ponovno kasnije istog dana, tvoja DCR vrijednost bit će viša i bliža 100 %, čak i ako drugi pokušaj dostave također ne uspije.',

      'kpi_desc_dnr':
          'DSC DPMO (Uvjeti Uspješne Dostave)\n(ranije DNR – Dostava Nije Zaprimljena)\n\nŠto je vrijednost niža, to je bolje.\n\nOva metrika mjeri koliko se ispravno i sljedivo provode dostave.\n\nOsnovna pravila dostave:\n- Dostava ispravnoj osobi ili na ispravnu lokaciju\n- Dostave kupcima, članovima kućanstva, susjedima ili recepcionarima su niskog rizika ako se pravilno provedu\n- Uvijek koristiti ispravan kod skeniranja/razloga kako bi kupci primili točne obavijesti\n\nDostave u poštansku sobu / poštanski sandučić:\n- Slijediti standardni tijek rada\n- Paketi moraju biti u potpunosti unutar poštanskog sandučića ili utora i ne smiju viriti\n- Koristiti najpreciznije dostupno skeniranje\n\nIspravna adresa i geofence:\n- Dostava unutar 25 metara ispravnog geofencea\n- Uvijek usporediti ime i adresu u aplikaciji s oznakom paketa i zgradom\n- Ako se geokod čini netočnim, prijaviti putem SDS-a\n\nFotografija pri dostavi (POD):\n- Uvijek napraviti jasnu fotografiju kada se to zatraži\n- Paket i okolina moraju biti jasno vidljivi\n- Posebno važno za nenadzirane dostave i povjerenje kupaca\n\nPoštivanje preferencija dostave:\n- Slijediti upute kupca u aplikaciji ako su sigurne\n- Ako upute nisu sigurne, kontaktirati kupca\n- Koristiti samo odobrene sigurne lokacije iz aplikacije\n\nIstovremene / grupne stanice:\n- Koristiti „Odaberi sve“ samo kada se više paketa dostavlja istoj osobi ili na isto mjesto (npr. recepcija)\n- Ispravno zabilježiti ime primatelja i potpis',

      'kpi_tip_dnr':
          'Važna napomena:\n\nPonavljano visoke vrijednosti DSC DPMO-a ukazuju na netočne ili rizične dostave.\n\n- Česta odstupanja Amazon može protumačiti kao moguću krađu\n- To može pokrenuti postupak sprječavanja gubitaka\n- U najgorem slučaju, to može dovesti do prekida suradnje\n\nPažljivo skeniranje, ispravne fotografije i poštivanje svih pravila dostave štite tebe i tvoj tim.',

      'kpi_desc_lor':
          'LoR (Izgubljeno na Ruti)\n\nŠto je vrijednost niža, to je bolje.\n\nOva metrika pokazuje jesu li svi nedostavljeni paketi ispravno evidentirani na kraju rute.\n\nNa kraju rute:\n- Provjeriti u skeneru koliko paketa treba vratiti\n- Osigurati da se taj broj točno podudara s paketima u vozilu',

      'kpi_tip_lor':
          'Važna napomena:\n\nOvo je kategorija s najvećom sumnjom na krađu.\n\nNeusklađenosti između skenera i inventara vozila mogu se smatrati ozbiljnim pogreškama i mogu dovesti do unutarnjih istraga ili drugih posljedica.',

      'kpi_desc_pod':
          'PoD (Fotografija pri Dostavi)\n\nŠto je vrijednost viša, to je bolje.\n\nOvaj stupac prikazuje pakete za koje je snimljena fotografija, ali su označeni kao Nevažeći ili Nesigurni.\n\nČesti razlozi za odbijanje POD-a:\n1. Oznaka paketa s podacima o kupcu vidljiva (paket se mora okrenuti)\n2. Mutna fotografija\n3. Osoba vidljiva na fotografiji\n4. Paket nije vidljiv na fotografiji\n5. Paket u vozilu\n6. Paket u ruci\n7. Paket preblizu kameri\n8. Fotografija je previše tamna',

      'kpi_tip_pod':
          'Ovo bi trebala biti najjednostavnija kategorija\nCiljana vrijednost: 100 %\nZnačajno poboljšava ukupni rezultat',

      'pod_quality_title': 'POD kvaliteta',
      'pod_quality_success': 'Uspjeh',
      'pod_quality_rejects': 'Odbijanja',
      'pod_quality_opp': 'Prilike',
      'pod_quality_bypass': 'Preskakanje',
      'pod_quality_blurry': 'Zamućeno',
      'pod_quality_too_dark': 'Previše tamno',
      'pod_quality_no_package': 'Nema paketa',
      'pod_quality_in_car': 'U vozilu',
      'pod_quality_too_close': 'Preblizu',
      'pod_quality_shell_week_title': 'POD KVALITETA - TJEDAN',
      'pod_quality_week_label': 'Tjedan {week}',
      'pod_quality_dashboard_title': 'POD KVALITETA NADZORNA PLOCA',
      'pod_quality_upload_pdf': 'Ucitaj PDF',
      'pod_quality_no_reports_uploaded':
          'Jos nema izvjestaja o POD kvaliteti. Ucitaj POD PDF za pocetak.',
      'pod_quality_upload_success_one':
          '1 izvjestaj POD kvalitete je obraden i spremljen.',
      'pod_quality_upload_success_many':
          '{count} izvjestaja POD kvalitete su obradena i spremljena.',
      'pod_quality_upload_parse_failed':
          'Ucitavanje/obrada nije uspjela: {error}',
      'pod_quality_rejects_breakdown': 'Raspodjela odbijanja',
      'pod_quality_no_data_week': 'Nema POD podataka za ovaj tjedan.',
      'pod_quality_drivers': 'Vozaci',
      'pod_quality_entries_count': '{count} zapisa',

      'kpi_desc_cc':
          'CC (Kontakt s Kupcem)\n\nŠto je vrijednost viša, to je bolje.\n\nIzuzetno važno:\nMoraš UVIJEK poslati poruku „Nema sigurne lokacije“ ili „Adresa nije pronađena“ svaki put kada ne možeš dostaviti paket jer:\n\n- kupac nije kod kuće ili\n- adresa se ne može pronaći',

      'kpi_tip_cc':
          'Za svaki scenarij u aplikaciji postoji automatska standardna poruka.',

      'kpi_desc_ce':
          'CE (Eskalacija Kupca)\n\nŠto je vrijednost niža, to je bolje.\nNajgora kategorija od svih.\n\nKupci eskaliraju kada se ne poštuju upute za dostavu.\n\nVozač je uvijek odgovoran\nŽalbe su gotovo nemoguće bez vrlo jakih dokaza\nIma najjači utjecaj na tvoj Scorecard\n\nKako izbjeći CE\n\nProtivno je pravilima dostave ostavljati pakete na nesigurnim ili nenadziranim mjestima bez odobrenja\n\nDelivery Associates moraju:\n- Pozvoniti / koristiti portafon ili pokucati\n- Dati kupcu dovoljno vremena za odgovor\n\nAko kupca nije moguće kontaktirati i nije postavljena sigurna lokacija:\n- Nazvati kupca dva puta\n- Poslati tekstualnu poruku\n- Kontaktirati Driver Support ako kontakt nije moguć\n\nAko je potrebno:\n- Skenirati paket kao „Dostava neuspješna – kupac nedostupan“\n- Ponovno pokušati dostavu u skladu s pravilima',

      'kpi_tip_ce':
          'Ne ostavljati pakete na nesigurnim ili neodobrenim lokacijama\nUvijek poštivati ispravne procese slanja i dostave',

      'kpi_desc_cdf':
          'CDF DPMO (Povratne Informacije Kupca o Dostavi)\n\nŠto je vrijednost niža, to je bolje.\n\nRazina 1 (L1)\n- Kupac ocjenjuje dostavu kao „Odlično” (👍) ili „Ne baš dobro” (👎)\n\nRazina 2 (L2)\n- Dodatna povratna informacija o tome zašto je iskustvo bilo dobro ili loše',

      'kpi_tip_cdf': 'CDF se izračunava isključivo na razini L1',

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

      // FAQ
      // =========================
      // CROATIAN (hr) – FAQ keys
      // =========================

      // FAQs
      'faq_title': 'Često postavljana pitanja',
      'faq_search_hint': 'Pretraži pitanja',
      'faq_empty': 'Nisu pronađena odgovarajuća ČPP pitanja.',
      'driver_tasks_error': 'Greska: {error}',
      'driver_tasks_no_tasks': 'Jos nema dodijeljenih zadataka.',
      'driver_tasks_update_status': 'Azuriraj status',
      'driver_tasks_confirm_completed': 'Potvrdi kao zavrseno',
      'driver_tasks_set_completed_first': 'Prvo postavi status na "Zavrseno".',
      'driver_tasks_completion_confirmed': 'Zavrsetak potvrden.',
      'driver_tasks_failed_update_status':
          'Azuriranje statusa nije uspjelo: {error}',
      'driver_tasks_failed_confirm_task':
          'Potvrda zadatka nije uspjela: {error}',
      'driver_tasks_status_confirmed_by_you': 'Status si potvrdio/la.',
      'driver_tasks_confirm_when_fully_done':
          'Molimo potvrdi kada je ovaj zadatak u potpunosti zavrsen.',
      'driver_tasks_status_pending': 'Na cekanju',
      'driver_tasks_status_in_progress': 'U tijeku',
      'driver_tasks_status_completed': 'Zavrseno',
      'faq_green_book_video_title': 'Video vodič za Green Book',
      'faq_green_book_video_subtitle':
          'Pogledaj korak po korak kako ispuniti Green Book',
      'faq_green_book_video_action': 'Pokreni video',
      'faq_green_book_video_missing':
          'Poveznica za Green Book video još nije postavljena.',
      'faq_green_book_video_open_failed':
          'Nije moguće otvoriti poveznicu za Green Book video.',

      'faq_q1': 'Što je najvažnije u tvom dnevnom zadatku?',
      'faq_a1': 'Dostavljanje paketa kvalitetno i uz dobro ponašanje.',

      'faq_q2': 'Što ne smiješ napraviti u slučaju problema s kupcem?',
      'faq_a2':
          'NE pokušavaj sam rješavati situaciju i umjesto toga obavijesti dežurnog dispečera. Pokušat ćemo razgovarati s kupcem umjesto tebe i izbjeći bilo kakve loše posljedice od Amazona zbog pritužbi kupaca. Tu smo za tebe!',

      'faq_q3':
          'Što ako je situacija već eskalirala i kupac nije zadovoljan zbog onoga što se dogodilo?',
      'faq_a3':
          'Nikada nije prekasno ispraviti greške. I dalje nas nazovi i pokušat ćemo ispraviti grešku s kupcem. Bolje ikad nego nikad.',

      'faq_q4':
          'Što je važnije, Količina (brzina dostave što više stajanja) ili Kvaliteta?',
      'faq_a4':
          'Kvaliteta! Uvijek kvaliteta! Slijedi upute kupca i NE ostavljaj paket na nesigurnim mjestima samo zato što kasniš sa stajanjima.',

      'faq_q5':
          'Što ako se fokusiram na kvalitetu, ali onda zaostanem sa stajanjima?',
      'faq_a5':
          'Završit ćeš svoja stajanja, na ovaj ili onaj način. Pokušat ćemo poslati pomoć, ali samo ako vidimo da je to razumno.',

      'faq_q6': 'Što je scorecard i što je DNR?',
      'faq_a6': 'Drago nam je da pitaš.',

      // 7 – Weekly scorecard
      'faq_q7': 'Tjedni scorecard',
      'faq_a7':
          'Tjedni scorecard daje nam brz, jasan pregled kako tim stoji s našim ključnim ciljevima. Pomaže nam uočiti što ide dobro, gdje zaostajemo i na što se trebamo fokusirati u nadolazećem tjednu. Ukupni rezultati su sljedeći:\n'
          '• Fantastic Plus: >93% (iznimna izvedba)\n'
          '• Fantastic: 85% – 92.9%\n'
          '• Great: 70% – 84.9%\n'
          '• Fair: 50% – 69.9%\n'
          '• Poor: <50%',

      'faq_q7_1': 'DNR kartica\nDelivered Not Received',
      'faq_a7_1':
          'To je kada si dostavio paket i kliknuo gumb "Swipe to finish" potvrđujući da si dostavio paket, ali kupac nije primio paket iz više razloga: krađa paketa, kutija je bila prazna od sadržaja paketa te pogrešna dostava na pogrešnu adresu.\n'
          'Svakog utorka dobit ćeš slike svakog DNR-a koji si imao tijekom tjedna.',

      'faq_q7_1_1':
          'Kako to trebam izbjeći i koliko je to važno za tjedni scorecard?',
      'faq_a7_1_1':
          'Vrlo je važno, a da bi to izbjegao jednostavno trebaš unaprijed obavijestiti kupca da uskoro dolaziš na njihovu kuću/poslovni prostor i zvoniti SAMO na zvono s njihovim imenom.',

      'faq_q7_1_2': 'Kako izbjeći gubitke paketa?',
      'faq_a7_1_2':
          'Uvijek pokušaj predati pakete iz ruke kupcu, a ako to nije moguće, pošalji poruku u kojoj ih obavještavaš gdje je paket ostavljen, na primjer u garaži, ispod stepenica, u šupi, iza vaze s cvijećem itd..\n'
          'Ako ne misliš da je sigurno ostaviti paket bez nadzora, molimo, uvijek je najbolje samo uzeti paket i pokušati ponovno kasnije. Ovo je VRLO važno.',

      'faq_q7_1_3': 'Kako znam koje je mjesto sigurno ili ne?',
      'faq_a7_1_3':
          'Instinkt i zdrav razum. Ako zgrada ima 20 - 30 katova i ostaviš paket kod sandučića, šanse da bude ukraden su sve veće u usporedbi s privatnom kućom.\n'
          'Također, kako bismo ti pomogli u svakodnevnim dostavama i kako bi izbjegao DNR, svako jutro ćemo objaviti sliku s adresama koje imaju veliku vjerojatnost krađe paketa i pritužbi kupaca, na temelju prethodnih rezultata dostava i statistike.',

      'faq_q7_1_4':
          'Što ako se paket izgubi ili bude ukraden, kako će to utjecati na moj rezultat?',
      'faq_a7_1_4':
          'Loše. To će te pogoditi za najmanje 30% i to je samo s jednim paketom koji ti oduzme najmanje 600 bodova. Što više bodova vidiš u scorecardu uz svoje ime, to je gore. Što više paketa dostaviš po radnom tjednu, to manje bodova gubiš. Bodovi koje gubiš također ovise o cijeni izgubljenog artikla: što je skuplje, više bodova se gubi. Ovu sekciju rezultata trebamo držati što niže moguće.\n'
          'Ne smije se zanemariti ni činjenica da, ako redovito imaš velik broj izgubljenih paketa, morat ćemo te otpustiti jer prije ili kasnije Amazon može posumnjati na krađu paketa, a to je vrlo opasno.',

      'faq_q7_2':
          'CC kartica\n'
          'Contact Compliance',
      'faq_a7_2':
          'Znači koliko puta si kontaktirao kupca u vezi njihove dostave, bilo putem poruke ili telefonskog poziva. Što manje komuniciraš s kupcem, to ćeš dobiti manje bodova u scorecardu, i ovu sekciju trebamo držati što višom jer je zapravo jedna od najlakših kategorija i puno pomaže tvom ukupnom rezultatu.',

      'faq_q7_2_1': 'Zašto bih to trebao raditi?',
      'faq_a7_2_1':
          'Dostava paketa nije samo Drop&Go, trebao bi unaprijed obavijestiti kupca i pitati ih gdje bi željeli da paket bude dostavljen.',

      'faq_q7_2_2': 'Kako poboljšati svoje CC rezultate?',
      'faq_a7_2_2':
          'Hvala što pitaš. Jednostavno: pozivima, a posebno slanjem poruka kupcima na svakoj stanici.',

      'faq_q7_3': 'CE kartica\nCostumer Escalation',
      'faq_a7_3':
          'Sjećaš se koliko je loše DNR utjecao na tvoje rezultate? E pa, ovo je najmanje 2 puta gore, i također riskiraš gubitak posla jer ovisi o tome koliko je situacija bila loša.',

      'faq_q7_3_1': 'Kako to izbjeći?',
      'faq_a7_3_1':
          'Tako da uvijek slijediš upute kupca za dostavu i u slučaju pogreške prvo se ispričaj, a ako je kupac ljut, zamoli ih za minutu vremena da razgovaraju s nama, jer nas već zoveš. Čitanjem Odjeljka 2, do sada bi trebao znati da je najbolje prepustiti nama da rješavamo takve situacije.',

      'faq_q7_4': 'POD kartica\nPicture on Delivery',
      'faq_a7_4':
          'Ova kolona prikazuje popis paketa koji su podobni za POD, za koje su fotografije snimljene, ali su označene kao Invalid ili Not Sure. Razlozi za odbijanje POD-a mogu uključivati:\n'
          '1- Etiketa paketa na fotografiji s podacima kupca. Paket treba okrenuti naopako prije nego što se snimi fotografija.\n'
          '2- Zamućena fotografija\n'
          '3- Osoba vidljiva na fotografiji\n'
          '4- Nije detektiran paket na fotografiji\n'
          '5- Paket u autu\n'
          '6- Paket u ruci\n'
          '7- Paket u sandučiću\n'
          '8- Paket preblizu\n'
          '9- Fotografija previše tamna.\n'
          'Ovo bi uvijek trebalo biti najlakše gdje trebaš imati rezultat od 100% i poboljšava tvoj ukupni rezultat',

      'faq_q7_5': 'LoR kartica\nLost on Road',
      'faq_a7_5':
          'Kažnjava te kada si skenirao paket pri utovaru i nisi ga vratio na kraju smjene u slučaju neuspješne dostave. Dakle, paket je izgubljen i izgubit ćeš onoliko bodova koliko bi izgubio i za DNR, zato dobro prebroji pakete koje vraćaš i provjeri odgovaraju li paketima prikazanim u scanneru. Možeš ih pronaći na: Todays Itinerary - Summary - Problems. Ako se ne podudaraju, molimo obavijesti dežurnog dispečera prije završetka rada u Amazon aplikaciji.',

      'faq_q7_6': 'DCR kartica\nDelivery Completion Rate',
      'faq_a7_6':
          'Pokazuje tvoje sposobnosti u dostavljanju paketa. Prati postotak dostava dovršenih prema planu, pomažući nam mjeriti učinkovitost i pouzdanost naših dostava. Ističe probleme poput kašnjenja, neuspješnih pokušaja ili problema s rutiranjem. Ovo bi uvijek trebalo biti što više moguće. Da bi to bilo moguće, svaki dan trebaš raditi reattempts i izbjegavati koliko god možeš vraćanje paketa.',

      'faq_q7_7': 'CDF kartica (Previously, DEX)\nCostumer Delivery Feedback',
      'faq_a7_7':
          'Bilježi iskustvo primatelja s procesom dostave, uključujući točnost, stanje robe i profesionalnost vozača. Pomaže nam identificirati snage usluge i područja za poboljšanje. Na kraju dostave, kupac dobiva e-mail od Amazona o iskustvu dostave, s pitanjima kao što su:\n'
          '1) Je li tvoj paket dostavljen na vrijeme?\n'
          'Da / Ne\n'
          '2) Je li paket ostavljen na sigurnom mjestu?\n'
          'Da / Ne\n'
          '3) Je li paket bio u dobrom stanju kada je stigao?\n'
          'Da / Ne\n'
          '4) Koliko si zadovoljan dostavom ukupno?\n'
          'Vrlo zadovoljan / Zadovoljan / Neutralan / Nezadovoljan / Vrlo nezadovoljan\n'
          '5) Kako bi ocijenio komunikaciju i ažuriranja praćenja za ovu dostavu?\n'
          'Odlično / Dobro / Osrednje / Loše\n'
          '6) Je li dostavljač bio ljubazan i profesionalan?\n'
          'Da / Ne / Nije primjenjivo (Bes kontaktna dostava)\n'
          '7) Imaš li komentare o svom iskustvu dostave?\n'
          '(Dodatni komentari kupca)',

      'faq_q7_8': 'Što trebam imati na umu o scorecardu?',
      'faq_a7_8':
          'Kvaliteta i učinkovitost puno znače. Dobri rezultati su dobri za tebe, za kompaniju i dobri za cijeli tim. Zadovoljstvo kupaca je vrlo važno i dobri rezultati su popraćeni bonusom od kompanije.\n'
          'Daj najbolje od sebe, dobiješ najbolje.',

      'faq_q8': 'Na koja druga područja trebam paziti?',
      'faq_a8':
          'Brini se o sebi vozeći sigurno, izbjegavajući ozljede i izbjegavajući pse i ugrize pasa. Budi pažljiv s radnom opremom kao što su dnevno vozilo, radni scanner/telefon i dolazi na posao noseći sigurnosne cipele i sigurnosni prsluk, Amazon jaknu ili majicu (ovisno o vremenu).',

      'faq_q9':
          'Što se događa ako doživim prometnu nesreću ili oštetim radno vozilo?',
      'faq_a9':
          'Prvo, provjeri da si dobro i da nisi teško ozlijeđen. Što se tiče štete na vozilu, ako utvrdimo da se nesreće događaju zbog nemara – na primjer, ometanja poput korištenja mobitela tijekom vožnje – bit ćeš osobno odgovoran za punu štetu. Osim toga, dobit ćeš policijski zapisnik, što može čak rezultirati suspenzijom vozačke dozvole. Naravno, to je također razlog za trenutni otkaz. U suprotnom, samo si isključen iz primanja tjednih Scorecard bonusa na 2 mjeseca. U slučaju incidenta, DUŽAN si nas odmah obavijestiti i dati nam vrijeme incidenta, lokaciju, postoji li šteta na privatnoj ili javnoj imovini (poput zidova, ograda, stupova rasvjete, ljudi i/ili kućnih ljubimaca), lokaciju i fotografije štete na vozilu.',

      'faq_q10': 'Što radim kada imam pakete oštećene i/ili nedostaju.',
      'faq_a10':
          'Kada je paket oštećen, slobodno ga označi kao oštećen i vrati ga u stanicu. Ako je taj oštećeni paket bio tekući paket i oštetio druge pakete, molimo napravi fotografiju svih oštećenih paketa i pošalji je dežurnom dispečeru, a mi ćemo to prijaviti Amazonu za tebe.\n'
          'Kada paket nedostaje, slobodno ga označi/rezerviraj kao nedostajući osim ako ima OTP za koji MORAŠ prvo nama prijaviti prije nego što ga označiš kao nedostajući. Ovo je VRLO važno.',

      'faq_q11': 'Što je OTP (One-Time Password) paket?',
      'faq_a11':
          'To je skup predmet za koji Amazon zahtijeva da kupac dostavljaču da jednokratnu lozinku (One Time Password) prije dostave paketa, kako bi se osiguralo da je paket dostavljen pravoj osobi/kupcu. Moraš biti posebno pažljiv s takvim paketima, ne ostavljati ih bez nadzora i predati ih samo kupcu koji ti je dao lozinku.',

      'faq_q12': 'Zašto te stalno gnjavimo da usporiš i da ne ideš brže?',
      'faq_a12':
          'Ni nama se to ne sviđa, ali takav je sustav. Moramo slijediti algoritam sustava i napraviti onoliko stajanja po satu koliko je unaprijed određeno kako bismo u budućnosti dobili više ruta i da ti možeš više raditi i ne biti slobodan.\n'
          'Također, bržom vožnjom riskiraš DNR i gubitak bodova za oboje, sebe i kompaniju, u tjednom scorecardu.',

      'faq_q13':
          'Pa zašto me dispečeri ponekad pitaju zašto kasnim i je li nešto pošlo po zlu?',
      'faq_a13':
          'Znamo da ovo nije ugodno, ali trebamo povratnu informaciju o tome što se moglo dogoditi na cesti zbog čega si zaostao sa stajanjima. Amazon traži ovu povratnu informaciju jer postoji i vremensko ograničenje do kojeg si trebao dostaviti X stajanja, stoga Amazon treba znati zašto su preostala stajanja iza rasporeda dostave i s ovom informacijom poboljšati buduću učinkovitost dostave.',

      'faq_q14': 'Zašto te ponekad tražimo da ideš pomoći kolegi?',
      'faq_a14':
          'Zato što mnogi faktori utječu na kašnjenje kolege, poput loše internetske veze u području, prometa, blokiranih ulica zbog radova u području, što je otežalo drugom vozaču da dostavi na vrijeme, stoga je potrebna tvoja pomoć.',

      'faq_q15':
          'Počinjem li odmah prvog dana dostavljati standardne rute kao i drugi, iskusniji vozači?',
      'faq_a15':
          'Ne, očito to nije slučaj za tebe. Na početku ćeš imati razdoblje od 14 radnih dana da u praksi primijeniš ono što si naučio u ride-along danima s trenerom i prilagodiš se području, vozilu, scanneru i naučiš tijek rada.\n'
          'Uz to, za to razdoblje od 14 dana, Amazon će ti dati do 50% manje paketa i stajanja nego inače u tvom rasporedu.',

      'faq_q16':
          'Što učiniti kada je adresa pogrešna i/ili pin lokacije nije točan na karti?',
      'faq_a16':
          'Prvo potvrdi da pin nije točan tako što ćeš potražiti adresu u Google Maps (točnije je i već je instalirano na tvom scanneru) i ako se ne podudara, obavijesti dežurnog dispečera o greškama.',

      'faq_q17':
          'Koji su moji dnevni zadaci prije nego počnem i nakon što završim posao?',
      'faq_a17':
          '1- Kada dođeš na parking, prvo provjeri nosiš li sigurnosne cipele, sigurnosni prsluk i Amazon uniformu.\n'
          '2- Provjeri je li scanner potpuno napunjen i obavijesti dispečera koji je tada prisutan ako nije napunjen.\n'
          '3- Provjeri ima li nešto pogrešno s vozilom.\n'
          '4- Pokreni trip u Mentor aplikaciji na svom scanneru.\n'
          '5- Objavi fotografiju instrument ploče vozila koja prikazuje trenutnu kilometražu i dnevni trip (u vozilu) resetiran na 0.\n'
          '6- Pripremi se za spuštanje u Waiting Area samo 10 minuta prije planiranog vremena utovara, ne ranije.\n'
          '7- Kada si u Waiting area, ugasi vozilo, pokreni Flex App i Timesheet. Molimo, ni minutu ranije, posebno flex app. Ne zaboravi 10-minutni timestamp.\n'
          '8- Zatim idi u Loading Area prema uputama Yard Marshalla. Kada si u Loading area, ugasi vozilo i izađi iz vozila TEK NAKON što čuješ zvižduk Yard Marshalla.\n'
          '9- Nakon što završiš utovar, upali vozilo i počni voziti, ali samo kada ti Yard Marshall kaže.\n'
          '10- Nakon što završiš sva stajanja, provjeri spremnik goriva i ako je manje od pola, molimo natoči gorivo.\n'
          '11- Kada si na stanici, molimo odloži sve preostale pakete na područja koja je odredio Amazon, odloži vreće na vrijeme\n'
          '12- Kada si na parkingu, ugasi vozilo i ispuni Green Book (Tageskontrollblat), objavi fotografiju dnevne kilometraže koju si napravio tijekom dana dostavljajući, zajedno s fotografijom Green Booka.\n'
          '13- Ugasi vozilo i molimo vrati radnu torbu na označeno mjesto/van',

      'faq_q18':
          'Moram li nešto učiniti kada mijenjam kombi i uzmem drugi kombi umjesto onog koji obično uzimam?',
      'faq_a18':
          'Trebao bi napraviti video, detaljno snimajući svaku malu štetu koju su prethodni vozač(i) mogli napraviti, kako ne bi bila tvoja krivnja pri sljedećem pregledu vozila.',

      'faq_q19':
          'Što trebam učiniti ako se Flex aplikacija stalno učitava i usporava moj tijek rada?',
      'faq_a19':
          'Prvo provjeri imaš li aktivnu internetsku vezu. Da to provjeriš možeš pokušati poslati poruku kupcu na trenutnom stajanju i ako prođe, to znači da je internetska veza aktivna. Također možeš provjeriti otvaranjem druge aplikacije na scanneru, poput preglednika, i pretraživanjem nečega.\n'
          'Koraci koje trebaš slijediti ako nema aktivne internetske veze:\n'
          '1- Ponovno pokreni scanner. Ovo bi uvijek trebalo biti prvo što pokušaš.\n'
          '2- Uključi/isključi airplane mode. Ovo radi većinu vremena bez čekanja da se scanner ponovno pokrene.\n'
          '3- Kao posljednje rješenje, molimo pokušaj podijeliti hotspot s osobnog telefona na maksimalno 10 minuta samo da se sustav osvježi.\n'
          'Možeš raditi i offline, ali u nekom trenutku moraš se spojiti na internet i biti aktivan. Da radiš offline, prvo moraš preuzeti offline karte u Flex aplikaciji. Da to napraviš, ideš na Settings - Offline Maps (zadnja opcija) - Download DBY5 - Allow downloads with mobile connection.\n',

      'faq_q20':
          'Što ako je internetska veza aktivna, a Flex aplikacija i dalje ne radi kako bi trebala?',
      'faq_a20':
          '1- Ponovno pokreni scanner.\n'
          '2- Uključi/isključi airplane mode\n'
          '3- Izađi iz aplikacije\n'
          '4- Isključi/uključi Location Services (GPS)\n'
          '5- Odjavi se iz Flex aplikacije i ponovno se prijavi s vjerodajnicama koje koristiš za Mentor aplikaciju.\n'
          '6- Provjeri treba li aplikaciju ažurirati.\n'
          'Trebaš isprobati ove korake jedan po jedan. Ako jedan ne radi, molimo pokušaj sljedeći ispod njega.',
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
      'header_good_afternoon': 'نهارك سعيد',
      'header_good_evening': 'مساء الخير',
      'select_language': 'اختر اللغة',
      'notifications': 'الإشعارات',
      'no_notifications': 'لا توجد إشعارات',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'مساعدة',
      'nav_rules': 'القواعد',
      'nav_profile': 'الملف الشخصي',
      'nav_tasks': 'المهام',
      'driver_home_dispatcher': 'الديسباتشر',
      'driver_home_shift_plan_title': 'خطة الشفت',
      'driver_home_shift_plan_subtitle': 'شفتاتك',
      'driver_home_scorecard_subtitle': 'نظرة عامة على ادائك',
      'driver_home_tasks_title': 'المهام',
      'driver_home_tasks_subtitle': 'ادارة المهام المفتوحة',
      'driver_home_academy_subtitle': 'تدريب ومعرفة',
      'driver_home_rules_title': 'قواعد الشركة',
      'driver_home_rules_subtitle': 'ارشادات وسياسات',
      'driver_notification_published_on': 'تم النشر {date}',
      'driver_home_vehicles_title': 'المركبات',
      'driver_home_vehicles_subtitle': 'نظرة عامة على المركبات',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'مساعدك الذكي',
      'driver_home_absence_title': 'الغياب',
      'driver_home_absence_subtitle': 'اجازة ومرضية',
      'driver_home_incident_title': 'بلاغ حادث',
      'driver_home_incident_subtitle': 'ابلاغ عن حادث',
      'driver_home_new_badge': 'جديد',
      'driver_academy_title': 'اكاديمية DA',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle': 'ارشادات ورقة الفحص اليومية',
      'driver_academy_safety_title': 'تدريب السلامة',
      'driver_academy_safety_subtitle': 'دورات السلامة',
      'driver_academy_delivery_title': 'توصيل امازون',
      'driver_academy_delivery_subtitle': 'عمليات وتدفقات التوصيل',
      'driver_academy_app_title': 'تطبيق CoDriver',
      'driver_academy_app_subtitle': 'ميزات وارشادات التطبيق',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - فيديو تدريبي',
      'driver_green_book_video_subtitle': 'اضغط للتشغيل',
      'driver_green_book_start_test': 'ابدأ اختبار Green Book',
      'driver_green_book_test_required': 'الاختبار مطلوب',
      'driver_green_book_section1_title': 'ورقة الفحص اليومية Green Book',
      'driver_green_book_section1_text':
          'ورقة الفحص اليومية (Green Book) مستند إلزامي يجب تعبئته قبل كل وردية. تساعد في التحقق من حالة المركبة وتوثيق نقاط السلامة.',
      'driver_green_book_section1_b1': 'قم بتعبئتها بالكامل قبل كل وردية.',
      'driver_green_book_section1_b2': 'ابلغ عن اعطال المركبة فوراً.',
      'driver_green_book_section1_b3': 'لا تنس التوقيع.',
      'driver_green_book_section2_title': 'عواقب عدم الالتزام',
      'driver_green_book_section2_text':
          'يتم التعامل مع المخالفات على مراحل تصاعدية:',
      'driver_green_book_section2_b1':
          'التحذير الاول: تحذير شفهي من الديسباتشر.',
      'driver_green_book_section2_b2': 'التحذير الثاني: تحذير خطي.',
      'driver_green_book_section2_b3': 'المخالفات المتكررة: اجراءات تأديبية.',
      'driver_green_book_section3_title': 'العقوبات القانونية',
      'driver_green_book_section3_text':
          'إذا كان Green Book مفقوداً او غير مكتمل عند الفحص:',
      'driver_green_book_section3_b1': 'غرامة تصل الى 5000 يورو على السائق.',
      'driver_green_book_section3_b2': 'غرامة تصل الى 30000 يورو على الشركة.',
      'driver_green_book_section3_b3': 'قد يتم تسجيل نقاط في فلنسبورغ.',
      'driver_green_book_section3_b4': 'قد يؤثر ذلك سلباً على التأمين.',
      'driver_green_book_test_title': 'اختبار Green Book',
      'driver_green_book_test_progress': 'السؤال {current} من {total}',
      'driver_green_book_test_next': 'التالي',
      'driver_green_book_test_submit': 'ارسال الاختبار',
      'driver_green_book_test_result_pass_title': 'تم اجتياز الاختبار',
      'driver_green_book_test_result_fail_title': 'لم يتم اجتياز الاختبار',
      'driver_green_book_test_result_pass_body':
          'مبروك! نجحت في الاختبار بنتيجة {score}/{total}.',
      'driver_green_book_test_result_fail_body':
          'نتيجتك {score}/{total}. حاول مرة اخرى.',
      'driver_green_book_test_retry': 'اعادة المحاولة',
      'driver_green_book_test_close': 'اغلاق',
      'driver_green_book_test_back_to_green_book': 'العودة الى Green Book',
      'driver_green_book_test_no_questions':
          'لا توجد اسئلة اختبار مهيأة بعد. يرجى التواصل مع الديسباتشر.',
      'driver_green_book_test_offline_fallback':
          'فشلت مزامنة الاختبار المباشرة. يمكنك المتابعة باسئلة بديلة ثم المحاولة مرة اخرى.',
      'admin_home_notification': 'إشعار',
      'admin_home_driver_fallback': 'سائق',
      'admin_home_not_confirmed_by': 'لم يؤكد بواسطة:',
      'admin_home_missing_loading': 'المتبقي: ...',
      'admin_home_missing_unknown': 'المتبقي: --',
      'admin_home_missing_count': 'المتبقي: {count}',
      'admin_home_error_generic': 'خطأ: {error}',
      'admin_home_all_drivers_confirmed': 'جميع السائقين أكدوا.',
      'admin_home_close': 'إغلاق',
      'admin_home_last_week': 'الأسبوع الماضي',
      'admin_home_not_logged_in': 'غير مسجل الدخول.',
      'admin_home_loading_reports': 'جارٍ تحميل التقارير...',
      'admin_home_no_reports_uploaded': 'لا توجد تقارير مرفوعة بعد.',
      'admin_home_week_short': 'أسبوع',
      'admin_home_month_prefix': 'الشهر',
      'admin_home_year_prefix': 'السنة',
      'admin_home_loading_scores': 'جارٍ تحميل الدرجات...',
      'admin_home_name_fallback': 'الاسم الكامل',
      'admin_home_scorecard': 'بطاقة الأداء',
      'admin_home_company_score': 'درجة الشركة',
      'admin_home_of': 'من',
      'admin_home_best_driver': 'أفضل سائق',
      'admin_home_worst_defender': 'أضعف مدافع',
      'admin_home_notification_history': 'سجل الإشعارات',
      'admin_home_no_notifications_yet': 'لا توجد إشعارات بعد.',
      'admin_home_notification_type_message': 'رسالة جديدة',
      'admin_home_notification_type_academy': 'أكاديمية DA',
      'admin_home_notification_type_ride_along': 'مرافقة',
      'admin_home_notification_type_rule': 'قاعدة جديدة',
      'admin_home_edit_rule': 'تعديل القاعدة',
      'admin_home_title': 'العنوان',
      'admin_home_body': 'المحتوى',
      'admin_home_cancel': 'إلغاء',
      'admin_home_save': 'حفظ',
      'admin_home_title_or_body_required': 'العنوان أو المحتوى مطلوب.',
      'admin_home_notification_not_found': 'لم يتم العثور على الإشعار.',
      'admin_home_rule_updated_for_drivers':
          'تم تحديث القاعدة لـ {count} سائق.',
      'admin_home_edit_failed': 'فشل التعديل: {error}',
      'admin_home_delete_notification_question': 'حذف الإشعار؟',
      'admin_home_delete_notification_body':
          'سيتم حذف هذا الإشعار لك ولجميع السائقين.',
      'admin_home_delete': 'حذف',
      'admin_home_notification_deleted': 'تم حذف الإشعار.',
      'admin_home_delete_failed': 'فشل الحذف: {error}',
      'admin_home_options': 'خيارات',
      'admin_home_title_upper': 'العنوان',
      'admin_home_confirmed_by': 'تم التأكيد بواسطة',
      'admin_home_fleet_hub': 'مركز الأسطول',
      'admin_home_service': 'الخدمة',
      'admin_home_accidents': 'الحوادث',
      'admin_home_total': 'الإجمالي',
      'admin_home_active': 'النشط',
      'admin_home_inactive': 'غير النشط',
      'admin_home_doc_id_card': 'بطاقة الهوية',
      'admin_home_doc_driving_license': 'رخصة القيادة',
      'admin_home_doc_residence_permit': 'تصريح الإقامة',
      'admin_home_loading_drivers': 'جارٍ تحميل السائقين...',
      'admin_home_no_drivers_yet': 'لا يوجد سائقون بعد.',
      'admin_home_contract': 'عقد',
      'admin_home_last_day': 'اليوم الأخير',
      'admin_home_probation': 'فترة التجربة',
      'admin_home_ended': 'انتهى',
      'admin_home_ends': 'ينتهي',
      'admin_home_expired_by': 'منتهي بتاريخ',
      'admin_home_loading_documents': 'جارٍ تحميل المستندات...',
      'admin_home_driver_documents': 'مستندات السائقين',
      'admin_home_expired_documents': 'مستندات منتهية',
      'admin_home_expired_soon': 'تنتهي قريبًا',
      'admin_home_missing_documents_data': 'مستندات / بيانات ناقصة',
      'admin_home_total_missing': 'إجمالي النواقص',
      'admin_home_driver_contracts': 'عقود السائقين',
      'admin_home_last_day_soon': 'اليوم الأخير قريبًا',
      'admin_home_no_items': 'لا توجد عناصر',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'تغيير صورة الملف الشخصي',
      'profile_change_photo': 'تغيير صورة الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'profile_logout': 'تسجيل الخروج',
      'pin_change_with_old':
          'يمكنك تغيير الرقم السري بعد التحقق من الرقم السري القديم.',
      'pin_forgot_contact_admin': 'نسيت الرقم السري؟ تواصل مع المسؤول.',
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
      'dash_company_data_section': 'البيانات على مستوى الشركة',
      'dash_company_data_show': 'عرض النتائج كشركة',
      'dash_company_data_hide': 'إخفاء فئات الشركة',

      'dash_rank': 'الترتيب',
      'dash_score': 'النتيجة',
      'dash_name': 'الاسم',

      'dash_delivered': 'تم التسليم',
      'dash_rank_in_aion': 'الترتيب في AION',
      'dash_rank_of_total': '{rank} من {total}',

      'dash_no_my_score_week':
          'لم يتم العثور على نتيجة لمعرّف السائق الخاص بك في هذا الأسبوع.',
      'dash_all_status': 'كل الحالات',
      'dash_search_name_or_id': 'ابحث بالاسم أو معرف الناقل...',
      'dash_upload_driver_csv': 'رفع CSV السائقين',

      'scorecard_overview_title': 'لوحة متابعة SCORE CARD',
      'scorecard_overview_overview_suffix': '— نظرة عامة',
      'scorecard_overview_upload_pdf': 'رفع PDF بطاقة الأداء',
      'scorecard_overview_upload_prompt': 'ارفع ملف PDF لبطاقة الأداء',
      'scorecard_overview_choose_file': 'اختر ملف',
      'scorecard_overview_summary_title': 'ملخص بطاقة الأداء',
      'scorecard_overview_no_reports_yet':
          'لا توجد تقارير بعد. ارفع أول ملف PDF لبطاقة الأداء للبدء.',
      'scorecard_overview_chart_title': 'نظرة عامة على بطاقة الأداء',
      'scorecard_overview_best_drivers': 'أفضل السائقين',
      'scorecard_overview_no_reports_available': 'لا توجد تقارير متاحة.',
      'scorecard_overview_no_drivers_period':
          'لم يتم العثور على سائقين لهذه الفترة.',
      'scorecard_overview_select_station': 'اختر المحطة',
      'scorecard_overview_all_stations': 'كل المحطات',
      'scorecard_overview_select_period': 'اختر الفترة',
      'scorecard_overview_best_drivers_year': 'أفضل السائقين في السنة',
      'scorecard_overview_best_drivers_month': 'أفضل السائقين في الشهر',
      'scorecard_overview_station': 'المحطة',
      'scorecard_overview_station_code': 'المحطة {code}',
      'scorecard_overview_upload_success_one':
          'تم تحليل وحفظ بطاقة أداء واحدة. تم تحديث اللوحة.',
      'scorecard_overview_upload_success_many':
          'تم تحليل وحفظ {count} بطاقات أداء. تم تحديث اللوحة.',
      'scorecard_overview_upload_parse_failed': 'فشل الرفع/التحليل: {error}',
      'scorecard_overview_no_file_bytes': 'لا توجد بيانات ملف',
      'scorecard_overview_csv_updated':
          'تم تحديث أسماء السائقين في جميع تقاريرك.',
      'scorecard_overview_csv_failed': 'فشل استيراد CSV: {error}',
      'scorecard_overview_delete_report_q': 'حذف التقرير؟',
      'scorecard_overview_delete_report_body':
          'سيؤدي هذا إلى حذف التقرير "{title}" وكل إدخالات الدرجات لهذا الأسبوع.',
      'scorecard_overview_deleted': 'تم حذف التقرير ودرجات الأسبوع.',
      'scorecard_overview_delete_failed': 'فشل الحذف: {error}',
      'scorecard_overview_more': 'المزيد',
      'scorecard_overview_delete_report_menu': 'حذف التقرير',
      'scorecard_overview_upload_processing':
          'جارٍ رفع ومعالجة بطاقات الأداء...',
      'scorecard_overview_row_title': 'بطاقة الأداء {year} أسبوع {week}',
      'scorecard_overview_reliability_score': 'درجة الموثوقية',
      'scorecard_overview_from_last_week': 'مقارنة بالأسبوع الماضي',
      'scorecard_overview_from_last_year': 'مقارنة بالعام الماضي',

      'kpi_score': 'النتيجة',
      'kpi_value': 'القيمة',
      'kpi_pro_tip': 'نصيحة',

      'kpi_title_dcr': 'معدل نجاح التسليم',
      'kpi_title_dnr': 'شروط نجاح التسليم',
      'kpi_title_lor': 'مفقود أثناء الطريق',
      'kpi_title_pod': 'صورة عند التسليم',
      'kpi_title_cc': 'التواصل مع العميل',
      'kpi_title_ce': 'تصعيد من العميل',
      'kpi_title_cdf': 'تقييم العميل لعملية التسليم',

      'kpi_desc_dcr':
          'كلما كانت القيمة أعلى، كان ذلك أفضل. للوصول إلى معدل نجاح 100٪، يُوصى بمحاولة إعادة التسليم* بعد فشل عملية التسليم.',
      'kpi_tip_dcr':
          'مثال: إذا لم تتمكن في يوم ما من تسليم طرد لأي سبب، وحاولت التسليم مرة أخرى لاحقًا في نفس اليوم، فستكون قيمة DCR أعلى وأقرب إلى 100٪، حتى لو كانت محاولة التسليم الثانية غير ناجحة أيضًا.',

      'kpi_desc_dnr':
          'DSC DPMO (شروط نجاح التسليم)\n(سابقًا DNR – لم يتم استلام التسليم)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\n\nيقيس هذا المؤشر مدى صحة وقابلية تتبع عمليات التسليم.\n\nقواعد التسليم الأساسية:\n- التسليم إلى الشخص الصحيح أو الموقع الصحيح\n- التسليم إلى العملاء أو أفراد الأسرة أو الجيران أو موظفي الاستقبال منخفض المخاطر عند تنفيذه بشكل صحيح\n- استخدم دائمًا رمز المسح/السبب الصحيح حتى يتلقى العملاء إشعارات صحيحة\n\nالتسليم إلى غرفة البريد / صندوق البريد:\n- اتباع سير العمل القياسي\n- يجب أن تكون الطرود بالكامل داخل صندوق البريد أو فتحة البريد وألا تبرز للخارج\n- استخدام أدق عملية مسح متاحة\n\nالعنوان الصحيح وGeofence:\n- التسليم ضمن 25 مترًا من geofence الصحيح\n- مطابقة الاسم والعنوان في التطبيق دائمًا مع ملصق الطرد والمبنى\n- إذا بدا الرمز الجغرافي غير صحيح، قم بالإبلاغ عبر SDS\n\nالصورة عند التسليم (POD):\n- التقاط صورة واضحة دائمًا عند الطلب\n- يجب أن يكون الطرد والمحيط واضحين\n- مهم بشكل خاص لعمليات التسليم غير المراقبة ولثقة العملاء\n\nالالتزام بتفضيلات التسليم:\n- اتباع تعليمات العميل في التطبيق إذا كانت آمنة\n- إذا كانت التعليمات غير آمنة، تواصل مع العميل\n- استخدام مواقع التسليم الآمنة المعتمدة فقط من التطبيق\n\nالتوقفات المتزامنة / الجماعية:\n- استخدم \"تحديد الكل\" فقط عندما يتم تسليم عدة طرود لنفس الشخص أو نفس الموقع (مثل مكتب الاستقبال)\n- تسجيل اسم المستلم والتوقيع بشكل صحيح',

      'kpi_tip_dnr':
          'تنبيه مهم:\n\nالقيم المرتفعة المتكررة في DSC DPMO تشير إلى عمليات تسليم غير صحيحة أو محفوفة بالمخاطر.\n\n- قد تفسر أمازون الانحرافات المتكررة على أنها سرقة محتملة\n- قد يؤدي ذلك إلى بدء إجراء منع الخسائر\n- في أسوأ الحالات، قد يؤدي ذلك إلى إنهاء التعاون\n\nالمسح الدقيق، والتقاط الصور الصحيحة، والالتزام بجميع قواعد التسليم يحميك ويحمي فريقك.',

      'kpi_desc_lor':
          'LoR (مفقود أثناء الطريق)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\n\nيوضح هذا المؤشر ما إذا تم تسجيل جميع الطرود غير المسلمة بشكل صحيح في نهاية المسار.\n\nفي نهاية المسار:\n- التحقق في الماسح الضوئي من عدد الطرود التي يجب إرجاعها\n- التأكد من أن هذا العدد يطابق تمامًا الطرود الموجودة في المركبة',

      'kpi_tip_lor':
          'تنبيه مهم:\n\nهذه هي الفئة ذات أعلى اشتباه بالسرقة.\n\nقد تُعتبر الفروقات بين الماسح الضوئي ومخزون المركبة أخطاء جسيمة وقد تؤدي إلى تحقيقات داخلية أو عواقب أخرى.',

      'kpi_desc_pod':
          'PoD (صورة عند التسليم)\n\nكلما كانت القيمة أعلى، كان ذلك أفضل.\n\nيعرض هذا العمود الطرود التي تم التقاط صورة لها ولكن تم تصنيفها على أنها غير صالحة أو غير آمنة.\n\nالأسباب الشائعة لرفض POD:\n1. ملصق الطرد مع بيانات العميل ظاهر (يجب قلب الطرد)\n2. صورة غير واضحة\n3. ظهور شخص في الصورة\n4. لا يظهر أي طرد في الصورة\n5. الطرد داخل المركبة\n6. الطرد في اليد\n7. الطرد قريب جدًا من الكاميرا\n8. الصورة مظلمة جدًا',

      'kpi_tip_pod':
          'يجب أن تكون هذه أسهل فئة\nالقيمة المستهدفة: 100٪\nتحسن النتيجة الإجمالية بشكل كبير',

      'pod_quality_title': 'جودة POD',
      'pod_quality_success': 'نجاح',
      'pod_quality_rejects': 'رفض',
      'pod_quality_opp': 'فرص',
      'pod_quality_bypass': 'تجاوز',
      'pod_quality_blurry': 'غير واضح',
      'pod_quality_too_dark': 'داكن جدًا',
      'pod_quality_no_package': 'بدون طرد',
      'pod_quality_in_car': 'في السيارة',
      'pod_quality_too_close': 'قريب جدًا',
      'pod_quality_shell_week_title': 'جودة POD - الأسبوع',
      'pod_quality_week_label': 'الأسبوع {week}',
      'pod_quality_dashboard_title': 'لوحة جودة POD',
      'pod_quality_upload_pdf': 'رفع PDF',
      'pod_quality_no_reports_uploaded':
          'لا توجد تقارير جودة POD بعد. ارفع ملف POD PDF للبدء.',
      'pod_quality_upload_success_one': 'تم تحليل وحفظ تقرير جودة POD واحد.',
      'pod_quality_upload_success_many':
          'تم تحليل وحفظ {count} من تقارير جودة POD.',
      'pod_quality_upload_parse_failed': 'فشل الرفع/التحليل: {error}',
      'pod_quality_rejects_breakdown': 'تفصيل الرفض',
      'pod_quality_no_data_week': 'لا توجد بيانات POD لهذا الأسبوع.',
      'pod_quality_drivers': 'السائقون',
      'pod_quality_entries_count': '{count} إدخال',

      'kpi_desc_cc':
          'CC (التواصل مع العميل)\n\nكلما كانت القيمة أعلى، كان ذلك أفضل.\n\nمهم للغاية:\nيجب عليك دائمًا إرسال رسالة \"لا يوجد مكان آمن\" أو \"لم يتم العثور على العنوان\" في كل مرة لا تتمكن فيها من تسليم طرد لأن:\n\n- العميل غير موجود في المنزل أو\n- لا يمكن العثور على العنوان',

      'kpi_tip_cc': 'توجد رسالة قياسية تلقائية في التطبيق لكل سيناريو.',

      'kpi_desc_ce':
          'CE (تصعيد من العميل)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\nأسوأ فئة على الإطلاق.\n\nيقوم العملاء بالتصعيد عندما لا يتم الالتزام بتعليمات التسليم.\n\nالسائق مسؤول دائمًا\nالاعتراضات شبه مستحيلة دون أدلة قوية جدًا\nله التأثير الأقوى على بطاقة الأداء الخاصة بك\n\nكيفية تجنب CE\n\nيُعد مخالفًا لإرشادات التسليم ترك الطرود في أماكن غير آمنة أو غير مراقبة دون موافقة\n\nيجب على Delivery Associates:\n- استخدام الجرس / جهاز الاتصال أو الطرق على الباب\n- منح العميل وقتًا كافيًا للرد\n\nإذا لم يكن من الممكن الوصول إلى العميل ولم يتم تحديد مكان آمن:\n- الاتصال بالعميل مرتين\n- إرسال رسالة نصية\n- التواصل مع Driver Support إذا لم يكن الاتصال ممكنًا\n\nإذا لزم الأمر:\n- مسح الطرد كـ \"فشل التسليم – العميل غير متاح\"\n- إعادة محاولة التسليم وفقًا للإرشادات',

      'kpi_tip_ce':
          'لا تترك الطرود في أماكن غير آمنة أو غير معتمدة\nالتزم دائمًا بعمليات الشحن والتسليم الصحيحة',

      'kpi_desc_cdf':
          'CDF DPMO (تقييم العميل لعملية التسليم)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\n\nالمستوى 1 (L1)\n- يقيم العميل عملية التسليم على أنها \"رائعة\" (👍) أو \"ليست جيدة\" (👎)\n\nالمستوى 2 (L2)\n- ملاحظات إضافية حول سبب كون التجربة جيدة أو سيئة',

      'kpi_tip_cdf': 'يتم احتساب CDF حصريًا على مستوى L1',

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

      // =========================
      // ARABIC (ar) – FAQ keys
      // =========================

      // FAQs
      'faq_title': 'الأسئلة الشائعة',
      'faq_search_hint': 'ابحث في الأسئلة',
      'faq_empty': 'لم يتم العثور على أسئلة شائعة مطابقة.',
      'driver_tasks_error': 'خطأ: {error}',
      'driver_tasks_no_tasks': 'لا توجد مهام مخصصة بعد.',
      'driver_tasks_update_status': 'تحديث الحالة',
      'driver_tasks_confirm_completed': 'تأكيد الإنجاز',
      'driver_tasks_set_completed_first': 'عيّن الحالة إلى "مكتمل" أولاً.',
      'driver_tasks_completion_confirmed': 'تم تأكيد الإنجاز.',
      'driver_tasks_failed_update_status': 'فشل تحديث الحالة: {error}',
      'driver_tasks_failed_confirm_task': 'فشل تأكيد المهمة: {error}',
      'driver_tasks_status_confirmed_by_you': 'تم تأكيد الحالة من قبلك.',
      'driver_tasks_confirm_when_fully_done':
          'يرجى التأكيد عند اكتمال هذه المهمة بالكامل.',
      'driver_tasks_status_pending': 'قيد الانتظار',
      'driver_tasks_status_in_progress': 'قيد التنفيذ',
      'driver_tasks_status_completed': 'مكتمل',
      'faq_green_book_video_title': 'فيديو شرح Green Book',
      'faq_green_book_video_subtitle': 'شاهد خطوة بخطوة كيفية تعبئة Green Book',
      'faq_green_book_video_action': 'تشغيل الفيديو',
      'faq_green_book_video_missing': 'رابط فيديو Green Book غير مُعدّ بعد.',
      'faq_green_book_video_open_failed': 'تعذر فتح رابط فيديو Green Book.',

      'faq_q1': 'ما هو الأهم في مهمتك اليومية؟',
      'faq_a1': 'تسليم الطرود بجودة وبسلوك جيد.',

      'faq_q2': 'ما الذي يجب ألا تفعله في حال حدوث مشاكل مع الزبون؟',
      'faq_a2':
          'لا تحاول التعامل مع الموقف بنفسك، وبدلاً من ذلك أخبر المرسِل/المشرف المناوب. سنحاول التحدث إلى الزبون نيابةً عنك وتجنب أي عواقب سيئة من أمازون بسبب شكاوى الزبائن. نحن هنا من أجلك!',

      'faq_q3':
          'ماذا لو كان الموقف قد تصاعد بالفعل والزبون غير سعيد لأي سبب حدث؟',
      'faq_a3':
          'ليس هناك وقت متأخر لإصلاح أي أخطاء. اتصل بنا رغم ذلك وسنحاول إصلاح الخطأ مع الزبون. متأخرًا خير من ألا يأتي أبدًا.',

      'faq_q4':
          'ما الأهم، الكمية (سرعة توصيل أكبر عدد ممكن من التوقفات) أم الجودة؟',
      'faq_a4':
          'الجودة! دائمًا الجودة! اتبع تعليمات الزبون ولا تترك الطرد في أماكن غير آمنة فقط لأنك متأخر في التوقفات.',

      'faq_q5': 'ماذا لو ركّزت على الجودة لكنني تأخرت في التوقفات؟',
      'faq_a5':
          'ستُنهي توقفاتك، بطريقة أو بأخرى. سنحاول إرسال مساعدة ولكن فقط إذا رأينا أن ذلك معقول.',

      'faq_q6': 'ما هو الـ scorecard وما هو DNR؟',
      'faq_a6': 'سعيدون أنك سألت.',

      'faq_q7': 'الـ Scorecard الأسبوعي',
      'faq_a7':
          'يعطينا الـ scorecard الأسبوعي نظرة سريعة وواضحة على أداء الفريق تجاه أهدافنا الرئيسية. يساعدنا على تحديد ما يسير جيدًا، وأين نتأخر، وعلى ماذا يجب أن نركز للأسبوع القادم. النتائج الإجمالية كما يلي:\n'
          '• Fantastic Plus: >93% (أداء استثنائي)\n'
          '• Fantastic: 85% – 92.9%\n'
          '• Great: 70% – 84.9%\n'
          '• Fair: 50% – 69.9%\n'
          '• Poor: <50%',

      'faq_q7_1': 'تبويب DNR\nDelivered Not Received',
      'faq_a7_1':
          'يحدث ذلك عندما تكون قد سلّمت طردًا، وضغطت زر "Swipe to finish" لتأكيد أنك سلّمت الطرد، لكن الزبون لم يستلم الطرد لعدة أسباب: سرقة الطرد، أن يكون الصندوق فارغًا من محتويات الطرد، أو التسليم الخاطئ إلى عنوان خاطئ.\n'
          'كل يوم ثلاثاء ستستلم صورًا لكل حالة DNR حصلت عليها خلال الأسبوع.',

      'faq_q7_1_1': 'كيف أتجنب ذلك وما مدى أهميته في الـ scorecard الأسبوعي؟',
      'faq_a7_1_1':
          'هذا مهم جدًا ولتجنبه عليك ببساطة إبلاغ الزبون مسبقًا بأنك ستصل قريبًا إلى منزلهم/عملهم وأن ترن الجرس فقط الذي يحمل لوحة اسمهم.',

      'faq_q7_1_2': 'كيف أتجنب فقدان الطرود؟',
      'faq_a7_1_2':
          'حاول دائمًا تسليم الطرود يدًا بيد إلى الزبون، وإذا لم يكن ذلك ممكنًا، أرسل رسالة تُبلغه أين تم ترك الطرد، على سبيل المثال في المرآب، تحت الدرج، في السقيفة، خلف مزهرية الزهور، إلخ..\n'
          'إذا كنت لا تعتقد أن ترك الطرد دون مراقبة آمن، فالخيار الأفضل دائمًا هو أخذ الطرد ومحاولة التسليم مرة أخرى لاحقًا. هذا مهم جدًا.',

      'faq_q7_1_3': 'كيف أعرف إن كان المكان آمنًا أم لا؟',
      'faq_a7_1_3':
          'الحدس وأيضًا المنطق السليم. إذا كان المبنى يتكون من 20 - 30 طابقًا وتركت الطرد بجانب صناديق البريد، فاحتمالات سرقته تكون أعلى وأعلى مقارنةً ببيت خاص.\n'
          'كذلك، لمساعدتك في تسليماتك اليومية وتجنب التعرض لـ DNR، سننشر كل صباح صورة بعناوين لديها احتمالية عالية لسرقة الطرود وشكاوى الزبائن، بناءً على نتائج التسليم السابقة والإحصائيات.',

      'faq_q7_1_4': 'ماذا لو فُقد طرد أو سُرق، كيف سيؤثر ذلك على نتيجتي؟',
      'faq_a7_1_4':
          'بشكل سيئ. سيؤثر عليك بنسبة لا تقل عن 30% وذلك مع طرد واحد فقط قد يخصم منك ما لا يقل عن 600 نقطة. كلما زادت النقاط التي تراها في الـ scorecard تحت اسمك، كان الوضع أسوأ. كلما زاد عدد الطرود التي تسلمها في أسبوع العمل، قلّت النقاط التي تخسرها. وتختلف النقاط التي تخسرها أيضًا حسب سعر العنصر المفقود؛ كلما كان أغلى، خُسرت نقاط أكثر. يجب أن نبقي قسم النتيجة هذا منخفضًا قدر الإمكان.\n'
          'ولا ينبغي تجاهل حقيقة أنه إذا كان لديك بانتظام عدد كبير من الطرود المفقودة، فسيتعين علينا الاستغناء عنك لأن أمازون قد تشتبه عاجلاً أم آجلاً بسرقة الطرود، ولذلك فهذا أمر خطير جدًا.',

      'faq_q7_2':
          'تبويب CC\n'
          'Contact Compliance',
      'faq_a7_2':
          'يعني عدد المرات التي تواصلت فيها مع الزبون بشأن تسليمه، سواء عبر رسالة أو مكالمة هاتفية. كلما قل تفاعلك مع الزبون، قلّت النقاط التي ستحصل عليها في الـ scorecard، ويجب أن نبقي هذا القسم مرتفعًا قدر الإمكان لأنه في الواقع من أسهل الفئات ويساعد كثيرًا في نتيجتك الإجمالية.',

      'faq_q7_2_1': 'لماذا يجب أن أفعل هذا؟',
      'faq_a7_2_1':
          'تسليم الطرود ليس مجرد Drop&Go، يجب عليك أيضًا إبلاغ الزبون مسبقًا وسؤاله أين يود أن يتم تسليم الطرد.',

      'faq_q7_2_2': 'كيف أحسن درجات CC الخاصة بي؟',
      'faq_a7_2_2':
          'شكرًا لسؤالك. بسيط: بالاتصال وخاصة بإرسال الرسائل للزبائن في كل توقف.',

      'faq_q7_3': 'تبويب CE\nCostumer Escalation',
      'faq_a7_3':
          'هل تتذكر مدى سوء تأثير DNR على درجاتك؟ حسنًا، هذا أسوأ على الأقل بمرتين، كما أنك تخاطر بفقدان وظيفتك لأنه يعتمد على مدى سوء الوضع.',

      'faq_q7_3_1': 'كيف أتجنب ذلك؟',
      'faq_a7_3_1':
          'باتباع تعليمات تسليم الزبون دائمًا، وفي حال حدوث خطأ، اعتذر أولاً، وإذا كان الزبون غاضبًا فاطلب منه دقيقة من وقته للتحدث معنا بينما أنت تتصل بنا بالفعل. بقراءة القسم 2، يجب أن تعرف الآن أنه من الأفضل تركنا نتعامل مع مثل هذه القضايا.',

      'faq_q7_4': 'تبويب POD\nPicture on Delivery',
      'faq_a7_4':
          'يعرض هذا العمود قائمة الطرود المؤهلة لـ POD والتي تم التقاط صور لها لكنها كانت إما Invalid أو Not Sure. أسباب رفض POD قد تشمل:\n'
          '1- ظهور ملصق الطرد في الصورة مع تفاصيل الزبون. يجب قلب الطرد قبل التقاط الصورة.\n'
          '2- صورة غير واضحة\n'
          '3- ظهور شخص في الصورة\n'
          '4- لا يظهر طرد في الصورة\n'
          '5- الطرد داخل السيارة\n'
          '6- الطرد في اليد\n'
          '7- الطرد في صندوق البريد\n'
          '8- الطرد قريب جدًا\n'
          '9- الصورة مظلمة جدًا.\n'
          'يجب أن يكون هذا دائمًا الأسهل حيث ينبغي أن تحصل على نتيجة 100% وهو يحسن نتيجتك الإجمالية',

      'faq_q7_5': 'تبويب LoR\nLost on Road',
      'faq_a7_5':
          'يعاقبك عندما تكون قد مسحت/سكنت طردًا من التحميل ولم تقم بإرجاعه في نهاية الوردية في حال فشل التسليم. وبالتالي يكون الطرد قد فُقد وستفقد نقاطًا بقدر ما ستفقده في DNR، لذا يرجى عدّ الطرود التي تعيدها جيدًا والتأكد من أنها تطابق الطرود المعروضة في الجهاز. يمكنك العثور عليها في: Todays Itinerary - Summary - Problems. إذا لم تتطابق، يرجى إبلاغ المرسِل/المشرف المناوب قبل إنهاء العمل في تطبيق أمازون.',

      'faq_q7_6': 'تبويب DCR\nDelivery Completion Rate',
      'faq_a7_6':
          'يعرض قدراتك على تسليم الطرود. يتتبع نسبة التسليمات التي تمت كما هو مخطط، مما يساعدنا على قياس كفاءة وموثوقية تسليماتنا. يبرز مشكلات مثل التأخيرات، المحاولات الفاشلة، أو مشاكل التوجيه. يجب أن يكون هذا مرتفعًا قدر الإمكان. ولتحقيق ذلك يجب أن تقوم يوميًا بمحاولات إعادة التسليم (reattempts) وتجنب قدر الإمكان إعادة الطرود.',

      'faq_q7_7': 'تبويب CDF (Previously, DEX)\nCostumer Delivery Feedback',
      'faq_a7_7':
          'يلتقط تجربة المستلم مع عملية التسليم، بما في ذلك الالتزام بالمواعيد، حالة البضائع، واحترافية السائق. يساعدنا على تحديد نقاط القوة ومجالات التحسين. في نهاية التسليم، يحصل الزبون على بريد إلكتروني من أمازون حول تجربة التسليم، مع أسئلة مثل:\n'
          '1) هل تم تسليم طردك في الوقت المحدد؟\n'
          'نعم / لا\n'
          '2) هل تم ترك الطرد في مكان آمن؟\n'
          'نعم / لا\n'
          '3) هل كان الطرد في حالة جيدة عند وصوله؟\n'
          'نعم / لا\n'
          '4) ما مدى رضاك عن التسليم بشكل عام؟\n'
          'راضٍ جدًا / راضٍ / محايد / غير راضٍ / غير راضٍ جدًا\n'
          '5) كيف تقيّم التواصل وتحديثات التتبع لهذه التسليم؟\n'
          'ممتاز / جيد / مقبول / سيئ\n'
          '6) هل كان موظف التسليم مهذبًا ومحترفًا؟\n'
          'نعم / لا / غير قابل للتطبيق (تسليم بدون تواصل)\n'
          '7) هل لديك أي تعليقات حول تجربة التسليم الخاصة بك؟\n'
          '(تعليقات إضافية من الزبون)',

      'faq_q7_8': 'ماذا يجب أن أضع في ذهني بشأن الـ scorecard؟',
      'faq_a7_8':
          'الجودة والكفاءة تقطع شوطًا طويلاً. الدرجات الجيدة جيدة لك، وللشركة، وجيدة للفريق بأكمله. رضا الزبون مهم جدًا والدرجات الجيدة تكون مصحوبة بمكافأة من الشركة.\n'
          'ابذل أفضل ما لديك، تحصل على الأفضل.',

      'faq_q8': 'ما المجالات الأخرى التي يجب أن أكون حذرًا بشأنها؟',
      'faq_a8':
          'الاعتناء بنفسك بالقيادة بأمان، وتجنب الإصابات وتجنب الكلاب وعضّات الكلاب. الحذر مع معدات العمل مثل السيارة اليومية، جهاز المسح/الهاتف الخاص بالعمل والحضور إلى العمل مرتديًا حذاء السلامة وسترة السلامة، وسترة أو قميص بعلامة أمازون (حسب الطقس).',

      'faq_q9': 'ماذا يحدث إذا تعرضت لحادث سيارة أو أتلفت مركبة العمل؟',
      'faq_a9':
          'أولاً، تأكد أنك بخير وأنك لست مصابًا بجروح خطيرة. أما بخصوص ضرر السيارة، فإذا قررنا أن الحوادث تحدث بسبب الإهمال – على سبيل المثال، تشتت الانتباه مثل استخدام الهاتف المحمول أثناء القيادة – فستكون مسؤولاً شخصيًا عن كامل الضرر. بالإضافة إلى ذلك، ستحصل على تقرير من الشرطة، والذي قد يؤدي حتى إلى تعليق الرخصة. وبالطبع، هذا أيضًا سبب للفصل الفوري. وإلا فسيتم فقط استبعادك من الحصول على مكافآت الـ Weekly Scorecard لمدة شهرين. في حالة حدوث حادث، أنت مُلزم بإبلاغنا فورًا وتزويدنا بوقت الحادث، والموقع، وما إذا كان هناك أضرار لممتلكات خاصة أو عامة (مثل الجدران، الأسوار، أعمدة الإنارة، الأشخاص و/أو الحيوانات الأليفة)، والموقع وصور أضرار السيارة.',

      'faq_q10': 'ماذا أفعل عندما تكون لدي طرود تالفة و/أو مفقودة.',
      'faq_a10':
          'عندما يكون الطرد تالفًا، لا تتردد في تسجيله كتالف وإعادته إلى المحطة. إذا كان الطرد التالف يحتوي على سوائل وأتلف طرودًا أخرى معه، يرجى التقاط صورة لجميع الطرود التالفة وإرسالها إلى المرسِل/المشرف المناوب وسنقوم بالإبلاغ إلى أمازون نيابةً عنك.\n'
          'عندما يكون الطرد مفقودًا، لا تتردد في وضع علامة/تسجيل أنه مفقود إلا إذا كان يحتوي على OTP، وفي هذه الحالة يجب عليك إبلاغنا أولاً قبل وضع علامة أنه مفقود. هذا مهم جدًا.',

      'faq_q11': 'ما هو طرد OTP (One-Time Password)؟',
      'faq_a11':
          'هو عنصر باهظ الثمن تطلب أمازون من الزبون أن يزوّد السائق بكلمة مرور لمرة واحدة قبل تسليم الطرد، لضمان أن الطرد سُلّم للشخص/الزبون الصحيح. يجب أن تعتني بهذه الطرود بعناية كبيرة، وألا تتركها دون مراقبة وأن تسلمها فقط للزبون الذي قدّم لك كلمة المرور.',

      'faq_q12': 'لماذا نستمر في إزعاجك لتبطئ ولا تذهب أسرع؟',
      'faq_a12':
          'نحن أيضًا لا نحب ذلك، لكن هذا هو النظام. نحتاج إلى اتباع خوارزمية النظام والقيام بعدد من التوقفات في الساعة كما هو محدد مسبقًا حتى نحصل على المزيد من المسارات في المستقبل وتعمل أكثر ولا تكون متفرغًا.\n'
          'كما أن الذهاب أسرع يعرضك لخطر DNR وخسارة نقاط لكلا الطرفين، لنفسك وللشركة، في الـ scorecard الأسبوعي.',

      'faq_q13':
          'إذًا لماذا يسألني المرسِلون/المشرفون أحيانًا لماذا أنت متأخر وهل هناك شيء خاطئ؟',
      'faq_a13':
          'نعلم أن هذا غير مريح، لكننا نحتاج بعض الملاحظات حول ما الذي قد يكون حدث على الطريق وأدى إلى تأخرك في التوقفات. أمازون يطلب منا هذه الملاحظات لأن هناك أيضًا حدًا زمنيًا كان يجب أن تكون قد سلّمت خلاله X توقف، لذلك تحتاج أمازون إلى معرفة لماذا التوقفات المتبقية متأخرة عن جدول التسليم وبهذه المعلومات تحسن كفاءة التسليم في المستقبل.',

      'faq_q14': 'لماذا نطلب منك أحيانًا أن تذهب لمساعدة زميل؟',
      'faq_a14':
          'لأن هناك عوامل كثيرة تؤثر في تأخر الزميل مثل ضعف اتصال الإنترنت في المنطقة، الازدحام، إغلاق الطرق بسبب أعمال البناء في المنطقة مما جعل من الصعب على السائق الآخر التسليم في الوقت المحدد، لذلك نحتاج مساعدتك.',

      'faq_q15':
          'هل أبدأ فورًا في يومي الأول بتسليم طرود المسار القياسي مثل غيري من السائقين الأكثر خبرة؟',
      'faq_a15':
          'لا، من الواضح أن هذا ليس الحال بالنسبة لك. في البداية سيكون لديك فترة 14 يوم عمل لتطبيق ما تعلمته في أيام الركوب مع المدرب والتأقلم مع المنطقة، السيارة، الجهاز وتعلم سير العمل.\n'
          'وبناءً على ذلك، خلال تلك الفترة البالغة 14 يومًا، ستمنحك أمازون ما يصل إلى 50% أقل من الطرود والتوقفات المعتادة في جدولك.',

      'faq_q16':
          'ماذا أفعل عندما يكون العنوان خاطئًا و/أو دبوس الموقع غير صحيح على الخريطة؟',
      'faq_a16':
          'أولاً أكد أن الدبوس غير صحيح من خلال البحث عن العنوان في خرائط Google (أدق وهو مثبت بالفعل على جهازك) وإذا لم يتطابق، أخبر المرسِل/المشرف المناوب بالأخطاء.',

      'faq_q17': 'ما هي مهامي اليومية قبل أن أبدأ وبعد أن أنهي العمل؟',
      'faq_a17':
          '1- عندما تدخل إلى الموقف، تأكد أولاً أنك ترتدي حذاء السلامة وسترة السلامة وبدلة أمازون.\n'
          '2- تحقق أن جهازك مشحون بالكامل وأبلغ المرسِل/المشرف الموجود في تلك اللحظة إذا لم يكن مشحونًا.\n'
          '3- تحقق إذا كان هناك أي شيء خاطئ في السيارة.\n'
          '4- ابدأ الرحلة على تطبيق Mentor على جهازك.\n'
          '5- انشر صورة للوحة عدادات السيارة تُظهر عداد الكيلومترات الحالي والرحلة اليومية (في السيارة) مع إعادة ضبطها إلى 0.\n'
          '6- استعد للنزول إلى منطقة الانتظار قبل 10 دقائق فقط من وقت التحميل المخطط، وليس أبكر.\n'
          '7- عندما تكون في منطقة الانتظار، أطفئ السيارة، ابدأ تطبيق Flex والـ Timesheet. من فضلك لا قبل ذلك بدقيقة، وخاصة تطبيق Flex. لا تنسَ طابع الـ 10 دقائق.\n'
          '8- أخيرًا اذهب إلى منطقة التحميل وفقًا لتعليمات Yard Marshall. عندما تكون في منطقة التحميل، أطفئ السيارة ولا تغادر السيارة إلا بعد أن تسمع صفارة Yard Marshall.\n'
          '9- بعد أن تنتهي من تحميل سيارتك، شغّل السيارة وابدأ القيادة ولكن فقط عندما يأمرك Yard Marshall بذلك.\n'
          '10- بعد أن تنتهي من جميع توقفاتك، تحقق من خزان الوقود وإذا كان أقل من النصف المتبقي، يرجى تعبئته.\n'
          '11- عندما تكون في المحطة، يرجى إسقاط جميع الطرود المتبقية في المناطق المخصصة من أمازون، وإسقاط الأكياس في الوقت المناسب\n'
          '12- عندما تكون في الموقف، أوقف السيارة وأكمل Green Book (Tageskontrollblat)، وانشر صورة للمسافة اليومية التي قطعتها خلال اليوم في التسليم، مع صورة لـ Green Book.\n'
          '13- أطفئ السيارة ويرجى إعادة حقيبة العمل إلى المنطقة/الفان المخصصة',

      'faq_q18':
          'هل يجب أن أفعل أي شيء عندما أغير الفان وأخذ فانًا آخر بدلًا من الذي أستخدمه عادةً؟',
      'faq_a18':
          'يجب أن تصوّر فيديو له، يلتقط بالتفصيل كل ضرر صغير ربما أحدثه السائق/السائقون السابقون، حتى لا يكون الخطأ عليك في الفحص التالي للسيارة.',

      'faq_q19':
          'ماذا يجب أن أفعل إذا كان تطبيق Flex يقوم بالتحميل باستمرار ويبطئ سير عملي؟',
      'faq_a19':
          'تحقق أولاً مما إذا كان لديك اتصال إنترنت نشط. للقيام بذلك يمكنك محاولة إرسال رسالة إلى زبون التوقف الحالي وإذا تمت بنجاح فهذا يعني أن اتصال الإنترنت نشط. يمكنك أيضًا التحقق بفتح تطبيق آخر على الجهاز مثل المتصفح والبحث عن شيء.\n'
          'الخطوات التي يجب اتباعها إذا لم يكن هناك اتصال إنترنت نشط:\n'
          '1- أعد تشغيل جهازك. يجب أن يكون هذا دائمًا أول شيء تجرّبه.\n'
          '2- شغّل/أوقف وضع الطيران. هذا يعمل معظم الوقت دون الحاجة لانتظار إعادة التشغيل.\n'
          '3- كحل أخير جدًا، حاول مشاركة نقطة اتصال من هاتفك الشخصي لمدة 10 دقائق كحد أقصى فقط لكي يقوم النظام بتحديث نفسه.\n'
          'يمكنك أيضًا العمل دون اتصال لكن في مرحلة ما يجب أن تتصل بالإنترنت وتكون نشطًا. للعمل دون اتصال يجب أولاً تنزيل الخرائط غير المتصلة في تطبيق Flex. للقيام بذلك، اذهب إلى Settings - Offline Maps (الخيار الأخير) - Download DBY5 - Allow downloads with mobile connection.\n',

      'faq_q20':
          'ماذا لو كان اتصال الإنترنت نشطًا لكن تطبيق Flex ما زال لا يعمل كما ينبغي؟',
      'faq_a20':
          '1- أعد تشغيل الجهاز.\n'
          '2- شغّل/أوقف وضع الطيران\n'
          '3- اخرج من التطبيق\n'
          '4- أوقف/شغّل خدمات الموقع (GPS)\n'
          '5- سجّل الخروج من تطبيق Flex ثم سجّل الدخول مرة أخرى باستخدام بيانات الاعتماد التي تستخدمها لتطبيق Mentor.\n'
          '6- تحقق مما إذا كان التطبيق يحتاج إلى تحديث.\n'
          'يجب أن تجرب هذه الخطوات واحدة تلو الأخرى. إذا لم تعمل واحدة، يرجى تجربة التالية بعدها.',
    },

    // =========================
    // TURKISH
    // =========================
    'tr': {
      'back': 'Geri',
      'continue': 'Devam',
      'button_save': 'Kaydet',
      'required': 'zorunlu',
      'error_required': '{field} zorunludur',
      'error_required_short': 'Bu alan zorunludur',
      'uploading': 'Yukleniyor...',
      'upload': 'Yukle',
      'replace': 'Degistir',
      'error_must_be_logged_in_driver':
          'Sofor olarak giris yapmis olmalisiniz.',
      'coming_soon': 'Yakin zamanda',
      'header_good_morning': 'GUNAYDIN',
      'header_good_afternoon': 'IYI GUNLER',
      'header_good_evening': 'IYI AKSAMLAR',
      'select_language': 'Dil secin',
      'notifications': 'Bildirimler',
      'no_notifications': 'Bildirim yok',
      'nav_scorecard': 'Skor Karti',
      'nav_help': 'Yardim',
      'nav_rules': 'Kurallar',
      'nav_profile': 'Profil',
      'nav_tasks': 'Gorevler',
      'driver_home_dispatcher': 'Dispatcher',
      'driver_home_shift_plan_title': 'Vardiya Plani',
      'driver_home_shift_plan_subtitle': 'Vardiyalarin',
      'driver_home_scorecard_subtitle': 'Performansina genel bakis',
      'driver_home_tasks_title': 'Gorevler',
      'driver_home_tasks_subtitle': 'Acik gorevleri yonet',
      'driver_home_academy_subtitle': 'Egitim ve bilgi',
      'driver_home_rules_title': 'Sirket Kurallari',
      'driver_home_rules_subtitle': 'Yonergeler ve politikalar',
      'driver_notification_published_on': 'Yayinlandi {date}',
      'driver_home_vehicles_title': 'Araclar',
      'driver_home_vehicles_subtitle': 'Arac genel bakisi',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'AI asistanin',
      'driver_home_absence_title': 'Izin',
      'driver_home_absence_subtitle': 'Tatil ve rapor izni',
      'driver_home_incident_title': 'Olay Raporu',
      'driver_home_incident_subtitle': 'Bir kazayi bildir',
      'driver_home_new_badge': 'YENI',
      'driver_academy_title': 'DA Academy',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle': 'Gunluk kontrol formu kilavuzu',
      'driver_academy_safety_title': 'Guvenlik Egitimi',
      'driver_academy_safety_subtitle': 'Guvenlik egitimleri',
      'driver_academy_delivery_title': 'Amazon Teslimat',
      'driver_academy_delivery_subtitle': 'Teslimat surecleri ve is akislari',
      'driver_academy_app_title': 'CoDriver Uygulamasi',
      'driver_academy_app_subtitle': 'Uygulama ozellikleri ve kilavuzlar',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - Egitim videosu',
      'driver_green_book_video_subtitle': 'Oynatmak icin dokun',
      'driver_green_book_start_test': 'Green Book testini baslat',
      'driver_green_book_test_required': 'Test zorunlu',
      'driver_green_book_section1_title': 'Green Book gunluk kontrol formu',
      'driver_green_book_section1_text':
          'Gunluk kontrol formu (Green Book), her vardiyadan once doldurulmasi gereken zorunlu bir belgedir. Arac durumunu kontrol etmeye ve guvenlikle ilgili noktalarin kaydina yardim eder.',
      'driver_green_book_section1_b1': 'Her vardiyadan once eksiksiz doldurun.',
      'driver_green_book_section1_b2': 'Arac arizalarini hemen bildirin.',
      'driver_green_book_section1_b3': 'Imzayi unutmayin.',
      'driver_green_book_section2_title': 'Uyumsuzlugun sonuclari',
      'driver_green_book_section2_text': 'Ihlaller artan adimlarla ele alinir:',
      'driver_green_book_section2_b1':
          'Ilk uyari: dispatcher tarafindan sozlu uyari.',
      'driver_green_book_section2_b2': 'Ikinci uyari: yazili uyari.',
      'driver_green_book_section2_b3': 'Tekrarlanan ihlal: disiplin islemleri.',
      'driver_green_book_section3_title': 'Yasal cezalar',
      'driver_green_book_section3_text':
          'Kontrolde Green Book eksik veya eksik doldurulmussa:',
      'driver_green_book_section3_b1':
          'Surucu icin 5000 EUR\'ya kadar para cezasi.',
      'driver_green_book_section3_b2':
          'Sirket icin 30000 EUR\'ya kadar para cezasi.',
      'driver_green_book_section3_b3': 'Flensburg puanlari kaydedilebilir.',
      'driver_green_book_section3_b4': 'Sigortayi olumsuz etkileyebilir.',
      'driver_green_book_test_title': 'Green Book testi',
      'driver_green_book_test_progress': '{total} sorudan {current}. soru',
      'driver_green_book_test_next': 'Ileri',
      'driver_green_book_test_submit': 'Testi gonder',
      'driver_green_book_test_result_pass_title': 'Test gecildi',
      'driver_green_book_test_result_fail_title': 'Test gecilemedi',
      'driver_green_book_test_result_pass_body':
          'Tebrikler! Testi {score}/{total} ile gectiniz.',
      'driver_green_book_test_result_fail_body':
          '{score}/{total} aldiniz. Lutfen tekrar deneyin.',
      'driver_green_book_test_retry': 'Tekrar dene',
      'driver_green_book_test_close': 'Kapat',
      'driver_green_book_test_back_to_green_book': 'Green Book\'a don',
      'driver_green_book_test_no_questions':
          'Henuz test sorulari tanimlanmadi. Lutfen dispatcher ile iletisime gecin.',
      'driver_green_book_test_offline_fallback':
          'Canli test senkronizasyonu basarisiz oldu. Fallback sorularla devam edip yeniden deneyebilirsiniz.',
      'admin_home_notification': 'Bildirim',
      'admin_home_driver_fallback': 'Surucu',
      'admin_home_not_confirmed_by': 'ONAYLAMAYANLAR:',
      'admin_home_missing_loading': 'eksik: ...',
      'admin_home_missing_unknown': 'eksik: --',
      'admin_home_missing_count': 'eksik: {count}',
      'admin_home_error_generic': 'Hata: {error}',
      'admin_home_all_drivers_confirmed': 'Tum suruculer onayladi.',
      'admin_home_close': 'Kapat',
      'admin_home_last_week': 'Gecen Hafta',
      'admin_home_not_logged_in': 'Giris yapilmadi.',
      'admin_home_loading_reports': 'Raporlar yukleniyor...',
      'admin_home_no_reports_uploaded': 'Henuz rapor yuklenmedi.',
      'admin_home_week_short': 'HF',
      'admin_home_month_prefix': 'AY',
      'admin_home_year_prefix': 'YIL',
      'admin_home_loading_scores': 'Skorlar yukleniyor...',
      'admin_home_name_fallback': 'Ad Soyad',
      'admin_home_scorecard': 'Skor Karti',
      'admin_home_company_score': 'SIRKET SKORU',
      'admin_home_of': '/',
      'admin_home_best_driver': 'En Iyi Surucu',
      'admin_home_worst_defender': 'En Zayif Defender',
      'admin_home_notification_history': 'Bildirim Gecmisi',
      'admin_home_no_notifications_yet': 'Henuz bildirim yok.',
      'admin_home_notification_type_message': 'YENI MESAJ',
      'admin_home_notification_type_academy': 'DA ACADEMY',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'YENI KURAL',
      'admin_home_edit_rule': 'Kurali duzenle',
      'admin_home_title': 'Baslik',
      'admin_home_body': 'Icerik',
      'admin_home_cancel': 'Iptal',
      'admin_home_save': 'Kaydet',
      'admin_home_title_or_body_required': 'Baslik veya icerik gerekli.',
      'admin_home_notification_not_found': 'Bildirim bulunamadi.',
      'admin_home_rule_updated_for_drivers':
          '{count} surucu icin kural guncellendi.',
      'admin_home_edit_failed': 'Duzenleme basarisiz: {error}',
      'admin_home_delete_notification_question': 'Bildirim silinsin mi?',
      'admin_home_delete_notification_body':
          'Bu bildirim sizden ve tum suruculerden silinecek.',
      'admin_home_delete': 'Sil',
      'admin_home_notification_deleted': 'Bildirim silindi.',
      'admin_home_delete_failed': 'Silme basarisiz: {error}',
      'admin_home_options': 'Secenekler',
      'admin_home_title_upper': 'BASLIK',
      'admin_home_confirmed_by': 'onaylayan',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Servis',
      'admin_home_accidents': 'Kaza',
      'admin_home_total': 'toplam',
      'admin_home_active': 'aktif',
      'admin_home_inactive': 'pasif',
      'admin_home_doc_id_card': 'Kimlik Karti',
      'admin_home_doc_driving_license': 'Surucu Belgesi',
      'admin_home_doc_residence_permit': 'Oturum Izni',
      'admin_home_loading_drivers': 'Suruculer yukleniyor...',
      'admin_home_no_drivers_yet': 'Henuz surucu yok.',
      'admin_home_contract': 'Sozlesme',
      'admin_home_last_day': 'son gun',
      'admin_home_probation': 'Deneme suresi',
      'admin_home_ended': 'bitti',
      'admin_home_ends': 'bitiyor',
      'admin_home_expired_by': 'su tarihte bitti',
      'admin_home_loading_documents': 'Belgeler yukleniyor...',
      'admin_home_driver_documents': 'Surucu Belgeleri',
      'admin_home_expired_documents': 'Suresi dolan belgeler',
      'admin_home_expired_soon': 'yakinda bitiyor',
      'admin_home_missing_documents_data': 'Eksik Belgeler / Veriler',
      'admin_home_total_missing': 'toplam eksik',
      'admin_home_driver_contracts': 'Surucu Sozlesmeleri',
      'admin_home_last_day_soon': 'son gun yakinda',
      'admin_home_no_items': 'Oge yok',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'Profil fotografini degistir',
      'profile_change_photo': 'Profil fotografini degistir',
      'logout': 'Cikis yap',
      'profile_logout': 'Cikis yap',
      'pin_change_with_old':
          'Eski PIN dogrulamasindan sonra PIN degistirebilirsiniz.',
      'pin_forgot_contact_admin':
          'PIN\'inizi mi unuttunuz? Lutfen yoneticinizle iletisime gecin.',
      'profile_photo_updated': 'Profil fotografi guncellendi.',
      'failed_upload_profile_photo': 'Profil fotografi yuklenemedi: {error}',
      'could_not_read_image_bytes':
          'Dosya seciciden goruntu verileri okunamadi.',
      'hi_name': 'Merhaba {name}, 👋',
      'welcome_to_company': '{company}\'e hos geldiniz',
      'welcome_desc': 'Aramiza katildiginiz icin mutluyuz. Haydi baslayalim!',
      'codriver': 'CODRIVER',
      'your_address': 'ADRESINIZ',
      'your_origin': 'KOKENINIZ',
      'uniform': 'UNIFORMA',
      'hint_street_house': 'Sokak, Kapi Numarasi',
      'hint_postal_code': 'Posta Kodu',
      'hint_city': 'Sehir',
      'hint_country': 'Ulke',
      'hint_birthday': 'Dogum tarihiniz',
      'hint_birth_city': 'Dogum sehri',
      'hint_birth_state': 'Dogum eyaleti',
      'hint_nationality': 'Uyruk (Kimlik Karti) (Ulke adi)',
      'label_cloth_size': 'Kiyafet bedeninizi secin',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'Ayakkabi bedeninizi secin',
      'hint_shoe_size': 'orn. 42',
      'label_notes': 'Diger istekler / notlar',
      'work_permit': 'CALISMA IZNI',
      'work_permit_question':
          'Almanya\'da calismak icin hangi tur calisma izniniz var?',
      'permit_german_id': 'Alman Kimlik Karti',
      'permit_eu_id': 'AB Kimlik Karti',
      'permit_work_visa': 'Almanya icin CALISMA VIZESI',
      'your_work_permit': 'CALISMA IZNINIZ',
      'please_upload_doc': 'Lutfen belgenizi yukleyin',
      'upload_quality_hint':
          'Fotografin tamamen gorunur, yuksek kalitede ve ustten cekilmis oldugundan emin olun',
      'upload_your_file': 'Dosyanizi yukleyin',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF en fazla 50 MB',
      'hint_select_expiry': 'Son kullanma tarihini secin',
      'id_passport_title': 'Kimlik Karti, Pasaport',
      'id_card': 'KIMLIK KARTI',
      'passport': 'PASAPORT',
      'or': 'VEYA',
      'your_passport': 'PASAPORTUNUZ',
      'your_id_card': 'KIMLIK KARTINIZ',
      'frontside': 'ON YUZ',
      'backside': 'ARKA YUZ',
      'your_drivers_license': 'SURUCU BELGENIZ',
      'upload_file_front': 'Dosyanizi yukleyin (on yuz)',
      'upload_file_back': 'Dosyanizi yukleyin (arka yuz)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (PDF degil)',
      'tax_document': 'VERGI BELGESI',
      'please_upload_tax_id': 'Lutfen vergi kimlik belgenizi yukleyin',
      'upload_tax_id': 'Vergi kimligini yukle',
      'file_formats_tax': 'PDF, JPG, PNG... en fazla 50 MB',
      'label_iban': 'IBAN',
      'label_license_expiry': 'Ehliyet son kullanma tarihi',
      'hint_license_expiry': 'Son kullanma tarihini secin',
      'label_uploaded_docs': 'Yuklenen belgeler',
      'no_docs': 'Henuz belge yuklenmedi.',
      'doc_resident_permit': 'Calisma/oturum izni',
      'doc_tax_id': 'Vergi kimlik belgesi',
      'doc_insurance': 'Sigorta',
      'doc_other_doc': 'Diger belge',
      'driver_license_front': 'Ehliyet (on yuz)',
      'driver_license_back': 'Ehliyet (arka yuz)',
      'id_card_front': 'Kimlik karti (on yuz)',
      'id_card_back': 'Kimlik karti (arka yuz)',
      'passport_front': 'Pasaport (on yuz)',
      'passport_back': 'Pasaport (arka yuz)',
      'dash_error_loading_reports': 'Raporlar yuklenirken hata: {error}',
      'dash_no_reports_uploaded': 'DSP\'niz henuz scorecard raporu yuklemedi.',
      'dash_scorecard_week': 'SCORECARD HAFTA {week}',
      'dash_week_range': 'Hafta {week}, {year}',
      'dash_no_scores_period': 'Bu donem icin henuz skor yok.',
      'dash_no_drivers_match': 'Bu filtreyle eslesen surucu yok.',
      'dash_no_name': '(Isim yok)',
      'dash_company_score': 'Sirket Skoru',
      'dash_my_score': 'Skorum',
      'dash_select_period': 'Donem secin',
      'dash_weekly_view': 'Haftalik gorunum',
      'dash_best_da_month': 'Ayin en iyi DA\'si',
      'dash_best_da_year': 'Yilin en iyi DA\'si',
      'dash_week': 'Hafta',
      'dash_total_score': 'Toplam Skor',
      'dash_rank_in_station': 'Istasyondaki siralama',
      'dash_status': 'Durum',
      'dash_company_data_section': 'Sirket verisi olarak',
      'dash_company_data_show': 'Sonuclari sirket olarak goster',
      'dash_company_data_hide': 'Sirket kategorilerini gizle',
      'dash_rank': 'Siralama',
      'dash_score': 'Skor',
      'dash_name': 'Ad',
      'dash_delivered': 'Teslim edildi',
      'dash_rank_in_aion': 'AION siralamasi',
      'dash_rank_of_total': '{rank} / {total}',
      'dash_no_my_score_week':
          'Bu hafta surucu kimliginiz icin skor bulunamadi.',
      'dash_all_status': 'Tum Durumlar',
      'dash_search_name_or_id': 'Isim veya Transporter ID ara...',
      'dash_upload_driver_csv': 'Surucu CSV Yukle',
      'scorecard_overview_title': 'SCORE CARD PANOSU',
      'scorecard_overview_overview_suffix': '— Genel Bakis',
      'scorecard_overview_upload_pdf': 'SCORECARD PDF YUKLE',
      'scorecard_overview_upload_prompt': 'Scorecard PDF dosyani yukle',
      'scorecard_overview_choose_file': 'Dosya sec',
      'scorecard_overview_summary_title': 'Score Card Ozeti',
      'scorecard_overview_no_reports_yet':
          'Henuz rapor yok. Baslamak icin ilk Scorecard PDF dosyani yukle.',
      'scorecard_overview_chart_title': 'Score Card Genel Bakis',
      'scorecard_overview_best_drivers': 'En Iyi Suruculer',
      'scorecard_overview_no_reports_available': 'Rapor bulunamadi.',
      'scorecard_overview_no_drivers_period':
          'Bu donem icin surucu bulunamadi.',
      'scorecard_overview_select_station': 'Istasyon sec',
      'scorecard_overview_all_stations': 'Tum Istasyonlar',
      'scorecard_overview_select_period': 'Donem sec',
      'scorecard_overview_best_drivers_year': 'Yilin en iyi suruculeri',
      'scorecard_overview_best_drivers_month': 'Ayin en iyi suruculeri',
      'scorecard_overview_station': 'Istasyon',
      'scorecard_overview_station_code': 'Istasyon {code}',
      'scorecard_overview_upload_success_one':
          '1 scorecard analiz edilip kaydedildi. Pano guncellendi.',
      'scorecard_overview_upload_success_many':
          '{count} scorecard analiz edilip kaydedildi. Pano guncellendi.',
      'scorecard_overview_upload_parse_failed':
          'Yukleme/analiz basarisiz: {error}',
      'scorecard_overview_no_file_bytes': 'Dosya verisi yok',
      'scorecard_overview_csv_updated':
          'Surucu isimleri tum raporlarinda guncellendi.',
      'scorecard_overview_csv_failed': 'CSV ice aktarma basarisiz: {error}',
      'scorecard_overview_delete_report_q': 'Rapor silinsin mi?',
      'scorecard_overview_delete_report_body':
          'Bu islem "{title}" raporunu ve bu haftaya ait tum skor kayitlarini siler.',
      'scorecard_overview_deleted': 'Rapor ve haftalik skorlar silindi.',
      'scorecard_overview_delete_failed': 'Silme basarisiz: {error}',
      'scorecard_overview_more': 'Daha Fazla',
      'scorecard_overview_delete_report_menu': 'Raporu Sil',
      'scorecard_overview_upload_processing':
          'Scorecardlar yukleniyor ve isleniyor...',
      'scorecard_overview_row_title': 'Score Card {year} HF {week}',
      'scorecard_overview_reliability_score': 'Guvenilirlik Skoru',
      'scorecard_overview_from_last_week': 'gecen haftaya gore',
      'scorecard_overview_from_last_year': 'gecen yila gore',
      'kpi_score': 'SKOR',
      'kpi_value': 'DEGER',
      'kpi_pro_tip': 'PRO IPUCU',
      'pod_quality_title': 'POD Kalitesi',
      'pod_quality_success': 'Basarili',
      'pod_quality_rejects': 'Reddedilen',
      'pod_quality_opp': 'Firsatlar',
      'pod_quality_bypass': 'Bypass',
      'pod_quality_blurry': 'Bulanik',
      'pod_quality_too_dark': 'Cok Karanlik',
      'pod_quality_no_package': 'Paket Yok',
      'pod_quality_in_car': 'Arabada',
      'pod_quality_too_close': 'Cok Yakin',
      'pod_quality_shell_week_title': 'POD KALITESI - HAFTA',
      'pod_quality_week_label': 'Hafta {week}',
      'pod_quality_dashboard_title': 'POD KALITESI PANOSU',
      'pod_quality_upload_pdf': 'PDF Yukle',
      'pod_quality_no_reports_uploaded':
          'Henuz POD kalite raporu yok. Baslamak icin bir POD PDF yukle.',
      'pod_quality_upload_success_one':
          '1 POD kalite raporu analiz edilip kaydedildi.',
      'pod_quality_upload_success_many':
          '{count} POD kalite raporu analiz edilip kaydedildi.',
      'pod_quality_upload_parse_failed': 'Yukleme/analiz basarisiz: {error}',
      'pod_quality_rejects_breakdown': 'Reddedilme dagilimi',
      'pod_quality_no_data_week': 'Bu hafta icin POD verisi yok.',
      'pod_quality_drivers': 'Suruculer',
      'pod_quality_entries_count': '{count} kayit',
      'month_jan': 'Ocak',
      'month_feb': 'Subat',
      'month_mar': 'Mart',
      'month_apr': 'Nisan',
      'month_may': 'Mayis',
      'month_jun': 'Haziran',
      'month_jul': 'Temmuz',
      'month_aug': 'Agustos',
      'month_sep': 'Eylul',
      'month_oct': 'Ekim',
      'month_nov': 'Kasim',
      'month_dec': 'Aralik',
      'month_short_jan': 'Oca',
      'month_short_feb': 'Sub',
      'month_short_mar': 'Mar',
      'month_short_apr': 'Nis',
      'month_short_may': 'May',
      'month_short_jun': 'Haz',
      'month_short_jul': 'Tem',
      'month_short_aug': 'Agu',
      'month_short_sep': 'Eyl',
      'month_short_oct': 'Eki',
      'month_short_nov': 'Kas',
      'month_short_dec': 'Ara',
      'status_fantastic': 'Mukemmel',
      'status_great': 'Harika',
      'status_fair': 'Orta',
      'status_poor': 'Zayif',
      'bucket_fantastic_plus': 'Mukemmel Plus',
      'bucket_fantastic': 'Mukemmel',
      'bucket_great': 'Harika',
      'bucket_fair': 'Orta',
      'bucket_poor': 'Zayif',
      'rank_at': 'de',
      'rank_of': '/',
      'period_month': 'Ay',
      'kw': 'KW',
      'faq_title': 'Sikca Sorulan Sorular',
      'faq_search_hint': 'Sorularda ara',
      'faq_empty': 'Eslesen SSS bulunamadi.',
      'driver_tasks_error': 'Hata: {error}',
      'driver_tasks_no_tasks': 'Henuz atanmis gorev yok.',
      'driver_tasks_update_status': 'Durumu guncelle',
      'driver_tasks_confirm_completed': 'Tamamlandi olarak onayla',
      'driver_tasks_set_completed_first':
          'Once durumu "Tamamlandi" olarak ayarlayin.',
      'driver_tasks_completion_confirmed': 'Tamamlanma onaylandi.',
      'driver_tasks_failed_update_status': 'Durum guncellenemedi: {error}',
      'driver_tasks_failed_confirm_task': 'Gorev onaylanamadi: {error}',
      'driver_tasks_status_confirmed_by_you':
          'Durum sizin tarafinizdan onaylandi.',
      'driver_tasks_confirm_when_fully_done':
          'Lutfen bu gorev tamamen bittiginde onaylayin.',
      'driver_tasks_status_pending': 'Beklemede',
      'driver_tasks_status_in_progress': 'Devam ediyor',
      'driver_tasks_status_completed': 'Tamamlandi',
      'faq_green_book_video_title': 'Green Book Egitim Videosu',
      'faq_green_book_video_subtitle':
          'Green Book doldurmayi adim adim izleyin',
      'faq_green_book_video_action': 'Videoyu ac',
      'faq_green_book_video_missing':
          'Green Book video baglantisi henuz ayarlanmadi.',
      'faq_green_book_video_open_failed':
          'Green Book video baglantisi acilamadi.',

      // Added for full key coverage (from EN fallback)
      'faq_a1': 'Paketleri kaliteli sekilde ve dogru davranisla teslim etmek.',
      'faq_a10':
          'Hasarli paketi hasarli olarak isaretleyip istasyona iade edebilirsiniz. Eger sizan sivi baska paketlere de zarar verdiyse, tum hasarli paketlerin fotograflarini cekip nobetteki dispatcher\\\'a gonderin; Amazon\\\'a biz bildiririz.\nPaket eksikse, OTP degilse eksik olarak isaretleyebilirsiniz. OTP ise, eksik isaretlemeden ONCE bize bildirmeniz ZORUNLUDUR. Bu COK ONEMLI.',
      'faq_a11':
          'Amazon\\\'un, pahali urunlerde teslimat oncesi musteriden tek kullanimlik sifre istemesidir. Amaç paketin dogru kisiye teslim edildigini dogrulamaktir. Bu paketlerde ekstra dikkatli olun; gozetsiz birakmayin ve yalnizca sifreyi veren musterinin kendisine teslim edin.',
      'faq_a12':
          'Bu bizim de hosumuza gitmiyor ama sistem boyle calisiyor. Algoritmaya uygun ilerleyip saatlik planli durak performansini korumamiz gerekiyor; boylece daha fazla rota alir, siz de daha fazla calisma gunu bulursunuz.\nAsiri hiz, DNR riskini artirir ve hem sizin hem de sirketin haftalik puanlarini dusurur.',
      'faq_a13':
          'Hos olmayabilecegini biliyoruz; ancak yolda ne oldugunu anlamak icin geri bildirim gerekli. Amazon belirli saatlerde belirli X duraga ulasilmasini bekler. Kalan duraklar neden geride, bunu bilmek ister; boylece gelecekte planlamayi iyilestirir.',
      'faq_a14':
          'Gecikmeler internet sorunu, trafik, yol calismasi gibi bircok nedenle olabilir. Diger surucunun zamaninda bitirebilmesi icin desteginize ihtiyac duyulabilir.',
      'faq_a15':
          'Hayir. Baslangicta egitmenle ride-alongda ogrendiklerinizi uygulayacaginiz ve bolge/arac/scanner akisina alisacaginiz 14 is gunluk bir donem olur.\nBu surede Amazon size normalden %50\\\'ye kadar daha az paket ve durak verir.',
      'faq_a16':
          'Once adresi Google Maps\\\'te kontrol ederek pinin yanlis oldugunu dogrulayin (genelde daha dogrudur ve scanner\\\'da kurulu gelir). Eslesmiyorsa nobetteki dispatcher\\\'a hatayi bildirin.',
      'faq_a17':
          '1- Parka girdiginizde guvenlik ayakkabisi, yelek ve Amazon uniformasi giydiginizi kontrol edin.\n2- Scanner\\\'in dolu oldugunu kontrol edin; degilse dispatcher\\\'a bildirin.\n3- Aracta sorun var mi kontrol edin.\n4- Scanner\\\'da Mentor uygulamasinda trip baslatin.\n5- Arac kilometresi ve gunluk trip sifirini gosteren fotograf paylasin.\n6- Yukleme saatinden yalnizca 10 dk once Waiting Area\\\'ya inin.\n7- Waiting Area\\\'da araci kapatip Flex App ve Timesheet\\\'i baslatin (erken degil).\n8- Yard Marshall talimatlariyla Loading Area\\\'ya gecin; dudukten once aractan inmeyin.\n9- Yukleme bitince, sadece talimat geldikten sonra cikis yapin.\n10- Tum duraklar bitince yakit yaridan azsa doldurun.\n11- Istasyonda kalan paketleri dogru alanlara, cantalari zamaninda birakin.\n12- Parkta araci kapatip Green Book\\\'u doldurun; gunluk km ve Green Book fotograflarini paylasin.\n13- Araci kapatip ekipman cantasini ayrilan alana teslim edin.',
      'faq_a18':
          'Evet. Aracin tum mevcut hasarlarini ayrintili gosteren bir video cekin; boylece sonraki kontrolde onceki hasarlardan sorumlu tutulmazsiniz.',
      'faq_a19':
          'Once internet baglantinizin aktif oldugunu kontrol edin: mevcut duraga mesaj gondermeyi deneyin veya tarayicida bir arama yapin.\nBaglanti yoksa adimlar:\n1- Scanner\\\'i yeniden baslatin (ilk denenecek adim).\n2- Ucak modunu ac/kapat.\n3- Son care olarak en fazla 10 dk kisisel hotspot verin.\nCevrimdisi da calisabilirsiniz; ancak bir noktada internete baglanmaniz gerekir. Flex\\\'te once Offline Maps indirin: Settings - Offline Maps - Download DBY5 - Allow downloads with mobile connection.',
      'faq_a2':
          'Durumu kendi basiniza cozmeye CALISMAYIN; bunun yerine nobetteki dispatcher\\\'i bilgilendirin. Sizin adiniza musteriyle iletisime gecip Amazon sikayetlerinden dogabilecek olumsuzluklari onlemeye calisiriz. Yaninizdayiz!',
      'faq_a20':
          '1- Scanner\\\'i yeniden baslatin.\n2- Ucak modunu ac/kapatin.\n3- Uygulamadan cikis yapin.\n4- Konum servislerini (GPS) kapatip acin.\n5- Flex\\\'ten cikis yapip Mentor\\\'da kullandiginiz bilgilerle yeniden girin.\n6- Uygulama guncellemesi gerekip gerekmedigini kontrol edin.\nBu adimlari tek tek deneyin; biri olmazsa bir sonrakine gecin.',
      'faq_a3':
          'Hatayi duzeltmek icin asla gec degildir. Bizi yine de arayin; musteriyle durumu duzeltmeye calisiriz. Gec olsun, guc olmasin.',
      'faq_a4':
          'Kalite! Her zaman kalite! Musteri talimatlarini izleyin ve duraklarda geride olsaniz bile paketi guvensiz yerlere birakmayin.',
      'faq_a5':
          'Duraklarinizi bir sekilde tamamlarsiniz. Mantikli gordugumuzde destek gondermeye calisiriz.',
      'faq_a6': 'Guzel soru.',
      'faq_a7':
          'Haftalik scorecard, ekibin temel hedeflerde nasil performans gosterdigini hizli ve net bicimde gosterir. Nelerin iyi gittigini, nerede geride kaldigimizi ve gelecek hafta neye odaklanmamiz gerektigini anlamamiza yardimci olur. Genel puan araliklari:\n• Fantastic Plus: >93% (istisnai performans)\n• Fantastic: 85% - 92.9%\n• Great: 70% - 84.9%\n• Fair: 50% - 69.9%\n• Poor: <50%',
      'faq_a7_1':
          'Paketi teslim edip "Bitirmek icin kaydir" ile onaylamaniza ragmen musterinin paketi alamamasi durumudur. Sebepler: paket hirsizligi, kutunun bos olmasi, yanlis adrese teslim vb.\nHer Sali, o hafta aldiginiz tum DNR\\\'lerin gorsellerini alirsiniz.',
      'faq_a7_1_1':
          'Cok onemlidir. Onlemek icin, teslimata gitmeden once musteriyi bilgilendirin ve yalnizca isimlikteki dogru zile basin.',
      'faq_a7_1_2':
          'Mumkunse paketi bizzat musteriye teslim edin. Mumkun degilse paketin nereye birakildigini mesajla net yazin (garaj, merdiven alti, kulube, saksinin arkasi vb.).\nGuvenli degilse paketi birakmayin; yaniniza alip daha sonra tekrar deneyin. Bu COK onemli.',
      'faq_a7_1_3':
          'Icgudu ve sagduyu. 20-30 katli bir binada posta kutularinin yanina birakmak, mustakil eve gore daha yuksek risk tasir.\nAyrica her sabah, DNR riskini azaltmak icin hirsizlik/sikayet riski yuksek adresleri paylasiyoruz.',
      'faq_a7_1_4':
          'Cok olumsuz etkiler. Tek bir paket bile en az %30 etki yaratabilir ve ciddi puan kaybi dogurur. Isminizin altinda ne kadar cok puan varsa durum o kadar kotudur. Haftalik teslimat sayisi arttikca kayip etkisi gorece azalir; urun degeri yuksekse kayip puan da artar. Bu bolumu mumkun oldugunca dusuk tutmaliyiz.\nDuzensiz olarak yuksek kayip sayisi olursa, Amazon hirsizlik supheci surecler baslatabilir; bu nedenle cok risklidir.',
      'faq_a7_2':
          'Musteriyle teslimat hakkinda kac kez iletisime gectiginizi (mesaj/arama) gosterir. Musteriyle ne kadar az iletisim olursa scorecard puani o kadar duser. Bu bolum yuksek olmali; en kolay kategorilerden biridir ve toplam skora ciddi katkisi vardir.',
      'faq_a7_2_1':
          'Teslimat sadece Drop&Go degildir. Musteriyi onceden bilgilendirin ve paketin nereye birakilmasini istedigini sorun.',
      'faq_a7_2_2':
          'Basit: her durakta ozellikle mesaj atarak ve gerekirse arayarak.',
      'faq_a7_3':
          'DNR\\\'nin puana etkisini hatirliyor musunuz? CE bunun en az iki kati kotu olabilir ve olay agirligina gore is riskine kadar gidebilir.',
      'faq_a7_3_1':
          'Her zaman musteri teslimat talimatlarina uyun. Hata olursa ozur dileyin. Musteri ofkeliyse bizle bir dakika gorusmesini rica edin ve bizi arayin. Bu tur durumlari bizim yonetmemiz en dogrusudur.',
      'faq_a7_4':
          'Bu sutun, POD icin uygun olup fotograf cekilmis ancak "Gecersiz" veya "Emin Degil" olarak isaretlenen paketleri gosterir. Reddetme nedenleri:\n1- Fotoğrafta musteri bilgili etiket gorunmesi (paket ters cevrilmeli)\n2- Bulanik fotograf\n3- Fotografta kisi gorunmesi\n4- Fotografta paket gorunmemesi\n5- Paket arac icinde\n6- Paket elde\n7- Paket posta kutusunda\n8- Paket cok yakin\n9- Fotograf cok karanlik\nBu kategori genelde en kolay olandir; hedef 100% olmalidir ve toplam skoru guclu sekilde iyilestirir.',
      'faq_a7_5':
          'Yuklemeden taradiginiz paketi basarisiz teslimat sonrasi vardiya sonunda iade etmezseniz ceza alirsiniz. Paket kayip sayilir ve DNR benzeri puan kaybi olur. Iade ettiginiz paketleri mutlaka sayin ve scanner\\\'daki listeyle eslestirin. Yol: Today\\\'s Itinerary - Summary - Problems. Eslesmiyorsa Amazon uygulamasinda isi bitirmeden once nobetteki dispatcher\\\'a bilgi verin.',
      'faq_a7_6':
          'Paket teslim etme performansinizi gosterir. Planlanan teslimatlarin yuzdesini takip ederek verimlilik ve guvenilirligi olcer. Gecikme, basarisiz deneme veya rota sorunlarini ortaya cikarir. Bu deger mumkun oldugunca yuksek olmalidir. Bunun icin gunluk yeniden deneme yapin ve iadeleri minimumda tutun.',
      'faq_a7_7':
          'Alicinin teslimat deneyimini (dakiklik, urun durumu, surucu profesyonelligi) olcer. Hizmette guclu/zayif alanlari gormemizi saglar. Teslimattan sonra musteriye Amazon tarafindan su tur sorular gelir:\n1) Paketiniz zamaninda teslim edildi mi? (Evet/Hayir)\n2) Paket guvenli bir yere birakildi mi? (Evet/Hayir)\n3) Paket geldiginde durumu iyi miydi? (Evet/Hayir)\n4) Genel teslimat memnuniyetiniz? (Cok memnun ... Cok memnun degil)\n5) Iletisim ve takip guncellemelerini nasil degerlendirirsiniz? (Mukemmel/Iyi/Orta/Kotu)\n6) Teslimati yapan kisi nazik ve profesyonel miydi? (Evet/Hayir/Uygulanamaz)\n7) Ek yorumunuz var mi? (Musteri yorumu)',
      'faq_a7_8':
          'Kalite ve verimlilik birlikte ilerler. Iyi skorlar sizin, sirketin ve tum ekibin yararinadir. Musteri memnuniyeti kritiktir; iyi skorlar bonusla da desteklenir.\nElinizden gelenin en iyisini yapin, en iyisini alin.',
      'faq_a8':
          'Guvenli surus yapin, yaralanmalardan ve kopek isirmalarindan kacinin. Arac, scanner/telefon gibi ekipmanlara dikkat edin. Ise gelirken guvenlik ayakkabisi, reflektorlu yelek ve hava durumuna uygun Amazon kiyafeti giyin.',
      'faq_a9':
          'Once iyi oldugunuzdan ve agir yaralanmadiginizdan emin olun. Hasar, ihmalden kaynaklaniyorsa (ornegin suruste telefonla dikkat daginikligi), tum zarardan sahsen sorumlu olabilirsiniz. Polis raporu duzenlenebilir ve ehliyet yaptirimlari olabilir. Bu durum is akdinin derhal feshine kadar gidebilir. Bunun disinda 2 ay boyunca haftalik scorecard bonuslarindan yararlanamazsiniz. Kaza aninda bizi DERHAL bilgilendirmeniz zorunludur: saat, konum, ozel/kamu malina hasar (duvar, cit, direk, kisi/hayvan), hasarin yeri ve arac fotograflari.',

      'faq_q1': 'Gunluk gorevinizde en onemli sey nedir?',

      'faq_q10': 'Paket hasarli ve/veya eksikse ne yapmaliyim?',

      'faq_q11': 'OTP (One-Time Password) paketi nedir?',

      'faq_q12':
          'Neden hep yavaslayin, daha hizli gitmeyin diye hatirlatiyorsunuz?',

      'faq_q13':
          'O halde dispatcher neden bazen neden geride kaldigimi soruyor?',

      'faq_q14': 'Neden bazen bir ekip arkadasina yardima gitmem isteniyor?',

      'faq_q15':
          'Ilk gunumden itibaren deneyimli suruculer gibi standart rota mi alirim?',

      'faq_q16':
          'Adres yanlissa veya haritadaki pin dogru degilse ne yapmaliyim?',

      'faq_q17':
          'Ise baslamadan once ve bitirdikten sonra gunluk gorevlerim neler?',

      'faq_q18':
          'Her zamanki aracim yerine baska bir van aldigimda ek bir sey yapmali miyim?',

      'faq_q19':
          'Flex uygulamasi surekli yuklenip is akisimi yavaslatirsa ne yapmaliyim?',

      'faq_q2': 'Musteriyle sorun yasandiginda ne yapmamalisiniz?',

      'faq_q20':
          'Internet aktif ama Flex yine de duzgun calismiyorsa ne yapmaliyim?',

      'faq_q3':
          'Durum zaten buyuduysa ve musteri memnun degilse ne yapmaliyim?',

      'faq_q4': 'Hangisi daha onemli: Miktar (hiz) mi yoksa Kalite mi?',

      'faq_q5': 'Kaliteye odaklanirsam ve duraklarda geriye dusersem ne olur?',

      'faq_q6': 'Scorecard ve DNR nedir?',

      'faq_q7': 'Haftalik Scorecard',

      'faq_q7_1': 'DNR Sekmesi\nTeslim Edildi Ama Alinmadi',

      'faq_q7_1_1':
          'Bunu nasil onleyebilirim ve haftalik scorecard icin onemi nedir?',

      'faq_q7_1_2': 'Paket kaybini nasil onlerim?',

      'faq_q7_1_3': 'Hangi yerin guvenli oldugunu nasil anlarim?',

      'faq_q7_1_4': 'Paket kaybolursa veya calinirsa puanim nasil etkilenir?',

      'faq_q7_2': 'CC Sekmesi\nIletisim Uyumlulugu',

      'faq_q7_2_1': 'Bunu neden yapmaliyim?',

      'faq_q7_2_2': 'CC puanimi nasil artiririm?',

      'faq_q7_3': 'CE Sekmesi\nMusteri Eskalasyonu',

      'faq_q7_3_1': 'Bunu nasil onlerim?',

      'faq_q7_4': 'POD Sekmesi\nTeslimatta Fotograf',

      'faq_q7_5': 'LoR Sekmesi\nYolda Kaybolan',

      'faq_q7_6': 'DCR Sekmesi\nTeslimat Tamamlama Orani',

      'faq_q7_7': 'CDF Sekmesi (Onceden DEX)\nMusteri Teslimat Geri Bildirimi',

      'faq_q7_8': 'Scorecard konusunda aklimda ne olmali?',

      'faq_q8': 'Diger hangi alanlarda dikkatli olmaliyim?',

      'faq_q9': 'Kaza yaparsam veya arac hasar gorurse ne olur?',

      'kpi_desc_cc':
          'CC (Musteri Iletisimi)\n\nDeger ne kadar yuksekse o kadar iyidir.\n\nCok onemli:\nAsagidaki durumlarda paketi teslim edemediginiz HER durumda mutlaka "Guvenli birakma yeri yok" veya "Adres bulunamadi" mesaji gondermelisiniz:\n\n- musteri evde degilse veya\n- adres bulunamiyorsa',

      'kpi_desc_cdf':
          'CDF DPMO (Musteri Teslimat Geri Bildirimi)\n\nDeger ne kadar dusukse o kadar iyidir.\n\nSeviye 1 (L1)\n- Musteri teslimati "Harika" (👍) veya "Pek iyi degil" (👎) olarak degerlendirir\n\nSeviye 2 (L2)\n- Deneyimin neden iyi/kotu olduguna dair ek geri bildirim',

      'kpi_desc_ce':
          'CE (Musteri Eskalasyonu)\n\nDeger ne kadar dusukse o kadar iyidir.\nTum kategoriler icinde en olumsuzudur.\n\nMusteriler, teslimat talimatlarina uyulmadiginda eskalasyon acar.\n\nSorumluluk surucudedır\nCok guclu kanit olmadan itiraz neredeyse imkansizdir\nScorecard\\\'a etkisi en yuksek kategoridir\n\nCE\\\'yi onleme\n\nOnaysiz guvensiz/nezaretsiz yerlere paket birakmak teslimat kurallarina aykiridir\n\nDelivery Associate\\\'ler sunlari yapmalidir:\n- Zile basmak / interkom kullanmak / kapiyi tiklamak\n- Musteriye yanit vermesi icin yeterli sure tanimak\n\nMusteriye ulasilamiyor ve kayitli guvenli yer yoksa:\n- Musteriyi iki kez arayin\n- Mesaj gonderin\n- Iletisim kurulamiyorsa Driver Support\\\'a ulasin\n\nGerekirse:\n- Paketi "Teslimat basarisiz - musteriye ulasilamadi" olarak tarayin\n- Kilavuzlara gore yeniden teslimat deneyin',

      'kpi_desc_dcr':
          'Deger ne kadar yuksekse o kadar iyidir. %100 basari icin, basarisiz bir teslimattan sonra yeniden teslimat denemesi* yapilmasi onerilir.',

      'kpi_desc_dnr':
          'DSC DPMO (Teslimat Basari Kosullari)\n(onceki adi: DNR - Delivery Not Received)\n\nDeger ne kadar dusukse o kadar iyidir.\n\nBu metrik, teslimatlarin ne kadar dogru ve izlenebilir yapildigini olcer.\n\nTemel teslimat kurallari:\n- Dogru kisiye veya dogru konuma teslimat\n- Musteri, hane uyesi, komsu veya resepsiyona dogru sekilde teslimat dusuk risklidir\n- Musterinin dogru bildirim almasi icin dogru tarama/neden kodunu kullanin\n\nPosta odasi / posta kutusu teslimatlari:\n- Standart is akisini izleyin\n- Paket posta kutusunun tamamen icinde olmali, disari tasmamalidir\n- Mumkun olan en dogru taramayi secin\n\nDogru adres ve geofence:\n- Dogru geofence icinde 25 metre dahilinde teslimat\n- Uygulamadaki ad/ adresi paket etiketi ve bina ile her zaman eslestirin\n- Geocode yanlis gorunuyorsa SDS uzerinden bildirin\n\nTeslimatta fotograf (POD):\n- Istendiginde her zaman net fotograf cekin\n- Paket ve cevre net gorunmeli\n- Ozellikle gozetsiz teslimatlar ve musteri guveni icin cok onemlidir\n\nTeslimat tercihleri:\n- Guvenliyse uygulamadaki musteri talimatlarini izleyin\n- Talimat guvensizse musteriyle iletisime gecin\n- Yalnizca uygulamadaki onayli guvenli noktalari kullanin\n\nEszamanli / grup duraklari:\n- "Tumunu sec" sadece birden fazla paket ayni kisiye veya konuma gidiyorsa kullanilmali\n- Alici adi ve imzayi dogru kaydedin',

      'kpi_desc_lor':
          'LoR (Yolda Kayip)\n\nDeger ne kadar dusukse o kadar iyidir.\n\nBu metrik, teslim edilemeyen tum paketlerin rota sonunda dogru kaydedilip kaydedilmedigini gosterir.\n\nRota sonunda:\n- Scanner\\\'da iade edilmesi gereken paket sayisini kontrol edin\n- Bu sayinin aractaki paketlerle birebir eslestiginden emin olun',

      'kpi_desc_pod':
          'PoD (Teslimatta Fotograf)\n\nDeger ne kadar yuksekse o kadar iyidir.\n\nBu sutun, fotograf cekilmis ancak "Gecersiz" veya "Guvensiz" olarak isaretlenmis paketleri gosterir.\n\nYaygin POD red nedenleri:\n1. Musteri bilgisi gorunen paket etiketi (paket ters cevrilmeli)\n2. Bulanik fotograf\n3. Fotografta kisi gorunmesi\n4. Fotografta paketin gorunmemesi\n5. Paketin arac icinde olmasi\n6. Paketin elde olmasi\n7. Paketin kameraya cok yakin olmasi\n8. Fotografin cok karanlik olmasi',

      'kpi_tip_cc':
          'Uygulamada her senaryo icin otomatik standart mesaj bulunur.',

      'kpi_tip_cdf': 'CDF yalnizca L1 seviyesinde hesaplanir',

      // Month names (long)
      'kpi_tip_ce':
          'Paketleri guvensiz veya onaysiz yerlere birakmayin\nDogru sevkiyat ve teslimat sureclerini her zaman takip edin',
      'kpi_tip_dcr':
          'Ornek: Bir paketi herhangi bir nedenle ilk denemede teslim edemez ama ayni gun tekrar denerseniz, ikinci deneme de basarisiz olsa DCR degeriniz 100\\\'e daha yakin olur.',

      'kpi_tip_dnr':
          'Onemli not:\n\nDSC DPMO\\\'da tekrar eden yuksek degerler, yanlis veya riskli teslimatlara isaret eder.\n\n- Sik sapmalar Amazon tarafindan olasi hirsizlik supheleriyle yorumlanabilir\n- Bu durum kayip-onleme sureci baslatabilir\n- En kotu senaryoda is birliginin sona ermesine kadar gidebilir\n\nDikkatli tarama, dogru fotograf ve tum kurallara uyum sizi ve ekibinizi korur.',

      'kpi_tip_lor':
          'Onemli not:\n\nBu kategori, hirsizlik suphesinin en yuksek oldugu kategoridir.\n\nScanner kaydi ile arac envanteri arasindaki uyumsuzluklar ciddi hata sayilabilir ve ic sorusturma veya ek yaptirimlara yol acabilir.',

      'kpi_tip_pod':
          'Bu, en kolay kategorilerden biri olmalidir\nHedef deger: %100\nToplam skoru belirgin sekilde iyilestirir',
      'kpi_title_cc': 'Musteri Iletisimi',
      'kpi_title_cdf': 'Musteri Teslimat Geri Bildirimi',
      'kpi_title_ce': 'Musteri Eskalasyonu',

      'kpi_title_dcr': 'Teslimat Basari Orani',
      'kpi_title_dnr': 'Teslimat Basari Kosullari',
      'kpi_title_lor': 'Yolda Kayip',
      'kpi_title_pod': 'Teslimatta Fotograf',
    },

    // =========================
    // RUSSIAN
    // =========================
    'ru': {
      'back': 'Назад',
      'continue': 'Продолжить',
      'button_save': 'Сохранить',
      'required': 'обязательно',
      'error_required': '{field} обязательно',
      'error_required_short': 'Это поле обязательно',
      'uploading': 'Загрузка...',
      'upload': 'Загрузить',
      'replace': 'Заменить',
      'error_must_be_logged_in_driver': 'Вы должны войти как водитель.',
      'coming_soon': 'Скоро',
      'header_good_morning': 'ДОБРОЕ УТРО',
      'header_good_afternoon': 'ДОБРЫЙ ДЕНЬ',
      'header_good_evening': 'ДОБРЫЙ ВЕЧЕР',
      'select_language': 'Выберите язык',
      'notifications': 'Уведомления',
      'no_notifications': 'Нет уведомлений',
      'nav_scorecard': 'Скоркард',
      'nav_help': 'Помощь',
      'nav_rules': 'Правила',
      'nav_profile': 'Профиль',
      'nav_tasks': 'Задачи',
      'driver_home_dispatcher': 'Диспетчер',
      'driver_home_shift_plan_title': 'План смен',
      'driver_home_shift_plan_subtitle': 'Ваши смены',
      'driver_home_scorecard_subtitle': 'Обзор вашей эффективности',
      'driver_home_tasks_title': 'Задачи',
      'driver_home_tasks_subtitle': 'Управление открытыми задачами',
      'driver_home_academy_subtitle': 'Обучение и знания',
      'driver_home_rules_title': 'Правила компании',
      'driver_home_rules_subtitle': 'Инструкции и политики',
      'driver_notification_published_on': 'Опубликовано {date}',
      'driver_home_vehicles_title': 'Транспорт',
      'driver_home_vehicles_subtitle': 'Обзор транспорта',
      'driver_home_codriver_title': 'CoDriver AI',
      'driver_home_codriver_subtitle': 'Ваш AI ассистент',
      'driver_home_absence_title': 'Отсутствие',
      'driver_home_absence_subtitle': 'Отпуск и больничный',
      'driver_home_incident_title': 'Отчет об инциденте',
      'driver_home_incident_subtitle': 'Сообщить об аварии',
      'driver_home_new_badge': 'НОВОЕ',
      'driver_academy_title': 'DA Academy',
      'driver_academy_green_book_title': 'Green Book',
      'driver_academy_green_book_subtitle':
          'Руководство по ежедневному листу проверки',
      'driver_academy_safety_title': 'Обучение безопасности',
      'driver_academy_safety_subtitle': 'Тренинги по безопасности',
      'driver_academy_delivery_title': 'Amazon Delivery',
      'driver_academy_delivery_subtitle': 'Процессы и рабочие потоки доставки',
      'driver_academy_app_title': 'Приложение CoDriver',
      'driver_academy_app_subtitle': 'Функции и руководства приложения',
      'driver_green_book_title': 'Green Book',
      'driver_green_book_video_title': 'Green Book - обучающее видео',
      'driver_green_book_video_subtitle': 'Нажмите, чтобы воспроизвести',
      'driver_green_book_start_test': 'Начать тест Green Book',
      'driver_green_book_test_required': 'Тест обязателен',
      'driver_green_book_section1_title': 'Ежедневный лист проверки Green Book',
      'driver_green_book_section1_text':
          'Ежедневный лист проверки (Green Book) - обязательный документ, который нужно заполнять перед каждой сменой. Он помогает проверять состояние автомобиля и фиксировать пункты безопасности.',
      'driver_green_book_section1_b1':
          'Полностью заполняйте его перед каждой сменой.',
      'driver_green_book_section1_b2':
          'Сразу сообщайте о неисправностях автомобиля.',
      'driver_green_book_section1_b3': 'Не забывайте подпись.',
      'driver_green_book_section2_title': 'Последствия несоблюдения',
      'driver_green_book_section2_text':
          'Нарушения обрабатываются по нарастающим этапам:',
      'driver_green_book_section2_b1':
          'Первое предупреждение: устное предупреждение от диспетчера.',
      'driver_green_book_section2_b2':
          'Второе предупреждение: письменное предупреждение.',
      'driver_green_book_section2_b3':
          'Повторные нарушения: дисциплинарные меры.',
      'driver_green_book_section3_title': 'Юридические штрафы',
      'driver_green_book_section3_text':
          'Если Green Book отсутствует или заполнен не полностью при проверке:',
      'driver_green_book_section3_b1': 'Штраф для водителя до 5000 EUR.',
      'driver_green_book_section3_b2': 'Штраф для компании до 30000 EUR.',
      'driver_green_book_section3_b3':
          'Могут быть начислены баллы во Фленсбурге.',
      'driver_green_book_section3_b4':
          'Это может негативно повлиять на страховку.',
      'driver_green_book_test_title': 'Тест Green Book',
      'driver_green_book_test_progress': 'Вопрос {current} из {total}',
      'driver_green_book_test_next': 'Далее',
      'driver_green_book_test_submit': 'Отправить тест',
      'driver_green_book_test_result_pass_title': 'Тест пройден',
      'driver_green_book_test_result_fail_title': 'Тест не пройден',
      'driver_green_book_test_result_pass_body':
          'Поздравляем! Вы прошли тест: {score}/{total}.',
      'driver_green_book_test_result_fail_body':
          'Ваш результат {score}/{total}. Попробуйте снова.',
      'driver_green_book_test_retry': 'Повторить',
      'driver_green_book_test_close': 'Закрыть',
      'driver_green_book_test_back_to_green_book': 'Назад к Green Book',
      'driver_green_book_test_no_questions':
          'Вопросы теста еще не настроены. Пожалуйста, свяжитесь с диспетчером.',
      'driver_green_book_test_offline_fallback':
          'Сбой онлайн-синхронизации теста. Вы можете продолжить с резервными вопросами и попробовать снова.',
      'admin_home_notification': 'Уведомление',
      'admin_home_driver_fallback': 'Водитель',
      'admin_home_not_confirmed_by': 'НЕ ПОДТВЕРДИЛИ:',
      'admin_home_missing_loading': 'не подтвердили: ...',
      'admin_home_missing_unknown': 'не подтвердили: --',
      'admin_home_missing_count': 'не подтвердили: {count}',
      'admin_home_error_generic': 'Ошибка: {error}',
      'admin_home_all_drivers_confirmed': 'Все водители подтвердили.',
      'admin_home_close': 'Закрыть',
      'admin_home_last_week': 'Прошлая неделя',
      'admin_home_not_logged_in': 'Нет входа в систему.',
      'admin_home_loading_reports': 'Загрузка отчетов...',
      'admin_home_no_reports_uploaded': 'Отчеты еще не загружены.',
      'admin_home_week_short': 'НЕД',
      'admin_home_month_prefix': 'МЕСЯЦ',
      'admin_home_year_prefix': 'ГОД',
      'admin_home_loading_scores': 'Загрузка оценок...',
      'admin_home_name_fallback': 'Имя Фамилия',
      'admin_home_scorecard': 'Скоркард',
      'admin_home_company_score': 'ОЦЕНКА КОМПАНИИ',
      'admin_home_of': 'из',
      'admin_home_best_driver': 'Лучший водитель',
      'admin_home_worst_defender': 'Худший defender',
      'admin_home_notification_history': 'История уведомлений',
      'admin_home_no_notifications_yet': 'Пока нет уведомлений.',
      'admin_home_notification_type_message': 'НОВОЕ СООБЩЕНИЕ',
      'admin_home_notification_type_academy': 'DA ACADEMY',
      'admin_home_notification_type_ride_along': 'RIDE ALONG',
      'admin_home_notification_type_rule': 'НОВОЕ ПРАВИЛО',
      'admin_home_edit_rule': 'Редактировать правило',
      'admin_home_title': 'Заголовок',
      'admin_home_body': 'Текст',
      'admin_home_cancel': 'Отмена',
      'admin_home_save': 'Сохранить',
      'admin_home_title_or_body_required': 'Требуется заголовок или текст.',
      'admin_home_notification_not_found': 'Уведомление не найдено.',
      'admin_home_rule_updated_for_drivers':
          'Правило обновлено для {count} водителей.',
      'admin_home_edit_failed': 'Ошибка редактирования: {error}',
      'admin_home_delete_notification_question': 'Удалить уведомление?',
      'admin_home_delete_notification_body':
          'Это уведомление будет удалено у вас и у всех водителей.',
      'admin_home_delete': 'Удалить',
      'admin_home_notification_deleted': 'Уведомление удалено.',
      'admin_home_delete_failed': 'Ошибка удаления: {error}',
      'admin_home_options': 'Опции',
      'admin_home_title_upper': 'ЗАГОЛОВОК',
      'admin_home_confirmed_by': 'подтвердили',
      'admin_home_fleet_hub': 'Fleet Hub',
      'admin_home_service': 'Сервис',
      'admin_home_accidents': 'Инциденты',
      'admin_home_total': 'всего',
      'admin_home_active': 'активные',
      'admin_home_inactive': 'неактивные',
      'admin_home_doc_id_card': 'ID-карта',
      'admin_home_doc_driving_license': 'Водительское удостоверение',
      'admin_home_doc_residence_permit': 'Вид на жительство',
      'admin_home_loading_drivers': 'Загрузка водителей...',
      'admin_home_no_drivers_yet': 'Пока нет водителей.',
      'admin_home_contract': 'Контракт',
      'admin_home_last_day': 'последний день',
      'admin_home_probation': 'Испытательный срок',
      'admin_home_ended': 'завершен',
      'admin_home_ends': 'заканчивается',
      'admin_home_expired_by': 'истек',
      'admin_home_loading_documents': 'Загрузка документов...',
      'admin_home_driver_documents': 'Документы водителей',
      'admin_home_expired_documents': 'Просроченные документы',
      'admin_home_expired_soon': 'скоро истекают',
      'admin_home_missing_documents_data': 'Отсутствующие документы / данные',
      'admin_home_total_missing': 'всего отсутствует',
      'admin_home_driver_contracts': 'Контракты водителей',
      'admin_home_last_day_soon': 'последний день скоро',
      'admin_home_no_items': 'Нет элементов',
      'admin_home_time_suffix': '',
      'change_profile_photo': 'Изменить фото профиля',
      'profile_change_photo': 'Изменить фото профиля',
      'logout': 'Выйти',
      'profile_logout': 'Выйти',
      'pin_change_with_old':
          'Вы можете изменить PIN после подтверждения старого PIN.',
      'pin_forgot_contact_admin': 'Забыли PIN? Обратитесь к администратору.',
      'profile_photo_updated': 'Фото профиля обновлено.',
      'failed_upload_profile_photo':
          'Не удалось загрузить фото профиля: {error}',
      'could_not_read_image_bytes':
          'Не удалось прочитать данные изображения из выбора файла.',
      'hi_name': 'Привет, {name}! 👋',
      'welcome_to_company': 'добро пожаловать в {company}',
      'welcome_desc': 'Мы рады видеть вас в команде. Давайте начнем!',
      'codriver': 'CODRIVER',
      'your_address': 'ВАШ АДРЕС',
      'your_origin': 'ВАШЕ ПРОИСХОЖДЕНИЕ',
      'uniform': 'ФОРМА',
      'hint_street_house': 'Улица, номер дома',
      'hint_postal_code': 'Почтовый индекс',
      'hint_city': 'Город',
      'hint_country': 'Страна',
      'hint_birthday': 'Дата рождения',
      'hint_birth_city': 'Город рождения',
      'hint_birth_state': 'Регион рождения',
      'hint_nationality': 'Гражданство (ID-карта) (название страны)',
      'label_cloth_size': 'Выберите размер одежды',
      'hint_cloth_size': 'S / M / L / XL',
      'label_shoe_size': 'Выберите размер обуви',
      'hint_shoe_size': 'например, 42',
      'label_notes': 'Другие пожелания / заметки',
      'work_permit': 'РАЗРЕШЕНИЕ НА РАБОТУ',
      'work_permit_question':
          'Какой тип разрешения на работу у вас есть для работы в Германии?',
      'permit_german_id': 'Немецкая ID-карта',
      'permit_eu_id': 'ID-карта ЕС',
      'permit_work_visa': 'РАБОЧАЯ ВИЗА для Германии',
      'your_work_permit': 'ВАШЕ РАЗРЕШЕНИЕ НА РАБОТУ',
      'please_upload_doc': 'Пожалуйста, загрузите документ',
      'upload_quality_hint':
          'Убедитесь, что фото полностью видно, хорошего качества и снято сверху',
      'upload_your_file': 'Загрузите файл',
      'file_formats_generic': 'JPG, JPEG, HEIC, PDF до 50 МБ',
      'hint_select_expiry': 'Выберите дату окончания',
      'id_passport_title': 'ID-карта, паспорт',
      'id_card': 'ID-КАРТА',
      'passport': 'ПАСПОРТ',
      'or': 'ИЛИ',
      'your_passport': 'ВАШ ПАСПОРТ',
      'your_id_card': 'ВАША ID-КАРТА',
      'frontside': 'ЛИЦЕВАЯ СТОРОНА',
      'backside': 'ОБРАТНАЯ СТОРОНА',
      'your_drivers_license': 'ВАШЕ ВОДИТЕЛЬСКОЕ УДОСТОВЕРЕНИЕ',
      'upload_file_front': 'Загрузите файл (лицевая сторона)',
      'upload_file_back': 'Загрузите файл (обратная сторона)',
      'file_formats_license': 'JPG, JPEG, HEIC, PNG (не PDF)',
      'tax_document': 'НАЛОГОВЫЙ ДОКУМЕНТ',
      'please_upload_tax_id':
          'Пожалуйста, загрузите документ с налоговым номером',
      'upload_tax_id': 'Загрузить налоговый номер',
      'file_formats_tax': 'PDF, JPG, PNG... до 50 МБ',
      'label_iban': 'IBAN',
      'label_license_expiry': 'Срок действия водительского удостоверения',
      'hint_license_expiry': 'Выберите дату окончания',
      'label_uploaded_docs': 'Загруженные документы',
      'no_docs': 'Документы еще не загружены.',
      'doc_resident_permit': 'Разрешение на работу / вид на жительство',
      'doc_tax_id': 'Документ налогового номера',
      'doc_insurance': 'Страховка',
      'doc_other_doc': 'Другой документ',
      'driver_license_front': 'Водительское удостоверение (лицевая)',
      'driver_license_back': 'Водительское удостоверение (обратная)',
      'id_card_front': 'ID-карта (лицевая)',
      'id_card_back': 'ID-карта (обратная)',
      'passport_front': 'Паспорт (лицевая)',
      'passport_back': 'Паспорт (обратная)',
      'dash_error_loading_reports': 'Ошибка загрузки отчетов: {error}',
      'dash_no_reports_uploaded': 'Ваш DSP еще не загрузил отчеты scorecard.',
      'dash_scorecard_week': 'SCORECARD НЕДЕЛЯ {week}',
      'dash_week_range': 'Неделя {week}, {year}',
      'dash_no_scores_period': 'Для этого периода пока нет оценок.',
      'dash_no_drivers_match': 'Нет водителей, подходящих под фильтр.',
      'dash_no_name': '(Без имени)',
      'dash_company_score': 'Оценка компании',
      'dash_my_score': 'Моя оценка',
      'dash_select_period': 'Выбрать период',
      'dash_weekly_view': 'Недельный вид',
      'dash_best_da_month': 'Лучший DA месяца',
      'dash_best_da_year': 'Лучший DA года',
      'dash_week': 'Неделя',
      'dash_total_score': 'Общий балл',
      'dash_rank_in_station': 'Ранг на станции',
      'dash_status': 'Статус',
      'dash_company_data_section': 'Данные по компании',
      'dash_company_data_show': 'Показать результаты как у компании',
      'dash_company_data_hide': 'Скрыть категории компании',
      'dash_rank': 'Ранг',
      'dash_score': 'Балл',
      'dash_name': 'Имя',
      'dash_delivered': 'Доставлено',
      'dash_rank_in_aion': 'Ранг в AION',
      'dash_rank_of_total': '{rank} из {total}',
      'dash_no_my_score_week':
          'Для вашего ID водителя за эту неделю оценка не найдена.',
      'dash_all_status': 'Все статусы',
      'dash_search_name_or_id': 'Поиск по имени или ID Transporter...',
      'dash_upload_driver_csv': 'Загрузить CSV водителей',
      'scorecard_overview_title': 'ПАНЕЛЬ SCORE CARD',
      'scorecard_overview_overview_suffix': '— Обзор',
      'scorecard_overview_upload_pdf': 'ЗАГРУЗИТЬ PDF SCORECARD',
      'scorecard_overview_upload_prompt': 'Загрузите ваш PDF Scorecard',
      'scorecard_overview_choose_file': 'Выбрать файл',
      'scorecard_overview_summary_title': 'Сводка Score Card',
      'scorecard_overview_no_reports_yet':
          'Отчетов пока нет. Загрузите первый PDF Scorecard, чтобы начать.',
      'scorecard_overview_chart_title': 'Обзор Score Card',
      'scorecard_overview_best_drivers': 'Лучшие водители',
      'scorecard_overview_no_reports_available': 'Нет доступных отчетов.',
      'scorecard_overview_no_drivers_period':
          'Для этого периода водители не найдены.',
      'scorecard_overview_select_station': 'Выберите станцию',
      'scorecard_overview_all_stations': 'Все станции',
      'scorecard_overview_select_period': 'Выберите период',
      'scorecard_overview_best_drivers_year': 'Лучшие водители года',
      'scorecard_overview_best_drivers_month': 'Лучшие водители месяца',
      'scorecard_overview_station': 'Станция',
      'scorecard_overview_station_code': 'Станция {code}',
      'scorecard_overview_upload_success_one':
          '1 scorecard обработан и сохранен. Панель обновлена.',
      'scorecard_overview_upload_success_many':
          '{count} scorecard обработано и сохранено. Панель обновлена.',
      'scorecard_overview_upload_parse_failed':
          'Ошибка загрузки/разбора: {error}',
      'scorecard_overview_no_file_bytes': 'Нет данных файла',
      'scorecard_overview_csv_updated':
          'Имена водителей обновлены во всех ваших отчетах.',
      'scorecard_overview_csv_failed': 'Ошибка импорта CSV: {error}',
      'scorecard_overview_delete_report_q': 'Удалить отчет?',
      'scorecard_overview_delete_report_body':
          'Это удалит отчет "{title}" и все записи оценок за эту неделю.',
      'scorecard_overview_deleted': 'Отчет и оценки за неделю удалены.',
      'scorecard_overview_delete_failed': 'Ошибка удаления: {error}',
      'scorecard_overview_more': 'Еще',
      'scorecard_overview_delete_report_menu': 'Удалить отчет',
      'scorecard_overview_upload_processing':
          'Загрузка и обработка scorecard...',
      'scorecard_overview_row_title': 'Score Card {year} НЕД {week}',
      'scorecard_overview_reliability_score': 'Оценка надежности',
      'scorecard_overview_from_last_week': 'по сравнению с прошлой неделей',
      'scorecard_overview_from_last_year': 'по сравнению с прошлым годом',
      'kpi_score': 'БАЛЛ',
      'kpi_value': 'ЗНАЧЕНИЕ',
      'kpi_pro_tip': 'ПРО СОВЕТ',
      'pod_quality_title': 'Качество POD',
      'pod_quality_success': 'Успех',
      'pod_quality_rejects': 'Отклонено',
      'pod_quality_opp': 'Возможности',
      'pod_quality_bypass': 'Пропуск',
      'pod_quality_blurry': 'Размыто',
      'pod_quality_too_dark': 'Слишком темно',
      'pod_quality_no_package': 'Нет посылки',
      'pod_quality_in_car': 'В машине',
      'pod_quality_too_close': 'Слишком близко',
      'pod_quality_shell_week_title': 'КАЧЕСТВО POD - НЕДЕЛЯ',
      'pod_quality_week_label': 'Неделя {week}',
      'pod_quality_dashboard_title': 'ПАНЕЛЬ КАЧЕСТВА POD',
      'pod_quality_upload_pdf': 'Загрузить PDF',
      'pod_quality_no_reports_uploaded':
          'Пока нет отчетов по качеству POD. Загрузите POD PDF, чтобы начать.',
      'pod_quality_upload_success_one':
          '1 отчет по качеству POD обработан и сохранен.',
      'pod_quality_upload_success_many':
          '{count} отчетов по качеству POD обработано и сохранено.',
      'pod_quality_upload_parse_failed': 'Ошибка загрузки/разбора: {error}',
      'pod_quality_rejects_breakdown': 'Разбивка отклонений',
      'pod_quality_no_data_week': 'Нет данных POD за эту неделю.',
      'pod_quality_drivers': 'Водители',
      'pod_quality_entries_count': '{count} записей',
      'month_jan': 'Январь',
      'month_feb': 'Февраль',
      'month_mar': 'Март',
      'month_apr': 'Апрель',
      'month_may': 'Май',
      'month_jun': 'Июнь',
      'month_jul': 'Июль',
      'month_aug': 'Август',
      'month_sep': 'Сентябрь',
      'month_oct': 'Октябрь',
      'month_nov': 'Ноябрь',
      'month_dec': 'Декабрь',
      'month_short_jan': 'Янв',
      'month_short_feb': 'Фев',
      'month_short_mar': 'Мар',
      'month_short_apr': 'Апр',
      'month_short_may': 'Май',
      'month_short_jun': 'Июн',
      'month_short_jul': 'Июл',
      'month_short_aug': 'Авг',
      'month_short_sep': 'Сен',
      'month_short_oct': 'Окт',
      'month_short_nov': 'Ноя',
      'month_short_dec': 'Дек',
      'status_fantastic': 'Отлично',
      'status_great': 'Очень хорошо',
      'status_fair': 'Средне',
      'status_poor': 'Плохо',
      'bucket_fantastic_plus': 'Отлично Плюс',
      'bucket_fantastic': 'Отлично',
      'bucket_great': 'Очень хорошо',
      'bucket_fair': 'Средне',
      'bucket_poor': 'Плохо',
      'rank_at': 'на',
      'rank_of': 'из',
      'period_month': 'Месяц',
      'kw': 'KW',
      'faq_title': 'Часто задаваемые вопросы',
      'faq_search_hint': 'Поиск по вопросам',
      'faq_empty': 'Совпадающие FAQ не найдены.',
      'driver_tasks_error': 'Ошибка: {error}',
      'driver_tasks_no_tasks': 'Пока нет назначенных задач.',
      'driver_tasks_update_status': 'Обновить статус',
      'driver_tasks_confirm_completed': 'Подтвердить выполнение',
      'driver_tasks_set_completed_first':
          'Сначала установите статус «Завершено».',
      'driver_tasks_completion_confirmed': 'Выполнение подтверждено.',
      'driver_tasks_failed_update_status':
          'Не удалось обновить статус: {error}',
      'driver_tasks_failed_confirm_task':
          'Не удалось подтвердить задачу: {error}',
      'driver_tasks_status_confirmed_by_you': 'Статус подтвержден вами.',
      'driver_tasks_confirm_when_fully_done':
          'Пожалуйста, подтвердите, когда эта задача будет полностью выполнена.',
      'driver_tasks_status_pending': 'В ожидании',
      'driver_tasks_status_in_progress': 'В процессе',
      'driver_tasks_status_completed': 'Завершено',
      'faq_green_book_video_title': 'Видео-инструкция Green Book',
      'faq_green_book_video_subtitle':
          'Посмотрите, как заполнять Green Book шаг за шагом',
      'faq_green_book_video_action': 'Смотреть видео',
      'faq_green_book_video_missing':
          'Ссылка на видео Green Book еще не настроена.',
      'faq_green_book_video_open_failed':
          'Не удалось открыть ссылку на видео Green Book.',

      // Added for full key coverage (from EN fallback)
      'faq_a1': 'Качественно доставлять посылки и вести себя профессионально.',
      'faq_a10':
          'Если посылка повреждена, отметьте ее как damaged и верните на станцию. Если это жидкость и она повредила другие посылки, сфотографируйте все поврежденные отправления и отправьте дежурному диспетчеру; мы передадим в Amazon.\nЕсли посылка отсутствует, можно отметить missing, кроме OTP-посылок: по OTP вы ОБЯЗАНЫ сначала сообщить нам, и только потом отмечать missing. Это ОЧЕНЬ ВАЖНО.',
      'faq_a11':
          'Это дорогой товар, для которого Amazon требует одноразовый пароль от клиента перед вручением, чтобы убедиться, что посылка передана правильному получателю. С такими посылками нужна повышенная осторожность: не оставляйте их без присмотра и вручайте только клиенту, который сообщил пароль.',
      'faq_a12':
          'Нам это тоже не всегда нравится, но так работает система. Нужно следовать алгоритму и плановому темпу стопов в час, чтобы компания получала больше маршрутов, а у вас было больше рабочих смен.\nСлишком высокая скорость повышает риск DNR и может снизить недельные баллы и для вас, и для компании.',
      'faq_a13':
          'Мы понимаем, что это неприятно, но нам нужна обратная связь о причинах отставания на маршруте. Amazon задает контрольные точки по времени (к какому времени должен быть выполнен X стоп), поэтому важно понимать причины отставания и улучшать планирование.',
      'faq_a14':
          'На задержку влияют многие факторы: плохой интернет, трафик, перекрытые улицы из-за работ и т.д. Поэтому иногда нужна помощь, чтобы коллега успел завершить маршрут вовремя.',
      'faq_a15':
          'Нет. В начале у вас есть 14 рабочих дней адаптации, чтобы применить знания после ride-along с тренером, привыкнуть к району, машине, scanner и рабочему процессу.\nВ этот период Amazon обычно дает до 50% меньше обычного количества посылок и стопов.',
      'faq_a16':
          'Сначала проверьте адрес в Google Maps (обычно точнее и уже установлен в scanner). Если не совпадает, сообщите дежурному диспетчеру об ошибке.',
      'faq_a17':
          '1- При заезде на парковку убедитесь, что на вас защитная обувь, жилет и форма Amazon.\n2- Проверьте, что scanner заряжен; если нет, сообщите диспетчеру.\n3- Проверьте состояние автомобиля.\n4- Запустите trip в приложении Mentor на scanner.\n5- Отправьте фото панели с текущим пробегом и daily trip, сброшенным в 0.\n6- В Waiting Area спускайтесь только за 10 минут до времени загрузки.\n7- В Waiting Area заглушите машину и запустите Flex App и Timesheet (не раньше).\n8- Переходите в Loading Area по инструкциям Yard Marshall; выходите из авто только после свистка.\n9- После загрузки начинайте движение только по команде Yard Marshall.\n10- После всех стопов проверьте топливо; если меньше половины - заправьтесь.\n11- На станции сдайте оставшиеся посылки и сумки в нужные зоны Amazon.\n12- На парковке заглушите машину, заполните Green Book (Tageskontrollblat), отправьте фото дневного пробега и Green Book.\n13- Верните рабочую сумку в назначенную зону.',
      'faq_a18':
          'Да. Снимите подробное видео всех имеющихся повреждений, чтобы на следующей проверке это не считалось вашей виной.',
      'faq_a19':
          'Сначала проверьте активность интернета: попробуйте отправить сообщение текущему клиенту или открыть поиск в браузере на scanner.\nЕсли интернета нет:\n1- Перезапустите scanner (всегда первый шаг).\n2- Включите/выключите авиарежим.\n3- В крайнем случае раздайте личный hotspot максимум на 10 минут для обновления системы.\nМожно работать офлайн, но позже нужно снова подключиться к интернету. Для офлайна заранее скачайте карты в Flex: Settings - Offline Maps - Download DBY5 - Allow downloads with mobile connection.',
      'faq_a2':
          'НЕ пытайтесь решить ситуацию самостоятельно. Сразу сообщите дежурному диспетчеру. Мы свяжемся с клиентом за вас и постараемся предотвратить негативные последствия из-за жалоб в Amazon. Мы рядом и готовы помочь.',
      'faq_a20':
          '1- Перезапустите scanner.\n2- Включите/выключите авиарежим.\n3- Полностью выйдите из приложения.\n4- Выключите/включите Location Services (GPS).\n5- Выйдите из Flex и войдите снова с данными Mentor.\n6- Проверьте, требуется ли обновление приложения.\nВыполняйте шаги по одному: если один не помог, переходите к следующему.',
      'faq_a3':
          'Исправить ошибку никогда не поздно. Все равно позвоните нам, и мы постараемся урегулировать ситуацию с клиентом. Лучше поздно, чем никогда.',
      'faq_a4':
          'Качество! Всегда качество! Следуйте инструкциям клиента и НЕ оставляйте посылку в небезопасных местах, даже если отстаете по стопам.',
      'faq_a5':
          'Вы все равно закончите маршрут. Мы постараемся отправить помощь, если это действительно обосновано.',
      'faq_a6': 'Отличный вопрос.',
      'faq_a7':
          'Еженедельный scorecard дает быстрый и понятный обзор того, как команда выполняет ключевые цели. Он помогает видеть, что идет хорошо, где есть отставание и на чем сосредоточиться на следующей неделе. Общие уровни:\n• Fantastic Plus: >93% (исключительная работа)\n• Fantastic: 85% - 92.9%\n• Great: 70% - 84.9%\n• Fair: 50% - 69.9%\n• Poor: <50%',
      'faq_a7_1':
          'Это ситуация, когда вы доставили посылку и подтвердили "Swipe to finish", но клиент не получил ее по ряду причин: кража, пустая коробка, доставка по неверному адресу и т.д.\nКаждый вторник вы получаете изображения всех DNR за неделю.',
      'faq_a7_1_1':
          'Это очень важно. Чтобы снизить риск, заранее уведомляйте клиента о доставке и звоните только в правильный звонок по табличке с именем.',
      'faq_a7_1_2':
          'По возможности передавайте посылку лично клиенту. Если это невозможно, отправьте сообщение, где именно оставили посылку (гараж, под лестницей, в сарае, за вазоном и т.п.).\nЕсли место кажется небезопасным, лучше не оставлять посылку, а взять ее с собой и попробовать доставить позже. Это ОЧЕНЬ важно.',
      'faq_a7_1_3':
          'По здравому смыслу и опыту. Например, в доме на 20-30 этажей оставлять у почтовых ящиков обычно намного рискованнее, чем в частном доме.\nТакже по утрам мы публикуем адреса с повышенным риском DNR, чтобы вам было проще избегать проблем.',
      'faq_a7_1_4':
          'Сильно негативно. Даже одна посылка может заметно ухудшить показатель и дать крупный штраф по баллам. Чем больше штрафных баллов у вашего имени, тем хуже. При большем количестве доставок эффект отдельного инцидента относительно ниже; дорогие товары дают больший минус. Этот показатель нужно держать как можно ниже.\nЕсли потери происходят регулярно, Amazon может заподозрить кражу, что очень опасно для работы.',
      'faq_a7_2':
          'Показывает, как часто вы связываетесь с клиентом по доставке (сообщения/звонки). Чем меньше коммуникации, тем ниже балл. Этот раздел должен быть высоким: это одна из самых простых категорий и она сильно помогает общему результату.',
      'faq_a7_2_1':
          'Доставка - это не только Drop&Go. Нужно заранее информировать клиента и уточнять, куда лучше оставить посылку.',
      'faq_a7_2_2':
          'Очень просто: звоните и особенно пишите клиентам на каждом стопе.',
      'faq_a7_3':
          'Помните, как DNR влияет на баллы? CE обычно минимум в 2 раза хуже и в тяжелых случаях может привести к потере работы.',
      'faq_a7_3_1':
          'Всегда следуйте инструкциям клиента по доставке. Если произошла ошибка, сначала извинитесь. Если клиент зол, попросите минуту на разговор с нами и сразу звоните. Такие ситуации лучше передавать нам.',
      'faq_a7_4':
          'В этой колонке показаны посылки, для которых фото сделано, но помечено как Invalid или Not Sure. Причины отклонения POD:\n1- На фото видна этикетка с данными клиента (посылку нужно повернуть)\n2- Размытое фото\n3- На фото виден человек\n4- На фото не видно посылки\n5- Посылка в машине\n6- Посылка в руке\n7- Посылка в почтовом ящике\n8- Посылка слишком близко\n9- Фото слишком темное\nОбычно это самая простая категория: цель 100%, и она хорошо повышает общий score.',
      'faq_a7_5':
          'Штрафует, если вы отсканировали посылку при загрузке, но не вернули ее в конце смены после неуспешной доставки. Такая посылка считается потерянной, и штраф сопоставим с DNR. Тщательно считайте возвраты и сверяйте их со scanner. Путь: Today\\\'s Itinerary - Summary - Problems. Если не совпадает, сообщите дежурному диспетчеру до завершения смены в приложении Amazon.',
      'faq_a7_6':
          'Показывает вашу способность завершать доставки. Отслеживает долю выполненных доставок и отражает эффективность и надежность. Выявляет задержки, неудачные попытки и проблемы маршрута. Значение должно быть как можно выше. Для этого делайте повторные попытки и по возможности уменьшайте возвраты.',
      'faq_a7_7':
          'Оценивает опыт получателя: вовремя ли доставка, состояние посылки, профессионализм водителя. Это помогает видеть сильные и слабые стороны сервиса. После доставки клиент получает письмо Amazon с вопросами:\n1) Доставлена ли посылка вовремя? (Да/Нет)\n2) Оставлена ли посылка в безопасном месте? (Да/Нет)\n3) Была ли посылка в хорошем состоянии? (Да/Нет)\n4) Общая удовлетворенность доставкой?\n5) Как вы оцениваете коммуникацию и трекинг? (Отлично/Хорошо/Средне/Плохо)\n6) Был ли курьер вежлив и профессионален?\n7) Дополнительные комментарии клиента.',
      'faq_a7_8':
          'Качество и эффективность идут вместе. Хорошие баллы полезны вам, компании и всей команде. Удовлетворенность клиента критична, а хорошие показатели поддерживаются бонусами.\nДелайте максимум - получайте максимум.',
      'faq_a8':
          'Берегите себя: безопасное вождение, профилактика травм, осторожность с собаками и укусами. Бережно относитесь к рабочему оборудованию (машина, scanner/телефон) и приходите в защитной обуви, жилете и фирменной одежде Amazon по погоде.',
      'faq_a9':
          'Сначала убедитесь, что вы не получили серьезных травм. Если ущерб вызван небрежностью (например, использование телефона за рулем), вы можете нести полную личную ответственность за повреждения. Также возможен полицейский протокол и санкции по правам. Это может стать причиной немедленного увольнения. В ином случае вы исключаетесь из Weekly Scorecard Bonus на 2 месяца. При инциденте вы ОБЯЗАНЫ немедленно сообщить нам время, место, наличие ущерба частной/публичной собственности (стены, заборы, столбы, люди/животные), а также прислать фото повреждений авто.',

      'faq_q1': 'Что самое важное в вашей ежедневной работе?',

      'faq_q10': 'Что делать, если посылка повреждена и/или отсутствует?',

      'faq_q11': 'Что такое OTP (One-Time Password) посылка?',

      'faq_q12': 'Почему вы постоянно просите замедлиться и не ехать быстрее?',

      'faq_q13':
          'Тогда почему диспетчеры иногда спрашивают, почему вы отстаете?',

      'faq_q14': 'Почему иногда просят помочь коллеге?',

      'faq_q15':
          'С первого дня я сразу получу стандартный маршрут как у опытных водителей?',

      'faq_q16':
          'Что делать, если адрес неверный и/или pin на карте неправильный?',

      'faq_q17': 'Какие ежедневные задачи до начала и после окончания смены?',

      'faq_q18':
          'Нужно ли что-то делать, если я беру другой фургон вместо своего обычного?',

      'faq_q19':
          'Что делать, если приложение Flex постоянно грузится и тормозит работу?',

      'faq_q2': 'Чего нельзя делать при проблеме с клиентом?',

      'faq_q20':
          'Что если интернет активен, но Flex все равно работает некорректно?',

      'faq_q3': 'Что делать, если ситуация уже обострилась и клиент недоволен?',

      'faq_q4': 'Что важнее: количество (скорость) или качество?',

      'faq_q5': 'Если я делаю упор на качество и начинаю отставать по стопам?',

      'faq_q6': 'Что такое scorecard и DNR?',

      'faq_q7': 'Еженедельный Scorecard',

      'faq_q7_1': 'Вкладка DNR\nДоставлено, но не получено',

      'faq_q7_1_1': 'Как этого избежать и насколько это важно для scorecard?',

      'faq_q7_1_2': 'Как избежать потери посылок?',

      'faq_q7_1_3': 'Как понять, безопасное место или нет?',

      'faq_q7_1_4':
          'Если посылка потеряна или украдена, как это повлияет на мой счет?',

      'faq_q7_2': 'Вкладка CC\nСоответствие коммуникации',

      'faq_q7_2_1': 'Почему это важно делать?',

      'faq_q7_2_2': 'Как улучшить CC?',

      'faq_q7_3': 'Вкладка CE\nЭскалация клиента',

      'faq_q7_3_1': 'Как этого избежать?',

      'faq_q7_4': 'Вкладка POD\nФото при доставке',

      'faq_q7_5': 'Вкладка LoR\nПотеряно в пути',

      'faq_q7_6': 'Вкладка DCR\nПроцент завершения доставок',

      'faq_q7_7': 'Вкладка CDF (ранее DEX)\nОбратная связь клиента по доставке',

      'faq_q7_8': 'Что важно помнить о scorecard?',

      'faq_q8': 'В каких еще областях нужно быть особенно внимательным?',

      'faq_q9':
          'Что будет, если я попаду в ДТП или поврежу рабочий автомобиль?',

      'kpi_desc_cc':
          'CC (Контакт с клиентом)\n\nЧем выше значение, тем лучше.\n\nКрайне важно:\nВы ДОЛЖНЫ ВСЕГДА отправлять сообщение "No safe location" или "Address not found", когда не можете доставить посылку, потому что:\n\n- клиента нет дома или\n- адрес не найден',

      'kpi_desc_cdf':
          'CDF DPMO (Обратная связь клиента по доставке)\n\nЧем ниже значение, тем лучше.\n\nУровень 1 (L1)\n- Клиент оценивает доставку как "Great" (👍) или "Not so good" (👎)\n\nУровень 2 (L2)\n- Дополнительная обратная связь, почему опыт был хорошим или плохим',

      'kpi_desc_ce':
          'CE (Эскалация клиента)\n\nЧем ниже значение, тем лучше.\nЭто худшая категория.\n\nКлиенты создают эскалацию, когда не соблюдаются инструкции по доставке.\n\nОтветственность всегда на водителе\nАпелляция почти невозможна без очень сильных доказательств\nИмеет самое сильное влияние на ваш Scorecard\n\nКак избежать CE\n\nОставлять посылки в небезопасных или бесконтрольных местах без одобрения запрещено правилами\n\nDelivery Associate обязан:\n- Позвонить в дверь / использовать домофон / постучать\n- Дать клиенту достаточно времени на ответ\n\nЕсли клиент недоступен и нет сохраненного безопасного места:\n- Позвонить клиенту дважды\n- Отправить сообщение\n- Связаться с Driver Support, если контакт невозможен\n\nПри необходимости:\n- Отсканировать как "Delivery failed - customer unavailable"\n- Повторить попытку доставки по правилам',

      'kpi_desc_dcr':
          'Чем выше значение, тем лучше. Для достижения 100% рекомендуется повторная попытка доставки* после неуспешной доставки.',

      'kpi_desc_dnr':
          'DSC DPMO (Условия успешной доставки)\n(ранее DNR - Delivery Not Received)\n\nЧем ниже значение, тем лучше.\n\nМетрика показывает, насколько корректно и прозрачно выполняются доставки.\n\nБазовые правила:\n- Доставка правильному получателю или в правильное место\n- Доставка клиенту, члену семьи, соседу или на ресепшн при корректном выполнении считается низкорисковой\n- Всегда используйте правильный scan/reason code, чтобы клиент получал корректные уведомления\n\nДоставка в mailroom/mailbox:\n- Следуйте стандартному workflow\n- Посылка должна полностью помещаться в mailbox/mail slot и не выступать наружу\n- Используйте наиболее точный доступный scan\n\nКорректный адрес и geofence:\n- Доставка в пределах 25 метров от корректного geofence\n- Всегда сверяйте имя и адрес в приложении с этикеткой и зданием\n- Если geocode выглядит неверно, сообщите через SDS\n\nФото при доставке (POD):\n- Всегда делайте четкое фото при запросе\n- Посылка и окружение должны быть хорошо видны\n- Особенно важно для бесконтактных доставок и доверия клиента\n\nСледование предпочтениям доставки:\n- Следуйте инструкциям клиента в приложении, если это безопасно\n- Если инструкции небезопасны, свяжитесь с клиентом\n- Используйте только одобренные безопасные места из приложения\n\nОдновременные/групповые стопы:\n- Используйте "Select all" только если несколько посылок доставляются одному получателю/в одно место\n- Корректно фиксируйте имя получателя и подпись',

      'kpi_desc_lor':
          'LoR (Потеряно в пути)\n\nЧем ниже значение, тем лучше.\n\nМетрика показывает, корректно ли учтены все недоставленные посылки в конце маршрута.\n\nВ конце маршрута:\n- Проверьте в scanner, сколько посылок нужно вернуть\n- Убедитесь, что это число точно совпадает с посылками в автомобиле',

      'kpi_desc_pod':
          'PoD (Фото при доставке)\n\nЧем выше значение, тем лучше.\n\nЭта колонка показывает посылки, по которым фото было сделано, но помечено как Invalid или Unsafe.\n\nРаспространенные причины отклонения POD:\n1. На фото видна этикетка с данными клиента (посылку нужно перевернуть)\n2. Размытое фото\n3. В кадре виден человек\n4. На фото не видно посылки\n5. Посылка внутри автомобиля\n6. Посылка в руке\n7. Посылка слишком близко к камере\n8. Фото слишком темное',

      'kpi_tip_cc':
          'В приложении есть автоматическое стандартное сообщение для каждого сценария.',

      'kpi_tip_cdf': 'CDF рассчитывается исключительно на уровне L1',

      // Month names (long)
      'kpi_tip_ce':
          'Не оставляйте посылки в небезопасных или неутвержденных местах\nВсегда соблюдайте правильные процессы отправки и доставки',
      'kpi_tip_dcr':
          'Пример: если вы не смогли доставить посылку в первой попытке, но попытались снова в тот же день, показатель DCR будет выше и ближе к 100%, даже если вторая попытка тоже неудачна.',

      'kpi_tip_dnr':
          'Важно:\n\nПовторяющиеся высокие значения DSC DPMO указывают на некорректные или рискованные доставки.\n\n- Частые отклонения могут трактоваться Amazon как возможный риск кражи\n- Это может запустить процесс loss prevention\n- В худшем случае возможно прекращение сотрудничества\n\nТочные сканы, корректные фото и соблюдение правил защищают вас и вашу команду.',

      'kpi_tip_lor':
          'Важно:\n\nЭто категория с самым высоким риском подозрения на кражу.\n\nНесоответствия между данными scanner и фактическими посылками в авто считаются серьезной ошибкой и могут привести к внутренней проверке и другим последствиям.',

      'kpi_tip_pod':
          'Обычно это самая простая категория\nЦелевое значение: 100%\nСущественно улучшает общий score',
      'kpi_title_cc': 'Контакт с клиентом',
      'kpi_title_cdf': 'Обратная связь клиента по доставке',
      'kpi_title_ce': 'Эскалация клиента',

      'kpi_title_dcr': 'Уровень успешной доставки',
      'kpi_title_dnr': 'Условия успешной доставки',
      'kpi_title_lor': 'Потеряно в пути',
      'kpi_title_pod': 'Фото при доставке',
    },
  };

  static final Map<String, Map<String, String>>
  _driverNotificationLocalizedValues = {
    'en': {
      'driver_notification_confirmation_required': 'confirmation required',
      'driver_notification_confirmed': 'confirmed',
      'driver_notification_detail_title': 'Detail',
      'driver_notification_reading_confirmation': 'Reading confirmation',
      'driver_notification_confirm_success': 'Confirmed',
      'driver_notification_confirm_failed': 'Confirm failed: {error}',
      'driver_notification_mark_read_failed':
          'Failed to mark as read: {error}',
    },
    'de': {
      'driver_notification_confirmation_required':
          'Bestaetigung erforderlich',
      'driver_notification_confirmed': 'bestaetigt',
      'driver_notification_detail_title': 'Detail',
      'driver_notification_reading_confirmation': 'Lesebestaetigung',
      'driver_notification_confirm_success': 'Bestaetigt',
      'driver_notification_confirm_failed':
          'Bestaetigung fehlgeschlagen: {error}',
      'driver_notification_mark_read_failed':
          'Als gelesen markieren fehlgeschlagen: {error}',
    },
    'sq': {
      'driver_notification_confirmation_required': 'konfirmimi kerkohet',
      'driver_notification_confirmed': 'konfirmuar',
      'driver_notification_detail_title': 'Detaje',
      'driver_notification_reading_confirmation': 'Konfirmimi i leximit',
      'driver_notification_confirm_success': 'U konfirmua',
      'driver_notification_confirm_failed': 'Konfirmimi deshtoi: {error}',
      'driver_notification_mark_read_failed':
          'Shenjimi si i lexuar deshtoi: {error}',
    },
    'hu': {
      'driver_notification_confirmation_required':
          'megerosites szukseges',
      'driver_notification_confirmed': 'megerositve',
      'driver_notification_detail_title': 'Reszletek',
      'driver_notification_reading_confirmation': 'Olvasas megerositese',
      'driver_notification_confirm_success': 'Megerositve',
      'driver_notification_confirm_failed':
          'A megerosites sikertelen: {error}',
      'driver_notification_mark_read_failed':
          'Sikertelen olvasottkent jeloles: {error}',
    },
    'ro': {
      'driver_notification_confirmation_required': 'confirmare necesara',
      'driver_notification_confirmed': 'confirmat',
      'driver_notification_detail_title': 'Detalii',
      'driver_notification_reading_confirmation': 'Confirmare citire',
      'driver_notification_confirm_success': 'Confirmat',
      'driver_notification_confirm_failed':
          'Confirmarea a esuat: {error}',
      'driver_notification_mark_read_failed':
          'Marcarea ca citit a esuat: {error}',
    },
    'hr': {
      'driver_notification_confirmation_required': 'potvrda je potrebna',
      'driver_notification_confirmed': 'potvrdeno',
      'driver_notification_detail_title': 'Detalji',
      'driver_notification_reading_confirmation': 'Potvrda citanja',
      'driver_notification_confirm_success': 'Potvrdeno',
      'driver_notification_confirm_failed': 'Potvrda nije uspjela: {error}',
      'driver_notification_mark_read_failed':
          'Oznacavanje kao procitano nije uspjelo: {error}',
    },
    'ar': {
      'driver_notification_confirmation_required': 'التأكيد مطلوب',
      'driver_notification_confirmed': 'تم التأكيد',
      'driver_notification_detail_title': 'التفاصيل',
      'driver_notification_reading_confirmation': 'تأكيد القراءة',
      'driver_notification_confirm_success': 'تم التأكيد',
      'driver_notification_confirm_failed': 'فشل التأكيد: {error}',
      'driver_notification_mark_read_failed':
          'فشل تعليم الإشعار كمقروء: {error}',
    },
    'tr': {
      'driver_notification_confirmation_required': 'onay gerekli',
      'driver_notification_confirmed': 'onaylandi',
      'driver_notification_detail_title': 'Detay',
      'driver_notification_reading_confirmation': 'Okuma onayi',
      'driver_notification_confirm_success': 'Onaylandi',
      'driver_notification_confirm_failed': 'Onay basarisiz: {error}',
      'driver_notification_mark_read_failed':
          'Okundu olarak isaretleme basarisiz: {error}',
    },
    'ru': {
      'driver_notification_confirmation_required': 'требуется подтверждение',
      'driver_notification_confirmed': 'подтверждено',
      'driver_notification_detail_title': 'Детали',
      'driver_notification_reading_confirmation': 'Подтверждение прочтения',
      'driver_notification_confirm_success': 'Подтверждено',
      'driver_notification_confirm_failed':
          'Не удалось подтвердить: {error}',
      'driver_notification_mark_read_failed':
          'Не удалось отметить как прочитано: {error}',
    },
  };

  static final Map<String, Map<String, String>> _driverAbsenceLocalizedValues = {
    'en': {
      'driver_absence_page_eyebrow': 'Absence',
      'driver_absence_overview_title': 'Absence overview',
      'driver_absence_periods_title': 'Requested periods',
      'driver_absence_total_label': 'Total',
      'driver_absence_special_label': 'Special leave',
      'driver_absence_taken_label': 'Taken',
      'driver_absence_available_vacation_label': 'Available vacation',
      'driver_absence_start_label': 'Start',
      'driver_absence_end_label': 'End',
      'driver_absence_days_label': 'Days',
      'driver_absence_day_label': 'day',
      'driver_absence_days_per_year': 'days / year',
      'driver_absence_of_word': 'of',
      'driver_absence_request_button': 'Request absence',
      'driver_absence_request_sheet_title': 'New absence request',
      'driver_absence_type_label': 'Type',
      'driver_absence_vacation_type': 'Vacation',
      'driver_absence_sick_leave_type': 'Sick leave',
      'driver_absence_from_label': 'From',
      'driver_absence_to_label': 'To',
      'driver_absence_reason_label': 'Reason',
      'driver_absence_reason_hint': 'Enter a short reason',
      'driver_absence_submit_label': 'Submit request',
      'driver_absence_submitting_label': 'Submitting...',
      'driver_absence_empty_vacation_list': 'No absence requests yet.',
      'driver_absence_submit_success': 'Absence request submitted.',
      'driver_absence_login_required': 'You must be logged in.',
      'driver_absence_scope_missing': 'Driver scope is missing.',
      'driver_absence_pick_date_validation': 'Please select both dates.',
      'driver_absence_reason_validation': 'Please enter a reason.',
      'driver_absence_available_vacation_hint_label': 'Available vacation',
      'driver_absence_vacation_limit_exceeded_template':
          'Requested {requested} days, but only {available} are available.',
      'driver_absence_submit_failed_template': 'Submit failed: {error}',
      'driver_absence_load_failed_template':
          'Failed to load absence data: {error}',
    },
    'de': {
      'driver_absence_page_eyebrow': 'Abwesenheit',
      'driver_absence_overview_title': 'Abwesenheitsuebersicht',
      'driver_absence_periods_title': 'Beantragte Zeitraeume',
      'driver_absence_total_label': 'Gesamt',
      'driver_absence_special_label': 'Sonderurlaub',
      'driver_absence_taken_label': 'Genommen',
      'driver_absence_available_vacation_label': 'Verfuegbarer Urlaub',
      'driver_absence_start_label': 'Start',
      'driver_absence_end_label': 'Ende',
      'driver_absence_days_label': 'Tage',
      'driver_absence_day_label': 'Tag',
      'driver_absence_days_per_year': 'Tage / Jahr',
      'driver_absence_of_word': 'von',
      'driver_absence_request_button': 'Abwesenheit beantragen',
      'driver_absence_request_sheet_title': 'Neue Abwesenheitsanfrage',
      'driver_absence_type_label': 'Typ',
      'driver_absence_vacation_type': 'Urlaub',
      'driver_absence_sick_leave_type': 'Krankmeldung',
      'driver_absence_from_label': 'Von',
      'driver_absence_to_label': 'Bis',
      'driver_absence_reason_label': 'Grund',
      'driver_absence_reason_hint': 'Kurzen Grund eingeben',
      'driver_absence_submit_label': 'Anfrage senden',
      'driver_absence_submitting_label': 'Wird gesendet...',
      'driver_absence_empty_vacation_list':
          'Noch keine Abwesenheitsanfragen.',
      'driver_absence_submit_success': 'Abwesenheitsanfrage gesendet.',
      'driver_absence_login_required': 'Du musst angemeldet sein.',
      'driver_absence_scope_missing': 'Fahrerbereich fehlt.',
      'driver_absence_pick_date_validation':
          'Bitte waehle beide Daten aus.',
      'driver_absence_reason_validation': 'Bitte gib einen Grund ein.',
      'driver_absence_available_vacation_hint_label': 'Verfuegbarer Urlaub',
      'driver_absence_vacation_limit_exceeded_template':
          '{requested} Tage angefragt, aber nur {available} verfuegbar.',
      'driver_absence_submit_failed_template':
          'Senden fehlgeschlagen: {error}',
      'driver_absence_load_failed_template':
          'Laden der Abwesenheitsdaten fehlgeschlagen: {error}',
    },
    'sq': {
      'driver_absence_page_eyebrow': 'Mungesa',
      'driver_absence_overview_title': 'Permbledhje e mungesave',
      'driver_absence_periods_title': 'Periudhat e kerkuara',
      'driver_absence_total_label': 'Totali',
      'driver_absence_special_label': 'Leje speciale',
      'driver_absence_taken_label': 'Te marra',
      'driver_absence_available_vacation_label': 'Pushime te disponueshme',
      'driver_absence_start_label': 'Fillimi',
      'driver_absence_end_label': 'Fundi',
      'driver_absence_days_label': 'Dite',
      'driver_absence_day_label': 'dite',
      'driver_absence_days_per_year': 'dite / vit',
      'driver_absence_of_word': 'nga',
      'driver_absence_request_button': 'Kerko mungese',
      'driver_absence_request_sheet_title': 'Kerkese e re per mungese',
      'driver_absence_type_label': 'Lloji',
      'driver_absence_vacation_type': 'Pushim',
      'driver_absence_sick_leave_type': 'Leje mjekesore',
      'driver_absence_from_label': 'Nga',
      'driver_absence_to_label': 'Deri',
      'driver_absence_reason_label': 'Arsyeja',
      'driver_absence_reason_hint': 'Shkruani nje arsye te shkurter',
      'driver_absence_submit_label': 'Dergo kerkesen',
      'driver_absence_submitting_label': 'Duke u derguar...',
      'driver_absence_empty_vacation_list':
          'Ende nuk ka kerkesa per mungese.',
      'driver_absence_submit_success': 'Kerkesa per mungese u dergua.',
      'driver_absence_login_required': 'Duhet te jesh i kycur.',
      'driver_absence_scope_missing': 'Mungon konteksti i shoferit.',
      'driver_absence_pick_date_validation':
          'Ju lutem zgjidhni te dy datat.',
      'driver_absence_reason_validation':
          'Ju lutem shkruani nje arsye.',
      'driver_absence_available_vacation_hint_label':
          'Pushime te disponueshme',
      'driver_absence_vacation_limit_exceeded_template':
          'U kerkuan {requested} dite, por vetem {available} jane ne dispozicion.',
      'driver_absence_submit_failed_template': 'Dergimi deshtoi: {error}',
      'driver_absence_load_failed_template':
          'Ngarkimi i te dhenave te mungeses deshtoi: {error}',
    },
    'hu': {
      'driver_absence_page_eyebrow': 'Tavollet',
      'driver_absence_overview_title': 'Tavollet attekintes',
      'driver_absence_periods_title': 'Igenyelt idoszakok',
      'driver_absence_total_label': 'Osszesen',
      'driver_absence_special_label': 'Kulonleges szabadsag',
      'driver_absence_taken_label': 'Kivett',
      'driver_absence_available_vacation_label': 'Elerheto szabadsag',
      'driver_absence_start_label': 'Kezdet',
      'driver_absence_end_label': 'Vege',
      'driver_absence_days_label': 'Napok',
      'driver_absence_day_label': 'nap',
      'driver_absence_days_per_year': 'nap / ev',
      'driver_absence_of_word': 'bol',
      'driver_absence_request_button': 'Tavollet igenylese',
      'driver_absence_request_sheet_title': 'Uj tavolleti kerelem',
      'driver_absence_type_label': 'Tipus',
      'driver_absence_vacation_type': 'Szabadsag',
      'driver_absence_sick_leave_type': 'Betegszabadsag',
      'driver_absence_from_label': 'Tol',
      'driver_absence_to_label': 'Ig',
      'driver_absence_reason_label': 'Indok',
      'driver_absence_reason_hint': 'Adj meg rovid indokot',
      'driver_absence_submit_label': 'Kerelem kuldese',
      'driver_absence_submitting_label': 'Kuldes...',
      'driver_absence_empty_vacation_list':
          'Meg nincsenek tavolleti kerelmek.',
      'driver_absence_submit_success': 'A tavolleti kerelem elkuldve.',
      'driver_absence_login_required': 'Be kell jelentkezned.',
      'driver_absence_scope_missing': 'A sofor kontextusa hianyzik.',
      'driver_absence_pick_date_validation':
          'Kerlek valaszd ki mindket datumot.',
      'driver_absence_reason_validation': 'Kerlek adj meg indokot.',
      'driver_absence_available_vacation_hint_label': 'Elerheto szabadsag',
      'driver_absence_vacation_limit_exceeded_template':
          '{requested} nap lett igenyelve, de csak {available} erheto el.',
      'driver_absence_submit_failed_template':
          'Kuldes sikertelen: {error}',
      'driver_absence_load_failed_template':
          'A tavolleti adatok betoltese sikertelen: {error}',
    },
    'ro': {
      'driver_absence_page_eyebrow': 'Absenta',
      'driver_absence_overview_title': 'Prezentare absente',
      'driver_absence_periods_title': 'Perioade solicitate',
      'driver_absence_total_label': 'Total',
      'driver_absence_special_label': 'Concediu special',
      'driver_absence_taken_label': 'Efectuate',
      'driver_absence_available_vacation_label': 'Vacanta disponibila',
      'driver_absence_start_label': 'Inceput',
      'driver_absence_end_label': 'Sfarsit',
      'driver_absence_days_label': 'Zile',
      'driver_absence_day_label': 'zi',
      'driver_absence_days_per_year': 'zile / an',
      'driver_absence_of_word': 'din',
      'driver_absence_request_button': 'Solicita absenta',
      'driver_absence_request_sheet_title': 'Cerere noua de absenta',
      'driver_absence_type_label': 'Tip',
      'driver_absence_vacation_type': 'Vacanta',
      'driver_absence_sick_leave_type': 'Concediu medical',
      'driver_absence_from_label': 'De la',
      'driver_absence_to_label': 'Pana la',
      'driver_absence_reason_label': 'Motiv',
      'driver_absence_reason_hint': 'Introdu un motiv scurt',
      'driver_absence_submit_label': 'Trimite cererea',
      'driver_absence_submitting_label': 'Se trimite...',
      'driver_absence_empty_vacation_list': 'Nu exista cereri de absenta inca.',
      'driver_absence_submit_success': 'Cererea de absenta a fost trimisa.',
      'driver_absence_login_required': 'Trebuie sa fii autentificat.',
      'driver_absence_scope_missing': 'Lipseste contextul soferului.',
      'driver_absence_pick_date_validation':
          'Te rugam selecteaza ambele date.',
      'driver_absence_reason_validation':
          'Te rugam introdu un motiv.',
      'driver_absence_available_vacation_hint_label': 'Vacanta disponibila',
      'driver_absence_vacation_limit_exceeded_template':
          'Au fost cerute {requested} zile, dar doar {available} sunt disponibile.',
      'driver_absence_submit_failed_template':
          'Trimiterea a esuat: {error}',
      'driver_absence_load_failed_template':
          'Incarcarea datelor de absenta a esuat: {error}',
    },
    'hr': {
      'driver_absence_page_eyebrow': 'Odsutnost',
      'driver_absence_overview_title': 'Pregled odsutnosti',
      'driver_absence_periods_title': 'Zatrazena razdoblja',
      'driver_absence_total_label': 'Ukupno',
      'driver_absence_special_label': 'Posebni dopust',
      'driver_absence_taken_label': 'Iskoristeno',
      'driver_absence_available_vacation_label': 'Dostupan godisnji odmor',
      'driver_absence_start_label': 'Pocetak',
      'driver_absence_end_label': 'Kraj',
      'driver_absence_days_label': 'Dani',
      'driver_absence_day_label': 'dan',
      'driver_absence_days_per_year': 'dana / godina',
      'driver_absence_of_word': 'od',
      'driver_absence_request_button': 'Zatrazi odsutnost',
      'driver_absence_request_sheet_title': 'Novi zahtjev za odsutnost',
      'driver_absence_type_label': 'Vrsta',
      'driver_absence_vacation_type': 'Godisnji odmor',
      'driver_absence_sick_leave_type': 'Bolovanje',
      'driver_absence_from_label': 'Od',
      'driver_absence_to_label': 'Do',
      'driver_absence_reason_label': 'Razlog',
      'driver_absence_reason_hint': 'Unesite kratak razlog',
      'driver_absence_submit_label': 'Posalji zahtjev',
      'driver_absence_submitting_label': 'Slanje...',
      'driver_absence_empty_vacation_list':
          'Jos nema zahtjeva za odsutnost.',
      'driver_absence_submit_success': 'Zahtjev za odsutnost je poslan.',
      'driver_absence_login_required': 'Morate biti prijavljeni.',
      'driver_absence_scope_missing': 'Nedostaje kontekst vozaca.',
      'driver_absence_pick_date_validation': 'Odaberite oba datuma.',
      'driver_absence_reason_validation': 'Unesite razlog.',
      'driver_absence_available_vacation_hint_label':
          'Dostupan godisnji odmor',
      'driver_absence_vacation_limit_exceeded_template':
          'Zatrazeno je {requested} dana, ali dostupno je samo {available}.',
      'driver_absence_submit_failed_template':
          'Slanje nije uspjelo: {error}',
      'driver_absence_load_failed_template':
          'Ucitavanje podataka o odsutnosti nije uspjelo: {error}',
    },
    'ar': {
      'driver_absence_page_eyebrow': 'الغياب',
      'driver_absence_overview_title': 'نظرة عامة على الغياب',
      'driver_absence_periods_title': 'الفترات المطلوبة',
      'driver_absence_total_label': 'الإجمالي',
      'driver_absence_special_label': 'إجازة خاصة',
      'driver_absence_taken_label': 'المستخدم',
      'driver_absence_available_vacation_label': 'الإجازة المتاحة',
      'driver_absence_start_label': 'البداية',
      'driver_absence_end_label': 'النهاية',
      'driver_absence_days_label': 'الأيام',
      'driver_absence_day_label': 'يوم',
      'driver_absence_days_per_year': 'يوم / سنة',
      'driver_absence_of_word': 'من',
      'driver_absence_request_button': 'طلب غياب',
      'driver_absence_request_sheet_title': 'طلب غياب جديد',
      'driver_absence_type_label': 'النوع',
      'driver_absence_vacation_type': 'إجازة',
      'driver_absence_sick_leave_type': 'إجازة مرضية',
      'driver_absence_from_label': 'من',
      'driver_absence_to_label': 'إلى',
      'driver_absence_reason_label': 'السبب',
      'driver_absence_reason_hint': 'اكتب سببًا قصيرًا',
      'driver_absence_submit_label': 'إرسال الطلب',
      'driver_absence_submitting_label': 'جارٍ الإرسال...',
      'driver_absence_empty_vacation_list': 'لا توجد طلبات غياب بعد.',
      'driver_absence_submit_success': 'تم إرسال طلب الغياب.',
      'driver_absence_login_required': 'يجب تسجيل الدخول.',
      'driver_absence_scope_missing': 'نطاق السائق مفقود.',
      'driver_absence_pick_date_validation':
          'يرجى اختيار التاريخين.',
      'driver_absence_reason_validation': 'يرجى إدخال سبب.',
      'driver_absence_available_vacation_hint_label': 'الإجازة المتاحة',
      'driver_absence_vacation_limit_exceeded_template':
          'تم طلب {requested} يومًا ولكن المتاح فقط {available}.',
      'driver_absence_submit_failed_template': 'فشل الإرسال: {error}',
      'driver_absence_load_failed_template':
          'فشل تحميل بيانات الغياب: {error}',
    },
    'tr': {
      'driver_absence_page_eyebrow': 'Devamsizlik',
      'driver_absence_overview_title': 'Devamsizlik ozeti',
      'driver_absence_periods_title': 'Talep edilen donemler',
      'driver_absence_total_label': 'Toplam',
      'driver_absence_special_label': 'Ozel izin',
      'driver_absence_taken_label': 'Kullanilan',
      'driver_absence_available_vacation_label': 'Mevcut izin',
      'driver_absence_start_label': 'Baslangic',
      'driver_absence_end_label': 'Bitis',
      'driver_absence_days_label': 'Gunler',
      'driver_absence_day_label': 'gun',
      'driver_absence_days_per_year': 'gun / yil',
      'driver_absence_of_word': 'den',
      'driver_absence_request_button': 'Devamsizlik talep et',
      'driver_absence_request_sheet_title': 'Yeni devamsizlik talebi',
      'driver_absence_type_label': 'Tur',
      'driver_absence_vacation_type': 'Izin',
      'driver_absence_sick_leave_type': 'Hastalik izni',
      'driver_absence_from_label': 'Baslangic',
      'driver_absence_to_label': 'Bitis',
      'driver_absence_reason_label': 'Neden',
      'driver_absence_reason_hint': 'Kisa bir neden girin',
      'driver_absence_submit_label': 'Talebi gonder',
      'driver_absence_submitting_label': 'Gonderiliyor...',
      'driver_absence_empty_vacation_list':
          'Henuz devamsizlik talebi yok.',
      'driver_absence_submit_success': 'Devamsizlik talebi gonderildi.',
      'driver_absence_login_required': 'Giris yapmis olmalisin.',
      'driver_absence_scope_missing': 'Surucu kapsami eksik.',
      'driver_absence_pick_date_validation':
          'Lutfen iki tarihi de secin.',
      'driver_absence_reason_validation': 'Lutfen bir neden girin.',
      'driver_absence_available_vacation_hint_label': 'Mevcut izin',
      'driver_absence_vacation_limit_exceeded_template':
          '{requested} gun talep edildi ancak sadece {available} gun mevcut.',
      'driver_absence_submit_failed_template':
          'Gonderim basarisiz: {error}',
      'driver_absence_load_failed_template':
          'Devamsizlik verileri yuklenemedi: {error}',
    },
    'ru': {
      'driver_absence_page_eyebrow': 'Отсутствие',
      'driver_absence_overview_title': 'Обзор отсутствий',
      'driver_absence_periods_title': 'Запрошенные периоды',
      'driver_absence_total_label': 'Итого',
      'driver_absence_special_label': 'Специальный отпуск',
      'driver_absence_taken_label': 'Использовано',
      'driver_absence_available_vacation_label': 'Доступный отпуск',
      'driver_absence_start_label': 'Начало',
      'driver_absence_end_label': 'Конец',
      'driver_absence_days_label': 'Дни',
      'driver_absence_day_label': 'день',
      'driver_absence_days_per_year': 'дней / год',
      'driver_absence_of_word': 'из',
      'driver_absence_request_button': 'Запросить отсутствие',
      'driver_absence_request_sheet_title': 'Новый запрос на отсутствие',
      'driver_absence_type_label': 'Тип',
      'driver_absence_vacation_type': 'Отпуск',
      'driver_absence_sick_leave_type': 'Больничный',
      'driver_absence_from_label': 'С',
      'driver_absence_to_label': 'По',
      'driver_absence_reason_label': 'Причина',
      'driver_absence_reason_hint': 'Введите короткую причину',
      'driver_absence_submit_label': 'Отправить запрос',
      'driver_absence_submitting_label': 'Отправка...',
      'driver_absence_empty_vacation_list':
          'Пока нет запросов на отсутствие.',
      'driver_absence_submit_success': 'Запрос на отсутствие отправлен.',
      'driver_absence_login_required': 'Вы должны войти в систему.',
      'driver_absence_scope_missing': 'Отсутствует контекст водителя.',
      'driver_absence_pick_date_validation':
          'Пожалуйста, выберите обе даты.',
      'driver_absence_reason_validation': 'Пожалуйста, укажите причину.',
      'driver_absence_available_vacation_hint_label': 'Доступный отпуск',
      'driver_absence_vacation_limit_exceeded_template':
          'Запрошено {requested} дней, но доступно только {available}.',
      'driver_absence_submit_failed_template':
          'Не удалось отправить запрос: {error}',
      'driver_absence_load_failed_template':
          'Не удалось загрузить данные об отсутствии: {error}',
    },
  };

  static final Map<String, Map<String, String>>
  _driverDashboardLocalizedValues = {
    'en': {
      'dash_compliance_safety': 'Compliance & Safety',
      'dash_delivery_quality_swc': 'Delivery Quality & SWC',
      'dash_company_threshold_hint': '{score}% out of {target}% minimum',
      'dash_company_threshold_met': '{score}% meets the {target}% threshold',
      'dash_company_section_safety': 'Safety',
      'dash_company_section_compliance': 'Compliance',
      'dash_company_section_customer_delivery_experience':
          'Customer Delivery Experience',
      'dash_company_section_quality': 'Quality',
      'dash_company_section_standard_work_compliance':
          'Standard Work Compliance',
      'dash_metric_fico': 'Safe Driving Metric (FICO)',
      'dash_metric_speeding_event_rate':
          'Speeding Event Rate (Per 100 Trips)',
      'dash_metric_mentor_adoption_rate': 'Mentor Adoption Rate',
      'dash_metric_vehicle_audit_compliance':
          'Vehicle Audit (VSA) Compliance',
      'dash_metric_breach_of_contract': 'Breach of Contract (BOC)',
      'dash_metric_working_hours_compliance':
          'Working Hours Compliance (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Comprehensive Audit Score (CAS)',
      'dash_metric_customer_escalation_dpmo': 'Customer Escalation DPMO',
      'dash_metric_customer_delivery_feedback': 'Customer Delivery Feedback',
      'dash_metric_delivery_completion_rate':
          'Delivery Completion Rate (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Photo-On-Delivery',
      'dash_metric_contact_compliance': 'Contact Compliance',
    },
    'de': {
      'dash_compliance_safety': 'Compliance & Sicherheit',
      'dash_delivery_quality_swc': 'Zustellqualitaet & SWC',
      'dash_company_threshold_hint': '{score}% von mindestens {target}%',
      'dash_company_threshold_met':
          '{score}% erfuellt den Schwellenwert von {target}%',
      'dash_company_section_safety': 'Sicherheit',
      'dash_company_section_compliance': 'Compliance',
      'dash_company_section_customer_delivery_experience':
          'Kundenerlebnis bei Zustellung',
      'dash_company_section_quality': 'Qualitaet',
      'dash_company_section_standard_work_compliance':
          'Standardarbeits-Compliance',
      'dash_metric_fico': 'Sicheres Fahrverhalten (FICO)',
      'dash_metric_speeding_event_rate':
          'Geschwindigkeitsrate (pro 100 Fahrten)',
      'dash_metric_mentor_adoption_rate': 'Mentor-Nutzungsrate',
      'dash_metric_vehicle_audit_compliance':
          'Fahrzeugaudit-Compliance (VSA)',
      'dash_metric_breach_of_contract': 'Vertragsverstoss (BOC)',
      'dash_metric_working_hours_compliance':
          'Arbeitszeit-Compliance (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Umfassender Audit-Score (CAS)',
      'dash_metric_customer_escalation_dpmo':
          'Kundeneskalation DPMO',
      'dash_metric_customer_delivery_feedback':
          'Kundenfeedback zur Zustellung',
      'dash_metric_delivery_completion_rate':
          'Zustellabschlussrate (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Foto bei Zustellung',
      'dash_metric_contact_compliance': 'Kontakt-Compliance',
    },
    'sq': {
      'dash_compliance_safety': 'Perputhshmeria & Siguria',
      'dash_delivery_quality_swc': 'Cilesia e dorezimit & SWC',
      'dash_company_threshold_hint': '{score}% nga minimumi {target}%',
      'dash_company_threshold_met': '{score}% arrin pragun {target}%',
      'dash_company_section_safety': 'Siguria',
      'dash_company_section_compliance': 'Perputhshmeria',
      'dash_company_section_customer_delivery_experience':
          'Pervoja e klientit ne dorezim',
      'dash_company_section_quality': 'Cilesia',
      'dash_company_section_standard_work_compliance':
          'Perputhshmeria me standardin e punes',
      'dash_metric_fico': 'Metrika e drejtimit te sigurt (FICO)',
      'dash_metric_speeding_event_rate':
          'Norma e shpejtesise (per 100 udhetime)',
      'dash_metric_mentor_adoption_rate': 'Shkalla e perdorimit te Mentor',
      'dash_metric_vehicle_audit_compliance':
          'Perputhshmeria e auditimit te automjetit (VSA)',
      'dash_metric_breach_of_contract': 'Shkelja e kontrates (BOC)',
      'dash_metric_working_hours_compliance':
          'Perputhshmeria e oreve te punes (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Rezultati i auditimit gjitheperfshires (CAS)',
      'dash_metric_customer_escalation_dpmo':
          'Pershkallezimi i klientit DPMO',
      'dash_metric_customer_delivery_feedback':
          'Reagimi i klientit per dorezimin',
      'dash_metric_delivery_completion_rate':
          'Norma e perfundimit te dorezimit (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Foto ne dorezim',
      'dash_metric_contact_compliance': 'Perputhshmeria e kontaktit',
    },
    'hu': {
      'dash_compliance_safety': 'Megfeleles & Biztonsag',
      'dash_delivery_quality_swc': 'Kezbesitesi minoseg & SWC',
      'dash_company_threshold_hint': '{score}% / minimum {target}%',
      'dash_company_threshold_met':
          '{score}% teljesiti a(z) {target}% kuszobot',
      'dash_company_section_safety': 'Biztonsag',
      'dash_company_section_compliance': 'Megfeleles',
      'dash_company_section_customer_delivery_experience':
          'Ugyfeleredmeny a kezbesitesnel',
      'dash_company_section_quality': 'Minoseg',
      'dash_company_section_standard_work_compliance':
          'Standard munka megfeleles',
      'dash_metric_fico': 'Biztonsagos vezetes mutato (FICO)',
      'dash_metric_speeding_event_rate':
          'Gyorshajtas esemenyrata (100 utankent)',
      'dash_metric_mentor_adoption_rate': 'Mentor hasznalati arany',
      'dash_metric_vehicle_audit_compliance':
          'Jarmuaudit-megfeleles (VSA)',
      'dash_metric_breach_of_contract': 'Szerzodesszeges (BOC)',
      'dash_metric_working_hours_compliance':
          'Munkaido-megfeleles (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Atfogo auditpontszam (CAS)',
      'dash_metric_customer_escalation_dpmo': 'Ugyfeleszkalacio DPMO',
      'dash_metric_customer_delivery_feedback':
          'Ugyfel visszajelzes a kezbesitesrol',
      'dash_metric_delivery_completion_rate':
          'Kezbesites befejezesi arany (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Foto kezbesiteskor',
      'dash_metric_contact_compliance': 'Kapcsolati megfeleles',
    },
    'ro': {
      'dash_compliance_safety': 'Conformitate & Siguranta',
      'dash_delivery_quality_swc': 'Calitatea livrarii & SWC',
      'dash_company_threshold_hint': '{score}% din minimul de {target}%',
      'dash_company_threshold_met':
          '{score}% atinge pragul de {target}%',
      'dash_company_section_safety': 'Siguranta',
      'dash_company_section_compliance': 'Conformitate',
      'dash_company_section_customer_delivery_experience':
          'Experienta clientului la livrare',
      'dash_company_section_quality': 'Calitate',
      'dash_company_section_standard_work_compliance':
          'Conformitate standard de lucru',
      'dash_metric_fico': 'Indicator de condus sigur (FICO)',
      'dash_metric_speeding_event_rate':
          'Rata de viteza (la 100 de curse)',
      'dash_metric_mentor_adoption_rate': 'Rata de utilizare Mentor',
      'dash_metric_vehicle_audit_compliance':
          'Conformitate audit vehicul (VSA)',
      'dash_metric_breach_of_contract': 'Incalcare contract (BOC)',
      'dash_metric_working_hours_compliance':
          'Conformitate ore de lucru (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Scor audit complet (CAS)',
      'dash_metric_customer_escalation_dpmo': 'Escaladare client DPMO',
      'dash_metric_customer_delivery_feedback':
          'Feedback clienti la livrare',
      'dash_metric_delivery_completion_rate':
          'Rata de finalizare a livrarii (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Fotografie la livrare',
      'dash_metric_contact_compliance': 'Conformitate contact',
    },
    'hr': {
      'dash_compliance_safety': 'Uskladenost & Sigurnost',
      'dash_delivery_quality_swc': 'Kvaliteta dostave & SWC',
      'dash_company_threshold_hint': '{score}% od minimuma {target}%',
      'dash_company_threshold_met':
          '{score}% doseze prag od {target}%',
      'dash_company_section_safety': 'Sigurnost',
      'dash_company_section_compliance': 'Uskladenost',
      'dash_company_section_customer_delivery_experience':
          'Iskustvo kupca pri dostavi',
      'dash_company_section_quality': 'Kvaliteta',
      'dash_company_section_standard_work_compliance':
          'Uskladenost sa standardnim radom',
      'dash_metric_fico': 'Mjera sigurne voznje (FICO)',
      'dash_metric_speeding_event_rate':
          'Stopa prekoracenja brzine (na 100 voznji)',
      'dash_metric_mentor_adoption_rate': 'Stopa koristenja Mentora',
      'dash_metric_vehicle_audit_compliance':
          'Uskladenost audita vozila (VSA)',
      'dash_metric_breach_of_contract': 'Krsenje ugovora (BOC)',
      'dash_metric_working_hours_compliance':
          'Uskladenost radnog vremena (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Sveobuhvatni rezultat audita (CAS)',
      'dash_metric_customer_escalation_dpmo':
          'Eskalacija korisnika DPMO',
      'dash_metric_customer_delivery_feedback':
          'Povratne informacije kupca o dostavi',
      'dash_metric_delivery_completion_rate':
          'Stopa dovrsenja dostave (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Fotografija pri dostavi',
      'dash_metric_contact_compliance': 'Uskladenost kontakta',
    },
    'ar': {
      'dash_compliance_safety': 'الالتزام والسلامة',
      'dash_delivery_quality_swc': 'جودة التسليم و SWC',
      'dash_company_threshold_hint': '{score}% من الحد الأدنى {target}%',
      'dash_company_threshold_met':
          '{score}% يحقق الحد الأدنى {target}%',
      'dash_company_section_safety': 'السلامة',
      'dash_company_section_compliance': 'الالتزام',
      'dash_company_section_customer_delivery_experience':
          'تجربة العميل في التسليم',
      'dash_company_section_quality': 'الجودة',
      'dash_company_section_standard_work_compliance':
          'الالتزام بمعايير العمل',
      'dash_metric_fico': 'مقياس القيادة الآمنة (FICO)',
      'dash_metric_speeding_event_rate':
          'معدل السرعة الزائدة (لكل 100 رحلة)',
      'dash_metric_mentor_adoption_rate': 'معدل استخدام Mentor',
      'dash_metric_vehicle_audit_compliance':
          'التزام تدقيق المركبة (VSA)',
      'dash_metric_breach_of_contract': 'خرق العقد (BOC)',
      'dash_metric_working_hours_compliance':
          'الالتزام بساعات العمل (WHC)',
      'dash_metric_comprehensive_audit_score':
          'درجة التدقيق الشاملة (CAS)',
      'dash_metric_customer_escalation_dpmo': 'تصعيد العميل DPMO',
      'dash_metric_customer_delivery_feedback':
          'ملاحظات العميل على التسليم',
      'dash_metric_delivery_completion_rate':
          'معدل إكمال التسليم (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'صورة عند التسليم',
      'dash_metric_contact_compliance': 'الالتزام بالتواصل',
    },
    'tr': {
      'dash_compliance_safety': 'Uyum & Guvenlik',
      'dash_delivery_quality_swc': 'Teslimat kalitesi & SWC',
      'dash_company_threshold_hint': '{score}% / minimum {target}%',
      'dash_company_threshold_met':
          '{score}% {target}% esigini karsiliyor',
      'dash_company_section_safety': 'Guvenlik',
      'dash_company_section_compliance': 'Uyum',
      'dash_company_section_customer_delivery_experience':
          'Musteri teslimat deneyimi',
      'dash_company_section_quality': 'Kalite',
      'dash_company_section_standard_work_compliance':
          'Standart calisma uyumu',
      'dash_metric_fico': 'Guvenli surus metrigi (FICO)',
      'dash_metric_speeding_event_rate':
          'Hiz asimi orani (100 yolculukta)',
      'dash_metric_mentor_adoption_rate': 'Mentor kullanim orani',
      'dash_metric_vehicle_audit_compliance':
          'Arac denetimi uyumu (VSA)',
      'dash_metric_breach_of_contract': 'Sozlesme ihlali (BOC)',
      'dash_metric_working_hours_compliance':
          'Calisma saati uyumu (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Kapsamli denetim skoru (CAS)',
      'dash_metric_customer_escalation_dpmo': 'Musteri eskalasyonu DPMO',
      'dash_metric_customer_delivery_feedback':
          'Musteri teslimat geri bildirimi',
      'dash_metric_delivery_completion_rate':
          'Teslimat tamamlama orani (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Teslimatta fotograf',
      'dash_metric_contact_compliance': 'Iletisim uyumu',
    },
    'ru': {
      'dash_compliance_safety': 'Соответствие и безопасность',
      'dash_delivery_quality_swc': 'Качество доставки и SWC',
      'dash_company_threshold_hint': '{score}% при минимуме {target}%',
      'dash_company_threshold_met':
          '{score}% соответствует порогу {target}%',
      'dash_company_section_safety': 'Безопасность',
      'dash_company_section_compliance': 'Соответствие',
      'dash_company_section_customer_delivery_experience':
          'Опыт клиента при доставке',
      'dash_company_section_quality': 'Качество',
      'dash_company_section_standard_work_compliance':
          'Соответствие стандартной работе',
      'dash_metric_fico': 'Показатель безопасного вождения (FICO)',
      'dash_metric_speeding_event_rate':
          'Частота превышения скорости (на 100 поездок)',
      'dash_metric_mentor_adoption_rate': 'Уровень использования Mentor',
      'dash_metric_vehicle_audit_compliance':
          'Соответствие аудиту транспорта (VSA)',
      'dash_metric_breach_of_contract': 'Нарушение контракта (BOC)',
      'dash_metric_working_hours_compliance':
          'Соответствие рабочим часам (WHC)',
      'dash_metric_comprehensive_audit_score':
          'Итоговый аудит-скор (CAS)',
      'dash_metric_customer_escalation_dpmo':
          'Эскалация клиента DPMO',
      'dash_metric_customer_delivery_feedback':
          'Отзыв клиента о доставке',
      'dash_metric_delivery_completion_rate':
          'Уровень завершения доставки (DCR)',
      'dash_metric_dnr_dpmo': 'DNR DPMO',
      'dash_metric_lor_dpmo': 'LoR DPMO',
      'dash_metric_dsc_dpmo': 'DSC DPMO',
      'dash_metric_photo_on_delivery': 'Фото при доставке',
      'dash_metric_contact_compliance': 'Соответствие контакту',
    },
  };

  static final Map<String, String> _notificationsSharedValues = {
    'notifications_page_title': 'Notifications',
    'notifications_page_new_content': 'NEW CONTENT | Notifications',
    'notifications_page_history': 'History',
    'notifications_page_publish': 'publish',
    'notifications_page_translation_preview': 'Translation preview',
    'notifications_page_translation_ready': 'Ready in {count} languages.',
    'notifications_page_title_hint': 'TITLE',
    'notifications_page_rule_message_hint': 'RULE / MESSAGE',
    'notifications_page_not_logged_in': 'Not logged in',
    'notifications_page_no_notifications': 'No notifications yet.',
    'notifications_page_error_generic': 'Error: {error}',
    'notifications_page_must_be_logged_in': 'You must be logged in.',
    'notifications_page_title_or_message_required':
        'Title or message is required.',
    'notifications_page_published_to_drivers': 'Published to {count} drivers.',
    'notifications_page_publish_failed': 'Publish failed: {error}',
    'notifications_page_popup_notification_fallback': 'Notification',
    'notifications_page_popup_driver_fallback': 'Driver',
    'notifications_page_not_confirmed_by': 'NOT CONFIRMED BY:',
    'notifications_page_missing_loading': 'missing: ...',
    'notifications_page_missing_unknown': 'missing: --',
    'notifications_page_missing_count': 'missing: {count}',
    'notifications_page_all_drivers_confirmed': 'All drivers have confirmed.',
    'notifications_page_close': 'Close',
    'notifications_page_time_suffix': '',
    'notifications_page_type_rule': 'New Rule',
    'notifications_page_type_message': 'New Message',
    'notifications_page_type_academy': 'DA Academy',
    'notifications_page_type_ride_along': 'Ride Along',
    'notifications_page_type_rule_badge': 'NEW RULE',
    'notifications_page_type_message_badge': 'NEW MESSAGE',
    'notifications_page_type_academy_badge': 'DA ACADEMY',
    'notifications_page_type_ride_along_badge': 'RIDE ALONG',
    'notifications_page_edit_rule': 'Edit rule',
    'notifications_page_field_title': 'Title',
    'notifications_page_field_body': 'Body',
    'notifications_page_cancel': 'Cancel',
    'notifications_page_save': 'Save',
    'notifications_page_title_or_body_required': 'Title or body is required.',
    'notifications_page_notification_not_found': 'Notification not found.',
    'notifications_page_rule_updated_for_drivers':
        'Rule updated for {count} drivers.',
    'notifications_page_edit_failed': 'Edit failed: {error}',
    'notifications_page_delete_question': 'Delete notification?',
    'notifications_page_delete_body':
        'This will delete this notification for you and for all drivers.',
    'notifications_page_delete': 'Delete',
    'notifications_page_notification_deleted': 'Notification deleted.',
    'notifications_page_delete_failed': 'Delete failed: {error}',
    'notifications_page_options': 'Options',
    'notifications_page_menu_edit_rule': 'Edit rule',
    'notifications_page_menu_delete': 'Delete',
    'notifications_page_title_fallback': 'TITLE',
    'notifications_page_confirmed_by': 'confirmed by',
  };

  static final Map<String, Map<String, String>>
  _notificationsLocalizedValues = {
    'en': _notificationsSharedValues,
    'de': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'Benachrichtigungen',
      'notifications_page_new_content': 'NEUER INHALT | Benachrichtigungen',
      'notifications_page_history': 'Verlauf',
      'notifications_page_publish': 'veroeffentlichen',
      'notifications_page_translation_preview': 'Uebersetzungsvorschau',
      'notifications_page_translation_ready': 'In {count} Sprachen bereit.',
      'notifications_page_title_hint': 'TITEL',
      'notifications_page_rule_message_hint': 'REGEL / NACHRICHT',
      'notifications_page_not_logged_in': 'Nicht angemeldet',
      'notifications_page_no_notifications': 'Noch keine Benachrichtigungen.',
      'notifications_page_must_be_logged_in': 'Du musst angemeldet sein.',
      'notifications_page_title_or_message_required':
          'Titel oder Nachricht ist erforderlich.',
      'notifications_page_published_to_drivers':
          'An {count} Fahrer veroeffentlicht.',
      'notifications_page_publish_failed':
          'Veroeffentlichen fehlgeschlagen: {error}',
      'notifications_page_popup_notification_fallback': 'Benachrichtigung',
      'notifications_page_popup_driver_fallback': 'Fahrer',
      'notifications_page_not_confirmed_by': 'NICHT BESTAETIGT VON:',
      'notifications_page_missing_loading': 'fehlt: ...',
      'notifications_page_missing_unknown': 'fehlt: --',
      'notifications_page_missing_count': 'fehlt: {count}',
      'notifications_page_all_drivers_confirmed':
          'Alle Fahrer haben bestaetigt.',
      'notifications_page_close': 'Schliessen',
      'notifications_page_time_suffix': 'Uhr',
      'notifications_page_type_rule': 'Neue Regel',
      'notifications_page_type_message': 'Neue Nachricht',
      'notifications_page_type_academy': 'DA Academy',
      'notifications_page_type_ride_along': 'Ride Along',
      'notifications_page_type_rule_badge': 'NEUE REGEL',
      'notifications_page_type_message_badge': 'NEUE NACHRICHT',
      'notifications_page_edit_rule': 'Regel bearbeiten',
      'notifications_page_field_title': 'Titel',
      'notifications_page_field_body': 'Inhalt',
      'notifications_page_cancel': 'Abbrechen',
      'notifications_page_save': 'Speichern',
      'notifications_page_title_or_body_required':
          'Titel oder Inhalt ist erforderlich.',
      'notifications_page_notification_not_found':
          'Benachrichtigung nicht gefunden.',
      'notifications_page_rule_updated_for_drivers':
          'Regel fuer {count} Fahrer aktualisiert.',
      'notifications_page_edit_failed': 'Bearbeiten fehlgeschlagen: {error}',
      'notifications_page_delete_question': 'Benachrichtigung loeschen?',
      'notifications_page_delete_body':
          'Dies loescht diese Benachrichtigung fuer dich und alle Fahrer.',
      'notifications_page_delete': 'Loeschen',
      'notifications_page_notification_deleted': 'Benachrichtigung geloescht.',
      'notifications_page_delete_failed': 'Loeschen fehlgeschlagen: {error}',
      'notifications_page_options': 'Optionen',
      'notifications_page_menu_edit_rule': 'Regel bearbeiten',
      'notifications_page_menu_delete': 'Loeschen',
      'notifications_page_title_fallback': 'TITEL',
      'notifications_page_confirmed_by': 'bestaetigt von',
    },
    'sq': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'Njoftimet',
      'notifications_page_new_content': 'PERMBAJTJE E RE | Njoftimet',
      'notifications_page_history': 'Historiku',
      'notifications_page_publish': 'publiko',
      'notifications_page_translation_preview': 'Pamje paraprake e perkthimit',
      'notifications_page_translation_ready': 'Gati ne {count} gjuhe.',
      'notifications_page_title_hint': 'TITULLI',
      'notifications_page_rule_message_hint': 'RREGULL / MESAZH',
      'notifications_page_not_logged_in': 'Nuk je i kycur',
      'notifications_page_no_notifications': 'Ende nuk ka njoftime.',
      'notifications_page_must_be_logged_in': 'Duhet te jesh i kycur.',
      'notifications_page_title_or_message_required':
          'Titulli ose mesazhi eshte i detyrueshem.',
      'notifications_page_published_to_drivers':
          'U publikua per {count} shofera.',
      'notifications_page_publish_failed': 'Publikimi deshtoi: {error}',
      'notifications_page_popup_notification_fallback': 'Njoftim',
      'notifications_page_popup_driver_fallback': 'Shofer',
      'notifications_page_not_confirmed_by': 'NUK ESHTE KONFIRMUAR NGA:',
      'notifications_page_missing_loading': 'mungojne: ...',
      'notifications_page_missing_unknown': 'mungojne: --',
      'notifications_page_missing_count': 'mungojne: {count}',
      'notifications_page_all_drivers_confirmed':
          'Te gjithe shoferet kane konfirmuar.',
      'notifications_page_close': 'Mbyll',
      'notifications_page_type_rule': 'Rregull i ri',
      'notifications_page_type_message': 'Mesazh i ri',
      'notifications_page_type_academy': 'DA Academy',
      'notifications_page_type_ride_along': 'Ride Along',
      'notifications_page_type_rule_badge': 'RREGULL I RI',
      'notifications_page_type_message_badge': 'MESAZH I RI',
      'notifications_page_edit_rule': 'Ndrysho rregullin',
      'notifications_page_field_title': 'Titulli',
      'notifications_page_field_body': 'Permbajtja',
      'notifications_page_cancel': 'Anulo',
      'notifications_page_save': 'Ruaj',
      'notifications_page_title_or_body_required':
          'Titulli ose permbajtja eshte e detyrueshme.',
      'notifications_page_notification_not_found': 'Njoftimi nuk u gjet.',
      'notifications_page_rule_updated_for_drivers':
          'Rregulli u perditesua per {count} shofera.',
      'notifications_page_edit_failed': 'Perditesimi deshtoi: {error}',
      'notifications_page_delete_question': 'Te fshihet njoftimi?',
      'notifications_page_delete_body':
          'Kjo do ta fshije kete njoftim per ju dhe per te gjithe shoferet.',
      'notifications_page_delete': 'Fshi',
      'notifications_page_notification_deleted': 'Njoftimi u fshi.',
      'notifications_page_delete_failed': 'Fshirja deshtoi: {error}',
      'notifications_page_options': 'Opsionet',
      'notifications_page_menu_edit_rule': 'Ndrysho rregullin',
      'notifications_page_menu_delete': 'Fshi',
      'notifications_page_title_fallback': 'TITULLI',
      'notifications_page_confirmed_by': 'konfirmuar nga',
    },
    'hu': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'Ertesitesek',
      'notifications_page_new_content': 'UJ TARTALOM | Ertesitesek',
      'notifications_page_history': 'Elozmenyek',
      'notifications_page_publish': 'kozzetesz',
      'notifications_page_translation_preview': 'Forditasi elonezet',
      'notifications_page_translation_ready': '{count} nyelven kesz.',
      'notifications_page_title_hint': 'CIM',
      'notifications_page_rule_message_hint': 'SZABALY / UZENET',
      'notifications_page_not_logged_in': 'Nincs bejelentkezve',
      'notifications_page_no_notifications': 'Meg nincsenek ertesitesek.',
      'notifications_page_must_be_logged_in': 'Be kell jelentkezned.',
      'notifications_page_title_or_message_required':
          'A cim vagy uzenet kotelezo.',
      'notifications_page_published_to_drivers': '{count} sofornek kozzeteve.',
      'notifications_page_publish_failed': 'Kozzetetel sikertelen: {error}',
      'notifications_page_popup_notification_fallback': 'Ertesites',
      'notifications_page_popup_driver_fallback': 'Sofor',
      'notifications_page_not_confirmed_by': 'NEM EROSITETTE MEG:',
      'notifications_page_missing_loading': 'hianyzik: ...',
      'notifications_page_missing_unknown': 'hianyzik: --',
      'notifications_page_missing_count': 'hianyzik: {count}',
      'notifications_page_all_drivers_confirmed': 'Minden sofor megerositette.',
      'notifications_page_close': 'Bezaras',
      'notifications_page_type_rule': 'Uj szabaly',
      'notifications_page_type_message': 'Uj uzenet',
      'notifications_page_type_academy': 'DA Academy',
      'notifications_page_type_ride_along': 'Ride Along',
      'notifications_page_type_rule_badge': 'UJ SZABALY',
      'notifications_page_type_message_badge': 'UJ UZENET',
      'notifications_page_edit_rule': 'Szabaly szerkesztese',
      'notifications_page_field_title': 'Cim',
      'notifications_page_field_body': 'Tartalom',
      'notifications_page_cancel': 'Megse',
      'notifications_page_save': 'Mentes',
      'notifications_page_title_or_body_required':
          'A cim vagy tartalom kotelezo.',
      'notifications_page_notification_not_found': 'Ertesites nem talalhato.',
      'notifications_page_rule_updated_for_drivers':
          'A szabaly {count} sofornel frissult.',
      'notifications_page_edit_failed': 'Szerkesztes sikertelen: {error}',
      'notifications_page_delete_question': 'Ertesites torlese?',
      'notifications_page_delete_body':
          'Ez torli ezt az ertesitest neked es minden sofornek.',
      'notifications_page_delete': 'Torles',
      'notifications_page_notification_deleted': 'Ertesites torolve.',
      'notifications_page_delete_failed': 'Torles sikertelen: {error}',
      'notifications_page_options': 'Opcio',
      'notifications_page_menu_edit_rule': 'Szabaly szerkesztese',
      'notifications_page_menu_delete': 'Torles',
      'notifications_page_title_fallback': 'CIM',
      'notifications_page_confirmed_by': 'megerositette',
    },
    'ro': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'Notificari',
      'notifications_page_new_content': 'CONTINUT NOU | Notificari',
      'notifications_page_history': 'Istoric',
      'notifications_page_publish': 'publica',
      'notifications_page_translation_preview': 'Previzualizare traduceri',
      'notifications_page_translation_ready': 'Pregatit in {count} limbi.',
      'notifications_page_title_hint': 'TITLU',
      'notifications_page_rule_message_hint': 'REGULA / MESAJ',
      'notifications_page_not_logged_in': 'Neautentificat',
      'notifications_page_no_notifications': 'Nu exista notificari inca.',
      'notifications_page_must_be_logged_in': 'Trebuie sa fii autentificat.',
      'notifications_page_title_or_message_required':
          'Titlul sau mesajul este obligatoriu.',
      'notifications_page_published_to_drivers':
          'Publicat pentru {count} soferi.',
      'notifications_page_publish_failed': 'Publicarea a esuat: {error}',
      'notifications_page_popup_notification_fallback': 'Notificare',
      'notifications_page_popup_driver_fallback': 'Sofer',
      'notifications_page_not_confirmed_by': 'NECONFIRMAT DE:',
      'notifications_page_missing_loading': 'lipsa: ...',
      'notifications_page_missing_unknown': 'lipsa: --',
      'notifications_page_missing_count': 'lipsa: {count}',
      'notifications_page_all_drivers_confirmed': 'Toti soferii au confirmat.',
      'notifications_page_close': 'Inchide',
      'notifications_page_type_rule': 'Regula noua',
      'notifications_page_type_message': 'Mesaj nou',
      'notifications_page_type_academy': 'DA Academy',
      'notifications_page_type_ride_along': 'Ride Along',
      'notifications_page_type_rule_badge': 'REGULA NOUA',
      'notifications_page_type_message_badge': 'MESAJ NOU',
      'notifications_page_edit_rule': 'Editeaza regula',
      'notifications_page_field_title': 'Titlu',
      'notifications_page_field_body': 'Continut',
      'notifications_page_cancel': 'Anuleaza',
      'notifications_page_save': 'Salveaza',
      'notifications_page_title_or_body_required':
          'Titlul sau continutul este obligatoriu.',
      'notifications_page_notification_not_found':
          'Notificarea nu a fost gasita.',
      'notifications_page_rule_updated_for_drivers':
          'Regula a fost actualizata pentru {count} soferi.',
      'notifications_page_edit_failed': 'Editarea a esuat: {error}',
      'notifications_page_delete_question': 'Stergi notificarea?',
      'notifications_page_delete_body':
          'Aceasta va sterge notificarea pentru tine si pentru toti soferii.',
      'notifications_page_delete': 'Sterge',
      'notifications_page_notification_deleted': 'Notificarea a fost stearsa.',
      'notifications_page_delete_failed': 'Stergerea a esuat: {error}',
      'notifications_page_options': 'Optiuni',
      'notifications_page_menu_edit_rule': 'Editeaza regula',
      'notifications_page_menu_delete': 'Sterge',
      'notifications_page_title_fallback': 'TITLU',
      'notifications_page_confirmed_by': 'confirmat de',
    },
    'hr': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'Obavijesti',
      'notifications_page_new_content': 'NOVI SADRZAJ | Obavijesti',
      'notifications_page_history': 'Povijest',
      'notifications_page_publish': 'objavi',
      'notifications_page_translation_preview': 'Pregled prijevoda',
      'notifications_page_translation_ready': 'Spremno na {count} jezika.',
      'notifications_page_title_hint': 'NASLOV',
      'notifications_page_rule_message_hint': 'PRAVILO / PORUKA',
      'notifications_page_not_logged_in': 'Niste prijavljeni',
      'notifications_page_no_notifications': 'Jos nema obavijesti.',
      'notifications_page_must_be_logged_in': 'Morate biti prijavljeni.',
      'notifications_page_title_or_message_required':
          'Naslov ili poruka su obavezni.',
      'notifications_page_published_to_drivers':
          'Objavljeno za {count} vozaca.',
      'notifications_page_publish_failed': 'Objava nije uspjela: {error}',
      'notifications_page_popup_notification_fallback': 'Obavijest',
      'notifications_page_popup_driver_fallback': 'Vozac',
      'notifications_page_not_confirmed_by': 'NIJE POTVRDENO OD:',
      'notifications_page_missing_loading': 'nedostaje: ...',
      'notifications_page_missing_unknown': 'nedostaje: --',
      'notifications_page_missing_count': 'nedostaje: {count}',
      'notifications_page_all_drivers_confirmed': 'Svi vozaci su potvrdili.',
      'notifications_page_close': 'Zatvori',
      'notifications_page_type_rule': 'Novo pravilo',
      'notifications_page_type_message': 'Nova poruka',
      'notifications_page_type_academy': 'DA Academy',
      'notifications_page_type_ride_along': 'Ride Along',
      'notifications_page_type_rule_badge': 'NOVO PRAVILO',
      'notifications_page_type_message_badge': 'NOVA PORUKA',
      'notifications_page_edit_rule': 'Uredi pravilo',
      'notifications_page_field_title': 'Naslov',
      'notifications_page_field_body': 'Sadrzaj',
      'notifications_page_cancel': 'Odustani',
      'notifications_page_save': 'Spremi',
      'notifications_page_title_or_body_required':
          'Naslov ili sadrzaj su obavezni.',
      'notifications_page_notification_not_found': 'Obavijest nije pronadena.',
      'notifications_page_rule_updated_for_drivers':
          'Pravilo je azurirano za {count} vozaca.',
      'notifications_page_edit_failed': 'Uredivanje nije uspjelo: {error}',
      'notifications_page_delete_question': 'Obrisati obavijest?',
      'notifications_page_delete_body':
          'Ovo ce obrisati ovu obavijest za vas i sve vozace.',
      'notifications_page_delete': 'Obrisi',
      'notifications_page_notification_deleted': 'Obavijest je obrisana.',
      'notifications_page_delete_failed': 'Brisanje nije uspjelo: {error}',
      'notifications_page_options': 'Opcije',
      'notifications_page_menu_edit_rule': 'Uredi pravilo',
      'notifications_page_menu_delete': 'Obrisi',
      'notifications_page_title_fallback': 'NASLOV',
      'notifications_page_confirmed_by': 'potvrdilo',
    },
    'ar': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'الإشعارات',
      'notifications_page_new_content': 'محتوى جديد | الإشعارات',
      'notifications_page_history': 'السجل',
      'notifications_page_publish': 'نشر',
      'notifications_page_translation_preview': 'معاينة الترجمة',
      'notifications_page_translation_ready': 'جاهز بـ {count} لغة.',
      'notifications_page_title_hint': 'العنوان',
      'notifications_page_rule_message_hint': 'قاعدة / رسالة',
      'notifications_page_not_logged_in': 'غير مسجل الدخول',
      'notifications_page_no_notifications': 'لا توجد إشعارات بعد.',
      'notifications_page_must_be_logged_in': 'يجب تسجيل الدخول.',
      'notifications_page_title_or_message_required':
          'العنوان أو الرسالة مطلوب.',
      'notifications_page_published_to_drivers': 'تم النشر إلى {count} سائق.',
      'notifications_page_publish_failed': 'فشل النشر: {error}',
      'notifications_page_popup_notification_fallback': 'إشعار',
      'notifications_page_popup_driver_fallback': 'سائق',
      'notifications_page_not_confirmed_by': 'غير مؤكد من:',
      'notifications_page_missing_loading': 'المفقود: ...',
      'notifications_page_missing_unknown': 'المفقود: --',
      'notifications_page_missing_count': 'المفقود: {count}',
      'notifications_page_all_drivers_confirmed': 'جميع السائقين أكدوا.',
      'notifications_page_close': 'إغلاق',
      'notifications_page_type_rule': 'قاعدة جديدة',
      'notifications_page_type_message': 'رسالة جديدة',
      'notifications_page_type_academy': 'أكاديمية DA',
      'notifications_page_type_ride_along': 'مرافقة قيادة',
      'notifications_page_type_rule_badge': 'قاعدة جديدة',
      'notifications_page_type_message_badge': 'رسالة جديدة',
      'notifications_page_type_academy_badge': 'أكاديمية DA',
      'notifications_page_type_ride_along_badge': 'مرافقة قيادة',
      'notifications_page_edit_rule': 'تعديل القاعدة',
      'notifications_page_field_title': 'العنوان',
      'notifications_page_field_body': 'المحتوى',
      'notifications_page_cancel': 'إلغاء',
      'notifications_page_save': 'حفظ',
      'notifications_page_title_or_body_required': 'العنوان أو المحتوى مطلوب.',
      'notifications_page_notification_not_found': 'الإشعار غير موجود.',
      'notifications_page_rule_updated_for_drivers':
          'تم تحديث القاعدة لـ {count} سائق.',
      'notifications_page_edit_failed': 'فشل التعديل: {error}',
      'notifications_page_delete_question': 'حذف الإشعار؟',
      'notifications_page_delete_body':
          'سيؤدي هذا إلى حذف هذا الإشعار لك ولجميع السائقين.',
      'notifications_page_delete': 'حذف',
      'notifications_page_notification_deleted': 'تم حذف الإشعار.',
      'notifications_page_delete_failed': 'فشل الحذف: {error}',
      'notifications_page_options': 'خيارات',
      'notifications_page_menu_edit_rule': 'تعديل القاعدة',
      'notifications_page_menu_delete': 'حذف',
      'notifications_page_title_fallback': 'العنوان',
      'notifications_page_confirmed_by': 'تم التأكيد بواسطة',
    },
    'tr': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'Bildirimler',
      'notifications_page_new_content': 'YENI ICERIK | Bildirimler',
      'notifications_page_history': 'Gecmis',
      'notifications_page_publish': 'yayinla',
      'notifications_page_translation_preview': 'Ceviri onizlemesi',
      'notifications_page_translation_ready': '{count} dil icin hazir.',
      'notifications_page_title_hint': 'BASLIK',
      'notifications_page_rule_message_hint': 'KURAL / MESAJ',
      'notifications_page_not_logged_in': 'Giris yapilmamis',
      'notifications_page_no_notifications': 'Henuz bildirim yok.',
      'notifications_page_must_be_logged_in': 'Giris yapmis olmalisin.',
      'notifications_page_title_or_message_required':
          'Baslik veya mesaj zorunludur.',
      'notifications_page_published_to_drivers': '{count} surucuye yayinlandi.',
      'notifications_page_publish_failed': 'Yayinlama basarisiz: {error}',
      'notifications_page_popup_notification_fallback': 'Bildirim',
      'notifications_page_popup_driver_fallback': 'Surucu',
      'notifications_page_not_confirmed_by': 'ONAYLAMAYANLAR:',
      'notifications_page_missing_loading': 'eksik: ...',
      'notifications_page_missing_unknown': 'eksik: --',
      'notifications_page_missing_count': 'eksik: {count}',
      'notifications_page_all_drivers_confirmed': 'Tum suruculer onayladi.',
      'notifications_page_close': 'Kapat',
      'notifications_page_type_rule': 'Yeni Kural',
      'notifications_page_type_message': 'Yeni Mesaj',
      'notifications_page_type_academy': 'DA Academy',
      'notifications_page_type_ride_along': 'Ride Along',
      'notifications_page_type_rule_badge': 'YENI KURAL',
      'notifications_page_type_message_badge': 'YENI MESAJ',
      'notifications_page_edit_rule': 'Kurali duzenle',
      'notifications_page_field_title': 'Baslik',
      'notifications_page_field_body': 'Icerik',
      'notifications_page_cancel': 'Iptal',
      'notifications_page_save': 'Kaydet',
      'notifications_page_title_or_body_required':
          'Baslik veya icerik zorunludur.',
      'notifications_page_notification_not_found': 'Bildirim bulunamadi.',
      'notifications_page_rule_updated_for_drivers':
          'Kural {count} surucu icin guncellendi.',
      'notifications_page_edit_failed': 'Duzenleme basarisiz: {error}',
      'notifications_page_delete_question': 'Bildirim silinsin mi?',
      'notifications_page_delete_body':
          'Bu bildirim senden ve tum suruculerden silinecek.',
      'notifications_page_delete': 'Sil',
      'notifications_page_notification_deleted': 'Bildirim silindi.',
      'notifications_page_delete_failed': 'Silme basarisiz: {error}',
      'notifications_page_options': 'Secenekler',
      'notifications_page_menu_edit_rule': 'Kurali duzenle',
      'notifications_page_menu_delete': 'Sil',
      'notifications_page_title_fallback': 'BASLIK',
      'notifications_page_confirmed_by': 'onaylayan',
    },
    'ru': {
      ..._notificationsSharedValues,
      'notifications_page_title': 'Уведомления',
      'notifications_page_new_content': 'НОВЫЙ КОНТЕНТ | Уведомления',
      'notifications_page_history': 'История',
      'notifications_page_publish': 'опубликовать',
      'notifications_page_translation_preview': 'Предпросмотр перевода',
      'notifications_page_translation_ready': 'Готово на {count} языках.',
      'notifications_page_title_hint': 'ЗАГОЛОВОК',
      'notifications_page_rule_message_hint': 'ПРАВИЛО / СООБЩЕНИЕ',
      'notifications_page_not_logged_in': 'Не выполнен вход',
      'notifications_page_no_notifications': 'Пока нет уведомлений.',
      'notifications_page_must_be_logged_in': 'Вы должны войти в систему.',
      'notifications_page_title_or_message_required':
          'Требуется заголовок или сообщение.',
      'notifications_page_published_to_drivers':
          'Опубликовано для {count} водителей.',
      'notifications_page_publish_failed': 'Ошибка публикации: {error}',
      'notifications_page_popup_notification_fallback': 'Уведомление',
      'notifications_page_popup_driver_fallback': 'Водитель',
      'notifications_page_not_confirmed_by': 'НЕ ПОДТВЕРДИЛИ:',
      'notifications_page_missing_loading': 'не подтверждено: ...',
      'notifications_page_missing_unknown': 'не подтверждено: --',
      'notifications_page_missing_count': 'не подтверждено: {count}',
      'notifications_page_all_drivers_confirmed': 'Все водители подтвердили.',
      'notifications_page_close': 'Закрыть',
      'notifications_page_type_rule': 'Новое правило',
      'notifications_page_type_message': 'Новое сообщение',
      'notifications_page_type_academy': 'DA Academy',
      'notifications_page_type_ride_along': 'Совместный выезд',
      'notifications_page_type_rule_badge': 'НОВОЕ ПРАВИЛО',
      'notifications_page_type_message_badge': 'НОВОЕ СООБЩЕНИЕ',
      'notifications_page_type_academy_badge': 'DA ACADEMY',
      'notifications_page_type_ride_along_badge': 'СОВМЕСТНЫЙ ВЫЕЗД',
      'notifications_page_edit_rule': 'Изменить правило',
      'notifications_page_field_title': 'Заголовок',
      'notifications_page_field_body': 'Текст',
      'notifications_page_cancel': 'Отмена',
      'notifications_page_save': 'Сохранить',
      'notifications_page_title_or_body_required':
          'Требуется заголовок или текст.',
      'notifications_page_notification_not_found': 'Уведомление не найдено.',
      'notifications_page_rule_updated_for_drivers':
          'Правило обновлено для {count} водителей.',
      'notifications_page_edit_failed': 'Ошибка редактирования: {error}',
      'notifications_page_delete_question': 'Удалить уведомление?',
      'notifications_page_delete_body':
          'Это удалит уведомление у вас и у всех водителей.',
      'notifications_page_delete': 'Удалить',
      'notifications_page_notification_deleted': 'Уведомление удалено.',
      'notifications_page_delete_failed': 'Ошибка удаления: {error}',
      'notifications_page_options': 'Параметры',
      'notifications_page_menu_edit_rule': 'Изменить правило',
      'notifications_page_menu_delete': 'Удалить',
      'notifications_page_title_fallback': 'ЗАГОЛОВОК',
      'notifications_page_confirmed_by': 'подтвердили',
    },
  };

  static final Map<String, String> _taskSheetSharedValues = {
    'task_sheet_must_be_logged_in': 'You must be logged in.',
    'task_sheet_title_required': 'Task title is required.',
    'task_sheet_assign_driver_required': 'Please assign a driver.',
    'task_sheet_no_drivers_assign': 'No drivers found to assign task.',
    'task_sheet_no_valid_drivers': 'No valid drivers found.',
    'task_sheet_created_for_drivers': 'Task created for {count} drivers.',
    'task_sheet_created': 'Task created.',
    'task_sheet_failed_create': 'Failed to create task: {error}',
    'task_sheet_deleted': 'Task deleted.',
    'task_sheet_deleted_all_assigned': 'Task deleted for all assigned drivers.',
    'task_sheet_failed_delete': 'Failed to delete task: {error}',
    'task_sheet_delete_task_title': 'Delete task',
    'task_sheet_delete_task_confirm': 'Delete "{title}"?',
    'task_sheet_cancel': 'Cancel',
    'task_sheet_delete': 'Delete',
    'task_sheet_delete_for_everyone_title': 'Delete task for everyone',
    'task_sheet_delete_for_everyone_confirm':
        'Delete "{title}" for all {count} assigned drivers?',
    'task_sheet_delete_all': 'Delete all',
    'task_sheet_just_now': 'just now',
    'task_sheet_page_title': 'Task Sheet',
    'task_sheet_new_content_title': 'NEW CONTENT | Task Sheet',
    'task_sheet_assign_task': 'Assign task',
    'task_sheet_specific_driver': 'Specific driver',
    'task_sheet_everyone': 'Everyone',
    'task_sheet_assigned_to_everyone': 'Assigned to everyone',
    'task_sheet_search_driver_hint': 'Search driver by name or ID',
    'task_sheet_no_drivers_found': 'No drivers found.',
    'task_sheet_selected_driver': 'Selected: {name} ({id})',
    'task_sheet_response_type': 'Response type',
    'task_sheet_response_type_help':
        'Choose whether this task is a standard action, a written feedback prompt, or a fixed-choice survey.',
    'task_sheet_response_standard': 'Standard task',
    'task_sheet_response_standard_help':
        'Driver updates progress and confirms when done.',
    'task_sheet_response_feedback_text': 'Written feedback',
    'task_sheet_response_feedback_text_help':
        'Driver submits a custom written answer.',
    'task_sheet_response_feedback_choice': 'Select an option',
    'task_sheet_response_feedback_choice_help':
        'Driver picks one response from predefined options.',
    'task_sheet_title_hint': 'TASK TITLE',
    'task_sheet_details_hint': 'TASK DETAILS',
    'task_sheet_feedback_options_title': 'Feedback options',
    'task_sheet_feedback_options_hint':
        'Add at least 2 options. Drivers will be able to choose one.',
    'task_sheet_feedback_add_option': 'Add option',
    'task_sheet_feedback_option_label': 'Option {index}',
    'task_sheet_feedback_remove_option': 'Remove option',
    'task_sheet_feedback_options_required':
        'Please add at least two feedback options.',
    'task_sheet_feedback_response_label': 'Response',
    'task_sheet_feedback_prompt_text': 'Driver feedback',
    'task_sheet_feedback_prompt_choice': 'Choose one option',
    'task_sheet_feedback_input_hint': 'Write your feedback here',
    'task_sheet_feedback_submit': 'Submit feedback',
    'task_sheet_feedback_update': 'Update feedback',
    'task_sheet_feedback_received': 'Feedback submitted',
    'task_sheet_feedback_waiting': 'Waiting for driver feedback',
    'task_sheet_feedback_text_required': 'Please write feedback first.',
    'task_sheet_feedback_choice_required':
        'Please select one option first.',
    'task_sheet_feedback_submitted': 'Feedback submitted.',
    'task_sheet_publish': 'publish',
    'task_sheet_history': 'History',
    'task_sheet_error_generic': 'Error: {error}',
    'task_sheet_no_tasks': 'No tasks yet. Create your first task above.',
    'task_sheet_everyone_title': 'EVERYONE | {title}',
    'task_sheet_drivers_count': 'drivers: {count}',
    'task_sheet_delete_for_everyone_tooltip': 'Delete for everyone',
    'task_sheet_confirmed': 'confirmed',
    'task_sheet_awaiting_confirm': 'awaiting confirm',
    'task_sheet_delete_task_tooltip': 'Delete task',
    'task_sheet_status_drivers_count': '{status} drivers: {count}',
    'task_sheet_no_drivers_in_status': 'No drivers in this status.',
    'task_sheet_close': 'Close',
  };

  static final Map<String, Map<String, String>> _taskSheetLocalizedValues = {
    'en': _taskSheetSharedValues,
    'de': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'Du musst angemeldet sein.',
      'task_sheet_title_required': 'Aufgabentitel ist erforderlich.',
      'task_sheet_assign_driver_required': 'Bitte einen Fahrer zuweisen.',
      'task_sheet_no_drivers_assign':
          'Keine Fahrer zum Zuweisen der Aufgabe gefunden.',
      'task_sheet_no_valid_drivers': 'Keine gueltigen Fahrer gefunden.',
      'task_sheet_created_for_drivers': 'Aufgabe fuer {count} Fahrer erstellt.',
      'task_sheet_created': 'Aufgabe erstellt.',
      'task_sheet_failed_create':
          'Aufgabe konnte nicht erstellt werden: {error}',
      'task_sheet_deleted': 'Aufgabe geloescht.',
      'task_sheet_deleted_all_assigned':
          'Aufgabe fuer alle zugewiesenen Fahrer geloescht.',
      'task_sheet_failed_delete':
          'Aufgabe konnte nicht geloescht werden: {error}',
      'task_sheet_delete_task_title': 'Aufgabe loeschen',
      'task_sheet_delete_task_confirm': 'Aufgabe "{title}" loeschen?',
      'task_sheet_cancel': 'Abbrechen',
      'task_sheet_delete': 'Loeschen',
      'task_sheet_delete_for_everyone_title': 'Aufgabe fuer alle loeschen',
      'task_sheet_delete_for_everyone_confirm':
          'Aufgabe "{title}" fuer alle {count} zugewiesenen Fahrer loeschen?',
      'task_sheet_delete_all': 'Alle loeschen',
      'task_sheet_just_now': 'gerade eben',
      'task_sheet_page_title': 'Task Sheet',
      'task_sheet_new_content_title': 'NEUER INHALT | Task Sheet',
      'task_sheet_assign_task': 'Aufgabe zuweisen',
      'task_sheet_specific_driver': 'Bestimmter Fahrer',
      'task_sheet_everyone': 'Alle',
      'task_sheet_assigned_to_everyone': 'Allen zugewiesen',
      'task_sheet_search_driver_hint': 'Fahrer nach Name oder ID suchen',
      'task_sheet_no_drivers_found': 'Keine Fahrer gefunden.',
      'task_sheet_selected_driver': 'Ausgewaehlt: {name} ({id})',
      'task_sheet_title_hint': 'AUFGABENTITEL',
      'task_sheet_details_hint': 'AUFGABENDETAILS',
      'task_sheet_publish': 'veroeffentlichen',
      'task_sheet_history': 'Verlauf',
      'task_sheet_error_generic': 'Fehler: {error}',
      'task_sheet_no_tasks':
          'Noch keine Aufgaben. Erstelle oben deine erste Aufgabe.',
      'task_sheet_everyone_title': 'ALLE | {title}',
      'task_sheet_drivers_count': 'Fahrer: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'Fuer alle loeschen',
      'task_sheet_confirmed': 'bestaetigt',
      'task_sheet_awaiting_confirm': 'warte auf Bestaetigung',
      'task_sheet_delete_task_tooltip': 'Aufgabe loeschen',
      'task_sheet_status_drivers_count': '{status} Fahrer: {count}',
      'task_sheet_no_drivers_in_status': 'Keine Fahrer in diesem Status.',
      'task_sheet_close': 'Schliessen',
    },
    'sq': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'Duhet te jesh i kycur.',
      'task_sheet_title_required': 'Titulli i detyres eshte i detyrueshem.',
      'task_sheet_assign_driver_required': 'Ju lutem cakto nje shofer.',
      'task_sheet_no_drivers_assign':
          'Nuk u gjeten shofera per caktimin e detyres.',
      'task_sheet_no_valid_drivers': 'Nuk u gjeten shofera te vlefshem.',
      'task_sheet_created_for_drivers': 'Detyra u krijua per {count} shofera.',
      'task_sheet_created': 'Detyra u krijua.',
      'task_sheet_failed_create': 'Deshtoi krijimi i detyres: {error}',
      'task_sheet_deleted': 'Detyra u fshi.',
      'task_sheet_deleted_all_assigned':
          'Detyra u fshi per te gjithe shoferet e caktuar.',
      'task_sheet_failed_delete': 'Deshtoi fshirja e detyres: {error}',
      'task_sheet_delete_task_title': 'Fshi detyren',
      'task_sheet_delete_task_confirm': 'Te fshihet "{title}"?',
      'task_sheet_cancel': 'Anulo',
      'task_sheet_delete': 'Fshi',
      'task_sheet_delete_for_everyone_title': 'Fshi detyren per te gjithe',
      'task_sheet_delete_for_everyone_confirm':
          'Te fshihet "{title}" per te gjithe {count} shoferet e caktuar?',
      'task_sheet_delete_all': 'Fshi te gjitha',
      'task_sheet_just_now': 'sapo tani',
      'task_sheet_page_title': 'Flete Detyrash',
      'task_sheet_new_content_title': 'PERMBAJTJE E RE | Flete Detyrash',
      'task_sheet_assign_task': 'Cakto detyre',
      'task_sheet_specific_driver': 'Shofer specifik',
      'task_sheet_everyone': 'Te gjithe',
      'task_sheet_assigned_to_everyone': 'E caktuar per te gjithe',
      'task_sheet_search_driver_hint': 'Kerko shofer sipas emrit ose ID-se',
      'task_sheet_no_drivers_found': 'Nuk u gjeten shofera.',
      'task_sheet_selected_driver': 'I zgjedhur: {name} ({id})',
      'task_sheet_title_hint': 'TITULLI I DETYRES',
      'task_sheet_details_hint': 'DETAJET E DETYRES',
      'task_sheet_publish': 'publiko',
      'task_sheet_history': 'Historiku',
      'task_sheet_error_generic': 'Gabim: {error}',
      'task_sheet_no_tasks':
          'Ende nuk ka detyra. Krijo detyren tende te pare me lart.',
      'task_sheet_everyone_title': 'TE GJITHE | {title}',
      'task_sheet_drivers_count': 'shofera: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'Fshi per te gjithe',
      'task_sheet_confirmed': 'konfirmuar',
      'task_sheet_awaiting_confirm': 'duke pritur konfirmim',
      'task_sheet_delete_task_tooltip': 'Fshi detyren',
      'task_sheet_status_drivers_count': '{status} shofera: {count}',
      'task_sheet_no_drivers_in_status': 'Nuk ka shofera ne kete status.',
      'task_sheet_close': 'Mbyll',
    },
    'hu': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'Be kell jelentkezned.',
      'task_sheet_title_required': 'A feladat cime kotelezo.',
      'task_sheet_assign_driver_required': 'Kerlek rendelj hozza egy sofort.',
      'task_sheet_no_drivers_assign':
          'Nincs elerheto sofor a feladat kiosztasahoz.',
      'task_sheet_no_valid_drivers': 'Nem talalhato ervenyes sofor.',
      'task_sheet_created_for_drivers':
          'A feladat letrehozva {count} sofornek.',
      'task_sheet_created': 'Feladat letrehozva.',
      'task_sheet_failed_create': 'A feladat letrehozasa sikertelen: {error}',
      'task_sheet_deleted': 'Feladat torolve.',
      'task_sheet_deleted_all_assigned':
          'A feladat minden kijelolt sofornel torolve.',
      'task_sheet_failed_delete': 'A feladat torlese sikertelen: {error}',
      'task_sheet_delete_task_title': 'Feladat torlese',
      'task_sheet_delete_task_confirm': 'Torli ezt: "{title}"?',
      'task_sheet_cancel': 'Megse',
      'task_sheet_delete': 'Torles',
      'task_sheet_delete_for_everyone_title': 'Feladat torlese mindenkinek',
      'task_sheet_delete_for_everyone_confirm':
          'Torli a "{title}" feladatot az osszes ({count}) kijelolt sofornel?',
      'task_sheet_delete_all': 'Osszes torlese',
      'task_sheet_just_now': 'most',
      'task_sheet_page_title': 'Feladatlap',
      'task_sheet_new_content_title': 'UJ TARTALOM | Feladatlap',
      'task_sheet_assign_task': 'Feladat kiosztasa',
      'task_sheet_specific_driver': 'Kivalasztott sofor',
      'task_sheet_everyone': 'Mindenki',
      'task_sheet_assigned_to_everyone': 'Mindenkinek kiosztva',
      'task_sheet_search_driver_hint': 'Sofor keresese nev vagy ID alapjan',
      'task_sheet_no_drivers_found': 'Nem talalhato sofor.',
      'task_sheet_selected_driver': 'Kivalasztva: {name} ({id})',
      'task_sheet_title_hint': 'FELADAT CIME',
      'task_sheet_details_hint': 'FELADAT RESZLETEI',
      'task_sheet_publish': 'kozzetesz',
      'task_sheet_history': 'Elozmenyek',
      'task_sheet_error_generic': 'Hiba: {error}',
      'task_sheet_no_tasks':
          'Meg nincsenek feladatok. Hozd letre az elso feladatot fent.',
      'task_sheet_everyone_title': 'MINDENKI | {title}',
      'task_sheet_drivers_count': 'soforok: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'Torles mindenkinek',
      'task_sheet_confirmed': 'megerositve',
      'task_sheet_awaiting_confirm': 'megerositesre var',
      'task_sheet_delete_task_tooltip': 'Feladat torlese',
      'task_sheet_status_drivers_count': '{status} soforok: {count}',
      'task_sheet_no_drivers_in_status': 'Nincs sofor ebben az allapotban.',
      'task_sheet_close': 'Bezaras',
    },
    'ro': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'Trebuie sa fii autentificat.',
      'task_sheet_title_required': 'Titlul sarcinii este obligatoriu.',
      'task_sheet_assign_driver_required': 'Te rugam sa atribui un sofer.',
      'task_sheet_no_drivers_assign':
          'Nu au fost gasiti soferi pentru atribuirea sarcinii.',
      'task_sheet_no_valid_drivers': 'Nu au fost gasiti soferi valizi.',
      'task_sheet_created_for_drivers':
          'Sarcina a fost creata pentru {count} soferi.',
      'task_sheet_created': 'Sarcina a fost creata.',
      'task_sheet_failed_create': 'Crearea sarcinii a esuat: {error}',
      'task_sheet_deleted': 'Sarcina a fost stearsa.',
      'task_sheet_deleted_all_assigned':
          'Sarcina a fost stearsa pentru toti soferii atribuiti.',
      'task_sheet_failed_delete': 'Stergerea sarcinii a esuat: {error}',
      'task_sheet_delete_task_title': 'Sterge sarcina',
      'task_sheet_delete_task_confirm': 'Stergi "{title}"?',
      'task_sheet_cancel': 'Anuleaza',
      'task_sheet_delete': 'Sterge',
      'task_sheet_delete_for_everyone_title': 'Sterge sarcina pentru toti',
      'task_sheet_delete_for_everyone_confirm':
          'Stergi "{title}" pentru toti cei {count} soferi atribuiti?',
      'task_sheet_delete_all': 'Sterge tot',
      'task_sheet_just_now': 'chiar acum',
      'task_sheet_page_title': 'Foaie de Sarcini',
      'task_sheet_new_content_title': 'CONTINUT NOU | Foaie de Sarcini',
      'task_sheet_assign_task': 'Atribuie sarcina',
      'task_sheet_specific_driver': 'Sofer specific',
      'task_sheet_everyone': 'Toata lumea',
      'task_sheet_assigned_to_everyone': 'Atribuit tuturor',
      'task_sheet_search_driver_hint': 'Cauta sofer dupa nume sau ID',
      'task_sheet_no_drivers_found': 'Nu au fost gasiti soferi.',
      'task_sheet_selected_driver': 'Selectat: {name} ({id})',
      'task_sheet_title_hint': 'TITLUL SARCINII',
      'task_sheet_details_hint': 'DETALII SARCINA',
      'task_sheet_publish': 'publica',
      'task_sheet_history': 'Istoric',
      'task_sheet_error_generic': 'Eroare: {error}',
      'task_sheet_no_tasks':
          'Nu exista sarcini inca. Creeaza prima sarcina mai sus.',
      'task_sheet_everyone_title': 'TOATA LUMEA | {title}',
      'task_sheet_drivers_count': 'soferi: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'Sterge pentru toti',
      'task_sheet_confirmed': 'confirmat',
      'task_sheet_awaiting_confirm': 'in asteptarea confirmarii',
      'task_sheet_delete_task_tooltip': 'Sterge sarcina',
      'task_sheet_status_drivers_count': 'Soferi {status}: {count}',
      'task_sheet_no_drivers_in_status': 'Nu exista soferi in acest status.',
      'task_sheet_close': 'Inchide',
    },
    'hr': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'Morate biti prijavljeni.',
      'task_sheet_title_required': 'Naslov zadatka je obavezan.',
      'task_sheet_assign_driver_required': 'Molimo odaberite vozaca.',
      'task_sheet_no_drivers_assign':
          'Nisu pronadeni vozaci za dodjelu zadatka.',
      'task_sheet_no_valid_drivers': 'Nisu pronadeni valjani vozaci.',
      'task_sheet_created_for_drivers': 'Zadatak je kreiran za {count} vozaca.',
      'task_sheet_created': 'Zadatak je kreiran.',
      'task_sheet_failed_create': 'Neuspjelo kreiranje zadatka: {error}',
      'task_sheet_deleted': 'Zadatak je obrisan.',
      'task_sheet_deleted_all_assigned':
          'Zadatak je obrisan za sve dodijeljene vozace.',
      'task_sheet_failed_delete': 'Brisanje zadatka nije uspjelo: {error}',
      'task_sheet_delete_task_title': 'Obrisi zadatak',
      'task_sheet_delete_task_confirm': 'Obrisati "{title}"?',
      'task_sheet_cancel': 'Odustani',
      'task_sheet_delete': 'Obrisi',
      'task_sheet_delete_for_everyone_title': 'Obrisi zadatak za sve',
      'task_sheet_delete_for_everyone_confirm':
          'Obrisati "{title}" za svih {count} dodijeljenih vozaca?',
      'task_sheet_delete_all': 'Obrisi sve',
      'task_sheet_just_now': 'upravo sada',
      'task_sheet_page_title': 'Lista Zadataka',
      'task_sheet_new_content_title': 'NOVI SADRZAJ | Lista Zadataka',
      'task_sheet_assign_task': 'Dodijeli zadatak',
      'task_sheet_specific_driver': 'Odredeni vozac',
      'task_sheet_everyone': 'Svi',
      'task_sheet_assigned_to_everyone': 'Dodijeljeno svima',
      'task_sheet_search_driver_hint': 'Pretrazi vozaca po imenu ili ID-u',
      'task_sheet_no_drivers_found': 'Nema pronadenih vozaca.',
      'task_sheet_selected_driver': 'Odabrano: {name} ({id})',
      'task_sheet_title_hint': 'NASLOV ZADATKA',
      'task_sheet_details_hint': 'DETALJI ZADATKA',
      'task_sheet_publish': 'objavi',
      'task_sheet_history': 'Povijest',
      'task_sheet_error_generic': 'Greska: {error}',
      'task_sheet_no_tasks': 'Jos nema zadataka. Kreiraj prvi zadatak iznad.',
      'task_sheet_everyone_title': 'SVI | {title}',
      'task_sheet_drivers_count': 'vozaci: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'Obrisi za sve',
      'task_sheet_confirmed': 'potvrdeno',
      'task_sheet_awaiting_confirm': 'ceka potvrdu',
      'task_sheet_delete_task_tooltip': 'Obrisi zadatak',
      'task_sheet_status_drivers_count': '{status} vozaci: {count}',
      'task_sheet_no_drivers_in_status': 'Nema vozaca u ovom statusu.',
      'task_sheet_close': 'Zatvori',
    },
    'ar': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'يجب تسجيل الدخول.',
      'task_sheet_title_required': 'عنوان المهمة مطلوب.',
      'task_sheet_assign_driver_required': 'يرجى تعيين سائق.',
      'task_sheet_no_drivers_assign': 'لم يتم العثور على سائقين لتعيين المهمة.',
      'task_sheet_no_valid_drivers': 'لم يتم العثور على سائقين صالحين.',
      'task_sheet_created_for_drivers': 'تم إنشاء المهمة لـ {count} سائق.',
      'task_sheet_created': 'تم إنشاء المهمة.',
      'task_sheet_failed_create': 'فشل إنشاء المهمة: {error}',
      'task_sheet_deleted': 'تم حذف المهمة.',
      'task_sheet_deleted_all_assigned':
          'تم حذف المهمة لجميع السائقين المعينين.',
      'task_sheet_failed_delete': 'فشل حذف المهمة: {error}',
      'task_sheet_delete_task_title': 'حذف المهمة',
      'task_sheet_delete_task_confirm': 'حذف "{title}"؟',
      'task_sheet_cancel': 'إلغاء',
      'task_sheet_delete': 'حذف',
      'task_sheet_delete_for_everyone_title': 'حذف المهمة للجميع',
      'task_sheet_delete_for_everyone_confirm':
          'حذف "{title}" لجميع السائقين المعينين وعددهم {count}؟',
      'task_sheet_delete_all': 'حذف الكل',
      'task_sheet_just_now': 'الآن',
      'task_sheet_page_title': 'ورقة المهام',
      'task_sheet_new_content_title': 'محتوى جديد | ورقة المهام',
      'task_sheet_assign_task': 'تعيين مهمة',
      'task_sheet_specific_driver': 'سائق محدد',
      'task_sheet_everyone': 'الجميع',
      'task_sheet_assigned_to_everyone': 'مخصصة للجميع',
      'task_sheet_search_driver_hint': 'ابحث عن السائق بالاسم أو المعرف',
      'task_sheet_no_drivers_found': 'لم يتم العثور على سائقين.',
      'task_sheet_selected_driver': 'المحدد: {name} ({id})',
      'task_sheet_title_hint': 'عنوان المهمة',
      'task_sheet_details_hint': 'تفاصيل المهمة',
      'task_sheet_publish': 'نشر',
      'task_sheet_history': 'السجل',
      'task_sheet_error_generic': 'خطأ: {error}',
      'task_sheet_no_tasks': 'لا توجد مهام بعد. أنشئ أول مهمة في الأعلى.',
      'task_sheet_everyone_title': 'الجميع | {title}',
      'task_sheet_drivers_count': 'السائقون: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'حذف للجميع',
      'task_sheet_confirmed': 'تم التأكيد',
      'task_sheet_awaiting_confirm': 'بانتظار التأكيد',
      'task_sheet_delete_task_tooltip': 'حذف المهمة',
      'task_sheet_status_drivers_count': 'السائقون بحالة {status}: {count}',
      'task_sheet_no_drivers_in_status': 'لا يوجد سائقون في هذه الحالة.',
      'task_sheet_close': 'إغلاق',
    },
    'tr': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'Giris yapmis olmalisin.',
      'task_sheet_title_required': 'Gorev basligi zorunludur.',
      'task_sheet_assign_driver_required': 'Lutfen bir surucu ata.',
      'task_sheet_no_drivers_assign': 'Gorev atamak icin surucu bulunamadi.',
      'task_sheet_no_valid_drivers': 'Gecerli surucu bulunamadi.',
      'task_sheet_created_for_drivers':
          '{count} surucu icin gorev olusturuldu.',
      'task_sheet_created': 'Gorev olusturuldu.',
      'task_sheet_failed_create': 'Gorev olusturulamadi: {error}',
      'task_sheet_deleted': 'Gorev silindi.',
      'task_sheet_deleted_all_assigned':
          'Gorev, atanan tum suruculer icin silindi.',
      'task_sheet_failed_delete': 'Gorev silinemedi: {error}',
      'task_sheet_delete_task_title': 'Gorevi sil',
      'task_sheet_delete_task_confirm': '"{title}" silinsin mi?',
      'task_sheet_cancel': 'Iptal',
      'task_sheet_delete': 'Sil',
      'task_sheet_delete_for_everyone_title': 'Gorevi herkes icin sil',
      'task_sheet_delete_for_everyone_confirm':
          '"{title}" gorevi atanan tum {count} surucu icin silinsin mi?',
      'task_sheet_delete_all': 'Tumunu sil',
      'task_sheet_just_now': 'simdi',
      'task_sheet_page_title': 'Gorev Sayfasi',
      'task_sheet_new_content_title': 'YENI ICERIK | Gorev Sayfasi',
      'task_sheet_assign_task': 'Gorev ata',
      'task_sheet_specific_driver': 'Belirli surucu',
      'task_sheet_everyone': 'Herkes',
      'task_sheet_assigned_to_everyone': 'Herkese atandi',
      'task_sheet_search_driver_hint': 'Surucuyu ad veya ID ile ara',
      'task_sheet_no_drivers_found': 'Surucu bulunamadi.',
      'task_sheet_selected_driver': 'Secilen: {name} ({id})',
      'task_sheet_title_hint': 'GOREV BASLIGI',
      'task_sheet_details_hint': 'GOREV DETAYLARI',
      'task_sheet_publish': 'yayinla',
      'task_sheet_history': 'Gecmis',
      'task_sheet_error_generic': 'Hata: {error}',
      'task_sheet_no_tasks': 'Henuz gorev yok. Ilk gorevini yukarida olustur.',
      'task_sheet_everyone_title': 'HERKES | {title}',
      'task_sheet_drivers_count': 'suruculer: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'Herkes icin sil',
      'task_sheet_confirmed': 'onaylandi',
      'task_sheet_awaiting_confirm': 'onay bekleniyor',
      'task_sheet_delete_task_tooltip': 'Gorevi sil',
      'task_sheet_status_drivers_count': '{status} suruculer: {count}',
      'task_sheet_no_drivers_in_status': 'Bu durumda surucu yok.',
      'task_sheet_close': 'Kapat',
    },
    'ru': {
      ..._taskSheetSharedValues,
      'task_sheet_must_be_logged_in': 'Вы должны войти в систему.',
      'task_sheet_title_required': 'Требуется заголовок задачи.',
      'task_sheet_assign_driver_required': 'Пожалуйста, назначьте водителя.',
      'task_sheet_no_drivers_assign':
          'Не найдено водителей для назначения задачи.',
      'task_sheet_no_valid_drivers': 'Не найдено подходящих водителей.',
      'task_sheet_created_for_drivers': 'Задача создана для {count} водителей.',
      'task_sheet_created': 'Задача создана.',
      'task_sheet_failed_create': 'Не удалось создать задачу: {error}',
      'task_sheet_deleted': 'Задача удалена.',
      'task_sheet_deleted_all_assigned':
          'Задача удалена для всех назначенных водителей.',
      'task_sheet_failed_delete': 'Не удалось удалить задачу: {error}',
      'task_sheet_delete_task_title': 'Удалить задачу',
      'task_sheet_delete_task_confirm': 'Удалить "{title}"?',
      'task_sheet_cancel': 'Отмена',
      'task_sheet_delete': 'Удалить',
      'task_sheet_delete_for_everyone_title': 'Удалить задачу для всех',
      'task_sheet_delete_for_everyone_confirm':
          'Удалить "{title}" для всех назначенных водителей ({count})?',
      'task_sheet_delete_all': 'Удалить все',
      'task_sheet_just_now': 'только что',
      'task_sheet_page_title': 'Лист задач',
      'task_sheet_new_content_title': 'НОВЫЙ КОНТЕНТ | Лист задач',
      'task_sheet_assign_task': 'Назначить задачу',
      'task_sheet_specific_driver': 'Конкретный водитель',
      'task_sheet_everyone': 'Всем',
      'task_sheet_assigned_to_everyone': 'Назначено всем',
      'task_sheet_search_driver_hint': 'Поиск водителя по имени или ID',
      'task_sheet_no_drivers_found': 'Водители не найдены.',
      'task_sheet_selected_driver': 'Выбрано: {name} ({id})',
      'task_sheet_title_hint': 'ЗАГОЛОВОК ЗАДАЧИ',
      'task_sheet_details_hint': 'ДЕТАЛИ ЗАДАЧИ',
      'task_sheet_publish': 'опубликовать',
      'task_sheet_history': 'История',
      'task_sheet_error_generic': 'Ошибка: {error}',
      'task_sheet_no_tasks': 'Пока нет задач. Создайте первую задачу выше.',
      'task_sheet_everyone_title': 'ВСЕМ | {title}',
      'task_sheet_drivers_count': 'водителей: {count}',
      'task_sheet_delete_for_everyone_tooltip': 'Удалить для всех',
      'task_sheet_confirmed': 'подтверждено',
      'task_sheet_awaiting_confirm': 'ожидает подтверждения',
      'task_sheet_delete_task_tooltip': 'Удалить задачу',
      'task_sheet_status_drivers_count':
          'Водители со статусом {status}: {count}',
      'task_sheet_no_drivers_in_status': 'Нет водителей с этим статусом.',
      'task_sheet_close': 'Закрыть',
    },
  };

  static final Map<String, String> _deliveryTrainingSharedValues = {
    'delivery_training_module_title': 'MEU - Delivery Workflow',
    'delivery_training_activity_subtitle':
        'Main app flow, tabs, notes and quick actions',
    'delivery_training_module_activity_2_title': 'Delivering to the Customer',
    'delivery_training_module_activity_2_subtitle':
        'Process and best-practice handling',
    'delivery_training_module_activity_3_title': 'Delivering to a Safe Place',
    'delivery_training_module_activity_3_subtitle': 'Safe drop location checks',
    'delivery_training_module_activity_4_title': 'Delivering to a Mailbox',
    'delivery_training_module_activity_4_subtitle':
        'Mailbox constraints and rules',
    'delivery_training_module_activity_5_title': 'Unable to Deliver',
    'delivery_training_module_activity_5_subtitle':
        'Issue handling and escalation',
    'delivery_training_module_activity_6_title': 'Delivery Verification',
    'delivery_training_module_activity_6_subtitle':
        'Photo and verification proof flow',
    'delivery_training_module_activity_7_title': 'Final Assessment',
    'delivery_training_module_activity_7_subtitle':
        'Knowledge check and completion',
    'delivery_training_status_not_started': 'Not started',
    'delivery_training_status_in_progress': 'In progress',
    'delivery_training_status_completed': 'Completed',
    'delivery_training_step_of_total': 'Step {current}/{total}',
    'delivery_training_last_completed': 'Last completed: {date}',
    'delivery_training_review': 'Review',
    'delivery_training_restart_activity': 'Restart activity',
    'delivery_training_resume': 'Resume',
    'delivery_training_start_now': 'Start now',
    'delivery_training_restart_tooltip': 'Restart',
    'delivery_training_step_title': 'Step {current}',
    'delivery_training_next': 'Next',
    'delivery_training_finish': 'Finish training',
    'delivery_training_done': 'Completed',
    'delivery_training_screen_title_overview': 'Overview',
    'delivery_training_screen_title_type_of_deliveries': 'Type of Deliveries',
    'delivery_training_screen_title_door_to_door': 'Door to Door',
    'delivery_training_screen_title_lockers': 'Lockers',
    'delivery_training_screen_title_counters': 'Counters',
    'delivery_training_screen_title_otr_supplies': 'Door to Door Deliveries',
    'delivery_training_screen_title_otp_badge': 'Door to Door Deliveries',
    'delivery_training_screen_title_weather_bags': 'Door to Door Deliveries',
    'delivery_training_screen_title_ready_to_go': 'Door to Door Deliveries',
    'delivery_training_screen_title_customer_arrival':
        'Door to Door Deliveries',
    'delivery_training_screen_title_customer_feedback':
        'Door to Door Deliveries',
    'delivery_training_screen_title_concessions': 'Concessions',
    'delivery_training_screen_title_delivery_app_usage': 'Delivery App Usage',
    'delivery_training_screen_title_delivery_app_overview':
        'Delivery App Overview',
    'delivery_training_screen_title_transportation_method':
        'Transportation Method',
    'delivery_training_screen_title_verify_identity': 'Verify Identity',
    'delivery_training_screen_title_offline_maps': 'Offline Maps',
    'delivery_training_screen_title_menu': 'Main Menu',
    'delivery_training_screen_title_settings': 'Settings',
    'delivery_training_screen_title_itinerary': 'Itinerary List',
    'delivery_training_screen_title_itinerary_list_lower': 'Itinerary list',
    'delivery_training_screen_title_itinerary_map_lower': 'Itinerary map',
    'delivery_training_screen_title_map': 'Itinerary Map',
    'delivery_training_screen_title_summary': 'Summary',
    'delivery_training_screen_title_stop_details': 'Stop Details',
    'delivery_training_welcome_title': 'Type of Deliveries',
    'delivery_training_welcome_body':
        'Learn the core workflow inside the delivery app.',
    'delivery_training_launch_button': 'Click here to launch',
    'delivery_training_step_launch':
        'Launch the training and prepare the app for your route.',
    'delivery_training_step_type_of_deliveries':
        'Review the delivery types introduction and continue.',
    'delivery_training_step_door_to_door':
        'Door-to-door deliveries are made directly to the customer home.',
    'delivery_training_step_lockers':
        'Amazon Locker locations allow customers to pick up and return packages.',
    'delivery_training_step_counters':
        'Counters are staffed pickup points where store partners support package collection.',
    'delivery_training_step_otr_supplies':
        'Review OTR supplies and where to find the trolley before continuing.',
    'delivery_training_step_otp_badge':
        'If customers do not know the OTP, ask them to scan the QR code on the OTP badge.',
    'delivery_training_step_otp_badge_visual':
        'If customers do not know the OTP, ask them to scan the QR code on the OTP badge.',
    'delivery_training_step_weather_bags':
        'Cover packages with weather bags when exposed to the weather.',
    'delivery_training_step_ready_to_go':
        'You have all the delivery equipment and are ready to hit the road.',
    'delivery_training_step_customer_arrival_contact':
        'When parked at the delivery address, use the app to call or text the customer and notify your arrival.',
    'delivery_training_step_customer_feedback':
        'When the delivery is completed, customers receive a survey to evaluate their experience.',
    'delivery_training_step_concessions':
        'If delivery experience is negative, customers can request a refund or concession.',
    'delivery_training_step_delivery_app_usage':
        'During this training, we will learn to avoid concessions by using the Delivery App correctly.',
    'delivery_training_step_delivery_app_overview':
        'The Delivery App is the main tool for making deliveries. Never uninstall it unless your DSP asks.',
    'delivery_training_step_transportation_method':
        'On the first screen, select how you will be delivering the packages.',
    'delivery_training_step_verify_identity':
        'The app may request a selfie to verify identity. Follow instructions safely.',
    'delivery_training_step_delivery_app_overview_maps':
        'If connection is weak, download maps before starting the route.',
    'delivery_training_step_offline_maps_prompt':
        'Open Main Menu to download offline maps.',
    'delivery_training_step_settings_prompt': 'From Main Menu, tap Settings.',
    'delivery_training_step_offline_maps_settings_prompt':
        'Tap on Offline Maps.',
    'delivery_training_step_offline_maps_download_prompt':
        'Review offline maps download options before continuing.',
    'delivery_training_step_offline_maps_downloaded_prompt':
        'Review downloaded maps and how to delete them.',
    'delivery_training_step_offline_maps_connectivity_prompt':
        'Download maps for your DS to keep delivering with poor connectivity.',
    'delivery_training_door_to_door_title': 'Door to Door',
    'delivery_training_door_to_door_body':
        'Deliver packages directly to the Customer\'s home.',
    'delivery_training_lockers_title': 'Lockers',
    'delivery_training_lockers_body':
        'Amazon Locker locations allow Customers to easily pick up and return packages.',
    'delivery_training_counters_title': 'Counters',
    'delivery_training_counters_body':
        'Staffed locations where partners offer space in their store as a pickup point for Customers.',
    'delivery_training_otr_header': 'DOOR TO DOOR DELIVERIES',
    'delivery_training_otr_body_1':
        'Before jumping to the processes to follow in the Delivery App while delivering packages door to door, let\'s take a look at the delivery equipment available for you in the On The Road (OTR) Supplies Trolley of the DS.',
    'delivery_training_otr_body_2':
        'The trolley is usually located close to the Loadout Area. Then we will familiarize with the main features of the Delivery App.',
    'delivery_training_otp_badge_body':
        'If customers don\'t know the One-Time Password (OTP) to complete the delivery, ask them to scan the QR code on the OTP badge.',
    'delivery_training_otp_badge_help_body':
        'They will be directed to the official help page with details on how to recover the OTP.',
    'delivery_training_weather_bags_body':
        'Cover packages with weather bags when exposed to the weather.',
    'delivery_training_ready_to_go_body':
        'You have all the delivery equipment and are ready to hit the road.',
    'delivery_training_ready_to_go_footer': 'Let\'s go!',
    'delivery_training_customer_arrival_body':
        'When parked at the delivery address, the Delivery App enables you to call or text the Customer to notify them of your arrival.',
    'delivery_training_customer_feedback_body':
        'When the delivery is completed, Customers receive a survey to evaluate their experience.',
    'delivery_training_concessions_title': 'Concessions',
    'delivery_training_concessions_body':
        'If the delivery experience was negative, customers can ask for a refund or concession.',
    'delivery_training_delivery_app_usage_title': 'Delivery App Usage',
    'delivery_training_delivery_app_usage_body':
        'During this training, we will learn to avoid concessions by using the Delivery App correctly.',
    'delivery_training_delivery_app_overview_header': 'DELIVERY APP OVERVIEW',
    'delivery_training_delivery_app_overview_body':
        'The Delivery App is the main tool for making deliveries.\n\nUnless your DSP tells you to, never uninstall it from your device.\n\nLet\'s take a look to the main features of the Delivery App!',
    'delivery_training_delivery_app_overview_maps_body':
        'Sometimes, the device might not have a good connection when delivering packages. This can make it hard to see where to go or which package to deliver next.\n\nTo fix this, download maps before starting the route, so you always know where to go.\n\nLet\'s take a look!',
    'delivery_training_offline_maps_prompt_title': 'Overview',
    'delivery_training_offline_maps_prompt_body':
        'You can download offline maps from the Main Menu, on the top-left corner.\n\nTap on it!',
    'delivery_training_settings_prompt_current_stop': 'Current stop',
    'delivery_training_settings_prompt_feedback': 'Feedback',
    'delivery_training_settings_prompt_settings': 'Settings',
    'delivery_training_settings_prompt_breaks': 'Breaks',
    'delivery_training_settings_prompt_driver_support': 'Driver Support',
    'delivery_training_settings_prompt_emergency_help': 'Emergency Help',
    'delivery_training_settings_prompt_body':
        'From the Main Menu, tap on “Settings”.\n\nTap on it!',
    'delivery_training_offline_maps_settings_header': 'SETTINGS',
    'delivery_training_offline_maps_settings_personal': 'Personal Information',
    'delivery_training_offline_maps_settings_phone': 'Phone Number',
    'delivery_training_offline_maps_settings_legal': 'View Legal Information',
    'delivery_training_offline_maps_settings_offline': 'Offline Maps',
    'delivery_training_offline_maps_settings_version': 'Version Info',
    'delivery_training_offline_maps_settings_device': 'Device Identifier',
    'delivery_training_offline_maps_settings_sign_out': 'SIGN OUT',
    'delivery_training_offline_maps_settings_prompt_body':
        'Tap on “Offline Maps”.',
    'delivery_training_offline_maps_settings_prompt_prefix': 'Tap on “',
    'delivery_training_offline_maps_settings_prompt_target': 'Offline Maps',
    'delivery_training_offline_maps_settings_prompt_suffix': '”.',
    'delivery_training_offline_maps_download_header': 'OFFLINE MAPS',
    'delivery_training_offline_maps_download_settings': 'Download settings',
    'delivery_training_offline_maps_allow_title':
        'Allow downloads over cell network',
    'delivery_training_offline_maps_allow_body':
        'If Wi-Fi isn\'t available, your maps will use your cell data to download updates.',
    'delivery_training_offline_maps_downloaded_title': 'Downloaded maps',
    'delivery_training_offline_maps_downloaded_item': 'MDC-HTB',
    'delivery_training_offline_maps_download_prompt_body':
        'By default, downloading offline maps requires WiFi, but you can switch to "Download over cellular network" to use your cellular connection instead.',
    'delivery_training_offline_maps_downloaded_code': 'DL01',
    'delivery_training_offline_maps_downloaded_size': '134.6 MB',
    'delivery_training_offline_maps_other_maps': 'Other maps',
    'delivery_training_offline_maps_downloaded_prompt_body':
        'Here you can find maps already downloaded. To delete a map, tap the bin icon.',
    'delivery_training_offline_maps_other_code_1': 'DLO4',
    'delivery_training_offline_maps_other_size_1': '162.7 MB',
    'delivery_training_offline_maps_other_code_2': 'DPU3',
    'delivery_training_offline_maps_other_size_2': '112.4 MB',
    'delivery_training_offline_maps_other_code_3': 'DGV2',
    'delivery_training_offline_maps_other_size_3': '105.9 MB',
    'delivery_training_offline_maps_connectivity_prompt_body':
        'Download maps for the DS you operate in. This ensures you can deliver packages even with poor connectivity.',
    'delivery_training_overview_intro_prompt_body':
        'In the Overview screen you\'ll find information that you\'ll need to deliver and troubleshoot packages.\n\nLet’s take a look!',
    'delivery_training_overview_tabs_prompt':
        'The buttons at the top help you to keep the itinerary at your fingertips.',
    'delivery_training_overview_itinerary_tap_prompt':
        'Let’s start exploring the Itinerary List screen.\n\nTap on it!',
    'delivery_training_itinerary_overview_prompt':
        'From the Itinerary List you access the list of delivery locations for the assigned route.',
    'delivery_training_itinerary_delivery_type_prompt':
        'You can also check the delivery type.',
    'delivery_training_itinerary_map_tap_prompt':
        'Let’s move on and explore the Itinerary Map screen.\n\nTap on it!',
    'delivery_training_itinerary_map_locations_prompt':
        'Here you see the delivery locations in the map.',
    'delivery_training_itinerary_summary_tap_prompt':
        'Let\'s finish by exploring the Summary screen.\n\nTap on it!',
    'delivery_training_itinerary_summary_overview_prompt':
        'Here you find information about the remaining packages to be delivered.',
    'delivery_training_itinerary_prompt_current_stop': 'Current stop',
    'delivery_training_itinerary_prompt_by_end_day': 'By the end of the day',
    'delivery_training_itinerary_prompt_access': '1-Click Access',
    'delivery_training_itinerary_prompt_otp_delivery': 'OTP Delivery',
    'delivery_training_itinerary_prompt_resume_stop1':
        'Resume delivery - Stop 1',
    'delivery_training_summary_work_remaining': 'Work remaining',
    'delivery_training_summary_stops_count': '5 stops',
    'delivery_training_summary_locations_count': '8 locations',
    'delivery_training_summary_packages_count': '9 packages',
    'delivery_training_summary_stops_header': 'Stops',
    'delivery_training_transportation_method_header': 'TRANSPORTATION METHOD',
    'delivery_training_transportation_method_question':
        'What transportation method do you prefer?',
    'delivery_training_transportation_method_walk': 'Walk',
    'delivery_training_transportation_method_drive': 'Drive',
    'delivery_training_transportation_method_bike': 'Bike',
    'delivery_training_transportation_method_motorcycle': 'Motorcycle',
    'delivery_training_transportation_method_card_title':
        'Transportation method',
    'delivery_training_transportation_method_card_body':
        'On the first screen, select how you\'ll be delivering the packages.',
    'delivery_training_verify_identity_header': 'VERIFY IDENTITY',
    'delivery_training_verify_identity_card_body':
        'The Delivery App might ask you to take a selfie to verify your identity. Follow the Delivery App instructions while taking a selfie.',
    'delivery_training_verify_identity_instructions_title': 'Instructions',
    'delivery_training_verify_identity_instructions_body':
        'To continue delivering, please help us verify your identity by taking a selfie. Do not take a selfie while driving. This photo won\'t be shown to customers.',
    'delivery_training_verify_identity_tips_title': 'Tips',
    'delivery_training_verify_identity_tip_1': 'Do not wear sunglasses',
    'delivery_training_verify_identity_tip_2': 'Face the camera directly',
    'delivery_training_verify_identity_tip_3': 'Avoid light sources behind you',
    'delivery_training_verify_identity_tip_4': 'Use good lighting on your face',
    'delivery_training_verify_identity_tip_5':
        'Have only your face in the picture',
    'delivery_training_verify_identity_tip_6':
        'Please remove hats that cover your face',
    'delivery_training_verify_identity_take_photo': 'Take photo',
    'delivery_training_step_country_selection':
        'Select the country flow that matches your delivery station.',
    'delivery_training_step_open_itinerary_tab':
        'Open Itinerary to see your assigned stops in execution order.',
    'delivery_training_step_itinerary_overview':
        'Review addresses and time windows before starting delivery.',
    'delivery_training_step_itinerary_locations_prompt':
        'From itinerary list, review all delivery locations assigned to your route.',
    'delivery_training_step_itinerary_delivery_type_prompt':
        'Check delivery type badges in the itinerary list.',
    'delivery_training_step_itinerary_map_tap_prompt':
        'Move on to the Itinerary Map screen from the top tabs.',
    'delivery_training_step_itinerary_map_locations_prompt':
        'Review delivery locations on the Itinerary Map screen.',
    'delivery_training_step_itinerary_summary_tap_prompt':
        'Move to Summary from the top tabs.',
    'delivery_training_step_itinerary_summary_overview_prompt':
        'Review remaining package information in Summary.',
    'delivery_training_step_open_stop':
        'Open a stop card to access stop-level actions.',
    'delivery_training_step_customer_notes':
        'Always follow customer notes when the requested location is safe.',
    'delivery_training_step_delivery_access':
        'Use access information and key instructions when available.',
    'delivery_training_step_external_navigation':
        'Open external navigation if additional routing help is needed.',
    'delivery_training_step_open_map_tab':
        'Switch to Map view for route context and nearby stop planning.',
    'delivery_training_step_map_guidance':
        'Use the map to confirm stop position before approaching.',
    'delivery_training_step_open_summary_tab':
        'Open Summary to track remaining work during the route.',
    'delivery_training_step_summary_guidance':
        'Monitor stops, locations, and package progress in Summary.',
    'delivery_training_step_open_menu':
        'Open the main menu for support and app-level options.',
    'delivery_training_step_open_settings':
        'Open Settings to manage app configuration.',
    'delivery_training_step_offline_maps':
        'Check Offline Maps before leaving station to avoid navigation gaps.',
    'delivery_training_step_help_menu':
        'Use Help whenever you need in-app guidance.',
    'delivery_training_step_otp_support':
        'If customer does not know OTP, ask them to scan the QR on their OTP badge.',
    'delivery_training_step_identity_verification':
        'Identity checks may require a selfie. Follow app instructions safely.',
    'delivery_training_step_feedback_quality':
        'Delivery quality affects customer feedback and score.',
    'delivery_training_step_completion':
        'You are ready for door-to-door deliveries. Continue with confidence.',
  };

  static final Map<String, Map<String, String>>
  _deliveryTrainingLocalizedValues = {
    'en': _deliveryTrainingSharedValues,
    'de': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_activity_subtitle':
          'Hauptablauf der App, Tabs, Hinweise und Schnellaktionen',
      'delivery_training_status_not_started': 'Nicht gestartet',
      'delivery_training_status_in_progress': 'In Bearbeitung',
      'delivery_training_status_completed': 'Abgeschlossen',
      'delivery_training_last_completed': 'Zuletzt abgeschlossen: {date}',
      'delivery_training_review': 'Ansehen',
      'delivery_training_restart_activity': 'Training neu starten',
      'delivery_training_resume': 'Fortsetzen',
      'delivery_training_start_now': 'Jetzt starten',
      'delivery_training_restart_tooltip': 'Neu starten',
      'delivery_training_next': 'Weiter',
      'delivery_training_finish': 'Training beenden',
      'delivery_training_done': 'Abgeschlossen',
      'delivery_training_welcome_body':
          'Lerne den Kernablauf in der Delivery App.',
      'delivery_training_launch_button': 'Hier tippen zum Starten',
      'delivery_training_step_launch':
          'Starte das Training und bereite die App fuer deine Route vor.',
      'delivery_training_step_type_of_deliveries':
          'Prufe die Einfuhrung zu Lieferarten und fahre fort.',
      'delivery_training_step_door_to_door':
          'Tür-zu-Tür-Lieferungen erfolgen direkt zum Kundenhaus.',
      'delivery_training_door_to_door_title': 'Tür zu Tür',
      'delivery_training_door_to_door_body':
          'Liefere Pakete direkt zum Zuhause des Kunden.',
      'delivery_training_step_completion':
          'Du bist bereit fuer Tür-zu-Tür-Lieferungen.',
    },
    'sq': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_status_not_started': 'Nuk ka filluar',
      'delivery_training_status_in_progress': 'Ne progres',
      'delivery_training_status_completed': 'Perfunduar',
      'delivery_training_last_completed': 'Perfunduar se fundmi: {date}',
      'delivery_training_review': 'Rishiko',
      'delivery_training_restart_activity': 'Rinis aktivitetin',
      'delivery_training_resume': 'Vazhdo',
      'delivery_training_start_now': 'Fillo tani',
      'delivery_training_restart_tooltip': 'Rinis',
      'delivery_training_next': 'Tjetra',
      'delivery_training_finish': 'Perfundo trajnimin',
      'delivery_training_done': 'Perfunduar',
      'delivery_training_welcome_body':
          'Meso rrjedhen kryesore te aplikacionit te dorezimit.',
      'delivery_training_launch_button': 'Kliko ketu per ta nisur',
      'delivery_training_step_type_of_deliveries':
          'Shiko hyrjen e llojeve te dorezimit dhe vazhdo.',
      'delivery_training_step_door_to_door':
          'Dorezimet dere me dere behen direkt ne shtepine e klientit.',
      'delivery_training_door_to_door_title': 'Dere me Dere',
      'delivery_training_door_to_door_body':
          'Dorezo pakot direkt ne shtepine e Klientit.',
    },
    'hu': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_status_not_started': 'Nincs elkezdve',
      'delivery_training_status_in_progress': 'Folyamatban',
      'delivery_training_status_completed': 'Befejezve',
      'delivery_training_last_completed': 'Utolso teljesites: {date}',
      'delivery_training_review': 'Attekintes',
      'delivery_training_restart_activity': 'Trening ujrainditasa',
      'delivery_training_resume': 'Folytatas',
      'delivery_training_start_now': 'Inditas most',
      'delivery_training_restart_tooltip': 'Ujrainditas',
      'delivery_training_next': 'Kovetkezo',
      'delivery_training_finish': 'Trening befejezese',
      'delivery_training_done': 'Befejezve',
      'delivery_training_welcome_body':
          'Ismerd meg a delivery app fo munkafolyamatait.',
      'delivery_training_launch_button': 'Kattints ide az inditashoz',
      'delivery_training_step_type_of_deliveries':
          'Tekintsd at a kezbesitesi tipusok bevezeteset, majd folytasd.',
      'delivery_training_step_door_to_door':
          'Az ajtotol ajtoig kezbesites kozvetlenul az ugyfel otthonaba tortenik.',
      'delivery_training_door_to_door_title': 'Ajtotol Ajtoig',
      'delivery_training_door_to_door_body':
          'A csomagokat kozvetlenul az Ugyfel otthonaba kezbesitsd.',
    },
    'ro': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_status_not_started': 'Neinceput',
      'delivery_training_status_in_progress': 'In progres',
      'delivery_training_status_completed': 'Finalizat',
      'delivery_training_last_completed': 'Ultima finalizare: {date}',
      'delivery_training_review': 'Revizuire',
      'delivery_training_restart_activity': 'Reporneste activitatea',
      'delivery_training_resume': 'Continua',
      'delivery_training_start_now': 'Incepe acum',
      'delivery_training_restart_tooltip': 'Reporneste',
      'delivery_training_next': 'Urmatorul',
      'delivery_training_finish': 'Finalizeaza trainingul',
      'delivery_training_done': 'Finalizat',
      'delivery_training_welcome_body':
          'Invata fluxul principal din aplicatia de livrare.',
      'delivery_training_launch_button': 'Apasa aici pentru pornire',
      'delivery_training_step_type_of_deliveries':
          'Revizuieste introducerea tipurilor de livrare si continua.',
      'delivery_training_step_door_to_door':
          'Livrarile door-to-door se fac direct la domiciliul clientului.',
      'delivery_training_door_to_door_title': 'Door to Door',
      'delivery_training_door_to_door_body':
          'Livreaza pachetele direct la domiciliul Clientului.',
    },
    'hr': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_status_not_started': 'Nije zapoceto',
      'delivery_training_status_in_progress': 'U tijeku',
      'delivery_training_status_completed': 'Zavrseno',
      'delivery_training_last_completed': 'Zadnje zavrseno: {date}',
      'delivery_training_review': 'Pregled',
      'delivery_training_restart_activity': 'Ponovno pokreni aktivnost',
      'delivery_training_resume': 'Nastavi',
      'delivery_training_start_now': 'Pokreni sada',
      'delivery_training_restart_tooltip': 'Ponovno pokreni',
      'delivery_training_next': 'Dalje',
      'delivery_training_finish': 'Zavrsi trening',
      'delivery_training_done': 'Zavrseno',
      'delivery_training_welcome_body':
          'Nauci glavni tijek rada u aplikaciji za dostavu.',
      'delivery_training_launch_button': 'Klikni ovdje za pokretanje',
      'delivery_training_step_type_of_deliveries':
          'Pregledaj uvod o vrstama dostave i nastavi.',
      'delivery_training_step_door_to_door':
          'Dostava od vrata do vrata ide izravno na adresu kupca.',
      'delivery_training_door_to_door_title': 'Od Vrata do Vrata',
      'delivery_training_door_to_door_body':
          'Dostavi pakete izravno na adresu Kupca.',
    },
    'ar': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_status_not_started': 'لم يبدأ',
      'delivery_training_status_in_progress': 'قيد التنفيذ',
      'delivery_training_status_completed': 'مكتمل',
      'delivery_training_last_completed': 'آخر إكمال: {date}',
      'delivery_training_review': 'مراجعة',
      'delivery_training_restart_activity': 'إعادة بدء النشاط',
      'delivery_training_resume': 'متابعة',
      'delivery_training_start_now': 'ابدأ الآن',
      'delivery_training_restart_tooltip': 'إعادة البدء',
      'delivery_training_next': 'التالي',
      'delivery_training_finish': 'إنهاء التدريب',
      'delivery_training_done': 'مكتمل',
      'delivery_training_welcome_title': 'أنواع التسليم',
      'delivery_training_welcome_body':
          'تعرّف على سير العمل الأساسي داخل تطبيق التسليم.',
      'delivery_training_launch_button': 'اضغط هنا للبدء',
      'delivery_training_step_type_of_deliveries':
          'راجع مقدمة أنواع التسليم ثم تابع.',
      'delivery_training_step_door_to_door':
          'تسليم الباب إلى الباب يتم مباشرة إلى منزل العميل.',
      'delivery_training_door_to_door_title': 'الباب إلى الباب',
      'delivery_training_door_to_door_body':
          'سلّم الطرود مباشرة إلى منزل العميل.',
    },
    'tr': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_status_not_started': 'Baslamadi',
      'delivery_training_status_in_progress': 'Devam ediyor',
      'delivery_training_status_completed': 'Tamamlandi',
      'delivery_training_last_completed': 'Son tamamlama: {date}',
      'delivery_training_review': 'Gozden gecir',
      'delivery_training_restart_activity': 'Etkinligi yeniden baslat',
      'delivery_training_resume': 'Devam et',
      'delivery_training_start_now': 'Simdi basla',
      'delivery_training_restart_tooltip': 'Yeniden baslat',
      'delivery_training_next': 'Ileri',
      'delivery_training_finish': 'Egitimi bitir',
      'delivery_training_done': 'Tamamlandi',
      'delivery_training_welcome_body':
          'Teslimat uygulamasindaki temel is akislarini ogren.',
      'delivery_training_launch_button': 'Baslatmak icin buraya dokun',
      'delivery_training_step_type_of_deliveries':
          'Teslimat turleri girisini inceleyin ve devam edin.',
      'delivery_training_step_door_to_door':
          'Kapiya teslimatlar dogrudan musteri evine yapilir.',
      'delivery_training_door_to_door_title': 'Door to Door',
      'delivery_training_door_to_door_body':
          'Paketleri dogrudan Musterinin evine teslim edin.',
    },
    'ru': {
      ..._deliveryTrainingSharedValues,
      'delivery_training_status_not_started': 'Не начато',
      'delivery_training_status_in_progress': 'В процессе',
      'delivery_training_status_completed': 'Завершено',
      'delivery_training_last_completed': 'Последнее завершение: {date}',
      'delivery_training_review': 'Просмотр',
      'delivery_training_restart_activity': 'Перезапустить активность',
      'delivery_training_resume': 'Продолжить',
      'delivery_training_start_now': 'Начать сейчас',
      'delivery_training_restart_tooltip': 'Перезапуск',
      'delivery_training_next': 'Далее',
      'delivery_training_finish': 'Завершить обучение',
      'delivery_training_done': 'Завершено',
      'delivery_training_welcome_title': 'Типы доставок',
      'delivery_training_welcome_body':
          'Изучите основной рабочий процесс в приложении доставки.',
      'delivery_training_launch_button': 'Нажмите здесь для запуска',
      'delivery_training_step_type_of_deliveries':
          'Ознакомьтесь с вводной частью по типам доставок и продолжайте.',
      'delivery_training_step_door_to_door':
          'Доставка door-to-door выполняется прямо к дому клиента.',
      'delivery_training_door_to_door_title': 'Door to Door',
      'delivery_training_door_to_door_body':
          'Доставляйте посылки прямо к дому Клиента.',
    },
  };

  // Overrides for Delivery Training strings that are still in English in
  // non-English locale maps.
  static final Map<String, Map<String, String>>
  _deliveryTrainingLocalizedOverrides = {
    'de': {
      'delivery_training_module_title': 'MEU - Lieferablauf',
      'delivery_training_step_of_total': 'Schritt {current}/{total}',
      'delivery_training_welcome_title': 'Lieferarten',
      'delivery_training_lockers_title': 'Locker',
      'delivery_training_counters_title': 'Schalter',
      'delivery_training_otr_header': 'TUeR-ZU-TUeR-LIEFERUNGEN',
      'delivery_training_concessions_title': 'Kulanzfaelle',
      'delivery_training_delivery_app_usage_title': 'Nutzung der Delivery App',
      'delivery_training_delivery_app_overview_header':
          'UEBERSICHT DELIVERY APP',
      'delivery_training_transportation_method_header': 'TRANSPORTMETHODE',
      'delivery_training_transportation_method_question':
          'Welche Transportmethode bevorzugst du?',
      'delivery_training_transportation_method_walk': 'Zu Fuss',
      'delivery_training_transportation_method_bike': 'Fahrrad',
      'delivery_training_verify_identity_header': 'IDENTITAET BESTAETIGEN',
      'delivery_training_verify_identity_tips_title': 'Tipps',
      'delivery_training_verify_identity_take_photo': 'Foto aufnehmen',
      'delivery_training_offline_maps_prompt_title': 'Uebersicht',
      'delivery_training_settings_prompt_current_stop': 'Aktueller Stopp',
      'delivery_training_settings_prompt_feedback': 'Rueckmeldung',
      'delivery_training_settings_prompt_settings': 'Einstellungen',
      'delivery_training_settings_prompt_breaks': 'Pausen',
      'delivery_training_settings_prompt_driver_support': 'Fahrer-Support',
      'delivery_training_settings_prompt_emergency_help': 'Notfallhilfe',
      'delivery_training_offline_maps_settings_header': 'EINSTELLUNGEN',
      'delivery_training_offline_maps_settings_personal':
          'Persoenliche Informationen',
      'delivery_training_offline_maps_settings_phone': 'Telefonnummer',
      'delivery_training_offline_maps_settings_legal':
          'Rechtliche Informationen anzeigen',
      'delivery_training_offline_maps_settings_offline': 'Offline-Karten',
      'delivery_training_offline_maps_settings_version': 'Versionsinfo',
      'delivery_training_offline_maps_settings_device': 'Geraete-ID',
      'delivery_training_offline_maps_settings_sign_out': 'ABMELDEN',
      'delivery_training_offline_maps_download_header': 'OFFLINE-KARTEN',
      'delivery_training_offline_maps_download_settings':
          'Download-Einstellungen',
      'delivery_training_offline_maps_downloaded_title':
          'Heruntergeladene Karten',
      'delivery_training_offline_maps_other_maps': 'Weitere Karten',
      'delivery_training_screen_title_overview': 'Uebersicht',
      'delivery_training_screen_title_itinerary': 'Itinerarliste',
      'delivery_training_screen_title_itinerary_list_lower': 'Itinerarliste',
      'delivery_training_itinerary_prompt_access': '1-Klick-Zugriff',
      'delivery_training_screen_title_map': 'Itinerarkarte',
      'delivery_training_screen_title_itinerary_map_lower': 'Itinerarkarte',
      'delivery_training_screen_title_summary': 'Zusammenfassung',
      'delivery_training_summary_work_remaining': 'Verbleibende Arbeit',
      'delivery_training_summary_stops_count': '5 Stopps',
      'delivery_training_summary_locations_count': '8 Orte',
      'delivery_training_summary_packages_count': '9 Pakete',
      'delivery_training_summary_stops_header': 'Stopps',
      'delivery_training_screen_title_type_of_deliveries': 'Lieferarten',
      'delivery_training_screen_title_door_to_door': 'Tür zu Tür',
      'delivery_training_screen_title_lockers': 'Locker',
      'delivery_training_screen_title_counters': 'Schalter',
      'delivery_training_screen_title_otr_supplies': 'Tür-zu-Tür-Lieferungen',
      'delivery_training_screen_title_otp_badge': 'Tür-zu-Tür-Lieferungen',
      'delivery_training_screen_title_weather_bags': 'Tür-zu-Tür-Lieferungen',
      'delivery_training_screen_title_ready_to_go': 'Tür-zu-Tür-Lieferungen',
      'delivery_training_screen_title_customer_arrival':
          'Tür-zu-Tür-Lieferungen',
      'delivery_training_screen_title_customer_feedback':
          'Tür-zu-Tür-Lieferungen',
      'delivery_training_screen_title_concessions': 'Kulanzfaelle',
      'delivery_training_screen_title_delivery_app_usage':
          'Nutzung der Delivery App',
      'delivery_training_screen_title_delivery_app_overview':
          'Uebersicht Delivery App',
      'delivery_training_screen_title_transportation_method':
          'Transportmethode',
      'delivery_training_screen_title_verify_identity':
          'Identitaet bestaetigen',
      'delivery_training_screen_title_menu': 'Hauptmenue',
      'delivery_training_screen_title_settings': 'Einstellungen',
      'delivery_training_screen_title_offline_maps': 'Offline-Karten',
      'delivery_training_screen_title_stop_details': 'Stopp-Details',
      'delivery_training_lockers_body':
          'Amazon-Locker-Standorte ermoeglichen Kunden eine einfache Abholung und Rueckgabe von Paketen.',
      'delivery_training_counters_body':
          'Besetzte Standorte, an denen Partnerflaeche als Abholpunkt angeboten wird.',
      'delivery_training_otr_body_1':
          'Bevor wir die Prozesse in der Delivery App fuer Tür-zu-Tür-Lieferungen ansehen, schauen wir auf die Ausruestung im OTR-Supplies-Trolley der DS.',
      'delivery_training_otr_body_2':
          'Der Trolley steht meist nahe der Loadout Area. Danach sehen wir uns die Hauptfunktionen der Delivery App an.',
      'delivery_training_otp_badge_body':
          'Wenn Kunden das One-Time Password (OTP) nicht kennen, bitte den QR-Code auf dem OTP-Badge scannen lassen.',
      'delivery_training_otp_badge_help_body':
          'Danach gelangen sie zur offiziellen Hilfeseite mit Schritten zur OTP-Wiederherstellung.',
      'delivery_training_weather_bags_body':
          'Decke Pakete mit Wetterschutzbeuteln ab, wenn sie Wetter ausgesetzt sind.',
      'delivery_training_ready_to_go_body':
          'Du hast die komplette Ausruestung und bist bereit fuer die Tour.',
      'delivery_training_ready_to_go_footer': 'Los gehts!',
      'delivery_training_customer_arrival_body':
          'Wenn du an der Lieferadresse geparkt hast, kannst du den Kunden in der Delivery App anrufen oder schreiben und die Ankunft melden.',
      'delivery_training_customer_feedback_body':
          'Nach der Zustellung erhalten Kunden eine Umfrage zur Bewertung ihrer Erfahrung.',
      'delivery_training_concessions_body':
          'Wenn die Zustellerfahrung negativ war, koennen Kunden Erstattung oder Kulanz anfragen.',
      'delivery_training_delivery_app_usage_body':
          'In diesem Training lernst du, wie du Kulanzfaelle durch korrekte Nutzung der Delivery App vermeidest.',
      'delivery_training_delivery_app_overview_body':
          'Die Delivery App ist das wichtigste Werkzeug fuer Zustellungen.\n\nWenn dein DSP es nicht verlangt, deinstalliere sie nie vom Geraet.\n\nSchauen wir uns die Hauptfunktionen der Delivery App an!',
      'delivery_training_offline_maps_prompt_body':
          'Du kannst Offline-Karten im Hauptmenue oben links herunterladen.\n\nTippe darauf!',
      'delivery_training_settings_prompt_body':
          'Tippe im Hauptmenue auf Einstellungen.\n\nTippe darauf!',
      'delivery_training_offline_maps_allow_body':
          'Wenn kein WLAN verfuegbar ist, werden Kartenupdates ueber mobile Daten geladen.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB Karte',
      'delivery_training_overview_intro_prompt_body':
          'Im Uebersichtsbildschirm findest du Infos fuer Zustellung und Problemloesung.\n\nSchauen wir rein!',
    },
    'sq': {
      'delivery_training_module_title': 'MEU - Rrjedha e dorezimit',
      'delivery_training_step_of_total': 'Hapi {current}/{total}',
      'delivery_training_welcome_title': 'Llojet e dorezimit',
      'delivery_training_lockers_title': 'Locker',
      'delivery_training_counters_title': 'Pika sporteli',
      'delivery_training_otr_header': 'DOREZIME DERE ME DERE',
      'delivery_training_concessions_title': 'Koncesione',
      'delivery_training_delivery_app_usage_title': 'Perdorimi i Delivery App',
      'delivery_training_delivery_app_overview_header':
          'PAMJE E PERGJITHSHME E DELIVERY APP',
      'delivery_training_transportation_method_header': 'MENYRA E TRANSPORTIT',
      'delivery_training_transportation_method_question':
          'Cilen menyre transporti preferon?',
      'delivery_training_transportation_method_walk': 'Ne kembe',
      'delivery_training_transportation_method_bike': 'Biçiklete',
      'delivery_training_verify_identity_header': 'VERIFIKO IDENTITETIN',
      'delivery_training_verify_identity_tips_title': 'Keshilla',
      'delivery_training_verify_identity_take_photo': 'Bej foto',
      'delivery_training_offline_maps_prompt_title': 'Permbledhje',
      'delivery_training_settings_prompt_current_stop': 'Ndalimi aktual',
      'delivery_training_settings_prompt_feedback': 'Reagime',
      'delivery_training_settings_prompt_settings': 'Cilesimet',
      'delivery_training_settings_prompt_breaks': 'Pushime',
      'delivery_training_settings_prompt_driver_support':
          'Mbeshtejtje per shoferin',
      'delivery_training_settings_prompt_emergency_help': 'Ndihme emergjente',
      'delivery_training_offline_maps_settings_header': 'CILESIMET',
      'delivery_training_offline_maps_settings_personal': 'Te dhena personale',
      'delivery_training_offline_maps_settings_phone': 'Numri i telefonit',
      'delivery_training_offline_maps_settings_legal':
          'Shiko informacionin ligjor',
      'delivery_training_offline_maps_settings_offline': 'Harta offline',
      'delivery_training_offline_maps_settings_version':
          'Informacion i versionit',
      'delivery_training_offline_maps_settings_device':
          'Identifikues pajisjeje',
      'delivery_training_offline_maps_settings_sign_out': 'DIL',
      'delivery_training_offline_maps_download_header': 'HARTA OFFLINE',
      'delivery_training_offline_maps_download_settings':
          'Cilesimet e shkarkimit',
      'delivery_training_offline_maps_downloaded_title': 'Hartat e shkarkuara',
      'delivery_training_offline_maps_other_maps': 'Harta te tjera',
      'delivery_training_screen_title_overview': 'Permbledhje',
      'delivery_training_screen_title_itinerary': 'Lista e itinerarit',
      'delivery_training_screen_title_itinerary_list_lower':
          'Lista e itinerarit',
      'delivery_training_itinerary_prompt_access': 'Qasje me 1 klik',
      'delivery_training_screen_title_map': 'Harta e itinerarit',
      'delivery_training_screen_title_itinerary_map_lower':
          'Harta e itinerarit',
      'delivery_training_screen_title_summary': 'Permbledhje',
      'delivery_training_summary_work_remaining': 'Pune e mbetur',
      'delivery_training_summary_stops_count': '5 ndalesa',
      'delivery_training_summary_locations_count': '8 lokacione',
      'delivery_training_summary_packages_count': '9 pako',
      'delivery_training_summary_stops_header': 'Ndalesa',
      'delivery_training_screen_title_type_of_deliveries': 'Llojet e dorezimit',
      'delivery_training_screen_title_door_to_door': 'Dere me dere',
      'delivery_training_screen_title_lockers': 'Locker',
      'delivery_training_screen_title_counters': 'Pika sporteli',
      'delivery_training_screen_title_otr_supplies': 'Dorezime dere me dere',
      'delivery_training_screen_title_otp_badge': 'Dorezime dere me dere',
      'delivery_training_screen_title_weather_bags': 'Dorezime dere me dere',
      'delivery_training_screen_title_ready_to_go': 'Dorezime dere me dere',
      'delivery_training_screen_title_customer_arrival':
          'Dorezime dere me dere',
      'delivery_training_screen_title_customer_feedback':
          'Dorezime dere me dere',
      'delivery_training_screen_title_concessions': 'Koncesione',
      'delivery_training_screen_title_delivery_app_usage':
          'Perdorimi i Delivery App',
      'delivery_training_screen_title_delivery_app_overview':
          'Pamje e Delivery App',
      'delivery_training_screen_title_transportation_method':
          'Menyra e transportit',
      'delivery_training_screen_title_verify_identity': 'Verifiko identitetin',
      'delivery_training_screen_title_menu': 'Menuja kryesore',
      'delivery_training_screen_title_settings': 'Cilesimet',
      'delivery_training_screen_title_offline_maps': 'Harta offline',
      'delivery_training_screen_title_stop_details': 'Detajet e ndalese',
      'delivery_training_lockers_body':
          'Lokacionet Amazon Locker i lejojne klientet te marrin dhe te kthejne pakot lehtesisht.',
      'delivery_training_counters_body':
          'Lokacione me staf ku partneret ofrojne hapesire ne dyqan si pike marrjeje.',
      'delivery_training_otr_body_1':
          'Para proceseve ne Delivery App per dorezimet dere me dere, shikojme pajisjet ne OTR Supplies Trolley te DS.',
      'delivery_training_otr_body_2':
          'Trollei zakonisht eshte afer zonës se ngarkimit. Me pas shohim funksionet kryesore te Delivery App.',
      'delivery_training_otp_badge_body':
          'Nese klientet nuk e dine OTP-ne, kerkoju te skanojne kodin QR ne OTP badge.',
      'delivery_training_otp_badge_help_body':
          'Ata do te drejtohen ne faqen zyrtare te ndihmes per rikuperimin e OTP.',
      'delivery_training_weather_bags_body':
          'Mbuloni pakot me qese moti kur jane te ekspozuara ndaj kushteve te motit.',
      'delivery_training_ready_to_go_body':
          'Keni te gjitha pajisjet e dorezimit dhe jeni gati per rruge.',
      'delivery_training_ready_to_go_footer': 'Le te nisim!',
      'delivery_training_customer_arrival_body':
          'Kur parkoni ne adrese, Delivery App ju lejon te telefononi ose te dergoni mesazh klientit per ardhjen.',
      'delivery_training_customer_feedback_body':
          'Kur dorezimi perfundon, klientet marrin nje ankete per te vleresuar eksperiencen.',
      'delivery_training_concessions_body':
          'Nese eksperienca e dorezimit ishte negative, klientet mund te kerkojne rimbursim ose koncesion.',
      'delivery_training_delivery_app_usage_body':
          'Ne kete trajnim mesojme si te shmangim koncesionet duke perdorur sakte Delivery App.',
      'delivery_training_delivery_app_overview_body':
          'Delivery App eshte mjeti kryesor per dorezime.\n\nNese DSP nuk ju kerkon, mos e cinstaloni nga pajisja.\n\nLe te shohim funksionet kryesore!',
      'delivery_training_offline_maps_prompt_body':
          'Mund te shkarkoni harta offline nga menuja kryesore ne cepin e siperm majtas.\n\nPreke!',
      'delivery_training_settings_prompt_body':
          'Nga menuja kryesore, prekni Cilesimet.\n\nPreke!',
      'delivery_training_offline_maps_allow_body':
          'Nese Wi-Fi nuk eshte i disponueshem, hartat do te perditesohen me internet celular.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB harte',
      'delivery_training_overview_intro_prompt_body':
          'Ne ekranin e permbledhjes gjeni informacion per dorezimin dhe zgjidhjen e problemeve.\n\nLe te shohim!',
    },
    'hu': {
      'delivery_training_module_title': 'MEU - Kezbesitesi munkafolyamat',
      'delivery_training_step_of_total': 'Lepes {current}/{total}',
      'delivery_training_welcome_title': 'Kezbesitesi tipusok',
      'delivery_training_lockers_title': 'Lockerek',
      'delivery_training_counters_title': 'Atveteli pontok',
      'delivery_training_otr_header': 'AJTOTOL AJTOIG KEZBESITES',
      'delivery_training_concessions_title': 'Kompenzaciok',
      'delivery_training_delivery_app_usage_title': 'Delivery App hasznalata',
      'delivery_training_delivery_app_overview_header':
          'DELIVERY APP ATTEKINTES',
      'delivery_training_transportation_method_header': 'SZALLITASI MOD',
      'delivery_training_transportation_method_question':
          'Melyik szallitasi modot preferalod?',
      'delivery_training_transportation_method_walk': 'Gyalog',
      'delivery_training_transportation_method_bike': 'Kerekpar',
      'delivery_training_verify_identity_header':
          'SZEMELYAZONOSSAG ELLENORZESE',
      'delivery_training_verify_identity_tips_title': 'Tippek',
      'delivery_training_verify_identity_take_photo': 'Foto keszitese',
      'delivery_training_offline_maps_prompt_title': 'Attekintes',
      'delivery_training_settings_prompt_current_stop': 'Aktualis stop',
      'delivery_training_settings_prompt_feedback': 'Visszajelzes',
      'delivery_training_settings_prompt_settings': 'Beallitasok',
      'delivery_training_settings_prompt_breaks': 'Szünetek',
      'delivery_training_settings_prompt_driver_support': 'Sofor tamogatas',
      'delivery_training_settings_prompt_emergency_help': 'Surgossegi segitseg',
      'delivery_training_offline_maps_settings_header': 'BEALLITASOK',
      'delivery_training_offline_maps_settings_personal': 'Szemelyes adatok',
      'delivery_training_offline_maps_settings_phone': 'Telefonszam',
      'delivery_training_offline_maps_settings_legal':
          'Jogi informaciok megtekintese',
      'delivery_training_offline_maps_settings_offline': 'Offline terkep',
      'delivery_training_offline_maps_settings_version': 'Verzioinformacio',
      'delivery_training_offline_maps_settings_device': 'Eszkozonosito',
      'delivery_training_offline_maps_settings_sign_out': 'KIJELENTKEZES',
      'delivery_training_offline_maps_download_header': 'OFFLINE TERKEPEK',
      'delivery_training_offline_maps_download_settings':
          'Letoltesi beallitasok',
      'delivery_training_offline_maps_downloaded_title': 'Letoltott terkep',
      'delivery_training_offline_maps_other_maps': 'Tovabbi terkepek',
      'delivery_training_screen_title_overview': 'Attekintes',
      'delivery_training_screen_title_itinerary': 'Itinerary lista',
      'delivery_training_screen_title_itinerary_list_lower': 'Itinerary lista',
      'delivery_training_itinerary_prompt_access': '1-kattintas hozzaferes',
      'delivery_training_screen_title_map': 'Itinerary terkep',
      'delivery_training_screen_title_itinerary_map_lower': 'Itinerary terkep',
      'delivery_training_screen_title_summary': 'Osszegzes',
      'delivery_training_summary_work_remaining': 'Hatrallevo munka',
      'delivery_training_summary_stops_count': '5 stop',
      'delivery_training_summary_locations_count': '8 helyszin',
      'delivery_training_summary_packages_count': '9 csomag',
      'delivery_training_summary_stops_header': 'Stopok',
      'delivery_training_screen_title_type_of_deliveries':
          'Kezbesitesi tipusok',
      'delivery_training_screen_title_door_to_door': 'Ajtotol ajtoig',
      'delivery_training_screen_title_lockers': 'Lockerek',
      'delivery_training_screen_title_counters': 'Atveteli pontok',
      'delivery_training_screen_title_otr_supplies':
          'Ajtotol ajtoig kezbesites',
      'delivery_training_screen_title_otp_badge': 'Ajtotol ajtoig kezbesites',
      'delivery_training_screen_title_weather_bags':
          'Ajtotol ajtoig kezbesites',
      'delivery_training_screen_title_ready_to_go': 'Ajtotol ajtoig kezbesites',
      'delivery_training_screen_title_customer_arrival':
          'Ajtotol ajtoig kezbesites',
      'delivery_training_screen_title_customer_feedback':
          'Ajtotol ajtoig kezbesites',
      'delivery_training_screen_title_concessions': 'Kompenzaciok',
      'delivery_training_screen_title_delivery_app_usage':
          'Delivery App hasznalata',
      'delivery_training_screen_title_delivery_app_overview':
          'Delivery App attekintes',
      'delivery_training_screen_title_transportation_method': 'Szallitasi mod',
      'delivery_training_screen_title_verify_identity':
          'Szemelyazonossag ellenorzese',
      'delivery_training_screen_title_menu': 'Fo menu',
      'delivery_training_screen_title_settings': 'Beallitasok',
      'delivery_training_screen_title_offline_maps': 'Offline terkep',
      'delivery_training_screen_title_stop_details': 'Stop reszletei',
      'delivery_training_lockers_body':
          'Az Amazon Locker helyek lehetove teszik a csomagok konnyu atvetelet es visszaadasat.',
      'delivery_training_counters_body':
          'Szemelyzettel mukodo helyek, ahol a partnerek atveteli pontot biztositanak.',
      'delivery_training_otr_body_1':
          'Mielott a Delivery App folyamatait atneznenk, nezzuk meg a DS OTR Supplies trolijaban elerheto felszereleseket.',
      'delivery_training_otr_body_2':
          'A troli altalaban a Loadout Area kozeleben van. Ezutan atnezzuk a Delivery App fo funkcioit.',
      'delivery_training_otp_badge_body':
          'Ha az ugyfel nem ismeri az OTP-t, kerd meg, hogy olvassa be az OTP badge QR-kodjat.',
      'delivery_training_otp_badge_help_body':
          'Ezutan a hivatalos segitsegoldalra jut, ahol visszaallithato az OTP.',
      'delivery_training_weather_bags_body':
          'Takard le a csomagokat idojarasi tasakokkal, ha ki vannak teve az idojarasnak.',
      'delivery_training_ready_to_go_body':
          'Minden szukseges felszereles nalad van, indulhatsz az utra.',
      'delivery_training_ready_to_go_footer': 'Induljunk!',
      'delivery_training_customer_arrival_body':
          'A cimre erve a Delivery App segitsegevel hivhatod vagy uzenetet kuldhetsz az ugyfelnek az erkezesrol.',
      'delivery_training_customer_feedback_body':
          'A kezbesites utan az ugyfel kerdoivet kap az elmeny ertekelesere.',
      'delivery_training_concessions_body':
          'Ha a kezbesitesi elmeny negativ, az ugyfel visszateritest vagy kompenzaciot kerhet.',
      'delivery_training_delivery_app_usage_body':
          'Ebben a treningben megtanuljuk, hogyan keruljuk el a kompenzaciokat a Delivery App helyes hasznalataval.',
      'delivery_training_delivery_app_overview_body':
          'A Delivery App a kezbesites fo eszkoze.\n\nHa a DSP nem keri, soha ne tavolitsd el az eszkozrol.\n\nNezzuk at a Delivery App fo funkcioit!',
      'delivery_training_offline_maps_prompt_body':
          'Offline terkepet a fo menubol, bal felul tudsz letolteni.\n\nErintsd meg!',
      'delivery_training_settings_prompt_body':
          'A fo menubol nyisd meg a Beallitasok pontot.\n\nErintsd meg!',
      'delivery_training_offline_maps_allow_body':
          'Ha nincs Wi-Fi, a terkepfrissitesek mobiladatot hasznalnak.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB terkep',
      'delivery_training_overview_intro_prompt_body':
          'Az attekintes kepernyon a kezbesiteshez es hibakezeleshez szukseges informaciokat talalsz.\n\nNezzuk meg!',
    },
    'ro': {
      'delivery_training_module_title': 'MEU - Fluxul de livrare',
      'delivery_training_step_of_total': 'Pasul {current}/{total}',
      'delivery_training_welcome_title': 'Tipuri de livrare',
      'delivery_training_door_to_door_title': 'Usa la usa',
      'delivery_training_lockers_title': 'Lockere',
      'delivery_training_counters_title': 'Puncte ghiseu',
      'delivery_training_otr_header': 'LIVRARI USA LA USA',
      'delivery_training_concessions_title': 'Concesii',
      'delivery_training_delivery_app_usage_title': 'Utilizarea Delivery App',
      'delivery_training_delivery_app_overview_header':
          'PREZENTARE DELIVERY APP',
      'delivery_training_transportation_method_header': 'METODA DE TRANSPORT',
      'delivery_training_transportation_method_question':
          'Ce metoda de transport preferi?',
      'delivery_training_transportation_method_walk': 'Pe jos',
      'delivery_training_transportation_method_bike': 'Bicicleta',
      'delivery_training_verify_identity_header': 'VERIFICA IDENTITATEA',
      'delivery_training_verify_identity_tips_title': 'Sfaturi',
      'delivery_training_verify_identity_take_photo': 'Fa o poza',
      'delivery_training_offline_maps_prompt_title': 'Prezentare',
      'delivery_training_settings_prompt_current_stop': 'Oprirea curenta',
      'delivery_training_settings_prompt_feedback': 'Feedback clienti',
      'delivery_training_settings_prompt_settings': 'Setari',
      'delivery_training_settings_prompt_breaks': 'Pauze',
      'delivery_training_settings_prompt_driver_support': 'Suport sofer',
      'delivery_training_settings_prompt_emergency_help': 'Ajutor de urgenta',
      'delivery_training_offline_maps_settings_header': 'SETARI',
      'delivery_training_offline_maps_settings_personal':
          'Informatii personale',
      'delivery_training_offline_maps_settings_phone': 'Numar de telefon',
      'delivery_training_offline_maps_settings_legal': 'Vezi informatii legale',
      'delivery_training_offline_maps_settings_offline': 'Harti offline',
      'delivery_training_offline_maps_settings_version': 'Informatii versiune',
      'delivery_training_offline_maps_settings_device':
          'Identificator dispozitiv',
      'delivery_training_offline_maps_settings_sign_out': 'DECONECTARE',
      'delivery_training_offline_maps_download_header': 'HARTI OFFLINE',
      'delivery_training_offline_maps_download_settings': 'Setari descarcare',
      'delivery_training_offline_maps_downloaded_title': 'Harti descarcate',
      'delivery_training_offline_maps_other_maps': 'Alte harti',
      'delivery_training_screen_title_overview': 'Prezentare',
      'delivery_training_screen_title_itinerary': 'Lista itinerar',
      'delivery_training_screen_title_itinerary_list_lower': 'Lista itinerar',
      'delivery_training_itinerary_prompt_access': 'Acces cu 1 click',
      'delivery_training_screen_title_map': 'Harta itinerar',
      'delivery_training_screen_title_itinerary_map_lower': 'Harta itinerar',
      'delivery_training_screen_title_summary': 'Sumar',
      'delivery_training_summary_work_remaining': 'Munca ramasa',
      'delivery_training_summary_stops_count': '5 opriri',
      'delivery_training_summary_locations_count': '8 locatii',
      'delivery_training_summary_packages_count': '9 colete',
      'delivery_training_summary_stops_header': 'Opriri',
      'delivery_training_screen_title_type_of_deliveries': 'Tipuri de livrare',
      'delivery_training_screen_title_door_to_door': 'Usa la usa',
      'delivery_training_screen_title_lockers': 'Lockere',
      'delivery_training_screen_title_counters': 'Puncte ghiseu',
      'delivery_training_screen_title_otr_supplies': 'Livrari usa la usa',
      'delivery_training_screen_title_otp_badge': 'Livrari usa la usa',
      'delivery_training_screen_title_weather_bags': 'Livrari usa la usa',
      'delivery_training_screen_title_ready_to_go': 'Livrari usa la usa',
      'delivery_training_screen_title_customer_arrival': 'Livrari usa la usa',
      'delivery_training_screen_title_customer_feedback': 'Livrari usa la usa',
      'delivery_training_screen_title_concessions': 'Concesii',
      'delivery_training_screen_title_delivery_app_usage':
          'Utilizarea Delivery App',
      'delivery_training_screen_title_delivery_app_overview':
          'Prezentare Delivery App',
      'delivery_training_screen_title_transportation_method':
          'Metoda de transport',
      'delivery_training_screen_title_verify_identity': 'Verifica identitatea',
      'delivery_training_screen_title_menu': 'Meniu principal',
      'delivery_training_screen_title_settings': 'Setari',
      'delivery_training_screen_title_offline_maps': 'Harti offline',
      'delivery_training_screen_title_stop_details': 'Detalii oprire',
      'delivery_training_lockers_body':
          'Locatiile Amazon Locker permit clientilor sa ridice si sa returneze usor coletele.',
      'delivery_training_counters_body':
          'Locatii cu personal unde partenerii ofera spatiu in magazin ca punct de ridicare.',
      'delivery_training_otr_body_1':
          'Inainte de procesele din Delivery App pentru livrari usa la usa, vedem echipamentele din OTR Supplies Trolley al DS.',
      'delivery_training_otr_body_2':
          'Caruciorul este de obicei aproape de zona Loadout. Apoi vedem functiile principale ale Delivery App.',
      'delivery_training_otp_badge_body':
          'Daca clientii nu stiu OTP-ul, roaga-i sa scaneze codul QR de pe OTP badge.',
      'delivery_training_otp_badge_help_body':
          'Vor fi directionati catre pagina oficiala de ajutor pentru recuperarea OTP.',
      'delivery_training_weather_bags_body':
          'Acopera coletele cu pungi de protectie cand sunt expuse la vreme.',
      'delivery_training_ready_to_go_body':
          'Ai tot echipamentul de livrare si esti gata de drum.',
      'delivery_training_ready_to_go_footer': 'Sa mergem!',
      'delivery_training_customer_arrival_body':
          'Cand ai ajuns la adresa, Delivery App iti permite sa suni sau sa trimiti mesaj clientului pentru a anunta sosirea.',
      'delivery_training_customer_feedback_body':
          'Cand livrarea este finalizata, clientii primesc un sondaj pentru evaluarea experientei.',
      'delivery_training_concessions_body':
          'Daca experienta de livrare a fost negativa, clientii pot cere rambursare sau concesie.',
      'delivery_training_delivery_app_usage_body':
          'In acest training invatam sa evitam concesiile folosind corect Delivery App.',
      'delivery_training_delivery_app_overview_body':
          'Delivery App este instrumentul principal pentru livrari.\n\nDaca DSP nu iti cere, nu il dezinstala niciodata de pe dispozitiv.\n\nHai sa vedem functiile principale!',
      'delivery_training_offline_maps_prompt_body':
          'Poti descarca harti offline din meniul principal, in coltul stanga sus.\n\nApasa pe el!',
      'delivery_training_settings_prompt_body':
          'Din meniul principal, apasa pe Setari.\n\nApasa pe el!',
      'delivery_training_offline_maps_allow_body':
          'Daca Wi-Fi nu este disponibil, hartile vor folosi datele mobile pentru actualizari.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB harta',
      'delivery_training_overview_intro_prompt_body':
          'In ecranul de prezentare gasesti informatii necesare pentru livrare si rezolvarea problemelor.\n\nHai sa vedem!',
    },
    'hr': {
      'delivery_training_module_title': 'MEU - Tijek dostave',
      'delivery_training_step_of_total': 'Korak {current}/{total}',
      'delivery_training_welcome_title': 'Vrste dostave',
      'delivery_training_lockers_title': 'Lockeri',
      'delivery_training_counters_title': 'Pultovi',
      'delivery_training_otr_header': 'DOSTAVE OD VRATA DO VRATA',
      'delivery_training_concessions_title': 'Koncesije',
      'delivery_training_delivery_app_usage_title': 'Koristenje Delivery App',
      'delivery_training_delivery_app_overview_header': 'PREGLED DELIVERY APP',
      'delivery_training_transportation_method_header': 'NACIN PRIJEVOZA',
      'delivery_training_transportation_method_question':
          'Koji nacin prijevoza preferiras?',
      'delivery_training_transportation_method_walk': 'Pjeske',
      'delivery_training_transportation_method_bike': 'Bicikl',
      'delivery_training_verify_identity_header': 'POTVRDI IDENTITET',
      'delivery_training_verify_identity_tips_title': 'Savjeti',
      'delivery_training_verify_identity_take_photo': 'Snimi fotografiju',
      'delivery_training_offline_maps_prompt_title': 'Pregled',
      'delivery_training_settings_prompt_current_stop': 'Trenutno stajaliste',
      'delivery_training_settings_prompt_feedback': 'Povratna informacija',
      'delivery_training_settings_prompt_settings': 'Postavke',
      'delivery_training_settings_prompt_breaks': 'Pauze',
      'delivery_training_settings_prompt_driver_support': 'Podrska vozacu',
      'delivery_training_settings_prompt_emergency_help': 'Hitna pomoc',
      'delivery_training_offline_maps_settings_header': 'POSTAVKE',
      'delivery_training_offline_maps_settings_personal': 'Osobni podaci',
      'delivery_training_offline_maps_settings_phone': 'Broj telefona',
      'delivery_training_offline_maps_settings_legal':
          'Pregled pravnih informacija',
      'delivery_training_offline_maps_settings_offline': 'Offline karte',
      'delivery_training_offline_maps_settings_version':
          'Informacije o verziji',
      'delivery_training_offline_maps_settings_device': 'Identifikator uredaja',
      'delivery_training_offline_maps_settings_sign_out': 'ODJAVA',
      'delivery_training_offline_maps_download_header': 'OFFLINE KARTE',
      'delivery_training_offline_maps_download_settings':
          'Postavke preuzimanja',
      'delivery_training_offline_maps_downloaded_title': 'Preuzete karte',
      'delivery_training_offline_maps_other_maps': 'Ostale karte',
      'delivery_training_screen_title_overview': 'Pregled',
      'delivery_training_screen_title_itinerary': 'Popis itinerara',
      'delivery_training_screen_title_itinerary_list_lower': 'Popis itinerara',
      'delivery_training_itinerary_prompt_access': 'Pristup jednim klikom',
      'delivery_training_screen_title_map': 'Karta itinerara',
      'delivery_training_screen_title_itinerary_map_lower': 'Karta itinerara',
      'delivery_training_screen_title_summary': 'Sažetak',
      'delivery_training_summary_work_remaining': 'Preostali posao',
      'delivery_training_summary_stops_count': '5 stajalista',
      'delivery_training_summary_locations_count': '8 lokacija',
      'delivery_training_summary_packages_count': '9 paketa',
      'delivery_training_summary_stops_header': 'Stajalista',
      'delivery_training_screen_title_type_of_deliveries': 'Vrste dostave',
      'delivery_training_screen_title_door_to_door': 'Od vrata do vrata',
      'delivery_training_screen_title_lockers': 'Lockeri',
      'delivery_training_screen_title_counters': 'Pultovi',
      'delivery_training_screen_title_otr_supplies':
          'Dostave od vrata do vrata',
      'delivery_training_screen_title_otp_badge': 'Dostave od vrata do vrata',
      'delivery_training_screen_title_weather_bags':
          'Dostave od vrata do vrata',
      'delivery_training_screen_title_ready_to_go': 'Dostave od vrata do vrata',
      'delivery_training_screen_title_customer_arrival':
          'Dostave od vrata do vrata',
      'delivery_training_screen_title_customer_feedback':
          'Dostave od vrata do vrata',
      'delivery_training_screen_title_concessions': 'Koncesije',
      'delivery_training_screen_title_delivery_app_usage':
          'Koristenje Delivery App',
      'delivery_training_screen_title_delivery_app_overview':
          'Pregled Delivery App',
      'delivery_training_screen_title_transportation_method': 'Nacin prijevoza',
      'delivery_training_screen_title_verify_identity': 'Potvrdi identitet',
      'delivery_training_screen_title_menu': 'Glavni izbornik',
      'delivery_training_screen_title_settings': 'Postavke',
      'delivery_training_screen_title_offline_maps': 'Offline karte',
      'delivery_training_screen_title_stop_details': 'Detalji stajalista',
      'delivery_training_lockers_body':
          'Amazon Locker lokacije omogucuju kupcima jednostavno preuzimanje i vracanje paketa.',
      'delivery_training_counters_body':
          'Lokacije s osobljem gdje partneri nude prostor kao mjesto preuzimanja.',
      'delivery_training_otr_body_1':
          'Prije procesa u Delivery App za dostavu od vrata do vrata, pogledajmo opremu u OTR Supplies Trolley-u DS-a.',
      'delivery_training_otr_body_2':
          'Kolica su obicno blizu Loadout Area. Zatim prolazimo glavne funkcije Delivery App.',
      'delivery_training_otp_badge_body':
          'Ako kupci ne znaju OTP, zamolite ih da skeniraju QR kod na OTP badge-u.',
      'delivery_training_otp_badge_help_body':
          'Bit ce preusmjereni na sluzbenu stranicu pomoci za oporavak OTP-a.',
      'delivery_training_weather_bags_body':
          'Pokrijte pakete vremenskim vrecama kada su izlozeni vremenskim uvjetima.',
      'delivery_training_ready_to_go_body':
          'Imate svu opremu za dostavu i spremni ste za put.',
      'delivery_training_ready_to_go_footer': 'Krenimo!',
      'delivery_training_customer_arrival_body':
          'Kad parkirate na adresi dostave, Delivery App omogucuje poziv ili poruku kupcu za najavu dolaska.',
      'delivery_training_customer_feedback_body':
          'Nakon zavrsene dostave kupci dobivaju anketu za ocjenu iskustva.',
      'delivery_training_concessions_body':
          'Ako je iskustvo dostave bilo negativno, kupci mogu zatraziti povrat ili koncesiju.',
      'delivery_training_delivery_app_usage_body':
          'U ovom treningu ucimo kako izbjeći koncesije pravilnim koristenjem Delivery App.',
      'delivery_training_delivery_app_overview_body':
          'Delivery App je glavni alat za dostavu.\n\nOsim ako DSP to ne trazi, nemojte ga deinstalirati s uredaja.\n\nPogledajmo glavne funkcije!',
      'delivery_training_offline_maps_prompt_body':
          'Offline karte mozete preuzeti iz glavnog izbornika, gore lijevo.\n\nDodirnite ga!',
      'delivery_training_settings_prompt_body':
          'U glavnom izborniku dodirnite Postavke.\n\nDodirnite!',
      'delivery_training_offline_maps_allow_body':
          'Ako Wi-Fi nije dostupan, karte ce koristiti mobilne podatke za preuzimanje azuriranja.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB karta',
      'delivery_training_overview_intro_prompt_body':
          'Na ekranu pregleda naci cete informacije potrebne za dostavu i rjesavanje problema.\n\nPogledajmo!',
    },
    'ar': {
      'delivery_training_module_title': 'MEU - سير عمل التسليم',
      'delivery_training_step_of_total': 'الخطوة {current}/{total}',
      'delivery_training_lockers_title': 'الخزائن',
      'delivery_training_counters_title': 'نقاط الاستلام',
      'delivery_training_otr_header': 'عمليات تسليم من الباب إلى الباب',
      'delivery_training_concessions_title': 'التعويضات',
      'delivery_training_delivery_app_usage_title': 'استخدام تطبيق التسليم',
      'delivery_training_delivery_app_overview_header':
          'نظرة عامة على تطبيق التسليم',
      'delivery_training_transportation_method_header': 'طريقة النقل',
      'delivery_training_transportation_method_question':
          'ما طريقة النقل التي تفضلها؟',
      'delivery_training_transportation_method_walk': 'مشيا',
      'delivery_training_transportation_method_bike': 'دراجة',
      'delivery_training_verify_identity_header': 'التحقق من الهوية',
      'delivery_training_verify_identity_tips_title': 'نصائح',
      'delivery_training_verify_identity_take_photo': 'التقاط صورة',
      'delivery_training_offline_maps_prompt_title': 'نظرة عامة',
      'delivery_training_settings_prompt_current_stop': 'التوقف الحالي',
      'delivery_training_settings_prompt_feedback': 'ملاحظات',
      'delivery_training_settings_prompt_settings': 'الإعدادات',
      'delivery_training_settings_prompt_breaks': 'الاستراحات',
      'delivery_training_settings_prompt_driver_support': 'دعم السائق',
      'delivery_training_settings_prompt_emergency_help': 'مساعدة طارئة',
      'delivery_training_offline_maps_settings_header': 'الإعدادات',
      'delivery_training_offline_maps_settings_personal': 'المعلومات الشخصية',
      'delivery_training_offline_maps_settings_phone': 'رقم الهاتف',
      'delivery_training_offline_maps_settings_legal':
          'عرض المعلومات القانونية',
      'delivery_training_offline_maps_settings_offline': 'خرائط دون اتصال',
      'delivery_training_offline_maps_settings_version': 'معلومات الإصدار',
      'delivery_training_offline_maps_settings_device': 'معرف الجهاز',
      'delivery_training_offline_maps_settings_sign_out': 'تسجيل الخروج',
      'delivery_training_offline_maps_download_header': 'خرائط دون اتصال',
      'delivery_training_offline_maps_download_settings': 'إعدادات التنزيل',
      'delivery_training_offline_maps_downloaded_title':
          'الخرائط التي تم تنزيلها',
      'delivery_training_offline_maps_other_maps': 'خرائط أخرى',
      'delivery_training_screen_title_overview': 'نظرة عامة',
      'delivery_training_screen_title_itinerary': 'قائمة المسار',
      'delivery_training_screen_title_itinerary_list_lower': 'قائمة المسار',
      'delivery_training_itinerary_prompt_access': 'وصول بنقرة واحدة',
      'delivery_training_screen_title_map': 'خريطة المسار',
      'delivery_training_screen_title_itinerary_map_lower': 'خريطة المسار',
      'delivery_training_screen_title_summary': 'الملخص',
      'delivery_training_summary_work_remaining': 'العمل المتبقي',
      'delivery_training_summary_stops_count': '5 توقفات',
      'delivery_training_summary_locations_count': '8 مواقع',
      'delivery_training_summary_packages_count': '9 طرود',
      'delivery_training_summary_stops_header': 'التوقفات',
      'delivery_training_screen_title_type_of_deliveries': 'أنواع التسليم',
      'delivery_training_screen_title_door_to_door': 'من الباب إلى الباب',
      'delivery_training_screen_title_lockers': 'الخزائن',
      'delivery_training_screen_title_counters': 'نقاط الاستلام',
      'delivery_training_screen_title_otr_supplies':
          'عمليات تسليم من الباب إلى الباب',
      'delivery_training_screen_title_otp_badge':
          'عمليات تسليم من الباب إلى الباب',
      'delivery_training_screen_title_weather_bags':
          'عمليات تسليم من الباب إلى الباب',
      'delivery_training_screen_title_ready_to_go':
          'عمليات تسليم من الباب إلى الباب',
      'delivery_training_screen_title_customer_arrival':
          'عمليات تسليم من الباب إلى الباب',
      'delivery_training_screen_title_customer_feedback':
          'عمليات تسليم من الباب إلى الباب',
      'delivery_training_screen_title_concessions': 'التعويضات',
      'delivery_training_screen_title_delivery_app_usage':
          'استخدام تطبيق التسليم',
      'delivery_training_screen_title_delivery_app_overview':
          'نظرة عامة على تطبيق التسليم',
      'delivery_training_screen_title_transportation_method': 'طريقة النقل',
      'delivery_training_screen_title_verify_identity': 'التحقق من الهوية',
      'delivery_training_screen_title_menu': 'القائمة الرئيسية',
      'delivery_training_screen_title_settings': 'الإعدادات',
      'delivery_training_screen_title_offline_maps': 'خرائط دون اتصال',
      'delivery_training_screen_title_stop_details': 'تفاصيل التوقف',
      'delivery_training_lockers_body':
          'تسمح مواقع Amazon Locker للعملاء باستلام الطرود وإرجاعها بسهولة.',
      'delivery_training_counters_body':
          'مواقع يعمل فيها موظفون ويقدم الشركاء مساحة كنقطة استلام.',
      'delivery_training_otr_body_1':
          'قبل البدء بعمليات Delivery App لتسليم الباب إلى الباب، لنراجع المعدات في عربة OTR الخاصة بمحطة DS.',
      'delivery_training_otr_body_2':
          'تكون العربة عادة بالقرب من منطقة التحميل. بعد ذلك نستعرض الميزات الرئيسية للتطبيق.',
      'delivery_training_otp_badge_body':
          'إذا لم يعرف العملاء رمز OTP، اطلب منهم مسح رمز QR على بطاقة OTP.',
      'delivery_training_otp_badge_help_body':
          'سيتم توجيههم إلى صفحة المساعدة الرسمية لاستعادة OTP.',
      'delivery_training_weather_bags_body':
          'غط الطرود بأكياس الطقس عندما تكون معرضة للطقس.',
      'delivery_training_ready_to_go_body':
          'لديك كل معدات التسليم وأنت جاهز للانطلاق.',
      'delivery_training_ready_to_go_footer': 'هيا بنا!',
      'delivery_training_customer_arrival_body':
          'عند الوقوف في عنوان التسليم، يتيح لك التطبيق الاتصال بالعميل أو إرسال رسالة لإبلاغه بوصولك.',
      'delivery_training_customer_feedback_body':
          'بعد اكتمال التسليم، يتلقى العملاء استبيانا لتقييم تجربتهم.',
      'delivery_training_concessions_body':
          'إذا كانت تجربة التسليم سلبية، يمكن للعملاء طلب استرداد أو تعويض.',
      'delivery_training_delivery_app_usage_body':
          'في هذا التدريب نتعلم كيفية تجنب التعويضات باستخدام التطبيق بشكل صحيح.',
      'delivery_training_delivery_app_overview_body':
          'تطبيق Delivery App هو الأداة الرئيسية للتسليم.\n\nما لم يطلب DSP ذلك، لا تقم بإزالته من الجهاز.\n\nلنستعرض الميزات الرئيسية!',
      'delivery_training_offline_maps_prompt_body':
          'يمكنك تنزيل الخرائط دون اتصال من القائمة الرئيسية في الزاوية العلوية اليسرى.\n\nاضغط عليها!',
      'delivery_training_settings_prompt_body':
          'من القائمة الرئيسية اضغط على الإعدادات.\n\nاضغط عليها!',
      'delivery_training_offline_maps_allow_body':
          'إذا لم تتوفر شبكة Wi-Fi، ستستخدم الخرائط بيانات الهاتف لتنزيل التحديثات.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB خريطة',
      'delivery_training_overview_intro_prompt_body':
          'في شاشة النظرة العامة ستجد معلومات مهمة للتسليم وحل المشكلات.\n\nلنلق نظرة!',
    },
    'tr': {
      'delivery_training_module_title': 'MEU - Teslimat is akisi',
      'delivery_training_step_of_total': 'Adim {current}/{total}',
      'delivery_training_welcome_title': 'Teslimat turleri',
      'delivery_training_door_to_door_title': 'Kapidan kapiya',
      'delivery_training_lockers_title': 'Lockerlar',
      'delivery_training_counters_title': 'Teslim noktalari',
      'delivery_training_otr_header': 'KAPIDAN KAPIYA TESLIMATLAR',
      'delivery_training_concessions_title': 'Telafiler',
      'delivery_training_delivery_app_usage_title': 'Delivery App kullanimi',
      'delivery_training_delivery_app_overview_header':
          'DELIVERY APP GENEL BAKIS',
      'delivery_training_transportation_method_header': 'ULASIM YONTEMI',
      'delivery_training_transportation_method_question':
          'Hangi ulasim yontemini tercih ediyorsun?',
      'delivery_training_transportation_method_walk': 'Yuruyus',
      'delivery_training_transportation_method_bike': 'Bisiklet',
      'delivery_training_verify_identity_header': 'KIMLIGI DOGRULA',
      'delivery_training_verify_identity_tips_title': 'Ipuclari',
      'delivery_training_verify_identity_take_photo': 'Foto cek',
      'delivery_training_offline_maps_prompt_title': 'Genel bakis',
      'delivery_training_settings_prompt_current_stop': 'Mevcut durak',
      'delivery_training_settings_prompt_feedback': 'Geri bildirim',
      'delivery_training_settings_prompt_settings': 'Ayarlar',
      'delivery_training_settings_prompt_breaks': 'Molalar',
      'delivery_training_settings_prompt_driver_support': 'Surucu destegi',
      'delivery_training_settings_prompt_emergency_help': 'Acil yardim',
      'delivery_training_offline_maps_settings_header': 'AYARLAR',
      'delivery_training_offline_maps_settings_personal': 'Kisisel bilgiler',
      'delivery_training_offline_maps_settings_phone': 'Telefon numarasi',
      'delivery_training_offline_maps_settings_legal': 'Yasal bilgileri gor',
      'delivery_training_offline_maps_settings_offline': 'Cevrimdisi haritalar',
      'delivery_training_offline_maps_settings_version': 'Surum bilgisi',
      'delivery_training_offline_maps_settings_device': 'Cihaz kimligi',
      'delivery_training_offline_maps_settings_sign_out': 'CIKIS YAP',
      'delivery_training_offline_maps_download_header': 'CEVRIMDISI HARITALAR',
      'delivery_training_offline_maps_download_settings': 'Indirme ayarlari',
      'delivery_training_offline_maps_downloaded_title': 'Indirilen haritalar',
      'delivery_training_offline_maps_other_maps': 'Diger haritalar',
      'delivery_training_screen_title_overview': 'Genel bakis',
      'delivery_training_screen_title_itinerary': 'Rota listesi',
      'delivery_training_screen_title_itinerary_list_lower': 'Rota listesi',
      'delivery_training_itinerary_prompt_access': '1-Tik erisim',
      'delivery_training_screen_title_map': 'Rota haritasi',
      'delivery_training_screen_title_itinerary_map_lower': 'Rota haritasi',
      'delivery_training_screen_title_summary': 'Ozet',
      'delivery_training_summary_work_remaining': 'Kalan is',
      'delivery_training_summary_stops_count': '5 durak',
      'delivery_training_summary_locations_count': '8 konum',
      'delivery_training_summary_packages_count': '9 paket',
      'delivery_training_summary_stops_header': 'Duraklar',
      'delivery_training_screen_title_type_of_deliveries': 'Teslimat turleri',
      'delivery_training_screen_title_door_to_door': 'Kapidan kapiya',
      'delivery_training_screen_title_lockers': 'Lockerlar',
      'delivery_training_screen_title_counters': 'Teslim noktalari',
      'delivery_training_screen_title_otr_supplies': 'Kapidan kapiya teslimat',
      'delivery_training_screen_title_otp_badge': 'Kapidan kapiya teslimat',
      'delivery_training_screen_title_weather_bags': 'Kapidan kapiya teslimat',
      'delivery_training_screen_title_ready_to_go': 'Kapidan kapiya teslimat',
      'delivery_training_screen_title_customer_arrival':
          'Kapidan kapiya teslimat',
      'delivery_training_screen_title_customer_feedback':
          'Kapidan kapiya teslimat',
      'delivery_training_screen_title_concessions': 'Telafiler',
      'delivery_training_screen_title_delivery_app_usage':
          'Delivery App kullanimi',
      'delivery_training_screen_title_delivery_app_overview':
          'Delivery App genel bakis',
      'delivery_training_screen_title_transportation_method': 'Ulasim yontemi',
      'delivery_training_screen_title_verify_identity': 'Kimligi dogrula',
      'delivery_training_screen_title_menu': 'Ana menu',
      'delivery_training_screen_title_settings': 'Ayarlar',
      'delivery_training_screen_title_offline_maps': 'Cevrimdisi haritalar',
      'delivery_training_screen_title_stop_details': 'Durak detaylari',
      'delivery_training_lockers_body':
          'Amazon Locker noktalarinda musteriler paketleri kolayca teslim alip iade edebilir.',
      'delivery_training_counters_body':
          'Partnerlerin magaza alanini teslim alma noktasi olarak sundugu personelli lokasyonlar.',
      'delivery_training_otr_body_1':
          'Kapidan kapiya teslimat sureclerine gecmeden once DS OTR Supplies arabasindaki ekipmanlari inceleyelim.',
      'delivery_training_otr_body_2':
          'Araba genelde Loadout Area yakinindadir. Ardindan Delivery App ana ozelliklerine bakariz.',
      'delivery_training_otp_badge_body':
          'Musteri OTP kodunu bilmiyorsa OTP badge uzerindeki QR kodunu okutmasini isteyin.',
      'delivery_training_otp_badge_help_body':
          'OTP kurtarma adimlari icin resmi yardim sayfasina yonlendirilir.',
      'delivery_training_weather_bags_body':
          'Hava kosullarina maruz kalan paketleri hava koruma torbalariyla kapatin.',
      'delivery_training_ready_to_go_body':
          'Tum teslimat ekipmanina sahipsin ve yola cikmaya hazirsin.',
      'delivery_training_ready_to_go_footer': 'Haydi baslayalim!',
      'delivery_training_customer_arrival_body':
          'Teslimat adresine park ettiginde Delivery App ile musteriyi arayabilir veya mesaj atarak geldigini bildirebilirsin.',
      'delivery_training_customer_feedback_body':
          'Teslimat tamamlandiginda musteriler deneyimi degerlendirmek icin anket alir.',
      'delivery_training_concessions_body':
          'Teslimat deneyimi olumsuzsa musteriler iade veya telafi talep edebilir.',
      'delivery_training_delivery_app_usage_body':
          'Bu egitimde Delivery App dogru kullanilarak telafilerin nasil azaltilacagini ogrenecegiz.',
      'delivery_training_delivery_app_overview_body':
          'Delivery App teslimatlar icin ana aracinizdir.\n\nDSP istemedikce cihazinizdan asla kaldirmayin.\n\nAna ozelliklere bakalim!',
      'delivery_training_offline_maps_prompt_body':
          'Cevrimdisi haritalari sol ustteki ana menuden indirebilirsin.\n\nUzerine dokun!',
      'delivery_training_settings_prompt_body':
          'Ana menuden Ayarlar secenegine dokun.\n\nDokun!',
      'delivery_training_offline_maps_allow_body':
          'Wi-Fi yoksa harita guncellemeleri indirmek icin mobil veri kullanilir.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB harita',
      'delivery_training_overview_intro_prompt_body':
          'Genel bakis ekraninda teslimat ve sorun giderme icin gerekli bilgileri bulursun.\n\nHadi bakalim!',
    },
    'ru': {
      'delivery_training_module_title': 'MEU - Процесс доставки',
      'delivery_training_step_of_total': 'Шаг {current}/{total}',
      'delivery_training_welcome_title': 'Типы доставок',
      'delivery_training_door_to_door_title': 'От двери к двери',
      'delivery_training_lockers_title': 'Локеры',
      'delivery_training_counters_title': 'Пункты выдачи',
      'delivery_training_otr_header': 'ДОСТАВКА ОТ ДВЕРИ К ДВЕРИ',
      'delivery_training_concessions_title': 'Компенсации',
      'delivery_training_delivery_app_usage_title':
          'Использование Delivery App',
      'delivery_training_delivery_app_overview_header': 'ОБЗОР DELIVERY APP',
      'delivery_training_transportation_method_header': 'СПОСОБ ПЕРЕДВИЖЕНИЯ',
      'delivery_training_transportation_method_question':
          'Какой способ передвижения вы предпочитаете?',
      'delivery_training_transportation_method_walk': 'Пешком',
      'delivery_training_transportation_method_bike': 'Велосипед',
      'delivery_training_verify_identity_header': 'ПОДТВЕРЖДЕНИЕ ЛИЧНОСТИ',
      'delivery_training_verify_identity_tips_title': 'Советы',
      'delivery_training_verify_identity_take_photo': 'Сделать фото',
      'delivery_training_offline_maps_prompt_title': 'Обзор',
      'delivery_training_settings_prompt_current_stop': 'Текущая остановка',
      'delivery_training_settings_prompt_feedback': 'Обратная связь',
      'delivery_training_settings_prompt_settings': 'Настройки',
      'delivery_training_settings_prompt_breaks': 'Перерывы',
      'delivery_training_settings_prompt_driver_support': 'Поддержка водителя',
      'delivery_training_settings_prompt_emergency_help': 'Экстренная помощь',
      'delivery_training_offline_maps_settings_header': 'НАСТРОЙКИ',
      'delivery_training_offline_maps_settings_personal': 'Личная информация',
      'delivery_training_offline_maps_settings_phone': 'Номер телефона',
      'delivery_training_offline_maps_settings_legal':
          'Просмотр юридической информации',
      'delivery_training_offline_maps_settings_offline': 'Офлайн-карты',
      'delivery_training_offline_maps_settings_version': 'Информация о версии',
      'delivery_training_offline_maps_settings_device':
          'Идентификатор устройства',
      'delivery_training_offline_maps_settings_sign_out': 'ВЫЙТИ',
      'delivery_training_offline_maps_download_header': 'ОФЛАЙН-КАРТЫ',
      'delivery_training_offline_maps_download_settings': 'Настройки загрузки',
      'delivery_training_offline_maps_downloaded_title': 'Загруженные карты',
      'delivery_training_offline_maps_other_maps': 'Другие карты',
      'delivery_training_screen_title_overview': 'Обзор',
      'delivery_training_screen_title_itinerary': 'Список маршрута',
      'delivery_training_screen_title_itinerary_list_lower': 'Список маршрута',
      'delivery_training_itinerary_prompt_access': 'Доступ в 1 клик',
      'delivery_training_screen_title_map': 'Карта маршрута',
      'delivery_training_screen_title_itinerary_map_lower': 'Карта маршрута',
      'delivery_training_screen_title_summary': 'Сводка',
      'delivery_training_summary_work_remaining': 'Оставшаяся работа',
      'delivery_training_summary_stops_count': '5 остановок',
      'delivery_training_summary_locations_count': '8 локаций',
      'delivery_training_summary_packages_count': '9 посылок',
      'delivery_training_summary_stops_header': 'Остановки',
      'delivery_training_screen_title_type_of_deliveries': 'Типы доставок',
      'delivery_training_screen_title_door_to_door': 'От двери к двери',
      'delivery_training_screen_title_lockers': 'Локеры',
      'delivery_training_screen_title_counters': 'Пункты выдачи',
      'delivery_training_screen_title_otr_supplies':
          'Доставка от двери к двери',
      'delivery_training_screen_title_otp_badge': 'Доставка от двери к двери',
      'delivery_training_screen_title_weather_bags':
          'Доставка от двери к двери',
      'delivery_training_screen_title_ready_to_go': 'Доставка от двери к двери',
      'delivery_training_screen_title_customer_arrival':
          'Доставка от двери к двери',
      'delivery_training_screen_title_customer_feedback':
          'Доставка от двери к двери',
      'delivery_training_screen_title_concessions': 'Компенсации',
      'delivery_training_screen_title_delivery_app_usage':
          'Использование Delivery App',
      'delivery_training_screen_title_delivery_app_overview':
          'Обзор Delivery App',
      'delivery_training_screen_title_transportation_method':
          'Способ передвижения',
      'delivery_training_screen_title_verify_identity':
          'Подтверждение личности',
      'delivery_training_screen_title_menu': 'Главное меню',
      'delivery_training_screen_title_settings': 'Настройки',
      'delivery_training_screen_title_offline_maps': 'Офлайн-карты',
      'delivery_training_screen_title_stop_details': 'Детали остановки',
      'delivery_training_lockers_body':
          'Локации Amazon Locker позволяют клиентам удобно забирать и возвращать посылки.',
      'delivery_training_counters_body':
          'Точки с персоналом, где партнеры предоставляют место как пункт выдачи.',
      'delivery_training_otr_body_1':
          'Перед процессами в Delivery App для доставки от двери к двери посмотрим оборудование в тележке OTR Supplies на DS.',
      'delivery_training_otr_body_2':
          'Тележка обычно находится рядом с зоной Loadout. Затем разберем основные функции Delivery App.',
      'delivery_training_otp_badge_body':
          'Если клиент не знает OTP, попросите его сканировать QR-код на OTP badge.',
      'delivery_training_otp_badge_help_body':
          'После этого он будет направлен на официальную страницу помощи по восстановлению OTP.',
      'delivery_training_weather_bags_body':
          'Накрывайте посылки защитными пакетами при плохой погоде.',
      'delivery_training_ready_to_go_body':
          'У вас есть все оборудование для доставки, и вы готовы выезжать.',
      'delivery_training_ready_to_go_footer': 'Поехали!',
      'delivery_training_customer_arrival_body':
          'Когда вы припарковались по адресу доставки, в Delivery App можно позвонить клиенту или написать ему о прибытии.',
      'delivery_training_customer_feedback_body':
          'После завершения доставки клиент получает опрос для оценки опыта.',
      'delivery_training_concessions_body':
          'Если опыт доставки был негативным, клиенты могут запросить возврат или компенсацию.',
      'delivery_training_delivery_app_usage_body':
          'В этом обучении мы изучим, как избегать компенсаций, правильно используя Delivery App.',
      'delivery_training_delivery_app_overview_body':
          'Delivery App - основной инструмент для доставок.\n\nЕсли DSP не требует, не удаляйте его с устройства.\n\nПосмотрим основные функции приложения!',
      'delivery_training_offline_maps_prompt_body':
          'Офлайн-карты можно загрузить из главного меню в левом верхнем углу.\n\nНажмите на него!',
      'delivery_training_settings_prompt_body':
          'В главном меню нажмите Настройки.\n\nНажмите!',
      'delivery_training_offline_maps_allow_body':
          'Если Wi-Fi недоступен, карты будут использовать мобильные данные для загрузки обновлений.',
      'delivery_training_offline_maps_downloaded_item': 'MDC-HTB карта',
      'delivery_training_overview_intro_prompt_body':
          'На экране обзора вы найдете информацию для доставки и устранения проблем.\n\nДавайте посмотрим!',
    },
  };

  static final Map<String, String> _driversHubSharedValues = {
    'drivers_hub_add_driver': 'Add driver',
    'drivers_hub_add_edit_driver': 'Add / edit driver',
    'drivers_hub_admin_tools': 'Admin tools',
    'drivers_hub_change_pin': 'Change PIN',
    'drivers_hub_confirm_password': 'Confirm password',
    'drivers_hub_copy_label': 'Copy {label}',
    'drivers_hub_could_not_launch_document_url':
        'Could not launch document URL',
    'drivers_hub_create_login_for_all': 'Create login for all',
    'drivers_hub_create_logins_for_all_body':
        'This will create logins for all drivers that do not yet have a login,\nusing the password:\n\n{password}\n\nContinue?',
    'drivers_hub_create_logins_for_all_drivers':
        'Create logins for all drivers',
    'drivers_hub_created_logins_summary':
        'Created logins for {created} drivers. Skipped {skipped} (already had login or missing ID).',
    'drivers_hub_csv_import_failed': 'Driver CSV import failed: {error}',
    'drivers_hub_csv_imported_for_dsp':
        'Driver CSV imported for your DSP ({file}).',
    'drivers_hub_date_format_hint': 'DD/MM/YYYY',
    'drivers_hub_default_driver_password': 'Default driver password',
    'drivers_hub_default_password_cannot_be_empty':
        'Default password cannot be empty.',
    'drivers_hub_delete_document_body': 'This will delete {document}.',
    'drivers_hub_delete_document_title': 'Delete document?',
    'drivers_hub_delete_driver_body':
        'Are you sure you want to delete driver "{name}"?\nThis will remove them and delete their login.',
    'drivers_hub_delete_driver_title': 'Delete driver',
    'drivers_hub_delete_failed': 'Delete failed: {error}',
    'drivers_hub_document_deleted': '{document} deleted.',
    'drivers_hub_document_type': 'Document type',
    'drivers_hub_document_uploaded': '{document} uploaded.',
    'drivers_hub_documents': 'Documents',
    'drivers_hub_documents_expired': '{count} documents expired',
    'drivers_hub_documents_expiring_soon': '{count} documents expiring soon',
    'drivers_hub_download': 'Download',
    'drivers_hub_driver_activated': 'Driver activated.',
    'drivers_hub_driver_deleted': 'Driver deleted.',
    'drivers_hub_driver_email': 'Driver email',
    'drivers_hub_driver_line': 'Driver: {name}',
    'drivers_hub_driver_login_created': 'Driver login created',
    'drivers_hub_driver_login_saved': 'Driver login saved successfully.',
    'drivers_hub_driver_name': 'Driver name',
    'drivers_hub_driver_saved': 'Driver "{name}" saved.',
    'drivers_hub_driver_suspended': 'Driver suspended.',
    'drivers_hub_driving_licence_front_preview':
        'Driving licence (front) preview',
    'drivers_hub_edit_label': 'Edit {label}',
    'drivers_hub_email': 'Email',
    'drivers_hub_email_optional': 'Email (optional)',
    'drivers_hub_expiry_contract': 'Contract',
    'drivers_hub_expiry_driving_license': 'Driving licence',
    'drivers_hub_expiry_id_passport': 'ID / Passport',
    'drivers_hub_expiry_items_expired': '{items} expired',
    'drivers_hub_expiry_items_expiring_soon': '{items} expiring soon',
    'drivers_hub_expiry_probezeit': 'Probezeit',
    'drivers_hub_expiry_work_permit': 'Work permit',
    'drivers_hub_expiry_work_visa': 'Working visa',
    'drivers_hub_expiry_zusatzblatt': 'Zusatzblatt',
    'drivers_hub_export_pdf': 'Export PDF',
    'drivers_hub_failed_create_logins': 'Failed to create logins: {error}',
    'drivers_hub_failed_delete_document': 'Failed to delete document: {error}',
    'drivers_hub_failed_load_pdf_preview': 'Failed to load PDF preview.',
    'drivers_hub_failed_save_default_password':
        'Failed to save default driver password: {error}',
    'drivers_hub_failed_set_login': 'Failed to set login: {error}',
    'drivers_hub_failed_update_label': 'Failed to update {label}: {error}',
    'drivers_hub_failed_upload_document': 'Failed to upload document: {error}',
    'drivers_hub_field_bank_iban': 'Bank IBAN',
    'drivers_hub_field_city': 'City',
    'drivers_hub_field_city_of_birth': 'City of birth',
    'drivers_hub_field_contract_expiry': 'Contract expiry',
    'drivers_hub_field_annual_vacation_days': 'Vacation days per year',
    'drivers_hub_field_remaining_vacation_days': 'Remaining vacation days',
    'drivers_hub_field_country': 'Country',
    'drivers_hub_field_date_of_birth': 'Date of birth',
    'drivers_hub_field_driving_license_number': 'Driving license number',
    'drivers_hub_field_emergency_contact_name': 'Emergency contact name',
    'drivers_hub_field_emergency_contact_phone': 'Emergency contact phone',
    'drivers_hub_field_full_name': 'Full name',
    'drivers_hub_field_id_card_passport_expiry': 'ID card / passport expiry',
    'drivers_hub_field_insurance_company': 'Insurance company',
    'drivers_hub_field_license_expiry_date': 'License expiry date',
    'drivers_hub_field_name_at_birth': 'Name at birth',
    'drivers_hub_field_nationality_id_card': 'Nationality (ID card)',
    'drivers_hub_field_notes': 'Notes',
    'drivers_hub_field_phone': 'Phone',
    'drivers_hub_field_postal_code': 'Postal code',
    'drivers_hub_field_probezeit_end': 'Probezeit end',
    'drivers_hub_field_shoe_size': 'Shoe size',
    'drivers_hub_field_state_of_birth': 'State of birth',
    'drivers_hub_field_street_address': 'Street address',
    'drivers_hub_field_tax_id': 'Tax ID',
    'drivers_hub_field_tshirt_size': 'T-shirt size',
    'drivers_hub_field_work_permit_type': 'Work permit',
    'drivers_hub_field_work_permit_expiry': 'Work permit expiry',
    'drivers_hub_field_work_visa_expiry': 'Expiry date of Working Visa',
    'drivers_hub_field_work_start_date': 'Work start date',
    'drivers_hub_field_zusatzblatt_expiry': 'Expiry date of Zusatzblatt',
    'drivers_hub_header_action': 'Action',
    'drivers_hub_header_login': 'Login',
    'drivers_hub_header_overall': 'Overall',
    'drivers_hub_header_profile': 'Profile',
    'drivers_hub_header_status': 'Status',
    'drivers_hub_header_working': 'Working',
    'drivers_hub_hide_pin': 'Hide PIN',
    'drivers_hub_import_csv': 'Import CSV',
    'drivers_hub_join_two': '{a} & {b}',
    'drivers_hub_label_copied': '{label} copied',
    'drivers_hub_label_updated': '{label} updated.',
    'drivers_hub_login_created': 'Login created',
    'drivers_hub_must_login_add_driver':
        'You must be logged in to add drivers.',
    'drivers_hub_must_login_import_csv':
        'You must be logged in to import CSVs.',
    'drivers_hub_must_login_manage_logins':
        'You must be logged in to manage driver logins.',
    'drivers_hub_must_login_view_drivers':
        'You must be logged in to view drivers.',
    'drivers_hub_name_and_transporter_id_required':
        'Name and Transporter ID are required.',
    'drivers_hub_no_drivers_for_dsp': 'No drivers found for this DSP.',
    'drivers_hub_no_drivers_yet':
        'No drivers yet.\nImport a CSV or add a driver manually.',
    'drivers_hub_no_login': 'No login',
    'drivers_hub_no_scores_yet': 'No weekly score summary yet.',
    'drivers_hub_not_set': 'Not set',
    'drivers_hub_not_uploaded': 'Not uploaded',
    'drivers_hub_notification_pin': 'Notification PIN',
    'drivers_hub_onboarding_completed': 'Onboarding completed',
    'drivers_hub_password': 'Password',
    'drivers_hub_passwords_must_match':
        'Passwords must match and not be empty.',
    'drivers_hub_pdf_driver_onboarding': 'Driver Onboarding',
    'drivers_hub_preview_not_available':
        'Preview is not available for this file type. Use Download to open it.',
    'drivers_hub_preview_unavailable_image':
        'Preview unavailable for this image.',
    'drivers_hub_probezeit_expired': 'Probezeit expired',
    'drivers_hub_probezeit_expiring_soon': 'Probezeit expiring soon',
    'drivers_hub_replace_slot_hint':
        'This will create/replace the slot: {slot}',
    'drivers_hub_search_name_or_email': 'Search by name or email...',
    'drivers_hub_section_address': 'Address',
    'drivers_hub_section_document_expiry_dates': 'Document expiry dates',
    'drivers_hub_section_driving_license': 'Driving license',
    'drivers_hub_section_emergency_contact': 'Emergency contact',
    'drivers_hub_section_origin': 'Origin',
    'drivers_hub_section_other_notes': 'Other notes',
    'drivers_hub_section_payment_tax': 'Payment & tax',
    'drivers_hub_section_personal_details': 'Personal details',
    'drivers_hub_section_uniform': 'Uniform',
    'drivers_hub_set_driver_login': 'Set driver login',
    'drivers_hub_set_pin': 'Set PIN',
    'drivers_hub_show_pin': 'Show PIN',
    'drivers_hub_sort_id_asc': 'ID A-Z',
    'drivers_hub_sort_name_asc': 'Name A-Z',
    'drivers_hub_sort_name_desc': 'Name Z-A',
    'drivers_hub_sort_approved': 'Approved',
    'drivers_hub_sort_newest': 'Newest',
    'drivers_hub_sort_oldest': 'Oldest',
    'drivers_hub_sort_pending': 'Pending',
    'drivers_hub_sort_rejected': 'Rejected',
    'drivers_hub_status_approved': 'Approved',
    'drivers_hub_status_pending': 'Pending',
    'drivers_hub_status_rejected': 'Rejected',
    'drivers_hub_switch_off': 'Off',
    'drivers_hub_switch_on': 'On',
    'drivers_hub_title': 'Drivers Hub',
    'drivers_hub_tooltip_create_login': 'Create login',
    'drivers_hub_tooltip_delete_driver': 'Delete driver',
    'drivers_hub_tooltip_reset_login': 'Reset login',
    'drivers_hub_tooltip_view_details': 'View details',
    'drivers_hub_transporter_id': 'Transporter ID',
    'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
    'drivers_hub_transporter_id_login': 'Transporter ID (login ID)',
    'drivers_hub_transporter_id_required': 'Transporter ID is required.',
    'drivers_hub_upload_doc': 'Upload doc',
    'drivers_hub_upload_driver_document': 'Upload driver document',
    'drivers_hub_valid_driver_email_required':
        'A valid driver email is required.',
    'drivers_hub_weekly_score_summary': 'Weekly score summary',
    'drivers_hub_work_permit_eu': 'EU',
    'drivers_hub_work_permit_working_visa': 'Working Visa',
  };

  static final Map<String, Map<String, String>> _driversHubLocalizedValues = {
    'en': _driversHubSharedValues,
    'de': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'Fahrer hinzufuegen',
      'drivers_hub_add_edit_driver': 'Fahrer hinzufuegen / bearbeiten',
      'drivers_hub_admin_tools': 'Admin-Tools',
      'drivers_hub_change_pin': 'PIN aendern',
      'drivers_hub_confirm_password': 'Passwort bestaetigen',
      'drivers_hub_copy_label': '{label} kopieren',
      'drivers_hub_could_not_launch_document_url':
          'Dokument-URL konnte nicht geoeffnet werden',
      'drivers_hub_create_login_for_all': 'Login fuer alle erstellen',
      'drivers_hub_create_logins_for_all_body':
          'Dadurch werden fuer alle Fahrer ohne Login neue Logins erstellt,\nmit folgendem Passwort:\n\n{password}\n\nFortfahren?',
      'drivers_hub_create_logins_for_all_drivers':
          'Logins fuer alle Fahrer erstellen',
      'drivers_hub_created_logins_summary':
          'Logins fuer {created} Fahrer erstellt. {skipped} uebersprungen (hatten bereits Login oder keine ID).',
      'drivers_hub_csv_import_failed':
          'Fahrer-CSV-Import fehlgeschlagen: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'Fahrer-CSV fuer deinen DSP importiert ({file}).',
      'drivers_hub_default_driver_password': 'Standardpasswort fuer Fahrer',
      'drivers_hub_default_password_cannot_be_empty':
          'Standardpasswort darf nicht leer sein.',
      'drivers_hub_delete_document_body': '{document} wird geloescht.',
      'drivers_hub_delete_document_title': 'Dokument loeschen?',
      'drivers_hub_delete_driver_body':
          'Moechtest du Fahrer "{name}" wirklich loeschen?\nDadurch werden Fahrer und Login entfernt.',
      'drivers_hub_delete_driver_title': 'Fahrer loeschen',
      'drivers_hub_delete_failed': 'Loeschen fehlgeschlagen: {error}',
      'drivers_hub_document_deleted': '{document} geloescht.',
      'drivers_hub_document_type': 'Dokumenttyp',
      'drivers_hub_document_uploaded': '{document} hochgeladen.',
      'drivers_hub_documents': 'Dokumente',
      'drivers_hub_documents_expired': '{count} Dokumente abgelaufen',
      'drivers_hub_documents_expiring_soon': '{count} Dokumente laufen bald ab',
      'drivers_hub_download': 'Herunterladen',
      'drivers_hub_driver_activated': 'Fahrer aktiviert.',
      'drivers_hub_driver_deleted': 'Fahrer geloescht.',
      'drivers_hub_driver_email': 'Fahrer-E-Mail',
      'drivers_hub_driver_line': 'Fahrer: {name}',
      'drivers_hub_driver_login_created': 'Fahrer-Login erstellt',
      'drivers_hub_driver_login_saved': 'Fahrer-Login erfolgreich gespeichert.',
      'drivers_hub_driver_name': 'Fahrername',
      'drivers_hub_driver_saved': 'Fahrer "{name}" gespeichert.',
      'drivers_hub_driver_suspended': 'Fahrer gesperrt.',
      'drivers_hub_driving_licence_front_preview':
          'Vorschau Fuehrerschein (Vorderseite)',
      'drivers_hub_edit_label': '{label} bearbeiten',
      'drivers_hub_email': 'E-Mail',
      'drivers_hub_email_optional': 'E-Mail (optional)',
      'drivers_hub_expiry_contract': 'Vertrag',
      'drivers_hub_expiry_driving_license': 'Fuehrerschein',
      'drivers_hub_expiry_id_passport': 'Ausweis / Reisepass',
      'drivers_hub_expiry_items_expired': '{items} abgelaufen',
      'drivers_hub_expiry_items_expiring_soon': '{items} laufen bald ab',
      'drivers_hub_expiry_work_permit': 'Arbeitserlaubnis',
      'drivers_hub_export_pdf': 'PDF exportieren',
      'drivers_hub_failed_create_logins':
          'Erstellen der Logins fehlgeschlagen: {error}',
      'drivers_hub_failed_delete_document':
          'Dokument konnte nicht geloescht werden: {error}',
      'drivers_hub_failed_load_pdf_preview':
          'PDF-Vorschau konnte nicht geladen werden.',
      'drivers_hub_failed_save_default_password':
          'Standardpasswort konnte nicht gespeichert werden: {error}',
      'drivers_hub_failed_set_login':
          'Login konnte nicht gespeichert werden: {error}',
      'drivers_hub_failed_update_label':
          '{label} konnte nicht aktualisiert werden: {error}',
      'drivers_hub_failed_upload_document':
          'Dokument konnte nicht hochgeladen werden: {error}',
      'drivers_hub_field_city': 'Stadt',
      'drivers_hub_field_city_of_birth': 'Geburtsort',
      'drivers_hub_field_contract_expiry': 'Vertragsende',
      'drivers_hub_field_annual_vacation_days': 'Urlaubstage pro Jahr',
      'drivers_hub_field_remaining_vacation_days': 'Resturlaub',
      'drivers_hub_field_country': 'Land',
      'drivers_hub_field_date_of_birth': 'Geburtsdatum',
      'drivers_hub_field_driving_license_number': 'Fuehrerscheinnummer',
      'drivers_hub_field_emergency_contact_name': 'Notfallkontakt Name',
      'drivers_hub_field_emergency_contact_phone': 'Notfallkontakt Telefon',
      'drivers_hub_field_full_name': 'Vollstaendiger Name',
      'drivers_hub_field_id_card_passport_expiry': 'Ablauf Ausweis / Reisepass',
      'drivers_hub_field_insurance_company': 'Versicherung',
      'drivers_hub_field_license_expiry_date': 'Ablaufdatum Fuehrerschein',
      'drivers_hub_field_name_at_birth': 'Geburtsname',
      'drivers_hub_field_nationality_id_card': 'Nationalitaet (Ausweis)',
      'drivers_hub_field_notes': 'Notizen',
      'drivers_hub_field_phone': 'Telefon',
      'drivers_hub_field_postal_code': 'Postleitzahl',
      'drivers_hub_field_probezeit_end': 'Probezeit Ende',
      'drivers_hub_field_shoe_size': 'Schuhgroesse',
      'drivers_hub_field_state_of_birth': 'Geburtsstaat',
      'drivers_hub_field_street_address': 'Strasse und Hausnummer',
      'drivers_hub_field_tshirt_size': 'T-Shirt-Groesse',
      'drivers_hub_field_work_permit_expiry': 'Ablauf Arbeitserlaubnis',
      'drivers_hub_field_work_start_date': 'Arbeitsbeginn',
      'drivers_hub_header_action': 'Aktion',
      'drivers_hub_header_login': 'Login',
      'drivers_hub_header_overall': 'Gesamt',
      'drivers_hub_header_profile': 'Profil',
      'drivers_hub_header_status': 'Status',
      'drivers_hub_header_working': 'Aktiv',
      'drivers_hub_hide_pin': 'PIN ausblenden',
      'drivers_hub_import_csv': 'CSV importieren',
      'drivers_hub_label_copied': '{label} kopiert',
      'drivers_hub_login_created': 'Login erstellt',
      'drivers_hub_must_login_add_driver':
          'Du musst eingeloggt sein, um Fahrer hinzuzufuegen.',
      'drivers_hub_must_login_import_csv':
          'Du musst eingeloggt sein, um CSV zu importieren.',
      'drivers_hub_must_login_manage_logins':
          'Du musst eingeloggt sein, um Fahrer-Logins zu verwalten.',
      'drivers_hub_must_login_view_drivers':
          'Du musst eingeloggt sein, um Fahrer zu sehen.',
      'drivers_hub_name_and_transporter_id_required':
          'Name und Transporter-ID sind erforderlich.',
      'drivers_hub_no_drivers_for_dsp':
          'Keine Fahrer fuer diesen DSP gefunden.',
      'drivers_hub_no_drivers_yet':
          'Noch keine Fahrer.\nCSV importieren oder Fahrer manuell hinzufuegen.',
      'drivers_hub_no_login': 'Kein Login',
      'drivers_hub_not_set': 'Nicht gesetzt',
      'drivers_hub_not_uploaded': 'Nicht hochgeladen',
      'drivers_hub_notification_pin': 'Benachrichtigungs-PIN',
      'drivers_hub_onboarding_completed': 'Onboarding abgeschlossen',
      'drivers_hub_password': 'Passwort',
      'drivers_hub_passwords_must_match':
          'Passwoerter muessen uebereinstimmen und duerfen nicht leer sein.',
      'drivers_hub_pdf_driver_onboarding': 'Fahrer-Onboarding',
      'drivers_hub_preview_not_available':
          'Vorschau ist fuer diesen Dateityp nicht verfuegbar. Zum Oeffnen herunterladen.',
      'drivers_hub_preview_unavailable_image':
          'Vorschau fuer dieses Bild nicht verfuegbar.',
      'drivers_hub_probezeit_expired': 'Probezeit abgelaufen',
      'drivers_hub_probezeit_expiring_soon': 'Probezeit laeuft bald ab',
      'drivers_hub_replace_slot_hint':
          'Dieser Slot wird erstellt/ersetzt: {slot}',
      'drivers_hub_search_name_or_email': 'Nach Name oder E-Mail suchen...',
      'drivers_hub_section_address': 'Adresse',
      'drivers_hub_section_document_expiry_dates': 'Dokument-Ablaufdaten',
      'drivers_hub_section_driving_license': 'Fuehrerschein',
      'drivers_hub_section_emergency_contact': 'Notfallkontakt',
      'drivers_hub_section_origin': 'Herkunft',
      'drivers_hub_section_other_notes': 'Weitere Notizen',
      'drivers_hub_section_payment_tax': 'Zahlung & Steuer',
      'drivers_hub_section_personal_details': 'Persoenliche Daten',
      'drivers_hub_section_uniform': 'Uniform',
      'drivers_hub_set_driver_login': 'Fahrer-Login setzen',
      'drivers_hub_set_pin': 'PIN setzen',
      'drivers_hub_show_pin': 'PIN anzeigen',
      'drivers_hub_sort_id_asc': 'ID A-Z',
      'drivers_hub_sort_name_asc': 'Name A-Z',
      'drivers_hub_sort_name_desc': 'Name Z-A',
      'drivers_hub_sort_approved': 'Genehmigt',
      'drivers_hub_sort_newest': 'Neueste',
      'drivers_hub_sort_oldest': 'Aelteste',
      'drivers_hub_sort_pending': 'Ausstehend',
      'drivers_hub_sort_rejected': 'Abgelehnt',
      'drivers_hub_status_approved': 'Genehmigt',
      'drivers_hub_status_pending': 'Ausstehend',
      'drivers_hub_status_rejected': 'Abgelehnt',
      'drivers_hub_switch_off': 'Aus',
      'drivers_hub_switch_on': 'An',
      'drivers_hub_title': 'Fahrer Hub',
      'drivers_hub_tooltip_create_login': 'Login erstellen',
      'drivers_hub_tooltip_delete_driver': 'Fahrer loeschen',
      'drivers_hub_tooltip_reset_login': 'Login zuruecksetzen',
      'drivers_hub_tooltip_view_details': 'Details anzeigen',
      'drivers_hub_transporter_id': 'Transporter-ID',
      'drivers_hub_transporter_id_line': 'Transporter-ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter-ID (Login-ID)',
      'drivers_hub_transporter_id_required': 'Transporter-ID ist erforderlich.',
      'drivers_hub_upload_doc': 'Dokument hochladen',
      'drivers_hub_upload_driver_document': 'Fahrer-Dokument hochladen',
      'drivers_hub_valid_driver_email_required':
          'Gueltige Fahrer-E-Mail ist erforderlich.',
    },
    'sq': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'Shto shofer',
      'drivers_hub_add_edit_driver': 'Shto / ndrysho shofer',
      'drivers_hub_admin_tools': 'Vegla admini',
      'drivers_hub_change_pin': 'Ndrysho PIN',
      'drivers_hub_confirm_password': 'Konfirmo fjalekalimin',
      'drivers_hub_copy_label': 'Kopjo {label}',
      'drivers_hub_could_not_launch_document_url': 'URL e dokumentit nuk u hap',
      'drivers_hub_create_login_for_all': 'Krijo login per te gjithe',
      'drivers_hub_create_logins_for_all_body':
          'Kjo do te krijoje login per te gjithe shoferet qe nuk kane ende login,\nduke perdorur fjalekalimin:\n\n{password}\n\nVazhdo?',
      'drivers_hub_create_logins_for_all_drivers':
          'Krijo login per te gjithe shoferet',
      'drivers_hub_created_logins_summary':
          'U krijuan login per {created} shofer. U anashkaluan {skipped} (kishin login ose mungonte ID).',
      'drivers_hub_csv_import_failed':
          'Importi i CSV te shoferve deshtoi: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'CSV e shoferve u importua per DSP-ne tende ({file}).',
      'drivers_hub_default_driver_password':
          'Fjalekalimi i parazgjedhur i shoferit',
      'drivers_hub_default_password_cannot_be_empty':
          'Fjalekalimi i parazgjedhur nuk mund te jete bosh.',
      'drivers_hub_delete_document_body': 'Kjo do te fshije {document}.',
      'drivers_hub_delete_document_title': 'Te fshihet dokumenti?',
      'drivers_hub_delete_driver_body':
          'Je i sigurt qe do ta fshish shoferin "{name}"?\nDo te hiqet edhe login-i i tij.',
      'drivers_hub_delete_driver_title': 'Fshi shoferin',
      'drivers_hub_delete_failed': 'Fshirja deshtoi: {error}',
      'drivers_hub_document_deleted': '{document} u fshi.',
      'drivers_hub_document_type': 'Lloji i dokumentit',
      'drivers_hub_document_uploaded': '{document} u ngarkua.',
      'drivers_hub_documents': 'Dokumente',
      'drivers_hub_documents_expired': '{count} dokumente te skaduara',
      'drivers_hub_documents_expiring_soon':
          '{count} dokumente skadojne se shpejti',
      'drivers_hub_download': 'Shkarko',
      'drivers_hub_driver_activated': 'Shoferi u aktivizua.',
      'drivers_hub_driver_deleted': 'Shoferi u fshi.',
      'drivers_hub_driver_email': 'Email i shoferit',
      'drivers_hub_driver_line': 'Shoferi: {name}',
      'drivers_hub_driver_login_created': 'Login i shoferit u krijua',
      'drivers_hub_driver_login_saved': 'Login i shoferit u ruajt me sukses.',
      'drivers_hub_driver_name': 'Emri i shoferit',
      'drivers_hub_driver_saved': 'Shoferi "{name}" u ruajt.',
      'drivers_hub_driver_suspended': 'Shoferi u pezullua.',
      'drivers_hub_driving_licence_front_preview':
          'Parashikim patente (pjesa e pare)',
      'drivers_hub_edit_label': 'Ndrysho {label}',
      'drivers_hub_email': 'Email',
      'drivers_hub_email_optional': 'Email (opsionale)',
      'drivers_hub_expiry_contract': 'Kontrate',
      'drivers_hub_expiry_driving_license': 'Patente',
      'drivers_hub_expiry_id_passport': 'ID / Pasaporte',
      'drivers_hub_expiry_items_expired': '{items} kane skaduar',
      'drivers_hub_expiry_items_expiring_soon': '{items} skadojne se shpejti',
      'drivers_hub_expiry_probezeit': 'Periudha prove',
      'drivers_hub_expiry_work_permit': 'Leje pune',
      'drivers_hub_export_pdf': 'Eksporto PDF',
      'drivers_hub_failed_create_logins':
          'Krijimi i login-eve deshtoi: {error}',
      'drivers_hub_failed_delete_document':
          'Fshirja e dokumentit deshtoi: {error}',
      'drivers_hub_failed_load_pdf_preview': 'Parashikimi i PDF nuk u ngarkua.',
      'drivers_hub_failed_save_default_password':
          'Ruajtja e fjalekalimit te parazgjedhur deshtoi: {error}',
      'drivers_hub_failed_set_login': 'Vendosja e login-it deshtoi: {error}',
      'drivers_hub_failed_update_label':
          'Perditesimi i {label} deshtoi: {error}',
      'drivers_hub_failed_upload_document':
          'Ngarkimi i dokumentit deshtoi: {error}',
      'drivers_hub_field_city': 'Qyteti',
      'drivers_hub_field_city_of_birth': 'Qyteti i lindjes',
      'drivers_hub_field_contract_expiry': 'Skadimi i kontrates',
      'drivers_hub_field_country': 'Shteti',
      'drivers_hub_field_date_of_birth': 'Data e lindjes',
      'drivers_hub_field_driving_license_number': 'Numri i patentes',
      'drivers_hub_field_emergency_contact_name': 'Emri i kontaktit emergjent',
      'drivers_hub_field_emergency_contact_phone':
          'Telefoni i kontaktit emergjent',
      'drivers_hub_field_full_name': 'Emri i plote',
      'drivers_hub_field_id_card_passport_expiry': 'Skadimi i ID / pasaportes',
      'drivers_hub_field_insurance_company': 'Kompania e sigurimit',
      'drivers_hub_field_license_expiry_date': 'Data e skadimit te patentes',
      'drivers_hub_field_name_at_birth': 'Emri ne lindje',
      'drivers_hub_field_nationality_id_card': 'Shtetesia (ID)',
      'drivers_hub_field_notes': 'Shenime',
      'drivers_hub_field_phone': 'Telefoni',
      'drivers_hub_field_postal_code': 'Kodi postar',
      'drivers_hub_field_probezeit_end': 'Fundi i periudhes prove',
      'drivers_hub_field_shoe_size': 'Numri i kepuceve',
      'drivers_hub_field_state_of_birth': 'Shteti i lindjes',
      'drivers_hub_field_street_address': 'Adresa (rruga)',
      'drivers_hub_field_tshirt_size': 'Madhesia e bluces',
      'drivers_hub_field_work_permit_expiry': 'Skadimi i lejes se punes',
      'drivers_hub_field_work_start_date': 'Data e fillimit te punes',
      'drivers_hub_header_action': 'Veprim',
      'drivers_hub_header_login': 'Login',
      'drivers_hub_header_overall': 'Mesatarja',
      'drivers_hub_header_profile': 'Profili',
      'drivers_hub_header_status': 'Statusi',
      'drivers_hub_header_working': 'Aktiv',
      'drivers_hub_hide_pin': 'Fshih PIN',
      'drivers_hub_import_csv': 'Importo CSV',
      'drivers_hub_label_copied': '{label} u kopjua',
      'drivers_hub_login_created': 'Login i krijuar',
      'drivers_hub_must_login_add_driver':
          'Duhet te jesh i kycur per te shtuar shofer.',
      'drivers_hub_must_login_import_csv':
          'Duhet te jesh i kycur per te importuar CSV.',
      'drivers_hub_must_login_manage_logins':
          'Duhet te jesh i kycur per menaxhimin e login-eve.',
      'drivers_hub_must_login_view_drivers':
          'Duhet te jesh i kycur per te pare shoferet.',
      'drivers_hub_name_and_transporter_id_required':
          'Emri dhe Transporter ID jane te detyrueshme.',
      'drivers_hub_no_drivers_for_dsp': 'Nuk u gjeten shofer per kete DSP.',
      'drivers_hub_no_drivers_yet':
          'Nuk ka ende shofer.\nImporto CSV ose shto shofer manualisht.',
      'drivers_hub_no_login': 'Pa login',
      'drivers_hub_not_set': 'Nuk eshte vendosur',
      'drivers_hub_not_uploaded': 'Nuk eshte ngarkuar',
      'drivers_hub_notification_pin': 'PIN i njoftimeve',
      'drivers_hub_onboarding_completed': 'Onboarding i perfunduar',
      'drivers_hub_password': 'Fjalekalimi',
      'drivers_hub_passwords_must_match':
          'Fjalekalimet duhet te jene te njejta dhe jo bosh.',
      'drivers_hub_pdf_driver_onboarding': 'Onboarding i shoferit',
      'drivers_hub_preview_not_available':
          'Parashikimi nuk eshte i disponueshem per kete lloj file. Perdorni shkarkimin.',
      'drivers_hub_preview_unavailable_image':
          'Parashikimi i imazhit nuk eshte i disponueshem.',
      'drivers_hub_probezeit_expired': 'Periudha prove ka skaduar',
      'drivers_hub_probezeit_expiring_soon': 'Periudha prove skadon se shpejti',
      'drivers_hub_replace_slot_hint':
          'Ky slot do te krijohet/zevendesohet: {slot}',
      'drivers_hub_search_name_or_email': 'Kerko sipas emrit ose email-it...',
      'drivers_hub_section_address': 'Adresa',
      'drivers_hub_section_document_expiry_dates':
          'Datat e skadimit te dokumenteve',
      'drivers_hub_section_driving_license': 'Patente',
      'drivers_hub_section_emergency_contact': 'Kontakt emergjent',
      'drivers_hub_section_origin': 'Origjina',
      'drivers_hub_section_other_notes': 'Shenime te tjera',
      'drivers_hub_section_payment_tax': 'Pagesa & taksa',
      'drivers_hub_section_personal_details': 'Detaje personale',
      'drivers_hub_section_uniform': 'Uniforma',
      'drivers_hub_set_driver_login': 'Vendos login e shoferit',
      'drivers_hub_set_pin': 'Vendos PIN',
      'drivers_hub_show_pin': 'Shfaq PIN',
      'drivers_hub_sort_id_asc': 'ID A-Z',
      'drivers_hub_sort_name_asc': 'Emri A-Z',
      'drivers_hub_sort_name_desc': 'Emri Z-A',
      'drivers_hub_sort_approved': 'Miratuar',
      'drivers_hub_sort_newest': 'Me te rinjte',
      'drivers_hub_sort_oldest': 'Me te vjeterit',
      'drivers_hub_sort_pending': 'Ne pritje',
      'drivers_hub_sort_rejected': 'Refuzuar',
      'drivers_hub_status_approved': 'Miratuar',
      'drivers_hub_status_pending': 'Ne pritje',
      'drivers_hub_status_rejected': 'Refuzuar',
      'drivers_hub_switch_off': 'Fikur',
      'drivers_hub_switch_on': 'Ndezur',
      'drivers_hub_title': 'Qendra e Shoferëve',
      'drivers_hub_tooltip_create_login': 'Krijo login',
      'drivers_hub_tooltip_delete_driver': 'Fshi shoferin',
      'drivers_hub_tooltip_reset_login': 'Rivendos login',
      'drivers_hub_tooltip_view_details': 'Shiko detajet',
      'drivers_hub_transporter_id': 'Transporter ID',
      'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter ID (ID login)',
      'drivers_hub_transporter_id_required':
          'Transporter ID eshte i detyrueshem.',
      'drivers_hub_upload_doc': 'Ngarko dokument',
      'drivers_hub_upload_driver_document': 'Ngarko dokument shoferi',
      'drivers_hub_valid_driver_email_required':
          'Kerkohet email i vlefshem i shoferit.',
    },
    'hu': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'Sofor hozzaadasa',
      'drivers_hub_add_edit_driver': 'Sofor hozzaadasa / szerkesztese',
      'drivers_hub_admin_tools': 'Admin eszkozok',
      'drivers_hub_change_pin': 'PIN modositasa',
      'drivers_hub_confirm_password': 'Jelszo megerositese',
      'drivers_hub_copy_label': '{label} masolasa',
      'drivers_hub_could_not_launch_document_url':
          'A dokumentum URL nem nyithato meg',
      'drivers_hub_create_login_for_all': 'Belepes letrehozasa mindenkinek',
      'drivers_hub_create_logins_for_all_body':
          'Ez belepest hoz letre minden olyan sofornek, akinek meg nincs,\na kovetkezo jelszoval:\n\n{password}\n\nFolytatod?',
      'drivers_hub_create_logins_for_all_drivers':
          'Belepes letrehozasa minden sofornek',
      'drivers_hub_created_logins_summary':
          '{created} sofornek keszult belepes. {skipped} kihagyva (mar volt belepes vagy hianyzott ID).',
      'drivers_hub_csv_import_failed': 'Sofor CSV import hiba: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'Sofor CSV importalva a DSP-hez ({file}).',
      'drivers_hub_default_driver_password': 'Alapertelmezett sofor jelszo',
      'drivers_hub_default_password_cannot_be_empty':
          'Az alapertelmezett jelszo nem lehet ures.',
      'drivers_hub_delete_document_body': 'Ez torli: {document}.',
      'drivers_hub_delete_document_title': 'Dokumentum torlese?',
      'drivers_hub_delete_driver_body':
          'Biztosan torlod "{name}" sofort?\nA sofor es a belepese is torlodik.',
      'drivers_hub_delete_driver_title': 'Sofor torlese',
      'drivers_hub_delete_failed': 'Torles sikertelen: {error}',
      'drivers_hub_document_deleted': '{document} torolve.',
      'drivers_hub_document_type': 'Dokumentum tipus',
      'drivers_hub_document_uploaded': '{document} feltoltve.',
      'drivers_hub_documents': 'Dokumentumok',
      'drivers_hub_documents_expired': '{count} dokumentum lejart',
      'drivers_hub_documents_expiring_soon':
          '{count} dokumentum hamarosan lejar',
      'drivers_hub_download': 'Letoltes',
      'drivers_hub_driver_activated': 'Sofor aktivalva.',
      'drivers_hub_driver_deleted': 'Sofor torolve.',
      'drivers_hub_driver_email': 'Sofor email',
      'drivers_hub_driver_line': 'Sofor: {name}',
      'drivers_hub_driver_login_created': 'Sofor belepes letrehozva',
      'drivers_hub_driver_login_saved': 'Sofor belepes sikeresen mentve.',
      'drivers_hub_driver_name': 'Sofor neve',
      'drivers_hub_driver_saved': '"{name}" sofor mentve.',
      'drivers_hub_driver_suspended': 'Sofor felfuggesztve.',
      'drivers_hub_driving_licence_front_preview':
          'Jogositvany (elol) elonezet',
      'drivers_hub_edit_label': '{label} szerkesztese',
      'drivers_hub_email': 'Email',
      'drivers_hub_email_optional': 'Email (opcionalis)',
      'drivers_hub_expiry_contract': 'Szerzodes',
      'drivers_hub_expiry_driving_license': 'Jogositvany',
      'drivers_hub_expiry_id_passport': 'Szemelyi / Utlevel',
      'drivers_hub_expiry_items_expired': '{items} lejart',
      'drivers_hub_expiry_items_expiring_soon': '{items} hamarosan lejar',
      'drivers_hub_expiry_probezeit': 'Probeido',
      'drivers_hub_expiry_work_permit': 'Munkavallalasi engedely',
      'drivers_hub_export_pdf': 'PDF export',
      'drivers_hub_failed_create_logins':
          'Belepesek letrehozasa sikertelen: {error}',
      'drivers_hub_failed_delete_document':
          'Dokumentum torlese sikertelen: {error}',
      'drivers_hub_failed_load_pdf_preview':
          'PDF elonezet betoltese sikertelen.',
      'drivers_hub_failed_save_default_password':
          'Alapertelmezett jelszo mentese sikertelen: {error}',
      'drivers_hub_failed_set_login': 'Belepes beallitasa sikertelen: {error}',
      'drivers_hub_failed_update_label':
          '{label} frissitese sikertelen: {error}',
      'drivers_hub_failed_upload_document':
          'Dokumentum feltoltese sikertelen: {error}',
      'drivers_hub_field_city': 'Varos',
      'drivers_hub_field_city_of_birth': 'Szuletesi varos',
      'drivers_hub_field_contract_expiry': 'Szerzodes lejarata',
      'drivers_hub_field_country': 'Orszag',
      'drivers_hub_field_date_of_birth': 'Szuletesi datum',
      'drivers_hub_field_driving_license_number': 'Jogositvany szama',
      'drivers_hub_field_emergency_contact_name': 'Veszhelyzeti kontakt neve',
      'drivers_hub_field_emergency_contact_phone':
          'Veszhelyzeti kontakt telefon',
      'drivers_hub_field_full_name': 'Teljes nev',
      'drivers_hub_field_id_card_passport_expiry':
          'Szemelyi / utlevel lejarata',
      'drivers_hub_field_insurance_company': 'Biztosito',
      'drivers_hub_field_license_expiry_date': 'Jogositvany lejarati datuma',
      'drivers_hub_field_name_at_birth': 'Szuletesi nev',
      'drivers_hub_field_nationality_id_card': 'Allampolgarsag (szemelyi)',
      'drivers_hub_field_notes': 'Megjegyzesek',
      'drivers_hub_field_phone': 'Telefon',
      'drivers_hub_field_postal_code': 'Iranyitoszam',
      'drivers_hub_field_probezeit_end': 'Probeido vege',
      'drivers_hub_field_shoe_size': 'Cipomeret',
      'drivers_hub_field_state_of_birth': 'Szuletesi allam',
      'drivers_hub_field_street_address': 'Utca cim',
      'drivers_hub_field_tshirt_size': 'Polo meret',
      'drivers_hub_field_work_permit_expiry':
          'Munkavallalasi engedely lejarata',
      'drivers_hub_field_work_start_date': 'Munkakezdes datuma',
      'drivers_hub_header_action': 'Muvelet',
      'drivers_hub_header_login': 'Belepes',
      'drivers_hub_header_overall': 'Atlag',
      'drivers_hub_header_profile': 'Profil',
      'drivers_hub_header_status': 'Statusz',
      'drivers_hub_header_working': 'Aktiv',
      'drivers_hub_hide_pin': 'PIN elrejtese',
      'drivers_hub_import_csv': 'CSV import',
      'drivers_hub_label_copied': '{label} masolva',
      'drivers_hub_login_created': 'Belepes letrehozva',
      'drivers_hub_must_login_add_driver':
          'Be kell jelentkezned a sofor hozzaadasahoz.',
      'drivers_hub_must_login_import_csv':
          'Be kell jelentkezned a CSV importhoz.',
      'drivers_hub_must_login_manage_logins':
          'Be kell jelentkezned a sofor belepesek kezeleshez.',
      'drivers_hub_must_login_view_drivers':
          'Be kell jelentkezned a soforok megtekintesehez.',
      'drivers_hub_name_and_transporter_id_required':
          'Nev es Transporter ID kotelezo.',
      'drivers_hub_no_drivers_for_dsp':
          'Ehhez a DSP-hez nincs sofor talalhato.',
      'drivers_hub_no_drivers_yet':
          'Meg nincsenek soforok.\nImportalj CSV-t vagy adj hozza kezzel.',
      'drivers_hub_no_login': 'Nincs belepes',
      'drivers_hub_not_set': 'Nincs beallitva',
      'drivers_hub_not_uploaded': 'Nincs feltoltve',
      'drivers_hub_notification_pin': 'Ertesitesi PIN',
      'drivers_hub_onboarding_completed': 'Onboarding befejezve',
      'drivers_hub_password': 'Jelszo',
      'drivers_hub_passwords_must_match':
          'A jelszavaknak egyezniuk kell es nem lehetnek uresek.',
      'drivers_hub_pdf_driver_onboarding': 'Sofor onboarding',
      'drivers_hub_preview_not_available':
          'Ehhez a fajltipushoz nincs elonezet. Letolteshez kattints.',
      'drivers_hub_preview_unavailable_image': 'Ehhez a kephez nincs elonezet.',
      'drivers_hub_probezeit_expired': 'Probeido lejart',
      'drivers_hub_probezeit_expiring_soon': 'Probeido hamarosan lejar',
      'drivers_hub_replace_slot_hint':
          'Ez a slot letrejon/lecserelodik: {slot}',
      'drivers_hub_search_name_or_email': 'Kereses nev vagy email alapjan...',
      'drivers_hub_section_address': 'Cim',
      'drivers_hub_section_document_expiry_dates': 'Dokumentum lejaratok',
      'drivers_hub_section_driving_license': 'Jogositvany',
      'drivers_hub_section_emergency_contact': 'Veszhelyzeti kontakt',
      'drivers_hub_section_origin': 'Szarmazas',
      'drivers_hub_section_other_notes': 'Egyeb megjegyzesek',
      'drivers_hub_section_payment_tax': 'Fizetes es ado',
      'drivers_hub_section_personal_details': 'Szemelyes adatok',
      'drivers_hub_section_uniform': 'Egyenruha',
      'drivers_hub_set_driver_login': 'Sofor belepes beallitasa',
      'drivers_hub_set_pin': 'PIN beallitasa',
      'drivers_hub_show_pin': 'PIN mutatasa',
      'drivers_hub_sort_id_asc': 'ID A-Z',
      'drivers_hub_sort_name_asc': 'Nev A-Z',
      'drivers_hub_sort_name_desc': 'Nev Z-A',
      'drivers_hub_sort_approved': 'Jovahagyva',
      'drivers_hub_sort_newest': 'Legujabb',
      'drivers_hub_sort_oldest': 'Legregebbi',
      'drivers_hub_sort_pending': 'Fuggoben',
      'drivers_hub_sort_rejected': 'Elutasitva',
      'drivers_hub_status_approved': 'Jovahagyva',
      'drivers_hub_status_pending': 'Fuggoben',
      'drivers_hub_status_rejected': 'Elutasitva',
      'drivers_hub_switch_off': 'Ki',
      'drivers_hub_switch_on': 'Be',
      'drivers_hub_title': 'Sofor Hub',
      'drivers_hub_tooltip_create_login': 'Belepes letrehozasa',
      'drivers_hub_tooltip_delete_driver': 'Sofor torlese',
      'drivers_hub_tooltip_reset_login': 'Belepes visszaallitasa',
      'drivers_hub_tooltip_view_details': 'Reszletek megtekintese',
      'drivers_hub_transporter_id': 'Transporter ID',
      'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter ID (belepesi ID)',
      'drivers_hub_transporter_id_required': 'A Transporter ID kotelezo.',
      'drivers_hub_upload_doc': 'Dokumentum feltoltese',
      'drivers_hub_upload_driver_document': 'Sofor dokumentum feltoltese',
      'drivers_hub_valid_driver_email_required':
          'Ervenyes sofor email kotelezo.',
    },
    'ro': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'Adauga sofer',
      'drivers_hub_add_edit_driver': 'Adauga / editeaza sofer',
      'drivers_hub_admin_tools': 'Instrumente admin',
      'drivers_hub_change_pin': 'Schimba PIN',
      'drivers_hub_confirm_password': 'Confirma parola',
      'drivers_hub_copy_label': 'Copiaza {label}',
      'drivers_hub_could_not_launch_document_url':
          'URL-ul documentului nu a putut fi deschis',
      'drivers_hub_create_login_for_all': 'Creeaza login pentru toti',
      'drivers_hub_create_logins_for_all_body':
          'Se vor crea logins pentru toti soferii fara login,\nfolosind parola:\n\n{password}\n\nContinui?',
      'drivers_hub_create_logins_for_all_drivers':
          'Creeaza logins pentru toti soferii',
      'drivers_hub_created_logins_summary':
          'Au fost create logins pentru {created} soferi. S-au omis {skipped} (aveau deja login sau lipsea ID).',
      'drivers_hub_csv_import_failed': 'Importul CSV a esuat: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'CSV soferi importat pentru DSP-ul tau ({file}).',
      'drivers_hub_default_driver_password': 'Parola implicita pentru soferi',
      'drivers_hub_default_password_cannot_be_empty':
          'Parola implicita nu poate fi goala.',
      'drivers_hub_delete_document_body': 'Se va sterge {document}.',
      'drivers_hub_delete_document_title': 'Stergi documentul?',
      'drivers_hub_delete_driver_body':
          'Sigur vrei sa stergi soferul "{name}"?\nAcesta si login-ul lui vor fi eliminate.',
      'drivers_hub_delete_driver_title': 'Sterge sofer',
      'drivers_hub_delete_failed': 'Stergerea a esuat: {error}',
      'drivers_hub_document_deleted': '{document} a fost sters.',
      'drivers_hub_document_type': 'Tip document',
      'drivers_hub_document_uploaded': '{document} incarcat.',
      'drivers_hub_documents': 'Documente',
      'drivers_hub_documents_expired': '{count} documente expirate',
      'drivers_hub_documents_expiring_soon': '{count} documente expira curand',
      'drivers_hub_download': 'Descarca',
      'drivers_hub_driver_activated': 'Sofer activat.',
      'drivers_hub_driver_deleted': 'Sofer sters.',
      'drivers_hub_driver_email': 'Email sofer',
      'drivers_hub_driver_line': 'Sofer: {name}',
      'drivers_hub_driver_login_created': 'Login sofer creat',
      'drivers_hub_driver_login_saved': 'Login sofer salvat cu succes.',
      'drivers_hub_driver_name': 'Nume sofer',
      'drivers_hub_driver_saved': 'Soferul "{name}" a fost salvat.',
      'drivers_hub_driver_suspended': 'Sofer suspendat.',
      'drivers_hub_driving_licence_front_preview':
          'Previzualizare permis (fata)',
      'drivers_hub_edit_label': 'Editeaza {label}',
      'drivers_hub_email': 'Email',
      'drivers_hub_email_optional': 'Email (optional)',
      'drivers_hub_expiry_contract': 'Contract',
      'drivers_hub_expiry_driving_license': 'Permis de conducere',
      'drivers_hub_expiry_id_passport': 'CI / Pasaport',
      'drivers_hub_expiry_items_expired': '{items} au expirat',
      'drivers_hub_expiry_items_expiring_soon': '{items} expira curand',
      'drivers_hub_expiry_probezeit': 'Perioada de proba',
      'drivers_hub_expiry_work_permit': 'Permis de munca',
      'drivers_hub_export_pdf': 'Exporta PDF',
      'drivers_hub_failed_create_logins':
          'Crearea login-urilor a esuat: {error}',
      'drivers_hub_failed_delete_document':
          'Stergerea documentului a esuat: {error}',
      'drivers_hub_failed_load_pdf_preview':
          'Previzualizarea PDF nu a putut fi incarcata.',
      'drivers_hub_failed_save_default_password':
          'Salvarea parolei implicite a esuat: {error}',
      'drivers_hub_failed_set_login': 'Setarea login-ului a esuat: {error}',
      'drivers_hub_failed_update_label':
          'Actualizarea {label} a esuat: {error}',
      'drivers_hub_failed_upload_document':
          'Incarcarea documentului a esuat: {error}',
      'drivers_hub_field_city': 'Oras',
      'drivers_hub_field_city_of_birth': 'Orasul nasterii',
      'drivers_hub_field_contract_expiry': 'Expirare contract',
      'drivers_hub_field_country': 'Tara',
      'drivers_hub_field_date_of_birth': 'Data nasterii',
      'drivers_hub_field_driving_license_number': 'Numar permis',
      'drivers_hub_field_emergency_contact_name': 'Nume contact de urgenta',
      'drivers_hub_field_emergency_contact_phone': 'Telefon contact de urgenta',
      'drivers_hub_field_full_name': 'Nume complet',
      'drivers_hub_field_id_card_passport_expiry': 'Expirare CI / pasaport',
      'drivers_hub_field_insurance_company': 'Companie asigurare',
      'drivers_hub_field_license_expiry_date': 'Expirare permis',
      'drivers_hub_field_name_at_birth': 'Nume la nastere',
      'drivers_hub_field_nationality_id_card': 'Nationalitate (CI)',
      'drivers_hub_field_notes': 'Note',
      'drivers_hub_field_phone': 'Telefon',
      'drivers_hub_field_postal_code': 'Cod postal',
      'drivers_hub_field_probezeit_end': 'Final perioada de proba',
      'drivers_hub_field_shoe_size': 'Marime pantofi',
      'drivers_hub_field_state_of_birth': 'Statul nasterii',
      'drivers_hub_field_street_address': 'Adresa strada',
      'drivers_hub_field_tshirt_size': 'Marime tricou',
      'drivers_hub_field_work_permit_expiry': 'Expirare permis de munca',
      'drivers_hub_field_work_start_date': 'Data inceperii muncii',
      'drivers_hub_header_action': 'Actiune',
      'drivers_hub_header_login': 'Login',
      'drivers_hub_header_overall': 'General',
      'drivers_hub_header_profile': 'Profil',
      'drivers_hub_header_status': 'Status',
      'drivers_hub_header_working': 'Activ',
      'drivers_hub_hide_pin': 'Ascunde PIN',
      'drivers_hub_import_csv': 'Importa CSV',
      'drivers_hub_label_copied': '{label} copiat',
      'drivers_hub_login_created': 'Login creat',
      'drivers_hub_must_login_add_driver':
          'Trebuie sa fii autentificat pentru a adauga soferi.',
      'drivers_hub_must_login_import_csv':
          'Trebuie sa fii autentificat pentru a importa CSV.',
      'drivers_hub_must_login_manage_logins':
          'Trebuie sa fii autentificat pentru a gestiona login-urile.',
      'drivers_hub_must_login_view_drivers':
          'Trebuie sa fii autentificat pentru a vedea soferii.',
      'drivers_hub_name_and_transporter_id_required':
          'Numele si Transporter ID sunt obligatorii.',
      'drivers_hub_no_drivers_for_dsp':
          'Nu au fost gasiti soferi pentru acest DSP.',
      'drivers_hub_no_drivers_yet':
          'Nu exista inca soferi.\nImporta un CSV sau adauga manual un sofer.',
      'drivers_hub_no_login': 'Fara login',
      'drivers_hub_not_set': 'Nesetat',
      'drivers_hub_not_uploaded': 'Neincarcat',
      'drivers_hub_notification_pin': 'PIN notificari',
      'drivers_hub_onboarding_completed': 'Onboarding finalizat',
      'drivers_hub_password': 'Parola',
      'drivers_hub_passwords_must_match':
          'Parolele trebuie sa coincida si sa nu fie goale.',
      'drivers_hub_pdf_driver_onboarding': 'Onboarding sofer',
      'drivers_hub_preview_not_available':
          'Previzualizarea nu este disponibila pentru acest tip de fisier. Foloseste descarcarea.',
      'drivers_hub_preview_unavailable_image':
          'Previzualizarea imaginii nu este disponibila.',
      'drivers_hub_probezeit_expired': 'Perioada de proba expirata',
      'drivers_hub_probezeit_expiring_soon': 'Perioada de proba expira curand',
      'drivers_hub_replace_slot_hint':
          'Acest slot va fi creat/inlocuit: {slot}',
      'drivers_hub_search_name_or_email': 'Cauta dupa nume sau email...',
      'drivers_hub_section_address': 'Adresa',
      'drivers_hub_section_document_expiry_dates': 'Date expirare documente',
      'drivers_hub_section_driving_license': 'Permis de conducere',
      'drivers_hub_section_emergency_contact': 'Contact de urgenta',
      'drivers_hub_section_origin': 'Origine',
      'drivers_hub_section_other_notes': 'Alte note',
      'drivers_hub_section_payment_tax': 'Plata si taxe',
      'drivers_hub_section_personal_details': 'Detalii personale',
      'drivers_hub_section_uniform': 'Uniforma',
      'drivers_hub_set_driver_login': 'Seteaza login sofer',
      'drivers_hub_set_pin': 'Seteaza PIN',
      'drivers_hub_show_pin': 'Arata PIN',
      'drivers_hub_sort_id_asc': 'ID A-Z',
      'drivers_hub_sort_name_asc': 'Nume A-Z',
      'drivers_hub_sort_name_desc': 'Nume Z-A',
      'drivers_hub_sort_approved': 'Aprobat',
      'drivers_hub_sort_newest': 'Cele mai noi',
      'drivers_hub_sort_oldest': 'Cele mai vechi',
      'drivers_hub_sort_pending': 'In asteptare',
      'drivers_hub_sort_rejected': 'Respins',
      'drivers_hub_status_approved': 'Aprobat',
      'drivers_hub_status_pending': 'In asteptare',
      'drivers_hub_status_rejected': 'Respins',
      'drivers_hub_switch_off': 'Oprit',
      'drivers_hub_switch_on': 'Pornit',
      'drivers_hub_title': 'Hub Soferi',
      'drivers_hub_tooltip_create_login': 'Creeaza login',
      'drivers_hub_tooltip_delete_driver': 'Sterge sofer',
      'drivers_hub_tooltip_reset_login': 'Reseteaza login',
      'drivers_hub_tooltip_view_details': 'Vezi detalii',
      'drivers_hub_transporter_id': 'Transporter ID',
      'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter ID (ID login)',
      'drivers_hub_transporter_id_required': 'Transporter ID este obligatoriu.',
      'drivers_hub_upload_doc': 'Incarca document',
      'drivers_hub_upload_driver_document': 'Incarca document sofer',
      'drivers_hub_valid_driver_email_required':
          'Este necesar un email valid de sofer.',
    },
    'hr': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'Dodaj vozaca',
      'drivers_hub_add_edit_driver': 'Dodaj / uredi vozaca',
      'drivers_hub_admin_tools': 'Admin alati',
      'drivers_hub_change_pin': 'Promijeni PIN',
      'drivers_hub_confirm_password': 'Potvrdi lozinku',
      'drivers_hub_copy_label': 'Kopiraj {label}',
      'drivers_hub_could_not_launch_document_url':
          'URL dokumenta nije moguce otvoriti',
      'drivers_hub_create_login_for_all': 'Kreiraj login za sve',
      'drivers_hub_create_logins_for_all_body':
          'Ovo ce kreirati logine za sve vozace koji jos nemaju login,\nkoristeci lozinku:\n\n{password}\n\nNastaviti?',
      'drivers_hub_create_logins_for_all_drivers':
          'Kreiraj logine za sve vozace',
      'drivers_hub_created_logins_summary':
          'Kreirani logini za {created} vozaca. Preskoceno {skipped} (vec imaju login ili nedostaje ID).',
      'drivers_hub_csv_import_failed': 'Uvoz CSV-a nije uspio: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'CSV vozaca je uvezen za tvoj DSP ({file}).',
      'drivers_hub_default_driver_password': 'Zadana lozinka vozaca',
      'drivers_hub_default_password_cannot_be_empty':
          'Zadana lozinka ne moze biti prazna.',
      'drivers_hub_delete_document_body': 'Ovo ce obrisati {document}.',
      'drivers_hub_delete_document_title': 'Obrisati dokument?',
      'drivers_hub_delete_driver_body':
          'Jesi li siguran da zelis obrisati vozaca "{name}"?\nVozac i njegov login bit ce uklonjeni.',
      'drivers_hub_delete_driver_title': 'Obrisi vozaca',
      'drivers_hub_delete_failed': 'Brisanje nije uspjelo: {error}',
      'drivers_hub_document_deleted': '{document} je obrisan.',
      'drivers_hub_document_type': 'Tip dokumenta',
      'drivers_hub_document_uploaded': '{document} je ucitan.',
      'drivers_hub_documents': 'Dokumenti',
      'drivers_hub_documents_expired': '{count} dokumenata je isteklo',
      'drivers_hub_documents_expiring_soon': '{count} dokumenata uskoro istice',
      'drivers_hub_download': 'Preuzmi',
      'drivers_hub_driver_activated': 'Vozac je aktiviran.',
      'drivers_hub_driver_deleted': 'Vozac je obrisan.',
      'drivers_hub_driver_email': 'Email vozaca',
      'drivers_hub_driver_line': 'Vozac: {name}',
      'drivers_hub_driver_login_created': 'Login vozaca je kreiran',
      'drivers_hub_driver_login_saved': 'Login vozaca je uspjesno sacuvan.',
      'drivers_hub_driver_name': 'Ime vozaca',
      'drivers_hub_driver_saved': 'Vozac "{name}" je sacuvan.',
      'drivers_hub_driver_suspended': 'Vozac je suspendiran.',
      'drivers_hub_driving_licence_front_preview':
          'Pregled vozacke (prednja strana)',
      'drivers_hub_edit_label': 'Uredi {label}',
      'drivers_hub_email': 'Email',
      'drivers_hub_email_optional': 'Email (opcionalno)',
      'drivers_hub_expiry_contract': 'Ugovor',
      'drivers_hub_expiry_driving_license': 'Vozacka dozvola',
      'drivers_hub_expiry_id_passport': 'Osobna / Putovnica',
      'drivers_hub_expiry_items_expired': '{items} je isteklo',
      'drivers_hub_expiry_items_expiring_soon': '{items} uskoro istice',
      'drivers_hub_expiry_probezeit': 'Probni rok',
      'drivers_hub_expiry_work_permit': 'Radna dozvola',
      'drivers_hub_export_pdf': 'Izvezi PDF',
      'drivers_hub_failed_create_logins':
          'Kreiranje logina nije uspjelo: {error}',
      'drivers_hub_failed_delete_document':
          'Brisanje dokumenta nije uspjelo: {error}',
      'drivers_hub_failed_load_pdf_preview': 'PDF pregled nije moguce ucitati.',
      'drivers_hub_failed_save_default_password':
          'Spremanje zadane lozinke nije uspjelo: {error}',
      'drivers_hub_failed_set_login':
          'Postavljanje logina nije uspjelo: {error}',
      'drivers_hub_failed_update_label':
          'Azuriranje {label} nije uspjelo: {error}',
      'drivers_hub_failed_upload_document':
          'Upload dokumenta nije uspio: {error}',
      'drivers_hub_field_city': 'Grad',
      'drivers_hub_field_city_of_birth': 'Grad rodenja',
      'drivers_hub_field_contract_expiry': 'Istek ugovora',
      'drivers_hub_field_country': 'Drzava',
      'drivers_hub_field_date_of_birth': 'Datum rodenja',
      'drivers_hub_field_driving_license_number': 'Broj vozacke dozvole',
      'drivers_hub_field_emergency_contact_name': 'Ime hitnog kontakta',
      'drivers_hub_field_emergency_contact_phone': 'Telefon hitnog kontakta',
      'drivers_hub_field_full_name': 'Puno ime',
      'drivers_hub_field_id_card_passport_expiry': 'Istek osobne / putovnice',
      'drivers_hub_field_insurance_company': 'Osiguravajuce drustvo',
      'drivers_hub_field_license_expiry_date': 'Datum isteka vozacke dozvole',
      'drivers_hub_field_name_at_birth': 'Ime pri rodenju',
      'drivers_hub_field_nationality_id_card': 'Nacionalnost (osobna)',
      'drivers_hub_field_notes': 'Biljeske',
      'drivers_hub_field_phone': 'Telefon',
      'drivers_hub_field_postal_code': 'Postanski broj',
      'drivers_hub_field_probezeit_end': 'Kraj probnog roka',
      'drivers_hub_field_shoe_size': 'Velicina obuce',
      'drivers_hub_field_state_of_birth': 'Drzava rodenja',
      'drivers_hub_field_street_address': 'Adresa ulice',
      'drivers_hub_field_tshirt_size': 'Velicina majice',
      'drivers_hub_field_work_permit_expiry': 'Istek radne dozvole',
      'drivers_hub_field_work_start_date': 'Datum pocetka rada',
      'drivers_hub_header_action': 'Akcija',
      'drivers_hub_header_login': 'Login',
      'drivers_hub_header_overall': 'Ukupno',
      'drivers_hub_header_profile': 'Profil',
      'drivers_hub_header_status': 'Status',
      'drivers_hub_header_working': 'Aktivan',
      'drivers_hub_hide_pin': 'Sakrij PIN',
      'drivers_hub_import_csv': 'Uvezi CSV',
      'drivers_hub_label_copied': '{label} kopirano',
      'drivers_hub_login_created': 'Login kreiran',
      'drivers_hub_must_login_add_driver':
          'Morate biti prijavljeni da biste dodali vozace.',
      'drivers_hub_must_login_import_csv':
          'Morate biti prijavljeni za uvoz CSV-a.',
      'drivers_hub_must_login_manage_logins':
          'Morate biti prijavljeni za upravljanje loginima.',
      'drivers_hub_must_login_view_drivers':
          'Morate biti prijavljeni za prikaz vozaca.',
      'drivers_hub_name_and_transporter_id_required':
          'Ime i Transporter ID su obavezni.',
      'drivers_hub_no_drivers_for_dsp': 'Nema vozaca za ovaj DSP.',
      'drivers_hub_no_drivers_yet':
          'Jos nema vozaca.\nUvezi CSV ili dodaj vozaca rucno.',
      'drivers_hub_no_login': 'Nema logina',
      'drivers_hub_not_set': 'Nije postavljeno',
      'drivers_hub_not_uploaded': 'Nije ucitano',
      'drivers_hub_notification_pin': 'PIN obavijesti',
      'drivers_hub_onboarding_completed': 'Onboarding zavrsen',
      'drivers_hub_password': 'Lozinka',
      'drivers_hub_passwords_must_match':
          'Lozinke se moraju podudarati i ne smiju biti prazne.',
      'drivers_hub_pdf_driver_onboarding': 'Onboarding vozaca',
      'drivers_hub_preview_not_available':
          'Pregled nije dostupan za ovu vrstu datoteke. Koristite preuzimanje.',
      'drivers_hub_preview_unavailable_image': 'Pregled slike nije dostupan.',
      'drivers_hub_probezeit_expired': 'Probni rok je istekao',
      'drivers_hub_probezeit_expiring_soon': 'Probni rok uskoro istice',
      'drivers_hub_replace_slot_hint':
          'Ovaj slot ce biti kreiran/zamijenjen: {slot}',
      'drivers_hub_search_name_or_email': 'Trazi po imenu ili emailu...',
      'drivers_hub_section_address': 'Adresa',
      'drivers_hub_section_document_expiry_dates': 'Datumi isteka dokumenata',
      'drivers_hub_section_driving_license': 'Vozacka dozvola',
      'drivers_hub_section_emergency_contact': 'Hitni kontakt',
      'drivers_hub_section_origin': 'Podrijetlo',
      'drivers_hub_section_other_notes': 'Dodatne biljeske',
      'drivers_hub_section_payment_tax': 'Placanje i porez',
      'drivers_hub_section_personal_details': 'Osobni podaci',
      'drivers_hub_section_uniform': 'Uniforma',
      'drivers_hub_set_driver_login': 'Postavi login vozaca',
      'drivers_hub_set_pin': 'Postavi PIN',
      'drivers_hub_show_pin': 'Prikazi PIN',
      'drivers_hub_sort_id_asc': 'ID A-Z',
      'drivers_hub_sort_name_asc': 'Ime A-Z',
      'drivers_hub_sort_name_desc': 'Ime Z-A',
      'drivers_hub_sort_approved': 'Odobreno',
      'drivers_hub_sort_newest': 'Najnoviji',
      'drivers_hub_sort_oldest': 'Najstariji',
      'drivers_hub_sort_pending': 'Na cekanju',
      'drivers_hub_sort_rejected': 'Odbijeno',
      'drivers_hub_status_approved': 'Odobreno',
      'drivers_hub_status_pending': 'Na cekanju',
      'drivers_hub_status_rejected': 'Odbijeno',
      'drivers_hub_switch_off': 'Isklj',
      'drivers_hub_switch_on': 'Uklj',
      'drivers_hub_title': 'Hub Vozaca',
      'drivers_hub_tooltip_create_login': 'Kreiraj login',
      'drivers_hub_tooltip_delete_driver': 'Obrisi vozaca',
      'drivers_hub_tooltip_reset_login': 'Resetiraj login',
      'drivers_hub_tooltip_view_details': 'Pogledaj detalje',
      'drivers_hub_transporter_id': 'Transporter ID',
      'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter ID (login ID)',
      'drivers_hub_transporter_id_required': 'Transporter ID je obavezan.',
      'drivers_hub_upload_doc': 'Ucitaj dokument',
      'drivers_hub_upload_driver_document': 'Ucitaj dokument vozaca',
      'drivers_hub_valid_driver_email_required':
          'Potreban je valjan email vozaca.',
    },
    'ar': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'إضافة سائق',
      'drivers_hub_add_edit_driver': 'إضافة / تعديل سائق',
      'drivers_hub_admin_tools': 'أدوات المشرف',
      'drivers_hub_change_pin': 'تغيير PIN',
      'drivers_hub_confirm_password': 'تأكيد كلمة المرور',
      'drivers_hub_copy_label': 'نسخ {label}',
      'drivers_hub_could_not_launch_document_url': 'تعذر فتح رابط المستند',
      'drivers_hub_create_login_for_all': 'إنشاء تسجيل دخول للجميع',
      'drivers_hub_create_logins_for_all_body':
          'سيؤدي هذا إلى إنشاء تسجيلات دخول لكل السائقين الذين ليس لديهم تسجيل دخول بعد،\nباستخدام كلمة المرور:\n\n{password}\n\nمتابعة؟',
      'drivers_hub_create_logins_for_all_drivers':
          'إنشاء تسجيل دخول لكل السائقين',
      'drivers_hub_created_logins_summary':
          'تم إنشاء تسجيلات دخول لـ {created} سائق. تم تخطي {skipped} (لديهم تسجيل دخول مسبقاً أو لا يوجد ID).',
      'drivers_hub_csv_import_failed': 'فشل استيراد CSV السائقين: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'تم استيراد CSV السائقين لـ DSP الخاص بك ({file}).',
      'drivers_hub_default_driver_password': 'كلمة المرور الافتراضية للسائق',
      'drivers_hub_default_password_cannot_be_empty':
          'لا يمكن أن تكون كلمة المرور الافتراضية فارغة.',
      'drivers_hub_delete_document_body': 'سيتم حذف {document}.',
      'drivers_hub_delete_document_title': 'حذف المستند؟',
      'drivers_hub_delete_driver_body':
          'هل أنت متأكد أنك تريد حذف السائق "{name}"؟\nسيتم حذف السائق وتسجيل دخوله.',
      'drivers_hub_delete_driver_title': 'حذف السائق',
      'drivers_hub_delete_failed': 'فشل الحذف: {error}',
      'drivers_hub_document_deleted': 'تم حذف {document}.',
      'drivers_hub_document_type': 'نوع المستند',
      'drivers_hub_document_uploaded': 'تم رفع {document}.',
      'drivers_hub_documents': 'المستندات',
      'drivers_hub_documents_expired': '{count} مستندات منتهية',
      'drivers_hub_documents_expiring_soon': '{count} مستندات ستنتهي قريباً',
      'drivers_hub_download': 'تنزيل',
      'drivers_hub_driver_activated': 'تم تفعيل السائق.',
      'drivers_hub_driver_deleted': 'تم حذف السائق.',
      'drivers_hub_driver_email': 'بريد السائق',
      'drivers_hub_driver_line': 'السائق: {name}',
      'drivers_hub_driver_login_created': 'تم إنشاء دخول السائق',
      'drivers_hub_driver_login_saved': 'تم حفظ دخول السائق بنجاح.',
      'drivers_hub_driver_name': 'اسم السائق',
      'drivers_hub_driver_saved': 'تم حفظ السائق "{name}".',
      'drivers_hub_driver_suspended': 'تم إيقاف السائق.',
      'drivers_hub_driving_licence_front_preview':
          'معاينة رخصة القيادة (الوجه الأمامي)',
      'drivers_hub_edit_label': 'تعديل {label}',
      'drivers_hub_email': 'البريد الإلكتروني',
      'drivers_hub_email_optional': 'البريد الإلكتروني (اختياري)',
      'drivers_hub_expiry_contract': 'العقد',
      'drivers_hub_expiry_driving_license': 'رخصة القيادة',
      'drivers_hub_expiry_id_passport': 'الهوية / جواز السفر',
      'drivers_hub_expiry_items_expired': '{items} منتهية',
      'drivers_hub_expiry_items_expiring_soon': '{items} ستنتهي قريباً',
      'drivers_hub_expiry_probezeit': 'فترة التجربة',
      'drivers_hub_expiry_work_permit': 'تصريح العمل',
      'drivers_hub_export_pdf': 'تصدير PDF',
      'drivers_hub_failed_create_logins': 'فشل إنشاء تسجيلات الدخول: {error}',
      'drivers_hub_failed_delete_document': 'فشل حذف المستند: {error}',
      'drivers_hub_failed_load_pdf_preview': 'فشل تحميل معاينة PDF.',
      'drivers_hub_failed_save_default_password':
          'فشل حفظ كلمة المرور الافتراضية: {error}',
      'drivers_hub_failed_set_login': 'فشل تعيين تسجيل الدخول: {error}',
      'drivers_hub_failed_update_label': 'فشل تحديث {label}: {error}',
      'drivers_hub_failed_upload_document': 'فشل رفع المستند: {error}',
      'drivers_hub_field_city': 'المدينة',
      'drivers_hub_field_city_of_birth': 'مدينة الميلاد',
      'drivers_hub_field_contract_expiry': 'انتهاء العقد',
      'drivers_hub_field_country': 'الدولة',
      'drivers_hub_field_date_of_birth': 'تاريخ الميلاد',
      'drivers_hub_field_driving_license_number': 'رقم رخصة القيادة',
      'drivers_hub_field_emergency_contact_name': 'اسم جهة الطوارئ',
      'drivers_hub_field_emergency_contact_phone': 'هاتف جهة الطوارئ',
      'drivers_hub_field_full_name': 'الاسم الكامل',
      'drivers_hub_field_id_card_passport_expiry': 'انتهاء الهوية / الجواز',
      'drivers_hub_field_insurance_company': 'شركة التأمين',
      'drivers_hub_field_license_expiry_date': 'تاريخ انتهاء الرخصة',
      'drivers_hub_field_name_at_birth': 'اسم الميلاد',
      'drivers_hub_field_nationality_id_card': 'الجنسية (الهوية)',
      'drivers_hub_field_notes': 'ملاحظات',
      'drivers_hub_field_phone': 'الهاتف',
      'drivers_hub_field_postal_code': 'الرمز البريدي',
      'drivers_hub_field_probezeit_end': 'نهاية فترة التجربة',
      'drivers_hub_field_shoe_size': 'مقاس الحذاء',
      'drivers_hub_field_state_of_birth': 'بلد الميلاد',
      'drivers_hub_field_street_address': 'عنوان الشارع',
      'drivers_hub_field_tshirt_size': 'مقاس القميص',
      'drivers_hub_field_work_permit_expiry': 'انتهاء تصريح العمل',
      'drivers_hub_field_work_start_date': 'تاريخ بدء العمل',
      'drivers_hub_header_action': 'إجراء',
      'drivers_hub_header_login': 'دخول',
      'drivers_hub_header_overall': 'الإجمالي',
      'drivers_hub_header_profile': 'الملف',
      'drivers_hub_header_status': 'الحالة',
      'drivers_hub_header_working': 'نشط',
      'drivers_hub_hide_pin': 'إخفاء PIN',
      'drivers_hub_import_csv': 'استيراد CSV',
      'drivers_hub_label_copied': 'تم نسخ {label}',
      'drivers_hub_login_created': 'تم إنشاء تسجيل الدخول',
      'drivers_hub_must_login_add_driver': 'يجب تسجيل الدخول لإضافة سائقين.',
      'drivers_hub_must_login_import_csv': 'يجب تسجيل الدخول لاستيراد CSV.',
      'drivers_hub_must_login_manage_logins':
          'يجب تسجيل الدخول لإدارة تسجيلات الدخول.',
      'drivers_hub_must_login_view_drivers': 'يجب تسجيل الدخول لعرض السائقين.',
      'drivers_hub_name_and_transporter_id_required':
          'الاسم ومعرف الناقل مطلوبان.',
      'drivers_hub_no_drivers_for_dsp': 'لا يوجد سائقون لهذا DSP.',
      'drivers_hub_no_drivers_yet':
          'لا يوجد سائقون بعد.\nقم باستيراد CSV أو إضافة سائق يدوياً.',
      'drivers_hub_no_login': 'بدون دخول',
      'drivers_hub_not_set': 'غير مضبوط',
      'drivers_hub_not_uploaded': 'غير مرفوع',
      'drivers_hub_notification_pin': 'PIN الإشعارات',
      'drivers_hub_onboarding_completed': 'اكتمل الإعداد',
      'drivers_hub_password': 'كلمة المرور',
      'drivers_hub_passwords_must_match':
          'يجب أن تتطابق كلمات المرور وألا تكون فارغة.',
      'drivers_hub_pdf_driver_onboarding': 'إعداد السائق',
      'drivers_hub_preview_not_available':
          'المعاينة غير متاحة لهذا النوع من الملفات. استخدم التنزيل.',
      'drivers_hub_preview_unavailable_image': 'معاينة الصورة غير متاحة.',
      'drivers_hub_probezeit_expired': 'انتهت فترة التجربة',
      'drivers_hub_probezeit_expiring_soon': 'فترة التجربة ستنتهي قريباً',
      'drivers_hub_replace_slot_hint': 'سيتم إنشاء/استبدال هذا الموضع: {slot}',
      'drivers_hub_search_name_or_email': 'ابحث بالاسم أو البريد الإلكتروني...',
      'drivers_hub_section_address': 'العنوان',
      'drivers_hub_section_document_expiry_dates': 'تواريخ انتهاء المستندات',
      'drivers_hub_section_driving_license': 'رخصة القيادة',
      'drivers_hub_section_emergency_contact': 'جهة اتصال الطوارئ',
      'drivers_hub_section_origin': 'الأصل',
      'drivers_hub_section_other_notes': 'ملاحظات أخرى',
      'drivers_hub_section_payment_tax': 'الدفع والضرائب',
      'drivers_hub_section_personal_details': 'البيانات الشخصية',
      'drivers_hub_section_uniform': 'الزي',
      'drivers_hub_set_driver_login': 'تعيين دخول السائق',
      'drivers_hub_set_pin': 'تعيين PIN',
      'drivers_hub_show_pin': 'إظهار PIN',
      'drivers_hub_sort_approved': 'معتمد',
      'drivers_hub_sort_newest': 'الأحدث',
      'drivers_hub_sort_oldest': 'الأقدم',
      'drivers_hub_sort_pending': 'قيد الانتظار',
      'drivers_hub_sort_rejected': 'مرفوض',
      'drivers_hub_status_approved': 'معتمد',
      'drivers_hub_status_pending': 'قيد الانتظار',
      'drivers_hub_status_rejected': 'مرفوض',
      'drivers_hub_switch_off': 'إيقاف',
      'drivers_hub_switch_on': 'تشغيل',
      'drivers_hub_title': 'مركز السائقين',
      'drivers_hub_tooltip_create_login': 'إنشاء دخول',
      'drivers_hub_tooltip_delete_driver': 'حذف السائق',
      'drivers_hub_tooltip_reset_login': 'إعادة تعيين الدخول',
      'drivers_hub_tooltip_view_details': 'عرض التفاصيل',
      'drivers_hub_transporter_id': 'Transporter ID',
      'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter ID (معرف الدخول)',
      'drivers_hub_transporter_id_required': 'Transporter ID مطلوب.',
      'drivers_hub_upload_doc': 'رفع مستند',
      'drivers_hub_upload_driver_document': 'رفع مستند السائق',
      'drivers_hub_valid_driver_email_required':
          'يلزم بريد إلكتروني صالح للسائق.',
    },
    'tr': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'Surucu ekle',
      'drivers_hub_add_edit_driver': 'Surucu ekle / duzenle',
      'drivers_hub_admin_tools': 'Admin araclari',
      'drivers_hub_change_pin': 'PIN degistir',
      'drivers_hub_confirm_password': 'Sifreyi onayla',
      'drivers_hub_copy_label': '{label} kopyala',
      'drivers_hub_could_not_launch_document_url': 'Belge URL acilamadi',
      'drivers_hub_create_login_for_all': 'Tumune giris olustur',
      'drivers_hub_create_logins_for_all_body':
          'Bu islem, henuz girisi olmayan tum suruculer icin\nsu sifre ile giris olusturur:\n\n{password}\n\nDevam edilsin mi?',
      'drivers_hub_create_logins_for_all_drivers':
          'Tum suruculer icin giris olustur',
      'drivers_hub_created_logins_summary':
          '{created} surucu icin giris olusturuldu. {skipped} atlandi (zaten girisi vardi veya ID eksikti).',
      'drivers_hub_csv_import_failed': 'Surucu CSV ice aktarma hatasi: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'Surucu CSV DSP icin ice aktarıldi ({file}).',
      'drivers_hub_default_driver_password': 'Varsayilan surucu sifresi',
      'drivers_hub_default_password_cannot_be_empty':
          'Varsayilan sifre bos olamaz.',
      'drivers_hub_delete_document_body': '{document} silinecek.',
      'drivers_hub_delete_document_title': 'Belge silinsin mi?',
      'drivers_hub_delete_driver_body':
          '"{name}" surucusunu silmek istediginize emin misiniz?\nSurucu ve giris bilgileri silinecek.',
      'drivers_hub_delete_driver_title': 'Surucuyu sil',
      'drivers_hub_delete_failed': 'Silme basarisiz: {error}',
      'drivers_hub_document_deleted': '{document} silindi.',
      'drivers_hub_document_type': 'Belge turu',
      'drivers_hub_document_uploaded': '{document} yuklendi.',
      'drivers_hub_documents': 'Belgeler',
      'drivers_hub_documents_expired': '{count} belge suresi dolmus',
      'drivers_hub_documents_expiring_soon': '{count} belge yakinda dolacak',
      'drivers_hub_download': 'Indir',
      'drivers_hub_driver_activated': 'Surucu aktif edildi.',
      'drivers_hub_driver_deleted': 'Surucu silindi.',
      'drivers_hub_driver_email': 'Surucu e-postasi',
      'drivers_hub_driver_line': 'Surucu: {name}',
      'drivers_hub_driver_login_created': 'Surucu girisi olusturuldu',
      'drivers_hub_driver_login_saved': 'Surucu girisi basariyla kaydedildi.',
      'drivers_hub_driver_name': 'Surucu adi',
      'drivers_hub_driver_saved': '"{name}" surucusu kaydedildi.',
      'drivers_hub_driver_suspended': 'Surucu askiya alindi.',
      'drivers_hub_driving_licence_front_preview': 'Ehliyet (on yuz) onizleme',
      'drivers_hub_edit_label': '{label} duzenle',
      'drivers_hub_email': 'E-posta',
      'drivers_hub_email_optional': 'E-posta (opsiyonel)',
      'drivers_hub_expiry_contract': 'Sozlesme',
      'drivers_hub_expiry_driving_license': 'Ehliyet',
      'drivers_hub_expiry_id_passport': 'Kimlik / Pasaport',
      'drivers_hub_expiry_items_expired': '{items} suresi doldu',
      'drivers_hub_expiry_items_expiring_soon': '{items} yakinda dolacak',
      'drivers_hub_expiry_probezeit': 'Deneme suresi',
      'drivers_hub_expiry_work_permit': 'Calisma izni',
      'drivers_hub_export_pdf': 'PDF disa aktar',
      'drivers_hub_failed_create_logins': 'Giris olusturma basarisiz: {error}',
      'drivers_hub_failed_delete_document': 'Belge silme basarisiz: {error}',
      'drivers_hub_failed_load_pdf_preview': 'PDF onizlemesi yuklenemedi.',
      'drivers_hub_failed_save_default_password':
          'Varsayilan sifre kaydedilemedi: {error}',
      'drivers_hub_failed_set_login': 'Giris ayarlanamadi: {error}',
      'drivers_hub_failed_update_label': '{label} guncellenemedi: {error}',
      'drivers_hub_failed_upload_document': 'Belge yukleme basarisiz: {error}',
      'drivers_hub_field_city': 'Sehir',
      'drivers_hub_field_city_of_birth': 'Dogum sehri',
      'drivers_hub_field_contract_expiry': 'Sozlesme bitis',
      'drivers_hub_field_country': 'Ulke',
      'drivers_hub_field_date_of_birth': 'Dogum tarihi',
      'drivers_hub_field_driving_license_number': 'Ehliyet numarasi',
      'drivers_hub_field_emergency_contact_name': 'Acil durum kisisi',
      'drivers_hub_field_emergency_contact_phone': 'Acil durum telefonu',
      'drivers_hub_field_full_name': 'Ad soyad',
      'drivers_hub_field_id_card_passport_expiry': 'Kimlik / pasaport bitis',
      'drivers_hub_field_insurance_company': 'Sigorta sirketi',
      'drivers_hub_field_license_expiry_date': 'Ehliyet bitis tarihi',
      'drivers_hub_field_name_at_birth': 'Dogumdaki ad',
      'drivers_hub_field_nationality_id_card': 'Uyruk (kimlik)',
      'drivers_hub_field_notes': 'Notlar',
      'drivers_hub_field_phone': 'Telefon',
      'drivers_hub_field_postal_code': 'Posta kodu',
      'drivers_hub_field_probezeit_end': 'Deneme suresi bitisi',
      'drivers_hub_field_shoe_size': 'Ayakkabi numarasi',
      'drivers_hub_field_state_of_birth': 'Dogum eyaleti',
      'drivers_hub_field_street_address': 'Sokak adresi',
      'drivers_hub_field_tshirt_size': 'Tisort bedeni',
      'drivers_hub_field_work_permit_expiry': 'Calisma izni bitis',
      'drivers_hub_field_work_start_date': 'Ise baslama tarihi',
      'drivers_hub_header_action': 'Islem',
      'drivers_hub_header_login': 'Giris',
      'drivers_hub_header_overall': 'Genel',
      'drivers_hub_header_profile': 'Profil',
      'drivers_hub_header_status': 'Durum',
      'drivers_hub_header_working': 'Aktif',
      'drivers_hub_hide_pin': 'PIN gizle',
      'drivers_hub_import_csv': 'CSV ice aktar',
      'drivers_hub_label_copied': '{label} kopyalandi',
      'drivers_hub_login_created': 'Giris olusturuldu',
      'drivers_hub_must_login_add_driver':
          'Surucu eklemek icin giris yapmalisiniz.',
      'drivers_hub_must_login_import_csv':
          'CSV ice aktarmak icin giris yapmalisiniz.',
      'drivers_hub_must_login_manage_logins':
          'Surucu girislerini yonetmek icin giris yapmalisiniz.',
      'drivers_hub_must_login_view_drivers':
          'Suruculeri gormek icin giris yapmalisiniz.',
      'drivers_hub_name_and_transporter_id_required':
          'Ad ve Transporter ID zorunludur.',
      'drivers_hub_no_drivers_for_dsp': 'Bu DSP icin surucu bulunamadi.',
      'drivers_hub_no_drivers_yet':
          'Henuz surucu yok.\nCSV ice aktar veya surucu el ile ekle.',
      'drivers_hub_no_login': 'Giris yok',
      'drivers_hub_not_set': 'Ayarli degil',
      'drivers_hub_not_uploaded': 'Yuklenmedi',
      'drivers_hub_notification_pin': 'Bildirim PIN',
      'drivers_hub_onboarding_completed': 'Onboarding tamamlandi',
      'drivers_hub_password': 'Sifre',
      'drivers_hub_passwords_must_match':
          'Sifreler ayni olmali ve bos olmamali.',
      'drivers_hub_pdf_driver_onboarding': 'Surucu onboarding',
      'drivers_hub_preview_not_available':
          'Bu dosya turu icin onizleme yok. Acmak icin indir.',
      'drivers_hub_preview_unavailable_image': 'Bu gorsel icin onizleme yok.',
      'drivers_hub_probezeit_expired': 'Deneme suresi doldu',
      'drivers_hub_probezeit_expiring_soon': 'Deneme suresi yakinda dolacak',
      'drivers_hub_replace_slot_hint':
          'Bu slot olusturulacak/degistirilecek: {slot}',
      'drivers_hub_search_name_or_email': 'Ad veya e-posta ile ara...',
      'drivers_hub_section_address': 'Adres',
      'drivers_hub_section_document_expiry_dates': 'Belge bitis tarihleri',
      'drivers_hub_section_driving_license': 'Ehliyet',
      'drivers_hub_section_emergency_contact': 'Acil durum iletisim',
      'drivers_hub_section_origin': 'Koken',
      'drivers_hub_section_other_notes': 'Diger notlar',
      'drivers_hub_section_payment_tax': 'Odeme ve vergi',
      'drivers_hub_section_personal_details': 'Kisisel bilgiler',
      'drivers_hub_section_uniform': 'Uniforma',
      'drivers_hub_set_driver_login': 'Surucu girisi ayarla',
      'drivers_hub_set_pin': 'PIN ayarla',
      'drivers_hub_show_pin': 'PIN goster',
      'drivers_hub_sort_id_asc': 'ID A-Z',
      'drivers_hub_sort_name_asc': 'Isim A-Z',
      'drivers_hub_sort_name_desc': 'Isim Z-A',
      'drivers_hub_sort_approved': 'Onaylandi',
      'drivers_hub_sort_newest': 'En yeni',
      'drivers_hub_sort_oldest': 'En eski',
      'drivers_hub_sort_pending': 'Beklemede',
      'drivers_hub_sort_rejected': 'Reddedildi',
      'drivers_hub_status_approved': 'Onaylandi',
      'drivers_hub_status_pending': 'Beklemede',
      'drivers_hub_status_rejected': 'Reddedildi',
      'drivers_hub_switch_off': 'Kapali',
      'drivers_hub_switch_on': 'Acik',
      'drivers_hub_title': 'Surucu Merkezi',
      'drivers_hub_tooltip_create_login': 'Giris olustur',
      'drivers_hub_tooltip_delete_driver': 'Surucuyu sil',
      'drivers_hub_tooltip_reset_login': 'Girisi sifirla',
      'drivers_hub_tooltip_view_details': 'Detaylari gor',
      'drivers_hub_transporter_id': 'Transporter ID',
      'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter ID (giris ID)',
      'drivers_hub_transporter_id_required': 'Transporter ID zorunludur.',
      'drivers_hub_upload_doc': 'Belge yukle',
      'drivers_hub_upload_driver_document': 'Surucu belgesi yukle',
      'drivers_hub_valid_driver_email_required':
          'Gecerli bir surucu e-postasi gerekli.',
    },
    'ru': {
      ..._driversHubSharedValues,
      'drivers_hub_add_driver': 'Добавить водителя',
      'drivers_hub_add_edit_driver': 'Добавить / изменить водителя',
      'drivers_hub_admin_tools': 'Инструменты администратора',
      'drivers_hub_change_pin': 'Изменить PIN',
      'drivers_hub_confirm_password': 'Подтвердить пароль',
      'drivers_hub_copy_label': 'Копировать {label}',
      'drivers_hub_could_not_launch_document_url':
          'Не удалось открыть URL документа',
      'drivers_hub_create_login_for_all': 'Создать вход для всех',
      'drivers_hub_create_logins_for_all_body':
          'Это создаст входы для всех водителей, у которых ещё нет входа,\nиспользуя пароль:\n\n{password}\n\nПродолжить?',
      'drivers_hub_create_logins_for_all_drivers':
          'Создать входы для всех водителей',
      'drivers_hub_created_logins_summary':
          'Создано входов для {created} водителей. Пропущено {skipped} (уже был вход или отсутствовал ID).',
      'drivers_hub_csv_import_failed': 'Ошибка импорта CSV водителей: {error}',
      'drivers_hub_csv_imported_for_dsp':
          'CSV водителей импортирован для вашего DSP ({file}).',
      'drivers_hub_default_driver_password': 'Пароль по умолчанию для водителя',
      'drivers_hub_default_password_cannot_be_empty':
          'Пароль по умолчанию не может быть пустым.',
      'drivers_hub_delete_document_body': 'Это удалит {document}.',
      'drivers_hub_delete_document_title': 'Удалить документ?',
      'drivers_hub_delete_driver_body':
          'Вы уверены, что хотите удалить водителя "{name}"?\nВодитель и его вход будут удалены.',
      'drivers_hub_delete_driver_title': 'Удалить водителя',
      'drivers_hub_delete_failed': 'Удаление не удалось: {error}',
      'drivers_hub_document_deleted': '{document} удален.',
      'drivers_hub_document_type': 'Тип документа',
      'drivers_hub_document_uploaded': '{document} загружен.',
      'drivers_hub_documents': 'Документы',
      'drivers_hub_documents_expired': '{count} документов просрочено',
      'drivers_hub_documents_expiring_soon':
          '{count} документов скоро истекают',
      'drivers_hub_download': 'Скачать',
      'drivers_hub_driver_activated': 'Водитель активирован.',
      'drivers_hub_driver_deleted': 'Водитель удален.',
      'drivers_hub_driver_email': 'Email водителя',
      'drivers_hub_driver_line': 'Водитель: {name}',
      'drivers_hub_driver_login_created': 'Вход водителя создан',
      'drivers_hub_driver_login_saved': 'Вход водителя успешно сохранен.',
      'drivers_hub_driver_name': 'Имя водителя',
      'drivers_hub_driver_saved': 'Водитель "{name}" сохранен.',
      'drivers_hub_driver_suspended': 'Водитель приостановлен.',
      'drivers_hub_driving_licence_front_preview':
          'Предпросмотр прав (лицевая сторона)',
      'drivers_hub_edit_label': 'Изменить {label}',
      'drivers_hub_email': 'Email',
      'drivers_hub_email_optional': 'Email (необязательно)',
      'drivers_hub_expiry_contract': 'Контракт',
      'drivers_hub_expiry_driving_license': 'Водительское удостоверение',
      'drivers_hub_expiry_id_passport': 'ID / Паспорт',
      'drivers_hub_expiry_items_expired': '{items} истекли',
      'drivers_hub_expiry_items_expiring_soon': '{items} скоро истекают',
      'drivers_hub_expiry_probezeit': 'Испытательный срок',
      'drivers_hub_expiry_work_permit': 'Разрешение на работу',
      'drivers_hub_export_pdf': 'Экспорт PDF',
      'drivers_hub_failed_create_logins': 'Не удалось создать входы: {error}',
      'drivers_hub_failed_delete_document':
          'Не удалось удалить документ: {error}',
      'drivers_hub_failed_load_pdf_preview':
          'Не удалось загрузить предпросмотр PDF.',
      'drivers_hub_failed_save_default_password':
          'Не удалось сохранить пароль по умолчанию: {error}',
      'drivers_hub_failed_set_login': 'Не удалось установить вход: {error}',
      'drivers_hub_failed_update_label': 'Не удалось обновить {label}: {error}',
      'drivers_hub_failed_upload_document':
          'Не удалось загрузить документ: {error}',
      'drivers_hub_field_city': 'Город',
      'drivers_hub_field_city_of_birth': 'Город рождения',
      'drivers_hub_field_contract_expiry': 'Срок контракта',
      'drivers_hub_field_country': 'Страна',
      'drivers_hub_field_date_of_birth': 'Дата рождения',
      'drivers_hub_field_driving_license_number': 'Номер прав',
      'drivers_hub_field_emergency_contact_name': 'Имя экстренного контакта',
      'drivers_hub_field_emergency_contact_phone':
          'Телефон экстренного контакта',
      'drivers_hub_field_full_name': 'Полное имя',
      'drivers_hub_field_id_card_passport_expiry': 'Срок ID / паспорта',
      'drivers_hub_field_insurance_company': 'Страховая компания',
      'drivers_hub_field_license_expiry_date': 'Срок действия прав',
      'drivers_hub_field_name_at_birth': 'Имя при рождении',
      'drivers_hub_field_nationality_id_card': 'Гражданство (ID)',
      'drivers_hub_field_notes': 'Заметки',
      'drivers_hub_field_phone': 'Телефон',
      'drivers_hub_field_postal_code': 'Почтовый индекс',
      'drivers_hub_field_probezeit_end': 'Окончание испытательного срока',
      'drivers_hub_field_shoe_size': 'Размер обуви',
      'drivers_hub_field_state_of_birth': 'Страна рождения',
      'drivers_hub_field_street_address': 'Адрес улицы',
      'drivers_hub_field_tshirt_size': 'Размер футболки',
      'drivers_hub_field_work_permit_expiry': 'Срок разрешения на работу',
      'drivers_hub_field_work_start_date': 'Дата начала работы',
      'drivers_hub_header_action': 'Действие',
      'drivers_hub_header_login': 'Вход',
      'drivers_hub_header_overall': 'Среднее',
      'drivers_hub_header_profile': 'Профиль',
      'drivers_hub_header_status': 'Статус',
      'drivers_hub_header_working': 'Активен',
      'drivers_hub_hide_pin': 'Скрыть PIN',
      'drivers_hub_import_csv': 'Импорт CSV',
      'drivers_hub_label_copied': '{label} скопировано',
      'drivers_hub_login_created': 'Вход создан',
      'drivers_hub_must_login_add_driver':
          'Вы должны войти, чтобы добавлять водителей.',
      'drivers_hub_must_login_import_csv':
          'Вы должны войти, чтобы импортировать CSV.',
      'drivers_hub_must_login_manage_logins':
          'Вы должны войти, чтобы управлять входами водителей.',
      'drivers_hub_must_login_view_drivers':
          'Вы должны войти, чтобы видеть водителей.',
      'drivers_hub_name_and_transporter_id_required':
          'Имя и Transporter ID обязательны.',
      'drivers_hub_no_drivers_for_dsp': 'Для этого DSP водители не найдены.',
      'drivers_hub_no_drivers_yet':
          'Пока нет водителей.\nИмпортируйте CSV или добавьте водителя вручную.',
      'drivers_hub_no_login': 'Нет входа',
      'drivers_hub_not_set': 'Не задано',
      'drivers_hub_not_uploaded': 'Не загружено',
      'drivers_hub_notification_pin': 'PIN уведомлений',
      'drivers_hub_onboarding_completed': 'Онбординг завершен',
      'drivers_hub_password': 'Пароль',
      'drivers_hub_passwords_must_match':
          'Пароли должны совпадать и не быть пустыми.',
      'drivers_hub_pdf_driver_onboarding': 'Онбординг водителя',
      'drivers_hub_preview_not_available':
          'Предпросмотр недоступен для этого типа файла. Используйте загрузку.',
      'drivers_hub_preview_unavailable_image':
          'Предпросмотр изображения недоступен.',
      'drivers_hub_probezeit_expired': 'Испытательный срок истек',
      'drivers_hub_probezeit_expiring_soon':
          'Испытательный срок скоро истекает',
      'drivers_hub_replace_slot_hint': 'Этот слот будет создан/заменен: {slot}',
      'drivers_hub_search_name_or_email': 'Поиск по имени или email...',
      'drivers_hub_section_address': 'Адрес',
      'drivers_hub_section_document_expiry_dates': 'Сроки действия документов',
      'drivers_hub_section_driving_license': 'Водительское удостоверение',
      'drivers_hub_section_emergency_contact': 'Экстренный контакт',
      'drivers_hub_section_origin': 'Происхождение',
      'drivers_hub_section_other_notes': 'Другие заметки',
      'drivers_hub_section_payment_tax': 'Оплата и налоги',
      'drivers_hub_section_personal_details': 'Личные данные',
      'drivers_hub_section_uniform': 'Униформа',
      'drivers_hub_set_driver_login': 'Настроить вход водителя',
      'drivers_hub_set_pin': 'Установить PIN',
      'drivers_hub_show_pin': 'Показать PIN',
      'drivers_hub_sort_id_asc': 'ID A-Z',
      'drivers_hub_sort_name_asc': 'Имя A-Z',
      'drivers_hub_sort_name_desc': 'Имя Z-A',
      'drivers_hub_sort_approved': 'Одобрен',
      'drivers_hub_sort_newest': 'Новые',
      'drivers_hub_sort_oldest': 'Старые',
      'drivers_hub_sort_pending': 'В ожидании',
      'drivers_hub_sort_rejected': 'Отклонен',
      'drivers_hub_status_approved': 'Одобрен',
      'drivers_hub_status_pending': 'В ожидании',
      'drivers_hub_status_rejected': 'Отклонен',
      'drivers_hub_switch_off': 'Выкл',
      'drivers_hub_switch_on': 'Вкл',
      'drivers_hub_title': 'Центр водителей',
      'drivers_hub_tooltip_create_login': 'Создать вход',
      'drivers_hub_tooltip_delete_driver': 'Удалить водителя',
      'drivers_hub_tooltip_reset_login': 'Сбросить вход',
      'drivers_hub_tooltip_view_details': 'Просмотр деталей',
      'drivers_hub_transporter_id': 'Transporter ID',
      'drivers_hub_transporter_id_line': 'Transporter ID: {id}',
      'drivers_hub_transporter_id_login': 'Transporter ID (ID входа)',
      'drivers_hub_transporter_id_required': 'Transporter ID обязателен.',
      'drivers_hub_upload_doc': 'Загрузить документ',
      'drivers_hub_upload_driver_document': 'Загрузить документ водителя',
      'drivers_hub_valid_driver_email_required':
          'Требуется корректный email водителя.',
    },
  };

  static final Map<String, String> _adminFaqSharedValues = {
    'admin_faq_locale_title': 'Language: {code}',
    'admin_faq_question_label': 'Question',
    'admin_faq_answer_label': 'Answer',
    'admin_faq_error_auto_translate': 'Auto-translation failed: {error}',
    'admin_faq_translate_all_languages': 'Translate all languages',
    'admin_faq_translate_done': 'Translated {count} fields.',
    'admin_faq_translate_none': 'No new translations were generated.',
    'admin_faq_add_title': 'Add custom FAQ',
    'admin_faq_edit_title': 'Edit custom FAQ',
    'admin_faq_insert_after': 'Insert after',
    'admin_faq_cancel': 'Cancel',
    'admin_faq_save': 'Save',
    'admin_faq_error_save': 'Failed to save FAQ: {error}',
    'admin_faq_edit_localized_title': 'Edit localized FAQ',
    'admin_faq_leave_empty_hint':
        'Leave fields empty to use the default app question/answer.',
    'admin_faq_error_save_localized': 'Failed to save localized FAQ: {error}',
    'admin_faq_insert_top': 'Top (first)',
    'admin_faq_insert_end': 'End (last)',
    'admin_faq_delete_title': 'Delete FAQ?',
    'admin_faq_delete_body': 'This FAQ will be permanently deleted.',
    'admin_faq_delete': 'Delete',
    'admin_faq_error_delete': 'Failed to delete FAQ: {error}',
    'admin_faq_no_custom': 'No custom FAQs yet.',
    'admin_faq_untitled': 'Untitled question',
    'admin_faq_no_answer': 'No answer',
    'admin_faq_edit': 'Edit',
    'admin_faq_must_login': 'You must be logged in.',
    'admin_faq_hide': 'Hide',
    'admin_faq_error_update_visibility': 'Failed to update visibility: {error}',
    'admin_faq_page_title': 'FAQs',
    'admin_faq_add_custom': 'Add custom FAQ',
    'admin_faq_section_localized_title': 'Default FAQs (localized overrides)',
    'admin_faq_section_localized_subtitle':
        'Edit per-language text for built-in FAQ questions, or hide them.',
    'admin_faq_section_custom_title': 'Custom FAQs',
    'admin_faq_section_custom_subtitle':
        'Create your own FAQ questions visible to all drivers.',
  };

  static final Map<String, Map<String, String>> _adminFaqLocalizedValues = {
    'en': _adminFaqSharedValues,
    'de': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'Sprache: {code}',
      'admin_faq_question_label': 'Frage',
      'admin_faq_answer_label': 'Antwort',
      'admin_faq_error_auto_translate':
          'Automatische Uebersetzung fehlgeschlagen: {error}',
      'admin_faq_translate_all_languages': 'Alle Sprachen uebersetzen',
      'admin_faq_translate_done': '{count} Felder wurden uebersetzt.',
      'admin_faq_translate_none': 'Es wurden keine neuen Uebersetzungen erstellt.',
      'admin_faq_add_title': 'Benutzerdefinierte FAQ hinzufuegen',
      'admin_faq_edit_title': 'Benutzerdefinierte FAQ bearbeiten',
      'admin_faq_insert_after': 'Einfuegen nach',
      'admin_faq_cancel': 'Abbrechen',
      'admin_faq_save': 'Speichern',
      'admin_faq_error_save': 'FAQ konnte nicht gespeichert werden: {error}',
      'admin_faq_edit_localized_title': 'Lokalisierte FAQ bearbeiten',
      'admin_faq_leave_empty_hint':
          'Leer lassen, um die Standardfrage/-antwort zu verwenden.',
      'admin_faq_error_save_localized':
          'Lokalisierte FAQ konnte nicht gespeichert werden: {error}',
      'admin_faq_insert_top': 'Ganz oben',
      'admin_faq_insert_end': 'Am Ende',
      'admin_faq_delete_title': 'FAQ loeschen?',
      'admin_faq_delete_body': 'Diese FAQ wird dauerhaft geloescht.',
      'admin_faq_delete': 'Loeschen',
      'admin_faq_error_delete': 'FAQ konnte nicht geloescht werden: {error}',
      'admin_faq_no_custom': 'Noch keine benutzerdefinierten FAQs.',
      'admin_faq_untitled': 'Frage ohne Titel',
      'admin_faq_no_answer': 'Keine Antwort',
      'admin_faq_edit': 'Bearbeiten',
      'admin_faq_must_login': 'Du musst eingeloggt sein.',
      'admin_faq_hide': 'Ausblenden',
      'admin_faq_error_update_visibility':
          'Sichtbarkeit konnte nicht aktualisiert werden: {error}',
      'admin_faq_page_title': 'FAQs',
      'admin_faq_add_custom': 'Benutzerdefinierte FAQ',
      'admin_faq_section_localized_title':
          'Standard-FAQs (lokalisierte Ueberschreibungen)',
      'admin_faq_section_localized_subtitle':
          'Bearbeite den Text pro Sprache fuer integrierte FAQ-Fragen oder blende sie aus.',
      'admin_faq_section_custom_title': 'Benutzerdefinierte FAQs',
      'admin_faq_section_custom_subtitle':
          'Erstelle eigene FAQ-Fragen, die alle Fahrer sehen koennen.',
    },
    'sq': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'Gjuha: {code}',
      'admin_faq_question_label': 'Pyetja',
      'admin_faq_answer_label': 'Pergjigjja',
      'admin_faq_error_auto_translate': 'Perkthimi automatik deshtoi: {error}',
      'admin_faq_translate_all_languages': 'Perkthe te gjitha gjuhet',
      'admin_faq_translate_done': 'U perkthyen {count} fusha.',
      'admin_faq_translate_none': 'Nuk u gjeneruan perkthime te reja.',
      'admin_faq_add_title': 'Shto FAQ te personalizuar',
      'admin_faq_edit_title': 'Ndrysho FAQ te personalizuar',
      'admin_faq_insert_after': 'Vendos pas',
      'admin_faq_cancel': 'Anulo',
      'admin_faq_save': 'Ruaj',
      'admin_faq_error_save': 'Ruajtja e FAQ deshtoi: {error}',
      'admin_faq_edit_localized_title': 'Ndrysho FAQ te lokalizuar',
      'admin_faq_leave_empty_hint':
          'Lere bosh per te perdorur pyetjen/pergjigjjen default te aplikacionit.',
      'admin_faq_error_save_localized':
          'Ruajtja e FAQ te lokalizuar deshtoi: {error}',
      'admin_faq_insert_top': 'Ne krye',
      'admin_faq_insert_end': 'Ne fund',
      'admin_faq_delete_title': 'Te fshihet FAQ?',
      'admin_faq_delete_body': 'Kjo FAQ do te fshihet pergjithmone.',
      'admin_faq_delete': 'Fshi',
      'admin_faq_error_delete': 'Fshirja e FAQ deshtoi: {error}',
      'admin_faq_no_custom': 'Nuk ka ende FAQ te personalizuara.',
      'admin_faq_untitled': 'Pyetje pa titull',
      'admin_faq_no_answer': 'Pa pergjigjje',
      'admin_faq_edit': 'Ndrysho',
      'admin_faq_must_login': 'Duhet te jesh i kycur.',
      'admin_faq_hide': 'Fshih',
      'admin_faq_error_update_visibility':
          'Perditesimi i shikueshmerise deshtoi: {error}',
      'admin_faq_page_title': 'FAQ',
      'admin_faq_add_custom': 'Shto FAQ te personalizuar',
      'admin_faq_section_localized_title':
          'FAQ default (mbishkrime te lokalizuara)',
      'admin_faq_section_localized_subtitle':
          'Ndrysho tekstin per gjuhe per pyetjet standarde te FAQ ose fshihi ato.',
      'admin_faq_section_custom_title': 'FAQ te personalizuara',
      'admin_faq_section_custom_subtitle':
          'Krijo pyetje-pergjigjje te tuat qe i shohin te gjithe shoferet.',
    },
    'hu': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'Nyelv: {code}',
      'admin_faq_question_label': 'Kerdes',
      'admin_faq_answer_label': 'Valasz',
      'admin_faq_error_auto_translate':
          'Automatikus forditas sikertelen: {error}',
      'admin_faq_translate_all_languages': 'Forditas minden nyelvre',
      'admin_faq_translate_done': '{count} mezo leforditva.',
      'admin_faq_translate_none': 'Nem keszult uj forditas.',
      'admin_faq_add_title': 'Egyedi GYIK hozzaadasa',
      'admin_faq_edit_title': 'Egyedi GYIK szerkesztese',
      'admin_faq_insert_after': 'Beszuras ez utan',
      'admin_faq_cancel': 'Megse',
      'admin_faq_save': 'Mentes',
      'admin_faq_error_save': 'Nem sikerult menteni a GYIK-et: {error}',
      'admin_faq_edit_localized_title': 'Lokalizalt GYIK szerkesztese',
      'admin_faq_leave_empty_hint':
          'Hagyd uresen az alkalmazas alapertelmezett kerdes/valasz hasznalatahoz.',
      'admin_faq_error_save_localized':
          'Nem sikerult menteni a lokalizalt GYIK-et: {error}',
      'admin_faq_insert_top': 'Legfelul',
      'admin_faq_insert_end': 'Legvegen',
      'admin_faq_delete_title': 'Torli a GYIK-et?',
      'admin_faq_delete_body': 'Ez a GYIK veglegesen torlodik.',
      'admin_faq_delete': 'Torles',
      'admin_faq_error_delete': 'A GYIK torlese sikertelen: {error}',
      'admin_faq_no_custom': 'Meg nincsenek egyedi GYIK-ek.',
      'admin_faq_untitled': 'Cim nelkuli kerdes',
      'admin_faq_no_answer': 'Nincs valasz',
      'admin_faq_edit': 'Szerkesztes',
      'admin_faq_must_login': 'Be kell jelentkezned.',
      'admin_faq_hide': 'Elrejt',
      'admin_faq_error_update_visibility':
          'A lathatosag frissitese sikertelen: {error}',
      'admin_faq_page_title': 'GYIK',
      'admin_faq_add_custom': 'Egyedi GYIK hozzaadasa',
      'admin_faq_section_localized_title':
          'Alapertelmezett GYIK-ek (lokalizalt felulirasok)',
      'admin_faq_section_localized_subtitle':
          'Nyelvenkent szerkesztheted a beepitett GYIK szoveget, vagy elrejtheted.',
      'admin_faq_section_custom_title': 'Egyedi GYIK-ek',
      'admin_faq_section_custom_subtitle':
          'Sajat kerdes-valasz elemek letrehozasa minden sofor szamara.',
    },
    'ro': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'Limba: {code}',
      'admin_faq_question_label': 'Intrebare',
      'admin_faq_answer_label': 'Raspuns',
      'admin_faq_error_auto_translate': 'Traducerea automata a esuat: {error}',
      'admin_faq_translate_all_languages': 'Tradu toate limbile',
      'admin_faq_translate_done': 'Au fost traduse {count} campuri.',
      'admin_faq_translate_none': 'Nu au fost generate traduceri noi.',
      'admin_faq_add_title': 'Adauga FAQ personalizat',
      'admin_faq_edit_title': 'Editeaza FAQ personalizat',
      'admin_faq_insert_after': 'Insereaza dupa',
      'admin_faq_cancel': 'Anuleaza',
      'admin_faq_save': 'Salveaza',
      'admin_faq_error_save': 'Nu s-a putut salva FAQ-ul: {error}',
      'admin_faq_edit_localized_title': 'Editeaza FAQ localizat',
      'admin_faq_leave_empty_hint':
          'Lasa gol pentru a folosi intrebarea/raspunsul implicit din aplicatie.',
      'admin_faq_error_save_localized':
          'Nu s-a putut salva FAQ-ul localizat: {error}',
      'admin_faq_insert_top': 'Sus (primul)',
      'admin_faq_insert_end': 'Jos (ultimul)',
      'admin_faq_delete_title': 'Stergi FAQ-ul?',
      'admin_faq_delete_body': 'Acest FAQ va fi sters definitiv.',
      'admin_faq_delete': 'Sterge',
      'admin_faq_error_delete': 'Nu s-a putut sterge FAQ-ul: {error}',
      'admin_faq_no_custom': 'Nu exista inca FAQ-uri personalizate.',
      'admin_faq_untitled': 'Intrebare fara titlu',
      'admin_faq_no_answer': 'Fara raspuns',
      'admin_faq_edit': 'Editeaza',
      'admin_faq_must_login': 'Trebuie sa fii autentificat.',
      'admin_faq_hide': 'Ascunde',
      'admin_faq_error_update_visibility':
          'Nu s-a putut actualiza vizibilitatea: {error}',
      'admin_faq_page_title': 'FAQ',
      'admin_faq_add_custom': 'Adauga FAQ personalizat',
      'admin_faq_section_localized_title':
          'FAQ implicite (suprascrieri localizate)',
      'admin_faq_section_localized_subtitle':
          'Editeaza textul pe limbi pentru intrebarile FAQ implicite sau ascunde-le.',
      'admin_faq_section_custom_title': 'FAQ personalizate',
      'admin_faq_section_custom_subtitle':
          'Creeaza intrebarile si raspunsurile tale pentru toti soferii.',
    },
    'hr': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'Jezik: {code}',
      'admin_faq_question_label': 'Pitanje',
      'admin_faq_answer_label': 'Odgovor',
      'admin_faq_error_auto_translate':
          'Automatski prijevod nije uspio: {error}',
      'admin_faq_translate_all_languages': 'Prevedi sve jezike',
      'admin_faq_translate_done': 'Prevedeno je {count} polja.',
      'admin_faq_translate_none': 'Nisu generirani novi prijevodi.',
      'admin_faq_add_title': 'Dodaj prilagodeni FAQ',
      'admin_faq_edit_title': 'Uredi prilagodeni FAQ',
      'admin_faq_insert_after': 'Umetni nakon',
      'admin_faq_cancel': 'Odustani',
      'admin_faq_save': 'Spremi',
      'admin_faq_error_save': 'Spremanje FAQ-a nije uspjelo: {error}',
      'admin_faq_edit_localized_title': 'Uredi lokalizirani FAQ',
      'admin_faq_leave_empty_hint':
          'Ostavi prazno za koristenje zadanog pitanja/odgovora aplikacije.',
      'admin_faq_error_save_localized':
          'Spremanje lokaliziranog FAQ-a nije uspjelo: {error}',
      'admin_faq_insert_top': 'Na vrh',
      'admin_faq_insert_end': 'Na kraj',
      'admin_faq_delete_title': 'Obrisati FAQ?',
      'admin_faq_delete_body': 'Ovaj FAQ ce biti trajno obrisan.',
      'admin_faq_delete': 'Obrisi',
      'admin_faq_error_delete': 'Brisanje FAQ-a nije uspjelo: {error}',
      'admin_faq_no_custom': 'Jos nema prilagodenih FAQ-ova.',
      'admin_faq_untitled': 'Pitanje bez naslova',
      'admin_faq_no_answer': 'Bez odgovora',
      'admin_faq_edit': 'Uredi',
      'admin_faq_must_login': 'Morate biti prijavljeni.',
      'admin_faq_hide': 'Sakrij',
      'admin_faq_error_update_visibility':
          'Azuriranje vidljivosti nije uspjelo: {error}',
      'admin_faq_page_title': 'FAQ',
      'admin_faq_add_custom': 'Dodaj prilagodeni FAQ',
      'admin_faq_section_localized_title':
          'Zadani FAQ-ovi (lokalizirane izmjene)',
      'admin_faq_section_localized_subtitle':
          'Uredi tekst po jeziku za ugradena FAQ pitanja ili ih sakrij.',
      'admin_faq_section_custom_title': 'Prilagodeni FAQ-ovi',
      'admin_faq_section_custom_subtitle':
          'Kreiraj vlastita FAQ pitanja i odgovore za sve vozace.',
    },
    'ar': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'اللغة: {code}',
      'admin_faq_question_label': 'السؤال',
      'admin_faq_answer_label': 'الإجابة',
      'admin_faq_error_auto_translate': 'فشلت الترجمة التلقائية: {error}',
      'admin_faq_translate_all_languages': 'ترجمة جميع اللغات',
      'admin_faq_translate_done': 'تمت ترجمة {count} حقول.',
      'admin_faq_translate_none': 'لم يتم إنشاء ترجمات جديدة.',
      'admin_faq_add_title': 'إضافة سؤال شائع مخصص',
      'admin_faq_edit_title': 'تعديل سؤال شائع مخصص',
      'admin_faq_insert_after': 'إدراج بعد',
      'admin_faq_cancel': 'إلغاء',
      'admin_faq_save': 'حفظ',
      'admin_faq_error_save': 'فشل حفظ السؤال الشائع: {error}',
      'admin_faq_edit_localized_title': 'تعديل السؤال الشائع المترجم',
      'admin_faq_leave_empty_hint':
          'اترك الحقول فارغة لاستخدام السؤال/الإجابة الافتراضيين في التطبيق.',
      'admin_faq_error_save_localized':
          'فشل حفظ السؤال الشائع المترجم: {error}',
      'admin_faq_insert_top': 'الأعلى',
      'admin_faq_insert_end': 'النهاية',
      'admin_faq_delete_title': 'حذف السؤال الشائع؟',
      'admin_faq_delete_body': 'سيتم حذف هذا السؤال الشائع نهائيا.',
      'admin_faq_delete': 'حذف',
      'admin_faq_error_delete': 'فشل حذف السؤال الشائع: {error}',
      'admin_faq_no_custom': 'لا توجد أسئلة شائعة مخصصة بعد.',
      'admin_faq_untitled': 'سؤال بدون عنوان',
      'admin_faq_no_answer': 'لا توجد إجابة',
      'admin_faq_edit': 'تعديل',
      'admin_faq_must_login': 'يجب تسجيل الدخول.',
      'admin_faq_hide': 'إخفاء',
      'admin_faq_error_update_visibility': 'فشل تحديث الرؤية: {error}',
      'admin_faq_page_title': 'الأسئلة الشائعة',
      'admin_faq_add_custom': 'إضافة سؤال شائع مخصص',
      'admin_faq_section_localized_title':
          'الأسئلة الشائعة الافتراضية (تخصيصات الترجمة)',
      'admin_faq_section_localized_subtitle':
          'عدّل النص لكل لغة في الأسئلة المدمجة أو أخفها.',
      'admin_faq_section_custom_title': 'الأسئلة الشائعة المخصصة',
      'admin_faq_section_custom_subtitle':
          'أنشئ أسئلتك وإجاباتك الخاصة لتظهر لجميع السائقين.',
    },
    'tr': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'Dil: {code}',
      'admin_faq_question_label': 'Soru',
      'admin_faq_answer_label': 'Cevap',
      'admin_faq_error_auto_translate': 'Otomatik ceviri basarisiz: {error}',
      'admin_faq_translate_all_languages': 'Tum dilleri cevir',
      'admin_faq_translate_done': '{count} alan cevrildi.',
      'admin_faq_translate_none': 'Yeni ceviri uretilmedi.',
      'admin_faq_add_title': 'Ozel SSS ekle',
      'admin_faq_edit_title': 'Ozel SSS duzenle',
      'admin_faq_insert_after': 'Sonrasina ekle',
      'admin_faq_cancel': 'Iptal',
      'admin_faq_save': 'Kaydet',
      'admin_faq_error_save': 'SSS kaydedilemedi: {error}',
      'admin_faq_edit_localized_title': 'Yerellestirilmis SSS duzenle',
      'admin_faq_leave_empty_hint':
          'Uygulamanin varsayilan soru/cevabini kullanmak icin bos birakin.',
      'admin_faq_error_save_localized':
          'Yerellestirilmis SSS kaydedilemedi: {error}',
      'admin_faq_insert_top': 'En ust',
      'admin_faq_insert_end': 'En alt',
      'admin_faq_delete_title': 'SSS silinsin mi?',
      'admin_faq_delete_body': 'Bu SSS kalici olarak silinecek.',
      'admin_faq_delete': 'Sil',
      'admin_faq_error_delete': 'SSS silinemedi: {error}',
      'admin_faq_no_custom': 'Henuz ozel SSS yok.',
      'admin_faq_untitled': 'Basliksiz soru',
      'admin_faq_no_answer': 'Cevap yok',
      'admin_faq_edit': 'Duzenle',
      'admin_faq_must_login': 'Giris yapmaniz gerekiyor.',
      'admin_faq_hide': 'Gizle',
      'admin_faq_error_update_visibility': 'Gorunurluk guncellenemedi: {error}',
      'admin_faq_page_title': 'SSS',
      'admin_faq_add_custom': 'Ozel SSS ekle',
      'admin_faq_section_localized_title':
          'Varsayilan SSS (yerellestirilmis gecersiz kilmalar)',
      'admin_faq_section_localized_subtitle':
          'Yerlesik SSS sorularinin metnini dile gore duzenleyin veya gizleyin.',
      'admin_faq_section_custom_title': 'Ozel SSS',
      'admin_faq_section_custom_subtitle':
          'Tum suruculerin gorecegi kendi soru-cevaplarinizi olusturun.',
    },
    'ru': {
      ..._adminFaqSharedValues,
      'admin_faq_locale_title': 'Язык: {code}',
      'admin_faq_question_label': 'Вопрос',
      'admin_faq_answer_label': 'Ответ',
      'admin_faq_error_auto_translate': 'Ошибка авто-перевода: {error}',
      'admin_faq_translate_all_languages': 'Перевести на все языки',
      'admin_faq_translate_done': 'Переведено полей: {count}.',
      'admin_faq_translate_none': 'Новые переводы не были созданы.',
      'admin_faq_add_title': 'Добавить пользовательский FAQ',
      'admin_faq_edit_title': 'Редактировать пользовательский FAQ',
      'admin_faq_insert_after': 'Вставить после',
      'admin_faq_cancel': 'Отмена',
      'admin_faq_save': 'Сохранить',
      'admin_faq_error_save': 'Не удалось сохранить FAQ: {error}',
      'admin_faq_edit_localized_title': 'Редактировать локализованный FAQ',
      'admin_faq_leave_empty_hint':
          'Оставьте поля пустыми, чтобы использовать вопрос/ответ по умолчанию.',
      'admin_faq_error_save_localized':
          'Не удалось сохранить локализованный FAQ: {error}',
      'admin_faq_insert_top': 'В начало',
      'admin_faq_insert_end': 'В конец',
      'admin_faq_delete_title': 'Удалить FAQ?',
      'admin_faq_delete_body': 'Этот FAQ будет удален навсегда.',
      'admin_faq_delete': 'Удалить',
      'admin_faq_error_delete': 'Не удалось удалить FAQ: {error}',
      'admin_faq_no_custom': 'Пользовательских FAQ пока нет.',
      'admin_faq_untitled': 'Вопрос без названия',
      'admin_faq_no_answer': 'Нет ответа',
      'admin_faq_edit': 'Редактировать',
      'admin_faq_must_login': 'Необходимо войти в систему.',
      'admin_faq_hide': 'Скрыть',
      'admin_faq_error_update_visibility':
          'Не удалось обновить видимость: {error}',
      'admin_faq_page_title': 'FAQ',
      'admin_faq_add_custom': 'Добавить пользовательский FAQ',
      'admin_faq_section_localized_title':
          'Стандартные FAQ (локализованные изменения)',
      'admin_faq_section_localized_subtitle':
          'Редактируйте встроенные FAQ по языкам или скрывайте их.',
      'admin_faq_section_custom_title': 'Пользовательские FAQ',
      'admin_faq_section_custom_subtitle':
          'Создавайте свои вопросы и ответы для всех водителей.',
    },
  };

  static final Map<String, String> _adminApprovalsSharedValues = {
    'admin_approvals_error_loading':
        'Failed to load pending approvals: {error}',
    'admin_approvals_no_pending': 'No pending approvals.',
    'admin_approvals_no_name': '(No name)',
    'admin_approvals_delete': 'Delete',
    'admin_approvals_approve': 'Approve',
  };

  static final Map<String, Map<String, String>> _adminApprovalsLocalizedValues =
      {
        'en': _adminApprovalsSharedValues,
        'de': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'Ausstehende Freigaben konnten nicht geladen werden: {error}',
          'admin_approvals_no_pending': 'Keine ausstehenden Freigaben.',
          'admin_approvals_no_name': '(Kein Name)',
          'admin_approvals_delete': 'Loeschen',
          'admin_approvals_approve': 'Freigeben',
        },
        'sq': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'Nuk u ngarkuan aprovimet ne pritje: {error}',
          'admin_approvals_no_pending': 'Nuk ka aprovime ne pritje.',
          'admin_approvals_no_name': '(Pa emer)',
          'admin_approvals_delete': 'Fshi',
          'admin_approvals_approve': 'Aprovo',
        },
        'hu': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'A jovahagyasra varo elemek betoltese sikertelen: {error}',
          'admin_approvals_no_pending': 'Nincs fuggoben levo jovahagyas.',
          'admin_approvals_no_name': '(Nincs nev)',
          'admin_approvals_delete': 'Torles',
          'admin_approvals_approve': 'Jovahagy',
        },
        'ro': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'Nu s-au putut incarca aprobarile in asteptare: {error}',
          'admin_approvals_no_pending': 'Nu exista aprobari in asteptare.',
          'admin_approvals_no_name': '(Fara nume)',
          'admin_approvals_delete': 'Sterge',
          'admin_approvals_approve': 'Aproba',
        },
        'hr': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'Ucavanje zahtjeva za odobrenje nije uspjelo: {error}',
          'admin_approvals_no_pending': 'Nema zahtjeva na cekanju.',
          'admin_approvals_no_name': '(Bez imena)',
          'admin_approvals_delete': 'Obrisi',
          'admin_approvals_approve': 'Odobri',
        },
        'ar': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'فشل تحميل طلبات الموافقة المعلقة: {error}',
          'admin_approvals_no_pending': 'لا توجد طلبات موافقة معلقة.',
          'admin_approvals_no_name': '(بدون اسم)',
          'admin_approvals_delete': 'حذف',
          'admin_approvals_approve': 'موافقة',
        },
        'tr': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'Bekleyen onaylar yuklenemedi: {error}',
          'admin_approvals_no_pending': 'Bekleyen onay yok.',
          'admin_approvals_no_name': '(Isim yok)',
          'admin_approvals_delete': 'Sil',
          'admin_approvals_approve': 'Onayla',
        },
        'ru': {
          ..._adminApprovalsSharedValues,
          'admin_approvals_error_loading':
              'Не удалось загрузить ожидающие одобрения: {error}',
          'admin_approvals_no_pending': 'Нет ожидающих одобрения.',
          'admin_approvals_no_name': '(Без имени)',
          'admin_approvals_delete': 'Удалить',
          'admin_approvals_approve': 'Одобрить',
        },
      };

  static final Map<String, String> _miscSharedValues = {
    'button_close': 'Close',
    'button_open': 'Open',
    'button_delete': 'Delete',
    'button_reload': 'Reload',
    'button_add': 'Add',
    'button_edit': 'Edit',
    'button_sign_out': 'Sign out',
    'verify_email_sent': 'Verification email sent.',
    'verify_email_title': 'Verify your email',
    'verify_email_intro': 'We sent a verification link to:',
    'verify_email_sending': 'Sending...',
    'verify_email_resend': 'Resend verification email',
    'verify_email_reload': 'I verified - Reload',
    'verify_email_back_to_login': 'Back to login',
    'verify_email_failed_template': 'Failed to resend verification email: {error}',
    'driver_shift_plan_missing_scope': 'Missing DSP or driver scope.',
    'driver_shift_plan_title': 'Shift Plan',
    'driver_shift_plan_load_failed_template': 'Failed to load shifts: {error}',
    'driver_shift_plan_empty': 'No shifts assigned yet.',
    'driver_shift_plan_upcoming': 'Upcoming shifts',
    'driver_shift_plan_upcoming_empty': 'No upcoming shifts.',
    'driver_shift_plan_past': 'Past shifts',
    'driver_shift_plan_past_empty': 'No past shifts.',
    'driver_shift_plan_status_scheduled': 'Scheduled',
    'driver_rules_error_template': 'Error: {error}',
    'driver_rules_empty': 'No rules yet.',
    'driver_notifications_filter_all': 'All',
    'driver_notifications_filter_rule': 'Rule',
    'driver_notifications_filter_academy': 'DA Academy',
    'driver_notifications_filter_message': 'Message',
    'driver_notifications_filter_ride_along': 'Ride Along',
    'driver_notifications_error_template': 'Error: {error}',
    'driver_notifications_empty': 'No notifications yet.',
    'driver_notifications_filter_empty': 'No notifications for this filter.',
    'auth_gate_driver_profile_error_template':
        'Error loading driver profile: {error}',
    'auth_gate_no_profile_found':
        'Your login is active, but no driver/DSP profile could be found.',
    'auth_gate_contact_admin': 'Please contact your DSP or admin.',
    'auth_gate_awaiting_approval_title': 'Your DSP account is awaiting approval.',
    'auth_gate_awaiting_approval_body':
        'Once an admin approves your account, you can access the dashboard.',
    'auth_gate_awaiting_approval_tab_hint':
        'You can close this tab; we will allow access after approval.',
    'notification_pin_close_tooltip': 'Close',
    'driver_onboarding_save_failed_template': 'Failed to save: {error}',
    'driver_onboarding_document_uploaded_template': '{document} uploaded.',
    'driver_onboarding_upload_documents_failed_template':
        'Failed to upload documents: {error}',
    'driver_onboarding_open_document_tooltip': 'Open',
    'driver_onboarding_delete_document_tooltip': 'Delete',
    'driver_onboarding_open_document_failed': 'Could not open document URL',
    'driver_onboarding_document_deleted': 'Document deleted.',
    'driver_onboarding_delete_document_failed_template':
        'Failed to delete document: {error}',
    'signup_request_title': 'Apply for Account',
    'signup_request_success':
        'Verification email sent. Verify, then wait for approval.',
    'signup_request_full_name': 'Full name',
    'signup_request_email': 'Email',
    'signup_request_password': 'Password',
    'signup_request_phone': 'Phone',
    'signup_request_company': 'Company',
    'signup_request_station_code': 'Station Code (e.g., DE123)',
    'signup_request_required': 'Required',
    'signup_request_valid_email': 'Enter a valid email',
    'signup_request_password_min': 'Min 6 chars',
    'signup_request_submitting': 'Submitting...',
    'signup_request_submit': 'Submit & Verify Email',
  };

  static final Map<String, Map<String, String>> _miscLocalizedValues = {
    'en': _miscSharedValues,
    'de': {
      ..._miscSharedValues,
      'button_close': 'Schließen',
      'button_open': 'Öffnen',
      'button_delete': 'Löschen',
      'button_reload': 'Neu laden',
      'button_add': 'Hinzufügen',
      'button_edit': 'Bearbeiten',
      'button_sign_out': 'Abmelden',
      'verify_email_sent': 'Bestätigungs-E-Mail gesendet.',
      'verify_email_title': 'E-Mail bestätigen',
      'verify_email_intro': 'Wir haben einen Bestätigungslink gesendet an:',
      'verify_email_sending': 'Wird gesendet...',
      'verify_email_resend': 'Bestätigungs-E-Mail erneut senden',
      'verify_email_reload': 'Ich habe bestätigt - Neu laden',
      'verify_email_back_to_login': 'Zurück zum Login',
      'verify_email_failed_template':
          'Bestätigungs-E-Mail konnte nicht erneut gesendet werden: {error}',
      'driver_shift_plan_missing_scope': 'DSP- oder Fahrerkontext fehlt.',
      'driver_shift_plan_title': 'Schichtplan',
      'driver_shift_plan_load_failed_template':
          'Schichten konnten nicht geladen werden: {error}',
      'driver_shift_plan_empty': 'Noch keine Schichten zugewiesen.',
      'driver_shift_plan_upcoming': 'Kommende Schichten',
      'driver_shift_plan_upcoming_empty': 'Keine kommenden Schichten.',
      'driver_shift_plan_past': 'Vergangene Schichten',
      'driver_shift_plan_past_empty': 'Keine vergangenen Schichten.',
      'driver_shift_plan_status_scheduled': 'Geplant',
      'driver_rules_error_template': 'Fehler: {error}',
      'driver_rules_empty': 'Noch keine Regeln.',
      'driver_notifications_filter_all': 'Alle',
      'driver_notifications_filter_rule': 'Regel',
      'driver_notifications_filter_academy': 'DA Academy',
      'driver_notifications_filter_message': 'Nachricht',
      'driver_notifications_filter_ride_along': 'Mitfahrt',
      'driver_notifications_error_template': 'Fehler: {error}',
      'driver_notifications_empty': 'Noch keine Benachrichtigungen.',
      'driver_notifications_filter_empty':
          'Keine Benachrichtigungen für diesen Filter.',
      'auth_gate_driver_profile_error_template':
          'Fehler beim Laden des Fahrerprofils: {error}',
      'auth_gate_no_profile_found':
          'Dein Login ist aktiv, aber es konnte kein Fahrer-/DSP-Profil gefunden werden.',
      'auth_gate_contact_admin': 'Bitte kontaktiere deinen DSP oder Admin.',
      'auth_gate_awaiting_approval_title':
          'Dein DSP-Konto wartet auf Genehmigung.',
      'auth_gate_awaiting_approval_body':
          'Sobald ein Admin dein Konto genehmigt, kannst du auf das Dashboard zugreifen.',
      'auth_gate_awaiting_approval_tab_hint':
          'Du kannst diesen Tab schließen; der Zugriff wird nach der Genehmigung freigeschaltet.',
      'notification_pin_close_tooltip': 'Schließen',
      'driver_onboarding_save_failed_template':
          'Speichern fehlgeschlagen: {error}',
      'driver_onboarding_document_uploaded_template':
          '{document} hochgeladen.',
      'driver_onboarding_upload_documents_failed_template':
          'Dokumente konnten nicht hochgeladen werden: {error}',
      'driver_onboarding_open_document_tooltip': 'Öffnen',
      'driver_onboarding_delete_document_tooltip': 'Löschen',
      'driver_onboarding_open_document_failed':
          'Dokument-URL konnte nicht geöffnet werden',
      'driver_onboarding_document_deleted': 'Dokument gelöscht.',
      'driver_onboarding_delete_document_failed_template':
          'Dokument konnte nicht gelöscht werden: {error}',
      'signup_request_title': 'Konto beantragen',
      'signup_request_success':
          'Bestätigungs-E-Mail gesendet. Bitte bestätigen und dann auf Genehmigung warten.',
      'signup_request_full_name': 'Vollständiger Name',
      'signup_request_email': 'E-Mail',
      'signup_request_password': 'Passwort',
      'signup_request_phone': 'Telefon',
      'signup_request_company': 'Firma',
      'signup_request_station_code': 'Stationscode (z. B. DE123)',
      'signup_request_required': 'Erforderlich',
      'signup_request_valid_email': 'Gültige E-Mail eingeben',
      'signup_request_password_min': 'Mindestens 6 Zeichen',
      'signup_request_submitting': 'Wird gesendet...',
      'signup_request_submit': 'Absenden & E-Mail bestätigen',
    },
    'sq': {
      ..._miscSharedValues,
      'button_close': 'Mbyll',
      'button_open': 'Hap',
      'button_delete': 'Fshi',
      'button_reload': 'Ringarko',
      'button_add': 'Shto',
      'button_edit': 'Ndrysho',
      'button_sign_out': 'Dil',
      'verify_email_sent': 'Emaili i verifikimit u dërgua.',
      'verify_email_title': 'Verifiko emailin',
      'verify_email_intro': 'Kemi dërguar një lidhje verifikimi te:',
      'verify_email_sending': 'Duke dërguar...',
      'verify_email_resend': 'Ridërgo emailin e verifikimit',
      'verify_email_reload': 'E verifikova - Ringarko',
      'verify_email_back_to_login': 'Kthehu te hyrja',
      'verify_email_failed_template':
          'Ridërgimi i emailit të verifikimit dështoi: {error}',
      'driver_shift_plan_missing_scope':
          'Mungon konteksti i DSP-së ose i shoferit.',
      'driver_shift_plan_title': 'Plani i turnit',
      'driver_shift_plan_load_failed_template':
          'Turnet nuk u ngarkuan: {error}',
      'driver_shift_plan_empty': 'Nuk ka ende turne të caktuara.',
      'driver_shift_plan_upcoming': 'Turnet e ardhshme',
      'driver_shift_plan_upcoming_empty': 'Nuk ka turne të ardhshme.',
      'driver_shift_plan_past': 'Turnet e kaluara',
      'driver_shift_plan_past_empty': 'Nuk ka turne të kaluara.',
      'driver_shift_plan_status_scheduled': 'Planifikuar',
      'driver_rules_error_template': 'Gabim: {error}',
      'driver_rules_empty': 'Nuk ka ende rregulla.',
      'driver_notifications_filter_all': 'Të gjitha',
      'driver_notifications_filter_rule': 'Rregull',
      'driver_notifications_filter_academy': 'DA Academy',
      'driver_notifications_filter_message': 'Mesazh',
      'driver_notifications_filter_ride_along': 'Ride Along',
      'driver_notifications_error_template': 'Gabim: {error}',
      'driver_notifications_empty': 'Nuk ka ende njoftime.',
      'driver_notifications_filter_empty':
          'Nuk ka njoftime për këtë filtër.',
      'auth_gate_driver_profile_error_template':
          'Gabim gjatë ngarkimit të profilit të shoferit: {error}',
      'auth_gate_no_profile_found':
          'Hyrja juaj është aktive, por nuk u gjet profil shoferi/DSP.',
      'auth_gate_contact_admin':
          'Ju lutem kontaktoni DSP-në ose administratorin tuaj.',
      'auth_gate_awaiting_approval_title':
          'Llogaria juaj DSP po pret miratimin.',
      'auth_gate_awaiting_approval_body':
          'Pasi një administrator ta miratojë llogarinë tuaj, mund të hyni në panel.',
      'auth_gate_awaiting_approval_tab_hint':
          'Mund ta mbyllni këtë skedë; qasja do të lejohet pas miratimit.',
      'notification_pin_close_tooltip': 'Mbyll',
      'driver_onboarding_save_failed_template':
          'Ruajtja dështoi: {error}',
      'driver_onboarding_document_uploaded_template':
          '{document} u ngarkua.',
      'driver_onboarding_upload_documents_failed_template':
          'Ngarkimi i dokumenteve dështoi: {error}',
      'driver_onboarding_open_document_tooltip': 'Hap',
      'driver_onboarding_delete_document_tooltip': 'Fshi',
      'driver_onboarding_open_document_failed':
          'URL-ja e dokumentit nuk mund të hapej',
      'driver_onboarding_document_deleted': 'Dokumenti u fshi.',
      'driver_onboarding_delete_document_failed_template':
          'Fshirja e dokumentit dështoi: {error}',
      'signup_request_title': 'Apliko për llogari',
      'signup_request_success':
          'Emaili i verifikimit u dërgua. Verifikoje dhe prit miratimin.',
      'signup_request_full_name': 'Emri i plotë',
      'signup_request_email': 'Email',
      'signup_request_password': 'Fjalëkalimi',
      'signup_request_phone': 'Telefon',
      'signup_request_company': 'Kompania',
      'signup_request_station_code': 'Kodi i stacionit (p.sh. DE123)',
      'signup_request_required': 'E detyrueshme',
      'signup_request_valid_email': 'Shkruani një email të vlefshëm',
      'signup_request_password_min': 'Minimumi 6 karaktere',
      'signup_request_submitting': 'Duke dërguar...',
      'signup_request_submit': 'Dërgo & verifiko emailin',
    },
    'hu': {
      ..._miscSharedValues,
      'button_close': 'Bezárás',
      'button_open': 'Megnyitás',
      'button_delete': 'Törlés',
      'button_reload': 'Újratöltés',
      'button_add': 'Hozzáadás',
      'button_edit': 'Szerkesztés',
      'button_sign_out': 'Kijelentkezés',
      'verify_email_sent': 'Az ellenőrző email elküldve.',
      'verify_email_title': 'E-mail megerősítése',
      'verify_email_intro': 'Ellenőrző linket küldtünk ide:',
      'verify_email_sending': 'Küldés...',
      'verify_email_resend': 'Ellenőrző email újraküldése',
      'verify_email_reload': 'Megerősítettem - Újratöltés',
      'verify_email_back_to_login': 'Vissza a bejelentkezéshez',
      'verify_email_failed_template':
          'Az ellenőrző email újraküldése sikertelen: {error}',
      'driver_shift_plan_missing_scope':
          'Hiányzik a DSP vagy a sofőr azonosítása.',
      'driver_shift_plan_title': 'Műszakterv',
      'driver_shift_plan_load_failed_template':
          'A műszakok betöltése sikertelen: {error}',
      'driver_shift_plan_empty': 'Még nincsenek kiosztott műszakok.',
      'driver_shift_plan_upcoming': 'Közelgő műszakok',
      'driver_shift_plan_upcoming_empty': 'Nincsenek közelgő műszakok.',
      'driver_shift_plan_past': 'Korábbi műszakok',
      'driver_shift_plan_past_empty': 'Nincsenek korábbi műszakok.',
      'driver_shift_plan_status_scheduled': 'Ütemezett',
      'driver_rules_error_template': 'Hiba: {error}',
      'driver_rules_empty': 'Még nincsenek szabályok.',
      'driver_notifications_filter_all': 'Összes',
      'driver_notifications_filter_rule': 'Szabály',
      'driver_notifications_filter_academy': 'DA Academy',
      'driver_notifications_filter_message': 'Üzenet',
      'driver_notifications_filter_ride_along': 'Ride Along',
      'driver_notifications_error_template': 'Hiba: {error}',
      'driver_notifications_empty': 'Még nincsenek értesítések.',
      'driver_notifications_filter_empty':
          'Ehhez a szűrőhöz nincs értesítés.',
      'auth_gate_driver_profile_error_template':
          'Hiba a sofőr profiljának betöltésekor: {error}',
      'auth_gate_no_profile_found':
          'A bejelentkezés aktív, de nem található sofőr/DSP profil.',
      'auth_gate_contact_admin':
          'Kérjük, lépjen kapcsolatba a DSP-vel vagy az adminnal.',
      'auth_gate_awaiting_approval_title':
          'A DSP-fiók jóváhagyásra vár.',
      'auth_gate_awaiting_approval_body':
          'Amint egy admin jóváhagyja a fiókját, hozzáférhet az irányítópulthoz.',
      'auth_gate_awaiting_approval_tab_hint':
          'Bezárhatja ezt a lapot; a hozzáférés jóváhagyás után engedélyezett lesz.',
      'notification_pin_close_tooltip': 'Bezárás',
      'driver_onboarding_save_failed_template':
          'A mentés sikertelen: {error}',
      'driver_onboarding_document_uploaded_template':
          '{document} feltöltve.',
      'driver_onboarding_upload_documents_failed_template':
          'A dokumentumok feltöltése sikertelen: {error}',
      'driver_onboarding_open_document_tooltip': 'Megnyitás',
      'driver_onboarding_delete_document_tooltip': 'Törlés',
      'driver_onboarding_open_document_failed':
          'A dokumentum URL nem nyitható meg',
      'driver_onboarding_document_deleted': 'A dokumentum törölve.',
      'driver_onboarding_delete_document_failed_template':
          'A dokumentum törlése sikertelen: {error}',
      'signup_request_title': 'Fiók igénylése',
      'signup_request_success':
          'Az ellenőrző email elküldve. Erősítse meg, majd várja a jóváhagyást.',
      'signup_request_full_name': 'Teljes név',
      'signup_request_email': 'Email',
      'signup_request_password': 'Jelszó',
      'signup_request_phone': 'Telefon',
      'signup_request_company': 'Cég',
      'signup_request_station_code': 'Állomáskód (pl. DE123)',
      'signup_request_required': 'Kötelező',
      'signup_request_valid_email': 'Adjon meg érvényes emailt',
      'signup_request_password_min': 'Minimum 6 karakter',
      'signup_request_submitting': 'Küldés...',
      'signup_request_submit': 'Beküldés és email megerősítése',
    },
    'ro': {
      ..._miscSharedValues,
      'button_close': 'Închide',
      'button_open': 'Deschide',
      'button_delete': 'Șterge',
      'button_reload': 'Reîncarcă',
      'button_add': 'Adaugă',
      'button_edit': 'Editează',
      'button_sign_out': 'Deconectare',
      'verify_email_sent': 'Emailul de verificare a fost trimis.',
      'verify_email_title': 'Verifică emailul',
      'verify_email_intro': 'Am trimis un link de verificare către:',
      'verify_email_sending': 'Se trimite...',
      'verify_email_resend': 'Retrimite emailul de verificare',
      'verify_email_reload': 'Am verificat - Reîncarcă',
      'verify_email_back_to_login': 'Înapoi la autentificare',
      'verify_email_failed_template':
          'Retrimiterea emailului de verificare a eșuat: {error}',
      'driver_shift_plan_missing_scope':
          'Lipsește contextul DSP sau al șoferului.',
      'driver_shift_plan_title': 'Planul turei',
      'driver_shift_plan_load_failed_template':
          'Încărcarea turelor a eșuat: {error}',
      'driver_shift_plan_empty': 'Nu există încă ture alocate.',
      'driver_shift_plan_upcoming': 'Ture viitoare',
      'driver_shift_plan_upcoming_empty': 'Nu există ture viitoare.',
      'driver_shift_plan_past': 'Ture trecute',
      'driver_shift_plan_past_empty': 'Nu există ture trecute.',
      'driver_shift_plan_status_scheduled': 'Programat',
      'driver_rules_error_template': 'Eroare: {error}',
      'driver_rules_empty': 'Nu există reguli încă.',
      'driver_notifications_filter_all': 'Toate',
      'driver_notifications_filter_rule': 'Regulă',
      'driver_notifications_filter_academy': 'DA Academy',
      'driver_notifications_filter_message': 'Mesaj',
      'driver_notifications_filter_ride_along': 'Ride Along',
      'driver_notifications_error_template': 'Eroare: {error}',
      'driver_notifications_empty': 'Nu există notificări încă.',
      'driver_notifications_filter_empty':
          'Nu există notificări pentru acest filtru.',
      'auth_gate_driver_profile_error_template':
          'Eroare la încărcarea profilului șoferului: {error}',
      'auth_gate_no_profile_found':
          'Autentificarea este activă, dar nu a fost găsit niciun profil de șofer/DSP.',
      'auth_gate_contact_admin':
          'Vă rugăm să contactați DSP-ul sau administratorul.',
      'auth_gate_awaiting_approval_title':
          'Contul DSP așteaptă aprobarea.',
      'auth_gate_awaiting_approval_body':
          'După ce un administrator aprobă contul, puteți accesa tabloul de bord.',
      'auth_gate_awaiting_approval_tab_hint':
          'Puteți închide această filă; accesul va fi permis după aprobare.',
      'notification_pin_close_tooltip': 'Închide',
      'driver_onboarding_save_failed_template':
          'Salvarea a eșuat: {error}',
      'driver_onboarding_document_uploaded_template':
          '{document} a fost încărcat.',
      'driver_onboarding_upload_documents_failed_template':
          'Încărcarea documentelor a eșuat: {error}',
      'driver_onboarding_open_document_tooltip': 'Deschide',
      'driver_onboarding_delete_document_tooltip': 'Șterge',
      'driver_onboarding_open_document_failed':
          'URL-ul documentului nu a putut fi deschis',
      'driver_onboarding_document_deleted': 'Documentul a fost șters.',
      'driver_onboarding_delete_document_failed_template':
          'Ștergerea documentului a eșuat: {error}',
      'signup_request_title': 'Aplică pentru cont',
      'signup_request_success':
          'Emailul de verificare a fost trimis. Verifică-l, apoi așteaptă aprobarea.',
      'signup_request_full_name': 'Nume complet',
      'signup_request_email': 'Email',
      'signup_request_password': 'Parolă',
      'signup_request_phone': 'Telefon',
      'signup_request_company': 'Companie',
      'signup_request_station_code': 'Cod stație (ex. DE123)',
      'signup_request_required': 'Obligatoriu',
      'signup_request_valid_email': 'Introduceți un email valid',
      'signup_request_password_min': 'Minim 6 caractere',
      'signup_request_submitting': 'Se trimite...',
      'signup_request_submit': 'Trimite și verifică emailul',
    },
    'hr': {
      ..._miscSharedValues,
      'button_close': 'Zatvori',
      'button_open': 'Otvori',
      'button_delete': 'Izbriši',
      'button_reload': 'Ponovno učitaj',
      'button_add': 'Dodaj',
      'button_edit': 'Uredi',
      'button_sign_out': 'Odjava',
      'verify_email_sent': 'Verifikacijski email je poslan.',
      'verify_email_title': 'Potvrdi email',
      'verify_email_intro': 'Poslali smo verifikacijski link na:',
      'verify_email_sending': 'Slanje...',
      'verify_email_resend': 'Ponovno pošalji verifikacijski email',
      'verify_email_reload': 'Potvrdio sam - Ponovno učitaj',
      'verify_email_back_to_login': 'Natrag na prijavu',
      'verify_email_failed_template':
          'Ponovno slanje verifikacijskog emaila nije uspjelo: {error}',
      'driver_shift_plan_missing_scope':
          'Nedostaje DSP ili vozački kontekst.',
      'driver_shift_plan_title': 'Plan smjene',
      'driver_shift_plan_load_failed_template':
          'Učitavanje smjena nije uspjelo: {error}',
      'driver_shift_plan_empty': 'Još nema dodijeljenih smjena.',
      'driver_shift_plan_upcoming': 'Nadolazeće smjene',
      'driver_shift_plan_upcoming_empty': 'Nema nadolazećih smjena.',
      'driver_shift_plan_past': 'Prošle smjene',
      'driver_shift_plan_past_empty': 'Nema prošlih smjena.',
      'driver_shift_plan_status_scheduled': 'Planirano',
      'driver_rules_error_template': 'Greška: {error}',
      'driver_rules_empty': 'Još nema pravila.',
      'driver_notifications_filter_all': 'Sve',
      'driver_notifications_filter_rule': 'Pravilo',
      'driver_notifications_filter_academy': 'DA Academy',
      'driver_notifications_filter_message': 'Poruka',
      'driver_notifications_filter_ride_along': 'Ride Along',
      'driver_notifications_error_template': 'Greška: {error}',
      'driver_notifications_empty': 'Još nema obavijesti.',
      'driver_notifications_filter_empty':
          'Nema obavijesti za ovaj filter.',
      'auth_gate_driver_profile_error_template':
          'Greška pri učitavanju profila vozača: {error}',
      'auth_gate_no_profile_found':
          'Vaša prijava je aktivna, ali nije pronađen profil vozača/DSP-a.',
      'auth_gate_contact_admin':
          'Molimo kontaktirajte svoj DSP ili administratora.',
      'auth_gate_awaiting_approval_title':
          'Vaš DSP račun čeka odobrenje.',
      'auth_gate_awaiting_approval_body':
          'Nakon što administrator odobri vaš račun, moći ćete pristupiti nadzornoj ploči.',
      'auth_gate_awaiting_approval_tab_hint':
          'Možete zatvoriti ovu karticu; pristup će biti omogućen nakon odobrenja.',
      'notification_pin_close_tooltip': 'Zatvori',
      'driver_onboarding_save_failed_template':
          'Spremanje nije uspjelo: {error}',
      'driver_onboarding_document_uploaded_template':
          '{document} je prenesen.',
      'driver_onboarding_upload_documents_failed_template':
          'Prijenos dokumenata nije uspio: {error}',
      'driver_onboarding_open_document_tooltip': 'Otvori',
      'driver_onboarding_delete_document_tooltip': 'Izbriši',
      'driver_onboarding_open_document_failed':
          'URL dokumenta nije moguće otvoriti',
      'driver_onboarding_document_deleted': 'Dokument je izbrisan.',
      'driver_onboarding_delete_document_failed_template':
          'Brisanje dokumenta nije uspjelo: {error}',
      'signup_request_title': 'Zatraži račun',
      'signup_request_success':
          'Verifikacijski email je poslan. Potvrdite ga i pričekajte odobrenje.',
      'signup_request_full_name': 'Puno ime',
      'signup_request_email': 'Email',
      'signup_request_password': 'Lozinka',
      'signup_request_phone': 'Telefon',
      'signup_request_company': 'Tvrtka',
      'signup_request_station_code': 'Kod stanice (npr. DE123)',
      'signup_request_required': 'Obavezno',
      'signup_request_valid_email': 'Unesite valjan email',
      'signup_request_password_min': 'Najmanje 6 znakova',
      'signup_request_submitting': 'Slanje...',
      'signup_request_submit': 'Pošalji i potvrdi email',
    },
    'ar': {
      ..._miscSharedValues,
      'button_close': 'إغلاق',
      'button_open': 'فتح',
      'button_delete': 'حذف',
      'button_reload': 'إعادة تحميل',
      'button_add': 'إضافة',
      'button_edit': 'تعديل',
      'button_sign_out': 'تسجيل الخروج',
      'verify_email_sent': 'تم إرسال بريد التحقق.',
      'verify_email_title': 'تحقق من بريدك الإلكتروني',
      'verify_email_intro': 'لقد أرسلنا رابط تحقق إلى:',
      'verify_email_sending': 'جارٍ الإرسال...',
      'verify_email_resend': 'إعادة إرسال بريد التحقق',
      'verify_email_reload': 'لقد تحققت - أعد التحميل',
      'verify_email_back_to_login': 'العودة إلى تسجيل الدخول',
      'verify_email_failed_template':
          'فشلت إعادة إرسال بريد التحقق: {error}',
      'driver_shift_plan_missing_scope': 'نطاق DSP أو السائق مفقود.',
      'driver_shift_plan_title': 'خطة المناوبة',
      'driver_shift_plan_load_failed_template':
          'فشل تحميل المناوبات: {error}',
      'driver_shift_plan_empty': 'لا توجد مناوبات مخصصة بعد.',
      'driver_shift_plan_upcoming': 'المناوبات القادمة',
      'driver_shift_plan_upcoming_empty': 'لا توجد مناوبات قادمة.',
      'driver_shift_plan_past': 'المناوبات السابقة',
      'driver_shift_plan_past_empty': 'لا توجد مناوبات سابقة.',
      'driver_shift_plan_status_scheduled': 'مجدول',
      'driver_rules_error_template': 'خطأ: {error}',
      'driver_rules_empty': 'لا توجد قواعد بعد.',
      'driver_notifications_filter_all': 'الكل',
      'driver_notifications_filter_rule': 'قاعدة',
      'driver_notifications_filter_academy': 'أكاديمية DA',
      'driver_notifications_filter_message': 'رسالة',
      'driver_notifications_filter_ride_along': 'مرافقة',
      'driver_notifications_error_template': 'خطأ: {error}',
      'driver_notifications_empty': 'لا توجد إشعارات بعد.',
      'driver_notifications_filter_empty':
          'لا توجد إشعارات لهذا الفلتر.',
      'auth_gate_driver_profile_error_template':
          'خطأ أثناء تحميل ملف السائق: {error}',
      'auth_gate_no_profile_found':
          'تسجيل الدخول نشط، لكن لم يتم العثور على ملف سائق أو DSP.',
      'auth_gate_contact_admin': 'يرجى التواصل مع DSP أو المسؤول.',
      'auth_gate_awaiting_approval_title':
          'حساب DSP الخاص بك بانتظار الموافقة.',
      'auth_gate_awaiting_approval_body':
          'بمجرد موافقة المسؤول على حسابك، ستتمكن من الوصول إلى لوحة التحكم.',
      'auth_gate_awaiting_approval_tab_hint':
          'يمكنك إغلاق هذه الصفحة؛ سيتم السماح بالوصول بعد الموافقة.',
      'notification_pin_close_tooltip': 'إغلاق',
      'driver_onboarding_save_failed_template':
          'فشل الحفظ: {error}',
      'driver_onboarding_document_uploaded_template':
          'تم رفع {document}.',
      'driver_onboarding_upload_documents_failed_template':
          'فشل رفع المستندات: {error}',
      'driver_onboarding_open_document_tooltip': 'فتح',
      'driver_onboarding_delete_document_tooltip': 'حذف',
      'driver_onboarding_open_document_failed':
          'تعذر فتح رابط المستند',
      'driver_onboarding_document_deleted': 'تم حذف المستند.',
      'driver_onboarding_delete_document_failed_template':
          'فشل حذف المستند: {error}',
      'signup_request_title': 'التقديم على حساب',
      'signup_request_success':
          'تم إرسال بريد التحقق. يرجى التحقق ثم انتظار الموافقة.',
      'signup_request_full_name': 'الاسم الكامل',
      'signup_request_email': 'البريد الإلكتروني',
      'signup_request_password': 'كلمة المرور',
      'signup_request_phone': 'الهاتف',
      'signup_request_company': 'الشركة',
      'signup_request_station_code': 'رمز المحطة (مثال DE123)',
      'signup_request_required': 'مطلوب',
      'signup_request_valid_email':
          'يرجى إدخال بريد إلكتروني صالح',
      'signup_request_password_min': '6 أحرف على الأقل',
      'signup_request_submitting': 'جارٍ الإرسال...',
      'signup_request_submit': 'إرسال والتحقق من البريد',
    },
    'tr': {
      ..._miscSharedValues,
      'button_close': 'Kapat',
      'button_open': 'Ac',
      'button_delete': 'Sil',
      'button_reload': 'Yeniden yukle',
      'button_add': 'Ekle',
      'button_edit': 'Duzenle',
      'button_sign_out': 'Cikis yap',
      'verify_email_sent': 'Dogrulama e-postasi gonderildi.',
      'verify_email_title': 'E-postani dogrula',
      'verify_email_intro': 'Dogrulama baglantisi su adrese gonderildi:',
      'verify_email_sending': 'Gonderiliyor...',
      'verify_email_resend': 'Dogrulama e-postasini yeniden gonder',
      'verify_email_reload': 'Dogruladim - Yenile',
      'verify_email_back_to_login': 'Girise don',
      'verify_email_failed_template':
          'Dogrulama e-postasi yeniden gonderilemedi: {error}',
      'driver_shift_plan_missing_scope':
          'DSP veya surucu kapsami eksik.',
      'driver_shift_plan_title': 'Vardiya Plani',
      'driver_shift_plan_load_failed_template':
          'Vardiyalar yuklenemedi: {error}',
      'driver_shift_plan_empty': 'Henuz atanmis vardiya yok.',
      'driver_shift_plan_upcoming': 'Yaklasan vardiyalar',
      'driver_shift_plan_upcoming_empty': 'Yaklasan vardiya yok.',
      'driver_shift_plan_past': 'Gecmis vardiyalar',
      'driver_shift_plan_past_empty': 'Gecmis vardiya yok.',
      'driver_shift_plan_status_scheduled': 'Planlandi',
      'driver_rules_error_template': 'Hata: {error}',
      'driver_rules_empty': 'Henuz kural yok.',
      'driver_notifications_filter_all': 'Tum',
      'driver_notifications_filter_rule': 'Kural',
      'driver_notifications_filter_academy': 'DA Academy',
      'driver_notifications_filter_message': 'Mesaj',
      'driver_notifications_filter_ride_along': 'Ride Along',
      'driver_notifications_error_template': 'Hata: {error}',
      'driver_notifications_empty': 'Henuz bildirim yok.',
      'driver_notifications_filter_empty':
          'Bu filtre icin bildirim yok.',
      'auth_gate_driver_profile_error_template':
          'Surucu profili yuklenirken hata olustu: {error}',
      'auth_gate_no_profile_found':
          'Girisiniz aktif, ancak surucu/DSP profili bulunamadi.',
      'auth_gate_contact_admin':
          'Lutfen DSP veya yonetici ile iletisime gecin.',
      'auth_gate_awaiting_approval_title':
          'DSP hesabin onay bekliyor.',
      'auth_gate_awaiting_approval_body':
          'Bir yonetici hesabinizi onayladiginda panele erisebilirsiniz.',
      'auth_gate_awaiting_approval_tab_hint':
          'Bu sekmeyi kapatabilirsiniz; onaydan sonra erisim acilacaktir.',
      'notification_pin_close_tooltip': 'Kapat',
      'driver_onboarding_save_failed_template':
          'Kaydetme basarisiz: {error}',
      'driver_onboarding_document_uploaded_template':
          '{document} yuklendi.',
      'driver_onboarding_upload_documents_failed_template':
          'Belgeler yuklenemedi: {error}',
      'driver_onboarding_open_document_tooltip': 'Ac',
      'driver_onboarding_delete_document_tooltip': 'Sil',
      'driver_onboarding_open_document_failed':
          'Belge URLsi acilamadi',
      'driver_onboarding_document_deleted': 'Belge silindi.',
      'driver_onboarding_delete_document_failed_template':
          'Belge silinemedi: {error}',
      'signup_request_title': 'Hesap basvurusu',
      'signup_request_success':
          'Dogrulama e-postasi gonderildi. Dogrulayin ve onay bekleyin.',
      'signup_request_full_name': 'Ad soyad',
      'signup_request_email': 'E-posta',
      'signup_request_password': 'Sifre',
      'signup_request_phone': 'Telefon',
      'signup_request_company': 'Sirket',
      'signup_request_station_code': 'Istasyon Kodu (orn. DE123)',
      'signup_request_required': 'Zorunlu',
      'signup_request_valid_email': 'Gecerli bir e-posta girin',
      'signup_request_password_min': 'En az 6 karakter',
      'signup_request_submitting': 'Gonderiliyor...',
      'signup_request_submit': 'Gonder ve e-postayi dogrula',
    },
    'ru': {
      ..._miscSharedValues,
      'button_close': 'Закрыть',
      'button_open': 'Открыть',
      'button_delete': 'Удалить',
      'button_reload': 'Перезагрузить',
      'button_add': 'Добавить',
      'button_edit': 'Редактировать',
      'button_sign_out': 'Выйти',
      'verify_email_sent': 'Письмо для подтверждения отправлено.',
      'verify_email_title': 'Подтвердите email',
      'verify_email_intro': 'Мы отправили ссылку подтверждения на:',
      'verify_email_sending': 'Отправка...',
      'verify_email_resend': 'Отправить письмо повторно',
      'verify_email_reload': 'Я подтвердил - Обновить',
      'verify_email_back_to_login': 'Назад к входу',
      'verify_email_failed_template':
          'Не удалось повторно отправить письмо подтверждения: {error}',
      'driver_shift_plan_missing_scope':
          'Отсутствует контекст DSP или водителя.',
      'driver_shift_plan_title': 'План смен',
      'driver_shift_plan_load_failed_template':
          'Не удалось загрузить смены: {error}',
      'driver_shift_plan_empty': 'Смены еще не назначены.',
      'driver_shift_plan_upcoming': 'Предстоящие смены',
      'driver_shift_plan_upcoming_empty': 'Нет предстоящих смен.',
      'driver_shift_plan_past': 'Прошедшие смены',
      'driver_shift_plan_past_empty': 'Нет прошедших смен.',
      'driver_shift_plan_status_scheduled': 'Запланировано',
      'driver_rules_error_template': 'Ошибка: {error}',
      'driver_rules_empty': 'Правил пока нет.',
      'driver_notifications_filter_all': 'Все',
      'driver_notifications_filter_rule': 'Правило',
      'driver_notifications_filter_academy': 'DA Academy',
      'driver_notifications_filter_message': 'Сообщение',
      'driver_notifications_filter_ride_along': 'Ride Along',
      'driver_notifications_error_template': 'Ошибка: {error}',
      'driver_notifications_empty': 'Уведомлений пока нет.',
      'driver_notifications_filter_empty':
          'Для этого фильтра уведомлений нет.',
      'auth_gate_driver_profile_error_template':
          'Ошибка загрузки профиля водителя: {error}',
      'auth_gate_no_profile_found':
          'Ваш вход активен, но профиль водителя/DSP не найден.',
      'auth_gate_contact_admin':
          'Пожалуйста, свяжитесь с DSP или администратором.',
      'auth_gate_awaiting_approval_title':
          'Ваш аккаунт DSP ожидает одобрения.',
      'auth_gate_awaiting_approval_body':
          'Как только администратор одобрит ваш аккаунт, вы получите доступ к панели.',
      'auth_gate_awaiting_approval_tab_hint':
          'Вы можете закрыть эту вкладку; доступ будет открыт после одобрения.',
      'notification_pin_close_tooltip': 'Закрыть',
      'driver_onboarding_save_failed_template':
          'Не удалось сохранить: {error}',
      'driver_onboarding_document_uploaded_template':
          '{document} загружен.',
      'driver_onboarding_upload_documents_failed_template':
          'Не удалось загрузить документы: {error}',
      'driver_onboarding_open_document_tooltip': 'Открыть',
      'driver_onboarding_delete_document_tooltip': 'Удалить',
      'driver_onboarding_open_document_failed':
          'Не удалось открыть URL документа',
      'driver_onboarding_document_deleted': 'Документ удален.',
      'driver_onboarding_delete_document_failed_template':
          'Не удалось удалить документ: {error}',
      'signup_request_title': 'Подать заявку на аккаунт',
      'signup_request_success':
          'Письмо подтверждения отправлено. Подтвердите email и ждите одобрения.',
      'signup_request_full_name': 'Полное имя',
      'signup_request_email': 'Email',
      'signup_request_password': 'Пароль',
      'signup_request_phone': 'Телефон',
      'signup_request_company': 'Компания',
      'signup_request_station_code': 'Код станции (например, DE123)',
      'signup_request_required': 'Обязательно',
      'signup_request_valid_email': 'Введите корректный email',
      'signup_request_password_min': 'Минимум 6 символов',
      'signup_request_submitting': 'Отправка...',
      'signup_request_submit': 'Отправить и подтвердить email',
    },
  };

  String _lang() => locale.languageCode.toLowerCase();

  String t(String key) {
    final lang = _lang();
    final langMap = _localizedValues[lang] ?? _localizedValues['en']!;
    final driverNotificationMap =
        _driverNotificationLocalizedValues[lang] ??
        _driverNotificationLocalizedValues['en']!;
    final driverAbsenceMap =
        _driverAbsenceLocalizedValues[lang] ??
        _driverAbsenceLocalizedValues['en']!;
    final driverDashboardMap =
        _driverDashboardLocalizedValues[lang] ??
        _driverDashboardLocalizedValues['en']!;
    final notificationsMap =
        _notificationsLocalizedValues[lang] ??
        _notificationsLocalizedValues['en']!;
    final taskSheetMap =
        _taskSheetLocalizedValues[lang] ?? _taskSheetLocalizedValues['en']!;
    final deliveryTrainingMap =
        _deliveryTrainingLocalizedValues[lang] ??
        _deliveryTrainingLocalizedValues['en']!;
    final deliveryTrainingOverrideMap =
        _deliveryTrainingLocalizedOverrides[lang] ?? const <String, String>{};
    final driversHubMap =
        _driversHubLocalizedValues[lang] ?? _driversHubLocalizedValues['en']!;
    final adminFaqMap =
        _adminFaqLocalizedValues[lang] ?? _adminFaqLocalizedValues['en']!;
    final adminApprovalsMap =
        _adminApprovalsLocalizedValues[lang] ??
        _adminApprovalsLocalizedValues['en']!;
    final miscMap = _miscLocalizedValues[lang] ?? _miscLocalizedValues['en']!;
    final text = langMap[key] ??
        driverNotificationMap[key] ??
        driverAbsenceMap[key] ??
        driverDashboardMap[key] ??
        notificationsMap[key] ??
        taskSheetMap[key] ??
        deliveryTrainingOverrideMap[key] ??
        deliveryTrainingMap[key] ??
        driversHubMap[key] ??
        adminFaqMap[key] ??
        adminApprovalsMap[key] ??
        miscMap[key] ??
        _localizedValues['en']![key] ??
        _driverNotificationLocalizedValues['en']![key] ??
        _driverAbsenceLocalizedValues['en']![key] ??
        _driverDashboardLocalizedValues['en']![key] ??
        _notificationsLocalizedValues['en']![key] ??
        _taskSheetLocalizedValues['en']![key] ??
        _deliveryTrainingLocalizedValues['en']![key] ??
        _driversHubLocalizedValues['en']![key] ??
        _adminFaqLocalizedValues['en']![key] ??
        _adminApprovalsLocalizedValues['en']![key] ??
        _miscLocalizedValues['en']![key] ??
        key;
    return _normalizeScorecardTerms(text);
  }

  String _normalizeScorecardTerms(String text) {
    return text
        .replaceAll('DNR DPMO', 'DSC DPMO')
        .replaceAll('Delivered Not Received', 'Delivery Success Conditions')
        .replaceAllMapped(RegExp(r'\bDNR\b'), (_) => 'DSC');
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
    return AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
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
    case 'tr':
      return '🇹🇷 Turkce';
    case 'ru':
      return '🇷🇺 Русский';
    default:
      return code;
  }
}
