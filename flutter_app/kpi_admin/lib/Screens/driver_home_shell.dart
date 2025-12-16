// lib/Screens/driver_home_shell.dart
//
// Shell for all driver screens:
// - persistent HeaderBar (good morning + language + bell + avatar)
// - persistent Bottom pill navigation
// - center content switches between tabs (dashboard, onboarding, ...)

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

import '../localization/app_localizations.dart';
import 'driver_onboarding_page.dart';
import 'driver_dashboard_page.dart' show DashboardTabBody;

// same colors as in dashboard
const _kBg = Color(0xFFF3F6F7);
const _kPrimaryGreen = Color(0xFF1D7F5A);

ImageProvider? _profileImageFromUserData({dynamic directBase64}) {
  if (directBase64 == null) return null;
  final base64String = directBase64.toString().trim();
  if (base64String.isEmpty) return null;

  try {
    final bytes = base64Decode(base64String);
    return MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

class DriverHomeShell extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;

  const DriverHomeShell({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
  });

  @override
  State<DriverHomeShell> createState() => _DriverHomeShellState();
}

class _DriverHomeShellState extends State<DriverHomeShell> {
  int _tabIndex = 0; // 0 = dashboard, 2 = onboarding, others later

  /// Use the SAME logic as DriverOnboardingPage._pickAndUploadProfilePhoto
  /// so data is consistent everywhere.
  Future<void> _changeProfilePhoto(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;

    // driverRef where onboarding lives
    final driverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(widget.driverTransporterId.toUpperCase());

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) return;

      final f = result.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.t('snack_could_not_read_image_bytes'))),
        );
        return;
      }

      final base64Thumb = base64Encode(bytes);

      final storage = fb.FirebaseStorage.instance;
      final ref = storage
          .ref()
          .child('driver_profile_photos')
          .child(driverRef.id)
          .child('profile_${DateTime.now().millisecondsSinceEpoch}_${f.name}');

      await ref.putData(bytes);
      final url = await ref.getDownloadURL();

      // 1) store on driver onboarding document
      await driverRef.set(
        {
          'onboarding': {
            'profilePhotoBase64': base64Thumb,
            'profilePhotoUrl': url,
          },
        },
        SetOptions(merge: true),
      );

      // 2) mirror on auth user document
      await FirebaseFirestore.instance.collection('users').doc(authUser.uid).set(
        {
          'profilePhotoBase64': base64Thumb,
          'profilePhotoUrl': url,
          'profilePhotoStorageUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.t('snack_profile_photo_updated'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.tf('snack_failed_upload_profile_photo', {'error': '$e'}),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        body: Center(child: Text(loc.t('error_must_be_logged_in_driver'))),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, accountSnap) {
        final accountData = accountSnap.data?.data() ?? <String, dynamic>{};
        final accountImage = _profileImageFromUserData(
          directBase64: accountData['profilePhotoBase64'],
        );

        final accountName = (accountData['driverName'] ??
                accountData['fullName'] ??
                accountData['displayName'] ??
                'Driver')
            .toString()
            .trim();

        final driverName = accountName.isEmpty ? 'Driver' : accountName;

        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: Column(
              children: [
                // ---------- HEADER (always visible) ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: _HeaderBar(
                    driverName: driverName,
                    profileImage: accountImage,
                    onChangePhoto: () => _changeProfilePhoto(context),
                  ),
                ),

                // ---------- TAB CONTENT ----------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildTabContent(context),
                  ),
                ),
              ],
            ),
          ),

          // ---------- BOTTOM NAV (always visible) ----------
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: _DriverBottomNav(
              index: _tabIndex,
              onTap: (i) => setState(() => _tabIndex = i),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent(BuildContext context) {
    final loc = AppLocalizations.of(context);

    switch (_tabIndex) {
      case 0:
        return DashboardTabBody(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
        );

      case 2:
        final driverRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.dspUid)
            .collection('drivers')
            .doc(widget.driverTransporterId.toUpperCase());
        return DriverOnboardingPage(driverRef: driverRef);

      default:
        return Center(child: Text(loc.t('coming_soon')));
    }
  }
}

// ===================== Header bar (moved from dashboard) =====================

class _HeaderBar extends StatelessWidget {
  final String driverName;
  final ImageProvider? profileImage;
  final Future<void> Function() onChangePhoto;

  const _HeaderBar({
    required this.driverName,
    this.profileImage,
    required this.onChangePhoto,
  });

