import 'package:flutter/material.dart';

/// A soft, living halo effect: a bright white core that
/// smoothly expands, pauses, and contracts while the surrounding
/// glow changes hue over time (breathing aura).
class BreathingHalo extends StatefulWidget {
  /// Base size of the halo (diameter). The halo scales between
  /// [minScale] and [maxScale] during the breath.
  final double size;

  /// Duration for a single expand or contract segment.
  final Duration breathSegmentDuration;

  /// Pause duration at the extremes (expanded and contracted).
  final Duration holdDuration;

  /// Minimum and maximum scale factors for the breathing.
  final double minScale;
  final double maxScale;

  /// Whether to animate the hue continuously.
  final bool animateHue;

  /// How long a full hue rotation takes.
  final Duration hueCycleDuration;

  /// Overall glow strength multiplier (0..1 recommended).
  final double glowStrength;

  const BreathingHalo({
    super.key,
    this.size = 280,
    this.breathSegmentDuration = const Duration(milliseconds: 1800),
    this.holdDuration = const Duration(milliseconds: 500),
    this.minScale = 0.86,
    this.maxScale = 1.12,
    this.animateHue = true,
    this.hueCycleDuration = const Duration(seconds: 12),
    this.glowStrength = 1.0,
  });

  @override
  State<BreathingHalo> createState() => _BreathingHaloState();
}

class _BreathingHaloState extends State<BreathingHalo>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _breathAnim;
  AnimationController? _hueController;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: widget.breathSegmentDuration,
      value: 0.0,
    );

    _breathAnim = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.animateHue) {
      _hueController = AnimationController(
        vsync: this,
        duration: widget.hueCycleDuration,
      )..repeat();
    }

    // Run continuous cycles: expand -> hold -> contract -> hold -> repeat
    _startBreathingLoop();
  }

  Future<void> _startBreathingLoop() async {
    // Detach from initState
    await Future<void>.delayed(Duration.zero);
    while (mounted) {
      await _breathController.forward();
      if (!mounted) break;
      await Future<void>.delayed(widget.holdDuration);
      if (!mounted) break;
      await _breathController.reverse();
      if (!mounted) break;
      await Future<void>.delayed(widget.holdDuration);
    }
  }

  @override
  void dispose() {
    _hueController?.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _breathController,
        if (_hueController != null) _hueController!,
      ]),
      builder: (context, child) {
        final t = _breathAnim.value; // 0..1 within a segment
        final scale = _lerpDouble(widget.minScale, widget.maxScale, t);

        // Compute a smoothly rotating hue.
        final hueT = _hueController?.value ?? 0.0; // 0..1
        final hue = (hueT * 360.0) % 360.0;
        final auraColor = widget.animateHue
            ? HSVColor.fromAHSV(1.0, hue, 0.85, 1.0).toColor()
            : Colors.white;

        final baseSize = widget.size * scale;

        return IgnorePointer(
          child: SizedBox(
            width: baseSize,
            height: baseSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer diffuse glow
                Container(
                  width: baseSize,
                  height: baseSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        auraColor.withOpacity(0.32 * widget.glowStrength),
                        auraColor.withOpacity(0.14 * widget.glowStrength),
                        Colors.transparent,
                      ],
                      stops: const [0.55, 0.8, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withOpacity(0.15 * widget.glowStrength),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),

                // Mid glow ring
                Container(
                  width: baseSize * 0.86,
                  height: baseSize * 0.86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        auraColor.withOpacity(0.45 * widget.glowStrength),
                        auraColor.withOpacity(0.18 * widget.glowStrength),
                        Colors.transparent,
                      ],
                      stops: const [0.35, 0.7, 1.0],
                    ),
                  ),
                ),

                // Bright white core with soft falloff
                Container(
                  width: baseSize * 0.56,
                  height: baseSize * 0.56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // Soft white center -> transparent edge produces a luminous core
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        Color(0x00FFFFFF),
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
