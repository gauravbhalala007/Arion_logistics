// lib/Screens/driver_driving_safety_page.dart
//
// DA Academy — DSP Fahrsicherheitstraining.
//
// Ablauf laut Spezifikation (docs/Training Docs/
// codriver_fahrsicherheitstraining.md):
//   Intro → Modulliste → Modul (Slides → Modul-Quiz) → … →
//   Abschlusstest (12 Fragen, 80 %) → Zertifikat im Fahrerprofil.
//
// Ein Modul gilt als bestanden, wenn sein Quiz mindestens 80 % erreicht.
// Der Abschlusstest wird erst nach allen Modulen freigeschaltet und
// enthält immer die Pflichtfragen zu Handy und Ein-/Aussteigen.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/safety_training/driving_safety_data.dart';
import '../data/safety_training/driving_safety_quiz_de.dart';
import '../data/safety_training/driving_safety_texts.dart';
import '../data/safety_training/safety_blocks.dart';
import '../widgets/safety_block_view.dart';

const String kDrivingSafetyTrainingId = 'dsp_fahrsicherheit_v1';
const String kDrivingSafetyTitle = 'DSP Fahrsicherheitstraining';
const String kDrivingSafetyVersion = '1.2.0';
const double kDrivingPassThreshold = 0.8;
const int kDrivingCertificateMonths = 12;

class DriverDrivingSafetyPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverDrivingSafetyPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverDrivingSafetyPage> createState() =>
      _DriverDrivingSafetyPageState();
}

enum _Step { intro, modules, moduleSlides, moduleQuiz, exam, done }

class _DriverDrivingSafetyPageState extends State<DriverDrivingSafetyPage> {
  static const _kBg = Color(0xFFF5F7F9);
  static const _kText = Color(0xFF1A2233);
  static const _kMuted = Color(0xFF7A8699);
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kMint = Color(0xFFEBF7F1);
  static const _kLine = Color(0xFFE3E8EF);

  _Step _step = _Step.intro;
  int _moduleIndex = 0;
  int _slideIndex = 0;

  /// Module, deren Quiz bestanden wurde (mit Ergebnis 0..1).
  final Map<String, double> _moduleScores = {};

  // Quiz-/Testzustand
  final Map<int, int> _answers = {};
  bool _showResult = false;
  List<DrivingQuestion> _examQuestions = const [];
  int _examAttempts = 0;

  // Abschluss
  bool _submitting = false;
  DateTime? _validUntil;
  String? _certificateNumber;

  /// Sprache des Fahrers — steuert Inhalte, Fragen und Bedien-Texte.
  String get _lang => Localizations.localeOf(context).languageCode;

  /// Kurzform für den Text-Lookup mit Fallback locale → en → de.
  String _t(String key, [Map<String, String>? vars]) =>
      drivingText(_lang, key, vars);

  List<SafetyChapterContent> get _modules => drivingSafetyChaptersFor(_lang);

  DocumentReference<Map<String, dynamic>> get _resultRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('academy_test_results')
      .doc(kDrivingSafetyTrainingId)
      .collection('drivers')
      .doc(widget.driverTransporterId);

