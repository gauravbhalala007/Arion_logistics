// lib/Screens/incident_faq_dialog.dart
//
// Telefon-Leitfaden „Was frage ich den Fahrer bei einem Unfall?".
//
// Der Inhalt steht in `lib/data/incident_faq/incident_faq_content.dart`
// und wird hier nur gerendert — neue Fragen brauchen keine Änderung an
// dieser Datei.
//
// Darstellung folgt der Incident-Seite:
//   • ab 700 px ein zentrierter Dialog (max. 720 px breit),
//   • darunter ein fast bildschirmhohes Bottom-Sheet, weil die
//     Disposition den Leitfaden auch am Handy im Telefonat liest.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/incident_faq/incident_faq_content.dart';
import '../widgets/co_button.dart';
import 'admin_incident_form_page.dart'
    show
        kIncidentBorder,
        kIncidentDanger,
        kIncidentFieldFill,
        kIncidentFocus,
        kIncidentMuted,
        kIncidentText;

/// Schwelle wie auf der Incident-Übersicht (`kIncidentMobileBreakpoint`).
/// Bewusst dupliziert, damit dieser Dialog nicht von der Listen-Seite
/// abhängt.
const double _kFaqMobileBreakpoint = 700;

/// Öffnet den Leitfaden — Dialog am Desktop, Bottom-Sheet am Handy.
Future<void> showIncidentFaq(BuildContext context) async {
  final isMobile = MediaQuery.sizeOf(context).width < _kFaqMobileBreakpoint;

  if (isMobile) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _IncidentFaqSheet(),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (_) => const _IncidentFaqDialog(),
  );
}

// ═════════════════════════════════════════════════════════════════════════
// Einstiegs-Button
// ═════════════════════════════════════════════════════════════════════════

