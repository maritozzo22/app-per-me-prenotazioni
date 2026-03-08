import 'package:app_prenotazioni/features/notifications/domain/entities/notification_settings.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';

class NotificationSettingsRepositoryImpl implements NotificationSettingsRepository {
  final NotificationDatasource _dataSource;

  NotificationSettingsRepositoryImpl(this._dataSource);

  @override
  Future<NotificationSettings> getSettings() async {
    final data = await _dataSource.getNotificationSettings();
    if (data == null) {
      return NotificationSettings.defaults();
    }
    return NotificationSettings.fromJson(data);
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    await _dataSource.saveNotificationSettings(settings.toJson());
  }

  @override
  Future<void> resetToDefaults() async {
    await saveSettings(NotificationSettings.defaults());
  }
}
