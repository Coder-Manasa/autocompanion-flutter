import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class DocumentUploadService {
  static Future<String?> uploadDocument(XFile file, String folder) async {
    try {
      final supabase = Supabase.instance.client;

      final fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.name}";

      final path = "$folder/$fileName";

      if (kIsWeb) {
        // 🌐 WEB → upload bytes
        final Uint8List bytes = await file.readAsBytes();

        await supabase.storage.from("vehicle-docs").uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: false,
            contentType: "image/jpeg",
          ),
        );
      } else {
        // 📱 ANDROID / IOS → upload file
        final File localFile = File(file.path);

        await supabase.storage.from("vehicle-docs").upload(
          path,
          localFile,
          fileOptions: const FileOptions(
            upsert: false,
            contentType: "image/jpeg",
          ),
        );
      }

      // ✅ Always return public URL
      final url = supabase.storage.from("vehicle-docs").getPublicUrl(path);
      print("UPLOAD SUCCESS → $url");

      return url;
    } on StorageException catch (e) {
      print("Supabase Storage Error: ${e.message}");
      return null;
    } catch (e) {
      print("General Upload Error: $e");
      return null;
    }
  }
}
