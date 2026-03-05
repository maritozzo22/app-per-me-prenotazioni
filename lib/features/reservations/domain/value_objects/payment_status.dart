import 'package:flutter/material.dart';

/// Payment status for tracking reservation payments.
enum PaymentStatus {
  received('Ricevuto', Icons.check_circle, Colors.green),
  pending('In attesa', Icons.pending, Colors.orange);

  final String label;
  final IconData icon;
  final Color color;

  const PaymentStatus(this.label, this.icon, this.color);
}
