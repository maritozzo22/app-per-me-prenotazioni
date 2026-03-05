import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'validation_result.dart';

/// Service for validating reservation business rules.
class ReservationValidationService {
  final ReservationRepository _repository;

  ReservationValidationService(this._repository);

  /// Validates check-out is after check-in.
  ValidationResult validateDates(DateTime checkIn, DateTime checkOut) {
    if (!checkOut.isAfter(checkIn)) {
      return const ValidationResult.failure(
        'La data di check-out deve essere successiva al check-in',
      );
    }
    return const ValidationResult.success();
  }

  /// Checks if a room is available for the given date range.
  Future<ValidationResult> checkRoomAvailability({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    final existing = await _repository.getReservationsForDateRange(checkIn, checkOut);

    // Filter by room and exclude current reservation if editing
    final conflicting = existing
        .where((r) =>
            r.roomId == roomId &&
            r.id != excludeReservationId &&
            r.overlapsWith(checkIn, checkOut))
        .toList();

    if (conflicting.isNotEmpty) {
      final conflict = conflicting.first;
      return ValidationResult.failure(
        'Sovrapposizione date: ${conflict.roomId} già prenotata da ${conflict.guest.name} '
        '(${_formatDateRange(conflict.checkIn, conflict.checkOut)})',
        details: {'conflictingReservation': conflict},
      );
    }

    return const ValidationResult.success();
  }

  /// Checks if apartment can be booked (no individual rooms booked).
  Future<ValidationResult> checkApartmentAvailability({
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    const apartmentRoomIds = ['room-1', 'room-2', 'room-3'];
    final existing = await _repository.getReservationsForDateRange(checkIn, checkOut);

    // Find any room that conflicts
    for (final room in apartmentRoomIds) {
      final conflicting = existing
          .where((r) =>
              r.roomId == room &&
              r.id != excludeReservationId &&
              r.overlapsWith(checkIn, checkOut))
          .toList();

      if (conflicting.isNotEmpty) {
        final conflict = conflicting.first;
        return ValidationResult.failure(
          'Appartamento non disponibile: ${_getRoomName(room)} occupata '
          '${_formatDateRange(conflict.checkIn, conflict.checkOut)}',
          details: {
            'blockingRoom': room,
            'blockingReservation': conflict,
          },
        );
      }
    }

    return const ValidationResult.success();
  }

  /// Validates that booking apartment won't conflict with existing room bookings.
  /// Call this when user tries to book the apartment.
  Future<ValidationResult> validateApartmentBooking({
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    return checkApartmentAvailability(
      checkIn: checkIn,
      checkOut: checkOut,
      excludeReservationId: excludeReservationId,
    );
  }

  /// Checks if booking a room conflicts with an existing apartment booking.
  Future<ValidationResult> checkRoomAgainstApartment({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    final existing = await _repository.getReservationsForDateRange(checkIn, checkOut);

    // Check if apartment is booked for these dates
    final apartmentConflict = existing
        .where((r) =>
            r.roomId == 'apartment' &&
            r.id != excludeReservationId &&
            r.overlapsWith(checkIn, checkOut))
        .toList();

    if (apartmentConflict.isNotEmpty) {
      final conflict = apartmentConflict.first;
      return ValidationResult.failure(
        'Stanza non disponibile: Appartamento Intero prenotato '
        '${_formatDateRange(conflict.checkIn, conflict.checkOut)}',
        details: {'blockingReservation': conflict},
      );
    }

    return const ValidationResult.success();
  }

  /// Full validation for a new or updated reservation.
  Future<ValidationResult> validateReservation({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeReservationId,
  }) async {
    // 1. Check dates
    final dateResult = validateDates(checkIn, checkOut);
    if (dateResult.isInvalid) return dateResult;

    // 2. Check room availability (including apartment logic)
    if (roomId == 'apartment') {
      final apartmentResult = await validateApartmentBooking(
        checkIn: checkIn,
        checkOut: checkOut,
        excludeReservationId: excludeReservationId,
      );
      if (apartmentResult.isInvalid) return apartmentResult;
    } else {
      // Check room availability
      final roomResult = await checkRoomAvailability(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        excludeReservationId: excludeReservationId,
      );
      if (roomResult.isInvalid) return roomResult;

      // Check against apartment booking
      final apartmentResult = await checkRoomAgainstApartment(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        excludeReservationId: excludeReservationId,
      );
      if (apartmentResult.isInvalid) return apartmentResult;
    }

    return const ValidationResult.success();
  }

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  String _getRoomName(String roomId) {
    switch (roomId) {
      case 'room-1':
        return 'Stanza 1';
      case 'room-2':
        return 'Stanza 2';
      case 'room-3':
        return 'Stanza 3';
      default:
        return roomId;
    }
  }
}
