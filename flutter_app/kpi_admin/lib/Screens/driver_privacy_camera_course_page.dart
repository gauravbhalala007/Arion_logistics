// lib/Screens/driver_privacy_camera_course_page.dart
//
// DA Academy — Kurs „Kameras im Fahrzeug – Datenschutz".
//
// Ablauf (Spec §2): 10 Module als Pager → Modul 10 ist der Volltext mit
// Scroll-Gate → Empfangsbestätigung.
//
// GATES:
//   - Quiz: jede Frage muss BEANTWORTET sein, um weiterzukommen. Eine
//     falsche Antwort blockiert NICHT, sie zeigt die Erklärung. Das Quiz
//     ist kein Bestehens-Gate; der Punktestand wandert in den Nachweis.
//   - Modul „document": der Volltext muss geöffnet und bis ans Ende
//     gescrollt worden sein.
//
// KEIN APP-GATE: Der Kurs lässt sich jederzeit verlassen und blockiert
// nichts. Das ist keine Nachlässigkeit, sondern Voraussetzung dafür,
// dass die Freiwilligkeitsargumentation der DSFA trägt.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

import '../data/privacy_camera/privacy_camera_content.dart';
import '../data/privacy_camera/privacy_camera_repository.dart';
import '../data/privacy_camera/privacy_camera_texts.dart';
import '../widgets/privacy_camera_blocks.dart';
import 'driver_privacy_camera_certificate.dart';
import 'driver_safety_training_page.dart' show kSignatureInkBlue;

/// Plattform-Kennzeichen für den Nachweis (Kontextfeld nach Spec §5).
String privacyCameraPlatform() =>
    kIsWeb ? 'web' : defaultTargetPlatform.name;

String privacyCameraFormatDate(DateTime at) =>
    DateFormat('dd.MM.yyyy').format(at);

class DriverPrivacyCameraCoursePage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverPrivacyCameraCoursePage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverPrivacyCameraCoursePage> createState() =>
      _DriverPrivacyCameraCoursePageState();
}

enum _Step { modules, acknowledgement, done }

