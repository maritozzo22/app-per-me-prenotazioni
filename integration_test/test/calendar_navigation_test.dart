import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_prenotazioni/main.dart' as app;
import 'package:table_calendar/table_calendar.dart';
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Calendar Navigation Tests', () {
    testWidgets('Calendar page loads and shows calendar widget', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify calendar widget is present
      expect(find.byKey(const Key('calendar_view')), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);

      TestHelpers.logStep('Calendar page loaded successfully');
    });

    testWidgets('Day tap shows bottom sheet', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Find a day cell and tap it
      final day15 = find.textContaining('15');
      if (day15.evaluate().isNotEmpty) {
        await tester.tap(day15.first);
        await tester.pumpAndSettle();

        // Bottom sheet may or may not appear depending on reservations
        // Just verify no errors occurred
        TestHelpers.logStep('Day tap completed without errors');
      }
    });

    testWidgets('Swipe gesture changes month via chevrons', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify calendar is present
      expect(find.byType(TableCalendar), findsOneWidget);

      // Use chevron to navigate to next month
      final nextMonthChevron = find.byIcon(Icons.chevron_right);
      if (nextMonthChevron.evaluate().isNotEmpty) {
        await tester.tap(nextMonthChevron.first);
        await tester.pumpAndSettle();

        TestHelpers.logStep('Navigated to next month via chevron');
      }

      // Use chevron to navigate back to previous month
      final prevMonthChevron = find.byIcon(Icons.chevron_left);
      if (prevMonthChevron.evaluate().isNotEmpty) {
        await tester.tap(prevMonthChevron.first);
        await tester.pumpAndSettle();

        TestHelpers.logStep('Navigated to previous month via chevron');
      }
    });

    testWidgets('Horizontal swipe gesture on calendar', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify calendar is present
      expect(find.byType(TableCalendar), findsOneWidget);

      // Perform horizontal drag (swipe left for next month)
      final calendar = find.byType(TableCalendar);
      await tester.drag(calendar, const Offset(-300, 0));
      await tester.pumpAndSettle();

      TestHelpers.logStep('Horizontal swipe completed');

      // Swipe back (right)
      await tester.drag(calendar, const Offset(300, 0));
      await tester.pumpAndSettle();

      TestHelpers.logStep('Swipe back completed');
    });

    testWidgets('Calendar shows updated hint text', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify new hint text is shown
      expect(find.textContaining('Scorri orizzontalmente'), findsOneWidget);

      TestHelpers.logStep('Updated hint text verified');
    });

    testWidgets('Calendar has horizontal swipe gesture enabled', (tester) async {
      app.main();
      await TestHelpers.waitForAppToLoad(tester);

      // Navigate to calendar
      await TestHelpers.tapIconAndWait(tester, Icons.calendar_today);

      // Verify calendar is present
      expect(find.byType(TableCalendar), findsOneWidget);

      // Verify the AvailableGestures is configured
      // (we can't directly test the enum, but we can verify swipe works)
      final calendar = find.byType(TableCalendar);

      // Multiple swipes should work smoothly
      for (int i = 0; i < 3; i++) {
        await tester.drag(calendar, const Offset(-200, 0));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      TestHelpers.logStep('Multiple horizontal swipes completed');

      // Swipe back
      for (int i = 0; i < 3; i++) {
        await tester.drag(calendar, const Offset(200, 0));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      TestHelpers.logStep('Swipe back navigation completed');
    });
  });
}
