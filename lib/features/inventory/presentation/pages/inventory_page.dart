import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/inventory_filter_chips.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/add_edit_inventory_item_dialog.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/inventory_movement_history_sheet.dart';
import 'package:app_prenotazioni/core/presentation/widgets/empty_state_widget.dart';
import 'package:app_prenotazioni/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

/// Main inventory management page
class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    final filteredItems = ref.watch(filteredItemsProvider);
    final asyncItems = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Magazzino'),
      ),
      body: Column(
        children: [
          // Filter chips
          const InventoryFilterChips(),
          const Divider(height: 1),
          // Items list
          Expanded(
            child: asyncItems.when(
              data: (_) {
                if (filteredItems.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Magazzino Vuoto',
                    message: 'Nessun articolo nel magazzino.\nTocca + per aggiungere il primo articolo.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(inventoryProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return InventoryItemCard(
                        key: ValueKey(item.id),
                        item: item,
                        onTap: () => _showMovementHistory(item),
                        onEdit: () => _showEditDialog(item),
                        onDelete: () => _confirmDelete(item),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text('Errore: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.read(inventoryProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi Articolo'),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditInventoryItemDialog(
        onSubmit: ({
          required String name,
          required InventoryCategory category,
          required int quantity,
          DateTime? expiryDate,
          String? notes,
        }) {
          ref.read(inventoryProvider.notifier).addItem(
            name: name,
            category: category,
            quantity: quantity,
            expiryDate: expiryDate,
            notes: notes,
          ).then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Articolo aggiunto')),
              );
            }
          });
        },
      ),
    );
  }

  void _showEditDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AddEditInventoryItemDialog(
        item: item,
        onSubmit: ({
          required String name,
          required InventoryCategory category,
          required int quantity,
          DateTime? expiryDate,
          String? notes,
        }) {
          // Create updated item
          final updated = item.copyWith(
            name: name,
            category: category,
            quantity: quantity,
            expiryDate: expiryDate,
            notes: notes,
          );

          ref.read(inventoryProvider.notifier).updateItem(updated).then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Articolo aggiornato')),
              );
            }
          });
        },
      ),
    );
  }

  void _showMovementHistory(dynamic item) async {
    final movements =
        await ref.read(inventoryRepositoryProvider).getMovementsByItemId(item.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InventoryMovementHistorySheet(
        movements: movements,
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Articolo'),
        content: Text(
          'Sei sicuro di voler eliminare "${item.name}"? Questa azione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(inventoryProvider.notifier).deleteItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Articolo eliminato')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}
