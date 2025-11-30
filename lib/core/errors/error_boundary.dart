import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app_exception.dart';

/// A widget that catches errors in its subtree and displays a fallback UI.
/// Similar to React's ErrorBoundary pattern.
class ErrorBoundary extends StatefulWidget {
  /// The child widget tree to protect
  final Widget child;

  /// Custom error widget builder
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  /// Callback when an error is caught
  final void Function(Object error, StackTrace? stackTrace)? onError;

  /// Whether to show error details in debug mode
  final bool showDetailsInDebug;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showDetailsInDebug = true,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Catch Flutter framework errors
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
    widget.onError?.call(details.exception, details.stack);
    
    if (mounted) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    }
  }

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return _DefaultErrorWidget(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _resetError,
        showDetails: widget.showDetailsInDebug && kDebugMode,
      );
    }

    return widget.child;
  }
}

/// Default error widget shown when an error occurs
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;
  final bool showDetails;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    required this.onRetry,
    this.showDetails = false,
  });

  String get _errorTitle {
    if (error is AppException) {
      return (error as AppException).message;
    }
    return 'Something went wrong';
  }

  String get _errorCode {
    if (error is AppException) {
      return (error as AppException).code ?? 'UNKNOWN';
    }
    return 'UNEXPECTED';
  }

  IconData get _errorIcon {
    if (error is NetworkException) {
      return Icons.wifi_off_rounded;
    }
    if (error is StorageException) {
      return Icons.storage_rounded;
    }
    if (error is ValidationException) {
      return Icons.warning_rounded;
    }
    if (error is SessionException) {
      return Icons.timer_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  Color get _errorColor {
    if (error is NetworkException) {
      return Colors.orange;
    }
    if (error is ValidationException) {
      return Colors.amber;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon with animated container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _errorIcon,
                    size: 50,
                    color: _errorColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Error title
                Text(
                  _errorTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Error code
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Error Code: $_errorCode',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Helpful message
                Text(
                  'Don\'t worry, your progress is saved.\nTap the button below to try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Retry button
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                // Debug details
                if (showDetails) ...[
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Debug Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (stackTrace != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            stackTrace.toString().split('\n').take(5).join('\n'),
                            style: TextStyle(
                              fontSize: 9,
                              fontFamily: 'monospace',
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget to catch errors in a specific subtree without replacing the entire screen
class ErrorHandler extends StatelessWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;

  const ErrorHandler({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (errorBuilder != null) {
        return errorBuilder!(details.exception);
      }
      return _InlineErrorWidget(error: details.exception);
    };
    return child;
  }
}

/// Compact inline error widget for use within the app
class _InlineErrorWidget extends StatelessWidget {
  final Object error;

  const _InlineErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error is AppException
                  ? (error as AppException).message
                  : 'An error occurred',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
