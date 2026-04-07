// lib/screens/notifications_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../localization/app_localizations.dart';

bool _isDriverWorking(Map<String, dynamic> driverData) {
  bool? parseBoolish(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final v = raw.trim().toLowerCase();
      if (v == 'false' || v == '0' || v == 'off' || v == 'inactive') {
        return false;
      }
      if (v == 'true' || v == '1' || v == 'on' || v == 'active') {
        return true;
      }
    }
    return null;
  }

  final active = parseBoolish(driverData['active']);
  final working = parseBoolish(driverData['working']);
  final isWorking = parseBoolish(driverData['isWorking']);

  if (active == false || working == false || isWorking == false) {
    return false;
  }

  final status = (driverData['status'] ?? '').toString().trim().toLowerCase();
  if (status == 'off' || status == 'inactive' || status == 'suspended') {
    return false;
  }

  if (active == true || working == true || isWorking == true) {
    return true;
  }

  return true; // Backward compatible default
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  bool _publishing = false;
  bool _translating = false;
  Map<String, Map<String, String>> _translationsByLang = const {};

  // Matches your UI dropdown type values
  final List<_NotifType> _types = const [
    _NotifType('rule', 'notifications_page_type_rule'),
    _NotifType('message', 'notifications_page_type_message'),
    _NotifType('academy', 'notifications_page_type_academy'),
    _NotifType('rideAlong', 'notifications_page_type_ride_along'),
  ];
  late _NotifType _selectedType = _types.first;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  String _sourceLangCode() {
    final supported = AppLocalizations.supportedLocales
        .map((l) => l.languageCode.toLowerCase())
        .toSet();
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return supported.contains(code) ? code : 'en';
  }

  void _clearTranslationsIfAny() {
    if (_translationsByLang.isEmpty) return;
    setState(() {
      _translationsByLang = const {};
    });
  }

  void _updateTranslation(String lang, String field, String value) {
    setState(() {
      final next = <String, Map<String, String>>{};
      for (final entry in _translationsByLang.entries) {
        next[entry.key] = Map<String, String>.from(entry.value);
      }
      final row = next.putIfAbsent(lang, () => <String, String>{});
      row[field] = value;
      _translationsByLang = next;
    });
  }

  Future<void> _translateAllLanguages() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t('notifications_page_title_or_message_required')),
        ),
      );
      return;
    }

    final sourceLang = _sourceLangCode();
    final targets = AppLocalizations.supportedLocales
        .map((l) => l.languageCode.toLowerCase())
        .where((code) => code != sourceLang)
        .toList(growable: false);
    if (targets.isEmpty) return;

    setState(() => _translating = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'translateFaqText',
      );
      final response = await callable.call({
        'sourceLang': sourceLang,
        'targetLangs': targets,
        'question': title,
        'answer': body,
      });

      final data = (response.data as Map?) ?? const {};
      final translations =
          (data['translations'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};

      final mapped = <String, Map<String, String>>{};
      for (final code in targets) {
        final raw = translations[code];
        if (raw is! Map) continue;
        final row = raw.cast<String, dynamic>();
        final translatedTitle = (row['question'] ?? '').toString().trim();
        final translatedBody = (row['answer'] ?? '').toString().trim();
        if (translatedTitle.isEmpty && translatedBody.isEmpty) continue;
        mapped[code] = {
          'title': translatedTitle,
          'body': translatedBody,
        };
      }

      if (!mounted) return;
      setState(() {
        _translationsByLang = mapped;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mapped.isEmpty
                ? 'No translations were generated.'
                : 'Translated for ${mapped.length} languages.',
          ),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('admin_faq_error_auto_translate', {
              'error': e.message ?? e.code,
            }),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('admin_faq_error_auto_translate', {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  // ------------------------------------------------------------
  // Publish (UI-first implementation)
  // ------------------------------------------------------------
  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context);
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('notifications_page_must_be_logged_in'))),
      );
      return;
    }

    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t('notifications_page_title_or_message_required')),
        ),
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
        'sourceLang': _sourceLangCode(),
        'translations': _translationsByLang,
        'requiresConfirmation': _selectedType.value == 'rule',
      });

      final data = (res.data as Map?) ?? {};
      final targetCount = (data['targetCount'] as num?)?.toInt() ?? 0;

      if (!mounted) return;
      _titleCtrl.clear();
      _bodyCtrl.clear();
      setState(() {
        _translationsByLang = const {};
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('notifications_page_published_to_drivers', {
              'count': '$targetCount',
            }),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('notifications_page_publish_failed', {
              'error': e.toString(),
            }),
          ),
        ),
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
    final l10n = AppLocalizations.of(context);
    // ✅ Load notification details (title/body) once for the popup header
    final notifDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(dspUid)
        .collection('notifications')
        .doc(notificationId)
        .get();

    final notifTitle =
        (notifDoc.data()?['title'] ??
                l10n.t('notifications_page_popup_notification_fallback'))
            .toString();
    final notifBody = (notifDoc.data()?['body'] ?? '').toString();

    Future<Map<String, dynamic>> loadMissingDrivers() async {
      final driversSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(dspUid)
          .collection('drivers')
          .get();
      final missing = <String>[];
      var total = 0;

      for (final d in driversSnap.docs) {
        final driverData = d.data();
        final driverName =
            (driverData['driverName'] ??
                    driverData['fullName'] ??
                    l10n.t('notifications_page_popup_driver_fallback'))
                .toString();

        final notifSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(dspUid)
            .collection('drivers')
            .doc(d.id)
            .collection('notifications')
            .doc(notificationId)
            .get();

        if (!notifSnap.exists) {
          continue; // Not part of this notification target set
        }

        total += 1;
        final status = (notifSnap.data()?['status'] ?? 'unread').toString();

        if (status != 'confirmed') {
          missing.add(driverName);
        }
      }

      return {
        'missing': missing,
        'total': total,
        'confirmed': total - missing.length,
      };
    }

    final statsFuture = loadMissingDrivers();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final size = MediaQuery.of(ctx).size;
        final dialogMaxHeight = size.height * 0.88;
        final dialogWidth = size.width < 560 ? size.width - 24 : 520.0;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogMaxHeight,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notifTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (notifBody.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: dialogMaxHeight * 0.28,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          notifBody,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        l10n.t('notifications_page_not_confirmed_by'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      FutureBuilder<Map<String, dynamic>>(
                        future: statsFuture,
                        builder: (_, statsSnap) {
                          if (statsSnap.connectionState ==
                                  ConnectionState.waiting &&
                              !statsSnap.hasData) {
                            return Text(
                              l10n.t('notifications_page_missing_loading'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE9741A),
                              ),
                            );
                          }
                          if (statsSnap.hasError) {
                            return Text(
                              l10n.t('notifications_page_missing_unknown'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE9741A),
                              ),
                            );
                          }
                          final total =
                              (statsSnap.data?['total'] as num?)?.toInt() ?? 0;
                          final confirmed =
                              (statsSnap.data?['confirmed'] as num?)?.toInt() ??
                              0;
                          final missingRaw = total - confirmed;
                          final missing = missingRaw < 0 ? 0 : missingRaw;
                          return Text(
                            l10n.tf('notifications_page_missing_count', {
                              'count': '$missing',
                            }),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE9741A),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: statsFuture,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              l10n.tf('notifications_page_error_generic', {
                                'error': '${snap.error}',
                              }),
                            ),
                          );
                        }

                        final items =
                            (snap.data?['missing'] as List<dynamic>? ??
                                    const [])
                                .map((e) => e.toString())
                                .toList(growable: false);
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.t(
                                'notifications_page_all_drivers_confirmed',
                              ),
                              style: const TextStyle(color: Colors.black54),
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
                      child: Text(l10n.t('notifications_page_close')),
                    ),
                  ),
                ],
              ),
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
    final l10n = AppLocalizations.of(context);
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
            stacked: stack,
            selectedType: _selectedType,
            types: _types,
            titleCtrl: _titleCtrl,
            bodyCtrl: _bodyCtrl,
            publishing: _publishing,
            translating: _translating,
            translatedCount: _translationsByLang.length,
            translationsByLang: _translationsByLang,
            onTranslationChanged: _updateTranslation,
            onTypeChanged: (t) => setState(() => _selectedType = t),
            onContentChanged: _clearTranslationsIfAny,
            onTranslateAll:
                (_publishing || _translating) ? null : _translateAllLanguages,
            onPublish: (_publishing || _translating) ? null : _publish,
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
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  const Icon(Icons.notifications_none, size: 22),
                  Text(
                    l10n.t('notifications_page_title'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: stack
                    ? ListView(
                        // Keep the composer natural-height on narrow screens so
                        // the original source fields remain visible.
                        children: [
                          left,
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
  final bool stacked;
  final _NotifType selectedType;
  final List<_NotifType> types;

  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;

  final bool publishing;
  final bool translating;
  final int translatedCount;
  final Map<String, Map<String, String>> translationsByLang;
  final void Function(String lang, String field, String value)
  onTranslationChanged;
  final ValueChanged<_NotifType> onTypeChanged;
  final VoidCallback onContentChanged;
  final VoidCallback? onTranslateAll;
  final VoidCallback? onPublish;

  const _ComposerCard({
    required this.stacked,
    required this.selectedType,
    required this.types,
    required this.titleCtrl,
    required this.bodyCtrl,
    required this.publishing,
    required this.translating,
    required this.translatedCount,
    required this.translationsByLang,
    required this.onTranslationChanged,
    required this.onTypeChanged,
    required this.onContentChanged,
    required this.onTranslateAll,
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
    final l10n = AppLocalizations.of(context);
    Widget buildBodyField() {
      final field = TextField(
        controller: bodyCtrl,
        onChanged: (_) => onContentChanged(),
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        decoration: _pillField(
          hint: l10n.t('notifications_page_rule_message_hint'),
        ),
      );

      if (stacked) {
        return SizedBox(height: 180, child: field);
      }
      return Expanded(child: field);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: "NEW CONTENT | Notifications" + dropdown
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final dropdown = Container(
                width: compact ? double.infinity : null,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<_NotifType>(
                    value: selectedType,
                    isExpanded: compact,
                    items: types
                        .map(
                          (t) => DropdownMenuItem<_NotifType>(
                            value: t,
                            child: Text(
                              l10n.t(t.labelKey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onTypeChanged(v);
                    },
                  ),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF1D7F5A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.t('notifications_page_new_content'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    dropdown,
                  ],
                );
              }

              return Row(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF1D7F5A),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.t('notifications_page_new_content'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  dropdown,
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Title
          TextField(
            controller: titleCtrl,
            onChanged: (_) => onContentChanged(),
            decoration: _pillField(
              hint: l10n.t('notifications_page_title_hint'),
            ),
          ),
          const SizedBox(height: 12),

          // Rule / Message big box
          buildBodyField(),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTranslateAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1D7F5A),
                    side: const BorderSide(color: Color(0xFF1D7F5A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: translating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.translate, size: 18),
                  label: Text(
                    translating
                        ? 'Translating...'
                        : 'Translate all languages',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          if (translatedCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              l10n.tf('notifications_page_translation_ready', {
                'count': '$translatedCount',
              }),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D7F5A),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: stacked ? 320 : 220),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9E7DE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('notifications_page_translation_preview'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D7F5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: translationsByLang.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = translationsByLang.entries.elementAt(
                          index,
                        );
                        final translatedTitle =
                            (entry.value['title'] ?? '').trim();
                        final translatedBody =
                            (entry.value['body'] ?? '').trim();
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6B7280),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: translatedTitle,
                                key: ValueKey('title-${entry.key}'),
                                onChanged: (value) => onTranslationChanged(
                                  entry.key,
                                  'title',
                                  value,
                                ),
                                decoration: _pillField(
                                  hint: l10n.t('notifications_page_title_hint'),
                                ).copyWith(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF22252F),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: translatedBody,
                                key: ValueKey('body-${entry.key}'),
                                onChanged: (value) => onTranslationChanged(
                                  entry.key,
                                  'body',
                                  value,
                                ),
                                minLines: 2,
                                maxLines: 4,
                                decoration: _pillField(
                                  hint: l10n.t(
                                    'notifications_page_rule_message_hint',
                                  ),
                                ).copyWith(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: Color(0xFF4A4F59),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        l10n.t('notifications_page_publish'),
                        style: const TextStyle(
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
  final void Function(
    String notificationId,
    int confirmedCount,
    int targetCount,
  )
  onOpenMissing;

  const _HistoryCard({required this.uid, required this.onOpenMissing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dspUid = uid;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF1D7F5A)),
              const SizedBox(width: 10),
              Text(
                l10n.t('notifications_page_history'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: dspUid == null
                ? Center(
                    child: Text(l10n.t('notifications_page_not_logged_in')),
                  )
                : StreamBuilder<int>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(dspUid)
                        .collection('drivers')
                        .snapshots()
                        .map(
                          (s) => s.docs
                              .where((d) => _isDriverWorking(d.data()))
                              .length,
                        ),
                    builder: (ctx, driverSnap) {
                      final currentDriverCount = driverSnap.hasData
                          ? (driverSnap.data ?? 0)
                          : -1;
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                              child: Text(
                                l10n.tf('notifications_page_error_generic', {
                                  'error': '${snap.error}',
                                }),
                              ),
                            );
                          }

                          final docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return Center(
                              child: Text(
                                l10n.t('notifications_page_no_notifications'),
                                style: const TextStyle(color: Colors.black54),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final d = docs[i];
                              final data = d.data();
                              final title = (data['title'] ?? '').toString();
                              final body = (data['body'] ?? '').toString();
                              final type = (data['type'] ?? 'rule').toString();
                              final confirmedCount =
                                  (data['confirmedCount'] as num?)?.toInt() ??
                                  0;
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
                                  currentDriverCount: currentDriverCount,
                                ),
                              );
                            },
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
  final int currentDriverCount;

  const _HistoryTile({
    required this.dspUid,
    required this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.dateTime,
    required this.confirmedCount,
    required this.targetCount,
    required this.currentDriverCount,
  });

  String _fmtDate(DateTime? dt, AppLocalizations l10n) {
    if (dt == null) return '';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final suffix = l10n.t('notifications_page_time_suffix').trim();
    if (suffix.isEmpty) return '$dd.$mm.$yy | $hh:$min';
    return '$dd.$mm.$yy | $hh:$min $suffix';
  }

  String _typeLabel(String t, AppLocalizations l10n) {
    switch (t) {
      case 'message':
        return l10n.t('notifications_page_type_message_badge');
      case 'academy':
        return l10n.t('notifications_page_type_academy_badge');
      case 'rideAlong':
        return l10n.t('notifications_page_type_ride_along_badge');
      case 'rule':
      default:
        return l10n.t('notifications_page_type_rule_badge');
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

  Future<void> _editEverywhere(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final titleCtrl = TextEditingController(text: title);
    final bodyCtrl = TextEditingController(text: body);

    try {
      final payload = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return AlertDialog(
            title: Text(l10n.t('notifications_page_edit_rule')),
            content: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.t('notifications_page_field_title'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyCtrl,
                    minLines: 5,
                    maxLines: 12,
                    decoration: InputDecoration(
                      labelText: l10n.t('notifications_page_field_body'),
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.t('notifications_page_cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop({
                    'title': titleCtrl.text.trim(),
                    'body': bodyCtrl.text.trim(),
                  });
                },
                child: Text(l10n.t('notifications_page_save')),
              ),
            ],
          );
        },
      );

      if (payload == null) return;
      final newTitle = (payload['title'] ?? '').trim();
      final newBody = (payload['body'] ?? '').trim();
      if (newTitle.isEmpty && newBody.isEmpty) {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(l10n.t('notifications_page_title_or_body_required')),
          ),
        );
        return;
      }

      final db = FirebaseFirestore.instance;
      final dspRef = db.collection('users').doc(dspUid);
      final adminNotifRef = dspRef
          .collection('notifications')
          .doc(notificationId);

      final adminSnap = await adminNotifRef.get();
      if (!adminSnap.exists) {
        throw Exception(l10n.t('notifications_page_notification_not_found'));
      }

      final adminData = adminSnap.data() ?? <String, dynamic>{};
      final notifType = (adminData['type'] ?? type).toString();
      final createdAt = adminData['createdAt'];
      final now = FieldValue.serverTimestamp();
      final sourceLang = Localizations.localeOf(context).languageCode
          .toLowerCase();

      final driversSnap = await dspRef.collection('drivers').get();
      final drivers = driversSnap.docs
          .where((d) => _isDriverWorking(d.data()))
          .toList(growable: false);

      await adminNotifRef.set({
        'title': newTitle,
        'body': newBody,
        'sourceLang': sourceLang,
        'translations': <String, dynamic>{},
        'targetCount': drivers.length,
        'confirmedCount': 0,
        'requiresConfirmation': true,
        'updatedAt': now,
        'editedAt': now,
      }, SetOptions(merge: true));

      const chunkSize = 400;
      for (int i = 0; i < drivers.length; i += chunkSize) {
        final end = (i + chunkSize > drivers.length)
            ? drivers.length
            : (i + chunkSize);
        final batch = db.batch();

        for (final d in drivers.sublist(i, end)) {
          final driverNotifRef = d.reference
              .collection('notifications')
              .doc(notificationId);

          batch.set(driverNotifRef, {
            'notificationId': notificationId,
            'type': notifType,
            'title': newTitle,
            'body': newBody,
            'sourceLang': sourceLang,
            'translations': <String, dynamic>{},
            'status': 'unread',
            'readAt': null,
            'confirmedAt': null,
            'requiresConfirmation': true,
            'createdAt': createdAt ?? now,
            'updatedAt': now,
            'editedAt': now,
          }, SetOptions(merge: true));
        }

        await batch.commit();
      }

      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('notifications_page_rule_updated_for_drivers', {
              'count': '${drivers.length}',
            }),
          ),
        ),
      );
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('notifications_page_edit_failed', {'error': e.toString()}),
          ),
        ),
      );
    } finally {
      titleCtrl.dispose();
      bodyCtrl.dispose();
    }
  }

  Future<void> _deleteEverywhere(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.t('notifications_page_delete_question')),
          content: Text(l10n.t('notifications_page_delete_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.t('notifications_page_cancel')),
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
              child: Text(l10n.t('notifications_page_delete')),
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
      await callable.call({'dspUid': dspUid, 'notificationId': notificationId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t('notifications_page_notification_deleted')),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.tf('notifications_page_delete_failed', {
              'error': e.toString(),
            }),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = targetCount > 0 ? targetCount : currentDriverCount;
    final safeTotal = total <= 0 ? 0 : total;
    final safeConfirmed = safeTotal <= 0
        ? 0
        : (confirmedCount > safeTotal ? safeTotal : confirmedCount);
    final ratio = '$safeConfirmed / $safeTotal';

    final menuButton = Theme(
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
            tooltip: l10n.t('notifications_page_options'),
            splashRadius: 18,
            offset: const Offset(0, 10),
            onSelected: (v) {
              if (v == 'edit') _editEverywhere(context);
              if (v == 'delete') _deleteEverywhere(context);
            },
            itemBuilder: (_) => [
              if (type == 'rule')
                PopupMenuItem<String>(
                  value: 'edit',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF1D7F5A),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.t('notifications_page_menu_edit_rule'),
                        style: const TextStyle(
                          color: Color(0xFF1D7F5A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'delete',
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.t('notifications_page_menu_delete'),
                      style: const TextStyle(
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
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;

          final leading = Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(_typeIcon(type), color: const Color(0xFF6B7280)),
          );

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_typeLabel(type, l10n)} | ${title.isEmpty ? l10n.t('notifications_page_title_fallback') : title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              if (_fmtDate(dateTime, l10n).isNotEmpty)
                Text(
                  _fmtDate(dateTime, l10n),
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
          );

          final meta = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.t('notifications_page_confirmed_by'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
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
              menuButton,
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leading,
                    const SizedBox(width: 12),
                    Expanded(child: textBlock),
                  ],
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [meta]),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(child: textBlock),
              const SizedBox(width: 14),
              meta,
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small type helper
// -----------------------------------------------------------------------------
class _NotifType {
  final String value; // stored in Firestore
  final String labelKey; // localization key shown in dropdown
  const _NotifType(this.value, this.labelKey);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is _NotifType && other.value == value);

  @override
  int get hashCode => value.hashCode;
}
