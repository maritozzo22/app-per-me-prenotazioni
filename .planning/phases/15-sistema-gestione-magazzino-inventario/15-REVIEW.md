---
phase: 15-sistema-gestione-magazzino-inventario
reviewed: 2026-04-12T00:00:00Z
depth: standard
files_reviewed: 16
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
findings:
  critical: 2
  warning: 6
  info: 3
  total: 11
status: issues_found
---

# Phase 15: Code Review Report

**Reviewed:** 2026-04-12T00:00:00Z
**Depth:** standard
**Files Reviewed:** 16
**Status:** issues_found

## Summary

Reviewed the inventory management system implementation across all architectural layers (domain, data, presentation). The codebase demonstrates good separation of concerns with clean architecture patterns, proper use of Freezed for immutable models, and comprehensive SQLite schema design. However, several issues were identified that require attention before release, including race conditions in movement tracking, missing error handling, and potential null pointer exceptions.

## Critical Issues

### CR-01: Race Condition in Inventory Movement Addition

**File:** `lib/features/inventory/data/repositories/inventory_repository_impl.dart:52-75`

**Issue:** The `addMovement` method has a race condition between reading the current item quantity (line 65) and updating it (line 74). Between these two operations, another movement could be added, causing the new quantity calculation to be based on stale data.

```dart
// Line 65: Read current quantity
final item = await getItemById(itemId);
if (item == null) {
  throw Exception('Item not found: $itemId');
}
final newQuantity = item.quantity + delta;

// Line 73-74: Update with potentially stale quantity
final movementModel = InventoryMovementModel.fromDomain(movement);
await _dataSource.addMovement(movementModel, newQuantity);
```

**Fix:** Move the quantity calculation inside the database transaction to ensure atomicity:

```dart
@override
Future<void> addMovement(String itemId, int delta) async {
  final now = DateTime.now();
  final movement = InventoryMovement(
    id: _uuid.v4(),
    itemId: itemId,
    delta: delta,
    date: now,
    createdAt: now,
  );

  final movementModel = InventoryMovementModel.fromDomain(movement);
  
  // Pass delta instead of pre-calculated quantity
  await _dataSource.addMovementAtomic(movementModel, delta);
}
```

Then update the data source to calculate within transaction:

```dart
Future<void> addMovementAtomic(
  InventoryMovementModel movement,
  int delta,
) async {
  await _db.transaction((txn) async {
    // Get current quantity within transaction
    final results = await txn.query(
      DatabaseSchema.tableInventoryItems,
      where: '${DatabaseSchema.inventoryItemId} = ?',
      whereArgs: [movement.itemId],
    );
    
    if (results.isEmpty) {
      throw Exception('Item not found: ${movement.itemId}');
    }
    
    final currentQuantity = results.first[DatabaseSchema.inventoryItemQuantity] as int;
    final newQuantity = currentQuantity + delta;
    
    // Insert movement record
    await txn.insert(
      DatabaseSchema.tableInventoryMovements,
      movement.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update item quantity
    await txn.update(
      DatabaseSchema.tableInventoryItems,
      {
        DatabaseSchema.inventoryItemQuantity: newQuantity,
        DatabaseSchema.inventoryItemUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseSchema.inventoryItemId} = ?',
      whereArgs: [movement.itemId],
    );
  });
}
```

### CR-02: Unvalidated Date Parsing Can Throw Exceptions

**File:** `lib/features/inventory/data/models/inventory_item_model.dart:49`

**Issue:** The `toDomain()` method uses `DateTime.parse()` without validation, which can throw `FormatException` if the database contains malformed date strings.

```dart
expiryDate: expiryDate != null ? DateTime.parse(expiryDate!) : null,
createdAt: DateTime.parse(createdAt),
updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
```

**Fix:** Add safe parsing with fallback or validation:

