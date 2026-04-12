import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';

/// Repository interface for inventory data access
abstract class InventoryRepository {
  /// Get all inventory items
  Future<List<InventoryItem>> getAllItems();

  /// Get single item by ID
  Future<InventoryItem?> getItemById(String id);

  /// Add new item
  Future<void> addItem(InventoryItem item);

  /// Update existing item
  Future<void> updateItem(InventoryItem item);

  /// Delete item (and associated movements)
  Future<void> deleteItem(String id);

  /// Get movement history for an item (per D-09)
  Future<List<InventoryMovement>> getMovementsByItemId(String itemId);

  /// Add movement record and update item quantity (per D-07, D-08)
  ///
  /// [delta] can be positive (stock added) or negative (stock lost per D-10)
  Future<void> addMovement(String itemId, int delta);
}
