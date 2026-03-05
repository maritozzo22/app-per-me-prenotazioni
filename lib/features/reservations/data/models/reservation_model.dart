import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/reservations/data/models/guest_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/payment_status_converter.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

/// Data model for Reservation with JSON serialization.
@freezed
class ReservationModel with _$ReservationModel {
  @JsonSerializable(explicitToJson: true, converters: [
    PaymentStatusConverter(),
  ])
  const factory ReservationModel({
    required String id,
    required String roomId,
    required String platformId,
    required GuestModel guest,
    required DateTime checkIn,
    required DateTime checkOut,
    double? amount,
    @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ReservationModel;

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);
}

/// Extension to convert ReservationModel to domain entity.
extension ReservationModelX on ReservationModel {
  Reservation toEntity() => Reservation(
        id: id,
        roomId: roomId,
        platformId: platformId,
        guest: guest.toEntity(),
        checkIn: checkIn,
        checkOut: checkOut,
        amount: amount,
        paymentStatus: paymentStatus,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// Extension to create ReservationModel from domain entity.
extension ReservationX on Reservation {
  ReservationModel toModel() => ReservationModel(
        id: id,
        roomId: roomId,
        platformId: platformId,
        guest: guest.toModel(),
        checkIn: checkIn,
        checkOut: checkOut,
        amount: amount,
        paymentStatus: paymentStatus,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
