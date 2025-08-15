import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// iOS-inspired Color Scheme (matching your app)
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
}

class CircularProgressWidget extends StatefulWidget {
  const CircularProgressWidget({super.key});

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Animation<double>? _scaleAnimation;
  Timer? _dailyTimer;

  static const int maxDays = 100;
  int _currentDay = 0;
  DateTime? _startDate;
  DateTime? _lastCheckDate;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
    _setupDailyTimer();
  }

  Future<void> _initializeProgress() async {
    await _loadProgressData();
    _setupAnimations();
    _updateProgress();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();

    // Get stored start date
    final startDateString = prefs.getString('challenge_start_date');
    if (startDateString != null) {
      _startDate = DateTime.parse(startDateString);
    } else {
      // First time - set start date to today
      _startDate = DateTime.now();
      await prefs.setString('challenge_start_date', _startDate!.toIso8601String());
    }

    // Get last check date
    final lastCheckString = prefs.getString('last_check_date');
    if (lastCheckString != null) {
      _lastCheckDate = DateTime.parse(lastCheckString);
    }

    _calculateCurrentDay();
  }

  void _calculateCurrentDay() {
    if (_startDate == null) return;

    final now = DateTime.now();
    final difference = now.difference(_startDate!).inDays;
    _currentDay = (difference + 1).clamp(0, maxDays); // +1 because day 1 is the start date
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (_currentDay / maxDays).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.elasticOut,
    ));

    _animationController!.forward();
  }

  void _setupDailyTimer() {
    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    // Set timer for midnight, then repeat every 24 hours
    _dailyTimer = Timer(timeUntilMidnight, () {
      _updateProgress();
      // Set up recurring daily timer
      _dailyTimer = Timer.periodic(const Duration(days: 1), (timer) {
        _updateProgress();
      });
    });
  }

  Future<void> _updateProgress() async {
    _calculateCurrentDay();

    // Update last check date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_check_date', DateTime.now().toIso8601String());

    if (_animationController != null && mounted) {
      // Animate to new progress
      final newProgress = (_currentDay / maxDays).clamp(0.0, 1.0);

      _progressAnimation = Tween<double>(
        begin: _progressAnimation?.value ?? 0.0,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ));

      _animationController!.forward(from: 0);
      setState(() {});
    }
  }

  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('challenge_start_date');
    await prefs.remove('last_check_date');

    _startDate = DateTime.now();
    await prefs.setString('challenge_start_date', _startDate!.toIso8601String());

    _calculateCurrentDay();
    _updateProgress();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _dailyTimer?.cancel();
    super.dispose();
  }

  void _showChallengeInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final daysRemaining = maxDays - _currentDay;
        final progressPercent = ((_currentDay / maxDays) * 100).round();
        final estimatedEndDate = _startDate?.add(Duration(days: maxDays - 1));

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "100 Day Challenge",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildInfoRow("Started", _formatDate(_startDate)),
                const SizedBox(height: 12),
                _buildInfoRow("Progress", "$progressPercent% complete"),
                const SizedBox(height: 12),
                _buildInfoRow("Days Remaining", daysRemaining > 0 ? "$daysRemaining days" : "Challenge Complete!"),
                if (estimatedEndDate != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow("Estimated End", _formatDate(estimatedEndDate)),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showResetConfirmation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.accent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    child: Text(
                      "Reset Challenge",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Reset Challenge?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            "This will start a new 100-day challenge from today. Your current progress will be lost.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetChallenge();
              },
              child: Text(
                "Reset",
                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Unknown";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Return simple progress indicator if controller not ready
    if (_animationController == null) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: (_currentDay / maxDays).clamp(0.0, 1.0),
                strokeWidth: 6,
                backgroundColor: AppColors.divider.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              "$_currentDay/100",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showChallengeInfo,
      child: AnimatedBuilder(
        animation: _animationController!,
        builder: (context, child) {
          final currentProgress = _progressAnimation?.value ?? 0.0;
          final isCompleted = _currentDay >= maxDays;

          return Transform.scale(
            scale: _scaleAnimation?.value ?? 1.0,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress indicator
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: currentProgress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.divider.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green.shade600 : AppColors.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$_currentDay/100",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isCompleted ? Colors.green.shade700 : AppColors.accent,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (isCompleted)
                        Text(
                          "Complete!",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade600,
                            letterSpacing: -0.1,
                          ),
                        ),
                    ],
                  ),

                  // Tap indicator
                  Positioned(
                    bottom: 5,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.onSurfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
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