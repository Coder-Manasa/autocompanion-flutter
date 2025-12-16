import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';



class DocumentStoragePage extends StatefulWidget {
  const DocumentStoragePage({super.key});

  @override
  State<DocumentStoragePage> createState() => _DocumentStoragePageState();
}

class _DocumentStoragePageState extends State<DocumentStoragePage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> documents = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      // ✅ FIREBASE AUTH ONLY (CONSISTENT WITH SCANNER)
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        setState(() {
          errorMessage = "User not logged in";
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('vehicle_documents')
          .select()
          .eq('user_id', firebaseUser.uid)
          .order('id', ascending: false);

      setState(() {
        documents = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load documents";
        isLoading = false;
      });
    }
  }

  Future<void> _openDocument(String? url) async {
  if (url == null || url.isEmpty) return;

  final uri = Uri.parse(url);

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Documents"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : documents.isEmpty
                  ? const Center(
                      child: Text("No documents uploaded yet"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(
                              doc['doc_type'] ?? 'Document',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Expiry: ${doc['expiry_date'] ?? 'Not detected'}",
                            ),
                            trailing: const Icon(Icons.open_in_new),
                            onTap: () => _openDocument(doc['file_url']),
                          ),
                        );
                      },
                    ),
    );
  }
}