```dart
DateTime? safeParseDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value);
  } on FormatException catch (_) {
    // Log error and return current time as fallback
    return DateTime.now();
  }
}

InventoryItem toDomain() {
  return InventoryItem(
    id: id,
    name: name,
    category: _parseCategory(category),
    quantity: quantity,
    expiryDate: safeParseDateTime(expiryDate),
    notes: notes,
    createdAt: safeParseDateTime(createdAt) ?? DateTime.now(),
    updatedAt: safeParseDateTime(updatedAt),
  );
}
```

Same issue in `inventory_movement_model.dart:40-41`:

```dart
date: safeParseDateTime(date) ?? DateTime.now(),
createdAt: safeParseDateTime(createdAt) ?? DateTime.now(),
```

## Warnings

### WR-01: Missing Error Handling in InventoryNotifier

**File:** `lib/features/inventory/presentation/providers/inventory_provider.dart:84`

**Issue:** Notification scheduling failures are silently ignored, which could leave users without expiry notifications.

```dart
await repo.addItem(item);

// Schedule expiry notification for food items per D-05
await scheduler.scheduleExpiryNotification(item);

return repo.getAllItems();
```

**Fix:** Wrap notification scheduling in try-catch and log errors:

```dart
await repo.addItem(item);

// Schedule expiry notification for food items per D-05
try {
  await scheduler.scheduleExpiryNotification(item);
} catch (e) {
  // Log error but don't fail the operation
  debugPrint('Failed to schedule expiry notification: $e');
}

return repo.getAllItems();
```

Same issue at lines 99, 114 for update and delete operations.

### WR-02: Generic Exception Type Throws

**File:** `lib/features/inventory/data/repositories/inventory_repository_impl.dart:67`

**Issue:** Throwing generic `Exception` makes error handling difficult for callers.

```dart
if (item == null) {
  throw Exception('Item not found: $itemId');
}
```

**Fix:** Use specific exception types:

```dart
if (item == null) {
  throw ItemNotFoundException(itemId);
}
```

Create a custom exception:

```dart
class ItemNotFoundException implements Exception {
  final String itemId;
  ItemNotFoundException(this.itemId);
  
  @override
  String toString() => 'Item not found: $itemId';
}
```

### WR-03: Potential Null Pointer in _showMovementHistory

**File:** `lib/features/inventory/presentation/pages/inventory_page.dart:160-162`

**Issue:** The method uses `inventoryRepositoryProvider` directly without null checks, but this provider could theoretically throw or return null in error states.

```dart
void _showMovementHistory(dynamic item) async {
  final movements =
      await ref.read(inventoryRepositoryProvider).getMovementsByItemId(item.id);
```

**Fix:** Add error handling:

```dart
void _showMovementHistory(dynamic item) async {
  try {
    final repo = ref.read(inventoryRepositoryProvider);
    final movements = await repo.getMovementsByItemId(item.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InventoryMovementHistorySheet(
        movements: movements,
      ),
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore caricamento storico: $e')),
      );
    }
  }
}
```

### WR-04: Missing Input Validation for Quantity Range

**File:** `lib/features/inventory/presentation/widgets/add_edit_inventory_item_dialog.dart:125-134`

**Issue:** The quantity validator accepts any integer, including extremely large values that could cause overflow or UI issues.

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Inserisci la quantità';
  }
  final quantity = int.tryParse(value);
  if (quantity == null) {
    return 'Inserisci un numero valido';
  }
  return null;
},
```

**Fix:** Add range validation:

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Inserisci la quantità';
  }
  final quantity = int.tryParse(value);
  if (quantity == null) {
    return 'Inserisci un numero valido';
  }
  if (quantity < -999999 || quantity > 999999) {
    return 'Quantità deve essere tra -999999 e 999999';
  }
  return null;
},
```

### WR-05: Memory Leak in TextEditingController

**File:** `lib/features/inventory/presentation/widgets/add_edit_inventory_item_dialog.dart:146-150`

