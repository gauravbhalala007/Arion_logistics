// lib/Screens/driver_faq_training_page.dart
//
// FAQ Training — driver-side quiz built on the existing FAQ data
// (`users/{dspUid}/faqs`). For every FAQ entry the driver sees:
//   1. An "Explanation" card with the original question + answer.
//   2. A "Quick check" card asking "Is this statement correct?"
//      with True/False buttons. The statement is the FAQ answer
//      itself, so the right response is "Correct".
//
// Progress is stored under
//   users/{dspUid}/drivers/{tid}/faq_training/{YYYY-MM-DD}
// so the dispatcher can see who completed the training when.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_button_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class DriverFaqTrainingPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverFaqTrainingPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverFaqTrainingPage> createState() => _DriverFaqTrainingPageState();
}

enum _Phase { explanation, test, feedback, summary }

class _Card {
  final String id;
  final String question;
  final String answer;
  const _Card({
    required this.id,
    required this.question,
    required this.answer,
  });
}

class _DriverFaqTrainingPageState extends State<DriverFaqTrainingPage> {
  List<_Card> _cards = const [];
  bool _loading = true;

  int _index = 0;
  _Phase _phase = _Phase.explanation;
  bool? _lastWasCorrect; // for feedback phase
  int _correct = 0;
  // Card IDs the driver answered correctly on the first try.
  final Set<String> _firstTryCorrect = <String>{};
  // Card IDs already attempted at least once (to score only first attempts).
  final Set<String> _attempted = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid.trim())
          .collection('faqs')
          .orderBy('order')
          .get();

      final lang = WidgetsBinding
          .instance
          .platformDispatcher
          .locale
          .languageCode
          .toLowerCase();

      final cards = <_Card>[];
      for (final d in snap.docs) {
        final data = d.data();
        final q = _localized(data, 'question', lang);
        final a = _localized(data, 'answer', lang);
        if (q.isEmpty || a.isEmpty) continue;
        cards.add(_Card(id: d.id, question: q, answer: a));
      }
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cards = const [];
        _loading = false;
      });
    }
  }

  String _localized(Map<String, dynamic> data, String key, String lang) {
    final direct = (data['${key}_$lang'] ?? '').toString().trim();
    if (direct.isNotEmpty) return direct;
    final en = (data['${key}_en'] ?? '').toString().trim();
    if (en.isNotEmpty) return en;
    final plain = (data[key] ?? '').toString().trim();
    return plain;
  }

  void _onUnderstood() {
    setState(() => _phase = _Phase.test);
  }

  void _onAnswer(bool said) {
    final card = _cards[_index];
    final firstAttempt = !_attempted.contains(card.id);
    _attempted.add(card.id);

    // The FAQ answer IS the truth; the right response is therefore "true".
    final correct = said == true;
    if (correct && firstAttempt) {
      _firstTryCorrect.add(card.id);
      _correct = _firstTryCorrect.length;
    }
    setState(() {
      _phase = _Phase.feedback;
      _lastWasCorrect = correct;
    });
  }

  void _retryThisCard() {
    setState(() {
      _phase = _Phase.explanation;
      _lastWasCorrect = null;
    });
  }

  void _next() {
    if (_index + 1 >= _cards.length) {
      _saveProgress();
      setState(() => _phase = _Phase.summary);
      return;
    }
    setState(() {
      _index += 1;
      _phase = _Phase.explanation;
      _lastWasCorrect = null;
    });
  }

  Future<void> _saveProgress() async {
    final now = DateTime.now();
    final id =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.dspUid.trim())
          .collection('drivers')
          .doc(widget.driverTransporterId.trim().toUpperCase())
          .collection('faq_training')
          .doc(id)
          .set({
            'completedAt': FieldValue.serverTimestamp(),
            'total': _cards.length,
            'correct': _correct,
            'cardIds': _cards.map((c) => c.id).toList(),
          }, SetOptions(merge: true));
    } catch (_) {
      // Persistence is best-effort — UI never blocks on it.
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _phase = _Phase.explanation;
      _lastWasCorrect = null;
      _correct = 0;
      _firstTryCorrect.clear();
      _attempted.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: _loading
            ? Center(child: Text(t.t('faq_training_loading')))
            : _cards.isEmpty
                ? _EmptyState(onBack: widget.onBack)
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _Header(
                          progress: '${_index + 1} / ${_cards.length}',
                          showProgress: _phase != _Phase.summary,
                          onBack: widget.onBack,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_phase != _Phase.summary)
                          _ProgressBar(
                            value: (_index + 1) / _cards.length,
                          ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(child: _buildBody(t)),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations t) {
    switch (_phase) {
      case _Phase.explanation:
        return _ExplanationCard(
          card: _cards[_index],
          onUnderstood: _onUnderstood,
        );
      case _Phase.test:
        return _TestCard(
          card: _cards[_index],
          onPick: _onAnswer,
        );
      case _Phase.feedback:
        return _FeedbackCard(
          correct: _lastWasCorrect ?? false,
          onRetry: _retryThisCard,
          onNext: _next,
        );
      case _Phase.summary:
        return _SummaryCard(
          correct: _correct,
          total: _cards.length,
          onRetake: _restart,
          onClose: widget.onBack,
        );
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Header + progress
// ════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final String progress;
  final bool showProgress;
  final VoidCallback onBack;
  const _Header({
    required this.progress,
    required this.showProgress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.t('faq_training_title'),
                style: AppTypography.title2.copyWith(
                  color: AppColors.codriverGraphite,
                ),
              ),
              Text(
                t.t('faq_training_subtitle'),
                style: AppTypography.footnote.copyWith(
                  color: AppColors.labelSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        if (showProgress)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              progress,
              style: AppTypography.caption1.copyWith(
                color: AppColors.codriverDeep,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: AppColors.separatorLight.withOpacity(0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(
          AppColors.codriverGreen,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            shape: BoxShape.circle,
            boxShadow: AppElevation.level1,
            border: Border.all(
              color: AppColors.separatorLight.withOpacity(0.4),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 18, color: AppColors.codriverGraphite),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Phase 1 — Explanation
// ════════════════════════════════════════════════════════════════════════════

class _ExplanationCard extends StatelessWidget {
  final _Card card;
  final VoidCallback onUnderstood;
  const _ExplanationCard({required this.card, required this.onUnderstood});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppElevation.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseChip(
            icon: Icons.menu_book_rounded,
            label: t.t('faq_training_explanation_label'),
            color: AppColors.codriverGreen,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            card.question,
            style: AppTypography.title3.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                card.answer,
                style: AppTypography.body.copyWith(
                  color: AppColors.codriverGraphite,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: AppButtonStyle.of(AppButtonVariant.primary),
              onPressed: onUnderstood,
              icon: const Icon(Icons.check_rounded),
              label: Text(t.t('faq_training_understood_btn')),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Phase 2 — Test (true/false)
// ════════════════════════════════════════════════════════════════════════════

class _TestCard extends StatelessWidget {
  final _Card card;
  final ValueChanged<bool> onPick;
  const _TestCard({required this.card, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppElevation.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhaseChip(
            icon: Icons.fact_check_rounded,
            label: t.t('faq_training_test_label'),
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.t('faq_training_test_prompt'),
            style: AppTypography.title3.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.separatorLight.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  '"${card.answer}"',
                  style: AppTypography.body.copyWith(
                    color: AppColors.codriverGraphite,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: AppButtonStyle.of(AppButtonVariant.destructive),
                  onPressed: () => onPick(false),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(t.t('faq_training_btn_false')),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  style: AppButtonStyle.of(AppButtonVariant.primary),
                  onPressed: () => onPick(true),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(t.t('faq_training_btn_true')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Phase 3 — Feedback
// ════════════════════════════════════════════════════════════════════════════

class _FeedbackCard extends StatelessWidget {
  final bool correct;
  final VoidCallback onRetry;
  final VoidCallback onNext;
  const _FeedbackCard({
    required this.correct,
    required this.onRetry,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final color = correct ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppElevation.level2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              correct
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              color: color,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            correct
                ? t.t('faq_training_correct_feedback')
                : t.t('faq_training_incorrect_feedback'),
            textAlign: TextAlign.center,
            style: AppTypography.title3.copyWith(
              color: AppColors.codriverGraphite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (correct)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: AppButtonStyle.of(AppButtonVariant.primary),
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(t.t('faq_training_continue')),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: AppButtonStyle.of(AppButtonVariant.primary),
                    onPressed: onRetry,
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(t.t('faq_training_back_to_explanation')),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: AppButtonStyle.of(AppButtonVariant.subtle),
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(t.t('faq_training_continue')),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Phase 4 — Summary
// ════════════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final int correct;
  final int total;
  final VoidCallback onRetake;
  final VoidCallback onClose;
  const _SummaryCard({
    required this.correct,
    required this.total,
    required this.onRetake,
    required this.onClose,
  });

  String _verdictKey() {
    final pct = total == 0 ? 0 : (correct / total) * 100;
    if (pct >= 90) return 'faq_training_score_excellent';
    if (pct >= 60) return 'faq_training_score_good';
    return 'faq_training_score_keep_practicing';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final perfect = correct == total && total > 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: perfect
              ? [
                  AppColors.codriverGreen,
                  AppColors.codriverDeep,
                ]
              : [
                  AppColors.surfaceElevatedLight,
                  AppColors.surfaceElevatedLight,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppElevation.level3,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            perfect ? Icons.celebration_rounded : Icons.school_rounded,
            size: 56,
            color: perfect ? Colors.white : AppColors.codriverGreen,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.t('faq_training_done_title'),
            textAlign: TextAlign.center,
            style: AppTypography.title2.copyWith(
              color: perfect ? Colors.white : AppColors.codriverGraphite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            t.tf('faq_training_done_score', {
              'correct': '$correct',
              'total': '$total',
            }),
            textAlign: TextAlign.center,
            style: AppTypography.title3.copyWith(
              color: perfect
                  ? Colors.white.withOpacity(0.85)
                  : AppColors.labelSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.t(_verdictKey()),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: perfect
                  ? Colors.white.withOpacity(0.9)
                  : AppColors.codriverGraphite,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: AppButtonStyle.of(AppButtonVariant.subtle),
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(t.t('faq_training_btn_close')),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  style: AppButtonStyle.of(AppButtonVariant.primary),
                  onPressed: onRetake,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(t.t('faq_training_btn_retake')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Empty state (no FAQs configured yet)
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevatedLight,
                    shape: BoxShape.circle,
                    boxShadow: AppElevation.level1,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.codriverDeep,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  t.t('faq_training_title'),
                  style: AppTypography.title3.copyWith(
                    color: AppColors.codriverGraphite,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    t.t('faq_training_no_questions'),
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
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

// ════════════════════════════════════════════════════════════════════════════
//  Small phase-label chip
// ════════════════════════════════════════════════════════════════════════════

class _PhaseChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PhaseChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption2.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
