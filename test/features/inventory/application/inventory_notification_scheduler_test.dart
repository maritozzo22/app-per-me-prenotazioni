import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/inventory/application/inventory_notification_scheduler.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late InventoryNotificationScheduler scheduler;
  late MockNotificationService mockService;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(
      NotificationSchedule(
        id: 'test-id',
        reservationId: 'test-reservation',
        type: NotificationType.threeDays,
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(PaymentStatus.received);
  });

  setUp(() {
    mockService = MockNotificationService();
    // Mock the methods to return Future<void>
    when(() => mockService.scheduleNotification(any(), any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => mockService.cancelNotification(any())).thenAnswer((_) async {});
    scheduler = InventoryNotificationScheduler(mockService);
  });

  group('InventoryNotificationScheduler', () {
    final now = DateTime(2026, 4, 12);

    test('schedules notification 3 days before expiry', () async {
      final expiryDate = now.add(const Duration(days: 10));
      final item = InventoryItem(
        id: '1',
        name: 'Latte',
        category: InventoryCategory.alimentari,
        quantity: 1,
        expiryDate: expiryDate,
        createdAt: now,
      );

      await scheduler.scheduleExpiryNotification(item);

      final scheduledDate = now.add(const Duration(days: 7)); // 10 - 3 = 7
      verify(() => mockService.scheduleNotification(
        any(),
        'Latte scade tra 3 giorni',
        'Categoria: Alimentari',
        PaymentStatus.received,
      )).called(1);
    });

    test('does not schedule for non-food items', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Asciugamani',
        category: InventoryCategory.tessili,
        quantity: 10,
        createdAt: now,
      );

      await scheduler.scheduleExpiryNotification(item);

      verifyNever(() => mockService.scheduleNotification(any(), any(), any(), any()));
    });

    test('does not schedule if expiry is in the past', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Latte scaduto',
        category: InventoryCategory.alimentari,
        quantity: 0,
        expiryDate: now.subtract(const Duration(days: 5)),
        createdAt: now,
      );

      await scheduler.scheduleExpiryNotification(item);

      verifyNever(() => mockService.scheduleNotification(any(), any(), any(), any()));
    });

    test('uses inventory_ prefix in ID to prevent collision', () async {
      final item = InventoryItem(
        id: '123',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        createdAt: now,
      );

      await scheduler.scheduleExpiryNotification(item);

      final captured = verify(
        () => mockService.scheduleNotification(captureAny(), any(), any(), any()),
      ).captured.single as NotificationSchedule;

      expect(captured.id.toString(), contains('inventory_123'));
    });

    test('cancelItemNotification cancels notification', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        createdAt: now,
      );

      await scheduler.cancelItemNotification(item);

      final expectedId = 'inventory_1'.hashCode;
      verify(() => mockService.cancelNotification(expectedId)).called(1);
    });

    test('rescheduleExpiryNotification cancels and reschedules', () async {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        createdAt: now,
      );

      await scheduler.rescheduleExpiryNotification(item);

      verify(() => mockService.cancelNotification(any())).called(1);
      verify(() => mockService.scheduleNotification(any(), any(), any(), any())).called(1);
    });
  });
}
