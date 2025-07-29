import 'package:flutter/material.dart';

class CircularProgressWidget extends StatefulWidget {
  final int progress; // should be between 0 and 66

  const CircularProgressWidget({super.key, required this.progress});

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animate;
  late Animation<double> _progress;

  static const int maxDays = 66;

  @override
  void initState() {
    super.initState();

    _animate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progress = Tween<double>(begin: 0, end: widget.progress / maxDays)
        .animate(_animate)
      ..addListener(() {
        setState(() {});
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
    final currentDay = (_progress.value * maxDays).toInt();

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: _progress.value,
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$currentDay/100",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
