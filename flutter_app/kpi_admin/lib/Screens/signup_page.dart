import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
    final first = _first.text.trim();
    final last = _last.text.trim();
    final email = _email.text.trim();
    final p1 = _pass.text;
    final p2 = _confirm.text;

    if (first.isEmpty || last.isEmpty || email.isEmpty || p1.isEmpty || p2.isEmpty) {
      _snack('Please fill all fields.');
      return;
    }
    if (p1 != p2) {
      _snack('Passwords do not match.');
      return;
    }

    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AuthService.register(
        firstName: first,
        lastName: last,
        email: email,
        password: p1,
      );
      if (!mounted) return;
      _snack('Verification email sent. Please check your inbox.');
      Navigator.of(context).pushReplacementNamed('/verify-email');
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 16),
                const Text('Create an account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name')),
                const SizedBox(height: 8),
                TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name')),
                const SizedBox(height: 8),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 8),
                TextField(controller: _confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(_busy ? 'Please wait…' : 'Create account'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text('Back to login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
