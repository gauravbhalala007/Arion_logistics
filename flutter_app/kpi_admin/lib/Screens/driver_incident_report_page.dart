import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  static const Color _kText = Color(0xFF1F2937);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kCardBorder = Color(0xFFD9DFE3);

  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  bool _loadingSettings = true;
  bool _submitting = false;

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
        return 'Company not configured';
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
        return 'Insurance not configured';
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
      _showSnack('Could not read image bytes.', error: true);
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
      _showSnack('Could not read selected image bytes.', error: true);
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
      _showSnack('No company or insurance email configured.', error: true);
      return;
    }

    final body = StringBuffer()
      ..writeln('Driver incident report details')
      ..writeln()
      ..writeln('Driver: ${widget.driverTransporterId.toUpperCase()}')
      ..writeln(
        'Location: ${_locationCtrl.text.trim().isEmpty ? '-' : _locationCtrl.text.trim()}',
      )
      ..writeln('Fault opinion: ${_faultLabel(_faultOpinion)}')
      ..writeln('Police involved: ${_policeInvolved ? 'Yes' : 'No'}')
      ..writeln('Damage type: ${_damageLabel(_damageType)}')
      ..writeln(
        'Accident time: ${_formatDateTime(_accidentNow ? DateTime.now() : _selectedAccidentTime)}',
      )
      ..writeln()
      ..writeln(
        'Description: ${_descriptionCtrl.text.trim().isEmpty ? '-' : _descriptionCtrl.text.trim()}',
      );

    final mail = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: <String, String>{
        'subject': 'Incident report details',
        'body': body.toString(),
      },
    );
    final opened = await launchUrl(mail, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      _showSnack('Could not open email app.', error: true);
    }
  }

  Future<void> _submit() async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth == null) {
      _showSnack('You must be logged in as driver.', error: true);
      return;
    }
    if (widget.dspUid.trim().isEmpty ||
        widget.driverTransporterId.trim().isEmpty) {
      _showSnack('Missing DSP or driver scope.', error: true);
      return;
    }

    if (_locationCtrl.text.trim().isEmpty) {
      _showSnack('Please provide accident location.', error: true);
      return;
    }
    if (_descriptionCtrl.text.trim().isEmpty) {
      _showSnack('Please provide a short description.', error: true);
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
      _showSnack('Incident report submitted.');
    } catch (e) {
      _showSnack('Failed to submit report: $e', error: true);
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

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 120),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF7A18),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Incident Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _kText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.business_outlined, 'Company Details'),
                    const SizedBox(height: 8),
                    _labelValue(_companyValue('name')),
                    _muted(_companyValue('addressLine1')),
                    _muted(_companyValue('addressLine2')),
                    if (_companyValue('phone').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _linkText(_companyValue('phone')),
                    ],
                    if (_companyValue('email').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      _linkText(_companyValue('email')),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.shield_outlined, 'Insurance Details'),
                    const SizedBox(height: 8),
                    _labelValue(_insuranceValue('name')),
                    _muted(
                      _insuranceValue('policyNumber').isEmpty
                          ? '-'
                          : 'Policy: ${_insuranceValue('policyNumber')}',
                    ),
                    if (_insuranceValue('email').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _linkText(_insuranceValue('email')),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _shareByEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kGreen,
                    side: const BorderSide(color: _kGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share details by email'),
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      Icons.location_on_outlined,
                      'Accident Location',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showSnack('Please enter location manually.'),
                        icon: const Icon(Icons.my_location),
                        label: const Text('Scan location'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Street, ZIP, City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Who do you think is at fault?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    _faultRadio('self', 'Me'),
                    _faultRadio('other', 'Other party'),
                    _faultRadio('both', 'Both parties'),
                    _faultRadio('unclear', 'Unclear / Not sure'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Was police involved?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _policeInvolved,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _policeInvolved = v);
                      },
                      activeColor: _kGreen,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Yes'),
                    ),
                    RadioListTile<bool>(
                      value: false,
                      groupValue: _policeInvolved,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _policeInvolved = v);
                      },
                      activeColor: _kGreen,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('No'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      Icons.photo_camera_outlined,
                      'Photograph license plate',
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickPlatePhoto,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          _platePhoto == null
                              ? 'Take plate photo'
                              : 'Replace plate photo',
                        ),
                      ),
                    ),
                    if (_platePhoto != null) ...[
                      const SizedBox(height: 8),
                      _imagePreview(_platePhoto!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.photo_camera_outlined, 'Damage photos'),
                    const SizedBox(height: 8),
                    const Text(
                      'Type of damage',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    _damageRadio('vehicle', 'Vehicle damage'),
                    _damageRadio('property', 'Property damage'),
                    _damageRadio('both', 'Both'),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickDamagePhotos,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _damagePhotos.isEmpty
                              ? 'Upload damage photos'
                              : 'Replace damage photos',
                        ),
                      ),
                    ),
                    if (_damagePhotos.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _damagePhotos
                            .map((photo) => _imagePreview(photo, compact: true))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.schedule_outlined, 'Accident time'),
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _accidentNow,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _accidentNow = v);
                      },
                      activeColor: _kGreen,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Accident happened now'),
                    ),
                    RadioListTile<bool>(
                      value: false,
                      groupValue: _accidentNow,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _accidentNow = v);
                      },
                      activeColor: _kGreen,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Select date / time'),
                    ),
                    if (!_accidentNow) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickAccidentDateTime,
                          icon: const Icon(Icons.edit_calendar_outlined),
                          label: Text(_formatDateTime(_selectedAccidentTime)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accident description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionCtrl,
                      minLines: 5,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Describe what happened...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _submitting ? 'Submitting...' : 'Submit incident report',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kCardBorder),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 19, color: _kGreen),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 22 / 1.15,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
      ],
    );
  }

  Widget _labelValue(String text) {
    return Text(
      text.isEmpty ? '-' : text,
      style: const TextStyle(
        fontSize: 23 / 1.2,
        fontWeight: FontWeight.w800,
        color: _kText,
      ),
    );
  }

  Widget _muted(String text) {
    return Text(
      text.isEmpty ? '-' : text,
      style: const TextStyle(
        fontSize: 16,
        color: _kMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _linkText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: _kGreen,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _faultRadio(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _faultOpinion,
      onChanged: (v) {
        if (v == null) return;
        setState(() => _faultOpinion = v);
      },
      activeColor: _kGreen,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
    );
  }

  Widget _damageRadio(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _damageType,
      onChanged: (v) {
        if (v == null) return;
        setState(() => _damageType = v);
      },
      activeColor: _kGreen,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
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

  static String _faultLabel(String value) {
    switch (value) {
      case 'self':
        return 'Me';
      case 'other':
        return 'Other party';
      case 'both':
        return 'Both parties';
      case 'unclear':
        return 'Unclear';
      default:
        return value;
    }
  }

  static String _damageLabel(String value) {
    switch (value) {
      case 'vehicle':
        return 'Vehicle damage';
      case 'property':
        return 'Property damage';
      case 'both':
        return 'Both';
      default:
        return value;
    }
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) return 'Select date / time';
    return DateFormat('dd.MM.yyyy HH:mm').format(value);
  }
}

class _PickedPhoto {
  final String name;
  final Uint8List bytes;

  const _PickedPhoto({required this.name, required this.bytes});
}
