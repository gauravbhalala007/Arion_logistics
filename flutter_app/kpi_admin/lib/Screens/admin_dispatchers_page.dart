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
  _PermissionDef('dashboard', 'Score Card Dashboard'),
  _PermissionDef('pod_quality', 'POD Quality'),
  _PermissionDef('concessions', 'Concessions'),
  _PermissionDef('cdf', 'Customer Feedback'),
  _PermissionDef('dwc', 'DWC / IADC'),
  _PermissionDef('contact_compliance', 'Contact Compliance'),
  _PermissionDef('waveplan', 'Waveplan'),
  _PermissionDef('flexplan', 'Flexplan'),
  _PermissionDef('shift_plan', 'Shift Plan'),
  _PermissionDef('monthly_plan', 'Monthly Plan'),
  _PermissionDef('calendar', 'Kalender', 'Calendar'),
  _PermissionDef('drivers_hub', 'Drivers Hub'),
  _PermissionDef('recruiting', 'Recruiting'),
  _PermissionDef('tasks', 'Tasks'),
  _PermissionDef('shift_absence', 'Shift & Absence'),
  _PermissionDef('fleet_status', 'Fleet Hub'),
  _PermissionDef('vehicle_check', 'Fahrzeug-Check', 'Vehicle Check'),
  _PermissionDef('incident_reports', 'Incident Reports'),
  _PermissionDef('inventory', 'Inventar', 'Inventory'),
  _PermissionDef('cotimer', 'CoTimer'),
  _PermissionDef('payment_check', 'Payment Check'),
  _PermissionDef('academy', 'Academy'),
  _PermissionDef('dispatcher_pill', 'Dispatcher Pill'),
  _PermissionDef('notifications', 'Company Rules'),
  _PermissionDef('feedback', 'Feedback'),
  _PermissionDef('faqs', 'FAQs'),
  _PermissionDef('approvals', 'Driver Approvals'),
];

class _PermissionDef {
  final String key;
  final String label;

  /// English label; falls back to [label] for names that stay identical
  /// (product/Amazon terms such as Waveplan, Drivers Hub, Fleet Hub …).
  final String? labelEn;
  const _PermissionDef(this.key, this.label, [this.labelEn]);

  String labelFor(bool de) => de ? label : (labelEn ?? label);
}

