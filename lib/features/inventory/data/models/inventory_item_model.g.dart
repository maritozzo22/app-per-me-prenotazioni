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
  expiryDate: json['expiry_date'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$$InventoryItemModelImplToJson(
  _$InventoryItemModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'quantity': instance.quantity,
  'expiry_date': instance.expiryDate,
  'notes': instance.notes,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
