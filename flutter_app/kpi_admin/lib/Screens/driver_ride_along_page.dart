// lib/Screens/driver_ride_along_page.dart
//
// DA Academy — Ride-Along-Schulung (zweitägige Begleitfahrt eines neuen
// Fahrers mit einem erfahrenen Fahrer als Trainer).
//
// Ablauf: Intro → Kapitelübersicht → Kapitel-Slides → Abschlusstest
// (alle Fragen, 80 % zum Bestehen) → Ergebnis.
//
// Aufbau wie die Green-Book-Schulung: kein Modul-Quiz und kein
// Zertifikat-PDF — nur ein Abschlusstest am Ende. Alle Bedientexte
// laufen über `rideAlongText(...)` und damit über die Sprache des
// Fahrers.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/safety_training/driving_safety_quiz_de.dart';
import '../data/safety_training/ride_along_data.dart';
import '../data/safety_training/ride_along_texts.dart';
import '../data/safety_training/safety_blocks.dart';
import '../widgets/safety_block_view.dart';

const String kRideAlongTestId = 'ride_along';
const double kRideAlongPassThreshold = 0.8;

class DriverRideAlongPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverRideAlongPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverRideAlongPage> createState() => _DriverRideAlongPageState();
}

enum _Step { intro, chapters, slides, exam, done }

class _DriverRideAlongPageState extends State<DriverRideAlongPage> {
  static const _kBg = Color(0xFFF5F7F9);
  static const _kText = Color(0xFF1A2233);
  static const _kMuted = Color(0xFF7A8699);
  static const _kAccent = Color(0xFF2A5FB0);
  static const _kTint = Color(0xFFEAF1FB);
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

  double? _passedScore;
  DateTime? _passedAt;

  List<SafetyChapterContent> get _chapters => rideAlongChaptersFor(_lang);

  List<DrivingQuestion> get _questions => rideAlongQuestionsFor(_lang);

  /// Sprache des Fahrers — steuert alle Bedien-Texte dieser Seite.
  String get _lang => Localizations.localeOf(context).languageCode;

  /// Kurzform für den Text-Lookup mit Fallback locale → en → de.
  String _t(String key, [Map<String, String>? vars]) =>
      rideAlongText(_lang, key, vars: vars);

  /// Bestehensgrenze als ganze Prozentzahl, z. B. „80".
  String get _threshold => (kRideAlongPassThreshold * 100).round().toString();

  DocumentReference<Map<String, dynamic>> get _resultRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('academy_test_results')
      .doc(kRideAlongTestId)
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
      setState(() {
        final score = (data['score'] as num?)?.toDouble();
        if (score != null && score >= kRideAlongPassThreshold) {
          _passedScore = score;
        }
        final at = data['passedAt'];
        if (at is Timestamp) _passedAt = at.toDate();
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
              const Icon(Icons.supervisor_account_rounded,
                  size: 34, color: _kAccent),
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
          child: Row(
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
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => setState(() => _step = _Step.chapters),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(
            _t(passed ? 'btn_view_content' : 'btn_start'),
          ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _t(_slideIndex > 0 ? 'btn_back' : 'btn_overview'),
                ),
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
    final passed = score >= kRideAlongPassThreshold;

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

  void _onContinue(double score, bool passed) {
    if (passed) {
      _saveResult(score);
    } else {
      setState(() {
        _showResult = false;
        _answers.clear();
      });
    }
  }

  Future<void> _saveResult(double score) async {
    setState(() => _submitting = true);
    final now = DateTime.now();
    try {
      await _resultRef.set({
        'driverTransporterId': widget.driverTransporterId,
        'testId': kRideAlongTestId,
        'score': score,
        'passedAt': Timestamp.fromDate(now),
        'total': _questions.length,
        'attempts': _attempts,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        _passedScore = score;
        _passedAt = now;
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
}
