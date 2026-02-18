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
  static const _kPageBg = Color(0xFFF3F6F7);
  static const _kCardBorder = Color(0xFFE1E4EA);
  static const _kTitle = Color(0xFF1F2937);
  static const _kSub = Color(0xFF6B7280);
  static const _kPrimary = Color(0xFF1D7F5A);

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

      await FirebaseFirestore.instance.collection('users').doc(_uid!).set({
        'profilePhotoBase64': base64String,
        'profilePhotoStorageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update photo: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(
        child: Text('You must be logged in to view your profile.'),
      );
    }

    final loc = AppLocalizations.of(context);
    final isNarrow = MediaQuery.of(context).size.width < 1100;
    final horizontalPadding = isNarrow ? 14.0 : 28.0;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_uid!)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snap.data?.data() ?? {};
        final firstName = (profile['firstName'] ?? '').toString().trim();
        final lastName = (profile['lastName'] ?? '').toString().trim();
        final fullName = [
          firstName,
          lastName,
        ].where((e) => e.isNotEmpty).join(' ').trim();
        final companyName = (profile['companyName'] ?? profile['dspName'] ?? '')
            .toString()
            .trim();
        final displayName = companyName.isNotEmpty
            ? companyName
            : (fullName.isNotEmpty
                  ? fullName
                  : (_user?.displayName ?? 'Profile'));
        final email = _user?.email ?? (profile['email'] ?? '—').toString();

        Uint8List? avatarBytes;
        final b64 = (profile['profilePhotoBase64'] ?? '').toString().trim();
        if (b64.isNotEmpty) {
          try {
            avatarBytes = base64Decode(b64);
          } catch (_) {}
        }

        final storedLang = (profile['languageCode'] ?? '')
            .toString()
            .toLowerCase();
        final supportedCodes = AppLocalizations.supportedLocales
            .map((e) => e.languageCode)
            .toSet();
        String effectiveLangCode = _languageCode;
        if (storedLang.isNotEmpty && supportedCodes.contains(storedLang)) {
          effectiveLangCode = storedLang;
        } else if (!supportedCodes.contains(effectiveLangCode)) {
          effectiveLangCode = 'en';
        }
        _languageCode = effectiveLangCode;

        String initials(String name) {
          final parts = name
              .trim()
              .split(RegExp(r'\s+'))
              .where((p) => p.isNotEmpty);
          final list = parts.take(2).toList();
          if (list.isEmpty) return '?';
          if (list.length == 1) {
            return list.first.characters.first.toUpperCase();
          }
          return (list[0].characters.first + list[1].characters.first)
              .toUpperCase();
        }

        return Container(
          color: _kPageBg,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person_outline, color: _kPrimary, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Profile Page',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: _kTitle,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isNarrow ? 16 : 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _kCardBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140B1220),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final stack = constraints.maxWidth < 560;
                          final profileInfo = stack
                              ? Column(
                                  children: [
                                    _avatar(avatarBytes, initials(displayName)),
                                    const SizedBox(height: 12),
                                    Text(
                                      displayName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: _kTitle,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _kSub,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _photoButton(loc),
                                  ],
                                )
                              : Row(
                                  children: [
                                    _avatar(avatarBytes, initials(displayName)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: _kTitle,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            email,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: _kSub,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _photoButton(loc),
                                  ],
                                );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              profileInfo,
                              const SizedBox(height: 18),
                              const Divider(height: 1, color: _kCardBorder),
                              const SizedBox(height: 16),
                              Text(
                                loc.t('select_language'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _kSub,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                key: ValueKey(_languageCode),
                                initialValue: _languageCode,
                                icon: const Icon(Icons.expand_more_rounded),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFB),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.language_rounded,
                                    color: _kPrimary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _kCardBorder,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _kCardBorder,
                                    ),
                                  ),
                                ),
                                items: AppLocalizations.supportedLocales
                                    .map(
                                      (locale) => DropdownMenuItem<String>(
                                        value: locale.languageCode,
                                        child: Text(
                                          languageLabel(locale.languageCode),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) async {
                                  if (value == null) return;
                                  setState(() => _languageCode = value);
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_uid!)
                                      .set({
                                        'languageCode': value,
                                        'updatedAt':
                                            FieldValue.serverTimestamp(),
                                      }, SetOptions(merge: true));

                                  localeController.setLocale(Locale(value));
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Language changed to ${languageLabel(value)}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _avatar(Uint8List? avatarBytes, String fallback) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kCardBorder),
      ),
      child: CircleAvatar(
        radius: 44,
        backgroundColor: const Color(0xFFE5E7EB),
        backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes) : null,
        child: avatarBytes == null
            ? Text(
                fallback,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              )
            : null,
      ),
    );
  }

  Widget _photoButton(AppLocalizations loc) {
    return ElevatedButton.icon(
      onPressed: _uploading ? null : _pickAndUploadPhoto,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF9CA3AF),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: _uploading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.camera_alt_outlined, size: 18),
      label: Text(
        _uploading ? loc.t('uploading') : loc.t('change_profile_photo'),
      ),
    );
  }
}
