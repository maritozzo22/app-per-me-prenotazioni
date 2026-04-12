import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

/// Expiry status for color-coded UI indicators (per D-04)
enum ExpiryStatus {
  /// Item has expired (expiryDate < today)
  expired,
  /// Expiring within 3 days (orange warning)
  expiringSoon,
  /// Expiry date is more than 3 days away (green)
  ok,
  /// Item has no expiry date (non-food items)
  notApplicable,
}

/// Inventory item entity (per D-03: name, category, quantity, expiryDate, notes)
@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    /// Unique identifier
    required String id,
    /// Item name
    required String name,
    /// Category (Alimentari, Tessili, Altro per D-01)
    required InventoryCategory category,
    /// Current quantity (can be negative per D-10 for tracking losses)
    required int quantity,
    /// Expiry date (null for non-food items per D-06)
    DateTime? expiryDate,
    /// Optional notes
    String? notes,
    /// Creation timestamp
    required DateTime createdAt,
    /// Last update timestamp
    DateTime? updatedAt,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}

/// Extension for expiry status calculation (per D-04 color coding)
extension InventoryItemX on InventoryItem {
  /// Calculate expiry status for color indicators
  ExpiryStatus get expiryStatus {
    if (expiryDate == null) return ExpiryStatus.notApplicable;

    final now = DateTime.now();
    // Normalize to start of day for consistent comparison
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    final threeDaysFromNow = today.add(const Duration(days: 4)); // 3 days means within next 3 days

    if (expiry.isBefore(today)) return ExpiryStatus.expired;
    if (expiry.isBefore(threeDaysFromNow)) return ExpiryStatus.expiringSoon;
    return ExpiryStatus.ok;
  }

  /// Days until expiry (null if not applicable)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiry.difference(today).inDays;
  }

  /// Whether quantity is negative (loss indicator per D-10)
  bool get isNegative => quantity < 0;

  /// Formatted quantity display (handles negative per D-10)
  String get quantityDisplay => quantity < 0 ? 'Mancano: ${-quantity}' : '$quantity';
}
