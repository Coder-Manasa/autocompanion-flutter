import 'dart:convert';
import 'package:http/http.dart' as http;

class OCRService {
  static Future<Map<String, dynamic>> scanDocument(
    String imageUrl,
    String docType,
  ) async {
    final uri = Uri.parse("http://192.168.0.105:5002/ocr-url");

    final payload = jsonEncode({
      "file_url": imageUrl,
      "doc_type": docType,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: payload,
      );

      // Server error
      if (response.statusCode != 200) {
        return {
          "success": false,
          "expiry_date": "Not detected",
          "extracted_text": "Server error: ${response.body}",
        };
      }
      // Parse valid response
      return jsonDecode(response.body);

    } catch (e) {
      return {
        "success": false,
        "expiry_date": "Not detected",
        "extracted_text": "Client error: $e",
      };
    }
  }
} 