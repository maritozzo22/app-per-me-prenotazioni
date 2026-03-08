import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_log.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_log_repository.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_log_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationLogRepository extends Mock
    implements NotificationLogRepository {}

void main() {
  late MockNotificationLogRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(NotificationLog.test(id: 'fallback', sentAt: DateTime.now()));
  });

  setUp(() {
    mockRepository = MockNotificationLogRepository();
    container = ProviderContainer(
      overrides: [
        notificationLogRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationLogNotifier', () {
    test('refreshLogs loads logs from repository', () async {
      final testLogs = [
        NotificationLog.test(id: 'test-1', sentAt: DateTime.now()),
      ];

      when(() => mockRepository.getLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => testLogs);
      when(() => mockRepository.getLogCount())
          .thenAnswer((_) async => 1);

      final notifier = container.read(notificationLogProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(notificationLogProvider);
      expect(state.isLoading, isFalse);
      expect(state.logs.length, equals(1));
      expect(state.totalCount, equals(1));
    });

    test('addTestLog adds log and refreshes', () async {
      when(() => mockRepository.getLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getLogCount())
          .thenAnswer((_) async => 0);
      when(() => mockRepository.addLog(any()))
          .thenAnswer((_) async {});

      final notifier = container.read(notificationLogProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.addTestLog(success: true);

      verify(() => mockRepository.addLog(any())).called(1);
      verify(() => mockRepository.getLogs(limit: any(named: 'limit'))).called(greaterThan(1));
    });

    test('deleteOldLogs removes logs and refreshes', () async {
      when(() => mockRepository.getLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getLogCount())
          .thenAnswer((_) async => 0);
      when(() => mockRepository.deleteOldLogs(olderThanDays: any(named: 'olderThanDays')))
          .thenAnswer((_) async => 5);

      final notifier = container.read(notificationLogProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final deleted = await notifier.deleteOldLogs(olderThanDays: 30);

      expect(deleted, equals(5));
      verify(() => mockRepository.deleteOldLogs(olderThanDays: 30)).called(1);
    });

    test('clearAllLogs clears logs and refreshes', () async {
      when(() => mockRepository.getLogs(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      when(() => mockRepository.getLogCount())
          .thenAnswer((_) async => 0);
      when(() => mockRepository.clearAllLogs())
          .thenAnswer((_) async => 10);

      final notifier = container.read(notificationLogProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.clearAllLogs();

      verify(() => mockRepository.clearAllLogs()).called(1);
    });
  });
}
