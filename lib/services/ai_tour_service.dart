import 'dart:convert';
import 'package:http/http.dart' as http;

class AITourService {
  static const String baseUrl = "http://192.168.0.105:5001"; // YOUR BACKEND IP

  static Future<String> generateTourPlan(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/ai-tour-plan");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return jsonBody["itinerary"] ?? "No itinerary generated.";
    } else {
      throw Exception(
        "Failed: ${response.statusCode}\n${response.body}",
      );
    }
  }
}
