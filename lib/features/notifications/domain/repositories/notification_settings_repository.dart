import 'package:app_prenotazioni/features/notifications/domain/entities/notification_settings.dart';

/// Repository interface for notification settings.
abstract class NotificationSettingsRepository {
  /// Gets the current notification settings.
  ///
  /// Returns default settings if none exist.
  Future<NotificationSettings> getSettings();

  /// Saves the notification settings.
  Future<void> saveSettings(NotificationSettings settings);

  /// Resets settings to defaults.
  Future<void> resetToDefaults();
}
