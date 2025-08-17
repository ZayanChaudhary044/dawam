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

// Enhanced Tap Zone with Tasbeeh Integration
class TasbeehTapZone extends StatefulWidget {
  final TasbeehSet? selectedSet;
  final int remainingCount;
  final int todayTaps;
  final VoidCallback onTap;
  final VoidCallback onSelectSet;

  const TasbeehTapZone({
    super.key,
    this.selectedSet,
    required this.remainingCount,
    required this.todayTaps,
    required this.onTap,
    required this.onSelectSet,
  });

  @override
  State<TasbeehTapZone> createState() => _TasbeehTapZoneState();
}

class _TasbeehTapZoneState extends State<TasbeehTapZone>
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
    final hasSelectedSet = widget.selectedSet != null;
    final isCompleted = hasSelectedSet && widget.remainingCount <= 0;

    return GestureDetector(
      onTap: hasSelectedSet && !isCompleted ? _handleTap : widget.onSelectSet,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 380,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: hasSelectedSet
                      ? [
                    widget.selectedSet!.accentColor.withOpacity(0.8),
                    widget.selectedSet!.accentColor.withOpacity(0.6),
                  ]
                      : [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: hasSelectedSet
                      ? widget.selectedSet!.accentColor.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasSelectedSet
                        ? widget.selectedSet!.accentColor.withOpacity(0.25)
                        : AppColors.primary.withOpacity(0.25),
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
              child: hasSelectedSet
                  ? _buildTasbeehContent(isCompleted)
                  : _buildDefaultContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasbeehContent(bool isCompleted) {
    if (isCompleted) {
      return _buildCompletionContent();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Arabic text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.selectedSet!.arabicText,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(height: 12),

        // Transliteration
        Text(
          widget.selectedSet!.transliteration,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: -0.3,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Remaining count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            "${widget.remainingCount} remaining",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Progress indicator
        Container(
          width: 200,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (widget.selectedSet!.recommendedCount - widget.remainingCount) /
                widget.selectedSet!.recommendedCount,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Completion icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.check_circle,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          "Dhikr Complete!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "May Allah accept your dhikr",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 20),

        // Select new set button
        GestureDetector(
          onTap: widget.onSelectSet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              "Select New Dhikr",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Select dhikr icon
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
              Icons.auto_awesome,
              size: 40,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "Select Dhikr",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black.withOpacity(0.9),
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "Choose a Tasbeeh set to begin",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.7),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          "Today: ${widget.todayTaps} taps",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.6),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// Tasbeeh Set Selection Modal
class TasbeehSetSelector extends StatelessWidget {
  final List<TasbeehSet> tasbeehSets;
  final Function(TasbeehSet) onSelectSet;

  const TasbeehSetSelector({
    super.key,
    required this.tasbeehSets,
    required this.onSelectSet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Dhikr",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Tasbeeh sets list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: tasbeehSets.length,
              itemBuilder: (context, index) {
                final set = tasbeehSets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onSelectSet(set);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.divider,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 40,
                            decoration: BoxDecoration(
                              color: set.accentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  set.transliteration,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  set.translation,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: set.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${set.recommendedCount}x",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: set.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
  List<TasbeehSet> _tasbeehSets = [];
  TasbeehSet? _selectedSet;
  int _remainingCount = 0;
  int _streakDays = 7;
  bool _isLoading = true;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    SoundManager.initializePlayer();
    _loadData();
  }

  @override
  void dispose() {
    SoundManager.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      print('🏛️ Loading Pavilion data...');

      // Load stats and tasbeeh sets in parallel
      final results = await Future.wait([
        _supabaseService.getTapStats(),
        _supabaseService.getTasbeehSets(),
      ]);

      final stats = results[0] as UserStats;
      final sets = results[1] as List<TasbeehSet>;

      print('🏛️ Data loaded: Stats: ${stats.todayTaps}, Sets: ${sets.length}');

      if (mounted) {
        setState(() {
          _userStats = stats;
          _tasbeehSets = sets;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading Pavilion data: $e');
      if (mounted) {
        setState(() {
          _userStats = UserStats(todayTaps: 0, weeklyTaps: 0, totalTaps: 0);
          _tasbeehSets = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _incrementTap() async {
    if (_selectedSet == null || _remainingCount <= 0) return;

    try {
      // Record tap in database
      print('🏛️ Recording dhikr tap...');
      final success = await _supabaseService.recordTap(type: 'tasbeeh');

      if (success) {
        print('🏛️ Dhikr tap recorded successfully');

        // Decrement remaining count
        setState(() {
          _remainingCount--;
        });

        // Refresh stats to show updated count
        final stats = await _supabaseService.getTapStats();
        setState(() {
          _userStats = stats;
        });

        // Show completion celebration if finished
        if (_remainingCount <= 0) {
          _showCompletionCelebration();
        }

      } else {
        print('❌ Failed to record dhikr tap');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to record dhikr. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error recording dhikr tap: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Dhikr not recorded.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showCompletionCelebration() {
    HapticFeedback.heavyImpact();
    // You could add confetti animation or other celebration effects here
  }

  void _selectTasbeehSet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TasbeehSetSelector(
        tasbeehSets: _tasbeehSets,
        onSelectSet: (set) {
          setState(() {
            _selectedSet = set;
            _remainingCount = set.recommendedCount;
          });
        },
      ),
    );
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
                            _selectedSet != null
                                ? "Dhikr in progress..."
                                : "Select dhikr to begin",
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
                    if (_selectedSet != null)
                      GestureDetector(
                        onTap: _selectTasbeehSet,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedSet!.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedSet!.accentColor.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            Icons.swap_horiz,
                            size: 18,
                            color: _selectedSet!.accentColor,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // Selected dhikr info (if any)
                if (_selectedSet != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedSet!.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedSet!.accentColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _selectedSet!.transliteration,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _selectedSet!.accentColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedSet!.translation,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

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
                          title: "Total Dhikr",
                          value: _formatNumber(_userStats?.totalTaps ?? 0),
                          icon: Icons.auto_awesome,
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
                            "Dhikr Reminder",
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
                        _selectedSet != null
                            ? "Focus on your dhikr and let each recitation draw you closer to Allah. Every count is a step towards spiritual fulfillment."
                            : "Select a dhikr set to begin your spiritual journey. Remember Allah through beautiful supplications and earn countless rewards.",
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

                // Main Tasbeeh tap zone
                TasbeehTapZone(
                  selectedSet: _selectedSet,
                  remainingCount: _remainingCount,
                  todayTaps: _userStats?.todayTaps ?? 0,
                  onTap: _incrementTap,
                  onSelectSet: _selectTasbeehSet,
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