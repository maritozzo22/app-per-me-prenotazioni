import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/reservations/presentation/widgets/payment_status_toggle.dart';
import 'package:app_prenotazioni/features/reservations/domain/value_objects/payment_status.dart';

void main() {
  group('PaymentStatusToggle', () {
    testWidgets('renders both status options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentStatusToggle(
              value: PaymentStatus.pending,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('In attesa'), findsWidgets);
      expect(find.text('Ricevuto'), findsWidgets);
    });

    testWidgets('calls onChanged when status changed', (tester) async {
      PaymentStatus? selectedStatus = PaymentStatus.pending;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentStatusToggle(
              value: selectedStatus,
              onChanged: (status) => selectedStatus = status,
            ),
          ),
        ),
      );

      // Tap on the received button
      await tester.tap(find.text('Ricevuto'));
      await tester.pumpAndSettle();

      expect(selectedStatus, PaymentStatus.received);
    });

    testWidgets('shows pending as initially selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentStatusToggle(
              value: PaymentStatus.pending,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final segmentedButton = tester.widget<SegmentedButton<PaymentStatus>>(
        find.byType(SegmentedButton<PaymentStatus>),
      );

      expect(segmentedButton.selected, contains(PaymentStatus.pending));
    });
  });
}
