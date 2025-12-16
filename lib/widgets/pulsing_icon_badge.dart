import 'package:flutter/material.dart';

class PulsingIconBadge extends StatefulWidget {
  final Widget child;
  const PulsingIconBadge({required this.child, super.key});

  @override
  State<PulsingIconBadge> createState() => _PulsingIconBadgeState();
}

class _PulsingIconBadgeState extends State<PulsingIconBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.1)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00E5FF),
              Color(0xFF8A00F8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.6),
              blurRadius: 18,
            )
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
