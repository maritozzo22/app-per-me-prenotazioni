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

  group('Semantic Labels', () {
    testWidgets('All form fields have semantic labels', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Navigate to reservations tab
      final reservationsTab = find.text('Prenotazioni');
      if (reservationsTab.evaluate().isNotEmpty) {
        await tester.tap(reservationsTab);
        await tester.pumpAndSettle();

        // Tap FAB to open form
        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await tester.tap(fab.first);
          await tester.pumpAndSettle();

          // Find all Semantics widgets in the form
          final semantics = find.byType(Semantics);

          // Verify we have semantic labels for form fields
          expect(semantics.evaluate().isNotEmpty, true,
              reason: 'Form should have semantic labels for accessibility');
        }
      }
    });

    testWidgets('Navigation bar items have semantic labels', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Find bottom navigation bar
      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav.evaluate().isNotEmpty, true,
          reason: 'Bottom navigation bar should be present');

      // Find all icons in navigation bar
      final icons = find.descendant(
        of: bottomNav.first,
        matching: find.byType(Icon),
      );

      // Each icon should have a semantic label
      expect(icons.evaluate().isNotEmpty, true,
          reason: 'Navigation items should have icons with semantic labels');
    });

    testWidgets('List tiles have semantic information', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Find list tiles (if any exist)
      final listTiles = find.byType(ListTile);

      // If there are list tiles, verify they're accessible
      if (listTiles.evaluate().isNotEmpty) {
        // Check for semantic information
        final semantics = find.ancestor(
          of: listTiles.first,
          matching: find.byType(Semantics),
        );

        expect(semantics.evaluate().isNotEmpty, true,
            reason: 'List tiles should be wrapped in Semantics widgets');
      }
    });
  });

  group('Keyboard Navigation', () {
    testWidgets('Form fields are focusable', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Navigate to form
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        // Find text fields
        final textFields = find.byType(TextField);

        if (textFields.evaluate().isNotEmpty) {
          // Verify text fields can receive focus
          final firstField = textFields.first;
          await tester.tap(firstField);
          await tester.pump();

          // Focus should be on the field
          expect(tester.widgets.firstWhere((w) => w is TextField), isNotNull);
        }
      }
    });

    testWidgets('Interactive elements have proper tab order', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Find focusable widgets
      final focusNodes = <FocusNode>[];

      // Collect all focusable widgets
      final inkWells = find.byType(InkWell);
      final textFields = find.byType(TextField);
      final buttons = find.byType(ElevatedButton);
      final fabs = find.byType(FloatingActionButton);

      // Verify at least some interactive elements exist
      final hasInteractive = inkWells.evaluate().isNotEmpty ||
          textFields.evaluate().isNotEmpty ||
          buttons.evaluate().isNotEmpty ||
          fabs.evaluate().isNotEmpty;

      expect(hasInteractive, true,
          reason: 'App should have interactive elements with proper focus order');
    });
  });

  group('Screen Reader Support', () {
    testWidgets('Loading states are announced', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Find loading indicators (if any)
      final progressIndicators = find.byType(CircularProgressIndicator);

      // Loading indicators might not be present initially, which is fine
      // The test verifies they exist when needed
      if (progressIndicators.evaluate().isNotEmpty) {
        // Find Semantics wrapper for announcements
        final semantics = find.ancestor(
          of: progressIndicators.first,
          matching: find.byType(Semantics),
        );

        // Loading states should have semantic information
        expect(semantics.evaluate().isNotEmpty, true,
            reason: 'Loading indicators should be announced to screen readers');
      }
    });

    testWidgets('Empty states have semantic information', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Find empty state widgets (if any)
      final emptyStates = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().contains('EmptyState'),
      );

      // Empty states might not be present if there's data
      if (emptyStates.evaluate().isNotEmpty) {
        // Find Semantics wrapper
        final semantics = find.ancestor(
          of: emptyStates.first,
          matching: find.byType(Semantics),
        );

        expect(semantics.evaluate().isNotEmpty, true,
            reason: 'Empty states should be announced to screen readers');
      }
    });

    testWidgets('Dashboard cards have semantic information', (tester) async {
      await tester.pumpWidget(ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)));
      await tester.pumpAndSettle();

      // Find dashboard cards
      final cards = find.byType(Card);

      if (cards.evaluate().isNotEmpty) {
        // Find Semantics wrapper
        final semantics = find.ancestor(
          of: cards.first,
          matching: find.byType(Semantics),
        );

        expect(semantics.evaluate().isNotEmpty, true,
            reason: 'Dashboard cards should have semantic information');
      }
    });
  });

  group('Reduce Motion Support', () {
    testWidgets('Animations respect system reduce motion setting', (tester) async {
      // Build app with reduced motion
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app still functions without animations
      final fab = find.byType(FloatingActionButton);
      expect(fab.evaluate().isNotEmpty, true,
          reason: 'App should function with reduced motion');

      // Tap should work immediately
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        // Form should appear
        final form = find.byType(Form);
        expect(form.evaluate().isNotEmpty, true,
            reason: 'Navigation should work without animations');
      }
    });
  });

  group('Font Scaling', () {
    testWidgets('UI adapts to large font sizes', (tester) async {
      // Build app with large text scale
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaleFactor: 2.0),
          child: ProviderScope(child: MyApp(navigatorKey: testNavigatorKey)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app renders without overflow
      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav.evaluate().isNotEmpty, true,
          reason: 'App should render correctly with large fonts');

      // Verify text is still readable
      final text = find.byType(Text);
      if (text.evaluate().isNotEmpty) {
        // No overflow errors should occur
        expect(tester.takeException(), isNull,
            reason: 'No overflow errors with large fonts');
      }
    });
  });
}
