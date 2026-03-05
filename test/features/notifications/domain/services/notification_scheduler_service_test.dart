import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationSchedulerServiceImpl', () {
    late NotificationSchedulerServiceImpl service;

    setUp(() {
      service = NotificationSchedulerServiceImpl();
    });

    group('calculateSchedules', () {
      test('should generate 5 schedules for future reservation', () {
        // Arrange
        final guest = Guest(
          name: 'Mario Rossi',
          phone: '+39 333 1234567',
        );

        final checkIn = DateTime.now().add(const Duration(days: 10));
        final checkOut = checkIn.add(const Duration(days: 3));

        final reservation = Reservation(
          id: 'res1',
          roomId: 'room1',
          platformId: 'booking',
          guest: guest,
          checkIn: checkIn,
          checkOut: checkOut,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final schedules = service.calculateSchedules(reservation);

        // Assert
        expect(schedules.length, equals(5));

        // Verify all notification types are present
        final types = schedules.map((s) => s.type).toSet();
        expect(types, contains(NotificationType.fiveDays));
        expect(types, contains(NotificationType.threeDays));
        expect(types, contains(NotificationType.twoDays));
        expect(types, contains(NotificationType.oneDay));
        expect(types, contains(NotificationType.sameDay));
      });

      test('should skip past notifications for near-term reservation', () {
        // Arrange
        final guest = Guest(
          name: 'Mario Rossi',
          phone: '+39 333 1234567',
        );

        // Check-in in 1 day - should skip 5, 3, 2 days notifications
        final checkIn = DateTime.now().add(const Duration(days: 1));
        final checkOut = checkIn.add(const Duration(days: 3));

        final reservation = Reservation(
          id: 'res1',
          roomId: 'room1',
          platformId: 'booking',
          guest: guest,
          checkIn: checkIn,
          checkOut: checkOut,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final schedules = service.calculateSchedules(reservation);

        // Assert - should only have 1day and sameday
        expect(schedules.length, lessThanOrEqualTo(2));

        final types = schedules.map((s) => s.type).toSet();
        expect(types, contains(NotificationType.oneDay));
        expect(types, contains(NotificationType.sameDay));
      });

      test('should set correct reservation ID and metadata', () {
        // Arrange
        final guest = Guest(
          name: 'Mario Rossi',
          phone: '+39 333 1234567',
        );

        final checkIn = DateTime.now().add(const Duration(days: 10));
        final checkOut = checkIn.add(const Duration(days: 3));

        final reservation = Reservation(
          id: 'res123',
          roomId: 'room1',
          platformId: 'booking',
          guest: guest,
          checkIn: checkIn,
          checkOut: checkOut,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final schedules = service.calculateSchedules(reservation);

        // Assert
        for (final schedule in schedules) {
          expect(schedule.reservationId, equals('res123'));
          expect(schedule.isSent, isFalse);
          expect(schedule.createdAt, isNotNull);
        }
      });

      test('should throw for past reservations', () {
        // Arrange
        final guest = Guest(
          name: 'Mario Rossi',
          phone: '+39 333 1234567',
        );

        // Check-in yesterday
        final checkIn = DateTime.now().subtract(const Duration(days: 1));
        final checkOut = checkIn.add(const Duration(days: 3));

        final reservation = Reservation(
          id: 'res1',
          roomId: 'room1',
          platformId: 'booking',
          guest: guest,
          checkIn: checkIn,
          checkOut: checkOut,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => service.calculateSchedules(reservation),
          throwsArgumentError,
        );
      });

      test('should handle same-day check-in correctly', () {
        // Arrange
        final guest = Guest(
          name: 'Mario Rossi',
          phone: '+39 333 1234567',
        );

        // Check-in today at 14:00
        final now = DateTime.now();
        final checkIn = DateTime(now.year, now.month, now.day, 14, 0);
        final checkOut = checkIn.add(const Duration(days: 3));

        final reservation = Reservation(
          id: 'res1',
          roomId: 'room1',
          platformId: 'booking',
          guest: guest,
          checkIn: checkIn,
          checkOut: checkOut,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final schedules = service.calculateSchedules(reservation);

        // Assert - should only have sameday if it's 9AM or later
        // If before 9AM, sameday notification at 9AM is still valid
        expect(schedules.isNotEmpty, isTrue);
        expect(
          schedules.every((s) => s.type == NotificationType.sameDay),
          isTrue,
        );
      });
    });

    group('calculateScheduledDate', () {
      test('should calculate 5 days before check-in', () {
        // Arrange
        final checkIn = DateTime(2026, 3, 15, 14, 0);

        // Act
        final scheduled = service.calculateScheduledDate(
          checkIn,
          NotificationType.fiveDays,
        );

        // Assert
        expect(scheduled.year, equals(2026));
        expect(scheduled.month, equals(3));
        expect(scheduled.day, equals(10));
        expect(scheduled.hour, equals(9)); // 9:00 AM
        expect(scheduled.minute, equals(0));
      });

      test('should calculate 3 days before check-in', () {
        // Arrange
        final checkIn = DateTime(2026, 3, 15, 14, 0);

        // Act
        final scheduled = service.calculateScheduledDate(
          checkIn,
          NotificationType.threeDays,
        );

        // Assert
        expect(scheduled.year, equals(2026));
        expect(scheduled.month, equals(3));
        expect(scheduled.day, equals(12));
        expect(scheduled.hour, equals(9));
        expect(scheduled.minute, equals(0));
      });

      test('should calculate 2 days before check-in', () {
        // Arrange
        final checkIn = DateTime(2026, 3, 15, 14, 0);

        // Act
        final scheduled = service.calculateScheduledDate(
          checkIn,
          NotificationType.twoDays,
        );

        // Assert
        expect(scheduled.year, equals(2026));
        expect(scheduled.month, equals(3));
        expect(scheduled.day, equals(13));
        expect(scheduled.hour, equals(9));
        expect(scheduled.minute, equals(0));
      });

      test('should calculate 1 day before check-in', () {
        // Arrange
        final checkIn = DateTime(2026, 3, 15, 14, 0);

        // Act
        final scheduled = service.calculateScheduledDate(
          checkIn,
          NotificationType.oneDay,
        );

        // Assert
        expect(scheduled.year, equals(2026));
        expect(scheduled.month, equals(3));
        expect(scheduled.day, equals(14));
        expect(scheduled.hour, equals(9));
        expect(scheduled.minute, equals(0));
      });

      test('should calculate same day notification', () {
        // Arrange
        final checkIn = DateTime(2026, 3, 15, 14, 0);

        // Act
        final scheduled = service.calculateScheduledDate(
          checkIn,
          NotificationType.sameDay,
        );

        // Assert
        expect(scheduled.year, equals(2026));
        expect(scheduled.month, equals(3));
        expect(scheduled.day, equals(15));
        expect(scheduled.hour, equals(9)); // Morning of check-in
        expect(scheduled.minute, equals(0));
      });

      test('should handle month boundaries correctly', () {
        // Arrange
        final checkIn = DateTime(2026, 3, 2, 14, 0); // March 2nd

        // Act
        final scheduled = service.calculateScheduledDate(
          checkIn,
          NotificationType.fiveDays,
        );

        // Assert - February 25th (leap year)
        expect(scheduled.year, equals(2026));
        expect(scheduled.month, equals(2));
        expect(scheduled.day, equals(25));
      });
    });

    group('shouldScheduleNotification', () {
      test('should return true for future notification', () {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 5));
        final schedule = NotificationSchedule(
          id: 'sched1',
          reservationId: 'res1',
          type: NotificationType.fiveDays,
          scheduledDate: futureDate,
          createdAt: DateTime.now(),
        );

        // Act
        final result = service.shouldScheduleNotification(schedule);

        // Assert
        expect(result, isTrue);
      });

      test('should return true for today notification', () {
        // Arrange
        final today = DateTime.now();
        final today9am = DateTime(
          today.year,
          today.month,
          today.day,
          9,
          0,
        );
        final schedule = NotificationSchedule(
          id: 'sched1',
          reservationId: 'res1',
          type: NotificationType.sameDay,
          scheduledDate: today9am,
          createdAt: DateTime.now(),
        );

        // Act
        final result = service.shouldScheduleNotification(schedule);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for past notification', () {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 2));
        final schedule = NotificationSchedule(
          id: 'sched1',
          reservationId: 'res1',
          type: NotificationType.fiveDays,
          scheduledDate: pastDate,
          createdAt: DateTime.now(),
        );

        // Act
        final result = service.shouldScheduleNotification(schedule);

        // Assert
        expect(result, isFalse);
      });
    });

    group('generateScheduleId', () {
      test('should generate unique ID per reservation and type', () {
        // Act
        final id1 = service.generateScheduleId('res1', NotificationType.fiveDays);
        final id2 = service.generateScheduleId('res1', NotificationType.threeDays);
        final id3 = service.generateScheduleId('res2', NotificationType.fiveDays);

        // Assert
        expect(id1, equals('res1_5days'));
        expect(id2, equals('res1_3days'));
        expect(id3, equals('res2_5days'));

        expect(id1, isNot(equals(id2)));
        expect(id1, isNot(equals(id3)));
        expect(id2, isNot(equals(id3)));
      });

      test('should generate consistent ID for same inputs', () {
        // Act
        final id1 = service.generateScheduleId('res1', NotificationType.sameDay);
        final id2 = service.generateScheduleId('res1', NotificationType.sameDay);

        // Assert
        expect(id1, equals(id2));
        expect(id1, equals('res1_sameday'));
      });
    });
  });
}
