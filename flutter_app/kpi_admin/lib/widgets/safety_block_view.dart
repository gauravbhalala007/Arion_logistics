// lib/widgets/safety_block_view.dart
//
// Rendering der Inhaltsbausteine der Sicherheitsunterweisung.
// Gestaltungsidee: Prüfbericht-Editorial — klare Typo-Hierarchie,
// Merksätze als Karten mit farbiger Kante, Zahlen als Kacheln,
// Richtig/Falsch in zwei Spalten. Kein Fließtext ohne Struktur.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Screens/driver_operating_instructions_page.dart';
import '../data/safety_training/safety_blocks.dart';

class SafetyBlockView extends StatelessWidget {
  final SafetyBlock block;

  /// Fahreridentität — durchgereicht an verlinkte Betriebsanweisungen,
  /// damit sich diese direkt aus dem Kapitel heraus bestätigen lassen.
  final String? dspUid;
  final String? driverTransporterId;

  const SafetyBlockView(
    this.block, {
    super.key,
    this.dspUid,
    this.driverTransporterId,
  });

  static const _text = Color(0xFF1A2233);
  static const _body = Color(0xFF3F4A5A);
  static const _muted = Color(0xFF7A8699);
  static const _green = Color(0xFF1D7F5A);
  static const _mint = Color(0xFFEBF7F1);
  static const _line = Color(0xFFE3E8EF);

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      ParagraphBlock(:final text) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.62,
              color: _body,
              letterSpacing: 0.05,
            ),
          ),
        ),
      SubheadBlock(:final text) => Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 16, height: 2.5, color: _green),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: _green,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      BulletsBlock(:final items) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: _mint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 11, color: _green),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          it,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.5,
                            color: _body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      StepsBlock(:final steps, :final startAt) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < steps.length; i++)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${startAt + i}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (i < steps.length - 1)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                color: _line,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 3,
                            bottom: i < steps.length - 1 ? 14 : 0,
                          ),
                          child: Text(
                            steps[i],
                            style: const TextStyle(
                              fontSize: 14.5,
                              height: 1.5,
                              color: _body,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      CalloutBlock(:final tone, :final title, :final text) =>
        _callout(tone, title, text),
      FactsBlock(:final facts) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in facts)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f.value,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: _green,
                          letterSpacing: -0.3,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f.label,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      TableBlock(:final headers, :final rows) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  color: const Color(0xFFF4F7FA),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  child: Row(
                    children: [
                      for (var i = 0; i < headers.length; i++)
                        Expanded(
                          flex: i == 0 ? 2 : 5,
                          child: Text(
                            headers[i].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: _muted,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                for (var r = 0; r < rows.length; r++)
                  Container(
                    color: r.isOdd ? const Color(0xFFFAFCFD) : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var c = 0; c < rows[r].length; c++)
                          Expanded(
                            flex: c == 0 ? 2 : 5,
                            child: Text(
                              rows[r][c],
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.4,
                                fontWeight:
                                    c == 0 ? FontWeight.w900 : FontWeight.w500,
                                color: c == 0 ? _green : _body,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      IllustratedStepsBlock(:final steps) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Illustration
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFFAFCFD),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SvgPicture.asset(
                            steps[i].asset,
                            height: 132,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _green,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      steps[i].title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: _text,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              // Untertitel — traegt die Aussage, wird uebersetzt
                              Text(
                                steps[i].caption,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: _body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      RevealBlock(:final prompt, :final answer) =>
        _RevealCard(prompt: prompt, answer: answer),
      ChecklistBlock(:final title, :final items) =>
        _ChecklistCard(title: title, items: items),
      InstructionRefBlock(:final instructionIds) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final id in instructionIds)
              InstructionLinkCard(
                instructionId: id,
                dspUid: dspUid,
                driverTransporterId: driverTransporterId,
              ),
          ],
        ),
      DoDontBlock(
        :final doTitle,
        :final dos,
        :final dontTitle,
        :final donts
      ) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LayoutBuilder(
            builder: (context, box) {
              final side = _doDontColumn(
                  doTitle, dos, true);
              final other = _doDontColumn(dontTitle, donts, false);
              if (box.maxWidth < 520) {
                return Column(
                  children: [side, const SizedBox(height: 10), other],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: side),
                  const SizedBox(width: 10),
                  Expanded(child: other),
                ],
              );
            },
          ),
        ),
    };
  }

  Widget _doDontColumn(String title, List<String> items, bool positive) {
    final accent = positive ? _green : const Color(0xFFC0392B);
    final bg = positive ? _mint : const Color(0xFFFDEDEB);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                positive ? Icons.thumb_up_rounded : Icons.report_rounded,
                size: 15,
                color: accent,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration:
                          BoxDecoration(color: accent, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      it,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: _text,
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

  Widget _callout(CalloutTone tone, String title, String text) {
    final (accent, bg, icon) = switch (tone) {
      CalloutTone.key => (
          _green,
          _mint,
          Icons.lightbulb_rounded,
        ),
      CalloutTone.warning => (
          const Color(0xFFB45309),
          const Color(0xFFFEF6E7),
          Icons.warning_amber_rounded,
        ),
      CalloutTone.danger => (
          const Color(0xFFC0392B),
          const Color(0xFFFDEDEB),
          Icons.dangerous_rounded,
        ),
      CalloutTone.law => (
          const Color(0xFF3B5A80),
          const Color(0xFFEFF4FA),
          Icons.balance_rounded,
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: accent,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: _text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// „Erst denken, dann sehen" — Auflösung erscheint nach dem Tippen.
class _RevealCard extends StatefulWidget {
  final String prompt;
  final String answer;
  const _RevealCard({required this.prompt, required this.answer});

  @override
  State<_RevealCard> createState() => _RevealCardState();
}

class _RevealCardState extends State<_RevealCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1D7F5A);
    const mint = Color(0xFFEBF7F1);
    const text = Color(0xFF1A2233);
    const body = Color(0xFF3F4A5A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _open ? green.withValues(alpha: 0.45) : const Color(0xFFE3E8EF),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: mint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _open
                            ? Icons.lightbulb_rounded
                            : Icons.psychology_alt_rounded,
                        size: 15,
                        color: green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.prompt,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: text,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: green,
                      size: 20,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  crossFadeState: _open
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 36),
                    child: Text(
                      widget.answer,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: body,
                      ),
                    ),
                  ),
                ),
                if (!_open)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 36),
                    child: Text(
                      'Tippen zum Aufdecken',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF7A8699),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Abhakbare Checkliste zur Selbstkontrolle (nicht persistiert).
class _ChecklistCard extends StatefulWidget {
  final String title;
  final List<String> items;
  const _ChecklistCard({required this.title, required this.items});

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  late final List<bool> _checked = List<bool>.filled(widget.items.length, false);

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1D7F5A);
    const text = Color(0xFF1A2233);
    final done = _checked.where((e) => e).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E8EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded, size: 16, color: green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: green,
                    ),
                  ),
                ),
                Text(
                  '$done/${widget.items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A8699),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < widget.items.length; i++)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _checked[i] = !_checked[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 1),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _checked[i] ? green : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _checked[i]
                                ? green
                                : const Color(0xFFCBD5E1),
                            width: 1.6,
                          ),
                        ),
                        child: _checked[i]
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          widget.items[i],
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: _checked[i]
                                ? const Color(0xFF7A8699)
                                : text,
                            decoration: _checked[i]
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
