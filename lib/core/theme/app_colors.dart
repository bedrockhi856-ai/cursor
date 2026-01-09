import 'package:flutter/material.dart';

/// App-wide color palette
/// Centralized location for all colors used throughout the app
class AppColors {
  AppColors._();

  // ============== PRIMARY COLORS ==============
  
  /// Primary brand color (golden yellow)
  static const Color primary = Color(0xFFFFD12A);
  
  /// Primary color with lighter shade
  static const Color primaryLight = Color(0xFFFFF8E1);
  
  /// Primary color for shadows/glows
  static Color primaryShadow = const Color(0xFFFFD12A).withOpacity(0.3);
  
  /// Golden focus button color
  static const Color focusButton = Color(0xFFFFD700);

  // ============== ACCENT COLORS ==============
  
  /// Orange accent (stats, streaks)
  static const Color orange = Color(0xFFFF6B35);
  
  /// Blue accent (time, progress)
  static const Color blue = Color(0xFF2196F3);
  
  /// Deep blue (buddy chat)
  static const Color deepBlue = Color(0xFF1E3A8A);
  
  /// Light blue (character avatar)
  static const Color lightBlue = Color(0xFFE3F2FD);
  
  /// Blue icon color
  static const Color blueIcon = Color(0xFF1976D2);

  // ============== STATUS COLORS ==============
  
  /// Success/complete green
  static const Color success = Colors.green;
  
  /// Warning orange
  static const Color warning = Colors.orange;
  
  /// Error/danger red
  static const Color error = Colors.red;
  
  /// Star/achievement amber
  static const Color star = Colors.amber;

  // ============== NEUTRAL COLORS ==============
  
  /// Pure white
  static const Color white = Colors.white;
  
  /// Pure black
  static const Color black = Colors.black;
  
  /// Black with 54% opacity (secondary text)
  static Color textSecondary = Colors.black54;
  
  /// Grey shade 100 (light backgrounds)
  static Color greyLight = Colors.grey.shade100;
  
  /// Grey shade 200 (borders)
  static Color greyBorder = Colors.grey.shade200;
  
  /// Grey shade 400 (icons)
  static Color greyIcon = Colors.grey.shade400;

  // ============== SHADOW COLORS ==============
  
  /// Default shadow color
  static Color shadow = Colors.black.withOpacity(0.05);
  
  /// Medium shadow
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  
  /// Strong shadow
  static Color shadowStrong = Colors.black.withOpacity(0.1);
  
  /// Card shadow for elevated elements
  static Color shadowCard = Colors.black.withOpacity(0.2);
}
