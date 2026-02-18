// lib/Screens/driver_home_shell.dart
//
// Shell for all driver screens:
// - persistent HeaderBar (good morning + language + bell + avatar)
// - persistent Bottom pill navigation
// - center content switches between tabs (dashboard, onboarding, ...)

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;

import '../localization/app_localizations.dart';
import '../models/driver_notification.dart';
import 'driver_academy_page.dart';
import 'driver_green_book_page.dart';
import 'driver_onboarding_page.dart';
import 'driver_dashboard_page.dart' show DashboardTabBody;
import 'driver_home_page.dart';
import 'driver_notification_detail_view.dart';
import 'driver_notifications_view.dart';
import 'driver_rules_view.dart';
import 'driver_tasks_view.dart';

import '../widgets/notification_pin_dialogs.dart';
import 'driver_profile_page.dart';
import 'driver_faq_page.dart';

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

// ✅ internal single-page views
enum DriverView {
  home,
  academy,
  greenBook,
  comingSoon,
  dashboard,
  faq,
  onboarding,
  tasks,
  notifications,
  rules,
  notificationDetail,
  profile,
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
  int _tabIndex = 0; // 0 = home

  DriverView _view = DriverView.home;
  DriverNotification? _selectedNotification;
  int _unreadCount = 0;
  int _pendingTasksCount = 0;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notifSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSub;

