import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';

/// Repository interface for reservation data access.
abstract class ReservationRepository {
  /// Gets all reservations.
  Future<List<Reservation>> getAllReservations();

  /// Gets a reservation by ID.
  Future<Reservation?> getReservationById(String id);

  /// Saves a reservation (insert or update).
  Future<void> saveReservation(Reservation reservation);

  /// Deletes a reservation by ID.
  Future<void> deleteReservation(String id);

  /// Gets reservations that overlap with a date range.
  Future<List<Reservation>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  );

  /// Gets all rooms.
  Future<List<Room>> getAllRooms();

  /// Gets all platforms.
  Future<List<BookingPlatform>> getAllPlatforms();

  /// Inserts multiple reservations in a batch for performance.
  Future<void> insertReservationsBatch(List<Reservation> reservations);
}
