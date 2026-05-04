import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../data/driver_faq_keys.dart';
import '../widgets/web_preview.dart';

const String _localizedFaqCollection = 'faqs_localized';
const String _insertAtStart = '__start__';
const String _insertAtEnd = '__end__';
const Color _kFaqGreen = Color(0xFF1D7F5A);
const Color _kFaqText = Color(0xFF111827);
const Color _kFaqSubText = Color(0xFF4B5563);
const Color _kFaqMuted = Color(0xFF6B7280);
const Color _kFaqCardBg = Color(0xFFF9FAFB);
const Color _kFaqCardBorder = Color(0xFFE5E7EB);

Future<String?> _resolveFaqImageUrl({
  required String rawUrl,
  required String rawPath,
}) async {
  final pathValue = rawPath.trim();
  if (pathValue.isNotEmpty) {
    try {
      final normalized = pathValue.startsWith('/')
          ? pathValue.substring(1)
          : pathValue;
      return await fb.FirebaseStorage.instance
          .ref()
          .child(normalized)
          .getDownloadURL();
    } catch (_) {
      // ignore and fall back to URL resolution
    }
  }

  final value = rawUrl.trim();
  if (value.isEmpty) return null;
  final lower = value.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return value;
  }
  try {
    if (lower.startsWith('gs://')) {
      return await fb.FirebaseStorage.instance
          .refFromURL(value)
          .getDownloadURL();
    }
    final normalized = value.startsWith('/') ? value.substring(1) : value;
    if (normalized.isNotEmpty) {
      return await fb.FirebaseStorage.instance
          .ref()
          .child(normalized)
          .getDownloadURL();
    }
  } catch (_) {
    // ignore resolution failures
  }
  return null;
}

class AdminFaqPage extends StatefulWidget {
  const AdminFaqPage({super.key});

  @override
  State<AdminFaqPage> createState() => _AdminFaqPageState();
}

class _LocaleFaqFields extends StatelessWidget {
  final String label;
  final TextEditingController questionCtrl;
  final TextEditingController answerCtrl;
  final bool initiallyExpanded;
  final String? questionHint;
  final String? answerHint;

