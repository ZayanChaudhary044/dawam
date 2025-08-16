import 'package:flutter/material.dart';
import 'package:dawam/components/prayer-timetable.dart';

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

class PrayerTimes extends StatelessWidget {
  const PrayerTimes({super.key});

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
                      onTap: () => Navigator.pop(context),
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
                            "Prayer Times",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground,
                              letterSpacing: -0.8,
                            ),
                          ),
                          Text(
                            "Today's schedule",
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

                // Current prayer status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Next Prayer",
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
                        "Asr", // TODO: Make this dynamic
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "in 2 hours 15 minutes", // TODO: Make this dynamic
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

                const SizedBox(height: 24),

                // Prayer times table
                Container(
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Prayer Times",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrayerTimetable(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Additional information cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Location",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "London, UK", // TODO: Make this dynamic
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
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
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Qibla direction card
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
                            Icons.explore_outlined,
                            size: 20,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Qibla Direction",
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
                        "Face towards Mecca for your prayers. The Qibla direction from your location is approximately 118° Southeast.",
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}