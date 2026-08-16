// lib/widgets/license_plate.dart
//
// Wiederverwendbare Fleet-Hub-Bausteine aus dem Kunden-Handoff
// (`design_handoff_fleet_hub`):
//
//  * [LicensePlate] — deutsches EU-Kennzeichenschild (weißes Schild, schwarzer
//    Rand, innerer Doppelrand, blaues EU-Band mit Sternenkreis + „D",
//    HU-Plakette und Zulassungssiegel zwischen Stadt- und Erkennungsteil).
//  * [VinQrTile] — 74×74-Kachel mit echtem QR-Code (Inhalt = VIN).
//
// Beide Bausteine werden von der Fleethub-Übersicht (`fleet_status_page.dart`)
// und der Fahrzeug-Detailseite (`fleet_vehicle_detail_page.dart`) genutzt.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ---------------------------------------------------------------------------
// Farben (Handoff-Tokens)
// ---------------------------------------------------------------------------

const Color _kPlateInk = Color(0xFF14181D);
const Color _kPlateInnerRing = Color(0xFFDFE3E8);
const Color _kEuBlue = Color(0xFF003399);
const Color _kEuYellow = Color(0xFFF8D117);
const Color _kHuFill = Color(0xFFBCD6E9);
const Color _kHuBorder = Color(0xFF8AA8B9);
const Color _kHuCore = Color(0xFF5F7D8F);
const Color _kSealFill = Color(0xFFCDD2D8);
const Color _kSealRing = Color(0xFF8A93A0);
const Color _kSealCrest = Color(0xFFA83232);
const Color _kQrBorder = Color(0xFFE5E9EE);
const Color _kQrInk = Color(0xFF1A212B);

/// Schriftstapel für die FE-Schrift-Anmutung. Steht keine der Schriften zur
/// Verfügung, greift die Plattform-Sans — das Schild bleibt lesbar.
const String _kPlateFont = 'DIN Condensed';
const List<String> _kPlateFontFallback = <String>[
  'DIN Alternate',
  'Arial Narrow',
  'Helvetica Neue',
  'Arial',
];

// ---------------------------------------------------------------------------
// Kennzeichen-Zerlegung
// ---------------------------------------------------------------------------

/// Zerlegt ein Kennzeichen in Stadtkürzel und Erkennungsnummer — exakt nach
/// der Logik des Prototyps: führende Buchstaben abtrennen, davon je nach
/// Länge 1–3 Zeichen als Stadtteil, der Rest wandert hinter die Plaketten.
///
/// `ERHAL321` → `ERH` + `AL 321`, `FUDE319` → `FU` + `DE 319`.
class LicensePlateParts {
  const LicensePlateParts({required this.city, required this.rest});

  final String city;
  final String rest;

  static LicensePlateParts of(String raw) {
    final plate = raw.trim().toUpperCase().replaceAll(RegExp(r'[\s-]+'), '');
    if (plate.isEmpty) {
      return const LicensePlateParts(city: '', rest: '');
    }
    final match = RegExp(r'^([A-ZÄÖÜ]+?)(\d.*)$').firstMatch(plate);
    final letters = match?.group(1) ?? plate;
    final digits = match?.group(2) ?? '';
    final cityLen = letters.length >= 5
        ? 3
        : letters.length >= 4
        ? 2
        : 1;
    final cut = math.min(cityLen, letters.length);
    final city = letters.substring(0, cut);
    final tail = letters.substring(cut);
    final rest = <String>[tail, digits].where((p) => p.isNotEmpty).join(' ');
    return LicensePlateParts(city: city, rest: rest);
  }
}

// ---------------------------------------------------------------------------
// Kennzeichen-Schild
// ---------------------------------------------------------------------------

/// EU-Kennzeichenschild nach Handoff.
///
/// Zwei Größen wie im Design: [LicensePlate.compact] für die Fahrzeugzeilen
/// der Übersicht (34 px Höhe, Seitenverhältnis 520:110) und
/// [LicensePlate.detail] für die Profilkarte der Detailseite (260 px Breite,
/// Seitenverhältnis 520:130). Beide Maße sind über den jeweiligen Parameter
/// frei skalierbar; alle Innenmaße skalieren proportional mit.
class LicensePlate extends StatelessWidget {
  /// Zeilen-Variante der Übersicht — [height] in logischen Pixeln.
  const LicensePlate.compact({
    super.key,
    required this.plate,
    double height = 34,
  }) : _detail = false,
       _size = height;

