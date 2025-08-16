import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:dawam/services/supabase_service.dart';
import 'package:dawam/models/tasbeeh_models.dart';

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

// SoundManager
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

  static Future<void> playTapSound() async {
    try {
      await initializePlayer();
      if (_player != null) {
        await _player!.setVolume(0.8);
        await _player!.play(AssetSource('sounds/account-switch.mp3'));
      }
    } catch (e) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (fallbackError) {
        await HapticFeedback.mediumImpact();
      }
    }
  }

  static void dispose() {
    _player?.dispose();
    _player = null;
  }
}

// Modern Tap Zone Widget
class TapZone extends StatefulWidget {
  final int tapCount;
  final VoidCallback onTap;

  const TapZone({
    super.key,
    required this.tapCount,
    required this.onTap,
  });

  @override
  State<TapZone> createState() => _TapZoneState();
}

class _TapZoneState extends State<TapZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    setState(() => _isPressed = true);
    _controller.forward().then((_) {
      _controller.reverse();
      setState(() => _isPressed = false);
    });

    await SoundManager.playTapSound();
    await HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: _isPressed ? 15 : 25,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                  BoxShadow(
                    color: AppColors.shadowMedium,
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tap icon with pulse effect
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.touch_app_rounded,
                        size: 40,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tap count
                  Text(
                    widget.tapCount.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.9),
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Taps Today",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
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

// Stats Card Widget
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ThePavilion extends StatefulWidget {
  const ThePavilion({super.key});

  @override
  State<ThePavilion> createState() => _ThePavilionState();
}

class _ThePavilionState extends State<ThePavilion> {
  UserStats? _userStats;
  int _streakDays = 7; // TODO: Calculate from database
  bool _isLoading = true;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    SoundManager.initializePlayer();
    _loadStats();
  }

  @override
  void dispose() {
    SoundManager.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      print('🏛️ Loading Pavilion stats...');
      final stats = await _supabaseService.getTapStats();
      print('🏛️ Stats loaded: Today: ${stats.todayTaps}, Total: ${stats.totalTaps}');

      if (mounted) {
        setState(() {
          _userStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading Pavilion stats: $e');
      if (mounted) {
        setState(() {
          _userStats = UserStats(todayTaps: 0, weeklyTaps: 0, totalTaps: 0);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _incrementTap() async {
    try {
      // Record tap in database
      print('🏛️ Recording tap...');
      final success = await _supabaseService.recordTap(type: 'pavilion');

      if (success) {
        print('🏛️ Tap recorded successfully');
        // Refresh stats to show updated count
        await _loadStats();
      } else {
        print('❌ Failed to record tap');
        // Show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to record tap. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error recording tap: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Tap not recorded.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
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
                // Header with back button
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        SoundManager.playButtonSound();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "The Pavilion",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground,
                              letterSpacing: -0.8,
                            ),
                          ),
                          Text(
                            "Tap to earn rewards",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Stats grid
                if (_isLoading)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.divider.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.divider.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: "Current Streak",
                          value: "$_streakDays days",
                          icon: Icons.local_fire_department_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          title: "Total Taps",
                          value: _formatNumber(_userStats?.totalTaps ?? 0),
                          icon: Icons.touch_app_rounded,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Motivational card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.divider,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 20,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Daily Reminder",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Every tap is a step closer to Allah. Keep your dhikr consistent and watch your spiritual journey flourish.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                          letterSpacing: -0.1,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Main tap zone (moved to bottom for better ergonomics)
                TapZone(
                  tapCount: _userStats?.todayTaps ?? 0,
                  onTap: _incrementTap,
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