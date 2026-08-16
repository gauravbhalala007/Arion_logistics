// /lib/Screens/login_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_button_style.dart';
import '../services/auth_service.dart';

// --- Codriver Design Tokens (from CODRIVER_STYLEGUIDE.md) ---
// Brand
const Color _codriverGreen = Color(0xFF00B287);
const Color _codriverDeep = Color(0xFF006047);
const Color _green50 = Color(0xFFE6F8F2);

// Semantic — Light
const Color _background = Color(0xFFFAFAFA);
const Color _surface = Color(0xFFF2F2F7);
const Color _surfaceElevated = Color(0xFFFFFFFF);
const Color _separator = Color(0xFFC6C6C8);
const Color _label = Color(0xFF000000);
const Color _labelSecondary = Color(0x993C3C43);
const Color _labelTertiary = Color(0x4D3C3C43);

// Status
const Color _error = Color(0xFFFF3B30);
const Color _success = Color(0xFF34C759);

// Spacing (4-pt grid)
const double _spXs = 8;
const double _spSm = 12;
const double _spMd = 16;
const double _spLg = 20;
const double _spXl = 24;
const double _spXxl = 32;
const double _spXxxl = 48;

// SF Pro → fallback to system. Apply letter-spacing per styleguide.
TextStyle get _title1 => GoogleFonts.inter(
  fontSize: 28,
  height: 34 / 28,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.4,
  color: _label,
);

TextStyle get _headline => GoogleFonts.inter(
  fontSize: 17,
  height: 22 / 17,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.3,
);

TextStyle get _body => GoogleFonts.inter(
  fontSize: 17,
  height: 22 / 17,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.3,
  color: _label,
);

TextStyle get _subheadline => GoogleFonts.inter(
  fontSize: 15,
  height: 20 / 15,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.2,
);

