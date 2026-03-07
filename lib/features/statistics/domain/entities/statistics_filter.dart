import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/period_filter.dart';

part 'statistics_filter.freezed.dart';
part 'statistics_filter.g.dart';

/// Filter criteria for statistics queries.
@freezed
class StatisticsFilter with _$StatisticsFilter {
  const factory StatisticsFilter({
    @Default(PeriodFilter.month) PeriodFilter period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    @Default(true) bool includePending,
  }) = _StatisticsFilter;

  factory StatisticsFilter.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFilterFromJson(json);
}

/// Extension to calculate date range from filter.
extension StatisticsFilterX on StatisticsFilter {
  /// Returns the start and end dates for this filter.
  ({DateTime start, DateTime end}) get dateRange {
    final now = DateTime.now();
    switch (period) {
      case PeriodFilter.month:
        return (
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case PeriodFilter.quarter:
        return (
          start: now.subtract(const Duration(days: 90)),
          end: now,
        );
      case PeriodFilter.year:
        return (
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      case PeriodFilter.custom:
        return (
          start: customStartDate ?? DateTime(now.year, now.month, 1),
          end: customEndDate ?? now,
        );
    }
  }
}
