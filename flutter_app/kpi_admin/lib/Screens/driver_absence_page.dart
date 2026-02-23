import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DriverAbsencePage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverAbsencePage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverAbsencePage> createState() => _DriverAbsencePageState();
}

class _DriverAbsencePageState extends State<DriverAbsencePage> {
  final _reasonCtrl = TextEditingController();
  String _type = 'vacation';
  DateTime? _from;
  DateTime? _to;
  bool _saving = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> _driverRequestsCol(
    String driverId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(driverId)
        .collection('absence_requests');
  }

  CollectionReference<Map<String, dynamic>> get _rootRequestsCol {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('absence_requests');
  }

  Future<void> _pickDate({required bool from}) async {
    final initial = from
        ? (_from ?? DateTime.now())
        : (_to ?? _from ?? DateTime.now());
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDate: initial,
    );
    if (selected == null || !mounted) return;

    setState(() {
      if (from) {
        _from = selected;
        if (_to != null && _to!.isBefore(selected)) {
          _to = selected;
        }
      } else {
        _to = selected;
      }
    });
  }

  Future<void> _submit() async {
    final auth = FirebaseAuth.instance.currentUser;
    final driverId = widget.driverTransporterId.toUpperCase().trim();

    if (auth == null) {
      _showSnack('You must be logged in as driver.', error: true);
      return;
    }
    if (widget.dspUid.trim().isEmpty || driverId.isEmpty) {
      _showSnack('Missing DSP or driver scope.', error: true);
      return;
    }
    if (_from == null || _to == null) {
      _showSnack('Please select start and end date.', error: true);
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      _showSnack('Please enter a reason.', error: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final db = FirebaseFirestore.instance;
      final driverRef = db
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .doc(driverId);
      final driverSnap = await driverRef.get();
      final driverData = driverSnap.data() ?? const <String, dynamic>{};
      final driverName = _firstNonEmpty([
        _stringOf(driverData['name']),
        _stringOf(driverData['fullName']),
        _stringOf(driverData['driverName']),
      ]);

      final rootRef = _rootRequestsCol.doc();
      final requestId = rootRef.id;
      final payload = <String, dynamic>{
        'requestId': requestId,
        'dspUid': widget.dspUid,
        'driverUid': auth.uid,
        'driverTransporterId': driverId,
        'driverName': driverName,
        'type': _type,
        'fromDate': Timestamp.fromDate(_from!),
        'toDate': Timestamp.fromDate(_to!),
        'reason': _reasonCtrl.text.trim(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final driverDocRef = _driverRequestsCol(driverId).doc(requestId);
      final batch = db.batch();
      batch.set(rootRef, payload, SetOptions(merge: true));
      batch.set(driverDocRef, payload, SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return;
      setState(() {
        _type = 'vacation';
        _from = null;
        _to = null;
        _reasonCtrl.clear();
      });
      _showSnack('Absence request submitted.');
    } catch (e) {
      _showSnack('Failed to submit request: $e', error: true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverId = widget.driverTransporterId.toUpperCase().trim();
    if (widget.dspUid.trim().isEmpty || driverId.isEmpty) {
      return const Center(child: Text('Missing DSP or driver scope.'));
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
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
                  Icons.event_busy_outlined,
                  color: Color(0xFFFF7A18),
                  size: 21,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Absence',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 14),
                children: [
                  _requestFormCard(),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text(
                      'Your requests',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _requestsList(driverId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3E7)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Apply for vacation or sick leave',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'vacation', child: Text('Vacation')),
              DropdownMenuItem(value: 'sick_leave', child: Text('Sick leave')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _type = value);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(from: true),
                  icon: const Icon(Icons.event_available_outlined),
                  label: Text('From: ${_date(_from)}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(from: false),
                  icon: const Icon(Icons.event_outlined),
                  label: Text('To: ${_date(_to)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Provide a short reason...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(_saving ? 'Submitting...' : 'Submit request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A18),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestsList(String driverId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _driverRequestsCol(
        driverId,
      ).orderBy('submittedAt', descending: true).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Text('Failed to load absence requests: ${snap.error}');
        }

        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDE3E7)),
            ),
            child: const Text(
              'No requests submitted yet.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return Column(
          children: docs.map((d) {
            final data = d.data();
            final status = _stringOf(data['status']).isEmpty
                ? 'pending'
                : _stringOf(data['status']);
            final from = _toDate(data['fromDate']);
            final to = _toDate(data['toDate']);
            final reason = _stringOf(data['reason']);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDE3E7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _typeLabel(_stringOf(data['type'])),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      _statusChip(status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_date(from)} - ${_date(to)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    Color fg;
    Color bg;
    final s = status.toLowerCase().trim();
    if (s == 'approved') {
      fg = const Color(0xFF1D7F5A);
      bg = const Color(0xFFE4F5EC);
    } else if (s == 'rejected') {
      fg = const Color(0xFFB91C1C);
      bg = const Color(0xFFFEE2E2);
    } else {
      fg = const Color(0xFF8A6200);
      bg = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800),
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

  static String _date(DateTime? value) {
    if (value == null) return '--.--.----';
    return DateFormat('dd.MM.yyyy').format(value);
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }

  static String _typeLabel(String type) {
    switch (type.toLowerCase().trim()) {
      case 'sick_leave':
        return 'Sick leave';
      case 'vacation':
      default:
        return 'Vacation';
    }
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
