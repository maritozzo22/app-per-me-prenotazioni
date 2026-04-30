import 'package:freezed_annotation/freezed_annotation.dart';

part 'year_over_year_comparison.freezed.dart';
part 'year_over_year_comparison.g.dart';

/// Year-over-year revenue comparison for bar chart.
@freezed
class YearOverYearComparison with _$YearOverYearComparison {
  const factory YearOverYearComparison({
    required int year1,
    required int year2,
    required List<double> year1Monthly, // 12 elements (Jan-Dec)
    required List<double> year2Monthly, // 12 elements (Jan-Dec)
  }) = _YearOverYearComparison;

  factory YearOverYearComparison.fromJson(Map<String, dynamic> json) =>
      _$YearOverYearComparisonFromJson(json);
}

/// Extension for chart helpers.
extension YearOverYearComparisonX on YearOverYearComparison {
  /// Returns the maximum revenue across both years for chart Y-axis scaling.
  double get maxRevenue {
    final allValues = [...year1Monthly, ...year2Monthly];
    return allValues.reduce((a, b) => a > b ? a : b);
  }

  /// Returns year-over-year growth percentage (can be negative).
  double get growthPercentage {
    final year1Total = year1Monthly.reduce((a, b) => a + b);
    final year2Total = year2Monthly.reduce((a, b) => a + b);
    if (year1Total == 0) return 0;
    return ((year2Total - year1Total) / year1Total) * 100;
  }
}
