import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

void main() {
  group('InventoryItem', () {
    final now = DateTime(2026, 4, 12);

    test('creates with all required fields', () {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        notes: 'Penne rigate',
        createdAt: now,
      );

      expect(item.name, equals('Pasta'));
      expect(item.category, equals(InventoryCategory.alimentari));
      expect(item.quantity, equals(5));
    });

    test('allows negative quantity per D-10', () {
      final item = InventoryItem(
        id: '1',
        name: 'Asciugamani',
        category: InventoryCategory.tessili,
        quantity: -2,
        createdAt: now,
      );

      expect(item.quantity, equals(-2));
      expect(item.isNegative, isTrue);
      expect(item.quantityDisplay, equals('Mancano: 2'));
    });

    test('quantityDisplay handles positive quantities', () {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        createdAt: now,
      );

      expect(item.quantityDisplay, equals('5'));
    });

    test('expiryStatus returns expired when date passed', () {
      final item = InventoryItem(
        id: '1',
        name: 'Latte',
        category: InventoryCategory.alimentari,
        quantity: 1,
        expiryDate: now.subtract(const Duration(days: 1)),
        createdAt: now,
      );

      expect(item.expiryStatus, equals(ExpiryStatus.expired));
    });

    test('expiryStatus returns expiringSoon within 3 days', () {
      final item = InventoryItem(
        id: '1',
        name: 'Latte',
        category: InventoryCategory.alimentari,
        quantity: 1,
        expiryDate: now.add(const Duration(days: 2)),
        createdAt: now,
      );

      expect(item.expiryStatus, equals(ExpiryStatus.expiringSoon));
    });

    test('expiryStatus returns ok when more than 3 days away', () {
      final item = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        createdAt: now,
      );

      expect(item.expiryStatus, equals(ExpiryStatus.ok));
    });

    test('expiryStatus returns notApplicable when no expiry date', () {
      final item = InventoryItem(
        id: '1',
        name: 'Asciugamani',
        category: InventoryCategory.tessili,
        quantity: 10,
        createdAt: now,
      );

      expect(item.expiryStatus, equals(ExpiryStatus.notApplicable));
    });

    test('daysUntilExpiry returns null for non-food items', () {
      final item = InventoryItem(
        id: '1',
        name: 'Asciugamani',
        category: InventoryCategory.tessili,
        quantity: 10,
        createdAt: now,
      );

      expect(item.daysUntilExpiry, isNull);
    });

    test('serializes to and from JSON', () {
      final original = InventoryItem(
        id: '1',
        name: 'Pasta',
        category: InventoryCategory.alimentari,
        quantity: 5,
        expiryDate: now.add(const Duration(days: 10)),
        notes: 'Penne',
        createdAt: now,
      );

      final json = original.toJson();
      final restored = InventoryItem.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.category, equals(original.category));
      expect(restored.quantity, equals(original.quantity));
    });
  });
}
