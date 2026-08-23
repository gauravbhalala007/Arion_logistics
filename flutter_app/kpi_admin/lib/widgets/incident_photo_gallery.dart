// lib/widgets/incident_photo_gallery.dart
//
// Gemeinsame Foto-Bausteine des Incident-Centers: Badge für die Kachel,
// Galerie mit Lightbox für die Detailansicht und der Vorschau-Streifen
// für noch nicht hochgeladene Bilder in beiden Formularen.
//
// Die Lightbox folgt dem Muster aus `admin_vehicle_check_detail_page.dart`
// (`InteractiveViewer` in einem transparenten `Dialog` auf schwarzem
// Barrier); hier zusätzlich mit Blättern, weil ein Vorfall mehrere Fotos
// ohne feste Schritt-Zuordnung hat.

import 'package:flutter/material.dart';

import '../services/incident_photos.dart';
import '../services/incident_reports.dart' show IncidentPhoto;
import 'co_pressable.dart';

const Color _kBorder = Color(0xFFE5E7EB);
const Color _kFill = Color(0xFFF7F8F8);
const Color _kMuted = Color(0xFF6B7280);
const Color _kText = Color(0xFF111827);

/// Kleines Zähler-Badge für die Vorfall-Kachel.
class IncidentPhotoBadge extends StatelessWidget {
  const IncidentPhotoBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Tooltip(
      message: de
          ? '$count ${count == 1 ? 'Foto' : 'Fotos'}'
          : '$count ${count == 1 ? 'photo' : 'photos'}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.photo_camera_outlined,
              size: 13,
              color: Color(0xFF475467),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475467),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Galerie bereits hochgeladener Fotos. [onRemove] blendet ein Entfernen-X
/// ein — im Bearbeiten-Modus des Admin-Formulars.
class IncidentPhotoGallery extends StatelessWidget {
  const IncidentPhotoGallery({
    super.key,
    required this.photos,
    this.onRemove,
    this.thumbWidth = 148,
    this.thumbHeight = 104,
  });

  final List<IncidentPhoto> photos;
  final void Function(int index)? onRemove;
  final double thumbWidth;
  final double thumbHeight;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    final urls = <String>[for (final p in photos) p.url];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (var i = 0; i < photos.length; i++)
          _Thumb(
            width: thumbWidth,
            height: thumbHeight,
            onTap: () => showIncidentPhotoLightbox(
              context,
              urls: urls,
              initialIndex: i,
            ),
            onRemove: onRemove == null ? null : () => onRemove!(i),
            child: Image.network(
              photos[i].url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 20,
                  color: _kMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Vorschau der ausgewählten, noch nicht hochgeladenen Fotos.
class PickedIncidentPhotoStrip extends StatelessWidget {
  const PickedIncidentPhotoStrip({
    super.key,
    required this.photos,
    required this.onRemove,
    this.removeTooltip,
    this.enabled = true,
    this.thumbWidth = 110,
    this.thumbHeight = 80,
  });

  final List<PickedIncidentPhoto> photos;
  final void Function(int index) onRemove;
  final String? removeTooltip;
  final bool enabled;
  final double thumbWidth;
  final double thumbHeight;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (var i = 0; i < photos.length; i++)
          _Thumb(
            width: thumbWidth,
            height: thumbHeight,
            onTap: () => _showMemoryLightbox(context, photos[i]),
            onRemove: enabled ? () => onRemove(i) : null,
            removeTooltip: removeTooltip,
            child: Image.memory(
              photos[i].bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 20,
                  color: _kMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static void _showMemoryLightbox(
    BuildContext context,
    PickedIncidentPhoto photo,
  ) {
    _showLightboxShell(
      context,
      title: photo.name,
      builder: (_) => Image.memory(photo.bytes, fit: BoxFit.contain),
    );
  }
}

/// Vollbild-Ansicht mit Zoom und Blättern.
void showIncidentPhotoLightbox(
  BuildContext context, {
  required List<String> urls,
  int initialIndex = 0,
}) {
  final clean = <String>[
    for (final u in urls)
      if (u.trim().isNotEmpty) u.trim(),
  ];
  if (clean.isEmpty) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => _IncidentLightbox(
      urls: clean,
      initialIndex: initialIndex.clamp(0, clean.length - 1),
    ),
  );
}

void _showLightboxShell(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  final de = Localizations.localeOf(context).languageCode == 'de';
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title.isNotEmpty)
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 10),
          Flexible(child: InteractiveViewer(maxScale: 5, child: builder(ctx))),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(de ? 'Schließen' : 'Close'),
          ),
        ],
      ),
    ),
  );
}

class _IncidentLightbox extends StatefulWidget {
  const _IncidentLightbox({required this.urls, required this.initialIndex});

  final List<String> urls;
  final int initialIndex;

  @override
  State<_IncidentLightbox> createState() => _IncidentLightboxState();
}

class _IncidentLightboxState extends State<_IncidentLightbox> {
  late int _index = widget.initialIndex;

  void _step(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.urls.length) return;
    setState(() => _index = next);
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final multi = widget.urls.length > 1;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            multi
                ? '${_index + 1} / ${widget.urls.length}'
                : (de ? 'Foto' : 'Photo'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (multi)
                  _NavButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: de ? 'Vorheriges Foto' : 'Previous photo',
                    onPressed: _index == 0 ? null : () => _step(-1),
                  ),
                Flexible(
                  child: InteractiveViewer(
                    // Ein neuer Key pro Bild setzt Zoom/Pan beim Blättern
                    // zurück — sonst startet das nächste Foto im Zoom des
                    // vorherigen.
                    key: ValueKey<int>(_index),
                    maxScale: 5,
                    child: Image.network(
                      widget.urls[_index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          de
                              ? 'Foto konnte nicht geladen werden.'
                              : 'Could not load photo.',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                if (multi)
                  _NavButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: de ? 'Nächstes Foto' : 'Next photo',
                    onPressed: _index == widget.urls.length - 1
                        ? null
                        : () => _step(1),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(de ? 'Schließen' : 'Close'),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      tooltip: tooltip,
      color: Colors.white,
      disabledColor: Colors.white24,
      // 44 pt Tap-Ziel, auch wenn das Chevron kleiner wirkt.
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }
}

/// Thumbnail-Rahmen mit optionalem Entfernen-X — von Galerie und
/// Auswahl-Streifen geteilt, damit beide identisch aussehen.
class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.width,
    required this.height,
    required this.child,
    required this.onTap,
    this.onRemove,
    this.removeTooltip,
  });

  final double width;
  final double height;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final String? removeTooltip;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CoPressable(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                  color: _kFill,
                ),
                child: child,
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 2,
              right: 2,
              child: Tooltip(
                message:
                    removeTooltip ?? (de ? 'Foto entfernen' : 'Remove photo'),
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(
                    side: BorderSide(color: _kBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onRemove,
                    child: const SizedBox(
                      width: 26,
                      height: 26,
                      child: Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: _kText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
