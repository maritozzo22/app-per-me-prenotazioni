import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard Tests', () {
    testWidgets('Dashboard loads and shows main components', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Dashboard should be the default view
      expect(find.byKey(const Key('dashboard_view')), findsOneWidget);

      TestHelpers.logStep('Dashboard loaded successfully');
    });

    testWidgets('Dashboard shows room occupancy section', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Verify occupancy grid is present
      expect(find.byKey(const Key('occupancy_grid')), findsOneWidget);

      TestHelpers.logStep('Occupancy grid found');
    });

    testWidgets('Dashboard shows income card', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Verify income card is present
      expect(find.byKey(const Key('income_card')), findsOneWidget);

      TestHelpers.logStep('Income card found');
    });

    testWidgets('Dashboard shows upcoming check-ins', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Verify check-ins card is present
      expect(find.byKey(const Key('check_ins_card')), findsOneWidget);

      TestHelpers.logStep('Check-ins card found');
    });

    testWidgets('Dashboard shows upcoming check-outs', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Verify check-outs card is present
      expect(find.byKey(const Key('check_outs_card')), findsOneWidget);

      TestHelpers.logStep('Check-outs card found');
    });

    testWidgets('Dashboard refresh works', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Find the dashboard view
      final dashboardView = find.byKey(const Key('dashboard_view'));
      expect(dashboardView, findsOneWidget);

      // Perform pull-to-refresh gesture
      await tester.fling(dashboardView, const Offset(0, 300), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      TestHelpers.logStep('Dashboard refresh completed');
    });

    testWidgets('Dashboard title is correct', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Verify dashboard title
      expect(find.text('Dashboard'), findsOneWidget);

      TestHelpers.logStep('Dashboard title found');
    });

    testWidgets('Dashboard shows Stanze Oggi section', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Verify section title
      expect(find.text('Stanze Oggi'), findsOneWidget);

      TestHelpers.logStep('Stanze Oggi section found');
    });
  });
}
