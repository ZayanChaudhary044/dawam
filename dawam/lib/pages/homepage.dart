import 'package:dawam/components/prayer-timetable.dart';
import 'package:dawam/pages/pavilion.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawam/components/circularProgressWidget.dart';
import 'package:dawam/components/stats-table.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.userName});

  final String userName;

  // Use MaterialColor so you can do textColor[900]
  final MaterialColor textColor = Colors.brown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$userName's Dashboard",
                    style: GoogleFonts.reemKufi(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: textColor[900],
                    ),
                  ),
                  Icon(Icons.account_circle_outlined, size: 50, color: textColor[700]),
                ],
              ),
          
              const SizedBox(height: 20),
          
              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.brown[100],
                    ),
                    child: Text(
                      "Custom Sets",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor[900],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.brown[100],
                    ),
                    child: Text(
                      "Tasbeeh Sets",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor[900],
                      ),
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 12),
          
              // Pavilion Button
              Center(
                child: ElevatedButton(
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ThePavilion()),
                  );},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
                    shadowColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.brown[100],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "The Pavilion",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.reemKufi(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: textColor[900],
                        ),
                      ),
                      Text(
                        "Gain Reward For Every Tap",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: textColor[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
              const SizedBox(height: 12),
          
              // Progress + Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(
                        "100 Day Hard",
                        style: GoogleFonts.reemKufi(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: textColor[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CircularProgressWidget(progress: 20),
                    ],
                  ),
                  StatsTable(),
                ],
              ),
              SizedBox(height: 3),
              PrayerTimetable()
            ],
          ),
        ),
      ),
    );
  }
}
