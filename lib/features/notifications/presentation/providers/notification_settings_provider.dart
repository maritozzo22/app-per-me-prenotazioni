import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_settings.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:app_prenotazioni/features/notifications/data/repositories/notification_settings_repository_impl.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_datasource_provider.dart';

/// Provider for NotificationSettingsRepository
final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  final dataSource = ref.watch(notificationDatasourceProvider);
  return NotificationSettingsRepositoryImpl(dataSource);
});

/// State for notification settings
class NotificationSettingsState {
  final NotificationSettings settings;
  final bool isLoading;

  const NotificationSettingsState({
    required this.settings,
    this.isLoading = true,
  });

  NotificationSettingsState copyWith({
    NotificationSettings? settings,
    bool? isLoading,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for notification settings
class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  final NotificationSettingsRepository _repository;

  NotificationSettingsNotifier(this._repository)
      : super(NotificationSettingsState(
          settings: NotificationSettings.defaults(),
          isLoading: true,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.getSettings();
    state = NotificationSettingsState(
      settings: settings,
      isLoading: false,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final updated = state.settings.copyWith(
      enabled: enabled,
      updatedAt: DateTime.now(),
    );
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> setDays(Set<int> days) async {
    final updated = state.settings.copyWith(
      daysBeforeCheckIn: days,
      updatedAt: DateTime.now(),
    );
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> toggleDay(int day) async {
    final currentDays = Set<int>.from(state.settings.daysBeforeCheckIn);
    if (currentDays.contains(day)) {
      currentDays.remove(day);
    } else {
      currentDays.add(day);
    }
    await setDays(currentDays);
  }

  Future<void> setTime(int hour, int minute) async {
    final updated = state.settings.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
      updatedAt: DateTime.now(),
    );
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
    await _loadSettings();
  }
}

/// Provider for notification settings state
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>(
  (ref) {
    final repository = ref.watch(notificationSettingsRepositoryProvider);
    return NotificationSettingsNotifier(repository);
  },
);
