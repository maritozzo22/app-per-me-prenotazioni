import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

void main() {
  group('InventoryItemCard', () {
    final now = DateTime(2026, 4, 12);

    testWidgets('displays item name and category', (tester) async {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        createdAt: now,
      );

      bool tapped = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InventoryItemCard(
                item: item,
                onTap: () => tapped = true,
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Alimentari'), findsOneWidget);
      expect(find.text('Qty: 5'), findsOneWidget);
    });

    testWidgets('shows Mancano for negative quantity', (tester) async {
      final item = InventoryItem(
        id: '1',
        name: 'Asciugamani',
        category: InventoryCategory.tessili,
        quantity: -2,
        createdAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InventoryItemCard(
                item: item,
                onTap: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Qty: Mancano: 2'), findsOneWidget);
    });

    testWidgets('triggers callbacks', (tester) async {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        createdAt: now,
      );

      bool tapped = false;
      bool edited = false;
      bool deleted = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InventoryItemCard(
                item: item,
                onTap: () => tapped = true,
                onEdit: () => edited = true,
                onDelete: () => deleted = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(tapped, isTrue);

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.edit));
      expect(edited, isTrue);

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete));
      expect(deleted, isTrue);
    });
  });
}
