import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/app_localizations.dart';
import '../services/auth_service.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _busy = false;

  Future<void> _resend() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AuthService.resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('verify_email_sent')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.tf('verify_email_failed_template', {'error': e.toString()}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _iVerifiedReload() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                t.t('verify_email_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.t('verify_email_intro'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _resend,
                child: Text(
                  _busy
                      ? t.t('verify_email_sending')
                      : t.t('verify_email_resend'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _iVerifiedReload,
                child: Text(t.t('verify_email_reload')),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: Text(t.t('verify_email_back_to_login')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
