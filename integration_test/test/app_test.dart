import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch and Navigation Tests', () {
    testWidgets('App launches and shows dashboard', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Verify bottom navigation is visible
      expect(find.byKey(const Key('bottom_nav')), findsOneWidget);

      TestHelpers.logStep('App launched successfully');
    });

    testWidgets('Navigate to calendar tab', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Find bottom navigation
      final bottomNav = find.byKey(const Key('bottom_nav'));
      expect(bottomNav, findsOneWidget);

      // Tap calendar tab using icon
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify calendar view is visible
      expect(find.byKey(const Key('calendar_view')), findsOneWidget);

      TestHelpers.logStep('Navigated to calendar tab');
    });

    testWidgets('Navigate to reservations tab', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Tap reservations tab
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Verify reservations list is visible
      expect(find.byKey(const Key('reservations_list')), findsOneWidget);

      TestHelpers.logStep('Navigated to reservations tab');
    });

    testWidgets('Navigate to platforms tab', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Tap platforms tab
      await TestHelpers.tapIconAndWait(tester, Icons.hotel);

      // Verify platforms list is visible
      expect(find.byKey(const Key('platforms_list')), findsOneWidget);

      TestHelpers.logStep('Navigated to platforms tab');
    });

    testWidgets('Navigate to settings tab', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Tap settings tab
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      // Verify settings view is visible
      expect(find.byKey(const Key('settings_view')), findsOneWidget);

      TestHelpers.logStep('Navigated to settings tab');
    });

    testWidgets('Rapid navigation performance', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      final performance = await TestHelpers.measurePerformance(tester, () async {
        for (int i = 0; i < 5; i++) {
          // Navigate through all tabs
          await TestHelpers.tapIconAndWait(tester, Icons.dashboard, settleTime: const Duration(milliseconds: 500));
          await TestHelpers.tapIconAndWait(tester, Icons.calendar_today, settleTime: const Duration(milliseconds: 500));
          await TestHelpers.tapIconAndWait(tester, Icons.list, settleTime: const Duration(milliseconds: 500));
          await TestHelpers.tapIconAndWait(tester, Icons.hotel, settleTime: const Duration(milliseconds: 500));
          await TestHelpers.tapIconAndWait(tester, Icons.settings, settleTime: const Duration(milliseconds: 500));
        }
      });

      TestHelpers.logStep('Navigation performance: ${performance['duration_ms']}ms for 25 navigations');

      // Verify no lag (should be < 60 seconds for 25 navigations on physical device)
      expect(performance['duration_ms'], lessThan(60000));
    });
  });
}
