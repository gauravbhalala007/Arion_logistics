// lib/Screens/driver_residence_permit_form_page.dart
//
// Multi-Step-Formular auf Albanisch zur Erfassung der Daten fuer den
// "Antrag auf Erteilung der Aufenthaltserlaubnis" (Bundesformular).
//
// Workflow:
//   1) Admin oeffnet das Formular vom Driver-Detail
//   2) Fahrer beantwortet 7 Schritte auf Albanisch
//   3) Vorhandene Daten werden vorbefuellt (Name, Geburt, etc.)
//   4) Am Ende unterschreibt der Fahrer per Touch/Mouse
//   5) Daten werden separat unter
//      users/{dspUid}/drivers/{tid}/residencePermitForm gespeichert
//
// Wichtig: PDF-Generierung erfolgt serverseitig (Cloud Function), damit
// die Original-PDF-Struktur unveraendert bleibt — der Server overlay-ed
// nur Text+Signatur an festen Koordinaten.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

// ============================================================
//  Albanian copy
// ============================================================

class _L {
  static const title = 'Aplikim për lejen e qëndrimit';
  static const subtitle = 'Aplikim për leje qëndrimi në Gjermani';
  static const intro =
      'Para se të nënshkruash, ju lutemi plotësoni të gjitha të dhënat me kujdes. '
      'Të dhënat e pasakta mund të çojnë në refuzim të aplikimit ose dëbim.';
  static const next = 'Vazhdo';
  static const back = 'Mbrapa';
  static const save = 'Ruaj';
  static const submit = 'Përfundo dhe nënshkruaj';
  static const finished = 'Aplikimi u ruajt.';
  static const required_ = 'E nevojshme';
  static const yes = 'Po';
  static const no = 'Jo';
  static const close = 'Mbyll';
  static const consentTitle = 'A jeni dakord t\'i plotësoni këto të dhëna?';
  static const consentBody =
      'Përgjegjësi yt: nga ti pranohet se të dhënat janë të vërteta. '
      'Të dhënat e rreme janë të dënueshme dhe mund të jenë arsye për dëbim. '
      'Para se të nënshkruash, do të të kërkohen pyetje hap pas hapi.';
  static const consentAgree = 'Po, jam dakord';
  static const consentCancel = 'Anulo';

  static const stepPersonal = '1. Të dhënat personale';
  static const stepAddress = '2. Adresa';
  static const stepFamily = '3. Familja';
  static const stepParents = '4. Prindërit';
  static const stepTravel = '5. Pasaporta dhe hyrja';
  static const stepWork = '6. Puna dhe sigurimi';
  static const stepLegal = '7. E kaluara ligjore';
  static const stepSignature = '8. Nënshkrimi';

  // Personal
  static const familyName = 'Mbiemri';
  static const givenNames = 'Emri (emrat)';
  static const maidenName = 'Mbiemri i lindjes (vajzëria)';
  static const birthDate = 'Data e lindjes';
  static const birthPlace = 'Vendi i lindjes';
  static const nationalityCurrent = 'Shtetësia aktuale';
  static const nationalityFormer = 'Shtetësia e mëparshme';
  static const maritalStatus = 'Statusi martesor';
  static const ms_single = 'Beqar/e';
  static const ms_married = 'I/E martuar';
  static const ms_separated = 'I/E ndarë';
  static const ms_divorced = 'I/E divorcuar';
  static const ms_widowed = 'I/E ve';
  static const maritalSince = 'Që nga (datë)';
  static const height = 'Lartësia (cm)';
  static const eyeColor = 'Ngjyra e syve';

  // Address
  static const currentAddress = 'Adresa aktuale (rrugë, numër, kod postar, qytet)';
  static const otherAddresses = 'Adresa të tjera?';
  static const otherAddressesDetails = 'Të dhënat e adresave të tjera';

  // Spouse
  static const spouseHeader = 'Bashkëshorti / Bashkëshortja (vetëm nëse i/e martuar)';
  static const spouseFamilyName = 'Mbiemri i bashkëshortit';
  static const spouseGivenName = 'Emri i bashkëshortit';
  static const spouseBirth = 'Data dhe vendi i lindjes';
  static const spouseNationality = 'Shtetësia';
  static const spouseAddress = 'Adresa';

  // Children
  static const childrenHeader = 'Fëmijët (deri në 4)';
  static const addChild = 'Shto fëmijë';
  static const removeChild = 'Hiq';
  static const childName = 'Emri i plotë';
  static const childGivenName = 'Emri';
  static const childFamilyName = 'Mbiemri';
  static const childBirth = 'Data e lindjes';
  static const childNationality = 'Shtetësia';
  static const childAddress = 'Adresa';

  // Parents
  static const fatherHeader = 'Babai i aplikantit';
  static const motherHeader = 'Nëna e aplikantit';
  static const parentFamilyName = 'Mbiemri';
  static const parentGivenName = 'Emri';
  static const parentBirthDate = 'Data e lindjes';

