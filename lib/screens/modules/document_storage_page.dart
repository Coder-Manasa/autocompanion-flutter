import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentStoragePage extends StatefulWidget {
  const DocumentStoragePage({super.key});

  @override
  State<DocumentStoragePage> createState() =>
      _DocumentStoragePageState();
}

class _DocumentStoragePageState
    extends State<DocumentStoragePage> {
  final supabase = Supabase.instance.client;
  final firebaseUser = FirebaseAuth.instance.currentUser;

  String? selectedCategory;
  bool isLoading = false;
  List<Map<String, dynamic>> documents = [];

  final categories = ["insurance", "puc", "rc", "dl", "others"];

  Future<void> _loadDocuments(String category) async {
    if (firebaseUser == null) return;

    setState(() {
      selectedCategory = category;
      isLoading = true;
      documents.clear();
    });

    final data = await supabase
        .from('vehicle_documents')
        .select()
        .eq('user_id', firebaseUser!.uid)
        .ilike('doc_type', category); // ✅ case-safe

    setState(() {
      documents = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  void _openDocument(String url) async {
    if (url.isEmpty) return;

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          selectedCategory?.toUpperCase() ??
              "Document Storage",
          style:
              const TextStyle(color: Color(0xFFD4AF37)),
        ),
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Color(0xFFD4AF37)),
                onPressed: () {
                  setState(() {
                    selectedCategory = null;
                    documents.clear();
                  });
                },
              )
            : null,
      ),
      body: selectedCategory == null
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                return Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        color: Color(0xFFD4AF37)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      cat.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFD4AF37),
                      size: 16,
                    ),
                    onTap: () => _loadDocuments(cat),
                  ),
                );
              },
            )
          : isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37)),
                )
              : documents.isEmpty
                  ? const Center(
                      child: Text(
                        "No documents found",
                        style:
                            TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: documents.length,
                      itemBuilder: (_, i) {
                        final doc = documents[i];
                        return Card(
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xFFD4AF37)),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              doc['doc_type']
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                            subtitle: const Text(
                              "Tap to open",
                              style: TextStyle(
                                  color: Colors.white70),
                            ),
                            onTap: () =>
                                _openDocument(doc['file_url']),
                          ),
                        );
                      },
                    ),
    );
  }
}
