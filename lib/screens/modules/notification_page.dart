import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List<Map<String, dynamic>> alerts = [];

  final DateFormat _readableFormat = DateFormat("d'th of' MMMM yyyy");

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ================= SAFE DATE PARSER =================
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      try {
        return _readableFormat
            .parse(value.toString().replaceAll("  ", " "));
      } catch (_) {
        debugPrint("⚠️ Invalid date skipped: $value");
        return null;
      }
    }
  }

  // ================= LOAD NOTIFICATIONS =================
  Future<void> _loadNotifications() async {
    try {
      final results = await Future.wait([
        supabase.from('vehicle_services').select(),
        supabase.from('vehicle_documents').select(),
      ]);

      final services = results[0] as List;
      final documents = results[1] as List;

      final now = DateTime.now();
      final List<Map<String, dynamic>> generated = [];

      // -------- SERVICES --------
      for (final s in services) {
        final expiry = _parseDate(s['expiry_date']);
        if (expiry == null) continue;

        final days = expiry.difference(now).inDays;

        if (days < 0 || days <= 30) {
          generated.add({
            "id": "service_${s['id']}",
            "title": days < 0
                ? "Service Expired"
                : "Service Expiring Soon",
            "message":
                "${s['vehicle_name']} • ${s['service_name']} ${days < 0 ? 'expired' : 'expires in $days days'}",
            "color": days < 0
                ? Colors.red
                : days == 30
                    ? Colors.amber
                    : Colors.redAccent,
          });
        }
      }

      // -------- DOCUMENTS --------
      for (final d in documents) {
        final expiry = _parseDate(d['expiry_date']);
        if (expiry == null) continue;

        final days = expiry.difference(now).inDays;
        final type = (d['doc_type'] ?? "Document").toString().toUpperCase();

        if (days < 0 || days <= 30) {
          generated.add({
            "id": "doc_${d['id']}",
            "title":
                days < 0 ? "$type Expired" : "$type Expiring Soon",
            "message": days < 0
                ? "$type document has expired"
                : "$type expires in $days days",
            "color": days < 0
                ? Colors.red
                : days == 30
                    ? Colors.amber
                    : Colors.redAccent,
          });
        }
      }

      setState(() {
        alerts = generated;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Notification error: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37)),
            )
          : alerts.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: alerts.length,
                  itemBuilder: (_, i) {
                    final n = alerts[i];

                    return Dismissible(
                      key: ValueKey(n['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete,
                            color: Colors.red),
                      ),
                      onDismissed: (_) {
                        setState(() {
                          alerts.removeAt(i);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.black,
                            content: Text(
                              "Notification dismissed",
                              style: TextStyle(
                                  color: Color(0xFFD4AF37)),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: n['color'], width: 1.5),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.notifications_active,
                            color: n['color'],
                          ),
                          title: Text(
                            n['title'],
                            style: TextStyle(
                              color: n['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            n['message'],
                            style: const TextStyle(
                                color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
