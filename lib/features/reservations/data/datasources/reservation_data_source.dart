import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';

/// Abstract interface for reservation data operations.
abstract class ReservationDataSource {
  Future<List<ReservationModel>> getAllReservations();
  Future<ReservationModel?> getReservationById(String id);
  Future<void> saveReservation(ReservationModel reservation);
  Future<void> deleteReservation(String id);
  Future<List<ReservationModel>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<RoomModel>> getAllRooms();
  Future<List<PlatformModel>> getAllPlatforms();
  Future<void> insertReservationsBatch(List<ReservationModel> reservations);

  /// Gets a paginated list of reservations.
  ///
  /// [limit] - Maximum number of items to return.
  /// [offset] - Number of items to skip (for pagination).
  Future<List<ReservationModel>> getReservationsPaginated(int limit, int offset);

  /// Gets the total count of reservations.
  Future<int> getTotalReservationsCount();

  /// Gets a filtered and paginated list of reservations.
  ///
  /// Applies SQL WHERE clauses for non-null filter criteria.
  /// [filter] - Filter criteria (only non-null values are applied).
  /// [limit] - Maximum number of items to return.
  /// [offset] - Number of items to skip (for pagination).
  Future<List<ReservationModel>> getReservationsFiltered(
    ReservationFilter filter,
    int limit,
    int offset,
  );

  /// Gets the total count of reservations matching the filter.
  ///
  /// [filter] - Filter criteria (only non-null values are applied).
  Future<int> getFilteredReservationsCount(ReservationFilter filter);
}
