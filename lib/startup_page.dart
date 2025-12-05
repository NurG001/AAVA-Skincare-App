import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'how_to_use_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/startup.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
      });

    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    // Wait 3 seconds to ensure the splash/video is fully visible
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Widget nextScreen;
    if (hasSeenOnboarding) {
      nextScreen = const HomePage();
    } else {
      nextScreen = const HowToUsePage();
    }

    // Smooth transition
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // --- VIDEO BACKGROUND ---
          if (_videoController.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // --- CONTENT ---
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CHANGED: Increased flex from 3 to 12 to push text further down
                const Spacer(flex: 12),

                // TITLE
                FadeInUp(
                  duration: const Duration(milliseconds: 1200),
                  child: Text(
                    "AAVA",
                    style: GoogleFonts.italiana(
                      fontSize: 72,
                      letterSpacing: 12,
                      color: const Color(0xFF2D3A3A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // SUBTITLE
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    "ADVANCED ACNE\nVISUALIZATION & ANALYSIS",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      height: 1.6,
                      color: const Color(0xFF2D3A3A).withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                // Adjusted bottom spacer to balance the layout
                const Spacer(flex: 4),

                // LOADING DOTS
                FadeIn(
                  delay: const Duration(milliseconds: 800),
                  child: const SizedBox(height: 8, child: LinearProgressIndicator(color: Color(0xFF8DA399), backgroundColor: Color(0xFFFAFAFA))),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}