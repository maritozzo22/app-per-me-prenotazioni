import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

/// Card showing monthly income breakdown (received vs pending).
class IncomeBreakdownCard extends StatelessWidget {
  final double received;
  final double pending;

  const IncomeBreakdownCard({
    super.key,
    required this.received,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final total = received + pending;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Incassi Mensili',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatCurrency(total),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _IncomeRow(
              label: PaymentStatus.received.label,
              amount: received,
              color: PaymentStatus.received.color,
              icon: PaymentStatus.received.icon,
            ),
            const SizedBox(height: 8),
            _IncomeRow(
              label: PaymentStatus.pending.label,
              amount: pending,
              color: PaymentStatus.pending.color,
              icon: PaymentStatus.pending.icon,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return 'EUR ${amount.toStringAsFixed(2)}';
  }
}

class _IncomeRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _IncomeRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return 'EUR ${amount.toStringAsFixed(2)}';
  }
}
