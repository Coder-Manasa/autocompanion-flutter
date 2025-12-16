// lib/screens/home/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("👤", style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text(
            user?.email ?? user?.phoneNumber ?? "User",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
