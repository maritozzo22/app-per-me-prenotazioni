import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // CRITICAL: Initialize sqflite FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseSchema Performance Indexes', () {
    late DatabaseHelper databaseHelper;
    late Database db;

    setUp(() async {
      databaseHelper = DatabaseHelper.forTesting();
      db = await databaseHelper.database as Database;
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should create index on reservations check_in', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_reservations_check_in'",
      );

      expect(indexes, isNotEmpty, reason: 'Index idx_reservations_check_in should exist');
    });

    test('should create index on reservations check_out', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_reservations_check_out'",
      );

      expect(indexes, isNotEmpty, reason: 'Index idx_reservations_check_out should exist');
    });

    test('should create index on reservations platform_id', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_reservations_platform_id'",
      );

      expect(indexes, isNotEmpty, reason: 'Index idx_reservations_platform_id should exist');
    });

    test('should create index on reservations room_id', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_reservations_room_id'",
      );

      expect(indexes, isNotEmpty, reason: 'Index idx_reservations_room_id should exist');
    });

    test('should create composite index on reservations (check_in, check_out)', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_reservations_date_range'",
      );

      expect(indexes, isNotEmpty, reason: 'Composite index idx_reservations_date_range should exist');
    });

    test('should use index for date range queries', () async {
      // Insert test data
      await db.insert(
        DatabaseSchema.tableReservations,
        {
          DatabaseSchema.reservationId: 'test-date-range-1',
          DatabaseSchema.reservationRoomId: 'room-1',
          DatabaseSchema.reservationPlatformId: 'booking',
          DatabaseSchema.reservationGuestName: 'Test Guest',
          DatabaseSchema.reservationCheckIn: '2026-01-01T00:00:00.000Z',
          DatabaseSchema.reservationCheckOut: '2026-01-05T00:00:00.000Z',
          DatabaseSchema.reservationCreatedAt: DateTime.now().toIso8601String(),
          DatabaseSchema.reservationUpdatedAt: DateTime.now().toIso8601String(),
        },
      );

      // Execute EXPLAIN QUERY PLAN
      final explainResult = await db.rawQuery(
        "EXPLAIN QUERY PLAN SELECT * FROM ${DatabaseSchema.tableReservations} "
        "WHERE ${DatabaseSchema.reservationCheckIn} >= '2026-01-01' "
        "AND ${DatabaseSchema.reservationCheckOut} <= '2026-12-31'",
      );

      // Verify index is used (should mention "USING INDEX" or "INDEX")
      final planText = explainResult.toString();
      expect(
        planText.toUpperCase().contains('INDEX'),
        isTrue,
        reason: 'Query should use index. Plan: $planText',
      );
    });

    test('should use index for platform filter queries', () async {
      // Execute EXPLAIN QUERY PLAN
      final explainResult = await db.rawQuery(
        "EXPLAIN QUERY PLAN SELECT * FROM ${DatabaseSchema.tableReservations} "
        "WHERE ${DatabaseSchema.reservationPlatformId} = 'booking'",
      );

      final planText = explainResult.toString();
      expect(
        planText.toUpperCase().contains('INDEX'),
        isTrue,
        reason: 'Platform filter should use index. Plan: $planText',
      );
    });

    test('should use index for room filter queries', () async {
      // Execute EXPLAIN QUERY PLAN
      final explainResult = await db.rawQuery(
        "EXPLAIN QUERY PLAN SELECT * FROM ${DatabaseSchema.tableReservations} "
        "WHERE ${DatabaseSchema.reservationRoomId} = 'room-1'",
      );

      final planText = explainResult.toString();
      expect(
        planText.toUpperCase().contains('INDEX'),
        isTrue,
        reason: 'Room filter should use index. Plan: $planText',
      );
    });
  });
}
