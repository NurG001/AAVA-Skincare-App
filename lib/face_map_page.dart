import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class FaceMapPage extends StatefulWidget {
  const FaceMapPage({super.key});

  @override
  State<FaceMapPage> createState() => _FaceMapPageState();
}

class _FaceMapPageState extends State<FaceMapPage> {
  String? _selectedZone;

  // --- ANIMATION STATE ---
  Alignment _imageAlignment = Alignment.center;
  double _imageScale = 1.0;

  // --- RICH DATA SOURCE ---
  final Map<String, Map<String, dynamic>> _zoneData = {
    "Forehead": {
      "system": "Digestive System & Stress",
      "cause": "Poor digestion, lack of sleep, excessive sugar intake.",
      "tip": "Drink more water. Sleep by 10 PM. Reduce processed foods.",
      "icon": Icons.nightlight_round,
      "color": const Color(0xFF8DA399), // Sage
      "align": const Alignment(0.0, -0.8), // Focus near top
    },
    "Nose": {
      "system": "Heart & Blood Pressure",
      "cause": "High blood pressure, Vitamin B deficiency, spicy food.",
      "tip": "Check cholesterol. Eat cooling foods (cucumber). Cut salt.",
      "icon": Icons.favorite_rounded,
      "color": const Color(0xFFE27D60), // Coral
      "align": const Alignment(0.0, -0.2), // Focus center
    },
    "Cheeks": {
      "system": "Respiratory System",
      "cause": "Pollution, smoking, dirty pillowcases, allergies.",
      "tip": "Get fresh air. Clean phone screen. Change pillowcases often.",
      "icon": Icons.air_rounded,
      "color": const Color(0xFF9FB8AD), // Blue-Green
      "align": const Alignment(-0.4, 0.1), // Focus middle (Left Cheek default)
    },
    "Chin": {
      "system": "Hormones & Endocrine",
      "cause": "Hormonal imbalance, menstrual cycle, kidney stress.",
      "tip": "Drink spearmint tea. Take Omega-3s. Reduce stress.",
      "icon": Icons.spa_rounded,
      "color": const Color(0xFF7B6F9E), // Purple
      "align": const Alignment(0.0, 0.9), // Focus bottom
    },
  };

  void _handleZoneTap(String zone, {Alignment? customAlign}) {
    setState(() {
      _selectedZone = zone;
      // Zoom in (1.8x) and pan to the specific zone alignment
      // Use customAlign if provided (e.g., for left vs right cheek), else use default
      _imageScale = 2.5; // High zoom for detail
      _imageAlignment = customAlign ?? _zoneData[zone]!['align'];
    });
  }

