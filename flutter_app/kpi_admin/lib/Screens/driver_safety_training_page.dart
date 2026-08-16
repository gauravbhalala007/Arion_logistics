// lib/Screens/driver_safety_training_page.dart
//
// DA Academy — Sicherheitsunterweisung (jährliche Arbeitsschutz-
// Unterweisung für Fahrer).
//
// Ablauf: Intro → 10 Kapitel (Slides mit Illustration) → Test
// (12 Fragen, 80 % zum Bestehen) → Unterschrift (dunkelblau) →
// Nachweis-PDF im TÜV-Berichts-Stil (gemäß § 12 Abs. 1 ArbSchG i. V. m.
// § 4 DGUV Vorschrift 1) → Ablage:
//   - Storage  driver_docs/{tid}/… + Firestore documents/
//     safety_training_certificate (erscheint im Drivers Hub)
//   - academy_test_results/safety_training/drivers/{tid}
//     (Admin-Übersicht + 12-Monats-Gültigkeit)
//
// Inhalte/Sprachen: lib/data/safety_training/ (10 Sprachen, Fallback en→de).

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';

import '../data/safety_training/safety_blocks.dart';
import '../data/safety_training/safety_training_data.dart';
import '../widgets/safety_block_view.dart';

/// Dunkles Signatur-Blau (Tinten-Optik) — Vorgabe fürs Nachweis-PDF.
const Color kSignatureInkBlue = Color(0xFF1E3A8A);

class DriverSafetyTrainingPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverSafetyTrainingPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverSafetyTrainingPage> createState() =>
      _DriverSafetyTrainingPageState();
}

enum _Step { intro, chapters, chapterDetail, test, signature, done }

class _DriverSafetyTrainingPageState extends State<DriverSafetyTrainingPage> {
  static const _kBg = Color(0xFFF5F7F9);
  static const _kText = Color(0xFF111827);
  static const _kMuted = Color(0xFF6B7280);
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kMint = Color(0xFFE4F5EC);

  static const _kLine = Color(0xFFE3E8EF);

  _Step _step = _Step.intro;
  int _chapterIndex = 0;
  int _slideIndex = 0;

  /// Kapitel, die der Fahrer bis zur letzten Seite durchgeblättert hat.
  final Set<String> _doneChapters = <String>{};

  // Test-State
  final Map<int, int> _answers = {};
  int? _lastScore;

  // Signatur-State
  late final SignatureController _signatureCtrl;
  bool _confirmed = false;
  bool _submitting = false;

  // Status (bestehender Abschluss)
  DateTime? _validUntil;

  String get _lang => Localizations.localeOf(context).languageCode;
  String t(String key) => safetyText(_lang, key);

  DocumentReference<Map<String, dynamic>> get _resultRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(widget.dspUid)
      .collection('academy_test_results')
      .doc(kSafetyTrainingTestId)
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
    _signatureCtrl = SignatureController(
      penStrokeWidth: 2.6,
      penColor: kSignatureInkBlue,
      exportBackgroundColor: Colors.white,
    );
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final snap = await _resultRef.get();
      final vu = snap.data()?['validUntil'];
      if (vu is Timestamp && mounted) {
        setState(() => _validUntil = vu.toDate());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _signatureCtrl.dispose();
    super.dispose();
  }

