/// Stub implementation for dart analyzer.
///
/// This file is never actually used at runtime - it exists only to satisfy
/// the dart analyzer. The actual implementation is selected via conditional
/// exports in database_helper.dart.
///
/// The real implementations are:
/// - database_helper_native.dart for Android/iOS/desktop (sqflite)
/// - database_helper_web.dart for web (sqflite_common_ffi for testing)
class DatabaseHelper {
  DatabaseHelper._internal();
  factory DatabaseHelper() => throw UnimplementedError();
  factory DatabaseHelper.forTesting() => throw UnimplementedError();

  Future<dynamic> get database => throw UnimplementedError();
  Future<void> close() => throw UnimplementedError();
}
