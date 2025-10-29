import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_options.dart';
import 'screens/upload_screen.dart';
import 'screens/dashboard_screen.dart';

/// Toggle this to false when you switch to your production backend.
const bool useEmulators = true;

/// Global Storage instance bound to the correct bucket (and emulator in dev).
late final FirebaseStorage storage;

Future<void> _connectToEmulators() async {
  // Firestore emulator
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  // Storage emulator (binds to the global `storage` we create below)
  await storage.useStorageEmulator('127.0.0.1', 9199);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Derive the GS bucket from firebase_options. On Apple platforms the value
  // can be "*.firebasestorage.app"; normalize to "<project>.appspot.com".
  String? bucket = DefaultFirebaseOptions.currentPlatform.storageBucket;
  if (bucket == null ||
      bucket.isEmpty ||
      bucket.endsWith('firebasestorage.app')) {
    final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
    bucket = '$projectId.appspot.com';
  }

  // Bind a Storage instance specifically to this bucket.
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
      ),
      home: const _Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _Home extends StatefulWidget {
  const _Home({super.key});
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _idx = 0;

  final _pages = const [
    DashboardScreen(),
    UploadScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_idx == 0 ? 'Scorecard Dashboard' : 'Uploads')),
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.upload_file_outlined), label: 'Uploads'),
        ],
        onDestinationSelected: (i) => setState(() => _idx = i),
      ),
    );
  }
}
