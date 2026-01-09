import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// A primary focus button with pulsing glow effect
/// Used on the home screen to start focus sessions
class FocusButton extends StatelessWidget {
  /// Button label
  final String label;
  
  /// Callback when button is tapped
  final VoidCallback onTap;
  
  /// Callback when long press starts
  final GestureLongPressStartCallback? onLongPressStart;
  
  /// Callback when long press ends
  final GestureLongPressEndCallback? onLongPressEnd;
  
  /// Callback when long press completes
  final GestureLongPressCallback? onLongPress;
  
  /// Scale animation value (default 1.0)
  final double scale;
  
  /// Pulse opacity for glow effect (0.0 to 1.0)
  final double pulseOpacity;
  
  /// Whether button is in long press state
  final bool isLongPressing;
  
  /// Long press fill progress (0.0 to 1.0)
  final double fillProgress;

  const FocusButton({
    super.key,
    this.label = 'Focus',
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onLongPress,
    this.scale = 1.0,
    this.pulseOpacity = 0.5,
    this.isLongPressing = false,
    this.fillProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      onLongPress: onLongPress,
      child: Transform.scale(
        scale: scale,
        child: Stack(
          children: [
            // Pulsing glow effect
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.focusButton.withOpacity(pulseOpacity * 0.3),
                borderRadius: AppRadius.radiusMd,
              ),
            ),
            // Main button with long press fill effect
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.focusButton,
                borderRadius: AppRadius.radiusMd,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.focusButton.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Fill effect from left to right
                  if (isLongPressing)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fillProgress,
                          heightFactor: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.3),
                              borderRadius: AppRadius.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Button text
                  Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple focus button without animations (for static use)
class SimpleFocusButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SimpleFocusButton({
    super.key,
    this.label = 'Focus',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FocusButton(
      label: label,
      onTap: onTap,
    );
  }
}
