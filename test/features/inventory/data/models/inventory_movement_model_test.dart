import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_movement_model.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';

void main() {
  group('InventoryMovementModel', () {
    final now = DateTime(2026, 4, 12);

    test('converts from domain entity', () {
      final entity = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now,
        createdAt: now,
      );

      final model = InventoryMovementModel.fromDomain(entity);

      expect(model.id, equals('1'));
      expect(model.itemId, equals('item-1'));
      expect(model.delta, equals(5));
      expect(model.date, equals(now.toIso8601String()));
    });

    test('converts to domain entity', () {
      final model = InventoryMovementModel(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now.toIso8601String(),
        createdAt: now.toIso8601String(),
      );

      final entity = model.toDomain();

      expect(entity.id, equals('1'));
      expect(entity.itemId, equals('item-1'));
      expect(entity.delta, equals(5));
    });

    test('handles negative delta per D-10', () {
      final entity = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: -2,
        date: now,
        createdAt: now,
      );

      final model = InventoryMovementModel.fromDomain(entity);
      expect(model.delta, equals(-2));

      final restored = model.toDomain();
      expect(restored.delta, equals(-2));
    });

    test('round-trips domain entity', () {
      final original = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now,
        createdAt: now,
      );

      final model = InventoryMovementModel.fromDomain(original);
      final restored = model.toDomain();

      expect(restored.id, equals(original.id));
      expect(restored.itemId, equals(original.itemId));
      expect(restored.delta, equals(original.delta));
    });
  });
}
