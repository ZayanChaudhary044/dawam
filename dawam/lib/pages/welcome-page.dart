import 'package:dawam/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawam/pages/homepage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawam/services/supabase_service.dart'; // Add this import

void fadeTo(BuildContext context, Widget page) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 550),
    ),
  );
}

// Sound Manager Class
class SoundManager {
  static AudioPlayer? _player;

  static Future<void> initializePlayer() async {
    _player ??= AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.release);
  }

  static Future<void> playButtonSound() async {
    try {
      await initializePlayer();

      if (_player != null) {
        await _player!.setVolume(1.0);
        await _player!.play(AssetSource('sounds/button-switch.mp3'));
      }

    } catch (e) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (fallbackError) {
        await HapticFeedback.lightImpact();
      }
    }
  }

  static void dispose() {
    _player?.dispose();
    _player = null;
  }
}

// Animated Button Widget
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xFFFFD700),
    this.textColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  void _onTap() {
    print('🔘 Button "${widget.text}" tapped!');

    // Play sound (don't await it)
    SoundManager.playButtonSound();

    // Execute callback immediately
    if (widget.onPressed != null) {
      print('🚀 Executing callback for: ${widget.text}');
      widget.onPressed!();
      print('✅ Callback executed successfully');
    } else {
      print('❌ No callback provided');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.3),
                    blurRadius: _isPressed ? 4 : 8,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Animated Tap Area Widget for the welcome screen
class AnimatedTapArea extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedTapArea({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<AnimatedTapArea> createState() => _AnimatedTapAreaState();
}

class _AnimatedTapAreaState extends State<AnimatedTapArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap != null) {
      await SoundManager.playButtonSound();
      _controller.forward().then((_) {
        _controller.reverse();
      });

      await Future.delayed(const Duration(milliseconds: 100));
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// WelcomePage with fade-in animation
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    SoundManager.initializePlayer();

    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1;
      });
    });
  }

  @override
  void dispose() {
    SoundManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedTapArea(
        onTap: () => fadeTo(context, const WelcomeName()),
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
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
      ),
    );
  }
}

/// WelcomeName screen
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
          children: [
            Text(
              "Assalamu'alaikum",
              style: GoogleFonts.reemKufi(
                color: const Color(0xFFFFD700),
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              "What's Your Name?",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF7E6E65),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: TextField(
                controller: _nameController,
                cursorColor: const Color(0xFFFFD700),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFF7E6E65), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedButton(
              text: 'Next',
              onPressed: () async {
                print('Next button pressed');
                String enteredName = _nameController.text.trim();

                if (enteredName.isEmpty) {
                  print('Name is empty');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your name'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                print('Navigating to WelcomeMessage with name: $enteredName');
                fadeTo(context, WelcomeMessage(userName: enteredName));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// WelcomeMessage screen - UPDATED with Supabase Integration
class WelcomeMessage extends StatelessWidget {
  final String userName;

  const WelcomeMessage({super.key, required this.userName});

  // Method to save user to Supabase and complete onboarding
  Future<void> _completeOnboarding(BuildContext context) async {
    try {
      // Create user in Supabase
      final supabaseService = SupabaseService();
      final userId = await supabaseService.createOrGetUser(userName);

      if (userId != null) {
        // Also save to local storage as backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_completed_onboarding', true);
        await prefs.setString('user_name', userName);

        print('✅ User created in Supabase with ID: $userId');
      } else {
        throw Exception('Failed to create user in Supabase');
      }
    } catch (e) {
      print('❌ Error completing onboarding: $e');

      // Fallback to local storage only
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
      await prefs.setString('user_name', userName);

      // Show error message to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error - data saved locally'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Icon(Icons.star, size: 40, color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 40),
            Text(
              'Welcome to Dawam, $userName!',
              textAlign: TextAlign.center,
              style: GoogleFonts.reemKufi(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "We built Dawam to help Muslims cultivate consistency and intentionality in their spiritual and personal growth. The name Dawam (دَوَام) reflects our vision — a lasting commitment to daily habits that nourish the soul. In Arabic, dawam means continuity, endurance, and constancy — values at the heart of our faith and this app. Whether it's prayer, reflection, or self-improvement, Dawam is here to support a path that endures.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF7E6E65)),
            ),
            const SizedBox(height: 20),
            const Text(
              "Set goals, track progress, and build strong habits — all in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF7E6E65)),
            ),
            const Spacer(),
            AnimatedButton(
              text: 'Get Started',
              onPressed: () async {
                print('🚀 Get Started button pressed');

                // Show loading state
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  ),
                );

                // Save to Supabase and complete onboarding
                await _completeOnboarding(context);

                // Close loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop();

                  // Navigate to homepage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(userName: userName),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Optional: Onboarding Manager for testing/debugging
class OnboardingManager {
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_completed_onboarding');
    await prefs.remove('user_name');

    // Also sign out from Supabase
    await SupabaseService().signOut();

    print('🔄 Onboarding reset - user will see welcome flow again');
  }

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_completed_onboarding') ?? false;
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }
}