// lib/Screens/driver_privacy_center_page.dart
//
// Dauerhafter Bereich „Datenschutz" für Fahrer (Spec §2 und §6).
//
// Erreichbar in zwei Taps: Fahrer-Home → DA Academy → Datenschutz.
// Bietet jederzeit — nicht nur am Ende des Kurses:
//   - Status der Empfangsbestätigung + Kurs starten/wiederholen
//   - beide Datenschutzerklärungen im Volltext
//   - Widerspruch einlegen und zurücknehmen
//   - Kontakt für Auskunft / Berichtigung / Löschung
//
// Der Widerspruch ist bewusst OHNE Dark Pattern gebaut: Grundfeld
// optional, keine Warnbanner, keine Mehrfachbestätigung, keine
// Verzögerung, Rücknahme genauso einfach wie die Abgabe. Jede
// Formulierung, die Konsequenzen andeutet, würde die von der DSFA
// zugesagte Nachteilsfreiheit unterlaufen.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/privacy_camera/privacy_camera_content.dart';
import '../data/privacy_camera/privacy_camera_repository.dart';
import '../data/privacy_camera/privacy_camera_texts.dart';
import '../widgets/privacy_camera_blocks.dart';
import 'driver_privacy_camera_course_page.dart';

class DriverPrivacyCenterPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverPrivacyCenterPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverPrivacyCenterPage> createState() =>
      _DriverPrivacyCenterPageState();
}

class _DriverPrivacyCenterPageState extends State<DriverPrivacyCenterPage> {
  late final PrivacyCameraRepository _repo = PrivacyCameraRepository(
    dspUid: widget.dspUid,
    driverTransporterId: widget.driverTransporterId,
  );

  PrivacyCameraState? _state;
  String _driverName = '';
  bool _loading = true;
  bool _busy = false;

  String get _lang =>
      Localizations.localeOf(context).languageCode.toLowerCase();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final state = await _repo.load(kPrivacyCourseFallbackLanguage);
      final driver = await _repo.loadDriverInfo();
      if (!mounted) return;
      setState(() {
        _state = state;
        _driverName = driver.name;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openCourse() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => DriverPrivacyCameraCoursePage(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _openDocument(PrivacyDocument doc) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrivacyDocumentReaderPage(document: doc),
      ),
    );
  }

