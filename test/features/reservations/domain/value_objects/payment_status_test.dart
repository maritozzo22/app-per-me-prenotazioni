import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

void main() {
  group('PaymentStatus', () {
    test('should have two values: received and pending', () {
      expect(PaymentStatus.values.length, 2);
      expect(PaymentStatus.values, contains(PaymentStatus.received));
      expect(PaymentStatus.values, contains(PaymentStatus.pending));
    });

    test('received status should have correct properties', () {
      expect(PaymentStatus.received.label, 'Ricevuto');
      expect(PaymentStatus.received.icon, Icons.check_circle);
      expect(PaymentStatus.received.color, Colors.green);
    });

    test('pending status should have correct properties', () {
      expect(PaymentStatus.pending.label, 'In attesa');
      expect(PaymentStatus.pending.icon, Icons.pending);
      expect(PaymentStatus.pending.color, Colors.orange);
    });

    test('should have correct name strings', () {
      expect(PaymentStatus.received.name, 'received');
      expect(PaymentStatus.pending.name, 'pending');
    });
  });
}
