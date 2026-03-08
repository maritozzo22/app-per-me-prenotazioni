import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';

/// Provider for NotificationDatasource
final notificationDatasourceProvider = Provider<NotificationDatasource>((ref) {
  return NotificationDatasource(DatabaseHelper());
});
