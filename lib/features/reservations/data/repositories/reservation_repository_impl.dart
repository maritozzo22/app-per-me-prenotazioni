import 'package:app_prenotazioni/features/reservations/data/datasources/reservation_data_source.dart';
import 'package:app_prenotazioni/features/reservations/data/models/reservation_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/room_model.dart';
import 'package:app_prenotazioni/features/reservations/data/models/platform_model.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/room.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/platform.dart';
import 'package:app_prenotazioni/features/reservations/domain/repositories/reservation_repository.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/paginated_result.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation_filter.dart';
import 'package:app_prenotazioni/features/statistics/domain/services/statistics_cache_service.dart';

/// Implementation of ReservationRepository using local data source.
///
/// Includes cache invalidation hooks to ensure statistics stay fresh
/// when reservations are modified.
class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationDataSource _dataSource;
  final StatisticsCacheService? _cacheService;

  ReservationRepositoryImpl({
    required ReservationDataSource dataSource,
    StatisticsCacheService? cacheService,
  })  : _dataSource = dataSource,
        _cacheService = cacheService;

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
    // Invalidate statistics cache when reservations change
    await _cacheService?.invalidateCache();
  }

  @override
  Future<void> deleteReservation(String id) async {
    await _dataSource.deleteReservation(id);
    // Invalidate statistics cache when reservations are deleted
    await _cacheService?.invalidateCache();
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

  @override
  Future<void> insertReservationsBatch(List<Reservation> reservations) async {
    final models = reservations.map((r) => r.toModel()).toList();
    await _dataSource.insertReservationsBatch(models);
    // Invalidate statistics cache when batch insert completes
    await _cacheService?.invalidateCache();
  }

  @override
  Future<PaginatedResult<Reservation>> getReservationsPaginated({
    int page = 1,
    int pageSize = 20,
  }) async {
    final offset = (page - 1) * pageSize;
    final models = await _dataSource.getReservationsPaginated(pageSize, offset);
    final totalCount = await _dataSource.getTotalReservationsCount();

    return PaginatedResult<Reservation>(
      items: models.map((model) => model.toEntity()).toList(),
      totalCount: totalCount,
      currentPage: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<PaginatedResult<Reservation>> getReservationsFiltered({
    required ReservationFilter filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    final offset = (page - 1) * pageSize;
    final models = await _dataSource.getReservationsFiltered(filter, pageSize, offset);
    final totalCount = await _dataSource.getFilteredReservationsCount(filter);

    return PaginatedResult<Reservation>(
      items: models.map((model) => model.toEntity()).toList(),
      totalCount: totalCount,
      currentPage: page,
      pageSize: pageSize,
    );
  }
}
