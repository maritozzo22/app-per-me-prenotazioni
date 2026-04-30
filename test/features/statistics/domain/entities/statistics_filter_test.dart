import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/statistics_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/period_filter.dart';

void main() {
  group('StatisticsFilter', () {
    group('defaults', () {
      test('defaults to month period', () {
        const filter = StatisticsFilter();
        expect(filter.period, PeriodFilter.month);
      });

      test('defaults includePending to true', () {
        const filter = StatisticsFilter();
        expect(filter.includePending, true);
      });

      test('custom dates are null by default', () {
        const filter = StatisticsFilter();
        expect(filter.customStartDate, isNull);
        expect(filter.customEndDate, isNull);
      });
    });

    group('JSON serialization', () {
      test('fromJson/toJson round-trips correctly', () {
        final filter = StatisticsFilter(
          period: PeriodFilter.year,
          customStartDate: DateTime(2025, 1, 15),
          customEndDate: DateTime(2025, 6, 30),
          includePending: false,
        );

        final json = filter.toJson();
        final restored = StatisticsFilter.fromJson(json);

        expect(restored.period, filter.period);
        expect(restored.customStartDate, filter.customStartDate);
        expect(restored.customEndDate, filter.customEndDate);
        expect(restored.includePending, filter.includePending);
      });

      test('serializes default values correctly', () {
        const filter = StatisticsFilter();
        final json = filter.toJson();
        final restored = StatisticsFilter.fromJson(json);

        expect(restored.period, PeriodFilter.month);
        expect(restored.includePending, true);
      });
    });

    group('dateRange extension', () {
      test('returns correct dates for month period', () {
        const filter = StatisticsFilter(period: PeriodFilter.month);
        final range = filter.dateRange;

        // Start should be first day of current month
        expect(range.start.day, 1);

        // End should be last day of current month
        final now = DateTime.now();
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
        expect(range.end.day, lastDayOfMonth);
        expect(range.end.hour, 23);
        expect(range.end.minute, 59);
        expect(range.end.second, 59);
      });

      test('returns correct dates for quarter period', () {
        const filter = StatisticsFilter(period: PeriodFilter.quarter);
        final range = filter.dateRange;

        // Start should be approximately 90 days before now
        final difference = range.end.difference(range.start).inDays;
        expect(difference, closeTo(90, 1)); // Allow 1 day tolerance
      });

      test('returns correct dates for year period', () {
        const filter = StatisticsFilter(period: PeriodFilter.year);
        final range = filter.dateRange;

        // Start should be Jan 1 of current year
        expect(range.start.month, 1);
        expect(range.start.day, 1);

        // End should be Dec 31 of current year
        expect(range.end.month, 12);
        expect(range.end.day, 31);
        expect(range.end.hour, 23);
        expect(range.end.minute, 59);
        expect(range.end.second, 59);
      });

      test('uses custom dates for custom period', () {
        final filter = StatisticsFilter(
          period: PeriodFilter.custom,
          customStartDate: DateTime(2025, 3, 1),
          customEndDate: DateTime(2025, 3, 31),
        );
        final range = filter.dateRange;

        expect(range.start.year, 2025);
        expect(range.start.month, 3);
        expect(range.start.day, 1);
        expect(range.end.year, 2025);
        expect(range.end.month, 3);
        expect(range.end.day, 31);
      });

      test('falls back to defaults when custom dates are null', () {
        const filter = StatisticsFilter(period: PeriodFilter.custom);
        final range = filter.dateRange;

        // Should fall back to current month
        final now = DateTime.now();
        expect(range.start.year, now.year);
        expect(range.start.month, now.month);
      });
    });
  });
}
