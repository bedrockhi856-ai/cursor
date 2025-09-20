import 'package:flutter/material.dart';

/// A reusable size-breathing wrapper that animates smoothly between
/// [minSize] and [maxSize] with a hold at the extremes, looping forever.
class BreathingSizer extends StatefulWidget {
  final double minSize; // e.g., 250
  final double maxSize; // e.g., 270
  final Duration breathSegmentDuration; // expand/contract duration
  final Duration holdDuration; // pause at extremes
  final Curve curve;

  /// Build the child for the current size.
  final Widget Function(double size) builder;

  const BreathingSizer({
    super.key,
    required this.minSize,
    required this.maxSize,
    required this.builder,
    this.breathSegmentDuration = const Duration(milliseconds: 1200),
    this.holdDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
  });

  @override
  State<BreathingSizer> createState() => _BreathingSizerState();
}

class _BreathingSizerState extends State<BreathingSizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.breathSegmentDuration,
      value: 0.0,
    );
    _anim = CurvedAnimation(parent: _controller, curve: widget.curve);
    _loop();
  }

  Future<void> _loop() async {
    await Future<void>.delayed(Duration.zero);
    while (mounted) {
      await _controller.forward();
      if (!mounted) break;
      await Future<void>.delayed(widget.holdDuration);
      if (!mounted) break;
      await _controller.reverse();
      if (!mounted) break;
      await Future<void>.delayed(widget.holdDuration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _anim.value; // 0..1
        final size = _lerp(widget.minSize, widget.maxSize, t);
        return widget.builder(size);
      },
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
