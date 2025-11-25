import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class JerseyClassifierService {
  JerseyClassifierService._();

  static final JerseyClassifierService instance = JerseyClassifierService._();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _modelLoaded = false;

  Future<void> _ensureModelLoaded() async {
    if (_modelLoaded) return;

    // Load the model
    _interpreter = await Interpreter.fromAsset('model_unquant.tflite');

    // Load labels
    final labelsData = await rootBundle.loadString('assets/labels.txt');
    _labels = labelsData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    _modelLoaded = true;
  }

  Future<ClassificationResult?> classifyImage(File imageFile) async {
    await _ensureModelLoaded();

    if (_interpreter == null) return null;

    // Read and decode image
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Get input shape from interpreter
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];

    // Resize image to model input size
    final resizedImage = img.copyResize(
      image,
      width: inputWidth,
      height: inputHeight,
    );

    // Prepare input tensor (normalize to 0-1 range)
    final input = List.generate(
      1,
      (_) => List.generate(
        inputHeight,
        (y) => List.generate(
          inputWidth,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    // Prepare output tensor
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final numClasses = outputShape[1];
    final output = List.generate(1, (_) => List.filled(numClasses, 0.0));

    // Run inference
    _interpreter!.run(input, output);

    final scores = output[0];

    // Find top result
    int topIndex = 0;
    double topConfidence = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > topConfidence) {
        topConfidence = scores[i];
        topIndex = i;
      }
    }

    final topLabel = topIndex < _labels.length ? _labels[topIndex] : 'Unknown';

    return ClassificationResult(
      topLabel: topLabel,
      topIndex: topIndex,
      topConfidence: topConfidence,
      scores: scores,
    );
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _modelLoaded = false;
  }
}

class ClassificationResult {
  const ClassificationResult({
    required this.topLabel,
    required this.topIndex,
    required this.topConfidence,
    required this.scores,
  });

  final String topLabel;
  final int topIndex;
  final double topConfidence;
  final List<double> scores;
}
