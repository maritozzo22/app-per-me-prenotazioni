import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_item_model.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

void main() {
  group('InventoryItemModel', () {
    final now = DateTime(2026, 4, 12);

    test('converts from domain entity', () {
      final entity = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        notes: 'Penne',
        createdAt: now,
      );

      final model = InventoryItemModel.fromDomain(entity);

      expect(model.id, equals('1'));
      expect(model.name, equals('Pasta'));
      expect(model.category, equals('alimentari'));
      expect(model.quantity, equals(5));
      expect(model.expiryDate, isNotNull);
    });

    test('converts to domain entity', () {
      final model = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)).toIso8601String(),
        notes: 'Penne',
        createdAt: now.toIso8601String(),
      );

      final entity = model.toDomain();

      expect(entity.id, equals('1'));
      expect(entity.name, equals('Pasta'));
      expect(entity.category, equals(InventoryCategory.alimentari));
      expect(entity.quantity, equals(5));
      expect(entity.expiryDate, isNotNull);
    });

    test('handles null expiry date for non-food items', () {
      final entity = InventoryItem(
        id: '1',
        name: 'Asciugamani',
        category: InventoryCategory.tessili,
        quantity: 10,
        createdAt: now,
      );

      final model = InventoryItemModel.fromDomain(entity);
      expect(model.expiryDate, isNull);

      final restored = model.toDomain();
      expect(restored.expiryDate, isNull);
    });

    test('handles negative quantity per D-10', () {
      final entity = InventoryItem(
        id: '1',
        name: 'Asciugamani',
        category: InventoryCategory.tessili,
        quantity: -2,
        createdAt: now,
      );

      final model = InventoryItemModel.fromDomain(entity);
      expect(model.quantity, equals(-2));

      final restored = model.toDomain();
      expect(restored.quantity, equals(-2));
    });

    test('round-trips domain entity', () {
      final original = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        notes: 'Penne',
        createdAt: now,
        updatedAt: now,
      );

      final model = InventoryItemModel.fromDomain(original);
      final restored = model.toDomain();

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.category, equals(original.category));
      expect(restored.quantity, equals(original.quantity));
      expect(restored.expiryDate, equals(original.expiryDate));
    });
  });
}
