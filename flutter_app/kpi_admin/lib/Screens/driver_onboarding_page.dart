// lib/Screens/driver_onboarding_page.dart
import 'dart:convert'; // <-- for base64
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../localization/app_localizations.dart';

class DriverOnboardingPage extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> driverRef;

  const DriverOnboardingPage({
    super.key,
    required this.driverRef,
  });

  @override
  State<DriverOnboardingPage> createState() => _DriverOnboardingPageState();
}

class _DriverOnboardingPageState extends State<DriverOnboardingPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _nameAtBirthCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _resPermitExpiryCtrl = TextEditingController();
  final _licenseNumberCtrl = TextEditingController();
  final _licenseExpiryCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _insuranceCompanyCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  final _tShirtSizeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // extra origin + uniform fields
  final _birthCityCtrl = TextEditingController(); // City of Birth
  final _birthStateCtrl = TextEditingController(); // State of Birth
  final _nationalityCtrl = TextEditingController(); // Nationality (ID CARD)
  final _shoeSizeCtrl = TextEditingController(); // Uniform shoe size

  // ID / passport expiry (step 5 field)
  final _idDocExpiryCtrl = TextEditingController();

  bool _loadingInitial = true;
  bool _saving = false;
  bool _uploadingDocs = false;
  String? _uploadingDocType; // which doc type is currently uploading

  // profile photo state
  String? _profilePhotoBase64;
  String? _profilePhotoUrl;
  bool _uploadingProfilePhoto = false;

  // current UI language for this driver (stored in Firestore)
  String _lang = 'de';

  // wizard step (0 = welcome, then 1..6 as in mockup)
  int _step = 0;
  static const int _lastStep = 6;

  // which document type was chosen on the “ID Card, Passport” step
  // 'id_card' or 'passport'
  String? _selectedIdDocType;

  AppLocalizations get _loc => AppLocalizations.of(context);
  String get _currentLangCode => _loc.locale.languageCode.toLowerCase();
  String _t(String key) => _loc.t(key);

  String _docTypeLabel(String docType) {
    switch (docType) {
      case 'resident_permit':
        return _t('doc_resident_permit');

      case 'driver_license_front':
        return _t('driver_license_front');
      case 'driver_license_back':
        return _t('driver_license_back');

      case 'tax_id':
        return _t('doc_tax_id');
      case 'insurance':
        return _t('doc_insurance');

      case 'id_card_front':
        return _t('id_card_front');
      case 'id_card_back':
        return _t('id_card_back');

      case 'passport_front':
        return _t('passport_front');
      case 'passport_back':
        return _t('passport_back');

      default:
        return _t('doc_other_doc');
    }
  }

  String _requiredError(String fieldLabel) {
    final template = _t('error_required'); // contains {field}
    return template.replaceAll('{field}', fieldLabel);
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  DateTime _parseExistingOrNow(String text) {
    if (text.trim().isEmpty) return DateTime.now();
    try {
      return DateTime.parse(text.trim());
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _nameAtBirthCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCodeCtrl.dispose();
    _countryCtrl.dispose();
    _dobCtrl.dispose();
    _resPermitExpiryCtrl.dispose();
    _licenseNumberCtrl.dispose();
    _licenseExpiryCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    _ibanCtrl.dispose();
    _insuranceCompanyCtrl.dispose();
    _taxIdCtrl.dispose();
    _tShirtSizeCtrl.dispose();
    _notesCtrl.dispose();

    _birthCityCtrl.dispose();
    _birthStateCtrl.dispose();
    _nationalityCtrl.dispose();
    _shoeSizeCtrl.dispose();

    _idDocExpiryCtrl.dispose();

    super.dispose();
  }

  Future<void> _loadExisting() async {
    try {
      final snap = await widget.driverRef.get();
      final data = snap.data() ?? {};
      final onboarding = (data['onboarding'] ?? {}) as Map<String, dynamic>;

      _fullNameCtrl.text = (onboarding['fullName'] ?? '').toString();
      _nameAtBirthCtrl.text = (onboarding['nameAtBirth'] ?? '').toString();
      _phoneCtrl.text = (onboarding['phone'] ?? '').toString();
      _addressCtrl.text = (onboarding['address'] ?? '').toString();
      _cityCtrl.text = (onboarding['city'] ?? '').toString();
      _postalCodeCtrl.text = (onboarding['postalCode'] ?? '').toString();
      _countryCtrl.text = (onboarding['country'] ?? '').toString();
      _dobCtrl.text = (onboarding['dateOfBirth'] ?? '').toString();
      _resPermitExpiryCtrl.text =
          (onboarding['residencePermitExpiry'] ?? '').toString();

      _idDocExpiryCtrl.text = (onboarding['idDocExpiry'] ?? '').toString();

      _licenseNumberCtrl.text = (onboarding['licenseNumber'] ?? '').toString();
      _licenseExpiryCtrl.text = (onboarding['licenseExpiry'] ?? '').toString();
      _emergencyNameCtrl.text =
          (onboarding['emergencyContactName'] ?? '').toString();
      _emergencyPhoneCtrl.text =
          (onboarding['emergencyContactPhone'] ?? '').toString();
      _ibanCtrl.text = (onboarding['bankIban'] ?? '').toString();
      _insuranceCompanyCtrl.text =
          (onboarding['insuranceCompany'] ?? '').toString();
      _taxIdCtrl.text = (onboarding['taxId'] ?? '').toString();
      _tShirtSizeCtrl.text = (onboarding['tShirtSize'] ?? '').toString();
      _notesCtrl.text = (onboarding['notes'] ?? '').toString();

      _birthCityCtrl.text = (onboarding['birthCity'] ?? '').toString();
      _birthStateCtrl.text = (onboarding['birthState'] ?? '').toString();
      _nationalityCtrl.text =
          (onboarding['nationalityIdCard'] ?? '').toString();
      _shoeSizeCtrl.text = (onboarding['shoeSize'] ?? '').toString();

      // restore profile photo fields if present
      final profileBase64 =
          (onboarding['profilePhotoBase64'] ?? '').toString();
      _profilePhotoBase64 = profileBase64.isEmpty ? null : profileBase64;

      final profileUrl = (onboarding['profilePhotoUrl'] ?? '').toString();
      _profilePhotoUrl = profileUrl.isEmpty ? null : profileUrl;

      final storedLang = (onboarding['language'] ?? '').toString();
      if (storedLang.isNotEmpty) {
        _lang = storedLang;
      } else {
        _lang = _currentLangCode;
      }
    } catch (_) {
      _lang = _currentLangCode;
    } finally {
      if (mounted) {
        setState(() {
          _loadingInitial = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.driverRef.set({
        'onboarding': {
          'fullName': _fullNameCtrl.text.trim(),
          'nameAtBirth': _nameAtBirthCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'postalCode': _postalCodeCtrl.text.trim(),
          'country': _countryCtrl.text.trim(),
          'dateOfBirth': _dobCtrl.text.trim(),
          'residencePermitExpiry': _resPermitExpiryCtrl.text.trim(),
          'idDocExpiry': _idDocExpiryCtrl.text.trim(),
          'licenseNumber': _licenseNumberCtrl.text.trim(),
          'licenseExpiry': _licenseExpiryCtrl.text.trim(),
          'emergencyContactName': _emergencyNameCtrl.text.trim(),
          'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
          'bankIban': _ibanCtrl.text.trim(),
          'insuranceCompany': _insuranceCompanyCtrl.text.trim(),
          'taxId': _taxIdCtrl.text.trim(),
          'tShirtSize': _tShirtSizeCtrl.text.trim(),
          'notes': _notesCtrl.text.trim(),
          'birthCity': _birthCityCtrl.text.trim(),
          'birthState': _birthStateCtrl.text.trim(),
          'nationalityIdCard': _nationalityCtrl.text.trim(),
          'shoeSize': _shoeSizeCtrl.text.trim(),
          'language': _lang,
          if (_profilePhotoBase64 != null)
            'profilePhotoBase64': _profilePhotoBase64,
          if (_profilePhotoUrl != null) 'profilePhotoUrl': _profilePhotoUrl,
        },
        'onboardingSubmittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mirror the same photo onto the auth user's document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _profilePhotoBase64 != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'profilePhotoBase64': _profilePhotoBase64,
            if (_profilePhotoUrl != null) 'profilePhotoUrl': _profilePhotoUrl,
            if (_profilePhotoUrl != null)
              'profilePhotoStorageUrl': _profilePhotoUrl,
          },
          SetOptions(merge: true),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('button_save'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loc.tf('driver_onboarding_save_failed_template', {
              'error': '$e',
            }),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  // ✅ IMPORTANT: store exactly one Firestore doc per slot (docId == docType)
  Future<void> _pickAndUploadDocs(String docType) async {
    setState(() {
      _uploadingDocs = true;
      _uploadingDocType = docType;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          setState(() {
            _uploadingDocs = false;
            _uploadingDocType = null;
          });
        }
        return;
      }

      final storage = fb.FirebaseStorage.instance;
      final docsCol = widget.driverRef.collection('documents');

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        throw Exception('Could not read file bytes.');
      }

      final originalName = f.name;
      final typeLabel = _docTypeLabel(docType);

      String displayName = typeLabel;
      final dotIndex = originalName.lastIndexOf('.');
      if (dotIndex != -1 && dotIndex < originalName.length - 1) {
        final ext = originalName.substring(dotIndex + 1);
        displayName = '$typeLabel.$ext';
      }

      final ref = storage
          .ref()
          .child('driver_docs')
          .child(widget.driverRef.id)
          .child('${DateTime.now().millisecondsSinceEpoch}_$originalName');

      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      await docsCol.doc(docType).set({
        'fileName': displayName,
        'downloadUrl': url,
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedAtClient': Timestamp.now(),
        'size': f.size,
        'docType': docType,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loc.tf('driver_onboarding_document_uploaded_template', {
              'document': _docTypeLabel(docType),
            }),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loc.tf('driver_onboarding_upload_documents_failed_template', {
              'error': '$e',
            }),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingDocs = false;
          _uploadingDocType = null;
        });
      }
    }
  }

  /// pick image, upload to Storage, store base64 + URL in Firestore
  Future<void> _pickAndUploadProfilePhoto() async {
    setState(() {
      _uploadingProfilePhoto = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _uploadingProfilePhoto = false;
        });
        return;
      }

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_loc.t('could_not_read_image_bytes'))),
        );
        setState(() {
          _uploadingProfilePhoto = false;
        });
        return;
      }

      final base64Thumb = base64Encode(bytes);

      final storage = fb.FirebaseStorage.instance;
      final ref = storage
          .ref()
          .child('driver_profile_photos')
          .child(widget.driverRef.id)
          .child('profile_${DateTime.now().millisecondsSinceEpoch}_${f.name}');

      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      await widget.driverRef.set({
        'onboarding': {
          'profilePhotoBase64': base64Thumb,
          'profilePhotoUrl': url,
        },
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _profilePhotoBase64 = base64Thumb;
        _profilePhotoUrl = url;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_loc.t('profile_photo_updated'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loc.tf('failed_upload_profile_photo', {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingProfilePhoto = false;
        });
      }
    }
  }

  // ---------------------------------------------------
  // WIZARD NAVIGATION + MAIN BUILD
  // ---------------------------------------------------

  void _goNext() {
    // Validate only main data step
    if (_step == 1) {
      if (!_formKey.currentState!.validate()) return;
    }
    if (_step < _lastStep) {
      setState(() => _step += 1);
    } else {
      _save();
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
    }
  }

  // derive first name from email if full name is empty
  String _derivedFirstNameFromEmail() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final at = email.indexOf('@');
    if (at <= 0) return 'Driver';
    final local = email.substring(0, at);
    final first = local.split(RegExp(r'[._-]')).first;
    if (first.isEmpty) return 'Driver';
    return '${first[0].toUpperCase()}${first.substring(1)}';
  }

  // derive company name from email domain
  String _derivedCompanyFromEmail() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final at = email.indexOf('@');
    if (at < 0 || at >= email.length - 1) return '(Company Name)';
    final domain = email.substring(at + 1);
    final lastDot = domain.lastIndexOf('.');
    final main = lastDot > 0 ? domain.substring(0, lastDot) : domain;
    final cleaned = main.replaceAll(RegExp(r'[_\-]'), ' ');
    final parts = cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '(Company Name)';
    final capitalized = parts
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
    return capitalized;
  }

  // ✅ Slot widget: shows uploaded doc in-place, otherwise shows upload placeholder
  Widget _docSlot({
    required String docType,
    required Widget Function() placeholder,
    Widget Function(Map<String, dynamic> data)? uploadedBuilder,
  }) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.driverRef.collection('documents').doc(docType).snapshots(),
      builder: (context, snap) {
        final uploadingThis = _uploadingDocs && _uploadingDocType == docType;

        // While uploading, keep placeholder visible (with spinner) instead of flickering.
        if (uploadingThis) return placeholder();

        final data = snap.data?.data();
        final url = (data?['downloadUrl'] ?? '').toString();

        if (data == null || url.isEmpty) {
          return placeholder();
        }

        if (uploadedBuilder != null) return uploadedBuilder(data);

        final fileName = (data['fileName'] ?? 'Document').toString();

        return InkWell(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade400, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _t('replace'),
                  onPressed: () => _pickAndUploadDocs(docType),
                  icon: const Icon(Icons.upload_outlined, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLang = _currentLangCode;
    if (_loadingInitial && _lang != appLang) {
      _lang = appLang;
    }

    if (_loadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    return Directionality(
      textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 5000),
                              child: Form(
                                key: _formKey,
                                child: _buildStepContent(context),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildBottomBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    // On WORK PERMIT selection step we don't show "continue" (auto advance)
    if (_step == 2) {
      return Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 6),
        child: Row(
          children: [
            TextButton(
              onPressed: _goBack,
              child: Text(_t('back')),
            ),
            const Spacer(),
          ],
        ),
      );
    }

    final bool isLast = _step == _lastStep;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 6),
      child: Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: _goBack,
              child: Text(_t('back')),
            )
          else
            const SizedBox(width: 72),
          const Spacer(),
          SizedBox(
            width: 180,
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00B26B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _saving ? null : _goNext,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? _t('button_save') : _t('continue'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildWelcomeStep(context);
      case 1:
        return _buildAddressOriginStep(context);
      case 2:
        return _buildWorkPermitSelectionStep(context);
      case 3:
        return _buildWorkPermitUploadStep(context);
      case 4:
        return _buildIdPassportChoiceStep(context);
      case 5:
        return _buildIdPassportUploadStep(context);
      case 6:
      default:
        return _buildDriverLicenseStep(context);
    }
  }

  // ----------------- STEP 0: WELCOME -----------------

  Widget _buildWelcomeStep(BuildContext context) {
    final name = _fullNameCtrl.text.trim().isNotEmpty
        ? _fullNameCtrl.text.trim()
        : _derivedFirstNameFromEmail();
    final company = _derivedCompanyFromEmail();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _t('hi_name').replaceAll('{name}', name),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _t('welcome_to_company').replaceAll('{company}', company),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _t('welcome_desc'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _t('codriver'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            color: Colors.black38.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ----------------- STEP 1: ADDRESS + ORIGIN + UNIFORM --------

  Widget _buildAddressOriginStep(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final displayName = _fullNameCtrl.text.trim().isNotEmpty
        ? _fullNameCtrl.text.trim()
        : _derivedFirstNameFromEmail();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _sectionHeaderWithRequired(_t('your_address')),
        const SizedBox(height: 8),
        _pillInput(
          controller: _addressCtrl,
          hint: _t('hint_street_house'),
          requiredField: true,
        ),
        Row(
          children: [
            Expanded(
              child: _pillInput(
                controller: _postalCodeCtrl,
                hint: _t('hint_postal_code'),
                requiredField: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _pillInput(
                controller: _cityCtrl,
                hint: _t('hint_city'),
                requiredField: true,
              ),
            ),
          ],
        ),
        _pillInput(
          controller: _countryCtrl,
          hint: _t('hint_country'),
          requiredField: true,
        ),
        const SizedBox(height: 20),
        _sectionHeaderWithRequired(_t('your_origin')),
        const SizedBox(height: 8),
        _pillDateField(
          controller: _dobCtrl,
          hint: _t('hint_birthday'),
          requiredField: true,
        ),
        _pillInput(
          controller: _birthCityCtrl,
          hint: _t('hint_birth_city'),
          requiredField: false,
        ),
        _pillInput(
          controller: _birthStateCtrl,
          hint: _t('hint_birth_state'),
          requiredField: false,
        ),
        _pillInput(
          controller: _nationalityCtrl,
          hint: _t('hint_nationality'),
          requiredField: true,
        ),
        const SizedBox(height: 20),
        _sectionHeaderWithRequired(_t('uniform')),
        const SizedBox(height: 8),
        _textField(
          controller: _tShirtSizeCtrl,
          label: _t('label_cloth_size'),
          hint: _t('hint_cloth_size'),
        ),
        _textField(
          controller: _shoeSizeCtrl,
          label: _t('label_shoe_size'),
          hint: _t('hint_shoe_size'),
        ),
        _textField(
          controller: _notesCtrl,
          label: _t('label_notes'),
          maxLines: 3,
        ),
      ],
    );
  }

  // ----------------- STEP 2: WORK PERMIT SELECTION -----

  Widget _buildWorkPermitSelectionStep(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(
          _t('work_permit'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _t('work_permit_question'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _permitButtonColumn(),
        ),
      ],
    );
  }

  Widget _permitButtonColumn() {
    Widget buildButton(String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFFFF7A00),
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              _goNext(); // auto advance
            },
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildButton(_t('permit_german_id')),
        buildButton(_t('permit_eu_id')),
        buildButton(_t('permit_work_visa')),
      ],
    );
  }

  // ----------------- STEP 3: WORK PERMIT UPLOAD --------

  Widget _buildWorkPermitUploadStep(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(
          _t('your_work_permit'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _t('please_upload_doc'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _t('upload_quality_hint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFFFF7A00),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _docSlot(
            docType: 'resident_permit',
            placeholder: () => _workPermitUploadTile(),
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              _pillDateField(
                controller: _resPermitExpiryCtrl,
                hint: _t('hint_select_expiry'),
                requiredField: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workPermitUploadTile() {
    const docType = 'resident_permit';
    final uploadingThis = _uploadingDocs && _uploadingDocType == docType;

    return InkWell(
      onTap: uploadingThis ? null : () => _pickAndUploadDocs(docType),
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFBDBDBD),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.upload_outlined, size: 32),
            const SizedBox(height: 12),
            Text(
              _t('upload_your_file'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _t('file_formats_generic'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
            if (uploadingThis) ...[
              const SizedBox(height: 12),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ----------------- STEP 4: ID / PASSPORT CHOICE -----

  Widget _buildIdPassportChoiceStep(BuildContext context) {
    final effectiveSelection = _selectedIdDocType ?? 'id_card';

    Widget choiceButton(String label, String value) {
      final selected = effectiveSelection == value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: const Color(0xFFFF7A00),
                width: selected ? 1.6 : 1.2,
              ),
              backgroundColor:
                  selected ? const Color(0xFFFF7A00).withOpacity(0.08) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              setState(() {
                _selectedIdDocType = value;
              });
            },
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(
          _t('id_passport_title'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _t('please_upload_doc'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _t('upload_quality_hint'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFFFF7A00),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              choiceButton(_t('id_card'), 'id_card'),
              Text(
                _t('or'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              choiceButton(_t('passport'), 'passport'),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------- STEP 5: ID / PASSPORT UPLOAD -----

  String get _effectiveIdDocType => _selectedIdDocType ?? 'id_card';

  Widget _buildIdPassportUploadStep(BuildContext context) {
    final isPassport = _effectiveIdDocType == 'passport';
    final title = isPassport ? _t('your_passport') : _t('your_id_card');

    final frontType = isPassport ? 'passport_front' : 'id_card_front';
    final backType = isPassport ? 'passport_back' : 'id_card_back';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 22, 0, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t('please_upload_doc'),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Text(
                _t('upload_quality_hint'),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFFF7A00),
                ),
              ),
              const SizedBox(height: 16),
              _docSlot(
                docType: frontType,
                placeholder: () => _idPassportUploadTile(
                  docType: frontType,
                  sideLabel: _t('frontside'),
                ),
              ),
              const SizedBox(height: 14),
              _docSlot(
                docType: backType,
                placeholder: () => _idPassportUploadTile(
                  docType: backType,
                  sideLabel: _t('backside'),
                ),
              ),
              const SizedBox(height: 14),
              _pillDateField(
                controller: _idDocExpiryCtrl,
                hint: _t('hint_select_expiry'),
                requiredField: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _idPassportUploadTile({
    required String docType,
    required String sideLabel,
  }) {
    final uploadingThis = _uploadingDocs && _uploadingDocType == docType;

    return InkWell(
      onTap: uploadingThis ? null : () => _pickAndUploadDocs(docType),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                const Icon(Icons.cloud_upload_outlined, size: 28),
                const SizedBox(height: 10),
                Text(
                  _t('upload_your_file'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t('file_formats_generic'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                if (uploadingThis) ...[
                  const SizedBox(height: 10),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFF7A00),
                    width: 1,
                  ),
                  color: Colors.white,
                ),
                child: Text(
                  sideLabel,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF7A00),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- STEP 6: DRIVER LICENSE + DOCS -----

  Widget _buildDriverLicenseStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 22, 0, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('your_drivers_license'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t('please_upload_doc'),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              _docSlot(
                docType: 'driver_license_front',
                placeholder: () => _docUploadTileMobile(
                  title: _t('upload_file_front'),
                  subtitle: _t('file_formats_license'),
                  docType: 'driver_license_front',
                ),
              ),
              const SizedBox(height: 12),
              _docSlot(
                docType: 'driver_license_back',
                placeholder: () => _docUploadTileMobile(
                  title: _t('upload_file_back'),
                  subtitle: _t('file_formats_license'),
                  docType: 'driver_license_back',
                ),
              ),
              const SizedBox(height: 14),
              _dateField(
                controller: _licenseExpiryCtrl,
                label: _t('label_license_expiry'),
                hint: _t('hint_license_expiry'),
                required: true,
              ),
              const SizedBox(height: 18),
              Text(
                _t('tax_document'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t('please_upload_tax_id'),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              _docSlot(
                docType: 'tax_id',
                placeholder: () => _docUploadTileMobile(
                  title: _t('upload_tax_id'),
                  subtitle: _t('file_formats_tax'),
                  docType: 'tax_id',
                ),
              ),
              const SizedBox(height: 18),
              _textField(
                controller: _ibanCtrl,
                label: _t('label_iban'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _DriverDocsPreview(driverRef: widget.driverRef),
      ],
    );
  }

  // ----------------- SMALL HELPERS -------------------

  Widget _sectionHeaderWithRequired(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFF7A00), width: 1),
          ),
          child: Text(
            _t('required'),
            style: const TextStyle(
              color: Color(0xFFFF7A00),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillInput({
    required TextEditingController controller,
    required String hint,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormField<String>(
        validator: (_) {
          if (requiredField && controller.text.trim().isEmpty) {
            return _t('error_required_short');
          }
          return null;
        },
        builder: (state) {
          final hasError = state.hasError;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : const Color(0xFFE0E0E0),
                      width: 1.3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : const Color(0xFF00A884),
                      width: 1.6,
                    ),
                  ),
                ),
                onChanged: (_) => state.didChange(controller.text),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    state.errorText ?? _t('error_required_short'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _pillDateField({
    required TextEditingController controller,
    required String hint,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormField<String>(
        validator: (_) {
          if (requiredField && controller.text.trim().isEmpty) {
            return _t('error_required_short');
          }
          return null;
        },
        builder: (state) {
          final hasError = state.hasError;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: hasError ? Colors.red : const Color(0xFF00A884),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : const Color(0xFFE0E0E0),
                      width: 1.3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : const Color(0xFF00A884),
                      width: 1.6,
                    ),
                  ),
                ),
                onTap: () async {
                  final initial = _parseExistingOrNow(controller.text);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.text = _formatDate(picked);
                    state.didChange(controller.text);
                  }
                },
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    state.errorText ?? _t('error_required_short'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _docUploadTileMobile({
    required String title,
    required String subtitle,
    required String docType,
  }) {
    final uploadingThis = _uploadingDocs && _uploadingDocType == docType;

    return InkWell(
      onTap: uploadingThis ? null : () => _pickAndUploadDocs(docType),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            if (uploadingThis) ...[
              const SizedBox(height: 12),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF8F8FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.indigo.shade400,
              width: 1.4,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: !required
            ? null
            : (val) {
                if (val == null || val.trim().isEmpty) {
                  return _requiredError(label);
                }
                return null;
              },
      ),
    );
  }

  Widget _dateField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF8F8FF),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.indigo.shade400,
              width: 1.4,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: !required
            ? null
            : (val) {
                if (val == null || val.trim().isEmpty) {
                  return _requiredError(label);
                }
                return null;
              },
        onTap: () async {
          final initial = _parseExistingOrNow(controller.text);
          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text = _formatDate(picked);
          }
        },
      ),
    );
  }
}

// ===================================================================
// PREVIEW OF UPLOADED DOCUMENTS
// ===================================================================

class _DriverDocsPreview extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> driverRef;

  const _DriverDocsPreview({
    required this.driverRef,
  });

  String _docTypeLabel(BuildContext context, String docType) {
    final loc = AppLocalizations.of(context);
    switch (docType) {
      case 'resident_permit':
        return loc.t('doc_resident_permit');
      case 'driver_license_front':
        return loc.t('driver_license_front');
      case 'driver_license_back':
        return loc.t('driver_license_back');
      case 'tax_id':
        return loc.t('doc_tax_id');
      case 'insurance':
        return loc.t('doc_insurance');
      case 'id_card_front':
        return loc.t('id_card_front');
      case 'id_card_back':
        return loc.t('id_card_back');
      case 'passport_front':
        return loc.t('passport_front');
      case 'passport_back':
        return loc.t('passport_back');
      default:
        return loc.t('doc_other_doc');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: driverRef
          .collection('documents')
          .orderBy('uploadedAtClient', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Text(
            loc.t('no_docs'),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.t('label_uploaded_docs'),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            ...docs.map((d) {
              final data = d.data();
              final name = (data['fileName'] ?? 'Document').toString();
              final url = (data['downloadUrl'] ?? '').toString();
              final docType = (data['docType'] ?? '').toString();
              final typeLabel = _docTypeLabel(context, docType);

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (typeLabel.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      tooltip: loc.t('driver_onboarding_open_document_tooltip'),
                      onPressed: url.isEmpty
                          ? null
                          : () async {
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      loc.t(
                                        'driver_onboarding_open_document_failed',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip:
                          loc.t('driver_onboarding_delete_document_tooltip'),
                      onPressed: () async {
                        try {
                          await d.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.t('driver_onboarding_document_deleted'),
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.tf(
                                  'driver_onboarding_delete_document_failed_template',
                                  {'error': '$e'},
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
