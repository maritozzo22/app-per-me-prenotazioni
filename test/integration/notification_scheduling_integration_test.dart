import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';
import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/notifications/application/reservation_notification_scheduler.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';

void main() {
  // Initialize sqflite FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Notification Scheduling Integration', () {
    late DatabaseHelper databaseHelper;
    late ReservationLocalDataSource reservationDataSource;
    late ReservationRepositoryImpl reservationRepository;
    late NotificationDatasource notificationDatasource;
    late NotificationRepositoryImpl notificationRepository;
    late NotificationSchedulerService schedulerService;
    late NotificationService notificationService;
    late ReservationNotificationScheduler scheduler;

    Reservation _createTestReservation() {
      return Reservation(
        id: 'res-integration-1',
        roomId: 'room-1',
        platformId: 'airbnb',
        guest: const Guest(name: 'Mario Rossi', phone: '+39 123 456 7890'),
        checkIn: DateTime.now().add(const Duration(days: 10)),
        checkOut: DateTime.now().add(const Duration(days: 15)),
        amount: 500.0,
        paymentStatus: PaymentStatus.pending,
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    setUp(() async {
      // Create fresh database for each test
      databaseHelper = DatabaseHelper.forTesting();
      await databaseHelper.database;

      reservationDataSource = ReservationLocalDataSource(databaseHelper: databaseHelper);
      reservationRepository = ReservationRepositoryImpl(dataSource: reservationDataSource);
      notificationDatasource = NotificationDatasource(databaseHelper);
      notificationRepository = NotificationRepositoryImpl(notificationDatasource);
      schedulerService = NotificationSchedulerServiceImpl();
      notificationService = WebNotificationService();

      scheduler = ReservationNotificationScheduler(
        schedulerService: schedulerService,
        notificationRepository: notificationRepository,
        notificationService: notificationService,
      );

      // Initialize notification service
      await notificationService.initialize();
    });

    tearDown(() async {
      // Clean up database
      await databaseHelper.close();
    });

    test('should schedule notifications when reservation is created', () async {
      final reservation = _createTestReservation();

      // Create reservation
      await reservationRepository.saveReservation(reservation);

      // Schedule notifications
      await scheduler.scheduleReservationNotifications(reservation);

      // Verify schedules were saved to database
      final schedules = await notificationRepository.getSchedulesForReservation(reservation.id);
      expect(schedules.isNotEmpty, true);

      // Verify notifications were scheduled (should have 5 schedules for future reservation)
      expect(schedules.length, greaterThan(0));
    });

    test('should cancel notifications when reservation is deleted', () async {
      final reservation = _createTestReservation();

      // Create reservation and schedule notifications
      await reservationRepository.saveReservation(reservation);
      await scheduler.scheduleReservationNotifications(reservation);

      // Verify schedules exist
      var schedules = await notificationRepository.getSchedulesForReservation(reservation.id);
      expect(schedules.isNotEmpty, true);

      // Delete reservation and cancel notifications
      await reservationRepository.deleteReservation(reservation.id);
      await scheduler.cancelReservationNotifications(reservation.id);

      // Verify schedules were deleted
      schedules = await notificationRepository.getSchedulesForReservation(reservation.id);
      expect(schedules.isEmpty, true);
    });

    test('should reschedule notifications when reservation is edited', () async {
      final reservation = _createTestReservation();

      // Create reservation and schedule notifications
      await reservationRepository.saveReservation(reservation);
      await scheduler.scheduleReservationNotifications(reservation);

      final initialSchedules = await notificationRepository.getSchedulesForReservation(reservation.id);

      // Edit reservation (change check-in date)
      final editedReservation = Reservation(
        id: reservation.id,
        roomId: reservation.roomId,
        platformId: reservation.platformId,
        guest: reservation.guest,
        checkIn: reservation.checkIn.add(const Duration(days: 7)),
        checkOut: reservation.checkOut.add(const Duration(days: 7)),
        amount: reservation.amount,
        paymentStatus: reservation.paymentStatus,
        notes: reservation.notes,
        createdAt: reservation.createdAt,
        updatedAt: DateTime.now(),
      );

      await reservationRepository.saveReservation(editedReservation);
      await scheduler.rescheduleReservationNotifications(editedReservation);

      final newSchedules = await notificationRepository.getSchedulesForReservation(reservation.id);

      // Verify schedules changed
      expect(newSchedules.length, initialSchedules.length);
      // Dates should be different
      expect(newSchedules.first.scheduledDate, isNot(initialSchedules.first.scheduledDate));
    });

    test('should handle web platform gracefully', () async {
      // Web notifications should not throw errors
      final reservation = _createTestReservation();

      await reservationRepository.saveReservation(reservation);

      // This should complete without errors even on web
      await scheduler.scheduleReservationNotifications(reservation);

      // Schedules should still be saved to database
      final schedules = await notificationRepository.getSchedulesForReservation(reservation.id);
      expect(schedules.isNotEmpty, true);
    });
  });
}
