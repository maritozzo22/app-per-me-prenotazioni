import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_prenotazioni/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_category.dart';

/// Filter chips for category filtering (Tutti, Alimentari, Tessili, Altro per D-02)
class InventoryFilterChips extends ConsumerWidget {
  const InventoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            label: 'Tutti',
            isSelected: selectedCategory == null,
            onSelected: (_) {
              ref.read(selectedCategoryProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          ...InventoryCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                context: context,
                label: category.label,
                isSelected: selectedCategory == category,
                onSelected: (_) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required void Function(bool) onSelected,
  }) {
    return Semantics(
      label: isSelected ? '$label, filtro attivo' : 'Mostra $label',
      selected: isSelected,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
