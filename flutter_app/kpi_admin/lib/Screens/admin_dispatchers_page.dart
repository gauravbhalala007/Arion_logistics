// lib/Screens/admin_dispatchers_page.dart
//
// Admin-only page to manage dispatcher sub-accounts. The admin can
// create new dispatchers (email + initial password), toggle each
// dispatcher's per-module permissions, deactivate or delete them.
// All account-mutation traffic goes through the Cloud Functions
// `createDispatcherAccount`, `updateDispatcherAccount` and
// `deleteDispatcherAccount` (Admin SDK is required to spawn a second
// Auth user without disturbing the current admin session).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_scope.dart';
import '../widgets/co_button.dart';
import '../widgets/co_pressable.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Stable order of permission keys used by both the toggle list and the
/// default-permissions in the Cloud Function. Keep these in sync.
const List<_PermissionDef> kDispatcherPermissions = [
  _PermissionDef('waveplan', 'Waveplan'),
  _PermissionDef('calendar', 'Kalender'),
  _PermissionDef('drivers_hub', 'Drivers Hub'),
  _PermissionDef('tasks', 'Tasks'),
  _PermissionDef('shift_absence', 'Shift & Absence'),
  _PermissionDef('fleet_status', 'Fleet Hub'),
  _PermissionDef('incident_reports', 'Incident Reports'),
  _PermissionDef('academy', 'Academy'),
  _PermissionDef('dispatcher_pill', 'Dispatcher Pill'),
  _PermissionDef('feedback', 'Feedback'),
  _PermissionDef('faqs', 'FAQs'),
  _PermissionDef('approvals', 'Driver Approvals'),
];

class _PermissionDef {
  final String key;
  final String label;
  const _PermissionDef(this.key, this.label);
}

