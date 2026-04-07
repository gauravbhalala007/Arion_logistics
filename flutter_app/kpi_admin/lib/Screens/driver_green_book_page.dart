import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../localization/app_localizations.dart';
import '../widgets/web_video_embed.dart';
import 'driver_green_book_test_page.dart';

const Color _kGreenBookText = Color(0xFF1F2937);
const Color _kGreenBookMuted = Color(0xFF7A869F);
const Color _kGreenBookPrimary = Color(0xFF2BBE63);
const Color _kGreenBookCardTint = Color(0xFFF3FBF5);
const Map<String, String> _kGreenBookVideoFallbacks = {
  'en':
      'https://drive.google.com/file/d/1ucFruV-uBg84u_smauEdUuPwIy4GFhO5/view?usp=drive_link',
  'sq':
      'https://drive.google.com/file/d/1jwpTXIYgWjF7UOJVeuQ38Kz3vvVjLiLi/view?usp=drive_link',
  'ar':
      'https://drive.google.com/file/d/1r788LPjImJS5AS0HXapWYL1hq9CXvjrT/view?usp=drive_link',
  'de':
      'https://drive.google.com/file/d/19oj-1MVWvZrWUwt5KyDgpv75XDIrSn4r/view?usp=drive_link',
  'ro':
      'https://drive.google.com/file/d/1AtSfBDwL4JvlFa82E8BL6Fft-fuJnSxF/view?usp=drive_link',
  'hr':
      'https://drive.google.com/file/d/1h0WbPTwzUFkw8LY1_w9aeQ2TkBTPY4R3/view?usp=drive_link',
  'hu':
      'https://drive.google.com/file/d/11JWbV6EBA3JpSgjxXfaoRR4O6baerLxj/view?usp=drive_link',
};

class DriverGreenBookPage extends StatefulWidget {
  final String dspUid;
  final String driverTransporterId;
  final VoidCallback onBack;

  const DriverGreenBookPage({
    super.key,
    required this.dspUid,
    required this.driverTransporterId,
    required this.onBack,
  });

  @override
  State<DriverGreenBookPage> createState() => _DriverGreenBookPageState();
}

