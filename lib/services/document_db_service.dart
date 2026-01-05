import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentDBService {
  static Future<void> saveDocument({
    required String userId,
    required String docType,
    required String fileUrl,
    required String expiryDate,
  }) async {
    final supabase = Supabase.instance.client;

    await supabase.from('vehicle_documents').insert({
      'user_id': userId,
      'doc_type': docType,
      'file_url': fileUrl, // ✅ PUBLIC URL
      'expiry_date': expiryDate,
    });
  }
}
