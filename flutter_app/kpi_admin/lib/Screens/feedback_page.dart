import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/web_preview.dart'
    if (dart.library.html) '../widgets/web_preview_web.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _submitting = false;
  Uint8List? _attachmentBytes;
  String? _attachmentName;

  static const _kPageBg = Color(0xFFF3F6F7);
  static const _kCardBorder = Color(0xFFE1E4EA);
  static const _kTitle = Color(0xFF1F2937);
  static const _kSub = Color(0xFF6B7280);
  static const _kPrimary = Color(0xFF1D7F5A);

  String _priority = 'medium'; // low | medium | high

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String? get _email => FirebaseAuth.instance.currentUser?.email;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool _isNarrow(BuildContext c) => MediaQuery.of(c).size.width < 1100;

  String _platformLabel() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }

  bool get _isGerman {
    try {
      return Localizations.localeOf(context).languageCode.toLowerCase() == 'de';
    } catch (_) {
      return false;
    }
  }

  String _t(String en, String de) => _isGerman ? de : en;

  InputDecoration _inputDeco({
    required String label,
    String? hint,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _kPrimary, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  String _fmtTimestamp(BuildContext context, dynamic raw) {
    try {
      if (raw is! Timestamp) return '—';
      final dt = raw.toDate();
      final loc = MaterialLocalizations.of(context);
      return '${loc.formatShortDate(dt)} ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(dt))}';
    } catch (_) {
      return '—';
    }
  }

  Future<void> _pickImage() async {
    if (_submitting) return;
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;
      final f = picked.files.first;
      final bytes = f.bytes;
      if (bytes == null) return;
      setState(() {
        _attachmentBytes = bytes;
        _attachmentName = f.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
    }
  }

  void _clearImage() {
    setState(() {
      _attachmentBytes = null;
      _attachmentName = null;
    });
  }

  Future<void> _openImagePreview(String url) async {
    if (url.trim().isEmpty) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.72,
                    maxWidth: 820,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: buildWebImagePreview(url),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit({required String role}) async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();

    final uid = _uid;
    if (uid == null) return;

    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Please describe the problem or suggestion.',
              'Bitte beschreibe das Problem oder den Vorschlag.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('feedback').doc();
      final feedbackId = docRef.id;

      String attachmentUrl = '';
      String attachmentPath = '';
      String attachmentName = _attachmentName ?? '';
      int attachmentSize = 0;

      final bytes = _attachmentBytes;
      if (bytes != null) {
        attachmentSize = bytes.lengthInBytes;
        final safeName = attachmentName.isNotEmpty
            ? attachmentName
            : 'image.png';
        attachmentPath = 'feedback_attachments/$uid/$feedbackId/$safeName';
        final uploadRef = fb.FirebaseStorage.instance.ref().child(
          attachmentPath,
        );
        await uploadRef.putData(bytes);
        attachmentUrl = await uploadRef.getDownloadURL();
      }

      await docRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'createdByUid': uid,
        'createdByEmail': _email ?? '',
        'createdByRole': role,
        'title': title,
        'description': desc,
        'priority': _priority,
        'attachmentUrl': attachmentUrl,
        'attachmentPath': attachmentPath,
        'attachmentName': attachmentName,
        'attachmentSize': attachmentSize,
        'status': 'open',
        'app': 'kpi_admin',
        'platform': _platformLabel(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _titleCtrl.clear();
      _descCtrl.clear();
      _clearImage();
      setState(() => _priority = 'medium');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Thanks! Your feedback was sent.',
              'Danke! Dein Feedback wurde gesendet.',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send feedback: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _markResolved({
    required String feedbackId,
    required bool resolved,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedbackId)
          .set({
            'status': resolved ? 'resolved' : 'open',
            'resolvedAt': resolved ? FieldValue.serverTimestamp() : null,
            'resolvedByUid': resolved ? uid : null,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Center(child: Text('You must be logged in.'));
    }

    final isNarrow = _isNarrow(context);
    final horizontalPadding = isNarrow ? 14.0 : 28.0;

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final me = snap.data?.data() ?? <String, dynamic>{};
        final role = (me['role'] ?? '').toString().trim().toLowerCase();
        final isDeveloper = role == 'developer';
        final isStaff = isDeveloper;

        final Query<Map<String, dynamic>> query = isStaff
            ? FirebaseFirestore.instance
                  .collection('feedback')
                  .orderBy('createdAt', descending: true)
                  .limit(200)
            : FirebaseFirestore.instance
                  .collection('feedback')
                  .where('createdByUid', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .limit(100);

        return Container(
          color: _kPageBg,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.feedback_outlined,
                          color: _kPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _t('Feedback', 'Feedback'),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _kTitle,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ---- Form card (only for non-developer roles) ----
                    if (!isDeveloper)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isNarrow ? 16 : 22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _kCardBorder),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140B1220),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleCtrl,
                              enabled: !_submitting,
                              decoration: _inputDeco(
                                label: _t('Title', 'Titel'),
                                hint: _t(
                                  'Short description...',
                                  'Kurze Beschreibung des Anliegens...',
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _descCtrl,
                              enabled: !_submitting,
                              minLines: 6,
                              maxLines: 10,
                              decoration: _inputDeco(
                                label: _t('Description', 'Beschreibung'),
                                hint: _t(
                                  'Describe the problem or suggestion in detail...',
                                  'Beschreibe das Problem oder den Vorschlag im Detail...',
                                ),
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _t('Image (optional)', 'Bild (optional)'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _kTitle,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _submitting ? null : _pickImage,
                              borderRadius: BorderRadius.circular(18),
                              child: _DashedRRectBorder(
                                radius: 18,
                                dash: 7,
                                gap: 5,
                                color: const Color(0xFFD1D5DB),
                                strokeWidth: 1.3,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.upload_rounded,
                                        color: Color(0xFF6B7280),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _attachmentName?.trim().isNotEmpty ==
                                                  true
                                              ? _attachmentName!
                                              : _t(
                                                  'Upload image',
                                                  'Bild hochladen',
                                                ),
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (_attachmentBytes != null &&
                                          !_submitting)
                                        IconButton(
                                          tooltip: _t('Remove', 'Entfernen'),
                                          onPressed: _clearImage,
                                          icon: const Icon(Icons.close_rounded),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_attachmentBytes != null) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.memory(
                                  _attachmentBytes!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            Text(
                              _t('Priority', 'Priorität'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _kTitle,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _PriorityButton(
                                  label: _t('Low', 'Low'),
                                  selected: _priority == 'low',
                                  kind: _PriorityKind.low,
                                  onTap: _submitting
                                      ? null
                                      : () => setState(() => _priority = 'low'),
                                ),
                                _PriorityButton(
                                  label: _t('Medium', 'Medium'),
                                  selected: _priority == 'medium',
                                  kind: _PriorityKind.medium,
                                  onTap: _submitting
                                      ? null
                                      : () => setState(
                                          () => _priority = 'medium',
                                        ),
                                ),
                                _PriorityButton(
                                  label: _t('High', 'High'),
                                  selected: _priority == 'high',
                                  kind: _PriorityKind.high,
                                  onTap: _submitting
                                      ? null
                                      : () =>
                                            setState(() => _priority = 'high'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _t(
                                'Admin/developer will be notified.',
                                'Admin/Developer werden benachrichtigt.',
                              ),
                              style: const TextStyle(
                                color: _kSub,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton(
                                onPressed: _submitting
                                    ? null
                                    : () => _submit(role: role),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _kPrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _t('Submit', 'Absenden'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (!isDeveloper) const SizedBox(height: 16),
                    Text(
                      isStaff
                          ? _t('Latest feedback', 'Letztes Feedback')
                          : _t('Your feedback', 'Dein Feedback'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _kTitle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: query.snapshots(),
                      builder: (context, listSnap) {
                        if (listSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (listSnap.hasError) {
                          return Text(
                            'Failed to load feedback: ${listSnap.error}',
                          );
                        }

                        final docs = listSnap.data?.docs ?? [];
                        final cutoff = DateTime.now().subtract(
                          const Duration(days: 7),
                        );
                        final filtered = docs
                            .where((doc) {
                              final data = doc.data();
                              final status = (data['status'] ?? 'open')
                                  .toString()
                                  .trim()
                                  .toLowerCase();
                              if (status != 'resolved') return true;
                              final raw = data['resolvedAt'];
                              if (raw is! Timestamp) return true;
                              return raw.toDate().isAfter(cutoff);
                            })
                            .toList(growable: false);

                        if (filtered.isEmpty) {
                          return Text(
                            isStaff
                                ? _t(
                                    'No feedback submitted yet.',
                                    'Noch kein Feedback.',
                                  )
                                : _t(
                                    'You have not submitted any feedback yet.',
                                    'Du hast noch kein Feedback gesendet.',
                                  ),
                            style: const TextStyle(
                              color: _kSub,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }

                        return Column(
                          children: filtered
                              .map((d) {
                                final data = d.data();
                                final status = (data['status'] ?? 'open')
                                    .toString()
                                    .trim()
                                    .toLowerCase();
                                final isResolved = status == 'resolved';

                                final title =
                                    (data['title'] ?? data['subject'] ?? '')
                                        .toString()
                                        .trim();
                                final description =
                                    (data['description'] ??
                                            data['message'] ??
                                            '')
                                        .toString()
                                        .trim();
                                final who =
                                    (data['createdByEmail'] ??
                                            data['createdByUid'] ??
                                            '')
                                        .toString()
                                        .trim();
                                final priority = (data['priority'] ?? '')
                                    .toString()
                                    .trim()
                                    .toLowerCase();
                                final createdAt = _fmtTimestamp(
                                  context,
                                  data['createdAt'],
                                );
                                final attachmentUrl =
                                    (data['attachmentUrl'] ?? '')
                                        .toString()
                                        .trim();

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: _kCardBorder),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title.isNotEmpty ? title : '—',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: isResolved
                                                  ? _kSub
                                                  : _kTitle,
                                            ),
                                          ),
                                        ),
                                        _StatusPill(resolved: isResolved),
                                        if (isStaff) ...[
                                          const SizedBox(width: 8),
                                          PopupMenuButton<String>(
                                            tooltip: 'Actions',
                                            onSelected: (v) {
                                              if (v == 'resolve') {
                                                _markResolved(
                                                  feedbackId: d.id,
                                                  resolved: true,
                                                );
                                              }
                                              if (v == 'reopen') {
                                                _markResolved(
                                                  feedbackId: d.id,
                                                  resolved: false,
                                                );
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              if (!isResolved)
                                                PopupMenuItem<String>(
                                                  value: 'resolve',
                                                  child: Text(
                                                    _t(
                                                      'Mark resolved',
                                                      'Als erledigt markieren',
                                                    ),
                                                  ),
                                                ),
                                              if (isResolved)
                                                PopupMenuItem<String>(
                                                  value: 'reopen',
                                                  child: Text(
                                                    _t(
                                                      'Reopen',
                                                      'Wieder öffnen',
                                                    ),
                                                  ),
                                                ),
                                            ],
                                            icon: const Icon(
                                              Icons.more_horiz_rounded,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (description.isNotEmpty)
                                            Text(
                                              description,
                                              style: const TextStyle(
                                                color: _kTitle,
                                                fontWeight: FontWeight.w600,
                                                height: 1.35,
                                              ),
                                            ),
                                          if (attachmentUrl.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _openImagePreview(
                                                    attachmentUrl,
                                                  ),
                                              icon: const Icon(
                                                Icons.image_outlined,
                                              ),
                                              label: Text(
                                                _t(
                                                  'View image',
                                                  'Bild ansehen',
                                                ),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 6,
                                            children: [
                                              if (priority.isNotEmpty)
                                                _metaChip(
                                                  label: 'priority: $priority',
                                                ),
                                              _metaChip(label: createdAt),
                                              if (isStaff && who.isNotEmpty)
                                                _metaChip(label: who),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(growable: false),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _metaChip extends StatelessWidget {
  final String label;
  const _metaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4B5563),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool resolved;
  const _StatusPill({required this.resolved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: resolved ? const Color(0xFFEEF2FF) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: resolved ? const Color(0xFFC7D2FE) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Text(
        resolved ? 'RESOLVED' : 'OPEN',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          color: resolved ? const Color(0xFF3730A3) : const Color(0xFF166534),
        ),
      ),
    );
  }
}

enum _PriorityKind { low, medium, high }

class _PriorityButton extends StatelessWidget {
  final String label;
  final bool selected;
  final _PriorityKind kind;
  final VoidCallback? onTap;

  const _PriorityButton({
    required this.label,
    required this.selected,
    required this.kind,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border;
    Color fg;
    Color bg;
    switch (kind) {
      case _PriorityKind.low:
        border = const Color(0xFF22C55E);
        fg = const Color(0xFF16A34A);
        bg = selected ? const Color(0xFFECFDF5) : Colors.white;
        break;
      case _PriorityKind.medium:
        border = const Color(0xFFEAB308);
        fg = const Color(0xFFB45309);
        bg = selected ? const Color(0xFFFDE68A) : Colors.white;
        break;
      case _PriorityKind.high:
        border = const Color(0xFFEF4444);
        fg = const Color(0xFFDC2626);
        bg = selected ? const Color(0xFFFEE2E2) : Colors.white;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 150,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w900, color: fg),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final double dash;
  final double gap;
  final Color color;
  final double strokeWidth;

  const _DashedRRectBorder({
    required this.child,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        radius: radius,
        dash: dash,
        gap: gap,
        color: color,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final double radius;
  final double dash;
  final double gap;
  final Color color;
  final double strokeWidth;

  _DashedRRectPainter({
    required this.radius,
    required this.dash,
    required this.gap,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dash < metric.length)
            ? dash
            : (metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
