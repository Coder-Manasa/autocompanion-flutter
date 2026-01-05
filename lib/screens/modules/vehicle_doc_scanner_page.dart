import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/document_upload_service.dart';
import '../../services/document_db_service.dart';

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
  XFile? _pickedFile;
  String? _fileName;

  bool _loading = false;
  bool _scanCompleted = false;
  bool _saving = false;

  String expiryDate = "";
  String documentType = "";
  String documentNumber = "";
  double confidence = 0;

  /// 🔗 BACKEND URL
  static const String BASE_URL = "http://127.0.0.1:5002";

  // ================= DOCUMENT TYPE =================
  String selectedDocType = "insurance";

  final List<Map<String, String>> docTypes = [
    {"label": "Insurance", "value": "insurance"},
    {"label": "RC Book", "value": "rc"},
    {"label": "PUC", "value": "puc"},
    {"label": "Driving Licence", "value": "dl"},
    {"label": "Other", "value": "others"},
  ];

  // =========================================================
  // PICK IMAGE
  // =========================================================
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _pickedFile = picked;
      _imageBytes = bytes;
      _fileName = picked.name;

      expiryDate = "";
      documentType = "";
      documentNumber = "";
      confidence = 0;

      _scanCompleted = false;
    });
  }

  // =========================================================
  // OCR API CALL
  // =========================================================
  Future<void> _scanDocument() async {
    if (_imageBytes == null) return;

    setState(() => _loading = true);

    try {
      final uri = Uri.parse("$BASE_URL/api/document/scan");

      final request = http.MultipartRequest("POST", uri)
        ..fields["doc_type"] = selectedDocType
        ..files.add(
          http.MultipartFile.fromBytes(
            "file",
            _imageBytes!,
            filename: _fileName ?? "document.jpg",
          ),
        );

      final streamed = await request.send();
      final response = await streamed.stream.bytesToString();

      final data = jsonDecode(response);

      if (data["success"] == true) {
        setState(() {
          expiryDate = data["expiry_date"] ?? "Not detected";
          documentType = data["document_type"] ?? selectedDocType;
          documentNumber = data["document_number"] ?? "Not detected";
          confidence = (data["confidence"] ?? 0).toDouble();
          _scanCompleted = true;
        });
      } else {
        _showError("Scan failed");
      }
    } catch (e) {
      _showError("OCR error");
    } finally {
      setState(() => _loading = false);
    }
  }

  // =========================================================
  // SAVE DOCUMENT (AFTER SCAN)
  // =========================================================
  Future<void> _saveDocument() async {
    if (_pickedFile == null) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1️⃣ Upload to Supabase Storage
      final fileUrl = await DocumentUploadService.uploadDocument(
        _pickedFile!,
        "${user.uid}/$documentType",
      );

      if (fileUrl == null) throw Exception("Upload failed");

      // 2️⃣ Save metadata to DB
      await DocumentDBService.saveDocument(
        userId: user.uid,
        docType: documentType,
        fileUrl: fileUrl,
        expiryDate: expiryDate,
      );

      // 3️⃣ Success popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Saved to ${documentType.toUpperCase()}",
            style: const TextStyle(color: Color(0xFFD4AF37)),
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  // =========================================================
  // UI HELPERS
  // =========================================================
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black,
        content: Text(
          msg,
          style: const TextStyle(color: Color(0xFFD4AF37)),
        ),
      ),
    );
  }

  BoxDecoration _goldCard() {
    return BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFD4AF37)),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Document Scanner",
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // IMAGE PREVIEW
            Container(
              height: 220,
              decoration: _goldCard(),
              child: _imageBytes == null
                  ? const Center(
                      child: Text(
                        "Select a document",
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // DOC TYPE
            DropdownButtonFormField<String>(
              value: selectedDocType,
              dropdownColor: Colors.black,
              decoration: const InputDecoration(
                labelText: "Document Type",
                labelStyle: TextStyle(color: Color(0xFFD4AF37)),
              ),
              style: const TextStyle(color: Colors.white),
              items: docTypes
                  .map(
                    (d) => DropdownMenuItem(
                      value: d["value"],
                      child: Text(d["label"]!),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() => selectedDocType = val!);
              },
            ),

            const SizedBox(height: 16),

            // PICK BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Choose Document"),
              ),
            ),

            const SizedBox(height: 12),

            // SCAN BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _scanDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side:
                      const BorderSide(color: Color(0xFFD4AF37)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Color(0xFFD4AF37),
                      )
                    : const Text(
                        "Scan Document",
                        style: TextStyle(color: Color(0xFFD4AF37)),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // RESULT + SAVE BUTTON
            if (_scanCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _goldCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _info("Document Type", documentType),
                    _info("Document Number", documentNumber),
                    _info("Expiry Date", expiryDate),
                    _info(
                      "Confidence",
                      "${(confidence * 100).toStringAsFixed(1)}%",
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveDocument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                        ),
                        child: _saving
                            ? const CircularProgressIndicator()
                            : const Text("Save Document"),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: $value",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
