import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ingredient_data.dart';

class IngredientScannerPage extends StatefulWidget {
  const IngredientScannerPage({super.key});

  @override
  State<IngredientScannerPage> createState() => _IngredientScannerPageState();
}

class _IngredientScannerPageState extends State<IngredientScannerPage> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _picker = ImagePicker();

  bool _isScanning = false;
  bool _isFlashOn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<Map<String, dynamic>> _scannedIngredients = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.1, end: 0.9).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();

    if (cameras.isNotEmpty) {
      
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21 
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  
  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

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

  Future<void> _processImageFile(String path) async {
    setState(() { _isScanning = true; _scannedIngredients.clear(); });

    
    if (_isFlashOn) _toggleFlash();

    try {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text.replaceAll("\n", " ");
      List<String> rawList = fullText.split(RegExp(r"[,•]"));

      List<Map<String, dynamic>> results = [];

      for (String item in rawList) {
        String cleanName = item.trim().toUpperCase();
        if (cleanName.length < 3) continue;

        String? dbMatchKey;
        IngredientData.db.forEach((key, value) {
          if (cleanName.contains(key)) {
            dbMatchKey = key;
          }
        });

        if (dbMatchKey != null) {
          var data = IngredientData.db[dbMatchKey];
          results.add({
            "name": cleanName,
            "known": true,
            "rating": data?['rating'],
            "tag": data?['tag'],
            "desc": data?['desc'],
          });
        } else {
          results.add({
            "name": cleanName,
            "known": false,
            "rating": 3,
            "tag": "Analyze Online",
            "desc": "Tap to search this ingredient on Google.",
          });
        }
      }

      if (mounted) {
        setState(() {
          _scannedIngredients = results;
          _isScanning = false;
        });
        _showResultsSheet();
      }

    } catch (e) {
      print("Scan error: $e");
      setState(() { _isScanning = false; });
    }
  }

  Future<void> _scanFromCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      final image = await _cameraController!.takePicture();
      await _processImageFile(image.path);
    } catch (e) {
      print("Camera Error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImageFile(image.path);
      }
    } catch (e) {
      print("Gallery Error: $e");
    }
  }

  void _showResultsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),

            Text(
              "Ingredient List",
              style: GoogleFonts.tenorSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2D3A3A)),
            ),
            const SizedBox(height: 5),
            Text(
              "${_scannedIngredients.length} items detected",
              style: GoogleFonts.lato(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _scannedIngredients.isEmpty
                  ? Center(child: Text("No text detected. Try again.", style: GoogleFonts.lato(color: Colors.grey)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _scannedIngredients.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    child: _buildIngredientCard(_scannedIngredients[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> item) {
    Color color;
    IconData icon;

    if (item['known'] == true) {
      color = IngredientData.getColor(item['rating']);
      icon = IngredientData.getIcon(item['rating']);
    } else {
      color = Colors.grey;
      icon = Icons.search;
    }

    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse("https://www.google.com/search?q=${item['name']}+skincare+safety");
        try {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } catch (e) {
          print("Could not launch url");
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                            item['name'],
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[300]),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item['tag'], style: GoogleFonts.lato(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                  if (item['known']) ...[
                    const SizedBox(height: 2),
                    Text(item['desc'], style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCameraReady = _cameraController != null && _cameraController!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (isCameraReady) SizedBox.expand(child: CameraPreview(_cameraController!)),

          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent, backgroundBlendMode: BlendMode.dstOut),
                ),
                Center(
                  child: Container(
                    height: 300, width: 350,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),

          if (!_isScanning)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.3 + (300 * _animation.value),
                  left: 40, right: 40,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: const Color(0xFF8DA399).withOpacity(0.8), blurRadius: 10, spreadRadius: 2)],
                      color: const Color(0xFF8DA399),
                    ),
                  ),
                );
              },
            ),

          Positioned(
            top: 50, left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // --- NEW: FLASH BUTTON (Top Right) ---
          Positioned(
            top: 50, right: 20,
            child: IconButton(
              icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: _isFlashOn ? Colors.yellow : Colors.white
              ),
              onPressed: _toggleFlash,
            ),
          ),

          Positioned(
            top: 60, left: 0, right: 0,
            child: Center(child: Text("Scan Full Label", style: GoogleFonts.tenorSans(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold))),
          ),

          Positioned(
            bottom: 50, left: 30, right: 30,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _isScanning ? null : _pickFromGallery,
                  child: Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isScanning ? null : _scanFromCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2D3A3A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _isScanning
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF2D3A3A), strokeWidth: 2))
                          : Text("CAPTURE LIST", style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
