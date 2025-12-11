import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'home_page.dart';

class HowToUsePage extends StatefulWidget {
  const HowToUsePage({super.key});

  @override
  State<HowToUsePage> createState() => _HowToUsePageState();
}

class _HowToUsePageState extends State<HowToUsePage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  
  final List<Map<String, dynamic>> _steps = [
    {
      "title": "Welcome to AAVA",
      "desc": "Your personal skin intelligence app. We guide you through analysis, not just tell you the results.",
      "icon": Icons.spa_rounded,
    },
    {
      "title": "Your Skin Forecast",
      "desc": "Start your day with the Skin Weather dashboard. We track real-time UV Index and Humidity to recommend the perfect SPF and hydration levels.",
      "icon": Icons.wb_sunny_rounded,
    },
    {
      "title": "AI Diagnostics",
      "desc": "Use the Camera Scan for primary diagnosis. The Face Cutout ensures optimal image capture for the AI model.",
      "icon": Icons.center_focus_strong_rounded,
    },
    {
      "title": "Heatmap Vision",
      "desc": "See what the naked eye misses. Toggle 'Heatvision' on your results to visualize inflammation zones before they become visible breakouts.",
      "icon": Icons.blur_on_rounded,
    },
    {
      "title": "3D Face Mapping",
      "desc": "Acne isn't random. Use the interactive Face Map to link breakout zones (like the chin or forehead) to internal health factors.",
      "icon": Icons.face_retouching_natural_rounded,
    },
    {
      "title": "Ingredient Safety",
      "desc": "Never buy blind again. Scan product labels with the Ingredient Scanner. AAVA instantly flags pore-clogging oils and irritants.",
      "icon": Icons.qr_code_scanner_rounded,
    },
    {
      "title": "Explore Zones",
      "desc": "Use the Interactive Face Map to understand the link between specific acne zones (chin, forehead) and internal health (hormones, stress).",
      "icon": Icons.map_outlined,
    },
    {
      "title": "Daily Education",
      "desc": "Visit the 'Learn' section for expert articles. Knowledge is your best skincare product.",
      "icon": Icons.menu_book_rounded,
    },
    {
      "title": "Quick Access",
      "desc": "You can always access this guide and other settings via the gear icon (top-right) on the Home Page.",
      "icon": Icons.settings_outlined,
    },
  ];

  
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
          
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildTutorialCard(_steps[index]);
                  },
                ),
              ),

              // 2. NAVIGATION CONTROLS
              Container(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                 
                    Row(
                      children: List.generate(_steps.length, (index) => _buildDot(index)),
                    ),

                  
                    ElevatedButton(
                      onPressed: () {
                        if (_currentIndex == _steps.length - 1) {
                          _completeOnboarding(); 
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3A3A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        elevation: 5,
                      ),
                      child: Text(
                        _currentIndex == _steps.length - 1 ? "GET STARTED" : "NEXT",
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding, 
              child: Text(
                "Skip",
                style: GoogleFonts.lato(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTutorialCard(Map<String, dynamic> step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                  color: const Color(0xFF8DA399).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8DA399).withOpacity(0.3), width: 1)
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 150, width: 150,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.5),
                        boxShadow: [BoxShadow(color: const Color(0xFF8DA399).withOpacity(0.2), blurRadius: 20, spreadRadius: 5)]
                    ),
                  ),
                  Icon(
                    step['icon'],
                    size: 80,
                    color: const Color(0xFF2D3A3A),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text(
              step['title'],
              textAlign: TextAlign.center,
              style: GoogleFonts.tenorSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3A3A),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Text(
              step['desc'],
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 30 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF8DA399) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
