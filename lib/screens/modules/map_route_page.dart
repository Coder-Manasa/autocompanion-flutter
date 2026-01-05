import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapRoutePage extends StatelessWidget {
  final String start;
  final String destination;

  const MapRoutePage({
    super.key,
    required this.start,
    required this.destination,
  });

  Future<void> _openInBrowser() async {
    final url =
        "https://www.google.com/maps/dir/?api=1&origin=$start&destination=$destination&travelmode=driving";

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ WEB / DESKTOP SAFE HANDLING
    if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android)) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Route Map",
            style: TextStyle(color: Color(0xFFD4AF37)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text("Open in Google Maps"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            onPressed: _openInBrowser,
          ),
        ),
      );
    }

    // ✅ ANDROID ONLY (NO RED SCREEN)
    return Scaffold(
      appBar: AppBar(title: const Text("Route Map")),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(12.9716, 77.5946),
          zoom: 6,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
