import 'package:flutter/material.dart';

/// Dezenter Hinweis-Kasten für Datei-Uploads von Amazon-Berichten.
///
/// Zeigt oben im Upload-Bereich, **wo** die Datei im Amazon-Portal (Cortex)
/// zu finden ist, und darunter klein/grau/monospace den **erwarteten
/// Dateinamen**.
///
/// Alle Texte sind zweisprachig (DE/EN) — die Sprache wird aus dem
/// aktuellen [Localizations]-Locale abgeleitet.
class ReportSourceHint extends StatelessWidget {
  const ReportSourceHint({
    super.key,
    required this.expectedFileName,
    this.sourceDe,
    this.sourceEn,
    this.extraHintDe,
    this.extraHintEn,
    this.extraFileName,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.compact = false,
  });

  /// Erwartetes Dateinamen-/Formatmuster, z. B.
  /// `DE-AION-DBY5-Week19-Concessions.xlsx`.
  final String expectedFileName;

  /// Abweichender Quellen-Pfad (Default: Cortex → Leistung →
  /// Zusätzliche Berichte).
  final String? sourceDe;
  final String? sourceEn;

  /// Optionaler Zusatz-Hinweis (z. B. Driver-CSV bei der Scorecard).
  final String? extraHintDe;
  final String? extraHintEn;

  /// Optionaler erwarteter Dateiname zum Zusatz-Hinweis.
  final String? extraFileName;

  final EdgeInsetsGeometry margin;

  /// Etwas engeres Padding — für Popup-Menüs / schmale Container.
  final bool compact;

  static const _bg = Color(0xFFF8FAFC);
  static const _border = Color(0xFFE2E8F0);
  static const _icon = Color(0xFF64748B);
  static const _text = Color(0xFF334155);
  static const _muted = Color(0xFF64748B);

  static const _mono = <String>[
    'Menlo',
    'SF Mono',
    'Consolas',
    'Courier New',
    'monospace',
  ];

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';

    final source = de
        ? (sourceDe ?? 'Quelle: Cortex → Leistung → Zusätzliche Berichte')
        : (sourceEn ?? 'Source: Cortex → Performance → Additional reports');

    final extra = de ? extraHintDe : extraHintEn;

    return Container(
      margin: margin,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 8 : 11,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline, size: 16, color: _icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  source,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 3),
                _fileLine(de, expectedFileName),
                if (extra != null && extra.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    extra,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  ),
                  if (extraFileName != null && extraFileName!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    _fileLine(de, extraFileName!),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileLine(bool de, String pattern) {
    return Text(
      '${de ? 'Erwartete Datei' : 'Expected file'}: $pattern',
      style: const TextStyle(
        fontSize: 11.5,
        height: 1.35,
        color: _muted,
        fontFamily: 'Menlo',
        fontFamilyFallback: _mono,
        letterSpacing: -0.1,
      ),
    );
  }
}
