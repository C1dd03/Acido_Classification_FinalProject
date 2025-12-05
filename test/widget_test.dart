// Jersey Identification App Tests
//
// These tests verify the core functionality of the Jersey Identification app,
// including models, services, and basic widget rendering.

import 'package:flutter_test/flutter_test.dart';

import 'package:jersey_identifier/core/models/detection_record.dart';
import 'package:jersey_identifier/core/models/history_filter.dart';
import 'package:jersey_identifier/core/models/record_filter.dart';
import 'package:jersey_identifier/app_theme.dart';

void main() {
  group('DetectionRecord', () {
    test('creates record with correct properties', () {
      final record = DetectionRecord(
        id: 'test-1',
        timestamp: DateTime(2024, 1, 15, 10, 30),
        groundTruthClass: 'Boston Celtics',
        groundTruthIndex: 0,
        predictedClass: 'Boston Celtics',
        predictedIndex: 0,
        confidence: 0.95,
        scores: [0.95, 0.02, 0.01, 0.01, 0.01, 0.0, 0.0, 0.0, 0.0, 0.0],
      );

      expect(record.id, 'test-1');
      expect(record.groundTruthClass, 'Boston Celtics');
      expect(record.predictedClass, 'Boston Celtics');
      expect(record.confidence, 0.95);
      expect(record.isCorrect, true);
      expect(record.isVerified, false);
    });

    test('isCorrect returns true when prediction matches ground truth', () {
      final record = DetectionRecord(
        id: 'test-2',
        timestamp: DateTime.now(),
        groundTruthClass: 'Chicago Bulls',
        groundTruthIndex: 2,
        predictedClass: 'Chicago Bulls',
        predictedIndex: 2,
        confidence: 0.88,
        scores: [],
      );

      expect(record.isCorrect, true);
    });

    test('isCorrect returns false when prediction differs from ground truth', () {
      final record = DetectionRecord(
        id: 'test-3',
        timestamp: DateTime.now(),
        groundTruthClass: 'Chicago Bulls',
        groundTruthIndex: 2,
        predictedClass: 'Miami Heat',
        predictedIndex: 7,
        confidence: 0.75,
        scores: [],
      );

      expect(record.isCorrect, false);
    });

    test('copyWith creates new record with updated isVerified', () {
      final original = DetectionRecord(
        id: 'test-4',
        timestamp: DateTime.now(),
        groundTruthClass: 'Lakers',
        groundTruthIndex: 6,
        predictedClass: 'Lakers',
        predictedIndex: 6,
        confidence: 0.92,
        scores: [],
        isVerified: false,
      );

      final verified = original.copyWith(isVerified: true);

      expect(original.isVerified, false);
      expect(verified.isVerified, true);
      expect(verified.id, original.id);
    });

    test('JSON serialization and deserialization works correctly', () {
      final original = DetectionRecord(
        id: 'test-5',
        timestamp: DateTime(2024, 3, 20, 14, 45),
        groundTruthClass: 'Golden State Warriors',
        groundTruthIndex: 5,
        predictedClass: 'Golden State Warriors',
        predictedIndex: 5,
        confidence: 0.89,
        scores: [0.01, 0.02, 0.03, 0.02, 0.01, 0.89, 0.01, 0.0, 0.01, 0.0],
        isVerified: true,
      );

      final json = original.toJson();
      final decoded = DetectionRecord.fromJson(json);

      expect(decoded.id, original.id);
      expect(decoded.groundTruthClass, original.groundTruthClass);
      expect(decoded.predictedClass, original.predictedClass);
      expect(decoded.confidence, original.confidence);
      expect(decoded.isVerified, original.isVerified);
      expect(decoded.scores.length, original.scores.length);
    });
  });

  group('HistoryFilter', () {
    test('default filter has no active filters', () {
      const filter = HistoryFilter();

      expect(filter.hasActiveFilters, false);
      expect(filter.activeFilterCount, 0);
    });

    test('filter with verification status is active', () {
      const filter = HistoryFilter(verificationFilter: RecordFilter.verified);

      expect(filter.hasActiveFilters, true);
      expect(filter.activeFilterCount, 1);
    });

    test('filter with class index is active', () {
      const filter = HistoryFilter(classIndex: 3);

      expect(filter.hasActiveFilters, true);
      expect(filter.activeFilterCount, 1);
    });

    test('filter with multiple options counts correctly', () {
      const filter = HistoryFilter(
        verificationFilter: RecordFilter.verified,
        classIndex: 2,
        isCorrect: true,
      );

      expect(filter.hasActiveFilters, true);
      expect(filter.activeFilterCount, 3);
    });

    test('copyWith clears values correctly', () {
      const original = HistoryFilter(
        classIndex: 5,
        isCorrect: false,
      );

      final cleared = original.copyWith(
        clearClassIndex: true,
        clearIsCorrect: true,
      );

      expect(cleared.classIndex, null);
      expect(cleared.isCorrect, null);
      expect(cleared.hasActiveFilters, false);
    });

    test('search query filter is active when not empty', () {
      const filter = HistoryFilter(searchQuery: 'Lakers');

      expect(filter.hasActiveFilters, true);
      expect(filter.activeFilterCount, 1);
    });

    test('date range filter is active', () {
      final filter = HistoryFilter(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
      );

      expect(filter.hasActiveFilters, true);
      expect(filter.activeFilterCount, 1); // Date range counts as 1
    });
  });

  group('RecordFilter', () {
    test('has correct labels', () {
      expect(RecordFilter.all.label, 'All');
      expect(RecordFilter.verified.label, 'Verified');
      expect(RecordFilter.notVerified.label, 'Not Verified');
    });

    test('has all three values', () {
      expect(RecordFilter.values.length, 3);
    });
  });

  group('AppColors', () {
    test('has 10 class names', () {
      expect(AppColors.classNames.length, 10);
    });

    test('has 10 class colors', () {
      expect(AppColors.classColors.length, 10);
    });

    test('class names match expected NBA teams', () {
      expect(AppColors.classNames[0], 'Boston Celtics');
      expect(AppColors.classNames[2], 'Chicago Bulls');
      expect(AppColors.classNames[6], 'Los Angeles Lakers');
      expect(AppColors.classNames[9], 'Phoenix Suns');
    });
  });
}
