// lib/screens/home/home_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'profile_page.dart';
import '../notifications_page.dart';
import '../modules/driving_history_page.dart';
import 'package:http/http.dart' as http;
import '../../core/auth_helper.dart';
import '../../core/backend_config.dart';

class HomePage extends StatefulWidget {
  void printUserToken() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print("❌ User not logged in");
    return;
  }

  try {
    String? token = await user.getIdToken(true); // Force refresh
    print("🔐 FIREBASE TOKEN:");
    print(token);
  } catch (e) {
    print("🔥 ERROR GETTING TOKEN: $e");
  }
}

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  late final List<Widget> _pages = [
    const DashboardPage(),
    const NotificationsPage(),
    const DrivingHistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: index == 0
          ? null
          : AppBar(
              title: const Text("AutoCompanion"),
              centerTitle: true,
              backgroundColor: const Color(0xFF050509),
            ),
      body: _pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        backgroundColor: const Color(0xFF050509),
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
Future<void> testBackend() async {
  final token = await AuthHelper.getToken();
  if (token == null) {
    print("User not logged in!");
    return;
  }

  final url = Uri.parse("${BackendConfig.activeBaseUrl}/api/test/secure");

  final res = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  print("STATUS: ${res.statusCode}");
  print("BODY: ${res.body}");
}
void printUserToken() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print("User not logged in");
    return;
  }

  String? token = await user.getIdToken(true);
  print("USER TOKEN: $token");
}
