import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';

void main() {
  group('InventoryMovement', () {
    final now = DateTime(2026, 4, 12);

    test('creates with all required fields', () {
      final movement = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now,
        createdAt: now,
      );

      expect(movement.itemId, equals('item-1'));
      expect(movement.delta, equals(5));
      expect(movement.date, equals(now));
    });

    test('isPositive for positive delta', () {
      final movement = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now,
        createdAt: now,
      );

      expect(movement.isPositive, isTrue);
      expect(movement.isNegative, isFalse);
    });

    test('isNegative for negative delta (loss tracking per D-10)', () {
      final movement = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: -2,
        date: now,
        createdAt: now,
      );

      expect(movement.isPositive, isFalse);
      expect(movement.isNegative, isTrue);
    });

    test('deltaDisplay formats with sign', () {
      final positive = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now,
        createdAt: now,
      );

      final negative = InventoryMovement(
        id: '2',
        itemId: 'item-1',
        delta: -2,
        date: now,
        createdAt: now,
      );

      expect(positive.deltaDisplay, equals('+5'));
      expect(negative.deltaDisplay, equals('-2'));
    });

    test('description returns correct text', () {
      final positive = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now,
        createdAt: now,
      );

      final negative = InventoryMovement(
        id: '2',
        itemId: 'item-1',
        delta: -2,
        date: now,
        createdAt: now,
      );

      expect(positive.description, equals('Aggiunti 5'));
      expect(negative.description, equals('Rimossi 2'));
    });

    test('serializes to and from JSON', () {
      final original = InventoryMovement(
        id: '1',
        itemId: 'item-1',
        delta: 5,
        date: now,
        createdAt: now,
      );

      final json = original.toJson();
      final restored = InventoryMovement.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.itemId, equals(original.itemId));
      expect(restored.delta, equals(original.delta));
    });
  });
}
