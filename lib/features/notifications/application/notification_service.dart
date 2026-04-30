import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Abstract interface for platform-specific notification services.
abstract class NotificationService {
  Future<void> initialize();
  Future<void> scheduleNotification(NotificationSchedule schedule, String guestName, String roomLabel);
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
  Future<bool> requestPermissions();
}

/// Android implementation of local notifications.
class AndroidNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    // Initialize timezone database
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Explicitly create notification channel for Android 8+ (API 26)
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        'reservation_reminders',
        'Promemoria Prenotazioni',
        description: 'Notifiche per i promemoria delle prenotazioni',
        importance: Importance.high,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  @override
  Future<void> scheduleNotification(
    NotificationSchedule schedule,
    String guestName,
    String roomLabel,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'reservation_reminders',
      'Promemoria Prenotazioni',
      channelDescription: 'Notifiche per i promemoria delle prenotazioni',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      schedule.id.hashCode,
      'Promemoria: $guestName',
      _buildMessage(schedule, guestName, roomLabel),
      tz.TZDateTime.from(schedule.scheduledDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelNotification(String id) async {
    await _plugin.cancel(id.hashCode);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  @override
  Future<bool> requestPermissions() async {
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) {
      return false;
    }

    final bool? granted = await androidImplementation.requestNotificationsPermission();
    return granted ?? false;
  }

  String _buildMessage(NotificationSchedule schedule, String guestName, String roomLabel) {
    final typeLabel = switch (schedule.type) {
      NotificationType.fiveDays => '5 giorni prima',
      NotificationType.threeDays => '3 giorni prima',
      NotificationType.twoDays => '2 giorni prima',
      NotificationType.oneDay => '1 giorno prima',
      NotificationType.sameDay => 'Oggi',
    };

    return '$roomLabel - $typeLabel';
  }

  void _handleNotificationTap(NotificationResponse response) {
    // TODO: Navigate to reservation details (Phase 7)
    // For now, just log the tap
    print('Notification tapped: ${response.payload}');
  }
}

/// Web/Stub implementation that does nothing (notifications not supported on web).
class WebNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // No-op on web
  }

  @override
  Future<void> scheduleNotification(NotificationSchedule schedule, String guestName, String roomLabel) async {
    // No-op on web
  }

  @override
  Future<void> cancelNotification(String id) async {
    // No-op on web
  }

  @override
  Future<void> cancelAllNotifications() async {
    // No-op on web
  }

  @override
  Future<bool> requestPermissions() async {
    return false; // Notifications not supported on web
  }
}

/// Factory to create the appropriate notification service for the current platform.
NotificationService createNotificationService() {
  if (PlatformService.isAndroid) {
    return AndroidNotificationService();
  }
  return WebNotificationService();
}
