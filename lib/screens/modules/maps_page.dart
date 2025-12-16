// lib/screens/modules/maps_page.dart
import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloaded Maps")),
      body: const Center(
        child: Text(
          "No maps downloaded (demo)",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
