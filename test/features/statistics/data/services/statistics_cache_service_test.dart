import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_prenotazioni/features/statistics/data/services/statistics_cache_service_impl.dart';
import 'package:app_prenotazioni/features/reservations/domain/services/dashboard_statistics_service.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late StatisticsCacheServiceImpl cacheService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    cacheService = StatisticsCacheServiceImpl(mockPrefs);
  });

  group('StatisticsCacheService', () {
    final testStatistics = DashboardStatistics(
      occupiedRoomsToday: 2,
      totalRooms: 4,
      monthlyIncomeReceived: 1500.0,
      monthlyIncomePending: 500.0,
      upcomingCheckIns: [
        Reservation(
          id: 'test-1',
          roomId: 'room-1',
          platformId: 'airbnb',
          guest: const Guest(name: 'Test Guest'),
          checkIn: DateTime.now(),
          checkOut: DateTime.now().add(const Duration(days: 2)),
          amount: 100.0,
          paymentStatus: PaymentStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      upcomingCheckOuts: [],
    );

    group('getCachedStatistics', () {
      test('returns null if no cache exists', () async {
        // Arrange
        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn(null);

        // Act
        final result = await cacheService.getCachedStatistics();

        // Assert
        expect(result, isNull);
        verify(() => mockPrefs.getString('cached_statistics_timestamp'))
            .called(1);
      });

      test('returns cached statistics if within 24h TTL', () async {
        // Arrange
        final now = DateTime.now();
        final timestamp = now.toIso8601String();
        final statisticsJson = '''
{
  "occupiedRoomsToday": 2,
  "totalRooms": 4,
  "monthlyIncomeReceived": 1500.0,
  "monthlyIncomePending": 500.0,
  "upcomingCheckIns": [
    {
      "id": "test-1",
      "roomId": "room-1",
      "platformId": "airbnb",
      "guest": {"name": "Test Guest", "phone": null},
      "checkIn": "${now.toIso8601String()}",
      "checkOut": "${now.add(const Duration(days: 2)).toIso8601String()}",
      "amount": 100.0,
      "paymentStatus": "pending",
      "notes": null,
      "createdAt": "${now.toIso8601String()}",
      "updatedAt": "${now.toIso8601String()}"
    }
  ],
  "upcomingCheckOuts": []
}
''';

        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn(timestamp);
        when(() => mockPrefs.getString('cached_statistics'))
            .thenReturn(statisticsJson);

        // Act
        final result = await cacheService.getCachedStatistics();

        // Assert
        expect(result, isNotNull);
        expect(result!.occupiedRoomsToday, equals(2));
        expect(result.totalRooms, equals(4));
        expect(result.monthlyIncomeReceived, equals(1500.0));
        expect(result.monthlyIncomePending, equals(500.0));
        expect(result.upcomingCheckIns.length, equals(1));
        expect(result.upcomingCheckOuts.length, equals(0));
      });

      test('returns null if cache expired (>24h)', () async {
        // Arrange
        final oldTimestamp =
            DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();

        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn(oldTimestamp);

        // Act
        final result = await cacheService.getCachedStatistics();

        // Assert
        expect(result, isNull);
      });

      test('returns null and clears cache if JSON is invalid', () async {
        // Arrange
        final now = DateTime.now();
        final timestamp = now.toIso8601String();
        final invalidJson = '{ invalid json }';

        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn(timestamp);
        when(() => mockPrefs.getString('cached_statistics'))
            .thenReturn(invalidJson);
        when(() => mockPrefs.remove('cached_statistics'))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.remove('cached_statistics_timestamp'))
            .thenAnswer((_) async => true);

        // Act
        final result = await cacheService.getCachedStatistics();

        // Assert
        expect(result, isNull);
        verify(() => mockPrefs.remove('cached_statistics')).called(1);
        verify(() => mockPrefs.remove('cached_statistics_timestamp'))
            .called(1);
      });
    });

    group('setCachedStatistics', () {
      test('stores statistics with timestamp', () async {
        // Arrange
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await cacheService.setCachedStatistics(testStatistics);

        // Assert
        verify(() => mockPrefs.setString('cached_statistics', any()))
            .called(1);
        verify(() => mockPrefs.setString('cached_statistics_timestamp', any()))
            .called(1);
      });
    });

    group('invalidateCache', () {
      test('clears stored statistics', () async {
        // Arrange
        when(() => mockPrefs.remove('cached_statistics'))
            .thenAnswer((_) async => true);
        when(() => mockPrefs.remove('cached_statistics_timestamp'))
            .thenAnswer((_) async => true);

        // Act
        await cacheService.invalidateCache();

        // Assert
        verify(() => mockPrefs.remove('cached_statistics')).called(1);
        verify(() => mockPrefs.remove('cached_statistics_timestamp'))
            .called(1);
      });
    });

    group('isCacheValid', () {
      test('returns false if no timestamp exists', () async {
        // Arrange
        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn(null);

        // Act
        final result = await cacheService.isCacheValid();

        // Assert
        expect(result, isFalse);
      });

      test('returns true if cache is within 24h', () async {
        // Arrange
        final recentTimestamp =
            DateTime.now().subtract(const Duration(hours: 12)).toIso8601String();

        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn(recentTimestamp);

        // Act
        final result = await cacheService.isCacheValid();

        // Assert
        expect(result, isTrue);
      });

      test('returns false if cache is older than 24h', () async {
        // Arrange
        final oldTimestamp =
            DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();

        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn(oldTimestamp);

        // Act
        final result = await cacheService.isCacheValid();

        // Assert
        expect(result, isFalse);
      });

      test('returns false if timestamp is invalid', () async {
        // Arrange
        when(() => mockPrefs.getString('cached_statistics_timestamp'))
            .thenReturn('invalid-timestamp');

        // Act
        final result = await cacheService.isCacheValid();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
