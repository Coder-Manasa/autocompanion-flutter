// lib/screens/home/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../widgets/pulsing_icon_badge.dart';

// Existing pages
import '../modules/document_storage_page.dart';
import '../modules/service_page.dart';
import '../modules/ai_tour_page.dart';
import '../modules/maps_page.dart';
import '../modules/emergency_page.dart';
import '../modules/driving_history_page.dart';

// NEW PREMIUM OCR SCANNER PAGE
import '../modules/vehicle_doc_scanner_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // 🔥 PRINT TOKEN TO DEBUG CONSOLE
  Future<String?> _getFreshToken() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ No user logged in");
      return null;
    }

    final token = await user.getIdToken(true);
    print("\n🔥🔥 NEW FIREBASE TOKEN 🔥🔥\n$token\n");

    return token;
  }

  // 🔥 COPY TOKEN TO CLIPBOARD + SNACKBAR
  Future<void> _copyToken(BuildContext context) async {
    final token = await _getFreshToken();
    if (token == null) return;

    await Clipboard.setData(ClipboardData(text: token));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: const Text(
          "Firebase token copied!",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email ?? user?.phoneNumber ?? "User";

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF050509), Color(0xFF12002F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // MAIN CONTENT
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // USER EMAIL BAR
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            username,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const PulsingIconBadge(
                        child: Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "My Garage Modules",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.blueAccent, blurRadius: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // MODULE GRID
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      // NEW PREMIUM OCR SCANNER
                      _moduleCard(
                        context,
                        icon: Icons.document_scanner_rounded,
                        title: "Scan Vehicle Docs",
                        page: const VehicleDocScannerPage(),
                      ),

                      _moduleCard(
                        context,
                        icon: Icons.description,
                        title: "Document Storage",
                        page: const DocumentStoragePage(),
                      ),
                      _moduleCard(
                        context,
                        icon: Icons.build,
                        title: "Service & Maintenance",
                        page: const ServicePage(),
                      ),
                      _moduleCard(
                        context,
                        icon: Icons.map,
                        title: "AI Tour Planner",
                        page: const AITourPage(),
                      ),
                      _moduleCard(
                        context,
                        icon: Icons.download,
                        title: "Downloaded Maps",
                        page: const MapsPage(),
                      ),
                      _moduleCard(
                        context,
                        icon: Icons.emergency,
                        title: "Emergency Help",
                        page: const EmergencyPage(),
                      ),
                      _moduleCard(
                        context,
                        icon: Icons.alt_route,
                        title: "Driving History",
                        page: const DrivingHistoryPage(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),

            // 🔥 TOKEN PANEL (TOP RIGHT)
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade800,
                    ),
                    onPressed: () => _getFreshToken(),
                    child: const Text("Print Token"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () => _copyToken(context),
                    child: const Text("Copy Token"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MODULE CARD BUILDER
  Widget _moduleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF4A148C)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.35),
              blurRadius: 14,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PulsingIconBadge(
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
