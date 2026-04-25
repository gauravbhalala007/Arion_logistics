// /lib/Screens/login_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart'; // Ensure this path is correct

// Define the custom colors used in the mockup
const Color primaryTeal = Color(0xFF50B39E);
const Color backgroundLight = Color(0xFFF5F5F5);
const Color coColor = Color(0xFF3B5B53); // Darker green for 'CO'

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // --- Utility Methods (Auth and Snack) ---

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
      // (On Flutter web, prompts can still be browser-dependent.)
      TextInput.finishAutofillContext(shouldSave: true);

      if (!mounted) return;
      _clearMessages();

      // 🔹 After successful sign-in, go to the root route where AuthGate is
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

  Future<void> _reset() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _showError('Enter your email address first.');
      return;
    }
    try {
      await AuthService.resetPassword(email);
      _showInfo('Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      _showError(_mapResetError(e));
    } catch (_) {
      _showError(
        'We could not send the password reset email right now. Please try again.',
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

  Widget _buildStatusCard() {
    final message = _errorMessage ?? _infoMessage;
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    final isError = _errorMessage != null;
    final borderColor = isError
        ? const Color(0xFFF3B0B0)
        : const Color(0xFF9ED9C8);
    final bgColor = isError ? const Color(0xFFFFF4F4) : const Color(0xFFF2FBF7);
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

  // --- Build Method with Mockup UI ---

  @override
  Widget build(BuildContext context) {
    // The theme object is still required for the form styling helper
    // final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                // 1. Branding / Logo Section -- UPDATED FOR IMAGE LOGO ONLY
                const SizedBox(height: 60), // Increased top space slightly
                Center(
                  child: Column(
                    children: [
                      // *** IMAGE ASSET LOGO ***
                      // Replace 'assets/codriver_logo.png' with your actual image path.
                      Image.asset(
                        'assets/codriver_logo.png',
                        width:
                            350, // Adjust size as needed for your full logo image
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60), // Space before the card
                // 2. Login Form Card (Remains the same)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: AutofillGroup(
                      onDisposeAction: AutofillContextAction.commit,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Welcome back!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildStatusCard(),

                          // Email Input Field
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.username],
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_errorMessage != null ||
                                  _infoMessage != null) {
                                _clearMessages();
                              }
                            },
                            decoration: _getInputDecoration('Your email'),
                          ),
                          const SizedBox(height: 16),

                          // Password Input Field
                          TextField(
                            controller: _password,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onChanged: (_) {
                              if (_errorMessage != null ||
                                  _infoMessage != null) {
                                _clearMessages();
                              }
                            },
                            onSubmitted: (_) => _submit(),
                            decoration: _getInputDecoration('Your password'),
                          ),
                          const SizedBox(height: 32),

                          // Login Button ("Continue")
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
                            child: Text(_busy ? 'Please wait…' : 'Continue'),
                          ),

                          const SizedBox(height: 16),

                          // Forgot Password Link
                          TextButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).pushReplacementNamed('/signup'),
                            child: const Text('New here?? SignUp.'),
                          ),
                          TextButton(
                            onPressed: _reset,
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 3. Footer Branding (English company name)
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

  // Helper function for input field decoration
  InputDecoration _getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
        borderSide: BorderSide(color: primaryTeal, width: 2),
      ),
    );
  }
}
