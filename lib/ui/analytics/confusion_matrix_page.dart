import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../../core/services/detection_storage_service.dart';

class ConfusionMatrixPage extends StatelessWidget {
  const ConfusionMatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    final numClasses = AppColors.classNames.length;
    final storage = DetectionStorageService.instance;
    final matrix = storage.buildConfusionMatrix(numClasses);

    int maxCount = 0;
    for (int r = 0; r < numClasses; r++) {
      for (int c = 0; c < numClasses; c++) {
        if (matrix[r][c] > maxCount) {
          maxCount = matrix[r][c];
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confusion Matrix'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confusion Matrix',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ground Truth vs Predicted Model Output',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
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
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numClasses,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: numClasses * numClasses,
                  itemBuilder: (context, index) {
                    final row = index ~/ numClasses;
                    final col = index % numClasses;
                    final count = matrix[row][col];

                    final baseOpacity = 0.1;
                    final maxExtra = 0.9;
                    final intensity = maxCount == 0
                        ? baseOpacity
                        : (baseOpacity + maxExtra * (count / maxCount));

                    return Container(
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryBlue.withOpacity(intensity.clamp(0.1, 1.0)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count == 0 ? '' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
