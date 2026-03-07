import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/statistics/presentation/pages/statistics_page.dart';
import 'package:app_prenotazioni/features/statistics/presentation/widgets/coming_soon_placeholder.dart';

void main() {
  group('StatisticsPage', () {
    testWidgets('displays ComingSoonPlaceholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsPage(),
        ),
      );

      expect(find.byType(ComingSoonPlaceholder), findsOneWidget);
    });

    testWidgets('has AppBar with title Statistiche', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsPage(),
        ),
      );

      expect(find.text('Statistiche'), findsOneWidget);
    });

    testWidgets('has correct key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StatisticsPage(),
        ),
      );

      expect(find.byKey(const Key('statistics_view')), findsOneWidget);
    });
  });
}
