---
phase: 15-sistema-gestione-magazzino-inventario
reviewed: 2026-04-13T12:00:00Z
depth: standard
files_reviewed: 31
files_reviewed_list:
  - lib/core/database/database_helper_native.dart
  - lib/core/database/database_schema.dart
  - lib/features/inventory/data/datasources/inventory_local_data_source.dart
  - lib/features/inventory/data/models/inventory_item_model.dart
  - lib/features/inventory/data/models/inventory_movement_model.dart
  - lib/features/inventory/data/repositories/inventory_repository_impl.dart
  - lib/features/inventory/domain/entities/inventory_category.dart
  - lib/features/inventory/domain/entities/inventory_item.dart
  - lib/features/inventory/domain/entities/inventory_movement.dart
  - lib/features/inventory/domain/repositories/inventory_repository.dart
  - lib/features/inventory/presentation/pages/inventory_page.dart
  - lib/features/inventory/presentation/providers/inventory_provider.dart
  - lib/features/inventory/presentation/widgets/add_edit_inventory_item_dialog.dart
  - lib/features/inventory/presentation/widgets/expiry_indicator.dart
  - lib/features/inventory/presentation/widgets/inventory_filter_chips.dart
  - lib/features/inventory/presentation/widgets/inventory_item_card.dart
  - lib/features/inventory/presentation/widgets/inventory_movement_history_sheet.dart
  - test/features/inventory/data/datasources/inventory_local_data_source_test.dart
  - test/features/inventory/data/models/inventory_item_model_test.dart
  - test/features/inventory/data/models/inventory_movement_model_test.dart
  - test/features/inventory/data/repositories/inventory_repository_impl_test.dart
  - test/features/inventory/domain/entities/inventory_category_test.dart
  - test/features/inventory/domain/entities/inventory_item_test.dart
  - test/features/inventory/domain/entities/inventory_movement_test.dart
  - test/features/inventory/presentation/pages/inventory_page_test.dart
  - test/features/inventory/presentation/providers/inventory_provider_test.dart
  - test/features/inventory/presentation/widgets/add_edit_inventory_item_dialog_test.dart
  - test/features/inventory/presentation/widgets/expiry_indicator_test.dart
  - test/features/inventory/presentation/widgets/inventory_filter_chips_test.dart
  - test/features/inventory/presentation/widgets/inventory_item_card_test.dart
  - test/features/inventory/presentation/widgets/inventory_movement_history_sheet_test.dart
findings:
  critical: 1
  warning: 4
  info: 3
  total: 8
status: issues_found
---

# Phase 15: Code Review Report

**Reviewed:** 2026-04-13T12:00:00Z
**Depth:** standard
**Files Reviewed:** 31
**Status:** issues_found

## Summary

Reviewed the inventory management feature (Magazzino) implementation across all architectural layers: database schema, data layer (data source, models, repository), domain layer (entities, repository interface), presentation layer (providers, pages, widgets), and all associated test files. The codebase follows clean architecture with proper Freezed-generated immutable models and entities, transactional data operations, and Riverpod state management.

One critical issue was found: a race condition in `addMovement` where the item quantity is read outside the transactional boundary, allowing concurrent movements to corrupt the quantity. Several warnings address type safety (`dynamic` usage), unhandled errors in `.then()` callbacks, a notification ID mismatch between scheduling and cancellation, and a misleading test helper. The test suite is well-structured with good coverage of domain logic, model conversions, and widget rendering.

## Critical Issues

### CR-01: Race condition in addMovement -- item quantity read outside transaction

**File:** `lib/features/inventory/data/repositories/inventory_repository_impl.dart:53-75`

**Issue:** In `addMovement()`, the current item is fetched via `getItemById()` (line 65), then the new quantity is computed (line 70), and finally both the movement insert and quantity update are committed in a transaction inside `_dataSource.addMovement()`. The read of the current quantity happens *before* the transaction starts. If two movements are added concurrently for the same item, both will read the same original quantity, compute different `newQuantity` values, and the second transaction will overwrite the first, losing one delta entirely.

```
Thread A: reads quantity=5, computes newQuantity=8 (delta=+3)
Thread B: reads quantity=5, computes newQuantity=3 (delta=-2)
Thread A: writes movement + sets quantity=8
Thread B: writes movement + sets quantity=3  <-- should be 6, lost Thread A's delta
```

**Fix:** Move the quantity read inside the transaction. Use a SQL-level atomic update so the database handles concurrency:

```dart
// In inventory_local_data_source.dart, change addMovement to accept only delta:
Future<void> addMovement(InventoryMovementModel movement, int delta) async {
  await _db.transaction((txn) async {
    await txn.insert(
      DatabaseSchema.tableInventoryMovements,
      movement.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await txn.rawUpdate(
      'UPDATE ${DatabaseSchema.tableInventoryItems} '
      'SET ${DatabaseSchema.inventoryItemQuantity} = ${DatabaseSchema.inventoryItemQuantity} + ?, '
      '${DatabaseSchema.inventoryItemUpdatedAt} = ? '
      'WHERE ${DatabaseSchema.inventoryItemId} = ?',
      [delta, DateTime.now().toIso8601String(), movement.itemId],
    );
  });
}
```

Then in the repository, pass `delta` instead of `newQuantity`:

```dart
await _dataSource.addMovement(movementModel, delta);
```

## Warnings

### WR-01: Mismatched notification ID between scheduling and cancellation

**File:** `lib/features/inventory/application/inventory_notification_scheduler.dart:32,55-56`

