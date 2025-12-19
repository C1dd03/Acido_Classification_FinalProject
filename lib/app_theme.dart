import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryIndigo = Color(0xFF6A5AE0);
  static const Color accentTeal = Color(0xFF3EDBF0);
  static const Color dark = Color(0xFF1E1E2F);
  static const Color backgroundLight = Color(0xFFF5F7FB);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1E1E2F);
  static const Color textSecondary = Color(0xFF6B6F80);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF2A2A2A);

  // Team Colors
  static const List<Color> classColors = [
    Color(0xFF007A33), // Boston Celtics - Green
    Color(0xFF000000), // Brooklyn Nets - Black
    Color(0xFFCE1141), // Chicago Bulls - Red
    Color(0xFF00538C), // Dallas Mavericks - Blue
    Color(0xFFFEC524), // Denver Nuggets - Gold
    Color(0xFF1D428A), // Golden State Warriors - Blue
    Color(0xFF552583), // Los Angeles Lakers - Purple
    Color(0xFF98002E), // Miami Heat - Red
    Color(0xFF00471B), // Milwaukee Bucks - Green
    Color(0xFF1D1160), // Phoenix Suns - Purple
  ];

  static const List<String> classNames = [
    'Boston Celtics',
    'Brooklyn Nets',
    'Chicago Bulls',
    'Dallas Mavericks',
    'Denver Nuggets',
    'Golden State Warriors',
    'Los Angeles Lakers',
    'Miami Heat',
    'Milwaukee Bucks',
    'Phoenix Suns',
  ];
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryBlue,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.accentTeal,
      surface: Colors.white,
      background: AppColors.backgroundLight,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.cardBackground,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerColor,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryBlue,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.accentTeal,
      surface: AppColors.darkCard,
      background: AppColors.darkBackground,
      onBackground: AppColors.darkTextPrimary,
      onSurface: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkCard,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.darkTextPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.darkTextSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
    ),
  );
}
