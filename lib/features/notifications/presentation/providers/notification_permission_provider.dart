import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:app_prenotazioni/features/notifications/data/datasources/notification_datasource.dart';
import 'package:app_prenotazioni/core/database/database_helper.dart';

/// Provider for the notification repository
final notificationRepositoryProvider = Provider<NotificationRepositoryImpl>((ref) {
  // Create datasource with database helper
  final datasource = NotificationDatasource(DatabaseHelper());
  return NotificationRepositoryImpl(datasource);
});

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
