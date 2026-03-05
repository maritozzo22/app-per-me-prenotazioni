---
phase: 06-android-optimization
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - android/app/src/main/AndroidManifest.xml
  - lib/main.dart
  - lib/core/platform/platform_service.dart
  - lib/features/notifications/application/notification_service.dart
  - lib/features/notifications/presentation/providers/notification_permission_provider.dart
  - lib/features/notifications/application/notification_initializer.dart
autonomous: false
requirements:
  - NOT-07
  - PLATFORM-04
user_setup:
  - service: flutter_local_notifications
    why: "Local notifications on Android"
    env_vars: []
    dashboard_config: []

must_haves:
  truths:
    - "Flutter local notifications plugin is installed and configured"
    - "Android manifest has POST_NOTIFICATIONS permission for Android 13+"
    - "Notification channels are configured (reservation_reminders)"
    - "Notification service can initialize on app startup"
    - "Platform detection service exists for adaptive UI"
    - "Notification permission provider requests runtime permission"
    - "All existing tests still pass (168 tests)"
  artifacts:
    - path: "pubspec.yaml"
      provides: "flutter_local_notifications dependency"
      contains: "flutter_local_notifications: ^17.2.0"
    - path: "android/app/src/main/AndroidManifest.xml"
      provides: "Android permissions and notification configuration"
      contains: "POST_NOTIFICATIONS"
    - path: "lib/main.dart"
      provides: "Notification initialization on app startup"
      exports: ["main()"]
    - path: "lib/core/platform/platform_service.dart"
      provides: "Platform detection utilities"
      exports: ["PlatformService", "isAndroid", "isWeb"]
    - path: "lib/features/notifications/application/notification_service.dart"
      provides: "Platform-specific notification service interface"
      exports: ["NotificationService", "AndroidNotificationService"]
    - path: "lib/features/notifications/presentation/providers/notification_permission_provider.dart"
      provides: "Runtime permission handling for Android 13+"
      exports: ["notificationPermissionProvider"]
    - path: "lib/features/notifications/application/notification_initializer.dart"
      provides: "Notification initialization and setup"
      exports: ["NotificationInitializer"]
  key_links:
    - from: "lib/main.dart"
      to: "lib/features/notifications/application/notification_initializer.dart"
      via: "initializeNotifications() call in main()"
      pattern: "await.*initializeNotifications"
    - from: "lib/features/notifications/application/notification_initializer.dart"
      to: "android/app/src/main/AndroidManifest.xml"
      via: "POST_NOTIFICATIONS permission required"
      pattern: "POST_NOTIFICATIONS"
    - from: "lib/features/notifications/presentation/providers/notification_permission_provider.dart"
      to: "lib/features/notifications/application/notification_service.dart"
      via: "Permission request before scheduling"
      pattern: "requestNotificationsPermission"
---

<objective>
Set up the foundation for Android local notifications and platform adaptation. Install flutter_local_notifications plugin, configure Android manifest with required permissions, create platform detection service, and implement notification service interfaces.

Purpose: Enable local notifications on Android devices with proper Android 13+ runtime permission handling and platform-adaptive UI preparation.

Output: Notification plugin configured, Android permissions set up, platform detection service created, notification service interfaces defined.
</objective>

<execution_context>
@./.claude/get-shit-done/workflows/execute-plan.md
@./.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/06-android-optimization/06-RESEARCH.md
@lib/features/notifications/domain/services/notification_scheduler_service.dart
@lib/core/theme/app_theme.dart
@pubspec.yaml

# Key Existing Code

From lib/features/notifications/domain/services/notification_scheduler_service.dart:
```dart
abstract class NotificationSchedulerService {
  List<NotificationSchedule> calculateSchedules(Reservation reservation);
  DateTime calculateScheduledDate(DateTime checkInDate, NotificationType type);
  bool shouldScheduleNotification(NotificationSchedule schedule);
  String generateScheduleId(String reservationId, NotificationType type);
}
```

From lib/main.dart:
```dart
void main() async {
  await initializeDateFormatting('it_IT');
  runApp(const ProviderScope(child: MyApp()));
}
```

From lib/core/theme/app_theme.dart:
```dart
class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
      useMaterial3: true,
      brightness: Brightness.light,
    );
  }
  static ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      useMaterial3: true,
      brightness: Brightness.dark,
    );
  }
}
```
</context>

<tasks>

