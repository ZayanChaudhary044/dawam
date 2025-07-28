import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawam/pages/homepage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDF3),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // lets taps register anywhere on screen
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()), // Make sure HomePage is imported
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Dawam",
                style: GoogleFonts.reemKufi(
                  color: Color(0xFFFFD700),
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "Consistency with Intention",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E6E65),
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 35),
              Text(
                "Tap Anywhere To Start",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E6E65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
