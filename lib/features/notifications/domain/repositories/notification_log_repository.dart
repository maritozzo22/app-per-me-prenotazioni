import 'package:app_prenotazioni/features/notifications/domain/entities/notification_log.dart';

/// Repository interface for notification logs.
abstract class NotificationLogRepository {
  /// Adds a notification log entry.
  Future<void> addLog(NotificationLog log);

  /// Gets notification logs, most recent first.
  Future<List<NotificationLog>> getLogs({
    int limit = 100,
    int offset = 0,
    bool? isTestOnly,
  });

  /// Gets the count of notification logs.
  Future<int> getLogCount({bool? isTestOnly});

  /// Deletes logs older than specified days.
  Future<int> deleteOldLogs({int olderThanDays = 30});

  /// Clears all notification logs.
  Future<int> clearAllLogs();
}
