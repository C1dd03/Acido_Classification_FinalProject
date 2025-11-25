import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_theme.dart';
import '../../core/services/jersey_classifier_service.dart';
import '../detection/detection_result_page.dart';

class CameraDetectionPage extends StatefulWidget {
  const CameraDetectionPage({
    super.key,
    this.selectedClassIndex,
    this.selectedClassName,
  });

  final int? selectedClassIndex;
  final String? selectedClassName;

  @override
  State<CameraDetectionPage> createState() => _CameraDetectionPageState();
}

class _CameraDetectionPageState extends State<CameraDetectionPage> {
  double _confidence = 0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Placeholder logic until shared state management is added.
    final displayName =
        widget.selectedClassName ?? 'Class ${(widget.selectedClassIndex ?? 0) + 1}';

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.accentTeal.withOpacity(0.9),
                  width: 2,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Ground Truth',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white70),
                        ),
                        child: const Text(
                          'Ground Truth',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Confidence: ${_confidence.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          if (_isProcessing) return;

                          setState(() {
                            _isProcessing = true;
                          });

                          try {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                              source: ImageSource.camera,
                            );

                            if (picked == null) {
                              setState(() {
                                _isProcessing = false;
                              });
                              return;
                            }

                            final file = File(picked.path);

                            final result = await JerseyClassifierService.instance
                                .classifyImage(file);

                            if (!mounted) return;

                            if (result == null) {
                              setState(() {
                                _confidence = 0;
                                _isProcessing = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No prediction from model'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _confidence = result.topConfidence * 100;
                              _isProcessing = false;
                            });

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DetectionResultPage(
                                  detectedClassName: result.topLabel,
                                  confidence: _confidence,
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!mounted) return;
                            setState(() {
                              _isProcessing = false;
                            });
                          }
                        },
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.accentTeal,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
