import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings Tests', () {
    testWidgets('Settings page loads', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify settings view is visible
      expect(find.byKey(const Key('settings_view')), findsOneWidget);

      TestHelpers.logStep('Settings page loaded');
    });

    testWidgets('Settings page shows title', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify title
      expect(find.text('Impostazioni'), findsOneWidget);

      TestHelpers.logStep('Settings title found');
    });

    testWidgets('Settings shows theme option', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify theme tile is present
      expect(find.byKey(const Key('theme_tile')), findsOneWidget);
      expect(find.text('Tema'), findsOneWidget);

      TestHelpers.logStep('Theme option found');
    });

    testWidgets('Settings shows appearance section', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify appearance section
      expect(find.text('Aspetto'), findsOneWidget);

      TestHelpers.logStep('Appearance section found');
    });

    testWidgets('Settings shows data section', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify data section
      expect(find.text('Dati'), findsOneWidget);

      TestHelpers.logStep('Data section found');
    });

    testWidgets('Settings shows backup option', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify backup option
      expect(find.text('Backup e Ripristino'), findsOneWidget);

      TestHelpers.logStep('Backup option found');
    });

    testWidgets('Settings shows about section', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify about section
      expect(find.text('Informazioni'), findsOneWidget);
      expect(find.text('Versione'), findsOneWidget);

      TestHelpers.logStep('About section found');
    });

    testWidgets('Theme dialog opens and closes', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Tap theme tile
      await TestHelpers.tapAndWait(tester, const Key('theme_tile'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Seleziona Tema'), findsOneWidget);

      // Close dialog by selecting an option (use first to handle duplicates)
      await tester.tap(find.textContaining('Sistema').first);
      await tester.pumpAndSettle();

      TestHelpers.logStep('Theme dialog opened and closed');
    });
  });
}
