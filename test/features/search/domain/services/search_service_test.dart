import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/search/domain/services/search_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  late SearchService searchService;
  late MockReservationRepository mockRepository;

  setUp(() {
    mockRepository = MockReservationRepository();
    searchService = SearchService(mockRepository);
  });

  List<Reservation> createTestReservations() {
    return [
      Reservation(
        id: '1',
        roomId: 'room-1',
        platformId: 'booking',
        guest: Guest(name: 'Mario Rossi', phone: '+39 123 456 7890'),
        checkIn: DateTime(2024, 6, 15),
        checkOut: DateTime(2024, 6, 18),
        amount: 300.0,
        paymentStatus: PaymentStatus.received,
        notes: 'Guest requires early check-in',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Reservation(
        id: '2',
        roomId: 'room-2',
        platformId: 'airbnb',
        guest: Guest(name: 'Luigi Verdi', phone: '+39 987 654 3210'),
        checkIn: DateTime(2024, 6, 20),
        checkOut: DateTime(2024, 6, 25),
        amount: 500.0,
        paymentStatus: PaymentStatus.pending,
        notes: 'Vegetarian guest',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Reservation(
        id: '3',
        roomId: 'apartment',
        platformId: 'whatsapp',
        guest: Guest(name: 'Giulia Bianchi'),
        checkIn: DateTime(2024, 7, 1),
        checkOut: DateTime(2024, 7, 7),
        amount: 800.0,
        paymentStatus: PaymentStatus.received,
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  group('SearchService', () {
    test('search with matching guest name returns matching reservations', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('Mario');

      expect(result.length, 1);
      expect(result[0].guest.name, 'Mario Rossi');
    });

    test('search with matching phone number returns matching reservations', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('123');

      expect(result.length, 1);
      expect(result[0].guest.phone, '+39 123 456 7890');
    });

    test('search with matching notes returns matching reservations', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('vegetarian');

      expect(result.length, 1);
      expect(result[0].guest.name, 'Luigi Verdi');
    });

    test('search with partial match returns matching reservations', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('Ross');

      expect(result.length, 1);
      expect(result[0].guest.name, 'Mario Rossi');
    });

    test('search with no results returns empty list', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('Nonexistent');

      expect(result, isEmpty);
    });

    test('search with empty query returns all reservations', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('');

      expect(result.length, 3);
    });

    test('search with whitespace-only query returns all reservations', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('   ');

      expect(result.length, 3);
    });

    test('search is case-insensitive', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      // Search with different cases
      final result1 = await searchService.search('MARIO');
      final result2 = await searchService.search('mario');
      final result3 = await searchService.search('MaRiO');

      expect(result1.length, 1);
      expect(result2.length, 1);
      expect(result3.length, 1);
      expect(result1[0].guest.name, 'Mario Rossi');
      expect(result2[0].guest.name, 'Mario Rossi');
      expect(result3[0].guest.name, 'Mario Rossi');
    });

    test('search matches across multiple fields', () async {
      final reservations = createTestReservations();
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      // Search term that matches name, phone, and notes across different reservations
      final result = await searchService.search('check-in');

      expect(result.length, 1);
      expect(result[0].guest.name, 'Mario Rossi');
    });

    test('search handles null phone and notes gracefully', () async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'Test Guest'), // No phone
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          amount: 300.0,
          paymentStatus: PaymentStatus.received,
          notes: null, // No notes
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('Test');

      expect(result.length, 1);
      expect(result[0].guest.name, 'Test Guest');
    });

    test('search returns multiple matches when query matches multiple reservations',
        () async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'Mario Rossi', phone: '123'),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 18),
          amount: 300.0,
          paymentStatus: PaymentStatus.received,
          notes: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Reservation(
          id: '2',
          roomId: 'room-2',
          platformId: 'airbnb',
          guest: Guest(name: 'Mario Bianchi', phone: '456'),
          checkIn: DateTime(2024, 6, 20),
          checkOut: DateTime(2024, 6, 25),
          amount: 500.0,
          paymentStatus: PaymentStatus.pending,
          notes: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      final result = await searchService.search('Mario');

      expect(result.length, 2);
    });
  });
}
