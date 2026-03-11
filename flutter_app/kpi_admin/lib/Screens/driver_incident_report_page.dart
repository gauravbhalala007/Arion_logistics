import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverIncidentReportPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverIncidentReportPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverIncidentReportPage> createState() =>
      _DriverIncidentReportPageState();
}

class _DriverIncidentReportPageState extends State<DriverIncidentReportPage> {
  static const _settingsCollection = 'settings';
  static const _settingsDoc = 'incident_report';
  static const _reportsCollection = 'incident_reports';

  static const Color _kGreen = Color(0xFF1D9E75);
  static const Color _kPageBg = Color(0xFFF1F3F2);
  static const Color _kText = Color(0xFF1F2937);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kCardBorder = Color(0xFFD9DFE3);
  static const Color _kInputBg = Color(0xFFF0F2F1);
  static const Color _kOrange = Color(0xFFFF7A18);

  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  bool _loadingSettings = true;
  bool _submitting = false;
  bool _locatingCurrentLocation = false;

  Map<String, dynamic> _settings = const <String, dynamic>{};

  String _faultOpinion = 'self';
  bool _policeInvolved = false;
  String _damageType = 'vehicle';

  bool _accidentNow = true;
  DateTime? _selectedAccidentTime;

  _PickedPhoto? _platePhoto;
  final List<_PickedPhoto> _damagePhotos = <_PickedPhoto>[];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String get _langCode => Localizations.localeOf(context).languageCode;

  String _t(String key) {
    final langMap =
        _driverIncidentReportTranslations[_langCode] ??
        _driverIncidentReportTranslations['en']!;
    return langMap[key] ?? _driverIncidentReportTranslations['en']![key] ?? key;
  }

  String _tf(String key, Map<String, String> params) {
    var text = _t(key);
    params.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  Future<void> _loadSettings() async {
    if (widget.dspUid.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _loadingSettings = false);
      return;
    }

    setState(() => _loadingSettings = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection(_settingsCollection)
          .doc(_settingsDoc)
          .get();
      _settings = snap.data() ?? const <String, dynamic>{};
    } catch (_) {
      _settings = const <String, dynamic>{};
    } finally {
      if (mounted) {
        setState(() => _loadingSettings = false);
      }
    }
  }

