import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../modules/document_storage_page.dart';
import '../modules/service_page.dart';
import '../modules/notification_page.dart';
import '../modules/ai_tour_page.dart'; // ✅ MUST BE THIS PATH

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final displayName =
        Supabase.instance.client.auth.currentUser?.email ?? "User";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Welcome, $displayName",
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
          ),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _tile(
            context,
            title: "Document Scan",
            icon: Icons.document_scanner,
            onTap: () {},
          ),
          _tile(
            context,
            title: "Document Storage",
            icon: Icons.folder,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DocumentStoragePage(),
                ),
              );
            },
          ),
          _tile(
            context,
            title: "Service & Maintenance",
            icon: Icons.build,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ServicePage(),
                ),
              );
            },
          ),
          _tile(
            context,
            title: "AI Trip Planner", // ✅ FIXED
            icon: Icons.travel_explore,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AITourPage(),
                ),
              );
            },
          ),
          _tile(
            context,
            title: "Notifications",
            icon: Icons.notifications,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: const Color(0xFFD4AF37).withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4AF37),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 12),
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
      ),
    );
  }
}
