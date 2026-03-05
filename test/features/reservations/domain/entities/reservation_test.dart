import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

void main() {
  group('Reservation', () {
    late Reservation testReservation;

    setUp(() {
      testReservation = Reservation(
        id: 'test-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Mario Rossi', phone: '+39123456789'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        amount: 150.00,
        notes: 'Late arrival',
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );
    });

    group('fields', () {
      test('should have all required fields', () {
        expect(testReservation.id, 'test-id');
        expect(testReservation.roomId, 'room-1');
        expect(testReservation.platformId, 'booking');
        expect(testReservation.guest.name, 'Mario Rossi');
        expect(testReservation.checkIn, DateTime(2024, 6, 15));
        expect(testReservation.checkOut, DateTime(2024, 6, 18));
        expect(testReservation.amount, 150.00);
        expect(testReservation.notes, 'Late arrival');
        expect(testReservation.createdAt, DateTime(2024, 6, 1));
        expect(testReservation.updatedAt, DateTime(2024, 6, 1));
      });

      test('should allow null amount and notes', () {
        final reservation = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Test'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation.amount, isNull);
        expect(reservation.notes, isNull);
      });
    });

    group('numberOfNights', () {
      test('should calculate 3 nights for June 15-18', () {
        expect(testReservation.numberOfNights, 3);
      });

      test('should calculate 1 night for same-day check-in and next-day check-out', () {
        final reservation = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Test'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation.numberOfNights, 1);
      });

      test('should calculate 7 nights for a week stay', () {
        final reservation = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Test'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 22),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation.numberOfNights, 7);
      });
    });

    group('overlapsWith', () {
      test('should return true for overlapping range (partial overlap)', () {
        // Test reservation: June 15-18
        // Overlapping: June 17-20
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 17),
            DateTime(2024, 6, 20),
          ),
          isTrue,
        );
      });

      test('should return true for completely contained range', () {
        // Test reservation: June 15-18
        // Contained: June 16-17
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 16),
            DateTime(2024, 6, 17),
          ),
          isTrue,
        );
      });

      test('should return true for range that contains reservation', () {
        // Test reservation: June 15-18
        // Containing: June 14-19
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 14),
            DateTime(2024, 6, 19),
          ),
          isTrue,
        );
      });

      test('should return false for adjacent range after (check-out day can be next check-in)', () {
        // Test reservation: June 15-18
        // Adjacent after: June 18-20
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 18),
            DateTime(2024, 6, 20),
          ),
          isFalse,
        );
      });

      test('should return false for adjacent range before (check-in day can be previous check-out)', () {
        // Test reservation: June 15-18
        // Adjacent before: June 13-15
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 13),
            DateTime(2024, 6, 15),
          ),
          isFalse,
        );
      });

      test('should return false for range completely before', () {
        // Test reservation: June 15-18
        // Before: June 10-14
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 10),
            DateTime(2024, 6, 14),
          ),
          isFalse,
        );
      });

      test('should return false for range completely after', () {
        // Test reservation: June 15-18
        // After: June 20-25
        expect(
          testReservation.overlapsWith(
            DateTime(2024, 6, 20),
            DateTime(2024, 6, 25),
          ),
          isFalse,
        );
      });
    });

    group('equality', () {
      test('should support equality', () {
        final reservation1 = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario Rossi'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        final reservation2 = Reservation(
          id: 'test-id',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario Rossi'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        expect(reservation1, equals(reservation2));
      });
    });
  });
}
