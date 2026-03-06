import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Calendar Tests', () {
    testWidgets('Calendar loads within acceptable time', (tester) async {
      app.main();

      final performance = await TestHelpers.measurePerformance(tester, () async {
        await TestHelpers.waitForAppToLoad(tester);
      });

      TestHelpers.logStep('App load time: ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(10000)); // < 10 seconds

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify calendar view is visible
      expect(find.byKey(const Key('calendar_view')), findsOneWidget);

      TestHelpers.logStep('Calendar loaded successfully');
    });

    testWidgets('Calendar view is accessible', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify calendar view is visible
      expect(find.byKey(const Key('calendar_view')), findsOneWidget);

      // Verify calendar title
      expect(find.textContaining('Calendario'), findsOneWidget);

      TestHelpers.logStep('Calendar view is accessible');
    });

    testWidgets('Calendar shows info message', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify info message is shown
      expect(find.textContaining('Seleziona un giorno'), findsOneWidget);

      TestHelpers.logStep('Calendar info message found');
    });

    testWidgets('Calendar can be refreshed', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify refresh indicator exists (drag down gesture area)
      expect(find.byType(RefreshIndicator), findsOneWidget);

      TestHelpers.logStep('Calendar refresh indicator found');
    });
  });
}
