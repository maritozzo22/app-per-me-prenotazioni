import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

part 'inventory_item_model.freezed.dart';
part 'inventory_item_model.g.dart';

/// Database model for inventory items
@freezed
class InventoryItemModel with _$InventoryItemModel {
  const factory InventoryItemModel({
    required String id,
    required String name,
    required String category, // Stored as string enum value
    required int quantity,
    String? expiryDate, // ISO8601 string or null
    String? notes,
    required String createdAt,
    String? updatedAt,
  }) = _InventoryItemModel;

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemModelFromJson(json);

  const InventoryItemModel._();

  /// Convert from domain entity to database model
  factory InventoryItemModel.fromDomain(InventoryItem entity) {
    return InventoryItemModel(
      id: entity.id,
      name: entity.name,
      category: entity.category.name,
      quantity: entity.quantity,
      expiryDate: entity.expiryDate?.toIso8601String(),
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  /// Convert to domain entity
  InventoryItem toDomain() {
    return InventoryItem(
      id: id,
      name: name,
      category: _parseCategory(category),
      quantity: quantity,
      expiryDate: expiryDate != null ? DateTime.parse(expiryDate!) : null,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Parse category string to enum
  InventoryCategory _parseCategory(String value) {
    return InventoryCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InventoryCategory.altro,
    );
  }
}