/// Dezenter Einstieg in den Leitfaden für die Kopfzeile der
/// Incident-Übersicht. Am Handy nur das Fragezeichen (44 × 44), sonst
/// Icon + Label, damit klar ist, was dahintersteckt.
class IncidentFaqButton extends StatelessWidget {
  const IncidentFaqButton({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final tooltip = de
        ? 'Was fragen? Leitfaden für den Unfall-Anruf'
        : 'What to ask? Guide for the accident call';

    if (!compact) {
      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: CoButton(
          onPressed: () => showIncidentFaq(context),
          icon: Icons.help_outline,
          label: de ? 'Was fragen?' : 'What to ask?',
          variant: CoButtonVariant.secondaryOutlined,
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(
          side: BorderSide(color: kIncidentBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showIncidentFaq(context),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.help_outline, size: 20, color: kIncidentText),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Hüllen: Dialog (Desktop) und Sheet (Mobile)
// ═════════════════════════════════════════════════════════════════════════

class _IncidentFaqDialog extends StatelessWidget {
  const _IncidentFaqDialog();

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 820),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FaqHeader(de: de),
            const Divider(height: 1, color: kIncidentBorder),
            Flexible(child: _FaqBody(de: de, mobile: false)),
            const Divider(height: 1, color: kIncidentBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CopyChecklistButton(de: de),
                  const SizedBox(width: 8),
                  CoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    label: de ? 'Schließen' : 'Close',
                    variant: CoButtonVariant.quiet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentFaqSheet extends StatelessWidget {
  const _IncidentFaqSheet();

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Griff — signalisiert, dass sich das Sheet wegwischen lässt.
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          _FaqHeader(de: de, compact: true),
          const Divider(height: 1, color: kIncidentBorder),
          Expanded(child: _FaqBody(de: de, mobile: true)),
          const Divider(height: 1, color: kIncidentBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _CopyChecklistButton(de: de, fullWidth: true),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Kopf, Körper, Aktion
// ═════════════════════════════════════════════════════════════════════════

class _FaqHeader extends StatelessWidget {
  const _FaqHeader({required this.de, this.compact = false});

  final bool de;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(16, 8, 8, 12)
          : const EdgeInsets.fromLTRB(24, 20, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4ED),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.support_agent_rounded,
              size: 20,
              color: Color(0xFFC2410C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incidentFaqTitle(de: de),
                  style: TextStyle(
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: kIncidentText,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  incidentFaqSubtitle(de: de),
                  style: const TextStyle(fontSize: 13, color: kIncidentMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: kIncidentMuted,
            tooltip: de ? 'Schließen' : 'Close',
          ),
        ],
      ),
    );
  }
}

class _FaqBody extends StatelessWidget {
  const _FaqBody({required this.de, required this.mobile});

  final bool de;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final sections = incidentFaqSections(de: de);
    final hPad = mobile ? 16.0 : 24.0;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(hPad, mobile ? 14 : 20, hPad, 20),
      itemCount: sections.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: mobile ? 12 : 14),
      itemBuilder: (context, index) {
        if (index == sections.length) return _FaqFooterNote(de: de);
        return _FaqSectionCard(
          section: sections[index],
          step: index + 1,
          mobile: mobile,
        );
      },
    );
  }
}

/// Farbpaket eines Abschnitts, abgeleitet aus [IncidentFaqTone].
class _ToneColors {
  const _ToneColors(this.background, this.border, this.accent);

  final Color background;
  final Color border;
  final Color accent;

  factory _ToneColors.of(IncidentFaqTone tone) {
    switch (tone) {
      case IncidentFaqTone.danger:
        return const _ToneColors(
          Color(0xFFFEF3F2),
          Color(0xFFFECDCA),
          kIncidentDanger,
        );
      case IncidentFaqTone.warning:
        return const _ToneColors(
          Color(0xFFFFFAEB),
          Color(0xFFFEDF89),
          Color(0xFFB54708),
        );
      case IncidentFaqTone.success:
        return const _ToneColors(
          Color(0xFFECFDF3),
          Color(0xFFABEFC6),
          kIncidentFocus,
        );
      case IncidentFaqTone.neutral:
        return const _ToneColors(
          kIncidentFieldFill,
          kIncidentBorder,
          kIncidentText,
        );
    }
  }
}

class _FaqSectionCard extends StatelessWidget {
  const _FaqSectionCard({
    required this.section,
    required this.step,
    required this.mobile,
  });

  final IncidentFaqSection section;
  final int step;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final colors = _ToneColors.of(section.tone);

    return Container(
      padding: EdgeInsets.all(mobile ? 14 : 16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(section.icon, size: 18, color: colors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$step. ${section.title}',
                  style: TextStyle(
                    fontSize: mobile ? 14 : 15,
                    fontWeight: FontWeight.w800,
                    color: colors.accent,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          if (section.intro != null) ...[
            const SizedBox(height: 6),
            Text(
              section.intro!,
              style: const TextStyle(
                fontSize: 12.5,
                color: kIncidentMuted,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 10),
          for (var i = 0; i < section.points.length; i++)
            _FaqPointRow(
              point: section.points[i],
              marker: section.numbered ? '${i + 1}' : null,
              accent: colors.accent,
              last: i == section.points.length - 1,
            ),
          if (section.footnote != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.push_pin_outlined, size: 15, color: colors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.footnote!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FaqPointRow extends StatelessWidget {
  const _FaqPointRow({
    required this.point,
    required this.marker,
    required this.accent,
    required this.last,
  });

  final IncidentFaqPoint point;

  /// Gesetzt = nummerierter Punkt (Fragenkatalog), sonst Bullet.
  final String? marker;
  final Color accent;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (marker != null)
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: kIncidentBorder),
              ),
              child: Text(
                marker!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  height: 1,
                ),
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 7, left: 7, right: 7),
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: kIncidentText,
                    height: 1.4,
                  ),
                ),
                if (point.detail != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    point.detail!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: kIncidentMuted,
                      height: 1.45,
                    ),
                  ),
                ],
                if (point.field != null) ...[
                  const SizedBox(height: 6),
                  _FieldChip(field: point.field!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Verweis auf das Formularfeld, in das die Antwort gehört.
class _FieldChip extends StatelessWidget {
  const _FieldChip({required this.field});

  final String field;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kIncidentBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.south_east_rounded,
            size: 12,
            color: kIncidentMuted,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              de ? 'Feld: $field' : 'Field: $field',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kIncidentMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqFooterNote extends StatelessWidget {
  const _FaqFooterNote({required this.de});

  final bool de;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: kIncidentMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            incidentFaqFooter(de: de),
            style: const TextStyle(
              fontSize: 12.5,
              color: kIncidentMuted,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _CopyChecklistButton extends StatelessWidget {
  const _CopyChecklistButton({required this.de, this.fullWidth = false});

  final bool de;
  final bool fullWidth;

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(
      ClipboardData(text: incidentFaqChecklistText(de: de)),
    );
    messenger?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        content: Text(
          de ? 'Checkliste kopiert.' : 'Checklist copied.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CoButton(
      onPressed: () => _copy(context),
      icon: Icons.content_copy_rounded,
      label: de ? 'Als Checkliste kopieren' : 'Copy as checklist',
      variant: CoButtonVariant.secondaryOutlined,
      fullWidth: fullWidth,
    );
  }
}
