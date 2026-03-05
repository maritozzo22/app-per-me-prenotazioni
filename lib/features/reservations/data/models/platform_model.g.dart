// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlatformModelImpl _$$PlatformModelImplFromJson(Map<String, dynamic> json) =>
    _$PlatformModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: (json['colorValue'] as num).toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PlatformModelImplToJson(_$PlatformModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'colorValue': instance.colorValue,
      'isDefault': instance.isDefault,
      'isSystem': instance.isSystem,
      'createdAt': instance.createdAt.toIso8601String(),
    };
