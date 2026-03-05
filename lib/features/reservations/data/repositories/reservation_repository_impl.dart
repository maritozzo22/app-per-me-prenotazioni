import 'package:app_prenotazioni/features/reservations/data/datasources/reservation_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';

/// Implementation of ReservationRepository using local data source.
class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationDataSource _dataSource;

  ReservationRepositoryImpl({
    required ReservationDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Reservation>> getAllReservations() async {
    final models = await _dataSource.getAllReservations();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Reservation?> getReservationById(String id) async {
    final model = await _dataSource.getReservationById(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveReservation(Reservation reservation) async {
    await _dataSource.saveReservation(reservation.toModel());
  }

  @override
  Future<void> deleteReservation(String id) async {
    await _dataSource.deleteReservation(id);
  }

  @override
  Future<List<Reservation>> getReservationsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final models = await _dataSource.getReservationsForDateRange(start, end);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Room>> getAllRooms() async {
    final models = await _dataSource.getAllRooms();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<BookingPlatform>> getAllPlatforms() async {
    final models = await _dataSource.getAllPlatforms();
    return models.map((model) => model.toEntity()).toList();
  }
}
