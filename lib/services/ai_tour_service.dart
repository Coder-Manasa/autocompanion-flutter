import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AITourService {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5001";
    }
    return "http://10.0.2.2:5001"; // Android emulator
  }

  static Future<String> generateTour(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/ai-tour-plan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded["success"] == true) {
      return decoded["itinerary"];
    } else {
      throw Exception(decoded["error"] ?? "AI failed");
    }
  }
}
