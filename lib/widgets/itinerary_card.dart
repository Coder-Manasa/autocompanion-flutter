// lib/widgets/itinerary_card.dart
import 'package:flutter/material.dart';

class ItineraryItem {
  final String title;
  final String detail;
  final String eta;

  ItineraryItem({
    required this.title,
    required this.detail,
    required this.eta,
  });
}

class ItineraryCard extends StatefulWidget {
  final int index;
  final ItineraryItem item;

  const ItineraryCard({super.key, required this.index, required this.item});

  @override
  State<ItineraryCard> createState() => _ItineraryCardState();
}

class _ItineraryCardState extends State<ItineraryCard>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController ctrl;
  late Animation<double> rotate;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    rotate = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      expanded = !expanded;
      expanded ? ctrl.forward() : ctrl.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: toggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(widget.index.toString()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(widget.item.eta,
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: rotate,
                    child:
                        const Icon(Icons.expand_more, color: Colors.white70),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          widget.item.detail,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
