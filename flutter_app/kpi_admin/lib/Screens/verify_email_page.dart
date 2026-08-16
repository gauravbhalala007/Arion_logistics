import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Codriver Design Tokens (from CODRIVER_STYLEGUIDE.md) ---
const Color _codriverGreen = Color(0xFF00B287);
const Color _codriverDeep = Color(0xFF006047);
const Color _green50 = Color(0xFFE6F8F2);

const Color _background = Color(0xFFFFFFFF);
const Color _surfaceElevated = Color(0xFFFFFFFF);
const Color _label = Color(0xFF000000);
const Color _labelSecondary = Color(0x993C3C43);

const double _spXs = 8;
const double _spSm = 12;
const double _spMd = 16;
const double _spLg = 20;
const double _spXl = 24;
const double _spXxl = 32;
const double _spXxxl = 48;

const String _fontFamily = 'SF Pro Display';

const TextStyle _title1 = TextStyle(
  fontFamily: _fontFamily,
  fontSize: 28,
  height: 34 / 28,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.36,
  color: _label,
);

const TextStyle _headline = TextStyle(
  fontFamily: _fontFamily,
  fontSize: 17,
  height: 22 / 17,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.43,
);

const TextStyle _body = TextStyle(
  fontFamily: _fontFamily,
  fontSize: 17,
  height: 22 / 17,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.43,
  color: _label,
);

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Future<void> _backToLogin() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: _spXl,
                vertical: _spXxl,
              ),
              shrinkWrap: true,
              children: [
                const SizedBox(height: _spXxl),
                _buildLogo(),
                const SizedBox(height: _spXxxl),
                _buildBetaCard(),
                const SizedBox(height: _spXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/login_codriver_logo.png',
        width: 240,
        height: 140,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildBetaCard() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      padding: const EdgeInsets.all(_spXl),
      decoration: const BoxDecoration(
        color: _surfaceElevated,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: _green50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 32,
                color: _codriverDeep,
              ),
            ),
          ),
          const SizedBox(height: _spLg),
          Text(
            de ? 'Beta-Phase' : 'Beta phase',
            textAlign: TextAlign.center,
            style: _title1,
          ),
          const SizedBox(height: _spXs),
          Text(
            de
                ? 'Vielen Dank für dein Interesse an CODRIVER.'
                : 'Thank you for your interest in CODRIVER.',
            textAlign: TextAlign.center,
            style: _headline.copyWith(color: _codriverDeep),
          ),
          const SizedBox(height: _spLg),
          Text(
            de
                ? 'Aktuell befinden wir uns in der Beta-Phase.'
                : 'We are currently in the beta phase.',
            textAlign: TextAlign.center,
            style: _body.copyWith(color: _labelSecondary, height: 1.45),
          ),
          const SizedBox(height: _spSm),
          Text(
            de
                ? 'Wenn du die Codriver App testen möchtest, melde dich bitte per E-Mail bei uns:'
                : 'If you would like to test the CoDriver app, please get in touch with us by email:',
            textAlign: TextAlign.center,
            style: _body.copyWith(color: _labelSecondary, height: 1.45),
          ),
          const SizedBox(height: _spMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _spMd,
              vertical: _spSm,
            ),
            decoration: BoxDecoration(
              color: _green50,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mail_outline_rounded,
                  size: 18,
                  color: _codriverDeep,
                ),
                const SizedBox(width: _spXs),
                SelectableText(
                  'info@kw-agentur.de',
                  style: _headline.copyWith(
                    color: _codriverDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: _spLg),
          Text(
            de
                ? 'Vielen Dank für dein Verständnis!'
                : 'Thank you for your understanding!',
            textAlign: TextAlign.center,
            style: _body.copyWith(color: _labelSecondary, height: 1.45),
          ),
          const SizedBox(height: _spXxl),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _backToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _codriverGreen,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: _spXxl),
                textStyle: _headline,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  const SizedBox(width: _spXs),
                  Text(
                    de ? 'Zurück zum Login' : 'Back to login',
                    style: _headline,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: _spSm),
          const Center(
            child: Text(
              'Kreativwerk | www.kw-agentur.de',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 13,
                height: 18 / 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Color(0x4D3C3C43),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
