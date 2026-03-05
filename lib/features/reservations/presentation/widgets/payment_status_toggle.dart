import 'package:flutter/material.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

class PaymentStatusToggle extends StatelessWidget {
  final PaymentStatus value;
  final ValueChanged<PaymentStatus> onChanged;

  const PaymentStatusToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PaymentStatus>(
      segments: PaymentStatus.values.map((status) {
        return ButtonSegment<PaymentStatus>(
          value: status,
          label: Text(status.label),
          icon: Icon(status.icon),
        );
      }).toList(),
      selected: {value},
      onSelectionChanged: (Set<PaymentStatus> selection) {
        onChanged(selection.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return value.color.withValues(alpha: 0.2);
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return value.color;
          }
          return null;
        }),
      ),
    );
  }
}
