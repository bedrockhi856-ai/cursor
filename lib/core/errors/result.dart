import 'package:flutter/foundation.dart';

/// A Result type for handling success and failure states in a type-safe way.
/// Inspired by Rust's Result and Kotlin's sealed classes.
/// 
/// Example usage:
/// ```dart
/// Result<User> getUser() {
///   try {
///     final user = await fetchUser();
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure('Failed to fetch user', e);
///   }
/// }
/// 
/// // Usage
/// final result = await getUser();
/// result.when(
///   success: (user) => print('Got user: ${user.name}'),
///   failure: (message, _) => print('Error: $message'),
/// );
/// ```
@immutable
sealed class Result<T> {
  const Result();

  /// Creates a success result with data
  factory Result.success(T data) = Success<T>;

  /// Creates a failure result with an error message
  factory Result.failure(String message, [Object? error, StackTrace? stackTrace]) = Failure<T>;

  /// Returns true if this is a success result
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure result
  bool get isFailure => this is Failure<T>;

  /// Gets the data if success, null otherwise
  T? get dataOrNull {
    final self = this;
    if (self is Success<T>) {
      return self.data;
    }
    return null;
  }

  /// Gets the data if success, throws if failure
  T get dataOrThrow {
    final self = this;
    if (self is Success<T>) {
      return self.data;
    }
    if (self is Failure<T>) {
      throw self.error ?? Exception(self.message);
    }
    throw Exception('Unknown result type');
  }

  /// Gets the error message if failure, null otherwise
  String? get errorMessage {
    final self = this;
    if (self is Failure<T>) {
      return self.message;
    }
    return null;
  }

  /// Pattern matching for Result
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error) failure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    }
    if (self is Failure<T>) {
      return failure(self.message, self.error);
    }
    throw Exception('Unknown result type');
  }

  /// Pattern matching with optional handlers
  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(String message, Object? error)? failure,
    required R Function() orElse,
  }) {
    final self = this;
    if (self is Success<T> && success != null) {
      return success(self.data);
    }
    if (self is Failure<T> && failure != null) {
      return failure(self.message, self.error);
    }
    return orElse();
  }

  /// Maps the success value to a new type
  Result<R> map<R>(R Function(T data) transform) {
    final self = this;
    if (self is Success<T>) {
      return Result.success(transform(self.data));
    }
    if (self is Failure<T>) {
      return Result.failure(self.message, self.error, self.stackTrace);
    }
    return Result.failure('Unknown result type');
  }

  /// Maps the success value with a function that returns a Result
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    final self = this;
    if (self is Success<T>) {
      return transform(self.data);
    }
    if (self is Failure<T>) {
      return Result.failure(self.message, self.error, self.stackTrace);
    }
    return Result.failure('Unknown result type');
  }

  /// Returns the data or a default value
  T getOrElse(T defaultValue) {
    final self = this;
    if (self is Success<T>) {
      return self.data;
    }
    return defaultValue;
  }

  /// Returns the data or computes a default value
  T getOrElseCompute(T Function() compute) {
    final self = this;
    if (self is Success<T>) {
      return self.data;
    }
    return compute();
  }
}

/// Success result containing data
@immutable
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Failure result containing an error message and optional error object
@immutable
final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.error, this.stackTrace]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && 
           other.message == message && 
           other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);

  @override
  String toString() => 'Failure($message, $error)';
}

/// Extension for async Result operations
extension AsyncResultExtension<T> on Future<Result<T>> {
  /// Maps the success value asynchronously
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    final result = await this;
    if (result is Success<T>) {
      return Result.success(await transform(result.data));
    }
    if (result is Failure<T>) {
      return Result.failure(result.message, result.error, result.stackTrace);
    }
    return Result.failure('Unknown result type');
  }

  /// Handles both success and failure asynchronously
  Future<R> whenAsync<R>({
    required Future<R> Function(T data) success,
    required Future<R> Function(String message, Object? error) failure,
  }) async {
    final result = await this;
    if (result is Success<T>) {
      return await success(result.data);
    }
    if (result is Failure<T>) {
      return await failure(result.message, result.error);
    }
    throw Exception('Unknown result type');
  }
}

/// Helper for running async operations and converting to Result
Future<Result<T>> runCatching<T>(Future<T> Function() block) async {
  try {
    return Result.success(await block());
  } catch (e, stackTrace) {
    return Result.failure(e.toString(), e, stackTrace);
  }
}

/// Helper for running sync operations and converting to Result
Result<T> runCatchingSync<T>(T Function() block) {
  try {
    return Result.success(block());
  } catch (e, stackTrace) {
    return Result.failure(e.toString(), e, stackTrace);
  }
}
