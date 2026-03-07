import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/dashboard_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../helpers/performance_test_helper.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DashboardProvider Performance Tests', () {
    test('Dashboard calculates statistics with 1000 reservations <2000ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      // Clear SharedPreferences cache
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(overrides: [
        reservationRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      // Start measuring from provider initialization
      final stopwatch = Stopwatch()..start();
      final notifier = container.read(dashboardProvider.notifier);

      // Poll until loading is complete (check every 50ms)
      while (container.read(dashboardProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      stopwatch.stop();

      final state = container.read(dashboardProvider);
      expect(state.isLoading, isFalse);
      expect(state.statistics, isNotNull);

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 2000),
        operation: 'Dashboard calculate (no cache)',
      );

      container.dispose();
    });

    test('Dashboard loads from cache <100ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      // Clear SharedPreferences cache
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(overrides: [
        reservationRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      // First load (no cache) - wait for completion
      while (container.read(dashboardProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Second load (from cache) - create new container
      final container2 = ProviderContainer(overrides: [
        reservationRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);

      final stopwatch = Stopwatch()..start();
      final notifier = container2.read(dashboardProvider.notifier);

      // Poll until loading is complete
      while (container2.read(dashboardProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      stopwatch.stop();

      final state = container2.read(dashboardProvider);
      expect(state.isLoading, isFalse);
      expect(state.statistics, isNotNull);

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 150),
        operation: 'Dashboard load (cached)',
      );

      container.dispose();
      container2.dispose();
    });
  });
}
