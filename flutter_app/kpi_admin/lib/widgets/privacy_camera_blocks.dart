// lib/widgets/privacy_camera_blocks.dart
//
// Renderer für die Inhaltsblöcke des Datenschutz-Kamera-Kurses und für
// die beiden Markdown-Volltexte.
//
// Der Markdown-Renderer ist bewusst selbst geschrieben: das Projekt hat
// keinen Markdown-Renderer als Abhängigkeit, und im Nachweispfad soll
// kein zusätzliches Fremdpaket liegen. Er beherrscht genau das, was die
// beiden Rechtstexte benutzen — Überschriften, Absätze, Aufzählungen —
// und gibt alles andere unverändert als Text aus, damit kein Wortlaut
// verloren geht.

import 'package:flutter/material.dart';

import '../data/privacy_camera/privacy_camera_content.dart';

const Color kPcText = Color(0xFF1F2937);
const Color kPcMuted = Color(0xFF7A8699);
const Color kPcBorder = Color(0xFFDDE3E7);
const Color kPcBg = Color(0xFFF5F7F9);
const Color kPcAccent = Color(0xFF2A5FB0);
const Color kPcAccentBg = Color(0xFFEAF1FB);

/// Rendert einen Inhaltsblock aus dem Kurs-JSON.
class PrivacyBlockView extends StatelessWidget {
  const PrivacyBlockView({
    super.key,
    required this.block,
    this.onOpenDocument,
  });

  final PrivacyBlock block;
  final void Function(String documentKey)? onOpenDocument;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            block.text ?? '',
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: kPcText,
            ),
          ),
        );
      case 'bullets':
        return _Bullets(title: block.title, items: block.items);
      case 'callout':
        return _Callout(
          style: block.style,
          title: block.title,
          text: block.text ?? '',
        );
      case 'keyValue':
        return _KeyValues(title: block.title, items: block.keyValues);
      case 'factCard':
        return _FactCard(
          positive: block.style == 'positive',
          title: block.title ?? '',
          items: block.items,
        );
      case 'documentEmbed':
        return _DocumentEmbed(
          title: block.title ?? '',
          onTap: block.documentKey == null
              ? null
              : () => onOpenDocument?.call(block.documentKey!),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({this.title, required this.items});
  final String? title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((title ?? '').isNotEmpty) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: kPcText,
              ),
            ),
            const SizedBox(height: 8),
          ],
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7, right: 10),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: kPcMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: kPcText,
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

class _Callout extends StatelessWidget {
  const _Callout({this.style, this.title, required this.text});
  final String? style;
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color border;
    late final Color fg;
    late final IconData icon;
    switch (style) {
      case 'warning':
        bg = const Color(0xFFFFF3E0);
        border = const Color(0xFFFFD9A0);
        fg = const Color(0xFF9A5B00);
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        bg = const Color(0xFFE4F5EC);
        border = const Color(0xFFB6E2C6);
        fg = const Color(0xFF16704F);
        icon = Icons.verified_outlined;
        break;
      default:
        bg = kPcAccentBg;
        border = const Color(0xFFB9D4F0);
        fg = const Color(0xFF14538C);
        icon = Icons.info_outline_rounded;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((title ?? '').isNotEmpty) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: kPcText,
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

class _KeyValues extends StatelessWidget {
  const _KeyValues({this.title, required this.items});
  final String? title;
  final List<PrivacyKeyValue> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((title ?? '').isNotEmpty) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: kPcText,
              ),
            ),
            const SizedBox(height: 8),
          ],
          for (final kv in items)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: kPcBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kv.key,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: kPcText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kv.value,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Color(0xFF4B5563),
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

/// „Was NICHT passiert" / „Was passiert". Die positive Karte steht im
/// Kurs bewusst zuerst — sie trägt die Verhältnismäßigkeit der DSFA.
class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.positive,
    required this.title,
    required this.items,
  });
  final bool positive;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF16704F) : const Color(0xFF3B5A80);
    final bg = positive ? const Color(0xFFE4F5EC) : const Color(0xFFEFF4FA);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    positive
                        ? Icons.check_circle_outline_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 17,
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: kPcText,
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

class _DocumentEmbed extends StatelessWidget {
  const _DocumentEmbed({required this.title, required this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: kPcAccent.withValues(alpha: 0.45), width: 1.4),
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
                    size: 20,
                    color: kPcAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: kPcText,
                      height: 1.35,
                    ),
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
  }
}

// ── Markdown ────────────────────────────────────────────────────────

/// Minimaler Markdown-Renderer für die beiden Rechtstexte.
///
/// Unterstützt `#`/`##`/`###`, `- `-Aufzählungen und Absätze. Alles
/// andere wird als Absatz ausgegeben — lieber unformatiert als
/// verschluckt: der Wortlaut ist der Nachweis.
List<Widget> buildPrivacyMarkdown(String markdown) {
  final out = <Widget>[];
  final lines = markdown.replaceAll('\r\n', '\n').split('\n');
  final paragraph = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    final text = paragraph.join(' ').trim();
    paragraph.clear();
    if (text.isEmpty) return;
    out.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14.5, height: 1.6, color: kPcText),
        ),
      ),
    );
  }

  for (final raw in lines) {
    final line = raw.trimRight();
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      flushParagraph();
      continue;
    }

    if (trimmed.startsWith('### ')) {
      flushParagraph();
      out.add(_mdHeading(trimmed.substring(4), 15));
      continue;
    }
    if (trimmed.startsWith('## ')) {
      flushParagraph();
      out.add(_mdHeading(trimmed.substring(3), 16.5));
      continue;
    }
    if (trimmed.startsWith('# ')) {
      flushParagraph();
      out.add(_mdHeading(trimmed.substring(2), 19));
      continue;
    }
    if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      flushParagraph();
      out.add(_mdBullet(trimmed.substring(2)));
      continue;
    }
    paragraph.add(trimmed);
  }
  flushParagraph();
  return out;
}

Widget _mdHeading(String text, double size) => Padding(
  padding: EdgeInsets.only(top: size > 17 ? 6 : 16, bottom: 8),
  child: Text(
    text.trim(),
    style: TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: kPcText,
      height: 1.3,
    ),
  ),
);

Widget _mdBullet(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8, left: 2),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 8, right: 10),
        width: 5,
        height: 5,
        decoration: const BoxDecoration(color: kPcMuted, shape: BoxShape.circle),
      ),
      Expanded(
        child: Text(
          text.trim(),
          style: const TextStyle(fontSize: 14.5, height: 1.55, color: kPcText),
        ),
      ),
    ],
  ),
);
