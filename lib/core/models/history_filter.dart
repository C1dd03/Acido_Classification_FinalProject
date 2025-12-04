import 'record_filter.dart';

/// Advanced filter options for history page.
class HistoryFilter {
  final RecordFilter verificationFilter;
  final int? classIndex; // null = all classes
  final bool? isCorrect; // null = all, true = correct only, false = incorrect only

  const HistoryFilter({
    this.verificationFilter = RecordFilter.all,
    this.classIndex,
    this.isCorrect,
  });

  HistoryFilter copyWith({
    RecordFilter? verificationFilter,
    int? classIndex,
    bool? isCorrect,
    bool clearClassIndex = false,
    bool clearIsCorrect = false,
  }) {
    return HistoryFilter(
      verificationFilter: verificationFilter ?? this.verificationFilter,
      classIndex: clearClassIndex ? null : (classIndex ?? this.classIndex),
      isCorrect: clearIsCorrect ? null : (isCorrect ?? this.isCorrect),
    );
  }

  /// Check if any filter is active (not default).
  bool get hasActiveFilters =>
      verificationFilter != RecordFilter.all ||
      classIndex != null ||
      isCorrect != null;

  /// Count of active filters.
  int get activeFilterCount {
    int count = 0;
    if (verificationFilter != RecordFilter.all) count++;
    if (classIndex != null) count++;
    if (isCorrect != null) count++;
    return count;
  }
}
