import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

// SoundManager from your homepage
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

  static Future<void> playAccountSound() async {
    try {
      await initializePlayer();

      if (_player != null) {
        await _player!.setVolume(1.0);
        await _player!.play(AssetSource('sounds/account-switch.mp3'));
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

// Animated plus box button widget
class AnimatedAddButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const AnimatedAddButton({super.key, this.onPressed});

  @override
  State<AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<AnimatedAddButton>
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

    SoundManager.initializePlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    SoundManager.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) async {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
    await SoundManager.playAccountSound();
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final MaterialColor textColor = Colors.brown;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.2),
                  blurRadius: _isPressed ? 4 : 6,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: 80,
                color: textColor[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThePavilion extends StatelessWidget {
  const ThePavilion({super.key});

  final MaterialColor textColor = Colors.brown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title in one row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.brown[300],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.3),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: textColor[900],
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Welcome To The Pavilion",
                    style: GoogleFonts.reemKufi(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: textColor[900],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Selected Set Card
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Set:",
                      style: GoogleFonts.reemKufi(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: textColor[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No set selected yet.",
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Animated Add Button
              AnimatedAddButton(onPressed: (){}),
            ],
          ),
        ),
      ),
    );
  }
}
