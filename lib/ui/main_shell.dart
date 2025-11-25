import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'home/class_selection_page.dart';
import 'camera/camera_detection_page.dart';
import 'analytics/dashboard_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ClassSelectionPage(),
    CameraDetectionPage(),
    DashboardPage(),
  ];

  final List<String> _titles = const [
    'Select a Class',
    'Camera',
    'Dashboard',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_rounded),
            label: 'Camera',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_rounded),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