class _DriverPrivacyCameraCoursePageState
    extends State<DriverPrivacyCameraCoursePage> {
  late final PrivacyCameraRepository _repo = PrivacyCameraRepository(
    dspUid: widget.dspUid,
    driverTransporterId: widget.driverTransporterId,
  );

  late final SignatureController _signatureCtrl = SignatureController(
    penStrokeWidth: 2.6,
    penColor: kSignatureInkBlue,
    exportBackgroundColor: Colors.white,
  );

  PrivacyCameraState? _state;
  PrivacyDriverInfo _driver = const PrivacyDriverInfo(
    name: '',
    employeeNumber: '',
    companyName: '',
  );
  bool _loading = true;
  String? _loadError;

  _Step _step = _Step.modules;
  int _index = 0;

  final Set<String> _completedModuleIds = <String>{};
  final Map<String, int> _answers = <String, int>{};
  bool _docScrolledToEnd = false;
  int _docReadSeconds = 0;

  bool _checkboxConfirmed = false;
  bool _busy = false;
  PrivacyAckOutcome? _outcome;

  String get _lang =>
      Localizations.localeOf(context).languageCode.toLowerCase();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _signatureCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      // Kursinhalte werden v1 nur auf Deutsch ausgeliefert; der Loader
      // fällt automatisch zurück, sobald keine Übersetzung existiert.
      final state = await _repo.load(kPrivacyCourseFallbackLanguage);
      final driver = await _repo.loadDriverInfo();
      if (!mounted) return;
      setState(() {
        _state = state;
        _driver = driver;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = '$e';
        _loading = false;
      });
    }
  }

  // ── Gates ─────────────────────────────────────────────────────────

  bool _canAdvance(PrivacyModule module) {
    for (final q in module.quiz) {
      if (!_answers.containsKey(q.id)) return false;
    }
    if (module.requiresFullScroll && !_docScrolledToEnd) return false;
    return true;
  }

  int get _quizCorrect {
    final course = _state?.bundle.course;
    if (course == null) return 0;
    var n = 0;
    for (final m in course.modules) {
      for (final q in m.quiz) {
        if (_answers[q.id] == q.correctIndex) n++;
      }
    }
    return n;
  }

  void _next(PrivacyCourse course) {
    final module = course.modules[_index];
    _completedModuleIds.add(module.id);
    if (_index >= course.modules.length - 1) {
      setState(() => _step = _Step.acknowledgement);
      return;
    }
    setState(() => _index++);
  }

  void _back() {
    if (_step == _Step.acknowledgement) {
      setState(() => _step = _Step.modules);
      return;
    }
    if (_index == 0) {
      widget.onBack();
      return;
    }
    setState(() => _index--);
  }

  // ── Nachweis speichern ────────────────────────────────────────────

  Future<void> _submit(PrivacyAckOutcome outcome) async {
    final state = _state;
    if (state == null) return;
    setState(() => _busy = true);
    try {
      Uint8List? signatureBytes;
      String? signature;
      if (outcome == PrivacyAckOutcome.acknowledged &&
          _signatureCtrl.isNotEmpty) {
        signatureBytes = await _signatureCtrl.toPngBytes(height: 160);
        if (signatureBytes != null) signature = base64Encode(signatureBytes);
      }

      final doc = state.document;
      final copy = state.bundle.course.acknowledgement;
      final statement = copy.statementFor(
        privacyCameraFormatDate(doc.ref.validFrom),
      );

      final ack = PrivacyCameraAck(
        driverTransporterId: widget.driverTransporterId.trim(),
        driverName: _driver.name,
        courseId: state.bundle.course.courseId,
        contentVersion: state.bundle.course.contentVersion,
        documentKey: doc.ref.documentKey,
        documentVersion: doc.ref.version,
        documentContentSha256: doc.contentSha256,
        statementShown: statement,
        outcome: outcome,
        occurredAt: DateTime.now(),
        checkboxConfirmed: outcome == PrivacyAckOutcome.acknowledged,
        signaturePngBase64: signature,
        documentScrolledToEnd: _docScrolledToEnd,
        documentReadSeconds: _docReadSeconds,
        completedModuleIds: _completedModuleIds.toList()..sort(),
        quizCorrect: _quizCorrect,
        quizTotal: state.bundle.course.quizTotal,
        appVersion: kPrivacyCameraAppVersion,
        platform: privacyCameraPlatform(),
        locale: state.bundle.course.locale,
      );

      await _repo.submitAcknowledgement(ack, previous: state.ack);

      // Bescheinigung nur bei Kenntnisnahme. Bewusst NACH dem Nachweis
      // und in eigenem try: schlägt die PDF-Erzeugung fehl, bleibt die
      // Kenntnisnahme trotzdem gespeichert — der Nachweis ist das
      // rechtlich Entscheidende, das PDF nur seine Ausfertigung.
      if (outcome == PrivacyAckOutcome.acknowledged) {
        try {
          final pdf = await buildPrivacyCameraCertificatePdf(
            signaturePng: signatureBytes,
            driverName: _driver.name,
            employeeNumber: _driver.employeeNumber,
            companyName: _driver.companyName,
            occurredAt: ack.occurredAt,
            documentTitle: doc.ref.title,
            documentVersion: doc.ref.version,
            contentSha256: doc.contentSha256,
            moduleTitles: [
              for (final m in state.bundle.course.modules) m.title,
            ],
            statementShown: statement,
            clarification: copy.clarification,
          );
          await _repo.storeCertificate(
            pdfBytes: pdf,
            occurredAt: ack.occurredAt,
            documentVersion: doc.ref.version,
            contentSha256: doc.contentSha256,
          );
        } catch (_) {
          // Kein harter Fehler für den Fahrer — die Kenntnisnahme steht.
        }
      }

      if (!mounted) return;
      setState(() {
        _outcome = outcome;
        _step = _Step.done;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            privacyCameraText(_lang, 'ack_save_error', vars: {'error': '$e'}),
          ),
        ),
      );
    }
  }

  /// „Ich möchte nicht bestätigen" — gleichwertiger Weg, kein Fehlerfall.
  /// Der Dialog erklärt nur die Folge; er warnt nicht und drängt nicht.
  Future<void> _confirmDecline() async {
    final copy = _state!.bundle.course.acknowledgement;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(copy.declineLabel),
        content: Text(copy.declineExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(privacyCameraText(_lang, 'ack_back')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(privacyCameraText(_lang, 'ack_decline_confirm')),
          ),
        ],
      ),
    );
    if (ok == true) await _submit(PrivacyAckOutcome.declined);
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: kPcBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final state = _state;
    if (state == null) {
      return Scaffold(
        backgroundColor: kPcBg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _loadError ?? 'Inhalt konnte nicht geladen werden.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kPcMuted),
            ),
          ),
        ),
      );
    }

    switch (_step) {
      case _Step.modules:
        return _buildModules(state);
      case _Step.acknowledgement:
        return _buildAcknowledgement(state);
      case _Step.done:
        return _buildDone(state);
    }
  }

  PreferredSizeWidget _appBar(String title, {double? progress}) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: kPcText,
        onPressed: _busy ? null : _back,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: kPcText,
        ),
      ),
      bottom: progress == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: const Color(0xFFE8EDF2),
                valueColor: const AlwaysStoppedAnimation<Color>(kPcAccent),
              ),
            ),
    );
  }

  Widget _buildModules(PrivacyCameraState state) {
    final course = state.bundle.course;
    final module = course.modules[_index];
    final canAdvance = _canAdvance(module);
    final isLast = _index == course.modules.length - 1;

    return Scaffold(
      backgroundColor: kPcBg,
      appBar: _appBar(
        privacyCameraText(
          _lang,
          'course_progress',
          vars: {'n': '${_index + 1}', 'total': '${course.modules.length}'},
        ),
        progress: (_index + 1) / course.modules.length,
      ),
      body: ListView(
        key: ValueKey(module.id),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: kPcAccentBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  privacyModuleIcon(module.icon),
                  size: 20,
                  color: kPcAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: kPcText,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final block in module.blocks)
            PrivacyBlockView(
              block: block,
              onOpenDocument: (key) => _openDocument(state, key),
            ),
          if (module.quiz.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(color: kPcBorder),
            const SizedBox(height: 10),
            Text(
              privacyCameraText(_lang, 'quiz_headline'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: kPcText,
              ),
            ),
            const SizedBox(height: 10),
            for (final q in module.quiz)
              _QuizCard(
                question: q,
                selected: _answers[q.id],
                onSelect: (i) => setState(() => _answers[q.id] = i),
              ),
          ],
          if (module.requiresFullScroll && !_docScrolledToEnd)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                privacyCameraText(_lang, 'doc_gate_hint'),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9A5B00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        child: SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: canAdvance ? () => _next(course) : null,
            style: _primaryButtonStyle,
            child: Text(
              isLast
                  ? privacyCameraText(_lang, 'course_to_ack')
                  : privacyCameraText(_lang, 'course_next'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDocument(
    PrivacyCameraState state,
    String documentKey,
  ) async {
    final doc = state.bundle.documents[documentKey];
    if (doc == null) return;
    final result = await Navigator.of(context).push<_DocumentReadResult>(
      MaterialPageRoute(
        builder: (_) => PrivacyDocumentReaderPage(
          document: doc,
          requireScrollToEnd: true,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _docReadSeconds += result.seconds;
      _docScrolledToEnd = _docScrolledToEnd || result.scrolledToEnd;
    });
  }

  Widget _buildAcknowledgement(PrivacyCameraState state) {
    final copy = state.bundle.course.acknowledgement;
    final doc = state.document;
    final statement = copy.statementFor(
      privacyCameraFormatDate(doc.ref.validFrom),
    );
    final hash = doc.contentSha256.length > 12
        ? '${doc.contentSha256.substring(0, 12)}…'
        : doc.contentSha256;

    return Scaffold(
      backgroundColor: kPcBg,
      appBar: _appBar(copy.headline),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            copy.intro,
            style: const TextStyle(fontSize: 15, height: 1.55, color: kPcText),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: kPcBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verbindlicher Wortlaut aus Spec §7 — nicht umformulieren.
                Text(
                  statement,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    fontWeight: FontWeight.w700,
                    color: kPcText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  copy.clarification,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: Color(0xFF4B5563),
                  ),
                ),
                if (copy.systemNote.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: kPcAccentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      copy.systemNote,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF14538C),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  '${privacyCameraText(_lang, 'doc_version', vars: {'version': doc.ref.version})} · '
                  '${privacyCameraText(_lang, 'doc_checksum', vars: {'hash': hash})}',
                  style: const TextStyle(fontSize: 11, color: kPcMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: kPcBorder),
            ),
            child: CheckboxListTile(
              value: _checkboxConfirmed,
              onChanged: _busy
                  ? null
                  : (v) => setState(() => _checkboxConfirmed = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              title: Text(
                copy.checkboxLabel,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: kPcText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                copy.signatureHint,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kPcText,
                ),
              ),
              const SizedBox(width: 8),
              if (copy.signatureOptional)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _lang == 'de' ? 'freiwillig' : 'optional',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: kPcMuted,
                    ),
                  ),
                ),
            ],
          ),
          if (copy.signatureOptionalHint.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              copy.signatureOptionalHint,
              style: const TextStyle(fontSize: 13, color: kPcMuted, height: 1.4),
            ),
          ],
          if (copy.signatureLegalNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Klarstellung UNMITTELBAR am Unterschriftsfeld: Die
            // Unterschrift belegt Erhalt und Kenntnisnahme, nicht mehr.
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: kPcAccentBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB9D4F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Color(0xFF14538C),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      copy.signatureLegalNote,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: Color(0xFF14538C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: kPcBorder, width: 1.4),
            ),
            clipBehavior: Clip.antiAlias,
            child: Signature(
              controller: _signatureCtrl,
              backgroundColor: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _busy ? null : () => _signatureCtrl.clear(),
              icon: const Icon(Icons.backspace_outlined, size: 16),
              label: Text(privacyCameraText(_lang, 'ack_signature_clear')),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _busy || !_checkboxConfirmed
                  ? null
                  : () => _submit(PrivacyAckOutcome.acknowledged),
              style: _primaryButtonStyle,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(copy.submitLabel),
            ),
          ),
          const SizedBox(height: 8),
          // Gleichwertig gestalteter Weg — sichtbar, nicht versteckt.
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _busy ? null : _confirmDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: kPcText,
                side: const BorderSide(color: kPcBorder, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(copy.declineLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDone(PrivacyCameraState state) {
    final copy = state.bundle.course.acknowledgement;
    final acknowledged = _outcome == PrivacyAckOutcome.acknowledged;
    return Scaffold(
      backgroundColor: kPcBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: acknowledged
                      ? const Color(0xFFE4F5EC)
                      : const Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  acknowledged
                      ? Icons.check_rounded
                      : Icons.assignment_turned_in_outlined,
                  size: 32,
                  color: acknowledged
                      ? const Color(0xFF16704F)
                      : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                acknowledged ? copy.successTitle : copy.declinedTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: kPcText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                acknowledged ? copy.successText : copy.declinedText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.55,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: widget.onBack,
                  style: _primaryButtonStyle,
                  child: Text(privacyCameraText(_lang, 'ok')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final ButtonStyle _primaryButtonStyle = FilledButton.styleFrom(
  backgroundColor: kPcAccent,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
);

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kPcBorder)),
        ),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// Quizkarte. Nach der Antwort wird die Erklärung gezeigt — auch bei
/// einer falschen Antwort geht es weiter.
class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final PrivacyQuizQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final answered = selected != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: kPcBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: kPcText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 11),
          for (var i = 0; i < question.options.length; i++)
            _option(i, answered),
          if (answered && question.explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              question.explanation,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _option(int i, bool answered) {
    final isSelected = selected == i;
    final isCorrect = i == question.correctIndex;
    Color border = kPcBorder;
    Color bg = Colors.white;
    if (answered && isCorrect) {
      border = const Color(0xFF16704F);
      bg = const Color(0xFFE4F5EC);
    } else if (answered && isSelected) {
      border = const Color(0xFFB3261E);
      bg = const Color(0xFFFDECEA);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: answered ? null : () => onSelect(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: border,
                width: border == kPcBorder ? 1 : 1.6,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question.options[i],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: kPcText,
                    ),
                  ),
                ),
                if (answered && isCorrect)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Color(0xFF16704F),
                  )
                else if (answered && isSelected)
                  const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFFB3261E),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Volltext mit Scroll-Gate ────────────────────────────────────────

