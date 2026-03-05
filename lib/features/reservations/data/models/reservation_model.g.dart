// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationModelImpl _$$ReservationModelImplFromJson(
  Map<String, dynamic> json,
) => _$ReservationModelImpl(
  id: json['id'] as String,
  roomId: json['roomId'] as String,
  platformId: json['platformId'] as String,
  guest: GuestModel.fromJson(json['guest'] as Map<String, dynamic>),
  checkIn: DateTime.parse(json['checkIn'] as String),
  checkOut: DateTime.parse(json['checkOut'] as String),
  amount: (json['amount'] as num?)?.toDouble(),
  paymentStatus: json['paymentStatus'] == null
      ? PaymentStatus.pending
      : const PaymentStatusConverter().fromJson(
          json['paymentStatus'] as String,
        ),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$ReservationModelImplToJson(
  _$ReservationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'roomId': instance.roomId,
  'platformId': instance.platformId,
  'guest': instance.guest.toJson(),
  'checkIn': instance.checkIn.toIso8601String(),
  'checkOut': instance.checkOut.toIso8601String(),
  'amount': instance.amount,
  'paymentStatus': const PaymentStatusConverter().toJson(
    instance.paymentStatus,
  ),
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
