import 'package:app_prenotazioni/features/notifications/domain/services/notification_scheduler_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';

/// Orchestrates notification scheduling for reservations.
///
/// This service coordinates:
/// 1. Calculating notification schedules using NotificationSchedulerService
/// 2. Persisting schedules to database using NotificationRepository
/// 3. Scheduling platform notifications using NotificationService
class ReservationNotificationScheduler {
  final NotificationSchedulerService _schedulerService;
  final NotificationRepository _notificationRepository;
  final NotificationService _notificationService;

  ReservationNotificationScheduler({
    required NotificationSchedulerService schedulerService,
    required NotificationRepository notificationRepository,
    required NotificationService notificationService,
  })  : _schedulerService = schedulerService,
        _notificationRepository = notificationRepository,
        _notificationService = notificationService;

  /// Schedules all notifications for a reservation.
  ///
  /// This method:
  /// 1. Calculates all notification schedules (5 days, 3 days, 2 days, 1 day before, same day)
  /// 2. Saves each schedule to the database
  /// 3. Schedules platform notifications for each schedule
  ///
  /// If notifications are not supported (web), this method completes without error.
  Future<void> scheduleReservationNotifications(Reservation reservation) async {
    if (!PlatformService.notificationsSupported) {
      print('Notifications not supported on ${PlatformService.platformName}');
      return;
    }

    // Calculate all notification schedules
    final schedules = _schedulerService.calculateSchedules(reservation);

    if (schedules.isEmpty) {
      print('No notifications to schedule for reservation ${reservation.id}');
      return;
    }

    // Save each schedule to database and schedule platform notification
    for (final schedule in schedules) {
      await _notificationRepository.saveSchedule(schedule);

      // Get room label from room ID (simplified for now)
      final roomLabel = 'Camera ${reservation.roomId}';

      await _notificationService.scheduleNotification(
        schedule,
        reservation.guest.name,
        roomLabel,
      );

      print('Scheduled notification ${schedule.id} for ${schedule.scheduledDate}');
    }

    print('Scheduled ${schedules.length} notifications for reservation ${reservation.id}');
  }

  /// Cancels all notifications for a reservation.
  ///
  /// This method:
  /// 1. Retrieves all schedules for the reservation
  /// 2. Cancels each platform notification
  /// 3. Deletes schedules from database
  Future<void> cancelReservationNotifications(String reservationId) async {
    if (!PlatformService.notificationsSupported) {
      return;
    }

    // Get all schedules for this reservation
    final schedules = await _notificationRepository.getSchedulesForReservation(reservationId);

    // Cancel each platform notification and delete from database
    for (final schedule in schedules) {
      await _notificationService.cancelNotification(schedule.id);
    }

    // Delete all schedules from database
    await _notificationRepository.deleteSchedulesForReservation(reservationId);

    print('Cancelled ${schedules.length} notifications for reservation $reservationId');
  }

  /// Reschedules all notifications for a reservation (e.g., after editing).
  ///
  /// This is a convenience method that cancels existing notifications
  /// and schedules new ones.
  Future<void> rescheduleReservationNotifications(Reservation reservation) async {
    await cancelReservationNotifications(reservation.id);
    await scheduleReservationNotifications(reservation);
  }
}
