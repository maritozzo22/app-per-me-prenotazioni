import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';
import '../../../../helpers/performance_test_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ReservationRepository Performance Tests', () {
    test('Pagination: Load first page (20 items) with 1000 reservations <500ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      final stopwatch = Stopwatch()..start();
      final result = await repository.getReservationsPaginated(page: 1, pageSize: 20);
      stopwatch.stop();

      expect(result.items.length, equals(20));
      expect(result.totalCount, equals(1000));

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 500),
        operation: 'Load first page',
      );
    });

    test('Pagination: Load page 10 (offset 180) with 1000 reservations <500ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      final stopwatch = Stopwatch()..start();
      final result = await repository.getReservationsPaginated(page: 10, pageSize: 20);
      stopwatch.stop();

      expect(result.items.length, equals(20));
      expect(result.currentPage, equals(10));

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 500),
        operation: 'Load page 10',
      );
    });

    test('Filter: Filter by platform with 1000 reservations <500ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      final filter = ReservationFilter(platformId: 'booking');

      final stopwatch = Stopwatch()..start();
      final result = await repository.getReservationsFiltered(filter: filter, page: 1, pageSize: 20);
      stopwatch.stop();

      // Verify all results match filter
      expect(result.items.every((r) => r.platformId == 'booking'), isTrue);

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 500),
        operation: 'Filter by platform',
      );
    });

    test('Filter: Filter by date range with 1000 reservations <1000ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      final now = DateTime.now();
      final filter = ReservationFilter(
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );

      final stopwatch = Stopwatch()..start();
      final result = await repository.getReservationsFiltered(filter: filter, page: 1, pageSize: 20);
      stopwatch.stop();

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 1000),
        operation: 'Filter by date range',
      );
    });

    test('Filter: Combined filters (platform + room + dates) <1000ms', () async {
      final repository = await PerformanceTestHelper.setupRepositoryWithReservations(1000);

      final now = DateTime.now();
      final filter = ReservationFilter(
        platformId: 'booking',
        roomId: 'room-1',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
      );

      final stopwatch = Stopwatch()..start();
      final result = await repository.getReservationsFiltered(filter: filter, page: 1, pageSize: 20);
      stopwatch.stop();

      PerformanceTestHelper.assertPerformance(
        actual: stopwatch.elapsed,
        max: const Duration(milliseconds: 1000),
        operation: 'Combined filters',
      );
    });
  });
}
