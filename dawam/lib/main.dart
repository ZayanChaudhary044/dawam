import 'package:dawam/pages/welcome-page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  await Supabase.initialize(
    url: 'https://uipvflasosxqdmuivppo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpcHZmbGFzb3N4cWRtdWl2cHBvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzIyNjEsImV4cCI6MjA3MDAwODI2MX0.yRBl0CtMqgzNh9f8RcbEKSnWXqVClk2UP8dCASM-JrA',
  );
  runApp(MyApp());
}
// Get a reference your Supabase client
final supabase = Supabase.instance.client;


class MyApp extends StatelessWidget {
  const MyApp({super.key});


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
