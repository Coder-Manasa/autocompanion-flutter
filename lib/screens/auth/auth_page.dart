import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/home/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool loadingEmail = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  // ==========================================================
  //                    EMAIL LOGIN
  // ==========================================================
  Future<void> _loginEmail() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      _error("Please enter email and password");
      return;
    }

    setState(() => loadingEmail = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      _goHome();
    } on FirebaseAuthException catch (e) {
      _error(e.message ?? "Login failed");
    }

    setState(() => loadingEmail = false);
  }

  Future<void> _registerEmail() async {
    setState(() => loadingEmail = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
      _error("Account created. Please login.");
    } on FirebaseAuthException catch (e) {
      _error(e.message ?? "Registration failed");
    }
    setState(() => loadingEmail = false);
  }

  // ==========================================================
  //                    HELPERS
  // ==========================================================
  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(msg, style: const TextStyle(color: Color(0xFFD4AF37))),
      ),
    );
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBFAF6F)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.6),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
      ),
    );
  }

  // ==========================================================
  //                     UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0E0A02)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // ------------------ DEER IMAGE ------------------
              Image.asset(
                'assets/image/deer.jpg',
                height: 180,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              const Text(
                "AutoCompanion",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37), // GOLD
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 40),

              // ------------------ EMAIL ------------------
              TextField(
                controller: emailCtrl,
                focusNode: emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(passFocus);
                },
                style: const TextStyle(color: Colors.white),
                decoration: _input("Email"),
              ),

              const SizedBox(height: 15),

              // ------------------ PASSWORD ------------------
              TextField(
                controller: passCtrl,
                focusNode: passFocus,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _loginEmail(),
                style: const TextStyle(color: Colors.white),
                decoration: _input("Password"),
              ),

              const SizedBox(height: 25),

              // ------------------ LOGIN BUTTON ------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loadingEmail ? null : _loginEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loadingEmail
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // ------------------ REGISTER ------------------
              TextButton(
                onPressed: loadingEmail ? null : _registerEmail,
                child: const Text(
                  "Create Account",
                  style: TextStyle(color: Color(0xFFBFAF6F)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
