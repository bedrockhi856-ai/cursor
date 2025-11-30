import 'package:flutter/material.dart';

/// A shimmer loading effect widget for placeholder content.
/// Displays an animated gradient that slides across the widget.
class ShimmerLoader extends StatefulWidget {
  /// Width of the shimmer container
  final double? width;

  /// Height of the shimmer container
  final double? height;

  /// Border radius of the shimmer container
  final BorderRadius? borderRadius;

  /// Base color for the shimmer (the darker color)
  final Color baseColor;

  /// Highlight color for the shimmer (the lighter color)
  final Color highlightColor;

  /// Duration of one shimmer animation cycle
  final Duration duration;

  /// Child widget to wrap with shimmer effect
  final Widget? child;

  const ShimmerLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
    this.child,
  });

  /// Creates a text line shimmer placeholder
  factory ShimmerLoader.text({
    Key? key,
    double width = 150,
    double height = 16,
  }) {
    return ShimmerLoader(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Creates a circular shimmer placeholder (for avatars)
  factory ShimmerLoader.circle({
    Key? key,
    double size = 48,
  }) {
    return ShimmerLoader(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  /// Creates a rectangular card shimmer placeholder
  factory ShimmerLoader.card({
    Key? key,
    double? width,
    double height = 120,
    double radius = 12,
  }) {
    return ShimmerLoader(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Creates a button-shaped shimmer placeholder
  factory ShimmerLoader.button({
    Key? key,
    double width = 120,
    double height = 44,
  }) {
    return ShimmerLoader(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(22),
    );
  }

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// A widget that shows shimmer loading for lists
class ShimmerList extends StatelessWidget {
  /// Number of shimmer items to show
  final int itemCount;

  /// Builder for each shimmer item
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Spacing between items
  final double spacing;

  /// Scroll direction
  final Axis scrollDirection;

  /// Padding around the list
  final EdgeInsets? padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.spacing = 12,
    this.scrollDirection = Axis.vertical,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(
        width: scrollDirection == Axis.horizontal ? spacing : 0,
        height: scrollDirection == Axis.vertical ? spacing : 0,
      ),
      itemBuilder: itemBuilder,
    );
  }
}

/// Pre-built shimmer loaders for common UI patterns
class ShimmerPresets {
  ShimmerPresets._();

  /// Profile header shimmer
  static Widget profileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ShimmerLoader.circle(size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader.text(width: 120, height: 20),
                const SizedBox(height: 8),
                ShimmerLoader.text(width: 80, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Stats card shimmer
  static Widget statsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoader.text(width: 80, height: 12),
          const SizedBox(height: 8),
          ShimmerLoader.text(width: 120, height: 28),
          const SizedBox(height: 12),
          ShimmerLoader.card(height: 8, width: double.infinity, radius: 4),
        ],
      ),
    );
  }

  /// List item shimmer
  static Widget listItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShimmerLoader.circle(size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader.text(width: double.infinity, height: 16),
                const SizedBox(height: 6),
                ShimmerLoader.text(width: 100, height: 12),
              ],
            ),
          ),
          ShimmerLoader.text(width: 50, height: 14),
        ],
      ),
    );
  }

  /// Focus session card shimmer
  static Widget focusSessionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ShimmerLoader.circle(size: 100),
          const SizedBox(height: 20),
          ShimmerLoader.text(width: 150, height: 24),
          const SizedBox(height: 12),
          ShimmerLoader.text(width: 100, height: 14),
          const SizedBox(height: 24),
          ShimmerLoader.button(width: 180, height: 50),
        ],
      ),
    );
  }

  /// Home screen shimmer
  static Widget homeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          ShimmerLoader.text(width: 200, height: 28),
          const SizedBox(height: 8),
          ShimmerLoader.text(width: 150, height: 16),
          const SizedBox(height: 24),
          
          // XP Bar
          ShimmerLoader.card(height: 60, width: double.infinity),
          const SizedBox(height: 24),
          
          // Character and speech bubble
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoader.circle(size: 80),
              const SizedBox(width: 16),
              Expanded(
                child: ShimmerLoader.card(height: 80),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Focus button
          Center(child: ShimmerLoader.circle(size: 150)),
        ],
      ),
    );
  }
}
