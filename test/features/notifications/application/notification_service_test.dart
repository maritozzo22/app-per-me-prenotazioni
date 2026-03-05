import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';

void main() {
  group('PlatformService', () {
    test('should identify platform correctly', () {
      // Test that platform detection works
      expect(PlatformService.platformName, isNotNull);
      expect(PlatformService.notificationsSupported, isA<bool>());
    });
  });

  group('WebNotificationService', () {
    late WebNotificationService webService;

    setUp(() {
      webService = WebNotificationService();
    });

    test('should initialize without error', () async {
      await expectLater(webService.initialize(), completes);
    });

    test('should schedule notification without error (no-op)', () async {
      final schedule = NotificationSchedule(
        id: 'test-id',
        reservationId: 'res-1',
        type: NotificationType.oneDay,
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
      );

      await expectLater(
        webService.scheduleNotification(schedule, 'Guest', 'Room'),
        completes,
      );
    });

    test('should cancel notification without error (no-op)', () async {
      await expectLater(webService.cancelNotification('test-id'), completes);
    });

    test('should cancel all notifications without error (no-op)', () async {
      await expectLater(webService.cancelAllNotifications(), completes);
    });

    test('should return false for requestPermissions', () async {
      final granted = await webService.requestPermissions();
      expect(granted, false);
    });
  });

  group('createNotificationService', () {
    test('should return appropriate service for platform', () {
      final service = createNotificationService();

      if (PlatformService.isWeb) {
        expect(service, isA<WebNotificationService>());
      } else {
        expect(service, isA<AndroidNotificationService>());
      }
    });
  });
}
