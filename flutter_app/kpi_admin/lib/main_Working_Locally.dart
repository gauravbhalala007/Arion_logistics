import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
import 'screens/scorecard_overview.dart';

/// Use emulators only in debug/profile, never in release.
bool get useEmulators => !kReleaseMode;

/// Global Storage instance bound to the bucket from firebase_options.dart.
late final FirebaseStorage storage;

Future<void> _connectToEmulators() async {
  // Firestore emulator
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  // Storage emulator
  await storage.useStorageEmulator('127.0.0.1', 9199);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


    // 🔎 TEMP LOGS — leave these for one deploy
  // ignore: avoid_print
  print('🔧 projectId: ${Firebase.app().options.projectId}');
  // ignore: avoid_print
  print('🔧 storageBucket (from options): ${DefaultFirebaseOptions.currentPlatform.storageBucket}');


  // IMPORTANT: use the bucket from firebase_options.dart as-is.
  // Do NOT “normalize” to appspot.com — your project uses firebasestorage.app.
  final bucket = DefaultFirebaseOptions.currentPlatform.storageBucket!;
  storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');

    // ignore: avoid_print
  print('🔧 storage.bucket runtime: ${storage.bucket}');



  if (useEmulators) {
    await _connectToEmulators();
  }

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
      home: const ScorecardOverviewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
