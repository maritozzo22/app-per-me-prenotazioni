import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';
import 'package:app_prenotazioni/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:app_prenotazioni/features/inventory/application/inventory_notification_scheduler.dart';
import 'package:app_prenotazioni/features/notifications/presentation/providers/notification_permission_provider.dart';

/// Provider for InventoryRepository
///
/// This provider must be overridden in main.dart or tests with the actual implementation.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  throw UnimplementedError(
    'inventoryRepositoryProvider must be overridden in main.dart or tests',
  );
});

/// Provider for InventoryNotificationScheduler
final inventoryNotificationSchedulerProvider = Provider<InventoryNotificationScheduler>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return InventoryNotificationScheduler(notificationService);
});

/// Selected category filter (null = show all per D-02)
final selectedCategoryProvider =
    StateProvider<InventoryCategory?>((ref) => null);

/// Inventory list provider
final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, List<InventoryItem>>(
  InventoryNotifier.new,
);

/// Filtered inventory items (by selected category)
final filteredItemsProvider = Provider<List<InventoryItem>>((ref) {
  final allItems = ref.watch(inventoryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return allItems.when(
    data: (items) {
      if (selectedCategory == null) return items;
      return items.where((item) => item.category == selectedCategory).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Notifier for inventory state
class InventoryNotifier extends AsyncNotifier<List<InventoryItem>> {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<InventoryItem>> build() async {
    final repo = ref.watch(inventoryRepositoryProvider);
    return repo.getAllItems();
  }

  Future<void> addItem({
    required String name,
    required InventoryCategory category,
    required int quantity,
    DateTime? expiryDate,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(inventoryRepositoryProvider);
      final scheduler = ref.watch(inventoryNotificationSchedulerProvider);

      final item = InventoryItem(
        id: _uuid.v4(),
        name: name,
        category: category,
        quantity: quantity,
        expiryDate: expiryDate,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await repo.addItem(item);

      // Schedule expiry notification for food items per D-05
      await scheduler.scheduleExpiryNotification(item);

      return repo.getAllItems();
    });
  }

  Future<void> updateItem(InventoryItem item) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(inventoryRepositoryProvider);
      final scheduler = ref.watch(inventoryNotificationSchedulerProvider);

      await repo.updateItem(item);

      // Reschedule notification if expiry date changed
      await scheduler.rescheduleExpiryNotification(item);

      return repo.getAllItems();
    });
  }

  Future<void> deleteItem(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(inventoryRepositoryProvider);
      final scheduler = ref.watch(inventoryNotificationSchedulerProvider);

      // Get item before deletion to cancel notification
      final item = await repo.getItemById(id);
      if (item != null) {
        await scheduler.cancelItemNotification(item);
      }

      await repo.deleteItem(id);
      return repo.getAllItems();
    });
  }

  Future<void> addMovement(String itemId, int delta) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(inventoryRepositoryProvider);
      await repo.addMovement(itemId, delta);
      return repo.getAllItems();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(inventoryRepositoryProvider);
      return repo.getAllItems();
    });
  }
}
