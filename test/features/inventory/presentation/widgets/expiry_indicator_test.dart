import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_prenotazioni/features/inventory/presentation/widgets/expiry_indicator.dart';
import 'package:app_prenotazioni/features/inventory/domain/entities/inventory_item.dart';

void main() {
  group('ExpiryIndicator', () {
    testWidgets('shows red for expired status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpiryIndicator(status: ExpiryStatus.expired),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration?.color, equals(Colors.red));
    });

    testWidgets('shows orange for expiringSoon status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpiryIndicator(status: ExpiryStatus.expiringSoon),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration?.color, equals(Colors.orange));
    });

    testWidgets('shows green for ok status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpiryIndicator(status: ExpiryStatus.ok),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration?.color, equals(Colors.green));
    });

    testWidgets('shows grey for notApplicable status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpiryIndicator(status: ExpiryStatus.notApplicable),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration?;

      expect(decoration?.color, isNotNull);
    });

    testWidgets('has correct size 12x12', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpiryIndicator(status: ExpiryStatus.ok),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      expect(container.constraints?.minWidth, equals(12));
      expect(container.constraints?.minHeight, equals(12));
    });
  });
}
