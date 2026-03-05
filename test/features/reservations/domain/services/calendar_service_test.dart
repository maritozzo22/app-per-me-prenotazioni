import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/calendar_service.dart';

void main() {
  group('CalendarService', () {
    late CalendarService service;

    setUp(() {
      service = CalendarService();
    });

    test('groups single-day reservation correctly', () {
      final reservation = Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Mario', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 16), // 1 night
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final result = service.groupReservationsByDate([reservation]);

      expect(result.length, 1);
      expect(result[DateTime(2024, 6, 15)], [reservation]);
    });

    test('groups multi-day reservation to all days in range', () {
      final reservation = Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Mario', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18), // 3 nights
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final result = service.groupReservationsByDate([reservation]);

      expect(result.length, 3);
      expect(result[DateTime(2024, 6, 15)], [reservation]);
      expect(result[DateTime(2024, 6, 16)], [reservation]);
      expect(result[DateTime(2024, 6, 17)], [reservation]);
      expect(result[DateTime(2024, 6, 18)], isNull); // Check-out day NOT included
    });

    test('groups multiple overlapping reservations for same day', () {
      final reservation1 = Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Mario', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final reservation2 = Reservation(
        id: '2',
        roomId: 'room-2', // Different room
        platformId: 'airbnb',
        guest: Guest(name: 'Luca', phone: null),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 17),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      final result = service.groupReservationsByDate([reservation1, reservation2]);

      expect(result[DateTime(2024, 6, 15)]?.length, 2);
      expect(result[DateTime(2024, 6, 16)]?.length, 2);
      expect(result[DateTime(2024, 6, 17)]?.length, 1); // Only reservation1
    });

    test('returns empty map for empty reservations list', () {
      final result = service.groupReservationsByDate([]);
      expect(result, isEmpty);
    });
  });
}