  /// Große Variante der Detailseite — [width] in logischen Pixeln.
  const LicensePlate.detail({
    super.key,
    required this.plate,
    double width = 260,
  }) : _detail = true,
       _size = width;

  final String plate;

  /// `true` = Detail-Maße (520:130), `false` = Zeilen-Maße (520:110).
  final bool _detail;

  /// Detail: Breite. Compact: Höhe.
  final double _size;

  @override
  Widget build(BuildContext context) {
    final double height = _detail ? _size * 130 / 520 : _size;
    final double width = _detail ? _size : _size * 520 / 110;

    // Alle Handoff-Maße beziehen sich auf 65 px (Detail) bzw. 34 px (Zeile)
    // Schildhöhe — dieser Faktor hält sie bei abweichenden Größen im Lot.
    final double s = _detail ? height / 65 : height / 34;

    final double borderWidth = (_detail ? 2.0 : 1.5) * s;
    final double radius = (_detail ? 7.0 : 5.0) * s;
    final double innerGap = (_detail ? 2.0 : 1.5) * s;
    final double fontSize = (_detail ? 46.0 : 22.0) * s;
    final double letterSpacing = (_detail ? 0.0 : 0.5) * s;
    final double gap = (_detail ? 10.0 : 6.0) * s;
    final double padH = (_detail ? 8.0 : 7.0) * s;

    final parts = LicensePlateParts.of(plate);
    final textStyle = TextStyle(
      fontFamily: _kPlateFont,
      fontFamilyFallback: _kPlateFontFallback,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      color: _kPlateInk,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    );

    final group = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (parts.city.isNotEmpty) Text(parts.city, style: textStyle),
        if (parts.city.isNotEmpty) SizedBox(width: gap),
        _PlateSeals(scale: s, detail: _detail),
        if (parts.rest.isNotEmpty) SizedBox(width: gap),
        if (parts.rest.isNotEmpty) Text(parts.rest, style: textStyle),
      ],
    );

    return MediaQuery.withNoTextScaling(
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _kPlateInk, width: borderWidth),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Innerer Doppelrand: erst weiße Luft, dann der graue Ring.
              Padding(
                padding: EdgeInsets.all(innerGap),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      math.max(0, radius - borderWidth - innerGap),
                    ),
                    border: Border.all(color: _kPlateInnerRing, width: 1),
                  ),
                ),
              ),
              Row(
                children: [
                  _EuBand(width: width * 0.11, scale: s, detail: _detail),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padH),
                      child: Center(
                        child: FittedBox(fit: BoxFit.scaleDown, child: group),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blaues EU-Band links: Sternenkreis oben, Länderkennung „D" unten.
class _EuBand extends StatelessWidget {
  const _EuBand({
    required this.width,
    required this.scale,
    required this.detail,
  });

  final double width;
  final double scale;
  final bool detail;

  @override
  Widget build(BuildContext context) {
    final double star = (detail ? 13.0 : 8.0) * scale;
    final double dSize = (detail ? 12.0 : 8.5) * scale;
    final double padTop = (detail ? 6.0 : 3.0) * scale;
    final double padBottom = (detail ? 9.0 : 6.5) * scale;

    return Container(
      width: width,
      color: _kEuBlue,
      padding: EdgeInsets.only(top: padTop, bottom: padBottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: star,
            height: star,
            child: CustomPaint(painter: const _EuStarsPainter()),
          ),
          Text(
            'D',
            style: TextStyle(
              fontSize: dSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ],
      ),
    );
  }
}

/// HU-Plakette (hellblau) über dem Zulassungssiegel (grau, gestrichelter
/// Ring als angedeutete Ringschrift, rotes Mini-Wappen).
class _PlateSeals extends StatelessWidget {
  const _PlateSeals({required this.scale, required this.detail});

  final double scale;
  final bool detail;

  @override
  Widget build(BuildContext context) {
    final double hu = (detail ? 14.0 : 8.0) * scale;
    final double seal = (detail ? 16.0 : 9.0) * scale;
    final double gap = (detail ? 2.0 : 1.0) * scale;
    final double core = (detail ? 4.0 : 0.0) * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: hu,
          height: hu,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kHuFill,
            border: Border.all(color: _kHuBorder, width: 1),
          ),
          alignment: Alignment.center,
          child: core <= 0
              ? null
              : Container(
                  width: core,
                  height: core,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _kHuCore, width: 1),
                  ),
                ),
        ),
        SizedBox(height: gap),
        SizedBox(
          width: seal,
          height: seal,
          child: CustomPaint(painter: const _SealPainter()),
        ),
      ],
    );
  }
}

