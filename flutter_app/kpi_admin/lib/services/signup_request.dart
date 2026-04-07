// screens/signup_request.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class SignUpRequestPage extends StatefulWidget {
  const SignUpRequestPage({super.key});

  @override
  State<SignUpRequestPage> createState() => _SignUpRequestPageState();
}

class _SignUpRequestPageState extends State<SignUpRequestPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _station = TextEditingController();

  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      await cred.user!.updateDisplayName(_name.text.trim());
      await cred.user!.sendEmailVerification();

      // create user document with status=pending
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'displayName': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'company': _company.text.trim(),
        'stationCode': _station.text.trim().toUpperCase(),
        'role': 'user',
        'status': 'pending', // <- admin must flip to 'active'
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.t('signup_request_success'))));
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    t.t('signup_request_title'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: t.t('signup_request_full_name'),
                    ),
                    validator: (v) => v!.trim().isEmpty
                        ? t.t('signup_request_required')
                        : null,
                  ),
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(
                      labelText: t.t('signup_request_email'),
                    ),
                    validator: (v) => v!.contains('@')
                        ? null
                        : t.t('signup_request_valid_email'),
                  ),
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: t.t('signup_request_password'),
                    ),
                    obscureText: true,
                    validator: (v) => v!.length < 6
                        ? t.t('signup_request_password_min')
                        : null,
                  ),
                  TextFormField(
                    controller: _phone,
                    decoration: InputDecoration(
                      labelText: t.t('signup_request_phone'),
                    ),
                  ),
                  TextFormField(
                    controller: _company,
                    decoration: InputDecoration(
                      labelText: t.t('signup_request_company'),
                    ),
                  ),
                  TextFormField(
                    controller: _station,
                    decoration: InputDecoration(
                      labelText: t.t('signup_request_station_code'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(
                      _busy
                          ? t.t('signup_request_submitting')
                          : t.t('signup_request_submit'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