  DocumentReference<Map<String, dynamic>> get _driverRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('drivers')
      .doc(widget.driverTransporterId);

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final snap = await _resultRef.get();
      final data = snap.data();
      if (data == null || !mounted) return;
      final scores = (data['moduleScores'] as Map?)?.cast<String, dynamic>();
      setState(() {
        if (scores != null) {
          scores.forEach((k, v) {
            final d = (v as num?)?.toDouble();
            if (d != null) _moduleScores[k] = d;
          });
        }
        final vu = data['validUntil'];
        if (vu is Timestamp) _validUntil = vu.toDate();
        _certificateNumber = (data['certificateNumber'] ?? '').toString();
        if (_certificateNumber!.isEmpty) _certificateNumber = null;
        _examAttempts = (data['attempts'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  bool _modulePassed(String id) =>
      (_moduleScores[id] ?? 0) >= kDrivingPassThreshold;

  bool get _allModulesPassed =>
      _modules.every((m) => _modulePassed(m.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        foregroundColor: _kText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            switch (_step) {
              case _Step.moduleSlides:
              case _Step.moduleQuiz:
              case _Step.exam:
                setState(() {
                  _step = _Step.modules;
                  _showResult = false;
                });
              case _Step.modules:
                setState(() => _step = _Step.intro);
              case _Step.intro:
              case _Step.done:
                widget.onBack();
            }
          },
        ),
        title: Text(
          _t('title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: switch (_step) {
          _Step.intro => _buildIntro(),
          _Step.modules => _buildModuleList(),
          _Step.moduleSlides => _buildSlides(),
          _Step.moduleQuiz => _buildModuleQuiz(),
          _Step.exam => _buildExam(),
          _Step.done => _buildDone(),
        },
      ),
    );
  }

  // ── Intro ─────────────────────────────────────────────────────────

  Widget _buildIntro() {
    final now = DateTime.now();
    final valid = _validUntil != null && _validUntil!.isAfter(now);
    final expired = _validUntil != null && !_validUntil!.isAfter(now);
    final totalMinutes = 42;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            color: Colors.white,
            child: SvgPicture.asset(
              'assets/academy/driving/cover.svg',
              height: 190,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            color: _kMint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.drive_eta_rounded, size: 34, color: _kGreen),
              const SizedBox(height: 10),
              const Text(
                kDrivingSafetyTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _t('intro_meta', {
                  'n': '${_modules.length}',
                  'min': '$totalMinutes',
                }),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _t('intro_body'),
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.55,
            color: Color(0xFF3F4A5A),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: valid
                ? _kMint
                : expired
                    ? const Color(0xFFFDEDEB)
                    : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                valid
                    ? Icons.verified_rounded
                    : expired
                        ? Icons.error_outline_rounded
                        : Icons.schedule_rounded,
                size: 18,
                color: valid
                    ? _kGreen
                    : expired
                        ? const Color(0xFFC0392B)
                        : _kMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  valid
                      ? _t('status_valid', {
                            'date':
                                DateFormat('dd.MM.yyyy').format(_validUntil!),
                          }) +
                          (_certificateNumber != null
                              ? _t('status_cert_no',
                                  {'no': _certificateNumber!})
                              : '')
                      : expired
                          ? _t('status_expired')
                          : _t('status_open'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: valid
                        ? _kGreen
                        : expired
                            ? const Color(0xFFC0392B)
                            : _kMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => setState(() => _step = _Step.modules),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            _moduleScores.isEmpty ? _t('btn_start') : _t('btn_continue'),
          ),
          style: _primaryButton(),
        ),
      ],
    );
  }

