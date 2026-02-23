import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const String _settingsCollection = 'settings';
const String _dispatcherPillDoc = 'dispatcher_pill';

class AdminDispatcherPillPage extends StatefulWidget {
  const AdminDispatcherPillPage({super.key});

  @override
  State<AdminDispatcherPillPage> createState() =>
      _AdminDispatcherPillPageState();
}

class _AdminDispatcherPillPageState extends State<AdminDispatcherPillPage> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String? _resolvedDspUid;
  bool _loading = true;
  bool _saving = false;
  final List<_DispatcherDraft> _rows = [];

  @override
  void initState() {
    super.initState();
    _resolveScopeAndLoad();
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  String? get _scopeUid {
    final uid = _uid;
    if (uid == null) return null;
    final scoped = (_resolvedDspUid ?? '').trim();
    return scoped.isEmpty ? uid : scoped;
  }

  DocumentReference<Map<String, dynamic>>? get _docRef {
    final uid = _scopeUid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_settingsCollection)
        .doc(_dispatcherPillDoc);
  }

  Future<void> _resolveScopeAndLoad() async {
    final uid = _uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      final dspUid = (data['dspUid'] ?? '').toString().trim();
      _resolvedDspUid = dspUid.isEmpty ? uid : dspUid;
    } catch (_) {
      _resolvedDspUid = uid;
    }

    await _loadRows();
  }

  Future<void> _loadRows() async {
    final ref = _docRef;
    if (ref == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    try {
      final snap = await ref.get();
      final data = snap.data() ?? const <String, dynamic>{};
      final raw = data['dispatchers'];
      final rows = <_DispatcherDraft>[];
      if (raw is List) {
        for (final row in raw) {
          if (row is! Map) continue;
          final map = row.cast<String, dynamic>();
          rows.add(
            _DispatcherDraft(
              name: _stringOf(map['name']),
              startTime: _firstNonEmpty([
                _stringOf(map['startTime']),
                _stringOf(map['shiftStart']),
              ]),
              endTime: _firstNonEmpty([
                _stringOf(map['endTime']),
                _stringOf(map['shiftEnd']),
              ]),
              phone: _stringOf(map['phone']),
              whatsapp: _firstNonEmpty([
                _stringOf(map['whatsapp']),
                _stringOf(map['whatsApp']),
                _stringOf(map['wa']),
              ]),
              whatsappLink: _firstNonEmpty([
                _stringOf(map['whatsappLink']),
                _stringOf(map['whatsappUrl']),
                _stringOf(map['waLink']),
              ]),
            ),
          );
        }
      }

      if (rows.isEmpty) {
        rows.addAll([
          _DispatcherDraft(
            name: 'ISRAFIL',
            startTime: '06:00',
            endTime: '13:00',
          ),
          _DispatcherDraft(name: 'HALIM', startTime: '13:00', endTime: '20:00'),
          _DispatcherDraft(name: 'ANES', startTime: '20:00', endTime: '03:00'),
        ]);
      }

      for (final row in _rows) {
        row.dispose();
      }
      _rows
        ..clear()
        ..addAll(rows);
    } catch (e) {
      _showSnack('Failed to load dispatcher settings: $e', error: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    final ref = _docRef;
    if (ref == null) {
      _showSnack('You must be logged in.', error: true);
      return;
    }

    final dispatchers = <Map<String, dynamic>>[];
    for (final row in _rows) {
      final name = row.name.text.trim();
      final startTime = row.startTime.text.trim();
      final endTime = row.endTime.text.trim();
      final phone = row.phone.text.trim();
      final whatsapp = row.whatsapp.text.trim();
      final whatsappLink = row.whatsappLink.text.trim();
      if (name.isEmpty) continue;
      dispatchers.add({
        'name': name,
        'startTime': startTime,
        'endTime': endTime,
        'shiftStart': startTime,
        'shiftEnd': endTime,
        'phone': phone,
        'whatsapp': whatsapp,
        'whatsappLink': whatsappLink,
        'isActive': true,
      });
    }

    if (dispatchers.isEmpty) {
      _showSnack('Add at least one dispatcher with a name.', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.set({
        'dispatchers': dispatchers,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _showSnack('Dispatcher pill settings saved.');
    } catch (e) {
      _showSnack('Failed to save settings: $e', error: true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _addRow() {
    setState(() {
      _rows.add(_DispatcherDraft());
    });
  }

  void _removeRow(int index) {
    if (index < 0 || index >= _rows.length) return;
    setState(() {
      final row = _rows.removeAt(index);
      row.dispose();
    });
  }

  void _showSnack(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scopeUid = _scopeUid ?? '';
    if (_uid == null) {
      return const Center(child: Text('You must be logged in as admin.'));
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF1D7F5A),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Dispatcher Pill',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'DSP scope: $scopeUid',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : _loadRows,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reload'),
              ),
              OutlinedButton.icon(
                onPressed: _saving ? null : _addRow,
                icon: const Icon(Icons.add),
                label: const Text('Add dispatcher'),
              ),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
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
                label: Text(_saving ? 'Saving...' : 'Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D7F5A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Configure tabs and contact details shown on the driver home dispatcher card.',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _rows.isEmpty
                ? const Center(child: Text('No dispatchers configured.'))
                : ListView.separated(
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final row = _rows[index];
                      return _DispatcherEditorCard(
                        index: index,
                        row: row,
                        onDelete: _rows.length == 1
                            ? null
                            : () => _removeRow(index),
                      );
                    },
                  ),
          ),
        ],
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
}

class _DispatcherDraft {
  final TextEditingController name;
  final TextEditingController startTime;
  final TextEditingController endTime;
  final TextEditingController phone;
  final TextEditingController whatsapp;
  final TextEditingController whatsappLink;

  _DispatcherDraft({
    String name = '',
    String startTime = '',
    String endTime = '',
    String phone = '',
    String whatsapp = '',
    String whatsappLink = '',
  }) : name = TextEditingController(text: name),
       startTime = TextEditingController(text: startTime),
       endTime = TextEditingController(text: endTime),
       phone = TextEditingController(text: phone),
       whatsapp = TextEditingController(text: whatsapp),
       whatsappLink = TextEditingController(text: whatsappLink);

  void dispose() {
    name.dispose();
    startTime.dispose();
    endTime.dispose();
    phone.dispose();
    whatsapp.dispose();
    whatsappLink.dispose();
  }
}

class _DispatcherEditorCard extends StatelessWidget {
  final int index;
  final _DispatcherDraft row;
  final VoidCallback? onDelete;

  const _DispatcherEditorCard({
    required this.index,
    required this.row,
    this.onDelete,
  });

  InputDecoration _field(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1D7F5A), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dispatcher ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Remove',
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(controller: row.name, decoration: _field('Name')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.startTime,
                  decoration: _field('Start time (e.g. 06:00)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.endTime,
                  decoration: _field('End time (e.g. 13:00)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.phone,
                  keyboardType: TextInputType.phone,
                  decoration: _field('Phone number'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.whatsapp,
                  keyboardType: TextInputType.phone,
                  decoration: _field('WhatsApp number'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: row.whatsappLink,
            keyboardType: TextInputType.url,
            decoration: _field('WhatsApp link (Business URL)'),
          ),
        ],
      ),
    );
  }
}
