import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_prenotazioni/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_item_model.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_movement_model.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('InventoryLocalDataSource', () {
    late Database db;
    late InventoryLocalDataSource dataSource;

    setUp(() async {
      db = await openDatabase(':memory:', version: 8);
      // Create tables
      await db.execute(DatabaseSchema.createInventoryItemsTable);
      await db.execute(DatabaseSchema.createInventoryMovementsTable);
      await db.execute(DatabaseSchema.createInventoryItemsExpiryDateIndex);
      await db.execute(DatabaseSchema.createInventoryMovementsItemIndex);
      dataSource = InventoryLocalDataSource(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getAllItems returns empty list initially', () async {
      final items = await dataSource.getAllItems();
      expect(items, isEmpty);
    });

    test('addItem and getAllItems', () async {
      final model = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        expiryDate: DateTime(2026, 5, 1).toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await dataSource.addItem(model);
      final items = await dataSource.getAllItems();

      expect(items.length, equals(1));
      expect(items.first.name, equals('Pasta'));
    });

    test('updateItem modifies existing item', () async {
      final model = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        createdAt: DateTime.now().toIso8601String(),
      );

      await dataSource.addItem(model);
      await dataSource.updateItem(model.copyWith(quantity: 10));

      final items = await dataSource.getAllItems();
      expect(items.first.quantity, equals(10));
    });

    test('deleteItem removes item', () async {
      final model = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        createdAt: DateTime.now().toIso8601String(),
      );

      await dataSource.addItem(model);
      await dataSource.deleteItem('1');

      final items = await dataSource.getAllItems();
      expect(items, isEmpty);
    });

    test('addMovement updates quantity atomically', () async {
      final item = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        createdAt: DateTime.now().toIso8601String(),
      );

      await dataSource.addItem(item);

      final movement = InventoryMovementModel(
        id: 'm1',
        itemId: '1',
        delta: 3,
        date: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await dataSource.addMovement(movement, 8); // 5 + 3 = 8

      final items = await dataSource.getAllItems();
      expect(items.first.quantity, equals(8));
    });

    test('getMovementsByItemId returns movements', () async {
      final item = InventoryItemModel(
        id: '1',
        name: 'Pasta',
        category: 'alimentari',
        quantity: 5,
        createdAt: DateTime.now().toIso8601String(),
      );

      await dataSource.addItem(item);

      final movement = InventoryMovementModel(
        id: 'm1',
        itemId: '1',
        delta: 3,
        date: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
      );

      await dataSource.addMovement(movement, 8);

      final movements = await dataSource.getMovementsByItemId('1');
      expect(movements.length, equals(1));
      expect(movements.first.delta, equals(3));
    });
  });
}
