import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

const Color primaryTeal = Color(0xFF50B39E);
const Color backgroundLight = Color(0xFFF5F5F5);

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool _busy = false;
  bool _passwordVisible = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();

    final first = _first.text.trim();
    final last = _last.text.trim();
    final email = _email.text.trim();
    final p1 = _pass.text;
    final p2 = _confirm.text;

    if (first.isEmpty ||
        last.isEmpty ||
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
      );
      if (!mounted) return;
      _showInfo('Verification email sent. Please check your inbox.');
      Navigator.of(context).pushReplacementNamed('/verify-email');
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

  Widget _buildStatusCard() {
    final message = _errorMessage ?? _infoMessage;
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = _errorMessage != null;
    final borderColor = isError
        ? const Color(0xFFF3B0B0)
        : const Color(0xFF9ED9C8);
    final bgColor = isError
        ? const Color(0xFFFFF4F4)
        : const Color(0xFFF2FBF7);
    final iconColor = isError ? const Color(0xFFC24141) : primaryTeal;
    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? const Color(0xFF7F1D1D)
                    : const Color(0xFF155E4B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'assets/codriver_logo.png',
                    width: 350,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 60),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Use your CoDriver details to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildStatusCard(),
                        TextField(
                          controller: _first,
                          onChanged: (_) {
                            if (_errorMessage != null || _infoMessage != null) {
                              _clearMessages();
                            }
                          },
                          decoration: _getInputDecoration('First name'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _last,
                          onChanged: (_) {
                            if (_errorMessage != null || _infoMessage != null) {
                              _clearMessages();
                            }
                          },
                          decoration: _getInputDecoration('Last name'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) {
                            if (_errorMessage != null || _infoMessage != null) {
                              _clearMessages();
                            }
                          },
                          decoration: _getInputDecoration('Your email'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _pass,
                          obscureText: !_passwordVisible,
                          onChanged: (_) {
                            if (_errorMessage != null || _infoMessage != null) {
                              _clearMessages();
                            }
                          },
                          onSubmitted: (_) => _submit(),
                          decoration: _getInputDecoration(
                            'Your password',
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirm,
                          obscureText: true,
                          onChanged: (_) {
                            if (_errorMessage != null || _infoMessage != null) {
                              _clearMessages();
                            }
                          },
                          onSubmitted: (_) => _submit(),
                          decoration: _getInputDecoration(
                            'Confirm your password',
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _busy ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(
                            _busy ? 'Please wait…' : 'Create account',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushReplacementNamed('/login'),
                          child: const Text('Already have an account? Login.'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Kreativvwerk',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(
    String hintText, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
    );
  }
}
