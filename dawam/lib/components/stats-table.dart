import 'package:flutter/material.dart';
import 'package:dawam/services/supabase_service.dart';
import 'package:dawam/models/tasbeeh_models.dart';

// iOS-inspired Color Scheme (matching your homepage)
class AppColors {
  static const primary = Color(0xFFD4AF37); // Elegant Gold
  static const background = Color(0xFFFCFBF8); // Off-white
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF2C2B28);
  static const onSurfaceVariant = Color(0xFF8A8983);
  static const accent = Color(0xFFA0785A); // Warm brown
  static const divider = Color(0xFFEDE9E4);
  static const shadow = Color(0x08000000);
}

class StatsTable extends StatefulWidget {
  final VoidCallback? onStatsUpdate; // Optional callback to refresh from parent

  const StatsTable({super.key, this.onStatsUpdate});

  @override
  State<StatsTable> createState() => _StatsTableState();
}

class _StatsTableState extends State<StatsTable> {
  UserStats? _userStats;
  bool _isLoading = true;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    print('📊 StatsTable initState called');
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      print('📊 Loading stats...');
      final stats = await _supabaseService.getTapStats();
      print('📊 Stats loaded: Today: ${stats.todayTaps}, Week: ${stats.weeklyTaps}, Total: ${stats.totalTaps}');

      if (mounted) {
        setState(() {
          _userStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading stats: $e');
      if (mounted) {
        setState(() {
          _userStats = UserStats(todayTaps: 0, weeklyTaps: 0, totalTaps: 0);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshStats() async {
    setState(() => _isLoading = true);
    await _loadStats();
  }

  void _showTodayStats() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
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
                      "Today's Stats",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Taps",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatNumber(_userStats?.todayTaps ?? 0),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        DateTime.now().toString().split(' ')[0],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWeeklyStats() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
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
                      "This Week",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Taps",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatNumber(_userStats?.weeklyTaps ?? 0),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This week (Mon - Sun)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTotalStats() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
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
                      "All Time Stats",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total Taps",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatNumber(_userStats?.totalTaps ?? 0),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Since you started using Dawam",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Statistics",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _refreshStats,
                    child: Icon(
                      Icons.refresh,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Stats Rows
            if (_isLoading)
              Column(
                children: [
                  _buildLoadingRow(),
                  const SizedBox(height: 10),
                  _buildLoadingRow(),
                  const SizedBox(height: 10),
                  _buildLoadingRow(),
                ],
              )
            else ...[
              _buildStatRowWithButton(
                  "Today",
                  _formatNumber(_userStats?.todayTaps ?? 0),
                  onTap: _showTodayStats
              ),
              const SizedBox(height: 10),
              _buildStatRowWithButton(
                  "Week",
                  _formatNumber(_userStats?.weeklyTaps ?? 0),
                  onTap: _showWeeklyStats
              ),
              const SizedBox(height: 10),
              _buildStatRowWithButton(
                  "Total",
                  _formatNumber(_userStats?.totalTaps ?? 0),
                  onTap: _showTotalStats
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRowWithButton(String label, String value, {required VoidCallback onTap}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
              letterSpacing: -0.1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}