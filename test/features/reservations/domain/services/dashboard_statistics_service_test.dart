import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

void main() {
  group('DashboardStatisticsService', () {
    late DashboardStatisticsService service;

    setUp(() {
      service = DashboardStatisticsService();
    });

    group('calculate', () {
      test('counts occupied rooms today correctly', () {
        final today = DateTime(2024, 6, 15);
        final reservations = [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 14),
            checkOut: DateTime(2024, 6, 17),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
          Reservation(
            id: '2',
            roomId: 'room-2',
            platformId: 'airbnb',
            guest: const Guest(name: 'Luca', phone: null),
            checkIn: DateTime(2024, 6, 15),
            checkOut: DateTime(2024, 6, 16),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ];

        final stats = service.calculate(reservations: reservations, currentDate: today);

        expect(stats.occupiedRoomsToday, 2);
        expect(stats.totalRooms, 4);
      });

      test('check-out day is not occupied', () {
        final today = DateTime(2024, 6, 17);
        final reservations = [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 14),
            checkOut: DateTime(2024, 6, 17), // Check-out today
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ];

        final stats = service.calculate(reservations: reservations, currentDate: today);

        expect(stats.occupiedRoomsToday, 0);
      });

      test('calculates monthly income by payment status', () {
        final today = DateTime(2024, 6, 15);
        final reservations = [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 10),
            checkOut: DateTime(2024, 6, 15),
            amount: 100,
            paymentStatus: PaymentStatus.received,
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
          Reservation(
            id: '2',
            roomId: 'room-2',
            platformId: 'airbnb',
            guest: const Guest(name: 'Luca', phone: null),
            checkIn: DateTime(2024, 6, 20),
            checkOut: DateTime(2024, 6, 25),
            amount: 200,
            paymentStatus: PaymentStatus.pending,
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ];

        final stats = service.calculate(reservations: reservations, currentDate: today);

        expect(stats.monthlyIncomeReceived, 100);
        expect(stats.monthlyIncomePending, 200);
        expect(stats.totalMonthlyIncome, 300);
      });

      test('finds upcoming check-ins within 7 days', () {
        final today = DateTime(2024, 6, 15);
        final reservations = [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 16), // Tomorrow
            checkOut: DateTime(2024, 6, 20),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
          Reservation(
            id: '2',
            roomId: 'room-2',
            platformId: 'airbnb',
            guest: const Guest(name: 'Luca', phone: null),
            checkIn: DateTime(2024, 6, 25), // 10 days - outside range
            checkOut: DateTime(2024, 6, 30),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ];

        final stats = service.calculate(reservations: reservations, currentDate: today);

        expect(stats.upcomingCheckIns.length, 1);
        expect(stats.upcomingCheckIns.first.id, '1');
      });

      test('finds upcoming check-outs within 7 days', () {
        final today = DateTime(2024, 6, 15);
        final reservations = [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 10),
            checkOut: DateTime(2024, 6, 18), // 3 days
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ];

        final stats = service.calculate(reservations: reservations, currentDate: today);

        expect(stats.upcomingCheckOuts.length, 1);
        expect(stats.upcomingCheckOuts.first.id, '1');
      });

      test('sorts upcoming check-ins by date ascending', () {
        final today = DateTime(2024, 6, 15);
        final reservations = [
          Reservation(
            id: '2',
            roomId: 'room-2',
            platformId: 'airbnb',
            guest: const Guest(name: 'Luca', phone: null),
            checkIn: DateTime(2024, 6, 18),
            checkOut: DateTime(2024, 6, 20),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: const Guest(name: 'Mario', phone: null),
            checkIn: DateTime(2024, 6, 16),
            checkOut: DateTime(2024, 6, 18),
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime(2024, 6, 1),
          ),
        ];

        final stats = service.calculate(reservations: reservations, currentDate: today);

        expect(stats.upcomingCheckIns.first.id, '1');
        expect(stats.upcomingCheckIns.last.id, '2');
      });
    });

    group('getRoomOccupancyToday', () {
      test('returns map with all room IDs', () {
        final today = DateTime(2024, 6, 15);
        final occupancy = service.getRoomOccupancyToday(
          reservations: [],
          currentDate: today,
        );

        expect(occupancy.keys, containsAll(['room-1', 'room-2', 'room-3', 'apartment']));
      });

      test('maps room to occupying reservation', () {
        final today = DateTime(2024, 6, 15);
        final reservation = Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario', phone: null),
          checkIn: DateTime(2024, 6, 14),
          checkOut: DateTime(2024, 6, 17),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        );

        final occupancy = service.getRoomOccupancyToday(
          reservations: [reservation],
          currentDate: today,
        );

        expect(occupancy['room-1'], reservation);
        expect(occupancy['room-2'], isNull);
      });
    });
  });
}
