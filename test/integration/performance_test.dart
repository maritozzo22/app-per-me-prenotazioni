import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_list_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../helpers/performance_test_helper.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('End-to-End Performance Tests', () {
    test('Full app workflow with 1000 reservations completes successfully', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      // Clear SharedPreferences cache
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(overrides: [
        reservationRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final totalStopwatch = Stopwatch()..start();

      // 1. Load reservations list (first page)
      print('Loading reservations list page 1...');
      final listStopwatch = Stopwatch()..start();
      final listNotifier = container.read(reservationListProvider.notifier);
      // Trigger load of first page
      await listNotifier.loadInitial();
      listStopwatch.stop();

      final listState = container.read(reservationListProvider);
      expect(listState.reservations.length, equals(20)); // First page
      print('List loaded: ${listState.reservations.length} reservations in ${listStopwatch.elapsedMilliseconds}ms');

      // 2. Load calendar (3 months)
      print('Loading calendar...');
      final calendarStopwatch = Stopwatch()..start();
      final calendarNotifier = container.read(calendarProvider.notifier);
      // Wait for calendar load
      while (container.read(calendarProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      calendarStopwatch.stop();

      final calendarState = container.read(calendarProvider);
      expect(calendarState.isLoading, isFalse);
      print('Calendar loaded: ${calendarState.loadedMonths.length} months in ${calendarStopwatch.elapsedMilliseconds}ms');

      // 3. Load dashboard (first time, no cache)
      print('Loading dashboard (no cache)...');
      final dashboardStopwatch = Stopwatch()..start();
      final dashboardNotifier = container.read(dashboardProvider.notifier);
      // Wait for dashboard load
      while (container.read(dashboardProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      dashboardStopwatch.stop();

      final dashboardState = container.read(dashboardProvider);
      expect(dashboardState.isLoading, isFalse);
      expect(dashboardState.statistics, isNotNull);
      print('Dashboard calculated (no cache) in ${dashboardStopwatch.elapsedMilliseconds}ms');

      // 4. Reload dashboard (from cache)
      print('Loading dashboard (cached)...');
      // Create new container to reload from cache
      final container2 = ProviderContainer(overrides: [
        reservationRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final cachedDashboardStopwatch = Stopwatch()..start();
      final dashboardNotifier2 = container2.read(dashboardProvider.notifier);
      // Wait for cached load
      while (container2.read(dashboardProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      cachedDashboardStopwatch.stop();

      final cachedDashboardState = container2.read(dashboardProvider);
      expect(cachedDashboardState.isLoading, isFalse);
      print('Dashboard loaded (cached) in ${cachedDashboardStopwatch.elapsedMilliseconds}ms');

      totalStopwatch.stop();

      print('\n=== Full Workflow Performance Summary ===');
      print('Total workflow time: ${totalStopwatch.elapsed.inSeconds}s ${totalStopwatch.elapsed.inMilliseconds % 1000}ms');
      print('  - List (first page): ${listStopwatch.elapsedMilliseconds}ms');
      print('  - Calendar (3 months): ${calendarStopwatch.elapsedMilliseconds}ms');
      print('  - Dashboard (no cache): ${dashboardStopwatch.elapsedMilliseconds}ms');
      print('  - Dashboard (cached): ${cachedDashboardStopwatch.elapsedMilliseconds}ms');

      // Overall workflow should complete in <5 seconds
      PerformanceTestHelper.assertPerformance(
        actual: totalStopwatch.elapsed,
        max: const Duration(seconds: 5),
        operation: 'Full app workflow',
      );

      container.dispose();
      container2.dispose();
    });
  });
}