**Issue:** A new `TextEditingController` is created in build without being disposed, causing a memory leak.

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Data scadenza *',
    hintText: 'Seleziona data',
    suffixIcon: const Icon(Icons.calendar_today),
  ),
  readOnly: true,
  onTap: _pickExpiryDate,
  controller: TextEditingController(  // Created every build
    text: _expiryDate != null
        ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
        : '',
  ),
```

**Fix:** Create a controller in initState and update its text when expiry date changes:

```dart
late TextEditingController _expiryDateController;

@override
void initState() {
  super.initState();
  _nameController = TextEditingController(text: widget.item?.name ?? '');
  _quantityController = TextEditingController(
    text: widget.item?.quantity.toString() ?? '1',
  );
  _notesController = TextEditingController(text: widget.item?.notes ?? '');
  _expiryDateController = TextEditingController(
    text: widget.item?.expiryDate != null
        ? '${widget.item!.expiryDate!.day}/${widget.item!.expiryDate!.month}/${widget.item!.expiryDate!.year}'
        : '',
  );
  _selectedCategory = widget.item?.category;
  _expiryDate = widget.item?.expiryDate;
}

@override
void dispose() {
  _nameController.dispose();
  _quantityController.dispose();
  _notesController.dispose();
  _expiryDateController.dispose();
  super.dispose();
}

// In _pickExpiryDate, update the controller text:
if (picked != null) {
  setState(() {
    _expiryDate = picked;
    _expiryDateController.text = 
        '${picked.day}/${picked.month}/${picked.year}';
  });
}
```

Then use `_expiryDateController` in the TextFormField.

### WR-06: Missing Null Check in inventory_page.dart

**File:** `lib/features/inventory/presentation/pages/inventory_page.dart:127`

**Issue:** The `_showEditDialog` and `_showMovementHistory` methods accept `dynamic` instead of `InventoryItem`, losing type safety.

```dart
void _showEditDialog(dynamic item) {
```

**Fix:** Use proper type:

```dart
void _showEditDialog(InventoryItem item) {
```

Same for line 160 and 175.

## Info

### IN-01: Inconsistent Error Message Language

**File:** `lib/features/inventory/presentation/pages/inventory_page.dart:75`

**Issue:** Error messages are in English while the rest of the UI is in Italian.

```dart
Text('Errore: $error'),
```

**Fix:** Use Italian for consistency:

```dart
Text('Si è verificato un errore: $error'),
```

### IN-02: Magic Number in Expiry Calculation

**File:** `lib/features/inventory/domain/entities/inventory_item.dart:55`

**Issue:** The value `4` is used for "3 days" calculation without explanation.

```dart
final threeDaysFromNow = today.add(const Duration(days: 4)); // 3 days means within next 3 days
```

**Fix:** Use a named constant:

```dart
static const int _expiryWarningDays = 3;
final threeDaysFromNow = today.add(Duration(days: _expiryWarningDays + 1));
```

### IN-03: Redundant Null Check in InventoryItemCard

**File:** `lib/features/inventory/presentation/widgets/inventory_item_card.dart:84-95`

**Issue:** The `_formatExpiryDate` method checks for null twice (once before calling, once inside).

```dart
if (item.expiryDate != null)
  Text(
    _formatExpiryDate(),
    ...
  ),
```

And in the method:

```dart
String _formatExpiryDate() {
  if (item.expiryDate == null) return '';
  ...
}
```

**Fix:** Remove the null check in the method since the caller ensures it's not null:

```dart
String _formatExpiryDate() {
  final days = item.daysUntilExpiry!;
  if (days < 0) return 'Scaduto il ${_formatDate(item.expiryDate!)}';
  if (days == 0) return 'Scade oggi';
  if (days == 1) return 'Scade domani';
  if (days <= 3) return 'Scade tra $days giorni';
  return 'Scade il ${_formatDate(item.expiryDate!)}';
}
```

---

_Reviewed: 2026-04-12T00:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
