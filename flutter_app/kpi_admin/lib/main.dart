import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
import 'screens/scorecard_overview.dart';

/// Toggle this to false for production.
const bool useEmulators = true;

/// Global Storage instance bound to the correct bucket (and emulator in dev).
late final FirebaseStorage storage;

Future<void> _connectToEmulators() async {
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  await storage.useStorageEmulator('127.0.0.1', 9199);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Normalize bucket for Apple platforms.
  String? bucket = DefaultFirebaseOptions.currentPlatform.storageBucket;
  if (bucket == null ||
      bucket.isEmpty ||
      bucket.endsWith('firebasestorage.app')) {
    final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
    bucket = '$projectId.appspot.com';
  }
  storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');

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
      // home: const ScoreboardPage(),
      home: const ScorecardOverviewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
