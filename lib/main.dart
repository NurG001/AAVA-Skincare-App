import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // REQUIRED
import 'startup_page.dart';

// --- INITIALIZE STORAGE BEFORE APP RUNS ---
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure SharedPreferences is ready globally for the StartupPage check
  await SharedPreferences.getInstance();
  runApp(const AavaApp());
}

class AavaApp extends StatelessWidget {
  const AavaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AAVA',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        primaryColor: const Color(0xFF2D3A3A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8DA399),
          primary: const Color(0xFF2D3A3A),
          secondary: const Color(0xFF8DA399),
        ),
        textTheme: GoogleFonts.latoTextTheme(),
        useMaterial3: true,
      ),
      home: const StartupPage(),
    );
  }
}