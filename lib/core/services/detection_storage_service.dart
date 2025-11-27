import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/detection_record.dart';

/// Service for persisting and retrieving detection records locally.
class DetectionStorageService {
  DetectionStorageService._();

  static final DetectionStorageService instance = DetectionStorageService._();

  static const String _storageKey = 'detection_records';

  List<DetectionRecord> _cachedRecords = [];
  bool _isLoaded = false;

  /// Get all stored detection records.
  List<DetectionRecord> get records => List.unmodifiable(_cachedRecords);

  /// Load records from storage. Call this once at app startup.
  Future<void> loadRecords() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    _cachedRecords = jsonList
        .map((json) => DetectionRecord.decode(json))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

    _isLoaded = true;
  }

  /// Save a new detection record.
  Future<void> saveRecord(DetectionRecord record) async {
    await loadRecords(); // Ensure loaded

    _cachedRecords.insert(0, record); // Add to front (newest first)

    await _persistRecords();
  }

  /// Delete a record by ID.
  Future<void> deleteRecord(String id) async {
    await loadRecords();

    _cachedRecords.removeWhere((r) => r.id == id);

    await _persistRecords();
  }

  /// Clear all records.
  Future<void> clearAllRecords() async {
    _cachedRecords.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Persist current records to storage.
  Future<void> _persistRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedRecords.map((r) => r.encode()).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Analytics helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Total number of detections.
  int get totalDetections =>
      _cachedRecords.where((r) => r.groundTruthIndex >= 0).length;

  /// Number of correct predictions.
  int get correctPredictions => _cachedRecords
      .where((r) => r.groundTruthIndex >= 0 && r.isCorrect)
      .length;

  /// Overall accuracy (0.0 - 1.0).
  double get accuracy =>
      totalDetections == 0 ? 0.0 : correctPredictions / totalDetections;

  /// Get accuracy for a specific class index.
  double accuracyForClass(int classIndex) {
    final classRecords =
        _cachedRecords.where((r) => r.groundTruthIndex == classIndex).toList();
    if (classRecords.isEmpty) return 0.0;

    final correct = classRecords.where((r) => r.isCorrect).length;
    return correct / classRecords.length;
  }

  /// Build a confusion matrix (10x10 for 10 classes).
  /// Returns a 2D list where [actual][predicted] = count.
  List<List<int>> buildConfusionMatrix(int numClasses) {
    final matrix = List.generate(
      numClasses,
      (_) => List.filled(numClasses, 0),
    );

    for (final record in _cachedRecords) {
      final gi = record.groundTruthIndex;
      final pi = record.predictedIndex;
      if (gi >= 0 && gi < numClasses && pi >= 0 && pi < numClasses) {
        matrix[gi][pi]++;
      }
    }

    return matrix;
  }

  /// Get detection counts per class (for bar charts).
  Map<int, int> get detectionsPerClass {
    final counts = <int, int>{};
    for (final record in _cachedRecords) {
      if (record.groundTruthIndex < 0) continue;
      counts[record.groundTruthIndex] =
          (counts[record.groundTruthIndex] ?? 0) + 1;
    }
    return counts;
  }

  /// Get records from the last N days.
  List<DetectionRecord> recordsFromLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _cachedRecords.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }
}
