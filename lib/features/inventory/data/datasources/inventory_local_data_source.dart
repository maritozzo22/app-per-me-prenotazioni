import 'package:sqflite/sqflite.dart';
import 'package:app_prenotazioni/core/database/database_schema.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_item_model.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_movement_model.dart';

/// Data source for inventory SQLite operations
class InventoryLocalDataSource {
  final Database _db;

  InventoryLocalDataSource(this._db);

  /// Get all inventory items, sorted by expiry date (soonest first) then name
  Future<List<InventoryItemModel>> getAllItems() async {
    // Items with expiry dates come first (soonest), then items without expiry
    final results = await _db.rawQuery('''
      SELECT * FROM ${DatabaseSchema.tableInventoryItems}
      ORDER BY
        CASE
          WHEN ${DatabaseSchema.inventoryItemExpiryDate} IS NULL THEN 1
          ELSE 0
        END,
        ${DatabaseSchema.inventoryItemExpiryDate} ASC,
        ${DatabaseSchema.inventoryItemName} ASC
    ''');

    return results
        .map((json) => InventoryItemModel.fromJson(json))
        .toList();
  }

  /// Get single item by ID
  Future<InventoryItemModel?> getItemById(String id) async {
    final results = await _db.query(
      DatabaseSchema.tableInventoryItems,
      where: '${DatabaseSchema.inventoryItemId} = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return InventoryItemModel.fromJson(results.first);
  }

  /// Add new item to database
  Future<void> addItem(InventoryItemModel item) async {
    await _db.insert(
      DatabaseSchema.tableInventoryItems,
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update existing item
  Future<void> updateItem(InventoryItemModel item) async {
    await _db.update(
      DatabaseSchema.tableInventoryItems,
      item.toJson(),
      where: '${DatabaseSchema.inventoryItemId} = ?',
      whereArgs: [item.id],
    );
  }

  /// Delete item (cascades to movements via foreign key)
  Future<void> deleteItem(String id) async {
    await _db.delete(
      DatabaseSchema.tableInventoryItems,
      where: '${DatabaseSchema.inventoryItemId} = ?',
      whereArgs: [id],
    );
  }

  /// Get movements for a specific item (per D-09)
  Future<List<InventoryMovementModel>> getMovementsByItemId(String itemId) async {
    final results = await _db.query(
      DatabaseSchema.tableInventoryMovements,
      where: '${DatabaseSchema.inventoryMovementItemId} = ?',
      whereArgs: [itemId],
      orderBy: '${DatabaseSchema.inventoryMovementDate} DESC',
    );

    return results
        .map((json) => InventoryMovementModel.fromJson(json))
        .toList();
  }

  /// Add movement and update item quantity atomically (per D-07, D-08)
  ///
  /// Uses transaction to ensure consistency: both operations succeed or both fail.
  Future<void> addMovement(
    InventoryMovementModel movement,
    int newQuantity,
  ) async {
    await _db.transaction((txn) async {
      // Insert movement record
      await txn.insert(
        DatabaseSchema.tableInventoryMovements,
        movement.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update item quantity
      await txn.update(
        DatabaseSchema.tableInventoryItems,
        {
          DatabaseSchema.inventoryItemQuantity: newQuantity,
          DatabaseSchema.inventoryItemUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '${DatabaseSchema.inventoryItemId} = ?',
        whereArgs: [movement.itemId],
      );
    });
  }

  /// Delete all movements for an item
  Future<void> deleteMovementsByItemId(String itemId) async {
    await _db.delete(
      DatabaseSchema.tableInventoryMovements,
      where: '${DatabaseSchema.inventoryMovementItemId} = ?',
      whereArgs: [itemId],
    );
  }
}
