import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_log.dart';
import 'package:app_prenotazioni/features/notifications/data/repositories/notification_log_repository_impl.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationDatasource extends Mock implements NotificationDatasource {}

void main() {
  late NotificationLogRepositoryImpl repository;
  late MockNotificationDatasource mockDataSource;

  setUp(() {
    mockDataSource = MockNotificationDatasource();
    repository = NotificationLogRepositoryImpl(mockDataSource);
    registerFallbackValue(<String, dynamic>{});
  });

  group('NotificationLogRepositoryImpl', () {
    test('addLog calls data source insertNotificationLog', () async {
      final log = NotificationLog.test(id: 'test-1', sentAt: DateTime.now());

      when(() => mockDataSource.insertNotificationLog(any()))
          .thenAnswer((_) async {});

      await repository.addLog(log);

      verify(() => mockDataSource.insertNotificationLog(any())).called(1);
    });

    test('getLogs returns mapped logs', () async {
      final mockData = [
        {
          'id': 'log-1',
          'reservation_id': 'res-1',
          'guest_name': 'John',
          'room_label': 'Room 1',
          'days_before': 3,
          'scheduled_time': '2026-03-05T09:00:00.000',
          'sent_at': '2026-03-05T09:00:00.000',
          'success': 1,
          'is_test': 0,
        },
      ];

      when(() => mockDataSource.getNotificationLogs(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        isTestOnly: any(named: 'isTestOnly'),
      )).thenAnswer((_) async => mockData);

      final logs = await repository.getLogs();

      expect(logs.length, equals(1));
      expect(logs.first.id, equals('log-1'));
      expect(logs.first.guestName, equals('John'));
    });

    test('getLogCount returns count from data source', () async {
      when(() => mockDataSource.getNotificationLogCount(isTestOnly: any(named: 'isTestOnly')))
          .thenAnswer((_) async => 42);

      final count = await repository.getLogCount();

      expect(count, equals(42));
    });

    test('deleteOldLogs calls data source with correct days', () async {
      when(() => mockDataSource.deleteOldNotificationLogs(olderThanDays: any(named: 'olderThanDays')))
          .thenAnswer((_) async => 5);

      final deleted = await repository.deleteOldLogs(olderThanDays: 60);

      expect(deleted, equals(5));
      verify(() => mockDataSource.deleteOldNotificationLogs(olderThanDays: 60)).called(1);
    });

    test('clearAllLogs calls data source', () async {
      when(() => mockDataSource.clearAllNotificationLogs())
          .thenAnswer((_) async => 10);

      final deleted = await repository.clearAllLogs();

      expect(deleted, equals(10));
      verify(() => mockDataSource.clearAllNotificationLogs()).called(1);
    });
  });
}
