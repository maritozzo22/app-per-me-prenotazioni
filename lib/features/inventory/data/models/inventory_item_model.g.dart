// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryItemModelImpl _$$InventoryItemModelImplFromJson(
  Map<String, dynamic> json,
) => _$InventoryItemModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  quantity: (json['quantity'] as num).toInt(),
  expiryDate: json['expiryDate'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$$InventoryItemModelImplToJson(
  _$InventoryItemModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'quantity': instance.quantity,
  'expiryDate': instance.expiryDate,
  'notes': instance.notes,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
