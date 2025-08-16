import 'package:flutter/material.dart';

class TasbeehSet {
  final String id;
  final String? userId;
  final String name;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String? meaning;
  final int recommendedCount;
  final String category;
  final String accentColorHex;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;

  TasbeehSet({
    required this.id,
    this.userId,
    required this.name,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.meaning,
    required this.recommendedCount,
    required this.category,
    required this.accentColorHex,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
  });

  // Convert hex color to Flutter Color
  Color get accentColor {
    try {
      return Color(int.parse(accentColorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4CAF50); // Default green
    }
  }

  // Create from Supabase JSON
  factory TasbeehSet.fromJson(Map<String, dynamic> json) {
    return TasbeehSet(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      arabicText: json['arabic_text'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      meaning: json['meaning'],
      recommendedCount: json['recommended_count'] ?? 33,
      category: json['category'] ?? 'Custom',
      accentColorHex: json['accent_color'] ?? '#4CAF50',
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'arabic_text': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'meaning': meaning,
      'recommended_count': recommendedCount,
      'category': category,
      'accent_color': accentColorHex,
      'is_default': isDefault,
      'is_active': isActive,
    };
  }

  // Create a copy with updated fields
  TasbeehSet copyWith({
    String? id,
    String? userId,
    String? name,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? meaning,
    int? recommendedCount,
    String? category,
    String? accentColorHex,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TasbeehSet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      meaning: meaning ?? this.meaning,
      recommendedCount: recommendedCount ?? this.recommendedCount,
      category: category ?? this.category,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserStats {
  final int todayTaps;
  final int weeklyTaps;
  final int totalTaps;

  UserStats({
    required this.todayTaps,
    required this.weeklyTaps,
    required this.totalTaps,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      todayTaps: json['dailytaps'] ?? 0,
      weeklyTaps: json['weeklytaps'] ?? 0,
      totalTaps: json['tapsalltime'] ?? 0,
    );
  }
}

class UserSettings {
  final bool darkMode;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool notificationsEnabled;

  UserSettings({
    required this.darkMode,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.notificationsEnabled,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      darkMode: json['dark_mode'] ?? false,
      soundEnabled: json['sound_enabled'] ?? true,
      vibrationEnabled: json['vibration_enabled'] ?? true,
      notificationsEnabled: json['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dark_mode': darkMode,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'notifications_enabled': notificationsEnabled,
    };
  }
}