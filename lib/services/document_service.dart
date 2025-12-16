import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class DocumentUploadService {
  static Future<String?> uploadDocument(File file, String folder) async {
    try {
      final supabase = Supabase.instance.client;

      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";

      final path = "$folder/$fileName";

      // ---- Upload file in original quality ----
      final bytes = await file.readAsBytes();

      await supabase.storage.from("vehicle-docs").uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          upsert: false,
          contentType: "image/jpeg",
        ),
      );

      // ---- FIX: Generate FULL QUALITY SIGNED URL ----
      final signedUrl = await supabase.storage
          .from("vehicle-docs")
          .createSignedUrl(path, 3600); // valid for 1 hour

      print("SIGNED URL → $signedUrl");

      return signedUrl;

    } on StorageException catch (e) {
      print("Supabase Storage Error: ${e.message}");
      return null;
    } catch (e) {
      print("General Upload Error: $e");
      return null;
    }
  }
}
