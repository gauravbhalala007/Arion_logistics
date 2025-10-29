import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Use the storage instance bound to bucket+emulator from main.dart
import '../main.dart' show storage;

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _busy = false;
  String? _msg;

  Future<void> _upload({required bool isCsv}) async {
    setState(() {
      _busy = true;
      _msg = null;
    });

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: isCsv ? ['csv'] : ['pdf'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) {
        setState(() {
          _busy = false;
          _msg = 'Upload cancelled.';
        });
        return;
      }

      final f = res.files.single;
      final Uint8List? bytes = f.bytes;
      if (bytes == null) {
        throw Exception('No bytes in picked file.');
      }

      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final path = isCsv
          ? 'uploads/drivers/$date/${f.name}'
          : 'uploads/reports/$date/${f.name}';

      final meta = SettableMetadata(
        contentType: isCsv ? 'text/csv' : 'application/pdf',
      );

      final ref = storage.ref().child(path);
      final task = await ref.putData(bytes, meta);
      final metaOut = await task.ref.getMetadata();

      final kb = ((metaOut.size ?? 0) / 1024).toStringAsFixed(1);
      setState(() {
        _msg = 'Uploaded ${metaOut.fullPath} ($kb KB)';
      });
    } catch (e) {
      setState(() {
        _msg = 'Upload failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _testWrite() async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    try {
      final ref = storage.ref('uploads/test/hello.txt');
      await ref.putData(
        Uint8List.fromList('hello'.codeUnits),
        SettableMetadata(contentType: 'text/plain'),
      );
      final m = await ref.getMetadata();
      setState(() => _msg = 'Wrote ${m.fullPath} (${m.size} bytes)');
    } catch (e) {
      setState(() => _msg = 'Test write failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : () => _upload(isCsv: true),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Drivers CSV'),
              ),
              FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _upload(isCsv: false),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Upload Weekly PDF'),
              ),
              FilledButton.tonal(
                onPressed: _busy ? null : _testWrite,
                child: const Text('Test write'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          if (_msg != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _msg!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'CSV → uploads/drivers/YYYY-MM-DD/file.csv\n'
            'PDF → uploads/reports/YYYY-MM-DD/file.pdf\n'
            'Both trigger backend processing automatically.',
          ),
        ],
      ),
    );
  }
}