class AdminDispatchersPage extends StatelessWidget {
  const AdminDispatchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) {
      return Scaffold(
        body: Center(
          child: Text(de ? 'Bitte zuerst einloggen.' : 'Please sign in first.'),
        ),
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
                    de ? 'Dispatcher-Accounts' : 'Dispatcher accounts',
                    style: AppTypography.title2.copyWith(
                      color: AppColors.codriverGraphite,
                    ),
                  ),
                  const Spacer(),
                  CoButton(
                    onPressed: () => _showCreateDialog(context, adminUid),
                    label: de ? 'Anlegen' : 'Add',
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
                            de
                                ? 'Noch keine Dispatcher angelegt.\n'
                                    'Tipp: oben rechts auf „Anlegen" klicken.'
                                : 'No dispatchers created yet.\n'
                                    'Tip: tap "Add" in the top right.',
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
    final de = Localizations.localeOf(context).languageCode == 'de';
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
                    ? '$allowedCount/${kDispatcherPermissions.length} '
                        '${de ? 'Module' : 'modules'}'
                    : (de ? 'Deaktiviert' : 'Deactivated'),
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
  final de = Localizations.localeOf(context).languageCode == 'de';
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  bool submitting = false;
  String? error;
  // Modul-Sichtbarkeit direkt beim Anlegen (Ticket) — Standard: ALLES an.
  final perms = <String, bool>{
    for (final p in kDispatcherPermissions) p.key: true,
  };

  /// Ticket: Dispatcher haben oft auch ein Fahrer-Konto — dieselbe
  /// E-Mail wuerde dessen Login ueberschreiben. Deshalb wird die
  /// E-Mail gegen die eigenen Fahrer geprueft (Felder email /
  /// loginEmail / onboarding.email).
  Future<String?> driverNameForEmail(String email) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUid)
          .collection('drivers')
          .get();
      final needle = email.trim().toLowerCase();
      for (final d in snap.docs) {
        final x = d.data();
        final candidates = <String>[
          (x['email'] ?? '').toString(),
          (x['loginEmail'] ?? '').toString(),
          ((x['onboarding'] is Map)
                  ? ((x['onboarding'] as Map)['email'] ?? '')
                  : '')
              .toString(),
        ];
        if (candidates
            .any((c) => c.trim().toLowerCase() == needle && needle.isNotEmpty)) {
          return (x['driverName'] ?? d.id).toString();
        }
      }
    } catch (_) {}
    return null;
  }

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
              setStateDialog(() => error = de
                  ? 'E-Mail und ein Passwort mit mind. 6 Zeichen sind nötig.'
                  : 'An email and a password with at least 6 characters '
                      'are required.');
              return;
            }
            setStateDialog(() {
              submitting = true;
              error = null;
            });
            // Fahrer-Email-Sperre (Ticket): gehoert die E-Mail einem
            // Fahrer dieses DSP, klar ablehnen statt kryptischem
            // "already exists".
            final driverName = await driverNameForEmail(email);
            if (driverName != null) {
              setStateDialog(() {
                submitting = false;
                error = de
                    ? 'Diese E-Mail gehört bereits zum Fahrer-Konto von '
                        '"$driverName". Dispatcher brauchen eine EIGENE '
                        'E-Mail — sonst würde der Fahrer-Login '
                        'überschrieben.'
                    : 'This email already belongs to the driver account '
                        'of "$driverName". Dispatchers need their OWN '
                        'email — otherwise the driver login would be '
                        'overwritten.';
              });
              return;
            }
            try {
              final result =
                  await FirebaseFunctions.instanceFor(region: 'us-central1')
                      .httpsCallable('createDispatcherAccount')
                      .call({
                'email': email,
                'password': pw,
                'displayName': nameCtrl.text.trim(),
              });
              // Modul-Auswahl DIREKT nach Firestore schreiben — die
              // Function kennt nur die alten 15 Schluessel und wuerde
              // neue Module verwerfen.
              final newUid = (result.data is Map)
                  ? ((result.data as Map)['uid'] ??
                          (result.data as Map)['dispatcherUid'] ??
                          '')
                      .toString()
                  : '';
              if (newUid.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(adminUid)
                    .collection('sub_accounts')
                    .doc(newUid)
                    .set({
                  'permissions': perms,
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            } on FirebaseFunctionsException catch (e) {
              setStateDialog(() {
                submitting = false;
                error = e.message ??
                    (de ? 'Fehler: ${e.code}' : 'Error: ${e.code}');
              });
            } catch (e) {
              setStateDialog(() {
                submitting = false;
                error = '$e';
              });
            }
          }

          return AlertDialog(
            title: Text(
              de ? 'Neuen Dispatcher anlegen' : 'Add new dispatcher',
            ),
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
                    decoration: InputDecoration(
                      labelText: de ? 'E-Mail' : 'Email',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: pwCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: de
                          ? 'Initial-Passwort (min. 6 Zeichen)'
                          : 'Initial password (min. 6 characters)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    de ? 'Sichtbare Module' : 'Visible modules',
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.codriverGraphite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    de
                        ? 'Standard: alle Seiten. Später jederzeit über das '
                            'Stift-Symbol änderbar.'
                        : 'Default: all pages. Editable any time via the '
                            'edit icon.',
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.labelSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final p in kDispatcherPermissions)
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(p.labelFor(de)),
                            value: perms[p.key] ?? true,
                            onChanged: submitting
                                ? null
                                : (v) => setStateDialog(
                                      () => perms[p.key] = v,
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
                ],
              ),
            ),
            actions: [
              CoButton(
                onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                label: de ? 'Abbrechen' : 'Cancel',
                variant: CoButtonVariant.quiet,
              ),
              CoButton(
                onPressed: submitting ? null : submit,
                label: de ? 'Anlegen' : 'Add',
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
  final de = Localizations.localeOf(context).languageCode == 'de';
  bool localActive = active;
  // Fehlender Schalter = ERLAUBT — muss zum Fallback der Dispatcher-
  // Shell passen (neue Module erscheinen sonst faelschlich als aus).
  final localPerms = <String, bool>{
    for (final p in kDispatcherPermissions) p.key: permissions[p.key] ?? true,
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
              // Rechte DIREKT nach Firestore (die Function kennt nur die
              // alten 15 Schluessel und wuerde neue Module verwerfen);
              // Aktiv/Inaktiv ueber die Function (sperrt den Auth-User).
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(adminUid)
                  .collection('sub_accounts')
                  .doc(dispatcherUid)
                  .set({
                'permissions': localPerms,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
              await FirebaseFunctions.instanceFor(region: 'us-central1')
                  .httpsCallable('updateDispatcherAccount')
                  .call({
                'dispatcherUid': dispatcherUid,
                'active': localActive,
              });
              if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
            } on FirebaseFunctionsException catch (e) {
              setSheetState(() {
                saving = false;
                error = e.message ??
                    (de ? 'Fehler: ${e.code}' : 'Error: ${e.code}');
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
                title: Text(
                  de ? 'Dispatcher löschen?' : 'Delete dispatcher?',
                ),
                content: Text(
                  de
                      ? 'Der Account "${displayName.isNotEmpty ? displayName : email}" '
                          'wird unwiderruflich entfernt.'
                      : 'The account "${displayName.isNotEmpty ? displayName : email}" '
                          'will be removed permanently.',
                ),
                actions: [
                  CoButton(
                    onPressed: () => Navigator.of(c).pop(false),
                    label: de ? 'Abbrechen' : 'Cancel',
                    variant: CoButtonVariant.quiet,
                  ),
                  CoButton(
                    onPressed: () => Navigator.of(c).pop(true),
                    label: de ? 'Löschen' : 'Delete',
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
                error = e.message ??
                    (de ? 'Fehler: ${e.code}' : 'Error: ${e.code}');
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
                    title: Text(de ? 'Account aktiv' : 'Account active'),
                    subtitle: Text(
                      de
                          ? 'Bei „Aus" kann sich der Dispatcher nicht mehr einloggen.'
                          : 'When off, the dispatcher can no longer sign in.',
                    ),
                    value: localActive,
                    onChanged: saving || deleting
                        ? null
                        : (v) => setSheetState(() => localActive = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    de ? 'Sichtbare Module' : 'Visible modules',
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
                            title: Text(p.labelFor(de)),
                            value: localPerms[p.key] ?? true,
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
                        label: de ? 'Löschen' : 'Delete',
                        icon: Icons.delete_outline_rounded,
                        variant: CoButtonVariant.destructiveQuiet,
                        busy: deleting,
                      ),
                      const Spacer(),
                      CoButton(
                        onPressed: saving || deleting
                            ? null
                            : () => Navigator.of(sheetCtx).pop(),
                        label: de ? 'Abbrechen' : 'Cancel',
                        variant: CoButtonVariant.quiet,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      CoButton(
                        onPressed: saving || deleting ? null : save,
                        label: de ? 'Speichern' : 'Save',
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
