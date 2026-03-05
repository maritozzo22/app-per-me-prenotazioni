import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

part 'platform_model.freezed.dart';
part 'platform_model.g.dart';

/// Data model for BookingPlatform with JSON serialization.
/// Color is stored as an integer value.
@freezed
class PlatformModel with _$PlatformModel {
  const factory PlatformModel({
    required String id,
    required String name,
    required int colorValue,
    @Default(false) bool isDefault,
    required DateTime createdAt,
  }) = _PlatformModel;

  factory PlatformModel.fromJson(Map<String, dynamic> json) =>
      _$PlatformModelFromJson(json);
}

/// Extension to convert PlatformModel to domain entity.
extension PlatformModelX on PlatformModel {
  BookingPlatform toEntity() => BookingPlatform(
        id: id,
        name: name,
        color: Color(colorValue),
        isDefault: isDefault,
        createdAt: createdAt,
      );
}

/// Extension to create PlatformModel from domain entity.
extension BookingPlatformX on BookingPlatform {
  PlatformModel toModel() => PlatformModel(
        id: id,
        name: name,
        colorValue: color.value,
        isDefault: isDefault,
        createdAt: createdAt,
      );
}
