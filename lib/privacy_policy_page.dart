import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text("Privacy Policy", style: GoogleFonts.tenorSans(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Last Updated: December 2025", style: GoogleFonts.lato(color: Colors.grey)),
            const SizedBox(height: 20),

            _buildSection("1. Introduction",
                "Welcome to AAVA. We are committed to protecting your personal information and your right to privacy. This policy explains how we process your data."),

            _buildSection("2. Data We Collect",
                "• Camera Data: Used strictly for real-time skin analysis. Images are processed on your device and are not uploaded to external servers unless you explicitly save them.\n"
                    "• Location Data: Used to fetch local UV Index and weather data via WeatherAPI.com.\n"
                    "• Storage: Used to save your analysis results locally."),

            _buildSection("3. How We Use Your Data",
                "We use your data solely to provide functionality within the app. We do not sell, trade, or rent your personal identification information to others."),

            _buildSection("4. AI & Machine Learning",
                "Our skin analysis AI (TensorFlow Lite) runs entirely on your device. No biometric face data leaves your phone."),

            _buildSection("5. Your Consent",
                "By using our app, you consent to our Privacy Policy."),

            const SizedBox(height: 30),
            Center(
              child: Text(
                "AAVA Inc.",
                style: GoogleFonts.tenorSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.tenorSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))),
          const SizedBox(height: 10),
          Text(content, style: GoogleFonts.lato(fontSize: 15, height: 1.5, color: Colors.grey[700])),
        ],
      ),
    );
  }
}