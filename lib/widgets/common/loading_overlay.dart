import 'package:flutter/material.dart';

/// A loading overlay that can be shown on top of content.
/// Useful for blocking user interaction during async operations.
class LoadingOverlay extends StatelessWidget {
  /// Whether the loading overlay is visible
  final bool isLoading;

  /// The child widget below the overlay
  final Widget child;

  /// The loading indicator widget
  final Widget? loadingWidget;

  /// Background color of the overlay
  final Color? overlayColor;

  /// Optional message to show below the loading indicator
  final String? message;

  /// Whether to blur the background
  final bool blur;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.overlayColor,
    this.message,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        child,

        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.black.withOpacity(0.4),
              child: Center(
                child: _buildLoadingContent(context),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    if (loadingWidget != null) {
      return loadingWidget!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A stateful loading overlay controller
class LoadingOverlayController extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, LoadingController controller) builder;

  const LoadingOverlayController({
    super.key,
    required this.child,
    required this.builder,
  });

  @override
  State<LoadingOverlayController> createState() => _LoadingOverlayControllerState();
}

class _LoadingOverlayControllerState extends State<LoadingOverlayController> {
  bool _isLoading = false;
  String? _message;

  void _show([String? message]) {
    setState(() {
      _isLoading = true;
      _message = message;
    });
  }

  void _hide() {
    setState(() {
      _isLoading = false;
      _message = null;
    });
  }

  Future<T> _wrap<T>(Future<T> Function() operation, [String? message]) async {
    _show(message);
    try {
      return await operation();
    } finally {
      _hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = LoadingController(
      show: _show,
      hide: _hide,
      wrap: _wrap,
    );

    return LoadingOverlay(
      isLoading: _isLoading,
      message: _message,
      child: widget.builder(context, controller),
    );
  }
}

/// Controller for managing loading state
class LoadingController {
  final void Function([String? message]) show;
  final void Function() hide;
  final Future<T> Function<T>(Future<T> Function() operation, [String? message]) wrap;

  const LoadingController({
    required this.show,
    required this.hide,
    required this.wrap,
  });
}

/// Loading indicator styles
class LoadingIndicators {
  LoadingIndicators._();

  /// Pulse loading indicator
  static Widget pulse({double size = 48, Color color = Colors.orange}) {
    return _PulseLoader(size: size, color: color);
  }

  /// Dots loading indicator
  static Widget dots({double dotSize = 12, Color color = Colors.orange}) {
    return _DotsLoader(dotSize: dotSize, color: color);
  }

  /// Simple circular progress
  static Widget circular({double size = 48, Color color = Colors.orange}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Animated pulse loader
class _PulseLoader extends StatefulWidget {
  final double size;
  final Color color;

  const _PulseLoader({required this.size, required this.color});

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// Animated dots loader
class _DotsLoader extends StatefulWidget {
  final double dotSize;
  final Color color;

  const _DotsLoader({required this.dotSize, required this.color});

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final bounce = (value < 0.5)
                ? Curves.easeOut.transform(value * 2)
                : Curves.easeIn.transform((1 - value) * 2);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.dotSize * 0.25),
              child: Transform.translate(
                offset: Offset(0, -bounce * widget.dotSize),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
