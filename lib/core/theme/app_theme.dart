import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

/// Main app theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme for the app
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.orange,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.white,
    
    // Color scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.orange,
      surface: AppColors.white,
      error: AppColors.error,
    ),
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.h4,
    ),
    
    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        textStyle: AppTypography.button,
        shape: AppRadius.shapePill,
        minimumSize: const Size(double.infinity, 56),
        elevation: 6,
      ),
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shadowColor: AppColors.shadow,
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.greyLight,
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.greyIcon,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: AppColors.greyBorder,
      thickness: 1,
    ),
  );
}
