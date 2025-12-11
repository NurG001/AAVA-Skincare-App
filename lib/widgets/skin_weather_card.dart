import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

// TODO: Replace with your actual key
const String _apiKey = "api_code_not_shown";

class SkinWeatherCard extends StatefulWidget {
  final bool isCelsius;
  const SkinWeatherCard({super.key, required this.isCelsius});

  @override
  State<SkinWeatherCard> createState() => _SkinWeatherCardState();
}

class _SkinWeatherCardState extends State<SkinWeatherCard> {
  String _location = "Locating...";
  double? _tempC;
  double? _tempF;
  String _humidity = "--";
  String _condition = "Loading";
  String _uvIndex = "--";
  String _advice = "Fetching skin forecast...";

  int _isDay = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSkinWeather();
  }

  void _loadFallbackData() {
    if (mounted) {
      setState(() {
        _location = "London (Sim)";
        _tempC = 19.0;
        _tempF = 66.2;
        _humidity = "45%";
        _condition = "Partly Cloudy";
        _uvIndex = "4.0";
        _isDay = 1;
        _advice = "Moderate UV. Wear SPF 30+. Air is balanced.";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherApi(Position position) async {
    final url = Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=$_apiKey&q=${position.latitude},${position.longitude}&aqi=no');

    // INCREASED API TIMEOUT TO 20 SECONDS
    final response = await http.get(url).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final current = data['current'];

      if (mounted) {
        setState(() {
          _location = data['location']['name'];
          _tempC = current['temp_c'].toDouble();
          _tempF = current['temp_f'].toDouble();
          _humidity = "${current['humidity']}%";
          _condition = current['condition']['text'];
          _uvIndex = current['uv'].toString();

          _isDay = current['is_day'];

          double uv = current['uv'];
          double humid = current['humidity'].toDouble();

          if (uv > 5) {
            _advice = "High UV! Reapply SPF 50 every 2 hours.";
          } else if (humid < 40) {
            _advice = "Dry air detected. Use a hydrating serum.";
          } else if (humid > 80) {
            _advice = "High humidity. Keep skincare light & oil-free.";
          } else {
            _advice = "Great skin weather. Maintain routine.";
          }

          _isLoading = false;
        });
      }
    } else {
      _loadFallbackData();
    }
  }

  Future<void> _fetchSkinWeather() async {
    Position? position;

    try {
      // 1. Initial Permission Check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _loadFallbackData();
        return;
      }

      // 2. Service Check & Prompt
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        if (mounted) {
          setState(() {
            _location = "Location Off";
            _advice = "Tap here to turn on GPS for real-time weather.";
            _isLoading = false;
          });
        }
        return;
      }

      // 3. Try Last Known Position (Fastest check)
      position = await Geolocator.getLastKnownPosition();

      // 4. If last position is null, try getCurrentPosition (Quick check)
      if (position == null) {
        print("No last known position. Attempting quick current acquisition (20s budget).");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 20), // Increased timeout to 20s
        );
      }

      // 5. Success: Use the position found (either cached or current)
      if (position != null) {
        await _fetchWeatherApi(position);
      } else {
        // Fallback if quick acquisition failed
        _loadFallbackData();
      }

    } catch (e) {
      // FINAL FAILURE HANDLING: Use fallback data on timeout/error
      print("GEOLOCATOR FINAL FAILURE: $e");
      _loadFallbackData();
    }
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity, height: 180,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
        ),
      );
    }

    String tempDisplay = "--";
    if (_tempC != null && _tempF != null) {
      tempDisplay = widget.isCelsius ? "${_tempC!.round()}°C" : "${_tempF!.round()}°F";
    }

    bool isServiceOffPrompt = _location == "Location Off";

    return GestureDetector( // Added GestureDetector to handle tap on prompt
      onTap: isServiceOffPrompt ? () => Geolocator.openLocationSettings() : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 10)),
          ],
          image: DecorationImage(
            image: AssetImage(_getBackgroundImage()),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Weather", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 180,
                      child: Text(
                        _location,
                        style: GoogleFonts.tenorSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                _buildConditionAnim(),
              ],
            ),
            const SizedBox(height: 20),

            // Show metrics only if data is loaded
            if (!isServiceOffPrompt) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeatherMetric("Temp", tempDisplay, Icons.thermostat),
                  _buildWeatherMetric("Humidity", _humidity, Icons.water_drop_rounded),
                  _buildWeatherMetric("UV Index", _uvIndex, Icons.wb_sunny_rounded),
                ],
              ),
              const SizedBox(height: 15),
            ],

            // Glassmorphism Advice Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _advice,
                      style: GoogleFonts.lato(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- REUSED HELPER METHODS (LOTTIE/ICON/BACKGROUND) ---

  String _getBackgroundImage() {
    String condition = _condition.toLowerCase();
    String time = _isDay == 1 ? "day" : "night";

    if (condition.contains("rain") || condition.contains("drizzle")) {
      return "assets/weather/rainy_$time.jpg";
    } else if (condition.contains("cloud") || condition.contains("overcast") || condition.contains("mist")) {
      return "assets/weather/cloudy_$time.jpg";
    } else if (condition.contains("clear") || condition.contains("sunny")) {
      return _isDay == 1 ? "assets/weather/sunny_day.jpg" : "assets/weather/clear_night.jpg";
    }

    return _isDay == 1 ? "assets/weather/sunny_day.jpg" : "assets/weather/clear_night.jpg";
  }

  Widget _buildConditionAnim() {
    String animPath = 'assets/anim/cloudy.json';
    String lowerCondition = _condition.toLowerCase();
    bool isNight = _isDay == 0;

    if (_isLoading) return const SizedBox(height: 70, width: 70);

    if (lowerCondition.contains("rain") || lowerCondition.contains("drizzle") || lowerCondition.contains("storm")) {
      animPath = isNight ? 'assets/anim/rainy(night).json' : 'assets/anim/rainy.json';
    } else if (lowerCondition.contains("cloud") || lowerCondition.contains("overcast")) {
      animPath = isNight ? 'assets/anim/cloudy(night).json' : 'assets/anim/cloudy.json';
    } else if (lowerCondition.contains("clear") || lowerCondition.contains("sunny")) {
      animPath = isNight ? 'assets/anim/night.json' : 'assets/anim/sunny.json';
    }

    return SizedBox(
      height: 70, width: 70,
      child: Lottie.asset(
        animPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.wb_cloudy_rounded, color: Colors.white, size: 40);
        },
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: GoogleFonts.lato(color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}
