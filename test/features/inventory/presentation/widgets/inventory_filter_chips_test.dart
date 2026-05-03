import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/inventory_filter_chips.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

void main() {
  group('InventoryFilterChips', () {
    testWidgets('shows all filter chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InventoryFilterChips(),
            ),
          ),
        ),
      );

      expect(find.text('Tutti'), findsOneWidget);
      expect(find.text('Alimentari'), findsOneWidget);
      expect(find.text('Tessili'), findsOneWidget);
      expect(find.text('Altro'), findsOneWidget);
    });

    testWidgets('selects category chip', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InventoryFilterChips(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Alimentari'));
      await tester.pumpAndSettle();

      final filterChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Alimentari'),
          matching: find.byType(FilterChip),
        ),
      );

      expect(filterChip.selected, isTrue);
    });

    testWidgets('Tutti clears filter', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InventoryFilterChips(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Alimentari'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tutti'));
      await tester.pumpAndSettle();

      final tuttiChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('Tutti'),
          matching: find.byType(FilterChip),
        ),
      );

      expect(tuttiChip.selected, isTrue);
    });
  });
}
