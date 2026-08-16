// lib/Screens/driver_privacy_training_page.dart
//
// DA Academy — Datenschutz-Schulung (DSGVO-Grundschulung für Fahrer).
//
// Ablauf: Intro → Kapitelübersicht → Kapitel-Slides → Abschlusstest
// (18 Fragen, 80 % zum Bestehen) → Unterschrift → Ergebnis.
//
// Aufbau der Kapitel-/Testseiten wie bei der Ride-Along-Schulung
// (driver_ride_along_page.dart). Der Unterschrifts-Teil ist unverändert
// aus der Sicherheitsunterweisung (driver_safety_training_page.dart)
// übernommen: signature-Package, SignatureController mit
// kSignatureInkBlue, `toPngBytes()`, Einbettung in ein Nachweis-PDF,
// Upload nach Storage `driver_docs/{tid}/…` und Ablage als
// Fahrer-Dokument. Ohne Unterschrift ist kein Abschluss möglich.
//
// Ablage:
//   - Storage  driver_docs/{tid}/…  + Firestore drivers/{tid}/documents/
//     privacy_training_certificate (erscheint im Drivers Hub)
//   - users/{dspUid}/academy_test_results/privacy/drivers/{tid}
//     (Admin-Übersicht + 12-Monats-Gültigkeit)

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';

import '../data/safety_training/driving_safety_quiz_de.dart';
import '../data/safety_training/privacy_data.dart';
import '../data/safety_training/privacy_texts.dart';
import '../data/safety_training/safety_blocks.dart';
import '../widgets/safety_block_view.dart';
import 'driver_safety_training_page.dart' show kSignatureInkBlue;

class DriverPrivacyTrainingPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverPrivacyTrainingPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverPrivacyTrainingPage> createState() =>
      _DriverPrivacyTrainingPageState();
}

enum _Step { intro, chapters, slides, exam, signature, done }

class _DriverPrivacyTrainingPageState extends State<DriverPrivacyTrainingPage> {
  static const _kBg = Color(0xFFF5F7F9);
  static const _kText = Color(0xFF1A2233);
  static const _kMuted = Color(0xFF7A8699);
  static const _kAccent = Color(0xFF5C4B99);
  static const _kTint = Color(0xFFEFECF9);
  static const _kLine = Color(0xFFE3E8EF);
  static const _kRed = Color(0xFFC0392B);

  _Step _step = _Step.intro;
  int _chapterIndex = 0;
  int _slideIndex = 0;

  /// Kapitel, deren Folien komplett durchgeblättert wurden.
  final Set<String> _readChapters = {};

  // Testzustand
  final Map<int, int> _answers = {};
  bool _showResult = false;
  int _attempts = 0;
  bool _submitting = false;

  /// Ergebnis des bestandenen Versuchs (Anteil 0…1) — wird erst nach der
  /// Unterschrift gespeichert.
  double? _pendingScore;

  double? _passedScore;
  DateTime? _passedAt;
  DateTime? _validUntil;

  // Signatur-State — identisch zur Sicherheitsunterweisung.
  late final SignatureController _signatureCtrl;
  bool _confirmed = false;

  List<SafetyChapterContent> get _chapters => privacyChaptersFor(_lang);

  List<DrivingQuestion> get _questions => privacyQuestionsFor(_lang);

  /// Sprache des Fahrers — steuert alle Bedien-Texte dieser Seite.
  String get _lang => Localizations.localeOf(context).languageCode;

  /// Kurzform für den Text-Lookup mit Fallback locale → en → de.
  String _t(String key, [Map<String, String>? vars]) =>
      privacyText(_lang, key, vars: vars);

  /// Bestehensgrenze als ganze Prozentzahl, z. B. „80".
  String get _threshold => (kPrivacyPassThreshold * 100).round().toString();

