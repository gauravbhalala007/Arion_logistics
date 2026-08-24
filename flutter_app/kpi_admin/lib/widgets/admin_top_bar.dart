// lib/widgets/admin_top_bar.dart
//
// Desktop-only top menu bar for the admin shell.
//   Left:  company name + selectable station (e.g. DBY5).
//   Right: paperclip (quick notes like IBAN — click to copy), language
//          switcher, updates, DA-Request bell, profile shortcut.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_localizations.dart';
import '../models/app_update.dart';
import '../services/app_updates_service.dart';
import '../services/da_request_badge.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.uid,
    required this.profile,
    required this.onOpenProfile,
    required this.onOpenUpdates,
    required this.onOpenDaRequests,
  });

  /// The admin's own uid (quick notes + station live on this user doc).
  final String uid;

  /// Live user-doc data from the shell's profile stream.
  final Map<String, dynamic> profile;

  /// Navigates to the profile page inside the shell.
  final VoidCallback onOpenProfile;

  /// Navigates to the updates page inside the shell.
  final VoidCallback onOpenUpdates;

  /// Navigates to the DA-Requests page inside the shell (bell icon).
  final VoidCallback onOpenDaRequests;

  DocumentReference<Map<String, dynamic>> get _userRef =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  List<String> get _stations {
    final raw = profile['stationCodes'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim().toUpperCase())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  String get _activeStation {
    final active = (profile['activeStationCode'] ?? '').toString().trim();
    if (active.isNotEmpty) return active.toUpperCase();
    final list = _stations;
    return list.isEmpty ? '' : list.first;
  }

  Future<void> _selectStation(BuildContext context, String value) async {
    if (value == '__add__') {
      final ctrl = TextEditingController();
      final code = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Station hinzufügen'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Stationscode',
              hintText: 'z. B. DBY5',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.codriverGreen),
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: const Text('Hinzufügen'),
            ),
          ],
        ),
      );
      final normalized = (code ?? '').trim().toUpperCase();
      if (normalized.isEmpty) return;
      await _userRef.set({
        'stationCodes': FieldValue.arrayUnion([normalized]),
        'activeStationCode': normalized,
      }, SetOptions(merge: true));
      return;
    }
    await _userRef.set(
      {'activeStationCode': value},
      SetOptions(merge: true),
    );
  }

  /// Marks the newest relevant update as seen (clears the green badge)
  /// and opens the updates page.
  Future<void> _openUpdates(List<AppUpdate> relevant) async {
    onOpenUpdates();
    if (relevant.isEmpty) return;
    await _userRef.set(
      {'lastSeenAppUpdateId': relevant.first.id},
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = (profile['companyName'] ?? profile['dspName'] ?? '')
        .toString()
        .trim();
    final station = _activeStation;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          width: double.infinity,
          // Icons sit flush right — only a slim right inset.
          padding: const EdgeInsets.only(left: 20, right: 8),
          // Same grey as the page background — separated from the content
          // only by the subtle inset divider below.
          color: const Color(0xFFF3F6F7),
          child: _buildRow(context, company, station),
        ),
        // Subtle divider that doesn't span the full width.
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 28),
          color: const Color(0xFFE1E4EA),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String company, String station) {
    // Stack instead of a flex Row so the icon group is PINNED to the right
    // edge no matter what the left side measures.
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Left: company + station ──
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              company.isEmpty ? '—' : company,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subheadline.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: 'Station wählen',
            onSelected: (v) => _selectStation(context, v),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (ctx) => [
              for (final s in _stations)
                PopupMenuItem<String>(
                  value: s,
                  child: Row(
                    children: [
                      Icon(
                        s == station
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        size: 16,
                        color: s == station
                            ? AppColors.codriverGreen
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 8),
                      Text(s),
                    ],
                  ),
                ),
              const PopupMenuItem<String>(
                value: '__add__',
                child: Row(
                  children: [
                    Icon(Icons.add_rounded,
                        size: 16, color: Color(0xFF1D7F5A)),
                    SizedBox(width: 8),
                    Text('Station hinzufügen…'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.codriverGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.codriverGreen.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.codriverDeep),
                  const SizedBox(width: 4),
                  Text(
                    station.isEmpty ? 'Station' : station,
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.codriverDeep,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: AppColors.codriverDeep),
                ],
              ),
            ),
          ),
        ],
          ),
        ),
        // ── Right (pinned to the edge): notes, language, updates,
        //    profile — white icon chips on the grey bar ──
        Align(
          alignment: Alignment.centerRight,
          child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BarIcon(
            tooltip: 'Wichtige Notizen',
            icon: Icons.attach_file_rounded,
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => _QuickNotesDialog(userRef: _userRef),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Sprache',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (code) => localeController.setLocale(Locale(code)),
            itemBuilder: (ctx) => [
              for (final locale in AppLocalizations.supportedLocales)
                PopupMenuItem<String>(
                  value: locale.languageCode,
                  child: Text(languageLabel(locale.languageCode)),
                ),
            ],
            child: const _BarIconChip(icon: Icons.translate_rounded),
          ),
          const SizedBox(width: 8),
          // Updates icon with a green badge counting unseen updates.
          StreamBuilder<List<AppUpdate>>(
            stream: AppUpdatesService().watchAll(),
            builder: (context, snap) {
              final lastSeen =
                  (profile['lastSeenAppUpdateId'] ?? '').toString();
              final relevant = <AppUpdate>[
                for (final u in (snap.data ?? const <AppUpdate>[]))
                  if (u.active && u.reaches('admin')) u,
              ];
              var unseen = 0;
              for (final u in relevant) {
                if (u.id == lastSeen) break;
                unseen++;
              }
              return _BarIcon(
                tooltip: 'Updates',
                icon: Icons.campaign_outlined,
                badgeCount: unseen,
                onTap: () => _openUpdates(relevant),
              );
            },
          ),
          const SizedBox(width: 8),
          // Glocke mit rotem Zaehler: offene DA Requests der Fahrer.
          StreamBuilder<int>(
            stream: DaRequestBadge.watchForContext(context),
            builder: (context, snap) {
              final open = snap.data ?? 0;
              final de =
                  Localizations.localeOf(context).languageCode == 'de';
              return _BarIcon(
                tooltip: open > 0
                    ? (de
                        ? 'Offene DA Requests: $open'
                        : 'Open DA requests: $open')
                    : (de ? 'DA Requests' : 'DA requests'),
                icon: Icons.notifications_outlined,
                badgeCount: open,
                badgeColor: AppColors.error,
                onTap: onOpenDaRequests,
              );
            },
          ),
          const SizedBox(width: 8),
          _BarIcon(
            tooltip: 'Profil',
            icon: Icons.account_circle_outlined,
            onTap: onOpenProfile,
          ),
        ],
          ),
        ),
      ],
    );
  }
}

