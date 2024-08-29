import 'dart:async';

import 'package:al_bastah/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  Timer? _emailVerificationTimer;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailVerificationTimer?.cancel();
    super.dispose();
  }
  //  again, this must not be here, but for testing purposes only, otherwise, Must be moved within a proper statemangement solution such as BloC/Riverpod/Provider etc.
  void _startEmailVerificationCheck() {
    _emailVerificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (user?.emailVerified ?? false) {
        timer.cancel();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(noteRoute, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: const Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    centerTitle: true,
    backgroundColor: Colors.teal,
  ),
  body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _email,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _password,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final email = _email.text;
            final password = _password.text;
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser?.emailVerified ?? false) {
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(noteRoute, (route) => false);
              } else {
                await currentUser?.sendEmailVerification();
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
              }
            } on FirebaseAuthException catch (e) {
              if (e.code == "wrong-password") {
                await showErrorDialog(context, 'Incorrect password');
              } else if (e.code == "user-not-found") {
                await showErrorDialog(context, 'User not found');
              } else {
                await showErrorDialog(context, 'Error code ${e.code}, Please contact support with the error code.');
              }
            } catch (e) {
              await showErrorDialog(context, 'Error code ${e.toString()}, Please contact support');
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Login', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
          },
          child: const Text('Register Here!', style: TextStyle(fontSize: 16, color: Colors.teal)),
        ),
      ],
    ),
  ),
);

  }
}
