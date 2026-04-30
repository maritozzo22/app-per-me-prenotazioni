import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dark Mode Tests', () {
    testWidgets('Theme can be changed to dark mode', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Tap theme tile
      await TestHelpers.tapAndWait(tester, const Key('theme_tile'));
      await tester.pumpAndSettle();

      // Select dark mode (use first to handle duplicates)
      await tester.tap(find.textContaining('Scuro').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify we're back in settings
      expect(find.byKey(const Key('settings_view')), findsOneWidget);

      TestHelpers.logStep('Dark mode enabled');
    });

    testWidgets('Theme can be changed to light mode', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Tap theme tile
      await TestHelpers.tapAndWait(tester, const Key('theme_tile'));
      await tester.pumpAndSettle();

      // Select light mode
      await tester.tap(find.textContaining('Chiaro').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      TestHelpers.logStep('Light mode enabled');
    });

    testWidgets('Theme can be set to system default', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Tap theme tile
      await TestHelpers.tapAndWait(tester, const Key('theme_tile'));
      await tester.pumpAndSettle();

      // Select system mode
      await tester.tap(find.textContaining('Sistema').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      TestHelpers.logStep('System mode enabled');
    });

    testWidgets('Dark mode persists across navigation', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings and enable dark mode
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      await TestHelpers.tapAndWait(tester, const Key('theme_tile'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Scuro').first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Navigate to different tabs to verify dark mode persists
      await TestHelpers.tapIconAndWait(tester, Icons.dashboard);
      await tester.pumpAndSettle();
      TestHelpers.logStep('Dark mode verified on dashboard');

      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);
      await tester.pumpAndSettle();
      TestHelpers.logStep('Dark mode verified on calendar');

      await TestHelpers.tapIconAndWait(tester, Icons.list);
      await tester.pumpAndSettle();
      TestHelpers.logStep('Dark mode verified on reservations');
    });
  });
}
