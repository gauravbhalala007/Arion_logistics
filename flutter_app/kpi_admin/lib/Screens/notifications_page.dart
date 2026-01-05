// lib/screens/notifications_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_side_menu.dart';

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
  //
  // This publishes by:
  // 1) Creating ONE admin notification doc: users/{dspUid}/notifications/{notifId}
  // 2) Fan-out to each driver:
  //    users/{dspUid}/drivers/{TID}/notifications/{notifId}
  //
  // NOTE: This works as an MVP.
  // For scale/production, we should move fan-out to a Cloud Function.
  //
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


  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppShell(
      menuWidth: 280,
      sideMenu: const AppSideMenu(
        width: 280,
        active: AppNav.notifications,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title row (optional)
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
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final isNarrow = constraints.maxWidth < 1100;

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
                  );

                  if (isNarrow) {
                    // Stack on small screens
                    return ListView(
                      children: [
                        left,
                        const SizedBox(height: 16),
                        SizedBox(height: 520, child: right),
                      ],
                    );
                  }

                  // Two columns (matches your screenshot)
                  return Row(
                    children: [
                      Expanded(flex: 6, child: left),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: right),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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

          // Publish button (centered like screenshot)
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
  const _HistoryCard({required this.uid});

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
                          final confirmedCount =
                              (data['confirmedCount'] as num?)?.toInt() ?? 0;
                          final targetCount =
                              (data['targetCount'] as num?)?.toInt() ?? 0;

                          final ts = data['createdAt'];
                          final dt = ts is Timestamp ? ts.toDate() : null;

                          return _HistoryTile(
                            title: title,
                            body: body,
                            dateTime: dt,
                            confirmedCount: confirmedCount,
                            targetCount: targetCount,
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
  final String title;
  final String body;
  final DateTime? dateTime;
  final int confirmedCount;
  final int targetCount;

  const _HistoryTile({
    required this.title,
    required this.body,
    required this.dateTime,
    required this.confirmedCount,
    required this.targetCount,
  });

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    // Simple formatting: 30.12.2025 | 11:45 Uhr
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd.$mm.$yy | $hh:$min Uhr';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (targetCount <= 0) ? '0 / 0' : '$confirmedCount / $targetCount';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // left icon placeholder (gavel-like in mock)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.gavel, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '(No title)' : title,
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

          const SizedBox(width: 10),

          // right confirmed badge
          Column(
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
