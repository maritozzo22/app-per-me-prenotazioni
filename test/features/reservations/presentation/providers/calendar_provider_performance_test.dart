import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/calendar_provider.dart';
import 'package:app_prenotazioni/features/reservations/presentation/providers/reservation_provider.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../helpers/performance_test_helper.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('CalendarProvider Performance Tests', () {
    test('Calendar loads 3 months with 1000 reservations <1000ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      final container = ProviderContainer(overrides: [
        reservationRepositoryProvider.overrideWithValue(repository),
      ]);

      // Start measuring from provider initialization
      final stopwatch = Stopwatch()..start();
      final notifier = container.read(calendarProvider.notifier);

      // Poll until loading is complete (check every 50ms)
      while (container.read(calendarProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      stopwatch.stop();

      final state = container.read(calendarProvider);
      expect(state.isLoading, isFalse);
      expect(state.loadedMonths.length, greaterThanOrEqualTo(3)); // Current month ±1

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 1000),
        operation: 'Calendar initial load (3 months)',
      );

      container.dispose();
    });

    test('Calendar lazy-loads new month <500ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      final container = ProviderContainer(overrides: [
        reservationRepositoryProvider.overrideWithValue(repository),
      ]);

      // Wait for initial load to complete
      while (container.read(calendarProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Change to a month far in the future (not yet loaded)
      final newMonth = DateTime.now().add(const Duration(days: 365)); // 1 year ahead
      final stopwatch = Stopwatch()..start();
      container.read(calendarProvider.notifier).changeMonth(newMonth);

      // Poll until loading is complete
      while (container.read(calendarProvider).isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      stopwatch.stop();

      final state = container.read(calendarProvider);
      expect(state.isLoading, isFalse);

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 500),
        operation: 'Calendar lazy load (1 month)',
      );

      container.dispose();
    });
  });
}
