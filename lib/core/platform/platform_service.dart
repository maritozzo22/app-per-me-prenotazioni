import 'package:flutter/foundation.dart';

/// Service for detecting the current platform and providing platform-specific utilities.
class PlatformService {
  PlatformService._();

  /// Returns true if running on Android.
  static bool get isAndroid => !kIsWeb;

  /// Returns true if running on Web.
  static bool get isWeb => kIsWeb;

  /// Returns the platform name for logging purposes.
  static String get platformName => kIsWeb ? 'Web' : 'Android';

  /// Returns true if notifications are supported on this platform.
  static bool get notificationsSupported => !kIsWeb;
}
