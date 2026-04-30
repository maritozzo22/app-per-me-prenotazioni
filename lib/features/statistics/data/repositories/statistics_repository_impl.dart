import 'package:app_prenotazioni/core/database/database_helper.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/year_over_year_comparison.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/aggregate_statistics.dart';
import 'package:app_prenotazioni/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Implementation of StatisticsRepository using SQLite aggregation queries.
///
/// Uses SQL GROUP BY and aggregate functions for efficient statistics
/// calculation instead of loading all data into memory.
class StatisticsRepositoryImpl implements StatisticsRepository {
  final DatabaseHelper _databaseHelper;

  /// Number of rooms available for occupancy calculation.
  static const int _totalRooms = 4; // Stanza 1, 2, 3, Appartamento

  StatisticsRepositoryImpl({
    required DatabaseHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  @override
  Future<List<PlatformRevenue>> getPlatformRevenue(
      StatisticsFilter filter) async {
    final db = await _databaseHelper.database as Database;
    final dateRange = filter.dateRange;

    final paymentFilter = filter.includePending
        ? "AND r.payment_status IN ('received', 'pending')"
        : "AND r.payment_status = 'received'";

    final sql = '''
      SELECT
        p.id as platformId,
        p.name as platformName,
        p.color_value as color_value,
        COALESCE(SUM(r.amount), 0) as totalRevenue,
        COUNT(r.id) as bookingCount
      FROM platforms p
      LEFT JOIN reservations r ON p.id = r.platform_id
        AND r.check_in >= ?
        AND r.check_in <= ?
        $paymentFilter
      GROUP BY p.id, p.name, p.color_value
      ORDER BY totalRevenue DESC
    ''';

    final results = await db.rawQuery(
      sql,
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    // Calculate total for percentage
    double totalRevenue = 0;
    for (final row in results) {
      totalRevenue += (row['totalRevenue'] as num?)?.toDouble() ?? 0;
    }

    // Filter out platforms with no revenue and map to entity
    return results
        .where((row) {
          final revenue = (row['totalRevenue'] as num?)?.toDouble() ?? 0;
          return revenue > 0;
        })
        .map((row) {
      final revenue = (row['totalRevenue'] as num?)?.toDouble() ?? 0;
      return PlatformRevenue(
        platformId: row['platformId'] as String,
        platformName: row['platformName'] as String,
        color: row['color_value'] as int,
        totalRevenue: revenue,
        bookingCount: (row['bookingCount'] as int?) ?? 0,
        percentage: totalRevenue > 0 ? (revenue / totalRevenue) * 100 : 0,
      );
    }).toList();
  }

  @override
  Future<List<MonthlyRevenue>> getMonthlyTrend(StatisticsFilter filter) async {
    final db = await _databaseHelper.database as Database;
    final dateRange = filter.dateRange;

    final paymentFilter = filter.includePending
        ? "AND payment_status IN ('received', 'pending')"
        : "AND payment_status = 'received'";

    final sql = '''
      SELECT
        strftime('%Y-%m', check_in) as month,
        SUM(amount) as revenue,
        COUNT(id) as bookingCount
      FROM reservations
      WHERE check_in >= ?
        AND check_in <= ?
        $paymentFilter
      GROUP BY strftime('%Y-%m', check_in)
      ORDER BY month ASC
    ''';

    final results = await db.rawQuery(
      sql,
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    return results.map((row) {
      final monthValue = row['month'];
      return MonthlyRevenue(
        month: monthValue != null ? monthValue as String : '',
        revenue: (row['revenue'] as num?)?.toDouble() ?? 0,
        bookingCount: (row['bookingCount'] as int?) ?? 0,
      );
    }).where((m) => m.month.isNotEmpty).toList();
  }

  @override
  Future<YearOverYearComparison?> getYearOverYearComparison(
      int year1, int year2) async {
    final db = await _databaseHelper.database as Database;

    const sql = '''
      SELECT
        strftime('%m', check_in) as month,
        strftime('%Y', check_in) as year,
        SUM(amount) as revenue
      FROM reservations
      WHERE strftime('%Y', check_in) IN (?, ?)
        AND payment_status = 'received'
      GROUP BY strftime('%Y-%m', check_in)
      ORDER BY month, year
    ''';

    final results = await db.rawQuery(sql, [year1.toString(), year2.toString()]);

    if (results.isEmpty) return null;

    // Initialize 12 months with zero for each year
    final year1Monthly = List<double>.filled(12, 0);
    final year2Monthly = List<double>.filled(12, 0);

    for (final row in results) {
      final month = int.parse(row['month'] as String) - 1; // 0-indexed
      final year = int.parse(row['year'] as String);
      final revenue = (row['revenue'] as num?)?.toDouble() ?? 0;

      if (year == year1) {
        year1Monthly[month] = revenue;
      } else if (year == year2) {
        year2Monthly[month] = revenue;
      }
    }

    return YearOverYearComparison(
      year1: year1,
      year2: year2,
      year1Monthly: year1Monthly,
      year2Monthly: year2Monthly,
    );
  }

  @override
  Future<double> getOccupancyRate(DateTime start, DateTime end) async {
    // Total available room-days in period
    final daysInPeriod = end.difference(start).inDays;
    final totalAvailableDays = _totalRooms * daysInPeriod;

    if (totalAvailableDays == 0) return 0;

    final db = await _databaseHelper.database as Database;

    // Calculate occupied days per room, handling reservations that span period boundaries
    const sql = '''
      SELECT
        room_id,
        SUM(
          JULIANDAY(MIN(check_out, ?)) - JULIANDAY(MAX(check_in, ?))
        ) as occupied_days
      FROM reservations
      WHERE check_out >= ?
        AND check_in <= ?
      GROUP BY room_id
    ''';

    final results = await db.rawQuery(
      sql,
      [
        end.toIso8601String(),
        start.toIso8601String(),
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );

    double totalOccupiedDays = 0;
    for (final row in results) {
      totalOccupiedDays += (row['occupied_days'] as num?)?.toDouble() ?? 0;
    }

    // Return as percentage
    return (totalOccupiedDays / totalAvailableDays) * 100;
  }

  @override
  Future<double> getAverageStayDuration(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database as Database;

    const sql = '''
      SELECT
        AVG(JULIANDAY(check_out) - JULIANDAY(check_in)) as avg_stay_days
      FROM reservations
      WHERE check_in >= ?
        AND check_in <= ?
    ''';

    final results = await db.rawQuery(
      sql,
      [start.toIso8601String(), end.toIso8601String()],
    );

    if (results.isEmpty) return 0;

    return (results.first['avg_stay_days'] as num?)?.toDouble() ?? 0;
  }

  @override
  Future<AggregateStatistics> getStatistics(StatisticsFilter filter) async {
    final dateRange = filter.dateRange;

    // Run all queries in parallel for efficiency
    final results = await Future.wait([
      getPlatformRevenue(filter),
      getMonthlyTrend(filter),
      getOccupancyRate(dateRange.start, dateRange.end),
      getAverageStayDuration(dateRange.start, dateRange.end),
      _getTotalBookings(dateRange.start, dateRange.end),
      _getTotalGuests(dateRange.start, dateRange.end),
      _getTotalRevenue(filter),
    ]);

    final platformBreakdown = results[0] as List<PlatformRevenue>;
    final monthlyTrend = results[1] as List<MonthlyRevenue>;
    final occupancyRate = results[2] as double;
    final avgStayDuration = results[3] as double;
    final totalBookings = results[4] as int;
    final totalGuests = results[5] as int;
    final totalRevenue = results[6] as double;

    // Get YoY comparison for current year vs previous year
    final now = DateTime.now();
    final currentYear = now.year;
    final previousYear = currentYear - 1;
    final yearOverYear = await getYearOverYearComparison(previousYear, currentYear);

    return AggregateStatistics(
      totalRevenue: totalRevenue,
      occupancyRate: occupancyRate,
      averageStayDuration: avgStayDuration,
      totalBookings: totalBookings,
      totalGuests: totalGuests,
      platformBreakdown: platformBreakdown,
      monthlyTrend: monthlyTrend,
      yearOverYear: yearOverYear,
    );
  }

  /// Get total number of bookings in the date range.
  Future<int> _getTotalBookings(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database as Database;

    const sql = '''
      SELECT COUNT(id) as count
      FROM reservations
      WHERE check_in >= ? AND check_in <= ?
    ''';

    final results = await db.rawQuery(
      sql,
      [start.toIso8601String(), end.toIso8601String()],
    );

    return (results.first['count'] as int?) ?? 0;
  }

  /// Get total number of unique guests in the date range.
  Future<int> _getTotalGuests(DateTime start, DateTime end) async {
    final db = await _databaseHelper.database as Database;

    const sql = '''
      SELECT COUNT(DISTINCT guest_name) as count
      FROM reservations
      WHERE check_in >= ? AND check_in <= ?
    ''';

    final results = await db.rawQuery(
      sql,
      [start.toIso8601String(), end.toIso8601String()],
    );

    return (results.first['count'] as int?) ?? 0;
  }

  /// Get total revenue for the filter period.
  Future<double> _getTotalRevenue(StatisticsFilter filter) async {
    final db = await _databaseHelper.database as Database;
    final dateRange = filter.dateRange;

    final paymentFilter = filter.includePending
        ? "AND payment_status IN ('received', 'pending')"
        : "AND payment_status = 'received'";

    final sql = '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM reservations
      WHERE check_in >= ?
        AND check_in <= ?
        $paymentFilter
    ''';

    final results = await db.rawQuery(
      sql,
      [dateRange.start.toIso8601String(), dateRange.end.toIso8601String()],
    );

    return (results.first['total'] as num?)?.toDouble() ?? 0;
  }
}
