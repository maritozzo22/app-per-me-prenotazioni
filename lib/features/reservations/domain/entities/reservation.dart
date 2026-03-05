import 'package:app_prenotazioni/features/reservations/domain/entities/guest.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Represents a reservation for a room.
class Reservation {
  final String id;
  final String roomId;
  final String platformId;
  final Guest guest;
  final DateTime checkIn;
  final DateTime checkOut;
  final double? amount;
  final PaymentStatus paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reservation({
    required this.id,
    required this.roomId,
    required this.platformId,
    required this.guest,
    required this.checkIn,
    required this.checkOut,
    this.amount,
    this.paymentStatus = PaymentStatus.pending,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculates the number of nights for this reservation.
  int get numberOfNights => checkOut.difference(checkIn).inDays;

  /// Checks if this reservation overlaps with a given date range.
  ///
  /// Returns true if there is any overlap between the reservation dates
  /// and the provided range. Note: Adjacent dates (where check-out equals
  /// the provided start, or check-in equals the provided end) do NOT
  /// count as overlapping, allowing same-day turnarounds.
  bool overlapsWith(DateTime otherStart, DateTime otherEnd) {
    // A reservation overlaps if:
    // checkIn < otherEnd AND checkOut > otherStart
    // This allows adjacent reservations (check-out = otherStart is OK)
    return checkIn.isBefore(otherEnd) && checkOut.isAfter(otherStart);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation &&
        other.id == id &&
        other.roomId == roomId &&
        other.platformId == platformId &&
        other.guest == guest &&
        other.checkIn == checkIn &&
        other.checkOut == checkOut &&
        other.amount == amount &&
        other.paymentStatus == paymentStatus &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        roomId,
        platformId,
        guest,
        checkIn,
        checkOut,
        amount,
        paymentStatus,
        notes,
        createdAt,
        updatedAt,
      );
}
