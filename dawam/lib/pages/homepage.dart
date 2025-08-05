import 'package:dawam/components/prayer-timetable.dart';
import 'package:dawam/pages/pavilion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawam/components/circularProgressWidget.dart';
import 'package:dawam/components/stats-table.dart';
import 'package:audioplayers/audioplayers.dart';

// Sound Manager Class (same as before)
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

// Animated Button Widget (same as before)
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? textStyle;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xFFFFD700),
    this.textColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.textStyle,
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
    // Play sound (don't await it)
    SoundManager.playButtonSound();

    // Execute callback immediately
    if (widget.onPressed != null) {
      widget.onPressed!();
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
              child: widget.textStyle != null
                  ? Text(widget.text, style: widget.textStyle)
                  : Text(
                widget.text,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: widget.fontWeight,
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Large Animated Button for special buttons like Pavilion
class LargeAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const LargeAnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor = Colors.brown,
    this.padding = const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<LargeAnimatedButton> createState() => _LargeAnimatedButtonState();
}

class _LargeAnimatedButtonState extends State<LargeAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
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
    // Play sound
    SoundManager.playButtonSound();

    // Execute callback
    if (widget.onPressed != null) {
      widget.onPressed!();
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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _isPressed ? 4 : 8,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.userName});

  final String userName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use MaterialColor so you can do textColor[900]
  final MaterialColor textColor = Colors.brown;

  @override
  void initState() {
    super.initState();
    // Initialize sound player
    SoundManager.initializePlayer();
  }

  @override
  void dispose() {
    SoundManager.dispose();
    super.dispose();
  }

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
                    "${widget.userName}'s Dashboard",
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

              // Animated Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AnimatedButton(
                    text: "Custom Sets",
                    backgroundColor: Colors.brown[100]!,
                    textColor: textColor[900]!,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    onPressed: () {
                      print('Custom Sets tapped!');
                      // Add your navigation or functionality here
                    },
                  ),
                  AnimatedButton(
                    text: "Tasbeeh Sets",
                    backgroundColor: Colors.brown[100]!,
                    textColor: textColor[900]!,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    onPressed: () {
                      print('Tasbeeh Sets tapped!');
                      // Add your navigation or functionality here
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Animated Pavilion Button
              Center(
                child: LargeAnimatedButton(
                  backgroundColor: Colors.brown[100]!,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    print('The Pavilion tapped!');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ThePavilion()),
                    );
                  },
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