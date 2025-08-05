import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final MaterialColor textColor = Colors.brown;

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
    });
  }

  Future<void> _updatePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[100],
        elevation: 0,
        iconTheme: IconThemeData(color: textColor[900]),
        title: Text(
          "Settings",
          style: GoogleFonts.reemKufi(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textColor[900],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top header with icon + username
            Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 60,
                  color: textColor[700],
                ),
                const SizedBox(width: 12),
                Text(
                  widget.userName,
                  style: GoogleFonts.reemKufi(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: textColor[900],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                children: [
                  SwitchListTile(
                    activeColor: textColor[700],
                    title: Text(
                      "Enable Dark Mode",
                      style: GoogleFonts.reemKufi(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: textColor[900],
                      ),
                    ),
                    value: _darkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _darkMode = value;
                      });
                      _updatePreference('darkMode', value);
                      // TODO: Apply dark mode app-wide
                    },
                  ),
                  SwitchListTile(
                    activeColor: textColor[700],
                    title: Text(
                      "Enable Sound",
                      style: GoogleFonts.reemKufi(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: textColor[900],
                      ),
                    ),
                    value: _soundEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                      _updatePreference('soundEnabled', value);
                    },
                  ),
                  SwitchListTile(
                    activeColor: textColor[700],
                    title: Text(
                      "Enable Vibration",
                      style: GoogleFonts.reemKufi(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: textColor[900],
                      ),
                    ),
                    value: _vibrationEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                      _updatePreference('vibrationEnabled', value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
