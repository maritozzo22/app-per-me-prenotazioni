import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Platforms List Tests', () {
    testWidgets('Platforms list page loads', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to platforms tab
      await TestHelpers.tapIconAndWait(tester, Icons.hotel);

      // Verify platforms list is visible
      expect(find.byKey(const Key('platforms_list')), findsOneWidget);

      TestHelpers.logStep('Platforms list loaded');
    });

    testWidgets('Platforms list has FAB for adding new platform', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to platforms tab
      await TestHelpers.tapIconAndWait(tester, Icons.hotel);

      // Verify FAB is present
      expect(find.byKey(const Key('platform_fab')), findsOneWidget);

      TestHelpers.logStep('Platform FAB found');
    });

    testWidgets('Platforms list title is correct', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to platforms tab
      await TestHelpers.tapIconAndWait(tester, Icons.hotel);

      // Verify title
      expect(find.text('Gestione Piattaforme'), findsOneWidget);

      TestHelpers.logStep('Platforms title found');
    });

    testWidgets('Platforms list shows default platforms', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to platforms tab
      await TestHelpers.tapIconAndWait(tester, Icons.hotel);

      // Look for common platform names
      // The app should have at least Airbnb and Booking as defaults
      expect(find.textContaining('Airbnb'), findsWidgets);

      TestHelpers.logStep('Default platforms found');
    });

    testWidgets('Platform FAB shows correct label', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to platforms tab
      await TestHelpers.tapIconAndWait(tester, Icons.hotel);

      // Verify FAB label
      expect(find.text('Nuova Piattaforma'), findsOneWidget);

      TestHelpers.logStep('Platform FAB label found');
    });

    testWidgets('Platforms list can be refreshed', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to platforms tab
      await TestHelpers.tapIconAndWait(tester, Icons.hotel);

      // Find the list view
      final listView = find.byKey(const Key('platforms_list_view'));
      if (listView.evaluate().isNotEmpty) {
        // Perform pull-to-refresh
        await tester.fling(listView, const Offset(0, 300), 1000);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      TestHelpers.logStep('Platforms list refreshed');
    });
  });
}
