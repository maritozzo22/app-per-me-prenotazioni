import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/period_filter_selector.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/period_filter.dart';

void main() {
  group('PeriodFilterSelector', () {
    testWidgets('displays all 4 period options', (tester) async {
      PeriodFilter? selectedPeriod;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PeriodFilterSelector(
              selectedPeriod: PeriodFilter.month,
              onPeriodChanged: (period) {
                selectedPeriod = period;
              },
            ),
          ),
        ),
      );

      expect(find.text('Mese'), findsOneWidget);
      expect(find.text('Trimestre'), findsOneWidget);
      expect(find.text('Anno'), findsOneWidget);
      expect(find.text('Personalizzato'), findsOneWidget);
    });

    testWidgets('highlights selected period', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PeriodFilterSelector(
              selectedPeriod: PeriodFilter.year,
              onPeriodChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the 'Anno' chip and verify it's selected
      final annoChip = find.widgetWithText(FilterChip, 'Anno');
      expect(annoChip, findsOneWidget);

      final filterChip = tester.widget<FilterChip>(annoChip);
      expect(filterChip.selected, isTrue);
    });

    testWidgets('callback fires on selection', (tester) async {
      PeriodFilter? selectedPeriod;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PeriodFilterSelector(
              selectedPeriod: PeriodFilter.month,
              onPeriodChanged: (period) {
                selectedPeriod = period;
              },
            ),
          ),
        ),
      );

      // Tap 'Trimestre' chip
      await tester.tap(find.widgetWithText(FilterChip, 'Trimestre'));
      await tester.pumpAndSettle();

      expect(selectedPeriod, equals(PeriodFilter.quarter));
    });

    testWidgets('callback fires for year selection', (tester) async {
      PeriodFilter? selectedPeriod;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PeriodFilterSelector(
              selectedPeriod: PeriodFilter.month,
              onPeriodChanged: (period) {
                selectedPeriod = period;
              },
            ),
          ),
        ),
      );

      // Tap 'Anno' chip
      await tester.tap(find.widgetWithText(FilterChip, 'Anno'));
      await tester.pumpAndSettle();

      expect(selectedPeriod, equals(PeriodFilter.year));
    });
  });
}
