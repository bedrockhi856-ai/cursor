import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// DESIGN SYSTEM COMPONENTS
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Reusable components following the Invisible Design methodology.
/// All components use the 8-point grid and consistent visual language.
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// PRIMARY BUTTON
// ═══════════════════════════════════════════════════════════════════════════

/// Primary CTA button with spring animation and haptic feedback
class DSButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  
  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  State<DSButton> createState() => _DSButtonState();
}

class _DSButtonState extends State<DSButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DSAnimations.buttonPressDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96, // Subtle press effect
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DSAnimations.buttonPressCurve,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails _) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }
  
  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          height: DSComponents.buttonHeight,
          decoration: BoxDecoration(
            color: isDisabled 
              ? DSColors.accent.withOpacity(0.5)
              : DSColors.accent,
            borderRadius: DS.br16,
            boxShadow: isDisabled ? null : DSShadows.accentGlow,
          ),
          child: Center(
            child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 20),
                      DS.h8,
                    ],
                    Text(widget.label, style: DSTypography.button),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════════════════

/// Stats card with icon, value, and label
class DSStatCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;
  
  const DSStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  State<DSStatCard> createState() => _DSStatCardState();
}

class _DSStatCardState extends State<DSStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DSAnimations.cardTapDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DSAnimations.cardTapCurve,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: DS.pad16,
          decoration: BoxDecoration(
            color: DSColors.card,
            borderRadius: DS.br16,
            border: Border.all(color: DSColors.border, width: 1),
            boxShadow: DSShadows.elevation1,
          ),
          child: Column(
            children: [
              // Icon with subtle glow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: DSComponents.iconSize,
                  color: widget.iconColor,
                ),
              ),
              DS.v8,
              // Value
              Text(
                widget.value,
                style: DSTypography.statMedium,
              ),
              DS.v4,
              // Label
              Text(
                widget.label,
                style: DSTypography.statLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CHAT BUBBLE (For Buddy messages)
// ═══════════════════════════════════════════════════════════════════════════

/// Chat bubble component with avatar
class DSChatBubble extends StatelessWidget {
  final String title;
  final String message;
  final bool isTyping;
  
  const DSChatBubble({
    super.key,
    required this.title,
    required this.message,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: DSComponents.avatarSize,
          height: DSComponents.avatarSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DSColors.xp.withOpacity(0.2),
                DSColors.xp.withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.psychology_outlined,
            size: 28,
            color: DSColors.xp,
          ),
        ),
        DS.h16,
        // Bubble
        Expanded(
          child: Container(
            padding: DS.pad16,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A), // Deep blue
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DS.radius8),
                topRight: Radius.circular(DS.radius16),
                bottomLeft: Radius.circular(DS.radius16),
                bottomRight: Radius.circular(DS.radius16),
              ),
              boxShadow: DSShadows.elevation2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DSTypography.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                DS.v8,
                if (isTyping)
                  _TypingIndicator()
                else
                  Text(
                    message,
                    style: DSTypography.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      )..repeat(reverse: true);
    });
    
    // Stagger the animations
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _controllers[1].repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controllers[2].repeat(reverse: true);
    });
  }
  
  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.4 + (_controllers[index].value * 0.6),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MICRO CTA (2-Minute Mode link)
// ═══════════════════════════════════════════════════════════════════════════

/// Subtle secondary action link
class DSMicroCTA extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  
  const DSMicroCTA({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Padding(
        padding: DS.padV16,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: DSColors.textSecondary),
              DS.h4,
            ],
            Text(
              label,
              style: DSTypography.labelMedium.copyWith(
                color: DSColors.textSecondary,
                decoration: TextDecoration.underline,
                decorationColor: DSColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS BAR
// ═══════════════════════════════════════════════════════════════════════════

/// Animated progress bar with label
class DSProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;
  final String? label;
  
  const DSProgressBar({
    super.key,
    required this.progress,
    this.color = DSColors.xp,
    this.height = 8,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: DSTypography.labelSmall),
          DS.v8,
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: DSColors.surface,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: AnimatedFractionallySizedBox(
              duration: DSAnimations.normal,
              curve: DSAnimations.springSmooth,
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated fractionally sized box wrapper
class AnimatedFractionallySizedBox extends StatelessWidget {
  final Duration duration;
  final Curve curve;
  final double widthFactor;
  final AlignmentGeometry alignment;
  final Widget child;
  
  const AnimatedFractionallySizedBox({
    super.key,
    required this.duration,
    required this.curve,
    required this.widthFactor,
    required this.alignment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0, end: widthFactor),
      builder: (context, value, child) {
        return FractionallySizedBox(
          widthFactor: value,
          alignment: alignment,
          child: child,
        );
      },
      child: child,
    );
  }
}
