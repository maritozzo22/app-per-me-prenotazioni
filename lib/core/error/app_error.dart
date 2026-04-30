/// Application error types for categorizing errors
enum AppErrorType {
  database,
  network,
  validation,
  permission,
  filesystem,
  unknown,
}

/// Application error class with user-friendly messages
class AppError {
  final AppErrorType type;
  final String message;
  final String? technicalDetails;
  final Exception? originalException;
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('AppError: $message');
    if (technicalDetails != null) {
      buffer.write('\nTechnical: $technicalDetails');
    }
    if (originalException != null) {
      buffer.write('\nException: $originalException');
    }
    return buffer.toString();
  }

  /// Create a database error
  factory AppError.database({
    required String message,
    String? technicalDetails,
    Exception? exception,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: AppErrorType.database,
      message: message,
      technicalDetails: technicalDetails,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Create a validation error
  factory AppError.validation({
    required String message,
    String? technicalDetails,
    Exception? exception,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: AppErrorType.validation,
      message: message,
      technicalDetails: technicalDetails,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Create a permission error
  factory AppError.permission({
    required String message,
    String? technicalDetails,
    Exception? exception,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: AppErrorType.permission,
      message: message,
      technicalDetails: technicalDetails,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Create a filesystem error
  factory AppError.filesystem({
    required String message,
    String? technicalDetails,
    Exception? exception,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: AppErrorType.filesystem,
      message: message,
      technicalDetails: technicalDetails,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Create an unknown error
  factory AppError.unknown({
    required String message,
    String? technicalDetails,
    Exception? exception,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: AppErrorType.unknown,
      message: message,
      technicalDetails: technicalDetails,
      originalException: exception,
      stackTrace: stackTrace,
    );
  }
}
