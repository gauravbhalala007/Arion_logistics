// lib/screens/driver_notifications_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/driver_notification.dart';
import '../widgets/driver_notification_card.dart';

class DriverNotificationsView extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  final ValueChanged<DriverNotification> onOpen;

  const DriverNotificationsView({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onOpen,
  });

  @override
  State<DriverNotificationsView> createState() =>
      _DriverNotificationsViewState();
}

class _DriverNotificationsViewState extends State<DriverNotificationsView> {
  DriverNotificationType? _filter;

  static const Color _kPrimaryGreen = Color(0xFF1D7F5A);

  CollectionReference<Map<String, dynamic>> _col() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(widget.driverTransporterId.toUpperCase())
        .collection('notifications');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final filters = <Map<String, Object?>>[
      {'key': null, 'label': t.t('driver_notifications_filter_all')},
      {
        'key': DriverNotificationType.rule,
        'label': t.t('driver_notifications_filter_rule'),
      },
      {
        'key': DriverNotificationType.academy,
        'label': t.t('driver_notifications_filter_academy'),
      },
      {
        'key': DriverNotificationType.message,
        'label': t.t('driver_notifications_filter_message'),
      },
      {
        'key': DriverNotificationType.rideAlong,
        'label': t.t('driver_notifications_filter_ride_along'),
      },
    ];

    String _labelForKey(DriverNotificationType? key) {
      return filters.firstWhere((f) => f['key'] == key)['label'] as String;
    }

    Future<void> _showFilterPicker(BuildContext context) async {
      final selected = await showDialog<DriverNotificationType?>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(ctx).pop(),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 80, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final f = filters[i];
                        final key = f['key'] as DriverNotificationType?;
                        final label = f['label'] as String;
                        final isSelected = key == _filter;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(key),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kPrimaryGreen.withOpacity(0.08)
                                    : const Color(0xFFF7F8F8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? _kPrimaryGreen : Colors.black12,
                                  width: isSelected ? 1.2 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? _kPrimaryGreen : Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        size: 18, color: _kPrimaryGreen)
                                  else
                                    const Icon(Icons.chevron_right,
                                        size: 18, color: Color(0xFF9CA3AF)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (selected != _filter) {
        setState(() => _filter = selected);
      }
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _col().orderBy('createdAt', descending: true).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text(
              t.tf('driver_notifications_error_template', {
                'error': '${snap.error}',
              }),
            ),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              t.t('driver_notifications_empty'),
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        final items = docs.map((d) => DriverNotification.fromDoc(d)).toList();
        final filteredItems = _filter == null
            ? items
            : items.where((n) => n.type == _filter).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showFilterPicker(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _kPrimaryGreen, width: 1.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _labelForKey(_filter).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down,
                                size: 16, color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        t.t('driver_notifications_filter_empty'),
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final n = filteredItems[i];
                        return DriverNotificationCard(
                          notification: n,
                          onTap: () => widget.onOpen(n),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
