import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// STUDYBUDDY DESIGN SYSTEM - "INVISIBLE DESIGN" METHODOLOGY
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Based on the Tim Gabe Methodology for world-class UI design.
/// The goal: Create interfaces so intuitive they become invisible.
///
/// Core Principles:
/// 1. 8-Point Grid System - All spacing is multiples of 8
/// 2. 3-Color Rule - 60% Base, 30% Neutral, 10% Accent
/// 3. Typography Physics - Line height, letter spacing, weight hierarchy
/// 4. Spring Animations - Physics-based motion for natural feel
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 1: 8-POINT GRID SPACING SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Spacing tokens based on 8-point grid
/// Use ONLY these values for margins, padding, and gaps
class DS {
  DS._();
  
  // ─────────────────────────────────────────────────────────────────────────
  // SPACING TOKENS (8pt Grid)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// 4px - Fine details (icon to label gap)
  static const double space4 = 4.0;
  
  /// 8px - Tight spacing (internal component spacing)
  static const double space8 = 8.0;
  
  /// 16px - Standard spacing (element separation)
  static const double space16 = 16.0;
  
  /// 24px - Group separation (heading to body)
  static const double space24 = 24.0;
  
  /// 32px - Component separation (card to card)
  static const double space32 = 32.0;
  
  /// 48px - Section separation
  static const double space48 = 48.0;
  
  /// 64px - Major section breaks
  static const double space64 = 64.0;
  
  /// 80px - Hero section spacing
  static const double space80 = 80.0;
  
  /// 120px - Macro breathing room
  static const double space120 = 120.0;
  
  // ─────────────────────────────────────────────────────────────────────────
  // SIZED BOX SPACERS (Pre-built for performance)
  // ─────────────────────────────────────────────────────────────────────────
  
  static const SizedBox v4 = SizedBox(height: space4);
  static const SizedBox v8 = SizedBox(height: space8);
  static const SizedBox v16 = SizedBox(height: space16);
  static const SizedBox v24 = SizedBox(height: space24);
  static const SizedBox v32 = SizedBox(height: space32);
  static const SizedBox v48 = SizedBox(height: space48);
  static const SizedBox v64 = SizedBox(height: space64);
  
  static const SizedBox h4 = SizedBox(width: space4);
  static const SizedBox h8 = SizedBox(width: space8);
  static const SizedBox h16 = SizedBox(width: space16);
  static const SizedBox h24 = SizedBox(width: space24);
  static const SizedBox h32 = SizedBox(width: space32);
  
  // ─────────────────────────────────────────────────────────────────────────
  // PADDING PRESETS (8pt Grid compliant)
  // ─────────────────────────────────────────────────────────────────────────
  
  static const EdgeInsets pad8 = EdgeInsets.all(space8);
  static const EdgeInsets pad16 = EdgeInsets.all(space16);
  static const EdgeInsets pad24 = EdgeInsets.all(space24);
  static const EdgeInsets pad32 = EdgeInsets.all(space32);
  
  static const EdgeInsets padH16 = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets padH24 = EdgeInsets.symmetric(horizontal: space24);
  static const EdgeInsets padV16 = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets padV24 = EdgeInsets.symmetric(vertical: space24);
  
  /// Screen padding - consistent edge margins
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: space24);
  
  // ─────────────────────────────────────────────────────────────────────────
  // BORDER RADIUS (8pt Grid)
  // ─────────────────────────────────────────────────────────────────────────
  
  static const double radius8 = 8.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  static const double radiusPill = 999.0;
  
  static const BorderRadius br8 = BorderRadius.all(Radius.circular(radius8));
  static const BorderRadius br16 = BorderRadius.all(Radius.circular(radius16));
  static const BorderRadius br24 = BorderRadius.all(Radius.circular(radius24));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(radiusPill));
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 2: COLOR SYSTEM (3-Color Rule)
// ═══════════════════════════════════════════════════════════════════════════

/// Color palette following the 3-Color Rule:
/// - 60% Base (canvas)
/// - 30% Neutral (text, borders)
/// - 10% Accent (CTAs, highlights)
class DSColors {
  DSColors._();
  
  // ─────────────────────────────────────────────────────────────────────────
  // BASE COLORS (60% of interface)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Pure white canvas
  static const Color background = Color(0xFFFFFFFF);
  
  /// Slightly warm off-white for sections
  static const Color surface = Color(0xFFFAFAFA);
  
  /// Card background
  static const Color card = Color(0xFFFFFFFF);
  
  // ─────────────────────────────────────────────────────────────────────────
  // NEUTRAL COLORS (30% of interface)
  // Uses opacity for hierarchy instead of different grays
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Base neutral (charcoal)
  static const Color neutral = Color(0xFF1A1A1A);
  
