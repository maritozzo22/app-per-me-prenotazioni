import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';
import 'package:app_prenotazioni/features/notifications/data/models/notification_schedule_model.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_repository.dart';

/// Implementation of [NotificationRepository] using a database data source.
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDatasource _datasource;

  NotificationRepositoryImpl(this._datasource);

  @override
  Future<NotificationSchedule> create(NotificationSchedule schedule) async {
    final model = NotificationScheduleModel.fromEntity(schedule);
    final created = await _datasource.create(model);
    return created.toEntity();
  }

  @override
  Future<List<NotificationSchedule>> createAll(List<NotificationSchedule> schedules) async {
    final models = schedules.map((s) => NotificationScheduleModel.fromEntity(s)).toList();
    final created = await _datasource.createAll(models);
    return created.map((m) => m.toEntity()).toList();
  }

  @override
  Future<NotificationSchedule?> getById(String id) async {
    final model = await _datasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<NotificationSchedule>> getByReservationId(String reservationId) async {
    final models = await _datasource.getByReservationId(reservationId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<NotificationSchedule>> getUnsent() async {
    final models = await _datasource.getUnsent();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<NotificationSchedule>> getByDateRange(DateTime start, DateTime end) async {
    final models = await _datasource.getByDateRange(start, end);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<NotificationSchedule> update(NotificationSchedule schedule) async {
    final model = NotificationScheduleModel.fromEntity(schedule);
    await _datasource.update(model);
    return schedule;
  }

  @override
  Future<NotificationSchedule?> markAsSent(String id) async {
    await _datasource.markAsSent(id);
    return await getById(id);
  }

  @override
  Future<bool> delete(String id) async {
    final rowsAffected = await _datasource.delete(id);
    return rowsAffected > 0;
  }

  @override
  Future<int> deleteByReservationId(String reservationId) async {
    return await _datasource.deleteByReservationId(reservationId);
  }

  @override
  Future<List<NotificationSchedule>> getAll() async {
    final models = await _datasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> countUnsent() async {
    return await _datasource.countUnsent();
  }

  @override
  Future<List<NotificationSchedule>> getPendingSchedules() async {
    final now = DateTime.now();
    final models = await _datasource.getAll();

    // Filter schedules that are not sent and scheduled for future
    return models
        .where((m) => !m.isSent && m.scheduledDate.isAfter(now))
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<void> saveSchedule(NotificationSchedule schedule) async {
    final model = NotificationScheduleModel.fromEntity(schedule);
    await _datasource.create(model);
  }

  @override
  Future<void> deleteSchedulesForReservation(String reservationId) async {
    await _datasource.deleteByReservationId(reservationId);
  }

  @override
  Future<List<NotificationSchedule>> getSchedulesForReservation(String reservationId) async {
    return await getByReservationId(reservationId);
  }
}
