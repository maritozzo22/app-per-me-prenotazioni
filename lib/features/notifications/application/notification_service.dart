import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/core/platform/platform_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:convert';

/// Navigation handler callback for notification taps
typedef NotificationNavigationHandler = Future<void> Function(String reservationId);

/// Global navigation handler (set from main.dart)
NotificationNavigationHandler? _notificationNavigationHandler;

/// Global notification service instance (initialized in main.dart)
NotificationService? _notificationServiceInstance;

/// Set the navigation handler for notification taps
void setNotificationNavigationHandler(NotificationNavigationHandler handler) {
  _notificationNavigationHandler = handler;
}

/// Set the global notification service instance (called from main.dart after initialization)
void setNotificationServiceInstance(NotificationService service) {
  _notificationServiceInstance = service;
}

/// Get the global notification service instance
NotificationService? getNotificationServiceInstance() {
  return _notificationServiceInstance;
}

/// Abstract interface for platform-specific notification services.
abstract class NotificationService {
  Future<void> initialize();
  Future<void> scheduleNotification(NotificationSchedule schedule, String guestName, String roomLabel);
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
  Future<bool> requestPermissions();

  /// Sends a test notification immediately.
  ///
  /// Returns true if notification was sent successfully.
  Future<bool> sendTestNotification();
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

    // Create payload with reservation ID for navigation
    final payload = jsonEncode({'reservationId': schedule.reservationId});

    await _plugin.zonedSchedule(
      schedule.id.hashCode,
      'Promemoria: $guestName',
      _buildMessage(schedule, guestName, roomLabel),
      tz.TZDateTime.from(schedule.scheduledDate, tz.local),
      notificationDetails,
      payload: payload,
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

  @override
  Future<bool> sendTestNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'reservation_reminders',
        'Promemoria Prenotazioni',
        channelDescription: 'Notifiche per i promemoria delle prenotazioni',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        'Notifica di Test',
        'Le notifiche funzionano correttamente!',
        notificationDetails,
      );

      return true;
    } catch (e) {
      print('Error sending test notification: $e');
      return false;
    }
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
    if (response.payload == null) {
      print('Notification tapped with no payload');
      return;
    }

    try {
      final payloadData = jsonDecode(response.payload!) as Map<String, dynamic>;
      final reservationId = payloadData['reservationId'] as String?;

      if (reservationId != null) {
        // Use the navigation handler if set
        if (_notificationNavigationHandler != null) {
          _notificationNavigationHandler!(reservationId);
        } else {
          print('Notification navigation handler not set. Reservation ID: $reservationId');
        }
      } else {
        print('Invalid notification payload: ${response.payload}');
      }
    } catch (e) {
      print('Error parsing notification payload: $e');
    }
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

  @override
  Future<bool> sendTestNotification() async {
    // Notifications not supported on web
    return false;
  }
}

/// Factory to create the appropriate notification service for the current platform.
NotificationService createNotificationService() {
  if (PlatformService.isAndroid) {
    return AndroidNotificationService();
  }
  return WebNotificationService();
}
