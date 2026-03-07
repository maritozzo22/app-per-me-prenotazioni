import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/aggregate_statistics.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/year_over_year_comparison.dart';

/// Repository interface for statistics data access.
abstract class StatisticsRepository {
  /// Get aggregate statistics for a given filter.
  Future<AggregateStatistics> getStatistics(StatisticsFilter filter);

  /// Get platform revenue breakdown.
  Future<List<PlatformRevenue>> getPlatformRevenue(StatisticsFilter filter);

  /// Get monthly revenue trend.
  Future<List<MonthlyRevenue>> getMonthlyTrend(StatisticsFilter filter);

  /// Get year-over-year comparison.
  Future<YearOverYearComparison?> getYearOverYearComparison(int year1, int year2);

  /// Get occupancy rate for period.
  Future<double> getOccupancyRate(DateTime start, DateTime end);

  /// Get average stay duration in days.
  Future<double> getAverageStayDuration(DateTime start, DateTime end);
}
