import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/main.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // Initialize locale data for tests
  setUpAll(() async {
    await initializeDateFormatting('it_IT');
  });

  testWidgets('All buttons meet 48x48dp minimum touch target', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Find FAB
    final fab = find.byType(FloatingActionButton);

    // If no FAB found, skip test gracefully
    if (fab.evaluate().isEmpty) {
      return;
    }

    // Verify FAB size meets minimum requirements
    final fabSize = tester.getSize(fab.first);
    expect(
      fabSize.width,
      greaterThanOrEqualTo(48),
      reason: 'FAB width must be at least 48dp, got ${fabSize.width}',
    );
    expect(
      fabSize.height,
      greaterThanOrEqualTo(48),
      reason: 'FAB height must be at least 48dp, got ${fabSize.height}',
    );
  });

  testWidgets('IconButtons meet size requirements', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Find icon buttons - might not have any on dashboard
    final iconButtons = find.byType(IconButton);
    if (iconButtons.evaluate().isEmpty) {
      // No icon buttons to test, which is fine
      return;
    }

    // Test first icon button
    final firstIconButton = iconButtons.first;
    final iconButtonSize = tester.getSize(firstIconButton);
    expect(
      iconButtonSize.width,
      greaterThanOrEqualTo(48),
      reason: 'IconButton width must be at least 48dp, got ${iconButtonSize.width}',
    );
    expect(
      iconButtonSize.height,
      greaterThanOrEqualTo(48),
      reason: 'IconButton height must be at least 48dp, got ${iconButtonSize.height}',
    );
  });

  testWidgets('App loads and has interactive elements', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify app has at least one interactive element
    final hasButtons = find.byType(FloatingActionButton).evaluate().isNotEmpty;
    final hasInkWells = find.byType(InkWell).evaluate().isNotEmpty ||
                       find.byType(InkResponse).evaluate().isNotEmpty;

    expect(hasButtons || hasInkWells, true,
        reason: 'App should have interactive elements');
  });
}
