import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// A loading overlay that covers the screen with a semi-transparent background
/// and shows a loading indicator with optional message
class LoadingOverlay extends StatelessWidget {
  /// Whether the overlay is visible
  final bool isLoading;
  
  /// The child widget to display behind the overlay
  final Widget child;
  
  /// Optional loading message
  final String? message;
  
  /// Background color of the overlay
  final Color? backgroundColor;
  
  /// Color of the loading indicator
  final Color? indicatorColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? AppColors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: indicatorColor ?? AppColors.primary,
                      strokeWidth: 3,
                    ),
                    if (message != null) ...[
                      AppSpacing.verticalDf,
                      Text(
                        message!,
                        style: AppTypography.body.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A simple loading indicator widget
class LoadingIndicator extends StatelessWidget {
  /// Size of the indicator
  final double size;
  
  /// Color of the indicator
  final Color? color;
  
  /// Stroke width of the indicator
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? AppColors.primary,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// A button with loading state
class LoadingButton extends StatelessWidget {
  /// Button label
  final String label;
  
  /// Whether the button is loading
  final bool isLoading;
  
  /// Callback when button is pressed (null if disabled)
  final VoidCallback? onPressed;
  
  /// Background color of the button
  final Color? backgroundColor;
  
  /// Text color of the button
  final Color? textColor;
  
  /// Height of the button
  final double height;

  const LoadingButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.white,
          disabledBackgroundColor: (backgroundColor ?? AppColors.primary).withOpacity(0.6),
          shape: AppRadius.shapePill,
          elevation: isLoading ? 0 : 6,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: textColor ?? AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: AppTypography.button.copyWith(
                  color: textColor ?? AppColors.white,
                ),
              ),
      ),
    );
  }
}

/// A card with loading state that shows shimmer effect
class LoadingCard extends StatelessWidget {
  /// Width of the card
  final double? width;
  
  /// Height of the card
  final double height;
  
  /// Border radius of the card
  final BorderRadius? borderRadius;

  const LoadingCard({
    super.key,
    this.width,
    this.height = 100,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: borderRadius ?? AppRadius.radiusDf,
      ),
      child: const Center(
        child: LoadingIndicator(),
      ),
    );
  }
}

/// Async data wrapper that shows loading/error/data states
class AsyncDataWidget<T> extends StatelessWidget {
  /// Whether data is loading
  final bool isLoading;
  
  /// Error message if any
  final String? error;
  
  /// The data when loaded
  final T? data;
  
  /// Builder for when data is available
  final Widget Function(T data) dataBuilder;
  
  /// Optional loading widget (defaults to LoadingIndicator)
  final Widget? loadingWidget;
  
  /// Optional error widget builder
  final Widget Function(String error)? errorBuilder;
  
  /// Callback to retry on error
  final VoidCallback? onRetry;

  const AsyncDataWidget({
    super.key,
    required this.isLoading,
    this.error,
    this.data,
    required this.dataBuilder,
    this.loadingWidget,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const Center(child: LoadingIndicator(size: 32));
    }

    if (error != null) {
      if (errorBuilder != null) {
        return errorBuilder!(error!);
      }
      return _buildDefaultError(context);
    }

    if (data != null) {
      return dataBuilder(data as T);
    }

    // No data, no error, not loading - show empty state
    return const SizedBox.shrink();
  }

  Widget _buildDefaultError(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            AppSpacing.verticalDf,
            Text(
              error!,
              style: AppTypography.body.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.verticalDf,
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
