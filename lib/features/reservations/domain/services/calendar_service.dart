import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

/// Service for calendar-related business logic.
class CalendarService {
  /// Groups reservations by date, adding each reservation to every day
  /// in its date range (from check-in to check-out, exclusive).
  ///
  /// Returns a map where keys are normalized dates (time stripped) and
  /// values are lists of reservations active on that day.
  Map<DateTime, List<Reservation>> groupReservationsByDate(
    List<Reservation> reservations,
  ) {
    final map = <DateTime, List<Reservation>>{};

    for (final reservation in reservations) {
      // Add reservation to each day in its range
      var current = reservation.checkIn;
      // Stop before checkOut (check-out day is not occupied)
      while (current.isBefore(reservation.checkOut)) {
        // Normalize to midnight to avoid time component issues
        final day = DateTime(current.year, current.month, current.day);

        map[day] = [...map[day] ?? [], reservation];
        current = current.add(const Duration(days: 1));
      }
    }

    return map;
  }
}
