// lib/models/fleet_vehicle_remark.dart
//
// Mehrfach-Bemerkungen je Fahrzeug (Fleet Hub, Ticket JzvyBI6N06o5g5ftecyQ).
//
// Datenmodell in `users/{dsp}/fleet_vehicle_extras/{plate}`:
//
//   remarkList: [
//     { text: 'Schiebetür klemmt',
//       photos: [{url: 'https://…', path: 'vehicles/…'}],
//       createdAt: <Timestamp> },
//     …
//   ]
//
// Das alte Einzelfeld `remarks` bleibt als Fallback UND als Spiegel erhalten:
// - Lesen: fehlt `remarkList`, wird ein gesetztes `remarks` wie eine
//   Ein-Element-Liste behandelt (Bestand geht NIE verloren).
// - Schreiben: jeder Save schreibt `remarkList` (führend) und `remarks`
//   (alle Texte, zeilenweise) — ältere Leser sehen weiterhin etwas.
//
// Zusätzlich enthält die Datei das geteilte Anzeige-Widget
// [FleetRemarkLines] (Kopfzeile in Liste + Detailseite: je Bemerkung max.
// zwei Zeilen, Kamera-Icon bei Fotos) und das Foto-Popup
// [showFleetRemarkPhotosPopup] im Look des VIN-QR-Popups.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Amber-Ton der Bemerkungszeilen — identisch in Liste
/// (`_kAccentAmber`) und Detailseite (`_C.amberValue`).
const Color kFleetRemarkAmber = Color(0xFFB0731C);

/// Ein Foto an einer Bemerkung: Download-URL + Storage-Pfad.
class FleetVehicleRemarkPhoto {
  const FleetVehicleRemarkPhoto({required this.url, required this.path});

  final String url;
  final String path;

  Map<String, dynamic> toMap() => <String, dynamic>{'url': url, 'path': path};

  static FleetVehicleRemarkPhoto? fromRaw(dynamic raw) {
    if (raw is! Map) return null;
    final url = (raw['url'] ?? '').toString().trim();
    if (url.isEmpty) return null;
    return FleetVehicleRemarkPhoto(
      url: url,
      path: (raw['path'] ?? '').toString().trim(),
    );
  }
}

/// Eine einzelne Bemerkung mit optionalen Fotos.
class FleetVehicleRemark {
  const FleetVehicleRemark({
    required this.text,
    this.photos = const <FleetVehicleRemarkPhoto>[],
    this.createdAt,
  });

  final String text;
  final List<FleetVehicleRemarkPhoto> photos;

  /// Roh-Wert aus Firestore (Timestamp / ISO-String) — wird beim
  /// Zurückschreiben unverändert durchgereicht, damit Bestand erhalten
  /// bleibt. Neue Einträge bekommen `Timestamp.now()`.
  final Object? createdAt;

  bool get isEmpty => text.trim().isEmpty && photos.isEmpty;

