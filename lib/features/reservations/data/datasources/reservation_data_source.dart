import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';

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
}
