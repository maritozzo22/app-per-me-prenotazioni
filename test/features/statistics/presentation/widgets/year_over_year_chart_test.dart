import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/year_over_year_chart.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/year_over_year_comparison.dart';

void main() {
  group('YearOverYearChart', () {
    testWidgets('renders grouped bar chart with data', (tester) async {
      // Arrange
      final data = YearOverYearComparison(
        year1: 2024,
        year2: 2025,
        year1Monthly: List.generate(12, (i) => 1000.0 + i * 100),
        year2Monthly: List.generate(12, (i) => 1200.0 + i * 100),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YearOverYearChart(data: data),
          ),
        ),
      );

      // Assert
      expect(find.text('Confronto Annuale'), findsOneWidget);
      expect(find.text('2024 vs 2025'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
    });

    testWidgets('shows empty state message when data is null', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YearOverYearChart(data: null),
          ),
        ),
      );

      // Assert
      expect(find.text('Dati insufficienti per il confronto'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('X-axis shows month labels', (tester) async {
      // Arrange
      final data = YearOverYearComparison(
        year1: 2024,
        year2: 2025,
        year1Monthly: List.generate(12, (i) => 1000.0),
        year2Monthly: List.generate(12, (i) => 1200.0),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YearOverYearChart(data: data),
          ),
        ),
      );

      // Assert - Check for some month labels
      expect(find.text('Gen'), findsOneWidget);
      expect(find.text('Feb'), findsOneWidget);
      expect(find.text('Mar'), findsOneWidget);
    });

    testWidgets('Y-axis shows Euro values', (tester) async {
      // Arrange
      final data = YearOverYearComparison(
        year1: 2024,
        year2: 2025,
        year1Monthly: List.generate(12, (i) => 1000.0),
        year2Monthly: List.generate(12, (i) => 1200.0),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YearOverYearChart(data: data),
          ),
        ),
      );

      // Assert - Check for Euro symbol
      expect(find.textContaining('€'), findsWidgets);
    });

    testWidgets('Legend shows both years', (tester) async {
      // Arrange
      final data = YearOverYearComparison(
        year1: 2024,
        year2: 2025,
        year1Monthly: List.generate(12, (i) => 1000.0),
        year2Monthly: List.generate(12, (i) => 1200.0),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YearOverYearChart(data: data),
          ),
        ),
      );

      // Assert
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      // Arrange
      final data = YearOverYearComparison(
        year1: 2024,
        year2: 2025,
        year1Monthly: List.generate(12, (i) => 1000.0),
        year2Monthly: List.generate(12, (i) => 1200.0),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YearOverYearChart(data: data, height: 400),
          ),
        ),
      );

      // Assert - Widget should render without errors
      expect(find.text('Confronto Annuale'), findsOneWidget);
    });
  });
}
