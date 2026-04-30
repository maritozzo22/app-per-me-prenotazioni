import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/core/database/test_data_generator.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for setting up performance tests.
class PerformanceTestHelper {
  /// Sets up a repository with the specified number of test reservations.
  ///
  /// This creates a fresh test database and populates it with synthetic data.
  /// Use this for performance tests that need realistic data volumes.
  static Future<ReservationRepository> setupRepositoryWithReservations(
    int count,
  ) async {
    final dbHelper = DatabaseHelper.forTesting();
    final db = await dbHelper.database;

    // Clear existing data
    await db.delete(DatabaseSchema.tableReservations);
    await db.delete(DatabaseSchema.tableRooms);
    await db.delete(DatabaseSchema.tablePlatforms);

    // Insert default rooms
    for (final room in Room.defaultRooms) {
      await db.insert(DatabaseSchema.tableRooms, {
        DatabaseSchema.roomId: room.id,
        DatabaseSchema.roomName: room.name,
        DatabaseSchema.roomType: room.type.name,
        DatabaseSchema.roomCreatedAt: room.createdAt.toIso8601String(),
      });
    }

    // Insert default platforms
    for (final platform in BookingPlatform.defaultPlatforms) {
      await db.insert(DatabaseSchema.tablePlatforms, {
        DatabaseSchema.platformId: platform.id,
        DatabaseSchema.platformName: platform.name,
        DatabaseSchema.platformColorValue: platform.color.value,
        DatabaseSchema.platformIsDefault: platform.isDefault ? 1 : 0,
        DatabaseSchema.platformIsSystem: platform.isSystem ? 1 : 0,
        DatabaseSchema.platformCreatedAt: platform.createdAt.toIso8601String(),
      });
    }

    final dataSource = ReservationLocalDataSource(databaseHelper: dbHelper);
    final repository = ReservationRepositoryImpl(dataSource: dataSource);

    // Generate and insert test data
    final reservations = TestDataGenerator.generateTestReservations(count);
    await repository.insertReservationsBatch(reservations);

    return repository;
  }

  /// Asserts that an operation completes within the specified time limit.
  ///
  /// [actual] - The actual duration of the operation.
  /// [max] - The maximum allowed duration.
  /// [operation] - Human-readable name of the operation (for error messages).
  ///
  /// Throws a descriptive error if the operation took too long.
  static void assertPerformance({
    required Duration actual,
    required Duration max,
    String? operation,
  }) {
    final operationName = operation ?? 'Operation';
    print('$operationName took ${actual.inMilliseconds}ms (max: ${max.inMilliseconds}ms)');

    expect(
      actual,
      lessThan(max),
      reason: '$operationName took ${actual.inMilliseconds}ms, expected < ${max.inMilliseconds}ms',
    );
  }
}
