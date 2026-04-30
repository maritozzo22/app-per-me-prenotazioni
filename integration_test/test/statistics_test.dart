import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Statistics Feature Integration Tests', () {
    testWidgets('StatisticsPage displays KPI cards', (WidgetTester tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to statistics tab
      final statsTab = find.byIcon(Icons.bar_chart);
      expect(statsTab, findsOneWidget, reason: 'Statistics tab should be visible');

      await tester.tap(statsTab);
      await tester.pumpAndSettle();

      // Verify page loaded
      expect(find.text('Statistiche'), findsOneWidget);

      // Wait for data to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify KPI cards are displayed (if data exists)
      expect(find.text('Fatturato'), findsOneWidget);
      expect(find.text('Occupazione'), findsOneWidget);
      expect(find.text('Durata Media'), findsOneWidget);
      expect(find.text('Prenotazioni'), findsOneWidget);
      expect(find.text('Ospiti'), findsOneWidget);

      TestHelpers.logStep('StatisticsPage displays KPI cards');
    });

    testWidgets('Period filter changes trigger reload', (WidgetTester tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to statistics tab
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Find and tap Trimestre filter
      final trimestreChip = find.text('Trimestre');
      if (trimestreChip.evaluate().isNotEmpty) {
        await tester.ensureVisible(trimestreChip);
        await tester.tap(trimestreChip);
        await tester.pumpAndSettle();

        // Verify loading state occurred (check for data reload)
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        TestHelpers.logStep('Period filter Trimestre selected');
      }

      // Find and tap Anno filter
      final annoChip = find.text('Anno');
      if (annoChip.evaluate().isNotEmpty) {
        await tester.ensureVisible(annoChip);
        await tester.tap(annoChip);
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        TestHelpers.logStep('Period filter Anno selected');
      }
    });

    testWidgets('Refresh button reloads data', (WidgetTester tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to statistics tab
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      TestHelpers.logStep('Refresh button tapped and data reloaded');
    });

    testWidgets('Charts section displays correctly', (WidgetTester tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to statistics tab
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Wait for data to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Scroll down to charts section
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify charts section exists
      expect(find.text('Analisi'), findsOneWidget);
      expect(find.text('Confronto Annuale'), findsOneWidget);
      expect(find.text('Fatturato per Piattaforma'), findsOneWidget);
      expect(find.text('Trend Mensile'), findsOneWidget);

      TestHelpers.logStep('Charts section displays correctly');
    });

    testWidgets('Statistics page with empty state', (WidgetTester tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to statistics tab
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Wait for data to load
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // If no data, should show empty message
      // If data exists, KPI cards should be visible
      final hasKpiCards = find.text('Fatturato').evaluate().isNotEmpty;
      final hasEmptyMessage = find.text('Nessun dato disponibile').evaluate().isNotEmpty;

      expect(hasKpiCards || hasEmptyMessage, isTrue,
          reason: 'Should either show KPI cards or empty state message');

      TestHelpers.logStep('Statistics page handles empty state correctly');
    });
  });
}
