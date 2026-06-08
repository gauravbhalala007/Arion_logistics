// /lib/Screens/signup_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';

// --- Codriver Design Tokens (from CODRIVER_STYLEGUIDE.md) ---
const Color _codriverGreen = Color(0xFF00B287);
const Color _codriverDeep = Color(0xFF006047);
const Color _green50 = Color(0xFFE6F8F2);

const Color _background = Color(0xFFFAFAFA);
const Color _surface = Color(0xFFF2F2F7);
const Color _surfaceElevated = Color(0xFFFFFFFF);
const Color _separator = Color(0xFFC6C6C8);
const Color _label = Color(0xFF000000);
const Color _labelSecondary = Color(0x993C3C43);
const Color _labelTertiary = Color(0x4D3C3C43);

const Color _error = Color(0xFFFF3B30);
const Color _success = Color(0xFF34C759);

const double _spXs = 8;
const double _spSm = 12;
const double _spMd = 16;
const double _spLg = 20;
const double _spXl = 24;
const double _spXxl = 32;

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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  final _firstFocus = FocusNode();
  final _lastFocus = FocusNode();
  final _companyFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _busy = false;
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  String? _errorMessage;
  String? _infoMessage;

  static const double _splitBreakpoint = 900;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _company.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    _companyFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // --- Auth ---

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();

    final first = _first.text.trim();
    final last = _last.text.trim();
    final company = _company.text.trim();
    final email = _email.text.trim();
    final p1 = _pass.text;
    final p2 = _confirm.text;

    if (first.isEmpty ||
        last.isEmpty ||
        company.isEmpty ||
        email.isEmpty ||
        p1.isEmpty ||
        p2.isEmpty) {
      _showError('Please fill all fields before continuing.');
      return;
    }

    if (p1 != p2) {
      _showError('Passwords do not match.');
      return;
    }

    if (p1.length < 6) {
      _showError('Password must be at least 6 characters long.');
      return;
    }

    setState(() => _busy = true);
    try {
      await AuthService.register(
        firstName: first,
        lastName: last,
        email: email,
        password: p1,
        companyName: company,
      );
      if (!mounted) return;
      // Nutzer ist nach der Registrierung bereits angemeldet → direkt in die
      // App (30-Tage-Test läuft ab jetzt).
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } on FirebaseAuthException catch (e) {
      _showError(_mapSignupError(e));
    } catch (_) {
      _showError(
        'We could not create your account right now. Please try again in a moment.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mapSignupError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists for that email address.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'Network connection failed. Check your internet and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      default:
        return 'Signup failed. Please review your details and try again.';
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

  void _onFieldChanged(String _) {
    if (_errorMessage != null || _infoMessage != null) _clearMessages();
  }

  // --- UI ---

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
            _buildSignupCard(),
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

  Widget _buildSignupCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create your account', textAlign: TextAlign.center, style: _title1),
          const SizedBox(height: _spXs),
          Text(
            'Use your Codriver details to get started',
            textAlign: TextAlign.center,
            style: _subheadline.copyWith(color: _labelSecondary),
          ),
          const SizedBox(height: _spXl),

          _buildStatusCard(),

          _CodriverTextField(
            controller: _first,
            focusNode: _firstFocus,
            hintText: 'First name',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline_rounded,
            onChanged: _onFieldChanged,
            onSubmitted: (_) => _lastFocus.requestFocus(),
          ),
          const SizedBox(height: _spMd),

          _CodriverTextField(
            controller: _last,
            focusNode: _lastFocus,
            hintText: 'Last name',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline_rounded,
            onChanged: _onFieldChanged,
            onSubmitted: (_) => _companyFocus.requestFocus(),
          ),
          const SizedBox(height: _spMd),

          _CodriverTextField(
            controller: _company,
            focusNode: _companyFocus,
            hintText: 'Company name',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.business_outlined,
            onChanged: _onFieldChanged,
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          const SizedBox(height: _spMd),

          _CodriverTextField(
            controller: _email,
            focusNode: _emailFocus,
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.mail_outline_rounded,
            onChanged: _onFieldChanged,
            onSubmitted: (_) => _passFocus.requestFocus(),
          ),
          const SizedBox(height: _spMd),

          _CodriverTextField(
            controller: _pass,
            focusNode: _passFocus,
            hintText: 'Your password',
            obscureText: !_passwordVisible,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.lock_outline_rounded,
            onChanged: _onFieldChanged,
            onSubmitted: (_) => _confirmFocus.requestFocus(),
            suffix: _PasswordToggleButton(
              visible: _passwordVisible,
              onToggle: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
          ),
          const SizedBox(height: _spMd),

          _CodriverTextField(
            controller: _confirm,
            focusNode: _confirmFocus,
            hintText: 'Confirm password',
            obscureText: !_confirmVisible,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline_rounded,
            onChanged: _onFieldChanged,
            onSubmitted: (_) => _submit(),
            suffix: _PasswordToggleButton(
              visible: _confirmVisible,
              onToggle: () =>
                  setState(() => _confirmVisible = !_confirmVisible),
            ),
          ),
          const SizedBox(height: _spLg),

          _buildPrimaryButton(),
          const SizedBox(height: _spMd),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: _footnote.copyWith(color: _labelSecondary),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
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
                  'Login',
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
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _busy ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _codriverGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _codriverGreen.withOpacity(0.5),
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
          shadowColor: _codriverGreen.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: _spXxl),
          textStyle: _headline,
        ),
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
                  Text('Create account', style: _headline),
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
      padding: const EdgeInsets.symmetric(
        horizontal: _spMd,
        vertical: _spSm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
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
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const _CodriverTextField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<_CodriverTextField> createState() => _CodriverTextFieldState();
}

class _CodriverTextFieldState extends State<_CodriverTextField> {
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        border: Border.all(
          color: focused ? _codriverGreen : _separator.withOpacity(0.0),
          width: focused ? 1.5 : 1,
        ),
      ),
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
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: _codriverGreen,
              style: _body,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hintText,
                hintStyle: _body.copyWith(color: _labelTertiary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
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
    );
  }
}

class _PasswordToggleButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onToggle;

  const _PasswordToggleButton({
    required this.visible,
    required this.onToggle,
  });

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
              visible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: _labelSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
