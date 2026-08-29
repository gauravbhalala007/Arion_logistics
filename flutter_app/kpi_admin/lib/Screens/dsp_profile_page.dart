// lib/screens/dsp_profile_page.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/account_switcher.dart';

/// MIME-Type für Bild-Uploads aus der Dateiendung. Ohne expliziten
/// contentType lädt Flutter Web als application/octet-stream hoch und
/// die Storage-Rule isImage() lehnt den Upload ab.
String _imageContentType(String extOrName) {
  final ext = extOrName.contains('.')
      ? extOrName.split('.').last.toLowerCase()
      : extOrName.toLowerCase();
  switch (ext) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    case 'heic':
    case 'heif':
      return 'image/heic';
    default:
      return 'image/jpeg';
  }
}

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

  // ── Firmendaten (editable company data) ──
  final _companyNameCtrl = TextEditingController();
  final _companyAddressCtrl = TextEditingController();
  final _companyPhoneCtrl = TextEditingController();

  /// Datenschutz-Kontakt (Fahrer-App → Datenschutz-Center). Leer =
  /// Standard: die Login-E-Mail des Admin-Kontos.
  final _privacyEmailCtrl = TextEditingController();

  bool _companySeeded = false;
  bool _savingCompany = false;

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _companyAddressCtrl.dispose();
    _companyPhoneCtrl.dispose();
    _privacyEmailCtrl.dispose();
    super.dispose();
  }

  /// Seed the company controllers ONCE from the live profile snapshot so
  /// typing isn't overwritten by stream ticks.
  void _seedCompany(Map<String, dynamic> profile) {
    if (_companySeeded) return;
    _companySeeded = true;
    _companyNameCtrl.text =
        (profile['companyName'] ?? profile['dspName'] ?? '').toString();
    _companyAddressCtrl.text = (profile['companyAddress'] ?? '').toString();
    _companyPhoneCtrl.text = (profile['companyPhone'] ?? '').toString();
    _privacyEmailCtrl.text = (profile['privacyContactEmail'] ?? '').toString();
  }

  Future<void> _saveCompany() async {
    final uid = _uid;
    if (uid == null || _savingCompany) return;
    final de = Localizations.localeOf(context).languageCode == 'de';
    setState(() => _savingCompany = true);
    try {
      // Effektiver Datenschutz-Kontakt: Eingabe, sonst Admin-Login-E-Mail.
      final privacyEmail = _privacyEmailCtrl.text.trim().isNotEmpty
          ? _privacyEmailCtrl.text.trim()
          : (_user?.email ?? '').trim();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'companyName': _companyNameCtrl.text.trim(),
        'companyAddress': _companyAddressCtrl.text.trim(),
        'companyPhone': _companyPhoneCtrl.text.trim(),
        // Leer = Standard (Admin-Login-E-Mail) — dann Feld entfernen,
        // damit das Profil-Formular den Default als Hint zeigt.
        'privacyContactEmail': _privacyEmailCtrl.text.trim().isEmpty
            ? FieldValue.delete()
            : _privacyEmailCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Fahrer dürfen das Admin-Hauptdokument NICHT lesen — der Kontakt
      // wird deshalb zusätzlich in das fahrer-lesbare Settings-Doc
      // gespiegelt (users/{uid}/settings/privacy_contact).
      if (privacyEmail.contains('@')) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('privacy_contact')
            .set({
          'email': privacyEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Firmendaten gespeichert.' : 'Company details saved.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Speichern fehlgeschlagen: $e' : 'Saving failed: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingCompany = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    if (_uid == null) return;

    final de = Localizations.localeOf(context).languageCode == 'de';
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

      // contentType MUSS gesetzt sein — sonst blockt die isImage()-Rule.
      await ref.putData(
        bytes,
        fb.SettableMetadata(contentType: _imageContentType(ext ?? 'jpg')),
      );
      final downloadUrl = await ref.getDownloadURL();

      // Base64 for fast inline avatar
      final base64String = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('users').doc(_uid!).set({
        'profilePhotoBase64': base64String,
        'profilePhotoStorageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Profilfoto aktualisiert.' : 'Profile photo updated.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de
                ? 'Foto konnte nicht aktualisiert werden: $e'
                : 'Failed to update photo: $e',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    if (_uid == null) {
      return Center(
        child: Text(
          de
              ? 'Bitte melde dich an, um dein Profil zu sehen.'
              : 'You must be logged in to view your profile.',
        ),
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
        _seedCompany(profile);
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          color: _kPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          de ? 'Profilseite' : 'Profile Page',
                          style: const TextStyle(
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
                                        value == 'de'
                                            ? 'Sprache geändert zu ${languageLabel(value)}'
                                            : 'Language changed to ${languageLabel(value)}',
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
                    const SizedBox(height: 16),
                    // ── Firmendaten ──
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.business_rounded,
                                  color: _kPrimary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                de ? 'Firmendaten' : 'Company details',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _kTitle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            de
                                ? 'Der Firmenname erscheint u. a. oben in der '
                                      'Menüleiste und auf geteilten Plänen.'
                                : 'The company name appears in the top menu '
                                      'bar and on shared plans.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: _kSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _companyField(
                            controller: _companyNameCtrl,
                            label: de ? 'Firmenname' : 'Company name',
                            hint: de
                                ? 'z. B. Arion Logistics GmbH'
                                : 'e.g. Arion Logistics GmbH',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),
                          _companyField(
                            controller: _companyAddressCtrl,
                            label: de ? 'Adresse' : 'Address',
                            hint: de
                                ? 'Straße Nr., PLZ Ort'
                                : 'Street No., ZIP City',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),
                          _companyField(
                            controller: _companyPhoneCtrl,
                            label: de ? 'Telefon' : 'Phone',
                            hint: '+49 …',
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 12),
                          _companyField(
                            controller: _privacyEmailCtrl,
                            label: de
                                ? 'Datenschutz-Kontakt (E-Mail)'
                                : 'Privacy contact (email)',
                            hint: _user?.email ??
                                (de ? 'Standard: Admin-E-Mail' : 'Default: admin email'),
                            icon: Icons.privacy_tip_outlined,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            de
                                ? 'Wird Fahrern im Datenschutz-Bereich als '
                                      'Kontakt für Auskunft/Berichtigung/'
                                      'Löschung angezeigt. Leer = Admin-E-Mail.'
                                : 'Shown to drivers in the data protection '
                                      'section as the contact for access/'
                                      'rectification/erasure. Empty = admin '
                                      'email.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: _kSub,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _savingCompany ? null : _saveCompany,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _savingCompany
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined,
                                      size: 18),
                              label: Text(de ? 'Speichern' : 'Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Stationen ──
                    _stationsCard(context, profile, isNarrow),
                    const SizedBox(height: 16),
                    // ── Weitere Station-Konten (Account-Switcher) ──
                    _linkedAccountsCard(context, isNarrow),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addLinkedAccount(BuildContext context) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final labelCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          de ? 'Station-Konto hinzufügen' : 'Add station account',
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: InputDecoration(
                  labelText: de
                      ? 'Bezeichnung (z. B. Station DBY5)'
                      : 'Label (e.g. Station DBY5)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: de ? 'E-Mail' : 'Email',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: de ? 'Passwort' : 'Password',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                de
                    ? 'Die Zugangsdaten werden nur lokal in diesem Browser '
                          'gespeichert (nicht auf dem Server).'
                    : 'Credentials are stored only locally in this browser '
                          '(not on the server).',
                style: const TextStyle(fontSize: 11.5, color: _kSub),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(de ? 'Abbrechen' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(de ? 'Speichern' : 'Save'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;
    if (email.isEmpty || pass.isEmpty) return;
    AccountSwitcher.add(LinkedAccount(
      label: labelCtrl.text.trim().isEmpty ? email : labelCtrl.text.trim(),
      email: email,
      password: pass,
    ));
    if (mounted) setState(() {});
  }

  Future<void> _switchToLinked(
      BuildContext context, LinkedAccount a) async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
    try {
      await AccountSwitcher.switchTo(a);
      // On success the AuthGate rebuilds into the other account.
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            de ? 'Wechsel fehlgeschlagen: $e' : 'Switching failed: $e',
          ),
        ),
      );
    }
  }

  /// Account-Switcher: manage secondary station logins (stored locally) and
  /// switch to them without a manual logout.
  Widget _linkedAccountsCard(BuildContext context, bool isNarrow) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final accounts = AccountSwitcher.load();
    final currentEmail =
        (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase();
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.swap_horiz_rounded, color: _kPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
                de
                    ? 'Station wechseln (weitere Konten)'
                    : 'Switch station (further accounts)',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kTitle)),
          ]),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Betreibst du mehrere Stationen mit getrennten Logins? Hinterlege '
                      'die weiteren Zugänge hier und wechsle per Klick — ohne dich '
                      'jedes Mal aus- und wieder einzuloggen.'
                : 'Running several stations with separate logins? Save the other '
                      'accounts here and switch with one click — without logging '
                      'out and in every time.',
            style: const TextStyle(
                fontSize: 12.5, color: _kSub, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          if (accounts.isEmpty)
            Text(
                de
                    ? 'Noch kein weiteres Konto hinterlegt.'
                    : 'No further account saved yet.',
                style: const TextStyle(color: _kSub))
          else
            ...accounts.map((a) {
              final isCurrent = a.email.toLowerCase() == currentEmail;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kCardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _kTitle)),
                          Text(a.email,
                              style: const TextStyle(
                                  fontSize: 12, color: _kSub)),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(de ? 'aktiv' : 'active',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _kPrimary)),
                      )
                    else
                      TextButton.icon(
                        onPressed: () => _switchToLinked(context, a),
                        icon: const Icon(Icons.login_rounded, size: 16),
                        label: Text(de ? 'Wechseln' : 'Switch'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 20, color: Color(0xFFB42318)),
                      tooltip: de ? 'Entfernen' : 'Remove',
                      onPressed: () {
                        AccountSwitcher.remove(a.email);
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addLinkedAccount(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(de ? 'Konto hinzufügen' : 'Add account'),
            ),
          ),
        ],
      ),
    );
  }

  /// Stations management: list station codes, set the active one, add/remove.
  /// Uses the same `users/{uid}.stationCodes` + `activeStationCode` fields as
  /// the top-bar station switcher.
  Widget _stationsCard(
      BuildContext context, Map<String, dynamic> profile, bool isNarrow) {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final raw = profile['stationCodes'];
    final stations = <String>[
      if (raw is List)
        for (final e in raw)
          if (e.toString().trim().isNotEmpty)
            e.toString().trim().toUpperCase(),
    ];
    final active =
        (profile['activeStationCode'] ?? '').toString().trim().toUpperCase();
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(_uid);

    Future<void> addStation() async {
      final ctrl = TextEditingController();
      final code = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(de ? 'Station hinzufügen' : 'Add station'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: de ? 'Stationscode' : 'Station code',
              hintText: de ? 'z. B. DBY5' : 'e.g. DBY5',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(de ? 'Abbrechen' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: Text(de ? 'Hinzufügen' : 'Add'),
            ),
          ],
        ),
      );
      final normalized = (code ?? '').trim().toUpperCase();
      if (normalized.isEmpty) return;
      await userRef.set({
        'stationCodes': FieldValue.arrayUnion([normalized]),
        if (active.isEmpty) 'activeStationCode': normalized,
      }, SetOptions(merge: true));
    }

    Future<void> removeStation(String code) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(de ? 'Station entfernen?' : 'Remove station?'),
          content: Text(de
              ? '„$code" wird aus deinen Stationen entfernt.'
              : '"$code" will be removed from your stations.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(de ? 'Abbrechen' : 'Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB42318)),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(de ? 'Entfernen' : 'Remove'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      final remaining = stations.where((s) => s != code).toList();
      await userRef.set({
        'stationCodes': FieldValue.arrayRemove([code]),
        if (active == code)
          'activeStationCode': remaining.isNotEmpty ? remaining.first : '',
      }, SetOptions(merge: true));
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_city_rounded, color: _kPrimary, size: 20),
            const SizedBox(width: 8),
            Text(de ? 'Stationen' : 'Stations',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kTitle)),
          ]),
          const SizedBox(height: 6),
          Text(
            de
                ? 'Verwalte deine Stationen. Die aktive Station bestimmt, welche '
                      'Daten oben in der Menüleiste angezeigt werden.'
                : 'Manage your stations. The active station determines which '
                      'data is shown in the top menu bar.',
            style: const TextStyle(
                fontSize: 12.5, color: _kSub, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          if (stations.isEmpty)
            Text(de ? 'Noch keine Station angelegt.' : 'No station added yet.',
                style: const TextStyle(color: _kSub))
          else
            ...stations.map((s) {
              final isActive =
                  s == active || (active.isEmpty && s == stations.first);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? _kPrimary.withValues(alpha: 0.06)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: isActive ? _kPrimary : _kCardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: isActive
                            ? null
                            : () => userRef.set({'activeStationCode': s},
                                SetOptions(merge: true)),
                        child: Row(children: [
                          Icon(
                              isActive
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 18,
                              color: isActive
                                  ? _kPrimary
                                  : const Color(0xFF9CA3AF)),
                          const SizedBox(width: 10),
                          Text(s,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _kTitle)),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Text(de ? 'aktiv' : 'active',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _kPrimary)),
                          ],
                        ]),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 20, color: Color(0xFFB42318)),
                      tooltip: de ? 'Entfernen' : 'Remove',
                      onPressed: () => removeStation(s),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: addStation,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(de ? 'Station hinzufügen' : 'Add station'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _companyField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: _kSub),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.4),
        ),
      ),
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