  // Travel & passport
  static const passportType = 'Lloji i dokumentit të udhëtimit';
  static const passportTypePassport = 'Pasaportë';
  static const passportTypeOther = 'Dokument tjetër';
  static const passportNumber = 'Numri i dokumentit';
  static const passportIssuedBy = 'Lëshuar nga (autoriteti)';
  static const passportIssuedOn = 'Lëshuar më';
  static const passportValidUntil = 'Vlefshëm deri më';
  static const rightOfReturn =
      'E drejta për kthim (nëse është shënuar në pasaportë) - ku dhe deri kur?';
  static const enteredGermany = 'Data e hyrjes në Gjermani';
  static const hasVisa = 'A keni vizë?';
  static const visaPurpose = 'Për çfarë qëllimi është lëshuar viza?';
  static const stayedBefore = 'A keni qëndruar më parë në Gjermani?';
  static const stayedBeforeDetails = 'Kur dhe ku?';
  static const arrivedOn = 'Data e ardhjes në vendin aktual';
  static const arrivedFrom = 'Ardhur nga (vendi i mëparshëm)';
  static const maintainsAbroad =
      'A mbani vendbanim të përhershëm jashtë Gjermanisë?';
  static const maintainsAbroadPlace = 'Ku?';
  static const purposeOfStay = 'Qëllimi i qëndrimit';
  static const intendedDuration = 'Kohëzgjatja e parashikuar';

  // Work
  static const profession = 'Profesioni i mësuar';
  static const employer = 'Punëdhënësi (emri + adresa) ose burimi i mjeteve të jetesës';
  static const hasHealthInsurance = 'A keni sigurim shëndetësor?';
  static const receivesSocial =
      'A merrni përfitime sociale për veten ose familjen?';
  static const socialDetails = 'Detajet (çfarë lloj përfitimi)';

  // Legal history
  static const convictedInGermany = 'A jeni dënuar në Gjermani?';
  static const convictedAbroad = 'A jeni dënuar jashtë Gjermanisë?';
  static const convictionsDetails =
      'Kur, ku, arsyeja dhe lloji + masa e dënimit?';
  static const expelled =
      'A jeni dëbuar nga Gjermania, refuzuar leje qëndrimi ose ndaluar të hyni?';
  static const expelledDetails = 'Detajet';

  // Signature
  static const signatureTitle = 'Nënshkrimi';
  static const signatureIntro =
      'Me nënshkrimin tim konfirmoj që të dhënat e mësipërme janë të sakta '
      'dhe të plota sipas dijenisë sime më të mirë. Të dhënat e pasakta janë '
      'të dënueshme dhe mund të çojnë në dëbim.';
  static const signaturePlace = 'Vendi (qyteti)';
  static const signatureDate = 'Data';
  static const signatureClear = 'Pastro';
  static const signatureHint = 'Vendosni nënshkrimin tuaj këtu';
}

// ============================================================
//  Page
// ============================================================

class DriverResidencePermitFormPage extends StatefulWidget {
  final String dspUid;
  final String driverDocId;

  const DriverResidencePermitFormPage({
    super.key,
    required this.dspUid,
    required this.driverDocId,
  });

  @override
  State<DriverResidencePermitFormPage> createState() =>
      _DriverResidencePermitFormPageState();
}

