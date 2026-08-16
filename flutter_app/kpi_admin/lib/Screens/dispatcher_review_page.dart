// lib/Screens/dispatcher_review_page.dart
//
// Öffentliche Bewertungsseite für Dispatcher (Link ohne Login).
//
// Aufruf: /review?t={token}
// Der Dispatcher arbeitet die aktiven Fahrer nacheinander durch und
// bewertet jeden mit kurzen Auswahlfragen plus Pflichtkommentar.
// Die Fahrerliste kommt aus dem Link-Dokument — die Seite greift nicht
// auf die Fahrerstammdaten zu.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../data/driver_review_model.dart';

class DispatcherReviewPage extends StatefulWidget {
  final String token;
  const DispatcherReviewPage({super.key, required this.token});

  @override
  State<DispatcherReviewPage> createState() => _DispatcherReviewPageState();
}

class _DispatcherReviewPageState extends State<DispatcherReviewPage> {
  static const _kBg = Color(0xFFF5F7F9);
  static const _kText = Color(0xFF1A2233);
  static const _kMuted = Color(0xFF7A8699);
  static const _kGreen = Color(0xFF1D7F5A);
  static const _kMint = Color(0xFFEBF7F1);
  static const _kLine = Color(0xFFE3E8EF);

  bool _loading = true;
  String? _error;

  String _adminUid = '';
  String _dispatcherName = '';
  String _period = '';
  List<Map<String, String>> _drivers = const [];

  int _index = 0;
  final Set<String> _submitted = {};

