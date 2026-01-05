import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final supabase = Supabase.instance.client;

  // 🔑 NO AUTH – SAME ID ALWAYS
  final String userId =
      Supabase.instance.client.auth.currentSession?.user.email ?? "guest";

  final TextEditingController vehicleCtrl = TextEditingController();

  String? selectedService;
  DateTime? selectedDate;

  bool isLoading = false;
  List<Map<String, dynamic>> services = [];

  // ⏱ DURABILITY IN MONTHS (20+ SERVICES)
  final Map<String, int> serviceDurability = {
    "Engine Oil Change": 6,
    "Oil Filter": 6,
    "Air Filter": 12,
    "Fuel Filter": 12,
    "Coolant Replacement": 24,
    "Transmission Oil": 36,
    "Brake Fluid": 24,
    "Brake Pads": 24,
    "Brake Disc": 48,
    "Clutch Plate": 36,
    "Battery": 36,
    "Tyres": 48,
    "Wheel Alignment": 12,
    "Wheel Balancing": 12,
    "Suspension Check": 24,
    "Shock Absorbers": 48,
    "Spark Plugs": 24,
    "AC Service": 12,
    "Chain Lubrication": 6,
    "Chain & Sprocket": 36,
    "General Service": 12,
    "Full Vehicle Inspection": 12,
  };

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  // ================= LOAD =================
  Future<void> _loadServices() async {
    setState(() => isLoading = true);

    final res = await supabase
        .from('vehicle_services')
        .select()
        .eq('user_id', userId)
        .order('expiry_date', ascending: true);

    setState(() {
      services = List<Map<String, dynamic>>.from(res);
      isLoading = false;
    });
  }

  // ================= SAVE =================
  Future<void> _saveService() async {
    if (vehicleCtrl.text.trim().isEmpty) {
      _toast("Enter vehicle name");
      return;
    }
    if (selectedService == null) {
      _toast("Select service");
      return;
    }
    if (selectedDate == null) {
      _toast("Select service date");
      return;
    }

    final months = serviceDurability[selectedService!]!;
    final expiry = DateTime(
      selectedDate!.year,
      selectedDate!.month + months,
      selectedDate!.day,
    );

    await supabase.from('vehicle_services').insert({
      'user_id': userId,
      'vehicle_name': vehicleCtrl.text.trim(),
      'service_name': selectedService,
      'service_date': selectedDate!.toIso8601String().substring(0, 10),
      'expiry_date': expiry.toIso8601String().substring(0, 10),
    });

    vehicleCtrl.clear();
    selectedService = null;
    selectedDate = null;

    _toast("Service saved successfully");
    _loadServices();
  }

  // ================= DELETE =================
  Future<void> _deleteService(String id) async {
    await supabase.from('vehicle_services').delete().eq('id', id);
    _toast("Service deleted");
    _loadServices();
  }

  // ================= DAYS LEFT =================
  int _daysLeft(String expiry) {
    return DateTime.parse(expiry)
        .difference(DateTime.now())
        .inDays;
  }

  Color _statusColor(String expiry) {
    final days = _daysLeft(expiry);
    if (days > 30) return Colors.green;
    if (days == 30) return Colors.amber;
    return Colors.red;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Service & Maintenance",
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: _openEntrySheet,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37)),
            )
          : services.isEmpty
              ? const Center(
                  child: Text(
                    "No service records",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: services.length,
                  itemBuilder: (_, i) {
                    final s = services[i];
                    final days = _daysLeft(s['expiry_date']);

                    return Card(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: _statusColor(s['expiry_date']),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          "${s['vehicle_name']} • ${s['service_name']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Service Date: ${s['service_date']}",
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),
                            Text(
                              "Expiry Date: ${s['expiry_date']}",
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),
                            Text(
                              days < 0
                                  ? "Expired"
                                  : "$days days left",
                              style: TextStyle(
                                color:
                                    _statusColor(s['expiry_date']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () =>
                              _deleteService(s['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // ================= ENTRY SHEET =================
  void _openEntrySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Service Entry",
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: vehicleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Vehicle name",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.black,
              decoration: const InputDecoration(
                labelText: "Service",
                labelStyle: TextStyle(color: Colors.white70),
              ),
              items: serviceDurability.keys
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        style:
                            const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => selectedService = v,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Text(
                selectedDate == null
                    ? "Pick Service Date"
                    : selectedDate!
                        .toIso8601String()
                        .substring(0, 10),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveService();
              },
              child: const Text("SAVE"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOAST =================
  void _toast(String msg) {
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
}