TextStyle get _footnote => GoogleFonts.inter(
  fontSize: 13,
  height: 18 / 13,
  fontWeight: FontWeight.w400,
  letterSpacing: -0.05,
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _busy = false;
  bool _passwordVisible = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // --- Auth ---

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Enter both your email and password to continue.');
      return;
    }

    setState(() => _busy = true);
    try {
      await AuthService.signIn(email: email, password: password);

      // Helps OS/browser password managers decide to save credentials.
      // (On Flutter web, prompts are still browser-dependent.)
      TextInput.finishAutofillContext(shouldSave: true);

      if (!mounted) return;
      _clearMessages();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } on FirebaseAuthException catch (e) {
      _showError(_mapLoginError(e));
    } catch (_) {
      _showError(
        'We could not sign you in right now. Please try again in a moment.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onForgotPassword() async {
    // Drivers/employees can't reliably receive reset mails (many use a
    // system address). Primary guidance: contact your supervisor, who sets
    // a new password in the Drivers Hub. Admins can still request an email
    // reset link for their own real address.
    final de = Localizations.localeOf(context).languageCode == 'de';
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(de ? 'Passwort vergessen?' : 'Forgot password?'),
        content: Text(
          de
              ? 'Mitarbeiter / Fahrer:\n'
                  'Bitte wende dich an deinen Vorgesetzten (DSP-Admin). Er kann dir '
                  'in der Fahrerverwaltung ein neues Passwort setzen.\n\n'
                  'Admin? Wir können dir einen Reset-Link an deine E-Mail senden.'
              : 'Employees / drivers:\n'
                  'Please contact your supervisor (DSP admin). They can set a '
                  'new password for you in the driver management.\n\n'
                  'Admin? We can send a reset link to your email address.',
          style: const TextStyle(height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('close'),
            child: Text(de ? 'Schließen' : 'Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('email'),
            child: Text(de ? 'Admin: Reset-Link senden' : 'Admin: send reset link'),
          ),
        ],
      ),
    );
    if (action != 'email') return;
    await _sendResetEmail();
  }

  Future<void> _sendResetEmail() async {
    final de = Localizations.localeOf(context).languageCode == 'de';
    final email = _email.text.trim();
    if (email.isEmpty) {
      _showError(
        de
            ? 'Bitte zuerst deine E-Mail-Adresse eingeben.'
            : 'Enter your email address first.',
      );
      return;
    }
    // System driver addresses can't receive mail — send them to their admin.
    if (email.toLowerCase().endsWith('@drivers.dsp-copilot.local')) {
      _showError(
        de
            ? 'Dieses Konto hat keine persönliche E-Mail. Bitte wende dich an '
                'deinen Vorgesetzten für ein neues Passwort.'
            : 'This account has no personal email — ask your supervisor for a '
                'new password.',
      );
      return;
    }
    try {
      await AuthService.resetPassword(email);
      _showInfo(
        de
            ? 'Reset-Link gesendet — bitte auch den Spam-Ordner prüfen. Kommt '
                'nichts an, wende dich an deinen Vorgesetzten.'
            : 'Reset link sent — please also check your spam folder. If '
                'nothing arrives, contact your supervisor.',
      );
    } on FirebaseAuthException catch (e) {
      _showError(_mapResetError(e));
    } catch (_) {
      _showError(
        de
            ? 'Reset-Link konnte gerade nicht gesendet werden. Bitte später '
                'erneut versuchen.'
            : 'Could not send the reset email right now. Please try again '
                'later.',
      );
    }
  }

  void _clearMessages() {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _infoMessage = null;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _infoMessage = null;
    });
  }

  void _showInfo(String message) {
    if (!mounted) return;
    setState(() {
      _infoMessage = message;
      _errorMessage = null;
    });
  }

  String _mapLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many login attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network connection failed. Check your internet and try again.';
      default:
        return 'Login failed. Please check your details and try again.';
    }
  }

  String _mapResetError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
        return 'No account was found for that email address.';
      case 'too-many-requests':
        return 'Too many requests. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network connection failed. Check your internet and try again.';
      default:
        return 'Password reset failed. Please try again.';
    }
  }

  // --- UI ---

  static const double _splitBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _splitBreakpoint;
          if (isWide) {
            return Row(
              children: [
                Expanded(child: _buildBrandPanel()),
                Expanded(child: _buildFormPanel()),
              ],
            );
          }
          return SafeArea(child: _buildFormPanel());
        },
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      color: _codriverDeep,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(72),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'organize and improve\nyour delivery team',
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 56,
                height: 1.25,
                fontWeight: FontWeight.w500,
                letterSpacing: -1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    return Center(
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
            const SizedBox(height: _spMd),
            _buildLoginCard(),
            const SizedBox(height: _spXxl),
            _buildFooter(),
            const SizedBox(height: _spXl),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/login_codriver_logo.png',
        width: 300,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildLoginCard() {
    final de = Localizations.localeOf(context).languageCode == 'de';
    return Container(
      padding: const EdgeInsets.all(_spXl),
      decoration: BoxDecoration(
        color: _surfaceElevated,
        borderRadius: const BorderRadius.all(Radius.circular(32)),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 2),
        boxShadow: const [
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
      child: AutofillGroup(
        onDisposeAction: AutofillContextAction.commit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome', textAlign: TextAlign.center, style: _title1),
            const SizedBox(height: _spXs),
            Text(
              'Sign in to continue to Codriver',
              textAlign: TextAlign.center,
              style: _subheadline.copyWith(color: _labelSecondary),
            ),
            const SizedBox(height: _spXl),

            _buildStatusCard(),

            _CodriverTextField(
              controller: _email,
              focusNode: _emailFocus,
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline_rounded,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              onChanged: _onFieldChanged,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: _spMd),

            _CodriverTextField(
              controller: _password,
              focusNode: _passwordFocus,
              hintText: 'Your password',
              obscureText: !_passwordVisible,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline_rounded,
              autofillHints: const [AutofillHints.password],
              onChanged: _onFieldChanged,
              onSubmitted: (_) => _submit(),
              suffix: _PasswordToggleButton(
                visible: _passwordVisible,
                onToggle: () {
                  setState(() => _passwordVisible = !_passwordVisible);
                },
              ),
            ),
            const SizedBox(height: _spXs),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _onForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: _codriverDeep,
                  padding: const EdgeInsets.symmetric(
                    horizontal: _spSm,
                    vertical: _spXs,
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  de ? 'Passwort vergessen?' : 'Forgot password?',
                  style: _footnote.copyWith(
                    color: _codriverDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: _spLg),

            _buildPrimaryButton(),
            const SizedBox(height: _spMd),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New here?',
                  style: _footnote.copyWith(color: _labelSecondary),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/signup'),
                  style: TextButton.styleFrom(
                    foregroundColor: _codriverGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: _spXs,
                      vertical: _spXs,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Sign up',
                    style: _footnote.copyWith(
                      color: _codriverGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onFieldChanged(String _) {
    if (_errorMessage != null || _infoMessage != null) _clearMessages();
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      child: FilledButton(
        onPressed: _busy ? null : _submit,
        style: AppButtonStyle.of(AppButtonVariant.primary),
        child: _busy
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(width: _spSm),
                  Text('Please wait…', style: _headline),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Continue', style: _headline),
                  const SizedBox(width: _spXs),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final message = _errorMessage ?? _infoMessage;
    if (message == null || message.isEmpty) return const SizedBox.shrink();

    final isError = _errorMessage != null;
    final accent = isError ? _error : _success;
    final bg = isError ? const Color(0xFFFFF1F0) : _green50;
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: _spMd),
      padding: const EdgeInsets.symmetric(horizontal: _spMd, vertical: _spSm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(12)), // sm
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: _spSm),
          Expanded(
            child: Text(
              message,
              style: _footnote.copyWith(
                color: isError ? const Color(0xFF7F1D1D) : _codriverDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Kreativwerk | www.kw-agentur.de',
        style: _footnote.copyWith(
          color: _labelTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// --- Small reusable bits (scoped to this file) ---

class _CodriverTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _CodriverTextField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_CodriverTextField> createState() => _CodriverTextFieldState();
}

class _CodriverTextFieldState extends State<_CodriverTextField> {
  bool _hovered = false;

  late final FocusNode _node;
  bool _ownsNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _node = widget.focusNode!;
    } else {
      _node = FocusNode();
      _ownsNode = true;
    }
    _node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    if (_ownsNode) _node.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = _node.hasFocus;

    // Border color: subtle at rest, slightly stronger on hover, brand on focus.
    final borderColor = focused
        ? _codriverGreen
        : _hovered
        ? _separator
        : _separator.withOpacity(0.55);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _surfaceElevated, // white — sits on the gray scaffold cleanly
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          // Constant border width avoids any layout jump or
          // half-disappearing edges when focus changes.
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _node.requestFocus(),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                const SizedBox(width: _spMd),
                Icon(
                  widget.prefixIcon,
                  size: 20,
                  color: focused ? _codriverGreen : _labelSecondary,
                ),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _node,
                  obscureText: widget.obscureText,
                  enableSuggestions: widget.enableSuggestions,
                  autocorrect: widget.autocorrect,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: _codriverGreen,
                  style: _body,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: widget.hintText,
                    hintStyle: _body.copyWith(color: _labelTertiary),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon == null ? _spMd : _spSm,
                      vertical: _spMd,
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                widget.suffix!,
                const SizedBox(width: _spXs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordToggleButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onToggle;

  const _PasswordToggleButton({required this.visible, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: visible ? 'Hide password' : 'Show password',
      child: Tooltip(
        message: visible ? 'Hide password' : 'Show password',
        child: InkWell(
          onTap: onToggle,
          customBorder: const StadiumBorder(),
          child: Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: _spSm),
            child: Icon(
              visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 20,
              color: _labelSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
