// Replace your main.dart with this corrected version:

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawam/theme/app-theme.dart';
import 'package:dawam/providers/theme-providers.dart';
import 'package:dawam/services/supabase_service.dart';
import 'package:dawam/pages/welcome-page.dart';
import 'package:dawam/pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Dawam',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      // Check if user is authenticated with Supabase
      final supabaseService = SupabaseService();

      if (supabaseService.isAuthenticated) {
        // Get user data from Supabase
        final userData = await supabaseService.getUserData();

        if (userData != null && userData['name'] != null) {
          // User exists in database, go to homepage
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(userName: userData['name']),
              ),
            );
          }
          return;
        }
      }

      // Check local storage for fallback
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
      final userName = prefs.getString('user_name');

      // Add delay for splash effect
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      if (hasCompletedOnboarding && userName != null) {
        // Try to restore user in Supabase
        final userId = await supabaseService.createOrGetUser(userName);
        if (userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userName: userName),
            ),
          );
        } else {
          // Failed to restore, show onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WelcomePage(),
            ),
          );
        }
      } else {
        // First time user, show onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
        );
      }
    } catch (e) {
      print('Error in splash screen: $e');

      // Fallback to local check if Supabase fails
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
      final userName = prefs.getString('user_name');

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      if (hasCompletedOnboarding && userName != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userName: userName),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(height: 20),
            const Text(
              "Dawam",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD4AF37),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFD4AF37),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}