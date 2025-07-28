import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeMessage extends StatelessWidget {
  final String userName;

  const WelcomeMessage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              "We're so glad you're here. Dawam is your spiritual companion, helping you stay consistent with your daily prayers, habits, and personal growth in deen.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7E6E65),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Set goals, track progress, and build strong habits — all in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Start button tapped!')),
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
