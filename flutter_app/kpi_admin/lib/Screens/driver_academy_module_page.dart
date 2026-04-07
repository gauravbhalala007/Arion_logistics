import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';

const Color _kAcademyBg = Color(0xFFF3F6F7);
const Color _kAcademyText = Color(0xFF1F2937);
const Color _kAcademyMuted = Color(0xFF6B7280);
const Color _kAcademyPrimary = Color(0xFF1D7F5A);
const Color _kAcademyBlue = Color(0xFF1788C3);

class DriverAcademyModulePage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final String categoryId;
  final String fallbackTitle;

  const DriverAcademyModulePage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.categoryId,
    required this.fallbackTitle,
  });

  @override
  State<DriverAcademyModulePage> createState() =>
      _DriverAcademyModulePageState();
}

class _DriverAcademyModulePageState extends State<DriverAcademyModulePage> {
  bool _loading = true;
  bool _saving = false;
  bool _completed = false;
  int _stepIndex = 0;

  String _title = '';
  String _subtitle = '';
  List<_ModuleItem> _allItems = const [];
  List<_ModuleItem> _steps = const [];
  List<_ModuleItem> _subcategories = const [];
  String _selectedSubcategoryId = '';
  final Map<String, String> _answers = <String, String>{};
  final Map<String, Future<String?>> _mediaUrlFutureCache =
      <String, Future<String?>>{};

