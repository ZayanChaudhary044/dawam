import 'package:flutter/material.dart';

class PrayerTimetable extends StatelessWidget {
  const PrayerTimetable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black), // border around the text
              borderRadius: BorderRadius.circular(8), // optional: rounded corners
            ),
            child: Text(
              "This is a box!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

        ],
      ),
    );
  }
}