  CollectionReference<Map<String, dynamic>> _driverNotifsCol() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('drivers')
        .doc(widget.driverTransporterId.toUpperCase())
        .collection('notifications');
  }

  CollectionReference<Map<String, dynamic>> _tasksCol() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid)
        .collection('tasks');
  }

  bool _pinPromptShown = false;

  @override
  void initState() {
    super.initState();
    _startCountSubscriptions();
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _tasksSub?.cancel();
    super.dispose();
  }

  void _startCountSubscriptions() {
    _notifSub = _driverNotifsCol().snapshots().listen((snap) {
      final notifications = snap.docs.map(DriverNotification.fromDoc).toList();
      final unreadCount = notifications
          .where((n) => n.requiresConfirmation && !n.confirmed)
          .length;

      if (!mounted) return;
      setState(() {
        _unreadCount = unreadCount;
      });
    }, onError: (_) {});

    _tasksSub = _tasksCol()
        .where(
          'assignedTransporterId',
          isEqualTo: widget.driverTransporterId.toUpperCase(),
        )
        .snapshots()
        .listen((snap) {
          final pendingTasksCount = snap.docs.where((d) {
            final status = (d.data()['status'] ?? 'pending')
                .toString()
                .trim()
                .toLowerCase();
            return status == 'pending' || status == 'in_progress';
          }).length;

          if (!mounted) return;
          setState(() {
            _pendingTasksCount = pendingTasksCount;
          });
        }, onError: (_) {});
  }

  Future<void> _ensurePinOnLogin() async {
    if (_pinPromptShown) return;
    _pinPromptShown = true;

    try {
      final pin = await NotificationPinService.getPin(
        dspUid: widget.dspUid,
        transporterId: widget.driverTransporterId.toUpperCase(),
      );

      if (!mounted) return;

      if (pin == null) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => SetNotificationPinDialog(
            dspUid: widget.dspUid,
            transporterId: widget.driverTransporterId.toUpperCase(),
            force: true,
          ),
        );
      }
    } catch (_) {
      // silent fail; we don't want to block login if Firestore fails
    }
  }

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
      await driverRef.set({
        'onboarding': {
          'profilePhotoBase64': base64Thumb,
          'profilePhotoUrl': url,
        },
      }, SetOptions(merge: true));

      // 2) mirror on auth user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .set({
            'profilePhotoBase64': base64Thumb,
            'profilePhotoUrl': url,
            'profilePhotoStorageUrl': url,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensurePinOnLogin();
    });

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, accountSnap) {
        final accountData = accountSnap.data?.data() ?? <String, dynamic>{};
        final accountImage = _profileImageFromUserData(
          directBase64: accountData['profilePhotoBase64'],
        );

        final accountName =
            (accountData['driverName'] ??
                    accountData['fullName'] ??
                    accountData['displayName'] ??
                    'Driver')
                .toString()
                .trim();

        final driverName = accountName.isEmpty ? 'Driver' : accountName;

        return Scaffold(
          backgroundColor: _kBg,
          extendBody: true,
          body: SafeArea(
            child: Column(
              children: [
                // ---------- HEADER (always visible) ----------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: _HeaderBar(
                    driverName: driverName,
                    profileImage: accountImage,
                    unreadCount: _unreadCount,
                    onChangePhoto: () => _changeProfilePhoto(context),
                    onOpenProfile: () {
                      setState(() {
                        _view = DriverView.profile;
                        _tabIndex = 0;
                      });
                    },
                    onOpenNotifications: () {
                      setState(() {
                        _view = DriverView.notifications;
                        _tabIndex = 0;
                      });
                    },
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
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              child: _DriverBottomNav(
                index: _tabIndex,
                pendingTasksCount: _pendingTasksCount,
                onTap: (i) {
                  setState(() {
                    _tabIndex = i;

                    if (i == 0) {
                      _view = DriverView.home;
                    } else if (i == 1) {
                      _view = DriverView.dashboard;
                    } else if (i == 2) {
                      _view = DriverView.faq;
                    } else if (i == 3) {
                      _view = DriverView.tasks;
                    } else if (i == 4) {
                      _view = DriverView.rules;
                    }
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent(BuildContext context) {
    final loc = AppLocalizations.of(context);

    switch (_view) {
      case DriverView.home:
        return DriverHomePage(
          pendingTasksCount: _pendingTasksCount,
          onOpenScorecard: () {
            setState(() {
              _tabIndex = 1;
              _view = DriverView.dashboard;
            });
          },
          onOpenAcademy: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.academy;
            });
          },
          onOpenTasks: () {
            setState(() {
              _tabIndex = 3;
              _view = DriverView.tasks;
            });
          },
          onOpenRules: () {
            setState(() {
              _tabIndex = 4;
              _view = DriverView.rules;
            });
          },
          onOpenComingSoon: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.comingSoon;
            });
          },
        );

      case DriverView.academy:
        return DriverAcademyPage(
          onBack: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.home;
            });
          },
          onOpenGreenBook: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.greenBook;
            });
          },
          onOpenSafetyTraining: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.comingSoon;
            });
          },
          onOpenAmazonDelivery: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.comingSoon;
            });
          },
          onOpenCoDriverApp: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.comingSoon;
            });
          },
        );

      case DriverView.greenBook:
        return DriverGreenBookPage(
          dspUid: widget.dspUid,
          onBack: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.academy;
            });
          },
          onStartTest: () {
            setState(() {
              _tabIndex = 0;
              _view = DriverView.comingSoon;
            });
          },
        );

      case DriverView.comingSoon:
        return Center(
          child: Text(
            loc.t('coming_soon'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        );

      case DriverView.dashboard:
        return DashboardTabBody(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
        );

      case DriverView.faq:
        return DriverFaqPage(dspUid: widget.dspUid);

      case DriverView.onboarding:
        final driverRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.dspUid)
            .collection('drivers')
            .doc(widget.driverTransporterId.toUpperCase());
        return DriverOnboardingPage(driverRef: driverRef);

      case DriverView.tasks:
        return DriverTasksView(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
        );

      case DriverView.notifications:
        return DriverNotificationsView(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
          onOpen: (n) {
            setState(() {
              _selectedNotification = n;
              _view = DriverView.notificationDetail;
            });
          },
        );

      case DriverView.rules:
        return DriverRulesView(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
          onOpen: (n) {
            setState(() {
              _selectedNotification = n;
              _view = DriverView.notificationDetail;
            });
          },
        );

      case DriverView.profile:
        return DriverProfilePage(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
        );

      case DriverView.notificationDetail:
        if (_selectedNotification == null) {
          return Center(child: Text(loc.t('coming_soon')));
        }
        return DriverNotificationDetailView(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
          notification: _selectedNotification!,
          onBack: () {
            setState(() {
              _view = DriverView.notifications;
            });
          },
        );
    }
  }
}

// ===================== Header bar (moved from dashboard) =====================

class _HeaderBar extends StatelessWidget {
  final String driverName;
  final ImageProvider? profileImage;
  final Future<void> Function() onChangePhoto;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;

  final int unreadCount;

