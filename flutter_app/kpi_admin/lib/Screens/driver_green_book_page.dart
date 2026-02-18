import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations.dart';

const String _settingsCollection = 'settings';
const String _faqResourcesDoc = 'faq_resources';
const Map<String, String> _defaultGreenBookVideoUrls = {
  'en':
      'https://drive.google.com/file/d/1ucFruV-uBg84u_smauEdUuPwIy4GFhO5/view?usp=sharing',
  'sq':
      'https://drive.google.com/file/d/1jwpTXIYgWjF7UOJVeuQ38Kz3vvVjLiLi/view?usp=sharing',
  'ar':
      'https://drive.google.com/file/d/1r788LPjImJS5AS0HXapWYL1hq9CXvjrT/view?usp=sharing',
  'de':
      'https://drive.google.com/file/d/19oj-1MVWvZrWUwt5KyDgpv75XDIrSn4r/view?usp=sharing',
  'hu':
      'https://drive.google.com/file/d/11JWbV6EBA3JpSgjxXfaoRR4O6baerLxj/view?usp=sharing',
  'hr':
      'https://drive.google.com/file/d/1h0WbPTwzUFkw8LY1_w9aeQ2TkBTPY4R3/view?usp=sharing',
  'ro':
      'https://drive.google.com/file/d/1AtSfBDwL4JvlFa82E8BL6Fft-fuJnSxF/view?usp=sharing',
};
const String _defaultGreenBookVideoUrl =
    'https://drive.google.com/file/d/19oj-1MVWvZrWUwt5KyDgpv75XDIrSn4r/view?usp=sharing';

class DriverGreenBookPage extends StatelessWidget {
  final String dspUid;
  final VoidCallback onBack;
  final VoidCallback onStartTest;

  const DriverGreenBookPage({
    super.key,
    required this.dspUid,
    required this.onBack,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final resourcesStream = dspUid.isEmpty
        ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance
              .collection('users')
              .doc(dspUid)
              .collection(_settingsCollection)
              .doc(_faqResourcesDoc)
              .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: resourcesStream,
      builder: (context, snap) {
        final resources = snap.data?.data() ?? const <String, dynamic>{};
        final videoUrl = _resolveGreenBookVideoUrl(resources, langCode);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t.t('driver_green_book_title'),
                    style: const TextStyle(
                      fontSize: 36 / 2,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _VideoCard(
                title: t.t('driver_green_book_video_title'),
                subtitle: t.t('driver_green_book_video_subtitle'),
                onTap: () => _openGreenBookVideo(context, videoUrl),
              ),
              const SizedBox(height: 14),
              _StartTestButton(
                label: t.t('driver_green_book_start_test'),
                onTap: onStartTest,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  t.t('driver_green_book_test_required'),
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                borderColor: const Color(0xFFDDE3E7),
                title: t.t('driver_green_book_section1_title'),
                paragraph: t.t('driver_green_book_section1_text'),
                bullets: [
                  t.t('driver_green_book_section1_b1'),
                  t.t('driver_green_book_section1_b2'),
                  t.t('driver_green_book_section1_b3'),
                ],
                bulletIcon: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF22C55E),
                  size: 22,
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                borderColor: const Color(0xFFFCA5A5),
                title: t.t('driver_green_book_section2_title'),
                paragraph: t.t('driver_green_book_section2_text'),
                bullets: [
                  t.t('driver_green_book_section2_b1'),
                  t.t('driver_green_book_section2_b2'),
                  t.t('driver_green_book_section2_b3'),
                ],
                bulletIcon: const Icon(
                  Icons.looks_one_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                borderColor: const Color(0xFFFCA5A5),
                title: t.t('driver_green_book_section3_title'),
                paragraph: t.t('driver_green_book_section3_text'),
                bullets: [
                  t.t('driver_green_book_section3_b1'),
                  t.t('driver_green_book_section3_b2'),
                  t.t('driver_green_book_section3_b3'),
                  t.t('driver_green_book_section3_b4'),
                ],
                bulletIcon: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _resolveGreenBookVideoUrl(
    Map<String, dynamic> resources,
    String langCode,
  ) {
    String pick(dynamic value) => value?.toString().trim() ?? '';
    final normalizedLang = langCode.trim().toLowerCase();

    if (normalizedLang.isNotEmpty) {
      final flatByLang = pick(resources['greenBookVideoUrl_$normalizedLang']);
      if (flatByLang.isNotEmpty) return flatByLang;

      final mapRaw = resources['greenBookVideoUrls'];
      if (mapRaw is Map) {
        final normalizedMap = mapRaw.map(
          (k, v) => MapEntry(k.toString().trim().toLowerCase(), v),
        );
        final mapByLang = pick(normalizedMap[normalizedLang]);
        if (mapByLang.isNotEmpty) return mapByLang;
      }
    }

    final generic = pick(resources['greenBookVideoUrl']);
    if (generic.isNotEmpty) return generic;

    final mapRaw = resources['greenBookVideoUrls'];
    if (mapRaw is Map) {
      final normalizedMap = mapRaw.map(
        (k, v) => MapEntry(k.toString().trim().toLowerCase(), v),
      );
      final mapDefault = pick(normalizedMap['default']);
      if (mapDefault.isNotEmpty) return mapDefault;
    }

    final byLangDefault = _defaultGreenBookVideoUrls[normalizedLang];
    if (byLangDefault != null && byLangDefault.trim().isNotEmpty) {
      return byLangDefault;
    }
    return _defaultGreenBookVideoUrl;
  }

  Future<void> _openGreenBookVideo(BuildContext context, String rawUrl) async {
    final messenger = ScaffoldMessenger.of(context);
    final t = AppLocalizations.of(context);
    final openFailedMessage = t.t('faq_green_book_video_open_failed');
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      _showSnack(messenger, t.t('faq_green_book_video_missing'));
      return;
    }

    Uri? uri = Uri.tryParse(trimmed);
    if (uri == null || (!uri.hasScheme && !trimmed.startsWith('www.'))) {
      _showSnack(messenger, openFailedMessage);
      return;
    }
    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$trimmed');
    }
    if (uri == null) {
      _showSnack(messenger, openFailedMessage);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showSnack(messenger, openFailedMessage);
    }
  }

  void _showSnack(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VideoCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 270,
          decoration: BoxDecoration(
            color: const Color(0xFFDCEBE3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 98,
                height: 98,
                decoration: const BoxDecoration(
                  color: Color(0xFFB8DEC7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 54,
                  color: Color(0xFF22AF66),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 35 / 2,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16, color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartTestButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StartTestButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF22AF66), width: 3),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 41 / 2,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF667085),
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color borderColor;
  final String title;
  final String paragraph;
  final List<String> bullets;
  final Icon bulletIcon;

  const _InfoCard({
    required this.borderColor,
    required this.title,
    required this.paragraph,
    required this.bullets,
    required this.bulletIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 44 / 2,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            paragraph,
            style: const TextStyle(
              fontSize: 40 / 2,
              color: Color(0xFF667085),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: bulletIcon,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 36 / 2,
                        color: Color(0xFF667085),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDDE3E7), width: 1),
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
