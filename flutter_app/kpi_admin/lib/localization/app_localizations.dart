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
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Help',
      'nav_rules': 'Rules',
      'nav_profile': 'Profile',
      'change_profile_photo': 'Change profile photo',
      'profile_change_photo': 'Change Profile Photo',
      'logout': 'Logout',
      'profile_logout': 'Logout',
      'pin_change_with_old': 'You can change your PIN after verifying the old one.',
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

      'kpi_title_dcr': 'Delivery Success Rate',
        'kpi_title_dnr': 'Delivery Success Conditions',
        'kpi_title_lor': 'Lost on Road',
        'kpi_title_pod': 'Picture on Delivery',
        'kpi_title_cc': 'Customer Contact',
        'kpi_title_ce': 'Customer Escalation',
        'kpi_title_cdf': 'Customer Delivery Feedback',

        'kpi_desc_dcr': 'The higher the value, the better. To achieve a 100% success rate, it is recommended to attempt a redelivery* after a failed delivery.',
        'kpi_tip_dcr': 'Example: If you cannot deliver a package on a given day for any reason and attempt delivery again later the same day, your DCR value will be higher and closer to 100%, even if the second delivery attempt is also unsuccessful.',

        'kpi_desc_dnr': 'DSC DPMO (Delivery Success Conditions)\n(previously DNR – Delivery Not Received)\n\nThe lower the value, the better.\n\nThis metric measures how correctly and traceably deliveries are carried out.\n\nBasic delivery rules:\n- Delivery to the correct person or the correct location\n- Deliveries to customers, household members, neighbors, or receptionists are low risk when performed correctly\n- Always use the correct scan/reason code so customers receive correct notifications\n\nMailroom / mailbox deliveries:\n- Follow the standard workflow\n- Packages must be fully inside the mailbox or mail slot and must not protrude\n- Use the most accurate scan available\n\nCorrect address & geofence:\n- Delivery within 25 meters of the correct geofence\n- Always match name and address in the app with the package label and the building\n- If the geocode appears incorrect, report it via SDS\n\nPhoto at delivery (POD):\n- Always take a clear photo when prompted\n- Package and surroundings must be clearly visible\n- Especially important for unattended deliveries and customer trust\n\nFollow delivery preferences:\n- Follow customer instructions in the app if they are safe\n- If instructions are unsafe, contact the customer\n- Only use approved safe locations from the app\n\nSimultaneous / group stops:\n- Use “Select all” only when multiple packages are delivered to the same person or location (e.g. reception)\n- Correctly capture recipient name and signature',

        'kpi_tip_dnr': 'Important notice:\n\nRepeated high values in DSC DPMO indicate incorrect or risky deliveries.\n\n- Frequent deviations may be interpreted by Amazon as potential theft\n- This may trigger a loss prevention process\n- In the worst case, this may lead to termination of cooperation\n\nCareful scans, correct photos, and following all delivery rules protect you and your team.',

        'kpi_desc_lor': 'LoR (Lost on Road)\n\nThe lower the value, the better.\n\nThis metric shows whether all undelivered packages are correctly recorded at the end of the route.\n\nAt the end of the route:\n- Check in the scanner how many packages must be returned\n- Ensure this number exactly matches the packages in the vehicle',

        'kpi_tip_lor': 'Important notice:\n\nThis is the category with the highest suspicion of theft.\n\nDiscrepancies between scanner and vehicle inventory may be considered serious errors and can lead to internal investigations or further consequences.',

        'kpi_desc_pod': 'PoD (Picture on Delivery)\n\nThe higher the value, the better.\n\nThis column shows packages for which a photo was taken but which were marked as Invalid or Unsafe.\n\nCommon reasons for POD rejection:\n1. Package label with customer data visible (package must be turned over)\n2. Blurry photo\n3. Person visible in the photo\n4. No package visible in the photo\n5. Package inside the vehicle\n6. Package in hand\n7. Package too close to the camera\n8. Photo too dark',

        'kpi_tip_pod': 'This should be the easiest category\nTarget value: 100%\nSignificantly improves the overall score',

        'kpi_desc_cc': 'CC (Customer Contact)\n\nThe higher the value, the better.\n\nExtremely important:\nYou must ALWAYS send a “No safe location” or “Address not found” message every time you cannot deliver a package because:\n\n- the customer is not at home or\n- the address cannot be found',

        'kpi_tip_cc': 'There is an automatic standard message in the app for every scenario.',

        'kpi_desc_ce': 'CE (Customer Escalation)\n\nThe lower the value, the better.\nThe worst category of all.\n\nCustomers escalate when delivery instructions are not followed.\n\nThe driver is always responsible\nAppeals are nearly impossible without very strong evidence\nHas the strongest impact on your Scorecard\n\nHow to avoid CE\n\nIt is against delivery guidelines to leave packages at unsafe or unattended locations without approval\n\nDelivery Associates must:\n- Ring the doorbell / use intercom or knock\n- Give the customer sufficient time to respond\n\nIf the customer cannot be reached and no safe location is stored:\n- Call the customer twice\n- Send a text message\n- Contact Driver Support if no contact is possible\n\nIf necessary:\n- Scan the package as “Delivery failed – customer unavailable”\n- Retry delivery according to guidelines',

        'kpi_tip_ce': 'Do not leave packages at unsafe or unapproved locations\nAlways follow the correct shipping and delivery processes',

        'kpi_desc_cdf': 'CDF DPMO (Customer Delivery Feedback)\n\nThe lower the value, the better.\n\nLevel 1 (L1)\n- Customer rates the delivery as “Great” (👍) or “Not so good” (👎)\n\nLevel 2 (L2)\n- Additional feedback on why the experience was good or bad',

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

  'faq_q1': 'What is most important about your daily task?',
  'faq_a1': 'Delivering packages in quality and in good behavior.',

  'faq_q2': 'What should you not do in case of problems with the costumer?',
  'faq_a2': 'DO NOT try to handle the situation yourself and inform a dispatcher onduty instead. We will try to talk to the costumer for you and avoid any bad consequences from Amazon due to costumer complaints. We are here for you!',

  'faq_q3': 'What if the situation has already escalated and the costumer is not happy for whatever happened?',
  'faq_a3': 'It is never too late to fix any mistakes. Still call us and we will try to fix the mistake with the costumer. Better late than ever.',

  'faq_q4': 'What is more important, Quantity (speed of delivering as many stops as possible) or Quality?',
  'faq_a4': 'Quality! Always quality! Follow costumers instructions and DO NOT leave the package in unsafe locations, just because you are behind with your stops.',

  'faq_q5': 'What if I focus on quality but then I get behind with my stops?',
  'faq_a5': 'You will finish your stops, in one way or another. We will try to send help but only if we see it reasonable.',

  'faq_q6': 'What is scorecard and a DNR?',
  'faq_a6': 'Glad you asked.',

  'faq_q7': 'Weekly Scorecard',
  'faq_a7': 'The weekly scorecard gives us a quick, clear overview of how the team is doing on our key goals. It helps us spot what’s going well, where we’re falling behind, and what we need to focus on for the week ahead The overall scores are as follows:\n'
  '• Fantastic Plus: >93% (exceptional performance)\n'
    '• Fantastic: 85% – 92.9%\n'
    '• Great: 70% – 84.9%\n'
    '• Fair: 50% – 69.9%\n'
    '• Poor: <50%',

  'faq_q7_1': 'DNR Tab\nDelivered Not Received',
  'faq_a7_1': 'Is when you have delivered a package, and clicked "Swipe to finish" button confirming you have delivered the package but the costumer has not received the package due to number of reasons: Package theft, box being empty of the package items and also wrong delivery to the wrong address.\n'
    'Every Tuesday you will receive pictures of every DNR you have received during the week.',

  'faq_q7_1_1': 'How should I avoid this and how important it is to the weekly scorecard?',
  'faq_a7_1_1': 'It is very important and to avoid this you simply should inform the costumer beforehand that you are soon going to their house/business and ONLY ring the bell with their nameplate on it.',

  'faq_q7_1_2': 'How do I avoid package losses?',
  'faq_a7_1_2': 'Always try to give the packages on hand to the costumer and if this is not possible, send a message informing them as to where the package was left, for example, in the garage, under the stairs, in the shed, behind the flower vase, etc..\n'
    'If you do not think it is safe to leave the package unattended, please, it is always best to just take the package and try again later. This is VERY important.',

  'faq_q7_1_3': 'How do I know what place is safe or not?',
  'faq_a7_1_3': 'Instinct and also common sense. If a building consist of 20 - 30 floors and you leave it by the mailboxes, chances for it to be stolen are higher and higher compared to those in a private house.\n'
    'Also, to help you on your daily deliveries and to avoid getting hit by a DNR, everyday morning we will post a picture with addresses that consist with a high chance of packages to be stolen and costumers complaining, based on previous results deliveries and statistics.',

  'faq_q7_1_4': 'What if a package is lost or stolen, how will that affect my score?',
  'faq_a7_1_4': 'Badly. This will affect you by at least 30% and that is only with one package which loses you at least 600 points. The more points you see in the scorecard under your name, the worse it is. The more packages you deliver per work-week, the less points you lose. The points you lose also varies by the price of the item lost, the more expensive, more points lost. We should keep this score section as low as possible.\n'
    'Not to be ignored is the fact that if you regurlarly have a high number of lost packages, we will have to release you due to the fact that sooner or later, Amazon may suspect of package theft, and therefore this is very dangerous.',

  'faq_q7_2': 'CC Tab\n'
    'Contact Compliance',
  'faq_a7_2': 'Meaning how many times you have reached out to the costumer about their delivery, be it via message or a phone call. The less you interact with the costumer, the less scores you will get in the scorecard and we should keep this section as high as possible because it is actually one of the the easiest categories and it helps a lot in your overall score.',

  'faq_q7_2_1': 'Why should I do this?',
  'faq_a7_2_1': 'Delivering packages is not just Drop&Go, you should also inform the costumer beforehand and ask them as to where would they like to have the package delivered.',

  'faq_q7_2_2': 'How do I improve my CC Scores?',
  'faq_a7_2_2': 'Thank you for asking. Simple, by calling and especially by texting costumers in every stop.',

  'faq_q7_3': 'CE Tab\nCostumer Escalation',
  'faq_a7_3': 'Remember how bad DNR affected your scores? Well, this is at least 2 times worse, and you also risk losing your job because it depends on how bad the situation was.',

  'faq_q7_3_1': 'How do I avoid this?',
  'faq_a7_3_1': 'By always following costumers delivery instructions and in case of a mistake, first please apologize and if the costumer is angry, please ask them for a minute of their time to talk to us, as you are already calling us. By reading Section 2, you should know by now that it is best to just leave it to us to handle such issues.',

  'faq_q7_4': 'POD Tab\nPicture on Delivery',
  'faq_a7_4': 'This column shows the list of package eligible for PODs, for which photos have been taken but which have been either Invalid or Not Sure. Reason for rejecting a POD, which may include:\n'
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
  'faq_a7_5': 'Penalizes you when you have a scanned a package from your loading and have not returned it at the end of the shift in case of a unsuccesful delivery. So the package has been lost and you will lose as much points as you would in a DNR, so please count well the packages you bring back and make sure they match with the packages shown in scanner. You can find them on: Todays Itinerary - Summary - Problems. If they dont match, please inform the dispatcher on-duty before ending work in the Amazon app.',

  'faq_q7_6': 'DCR Tab\nDelivery Completion Rate',
  'faq_a7_6': 'YShows your capabilities on delivering packages. It tracks the percentage of deliveries completed as planned, helping us measure the efficiency and reliability of our deliveries. It highlights issues like delays, failed attempts, or routing problems. This should always be as high as possible. To make that possible you should every day do reattempts and avoid as much you can returning packages.',

  'faq_q7_7': 'CDF Tab (Previously, DEX)\nCostumer Delivery Feedback',
  'faq_a7_7': 'Captures the recipient’s experience with the delivery process, including punctuality, condition of goods, and driver professionalism. It helps us identify service strengths and areas for improvement. At the end of the delivery, costumer gets an email from Amazon about the delivery experience, with questions such as:\n'
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
  'faq_a7_8': 'Quality and efficency go a long way. Good scores are good for you, for the company and good for the whole team. Costumer satisfaction is very important and good scores are accompanied with a bonus from the company.\n'
    'Give your best, get the best.',

  'faq_q8': 'What other areas should I be careful about?',
  'faq_a8': 'Taking care of yourself in driving safely, avoiding injuries and avoiding dogs and dog bites. Being careful with work equipment such as the daily vehicle, the work scanner/phone and coming to work wearing your safety shoes & safety vest, Amazon-branded jacket or t-shirt (depending on the weather).',

  'faq_q9': 'What happens if I do a car accident or damage the work vehicle?',
  'faq_a9': 'First, make sure you are okay and you are not badly injured. As about the car damage, if we determine that accidents occur due to negligence – for example, distractions such as mobile phone use while driving – you will be personally liable for the full damage. Additionally, you will receive a report from the police, which could even result in license suspension. Of course, this is also a reason for immediate dismissal. Otherwise you are only expelled from taking Weekly Scorecard Bonuses for 2 months. In case of an incident, you ARE obliged to inform us immediately and provide us with the time of the incident, location, if there is damages to private or public properties (such as wall, fences, lamp posts, people and/or pets), location and pictures of the car damages.',

  'faq_q10': 'What do I do when I have packages damaged and/or missing.',
  'faq_a10': 'When a package is damaged, feel free to book it as damaged and return it to station. If that damaged package was a liquid package and has damaged other packages with it, please make a picture of all damaged packages and send it to the dispatcher on duty and we will report it to Amazon for you.\n'
    'When a package is missing, feel free to mark/book it as missing unless it has an OTP for which YOU HAVE to report it to us first before marking it as missing. This is VERY IMPORTANT.',

  'faq_q11': 'What is an OTP (One-Time Password) Package?',
  'faq_a11': 'It is an expensive item that Amazon requires costumer to provide the driver with a One Time Password before delivering the package, to ensure the package is delivered to the right person/costumer. You have to take extensive care for such packages and not to leave them unattended and only hand the packages to the costumer that has provided you with the password.',

  'faq_q12': 'Why do we keep bothering you to slow down and not go any faster?',
  'faq_a12': 'We do not like that either but that is how the system is. We need to follow systems algorithm and do as many stops per-hour as predetermined so we can get more routes in the future and you get to work more and not be free.\n'
    'Also by going faster, you risk getting a DNR and risk losing points for both, yourself and the company in the weekly scorecard.',

  'faq_q13': 'Then why do the dispatchers sometimes ask me as to why you are behind and if there is something wrong?',
  'faq_a13': 'We know this is not pleasant but we need some feedback as to what might have happened on the road that caused you to be behind with your stops. Amazon asks us for this feedback because there is also a timelimit of which you should have delivered X stop, therefore Amazon needs to know why the remaining stops are behind the delivery schedule and with this information, improve future delivery efficiency.',

  'faq_q14': 'Why do we sometimes ask you to go help a fellow colleague?',
  'faq_a14': 'Because many factors play a role in the colleagues delay such as bad internet connection in the area, traffic, blocked streets due to construction in the area which has made it difficult for the other driver to deliver on time, therefore your help is needed.',

  'faq_q15': 'Do I immediately in my first day, start to deliver standart-route packages as other, more experienced delivery drivers?',
  'faq_a15': 'No, obviously not that is not the case for you. At the beginning you will have a period of 14 work-days to put in practice what you have learned in the ride-along days with your trainer and adjust with the area, with the car, with the scanner and to learn the workflow proccess.\n'
    'With that said, for that time period of 14 days, Amazon will give you up to 50% less than normal packages and stops in your schedule.',

  'faq_q16': 'What to do when an address is wrong and/or the location pin is not correct on the map?',
  'faq_a16': 'First confirm that the pin is not correct by searching the address in google maps (is more accurate and is already installed on your scanner) and if it does not match, inform a dispatcher on duty with the errors.',

  'faq_q17': 'What are my daily tasks before I begin and after I end work?',
  'faq_a17': '1- When you come into the parking, first you make sure you are wearing the safety shoes and safety vest and Amazon uniform.\n'
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

  'faq_q18': 'Do I have to do anything when I change the van and take another van rather than the one I usually take?',
  'faq_a18': 'You should make a video of it, capturing in detail every small damage the previous driver/s might have done, so it is not your fault in the next inspection of the car.',

  'faq_q19': 'What should I do if the Flex app is constantly loading and slowing down my work flow?',
  'faq_a19': 'First check if you have an active internet connection. To do so you can try to send a message to the current stop costumer and if it goes through then that means the internet connection is active. You can also check by opening another app in the scanner such as the browser and searching something on it.\n'
    'Steps you should follow if there isn ot an active internet connection:\n'
    '1- Restart your scanner. This should always be the first thing you try.\n'
    '2- Turn on/off airplane mode. This works most of the time without having to wait for the scanner to restart.\n'
    '3- As a very last resort, please try to share some hotspot from your personal phone for just 10 minutes max just for the system to refresh itself.\n'
    'You can also work offline but at some point you have to connect to the internet and be active. To work offline you must first download offline maps in the Flex app. To do so, you go to Settings - Offline Maps (last option) - Download DBY5 - Allow downloads with mobile connection.\n',

  'faq_q20': 'What if the internet connection is active and the Flex app is still not working as it should?',
  'faq_a20': '1- Restart the scanner.\n'
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
      'select_language': 'Sprache auswählen',
      'notifications': 'Benachrichtigungen',
      'no_notifications': 'Keine Benachrichtigungen',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Hilfe',
      'nav_rules': 'Regeln',
      'nav_profile': 'Profil',
      'change_profile_photo': 'Profilfoto ändern',
      'profile_change_photo': 'Profilfoto ändern',
      'logout': 'Abmelden',
      'profile_logout': 'Abmelden',
      'pin_change_with_old': 'Du kannst deine PIN nach Eingabe der alten PIN ändern.',
      'pin_forgot_contact_admin': 'PIN vergessen? Bitte den Admin kontaktieren.',
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

      'kpi_title_dcr': 'Delivery Success Rate',
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
      'kpi_desc_dnr': 'DSC DPMO (Delivery Success Conditions)\n(früher DNR – Delivery Not Received)\n\nJe niedriger der Wert, desto besser.\n\nDiese Kennzahl misst, wie korrekt und nachvollziehbar Zustellungen durchgeführt werden.\n\nGrundregeln der Zustellung:\n- Zustellung an die richtige Person oder den richtigen Ort\n- Zustellungen an Kunden, Haushaltsmitglieder, Nachbarn oder Rezeptionisten sind bei korrekter Durchführung risikoarm\n- Immer den korrekten Scan-/Grund-Code verwenden, damit Kunden korrekte Benachrichtigungen erhalten\n\nPostraum- / Briefkastenzustellungen:\n- Standard-Workflow einhalten\n- Pakete müssen vollständig im Briefkasten oder Postschlitz sein und dürfen nicht herausragen\n- Den genauesten verfügbaren Scan verwenden\n\nKorrekte Adresse & Geofence:\n- Zustellung innerhalb von 25 Metern des korrekten Geofence\n- Name und Adresse in der App immer mit dem Paketlabel und dem Gebäude abgleichen\n- Wenn der Geocode falsch erscheint, diesen über SDS melden\n\nFoto bei Zustellung (POD):\n- Immer ein klares Foto aufnehmen, wenn dazu aufgefordert\n- Paket und Umgebung müssen gut sichtbar sein\n- Besonders wichtig bei unbeaufsichtigten Zustellungen und für das Kundenvertrauen\n\nZustellpräferenzen einhalten:\n- Kundenanweisungen in der App befolgen, sofern sie sicher sind\n- Wenn Anweisungen unsicher sind, den Kunden kontaktieren\n- Nur genehmigte sichere Ablageorte aus der App verwenden\n\nGleichzeitige / Gruppen-Stopps:\n- \"Alle auswählen\" nur verwenden, wenn mehrere Pakete an dieselbe Person oder denselben Ort geliefert werden (z. B. Rezeption)\n- Empfängername und Unterschrift korrekt erfassen',

      'kpi_tip_dnr': 'Wichtiger Hinweis:\n\nWiederholt hohe Werte bei DSC DPMO deuten auf fehlerhafte oder riskante Zustellungen hin.\n\n- Häufige Abweichungen können von Amazon als möglicher Diebstahl interpretiert werden\n- Dies kann ein Loss-Prevention-Verfahren auslösen\n- Im schlimmsten Fall kann dies zur Beendigung der Zusammenarbeit führen\n\nSorgfältige Scans, korrekte Fotos und das Einhalten aller Zustellregeln schützen dich und dein Team.',

      'kpi_desc_lor': 'LoR (Lost on Road)\n\nJe niedriger der Wert, desto besser.\n\nDiese Kennzahl zeigt, ob am Ende der Route alle nicht zugestellten Pakete korrekt erfasst wurden.\n\nAm Ende der Route:\n- Im Scanner prüfen, wie viele Pakete zurückzugeben sind\n- Sicherstellen, dass diese Zahl exakt mit den Paketen im Fahrzeug übereinstimmt',

      'kpi_tip_lor': 'Wichtiger Hinweis:\n\nDies ist die Kategorie mit dem höchsten Diebstahlverdacht.\n\nAbweichungen zwischen Scanner und Fahrzeugbestand können als schwerwiegender Fehler gewertet werden und zu internen Prüfungen oder weiteren Konsequenzen führen.',

      'kpi_desc_pod': 'PoD (Picture on Delivery)\n\nJe höher der Wert, desto besser.\n\nDiese Spalte zeigt Pakete, für die ein Foto aufgenommen wurde, die jedoch als Ungültig oder Unsicher markiert wurden.\n\nHäufige Gründe für POD-Ablehnung:\n1. Paketlabel mit Kundendaten sichtbar (Paket muss umgedreht werden)\n2. Unscharfes Foto\n3. Person auf dem Foto sichtbar\n4. Kein Paket auf dem Foto erkennbar\n5. Paket im Fahrzeug\n6. Paket in der Hand\n7. Paket zu nah an der Kamera\n8. Foto zu dunkel',

      'kpi_tip_pod': 'Dies sollte die einfachste Kategorie sein\nZielwert: 100 %\nVerbessert den Gesamt-Score erheblich',

      'kpi_desc_cc': 'CC (Customer Contact)\n\nJe höher der Wert, desto besser.\n\nExtrem wichtig:\nDu musst IMMER eine „Kein sicherer Ablageort“- oder „Adresse nicht gefunden“-Nachricht senden, jedes Mal, wenn du ein Paket nicht zustellen kannst, weil:\n\n- der Kunde nicht zu Hause ist oder\n- die Adresse nicht gefunden werden kann',

      'kpi_tip_cc': 'Für jedes Szenario gibt es eine automatische Standardnachricht in der App.',

      'kpi_desc_ce': 'CE (Customer Escalation)\n\nJe niedriger der Wert, desto besser.\nDie schlechteste Kategorie von allen.\n\nKunden eskalieren, wenn Zustellanweisungen nicht eingehalten werden.\n\nDer Fahrer ist immer verantwortlich\nEinsprüche sind ohne sehr starke Beweise nahezu unmöglich\nHat den stärksten Einfluss auf deine Scorecard\n\nSo vermeidest du CE\n\nEs ist gegen die Zustellrichtlinien, Pakete ohne Genehmigung an unsicheren oder unbeaufsichtigten Orten abzulegen\n\nDelivery Associates müssen:\n- Klingeln / Gegensprechanlage benutzen oder klopfen\n- Dem Kunden ausreichend Zeit zum Antworten geben\n\nWenn der Kunde nicht erreichbar ist und kein sicherer Ablageort hinterlegt wurde:\n- Kunden zweimal anrufen\n- Eine Textnachricht senden\n- Driver Support kontaktieren, wenn kein Kontakt möglich ist\n\nFalls notwendig:\n- Paket scannen als „Zustellung fehlgeschlagen – Kunde nicht verfügbar“\n- Zustellung gemäß Richtlinie erneut versuchen',

      'kpi_tip_ce': 'Keine Pakete an unsicheren oder nicht genehmigten Orten ablegen\nImmer die korrekten Versand- und Zustellprozesse einhalten',

      'kpi_desc_cdf': 'CDF DPMO (Customer Delivery Feedback)\n\nJe niedriger der Wert, desto besser.\n\nLevel 1 (L1)\n- Kunde bewertet die Zustellung als „Großartig“ (👍) oder „Nicht so gut“ (👎)\n\nLevel 2 (L2)\n- Zusätzliche Rückmeldung, warum die Erfahrung gut oder schlecht war',

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

    'faq_q1': 'Was ist bei deiner täglichen Arbeit am wichtigsten?',
    'faq_a1': 'Pakete mit Qualität und gutem Verhalten zuzustellen.',

    'faq_q2': 'Was solltest du bei Problemen mit dem Kunden NICHT tun?',
    'faq_a2': 'Versuche NICHT, die Situation selbst zu lösen, sondern informiere stattdessen den Dispatcher im Dienst. Wir sprechen mit dem Kunden für dich und versuchen, negative Folgen von Amazon durch Kundenbeschwerden zu vermeiden. Wir sind für dich da!',

    'faq_q3': 'Was, wenn die Situation bereits eskaliert ist und der Kunde aus irgendeinem Grund unzufrieden ist?',
    'faq_a3': 'Es ist nie zu spät, Fehler zu korrigieren. Ruf uns trotzdem an und wir versuchen, den Fehler mit dem Kunden zu klären. Besser spät als nie.',

    'faq_q4': 'Was ist wichtiger: Quantität (so schnell wie möglich viele Stopps) oder Qualität?',
    'faq_a4': 'Qualität! Immer Qualität! Folge den Kundenanweisungen und lege das Paket NICHT an unsicheren Orten ab, nur weil du mit den Stopps im Rückstand bist.',

    'faq_q5': 'Was ist, wenn ich mich auf Qualität konzentriere und dadurch mit meinen Stopps in Rückstand gerate?',
    'faq_a5': 'Du wirst deine Stopps beenden – so oder so. Wir versuchen, Hilfe zu schicken, aber nur, wenn wir es für sinnvoll halten.',

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

    'faq_q7_1_1': 'Wie kann ich das vermeiden und wie wichtig ist das für die wöchentliche Scorecard?',
    'faq_a7_1_1': 'Das ist sehr wichtig. Um es zu vermeiden, informiere den Kunden vorher, dass du bald ankommst, und klingele NUR bei dem Klingelschild mit seinem Namen.',

    'faq_q7_1_2': 'Wie vermeide ich Paketverluste?',
    'faq_a7_1_2':
    'Versuche immer, die Pakete dem Kunden persönlich zu übergeben. Wenn das nicht möglich ist, sende eine Nachricht und informiere ihn, wo das Paket abgelegt wurde, z. B. in der Garage, unter der Treppe, im Schuppen, hinter der Blumenvase usw.\n'
    'Wenn du nicht glaubst, dass es sicher ist, das Paket unbeaufsichtigt zu lassen, nimm es bitte lieber wieder mit und versuche es später erneut. Das ist SEHR wichtig.',

    'faq_q7_1_3': 'Woran erkenne ich, ob ein Ort sicher ist oder nicht?',
    'faq_a7_1_3':
    'Instinkt und gesunder Menschenverstand. Wenn ein Gebäude 20–30 Stockwerke hat und du das Paket bei den Briefkästen ablegst, ist die Wahrscheinlichkeit für Diebstahl deutlich höher als bei einem Einfamilienhaus.\n'
    'Außerdem posten wir jeden Morgen ein Bild mit Adressen, bei denen eine hohe Wahrscheinlichkeit für Diebstahl und Kundenbeschwerden besteht – basierend auf bisherigen Zustellungen und Statistiken.',

    'faq_q7_1_4': 'Was passiert, wenn ein Paket verloren geht oder gestohlen wird – wie wirkt sich das auf meinen Score aus?',
    'faq_a7_1_4':
    'Sehr negativ. Das kann dich mit mindestens 30% treffen – und schon ein einziges Paket kann dir mindestens 600 Punkte kosten. Je mehr Punkte du in der Scorecard unter deinem Namen siehst, desto schlechter ist es. Je mehr Pakete du pro Arbeitswoche zustellst, desto weniger Punkte verlierst du pro Vorfall. Die verlorenen Punkte variieren auch je nach Preis des Artikels: Je teurer, desto mehr Punkteverlust.\n'
    'Wichtig ist außerdem: Wenn du regelmäßig eine hohe Anzahl verlorener Pakete hast, müssen wir dich ggf. freistellen, weil Amazon früher oder später Paketdiebstahl vermuten könnte. Das ist sehr gefährlich.',

    // CC
    'faq_q7_2': 'CC-Tab\nContact Compliance',
    'faq_a7_2':
    'Das bedeutet, wie oft du den Kunden wegen seiner Lieferung kontaktierst – per Nachricht oder Anruf. Je weniger du den Kunden kontaktierst, desto weniger Score bekommst du in der Scorecard. Wir sollten diesen Bereich so hoch wie möglich halten, weil er zu den einfachsten Kategorien gehört und dir beim Gesamtscore sehr hilft.',

    'faq_q7_2_1': 'Warum sollte ich das machen?',
    'faq_a7_2_1': 'Pakete zuzustellen ist nicht nur „Drop & Go“. Du solltest den Kunden vorher informieren und fragen, wo er das Paket gerne zugestellt haben möchte.',

    'faq_q7_2_2': 'Wie verbessere ich meinen CC-Score?',
    'faq_a7_2_2': 'Danke für die Frage. Ganz einfach: durch Anrufe und vor allem durch Nachrichten an den Kunden bei jedem Stopp.',

    // CE
    'faq_q7_3': 'CE-Tab\nKundeneskalation',
    'faq_a7_3': 'Du erinnerst dich, wie stark DNR deine Scores beeinflusst? Das hier ist mindestens doppelt so schlimm, und du riskierst auch deinen Job – je nachdem, wie schlimm die Situation war.',

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

    'faq_q7_8': 'Was sollte ich bezüglich der Scorecard im Hinterkopf behalten?',
    'faq_a7_8':
    'Qualität und Effizienz bringen dich weit. Gute Scores sind gut für dich, für die Firma und für das gesamte Team. Kundenzufriedenheit ist sehr wichtig, und gute Scores werden mit einem Bonus der Firma belohnt.\n'
    'Gib dein Bestes, bekomme das Beste.',

    // 8+
    'faq_q8': 'In welchen anderen Bereichen sollte ich vorsichtig sein?',
    'faq_a8':
    'Achte auf dich selbst: Fahre sicher, vermeide Verletzungen und vermeide Hunde bzw. Hundebisse. Sei vorsichtig mit Arbeitsausrüstung wie dem täglichen Fahrzeug, dem Arbeitsscanner/Telefon und komme zur Arbeit mit Sicherheitsschuhen und Sicherheitsweste sowie Amazon-Jacke oder T-Shirt (je nach Wetter).',

    'faq_q9': 'Was passiert, wenn ich einen Unfall habe oder das Arbeitsfahrzeug beschädige?',
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

    'faq_q12': 'Warum sagen wir dir immer wieder, du sollst langsamer machen und nicht schneller fahren?',
    'faq_a12':
    'Uns gefällt das auch nicht, aber so funktioniert das System. Wir müssen dem Algorithmus folgen und eine vorgegebene Anzahl Stopps pro Stunde einhalten, damit wir in Zukunft mehr Routen bekommen und du mehr arbeiten kannst statt frei zu haben.\n'
    'Außerdem riskierst du durch zu schnelles Arbeiten einen DNR und verlierst Punkte – sowohl für dich als auch für die Firma – in der wöchentlichen Scorecard.',

    'faq_q13': 'Warum fragen dich die Dispatcher manchmal, warum du zurückliegst und ob etwas nicht stimmt?',
    'faq_a13':
    'Wir wissen, dass das unangenehm ist, aber wir brauchen Feedback, was auf der Straße passiert ist, sodass du mit deinen Stopps in Rückstand geraten bist. Amazon fragt uns nach diesem Feedback, weil es auch ein Zeitlimit gibt, bis zu dem du X Stopps erledigt haben solltest. Mit diesen Informationen kann Amazon zukünftige Zustelleffizienz verbessern.',

    'faq_q14': 'Warum bitten wir dich manchmal, einem Kollegen zu helfen?',
    'faq_a14':
    'Weil viele Faktoren eine Rolle spielen können, warum ein Kollege zurückliegt – z. B. schlechte Internetverbindung, Verkehr, gesperrte Straßen durch Baustellen. Dann wird deine Hilfe benötigt.',

    'faq_q15': 'Beginne ich am ersten Tag sofort mit Standard-Routen wie erfahrene Fahrer?',
    'faq_a15':
    'Nein, natürlich nicht. Am Anfang hast du eine Phase von 14 Arbeitstagen, um das Gelernte aus den Ride-Along-Tagen mit deinem Trainer umzusetzen und dich an Gebiet, Fahrzeug, Scanner und Workflow zu gewöhnen.\n'
    'In dieser Zeit gibt Amazon dir bis zu 50% weniger Pakete und Stopps als normal.',

    'faq_q16': 'Was tun, wenn eine Adresse falsch ist und/oder der Standort-Pin auf der Karte nicht stimmt?',
    'faq_a16':
    'Bestätige zuerst, dass der Pin nicht stimmt, indem du die Adresse in Google Maps suchst (ist genauer und auf deinem Scanner installiert). Wenn es nicht passt, informiere den Dispatcher im Dienst über die Fehler.',

    'faq_q17': 'Was sind meine täglichen Aufgaben, bevor ich starte und nachdem ich die Arbeit beende?',
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

    'faq_q18': 'Muss ich etwas beachten, wenn ich das Fahrzeug wechsle und ein anderes nehme als sonst?',
    'faq_a18':
    'Du solltest ein Video machen, das jeden kleinen Schaden im Detail zeigt, den der/die Fahrer vor dir verursacht haben könnten, damit es bei der nächsten Kontrolle nicht als dein Fehler gilt.',

    'faq_q19': 'Was tun, wenn die Flex-App ständig lädt und meinen Workflow verlangsamt?',
    'faq_a19':
    'Prüfe zuerst, ob du eine aktive Internetverbindung hast. Das kannst du testen, indem du dem Kunden am aktuellen Stopp eine Nachricht schickst. Wenn sie durchgeht, ist das Internet aktiv. Du kannst auch eine andere App öffnen (z. B. Browser) und etwas suchen.\n'
    'Schritte, wenn keine aktive Internetverbindung besteht:\n'
    '1- Scanner neu starten. Das sollte immer das Erste sein.\n'
    '2- Flugmodus ein/aus. Das funktioniert oft, ohne auf einen Neustart zu warten.\n'
    '3- Als allerletzte Option: Teile maximal 10 Minuten Hotspot von deinem privaten Handy, damit sich das System aktualisieren kann.\n'
    'Du kannst auch offline arbeiten, aber irgendwann musst du wieder online sein. Um offline zu arbeiten, musst du zuerst Offline-Karten in der Flex App herunterladen: Settings – Offline Maps (letzte Option) – Download DBY5 – Allow downloads with mobile connection.\n',

    'faq_q20': 'Was, wenn die Internetverbindung aktiv ist, die Flex-App aber trotzdem nicht richtig funktioniert?',
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
      'select_language': 'Zgjidh gjuhën',
      'notifications': 'Njoftime',
      'no_notifications': 'Nuk ka njoftime',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Ndihmë',
      'nav_rules': 'Rregulla',
      'nav_profile': 'Profil',
      'change_profile_photo': 'Ndrysho foton e profilit',
      'profile_change_photo': 'Ndrysho foton e profilit',
      'logout': 'Dil',
      'profile_logout': 'Dil',
      'pin_change_with_old': 'Mund ta ndryshosh PIN-in pasi të verifikosh PIN-in e vjetër.',
      'pin_forgot_contact_admin': 'Ke harruar PIN-in? Kontakto administratorin.',
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

      'kpi_title_dcr': 'Shkalla e Suksesit të Dorëzimit',
        'kpi_title_dnr': 'Kushtet e Suksesit të Dorëzimit',
        'kpi_title_lor': 'Humbur Gjatë Rrugës',
        'kpi_title_pod': 'Foto gjatë Dorëzimit',
        'kpi_title_cc': 'Kontakt me Klientin',
        'kpi_title_ce': 'Përshkallëzim nga Klienti',
        'kpi_title_cdf': 'Vlerësimi i Dorëzimit nga Klienti',

        'kpi_desc_dcr': 'Sa më e lartë vlera, aq më mirë. Për të arritur një shkallë suksesi 100%, rekomandohet të bëhet një përpjekje për ridorëzim* pas një dorëzimi të pasuksesshëm.',
        'kpi_tip_dcr': 'Shembull: Nëse nuk mund të dorëzosh një paketë gjatë një dite për çfarëdo arsye dhe provon ta dorëzosh sërish më vonë po atë ditë, vlera jote DCR do të jetë më e lartë dhe më afër 100%, edhe nëse përpjekja e dytë e dorëzimit është gjithashtu e pasuksesshme.',

        'kpi_desc_dnr': 'DSC DPMO (Kushtet e Suksesit të Dorëzimit)\n(më parë DNR – Dorëzim i Pa Marrë)\n\nSa më e ulët vlera, aq më mirë.\n\nKjo metrikë mat se sa saktë dhe në mënyrë të gjurmueshme kryhen dorëzimet.\n\nRregullat bazë të dorëzimit:\n- Dorëzim te personi i saktë ose në vendin e saktë\n- Dorëzimet te klientët, anëtarët e familjes, fqinjët ose recepsionistët janë me rrezik të ulët kur kryhen saktë\n- Përdor gjithmonë kodin e saktë të skanimit/arsyes në mënyrë që klientët të marrin njoftime të sakta\n\nDorëzime në dhomë poste / kuti postare:\n- Ndiq rrjedhën standarde të punës\n- Paketat duhet të jenë plotësisht brenda kutisë postare ose hapjes postare dhe nuk duhet të dalin jashtë\n- Përdor skanimin më të saktë të disponueshëm\n\nAdresë e saktë & Geofence:\n- Dorëzim brenda 25 metrave nga geofence i saktë\n- Gjithmonë përputh emrin dhe adresën në aplikacion me etiketën e paketës dhe ndërtesën\n- Nëse geokodi duket i pasaktë, raportoje përmes SDS\n\nFoto gjatë dorëzimit (POD):\n- Gjithmonë bëj një foto të qartë kur kërkohet\n- Paketa dhe ambienti përreth duhet të jenë qartë të dukshme\n- Veçanërisht e rëndësishme për dorëzime pa mbikëqyrje dhe për besimin e klientit\n\nRespekto preferencat e dorëzimit:\n- Ndiq udhëzimet e klientit në aplikacion nëse janë të sigurta\n- Nëse udhëzimet janë të pasigurta, kontakto klientin\n- Përdor vetëm vendet e sigurta të miratuara nga aplikacioni\n\nNdalesa të njëkohshme / në grup:\n- Përdor “Zgjidh të gjitha” vetëm kur disa paketa dorëzohen te i njëjti person ose në të njëjtin vend (p.sh. recepsion)\n- Regjistro saktë emrin e marrësit dhe nënshkrimin',

        'kpi_tip_dnr': 'Njoftim i rëndësishëm:\n\nVlera të larta të përsëritura në DSC DPMO tregojnë dorëzime të pasakta ose të rrezikshme.\n\n- Devijimet e shpeshta mund të interpretohen nga Amazon si vjedhje e mundshme\n- Kjo mund të aktivizojë një proces parandalimi humbjesh\n- Në rastin më të keq, kjo mund të çojë në përfundimin e bashkëpunimit\n\nSkanime të kujdesshme, foto të sakta dhe respektimi i të gjitha rregullave të dorëzimit të mbrojnë ty dhe ekipin tënd.',

        'kpi_desc_lor': 'LoR (Humbur Gjatë Rrugës)\n\nSa më e ulët vlera, aq më mirë.\n\nKjo metrikë tregon nëse të gjitha paketat e pa dorëzuara janë regjistruar saktë në fund të itinerarit.\n\nNë fund të itinerarit:\n- Kontrollo në skaner sa paketa duhet të kthehen\n- Sigurohu që ky numër përputhet saktësisht me paketat në automjet',

        'kpi_tip_lor': 'Njoftim i rëndësishëm:\n\nKjo është kategoria me dyshimin më të lartë për vjedhje.\n\nMospërputhjet midis skanerit dhe inventarit të automjetit mund të konsiderohen gabime serioze dhe mund të çojnë në hetime të brendshme ose pasoja të tjera.',

        'kpi_desc_pod': 'PoD (Foto gjatë Dorëzimit)\n\nSa më e lartë vlera, aq më mirë.\n\nKjo kolonë tregon paketat për të cilat është bërë një foto, por që janë shënuar si të Pavlefshme ose të Pasigurta.\n\nArsyet e zakonshme për refuzimin e POD:\n1. Etiketa e paketës me të dhëna të klientit e dukshme (paketa duhet të kthehet)\n2. Foto e paqartë\n3. Person i dukshëm në foto\n4. Asnjë paketë e dukshme në foto\n5. Paketa brenda automjetit\n6. Paketa në dorë\n7. Paketa shumë afër kamerës\n8. Foto shumë e errët',

        'kpi_tip_pod': 'Kjo duhet të jetë kategoria më e thjeshtë\nVlera e synuar: 100%\nPërmirëson ndjeshëm rezultatin e përgjithshëm',

        'kpi_desc_cc': 'CC (Kontakt me Klientin)\n\nSa më e lartë vlera, aq më mirë.\n\nJashtëzakonisht e rëndësishme:\nDuhet GJITHMONË të dërgosh një mesazh “Nuk ka vend të sigurt” ose “Adresa nuk u gjet”, çdo herë që nuk mund të dorëzosh një paketë sepse:\n\n- klienti nuk është në shtëpi ose\n- adresa nuk mund të gjendet',

        'kpi_tip_cc': 'Ekziston një mesazh standard automatik në aplikacion për çdo skenar.',

        'kpi_desc_ce': 'CE (Përshkallëzim nga Klienti)\n\nSa më e ulët vlera, aq më mirë.\nKategoria më e keqe nga të gjitha.\n\nKlientët përshkallëzojnë kur udhëzimet e dorëzimit nuk respektohen.\n\nShoferi është gjithmonë përgjegjës\nAnkesat janë pothuajse të pamundura pa prova shumë të forta\nKa ndikimin më të fortë në Scorecard-in tënd\n\nSi të shmangësh CE\n\nËshtë kundër udhëzimeve të dorëzimit të lësh paketat në vende të pasigurta ose të pambikëqyrura pa miratim\n\nDelivery Associates duhet:\n- Të bien zilen / të përdorin interfonin ose të trokasin\n- T’i japin klientit kohë të mjaftueshme për t’u përgjigjur\n\nNëse klienti nuk mund të kontaktohet dhe nuk është regjistruar asnjë vend i sigurt:\n- Të telefonojnë klientin dy herë\n- Të dërgojnë një mesazh me tekst\n- Të kontaktojnë Driver Support nëse nuk është i mundur kontakti\n\nNëse është e nevojshme:\n- Të skanojnë paketën si “Dorëzim i dështuar – klienti i padisponueshëm”\n- Të provojnë sërish dorëzimin sipas udhëzimeve',

        'kpi_tip_ce': 'Mos i lër paketat në vende të pasigurta ose të pamiratuara\nRespekto gjithmonë proceset e sakta të dërgimit dhe dorëzimit',

        'kpi_desc_cdf': 'CDF DPMO (Vlerësimi i Dorëzimit nga Klienti)\n\nSa më e ulët vlera, aq më mirë.\n\nNiveli 1 (L1)\n- Klienti e vlerëson dorëzimin si “Shkëlqyeshëm” (👍) ose “Jo aq mirë” (👎)\n\nNiveli 2 (L2)\n- Reagim shtesë pse përvoja ishte e mirë ose e keqe',

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

    'faq_q1': 'Cila është gjëja më e rëndësishme në detyrën tënde të përditshme?',
    'faq_a1': 'Dërgimi i paketave me cilësi dhe me sjellje të mirë.',

    'faq_q2': 'Çfarë nuk duhet të bësh në rast problemesh me klientin?',
    'faq_a2': 'MOS u përpiq ta zgjidhësh situatën vetë; informo dispatcher-in në detyrë. Ne do të flasim me klientin për ty dhe do të përpiqemi të shmangim pasojat negative nga Amazon për shkak të ankesave. Jemi këtu për ty!',

    'faq_q3': 'Po nëse situata tashmë ka eskaluar dhe klienti nuk është i kënaqur për çfarëdo që ka ndodhur?',
    'faq_a3': 'Nuk është kurrë vonë për të rregulluar gabimet. Na telefono gjithsesi dhe do të përpiqemi ta rregullojmë me klientin. Më mirë vonë se kurrë.',

    'faq_q4': 'Çfarë është më e rëndësishme: Sasia (shpejtësia për të dorëzuar sa më shumë ndalesa) apo Cilësia?',
    'faq_a4': 'Cilësia! Gjithmonë cilësia! Ndiq udhëzimet e klientit dhe MOS e lër paketën në vende të pasigurta vetëm sepse je mbrapa me ndalesat.',

    'faq_q5': 'Po nëse fokusohem te cilësia, por pastaj mbetem mbrapa me ndalesat?',
    'faq_a5': 'Do t’i përfundosh ndalesat, në një mënyrë ose në një tjetër. Do të përpiqemi të dërgojmë ndihmë, por vetëm nëse e shohim të arsyeshme.',

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

    'faq_q7_1_1': 'Si ta shmang këtë dhe sa e rëndësishme është për scorecard-in javor?',
    'faq_a7_1_1': 'Është shumë e rëndësishme. Për ta shmangur, thjesht njofto klientin paraprakisht që po afrohesh dhe bjeri ziles VETËM te emri i tij në zile.',

    'faq_q7_1_2': 'Si t’i shmang humbjet e paketave?',
    'faq_a7_1_2':
    'Gjithmonë përpiqu t’ia dorëzosh paketat në dorë klientit. Nëse kjo nuk është e mundur, dërgo një mesazh duke e informuar se ku u la paketa, p.sh. në garazh, nën shkallë, në kasolle, pas vazos së luleve, etj.\n'
    'Nëse mendon se nuk është e sigurt ta lësh paketën pa mbikëqyrje, më mirë merre dhe provo përsëri më vonë. Kjo është SHUMË e rëndësishme.',

    'faq_q7_1_3': 'Si ta di nëse një vend është i sigurt apo jo?',
    'faq_a7_1_3':
    'Instinkti dhe logjika. Nëse një ndërtesë ka 20–30 kate dhe ti e lë paketën te kutitë postare, shanset për vjedhje janë shumë më të larta krahasuar me një shtëpi private.\n'
    'Gjithashtu, për të të ndihmuar në dorëzimet e përditshme dhe për të shmangur DNR, çdo mëngjes do të postojmë një foto me adresa ku ka rrezik të lartë për vjedhje dhe ankesa, bazuar në rezultatet dhe statistikat e mëparshme.',

    'faq_q7_1_4': 'Po nëse një paketë humbet ose vidhet, si ndikon kjo në rezultatin tim?',
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
    'faq_a7_2_1': 'Dorëzimi i paketave nuk është vetëm “Drop&Go”. Duhet ta njoftosh klientin paraprakisht dhe ta pyesësh se ku do të donte të dorëzohej paketa.',

    'faq_q7_2_2': 'Si ta përmirësoj rezultatin tim CC?',
    'faq_a7_2_2': 'Faleminderit që pyete. Shumë thjesht: duke telefonuar dhe sidomos duke dërguar mesazhe klientëve në çdo ndalesë.',

    // CE
    'faq_q7_3': 'Skeda CE\nCustomer Escalation',
    'faq_a7_3': 'Të kujtohet sa keq ndikoi DNR në rezultatet? Kjo është të paktën 2 herë më e keqe dhe rrezikon edhe vendin e punës, sepse varet sa e rëndë ishte situata.',

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

    'faq_q12': 'Pse vazhdojmë të të themi të ngadalësosh dhe të mos shkosh më shpejt?',
    'faq_a12':
    'As neve nuk na pëlqen, por kështu funksionon sistemi. Duhet të ndjekim algoritmin dhe të bëjmë një numër ndalesash për orë siç është paracaktuar, që të marrim më shumë rrugë në të ardhmen dhe ti të kesh më shumë punë e jo të jesh i lirë.\n'
    'Gjithashtu, duke shkuar më shpejt rrezikon të marrësh DNR dhe të humbësh pikë si për veten, ashtu edhe për kompaninë në scorecard-in javor.',

    'faq_q13': 'Atëherë pse dispatcher-at ndonjëherë më pyesin pse je mbrapa dhe nëse ka diçka që nuk shkon?',
    'faq_a13':
    'E dimë që nuk është e këndshme, por na duhet feedback se çfarë mund të ketë ndodhur rrugës që të ka bërë të mbetesh mbrapa me ndalesat. Amazon na e kërkon këtë feedback sepse ka edhe një afat kohor ku duhet të kesh dorëzuar X ndalesa; prandaj Amazon duhet të dijë pse ndalesat e mbetura janë mbrapa planit, për të përmirësuar efikasitetin e ardhshëm.',

    'faq_q14': 'Pse ndonjëherë të kërkojmë të shkosh të ndihmosh një koleg?',
    'faq_a14':
    'Sepse shumë faktorë ndikojnë në vonesën e kolegut, si lidhje e dobët interneti në zonë, trafik, rrugë të bllokuara nga punime, që e bëjnë të vështirë dorëzimin në kohë. Prandaj nevojitet ndihma jote.',

    'faq_q15': 'A filloj që në ditën e parë të dorëzoj paketa në ruter standard si shoferët më me përvojë?',
    'faq_a15':
    'Jo, sigurisht që jo. Në fillim ke një periudhë prej 14 ditësh pune për të vënë në praktikë atë që ke mësuar në ditët “ride-along” me trajnerin dhe për t’u përshtatur me zonën, furgonin, scanner-in dhe procesin e punës.\n'
    'Gjatë kësaj periudhe 14-ditore, Amazon do të të japë deri në 50% më pak paketa dhe ndalesa se normalisht.',

    'faq_q16': 'Çfarë të bëj kur një adresë është e gabuar dhe/ose pini i vendndodhjes nuk është i saktë në hartë?',
    'faq_a16': 'Së pari konfirmo që pini nuk është i saktë duke kërkuar adresën në Google Maps (është më i saktë dhe është i instaluar në scanner). Nëse nuk përputhet, njofto dispatcher-in në detyrë për gabimet.',

    'faq_q17': 'Cilat janë detyrat e mia të përditshme para se të filloj dhe pasi të mbaroj punën?',
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

    'faq_q18': 'A duhet të bëj diçka kur ndërroj furgonin dhe marr një tjetër në vend të atij që përdor zakonisht?',
    'faq_a18': 'Duhet të bësh një video që tregon me detaje çdo dëmtim të vogël që mund të kenë bërë shoferët para teje, që të mos jetë faji yt në inspektimin e ardhshëm.',

    'faq_q19': 'Çfarë të bëj nëse Flex App është gjithmonë duke u ngarkuar dhe po ma ngadalëson punën?',
    'faq_a19':
    'Së pari kontrollo nëse ke lidhje aktive interneti. Mund ta provosh duke dërguar një mesazh te klienti i ndalesës aktuale; nëse shkon, atëherë interneti është aktiv. Mund ta kontrollosh edhe duke hapur një aplikacion tjetër, p.sh. browser-in.\n'
    'Hapat nëse NUK ka lidhje aktive interneti:\n'
    '1- Rinise scanner-in. Kjo duhet të jetë gjithmonë gjëja e parë.\n'
    '2- Aktivizo/çaktivizo airplane mode. Shpesh funksionon pa pritur rinisjen.\n'
    '3- Si zgjidhje e fundit, përdor hotspot nga telefoni personal për maksimum 10 minuta, vetëm sa të rifreskohet sistemi.\n'
    'Mund të punosh edhe offline, por në një moment duhet të lidhet interneti. Për offline duhet të shkarkosh offline maps në Flex App: Settings – Offline Maps (opsioni i fundit) – Download DBY5 – Allow downloads with mobile connection.\n',

    'faq_q20': 'Po nëse interneti është aktiv, por Flex App prapë nuk punon siç duhet?',
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
      'select_language': 'Nyelv kiválasztása',
      'notifications': 'Értesítések',
      'no_notifications': 'Nincs értesítés',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Súgó',
      'nav_rules': 'Szabályok',
      'nav_profile': 'Profil',
      'change_profile_photo': 'Profilkép módosítása',
      'profile_change_photo': 'Profilkép módosítása',
      'logout': 'Kijelentkezés',
      'profile_logout': 'Kijelentkezés',
      'pin_change_with_old': 'A PIN módosításához add meg a régi PIN-t.',
      'pin_forgot_contact_admin': 'Elfelejtetted a PIN-t? Vedd fel a kapcsolatot az adminnal.',
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

        'kpi_title_dcr': 'Kézbesítési Sikerességi Arány',
        'kpi_title_dnr': 'Kézbesítési Sikerfeltételek',
        'kpi_title_lor': 'Útközben Elveszett',
        'kpi_title_pod': 'Kézbesítéskori Fénykép',
        'kpi_title_cc': 'Ügyfélkapcsolat',
        'kpi_title_ce': 'Ügyfél Eszkaláció',
        'kpi_title_cdf': 'Ügyfél Kézbesítési Visszajelzés',

        'kpi_desc_dcr': 'Minél magasabb az érték, annál jobb. A 100%-os sikerességi arány eléréséhez ajánlott sikertelen kézbesítés után újrakézbesítést* megkísérelni.',
        'kpi_tip_dcr': 'Példa: Ha egy adott napon bármilyen okból nem tudsz kézbesíteni egy csomagot, és még ugyanazon a napon újra megpróbálod a kézbesítést, a DCR értéked magasabb lesz és közelebb kerül a 100%-hoz, még akkor is, ha a második kézbesítési kísérlet sem sikeres.',

        'kpi_desc_dnr': 'DSC DPMO (Kézbesítési Sikerfeltételek)\n(korábban DNR – Kézbesítés nem történt meg)\n\nMinél alacsonyabb az érték, annál jobb.\n\nEz a mutató azt méri, hogy a kézbesítések mennyire helyesen és nyomon követhetően történnek.\n\nAlapvető kézbesítési szabályok:\n- Kézbesítés a megfelelő személynek vagy a megfelelő helyre\n- Ügyfeleknek, háztartás tagjainak, szomszédoknak vagy recepciósoknak történő kézbesítés megfelelő végrehajtás esetén alacsony kockázatú\n- Mindig a megfelelő szkennelési/indok kódot használd, hogy az ügyfelek helyes értesítéseket kapjanak\n\nPostaszoba / postaláda kézbesítések:\n- Kövesd a szabványos munkafolyamatot\n- A csomagoknak teljes egészében a postaládában vagy a postanyílásban kell lenniük, és nem lóghatnak ki\n- A lehető legpontosabb szkennelést használd\n\nHelyes cím és geofence:\n- Kézbesítés a megfelelő geofence 25 méteres körzetén belül\n- Az alkalmazásban szereplő nevet és címet mindig egyeztesd a csomagcímkével és az épülettel\n- Ha a geokód helytelennek tűnik, jelentsd SDS-en keresztül\n\nFénykép kézbesítéskor (POD):\n- Mindig készíts tiszta fényképet, amikor erre felszólítanak\n- A csomagnak és a környezetnek jól láthatónak kell lennie\n- Különösen fontos felügyelet nélküli kézbesítések és az ügyfélbizalom szempontjából\n\nKézbesítési preferenciák betartása:\n- Kövesd az alkalmazásban megadott ügyfélutasításokat, amennyiben azok biztonságosak\n- Ha az utasítások nem biztonságosak, vedd fel a kapcsolatot az ügyféllel\n- Csak az alkalmazásban jóváhagyott biztonságos helyeket használd\n\nEgyidejű / csoportos megállók:\n- A „Mind kijelölése” funkciót csak akkor használd, ha több csomagot ugyanannak a személynek vagy ugyanarra a helyre kézbesítesz (pl. recepció)\n- A címzett nevét és aláírását pontosan rögzítsd',

        'kpi_tip_dnr': 'Fontos figyelmeztetés:\n\nAz ismételten magas DSC DPMO értékek helytelen vagy kockázatos kézbesítésekre utalnak.\n\n- A gyakori eltéréseket az Amazon potenciális lopásként értelmezheti\n- Ez veszteségmegelőzési eljárást indíthat el\n- A legrosszabb esetben az együttműködés megszüntetéséhez vezethet\n\nA gondos szkennelések, a megfelelő fényképek és az összes kézbesítési szabály betartása megvéd téged és a csapatodat.',

        'kpi_desc_lor': 'LoR (Útközben Elveszett)\n\nMinél alacsonyabb az érték, annál jobb.\n\nEz a mutató azt mutatja, hogy az út végén minden nem kézbesített csomag helyesen lett-e rögzítve.\n\nAz út végén:\n- Ellenőrizd a szkennerben, hány csomagot kell visszavinni\n- Győződj meg róla, hogy ez a szám pontosan megegyezik a járműben lévő csomagok számával',

        'kpi_tip_lor': 'Fontos figyelmeztetés:\n\nEz a kategória a legnagyobb lopásgyanúval jár.\n\nA szkenner és a jármű készlete közötti eltérések súlyos hibának minősülhetnek, és belső vizsgálatokhoz vagy további következményekhez vezethetnek.',

        'kpi_desc_pod': 'PoD (Kézbesítéskori Fénykép)\n\nMinél magasabb az érték, annál jobb.\n\nEz az oszlop azokat a csomagokat mutatja, amelyekről készült fénykép, de Érvénytelen vagy Nem biztonságos jelölést kaptak.\n\nA POD elutasításának gyakori okai:\n1. A csomagcímkén láthatók az ügyfél adatai (a csomagot meg kell fordítani)\n2. Elmosódott fénykép\n3. Személy látható a fényképen\n4. Nem látható csomag a fényképen\n5. Csomag a járműben\n6. Csomag kézben\n7. A csomag túl közel van a kamerához\n8. A fénykép túl sötét',

        'kpi_tip_pod': 'Ez kell legyen a legegyszerűbb kategória\nCélérték: 100%\nJelentősen javítja az összpontszámot',

        'kpi_desc_cc': 'CC (Ügyfélkapcsolat)\n\nMinél magasabb az érték, annál jobb.\n\nRendkívül fontos:\nMINDIG küldened kell egy „Nincs biztonságos hely” vagy „Cím nem található” üzenetet minden alkalommal, amikor nem tudsz kézbesíteni egy csomagot, mert:\n\n- az ügyfél nincs otthon vagy\n- a cím nem található',

        'kpi_tip_cc': 'Minden forgatókönyvre létezik automatikus alapértelmezett üzenet az alkalmazásban.',

        'kpi_desc_ce': 'CE (Ügyfél Eszkaláció)\n\nMinél alacsonyabb az érték, annál jobb.\nA legrosszabb kategória mind közül.\n\nAz ügyfelek akkor eszkalálnak, ha a kézbesítési utasításokat nem tartják be.\n\nA sofőr mindig felelős\nFellebbezések nagyon erős bizonyítékok nélkül szinte lehetetlenek\nA legerősebb hatással van a Scorecardodra\n\nHogyan kerüld el a CE-t\n\nA kézbesítési irányelvek ellen van, ha engedély nélkül nem biztonságos vagy felügyelet nélküli helyeken hagyod a csomagokat\n\nA Delivery Associates kötelesek:\n- Csengetni / kaputelefont használni vagy kopogni\n- Elegendő időt adni az ügyfélnek a válaszadásra\n\nHa az ügyfél nem érhető el, és nincs rögzítve biztonságos hely:\n- Az ügyfelet kétszer felhívni\n- Szöveges üzenetet küldeni\n- Driver Supporttal kapcsolatba lépni, ha nincs lehetőség kapcsolatra\n\nSzükség esetén:\n- A csomagot „Sikertelen kézbesítés – ügyfél nem elérhető” státusszal szkennelni\n- Az irányelveknek megfelelően újrapróbálni a kézbesítést',

        'kpi_tip_ce': 'Ne hagyj csomagokat nem biztonságos vagy nem jóváhagyott helyeken\nMindig tartsd be a helyes szállítási és kézbesítési folyamatokat',

        'kpi_desc_cdf': 'CDF DPMO (Ügyfél Kézbesítési Visszajelzés)\n\nMinél alacsonyabb az érték, annál jobb.\n\n1. szint (L1)\n- Az ügyfél a kézbesítést „Nagyszerű” (👍) vagy „Nem olyan jó” (👎) értékeléssel látja el\n\n2. szint (L2)\n- További visszajelzés arról, miért volt a tapasztalat jó vagy rossz',

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

    'faq_q1': 'Mi a legfontosabb a napi feladatod során?',
    'faq_a1': 'A csomagok minőségi kézbesítése és a megfelelő viselkedés.',

    'faq_q2': 'Mit NE tegyél, ha problémád van az ügyféllel?',
    'faq_a2': 'NE próbáld meg egyedül kezelni a helyzetet, hanem értesítsd a szolgálatos diszpécsert. Mi megpróbálunk az ügyféllel beszélni helyetted, és elkerülni az Amazon felől érkező negatív következményeket az ügyfélpanaszok miatt. Itt vagyunk neked!',

    'faq_q3': 'Mi van akkor, ha a helyzet már elmérgesedett, és az ügyfél valami miatt nem elégedett?',
    'faq_a3': 'Soha nincs túl késő kijavítani a hibákat. Hívj minket akkor is, és megpróbáljuk rendezni a helyzetet az ügyféllel. Jobb későn, mint soha.',

    'faq_q4': 'Mi a fontosabb: Mennyiség (minél gyorsabban minél több megálló) vagy Minőség?',
    'faq_a4': 'Minőség! Mindig minőség! Kövesd az ügyfél utasításait, és NE hagyd a csomagot nem biztonságos helyen csak azért, mert le vagy maradva a megállókkal.',

    'faq_q5': 'Mi van, ha a minőségre figyelek, de emiatt lemaradok a megállókkal?',
    'faq_a5': 'Be fogod fejezni a megállókat, valahogy. Megpróbálunk segítséget küldeni, de csak akkor, ha ezt ésszerűnek látjuk.',

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

    'faq_q7_1_1': 'Hogyan kerülhetem el ezt, és mennyire fontos ez a heti scorecardban?',
    'faq_a7_1_1': 'Nagyon fontos. Ennek elkerüléséhez előre értesítsd az ügyfelet, hogy hamarosan érkezel, és CSAK annál a csengőnél csengess, amelyen az ő neve szerepel.',

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

    'faq_q7_1_4': 'Mi van, ha egy csomag elveszik vagy ellopják? Hogyan hat ez a pontszámomra?',
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
    'faq_a7_2_1': 'A csomagkézbesítés nem csak „lerak és kész”. Előre tájékoztasd az ügyfelet, és kérdezd meg, hova szeretné, hogy a csomag kerüljön.',

    'faq_q7_2_2': 'Hogyan javíthatom a CC pontszámomat?',
    'faq_a7_2_2': 'Köszönjük a kérdést. Egyszerű: hívással, és különösen üzenetküldéssel szinte minden megállónál.',

    // CE
    'faq_q7_3': 'CE fül\nÜgyfél-eszkaláció',
    'faq_a7_3': 'Emlékszel, milyen rosszul hatott a DNR a pontszámodra? Ez legalább kétszer olyan rossz, és akár az állásodat is kockáztatod – attól függően, mennyire súlyos volt a helyzet.',

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

    'faq_q9': 'Mi történik, ha balesetet okozok vagy megsértem a munkajárművet?',
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

    'faq_q13': 'A diszpécserek miért kérdezik néha, hogy miért vagy lemaradva, és hogy van-e valami probléma?',
    'faq_a13':
    'Tudjuk, hogy ez nem kellemes, de szükségünk van visszajelzésre, mi történt az úton, ami miatt lemaradtál a megállókkal. '
    'Amazon ezt a visszajelzést kéri tőlünk, mert időlimit is van, ameddig X megállót teljesítened kellett volna. Ezek az információk segítenek az Amazonnak a jövőbeli kézbesítési hatékonyság javításában.',

    'faq_q14': 'Miért kérjük néha, hogy menj és segíts egy kollégának?',
    'faq_a14':
    'Mert sok tényező okozhat késést: rossz internet a környéken, forgalom, útlezárások/építkezések, amelyek megnehezítik az időben történő kézbesítést. Ilyenkor szükség van a segítségedre.',

    'faq_q15': 'Az első napomon rögtön ugyanazokat a standard útvonalakat kapom, mint a tapasztalt sofőrök?',
    'faq_a15':
    'Nem, természetesen nem. Kezdetben 14 munkanapos időszakod van, hogy a trénerrel töltött ride-along napokon tanultakat gyakorold, '
    'és hozzászokj a területhez, az autóhoz, a scannerhez és a munkafolyamathoz.\n'
    'Ebben a 14 napban az Amazon akár 50%-kal kevesebb csomagot és megállót ad a szokásosnál.',

    'faq_q16': 'Mit tegyek, ha rossz a cím és/vagy a térképen nem jó a helyszín-pin?',
    'faq_a16':
    'Először ellenőrizd, hogy a pin tényleg rossz-e: keresd meg a címet Google Maps-ben (pontosabb, és a scannereden is telepítve van). '
    'Ha nem egyezik, jelezd a szolgálatos diszpécsernek a hibát.',

    'faq_q17': 'Mik a napi feladataim a munka kezdése előtt és a munka végén?',
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

    'faq_q18': 'Kell-e bármit csinálnom, ha furgont cserélek, és nem a megszokottat viszem?',
    'faq_a18':
    'Készíts róla videót, amely részletesen mutatja az összes apró sérülést, amit az előző sofőr(ök) okozhattak, hogy a következő ellenőrzésnél ne téged hibáztassanak.',

    'faq_q19': 'Mit tegyek, ha a Flex app folyamatosan tölt, és lelassítja a munkafolyamatot?',
    'faq_a19':
    'Először ellenőrizd, hogy van-e aktív internetkapcsolat. Ezt úgy tudod tesztelni, hogy üzenetet küldesz az aktuális megállónál lévő ügyfélnek. '
    'Ha átmegy, akkor van internet. Ezt úgy is ellenőrizheted, hogy megnyitsz egy másik appot (pl. böngésző), és keresel valamit.\n'
    'Lépések, ha nincs aktív internet:\n'
    '1- Indítsd újra a scannert. Ez legyen mindig az első.\n'
    '2- Kapcsold be/ki a repülő módot. Ez gyakran működik újraindítás nélkül is.\n'
    '3- Utolsó lehetőségként ossz meg hotspotot a saját telefonodról legfeljebb 10 percre, hogy a rendszer frissíteni tudjon.\n'
    'Offline is dolgozhatsz, de egy ponton újra csatlakoznod kell. Offline munkához előbb le kell töltened az offline térképeket a Flex appban: Settings – Offline Maps (utolsó opció) – Download DBY5 – Allow downloads with mobile connection.\n',

    'faq_q20': 'Mi van, ha van internet, de a Flex app mégsem működik rendesen?',
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
      'select_language': 'Selectează limba',
      'notifications': 'Notificări',
      'no_notifications': 'Nu există notificări',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Ajutor',
      'nav_rules': 'Reguli',
      'nav_profile': 'Profil',
      'change_profile_photo': 'Schimbă poza de profil',
      'profile_change_photo': 'Schimbă poza de profil',
      'logout': 'Deconectare',
      'profile_logout': 'Deconectare',
      'pin_change_with_old': 'Poți schimba PIN-ul după verificarea celui vechi.',
      'pin_forgot_contact_admin': 'Ai uitat PIN-ul? Contactează administratorul.',
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

      'kpi_title_dcr': 'Rata de Succes a Livrării',
        'kpi_title_dnr': 'Condițiile de Succes ale Livrării',
        'kpi_title_lor': 'Pierdut pe Traseu',
        'kpi_title_pod': 'Fotografie la Livrare',
        'kpi_title_cc': 'Contact cu Clientul',
        'kpi_title_ce': 'Escaladare de la Client',
        'kpi_title_cdf': 'Feedback-ul Clientului privind Livrarea',

        'kpi_desc_dcr': 'Cu cât valoarea este mai mare, cu atât mai bine. Pentru a atinge o rată de succes de 100%, se recomandă efectuarea unei încercări de relivrare* după o livrare eșuată.',
        'kpi_tip_dcr': 'Exemplu: Dacă într-o zi nu poți livra un colet din orice motiv și încerci din nou livrarea mai târziu în aceeași zi, valoarea DCR va fi mai mare și mai aproape de 100%, chiar dacă și a doua încercare de livrare este nereușită.',

        'kpi_desc_dnr': 'DSC DPMO (Condițiile de Succes ale Livrării)\n(anterior DNR – Livrare Neprimita)\n\nCu cât valoarea este mai mică, cu atât mai bine.\n\nAcest indicator măsoară cât de corect și trasabil sunt efectuate livrările.\n\nReguli de bază ale livrării:\n- Livrare către persoana corectă sau locația corectă\n- Livrările către clienți, membri ai gospodăriei, vecini sau recepționeri sunt cu risc scăzut atunci când sunt efectuate corect\n- Folosește întotdeauna codul corect de scanare/motiv pentru ca clienții să primească notificări corecte\n\nLivrări în camera poștală / cutia poștală:\n- Respectă fluxul de lucru standard\n- Coletele trebuie să fie complet în interiorul cutiei poștale sau fantei poștale și nu trebuie să iasă în afară\n- Folosește cea mai precisă scanare disponibilă\n\nAdresă corectă & Geofence:\n- Livrare în interiorul a 25 de metri de geofence-ul corect\n- Compară întotdeauna numele și adresa din aplicație cu eticheta coletului și clădirea\n- Dacă geocodul pare incorect, raportează prin SDS\n\nFotografie la livrare (POD):\n- Fă întotdeauna o fotografie clară atunci când ți se solicită\n- Coletul și mediul înconjurător trebuie să fie clar vizibile\n- Deosebit de important pentru livrările nesupravegheate și pentru încrederea clientului\n\nRespectarea preferințelor de livrare:\n- Respectă instrucțiunile clientului din aplicație, dacă sunt sigure\n- Dacă instrucțiunile nu sunt sigure, contactează clientul\n- Folosește doar locațiile sigure aprobate din aplicație\n\nOpriri simultane / de grup:\n- Folosește „Selectează toate” doar atunci când mai multe colete sunt livrate aceleiași persoane sau în același loc (de ex. recepție)\n- Înregistrează corect numele destinatarului și semnătura',

        'kpi_tip_dnr': 'Notificare importantă:\n\nValorile ridicate repetate la DSC DPMO indică livrări incorecte sau riscante.\n\n- Abaterile frecvente pot fi interpretate de Amazon ca posibil furt\n- Acest lucru poate declanșa un proces de prevenire a pierderilor\n- În cel mai rău caz, poate duce la încetarea colaborării\n\nScanările atente, fotografiile corecte și respectarea tuturor regulilor de livrare te protejează pe tine și echipa ta.',

        'kpi_desc_lor': 'LoR (Pierdut pe Traseu)\n\nCu cât valoarea este mai mică, cu atât mai bine.\n\nAcest indicator arată dacă toate coletele nelivrate sunt înregistrate corect la finalul rutei.\n\nLa finalul rutei:\n- Verifică în scanner câte colete trebuie returnate\n- Asigură-te că acest număr corespunde exact cu coletele din vehicul',

        'kpi_tip_lor': 'Notificare importantă:\n\nAceasta este categoria cu cel mai ridicat suspiciune de furt.\n\nNeconcordanțele dintre scanner și inventarul vehiculului pot fi considerate erori grave și pot duce la investigații interne sau la alte consecințe.',

        'kpi_desc_pod': 'PoD (Fotografie la Livrare)\n\nCu cât valoarea este mai mare, cu atât mai bine.\n\nAceastă coloană arată coletele pentru care a fost făcută o fotografie, dar care au fost marcate ca Nevalide sau Nesigure.\n\nMotive frecvente pentru respingerea POD:\n1. Eticheta coletului cu datele clientului vizibilă (coletul trebuie întors)\n2. Fotografie neclară\n3. Persoană vizibilă în fotografie\n4. Niciun colet vizibil în fotografie\n5. Colet în vehicul\n6. Colet în mână\n7. Colet prea aproape de cameră\n8. Fotografie prea întunecată',

        'kpi_tip_pod': 'Aceasta ar trebui să fie cea mai simplă categorie\nValoare țintă: 100%\nÎmbunătățește semnificativ scorul general',

        'kpi_desc_cc': 'CC (Contact cu Clientul)\n\nCu cât valoarea este mai mare, cu atât mai bine.\n\nExtrem de important:\nTrebuie SĂ TRIMIȚI ÎNTOTDEAUNA un mesaj „Nicio locație sigură” sau „Adresa nu a fost găsită” de fiecare dată când nu poți livra un colet deoarece:\n\n- clientul nu este acasă sau\n- adresa nu poate fi găsită',

        'kpi_tip_cc': 'Există un mesaj standard automat în aplicație pentru fiecare scenariu.',

        'kpi_desc_ce': 'CE (Escaladare de la Client)\n\nCu cât valoarea este mai mică, cu atât mai bine.\nCea mai proastă categorie dintre toate.\n\nClienții escaladează atunci când instrucțiunile de livrare nu sunt respectate.\n\nȘoferul este întotdeauna responsabil\nContestațiile sunt aproape imposibile fără dovezi foarte puternice\nAre cel mai puternic impact asupra Scorecard-ului tău\n\nCum să eviți CE\n\nEste împotriva regulilor de livrare să lași colete în locații nesigure sau nesupravegheate fără aprobare\n\nDelivery Associates trebuie:\n- Să sune la sonerie / să folosească interfonul sau să bată la ușă\n- Să ofere clientului suficient timp pentru a răspunde\n\nDacă clientul nu poate fi contactat și nu este setată nicio locație sigură:\n- Să sune clientul de două ori\n- Să trimită un mesaj text\n- Să contacteze Driver Support dacă nu este posibil contactul\n\nDacă este necesar:\n- Să scaneze coletul ca „Livrare eșuată – client indisponibil”\n- Să reîncerce livrarea conform regulilor',

        'kpi_tip_ce': 'Nu lăsa colete în locații nesigure sau neaprobate\nRespectă întotdeauna procesele corecte de expediere și livrare',

        'kpi_desc_cdf': 'CDF DPMO (Feedback-ul Clientului privind Livrarea)\n\nCu cât valoarea este mai mică, cu atât mai bine.\n\nNivelul 1 (L1)\n- Clientul evaluează livrarea ca „Groaznic” (👍) sau „Nu atât de bine” (👎)\n\nNivelul 2 (L2)\n- Feedback suplimentar despre motivul pentru care experiența a fost bună sau rea',

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

    'faq_q1': 'Ce este cel mai important în sarcina ta zilnică?',
    'faq_a1': 'Livrarea coletelor cu calitate și cu un comportament bun.',

    'faq_q2': 'Ce NU ar trebui să faci în cazul unor probleme cu clientul?',
    'faq_a2': 'NU încerca să gestionezi situația singur și informează în schimb dispecerul de serviciu. Vom încerca să vorbim cu clientul pentru tine și să evităm orice consecințe negative din partea Amazon din cauza reclamațiilor clienților. Suntem aici pentru tine!',

    'faq_q3': 'Ce se întâmplă dacă situația a escaladat deja și clientul nu este mulțumit de ceea ce s-a întâmplat?',
    'faq_a3': 'Nu este niciodată prea târziu să corectezi orice greșeli. Sună-ne în continuare și vom încerca să reparăm greșeala cu clientul. Mai bine mai târziu decât niciodată.',

    'faq_q4': 'Ce este mai important, Cantitatea (viteza de a livra cât mai multe opriri posibil) sau Calitatea?',
    'faq_a4': 'Calitatea! Întotdeauna calitatea! Urmează instrucțiunile clientului și NU lăsa coletul în locuri nesigure doar pentru că ești în urmă cu opririle.',

    'faq_q5': 'Ce se întâmplă dacă mă concentrez pe calitate, dar apoi rămân în urmă cu opririle?',
    'faq_a5': 'Îți vei termina opririle, într-un fel sau altul. Vom încerca să trimitem ajutor, dar numai dacă vedem că este rezonabil.',

    'faq_q6': 'Ce este scorecard-ul și ce este un DNR?',
    'faq_a6': 'Ne bucurăm că ai întrebat.',

    // 7 – Weekly scorecard
    'faq_q7': 'Scorecard săptămânal',
    'faq_a7': 'Scorecard-ul săptămânal ne oferă o imagine rapidă și clară despre cum se descurcă echipa în ceea ce privește obiectivele noastre cheie. Ne ajută să vedem ce merge bine, unde rămânem în urmă și pe ce trebuie să ne concentrăm pentru săptămâna următoare. Scorurile generale sunt următoarele:\n'
    '• Fantastic Plus: >93% (performanță excepțională)\n'
    '• Fantastic: 85% – 92.9%\n'
    '• Great: 70% – 84.9%\n'
    '• Fair: 50% – 69.9%\n'
    '• Poor: <50%',

    'faq_q7_1': 'Fila DNR\nDelivered Not Received',
    'faq_a7_1': 'Este atunci când ai livrat un colet și ai apăsat butonul „Swipe to finish”, confirmând că ai livrat coletul, dar clientul nu a primit coletul din mai multe motive: furtul coletului, cutia fiind goală de conținut și, de asemenea, livrarea greșită la o adresă greșită.\n'
    'În fiecare marți vei primi poze cu fiecare DNR pe care l-ai avut în timpul săptămânii.',

    'faq_q7_1_1': 'Cum ar trebui să evit acest lucru și cât de important este pentru scorecard-ul săptămânal?',
    'faq_a7_1_1': 'Este foarte important și, pentru a evita acest lucru, pur și simplu ar trebui să informezi clientul din timp că vei ajunge în curând la casa/afacerea lui și să suni DOAR la soneria pe care este trecut numele lui.',

    'faq_q7_1_2': 'Cum evit pierderile de colete?',
    'faq_a7_1_2': 'Încearcă întotdeauna să predai coletele direct clientului și, dacă acest lucru nu este posibil, trimite un mesaj informându-l unde a fost lăsat coletul, de exemplu, în garaj, sub scări, în șopron, în spatele vazei cu flori etc..\n'
    'Dacă nu consideri că este sigur să lași coletul nesupravegheat, te rugăm, cel mai bine este întotdeauna să iei coletul și să încerci din nou mai târziu. Acest lucru este FOARTE important.',

    'faq_q7_1_3': 'Cum știu ce loc este sigur sau nu?',
    'faq_a7_1_3': 'Instinct și bun simț. Dacă o clădire are 20 - 30 de etaje și îl lași lângă cutiile poștale, șansele să fie furat sunt din ce în ce mai mari comparativ cu o casă privată.\n'
    'De asemenea, pentru a te ajuta la livrările zilnice și pentru a evita să primești un DNR, în fiecare dimineață vom posta o poză cu adrese care au o probabilitate mare ca pachetele să fie furate și clienții să se plângă, pe baza rezultatelor și statisticilor livrărilor anterioare.',

    'faq_q7_1_4': 'Ce se întâmplă dacă un colet este pierdut sau furat, cum îmi va afecta scorul?',
    'faq_a7_1_4': 'Rău. Acest lucru te va afecta cu cel puțin 30% și asta doar cu un singur colet, care îți scade cel puțin 600 de puncte. Cu cât vezi mai multe puncte în scorecard sub numele tău, cu atât este mai rău. Cu cât livrezi mai multe colete pe săptămâna de lucru, cu atât pierzi mai puține puncte. Punctele pe care le pierzi variază și în funcție de prețul articolului pierdut: cu cât este mai scump, cu atât se pierd mai multe puncte. Ar trebui să păstrăm această secțiune de scor cât mai mică posibil.\n'
    'De asemenea, nu trebuie ignorat faptul că, dacă în mod regulat ai un număr mare de colete pierdute, va trebui să te eliberăm din funcție, deoarece mai devreme sau mai târziu Amazon poate suspecta furt de colete și, prin urmare, acest lucru este foarte periculos.',

    'faq_q7_2': 'Fila CC\n'
    'Contact Compliance',
    'faq_a7_2': 'Înseamnă de câte ori ai contactat clientul în legătură cu livrarea lui, fie prin mesaj, fie printr-un apel telefonic. Cu cât interacționezi mai puțin cu clientul, cu atât vei obține scoruri mai mici în scorecard și ar trebui să păstrăm această secțiune cât mai sus posibil, deoarece este de fapt una dintre cele mai ușoare categorii și ajută mult la scorul tău general.',

    'faq_q7_2_1': 'De ce ar trebui să fac asta?',
    'faq_a7_2_1': 'Livrarea coletelor nu înseamnă doar Drop&Go, ar trebui să informezi clientul în prealabil și să îl întrebi unde ar dori să fie livrat coletul.',

    'faq_q7_2_2': 'Cum îmi îmbunătățesc scorurile CC?',
    'faq_a7_2_2': 'Îți mulțumim că ai întrebat. Simplu, sunând și mai ales trimițând mesaje clienților la fiecare oprire.',

    'faq_q7_3': 'Fila CE\nCostumer Escalation',
    'faq_a7_3': 'Îți amintești cât de rău ți-a afectat DNR scorurile? Ei bine, asta este cel puțin de 2 ori mai rău și riști, de asemenea, să îți pierzi locul de muncă, deoarece depinde de cât de gravă a fost situația.',

    'faq_q7_3_1': 'Cum evit acest lucru?',
    'faq_a7_3_1': 'Urmând întotdeauna instrucțiunile de livrare ale clientului și, în cazul unei greșeli, mai întâi te rugăm să îți ceri scuze, iar dacă clientul este supărat, te rugăm să îi ceri un minut din timpul lui pentru a vorbi cu noi, deoarece deja ne suni. Citind Secțiunea 2, ar trebui să știi până acum că este cel mai bine să ne lași pe noi să gestionăm astfel de situații.',

    'faq_q7_4': 'Fila POD\nPicture on Delivery',
    'faq_a7_4': 'Această coloană arată lista coletelor eligibile pentru POD-uri, pentru care au fost făcute fotografii, dar care au fost fie Invalid, fie Not Sure. Motivele pentru respingerea unui POD pot include:\n'
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
    'faq_a7_5': 'Te penalizează atunci când ai scanat un colet la încărcare și nu l-ai returnat la sfârșitul turei în cazul unei livrări nereușite. Astfel coletul s-a pierdut și vei pierde la fel de multe puncte ca la un DNR, așa că te rugăm să numeri bine coletele pe care le aduci înapoi și să te asiguri că se potrivesc cu coletele afișate în scanner. Le poți găsi la: Todays Itinerary - Summary - Problems. Dacă nu se potrivesc, te rugăm să informezi dispecerul de serviciu înainte de a încheia munca în aplicația Amazon.',

    'faq_q7_6': 'Fila DCR\nDelivery Completion Rate',
    'faq_a7_6': 'Îți arată capacitățile de a livra colete. Urmărește procentul livrărilor finalizate conform planului, ajutându-ne să măsurăm eficiența și fiabilitatea livrărilor noastre. Evidențiază probleme precum întârzieri, încercări eșuate sau probleme de rutare. Acesta ar trebui să fie întotdeauna cât mai mare posibil. Pentru a face acest lucru posibil ar trebui în fiecare zi să faci reattempts și să eviți cât de mult poți returnarea coletelor.',

    'faq_q7_7': 'Fila CDF (Anterior, DEX)\nCostumer Delivery Feedback',
    'faq_a7_7': 'Captează experiența destinatarului cu procesul de livrare, inclusiv punctualitatea, starea bunurilor și profesionalismul șoferului. Ne ajută să identificăm punctele forte ale serviciului și zonele de îmbunătățire. La finalul livrării, clientul primește un e-mail de la Amazon despre experiența livrării, cu întrebări precum:\n'
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
    'faq_a7_8': 'Calitatea și eficiența contează mult. Scorurile bune sunt bune pentru tine, pentru companie și bune pentru întreaga echipă. Satisfacția clientului este foarte importantă și scorurile bune sunt însoțite de un bonus din partea companiei.\n'
    'Dă tot ce poți, primește ce e mai bun.',

    'faq_q8': 'La ce alte domenii ar trebui să fiu atent?',
    'faq_a8': 'Ai grijă de tine conducând în siguranță, evitând accidentările și evitând câinii și mușcăturile de câine. Ai grijă de echipamentele de lucru, cum ar fi vehiculul zilnic, scannerul/telefonul de lucru și vino la muncă purtând pantofii de siguranță și vesta de siguranță, jachetă sau tricou marca Amazon (în funcție de vreme).',

    'faq_q9': 'Ce se întâmplă dacă fac un accident de mașină sau deteriorez vehiculul de lucru?',
    'faq_a9': 'Mai întâi, asigură-te că ești bine și că nu ești rănit grav. În ceea ce privește daunele la mașină, dacă stabilim că accidentele apar din neglijență – de exemplu, distrageri precum utilizarea telefonului mobil în timpul conducerii – vei fi personal răspunzător pentru întreaga daună. În plus, vei primi un raport de la poliție, care ar putea duce chiar la suspendarea permisului. Desigur, acesta este și un motiv pentru concediere imediată. În caz contrar, ești doar exclus de la bonusurile Weekly Scorecard pentru 2 luni. În cazul unui incident, ești OBLIGAT să ne informezi imediat și să ne furnizezi ora incidentului, locația, dacă există daune la proprietăți private sau publice (cum ar fi pereți, garduri, stâlpi de iluminat, persoane și/sau animale de companie), locația și poze cu daunele mașinii.',

    'faq_q10': 'Ce fac când am colete deteriorate și/sau lipsă.',
    'faq_a10': 'Când un colet este deteriorat, te rugăm să îl înregistrezi ca deteriorat și să îl returnezi la stație. Dacă acel colet deteriorat a fost un colet cu lichide și a deteriorat și alte colete, te rugăm să faci o poză cu toate coletele deteriorate și să o trimiți dispecerului de serviciu și vom raporta noi către Amazon.\n'
    'Când un colet lipsește, te rugăm să îl marchezi/înregistrezi ca lipsă, cu excepția cazului în care are un OTP, pentru care TREBUIE să ne raportezi mai întâi înainte de a-l marca drept lipsă. Acest lucru este FOARTE important.',

    'faq_q11': 'Ce este un colet OTP (One-Time Password)?',
    'faq_a11': 'Este un articol scump pentru care Amazon cere clientului să îi ofere șoferului o parolă unică (One Time Password) înainte de a livra coletul, pentru a se asigura că coletul este livrat persoanei/clientului potrivit. Trebuie să ai grijă deosebită de astfel de colete, să nu le lași nesupravegheate și să înmânezi coletele doar clientului care ți-a furnizat parola.',

    'faq_q12': 'De ce te tot deranjăm să încetinești și să nu mergi mai repede?',
    'faq_a12': 'Nici nouă nu ne place, dar așa este sistemul. Trebuie să urmăm algoritmul sistemului și să facem cât mai multe opriri pe oră, așa cum este stabilit, ca să putem obține mai multe rute în viitor și tu să ajungi să lucrezi mai mult și să nu fii liber.\n'
    'De asemenea, mergând mai repede, riști să primești un DNR și riști să pierzi puncte pentru ambele, pentru tine și pentru companie, în scorecard-ul săptămânal.',

    'faq_q13': 'Atunci de ce dispecerii uneori mă întreabă de ce sunt în urmă și dacă este ceva în neregulă?',
    'faq_a13': 'Știm că acest lucru nu este plăcut, dar avem nevoie de un feedback despre ce s-ar fi putut întâmpla pe drum care te-a făcut să rămâi în urmă cu opririle. Amazon ne cere acest feedback deoarece există și un termen-limită până la care ar fi trebuit să livrezi X opriri, prin urmare Amazon trebuie să știe de ce opririle rămase sunt în urmă față de programul de livrare și, cu aceste informații, să îmbunătățească eficiența livrărilor viitoare.',

    'faq_q14': 'De ce uneori îți cerem să mergi să ajuți un coleg?',
    'faq_a14': 'Pentru că mulți factori joacă un rol în întârzierea colegului, cum ar fi conexiunea slabă la internet în zonă, traficul, străzi blocate din cauza lucrărilor în zonă, ceea ce a făcut dificil pentru celălalt șofer să livreze la timp, prin urmare ajutorul tău este necesar.',

    'faq_q15': 'În prima mea zi, încep imediat să livrez colete pe rute standard ca alți șoferi de livrare mai experimentați?',
    'faq_a15': 'Nu, evident că nu este cazul pentru tine. La început vei avea o perioadă de 14 zile de lucru pentru a pune în practică ceea ce ai învățat în zilele de ride-along cu trainerul tău și pentru a te adapta la zonă, la mașină, la scanner și pentru a învăța procesul de lucru.\n'
    'Cu asta spus, pentru acea perioadă de 14 zile, Amazon îți va da cu până la 50% mai puține colete și opriri decât în mod normal în programul tău.',

    'faq_q16': 'Ce să faci când o adresă este greșită și/sau pinul locației nu este corect pe hartă?',
    'faq_a16': 'Mai întâi confirmă că pinul nu este corect căutând adresa în Google Maps (este mai precis și este deja instalat pe scannerul tău) și, dacă nu se potrivește, informează un dispecer de serviciu cu erorile.',

    'faq_q17': 'Care sunt sarcinile mele zilnice înainte de a începe și după ce termin munca?',
    'faq_a17': '1- Când ajungi în parcare, mai întâi te asiguri că porți pantofii de siguranță și vesta de siguranță și uniforma Amazon.\n'
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

    'faq_q18': 'Trebuie să fac ceva când schimb van-ul și iau un alt van decât cel pe care îl iau de obicei?',
    'faq_a18': 'Ar trebui să faci un video cu el, surprinzând în detaliu fiecare mică daună pe care șoferul(șoferii) anterior(i) ar fi putut să o facă, astfel încât să nu fie vina ta la următoarea inspecție a mașinii.',

    'faq_q19': 'Ce ar trebui să fac dacă aplicația Flex se încarcă constant și îmi încetinește fluxul de lucru?',
    'faq_a19': 'Mai întâi verifică dacă ai o conexiune activă la internet. Pentru a face asta poți încerca să trimiți un mesaj clientului de la oprirea curentă și, dacă se trimite, atunci înseamnă că internetul este activ. Poți verifica și deschizând o altă aplicație pe scanner, cum ar fi browserul, și căutând ceva pe el.\n'
    'Pașii pe care ar trebui să îi urmezi dacă nu există o conexiune activă la internet:\n'
    '1- Repornește scannerul. Acesta ar trebui să fie întotdeauna primul lucru pe care îl încerci.\n'
    '2- Pornește/oprește modul avion. Acesta funcționează de cele mai multe ori fără să aștepți repornirea scannerului.\n'
    '3- Ca ultimă soluție, te rog să încerci să partajezi un hotspot de pe telefonul tău personal pentru doar 10 minute max, doar pentru ca sistemul să se reîmprospăteze.\n'
    'Poți lucra și offline, dar la un moment dat trebuie să te conectezi la internet și să fii activ. Pentru a lucra offline trebuie mai întâi să descarci hărțile offline în aplicația Flex. Pentru a face asta, mergi la Settings - Offline Maps (ultima opțiune) - Download DBY5 - Allow downloads with mobile connection.\n',

    'faq_q20': 'Ce se întâmplă dacă conexiunea la internet este activă și aplicația Flex încă nu funcționează așa cum ar trebui?',
    'faq_a20': '1- Repornește scannerul.\n'
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
      'select_language': 'Odaberi jezik',
      'notifications': 'Obavijesti',
      'no_notifications': 'Nema obavijesti',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'Pomoć',
      'nav_rules': 'Pravila',
      'nav_profile': 'Profil',
      'change_profile_photo': 'Promijeni profilnu sliku',
      'profile_change_photo': 'Promijeni profilnu sliku',
      'logout': 'Odjava',
      'profile_logout': 'Odjava',
      'pin_change_with_old': 'PIN možeš promijeniti nakon provjere starog PIN-a.',
      'pin_forgot_contact_admin': 'Zaboravili ste PIN? Kontaktirajte administratora.',
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

        'kpi_title_dcr': 'Stopa Uspješnosti Dostave',
        'kpi_title_dnr': 'Uvjeti Uspješne Dostave',
        'kpi_title_lor': 'Izgubljeno na Ruti',
        'kpi_title_pod': 'Fotografija pri Dostavi',
        'kpi_title_cc': 'Kontakt s Kupcem',
        'kpi_title_ce': 'Eskalacija Kupca',
        'kpi_title_cdf': 'Povratne Informacije Kupca o Dostavi',

        'kpi_desc_dcr': 'Što je vrijednost viša, to je bolje. Kako bi se postigla stopa uspješnosti od 100 %, preporučuje se ponovni pokušaj dostave* nakon neuspjele dostave.',
        'kpi_tip_dcr': 'Primjer: Ako tijekom dana iz bilo kojeg razloga ne možeš dostaviti paket i pokušaš dostavu ponovno kasnije istog dana, tvoja DCR vrijednost bit će viša i bliža 100 %, čak i ako drugi pokušaj dostave također ne uspije.',

        'kpi_desc_dnr': 'DSC DPMO (Uvjeti Uspješne Dostave)\n(ranije DNR – Dostava Nije Zaprimljena)\n\nŠto je vrijednost niža, to je bolje.\n\nOva metrika mjeri koliko se ispravno i sljedivo provode dostave.\n\nOsnovna pravila dostave:\n- Dostava ispravnoj osobi ili na ispravnu lokaciju\n- Dostave kupcima, članovima kućanstva, susjedima ili recepcionarima su niskog rizika ako se pravilno provedu\n- Uvijek koristiti ispravan kod skeniranja/razloga kako bi kupci primili točne obavijesti\n\nDostave u poštansku sobu / poštanski sandučić:\n- Slijediti standardni tijek rada\n- Paketi moraju biti u potpunosti unutar poštanskog sandučića ili utora i ne smiju viriti\n- Koristiti najpreciznije dostupno skeniranje\n\nIspravna adresa i geofence:\n- Dostava unutar 25 metara ispravnog geofencea\n- Uvijek usporediti ime i adresu u aplikaciji s oznakom paketa i zgradom\n- Ako se geokod čini netočnim, prijaviti putem SDS-a\n\nFotografija pri dostavi (POD):\n- Uvijek napraviti jasnu fotografiju kada se to zatraži\n- Paket i okolina moraju biti jasno vidljivi\n- Posebno važno za nenadzirane dostave i povjerenje kupaca\n\nPoštivanje preferencija dostave:\n- Slijediti upute kupca u aplikaciji ako su sigurne\n- Ako upute nisu sigurne, kontaktirati kupca\n- Koristiti samo odobrene sigurne lokacije iz aplikacije\n\nIstovremene / grupne stanice:\n- Koristiti „Odaberi sve“ samo kada se više paketa dostavlja istoj osobi ili na isto mjesto (npr. recepcija)\n- Ispravno zabilježiti ime primatelja i potpis',

        'kpi_tip_dnr': 'Važna napomena:\n\nPonavljano visoke vrijednosti DSC DPMO-a ukazuju na netočne ili rizične dostave.\n\n- Česta odstupanja Amazon može protumačiti kao moguću krađu\n- To može pokrenuti postupak sprječavanja gubitaka\n- U najgorem slučaju, to može dovesti do prekida suradnje\n\nPažljivo skeniranje, ispravne fotografije i poštivanje svih pravila dostave štite tebe i tvoj tim.',

        'kpi_desc_lor': 'LoR (Izgubljeno na Ruti)\n\nŠto je vrijednost niža, to je bolje.\n\nOva metrika pokazuje jesu li svi nedostavljeni paketi ispravno evidentirani na kraju rute.\n\nNa kraju rute:\n- Provjeriti u skeneru koliko paketa treba vratiti\n- Osigurati da se taj broj točno podudara s paketima u vozilu',

        'kpi_tip_lor': 'Važna napomena:\n\nOvo je kategorija s najvećom sumnjom na krađu.\n\nNeusklađenosti između skenera i inventara vozila mogu se smatrati ozbiljnim pogreškama i mogu dovesti do unutarnjih istraga ili drugih posljedica.',

        'kpi_desc_pod': 'PoD (Fotografija pri Dostavi)\n\nŠto je vrijednost viša, to je bolje.\n\nOvaj stupac prikazuje pakete za koje je snimljena fotografija, ali su označeni kao Nevažeći ili Nesigurni.\n\nČesti razlozi za odbijanje POD-a:\n1. Oznaka paketa s podacima o kupcu vidljiva (paket se mora okrenuti)\n2. Mutna fotografija\n3. Osoba vidljiva na fotografiji\n4. Paket nije vidljiv na fotografiji\n5. Paket u vozilu\n6. Paket u ruci\n7. Paket preblizu kameri\n8. Fotografija je previše tamna',

        'kpi_tip_pod': 'Ovo bi trebala biti najjednostavnija kategorija\nCiljana vrijednost: 100 %\nZnačajno poboljšava ukupni rezultat',

        'kpi_desc_cc': 'CC (Kontakt s Kupcem)\n\nŠto je vrijednost viša, to je bolje.\n\nIzuzetno važno:\nMoraš UVIJEK poslati poruku „Nema sigurne lokacije“ ili „Adresa nije pronađena“ svaki put kada ne možeš dostaviti paket jer:\n\n- kupac nije kod kuće ili\n- adresa se ne može pronaći',

        'kpi_tip_cc': 'Za svaki scenarij u aplikaciji postoji automatska standardna poruka.',

        'kpi_desc_ce': 'CE (Eskalacija Kupca)\n\nŠto je vrijednost niža, to je bolje.\nNajgora kategorija od svih.\n\nKupci eskaliraju kada se ne poštuju upute za dostavu.\n\nVozač je uvijek odgovoran\nŽalbe su gotovo nemoguće bez vrlo jakih dokaza\nIma najjači utjecaj na tvoj Scorecard\n\nKako izbjeći CE\n\nProtivno je pravilima dostave ostavljati pakete na nesigurnim ili nenadziranim mjestima bez odobrenja\n\nDelivery Associates moraju:\n- Pozvoniti / koristiti portafon ili pokucati\n- Dati kupcu dovoljno vremena za odgovor\n\nAko kupca nije moguće kontaktirati i nije postavljena sigurna lokacija:\n- Nazvati kupca dva puta\n- Poslati tekstualnu poruku\n- Kontaktirati Driver Support ako kontakt nije moguć\n\nAko je potrebno:\n- Skenirati paket kao „Dostava neuspješna – kupac nedostupan“\n- Ponovno pokušati dostavu u skladu s pravilima',

        'kpi_tip_ce': 'Ne ostavljati pakete na nesigurnim ili neodobrenim lokacijama\nUvijek poštivati ispravne procese slanja i dostave',

        'kpi_desc_cdf': 'CDF DPMO (Povratne Informacije Kupca o Dostavi)\n\nŠto je vrijednost niža, to je bolje.\n\nRazina 1 (L1)\n- Kupac ocjenjuje dostavu kao „Odlično” (👍) ili „Ne baš dobro” (👎)\n\nRazina 2 (L2)\n- Dodatna povratna informacija o tome zašto je iskustvo bilo dobro ili loše',

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

    'faq_q1': 'Što je najvažnije u tvom dnevnom zadatku?',
    'faq_a1': 'Dostavljanje paketa kvalitetno i uz dobro ponašanje.',

    'faq_q2': 'Što ne smiješ napraviti u slučaju problema s kupcem?',
    'faq_a2': 'NE pokušavaj sam rješavati situaciju i umjesto toga obavijesti dežurnog dispečera. Pokušat ćemo razgovarati s kupcem umjesto tebe i izbjeći bilo kakve loše posljedice od Amazona zbog pritužbi kupaca. Tu smo za tebe!',

    'faq_q3': 'Što ako je situacija već eskalirala i kupac nije zadovoljan zbog onoga što se dogodilo?',
    'faq_a3': 'Nikada nije prekasno ispraviti greške. I dalje nas nazovi i pokušat ćemo ispraviti grešku s kupcem. Bolje ikad nego nikad.',

    'faq_q4': 'Što je važnije, Količina (brzina dostave što više stajanja) ili Kvaliteta?',
    'faq_a4': 'Kvaliteta! Uvijek kvaliteta! Slijedi upute kupca i NE ostavljaj paket na nesigurnim mjestima samo zato što kasniš sa stajanjima.',

    'faq_q5': 'Što ako se fokusiram na kvalitetu, ali onda zaostanem sa stajanjima?',
    'faq_a5': 'Završit ćeš svoja stajanja, na ovaj ili onaj način. Pokušat ćemo poslati pomoć, ali samo ako vidimo da je to razumno.',

    'faq_q6': 'Što je scorecard i što je DNR?',
    'faq_a6': 'Drago nam je da pitaš.',

    // 7 – Weekly scorecard
    'faq_q7': 'Tjedni scorecard',
    'faq_a7': 'Tjedni scorecard daje nam brz, jasan pregled kako tim stoji s našim ključnim ciljevima. Pomaže nam uočiti što ide dobro, gdje zaostajemo i na što se trebamo fokusirati u nadolazećem tjednu. Ukupni rezultati su sljedeći:\n'
    '• Fantastic Plus: >93% (iznimna izvedba)\n'
    '• Fantastic: 85% – 92.9%\n'
    '• Great: 70% – 84.9%\n'
    '• Fair: 50% – 69.9%\n'
    '• Poor: <50%',

    'faq_q7_1': 'DNR kartica\nDelivered Not Received',
    'faq_a7_1': 'To je kada si dostavio paket i kliknuo gumb "Swipe to finish" potvrđujući da si dostavio paket, ali kupac nije primio paket iz više razloga: krađa paketa, kutija je bila prazna od sadržaja paketa te pogrešna dostava na pogrešnu adresu.\n'
    'Svakog utorka dobit ćeš slike svakog DNR-a koji si imao tijekom tjedna.',

    'faq_q7_1_1': 'Kako to trebam izbjeći i koliko je to važno za tjedni scorecard?',
    'faq_a7_1_1': 'Vrlo je važno, a da bi to izbjegao jednostavno trebaš unaprijed obavijestiti kupca da uskoro dolaziš na njihovu kuću/poslovni prostor i zvoniti SAMO na zvono s njihovim imenom.',

    'faq_q7_1_2': 'Kako izbjeći gubitke paketa?',
    'faq_a7_1_2': 'Uvijek pokušaj predati pakete iz ruke kupcu, a ako to nije moguće, pošalji poruku u kojoj ih obavještavaš gdje je paket ostavljen, na primjer u garaži, ispod stepenica, u šupi, iza vaze s cvijećem itd..\n'
    'Ako ne misliš da je sigurno ostaviti paket bez nadzora, molimo, uvijek je najbolje samo uzeti paket i pokušati ponovno kasnije. Ovo je VRLO važno.',

    'faq_q7_1_3': 'Kako znam koje je mjesto sigurno ili ne?',
    'faq_a7_1_3': 'Instinkt i zdrav razum. Ako zgrada ima 20 - 30 katova i ostaviš paket kod sandučića, šanse da bude ukraden su sve veće u usporedbi s privatnom kućom.\n'
    'Također, kako bismo ti pomogli u svakodnevnim dostavama i kako bi izbjegao DNR, svako jutro ćemo objaviti sliku s adresama koje imaju veliku vjerojatnost krađe paketa i pritužbi kupaca, na temelju prethodnih rezultata dostava i statistike.',

    'faq_q7_1_4': 'Što ako se paket izgubi ili bude ukraden, kako će to utjecati na moj rezultat?',
    'faq_a7_1_4': 'Loše. To će te pogoditi za najmanje 30% i to je samo s jednim paketom koji ti oduzme najmanje 600 bodova. Što više bodova vidiš u scorecardu uz svoje ime, to je gore. Što više paketa dostaviš po radnom tjednu, to manje bodova gubiš. Bodovi koje gubiš također ovise o cijeni izgubljenog artikla: što je skuplje, više bodova se gubi. Ovu sekciju rezultata trebamo držati što niže moguće.\n'
    'Ne smije se zanemariti ni činjenica da, ako redovito imaš velik broj izgubljenih paketa, morat ćemo te otpustiti jer prije ili kasnije Amazon može posumnjati na krađu paketa, a to je vrlo opasno.',

    'faq_q7_2': 'CC kartica\n'
    'Contact Compliance',
    'faq_a7_2': 'Znači koliko puta si kontaktirao kupca u vezi njihove dostave, bilo putem poruke ili telefonskog poziva. Što manje komuniciraš s kupcem, to ćeš dobiti manje bodova u scorecardu, i ovu sekciju trebamo držati što višom jer je zapravo jedna od najlakših kategorija i puno pomaže tvom ukupnom rezultatu.',

    'faq_q7_2_1': 'Zašto bih to trebao raditi?',
    'faq_a7_2_1': 'Dostava paketa nije samo Drop&Go, trebao bi unaprijed obavijestiti kupca i pitati ih gdje bi željeli da paket bude dostavljen.',

    'faq_q7_2_2': 'Kako poboljšati svoje CC rezultate?',
    'faq_a7_2_2': 'Hvala što pitaš. Jednostavno: pozivima, a posebno slanjem poruka kupcima na svakoj stanici.',

    'faq_q7_3': 'CE kartica\nCostumer Escalation',
    'faq_a7_3': 'Sjećaš se koliko je loše DNR utjecao na tvoje rezultate? E pa, ovo je najmanje 2 puta gore, i također riskiraš gubitak posla jer ovisi o tome koliko je situacija bila loša.',

    'faq_q7_3_1': 'Kako to izbjeći?',
    'faq_a7_3_1': 'Tako da uvijek slijediš upute kupca za dostavu i u slučaju pogreške prvo se ispričaj, a ako je kupac ljut, zamoli ih za minutu vremena da razgovaraju s nama, jer nas već zoveš. Čitanjem Odjeljka 2, do sada bi trebao znati da je najbolje prepustiti nama da rješavamo takve situacije.',

    'faq_q7_4': 'POD kartica\nPicture on Delivery',
    'faq_a7_4': 'Ova kolona prikazuje popis paketa koji su podobni za POD, za koje su fotografije snimljene, ali su označene kao Invalid ili Not Sure. Razlozi za odbijanje POD-a mogu uključivati:\n'
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
    'faq_a7_5': 'Kažnjava te kada si skenirao paket pri utovaru i nisi ga vratio na kraju smjene u slučaju neuspješne dostave. Dakle, paket je izgubljen i izgubit ćeš onoliko bodova koliko bi izgubio i za DNR, zato dobro prebroji pakete koje vraćaš i provjeri odgovaraju li paketima prikazanim u scanneru. Možeš ih pronaći na: Todays Itinerary - Summary - Problems. Ako se ne podudaraju, molimo obavijesti dežurnog dispečera prije završetka rada u Amazon aplikaciji.',

    'faq_q7_6': 'DCR kartica\nDelivery Completion Rate',
    'faq_a7_6': 'Pokazuje tvoje sposobnosti u dostavljanju paketa. Prati postotak dostava dovršenih prema planu, pomažući nam mjeriti učinkovitost i pouzdanost naših dostava. Ističe probleme poput kašnjenja, neuspješnih pokušaja ili problema s rutiranjem. Ovo bi uvijek trebalo biti što više moguće. Da bi to bilo moguće, svaki dan trebaš raditi reattempts i izbjegavati koliko god možeš vraćanje paketa.',

    'faq_q7_7': 'CDF kartica (Previously, DEX)\nCostumer Delivery Feedback',
    'faq_a7_7': 'Bilježi iskustvo primatelja s procesom dostave, uključujući točnost, stanje robe i profesionalnost vozača. Pomaže nam identificirati snage usluge i područja za poboljšanje. Na kraju dostave, kupac dobiva e-mail od Amazona o iskustvu dostave, s pitanjima kao što su:\n'
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
    'faq_a7_8': 'Kvaliteta i učinkovitost puno znače. Dobri rezultati su dobri za tebe, za kompaniju i dobri za cijeli tim. Zadovoljstvo kupaca je vrlo važno i dobri rezultati su popraćeni bonusom od kompanije.\n'
    'Daj najbolje od sebe, dobiješ najbolje.',

    'faq_q8': 'Na koja druga područja trebam paziti?',
    'faq_a8': 'Brini se o sebi vozeći sigurno, izbjegavajući ozljede i izbjegavajući pse i ugrize pasa. Budi pažljiv s radnom opremom kao što su dnevno vozilo, radni scanner/telefon i dolazi na posao noseći sigurnosne cipele i sigurnosni prsluk, Amazon jaknu ili majicu (ovisno o vremenu).',

    'faq_q9': 'Što se događa ako doživim prometnu nesreću ili oštetim radno vozilo?',
    'faq_a9': 'Prvo, provjeri da si dobro i da nisi teško ozlijeđen. Što se tiče štete na vozilu, ako utvrdimo da se nesreće događaju zbog nemara – na primjer, ometanja poput korištenja mobitela tijekom vožnje – bit ćeš osobno odgovoran za punu štetu. Osim toga, dobit ćeš policijski zapisnik, što može čak rezultirati suspenzijom vozačke dozvole. Naravno, to je također razlog za trenutni otkaz. U suprotnom, samo si isključen iz primanja tjednih Scorecard bonusa na 2 mjeseca. U slučaju incidenta, DUŽAN si nas odmah obavijestiti i dati nam vrijeme incidenta, lokaciju, postoji li šteta na privatnoj ili javnoj imovini (poput zidova, ograda, stupova rasvjete, ljudi i/ili kućnih ljubimaca), lokaciju i fotografije štete na vozilu.',

    'faq_q10': 'Što radim kada imam pakete oštećene i/ili nedostaju.',
    'faq_a10': 'Kada je paket oštećen, slobodno ga označi kao oštećen i vrati ga u stanicu. Ako je taj oštećeni paket bio tekući paket i oštetio druge pakete, molimo napravi fotografiju svih oštećenih paketa i pošalji je dežurnom dispečeru, a mi ćemo to prijaviti Amazonu za tebe.\n'
    'Kada paket nedostaje, slobodno ga označi/rezerviraj kao nedostajući osim ako ima OTP za koji MORAŠ prvo nama prijaviti prije nego što ga označiš kao nedostajući. Ovo je VRLO važno.',

    'faq_q11': 'Što je OTP (One-Time Password) paket?',
    'faq_a11': 'To je skup predmet za koji Amazon zahtijeva da kupac dostavljaču da jednokratnu lozinku (One Time Password) prije dostave paketa, kako bi se osiguralo da je paket dostavljen pravoj osobi/kupcu. Moraš biti posebno pažljiv s takvim paketima, ne ostavljati ih bez nadzora i predati ih samo kupcu koji ti je dao lozinku.',

    'faq_q12': 'Zašto te stalno gnjavimo da usporiš i da ne ideš brže?',
    'faq_a12': 'Ni nama se to ne sviđa, ali takav je sustav. Moramo slijediti algoritam sustava i napraviti onoliko stajanja po satu koliko je unaprijed određeno kako bismo u budućnosti dobili više ruta i da ti možeš više raditi i ne biti slobodan.\n'
    'Također, bržom vožnjom riskiraš DNR i gubitak bodova za oboje, sebe i kompaniju, u tjednom scorecardu.',

    'faq_q13': 'Pa zašto me dispečeri ponekad pitaju zašto kasnim i je li nešto pošlo po zlu?',
    'faq_a13': 'Znamo da ovo nije ugodno, ali trebamo povratnu informaciju o tome što se moglo dogoditi na cesti zbog čega si zaostao sa stajanjima. Amazon traži ovu povratnu informaciju jer postoji i vremensko ograničenje do kojeg si trebao dostaviti X stajanja, stoga Amazon treba znati zašto su preostala stajanja iza rasporeda dostave i s ovom informacijom poboljšati buduću učinkovitost dostave.',

    'faq_q14': 'Zašto te ponekad tražimo da ideš pomoći kolegi?',
    'faq_a14': 'Zato što mnogi faktori utječu na kašnjenje kolege, poput loše internetske veze u području, prometa, blokiranih ulica zbog radova u području, što je otežalo drugom vozaču da dostavi na vrijeme, stoga je potrebna tvoja pomoć.',

    'faq_q15': 'Počinjem li odmah prvog dana dostavljati standardne rute kao i drugi, iskusniji vozači?',
    'faq_a15': 'Ne, očito to nije slučaj za tebe. Na početku ćeš imati razdoblje od 14 radnih dana da u praksi primijeniš ono što si naučio u ride-along danima s trenerom i prilagodiš se području, vozilu, scanneru i naučiš tijek rada.\n'
    'Uz to, za to razdoblje od 14 dana, Amazon će ti dati do 50% manje paketa i stajanja nego inače u tvom rasporedu.',

    'faq_q16': 'Što učiniti kada je adresa pogrešna i/ili pin lokacije nije točan na karti?',
    'faq_a16': 'Prvo potvrdi da pin nije točan tako što ćeš potražiti adresu u Google Maps (točnije je i već je instalirano na tvom scanneru) i ako se ne podudara, obavijesti dežurnog dispečera o greškama.',

    'faq_q17': 'Koji su moji dnevni zadaci prije nego počnem i nakon što završim posao?',
    'faq_a17': '1- Kada dođeš na parking, prvo provjeri nosiš li sigurnosne cipele, sigurnosni prsluk i Amazon uniformu.\n'
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

    'faq_q18': 'Moram li nešto učiniti kada mijenjam kombi i uzmem drugi kombi umjesto onog koji obično uzimam?',
    'faq_a18': 'Trebao bi napraviti video, detaljno snimajući svaku malu štetu koju su prethodni vozač(i) mogli napraviti, kako ne bi bila tvoja krivnja pri sljedećem pregledu vozila.',

    'faq_q19': 'Što trebam učiniti ako se Flex aplikacija stalno učitava i usporava moj tijek rada?',
    'faq_a19': 'Prvo provjeri imaš li aktivnu internetsku vezu. Da to provjeriš možeš pokušati poslati poruku kupcu na trenutnom stajanju i ako prođe, to znači da je internetska veza aktivna. Također možeš provjeriti otvaranjem druge aplikacije na scanneru, poput preglednika, i pretraživanjem nečega.\n'
    'Koraci koje trebaš slijediti ako nema aktivne internetske veze:\n'
    '1- Ponovno pokreni scanner. Ovo bi uvijek trebalo biti prvo što pokušaš.\n'
    '2- Uključi/isključi airplane mode. Ovo radi većinu vremena bez čekanja da se scanner ponovno pokrene.\n'
    '3- Kao posljednje rješenje, molimo pokušaj podijeliti hotspot s osobnog telefona na maksimalno 10 minuta samo da se sustav osvježi.\n'
    'Možeš raditi i offline, ali u nekom trenutku moraš se spojiti na internet i biti aktivan. Da radiš offline, prvo moraš preuzeti offline karte u Flex aplikaciji. Da to napraviš, ideš na Settings - Offline Maps (zadnja opcija) - Download DBY5 - Allow downloads with mobile connection.\n',

    'faq_q20': 'Što ako je internetska veza aktivna, a Flex aplikacija i dalje ne radi kako bi trebala?',
    'faq_a20': '1- Ponovno pokreni scanner.\n'
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
      'select_language': 'اختر اللغة',
      'notifications': 'الإشعارات',
      'no_notifications': 'لا توجد إشعارات',
      'nav_scorecard': 'Scorecard',
      'nav_help': 'مساعدة',
      'nav_rules': 'القواعد',
      'nav_profile': 'الملف الشخصي',
      'change_profile_photo': 'تغيير صورة الملف الشخصي',
      'profile_change_photo': 'تغيير صورة الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'profile_logout': 'تسجيل الخروج',
      'pin_change_with_old': 'يمكنك تغيير الرقم السري بعد التحقق من الرقم السري القديم.',
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

        'kpi_title_dcr': 'معدل نجاح التسليم',
        'kpi_title_dnr': 'شروط نجاح التسليم',
        'kpi_title_lor': 'مفقود أثناء الطريق',
        'kpi_title_pod': 'صورة عند التسليم',
        'kpi_title_cc': 'التواصل مع العميل',
        'kpi_title_ce': 'تصعيد من العميل',
        'kpi_title_cdf': 'تقييم العميل لعملية التسليم',

        'kpi_desc_dcr': 'كلما كانت القيمة أعلى، كان ذلك أفضل. للوصول إلى معدل نجاح 100٪، يُوصى بمحاولة إعادة التسليم* بعد فشل عملية التسليم.',
        'kpi_tip_dcr': 'مثال: إذا لم تتمكن في يوم ما من تسليم طرد لأي سبب، وحاولت التسليم مرة أخرى لاحقًا في نفس اليوم، فستكون قيمة DCR أعلى وأقرب إلى 100٪، حتى لو كانت محاولة التسليم الثانية غير ناجحة أيضًا.',

        'kpi_desc_dnr': 'DSC DPMO (شروط نجاح التسليم)\n(سابقًا DNR – لم يتم استلام التسليم)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\n\nيقيس هذا المؤشر مدى صحة وقابلية تتبع عمليات التسليم.\n\nقواعد التسليم الأساسية:\n- التسليم إلى الشخص الصحيح أو الموقع الصحيح\n- التسليم إلى العملاء أو أفراد الأسرة أو الجيران أو موظفي الاستقبال منخفض المخاطر عند تنفيذه بشكل صحيح\n- استخدم دائمًا رمز المسح/السبب الصحيح حتى يتلقى العملاء إشعارات صحيحة\n\nالتسليم إلى غرفة البريد / صندوق البريد:\n- اتباع سير العمل القياسي\n- يجب أن تكون الطرود بالكامل داخل صندوق البريد أو فتحة البريد وألا تبرز للخارج\n- استخدام أدق عملية مسح متاحة\n\nالعنوان الصحيح وGeofence:\n- التسليم ضمن 25 مترًا من geofence الصحيح\n- مطابقة الاسم والعنوان في التطبيق دائمًا مع ملصق الطرد والمبنى\n- إذا بدا الرمز الجغرافي غير صحيح، قم بالإبلاغ عبر SDS\n\nالصورة عند التسليم (POD):\n- التقاط صورة واضحة دائمًا عند الطلب\n- يجب أن يكون الطرد والمحيط واضحين\n- مهم بشكل خاص لعمليات التسليم غير المراقبة ولثقة العملاء\n\nالالتزام بتفضيلات التسليم:\n- اتباع تعليمات العميل في التطبيق إذا كانت آمنة\n- إذا كانت التعليمات غير آمنة، تواصل مع العميل\n- استخدام مواقع التسليم الآمنة المعتمدة فقط من التطبيق\n\nالتوقفات المتزامنة / الجماعية:\n- استخدم \"تحديد الكل\" فقط عندما يتم تسليم عدة طرود لنفس الشخص أو نفس الموقع (مثل مكتب الاستقبال)\n- تسجيل اسم المستلم والتوقيع بشكل صحيح',

        'kpi_tip_dnr': 'تنبيه مهم:\n\nالقيم المرتفعة المتكررة في DSC DPMO تشير إلى عمليات تسليم غير صحيحة أو محفوفة بالمخاطر.\n\n- قد تفسر أمازون الانحرافات المتكررة على أنها سرقة محتملة\n- قد يؤدي ذلك إلى بدء إجراء منع الخسائر\n- في أسوأ الحالات، قد يؤدي ذلك إلى إنهاء التعاون\n\nالمسح الدقيق، والتقاط الصور الصحيحة، والالتزام بجميع قواعد التسليم يحميك ويحمي فريقك.',

        'kpi_desc_lor': 'LoR (مفقود أثناء الطريق)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\n\nيوضح هذا المؤشر ما إذا تم تسجيل جميع الطرود غير المسلمة بشكل صحيح في نهاية المسار.\n\nفي نهاية المسار:\n- التحقق في الماسح الضوئي من عدد الطرود التي يجب إرجاعها\n- التأكد من أن هذا العدد يطابق تمامًا الطرود الموجودة في المركبة',

        'kpi_tip_lor': 'تنبيه مهم:\n\nهذه هي الفئة ذات أعلى اشتباه بالسرقة.\n\nقد تُعتبر الفروقات بين الماسح الضوئي ومخزون المركبة أخطاء جسيمة وقد تؤدي إلى تحقيقات داخلية أو عواقب أخرى.',

        'kpi_desc_pod': 'PoD (صورة عند التسليم)\n\nكلما كانت القيمة أعلى، كان ذلك أفضل.\n\nيعرض هذا العمود الطرود التي تم التقاط صورة لها ولكن تم تصنيفها على أنها غير صالحة أو غير آمنة.\n\nالأسباب الشائعة لرفض POD:\n1. ملصق الطرد مع بيانات العميل ظاهر (يجب قلب الطرد)\n2. صورة غير واضحة\n3. ظهور شخص في الصورة\n4. لا يظهر أي طرد في الصورة\n5. الطرد داخل المركبة\n6. الطرد في اليد\n7. الطرد قريب جدًا من الكاميرا\n8. الصورة مظلمة جدًا',

        'kpi_tip_pod': 'يجب أن تكون هذه أسهل فئة\nالقيمة المستهدفة: 100٪\nتحسن النتيجة الإجمالية بشكل كبير',

        'kpi_desc_cc': 'CC (التواصل مع العميل)\n\nكلما كانت القيمة أعلى، كان ذلك أفضل.\n\nمهم للغاية:\nيجب عليك دائمًا إرسال رسالة \"لا يوجد مكان آمن\" أو \"لم يتم العثور على العنوان\" في كل مرة لا تتمكن فيها من تسليم طرد لأن:\n\n- العميل غير موجود في المنزل أو\n- لا يمكن العثور على العنوان',

        'kpi_tip_cc': 'توجد رسالة قياسية تلقائية في التطبيق لكل سيناريو.',

        'kpi_desc_ce': 'CE (تصعيد من العميل)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\nأسوأ فئة على الإطلاق.\n\nيقوم العملاء بالتصعيد عندما لا يتم الالتزام بتعليمات التسليم.\n\nالسائق مسؤول دائمًا\nالاعتراضات شبه مستحيلة دون أدلة قوية جدًا\nله التأثير الأقوى على بطاقة الأداء الخاصة بك\n\nكيفية تجنب CE\n\nيُعد مخالفًا لإرشادات التسليم ترك الطرود في أماكن غير آمنة أو غير مراقبة دون موافقة\n\nيجب على Delivery Associates:\n- استخدام الجرس / جهاز الاتصال أو الطرق على الباب\n- منح العميل وقتًا كافيًا للرد\n\nإذا لم يكن من الممكن الوصول إلى العميل ولم يتم تحديد مكان آمن:\n- الاتصال بالعميل مرتين\n- إرسال رسالة نصية\n- التواصل مع Driver Support إذا لم يكن الاتصال ممكنًا\n\nإذا لزم الأمر:\n- مسح الطرد كـ \"فشل التسليم – العميل غير متاح\"\n- إعادة محاولة التسليم وفقًا للإرشادات',

        'kpi_tip_ce': 'لا تترك الطرود في أماكن غير آمنة أو غير معتمدة\nالتزم دائمًا بعمليات الشحن والتسليم الصحيحة',

        'kpi_desc_cdf': 'CDF DPMO (تقييم العميل لعملية التسليم)\n\nكلما كانت القيمة أقل، كان ذلك أفضل.\n\nالمستوى 1 (L1)\n- يقيم العميل عملية التسليم على أنها \"رائعة\" (👍) أو \"ليست جيدة\" (👎)\n\nالمستوى 2 (L2)\n- ملاحظات إضافية حول سبب كون التجربة جيدة أو سيئة',

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

    'faq_q1': 'ما هو الأهم في مهمتك اليومية؟',
    'faq_a1': 'تسليم الطرود بجودة وبسلوك جيد.',

    'faq_q2': 'ما الذي يجب ألا تفعله في حال حدوث مشاكل مع الزبون؟',
    'faq_a2': 'لا تحاول التعامل مع الموقف بنفسك، وبدلاً من ذلك أخبر المرسِل/المشرف المناوب. سنحاول التحدث إلى الزبون نيابةً عنك وتجنب أي عواقب سيئة من أمازون بسبب شكاوى الزبائن. نحن هنا من أجلك!',

    'faq_q3': 'ماذا لو كان الموقف قد تصاعد بالفعل والزبون غير سعيد لأي سبب حدث؟',
    'faq_a3': 'ليس هناك وقت متأخر لإصلاح أي أخطاء. اتصل بنا رغم ذلك وسنحاول إصلاح الخطأ مع الزبون. متأخرًا خير من ألا يأتي أبدًا.',

    'faq_q4': 'ما الأهم، الكمية (سرعة توصيل أكبر عدد ممكن من التوقفات) أم الجودة؟',
    'faq_a4': 'الجودة! دائمًا الجودة! اتبع تعليمات الزبون ولا تترك الطرد في أماكن غير آمنة فقط لأنك متأخر في التوقفات.',

    'faq_q5': 'ماذا لو ركّزت على الجودة لكنني تأخرت في التوقفات؟',
    'faq_a5': 'ستُنهي توقفاتك، بطريقة أو بأخرى. سنحاول إرسال مساعدة ولكن فقط إذا رأينا أن ذلك معقول.',

    'faq_q6': 'ما هو الـ scorecard وما هو DNR؟',
    'faq_a6': 'سعيدون أنك سألت.',

    'faq_q7': 'الـ Scorecard الأسبوعي',
    'faq_a7': 'يعطينا الـ scorecard الأسبوعي نظرة سريعة وواضحة على أداء الفريق تجاه أهدافنا الرئيسية. يساعدنا على تحديد ما يسير جيدًا، وأين نتأخر، وعلى ماذا يجب أن نركز للأسبوع القادم. النتائج الإجمالية كما يلي:\n'
    '• Fantastic Plus: >93% (أداء استثنائي)\n'
    '• Fantastic: 85% – 92.9%\n'
    '• Great: 70% – 84.9%\n'
    '• Fair: 50% – 69.9%\n'
    '• Poor: <50%',

    'faq_q7_1': 'تبويب DNR\nDelivered Not Received',
    'faq_a7_1': 'يحدث ذلك عندما تكون قد سلّمت طردًا، وضغطت زر "Swipe to finish" لتأكيد أنك سلّمت الطرد، لكن الزبون لم يستلم الطرد لعدة أسباب: سرقة الطرد، أن يكون الصندوق فارغًا من محتويات الطرد، أو التسليم الخاطئ إلى عنوان خاطئ.\n'
    'كل يوم ثلاثاء ستستلم صورًا لكل حالة DNR حصلت عليها خلال الأسبوع.',

    'faq_q7_1_1': 'كيف أتجنب ذلك وما مدى أهميته في الـ scorecard الأسبوعي؟',
    'faq_a7_1_1': 'هذا مهم جدًا ولتجنبه عليك ببساطة إبلاغ الزبون مسبقًا بأنك ستصل قريبًا إلى منزلهم/عملهم وأن ترن الجرس فقط الذي يحمل لوحة اسمهم.',

    'faq_q7_1_2': 'كيف أتجنب فقدان الطرود؟',
    'faq_a7_1_2': 'حاول دائمًا تسليم الطرود يدًا بيد إلى الزبون، وإذا لم يكن ذلك ممكنًا، أرسل رسالة تُبلغه أين تم ترك الطرد، على سبيل المثال في المرآب، تحت الدرج، في السقيفة، خلف مزهرية الزهور، إلخ..\n'
    'إذا كنت لا تعتقد أن ترك الطرد دون مراقبة آمن، فالخيار الأفضل دائمًا هو أخذ الطرد ومحاولة التسليم مرة أخرى لاحقًا. هذا مهم جدًا.',

    'faq_q7_1_3': 'كيف أعرف إن كان المكان آمنًا أم لا؟',
    'faq_a7_1_3': 'الحدس وأيضًا المنطق السليم. إذا كان المبنى يتكون من 20 - 30 طابقًا وتركت الطرد بجانب صناديق البريد، فاحتمالات سرقته تكون أعلى وأعلى مقارنةً ببيت خاص.\n'
    'كذلك، لمساعدتك في تسليماتك اليومية وتجنب التعرض لـ DNR، سننشر كل صباح صورة بعناوين لديها احتمالية عالية لسرقة الطرود وشكاوى الزبائن، بناءً على نتائج التسليم السابقة والإحصائيات.',

    'faq_q7_1_4': 'ماذا لو فُقد طرد أو سُرق، كيف سيؤثر ذلك على نتيجتي؟',
    'faq_a7_1_4': 'بشكل سيئ. سيؤثر عليك بنسبة لا تقل عن 30% وذلك مع طرد واحد فقط قد يخصم منك ما لا يقل عن 600 نقطة. كلما زادت النقاط التي تراها في الـ scorecard تحت اسمك، كان الوضع أسوأ. كلما زاد عدد الطرود التي تسلمها في أسبوع العمل، قلّت النقاط التي تخسرها. وتختلف النقاط التي تخسرها أيضًا حسب سعر العنصر المفقود؛ كلما كان أغلى، خُسرت نقاط أكثر. يجب أن نبقي قسم النتيجة هذا منخفضًا قدر الإمكان.\n'
    'ولا ينبغي تجاهل حقيقة أنه إذا كان لديك بانتظام عدد كبير من الطرود المفقودة، فسيتعين علينا الاستغناء عنك لأن أمازون قد تشتبه عاجلاً أم آجلاً بسرقة الطرود، ولذلك فهذا أمر خطير جدًا.',

    'faq_q7_2': 'تبويب CC\n'
    'Contact Compliance',
    'faq_a7_2': 'يعني عدد المرات التي تواصلت فيها مع الزبون بشأن تسليمه، سواء عبر رسالة أو مكالمة هاتفية. كلما قل تفاعلك مع الزبون، قلّت النقاط التي ستحصل عليها في الـ scorecard، ويجب أن نبقي هذا القسم مرتفعًا قدر الإمكان لأنه في الواقع من أسهل الفئات ويساعد كثيرًا في نتيجتك الإجمالية.',

    'faq_q7_2_1': 'لماذا يجب أن أفعل هذا؟',
    'faq_a7_2_1': 'تسليم الطرود ليس مجرد Drop&Go، يجب عليك أيضًا إبلاغ الزبون مسبقًا وسؤاله أين يود أن يتم تسليم الطرد.',

    'faq_q7_2_2': 'كيف أحسن درجات CC الخاصة بي؟',
    'faq_a7_2_2': 'شكرًا لسؤالك. بسيط: بالاتصال وخاصة بإرسال الرسائل للزبائن في كل توقف.',

    'faq_q7_3': 'تبويب CE\nCostumer Escalation',
    'faq_a7_3': 'هل تتذكر مدى سوء تأثير DNR على درجاتك؟ حسنًا، هذا أسوأ على الأقل بمرتين، كما أنك تخاطر بفقدان وظيفتك لأنه يعتمد على مدى سوء الوضع.',

    'faq_q7_3_1': 'كيف أتجنب ذلك؟',
    'faq_a7_3_1': 'باتباع تعليمات تسليم الزبون دائمًا، وفي حال حدوث خطأ، اعتذر أولاً، وإذا كان الزبون غاضبًا فاطلب منه دقيقة من وقته للتحدث معنا بينما أنت تتصل بنا بالفعل. بقراءة القسم 2، يجب أن تعرف الآن أنه من الأفضل تركنا نتعامل مع مثل هذه القضايا.',

    'faq_q7_4': 'تبويب POD\nPicture on Delivery',
    'faq_a7_4': 'يعرض هذا العمود قائمة الطرود المؤهلة لـ POD والتي تم التقاط صور لها لكنها كانت إما Invalid أو Not Sure. أسباب رفض POD قد تشمل:\n'
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
    'faq_a7_5': 'يعاقبك عندما تكون قد مسحت/سكنت طردًا من التحميل ولم تقم بإرجاعه في نهاية الوردية في حال فشل التسليم. وبالتالي يكون الطرد قد فُقد وستفقد نقاطًا بقدر ما ستفقده في DNR، لذا يرجى عدّ الطرود التي تعيدها جيدًا والتأكد من أنها تطابق الطرود المعروضة في الجهاز. يمكنك العثور عليها في: Todays Itinerary - Summary - Problems. إذا لم تتطابق، يرجى إبلاغ المرسِل/المشرف المناوب قبل إنهاء العمل في تطبيق أمازون.',

    'faq_q7_6': 'تبويب DCR\nDelivery Completion Rate',
    'faq_a7_6': 'يعرض قدراتك على تسليم الطرود. يتتبع نسبة التسليمات التي تمت كما هو مخطط، مما يساعدنا على قياس كفاءة وموثوقية تسليماتنا. يبرز مشكلات مثل التأخيرات، المحاولات الفاشلة، أو مشاكل التوجيه. يجب أن يكون هذا مرتفعًا قدر الإمكان. ولتحقيق ذلك يجب أن تقوم يوميًا بمحاولات إعادة التسليم (reattempts) وتجنب قدر الإمكان إعادة الطرود.',

    'faq_q7_7': 'تبويب CDF (Previously, DEX)\nCostumer Delivery Feedback',
    'faq_a7_7': 'يلتقط تجربة المستلم مع عملية التسليم، بما في ذلك الالتزام بالمواعيد، حالة البضائع، واحترافية السائق. يساعدنا على تحديد نقاط القوة ومجالات التحسين. في نهاية التسليم، يحصل الزبون على بريد إلكتروني من أمازون حول تجربة التسليم، مع أسئلة مثل:\n'
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
    'faq_a7_8': 'الجودة والكفاءة تقطع شوطًا طويلاً. الدرجات الجيدة جيدة لك، وللشركة، وجيدة للفريق بأكمله. رضا الزبون مهم جدًا والدرجات الجيدة تكون مصحوبة بمكافأة من الشركة.\n'
    'ابذل أفضل ما لديك، تحصل على الأفضل.',

    'faq_q8': 'ما المجالات الأخرى التي يجب أن أكون حذرًا بشأنها؟',
    'faq_a8': 'الاعتناء بنفسك بالقيادة بأمان، وتجنب الإصابات وتجنب الكلاب وعضّات الكلاب. الحذر مع معدات العمل مثل السيارة اليومية، جهاز المسح/الهاتف الخاص بالعمل والحضور إلى العمل مرتديًا حذاء السلامة وسترة السلامة، وسترة أو قميص بعلامة أمازون (حسب الطقس).',

    'faq_q9': 'ماذا يحدث إذا تعرضت لحادث سيارة أو أتلفت مركبة العمل؟',
    'faq_a9': 'أولاً، تأكد أنك بخير وأنك لست مصابًا بجروح خطيرة. أما بخصوص ضرر السيارة، فإذا قررنا أن الحوادث تحدث بسبب الإهمال – على سبيل المثال، تشتت الانتباه مثل استخدام الهاتف المحمول أثناء القيادة – فستكون مسؤولاً شخصيًا عن كامل الضرر. بالإضافة إلى ذلك، ستحصل على تقرير من الشرطة، والذي قد يؤدي حتى إلى تعليق الرخصة. وبالطبع، هذا أيضًا سبب للفصل الفوري. وإلا فسيتم فقط استبعادك من الحصول على مكافآت الـ Weekly Scorecard لمدة شهرين. في حالة حدوث حادث، أنت مُلزم بإبلاغنا فورًا وتزويدنا بوقت الحادث، والموقع، وما إذا كان هناك أضرار لممتلكات خاصة أو عامة (مثل الجدران، الأسوار، أعمدة الإنارة، الأشخاص و/أو الحيوانات الأليفة)، والموقع وصور أضرار السيارة.',

    'faq_q10': 'ماذا أفعل عندما تكون لدي طرود تالفة و/أو مفقودة.',
    'faq_a10': 'عندما يكون الطرد تالفًا، لا تتردد في تسجيله كتالف وإعادته إلى المحطة. إذا كان الطرد التالف يحتوي على سوائل وأتلف طرودًا أخرى معه، يرجى التقاط صورة لجميع الطرود التالفة وإرسالها إلى المرسِل/المشرف المناوب وسنقوم بالإبلاغ إلى أمازون نيابةً عنك.\n'
    'عندما يكون الطرد مفقودًا، لا تتردد في وضع علامة/تسجيل أنه مفقود إلا إذا كان يحتوي على OTP، وفي هذه الحالة يجب عليك إبلاغنا أولاً قبل وضع علامة أنه مفقود. هذا مهم جدًا.',

    'faq_q11': 'ما هو طرد OTP (One-Time Password)؟',
    'faq_a11': 'هو عنصر باهظ الثمن تطلب أمازون من الزبون أن يزوّد السائق بكلمة مرور لمرة واحدة قبل تسليم الطرد، لضمان أن الطرد سُلّم للشخص/الزبون الصحيح. يجب أن تعتني بهذه الطرود بعناية كبيرة، وألا تتركها دون مراقبة وأن تسلمها فقط للزبون الذي قدّم لك كلمة المرور.',

    'faq_q12': 'لماذا نستمر في إزعاجك لتبطئ ولا تذهب أسرع؟',
    'faq_a12': 'نحن أيضًا لا نحب ذلك، لكن هذا هو النظام. نحتاج إلى اتباع خوارزمية النظام والقيام بعدد من التوقفات في الساعة كما هو محدد مسبقًا حتى نحصل على المزيد من المسارات في المستقبل وتعمل أكثر ولا تكون متفرغًا.\n'
    'كما أن الذهاب أسرع يعرضك لخطر DNR وخسارة نقاط لكلا الطرفين، لنفسك وللشركة، في الـ scorecard الأسبوعي.',

    'faq_q13': 'إذًا لماذا يسألني المرسِلون/المشرفون أحيانًا لماذا أنت متأخر وهل هناك شيء خاطئ؟',
    'faq_a13': 'نعلم أن هذا غير مريح، لكننا نحتاج بعض الملاحظات حول ما الذي قد يكون حدث على الطريق وأدى إلى تأخرك في التوقفات. أمازون يطلب منا هذه الملاحظات لأن هناك أيضًا حدًا زمنيًا كان يجب أن تكون قد سلّمت خلاله X توقف، لذلك تحتاج أمازون إلى معرفة لماذا التوقفات المتبقية متأخرة عن جدول التسليم وبهذه المعلومات تحسن كفاءة التسليم في المستقبل.',

    'faq_q14': 'لماذا نطلب منك أحيانًا أن تذهب لمساعدة زميل؟',
    'faq_a14': 'لأن هناك عوامل كثيرة تؤثر في تأخر الزميل مثل ضعف اتصال الإنترنت في المنطقة، الازدحام، إغلاق الطرق بسبب أعمال البناء في المنطقة مما جعل من الصعب على السائق الآخر التسليم في الوقت المحدد، لذلك نحتاج مساعدتك.',

    'faq_q15': 'هل أبدأ فورًا في يومي الأول بتسليم طرود المسار القياسي مثل غيري من السائقين الأكثر خبرة؟',
    'faq_a15': 'لا، من الواضح أن هذا ليس الحال بالنسبة لك. في البداية سيكون لديك فترة 14 يوم عمل لتطبيق ما تعلمته في أيام الركوب مع المدرب والتأقلم مع المنطقة، السيارة، الجهاز وتعلم سير العمل.\n'
    'وبناءً على ذلك، خلال تلك الفترة البالغة 14 يومًا، ستمنحك أمازون ما يصل إلى 50% أقل من الطرود والتوقفات المعتادة في جدولك.',

    'faq_q16': 'ماذا أفعل عندما يكون العنوان خاطئًا و/أو دبوس الموقع غير صحيح على الخريطة؟',
    'faq_a16': 'أولاً أكد أن الدبوس غير صحيح من خلال البحث عن العنوان في خرائط Google (أدق وهو مثبت بالفعل على جهازك) وإذا لم يتطابق، أخبر المرسِل/المشرف المناوب بالأخطاء.',

    'faq_q17': 'ما هي مهامي اليومية قبل أن أبدأ وبعد أن أنهي العمل؟',
    'faq_a17': '1- عندما تدخل إلى الموقف، تأكد أولاً أنك ترتدي حذاء السلامة وسترة السلامة وبدلة أمازون.\n'
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

    'faq_q18': 'هل يجب أن أفعل أي شيء عندما أغير الفان وأخذ فانًا آخر بدلًا من الذي أستخدمه عادةً؟',
    'faq_a18': 'يجب أن تصوّر فيديو له، يلتقط بالتفصيل كل ضرر صغير ربما أحدثه السائق/السائقون السابقون، حتى لا يكون الخطأ عليك في الفحص التالي للسيارة.',

    'faq_q19': 'ماذا يجب أن أفعل إذا كان تطبيق Flex يقوم بالتحميل باستمرار ويبطئ سير عملي؟',
    'faq_a19': 'تحقق أولاً مما إذا كان لديك اتصال إنترنت نشط. للقيام بذلك يمكنك محاولة إرسال رسالة إلى زبون التوقف الحالي وإذا تمت بنجاح فهذا يعني أن اتصال الإنترنت نشط. يمكنك أيضًا التحقق بفتح تطبيق آخر على الجهاز مثل المتصفح والبحث عن شيء.\n'
    'الخطوات التي يجب اتباعها إذا لم يكن هناك اتصال إنترنت نشط:\n'
    '1- أعد تشغيل جهازك. يجب أن يكون هذا دائمًا أول شيء تجرّبه.\n'
    '2- شغّل/أوقف وضع الطيران. هذا يعمل معظم الوقت دون الحاجة لانتظار إعادة التشغيل.\n'
    '3- كحل أخير جدًا، حاول مشاركة نقطة اتصال من هاتفك الشخصي لمدة 10 دقائق كحد أقصى فقط لكي يقوم النظام بتحديث نفسه.\n'
    'يمكنك أيضًا العمل دون اتصال لكن في مرحلة ما يجب أن تتصل بالإنترنت وتكون نشطًا. للعمل دون اتصال يجب أولاً تنزيل الخرائط غير المتصلة في تطبيق Flex. للقيام بذلك، اذهب إلى Settings - Offline Maps (الخيار الأخير) - Download DBY5 - Allow downloads with mobile connection.\n',

    'faq_q20': 'ماذا لو كان اتصال الإنترنت نشطًا لكن تطبيق Flex ما زال لا يعمل كما ينبغي؟',
    'faq_a20': '1- أعد تشغيل الجهاز.\n'
    '2- شغّل/أوقف وضع الطيران\n'
    '3- اخرج من التطبيق\n'
    '4- أوقف/شغّل خدمات الموقع (GPS)\n'
    '5- سجّل الخروج من تطبيق Flex ثم سجّل الدخول مرة أخرى باستخدام بيانات الاعتماد التي تستخدمها لتطبيق Mentor.\n'
    '6- تحقق مما إذا كان التطبيق يحتاج إلى تحديث.\n'
    'يجب أن تجرب هذه الخطوات واحدة تلو الأخرى. إذا لم تعمل واحدة، يرجى تجربة التالية بعدها.',

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
