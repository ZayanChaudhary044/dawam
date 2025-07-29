import 'package:dawam/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeMessage extends StatelessWidget {
  final String userName;

  const WelcomeMessage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Icon(Icons.star, size: 40, color: Color(0xFFFFD700)),
            ),
            SizedBox(height: 40),
            Text(
              'Welcome to Dawam, $userName!',
              textAlign: TextAlign.center,
              style: GoogleFonts.reemKufi(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "We built Dawam to help Muslims cultivate consistency and intentionality in their spiritual and personal growth. The name “Dawam” (دَوَام) reflects our vision — a lasting commitment to daily habits that nourish the soul. In Arabic, dawam means continuity, endurance, and constancy — values at the heart of our faith and this app. Whether it's prayer, reflection, or self-improvement, Dawam is here to support a path that endures.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7E6E65),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Set goals, track progress, and build strong habits — all in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7E6E65),
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(userName: userName)),
                );
              },
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
