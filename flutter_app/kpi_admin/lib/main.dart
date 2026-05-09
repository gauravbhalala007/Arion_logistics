import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
import 'widgets/auth_gate.dart';
import 'Screens/login_page.dart';
import 'Screens/signup_page.dart';
import 'Screens/verify_email_page.dart';
import 'Screens/driver_dashboard_page.dart';
import 'Screens/admin_shell_page.dart';
import 'widgets/app_side_menu.dart'; // for AppNav

import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/app_localizations.dart';
import 'theme/app_theme.dart';

/// Use emulators only in debug/profile, never in release.
bool get useEmulators => !kReleaseMode;

/// Global Storage instance bound to the bucket from firebase_options.dart.
late final FirebaseStorage storage;

Future<void> _connectToEmulators() async {
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  await storage.useStorageEmulator('127.0.0.1', 9199);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  // TEMP logs
  // ignore: avoid_print
  // print('🔧 projectId: ${Firebase.app().options.projectId}');
  // ignore: avoid_print
  // print(
  //   '🔧 storageBucket (from options): ${DefaultFirebaseOptions.currentPlatform.storageBucket}',
  // );

  final bucket = DefaultFirebaseOptions.currentPlatform.storageBucket!;
  storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');

  // ignore: avoid_print
  // print('🔧 storage.bucket runtime: ${storage.bucket}');

  // if (useEmulators) {
  //   await _connectToEmulators();
  // }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  Widget _wrapSelectable(Widget child) => SelectionArea(child: child);

  @override
  Widget build(BuildContext context) {
    // 🔑 AnimatedBuilder listens to the global localeController.
    // Whenever localeController.setLocale(...) is called,
    // MaterialApp is rebuilt with the new locale → entire app language updates.
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'DSP Copilot',
          debugShowCheckedModeBanner: false,
          // 🌍 Current app locale (null = use system locale)
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(),

          home: _wrapSelectable(const AuthGate()),
          routes: {
            '/login': (_) => _wrapSelectable(const LoginPage()),
            '/signup': (_) => _wrapSelectable(const SignupPage()),
            '/verify-email': (_) => _wrapSelectable(const VerifyEmailPage()),
            '/profile': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.profile),
            ),

            // ✅ all side-menu destinations go through the shell
            '/home': (_) =>
                _wrapSelectable(const AdminShellPage(initialNav: AppNav.home)),
            '/dashboard': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.dashboard),
            ),
            '/pod-quality': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.podQuality),
            ),
            '/drivers': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.drivers),
            ),
            '/waveplan': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.waveplan),
            ),
            '/calendar': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.calendar),
            ),
            '/fleet-status': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.fleetStatus),
            ),
            '/tasks': (_) =>
                _wrapSelectable(const AdminShellPage(initialNav: AppNav.tasks)),
            '/shift-absence': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.shiftAbsence),
            ),
            '/incident-reports': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.incidentReports),
            ),
            '/academy': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.academy),
            ),
            '/dispatcher-pill': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.dispatcherPill),
            ),
            '/notifications': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.notifications),
            ),
            '/feedback': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.feedback),
            ),
            '/faqs': (_) =>
                _wrapSelectable(const AdminShellPage(initialNav: AppNav.faqs)),
            '/admin-approvals': (_) => _wrapSelectable(
              const AdminShellPage(initialNav: AppNav.adminApprovals),
            ),

            '/coming-soon': (_) =>
                _wrapSelectable(const _PlaceholderPage(title: 'Coming Soon')),
          },
        );
      },
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