class _DocumentReadResult {
  final int seconds;
  final bool scrolledToEnd;
  const _DocumentReadResult(this.seconds, this.scrolledToEnd);
}

/// Volltext einer Datenschutzerklärung.
///
/// Mit [requireScrollToEnd] aktiviert sich der Abschluss-Button erst,
/// wenn wirklich bis ans Ende gescrollt wurde — das ist der Kern des
/// Nachweises „ich habe das nie gesehen" zu widerlegen.
class PrivacyDocumentReaderPage extends StatefulWidget {
  const PrivacyDocumentReaderPage({
    super.key,
    required this.document,
    this.requireScrollToEnd = false,
  });

  final PrivacyDocument document;
  final bool requireScrollToEnd;

  @override
  State<PrivacyDocumentReaderPage> createState() =>
      _PrivacyDocumentReaderPageState();
}

class _PrivacyDocumentReaderPageState extends State<PrivacyDocumentReaderPage> {
  final ScrollController _scroll = ScrollController();
  final Stopwatch _watch = Stopwatch()..start();
  bool _reachedEnd = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (_reachedEnd || !_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    // Kurze Dokumente ohne Scrollbereich gelten sofort als gelesen.
    if (max <= 0 || _scroll.offset >= max - 24) {
      setState(() => _reachedEnd = true);
    }
  }

