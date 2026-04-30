import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/statistics/domain/entities/period_filter.dart';

/// Selector for statistics period filter.
///
/// Displays a horizontal scrollable row of filter chips for selecting
/// the time period for statistics queries.
class PeriodFilterSelector extends StatelessWidget {
  const PeriodFilterSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.onCustomRangeSelected,
  });

  /// The currently selected period filter.
  final PeriodFilter selectedPeriod;

  /// Callback when a period is selected.
  final ValueChanged<PeriodFilter> onPeriodChanged;

  /// Optional callback for custom date range selection.
  final void Function(DateTime start, DateTime end)? onCustomRangeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: PeriodFilter.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getLabel(period)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  if (period == PeriodFilter.custom && onCustomRangeSelected != null) {
                    _showDateRangePicker(context);
                  } else {
                    onPeriodChanged(period);
                  }
                }
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Get the display label for a period filter.
  String _getLabel(PeriodFilter period) {
    switch (period) {
      case PeriodFilter.month:
        return 'Mese';
      case PeriodFilter.quarter:
        return 'Trimestre';
      case PeriodFilter.year:
        return 'Anno';
      case PeriodFilter.custom:
        return 'Personalizzato';
    }
  }

  /// Show date range picker for custom period selection.
  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );

    if (range != null && onCustomRangeSelected != null) {
      onCustomRangeSelected!(range.start, range.end);
      onPeriodChanged(PeriodFilter.custom);
    }
  }
}
