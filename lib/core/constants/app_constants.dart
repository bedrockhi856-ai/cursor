import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  // Primary colors
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color mediumBlue = Color(0xFF1976D2);
  
  // Semantic colors
  static const Color success = Colors.green;
  static const Color error = Color(0xFFFF1744);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color mediumRed = Color(0xFFD32F2F);
  
  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  AppColors._(); // Private constructor to prevent instantiation
}

/// App-wide string constants
class AppStrings {
  static const String appName = 'StudyBuddy';
  static const String freedomSwitchTitle = 'Freedom Switch';
  static const String freedomSwitchSubtitle = 'Turn ON to unlock your potential';
  static const String freedomSwitchUnlocked = 'Your potential is now unlocked!';
  static const String selectCharacter = 'Select your character';
  static const String continueButton = 'Continue';
  static const String freedom = 'Freedom';
  static const String stayFocused = 'Stay Focused';
  static const String slideToSurrender = 'Slide to Surrender';
  static const String surrendered = 'Surrendered!';
  static const String betterLuckNextTime = 'Better luck next time';
  
  AppStrings._();
}

/// App-wide dimension constants
class AppDimens {
  static const double defaultPadding = 20.0;
  static const double defaultRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
  
  AppDimens._();
}

/// Font family constants
class AppFonts {
  static const String inter = 'Inter';
  static const String georgia = 'Georgia';
  static const String arial = 'Arial';
  
  AppFonts._();
}