class _DriverResidencePermitFormPageState
    extends State<DriverResidencePermitFormPage> {
  int _step = 0;
  static const _totalSteps = 8;
  bool _busy = false;
  bool _loadedExisting = false;

  // Step 1: Personal
  final _familyNameCtrl = TextEditingController();
  final _givenNamesCtrl = TextEditingController();
  final _maidenNameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();
  final _nationalityCurrentCtrl = TextEditingController();
  final _nationalityFormerCtrl = TextEditingController();
  String _maritalStatus = 'single';
  final _maritalSinceCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _eyeColorCtrl = TextEditingController();

  // Step 2: Address
  final _currentAddressCtrl = TextEditingController();
  bool _hasOtherAddresses = false;
  final _otherAddressesCtrl = TextEditingController();

  // Step 3: Spouse + Children
  final _spouseFamilyCtrl = TextEditingController();
  final _spouseGivenCtrl = TextEditingController();
  final _spouseBirthCtrl = TextEditingController();
  final _spouseNationalityCtrl = TextEditingController();
  final _spouseAddressCtrl = TextEditingController();
  final List<_ChildEntry> _children = [];

  // Step 4: Parents
  final _fatherFamilyCtrl = TextEditingController();
  final _fatherGivenCtrl = TextEditingController();
  final _fatherBirthCtrl = TextEditingController();
  final _motherFamilyCtrl = TextEditingController();
  final _motherGivenCtrl = TextEditingController();
  final _motherBirthCtrl = TextEditingController();

  // Step 5: Travel
  String _passportType = 'passport';
  final _passportNumberCtrl = TextEditingController();
  final _passportIssuedByCtrl = TextEditingController();
  final _passportIssuedOnCtrl = TextEditingController();
  final _passportValidUntilCtrl = TextEditingController();
  final _rightOfReturnCtrl = TextEditingController();
  final _enteredGermanyCtrl = TextEditingController();
  bool _hasVisa = false;
  final _visaPurposeCtrl = TextEditingController();
  bool _stayedBefore = false;
  final _stayedBeforeDetailsCtrl = TextEditingController();
  final _arrivedOnCtrl = TextEditingController();
  final _arrivedFromCtrl = TextEditingController();
  bool _maintainsAbroad = false;
  final _maintainsAbroadPlaceCtrl = TextEditingController();
  final _purposeOfStayCtrl = TextEditingController();
  final _intendedDurationCtrl = TextEditingController();

  // Step 6: Work
  final _professionCtrl = TextEditingController();
  final _employerCtrl = TextEditingController();
  bool _hasHealthInsurance = true;
  bool _receivesSocial = false;
  final _socialDetailsCtrl = TextEditingController();

  // Step 7: Legal
  bool _convictedInGermany = false;
  bool _convictedAbroad = false;
  final _convictionsDetailsCtrl = TextEditingController();
  bool _expelled = false;
  final _expelledDetailsCtrl = TextEditingController();

  // Step 8: Signature
  late final SignatureController _signatureCtrl;
  final _signaturePlaceCtrl = TextEditingController(text: 'Erlangen');
  final _signatureDateCtrl = TextEditingController();

  DocumentReference<Map<String, dynamic>> get _driverRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .doc(widget.driverDocId);

  DocumentReference<Map<String, dynamic>> get _formRef =>
      _driverRef.collection('forms').doc('residencePermit');

  @override
  void initState() {
    super.initState();
    _signatureCtrl = SignatureController(
      penStrokeWidth: 2.5,
      penColor: const Color(0xFF111827),
      exportBackgroundColor: Colors.white,
    );
    _signatureDateCtrl.text =
        DateFormat('dd.MM.yyyy', 'de_DE').format(DateTime.now());
    _loadInitialData();
  }

  @override
  void dispose() {
    for (final c in [
      _familyNameCtrl,
      _givenNamesCtrl,
      _maidenNameCtrl,
      _birthDateCtrl,
      _birthPlaceCtrl,
      _nationalityCurrentCtrl,
      _nationalityFormerCtrl,
      _maritalSinceCtrl,
      _heightCtrl,
      _eyeColorCtrl,
      _currentAddressCtrl,
      _otherAddressesCtrl,
      _spouseFamilyCtrl,
      _spouseGivenCtrl,
      _spouseBirthCtrl,
      _spouseNationalityCtrl,
      _spouseAddressCtrl,
      _fatherFamilyCtrl,
      _fatherGivenCtrl,
      _fatherBirthCtrl,
      _motherFamilyCtrl,
      _motherGivenCtrl,
      _motherBirthCtrl,
      _passportNumberCtrl,
      _passportIssuedByCtrl,
      _passportIssuedOnCtrl,
      _passportValidUntilCtrl,
      _rightOfReturnCtrl,
      _enteredGermanyCtrl,
      _visaPurposeCtrl,
      _stayedBeforeDetailsCtrl,
      _arrivedOnCtrl,
      _arrivedFromCtrl,
      _maintainsAbroadPlaceCtrl,
      _purposeOfStayCtrl,
      _intendedDurationCtrl,
      _professionCtrl,
      _employerCtrl,
      _socialDetailsCtrl,
      _convictionsDetailsCtrl,
      _expelledDetailsCtrl,
      _signaturePlaceCtrl,
      _signatureDateCtrl,
    ]) {
      c.dispose();
    }
    for (final ch in _children) {
      ch.dispose();
    }
    _signatureCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final driverSnap = await _driverRef.get();
      final driver = driverSnap.data() ?? {};
      final formSnap = await _formRef.get();
      final form = formSnap.data() ?? {};

      // Prefill from driver doc first, then override with previously
      // saved form values (form > driver doc).
      String pickStr(List<dynamic> vals) {
        for (final v in vals) {
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return '';
      }

      final onboarding =
          (driver['onboarding'] as Map?)?.cast<String, dynamic>() ??
              const {};

      // Resolve a single family/given-name pair. We prefer the
      // structured onboarding 'fullName' field, fall back to the
      // top-level driverName, and split "last token = family, rest =
      // given names" (Western convention used in the existing app).
      String pickName(List<dynamic> vals) {
        for (final v in vals) {
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return '';
      }

      final combinedName = pickName([
        onboarding['fullName'],
        driver['driverName'],
      ]);
      final nameParts = combinedName.split(RegExp(r'\s+'));
      final driverFamily = nameParts.length > 1 ? nameParts.last : '';
      final driverGiven = nameParts.length > 1
          ? nameParts.sublist(0, nameParts.length - 1).join(' ')
          : combinedName;

      // Personal
      final personal =
          (form['personal'] as Map?)?.cast<String, dynamic>() ?? const {};
      _familyNameCtrl.text = pickStr([
        personal['familyName'],
        onboarding['lastName'],
        onboarding['surname'],
        onboarding['familyName'],
        driverFamily,
      ]);
      _givenNamesCtrl.text = pickStr([
        personal['givenNames'],
        onboarding['firstName'],
        onboarding['givenNames'],
        driverGiven,
      ]);
      _maidenNameCtrl.text = pickStr([
        personal['maidenName'],
        onboarding['nameAtBirth'],
        onboarding['maidenName'],
      ]);
      _birthDateCtrl.text = pickStr([
        personal['birthDate'],
        onboarding['dateOfBirth'],
        onboarding['birthDate'],
        driver['dateOfBirth'],
        driver['birthDate'],
      ]);
      // Compose "City, State" if both are present in onboarding.
      final birthCity = pickStr([
        onboarding['birthCity'],
        driver['birthCity'],
      ]);
      final birthState = pickStr([
        onboarding['birthState'],
        driver['birthState'],
      ]);
      final composedBirthPlace = [birthCity, birthState]
          .where((s) => s.isNotEmpty)
          .join(', ');
      _birthPlaceCtrl.text = pickStr([
        personal['birthPlace'],
        composedBirthPlace,
        onboarding['birthPlace'],
      ]);
      _nationalityCurrentCtrl.text = pickStr([
        personal['nationalityCurrent'],
        onboarding['nationalityIdCard'],
        onboarding['nationality'],
        onboarding['citizenship'],
      ]);
      _nationalityFormerCtrl.text = pickStr([
        personal['nationalityFormer'],
        onboarding['previousNationality'],
      ]);
      _maritalStatus = (personal['maritalStatus'] as String?) ??
          (onboarding['maritalStatus'] as String?) ??
          'single';
      _maritalSinceCtrl.text = pickStr([
        personal['maritalSince'],
        onboarding['maritalSince'],
      ]);
      _heightCtrl.text = pickStr([
        personal['heightCm']?.toString(),
        onboarding['heightCm']?.toString(),
        onboarding['height']?.toString(),
      ]);
      _eyeColorCtrl.text = pickStr([
        personal['eyeColor'],
        onboarding['eyeColor'],
      ]);

      // Address — compose street + postal code + city + country into a
      // multi-line block so the form field reads like a postal label.
      final address =
          (form['address'] as Map?)?.cast<String, dynamic>() ?? const {};
      final street = pickStr([
        onboarding['address'],
        onboarding['street'],
        driver['address'],
      ]);
      final postal = pickStr([
        onboarding['postalCode'],
        onboarding['zip'],
        driver['postalCode'],
      ]);
      final city = pickStr([
        onboarding['city'],
        driver['city'],
      ]);
      final country = pickStr([
        onboarding['country'],
        driver['country'],
      ]);
      final composedAddress = <String>[
        if (street.isNotEmpty) street,
        if (postal.isNotEmpty || city.isNotEmpty)
          [postal, city].where((s) => s.isNotEmpty).join(' '),
        if (country.isNotEmpty) country,
      ].join('\n');
      _currentAddressCtrl.text = pickStr([
        address['current'],
        composedAddress,
      ]);
      _hasOtherAddresses = (address['hasOther'] as bool?) ?? false;
      _otherAddressesCtrl.text = pickStr([address['otherDetails']]);

      // Spouse
      final spouse =
          (form['spouse'] as Map?)?.cast<String, dynamic>() ?? const {};
      _spouseFamilyCtrl.text = pickStr([spouse['familyName']]);
      _spouseGivenCtrl.text = pickStr([spouse['givenName']]);
      _spouseBirthCtrl.text = pickStr([spouse['birthDateAndPlace']]);
      _spouseNationalityCtrl.text = pickStr([spouse['nationality']]);
      _spouseAddressCtrl.text = pickStr([spouse['address']]);

      // Children
      _children.clear();
      final childrenRaw =
          (form['children'] as List?)?.cast<dynamic>() ?? const [];
      for (final c in childrenRaw) {
        if (c is Map) {
          _children.add(_ChildEntry.fromMap(c.cast<String, dynamic>()));
        }
      }

      // Parents
      final parents =
          (form['parents'] as Map?)?.cast<String, dynamic>() ?? const {};
      final father =
          (parents['father'] as Map?)?.cast<String, dynamic>() ?? const {};
      final mother =
          (parents['mother'] as Map?)?.cast<String, dynamic>() ?? const {};
      _fatherFamilyCtrl.text = pickStr([father['familyName']]);
      _fatherGivenCtrl.text = pickStr([father['givenName']]);
      _fatherBirthCtrl.text = pickStr([father['birthDate']]);
      _motherFamilyCtrl.text = pickStr([mother['familyName']]);
      _motherGivenCtrl.text = pickStr([mother['givenName']]);
      _motherBirthCtrl.text = pickStr([mother['birthDate']]);

      // Travel — pre-fill passport validity from the ID-doc expiry we
      // already collected during onboarding, plus work start date as a
      // reasonable proxy for "Einreisedatum" so the form is mostly full.
      final travel =
          (form['travel'] as Map?)?.cast<String, dynamic>() ?? const {};
      _passportType =
          (travel['passportType'] as String?) ?? 'passport';
      _passportNumberCtrl.text = pickStr([
        travel['passportNumber'],
        onboarding['passportNumber'],
        onboarding['idDocNumber'],
      ]);
      _passportIssuedByCtrl.text = pickStr([
        travel['issuedBy'],
        onboarding['passportIssuedBy'],
      ]);
      _passportIssuedOnCtrl.text = pickStr([
        travel['issuedOn'],
        onboarding['passportIssuedOn'],
      ]);
      _passportValidUntilCtrl.text = pickStr([
        travel['validUntil'],
        onboarding['passportExpiry'],
        onboarding['idDocExpiry'],
      ]);
      _rightOfReturnCtrl.text = pickStr([travel['rightOfReturn']]);
      _enteredGermanyCtrl.text = pickStr([
        travel['enteredOn'],
        onboarding['enteredGermany'],
        onboarding['workStartDate'],
      ]);
      _hasVisa = (travel['hasVisa'] as bool?) ??
          (onboarding['workPermitType'] == 'working_visa');
      _visaPurposeCtrl.text = pickStr([
        travel['visaPurpose'],
        onboarding['visaPurpose'],
        if (onboarding['workPermitType'] == 'working_visa')
          'Arbeit als Auslieferungsfahrer',
      ]);
      _stayedBefore = (travel['stayedBefore'] as bool?) ?? false;
      _stayedBeforeDetailsCtrl.text =
          pickStr([travel['stayedBeforeDetails']]);
      _arrivedOnCtrl.text = pickStr([travel['arrivedOn']]);
      _arrivedFromCtrl.text = pickStr([travel['arrivedFrom']]);
      _maintainsAbroad =
          (travel['maintainsResidenceAbroad'] as bool?) ?? false;
      _maintainsAbroadPlaceCtrl.text =
          pickStr([travel['residenceAbroadPlace']]);
      _purposeOfStayCtrl.text = pickStr([
        travel['purposeOfStay'],
        'Beschäftigung als Zusteller (Paketauslieferung)',
      ]);
      _intendedDurationCtrl.text = pickStr([
        travel['intendedDuration'],
        'unbefristet',
      ]);

      // Work — pre-fill employer block from the DSP user doc so the
      // driver doesn't have to type the company name + address again.
      final work =
          (form['work'] as Map?)?.cast<String, dynamic>() ?? const {};
      String dspEmployerBlock = '';
      try {
        final dspSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.dspUid)
            .get();
        final dsp = dspSnap.data() ?? {};
        final dspCompany = pickStr([
          dsp['companyName'],
          dsp['dspName'],
          dsp['name'],
          dsp['businessName'],
        ]);
        final dspStreet = pickStr([dsp['address'], dsp['street']]);
        final dspPostal = pickStr([dsp['postalCode'], dsp['zip']]);
        final dspCity = pickStr([dsp['city']]);
        dspEmployerBlock = <String>[
          if (dspCompany.isNotEmpty) dspCompany,
          if (dspStreet.isNotEmpty) dspStreet,
          if (dspPostal.isNotEmpty || dspCity.isNotEmpty)
            [dspPostal, dspCity].where((s) => s.isNotEmpty).join(' '),
        ].join('\n');
      } catch (_) {}
      _professionCtrl.text = pickStr([
        work['profession'],
        onboarding['profession'],
        onboarding['occupation'],
        'Auslieferungsfahrer / Paketzusteller',
      ]);
      _employerCtrl.text = pickStr([
        work['employer'],
        dspEmployerBlock,
      ]);
      _hasHealthInsurance =
          (work['hasHealthInsurance'] as bool?) ?? true;
      _receivesSocial = (work['receivesSocialBenefits'] as bool?) ?? false;
      _socialDetailsCtrl.text = pickStr([work['socialBenefitsDetails']]);

      // Legal
      final legal =
          (form['legal'] as Map?)?.cast<String, dynamic>() ?? const {};
      _convictedInGermany =
          (legal['convictedInGermany'] as bool?) ?? false;
      _convictedAbroad = (legal['convictedAbroad'] as bool?) ?? false;
      _convictionsDetailsCtrl.text =
          pickStr([legal['convictionsDetails']]);
      _expelled = (legal['expelled'] as bool?) ?? false;
      _expelledDetailsCtrl.text = pickStr([legal['expelledDetails']]);

      // Signature place
      final signature =
          (form['signature'] as Map?)?.cast<String, dynamic>() ?? const {};
      if (signature['place'] is String) {
        _signaturePlaceCtrl.text =
            (signature['place'] as String).trim();
      }

      if (mounted) setState(() => _loadedExisting = true);
    } catch (_) {
      if (mounted) setState(() => _loadedExisting = true);
    }
  }

  Future<void> _saveDraft({bool isSubmit = false}) async {
    setState(() => _busy = true);
    try {
      Uint8List? signaturePng;
      if (isSubmit) {
        signaturePng = await _signatureCtrl.toPngBytes();
      }

      await _formRef.set({
        'personal': {
          'familyName': _familyNameCtrl.text.trim(),
          'givenNames': _givenNamesCtrl.text.trim(),
          'maidenName': _maidenNameCtrl.text.trim(),
          'birthDate': _birthDateCtrl.text.trim(),
          'birthPlace': _birthPlaceCtrl.text.trim(),
          'nationalityCurrent': _nationalityCurrentCtrl.text.trim(),
          'nationalityFormer': _nationalityFormerCtrl.text.trim(),
          'maritalStatus': _maritalStatus,
          'maritalSince': _maritalSinceCtrl.text.trim(),
          'heightCm': int.tryParse(_heightCtrl.text.trim()),
          'eyeColor': _eyeColorCtrl.text.trim(),
        },
        'address': {
          'current': _currentAddressCtrl.text.trim(),
          'hasOther': _hasOtherAddresses,
          'otherDetails': _otherAddressesCtrl.text.trim(),
        },
        'spouse': {
          'familyName': _spouseFamilyCtrl.text.trim(),
          'givenName': _spouseGivenCtrl.text.trim(),
          'birthDateAndPlace': _spouseBirthCtrl.text.trim(),
          'nationality': _spouseNationalityCtrl.text.trim(),
          'address': _spouseAddressCtrl.text.trim(),
        },
        'children': _children.map((c) => c.toMap()).toList(),
        'parents': {
          'father': {
            'familyName': _fatherFamilyCtrl.text.trim(),
            'givenName': _fatherGivenCtrl.text.trim(),
            'birthDate': _fatherBirthCtrl.text.trim(),
          },
          'mother': {
            'familyName': _motherFamilyCtrl.text.trim(),
            'givenName': _motherGivenCtrl.text.trim(),
            'birthDate': _motherBirthCtrl.text.trim(),
          },
        },
        'travel': {
          'passportType': _passportType,
          'passportNumber': _passportNumberCtrl.text.trim(),
          'issuedBy': _passportIssuedByCtrl.text.trim(),
          'issuedOn': _passportIssuedOnCtrl.text.trim(),
          'validUntil': _passportValidUntilCtrl.text.trim(),
          'rightOfReturn': _rightOfReturnCtrl.text.trim(),
          'enteredOn': _enteredGermanyCtrl.text.trim(),
          'hasVisa': _hasVisa,
          'visaPurpose': _visaPurposeCtrl.text.trim(),
          'stayedBefore': _stayedBefore,
          'stayedBeforeDetails': _stayedBeforeDetailsCtrl.text.trim(),
          'arrivedOn': _arrivedOnCtrl.text.trim(),
          'arrivedFrom': _arrivedFromCtrl.text.trim(),
          'maintainsResidenceAbroad': _maintainsAbroad,
          'residenceAbroadPlace': _maintainsAbroadPlaceCtrl.text.trim(),
          'purposeOfStay': _purposeOfStayCtrl.text.trim(),
          'intendedDuration': _intendedDurationCtrl.text.trim(),
        },
        'work': {
          'profession': _professionCtrl.text.trim(),
          'employer': _employerCtrl.text.trim(),
          'hasHealthInsurance': _hasHealthInsurance,
          'receivesSocialBenefits': _receivesSocial,
          'socialBenefitsDetails': _socialDetailsCtrl.text.trim(),
        },
        'legal': {
          'convictedInGermany': _convictedInGermany,
          'convictedAbroad': _convictedAbroad,
          'convictionsDetails': _convictionsDetailsCtrl.text.trim(),
          'expelled': _expelled,
          'expelledDetails': _expelledDetailsCtrl.text.trim(),
        },
        if (signaturePng != null)
          'signature': {
            'pngBase64': base64Encode(signaturePng),
            'place': _signaturePlaceCtrl.text.trim(),
            'date': _signatureDateCtrl.text.trim(),
            'signedAt': FieldValue.serverTimestamp(),
          },
        'metadata': {
          'updatedAt': FieldValue.serverTimestamp(),
          'status': isSubmit ? 'submitted' : 'draft',
          if (isSubmit) 'submittedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_L.finished)),
      );
      if (isSubmit) Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruajtja dështoi: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedExisting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(_L.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / _totalSteps,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF1D7F5A)),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: _buildStep(),
              ),
            ),
          ),
          _buildNavBar(),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    final isLast = _step == _totalSteps - 1;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_step > 0)
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => setState(() => _step -= 1),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(_L.back),
              ),
            const Spacer(),
            if (!isLast)
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        await _saveDraft();
                        if (mounted) setState(() => _step += 1);
                      },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text(_L.next),
              )
            else
              FilledButton.icon(
                onPressed: _busy ? null : _onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D7F5A),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text(_L.submit),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_signatureCtrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_L.signatureHint),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
      return;
    }
    await _saveDraft(isSubmit: true);
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepPersonal();
      case 1:
        return _stepAddress();
      case 2:
        return _stepFamily();
      case 3:
        return _stepParents();
      case 4:
        return _stepTravel();
      case 5:
        return _stepWork();
      case 6:
        return _stepLegal();
      case 7:
        return _stepSignature();
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  //  Step renderers
  // ============================================================

  Widget _stepPersonal() {
    return _StepWrap(
      title: _L.stepPersonal,
      children: [
        _tf(_L.familyName, _familyNameCtrl),
        _tf(_L.givenNames, _givenNamesCtrl),
        _tf(_L.maidenName, _maidenNameCtrl, required_: false),
        _dateField(_L.birthDate, _birthDateCtrl),
        _tf(_L.birthPlace, _birthPlaceCtrl),
        _tf(_L.nationalityCurrent, _nationalityCurrentCtrl),
        _tf(_L.nationalityFormer, _nationalityFormerCtrl, required_: false),
        _dropdown<String>(
          label: _L.maritalStatus,
          value: _maritalStatus,
          items: const [
            ('single', _L.ms_single),
            ('married', _L.ms_married),
            ('separated', _L.ms_separated),
            ('divorced', _L.ms_divorced),
            ('widowed', _L.ms_widowed),
          ],
          onChanged: (v) => setState(() => _maritalStatus = v ?? 'single'),
        ),
        _dateField(_L.maritalSince, _maritalSinceCtrl, required_: false),
        Row(
          children: [
            Expanded(
              child: _tf(
                _L.height,
                _heightCtrl,
                keyboard: TextInputType.number,
                required_: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tf(_L.eyeColor, _eyeColorCtrl, required_: false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepAddress() {
    return _StepWrap(
      title: _L.stepAddress,
      children: [
        _tf(_L.currentAddress, _currentAddressCtrl, maxLines: 2),
        _yesNo(_L.otherAddresses, _hasOtherAddresses,
            (v) => setState(() => _hasOtherAddresses = v)),
        if (_hasOtherAddresses)
          _tf(_L.otherAddressesDetails, _otherAddressesCtrl,
              maxLines: 3, required_: false),
      ],
    );
  }

  Widget _stepFamily() {
    return _StepWrap(
      title: _L.stepFamily,
      children: [
        if (_maritalStatus == 'married' ||
            _maritalStatus == 'separated' ||
            _maritalStatus == 'divorced' ||
            _maritalStatus == 'widowed') ...[
          _sectionHeader(_L.spouseHeader),
          _tf(_L.spouseFamilyName, _spouseFamilyCtrl, required_: false),
          _tf(_L.spouseGivenName, _spouseGivenCtrl, required_: false),
          _tf(_L.spouseBirth, _spouseBirthCtrl, required_: false),
          _tf(_L.spouseNationality, _spouseNationalityCtrl, required_: false),
          _tf(_L.spouseAddress, _spouseAddressCtrl,
              maxLines: 2, required_: false),
          const SizedBox(height: 24),
        ],
        _sectionHeader(_L.childrenHeader),
        for (var i = 0; i < _children.length; i++)
          _childCard(i, _children[i]),
        if (_children.length < 4)
          OutlinedButton.icon(
            onPressed: () => setState(() => _children.add(_ChildEntry())),
            icon: const Icon(Icons.add_rounded),
            label: const Text(_L.addChild),
          ),
      ],
    );
  }

  Widget _childCard(int idx, _ChildEntry child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${idx + 1}. ${_L.childName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  )),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() {
                  _children.removeAt(idx).dispose();
                }),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text(_L.removeChild),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _tf(_L.childFamilyName, child.family, required_: false),
          _tf(_L.childGivenName, child.given, required_: false),
          _dateField(_L.childBirth, child.birth, required_: false),
          _tf(_L.childNationality, child.nationality, required_: false),
          _tf(_L.childAddress, child.address,
              maxLines: 2, required_: false),
        ],
      ),
    );
  }

  Widget _stepParents() {
    return _StepWrap(
      title: _L.stepParents,
      children: [
        _sectionHeader(_L.fatherHeader),
        _tf(_L.parentFamilyName, _fatherFamilyCtrl, required_: false),
        _tf(_L.parentGivenName, _fatherGivenCtrl, required_: false),
        _dateField(_L.parentBirthDate, _fatherBirthCtrl, required_: false),
        const SizedBox(height: 16),
        _sectionHeader(_L.motherHeader),
        _tf(_L.parentFamilyName, _motherFamilyCtrl, required_: false),
        _tf(_L.parentGivenName, _motherGivenCtrl, required_: false),
        _dateField(_L.parentBirthDate, _motherBirthCtrl, required_: false),
      ],
    );
  }

  Widget _stepTravel() {
    return _StepWrap(
      title: _L.stepTravel,
      children: [
        _dropdown<String>(
          label: _L.passportType,
          value: _passportType,
          items: const [
            ('passport', _L.passportTypePassport),
            ('other', _L.passportTypeOther),
          ],
          onChanged: (v) => setState(() => _passportType = v ?? 'passport'),
        ),
        _tf(_L.passportNumber, _passportNumberCtrl),
        _tf(_L.passportIssuedBy, _passportIssuedByCtrl),
        _dateField(_L.passportIssuedOn, _passportIssuedOnCtrl),
        _dateField(_L.passportValidUntil, _passportValidUntilCtrl),
        _tf(_L.rightOfReturn, _rightOfReturnCtrl,
            maxLines: 2, required_: false),
        _dateField(_L.enteredGermany, _enteredGermanyCtrl),
        _yesNo(_L.hasVisa, _hasVisa, (v) => setState(() => _hasVisa = v)),
        if (_hasVisa) _tf(_L.visaPurpose, _visaPurposeCtrl),
        _yesNo(_L.stayedBefore, _stayedBefore,
            (v) => setState(() => _stayedBefore = v)),
        if (_stayedBefore)
          _tf(_L.stayedBeforeDetails, _stayedBeforeDetailsCtrl, maxLines: 3),
        _dateField(_L.arrivedOn, _arrivedOnCtrl, required_: false),
        _tf(_L.arrivedFrom, _arrivedFromCtrl, required_: false),
        _yesNo(_L.maintainsAbroad, _maintainsAbroad,
            (v) => setState(() => _maintainsAbroad = v)),
        if (_maintainsAbroad)
          _tf(_L.maintainsAbroadPlace, _maintainsAbroadPlaceCtrl),
        _tf(_L.purposeOfStay, _purposeOfStayCtrl),
        _tf(_L.intendedDuration, _intendedDurationCtrl),
      ],
    );
  }

  Widget _stepWork() {
    return _StepWrap(
      title: _L.stepWork,
      children: [
        _tf(_L.profession, _professionCtrl),
        _tf(_L.employer, _employerCtrl, maxLines: 3),
        _yesNo(_L.hasHealthInsurance, _hasHealthInsurance,
            (v) => setState(() => _hasHealthInsurance = v)),
        _yesNo(_L.receivesSocial, _receivesSocial,
            (v) => setState(() => _receivesSocial = v)),
        if (_receivesSocial)
          _tf(_L.socialDetails, _socialDetailsCtrl, maxLines: 3),
      ],
    );
  }

  Widget _stepLegal() {
    return _StepWrap(
      title: _L.stepLegal,
      children: [
        _yesNo(_L.convictedInGermany, _convictedInGermany,
            (v) => setState(() => _convictedInGermany = v)),
        _yesNo(_L.convictedAbroad, _convictedAbroad,
            (v) => setState(() => _convictedAbroad = v)),
        if (_convictedInGermany || _convictedAbroad)
          _tf(_L.convictionsDetails, _convictionsDetailsCtrl, maxLines: 4),
        _yesNo(_L.expelled, _expelled, (v) => setState(() => _expelled = v)),
        if (_expelled)
          _tf(_L.expelledDetails, _expelledDetailsCtrl, maxLines: 4),
      ],
    );
  }

  Widget _stepSignature() {
    return _StepWrap(
      title: _L.stepSignature,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFEC84B)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.gavel_rounded,
                  size: 22, color: Color(0xFFB54708)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  _L.signatureIntro,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A3E08),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _tf(_L.signaturePlace, _signaturePlaceCtrl,
                  required_: false),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tf(_L.signatureDate, _signatureDateCtrl,
                  required_: false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(
              controller: _signatureCtrl,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Spacer(),
            TextButton.icon(
              onPressed: () => _signatureCtrl.clear(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(_L.signatureClear),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  //  Reusable widgets
  // ============================================================

  Widget _tf(
    String label,
    TextEditingController c, {
    bool required_ = true,
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: required_ ? '$label *' : label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1D7F5A)),
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController c,
      {bool required_ = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        readOnly: false,
        keyboardType: TextInputType.datetime,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-/]')),
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          labelText: required_ ? '$label *' : label,
          hintText: 'TT.MM.VVVV',
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today_rounded, size: 18),
            onPressed: () async {
              final initial = DateTime.tryParse(
                    c.text.split('.').reversed.join('-'),
                  ) ??
                  DateTime(2000);
              final picked = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(1900),
                lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
              );
              if (picked != null) {
                c.text = DateFormat('dd.MM.yyyy').format(picked);
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
    );
  }

  Widget _yesNo(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              isSelected: [value, !value],
              onPressed: (i) => onChanged(i == 0),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(_L.yes),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(_L.no),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<(T, String)> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        items: items
            .map(
              (e) => DropdownMenuItem<T>(value: e.$1, child: Text(e.$2)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6B7280),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ============================================================
//  Helper child entry
// ============================================================

class _ChildEntry {
  final TextEditingController family;
  final TextEditingController given;
  final TextEditingController birth;
  final TextEditingController nationality;
  final TextEditingController address;

  _ChildEntry()
      : family = TextEditingController(),
        given = TextEditingController(),
        birth = TextEditingController(),
        nationality = TextEditingController(),
        address = TextEditingController();

  _ChildEntry.fromMap(Map<String, dynamic> m)
      : family = TextEditingController(text: (m['familyName'] ?? '').toString()),
        given = TextEditingController(text: (m['givenName'] ?? '').toString()),
        birth = TextEditingController(text: (m['birthDate'] ?? '').toString()),
        nationality = TextEditingController(
            text: (m['nationality'] ?? '').toString()),
        address = TextEditingController(text: (m['address'] ?? '').toString());

  Map<String, dynamic> toMap() => {
        'familyName': family.text.trim(),
        'givenName': given.text.trim(),
        'birthDate': birth.text.trim(),
        'nationality': nationality.text.trim(),
        'address': address.text.trim(),
      };

  void dispose() {
    family.dispose();
    given.dispose();
    birth.dispose();
    nationality.dispose();
    address.dispose();
  }
}

// ============================================================
//  Step wrapper
// ============================================================

class _StepWrap extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _StepWrap({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

// ============================================================
//  Public consent gate
// ============================================================

/// Open the form after consent dialog. Returns true if completed.
Future<void> openResidencePermitForm(
  BuildContext context, {
  required String dspUid,
  required String driverDocId,
}) async {
  final agreed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(_L.consentTitle),
      content: const Text(_L.consentBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(_L.consentCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(_L.consentAgree),
        ),
      ],
    ),
  );
  if (agreed != true || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DriverResidencePermitFormPage(
        dspUid: dspUid,
        driverDocId: driverDocId,
      ),
    ),
  );
}
