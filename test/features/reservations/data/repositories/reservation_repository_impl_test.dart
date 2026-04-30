import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_prenotazioni/features/reservations/data/datasources/reservation_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/repositories/reservation_repository_impl.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/paginated_result.dart';

class MockReservationDataSource extends Mock implements ReservationDataSource {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      ReservationModel(
        id: '',
        roomId: '',
        platformId: '',
        guest: const GuestModel(name: ''),
        checkIn: DateTime.now(),
        checkOut: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  late ReservationRepositoryImpl repository;
  late MockReservationDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockReservationDataSource();
    repository = ReservationRepositoryImpl(dataSource: mockDataSource);
  });

  group('ReservationRepositoryImpl', () {
    final testReservationModel = ReservationModel(
      id: 'res-1',
      roomId: 'room-1',
      platformId: 'booking',
      guest: const GuestModel(name: 'Mario Rossi', phone: '+39123456789'),
      checkIn: DateTime(2024, 6, 20),
      checkOut: DateTime(2024, 6, 25),
      amount: 500.00,
      notes: 'Late arrival',
      createdAt: DateTime(2024, 6, 1),
      updatedAt: DateTime(2024, 6, 1),
    );

    final testRoomModel = RoomModel(
      id: 'room-1',
      name: 'Stanza 1',
      type: 'singleRoom',
      createdAt: DateTime(2024, 1, 1),
    );

    final testPlatformModel = PlatformModel(
      id: 'booking',
      name: 'Booking',
      colorValue: 0xFF2196F3,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    );

    group('getAllReservations', () {
      test('should return list of Reservation entities', () async {
        when(() => mockDataSource.getAllReservations())
            .thenAnswer((_) async => [testReservationModel]);

        final result = await repository.getAllReservations();

        expect(result.length, 1);
        expect(result.first, isA<Reservation>());
        expect(result.first.id, 'res-1');
        expect(result.first.roomId, 'room-1');
        verify(() => mockDataSource.getAllReservations()).called(1);
      });

      test('should return empty list when no reservations', () async {
        when(() => mockDataSource.getAllReservations())
            .thenAnswer((_) async => []);

        final result = await repository.getAllReservations();

        expect(result, isEmpty);
      });
    });

    group('getReservationById', () {
      test('should return Reservation entity when found', () async {
        when(() => mockDataSource.getReservationById('res-1'))
            .thenAnswer((_) async => testReservationModel);

        final result = await repository.getReservationById('res-1');

        expect(result, isNotNull);
        expect(result!.id, 'res-1');
      });

      test('should return null when not found', () async {
        when(() => mockDataSource.getReservationById('nonexistent'))
            .thenAnswer((_) async => null);

        final result = await repository.getReservationById('nonexistent');

        expect(result, isNull);
      });
    });

    group('saveReservation', () {
      test('should call dataSource with correct model', () async {
        final entity = testReservationModel.toEntity();

        when(() => mockDataSource.saveReservation(any()))
            .thenAnswer((_) async {});

        await repository.saveReservation(entity);

        verify(() => mockDataSource.saveReservation(any())).called(1);
      });
    });

    group('deleteReservation', () {
      test('should call dataSource with correct id', () async {
        when(() => mockDataSource.deleteReservation('res-1'))
            .thenAnswer((_) async {});

        await repository.deleteReservation('res-1');

        verify(() => mockDataSource.deleteReservation('res-1')).called(1);
      });
    });

    group('getReservationsForDateRange', () {
      test('should return reservations overlapping with date range', () async {
        when(() => mockDataSource.getReservationsForDateRange(
              any(),
              any(),
            )).thenAnswer((_) async => [testReservationModel]);

        final result = await repository.getReservationsForDateRange(
          DateTime(2024, 6, 15),
          DateTime(2024, 6, 30),
        );

        expect(result.length, 1);
        expect(result.first, isA<Reservation>());
      });
    });

    group('getAllRooms', () {
      test('should return list of Room entities', () async {
        when(() => mockDataSource.getAllRooms())
            .thenAnswer((_) async => [testRoomModel]);

        final result = await repository.getAllRooms();

        expect(result.length, 1);
        expect(result.first, isA<Room>());
        expect(result.first.id, 'room-1');
      });
    });

    group('getAllPlatforms', () {
      test('should return list of BookingPlatform entities', () async {
        when(() => mockDataSource.getAllPlatforms())
            .thenAnswer((_) async => [testPlatformModel]);

        final result = await repository.getAllPlatforms();

        expect(result.length, 1);
        expect(result.first, isA<BookingPlatform>());
        expect(result.first.id, 'booking');
      });
    });

    group('getReservationsPaginated', () {
      test('should return PaginatedResult with correct page and metadata', () async {
        when(() => mockDataSource.getReservationsPaginated(any(), any()))
            .thenAnswer((_) async => [testReservationModel]);
        when(() => mockDataSource.getTotalReservationsCount())
            .thenAnswer((_) async => 100);

        final result = await repository.getReservationsPaginated(
          page: 1,
          pageSize: 20,
        );

        expect(result, isA<PaginatedResult<Reservation>>());
        expect(result.items.length, 1);
        expect(result.totalCount, 100);
        expect(result.currentPage, 1);
        expect(result.pageSize, 20);
        expect(result.hasMore, isTrue);
      });

      test('should calculate correct offset from page and pageSize', () async {
        when(() => mockDataSource.getReservationsPaginated(any(), any()))
            .thenAnswer((_) async => []);
        when(() => mockDataSource.getTotalReservationsCount())
            .thenAnswer((_) async => 0);

        // Page 3, pageSize 20 -> offset = (3-1) * 20 = 40
        await repository.getReservationsPaginated(page: 3, pageSize: 20);

        final captured = verify(() =>
          mockDataSource.getReservationsPaginated(captureAny(), captureAny())
        ).captured;

        expect(captured[0], 20); // limit (pageSize)
        expect(captured[1], 40); // offset
      });

      test('should return PaginatedResult with hasMore = false on last page', () async {
        when(() => mockDataSource.getReservationsPaginated(any(), any()))
            .thenAnswer((_) async => [testReservationModel]);
        when(() => mockDataSource.getTotalReservationsCount())
            .thenAnswer((_) async => 5);

        // Total 5 items, page 1, pageSize 5 -> hasMore = false
        final result = await repository.getReservationsPaginated(
          page: 1,
          pageSize: 5,
        );

        expect(result.hasMore, isFalse);
      });

      test('should use default values when page and pageSize not specified', () async {
        when(() => mockDataSource.getReservationsPaginated(any(), any()))
            .thenAnswer((_) async => []);
        when(() => mockDataSource.getTotalReservationsCount())
            .thenAnswer((_) async => 0);

        final result = await repository.getReservationsPaginated();

        expect(result.currentPage, 1);
        expect(result.pageSize, 20);
      });
    });
  });
}
