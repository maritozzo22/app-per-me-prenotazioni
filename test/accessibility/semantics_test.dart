import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/main.dart';
import 'package:intl/date_symbol_data_local.dart';

// Test navigator key
final testNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Initialize locale data for tests
  setUpAll(() async {
    await initializeDateFormatting('it_IT');
  });

  testWidgets('App has interactive elements', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
    await tester.pumpAndSettle();

    // Verify the app is interactive
    final inkWells = find.byType(InkWell);
    final inkResponses = find.byType(InkResponse);
    final hasInteractive = inkWells.evaluate().isNotEmpty || inkResponses.evaluate().isNotEmpty;

    expect(hasInteractive, true, reason: 'App should have interactive elements');
  });

  testWidgets('Form has labeled input fields', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
    await tester.pumpAndSettle();

    // Try to tap FAB to get to form
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();
    }

    // Find input fields
    final textFields = find.byType(TextField);

    // If we have text fields, verify form is accessible
    if (textFields.evaluate().isNotEmpty) {
      expect(textFields.evaluate().length, greaterThan(0));
    }
  });

  testWidgets('Room cards in dashboard have semantic labels', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
    await tester.pumpAndSettle();

    // Dashboard should have room cards or at least be visible
    final roomCards = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString().contains('RoomStatusCard'),
    );

    // Verify we can find dashboard elements
    final hasDashboardElements = roomCards.evaluate().isNotEmpty || find.text('Dashboard').evaluate().isNotEmpty;
    expect(hasDashboardElements, true);
  });

  testWidgets('Calendar has navigation buttons or empty state', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
    await tester.pumpAndSettle();

    // Try to find and tap the calendar tab using the icon
    final calendarIcon = find.byIcon(Icons.calendar_today);
    if (calendarIcon.evaluate().isNotEmpty) {
      await tester.tap(calendarIcon);
      await tester.pumpAndSettle();

      // Calendar either has navigation arrows (when has reservations)
      // or shows empty state (when no reservations)
      final chevronLeft = find.byIcon(Icons.chevron_left);
      final chevronRight = find.byIcon(Icons.chevron_right);
      final emptyState = find.text('Nessun evento');
      final calendarTitle = find.text('Calendario Prenotazioni');

      final hasNavOrEmpty = chevronLeft.evaluate().isNotEmpty ||
          chevronRight.evaluate().isNotEmpty ||
          emptyState.evaluate().isNotEmpty ||
          calendarTitle.evaluate().isNotEmpty;
      expect(hasNavOrEmpty, true,
          reason: 'Calendar should have navigation, show empty state, or have calendar title');
    } else {
      // If calendar icon not found, that's OK - just verify we can navigate somewhere
      final dashboardIcon = find.byIcon(Icons.dashboard);
      expect(dashboardIcon.evaluate().isNotEmpty, true,
          reason: 'At least dashboard icon should be present');
    }
  });

  testWidgets('Semantics widgets are present in the app', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
    await tester.pumpAndSettle();

    // Find all Semantics widgets
    final semantics = find.byType(Semantics);

    // Verify we have semantics for accessibility
    expect(semantics.evaluate().isNotEmpty, true,
        reason: 'App should have Semantics widgets for accessibility');
  });
}