  /// Primary text - 100% opacity
  static const Color textPrimary = Color(0xFF1A1A1A);
  
  /// Secondary text - 60% opacity  
  static const Color textSecondary = Color(0x991A1A1A); // 60%
  
  /// Tertiary text - 40% opacity
  static const Color textTertiary = Color(0x661A1A1A); // 40%
  
  /// Disabled text - 30% opacity
  static const Color textDisabled = Color(0x4D1A1A1A); // 30%
  
  /// Border color - 10% opacity
  static const Color border = Color(0x1A1A1A1A); // 10%
  
  /// Subtle divider - 6% opacity
  static const Color divider = Color(0x0F1A1A1A); // 6%
  
  // ─────────────────────────────────────────────────────────────────────────
  // ACCENT COLORS (10% of interface)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Primary accent - Gold (for CTAs)
  static const Color accent = Color(0xFFFFD700);
  
  /// Accent pressed state
  static const Color accentPressed = Color(0xFFE6C200);
  
  /// Accent shadow/glow
  static Color accentGlow = const Color(0xFFFFD700).withOpacity(0.25);
  
  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC COLORS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Streak/Fire orange
  static const Color streak = Color(0xFFFF6B35);
  
  /// XP/Progress blue
  static const Color xp = Color(0xFF4F9DFF);
  
  /// Gems purple
  static const Color gems = Color(0xFF9B59B6);
  
  /// Success green
  static const Color success = Color(0xFF34C759);
  
  /// Warning amber
  static const Color warning = Color(0xFFFFCC00);
  
  /// Error red
  static const Color error = Color(0xFFFF3B30);
  
  // ─────────────────────────────────────────────────────────────────────────
  // SHADOW COLORS (Derived from neutrals)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Subtle shadow
  static const Color shadowLight = Color(0x0A000000); // 4%
  
  /// Standard shadow
  static const Color shadowMedium = Color(0x14000000); // 8%
  
  /// Elevated shadow
  static const Color shadowStrong = Color(0x1F000000); // 12%
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 3: TYPOGRAPHY SYSTEM (Physics-Based)
// ═══════════════════════════════════════════════════════════════════════════

/// Typography system applying:
/// - Headings: Line height 1.1-1.3x, letter spacing -1% to -2%
/// - Body: Line height 1.4-1.5x, letter spacing 0%
/// - Hierarchy through weight + opacity, not just size
class DSTypography {
  DSTypography._();
  
  static const String _fontFamily = 'Inter';
  
  // ─────────────────────────────────────────────────────────────────────────
  // DISPLAY (Hero text, large headings)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Display Large - 32px, bold, tight
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1, // Tight for large text
    letterSpacing: -0.5, // ~-1.5% for headlines
    color: DSColors.textPrimary,
  );
  
  /// Display Medium - 28px, semibold
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: -0.4, // ~-1.4%
    color: DSColors.textPrimary,
  );
  
  /// Display Small - 24px, semibold
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
    color: DSColors.textPrimary,
  );
  
  // ─────────────────────────────────────────────────────────────────────────
  // HEADINGS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Heading Large - 20px, semibold
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: DSColors.textPrimary,
  );
  
  /// Heading Medium - 18px, semibold
  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
    color: DSColors.textPrimary,
  );
  
  /// Heading Small - 16px, semibold
  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: DSColors.textPrimary,
  );
  
  // ─────────────────────────────────────────────────────────────────────────
  // BODY TEXT
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Body Large - 16px, regular, generous line height
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // Breathing room for body
    letterSpacing: 0,
    color: DSColors.textPrimary,
  );
  
  /// Body Medium - 14px, regular
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
    color: DSColors.textPrimary,
  );
  
  /// Body Small - 12px, regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.1, // Slightly looser for small text
    color: DSColors.textSecondary,
  );
  
  // ─────────────────────────────────────────────────────────────────────────
  // LABELS (UI Elements)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Label Large - 16px, medium weight
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0,
    color: DSColors.textPrimary,
  );
  
  /// Label Medium - 14px, medium weight
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0,
    color: DSColors.textPrimary,
  );
  
  /// Label Small - 12px, medium weight
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.1,
    color: DSColors.textSecondary,
  );
  
  // ─────────────────────────────────────────────────────────────────────────
  // BUTTON TEXT
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Button text - 16px, semibold, slightly tight
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.1,
    color: Colors.white,
  );
  
  /// Button text large - 18px
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
    color: Colors.white,
  );
  
  // ─────────────────────────────────────────────────────────────────────────
  // STAT NUMBERS (Monospace-feel for numbers)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Stat value - 24px, bold
  static const TextStyle statLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.3,
    color: DSColors.textPrimary,
  );
  
  /// Stat value - 18px, bold
  static const TextStyle statMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
    color: DSColors.textPrimary,
  );
  
  /// Stat label - 12px, secondary
  static const TextStyle statLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.2,
    color: DSColors.textSecondary,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 4: SPRING ANIMATION CURVES
