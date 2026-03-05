import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Service for platform-related business logic.
class PlatformService {
  /// Validates that a platform name is unique (not in existing platforms).
  ///
  /// Returns true if the name is unique, false if it already exists.
  /// When [currentPlatformId] is provided, it excludes that platform from
  /// the check (useful for updates).
  static bool validatePlatformName(
    String name,
    List<BookingPlatform> existingPlatforms, {
    String? currentPlatformId,
  }) {
    // Check for duplicate names (case-insensitive)
    final lowerCaseName = name.toLowerCase().trim();

    for (final platform in existingPlatforms) {
      // Skip the current platform when updating
      if (currentPlatformId != null && platform.id == currentPlatformId) {
        continue;
      }

      if (platform.name.toLowerCase().trim() == lowerCaseName) {
        return false; // Duplicate found
      }
    }

    return true; // Name is unique
  }

  /// Checks if a platform can be deleted.
  ///
  /// A platform can be deleted if it's not in use by any reservation.
  /// The [reservationCount] parameter should be the number of reservations
  /// using this platform.
  static bool canDeletePlatform(int reservationCount) {
    return reservationCount == 0;
  }

  /// Returns the list of system (default) platforms.
  static List<BookingPlatform> getSystemPlatforms(
    List<BookingPlatform> allPlatforms,
  ) {
    return allPlatforms.where((p) => p.isSystem).toList();
  }

  /// Returns the list of custom (user-created) platforms.
  static List<BookingPlatform> getCustomPlatforms(
    List<BookingPlatform> allPlatforms,
  ) {
    return allPlatforms.where((p) => !p.isSystem).toList();
  }

  /// Checks if a platform is a system platform.
  static bool isSystemPlatform(BookingPlatform platform) {
    return platform.isSystem;
  }
}
