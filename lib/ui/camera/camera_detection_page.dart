import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
  // Camera
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _errorMessage;

  // Real-time detection state
  String _detectedClass = 'Scanning...';
  double _confidence = 0;
  List<double> _scores = [];
  bool _isProcessingFrame = false;
  int _frameSkipCount = 0;
  static const int _frameSkipInterval = 10; // Process every Nth frame

  // For snapshot capture
  bool _isCapturing = false;

  final _classifier = JerseyClassifierService.instance;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Pre-load the model
      await _classifier.ensureModelLoaded();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras found');
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      // Start image stream for real-time detection
      await _cameraController!.startImageStream(_processCameraFrame);

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Camera error: $e');
    }
  }

  void _processCameraFrame(CameraImage cameraImage) {
    // Skip frames to reduce processing load
    _frameSkipCount++;
    if (_frameSkipCount < _frameSkipInterval) return;
    _frameSkipCount = 0;

    // Don't process if already processing or capturing
    if (_isProcessingFrame || _isCapturing) return;
    _isProcessingFrame = true;

    // Run inference
    final result = _classifier.classifyCameraImage(cameraImage);

    if (result != null && mounted) {
      final cleanLabel = _classifier.cleanLabel(result.topLabel);
      setState(() {
        _detectedClass = cleanLabel;
        _confidence = result.topConfidence * 100;
        _scores = result.scores;
      });
    }

    _isProcessingFrame = false;
  }

  Future<void> _captureAndNavigate() async {
    if (_isCapturing || _cameraController == null || !_isCameraInitialized) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      // Stop image stream before taking picture
      await _cameraController!.stopImageStream();

      // Take picture
      final xFile = await _cameraController!.takePicture();
      final file = File(xFile.path);

      // Run inference on captured image for accurate result
      final result = await _classifier.classifyImage(file);

      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to classify image')),
        );
        // Restart stream
        await _cameraController!.startImageStream(_processCameraFrame);
        setState(() => _isCapturing = false);
        return;
      }

      final cleanLabel = _classifier.cleanLabel(result.topLabel);

      // Navigate to result page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DetectionResultPage(
            detectedClassName: cleanLabel,
            confidence: result.topConfidence * 100,
            scores: result.scores,
          ),
        ),
      ).then((_) {
        // Restart stream when returning
        if (mounted && _cameraController != null) {
          _cameraController!.startImageStream(_processCameraFrame);
          setState(() => _isCapturing = false);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      // Try to restart stream
      try {
        await _cameraController!.startImageStream(_processCameraFrame);
      } catch (_) {}
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Color _getConfidenceColor() {
    if (_confidence >= 70) return Colors.green;
    if (_confidence >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.selectedClassName ?? 
        'Class ${(widget.selectedClassIndex ?? 0) + 1}';

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: _buildCameraPreview(),
          ),

          // Detection frame overlay
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getConfidenceColor().withOpacity(0.9),
                  width: 3,
                ),
              ),
            ),
          ),

          // Top bar with ground truth
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(displayName),
                const Spacer(),
                _buildDetectionOverlay(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading camera & model...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return CameraPreview(_cameraController!);
  }

  Widget _buildTopBar(String displayName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Column(
            children: [
              const Text(
                'Ground Truth',
                style: TextStyle(color: Colors.white70, fontSize: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionOverlay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_basketball,
                color: _getConfidenceColor(),
                size: 28,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _detectedClass,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Confidence bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _confidence / 100,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_confidence.toStringAsFixed(1)}% Confidence',
            style: TextStyle(
              color: _getConfidenceColor(),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tap to capture & view details',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _captureAndNavigate,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getConfidenceColor(),
                    _getConfidenceColor().withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getConfidenceColor().withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _isCapturing
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
