import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/statistics/presentation/pages/statistics_page.dart';
import 'package:app_prenotazioni/features/statistics/presentation/providers/statistics_provider.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/aggregate_statistics.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';
import 'package:app_prenotazioni/core/providers/statistics_providers.dart';
import 'package:app_prenotazioni/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const StatisticsFilter());
  });

  group('StatisticsPage', () {
    late MockStatisticsRepository mockRepository;
    late AggregateStatistics testStatistics;

    setUp(() {
      mockRepository = MockStatisticsRepository();

      testStatistics = AggregateStatistics(
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
        yearOverYear: null,
      );

      when(() => mockRepository.getStatistics(any()))
          .thenAnswer((_) async => testStatistics);
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      // Create a slow repository to capture loading state
      final slowRepository = MockStatisticsRepository();
      when(() => slowRepository.getStatistics(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return testStatistics;
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsRepositoryProvider.overrideWithValue(slowRepository),
          ],
          child: const MaterialApp(
            home: StatisticsPage(),
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Wait for loading to complete
      await tester.pumpAndSettle();
    });

    testWidgets('shows KPI cards with data on success', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: StatisticsPage(),
          ),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should display KPI cards with data
      expect(find.text('Fatturato'), findsOneWidget);
      expect(find.text('Occupazione'), findsOneWidget);
      expect(find.text('Durata Media'), findsOneWidget);
      expect(find.text('Prenotazioni'), findsOneWidget);
      expect(find.text('Ospiti'), findsOneWidget);
    });

    testWidgets('period filter selector is visible', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: StatisticsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display period filter options
      expect(find.text('Mese'), findsOneWidget);
      expect(find.text('Trimestre'), findsOneWidget);
      expect(find.text('Anno'), findsOneWidget);
      expect(find.text('Personalizzato'), findsOneWidget);
    });

    testWidgets('refresh button triggers data reload', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: StatisticsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial load
      verify(() => mockRepository.getStatistics(any())).called(1);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify refresh triggered another load
      verify(() => mockRepository.getStatistics(any())).called(1);
    });

    testWidgets('shows error message on failure', (tester) async {
      final errorRepository = MockStatisticsRepository();
      when(() => errorRepository.getStatistics(any()))
          .thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsRepositoryProvider.overrideWithValue(errorRepository),
          ],
          child: const MaterialApp(
            home: StatisticsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display error message
      expect(find.textContaining('Errore'), findsWidgets);
    });

    testWidgets('has AppBar with title Statistiche', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: StatisticsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Statistiche'), findsOneWidget);
    });

    testWidgets('has correct key', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statisticsRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: StatisticsPage(),
          ),
        ),
      );

      expect(find.byKey(const Key('statistics_view')), findsOneWidget);
    });
  });
}