  DocumentReference<Map<String, dynamic>> get _driverDoc => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid.trim())
      .collection('drivers')
      .doc(widget.driverTransporterId.trim().toUpperCase())
      .collection('academy_tests')
      .doc(widget.categoryId);

  DocumentReference<Map<String, dynamic>> get _masterDoc => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid.trim())
      .collection('academy_tests')
      .doc(widget.categoryId);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final driverSnap = await _driverDoc.get();
      var data = driverSnap.data() ?? const <String, dynamic>{};

      List<_ModuleItem> parsed = _parseItems(data['questions']);
      if (parsed.isEmpty) parsed = _parseItems(data['steps']);
      final driverParsed = parsed;

      final masterSnap = await _masterDoc.get();
      final masterData = masterSnap.data() ?? const <String, dynamic>{};
      List<_ModuleItem> parsedFromMaster = _parseItems(masterData['questions']);
      if (parsedFromMaster.isEmpty) {
        parsedFromMaster = _parseItems(masterData['steps']);
      }
      if (parsedFromMaster.isEmpty) {
        final qSnap = await _masterDoc
            .collection('questions')
            .orderBy('order')
            .get();
        parsedFromMaster = _parseItems(
          qSnap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList(),
        );
      }

      final masterHasSubcategories = _extractRootSubcategories(
        parsedFromMaster,
      ).isNotEmpty;
      final driverHasSubcategories = _extractRootSubcategories(
        driverParsed,
      ).isNotEmpty;

      if (parsedFromMaster.isNotEmpty &&
          (driverParsed.isEmpty ||
              (masterHasSubcategories && !driverHasSubcategories))) {
        parsed = parsedFromMaster;
      }

      // Keep module metadata from master when available.
      if (masterData.isNotEmpty) {
        data = {...masterData, ...data};
      }

      if (parsed.isNotEmpty &&
          (driverParsed.isEmpty ||
              (masterHasSubcategories && !driverHasSubcategories))) {
        await _driverDoc.set({
          'scope': 'driver',
          'dspUid': widget.dspUid.trim(),
          'driverTransporterId': widget.driverTransporterId
              .trim()
              .toUpperCase(),
          'testId': widget.categoryId,
          'questionCount': parsed.length,
          'questions': parsed.map((e) => e.toPayload()).toList(),
          'syncedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final locale = WidgetsBinding
          .instance
          .platformDispatcher
          .locale
          .languageCode
          .toLowerCase();
      final title = _localizedValue(
        data,
        'title',
        locale,
        fallback: widget.fallbackTitle,
      );
      final subtitle = _localizedValue(data, 'subtitle', locale, fallback: '');
      final subcategories = _extractRootSubcategories(parsed);
      final savedStep = (data['activity1Step'] as num?)?.toInt() ?? 0;
      final savedCompleted = data['activity1Completed'] == true;

      final hasSubcategoryMode = subcategories.isNotEmpty;
      String selectedSubcategoryId = '';
      List<_ModuleItem> flow = const [];
      if (hasSubcategoryMode) {
        // Always land on subcategory chooser first when subcategories exist.
        // This prevents auto-opening saved content directly.
        selectedSubcategoryId = '';
        flow = const [];
      } else {
        flow = _buildFlow(parsed);
      }

      if (!mounted) return;
      setState(() {
        _title = title;
        _subtitle = subtitle;
        _allItems = parsed;
        _steps = flow;
        _subcategories = subcategories;
        _selectedSubcategoryId = selectedSubcategoryId;
        _stepIndex = hasSubcategoryMode
            ? 0
            : (flow.isEmpty ? 0 : savedStep.clamp(0, flow.length - 1));
        _completed = hasSubcategoryMode
            ? false
            : (flow.isNotEmpty && savedCompleted);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allItems = const [];
        _steps = const [];
        _subcategories = const [];
        _selectedSubcategoryId = '';
        _loading = false;
      });
    }
  }

  String _localizedValue(
    Map<String, dynamic> data,
    String key,
    String locale, {
    required String fallback,
  }) {
    final direct = (data['${key}_$locale'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;
    final en = (data['${key}_en'] ?? '').toString().trim();
    if (en.isNotEmpty) return en;
    final plain = (data[key] ?? '').toString().trim();
    if (plain.isNotEmpty) return plain;
    return fallback;
  }

  List<_ModuleItem> _parseItems(dynamic raw) {
    if (raw is! List) return const [];
    final out = <_ModuleItem>[];
    for (var i = 0; i < raw.length; i++) {
      final rowRaw = raw[i];
      if (rowRaw is! Map) continue;
      final row = rowRaw.cast<String, dynamic>();
      out.add(_ModuleItem.fromMap(row, fallbackIndex: i));
    }
    out.sort((a, b) => a.order.compareTo(b.order));
    return out;
  }

  List<_ModuleItem> _buildFlow(List<_ModuleItem> source) {
    if (source.isEmpty) return const [];

    final roots = source.where((s) => s.parentId.trim().isEmpty).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final byParent = <String, List<_ModuleItem>>{};
    for (final item in source.where((s) => s.parentId.trim().isNotEmpty)) {
      byParent.putIfAbsent(item.parentId, () => <_ModuleItem>[]).add(item);
    }
    for (final list in byParent.values) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }

    final flow = <_ModuleItem>[];
    for (final root in roots) {
      if (root.isSubcategory) {
        // Subcategory is structural only, not a playable training step.
        final children = byParent[root.id] ?? const <_ModuleItem>[];
        flow.addAll(children.where((c) => c.isPlayable));
      } else if (root.isPlayable) {
        flow.add(root);
      }
    }

    // Keep orphan playable items reachable.
    final known = flow.map((e) => e.id).toSet();
    final orphans =
        source.where((s) => s.isPlayable && !known.contains(s.id)).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    flow.addAll(orphans);
    return flow;
  }

  List<_ModuleItem> _extractRootSubcategories(List<_ModuleItem> source) {
    final roots =
        source
            .where((item) => item.parentId.trim().isEmpty && item.isSubcategory)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    return roots;
  }

  List<_ModuleItem> _buildSubcategoryFlow(
    List<_ModuleItem> source,
    String subcategoryId,
  ) {
    final target = subcategoryId.trim();
    if (target.isEmpty) return const [];
    final flow =
        source
            .where((item) => item.parentId.trim() == target && item.isPlayable)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    return flow;
  }

  Future<void> _openSubcategory(_ModuleItem subcategory) async {
    final flow = _buildSubcategoryFlow(_allItems, subcategory.id);
    if (flow.isEmpty) {
      _showToast('This subcategory has no playable steps yet.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _selectedSubcategoryId = subcategory.id;
      _steps = flow;
      _stepIndex = 0;
      _completed = false;
    });
    await _saveProgress(completed: false);
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveProgress({required bool completed}) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _driverDoc.set({
        'scope': 'driver',
        'dspUid': widget.dspUid.trim(),
        'driverTransporterId': widget.driverTransporterId.trim().toUpperCase(),
        'testId': widget.categoryId,
        'testTitle': _title,
        'activity1SubcategoryId': _selectedSubcategoryId,
        'activity1Step': _stepIndex,
        'activity1Completed': completed,
        if (completed) 'activity1CompletedAt': FieldValue.serverTimestamp(),
        if (completed) 'lastPassed': true,
        if (completed) 'passedEver': true,
        if (completed) 'lastAttemptAt': FieldValue.serverTimestamp(),
        if (completed) 'attempts': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // ignore write errors in UI flow
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _onNext() async {
    if (_steps.isEmpty || _completed || _saving) return;
    if (_stepIndex >= _steps.length - 1) {
      setState(() => _completed = true);
      await _saveProgress(completed: true);
      return;
    }

    setState(() => _stepIndex += 1);
    await _saveProgress(completed: false);
  }

  Future<void> _onPrevious() async {
    if (_steps.isEmpty || _saving || _stepIndex <= 0) return;
    setState(() {
      _completed = false;
      _stepIndex -= 1;
    });
    await _saveProgress(completed: false);
  }

  Future<void> _openVideo(String url) async {
    final resolved = await _resolvedMediaFuture(url);
    if (resolved == null || resolved.trim().isEmpty) {
      _showToast('Unable to open media URL.');
      return;
    }
    final uri = Uri.tryParse(resolved.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<String?> _resolvedMediaFuture(String raw) {
    final key = raw.trim();
    if (key.isEmpty) return Future.value(null);
    return _mediaUrlFutureCache.putIfAbsent(key, () => _resolveMediaUrl(key));
  }

  Future<String?> _resolveMediaUrl(String raw) async {
    final value = raw.trim();
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
      // fallthrough to null
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    final title = _title.trim().isEmpty ? widget.fallbackTitle : _title.trim();
    final hasSubcategoryMode = _subcategories.isNotEmpty;
    final showingSubcategoryChooser =
        hasSubcategoryMode && _selectedSubcategoryId.isEmpty;

    if (_loading) {
      return const Scaffold(
        backgroundColor: _kAcademyBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (showingSubcategoryChooser) {
      return Scaffold(
        backgroundColor: _kAcademyBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _kAcademyText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.builder(
                    itemCount: _subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = _subcategories[index];
                      final label = subcategory.textFor(locale).trim();
                      final subFlow = _buildSubcategoryFlow(
                        _allItems,
                        subcategory.id,
                      );
                      final subtitle = subFlow.isEmpty
                          ? 'No content/questions yet in this subcategory.'
                          : '${subFlow.length} steps available';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SubcategoryCard(
                          title: label.isEmpty
                              ? 'Subcategory #${subcategory.order}'
                              : label,
                          subtitle: subtitle,
                          actionLabel: subFlow.isEmpty
                              ? 'No steps yet'
                              : 'Resume',
                          actionEnabled: subFlow.isNotEmpty,
                          onTap: () => _openSubcategory(subcategory),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_steps.isEmpty) {
      if (_subcategories.isNotEmpty) {
        return Scaffold(
          backgroundColor: _kAcademyBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          setState(() {
                            _selectedSubcategoryId = '';
                            _steps = const [];
                            _stepIndex = 0;
                            _completed = false;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _kAcademyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDDE3E7)),
                        ),
                        child: const Text(
                          'No content/questions in this subcategory yet.',
                          style: TextStyle(
                            color: _kAcademyMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: _kAcademyBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _kAcademyText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDDE3E7)),
                  ),
                  child: const Text(
                    'No training steps configured yet. Ask admin to add content in DA Academy.',
                    style: TextStyle(
                      color: _kAcademyMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final safeIndex = _stepIndex.clamp(0, _steps.length - 1);
    final step = _steps[safeIndex];
    final selectedOptionId = _answers[step.id];
    final canContinue = !step.isQuestion || selectedOptionId != null;

    return Scaffold(
      backgroundColor: _kAcademyBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            children: [
              Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      if (_subcategories.isNotEmpty &&
                          _selectedSubcategoryId.isNotEmpty) {
                        setState(() {
                          _selectedSubcategoryId = '';
                          _steps = const [];
                          _stepIndex = 0;
                          _completed = false;
                        });
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22 / 1.1,
                            fontWeight: FontWeight.w800,
                            color: _kAcademyText,
                          ),
                        ),
                        if (_subtitle.trim().isNotEmpty)
                          Text(
                            _subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _kAcademyMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    t.tf('delivery_training_step_of_total', {
                      'current':
                          '${_completed ? _steps.length : (_stepIndex + 1)}',
                      'total': '${_steps.length}',
                    }),
                    style: const TextStyle(
                      color: _kAcademyMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _completed ? 1 : ((_stepIndex + 1) / _steps.length),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    _kAcademyPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFDDE3E7),
                      width: 1.3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      children: [
                        if (step.mediaType == 'image' &&
                            step.mediaUrl.isNotEmpty)
                          FutureBuilder<String?>(
                            future: _resolvedMediaFuture(step.mediaUrl),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  ),
                                );
                              }
                              final url = snapshot.data?.trim() ?? '';
                              if (url.isEmpty) {
                                return Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 42,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                );
                              }
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  url,
                                  height: 220,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          height: 220,
                                          color: const Color(0xFFF3F4F6),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 220,
                                    color: const Color(0xFFF3F4F6),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      size: 42,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        if (step.mediaType == 'video' &&
                            step.mediaUrl.isNotEmpty)
                          InkWell(
                            onTap: () => _openVideo(step.mediaUrl),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFDDE3E7),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 170,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111827),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: Colors.white,
                                      size: 64,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Tap to play video',
                                    style: TextStyle(
                                      color: _kAcademyText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (step.mediaType != 'none' &&
                            step.mediaUrl.isNotEmpty)
                          const SizedBox(height: 12),
                        Text(
                          step.textFor(locale),
                          style: const TextStyle(
                            color: _kAcademyText,
                            fontSize: 32 / 2,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        if (step.isQuestion) ...[
                          const SizedBox(height: 16),
                          ...step.options.map((option) {
                            final selected = option.id == selectedOptionId;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: _saving
                                    ? null
                                    : () {
                                        setState(() {
                                          _answers[step.id] = option.id;
                                        });
                                      },
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFE7F3FF)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(0xFF1788C3)
                                          : const Color(0xFFDDE3E7),
                                      width: selected ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selected
                                                ? const Color(0xFF1788C3)
                                                : const Color(0xFF9CA3AF),
                                            width: 2,
                                          ),
                                        ),
                                        child: selected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: Color(0xFF1788C3),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          option.textFor(locale),
                                          style: const TextStyle(
                                            color: _kAcademyText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: (!_saving && _stepIndex > 0)
                                      ? _onPrevious
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _kAcademyText,
                                    disabledForegroundColor: const Color(
                                      0xFF9CA3AF,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const Text(
                                    'Previous',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: (!_saving && canContinue)
                                      ? _onNext
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _kAcademyBlue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFF9CA3AF,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: Text(
                                    step.buttonLabel.trim().isNotEmpty
                                        ? step.buttonLabel.trim()
                                        : t.t('delivery_training_next'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}

class _SubcategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool actionEnabled;
  final VoidCallback onTap;

  const _SubcategoryCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3E7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_copy_outlined,
                  color: Color(0xFF1788C3),
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _kAcademyText,
                        fontWeight: FontWeight.w800,
                        fontSize: 36 / 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _kAcademyMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: actionEnabled ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAcademyPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFA5B4C3),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: Text(
                actionLabel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleItem {
  final String id;
  final int order;
  final String parentId;
  final String type;
  final Map<String, String> localizedText;
  final String mediaType;
  final String mediaUrl;
  final String buttonLabel;
  final List<_ModuleOption> options;

  const _ModuleItem({
    required this.id,
    required this.order,
    required this.parentId,
    required this.type,
    required this.localizedText,
    required this.mediaType,
    required this.mediaUrl,
    required this.buttonLabel,
    required this.options,
  });

  factory _ModuleItem.fromMap(
    Map<String, dynamic> data, {
    required int fallbackIndex,
  }) {
    final idRaw = (data['id'] ?? '').toString().trim();
    final typeRaw = (data['stepType'] ?? data['type'] ?? 'content')
        .toString()
        .trim()
        .toLowerCase();
    final normalizedType = switch (typeRaw) {
      'question' => 'question',
      'subcategory' => 'subcategory',
      _ => 'content',
    };

    final localizedText = <String, String>{};
    for (final entry in data.entries) {
      if (!entry.key.startsWith('statement_')) continue;
      final code = entry.key
          .substring('statement_'.length)
          .trim()
          .toLowerCase();
      if (code.isEmpty) continue;
      final value = (entry.value ?? '').toString().trim();
      if (value.isNotEmpty) localizedText[code] = value;
    }
    final fallback = (data['statement'] ?? '').toString().trim();
    if (fallback.isNotEmpty && !localizedText.containsKey('en')) {
      localizedText['en'] = fallback;
    }

    final options = <_ModuleOption>[];
    if (normalizedType == 'question' && data['options'] is List) {
      final rawOptions = data['options'] as List;
      for (var i = 0; i < rawOptions.length; i++) {
        final row = rawOptions[i];
        if (row is! Map) continue;
        options.add(
          _ModuleOption.fromMap(row.cast<String, dynamic>(), fallbackIndex: i),
        );
      }
    }
    options.sort((a, b) => a.order.compareTo(b.order));

    final mediaTypeRaw = (data['mediaType'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final mediaUrl = _firstNonEmpty([
      (data['mediaUrl'] ?? '').toString().trim(),
      (data['imageUrl'] ?? '').toString().trim(),
      (data['videoUrl'] ?? '').toString().trim(),
      (data['mediaPath'] ?? '').toString().trim(),
      (data['url'] ?? '').toString().trim(),
    ]);
    final mediaType = (mediaTypeRaw == 'image' || mediaTypeRaw == 'video')
        ? mediaTypeRaw
        : _inferMediaTypeFromUrl(mediaUrl);

    return _ModuleItem(
      id: idRaw.isEmpty ? 'step_${fallbackIndex + 1}' : idRaw,
      order: (data['order'] as num?)?.toInt() ?? (fallbackIndex + 1) * 10,
      parentId: (data['parentId'] ?? '').toString().trim(),
      type: normalizedType,
      localizedText: localizedText,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      buttonLabel: (data['buttonLabel'] ?? '').toString().trim(),
      options: options,
    );
  }

  bool get isQuestion => type == 'question' && options.isNotEmpty;
  bool get isSubcategory => type == 'subcategory';
  bool get isPlayable => type == 'content' || isQuestion;

  _ModuleItem asSectionHeading() {
    return _ModuleItem(
      id: 'section_$id',
      order: order,
      parentId: '',
      type: 'content',
      localizedText: localizedText,
      mediaType: 'none',
      mediaUrl: '',
      buttonLabel: 'Next',
      options: const [],
    );
  }

  String textFor(String locale) {
    final code = locale.trim().toLowerCase();
    final direct = (localizedText[code] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final en = (localizedText['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    for (final value in localizedText.values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'id': id,
      'order': order,
      'parentId': parentId,
      'stepType': type,
      'statement': textFor('en'),
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'buttonLabel': buttonLabel,
      'options': options.map((o) => o.toPayload()).toList(),
    };
    if (mediaType == 'image' && mediaUrl.isNotEmpty) {
      payload['imageUrl'] = mediaUrl;
    }
    if (mediaType == 'video' && mediaUrl.isNotEmpty) {
      payload['videoUrl'] = mediaUrl;
    }
    for (final entry in localizedText.entries) {
      final value = entry.value.trim();
      if (value.isNotEmpty) {
        payload['statement_${entry.key}'] = value;
      }
    }
    return payload;
  }

  static String _firstNonEmpty(List<String> values) {
    for (final raw in values) {
      final value = raw.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  static String _inferMediaTypeFromUrl(String raw) {
    final url = raw.trim().toLowerCase();
    if (url.isEmpty) return 'none';
    const videoHints = <String>[
      '.mp4',
      '.mov',
      '.m4v',
      '.webm',
      '.m3u8',
      'youtube.com',
      'youtu.be',
      'vimeo.com',
    ];
    for (final hint in videoHints) {
      if (url.contains(hint)) return 'video';
    }
    return 'image';
  }
}

class _ModuleOption {
  final String id;
  final int order;
  final Map<String, String> localizedText;

  const _ModuleOption({
    required this.id,
    required this.order,
    required this.localizedText,
  });

  factory _ModuleOption.fromMap(
    Map<String, dynamic> data, {
    required int fallbackIndex,
  }) {
    final localizedText = <String, String>{};
    for (final entry in data.entries) {
      if (!entry.key.startsWith('text_')) continue;
      final code = entry.key.substring('text_'.length).trim().toLowerCase();
      if (code.isEmpty) continue;
      final value = (entry.value ?? '').toString().trim();
      if (value.isNotEmpty) localizedText[code] = value;
    }
    final fallback = (data['text'] ?? '').toString().trim();
    if (fallback.isNotEmpty && !localizedText.containsKey('en')) {
      localizedText['en'] = fallback;
    }

    return _ModuleOption(
      id: (data['id'] ?? '').toString().trim().isEmpty
          ? String.fromCharCode(97 + fallbackIndex)
          : (data['id'] ?? '').toString().trim(),
      order: (data['order'] as num?)?.toInt() ?? (fallbackIndex + 1),
      localizedText: localizedText,
    );
  }

  String textFor(String locale) {
    final code = locale.trim().toLowerCase();
    final direct = (localizedText[code] ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final en = (localizedText['en'] ?? '').trim();
    if (en.isNotEmpty) return en;
    for (final value in localizedText.values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'id': id,
      'order': order,
      'text': textFor('en'),
    };
    for (final entry in localizedText.entries) {
      final value = entry.value.trim();
      if (value.isNotEmpty) {
        payload['text_${entry.key}'] = value;
      }
    }
    return payload;
  }
}
