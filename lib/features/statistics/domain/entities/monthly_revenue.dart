import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_revenue.freezed.dart';
part 'monthly_revenue.g.dart';

/// Monthly revenue data point for trend charts.
@freezed
class MonthlyRevenue with _$MonthlyRevenue {
  const factory MonthlyRevenue({
    required String month, // Format: YYYY-MM (e.g., "2025-01")
    required double revenue,
    required int bookingCount,
  }) = _MonthlyRevenue;

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) =>
      _$MonthlyRevenueFromJson(json);
}

/// Extension for chart-friendly data access.
extension MonthlyRevenueX on MonthlyRevenue {
  /// Returns month index (0-11) for chart x-axis.
  int get monthIndex => int.parse(month.split('-')[1]) - 1;

  /// Returns year for grouping.
  int get year => int.parse(month.split('-')[0]);
}
