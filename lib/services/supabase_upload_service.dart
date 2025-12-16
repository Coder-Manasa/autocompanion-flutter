import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUploadService {
  static Future<String?> uploadDocument(File file, String folder) async {
    try {
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}";

      final storagePath = "$folder/$fileName";

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Upload original full-quality file
      await Supabase.instance.client.storage
          .from("vehicle-docs")
          .uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: false,
          contentType: "image/jpeg",
        ),
      );

      // ⭐ FIX: Get FULL QUALITY high-resolution URL
      final signedUrl = await Supabase.instance.client.storage
          .from("vehicle-docs")
          .createSignedUrl(
            storagePath,
            3600, // valid for 1 hour
          );

      print("SIGNED URL → $signedUrl");

      return signedUrl; // return correct URL

    } catch (e) {
      print("Supabase Upload Error: $e");
      return null;
    }
  }
}
