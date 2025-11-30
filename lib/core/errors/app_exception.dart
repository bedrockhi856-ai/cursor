/// Base exception class for all app-specific exceptions
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Network-related exceptions
final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() => const NetworkException(
    message: 'No internet connection. Please check your network.',
    code: 'NO_CONNECTION',
  );

  factory NetworkException.timeout() => const NetworkException(
    message: 'Request timed out. Please try again.',
    code: 'TIMEOUT',
  );

  factory NetworkException.serverError([String? details]) => NetworkException(
    message: details ?? 'Server error occurred. Please try again later.',
    code: 'SERVER_ERROR',
  );
}

/// Storage-related exceptions (Hive, local storage)
final class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.readFailed(String key) => StorageException(
    message: 'Failed to read data for key: $key',
    code: 'READ_FAILED',
  );

  factory StorageException.writeFailed(String key) => StorageException(
    message: 'Failed to write data for key: $key',
    code: 'WRITE_FAILED',
  );

  factory StorageException.deleteFailed(String key) => StorageException(
    message: 'Failed to delete data for key: $key',
    code: 'DELETE_FAILED',
  );

  factory StorageException.initFailed() => const StorageException(
    message: 'Failed to initialize local storage',
    code: 'INIT_FAILED',
  );
}

/// Validation exceptions
final class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  factory ValidationException.invalidField(String field, String reason) => 
    ValidationException(
      message: 'Invalid $field: $reason',
      code: 'INVALID_FIELD',
      fieldErrors: {field: reason},
    );

  factory ValidationException.requiredField(String field) => 
    ValidationException(
      message: '$field is required',
      code: 'REQUIRED_FIELD',
      fieldErrors: {field: 'This field is required'},
    );
}

/// User/Auth exceptions
final class UserException extends AppException {
  const UserException({
    required super.message,
    super.code = 'USER_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory UserException.notFound() => const UserException(
    message: 'User not found',
    code: 'USER_NOT_FOUND',
  );

  factory UserException.notLoggedIn() => const UserException(
    message: 'User is not logged in',
    code: 'NOT_LOGGED_IN',
  );

  factory UserException.sessionExpired() => const UserException(
    message: 'Your session has expired. Please log in again.',
    code: 'SESSION_EXPIRED',
  );
}

/// Focus session exceptions
final class SessionException extends AppException {
  const SessionException({
    required super.message,
    super.code = 'SESSION_ERROR',
    super.originalError,
    super.stackTrace,
  });

  factory SessionException.alreadyActive() => const SessionException(
    message: 'A focus session is already active',
    code: 'ALREADY_ACTIVE',
  );

  factory SessionException.notFound(String id) => SessionException(
    message: 'Focus session not found: $id',
    code: 'NOT_FOUND',
  );

  factory SessionException.invalidDuration() => const SessionException(
    message: 'Invalid session duration',
    code: 'INVALID_DURATION',
  );

  factory SessionException.saveFailed() => const SessionException(
    message: 'Failed to save focus session',
    code: 'SAVE_FAILED',
  );
}

/// Generic unexpected exceptions
final class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred',
    super.code = 'UNEXPECTED',
    super.originalError,
    super.stackTrace,
  });

  factory UnexpectedException.fromError(Object error, [StackTrace? stackTrace]) =>
    UnexpectedException(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
}

/// Extension to convert any exception to AppException
extension ExceptionConverter on Object {
  AppException toAppException([StackTrace? stackTrace]) {
    if (this is AppException) {
      return this as AppException;
    }
    return UnexpectedException.fromError(this, stackTrace);
  }
}