  ButtonStyle _primaryButton() => FilledButton.styleFrom(
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  // ── Modulliste ────────────────────────────────────────────────────

  Widget _buildModuleList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(
          _t('modules_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _t('modules_hint', {
            't': '${(kDrivingPassThreshold * 100).round()}',
          }),
          style: const TextStyle(fontSize: 13.5, color: _kMuted, height: 1.45),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _modules.length; i++) _moduleCard(i, _modules[i]),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _allModulesPassed
              ? () => setState(() {
                    _examQuestions = buildDrivingExam(
                      seed: DateTime.now().millisecondsSinceEpoch,
                      languageCode: _lang,
                    );
                    _answers.clear();
                    _showResult = false;
                    _step = _Step.exam;
                  })
              : null,
          icon: const Icon(Icons.workspace_premium_rounded, size: 18),
          label: Text(
            _allModulesPassed
                ? _t('btn_exam_start')
                : _t('btn_exam_locked'),
          ),
          style: _primaryButton(),
        ),
      ],
    );
  }

  Widget _moduleCard(int index, SafetyChapterContent m) {
    final passed = _modulePassed(m.id);
    final score = _moduleScores[m.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() {
            _moduleIndex = index;
            _slideIndex = 0;
            _step = _Step.moduleSlides;
          }),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: passed ? _kGreen.withValues(alpha: 0.45) : _kLine,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: passed ? _kGreen : _kMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: passed
                      ? const Icon(Icons.check_rounded,
                          size: 20, color: Colors.white)
                      : Text(
                          'M${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _kGreen,
                          ),
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.summary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _kMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        passed && score != null
                            ? _t('module_passed',
                                {'p': '${(score * 100).round()}'})
                            : _t('module_pages',
                                {'n': '${m.slides.length}'}),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: passed ? _kGreen : _kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _kMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Modul-Slides ──────────────────────────────────────────────────

  /// Bild einer Seite: eigenes Slide-Asset, sonst auf der Auftaktseite
  /// das Kapitelbild, sonst keins.
  String? _slideAsset(SafetyChapterContent m, SafetySlide slide) {
    final own = slide.asset;
    if (own != null && own.isNotEmpty) return own;
    if (_slideIndex == 0 && m.asset.isNotEmpty) return m.asset;
    return null;
  }

  Widget _buildSlides() {
    final m = _modules[_moduleIndex];
    final slide = m.slides[_slideIndex];
    final isLast = _slideIndex == m.slides.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kMint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'M${_moduleIndex + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _kGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _kMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    '${_slideIndex + 1}/${m.slides.length}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _kMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < m.slides.length; i++)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                            right: i == m.slides.length - 1 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: i <= _slideIndex ? _kGreen : _kLine,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            key: ValueKey('${m.id}_$_slideIndex'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              // Seiteneigenes Bild; auf der Auftaktseite sonst das
              // Kapitelbild.
              if (_slideAsset(m, slide) != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: SvgPicture.asset(
                      _slideAsset(m, slide)!,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Text(
                slide.title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              for (final b in slide.blocks)
                SafetyBlockView(
                  b,
                  dspUid: widget.dspUid,
                  driverTransporterId: widget.driverTransporterId,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  if (_slideIndex > 0) {
                    setState(() => _slideIndex--);
                  } else {
                    setState(() => _step = _Step.modules);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kGreen,
                  side: const BorderSide(color: _kGreen),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _slideIndex > 0 ? _t('btn_back') : _t('btn_overview'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (!isLast) {
                      setState(() => _slideIndex++);
                    } else {
                      setState(() {
                        _answers.clear();
                        _showResult = false;
                        _step = _Step.moduleQuiz;
                      });
                    }
                  },
                  icon: Icon(
                    isLast ? Icons.quiz_rounded : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(isLast ? _t('btn_to_quiz') : _t('btn_next')),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Quiz / Test (gemeinsames Rendering) ──────────────────────────

  Widget _buildModuleQuiz() {
    final m = _modules[_moduleIndex];
    final qs = drivingQuestionsForModule(m.id, _lang);
    return _questionList(
      title: _t('quiz_title', {'title': m.title}),
      intro: _t('quiz_intro', {
        'n': '${qs.length}',
        't': '${(kDrivingPassThreshold * 100).round()}',
      }),
      questions: qs,
      onSubmit: () => _submitModuleQuiz(m.id, qs),
      onContinue: () {
        final passed = _modulePassed(m.id);
        setState(() {
          _showResult = false;
          if (passed && _moduleIndex < _modules.length - 1) {
            _moduleIndex++;
            _slideIndex = 0;
            _step = _Step.moduleSlides;
          } else {
            _step = _Step.modules;
          }
        });
      },
    );
  }

  Widget _buildExam() {
    return _questionList(
      title: _t('exam_title'),
      intro: _t('quiz_intro', {
            'n': '${_examQuestions.length}',
            't': '${(kDrivingPassThreshold * 100).round()}',
          }) +
          (_examAttempts > 0
              ? _t('exam_attempt', {'n': '${_examAttempts + 1}'})
              : ''),
      questions: _examQuestions,
      onSubmit: _submitExam,
      onContinue: () {
        final score = _scoreOf(_examQuestions);
        if (score >= kDrivingPassThreshold) {
          _issueCertificate(score);
        } else {
          setState(() {
            _showResult = false;
            _answers.clear();
            _examQuestions = buildDrivingExam(
              seed: DateTime.now().millisecondsSinceEpoch,
              languageCode: _lang,
            );
          });
        }
      },
    );
  }

  double _scoreOf(List<DrivingQuestion> qs) {
    if (qs.isEmpty) return 0;
    var correct = 0;
    for (var i = 0; i < qs.length; i++) {
      if (_answers[i] == qs[i].correctIndex) correct++;
    }
    return correct / qs.length;
  }

  Widget _questionList({
    required String title,
    required String intro,
    required List<DrivingQuestion> questions,
    required VoidCallback onSubmit,
    required VoidCallback onContinue,
  }) {
    final answered = _answers.length;
    final score = _showResult ? _scoreOf(questions) : 0.0;
    final passed = score >= kDrivingPassThreshold;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 4),
              Text(intro,
                  style: const TextStyle(fontSize: 13, color: _kMuted)),
              if (_showResult) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: passed ? _kMint : const Color(0xFFFDEDEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        passed
                            ? Icons.check_circle_rounded
                            : Icons.replay_rounded,
                        color: passed ? _kGreen : const Color(0xFFC0392B),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          passed
                              ? _t('result_passed',
                                  {'p': '${(score * 100).round()}'})
                              : _t('result_failed',
                                  {'p': '${(score * 100).round()}'}),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: passed ? _kGreen : const Color(0xFFC0392B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              for (var qi = 0; qi < questions.length; qi++) ...[
                const SizedBox(height: 10),
                _questionCard(qi, questions[qi]),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _showResult
                  ? onContinue
                  : (answered == questions.length ? onSubmit : null),
              icon: Icon(
                _showResult
                    ? (passed
                        ? Icons.arrow_forward_rounded
                        : Icons.replay_rounded)
                    : Icons.checklist_rounded,
                size: 18,
              ),
              label: Text(
                _showResult
                    ? (passed ? _t('btn_next') : _t('btn_retry'))
                    : (answered == questions.length
                        ? _t('btn_check')
                        : _t('btn_check_progress', {
                            'a': '$answered',
                            'b': '${questions.length}',
                          })),
              ),
              style: _primaryButton(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionCard(int qi, DrivingQuestion q) {
    final given = _answers[qi];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${qi + 1}. ${q.question}',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: _kText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          for (var oi = 0; oi < q.options.length; oi++)
            RadioListTile<int>(
              value: oi,
              groupValue: given,
              onChanged: _showResult
                  ? null
                  : (v) => setState(() => _answers[qi] = v ?? 0),
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: _kGreen,
              title: Text(
                q.options[oi],
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: _showResult && oi == q.correctIndex
                      ? FontWeight.w800
                      : FontWeight.normal,
                  color: _showResult
                      ? (oi == q.correctIndex
                          ? _kGreen
                          : (oi == given
                              ? const Color(0xFFC0392B)
                              : _kMuted))
                      : const Color(0xFF3F4A5A),
                ),
              ),
            ),
          if (_showResult) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                q.explanation,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Color(0xFF3F4A5A),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitModuleQuiz(
      String moduleId, List<DrivingQuestion> qs) async {
    final score = _scoreOf(qs);
    setState(() {
      _showResult = true;
      if (score >= kDrivingPassThreshold) _moduleScores[moduleId] = score;
    });
    try {
      await _resultRef.set({
        'driverTransporterId': widget.driverTransporterId,
        // Ohne testId weist die Firestore-Regel den Schreibvorgang ab —
        // der Modulfortschritt ging dadurch stillschweigend verloren.
        'testId': kDrivingSafetyTrainingId,
        'trainingId': kDrivingSafetyTrainingId,
        'moduleScores': {moduleId: score},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('err_certificate', {'error': '\$e'}))),
      );
    }
  }

  void _submitExam() {
    setState(() {
      _showResult = true;
      _examAttempts++;
    });
  }

  // ── Zertifikat ────────────────────────────────────────────────────

  /// Zertifikatsnummer im Schema CD-{Jahr}-{8 Stellen}.
  ///
  /// Frueher lief das ueber einen fortlaufenden Zaehler in
  /// users/{uid}/settings/certificate_counter. Fahrer duerfen dort laut
  /// Firestore-Regeln aber nur LESEN — der Schreibvorgang scheiterte mit
  /// permission-denied und riss die gesamte Zertifikatsausstellung mit.
  /// Die Nummer wird deshalb lokal aus Transporter-ID und Zeitpunkt
  /// abgeleitet: eindeutig, ohne zentralen Zaehler und ohne Sonderrechte.
  /// Fuer die Echtheitspruefung zaehlt ohnehin der SHA-256-Hash.
  String _certificateNumberFor(DateTime now) {
    final year = now.year;
    final seed = '${widget.dspUid}|${widget.driverTransporterId}|'
        '${now.microsecondsSinceEpoch}';
    final digest = sha256.convert(utf8.encode(seed)).toString();
    final digits = digest.replaceAll(RegExp(r'[^0-9]'), '');
    final take = digits.length >= 8
        ? digits.substring(0, 8)
        : '${digits}00000000'.substring(0, 8);
    return 'CD-$year-$take';
  }

  Future<void> _issueCertificate(double score) async {
    // Sprache vor dem ersten await festhalten — danach ist der Zugriff
    // auf den BuildContext nicht mehr sicher.
    final lang = _lang;
    setState(() => _submitting = true);
    try {
      final driverSnap = await _driverRef.get();
      final driverData = driverSnap.data() ?? const {};
      final driverName =
          (driverData['driverName'] ?? '').toString().trim().isEmpty
              ? widget.driverTransporterId
              : (driverData['driverName'] ?? '').toString().trim();

      String issuer = '';
      try {
        final company = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.dspUid)
            .get();
        final p = company.data() ?? const {};
        issuer =
            (p['companyName'] ?? p['dspName'] ?? '').toString().trim();
      } catch (_) {}

      final now = DateTime.now();
      final validUntil = DateTime(
        now.year,
        now.month + kDrivingCertificateMonths,
        now.day,
      );
      final number = _certificateNumber ?? _certificateNumberFor(now);

      // Bestandenes Ergebnis ZUERST sichern. Frueher lief erst die
      // PDF-Erzeugung und der Storage-Upload — schlug dort etwas fehl,
      // war der bestandene Test komplett verloren und musste wiederholt
      // werden. Das Zertifikat wird danach nachgetragen.
      try {
        await _resultRef.set({
          'driverTransporterId': widget.driverTransporterId,
          'testId': kDrivingSafetyTrainingId,
          'trainingId': kDrivingSafetyTrainingId,
          'trainingVersion': kDrivingSafetyVersion,
          'driverName': driverName,
          'score': score,
          'passedAt': Timestamp.fromDate(now),
          'validUntil': Timestamp.fromDate(validUntil),
          'certificateNumber': number,
          'attempts': _examAttempts,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {
        // Auch das darf den Ablauf nicht abbrechen — der Fahrer sieht
        // sein Ergebnis, die Meldung kommt weiter unten.
      }

      // Fälschungsschutz: Hash über die inhaltlichen Felder.
      final hash = sha256
          .convert(utf8.encode([
            number,
            widget.driverTransporterId,
            driverName,
            kDrivingSafetyTrainingId,
            kDrivingSafetyVersion,
            score.toStringAsFixed(2),
            now.toIso8601String(),
          ].join('|')))
          .toString();

      final pdf = await _buildCertificatePdf(
        lang: lang,
        driverName: driverName,
        employeeNumber:
            (driverData['employeeNumber'] ?? '').toString().trim(),
        issuer: issuer,
        number: number,
        score: score,
        issuedAt: now,
        validUntil: validUntil,
        hash: hash,
      );

      final filename =
          'Fahrsicherheit_${DateFormat('yyyy-MM-dd').format(now)}.pdf';
      final ref = FirebaseStorage.instance
          .ref()
          .child('driver_docs')
          .child(widget.driverTransporterId)
          .child('${now.millisecondsSinceEpoch}_$filename');
      await ref.putData(
        pdf,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final url = await ref.getDownloadURL();

      await _driverRef
          .collection('documents')
          .doc('driving_safety_certificate')
          .set({
        'fileName': filename,
        'downloadUrl': url,
        'storagePath': ref.fullPath,
        'contentType': 'application/pdf',
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedAtClient': Timestamp.now(),
        'size': pdf.length,
        'docType': 'driving_safety_certificate',
        'uploadedBy': 'driver',
        'certificateNumber': number,
        'validUntil': Timestamp.fromDate(validUntil),
        'score': score,
      }, SetOptions(merge: true));

      await _resultRef.set({
        'driverTransporterId': widget.driverTransporterId,
        'testId': kDrivingSafetyTrainingId,
        'trainingId': kDrivingSafetyTrainingId,
        'trainingVersion': kDrivingSafetyVersion,
        'driverName': driverName,
        'score': score,
        'passedAt': Timestamp.fromDate(now),
        'validUntil': Timestamp.fromDate(validUntil),
        'certificateNumber': number,
        'certificateUrl': url,
        'verificationHash': hash,
        'attempts': _examAttempts,
        'issuer': issuer,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _validUntil = validUntil;
        _certificateNumber = number;
        _step = _Step.done;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            drivingText(lang, 'err_certificate', {'error': '$e'}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildDone() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      children: [
        const Icon(Icons.workspace_premium_rounded, size: 72, color: _kGreen),
        const SizedBox(height: 14),
        Text(
          _t('done_title'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _t('done_body', {'months': '$kDrivingCertificateMonths'}),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5, color: _kMuted),
        ),
        if (_certificateNumber != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _kMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  _t('done_cert_no', {'no': _certificateNumber!}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _kGreen,
                  ),
                ),
                if (_validUntil != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _t('done_valid_until', {
                      'date': DateFormat('dd.MM.yyyy').format(_validUntil!),
                    }),
                    style: const TextStyle(fontSize: 13, color: _kGreen),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        FilledButton(
          onPressed: widget.onBack,
          style: _primaryButton(),
          child: Text(_t('btn_done')),
        ),
      ],
    );
  }

  /// Zeichen außerhalb von Latin-1 ersetzen — die PDF-Standardschrift
  /// stellt sie sonst als leere Kästchen dar.
  static String _pdfSafe(String input) {
    const map = {
      '–': '-',
      '—': '-',
      '‘': "'",
      '’': "'",
      '“': '"',
      '”': '"',
      '„': '"',
      '…': '...',
      ' ': ' ',
      ' ': ' ',
      '€': 'EUR',
      '→': '->',
      '•': '-',
      '✓': 'x',
      // Latin-Extended → Grundbuchstabe, damit hu/ro/hr/tr-Texte im PDF
      // lesbar bleiben statt Buchstaben zu verlieren.
      'ă': 'a', 'Ă': 'A', // ă Ă (ro)
      'ć': 'c', 'Ć': 'C', // ć Ć (hr)
      'č': 'c', 'Č': 'C', // č Č (hr)
      'đ': 'd', 'Đ': 'D', // đ Đ (hr)
      'ğ': 'g', 'Ğ': 'G', // ğ Ğ (tr)
      'ı': 'i', 'İ': 'I', // ı İ (tr)
      'ő': 'o', 'Ő': 'O', // ő Ő (hu)
      'ş': 's', 'Ş': 'S', // ş Ş (tr/ro)
      'ș': 's', 'Ș': 'S', // ș Ș (ro)
      'š': 's', 'Š': 'S', // š Š (hr)
      'ţ': 't', 'Ţ': 'T', // ţ Ţ (ro)
      'ț': 't', 'Ț': 'T', // ț Ț (ro)
      'ű': 'u', 'Ű': 'U', // ű Ű (hu)
      'ž': 'z', 'Ž': 'Z', // ž Ž (hr)
      'ł': 'l', 'Ł': 'L', // ł Ł
    };
    var out = input;
    map.forEach((k, v) => out = out.replaceAll(k, v));
    return out.replaceAll(RegExp(r'[^ -ÿ]'), '');
  }

  Future<Uint8List> _buildCertificatePdf({
    required String lang,
    required String driverName,
    required String employeeNumber,
    required String issuer,
    required String number,
    required double score,
    required DateTime issuedAt,
    required DateTime validUntil,
    required String hash,
  }) async {
    final doc = pw.Document();
    const green = PdfColor.fromInt(0xFF1D7F5A);
    const mint = PdfColor.fromInt(0xFFE4F5EC);
    const grey = PdfColor.fromInt(0xFF6B7280);
    const dark = PdfColor.fromInt(0xFF111827);
    final df = DateFormat('dd.MM.yyyy');

    // Zertifikatstexte in der Fahrersprache. Der Trainingsname, die
    // Zertifikatsnummer und der Firmenname bleiben unverändert.
    String p(String key, [Map<String, String>? vars]) =>
        drivingText(lang, key, vars);

    pw.Widget kv(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 150,
                child: pw.Text(_pdfSafe(label),
                    style: const pw.TextStyle(fontSize: 10, color: grey)),
              ),
              pw.Expanded(
                child: pw.Text(
                  _pdfSafe(value),
                  style: pw.TextStyle(
                    fontSize: 11.5,
                    fontWeight: pw.FontWeight.bold,
                    color: dark,
                  ),
                ),
              ),
            ],
          ),
        );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 40),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: mint,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: green, width: 1.2),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _pdfSafe(p('pdf_heading')),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: green,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    _pdfSafe(kDrivingSafetyTitle),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: dark,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Text(_pdfSafe(p('pdf_confirm')),
                style: const pw.TextStyle(fontSize: 11, color: grey)),
            pw.SizedBox(height: 8),
            pw.Text(
              _pdfSafe(driverName),
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: dark,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              _pdfSafe(p('pdf_completed', {'training': kDrivingSafetyTitle})),
              style: const pw.TextStyle(fontSize: 11.5, lineSpacing: 2),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            if (employeeNumber.isNotEmpty)
              kv(p('pdf_employee_no'), employeeNumber),
            kv(p('pdf_transporter_id'), widget.driverTransporterId),
            kv(
              p('pdf_result'),
              p('pdf_result_value', {
                'p': '${(score * 100).round()}',
                't': '${(kDrivingPassThreshold * 100).round()}',
              }),
            ),
            kv(p('pdf_issued_at'), df.format(issuedAt)),
            kv(p('pdf_valid_until'), df.format(validUntil)),
            kv(p('pdf_cert_no'), number),
            kv(p('pdf_version'), kDrivingSafetyVersion),
            if (issuer.isNotEmpty) kv(p('pdf_issued_by'), issuer),
            pw.SizedBox(height: 16),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(11),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFF8FAFC),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                _pdfSafe(p('pdf_contents')),
                style: const pw.TextStyle(
                    fontSize: 9, color: grey, lineSpacing: 1.6),
              ),
            ),
            pw.Spacer(),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'CoDriver|$number|$hash',
                    width: 74,
                    height: 74,
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _pdfSafe(p('pdf_checksum')),
                        style: const pw.TextStyle(fontSize: 8, color: grey),
                      ),
                      pw.Text(
                        hash,
                        style: const pw.TextStyle(fontSize: 6.5, color: grey),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        _pdfSafe(p('pdf_generated')),
                        style: const pw.TextStyle(fontSize: 8, color: grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }
}