  Map<String, dynamic> get _companySettings {
    final raw = _settings['company'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Map<String, dynamic> get _insuranceSettings {
    final raw = _settings['insurance'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  String _companyValue(String key) {
    final fromNested = _stringOf(_companySettings[key]);
    if (fromNested.isNotEmpty) return fromNested;
    final fromFlat = _stringOf(_settings['company_$key']);
    if (fromFlat.isNotEmpty) return fromFlat;

    switch (key) {
      case 'name':
        return _t('driver_incident_company_not_configured');
      default:
        return '';
    }
  }

  String _insuranceValue(String key) {
    final fromNested = _stringOf(_insuranceSettings[key]);
    if (fromNested.isNotEmpty) return fromNested;
    final fromFlat = _stringOf(_settings['insurance_$key']);
    if (fromFlat.isNotEmpty) return fromFlat;

    switch (key) {
      case 'name':
        return _t('driver_incident_insurance_not_configured');
      default:
        return '';
    }
  }

  Future<void> _pickPlatePhoto() async {
    final picked = await _pickSingleImage();
    if (picked == null || !mounted) return;
    setState(() => _platePhoto = picked);
  }

  Future<void> _pickDamagePhotos() async {
    final picked = await _pickManyImages();
    if (picked.isEmpty || !mounted) return;
    setState(() {
      _damagePhotos
        ..clear()
        ..addAll(picked);
    });
  }

  Future<_PickedPhoto?> _pickSingleImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.image,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.bytes == null) {
      _showSnack(
        _t('driver_incident_snack_could_not_read_image_bytes'),
        error: true,
      );
      return null;
    }
    return _PickedPhoto(name: file.name, bytes: file.bytes!);
  }

  Future<List<_PickedPhoto>> _pickManyImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.image,
    );
    if (result == null || result.files.isEmpty) return const <_PickedPhoto>[];
    final out = <_PickedPhoto>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      out.add(_PickedPhoto(name: file.name, bytes: bytes));
    }
    if (out.isEmpty) {
      _showSnack(
        _t('driver_incident_snack_could_not_read_selected_image_bytes'),
        error: true,
      );
    }
    return out;
  }

  Future<void> _pickAccidentDateTime() async {
    final now = DateTime.now();
    final initial = _selectedAccidentTime ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: initial,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() => _selectedAccidentTime = selected);
  }

  Future<void> _acquireCurrentLocation() async {
    if (_locatingCurrentLocation) return;
    FocusScope.of(context).unfocus();

    setState(() => _locatingCurrentLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showSnack(
          _t('driver_incident_snack_enter_location_manually'),
          error: true,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack(
          _t('driver_incident_snack_enter_location_manually'),
          error: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final coords =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

      var value = coords;
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final address = _formatPlacemark(placemarks.first);
          if (address.isNotEmpty) {
            value = '$address ($coords)';
          }
        }
      } catch (_) {
        // Reverse geocoding may be unavailable on some platforms; keep coords.
      }

      if (!mounted) return;
      setState(() {
        _locationCtrl.text = value;
        _locationCtrl.selection = TextSelection.collapsed(offset: value.length);
      });
    } catch (_) {
      if (mounted) {
        _showSnack(
          _t('driver_incident_snack_enter_location_manually'),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _locatingCurrentLocation = false);
      }
    }
  }

  String _formatPlacemark(geocoding.Placemark p) {
    final parts = <String>[];
    void add(String? v) {
      final text = (v ?? '').trim();
      if (text.isEmpty) return;
      if (parts.contains(text)) return;
      parts.add(text);
    }

    add(p.street);
    add(p.subLocality);
    add(p.postalCode);
    add(p.locality);
    add(p.administrativeArea);
    add(p.country);
    return parts.join(', ');
  }

  Future<String> _uploadPhoto({
    required _PickedPhoto photo,
    required String reportId,
    required String bucket,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_safeFileName(photo.name)}';
    final ref = fb.FirebaseStorage.instance
        .ref()
        .child('incident_reports')
        .child(widget.dspUid)
        .child(widget.driverTransporterId.toUpperCase())
        .child(reportId)
        .child(bucket)
        .child(fileName);
    await ref.putData(photo.bytes);
    return ref.getDownloadURL();
  }

  Future<void> _shareByEmail() async {
    final recipient = _firstNonEmpty([
      _companyValue('email'),
      _insuranceValue('email'),
    ]);
    if (recipient.isEmpty) {
      _showSnack(
        _t('driver_incident_snack_no_company_or_insurance_email'),
        error: true,
      );
      return;
    }

    final body = StringBuffer()
      ..writeln(_t('driver_incident_email_intro'))
      ..writeln()
      ..writeln(
        _tf('driver_incident_email_driver', {
          'value': widget.driverTransporterId.toUpperCase(),
        }),
      )
      ..writeln(
        _tf('driver_incident_email_location', {
          'value': _locationCtrl.text.trim().isEmpty
              ? '-'
              : _locationCtrl.text.trim(),
        }),
      )
      ..writeln(
        _tf('driver_incident_email_fault_opinion', {
          'value': _faultLabel(_faultOpinion),
        }),
      )
      ..writeln(
        _tf('driver_incident_email_police_involved', {
          'value': _policeInvolved
              ? _t('driver_incident_yes')
              : _t('driver_incident_no'),
        }),
      )
      ..writeln(
        _tf('driver_incident_email_damage_type', {
          'value': _damageLabel(_damageType),
        }),
      )
      ..writeln(
        _tf('driver_incident_email_accident_time', {
          'value': _formatDateTime(
            _accidentNow ? DateTime.now() : _selectedAccidentTime,
          ),
        }),
      )
      ..writeln()
      ..writeln(
        _tf('driver_incident_email_description', {
          'value': _descriptionCtrl.text.trim().isEmpty
              ? '-'
              : _descriptionCtrl.text.trim(),
        }),
      );

    final mail = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: <String, String>{
        'subject': _t('driver_incident_email_subject'),
        'body': body.toString(),
      },
    );
    final opened = await launchUrl(mail, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      _showSnack(_t('driver_incident_snack_could_not_open_email'), error: true);
    }
  }

  Future<void> _openPhone(String phone) async {
    final normalized = phone.trim();
    if (normalized.isEmpty) return;
    final uri = Uri.parse('tel:${normalized.replaceAll(' ', '')}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      _showSnack(_t('driver_incident_snack_could_not_open_phone'), error: true);
    }
  }

  Future<void> _openEmail(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: normalized);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      _showSnack(_t('driver_incident_snack_could_not_open_email'), error: true);
    }
  }

  Future<void> _submit() async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      _showSnack(
        _t('driver_incident_snack_must_be_logged_in_driver'),
        error: true,
      );
      return;
    }
    if (widget.dspUid.trim().isEmpty ||
        widget.driverTransporterId.trim().isEmpty) {
      _showSnack(_t('driver_incident_snack_missing_scope'), error: true);
      return;
    }

    if (_locationCtrl.text.trim().isEmpty) {
      _showSnack(_t('driver_incident_snack_provide_location'), error: true);
      return;
    }
    if (_descriptionCtrl.text.trim().isEmpty) {
      _showSnack(_t('driver_incident_snack_provide_description'), error: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final dspRef = db.collection('users').doc(widget.dspUid);
      final rootRef = dspRef.collection(_reportsCollection).doc();
      final reportId = rootRef.id;

      final plateUrl = _platePhoto == null
          ? ''
          : await _uploadPhoto(
              photo: _platePhoto!,
              reportId: reportId,
              bucket: 'plate',
            );

      final damageUrls = <String>[];
      for (final photo in _damagePhotos) {
        final url = await _uploadPhoto(
          photo: photo,
          reportId: reportId,
          bucket: 'damage',
        );
        damageUrls.add(url);
      }

      final driverId = widget.driverTransporterId.toUpperCase();
      final driverRef = dspRef.collection('drivers').doc(driverId);
      final driverSnap = await driverRef.get();
      final driverData = driverSnap.data() ?? const <String, dynamic>{};
      final driverName = _firstNonEmpty([
        _stringOf(driverData['name']),
        _stringOf(driverData['fullName']),
        _stringOf(driverData['driverName']),
      ]);

      final accidentAt = _accidentNow
          ? DateTime.now()
          : (_selectedAccidentTime ?? DateTime.now());

      final payload = <String, dynamic>{
        'reportId': reportId,
        'dspUid': widget.dspUid,
        'driverUid': auth.uid,
        'driverTransporterId': driverId,
        'driverName': driverName,
        'location': _locationCtrl.text.trim(),
        'faultOpinion': _faultOpinion,
        'policeInvolved': _policeInvolved,
        'damageType': _damageType,
        'description': _descriptionCtrl.text.trim(),
        'accidentAt': Timestamp.fromDate(accidentAt),
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'submitted',
        'platePhotoUrl': plateUrl,
        'damagePhotoUrls': damageUrls,
        'company': <String, dynamic>{
          'name': _companyValue('name'),
          'addressLine1': _companyValue('addressLine1'),
          'addressLine2': _companyValue('addressLine2'),
          'phone': _companyValue('phone'),
          'email': _companyValue('email'),
        },
        'insurance': <String, dynamic>{
          'name': _insuranceValue('name'),
          'policyNumber': _insuranceValue('policyNumber'),
          'email': _insuranceValue('email'),
        },
      };

      final driverDocRef = driverRef
          .collection(_reportsCollection)
          .doc(reportId);
      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverDocRef, payload, SetOptions(merge: true));
      batch.set(driverRef, {
        'lastIncidentReportAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return;
      setState(() {
        _locationCtrl.clear();
        _descriptionCtrl.clear();
        _faultOpinion = 'self';
        _policeInvolved = false;
        _damageType = 'vehicle';
        _accidentNow = true;
        _selectedAccidentTime = null;
        _platePhoto = null;
        _damagePhotos.clear();
      });
      _showSnack(_t('driver_incident_snack_submitted'));
    } catch (e) {
      _showSnack(
        _tf('driver_incident_snack_submit_failed', {'error': '$e'}),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSettings) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: _kPageBg,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFDDE2E4),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              Icons.business_outlined,
                              _t('driver_incident_company_section_title'),
                            ),
                            const SizedBox(height: 18),
                            _headlineValue(_companyValue('name')),
                            const SizedBox(height: 6),
                            _mutedLine(_companyValue('addressLine1')),
                            _mutedLine(_companyValue('addressLine2')),
                            if (_companyValue('phone').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _contactLinkRow(
                                icon: Icons.phone_outlined,
                                text: _companyValue('phone'),
                                onTap: () => _openPhone(_companyValue('phone')),
                              ),
                            ],
                            if (_companyValue('email').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _contactLinkRow(
                                icon: Icons.mail_outline,
                                text: _companyValue('email'),
                                onTap: () => _openEmail(_companyValue('email')),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              Icons.shield_outlined,
                              _t('driver_incident_insurance_section_title'),
                            ),
                            const SizedBox(height: 18),
                            _headlineValue(_insuranceValue('name')),
                            const SizedBox(height: 6),
                            _mutedLine(
                              _insuranceValue('policyNumber').isEmpty
                                  ? _tf(
                                      'driver_incident_insurance_policy_number',
                                      {'value': '-'},
                                    )
                                  : _tf(
                                      'driver_incident_insurance_policy_number',
                                      {
                                        'value': _insuranceValue(
                                          'policyNumber',
                                        ),
                                      },
                                    ),
                            ),
                            if (_insuranceValue('email').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _contactLinkRow(
                                icon: Icons.mail_outline,
                                text: _insuranceValue('email'),
                                onTap: () =>
                                    _openEmail(_insuranceValue('email')),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _outlineActionButton(
                        icon: Icons.share_outlined,
                        label: _t('driver_incident_share_by_email'),
                        onPressed: _shareByEmail,
                      ),
                      const SizedBox(height: 18),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              Icons.location_on_outlined,
                              _t('driver_incident_location_section_title'),
                            ),
                            const SizedBox(height: 16),
                            _softActionButton(
                              icon: Icons.location_searching_outlined,
                              label: _locatingCurrentLocation
                                  ? '${_t('driver_incident_scan_location')}...'
                                  : _t('driver_incident_scan_location'),
                              onPressed: _acquireCurrentLocation,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _t('driver_incident_or_enter_manually'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _softTextField(
                              controller: _locationCtrl,
                              hintText: _t('driver_incident_location_hint'),
                              minLines: 1,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _questionTitle(
                              _t('driver_incident_fault_question'),
                            ),
                            const SizedBox(height: 14),
                            _radioRow<String>(
                              value: 'self',
                              groupValue: _faultOpinion,
                              onChanged: (v) =>
                                  setState(() => _faultOpinion = v),
                              label: _t('driver_incident_fault_self'),
                            ),
                            _radioRow<String>(
                              value: 'other',
                              groupValue: _faultOpinion,
                              onChanged: (v) =>
                                  setState(() => _faultOpinion = v),
                              label: _t('driver_incident_fault_other'),
                            ),
                            _radioRow<String>(
                              value: 'both',
                              groupValue: _faultOpinion,
                              onChanged: (v) =>
                                  setState(() => _faultOpinion = v),
                              label: _t('driver_incident_fault_both'),
                            ),
                            _radioRow<String>(
                              value: 'unclear',
                              groupValue: _faultOpinion,
                              onChanged: (v) =>
                                  setState(() => _faultOpinion = v),
                              label: _t('driver_incident_fault_unclear'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _questionTitle(
                              _t('driver_incident_police_question'),
                            ),
                            const SizedBox(height: 14),
                            _radioRow<bool>(
                              value: true,
                              groupValue: _policeInvolved,
                              onChanged: (v) =>
                                  setState(() => _policeInvolved = v),
                              label: _t('driver_incident_yes'),
                            ),
                            _radioRow<bool>(
                              value: false,
                              groupValue: _policeInvolved,
                              onChanged: (v) =>
                                  setState(() => _policeInvolved = v),
                              label: _t('driver_incident_no'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              Icons.photo_camera_outlined,
                              _t('driver_incident_plate_section_title'),
                            ),
                            const SizedBox(height: 14),
                            _uploadSelectButton(
                              onPressed: _pickPlatePhoto,
                              label: _platePhoto == null
                                  ? _t('driver_incident_plate_take')
                                  : _t('driver_incident_plate_replace'),
                            ),
                            if (_platePhoto != null) ...[
                              const SizedBox(height: 12),
                              _imagePreview(_platePhoto!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              Icons.photo_camera_outlined,
                              _t('driver_incident_damage_section_title'),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _t('driver_incident_damage_type_label'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _radioRow<String>(
                              value: 'vehicle',
                              groupValue: _damageType,
                              onChanged: (v) => setState(() => _damageType = v),
                              label: _t('driver_incident_damage_vehicle'),
                            ),
                            _radioRow<String>(
                              value: 'property',
                              groupValue: _damageType,
                              onChanged: (v) => setState(() => _damageType = v),
                              label: _t('driver_incident_damage_property'),
                            ),
                            _radioRow<String>(
                              value: 'both',
                              groupValue: _damageType,
                              onChanged: (v) => setState(() => _damageType = v),
                              label: _t('driver_incident_damage_both'),
                            ),
                            const SizedBox(height: 10),
                            _uploadSelectButton(
                              onPressed: _pickDamagePhotos,
                              label: _damagePhotos.isEmpty
                                  ? _t('driver_incident_damage_take_photos')
                                  : _t('driver_incident_damage_replace_photos'),
                            ),
                            if (_damagePhotos.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _damagePhotos
                                    .map(
                                      (photo) =>
                                          _imagePreview(photo, compact: true),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle(
                              Icons.access_time_outlined,
                              _t('driver_incident_time_section_title'),
                            ),
                            const SizedBox(height: 12),
                            _radioRow<bool>(
                              value: true,
                              groupValue: _accidentNow,
                              onChanged: (v) =>
                                  setState(() => _accidentNow = v),
                              label: _t('driver_incident_time_now'),
                            ),
                            _radioRow<bool>(
                              value: false,
                              groupValue: _accidentNow,
                              onChanged: (v) =>
                                  setState(() => _accidentNow = v),
                              label: _t('driver_incident_time_other'),
                            ),
                            if (!_accidentNow) ...[
                              const SizedBox(height: 10),
                              _softActionButton(
                                icon: Icons.edit_calendar_outlined,
                                label: _formatDateTime(_selectedAccidentTime),
                                onPressed: _pickAccidentDateTime,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _questionTitle(
                              _t('driver_incident_description_title'),
                            ),
                            const SizedBox(height: 14),
                            _softTextField(
                              controller: _descriptionCtrl,
                              hintText: _t('driver_incident_description_hint'),
                              minLines: 5,
                              maxLines: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _kGreen.withValues(
                              alpha: 0.6,
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_outlined, size: 20),
                          label: Text(
                            _submitting
                                ? _t('driver_incident_submit_sending')
                                : _t('driver_incident_submit'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: _kText, size: 24),
          ),
          const Icon(Icons.warning_amber_rounded, color: _kOrange, size: 24),
          const SizedBox(width: 10),
          Text(
            _t('driver_incident_header_title'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kCardBorder, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: _kGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _kText,
      ),
    );
  }

  Widget _headlineValue(String text) {
    return Text(
      text.isEmpty ? '-' : text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: _kText,
        height: 1.15,
      ),
    );
  }

  Widget _mutedLine(String text) {
    return Text(
      text.isEmpty ? '-' : text,
      style: const TextStyle(
        fontSize: 15,
        color: _kMuted,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
    );
  }

  Widget _contactLinkRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _kMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: _kGreen,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlineActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _kGreen,
          side: const BorderSide(color: _kGreen, width: 1.4),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _softActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _kInputBg,
          foregroundColor: _kText,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _kCardBorder),
          ),
        ),
        icon: Icon(icon, size: 22, color: _kText),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _softTextField({
    required TextEditingController controller,
    required String hintText,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8B95A7), fontSize: 15),
        filled: true,
        fillColor: _kInputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _kCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _kCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _kGreen, width: 1.4),
        ),
      ),
    );
  }

  Widget _uploadSelectButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _kInputBg,
          foregroundColor: const Color(0xFF7D8799),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: _kCardBorder.withValues(alpha: 0.9)),
          ),
        ),
        icon: const Icon(Icons.photo_camera_outlined, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _radioRow<T>({
    required T value,
    required T groupValue,
    required ValueChanged<T> onChanged,
    required String label,
  }) {
    final selected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              activeColor: _kGreen,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: _kGreen, width: 1.4),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: _kText,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview(_PickedPhoto photo, {bool compact = false}) {
    return Container(
      width: compact ? 110 : 180,
      height: compact ? 80 : 110,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kCardBorder),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            photo.bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image_outlined)),
          ),
          Positioned(
            left: 6,
            right: 6,
            bottom: 4,
            child: Text(
              photo.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  static String _safeFileName(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final v = raw.trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  String _faultLabel(String value) {
    switch (value) {
      case 'self':
        return _t('driver_incident_fault_self');
      case 'other':
        return _t('driver_incident_fault_other');
      case 'both':
        return _t('driver_incident_fault_both');
      case 'unclear':
        return _t('driver_incident_fault_unclear');
      default:
        return value;
    }
  }

  String _damageLabel(String value) {
    switch (value) {
      case 'vehicle':
        return _t('driver_incident_damage_vehicle');
      case 'property':
        return _t('driver_incident_damage_property');
      case 'both':
        return _t('driver_incident_damage_both');
      default:
        return value;
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return _t('driver_incident_select_date_time');
    return DateFormat('dd.MM.yyyy HH:mm').format(value);
  }
}

class _PickedPhoto {
  final String name;
  final Uint8List bytes;

  const _PickedPhoto({required this.name, required this.bytes});
}

const Map<String, Map<String, String>> _driverIncidentReportTranslations = {
  'en': {
    'driver_incident_company_not_configured': 'Company not configured',
    'driver_incident_insurance_not_configured': 'Insurance not configured',
    'driver_incident_snack_could_not_read_image_bytes':
        'Could not read image bytes.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'Could not read selected image bytes.',
    'driver_incident_snack_no_company_or_insurance_email':
        'No company or insurance email configured.',
    'driver_incident_email_intro': 'Driver incident report details',
    'driver_incident_email_driver': 'Driver: {value}',
    'driver_incident_email_location': 'Location: {value}',
    'driver_incident_email_fault_opinion': 'Fault opinion: {value}',
    'driver_incident_email_police_involved': 'Police involved: {value}',
    'driver_incident_email_damage_type': 'Damage type: {value}',
    'driver_incident_email_accident_time': 'Accident time: {value}',
    'driver_incident_email_description': 'Description: {value}',
    'driver_incident_email_subject': 'Incident report details',
    'driver_incident_snack_could_not_open_email': 'Could not open email app.',
    'driver_incident_snack_could_not_open_phone': 'Could not open phone app.',
    'driver_incident_snack_must_be_logged_in_driver':
        'You must be logged in as driver.',
    'driver_incident_snack_missing_scope': 'Missing DSP or driver scope.',
    'driver_incident_snack_provide_location':
        'Please provide accident location.',
    'driver_incident_snack_provide_description':
        'Please provide a short description.',
    'driver_incident_snack_submitted': 'Incident report submitted.',
    'driver_incident_snack_submit_failed': 'Failed to submit report: {error}',
    'driver_incident_company_section_title': 'Company Details',
    'driver_incident_insurance_section_title': 'Insurance Details',
    'driver_incident_insurance_policy_number': 'Policy no.: {value}',
    'driver_incident_share_by_email': 'Share details by email',
    'driver_incident_location_section_title': 'Accident Location',
    'driver_incident_scan_location': 'Scan location',
    'driver_incident_snack_enter_location_manually':
        'Please enter location manually.',
    'driver_incident_or_enter_manually': 'Or enter manually',
    'driver_incident_location_hint': 'Street, ZIP, City',
    'driver_incident_fault_question': 'Who do you think is at fault?',
    'driver_incident_fault_self': 'Me',
    'driver_incident_fault_other': 'Other party',
    'driver_incident_fault_both': 'Both parties',
    'driver_incident_fault_unclear': 'Unclear / Not sure',
    'driver_incident_police_question': 'Was police involved?',
    'driver_incident_yes': 'Yes',
    'driver_incident_no': 'No',
    'driver_incident_plate_section_title': 'Photograph license plate',
    'driver_incident_plate_take': 'Take plate photo',
    'driver_incident_plate_replace': 'Replace plate photo',
    'driver_incident_damage_section_title': 'Damage photos',
    'driver_incident_damage_type_label': 'Type of damage',
    'driver_incident_damage_vehicle': 'Vehicle damage',
    'driver_incident_damage_property': 'Property damage',
    'driver_incident_damage_both': 'Both',
    'driver_incident_damage_take_photos': 'Take damage photos',
    'driver_incident_damage_replace_photos': 'Replace damage photos',
    'driver_incident_time_section_title': 'Accident time',
    'driver_incident_time_now': 'Accident happened now',
    'driver_incident_time_other': 'Other date / time',
    'driver_incident_description_title': 'Accident description',
    'driver_incident_description_hint':
        'Describe the accident as precisely as possible...',
    'driver_incident_submit_sending': 'Sending...',
    'driver_incident_submit': 'Submit incident report',
    'driver_incident_header_title': 'Incident Report',
    'driver_incident_select_date_time': 'Select date / time',
  },
  'de': {
    'driver_incident_company_not_configured': 'Firmendaten nicht konfiguriert',
    'driver_incident_insurance_not_configured':
        'Versicherungsdaten nicht konfiguriert',
    'driver_incident_snack_could_not_read_image_bytes':
        'Bilddaten konnten nicht gelesen werden.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'Ausgewählte Bilddaten konnten nicht gelesen werden.',
    'driver_incident_snack_no_company_or_insurance_email':
        'Keine Firmen- oder Versicherungs-E-Mail konfiguriert.',
    'driver_incident_email_intro': 'Details zum Unfallbericht des Fahrers',
    'driver_incident_email_driver': 'Fahrer: {value}',
    'driver_incident_email_location': 'Unfallort: {value}',
    'driver_incident_email_fault_opinion': 'Einschätzung zur Schuld: {value}',
    'driver_incident_email_police_involved': 'Polizei hinzugezogen: {value}',
    'driver_incident_email_damage_type': 'Art des Schadens: {value}',
    'driver_incident_email_accident_time': 'Unfallzeitpunkt: {value}',
    'driver_incident_email_description': 'Beschreibung: {value}',
    'driver_incident_email_subject': 'Unfallbericht Details',
    'driver_incident_snack_could_not_open_email':
        'E-Mail-App konnte nicht geöffnet werden.',
    'driver_incident_snack_could_not_open_phone':
        'Telefon-App konnte nicht geöffnet werden.',
    'driver_incident_snack_must_be_logged_in_driver':
        'Du musst als Fahrer angemeldet sein.',
    'driver_incident_snack_missing_scope': 'DSP- oder Fahrer-Zuordnung fehlt.',
    'driver_incident_snack_provide_location': 'Bitte Unfallort angeben.',
    'driver_incident_snack_provide_description':
        'Bitte kurze Beschreibung angeben.',
    'driver_incident_snack_submitted': 'Unfallbericht wurde gesendet.',
    'driver_incident_snack_submit_failed':
        'Unfallbericht konnte nicht gesendet werden: {error}',
    'driver_incident_company_section_title': 'Firmendaten',
    'driver_incident_insurance_section_title': 'Versicherungsdaten',
    'driver_incident_insurance_policy_number': 'Versicherungsnr: {value}',
    'driver_incident_share_by_email': 'Daten per E-Mail teilen',
    'driver_incident_location_section_title': 'Unfallort',
    'driver_incident_scan_location': 'Standort scannen',
    'driver_incident_snack_enter_location_manually':
        'Bitte Standort manuell eingeben.',
    'driver_incident_or_enter_manually': 'Oder manuell eingeben',
    'driver_incident_location_hint': 'Straße, PLZ, Ort',
    'driver_incident_fault_question': 'Wer ist deiner Meinung nach schuld?',
    'driver_incident_fault_self': 'Ich selbst',
    'driver_incident_fault_other': 'Der Unfallgegner',
    'driver_incident_fault_both': 'Beide Parteien',
    'driver_incident_fault_unclear': 'Unklar / Nicht eindeutig',
    'driver_incident_police_question': 'Wurde die Polizei hinzugezogen?',
    'driver_incident_yes': 'Ja',
    'driver_incident_no': 'Nein',
    'driver_incident_plate_section_title': 'Kennzeichen fotografieren',
    'driver_incident_plate_take': 'Kennzeichen aufnehmen',
    'driver_incident_plate_replace': 'Kennzeichenfoto ersetzen',
    'driver_incident_damage_section_title': 'Fotos vom Schaden',
    'driver_incident_damage_type_label': 'Art des Schadens',
    'driver_incident_damage_vehicle': 'Fahrzeugschaden',
    'driver_incident_damage_property': 'Sachbeschädigung',
    'driver_incident_damage_both': 'Beides',
    'driver_incident_damage_take_photos': 'Schadenfotos aufnehmen',
    'driver_incident_damage_replace_photos': 'Schadenfotos ersetzen',
    'driver_incident_time_section_title': 'Unfallzeitpunkt',
    'driver_incident_time_now': 'Unfall ist gerade passiert',
    'driver_incident_time_other': 'Anderes Datum / Uhrzeit',
    'driver_incident_description_title': 'Beschreibung des Unfalls',
    'driver_incident_description_hint':
        'Beschreibe den Unfallhergang so genau wie möglich...',
    'driver_incident_submit_sending': 'Wird gesendet...',
    'driver_incident_submit': 'Unfallbericht absenden',
    'driver_incident_header_title': 'Unfallbericht',
    'driver_incident_select_date_time': 'Datum / Uhrzeit auswählen',
  },
  'sq': {
    'driver_incident_company_not_configured':
        'Te dhenat e kompanise nuk jane konfiguruar',
    'driver_incident_insurance_not_configured':
        'Te dhenat e sigurimit nuk jane konfiguruar',
    'driver_incident_snack_could_not_read_image_bytes':
        'Nuk u lexuan te dhenat e fotos.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'Nuk u lexuan te dhenat e fotove te zgjedhura.',
    'driver_incident_snack_no_company_or_insurance_email':
        'Nuk ka email te kompanise ose sigurimit te konfiguruar.',
    'driver_incident_email_intro':
        'Detajet e raportit te incidentit te shoferit',
    'driver_incident_email_driver': 'Shoferi: {value}',
    'driver_incident_email_location': 'Vendndodhja: {value}',
    'driver_incident_email_fault_opinion': 'Mendimi per fajin: {value}',
    'driver_incident_email_police_involved': 'Policia e perfshire: {value}',
    'driver_incident_email_damage_type': 'Lloji i demit: {value}',
    'driver_incident_email_accident_time': 'Koha e aksidentit: {value}',
    'driver_incident_email_description': 'Pershkrimi: {value}',
    'driver_incident_email_subject': 'Detajet e raportit te incidentit',
    'driver_incident_snack_could_not_open_email':
        'Aplikacioni i email-it nuk u hap.',
    'driver_incident_snack_could_not_open_phone':
        'Aplikacioni i telefonit nuk u hap.',
    'driver_incident_snack_must_be_logged_in_driver':
        'Duhet te jesh i identifikuar si shofer.',
    'driver_incident_snack_missing_scope': 'Mungon DSP ose shoferi.',
    'driver_incident_snack_provide_location':
        'Ju lutem jepni vendndodhjen e aksidentit.',
    'driver_incident_snack_provide_description':
        'Ju lutem jepni nje pershkrim te shkurter.',
    'driver_incident_snack_submitted': 'Raporti i incidentit u dergua.',
    'driver_incident_snack_submit_failed':
        'Dergimi i raportit deshtoi: {error}',
    'driver_incident_company_section_title': 'Te dhenat e kompanise',
    'driver_incident_insurance_section_title': 'Te dhenat e sigurimit',
    'driver_incident_insurance_policy_number': 'Nr. i sigurimit: {value}',
    'driver_incident_share_by_email': 'Ndaj te dhenat me e-mail',
    'driver_incident_location_section_title': 'Vendi i aksidentit',
    'driver_incident_scan_location': 'Skano vendndodhjen',
    'driver_incident_snack_enter_location_manually':
        'Ju lutem shkruani vendndodhjen manualisht.',
    'driver_incident_or_enter_manually': 'Ose shkruaje manualisht',
    'driver_incident_location_hint': 'Rruga, Kodi postar, Qyteti',
    'driver_incident_fault_question': 'Sipas teje kush eshte fajtor?',
    'driver_incident_fault_self': 'Une',
    'driver_incident_fault_other': 'Pala tjeter',
    'driver_incident_fault_both': 'Te dyja palet',
    'driver_incident_fault_unclear': 'E paqarte / Jo e sigurt',
    'driver_incident_police_question': 'A u thirr policia?',
    'driver_incident_yes': 'Po',
    'driver_incident_no': 'Jo',
    'driver_incident_plate_section_title': 'Fotografo targen',
    'driver_incident_plate_take': 'Bej foto te targes',
    'driver_incident_plate_replace': 'Zevendeso foton e targes',
    'driver_incident_damage_section_title': 'Foto te demit',
    'driver_incident_damage_type_label': 'Lloji i demit',
    'driver_incident_damage_vehicle': 'Dem ne mjet',
    'driver_incident_damage_property': 'Dem ne prone',
    'driver_incident_damage_both': 'Te dyja',
    'driver_incident_damage_take_photos': 'Bej foto te demit',
    'driver_incident_damage_replace_photos': 'Zevendeso fotot e demit',
    'driver_incident_time_section_title': 'Koha e aksidentit',
    'driver_incident_time_now': 'Aksidenti ndodhi tani',
    'driver_incident_time_other': 'Date / ore tjeter',
    'driver_incident_description_title': 'Pershkrimi i aksidentit',
    'driver_incident_description_hint':
        'Pershkruaj aksidentin sa me sakte te jete e mundur...',
    'driver_incident_submit_sending': 'Duke derguar...',
    'driver_incident_submit': 'Dergo raportin e incidentit',
    'driver_incident_header_title': 'Raport incidenti',
    'driver_incident_select_date_time': 'Zgjidh daten / oren',
  },
  'hu': {
    'driver_incident_company_not_configured': 'Cegadatok nincsenek beallitva',
    'driver_incident_insurance_not_configured':
        'Biztositas adatai nincsenek beallitva',
    'driver_incident_snack_could_not_read_image_bytes':
        'A kepadatok nem olvashatok.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'A kivalasztott kepadatok nem olvashatok.',
    'driver_incident_snack_no_company_or_insurance_email':
        'Nincs beallitott ceges vagy biztositoi e-mail.',
    'driver_incident_email_intro': 'Vezetoi incidensjelentes reszletei',
    'driver_incident_email_driver': 'Sofor: {value}',
    'driver_incident_email_location': 'Helyszin: {value}',
    'driver_incident_email_fault_opinion': 'Felelosseg velemeny: {value}',
    'driver_incident_email_police_involved': 'Rendorseg bevonva: {value}',
    'driver_incident_email_damage_type': 'Kar tipusa: {value}',
    'driver_incident_email_accident_time': 'Baleset ideje: {value}',
    'driver_incident_email_description': 'Leiras: {value}',
    'driver_incident_email_subject': 'Incidensjelentes reszletei',
    'driver_incident_snack_could_not_open_email':
        'Az e-mail alkalmazas nem nyithato meg.',
    'driver_incident_snack_could_not_open_phone':
        'A telefon alkalmazas nem nyithato meg.',
    'driver_incident_snack_must_be_logged_in_driver':
        'Soforkent kell bejelentkezni.',
    'driver_incident_snack_missing_scope':
        'Hianyzik a DSP vagy a sofor azonosito.',
    'driver_incident_snack_provide_location':
        'Kerjuk add meg a baleset helyet.',
    'driver_incident_snack_provide_description':
        'Kerjuk adj meg rovid leirast.',
    'driver_incident_snack_submitted': 'Az incidensjelentes elkuldve.',
    'driver_incident_snack_submit_failed':
        'Az incidensjelentes kuldese sikertelen: {error}',
    'driver_incident_company_section_title': 'Cegadatok',
    'driver_incident_insurance_section_title': 'Biztositas adatai',
    'driver_incident_insurance_policy_number': 'Biztositasi szam: {value}',
    'driver_incident_share_by_email': 'Adatok megosztasa e-mailben',
    'driver_incident_location_section_title': 'Baleset helye',
    'driver_incident_scan_location': 'Helyszin beolvasasa',
    'driver_incident_snack_enter_location_manually':
        'Kerjuk add meg a helyszint kezzel.',
    'driver_incident_or_enter_manually': 'Vagy add meg kezzel',
    'driver_incident_location_hint': 'Utca, iranyitoszam, varos',
    'driver_incident_fault_question': 'Ki a hibas velemenyed szerint?',
    'driver_incident_fault_self': 'En',
    'driver_incident_fault_other': 'Masik fel',
    'driver_incident_fault_both': 'Mindket fel',
    'driver_incident_fault_unclear': 'Nem egyertelmu',
    'driver_incident_police_question': 'Kihivtak a rendorseget?',
    'driver_incident_yes': 'Igen',
    'driver_incident_no': 'Nem',
    'driver_incident_plate_section_title': 'Rendszam fotozasa',
    'driver_incident_plate_take': 'Rendszam foto keszitese',
    'driver_incident_plate_replace': 'Rendszam foto cserelese',
    'driver_incident_damage_section_title': 'Karfoto(k)',
    'driver_incident_damage_type_label': 'Kar tipusa',
    'driver_incident_damage_vehicle': 'Jarmukar',
    'driver_incident_damage_property': 'Tulajdonkar',
    'driver_incident_damage_both': 'Mindketto',
    'driver_incident_damage_take_photos': 'Karfotok keszitese',
    'driver_incident_damage_replace_photos': 'Karfotok cserelese',
    'driver_incident_time_section_title': 'Baleset idopontja',
    'driver_incident_time_now': 'A baleset most tortent',
    'driver_incident_time_other': 'Mas datum / ido',
    'driver_incident_description_title': 'Baleset leirasa',
    'driver_incident_description_hint':
        'Ird le a baleset lefolyasat minel pontosabban...',
    'driver_incident_submit_sending': 'Kuldes...',
    'driver_incident_submit': 'Baleseti jelentés kuldese',
    'driver_incident_header_title': 'Baleseti jelentés',
    'driver_incident_select_date_time': 'Datum / ido kivalasztasa',
  },
  'ro': {
    'driver_incident_company_not_configured':
        'Datele companiei nu sunt configurate',
    'driver_incident_insurance_not_configured':
        'Datele asigurarii nu sunt configurate',
    'driver_incident_snack_could_not_read_image_bytes':
        'Datele imaginii nu au putut fi citite.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'Datele imaginilor selectate nu au putut fi citite.',
    'driver_incident_snack_no_company_or_insurance_email':
        'Nu exista email de companie sau asigurare configurat.',
    'driver_incident_email_intro': 'Detalii raport incident sofer',
    'driver_incident_email_driver': 'Sofer: {value}',
    'driver_incident_email_location': 'Locatie: {value}',
    'driver_incident_email_fault_opinion': 'Opinie despre vina: {value}',
    'driver_incident_email_police_involved': 'Politia implicata: {value}',
    'driver_incident_email_damage_type': 'Tipul pagubei: {value}',
    'driver_incident_email_accident_time': 'Ora accidentului: {value}',
    'driver_incident_email_description': 'Descriere: {value}',
    'driver_incident_email_subject': 'Detalii raport incident',
    'driver_incident_snack_could_not_open_email':
        'Aplicatia de email nu a putut fi deschisa.',
    'driver_incident_snack_could_not_open_phone':
        'Aplicatia de telefon nu a putut fi deschisa.',
    'driver_incident_snack_must_be_logged_in_driver':
        'Trebuie sa fii autentificat ca sofer.',
    'driver_incident_snack_missing_scope': 'Lipseste DSP sau soferul.',
    'driver_incident_snack_provide_location':
        'Te rugam sa introduci locatia accidentului.',
    'driver_incident_snack_provide_description':
        'Te rugam sa introduci o scurta descriere.',
    'driver_incident_snack_submitted': 'Raportul de incident a fost trimis.',
    'driver_incident_snack_submit_failed':
        'Trimiterea raportului a esuat: {error}',
    'driver_incident_company_section_title': 'Date companie',
    'driver_incident_insurance_section_title': 'Date asigurare',
    'driver_incident_insurance_policy_number': 'Nr. asigurare: {value}',
    'driver_incident_share_by_email': 'Trimite datele prin e-mail',
    'driver_incident_location_section_title': 'Locul accidentului',
    'driver_incident_scan_location': 'Scaneaza locatia',
    'driver_incident_snack_enter_location_manually':
        'Te rugam introdu locatia manual.',
    'driver_incident_or_enter_manually': 'Sau introdu manual',
    'driver_incident_location_hint': 'Strada, Cod postal, Oras',
    'driver_incident_fault_question': 'Cine crezi ca este vinovat?',
    'driver_incident_fault_self': 'Eu',
    'driver_incident_fault_other': 'Cealalta parte',
    'driver_incident_fault_both': 'Ambele parti',
    'driver_incident_fault_unclear': 'Neclar / Nesigur',
    'driver_incident_police_question': 'A fost chemata politia?',
    'driver_incident_yes': 'Da',
    'driver_incident_no': 'Nu',
    'driver_incident_plate_section_title':
        'Fotografiaza numarul de inmatriculare',
    'driver_incident_plate_take': 'Fa poza numarului',
    'driver_incident_plate_replace': 'Inlocuieste poza numarului',
    'driver_incident_damage_section_title': 'Poze cu paguba',
    'driver_incident_damage_type_label': 'Tipul pagubei',
    'driver_incident_damage_vehicle': 'Paguba vehicul',
    'driver_incident_damage_property': 'Paguba proprietate',
    'driver_incident_damage_both': 'Ambele',
    'driver_incident_damage_take_photos': 'Fa poze cu paguba',
    'driver_incident_damage_replace_photos': 'Inlocuieste pozele',
    'driver_incident_time_section_title': 'Momentul accidentului',
    'driver_incident_time_now': 'Accidentul s-a intamplat acum',
    'driver_incident_time_other': 'Alta data / ora',
    'driver_incident_description_title': 'Descrierea accidentului',
    'driver_incident_description_hint':
        'Descrie accidentul cat mai exact posibil...',
    'driver_incident_submit_sending': 'Se trimite...',
    'driver_incident_submit': 'Trimite raportul de incident',
    'driver_incident_header_title': 'Raport incident',
    'driver_incident_select_date_time': 'Selecteaza data / ora',
  },
  'hr': {
    'driver_incident_company_not_configured':
        'Podaci tvrtke nisu konfigurirani',
    'driver_incident_insurance_not_configured':
        'Podaci osiguranja nisu konfigurirani',
    'driver_incident_snack_could_not_read_image_bytes':
        'Podaci slike se ne mogu procitati.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'Podaci odabranih slika se ne mogu procitati.',
    'driver_incident_snack_no_company_or_insurance_email':
        'Nije konfiguriran email tvrtke ili osiguranja.',
    'driver_incident_email_intro': 'Detalji izvjestaja o nesreci vozaca',
    'driver_incident_email_driver': 'Vozac: {value}',
    'driver_incident_email_location': 'Lokacija: {value}',
    'driver_incident_email_fault_opinion': 'Misljenje o krivnji: {value}',
    'driver_incident_email_police_involved': 'Policija ukljucena: {value}',
    'driver_incident_email_damage_type': 'Vrsta stete: {value}',
    'driver_incident_email_accident_time': 'Vrijeme nesrece: {value}',
    'driver_incident_email_description': 'Opis: {value}',
    'driver_incident_email_subject': 'Detalji izvjestaja o nesreci',
    'driver_incident_snack_could_not_open_email':
        'Aplikacija za e-postu se ne moze otvoriti.',
    'driver_incident_snack_could_not_open_phone':
        'Aplikacija za telefon se ne moze otvoriti.',
    'driver_incident_snack_must_be_logged_in_driver':
        'Morate biti prijavljeni kao vozac.',
    'driver_incident_snack_missing_scope': 'Nedostaje DSP ili vozac.',
    'driver_incident_snack_provide_location':
        'Molimo unesite lokaciju nesrece.',
    'driver_incident_snack_provide_description': 'Molimo unesite kratak opis.',
    'driver_incident_snack_submitted': 'Izvjestaj o nesreci je poslan.',
    'driver_incident_snack_submit_failed':
        'Slanje izvjestaja nije uspjelo: {error}',
    'driver_incident_company_section_title': 'Podaci tvrtke',
    'driver_incident_insurance_section_title': 'Podaci osiguranja',
    'driver_incident_insurance_policy_number': 'Broj police: {value}',
    'driver_incident_share_by_email': 'Podijeli podatke e-postom',
    'driver_incident_location_section_title': 'Mjesto nesrece',
    'driver_incident_scan_location': 'Skeniraj lokaciju',
    'driver_incident_snack_enter_location_manually':
        'Molimo unesite lokaciju rucno.',
    'driver_incident_or_enter_manually': 'Ili unesite rucno',
    'driver_incident_location_hint': 'Ulica, postanski broj, grad',
    'driver_incident_fault_question': 'Tko je po vasem misljenju kriv?',
    'driver_incident_fault_self': 'Ja',
    'driver_incident_fault_other': 'Druga strana',
    'driver_incident_fault_both': 'Obje strane',
    'driver_incident_fault_unclear': 'Nejasno / Nesigurno',
    'driver_incident_police_question': 'Je li policija pozvana?',
    'driver_incident_yes': 'Da',
    'driver_incident_no': 'Ne',
    'driver_incident_plate_section_title': 'Fotografiraj registraciju',
    'driver_incident_plate_take': 'Snimi registraciju',
    'driver_incident_plate_replace': 'Zamijeni fotografiju registracije',
    'driver_incident_damage_section_title': 'Fotografije stete',
    'driver_incident_damage_type_label': 'Vrsta stete',
    'driver_incident_damage_vehicle': 'Steta na vozilu',
    'driver_incident_damage_property': 'Materijalna steta',
    'driver_incident_damage_both': 'Oboje',
    'driver_incident_damage_take_photos': 'Snimi fotografije stete',
    'driver_incident_damage_replace_photos': 'Zamijeni fotografije stete',
    'driver_incident_time_section_title': 'Vrijeme nesrece',
    'driver_incident_time_now': 'Nesreca se upravo dogodila',
    'driver_incident_time_other': 'Drugi datum / vrijeme',
    'driver_incident_description_title': 'Opis nesrece',
    'driver_incident_description_hint': 'Opisi tijek nesrece sto preciznije...',
    'driver_incident_submit_sending': 'Slanje...',
    'driver_incident_submit': 'Posalji izvjestaj o nesreci',
    'driver_incident_header_title': 'Izvjestaj o nesreci',
    'driver_incident_select_date_time': 'Odaberi datum / vrijeme',
  },
  'ar': {
    'driver_incident_company_not_configured': 'بيانات الشركة غير مهيأة',
    'driver_incident_insurance_not_configured': 'بيانات التأمين غير مهيأة',
    'driver_incident_snack_could_not_read_image_bytes':
        'تعذر قراءة بيانات الصورة.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'تعذر قراءة بيانات الصور المحددة.',
    'driver_incident_snack_no_company_or_insurance_email':
        'لا يوجد بريد إلكتروني للشركة أو التأمين.',
    'driver_incident_email_intro': 'تفاصيل تقرير الحادث للسائق',
    'driver_incident_email_driver': 'السائق: {value}',
    'driver_incident_email_location': 'الموقع: {value}',
    'driver_incident_email_fault_opinion': 'الرأي في المسؤولية: {value}',
    'driver_incident_email_police_involved': 'هل الشرطة حضرت: {value}',
    'driver_incident_email_damage_type': 'نوع الضرر: {value}',
    'driver_incident_email_accident_time': 'وقت الحادث: {value}',
    'driver_incident_email_description': 'الوصف: {value}',
    'driver_incident_email_subject': 'تفاصيل تقرير الحادث',
    'driver_incident_snack_could_not_open_email':
        'تعذر فتح تطبيق البريد الإلكتروني.',
    'driver_incident_snack_could_not_open_phone': 'تعذر فتح تطبيق الهاتف.',
    'driver_incident_snack_must_be_logged_in_driver': 'يجب تسجيل الدخول كسائق.',
    'driver_incident_snack_missing_scope': 'بيانات DSP أو السائق مفقودة.',
    'driver_incident_snack_provide_location': 'يرجى إدخال موقع الحادث.',
    'driver_incident_snack_provide_description': 'يرجى إدخال وصف قصير.',
    'driver_incident_snack_submitted': 'تم إرسال تقرير الحادث.',
    'driver_incident_snack_submit_failed': 'فشل إرسال التقرير: {error}',
    'driver_incident_company_section_title': 'بيانات الشركة',
    'driver_incident_insurance_section_title': 'بيانات التأمين',
    'driver_incident_insurance_policy_number': 'رقم التأمين: {value}',
    'driver_incident_share_by_email': 'مشاركة البيانات عبر البريد الإلكتروني',
    'driver_incident_location_section_title': 'مكان الحادث',
    'driver_incident_scan_location': 'مسح الموقع',
    'driver_incident_snack_enter_location_manually':
        'يرجى إدخال الموقع يدويًا.',
    'driver_incident_or_enter_manually': 'أو أدخل يدويًا',
    'driver_incident_location_hint': 'الشارع، الرمز البريدي، المدينة',
    'driver_incident_fault_question': 'من برأيك هو المسؤول؟',
    'driver_incident_fault_self': 'أنا',
    'driver_incident_fault_other': 'الطرف الآخر',
    'driver_incident_fault_both': 'الطرفان',
    'driver_incident_fault_unclear': 'غير واضح / غير مؤكد',
    'driver_incident_police_question': 'هل تم استدعاء الشرطة؟',
    'driver_incident_yes': 'نعم',
    'driver_incident_no': 'لا',
    'driver_incident_plate_section_title': 'تصوير لوحة السيارة',
    'driver_incident_plate_take': 'التقاط صورة للوحة',
    'driver_incident_plate_replace': 'استبدال صورة اللوحة',
    'driver_incident_damage_section_title': 'صور الضرر',
    'driver_incident_damage_type_label': 'نوع الضرر',
    'driver_incident_damage_vehicle': 'ضرر بالمركبة',
    'driver_incident_damage_property': 'ضرر بالممتلكات',
    'driver_incident_damage_both': 'كلاهما',
    'driver_incident_damage_take_photos': 'التقاط صور الضرر',
    'driver_incident_damage_replace_photos': 'استبدال صور الضرر',
    'driver_incident_time_section_title': 'وقت الحادث',
    'driver_incident_time_now': 'الحادث وقع الآن',
    'driver_incident_time_other': 'تاريخ / وقت آخر',
    'driver_incident_description_title': 'وصف الحادث',
    'driver_incident_description_hint':
        'صف تفاصيل الحادث بأكبر قدر ممكن من الدقة...',
    'driver_incident_submit_sending': 'جاري الإرسال...',
    'driver_incident_submit': 'إرسال تقرير الحادث',
    'driver_incident_header_title': 'تقرير الحادث',
    'driver_incident_select_date_time': 'اختر التاريخ / الوقت',
  },
  'tr': {
    'driver_incident_company_not_configured': 'Sirket bilgileri ayarlanmamis',
    'driver_incident_insurance_not_configured':
        'Sigorta bilgileri ayarlanmamis',
    'driver_incident_snack_could_not_read_image_bytes':
        'Gorsel verileri okunamadi.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'Secilen gorsellerin verileri okunamadi.',
    'driver_incident_snack_no_company_or_insurance_email':
        'Sirket veya sigorta e-postasi ayarlanmamis.',
    'driver_incident_email_intro': 'Surucu olay raporu detaylari',
    'driver_incident_email_driver': 'Surucu: {value}',
    'driver_incident_email_location': 'Konum: {value}',
    'driver_incident_email_fault_opinion': 'Kusur gorusu: {value}',
    'driver_incident_email_police_involved': 'Polis dahil mi: {value}',
    'driver_incident_email_damage_type': 'Hasar tipi: {value}',
    'driver_incident_email_accident_time': 'Kaza saati: {value}',
    'driver_incident_email_description': 'Aciklama: {value}',
    'driver_incident_email_subject': 'Olay raporu detaylari',
    'driver_incident_snack_could_not_open_email':
        'E-posta uygulamasi acilamadi.',
    'driver_incident_snack_could_not_open_phone':
        'Telefon uygulamasi acilamadi.',
    'driver_incident_snack_must_be_logged_in_driver':
        'Surucu olarak giris yapmalisiniz.',
    'driver_incident_snack_missing_scope': 'DSP veya surucu bilgisi eksik.',
    'driver_incident_snack_provide_location': 'Lutfen kaza konumunu girin.',
    'driver_incident_snack_provide_description':
        'Lutfen kisa bir aciklama girin.',
    'driver_incident_snack_submitted': 'Olay raporu gonderildi.',
    'driver_incident_snack_submit_failed': 'Rapor gonderilemedi: {error}',
    'driver_incident_company_section_title': 'Sirket Bilgileri',
    'driver_incident_insurance_section_title': 'Sigorta Bilgileri',
    'driver_incident_insurance_policy_number': 'Poliçe no: {value}',
    'driver_incident_share_by_email': 'Bilgileri e-posta ile paylas',
    'driver_incident_location_section_title': 'Kaza Yeri',
    'driver_incident_scan_location': 'Konum tara',
    'driver_incident_snack_enter_location_manually':
        'Lutfen konumu manuel girin.',
    'driver_incident_or_enter_manually': 'Veya manuel girin',
    'driver_incident_location_hint': 'Sokak, posta kodu, sehir',
    'driver_incident_fault_question': 'Sence kim hatali?',
    'driver_incident_fault_self': 'Ben',
    'driver_incident_fault_other': 'Karsi taraf',
    'driver_incident_fault_both': 'Iki taraf da',
    'driver_incident_fault_unclear': 'Belirsiz / Emin degil',
    'driver_incident_police_question': 'Polis cagrildi mi?',
    'driver_incident_yes': 'Evet',
    'driver_incident_no': 'Hayir',
    'driver_incident_plate_section_title': 'Plakayi fotograflayin',
    'driver_incident_plate_take': 'Plaka fotosu cek',
    'driver_incident_plate_replace': 'Plaka fotosunu degistir',
    'driver_incident_damage_section_title': 'Hasar Fotograflari',
    'driver_incident_damage_type_label': 'Hasar Turu',
    'driver_incident_damage_vehicle': 'Arac hasari',
    'driver_incident_damage_property': 'Mulk hasari',
    'driver_incident_damage_both': 'Ikisi de',
    'driver_incident_damage_take_photos': 'Hasar fotograflari cek',
    'driver_incident_damage_replace_photos': 'Hasar fotograflarini degistir',
    'driver_incident_time_section_title': 'Kaza Zamani',
    'driver_incident_time_now': 'Kaza simdi oldu',
    'driver_incident_time_other': 'Diger tarih / saat',
    'driver_incident_description_title': 'Kazanin Aciklamasi',
    'driver_incident_description_hint':
        'Kazayi olabildigince ayrintili aciklayin...',
    'driver_incident_submit_sending': 'Gonderiliyor...',
    'driver_incident_submit': 'Olay raporunu gonder',
    'driver_incident_header_title': 'Olay Raporu',
    'driver_incident_select_date_time': 'Tarih / saat secin',
  },
  'ru': {
    'driver_incident_company_not_configured': 'Данные компании не настроены',
    'driver_incident_insurance_not_configured': 'Данные страховки не настроены',
    'driver_incident_snack_could_not_read_image_bytes':
        'Не удалось прочитать данные изображения.',
    'driver_incident_snack_could_not_read_selected_image_bytes':
        'Не удалось прочитать данные выбранных изображений.',
    'driver_incident_snack_no_company_or_insurance_email':
        'Не указан e-mail компании или страховой.',
    'driver_incident_email_intro': 'Детали отчета об инциденте водителя',
    'driver_incident_email_driver': 'Водитель: {value}',
    'driver_incident_email_location': 'Место: {value}',
    'driver_incident_email_fault_opinion': 'Мнение о виновности: {value}',
    'driver_incident_email_police_involved': 'Полиция привлечена: {value}',
    'driver_incident_email_damage_type': 'Тип ущерба: {value}',
    'driver_incident_email_accident_time': 'Время аварии: {value}',
    'driver_incident_email_description': 'Описание: {value}',
    'driver_incident_email_subject': 'Детали отчета об инциденте',
    'driver_incident_snack_could_not_open_email':
        'Не удалось открыть почтовое приложение.',
    'driver_incident_snack_could_not_open_phone':
        'Не удалось открыть приложение телефона.',
    'driver_incident_snack_must_be_logged_in_driver':
        'Вы должны войти как водитель.',
    'driver_incident_snack_missing_scope':
        'Отсутствуют данные DSP или водителя.',
    'driver_incident_snack_provide_location': 'Укажите место аварии.',
    'driver_incident_snack_provide_description': 'Укажите короткое описание.',
    'driver_incident_snack_submitted': 'Отчет об инциденте отправлен.',
    'driver_incident_snack_submit_failed':
        'Не удалось отправить отчет: {error}',
    'driver_incident_company_section_title': 'Данные компании',
    'driver_incident_insurance_section_title': 'Данные страховки',
    'driver_incident_insurance_policy_number': 'Номер полиса: {value}',
    'driver_incident_share_by_email': 'Отправить данные по e-mail',
    'driver_incident_location_section_title': 'Место аварии',
    'driver_incident_scan_location': 'Сканировать местоположение',
    'driver_incident_snack_enter_location_manually':
        'Введите местоположение вручную.',
    'driver_incident_or_enter_manually': 'Или введите вручную',
    'driver_incident_location_hint': 'Улица, индекс, город',
    'driver_incident_fault_question': 'Кто, по вашему мнению, виноват?',
    'driver_incident_fault_self': 'Я',
    'driver_incident_fault_other': 'Другая сторона',
    'driver_incident_fault_both': 'Обе стороны',
    'driver_incident_fault_unclear': 'Неясно / Не уверен',
    'driver_incident_police_question': 'Полиция была вызвана?',
    'driver_incident_yes': 'Да',
    'driver_incident_no': 'Нет',
    'driver_incident_plate_section_title': 'Сфотографировать номерной знак',
    'driver_incident_plate_take': 'Сделать фото номера',
    'driver_incident_plate_replace': 'Заменить фото номера',
    'driver_incident_damage_section_title': 'Фото повреждений',
    'driver_incident_damage_type_label': 'Тип повреждения',
    'driver_incident_damage_vehicle': 'Повреждение автомобиля',
    'driver_incident_damage_property': 'Повреждение имущества',
    'driver_incident_damage_both': 'Оба',
    'driver_incident_damage_take_photos': 'Сделать фото повреждений',
    'driver_incident_damage_replace_photos': 'Заменить фото повреждений',
    'driver_incident_time_section_title': 'Время аварии',
    'driver_incident_time_now': 'Авария произошла только что',
    'driver_incident_time_other': 'Другая дата / время',
    'driver_incident_description_title': 'Описание аварии',
    'driver_incident_description_hint':
        'Опишите ход аварии как можно точнее...',
    'driver_incident_submit_sending': 'Отправка...',
    'driver_incident_submit': 'Отправить отчет об аварии',
    'driver_incident_header_title': 'Отчет об аварии',
    'driver_incident_select_date_time': 'Выберите дату / время',
  },
};
