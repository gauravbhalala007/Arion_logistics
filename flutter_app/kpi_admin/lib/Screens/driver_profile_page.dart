import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../widgets/notification_pin_dialogs.dart';

const _kBg = Color(0xFFF3F6F7);
const _kGreen = Color(0xFF1D7F5A);
const _kText = Color(0xFF22252F);
const _kMuted = Color(0xFF6B7280);

class DriverProfilePage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  const DriverProfilePage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  bool _busy = false;
  String? _pin;

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final p = await NotificationPinService.getPin(
        dspUid: widget.dspUid,
        transporterId: widget.driverTransporterId.toUpperCase(),
      );
      if (!mounted) return;
      setState(() => _pin = p);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _resetPin() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => VerifyNotificationPinDialog(
        dspUid: widget.dspUid,
        transporterId: widget.driverTransporterId.toUpperCase(),
      ),
    );

    if (ok != true) return;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SetNotificationPinDialog(
        dspUid: widget.dspUid,
        transporterId: widget.driverTransporterId.toUpperCase(),
        force: true,
      ),
    );

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Container(
      color: _kBg,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _busy ? null : _load,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE1E4EA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification PIN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.t('pin_change_with_old'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kMuted.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.t('pin_forgot_contact_admin'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kMuted.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pin == null
                            ? () async {
                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => SetNotificationPinDialog(
                                    dspUid: widget.dspUid,
                                    transporterId: widget.driverTransporterId.toUpperCase(),
                                    force: true,
                                  ),
                                );
                                await _load();
                              }
                            : _resetPin,
                        icon: const Icon(Icons.lock_reset),
                        label: Text(_pin == null ? 'Set PIN' : 'Change PIN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
