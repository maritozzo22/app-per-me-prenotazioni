import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

void main() {
  group('InventoryCategory', () {
    test('has 3 values', () {
      expect(InventoryCategory.values.length, equals(3));
      expect(InventoryCategory.values, contains(InventoryCategory.alimentari));
      expect(InventoryCategory.values, contains(InventoryCategory.tessili));
      expect(InventoryCategory.values, contains(InventoryCategory.altro));
    });

    test('label returns Italian text', () {
      expect(InventoryCategory.alimentari.label, equals('Alimentari'));
      expect(InventoryCategory.tessili.label, equals('Tessili'));
      expect(InventoryCategory.altro.label, equals('Altro'));
    });

    test('hasExpiryDate is true only for alimentari', () {
      expect(InventoryCategory.alimentari.hasExpiryDate, isTrue);
      expect(InventoryCategory.tessili.hasExpiryDate, isFalse);
      expect(InventoryCategory.altro.hasExpiryDate, isFalse);
    });

    test('hasQuantity is true for all categories', () {
      expect(InventoryCategory.alimentari.hasQuantity, isTrue);
      expect(InventoryCategory.tessili.hasQuantity, isTrue);
      expect(InventoryCategory.altro.hasQuantity, isTrue);
    });
  });
}