**Issue:** When scheduling, the `NotificationSchedule` uses a string ID `'inventory_${item.id}'` (line 32). When cancelling, the code computes `'inventory_${item.id}'.hashCode` (an `int`) and passes it to `cancelNotification()` (line 56). The `scheduleNotification` method receives the whole `NotificationSchedule` object and may derive its own platform notification ID differently. If `scheduleNotification` and `cancelNotification` do not use the same ID derivation internally, scheduled expiry notifications will never be cancelled. Additionally, passing `PaymentStatus.received` as a placeholder (line 48) indicates this call is forced into a reservation-shaped API.

**Fix:** Verify that `NotificationService.scheduleNotification` and `cancelNotification` use the same ID derivation mechanism. If `cancelNotification` takes an integer hash, confirm that `scheduleNotification` also uses `.id.hashCode` when registering with the platform. If there is a mismatch, both must use the same derivation. Long-term, consider creating an inventory-specific scheduling method rather than reusing the reservation notification path.

### WR-02: `dynamic` type used instead of `InventoryItem` in InventoryPage methods

**File:** `lib/features/inventory/presentation/pages/inventory_page.dart:127,160,175`

**Issue:** The methods `_showEditDialog(dynamic item)`, `_showMovementHistory(dynamic item)`, and `_confirmDelete(dynamic item)` accept `dynamic` instead of `InventoryItem`. This bypasses Dart's type safety -- a caller could pass any object, causing runtime crashes when accessing `.id`, `.name`, or `.copyWith()`.

**Fix:** Replace `dynamic` with `InventoryItem`:

```dart
void _showEditDialog(InventoryItem item) { ... }
void _showMovementHistory(InventoryItem item) { ... }
void _confirmDelete(InventoryItem item) { ... }
```

### WR-03: `.then()` callbacks used without error handling -- failures silently swallowed

**File:** `lib/features/inventory/presentation/pages/inventory_page.dart:115-124,148-155`

**Issue:** The `addItem` and `updateItem` calls use `.then()` callbacks to show SnackBars but do not handle errors (no `.catchError()` or `try/catch`). If the repository throws, the error is silently swallowed. The user gets no feedback about the failure, and the SnackBar confirmation never appears, leaving the UI in an inconsistent state.

**Fix:** Use async/await with try/catch:

```dart
void _showAddDialog() {
  showDialog(
    context: context,
    builder: (context) => AddEditInventoryItemDialog(
      onSubmit: ({...}) async {
        try {
          await ref.read(inventoryProvider.notifier).addItem(...);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Articolo aggiunto')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore: $e')),
            );
          }
        }
      },
    ),
  );
}
```

### WR-04: DatabaseHelper.forTesting() returns the same singleton instance

**File:** `lib/core/database/database_helper_native.dart:15`

**Issue:** The `DatabaseHelper.forTesting()` factory constructor calls `DatabaseHelper._internal()`, which returns the same singleton instance as `DatabaseHelper()`. Tests using `forTesting()` share state with any code using the default constructor, which could cause test pollution between suites. The method name implies it provides isolation, but it does not.

**Fix:** Either create a truly separate instance for testing by accepting a custom database path, or remove the factory and document that tests must override the provider with a separate database:

```dart
// Option: Named constructor with path override
DatabaseHelper._withPath(this._dbPath);
factory DatabaseHelper.forTesting() => DatabaseHelper._withPath(inMemoryDatabasePath);
```

## Info

### IN-01: Expiry date calculation uses `Duration(days: 4)` for "3 days" threshold

**File:** `lib/features/inventory/domain/entities/inventory_item.dart:55`

**Issue:** The comment says "3 days means within next 3 days" but the code uses `Duration(days: 4)`. The logic is technically correct (comparing normalized-to-midnight dates, day 0 through day 3 inclusive spans 4 calendar days), but the magic number 4 without explanation is confusing. The `<= 3` check in `_formatExpiryDate` (inventory_item_card.dart line 93) also refers to "3 days" in the UI text.

**Fix:** Extract the threshold into a named constant with a clarifying comment:

```dart
static const int _expiryWarningDays = 3;
// +1 day because we compare at midnight: "within 3 days" spans 4 calendar days
final threeDaysFromNow = today.add(Duration(days: _expiryWarningDays + 1));
```

### IN-02: Unused import and dead code in inventory_provider_test.dart

**File:** `test/features/inventory/presentation/providers/inventory_provider_test.dart:8,12`

**Issue:** `import 'package:sqflite/sqflite.dart';` is imported and `FakeDatabase extends Fake implements Database` is declared (line 12), but `FakeDatabase` is never used in any test. This is dead code that adds unnecessary dependencies to the test file.

**Fix:** Remove the unused import and the `FakeDatabase` class definition.

### IN-03: Cross-feature dependency on PaymentStatus for inventory notifications

**File:** `lib/features/inventory/application/inventory_notification_scheduler.dart:5`

**Issue:** `import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';` is imported only to pass `PaymentStatus.received` as a placeholder argument on line 48. This creates a cross-feature dependency that exists solely because `scheduleNotification` requires a `PaymentStatus` parameter irrelevant for inventory notifications.

**Fix:** Consider refactoring `NotificationService.scheduleNotification` to not require a `PaymentStatus`, or create an inventory-specific scheduling interface that does not carry reservation-domain concepts. This is a design improvement rather than a bug.

---

_Reviewed: 2026-04-13T12:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
