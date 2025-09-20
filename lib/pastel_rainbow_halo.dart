import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A soft blurred rainbow halo around a center sphere using a smooth
/// radial gradient of light pastel colors. The halo size is a multiple
/// of the sphere diameter (1.5–2.0x recommended) and blurred for softness.
class PastelRainbowHalo extends StatelessWidget {
  /// The diameter of the sphere at the center, in logical pixels.
  final double sphereDiameter;

  /// Scale factor for the halo diameter relative to the sphere diameter.
  /// Typical values: 1.5 to 2.0.
  final double haloScale;

  /// Gaussian blur sigma to soften the halo.
  final double blurSigma;

  /// Optional overall opacity for the halo (0..1).
  final double opacity;

  const PastelRainbowHalo({
    super.key,
    required this.sphereDiameter,
    this.haloScale = 1.8,
    this.blurSigma = 24,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final haloDiameter = (sphereDiameter * haloScale).clamp(0.0, double.infinity);

    // Ensure enough paint bounds so shadows/blur aren't clipped
    final paintDiameter = haloDiameter + blurSigma * 4;

    // Pastel rainbow colors in radial gradient from center outward
    const pastelColors = <Color>[
      Color(0xFFFFC1E3), // soft pink
      Color(0xFFCFCEFF), // pastel purple
      Color(0xFFBFE0FF), // light blue
      Color(0xFFC8F7DC), // mint green
      Color(0xFFFFF3B0), // soft yellow
      Color(0xFFFFC1E3), // loop back to pink for seamless ring
      Colors.transparent, // edge fade
    ];

    const stops = <double>[
      0.00, 0.18, 0.36, 0.54, 0.72, 0.90, 1.00,
    ];

    return IgnorePointer(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: SizedBox(
          width: paintDiameter,
          height: paintDiameter,
          child: Center(
            child: ClipOval(
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: CustomPaint(
                  size: Size(haloDiameter, haloDiameter),
                  painter: _PastelHaloPainter(
                    colors: pastelColors,
                    stops: stops,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PastelHaloPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> stops;

  _PastelHaloPainter({required this.colors, required this.stops});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gradient = RadialGradient(
      colors: colors,
      stops: stops,
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _PastelHaloPainter oldDelegate) {
    return oldDelegate.colors != colors || oldDelegate.stops != stops;
  }
}
