// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryItemImpl _$$InventoryItemImplFromJson(Map<String, dynamic> json) =>
    _$InventoryItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$InventoryCategoryEnumMap, json['category']),
      quantity: (json['quantity'] as num).toInt(),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$InventoryItemImplToJson(_$InventoryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': _$InventoryCategoryEnumMap[instance.category]!,
      'quantity': instance.quantity,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$InventoryCategoryEnumMap = {
  InventoryCategory.alimentari: 'alimentari',
  InventoryCategory.tessili: 'tessili',
  InventoryCategory.altro: 'altro',
};
