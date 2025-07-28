
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeName extends StatelessWidget {
  const WelcomeName({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Assalamu'alaikum",
              style: GoogleFonts.reemKufi(
                color: const Color(0xFFFFD700),
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 50),
            Text(
              "What's Your Name?",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF7E6E65),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 40, right: 40),
              child: TextField(
                cursorColor: Color(0xFFFFD700),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Color(0xFF7E6E65),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Color(0xFFFFD700),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

//"Before you start clicking away, what's your name?",
