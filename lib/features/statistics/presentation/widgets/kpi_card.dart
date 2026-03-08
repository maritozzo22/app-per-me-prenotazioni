import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Format type for KPI values.
enum KpiFormat {
  /// Plain number (e.g., 1,234)
  number,

  /// Currency with Euro symbol (e.g., €1,234)
  currency,

  /// Percentage (e.g., 75.5%)
  percentage,

  /// Days duration (e.g., 3.5 giorni)
  days,
}

/// Card displaying a single KPI metric.
///
/// Used in the statistics page to display key performance indicators
/// like revenue, occupancy rate, average stay duration, etc.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.format = KpiFormat.number,
    this.backgroundColor,
    this.iconColor,
  });

  /// The label for this KPI (e.g., "Fatturato", "Occupazione")
  final String title;

  /// The numeric value to display
  final dynamic value;

  /// Optional subtitle shown below the value
  final String? subtitle;

  /// Optional icon to display next to the title
  final IconData? icon;

  /// How to format the value
  final KpiFormat format;

  /// Optional background color for the card
  final Color? backgroundColor;

  /// Optional color for the icon
  final Color? iconColor;

  /// Returns the formatted value string based on the format type.
  String get formattedValue {
    switch (format) {
      case KpiFormat.currency:
        return NumberFormat.currency(symbol: '€', decimalDigits: 0).format(value);
      case KpiFormat.percentage:
        return '${value.toStringAsFixed(1)}%';
      case KpiFormat.days:
        return '${value.toStringAsFixed(1)} giorni';
      case KpiFormat.number:
      default:
        return NumberFormat.decimalPattern('it_IT').format(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return Card(
      elevation: 0,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedValue,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
