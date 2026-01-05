import 'package:flutter/material.dart';

class SavedTripDetailPage extends StatelessWidget {
  final String title;
  final String itinerary;

  const SavedTripDetailPage({
    super.key,
    required this.title,
    required this.itinerary,
  });

  static const Color bg = Colors.black;
  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF0D0D0D);

  @override
  Widget build(BuildContext context) {
    final sections = itinerary.split(RegExp(r'\n\s*\n'));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: gold),
        title: Text(title, style: const TextStyle(color: gold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sections.map((s) => _card(s)).toList(),
        ),
      ),
    );
  }

  Widget _card(String text) {
    IconData icon = Icons.event_note;
    final t = text.toLowerCase();
    if (t.contains("morning")) icon = Icons.wb_sunny;
    if (t.contains("afternoon")) icon = Icons.wb_cloudy;
    if (t.contains("evening")) icon = Icons.nights_stay;
    if (t.contains("night")) icon = Icons.hotel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.replaceAll('*', ''),
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
