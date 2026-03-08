import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_settings.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_settings_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationSettingsRepository extends Mock
    implements NotificationSettingsRepository {}

void main() {
  late MockNotificationSettingsRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockNotificationSettingsRepository();
    container = ProviderContainer(
      overrides: [
        notificationSettingsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    // Register fallback values
    registerFallbackValue(NotificationSettings.defaults());
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationSettingsNotifier', () {
    test('loads settings on initialization', () async {
      final defaultSettings = NotificationSettings.defaults();
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => defaultSettings);

      final notifier = container.read(notificationSettingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(notificationSettingsProvider);
      expect(state.isLoading, isFalse);
      expect(state.settings.enabled, isTrue);
    });

    test('setEnabled updates settings', () async {
      final settings = NotificationSettings.defaults();
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => settings);
      when(() => mockRepository.saveSettings(any()))
          .thenAnswer((_) async {});

      final notifier = container.read(notificationSettingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.setEnabled(false);

      final state = container.read(notificationSettingsProvider);
      expect(state.settings.enabled, isFalse);
      verify(() => mockRepository.saveSettings(any())).called(1);
    });

    test('toggleDay adds and removes days', () async {
      final settings = NotificationSettings(
        daysBeforeCheckIn: {5, 3, 2},
        updatedAt: DateTime.now(),
      );
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => settings);
      when(() => mockRepository.saveSettings(any()))
          .thenAnswer((_) async {});

      final notifier = container.read(notificationSettingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Remove day 3
      await notifier.toggleDay(3);
      expect(
        container.read(notificationSettingsProvider).settings.daysBeforeCheckIn,
        equals({5, 2}),
      );

      // Add day 1
      await notifier.toggleDay(1);
      expect(
        container.read(notificationSettingsProvider).settings.daysBeforeCheckIn,
        equals({5, 2, 1}),
      );
    });

    test('setTime updates hour and minute', () async {
      final settings = NotificationSettings.defaults();
      when(() => mockRepository.getSettings())
          .thenAnswer((_) async => settings);
      when(() => mockRepository.saveSettings(any()))
          .thenAnswer((_) async {});

      final notifier = container.read(notificationSettingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.setTime(10, 30);

      final state = container.read(notificationSettingsProvider);
      expect(state.settings.notificationHour, equals(10));
      expect(state.settings.notificationMinute, equals(30));
    });
  });
}