// ═══════════════════════════════════════════════════════════════════════════

/// Spring-based animation curves for natural, physics-based motion
class DSAnimations {
  DSAnimations._();
  
  // ─────────────────────────────────────────────────────────────────────────
  // DURATIONS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Instant feedback (button press)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// Standard transition
  static const Duration normal = Duration(milliseconds: 250);
  
  /// Deliberate motion (modals, page transitions)
  static const Duration slow = Duration(milliseconds: 400);
  
  /// Emphasis animation (celebrations)
  static const Duration emphasis = Duration(milliseconds: 600);
  
  // ─────────────────────────────────────────────────────────────────────────
  // SPRING CURVES (Natural physics)
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Snappy spring - for buttons, toggles
  /// Overshoots slightly then settles quickly
  static const Curve springSnappy = Curves.easeOutBack;
  
  /// Smooth spring - for modals, cards
  static const Curve springSmooth = Curves.easeOutCubic;
  
  /// Bouncy spring - for celebrations, rewards
  static const Curve springBouncy = Curves.elasticOut;
  
  /// Decelerate - for elements entering view
  static const Curve decelerate = Curves.decelerate;
  
  /// Emphasize - for attention-grabbing
  static const Curve emphasize = Curves.easeOutExpo;
  
  // ─────────────────────────────────────────────────────────────────────────
  // PRE-BUILT ANIMATION SPECS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Button press animation spec
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  static const Curve buttonPressCurve = Curves.easeInOut;
  
  /// Card hover/tap animation spec
  static const Duration cardTapDuration = Duration(milliseconds: 150);
  static const Curve cardTapCurve = Curves.easeOutCubic;
  
  /// Page transition spec
  static const Duration pageDuration = Duration(milliseconds: 300);
  static const Curve pageCurve = Curves.easeOutCubic;
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 5: SHADOWS & ELEVATION
// ═══════════════════════════════════════════════════════════════════════════

/// Shadow system for depth and hierarchy
class DSShadows {
  DSShadows._();
  
  /// Subtle lift (cards at rest)
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: DSColors.shadowLight,
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
  
  /// Standard elevation (cards, buttons)
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: DSColors.shadowLight,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: DSColors.shadowMedium,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  /// High elevation (modals, dropdowns)
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: DSColors.shadowLight,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: DSColors.shadowMedium,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  /// Accent glow (for CTA buttons)
  static List<BoxShadow> accentGlow = [
    BoxShadow(
      color: DSColors.accentGlow,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Streak glow
  static List<BoxShadow> streakGlow = [
    BoxShadow(
      color: DSColors.streak.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Inner highlight (3D button effect)
  static const List<BoxShadow> innerHighlight = [
    BoxShadow(
      color: Color(0x33FFFFFF), // 20% white
      blurRadius: 0,
      offset: Offset(0, 1),
      blurStyle: BlurStyle.inner,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 6: COMPONENT TOKENS
// ═══════════════════════════════════════════════════════════════════════════

/// Reusable component dimensions
class DSComponents {
  DSComponents._();
  
  // ─────────────────────────────────────────────────────────────────────────
  // BUTTONS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Primary button height
  static const double buttonHeight = 56.0;
  
  /// Secondary button height
  static const double buttonHeightSmall = 48.0;
  
  /// Icon button size
  static const double iconButtonSize = 48.0;
  
  // ─────────────────────────────────────────────────────────────────────────
  // CARDS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(DS.space16);
  
  /// Card border radius
  static const BorderRadius cardRadius = DS.br16;
  
  // ─────────────────────────────────────────────────────────────────────────
  // ICONS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Standard icon size
  static const double iconSize = 24.0;
  
  /// Large icon size
  static const double iconSizeLarge = 32.0;
  
  /// Small icon size
  static const double iconSizeSmall = 16.0;
  
  // ─────────────────────────────────────────────────────────────────────────
  // AVATARS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Standard avatar size
  static const double avatarSize = 48.0;
  
  /// Large avatar size
  static const double avatarSizeLarge = 64.0;
  
  /// Small avatar/badge size
  static const double avatarSizeSmall = 32.0;
  
  // ─────────────────────────────────────────────────────────────────────────
  // CONTENT CONSTRAINTS
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Max width for readable text (50-75 characters)
  static const double maxTextWidth = 600.0;
  
  /// Max content width for desktop
  static const double maxContentWidth = 960.0;
}
