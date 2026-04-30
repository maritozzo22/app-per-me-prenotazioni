import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_settings.dart';
import 'package:app_prenotazioni/features/notifications/data/repositories/notification_settings_repository_impl.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationDatasource extends Mock implements NotificationDatasource {}

void main() {
  late NotificationSettingsRepositoryImpl repository;
  late MockNotificationDatasource mockDataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockDataSource = MockNotificationDatasource();
    repository = NotificationSettingsRepositoryImpl(mockDataSource);
  });

  group('NotificationSettingsRepositoryImpl', () {
    test('getSettings returns default when no settings exist', () async {
      when(() => mockDataSource.getNotificationSettings())
          .thenAnswer((_) async => null);

      final settings = await repository.getSettings();

      expect(settings.enabled, isTrue);
      expect(settings.daysBeforeCheckIn, equals({5, 3, 2, 1, 0}));

      verify(() => mockDataSource.getNotificationSettings()).called(1);
    });

    test('getSettings returns saved settings', () async {
      final savedJson = {
        'enabled': false,
        'days_before': '[0,2,5]',
        'notification_hour': 10,
        'notification_minute': 30,
        'updated_at': '2026-03-08T12:00:00.000',
      };

      when(() => mockDataSource.getNotificationSettings())
          .thenAnswer((_) async => savedJson);

      final settings = await repository.getSettings();

      expect(settings.enabled, isFalse);
      expect(settings.daysBeforeCheckIn, equals({5, 2, 0}));
      expect(settings.notificationHour, equals(10));
      expect(settings.notificationMinute, equals(30));
    });

    test('saveSettings calls data source', () async {
      final settings = NotificationSettings(
        enabled: false,
        daysBeforeCheckIn: {5, 2},
        notificationHour: 10,
        notificationMinute: 0,
        updatedAt: DateTime(2026, 3, 8),
      );

      when(() => mockDataSource.saveNotificationSettings(any()))
          .thenAnswer((_) async {});

      await repository.saveSettings(settings);

      verify(() => mockDataSource.saveNotificationSettings(any())).called(1);
    });

    test('resetToDefaults saves default settings', () async {
      when(() => mockDataSource.saveNotificationSettings(any()))
          .thenAnswer((_) async {});

      await repository.resetToDefaults();

      // Verify that saveNotificationSettings was called
      verify(() => mockDataSource.saveNotificationSettings(any())).called(1);
    });
  });
}