class _DriverGreenBookPageState extends State<DriverGreenBookPage> {
  late Future<String> _videoUrlFuture;
  String _lastLocaleCode = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode
        .toLowerCase()
        .trim();
    if (_lastLocaleCode == localeCode) return;
    _lastLocaleCode = localeCode;
    _videoUrlFuture = _loadVideoUrl();
  }

  Future<String> _loadVideoUrl() async {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    String fallbackFor(String code) {
      return _kGreenBookVideoFallbacks[code] ??
          _kGreenBookVideoFallbacks['en'] ??
          '';
    }

    if (widget.dspUid.trim().isEmpty) {
      return fallbackFor(lang);
    }
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.dspUid.trim())
        .collection('academy_tests')
        .doc('green_book');

    try {
      DocumentSnapshot<Map<String, dynamic>> snap;
      try {
        snap = await ref.get(const GetOptions(source: Source.server));
      } on FirebaseException {
        snap = await ref.get();
      }
      final data = snap.data() ?? const <String, dynamic>{};
      final candidates = [
        (data['videoUrl_$lang'] ?? '').toString().trim(),
        (data['mediaUrl_$lang'] ?? '').toString().trim(),
        (data['url_$lang'] ?? '').toString().trim(),
        (data['videoUrl'] ?? '').toString().trim(),
        (data['mediaUrl'] ?? '').toString().trim(),
        (data['url'] ?? '').toString().trim(),
        fallbackFor(lang),
      ];
      for (final value in candidates) {
        if (value.isNotEmpty) return value;
      }
      return '';
    } catch (_) {
      return fallbackFor(lang);
    }
  }

  Uri? _googleDrivePreviewUri(Uri uri) {
    final fileId = _extractGoogleDriveFileId(uri);
    if (fileId.isEmpty) return null;
    return Uri.parse('https://drive.google.com/file/d/$fileId/preview');
  }

  String _extractGoogleDriveFileId(Uri uri) {
    final idFromQuery = uri.queryParameters['id']?.trim() ?? '';
    if (idFromQuery.isNotEmpty) return idFromQuery;

    final segments = uri.pathSegments;
    final fileIndex = segments.indexOf('d');
    if (fileIndex >= 0 && fileIndex + 1 < segments.length) {
      final id = segments[fileIndex + 1].trim();
      if (id.isNotEmpty) return id;
    }

    return '';
  }

  Future<void> _openVideo(String url) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final raw = url.trim();
    if (raw.isEmpty) {
      messenger?.showSnackBar(
        SnackBar(content: Text(t.t('faq_green_book_video_missing'))),
      );
      return;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(t.t('faq_green_book_video_open_failed'))),
      );
      return;
    }

    final googleDrivePreviewUri = _googleDrivePreviewUri(uri);
    if (!kIsWeb && googleDrivePreviewUri != null) {
      final opened = await launchUrl(
        googleDrivePreviewUri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (!opened && mounted) {
        messenger?.showSnackBar(
          SnackBar(content: Text(t.t('faq_green_book_video_open_failed'))),
        );
      }
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _GreenBookVideoDialog(
        videoUri: googleDrivePreviewUri ?? uri,
        title: t.t('driver_green_book_video_title'),
        useWebEmbed: kIsWeb && googleDrivePreviewUri != null,
      ),
    );
  }

  void _openTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverGreenBookTestPage(
          dspUid: widget.dspUid,
          driverTransporterId: widget.driverTransporterId,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  _LanguageMeta _languageMeta(String code) {
    switch (code) {
      case 'de':
        return const _LanguageMeta(flag: '🇩🇪', label: 'Deutsch');
      case 'sq':
        return const _LanguageMeta(flag: '🇦🇱', label: 'Shqip');
      case 'hu':
        return const _LanguageMeta(flag: '🇭🇺', label: 'Magyar');
      case 'ro':
        return const _LanguageMeta(flag: '🇷🇴', label: 'Romana');
      case 'hr':
        return const _LanguageMeta(flag: '🇭🇷', label: 'Hrvatski');
      case 'ar':
        return const _LanguageMeta(flag: '🇸🇦', label: 'العربية');
      case 'tr':
        return const _LanguageMeta(flag: '🇹🇷', label: 'Turkce');
      case 'ru':
        return const _LanguageMeta(flag: '🇷🇺', label: 'Русский');
      default:
        return const _LanguageMeta(flag: '🇬🇧', label: 'English');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final langMeta = _languageMeta(langCode);
    const noUnderline = TextStyle(
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    );

    return DefaultTextStyle.merge(
      style: noUnderline,
      child: SelectionContainer.disabled(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: widget.onBack,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    t.t('driver_academy_green_book_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kGreenBookText,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FutureBuilder<String>(
                future: _videoUrlFuture,
                builder: (context, snap) {
                  return _GreenBookVideoCard(
                    title: t.t('driver_green_book_video_title'),
                    flag: langMeta.flag,
                    languageLabel: langMeta.label,
                    onTap: () => _openVideo(snap.data ?? ''),
                  );
                },
              ),
              const SizedBox(height: 14),
              _GreenBookTestCta(
                label: t.t('driver_green_book_start_test'),
                note: t.t('driver_green_book_test_required'),
                onTap: _openTest,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.content_paste_rounded,
                iconColor: const Color(0xFFD09A55),
                title: t.t('driver_green_book_section1_title'),
                body: t.t('driver_green_book_section1_text'),
                bullets: [
                  t.t('driver_green_book_section1_b1'),
                  t.t('driver_green_book_section1_b2'),
                  t.t('driver_green_book_section1_b3'),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFF97316),
                title: t.t('driver_green_book_section2_title'),
                body: t.t('driver_green_book_section2_text'),
                bullets: [
                  t.t('driver_green_book_section2_b1'),
                  t.t('driver_green_book_section2_b2'),
                  t.t('driver_green_book_section2_b3'),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.gavel_rounded,
                iconColor: const Color(0xFFEF4444),
                title: t.t('driver_green_book_section3_title'),
                body: t.t('driver_green_book_section3_text'),
                bullets: [
                  t.t('driver_green_book_section3_b1'),
                  t.t('driver_green_book_section3_b2'),
                  t.t('driver_green_book_section3_b3'),
                  t.t('driver_green_book_section3_b4'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenBookVideoCard extends StatelessWidget {
  final String title;
  final String flag;
  final String languageLabel;
  final VoidCallback onTap;

  const _GreenBookVideoCard({
    required this.title,
    required this.flag,
    required this.languageLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
          decoration: BoxDecoration(
            color: _kGreenBookCardTint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDDE9DF), width: 1.2),
          ),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0xFFD8F1DE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 54,
                  color: _kGreenBookPrimary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kGreenBookText,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$flag $languageLabel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _kGreenBookMuted,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreenBookTestCta extends StatelessWidget {
  final String label;
  final String note;
  final VoidCallback onTap;

  const _GreenBookTestCta({
    required this.label,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _kGreenBookPrimary, width: 2.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF70809D),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF70809D),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          note,
          style: const TextStyle(
            color: Color(0xFFFF3B30),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final List<String> bullets;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final cleanBullets = bullets.where((b) => b.trim().isNotEmpty).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3E7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 21, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _kGreenBookText,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          if (body.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: _kGreenBookMuted,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
          for (final bullet in cleanBullets) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_rounded,
                    size: 21,
                    color: _kGreenBookPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bullet,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: _kGreenBookMuted,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GreenBookVideoDialog extends StatefulWidget {
  final Uri videoUri;
  final String title;
  final bool useWebEmbed;

  const _GreenBookVideoDialog({
    required this.videoUri,
    required this.title,
    required this.useWebEmbed,
  });

  @override
  State<_GreenBookVideoDialog> createState() => _GreenBookVideoDialogState();
}

class _GreenBookVideoDialogState extends State<_GreenBookVideoDialog> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.useWebEmbed) return;
    _controller = VideoPlayerController.networkUrl(widget.videoUri);
    _initializeFuture = _controller!.initialize().then((_) {
      _controller!.setLooping(false);
      if (mounted) setState(() {});
    }).catchError((_) {
      _error = 'load_failed';
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final media = MediaQuery.sizeOf(context);
    final dialogWidth = media.width > 960 ? 960.0 : media.width - 24;
    final dialogHeight = media.height > 780 ? 780.0 : media.height - 32;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kGreenBookText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: widget.useWebEmbed
                        ? buildWebVideoEmbed(
                            viewType:
                                'green-book-video-${DateTime.now().microsecondsSinceEpoch}',
                            uri: widget.videoUri,
                          )
                        : FutureBuilder<void>(
                            future: _initializeFuture,
                            builder: (context, snap) {
                              if (_error != null || _controller == null) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      t.t('faq_green_book_video_open_failed'),
                                      style:
                                          const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              if (snap.connectionState !=
                                      ConnectionState.done ||
                                  !_controller!.value.isInitialized) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              }
                              return Center(
                                child: AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: VideoPlayer(_controller!),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              if (!widget.useWebEmbed) ...[
                const SizedBox(height: 12),
                if (_controller != null && _controller!.value.isInitialized)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          final c = _controller!;
                          c.value.isPlaying ? c.pause() : c.play();
                          setState(() {});
                        },
                        icon: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          size: 42,
                          color: _kGreenBookPrimary,
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
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
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 18, color: _kGreenBookText),
        ),
      ),
    );
  }
}

class _LanguageMeta {
  final String flag;
  final String label;

  const _LanguageMeta({required this.flag, required this.label});
}
