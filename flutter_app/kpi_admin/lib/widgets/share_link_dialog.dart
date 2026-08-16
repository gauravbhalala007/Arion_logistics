// lib/widgets/share_link_dialog.dart
//
// Small dialog showing a freshly created public share link with a
// copy-to-clipboard button. Used by the waveplan + shift plan pages.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

Future<void> showShareLinkDialog(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.link_rounded,
                      color: AppColors.codriverDeep),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Öffentlicher Link',
                      style: AppTypography.headline.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              Text(
                'Jeder mit diesem Link kann den Plan ansehen — ohne '
                'Anmeldung. Erneutes Teilen aktualisiert denselben Link.',
                style: AppTypography.caption1
                    .copyWith(color: const Color(0xFF6B7280), height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: SelectableText(
                  url,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.codriverGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.codriverDeep,
                        content: Text(
                          'Link kopiert.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Link kopieren'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
