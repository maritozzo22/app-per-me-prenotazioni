import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

void main() {
  // Initialize sqflite FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Query Performance', () {
    late DatabaseHelper databaseHelper;
    late ReservationRepositoryImpl repository;

    Reservation _createTestReservation(int index) {
      return Reservation(
        id: 'perf-test-$index',
        roomId: 'perf-room-1', // Custom test room
        platformId: 'perf-platform-1', // Custom test platform
        guest: const Guest(name: 'Performance Test Guest', phone: '+39 123 456 7890'),
        checkIn: DateTime(2026, 1, 1).add(Duration(days: index)),
        checkOut: DateTime(2026, 1, 5).add(Duration(days: index)),
        amount: 500.0,
        paymentStatus: PaymentStatus.pending,
        notes: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    Future<void> _seedTestData(ReservationRepositoryImpl repository, int count) async {
      final reservations = List.generate(
        count,
        (i) => _createTestReservation(i),
      );

      await repository.insertReservationsBatch(reservations);
    }

    Future<void> _seedRoomsAndPlatforms(DatabaseHelper dbHelper) async {
      final db = await dbHelper.database;
      // Clear existing data
      await db.delete(DatabaseSchema.tableReservations);
      await db.delete(DatabaseSchema.tableRooms);
      await db.delete(DatabaseSchema.tablePlatforms);

      // Insert test room
      await db.insert(DatabaseSchema.tableRooms, {
        'id': 'perf-room-1',
        'name': 'Performance Test Room',
        'type': 'double',
        'created_at': DateTime.now().toIso8601String(),
      });
      // Insert test platform
      await db.insert(DatabaseSchema.tablePlatforms, {
        'id': 'perf-platform-1',
        'name': 'Test Platform',
        'color_value': 0xFFFF0000,
        'is_default': 0,
        'is_system': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    setUp(() async {
      databaseHelper = DatabaseHelper.forTesting();
      final dataSource = ReservationLocalDataSource(databaseHelper: databaseHelper);
      repository = ReservationRepositoryImpl(dataSource: dataSource);

      // Seed rooms and platforms first (required for foreign key constraints)
      await _seedRoomsAndPlatforms(databaseHelper);

      // Seed database with test data
      await _seedTestData(repository, 100);
    });

    tearDown(() async {
      // Clean up
      await databaseHelper.close();
    });

    test('should query reservations by date range in < 100ms', () async {
      final stopwatch = Stopwatch()..start();

      await repository.getReservationsForDateRange(
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
      );

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Date range query should be fast with indexes',
      );
    });

    test('should query all reservations with pagination in < 50ms', () async {
      final stopwatch = Stopwatch()..start();

      await repository.getAllReservations();

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(50),
        reason: 'Paginated query should be very fast',
      );
    });

    test('should insert reservations in batch efficiently', () async {
      final reservations = List.generate(
        50,
        (i) => _createTestReservation(i + 1000), // Use different IDs to avoid conflicts
      );

      final stopwatch = Stopwatch()..start();

      await repository.insertReservationsBatch(reservations);

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Batch insert should be fast',
      );
    });
  });
}
