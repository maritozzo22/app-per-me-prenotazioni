import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

/// Data model for Room with JSON serialization.
@freezed
class RoomModel with _$RoomModel {
  const factory RoomModel({
    required String id,
    required String name,
    required String type,
    required DateTime createdAt,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);
}

/// Extension to convert RoomModel to domain entity.
extension RoomModelX on RoomModel {
  Room toEntity() => Room(
        id: id,
        name: name,
        type: type == 'entireApartment'
            ? RoomType.entireApartment
            : RoomType.singleRoom,
        createdAt: createdAt,
      );
}

/// Extension to create RoomModel from domain entity.
extension RoomX on Room {
  RoomModel toModel() => RoomModel(
        id: id,
        name: name,
        type: type == RoomType.entireApartment
            ? 'entireApartment'
            : 'singleRoom',
        createdAt: createdAt,
      );
}
