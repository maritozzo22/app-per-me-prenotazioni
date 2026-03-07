import 'package:app_prenotazioni/core/database/test_data_generator.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestDataGenerator', () {
    group('generateTestReservations', () {
      test('generates correct number of reservations', () {
        final reservations = TestDataGenerator.generateTestReservations(100);

        expect(reservations.length, equals(100));
      });

      test('generates reservations with unique IDs', () {
        final reservations = TestDataGenerator.generateTestReservations(100);

        final ids = reservations.map((r) => r.id).toSet();
        expect(ids.length, equals(100));
      });

      test('generates reservations distributed across all default rooms', () {
        final reservations = TestDataGenerator.generateTestReservations(100);
        final defaultRooms = Room.defaultRooms;

        final roomIds = reservations.map((r) => r.roomId).toSet();

        // All default rooms should have at least one reservation
        for (final room in defaultRooms) {
          expect(roomIds.contains(room.id), isTrue,
              reason: 'Room ${room.id} should have reservations');
        }
      });

      test('generates reservations distributed across all default platforms', () {
        final reservations = TestDataGenerator.generateTestReservations(100);
        final defaultPlatforms = BookingPlatform.defaultPlatforms;

        final platformIds = reservations.map((r) => r.platformId).toSet();

        // All default platforms should have at least one reservation
        for (final platform in defaultPlatforms) {
          expect(platformIds.contains(platform.id), isTrue,
              reason: 'Platform ${platform.id} should have reservations');
        }
      });

      test('generates reservations with varied payment statuses', () {
        final reservations = TestDataGenerator.generateTestReservations(100);

        final paymentStatuses = reservations.map((r) => r.paymentStatus).toSet();

        // Should have at least 2 different payment statuses
        expect(paymentStatuses.length, greaterThanOrEqualTo(2));
      });

      test('generates reservations with dates spanning past, present, and future', () {
        final now = DateTime.now();
        final reservations = TestDataGenerator.generateTestReservations(100);

        final hasPast = reservations.any((r) => r.checkIn.isBefore(now));
        final hasFuture = reservations.any((r) => r.checkIn.isAfter(now));

        expect(hasPast, isTrue, reason: 'Should have reservations in the past');
        expect(hasFuture, isTrue, reason: 'Should have reservations in the future');
      });

      test('generates reservations with no overlapping dates for same room', () {
        final reservations = TestDataGenerator.generateTestReservations(100);

        // Group reservations by room
        final reservationsByRoom = <String, List<Reservation>>{};
        for (final reservation in reservations) {
          reservationsByRoom.putIfAbsent(reservation.roomId, () => []);
          reservationsByRoom[reservation.roomId]!.add(reservation);
        }

        // Check for overlaps within each room
        for (final entry in reservationsByRoom.entries) {
          final roomReservations = entry.value;
          roomReservations.sort((a, b) => a.checkIn.compareTo(b.checkIn));

          for (int i = 0; i < roomReservations.length - 1; i++) {
            final current = roomReservations[i];
            final next = roomReservations[i + 1];

            // Current check-out should be <= next check-in (no overlap)
            // Adjacent dates are allowed (same-day turnaround)
            expect(
              current.checkOut.compareTo(next.checkIn),
              lessThanOrEqualTo(0),
              reason: 'Room ${entry.key}: Reservation ${current.id} overlaps with ${next.id}',
            );
          }
        }
      });

      test('generates reproducible reservations with same seed', () {
        final reservations1 = TestDataGenerator.generateTestReservations(10);
        final reservations2 = TestDataGenerator.generateTestReservations(10);

        // Same seed should produce same reservations
        for (int i = 0; i < 10; i++) {
          expect(reservations1[i].id, equals(reservations2[i].id));
          expect(reservations1[i].guest.name, equals(reservations2[i].guest.name));
          expect(reservations1[i].checkIn, equals(reservations2[i].checkIn));
        }
      });

      test('generates reservations with realistic stay duration (1-14 nights)', () {
        final reservations = TestDataGenerator.generateTestReservations(100);

        for (final reservation in reservations) {
          final nights = reservation.numberOfNights;
          expect(nights, greaterThanOrEqualTo(1));
          expect(nights, lessThanOrEqualTo(14));
        }
      });

      test('generates reservations with realistic prices', () {
        final reservations = TestDataGenerator.generateTestReservations(100);

        for (final reservation in reservations) {
          expect(reservation.amount, isNotNull);
          expect(reservation.amount!, greaterThan(0));

          final pricePerNight = reservation.amount! / reservation.numberOfNights;
          // Price per night should be between 50 and 200
          expect(pricePerNight, greaterThanOrEqualTo(50));
          expect(pricePerNight, lessThanOrEqualTo(200));
        }
      });

      test('generates large dataset (1000+ reservations) efficiently', () {
        final stopwatch = Stopwatch()..start();
        final reservations = TestDataGenerator.generateTestReservations(1000);
        stopwatch.stop();

        expect(reservations.length, equals(1000));
        // Generation should be fast (<1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