  @override
  void dispose() {
    _watch.stop();
    _scroll.dispose();
    super.dispose();
  }

  void _close() {
    _watch.stop();
    Navigator.of(
      context,
    ).pop(_DocumentReadResult(_watch.elapsed.inSeconds, _reachedEnd));
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final canContinue = _reachedEnd || !widget.requireScrollToEnd;
    final ref = widget.document.ref;
    final hash = widget.document.contentSha256.length > 12
        ? '${widget.document.contentSha256.substring(0, 12)}…'
        : widget.document.contentSha256;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: kPcBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: kPcText,
            onPressed: _close,
          ),
          title: Text(
            ref.shortTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kPcText,
            ),
          ),
        ),
        body: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          children: [
            Text(
              '${privacyCameraText(lang, 'doc_version', vars: {'version': ref.version})} · '
              '${privacyCameraText(lang, 'doc_checksum', vars: {'hash': hash})}',
              style: const TextStyle(fontSize: 11.5, color: kPcMuted),
            ),
            const SizedBox(height: 12),
            ...buildPrivacyMarkdown(widget.document.markdown),
          ],
        ),
        bottomNavigationBar: _BottomBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: canContinue ? _close : null,
                  style: _primaryButtonStyle,
                  child: Text(
                    canContinue
                        ? privacyCameraText(lang, 'doc_read_done')
                        : privacyCameraText(lang, 'doc_read_hint'),
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
