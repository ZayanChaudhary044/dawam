import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dawam/services/supabase_service.dart';
import 'package:dawam/pages/welcome-page.dart';
import 'package:dawam/pages/homepage.dart';

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

class AccountsPage extends StatefulWidget {
  final String userName;
  const AccountsPage({super.key, required this.userName});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool _darkMode = false;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _updatePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showChangeNameDialog() {
    final nameController = TextEditingController(text: widget.userName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Change Name",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter your new name:",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  hintText: "Your name",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
            ],
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
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != widget.userName) {
                  Navigator.of(context).pop();
                  await _updateUserName(newName);
                } else if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid name")),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Update",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Reset All Data?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          content: Text(
            "This will reset your progress, settings, and return you to the welcome screen where you'll need to set up your account again. This action cannot be undone.",
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAllData();
              },
              child: Text(
                "Reset",
                style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserName(String newName) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );

      // Update name in Supabase
      final supabaseService = SupabaseService();
      await supabaseService.updateUserName(newName);

      // Update name in local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Name updated to $newName"),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        // Navigate back to homepage with new name
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomePage(userName: newName),
          ),
              (route) => route.isFirst,
        );
      }
    } catch (e) {
      print('Error updating name: $e');

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Try to update locally even if Supabase fails
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', newName);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Name updated to $newName (saved locally)"),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );

          // Navigate back to homepage with new name
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomePage(userName: newName),
            ),
                (route) => route.isFirst,
          );
        } catch (localError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to update name. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _resetAllData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );

      // Sign out from Supabase
      final supabaseService = SupabaseService();
      await supabaseService.signOut();

      // Clear all SharedPreferences data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Navigate to WelcomePage and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      print('Error during reset: $e');

      // Even if Supabase fails, still clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        // Close loading dialog if it's still open
        Navigator.of(context).pop();

        // Navigate to WelcomePage
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
              (route) => false,
        );
      }
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
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackground,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Profile Section
                GestureDetector(
                  onTap: _showChangeNameDialog,
                  child: Container(
                    width: double.infinity,
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
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tap to change name",
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
                        Icon(
                          Icons.edit,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Settings Section
                Text(
                  "App Settings",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
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
                    children: [
                      _buildSettingTile(
                        icon: Icons.dark_mode_outlined,
                        title: "Dark Mode",
                        subtitle: "Switch to dark theme",
                        value: _darkMode,
                        onChanged: (value) {
                          setState(() => _darkMode = value);
                          _updatePreference('darkMode', value);
                        },
                        isFirst: true,
                      ),
                      _buildSettingTile(
                        icon: Icons.volume_up_outlined,
                        title: "Sound Effects",
                        subtitle: "Button tap sounds",
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() => _soundEnabled = value);
                          _updatePreference('soundEnabled', value);
                        },
                      ),
                      _buildSettingTile(
                        icon: Icons.vibration,
                        title: "Haptic Feedback",
                        subtitle: "Vibration on interactions",
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() => _vibrationEnabled = value);
                          _updatePreference('vibrationEnabled', value);
                        },
                      ),
                      _buildSettingTile(
                        icon: Icons.notifications_outlined,
                        title: "Push Notifications",
                        subtitle: "Prayer reminders and updates",
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                          _updatePreference('notificationsEnabled', value);
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Data Section
                Text(
                  "Data & Privacy",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
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
                    children: [
                      _buildActionTile(
                        icon: Icons.backup_outlined,
                        title: "Export Data",
                        subtitle: "Download your progress",
                        onTap: () {
                          // TODO: Implement data export
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Export feature coming soon")),
                          );
                        },
                        isFirst: true,
                      ),
                      _buildActionTile(
                        icon: Icons.delete_outline,
                        title: "Reset All Data",
                        subtitle: "Clear progress and settings",
                        onTap: _showResetDialog,
                        isDestructive: true,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // About Section
                Text(
                  "About",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
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
                    children: [
                      _buildInfoTile(
                        icon: Icons.info_outline,
                        title: "App Version",
                        value: "1.0.0",
                        isFirst: true,
                      ),
                      _buildInfoTile(
                        icon: Icons.code,
                        title: "Build",
                        value: "Beta",
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: !isLast ? Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: AppColors.onSurfaceVariant.withOpacity(0.5),
            inactiveTrackColor: AppColors.divider,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: !isLast ? Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 0.5,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive ? Colors.red.shade600 : AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red.shade600 : AppColors.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: !isLast ? Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}