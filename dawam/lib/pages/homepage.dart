import 'package:dawam/components/prayer-timetable.dart';
import 'package:dawam/pages/pavilion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dawam/components/circularProgressWidget.dart';
import 'package:dawam/components/stats-table.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dawam/pages/account.dart';

// iOS-inspired Color Scheme
class AppColors {
  static const primary = Color(0xFFD4AF37); // Elegant Gold
  static const primaryLight = Color(0xFFF5E6A3);
  static const secondary = Color(0xFF8B4513); // Saddle Brown
  static const background = Color(0xFFFCFBF8); // Off-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFF8F7F4);
  static const onBackground = Color(0xFF1C1B1A);
  static const onSurface = Color(0xFF2C2B28);
  static const onSurfaceVariant = Color(0xFF8A8983);
  static const accent = Color(0xFFA0785A); // Warm brown
  static const accentLight = Color(0xFFE8DDD4);
  static const divider = Color(0xFFEDE9E4);
  static const shadow = Color(0x08000000);
  static const shadowMedium = Color(0x12000000);
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

// iOS-style Button
class iOSButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isCompact;
  final IconData? icon;

  const iOSButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isCompact = false,
    this.icon,
  });

  @override
  State<iOSButton> createState() => _iOSButtonState();
}

class _iOSButtonState extends State<iOSButton> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        SoundManager.playButtonSound();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.isCompact
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isPrimary ? AppColors.primary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: widget.isPrimary ? null : Border.all(
                  color: AppColors.divider,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.isPrimary ? Colors.black : AppColors.onSurface,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.isCompact ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isPrimary ? Colors.black : AppColors.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// iOS Card Component
class iOSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const iOSCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.divider,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// Hero Pavilion Card
class PavilionHeroCard extends StatefulWidget {
  final VoidCallback? onTap;

  const PavilionHeroCard({super.key, this.onTap});

  @override
  State<PavilionHeroCard> createState() => _PavilionHeroCardState();
}

class _PavilionHeroCardState extends State<PavilionHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        SoundManager.playButtonSound();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.black.withOpacity(0.8),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "The Pavilion",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.9),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Gain reward for every tap",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Assalamu'alaikum",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await SoundManager.playAccountSound();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountsPage(userName: widget.userName),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: iOSButton(
                        text: "Custom Sets",
                        icon: Icons.tune,
                        isCompact: true,
                        onPressed: () {
                          print('Custom Sets tapped!');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: iOSButton(
                        text: "Tasbeeh Sets",
                        icon: Icons.auto_awesome,
                        isCompact: true,
                        onPressed: () {
                          print('Tasbeeh Sets tapped!');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Pavilion Hero
                PavilionHeroCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThePavilion(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: iOSCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "100 Day Challenge",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(child: CircularProgressWidget(),)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: iOSCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            StatsTable(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Prayer Times
                iOSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      PrayerTimetable(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}