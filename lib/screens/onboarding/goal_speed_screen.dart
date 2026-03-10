import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../data/providers/user_provider.dart';

/// Growth Pace selection - slider to pick weekly increment rate
/// Onboarding Screen 5 - Goal Speed
class GoalSpeedScreen extends ConsumerStatefulWidget {
  const GoalSpeedScreen({super.key});

  @override
  ConsumerState<GoalSpeedScreen> createState() => _GoalSpeedScreenState();
}

class _GoalSpeedScreenState extends ConsumerState<GoalSpeedScreen> {
  // Month timeline 1-6, default 4 months as recommended
  double _sliderValue = 4.0; // Default to 4 months (recommended)

  // Determine state based on slider value (4 months is recommended)
  _PaceState get _currentState {
    if (_sliderValue < 1.5) {
      return _PaceState.veryFast;
    } else if (_sliderValue < 2.5) {
      return _PaceState.fast;
    } else if (_sliderValue < 4.5) {
      return _PaceState.recommended;
    } else if (_sliderValue < 5.5) {
      return _PaceState.slow;
    } else {
      return _PaceState.verySlow;
    }
  }

  Color get _stateColor {
    switch (_currentState) {
      case _PaceState.veryFast:
        return const Color(0xFFDC2626);
      case _PaceState.fast:
        return const Color(0xFFFF9800);
      case _PaceState.recommended:
        return const Color(0xFF4CAF50);
      case _PaceState.slow:
        return const Color(0xFFFF9800);
      case _PaceState.verySlow:
        return const Color(0xFFDC2626);
    }
  }

  String get _stateLabel {
    switch (_currentState) {
      case _PaceState.veryFast:
        return 'Very Fast';
      case _PaceState.fast:
        return 'Fast';
      case _PaceState.recommended:
        return 'Recommended';
      case _PaceState.slow:
        return 'Slow';
      case _PaceState.verySlow:
        return 'Very Slow';
    }
  }

  void _onFinalize() {
    ref.read(userProvider.notifier).updateGoalSpeed(_sliderValue);
    context.go(AppRoutes.onboardingConsistency);
  }

  void _onBack() {
    context.go(AppRoutes.onboardingCommitment);
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color(0xFFFACC15);
    const slate900 = Color(0xFF0F172A);
    const slate500 = Color(0xFF64748B);
    const borderColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress Bar - Full (1.0)
              SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryYellow),
                ),
              ),

              // Content
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with back button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _onBack,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                  color: slate900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: const Text(
                          'How fast do you want to reach your goal?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: slate900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const Spacer(),

                      // Dynamic Status Display
                      Column(
                        children: [
                          const Text(
                            'Timeline to goal',
                            style: TextStyle(
                              fontSize: 16,
                              color: slate500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _stateColor,
                            ),
                            child: Text(_stateLabel),
                          ),
                          const SizedBox(height: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: _stateColor,
                            ),
                            child: Text('${_sliderValue.round()} ${_sliderValue.round() == 1 ? 'Month' : 'Months'}'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Custom Pace Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // Turtle icon (slow)
                            const Text(
                              '🐢',
                              style: TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 4),

                            // Slider
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 10,
                                  activeTrackColor: _stateColor,
                                  inactiveTrackColor: Colors.grey.shade300,
                                  thumbColor: Colors.white,
                                  thumbShape: const _CustomThumbShape(),
                                  overlayColor: _stateColor.withOpacity(0.2),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                                ),
                                child: Slider(
                                  value: _sliderValue,
                                  min: 1,
                                  max: 6,
                                  onChanged: (value) {
                                    setState(() {
                                      _sliderValue = value;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),
                            // Rabbit icon (fast)
                            const Text(
                              '🐇',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Bottom Button
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _onFinalize,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryYellow,
                              foregroundColor: slate900,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _PaceState { veryFast, fast, recommended, slow, verySlow }

class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 2), 14, shadowPaint);

    // White thumb
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, thumbPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 14, borderPaint);
  }
}
