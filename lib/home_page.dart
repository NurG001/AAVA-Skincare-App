import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- NEW IMPORT for SystemChrome
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bouncing_button.dart';
import 'scan_logic_page.dart';
import 'tips_page.dart';
import 'how_to_use_page.dart';
import 'widgets/skin_weather_card.dart';
import 'face_map_page.dart';
import 'ingredient_scanner_page.dart';
import 'privacy_policy_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- SETTINGS STATE ---
  bool _isCelsius = true;

  // Animation Controller for Pulse Effect
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Initialize Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToScan(BuildContext context, ImageSource source) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ScanLogicPage(source: source)));
  }

  @override
  Widget build(BuildContext context) {
    // --- FIX: SET STATUS BAR TO DARK ICONS ---
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent background for a clean look
      statusBarIconBrightness: Brightness.dark, // For Android icons (Black/Dark Grey)
      statusBarBrightness: Brightness.light, // For iOS text/icons (Requires light background)
    ));
    // ------------------------------------------

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),

      endDrawer: _buildSideMenu(),

      // --- PULSING FAB ---
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.08).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToScan(context, ImageSource.camera),
          backgroundColor: const Color(0xFF2D3A3A),
          foregroundColor: Colors.white,
          elevation: 10,
          highlightElevation: 15,
          icon: const Icon(Icons.center_focus_strong),
          label: Text(
              "AI Scan",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, letterSpacing: 1)
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER ---
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome to", style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600])),
                        Text("AAVA", style: GoogleFonts.tenorSans(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))),
                      ],
                    ),

                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                      child: Container(
                        height: 50, width: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF8DA399).withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5)
                              )
                            ]
                        ),
                        child: const Icon(Icons.settings_outlined, color: Color(0xFF2D3A3A), size: 26),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. WEATHER ---
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 800),
                child: SkinWeatherCard(isCelsius: _isCelsius),
              ),

              const SizedBox(height: 35),

              // --- 3. CORE ANALYSIS FEATURES ---
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Start Analysis", style: GoogleFonts.tenorSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))),
                    const SizedBox(height: 15),

                    // HERO 1: AI SKIN SCANNER
                    _buildBlurredImageCard(
                      context,
                      title: "AI Skin Scanner",
                      subtitle: "Analyze acne levels & skin health",
                      icon: Icons.face_retouching_natural,
                      imageAsset: 'assets/camera2.jpg',
                      badgeText: "PRIMARY",
                      badgeColor: const Color(0xFF8DA399),
                      badgeIcon: Icons.auto_awesome,
                      ctaText: "SCAN FACE",
                      onTap: () => _navigateToScan(context, ImageSource.camera),
                    ),

                    const SizedBox(height: 20),

                    // HERO 2: INGREDIENT SCANNER
                    _buildBlurredImageCard(
                      context,
                      title: "Ingredient Checker",
                      subtitle: "Scan labels for harmful chemicals",
                      icon: Icons.qr_code_scanner,
                      imageAsset: 'assets/ingredients.jpg',
                      badgeText: "SAFE CHECK",
                      badgeColor: const Color(0xFFE27D60),
                      badgeIcon: Icons.shield_outlined,
                      ctaText: "SCAN LABEL",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IngredientScannerPage())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- 4. QUICK ACTIONS ---
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quick Actions", style: GoogleFonts.tenorSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))),
                    const SizedBox(height: 15),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildSmartToolCard(
                              context,
                              title: "Face Map",
                              description: "Acne zones guide",
                              icon: Icons.map_outlined,
                              buttonText: "EXPLORE",
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceMapPage())),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildSmartToolCard(
                              context,
                              title: "Gallery",
                              description: "Import photos",
                              icon: Icons.photo_library_outlined,
                              buttonText: "UPLOAD",
                              onTap: () => _navigateToScan(context, ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- 5. LEARN ---
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Learn", style: GoogleFonts.tenorSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))),
                    const SizedBox(height: 15),

                    _buildBlurredImageCard(
                      context,
                      title: "Skincare Tips",
                      subtitle: "Expert routines & advice",
                      icon: Icons.spa_outlined,
                      imageAsset: 'assets/skintip.jpg',
                      badgeText: "DAILY READ",
                      badgeColor: const Color(0xFFFFCC80),
                      badgeIcon: Icons.lightbulb_outline,
                      ctaText: "READ",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsPage())),
                    ),

                    const SizedBox(height: 15),

                    _buildListCard(
                      context,
                      title: "App Tutorial",
                      subtitle: "How to use AAVA",
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFFB0BEC5),
                      tag: "HELP",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToUsePage())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --- SIDE MENU ---
  Widget _buildSideMenu() {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF2D3A3A),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Container(
                  height: 70, width: 70,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.spa_rounded, color: Color(0xFF8DA399), size: 30);
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AAVA Settings", style: GoogleFonts.tenorSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("v2.0.1 (Sage)", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader("PREFERENCES"),

                _buildSwitchTile(
                    "Use Celsius (°C)",
                    "Switch to Fahrenheit if off",
                    _isCelsius,
                        (v) => setState(() => _isCelsius = v)
                ),

                const SizedBox(height: 30),
                _buildSectionHeader("DATA & PRIVACY"),

                _buildActionTile(Icons.delete_outline, "Clear Scan History", "Remove locally saved data", () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("History Cleared")));
                }, isDestructive: true),

                _buildActionTile(Icons.privacy_tip_outlined, "Privacy Policy", "How we protect your data", () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
                }),

                const SizedBox(height: 30),
                _buildSectionHeader("ABOUT THE APP"),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Developed by", style: GoogleFonts.lato(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Ismail Mahmud Nur", style: GoogleFonts.tenorSans(fontSize: 16, color: const Color(0xFF2D3A3A), fontWeight: FontWeight.bold)),
                      Text("Software Engineer", style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 15),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text("© 2025 AAVA Inc. All rights reserved.", style: GoogleFonts.lato(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => SystemNavigator.pop(),
                icon: const Icon(Icons.exit_to_app, color: Color(0xFFE27D60)),
                label: Text("EXIT AAVA", style: GoogleFonts.lato(color: const Color(0xFFE27D60), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF4F4),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE27D60)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildSmartToolCard(BuildContext context, {required String title, required String description, required IconData icon, String buttonText = "OPEN", required VoidCallback onTap}) {
    return BouncingButton(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF8DA399).withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFF8DA399).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(height: 55, width: 55, decoration: BoxDecoration(color: const Color(0xFF8DA399).withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF8DA399), size: 30)),
            const SizedBox(height: 15),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Column(children: [Text(title, style: GoogleFonts.tenorSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A)), textAlign: TextAlign.center), const SizedBox(height: 5), Text(description, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600], height: 1.3), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)])),
            const Spacer(), const SizedBox(height: 15),
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), decoration: const BoxDecoration(color: Color(0xFF2D3A3A), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18))), child: Center(child: Text(buttonText, style: GoogleFonts.lato(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)))),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredImageCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap, required String imageAsset, required String badgeText, required Color badgeColor, required IconData badgeIcon, required String ctaText}) {
    return BouncingButton(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(imageAsset, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: Colors.grey[400]))),
              Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0), child: Container(color: Colors.black.withOpacity(0.4)))),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)), child: Icon(icon, color: Colors.white, size: 28)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(badgeIcon, size: 10, color: Colors.white), const SizedBox(width: 4), Text(badgeText, style: GoogleFonts.lato(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))])),
                                const SizedBox(height: 8),
                                Text(title, style: GoogleFonts.tenorSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text(subtitle, style: GoogleFonts.lato(fontSize: 13, color: Colors.white.withOpacity(0.9)))
                              ]
                          )
                      ),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text(ctaText, style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF2D3A3A), letterSpacing: 0.5)))
                    ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required String tag, required VoidCallback onTap, bool isAction = false}) {
    return BouncingButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: isAction ? Border.all(color: const Color(0xFF8DA399).withOpacity(0.3), width: 1) : Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Row(children: [Container(height: 50, width: 50, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 26)), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tag, style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)), const SizedBox(height: 4), Text(title, style: GoogleFonts.tenorSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))), Text(subtitle, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey))])), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isAction ? const Color(0xFF2D3A3A) : Colors.grey[100], shape: BoxShape.circle), child: Icon(Icons.arrow_forward, size: 16, color: isAction ? Colors.white : Colors.grey[400]))]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[400], letterSpacing: 1.5)),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.tenorSans(fontSize: 16, color: const Color(0xFF2D3A3A))), Text(subtitle, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey))])),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF8DA399), activeTrackColor: const Color(0xFF8DA399).withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDestructive ? const Color(0xFFFFF4F4) : Colors.grey[100], shape: BoxShape.circle), child: Icon(icon, color: isDestructive ? const Color(0xFFE27D60) : const Color(0xFF2D3A3A), size: 20)),
      title: Text(title, style: GoogleFonts.tenorSans(fontSize: 16, color: isDestructive ? const Color(0xFFE27D60) : const Color(0xFF2D3A3A))),
      subtitle: Text(subtitle, style: GoogleFonts.lato(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}