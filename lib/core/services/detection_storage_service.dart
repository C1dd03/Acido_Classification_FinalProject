import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/detection_record.dart';
import '../models/record_filter.dart';

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

  /// Mark a record as verified by ID.
  Future<bool> verifyRecord(String id) async {
    await loadRecords();

    final index = _cachedRecords.indexWhere((r) => r.id == id);
    if (index == -1) return false;

    _cachedRecords[index] = _cachedRecords[index].copyWith(isVerified: true);

    await _persistRecords();
    return true;
  }

  /// Get a record by ID.
  DetectionRecord? getRecordById(String id) {
    try {
      return _cachedRecords.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Persist current records to storage.
  Future<void> _persistRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cachedRecords.map((r) => r.encode()).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Analytics helpers (with filter support)
  // ─────────────────────────────────────────────────────────────────────────

  /// Get filtered records based on the filter option.
  List<DetectionRecord> getFilteredRecords(RecordFilter filter) {
    return _cachedRecords.where((r) {
      if (r.groundTruthIndex < 0) return false;
      switch (filter) {
        case RecordFilter.all:
          return true;
        case RecordFilter.verified:
          return r.isVerified;
        case RecordFilter.notVerified:
          return !r.isVerified;
      }
    }).toList();
  }

  /// Total number of detections based on filter.
  int getTotalDetections(RecordFilter filter) =>
      getFilteredRecords(filter).length;

  /// Number of correct predictions based on filter.
  int getCorrectPredictions(RecordFilter filter) =>
      getFilteredRecords(filter).where((r) => r.isCorrect).length;

  /// Overall accuracy (0.0 - 1.0) based on filter.
  double getAccuracy(RecordFilter filter) {
    final total = getTotalDetections(filter);
    return total == 0 ? 0.0 : getCorrectPredictions(filter) / total;
  }

  /// Get accuracy for a specific class index based on filter.
  double getAccuracyForClass(int classIndex, RecordFilter filter) {
    final classRecords = getFilteredRecords(filter)
        .where((r) => r.groundTruthIndex == classIndex)
        .toList();
    if (classRecords.isEmpty) return 0.0;

    final correct = classRecords.where((r) => r.isCorrect).length;
    return correct / classRecords.length;
  }

  /// Build a confusion matrix based on filter.
  /// Returns a 2D list where [actual][predicted] = count.
  List<List<int>> buildConfusionMatrix(int numClasses, RecordFilter filter) {
    final matrix = List.generate(
      numClasses,
      (_) => List.filled(numClasses, 0),
    );

    for (final record in getFilteredRecords(filter)) {
      final gi = record.groundTruthIndex;
      final pi = record.predictedIndex;
      if (gi >= 0 && gi < numClasses && pi >= 0 && pi < numClasses) {
        matrix[gi][pi]++;
      }
    }

    return matrix;
  }

  /// Get detection counts per class based on filter.
  Map<int, int> getDetectionsPerClass(RecordFilter filter) {
    final counts = <int, int>{};
    for (final record in getFilteredRecords(filter)) {
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
