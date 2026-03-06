import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Reservations List Tests', () {
    testWidgets('Reservations list page loads', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to reservations tab
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Verify reservations list is visible
      expect(find.byKey(const Key('reservations_list')), findsOneWidget);

      TestHelpers.logStep('Reservations list loaded');
    });

    testWidgets('Reservations list has search functionality', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to reservations tab
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Verify search field is present
      expect(find.byKey(const Key('search_field')), findsOneWidget);

      TestHelpers.logStep('Search field found');
    });

    testWidgets('Reservations list title is correct', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to reservations tab
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Verify title
      expect(find.text('Prenotazioni'), findsOneWidget);

      TestHelpers.logStep('Reservations title found');
    });

    testWidgets('Reservations list can be refreshed', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to reservations tab
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Find the list view
      final listView = find.byType(ListView).first;

      // Perform pull-to-refresh
      await tester.fling(listView, const Offset(0, 300), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      TestHelpers.logStep('Reservations list refreshed');
    });
  });

  group('Search Tests', () {
    testWidgets('Search field accepts input', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to reservations tab
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Find and tap search field
      final searchField = find.byKey(const Key('search_field'));
      expect(searchField, findsOneWidget);

      await tester.tap(searchField);
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(searchField, 'Mario');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      TestHelpers.logStep('Search input entered');
    });

    testWidgets('Search can be cleared', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to reservations tab
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Enter search text
      final searchField = find.byKey(const Key('search_field'));
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      await tester.enterText(searchField, 'Test search');
      await tester.pumpAndSettle();

      // Clear the field
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      TestHelpers.logStep('Search cleared');
    });
  });
}
