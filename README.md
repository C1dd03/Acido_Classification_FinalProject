JerseyLens – Basketball Jersey Identification System
System Overview

JerseyLens is a mobile application designed to identify basketball jerseys using computer vision and machine learning. Built with Flutter for cross-platform compatibility, the system leverages TensorFlow Lite to perform on-device image classification, enabling fast, offline, and privacy-friendly jersey identification from either camera input or gallery images.

Key Features

Jersey Identification
Detects and classifies basketball jerseys from captured or uploaded images.

Real-Time Camera Detection
Allows users to perform live jersey recognition using the device camera.

Detection History
Stores past detection results locally for later review.

Analytics Dashboard
Displays statistics and insights based on detection records.

Theme Support
Provides both light and dark mode for improved user experience.

System Architecture

The application follows a clean architecture approach, ensuring separation of concerns, scalability, and maintainability.

1. UI Layer

Handles user interaction and presentation logic.

main_shell.dart – Main application shell and navigation

splash_screen.dart – Initial loading screen

camera_detection_page.dart – Camera interface for real-time detection

detection_result_page.dart – Displays classification results

history_page.dart – Displays saved detection history

dashboard_page.dart – Analytics and performance statistics

2. Business Logic Layer

Manages image processing, model inference, and data handling.

JerseyClassifierService
Responsible for loading the TensorFlow Lite model, preprocessing images, and performing classification.

DetectionStorageService
Handles local storage and retrieval of detection records.

3. Data Models

Defines structured data used throughout the system.

DetectionRecord – Represents a single jersey detection result

RecordFilter – Filters detection records

HistoryFilter – Supports advanced history filtering

System Workflow
1. Image Acquisition

Users can:

Capture an image using the device camera, or

Select an existing image from the gallery.

2. Image Preprocessing

Before inference, the image undergoes:

Resizing to 224 × 224 pixels (model input size)

Color space conversion:

YUV420 → RGB (Android)

BGRA8888 → RGB (iOS)

Pixel value normalization

3. Model Inference

The pre-trained TensorFlow Lite model (model_unquant.tflite) is loaded

The processed image is passed to the model

The model outputs raw confidence scores for each jersey class

4. Post-Processing

Softmax is applied to convert scores into probabilities

Results are sorted by confidence level

Low-confidence predictions are filtered out

5. Result Presentation

Displays the top prediction with its confidence score

Shows alternative predictions when available

Allows users to save results to detection history

6. Data Persistence

Detection results are stored locally

Each record includes:

Prediction result

Confidence score

Timestamp

Supports searching and filtering through history

Technology Stack

Frontend: Flutter (Dart)

Machine Learning: TensorFlow Lite

Image Processing: image package

State Management: Native Flutter state management

Local Storage: Local database for detection history

Performance and Design Considerations

Fully on-device processing for privacy and offline use

Optimized model size for mobile performance

Asynchronous operations to ensure a smooth user interface

Modular architecture for easier maintenance and future expansion
