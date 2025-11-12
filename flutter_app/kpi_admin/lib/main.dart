import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';

import 'widgets/auth_gate.dart';
import 'Screens/login_page.dart';
import 'Screens/scorecard_overview.dart';
import 'Screens/signup_page.dart';
import 'Screens/verify_email_page.dart';
import 'Screens/admin_approvals_page.dart';

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

  // TEMP logs
  // ignore: avoid_print
  print('🔧 projectId: ${Firebase.app().options.projectId}');
  // ignore: avoid_print
  print('🔧 storageBucket (from options): ${DefaultFirebaseOptions.currentPlatform.storageBucket}');

  final bucket = DefaultFirebaseOptions.currentPlatform.storageBucket!;
  storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');

  // ignore: avoid_print
  print('🔧 storage.bucket runtime: ${storage.bucket}');

  // if (useEmulators) {
  //   await _connectToEmulators();
  // }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSP Copilot',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
        fontFamily: 'SF Pro',
        scaffoldBackgroundColor: const Color(0xFFF6F7F5),
      ),
      debugShowCheckedModeBanner: false,

      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignupPage(),
        '/verify-email': (_) => const VerifyEmailPage(),
        '/dashboard': (_) => const ScorecardOverviewPage(),
        '/drivers': (_) => const _PlaceholderPage(title: 'Drivers Hub (Coming Soon)'),
        '/coming-soon': (_) => const _PlaceholderPage(title: 'Coming Soon'),
        '/admin-approvals': (_) => const AdminApprovalsPage(),
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
