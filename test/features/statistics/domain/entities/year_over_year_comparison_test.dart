import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/year_over_year_comparison.dart';

void main() {
  group('YearOverYearComparison', () {
    group('entity creation', () {
      test('stores both years data', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: List.filled(12, 1000.0),
          year2Monthly: List.filled(12, 1200.0),
        );

        expect(comparison.year1, 2024);
        expect(comparison.year2, 2025);
        expect(comparison.year1Monthly.length, 12);
        expect(comparison.year2Monthly.length, 12);
      });

      test('year1Monthly and year2Monthly have 12 elements each', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200],
          year2Monthly: [150, 250, 350, 450, 550, 650, 750, 850, 950, 1050, 1150, 1250],
        );

        expect(comparison.year1Monthly.length, 12);
        expect(comparison.year2Monthly.length, 12);
      });
    });

    group('JSON serialization', () {
      test('fromJson/toJson round-trips correctly', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200],
          year2Monthly: [150, 250, 350, 450, 550, 650, 750, 850, 950, 1050, 1150, 1250],
        );

        final json = comparison.toJson();
        final restored = YearOverYearComparison.fromJson(json);

        expect(restored.year1, comparison.year1);
        expect(restored.year2, comparison.year2);
        expect(restored.year1Monthly, comparison.year1Monthly);
        expect(restored.year2Monthly, comparison.year2Monthly);
      });
    });

    group('extensions', () {
      test('maxRevenue returns the highest value', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200],
          year2Monthly: [150, 250, 350, 450, 550, 650, 750, 850, 950, 1050, 1150, 1300], // 1300 is max
        );

        expect(comparison.maxRevenue, 1300);
      });

      test('maxRevenue handles all zeros', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: List.filled(12, 0.0),
          year2Monthly: List.filled(12, 0.0),
        );

        expect(comparison.maxRevenue, 0);
      });

      test('growthPercentage calculates positive growth correctly', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100], // Total: 1200
          year2Monthly: [120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120], // Total: 1440
        );

        // Growth: (1440 - 1200) / 1200 * 100 = 20%
        expect(comparison.growthPercentage, closeTo(20.0, 0.01));
      });

      test('growthPercentage calculates negative growth correctly', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: [200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200], // Total: 2400
          year2Monthly: [150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150], // Total: 1800
        );

        // Growth: (1800 - 2400) / 2400 * 100 = -25%
        expect(comparison.growthPercentage, closeTo(-25.0, 0.01));
      });

      test('growthPercentage returns 0 when year1 total is 0', () {
        final comparison = YearOverYearComparison(
          year1: 2024,
          year2: 2025,
          year1Monthly: List.filled(12, 0.0),
          year2Monthly: [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
        );

        expect(comparison.growthPercentage, 0);
      });
    });
  });
}
