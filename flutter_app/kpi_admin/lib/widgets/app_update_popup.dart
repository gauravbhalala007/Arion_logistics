import 'package:flutter/material.dart';

import '../models/app_update.dart';
import '../services/app_updates_service.dart';
import '../theme/app_colors.dart';

/// Shows the newest unseen [AppUpdate] for [side] ('admin' | 'driver') as a
/// one-time post-login dialog. Safe to call repeatedly — it no-ops when there
/// is nothing new, and it marks the update as seen on dismissal so it won't
/// reappear. Guard against duplicate triggers with [AppUpdatePopup.shownThisSession].
class AppUpdatePopup {
  AppUpdatePopup._();

  /// Tracks per-(uid+side) keys already handled this app session, so a rebuild
  /// of the shell doesn't re-run the lookup on every frame.
  static final Set<String> _handled = <String>{};

  static Future<void> maybeShow(
    BuildContext context, {
    required String uid,
    required String side,
    AppUpdatesService? service,
  }) async {
    final key = '$uid::$side';
    if (_handled.contains(key)) return;
    _handled.add(key);

    final svc = service ?? AppUpdatesService();
    AppUpdate? update;
    try {
      update = await svc.latestUnseenFor(uid: uid, side: side);
    } catch (_) {
      // Reading appUpdates may fail (rules / offline) — never block the app.
      _handled.remove(key); // allow a retry on next mount
      return;
    }
    if (update == null) return;
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UpdateDialog(update: update!),
    );
    try {
      await svc.markSeen(uid: uid, updateId: update.id);
    } catch (_) {
      // best-effort
    }
  }
}

/// Localized chrome strings for the popup, keyed by language code.
const Map<String, String> _kNewInCodriver = {
  'en': 'New in CoDriver',
  'de': 'Neu in CoDriver',
  'sq': 'E re në CoDriver',
  'hu': 'Újdonság a CoDriverben',
  'ro': 'Nou în CoDriver',
  'hr': 'Novo u CoDriveru',
  'ar': 'جديد في CoDriver',
  'tr': "CoDriver'da yeni",
  'ru': 'Новое в CoDriver',
  'bg': 'Ново в CoDriver',
  'es': 'Novedades en CoDriver',
};

const Map<String, String> _kGotIt = {
  'en': 'Got it',
  'de': 'Verstanden',
  'sq': 'E kuptova',
  'hu': 'Értem',
  'ro': 'Am înțeles',
  'hr': 'U redu',
  'ar': 'فهمت',
  'tr': 'Anladım',
  'ru': 'Понятно',
  'bg': 'Разбрах',
  'es': 'Entendido',
};

String _tr(Map<String, String> m, String lang) => m[lang] ?? m['en']!;

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({required this.update});
  final AppUpdate update;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final body = update.bodyFor(lang);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.codriverGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      update.icon,
                      color: AppColors.codriverGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _tr(_kNewInCodriver, lang),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                update.titleFor(lang),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.codriverGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(_tr(_kGotIt, lang)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