<task type="auto">
  <name>Task 1: Install flutter_local_notifications and dependencies</name>
  <files>pubspec.yaml</files>
  <action>
    Add to dependencies in pubspec.yaml:
    ```yaml
    # Notifications
    flutter_local_notifications: ^17.2.0
    timezone: ^0.9.4
    flutter_native_timezone: ^2.0.0
    ```

    Then run:
    ```bash
    flutter pub get
    ```

    Verify installation:
    ```bash
    flutter pub deps | grep flutter_local_notifications
    ```

    Do NOT modify any other dependencies. This is a pure addition task.
  </action>
  <verify>flutter pub deps | grep flutter_local_notifications</verify>
  <done>flutter_local_notifications^17.2.0, timezone^0.9.4, flutter_native_timezone^2.0.0 added to pubspec.yaml and installed successfully</done>
</task>

<task type="auto">
  <name>Task 2: Configure Android manifest with notification permissions</name>
  <files>android/app/src/main/AndroidManifest.xml</files>
  <action>
    Add the following permissions and configuration to AndroidManifest.xml:

    1. Add POST_NOTIFICATIONS permission (required for Android 13+):
    ```xml
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    ```

    2. Add SCHEDULE_EXACT_ALARM permission (for exact notification timing):
    ```xml
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    ```

    3. Add RECEIVE_BOOT_COMPLETED permission (to reschedule after device restart):
    ```xml
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    ```

    Add these permissions AFTER the closing </manifest> tag but BEFORE the <application> tag.

    This ensures notifications work on Android 13+ with runtime permissions, can be scheduled for exact times (9:00 AM), and persist across device restarts.
  </action>
  <verify>grep -E "POST_NOTIFICATIONS|SCHEDULE_EXACT_ALARM|RECEIVE_BOOT_COMPLETED" android/app/src/main/AndroidManifest.xml</verify>
  <done>Android manifest contains POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, and RECEIVE_BOOT_COMPLETED permissions in the correct location</done>
</task>

<task type="auto">
  <name>Task 3: Create platform detection service</name>
  <files>lib/core/platform/platform_service.dart</files>
  <action>
    Create lib/core/platform/platform_service.dart with platform detection utilities:

    ```dart
    import 'package:flutter/foundation.dart';

    /// Service for detecting the current platform and providing platform-specific utilities.
    class PlatformService {
      PlatformService._();

      /// Returns true if running on Android.
      static bool get isAndroid => !kIsWeb;

      /// Returns true if running on Web.
      static bool get isWeb => kIsWeb;

      /// Returns the platform name for logging purposes.
      static String get platformName => kIsWeb ? 'Web' : 'Android';

      /// Returns true if notifications are supported on this platform.
      static bool get notificationsSupported => !kIsWeb;
    }
    ```

    This service provides a simple way to check the platform throughout the app. Since this project only supports Web and Android (no iOS), we can use kIsWeb as the primary differentiator.
  </action>
  <verify>test -f lib/core/platform/platform_service.dart && grep -q "class PlatformService" lib/core/platform/platform_service.dart</verify>
  <done>PlatformService created with isAndroid, isWeb, platformName, and notificationsSupported getters</done>
</task>

<task type="auto">
  <name>Task 4: Create notification service interface and Android implementation</name>
  <files>lib/features/notifications/application/notification_service.dart</files>
  <action>
    Create lib/features/notifications/application/notification_service.dart:

    ```dart
    import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
    import 'package:app_prenotazioni/core/platform/platform_service.dart';
    import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

        await _plugin.zonedSchedule(
          schedule.id.hashCode,
          'Promemoria: $guestName',
          _buildMessage(schedule, guestName, roomLabel),
          schedule.scheduledDate,
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
          NotificationType.fiveDaysBefore => '5 giorni prima',
          NotificationType.threeDaysBefore => '3 giorni prima',
          NotificationType.twoDaysBefore => '2 giorni prima',
          NotificationType.oneDayBefore => '1 giorno prima',
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
    ```

    This creates a platform-agnostic interface with Android implementation using flutter_local_notifications. The web implementation is a stub that does nothing since web notifications have significant limitations (see RESEARCH.md).
  </action>
  <verify>test -f lib/features/notifications/application/notification_service.dart && grep -q "class AndroidNotificationService" lib/features/notifications/application/notification_service.dart</verify>
  <done>NotificationService interface created with AndroidNotificationService implementation, WebNotificationService stub, and createNotificationService factory</done>
</task>