/// Zwölf gelbe Punkte im Kreis — die EU-Sterne des Bandes.
class _EuStarsPainter extends CustomPainter {
  const _EuStarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.shortestSide / 2 - size.shortestSide * 0.08;
    final dot = math.max(0.35, size.shortestSide * 0.065);
    final paint = Paint()..color = _kEuYellow;
    for (var i = 0; i < 12; i++) {
      final angle = (math.pi * 2 / 12) * i - math.pi / 2;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * ringRadius,
        dot,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EuStarsPainter oldDelegate) => false;
}

/// Zulassungssiegel: graue Scheibe, gestrichelter Ring, rotes Mini-Wappen.
class _SealPainter extends CustomPainter {
  const _SealPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(center, radius, Paint()..color = _kSealFill);

    final ring = Paint()
      ..color = _kSealRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, size.shortestSide * 0.07);
    final ringRadius = radius - ring.strokeWidth / 2;
    const segments = 10;
    const sweep = (math.pi * 2 / segments) * 0.55;
    for (var i = 0; i < segments; i++) {
      final start = (math.pi * 2 / segments) * i;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        start,
        sweep,
        false,
        ring,
      );
    }

    final crestWidth = size.width * 0.32;
    final crestHeight = size.height * 0.38;
    final crest = Rect.fromCenter(
      center: center,
      width: crestWidth,
      height: crestHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        crest,
        topLeft: Radius.circular(crestWidth * 0.2),
        topRight: Radius.circular(crestWidth * 0.2),
        bottomLeft: Radius.circular(crestWidth * 0.6),
        bottomRight: Radius.circular(crestWidth * 0.6),
      ),
      Paint()..color = _kSealCrest,
    );
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// VIN-QR-Kachel
// ---------------------------------------------------------------------------

/// Weiße Kachel mit echtem QR-Code (Inhalt = VIN) — Handoff: 74×74 px,
/// Rand `#E5E9EE`, Radius 8, 5 px Innenabstand.
///
/// Ohne VIN erscheint ein dezenter Platzhalter statt einer leeren Fläche.
class VinQrTile extends StatelessWidget {
  const VinQrTile({
    super.key,
    required this.data,
    this.size = 74,
    this.onTap,
    this.tooltip,
    this.bordered = true,
  });

  final String data;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  /// `false` rendert den Code ohne Rahmen und Kachelfläche — für Stellen, an
  /// denen der QR bereits in einem eigenen Block sitzt (Mobile-Fahrzeugkarte).
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final value = data.trim();

    Widget content = Container(
      width: size,
      height: size,
      padding: bordered ? EdgeInsets.all(size * 5 / 74) : EdgeInsets.zero,
      decoration: bordered
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kQrBorder),
            )
          : null,
      child: value.isEmpty
          ? Center(
              child: Icon(
                Icons.qr_code_2_outlined,
                size: size * 0.5,
                color: const Color(0xFFB6BEC8),
              ),
            )
          : QrImageView(
              data: value,
              version: QrVersions.auto,
              gapless: true,
              padding: EdgeInsets.zero,
              backgroundColor: bordered ? Colors.white : Colors.transparent,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: _kQrInk,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: _kQrInk,
              ),
              errorStateBuilder: (context, error) => Center(
                child: Icon(
                  Icons.qr_code_2_outlined,
                  size: size * 0.5,
                  color: const Color(0xFFB6BEC8),
                ),
              ),
            ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: content),
      );
    }
    if (tooltip == null || tooltip!.isEmpty) return content;
    return Tooltip(
      message: tooltip!,
      waitDuration: const Duration(milliseconds: 400),
      child: content,
    );
  }
}
