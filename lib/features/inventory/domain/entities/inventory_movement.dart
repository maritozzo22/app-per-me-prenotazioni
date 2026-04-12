import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_movement.freezed.dart';
part 'inventory_movement.g.dart';

/// Movement record for tracking inventory changes (per D-07, D-08, D-09)
///
/// Each movement records a +/- delta when user does periodic counting (every 2-3 months).
@freezed
class InventoryMovement with _$InventoryMovement {
  const factory InventoryMovement({
    /// Unique identifier
    required String id,
    /// Reference to inventory item
    required String itemId,
    /// Quantity change (+ for additions, - for removals/losses per D-10)
    required int delta,
    /// When the movement was recorded
    required DateTime date,
    /// Creation timestamp
    required DateTime createdAt,
  }) = _InventoryMovement;

  factory InventoryMovement.fromJson(Map<String, dynamic> json) =>
      _$InventoryMovementFromJson(json);
}

/// Extension for movement display helpers
extension InventoryMovementX on InventoryMovement {
  /// Whether this is a positive movement (stock added)
  bool get isPositive => delta > 0;

  /// Whether this is a negative movement (stock removed/lost)
  bool get isNegative => delta < 0;

  /// Formatted delta with sign (+5, -3)
  String get deltaDisplay => delta >= 0 ? '+$delta' : '$delta';

  /// Movement description for UI
  String get description {
    if (isPositive) return 'Aggiunti $delta';
    if (isNegative) return 'Rimossi ${-delta}';
    return 'Nessun cambiamento';
  }
}
