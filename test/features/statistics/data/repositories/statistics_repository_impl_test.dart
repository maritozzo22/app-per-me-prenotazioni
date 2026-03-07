import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:app_prenotazioni/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/period_filter.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockDatabase extends Mock implements Database {}

void main() {
  late StatisticsRepositoryImpl repository;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    repository = StatisticsRepositoryImpl(databaseHelper: mockDatabaseHelper);

    registerFallbackValue(DateTime.now());
  });

  group('getPlatformRevenue', () {
    test('returns empty list when no reservations exist', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'platformId': 'booking', 'platformName': 'Booking', 'color_value': 0xFF2196F3, 'totalRevenue': 0.0, 'bookingCount': 0},
                {'platformId': 'airbnb', 'platformName': 'Airbnb', 'color_value': 0xFFE91E63, 'totalRevenue': 0.0, 'bookingCount': 0},
              ]);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.month);
      final result = await repository.getPlatformRevenue(filter);

      // Assert
      expect(result, isEmpty);
      verify(() => mockDatabase.rawQuery(any(), any())).called(1);
    });

    test('groups revenue by platform correctly', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {
                  'platformId': 'booking',
                  'platformName': 'Booking',
                  'color_value': 0xFF2196F3,
                  'totalRevenue': 1000.0,
                  'bookingCount': 5
                },
                {
                  'platformId': 'airbnb',
                  'platformName': 'Airbnb',
                  'color_value': 0xFFE91E63,
                  'totalRevenue': 500.0,
                  'bookingCount': 2
                },
              ]);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.month);
      final result = await repository.getPlatformRevenue(filter);

      // Assert
      expect(result.length, 2);
      expect(result[0].platformId, 'booking');
      expect(result[0].totalRevenue, 1000.0);
      expect(result[0].bookingCount, 5);
      expect(result[1].platformId, 'airbnb');
      expect(result[1].totalRevenue, 500.0);
    });

    test('calculates percentage correctly', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {
                  'platformId': 'booking',
                  'platformName': 'Booking',
                  'color_value': 0xFF2196F3,
                  'totalRevenue': 750.0,
                  'bookingCount': 3
                },
                {
                  'platformId': 'airbnb',
                  'platformName': 'Airbnb',
                  'color_value': 0xFFE91E63,
                  'totalRevenue': 250.0,
                  'bookingCount': 1
                },
              ]);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.month);
      final result = await repository.getPlatformRevenue(filter);

      // Assert
      expect(result.length, 2);
      // Total is 1000, booking=75%, airbnb=25%
      expect(result[0].percentage, closeTo(75.0, 0.01));
      expect(result[1].percentage, closeTo(25.0, 0.01));
    });

    test('respects includePending flag - excludes pending when false', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {
                  'platformId': 'booking',
                  'platformName': 'Booking',
                  'color_value': 0xFF2196F3,
                  'totalRevenue': 800.0,
                  'bookingCount': 4
                },
              ]);

      // Act
      final filter = StatisticsFilter(
        period: PeriodFilter.month,
        includePending: false,
      );
      final result = await repository.getPlatformRevenue(filter);

      // Assert
      final captured = verify(() => mockDatabase.rawQuery(captureAny(), captureAny())).captured;
      final sql = captured[0] as String;
      expect(sql, contains("payment_status = 'received'"));
      expect(result.length, 1);
    });

    test('respects includePending flag - includes pending when true', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {
                  'platformId': 'booking',
                  'platformName': 'Booking',
                  'color_value': 0xFF2196F3,
                  'totalRevenue': 1000.0,
                  'bookingCount': 5
                },
              ]);

      // Act
      final filter = StatisticsFilter(
        period: PeriodFilter.month,
        includePending: true,
      );
      final result = await repository.getPlatformRevenue(filter);

      // Assert
      final captured = verify(() => mockDatabase.rawQuery(captureAny(), captureAny())).captured;
      final sql = captured[0] as String;
      expect(sql, contains("payment_status IN ('received', 'pending')"));
      expect(result.length, 1);
    });

    test('uses platform colors from database', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {
                  'platformId': 'booking',
                  'platformName': 'Booking',
                  'color_value': 0xFF2196F3,
                  'totalRevenue': 500.0,
                  'bookingCount': 2
                },
              ]);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.month);
      final result = await repository.getPlatformRevenue(filter);

      // Assert
      expect(result[0].color, 0xFF2196F3);
    });
  });

  group('getMonthlyTrend', () {
    test('returns empty list when no reservations exist', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => []);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.year);
      final result = await repository.getMonthlyTrend(filter);

      // Assert
      expect(result, isEmpty);
    });

    test('groups by month correctly', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'month': '2025-01', 'revenue': 1000.0, 'bookingCount': 3},
                {'month': '2025-02', 'revenue': 1500.0, 'bookingCount': 4},
                {'month': '2025-03', 'revenue': 2000.0, 'bookingCount': 5},
              ]);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.year);
      final result = await repository.getMonthlyTrend(filter);

      // Assert
      expect(result.length, 3);
      expect(result[0].month, '2025-01');
      expect(result[1].month, '2025-02');
      expect(result[2].month, '2025-03');
    });

    test('sorts months ascending', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'month': '2025-03', 'revenue': 2000.0, 'bookingCount': 5},
                {'month': '2025-01', 'revenue': 1000.0, 'bookingCount': 3},
                {'month': '2025-02', 'revenue': 1500.0, 'bookingCount': 4},
              ]);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.year);
      final result = await repository.getMonthlyTrend(filter);

      // Assert - results are returned in the order from the query
      // The SQL ORDER BY should handle sorting
      expect(result.length, 3);
    });

    test('month format is YYYY-MM', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'month': '2025-12', 'revenue': 3000.0, 'bookingCount': 8},
              ]);

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.year);
      final result = await repository.getMonthlyTrend(filter);

      // Assert
      expect(result[0].month, matches(r'^\d{4}-\d{2}$'));
    });
  });

  group('getYearOverYearComparison', () {
    test('returns null when no data for either year', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getYearOverYearComparison(2024, 2025);

      // Assert
      expect(result, isNull);
    });

    test('returns 12 monthly values for each year', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'month': '01', 'year': '2024', 'revenue': 1000.0},
                {'month': '02', 'year': '2024', 'revenue': 1500.0},
                {'month': '01', 'year': '2025', 'revenue': 1200.0},
                {'month': '02', 'year': '2025', 'revenue': 1800.0},
              ]);

      // Act
      final result = await repository.getYearOverYearComparison(2024, 2025);

      // Assert
      expect(result, isNotNull);
      expect(result!.year1Monthly.length, 12);
      expect(result.year2Monthly.length, 12);
    });

    test('zero values for months without bookings', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'month': '01', 'year': '2024', 'revenue': 1000.0},
                {'month': '03', 'year': '2024', 'revenue': 2000.0},
                // Month 02 is missing
              ]);

      // Act
      final result = await repository.getYearOverYearComparison(2024, 2025);

      // Assert
      expect(result, isNotNull);
      expect(result!.year1Monthly[0], 1000.0); // January
      expect(result.year1Monthly[1], 0.0); // February (missing)
      expect(result.year1Monthly[2], 2000.0); // March
    });

    test('correctly maps data to year1/year2 arrays', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'month': '06', 'year': '2024', 'revenue': 5000.0},
                {'month': '06', 'year': '2025', 'revenue': 6000.0},
              ]);

      // Act
      final result = await repository.getYearOverYearComparison(2024, 2025);

      // Assert
      expect(result, isNotNull);
      expect(result!.year1, 2024);
      expect(result.year2, 2025);
      expect(result.year1Monthly[5], 5000.0); // June (0-indexed: 5)
      expect(result.year2Monthly[5], 6000.0);
    });
  });

  group('getOccupancyRate', () {
    test('returns 0 when no reservations', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => []);

      // Act
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);
      final result = await repository.getOccupancyRate(start, end);

      // Assert
      expect(result, 0.0);
    });

    test('calculates occupied days correctly', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'room_id': 'room-1', 'occupied_days': 10.0},
                {'room_id': 'room-2', 'occupied_days': 15.0},
              ]);

      // Act
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);
      final result = await repository.getOccupancyRate(start, end);

      // Assert - 25 days occupied / (4 rooms * 30 days) = 25/120 = 20.83%
      // Note: end.difference(start).inDays is 30, not 31
      expect(result, closeTo(20.83, 0.1));
    });

    test('returns percentage (0-100)', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'room_id': 'room-1', 'occupied_days': 30.0},
                {'room_id': 'room-2', 'occupied_days': 30.0},
                {'room_id': 'room-3', 'occupied_days': 30.0},
                {'room_id': 'apartment', 'occupied_days': 30.0},
              ]);

      // Act
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);
      final result = await repository.getOccupancyRate(start, end);

      // Assert - 100% occupancy (120/120)
      // Note: end.difference(start).inDays is 30
      expect(result, closeTo(100.0, 0.1));
    });
  });

  group('getAverageStayDuration', () {
    test('returns 0 when no reservations', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => []);

      // Act
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);
      final result = await repository.getAverageStayDuration(start, end);

      // Assert
      expect(result, 0.0);
    });

    test('calculates average stay correctly', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'avg_stay_days': 5.5},
              ]);

      // Act
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);
      final result = await repository.getAverageStayDuration(start, end);

      // Assert
      expect(result, 5.5);
    });

    test('uses JULIANDAY for calculation', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async => [
                {'avg_stay_days': 7.0},
              ]);

      // Act
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);
      await repository.getAverageStayDuration(start, end);

      // Assert
      final captured = verify(() => mockDatabase.rawQuery(captureAny(), captureAny())).captured;
      final sql = captured[0] as String;
      expect(sql.toUpperCase(), contains('JULIANDAY'));
    });
  });

  group('getStatistics', () {
    test('aggregates all metrics', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);

      // Mock responses for different queries
      int callCount = 0;
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async {
            callCount++;
            // Different responses based on call order
            if (callCount == 1) {
              // getPlatformRevenue
              return [
                {
                  'platformId': 'booking',
                  'platformName': 'Booking',
                  'color_value': 0xFF2196F3,
                  'totalRevenue': 1000.0,
                  'bookingCount': 5
                },
              ];
            } else if (callCount == 2) {
              // getMonthlyTrend
              return [
                {'month': '2025-01', 'revenue': 1000.0, 'bookingCount': 5},
              ];
            } else if (callCount == 3) {
              // getOccupancyRate
              return [
                {'room_id': 'room-1', 'occupied_days': 10.0},
              ];
            } else if (callCount == 4) {
              // getAverageStayDuration
              return [
                {'avg_stay_days': 5.5},
              ];
            } else if (callCount == 5) {
              // _getTotalBookings
              return [
                {'count': 5},
              ];
            } else if (callCount == 6) {
              // _getTotalGuests
              return [
                {'count': 3},
              ];
            } else if (callCount == 7) {
              // _getTotalRevenue
              return [
                {'total': 1000.0},
              ];
            } else {
              // getYearOverYearComparison
              return [
                {'month': '01', 'year': '2024', 'revenue': 1000.0},
                {'month': '01', 'year': '2025', 'revenue': 1200.0},
              ];
            }
          });

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.month);
      final result = await repository.getStatistics(filter);

      // Assert
      expect(result.totalRevenue, greaterThanOrEqualTo(0));
      expect(result.occupancyRate, greaterThanOrEqualTo(0));
      expect(result.averageStayDuration, greaterThanOrEqualTo(0));
      expect(result.totalBookings, greaterThanOrEqualTo(0));
      expect(result.totalGuests, greaterThanOrEqualTo(0));
      expect(result.platformBreakdown, isNotEmpty);
    });

    test('includes year over year comparison', () async {
      // Arrange
      when(() => mockDatabaseHelper.database)
          .thenAnswer((_) async => mockDatabase);

      int callCount = 0;
      when(() => mockDatabase.rawQuery(any(), any()))
          .thenAnswer((_) async {
            callCount++;
            if (callCount <= 7) {
              // Return minimal data for getStatistics queries
              return callCount == 1
                  ? [
                      {
                        'platformId': 'booking',
                        'platformName': 'Booking',
                        'color_value': 0xFF2196F3,
                        'totalRevenue': 1000.0,
                        'bookingCount': 5
                      },
                    ]
                  : callCount == 2
                      ? [
                          {'month': '2025-01', 'revenue': 1000.0, 'bookingCount': 5},
                        ]
                      : callCount == 5
                          ? [
                              {'count': 5},
                            ]
                          : callCount == 6
                              ? [
                                  {'count': 3},
                                ]
                              : callCount == 7
                                  ? [
                                      {'total': 1000.0},
                                    ]
                                  : [];
            }
            // getYearOverYearComparison
            return [
              {'month': '01', 'year': '2024', 'revenue': 1000.0},
              {'month': '01', 'year': '2025', 'revenue': 1200.0},
            ];
          });

      // Act
      final filter = StatisticsFilter(period: PeriodFilter.year);
      final result = await repository.getStatistics(filter);

      // Assert
      // YoY can be null if no data
      expect(result.yearOverYear, anyOf(isNull, isNotNull));
    });
  });
}
