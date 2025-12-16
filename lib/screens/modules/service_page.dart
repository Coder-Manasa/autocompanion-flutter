// lib/screens/modules/service_page.dart
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final List<Map<String, String>> services = [];

  final dateCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void dispose() {
    dateCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void addService() {
    final date = dateCtrl.text.trim();
    final desc = descCtrl.text.trim();

    if (date.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Provide date and details")),
      );
      return;
    }

    setState(() {
      services.insert(0, {"date": date, "desc": desc});
    });

    dateCtrl.clear();
    descCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛠️ Service & Maintenance")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              "Add service record (demo — local only)",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: dateCtrl,
              decoration: InputDecoration(
                hintText: "Service date (e.g., 2025-11-20)",
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                hintText: "Details (e.g., oil change, wheel alignment)",
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: addService,
              child: const Text("Add Record"),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            Expanded(
              child: services.isEmpty
                  ? const Center(
                      child: Text(
                        "No service records added",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (_, i) {
                        final s = services[i];
                        return ListTile(
                          title: Text(
                            s["desc"]!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            s["date"]!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          leading:
                              const Icon(Icons.build, color: Colors.white70),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
