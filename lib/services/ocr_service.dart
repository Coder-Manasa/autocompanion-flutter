import 'dart:convert';
import 'package:http/http.dart' as http;

class OCRService {
  // ✅ CHANGE THIS URL TO YOUR DEPLOYED OCR BACKEND
  static const String _ocrUrl =
      "https://YOUR-OCR-BACKEND.onrender.com/ocr-url";

  static Future<Map<String, dynamic>> scanDocument(
    String imageUrl,
    String docType,
  ) async {
    final uri = Uri.parse(_ocrUrl);

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

      // ❌ Server error
      if (response.statusCode != 200) {
        return {
          "success": false,
          "expiry_date": "Not detected",
          "extracted_text": "Server error: ${response.body}",
        };
      }

      // ✅ Valid OCR response
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
