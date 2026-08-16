// lib/services/account_switcher.dart
//
// Lets an admin who runs several stations under SEPARATE logins switch
// between them without manually logging out. The extra logins are stored
// ONLY in this browser's localStorage (never on the server) — the admin
// opts into this in the settings page. Switching = sign out + sign in.

import 'dart:convert';
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

/// A stored secondary login (one per station).
class LinkedAccount {
  final String label;
  final String email;
  final String password;
  const LinkedAccount({
    required this.label,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() =>
      {'label': label, 'email': email, 'password': password};

  factory LinkedAccount.fromJson(Map<dynamic, dynamic> j) => LinkedAccount(
        label: (j['label'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        password: (j['password'] ?? '').toString(),
      );
}

class AccountSwitcher {
  static const String _key = 'codriver_linked_accounts_v1';

  /// All stored secondary logins (synchronous — localStorage).
  static List<LinkedAccount> load() {
    try {
      final raw = html.window.localStorage[_key];
      if (raw == null || raw.isEmpty) return <LinkedAccount>[];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <LinkedAccount>[];
      return [
        for (final e in decoded)
          if (e is Map) LinkedAccount.fromJson(e),
      ];
    } catch (_) {
      return <LinkedAccount>[];
    }
  }

  static void _save(List<LinkedAccount> accounts) {
    html.window.localStorage[_key] =
        jsonEncode([for (final a in accounts) a.toJson()]);
  }

  /// Adds/replaces a login (keyed by email).
  static void add(LinkedAccount account) {
    final list = load()
      ..removeWhere(
          (e) => e.email.toLowerCase() == account.email.toLowerCase());
    list.add(account);
    _save(list);
  }

  static void remove(String email) {
    final list = load()
      ..removeWhere((e) => e.email.toLowerCase() == email.toLowerCase());
    _save(list);
  }

  /// Signs out of the current account and into [account]. Throws
  /// [FirebaseAuthException] on wrong credentials so the caller can report it.
  static Future<void> switchTo(LinkedAccount account) async {
    await FirebaseAuth.instance.signOut();
    await AuthService.signIn(
      email: account.email,
      password: account.password,
    );
  }
}
