import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/inventory_movement_history_sheet.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';

void main() {
  group('InventoryMovementHistorySheet', () {
    final now = DateTime(2026, 4, 12, 10, 30);

    testWidgets('shows title and movements', (tester) async {
      final movements = [
        InventoryMovement(
          id: '1',
          itemId: 'item-1',
          delta: 5,
          date: now,
          createdAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventoryMovementHistorySheet(movements: movements),
          ),
        ),
      );

      expect(find.text('Storico Movimenti'), findsOneWidget);
      expect(find.text('+5'), findsOneWidget);
    });

    testWidgets('shows empty state when no movements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const InventoryMovementHistorySheet(movements: []),
          ),
        ),
      );

      expect(find.text('Nessun movimento registrato'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('shows positive delta in green', (tester) async {
      final movements = [
        InventoryMovement(
          id: '1',
          itemId: 'item-1',
          delta: 5,
          date: now,
          createdAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventoryMovementHistorySheet(movements: movements),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('+5'));
      expect(textWidget.style?.color, equals(Colors.green));
    });

    testWidgets('shows negative delta in red', (tester) async {
      final movements = [
        InventoryMovement(
          id: '1',
          itemId: 'item-1',
          delta: -2,
          date: now,
          createdAt: now,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventoryMovementHistorySheet(movements: movements),
          ),
        ),
      );

      expect(find.text('-2'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('-2'));
      expect(textWidget.style?.color, equals(Colors.red));
    });
  });
}
