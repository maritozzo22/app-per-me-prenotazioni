import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_movement.dart';

/// Bottom sheet showing movement history for an item (per D-09)
class InventoryMovementHistorySheet extends StatelessWidget {
  final List<InventoryMovement> movements;

  const InventoryMovementHistorySheet({
    super.key,
    required this.movements,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle for dragging
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              ListTile(
                title: Text(
                  'Storico Movimenti',
                  style: theme.textTheme.titleLarge,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Chiudi',
                ),
              ),
              const Divider(height: 1),
              // Movements list
              Expanded(
                child: movements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: theme.disabledColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun movimento registrato',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: movements.length,
                        itemBuilder: (context, index) {
                          final movement = movements[index];
                          return ListTile(
                            leading: Container(
                              width: 48,
                              alignment: Alignment.center,
                              child: Text(
                                movement.deltaDisplay,
                                style: TextStyle(
                                  color: movement.isPositive
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              _formatDate(movement.date),
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              _formatTime(movement.date),
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    // Italian month names
    const months = [
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
