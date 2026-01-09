import 'package:flutter/material.dart';

/// App-wide typography styles
/// Use these instead of inline TextStyle definitions
class AppTypography {
  AppTypography._();

  /// Default font family
  static const String fontFamily = 'Inter';

  // ============== HEADINGS ==============
  
  /// Heading 1: 28px, bold
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Heading 2: 24px, bold
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Heading 3: 22px, semi-bold
  static const TextStyle h3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Heading 4: 18px, bold
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: fontFamily,
  );

  // ============== BODY TEXT ==============
  
  /// Body large: 18px, normal
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Body: 16px, normal
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Body small: 14px, normal
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontFamily: fontFamily,
  );

  // ============== LABELS ==============
  
  /// Label large: 16px, medium
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Label: 14px, medium
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Label small: 12px, normal
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
    fontFamily: fontFamily,
  );

  // ============== BUTTON TEXT ==============
  
  /// Button text: 18px, semi-bold, white
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: fontFamily,
  );
  
  /// Button large: 22px, semi-bold, white
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: fontFamily,
  );

  // ============== SPECIAL STYLES ==============
  
  /// Stats value: 18px, bold
  static const TextStyle statValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontFamily: fontFamily,
  );
  
  /// Stats label: 12px, secondary color
  static TextStyle statLabel = TextStyle(
    fontSize: 12,
    color: Colors.black54,
    fontFamily: fontFamily,
  );
  
  /// Chat bubble: 16px, white, 1.3 line height
  static const TextStyle chatBubble = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontFamily: fontFamily,
    height: 1.3,
  );
  
  /// Chat title: 18px, bold, white
  static const TextStyle chatTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: fontFamily,
  );
}
