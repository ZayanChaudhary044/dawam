import 'package:flutter/material.dart';
import 'package:dawam/pages/welcome-page.dart';

void main() {
  runApp(const DawamApp());
}

class DawamApp extends StatelessWidget {
  const DawamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dawam',
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}