  // Antworten des aktuellen Fahrers
  final Map<String, int> _answers = {};
  int? _attitude;
  final _commentCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('dispatcher_review_links')
          .doc(widget.token)
          .get();
      if (!mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      final data = snap.data();
      if (!snap.exists || data == null) {
        setState(() {
          _loading = false;
          _error = de ? 'Dieser Link ist ungültig.' : 'This link is invalid.';
        });
        return;
      }
      if (data['active'] != true) {
        setState(() {
          _loading = false;
          _error = de
              ? 'Dieser Link ist nicht mehr aktiv.'
              : 'This link is no longer active.';
        });
        return;
      }
      final raw = (data['drivers'] as List?) ?? const [];
      final drivers = <Map<String, String>>[];
      for (final d in raw) {
        if (d is! Map) continue;
        final tid = (d['tid'] ?? '').toString().trim();
        if (tid.isEmpty) continue;
        drivers.add({
          'tid': tid,
          'name': (d['name'] ?? tid).toString(),
        });
      }
      // Bereits abgegebene Bewertungen dieses Zeitraums überspringen.
      final done = (data['completed'] as List?) ?? const [];
      setState(() {
        _adminUid = (data['adminUid'] ?? '').toString();
        _dispatcherName = (data['dispatcherName'] ?? '').toString();
        _period = (data['period'] ?? currentReviewPeriod()).toString();
        _drivers = drivers;
        _submitted.addAll(done.map((e) => e.toString()));
        _index = drivers.indexWhere((d) => !_submitted.contains(d['tid']));
        if (_index < 0) _index = drivers.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final de = Localizations.localeOf(context).languageCode == 'de';
      setState(() {
        _loading = false;
        _error = de
            ? 'Link konnte nicht geladen werden.'
            : 'The link could not be loaded.';
      });
    }
  }

  bool get _canSubmit =>
      _answers.length == kDriverReviewQuestions.length &&
      _attitude != null &&
      _commentCtrl.text.trim().length >= 3;

  Future<void> _submitCurrent() async {
    if (!_canSubmit || _saving) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    setState(() => _saving = true);
    final driver = _drivers[_index];
    try {
      final score = reviewScore(_answers);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_adminUid)
          .collection('driver_reviews')
          .doc('${_period}_${driver['tid']}')
          .set({
        'linkToken': widget.token,
        'period': _period,
        'driverTransporterId': driver['tid'],
        'driverName': driver['name'],
        'dispatcherName': _dispatcherName,
        'ratings': _answers,
        'attitude': _attitude,
        'comment': _commentCtrl.text.trim(),
        'note': _noteCtrl.text.trim(),
        'score': score,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Fortschritt im Link vermerken, damit ein erneutes Öffnen dort
      // weitermacht, wo der Dispatcher aufgehört hat.
      await FirebaseFirestore.instance
          .collection('dispatcher_review_links')
          .doc(widget.token)
          .set({
        'completed': FieldValue.arrayUnion([driver['tid']]),
        'lastActivityAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        _submitted.add(driver['tid']!);
        _answers.clear();
        _attitude = null;
        _commentCtrl.clear();
        _noteCtrl.clear();
        _index++;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Speichern fehlgeschlagen: $e' : 'Saving failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _errorView()
                    : _index >= _drivers.length
                        ? _doneView()
                        : _reviewForm(),
          ),
        ),
      ),
    );
  }

  Widget _errorView() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off_rounded, size: 48, color: _kMuted),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              de
                  ? 'Bitte wende dich an deinen Admin.'
                  : 'Please contact your admin.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: _kMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doneView() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded, size: 60, color: _kGreen),
            const SizedBox(height: 14),
            Text(
              de
                  ? 'Alle Fahrer bewertet — danke!'
                  : 'All drivers reviewed — thank you!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: _kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              de
                  ? 'Du hast ${_drivers.length} Bewertungen für '
                      '${_periodLabel(_period, de)} abgegeben. Nächsten Monat '
                      'bekommst du wieder einen Link.'
                  : 'You submitted ${_drivers.length} reviews for '
                      '${_periodLabel(_period, de)}. Next month you will get '
                      'a new link.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: _kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewForm() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final driver = _drivers[_index];
    final done = _submitted.length;
    final total = _drivers.length;

    return Column(
      children: [
        // Kopf mit Fortschritt
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${de ? 'Monatsbewertung' : 'Monthly review'} · '
                      '${_periodLabel(_period, de)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: _kGreen,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    '${done + 1} / $total',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _kMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  minHeight: 5,
                  backgroundColor: _kLine,
                  valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _kMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(driver['name'] ?? ''),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _kGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _kText,
                          ),
                        ),
                        Text(
                          driver['tid'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            key: ValueKey(driver['tid']),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            children: [
              for (final q in kDriverReviewQuestions) _questionTile(q, de),
              _choiceTile(
                label: de ? 'Grundhaltung' : 'Attitude',
                options: de ? kAttitudeOptionsDe : kAttitudeOptionsEn,
                value: _attitude,
                onChanged: (v) => setState(() => _attitude = v),
              ),
              const SizedBox(height: 4),
              _textField(
                controller: _commentCtrl,
                label: de ? 'Kommentar (Pflicht)' : 'Comment (required)',
                hint: de
                    ? 'Wie lief der Monat mit diesem Fahrer?'
                    : 'How did the month go with this driver?',
                minLines: 3,
              ),
              _textField(
                controller: _noteCtrl,
                label: de
                    ? 'Interne Notiz (optional)'
                    : 'Internal note (optional)',
                hint: de
                    ? 'Nur für den Admin sichtbar'
                    : 'Visible to the admin only',
                minLines: 2,
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          color: Colors.white,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _canSubmit && !_saving ? _submitCurrent : null,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                _index == _drivers.length - 1
                    ? (de ? 'Speichern & abschließen' : 'Save & finish')
                    : (de
                        ? 'Speichern & nächster Fahrer'
                        : 'Save & next driver'),
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

  /// `reviewPeriodLabel()` liefert nur deutsche Monatsnamen — für EN hier
  /// die englische Entsprechung aus dem Perioden-Key ('2026-08').
  static String _periodLabel(String period, bool de) {
    if (de) return reviewPeriodLabel(period);
    const monthsEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final parts = period.split('-');
    if (parts.length != 2) return period;
    final m = int.tryParse(parts[1]) ?? 0;
    if (m < 1 || m > 12) return period;
    return '${monthsEn[m - 1]} ${parts[0]}';
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  /// Das Modell liefert Antwortoptionen zweisprachig, Frage-Label und
  /// -Hinweis aber nur auf Deutsch — hier die englischen Entsprechungen.
  static const Map<String, String> _questionLabelEn = {
    'pace': 'Work pace',
    'helpfulness': 'Helpfulness',
    'communication': 'Communication',
    'punctuality': 'Punctuality',
    'mood': 'Mood & demeanour',
    'complaints': 'Complains',
    'vehicle': 'Vehicle cleanliness',
    'respect': 'Respectful behaviour',
    'language': 'Language skills',
  };

  static const Map<String, String> _questionHintEn = {
    'pace': 'Too fast is just as much a risk as too slow.',
    'communication': 'Reachability, feedback, reporting problems.',
    'respect': 'Towards colleagues, managers and customers.',
  };

  Widget _questionTile(ReviewQuestion q, bool de) => _choiceTile(
        label: de ? q.label : (_questionLabelEn[q.id] ?? q.label),
        hint: de ? q.hintDe : _questionHintEn[q.id],
        options: de ? q.optionsDe : q.optionsEn,
        value: _answers[q.id],
        onChanged: (v) => setState(() => _answers[q.id] = v),
      );

  Widget _choiceTile({
    required String label,
    String? hint,
    required List<String> options,
    required int? value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value == null ? _kLine : _kGreen.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 2),
              Text(
                hint,
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
            ],
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < options.length; i++)
                  _optionChip(
                    text: options[i],
                    selected: value == i,
                    onTap: () => onChanged(i),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionChip({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? _kGreen : const Color(0xFFF3F6F9),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF3F4A5A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int minLines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines + 4,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
