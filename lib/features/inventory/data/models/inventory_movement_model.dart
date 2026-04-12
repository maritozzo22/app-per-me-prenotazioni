import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';

part 'inventory_movement_model.freezed.dart';
part 'inventory_movement_model.g.dart';

/// Database model for inventory movements
@freezed
class InventoryMovementModel with _$InventoryMovementModel {
  const factory InventoryMovementModel({
    required String id,
    required String itemId,
    required int delta,
    required String date, // ISO8601 string
    required String createdAt,
  }) = _InventoryMovementModel;

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementModelFromJson(json);

  const InventoryMovementModel._();

  /// Convert from domain entity to database model
  factory InventoryMovementModel.fromDomain(InventoryMovement entity) {
    return InventoryMovementModel(
      id: entity.id,
      itemId: entity.itemId,
      delta: entity.delta,
      date: entity.date.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  /// Convert to domain entity
  InventoryMovement toDomain() {
    return InventoryMovement(
      id: id,
      itemId: itemId,
      delta: delta,
      date: DateTime.parse(date),
      createdAt: DateTime.parse(createdAt),
    );
  }
}
