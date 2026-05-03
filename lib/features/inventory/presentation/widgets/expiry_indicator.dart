import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';

/// Color-coded expiry indicator (12x12dp dot per D-04)
///
/// Colors:
/// - Red: Expired
/// - Orange: Expiring within 3 days
/// - Green: More than 3 days away
/// - Grey: Not applicable (non-food items)
class ExpiryIndicator extends StatelessWidget {
  final ExpiryStatus status;
  final double size;

  const ExpiryIndicator({
    super.key,
    required this.status,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    return Semantics(
      label: _getSemanticLabel(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    return switch (status) {
      ExpiryStatus.expired => Colors.red,
      ExpiryStatus.expiringSoon => Colors.orange,
      ExpiryStatus.ok => Colors.green,
      ExpiryStatus.notApplicable => Colors.grey.shade400,
    };
  }

  String _getSemanticLabel() {
    return switch (status) {
      ExpiryStatus.expired => 'Scaduto',
      ExpiryStatus.expiringSoon => 'In scadenza',
      ExpiryStatus.ok => 'Scadenza normale',
      ExpiryStatus.notApplicable => 'Non applicabile',
    };
  }
}