<task type="auto">
  <name>Task 5: Create notification permission provider</name>
  <files>lib/features/notifications/presentation/providers/notification_permission_provider.dart</files>
  <action>
    Create lib/features/notifications/presentation/providers/notification_permission_provider.dart:

    ```dart
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';

    /// Provider for the notification service instance.
    final notificationServiceProvider = Provider<NotificationService>((ref) {
      return createNotificationService();
    });

    /// Provider that requests notification permissions and returns the granted status.
    ///
    /// This provider will automatically request permissions on Android 13+ when first read.
    /// On Android 12 and below, permissions are auto-granted at install time.
    /// On web, returns false (notifications not supported).
    final notificationPermissionProvider = FutureProvider<bool>((ref) async {
      final service = ref.watch(notificationServiceProvider);
      return await service.requestPermissions();
    });

    /// Provider that tracks whether notifications are enabled.
    ///
    /// This combines the permission status with platform support.
    final notificationsEnabledProvider = Provider<bool>((ref) {
      final permissionAsync = ref.watch(notificationPermissionProvider);

      return permissionAsync.when(
        data: (granted) => granted,
        loading: () => false,
        error: (_, __) => false,
      );
    });
    ```

    This creates Riverpod providers for managing notification permissions. The notificationPermissionProvider requests permissions when first read and provides the granted status. The notificationsEnabledProvider provides a convenient boolean for UI components.
  </action>
  <verify>test -f lib/features/notifications/presentation/providers/notification_permission_provider.dart && grep -q "notificationPermissionProvider" lib/features/notifications/presentation/providers/notification_permission_provider.dart</verify>
  <done>notificationServiceProvider, notificationPermissionProvider, and notificationsEnabledProvider created for managing notification permissions</done>
</task>

<task type="auto">
  <name>Task 6: Create notification initializer</name>
  <files>lib/features/notifications/application/notification_initializer.dart</files>
  <action>
    Create lib/features/notifications/application/notification_initializer.dart:

    ```dart
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
          // For now, just schedule with basic info. Full implementation in Wave 3.
          await notificationService.scheduleNotification(schedule, 'Ospite', 'Stanza');
        }

        print('Rescheduled ${pendingSchedules.length} pending notifications');
      } catch (e) {
        print('Error rescheduling notifications: $e');
        // Don't throw - initialization should succeed even if rescheduling fails
      }
    }
    ```

    This creates an initialization function that sets up the notification system and reschedules pending notifications from the database. It will be called from main() during app startup.
  </action>
  <verify>test -f lib/features/notifications/application/notification_initializer.dart && grep -q "initializeNotifications" lib/features/notifications/application/notification_initializer.dart</verify>
  <done>initializeNotifications function created that initializes the notification service and reschedules pending notifications from database</done>
</task>

<task type="auto">
  <name>Task 7: Wire notification initialization in main.dart</name>
  <files>lib/main.dart</files>
  <action>
    Modify lib/main.dart to initialize notifications on startup:

    1. Add imports at the top:
    ```dart
    import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
    import 'package:app_prenotazioni/features/notifications/application/notification_initializer.dart';
    import 'package:app_prenotazioni/features/notifications/data/repositories/notification_repository_impl.dart';
    import 'package:app_prenotazioni/core/database/database_helper.dart';
    ```

    2. Update the main() function:
    ```dart
    void main() async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize locale data for Italian
      await initializeDateFormatting('it_IT');

      // Initialize notifications (only on Android)
      if (!PlatformService.isWeb) {
        final notificationService = createNotificationService();
        final databaseHelper = await DatabaseHelper.instance;
        final notificationRepository = NotificationRepositoryImpl(databaseHelper);

        await initializeNotifications(notificationService, notificationRepository);
      }

      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    }
    ```

    This ensures notifications are initialized when the app starts, before the UI is rendered. The initialization happens on Android only, not on web.
  </action>
  <verify>grep -q "initializeNotifications" lib/main.dart</verify>
  <done>main.dart updated to initialize notifications on app startup (Android only)</done>
</task>

