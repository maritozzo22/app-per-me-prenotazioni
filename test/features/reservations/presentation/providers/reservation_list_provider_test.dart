import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/paginated_result.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_list_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MockReservationRepository extends Mock implements ReservationRepository {}
class FakeReservationFilter extends Fake implements ReservationFilter {}

void main() {
  late MockReservationRepository mockRepository;
  late SharedPreferences sharedPreferences;

  setUpAll(() {
    registerFallbackValue(FakeReservationFilter());
  });

  setUp(() async {
    mockRepository = MockReservationRepository();
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  group('ReservationListNotifier', () {
    group('initialization', () {
      test('should load first 20 reservations on initialization', () async {
        // Arrange
        final reservations = List.generate(
          20,
          (i) => _createTestReservation(id: 'reservation-$i'),
        );
        when(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: 1,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: reservations,
              totalCount: 100,
              currentPage: 1,
              pageSize: 20,
            ));

        // Act
        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
        );
        await container.read(reservationListProvider.notifier).loadInitial();

        // Assert
        final state = container.read(reservationListProvider);
        expect(state.reservations.length, equals(20));
        expect(state.currentPage, equals(1));
        expect(state.totalCount, equals(100));
        expect(state.isLoading, isFalse);
        expect(state.hasMore, isTrue);

        verify(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: 1,
              pageSize: 20,
            )).called(1);
      });
    });

    group('loadMore', () {
      test('should append next 20 reservations to existing list', () async {
        // Arrange
        final page1Reservations = List.generate(
          20,
          (i) => _createTestReservation(id: 'reservation-$i'),
        );
        final page2Reservations = List.generate(
          20,
          (i) => _createTestReservation(id: 'reservation-${i + 20}'),
        );

        when(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: 1,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: page1Reservations,
              totalCount: 100,
              currentPage: 1,
              pageSize: 20,
            ));

        when(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: 2,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: page2Reservations,
              totalCount: 100,
              currentPage: 2,
              pageSize: 20,
            ));

        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
        );
        await container.read(reservationListProvider.notifier).loadInitial();

        // Act
        await container.read(reservationListProvider.notifier).loadMore();

        // Assert
        final state = container.read(reservationListProvider);
        expect(state.reservations.length, equals(40));
        expect(state.currentPage, equals(2));
        expect(state.isLoadingMore, isFalse);
        expect(state.hasMore, isTrue);
      });

      test('should set hasMore to false when last page reached', () async {
        // Arrange
        final reservations = List.generate(
          5,
          (i) => _createTestReservation(id: 'reservation-$i'),
        );

        when(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: 1,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: reservations,
              totalCount: 5,
              currentPage: 1,
              pageSize: 20,
            ));

        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
        );
        await container.read(reservationListProvider.notifier).loadInitial();

        // Assert
        final state = container.read(reservationListProvider);
        expect(state.hasMore, isFalse);
      });

      test('should not load more if already loading', () async {
        // Arrange
        final reservations = List.generate(
          20,
          (i) => _createTestReservation(id: 'reservation-$i'),
        );

        when(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: any(named: 'page'),
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: reservations,
              totalCount: 100,
              currentPage: 1,
              pageSize: 20,
            ));

        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
        );
        await container.read(reservationListProvider.notifier).loadInitial();

        // Act - Start loading more (don't await)
        container.read(reservationListProvider.notifier).loadMore();
        // Try to load more again while still loading
        await container.read(reservationListProvider.notifier).loadMore();

        // Assert - Should only call repository twice (initial + one loadMore)
        verify(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: any(named: 'page'),
              pageSize: 20,
            )).called(2);
      });
    });

    group('applyFilter', () {
      test('should reset to page 1 with new filter', () async {
        // Arrange
        final initialReservations = List.generate(
          20,
          (i) => _createTestReservation(id: 'reservation-$i'),
        );
        final filteredReservations = List.generate(
          5,
          (i) => _createTestReservation(id: 'filtered-$i'),
        );

        when(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: 1,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: initialReservations,
              totalCount: 100,
              currentPage: 1,
              pageSize: 20,
            ));

        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
        );
        await container.read(reservationListProvider.notifier).loadInitial();

        // Setup filter response
        const newFilter = ReservationFilter(platformId: 'platform-1');
        when(() => mockRepository.getReservationsFiltered(
              filter: newFilter,
              page: 1,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: filteredReservations,
              totalCount: 5,
              currentPage: 1,
              pageSize: 20,
            ));

        // Act
        await container.read(reservationListProvider.notifier).applyFilter(newFilter);

        // Assert
        final state = container.read(reservationListProvider);
        expect(state.reservations.length, equals(5));
        expect(state.currentPage, equals(1));
        expect(state.totalCount, equals(5));
        expect(state.activeFilter.platformId, equals('platform-1'));
      });

      test('should persist filter to SharedPreferences', () async {
        // Arrange
        when(() => mockRepository.getReservationsFiltered(
              filter: any(named: 'filter'),
              page: 1,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: [],
              totalCount: 0,
              currentPage: 1,
              pageSize: 20,
            ));

        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
        );

        // Act
        const filter = ReservationFilter(platformId: 'platform-123');
        await container.read(reservationListProvider.notifier).applyFilter(filter);

        // Assert
        final savedFilterJson = sharedPreferences.getString('reservation_filter');
        expect(savedFilterJson, isNotNull);
        final savedFilterMap = jsonDecode(savedFilterJson!) as Map<String, dynamic>;
        expect(savedFilterMap['platformId'], equals('platform-123'));
      });
    });

    group('filter persistence', () {
      test('should load saved filter on initialization', () async {
        // Arrange
        const savedFilter = ReservationFilter(platformId: 'saved-platform');
        await sharedPreferences.setString(
          'reservation_filter',
          jsonEncode(savedFilter.toMap()),
        );

        when(() => mockRepository.getReservationsFiltered(
              filter: savedFilter,
              page: 1,
              pageSize: 20,
            )).thenAnswer((_) async => PaginatedResult(
              items: [],
              totalCount: 0,
              currentPage: 1,
              pageSize: 20,
            ));

        // Act
        final container = ProviderContainer(
          overrides: [
            reservationRepositoryProvider.overrideWithValue(mockRepository),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
        );
        await container.read(reservationListProvider.notifier).loadInitial();

        // Assert
        final state = container.read(reservationListProvider);
        expect(state.activeFilter.platformId, equals('saved-platform'));
      });
    });
  });
}

// Helper function
Reservation _createTestReservation({required String id}) {
  return Reservation(
    id: id,
    roomId: 'room-1',
    platformId: 'platform-1',
    guest: const Guest(name: 'Test Guest', phone: null),
    checkIn: DateTime(2026, 3, 1),
    checkOut: DateTime(2026, 3, 5),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
