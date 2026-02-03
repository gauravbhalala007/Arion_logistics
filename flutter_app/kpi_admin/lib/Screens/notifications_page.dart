// lib/screens/notifications_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  bool _publishing = false;

  // Matches your UI dropdown labels
  final List<_NotifType> _types = const [
    _NotifType('rule', 'New Rule'),
    _NotifType('message', 'New Message'),
    _NotifType('academy', 'DA Academy'),
    _NotifType('rideAlong', 'Ride Along'),
  ];
  late _NotifType _selectedType = _types.first;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _dspDoc() =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> _adminNotifsCol() =>
      _dspDoc().collection('notifications');

  CollectionReference<Map<String, dynamic>> _driversCol() =>
      _dspDoc().collection('drivers');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Publish (UI-first implementation)
  // ------------------------------------------------------------
  Future<void> _publish() async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in.')),
      );
      return;
    }

    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title or message is required.')),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'publishNotificationToAllDrivers',
      );

      final res = await callable.call({
        'dspUid': _uid,
        'type': _selectedType.value,
        'title': title,
        'body': body,
        'requiresConfirmation': _selectedType.value == 'rule',
      });

      final data = (res.data as Map?) ?? {};
      final targetCount = (data['targetCount'] as num?)?.toInt() ?? 0;

      if (!mounted) return;
      _titleCtrl.clear();
      _bodyCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Published to $targetCount drivers.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Publish failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _openNotConfirmedPopup({
    required BuildContext context,
    required String dspUid,
    required String notificationId,
    required int confirmedCount,
    required int targetCount,
  }) async {

    // ✅ Load notification details (title/body) once for the popup header
    final notifDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('notifications')
        .doc(notificationId)
        .get();

    final notifTitle = (notifDoc.data()?['title'] ?? 'Notification').toString();
    final notifBody = (notifDoc.data()?['body'] ?? '').toString();
    
    Future<List<String>> loadMissingDrivers() async {
      final driversSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(dspUid)
          .collection('drivers')
          .get();

      final missing = <String>[];

      for (final d in driversSnap.docs) {
        final driverData = d.data();
        final driverName =
            (driverData['driverName'] ?? driverData['fullName'] ?? 'Driver')
                .toString();

        final notifSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(dspUid)
            .collection('drivers')
            .doc(d.id)
            .collection('notifications')
            .doc(notificationId)
            .get();

        final status = (notifSnap.data()?['status'] ?? 'unread').toString();

        if (status != 'confirmed') {
          missing.add(driverName);
        }
      }

      return missing;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Notification context (TITLE + BODY)
                Text(
                  notifTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (notifBody.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    notifBody,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ✅ Existing section header
                Row(
                  children: [
                    const Text(
                      'NOT CONFIRMED BY:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'missing: ${(targetCount - confirmedCount) < 0 ? 0 : (targetCount - confirmedCount)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE9741A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // ✅ Your list stays unchanged
                SizedBox(
                  height: 420,

                  child: FutureBuilder<List<String>>(
                    future: loadMissingDrivers(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                      }

                      final items = snap.data ?? [];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'All drivers have confirmed.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              items[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UI (Responsive)
  // - No horizontal scroll
  // - Shrinks composer height on smaller screens/heights
  // - Moves History below Composer on narrow widths
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // Breakpoints (tune if needed)
            final bool stack = w < 800;

            // Space taken by title row + spacing
            const headerBlock = 22.0 + 16.0;

            // Remaining height for main content area
            final contentH = (h - headerBlock).clamp(520.0, 5000.0);

            // Composer height shrinks when screen height shrinks
            // Wide: it can use full height (since right card sits next to it)
            // Stack: we split height between composer and history
            final composerH = stack
                ? (contentH * 0.56).clamp(360.0, 520.0)
                : contentH;

            final historyH = stack
                ? (contentH * 0.44).clamp(320.0, 560.0)
                : contentH;

            final left = _ComposerCard(
              selectedType: _selectedType,
              types: _types,
              titleCtrl: _titleCtrl,
              bodyCtrl: _bodyCtrl,
              publishing: _publishing,
              onTypeChanged: (t) => setState(() => _selectedType = t),
              onPublish: _publishing ? null : _publish,
            );

            final right = _HistoryCard(
              uid: _uid,
              onOpenMissing: (notifId, confirmedCount, targetCount) {
                final dspUid = _uid;
                if (dspUid == null) return;
                _openNotConfirmedPopup(
                  context: context,
                  dspUid: dspUid,
                  notificationId: notifId,
                  confirmedCount: confirmedCount,
                  targetCount: targetCount,
                );
              },
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_none, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Notifications',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: stack
                      ? ListView(
                          // IMPORTANT: bounded heights so Expanded() inside cards works
                          children: [
                            SizedBox(height: composerH, child: left),
                            const SizedBox(height: 16),
                            SizedBox(height: historyH, child: right),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 6, child: left),
                            const SizedBox(width: 18),
                            Expanded(flex: 4, child: right),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      );
  }
}

// -----------------------------------------------------------------------------
// Left: Composer Card
// -----------------------------------------------------------------------------
class _ComposerCard extends StatelessWidget {
  final _NotifType selectedType;
  final List<_NotifType> types;

  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;

  final bool publishing;
  final ValueChanged<_NotifType> onTypeChanged;
  final VoidCallback? onPublish;

  const _ComposerCard({
    required this.selectedType,
    required this.types,
    required this.titleCtrl,
    required this.bodyCtrl,
    required this.publishing,
    required this.onTypeChanged,
    required this.onPublish,
  });

  InputDecoration _pillField({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF6F7F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF1D7F5A), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: "NEW CONTENT | Notifications" + dropdown
          Row(
            children: [
              const Icon(Icons.notifications_none, color: Color(0xFF1D7F5A)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'NEW CONTENT | Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_NotifType>(
                    value: selectedType,
                    items: types
                        .map(
                          (t) => DropdownMenuItem<_NotifType>(
                            value: t,
                            child: Text(t.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onTypeChanged(v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          TextField(
            controller: titleCtrl,
            decoration: _pillField(hint: 'TITLE'),
          ),
          const SizedBox(height: 12),

          // Rule / Message big box
          Expanded(
            child: TextField(
              controller: bodyCtrl,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: _pillField(hint: 'RULE / MESSAGE'),
            ),
          ),
          const SizedBox(height: 14),

          // Publish button
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 44,
              width: 220,
              child: ElevatedButton(
                onPressed: onPublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D7F5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: publishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'publish',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Right: History Card
// -----------------------------------------------------------------------------
class _HistoryCard extends StatelessWidget {
  final String? uid;
  final void Function(String notificationId, int confirmedCount, int targetCount)
      onOpenMissing;

  const _HistoryCard({
    required this.uid,
    required this.onOpenMissing,
  });

  @override
  Widget build(BuildContext context) {
    final dspUid = uid;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.history, color: Color(0xFF1D7F5A)),
              SizedBox(width: 10),
              Text(
                'History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: dspUid == null
                ? const Center(child: Text('Not logged in'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(dspUid)
                        .collection('notifications')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text('Error: ${snap.error}'),
                        );
                      }

                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No notifications yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final d = docs[i];
                          final data = d.data();
                          final title = (data['title'] ?? '').toString();
                          final body = (data['body'] ?? '').toString();
                          final type = (data['type'] ?? 'rule').toString();
                          final confirmedCount =
                              (data['confirmedCount'] as num?)?.toInt() ?? 0;
                          final targetCount =
                              (data['targetCount'] as num?)?.toInt() ?? 0;

                          final ts = data['createdAt'];
                          final dt = ts is Timestamp ? ts.toDate() : null;

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              onOpenMissing(
                                d.id,
                                confirmedCount,
                                targetCount,
                              );
                            },
                            child: _HistoryTile(
                              dspUid: dspUid,
                              notificationId: d.id,
                              title: title,
                              body: body,
                              type: type,
                              dateTime: dt,
                              confirmedCount: confirmedCount,
                              targetCount: targetCount,
                            ),
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
}

class _HistoryTile extends StatelessWidget {
  final String dspUid;
  final String notificationId;

  final String title;
  final String body;
  final String type;
  final DateTime? dateTime;
  final int confirmedCount;
  final int targetCount;

  const _HistoryTile({
    required this.dspUid,
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.dateTime,
    required this.confirmedCount,
    required this.targetCount,
  });

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd.$mm.$yy | $hh:$min Uhr';
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'message':
        return 'NEW MESSAGE';
      case 'academy':
        return 'DA ACADEMY';
      case 'rideAlong':
        return 'RIDE ALONG';
      case 'rule':
      default:
        return 'NEW RULE';
    }
  }

  IconData _typeIcon(String t) {
  switch (t) {
    case 'message':
      return Icons.chat_bubble_outline;
    case 'academy':
      return Icons.school_outlined;
    case 'rideAlong':
      return Icons.directions_car_filled_outlined;
    case 'rule':
    default:
      return Icons.gavel;
  }
}


  Future<void> _deleteEverywhere(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete notification?'),
          content: const Text(
            'This will delete this notification for you and for all drivers.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'deleteNotificationEverywhere',
      );
      await callable.call({
        'dspUid': dspUid,
        'notificationId': notificationId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        (targetCount <= 0) ? '0 / 0' : '$confirmedCount / $targetCount';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(_typeIcon(type), color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),

          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_typeLabel(type)} | ${title.isEmpty ? 'TITLE' : title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                if (_fmtDate(dateTime).isNotEmpty)
                  Text(
                    _fmtDate(dateTime),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  body.isEmpty ? '—' : body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Right side: confirmed column + 3-dot menu
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'confirmed by',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ratio,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D7F5A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    color: const Color(0xFFF3F6F7),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: PopupMenuButton<String>(
                      tooltip: 'Options',
                      splashRadius: 18,
                      offset: const Offset(0, 10),
                      onSelected: (v) {
                        if (v == 'delete') _deleteEverywhere(context);
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem<String>(
                          value: 'delete',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFE11D48),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Color(0xFFE11D48),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small type helper
// -----------------------------------------------------------------------------
class _NotifType {
  final String value; // stored in Firestore
  final String label; // shown in dropdown
  const _NotifType(this.value, this.label);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is _NotifType && other.value == value);

  @override
  int get hashCode => value.hashCode;
}
