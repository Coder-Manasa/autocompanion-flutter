// lib/screens/modules/driving_history_page.dart
import 'package:flutter/material.dart';

class DrivingHistoryPage extends StatelessWidget {
  const DrivingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛣️ Driving History")),
      body: const Center(
        child: Text(
          "See your trip history (demo).",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
