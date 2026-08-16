// lib/Screens/driver_operating_instructions_page.dart
//
// DA Academy → Betriebsanweisungen.
//
// Sammelordner aller Betriebsanweisungen (BAW), gruppiert nach
// Themenbereich. Jede Anweisung folgt dem Standard-Schema mit sechs
// Abschnitten (siehe operating_instructions.dart) und kann auch direkt
// aus einem Kapitel der Sicherheitsunterweisung geöffnet werden.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/safety_training/operating_instructions.dart';
import '../data/safety_training/operating_instructions_ar.dart';
import '../data/safety_training/operating_instructions_bg.dart';
import '../data/safety_training/operating_instructions_de.dart';
import '../data/safety_training/operating_instructions_en.dart';
import '../data/safety_training/operating_instructions_es.dart';
import '../data/safety_training/operating_instructions_hr.dart';
import '../data/safety_training/operating_instructions_hu.dart';
import '../data/safety_training/operating_instructions_ro.dart';
import '../data/safety_training/operating_instructions_ru.dart';
import '../data/safety_training/operating_instructions_sq.dart';
import '../data/safety_training/operating_instructions_texts.dart';
import '../data/safety_training/operating_instructions_tr.dart';
import '../services/operating_instructions_ack_service.dart';

/// Anweisungen für [languageCode]; ohne Übersetzung deutsche Fassung.
///
/// [forDispatcher] blendet die Anweisungen ein, die nur die Disposition
/// betreffen (siehe [kDispatcherOnlyInstructionIds]). Für Fahrer bleiben
/// sie ausgeblendet — sie gelten für sie nicht und würden sonst als
/// offene Lesebestätigung mitgezählt.
List<OperatingInstruction> operatingInstructionsFor(
  String languageCode, {
  bool forDispatcher = false,
}) {
  final all = _allInstructionsFor(languageCode);
  if (forDispatcher) return all;
  return [
    for (final i in all)
      if (!kDispatcherOnlyInstructionIds.contains(i.id)) i,
  ];
}

List<OperatingInstruction> _allInstructionsFor(String languageCode) {
  return switch (languageCode) {
    'en' => operatingInstructionsEn,
    'sq' => operatingInstructionsSq,
    'hu' => operatingInstructionsHu,
    'ro' => operatingInstructionsRo,
    'hr' => operatingInstructionsHr,
    'tr' => operatingInstructionsTr,
    'ru' => operatingInstructionsRu,
    'bg' => operatingInstructionsBg,
    'ar' => operatingInstructionsAr,
    'es' => operatingInstructionsEs,
    _ => operatingInstructionsDe,
  };
}

/// Sucht bewusst in der UNGEFILTERTEN Liste: Wird eine Anweisung direkt
/// verlinkt oder aus einer Schulung heraus geöffnet, soll sie gefunden
/// werden — die Filterung betrifft nur die Übersichtsliste.
OperatingInstruction? operatingInstructionById(String languageCode, String id) {
  for (final i in _allInstructionsFor(languageCode)) {
    if (i.id == id) return i;
  }
  return null;
}

const _kText = Color(0xFF1A2233);
const _kMuted = Color(0xFF7A8699);
const _kGreen = Color(0xFF1D7F5A);
const _kMint = Color(0xFFEBF7F1);
const _kLine = Color(0xFFE3E8EF);
const _kAmber = Color(0xFFE9741A);
const _kAmberBg = Color(0xFFFDF1E6);

/// Zeitpunkt einer Lesebestätigung, wie er in der Oberfläche erscheint.
String _formatAckDate(DateTime at) =>
    DateFormat('dd.MM.yyyy, HH:mm').format(at);

IconData instructionIcon(InstructionCategory c) => switch (c) {
      InstructionCategory.vehicle => Icons.local_shipping_rounded,
      InstructionCategory.ppe => Icons.shield_rounded,
      InstructionCategory.handling => Icons.inventory_2_rounded,
      InstructionCategory.hazardous => Icons.science_rounded,
      InstructionCategory.hygiene => Icons.clean_hands_rounded,
      InstructionCategory.workplace => Icons.desktop_windows_rounded,
    };

