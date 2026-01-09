import 'package:flutter/material.dart';

/// App-wide border radius constants
/// Use these instead of hardcoded values for consistent styling
class AppRadius {
  AppRadius._();

  // ============== RADIUS VALUES ==============
  
  /// Extra small: 4.0
  static const double xs = 4.0;
  
  /// Small: 8.0
  static const double sm = 8.0;
  
  /// Medium: 12.0
  static const double md = 12.0;
  
  /// Default: 16.0
  static const double df = 16.0;
  
  /// Large: 20.0
  static const double lg = 20.0;
  
  /// Extra large: 24.0
  static const double xl = 24.0;
  
  /// Pill/Capsule: 30.0
  static const double pill = 30.0;
  
  /// Circular: 100.0 (for avatars, circles)
  static const double circular = 100.0;

  // ============== BORDER RADIUS ==============
  
  /// BorderRadius: 4px
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  
  /// BorderRadius: 8px
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  
  /// BorderRadius: 12px
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  
  /// BorderRadius: 16px
  static const BorderRadius radiusDf = BorderRadius.all(Radius.circular(df));
  
  /// BorderRadius: 20px
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  
  /// BorderRadius: 24px
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  
  /// BorderRadius: 30px (pill shape)
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(pill));

  // ============== SHAPE DECORATIONS ==============
  
  /// Rounded rectangle shape: 12px
  static final RoundedRectangleBorder shapeMd = RoundedRectangleBorder(
    borderRadius: radiusMd,
  );
  
  /// Rounded rectangle shape: 16px
  static final RoundedRectangleBorder shapeDf = RoundedRectangleBorder(
    borderRadius: radiusDf,
  );
  
  /// Rounded rectangle shape: 30px (pill)
  static final RoundedRectangleBorder shapePill = RoundedRectangleBorder(
    borderRadius: radiusPill,
  );
}
