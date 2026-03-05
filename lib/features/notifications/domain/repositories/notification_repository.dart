import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';

/// Repository interface for notification schedules.
///
/// This abstract class defines the contract for notification schedule
/// data operations, allowing for different implementations (e.g., database,
/// API, in-memory).
abstract class NotificationRepository {
  /// Creates a new notification schedule.
  ///
  /// Returns the created [NotificationSchedule].
  Future<NotificationSchedule> create(NotificationSchedule schedule);

  /// Creates multiple notification schedules.
  ///
  /// Returns all created [NotificationSchedule] objects.
  Future<List<NotificationSchedule>> createAll(List<NotificationSchedule> schedules);

  /// Gets a notification schedule by its ID.
  ///
  /// Returns the [NotificationSchedule] if found, null otherwise.
  Future<NotificationSchedule?> getById(String id);

  /// Gets all notification schedules for a specific reservation.
  ///
  /// Returns a list of [NotificationSchedule] objects.
  Future<List<NotificationSchedule>> getByReservationId(String reservationId);

  /// Gets all notification schedules that have not been sent yet.
  ///
  /// Returns a list of [NotificationSchedule] objects.
  Future<List<NotificationSchedule>> getUnsent();

  /// Gets all notification schedules scheduled for a specific date range.
  ///
  /// Returns a list of [NotificationSchedule] objects.
  Future<List<NotificationSchedule>> getByDateRange(DateTime start, DateTime end);

  /// Updates a notification schedule.
  ///
  /// Returns the updated [NotificationSchedule].
  Future<NotificationSchedule> update(NotificationSchedule schedule);

  /// Marks a notification schedule as sent.
  ///
  /// Returns the updated [NotificationSchedule] if found, null otherwise.
  Future<NotificationSchedule?> markAsSent(String id);

  /// Deletes a notification schedule.
  ///
  /// Returns true if the schedule was deleted, false otherwise.
  Future<bool> delete(String id);

  /// Deletes all notification schedules for a specific reservation.
  ///
  /// Returns the number of schedules deleted.
  Future<int> deleteByReservationId(String reservationId);

  /// Gets all notification schedules.
  ///
  /// Returns a list of all [NotificationSchedule] objects.
  Future<List<NotificationSchedule>> getAll();

  /// Counts all unsent notification schedules.
  ///
  /// Returns the count of unsent notifications.
  Future<int> countUnsent();

  /// Gets all pending notification schedules (not sent and scheduled date is in the future).
  ///
  /// Returns a list of pending [NotificationSchedule] objects.
  Future<List<NotificationSchedule>> getPendingSchedules();

  /// Saves a notification schedule (create or update).
  ///
  /// Returns void.
  Future<void> saveSchedule(NotificationSchedule schedule);

  /// Deletes all notification schedules for a specific reservation.
  ///
  /// Returns void.
  Future<void> deleteSchedulesForReservation(String reservationId);

  /// Gets all schedules for a specific reservation (alias for getByReservationId).
  ///
  /// Returns a list of [NotificationSchedule] objects for the reservation.
  Future<List<NotificationSchedule>> getSchedulesForReservation(String reservationId);
}
