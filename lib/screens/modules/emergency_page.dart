// lib/screens/modules/emergency_page.dart
import 'package:flutter/material.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🚨 Emergency Help")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              "Emergency contacts & quick actions (demo)",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text("Police"),
              subtitle: const Text("Dial emergency services"),
              trailing: ElevatedButton(
                onPressed: () {
                  _showSnack(context, "Dialing Police (simulated)");
                },
                child: const Text("Call"),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.call),
              title: const Text("Roadside Assistance"),
              subtitle: const Text("Tow or help"),
              trailing: ElevatedButton(
                onPressed: () {
                  _showSnack(
                    context,
                    "Requesting roadside assistance (simulated)",
                  );
                },
                child: const Text("Request"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
