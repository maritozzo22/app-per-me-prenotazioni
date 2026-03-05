/// Result of a validation check.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? details;

  const ValidationResult.success()
      : isValid = true,
        errorMessage = null,
        details = null;

  const ValidationResult.failure(this.errorMessage, {this.details})
      : isValid = false;

  bool get isInvalid => !isValid;
}

/// Specific validation errors for reservations.
enum ReservationValidationError {
  checkOutBeforeCheckIn,
  dateOverlap,
  apartmentBlocked,
  apartmentBlocksRooms,
}