  DocumentReference<Map<String, dynamic>> get _resultRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('academy_test_results')
      .doc(kPrivacyTestId)
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
    // Übernommen aus driver_safety_training_page.dart (initState):
    _signatureCtrl = SignatureController(
      penStrokeWidth: 2.6,
      penColor: kSignatureInkBlue,
      exportBackgroundColor: Colors.white,
    );
    _loadProgress();
  }

  @override
  void dispose() {
    _signatureCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final snap = await _resultRef.get();
      final data = snap.data();
      if (data == null || !mounted) return;
      setState(() {
        final score = (data['score'] as num?)?.toDouble();
        if (score != null && score >= kPrivacyPassThreshold) {
          _passedScore = score;
        }
        final at = data['passedAt'];
        if (at is Timestamp) _passedAt = at.toDate();
        final vu = data['validUntil'];
        if (vu is Timestamp) _validUntil = vu.toDate();
        _attempts = (data['attempts'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  bool get _allChaptersRead =>
      _chapters.every((c) => _readChapters.contains(c.id));

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
              case _Step.slides:
              case _Step.exam:
                setState(() {
                  _step = _Step.chapters;
                  _showResult = false;
                });
              case _Step.chapters:
                setState(() => _step = _Step.intro);
              case _Step.intro:
              case _Step.signature:
              case _Step.done:
                widget.onBack();
            }
          },
        ),
        title: Text(
          _t('appbar_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: switch (_step) {
          _Step.intro => _buildIntro(),
          _Step.chapters => _buildChapterList(),
          _Step.slides => _buildSlides(),
          _Step.exam => _buildExam(),
          _Step.signature => _buildSignature(),
          _Step.done => _buildDone(),
        },
      ),
    );
  }

  ButtonStyle _primaryButton() => FilledButton.styleFrom(
        backgroundColor: _kAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  // ── Intro ─────────────────────────────────────────────────────────

  /// Statuszeile im Intro, z. B. „Test bestanden · 90 % am 05.08.2026".
  String _passedSummary() {
    final buf = StringBuffer(_t('status_passed'));
    if (_passedScore != null) {
      buf.write(_t('status_passed_score', {
        'p': '${(_passedScore! * 100).round()}',
      }));
    }
    if (_passedAt != null) {
      buf.write(_t('status_passed_date', {
        'date': DateFormat('dd.MM.yyyy').format(_passedAt!),
      }));
    }
    return buf.toString();
  }

  Widget _buildIntro() {
    final passed = _passedScore != null;
    final slideCount =
        _chapters.fold<int>(0, (total, c) => total + c.slides.length);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            color: _kTint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.privacy_tip_rounded, size: 34, color: _kAccent),
              const SizedBox(height: 10),
              Text(
                _t('training_title'),
                style: const TextStyle(
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
                  'c': '${_chapters.length}',
                  's': '$slideCount',
                  'q': '${_questions.length}',
                }),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kAccent,
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
            color: passed ? _kTint : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    passed ? Icons.verified_rounded : Icons.schedule_rounded,
                    size: 18,
                    color: passed ? _kAccent : _kMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      passed ? _passedSummary() : _t('status_open'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: passed ? _kAccent : _kMuted,
                      ),
                    ),
                  ),
                ],
              ),
              if (passed && _validUntil != null) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    _t('status_valid_until', {
                      'date': DateFormat('dd.MM.yyyy').format(_validUntil!),
                    }),
                    style: const TextStyle(fontSize: 12.5, color: _kAccent),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => setState(() => _step = _Step.chapters),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(_t(passed ? 'btn_view_content' : 'btn_start')),
          style: _primaryButton(),
        ),
      ],
    );
  }

  // ── Kapitelübersicht ──────────────────────────────────────────────

  Widget _buildChapterList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(
          _t('chapters_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _t('chapters_hint', {
            'n': '${_questions.length}',
            't': _threshold,
          }),
          style: const TextStyle(
            fontSize: 13.5,
            color: _kMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _chapters.length; i++)
          _chapterCard(i, _chapters[i]),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _allChaptersRead
              ? () => setState(() {
                    _answers.clear();
                    _showResult = false;
                    _step = _Step.exam;
                  })
              : null,
          icon: const Icon(Icons.checklist_rounded, size: 18),
          label: Text(
            _t(_allChaptersRead ? 'btn_exam_start' : 'btn_exam_locked'),
          ),
          style: _primaryButton(),
        ),
      ],
    );
  }

  Widget _chapterCard(int index, SafetyChapterContent c) {
    final read = _readChapters.contains(c.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() {
            _chapterIndex = index;
            _slideIndex = 0;
            _step = _Step.slides;
          }),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: read ? _kAccent.withValues(alpha: 0.45) : _kLine,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: read ? _kAccent : _kTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: read
                      ? const Icon(Icons.check_rounded,
                          size: 20, color: Colors.white)
                      : Text(
                          _t('chapter_badge', {'n': '${index + 1}'}),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _kAccent,
                          ),
                        ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.summary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _kMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _t(
                          read ? 'chapter_read' : 'chapter_pages',
                          {'n': '${c.slides.length}'},
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: read ? _kAccent : _kMuted,
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

  // ── Kapitel-Slides ────────────────────────────────────────────────

  Widget _buildSlides() {
    final c = _chapters[_chapterIndex];
    final slide = c.slides[_slideIndex];
    final isLast = _slideIndex == c.slides.length - 1;
    final isLastChapter = _chapterIndex == _chapters.length - 1;

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _t('chapter_badge', {'n': '${_chapterIndex + 1}'}),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _kAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.title.toUpperCase(),
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
                    '${_slideIndex + 1}/${c.slides.length}',
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
                  for (var i = 0; i < c.slides.length; i++)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                            right: i == c.slides.length - 1 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: i <= _slideIndex ? _kAccent : _kLine,
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
            key: ValueKey('${c.id}_$_slideIndex'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
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
                    setState(() => _step = _Step.chapters);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kAccent,
                  side: const BorderSide(color: _kAccent),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(_t(_slideIndex > 0 ? 'btn_back' : 'btn_overview')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (!isLast) {
                      setState(() => _slideIndex++);
                      return;
                    }
                    setState(() {
                      _readChapters.add(c.id);
                      if (!isLastChapter) {
                        _chapterIndex++;
                        _slideIndex = 0;
                      } else {
                        _step = _Step.chapters;
                      }
                    });
                  },
                  icon: Icon(
                    isLast
                        ? (isLastChapter
                            ? Icons.check_rounded
                            : Icons.skip_next_rounded)
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _t(
                      isLast
                          ? (isLastChapter
                              ? 'btn_chapter_done'
                              : 'btn_next_chapter')
                          : 'btn_next',
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kAccent,
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

  // ── Abschlusstest ─────────────────────────────────────────────────

  double _scoreOf(List<DrivingQuestion> qs) {
    if (qs.isEmpty) return 0;
    var correct = 0;
    for (var i = 0; i < qs.length; i++) {
      if (_answers[i] == qs[i].correctIndex) correct++;
    }
    return correct / qs.length;
  }

  Widget _buildExam() {
    final qs = _questions;
    final answered = _answers.length;
    final score = _showResult ? _scoreOf(qs) : 0.0;
    final passed = score >= kPrivacyPassThreshold;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            children: [
              Text(
                _t('exam_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _t('exam_intro', {
                      'n': '${qs.length}',
                      't': _threshold,
                    }) +
                    (_attempts > 0
                        ? _t('exam_attempt', {'n': '${_attempts + 1}'})
                        : ''),
                style: const TextStyle(fontSize: 13, color: _kMuted),
              ),
              if (_showResult) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: passed ? _kTint : const Color(0xFFFDEDEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        passed
                            ? Icons.check_circle_rounded
                            : Icons.replay_rounded,
                        color: passed ? _kAccent : _kRed,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _t(
                            passed ? 'result_passed' : 'result_failed',
                            {'p': '${(score * 100).round()}'},
                          ),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: passed ? _kAccent : _kRed,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              for (var qi = 0; qi < qs.length; qi++) ...[
                const SizedBox(height: 10),
                _questionCard(qi, qs[qi]),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitting
                  ? null
                  : (_showResult
                      ? () => _onContinue(score, passed)
                      : (answered == qs.length ? _submitExam : null)),
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
                    ? _t(passed ? 'btn_next' : 'btn_retry')
                    : (answered == qs.length
                        ? _t('btn_check')
                        : _t('btn_check_progress', {
                            'a': '$answered',
                            'b': '${qs.length}',
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
              activeColor: _kAccent,
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
                          ? _kAccent
                          : (oi == given ? _kRed : _kMuted))
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

  void _submitExam() {
    setState(() {
      _showResult = true;
      _attempts++;
    });
  }

  /// Bestanden → weiter zur Unterschrift (Pflicht). Nicht bestanden →
  /// Antworten zurücksetzen und erneut versuchen.
  void _onContinue(double score, bool passed) {
    if (passed) {
      setState(() {
        _pendingScore = score;
        _step = _Step.signature;
      });
    } else {
      setState(() {
        _showResult = false;
        _answers.clear();
      });
    }
  }

  // ── Unterschrift ──────────────────────────────────────────────────
  // Unverändert aus driver_safety_training_page.dart (_buildSignature).

  Widget _buildSignature() {
    final score = _pendingScore ?? 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        Text(
          _t('signature_title'),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _t('signature_hint'),
          style: const TextStyle(fontSize: 13.5, height: 1.5, color: _kMuted),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _t('result_passed', {'p': '${(score * 100).round()}'}),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _kAccent,
            ),
          ),
        ),
        CheckboxListTile(
          value: _confirmed,
          onChanged: (v) => setState(() => _confirmed = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: _kAccent,
          title: Text(
            _t('confirm_checkbox'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: 170,
                child: Signature(
                  controller: _signatureCtrl,
                  backgroundColor: Colors.white,
                ),
              ),
              Container(
                color: const Color(0xFFF8FAFC),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _signatureCtrl.clear(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(_t('btn_clear')),
                      style: TextButton.styleFrom(foregroundColor: _kMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _submitting ? null : _completeTraining,
          icon: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.draw_rounded, size: 18),
          label: Text(_t('btn_sign_submit')),
          style: _primaryButton(),
        ),
      ],
    );
  }

  /// Abschluss — Unterschrift ist Pflicht. Ablauf identisch zur
  /// Sicherheitsunterweisung (_completeTraining dort): PNG exportieren,
  /// Nachweis-PDF bauen, in Storage ablegen, als Fahrer-Dokument
  /// verlinken und das Testergebnis speichern.
  Future<void> _completeTraining() async {
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('confirm_checkbox'))),
      );
      return;
    }
    if (_signatureCtrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('signature_hint'))),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final signaturePng = await _signatureCtrl.toPngBytes();
      if (signaturePng == null) {
        throw Exception('signature export failed');
      }

      // Stammdaten laden (Fahrer + Firma).
      final driverSnap = await _driverRef.get();
      final driverData = driverSnap.data() ?? const {};
      final driverName =
          (driverData['driverName'] ?? '').toString().trim().isEmpty
              ? widget.driverTransporterId
              : (driverData['driverName'] ?? '').toString().trim();
      final employeeNumber =
          (driverData['employeeNumber'] ?? '').toString().trim();
      String companyName = '';
      try {
        final companySnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.dspUid)
            .get();
        final profile = companySnap.data() ?? const {};
        companyName = (profile['companyName'] ??
                profile['dspName'] ??
                profile['company'] ??
                '')
            .toString()
            .trim();
      } catch (_) {}
      // Fallback: Firmenname aus dem Fahrer-Dokument, falls das
      // Admin-Profil keinen liefert — die Firma muss auf dem Nachweis
      // stehen.
      if (companyName.isEmpty) {
        companyName = (driverData['company'] ?? '').toString().trim();
      }

      final now = DateTime.now();
      final validUntil = now.add(kPrivacyValidity);
      final score = _pendingScore ?? 0;
      final correct = (score * _questions.length).round();

      final pdfBytes = await _buildCertificatePdf(
        signaturePng: signaturePng,
        driverName: driverName,
        employeeNumber: employeeNumber,
        companyName: companyName,
        correct: correct,
        completedAt: now,
        validUntil: validUntil,
      );

      // 1) PDF in Storage ablegen (Fahrer darf in driver_docs/{tid}/).
      final filename =
          'Datenschutz_Schulungsnachweis_${DateFormat('yyyy-MM-dd').format(now)}'
          '.pdf';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('driver_docs')
          .child(widget.driverTransporterId)
          .child('${now.millisecondsSinceEpoch}_$filename');
      await storageRef.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final url = await storageRef.getDownloadURL();

      // 2) Als Fahrer-Dokument ablegen → sichtbar im Drivers Hub.
      await _driverRef
          .collection('documents')
          .doc('privacy_training_certificate')
          .set({
        'fileName': filename,
        'downloadUrl': url,
        'storagePath': storageRef.fullPath,
        'contentType': 'application/pdf',
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedAtClient': Timestamp.now(),
        'size': pdfBytes.length,
        'docType': 'privacy_training_certificate',
        'uploadedBy': 'driver',
        'completedAt': Timestamp.fromDate(now),
        'validUntil': Timestamp.fromDate(validUntil),
        'score': correct,
        'total': _questions.length,
      }, SetOptions(merge: true));

      // 3) Abschluss für die Admin-Übersicht + Gültigkeit.
      await _resultRef.set({
        'driverTransporterId': widget.driverTransporterId,
        'testId': kPrivacyTestId,
        'driverName': driverName,
        'employeeNumber': employeeNumber,
        'score': score,
        'correct': correct,
        'total': _questions.length,
        'attempts': _attempts,
        'passedAt': Timestamp.fromDate(now),
        'validUntil': Timestamp.fromDate(validUntil),
        'certificateUrl': url,
        'signedAt': Timestamp.fromDate(now),
        'language': _lang,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _passedScore = score;
        _passedAt = now;
        _validUntil = validUntil;
        _step = _Step.done;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('err_save', {'error': '$e'}))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Abschluss ─────────────────────────────────────────────────────

  Widget _buildDone() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      children: [
        const Icon(Icons.verified_rounded, size: 72, color: _kAccent),
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
          _t('done_body'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: _kMuted,
          ),
        ),
        if (_passedScore != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _kTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  _t('done_result', {
                    'p': '${(_passedScore! * 100).round()}',
                  }),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _kAccent,
                  ),
                ),
                if (_passedAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _t('done_passed_at', {
                      'date': DateFormat('dd.MM.yyyy').format(_passedAt!),
                    }),
                    style: const TextStyle(fontSize: 13, color: _kAccent),
                  ),
                ],
                if (_validUntil != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    _t('status_valid_until', {
                      'date': DateFormat('dd.MM.yyyy').format(_validUntil!),
                    }),
                    style: const TextStyle(fontSize: 13, color: _kAccent),
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

  // ── Nachweis-PDF ──────────────────────────────────────────────────
  // Aufbau übernommen aus driver_safety_training_page.dart
  // (_pdfSafe + _buildCertificatePdf), Texte auf die
  // Datenschutz-Schulung angepasst.

  /// Ersetzt Zeichen außerhalb von Latin-1 — die PDF-Standardschrift
  /// stellt sie sonst als leere Kästchen dar.
  static String _pdfSafe(String input) {
    const map = {
      '\u2013': '-',
      '\u2014': '-',
      '\u2018': "'",
      '\u2019': "'",
      '\u201C': '"',
      '\u201D': '"',
      '\u201E': '"',
      '\u2026': '...',
      '\u00A0': ' ',
      '\u202F': ' ',
      '\u20AC': 'EUR',
      '\u2192': '->',
      '\u2022': '-',
      '\u2713': 'x',
    };
    var out = input;
    map.forEach((k, v) => out = out.replaceAll(k, v));
    return out.replaceAll(RegExp(r'[^\u0000-\u00FF]'), '');
  }

  // ── Urkunden-Bausteine (Layout identisch zu tool/regen_certs.dart) ──

  static const PdfColor _certGrey = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _certDark = PdfColor.fromInt(0xFF111827);

  static pw.Widget _certKv(String label, String value) => pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
                color: PdfColor.fromInt(0xFFECEEF2), width: 0.6),
          ),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 165,
              child: pw.Text(_pdfSafe(label),
                  style: const pw.TextStyle(fontSize: 10, color: _certGrey)),
            ),
            pw.Expanded(
              child: pw.Text(_pdfSafe(value),
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: _certDark)),
            ),
          ],
        ),
      );

  /// Briefkopf + zentrierter Titelblock im Urkunden-Stil.
  static pw.Widget _certHeader(
          String title, String subtitle, PdfColor accent, String nr,
          {double titleSize = 19}) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(
                    text: 'CoDriver',
                    style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: accent)),
                const pw.TextSpan(
                    text: '  ·  DA Academy',
                    style: pw.TextStyle(fontSize: 10, color: _certGrey)),
              ]),
            ),
            pw.Text('Nachweis-Nr. $nr',
                style: const pw.TextStyle(fontSize: 9, color: _certGrey)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFE1E4EA)),
        pw.SizedBox(height: 26),
        pw.Text(_pdfSafe(title),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
                fontSize: titleSize,
                fontWeight: pw.FontWeight.bold,
                color: _certDark,
                letterSpacing: 2.2)),
        pw.SizedBox(height: 7),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 40),
          child: pw.Text(_pdfSafe(subtitle),
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(
                  fontSize: 9.5, color: _certGrey, lineSpacing: 1.4)),
        ),
        pw.SizedBox(height: 14),
        pw.Center(child: pw.Container(width: 76, height: 2.4, color: accent)),
        pw.SizedBox(height: 22),
      ]);

  /// Rundes „digital signiert“-Siegel im Prüfsiegel-Stil.
  static pw.Widget _certSeal(
          PdfColor accent, String line1, String line2, String dateText) =>
      pw.Container(
        width: 86,
        height: 86,
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: accent, width: 1.6),
        ),
        child: pw.Container(
          margin: const pw.EdgeInsets.all(3.5),
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: accent, width: 0.6),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(line1,
                  style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: accent,
                      letterSpacing: 0.6)),
              pw.SizedBox(height: 2),
              pw.Text(line2,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                      fontSize: 6.4,
                      fontWeight: pw.FontWeight.bold,
                      color: accent,
                      letterSpacing: 0.8)),
              pw.SizedBox(height: 3),
              pw.Container(width: 30, height: 0.7, color: accent),
              pw.SizedBox(height: 3),
              pw.Text(dateText,
                  style: const pw.TextStyle(fontSize: 7, color: _certGrey)),
            ],
          ),
        ),
      );

  /// Doppelter Urkundenrahmen um den Seiteninhalt.
  static pw.Widget _certFrame(PdfColor accent, pw.Widget child) => pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: accent, width: 1.4),
        ),
        padding: const pw.EdgeInsets.all(4),
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
                color: const PdfColor.fromInt(0xFFD5DAE2), width: 0.7),
          ),
          padding: const pw.EdgeInsets.fromLTRB(34, 26, 34, 22),
          child: child,
        ),
      );

  static pw.Widget _certTopicList(List<String> topics, PdfColor accent) =>
      pw.Wrap(
        spacing: 12,
        runSpacing: 3,
        children: [
          for (final topic in topics)
            pw.SizedBox(
              width: 224,
              child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                        margin: const pw.EdgeInsets.only(top: 2),
                        width: 7,
                        height: 7,
                        decoration: pw.BoxDecoration(
                            color: accent,
                            borderRadius: pw.BorderRadius.circular(2))),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                        child: pw.Text(_pdfSafe(topic),
                            style: const pw.TextStyle(
                                fontSize: 9, color: _certDark))),
                  ]),
            ),
        ],
      );

  static pw.Widget _certLegalBox(String text) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF8FAFC),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
        ),
        child: pw.Text(_pdfSafe(text),
            style: const pw.TextStyle(
                fontSize: 8, color: _certGrey, lineSpacing: 1.6)),
      );

  static pw.Widget _certSignatures({
    required pw.MemoryImage sig,
    required String leftText,
    required String rightText,
    required pw.Widget sealWidget,
  }) =>
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
        sealWidget,
        pw.SizedBox(width: 26),
        pw.Expanded(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 58),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(
                          top: pw.BorderSide(color: _certGrey, width: 0.8))),
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(_pdfSafe(leftText),
                      style:
                          const pw.TextStyle(fontSize: 8, color: _certGrey)),
                ),
              ]),
        ),
        pw.SizedBox(width: 26),
        pw.Expanded(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                    height: 54,
                    alignment: pw.Alignment.bottomLeft,
                    child: pw.Image(sig, height: 50, fit: pw.BoxFit.contain)),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(
                          top: pw.BorderSide(color: _certGrey, width: 0.8))),
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(_pdfSafe(rightText),
                      style:
                          const pw.TextStyle(fontSize: 8, color: _certGrey)),
                ),
              ]),
        ),
      ]);

  static pw.Widget _certFooter(String text) => pw.Column(children: [
        pw.SizedBox(height: 14),
        pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFE1E4EA)),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(_pdfSafe(text),
              style: const pw.TextStyle(fontSize: 7.5, color: _certGrey)),
        ),
      ]);

  Future<Uint8List> _buildCertificatePdf({
    required Uint8List signaturePng,
    required String driverName,
    required String employeeNumber,
    required String companyName,
    required int correct,
    required DateTime completedAt,
    required DateTime validUntil,
  }) async {
    final doc = pw.Document();
    final sigImage = pw.MemoryImage(signaturePng);
    const blue = PdfColor.fromInt(0xFF5C4B99);
    final dateText = DateFormat('dd.MM.yyyy').format(completedAt);
    final nr = completedAt.millisecondsSinceEpoch.toString();

    // Themenliste = die absolvierten Kapitel (deutsch, Audit-Doku).
    final topics = [
      for (final ch in privacyChaptersFor('de')) ch.title,
    ];

    // Kein Testergebnis, keine Transporter-ID, kein „BESTANDEN“-Badge —
    // schlichter Urkunden-Stil wie die regenerierten Bestands-PDFs.
    final body = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _certHeader(
            'DATENSCHUTZ-SCHULUNGSNACHWEIS',
            'Datenschutzschulung nach Art. 32 DSGVO i. V. m. Art. 39 Abs. 1 '
                'lit. b DSGVO; Nachweis gemäß Art. 5 Abs. 2 DSGVO '
                '(Rechenschaftspflicht)',
            blue,
            nr,
            titleSize: 16),
        _certKv('Unternehmen', companyName.isEmpty ? '-' : companyName),
        _certKv('Schulungsverantwortlich',
            'Geschäftsführung ${companyName.isEmpty ? '' : companyName}'),
        _certKv('Mitarbeiter / Teilnehmer', driverName),
        if (employeeNumber.isNotEmpty) _certKv('Personalnummer', employeeNumber),
        _certKv('Datum der Schulung', dateText),
        _certKv('Form der Schulung',
            'Digitale Schulung mit Verständnistest (CoDriver DA Academy)'),
        _certKv(
            'Gültig bis',
            '${DateFormat('dd.MM.yyyy').format(validUntil)} '
                '(jährliche Wiederholung empfohlen)'),
        pw.SizedBox(height: 10),
        pw.Text('Inhalt der Schulung',
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _certDark)),
        pw.SizedBox(height: 5),
        _certTopicList(topics, blue),
        pw.SizedBox(height: 12),
        _certLegalBox('Mit meiner Unterschrift bestätige ich, dass ich an der '
            'Datenschutz-Schulung teilgenommen und den Inhalt verstanden '
            'habe. Ich hatte Gelegenheit, Fragen zu stellen. Ich '
            'verpflichte mich, personenbezogene Daten ausschließlich für '
            'dienstliche Zwecke zu verarbeiten, Verschwiegenheit zu wahren '
            'und jede Verletzung des Schutzes personenbezogener Daten '
            'unverzüglich zu melden. Die vorstehenden Daten werden zum '
            'Nachweis der Schulung nach Art. 5 Abs. 2 DSGVO erhoben und '
            'verarbeitet. Rechtsgrundlage ist Art. 6 Abs. 1 lit. c und f '
            'DSGVO. Die Daten werden so lange gespeichert, wie sie zum '
            'Nachweis der Durchführung benötigt werden, mindestens aber '
            'bis zu einer folgenden Schulung.'),
        pw.Spacer(),
        _certSignatures(
            sig: sigImage,
            sealWidget: _certSeal(
                blue, 'CoDriver', 'DA ACADEMY\nDIGITAL SIGNIERT', dateText),
            leftText: 'Ort, Datum | Unterschrift Schulungsverantwortlicher\n'
                'Geschäftsführung'
                '${companyName.isEmpty ? '' : ' | $companyName'}',
            rightText: '$dateText | Unterschrift Mitarbeiter\n$driverName'),
        _certFooter('Digital erstellt und signiert über CoDriver DA Academy '
            '· Datenschutzschulung nach Art. 32, 39 DSGVO'),
      ],
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => _certFrame(blue, body),
      ),
    );

    return doc.save();
  }
}
