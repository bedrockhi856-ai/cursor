import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

/// Custom animated pill widget showing a "charging" glow effect
class AnimatedRechargePill extends StatefulWidget {
  final String label;
  final double targetPercentage;
  final Color targetColor;
  final Duration delay;

  const AnimatedRechargePill({
    super.key,
    required this.label,
    required this.targetPercentage,
    required this.targetColor,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedRechargePill> createState() => _AnimatedRechargePillState();
}

class _AnimatedRechargePillState extends State<AnimatedRechargePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: widget.targetPercentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const slate900 = Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: slate900,
          ),
        ),
        const SizedBox(height: 12),

        // The Pill Track
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF4B5563),
                borderRadius: BorderRadius.circular(30),
                // Subtle inner shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Inner shadow simulation using gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.white.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                  // Glow layer behind the fill
                  if (_fillAnimation.value > 0.01)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _fillAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  // Outer glow
                                  BoxShadow(
                                    color: widget.targetColor.withOpacity(0.6 * _glowAnimation.value),
                                    blurRadius: 24 * _glowAnimation.value,
                                    spreadRadius: 4 * _glowAnimation.value,
                                  ),
                                  // Inner intense glow
                                  BoxShadow(
                                    color: widget.targetColor.withOpacity(0.8 * _glowAnimation.value),
                                    blurRadius: 12 * _glowAnimation.value,
                                    spreadRadius: 2 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // The Fill
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _fillAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: widget.targetColor == const Color(0xFFEF4444)
                                  ? [
                                      const Color(0xFFDC2626), // Dark red
                                      const Color(0xFFEF4444), // Red
                                      const Color(0xFFFBBF24), // Yellow/amber
                                    ]
                                  : [
                                      const Color(0xFF65A30D), // Darker lime green
                                      widget.targetColor,
                                      _brightenColor(widget.targetColor, 0.25),
                                    ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              // Neon glow effect
                              BoxShadow(
                                color: widget.targetColor.withOpacity(0.7 * _glowAnimation.value),
                                blurRadius: 20 * _glowAnimation.value,
                                spreadRadius: 2 * _glowAnimation.value,
                              ),
                              BoxShadow(
                                color: widget.targetColor.withOpacity(0.5 * _glowAnimation.value),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 8 * _glowAnimation.value,
                              ),
                            ],
                          ),
                          // Add inner highlight
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.4 * _glowAnimation.value),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.6],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Percentage label at the end of fill
                  if (_fillAnimation.value > 0.15)
                    Positioned(
                      left: 16,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Opacity(
                          opacity: _glowAnimation.value,
                          child: Text(
                            '${(_fillAnimation.value * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _brightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}

/// Onboarding Screen 2 - Success Rate
class SuccessRateScreen extends StatelessWidget {
  const SuccessRateScreen({super.key});

  void _onContinue(BuildContext context) {
    context.go(AppRoutes.onboardingCommitment);
  }

  void _onBack(BuildContext context) {
    context.go(AppRoutes.onboardingGoal);
  }

  @override
  Widget build(BuildContext context) {
    const primaryYellow = Color(0xFFFACC15);
    const slate900 = Color(0xFF0F172A);
    const slate500 = Color(0xFF64748B);
    const borderColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Progress Bar
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: 0.8,
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
                          onTap: () => _onBack(context),
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

                  // Main Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: const [
                        Text(
                          '4x Your Success Rate',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: slate900,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Research shows that starting with small progress makes you significantly more likely to finish what you start.',
                          style: TextStyle(
                            fontSize: 18,
                            color: slate500,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Comparison Container
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Starting Big - Low fill, Red/Orange glow
                              AnimatedRechargePill(
                                label: '😔 Start Big',
                                targetPercentage: 0.35,
                                targetColor: const Color(0xFFEF4444),
                                delay: const Duration(milliseconds: 300),
                              ),

                              const SizedBox(height: 24),

                              // Starting Small - High fill, Yellow/Green glow
                              AnimatedRechargePill(
                                label: '😎 Start Small',
                                targetPercentage: 0.90,
                                targetColor: const Color(0xFF84CC16),
                                delay: const Duration(milliseconds: 800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _onContinue(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryYellow,
                          foregroundColor: slate900,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
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
    );
  }
}
