import 'package:app_prenotazioni/features/notifications/application/notification_service.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';
import 'package:app_prenotazioni/features/notifications/domain/entities/notification_schedule.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Schedules expiry notifications for inventory items (per D-05)
///
/// Schedules notification 3 days before expiry for Alimentari items.
class InventoryNotificationScheduler {
  final NotificationService _notificationService;

  InventoryNotificationScheduler(this._notificationService);

  /// Schedule notification for 3 days before item expiry
  ///
  /// Only schedules for food items with future expiry dates.
  /// Notification ID format: 'inventory_{itemId}' to prevent collision with
  /// reservation notifications (see RESEARCH.md pitfall #3).
  Future<void> scheduleExpiryNotification(InventoryItem item) async {
    // Only schedule for food items with expiry dates per D-06
    if (item.expiryDate == null) return;

    final now = DateTime.now();
    final notificationDate = item.expiryDate!.subtract(const Duration(days: 3));

    // Only schedule if notification date is in the future
    if (notificationDate.isBefore(now)) return;

    // Create notification schedule with inventory-prefixed ID
    final schedule = NotificationSchedule(
      id: 'inventory_${item.id}', // Namespace prefix prevents collision
      reservationId: '', // Not a reservation
      type: NotificationType.threeDays, // Use 3 days type (close enough to 3 days before expiry)
      scheduledDate: notificationDate,
      isSent: false,
      createdAt: now,
    );

    // Build notification title and body
    final title = '${item.name} scade tra 3 giorni';
    final body = 'Categoria: ${item.category.label}';

    await _notificationService.scheduleNotification(
      schedule,
      title,
      body,
      PaymentStatus.received, // Not applicable, using placeholder
    );
  }

  /// Cancel notification for a specific item
  Future<void> cancelItemNotification(InventoryItem item) async {
    // Calculate the notification ID
    final notificationId = 'inventory_${item.id}'.hashCode;

    await _notificationService.cancelNotification(notificationId);
  }

  /// Reschedule notification for an item (cancel and reschedule)
  ///
  /// Used when item is updated with new expiry date.
  Future<void> rescheduleExpiryNotification(InventoryItem item) async {
    await cancelItemNotification(item);
    await scheduleExpiryNotification(item);
  }
}
