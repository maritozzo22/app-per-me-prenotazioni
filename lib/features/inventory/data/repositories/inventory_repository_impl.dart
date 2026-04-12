import 'package:uuid/uuid.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';
import 'package:app_prenotazioni/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:app_prenotazioni/features/inventory/data/datasources/inventory_local_data_source.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_item_model.dart';
import 'package:app_prenotazioni/features/inventory/data/models/inventory_movement_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  InventoryRepositoryImpl(this._dataSource);

  @override
  Future<List<InventoryItem>> getAllItems() async {
    final models = await _dataSource.getAllItems();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<InventoryItem?> getItemById(String id) async {
    final model = await _dataSource.getItemById(id);
    return model?.toDomain();
  }

  @override
  Future<void> addItem(InventoryItem item) async {
    final model = InventoryItemModel.fromDomain(item);
    await _dataSource.addItem(model);
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    final model = InventoryItemModel.fromDomain(
      item.copyWith(updatedAt: DateTime.now()),
    );
    await _dataSource.updateItem(model);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dataSource.deleteItem(id);
  }

  @override
  Future<List<InventoryMovement>> getMovementsByItemId(String itemId) async {
    final models = await _dataSource.getMovementsByItemId(itemId);
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> addMovement(String itemId, int delta) async {
    // Create movement record
    final now = DateTime.now();
    final movement = InventoryMovement(
      id: _uuid.v4(),
      itemId: itemId,
      delta: delta,
      date: now,
      createdAt: now,
    );

    // Get current item to calculate new quantity
    final item = await getItemById(itemId);
    if (item == null) {
      throw Exception('Item not found: $itemId');
    }

    final newQuantity = item.quantity + delta;

    // Create movement model and update atomically
    final movementModel = InventoryMovementModel.fromDomain(movement);
    await _dataSource.addMovement(movementModel, newQuantity);
  }
}
