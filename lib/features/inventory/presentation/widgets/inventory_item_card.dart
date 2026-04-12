import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/expiry_indicator.dart';

/// Card widget for displaying inventory item with expiry indicator
class InventoryItemCard extends ConsumerWidget {
  final InventoryItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ExpiryIndicator(status: item.expiryStatus),
        title: Text(
          item.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.category.label),
            const SizedBox(height: 4),
            Text(
              'Qty: ${item.quantityDisplay}',
              style: TextStyle(
                color: item.isNegative
                    ? Colors.red
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: item.isNegative ? FontWeight.bold : null,
              ),
            ),
            if (item.expiryDate != null)
              Text(
                _formatExpiryDate(),
                style: TextStyle(
                  color: _getExpiryTextColor(),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Modifica ${item.name}',
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Modifica',
              ),
            ),
            Semantics(
              label: 'Elimina ${item.name}',
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Elimina',
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatExpiryDate() {
    if (item.expiryDate == null) return '';

    final days = item.daysUntilExpiry;
    if (days == null) return '';

    if (days < 0) return 'Scaduto il ${_formatDate(item.expiryDate!)}';
    if (days == 0) return 'Scade oggi';
    if (days == 1) return 'Scade domani';
    if (days <= 3) return 'Scade tra $days giorni';
    return 'Scade il ${_formatDate(item.expiryDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color? _getExpiryTextColor() {
    return switch (item.expiryStatus) {
      ExpiryStatus.expired => Colors.red,
      ExpiryStatus.expiringSoon => Colors.orange,
      ExpiryStatus.ok => Colors.green,
      ExpiryStatus.notApplicable => null,
    };
  }
}
