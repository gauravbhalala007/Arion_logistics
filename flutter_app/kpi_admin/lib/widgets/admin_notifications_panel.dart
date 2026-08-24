// lib/widgets/admin_notifications_panel.dart
//
// Das Panel hinter der Header-Glocke: je Meldungs-Quelle eine Zeile
// [Icon] [Label] [Zaehler-Pille]. Quellen mit 0 werden ausgeblendet;
// sind alle 0, erscheint eine kurze Leermeldung.
//
// Zwei Darstellungen, gleicher Inhalt:
//   • Desktop — Menue direkt unter der Glocke ([showAdminNotificationsMenu])
//   • Mobil   — Bottom-Sheet im Stil der uebrigen Sheets
//               ([showAdminNotificationsSheet])
//
// Die Quellen selbst stehen in services/admin_notifications_service.dart —
// dort andocken, hier ist nichts anzupassen.

import 'package:flutter/material.dart';

import '../services/admin_notifications_service.dart';
import '../theme/app_colors.dart';
import 'app_side_menu.dart' show AppNav;

const Color _kInk = Color(0xFF1A212B);
const Color _kMuted = Color(0xFF6B7280);
const Color _kLine = Color(0xFFE5E9EE);

/// Oeffnet das Panel als Menue unter dem Glocken-Icon (Desktop).
/// [anchorContext] ist der BuildContext des Icons selbst.
Future<void> showAdminNotificationsMenu({
  required BuildContext anchorContext,
  required ValueChanged<AppNav> onNavigate,
}) async {
  final box = anchorContext.findRenderObject() as RenderBox?;
  final overlay =
      Navigator.of(anchorContext).overlay?.context.findRenderObject()
          as RenderBox?;
  if (box == null || overlay == null) return;

  final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight = box.localToGlobal(
    box.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  // Unterhalb der Glocke, rechtsbuendig zu ihr.
  final position = RelativeRect.fromLTRB(
    topLeft.dx,
    bottomRight.dy + 6,
    overlay.size.width - bottomRight.dx,
    0,
  );

  await showMenu<void>(
    context: anchorContext,
    position: position,
    color: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    constraints: const BoxConstraints(minWidth: 300, maxWidth: 340),
    items: [
      PopupMenuItem<void>(
        // Nicht die Zeile selbst ist klickbar, sondern die Eintraege
        // im Panel — deshalb `enabled: false`.
        enabled: false,
        padding: EdgeInsets.zero,
        child: _AdminNotificationsList(
          onNavigate: (nav) {
            Navigator.of(anchorContext).pop();
            onNavigate(nav);
          },
        ),
      ),
    ],
  );
}

/// Oeffnet das Panel als Bottom-Sheet (Mobil).
Future<void> showAdminNotificationsSheet({
  required BuildContext context,
  required ValueChanged<AppNav> onNavigate,
}) {
  final de = Localizations.localeOf(context).languageCode == 'de';
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _kLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  de ? 'Meldungen' : 'Notifications',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: _AdminNotificationsList(
                  showTitle: false,
                  onNavigate: (nav) {
                    Navigator.of(ctx).pop();
                    onNavigate(nav);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

/// Live-Liste der Quellen mit Zaehler > 0.
class _AdminNotificationsList extends StatelessWidget {
  const _AdminNotificationsList({
    required this.onNavigate,
    this.showTitle = true,
  });

  final ValueChanged<AppNav> onNavigate;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final sources = AdminNotificationsService.sourcesFor(context);

    return StreamBuilder<List<int>>(
      stream: AdminNotificationsService.combineCounts([
        for (final s in sources) s.count,
      ]),
      builder: (context, snap) {
        final counts = snap.data ?? const <int>[];
        final rows = <Widget>[];
        for (var i = 0; i < sources.length; i++) {
          final count = i < counts.length ? counts[i] : 0;
          if (count <= 0) continue;
          rows.add(
            _NotificationRow(
              source: sources[i],
              count: count,
              de: de,
              onTap: () => onNavigate(sources[i].target),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTitle) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  de ? 'Meldungen' : 'Notifications',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Divider(height: 1, color: _kLine),
            ],
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 22,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: _kMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        de
                            ? 'Keine neuen Meldungen'
                            : 'No new notifications',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: _kMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...rows,
            const SizedBox(height: 6),
          ],
        );
      },
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.source,
    required this.count,
    required this.de,
    required this.onTap,
  });

  final AdminNotificationSource source;
  final int count;
  final bool de;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.codriverGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                source.icon,
                size: 17,
                color: AppColors.codriverDeep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                source.label(de),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _kInk,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 2,
              ),
              constraints: const BoxConstraints(minWidth: 22),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: _kMuted),
          ],
        ),
      ),
    );
  }
}
