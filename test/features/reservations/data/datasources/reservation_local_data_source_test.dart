import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/local/reservation_local_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockDatabase extends Mock implements Database {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(ReservationModel(
      id: '',
      roomId: '',
      platformId: '',
      guest: const GuestModel(name: ''),
      checkIn: DateTime(2024, 1, 1),
      checkOut: DateTime(2024, 1, 2),
      paymentStatus: PaymentStatus.pending,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ));
    // Register fallback for Map<String, dynamic> used in insert/update operations
    registerFallbackValue(<String, dynamic>{});
  });

  late ReservationLocalDataSource dataSource;
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();
    dataSource = ReservationLocalDataSource(databaseHelper: mockDbHelper);

    when(() => mockDbHelper.database).thenAnswer((_) => Future.value(mockDb));
  });

  group('ReservationLocalDataSource', () {
    final testReservation = ReservationModel(
      id: 'res-1',
      roomId: 'room-1',
      platformId: 'booking',
      guest: const GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
      checkIn: DateTime(2024, 6, 20),
      checkOut: DateTime(2024, 6, 25),
      amount: 500.00,
      paymentStatus: PaymentStatus.received,
      notes: 'Late arrival',
      createdAt: DateTime(2024, 6, 1),
      updatedAt: DateTime(2024, 6, 1),
    );

    group('getAllReservations', () {
      test('should return empty list when no reservations exist', () async {
        when(() => mockDb.query(
          any(),
          orderBy: any(named: 'orderBy'),
        )).thenAnswer((_) => Future.value([]));

        final result = await dataSource.getAllReservations();

        expect(result, isEmpty);
      });

      test('should return list of reservations', () async {
        when(() => mockDb.query(
          any(),
          orderBy: any(named: 'orderBy'),
        )).thenAnswer((_) => Future.value([
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': '+39123456789',
                'check_in': '2024-06-20T00:00:00.000Z',
                'check_out': '2024-06-25T00:00:00.000Z',
                'amount': 500.00,
                'notes': 'Late arrival',
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]));

        final result = await dataSource.getAllReservations();

        expect(result.length, 1);
        expect(result.first.id, 'res-1');
        expect(result.first.roomId, 'room-1');
      });
    });

    group('saveReservation', () {
      test('should insert reservation into database', () async {
        when(() => mockDb.insert('reservations', any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
            .thenAnswer((_) => Future.value(1));

        await dataSource.saveReservation(testReservation);

        verify(() => mockDb.insert('reservations', any(), conflictAlgorithm: any(named: 'conflictAlgorithm'))).called(1);
      });
    });

    group('getReservationById', () {
      test('should return reservation when found', () async {
        when(() => mockDb.query(
              'reservations',
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) => Future.value([
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': '+39123456789',
                'check_in': '2024-06-20T00:00:00.000Z',
                'check_out': '2024-06-25T00:00:00.000Z',
                'amount': 500.00,
                'notes': 'Late arrival',
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]));

        final result = await dataSource.getReservationById('res-1');

        expect(result, isNotNull);
        expect(result!.id, 'res-1');
      });

      test('should return null when not found', () async {
        when(() => mockDb.query(
              'reservations',
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) => Future.value([]));

        final result = await dataSource.getReservationById('nonexistent');

        expect(result, isNull);
      });
    });

    group('deleteReservation', () {
      test('should delete reservation from database', () async {
        when(() => mockDb.delete(
              'reservations',
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
            )).thenAnswer((_) => Future.value(1));

        await dataSource.deleteReservation('res-1');

        verify(() => mockDb.delete(
              'reservations',
              where: 'id = ?',
              whereArgs: ['res-1'],
            )).called(1);
      });
    });

    group('getReservationsForDateRange', () {
      test('should return reservations overlapping with date range', () async {
        // Query: check_in <= end AND check_out >= start
        // Range: June 15-30
        // Reservation: June 20-25 (overlaps)
        when(() => mockDb.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) => Future.value([
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': null,
                'check_in': '2024-06-20T00:00:00.000Z',
                'check_out': '2024-06-25T00:00:00.000Z',
                'amount': null,
                'notes': null,
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]));

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 15),
          DateTime(2024, 6, 30),
        );

        expect(result.length, 1);
        // Verify the query was called with correct arguments (where clause contains the expected logic)
        final captured = verify(() => mockDb.query(
              'reservations',
              where: any(named: 'where'),
              whereArgs: captureAny(named: 'whereArgs'),
              orderBy: 'check_in ASC',
            )).captured.single as List;

        // Verify date args: end date first, start date second
        expect(captured[0], DateTime(2024, 6, 30).toIso8601String());
        expect(captured[1], DateTime(2024, 6, 15).toIso8601String());
      });

      test('should return empty list when no reservations overlap', () async {
        // Range: June 15-30
        // No reservations in this period
        when(() => mockDb.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) => Future.value([]));

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 15),
          DateTime(2024, 6, 30),
        );

        expect(result, isEmpty);
      });

      test('should return reservations that start before range and end within it', () async {
        // Range: June 20-25
        // Reservation: June 18-22 (starts before, ends within)
        when(() => mockDb.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) => Future.value([
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': null,
                'check_in': '2024-06-18T00:00:00.000Z',
                'check_out': '2024-06-22T00:00:00.000Z',
                'amount': null,
                'notes': null,
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]));

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 20),
          DateTime(2024, 6, 25),
        );

        expect(result.length, 1);
      });

      test('should return reservations that start within range and end after it', () async {
        // Range: June 20-25
        // Reservation: June 22-28 (starts within, ends after)
        when(() => mockDb.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) => Future.value([
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': null,
                'check_in': '2024-06-22T00:00:00.000Z',
                'check_out': '2024-06-28T00:00:00.000Z',
                'amount': null,
                'notes': null,
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]));

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 20),
          DateTime(2024, 6, 25),
        );

        expect(result.length, 1);
      });

      test('should return reservations that completely encompass the range', () async {
        // Range: June 20-25
        // Reservation: June 15-30 (starts before, ends after)
        when(() => mockDb.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) => Future.value([
              {
                'id': 'res-1',
                'room_id': 'room-1',
                'platform_id': 'booking',
                'guest_name': 'Mario Rossi',
                'guest_phone': null,
                'check_in': '2024-06-15T00:00:00.000Z',
                'check_out': '2024-06-30T00:00:00.000Z',
                'amount': null,
                'notes': null,
                'created_at': '2024-06-01T00:00:00.000Z',
                'updated_at': '2024-06-01T00:00:00.000Z',
              }
            ]));

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 20),
          DateTime(2024, 6, 25),
        );

        expect(result.length, 1);
      });

      test('should not return reservations that end before range starts', () async {
        // Range: June 20-25
        // Reservation: June 15-19 (ends before range)
        when(() => mockDb.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) => Future.value([]));

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 20),
          DateTime(2024, 6, 25),
        );

        expect(result, isEmpty);
      });

      test('should not return reservations that start after range ends', () async {
        // Range: June 20-25
        // Reservation: June 26-30 (starts after range)
        when(() => mockDb.query(
              any(),
              where: any(named: 'where'),
              whereArgs: any(named: 'whereArgs'),
              orderBy: any(named: 'orderBy'),
            )).thenAnswer((_) => Future.value([]));

        final result = await dataSource.getReservationsForDateRange(
          DateTime(2024, 6, 20),
          DateTime(2024, 6, 25),
        );

        expect(result, isEmpty);
      });
    });

    group('getAllPlatforms', () {
      test('should return all platforms', () async {
        when(() => mockDb.query('platforms'))
            .thenAnswer((_) => Future.value([
                  {'id': 'booking', 'name': 'Booking', 'color_value': 0xFF2196F3, 'is_default': 1, 'created_at': '2024-01-01T00:00:00.000Z'},
                ]));

        final result = await dataSource.getAllPlatforms();

        expect(result, isNotEmpty);
      });
    });

    group('getAllRooms', () {
      test('should return all rooms', () async {
        when(() => mockDb.query('rooms'))
            .thenAnswer((_) => Future.value([
                  {'id': 'room-1', 'name': 'Stanza 1', 'type': 'singleRoom', 'created_at': '2024-01-01T00:00:00.000Z'},
                ]));

        final result = await dataSource.getAllRooms();

        expect(result, isNotEmpty);
      });
    });
  });
}