  FleetVehicleRemark copyWith({
    String? text,
    List<FleetVehicleRemarkPhoto>? photos,
  }) {
    return FleetVehicleRemark(
      text: text ?? this.text,
      photos: photos ?? this.photos,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'text': text.trim(),
    'photos': <Map<String, dynamic>>[for (final p in photos) p.toMap()],
    'createdAt': createdAt ?? Timestamp.now(),
  };

  static FleetVehicleRemark? fromRaw(dynamic raw) {
    if (raw is! Map) return null;
    final text = (raw['text'] ?? '').toString().trim();
    final photos = <FleetVehicleRemarkPhoto>[
      if (raw['photos'] is List)
        for (final p in raw['photos'] as List)
          if (FleetVehicleRemarkPhoto.fromRaw(p) != null)
            FleetVehicleRemarkPhoto.fromRaw(p)!,
    ];
    if (text.isEmpty && photos.isEmpty) return null;
    return FleetVehicleRemark(
      text: text,
      photos: photos,
      createdAt: raw['createdAt'],
    );
  }
}

/// Liest die Bemerkungen eines Extras-Dokuments — `remarkList` führend,
/// gesetztes Alt-Feld `remarks` als Ein-Element-Fallback.
List<FleetVehicleRemark> fleetVehicleRemarksFromExtras(
  Map<String, dynamic> extras,
) {
  final raw = extras['remarkList'];
  if (raw is List) {
    return <FleetVehicleRemark>[
      for (final entry in raw)
        if (FleetVehicleRemark.fromRaw(entry) != null)
          FleetVehicleRemark.fromRaw(entry)!,
    ];
  }
  final legacy = (extras['remarks'] ?? '').toString().trim();
  if (legacy.isEmpty) return const <FleetVehicleRemark>[];
  return <FleetVehicleRemark>[FleetVehicleRemark(text: legacy)];
}

/// Spiegel-Text für das Alt-Feld `remarks`: alle Texte, zeilenweise.
String fleetVehicleRemarksLegacyText(List<FleetVehicleRemark> remarks) {
  return remarks
      .map((r) => r.text.trim())
      .where((t) => t.isNotEmpty)
      .join('\n');
}

/// Foto-Popup einer Bemerkung — gleiche Optik wie das VIN-QR-Popup der
/// Fleet-Liste (weißer Dialog, Radius 16, abgedunkelter Hintergrund).
Future<void> showFleetRemarkPhotosPopup(
  BuildContext context,
  FleetVehicleRemark remark,
) {
  final de = Localizations.localeOf(context).languageCode == 'de';
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final imgSize = (MediaQuery.of(ctx).size.width - 96).clamp(180.0, 420.0);
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: imgSize + 48,
            maxHeight: MediaQuery.of(ctx).size.height - 96,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < remark.photos.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      remark.photos[i].url,
                      width: imgSize,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          width: imgSize,
                          height: imgSize * 0.6,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => SizedBox(
                        width: imgSize,
                        height: 120,
                        child: Center(
                          child: Text(
                            de
                                ? 'Bild konnte nicht geladen werden.'
                                : 'Could not load the image.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF8A93A0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (remark.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SelectableText(
                    remark.text.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A212B),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Bemerkungszeilen für den Fahrzeug-Kopf (Liste + Detailseite): je
/// Bemerkung eine Amber-Zeile mit Notiz-Icon, max. zwei Zeilen Text
/// (Ellipsis, voller Text im Tooltip). Hat eine Bemerkung Fotos, sitzt
/// rechts ein kleines Kamera-Icon — Klick öffnet das Foto-Popup.
class FleetRemarkLines extends StatelessWidget {
  const FleetRemarkLines({
    super.key,
    required this.remarks,
    this.fontSize = 11.5,
    this.iconSize = 13,
  });

  final List<FleetVehicleRemark> remarks;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < remarks.length; i++) ...[
          if (i > 0) const SizedBox(height: 3),
          _line(context, remarks[i], de),
        ],
      ],
    );
  }

  Widget _line(BuildContext context, FleetVehicleRemark remark, bool de) {
    final text = remark.text.trim().isEmpty
        ? (de ? 'Foto-Bemerkung' : 'Photo remark')
        : remark.text.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Icon(
            Icons.sticky_note_2_outlined,
            size: iconSize,
            color: kFleetRemarkAmber,
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Tooltip(
            message: text,
            waitDuration: const Duration(milliseconds: 400),
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: kFleetRemarkAmber,
                height: 1.3,
              ),
            ),
          ),
        ),
        if (remark.photos.isNotEmpty) ...[
          const SizedBox(width: 5),
          Tooltip(
            message: de
                ? '${remark.photos.length} Foto(s) anzeigen'
                : 'Show ${remark.photos.length} photo(s)',
            waitDuration: const Duration(milliseconds: 300),
            child: InkWell(
              onTap: () => showFleetRemarkPhotosPopup(context, remark),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 1.5,
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: iconSize + 1,
                  color: kFleetRemarkAmber,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
