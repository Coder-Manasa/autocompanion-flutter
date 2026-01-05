import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../core/auth_helper.dart';
import '../../core/backend_config.dart';
import '../modules/vehicle_doc_scanner_page.dart';
import '../modules/document_storage_page.dart';
import '../modules/service_page.dart';
import '../modules/notification_page.dart';
import '../modules/ai_tour_page.dart'; // ✅ ADDED

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> printUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await user.getIdToken(true);
    print("🔐 TOKEN: $token");
  }

  Future<void> testBackend() async {
    final token = await AuthHelper.getToken();
    if (token == null) return;

    final url =
        Uri.parse("${BackendConfig.activeBaseUrl}/api/test/secure");

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

  Widget featureBox(
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white70),
          onPressed: () {
            printUserToken();
            testBackend();
          },
        ),
        centerTitle: true,
        title: const Text(
          "Welcome to AutoCompanion",
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/image/deer.jpg', height: 120),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: featureBox(
                    "Document Scan",
                    Icons.document_scanner,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentScannerPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: featureBox(
                    "Document Storage",
                    Icons.folder,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DocumentStoragePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: featureBox(
                    "Service & Maintenance",
                    Icons.build,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServicePage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: featureBox(
                    "Notifications",
                    Icons.notifications,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: featureBox(
                    "AI Trip Planner",
                    Icons.travel_explore,
                    onTap: () { // ✅ FIX
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AITourPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: featureBox(
                    "Maps",
                    Icons.map,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "AutoCompanion • Smart Vehicle Assistant",
              style: TextStyle(
                color: Colors.white54,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
