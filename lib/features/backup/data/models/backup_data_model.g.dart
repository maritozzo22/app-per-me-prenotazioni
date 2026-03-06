// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BackupDataModelImpl _$$BackupDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$BackupDataModelImpl(
  version: json['version'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  reservations: (json['reservations'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  platforms: (json['platforms'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  rooms: (json['rooms'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  backupType: json['backupType'] as String? ?? 'manual',
);

Map<String, dynamic> _$$BackupDataModelImplToJson(
  _$BackupDataModelImpl instance,
) => <String, dynamic>{
  'version': instance.version,
  'timestamp': instance.timestamp.toIso8601String(),
  'reservations': instance.reservations,
  'platforms': instance.platforms,
  'rooms': instance.rooms,
  'backupType': instance.backupType,
};