  void _resetView() {
    setState(() {
      _selectedZone = null;
      // Zoom out to normal
      _imageScale = 1.0;
      _imageAlignment = Alignment.center;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text("Face Mapping", style: GoogleFonts.tenorSans(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- 1. INTERACTIVE FACE AREA ---
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: _resetView, // Tap background to zoom out
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // A. The Face Image (Animated Pan/Zoom)
                    ClipRect(
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic, // Smooth slow-down effect
                        alignment: _imageAlignment,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          scale: _imageScale,
                          child: Stack(
                            alignment: Alignment.center, // Center glow on image
                            children: [
                              Image.asset(
                                'assets/face_mesh.png',
                                height: 600, // Base height
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.face, size: 100, color: Colors.grey)),
                              ),

                              // B. THE GOLDEN GLOW LAYER (New!)
                              // This sits ON TOP of the image but moves/scales WITH it
                              if (_selectedZone != null)
                                Positioned.fill(
                                  child: Align(
                                    // If a custom alignment was used (like for cheeks), we need to approximate or pass it.
                                    // For simplicity, we use the main zone alignment relative to the image center.
                                    // Note: Alignments are relative to the parent. Since this is inside the Stack with the Image,
                                    // and the whole stack is being aligned/scaled, we need to place the glow relative to the image itself.
                                    // However, simpler approach: Just use the same alignment logic as buttons but relative to image stack.

                                    // Let's use a specific glow widget that uses the zone's alignment relative to image center
                                    alignment: _getGlowAlignment(_selectedZone!),
                                    child: FadeIn(
                                      duration: const Duration(milliseconds: 600),
                                      child: Container(
                                        width: 120, height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              const Color(0xFFFFD700).withOpacity(0.6), // Strong Gold Core
                                              const Color(0xFFFFD700).withOpacity(0.0), // Fade out
                                            ],
                                            stops: const [0.0, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // C. The Buttons (Overlay)
                    // We hide buttons when zoomed in so they don't block the view
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _selectedZone == null ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: _selectedZone != null, // Disable clicks when hidden
                        child: Stack(
                          children: [
                            // FOREHEAD
                            Align(alignment: const Alignment(0.0, -0.35), child: _buildFacePoint("Forehead")),
                            // NOSE
                            Align(alignment: const Alignment(0.0, -0.02), child: _buildFacePoint("Nose")),
                            // LEFT CHEEK
                            Align(
                                alignment: const Alignment(-0.3, 0.05),
                                child: _buildFacePoint("Cheeks", customAlign: const Alignment(-0.5, 0.1))
                            ),
                            // RIGHT CHEEK
                            Align(
                                alignment: const Alignment(0.3, 0.05),
                                child: _buildFacePoint("Cheeks", customAlign: const Alignment(0.5, 0.1))
                            ),
                            // CHIN
                            Align(alignment: const Alignment(0.0, 0.35), child: _buildFacePoint("Chin")),
                          ],
                        ),
                      ),
                    ),

                    // D. Instruction Text (Fades out when zoomed)
                    if (_selectedZone == null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: FadeInDown(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
                              ),
                              child: Text("Tap a Zone to Analyze", style: GoogleFonts.lato(fontSize: 12)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. INFO CARD (Bottom) ---
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _selectedZone == null ? _buildDefaultView() : _buildDetailView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: Get Alignment for Glow ---
  // This approximates where the glow should be on the image itself
  Alignment _getGlowAlignment(String zone) {
    // Since we are checking `_selectedZone`, we need to know which *specific* tap triggered it
    // for Cheeks (left vs right). The state `_imageAlignment` actually holds the exact target!

    // However, `_imageAlignment` is used to CENTER the view.
    // If we want the glow to appear on the feature, we can use the button coordinates.

    if (zone == "Forehead") return const Alignment(0.0, -0.55);
    if (zone == "Nose") return const Alignment(0.0, -0.15);
    if (zone == "Chin") return const Alignment(0.0, 0.45);

    // For cheeks, we check the current pan alignment to guess which one was clicked
    if (zone == "Cheeks") {
      if (_imageAlignment.x < 0) return const Alignment(-0.4, 0.05); // Left
      return const Alignment(0.4, 0.05); // Right
    }
    return Alignment.center;
  }

  // --- WIDGETS ---

  Widget _buildDefaultView() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFF5F5F5), child: Icon(Icons.face_retouching_natural, color: Colors.orange)),
              const SizedBox(width: 15),
              Text("Face Analysis", style: GoogleFonts.tenorSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Your skin map. Tap the dots to zoom in and reveal what your acne placement is trying to tell you.",
            style: GoogleFonts.lato(fontSize: 16, height: 1.5, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    final data = _zoneData[_selectedZone]!;
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: (data['color'] as Color).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(data['icon'], color: data['color'], size: 20),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedZone!, style: GoogleFonts.tenorSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A))),
                      Text(data['system'], style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: data['color'])),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: _resetView,
                icon: const Icon(Icons.close, color: Colors.grey),
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBlock("ROOT CAUSE", data['cause']),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: (data['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: (data['color'] as Color).withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb, color: data['color'], size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(data['tip'], style: GoogleFonts.lato(fontSize: 14, color: const Color(0xFF2D3A3A), height: 1.4))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[400], letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(text, style: GoogleFonts.lato(fontSize: 16, height: 1.4, color: const Color(0xFF2D3A3A))),
      ],
    );
  }

  Widget _buildFacePoint(String zone, {Alignment? customAlign}) {
    return GestureDetector(
      onTap: () => _handleZoneTap(zone, customAlign: customAlign),
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2D3A3A), width: 2),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: const Icon(Icons.touch_app, size: 20, color: Color(0xFF2D3A3A)),
      ),
    );
  }
}