  const _LocaleFaqFields({
    required this.label,
    required this.questionCtrl,
    required this.answerCtrl,
    required this.initiallyExpanded,
    this.questionHint,
    this.answerHint,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    InputDecoration fieldDecoration({
      required String labelText,
      String? hintText,
    }) {
      return InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kFaqCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kFaqCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kFaqGreen, width: 1.2),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kFaqCardBorder),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text(
          t.tf('admin_faq_locale_title', {'code': label}),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(
              children: [
                TextField(
                  controller: questionCtrl,
                  decoration: fieldDecoration(
                    labelText: t.t('admin_faq_question_label'),
                    hintText: questionHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: answerCtrl,
                  maxLines: 5,
                  decoration: fieldDecoration(
                    labelText: t.t('admin_faq_answer_label'),
                    hintText: answerHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatFaqNode {
  final DriverFaqNode node;
  final int depth;

  const _FlatFaqNode({required this.node, required this.depth});
}

class _InsertOption {
  final String key;
  final String label;

  const _InsertOption({required this.key, required this.label});
}

class _FaqImageUploadResult {
  final String downloadUrl;
  final String storagePath;
  final Uint8List bytes;

  const _FaqImageUploadResult({
    required this.downloadUrl,
    required this.storagePath,
    required this.bytes,
  });
}

class _AdminFaqPageState extends State<AdminFaqPage> {
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void _showError(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<_FaqImageUploadResult?> _pickAndUploadFaqImage(
    String folderKey,
  ) async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showError('Could not read image bytes.');
        return null;
      }

      final extension = _faqImageExtension(file.name, file.extension);
      if (!_isAllowedFaqImageExtension(extension)) {
        _showError('Unsupported image format. Use JPG, PNG, WEBP, or GIF.');
        return null;
      }

      final ref = fb.FirebaseStorage.instance
          .ref()
          .child('faq_images')
          .child(uid)
          .child(folderKey)
          .child(
            '${DateTime.now().millisecondsSinceEpoch}_${_sanitizeFaqImageName(file.name)}',
          );

      await ref.putData(
        bytes,
        fb.SettableMetadata(contentType: _faqImageContentType(extension)),
      );
      return _FaqImageUploadResult(
        downloadUrl: await ref.getDownloadURL(),
        storagePath: ref.fullPath,
        bytes: bytes,
      );
    } catch (e) {
      _showError('Failed to upload image: $e');
      return null;
    }
  }

  String _faqImageExtension(String name, String? extension) {
    final fromExtension = (extension ?? '').trim().toLowerCase();
    if (fromExtension.isNotEmpty) {
      return fromExtension;
    }
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot >= name.length - 1) {
      return 'jpg';
    }
    return name.substring(dot + 1).toLowerCase();
  }

  bool _isAllowedFaqImageExtension(String extension) {
    return const {'jpg', 'jpeg', 'png', 'webp', 'gif'}.contains(extension);
  }

  String _faqImageContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  String _sanitizeFaqImageName(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return cleaned.isEmpty ? 'faq_image.jpg' : cleaned;
  }

  Future<int> _autoTranslateMissingLocaleFields({
    required List<Locale> locales,
    required Map<String, TextEditingController> qCtrls,
    required Map<String, TextEditingController> aCtrls,
    bool overwriteExisting = false,
  }) async {
    final codes = locales.map((l) => l.languageCode.toLowerCase()).toList();

    String? sourceLang;
    for (final preferred in ['en', ...codes]) {
      if (!codes.contains(preferred)) continue;
      final q = qCtrls[preferred]?.text.trim() ?? '';
      final a = aCtrls[preferred]?.text.trim() ?? '';
      if (q.isNotEmpty || a.isNotEmpty) {
        sourceLang = preferred;
        break;
      }
    }

    if (sourceLang == null) return 0;

    final sourceQuestion = qCtrls[sourceLang]?.text.trim() ?? '';
    final sourceAnswer = aCtrls[sourceLang]?.text.trim() ?? '';
    if (sourceQuestion.isEmpty && sourceAnswer.isEmpty) return 0;

    final targets = <String>[];
    for (final code in codes) {
      if (code == sourceLang) continue;
      if (overwriteExisting) {
        targets.add(code);
        continue;
      }
      final needsQuestion =
          sourceQuestion.isNotEmpty &&
          (qCtrls[code]?.text.trim().isEmpty ?? true);
      final needsAnswer =
          sourceAnswer.isNotEmpty &&
          (aCtrls[code]?.text.trim().isEmpty ?? true);
      if (needsQuestion || needsAnswer) {
        targets.add(code);
      }
    }

    if (targets.isEmpty) return 0;

    var translatedCount = 0;

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'translateFaqText',
      );

      final response = await callable.call({
        'sourceLang': sourceLang,
        'targetLangs': targets,
        'question': sourceQuestion,
        'answer': sourceAnswer,
      });

      final data = (response.data as Map?) ?? const {};
      final translations =
          (data['translations'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};

      for (final code in targets) {
        final raw = translations[code];
        if (raw is! Map) continue;
        final row = raw.cast<String, dynamic>();

        final qTranslated = (row['question'] ?? '').toString().trim();
        final aTranslated = (row['answer'] ?? '').toString().trim();

        final qCtrl = qCtrls[code];
        final aCtrl = aCtrls[code];

        if (qCtrl != null &&
            qTranslated.isNotEmpty &&
            (overwriteExisting || qCtrl.text.trim().isEmpty)) {
          qCtrl.text = qTranslated;
          translatedCount++;
        }
        if (aCtrl != null &&
            aTranslated.isNotEmpty &&
            (overwriteExisting || aCtrl.text.trim().isEmpty)) {
          aCtrl.text = aTranslated;
          translatedCount++;
        }
      }
      return translatedCount;
    } on FirebaseFunctionsException catch (e) {
      _showError(
        AppLocalizations.of(
          context,
        ).tf('admin_faq_error_auto_translate', {'error': e.message ?? e.code}),
      );
    } catch (e) {
      _showError(
        AppLocalizations.of(
          context,
        ).tf('admin_faq_error_auto_translate', {'error': '$e'}),
      );
    }
    return 0;
  }

  CollectionReference<Map<String, dynamic>>? get _faqCol {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('faqs');
  }

  CollectionReference<Map<String, dynamic>>? get _localizedFaqCol {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_localizedFaqCollection);
  }

  Future<void> _openFaqEditor({
    String? docId,
    Map<String, dynamic>? data,
    int? order,
  }) async {
    final t = AppLocalizations.of(context);
    final locales = AppLocalizations.supportedLocales;
    final qCtrls = <String, TextEditingController>{};
    final aCtrls = <String, TextEditingController>{};
    final insertOptions = _buildInsertOptions(t);
    final initialInsertKey = (data?['insertAfterKey'] ?? _insertAtEnd)
        .toString();
    String imageUrl = (data?['imageUrl'] ?? '').toString().trim();
    String imagePath = (data?['imagePath'] ?? '').toString().trim();
    String imagePreviewUrl =
        await _resolveFaqImageUrl(rawUrl: imageUrl, rawPath: imagePath) ?? '';
    if (imagePreviewUrl.isEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      imagePreviewUrl = imageUrl;
    }
    Uint8List? previewBytes;
    var imageUploading = false;
    var translating = false;
    String selectedInsertKey =
        insertOptions.any((o) => o.key == initialInsertKey)
        ? initialInsertKey
        : _insertAtEnd;

    for (final locale in locales) {
      final code = locale.languageCode;
      final qValue = _storedFaqEditorValue(data, 'question', code);
      final aValue = _storedFaqEditorValue(data, 'answer', code);
      qCtrls[code] = TextEditingController(text: qValue);
      aCtrls[code] = TextEditingController(text: aValue);
    }

    var dialogOpen = true;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> uploadImage() async {
              if (!dialogOpen) return;
              setStateDialog(() => imageUploading = true);
              final uploaded = await _pickAndUploadFaqImage('custom');
              if (!mounted || !dialogOpen) return;
              setStateDialog(() {
                imageUploading = false;
                if (uploaded != null && uploaded.downloadUrl.isNotEmpty) {
                  imageUrl = uploaded.downloadUrl;
                  imagePath = uploaded.storagePath;
                  imagePreviewUrl = uploaded.downloadUrl;
                  previewBytes = uploaded.bytes;
                }
              });
            }

            Future<void> translateAllLanguages() async {
              if (!dialogOpen || imageUploading || translating) return;
              setStateDialog(() => translating = true);
              final translatedCount = await _autoTranslateMissingLocaleFields(
                locales: locales,
                qCtrls: qCtrls,
                aCtrls: aCtrls,
                overwriteExisting: true,
              );
              if (!mounted || !dialogOpen) return;
              setStateDialog(() => translating = false);
              final messenger = ScaffoldMessenger.maybeOf(context);
              messenger?.showSnackBar(
                SnackBar(
                  content: Text(
                    translatedCount > 0
                        ? t.tf('admin_faq_translate_done', {
                            'count': '$translatedCount',
                          })
                        : t.t('admin_faq_translate_none'),
                  ),
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: Text(
                docId == null
                    ? t.t('admin_faq_add_title')
                    : t.t('admin_faq_edit_title'),
              ),
              content: SizedBox(
                width: 520,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 560),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    children: [
                      _FaqImageEditorCard(
                        imageUrl: imageUrl,
                        previewUrl: imagePreviewUrl,
                        previewBytes: previewBytes,
                        isUploading: imageUploading,
                        onUpload: uploadImage,
                        onRemove: imageUrl.isEmpty || imageUploading
                            ? null
                            : () => setStateDialog(() {
                                imageUrl = '';
                                imagePath = '';
                                imagePreviewUrl = '';
                                previewBytes = null;
                              }),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: imageUploading || translating
                              ? null
                              : translateAllLanguages,
                          icon: translating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.translate),
                          label: Text(t.t('admin_faq_translate_all_languages')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedInsertKey,
                          isExpanded: true,
                          selectedItemBuilder: (context) {
                            return insertOptions
                                .map(
                                  (option) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      option.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList();
                          },
                          items: insertOptions
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option.key,
                                  child: Text(
                                    option.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: imageUploading || translating
                              ? null
                              : (value) {
                                  setStateDialog(
                                    () => selectedInsertKey =
                                        value ?? _insertAtEnd,
                                  );
                                },
                          decoration: InputDecoration(
                            labelText: t.t('admin_faq_insert_after'),
                            labelStyle: TextStyle(height: 1.2),
                            border: const OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...locales.map((locale) {
                        final code = locale.languageCode;
                        return _LocaleFaqFields(
                          label: code.toUpperCase(),
                          questionCtrl: qCtrls[code]!,
                          answerCtrl: aCtrls[code]!,
                          initiallyExpanded: code == 'en',
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: imageUploading || translating
                      ? null
                      : () {
                          dialogOpen = false;
                          Navigator.of(ctx).pop(false);
                        },
                  child: Text(t.t('admin_faq_cancel')),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _kFaqGreen),
                  onPressed: imageUploading || translating
                      ? null
                      : () {
                          dialogOpen = false;
                          Navigator.of(ctx).pop(true);
                        },
                  child: Text(t.t('admin_faq_save')),
                ),
              ],
            );
          },
        );
      },
    );
    dialogOpen = false;

    if (ok != true) {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
      return;
    }

    await _autoTranslateMissingLocaleFields(
      locales: locales,
      qCtrls: qCtrls,
      aCtrls: aCtrls,
    );

    final col = _faqCol;
    if (col == null) return;

    String firstNonEmpty(Map<String, TextEditingController> ctrls) {
      for (final locale in locales) {
        final code = locale.languageCode;
        final text = ctrls[code]?.text.trim() ?? '';
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final payload = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'order': order ?? DateTime.now().millisecondsSinceEpoch,
      'insertAfterKey': selectedInsertKey,
    };

    if (imageUrl.trim().isNotEmpty) {
      payload['imageUrl'] = imageUrl.trim();
      payload['imagePath'] = imagePath.trim();
    } else if (data != null && data.containsKey('imageUrl')) {
      payload['imageUrl'] = FieldValue.delete();
      payload['imagePath'] = FieldValue.delete();
    }

    for (final locale in locales) {
      final code = locale.languageCode;
      final qText = qCtrls[code]?.text.trim() ?? '';
      final aText = aCtrls[code]?.text.trim() ?? '';
      payload['question_$code'] = qText;
      payload['answer_$code'] = aText;
    }

    final qEn = qCtrls['en']?.text.trim() ?? '';
    final aEn = aCtrls['en']?.text.trim() ?? '';
    payload['question'] = qEn.isNotEmpty ? qEn : firstNonEmpty(qCtrls);
    payload['answer'] = aEn.isNotEmpty ? aEn : firstNonEmpty(aCtrls);

    try {
      if (docId == null) {
        await col.add({...payload, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        await col.doc(docId).set(payload, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      _showError(t.tf('admin_faq_error_save', {'error': e.message ?? e.code}));
    } catch (e) {
      _showError(t.tf('admin_faq_error_save', {'error': '$e'}));
    } finally {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
    }
  }

  Future<void> _openLocalizedFaqEditor({
    required DriverFaqNode node,
    Map<String, dynamic>? overrideData,
  }) async {
    final t = AppLocalizations.of(context);
    final locales = AppLocalizations.supportedLocales;
    final qCtrls = <String, TextEditingController>{};
    final aCtrls = <String, TextEditingController>{};
    final defaultQuestions = <String, String>{};
    final defaultAnswers = <String, String>{};
    String imageUrl = (overrideData?['imageUrl'] ?? '').toString().trim();
    String imagePath = (overrideData?['imagePath'] ?? '').toString().trim();
    String imagePreviewUrl =
        await _resolveFaqImageUrl(rawUrl: imageUrl, rawPath: imagePath) ?? '';
    if (imagePreviewUrl.isEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))) {
      imagePreviewUrl = imageUrl;
    }
    Uint8List? previewBytes;
    var imageUploading = false;
    var translating = false;

    for (final locale in locales) {
      final code = locale.languageCode;
      final localeText = AppLocalizations(locale);
      final qOverride = _overrideValue(overrideData, 'question', code);
      final aOverride = _overrideValue(overrideData, 'answer', code);
      final defaultQuestion = localeText.t(node.qKey).trim();
      final defaultAnswer = localeText.t(node.aKey).trim();

      defaultQuestions[code] = defaultQuestion;
      defaultAnswers[code] = defaultAnswer;
      qCtrls[code] = TextEditingController(
        text: qOverride.isNotEmpty ? qOverride : defaultQuestion,
      );
      aCtrls[code] = TextEditingController(
        text: aOverride.isNotEmpty ? aOverride : defaultAnswer,
      );
    }

    var dialogOpen = true;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> uploadImage() async {
              if (!dialogOpen) return;
              setStateDialog(() => imageUploading = true);
              final uploaded = await _pickAndUploadFaqImage(node.qKey);
              if (!mounted || !dialogOpen) return;
              setStateDialog(() {
                imageUploading = false;
                if (uploaded != null && uploaded.downloadUrl.isNotEmpty) {
                  imageUrl = uploaded.downloadUrl;
                  imagePath = uploaded.storagePath;
                  imagePreviewUrl = uploaded.downloadUrl;
                  previewBytes = uploaded.bytes;
                }
              });
            }

            Future<void> translateAllLanguages() async {
              if (!dialogOpen || imageUploading || translating) return;
              setStateDialog(() => translating = true);
              final translatedCount = await _autoTranslateMissingLocaleFields(
                locales: locales,
                qCtrls: qCtrls,
                aCtrls: aCtrls,
                overwriteExisting: true,
              );
              if (!mounted || !dialogOpen) return;
              setStateDialog(() => translating = false);
              final messenger = ScaffoldMessenger.maybeOf(context);
              messenger?.showSnackBar(
                SnackBar(
                  content: Text(
                    translatedCount > 0
                        ? t.tf('admin_faq_translate_done', {
                            'count': '$translatedCount',
                          })
                        : t.t('admin_faq_translate_none'),
                  ),
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: Text(t.t('admin_faq_edit_localized_title')),
              content: SizedBox(
                width: 600,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 560),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        t.t('admin_faq_leave_empty_hint'),
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 12),
                      _FaqImageEditorCard(
                        imageUrl: imageUrl,
                        previewUrl: imagePreviewUrl,
                        previewBytes: previewBytes,
                        isUploading: imageUploading,
                        onUpload: uploadImage,
                        onRemove: imageUrl.isEmpty || imageUploading
                            ? null
                            : () => setStateDialog(() {
                                imageUrl = '';
                                imagePath = '';
                                imagePreviewUrl = '';
                                previewBytes = null;
                              }),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: imageUploading || translating
                              ? null
                              : translateAllLanguages,
                          icon: translating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.translate),
                          label: Text(t.t('admin_faq_translate_all_languages')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...locales.map((locale) {
                        final code = locale.languageCode;
                        return _LocaleFaqFields(
                          label: code.toUpperCase(),
                          questionCtrl: qCtrls[code]!,
                          answerCtrl: aCtrls[code]!,
                          initiallyExpanded: code == 'en',
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: imageUploading || translating
                      ? null
                      : () {
                          dialogOpen = false;
                          Navigator.of(ctx).pop(false);
                        },
                  child: Text(t.t('admin_faq_cancel')),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _kFaqGreen),
                  onPressed: imageUploading || translating
                      ? null
                      : () {
                          dialogOpen = false;
                          Navigator.of(ctx).pop(true);
                        },
                  child: Text(t.t('admin_faq_save')),
                ),
              ],
            );
          },
        );
      },
    );
    dialogOpen = false;

    if (ok != true) {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
      return;
    }

    await _autoTranslateMissingLocaleFields(
      locales: locales,
      qCtrls: qCtrls,
      aCtrls: aCtrls,
    );

    final col = _localizedFaqCol;
    if (col == null) return;

    final payload = <String, dynamic>{
      'qKey': node.qKey,
      'aKey': node.aKey,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    var hasOverride = false;

    if (imageUrl.trim().isNotEmpty) {
      payload['imageUrl'] = imageUrl.trim();
      payload['imagePath'] = imagePath.trim();
      hasOverride = true;
    } else if (overrideData != null && overrideData.containsKey('imageUrl')) {
      payload['imageUrl'] = FieldValue.delete();
      payload['imagePath'] = FieldValue.delete();
    }

    for (final locale in locales) {
      final code = locale.languageCode;
      final qText = qCtrls[code]?.text.trim() ?? '';
      final aText = aCtrls[code]?.text.trim() ?? '';
      final qField = 'question_$code';
      final aField = 'answer_$code';
      final defaultQuestion = defaultQuestions[code] ?? '';
      final defaultAnswer = defaultAnswers[code] ?? '';
      final hasQuestionOverride = qText.isNotEmpty && qText != defaultQuestion;
      final hasAnswerOverride = aText.isNotEmpty && aText != defaultAnswer;

      if (hasQuestionOverride) {
        payload[qField] = qText;
        hasOverride = true;
      } else if (overrideData != null && overrideData.containsKey(qField)) {
        payload[qField] = FieldValue.delete();
      }

      if (hasAnswerOverride) {
        payload[aField] = aText;
        hasOverride = true;
      } else if (overrideData != null && overrideData.containsKey(aField)) {
        payload[aField] = FieldValue.delete();
      }
    }

    try {
      if (!hasOverride) {
        if (overrideData != null) {
          await col.doc(node.qKey).delete();
        }
        return;
      }
      await col.doc(node.qKey).set(payload, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      _showError(
        t.tf('admin_faq_error_save_localized', {'error': e.message ?? e.code}),
      );
    } catch (e) {
      _showError(t.tf('admin_faq_error_save_localized', {'error': '$e'}));
    } finally {
      for (final ctrl in qCtrls.values) {
        ctrl.dispose();
      }
      for (final ctrl in aCtrls.values) {
        ctrl.dispose();
      }
    }
  }

  String _overrideValue(
    Map<String, dynamic>? data,
    String field,
    String langCode,
  ) {
    if (data == null) return '';
    final raw = data['${field}_$langCode'];
    final text = raw?.toString().trim() ?? '';
    return text;
  }

  List<_FlatFaqNode> _flattenFaqNodes(
    List<DriverFaqNode> nodes, {
    int depth = 0,
  }) {
    final out = <_FlatFaqNode>[];
    for (final node in nodes) {
      out.add(_FlatFaqNode(node: node, depth: depth));
      if (node.children.isNotEmpty) {
        out.addAll(_flattenFaqNodes(node.children, depth: depth + 1));
      }
    }
    return out;
  }

  List<_InsertOption> _buildInsertOptions(AppLocalizations t) {
    final options = <_InsertOption>[
      _InsertOption(key: _insertAtStart, label: t.t('admin_faq_insert_top')),
      ...DriverFaqKeys.items.map(
        (node) => _InsertOption(key: node.qKey, label: t.t(node.qKey)),
      ),
      _InsertOption(key: _insertAtEnd, label: t.t('admin_faq_insert_end')),
    ];
    return options;
  }

  String _localizedFaqValue(
    Map<String, dynamic>? data,
    String field,
    String langCode,
  ) {
    if (data == null) return '';
    String? pick(String key) {
      final raw = data[key];
      if (raw == null) return null;
      final text = raw.toString().trim();
      return text.isEmpty ? null : text;
    }

    final fallbackKey = _firstLocalizedKey(data, field);

    return pick('${field}_$langCode') ??
        pick('${field}_en') ??
        pick(field) ??
        (fallbackKey != null ? pick(fallbackKey) : null) ??
        '';
  }

  String _storedFaqEditorValue(
    Map<String, dynamic>? data,
    String field,
    String langCode,
  ) {
    final localized = _overrideValue(data, field, langCode);
    if (localized.isNotEmpty) return localized;

    // Preserve older custom FAQs that may only have the base English fields.
    if (langCode == 'en' && data != null) {
      final raw = data[field];
      final text = raw?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String? _firstLocalizedKey(Map<String, dynamic> data, String field) {
    for (final entry in data.entries) {
      if (!entry.key.startsWith('${field}_')) continue;
      final text = entry.value?.toString().trim() ?? '';
      if (text.isNotEmpty) return entry.key;
    }
    return null;
  }

  Future<void> _confirmDelete(String docId) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('admin_faq_delete_title')),
        content: Text(t.t('admin_faq_delete_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.t('admin_faq_cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.t('admin_faq_delete')),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final col = _faqCol;
    if (col == null) return;
    try {
      await col.doc(docId).delete();
    } on FirebaseException catch (e) {
      _showError(
        t.tf('admin_faq_error_delete', {'error': e.message ?? e.code}),
      );
    } catch (e) {
      _showError(t.tf('admin_faq_error_delete', {'error': '$e'}));
    }
  }

  String _localizedFaqText({
    required DriverFaqNode node,
    required Map<String, dynamic>? overrideData,
    required String langCode,
    required AppLocalizations t,
    required bool isQuestion,
  }) {
    final overrideText = _overrideValue(
      overrideData,
      isQuestion ? 'question' : 'answer',
      langCode,
    );
    if (overrideText.isNotEmpty) return overrideText;
    return t.t(isQuestion ? node.qKey : node.aKey);
  }

  Widget _buildCustomFaqsSection(
    CollectionReference<Map<String, dynamic>> col,
  ) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.orderBy('order').snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          final t = AppLocalizations.of(context);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(t.t('admin_faq_no_custom')),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = docs[i];
            final data = d.data();
            final langCode = Localizations.localeOf(context).languageCode;
            final t = AppLocalizations.of(context);
            final question = _localizedFaqValue(data, 'question', langCode);
            final answer = _localizedFaqValue(data, 'answer', langCode);
            final imageUrl = (data['imageUrl'] ?? '').toString().trim();
            final order = (data['order'] as num?)?.toInt();

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kFaqCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kFaqCardBorder),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 680;
                  final leading = Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kFaqCardBorder),
                    ),
                    child: const Icon(Icons.quiz_outlined, color: _kFaqMuted),
                  );

                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.isEmpty ? t.t('admin_faq_untitled') : question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: _kFaqText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        answer.isEmpty ? t.t('admin_faq_no_answer') : answer,
                        maxLines: compact ? 4 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _kFaqSubText,
                          height: 1.35,
                          fontSize: 13,
                        ),
                      ),
                      if (imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _FaqImageBadge(url: imageUrl),
                      ],
                    ],
                  );

                  final actions = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FaqActionButton(
                        label: t.t('admin_faq_edit'),
                        icon: Icons.edit_outlined,
                        onPressed: () => _openFaqEditor(
                          docId: d.id,
                          data: data,
                          order: order,
                        ),
                      ),
                      _FaqActionButton(
                        label: t.t('admin_faq_delete'),
                        icon: Icons.delete_outline,
                        danger: true,
                        onPressed: () => _confirmDelete(d.id),
                      ),
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
                            Expanded(child: content),
                          ],
                        ),
                        const SizedBox(height: 10),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leading,
                      const SizedBox(width: 12),
                      Expanded(child: content),
                      const SizedBox(width: 12),
                      actions,
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocalizedFaqsSection() {
    final col = _localizedFaqCol;
    if (col == null) {
      return Center(
        child: Text(AppLocalizations.of(context).t('admin_faq_must_login')),
      );
    }

    final flatItems = _flattenFaqNodes(DriverFaqKeys.items);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final overrides = <String, Map<String, dynamic>>{};
        for (final d in docs) {
          overrides[d.id] = d.data();
        }

        final langCode = Localizations.localeOf(context).languageCode;
        final t = AppLocalizations.of(context);

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: flatItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final item = flatItems[i];
            final node = item.node;
            final overrideData = overrides[node.qKey];
            final isHidden = overrideData?['hidden'] == true;
            final question = _localizedFaqText(
              node: node,
              overrideData: overrideData,
              langCode: langCode,
              t: t,
              isQuestion: true,
            );
            final answer = _localizedFaqText(
              node: node,
              overrideData: overrideData,
              langCode: langCode,
              t: t,
              isQuestion: false,
            );
            final imageUrl = (overrideData?['imageUrl'] ?? '')
                .toString()
                .trim();

            return Container(
              margin: EdgeInsets.only(left: item.depth * 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kFaqCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kFaqCardBorder),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 740;
                  final leading = Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kFaqCardBorder),
                    ),
                    child: const Icon(
                      Icons.language_outlined,
                      color: _kFaqMuted,
                    ),
                  );

                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: _kFaqText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        answer,
                        maxLines: compact ? 4 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _kFaqSubText,
                          height: 1.35,
                          fontSize: 13,
                        ),
                      ),
                      if (imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _FaqImageBadge(url: imageUrl),
                      ],
                    ],
                  );

                  final actions = Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _kFaqCardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.t('admin_faq_hide'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _kFaqMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              height: 20,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Switch(
                                  value: isHidden,
                                  onChanged: (value) => _setHiddenForNode(
                                    node.qKey,
                                    value,
                                    overrideData,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _FaqActionButton(
                        label: t.t('admin_faq_edit'),
                        icon: Icons.edit_outlined,
                        onPressed: () => _openLocalizedFaqEditor(
                          node: node,
                          overrideData: overrideData,
                        ),
                      ),
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
                            Expanded(child: content),
                          ],
                        ),
                        const SizedBox(height: 10),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      leading,
                      const SizedBox(width: 12),
                      Expanded(child: content),
                      const SizedBox(width: 12),
                      actions,
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setHiddenForNode(
    String qKey,
    bool hidden,
    Map<String, dynamic>? overrideData,
  ) async {
    final col = _localizedFaqCol;
    if (col == null) return;
    final doc = col.doc(qKey);

    if (hidden) {
      try {
        await doc.set({
          'hidden': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } on FirebaseException catch (e) {
        _showError(
          AppLocalizations.of(context).tf('admin_faq_error_update_visibility', {
            'error': e.message ?? e.code,
          }),
        );
      } catch (e) {
        _showError(
          AppLocalizations.of(
            context,
          ).tf('admin_faq_error_update_visibility', {'error': '$e'}),
        );
      }
      return;
    }

    if (overrideData == null) {
      return;
    }

    try {
      await doc.set({
        'hidden': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      _showError(
        AppLocalizations.of(context).tf('admin_faq_error_update_visibility', {
          'error': e.message ?? e.code,
        }),
      );
    } catch (e) {
      _showError(
        AppLocalizations.of(
          context,
        ).tf('admin_faq_error_update_visibility', {'error': '$e'}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final col = _faqCol;
    if (col == null) {
      return Center(child: Text(t.t('admin_faq_must_login')));
    }
    final isNarrow = MediaQuery.of(context).size.width < 700;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              const Icon(Icons.help_outline, size: 22, color: _kFaqGreen),
              Text(
                t.t('admin_faq_page_title'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _kFaqText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isNarrow)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openFaqEditor(),
                icon: const Icon(Icons.add),
                label: Text(t.t('admin_faq_add_custom')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kFaqGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _openFaqEditor(),
                icon: const Icon(Icons.add),
                label: Text(t.t('admin_faq_add_custom')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kFaqGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                _FaqSectionCard(
                  title: t.t('admin_faq_section_localized_title'),
                  subtitle: t.t('admin_faq_section_localized_subtitle'),
                  icon: Icons.language_outlined,
                  child: _buildLocalizedFaqsSection(),
                ),
                const SizedBox(height: 16),
                _FaqSectionCard(
                  title: t.t('admin_faq_section_custom_title'),
                  subtitle: t.t('admin_faq_section_custom_subtitle'),
                  icon: Icons.quiz_outlined,
                  child: _buildCustomFaqsSection(col),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _FaqSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kFaqCardBorder),
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
              Icon(icon, color: _kFaqGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _kFaqText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: _kFaqMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFD9DED8)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FaqActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool danger;

  const _FaqActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE11D48) : _kFaqGreen;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FaqImageEditorCard extends StatelessWidget {
  final String imageUrl;
  final String previewUrl;
  final Uint8List? previewBytes;
  final bool isUploading;
  final VoidCallback onUpload;
  final VoidCallback? onRemove;

  const _FaqImageEditorCard({
    required this.imageUrl,
    required this.previewUrl,
    required this.previewBytes,
    required this.isUploading,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kFaqCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sample image',
            style: TextStyle(fontWeight: FontWeight.w900, color: _kFaqText),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload one optional image that drivers can view inside this FAQ.',
            style: TextStyle(color: _kFaqMuted, fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 12),
          if (imageUrl.isNotEmpty)
            _FaqPreviewFrame(
              child: previewBytes != null
                  ? _FaqZoomableImage(
                      child: Image.memory(previewBytes!, fit: BoxFit.contain),
                    )
                  : (previewUrl.isNotEmpty)
                  ? _FaqZoomableImage(child: buildWebImagePreview(previewUrl))
                  : (imageUrl.startsWith('http://') ||
                        imageUrl.startsWith('https://'))
                  ? _FaqZoomableImage(child: buildWebImagePreview(imageUrl))
                  : const Center(
                      child: Text(
                        'Could not load image preview.',
                        style: TextStyle(
                          color: _kFaqMuted,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kFaqCardBorder),
              ),
              alignment: Alignment.center,
              child: const Text(
                'No sample image selected.',
                style: TextStyle(
                  color: _kFaqMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isUploading ? null : onUpload,
                style: FilledButton.styleFrom(backgroundColor: _kFaqGreen),
                icon: isUploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_outlined),
                label: Text(
                  imageUrl.isEmpty ? 'Upload image' : 'Replace image',
                ),
              ),
              if (onRemove != null)
                OutlinedButton.icon(
                  onPressed: isUploading ? null : onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove image'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqPreviewFrame extends StatelessWidget {
  final Widget child;

  const _FaqPreviewFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
    );
  }
}

class _FaqZoomableImage extends StatelessWidget {
  final Widget child;

  const _FaqZoomableImage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _FaqImageBadge extends StatelessWidget {
  final String url;

  const _FaqImageBadge({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kFaqCardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined, size: 16, color: _kFaqGreen),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Sample image attached',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _kFaqMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
