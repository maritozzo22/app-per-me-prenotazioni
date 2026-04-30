import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('App launch performance', (tester) async {
      final performance = await TestHelpers.measurePerformance(tester, () async {
        app.main();
        await TestHelpers.waitForAppToLoad(tester);
      });

      TestHelpers.logStep('App launch time: ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(10000)); // < 10 seconds
    });

    testWidgets('Dashboard load performance', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      final performance = await TestHelpers.measurePerformance(tester, () async {
        // Dashboard should already be loaded, refresh it
        await tester.fling(
          find.byKey(const Key('dashboard_view')),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle(const Duration(seconds: 3));
      });

      TestHelpers.logStep('Dashboard refresh time: ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(5000)); // < 5 seconds
    });

    testWidgets('Navigation between tabs performance', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      final performance = await TestHelpers.measurePerformance(tester, () async {
        // Navigate to each tab
        await TestHelpers.tapIconAndWait(tester, Icons.calendar_today, settleTime: const Duration(milliseconds: 500));
        await TestHelpers.tapIconAndWait(tester, Icons.list, settleTime: const Duration(milliseconds: 500));
        await TestHelpers.tapIconAndWait(tester, Icons.hotel, settleTime: const Duration(milliseconds: 500));
        await TestHelpers.tapIconAndWait(tester, Icons.settings, settleTime: const Duration(milliseconds: 500));
        await TestHelpers.tapIconAndWait(tester, Icons.dashboard, settleTime: const Duration(milliseconds: 500));
      });

      TestHelpers.logStep('Full navigation cycle (5 tabs): ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(5000)); // < 5 seconds for 5 navigations
    });

    testWidgets('Calendar month navigation performance', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      final performance = await TestHelpers.measurePerformance(tester, () async {
        // Navigate through 12 months
        for (int i = 0; i < 12; i++) {
          await TestHelpers.tapIconAndWait(tester, Icons.chevron_right, settleTime: const Duration(milliseconds: 300));
        }
      });

      TestHelpers.logStep('12 month navigations: ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(10000)); // < 10 seconds for 12 navigations
    });

    testWidgets('List scroll performance', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to reservations
      await TestHelpers.tapIconAndWait(tester, Icons.list);

      // Find scrollable content
      final listView = find.byType(ListView).first;

      final performance = await TestHelpers.measurePerformance(tester, () async {
        // Scroll multiple times
        for (int i = 0; i < 5; i++) {
          await tester.drag(listView, const Offset(0, -500));
          await tester.pumpAndSettle();
        }
      });

      TestHelpers.logStep('5 scroll operations: ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(3000)); // < 3 seconds
    });

    testWidgets('Settings interaction performance', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to settings
      await TestHelpers.tapIconAndWait(tester, Icons.settings);

      final performance = await TestHelpers.measurePerformance(tester, () async {
        // Open and close theme dialog multiple times
        for (int i = 0; i < 3; i++) {
          await TestHelpers.tapAndWait(tester, const Key('theme_tile'));
          await tester.pumpAndSettle();
          await tester.tap(find.textContaining('Sistema').first);
          await tester.pumpAndSettle();
        }
      });

      TestHelpers.logStep('3 theme dialog cycles: ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(5000)); // < 5 seconds
    });

    testWidgets('Memory stress test - rapid navigation', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      final performance = await TestHelpers.measurePerformance(tester, () async {
        // Rapid navigation for memory stress
        for (int i = 0; i < 20; i++) {
          await TestHelpers.tapIconAndWait(tester, Icons.calendar_today, settleTime: const Duration(milliseconds: 100));
          await TestHelpers.tapIconAndWait(tester, Icons.list, settleTime: const Duration(milliseconds: 100));
          await TestHelpers.tapIconAndWait(tester, Icons.hotel, settleTime: const Duration(milliseconds: 100));
          await TestHelpers.tapIconAndWait(tester, Icons.settings, settleTime: const Duration(milliseconds: 100));
          await TestHelpers.tapIconAndWait(tester, Icons.dashboard, settleTime: const Duration(milliseconds: 100));
        }
      });

      TestHelpers.logStep('Rapid navigation (100 taps): ${performance['duration_ms']}ms');
      expect(performance['duration_ms'], lessThan(30000)); // < 30 seconds

      // Verify app is still responsive
      expect(find.byKey(const Key('dashboard_view')), findsOneWidget);

      TestHelpers.logStep('Memory stress test completed - app remains responsive');
    });
  });
}
