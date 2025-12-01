import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../core/models/record_filter.dart';
import '../../core/services/detection_storage_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  RecordFilter _selectedFilter = RecordFilter.verified;

  @override
  Widget build(BuildContext context) {
    final storage = DetectionStorageService.instance;
    final totalDetections = storage.getTotalDetections(_selectedFilter);
    final accuracyPercent = (storage.getAccuracy(_selectedFilter) * 100).toStringAsFixed(1);

    final perClassCounts = storage.getDetectionsPerClass(_selectedFilter);
    final classNames = AppColors.classNames;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RecordFilter>(
                    value: _selectedFilter,
                    isDense: true,
                    icon: const Icon(Icons.filter_list, size: 20),
                    items: RecordFilter.values.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getFilterIcon(filter),
                              size: 16,
                              color: _getFilterColor(filter),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              filter.label,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (filter) {
                      if (filter != null) {
                        setState(() => _selectedFilter = filter);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Detections',
                      value: '$totalDetections',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Overall Accuracy',
                      value: totalDetections == 0 ? '--' : '$accuracyPercent%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Per-Class Performance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: classNames.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final name = classNames[index];
                      final count = perClassCounts[index] ?? 0;
                      final acc = storage.getAccuracyForClass(index, _selectedFilter) * 100;
                      final accText =
                          count == 0 ? '--' : '${acc.toStringAsFixed(1)}%';

                      return Row(
                        children: [
                          Container(
                            width: 10,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: AppColors
                                  .classColors[index % AppColors.classColors.length],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Detections: $count',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Accuracy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                accText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(RecordFilter filter) {
    switch (filter) {
      case RecordFilter.all:
        return Icons.list;
      case RecordFilter.verified:
        return Icons.check_circle;
      case RecordFilter.notVerified:
        return Icons.pending;
    }
  }

  Color _getFilterColor(RecordFilter filter) {
    switch (filter) {
      case RecordFilter.all:
        return AppColors.primaryBlue;
      case RecordFilter.verified:
        return Colors.green;
      case RecordFilter.notVerified:
        return Colors.orange;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
