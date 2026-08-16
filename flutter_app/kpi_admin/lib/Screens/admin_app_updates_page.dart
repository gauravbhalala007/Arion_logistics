import 'package:flutter/material.dart';

import '../models/app_update.dart';
import '../services/app_updates_service.dart';
import '../theme/app_colors.dart';

/// "dd.MM.yyyy" for the update date shown on each card.
String _fmtDate(DateTime d) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${p(d.day)}.${p(d.month)}.${d.year}';
}

/// Read-only product updates / changelog. Each entry is a card with an icon,
/// title and short description. Entries are authored directly in the
/// `appUpdates` Firestore collection (superadmin only, enforced by rules) and
/// also surface as a post-login popup (see `AppUpdatePopup`). This page never
/// creates, edits or deletes — it only displays.
class AdminAppUpdatesPage extends StatefulWidget {
  const AdminAppUpdatesPage({super.key});

  @override
  State<AdminAppUpdatesPage> createState() => _AdminAppUpdatesPageState();
}

class _AdminAppUpdatesPageState extends State<AdminAppUpdatesPage> {
  static const _bg = Color(0xFFF3F6F7);
  static const _border = Color(0xFFE1E4EA);
  static const _title = Color(0xFF1F2937);
  static const _sub = Color(0xFF6B7280);

  final _service = AppUpdatesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'Updates',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _title,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AppUpdate>>(
                stream: _service.watchAll(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          Localizations.localeOf(context).languageCode == 'de'
                              ? 'Konnte Updates nicht laden: ${snap.error}'
                              : 'Could not load updates: ${snap.error}',
                          style: const TextStyle(color: _sub),
                        ),
                      ),
                    );
                  }
                  // Only active updates that target this (admin) app side.
                  final updates = <AppUpdate>[
                    for (final u in (snap.data ?? const <AppUpdate>[]))
                      if (u.active && u.reaches('admin')) u,
                  ];
                  if (updates.isEmpty) {
                    return Center(
                      child: Text(
                          Localizations.localeOf(context).languageCode == 'de'
                              ? 'Noch keine Updates.'
                              : 'No updates yet.',
                          style: const TextStyle(color: _sub)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    itemCount: updates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _UpdateCard(
                      update: updates[i],
                      borderColor: _border,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({
    required this.update,
    required this.borderColor,
  });

  final AppUpdate update;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final body = update.bodyFor(lang);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.codriverGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(update.icon,
                    color: AppColors.codriverDeep, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  update.titleFor(lang),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              if (update.createdAt != null) ...[
                const SizedBox(width: 10),
                Text(
                  _fmtDate(update.createdAt!),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