  Future<void> _openObjection() async {
    final state = _state;
    if (state == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DriverPrivacyObjectionPage(
          repo: _repo,
          copy: state.bundle.course.objectionForm,
          driverName: _driverName,
        ),
      ),
    );
    if (!mounted) return;
    if (changed == true) await _load();
  }

  Future<void> _withdrawObjection() async {
    setState(() => _busy = true);
    try {
      await _repo.withdrawObjection();
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openMail(PrivacyCenterCopy copy) async {
    final uri = Uri(
      scheme: 'mailto',
      path: copy.contactEmail.trim(),
      query: 'subject=${Uri.encodeComponent(copy.contactMailSubject)}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(privacyCameraText(_lang, 'center_mail_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      backgroundColor: kPcBg,
      body: SafeArea(
        child: _loading || state == null
            ? const Center(child: CircularProgressIndicator())
            : _content(state),
      ),
    );
  }

  Widget _content(PrivacyCameraState state) {
    final copy = state.bundle.course.center;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoundIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: widget.onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  copy.headline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: kPcText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (copy.intro.isNotEmpty)
            Text(
              copy.intro,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF4B5563),
              ),
            ),
          const SizedBox(height: 16),
          _sectionTitle(copy.courseTitle),
          _statusCard(state),
          const SizedBox(height: 18),
          _sectionTitle(copy.documentsTitle),
          for (final key in state.bundle.course.documentRefs)
            if (state.bundle.documents[key] != null)
              _documentTile(state.bundle.documents[key]!),
          const SizedBox(height: 18),
          _sectionTitle(copy.objectionTitle),
          _objectionCard(state),
          const SizedBox(height: 18),
          _sectionTitle(copy.contactTitle),
          _contactCard(copy),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: kPcMuted,
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kPcBorder, width: 1.2),
    ),
    child: child,
  );

  Widget _statusCard(PrivacyCameraState state) {
    final ack = state.ack;
    final due = state.acknowledgementDue;

    String status;
    if (ack == null) {
      status = privacyCameraText(_lang, 'center_status_none');
    } else if (ack.isAcknowledged) {
      status = privacyCameraText(
        _lang,
        'center_status_ack',
        vars: {'date': privacyCameraFormatDate(ack.occurredAt)},
      );
    } else {
      status = privacyCameraText(
        _lang,
        'center_status_declined',
        vars: {'date': privacyCameraFormatDate(ack.occurredAt)},
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.bundle.course.title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: kPcText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: Color(0xFF4B5563),
            ),
          ),
          if (ack != null && ack.isAcknowledged) ...[
            const SizedBox(height: 6),
            Text(
              (ack.signaturePngBase64 ?? '').isNotEmpty
                  ? privacyCameraText(_lang, 'center_signature_saved')
                  : privacyCameraText(_lang, 'center_signature_none'),
              style: const TextStyle(fontSize: 12, color: kPcMuted),
            ),
          ],
          if (due && ack != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                privacyCameraText(_lang, 'center_status_outdated'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9A5B00),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: _openCourse,
              style: FilledButton.styleFrom(
                backgroundColor: kPcAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(
                due
                    ? privacyCameraText(_lang, 'center_course_open')
                    : privacyCameraText(_lang, 'center_course_repeat'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentTile(PrivacyDocument doc) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDocument(doc),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kPcBorder, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: kPcAccentBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 19,
                  color: kPcAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.ref.shortTitle,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: kPcText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      privacyCameraText(
                        _lang,
                        'doc_version',
                        vars: {'version': doc.ref.version},
                      ),
                      style: const TextStyle(fontSize: 12, color: kPcMuted),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: kPcMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _objectionCard(PrivacyCameraState state) {
    final objection = state.objection;
    final active = objection?.isActive ?? false;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (active && objection != null) ...[
            Text(
              privacyCameraText(
                _lang,
                'center_objection_active',
                vars: {'date': privacyCameraFormatDate(objection.createdAt)},
              ),
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: kPcText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              objection.processedAt != null
                  ? privacyCameraText(
                      _lang,
                      'center_objection_processed',
                      vars: {
                        'date': privacyCameraFormatDate(objection.processedAt!),
                      },
                    )
                  : privacyCameraText(_lang, 'center_objection_pending'),
              style: const TextStyle(fontSize: 13, color: kPcMuted),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: _busy ? null : _withdrawObjection,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPcText,
                  side: const BorderSide(color: kPcBorder, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(
                  privacyCameraText(_lang, 'center_objection_withdraw'),
                ),
              ),
            ),
          ] else ...[
            Text(
              state.bundle.course.objectionForm.intro,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: _openObjection,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPcText,
                  side: const BorderSide(color: kPcBorder, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(privacyCameraText(_lang, 'center_objection_open')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactCard(PrivacyCenterCopy copy) {
    final placeholder = copy.contactIsPlaceholder;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.contactIntro,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            copy.contactEmail,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: kPcText,
            ),
          ),
          const SizedBox(height: 10),
          if (placeholder)
            // Solange die Adresse ein Platzhalter aus der Vorlage ist,
            // wird kein mailto angeboten — sonst liefe der Fahrer ins
            // Leere. Der Kunde trägt die Adresse vor dem Go-live ein.
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                copy.contactPlaceholderHint,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF9A5B00),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _openMail(copy),
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: Text(privacyCameraText(_lang, 'center_contact_button')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPcText,
                  side: const BorderSide(color: kPcBorder, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widerspruchsformular — neutral, ohne Warnungen, ohne Pflichtbegründung.
class DriverPrivacyObjectionPage extends StatefulWidget {
  const DriverPrivacyObjectionPage({
    super.key,
    required this.repo,
    required this.copy,
    required this.driverName,
  });

  final PrivacyCameraRepository repo;
  final PrivacyObjectionCopy copy;
  final String driverName;

  @override
  State<DriverPrivacyObjectionPage> createState() =>
      _DriverPrivacyObjectionPageState();
}

class _DriverPrivacyObjectionPageState
    extends State<DriverPrivacyObjectionPage> {
  final TextEditingController _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    setState(() => _busy = true);
    try {
      await widget.repo.submitObjection(
        driverName: widget.driverName,
        statement: widget.copy.statement,
        reason: _reason.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(widget.copy.successTitle),
          content: Text(widget.copy.successText),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(privacyCameraText(lang, 'ok')),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            privacyCameraText(lang, 'ack_save_error', vars: {'error': '$e'}),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    return Scaffold(
      backgroundColor: kPcBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: kPcText,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          copy.headline,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kPcText,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            copy.intro,
            style: const TextStyle(fontSize: 14.5, height: 1.55, color: kPcText),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: kPcBorder),
            ),
            child: Text(
              copy.statement,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: kPcText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reason,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: copy.reasonLabel,
              helperText: copy.reasonHint,
              helperMaxLines: 3,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            copy.consequences,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: kPcAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

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
            border: Border.all(color: kPcBorder, width: 1),
          ),
          child: Icon(icon, size: 20, color: kPcText),
        ),
      ),
    );
  }
}
