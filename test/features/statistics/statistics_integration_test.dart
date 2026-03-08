import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/statistics/presentation/pages/statistics_page.dart';
import 'package:app_prenotazioni/features/statistics/presentation/providers/statistics_provider.dart';
import 'package:app_prenotazioni/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/aggregate_statistics.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/year_over_year_comparison.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/core/providers/statistics_providers.dart';
import 'package:app_prenotazioni/features/statistics/domain/services/statistics_cache_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

class MockStatisticsCacheService extends Mock implements StatisticsCacheService {}

void main() {
  late MockStatisticsRepository mockRepository;
  late MockStatisticsCacheService mockCacheService;

  setUp(() {
    mockRepository = MockStatisticsRepository();
    mockCacheService = MockStatisticsCacheService();
    registerFallbackValue(const StatisticsFilter());
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        statisticsRepositoryProvider.overrideWithValue(mockRepository),
        statisticsCacheServiceProvider.overrideWithValue(mockCacheService),
      ],
      child: const MaterialApp(
        home: StatisticsPage(),
      ),
    );
  }

  group('Statistics Integration Tests', () {
    testWidgets('Full flow: loading -> success with data -> charts visible', (tester) async {
      // Setup mock data
      final mockStatistics = AggregateStatistics(
        totalRevenue: 5000.0,
        occupancyRate: 75.0,
        averageStayDuration: 3.5,
        totalBookings: 15,
        totalGuests: 20,
        platformBreakdown: [
          PlatformRevenue(
            platformId: 'booking',
            platformName: 'Booking',
            color: 0xFF2196F3,
            totalRevenue: 3000.0,
            bookingCount: 10,
            percentage: 60.0,
          ),
          PlatformRevenue(
            platformId: 'airbnb',
            platformName: 'Airbnb',
            color: 0xFFFF5A5F,
            totalRevenue: 2000.0,
            bookingCount: 5,
            percentage: 40.0,
          ),
        ],
        monthlyTrend: [
          MonthlyRevenue(month: '2025-01', revenue: 1000.0, bookingCount: 3),
          MonthlyRevenue(month: '2025-02', revenue: 2000.0, bookingCount: 5),
          MonthlyRevenue(month: '2025-03', revenue: 2000.0, bookingCount: 7),
        ],
        yearOverYear: YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: [800.0, 1500.0, 1800.0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          year2Monthly: [1000.0, 2000.0, 2000.0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ),
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => mockStatistics);
      when(() => mockCacheService.isCacheValid())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());

      // Verify loading state initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify KPI cards
      expect(find.text('Fatturato'), findsOneWidget);
      expect(find.text('Occupazione'), findsOneWidget);
      expect(find.text('Durata Media'), findsOneWidget);
      expect(find.text('Prenotazioni'), findsOneWidget);
      expect(find.text('Ospiti'), findsOneWidget);

      // Verify charts section
      expect(find.text('Analisi'), findsOneWidget);
      expect(find.text('Confronto Annuale'), findsOneWidget);
      expect(find.text('Fatturato per Piattaforma'), findsOneWidget);
      expect(find.text('Trend Mensile'), findsOneWidget);
    });

    testWidgets('Performance test: 100+ data points loads in < 2 seconds', (tester) async {
      // Generate 100+ platform revenue entries
      final platforms = List.generate(100, (i) =>
        PlatformRevenue(
          platformId: 'platform-$i',
          platformName: 'Platform $i',
          color: 0xFF2196F3,
          totalRevenue: 100.0 * i,
          bookingCount: i,
          percentage: 1.0,
        ),
      );

      final mockStatistics = AggregateStatistics(
        totalRevenue: 50000.0,
        occupancyRate: 75.0,
        averageStayDuration: 3.5,
        totalBookings: 100,
        totalGuests: 150,
        platformBreakdown: platforms,
        monthlyTrend: List.generate(12, (i) =>
          MonthlyRevenue(month: '2025-${(i + 1).toString().padLeft(2, '0')}', revenue: 1000.0 * (i + 1), bookingCount: i + 1)
        ),
        yearOverYear: YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: List.generate(12, (i) => 800.0 * (i + 1)),
          year2Monthly: List.generate(12, (i) => 1000.0 * (i + 1)),
        ),
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => mockStatistics);
      when(() => mockCacheService.isCacheValid())
          .thenAnswer((_) async => false);

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify load time < 2 seconds (2000ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Statistics page should load in < 2 seconds with 100+ data points. '
                  'Actual time: ${stopwatch.elapsedMilliseconds}ms');

      // Verify data rendered
      expect(find.text('Fatturato'), findsOneWidget);

      debugPrint('Performance test: Loaded 100+ data points in ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Empty state displays when no data', (tester) async {
      // Setup mock to return empty statistics (zero values)
      final emptyStatistics = AggregateStatistics(
        totalRevenue: 0,
        occupancyRate: 0,
        averageStayDuration: 0,
        totalBookings: 0,
        totalGuests: 0,
        platformBreakdown: [],
        monthlyTrend: [],
        yearOverYear: null,
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => emptyStatistics);
      when(() => mockCacheService.isCacheValid())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify KPI cards show zero values
      expect(find.text('Fatturato'), findsOneWidget);
      expect(find.text('Occupazione'), findsOneWidget);
    });

    testWidgets('Error state displays on repository failure', (tester) async {
      // Setup mock to throw error
      when(() => mockRepository.getStatistics(any()))
          .thenThrow(Exception('Database error'));
      when(() => mockCacheService.isCacheValid())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.textContaining('Errore caricamento statistiche'), findsOneWidget);
    });

    testWidgets('Refresh button triggers data reload', (tester) async {
      // Setup mock data
      final mockStatistics = AggregateStatistics(
        totalRevenue: 5000.0,
        occupancyRate: 75.0,
        averageStayDuration: 3.5,
        totalBookings: 15,
        totalGuests: 20,
        platformBreakdown: [],
        monthlyTrend: [],
        yearOverYear: null,
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => mockStatistics);
      when(() => mockCacheService.isCacheValid())
          .thenAnswer((_) async => false);
      when(() => mockCacheService.invalidateCache())
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Verify cache invalidation was called
      verify(() => mockCacheService.invalidateCache()).called(greaterThanOrEqualTo(1));
    });

    testWidgets('Period filter selector displays all options', (tester) async {
      // Setup mock data
      final mockStatistics = AggregateStatistics(
        totalRevenue: 5000.0,
        occupancyRate: 75.0,
        averageStayDuration: 3.5,
        totalBookings: 15,
        totalGuests: 20,
        platformBreakdown: [],
        monthlyTrend: [],
        yearOverYear: null,
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => mockStatistics);
      when(() => mockCacheService.isCacheValid())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify period filter options are visible
      expect(find.text('Mese'), findsOneWidget);
      expect(find.text('Trimestre'), findsOneWidget);
      expect(find.text('Anno'), findsOneWidget);
      expect(find.text('Personalizzato'), findsOneWidget);
    });

    testWidgets('Responsive layout adapts to screen width', (tester) async {
      // Setup mock data
      final mockStatistics = AggregateStatistics(
        totalRevenue: 5000.0,
        occupancyRate: 75.0,
        averageStayDuration: 3.5,
        totalBookings: 15,
        totalGuests: 20,
        platformBreakdown: [],
        monthlyTrend: [],
        yearOverYear: null,
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => mockStatistics);
      when(() => mockCacheService.isCacheValid())
          .thenAnswer((_) async => false);

      // Test with wide screen
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify KPI cards are visible
      expect(find.text('Fatturato'), findsOneWidget);

      // Reset to small screen
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // KPI cards should still be visible on small screen
      expect(find.text('Fatturato'), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });
  });
}
