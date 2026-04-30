import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/monthly_trend_chart.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/monthly_revenue.dart';

void main() {
  group('MonthlyTrendChart', () {
    testWidgets('renders line chart with data', (tester) async {
      // Arrange
      final data = [
        MonthlyRevenue(month: '2025-01', revenue: 3000.0, bookingCount: 5),
        MonthlyRevenue(month: '2025-02', revenue: 4000.0, bookingCount: 7),
        MonthlyRevenue(month: '2025-03', revenue: 3500.0, bookingCount: 6),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(data: data),
          ),
        ),
      );

      // Assert
      expect(find.text('Trend Mensile'), findsOneWidget);
    });

    testWidgets('shows empty state when no data', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(data: []),
          ),
        ),
      );

      // Assert
      expect(find.text('Nessun dato disponibile'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);
    });

    testWidgets('X-axis shows month labels', (tester) async {
      // Arrange
      final data = [
        MonthlyRevenue(month: '2025-01', revenue: 3000.0, bookingCount: 5),
        MonthlyRevenue(month: '2025-02', revenue: 4000.0, bookingCount: 7),
        MonthlyRevenue(month: '2025-03', revenue: 3500.0, bookingCount: 6),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(data: data),
          ),
        ),
      );

      // Assert - Check for some month labels (FL Chart renders multiple copies)
      expect(find.text('Gen'), findsWidgets);
      expect(find.text('Feb'), findsWidgets);
      expect(find.text('Mar'), findsWidgets);
    });

    testWidgets('Y-axis shows Euro values', (tester) async {
      // Arrange
      final data = [
        MonthlyRevenue(month: '2025-01', revenue: 3000.0, bookingCount: 5),
        MonthlyRevenue(month: '2025-02', revenue: 4000.0, bookingCount: 7),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(data: data),
          ),
        ),
      );

      // Assert - Check for Euro symbol
      expect(find.textContaining('€'), findsWidgets);
    });

    testWidgets('renders with custom height', (tester) async {
      // Arrange
      final data = [
        MonthlyRevenue(month: '2025-01', revenue: 3000.0, bookingCount: 5),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(data: data, height: 400),
          ),
        ),
      );

      // Assert - Widget should render without errors
      expect(find.text('Trend Mensile'), findsOneWidget);
    });

    testWidgets('handles single data point', (tester) async {
      // Arrange
      final data = [
        MonthlyRevenue(month: '2025-06', revenue: 5000.0, bookingCount: 10),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(data: data),
          ),
        ),
      );

      // Assert - Widget should render without errors
      expect(find.text('Trend Mensile'), findsOneWidget);
      expect(find.text('Giu'), findsOneWidget);
    });

    testWidgets('handles many data points', (tester) async {
      // Arrange - 12 months of data
      final data = List.generate(
        12,
        (i) => MonthlyRevenue(
          month: '2025-${(i + 1).toString().padLeft(2, '0')}',
          revenue: 3000.0 + i * 100,
          bookingCount: 5 + i,
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthlyTrendChart(data: data),
          ),
        ),
      );

      // Assert - Widget should render without errors
      expect(find.text('Trend Mensile'), findsOneWidget);
    });
  });
}
