import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../services/ai_tour_service.dart';
import 'map_route_page.dart';
import 'saved_trips_page.dart';

class AITourPage extends StatefulWidget {
  const AITourPage({super.key});

  @override
  State<AITourPage> createState() => _AITourPageState();
}

class _AITourPageState extends State<AITourPage> {
  final startCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  final budgetCtrl = TextEditingController(text: "25000");

  DateTime? startDate;
  DateTime? endDate;

  bool loading = false;
  String result = "";
  int travelers = 1;

  final prefs = [
    "Beach",
    "Mountains",
    "Nature",
    "Adventure",
    "Food",
    "Shopping",
    "Photography",
    "Temples"
  ];
  final selectedPrefs = [];

  static const bg = Colors.black;
  static const gold = Color(0xFFD4AF37);
  static const card = Color(0xFF0D0D0D);

  Future<void> _pickDate(bool start) async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (d != null) {
      setState(() {
        start ? startDate = d : endDate = d;
      });
    }
  }

  Future<void> generateTrip() async {
    setState(() => loading = true);

    final data = {
      "start_location": startCtrl.text,
      "destination": destCtrl.text,
      "start_date":
          startDate != null ? DateFormat("yyyy-MM-dd").format(startDate!) : "",
      "end_date":
          endDate != null ? DateFormat("yyyy-MM-dd").format(endDate!) : "",
      "days": (startDate != null && endDate != null)
          ? endDate!.difference(startDate!).inDays + 1
          : 3,
      "travelers": travelers,
      "budget": "₹${budgetCtrl.text}",
      "interests": selectedPrefs,
    };

    try {
      final text = await AITourService.generateTour(data);
      if (!mounted) return;
      setState(() => result = text);
      await saveTrip();
    } catch (_) {}

    if (!mounted) return;
    setState(() => loading = false);
  }

  // ✅ NO AUTH – DB ONLY
  Future<void> saveTrip() async {
    await Supabase.instance.client.from('ai_trips').insert({
      'start_location': startCtrl.text,
      'destination': destCtrl.text,
      'itinerary': result,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ✅ PDF WORKS (WEB + MOBILE/DESKTOP)
 Future<void> exportPdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          "AI Tour Itinerary",
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(result.replaceAll('*', '')),
      ],
    ),
  );

  // ===== WEB =====
  if (kIsWeb) {
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..download = "ai_trip.pdf"
      ..click();

    html.Url.revokeObjectUrl(url);

    // ✅ THIS IS THE VISIBLE CHANGE
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF downloaded (check browser downloads)")),
    );
    return;
  }

  // ===== MOBILE / DESKTOP =====
  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/ai_trip.pdf");

  await file.writeAsBytes(await pdf.save());
  await OpenFile.open(file.path, type: "application/pdf");

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("PDF opened")),
  );

 }

  void shareTrip() {
    Share.share(result.replaceAll('*', ''));
  }

  void openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapRoutePage(
          start: startCtrl.text,
          destination: destCtrl.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("AI Tour Planner", style: TextStyle(color: gold)),
        iconTheme: const IconThemeData(color: gold),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedTripsPage()),
              );
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : result.isEmpty
              ? _form()
              : _result(),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _field("Start Location", Icons.my_location, startCtrl),
        _field("Destination", Icons.location_on, destCtrl),

        Row(children: [
          Expanded(
              child:
                  _dateBtn("Start Date", Icons.calendar_today, () => _pickDate(true))),
          const SizedBox(width: 10),
          Expanded(
              child: _dateBtn("End Date", Icons.event, () => _pickDate(false))),
        ]),

        const SizedBox(height: 16),
        Text("Travelers: $travelers", style: const TextStyle(color: gold)),
        Slider(
          value: travelers.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: gold,
          onChanged: (v) => setState(() => travelers = v.toInt()),
        ),

        _field("Budget (₹)", Icons.currency_rupee, budgetCtrl,
            keyboard: TextInputType.number),

        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("Preferences", style: TextStyle(color: gold)),
        ),
        Wrap(
          spacing: 8,
          children: prefs.map((p) {
            final s = selectedPrefs.contains(p);
            return ChoiceChip(
              label: Text(p),
              selected: s,
              selectedColor: gold,
              backgroundColor: card,
              labelStyle:
                  TextStyle(color: s ? Colors.black : Colors.white),
              onSelected: (v) =>
                  setState(() => v ? selectedPrefs.add(p) : selectedPrefs.remove(p)),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: gold, foregroundColor: Colors.black),
          onPressed: generateTrip,
          child: const Text("Generate AI Trip"),
        )
      ]),
    );
  }

  Widget _result() {
    final sections = result.split(RegExp(r'\n\s*\n'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const Text(
          "Your AI Itinerary",
          style:
              TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...sections.map(_dayCard),

        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          children: [
            _actionBtn(Icons.picture_as_pdf, "PDF", exportPdf),
            _actionBtn(Icons.map, "Map", openMap),
            _actionBtn(Icons.share, "Share", shareTrip),
            _actionBtn(Icons.refresh, "New", () => setState(() => result = "")),
          ],
        )
      ]),
    );
  }

  Widget _dayCard(String text) {
    IconData icon = Icons.event_note;
    final t = text.toLowerCase();
    if (t.contains("morning")) icon = Icons.wb_sunny;
    if (t.contains("afternoon")) icon = Icons.wb_cloudy;
    if (t.contains("evening")) icon = Icons.nights_stay;
    if (t.contains("night")) icon = Icons.hotel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text.replaceAll('*', ''),
              style:
                  const TextStyle(color: Colors.white70, height: 1.5),
            ),
          )
        ],
      ),
    );
  }

  Widget _actionBtn(IconData i, String t, VoidCallback f) {
    return ElevatedButton.icon(
      icon: Icon(i),
      label: Text(t),
      style: ElevatedButton.styleFrom(
          backgroundColor: gold, foregroundColor: Colors.black),
      onPressed: f,
    );
  }

  Widget _field(String l, IconData i, TextEditingController c,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(i, color: gold),
          labelText: l,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: card,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _dateBtn(String t, IconData i, VoidCallback f) {
    return OutlinedButton.icon(
      icon: Icon(i, color: gold),
      label: Text(t, style: const TextStyle(color: gold)),
      onPressed: f,
      style: OutlinedButton.styleFrom(side: const BorderSide(color: gold)),
    );
  }
}
