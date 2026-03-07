import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late ReservationLocalDataSource dataSource;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseHelper = DatabaseHelper.forTesting();
    // Clear database before each test
    final db = await databaseHelper.database;
    await db.delete(DatabaseSchema.tableReservations);
    await db.delete(DatabaseSchema.tableRooms);
    await db.delete(DatabaseSchema.tablePlatforms);

    // Insert test rooms and platforms (required for foreign key constraints)
    await db.insert(DatabaseSchema.tableRooms, {
      DatabaseSchema.roomId: 'room-1',
      DatabaseSchema.roomName: 'Test Room 1',
      DatabaseSchema.roomType: 'double',
      DatabaseSchema.roomCreatedAt: DateTime.now().toIso8601String(),
    });
    await db.insert(DatabaseSchema.tableRooms, {
      DatabaseSchema.roomId: 'room-2',
      DatabaseSchema.roomName: 'Test Room 2',
      DatabaseSchema.roomType: 'single',
      DatabaseSchema.roomCreatedAt: DateTime.now().toIso8601String(),
    });
    await db.insert(DatabaseSchema.tablePlatforms, {
      DatabaseSchema.platformId: 'platform-1',
      DatabaseSchema.platformName: 'Platform 1',
      DatabaseSchema.platformColorValue: 0xFFFF0000,
      DatabaseSchema.platformIsDefault: 0,
      DatabaseSchema.platformCreatedAt: DateTime.now().toIso8601String(),
    });
    await db.insert(DatabaseSchema.tablePlatforms, {
      DatabaseSchema.platformId: 'platform-2',
      DatabaseSchema.platformName: 'Platform 2',
      DatabaseSchema.platformColorValue: 0xFF00FF00,
      DatabaseSchema.platformIsDefault: 0,
      DatabaseSchema.platformCreatedAt: DateTime.now().toIso8601String(),
    });

    dataSource = ReservationLocalDataSource(databaseHelper: databaseHelper);
  });

  group('getReservationsFiltered', () {
    test('should return all reservations when filter is empty', () async {
      // Arrange
      final reservations = _createTestReservations(5);
      await dataSource.insertReservationsBatch(reservations);

      // Act
      const filter = ReservationFilter();
      final result = await dataSource.getReservationsFiltered(filter, 100, 0);

      // Assert
      expect(result.length, equals(5));
    });

    test('should filter by platformId with SQL WHERE clause', () async {
      // Arrange
      final reservations = [
        _createReservation(id: '1', platformId: 'platform-1'),
        _createReservation(id: '2', platformId: 'platform-2'),
        _createReservation(id: '3', platformId: 'platform-1'),
      ];
      await dataSource.insertReservationsBatch(reservations);

      // Act
      const filter = ReservationFilter(platformId: 'platform-1');
      final result = await dataSource.getReservationsFiltered(filter, 100, 0);

      // Assert
      expect(result.length, equals(2));
      expect(result.every((r) => r.platformId == 'platform-1'), isTrue);
    });

    test('should filter by roomId with SQL WHERE clause', () async {
      // Arrange
      final reservations = [
        _createReservation(id: '1', roomId: 'room-1'),
        _createReservation(id: '2', roomId: 'room-2'),
        _createReservation(id: '3', roomId: 'room-1'),
      ];
      await dataSource.insertReservationsBatch(reservations);

      // Act
      const filter = ReservationFilter(roomId: 'room-1');
      final result = await dataSource.getReservationsFiltered(filter, 100, 0);

      // Assert
      expect(result.length, equals(2));
      expect(result.every((r) => r.roomId == 'room-1'), isTrue);
    });

    test('should filter by date range with SQL WHERE clause', () async {
      // Arrange
      final reservations = [
        _createReservation(
          id: '1',
          checkIn: DateTime(2026, 3, 1),
          checkOut: DateTime(2026, 3, 5),
        ),
        _createReservation(
          id: '2',
          checkIn: DateTime(2026, 3, 10),
          checkOut: DateTime(2026, 3, 15),
        ),
        _createReservation(
          id: '3',
          checkIn: DateTime(2026, 3, 20),
          checkOut: DateTime(2026, 3, 25),
        ),
      ];
      await dataSource.insertReservationsBatch(reservations);

      // Act
      // Filter for March 5-12 - should match reservation 1 (overlaps) and 2 (overlaps)
      final filter = ReservationFilter(
        startDate: DateTime(2026, 3, 5),
        endDate: DateTime(2026, 3, 12),
      );
      final result = await dataSource.getReservationsFiltered(filter, 100, 0);

      // Assert
      expect(result.length, equals(2));
      expect(result.any((r) => r.id == '1'), isTrue);
      expect(result.any((r) => r.id == '2'), isTrue);
      expect(result.any((r) => r.id == '3'), isFalse);
    });

    test('should filter by paymentStatus with SQL WHERE clause', () async {
      // Arrange
      final reservations = [
        _createReservation(id: '1', paymentStatus: PaymentStatus.received),
        _createReservation(id: '2', paymentStatus: PaymentStatus.pending),
        _createReservation(id: '3', paymentStatus: PaymentStatus.received),
      ];
      await dataSource.insertReservationsBatch(reservations);

      // Act
      const filter = ReservationFilter(paymentStatus: PaymentStatus.received);
      final result = await dataSource.getReservationsFiltered(filter, 100, 0);

      // Assert
      expect(result.length, equals(2));
      expect(result.every((r) => r.paymentStatus == PaymentStatus.received), isTrue);
    });

    test('should combine multiple filters with AND', () async {
      // Arrange
      final reservations = [
        _createReservation(
          id: '1',
          platformId: 'platform-1',
          roomId: 'room-1',
          paymentStatus: PaymentStatus.received,
        ),
        _createReservation(
          id: '2',
          platformId: 'platform-1',
          roomId: 'room-2',
          paymentStatus: PaymentStatus.received,
        ),
        _createReservation(
          id: '3',
          platformId: 'platform-2',
          roomId: 'room-1',
          paymentStatus: PaymentStatus.received,
        ),
      ];
      await dataSource.insertReservationsBatch(reservations);

      // Act
      const filter = ReservationFilter(
        platformId: 'platform-1',
        roomId: 'room-1',
        paymentStatus: PaymentStatus.received,
      );
      final result = await dataSource.getReservationsFiltered(filter, 100, 0);

      // Assert
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
    });

    test('should respect limit and offset', () async {
      // Arrange
      final reservations = _createTestReservations(25, platformId: 'platform-1');
      await dataSource.insertReservationsBatch(reservations);

      // Act
      const filter = ReservationFilter(platformId: 'platform-1');
      final page1 = await dataSource.getReservationsFiltered(filter, 10, 0);
      final page2 = await dataSource.getReservationsFiltered(filter, 10, 10);
      final page3 = await dataSource.getReservationsFiltered(filter, 10, 20);

      // Assert
      expect(page1.length, equals(10));
      expect(page2.length, equals(10));
      expect(page3.length, equals(5));
    });

    test('should return empty list when no matches', () async {
      // Arrange
      final reservations = _createTestReservations(5);
      await dataSource.insertReservationsBatch(reservations);

      // Act
      const filter = ReservationFilter(platformId: 'non-existent');
      final result = await dataSource.getReservationsFiltered(filter, 100, 0);

      // Assert
      expect(result, isEmpty);
    });
  });
}

// Helper functions
ReservationModel _createReservation({
  required String id,
  String platformId = 'platform-1',
  String roomId = 'room-1',
  DateTime? checkIn,
  DateTime? checkOut,
  PaymentStatus paymentStatus = PaymentStatus.pending,
}) {
  final now = DateTime.now();
  return ReservationModel(
    id: id,
    roomId: roomId,
    platformId: platformId,
    guest: const GuestModel(name: 'Test Guest', phone: null),
    checkIn: checkIn ?? now,
    checkOut: checkOut ?? now.add(const Duration(days: 3)),
    paymentStatus: paymentStatus,
    createdAt: now,
    updatedAt: now,
  );
}

List<ReservationModel> _createTestReservations(int count, {String platformId = 'platform-1'}) {
  return List.generate(
    count,
    (i) => _createReservation(
      id: 'reservation-$i',
      platformId: platformId,
    ),
  );
}