  // languageCode -> asset path
  String _flagAssetForLang(String code) {
    switch (code) {
      case 'en':
        return 'assets/flags/gb.svg';
      case 'de':
        return 'assets/flags/de.svg';
      case 'sq':
        return 'assets/flags/al.svg';
      case 'hu':
        return 'assets/flags/hu.svg';
      case 'ro':
        return 'assets/flags/ro.svg';
      case 'hr':
        return 'assets/flags/hr.svg';
      case 'ar':
        return 'assets/flags/sy.svg';
      default:
        return 'assets/flags/gb.svg'; // fallback
    }
  }

  // round white icon container (for flag + bell)
  Widget _circleIcon({required Widget child, VoidCallback? onTap}) {
    final content = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );

    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }

  Widget _notificationBubble(VoidCallback onTap) {
    // TODO: wire real count here later
    const int notificationCount = 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _circleIcon(
            child: const Icon(
              Icons.notifications_none,
              size: 22,
              color: Color(0xFF4A4F59),
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: const BoxDecoration(
                  color: Color(0xFFE9741A),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: const Center(
                  child: Text(
                    '3', // placeholder
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _profileChip(VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1E4EA), width: 2),
        ),
        child: CircleAvatar(
          backgroundImage: profileImage,
          backgroundColor: Colors.grey.shade300,
        ),
      ),
    );
  }

  // --- actions --------------------------------------------------------------

  Future<void> _selectLanguage(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    final current = localeController.locale ?? Localizations.localeOf(context);
    final currentCode = current.languageCode;

    final selectedCode = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.t('sheet_select_language'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: AppLocalizations.supportedLocales.length,
                        itemBuilder: (ctx, index) {
                          final l = AppLocalizations.supportedLocales[index];
                          final code = l.languageCode;
                          final isActive = code == currentCode;
                          final asset = _flagAssetForLang(code);

                          return ListTile(
                            leading: SvgPicture.asset(asset, width: 26, height: 20),
                            title: Text(
                              languageLabel(code),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: isActive
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () => Navigator.of(ctx).pop(code),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selectedCode != null && selectedCode != currentCode) {
      localeController.setLocale(Locale(selectedCode));

      // persist on user document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'languageCode': selectedCode,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    }
  }

  Future<void> _openNotifications(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    // TODO: replace with real notifications from Firestore later
    final List<String> notifications = [];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).pop(),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {}, // prevent closing when tapping inside
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    loc.t('sheet_notifications'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          if (notifications.isEmpty)
                            SizedBox(
                              height: 80,
                              child: Center(
                                child: Text(
                                  loc.t('no_notifications'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: notifications.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, i) => ListTile(
                                  title: Text(notifications[i]),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onProfileTap(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).pop(),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {}, // stop closing when tapping inside
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),

                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: profileImage,
                              backgroundColor: Colors.grey.shade300,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driverName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (email.isNotEmpty)
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Change profile photo
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await onChangePhoto();
                            },
                            child: Text(
                              loc.t('profile_change_photo'),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Logout
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context).popUntil((r) => r.isFirst);
                            },
                            child: Text(
                              loc.t('profile_logout'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final currentLocale = localeController.locale ?? Localizations.localeOf(context);
    final langCode = currentLocale.languageCode;
    final flagAsset = _flagAssetForLang(langCode);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.t('header_good_morning'),
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9FA4AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                driverName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF22252F),
                ),
              ),
            ],
          ),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _circleIcon(
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                clipBehavior: Clip.hardEdge,
                child: SvgPicture.asset(
                  flagAsset,
                  fit: BoxFit.cover,
                ),
              ),
              onTap: () => _selectLanguage(context),
            ),
            const SizedBox(width: 10),
            _notificationBubble(() => _openNotifications(context)),
            const SizedBox(width: 10),
            _profileChip(() => _onProfileTap(context)),
          ],
        ),
      ],
    );
  }
}

// ===================== Bottom pill navigation (moved) =====================

class _DriverBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _DriverBottomNav({
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Icon _icon(IconData data, int i) {
      final selected = index == i;
      return Icon(
        data,
        size: 24,
        color: selected ? _kPrimaryGreen : Colors.black54,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(onTap: () => onTap(0), child: _icon(Icons.home_outlined, 0)),
          GestureDetector(onTap: () => onTap(1), child: _icon(Icons.leaderboard_outlined, 1)),
          GestureDetector(onTap: () => onTap(2), child: _icon(Icons.note_add_outlined, 2)),
          GestureDetector(onTap: () => onTap(3), child: _icon(Icons.receipt_long_outlined, 3)),
          GestureDetector(onTap: () => onTap(4), child: _icon(Icons.person_outline, 4)),
        ],
      ),
    );
  }
}
