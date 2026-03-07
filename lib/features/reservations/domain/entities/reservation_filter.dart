import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Filter criteria for querying reservations.
class ReservationFilter {
  final String? platformId;
  final String? roomId;
  final DateTime? startDate;
  final DateTime? endDate;
  final PaymentStatus? paymentStatus;

  const ReservationFilter({
    this.platformId,
    this.roomId,
    this.startDate,
    this.endDate,
    this.paymentStatus,
  });

  /// Returns true if all filter criteria are null.
  bool get isEmpty =>
      platformId == null &&
      roomId == null &&
      startDate == null &&
      endDate == null &&
      paymentStatus == null;

  /// Converts filter to a map for persistence.
  ///
  /// Only includes non-null values to minimize storage size.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (platformId != null) map['platformId'] = platformId;
    if (roomId != null) map['roomId'] = roomId;
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (endDate != null) map['endDate'] = endDate!.toIso8601String();
    if (paymentStatus != null) map['paymentStatus'] = paymentStatus!.name;
    return map;
  }

  /// Creates filter from persisted map.
  static ReservationFilter fromMap(Map<String, dynamic> map) {
    return ReservationFilter(
      platformId: map['platformId'] as String?,
      roomId: map['roomId'] as String?,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      paymentStatus: map['paymentStatus'] != null
          ? PaymentStatus.values.firstWhere(
              (e) => e.name == map['paymentStatus'],
              orElse: () => PaymentStatus.pending,
            )
          : null,
    );
  }
}
