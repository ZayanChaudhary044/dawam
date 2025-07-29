import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawam/pages/homepage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeName()),
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Dawam",
                style: GoogleFonts.reemKufi(
                  color: const Color(0xFFFFD700),
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                "Consistency with Intention",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7E6E65),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
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

class WelcomeName extends StatefulWidget {
  const WelcomeName({super.key});

  @override
  State<WelcomeName> createState() => _WelcomeNameState();
}

class _WelcomeNameState extends State<WelcomeName> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                controller: _nameController,
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
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                String enteredName = _nameController.text.trim();
                if (enteredName.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WelcomeMessage(userName: enteredName),
                    ),
                  );
                }
              },
              child: Text('Next',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),),
            ),
          ],
        ),
      ),
    );
  }
}

//"Before you start clicking away, what's your name?",


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