class AdminDispatchersPage extends StatelessWidget {
  const AdminDispatchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      return const Scaffold(
        body: Center(child: Text('Bitte zuerst einloggen.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.manage_accounts_rounded,
                    color: AppColors.codriverDeep,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Dispatcher-Accounts',
                    style: AppTypography.title2.copyWith(
                      color: AppColors.codriverGraphite,
                    ),
                  ),
                  const Spacer(),
                  CoButton(
                    onPressed: () => _showCreateDialog(context, adminUid),
                    label: 'Anlegen',
                    icon: Icons.add_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(adminUid)
                      .collection('sub_accounts')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snap) {
                    final Widget content;
                    if (snap.connectionState == ConnectionState.waiting) {
                      content = const Center(
                        key: ValueKey('loading'),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.codriverGreen,
                          ),
                        ),
                      );
                    } else {
                      final docs = snap.data?.docs ?? const [];
                      if (docs.isEmpty) {
                        content = Center(
                          key: const ValueKey('empty'),
                          child: Text(
                            'Noch keine Dispatcher angelegt.\n'
                            'Tipp: oben rechts auf „Anlegen" klicken.',
                            textAlign: TextAlign.center,
                            style: AppTypography.footnote.copyWith(
                              color: AppColors.labelSecondaryLight,
                            ),
                          ),
                        );
                      } else {
                        content = ListView.separated(
                          key: const ValueKey('list'),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (_, i) => _DispatcherRow(
                            adminUid: adminUid,
                            doc: docs[i],
                          ),
                        );
                      }
                    }
                    return CoStateSwitcher(child: content);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DispatcherRow extends StatelessWidget {
  final String adminUid;
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  const _DispatcherRow({required this.adminUid, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final email = (data['email'] ?? '').toString();
    final name = (data['displayName'] ?? '').toString();
    final active = data['active'] != false;
    final permissions = (data['permissions'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v == true)) ??
        const <String, bool>{};
    final allowedCount = permissions.values.where((v) => v).length;

    return CoPressable(
      onTap: () => _showEditSheet(
        context,
        adminUid: adminUid,
        dispatcherUid: doc.id,
        email: email,
        displayName: name,
        active: active,
        permissions: permissions,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevatedLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppElevation.level1,
          border: Border.all(
            color: AppColors.separatorLight.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.codriverGreen
                    : AppColors.labelTertiaryLight,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : email,
                    style: AppTypography.headline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    email,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.green50
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                active
                    ? '$allowedCount/${kDispatcherPermissions.length} Module'
                    : 'Deaktiviert',
                style: AppTypography.caption2.copyWith(
                  color: active
                      ? AppColors.codriverDeep
                      : AppColors.labelSecondaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.labelTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showCreateDialog(BuildContext context, String adminUid) async {
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  bool submitting = false;
  String? error;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setStateDialog) {
          Future<void> submit() async {
            final email = emailCtrl.text.trim();
            final pw = pwCtrl.text;
            if (email.isEmpty || pw.length < 6) {
              setStateDialog(() => error =
                  'E-Mail und ein Passwort mit mind. 6 Zeichen sind nötig.');
              return;
            }
            setStateDialog(() {
              submitting = true;
              error = null;
            });
            try {
              await FirebaseFunctions.instanceFor(region: 'us-central1')
                  .httpsCallable('createDispatcherAccount')
                  .call({
                'email': email,
                'password': pw,
                'displayName': nameCtrl.text.trim(),
              });
              if (ctx.mounted) Navigator.of(ctx).pop();
            } on FirebaseFunctionsException catch (e) {
              setStateDialog(() {
                submitting = false;
                error = e.message ?? 'Fehler: ${e.code}';
              });
            } catch (e) {
              setStateDialog(() {
                submitting = false;
                error = '$e';
              });
            }
          }

          return AlertDialog(
            title: const Text('Neuen Dispatcher anlegen'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name (optional)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-Mail',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: pwCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Initial-Passwort (min. 6 Zeichen)',
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              CoButton(
                onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                label: 'Abbrechen',
                variant: CoButtonVariant.quiet,
              ),
              CoButton(
                onPressed: submitting ? null : submit,
                label: 'Anlegen',
                busy: submitting,
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showEditSheet(
  BuildContext context, {
  required String adminUid,
  required String dispatcherUid,
  required String email,
  required String displayName,
  required bool active,
  required Map<String, bool> permissions,
}) async {
  bool localActive = active;
  final localPerms = <String, bool>{
    for (final p in kDispatcherPermissions) p.key: permissions[p.key] ?? false,
  };
  bool saving = false;
  bool deleting = false;
  String? error;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevatedLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          Future<void> save() async {
            setSheetState(() {
              saving = true;
              error = null;
            });
            try {
              await FirebaseFunctions.instanceFor(region: 'us-central1')
                  .httpsCallable('updateDispatcherAccount')
                  .call({
                'dispatcherUid': dispatcherUid,
                'active': localActive,
                'permissions': localPerms,
              });
              if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
            } on FirebaseFunctionsException catch (e) {
              setSheetState(() {
                saving = false;
                error = e.message ?? 'Fehler: ${e.code}';
              });
            } catch (e) {
              setSheetState(() {
                saving = false;
                error = '$e';
              });
            }
          }

          Future<void> delete() async {
            final confirm = await showDialog<bool>(
              context: sheetCtx,
              builder: (c) => AlertDialog(
                title: const Text('Dispatcher löschen?'),
                content: Text(
                  'Der Account "${displayName.isNotEmpty ? displayName : email}" '
                  'wird unwiderruflich entfernt.',
                ),
                actions: [
                  CoButton(
                    onPressed: () => Navigator.of(c).pop(false),
                    label: 'Abbrechen',
                    variant: CoButtonVariant.quiet,
                  ),
                  CoButton(
                    onPressed: () => Navigator.of(c).pop(true),
                    label: 'Löschen',
                    variant: CoButtonVariant.destructive,
                  ),
                ],
              ),
            );
            if (confirm != true) return;
            setSheetState(() {
              deleting = true;
              error = null;
            });
            try {
              await FirebaseFunctions.instanceFor(region: 'us-central1')
                  .httpsCallable('deleteDispatcherAccount')
                  .call({'dispatcherUid': dispatcherUid});
              if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
            } on FirebaseFunctionsException catch (e) {
              setSheetState(() {
                deleting = false;
                error = e.message ?? 'Fehler: ${e.code}';
              });
            }
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                MediaQuery.of(sheetCtx).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.separatorLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    displayName.isNotEmpty ? displayName : email,
                    style: AppTypography.title3.copyWith(
                      color: AppColors.codriverGraphite,
                    ),
                  ),
                  Text(
                    email,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Account aktiv'),
                    subtitle: const Text(
                      'Bei „Aus" kann sich der Dispatcher nicht mehr einloggen.',
                    ),
                    value: localActive,
                    onChanged: saving || deleting
                        ? null
                        : (v) => setSheetState(() => localActive = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Modul-Zugriff',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final p in kDispatcherPermissions)
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(p.label),
                            value: localPerms[p.key] ?? false,
                            onChanged: saving || deleting || !localActive
                                ? null
                                : (v) => setSheetState(
                                      () => localPerms[p.key] = v,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      CoButton(
                        onPressed: deleting || saving ? null : delete,
                        label: 'Löschen',
                        icon: Icons.delete_outline_rounded,
                        variant: CoButtonVariant.destructiveQuiet,
                        busy: deleting,
                      ),
                      const Spacer(),
                      CoButton(
                        onPressed: saving || deleting
                            ? null
                            : () => Navigator.of(sheetCtx).pop(),
                        label: 'Abbrechen',
                        variant: CoButtonVariant.quiet,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      CoButton(
                        onPressed: saving || deleting ? null : save,
                        label: 'Speichern',
                        busy: saving,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
