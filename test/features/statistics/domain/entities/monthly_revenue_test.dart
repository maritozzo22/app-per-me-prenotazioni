import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';

void main() {
  group('MonthlyRevenue', () {
    group('entity creation', () {
      test('stores month, revenue, and booking count', () {
        final revenue = MonthlyRevenue(
          month: '2025-03',
          revenue: 8500.00,
          bookingCount: 8,
        );

        expect(revenue.month, '2025-03');
        expect(revenue.revenue, 8500.00);
        expect(revenue.bookingCount, 8);
      });

      test('handles zero values correctly', () {
        final revenue = MonthlyRevenue(
          month: '2025-01',
          revenue: 0,
          bookingCount: 0,
        );

        expect(revenue.revenue, 0);
        expect(revenue.bookingCount, 0);
      });
    });

    group('JSON serialization', () {
      test('fromJson/toJson round-trips correctly', () {
        final revenue = MonthlyRevenue(
          month: '2025-06',
          revenue: 12500.50,
          bookingCount: 15,
        );

        final json = revenue.toJson();
        final restored = MonthlyRevenue.fromJson(json);

        expect(restored.month, revenue.month);
        expect(restored.revenue, revenue.revenue);
        expect(restored.bookingCount, revenue.bookingCount);
      });
    });

    group('month format', () {
      test('format is YYYY-MM', () {
        final revenue = MonthlyRevenue(
          month: '2025-12',
          revenue: 10000,
          bookingCount: 10,
        );

        // Verify format matches YYYY-MM pattern
        expect(revenue.month, matches(r'^\d{4}-\d{2}$'));
      });
    });

    group('extensions', () {
      test('monthIndex returns correct value (0-11)', () {
        final january = MonthlyRevenue(month: '2025-01', revenue: 1000, bookingCount: 1);
        final june = MonthlyRevenue(month: '2025-06', revenue: 1000, bookingCount: 1);
        final december = MonthlyRevenue(month: '2025-12', revenue: 1000, bookingCount: 1);

        expect(january.monthIndex, 0);
        expect(june.monthIndex, 5);
        expect(december.monthIndex, 11);
      });

      test('year returns correct value', () {
        final revenue = MonthlyRevenue(
          month: '2025-08',
          revenue: 1000,
          bookingCount: 1,
        );

        expect(revenue.year, 2025);
      });

      test('extensions work with different years', () {
        final revenue2024 = MonthlyRevenue(month: '2024-12', revenue: 1000, bookingCount: 1);
        final revenue2025 = MonthlyRevenue(month: '2025-01', revenue: 1000, bookingCount: 1);

        expect(revenue2024.year, 2024);
        expect(revenue2025.year, 2025);
        expect(revenue2024.monthIndex, 11);
        expect(revenue2025.monthIndex, 0);
      });
    });
  });
}
