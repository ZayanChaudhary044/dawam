import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class PrayerTimetable extends StatefulWidget {
  const PrayerTimetable({super.key});

  @override
  State<PrayerTimetable> createState() => _PrayerTimetableState();
}

class _PrayerTimetableState extends State<PrayerTimetable> {
  late Future<Map<String, String>> prayerTimesFuture;
  final MaterialColor textColor = Colors.brown;

  @override
  void initState() {
    super.initState();
    prayerTimesFuture = fetchPrayerTimes();
  }

  Future<Map<String, String>> fetchPrayerTimes() async {
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
      return timings.map((key, value) => MapEntry(key, value.toString()));
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);

    return Card(
      color: Colors.brown[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Prayer Times on $formattedDate",
              style: GoogleFonts.reemKufi(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor[900],
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, String>>(
              future: prayerTimesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                        color: textColor[700],
                      ));
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.reemKufi(color: Colors.redAccent),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No prayer times found',
                    style: GoogleFonts.reemKufi(color: textColor[700]),
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

                  return Column(
                    children: filteredTimes.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.reemKufi(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: textColor[900],
                              ),
                            ),
                            Text(
                              entry.value,
                              style: GoogleFonts.reemKufi(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: textColor[800],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
