import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentUploadService {
  static Future<String?> uploadDocument(
    XFile file,
    String folder,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.name}";
      final path = "$folder/$fileName";

      // ✅ WEB + MOBILE SAFE
      final Uint8List bytes = await file.readAsBytes();

      await supabase.storage
          .from('vehicle-docs')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      // 🔥 RETURN PUBLIC URL
      return supabase.storage
          .from('vehicle-docs')
          .getPublicUrl(path);
    } catch (e) {
      debugPrint("❌ Upload failed: $e");
      return null;
    }
  }
}
