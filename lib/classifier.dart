import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Classifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _labels = ["Level 0 - Clear", "Level 1 - Mild", "Level 2 - Moderate", "Level 3 - Severe"];
      print("AAVA AI Loaded Successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<String> predict(String imagePath) async {
    if (_interpreter == null) return "AI Not Ready";

    try {
      final imageFile = File(imagePath);
      var image = img.decodeImage(imageFile.readAsBytesSync())!;

      // Resize to 224x224 (Standard TFLite input)
      image = img.copyResize(image, width: 224, height: 224);

      // Normalize (-1 to 1 for Teachable Machine models)
      var input = List.generate(1, (i) =>
          List.generate(224, (y) =>
              List.generate(224, (x) {
                var pixel = image.getPixel(x, y);
                return [(pixel.r - 127.5) / 127.5, (pixel.g - 127.5) / 127.5, (pixel.b - 127.5) / 127.5];
              })
          )
      );

      var output = List.filled(1 * 4, 0.0).reshape([1, 4]);
      _interpreter!.run(input, output);

      var result = output[0] as List<double>;
      var maxScore = result.reduce((a, b) => a > b ? a : b);
      var index = result.indexOf(maxScore);

      return _labels![index];
    } catch (e) {
      print("Prediction Error: $e");
      return "Analysis Failed";
    }
  }
}