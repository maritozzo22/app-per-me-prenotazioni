import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'app_error.dart';

/// Centralized error handling utility
class ErrorHandler {
  /// Convert any error to a user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is AppError) {
      return error.message;
    }

    if (error is DatabaseException) {
      return _getDatabaseErrorMessage(error);
    }

    if (error is FileSystemException) {
      return 'Errore di accesso ai file: ${error.message}';
    }

    if (error is SocketException) {
      return 'Errore di connessione. Verifica la tua rete.';
    }

    if (error is FormatException) {
      return 'Errore nel formato dei dati.';
    }

    if (error is TypeError) {
      return 'Errore interno nel tipo di dati.';
    }

    // Default fallback
    return error.toString().isEmpty
        ? 'Si è verificato un errore imprevisto.'
        : 'Errore: ${error.toString()}';
  }

  /// Get user-friendly message for database errors
  static String _getDatabaseErrorMessage(DatabaseException error) {
    final message = error.toString().toLowerCase();

    if (message.contains('unique') || message.contains('constraint')) {
      return 'Questo elemento esiste già.';
    }

    if (message.contains('no such') || message.contains('not found')) {
      return 'Elemento non trovato.';
    }

    if (message.contains('database is locked')) {
      return 'Il database è occupato. Riprova tra qualche secondo.';
    }

    if (message.contains('disk') || message.contains('i/o')) {
      return 'Errore di accesso al database. Verifica lo spazio disponibile.';
    }

    return 'Errore del database: ${error.toString()}';
  }

  /// Convert any error to an AppError
  static AppError toAppError(
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    if (error is AppError) {
      return error;
    }

    final message = getErrorMessage(error);

    if (error is DatabaseException) {
      return AppError.database(
        message: message,
        technicalDetails: error.toString(),
        exception: null, // DatabaseException is not an Exception
        stackTrace: stackTrace,
      );
    }

    if (error is FileSystemException) {
      return AppError.filesystem(
        message: message,
        technicalDetails: error.path,
        exception: error,
        stackTrace: stackTrace,
      );
    }

    if (error is SocketException) {
      return AppError.database(
        message: message,
        technicalDetails: error.address?.toString(),
        exception: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return AppError.validation(
        message: message,
        technicalDetails: error.message,
        exception: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TypeError) {
      // TypeError is not an Exception in Dart, so pass null
      return AppError.validation(
        message: message,
        technicalDetails: error.toString(),
        exception: null,
        stackTrace: stackTrace,
      );
    }

    // Unknown error type - only store if it's actually an Exception
    final exception = error is Exception ? error : null;
    return AppError.unknown(
      message: message,
      technicalDetails: error.toString(),
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Log error for debugging
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    final appError = toAppError(error, stackTrace);

    // In a real app, this would log to a service like Sentry, Firebase Crashlytics, etc.
    // For now, just print to console
    print('=== ERROR LOG ===');
    print('Type: ${appError.type}');
    print('Message: ${appError.message}');
    if (appError.technicalDetails != null) {
      print('Details: ${appError.technicalDetails}');
    }
    if (stackTrace != null) {
      print('StackTrace:\n$stackTrace');
    }
    print('================');
  }
}
