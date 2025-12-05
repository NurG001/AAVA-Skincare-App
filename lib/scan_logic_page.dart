import 'dart:io';
import 'dart:async';
import 'dart:typed_data'; // Kept for buffer manipulation (for heatmap generation)
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// Removed ML Kit dependency for stability
import 'classifier.dart';

class ScanLogicPage extends StatefulWidget {
  final ImageSource source;
  const ScanLogicPage({super.key, required this.source});

  @override
  State<ScanLogicPage> createState() => _ScanLogicPageState();
}

enum ScanState { initializing, camera, gallery, scanning, results, live_scan }

class _ScanLogicPageState extends State<ScanLogicPage> with TickerProviderStateMixin {
  final Classifier _classifier = Classifier();

  // State Management
  ScanState _currentState = ScanState.initializing;
  File? _capturedImage;
  File? _heatmapImage;
  String _result = "";
  bool _showHeatmap = false;

  // Camera State
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isFrontCamera = true;
  bool _isFlashOn = false;

  // Animation Controllers
  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;
  late AnimationController _breathingController; // Breathing animation for guide

  @override
  void initState() {
    super.initState();
    _classifier.loadModel(); //

    _scannerController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut));

    _breathingController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _initSource();
  }

  Future<void> _initSource() async {
    if (widget.source == ImageSource.camera) {
      await _setupCamera();
    } else {
      _pickFromGallery();
    }
  }

  // --- 1. CAMERA SETUP ---
  Future<void> _setupCamera() async {
    if (await Permission.camera.request().isDenied) {
      if(mounted) Navigator.pop(context);
      return;
    }

    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Default to front camera for face scan
      int frontCamIndex = 0;
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.front) {
          frontCamIndex = i;
          break;
        }
      }
      _selectedCameraIndex = frontCamIndex;

      await _initCameraController(_cameras![_selectedCameraIndex]);
      if (mounted) {
        setState(() => _currentState = ScanState.camera);
      }
    }
  }

  Future<void> _initCameraController(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isFrontCamera = cameraDescription.lensDirection == CameraLensDirection.front;
          // Reset flash when switching cameras
          if(_isFlashOn) _toggleFlash();
        });
      }
    } catch (e) {
      print("Camera Init Error: $e");
    }
  }

  // --- CAMERA CONTROL: SWITCH ---
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initCameraController(_cameras![_selectedCameraIndex]);
  }

  // --- CAMERA CONTROL: FLASH ---
  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isFrontCamera) return;

    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print("Flash Error: $e");
    }
  }


  // --- 2. GALLERY PICKER ---
  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _startAnalysis(File(image.path));
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  // --- 3. CAPTURE & ANALYZE ---
  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (_isFlashOn) _toggleFlash();

    setState(() { _currentState = ScanState.scanning; });

    try {
      final XFile image = await _cameraController!.takePicture();
      _startAnalysis(File(image.path));
    } catch (e) {
      print("Capture Error: $e");
      if(mounted) {
        setState(() { _currentState = ScanState.camera; });
      }
    }
  }

  Future<void> _startAnalysis(File image) async {
    setState(() {
      _capturedImage = image;
      _currentState = ScanState.scanning;
    });

    _scannerController.repeat(reverse: true);

    final minDelay = Future.delayed(const Duration(seconds: 2));
    final diagnosisFuture = _classifier.predict(image.path); //
    final heatmapFuture = _generateHeatmap(image);

    final results = await Future.wait([diagnosisFuture, heatmapFuture, minDelay]);

    if (mounted) {
      _scannerController.stop();
      setState(() {
        _result = results[0] as String;
        _heatmapImage = results[1] as File;
        _currentState = ScanState.results;
      });
    }
  }

  // --- 4. HEATMAP LOGIC (Same as before) ---
  Future<File> _generateHeatmap(File original) async {
    final bytes = await original.readAsBytes();
    img.Image? src = img.decodeImage(bytes);
    if (src == null) return original;

    img.Image lowRes = img.copyResize(src, width: 300);

    for (var pixel in lowRes) {
      num r = pixel.r; num g = pixel.g; num b = pixel.b;
      double inflammation = r - ((g + b) / 2);
      if (inflammation > 20) {
        pixel.r = 255; pixel.g = (255 - (inflammation * 2)).clamp(0, 255).toInt(); pixel.b = 0;
      } else {
        pixel.r = (r * 0.5).toInt(); pixel.g = (g * 0.5).toInt(); pixel.b = 200;
      }
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/heatmap_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(path)..writeAsBytesSync(img.encodeJpg(lowRes));
  }


  // --- 5. INSIGHTS LOGIC (Same as before) ---
  Map<String, String> _getInsights() {
    if (_result.contains("Level 0")) {
      return {"title": "Clear / Normal", "desc": "Your skin barrier appears healthy.", "care": "Maintain with gentle cleanser & SPF.", "doctor": "Routine check-up.", "alert": "low"};
    } else if (_result.contains("Level 1")) {
      return {"title": "Mild Acne", "desc": "Comedones (whiteheads/blackheads) detected.", "care": "Try Salicylic Acid or AHA/BHA.", "doctor": "Monitor for 8 weeks.", "alert": "low"};
    } else if (_result.contains("Level 2")) {
      return {"title": "Moderate Acne", "desc": "Inflamed papules and redness visible.", "care": "Benzoyl Peroxide or Niacinamide.", "doctor": "Consider seeing a derm.", "alert": "medium"};
    } else {
      return {"title": "Severe Acne", "desc": "Deep cysts or nodules detected.", "care": "Gentle routine only. Don't scrub.", "doctor": "DERMATOLOGIST RECOMMENDED.", "alert": "high"};
    }
  }

  Color _getStatusColor() {
    if (_result.contains("Level 0")) return const Color(0xFF8DA399);
    if (_result.contains("Level 1")) return const Color(0xFFEBC999);
    if (_result.contains("Level 2")) return const Color(0xFFE8A87C);
    return const Color(0xFFE27D60);
  }

  double _getScore() {
    if (_result.contains("Level 0")) return 0.95;
    if (_result.contains("Level 1")) return 0.75;
    if (_result.contains("Level 2")) return 0.50;
    return 0.25;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scannerController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  // --- BUILD METHOD AND VIEWS (Refactored) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildContent(),
          if (_currentState != ScanState.results) _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 50, left: 20,
      child: CircleAvatar(
        backgroundColor: Colors.black45,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentState) {
      case ScanState.initializing:
      case ScanState.gallery:
        return const Center(child: CircularProgressIndicator(color: Color(0xFF8DA399)));
      case ScanState.camera:
        return _buildCameraView();
      case ScanState.live_scan:
        return _buildCameraView();
      case ScanState.scanning:
        return _buildScanningView();
      case ScanState.results:
        return _buildResultsView();
    }
  }

  // === VIEW 1: STABLE CAMERA VIEW WITH OVERLAYS ===
  Widget _buildCameraView() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: Text("Loading Camera...", style: TextStyle(color: Colors.white)));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Camera Feed
        CameraPreview(_cameraController!),

        // 2. Face Cutout Overlay (Custom Painter)
        CustomPaint(
          painter: FaceCutoutPainter(),
          child: Container(),
        ),

        // 3. Animated Border (Breathing effect around the face)
        Center(
          child: AnimatedBuilder(
            animation: _breathingController,
            builder: (context, child) {
              return Container(
                height: 380 + (_breathingController.value * 10),
                width: 280 + (_breathingController.value * 10),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF8DA399).withOpacity(0.5 + (_breathingController.value * 0.5)),
                      width: 3
                  ),
                  borderRadius: BorderRadius.circular(180), // Oval shape
                ),
              );
            },
          ),
        ),

        // 4. Top Controls
        Positioned(
          top: 50, right: 20,
          child: Column(
            children: [
              // Switch Camera Button
              GestureDetector(
                onTap: _switchCamera,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black45,
                  child: Icon(
                      Platform.isIOS ? Icons.flip_camera_ios : Icons.flip_camera_android,
                      color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Flash Button (Only visible/enabled for back camera)
              if (!_isFrontCamera)
                GestureDetector(
                  onTap: _toggleFlash,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.black45,
                    child: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: _isFlashOn ? Colors.yellow : Colors.white
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 5. Text Instruction
        Positioned(
          top: 120, left: 0, right: 0,
          child: Text(
            "Align face & tap to capture",
            textAlign: TextAlign.center,
            style: GoogleFonts.tenorSans(
                fontSize: 20,
                color: Colors.white.withOpacity(0.9),
                shadows: [const Shadow(blurRadius: 10, color: Colors.black)]
            ),
          ),
        ),

        // 6. Capture Button
        Positioned(
          bottom: 50, left: 0, right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _takePhoto,
              child: Container(
                height: 80, width: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                    color: Colors.white24
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  // === VIEW 2: SCANNING ANIMATION ===
  Widget _buildScanningView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_capturedImage != null) Image.file(_capturedImage!, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.3)),
        AnimatedBuilder(
          animation: _scannerAnimation,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * _scannerAnimation.value,
              left: 0, right: 0,
              child: Column(
                children: [
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                        color: const Color(0xFF8DA399),
                        boxShadow: [BoxShadow(color: const Color(0xFF8DA399).withOpacity(0.8), blurRadius: 15, spreadRadius: 2)]
                    ),
                  ),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [const Color(0xFF8DA399).withOpacity(0.3), Colors.transparent]
                        )
                    ),
                  )
                ],
              ),
            );
          },
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                "Analyzing Skin...",
                style: GoogleFonts.tenorSans(fontSize: 18, color: Colors.white),
              )
            ],
          ),
        )
      ],
    );
  }

  // === VIEW 3: RESULTS (FIXED) ===
  Widget _buildResultsView() {
    final insights = _getInsights();
    bool isHighRisk = insights['alert'] == 'high';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Results", style: GoogleFonts.tenorSans(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showHeatmap && _heatmapImage != null
                          ? Image.file(_heatmapImage!, key: const ValueKey(2), height: 350, width: double.infinity, fit: BoxFit.cover)
                          : Image.file(_capturedImage!, key: const ValueKey(1), height: 350, width: double.infinity, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleOption("Original", !_showHeatmap),
                          _buildToggleOption("Heatvision", _showHeatmap),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 1. GRADE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Analysis Complete", style: GoogleFonts.lato(color: Colors.grey)),
                      Icon(Icons.verified, color: _getStatusColor()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_result.replaceAll("Level ", "Grade "), style: GoogleFonts.tenorSans(fontSize: 28, color: const Color(0xFF2D3A3A))),
                  const SizedBox(height: 15),
                  LinearPercentIndicator(
                    lineHeight: 8.0, percent: _getScore(), backgroundColor: Colors.grey.shade200, progressColor: _getStatusColor(), barRadius: const Radius.circular(10), animation: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. INSIGHTS CARD (Care)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Insights & Action Plan", style: GoogleFonts.tenorSans(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildInsightRow(Icons.info_outline, "Condition", insights['desc']!),
                  const SizedBox(height: 10),
                  _buildInsightRow(Icons.spa_outlined, "Action Plan", insights['care']!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. DOCTOR ADVICE / ALERT CARD
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isHighRisk ? const Color(0xFFFFF4F4) : const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isHighRisk ? const Color(0xFFFFCDD2) : const Color(0xFFE0F2F1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                      isHighRisk ? Icons.warning_amber_rounded : Icons.health_and_safety_outlined,
                      color: isHighRisk ? const Color(0xFFE27D60) : const Color(0xFF8DA399),
                      size: 24
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dermatologist Recommendation", style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        // Renders the 'doctor' string
                        Text(insights['doctor']!, style: GoogleFonts.lato(fontSize: 15, color: const Color(0xFF2D3A3A))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _showHeatmap = title == "Heatvision"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D3A3A) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black54)),
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String title, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
              Text(text, style: GoogleFonts.lato(fontSize: 15, color: const Color(0xFF2D3A3A))),
            ],
          ),
        )
      ],
    );
  }
}

// --- FACE CUTOUT PAINTER (Required Class Definition) ---
class FaceCutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.65); // Dark Overlay

    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final facePath = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: 280, // Width of face hole
          height: 380 // Height of face hole
      ));

    final path = Path.combine(PathOperation.difference, backgroundPath, facePath);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}