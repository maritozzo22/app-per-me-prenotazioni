import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/notifications/application/reservation_notification_scheduler.dart';
import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';

class MockNotificationSchedulerService extends Mock implements NotificationSchedulerService {}
class MockNotificationRepository extends Mock implements NotificationRepository {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  setUpAll(() {
    // Register fallback value for mocktail
    registerFallbackValue(
      NotificationSchedule(
        id: 'fallback',
        reservationId: 'fallback',
        type: NotificationType.fiveDays,
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
  });

  group('ReservationNotificationScheduler', () {
    late MockNotificationSchedulerService mockSchedulerService;
    late MockNotificationRepository mockNotificationRepository;
    late MockNotificationService mockNotificationService;
    late ReservationNotificationScheduler scheduler;

    Reservation _createTestReservation() {
      return Reservation(
        id: 'res-1',
        roomId: 'room-1',
        platformId: 'airbnb',
        guest: const Guest(name: 'Mario Rossi', phone: '+39 123 456 7890'),
        checkIn: DateTime(2026, 3, 10),
        checkOut: DateTime(2026, 3, 15),
        amount: 500.0,
        paymentStatus: PaymentStatus.pending,
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    List<NotificationSchedule> _createTestSchedules() {
      return [
        NotificationSchedule(
          id: 'sched-1',
          reservationId: 'res-1',
          type: NotificationType.fiveDays,
          scheduledDate: DateTime(2026, 3, 5, 9, 0),
          createdAt: DateTime.now(),
        ),
        NotificationSchedule(
          id: 'sched-2',
          reservationId: 'res-1',
          type: NotificationType.threeDays,
          scheduledDate: DateTime(2026, 3, 7, 9, 0),
          createdAt: DateTime.now(),
        ),
      ];
    }

    setUp(() {
      mockSchedulerService = MockNotificationSchedulerService();
      mockNotificationRepository = MockNotificationRepository();
      mockNotificationService = MockNotificationService();

      scheduler = ReservationNotificationScheduler(
        schedulerService: mockSchedulerService,
        notificationRepository: mockNotificationRepository,
        notificationService: mockNotificationService,
      );

      // Setup default mock behaviors
      when(() => mockNotificationService.scheduleNotification(any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationService.cancelNotification(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.saveSchedule(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.deleteSchedulesForReservation(any()))
          .thenAnswer((_) async {});
    });

    test('should calculate and save all schedules', () async {
      final reservation = _createTestReservation();
      final schedules = _createTestSchedules();

      when(() => mockSchedulerService.calculateSchedules(reservation))
          .thenReturn(schedules);

      await scheduler.scheduleReservationNotifications(reservation);

      verify(() => mockSchedulerService.calculateSchedules(reservation)).called(1);
      verify(() => mockNotificationRepository.saveSchedule(schedules[0])).called(1);
      verify(() => mockNotificationRepository.saveSchedule(schedules[1])).called(1);
    });

    test('should schedule platform notifications', () async {
      final reservation = _createTestReservation();
      final schedules = _createTestSchedules();

      when(() => mockSchedulerService.calculateSchedules(reservation))
          .thenReturn(schedules);

      await scheduler.scheduleReservationNotifications(reservation);

      verify(() => mockNotificationService.scheduleNotification(
        schedules[0],
        reservation.guest.name,
        'Camera ${reservation.roomId}',
      )).called(1);
    });

    test('should cancel all notifications for reservation', () async {
      final reservationId = 'res-1';
      final schedules = _createTestSchedules();

      when(() => mockNotificationRepository.getSchedulesForReservation(reservationId))
          .thenAnswer((_) async => schedules);

      await scheduler.cancelReservationNotifications(reservationId);

      verify(() => mockNotificationService.cancelNotification(schedules[0].id)).called(1);
      verify(() => mockNotificationService.cancelNotification(schedules[1].id)).called(1);
      verify(() => mockNotificationRepository.deleteSchedulesForReservation(reservationId)).called(1);
    });

    test('should reschedule notifications', () async {
      final reservation = _createTestReservation();
      final schedules = _createTestSchedules();

      when(() => mockNotificationRepository.getSchedulesForReservation(reservation.id))
          .thenAnswer((_) async => schedules);
      when(() => mockSchedulerService.calculateSchedules(reservation))
          .thenReturn(schedules);

      await scheduler.rescheduleReservationNotifications(reservation);

      verify(() => mockNotificationRepository.deleteSchedulesForReservation(reservation.id)).called(1);
      verify(() => mockSchedulerService.calculateSchedules(reservation)).called(1);
    });
  });
}
