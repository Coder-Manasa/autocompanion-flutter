// lib/screens/notifications_page.dart
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "🔔 No notifications yet",
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
    );
  }
}
