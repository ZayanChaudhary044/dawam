import 'package:dawam/pages/welcome-page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF3E8DD)
      ),
    );
  }
}

//dark mode = 0xFF8B6F4E
