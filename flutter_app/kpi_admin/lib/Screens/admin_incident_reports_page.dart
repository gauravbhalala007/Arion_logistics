import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminIncidentReportsPage extends StatefulWidget {
  const AdminIncidentReportsPage({super.key});

  @override
  State<AdminIncidentReportsPage> createState() =>
      _AdminIncidentReportsPageState();
}

class _AdminIncidentReportsPageState extends State<AdminIncidentReportsPage> {
  static const _settingsCollection = 'settings';
  static const _settingsDoc = 'incident_report';
  static const _reportsCollection = 'incident_reports';

  static const Color _kGreen = Color(0xFF1D7F5A);
  static const Color _kText = Color(0xFF111827);
  static const Color _kMuted = Color(0xFF6B7280);
  static const Color _kBorder = Color(0xFFE5E7EB);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String? _resolvedDspUid;

  bool _loading = true;
  bool _saving = false;

  final _companyNameCtrl = TextEditingController();
  final _companyAddress1Ctrl = TextEditingController();
  final _companyAddress2Ctrl = TextEditingController();
  final _companyPhoneCtrl = TextEditingController();
  final _companyEmailCtrl = TextEditingController();

  final _insuranceNameCtrl = TextEditingController();
  final _insurancePolicyCtrl = TextEditingController();
  final _insuranceEmailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resolveScopeAndLoad();
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _companyAddress1Ctrl.dispose();
    _companyAddress2Ctrl.dispose();
    _companyPhoneCtrl.dispose();
    _companyEmailCtrl.dispose();
    _insuranceNameCtrl.dispose();
    _insurancePolicyCtrl.dispose();
    _insuranceEmailCtrl.dispose();
    super.dispose();
  }

  String? get _scopeUid {
    final uid = _uid;
    if (uid == null) return null;
    final scoped = (_resolvedDspUid ?? '').trim();
    if (scoped.isNotEmpty) return scoped;
    return uid;
  }

  DocumentReference<Map<String, dynamic>>? get _settingsRef {
    final uid = _scopeUid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_settingsCollection)
        .doc(_settingsDoc);
  }

  CollectionReference<Map<String, dynamic>>? get _reportsCol {
    final uid = _scopeUid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_reportsCollection);
  }

  Future<void> _resolveScopeAndLoad() async {
    final uid = _uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final userData = userSnap.data() ?? const <String, dynamic>{};
      final dspUid = (userData['dspUid'] ?? '').toString().trim();
      _resolvedDspUid = dspUid.isEmpty ? uid : dspUid;
    } catch (_) {
      _resolvedDspUid = uid;
    }

    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final ref = _settingsRef;
    if (ref == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    try {
      final snap = await ref.get();
      final data = snap.data() ?? const <String, dynamic>{};
      final company = _mapOf(data['company']);
      final insurance = _mapOf(data['insurance']);

      _companyNameCtrl.text = _firstNonEmpty([
        _stringOf(company['name']),
        _stringOf(data['company_name']),
      ]);
      _companyAddress1Ctrl.text = _firstNonEmpty([
        _stringOf(company['addressLine1']),
        _stringOf(data['company_addressLine1']),
      ]);
      _companyAddress2Ctrl.text = _firstNonEmpty([
        _stringOf(company['addressLine2']),
        _stringOf(data['company_addressLine2']),
      ]);
      _companyPhoneCtrl.text = _firstNonEmpty([
        _stringOf(company['phone']),
        _stringOf(data['company_phone']),
      ]);
      _companyEmailCtrl.text = _firstNonEmpty([
        _stringOf(company['email']),
        _stringOf(data['company_email']),
      ]);

      _insuranceNameCtrl.text = _firstNonEmpty([
        _stringOf(insurance['name']),
        _stringOf(data['insurance_name']),
      ]);
      _insurancePolicyCtrl.text = _firstNonEmpty([
        _stringOf(insurance['policyNumber']),
        _stringOf(data['insurance_policyNumber']),
      ]);
      _insuranceEmailCtrl.text = _firstNonEmpty([
        _stringOf(insurance['email']),
        _stringOf(data['insurance_email']),
      ]);
    } catch (e) {
      _showSnack('Failed to load incident settings: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSettings() async {
    final ref = _settingsRef;
    if (ref == null) {
      _showSnack('You must be logged in as admin.', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.set({
        'enabled': true,
        'company': {
          'name': _companyNameCtrl.text.trim(),
          'addressLine1': _companyAddress1Ctrl.text.trim(),
          'addressLine2': _companyAddress2Ctrl.text.trim(),
          'phone': _companyPhoneCtrl.text.trim(),
          'email': _companyEmailCtrl.text.trim(),
        },
        'insurance': {
          'name': _insuranceNameCtrl.text.trim(),
          'policyNumber': _insurancePolicyCtrl.text.trim(),
          'email': _insuranceEmailCtrl.text.trim(),
        },
        // Flat mirror for backward compatibility.
        'company_name': _companyNameCtrl.text.trim(),
        'company_addressLine1': _companyAddress1Ctrl.text.trim(),
        'company_addressLine2': _companyAddress2Ctrl.text.trim(),
        'company_phone': _companyPhoneCtrl.text.trim(),
        'company_email': _companyEmailCtrl.text.trim(),
        'insurance_name': _insuranceNameCtrl.text.trim(),
        'insurance_policyNumber': _insurancePolicyCtrl.text.trim(),
        'insurance_email': _insuranceEmailCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSnack('Incident report settings saved.');
    } catch (e) {
      _showSnack('Failed to save settings: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showReportDetails(Map<String, dynamic> data) {
    final company = _mapOf(data['company']);
    final insurance = _mapOf(data['insurance']);
    final plateUrl = _stringOf(data['platePhotoUrl']);
    final damageUrls = _listOfStrings(data['damagePhotoUrls']);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Incident Details'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(
                    'Driver',
                    _firstNonEmpty([
                      _stringOf(data['driverName']),
                      _stringOf(data['driverTransporterId']),
                    ]),
                  ),
                  _detailRow(
                    'Driver ID',
                    _stringOf(data['driverTransporterId']),
                  ),
                  _detailRow('Location', _stringOf(data['location'])),
                  _detailRow('Fault opinion', _stringOf(data['faultOpinion'])),
                  _detailRow(
                    'Police involved',
                    (data['policeInvolved'] == true) ? 'Yes' : 'No',
                  ),
                  _detailRow('Damage type', _stringOf(data['damageType'])),
                  _detailRow(
                    'Accident at',
                    _formatTimestamp(data['accidentAt']),
                  ),
                  _detailRow(
                    'Submitted at',
                    _formatTimestamp(data['submittedAt']),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stringOf(data['description']).isEmpty
                        ? '-'
                        : _stringOf(data['description']),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Company',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stringOf(company['name']).isEmpty
                        ? '-'
                        : _stringOf(company['name']),
                  ),
                  Text(
                    _stringOf(company['addressLine1']).isEmpty
                        ? '-'
                        : _stringOf(company['addressLine1']),
                  ),
                  Text(
                    _stringOf(company['addressLine2']).isEmpty
                        ? '-'
                        : _stringOf(company['addressLine2']),
                  ),
                  Text(
                    _stringOf(company['phone']).isEmpty
                        ? '-'
                        : _stringOf(company['phone']),
                  ),
                  Text(
                    _stringOf(company['email']).isEmpty
                        ? '-'
                        : _stringOf(company['email']),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Insurance',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _stringOf(insurance['name']).isEmpty
                        ? '-'
                        : _stringOf(insurance['name']),
                  ),
                  Text(
                    _stringOf(insurance['policyNumber']).isEmpty
                        ? '-'
                        : _stringOf(insurance['policyNumber']),
                  ),
                  Text(
                    _stringOf(insurance['email']).isEmpty
                        ? '-'
                        : _stringOf(insurance['email']),
                  ),
                  const SizedBox(height: 12),
                  if (plateUrl.isNotEmpty) ...[
                    const Text(
                      'Plate Photo',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    _urlPreview(plateUrl),
                    const SizedBox(height: 12),
                  ],
                  if (damageUrls.isNotEmpty) ...[
                    const Text(
                      'Damage Photos',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: damageUrls.map(_urlPreview).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _urlPreview(String url) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        width: 170,
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
          color: const Color(0xFFF9FAFB),
        ),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: TextButton(
              onPressed: () => _openUrl(url),
              child: const Text('Open image'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String raw) async {
    final url = raw.trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!opened) {
      _showSnack('Could not open URL.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: Text('You must be logged in as admin.'));
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final scopeUid = _scopeUid ?? '';
    final reportsCol = _reportsCol;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF7A18),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Incident Reports',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 8),
          // Text(
          //   'DSP scope: $scopeUid',
          //   style: const TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
          // ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : _loadSettings,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reload settings'),
              ),
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveSettings,
                icon: _saving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving...' : 'Save settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 1120;
                if (narrow) {
                  return ListView(
                    children: [
                      _settingsPanel(),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 520,
                        child: _submissionsPanel(reportsCol),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _settingsPanel()),
                    const SizedBox(width: 12),
                    Expanded(child: _submissionsPanel(reportsCol)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company and Insurance Settings',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: _kText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'These details are shown on the driver incident report page.',
              style: TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Company',
              style: TextStyle(fontWeight: FontWeight.w800, color: _kText),
            ),
            const SizedBox(height: 8),
            _field(_companyNameCtrl, 'Company name'),
            _field(_companyAddress1Ctrl, 'Address line 1'),
            _field(_companyAddress2Ctrl, 'Address line 2'),
            _field(_companyPhoneCtrl, 'Phone'),
            _field(
              _companyEmailCtrl,
              'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            const Text(
              'Insurance',
              style: TextStyle(fontWeight: FontWeight.w800, color: _kText),
            ),
            const SizedBox(height: 8),
            _field(_insuranceNameCtrl, 'Insurance company'),
            _field(_insurancePolicyCtrl, 'Policy number'),
            _field(
              _insuranceEmailCtrl,
              'Insurance email',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _submissionsPanel(
    CollectionReference<Map<String, dynamic>>? reportsCol,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Driver Submissions',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: _kText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Latest incident reports submitted by drivers.',
            style: TextStyle(color: _kMuted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: reportsCol == null
                ? const Center(child: Text('Missing DSP scope.'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: reportsCol
                        .orderBy('submittedAt', descending: true)
                        .limit(150)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text('Failed to load reports: ${snap.error}'),
                        );
                      }
                      final docs = snap.data?.docs ?? const [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text('No incident reports yet.'),
                        );
                      }

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final driverName = _firstNonEmpty([
                            _stringOf(data['driverName']),
                            _stringOf(data['driverTransporterId']),
                            'Unknown driver',
                          ]);
                          final driverId = _stringOf(
                            data['driverTransporterId'],
                          );
                          final location = _stringOf(data['location']);
                          final submittedAt = _formatTimestamp(
                            data['submittedAt'],
                          );
                          final police = data['policeInvolved'] == true
                              ? 'Yes'
                              : 'No';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 4,
                            ),
                            leading: const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFFFFF1E8),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFF7A18),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              driverName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _kText,
                              ),
                            ),
                            subtitle: Text(
                              '$driverId\n${location.isEmpty ? '-' : location}\nPolice: $police\n$submittedAt',
                              style: const TextStyle(height: 1.3),
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _showReportDetails(data),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kBorder),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _kMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: _kText),
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

  static String _stringOf(dynamic value) => value?.toString().trim() ?? '';

  static String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final v = raw.trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  static Map<String, dynamic> _mapOf(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  static List<String> _listOfStrings(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((e) => _stringOf(e)).where((e) => e.isNotEmpty).toList();
  }

  static String _formatTimestamp(dynamic value) {
    if (value is Timestamp) {
      return DateFormat('dd.MM.yyyy HH:mm').format(value.toDate());
    }
    if (value is DateTime) {
      return DateFormat('dd.MM.yyyy HH:mm').format(value);
    }
    return '-';
  }
}
