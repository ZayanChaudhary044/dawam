import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class PrayerTimetable extends StatefulWidget {
  const PrayerTimetable({super.key});

  @override
  State<PrayerTimetable> createState() => _PrayerTimetableState();
}

class _PrayerTimetableState extends State<PrayerTimetable> {
  late Future<Map<String, String>> prayerTimesFuture;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    prayerTimesFuture = fetchPrayerTimes();
  }

  Future<Map<String, String>> fetchPrayerTimes() async {
    try {
      final now = DateTime.now();
      final formatter = DateFormat('dd-MM-yyyy');
      String formattedDate = formatter.format(now);

      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timingsByAddress/$formattedDate'
            '?address=Harrow,London,UK'
            '&method=3'
            '&latitudeAdjustmentMethod=3'
            '&school=0'
            '&timezonestring=Europe/London',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data['data']['timings'] as Map<String, dynamic>;
        _lastUpdated = DateTime.now();
        return timings.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception('Failed to load prayer times (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: Please check your connection');
    }
  }

  void _refreshPrayerTimes() {
    setState(() {
      prayerTimesFuture = fetchPrayerTimes();
    });
  }

  String _getCurrentPrayer(Map<String, String> times) {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int i = 0; i < prayerOrder.length; i++) {
      final prayerTime = times[prayerOrder[i]];
      if (prayerTime != null) {
        final time = TimeOfDay.fromDateTime(_parseTime(prayerTime));
        final prayerMinutes = time.hour * 60 + time.minute;

        if (currentMinutes < prayerMinutes) {
          return prayerOrder[i];
        }
      }
    }

    return 'Fajr'; // Next day's Fajr
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String _getTimeUntilNext(Map<String, String> times) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (final prayer in prayerOrder) {
      final prayerTime = times[prayer];
      if (prayerTime != null) {
        final time = TimeOfDay.fromDateTime(_parseTime(prayerTime));
        final prayerMinutes = time.hour * 60 + time.minute;

        if (currentMinutes < prayerMinutes) {
          final diff = prayerMinutes - currentMinutes;
          final hours = diff ~/ 60;
          final minutes = diff % 60;

          if (hours > 0) {
            return "${hours}h ${minutes}m";
          } else {
            return "${minutes}m";
          }
        }
      }
    }

    // Calculate time until tomorrow's Fajr
    final fajrTime = times['Fajr'];
    if (fajrTime != null) {
      final time = TimeOfDay.fromDateTime(_parseTime(fajrTime));
      final tomorrowFajr = (time.hour * 60 + time.minute) + (24 * 60);
      final diff = tomorrowFajr - currentMinutes;
      final hours = diff ~/ 60;
      final minutes = diff % 60;
      return "${hours}h ${minutes}m";
    }

    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.mosque_outlined,
              size: 18,
              color: AppColors.accent,
            ),
            Text(
              "Prayer Times",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: _refreshPrayerTimes,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.refresh,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Prayer times content
        FutureBuilder<Map<String, String>>(
          future: prayerTimesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Loading prayer times...",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Failed to load prayer times",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _refreshPrayerTimes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Retry",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No prayer times available',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              );
            } else {
              final times = snapshot.data!;
              final filteredTimes = {
                'Fajr': times['Fajr'] ?? '',
                'Dhuhr': times['Dhuhr'] ?? '',
                'Asr': times['Asr'] ?? '',
                'Maghrib': times['Maghrib'] ?? '',
                'Isha': times['Isha'] ?? '',
              };

              final currentPrayer = _getCurrentPrayer(filteredTimes);
              final timeUntilNext = _getTimeUntilNext(filteredTimes);

              return Column(
                children: [
                  // Next prayer indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Next: $currentPrayer",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "in $timeUntilNext",
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

                  const SizedBox(height: 12),

                  // Prayer times list
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.divider,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: filteredTimes.entries.map((entry) {
                        final isNext = entry.key == currentPrayer;
                        final isLast = entry.key == filteredTimes.keys.last;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isNext ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                            border: !isLast ? Border(
                              bottom: BorderSide(
                                color: AppColors.divider,
                                width: 0.5,
                              ),
                            ) : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isNext)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                                      color: isNext ? AppColors.accent : AppColors.onSurface,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isNext ? AppColors.accent : AppColors.onSurfaceVariant,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Last updated info
                  if (_lastUpdated != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Updated ${DateFormat('HH:mm').format(_lastUpdated!)}",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant.withOpacity(0.7),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ],
              );
            }
          },
        ),
      ],
    );
  }
}