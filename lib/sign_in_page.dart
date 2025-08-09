import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _signInEmail() async {
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _registerEmail() async {
    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Use the singleton and await initialization
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();           // clears cached account
      await googleSignIn.initialize();

      // Trigger authentication flow
      final googleUser = await googleSignIn.authenticate();
      if (googleUser == null) return; // user canceled

      // auth object is now synchronous
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, // ✅ only idToken now
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loading ? null : _signInEmail, child: const Text('Sign in')),
            TextButton(onPressed: _loading ? null : _registerEmail, child: const Text('Create account')),
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: _loading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }
}