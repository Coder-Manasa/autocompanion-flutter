import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'saved_trip_detail_page.dart';

class SavedTripsPage extends StatelessWidget {
  const SavedTripsPage({super.key});

  static const Color bg = Colors.black;
  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF0D0D0D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: const IconThemeData(color: gold),
        title: const Text(
          "Saved Trips",
          style: TextStyle(color: gold),
        ),
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('ai_trips')
            .select()
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips = snapshot.data as List;

          if (trips.isEmpty) {
            return const Center(
              child: Text(
                "No saved trips",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final t = trips[index];
              final title =
                  "${t['start_location']} → ${t['destination']}";

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavedTripDetailPage(
                        title: title,
                        itinerary: t['itinerary'],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t['itinerary']
                                .toString()
                                .split('\n')
                                .first ??
                            "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
