import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/features/reservations/domain/entities/reservation.dart';

/// Service responsible for calculating notification schedules for reservations.
///
/// This is a platform-agnostic service that handles the business logic
/// for determining when notifications should be sent based on reservation
/// check-in dates.
abstract class NotificationSchedulerService {
  /// Calculates all notification schedules for a given reservation.
  ///
  /// Returns a list of [NotificationSchedule] objects, one for each
  /// notification type (5 days, 3 days, 2 days, 1 day before, and same day).
  ///
  /// The scheduled dates are calculated based on the reservation's check-in date.
  /// All notifications are scheduled for 9:00 AM on their respective days.
  ///
  /// Throws [ArgumentError] if [reservation] has already checked in.
  List<NotificationSchedule> calculateSchedules(Reservation reservation);

  /// Calculates the scheduled date for a specific notification type.
  ///
  /// Returns a [DateTime] representing when the notification should be sent.
  /// The time is set to 9:00 AM on the calculated day.
  ///
  /// [checkInDate] is the reservation's check-in date.
  /// [type] is the type of notification to calculate the date for.
  DateTime calculateScheduledDate(DateTime checkInDate, NotificationType type);

  /// Validates if a notification should still be scheduled.
  ///
  /// Returns true if the notification's scheduled date is in the future
  /// or today (hasn't passed yet).
  ///
  /// [schedule] is the notification schedule to validate.
  bool shouldScheduleNotification(NotificationSchedule schedule);

  /// Generates a unique ID for a notification schedule.
  ///
  /// The ID is generated based on the reservation ID and notification type
  /// to ensure uniqueness and prevent duplicate schedules.
  ///
  /// [reservationId] is the ID of the reservation.
  /// [type] is the type of notification.
  String generateScheduleId(String reservationId, NotificationType type);
}

/// Implementation of [NotificationSchedulerService].
class NotificationSchedulerServiceImpl implements NotificationSchedulerService {
  /// The hour of the day when notifications should be sent (9:00 AM).
  static const int notificationHour = 9;

  /// The minute of the hour when notifications should be sent (0 minutes).
  static const int notificationMinute = 0;

  @override
  List<NotificationSchedule> calculateSchedules(Reservation reservation) {
    final now = DateTime.now();
    final checkInDate = DateTime(
      reservation.checkIn.year,
      reservation.checkIn.month,
      reservation.checkIn.day,
    );

    // Don't schedule notifications for past reservations
    if (checkInDate.isBefore(DateTime(now.year, now.month, now.day))) {
      throw ArgumentError(
        'Cannot schedule notifications for past reservations',
      );
    }

    final schedules = <NotificationSchedule>[];
    final nowDate = DateTime.now();

    for (final type in NotificationType.all) {
      final scheduledDate = calculateScheduledDate(reservation.checkIn, type);

      // Only schedule if the date hasn't passed yet
      if (scheduledDate.isAfter(nowDate) ||
          _isSameDay(scheduledDate, nowDate)) {
        final schedule = NotificationSchedule(
          id: generateScheduleId(reservation.id, type),
          reservationId: reservation.id,
          type: type,
          scheduledDate: scheduledDate,
          createdAt: nowDate,
        );

        schedules.add(schedule);
      }
    }

    return schedules;
  }

  @override
  DateTime calculateScheduledDate(
    DateTime checkInDate,
    NotificationType type,
  ) {
    // Calculate the date by subtracting days from check-in
    final scheduledDate = DateTime(
      checkInDate.year,
      checkInDate.month,
      checkInDate.day,
    ).subtract(Duration(days: type.daysBeforeCheckIn));

    // Set the time to 9:00 AM
    return DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      notificationHour,
      notificationMinute,
    );
  }

  @override
  bool shouldScheduleNotification(NotificationSchedule schedule) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Schedule if the date is today or in the future
    return schedule.scheduledDate.isAfter(today) ||
        _isSameDay(schedule.scheduledDate, today);
  }

  @override
  String generateScheduleId(String reservationId, NotificationType type) {
    return '${reservationId}_${type.value}';
  }

  /// Checks if two DateTime objects represent the same calendar day.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
