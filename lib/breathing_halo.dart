import 'dart:math';
import 'package:flutter/material.dart';

class BreathingHalo extends StatefulWidget {
  const BreathingHalo({super.key, this.size = 240, required this.scale, this.timerText, this.compactHours = false});
  final double size;
  final double scale;
  final String? timerText;
  final bool compactHours;

  @override
  State<BreathingHalo> createState() => _BreathingHaloState();
}

class _BreathingHaloState extends State<BreathingHalo>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _hueShiftController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _hueShiftAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing opacity animation - 5.5 seconds per cycle (0.5 → 0.9 opacity)
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 5500),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.5, // Minimum opacity (50%)
      end: 0.9,   // Maximum opacity (90%)
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // Hue shift animation - 13 seconds per cycle for subtle color morphing
    _hueShiftController = AnimationController(
      duration: const Duration(milliseconds: 13000),
      vsync: this,
    );

    _hueShiftAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hueShiftController,
      curve: Curves.easeInOut,
    ));

    // Start both animations
    _breathingController.repeat(reverse: true);
    _hueShiftController.repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _hueShiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The glowing halo with breathing and hue shifting
          Transform.scale(
            scale: widget.scale,
            child: AnimatedBuilder(
              animation: Listenable.merge([_breathingAnimation, _hueShiftAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size.square(widget.size),
                  painter: _HaloPainter(
                    opacity: _breathingAnimation.value,
                    hueShift: _hueShiftAnimation.value,
                  ),
                );
              },
            ),
          ),

          // The white sphere (animated)
          Transform.scale(
            scale: widget.scale,
            child: Container(
              width: widget.size * 0.657,
              height: widget.size * 0.657,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),

          // Static digital timer (not affected by breathing animation)
          if (widget.timerText != null)
            Center(
              child: widget.compactHours && widget.timerText!.contains(':') && widget.timerText!.split(':').length == 3
                ? _buildCompactHoursTimer(widget.timerText!)
                : Text(
                    widget.timerText!,
                    style: TextStyle(
                      fontSize: 52, // Smaller, fixed font size
                      fontWeight: FontWeight.w300, // Light weight for professional look
                      color: Colors.black87,
                      fontFamily: 'SF Mono', // Monospace font for digital timer look
                      letterSpacing: 3.5, // Adjusted spacing for smaller text
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactHoursTimer(String timerText) {
    final parts = timerText.split(':');
    if (parts.length != 3) return Text(timerText);
    
    final hours = parts[0];
    final minutes = parts[1];
    final seconds = parts[2];
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Hours - same size as minutes and seconds
        Text(
          hours,
          style: TextStyle(
            fontSize: 52, // Same font size as minutes and seconds
            fontWeight: FontWeight.w300,
            color: Colors.black87,
            fontFamily: 'SF Mono',
            letterSpacing: 1.5, // More compact spacing
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // First colon
        Text(
          ':',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w300,
            color: Colors.black87,
            fontFamily: 'SF Mono',
            letterSpacing: 1.5, // More compact spacing
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // Minutes - normal size
        Text(
          minutes,
          style: TextStyle(
            fontSize: 52, // Normal size for minutes
            fontWeight: FontWeight.w300,
            color: Colors.black87,
            fontFamily: 'SF Mono',
            letterSpacing: 1.5, // More compact spacing
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // Second colon
        Text(
          ':',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w300,
            color: Colors.black87,
            fontFamily: 'SF Mono',
            letterSpacing: 1.5, // More compact spacing
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // Seconds - normal size
        Text(
          seconds,
          style: TextStyle(
            fontSize: 52, // Normal size for seconds
            fontWeight: FontWeight.w300,
            color: Colors.black87,
            fontFamily: 'SF Mono',
            letterSpacing: 1.5, // More compact spacing
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HaloPainter extends CustomPainter {
  final double opacity;
  final double hueShift;

  _HaloPainter({required this.opacity, required this.hueShift});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // White sphere radius (same as in the widget)
    final double sphereRadius = (size.width * 0.657) / 2;
    // Stroke width - covers the entire circle evenly
    final double strokeWidth = sphereRadius * 0.4;

    final rect = Rect.fromCircle(center: center, radius: sphereRadius);

    // Create living, breathing colors with subtle hue shifts
    final animatedColors = _createLivingColors(opacity, hueShift);

    // Perfect SweepGradient with evenly distributed stops
    final sweep = SweepGradient(
      startAngle: 0.0, // Start from right (3 o'clock)
      colors: animatedColors,
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0], // Evenly distributed around circle
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = sweep.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20); // Soft glow

    // Draw the continuous rainbow ring
    canvas.drawCircle(center, sphereRadius, paint);

    // Add a second layer for extra glow and coverage
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.5
      ..shader = sweep.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35); // Softer outer glow

    // Draw outer glow layer with reduced opacity
    canvas.saveLayer(rect.inflate(strokeWidth), Paint()..color = Colors.white.withOpacity(0.3));
    canvas.drawCircle(center, sphereRadius, glowPaint);
    canvas.restore();
  }

  List<Color> _createLivingColors(double breathingOpacity, double hueShiftProgress) {
    // Soft pastel colors: yellow → peach → pink → lavender → blue → back to yellow
    final baseColors = [
      const Color(0xFFFFF4B3), // Soft pastel yellow (start)
      const Color(0xFFFFD4B3), // Soft pastel peach
      const Color(0xFFFFB3D4), // Soft pastel pink
      const Color(0xFFD4B3FF), // Soft pastel lavender
      const Color(0xFFB3D4FF), // Soft pastel blue
      const Color(0xFFFFF4B3), // Back to soft pastel yellow (seamless loop)
    ];

    // Create subtle hue variations for each color
    final livingColors = <Color>[];
    
    for (int i = 0; i < baseColors.length; i++) {
      final baseColor = baseColors[i];
      final hsl = HSLColor.fromColor(baseColor);
      
      // Create very subtle hue shifts for each color (uniform phases)
      double hueOffset = 0.0;
      double saturationMultiplier = 1.0;
      
      // Use consistent, subtle shifts for all colors to maintain uniformity
      final phaseOffset = (i * 2 * pi / 5); // Evenly distribute phase offsets
      
      hueOffset = sin(hueShiftProgress * 2 * pi + phaseOffset) * 5.0; // ±5 degrees (more subtle)
      saturationMultiplier = 1.0 + sin(hueShiftProgress * 2 * pi + phaseOffset + pi/4) * 0.08; // More subtle saturation changes
      
      // Apply subtle hue and saturation shifts
      final shiftedHsl = hsl.withHue((hsl.hue + hueOffset) % 360)
                           .withSaturation((hsl.saturation * saturationMultiplier).clamp(0.0, 1.0));
      
      // Apply breathing opacity
      final finalColor = shiftedHsl.toColor().withOpacity(breathingOpacity);
      livingColors.add(finalColor);
    }

    return livingColors;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _HaloPainter ||
        oldDelegate.opacity != opacity ||
        oldDelegate.hueShift != hueShift;
  }
}