import 'package:flutter/material.dart';

class CircularProgressWidget extends StatefulWidget {
  final int progress; // Add this to accept progress value

  const CircularProgressWidget({super.key, required this.progress});

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animate;
  late Animation<double> _progress; // Use double animation

  @override
  void initState() {
    super.initState();

    _animate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _progress = Tween<double>(begin: 0, end: widget.progress.toDouble())
        .animate(_animate)
      ..addListener(() {
        setState(() {}); // rebuild widget on every animation tick
      });

    _animate.forward();
  }

  @override
  void dispose() {
    _animate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Example showing the animated progress as text
    return Center(
      child: Text(
        "${_progress.value.toInt()}%", // convert double to int for display
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}
