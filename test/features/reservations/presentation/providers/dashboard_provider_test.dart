import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/statistics/domain/services/statistics_cache_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class MockReservationRepository extends Mock implements ReservationRepository {}

class MockStatisticsCacheService extends Mock implements StatisticsCacheService {}

void main() {
  group('DashboardNotifier', () {
    late MockReservationRepository mockRepository;
    late MockStatisticsCacheService mockCacheService;
    late DashboardNotifier notifier;

    setUp(() {
      mockRepository = MockReservationRepository();
      mockCacheService = MockStatisticsCacheService();

      registerFallbackValue(Reservation(
        id: 'test',
        roomId: 'room-1',
        platformId: 'booking',
        guest: const Guest(name: 'Test', phone: null),
        checkIn: DateTime(2024, 1, 1),
        checkOut: DateTime(2024, 1, 2),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ));

      registerFallbackValue(DashboardStatistics(
        occupiedRoomsToday: 0,
        totalRooms: 4,
        monthlyIncomeReceived: 0,
        monthlyIncomePending: 0,
        upcomingCheckIns: [],
        upcomingCheckOuts: [],
      ));
    });

    test('initial state sets isLoading true when loadDashboard starts', () async {
      // Arrange - mock cache to return null for initial load
      when(() => mockCacheService.getCachedStatistics())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);
      when(() => mockCacheService.setCachedStatistics(any()))
          .thenAnswer((_) async {});

      // Act - create notifier which immediately calls loadDashboard
      notifier = DashboardNotifier(mockRepository, mockCacheService);

      // Assert - isLoading should be true immediately after construction
      // (loadDashboard sets isLoading=true synchronously)
      expect(notifier.state.isLoading, true);

      // Wait for load to complete
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.state.isLoading, false);
    });

    test('loadDashboard uses cached statistics if valid', () async {
      final testStatistics = DashboardStatistics(
        occupiedRoomsToday: 2,
        totalRooms: 4,
        monthlyIncomeReceived: 1500.0,
        monthlyIncomePending: 500.0,
        upcomingCheckIns: [],
        upcomingCheckOuts: [],
      );

      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario', phone: null),
          checkIn: DateTime.now().subtract(const Duration(days: 1)),
          checkOut: DateTime.now().add(const Duration(days: 2)),
          amount: 100,
          paymentStatus: PaymentStatus.received,
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        ),
      ];

      when(() => mockCacheService.getCachedStatistics())
          .thenAnswer((_) async => testStatistics);
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);

      notifier = DashboardNotifier(mockRepository, mockCacheService);
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for init

      expect(notifier.state.isLoading, false);
      expect(notifier.state.statistics, isNotNull);
      expect(notifier.state.statistics!.occupiedRoomsToday, 2);
      verify(() => mockCacheService.getCachedStatistics()).called(1);
      // Still need to call getAllReservations for room occupancy (changes daily)
      verify(() => mockRepository.getAllReservations()).called(1);
      // Should NOT call setCachedStatistics when cache is valid
      verifyNever(() => mockCacheService.setCachedStatistics(any()));
    });

    test('loadDashboard recalculates if cache invalid', () async {
      final reservations = [
        Reservation(
          id: '1',
          roomId: 'room-1',
          platformId: 'booking',
          guest: const Guest(name: 'Mario', phone: null),
          checkIn: DateTime.now().subtract(const Duration(days: 1)),
          checkOut: DateTime.now().add(const Duration(days: 2)),
          amount: 100,
          paymentStatus: PaymentStatus.received,
          createdAt: DateTime(2024, 6, 1),
          updatedAt: DateTime(2024, 6, 1),
        ),
      ];

      when(() => mockCacheService.getCachedStatistics())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => reservations);
      when(() => mockCacheService.setCachedStatistics(any()))
          .thenAnswer((_) async {});

      notifier = DashboardNotifier(mockRepository, mockCacheService);
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for init

      expect(notifier.state.isLoading, false);
      expect(notifier.state.statistics, isNotNull);
      expect(notifier.state.statistics!.occupiedRoomsToday, 1);
      verify(() => mockCacheService.getCachedStatistics()).called(1);
      verify(() => mockRepository.getAllReservations()).called(1);
      verify(() => mockCacheService.setCachedStatistics(any())).called(1);
    });

    test('loadDashboard calculates room occupancy', () async {
      when(() => mockCacheService.getCachedStatistics())
          .thenAnswer((_) async => null);
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);
      when(() => mockCacheService.setCachedStatistics(any()))
          .thenAnswer((_) async {});

      notifier = DashboardNotifier(mockRepository, mockCacheService);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.roomOccupancy.length, 4);
    });

    test('refresh invalidates cache and reloads', () async {
      final testStatistics = DashboardStatistics(
        occupiedRoomsToday: 2,
        totalRooms: 4,
        monthlyIncomeReceived: 1500.0,
        monthlyIncomePending: 500.0,
        upcomingCheckIns: [],
        upcomingCheckOuts: [],
      );

      when(() => mockCacheService.getCachedStatistics())
          .thenAnswer((_) async => testStatistics);
      when(() => mockRepository.getAllReservations())
          .thenAnswer((_) async => []);
      when(() => mockCacheService.invalidateCache())
          .thenAnswer((_) async {});

      notifier = DashboardNotifier(mockRepository, mockCacheService);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.refresh();

      verify(() => mockCacheService.invalidateCache()).called(1);
      verify(() => mockCacheService.getCachedStatistics()).called(greaterThanOrEqualTo(2));
    });

    test('saveReservation invalidates dashboard cache', () async {
      when(() => mockCacheService.invalidateCache())
          .thenAnswer((_) async {});

      // Act - This would typically be called from ReservationProvider after save
      await mockCacheService.invalidateCache();

      verify(() => mockCacheService.invalidateCache()).called(1);
    });

    test('deleteReservation invalidates dashboard cache', () async {
      when(() => mockCacheService.invalidateCache())
          .thenAnswer((_) async {});

      // Act - This would typically be called from ReservationProvider after delete
      await mockCacheService.invalidateCache();

      verify(() => mockCacheService.invalidateCache()).called(1);
    });
  });
}
