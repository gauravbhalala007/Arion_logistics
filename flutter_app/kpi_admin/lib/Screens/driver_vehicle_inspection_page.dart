// lib/Screens/driver_vehicle_inspection_page.dart
//
// Pre-shift vehicle inspection — two yes/no questions the driver answers
// before starting their shift. When a "No" is selected we tell the
// driver to record a short walk-around video and send it to their
// dispatcher (e.g. via WhatsApp). The answers are persisted on the
// driver doc so the dispatcher team can see who completed it today.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Public entry point — call from anywhere on the driver side.
Future<void> openDriverVehicleInspectionSheet(
  BuildContext context, {
  required String dspUid,
  required String driverDocId,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _VehicleInspectionSheet(
      dspUid: dspUid,
      driverDocId: driverDocId,
    ),
  );
}

class _VehicleInspectionSheet extends StatefulWidget {
  final String dspUid;
  final String driverDocId;

  const _VehicleInspectionSheet({
    required this.dspUid,
    required this.driverDocId,
  });

  @override
  State<_VehicleInspectionSheet> createState() =>
      _VehicleInspectionSheetState();
}

class _VehicleInspectionSheetState extends State<_VehicleInspectionSheet> {
  bool? _sameVehicle; // Q1
  bool? _wasOffYesterday; // Q2
  bool _saving = false;

  String get _dateKey =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool get _needsVideo {
    // Driver needs to send a video if vehicle changed OR they were off
    // yesterday (so the dispatcher can verify the vehicle condition
    // before the shift starts).
    return _sameVehicle == false || _wasOffYesterday == true;
  }

  Future<void> _submit() async {
    if (_sameVehicle == null || _wasOffYesterday == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid)
          .collection('drivers')
          .doc(widget.driverDocId)
          .collection('vehicleInspections')
          .doc(_dateKey)
          .set({
        'date': _dateKey,
        'sameVehicleAsYesterday': _sameVehicle,
        'wasOffYesterday': _wasOffYesterday,
        'needsVideoSubmission': _needsVideo,
        'driverUid': FirebaseAuth.instance.currentUser?.uid,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _needsVideo
              ? const Color(0xFFB45309)
              : const Color(0xFF067647),
          content: Text(
            _needsVideo
                ? 'Bitte vergiss nicht das Video an deinen Dispatcher zu schicken!'
                : 'Fahrzeug-Check abgeschlossen. Gute Schicht!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speichern fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _sameVehicle != null && _wasOffYesterday != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.directions_car_rounded,
                      color: Color(0xFF1D7F5A)),
                  SizedBox(width: 8),
                  Text(
                    'Fahrzeug-Check',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Bitte vor Schichtstart kurz beantworten — '
                'so weiß dein Dispatcher Bescheid.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              _Question(
                number: 1,
                question: 'Hast du heute das gleiche Fahrzeug wie gestern?',
                value: _sameVehicle,
                onChanged: (v) => setState(() => _sameVehicle = v),
              ),
              const SizedBox(height: 14),
              _Question(
                number: 2,
                question: 'Hattest du gestern frei?',
                value: _wasOffYesterday,
                onChanged: (v) => setState(() => _wasOffYesterday = v),
              ),
              if (_needsVideo) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.videocam_outlined,
                          size: 20, color: Color(0xFF92400E)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bitte mach jetzt ein kurzes Video rund um das Fahrzeug '
                          '(Außen + Innen, sichtbare Schäden klar zeigen) und '
                          'schick es deinem Dispatcher per WhatsApp oder einem '
                          'anderen Messenger — bevor du losfährst.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7A3E08),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: canSubmit && !_saving ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D7F5A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(_saving ? 'Speichere…' : 'Bestätigen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  final int number;
  final String question;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _Question({
    required this.number,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  Widget _btn({
    required bool isYes,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = isYes
        ? const Color(0xFF067647)
        : const Color(0xFFB42318);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : const Color(0xFFE5E7EB),
              width: selected ? 1.8 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isYes ? Icons.check_circle : Icons.cancel,
                color: selected ? color : const Color(0xFF9CA3AF),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isYes ? 'Ja' : 'Nein',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selected ? color : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frage $number',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6B7280),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _btn(
              isYes: true,
              selected: value == true,
              onTap: () => onChanged(true),
            ),
            const SizedBox(width: 10),
            _btn(
              isYes: false,
              selected: value == false,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }
}
