// lib/screens/driver_notification_detail_view.dart

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../models/driver_notification.dart';

class DriverNotificationDetailView extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  final DriverNotification notification;
  final VoidCallback onBack;

  const DriverNotificationDetailView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.notification,
    required this.onBack,
  });

  @override
  State<DriverNotificationDetailView> createState() =>
      _DriverNotificationDetailViewState();
}

class _DriverNotificationDetailViewState
    extends State<DriverNotificationDetailView> {
  bool _busyRead = false;
  bool _busyConfirm = false;

  Future<void> _markRead() async {
    if (_busyRead) return;
    if (!mounted) return;

    setState(() => _busyRead = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'markDriverNotificationRead',
      );
      await callable.call({
        'dspUid': widget.dspUid,
        'transporterId': widget.driverTransporterId,
        'notificationId': widget.notification.id,
      });
    } catch (e) {
      // Don’t block UX; just show snack
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark read: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyRead = false);
    }
  }

  Future<void> _confirm() async {
    if (_busyConfirm) return;
    if (!mounted) return;

    setState(() => _busyConfirm = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'confirmDriverNotification',
      );
      await callable.call({
        'dspUid': widget.dspUid,
        'transporterId': widget.driverTransporterId,
        'notificationId': widget.notification.id,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busyConfirm = false);
    }
  }

  @override
  void initState() {
    super.initState();

    // If unread, mark as read immediately when opening detail
    if (widget.notification.isUnread) {
      _markRead();
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.chevron_left),
            ),
            const SizedBox(width: 4),
            const Text(
              'Detail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (_busyRead)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E4EA)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _StatusPill(notification: n),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF22252F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    n.body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF4A4F59),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (n.requiresConfirmation)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    n.confirmed ? Colors.grey.shade400 : const Color(0xFF1D7F5A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: (n.confirmed || _busyConfirm) ? null : _confirm,
              child: _busyConfirm
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      n.confirmed ? 'confirmed' : 'Reading confirmation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          )
        else
          const SizedBox(height: 8),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DriverNotification notification;
  const _StatusPill({required this.notification});

  @override
  Widget build(BuildContext context) {
    final bool confirmed =
        notification.confirmed || !notification.requiresConfirmation;

    final Color border =
        confirmed ? const Color(0xFF1D7F5A) : const Color(0xFFE9741A);
    final Color text =
        confirmed ? const Color(0xFF1D7F5A) : const Color(0xFFE9741A);

    final String label = confirmed ? 'confirmed' : 'confirmation required';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
