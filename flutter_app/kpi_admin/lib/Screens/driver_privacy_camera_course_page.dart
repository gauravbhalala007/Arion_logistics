// lib/Screens/driver_privacy_camera_course_page.dart
//
// DA Academy — Kurs „Kameras im Fahrzeug – Datenschutz".
//
// Ablauf: 9 Lese-/Infomodule als Pager → das letzte Modul ist der
// Volltext mit Scroll-Gate → Empfangsbestätigung.
//
// KEIN QUIZ: Die Module sind reine Informationsseiten mit „Weiter".
//
// EINZIGES GATE: Im Modul „document" muss der Volltext geöffnet und bis
// ans Ende gelesen worden sein.
//
// ABSCHLUSS: Die Empfangsbestätigung ist der VERPFLICHTENDE letzte
// Schritt. Der Kurs gilt erst mit ihr als abgeschlossen; es gibt keinen
// Weg am Bestätigungsschritt vorbei.
//
// KEIN WEIGERUNGS-EINDRUCK: Es gibt keinen Ablehnen-Weg mehr. Wer noch
// nicht bestätigen möchte, wählt den zurückhaltenden Textlink „Später" —
// dann wird NICHTS gespeichert und nichts vermerkt, der Kurs bleibt
// einfach offen. Der Ausgang `declined` entsteht im Fahrer-Flow nicht
// mehr; der Enum-Wert bleibt nur erhalten, um Bestandsdaten aus früheren
// Fassungen weiterhin lesen und anzeigen zu können.
//
// KEIN APP-GATE: Der Kurs lässt sich jederzeit verlassen und blockiert
// die App nie.
//
// SPRACHE: Der Kurs läuft in der App-Sprache des Fahrers. Der
// VERBINDLICHE Wortlaut der Empfangsbestätigung (Spec §7) bleibt in
// jeder Sprache zusätzlich auf Deutsch sichtbar und wird so gespeichert.

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

  /// Kenntnisnahme-Beleg: durchlaufene Module, Scroll-Gate im Volltext
  /// und Lesedauer. Ein Quiz gibt es in diesem Kurs bewusst nicht.
  final Set<String> _completedModuleIds = <String>{};
  bool _docScrolledToEnd = false;
  int _docReadSeconds = 0;

  bool _checkboxConfirmed = false;

  /// Ob im Unterschriftsfeld etwas steht. Die Unterschrift ist
  /// VERPFLICHTEND — sie belegt zusammen mit der Checkbox den Empfang
  /// und die Kenntnisnahme (keine Einwilligung, siehe
  /// `signatureLegalNote` direkt am Feld).
  bool _hasSignature = false;
  bool _busy = false;

  String get _lang =>
      Localizations.localeOf(context).languageCode.toLowerCase();

  bool _loadStarted = false;

  @override
  void initState() {
    super.initState();
    // Der SignatureController meldet jeden Strich — daran hängt, ob der
    // Bestätigen-Button aktiv wird.
    _signatureCtrl.addListener(_onSignatureChanged);
  }

  void _onSignatureChanged() {
    final has = _signatureCtrl.isNotEmpty;
    if (has != _hasSignature && mounted) {
      setState(() => _hasSignature = has);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Erst hier ist `Localizations` verfügbar — der Kurs wird in der
    // App-Sprache des Fahrers geladen.
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  @override
  void dispose() {
    _signatureCtrl.removeListener(_onSignatureChanged);
    _signatureCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final state = await _repo.load(_lang);
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

  /// Einziges verbleibendes Gate: der Volltext muss im Modul
  /// „document" geöffnet und bis ans Ende gelesen worden sein.
  bool _canAdvance(PrivacyModule module) =>
      !module.requiresFullScroll || _docScrolledToEnd;

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

  /// Exportiert die Unterschrift als PNG. Ein Fehlversuch wird genau
  /// einmal wiederholt — der Export kann auf Web sporadisch scheitern,
  /// wenn er in einen Frame fällt, in dem die Canvas noch nicht bereit
  /// ist. `null` heißt: endgültig fehlgeschlagen.
  Future<Uint8List?> _exportSignature() async {
    if (_signatureCtrl.isEmpty) return null;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final bytes = await _signatureCtrl.toPngBytes(height: 160);
        if (bytes != null && bytes.isNotEmpty) return bytes;
      } catch (_) {
        // Zweiter Versuch nach einem Frame.
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
    return null;
  }

  /// Speichert die Empfangsbestätigung.
  ///
  /// Es gibt im Fahrer-Flow nur noch DIESEN Ausgang: `acknowledged`.
  /// Wer noch nicht bestätigen will, wählt „Später" — dann wird gar
  /// nichts geschrieben und der Kurs bleibt schlicht offen. Ein
  /// ausdrücklicher Verweigerungs-Nachweis („declined") entsteht nicht
  /// mehr; der Wert bleibt nur zum Lesen von Bestandsdaten erhalten.
  Future<void> _submit() async {
    const outcome = PrivacyAckOutcome.acknowledged;
    final state = _state;
    if (state == null) return;
    setState(() => _busy = true);
    try {
      // Die Unterschrift ist Pflicht und wird VOR dem Nachweis exportiert:
      // Scheitert der PNG-Export, darf gar nichts gespeichert werden —
      // sonst entstünde ein Nachweis, der eine Unterschrift behauptet,
      // die weder im Dokument noch auf der Bescheinigung existiert.
      final signatureBytes = await _exportSignature();
      if (signatureBytes == null) {
        if (!mounted) return;
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              privacyCameraText(_lang, 'signature_export_failed'),
            ),
          ),
        );
        return;
      }
      final signature = base64Encode(signatureBytes);

      final doc = state.document;
      final binding = state.bindingDocument;
      final copy = state.bundle.course.acknowledgement;
      final bindingCopy = state.bundle.bindingAck;
      final dateText = privacyCameraFormatDate(binding.ref.validFrom);

      // Verbindlich ist der DEUTSCHE Wortlaut (Spec §7). Die Übersetzung
      // wird zusätzlich angezeigt und zusätzlich gespeichert.
      final statementDe = bindingCopy.statementFor(dateText);
      final statementLocalized = state.bundle.needsBindingTranslationBlock
          ? copy.statementFor(dateText)
          : null;

      final ack = PrivacyCameraAck(
        driverTransporterId: widget.driverTransporterId.trim(),
        driverName: _driver.name,
        courseId: state.bundle.course.courseId,
        contentVersion: state.bundle.course.contentVersion,
        documentKey: binding.ref.documentKey,
        documentVersion: binding.ref.version,
        documentContentSha256: binding.contentSha256,
        documentDisplayLocale: state.bundle.languageCode,
        documentDisplaySha256: doc.contentSha256,
        statementShown: statementDe,
        statementShownLocalized: statementLocalized,
        statementLocale: state.bundle.languageCode,
        outcome: outcome,
        occurredAt: DateTime.now(),
        checkboxConfirmed: true,
        signaturePngBase64: signature,
        documentScrolledToEnd: _docScrolledToEnd,
        documentReadSeconds: _docReadSeconds,
        completedModuleIds: _completedModuleIds.toList()..sort(),
        appVersion: kPrivacyCameraAppVersion,
        platform: privacyCameraPlatform(),
        locale: state.bundle.course.locale,
      );

      await _repo.submitAcknowledgement(ack, previous: state.ack);

      // Bescheinigung. Bewusst NACH dem Nachweis und in eigenem try:
      // schlägt die PDF-Erzeugung fehl, bleibt die Kenntnisnahme
      // trotzdem gespeichert — der Nachweis ist das rechtlich
      // Entscheidende, das PDF nur seine Ausfertigung.
      try {
        // Die Bescheinigung ist durchgehend deutsch — auch die
        // Inhaltsliste. Der Loader cacht die Sprachfassungen, der Zugriff
        // kostet nach dem ersten Mal nichts.
        final deBundle = await PrivacyCourseBundle.load(
          kPrivacyBindingLanguage,
        );
        final pdf = await buildPrivacyCameraCertificatePdf(
          signaturePng: signatureBytes,
          driverName: _driver.name,
          employeeNumber: _driver.employeeNumber,
          companyName: _driver.companyName,
          occurredAt: ack.occurredAt,
          documentTitle: binding.ref.title,
          documentVersion: binding.ref.version,
          contentSha256: binding.contentSha256,
          moduleTitles: [for (final m in deBundle.course.modules) m.title],
          // Verbindlicher Wortlaut: ausschließlich deutsch.
          statementShown: statementDe,
          clarification: bindingCopy.clarification,
        );
        await _repo.storeCertificate(
          pdfBytes: pdf,
          occurredAt: ack.occurredAt,
          documentVersion: binding.ref.version,
          contentSha256: binding.contentSha256,
        );
      } catch (_) {
        // Kein harter Fehler für den Fahrer — die Kenntnisnahme steht.
      }

      if (!mounted) return;
      setState(() {
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

  /// „Später" — schließt den Kurs, ohne irgendetwas zu schreiben.
  ///
  /// Bewusst ohne Rückfrage, ohne Warnung und ohne Vermerk: Es soll nicht
  /// der Eindruck einer Weigerung entstehen, sondern der einer schlicht
  /// verschobenen Aufgabe. Der Kurs bleibt danach offen und kann
  /// jederzeit erneut gestartet werden.
  void _later() => widget.onBack();

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
    final bindingCopy = state.bundle.bindingAck;
    final binding = state.bindingDocument;
    final translated = state.bundle.needsBindingTranslationBlock;
    final dateText = privacyCameraFormatDate(binding.ref.validFrom);
    final statementDe = bindingCopy.statementFor(dateText);
    final statementLocalized = copy.statementFor(dateText);
    final hash = binding.contentSha256.length > 12
        ? '${binding.contentSha256.substring(0, 12)}…'
        : binding.contentSha256;

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
                // VERBINDLICHER Wortlaut aus Spec §7 — immer auf Deutsch,
                // in jeder Sprachfassung, nicht umformulieren.
                if (translated) ...[
                  Text(
                    privacyCameraText(_lang, 'binding_label'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: kPcMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  statementDe,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    fontWeight: FontWeight.w700,
                    color: kPcText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  bindingCopy.clarification,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: Color(0xFF4B5563),
                  ),
                ),
                // Übersetzung ergänzend darunter — sie ersetzt den
                // deutschen Wortlaut nicht, sie erklärt ihn.
                if (translated) ...[
                  const SizedBox(height: 14),
                  const Divider(color: kPcBorder, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    privacyCameraText(_lang, 'translation_label'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: kPcMuted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statementLocalized,
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
                ],
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
                  '${privacyCameraText(_lang, 'doc_version', vars: {'version': binding.ref.version})} · '
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
            ],
          ),
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
          Row(
            children: [
              // Solange nicht unterschrieben ist, erklärt dieser Hinweis
              // den noch inaktiven Bestätigen-Button. Sachlich, keine
              // Warnung.
              Expanded(
                child: _hasSignature
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          privacyCameraText(_lang, 'signature_required_hint'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: kPcMuted,
                          ),
                        ),
                      ),
              ),
              TextButton.icon(
                onPressed: _busy ? null : () => _signatureCtrl.clear(),
                icon: const Icon(Icons.backspace_outlined, size: 16),
                label: Text(privacyCameraText(_lang, 'ack_signature_clear')),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: FilledButton(
              // Bestätigen erst mit Checkbox UND Unterschrift.
              onPressed: _busy || !_checkboxConfirmed || !_hasSignature
                  ? null
                  : _submit,
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
          const SizedBox(height: 4),
          // „Später" — zurückhaltender Textlink, kein gleichwertiger
          // Button. Er verschiebt nur; es wird nichts gespeichert und
          // nichts vermerkt, damit kein Eindruck einer Weigerung
          // entsteht.
          Center(
            child: TextButton(
              onPressed: _busy ? null : _later,
              style: TextButton.styleFrom(
                foregroundColor: kPcMuted,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(privacyCameraText(_lang, 'later_label')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDone(PrivacyCameraState state) {
    final copy = state.bundle.course.acknowledgement;
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
                decoration: const BoxDecoration(
                  color: Color(0xFFE4F5EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 32,
                  color: Color(0xFF16704F),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                copy.successTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: kPcText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                copy.successText,
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
    // Über ALLE angehängten Positionen prüfen: während Route-Transitions
    // kann der Controller kurzzeitig mehrere Clients haben — der
    // Einzel-Getter `position` liefert dann im Release-Build die falsche.
    for (final pos in _scroll.positions) {
      final max = pos.maxScrollExtent;
      // Kurze Dokumente ohne Scrollbereich gelten sofort als gelesen.
      if (max <= 0 || pos.pixels >= max - 24) {
        setState(() => _reachedEnd = true);
        return;
      }
    }
  }

  /// Eine Bildschirmseite weiter — Fallback-Pfeil, falls die
  /// Scroll-Geste auf einem Gerät nicht greift. Bewusst jumpTo je
  /// Position (statt animateTo über den Controller): Pointer-Events
  /// stoppen laufende Animationen, und bei mehreren angehängten
  /// Positionen rechnet jede mit ihren eigenen Maßen.
  void _pageDown() {
    if (!_scroll.hasClients) return;
    for (final pos in _scroll.positions) {
      final step = pos.viewportDimension > 200
          ? pos.viewportDimension * 0.85
          : 400.0;
      pos.jumpTo((pos.pixels + step).clamp(0.0, pos.maxScrollExtent));
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
        // SelectionContainer.disabled: Die App ist global in eine
        // SelectionArea gewickelt — im langen Pflichttext wurde die
        // Scroll-Geste dadurch zur TEXTAUSWAHL, Fahrer erreichten das
        // Ende nie und der Abschluss-Button blieb gesperrt (Ticket
        // „Bei dem Test kommen die Mitarbeiter nicht weiter").
        body: SelectionContainer.disabled(
          child: Stack(
            children: [
              ListView(
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
              // Fallback, falls Scrollen auf einem Gerät trotzdem klemmt:
              // Pfeil springt schrittweise Richtung Ende — derselbe Weg,
              // den auch echtes Scrollen nimmt (Listener setzt reachedEnd).
              if (!_reachedEnd)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'privacy_doc_scroll_down',
                    backgroundColor: kPcText,
                    foregroundColor: Colors.white,
                    onPressed: _pageDown,
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
            ],
          ),
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
