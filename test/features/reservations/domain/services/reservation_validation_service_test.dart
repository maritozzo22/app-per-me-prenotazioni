import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/reservation_validation_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late ReservationValidationService service;
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
    service = ReservationValidationService(mockRepository);
  });

  group('validateDates', () {
    test('should return success when check-out is after check-in', () {
      final result = service.validateDates(
        DateTime(2024, 6, 15),
        DateTime(2024, 6, 18),
      );
      expect(result.isValid, isTrue);
    });

    test('should return failure when check-out equals check-in', () {
      final result = service.validateDates(
        DateTime(2024, 6, 15),
        DateTime(2024, 6, 15),
      );
      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('check-out deve essere successiva'));
    });

    test('should return failure when check-out is before check-in', () {
      final result = service.validateDates(
        DateTime(2024, 6, 18),
        DateTime(2024, 6, 15),
      );
      expect(result.isInvalid, isTrue);
    });
  });

  group('checkRoomAvailability', () {
    test('should return success when no conflicting reservations', () async {
      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => []);

      final result = await service.checkRoomAvailability(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isValid, isTrue);
    });

    test('should return failure with details when overlap exists', () async {
      final existingReservation = Reservation(
        id: 'existing-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Mario Rossi'),
        checkIn: DateTime(2024, 6, 16),
        checkOut: DateTime(2024, 6, 20),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [existingReservation]);

      final result = await service.checkRoomAvailability(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('Sovrapposizione'));
      expect(result.errorMessage, contains('Mario Rossi'));
      expect(result.details, isNotNull);
    });

    test('should allow same-day turnaround (check-out = next check-in)', () async {
      final existingReservation = Reservation(
        id: 'existing-id',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Mario Rossi'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [existingReservation]);

      // New reservation starts on the day existing one ends
      final result = await service.checkRoomAvailability(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 18), // Same day as existing check-out
        checkOut: DateTime(2024, 6, 20),
      );

      expect(result.isValid, isTrue);
    });
  });

  group('checkApartmentAvailability', () {
    test('should return success when no rooms are booked', () async {
      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => []);

      final result = await service.checkApartmentAvailability(
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isValid, isTrue);
    });

    test('should return failure with room name when room 2 is booked', () async {
      final existingReservation = Reservation(
        id: 'existing-id',
        roomId: 'room-2',
        platformId: 'booking',
        guest: const Guest(name: 'Luigi Verdi'),
        checkIn: DateTime(2024, 6, 16),
        checkOut: DateTime(2024, 6, 20),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [existingReservation]);

      final result = await service.checkApartmentAvailability(
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('Stanza 2'));
      expect(result.details?['blockingRoom'], 'room-2');
    });
  });

  group('checkRoomAgainstApartment', () {
    test('should return failure when apartment is booked for those dates', () async {
      final apartmentReservation = Reservation(
        id: 'apartment-id',
        roomId: 'apartment',
        platformId: 'airbnb',
        guest: const Guest(name: 'Family Smith'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 20),
        createdAt: DateTime(2024, 6, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => [apartmentReservation]);

      final result = await service.checkRoomAgainstApartment(
        roomId: 'room-1',
        checkIn: DateTime(2024, 6, 16),
        checkOut: DateTime(2024, 6, 18),
      );

      expect(result.isInvalid, isTrue);
      expect(result.errorMessage, contains('Appartamento Intero'));
    });
  });
}