  int get _passThreshold =>
      (kSafetyQuestions.length * kSafetyTrainingPassRatio).ceil();

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
              case _Step.chapterDetail:
                setState(() => _step = _Step.chapters);
              case _Step.chapters:
                setState(() => _step = _Step.intro);
              case _Step.test:
                setState(() => _step = _Step.chapters);
              case _Step.intro:
              case _Step.signature:
              case _Step.done:
                widget.onBack();
            }
          },
        ),
        title: Text(
          t('training_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: switch (_step) {
          _Step.intro => _buildIntro(),
          _Step.chapters => _buildChapterList(),
          _Step.chapterDetail => _buildChapterDetail(),
          _Step.test => _buildTest(),
          _Step.signature => _buildSignature(),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            color: Colors.white,
            child: SvgPicture.asset(
              'assets/academy/safety/cover.svg',
              height: 190,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          t('training_subtitle'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _kGreen,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('training_intro'),
          style: const TextStyle(fontSize: 14.5, height: 1.5, color: _kText),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: valid
                ? _kMint
                : expired
                    ? const Color(0xFFFEE2E2)
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
                        ? const Color(0xFFB91C1C)
                        : _kMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  valid
                      ? t('status_valid_until').replaceAll(
                          '{date}',
                          DateFormat('dd.MM.yyyy').format(_validUntil!),
                        )
                      : expired
                          ? t('status_expired')
                          : t('status_open'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: valid
                        ? _kGreen
                        : expired
                            ? const Color(0xFFB91C1C)
                            : _kMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => setState(() {
            _step = _Step.chapters;
            _chapterIndex = 0;
            _slideIndex = 0;
          }),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(t('btn_start')),
          style: FilledButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Kapitel-Übersicht ────────────────────────────────────────────

  Widget _buildChapterList() {
    final chapters = safetyChaptersFor(_lang);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(
          t('chapters_overview_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _kText,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('chapters_overview_hint'),
          style: const TextStyle(fontSize: 13.5, color: _kMuted, height: 1.45),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < chapters.length; i++)
          _chapterCard(i, chapters[i]),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _allChaptersDone
              ? () => setState(() {
                    _answers.clear();
                    _lastScore = null;
                    _step = _Step.test;
                  })
              : null,
          icon: const Icon(Icons.quiz_rounded, size: 18),
          label: Text(
            _allChaptersDone
                ? t('btn_start_test')
                : t('btn_test_locked'),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  bool get _allChaptersDone =>
      _doneChapters.length >= safetyChaptersFor(_lang).length;

  Widget _chapterCard(int index, SafetyChapterContent ch) {
    final done = _doneChapters.contains(ch.id);
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
            _step = _Step.chapterDetail;
          }),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: done ? _kGreen.withValues(alpha: 0.45) : _kLine,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: done ? _kGreen : _kMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? const Icon(Icons.check_rounded,
                          size: 20, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 15,
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
                        ch.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ch.summary,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _kMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        t('chapter_pages')
                            .replaceAll('{n}', '${ch.slides.length}'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _kGreen,
                          letterSpacing: 0.3,
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

  // ── Kapitel-Detail (Seiten) ──────────────────────────────────────

  Widget _buildChapterDetail() {
    final chapters = safetyChaptersFor(_lang);
    final ch = chapters[_chapterIndex];
    final slide = ch.slides[_slideIndex];
    final isLastSlide = _slideIndex == ch.slides.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kapitel-Kopf mit Seitenfortschritt
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      '${_chapterIndex + 1}',
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
                      ch.title.toUpperCase(),
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
                    '${_slideIndex + 1}/${ch.slides.length}',
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
                  for (var i = 0; i < ch.slides.length; i++)
                    Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                            right: i == ch.slides.length - 1 ? 0 : 4),
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
            key: ValueKey('${ch.id}_$_slideIndex'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              if (slide.asset != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: SvgPicture.asset(
                      slide.asset!,
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

        // Ticket: Auf JEDER Seite der Unterweisung sichtbar — wer eine
        // Frage hat, soll wissen, an wen er sich wenden kann. Bewusst
        // ueber der Navigation, damit der Hinweis nicht weggescrollt
        // werden kann.
        _askAnytimeBar(t),

        // Navigation
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
                  foregroundColor: _kGreen,
                  side: const BorderSide(color: _kGreen),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(_slideIndex > 0 ? t('btn_back') : t('btn_overview')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (!isLastSlide) {
                      setState(() => _slideIndex++);
                    } else {
                      setState(() {
                        _doneChapters.add(ch.id);
                        _step = _Step.chapters;
                      });
                    }
                  },
                  icon: Icon(
                    isLastSlide
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isLastSlide ? t('btn_chapter_done') : t('btn_next'),
                  ),
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

  // ── Test ──────────────────────────────────────────────────────────

  Widget _buildTest() {
    final total = kSafetyQuestions.length;
    final answered = _answers.length;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
            children: [
              Text(
                t('test_title'),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t('test_intro'),
                style: const TextStyle(fontSize: 13.5, color: _kMuted),
              ),
              if (_lastScore != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    t('test_failed')
                        .replaceAll('{score}', '$_lastScore')
                        .replaceAll('{total}', '$total'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              for (var qi = 0; qi < kSafetyQuestions.length; qi++) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${qi + 1}. ${t(kSafetyQuestions[qi].questionKey)}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (var oi = 0;
                          oi < kSafetyQuestions[qi].optionKeys.length;
                          oi++)
                        RadioListTile<int>(
                          value: oi,
                          groupValue: _answers[qi],
                          onChanged: (v) =>
                              setState(() => _answers[qi] = v ?? 0),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: _kGreen,
                          title: Text(
                            t(kSafetyQuestions[qi].optionKeys[oi]),
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: answered == total ? _submitTest : null,
              icon: const Icon(Icons.checklist_rounded, size: 18),
              label: Text(
                answered == total
                    ? t('btn_submit_test')
                    : '${t('btn_submit_test')} ($answered/$total)',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitTest() {
    var score = 0;
    for (var i = 0; i < kSafetyQuestions.length; i++) {
      if (_answers[i] == kSafetyQuestions[i].correctIndex) score++;
    }
    if (score >= _passThreshold) {
      setState(() {
        _lastScore = score;
        _step = _Step.signature;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF067647),
          content: Text(
            t('test_passed')
                .replaceAll('{score}', '$score')
                .replaceAll('{total}', '${kSafetyQuestions.length}'),
          ),
        ),
      );
    } else {
      setState(() {
        _lastScore = score;
        _answers.clear();
      });
    }
  }

  // ── Unterschrift ─────────────────────────────────────────────────

  Widget _buildSignature() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        Text(
          t('signature_title'),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t('signature_hint'),
          style: const TextStyle(fontSize: 13.5, height: 1.5, color: _kMuted),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kMint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            t('test_passed')
                .replaceAll('{score}', '${_lastScore ?? 0}')
                .replaceAll('{total}', '${kSafetyQuestions.length}'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _kGreen,
            ),
          ),
        ),
        CheckboxListTile(
          value: _confirmed,
          onChanged: (v) => setState(() => _confirmed = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: _kGreen,
          title: Text(
            t('confirm_checkbox'),
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
                      label: Text(t('btn_clear')),
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
          label: Text(t('btn_sign_submit')),
          style: FilledButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completeTraining() async {
    final de = _lang == 'de';
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('confirm_checkbox'))),
      );
      return;
    }
    if (_signatureCtrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('signature_hint'))),
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
      final validUntil = now.add(kSafetyTrainingValidity);
      final score = _lastScore ?? 0;

      final pdfBytes = await _buildCertificatePdf(
        signaturePng: signaturePng,
        driverName: driverName,
        employeeNumber: employeeNumber,
        companyName: companyName,
        score: score,
        completedAt: now,
        validUntil: validUntil,
      );

      // 1) PDF in Storage ablegen (Fahrer darf in driver_docs/{tid}/).
      final filename =
          'Unterweisungsnachweis_${DateFormat('yyyy-MM-dd').format(now)}.pdf';
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
          .doc('safety_training_certificate')
          .set({
        'fileName': filename,
        'downloadUrl': url,
        'storagePath': storageRef.fullPath,
        'contentType': 'application/pdf',
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedAtClient': Timestamp.now(),
        'size': pdfBytes.length,
        'docType': 'safety_training_certificate',
        'uploadedBy': 'driver',
        'completedAt': Timestamp.fromDate(now),
        'validUntil': Timestamp.fromDate(validUntil),
        'score': score,
        'total': kSafetyQuestions.length,
      }, SetOptions(merge: true));

      // 3) Abschluss für die Admin-Übersicht + Gültigkeit.
      await _resultRef.set({
        'driverTransporterId': widget.driverTransporterId,
        'testId': kSafetyTrainingTestId,
        'driverName': driverName,
        'employeeNumber': employeeNumber,
        'score': score,
        'total': kSafetyQuestions.length,
        'passedAt': Timestamp.fromDate(now),
        'validUntil': Timestamp.fromDate(validUntil),
        'certificateUrl': url,
        'language': _lang,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _validUntil = validUntil;
        _step = _Step.done;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Abschluss fehlgeschlagen: $e' : 'Completion failed: $e',
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
        const Icon(Icons.verified_rounded, size: 72, color: _kGreen),
        const SizedBox(height: 14),
        Text(
          t('cert_done_title'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _kText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('cert_done_body'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5, color: _kMuted),
        ),
        if (_validUntil != null) ...[
          const SizedBox(height: 10),
          Text(
            t('status_valid_until').replaceAll(
              '{date}',
              DateFormat('dd.MM.yyyy').format(_validUntil!),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: _kGreen,
            ),
          ),
        ],
        const SizedBox(height: 22),
        FilledButton(
          onPressed: widget.onBack,
          style: FilledButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(t('btn_finish')),
        ),
      ],
    );
  }

  // ── Nachweis-PDF (TÜV-Berichts-Stil, dezente CoDriver-Farben) ────

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
    required int score,
    required DateTime completedAt,
    required DateTime validUntil,
  }) async {
    final doc = pw.Document();
    final sigImage = pw.MemoryImage(signaturePng);
    const green = PdfColor.fromInt(0xFF1D7F5A);
    final dateText = DateFormat('dd.MM.yyyy').format(completedAt);
    final nr = completedAt.millisecondsSinceEpoch.toString();

    // Themenliste = tatsächlich absolvierte Kapitel (deutsch, Audit-Doku).
    final topics = [
      for (final ch in safetyChaptersFor('de')) ch.title,
    ];

    // Kein Testergebnis, keine Transporter-ID, kein „BESTANDEN“-Badge —
    // schlichter Urkunden-Stil wie die regenerierten Bestands-PDFs.
    final body = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _certHeader(
            'UNTERWEISUNGSNACHWEIS',
            'Sicherheitsunterweisung gemäß § 12 Abs. 1 Arbeitsschutzgesetz '
                '(ArbSchG) i. V. m. § 4 DGUV Vorschrift 1',
            green,
            nr),
        _certKv('Unternehmen', companyName.isEmpty ? '-' : companyName),
        _certKv('Unterweisender',
            'Geschäftsführung ${companyName.isEmpty ? '' : companyName}'),
        _certKv('Mitarbeiter / Teilnehmer', driverName),
        if (employeeNumber.isNotEmpty) _certKv('Personalnummer', employeeNumber),
        _certKv('Datum der Unterweisung', dateText),
        _certKv('Form der Unterweisung',
            'Digitale Unterweisung mit Verständnistest (CoDriver DA Academy)'),
        _certKv(
            'Gültig bis',
            '${DateFormat('dd.MM.yyyy').format(validUntil)} '
                '(jährliche Wiederholung gem. § 12 ArbSchG / DGUV V1)'),
        pw.SizedBox(height: 10),
        pw.Text('Inhalt der Unterweisung',
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _certDark)),
        pw.SizedBox(height: 5),
        _certTopicList(topics, green),
        pw.SizedBox(height: 12),
        _certLegalBox('Mit meiner Unterschrift bestätige ich, dass ich an der '
            'Unterweisung teilgenommen und den Inhalt verstanden habe. '
            'Ich hatte Gelegenheit, Fragen zu stellen. Die vorstehenden '
            'Daten werden im Rahmen der gesetzlich verpflichtenden '
            'Arbeitsschutz-Unterweisung erhoben und verarbeitet. '
            'Rechtsgrundlage hierfür ist Art. 6 Abs. 1 lit. c) und f) '
            'der Datenschutz-Grundverordnung (DSGVO). Die Daten werden '
            'so lange gespeichert, wie sie zur Erfüllung der '
            'Dokumentationspflicht sowie zum Nachweis der Durchführung '
            'benötigt werden, mindestens aber zwei Jahre bzw. bis zu '
            'einer folgenden Unterweisung.'),
        pw.Spacer(),
        _certSignatures(
            sig: sigImage,
            sealWidget: _certSeal(
                green, 'CoDriver', 'DA ACADEMY\nDIGITAL SIGNIERT', dateText),
            leftText: 'Ort, Datum | Unterschrift Unterweisender\n'
                'Geschäftsführung'
                '${companyName.isEmpty ? '' : ' | $companyName'}',
            rightText: '$dateText | Unterschrift Mitarbeiter\n$driverName'),
        _certFooter('Digital erstellt und signiert über CoDriver DA Academy '
            '· Jährliche Unterweisung nach § 12 ArbSchG / '
            'DGUV Vorschrift 1'),
      ],
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => _certFrame(green, body),
      ),
    );
    return doc.save();
  }

  /// Dauerhafter Hinweis auf jeder Seite der Unterweisung: Bei Fragen
  /// kann man sich jederzeit an Manager, Dispatcher oder die
  /// Geschaeftsfuehrung wenden. Eine Unterweisung, bei der man nicht
  /// nachfragen kann, erfuellt ihren Zweck nur halb.
  Widget _askAnytimeBar(String Function(String) t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _kMint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kGreen.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.help_outline_rounded, size: 17, color: _kGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t('ask_anytime'),
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: Color(0xFF2E4A3E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

