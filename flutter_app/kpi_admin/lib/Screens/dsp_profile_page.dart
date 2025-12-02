// lib/screens/dsp_profile_page.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class DspProfilePage extends StatefulWidget {
  const DspProfilePage({super.key});

  @override
  State<DspProfilePage> createState() => _DspProfilePageState();
}

class _DspProfilePageState extends State<DspProfilePage> {
  final _auth = FirebaseAuth.instance;
  bool _uploading = false;

  User? get _user => _auth.currentUser;
  String? get _uid => _user?.uid;

  // Keep a local selected language code (e.g. 'en', 'de', ...)
  String _languageCode = 'en';

  Future<void> _pickAndUploadPhoto() async {
    if (_uid == null) return;

    setState(() => _uploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _uploading = false);
        return;
      }

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        setState(() => _uploading = false);
        return;
      }

      // Upload to Firebase Storage (backup / larger original)
      final storage = fb.FirebaseStorage.instance;
      final ext = (f.extension != null && f.extension!.isNotEmpty)
          ? f.extension
          : 'jpg';
      final ref = storage
          .ref()
          .child('user_profile_photos')
          .child(_uid!)
          .child('profile_${DateTime.now().millisecondsSinceEpoch}.$ext');

      await ref.putData(bytes);
      final downloadUrl = await ref.getDownloadURL();

      // Base64 for fast inline avatar
      final base64String = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('users').doc(_uid!).set(
        {
          'profilePhotoBase64': base64String,
          'profilePhotoStorageUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to view your profile.')),
      );
    }

    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('profileTitle')),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid!)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snap.data?.data() ?? {};

          // Try to get company / DSP name
          final firstName = (profile['firstName'] ?? '').toString().trim();
          final lastName = (profile['lastName'] ?? '').toString().trim();
          final fullName =
              [firstName, lastName].where((e) => e.isNotEmpty).join(' ').trim();

          final companyName =
              (profile['companyName'] ?? profile['dspName'] ?? '')
                  .toString()
                  .trim();

          final displayName = companyName.isNotEmpty
              ? companyName
              : (fullName.isNotEmpty
                  ? fullName
                  : (_user?.displayName ?? 'Your profile'));

          final email = _user?.email ?? (profile['email'] ?? '—').toString();

          // Avatar bytes from base64
          Uint8List? avatarBytes;
          final b64 = (profile['profilePhotoBase64'] ?? '').toString().trim();
          if (b64.isNotEmpty) {
            try {
              avatarBytes = base64Decode(b64);
            } catch (_) {}
          }

          // Load stored languageCode from Firestore if available
          final storedLang =
              (profile['languageCode'] ?? '').toString().toLowerCase();
          final supportedCodes =
              AppLocalizations.supportedLocales.map((e) => e.languageCode).toSet();

          String effectiveLangCode = _languageCode;
          if (storedLang.isNotEmpty && supportedCodes.contains(storedLang)) {
            effectiveLangCode = storedLang;
          } else if (!supportedCodes.contains(effectiveLangCode)) {
            effectiveLangCode = 'en';
          }
          _languageCode = effectiveLangCode; // keep field in sync

          String _initials(String name) {
            final parts =
                name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
            final list = parts.take(2).toList();
            if (list.isEmpty) return '?';
            if (list.length == 1) {
              return list.first.characters.first.toUpperCase();
            }
            return (list[0].characters.first + list[1].characters.first)
                .toUpperCase();
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFFE5E7EB),
                          backgroundImage: avatarBytes != null
                              ? MemoryImage(avatarBytes)
                              : null,
                          child: avatarBytes == null
                              ? Text(
                                  _initials(displayName),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 🔤 Language selector
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            loc.t('language'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _languageCode,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: AppLocalizations.supportedLocales
                              .map(
                                (locale) => DropdownMenuItem<String>(
                                  value: locale.languageCode,
                                  child: Text(
                                    languageLabel(locale.languageCode),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) async {
                            if (value == null) return;
                            setState(() {
                              _languageCode = value;
                            });

                            // Save preference in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_uid!)
                                .set(
                              {
                                'languageCode': value,
                                'updatedAt': FieldValue.serverTimestamp(),
                              },
                              SetOptions(merge: true),
                            );

                            // Update global app locale → entire app updates
                            localeController.setLocale(Locale(value));

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Language changed to ${languageLabel(value)}'),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Change profile photo button
                        SizedBox(
                          width: 220,
                          child: ElevatedButton.icon(
                            onPressed: _uploading ? null : _pickAndUploadPhoto,
                            icon: _uploading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.camera_alt_outlined, size: 18),
                            label: Text(
                              _uploading
                                  ? 'Uploading...'
                                  : loc.t('changePhoto'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.t('profilePhotoHint'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
