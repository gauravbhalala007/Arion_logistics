// /lib/Screens/login_page.dart

import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // --- Utility Methods (Auth and Snack) ---

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AuthService.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      // 🔹 After successful sign-in, go to the root route where AuthGate is
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _snack('Enter your email first.');
      return;
    }
    try {
      await AuthService.resetPassword(email);
      _snack('Password reset email sent.');
    } catch (e) {
      _snack(e.toString());
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
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
                        width: 250, // Adjust size as needed for your full logo image
                        height: 100, 
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome back!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 24),
                        
                        // Email Input Field
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _getInputDecoration('Your email'), 
                        ),
                        const SizedBox(height: 16),

                        // Password Input Field
                        TextField(
                          controller: _password,
                          obscureText: true,
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
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'),
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
                
                const SizedBox(height: 40),

                // 3. Footer Branding (English company name)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'K kreativvwerk', 
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
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