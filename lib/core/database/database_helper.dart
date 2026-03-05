/// Platform-aware database helper.
///
/// This file conditionally exports the correct implementation based on platform:
/// - Native (Android/iOS/desktop): Uses sqflite for SQLite
/// - Web: Uses sqflite_common_ffi (for testing, should be idb_shim for production)
///
/// Both implementations share the same interface, allowing the rest of the
/// application to use DatabaseHelper without platform-specific code.
export 'database_helper_stub.dart'
    if (dart.library.io) 'database_helper_native.dart'
    if (dart.library.js) 'database_helper_web.dart';
