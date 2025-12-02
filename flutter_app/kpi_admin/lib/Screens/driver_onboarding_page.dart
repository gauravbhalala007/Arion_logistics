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

  AppLocalizations get _loc => AppLocalizations.of(context);
  String get _currentLangCode => _loc.locale.languageCode.toLowerCase();

  String _t(String key) => _loc.t(key);

  String _docTypeLabel(String docType) {
    switch (docType) {
      case 'resident_permit':
        return _t('doc_resident_permit');
      case 'driver_license':
        return _t('doc_driver_license');
      case 'tax_id':
        return _t('doc_tax_id');
      case 'insurance':
        return _t('doc_insurance');
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
      _licenseNumberCtrl.text =
          (onboarding['licenseNumber'] ?? '').toString();
      _licenseExpiryCtrl.text =
          (onboarding['licenseExpiry'] ?? '').toString();
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

      // restore profile photo fields if present
      final profileBase64 =
          (onboarding['profilePhotoBase64'] ?? '').toString();
      _profilePhotoBase64 =
          profileBase64.isEmpty ? null : profileBase64;

      final profileUrl = (onboarding['profilePhotoUrl'] ?? '').toString();
      _profilePhotoUrl = profileUrl.isEmpty ? null : profileUrl;

      // restore language if stored, otherwise use current app locale
      final storedLang = (onboarding['language'] ?? '').toString();
      if (storedLang.isNotEmpty) {
        _lang = storedLang;
      } else {
        _lang = _currentLangCode;
      }
    } catch (_) {
      // ignore, just start empty
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
          'licenseNumber': _licenseNumberCtrl.text.trim(),
          'licenseExpiry': _licenseExpiryCtrl.text.trim(),
          'emergencyContactName': _emergencyNameCtrl.text.trim(),
          'emergencyContactPhone': _emergencyPhoneCtrl.text.trim(),
          'bankIban': _ibanCtrl.text.trim(),
          'insuranceCompany': _insuranceCompanyCtrl.text.trim(),
          'taxId': _taxIdCtrl.text.trim(),
          'tShirtSize': _tShirtSizeCtrl.text.trim(),
          'notes': _notesCtrl.text.trim(),
          'language': _lang,
          // keep whatever photo is currently in state
          if (_profilePhotoBase64 != null)
            'profilePhotoBase64': _profilePhotoBase64,
          if (_profilePhotoUrl != null)
            'profilePhotoUrl': _profilePhotoUrl,
        },
        'onboardingSubmittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mirror the same photo onto the auth user's document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _profilePhotoBase64 != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(
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
        const SnackBar(content: Text('Onboarding form saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

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
        setState(() {
          _uploadingDocs = false;
          _uploadingDocType = null;
        });
        return;
      }

      final storage = fb.FirebaseStorage.instance;
      final docsCol = widget.driverRef.collection('documents');

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes != null) {
        final originalName = f.name;
        final typeLabel = _docTypeLabel(docType);

        // build a clean display name like "Resident permit.pdf"
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

        await docsCol.add({
          'fileName': displayName,
          'downloadUrl': url,
          'uploadedAt': FieldValue.serverTimestamp(),
          'size': f.size,
          'docType': docType,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_docTypeLabel(docType)} uploaded.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload documents: $e')),
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
          const SnackBar(
            content: Text(
              'Could not read image bytes from file picker.',
            ),
          ),
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
          .child(
              'profile_${DateTime.now().millisecondsSinceEpoch}_${f.name}');

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
        const SnackBar(
          content: Text('Profile photo updated.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload profile photo: $e'),
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

  @override
  Widget build(BuildContext context) {
    // keep _lang consistent with current app locale if not loaded yet
    final appLang = _currentLangCode;
    if (_loadingInitial && _lang != appLang) {
      _lang = appLang;
    }

    if (_loadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 720;
    final bool isNarrow = width < 960;
    final double maxWidth = isNarrow ? width - 24 : 960.0;

    return Directionality(
      textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFFF4F5FB),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 32,
                    vertical: isMobile ? 18 : 28,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ---------- Header row ----------
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.assignment_ind_outlined,
                                color:
                                    Theme.of(context).colorScheme.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t('header_title'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _t('subtitle'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _t('language_label'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(999),
                                    border:
                                        Border.all(color: Colors.black12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _lang,
                                      isDense: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'de',
                                          child: Text('🇩🇪 Deutsch'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'en',
                                          child: Text('🇬🇧 English'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'sq',
                                          child: Text('🇦🇱 Shqip'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'hu',
                                          child: Text('🇭🇺 Magyar'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'ro',
                                          child: Text('🇷🇴 Română'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'hr',
                                          child: Text('🇭🇷 Hrvatski'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'ar',
                                          child: Text('🇸🇾 العربية'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
                                          _lang = v;
                                        });
                                        // update global app locale as well
                                        localeController
                                            .setLocale(Locale(v));
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // profile photo row (avatar + upload button)
                        _buildProfilePhotoRow(context),

                        const SizedBox(height: 18),
                        Divider(
                          height: 1,
                          color: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 12),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bool twoCols =
                                constraints.maxWidth > 720;

                            Widget leftColumn = Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // PERSONAL
                                _sectionTitle(context, _t('section_personal')),
                                if (twoCols)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _textField(
                                          controller: _fullNameCtrl,
                                          label: _t('label_full_name'),
                                          required: true,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _dateField(
                                          controller: _dobCtrl,
                                          label: _t('label_dob'),
                                          hint: _t('hint_dob'),
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _textField(
                                    controller: _fullNameCtrl,
                                    label: _t('label_full_name'),
                                    required: true,
                                  ),
                                  _dateField(
                                    controller: _dobCtrl,
                                    label: _t('label_dob'),
                                    hint: _t('hint_dob'),
                                  ),
                                ],
                                _textField(
                                  controller: _nameAtBirthCtrl,
                                  label: _t('label_name_at_birth'),
                                ),
                                _textField(
                                  controller: _phoneCtrl,
                                  label: _t('label_phone'),
                                  required: true,
                                ),

                                // ADDRESS
                                _sectionTitle(
                                    context, _t('section_address')),
                                _textField(
                                  controller: _addressCtrl,
                                  label: _t('label_street'),
                                ),
                                if (twoCols)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _textField(
                                          controller: _cityCtrl,
                                          label: _t('label_city'),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _textField(
                                          controller: _postalCodeCtrl,
                                          label: _t('label_postal'),
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _textField(
                                    controller: _cityCtrl,
                                    label: _t('label_city'),
                                  ),
                                  _textField(
                                    controller: _postalCodeCtrl,
                                    label: _t('label_postal'),
                                  ),
                                ],
                                _textField(
                                  controller: _countryCtrl,
                                  label: _t('label_country'),
                                ),
                                _dateField(
                                  controller: _resPermitExpiryCtrl,
                                  label:
                                      _t('label_residence_permit_expiry'),
                                  hint: _t('hint_residence_permit_expiry'),
                                ),
                                _docUploadRow(
                                  context: context,
                                  docType: 'resident_permit',
                                ),

                                // LICENSE
                                _sectionTitle(
                                    context, _t('section_license')),
                                _textField(
                                  controller: _licenseNumberCtrl,
                                  label: _t('label_license_number'),
                                ),
                                _dateField(
                                  controller: _licenseExpiryCtrl,
                                  label: _t('label_license_expiry'),
                                  hint: _t('hint_license_expiry'),
                                ),
                                _docUploadRow(
                                  context: context,
                                  docType: 'driver_license',
                                ),

                                // EMERGENCY
                                _sectionTitle(
                                    context, _t('section_emergency')),
                                _textField(
                                  controller: _emergencyNameCtrl,
                                  label: _t('label_emergency_name'),
                                ),
                                _textField(
                                  controller: _emergencyPhoneCtrl,
                                  label: _t('label_emergency_phone'),
                                ),
                              ],
                            );

                            Widget rightColumn = Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // PAYMENT & EQUIPMENT
                                _sectionTitle(
                                    context, _t('section_payment')),
                                _textField(
                                  controller: _ibanCtrl,
                                  label: _t('label_iban'),
                                ),
                                _textField(
                                  controller: _insuranceCompanyCtrl,
                                  label: _t('label_insurance_company'),
                                ),
                                _docUploadRow(
                                  context: context,
                                  docType: 'insurance',
                                ),
                                _textField(
                                  controller: _taxIdCtrl,
                                  label: _t('label_tax_id'),
                                ),
                                _docUploadRow(
                                  context: context,
                                  docType: 'tax_id',
                                ),
                                _textField(
                                  controller: _tShirtSizeCtrl,
                                  label: _t('label_tshirt'),
                                  hint: _t('hint_tshirt'),
                                ),

                                // NOTES
                                _sectionTitle(
                                    context, _t('section_notes')),
                                _textField(
                                  controller: _notesCtrl,
                                  label: _t('label_notes'),
                                  maxLines: 4,
                                ),

                                // DOCUMENTS OVERVIEW
                                _sectionTitle(
                                    context, _t('section_documents')),
                                _DriverDocsPreview(
                                  driverRef: widget.driverRef,
                                ),
                              ],
                            );

                            if (!twoCols) {
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  leftColumn,
                                  const SizedBox(height: 16),
                                  rightColumn,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(child: leftColumn),
                                const SizedBox(width: 28),
                                Expanded(child: rightColumn),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.save_outlined,
                                    size: 18),
                            label: Text(_t('button_save')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // small row with avatar + upload button
  Widget _buildProfilePhotoRow(BuildContext context) {
    ImageProvider? provider;
    if (_profilePhotoBase64 != null &&
        _profilePhotoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_profilePhotoBase64!);
        provider = MemoryImage(bytes);
      } catch (_) {
        provider = null;
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: provider,
            child: provider == null
                ? const Icon(
                    Icons.person,
                    color: Color(0xFF6B7280),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile photo',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Optional. Used in driver hub and internal view.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed:
                _uploadingProfilePhoto ? null : _pickAndUploadProfilePhoto,
            icon: _uploadingProfilePhoto
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_outlined, size: 18),
            label: Text(
              _uploadingProfilePhoto ? 'Uploading...' : 'Upload',
            ),
          ),
        ],
      ),
    );
  }

  Widget _docUploadRow({
    required BuildContext context,
    required String docType,
  }) {
    final typeLabel = _docTypeLabel(docType);
    final uploadingThis =
        _uploadingDocs && _uploadingDocType == docType;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: uploadingThis ? null : () => _pickAndUploadDocs(docType),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.indigo.withOpacity(0.15),
            ),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.upload_file_outlined,
                  color: Colors.indigo.shade600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      uploadingThis
                          ? _t('label_uploading')
                          : 'PDF, JPG, PNG…',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (uploadingThis)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
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
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
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
      case 'driver_license':
        return loc.t('doc_driver_license');
      case 'tax_id':
        return loc.t('doc_tax_id');
      case 'insurance':
        return loc.t('doc_insurance');
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
          .orderBy('uploadedAt', descending: true)
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          if (typeLabel.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 2.0),
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
                      tooltip: 'Open',
                      onPressed: url.isEmpty
                          ? null
                          : () async {
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode:
                                      LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open document URL',
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Delete',
                      onPressed: () async {
                        try {
                          await d.reference.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Document deleted.'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to delete document: $e',
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
