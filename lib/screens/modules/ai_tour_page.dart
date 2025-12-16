import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/ai_tour_service.dart';

class AITourPage extends StatefulWidget {
  const AITourPage({super.key});

  @override
  State<AITourPage> createState() => _AITourPageState();
}

class _AITourPageState extends State<AITourPage> {
  // Controllers
  final startLocationController = TextEditingController();
  final destinationController = TextEditingController();
  final budgetController = TextEditingController();

  // Variables
  DateTime? startDate;
  DateTime? endDate;
  String vehicle = "Car";
  int travelers = 1;
  String pace = "Relaxed";

  bool isLoading = false;
  String itinerary = "";

  // Interest List
  final List<String> interests = [
    "Beach",
    "Mountains",
    "Food",
    "Temples",
    "Adventure",
    "Shopping",
    "Photography",
    "Nature"
  ];

  List<String> selectedInterests = [];

  // Date Picker
  Future<void> pickDate(bool isStart) async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Call backend
  Future<void> generatePlan() async {
    if (startLocationController.text.isEmpty ||
        destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    final data = {
      "start_location": startLocationController.text,
      "destination": destinationController.text,
      "start_date": startDate != null
          ? DateFormat("yyyy-MM-dd").format(startDate!)
          : "",
      "end_date":
          endDate != null ? DateFormat("yyyy-MM-dd").format(endDate!) : "",
      "days": endDate != null && startDate != null
          ? endDate!.difference(startDate!).inDays + 1
          : null,
      "budget": budgetController.text,
      "travelers": travelers,
      "vehicle_type": vehicle,
      "interests": selectedInterests,
      "pace": pace.toLowerCase(),
    };

    try {
      final result = await AITourService.generateTourPlan(data);
      setState(() {
        itinerary = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Tour Planner"),
        backgroundColor: Colors.blueAccent,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : itinerary.isEmpty
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      field("Starting Location", startLocationController),
                      field("Destination", destinationController),
                      const SizedBox(height: 10),

                      // Date pickers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          dateBox("Start Date", startDate, () => pickDate(true)),
                          dateBox("End Date", endDate, () => pickDate(false)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      field("Budget (optional)", budgetController),

                      const SizedBox(height: 20),
                      dropdown("Vehicle Type", ["Car", "Bike", "SUV"], vehicle,
                          (v) => setState(() => vehicle = v!)),
                      const SizedBox(height: 10),

                      dropdown("Pace", ["Relaxed", "Normal", "Tight"], pace,
                          (v) => setState(() => pace = v!)),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<int>(
                        initialValue: travelers,
                        decoration: const InputDecoration(
                          labelText: "Number of Travelers",
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          10,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text("${i + 1}"),
                          ),
                        ),
                        onChanged: (v) => setState(() => travelers = v!),
                      ),

                      const SizedBox(height: 20),
                      const Text("Select Interests",
                          style: TextStyle(fontWeight: FontWeight.bold)),

                      Wrap(
                        spacing: 10,
                        children: interests.map((interest) {
                          bool selected = selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  selectedInterests.add(interest);
                                } else {
                                  selectedInterests.remove(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: generatePlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Generate Itinerary"),
                      )
                    ],
                  ),
                )

              // SHOW ITINERARY
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Trip Itinerary",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(itinerary,
                          style: const TextStyle(
                              fontSize: 16, height: 1.4)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => setState(() => itinerary = ""),
                        child: const Text("Plan Another Trip"),
                      )
                    ],
                  ),
                ),
    );
  }

  // Helper widgets
  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget dropdown(String label, List<String> items, String value, Function(String?) onChange) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChange,
    );
  }

  Widget dateBox(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$label:\n${date != null ? DateFormat("dd MMM yyyy").format(date) : "Select"}",
          ),
        ),
      ),
    );
  }
}
