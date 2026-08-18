// lib/Screens/driver_privacy_center_page.dart
//
// Dauerhafter Bereich „Datenschutz" für Fahrer.
//
// Erreichbar in zwei Taps: Fahrer-Home → DA Academy → Datenschutz.
// Bietet jederzeit — nicht nur am Ende des Kurses:
//   - Status der Empfangsbestätigung + Kurs starten/wiederholen
//   - beide Datenschutzerklärungen im Volltext
//   - Kontakt für Auskunft / Berichtigung / Löschung
//
// WIDERSPRUCH: Auf Kundenwunsch gibt es hier KEIN In-App-Formular mehr.
// Die gesetzliche Information über das Widerspruchsrecht bleibt davon
// unberührt — sie steht weiterhin in beiden Volltext-Dokumenten und als
// ein Punkt im Rechte-Modul des Kurses (Art. 13 Abs. 2 lit. b DSGVO).
// Der Weg zur Ausübung ist die hier genannte Kontaktadresse.

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
  bool _loading = true;
  bool _loadStarted = false;

  String get _lang =>
      Localizations.localeOf(context).languageCode.toLowerCase();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final state = await _repo.load(_lang);
      if (!mounted) return;
      setState(() {
        _state = state;
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
