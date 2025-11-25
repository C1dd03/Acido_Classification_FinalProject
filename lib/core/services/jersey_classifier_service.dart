import 'dart:io';

import 'package:tflite/tflite.dart';

class JerseyClassifierService {
  JerseyClassifierService._();

  static final JerseyClassifierService instance = JerseyClassifierService._();

  bool _modelLoaded = false;

  Future<void> _ensureModelLoaded() async {
    if (_modelLoaded) return;

    await Tflite.close();
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );

    _modelLoaded = true;
  }

  Future<ClassificationResult?> classifyImage(File imageFile) async {
    await _ensureModelLoaded();

    final recognitions = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 10,
      threshold: 0.0,
      asynch: true,
    );

    if (recognitions == null || recognitions.isEmpty) {
      return null;
    }

    final results = (recognitions as List)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    results.sort((a, b) {
      final da = (a['confidence'] as double?) ?? 0.0;
      final db = (b['confidence'] as double?) ?? 0.0;
      return db.compareTo(da);
    });

    final top = results.first;
    final scores = List<double>.filled(10, 0.0);

    for (final r in results) {
      final index = (r['index'] as int?) ?? -1;
      final conf = (r['confidence'] as double?) ?? 0.0;
      if (index >= 0 && index < scores.length) {
        scores[index] = conf;
      }
    }

    return ClassificationResult(
      topLabel: (top['label'] as String?) ?? 'Unknown',
      topIndex: (top['index'] as int?) ?? 0,
      topConfidence: (top['confidence'] as double?) ?? 0.0,
      scores: scores,
    );
  }

  Future<void> dispose() async {
    await Tflite.close();
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
