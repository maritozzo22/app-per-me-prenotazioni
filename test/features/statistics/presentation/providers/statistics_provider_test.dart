import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/period_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/aggregate_statistics.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/year_over_year_comparison.dart';
import 'package:app_prenotazioni/features/statistics/presentation/providers/statistics_provider.dart';
import 'package:app_prenotazioni/core/providers/statistics_providers.dart';
import 'package:app_prenotazioni/features/statistics/domain/repositories/statistics_repository.dart';

import 'package:mocktail/mocktail.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const StatisticsFilter());
  });

  group('statisticsFilterProvider', () {
    test('defaults to month period', () {
      final container = ProviderContainer();

      final filter = container.read(statisticsFilterProvider);

      expect(filter.period, equals(PeriodFilter.month));
      expect(filter.includePending, isTrue);
      expect(filter.customStartDate, isNull);
      expect(filter.customEndDate, isNull);

      container.dispose();
    });
  });

  group('statisticsProvider', () {
    late MockStatisticsRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockStatisticsRepository();

      // Create sample statistics for testing
      final sampleStatistics = AggregateStatistics(
        totalRevenue: 10000.0,
        occupancyRate: 75.5,
        averageStayDuration: 3.5,
        totalBookings: 25,
        totalGuests: 50,
        platformBreakdown: [
          PlatformRevenue(
            platformId: '1',
            platformName: 'Airbnb',
            color: 0xFFFF5A5F,
            totalRevenue: 6000.0,
            bookingCount: 15,
            percentage: 60.0,
          ),
        ],
        monthlyTrend: [
          MonthlyRevenue(
            month: '2026-03',
            revenue: 10000.0,
            bookingCount: 25,
          ),
        ],
        yearOverYear: YearOverYearComparison(
          year1: 2025,
          year2: 2026,
          year1Monthly: List.filled(12, 0.0),
          year2Monthly: List.filled(12, 0.0),
        ),
      );

      // Setup mock to return sample statistics
      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => sampleStatistics);

      container = ProviderContainer(
        overrides: [
          statisticsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads data on initialization', () async {
      // Watch the provider to trigger initialization
      final provider = container.read(statisticsProvider.notifier);

      // Wait for the build to complete
      await provider.future;

      // Verify repository was called
      verify(() => mockRepository.getStatistics(any())).called(1);
    });

    test('shows loading state during fetch', () async {
      // Use a slow future to capture loading state
      final slowRepository = MockStatisticsRepository();
      final completer = Future.delayed(const Duration(milliseconds: 100));

      when(() => slowRepository.getStatistics(any())).thenAnswer((_) async {
        await completer;
        return AggregateStatistics(
          totalRevenue: 0,
          occupancyRate: 0,
          averageStayDuration: 0,
          totalBookings: 0,
          totalGuests: 0,
          platformBreakdown: [],
          monthlyTrend: [],
          yearOverYear: null,
        );
      });

      final slowContainer = ProviderContainer(
        overrides: [
          statisticsRepositoryProvider.overrideWithValue(slowRepository),
        ],
      );

      // Read immediately - should be loading
      final asyncValue = slowContainer.read(statisticsProvider);
      expect(asyncValue.isLoading, isTrue);

      slowContainer.dispose();
    });

    test('shows error state on failure', () async {
      final errorRepository = MockStatisticsRepository();

      when(() => errorRepository.getStatistics(any()))
          .thenThrow(Exception('Database error'));

      final errorContainer = ProviderContainer(
        overrides: [
          statisticsRepositoryProvider.overrideWithValue(errorRepository),
        ],
      );

      // Wait for the error
      await errorContainer.read(statisticsProvider.notifier).future.catchError((_) {});

      final asyncValue = errorContainer.read(statisticsProvider);
      expect(asyncValue.hasError, isTrue);
      expect(asyncValue.error.toString(), contains('Database error'));

      errorContainer.dispose();
    });

    test('refreshing fetches fresh data', () async {
      final notifier = container.read(statisticsProvider.notifier);

      // Wait for initial load
      await notifier.future;

      // Reset mock to track new calls
      reset(mockRepository);

      // Setup mock again for refresh
      final freshStatistics = AggregateStatistics(
        totalRevenue: 15000.0,
        occupancyRate: 80.0,
        averageStayDuration: 4.0,
        totalBookings: 30,
        totalGuests: 60,
        platformBreakdown: [],
        monthlyTrend: [],
        yearOverYear: null,
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => freshStatistics);

      // Refresh
      await notifier.refresh();

      // Verify repository was called again
      verify(() => mockRepository.getStatistics(any())).called(1);

      // Verify data was updated
      final data = container.read(statisticsProvider).value;
      expect(data?.totalRevenue, equals(15000.0));
    });

    test('updateFilter triggers refresh with new filter', () async {
      // Create a fresh mock for this test
      final testRepository = MockStatisticsRepository();

      final testStatistics = AggregateStatistics(
        totalRevenue: 5000.0,
        occupancyRate: 50.0,
        averageStayDuration: 2.5,
        totalBookings: 10,
        totalGuests: 20,
        platformBreakdown: [],
        monthlyTrend: [],
        yearOverYear: null,
      );

      when(() => testRepository.getStatistics(any()))
          .thenAnswer((_) async => testStatistics);

      final testContainer = ProviderContainer(
        overrides: [
          statisticsRepositoryProvider.overrideWithValue(testRepository),
        ],
      );

      final notifier = testContainer.read(statisticsProvider.notifier);

      // Wait for initial load
      await notifier.future;

      // Update filter
      final newFilter = const StatisticsFilter(period: PeriodFilter.year);
      await notifier.updateFilter(newFilter);

      // Verify filter was updated
      final currentFilter = testContainer.read(statisticsFilterProvider);
      expect(currentFilter.period, equals(PeriodFilter.year));

      // Verify repository was called twice (initial + refresh)
      verify(() => testRepository.getStatistics(any())).called(2);

      testContainer.dispose();
    });
  });
}
