import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';

/// Initializes the notification system for the current platform.
///
/// On Android: Initializes flutter_local_notifications plugin and reschedules pending notifications.
/// On Web: Does nothing (notifications not supported).
Future<void> initializeNotifications(
  NotificationService notificationService,
  NotificationRepository notificationRepository,
) async {
  if (!PlatformService.notificationsSupported) {
    print('Notifications not supported on ${PlatformService.platformName}');
    return;
  }

  // Initialize the notification plugin
  await notificationService.initialize();
  print('Notification service initialized on ${PlatformService.platformName}');

  // Reschedule any pending notifications from the database
  // This ensures notifications persist across app restarts and device reboots
  try {
    final pendingSchedules = await notificationRepository.getPendingSchedules();

    for (final schedule in pendingSchedules) {
      // Note: We can't get guest/room details here without additional repositories
      // For now, just schedule with basic info. Full implementation in Wave 2.
      await notificationService.scheduleNotification(schedule, 'Ospite', 'Stanza');
    }

    print('Rescheduled ${pendingSchedules.length} pending notifications');
  } catch (e) {
    print('Error rescheduling notifications: $e');
    // Don't throw - initialization should succeed even if rescheduling fails
  }
}
