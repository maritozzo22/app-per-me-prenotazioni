// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryMovementImpl _$$InventoryMovementImplFromJson(
  Map<String, dynamic> json,
) => _$InventoryMovementImpl(
  id: json['id'] as String,
  itemId: json['itemId'] as String,
  delta: (json['delta'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$InventoryMovementImplToJson(
  _$InventoryMovementImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'itemId': instance.itemId,
  'delta': instance.delta,
  'date': instance.date.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
