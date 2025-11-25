import 'package:flutter/material.dart';

import '../../app_theme.dart';

class DetectionResultPage extends StatelessWidget {
  const DetectionResultPage({
    super.key,
    this.detectedClassName = 'Boston Celtics',
    this.confidence = 0.0,
    this.scores,
  });

  final String detectedClassName;
  final double confidence;
  final List<double>? scores;

  @override
  Widget build(BuildContext context) {
    final confidenceText = confidence.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detection Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detected Class',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detectedClassName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Confidence',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$confidenceText%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Class Probabilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: AppColors.classNames.length,
                itemBuilder: (context, index) {
                  final color = AppColors.classColors[index];
                  final className = AppColors.classNames[index];
                  final score = (scores != null && index < scores!.length)
                      ? scores![index]
                      : 0.0;
                  final scorePercent = (score * 100).toStringAsFixed(1);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            className,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: AppColors.backgroundLight,
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: score.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 45,
                          child: Text(
                            '$scorePercent%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Save result.
                    },
                    child: const Text('Save result'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },
                    child: const Text('Retake'),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to confusion matrix screen for this detection.
                },
                icon: const Icon(Icons.grid_on_rounded),
                label: const Text('View Confusion Matrix'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
