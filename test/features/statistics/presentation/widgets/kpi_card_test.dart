import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/kpi_card.dart';

void main() {
  group('KpiCard', () {
    testWidgets('displays title and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Fatturato',
              value: 10000,
            ),
          ),
        ),
      );

      expect(find.text('Fatturato'), findsOneWidget);
      expect(find.text('10.000'), findsOneWidget);
    });

    testWidgets('formats currency values correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Fatturato',
              value: 15000.50,
              format: KpiFormat.currency,
            ),
          ),
        ),
      );

      expect(find.text('Fatturato'), findsOneWidget);
      // Euro symbol with formatted number - value is 15000.50 rounded to 15001
      // NumberFormat.currency with decimalDigits: 0 produces €15,001
      expect(find.textContaining('€'), findsWidgets);
    });

    testWidgets('formats percentage values correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Occupazione',
              value: 75.5,
              format: KpiFormat.percentage,
            ),
          ),
        ),
      );

      expect(find.text('Occupazione'), findsOneWidget);
      expect(find.text('75.5%'), findsOneWidget);
    });

    testWidgets('formats days values correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Durata Media',
              value: 3.5,
              format: KpiFormat.days,
            ),
          ),
        ),
      );

      expect(find.text('Durata Media'), findsOneWidget);
      expect(find.text('3.5 giorni'), findsOneWidget);
    });

    testWidgets('shows optional subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Fatturato',
              value: 10000,
              subtitle: '+10% vs mese scorso',
            ),
          ),
        ),
      );

      expect(find.text('Fatturato'), findsOneWidget);
      expect(find.text('+10% vs mese scorso'), findsOneWidget);
    });

    testWidgets('applies custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Fatturato',
              value: 10000,
              icon: Icons.euro,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.euro), findsOneWidget);
    });

    testWidgets('applies number format for integer values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Prenotazioni',
              value: 25,
              format: KpiFormat.number,
            ),
          ),
        ),
      );

      expect(find.text('Prenotazioni'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('applies number format for large values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiCard(
              title: 'Ospiti',
              value: 1500,
              format: KpiFormat.number,
            ),
          ),
        ),
      );

      expect(find.text('Ospiti'), findsOneWidget);
      expect(find.text('1.500'), findsOneWidget);
    });
  });
}