  const _HeaderBar({
    required this.driverName,
    this.profileImage,
    required this.onChangePhoto,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.unreadCount,
  });

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((p) => p[0]).join();
    return initials.toUpperCase();
  }

  Widget _avatarFallback({required double fontSize}) {
    final initials = _initialsFromName(driverName);
    if (initials.isEmpty) {
      return const Icon(Icons.person, color: Colors.white, size: 18);
    }
    return Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }

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
      case 'tr':
        return 'assets/flags/tr.svg';
      case 'ru':
        return 'assets/flags/ru.svg';
      default:
        return 'assets/flags/gb.svg'; // fallback
    }
  }

  String _languageName(String code) {
    switch (code) {
      case 'de':
        return 'Deutsch';
      case 'en':
        return 'English';
      case 'sq':
        return 'Shqip';
      case 'hu':
        return 'Magyar';
      case 'ro':
        return 'Română';
      case 'hr':
        return 'Hrvatski';
      case 'ar':
        return 'العربية';
      case 'tr':
        return 'Turkce';
      case 'ru':
        return 'Русский';
      default:
        return code;
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
    final int notificationCount = unreadCount;

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
                child: Center(
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: const TextStyle(
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
          child: profileImage == null ? _avatarFallback(fontSize: 12) : null,
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
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final localeCount = AppLocalizations.supportedLocales.length;
        const tileHeight = 56.0;
        const headerHeight = 60.0;
        const dividerHeight = 1.0;
        const bottomGap = 8.0;
        const verticalMargin = 24.0; // top+bottom margin around sheet
        const minTopGap = 56.0; // keep tappable outside area for dismissal

        final desiredHeight =
            headerHeight +
            dividerHeight +
            (localeCount * tileHeight) +
            bottomGap;
        final maxAvailableHeight =
            media.size.height -
            media.padding.top -
            media.padding.bottom -
            verticalMargin -
            minTopGap;
        final safeMaxHeight = maxAvailableHeight > 260
            ? maxAvailableHeight
            : (media.size.height * 0.8);
        final sheetHeight = desiredHeight < safeMaxHeight
            ? desiredHeight
            : safeMaxHeight;
        final needsScroll = desiredHeight > safeMaxHeight;

        return Container(
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
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          loc.t('select_language'),
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
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: needsScroll
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemExtent: tileHeight,
                    itemCount: AppLocalizations.supportedLocales.length,
                    itemBuilder: (ctx, index) {
                      final l = AppLocalizations.supportedLocales[index];
                      final code = l.languageCode;
                      final isActive = code == currentCode;
                      final asset = _flagAssetForLang(code);

                      return ListTile(
                        leading: SvgPicture.asset(asset, width: 26, height: 20),
                        title: Text(
                          _languageName(code),
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
        );
      },
    );

    if (selectedCode != null && selectedCode != currentCode) {
      localeController.setLocale(Locale(selectedCode));

      // persist on user document
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'languageCode': selectedCode,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> _onProfileTap(BuildContext context) async {
    final loc = AppLocalizations.of(context);

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).pop(),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // stop closing when tapping inside
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: profileImage,
                          backgroundColor: Colors.grey.shade300,
                          child: profileImage == null
                              ? _avatarFallback(fontSize: 18)
                              : null,
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
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onOpenProfile();
                        },
                        child: Text(
                          loc.t('nav_profile'),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
        );
      },
    );
  }

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final currentLocale =
        localeController.locale ?? Localizations.localeOf(context);
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
                child: SvgPicture.asset(flagAsset, fit: BoxFit.cover),
              ),
              onTap: () => _selectLanguage(context),
            ),
            const SizedBox(width: 10),
            _notificationBubble(onOpenNotifications),
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
  final int pendingTasksCount;
  final ValueChanged<int> onTap;

  const _DriverBottomNav({
    required this.index,
    required this.pendingTasksCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    Widget navItem({
      required Widget Function(Color color) iconBuilder,
      required String label,
      required int i,
      int badgeCount = 0,
    }) {
      final selected = index == i;
      final color = selected ? _kPrimaryGreen : Colors.black54;

      Widget icon = iconBuilder(color);
      if (badgeCount > 0) {
        icon = Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            Positioned(
              right: -8,
              top: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: const BoxDecoration(
                  color: Color(0xFFE9741A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => onTap(0),
            child: navItem(
              iconBuilder: (color) =>
                  Icon(Icons.home_outlined, size: 28, color: color),
              label: loc.t('nav_home'),
              i: 0,
            ),
          ),
          GestureDetector(
            onTap: () => onTap(1),
            child: navItem(
              iconBuilder: (color) => SvgPicture.asset(
                'assets/icons/cards_star.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              label: loc.t('nav_scorecard'),
              i: 1,
            ),
          ),
          GestureDetector(
            onTap: () => onTap(2),
            child: navItem(
              iconBuilder: (color) =>
                  Icon(Icons.help_outline_rounded, size: 28, color: color),
              label: loc.t('nav_help'),
              i: 2,
            ),
          ),
          GestureDetector(
            onTap: () => onTap(3),
            child: navItem(
              iconBuilder: (color) =>
                  Icon(Icons.task_alt_outlined, size: 28, color: color),
              label: loc.t('nav_tasks'),
              i: 3,
              badgeCount: pendingTasksCount,
            ),
          ),
          GestureDetector(
            onTap: () => onTap(4),
            child: navItem(
              iconBuilder: (color) =>
                  Icon(Icons.gavel_outlined, size: 28, color: color),
              label: loc.t('nav_rules'),
              i: 4,
            ),
          ),
        ],
      ),
    );
  }
}
