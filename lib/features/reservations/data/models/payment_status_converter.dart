import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';
import 'package:json_annotation/json_annotation.dart';

class PaymentStatusConverter implements JsonConverter<PaymentStatus, String> {
  const PaymentStatusConverter();

  @override
  PaymentStatus fromJson(String json) =>
      PaymentStatus.values.firstWhere((e) => e.name == json, orElse: () => PaymentStatus.pending);

  @override
  String toJson(PaymentStatus object) => object.name;
}
