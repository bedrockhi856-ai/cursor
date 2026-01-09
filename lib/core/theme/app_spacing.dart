import 'package:flutter/material.dart';

/// App-wide spacing constants
/// Use these instead of hardcoded values for consistent layout
class AppSpacing {
  AppSpacing._();

  // ============== BASE SPACING ==============
  
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
  
  /// 2x Extra large: 32.0
  static const double xxl = 32.0;
  
  /// 3x Extra large: 48.0
  static const double xxxl = 48.0;

  // ============== SIZED BOXES ==============
  
  /// Vertical spacer: 4px
  static const SizedBox verticalXs = SizedBox(height: xs);
  
  /// Vertical spacer: 8px
  static const SizedBox verticalSm = SizedBox(height: sm);
  
  /// Vertical spacer: 12px
  static const SizedBox verticalMd = SizedBox(height: md);
  
  /// Vertical spacer: 16px
  static const SizedBox verticalDf = SizedBox(height: df);
  
  /// Vertical spacer: 20px
  static const SizedBox verticalLg = SizedBox(height: lg);
  
  /// Vertical spacer: 24px
  static const SizedBox verticalXl = SizedBox(height: xl);
  
  /// Vertical spacer: 32px
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  
  /// Vertical spacer: 48px
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);
  
  /// Horizontal spacer: 4px
  static const SizedBox horizontalXs = SizedBox(width: xs);
  
  /// Horizontal spacer: 8px
  static const SizedBox horizontalSm = SizedBox(width: sm);
  
  /// Horizontal spacer: 12px
  static const SizedBox horizontalMd = SizedBox(width: md);
  
  /// Horizontal spacer: 16px
  static const SizedBox horizontalDf = SizedBox(width: df);
  
  /// Horizontal spacer: 20px
  static const SizedBox horizontalLg = SizedBox(width: lg);
  
  /// Horizontal spacer: 24px
  static const SizedBox horizontalXl = SizedBox(width: xl);

  // ============== PADDING ==============
  
  /// All sides: 8px
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  
  /// All sides: 12px
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  
  /// All sides: 16px
  static const EdgeInsets paddingDf = EdgeInsets.all(df);
  
  /// All sides: 20px
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  
  /// All sides: 24px
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  
  /// Horizontal: 16px
  static const EdgeInsets paddingHorizontalDf = EdgeInsets.symmetric(horizontal: df);
  
  /// Horizontal: 20px
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  
  /// Horizontal: 24px
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);
  
  /// Screen padding (horizontal: 20px)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg);
}
