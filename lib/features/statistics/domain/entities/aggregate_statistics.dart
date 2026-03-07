import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/platform_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/year_over_year_comparison.dart';

part 'aggregate_statistics.freezed.dart';
part 'aggregate_statistics.g.dart';

/// Aggregated statistics for a given period.
@freezed
class AggregateStatistics with _$AggregateStatistics {
  const factory AggregateStatistics({
    required double totalRevenue,
    required double occupancyRate,
    required double averageStayDuration,
    required int totalBookings,
    required int totalGuests,
    required List<PlatformRevenue> platformBreakdown,
    required List<MonthlyRevenue> monthlyTrend,
    required YearOverYearComparison? yearOverYear,
  }) = _AggregateStatistics;

  factory AggregateStatistics.fromJson(Map<String, dynamic> json) =>
      _$AggregateStatisticsFromJson(json);
}
