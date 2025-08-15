// 1. Create a new file: lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const primary = Color(0xFFD4AF37); // Elegant Gold
  static const primaryLight = Color(0xFFF5E6A3);
  static const secondary = Color(0xFF8B4513); // Saddle Brown

  // Light mode colors
  static const lightBackground = Color(0xFFFCFBF8); // Off-white
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF8F7F4);
  static const lightOnBackground = Color(0xFF1C1B1A);
  static const lightOnSurface = Color(0xFF2C2B28);
  static const lightOnSurfaceVariant = Color(0xFF8A8983);
  static const lightAccent = Color(0xFFA0785A); // Warm brown
  static const lightAccentLight = Color(0xFFE8DDD4);
  static const lightDivider = Color(0xFFEDE9E4);
  static const lightShadow = Color(0x08000000);

  // Dark mode colors
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceElevated = Color(0xFF2A2A2A);
  static const darkOnBackground = Color(0xFFE8E6E3);
  static const darkOnSurface = Color(0xFFE0DDD7);
  static const darkOnSurfaceVariant = Color(0xFFB8B5B0);
  static const darkAccent = Color(0xFFD4AF37); // Keep gold in dark mode
  static const darkAccentLight = Color(0xFF3A2E1A);
  static const darkDivider = Color(0xFF2F2F2F);
  static const darkShadow = Color(0x20000000);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightSurface,
    dividerColor: AppColors.lightDivider,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      background: AppColors.lightBackground,
      onBackground: AppColors.lightOnBackground,
      onSurface: AppColors.lightOnSurface,
    ),
    extensions: [
      AppColorsExtension(
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfaceElevated: AppColors.lightSurfaceElevated,
        onBackground: AppColors.lightOnBackground,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        accent: AppColors.lightAccent,
        accentLight: AppColors.lightAccentLight,
        divider: AppColors.lightDivider,
        shadow: AppColors.lightShadow,
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkSurface,
    dividerColor: AppColors.darkDivider,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      onBackground: AppColors.darkOnBackground,
      onSurface: AppColors.darkOnSurface,
    ),
    extensions: [
      AppColorsExtension(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceElevated: AppColors.darkSurfaceElevated,
        onBackground: AppColors.darkOnBackground,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        accent: AppColors.darkAccent,
        accentLight: AppColors.darkAccentLight,
        divider: AppColors.darkDivider,
        shadow: AppColors.darkShadow,
      ),
    ],
  );
}

// Custom theme extension for your app colors
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color onBackground;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color accent;
  final Color accentLight;
  final Color divider;
  final Color shadow;

  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.accent,
    required this.accentLight,
    required this.divider,
    required this.shadow,
  });

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? onBackground,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? accent,
    Color? accentLight,
    Color? divider,
    Color? shadow,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

// Helper extension to easily access your colors
extension AppColorsHelper on BuildContext {
  AppColorsExtension get appColors => Theme.of(this).extension<AppColorsExtension>()!;
}

// 2. Create a theme provider: lib/providers/theme_provider.dart



// Rest of your SplashScreen code stays the same...

// 4. How to use in your pages (example for any page):

// Instead of using hardcoded AppColors, use context.appColors:
/*
Container(
  color: context.appColors.background, // Automatically switches between light/dark
  child: Text(
    "Hello",
    style: TextStyle(color: context.appColors.onBackground),
  ),
)
*/

// 5. Updated AccountsPage dark mode toggle:
/*
In your AccountsPage, replace the dark mode switch with:

SwitchListTile(
  title: Text("Dark Mode"),
  value: Provider.of<ThemeProvider>(context).isDarkMode,
  onChanged: (value) {
    Provider.of<ThemeProvider>(context, listen: false).setTheme(value);
  },
),
*/