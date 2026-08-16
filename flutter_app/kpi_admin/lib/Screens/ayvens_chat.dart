// lib/Screens/ayvens_chat.dart
//
// "Ayvens Wissen" — a grounded chat assistant shown from the Fleet Hub
// (superadmin only). It calls the `askAyvens` Cloud Function, which answers
// strictly from the Ayvens knowledge base (ayvens.com/de-de/amazon) via
// Gemini.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

const _kAccent = Color(0xFF00B287);
const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);

Future<void> showAyvensChat(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const Dialog(
      insetPadding: EdgeInsets.all(20),
      backgroundColor: Colors.transparent,
      child: _AyvensChat(),
    ),
  );
}

class _Msg {
  final bool user;
  final String text;
  _Msg(this.user, this.text);
}

class _AyvensChat extends StatefulWidget {
  const _AyvensChat();

  @override
  State<_AyvensChat> createState() => _AyvensChatState();
}

class _AyvensChatState extends State<_AyvensChat> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _greetingAdded = false;
  bool _sending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_greetingAdded) return;
    _greetingAdded = true;
    final de = Localizations.localeOf(context).languageCode == 'de';
    _messages.add(_Msg(
      false,
      de
          ? 'Hallo! Ich beantworte Fragen rund um die Ayvens-Services für Amazon '
              'DSPs (Onboarding, Panne/Unfall/Schaden, Wartung/TÜV, Übergabe, '
              'Rückgabe, Kontakt). Frag einfach.'
          : 'Hi! I answer questions about the Ayvens services for Amazon '
              'DSPs (onboarding, breakdown/accident/damage, servicing/TÜV, '
              'handover, return, contact). Just ask.',
    ));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final q = _input.text.trim();
    if (q.isEmpty || _sending) return;
    setState(() {
      _messages.add(_Msg(true, q));
      _input.clear();
      _sending = true;
    });
    _scrollDown();

    // Send last turns as history (exclude the greeting + the just-added msg).
    final history = <Map<String, String>>[];
    for (final m in _messages.take(_messages.length - 1)) {
      history.add({'role': m.user ? 'user' : 'model', 'text': m.text});
    }

    try {
      final resp = await FirebaseFunctions.instance
          .httpsCallable('askAyvens')
          .call(<String, dynamic>{'question': q, 'history': history});
      final answer =
          ((resp.data as Map?)?['answer'] ?? '').toString().trim();
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(
            false,
            answer.isEmpty
                ? (de ? '(keine Antwort)' : '(no answer)')
                : answer));
        _sending = false;
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        final hint = e.code == 'failed-precondition'
            ? (de
                ? 'Der Gemini-API-Key ist noch nicht hinterlegt.'
                : 'The Gemini API key has not been configured yet.')
            : '';
        _messages.add(_Msg(false,
            '${de ? 'Fehler' : 'Error'}: ${e.message ?? e.code}. $hint'));
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(false, '${de ? 'Fehler' : 'Error'}: $e'));
        _sending = false;
      });
    }
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final h = MediaQuery.of(context).size.height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 560, maxHeight: h * 0.82),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: _kAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(de ? 'Ayvens Wissen' : 'Ayvens knowledge',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: _kInk)),
                        Text(
                            de
                                ? 'Antworten auf Basis der Ayvens-Amazon-Seite'
                                : 'Answers based on the Ayvens Amazon page',
                            style: const TextStyle(
                                fontSize: 11.5, color: _kMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Disclaimer — no guarantee of correctness; answers only mirror
            // the Ayvens-Amazon page in simplified form.
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF7ED),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: Color(0xFFB45309)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      de
                          ? 'Hinweis: Keine Gewähr für die Richtigkeit. Die Antworten '
                              'geben nur die Inhalte der Ayvens-Amazon-Seite in '
                              'vereinfachter Form wieder.'
                          : 'Note: no guarantee of correctness. The answers only '
                              'reflect the content of the Ayvens Amazon page in '
                              'simplified form.',
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Messages
            Flexible(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (context, i) {
                  if (_sending && i == _messages.length) {
                    return const _Bubble(
                        user: false, child: _TypingDots());
                  }
                  final m = _messages[i];
                  return _Bubble(
                    user: m.user,
                    child: SelectableText(
                      m.text,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: m.user ? Colors.white : _kInk,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: de
                            ? 'Frage zu Ayvens stellen…'
                            : 'Ask a question about Ayvens…',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: _kAccent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _sending ? null : _send,
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(Icons.arrow_upward_rounded,
                            color: Colors.white),
                      ),
                    ),
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

class _Bubble extends StatelessWidget {
  final bool user;
  final Widget child;
  const _Bubble({required this.user, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: user ? _kAccent : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(user ? 14 : 4),
            bottomRight: Radius.circular(user ? 4 : 14),
          ),
          border: user ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: child,
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = ((_c.value + i * 0.2) % 1.0);
            final o = 0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: o,
                child: const CircleAvatar(radius: 3.5, backgroundColor: _kMuted),
              ),
            );
          }),
        );
      },
    );
  }
}
