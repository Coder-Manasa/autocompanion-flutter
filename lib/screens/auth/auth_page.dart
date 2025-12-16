import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../screens/home/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool loadingGoogle = false;
  bool loadingEmail = false;
  bool loadingPhone = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool otpSent = false;
  String? verificationId;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    phoneCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }


  // ==========================================================
  //                    GOOGLE SIGN-IN
  // ==========================================================
  Future<void> _signInWithGoogle() async {
    setState(() => loadingGoogle = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => loadingGoogle = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _goHome();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-in failed: $e")),
      );
    }

    setState(() => loadingGoogle = false);
  }

  // ==========================================================
  //                    EMAIL LOGIN
  // ==========================================================
  Future<void> _loginEmail() async {
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
      _error("Registered successfully! Now login.");
    } on FirebaseAuthException catch (e) {
      _error(e.message ?? "Registration failed");
    }
    setState(() => loadingEmail = false);
  }

  // ==========================================================
  //                    PHONE LOGIN (OTP)
  // ==========================================================
  Future<void> _sendOTP() async {
    setState(() => loadingPhone = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneCtrl.text.trim(),
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _goHome();
        },
        verificationFailed: (e) {
          _error(e.message ?? "Verification failed");
        },
        codeSent: (id, _) {
          setState(() {
            otpSent = true;
            verificationId = id;
          });
          _error("OTP Sent!");
        },
        codeAutoRetrievalTimeout: (id) => verificationId = id,
      );
    } catch (e) {
      _error("Error sending OTP");
    }

    setState(() => loadingPhone = false);
  }

  Future<void> _verifyOTP() async {
    setState(() => loadingPhone = true);

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpCtrl.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(cred);

      _goHome();
    } catch (e) {
      _error("Invalid OTP");
    }

    setState(() => loadingPhone = false);
  }

  // ==========================================================
  //                    HELPERS
  // ==========================================================
  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // ==========================================================
  //                     UI SECTION
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050509), Color(0xFF1A0035)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "AutoCompanion Login",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // --------------------------------------------------
              // EMAIL LOGIN
              // --------------------------------------------------
              _sectionTitle("Email Login"),
              TextField(controller: emailCtrl, decoration: _input("Email")),
              const SizedBox(height: 10),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: _input("Password"),
              ),
              const SizedBox(height: 10),
              _button("Login", loadingEmail, _loginEmail),
              TextButton(
                onPressed: _registerEmail,
                child: const Text("Create Account"),
              ),

              const Divider(color: Colors.white38, height: 40),

              // --------------------------------------------------
              // PHONE LOGIN
              // --------------------------------------------------
              _sectionTitle("Phone Login"),
              TextField(controller: phoneCtrl, decoration: _input("Phone +91")),
              const SizedBox(height: 10),

              if (otpSent)
                TextField(controller: otpCtrl, decoration: _input("Enter OTP")),

              const SizedBox(height: 10),

              otpSent
                  ? _button("Verify OTP", loadingPhone, _verifyOTP)
                  : _button("Send OTP", loadingPhone, _sendOTP),

              const Divider(color: Colors.white38, height: 40),

              // --------------------------------------------------
              // GOOGLE SIGN-IN
              // --------------------------------------------------
              _sectionTitle("Or continue with"),
              _googleButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _button(String title, bool loading, Function() onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

 Widget _googleButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: loadingGoogle ? null : _signInWithGoogle,
      icon: loadingGoogle
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : const Icon(Icons.g_mobiledata, size: 32, color: Colors.white),
      label: const Text("Sign in with Google"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white10,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
}