<task type="auto">
  <name>Task 8: Create unit tests for notification service</name>
  <files>test/features/notifications/application/notification_service_test.dart</files>
  <action>
    Create test/features/notifications/application/notification_service_test.dart:

    ```dart
    import 'package:flutter_test/flutter_test.dart';
    import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
    import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
    import 'package:app_prenotazioni/core/platform/platform_service.dart';

    void main() {
      group('PlatformService', () {
        test('should identify platform correctly', () {
          // Test that platform detection works
          expect(PlatformService.platformName, isNotNull);
          expect(PlatformService.notificationsSupported, isA<bool>());
        });
      });

      group('WebNotificationService', () {
        late WebNotificationService webService;

        setUp(() {
          webService = WebNotificationService();
        });

        test('should initialize without error', () async {
          await expectLater(webService.initialize(), completes);
        });

        test('should schedule notification without error (no-op)', () async {
          final schedule = NotificationSchedule(
            id: 'test-id',
            reservationId: 'res-1',
            type: NotificationType.oneDayBefore,
            scheduledDate: DateTime.now().add(const Duration(days: 1)),
            createdAt: DateTime.now(),
          );

          await expectLater(
            webService.scheduleNotification(schedule, 'Guest', 'Room'),
            completes,
          );
        });

        test('should cancel notification without error (no-op)', () async {
          await expectLater(webService.cancelNotification('test-id'), completes);
        });

        test('should cancel all notifications without error (no-op)', () async {
          await expectLater(webService.cancelAllNotifications(), completes);
        });

        test('should return false for requestPermissions', () async {
          final granted = await webService.requestPermissions();
          expect(granted, false);
        });
      });

      group('createNotificationService', () {
        test('should return appropriate service for platform', () {
          final service = createNotificationService();

          if (PlatformService.isWeb) {
            expect(service, isA<WebNotificationService>());
          } else {
            expect(service, isA<AndroidNotificationService>());
          }
        });
      });
    }
    ```

    These tests verify the platform service and web notification service. Android notification service tests require native Android environment and will be added in Wave 2.
  </action>
  <verify>flutter test test/features/notifications/application/notification_service_test.dart</verify>
  <done>Unit tests created for notification service, all tests pass</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
    - flutter_local_notifications plugin installed
    - Android manifest configured with POST_NOTIFICATIONS permission
    - Platform detection service created
    - Notification service interface and Android implementation
    - Notification permission provider created
    - Notification initializer created
    - main.dart updated to initialize notifications
    - Unit tests created
  </what-built>
  <how-to-verify>
    1. Run all existing tests to ensure nothing broke:
       ```bash
       flutter test
       ```
       Expected: All 168 existing tests pass

    2. Verify pubspec.yaml has the new dependencies:
       ```bash
       grep -A 2 "flutter_local_notifications" pubspec.yaml
       ```
       Expected: flutter_local_notifications: ^17.2.0

    3. Verify Android manifest has permissions:
       ```bash
       grep POST_NOTIFICATIONS android/app/src/main/AndroidManifest.xml
       ```
       Expected: Permission is present in manifest

    4. Verify new files exist:
       ```bash
       ls -la lib/core/platform/platform_service.dart
       ls -la lib/features/notifications/application/notification_service.dart
       ls -la lib/features/notifications/presentation/providers/notification_permission_provider.dart
       ls -la lib/features/notifications/application/notification_initializer.dart
       ```
       Expected: All files exist

    5. Run the new notification service tests:
       ```bash
       flutter test test/features/notifications/application/notification_service_test.dart
       ```
       Expected: All tests pass
  </how-to-verify>
  <resume-signal>Type "approved" to continue to Wave 2, or describe any issues</resume-signal>
</task>

</tasks>

<verification>
Wave 1 verification checks:
- [ ] flutter_local_notifications plugin installed successfully
- [ ] Android manifest has POST_NOTIFICATIONS, SCHEDULE_EXACT_ALARM, and RECEIVE_BOOT_COMPLETED permissions
- [ ] Platform detection service works correctly
- [ ] Notification service interface and implementations created
- [ ] Notification permission provider created
- [ ] Notification initializer created
- [ ] main.dart updated to initialize notifications
- [ ] All existing 168 tests still pass
- [ ] New notification service tests pass
- [ ] App compiles successfully on web (flutter run -d chrome)
</verification>

<success_criteria>
1. flutter_local_notifications plugin is installed and configured
2. Android manifest contains all required permissions for notifications
3. Platform detection service correctly identifies Android vs Web
4. Notification service interface is defined with Android implementation
5. Notification permission provider requests runtime permissions on Android 13+
6. Notification initializer sets up the notification system on app startup
7. All existing tests (168) still pass
8. New notification service unit tests pass
9. App compiles and runs on web without errors
</success_criteria>

<output>
After completion, create `.planning/phases/06-android-optimization/06-01-SUMMARY.md`
</output>
