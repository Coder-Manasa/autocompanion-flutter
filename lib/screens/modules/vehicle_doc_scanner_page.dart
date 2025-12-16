import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../services/document_upload_service.dart';
import '../../services/ocr_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/document_db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';



class VehicleDocScannerPage extends StatefulWidget {
  const VehicleDocScannerPage({super.key});

  @override
  State<VehicleDocScannerPage> createState() => _VehicleDocScannerPageState();
}

class _VehicleDocScannerPageState extends State<VehicleDocScannerPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  String _selectedDocType = "Insurance";
  bool _isUploading = false;

  Map<String, dynamic>? _result;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<String> _docTypes = [
    "Insurance",
    "RC Book",
    "PUC",
    "Driving License",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------------- IMAGE PICKER ----------------

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    final file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (file != null) {
      setState(() {
        _selectedImage = file;
        _result = null;
      });
      _animController.forward(from: 0);
    }
  }

  // ---------------- UPLOAD + OCR ----------------

 Future<void> _uploadAndScan() async {
  if (_selectedImage == null) {
    setState(() {
      _errorMessage = "Please select a document image first.";
    });
    return;
  }

  setState(() {
    _isUploading = true;
    _errorMessage = null;
  });

  try {
    final folder = _selectedDocType.toLowerCase().replaceAll(" ", "_");

    // ✅ Upload works on Web + Phone
    final url = await DocumentUploadService.uploadDocument(
      _selectedImage!, // XFile
      folder,
    );

    if (url == null) {
      throw Exception("Upload failed. Please try again.");
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception("User not logged in");
    }

    final userId = firebaseUser.uid;

    // ✅ OCR ONLY on Mobile
    Map<String, dynamic> res = {
      'success': true,
      'expiry_date': "Not detected",
      'extracted_text': "",
    };

    if (!kIsWeb) {
      res = await OCRService.scanDocument(url, folder);
    }

    await DocumentDBService.saveDocument(
      userId: userId,
      docType: _selectedDocType,
      fileUrl: url,
      expiryDate: res['expiry_date'] ?? "Not detected",
    );

    setState(() {
      _result = res;
      _isUploading = false;
    });

    _animController.forward(from: 0);
  } catch (e) {
    setState(() {
      _isUploading = false;
      _errorMessage = e.toString();
    });
  }
}


  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Vehicle Document Scanner"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050509),
              Color(0xFF060A1A),
              Color(0xFF050509),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(theme),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildImagePreviewCard(),
                        const SizedBox(height: 16),
                        _buildDocTypeChips(theme),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        if (_errorMessage != null) _buildErrorBanner(),
                        const SizedBox(height: 8),
                        _buildResultCard(theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(Icons.document_scanner, color: Colors.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Smart Vehicle Docs",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Scan, extract expiry & store securely",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- IMAGE PREVIEW ----------------

   // ---------------- IMAGE PREVIEW ----------------

  Widget _buildImagePreviewCard() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.03),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: _selectedImage == null
        ? SizedBox(
            height: 160,
            child: Center(
              child: Text(
                "No document selected",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: kIsWeb
                ? Image.network(
                    _selectedImage!.path, // ✅ WEB
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(_selectedImage!.path), // ✅ ANDROID / iOS
                    fit: BoxFit.cover,
                  ),
          ),
  );
}


  // ---------------- DOC TYPE ----------------

  Widget _buildDocTypeChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      children: _docTypes.map((type) {
        final selected = _selectedDocType == type;
        return ChoiceChip(
          label: Text(type),
          selected: selected,
          onSelected: (_) {
            setState(() => _selectedDocType = type);
          },
          selectedColor: const Color(0xFF00E5FF),
          labelStyle: TextStyle(
            color: selected ? Colors.black : Colors.white70,
          ),
          backgroundColor: Colors.white.withOpacity(0.05),
        );
      }).toList(),
    );
  }

  // ---------------- BUTTONS ----------------

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _button(
                icon: Icons.camera_alt,
                label: "Camera",
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _button(
                icon: Icons.photo_library,
                label: "Gallery",
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _button(
          icon: Icons.cloud_upload,
          label: _isUploading ? "Scanning..." : "Scan & Upload",
          onTap: _isUploading ? null : _uploadAndScan,
          primary: true,
          loading: _isUploading,
        ),
      ],
    );
  }

  Widget _button({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool primary = false,
    bool loading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                )
              : null,
          color: primary ? null : Colors.white.withOpacity(0.08),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.black)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        color: primary ? Colors.black : Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: primary ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ---------------- ERROR ----------------

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.redAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage ?? "",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(
  String label,
  String value, {
  bool highlight = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
        ),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.greenAccent : Colors.white,
            fontSize: 13,
            fontWeight:
                highlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}

  // ---------------- RESULT ----------------

  Widget _buildResultCard(ThemeData theme) {
  if (_result == null) return const SizedBox.shrink();

  final bool success = _result?['success'] == true;
  final String expiry =
      (_result?['expiry_date'] ?? "Not detected").toString();
  final String extractedText =
      (_result?['extracted_text'] ?? "No text extracted").toString();

  return FadeTransition(
    opacity: _fadeAnimation,
    child: Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- TITLE ----
          Text(
            "Scan Result",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // ---- STATUS ----
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: success ? Colors.greenAccent : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Text(
                success
                    ? "Uploaded & processed successfully"
                    : "Processing failed",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: success
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ---- INFO ----
          _buildInfoRow("Document Type:", _selectedDocType),
          const SizedBox(height: 6),
          _buildInfoRow(
            "Expiry Date:",
            expiry,
            highlight: expiry.toLowerCase() != "not detected",
          ),

          const SizedBox(height: 14),

          // ---- EXTRACTED TEXT ----
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            collapsedIconColor: Colors.white70,
            iconColor: Colors.white,
            title: Text(
              "View extracted text",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            children: [
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  extractedText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
    }