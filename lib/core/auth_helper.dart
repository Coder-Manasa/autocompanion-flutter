import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<String?> getToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken(true); // refresh token
  }
}