/// White, fully round icon chip used on the grey top bar.
class _BarIconChip extends StatelessWidget {
  const _BarIconChip({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, size: 22, color: const Color(0xFF6B7280)),
    );
  }
}

/// Tappable white icon chip with an optional count badge (green by
/// default, red for attention-grabbing counters like open DA Requests).
class _BarIcon extends StatelessWidget {
  const _BarIcon({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.badgeColor = AppColors.codriverGreen,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _BarIconChip(icon: icon),
            if (badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Öffnet die Schnellnotizen des Admins — dieselbe UI wie hinter dem
/// Notiz-Icon der Desktop-Topbar. Wird zusätzlich vom mobilen Header der
/// Admin-Shell genutzt.
Future<void> showAdminQuickNotes(
  BuildContext context, {
  required String uid,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _QuickNotesDialog(
      userRef: FirebaseFirestore.instance.collection('users').doc(uid),
    ),
  );
}

/// Dialog managing the admin's quick notes (IBAN, insurance number, …).
/// Notes live on the user doc as `quickNotes: [{label, value}]`; a tap on a
/// note copies its value to the clipboard.
class _QuickNotesDialog extends StatelessWidget {
  const _QuickNotesDialog({required this.userRef});

  final DocumentReference<Map<String, dynamic>> userRef;

  Future<void> _addNote(BuildContext context) async {
    final labelCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notiz hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Bezeichnung',
                hintText: 'z. B. IBAN, Versicherungsnummer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueCtrl,
              decoration: const InputDecoration(
                labelText: 'Wert',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.codriverGreen),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final label = labelCtrl.text.trim();
    final value = valueCtrl.text.trim();
    if (label.isEmpty || value.isEmpty) return;
    await userRef.set({
      'quickNotes': FieldValue.arrayUnion([
        {'label': label, 'value': value},
      ]),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_file_rounded,
                      size: 20, color: AppColors.codriverDeep),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wichtige Notizen',
                      style: AppTypography.headline.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                'Zum Kopieren antippen — z. B. IBAN oder Versicherungsnummer.',
                style: AppTypography.caption1
                    .copyWith(color: const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: userRef.snapshots(),
                  builder: (context, snap) {
                    final raw = snap.data?.data()?['quickNotes'];
                    final notes = <Map<String, String>>[
                      if (raw is List)
                        for (final n in raw)
                          if (n is Map)
                            {
                              'label': (n['label'] ?? '').toString(),
                              'value': (n['value'] ?? '').toString(),
                            },
                    ];
                    if (notes.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Noch keine Notizen.',
                            style: TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final n = notes[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Clipboard.setData(
                                ClipboardData(text: n['value']!));
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.codriverDeep,
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  '„${n['label']}" kopiert.',
                                  style:
                                      const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n['label']!,
                                        style:
                                            AppTypography.caption2.copyWith(
                                          color: const Color(0xFF6B7280),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n['value']!,
                                        style: AppTypography.subheadline
                                            .copyWith(
                                          color: const Color(0xFF111827),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.copy_rounded,
                                    size: 16, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 6),
                                IconButton(
                                  tooltip: 'Löschen',
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Color(0xFF9CA3AF)),
                                  onPressed: () async {
                                    await userRef.set({
                                      'quickNotes': FieldValue.arrayRemove([
                                        {
                                          'label': n['label'],
                                          'value': n['value'],
                                        },
                                      ]),
                                    }, SetOptions(merge: true));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.codriverGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _addNote(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Notiz hinzufügen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
