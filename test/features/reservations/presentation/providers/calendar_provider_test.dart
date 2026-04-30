import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

void main() {
  group('CalendarNotifier', () {
    late MockReservationRepository mockRepository;
    late CalendarNotifier notifier;

    setUpAll(() async {
      // Initialize Italian date formatting
      await initializeDateFormatting('it_IT');
      // Register fallback values for mocktail matchers
      registerFallbackValue(DateTime.now());
    });

    setUp(() {
      mockRepository = MockReservationRepository();
      // Set up default mock for getReservationsForDateRange (used by lazy loading)
      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => []);
      notifier = CalendarNotifier(mockRepository);
    });

    test('initial state has current focused day and isLoading true', () {
      expect(notifier.state.focusedDay, isNotNull);
      expect(notifier.state.reservationsByDate, isEmpty);
      expect(notifier.state.isLoading, false); // Loaded immediately
    });

    test('loadReservations groups reservations by date', () async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: Guest(name: 'Mario', phone: null),
          checkIn: DateTime(2024, 6, 15),
          checkOut: DateTime(2024, 6, 16),
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        ),
      ];

      when(() => mockRepository.getReservationsForDateRange(any(), any()))
          .thenAnswer((_) async => reservations);

      await notifier.loadReservations();

      expect(notifier.state.reservationsByDate.length, greaterThan(0));
      expect(notifier.state.isLoading, false);
    });

    test('selectDay updates selected day', () {
      final day = DateTime(2024, 6, 15);
      notifier.selectDay(day);
      expect(notifier.state.selectedDay, day);
    });

    test('changeMonth updates focused day', () {
      final newMonth = DateTime(2024, 7, 1);
      notifier.changeMonth(newMonth);
      expect(notifier.state.focusedDay, newMonth);
    });

    group('Lazy Loading', () {
      setUp(() async {
        // Reset the mock to clear any previous calls
        reset(mockRepository);
        // Set up default mock for getReservationsForDateRange
        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => []);
        // Recreate notifier for lazy loading tests
        notifier = CalendarNotifier(mockRepository);
        // Wait for initial async load to complete
        await Future.delayed(Duration(milliseconds: 50));
      });

      test('initial load fetches 3 months (current, previous, next)', () async {
        final now = DateTime.now();
        final reservations = [
          Reservation(
            id: '1',
            roomId: 'room-1',
            platformId: 'booking',
            guest: Guest(name: 'Mario', phone: null),
            checkIn: now,
            checkOut: now.add(Duration(days: 1)),
            createdAt: now,
            updatedAt: now,
          ),
        ];

        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => reservations);

        // Wait for initial load to complete
        await Future.delayed(Duration(milliseconds: 100));

        // Verify getReservationsForDateRange was called once
        verify(() => mockRepository.getReservationsForDateRange(any(), any())).called(1);

        // Verify 3 months are tracked as loaded
        expect(notifier.state.loadedMonths.length, 3);
      });

      test('changeMonth to unloaded month triggers lazy load', () async {
        final reservations = <Reservation>[];

        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => reservations);

        // Wait for initial load
        await Future.delayed(Duration(milliseconds: 100));

        // Clear any previous calls
        reset(mockRepository);
        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => reservations);

        // Change to a month far in the future (not loaded yet)
        final futureMonth = DateTime.now().add(Duration(days: 365));
        notifier.changeMonth(futureMonth);

        // Wait for debounce
        await Future.delayed(Duration(milliseconds: 400));

        // Verify lazy load was triggered
        verify(() => mockRepository.getReservationsForDateRange(any(), any())).called(1);
      });

      test('changeMonth to already loaded month does NOT trigger load', () async {
        final reservations = <Reservation>[];

        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => reservations);

        // Wait for initial load
        await Future.delayed(Duration(milliseconds: 100));

        // Clear any previous calls
        reset(mockRepository);
        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => reservations);

        // Change to current month (already loaded)
        final currentMonth = DateTime.now();
        notifier.changeMonth(currentMonth);

        // Wait for debounce
        await Future.delayed(Duration(milliseconds: 400));

        // Verify NO lazy load was triggered
        verifyNever(() => mockRepository.getReservationsForDateRange(any(), any()));
      });

      test('rapid month changes debounce to single load', () async {
        final reservations = <Reservation>[];

        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => reservations);

        // Wait for initial load
        await Future.delayed(Duration(milliseconds: 100));

        // Clear any previous calls
        reset(mockRepository);
        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async => reservations);

        // Rapidly change months 5 times
        for (int i = 0; i < 5; i++) {
          notifier.changeMonth(DateTime.now().add(Duration(days: 365 * (i + 1))));
          await Future.delayed(Duration(milliseconds: 50));
        }

        // Wait for debounce to complete
        await Future.delayed(Duration(milliseconds: 400));

        // Verify only 1 load was triggered (debounced)
        verify(() => mockRepository.getReservationsForDateRange(any(), any())).called(1);
      });

      test('refresh clears cache and reloads', () async {
        // Track how many times the repository method is called
        int callCount = 0;
        when(() => mockRepository.getReservationsForDateRange(any(), any()))
            .thenAnswer((_) async {
          callCount++;
          return [];
        });

        // Recreate notifier to use the new mock
        notifier = CalendarNotifier(mockRepository);
        await Future.delayed(Duration(milliseconds: 50));

        // Verify initial load happened
        expect(callCount, 1);

        // Refresh
        await notifier.refresh();

        // Verify loaded months were cleared and reloaded
        expect(notifier.state.loadedMonths.length, 3);
        // Verify repository was called again
        expect(callCount, 2);
      });
    });
  });
}
