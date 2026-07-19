// lib/widgets/admin_scope.dart
//
// Scope helper for the dispatcher sub-account feature.
//
// Modules under the AdminShell historically read/write data under
// `users/{currentUser.uid}/...`. Dispatchers log in with their own
// UID but need to read/write the *parent admin's* namespace. Wrap
// the DispatcherShell body in `AdminScope(parentAdminUid)`; every
// module then resolves the effective admin via:
//
//   final adminUid = AdminScope.adminUidOf(context);
//
// On the regular AdminShell where no wrapper is present, this
// helper falls back to `FirebaseAuth.instance.currentUser?.uid`,
// so legacy callsites keep working untouched.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AdminScope extends InheritedWidget {
  /// UID of the DSP admin whose data namespace the subtree should
  /// operate on. For a real admin this is just `currentUser.uid`; for
  /// a dispatcher this is their `parentAdminUid`.
  final String adminUid;

  const AdminScope({
    super.key,
    required this.adminUid,
    required super.child,
  });

  static AdminScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminScope>();

  /// Resolves the effective admin UID for the subtree. Returns the
  /// scoped UID if a [AdminScope] is present, otherwise the currently
  /// signed-in user's UID, otherwise `null` (no auth).
  static String? adminUidOf(BuildContext context) {
    final scoped = maybeOf(context);
    if (scoped != null) return scoped.adminUid;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  bool updateShouldNotify(AdminScope oldWidget) =>
      oldWidget.adminUid != adminUid;
}
