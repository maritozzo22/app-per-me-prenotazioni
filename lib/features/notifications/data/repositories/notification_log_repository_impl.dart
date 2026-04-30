import 'package:app_prenotazioni/features/notifications/domain/entities/notification_log.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_log_repository.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';

class NotificationLogRepositoryImpl implements NotificationLogRepository {
  final NotificationDatasource _dataSource;

  NotificationLogRepositoryImpl(this._dataSource);

  @override
  Future<void> addLog(NotificationLog log) async {
    await _dataSource.insertNotificationLog(log.toJson());
  }

  @override
  Future<List<NotificationLog>> getLogs({
    int limit = 100,
    int offset = 0,
    bool? isTestOnly,
  }) async {
    final data = await _dataSource.getNotificationLogs(
      limit: limit,
      offset: offset,
      isTestOnly: isTestOnly,
    );
    return data.map((json) => NotificationLog.fromJson(json)).toList();
  }

  @override
  Future<int> getLogCount({bool? isTestOnly}) async {
    return await _dataSource.getNotificationLogCount(isTestOnly: isTestOnly);
  }

  @override
  Future<int> deleteOldLogs({int olderThanDays = 30}) async {
    return await _dataSource.deleteOldNotificationLogs(olderThanDays: olderThanDays);
  }

  @override
  Future<int> clearAllLogs() async {
    return await _dataSource.clearAllNotificationLogs();
  }
}