String instructionCategoryLabel(InstructionCategory c, String lang) {
  final key = switch (c) {
    InstructionCategory.vehicle => 'cat_vehicle',
    InstructionCategory.ppe => 'cat_ppe',
    InstructionCategory.handling => 'cat_handling',
    InstructionCategory.hazardous => 'cat_hazardous',
    InstructionCategory.hygiene => 'cat_hygiene',
    InstructionCategory.workplace => 'cat_workplace',
  };
  return opsText(lang, key);
}

class DriverOperatingInstructionsPage extends StatefulWidget {
  final VoidCallback onBack;

  /// Identität des Fahrers — nur damit lassen sich Lesebestätigungen
  /// speichern. Fehlt sie (z. B. Vorschau ohne Anmeldung), bleibt die
  /// Seite reine Leseansicht.
  final String? dspUid;
  final String? driverTransporterId;

  const DriverOperatingInstructionsPage({
    super.key,
    required this.onBack,
    this.dspUid,
    this.driverTransporterId,
  });

  @override
  State<DriverOperatingInstructionsPage> createState() =>
      _DriverOperatingInstructionsPageState();
}

class _DriverOperatingInstructionsPageState
    extends State<DriverOperatingInstructionsPage> {
  OperatingInstructionsAckService? _ack;

  @override
  void initState() {
    super.initState();
    _ack = buildOperatingInstructionsAckService(
      widget.dspUid,
      widget.driverTransporterId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = _ack;
    if (service == null) return _buildScaffold(context, const {});

    return StreamBuilder<Map<String, OperatingInstructionAck>>(
      stream: service.watch(),
      builder: (context, snap) =>
          _buildScaffold(context, snap.data ?? const {}),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    Map<String, OperatingInstructionAck> acks,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    final all = operatingInstructionsFor(lang);

    // Nach Kategorie gruppieren, Reihenfolge der Enum-Deklaration folgen.
    final grouped = <InstructionCategory, List<OperatingInstruction>>{};
    for (final i in all) {
      (grouped[i.category] ??= []).add(i);
    }

    final done = all.where((i) => acks.containsKey(i.id)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F9),
        foregroundColor: _kText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        title: Text(
          opsText(lang, 'page_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(
              opsText(lang, 'page_intro'),
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: _kMuted,
              ),
            ),
            const SizedBox(height: 14),
            if (_ack != null && all.isNotEmpty) ...[
              _AckProgressCard(lang: lang, done: done, total: all.length),
              const SizedBox(height: 16),
            ],
            if (all.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kLine),
                ),
                child: Text(
                  opsText(lang, 'empty_list'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: _kMuted,
                  ),
                ),
              ),
            for (final cat in InstructionCategory.values)
              if (grouped[cat] != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Row(
                    children: [
                      Container(width: 16, height: 2.5, color: _kGreen),
                      const SizedBox(width: 8),
                      Text(
                        opsUpper(lang, instructionCategoryLabel(cat, lang)),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: _kGreen,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final ins in grouped[cat]!)
                  _InstructionTile(
                    instruction: ins,
                    ack: acks[ins.id],
                    ackService: _ack,
                  ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

/// Fortschritt der Lesebestätigungen über alle Betriebsanweisungen.
class _AckProgressCard extends StatelessWidget {
  final String lang;
  final int done;
  final int total;

  const _AckProgressCard({
    required this.lang,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final open = total - done;
    final complete = open <= 0;
    final accent = complete ? _kGreen : _kAmber;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: complete ? _kMint : _kAmberBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                complete
                    ? Icons.verified_rounded
                    : Icons.pending_actions_rounded,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  opsText(
                    lang,
                    'ack_progress',
                    vars: {'done': '$done', 'total': '$total'},
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: total == 0 ? 0 : done / total,
              ),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complete
                ? opsText(lang, 'ack_all_done')
                : opsText(lang, 'ack_open_count', vars: {'n': '$open'}),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF5A6473),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakter Status-Chip einer einzelnen Betriebsanweisung.
class _AckChip extends StatelessWidget {
  final String lang;
  final OperatingInstructionAck? ack;

  /// Kurzform ohne Datum — für die Übersichtsliste.
  final bool compact;

  const _AckChip({required this.lang, this.ack, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final confirmed = ack != null;
    final color = confirmed ? _kGreen : _kAmber;
    final label = confirmed
        ? (compact
            ? opsText(lang, 'ack_confirmed')
            : opsText(
                lang,
                'ack_confirmed_on',
                vars: {'date': _formatAckDate(ack!.at)},
              ))
        : opsText(lang, 'ack_pending');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: confirmed ? _kMint : _kAmberBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionTile extends StatelessWidget {
  final OperatingInstruction instruction;
  final OperatingInstructionAck? ack;
  final OperatingInstructionsAckService? ackService;

  const _InstructionTile({
    required this.instruction,
    this.ack,
    this.ackService,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final confirmed = ack != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OperatingInstructionDetailPage(
                instruction: instruction,
                ackService: ackService,
                initialAck: ack,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 12, 10, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: confirmed ? _kGreen.withValues(alpha: 0.35) : _kLine,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kMint,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(instructionIcon(instruction.category),
                      size: 19, color: _kGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        instruction.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        instruction.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _kMuted,
                          height: 1.3,
                        ),
                      ),
                      if (ackService != null) ...[
                        const SizedBox(height: 7),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _AckChip(
                            lang: lang,
                            ack: ack,
                            compact: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _kMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Detailansicht einer Betriebsanweisung — sechs feste Abschnitte.
///
/// Unten steht die Lesebestätigung: ein Bestätigen-Button, nach dem
/// Bestätigen die Bestätigungskarte samt Zeitpunkt.
class OperatingInstructionDetailPage extends StatefulWidget {
  final OperatingInstruction instruction;

  /// Fehlt der Dienst, bleibt die Seite reine Leseansicht.
  final OperatingInstructionsAckService? ackService;

  /// Bereits bekannter Stand aus der Übersicht — vermeidet Flackern.
  final OperatingInstructionAck? initialAck;

  const OperatingInstructionDetailPage({
    super.key,
    required this.instruction,
    this.ackService,
    this.initialAck,
  });

  @override
  State<OperatingInstructionDetailPage> createState() =>
      _OperatingInstructionDetailPageState();
}

class _OperatingInstructionDetailPageState
    extends State<OperatingInstructionDetailPage>
    with SingleTickerProviderStateMixin {
  OperatingInstructionAck? _ack;

  /// Verhindert doppeltes Schreiben bei mehrfachem Tippen.
  bool _busy = false;

  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    _ack = widget.initialAck;
    if (_ack != null) _anim.value = 1.0;

    // Direkteinstieg (z. B. aus einem Schulungskapitel): Stand nachladen.
    if (widget.ackService != null && widget.initialAck == null) {
      _loadAck();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _loadAck() async {
    try {
      final all = await widget.ackService!.load();
      if (!mounted) return;
      final ack = all[widget.instruction.id];
      if (ack == null) return;
      setState(() => _ack = ack);
      _anim.value = 1.0;
    } catch (_) {
      // Reines Nachladen — ein Fehlschlag darf die Seite nicht stören.
      // Der Bestätigen-Button bleibt sichtbar; ein zweites Bestätigen
      // überschreibt lediglich denselben Map-Eintrag.
    }
  }

  Future<void> _acknowledge() async {
    final service = widget.ackService;
    if (service == null) return;
    if (_busy || _ack != null) return; // kein Doppelklick, kein Doppeleintrag

    setState(() => _busy = true);
    final lang = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    try {
      await service
          .acknowledge(widget.instruction.id, at: now)
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      setState(() {
        _ack = OperatingInstructionAck(
          at: now,
          version: kOperatingInstructionsVersion,
        );
      });
      _anim.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(opsText(lang, 'ack_success'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(opsText(lang, 'ack_error')),
          backgroundColor: const Color(0xFFC0392B),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final i = widget.instruction;

    final sections = <(int, String, IconData, Color, List<String>)>[
      (
        2,
        opsText(lang, 'section_hazards'),
        Icons.warning_amber_rounded,
        const Color(0xFFB45309),
        i.hazards,
      ),
      (
        3,
        opsText(lang, 'section_protection'),
        Icons.verified_user_rounded,
        _kGreen,
        i.protection,
      ),
      (
        4,
        opsText(lang, 'section_failure'),
        Icons.build_circle_rounded,
        const Color(0xFF3B5A80),
        i.onFailure,
      ),
      (
        5,
        opsText(lang, 'section_accident'),
        Icons.medical_services_rounded,
        const Color(0xFFC0392B),
        i.onAccident,
      ),
      (
        6,
        opsText(lang, 'section_maintenance'),
        Icons.recycling_rounded,
        const Color(0xFF3B5A80),
        i.maintenance,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F9),
        foregroundColor: _kText,
        elevation: 0,
        title: Text(
          opsText(lang, 'detail_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            // Kopf
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
              decoration: BoxDecoration(
                color: _kMint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kGreen.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(instructionIcon(i.category),
                          size: 18, color: _kGreen),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          opsUpper(
                            lang,
                            instructionCategoryLabel(i.category, lang),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: _kGreen,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      if (widget.ackService != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: _AckChip(
                              lang: lang,
                              ack: _ack,
                              compact: true,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    i.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: _kText,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 1. Geltungsbereich
            _sectionHeader(
              1,
              opsText(lang, 'section_scope'),
              Icons.place_rounded,
              _kMuted,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 34, bottom: 18),
              child: Text(
                i.scope,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.55,
                  color: Color(0xFF3F4A5A),
                ),
              ),
            ),

            for (final (no, title, icon, color, items) in sections) ...[
              _sectionHeader(no, title, icon, color),
              Padding(
                padding: const EdgeInsets.only(left: 34, bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final it in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 7),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                it,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  height: 1.5,
                                  color: Color(0xFF3F4A5A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],

            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FA),
                borderRadius: BorderRadius.circular(14),
                border: const Border(
                  left: BorderSide(color: Color(0xFF3B5A80), width: 4),
                ),
              ),
              child: Text(
                opsText(lang, 'legal_note'),
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Color(0xFF3B5A80),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (widget.ackService != null) ...[
              const SizedBox(height: 20),
              _buildAckSection(lang),
            ],
          ],
        ),
      ),
    );
  }

  /// Lesebestätigung: vor dem Bestätigen der Button, danach die Karte
  /// mit Zeitpunkt.
  Widget _buildAckSection(String lang) {
    final ack = _ack;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: ack != null
          ? FadeTransition(
              key: const ValueKey('ack_done'),
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: _kMint,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kGreen.withValues(alpha: 0.45)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 34, color: _kGreen),
                      const SizedBox(height: 8),
                      Text(
                        opsText(lang, 'ack_confirmed'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _kGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opsText(
                          lang,
                          'ack_confirmed_on',
                          vars: {'date': _formatAckDate(ack.at)},
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF3F4A5A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              key: const ValueKey('ack_open'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  opsText(lang, 'ack_hint'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: _kMuted,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _acknowledge,
                  style: FilledButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kGreen.withValues(alpha: 0.55),
                    disabledForegroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded,
                          size: 20),
                  label: Text(
                    _busy
                        ? opsText(lang, 'ack_saving')
                        : opsText(lang, 'ack_button'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionHeader(int no, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$no',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kleine Verweiskarte — wird in Schulungskapiteln eingebettet.
class InstructionLinkCard extends StatelessWidget {
  final String instructionId;

  /// Fahreridentität — nur damit lässt sich aus der geöffneten
  /// Detailansicht heraus bestätigen.
  final String? dspUid;
  final String? driverTransporterId;

  const InstructionLinkCard({
    super.key,
    required this.instructionId,
    this.dspUid,
    this.driverTransporterId,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final ins = operatingInstructionById(lang, instructionId);
    if (ins == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OperatingInstructionDetailPage(
                instruction: ins,
                ackService: buildOperatingInstructionsAckService(
                  dspUid,
                  driverTransporterId,
                ),
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _kGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(instructionIcon(ins.category), size: 18, color: _kGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opsUpper(lang, opsText(lang, 'link_badge')),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: _kGreen,
                          letterSpacing: 0.9,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        ins.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new_rounded,
                    size: 16, color: _kGreen),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
