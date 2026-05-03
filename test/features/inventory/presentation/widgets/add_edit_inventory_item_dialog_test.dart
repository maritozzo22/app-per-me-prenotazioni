import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/add_edit_inventory_item_dialog.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

void main() {
  group('AddEditInventoryItemDialog', () {
    final now = DateTime(2026, 4, 12);

    testWidgets('shows all form fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AddEditInventoryItemDialog(
                onSubmit: ({
                  required String name,
                  required InventoryCategory category,
                  required int quantity,
                  DateTime? expiryDate,
                  String? notes,
                }) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nome *'), findsOneWidget);
      expect(find.text('Categoria *'), findsOneWidget);
      expect(find.text('Quantità *'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets('shows expiry field only for Alimentari', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AddEditInventoryItemDialog(
                onSubmit: ({
                  required String name,
                  required InventoryCategory category,
                  required int quantity,
                  DateTime? expiryDate,
                  String? notes,
                }) {},
              ),
            ),
          ),
        ),
      );

      // Initially no expiry field (no category selected)
      expect(find.text('Data scadenza *'), findsNothing);

      // Select Alimentari
      await tester.tap(find.text('Categoria *'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alimentari').last);
      await tester.pumpAndSettle();

      expect(find.text('Data scadenza *'), findsOneWidget);
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AddEditInventoryItemDialog(
                onSubmit: ({
                  required String name,
                  required InventoryCategory category,
                  required int quantity,
                  DateTime? expiryDate,
                  String? notes,
                }) {},
              ),
            ),
          ),
        ),
      );

      // Try to submit without filling form
      await tester.tap(find.text('Aggiungi'));
      await tester.pumpAndSettle();

      expect(find.text('Inserisci un nome'), findsOneWidget);
    });

    testWidgets('pre-fills data in edit mode', (tester) async {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        notes: 'Penne rigate',
        createdAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AddEditInventoryItemDialog(
                item: item,
                onSubmit: ({
                  required String name,
                  required InventoryCategory category,
                  required int quantity,
                  DateTime? expiryDate,
                  String? notes,
                }) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Penne rigate'), findsOneWidget);
    });
  });
}
