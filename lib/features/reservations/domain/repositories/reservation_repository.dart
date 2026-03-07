import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/paginated_result.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';

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

  /// Gets a paginated list of reservations.
  ///
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of items per page.
  ///
  /// Returns a [PaginatedResult] containing the items and pagination metadata.
  Future<PaginatedResult<Reservation>> getReservationsPaginated({
    int page = 1,
    int pageSize = 20,
  });

  /// Gets a filtered and paginated list of reservations.
  ///
  /// [filter] - Filter criteria (only non-null values are applied).
  /// [page] - Page number (1-indexed).
  /// [pageSize] - Number of items per page.
  ///
  /// Returns a [PaginatedResult] containing the filtered items and pagination metadata.
  Future<PaginatedResult<Reservation>> getReservationsFiltered({
    required ReservationFilter filter,
    int page = 1,
    int pageSize = 20,
  });
}
