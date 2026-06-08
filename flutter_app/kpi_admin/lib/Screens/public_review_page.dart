// lib/Screens/public_review_page.dart
//
// Öffentliche Bewertungsseite — nur über einen direkten Link erreichbar
// (kein Nav-Eintrag, kein Login). Besucher geben Name, Stations-Code,
// Stadt der Station, Firmenname, einen Bewertungstext und eine
// Sternebewertung (1–5) ab. Die Bewertung landet in der globalen
// Top-Level-Sammlung `public_reviews` mit `approved: false`; eine
// Freigabe (für Landingpage-Testimonials) erfolgt serverseitig.
//
// Route: https://dsp-codriver.de/#/bewertung
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../widgets/co_button.dart';

class PublicReviewPage extends StatefulWidget {
  const PublicReviewPage({super.key});

  @override
  State<PublicReviewPage> createState() => _PublicReviewPageState();
}

class _PublicReviewPageState extends State<PublicReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _stationCode = TextEditingController();
  final _stationCity = TextEditingController();
  final _company = TextEditingController();
  final _review = TextEditingController();

  int _rating = 0;
  bool _ratingError = false;
  bool _busy = false;
  bool _done = false;
  String? _error;

  static const _bg = Color(0xFFF3F6F7);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  void dispose() {
    _name.dispose();
    _stationCode.dispose();
    _stationCity.dispose();
    _company.dispose();
    _review.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    final ratingOk = _rating >= 1;
    setState(() => _ratingError = !ratingOk);
    if (!formOk || !ratingOk) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance.collection('public_reviews').add({
        'name': _name.text.trim(),
        'stationCode': _stationCode.text.trim(),
        'stationCity': _stationCity.text.trim(),
        'companyName': _company.text.trim(),
        'reviewText': _review.text.trim(),
        'rating': _rating,
        'approved': false,
        'source': 'public_review_page',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        _busy = false;
        _done = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error =
            'Die Bewertung konnte nicht gesendet werden. Bitte versuche es '
            'gleich noch einmal.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.97, end: 1.0).animate(anim),
                    child: child,
                  ),
                ),
                child: _done ? _buildSuccess() : _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            'assets/codriver_logo.png',
            height: 40,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            cacheHeight: 160,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Bewerte deinen DSP',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Teile deine Erfahrung. Deine Bewertung hilft anderen Fahrern '
          'und Partnern.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: _muted, height: 1.45),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _line),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RatingPicker(
                  value: _rating,
                  hasError: _ratingError,
                  onChanged: (v) => setState(() {
                    _rating = v;
                    _ratingError = false;
                  }),
                ),
                const SizedBox(height: 24),
                _field(
                  controller: _name,
                  label: 'Name',
                  hint: 'Dein Name',
                  textInputAction: TextInputAction.next,
                  maxLength: 80,
                ),
                const SizedBox(height: 16),
                _field(
                  controller: _company,
                  label: 'Firmenname',
                  hint: 'Name des DSP / Unternehmens',
                  textInputAction: TextInputAction.next,
                  maxLength: 120,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _field(
                        controller: _stationCode,
                        label: 'Stations-Code',
                        hint: 'z. B. DDU5',
                        textInputAction: TextInputAction.next,
                        maxLength: 40,
                        required: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _stationCity,
                        label: 'Stadt der Station',
                        hint: 'z. B. München',
                        textInputAction: TextInputAction.next,
                        maxLength: 80,
                        required: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _field(
                  controller: _review,
                  label: 'Bewertung',
                  hint: 'Was lief gut? Was könnte besser sein?',
                  maxLines: 5,
                  maxLength: 2000,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: _error!),
                ],
                const SizedBox(height: 20),
                CoButton(
                  onPressed: _submit,
                  busy: _busy,
                  fullWidth: true,
                  label: 'Bewertung senden',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Deine Daten werden sicher in der EU gespeichert und nicht an '
          'Dritte weitergegeben.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), height: 1.4),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    bool required = true,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          buildCounter: (_,
                  {required currentLength,
                  required isFocused,
                  maxLength}) =>
              null,
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
                  ? 'Bitte ausfüllen'
                  : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.codriverGreen, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB91C1C)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  // ── Success ───────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Container(
      key: const ValueKey('done'),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.green50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 38,
              color: AppColors.codriverDeep,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Danke für deine Bewertung!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Deine Rückmeldung wurde gespeichert. Wir prüfen sie und '
            'schalten sie ggf. frei.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: _muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Star rating picker (spring tap feedback) ──────────────────────────
class _RatingPicker extends StatelessWidget {
  const _RatingPicker({
    required this.value,
    required this.onChanged,
    required this.hasError,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool hasError;

  static const _labels = [
    '',
    'Schlecht',
    'Geht so',
    'In Ordnung',
    'Gut',
    'Sehr gut',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Deine Sternebewertung',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: hasError ? const Color(0xFFB91C1C) : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final idx = i + 1;
            final active = idx <= value;
            return _Star(
              active: active,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(idx);
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            value >= 1 ? _labels[value] : 'Tippe auf einen Stern',
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: value >= 1
                  ? AppColors.codriverDeep
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }
}

class _Star extends StatefulWidget {
  const _Star({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  State<_Star> createState() => _StarState();
}

class _StarState extends State<_Star> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.86),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              widget.active ? Icons.star_rounded : Icons.star_outline_rounded,
              key: ValueKey(widget.active),
              size: 44,
              color: widget.active
                  ? const Color(0xFFF5B400)
                  : const Color(0xFFD1D5DB),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: Color(0xFFB91C1C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFFB91C1C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
