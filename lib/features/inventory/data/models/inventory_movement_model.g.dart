// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryMovementModelImpl _$$InventoryMovementModelImplFromJson(
  Map<String, dynamic> json,
) => _$InventoryMovementModelImpl(
  id: json['id'] as String,
  itemId: json['itemId'] as String,
  delta: (json['delta'] as num).toInt(),
  date: json['date'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$InventoryMovementModelImplToJson(
  _$InventoryMovementModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'itemId': instance.itemId,
  'delta': instance.delta,
  'date': instance.date,
  'createdAt': instance.createdAt,
};
