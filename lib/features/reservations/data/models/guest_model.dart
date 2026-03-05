import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';

part 'guest_model.freezed.dart';
part 'guest_model.g.dart';

/// Data model for Guest with JSON serialization.
@freezed
class GuestModel with _$GuestModel {
  const factory GuestModel({
    required String name,
    String? phone,
  }) = _GuestModel;

  factory GuestModel.fromJson(Map<String, dynamic> json) =>
      _$GuestModelFromJson(json);
}

/// Extension to convert GuestModel to domain entity.
extension GuestModelX on GuestModel {
  Guest toEntity() => Guest(name: name, phone: phone);
}

/// Extension to create GuestModel from domain entity.
extension GuestX on Guest {
  GuestModel toModel() => GuestModel(name: name, phone: phone);
}
