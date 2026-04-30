import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_log.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_log_repository.dart';
import 'package:app_prenotazioni/features/notifications/data/repositories/notification_log_repository_impl.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_datasource_provider.dart';

/// Provider for NotificationLogRepository
final notificationLogRepositoryProvider =
    Provider<NotificationLogRepository>((ref) {
  final dataSource = ref.watch(notificationDatasourceProvider);
  return NotificationLogRepositoryImpl(dataSource);
});

/// State for notification logs
class NotificationLogState {
  final List<NotificationLog> logs;
  final bool isLoading;
  final int totalCount;

  const NotificationLogState({
    this.logs = const [],
    this.isLoading = true,
    this.totalCount = 0,
  });

  NotificationLogState copyWith({
    List<NotificationLog>? logs,
    bool? isLoading,
    int? totalCount,
  }) {
    return NotificationLogState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Notifier for notification logs
class NotificationLogNotifier extends StateNotifier<NotificationLogState> {
  final NotificationLogRepository _repository;
  final Uuid _uuid;

  NotificationLogNotifier(this._repository, this._uuid)
      : super(const NotificationLogState()) {
    refreshLogs();
  }

  Future<void> refreshLogs({int limit = 100}) async {
    state = state.copyWith(isLoading: true);

    final logs = await _repository.getLogs(limit: limit);
    final count = await _repository.getLogCount();

    state = NotificationLogState(
      logs: logs,
      isLoading: false,
      totalCount: count,
    );
  }

  Future<void> addTestLog({
    required bool success,
    String? errorMessage,
  }) async {
    final now = DateTime.now();
    final log = NotificationLog.test(
      id: _uuid.v4(),
      sentAt: now,
      success: success,
      errorMessage: errorMessage,
    );

    await _repository.addLog(log);
    await refreshLogs();
  }

  Future<void> addLog(NotificationLog log) async {
    await _repository.addLog(log);
    await refreshLogs();
  }

  Future<int> deleteOldLogs({int olderThanDays = 30}) async {
    final deleted = await _repository.deleteOldLogs(olderThanDays: olderThanDays);
    await refreshLogs();
    return deleted;
  }

  Future<void> clearAllLogs() async {
    await _repository.clearAllLogs();
    await refreshLogs();
  }
}

/// Provider for notification logs state
final notificationLogProvider =
    StateNotifierProvider<NotificationLogNotifier, NotificationLogState>(
  (ref) {
    final repository = ref.watch(notificationLogRepositoryProvider);
    return NotificationLogNotifier(repository, const Uuid());
  },
);
